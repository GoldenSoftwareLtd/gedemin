// ShlTanya, 09.03.2019

{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    acctTransactionDatabase.pas

  Abstract

    Class that holds all
    information concerning transactions and transactions
    in context of documents including scripts.

  Author

    Romanovski Denis (23-11-2001)

  Revisions history

    Initial  23-11-2001  Dennis  Initial version.

--}


unit acctTransactionDatabase;

interface

uses
  Classes, DB, IBSQL, IBDatabase, Contnrs, gdcBaseInterface;

type
  TAcctAccountPart = (apDebit, apCredit, apNone);

  TAcctAnalyticFields = array of String;

type
  TAcctScript = string;


type
  TAcctDatabase = class;
  TAcctTransaction = class;

  //
  //  Список всех типовый бухгалтерских
  //  операций


  TAcctTransactionList = class(TObjectList)
  private
    FDatabase: TAcctDatabase; // База данных операций

    function GetItem(Index: Integer): TAcctTransaction;
    function GetTransactionSQL: TIBSQL;

  protected
    procedure UpdateTransactionSQL(const SingleRecord: Boolean = True);
    procedure Refresh;

    property TransactionSQL: TIBSQL read GetTransactionSQL;

  public
    constructor Create(ADatabase: TAcctDatabase);
    destructor Destroy; override;

    function FindTransaction(TransactionKey: TID): TAcctTransaction;

    property Database: TAcctDatabase read FDatabase;

    property Items[Index: Integer]: TAcctTransaction read GetItem; default;

  end;


  TAcctRecordList = class;


  TAcctTransaction = class(TObject)
  private
    FID: TID; // Идентификатор операции
    FName: String; // Наименование операции

    FTransactionList: TAcctTransactionList; // Список операций
    FRecordList: TAcctRecordList;

    function GetDatabase: TAcctDatabase; // Список проводок

  protected
    procedure Refresh; overload;
    procedure Refresh(Current: TIBXSQLDA); overload;

  public
    constructor Create(ATransactionList: TAcctTransactionList);
    destructor Destroy; override;

    property ID: TID read FID;
    property Name: String read FName;

    property TransactionList: TAcctTransactionList read FTransactionList;
    property RecordList: TAcctRecordList read FRecordList;

    property Database: TAcctDatabase read GetDatabase;

  end;


  TAcctRecord = class;


  TAcctRecordList = class(TObjectList)
  private
    FTransaction: TAcctTransaction; // Операция

    function GetItem(Index: Integer): TAcctRecord;
    function GetDatabase: TAcctDatabase;
    function GetRecordSQL: TIBSQL;

  protected
    procedure UpdateRecordSQL(const SingleRecord: Boolean = True);
    procedure Refresh;

    property RecordSQL: TIBSQL read GetRecordSQL;

  public
    constructor Create(ATransaction: TAcctTransaction);
    destructor Destroy; override;

    function FindRecord(const RecordKey: TID): TAcctRecord;

    property Transaction: TAcctTransaction read FTransaction;

    property Items[Index: Integer]: TAcctRecord read GetItem; default;

    property Database: TAcctDatabase read GetDatabase;

  end;


  TAcctEntryList = class;


  TAcctRecord = class(TObject)
  private
    FID: TID; // Идентификатор проводки
    FDescription: String; // Описание проводки

    FRecordList: TAcctRecordList; // Список проводок
    FEntryList: TAcctEntryList;

    function GetDatabase: TAcctDatabase; // Список позиций проводок

  protected
    procedure Refresh; overload;
    procedure Refresh(Current: TIBXSQLDA); overload;

  public
    constructor Create(ARecordList: TAcctRecordList);
    destructor Destroy; override;

    property ID: TID read FID;
    property Description: String read FDescription;

    property RecordList: TAcctRecordList read FRecordList;
    property EntryList: TAcctEntryList read FEntryList;

    property Database: TAcctDatabase read GetDatabase;

  end;


  TAcctEntry = class;


  TAcctEntryList = class(TObjectList)
  private
    FRecord: TAcctRecord; // Запись

    function GetItem(Index: Integer): TAcctEntry;
    function GetDatabase: TAcctDatabase;
    function GetEntrySQL: TIBSQL;

  protected
    procedure Refresh;
    procedure UpdateEntrySQL(const SingleRecord: Boolean = True);

    property EntrySQL: TIBSQL read GetEntrySQL;

  public
    constructor Create(ARecord: TAcctRecord);
    destructor Destroy; override;

    property AcctRecord: TAcctRecord read FRecord;

    property Items[Index: Integer]: TAcctEntry read GetItem; default;

    property Database: TAcctDatabase read GetDatabase;

  end;


  TAcctEntry = class(TObject)
  private
    FID: TID; // Идентификатор проводки

    FAccountKey: TID; // Ключ счета
    FAccountName: String; // Наименование счета
    FAccountAlias: String; // Код счета

    FAccountPart: TAcctAccountPart; // Часть счета

    FEntryList: TAcctEntryList;

    function GetDatabase: TAcctDatabase; // Список записей в проводке

  protected
    procedure Refresh; overload;
    procedure Refresh(Current: TIBXSQLDA); overload;

  public
    constructor Create(AnEntryList: TAcctEntryList);
    destructor Destroy; override;

    function GetAnalytics: TAcctAnalyticFields;

    property EntryList: TAcctEntryList read FEntryList;

    property ID: TID read FID;

    property AccountKey: TID read FAccountKey;
    property AccountName: String read FAccountName;
    property AccountAlias: String read FAccountAlias;

    property AccountPart: TAcctAccountPart read FAccountPart;

    property Database: TAcctDatabase read GetDatabase;

  end;


  //
  //  Список бухгалтерских операций
  //  в контексте конкретного документа,
  //  включая скрипты определения суммовых
  //  показателей и аналитики


  TAcctDocument = class;


  TAcctDocumentList = class(TObjectList)
  private
    FDatabase: TAcctDatabase; // База данных операций

    function GetItem(Index: Integer): TAcctDocument;
    function GetDocumentSQL: TIBSQL;

  protected
    procedure UpdateDocumentSQL(const SingleRecord: Boolean = True);

    property DocumentSQL: TIBSQL read GetDocumentSQL;

  public
    constructor Create(ADatabase: TAcctDatabase);
    destructor Destroy; override;

    function FindDocument(const DocumentKey: TID): TAcctDocument;

    property Database: TAcctDatabase read FDatabase;

    property Items[Index: Integer]: TAcctDocument read GetItem; default;

  end;


  TAcctDocTransactionList = class;


  TAcctDocument = class(TObject)
  private
    FID: TID; // Идентификатор типового документа
    FName: String; // Наименвоание документа
    FDescription: String; // Описание документа

    FDocumentList: TAcctDocumentList; // Список документов
    FDocTransactionList:
      TAcctDocTransactionList;

    function GetDatabase: TAcctDatabase; // Список операций в контексте документа

  protected
    procedure Refresh; overload;
    procedure Refresh(Current: TIBXSQLDA); overload;

  public
    constructor Create(ADocumentList: TAcctDocumentList);
    destructor Destroy; override;

    property ID: TID read FID;
    property Name: String read FName;
    property Description: String read FDescription;

    property DocumentList: TAcctDocumentList read FDocumentList;
    property DocTransactionList: TAcctDoctransactionList read FDocTransactionList;

    property Database: TAcctDatabase read GetDatabase;

  end;


  TAcctDocTransaction = class;


  TAcctDocTransactionList = class(TObjectList)
  private
    FDocument: TAcctDocument; // Документ

    FBeforeScript, // Скрипт выполняется перед вызовом скриптов операций
    FAfterScript // Скрипт выполняется после вызова скриптов операций
      : TAcctScript;

    function GetItem(Index: Integer): TAcctDocTransaction;
    function GetDatabase: TAcctDatabase;
    function GetTransactionSQL: TIBSQL;

  protected
    procedure UpdateTransactionSQL;
    procedure Refresh;

    property TransactionSQL: TIBSQL read GetTransactionSQL;

  public
    constructor Create(ADocument: TAcctDocument);
    destructor Destroy; override;

    property Document: TAcctDocument read FDocument;

    property BeforeScript: TAcctScript read FBeforeScript;
    property AfterScript: TAcctScript read FAfterScript;

    property Items[Index: Integer]: TAcctDocTransaction read GetItem; default;

    property Database: TAcctDatabase read GetDatabase;

  end;


  TAcctDocRecordList = class;


  TAcctDocTransaction = class(TObject)
  private
    FDocTransactionList: TAcctDocTransactionList; // Список операций документа
    FTransaction: TAcctTransaction; // Операция

    FDocRecordList: TAcctDocRecordList;

    function GetDatabase: TAcctDatabase; // Список проводок  в контексте документа

  protected
    procedure Refresh(Current: TIBXSQLDA); overload;

  public
    constructor Create(ADocTransactionList: TAcctDocTransactionList);
    destructor Destroy; override;

    property DocTransactionList: TAcctDocTransactionList read FDocTransactionList;
    property Transaction: TAcctTransaction read FTransaction;

    property DocRecordList: TAcctDocRecordList read FDocRecordList;

    property Database: TAcctDatabase read GetDatabase;

  end;


  TAcctDocRecord = class;


  TAcctDocRecordList = class(TObjectList)
  private
    FDocTransaction: TAcctDocTransaction; // Операция в контексте документа

    FBeforeScript, // Скрипт выполняется перед вызовом скриптов проводок
    FAfterScript // Скрипт выполняется после вызова скриптов проводок
      : TAcctScript;

    function GetItem(Index: Integer): TAcctDocRecord;
    function GetDatabase: TAcctDatabase;
    function GetRecordSQL: TIBSQL;

  protected
    procedure UpdateRecordSQL;
    procedure Refresh;

    property RecordSQL: TIBSQL read GetRecordSQL; 

  public
    constructor Create(ADocTransaction: TAcctDocTransaction);
    destructor Destroy; override;

    function FindRecord(const RecordKey: TID): TAcctDocRecord;

    property DocTransaction: TAcctDocTransaction read FDocTransaction;

    property BeforeScript: TAcctScript read FBeforeScript;
    property AfterScript: TAcctScript read FAfterScript;

    property Items[Index: Integer]: TAcctDocRecord read GetItem; default;

    property Database: TAcctDatabase read GetDatabase;

  end;


  TAcctDocEntryList = class;


  TAcctDocRecord = class(TObject)
  private
    FRecord: TAcctRecord; // Проводка
    FDocEntryList: TAcctDocEntryList; // Список записей проводки в контексте документа
    FDocRecordList: TAcctDocRecordList;

    function GetDatabase: TAcctDatabase; // Список проводок в контексте документа

  protected
    procedure Refresh;

  public
    constructor Create(ADocRecordList: TAcctDocRecordList);
    destructor Destroy; override;

    property AcctRecord: TAcctRecord read FRecord;

    property DocRecordList: TAcctDocRecordList read FDocRecordList;
    property DocEntryList: TAcctDocEntryList read FDocEntryList;

    property Database: TAcctDatabase read GetDatabase;

  end;


  TAcctDocEntry = class;


  TAcctDocEntryList = class(TObjectList)
  private
    FDocRecord: TAcctDocRecord; // Проводка в контексте документа

    FBeforeScript, // Скрипт выполняется перед вызовом скриптов проводок
    FAfterScript // Скрипт выполняется после вызова скриптов проводок
      : TAcctScript;

    function GetItem(Index: Integer): TAcctDocEntry;

    function GetDatabase: TAcctDatabase;
    function GetEntrySQL: TIBSQL;
    function GetRecordSQL: TIBSQL;

  protected
    procedure UpdateRecordSQL;
    procedure UpdateEntrySQL(const SingleRecord: Boolean = True);

    procedure Refresh;

    property RecordSQL: TIBSQL read GetRecordSQL;
    property EntrySQL: TIBSQL read GetEntrySQL;

  public
    constructor Create(ADocRecord: TAcctDocRecord);
    destructor Destroy; override;

    function FindEntry(const EntryKey: TID): TAcctDocEntry;

    property DocRecord: TAcctDocRecord read FDocRecord;

    property Items[Index: Integer]: TAcctDocEntry read GetItem; default;

    property BeforeScript: TAcctScript read FBeforeScript;
    property AfterScript: TAcctScript read FAfterScript;

    property Database: TAcctDatabase read GetDatabase;

  end;


  TAcctDocEntry = class(TObject)
  private
    FDocEntryList: TAcctDocEntryList; // Список записей проводки в контексте документа

    FEntry: TAcctEntry; // Запись проводки

    FEntryScript: TAcctScript; // Скрипт

    function GetDatabase: TAcctDatabase; // Скрипт создания показателей проводки

  protected
    procedure Refresh; overload;
    procedure Refresh(Current: TIBXSQLDA); overload;

  public
    constructor Create(ADocEntryList: TAcctDocEntryList);
    destructor Destroy; override;

    property DocEntryList: TAcctDocEntryList read FDocEntryList;
    property Entry: TAcctEntry read FEntry;

    property EntryScript: TAcctScript read FEntryScript;

    property Database: TAcctDatabase read GetDatabase;

  end;


  TAcctDatabase = class(TObject)
  private
    FIBBase: TIBBase;

    FTransactionList: TAcctTransactionList;
    FDocumentList: TAcctDocumentList;

    FInternalTransaction: TIBTransaction;

    FTransactionSQL, FRecordSQL, FEntrySQL:
      TIBSQL;  // Запросы к базе данных для типовых операций

    FDocumentSQL, FDocTransactionSQL, FDocRecordSQL, FDocEntrySQL:
      TIBSQL; // Запросы к базе данных настроенных операций

    function GetDatabase: TIBDatabase;
    function GetTransaction: TIBTransaction;

    procedure SetDatabase(const Value: TIBDatabase);
    procedure SetTransaction(const Value: TIBTransaction);

    function UpdateSQL(SQL: TIBSQL): TIBSQL;

    function GetDocEntrySQL: TIBSQL;
    function GetDocRecordSQL: TIBSQL;
    function GetDocTransactionSQL: TIBSQL;
    function GetDocumentSQL: TIBSQL;
    function GetEntrySQL: TIBSQL;
    function GetRecordSQL: TIBSQL;
    function GetTransactionSQL: TIBSQL;

  protected
    property TransactionSQL: TIBSQL read GetTransactionSQL;
    property RecordSQL: TIBSQL read GetRecordSQL;
    property EntrySQL: TIBSQL read GetEntrySQL;

    property DocumentSQL: TIBSQL read GetDocumentSQL;
    property DocTransactionSQL: TIBSQL read GetDocTransactionSQL;
    property DocRecordSQL: TIBSQL read GetDocRecordSQL;
    property DocEntrySQL: TIBSQL read GetDocEntrySQL;

  public
    constructor Create;
    destructor Destroy; override;

    property TransactionList: TAcctTransactionList read FTransactionList;
    property DocumentList: TAcctDocumentList read FDocumentList;

    property Database: TIBDatabase read GetDatabase write SetDatabase;
    property Transaction: TIBTransaction read GetTransaction write SetTransaction;

  end;


implementation

{ TAcctDatabase }

constructor TAcctDatabase.Create;
begin
  FIBBase := TIBBase.Create(Self);

  FTransactionList := TAcctTransactionList.Create(Self);
  FDocumentList := TAcctDocumentList.Create(Self);

  FInternalTransaction := TIBTransaction.Create(nil);
  FInternalTransaction.Params.Text :=
    'read_committed'#13#10'rec_version'#13#10'nowait'#13#10;

  Transaction := FInternalTransaction;

  if gdcBaseManager <> nil then
    Database := gdcBaseManager.Database;

  FTransactionSQL := nil;
  FRecordSQL := nil;
  FEntrySQL := nil;

  FDocumentSQL := nil;
  FDocTransactionSQL := nil;
  FDocRecordSQL := nil;
  FDocEntrySQL := nil;
end;

destructor TAcctDatabase.Destroy;
begin
  FTransactionList.Free;
  FDocumentList.Free;

  FIBBase.Free;
  FInternalTransaction.Free;

  if Assigned(FTransactionSQL) then
    FTransactionSQL.Free;
  if Assigned(FRecordSQL) then
    FRecordSQL.Free;
  if Assigned(FEntrySQL) then
    FEntrySQL.Free;

  if Assigned(FDocumentSQL) then
    FDocumentSQL.Free;
  if Assigned(FDocTransactionSQL) then
    FDocTransactionSQL.Free;
  if Assigned(FDocRecordSQL) then
    FDocRecordSQL.Free;
  if Assigned(FDocEntrySQL) then
    FDocEntrySQL.Free;

  inherited;
end;

function TAcctDatabase.GetDatabase: TIBDatabase;
begin
  Result := FIBBase.Database;
end;

function TAcctDatabase.GetDocEntrySQL: TIBSQL;
begin
  Result := UpdateSQL(FDocEntrySQL);
end;

function TAcctDatabase.GetDocRecordSQL: TIBSQL;
begin
  Result := UpdateSQL(FDocRecordSQL);
end;

function TAcctDatabase.GetDocTransactionSQL: TIBSQL;
begin
  Result := UpdateSQL(FDocTransactionSQL);
end;

function TAcctDatabase.GetDocumentSQL: TIBSQL;
begin
  Result := UpdateSQL(FDocumentSQL);
end;

function TAcctDatabase.GetEntrySQL: TIBSQL;
begin
  Result := UpdateSQL(FEntrySQL);
end;

function TAcctDatabase.GetRecordSQL: TIBSQL;
begin
  Result := UpdateSQL(FRecordSQL);
end;

function TAcctDatabase.GetTransaction: TIBTransaction;
begin
  Result := FIBBase.Transaction;
end;

function TAcctDatabase.GetTransactionSQL: TIBSQL;
begin
  Result := UpdateSQL(FTransactionSQL);
end;

function TAcctDatabase.UpdateSQL(SQL: TIBSQL): TIBSQL;
begin
  if SQL = nil then
    Result := TIBSQL.Create(nil)
  else
    Result := SQL;

  Result.Database := Database;
  Result.Transaction := Transaction;
end;

procedure TAcctDatabase.SetDatabase(const Value: TIBDatabase);
begin
  FIBBase.Database := Value;
end;

procedure TAcctDatabase.SetTransaction(const Value: TIBTransaction);
begin
  FIBBase.Transaction := Value;
end;

{ TAcctTransactionList }

constructor TAcctTransactionList.Create(ADatabase: TAcctDatabase);
begin
  inherited Create(True);

  FDatabase := ADatabase;
end;

destructor TAcctTransactionList.Destroy;
begin
  inherited;
end;

function TAcctTransactionList.FindTransaction(
  TransactionKey: TID): TAcctTransaction;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    if Items[I].ID = TransactionKey then
    begin
      Result := Items[I];
      Break;
    end;

  if not Assigned(Result) then
  begin
    UpdateTransactionSQL(True);

    with TransactionSQL do
    begin
      Close;
      SetTID(ParamByName('id'), TransactionKey);
      ExecQuery;

      if RecordCount > 0 then
      begin
        Result := TAcctTransaction.Create(Self);
        Result.Refresh(Current);
        Add(Result);
      end;
    end;
  end;
end;

function TAcctTransactionList.GetItem(Index: Integer): TAcctTransaction;
begin
  Result := inherited Items[Index] as TAcctTransaction;
end;

function TAcctTransactionList.GetTransactionSQL: TIBSQL;
begin
  Result := Database.TransactionSQL;
end;

procedure TAcctTransactionList.Refresh;
var
  CurrTransaction: TAcctTransaction;
begin
  Clear;
  UpdateTransactionSQL(False);

  with TransactionSQL do
  begin
    Close;
    ExecQuery;

    while not EOF do
    begin
      CurrTransaction := TAcctTransaction.Create(Self);
      CurrTransaction.Refresh(Current);
      Add(CurrTransaction);

      Next;
    end;
  end;
end;

procedure TAcctTransactionList.UpdateTransactionSQL;
var
  S: String;
begin
  if SingleRecord then
    S := 'SELECT * FROM ac_transaction WHERE id = :id'
  else
    S := 'SELECT * FROM ac_transaction';

  if S <> TransactionSQL.SQL.Text then
    TransactionSQL.SQL.Text := S;
end;

{ TAcctTransaction }

constructor TAcctTransaction.Create(
  ATransactionList: TAcctTransactionList);
begin
  FID := -1;
  FName := '';

  FTransactionList := ATransactionList;
  FRecordList := TAcctRecordList.Create(Self);
end;

destructor TAcctTransaction.Destroy;
begin
  FRecordList.Free;

  inherited;
end;

procedure TAcctTransaction.Refresh;
begin
  with FTransactionList do
  begin
    UpdateTransactionSQL(True);

    SetTID(TransactionSQL.ParamByName('id'), ID);
    TransactionSQL.ExecQuery;

    if TransactionSQL.RecordCount > 0 then
      Self.Refresh(TransactionSQL.Current)
    else begin
      FID := -1;
      FName := '';
    end;
  end;
end;

function TAcctTransaction.GetDatabase: TAcctDatabase;
begin
  Result := FTransactionList.Database;
end;

procedure TAcctTransaction.Refresh(Current: TIBXSQLDA);
begin
  FID := GetTID(Current.ByName('id'));
  FName := Current.ByName('name').AsString;

  FRecordList.Refresh;
end;

{ TAcctRecordList }

constructor TAcctRecordList.Create(ATransaction: TAcctTransaction);
begin
  inherited Create(True);
end;

destructor TAcctRecordList.Destroy;
begin
  inherited;
end;

function TAcctRecordList.FindRecord(const RecordKey: TID): TAcctRecord;
var
  I: Integer;
begin
  Result := nil;
  
  for I := 0 to Count - 1 do
    if Items[I].ID = RecordKey then
    begin
      Result := Items[I];
      Break;
    end;

  if not Assigned(Result) then
  begin
    UpdateRecordSQL(True);

    with RecordSQL do
    begin
      Close;
      SetTID(ParamByName('id'), RecordKey);
      ExecQuery;

      if RecordCount > 0 then
      begin
        Result := TAcctRecord.Create(Self);
        Result.Refresh(Current);
        Add(Result);
      end;
    end;
  end;
end;

function TAcctRecordList.GetDatabase: TAcctDatabase;
begin
  Result := FTransaction.Database;
end;

function TAcctRecordList.GetItem(Index: Integer): TAcctRecord;
begin
  Result := inherited Items[Index] as TAcctRecord;
end;

function TAcctRecordList.GetRecordSQL: TIBSQL;
begin
  Result := Database.RecordSQL;
end;

procedure TAcctRecordList.Refresh;
var
  CurrRecord: TAcctRecord;
begin
  UpdateRecordSQL(False);

  Clear;

  with RecordSQL do
  begin
    Close;
    SetTID(ParamByName('TransactionKey'), FTransaction.ID);
    ExecQuery;

    while not EOF do
    begin
      CurrRecord := TAcctRecord.Create(Self);
      CurrRecord.Refresh(Current);
      Add(CurrRecord);

      Next;
    end;
  end;
end;

procedure TAcctRecordList.UpdateRecordSQL(const SingleRecord: Boolean);
var
  S: String;
begin
  if SingleRecord then
    S := 'SELECT * FROM ac_trrecord WHERE id = :id'
  else
    S := 'SELECT * FROM ac_trrecord WHERE transactionkey = :transactionkey';

  if RecordSQL.SQL.Text <> S then
    RecordSQL.SQL.Text := S;
end;

{ TAcctRecord }

constructor TAcctRecord.Create(ARecordList: TAcctRecordList);
begin
  FID := -1;
  FDescription := '';

  FRecordList := ARecordList;
  FEntryList := TAcctEntryList.Create(Self);
end;

destructor TAcctRecord.Destroy;
begin
  FEntryList.Free;

  inherited;
end;

function TAcctRecord.GetDatabase: TAcctDatabase;
begin
  Result := FRecordList.Database;
end;

procedure TAcctRecord.Refresh(Current: TIBXSQLDA);
begin
  FID := GetTID(Current.ByName('id'));
  FDescription := Current.ByName('description').AsString; 
end;

procedure TAcctRecord.Refresh;
begin
  with FRecordList do
  begin
    UpdateRecordSQL(True);

    RecordSQL.Close;
    SetTID(RecordSQL.ParamByName('id'), Self.ID);
    RecordSQL.ExecQuery;

    if RecordSQL.RecordCount > 0 then
      Self.Refresh(RecordSQL.Current)
    else begin
      FID := -1;
      FDescription := '';
    end;
  end;  
end;

{ TAcctEntryList }

constructor TAcctEntryList.Create(ARecord: TAcctRecord);
begin
  inherited Create(True);

  FRecord := ARecord;
end;

destructor TAcctEntryList.Destroy;
begin
  inherited;
end;

function TAcctEntryList.GetDatabase: TAcctDatabase;
begin
  Result := FRecord.Database;
end;

function TAcctEntryList.GetEntrySQL: TIBSQL;
begin
  Result := Database.EntrySQL;
end;

function TAcctEntryList.GetItem(Index: Integer): TAcctEntry;
begin
  Result := inherited Items[Index] as TAcctEntry;
end;

procedure TAcctEntryList.Refresh;
var
  CurrentEntry: TAcctEntry;
begin
  Clear;

  UpdateEntrySQL(False);

  with EntrySQL do
  begin
    while not EOF do
    begin
      CurrentEntry := TAcctEntry.Create(Self);
      CurrentEntry.Refresh(Current);
      Add(CurrentEntry);

      Next;
    end;
  end;
end;

procedure TAcctEntryList.UpdateEntrySQL(const SingleRecord: Boolean);
var
  S: String;
begin
  if SingleRecord then
    S :=
      'SELECT e.*, a.name, a.alias FROM ac_trentry e ' +
      '  JOIN ac_account a on e.accountkey = a.id WHERE e.id = :id'
  else
    S :=
      'SELECT e.*, a.name, a.alias FROM ac_trentry e ' +
      '  JOIN ac_account a on e.accountkey = a.id' +
      'WHERE e.trrecordkey = :trrecordkey';

  if EntrySQL.SQL.Text <> S then
    EntrySQL.SQL.Text := S;
end;

{ TAcctEntry }

constructor TAcctEntry.Create(AnEntryList: TAcctEntryList);
begin
  FID := -1;
  FAccountKey := -1;

  FAccountName := '';
  FAccountAlias := '';

  FAccountPart := apNone;

  FEntryList := AnEntryList; 
end;

destructor TAcctEntry.Destroy;
begin
  inherited;
end;

function TAcctEntry.GetAnalytics: TAcctAnalyticFields;
begin
  SetLength(Result, 0);
end;

procedure TAcctEntry.Refresh;
begin
  with FEntryList do
  begin
    UpdateEntrySQL(True);

    EntrySQL.Close;
    SetTID(EntrySQL.ParamByName('id'), ID);
    EntrySQL.ExecQuery;

    if EntrySQL.RecordCount > 0 then
      Self.Refresh(EntrySQL.Current)
    else begin
      FID := -1;
      FAccountKey := -1;

      FAccountName := '';
      FAccountAlias := '';

      FAccountPart := apNone;
    end;
  end;
end;

function TAcctEntry.GetDatabase: TAcctDatabase;
begin
  Result := FEntryList.Database;
end;

procedure TAcctEntry.Refresh(Current: TIBXSQLDA);
begin
  FID := GetTID(Current.ByName('id'));
  FAccountKey := GetTID(Current.ByName('AccountKey'));

  FAccountName := Current.ByName('name').AsString;
  FAccountAlias := Current.ByName('alias').AsString;

  if Current.ByName('accountpart').AsString = 'D' then
    FAccountPart := apDebit else
  if Current.ByName('accountpart').AsString = 'C' then
    FAccountPart := apCredit;
end;

{ TAcctDocumentList }

constructor TAcctDocumentList.Create(ADatabase: TAcctDatabase);
begin
  inherited Create(True);

  FDatabase := ADatabase;
end;

destructor TAcctDocumentList.Destroy;
begin
  inherited;
end;

function TAcctDocumentList.FindDocument(
  const DocumentKey: TID): TAcctDocument;
var
  I: Integer;
begin
  Result := nil;

  //
  //  Осуществляем поиск документа,
  //  если его не находим - делаем запрос к базе данных
  //  и загружаем его

  for I := 0 to Count - 1 do
    if Items[I].ID = DocumentKey then
    begin
      Result := Items[I];
      Break;
    end;

  if not Assigned(Result) then
  begin
    UpdateDocumentSQL(True);

    with DocumentSQL do
    begin
      Close;
      SetTID(ParamByName('id'), DocumentKey);
      ExecQuery;

      if RecordCount > 0 then
      begin
        Result := TAcctDocument.Create(Self);
        Result.Refresh(Current);
        Add(Result);
      end;
    end;
  end;
end;

function TAcctDocumentList.GetDocumentSQL: TIBSQL;
begin
  Result := Database.DocumentSQL;
end;

function TAcctDocumentList.GetItem(Index: Integer): TAcctDocument;
begin
  Result := inherited Items[Index] as TAcctDocument;
end;

procedure TAcctDocumentList.UpdateDocumentSQL(const SingleRecord: Boolean);
var
  S: String;
begin
  if SingleRecord then
    S := 'SELECT * FROM gd_documenttype WHERE id = :id'
  else
    S := 'SELECT * FROM gd_document WHERE id = :id';

  if DocumentSQL.SQL.Text <> S then
    DocumentSQL.SQl.Text := S;
end;

{ TAcctDocument }

constructor TAcctDocument.Create(ADocumentList: TAcctDocumentList);
begin
  FID := -1;
  FName := '';
  FDescription := '';

  FDocumentList := ADocumentList;
  FDocTransactionList := nil;
end;

destructor TAcctDocument.Destroy;
begin
  inherited;
end;

procedure TAcctDocument.Refresh;
begin
  with FDocumentList do
  begin
    UpdateDocumentSQL(True);

    DocumentSQL.Close;
    SetTID(DocumentSQL.ParamByName('id'), ID);
    DocumentSQL.ExecQuery;

    if DocumentSQL.RecordCount > 0 then
      Self.Refresh(DocumentSQL.Current)
    else begin
      FID := -1;
      FName := '';
      FDescription := '';
    end;
  end;
end;

function TAcctDocument.GetDatabase: TAcctDatabase;
begin
  Result := FDocumentList.Database;
end;

procedure TAcctDocument.Refresh(Current: TIBXSQLDA);
begin
  FID := GetTID(Current.ByName('id'));
  FName := Current.ByName('name').AsString;
  FDescription := Current.ByName('description').AsString;

  // Считываем все типовые операции документа
  FDocTransactionList.Refresh;
end;

{ TAcctDocTransactionList }

constructor TAcctDocTransactionList.Create(ADocument: TAcctDocument);
begin
  inherited Create(True);

  FDocument := ADocument;

  FBeforeScript := '';
  FAfterScript := '';
end;

destructor TAcctDocTransactionList.Destroy;
begin
  inherited;
end;

function TAcctDocTransactionList.GetDatabase: TAcctDatabase;
begin
  Result := FDocument.Database;
end;

function TAcctDocTransactionList.GetItem(
  Index: Integer): TAcctDocTransaction;
begin
  Result := inherited Items[Index] as TAcctDocTransaction;
end;

function TAcctDocTransactionList.GetTransactionSQL: TIBSQL;
begin
  Result := Database.DocTransactionSQL;
end;

procedure TAcctDocTransactionList.Refresh;
var
  CurrTransaction: TAcctDocTransaction;
begin
  UpdateTransactionSQL;

  with TransactionSQL do
  begin
    Close;
    SetTID(ParamByName('ID'), FDocument.ID);
    ExecQuery;

    while not EOF do
    begin
      CurrTransaction := TAcctDocTransaction.Create(Self);
      Add(CurrTransaction);
      CurrTransaction.Refresh(Current);

      Next;
    end;
  end;
end;

procedure TAcctDocTransactionList.UpdateTransactionSQL;
var
  S: String;
begin
  S :=
    'SELECT transactionkey FROM ac_script ' +
    'WHERE documenttypekey = :id ' +
    'GROUP BY transactionkey';

  if TransactionSQL.SQL.Text <> S then
    TransactionSQL.SQl.Text := S;
end;

{ TAcctDocTransaction }

constructor TAcctDocTransaction.Create(
  ADocTransactionList: TAcctDocTransactionList);
begin
  FDocTransactionList := ADocTransactionList;
  FTransaction := nil;
  FDocRecordList := TAcctDocRecordList.Create(Self);
end;

destructor TAcctDocTransaction.Destroy;
begin
  FDocRecordList.Free;

  inherited;
end;

function TAcctDocTransaction.GetDatabase: TAcctDatabase;
begin
  Result := FDocTransactionList.Database;
end;

procedure TAcctDocTransaction.Refresh(Current: TIBXSQLDA);
begin
  FTransaction := Database.TransactionList.FindTransaction(
    GettID(Current.ByName('transactionkey')));

  FDocRecordList.Refresh;
end;

{ TAcctDocRecordList }

constructor TAcctDocRecordList.Create(
  ADocTransaction: TAcctDocTransaction);
begin
  inherited Create(True);

  FDocTransaction := ADocTransaction;

  FBeforeScript := '';
  FAfterScript := '';
end;

destructor TAcctDocRecordList.Destroy;
begin
  inherited;
end;

function TAcctDocRecordList.FindRecord(
  const RecordKey: TID): TAcctDocRecord;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Items[I].AcctRecord.ID = RecordKey then
    begin
      Result := Items[I];
      Exit;
    end;

  Result := nil;  
end;

function TAcctDocRecordList.GetDatabase: TAcctDatabase;
begin
  Result := FDocTransaction.Database;
end;

function TAcctDocRecordList.GetItem(Index: Integer): TAcctDocRecord;
begin
  Result := inherited Items[Index] as TAcctDocRecord;
end;

function TAcctDocRecordList.GetRecordSQL: TIBSQL;
begin
  Result := Database.DocRecordSQL;
end;

procedure TAcctDocRecordList.Refresh;
var
  CurrRecord: TAcctDocRecord;
  I: Integer;
begin
  UpdateRecordSQL;
  Clear;

  with RecordSQL do
  begin
    Close;
    SetTID(ParamByName('transactionkey'), FDocTransaction.Transaction.ID);
    ExecQuery;

    while not EOF do
    begin
      if Current.ByName('kind').AsString = 'B' then
        FBeforeScript := Current.ByName('script').AsString else

      if Current.ByName('kind').AsString = 'A' then
        FAfterScript := Current.ByName('script').AsString;

      Next;
    end;
  end;

  with FDocTransaction.Transaction do
    for I := 0 to RecordList.Count - 1 do
    begin
      CurrRecord := TAcctDocRecord.Create(Self);
      CurrRecord.FRecord := RecordList[I];
      Add(CurrRecord);
      CurrRecord.Refresh;
    end;
end;

procedure TAcctDocRecordList.UpdateRecordSQL;
var
  S: String;
begin
  S :=
    'SELECT * FROM ac_script WHERE ' +
    'transactionkey = :transactionkey AND trrecordkey IS NULL AND ' +
    'trentrykey IS NULL AND kind in (''B'', ''A'') ORDER BY trrecordkey, kind';

  if RecordSQL.SQL.Text <> S then
    RecordSQL.SQL.Text := S;
end;

{ TAcctDocRecord }

constructor TAcctDocRecord.Create(ADocRecordList: TAcctDocRecordList);
begin
  FDocRecordList := ADocRecordList;
  FDocEntryList := TAcctDocEntryList.Create(Self);
  FRecord := nil;
end;

destructor TAcctDocRecord.Destroy;
begin
  FDocEntryList.Free;

  inherited;
end;

function TAcctDocRecord.GetDatabase: TAcctDatabase;
begin
  Result := FDocRecordList.Database;
end;

procedure TAcctDocRecord.Refresh;
begin
  FDocEntryList.Refresh;
end;

{ TAcctDocEntryList }

constructor TAcctDocEntryList.Create(ADocRecord: TAcctDocRecord);
begin
  inherited Create(True);

  FDocRecord := ADocRecord;

  FBeforeScript := '';
  FAfterScript := '';
end;

destructor TAcctDocEntryList.Destroy;
begin
  inherited;
end;

function TAcctDocEntryList.FindEntry(
  const EntryKey: TID): TAcctDocEntry;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Items[I].Entry.ID = EntryKey then
    begin
      Result := Items[I];
      Exit;
    end;

  Result := nil;  
end;

function TAcctDocEntryList.GetDatabase: TAcctDatabase;
begin
  Result := FDocRecord.Database;
end;

function TAcctDocEntryList.GetEntrySQL: TIBSQL;
begin
  Result := Database.DocEntrySQL;
end;

function TAcctDocEntryList.GetItem(Index: Integer): TAcctDocEntry;
begin
  Result := inherited Items[Index] as TAcctDocEntry;
end;

function TAcctDocEntryList.GetRecordSQL: TIBSQL;
begin
  Result := Database.DocRecordSQL;
end;

procedure TAcctDocEntryList.Refresh;
var
  I: Integer;
  CurrEntry: TAcctDocEntry;
begin
  UpdateRecordSQL;

  with RecordSQL do
  begin
    Close;
    SetTID(ParamByName('trrecordkey'), FDocRecord.AcctRecord.ID);
    ExecQuery;

    while not EOF do
    begin
      if Current.ByName('kind').AsString = 'B' then
        FBeforeScript := Current.ByName('script').AsString else

      if Current.ByName('kind').AsString = 'A' then
        FAfterScript := Current.ByName('script').AsString;

      Next;
    end;
  end;

  UpdateEntrySQL(False);

  Clear;

  with FDocRecord.AcctRecord do
    for I := 0 to EntryList.Count - 1 do
    begin
      CurrEntry := TAcctDocEntry.Create(Self);
      CurrEntry.FEntry := EntryList.Items[I];
    end;

  with EntrySQL do
  begin
    Close;
    SetTID(ParamByName('recordkey'), FDocRecord.AcctRecord.ID);
    ExecQuery;

    while not EOF do
    begin
      CurrEntry := FindEntry(GetTID(Current.ByName('trentrykey')));
      CurrEntry.Refresh(Current);

      Next;
    end;
  end;
end;

procedure TAcctDocEntryList.UpdateEntrySQL(const SingleRecord: Boolean = True);
var
  S: String;
begin
  if SingleRecord then
    S :=
      'SELECT * FROM ac_script WHERE trentrykey = :entrykey AND ' +
      'kind = ''E'' '
  else
    S :=
      'SELECT * FROM ac_script WHERE trrecordkey = :recordkey AND ' +
      'kind = ''E'' ORDER BY trrecordkey ';

  if EntrySQL.SQL.Text <> S then
    EntrySQL.SQL.Text := S;
end;

procedure TAcctDocEntryList.UpdateRecordSQL;
var
  S: String;
begin
  S :=
    'SELECT * FROM ac_script WHERE trrecordkey = :trrecordkey AND ' +
    'trentrykey IS NULL AND kind in (''B'', ''A'') ORDER BY trrecordkey, kind';

  if RecordSQL.SQL.Text <> S then
    RecordSQL.SQL.Text := S;
end;

{ TAcctDocEntry }

constructor TAcctDocEntry.Create(ADocEntryList: TAcctDocEntryList);
begin
  FDocEntryList := ADocEntryList;

  FEntry := nil;
  FEntryScript := '';
end;

destructor TAcctDocEntry.Destroy;
begin
  inherited;
end;

procedure TAcctDocEntry.Refresh;
begin
  with DocEntryList, EntrySQL do
  begin
    UpdateEntrySQL(True);

    Close;
    SetTID(ParamByName('entrykey'), Entry.ID);
    ExecQuery;

    if RecordCount > 0 then
      Self.Refresh(Current);
  end;
end;

function TAcctDocEntry.GetDatabase: TAcctDatabase;
begin
  Result := FDocEntryList.Database;
end;

procedure TAcctDocEntry.Refresh(Current: TIBXSQLDA);
begin
  FEntryScript := Current.ByName('script').AsString;
end;

end.

