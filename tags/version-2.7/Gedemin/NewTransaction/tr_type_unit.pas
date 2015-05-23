unit tr_Type_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  contnrs, xCalc, at_classes, flt_sqlfilter_condition_type, db,
  IBCustomDataSet, Ibdatabase;

const
  UserTransactionKey = 801000;
  RemainderTransactionKey = 1000;
  RemainderEntryKey       = 1001;

type
  TTypeCondition = (cEqual, cLarger, cLess, cLargerAndEqual, cLessAndEqual,
    cContain, cBegining, cInclude, cNone);

  TTypeSave = (tsDatabase, tsMemory);

  TAnalyze = class
  private
    FFromTableName: String;
    FFromFieldName: String;
    FReferencyName: String;
    FFieldName    : String;
    FValueAnalyze : Integer;

  public
    constructor Create(const aFromTableName, aFromFieldName, aReferencyName, aFieldName: String;
      const aValueAnalyze: Integer);

    property FromTableName: String read FFromTableName write FFromTableName;
    property FromFieldName: String read FFromFieldName write FFromFieldName;
    property ReferencyName: String read FReferencyName write FReferencyName;
    property FieldName: String     read FFieldName     write FFieldName;
    property ValueAnalyze: Integer read FValueAnalyze  write FValueAnalyze;

  end;

  TValue = class
  private
    FNameTable: String;
    FNameField: String;
    FValue: Currency;
    function GetNameValue: String;
  public
    constructor Create(const aNameTable, aNameField: String; const aValue: Currency); overload;
    constructor Create(Value: TValue); overload;
    property Value: Currency read FValue;
    property NameValue: String read GetNameValue;
  end;

  TAccount = class
  private
    FCode: Integer;
    FAlias: String;
    FName: String;
    FCurrencyAccount: Boolean;
    { DONE 1 -oденис -cнедочет : Где префикс F }
    FAnalyze: TObjectList;
    function GetAnalyzeItem(Index: Integer): TAnalyze;
    function SearchInRelation(const aFirst, aSecond: String): Boolean;
  public

    constructor Create(const aCode: Integer; const aAlias, aName: String;
      const aCurrencyAccount: Boolean); overload;
    constructor Create(aValue: TAccount); overload;

    destructor Destroy; override;

    function AnalyzeByType(const aReferencyName: String): Integer;
    function IsAnalyze(const aReferencyName: String): Boolean;
    function CountAnalyze: Integer;

    procedure AddAnalyze(const aFromTableName, aFromFieldName,
      aReferencyName, aFieldName: String; const aValueAnalyze: Integer);
    procedure AssignAnalyze(aAnalyze: TObjectList);

    property Code: Integer read FCode write FCode;
    property Alias: String read FAlias write FAlias;
    property Name: String read FName write FName;
    property CurrencyAccount: Boolean read FCurrencyAccount;

    property AnalyzeItem[Index: Integer]: TAnalyze read GetAnalyzeItem;
  end;

  TTypeAccount = class(TAccount)
  private
    FExprNCU: String;
    FExprCurr: String;
    FExprEq: String;
  public
    constructor Create(const aCode: Integer; const aAlias, aName, aExprNCU,
      aExprCurr, aExprEq: String; const aCurrencyAccount: Boolean); overload;
    constructor Create(aValue: TTypeAccount); overload;

    function IsUseVariable(const aVariable: String): Boolean;

    property ExprNCU: String read FExprNCU write FExprNCU;
    property ExprCurr: String read FExprCurr write FExprCurr;
    property ExprEq: String read FExprEq write FExprEq;
  end;

  TRealAccount = class(TAccount)
  private
    FSumNCU: Currency;
    FSumCurr: Currency;
    FSumEq: Currency;
    FCurrKey: Integer;
  public
    constructor Create(const aCode: Integer; const aAlias, aName: String;
      const aSumNCU, aSumCurr, aSumEq: Currency; const aCurrencyAccount: Boolean;
      const aCurrKey: Integer); overload;
    constructor Create(aTypeAccount: TTypeAccount; aValueList, aAnalyzeList: TObjectList;
      aCurrKey: Integer); overload;
    constructor Create(aValue: TRealAccount); overload;

    procedure SetNewAnalyze(aNewAnalyzeList: TObjectList);

    property SumNCU: Currency read FSumNCU write FSumNCU;
    property SumCurr: Currency read FSumCurr write FSumCurr;
    property SumEq: Currency read FSumEq write FSumEq;
    property CurrKey: Integer read FCurrKey write FCurrKey;
  end;


  TEntry = class
  private
    FEntryDate: TDateTime;
    FEntryKey: Integer;
    FDescription: String;
    FDocumentKey: Integer;
    FPositionKey: Integer;
    FChanged: Boolean;

    { DONE 1 -oденис -cнедочет : Где префикс F }
    FDebits: TObjectList;
    FCredits: TObjectList;
    function GetDebit(Index: Integer): TAccount;
    function GetCredit(Index: Integer): TAccount;
    function GetCreditCount: Integer;
    function GetDebitCount: Integer;
    function TypeBasedAccount: Char;

  public

    constructor Create(const aEntryKey, aDocumentKey, aPositionKey: Integer;
      const aEntryDate: TDateTime); overload;
    constructor Create(aValue: TEntry; const IsType: Boolean); overload;

    destructor Destroy; override;
    procedure AddEntryLine(AccountInfo: TAccount; const IsDebit: Boolean;
      const aDescription: String);

    procedure AddFromTypeEntry(TypeEntry: TEntry; aValueList, aAnalyzeList: TObjectList;
      aCurrKey: Integer);
    procedure SetSumFromTypeEntry(TypeEntry: TEntry; aValueList: TObjectList);

    function IsUseVariable(const aVariable: String): Boolean;

    procedure Clear;

    function CheckBalans: Boolean;

    function GetDebitSumNCU: Currency;
    function GetCreditSumNCU: Currency;
    function GetDebitSumCurr: Currency;
    function GetCreditSumCurr: Currency;

    function IsCurrencyEntry: Boolean;

    property EntryDate: TDateTime read FEntryDate write FEntryDate;
    property EntryKey: Integer read FEntryKey write FEntryKey;
    property Description: String read FDescription write FDescription;
    property DocumentKey: Integer read FDocumentKey write FDocumentKey;
    property PositionKey: Integer read FPositionKey write FPositionKey;
    property Changed: Boolean read FChanged write FChanged;

    property Debit[Index: Integer]: TAccount read GetDebit;
    property Credit[Index: Integer]: TAccount read GetCredit;
    property DebitCount: Integer read GetDebitCount;
    property CreditCount: Integer read GetCreditCount;
  end;

  TTypeRelation = (trValue, trCondition, trAnalyze, trNone);
  TTypeRelations = set of TTypeRelation;

  TTransactionRelationField = class
  private
    FRelationName: String;
    FFieldName: String;
    FTypeRelations: TTypeRelations;
    FOldOnChange: TFieldNotifyEvent;
    procedure SetOldOnChange(const Value: TFieldNotifyEvent);
  public

    constructor Create(const aRelationName, aFieldName: String;
      const aTypeRelation: TTypeRelation);
    procedure AddTypeRelation(const aTypeRelation: TTypeRelation);

    property RelationName: String read FRelationName;
    property FieldName: String read FFieldName;
    property TypeRelations: TTypeRelations read FTypeRelations;
    property OldOnChange: TFieldNotifyEvent read FOldOnChange write
      SetOldOnChange;
  end;

  TTransaction = class
  private
    FTransactionKey: Integer;
    FDocumentTypeKey: Integer;
    FTransactionName: String;
    FDescription: String;
    FIsDocument: Boolean;

    FTransactionFilterData: TFilterData;
    FTypeEntryList: TObjectList;

    function GetTypeEntry(Index: Integer): TEntry;
    function GetTypeEntryCount: Integer;
  public
    constructor Create(const aTransactionKey, aDocumentTypeKey: Integer;
      const aTransactionName, aDescription: String; const aIsDocument: Boolean);
    destructor Destroy; override;
    procedure Assign(Value: TTransaction); virtual;
    function IsTransaction(aTransaction: TIBTransaction;
      Values: TFilterConditionList): Boolean;

    procedure AddTransactionCondition(LocBlobStream: TIBDSBlobStream);

    procedure AddTypeEntry(Entry: TEntry);

    function IsUseVariable(const aVariable: String): Boolean;
    function IsCurrencyTransaction: Boolean;

    property TransactionFilterData: TFilterData read FTransactionFilterData;
    property TransactionKey: Integer read FTransactionKey write FTransactionKey;
    property DocumentTypeKey: Integer read FDocumentTypeKey write FDocumentTypeKey;
    property IsDocument: Boolean read FIsDocument write FIsDocument;
    property TransactionName: String read FTransactionName write FTransactionName;
    property Description: String read FDescription write FDescription;

    property TypeEntry[Index: Integer]: TEntry read GetTypeEntry;

    property TypeEntryCount: Integer read GetTypeEntryCount;
  end;

  TPositionTransaction = class(TTransaction)
  private
    FDocumentCode: Integer;
    FPositionCode: Integer;
    FTransactionDate: TDateTime;
    FTransactionChanged: Boolean;
    FRealEntryList: TObjectList;

    function GetRealEntry(Index: Integer): TEntry;
    function GetRealEntryCount: Integer;
    procedure SetTransactionDate(const Value: TDateTime);
    function GetSumTransaction: Currency;
  public

    constructor Create; overload;
    constructor Create(const aTransactionKey, aDocumentTypeKey, aDocumentCode,
      aPositionCode: Integer; const aTransactionName, aDescription: String;
      const aTransactionDate: TDateTime; const aIsDocument: Boolean); overload;

    procedure Assign(Value: TTransaction); override;

    destructor Destroy; override;

    procedure AddRealEntry(Entry: TEntry);
    function CreateRealEntry(const aValueList, aAnalyzeList: TObjectList;
       const aCurrKey: Integer): Boolean;
    procedure ClearRealEntry;

{ Функция зменяет в уже сформированных реальных проводках сумму и документ }
{ возвращает Истину если это удалось сделать и Ложь в противном случае     }

    function ChangeValue(const aDocumentKey, aPositionKey: Integer;
      const aDocumentDate: TDateTime; ValueList: TObjectList): Boolean;

    property DocumentCode: Integer read FDocumentCode write FDocumentCode;
    property PositionCode: Integer read FPositionCode write FPositionCode;
    property TransactionDate: TDateTime read FTransactionDate write SetTransactionDate;
    property TransactionChanged: Boolean read FTransactionChanged write
      FTransactionChanged;

    property SumTransaction: Currency read GetSumTransaction;
    property RealEntry[Index: Integer]: TEntry read GetRealEntry;
    property RealEntryCount: Integer read GetRealEntryCount;
  end;

  type
    TRelationAnalyzeName = record
      FirstName: String;
      SecondName: String;
    end;


  const
    CountRelationAnalyzeName = 2;

    RelationAnalyzeNames: array[1..CountRelationAnalyzeName] of TRelationAnalyzeName =
    ( (FirstName: 'GD_CONTACT'; SecondName: 'GD_COMPANY'),
      (FirstName: 'GD_CONTACT'; SecondName: 'GD_PEOPLE'));

implementation

uses flt_AdditionalFunctions;

{ TAnalyze -----------------------------------------------------------------}

constructor TAnalyze.Create(const aFromTableName, aFromFieldName,
  aReferencyName, aFieldName: String; const aValueAnalyze: Integer);
begin
  FReferencyName := aReferencyName;
  FFieldName := aFieldName;
  FValueAnalyze := aValueAnalyze;
  FFromTableName := aFromTableName;
  FFromFieldName := aFromFieldName;
end;


{ TValue --------------------------------------------------------------------- }

constructor TValue.Create(const aNameTable, aNameField: String; const aValue: Currency);
begin
  FNameTable := aNameTable;
  FNameField := aNameField;
  FValue := aValue;
end;

constructor TValue.Create(Value: TValue);
begin
  FNameTable := Value.FNameTable;
  FNameField := Value.FNameField;
  FValue := Value.FValue;
end;

function TValue.GetNameValue: String;
var
  R: TatRelationField;
begin
  Result := '';
  R := atDatabase.FindRelationField(FNameTable, FNameField);
  if Assigned(R) and Assigned(R.Relation) then
    Result := Trim(R.Relation.LShortName) + '_' + Trim(R.LShortName);
end;


{ TAccount --------------------------------------------------------------------}

constructor TAccount.Create(const aCode: Integer; const aAlias, aName: String;
  const aCurrencyAccount: Boolean);
begin
  FCode := aCode;
  FAlias := aAlias;
  FName := aName;
  FCurrencyAccount := aCurrencyAccount;

  FAnalyze := TObjectList.Create;
end;

constructor TAccount.Create(aValue: TAccount);
var
  i: Integer;
begin
  FCode := aValue.Code;
  FAlias := aValue.Alias;
  FName := aValue.Name;
  FCurrencyAccount := aValue.CurrencyAccount;

  FAnalyze := TObjectList.Create;

  for i:= 0 to aValue.CountAnalyze - 1 do
    FAnalyze.Add(TAnalyze.Create(
      aValue.AnalyzeItem[i].FFromTableName,
      aValue.AnalyzeItem[i].FFromFieldName,
      aValue.AnalyzeItem[i].FReferencyName,
      aValue.AnalyzeItem[i].FFieldName, aValue.AnalyzeItem[i].FValueAnalyze)); 
end;

destructor TAccount.Destroy;
begin
  if Assigned(FAnalyze) then
    FreeAndNil(FAnalyze);
  inherited Destroy;
end;

function TAccount.SearchInRelation(const aFirst, aSecond: String): Boolean;
var
  k: Integer;
begin
  Result := False;
  for k:= 1 to CountRelationAnalyzeName do
    if (RelationAnalyzeNames[k].FirstName = Trim(aFirst)) and
       (RelationAnalyzeNames[k].SecondName = Trim(aSecond))
    then
    begin
      Result := True;
      Break;
    end;
end;

function TAccount.AnalyzeByType(const aReferencyName: String): Integer;
var
  i: Integer;

begin
  Result := -1;
  for i:= 0 to FAnalyze.Count - 1 do
    if (TAnalyze(FAnalyze[i]).FReferencyName = aReferencyName) or
       SearchInRelation(TAnalyze(FAnalyze[i]).FReferencyName, aReferencyName)
    then
    begin
      Result := TAnalyze(FAnalyze[i]).FValueAnalyze;
      Break;
    end;
end;

function TAccount.IsAnalyze(const aReferencyName: String): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i:= 0 to FAnalyze.Count - 1 do
    if (TAnalyze(FAnalyze[i]).FReferencyName = aReferencyName) or
       SearchInRelation(TAnalyze(FAnalyze[i]).FReferencyName, aReferencyName)
    then
    begin
      Result := True;
      Break;
    end;
end;

function TAccount.CountAnalyze: Integer;
begin
  if Assigned(FAnalyze) then
    Result := FAnalyze.Count
  else
    Result := 0;
end;

function TAccount.GetAnalyzeItem(Index: Integer): TAnalyze;
begin
  if (Index >= 0) and (Index < CountAnalyze) then
    Result := TAnalyze(FAnalyze[Index])
  else
    Result := nil;
end;

procedure TAccount.AddAnalyze(const aFromTableName, aFromFieldName,
  aReferencyName, aFieldName: String; const aValueAnalyze: Integer);
var
  i: Integer;
  isFind: Boolean;
begin
  isFind := False;
  
  for i:= 0 to CountAnalyze - 1 do
    if AnalyzeItem[i].FFieldName = aFieldName then
    begin
      isFind := True;
      Break;
    end;

  if not isFind then
    FAnalyze.Add(TAnalyze.Create(aFromTableName, aFromFieldName, aReferencyName,
      aFieldName, aValueAnalyze));
end;

procedure TAccount.AssignAnalyze(aAnalyze: TObjectList);
var
  i: Integer;
begin
  for i:= 0 to aAnalyze.Count - 1 do
    FAnalyze.Add(TAnalyze.Create(
      TAnalyze(aAnalyze[i]).FFromTableName,
      TAnalyze(aAnalyze[i]).FFromFieldName,
      TAnalyze(aAnalyze[i]).FReferencyName,
      TAnalyze(aAnalyze[i]).FFieldName, -1));
end;


{ TTypeAccount ----------------------------------------------------------------}

constructor TTypeAccount.Create(const aCode: Integer; const aAlias, aName,
  aExprNCU, aExprCurr, aExprEq: String; const aCurrencyAccount: Boolean);
begin
  inherited Create(aCode, aAlias, aName, aCurrencyAccount);
  FExprNCU := aExprNCU;
  FExprCurr := aExprCurr;
  FExprEq := aExprEq;
end;

constructor TTypeAccount.Create(aValue: TTypeAccount);
begin
  inherited Create(aValue);

  FExprNCU := TTypeAccount(aValue).ExprNCU;
  FExprCurr := TTypeAccount(aValue).ExprCurr;
  FExprEq := TTypeAccount(aValue).ExprEq;
end;

function TTypeAccount.IsUseVariable(const aVariable: String): Boolean;
begin
  Result := (Pos(AnsiUpperCase(aVariable), AnsiUpperCase(FExprNCU)) > 0) or
            (Pos(AnsiUpperCase(aVariable), AnsiUpperCase(FExprCurr)) > 0) or
            (Pos(AnsiUpperCase(aVariable), AnsiUpperCase(FExprEq)) > 0);
end;


{ TRealAccount ----------------------------------------------------------------}

constructor TRealAccount.Create(const aCode: Integer; const aAlias, aName: String;
      const aSumNCU, aSumCurr, aSumEq: Currency; const aCurrencyAccount: Boolean;
      const aCurrKey: Integer);
begin
  inherited Create(aCode, aAlias, aName, aCurrencyAccount);
  FSumNCU := aSumNCU;
  FSumCurr := aSumCurr;
  FSumEq := aSumEq;
  FCurrKey := aCurrKey;
end;

constructor TRealAccount.Create(aTypeAccount: TTypeAccount;
  aValueList, aAnalyzeList: TObjectList; aCurrKey: Integer);
var
  i: Integer;
  xFocal: TxFoCal;
begin
  Assert(Assigned(aTypeAccount), 'Типовой счет - nil');

  inherited Create(aTypeAccount.Code, aTypeAccount.Alias, aTypeAccount.Name,
    aTypeAccount.CurrencyAccount);
    
  xFocal := TxFocal.Create(Application);
  try
    for i:= 0 to aValueList.Count - 1 do
      xFocal.AssignVariable(TValue(aValueList[i]).NameValue, TValue(aValueList[i]).Value);

    xFocal.Expression := aTypeAccount.ExprNCU;
    FSumNCU := xFocal.Value;

    xFocal.Expression := aTypeAccount.ExprCurr;
    FSumCurr := xFocal.Value;

    xFocal.Expression := aTypeAccount.ExprEq;
    FSumEq := xFocal.Value;

    if Assigned(aAnalyzeList) then
    begin
      AssignAnalyze(aTypeAccount.FAnalyze);
      SetNewAnalyze(aAnalyzeList);
    end;  
  finally
    xFocal.Free;
  end;
  
end;


constructor TRealAccount.Create(aValue: TRealAccount);
begin
  inherited Create(aValue);

  FSumNCU := aValue.SumNCU;
  FSumCurr := aValue.SumCurr;
  FSumEq := aValue.SumEq;
  FCurrKey := aValue.CurrKey;
end;

procedure TRealAccount.SetNewAnalyze(aNewAnalyzeList: TObjectList);
var
  i, j: Integer;
begin
  for i:= 0 to FAnalyze.Count - 1 do
  begin
    for j:= 0 to aNewAnalyzeList.Count - 1 do
      if (
         (Trim(TAnalyze(FAnalyze[i]).FReferencyName) = Trim(TAnalyze(aNewAnalyzeList[j]).FReferencyName)) or
         SearchInRelation(TAnalyze(FAnalyze[i]).FReferencyName, TAnalyze(aNewAnalyzeList[j]).FReferencyName)
         )
         and
         (TAnalyze(FAnalyze[i]).FValueAnalyze <= 0) and
         ((TAnalyze(FAnalyze[i]).FFromTableName = '') or
          (TAnalyze(FAnalyze[i]).FFromTableName = TAnalyze(aNewAnalyzeList[j]).FFromTableName)) and
         ((TAnalyze(FAnalyze[i]).FFromFieldName = '') or
          (TAnalyze(FAnalyze[i]).FFromFieldName = TAnalyze(aNewAnalyzeList[j]).FFromFieldName))
      then
      begin
        TAnalyze(FAnalyze[i]).FValueAnalyze := TAnalyze(aNewAnalyzeList[j]).FValueAnalyze;
//        Break;
      end;
  end;
end;


{ TEntry ----------------------------------------------------------------------}

constructor TEntry.Create(const aEntryKey, aDocumentKey, aPositionKey: Integer;
  const aEntryDate: TDateTime);
begin
  FEntryKey := aEntryKey;
  FEntryDate := aEntryDate;
  FPositionKey := aPositionKey;
  FDocumentKey := aDocumentKey;
  FChanged := False;

  FDebits := TObjectList.Create;
  FCredits := TObjectList.Create;
  FDescription := '';
end;

constructor TEntry.Create(aValue: TEntry; const IsType: Boolean);
var
  i: Integer;
begin
  FDebits := TObjectList.Create;
  FCredits := TObjectList.Create;

  FEntryKey := aValue.EntryKey;
  FEntryDate := aValue.EntryDate;
  FPositionKey := aValue.PositionKey;
  FDocumentKey := aValue.DocumentKey;
  FDescription := aValue.Description;

  for i:= 0 to aValue.DebitCount - 1 do
    if IsType and (aValue.Debit[i] is TTypeAccount) then
      FDebits.Add(TTypeAccount.Create(TTypeAccount(aValue.Debit[i])))
    else
      if not isType and (aValue.Debit[i] is TRealAccount) then
        FDebits.Add(TRealAccount.Create(TRealAccount(aValue.Debit[i])));

  for i:= 0 to aValue.CreditCount - 1 do
    if IsType and (aValue.Credit[i] is TTypeAccount) then
      FCredits.Add(TTypeAccount.Create(TTypeAccount(aValue.Credit[i])))
    else
      if not isType and (aValue.Credit[i] is TRealAccount) then
        FCredits.Add(TRealAccount.Create(TRealAccount(aValue.Credit[i])));

end;

procedure TEntry.Clear;
begin
  if Assigned(FDebits) then
    FDebits.Clear;

  if Assigned(FCredits) then
    FCredits.Clear;  
end;

function TEntry.CheckBalans: Boolean;
begin

  Result := (GetCreditSumNCU = GetDebitSumNCU) and (GetCreditSumCurr = GetDebitSumCurr);

end;

function TEntry.GetCreditSumNCU: Currency;
var
  i: Integer;
begin
  Result := 0;
  if (CreditCount = 0) or not (Credit[0] is TRealAccount) then
    exit;
  for i:= 0 to CreditCount - 1 do
    Result := Result + TRealAccount(Credit[i]).SumNCU;
end;

function TEntry.GetDebitSumNCU: Currency;
var
  i: Integer;
begin
  Result := 0;
  if (DebitCount = 0) or not (Debit[0] is TRealAccount) then
    exit;
  for i:= 0 to DebitCount - 1 do
    Result := Result + TRealAccount(Debit[i]).SumNCU;
end;

function TEntry.GetCreditSumCurr: Currency;
var
  i: Integer;
begin
  Result := 0;
  if (CreditCount = 0) or not (Credit[0] is TRealAccount) then
    exit;
  for i:= 0 to CreditCount - 1 do
    Result := Result + TRealAccount(Credit[i]).SumCurr;
end;

function TEntry.GetDebitSumCurr: Currency;
var
  i: Integer;
begin
  Result := 0;
  if (DebitCount = 0) or not (Debit[0] is TRealAccount) then
    exit;
  for i:= 0 to DebitCount - 1 do
    Result := Result + TRealAccount(Debit[i]).SumCurr;
end;

function TEntry.IsCurrencyEntry: Boolean;
var
  i: Integer;
begin
  Result := False;
  for i:= 0 to DebitCount - 1 do
    Result := Result or Debit[i].CurrencyAccount;

  if not Result then
    for i:= 0 to CreditCount - 1 do
      Result := Result or Credit[i].CurrencyAccount;   
end;

procedure TEntry.AddEntryLine(AccountInfo: TAccount; const IsDebit: Boolean;
      const aDescription: String);
begin
  if isDebit then
    FDebits.Add(AccountInfo)
  else
    FCredits.Add(AccountInfo);

  if aDescription > '' then
    FDescription := FDescription;

end;

function TEntry.TypeBasedAccount: Char;
var
  i: Integer;
begin
  Result := #0;
  for i:= 0 to DebitCount - 1 do
    if (TTypeAccount(Debit[i]).FExprNCU = '') and
       (TTypeAccount(Debit[i]).FExprCurr = '') and
       (TTypeAccount(Debit[i]).FExprEq = '')
    then
    begin
      Result := #0;
      Break;
    end
    else
      Result := 'D';

  if Result = #0 then
    for i:= 0 to CreditCount - 1 do
      if (TTypeAccount(Credit[i]).FExprNCU = '') and
         (TTypeAccount(Credit[i]).FExprCurr = '') and
         (TTypeAccount(Credit[i]).FExprEq = '')
      then
      begin
        Result := #0;
        Break;
      end
      else
        Result := 'K';

end;

procedure TEntry.AddFromTypeEntry(TypeEntry: TEntry; aValueList, aAnalyzeList: TObjectList;
  aCurrKey: Integer);
var
  i: Integer;
  RealAccount: TRealAccount;
  SumNCU, SumCurr, SumEq: Currency;
begin
  Changed := True;

  if TypeEntry.TypeBasedAccount = 'D' then
  begin
    SumNCU := 0;
    SumCurr := 0;
    SumEq := 0;
    for i:= 0 to TypeEntry.DebitCount - 1 do
    begin
      RealAccount := TRealAccount.Create(TTypeAccount(TypeEntry.Debit[i]), aValueList,
        aAnalyzeList, aCurrKey);
      SumNCU := SumNCU + RealAccount.SumNCU;
      SumCurr := SumCurr + RealAccount.SumCurr;
      SumEq := SumEq + RealAccount.SumEq;
      AddEntryLine(RealAccount, True, '');
    end;

    for i:= 0 to TypeEntry.CreditCount - 1 do
    begin
      RealAccount := TRealAccount.Create(TypeEntry.Credit[i].Code, TypeEntry.Credit[i].Alias,
        TypeEntry.Credit[i].Name, SumNCU / TypeEntry.CreditCount,
        SumCurr / TypeEntry.CreditCount, SumEq / TypeEntry.CreditCount,
        TypeEntry.Credit[i].CurrencyAccount, aCurrKey);
      RealAccount.AssignAnalyze(TypeEntry.Credit[i].FAnalyze);
      RealAccount.SetNewAnalyze(aAnalyzeList);
      AddEntryLine(RealAccount, False, '');
    end;
  end
  else
    if TypeEntry.TypeBasedAccount = 'K' then
    begin
      SumNCU := 0;
      SumCurr := 0;
      SumEq := 0;
      for i:= 0 to TypeEntry.CreditCount - 1 do
      begin
        RealAccount := TRealAccount.Create(TTypeAccount(TypeEntry.Credit[i]), aValueList,
          aAnalyzeList, aCurrKey);
        SumNCU := SumNCU + RealAccount.SumNCU;
        SumCurr := SumCurr + RealAccount.SumCurr;
        SumEq := SumEq + RealAccount.SumEq;
        AddEntryLine(RealAccount, False, '');
      end;

      for i:= 0 to TypeEntry.DebitCount - 1 do
      begin
        RealAccount := TRealAccount.Create(TypeEntry.Debit[i].Code, TypeEntry.Debit[i].Alias,
          TypeEntry.Debit[i].Name, SumNCU / TypeEntry.DebitCount,
          SumCurr / TypeEntry.DebitCount, SumEq / TypeEntry.DebitCount,
          TypeEntry.Debit[i].CurrencyAccount, aCurrKey);
        RealAccount.AssignAnalyze(TypeEntry.Debit[i].FAnalyze);
        RealAccount.SetNewAnalyze(aAnalyzeList);
        AddEntryLine(RealAccount, True, '');
      end;
    end;
end;

procedure TEntry.SetSumFromTypeEntry(TypeEntry: TEntry; aValueList: TObjectList);
var
  i: Integer;
  RealAccount: TRealAccount;
  SumNCU, SumCurr, SumEq: Currency;
begin
  Changed := True;
  RealAccount := nil;

  if TypeEntry.TypeBasedAccount = 'D' then
  begin
    SumNCU := 0;
    SumCurr := 0;
    SumEq := 0;
    for i:= 0 to TypeEntry.DebitCount - 1 do
    begin
      if i < DebitCount then
      begin
        RealAccount := TRealAccount.Create(TTypeAccount(TypeEntry.Debit[i]), aValueList,
          nil, (Debit[i] as TRealAccount).CurrKey);
        try
          SumNCU := SumNCU + RealAccount.SumNCU;
          SumCurr := SumCurr + RealAccount.SumCurr;
          SumEq := SumEq + RealAccount.SumEq;
          (Debit[i] as TRealAccount).SumNCU := RealAccount.SumNCU;
          (Debit[i] as TRealAccount).SumCurr := RealAccount.SumCurr;
          (Debit[i] as TRealAccount).SumEq := RealAccount.SumEq;
        finally
          FreeAndNil(RealAccount);
        end;
      end;
    end;

    for i:= 0 to CreditCount - 1 do
    begin
      (Credit[i] as TRealAccount).SumNCU := SumNCU / CreditCount;
      (Credit[i] as TRealAccount).SumCurr := SumCurr / CreditCount;
      (Credit[i] as TRealAccount).SumEq := SumEq / CreditCount;
    end;
  end
  else
    if TypeEntry.TypeBasedAccount = 'K' then
    begin
      SumNCU := 0;
      SumCurr := 0;
      SumEq := 0;
      for i:= 0 to TypeEntry.CreditCount - 1 do
      begin
        if i < CreditCount then
        begin
          RealAccount := TRealAccount.Create(TTypeAccount(TypeEntry.Credit[i]), aValueList,
            nil, (Credit[i] as TRealAccount).CurrKey);
          try
            SumNCU := SumNCU + RealAccount.SumNCU;
            SumCurr := SumCurr + RealAccount.SumCurr;
            SumEq := SumEq + RealAccount.SumEq;
            (Credit[i] as TRealAccount).SumNCU := RealAccount.SumNCU;
            (Credit[i] as TRealAccount).SumCurr := RealAccount.SumCurr;
            (Credit[i] as TRealAccount).SumEq := RealAccount.SumEq;
          finally
            FreeAndNil(RealAccount);
          end;
        end;
      end;

      for i:= 0 to DebitCount - 1 do
      begin
        (Debit[i] as TRealAccount).SumNCU := SumNCU / CreditCount;
        (Debit[i] as TRealAccount).SumCurr := SumCurr / CreditCount;
        (Debit[i] as TRealAccount).SumEq := SumEq / CreditCount;
      end;
    end;
end;

function TEntry.GetDebit(Index: Integer): TAccount;
begin
  if (Index >= 0) and (Index < DebitCount) then
    Result := TAccount(FDebits[Index])
  else
    Result := nil;
end;

function TEntry.GetCredit(Index: Integer): TAccount;
begin
  if (Index >= 0) and (Index < CreditCount) then
    Result := TAccount(FCredits[Index])
  else
    Result := nil;
end;

function TEntry.GetCreditCount: Integer;
begin
  if Assigned(FCredits) then
    Result := FCredits.Count
  else
    Result := 0;  
end;

function TEntry.GetDebitCount: Integer;
begin
  if Assigned(FDebits) then
    Result := FDebits.Count
  else
    Result := 0;  
end;

destructor TEntry.Destroy;
begin
  if Assigned(FDebits) then
    FreeAndNil(FDebits);
  if Assigned(FCredits) then
    FreeAndNil(FCredits);

  inherited;
end;

function TEntry.IsUseVariable(const aVariable: String): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i:= 0 to DebitCount - 1 do
    if Debit[i] is TTypeAccount then
    begin
      Result := (Debit[i] as TTypeAccount).IsUseVariable(aVariable);
      if Result then
        Break;
    end
    else
      Break;

  if not Result then
    for i:= 0 to CreditCount - 1 do
      if Credit[i] is TTypeAccount then
      begin
        Result := (Credit[i] as TTypeAccount).IsUseVariable(aVariable);
        if Result then
          Break;
      end
      else
        Break;
end;


{ TTransactionRelationField }

procedure TTransactionRelationField.AddTypeRelation(
  const aTypeRelation: TTypeRelation);
begin
  if not (aTypeRelation in TypeRelations) then
    FTypeRelations := FTypeRelations + [aTypeRelation];
end;

constructor TTransactionRelationField.Create(const aRelationName,
  aFieldName: String; const aTypeRelation: TTypeRelation);
begin
  FRelationName := aRelationName;
  FFieldName := aFieldName;
  FOldOnChange := nil;
  FTypeRelations := [];
  AddTypeRelation(aTypeRelation);
end;

procedure TTransactionRelationField.SetOldOnChange(
  const Value: TFieldNotifyEvent);
begin
  FOldOnChange := Value;
end;

{ TTransaction --------------------------------------------------------------- }

constructor TTransaction.Create(const aTransactionKey, aDocumentTypeKey: Integer;
  const aTransactionName, aDescription: String; const aIsDocument: Boolean);
begin
  FTransactionKey := aTransactionKey;
  FDocumentTypeKey := aDocumentTypeKey;
  FTransactionName := aTransactionName;
  FDescription := aDescription;

  FIsDocument := aIsDocument;

  FTransactionFilterData := TFilterData.Create;
  FTypeEntryList := TObjectList.Create;

end;

destructor TTransaction.Destroy;
begin
  if Assigned(FTransactionFilterData) then
    FreeAndNil(FTransactionFilterData);

  if Assigned(FTypeEntryList) then
    FreeAndNil(FTypeEntryList);

  inherited;
end;

procedure TTransaction.AddTransactionCondition(
  LocBlobStream: TIBDSBlobStream);
begin
  try
    FTransactionFilterData.ConditionList.ReadFromStream(LocBlobStream);
  except
  end;  
end;

procedure TTransaction.AddTypeEntry(Entry: TEntry);
begin
  FTypeEntryList.Add(Entry);
end;

function TTransaction.IsTransaction(aTransaction: TIBTransaction;
  Values: TFilterConditionList): Boolean;
begin
  Result := Assigned(FTransactionFilterData);
  if not Result then exit;
  try
    Result := CheckIncludeCondition(aTransaction.DefaultDatabase, aTransaction,
      FTransactionFilterData.ConditionList, Values);
  except
    Result := False;
  end;
end;

function TTransaction.GetTypeEntry(Index: Integer): TEntry;
begin
  if (Index >= 0) and (Index < TypeEntryCount) then
    Result := TEntry(FTypeEntryList[Index])
  else
    Result := nil;
end;

function TTransaction.GetTypeEntryCount: Integer;
begin
  if Assigned(FTypeEntryList) then
    Result := FTypeEntryList.Count
  else
    Result := 0;
end;

procedure TTransaction.Assign(Value: TTransaction);
var
  i: Integer;
begin
  FTransactionKey := Value.TransactionKey;
  FDocumentTypeKey := Value.DocumentTypeKey;
  FTransactionName := Value.TransactionName;
  FDescription := Value.Description;
  FIsDocument := Value.IsDocument;

  FTransactionFilterData.Assign(Value.TransactionFilterData);

  FTypeEntryList.Clear;

  for i:= 0 to Value.TypeEntryCount - 1 do
    FTypeEntryList.Add(TEntry.Create(Value.TypeEntry[i], True));
end;

function TTransaction.IsUseVariable(const aVariable: String): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i:= 0 to TypeEntryCount - 1 do
  begin
    Result := TypeEntry[i].IsUseVariable(aVariable);
    if Result then
      Break;
  end;
end;

function TTransaction.IsCurrencyTransaction: Boolean;
var
  i: Integer;
begin
  Result := False;
  for i:= 0 to TypeEntryCount - 1 do
    Result := Result or TypeEntry[i].IsCurrencyEntry;
end;

{ TPositionTransaction }

constructor TPositionTransaction.Create;
begin
  inherited Create(-1, -1, '', '', False);
  FDocumentCode := -1;
  FPositionCode := -1;
  FTransactionDate := 0;
  FTransactionChanged := False;

  FRealEntryList := TObjectList.Create;
{  FValueList := TObjectList.Create;
  FAnalyzeList := TObjectList.Create;}
end;

constructor TPositionTransaction.Create(const aTransactionKey,
  aDocumentTypeKey, aDocumentCode, aPositionCode: Integer;
  const aTransactionName, aDescription: String; const aTransactionDate: TDateTime;
  const aIsDocument: Boolean);
begin
  inherited Create(aTransactionKey, aDocumentTypeKey, aTransactionName, aDescription,
    aIsDocument);

  FDocumentCode := aDocumentCode;
  FPositionCode := aPositionCode;
  FTransactionDate := aTransactionDate;
  FTransactionChanged := False;

  FRealEntryList := TObjectList.Create;
{  FValueList := TObjectList.Create;
  FAnalyzeList := TObjectList.Create;}

end;

destructor TPositionTransaction.Destroy;
begin
  if Assigned(FRealEntryList) then
    FreeAndNil(FRealEntryList);

{  if Assigned(FValueList) then
    FreeAndNil(FValueList);

  if Assigned(FAnalyzeList) then
    FreeAndNil(FAnalyzeList);}

  inherited Destroy;  
end;

procedure TPositionTransaction.ClearRealEntry;
begin
  FRealEntryList.Clear;
end;

function TPositionTransaction.CreateRealEntry(const aValueList,
  aAnalyzeList: TObjectList; const aCurrKey: Integer): Boolean;

var
  i: Integer;
  Entry: TEntry;
begin
  Result := True;

  FRealEntryList.Clear;

  for i:= 0 to FTypeEntryList.Count - 1 do
  begin
    Entry := TEntry.Create(i, DocumentCode, PositionCode, TransactionDate);

    if Assigned(aValueList) and Assigned(aAnalyzeList) then
      Entry.AddFromTypeEntry(TEntry(FTypeEntryList[i]), aValueList, aAnalyzeList, aCurrKey);
    FRealEntryList.Add(Entry);
  end;

  FTransactionChanged := False;

end;


function TPositionTransaction.GetRealEntry(Index: Integer): TEntry;
begin
  if (Index >= 0) and (Index < RealEntryCount) then
    Result := TEntry(FRealEntryList[Index])
  else
    Result := nil;
end;

function TPositionTransaction.GetRealEntryCount: Integer;
begin
  if Assigned(FRealEntryList) then
    Result := FRealEntryList.Count
  else
    Result := 0;
end;

procedure TPositionTransaction.Assign(Value: TTransaction);
var
  i: Integer;
begin
  inherited Assign(Value);

  FDocumentCode := TPositionTransaction(Value).DocumentCode;
  FPositionCode := TPositionTransaction(Value).PositionCode;
  FTransactionDate := TPositionTransaction(Value).TransactionDate;
  FTransactionChanged := TPositionTransaction(Value).TransactionChanged;

  FRealEntryList.Clear;
  for i:= 0 to TPositionTransaction(Value).RealEntryCount - 1 do
    FRealEntryList.Add(TEntry.Create(TPositionTransaction(Value).RealEntry[i], False));

end;

procedure TPositionTransaction.AddRealEntry(Entry: TEntry);
begin
  if Assigned(Entry) then
    FRealEntryList.Add(Entry);
end;

function TPositionTransaction.ChangeValue(const aDocumentKey,
  aPositionKey: Integer; const aDocumentDate: TDateTime;
  ValueList: TObjectList): Boolean;
var
  i, j, k: Integer;
  NumTypeEntry: Integer;
  isOk: Boolean;
begin

{ Для сформированных  проводок ищем типовую, по ней рассчитываем сумму и заменяем }

  Result := True;

  for i:= 0 to RealEntryCount - 1 do
  begin

    NumTypeEntry := -1;
    for j := 0 to TypeEntryCount - 1 do
    begin
      if (RealEntry[i].DebitCount <> TypeEntry[j].DebitCount) or
         (RealEntry[i].CreditCount <> TypeEntry[j].CreditCount)
      then
        Continue;
      isOK := True;
      for k := 0 to RealEntry[i].DebitCount - 1 do
        if RealEntry[i].Debit[k].Code <> TypeEntry[j].Debit[k].Code then
        begin
          isOK := False;
          Break;
        end;
      if isOK then
      begin
        for k := 0 to RealEntry[i].CreditCount - 1 do
          if RealEntry[i].Credit[k].Code <> TypeEntry[j].Credit[k].Code then
          begin
            isOK := False;
            Break;
          end;
        if isOk then
        begin
          NumTypeEntry := j;
          Break;
        end;
      end;
    end;

    if NumTypeEntry <> -1 then
    begin
      RealEntry[i].SetSumFromTypeEntry(TypeEntry[NumTypeEntry], ValueList);
      RealEntry[i].EntryKey := -1;
      RealEntry[i].EntryDate := aDocumentDate;
      RealEntry[i].DocumentKey := aDocumentKey;
      RealEntry[i].PositionKey := aPositionKey;
    end
    else
    begin
      Result := False;  // Для сформированной операции не найдена типовая
      Break;
    end;
  end;
end;

procedure TPositionTransaction.SetTransactionDate(const Value: TDateTime);
var
  i: Integer;
begin
  FTransactionDate := Value;
  for i:= 0 to RealEntryCount - 1 do
    RealEntry[i].EntryDate := Value; 
end;

function TPositionTransaction.GetSumTransaction: Currency;
var
  i: Integer;
begin
  Result := 0;
  for i:= 0 to RealEntryCount - 1 do
    Result := Result + RealEntry[i].GetDebitSumNCU;
end;

end.
