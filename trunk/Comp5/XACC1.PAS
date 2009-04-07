unit Xacc1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, xAccount, DBTables, Inform;

procedure xSetPeriod(WorkDate: TDateTime; PeriodValue: Integer;
  var FromDate, ToDate: TDateTime);

type
  (* Пособия на детей *)
  TxChildSum = class(TComponent)
  private
    (* Период, за который выбираются *)
    FFromDate, FToDate: TDateTime;
    FChildVed, FChildAcc: TTable;
    FEmplKey: LongInt;

    FChildCat: Integer;

    (* Структура начислений *)
    FxAccountList: TxAccountList;

    procedure SetActive(Value: Boolean);
    procedure SetEmplKey(Value: LongInt);
    procedure SetFromDate(Value: TDateTime);
    procedure SetToDate(Value: TDateTime);

    function GetActive: Boolean;

    function GetChildSum: Double;
    function GetAddSum: Double;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    (* Заполняет xAccountLis по дате зачисления за период (fromDate toDate) *)
    procedure AllChildSum;
    procedure AllAddSum;

    procedure SetRange; 

    property Active: Boolean read GetActive write SetActive;
    property EmplKey: LongInt read FEmplKey write SetEmplKey;
    property FromDate: TDateTime read FFromDate write SetFromDate;
    property ToDate: TDateTime read FToDate write SetToDate;

    property ChildCat: Integer read FChildCat write FChildCat;
    property ChildSum: Double read GetChildSum;
    property AddSum: Double read GetAddSum;

    property xAccountList: TxAccountList read FxAccountList;
  end;

  (* Индексапция пособия на детей *)
type
  TxChildIndSum = class(TComponent)
  private
    (* Период, за который выбираются *)
    FFromDate, FToDate: TDateTime;
    FChildIndVed, FChildIndAcc: TTable;
    FEmplKey: LongInt;

    (* Структура начислений *)
    FxAccountList: TxAccountList;

    procedure SetActive(Value: Boolean);
    procedure SetEmplKey(Value: LongInt);
    procedure SetFromDate(Value: TDateTime);
    procedure SetToDate(Value: TDateTime);

    function GetActive: Boolean;

    function GetChildSum: Double;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetRange;

    (* Заполняет xAccountLis по дате зачисления за период (fromDate toDate)*)
    procedure AllChildSum;

    property Active: Boolean read GetActive write SetActive;
    property EmplKey: LongInt read FEmplKey write SetEmplKey;
    property FromDate: TDateTime read FFromDate write SetFromDate;
    property ToDate: TDateTime read FToDate write SetToDate;

    property ChildSum: Double read GetChildSum;

    property xAccountList: TxAccountList read FxAccountList;
  end;

type
  (* Доплата по итогам работы за период *)
  TxPeriodAPSum = class(TComponent)
  private
    (* Период, за который выбираются *)
    FFromDate, FToDate, FWorkDate: TDateTime;
    FAPVed, FAPYear: TTable;
    FEmplKey: LongInt;

    (* для среденего заработка*)
    FUsePeriod: Boolean;
    FPeriod: Word;

    (* Структура начислений *)
    FxAccountList: TxAccountList;

    procedure SetActive(Value: Boolean);
    procedure SetEmplKey(Value: LongInt);
    procedure SetFromDate(Value: TDateTime);
    procedure SetToDate(Value: TDateTime);

    function GetActive: Boolean;
    function GetPeriodSum: Double;
    function GetSumInMedwage: Double;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetRange;

    (* Заполняет xAccountLis по дате зачисления за период (fromDate toDate)*)
    procedure AllPeriodSum;

    property Active: Boolean read GetActive write SetActive;
    property EmplKey: LongInt read FEmplKey write SetEmplKey;
    property FromDate: TDateTime read FFromDate write SetFromDate;
    property ToDate: TDateTime read FToDate write SetToDate;
    property WorkDate: TDateTime read FWorkDate write FWorkDate;

    property UsePeriod: Boolean read FUsePeriod write FUsePeriod;
    property Period: Word read FPeriod write FPeriod;

    property PeriodSum: Double read GetPeriodSum;
    property SumInMedWage: Double read GetSumInMedwage;

    property xAccountList: TxAccountList read FxAccountList;
  end;

type
  (* За стаж работы по специальности *)
  TxStagSum = class(TComponent)
  private
    (* Период, за который выбираются начисления *)
    FFromDate, FToDate, FWorkDate: TDateTime;
    FStagVed, FStagAcc: TTable;
    FStagCat: Integer;
    FEmplKey: LongInt;

    (* для среденего заработка*)
    FUsePeriod: Boolean;
    FPeriod: Word;

    (* Структура начислений *)
    FxAccountList: TxAccountList;

    procedure SetActive(Value: Boolean);
    procedure SetFromDate(Value: TDateTime);
    procedure SetToDate(Value: TDateTime);

    function GetActive: Boolean;
    function GetPeriodSum: Double;
    function GetSumInMedwage: Double;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetRange;

    (* Заполняет xAccountLis на основании кода категории и указанного периода *)
    procedure AllStagSum;

    property Active: Boolean read GetActive write SetActive;
    property EmplKey: LongInt read FEmplKey write FEmplKey;
    property FromDate: TDateTime read FFromDate write SetFromDate;
    property ToDate: TDateTime read FToDate write SetToDate;
    property WorkDate: TDateTime read FWorkDate write FWorkDate;

    property UsePeriod: Boolean read FUsePeriod write FUsePeriod;
    property Period: Word read FPeriod write FPeriod;

    property StagCat: Integer read FStagCat write FStagCat;
    property StagSum: Double read GetPeriodSum;
    property SumInMedWage: Double read GetSumInMedwage;

    property xAccountList: TxAccountList read FxAccountList;
  end;

type
  (* Доплата по итогам работы за период *)
  TxNatPaySum = class(TComponent)
  private
    (* Период, за который выбираются *)
    FFromDate, FToDate: TDateTime;
    FNatVed, FNatSum: TTable;
    FEmplKey: LongInt;

    (* Структура начислений *)
    FxAccountList: TxAccountList;

    procedure SetActive(Value: Boolean);
    procedure SetEmplKey(Value: LongInt);
    procedure SetFromDate(Value: TDateTime);
    procedure SetToDate(Value: TDateTime);

    function GetActive: Boolean;

    function GetNatPaySum: Double;
    function GetSimpleSum: Double;
    function GetMatHelpSum: Double;
    function GetPresentSum: Double;
    function GetNoIncomeSum: Double;

    procedure NatPaySumByCode(Code: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetRange;

    (* Заполняет xAccountLis за период (fromDate toDate)*)
    procedure AllNatPaySum;
    procedure AllMatHelpSum;
    procedure AllPresentSum;
    procedure AllSimpleSum;
    procedure AllNoIncomeSum;

    property Active: Boolean read GetActive write SetActive;
    property EmplKey: LongInt read FEmplKey write SetEmplKey;
    property FromDate: TDateTime read FFromDate write SetFromDate;
    property ToDate: TDateTime read FToDate write SetToDate;

    property NatPaySum: Double read GetNatPaySum;
    property MathelpSum: Double read GetMathelpSum;
    property PresentSum: Double read GetPresentSum;
    property SimpleSum: Double read GetSimpleSum;
    property NoIncomeSum: Double read GetNoIncomeSum;

    property xAccountList: TxAccountList read FxAccountList;
  end;

type
  (* Квартальная премия *)
  TxDeafAddPaySum = class(TComponent)
  private
    (* Период, за который выбираются *)
    FFromDate, FToDate: TDateTime;
    FDeafAddP, FDeafStaf: TTable;
    FEmplKey: LongInt;

    (* Структура начислений *)
    FxAccountList: TxAccountList;

    procedure SetActive(Value: Boolean);
    procedure SetEmplKey(Value: LongInt);
    procedure SetFromDate(Value: TDateTime);
    procedure SetToDate(Value: TDateTime);

    function GetActive: Boolean;
    function GetAddPaySum: Double;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetRange;

    (* Заполняет xAccountLis за период (fromDate toDate)*)
    procedure AllAddPaySum;

    property Active: Boolean read GetActive write SetActive;
    property EmplKey: LongInt read FEmplKey write SetEmplKey;
    property FromDate: TDateTime read FFromDate write SetFromDate;
    property ToDate: TDateTime read FToDate write SetToDate;

    property AddPaySum: Double read GetAddPaySum;
    property xAccountList: TxAccountList read FxAccountList;
  end;

type
  (* Авансы *)
  TxAvansSum = class(TComponent)
  private
    (* Период, за который выбираются *)
    FFromDate, FToDate: TDateTime;
    FAvVed, FAvansy: TTable;
    FEmplKey: LongInt;

    (* Структура начислений *)
    FxAccountList: TxAccountList;

    procedure SetActive(Value: Boolean);
    procedure SetEmplKey(Value: LongInt);
    procedure SetFromDate(Value: TDateTime);
    procedure SetToDate(Value: TDateTime);

    function GetActive: Boolean;
    function GetAvansSum: Double;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    (* Заполняет xAccountLis за период (fromDate toDate)*)
    procedure AllAvansSum;

    property Active: Boolean read GetActive write SetActive;
    property EmplKey: LongInt read FEmplKey write SetEmplKey;
    property FromDate: TDateTime read FFromDate write SetFromDate;
    property ToDate: TDateTime read FToDate write SetToDate;

    property AvansSum: Double read GetAvansSum;
    property xAccountList: TxAccountList read FxAccountList;
  end;

type
  (* Возврат денег в кассу *)
  TxGiveBackSum = class(TComponent)
  private
    (* Период, за который выбираются *)
    FFromDate, FToDate: TDateTime;
    FGBVed, FGiveBack: TTable;
    FEmplKey: LongInt;

    (* Структура начислений *)
    FxAccountList: TxAccountList;

    procedure SetActive(Value: Boolean);
    procedure SetEmplKey(Value: LongInt);
    procedure SetFromDate(Value: TDateTime);
    procedure SetToDate(Value: TDateTime);

    function GetActive: Boolean;
    function GetGiveBackSum: Double;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    (* Заполняет xAccountLis за период (fromDate toDate)*)
    procedure AllGiveBackSum;

    property Active: Boolean read GetActive write SetActive;
    property EmplKey: LongInt read FEmplKey write SetEmplKey;
    property FromDate: TDateTime read FFromDate write SetFromDate;
    property ToDate: TDateTime read FToDate write SetToDate;

    property GiveBackSum: Double read GetGiveBackSum;
    property xAccountList: TxAccountList read FxAccountList;
  end;

procedure Register;

implementation

{------ Пособия на детей ------}
constructor TxChildSum.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FChildVed := TTable.Create(Self);
  FChildVed.DatabaseName := 'WAGE';
  FChildVed.Name := 'ChildD';
  FChildVed.TableName := 'ChildD';
  FChildVed.IndexFieldNames := 'WorkDate';

  FChildAcc := TTable.Create(Self);
  FChildAcc.DatabaseName := 'WAGE';
  FChildAcc.Name := 'ChildAcc';
  FChildAcc.TableName := 'ChildAcc';
  FChildAcc.IndexFieldNames := 'VedKey;EmplKey;ChildKey';

  FFromDate := Now;
  FToDate := Now;

  FEmplKey := -1;

  FChildCat := 0;

  FxAccountList := TxAccountList.Create;
end;

destructor TxChildSum.Destroy;
begin
  FxAccountList.Free;

  if Assigned(FChildVed) then FChildVed.Free;
  if Assigned(FChildAcc) then FChildAcc.Free;

  inherited Destroy;
end;

function TxChildSum.GetActive: Boolean;
begin
  Result := (FChildVed.Active and FChildAcc.Active);
  FChildVed.SetRange([FFromDate], [FToDate]);
end;

procedure TxChildSum.SetActive(Value: Boolean);
begin
  FChildVed.Active := Value;
  FChildAcc.Active := Value;
end;

procedure TxChildSum.SetEmplKey(Value: LongInt);
begin
  FEmplKey := Value;
end;

procedure TxChildSum.SetFromDate(Value: TDateTime);
begin
  FChildVed.SetRange([Value], [FToDate]);
  FFromDate := Value;
end;

procedure TxChildSum.SetToDate(Value: TDateTime);
begin
  FChildVed.SetRange([FFromDate], [Value]);
  FToDate := Value;
end;

procedure TxChildSum.SetRange;
begin
  FChildVed.SetRange([FFromDate], [FToDate]);
end;

(* Формирует структуру индексации больничных, начисленной за период с FromDate по ToDate *)
procedure TxChildSum.AllChildSum;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FChildVed.First;
  while not FChildVed.EOF do
  begin
    if (FChildVed.FieldByName('CatKey').AsInteger = ChildCat) or (ChildCat = 0) then
    try
      FChildAcc.SetRange(
        [FChildVed.FieldByName('VedKey').AsInteger, FEmplKey],
        [FChildVed.FieldByName('VedKey').AsInteger, FEmplKey]);

      FChildAcc.First;
      while not FChildAcc.EOF do
      begin
        xPayRecord := TxPayRecord.Create;
        xPayRecord.AccDate := FChildVed.FieldByName('WorkDate').AsDateTime;
        xPayRecord.EnlistDate := xPayRecord.AccDate;
        xPayRecord.AccName := FChildVed.FieldByName('VedName').AsString;
        xPayRecord.Sum := FChildAcc.FieldByName('ChildSum').AsFloat;
        FxAccountList.Add(xPayRecord);

        FChildAcc.Next;
      end;
    finally
      FChildAcc.CancelRange;
    end;
    FChildVed.Next;
  end;
end;

function TxChildSum.GetChildSum: Double;
begin
  Result := 0;
  AllChildSum;
  Result := FxAccountList.Sum;
end;

(* Формирует структуру индексации больничных, начисленной за период с FromDate по ToDate *)
procedure TxChildSum.AllAddSum;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FChildVed.First;
  while not FChildVed.EOF do
  begin
    if (FChildVed.FieldByName('CatKey').AsInteger = ChildCat) or (ChildCat = 0) then
    try
      FChildAcc.SetRange(
        [FChildVed.FieldByName('VedKey').AsInteger, FEmplKey],
        [FChildVed.FieldByName('VedKey').AsInteger, FEmplKey]);

      FChildAcc.First;
      while not FChildAcc.EOF do
      begin
        if FChildAcc.FieldByName('AddSum').AsFloat <> 0 then
        begin
          xPayRecord := TxPayRecord.Create;
          xPayRecord.AccDate := FChildVed.FieldByName('WorkDate').AsDateTime;
          xPayRecord.EnlistDate := xPayRecord.AccDate;
          xPayRecord.AccName := 'Дополнительно к пособию';
          xPayRecord.Sum := FChildAcc.FieldByName('AddSum').AsFloat;
          FxAccountList.Add(xPayRecord);
        end;
        FChildAcc.Next;
      end;
    finally
      FChildAcc.CancelRange;
    end;
    FChildVed.Next;
  end;
end;

function TxChildSum.GetAddSum: Double;
begin
  Result := 0;
  AllAddSum;
  Result := FxAccountList.Sum;
end;

{------ Индексация пособий на детей ------}
constructor TxChildIndSum.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FChildIndVed := TTable.Create(Self);
  FChildIndVed.DatabaseName := 'WAGE';
  FChildIndVed.Name := 'IndChild';
  FChildIndVed.TableName := 'IndChild';
  FChildIndVed.IndexFieldNames := 'VedDate;FromDate';

  FChildIndAcc := TTable.Create(Self);
  FChildIndAcc.DatabaseName := 'WAGE';
  FChildIndAcc.Name := 'INDCHILS';
  FChildIndAcc.TableName := 'INDCHILS';
  FChildIndAcc.IndexFieldNames := 'VedKey;Emplkey;ChildKey';

  FFromDate := Now;
  FToDate := Now;

  FEmplKey := -1;

  FxAccountList := TxAccountList.Create;
end;

destructor TxChildIndSum.Destroy;
begin
  FxAccountList.Free;

  if Assigned(FChildIndVed) then FChildIndVed.Free;
  if Assigned(FChildIndAcc) then FChildIndAcc.Free;

  inherited Destroy;
end;

function TxChildIndSum.GetActive: Boolean;
begin
  Result := (FChildIndVed.Active and FChildIndAcc.Active);
  FChildIndVed.SetRange([FFromDate], [FToDate]);
end;

procedure TxChildIndSum.SetActive(Value: Boolean);
begin
  FChildIndVed.Active := Value;
  FChildIndAcc.Active := Value;
end;

procedure TxChildIndSum.SetEmplKey(Value: LongInt);
begin
  FEmplKey := Value;
end;

procedure TxChildIndSum.SetFromDate(Value: TDateTime);
begin
  FChildIndVed.SetRange([Value], [FToDate]);
  FFromDate := Value;
end;

procedure TxChildIndSum.SetToDate(Value: TDateTime);
begin
  FChildIndVed.SetRange([FFromDate], [Value]);
  FToDate := Value;
end;

procedure TxChildIndSum.SetRange;
begin
  FChildIndVed.SetRange([FFromDate], [FToDate]);
end;

(* по всем документам выбираются суммы *)
procedure TxChildIndSum.AllChildSum;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FChildIndVed.First;
  while not FChildIndVed.EOF do
  begin
    try
      FChildIndAcc.SetRange(
        [FChildIndVed.FieldByName('VedKey').AsInteger, FEmplKey],
        [FChildIndVed.FieldByName('VedKey').AsInteger, FEmplKey]);

      FChildIndAcc.First;
      while not FChildIndAcc.EOF do
      begin
        xPayRecord := TxPayRecord.Create;
        xPayRecord.AccDate := FChildIndVed.FieldByName('VedDate').AsDateTime;
        xPayRecord.EnlistDate := FChildIndVed.FieldByName('FromDate').AsDateTime;
        xPayRecord.AccName := FChildIndVed.FieldByName('VedName').AsString;

        xPayRecord.Sum := FChildIndAcc.FieldByName('ChildIndSum').AsFloat;
        FxAccountList.Add(xPayRecord);

        FChildIndAcc.Next;
      end;
    finally
      FChildIndAcc.CancelRange;
    end;
    FChildIndVed.Next;
  end;
end;

function TxChildIndSum.GetChildSum: Double;
begin
  Result := 0;
  AllChildSum;
  Result := FxAccountList.Sum;
end;

{------ Доплаты по итогам работы за период ------}
constructor TxPeriodAPSum.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FAPVed := TTable.Create(Self);
  FAPVed.DatabaseName := 'WAGE';
  FAPVed.Name := 'APVed';
  FAPVed.TableName := 'APVed';
  FAPVed.IndexFieldNames := 'AcDate;FromDate';

  FAPYear := TTable.Create(Self);
  FAPYear.DatabaseName := 'WAGE';
  FAPYear.Name := 'APYear';
  FAPYear.TableName := 'APYear';
  FAPYear.IndexFieldNames := 'ApKey;EmplKey';

  FFromDate := Now;
  FToDate := Now;
  FWorkDate := Now;

  FEmplKey := -1;

  FxAccountList := TxAccountList.Create;

  FUsePeriod := False;
  FPeriod := 1;
end;

destructor TxPeriodAPSum.Destroy;
begin
  FxAccountList.Free;

  if Assigned(FAPVed) then FAPVed.Free;
  if Assigned(FAPYear) then FAPYear.Free;

  inherited Destroy;
end;

function TxPeriodAPSum.GetActive: Boolean;
begin
  Result := (FAPVed.Active and FAPYear.Active);
  FAPVed.SetRange([FFromDate], [FToDate]);
end;

procedure TxPeriodAPSum.SetActive(Value: Boolean);
begin
  FAPVed.Active := Value;
  FAPYear.Active := Value;
end;

procedure TxPeriodAPSum.SetEmplKey(Value: LongInt);
begin
  FEmplKey := Value;
end;

procedure TxPeriodAPSum.SetFromDate(Value: TDateTime);
begin
  FAPVed.SetRange([Value], [FToDate]);
  FFromDate := Value;
end;

procedure TxPeriodAPSum.SetToDate(Value: TDateTime);
begin
  FAPVed.SetRange([FFromDate], [Value]);
  FToDate := Value;
end;

procedure TxPeriodAPSum.SetRange;
begin
  FAPVed.SetRange([FFromDate], [FToDate]);
end;

(* по всем документам выбираются суммы *)
procedure TxPeriodAPSum.AllPeriodSum;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FAPVed.First;
  while not FAPVed.EOF do
  begin
    try
      FAPYear.SetRange(
        [FAPVed.FieldByName('ApKey').AsInteger, FEmplKey],
        [FAPVed.FieldByName('ApKey').AsInteger, FEmplKey]);

      FAPYear.First;
      while not FAPYear.EOF do
      begin
        xPayRecord := TxPayRecord.Create;
        xPayRecord.AccDate := FAPVed.FieldByName('AcDate').AsDateTime;
        xPayRecord.EnlistDate := FAPVed.FieldByName('AcDate').AsDateTime;
        xPayRecord.AccName := FAPVed.FieldByName('VedName').AsString;
        xPayRecord.Sum := FAPYear.FieldByName('APSum').AsFloat;

        FxAccountList.Add(xPayRecord);

        FAPYear.Next;
      end;
    finally
      FAPYear.CancelRange;
    end;
    FAPVed.Next;
  end;
end;

function TxPeriodAPSum.GetPeriodSum: Double;
begin
  Result := 0;
  AllPeriodSum;
  Result := FxAccountList.Sum;
end;

(*  За месяц, соответствующий FromDate выбираются суммы входящий в срдений
  заработок.
  !!!  FromDate должна указывать на на первое число месяца, а ToDate на
  последнее число месяца
*)
function TxPeriodAPSum.GetSumInMedwage: Double;
var
  xFromDate, xToDate: TDateTime;
  S1, S2: String;

begin
  Result := 0;

  (* если не включать частями или период равен 1 месяц, тогда взять всю сумму *)
  if (not FUsePeriod) or (FPeriod = 1) then
    Result := PeriodSum
  else
    if FPeriod in [2, 3, 4, 6, 12] then
    begin
      xSetPeriod(FWorkDate, FPeriod, xFromDate, xToDate);
      FromDate := xFromDate;
      ToDate := xToDate;
      Result := PeriodSum / FPeriod;
    end;
end;

(* разбор периода *)
procedure xSetPeriod(WorkDate: TDateTime; PeriodValue: Integer;
  var FromDate, ToDate: TDateTime);
var
  Year, Month, Day: Word;
  StartMonth, EndMonth: Word;
begin
  DecodeDate(WorkDate, Year, Month, Day);

  if PeriodValue = 12 then
  begin
    Dec(Year);
    FromDate := EncodeDate(Year, 1, 1);
    ToDate := EncodeDate(Year, 12, 31);

    Exit;
  end;

  if Month mod PeriodValue = 0 then
     begin
    StartMonth := PeriodValue * (Month div PeriodValue - 1) + 1;
    EndMonth := Month;
  end else
  begin
    StartMonth := PeriodValue * (Month div PeriodValue) + 1;
    EndMonth := PeriodValue * (Month div PeriodValue + 1);
  end;

  if PeriodValue > StartMonth  then
  begin
    StartMonth := 12 + StartMonth - PeriodValue ;
    FromDate := EncodeDate(Year - 1, StartMonth, 1);
  end else
  begin
    StartMonth := StartMonth - PeriodValue;
    FromDate := EncodeDate(Year, StartMonth, 1);
  end;

  EndMonth := EndMonth - PeriodValue;
  if EndMonth = 0 then
  begin
    EndMonth := 12;
    ToDate := GetLastDate(EncodeDate(Year - 1, EndMonth, 1));
  end
  else
    ToDate := GetLastDate(EncodeDate(Year, EndMonth, 1));
end;

{------ Доплаты за выслугу лет  ------}
constructor TxStagSum.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FStagVed := TTable.Create(Self);
  FStagVed.DatabaseName := 'WAGE';
  FStagVed.Name := 'StagVed';
  FStagVed.TableName := 'StagVed';
  FStagVed.IndexFieldNames := 'AcDate;StagFrom';

  FStagAcc := TTable.Create(Self);
  FStagAcc.DatabaseName := 'WAGE';
  FStagAcc.Name := 'StagAcc';
  FStagAcc.TableName := 'StagAcc';
  FStagAcc.IndexFieldNames := 'StagKey;EmplKey';

  FFromDate := Now;
  FToDate := Now;
  FWorkDate := Now;

  FEmplKey := -1;
  FStagCat := 0;

  FxAccountList := TxAccountList.Create;

  FUsePeriod := False;
  FPeriod := 1;
end;

destructor TxStagSum.Destroy;
begin
  FxAccountList.Free;

  if Assigned(FStagVed) then FStagVed.Free;
  if Assigned(FStagAcc) then FStagAcc.Free;

  inherited Destroy;
end;

function TxStagSum.GetActive: Boolean;
begin
  Result := (FStagVed.Active and FStagAcc.Active);
  FStagVed.SetRange([FFromDate], [FToDate]);
end;

procedure TxStagSum.SetActive(Value: Boolean);
begin
  FStagVed.Active := Value;
  FStagAcc.Active := Value;
end;

procedure TxStagSum.SetFromDate(Value: TDateTime);
begin
  FStagVed.SetRange([Value], [FToDate]);
  FFromDate := Value;
end;

procedure TxStagSum.SetToDate(Value: TDateTime);
begin
  FStagVed.SetRange([FFromDate], [Value]);
  FToDate := Value;
end;

procedure TxStagSum.SetRange;
begin
  FStagVed.SetRange([FFromDate], [FToDate]);
end;

(* по всем документам выбираются суммы *)
procedure TxStagSum.AllStagSum;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FStagVed.First;
  while not FStagVed.EOF do
  begin
    if (FStagCat = 0) or (FStagVed.FieldByName('CatKey').AsInteger = FStagCat) then
    begin
      FStagAcc.SetRange([FStagVed.FieldByName('StagKey').AsInteger, FEmplKey],
          [FStagVed.FieldByName('StagKey').AsInteger, FEmplKey]);
      try
        FStagAcc.First;
        while not FStagAcc.EOF do
        begin
          xPayRecord := TxPayRecord.Create;
          xPayRecord.AccDate := FStagVed.FieldByName('AcDate').AsDateTime;
          xPayRecord.EnlistDate := xPayRecord.AccDate;
          xPayRecord.AccName := FStagVed.FieldByName('VedName').AsString;
          xPayRecord.Sum := FStagAcc.FieldByName('StagSum').AsFloat;

          FxAccountList.Add(xPayRecord);

          FStagAcc.Next;
        end;
      finally
        FStagAcc.CancelRange;
      end;
    end;
    FStagVed.Next;
  end;
end;

function TxStagSum.GetPeriodSum: Double;
begin
  Result := 0;
  AllStagSum;
  Result := FxAccountList.Sum;
end;

(*  За месяц, соответствующий FromDate выбираются суммы входящий в срдений
  заработок.
  !!!  FromDate должна указывать на на первое число месяца, а ToDate на
  последнее число месяца
*)
function TxStagSum.GetSumInMedwage: Double;
var
  xFromDate, xToDate: TDateTime;
  S1, S2: String;

begin
  Result := 0;

  (* если не включать частями или период равен 1 месяц, тогда взять всю сумму *)
  if (not FUsePeriod) or (FPeriod = 1) then
    Result := StagSum
  else
    if FPeriod in [2, 3, 4, 6, 12] then
    begin
      xSetPeriod(FWorkDate, FPeriod, xFromDate, xToDate);
      FromDate := xFromDate;
      ToDate := xToDate;
      Result := StagSum / FPeriod;
    end;
end;

{------ выплаты в натуральной форме ------}
constructor TxNatPaySum.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FNatVed := TTable.Create(Self);
  FNatVed.DatabaseName := 'WAGE';
  FNatVed.Name := 'NatVed';
  FNatVed.TableName := 'NatVed';
  FNatVed.IndexFieldNames := 'VedDate';

  FNatSum := TTable.Create(Self);
  FNatSum.DatabaseName := 'WAGE';
  FNatSum.Name := 'NatSum';
  FNatSum.TableName := 'NatSum';
  FNatSum.IndexFieldNames := 'VedKey;EmplKey';

  FFromDate := Now;
  FToDate := Now;

  FEmplKey := -1;

  FxAccountList := TxAccountList.Create;
end;

destructor TxNatPaySum.Destroy;
begin
  FxAccountList.Free;

  if Assigned(FNatVed) then FNatVed.Free;
  if Assigned(FNatSum) then FNatSum.Free;

  inherited Destroy;
end;

function TxNatPaySum.GetActive: Boolean;
begin
  Result := (FNatVed.Active and FNatSum.Active);
  FNatVed.SetRange([FFromDate], [FToDate]);
end;

procedure TxNatPaySum.SetActive(Value: Boolean);
begin
  FNatVed.Active := Value;
  FNatSum.Active := Value;
end;

procedure TxNatPaySum.SetEmplKey(Value: LongInt);
begin
  FEmplKey := Value;
end;

procedure TxNatPaySum.SetFromDate(Value: TDateTime);
begin
  FNatVed.SetRange([Value], [FToDate]);
  FFromDate := Value;
end;

procedure TxNatPaySum.SetToDate(Value: TDateTime);
begin
  FNatVed.SetRange([FFromDate], [Value]);
  FToDate := Value;
end;

procedure TxNatPaySum.SetRange;
begin
  FNatVed.SetRange([FFromDate], [FToDate]);
end;

procedure TxNatPaySum.NatPaySumByCode(Code: Integer);

procedure Calculate;
var
  xPayRecord: TxPayRecord;
begin
  try
    FNatSum.SetRange(
      [FNatVed.FieldByName('VedKey').AsInteger, FEmplKey],
      [FNatVed.FieldByName('VedKey').AsInteger, FEmplKey]);

    FNatSum.First;
    while not FNatSum.EOF do
    begin
      xPayRecord := TxPayRecord.Create;
      xPayRecord.AccDate := FNatVed.FieldByName('VedDate').AsDateTime;
      xPayRecord.EnlistDate := FNatVed.FieldByName('VedDate').AsDateTime;
      xPayRecord.AccName := FNatVed.FieldByName('VedName').AsString;
      xPayRecord.Sum := FNatSum.FieldByName('NutSum').AsFloat;

      FxAccountList.Add(xPayRecord);

      FNatSum.Next;
    end;
  finally
    FNatSum.CancelRange;
  end;
end;

begin
  FxAccountList.Clear;

  FNatVed.First;
  while not FNatVed.EOF do
  begin
    (* Все натуральные выплаты *)
    if Code = -1 then
      Calculate
    else
      (* Натуральные выплаты по типу *)
      if FNatVed.FieldByName('Sign').AsInteger = Code then
        Calculate;
    FNatVed.Next;
  end;
end;

(* Список всех натуральных выплат *)
procedure TxNatPaySum.AllNatPaySum;
begin
  NatPaySumByCode(-1);
end;

(* Сумма всех натуральных выплат *)
function TxNatPaySum.GetNatPaySum: Double;
begin
  Result := 0;
  AllNatPaySum;
  Result := FxAccountList.Sum;
end;

(* Список обычных выплат *)
procedure TxNatPaySum.AllSimpleSum;
begin
  NatPaySumByCode(1);
end;

(* Сумма всех обычных выплат *)
function TxNatPaySum.GetSimpleSum: Double;
begin
  Result := 0;
  AllSimpleSum;
  Result := FxAccountList.Sum;
end;

(* Список всех материальных помощей *)
procedure TxNatPaySum.AllMatHelpSum;
begin
  NatPaySumByCode(2);
end;

(* Сумма всех материальных помощей *)
function TxNatPaySum.GetMatHelpSum: Double;
begin
  Result := 0;
  AllMatHelpSum;
  Result := FxAccountList.Sum;
end;

(* Список всех подарков *)
procedure TxNatPaySum.AllPresentSum;
begin
  NatPaySumByCode(3);
end;

(* Сумма всех подарков *)
function TxNatPaySum.GetPresentSum: Double;
begin
  Result := 0;
  AllPresentSum;
  Result := FxAccountList.Sum;
end;

(* Список всех необлагаемых *)
procedure TxNatPaySum.AllNoIncomeSum;
begin
  NatPaySumByCode(4);
end;

(* Сумма всех подарков *)
function TxNatPaySum.GetNoIncomeSum: Double;
begin
  Result := 0;
  AllNoIncomeSum;
  Result := FxAccountList.Sum;
end;

{------ Квартальная премия ------}
constructor TxDeafAddPaySum.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FDeafAddP := TTable.Create(Self);
  FDeafAddP.DatabaseName := 'WAGE';
  FDeafAddP.Name := 'DeafAddP';   
  FDeafAddP.TableName := 'DeafAddP';
  FDeafAddP.IndexFieldNames := 'AcDate';

  FDeafStaf := TTable.Create(Self);
  FDeafStaf.DatabaseName := 'WAGE';
  FDeafStaf.Name := 'DeafStaf';
  FDeafStaf.TableName := 'DEAFSTAF';
  FDeafStaf.IndexFieldNames := 'RegKey;EmplKey';

  FFromDate := Now;
  FToDate := Now;

  FEmplKey := -1;

  FxAccountList := TxAccountList.Create;
end;

destructor TxDeafAddPaySum.Destroy;
begin
  FxAccountList.Free;

  if Assigned(FDeafAddP) then FDeafAddP.Free;
  if Assigned(FDeafStaf) then FDeafStaf.Free;

  inherited Destroy;
end;

function TxDeafAddPaySum.GetActive: Boolean;
begin
  Result := (FDeafAddP.Active and FDeafStaf.Active);
  FDeafAddP.SetRange([FFromDate], [FToDate]);
end;

procedure TxDeafAddPaySum.SetActive(Value: Boolean);
begin
  FDeafAddP.Active := Value;
  FDeafStaf.Active := Value;
end;

procedure TxDeafAddPaySum.SetEmplKey(Value: LongInt);
begin
  FEmplKey := Value;
end;

procedure TxDeafAddPaySum.SetFromDate(Value: TDateTime);
begin
  FDeafAddP.SetRange([Value], [FToDate]);
  FFromDate := Value;
end;

procedure TxDeafAddPaySum.SetToDate(Value: TDateTime);
begin
  FDeafAddP.SetRange([FFromDate], [Value]);
  FToDate := Value;
end;

procedure TxDeafAddPaySum.SetRange;
begin
  FDeafAddP.SetRange([FFromDate], [FToDate]);
end;

procedure TxDeafAddPaySum.AllAddPaySum;
var
  S: Double;
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FDeafAddP.First;
  while not FDeafAddP.EOF do
  begin
    try
    FDeafStaf.SetRange(
      [FDeafAddP.FieldByName('RegKey').AsInteger, FEmplKey],
      [FDeafAddP.FieldByName('RegKey').AsInteger, FEmplKey]);

    FDeafStaf.First;
    while not FDeafStaf.EOF do
    begin
      xPayRecord := TxPayRecord.Create;
      xPayRecord.AccDate := FDeafAddP.FieldByName('AcDate').AsDateTime;
      xPayRecord.EnlistDate := FDeafAddP.FieldByName('AcDate').AsDateTime;
      xPayRecord.AccName := FDeafAddP.FieldByName('Name').AsString;

      (* Премия *)
      S := CurrencyRound(FDeafStaf.FieldByName('Salary').AsFloat *
        FDeafStaf.FieldByName('Percent').AsFloat / 100, RoundValue);

      (* За вычетом суммы к уменьшению премии *)
      S := S - CurrencyRound(S * FDeafStaf.FieldByName('Decrease').AsFloat / 100, RoundValue);

      (* за вычетом аванса *)
      S := S - FDeafStaf.FieldByName('Avans').AsFloat;

      xPayRecord.Sum := CurrencyRound(S, RoundValue);

      FxAccountList.Add(xPayRecord);

      FDeafStaf.Next;
    end;
    finally
      FDeafStaf.CancelRange;
    end;
    FDeafAddP.Next;
  end;
end;

(* Сумма всех премий *)
function TxDeafAddPaySum.GetAddPaySum: Double;
begin
  Result := 0;
  AllAddPaySum;
  Result := FxAccountList.Sum;
end;

{------ Авансы ------}
constructor TxAvansSum.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FAvVed := TTable.Create(Self);
  FAvVed.DatabaseName := 'WAGE';
  FAvVed.Name := 'AvVed';
  FAvVed.TableName := 'AvVed';
  FAvVed.IndexFieldNames := 'VedDate;VedNum';

  FAvansy := TTable.Create(Self);
  FAvansy.DatabaseName := 'WAGE';
  FAvansy.Name := 'Avansy';
  FAvansy.TableName := 'Avansy';
  FAvansy.IndexFieldNames := 'Vedkey;EmplKey';

  FFromDate := Now;
  FToDate := Now;

  FEmplKey := -1;

  FxAccountList := TxAccountList.Create;
end;

destructor TxAvansSum.Destroy;
begin
  FxAccountList.Free;

  if Assigned(FAvVed) then FAvVed.Free;
  if Assigned(FAvansy) then FAvansy.Free;

  inherited Destroy;
end;

function TxAvansSum.GetActive: Boolean;
begin
  Result := (FAvVed.Active and FAvansy.Active);
  FAvVed.SetRange([FFromDate], [FToDate]);
end;

procedure TxAvansSum.SetActive(Value: Boolean);
begin
  FAvVed.Active := Value;
  FAvansy.Active := Value;
end;

procedure TxAvansSum.SetEmplKey(Value: LongInt);
begin
  FEmplKey := Value;
end;

procedure TxAvansSum.SetFromDate(Value: TDateTime);
begin
  FAvVed.SetRange([Value], [FToDate]);
  FFromDate := Value;
end;

procedure TxAvansSum.SetToDate(Value: TDateTime);
begin
  FAvVed.SetRange([FFromDate], [Value]);
  FToDate := Value;
end;

procedure TxAvansSum.AllAvansSum;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FAvVed.First;
  while not FAvVed.EOF do
  begin
    FAvansy.SetRange([FAvVed.FieldByName('VedKey').AsInteger, FEmplKey],
      [FAvVed.FieldByName('VedKey').AsInteger, FEmplKey]);
    try
      FAvansy.First;
      while not FAvansy.EOF do
      begin
        xPayRecord := TxPayRecord.Create;
        xPayRecord.AccDate := FAvVed.FieldByName('VedDate').AsDateTime;
        xPayRecord.EnlistDate := FAvVed.FieldByName('VedDate').AsDateTime;
        xPayRecord.AccName := FAvVed.FieldByName('VedName').AsString;
        xPayRecord.Sum := FAvansy.FieldByName('AvSum').AsFloat;

        FxAccountList.Add(xPayRecord);

        FAvansy.Next;
      end;
    finally
      FAvansy.CancelRange;
    end;
    FAvVed.Next;
  end;
end;

(* Сумма всех авансов *)
function TxAvansSum.GetAvansSum: Double;
begin
  Result := 0;
  AllAvansSum;
  Result := FxAccountList.Sum;
end;

{------ Возврат денег в кассу  ------}
constructor TxGiveBackSum.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FGBVed := TTable.Create(Self);
  FGBVed.DatabaseName := 'WAGE';
  FGBVed.Name := 'GBVed';
  FGBVed.TableName := 'GBVed';
  FGBVed.IndexFieldNames := 'VedDate;VedNumber';

  FGiveBack := TTable.Create(Self);
  FGiveBack.DatabaseName := 'WAGE';
  FGiveBack.Name := 'GiveBack';
  FGiveBack.TableName := 'GiveBack';
  FGiveBack.IndexFieldNames := 'Vedkey;EmplKey';

  FFromDate := Now;
  FToDate := Now;

  FEmplKey := -1;

  FxAccountList := TxAccountList.Create;
end;

destructor TxGiveBackSum.Destroy;
begin
  FxAccountList.Free;

  if Assigned(FGBVed) then FGBVed.Free;
  if Assigned(FGiveBack) then FGiveBack.Free;

  inherited Destroy;
end;

function TxGiveBackSum.GetActive: Boolean;
begin
  Result := (FGBVed.Active and FGiveBack.Active);
  FGBVed.SetRange([FFromDate], [FToDate]);
end;

procedure TxGiveBackSum.SetActive(Value: Boolean);
begin
  FGBVed.Active := Value;
  FGiveBack.Active := Value;
end;

procedure TxGiveBackSum.SetEmplKey(Value: LongInt);
begin
  FEmplKey := Value;
end;

procedure TxGiveBackSum.SetFromDate(Value: TDateTime);
begin
  FGBVed.SetRange([Value], [FToDate]);
  FFromDate := Value;
end;

procedure TxGiveBackSum.SetToDate(Value: TDateTime);
begin
  FGBVed.SetRange([FFromDate], [Value]);
  FToDate := Value;
end;

procedure TxGiveBackSum.AllGiveBackSum;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FGBVed.First;
  while not FGBVed.EOF do
  begin
    try
    FGiveBack.SetRange(
      [FGBVed.FieldByName('VedKey').AsInteger, FEmplKey],
      [FGBVed.FieldByName('VedKey').AsInteger, FEmplKey]);

    FGiveBack.First;
    while not FGiveBack.EOF do
    begin
      xPayRecord := TxPayRecord.Create;
      xPayRecord.AccDate := FGBVed.FieldByName('VedDate').AsDateTime;
      xPayRecord.EnlistDate := FGBVed.FieldByName('VedDate').AsDateTime;
      xPayRecord.AccName := FGBVed.FieldByName('VedName').AsString;
      xPayRecord.Sum := FGiveBack.FieldByName('GiveBackSum').AsFloat;

      FxAccountList.Add(xPayRecord);

      FGiveBack.Next;
    end;
    finally
      FGiveBack.CancelRange;
    end;
    FGBVed.Next;
  end;
end;

(* Сумма всех возвратов денег в кассу *)
function TxGiveBackSum.GetGiveBackSum: Double;
begin
  Result := 0;
  AllGiveBackSum;
  Result := FxAccountList.Sum;
end;

procedure Register;
begin
  RegisterComponents('xWage', [TxChildSum]);
  RegisterComponents('xWage', [TxChildIndSum]);
  RegisterComponents('xWage', [TxPeriodAPSum]);
  RegisterComponents('xWage', [TxStagSum]);
  RegisterComponents('xWage', [TxNatPaySum]);
  RegisterComponents('xWage', [TxDeafAddPaySum]);
  RegisterComponents('xWage', [TxAvansSum]);
  RegisterComponents('xWage', [TxGiveBackSum]);
end;

end.
