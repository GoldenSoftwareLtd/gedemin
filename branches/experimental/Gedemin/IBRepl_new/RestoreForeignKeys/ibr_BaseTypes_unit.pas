unit ibr_BaseTypes_unit;

interface

uses IBDataBase, IBSQL, ibr_const, Classes, IBCustomDataSet, db, contnrs, Forms, Windows,
  SysUtils, IBHeader, ZLib, dialogs ,ibr_GlobalVars_unit;

const
  DataNoPassed = -1;
  DataPassed = 0;
  DataCommited = 1;

type
  TRUIDType = (rtNone, rtInteger, rtString, rtFloat, rtDateTime);

  TReplType = Char;
  //Тип ключа, используемый базой
  TPrimeKeyType =
    (ptNatural, //Натуральный, т.е. уникально изентифицирующий кортеж во всех базах
    ptUniqueInDb, //Уникальный для данной базы
    ptUniqueInRelation);  //Уникальный для таблицы

  TDBState = (dbsMain, dbsSecondary);
  //Информация о базе
  PDBInfo = ^TDBInfo;
  TDBInfo = record
    DBState: TDBState;  //статус базы
    Schema: Integer; //Номер схемы репликации
    ErrorDecision: TErrorDecision; //Метод разрешения конфликтных ситуаций

    Loaded: Boolean; //Информация прочитана из базы
    DBID: Integer;  //Ид базы данных
    PrimeKeyType: TPrimeKeyType;
    GeneratorName: string;
    KeyDivider: string;
  end;


  PRUID = ^TRUID;
  TRUID = record
    XID: Integer;
    DBID: Integer;
    case PrimeKeyType: TPrimeKeyType of
      ptUniqueInRelation: (RelationID: Integer);
  end;

  //Хранит соответствие РУИДов на главной и второстепенной базе
  //Необходим для разрешения конфликтов
  PRUIDConformity = ^TRUIDConformity;
  TRUIDConformity = record
    RUID: TRUID;
    ConfRUID: TRUID;
    ReplID: Integer; //Ключ файла реплики, при обработке которого было найдено данное
                     //сопоставление. Необходимо использовать во время удаления из списка
                     //найденных сопоставлений
  end;

  //Тип репликации
  TReplDirection = (
    rdDual,           //Двунаправленная репликация
    rdFromServer,     //Однонаправленная, от сервера к второстепенным базам
    rdToServer);      //Однонаправленная, от второстепенных баз к серверу

  TReplDataBase = class;
  TrpRelation = class;

  PrpUniqueIndexValue = ^TrpUniqueIndexValue;
  TrpUniqueIndexValue = record
    Value: string;
    Action: TReplType;
  end;

  PReplLogRecord = ^TReplLogRecord;
  TReplLogRecord = record
    Seqno: Integer;
    RelationKey: Integer;
    ReplType: TReplType;
    OldKey: String;
    NewKey: String;
    ActionTime: TDateTime;

    NeedDelete: Boolean;
  end;

  PReplicationDB = ^TReplicationDB;
  TReplicationDB = record
    DBKey: Integer;
    DBState: TDBState;
    DBName: String;
    Priority: Integer;
    ReplKey: Integer;
    ReplData: TDateTime;
    LastProcessReplKey: Integer;
    LastProcessReplData: TDateTime;
    //Используется только во время подготовки к репликации
    //все остальное время равна пустой ктроке
    DBPath: string;
  end;

//  TrpCortegeState = (csNone, csSelect, csInsert, csUpdate, csDelete,
//    csSaveToStream, csLoadFromSream, csLoaded, csSelected);
  TrpCortegeStates = set of (csNone, csSelect, csInsert, csUpdate, csDelete,
    csSaveToStream, csLoadFromSream, csLoaded, csSelected);

  //Способ сжатия потока
  TStreamPackType = (
    sptNormal, //без сжатия
    sptMinZip,  //минимальное сжатие
    sptNormalZip,  //обычное сжатие
    sptMaximalZip  //Максимальное сжатие
    );

  //Хранит информацию о потоке данных
  TStreamInfo = record
    StreamLabel: array[0..10] of Char;
    Version: Integer;
    PackType: TStreamPackType;
  end;

  PIDIndex = ^TIDIndex;
  PRUIDIndex = ^TRUIDIndex;
  TIDIndex = record
    Id: Integer;
    RelationKey: Integer;
    RUIDIndex: PRUIDIndex;
  end;

  TRUIDIndex = record
    RUID: TRUID;
    IDIndex: PIDIndex;
  end;  
    
  TrpErrorEvent = procedure (SQL:TIBSQL; E: Exception; var DataAction: 
          TDataAction) of object;
  TSortedList = class (TList)
  private
    FOwnObjects: Boolean;
    FSortCompare: TListSortCompare;
    FSorted: Boolean;
    procedure SetOwnObjects(const Value: Boolean);
  protected
    procedure GetSortCompare; virtual; abstract;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    constructor Create;
    function IndexOf(Item: Pointer): Integer;
    procedure Sort; overload;
    property OwnObjects: Boolean read FOwnObjects write SetOwnObjects;
  end;
  
  TrpField = class (TObject)
  private
    FConformity: Boolean;
    FFieldIndex: Integer;
    FFieldName: string;
    FFieldSubType: Integer;
    FFieldType: Integer;
    FForeignFields: TList;
    FIsPrimeKey: Boolean;
    FReferenceField: TrpField;
    FRelation: TrpRelation;
    FUnique: Boolean;
    function GetFieldIndex: Integer;
    function GetForeignFieldCount: Integer;
    function GetForeignFields(Index: Integer): TrpField;
    function GetIsForeign: Boolean;
    procedure SetFieldIndex(const Value: Integer);
    procedure SetFieldName(const Value: string);
    procedure SetFieldSubType(const Value: Integer);
    procedure SetFieldType(const Value: Integer);
    procedure SetReferenceField(const Value: TrpField);
    procedure SetRelation(const Value: TrpRelation);
  protected
    procedure SetConformity(const Value: Boolean); virtual;
    procedure SetIsPrimeKey(const Value: Boolean); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure InitIndices(SQL: TIBSQL);
    property Conformity: Boolean read FConformity write SetConformity;
    property FieldIndex: Integer read GetFieldIndex write SetFieldIndex;
    property FieldName: string read FFieldName write SetFieldName;
    property FieldSubType: Integer read FFieldSubType write SetFieldSubType;
    property FieldType: Integer read FFieldType write SetFieldType;
    property ForeignFieldCount: Integer read GetForeignFieldCount;
    property ForeignFields[Index: Integer]: TrpField read GetForeignFields;
    property IsForeign: Boolean read GetIsForeign;
    property IsPrimeKey: Boolean read FIsPrimeKey write SetIsPrimeKey;
    property ReferenceField: TrpField read FReferenceField write
            SetReferenceField;
    property Relation: TrpRelation read FRelation write SetRelation;
    property Unique: Boolean read FUnique;
  end;

  TrpFields = class (TSortedList)
  private
    function GetFields(Index: Integer): TrpField;
  protected
    FField: TrpField;
    procedure GetSortCompare; override;
  public
    destructor Destroy; override;
    function IndexOfField(FieldName: string): Integer;
    property Fields[Index: Integer]: TrpField read GetFields; default;
  end;

  //Список уникальных индексов
  //Список таблиц, участвующих в репликации
  TrpRelation = class (TObject)
  private
    FDataBase: TReplDataBase;
    FFieldIndicesInited: Boolean;
    FGeneratorName: string;
    FIBSQL: TIBSQL;
    FJuxtaPosition: TrpFields;
    FJuxtaPositionSQL: TStrings;
    FRelationKey: Integer;
    FRelationName: string;
    FRelationLocalName: string;
    procedure CheckSQL;
    function GetFields: TrpFields;
    function GetJuxtaPosition: TrpFields;
    function GetJuxtaPositionSQL: TStrings;
    function GetKeys: TrpFields;
    procedure SetDataBase(const Value: TReplDataBase);
    procedure SetDeleteSQL(const Value: TStrings);
    procedure SetGeneratorName(const Value: string);
    procedure SetInsertSQL(const Value: TStrings);
    procedure SetJuxtaPositionSQL(const Value: TStrings);
    procedure SetModifySQL(const Value: TStrings);
    procedure SetRelationKey(const Value: Integer);
    procedure SetRelationName(const Value: string);
    procedure SetRelationLocalName(const Value: string);
    procedure SetSelectSQL(const Value: TStrings);
  protected
    FDeleteSQL: TStrings;
    FFields: TrpFields;
    FInsertSQL: TStrings;
    FKeys: TrpFields;
    FLoaded: Boolean;
    FModifySQL: TStrings;
    FSelectSQL: TStrings;
    FNeedSaveRUIDFields: TrpFields;
    procedure CheckLoaded; virtual;
    function GetDeleteSQL: TStrings; virtual;
    function GetInsertSQL: TStrings; virtual;
    function GetModifySQL: TStrings; virtual;
    function GetSelectSQL: TStrings; virtual;
    function IBSQL: TIBSQL;
    function Loaded: Boolean; virtual;
  public
    destructor Destroy; override;
    procedure InitFieldIndices;
    procedure Load;
    function NeedSaveRUID(F: TrpField): Boolean;

    property DataBase: TReplDataBase read FDataBase write SetDataBase;
    property DeleteSQL: TStrings read GetDeleteSQL write SetDeleteSQL;
    property Fields: TrpFields read GetFields;
    property GeneratorName: string read FGeneratorName write SetGeneratorName;
    property InsertSQL: TStrings read GetInsertSQL write SetInsertSQL;
    property JuxtaPosition: TrpFields read GetJuxtaPosition;
    property JuxtaPositionSQL: TStrings read GetJuxtaPositionSQL write
            SetJuxtaPositionSQL;
    property Keys: TrpFields read GetKeys;
    property ModifySQL: TStrings read GetModifySQL write SetModifySQL;
    property RelationKey: Integer read FRelationKey write SetRelationKey;
    property RelationName: string read FRelationName write SetRelationName;
    property RelationLocalName: string read FRelationLocalName write SetRelationLocalName;
    property SelectSQL: TStrings read GetSelectSQL write SetSelectSQL;
  end;

  TrpRelations = class (TSortedList)
  private
    FDataBase: TReplDataBase;
    FrpRelation: TrpRelation;
    function GetCount: Integer;
    function GetRelations(Key: Integer): TrpRelation;
    procedure SetDataBase(const Value: TReplDataBase);
  protected
    FLoaded: Boolean;
    procedure CheckLoaded; virtual;
    procedure GetSortCompare; override;
  public
    destructor Destroy; override;
    function IndexOfRelation(RelationKey: Integer): Integer;
    function KeyByName(RelationName: string): Integer;
    property Count: Integer read GetCount;
    property DataBase: TReplDataBase read FDataBase write SetDataBase;
    property Relations[Key: Integer]: TrpRelation read GetRelations; default;
  end;
  
  //класс менаджера руидов для баз у которых ид уникально в пределах базы
  TReplicationDBList = class (TList)
  private
    function GetCount: Integer;
    function GetItems(DBKey: Integer): TReplicationDB;
    function GetItemsByIndex(Index: Integer): TReplicationDB;
  protected
    FLoaded: Boolean;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    function IndexByDBName(Name: string): Integer;
    function IndexOfDb(DBKey: Integer): Integer;
    procedure LoadAll; virtual;
    property Count: Integer read GetCount;
    property ItemsByIndex[Index: Integer]: TReplicationDB read GetItemsByIndex;
    property ItemsByKey[DBKey: Integer]: TReplicationDB read GetItems; default;
  end;
  
  IConnectChangeNotify = interface (IInterface)
    ['{A6ADAA75-CAC3-4EE0-8A92-8CDF2D009439}']
    procedure DoAfterConnectionLost;
    procedure DoAfterSuccessfullConnection;
    procedure DoBeforeDisconnect;
  end;
  
  //Хранит связку номера изменения и индекса в журнале изменений
  TReplDataBase = class (TIBDataBase)
  private
    FConnectNotifyList: TList;
    FDataBaseInfo: TDBInfo;
    FFileName: string;
    FIsPrepared: Boolean;
    FPreserve: Boolean;
    FProtocol: string;
    FReadSQL: TIBSQL;
    FReadTransaction: TIBTransaction;
    FRelations: TrpRelations;
    FReplicationDBList: TReplicationDBList;
    FSchemaChecked: Boolean;
    FSeqNo: TIBSQL;
    FServerName: string;
    FTransaction: TIBTransaction;
    procedure CheckReadSQL;
    procedure CheckReadTransaction;
    procedure CheckReadTransactionInTransaction;
    procedure CheckReplicationDbList;
    procedure CheckTransaction;
    function GetDBInfo: TDBInfo;
    function GetDBList: TReplicationDBList;
    function GetDBName: TIBFileName;
    function GetLastProcessReplKey(DBKey: Integer): Integer;
    function GetReadTransaction: TIBTransaction;
    function GetRelations: TrpRelations;
    function GetTransaction: TIBTransaction;
    procedure SetDatabaseName(const Value: TIBFileName);
    procedure SetFileName(const Value: string);
    procedure SetLastProcessReplKey(DBKey: Integer; ReplKey: Integer);
    procedure SetPreserve(const Value: Boolean);
    procedure SetProtocol(const Value: string);
    procedure SetServerName(const Value: string);
    function GetServerName: string;
  protected
    procedure DoConnect; override;
    procedure DoDisconnect; override;
  public
    destructor Destroy; override;
    procedure AddConnectNotify(Notify: IConnectChangeNotify);
    function CanRepl(ADBID: Integer): Boolean;
    function CheckReplicationSchema: Boolean;
    function CountChanges(ADBID: Integer): Integer;
    function DBPriority(DBKey: Integer): Integer;
    function DomaneExist(Domane: TDomane): Boolean;
    function ExceptionExist(Exception: TExcept): Boolean;
    function GenDBID: Integer;
    function GeneratorExist(Generator: TGenerator): Boolean;
    procedure GetDbReport(const S: TStrings); overload;
    procedure GetDbReport(const S: TStrings; DBKey: Integer); overload;
    procedure GetGeneratorList(const GeneratorList: TStrings);
    procedure IncReplKey(DBKey: Integer);
    function NextSeqNo: Integer;
    function NotCommitedTransaction(ADBID: Integer): Integer;
    function ConflictCount(DBKey: Integer): Integer;
    procedure RemoveConnectNotify(Notify: IConnectChangeNotify);
    function ReplicationDBCount: Integer;
    function ReplKey(DbKey: Integer): Integer;
    function TableExist(Table: TTable): Boolean;
    property DataBaseInfo: TDBInfo read GetDBInfo;
    property DBList: TReplicationDBList read GetDBList;
    property FileName: string read FFileName write SetFileName;
    property LastProcessReplKey[DBKey: Integer]: Integer read
            GetLastProcessReplKey write SetLastProcessReplKey;
    property Preserve: Boolean read FPreserve write SetPreserve;
    property Protocol: string read FProtocol write SetProtocol;
    property ReadTransaction: TIBTransaction read GetReadTransaction;
    property Relations: TrpRelations read GetRelations;
    property ServerName: string read GetServerName write SetServerName;
    property Transaction: TIBTransaction read GetTransaction;
    procedure SetReplKey(DBKey: Integer; ReplKey: Integer);
  published
    property DatabaseName: TIBFileName read GetDBName write SetDatabaseName;
  end;

  //Обект хранит данные поля
const
  //Метка потока
  StreamLabel: array[0..9] of Char = ('R', 'e', 'p', 'l', 'i', 'c', 'a', 't', 'o', 'r');

function ReplDataBase: TReplDataBase;
//сохраняет строку в поток
procedure SaveStringToStream(Str: String; Stream: TStream);
//читает строку из потока
function ReadStringFromStream(Stream: TStream): string;
//сохраняет РУИД в поток
procedure SaveRUIDToStream(const RUID: TRUID;
  const Stream: TStream);
//Читает РУИД из потока
procedure ReadRUIDFromStream(var RUID: TRUID;
  const Stream: TStream);

function RUID(XID, DBID, RelationId: Integer): TRUID;

procedure ShowInfoMessage(Message, Caption: string); overload;
procedure ShowInfoMessage(Message: string); overload;

procedure ShowErrorMessage(Message, Caption: string); overload;
procedure ShowErrorMessage(Message: string); overload;

function AskQuestion(Message, Caption: string): Boolean; overload;
function AskQuestion(Message: string): Boolean; overload;
function GetNewDBID: Integer;

function GetDataBaseName(Server, Path, Protocol: string): string;

procedure OriginNames(Origin: string; out TableName: string;
  out FieldName: string);
function FieldTypeStr(FieldType: Integer): string;
function FieldSubTypeStr(FieldType, FieldSubType: Integer): string;
function ShiftString(S: string; C: Integer): string;
procedure ReadComandLineLoginParams(CommandLines: TStrings);
function CommandString: TStrings;
function CompareAnyString(S1: String; S2: array of String): Boolean;

implementation

uses Variants;
var
  _ReplDataBase: TReplDataBase;
  _CommandString: TStrings;
{$IFDEF DEBUG}
const
  cLb =123456;
{$ENDIF}
function CompareAnyString(S1: String; S2: array of String): Boolean;
var
  S: String;
  I: Integer;
begin
  for I := Low(S2) to High(S2) do
  begin
    S := S2[I];
    if AnsiCompareText(S1, S) = 0 then
    begin
      Result := True;
      Exit;
    end;
  end;

  Result := False;
end;

function ReplDataBase: TReplDataBase;
begin
  if _ReplDataBase = nil then
    _ReplDataBase := TReplDataBase.Create(nil);

 Result := _ReplDataBase;
end;

function CommandString: TStrings;
begin
  if _CommandString = nil then
  begin
    _CommandString := TStringList.Create;
    ReadComandLineLoginParams(_CommandString);
  end;
  Result := _CommandString
end;

function GetNewDBID: Integer;
var
  D: Double;
begin
  //Данный алгоритм взят из Gedemina( unit gd_security_body)
  D := Abs(Now - EncodeDate(2002, 08, 25));
  while D > 10 * 365 do
    D := D / (10 * 365);
  Result := Round(D * 24 * 60 * 60 * 6.8) + 2000;
end;

function GetDataBaseName(Server, Path, Protocol: string): string;
begin
  Result := '';
  if Protocol = prTCP then
    Result := Server + ':' + Path
  else if Protocol = prNetBEUI then
    Result := '\\' + Server + '\' + Path
  else if Protocol = prSPX  then
    Result := Server + '@' + Path
  else if Protocol = prLocal  then
    Result := Path
  else
    raise Exception.Create(InvalidProtocol);
end;

procedure SaveStringToStream(Str: String; Stream: TStream);
var
  L: Integer;
begin
  L := Length(Str);
  Stream.WriteBuffer(L, SizeOf(L));
  Stream.WriteBuffer(Str[1], L);
end;

function ReadStringFromStream(Stream: TStream): string;
var
  L: Integer;
begin
  Stream.ReadBuffer(L, SizeOf(L));
  if L > 0 then
  begin
    SetLength(Result, L);
    Stream.ReadBuffer(Result[1], L);
  end else
    Result := '';
end;

procedure SaveRUIDToStream(const RUID: TRUID;
  const Stream: TStream);
begin
  {Записываем в поток РУИД записи}
  Stream.WriteBuffer(RUID.XID, SizeOF(RUID.XID));
  Stream.WriteBuffer(RUID.DBID, SizeOf(RUID.DBID));
end;

procedure ReadRUIDFromStream(var RUID: TRUID;
  const Stream: TStream);
begin
  {Записываем в поток РУИД записи}
  Stream.ReadBuffer(RUID.XID, SizeOF(RUID.XID));
  Stream.ReadBuffer(RUID.DBID, SizeOf(RUID.DBID));
end;

function RUID(XID, DBID, RelationId: Integer): TRUID;
begin
  Result.XID := XID;
  Result.DBID := DBID;
  Result.RelationID := RelationID;
end;

procedure ShowInfoMessage(Message, Caption: string);
begin
  Application.NormalizeTopMosts;
  Application.MessageBox(PChar(Message), PChar(Caption),
    MB_OK + MB_ICONINFORMATION + MB_APPLMODAL);
  Application.RestoreTopMosts;
end;

procedure ShowInfoMessage(Message: string);
begin
  ShowInfoMessage(Message, Application.MainForm.Caption);
end;

procedure ShowErrorMessage(Message, Caption: string); overload;
begin
  Application.NormalizeTopMosts;
  Application.MessageBox(PChar(Message), PChar(Caption),
    MB_OK + MB_ICONERROR + MB_APPLMODAL);
  Application.RestoreTopMosts;
end;

procedure ShowErrorMessage(Message: string); overload;
begin
  ShowErrorMessage(Message, Application.MainForm.Caption);
end;

function AskQuestion(Message, Caption: string): Boolean;
begin
  Application.NormalizeTopMosts;
  Result := MessageBox(Application.Handle, PChar(Message),
    PChar(Caption), MB_YESNO + MB_APPLMODAL + MB_ICONQUESTION) = ID_YES;
  Application.RestoreTopMosts;
end;

function AskQuestion(Message: string): Boolean; overload;
begin
  Result := AskQuestion(Message, Application.MainForm.Caption);
end;

procedure OriginNames(Origin: string; out TableName: string;
  out FieldName: string);
var
  S: TStrings;
begin
  S := TStringList.Create;
  try
    TableName := '';
    FieldName := '';
    S.Text := StringReplace(StringReplace(Origin, '"', '', [rfReplaceAll]), '.',
      #13#10, [rfReplaceAll]);
    if S.Count = 2 then
    begin
      TableName := S[0];
      FieldName := S[1];
    end;
  finally
    S.Free;
  end;
end;

function FieldTypeStr(FieldType: Integer): string;
begin
  Result := '';
  case FieldType of
    tfInteger: Result := 'INTEGER';
    tfInt64: Result := 'BIGINT';
    tfSmallInt: Result  := 'SMALLINT';
    tfQuard: Result := 'QUARD';
    tfChar: Result := 'CHAR';
    tfCString: Result := 'CSTRING';
    tfVarChar: Result := 'VARCHAR';
    tfD_Float: Result := 'DFOAT';
    tfDouble: Result := 'DOUBLE';
    tfFloat: Result := 'FLOAT';
    tfDate: Result := 'DATE';
    tfTime: Result := 'TIME';
    tfTimeStamp: Result := 'TIMESTAMP';
    tfBlob: Result := 'BLOB';
  end;
end;

function FieldSubTypeStr(FieldType, FieldSubType: Integer): string;
begin
  Result := '';
  case FieldType of
    tfBlob:
    begin
      case FieldSubType of
        bstText: Result := 'Text';
        bstBLR: Result := 'Binary';

      end;
    end;
    tfChar:
    begin
      if FieldSubType = 1 then
        Result := 'Fixed binary';
    end;
    tfInteger, tfSmallInt, tfInt64:
    begin
      case FieldSubType of
        istNumeric: Result := 'Numeric';
        istDecimal: Result := 'Decimal';
      end;
    end;
  end;
end;

function ShiftString(S: string; C: Integer): string;
var
  Strings: TStrings;
  I: Integer;
  lS: string;
begin
  Strings := TStringList.Create;
  try
    Strings.text := S;
    lS := StringOfChar(' ', C);
    for I := 0 to Strings.Count - 1do
    begin
      Strings[I] := lS + Strings[I];
    end;
    Result := Strings.Text;
  finally
    Strings.Free;
  end;
end;

procedure ReadComandLineLoginParams(CommandLines: TStrings);
begin
  ExtractStrings([' '], [' '], GetCommandLine, CommandLines);
end;

function DoSortLog(Item1, Item2: Pointer): Integer;
var
  Rl1, RL2: TReplLogRecord;
begin
  RL1 := TReplLogRecord(Item1^);
  RL2 := TReplLogRecord(Item2^);
  Result := RL1.RelationKey - RL2.RelationKey;
  if Result = 0 then
  begin
    if (RL1.OldKey = RL2.NewKey) or (RL1.NewKey = RL2.OldKey) then
    begin
      if Double(RL1.ActionTime) - Double(RL2.ActionTime) > 0 then
        Result := 1
      else
      if Double(RL1.ActionTime) - Double(RL2.ActionTime) < 0 then
        Result := -1
      else
      begin
        Result := RL1.Seqno - RL2.Seqno;
      end;
    end else
      Result := CompareStr(RL1.OldKey, RL2.OldKey);
  end;
end;

function rpRelationIndexesSortCompare(Item1, Item2: Pointer): Integer;
begin
  Result := TrpRelation(Item1).FRelationKey - TrpRelation(Item2).FRelationKey;
end;

function rpFieldSortCompare(Item1, Item2: Pointer): Integer;
begin
  Result :=  CompareStr(TrpField(Item1).FFieldName, TrpField(Item2).FFieldName);
end;

function RUIDConformitysSortCompare(Item1, Item2: Pointer): Integer;
var
  R1, R2: TRUID;
begin
  R1 := TRUIDConformity(Item1^).RUID;
  R2 := TRUIDConformity(Item2^).RUID;
  Result := R1.DBID - R2.DBID;
  if Result = 0 then
  begin
    Result := R1.RelationID - R2.RelationID;
    if Result = 0 then
      Result := R1.XID - R2.XID;
  end;
end;

function RUIDIndicesSortCompare(Item1, Item2: Pointer): Integer;
var
  R1, R2: TRUIDIndex;
begin
  R1 := TRUIDIndex(Item1^);
  R2 := TRUIDIndex(Item2^);
  Result := R1.RUID.DBID - R2.RUID.DBID;
  if Result = 0 then
  begin
    Result := R1.RUID.RelationID - R2.RUID.RelationID;
    if Result = 0 then
    begin
      Result := R1.RUID.XID - R2.RUID.XID;
    end;
  end;
end;

function IDIndicesSortCompare(Item1, Item2: Pointer): Integer;
var
  I1, I2: TIDIndex;
begin
  I1 := TIDIndex(Item1^);
  I2 := TIDIndex(Item2^);
  Result := I1.RelationKey - I2.RelationKey;
  if Result = 0 then
    Result := I1.Id - I2.Id;
end;

{
****************************** TReplicationDBList ******************************
}
function TReplicationDBList.GetCount: Integer;
begin
  LoadAll;
  Result := inherited Count;
end;

function TReplicationDBList.GetItems(DBKey: Integer): TReplicationDB;
var
  Index: Integer;
begin
  Index := IndexOfDB(DBKey);
  if Index > - 1 then
    Result := TReplicationDB(inherited Items[Index]^)
  else
    raise exception.Create(InvalidDataBaseKey);
end;

function TReplicationDBList.GetItemsByIndex(Index: Integer): TReplicationDB;
begin
  Result := TReplicationDB(inherited Items[Index]^)
end;

function TReplicationDBList.IndexByDBName(Name: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if UpperCase(ItemsByIndex[I].DBName) = UpperCAse(Name) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TReplicationDBList.IndexOfDb(DBKey: Integer): Integer;
var
  SQL: TIBSQL;
  I: Integer;
  DB: PReplicationDB;
begin
  Result := -1;
  for I := 0 to inherited Count - 1 do
  begin
    if ItemsByIndex[I].DBKey = DBKey then
    begin
      Result := I;
      Exit;
    end;
  end;
  
  SQL := TIBSQl.Create(nil);
  try
    SQL.Transaction := ReplDataBase.ReadTransaction;
    SQL.SQL.Add('SELECT * FROM RPL$REPLICATIONDB WHERE dbkey = :dbkey');
    SQL.ParamByName('dbkey').AsInteger := DbKey;
    SQL.ExecQuery;
    if SQL.RecordCount > 0 then
    begin
      New(DB);
      with DB^ do
      begin
        DBKey := SQL.FieldByName(fnDBKey).AsInteger;
        DBState := TDBState(SQL.FieldByName(fnDBState).AsInteger);
        DBName := SQL.FieldByName(fnDBName).AsString;
        Priority := SQL.FieldByName(fnPriority).AsInteger;
        ReplKey := SQL.FieldByName(fnReplKey).AsInteger;
        LastProcessReplKey := SQL.FieldByName(fnLastProcessReplKey).AsInteger;
        ReplData := SQL.FieldByName(fnReplDate).AsDateTime;
        LastProcessReplData := SQL.FieldByName(fnLastProcessReplDate).AsDateTime;
      end;
      Result := Add(DB);
    end;
  finally
    SQL.Free;
  end;
end;

procedure TReplicationDBList.LoadAll;
var
  SQL: TIBSQL;
begin
  if not FLoaded then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.ReadTransaction;
      SQL.SQL.Add('SELECT dbkey FROM rpl$replicationdb');
      SQL.ExecQuery;
      while not SQL.Eof do
      begin
        IndexOfDb(SQL.FieldByName(fnDBKey).AsInteger);
        SQL.Next;
      end;
    finally
      SQL.Free;
    end;
    FLoaded := True;
  end;
end;

procedure TReplicationDBList.Notify(Ptr: Pointer; Action: TListNotification);
  
  {var
    P: PReplicationDB;}
  
begin
  case Action of
    lnDeleted: Dispose(Ptr);
  {    lnAdded:
      begin
        New(P);
        P^ := TReplicationDB(Ptr^);
        inherited Items[IndexOf(Ptr)] := P;
      end;}
  end;
end;

{
******************************** TSeqnoIndices *********************************
}
{
******************************* TrplStreamHeader *******************************
}
{
********************************* TSortedList **********************************
}
constructor TSortedList.Create;
begin
  FOwnObjects := True;
end;

function TSortedList.IndexOf(Item: Pointer): Integer;
var
  L, H, I, C: Integer;
begin
  Sort;
  Result := - 1;
  L := 0;
  H := Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := FSortCompare(Items[I], Item);
    if C < 0 then
      L := I + 1
    else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Result := I;
        Break;
      end;
    end;
  end;
end;

procedure TSortedList.Notify(Ptr: Pointer; Action: TListNotification);
begin
  inherited;
  FSorted := Action <> lnAdded;
  if (Action = lnDeleted) and FOwnObjects then
    TObject(Ptr).Free;
end;

procedure TSortedList.SetOwnObjects(const Value: Boolean);
begin
  FOwnObjects := Value;
end;

procedure TSortedList.Sort;
begin
  if not FSorted then
  begin
    GetSortCompare;
    inherited Sort(FSortCompare);
    FSorted := True;
  end;
end;

{
******************************** TRelationIndex ********************************
}
{
********************************* TKeyIndices **********************************
}
{
********************************* TrpRelation **********************************
}
destructor TrpRelation.Destroy;
begin
  FIBSQL.Free;
  FFields.Free;
  FKeys.Free;
  {$IFDEF JUXTA}
  FJuxtaPosition.Free;
  FJuxtaPositionSQL.Free;
  {$ENDIF}

  FDeleteSQL.Free;
  FInsertSQL.Free;
  FSelectSQL.Free;
  FModifySQL.Free;

  FNeedSaveRUIDFields.Free;
  
  inherited;
end;

procedure TrpRelation.CheckLoaded;
var
  F: TrpField;
  R: TrpRelation;
  Index: Integer;
begin
  if not FLoaded then
  begin
    CheckSQL;
    FIBSQL.SQL.Clear;
    //Чтение полей
    FIBSQL.SQL.Add('SELECT rplf.fieldname, f.rdb$field_type AS fieldtype, ' +
      ' f.rdb$field_sub_type as fieldsubtype, (SELECT 1 FROM rdb$relation_constraints rc JOIN ' +
      ' rdb$index_segments i_s ON rc.rdb$index_name = i_s.rdb$index_name WHERE ' +
      ' rc.rdb$relation_name = rplr.relation AND rc.rdb$constraint_type = ' +
      ' ''PRIMARY KEY'' AND i_s.rdb$field_name = rplf.fieldname) AS IsPrimeKey FROM rpl$fields rplf ' +
      ' JOIN rpl$relations rplr ON rplr.id = rplf.relationkey JOIN rdb$relation_fields '+
      ' rf ON rf.rdb$relation_name = rplr.relation AND rf.rdb$field_name = rplf.fieldname ' +
      ' JOIN rdb$fields f ON f.rdb$field_name = rf.rdb$field_source ' +
      'WHERE rplf.relationkey = :relationkey ORDER BY rplf.fieldname');
    FIBSQL.ParamByName('relationkey').AsInteger := FRelationKey;
    FIBSQL.ExecQuery;
  
    if FFields =  nil then
      FFields := TrpFields.Create;
  
    FFields.Clear;
  
    if not FIBSQL.Eof then
    begin
      while not FIBSQL.Eof do
      begin
        F := TrpField.Create;
        F.FFieldName := Trim(FIBSQL.FieldByName(fnFieldName).AsString);
        F.FFieldType := FIBSQL.FieldByName(fnFieldType).AsInteger;
        F.FIsPrimeKey := FIBSQL.FieldByName(fnIsPrimeKey).AsInteger > 0;
        F.FieldSubType := FIBSQL.FieldByName(fnFieldSubType).AsInteger;
        F.FRelation := Self;
        FFields.Add(F);
  
        FIBSQL.Next;
      end;
    end;
    FIBSQL.Close;
  
    FIBSQL.SQL.Clear;
    //Чтение ключей
    FIBSQL.SQL.Add('SELECT rplf.keyname as fieldname, f.rdb$field_type AS fieldtype, ' +
      ' f.rdb$field_sub_type as fieldsubtype, (SELECT 1 FROM rdb$relation_constraints rc JOIN ' +
      ' rdb$index_segments i_s ON rc.rdb$index_name = i_s.rdb$index_name WHERE ' +
      ' rc.rdb$relation_name = rplr.relation AND rc.rdb$constraint_type = ' +
      ' ''PRIMARY KEY'' AND i_s.rdb$field_name = rplf.keyname) AS IsPrimeKey FROM rpl$keys rplf ' +
      ' JOIN rpl$relations rplr ON rplr.id = rplf.relationkey JOIN rdb$relation_fields '+
      ' rf ON rf.rdb$relation_name = rplr.relation AND rf.rdb$field_name = rplf.keyname ' +
      ' JOIN rdb$fields f ON f.rdb$field_name = rf.rdb$field_source WHERE rplf.relationkey ' +
      ' = :relationkey ORDER BY rplf.keyname');
    FIBSQL.ParamByName('relationkey').AsInteger := FRelationKey;
    FIBSQL.ExecQuery;

    if FKeys = nil then
    begin
      FKeys := TrpFields.Create;
      FKeys.FOwnObjects := False;
    end;
    FKeys.Clear;
  
    while not FIBSQL.Eof do
    begin
      F := TrpField.Create;
      F.FFieldName := Trim(FIBSQL.FieldByName(fnFieldName).AsString);
      F.FFieldType := FIBSQL.FieldByName(fnFieldType).AsInteger;
      F.FIsPrimeKey := FIBSQL.FieldByName(fnIsPrimeKey).AsInteger > 0;
      F.FieldSubType := FIBSQL.FieldByName(fnFieldSubType).AsInteger;
      F.FRelation := Self;
      FKeys.Add(F);
      FFields.Add(F);
  
      FIBSQL.Next;
    end;
    {$IFDEF JUXTA}
    FIBSQL.Close;

    FIBSQL.SQL.Clear;
    //Загрузка кондидатов на первичный ключ
    FIBSQL.SQL.Add('SELECT rplf.fieldname FROM rpl$juxtaposition rplf ' +
      ' JOIN rpl$relations rplr ON rplr.id = rplf.relationkey WHERE rplf.relationkey ' +
      ' = :relationkey ORDER BY rplf.fieldname');
    FIBSQL.ParamByName('relationkey').AsInteger := FRelationKey;
    FIBSQL.ExecQuery;
  
    if FJuxtaPosition = nil then
    begin
      FJuxtaPosition := TrpFields.Create;
      FJuxtaPosition.FOwnObjects := False;
    end;
  
    FJuxtaPosition.Clear;
  
    while not FIBSQL.Eof do
    begin
      Index := FFields.IndexOfField(Trim(FIBSQL.FieldByName(fnFieldName).AsString));
      if Index > - 1 then
      begin
        F := FFields[Index];
        FJuxtaPosition.Add(F);
      end else
        raise Exception.Create(InvalidFieldName);

      FIBSQL.Next;
    end;
    {$ENDIF}
    //Загрузка уникальных ключей
  
    //Загрузка внешних ключей
    FIBSQL.Close;
  
    FIBSQL.SQL.Clear;
    //Загрузка внешних ключей
    FIBSQL.SQL.Add(SELECT_FOREIGN_KEYS_BY_RELATIONKEY);
    FIBSQL.ParamByName(fnRelationKey).AsInteger := FRelationKey;
    FIBSQL.ExecQuery;
    //для предотвращения зацикливания присваиваем
   // признак загрузки здесь
    FLoaded := True;
    while not FIBSQL.Eof do
    begin
      Index := FFields.IndexOfField(Trim(FIBSQL.FieldByName(fnFieldName).AsString));
      if Index > - 1 then
      begin
        F := FFields[Index];
        R := ReplDataBase.Relations[FIBSQL.FieldByName('refid').AsInteger];
        R.Load;
        Index := R.FFields.IndexOfField(Trim(FIBSQL.FieldByName('reffieldname').AsString));
        if Index > - 1 then
        begin
          F.ReferenceField := R.FFields[Index];
        end else
          raise Exception.Create(InvalidFieldName);
      end;

      FIBSQl.Next;
    end;

    if FDeleteSQL <> nil then FDeleteSQL.Clear;
    if FInsertSQL <> nil then FInsertSQL.Clear;
    if FSelectSQL <> nil then FSelectSQL.Clear;
    if FModifySQL <> nil then FModifySQL.Clear;
  
  end;
end;

procedure TrpRelation.CheckSQL;
begin
  if FIBSQL = nil then
  begin
    FIBSQL := TIBSQL.Create(nil);
    FIBSQL.Transaction := FDataBase.ReadTransaction;
  end;
  FIBSQL.Close;
end;

function TrpRelation.GetDeleteSQL: TStrings;
var
  I: Integer;
begin
  Load;
  
  if FDeleteSQL = nil then
    FDeleteSQL := TStringList.Create;
  
  if FDeleteSQL.Count = 0 then
  begin
    FDeleteSQL.Add('DELETE FROM ' + FRelationName);
    FDeleteSQL.Add('WHERE');
    for I := 0 to FKeys.Count - 2 do
      FDeleteSQL.Add(FKeys[I].FFieldName + ' = :' + FKeys[I].FFieldName + ' AND ');
  
    if FKeys.Count > 0 then
      FDeleteSQL.Add(FKeys[FKeys.Count - 1].FFieldName + ' = :' +
        FKeys[FKeys.Count - 1].FFieldName);
  end;
  
  Result := FDeleteSQL;
end;

function TrpRelation.GetFields: TrpFields;
begin
  Load;
  Result := FFields;
end;

function TrpRelation.GetInsertSQL: TStrings;
var
  I: Integer;
begin
  Load;
  
  if FInsertSQL = nil then
    FInsertSQL := TStringList.Create;
  
  if FInsertSQL.Count = 0 then
  begin
    FInsertSQL.Add('INSERT INTO ' + FRelationName + '(');
  
    for I := 0 to FFields.Count - 2 do
      FInsertSQL.Add(FFields[i].FFieldName + ', ');
  
    if FFields.Count > 0 then
      FInsertSQL.Add(FFields[FFields.Count - 1].FFieldName);
  
    FInsertSQL.Add(') VALUES (');
  
    for I := 0 to FFields.Count - 2 do
      FInsertSQL.Add(':' + FFields[i].FFieldName + ', ');
  
    if FFields.Count > 0 then
      FInsertSQL.Add(':' + FFields[FFields.Count - 1].FFieldName);
  
    FInsertSQL.Add(')');
  end;
  
  Result := FInsertSQL;
end;

function TrpRelation.GetJuxtaPosition: TrpFields;
begin
  Load;
  Result := FJuxtaPosition;
end;

function TrpRelation.GetJuxtaPositionSQL: TStrings;
var
  I: Integer;
begin
  Load;
  
  if FJuxtaPosition.Count > 0 then
  begin
    if FJuxtaPositionSQL = nil then
      FJuxtaPositionSQL := TStringList.Create;
  
    if FJuxtaPositionSQL.Count = 0 then
    begin
      FJuxtaPositionSQL.Add('SELECT');
  
      for I := 0 to FFields.Count - 2 do
        FJuxtaPositionSQL.Add(FFields[i].FFieldName + ', ');
  
      if FFields.Count > 0 then
        FJuxtaPositionSQL.Add(FFields[FFields.Count - 1].FFieldName);
  
      FJuxtaPositionSQL.Add('FROM');
      FJuxtaPositionSQL.Add(FRelationName);
      FJuxtaPositionSQL.Add('WHERE ');
  
      for I := 0 to FJuxtaPosition.Count - 2 do
        FJuxtaPositionSQL.Add(FJuxtaPosition[I].FFieldName + ' = :' +
          FJuxtaPosition[I].FFieldName + ' AND ');
  
      FJuxtaPositionSQL.Add(FJuxtaPosition[FJuxtaPosition.Count - 1].FFieldName + ' = :' +
        FJuxtaPosition[FJuxtaPosition.Count - 1].FFieldName);
    end;
  end;
  
  Result := FJuxtaPositionSQL;
end;

function TrpRelation.GetKeys: TrpFields;
begin
  Load;
  Result := FKeys;
end;

function TrpRelation.GetModifySQL: TStrings;
var
  I: Integer;
begin
  Load;
  
  if FModifySQL = nil then
    FModifySQL :=  TStringList.Create;
  
  if FModifySQL.Count = 0 then
  begin
    FModifySQL.Add('UPDATE ' + FRelationName + ' SET');
  
    for I := 0 to FFields.Count - 2 do
      FModifySQL.Add(FFields[i].FFieldName + ' = :' + FFields[i].FFieldName + ', ');
  
    if FFields.Count > 0 then
      FModifySQL.Add(FFields[FFields.Count - 1].FFieldName + ' = :' +
        FFields[FFields.Count - 1].FFieldName);
  
   FModifySQL.Add('WHERE');
  
   for I := 0 to FKeys.Count - 2 do
     FModifySQL.Add(FKeys[i].FFieldName + ' = :OLD_' + FKeys[i].FFieldName + ' AND ');
  
   if FKeys.Count > 0 then
     FModifySQL.Add(FKeys[FKeys.Count - 1].FFieldName + ' = :OLD_' +
       FKeys[FKeys.Count - 1].FFieldName);
  end;
  
  Result := FModifySQL;
end;

function TrpRelation.GetSelectSQL: TStrings;
var
  I: Integer;
begin
  Load;
  
  if FSelectSQL = nil then
    FSelectSQL := TStringList.Create;
  
  if FSelectSQL.Count = 0 then
  begin
    FSelectSQL.Add('SELECT');
  
    for I := 0 to FFields.Count - 2 do
      FSelectSQL.Add(FFields[i].FFieldName + ', ');
  
    if FFields.Count > 0 then
      FSelectSQL.Add(FFields[FFields.Count - 1].FFieldName);
  
    FSelectSQL.Add('FROM');
    FSelectSQL.Add(FRelationName);
    FSelectSQL.Add('WHERE ');
  
    for I := 0 to FKeys.Count - 2 do
      FSelectSQL.Add(FKeys[i].FFieldName + ' = :' + FKeys[i].FFieldName + ' AND ');
  
    if FKeys.Count > 0 then
      FSelectSQL.Add(FKeys[FKeys.Count - 1].FFieldName + ' = :' +
        FKeys[FKeys.Count - 1].FFieldName);
  end;
  
  Result := FSelectSQL;
end;

function TrpRelation.IBSQL: TIBSQL;
begin
  CheckSQL;
  Result := FIBSQL;
end;

procedure TrpRelation.InitFieldIndices;
var
  SQL: TIBSQL;
  I: Integer;
begin
  if not FFieldIndicesInited then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := FDataBase.ReadTransaction;
      SQL.SQL.Assign(SelectSQL);
      SQL.Prepare;
  
      for I := 0 to FFields.Count - 1 do
        FFields[I].InitIndices(SQL);
    finally
      SQL.Free;
    end;
    FFieldIndicesInited := True;
  end;
end;

procedure TrpRelation.Load;
{$IFDEF GEDEMIN}
  var
    Index: Integer;
    F: TrpField;
    B: Boolean;
{$ENDIF}
begin
  {$IFDEF GEDEMIN}
  B := not FLoaded;
  {$ENDIF}
  CheckLoaded;

  {$IFDEF GEDEMIN}
  if B and (FRelationName = 'INV_MOVEMENT') then
  begin
    if FNeedSaveRUIDFields = nil then
    begin
      FNeedSaveRUIDFields := TrpFields.Create;
      FNeedSaveRUIDFields.OwnObjects := False;
    end;

    Index := Fields.IndexOfField('MOVEMENTKEY');
    if Index > - 1 then
    begin
      F := Fields[Index];
      if FNeedSaveRUIDFields.IndexOf(F) = - 1 then
      begin
        FNeedSaveRUIDFields.Add(F);
      end;
    end;
  end;
  {$ENDIF}
end;

function TrpRelation.Loaded: Boolean;
begin
  Result := FLoaded;
end;

procedure TrpRelation.SetDataBase(const Value: TReplDataBase);
begin
  FDataBase := Value;
end;

procedure TrpRelation.SetDeleteSQL(const Value: TStrings);
begin
  FDeleteSQL.Assign(Value);
end;

procedure TrpRelation.SetGeneratorName(const Value: string);
begin
  FGeneratorName := Value;
end;

procedure TrpRelation.SetInsertSQL(const Value: TStrings);
begin
  FInsertSQL.Assign(Value);
end;

procedure TrpRelation.SetJuxtaPositionSQL(const Value: TStrings);
begin
  FJuxtaPositionSQL := Value;
end;

procedure TrpRelation.SetModifySQL(const Value: TStrings);
begin
  FModifySQL.Assign(Value);
end;

procedure TrpRelation.SetRelationKey(const Value: Integer);
begin
  FRelationKey := Value;
end;

procedure TrpRelation.SetRelationName(const Value: string);
begin
  FRelationName := UpperCase(Value);
end;

procedure TrpRelation.SetRelationLocalName(const Value: string);
begin
  FRelationLocalName := UpperCase(Value);
end;

procedure TrpRelation.SetSelectSQL(const Value: TStrings);
begin
  FSelectSQL.Assign(Value);
end;

{
******************************* TrpUniqueIndices *******************************
}
{
******************************* TRelationIndices *******************************
}
{
*********************************** TrpField ***********************************
}
constructor TrpField.Create;
begin
  FFieldIndex := - 1;
  //  FParamIndex := -1;
end;

destructor TrpField.Destroy;
var
  I: Integer;
begin
  if FReferenceField <> nil then
  begin
    FReferenceField.FForeignFields.Extract(Self);
    if FReferenceField.FForeignFields.Count = 0 then
      FreeAndNil(FReferenceField.FForeignFields)
  end;
  for I := 0 to ForeignFieldCount - 1 do
  begin
    ForeignFields[I].ReferenceField := nil;
  end;
  FForeignFields.Free;
  inherited;
end;

function TrpField.GetFieldIndex: Integer;
begin
  if FFieldIndex = - 1 then
  begin
    if FRelation = nil then
      raise Exception.Create(RelationNotAssigned);
    FRelation.InitFieldIndices;
  end;
  
  Result := FFieldIndex;
end;

function TrpField.GetForeignFieldCount: Integer;
begin
  Result := 0;
  if FForeignFields <> nil then
    Result := FForeignFields.Count;
end;

function TrpField.GetForeignFields(Index: Integer): TrpField;
begin
  Result := nil;
  if FForeignFields <> nil then
    Result := TrpField(FForeignFields[Index]);
end;

function TrpField.GetIsForeign: Boolean;
begin
  //Result := False;
  Result := FReferenceField <> nil;
end;

procedure TrpField.InitIndices(SQL: TIBSQL);
  
  {var
    S: TStrings;}
  
begin
  FFieldIndex := SQL.FieldIndex[FFieldName];
  {  S := TStringList.Create;
    try
      S.Text := SQL.Params.Names;
      FParamIndex := S.IndexOf(FFieldName);
    finally
      S.Free;
    end;}
end;

procedure TrpField.SetConformity(const Value: Boolean);
begin
  FConformity := Value;
end;

procedure TrpField.SetFieldIndex(const Value: Integer);
begin
  FFieldIndex := Value;
end;

procedure TrpField.SetFieldName(const Value: string);
begin
  FFieldName := Value;
end;

procedure TrpField.SetFieldSubType(const Value: Integer);
begin
  FFieldSubType := Value;
end;

procedure TrpField.SetFieldType(const Value: Integer);
begin
  FFieldType := Value;
end;

procedure TrpField.SetIsPrimeKey(const Value: Boolean);
begin
  FIsPrimeKey := Value;
end;

procedure TrpField.SetReferenceField(const Value: TrpField);
begin
  FReferenceField := Value;
  if FReferenceField <> nil then
  begin
    if FReferenceField.FForeignFields = nil then
      FReferenceField.FForeignFields := TList.Create;
  
    FReferenceField.FForeignFields.Add(Self);
  end;
end;

procedure TrpField.SetRelation(const Value: TrpRelation);
begin
  FRelation := Value;
end;

{
********************************* TSeqnoIndex **********************************
}
{
******************************** TReplDataBase *********************************
}
destructor TReplDataBase.Destroy;
begin
  FReadSQL.Free;
  FReadTransaction.Free;
  FTransaction.Free;
  FRelations.Free;
  FSeqNo.Free;
  FReplicationDBList.Free;
  FConnectNotifyList.Free;
  
  inherited;
end;

procedure TReplDataBase.AddConnectNotify(Notify: IConnectChangeNotify);
begin
  if FConnectNotifyList = nil then
    FConnectNotifyList := TList.Create;
  
  if FConnectNotifyList.IndexOf(Pointer(Notify)) = - 1 then
  begin
    FConnectNotifyList.Add(Pointer(Notify));
  end;
end;

function TReplDataBase.CanRepl(ADBID: Integer): Boolean;
begin
  CheckReplicationDbList;
  Result := (FReplicationDBList.IndexOfDb(ADBID) > - 1) and (DataBaseInfo.DBID <> ADBID);
end;

procedure TReplDataBase.CheckReadSQL;
begin
  CheckReadTransactionInTransaction;
  
  if FReadSQL = nil then
  begin
    FReadSQL := TIBSQL.Create(nil);
    FReadSQL.Transaction := FReadTransaction;
  end;
  FReadSQL.Close;
  FReadSQL.SQL.Clear;
end;

procedure TReplDataBase.CheckReadTransaction;
begin
  if FReadTransaction = nil then
  begin
    FReadTransaction := TIBTransaction.Create(nil);
    FReadTransaction.DefaultDatabase := Self;
    FReadTransaction.Params.Text := 'read_committed'#13#10'rec_version'#13#10'nowait'#13#10'read'#13#10;
    FReadTransaction.Name := 'InternalRead';
    FReadTransaction.AutoStopAction := saNone;
  end;
end;

procedure TReplDataBase.CheckReadTransactionInTransaction;
begin
  if Connected then
  begin
    CheckReadTransaction;
    if not FReadTransaction.InTransaction then
      FReadTransaction.StartTransaction;
  end else
    raise Exception.Create(DataBaseIsNotConnected);
end;

procedure TReplDataBase.CheckReplicationDbList;
begin
  if FReplicationDBList = nil then
    FReplicationDBList := TReplicationDBList.Create;
end;

function TReplDataBase.CheckReplicationSchema: Boolean;
begin
  if not FSchemaChecked then
  begin
    CheckReadSQL;
    FReadSQL.SQL.Text := cCheckTableExist;
    FReadSQL.ExecQuery;
    FIsPrepared := FReadSQL.Fields[0].AsInteger = TableCount;
  
    if FIsPrepared then
    begin
      FReadSQL.Close;
      FReadSQL.SQL.Text := 'SELECT prepared FROM rpl$dbstate';
      FReadSQl.ExecQuery;
      FIsPrepared := FReadSQL.FieldByName(fnPrepared).AsInteger = 1;
    end;
  
    FSchemaChecked := True;
  end;
  Result := FIsPrepared;
end;

procedure TReplDataBase.CheckTransaction;
begin
  if FTransaction = nil then
  begin
    FTransaction := TIBTransaction.Create(nil);
    FTransaction.DefaultDatabase := Self;
    FTransaction.Name := 'Internal';
    FTransaction.AutoStopAction := saNone;
  end;
end;

function TReplDataBase.CountChanges(ADBID: Integer): Integer;
begin
  CheckReadSQL;
  FReadSQL.SQL.Text := Format('SELECT'#13#10 +
    '  COUNT(all_l.seqno) - COUNT(l.seqno)'#13#10 +
    'FROM'#13#10 +
    '  rpl$log all_l'#13#10 +
    'LEFT JOIN  rpl$log l ON l.seqno = all_l.seqno AND'#13#10 +
    '  EXISTS('#13#10 +
    '    SELECT'#13#10 +
    '      seqno'#13#10 +
    '    FROM'#13#10 +
    '      rpl$loghist h'#13#10 +
    '    WHERE'#13#10 +
    '      h.seqno = l.seqno AND'#13#10 +
    '      h.dbkey = %d AND'#13#10 +
    '      h.tr_commit <> - 1)', [ADBID]);
  FReadSQl.ExecQuery;
  Result := FReadSQL.Fields[0].AsInteger;
end;

function TReplDataBase.DBPriority(DBKey: Integer): Integer;
begin
  CheckReplicationDbList;
  Result := FReplicationDBList[DBKey].Priority;
end;

procedure TReplDataBase.DoConnect;
var
  I: Integer;
begin
  inherited;
  
  CheckReadTransactionInTransaction;
  
  if not FPreserve then
  begin
    FDataBaseInfo.Loaded := False;
    FSchemaChecked := False;
  
    FreeAndNil(FRelations);
    FreeAndNil(FReplicationDBList);

    if FConnectNotifyList <> nil then
    begin
      for I := 0 to FConnectNotifyList.Count -1 do
      begin
        IConnectChangeNotify(FConnectNotifyList[I]).DoAfterSuccessfullConnection;
      end;
    end;
  end;
end;

procedure TReplDataBase.DoDisconnect;
var
  I: Integer;
begin
  if FReadTransaction.InTransaction then
    FReadTransaction.Commit;
  
  if not FPreserve then
  begin
    if FConnectNotifyList <> nil then
    begin
      for I := 0 to FConnectNotifyList.Count -1 do
      begin
        IConnectChangeNotify(FConnectNotifyList[I]).DoBeforeDisconnect;
      end;
    end;
  end;
  
  inherited;
end;

function TReplDataBase.DomaneExist(Domane: TDomane): Boolean;
begin
  CheckReadSQL;
  FReadSQL.SQL.Add('SELECT rdb$field_name FROM rdb$fields WHERE rdb$field_name = :name');
  FReadSQL.ParamByName('name').AsString := UpperCase(Domane.Name);
  FReadSQL.ExecQuery;
  Result := FReadSQL.RecordCount > 0;
end;

function TReplDataBase.ExceptionExist(Exception: TExcept): Boolean;
begin
  CheckReadSQL;
  FReadSQL.SQL.Add('SELECT rdb$exception_name FROM rdb$exceptions WHERE rdb$exception_name = :name');
  FReadSQL.ParamByName('name').AsString := UpperCase(Exception.Name);
  FReadSQL.ExecQuery;
  Result := FReadSQL.RecordCount > 0;
end;

function TReplDataBase.GenDBID: Integer;
var
  SQL: TIBSQL;
begin
  if GeneratorExist(GD_G_DBID) then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction :=  ReadTransaction;
      SQL.SQL.Add('SELECT GEN_ID(gd_g_dbid, 0) FROM rdb$database');
      SQL.ExecQuery;
      Result := SQL.Fields[0].AsInteger;
      if Result = 0 then
      begin
        SQL.Close;
        Result := GetNewDBID;
        SQL.SQL.Text := 'SET GENERATOR gd_g_dbid TO ' + IntToStr(Result);
        SQL.ExecQuery;
      end;
    finally
      SQL.Free;
    end;
  end else
    Result := GetNewDBID;
end;

function TReplDataBase.GeneratorExist(Generator: TGenerator): Boolean;
begin
  CheckReadSQL;
  FReadSQL.SQL.Add('SELECT rdb$generator_name FROM rdb$generators WHERE rdb$generator_name = :name');
  FReadSQL.ParamByName('name').AsString := UpperCase(Generator.Name);
  FReadSQL.ExecQuery;
  Result := FReadSQL.RecordCount > 0;
end;

function TReplDataBase.GetDBInfo: TDBInfo;
begin
  if not FDataBaseInfo.Loaded then
  begin
    if not CheckReplicationSchema then
      raise Exception.Create(ReplicationSchemaNotFound);
  
    CheckReadSQL;
    FReadSQL.SQL.Text := 'SELECT s.*, r.dbstate FROM rpl$dbstate s JOIN rpl$replicationdb r ON s.dbkey = r.dbkey ';
    FReadSQL.ExecQuery;
    with FDataBaseInfo do
    begin
      DBState := TDBState(FReadSQL.FieldByName(fnDbState).AsInteger);
      Schema := FReadSQL.FieldByName(fnReplicationID).AsInteger;
      ErrorDecision :=
        TErrorDecision(FReadSQL.FieldByName(fnErrorDecision).AsInteger);
      PrimeKeyType := TPrimeKeyType(FReadSQL.FieldByName(fnPrimeKeyType).AsInteger);
      if PrimeKeyType = ptUniqueInDb then
        GeneratorName := FReadSQL.FieldByName(fnGeneratorName).AsString;
      KeyDivider := FReadSQL.FieldByName(fnKeyDivider).AsString;
      DBID := FReadSQL.FieldByName(fnDBKey).AsInteger;
      Loaded := True;
    end;
  
    FReadSQL.Close;
  end;
  Result := FDataBaseInfo;
end;

function TReplDataBase.GetDBList: TReplicationDBList;
begin
  CheckReplicationDbList;
  Result := FReplicationDBList;
end;

function TReplDataBase.GetDBName: TIBFileName;
begin
  Result := inherited DatabaseName;
end;

procedure TReplDataBase.GetDbReport(const S: TStrings);
var
  I: Integer;
begin
  {$IFDEF DEBUG}
  Exit;
  {$ENDIF}
  CheckReplicationDbList;
  FReplicationDBList.LoadAll;
  with DataBaseInfo do
  begin
{    S.Add(Format(MSG_REPORT_ERROR_DECISION, [GetErrorDecisionString(ErrorDecision)]));
    S.Add(Format(MSG_REPORT_REPL_KEY, [Schema]));
    S.Add('');

    S.Add(Format(MSG_REPORT_CURRENT_DB_ALIAS, [FReplicationDBList[DBID].DBName]));
    S.Add(Format(MSG_REPORT_DB_KEY, [DBID]));
    S.Add(Format(MSG_REPORT_DB_STATE, [GetDBStateString(DBState)]));
    S.Add(Format(MSG_REPORT_DB_PRIORITY,
      [GetDBPriorityString(TrplPriority(FReplicationDBList[DBID].Priority))]));}
  end;
//  S.Add('');
//  S.Add(MSG_REPORT_TRANSFER_DATA_TO);

  for i := 0 to FReplicationDBList.Count - 1 do
  begin
    if DataBaseInfo.DBID <> FReplicationDBList.ItemsByIndex[I].DBKey then
    begin
      GetDbReport(S, FReplicationDBList.ItemsByIndex[I].DBKey);
      S.Add('');
    end;
  end;
  S.Text := Trim(S.text);
end;

procedure TReplDataBase.GetDbReport(const S: TStrings; DBKey: Integer);
var
  Db: TReplicationDB;
begin
  {$IFDEF DEBUG}
  Exit;
  {$ENDIF}
  DB := DBList[DBKey];
{  S.Add(Format(MSG_REPORT_DB_ALIAS, [DB.DBName]));
  S.Add(Format(MSG_REPORT_DB_KEY, [DB.DBKey]));
  S.Add(Format(MSG_REPORT_DB_STATE, [GetDBStateString(DB.DBState)]));
  S.Add(Format(MSG_REPORT_DB_PRIORITY, [GetDBPriorityString(TrplPriority(DB.Priority))]));
  S.Add(Format(MSG_REPORT_REGISTRED_CHANGES_COUNT, [CountChanges(DBKey)]));
  S.Add(Format(MSG_REPORT_NOT_COMMIT, [NotCommitedTransaction(DBKey)]));
  S.Add(Format(MSG_REPORT_CONFLICT_COUNT, [ConflictCount(DBKey)]));}
end;

procedure TReplDataBase.GetGeneratorList(const GeneratorList: TStrings);
begin
  {$IFDEF DEBUG}
  if GeneratorList = nil then
    raise Exception.Create('Неприсвоено значение списка генераторов');
  {$ENDIF}
  GeneratorList.Clear;
  CheckReadSQL;
  FReadSQL.SQL.Text := 'SELECT rdb$generator_name FROM rdb$generators ORDER BY 1';
  FReadSQL.ExecQuery;
  while not FReadSQL.Eof do
  begin
    GeneratorList.Add(Trim(FReadSQL.FieldByName('rdb$generator_name').AsString));
    FReadSQL.Next;
  end;
end;

function TReplDataBase.GetLastProcessReplKey(DBKey: Integer): Integer;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.SQL.Text := 'SELECT lastprocessreplkey FROM rpl$replicationdb' +
      ' WHERE dbkey = ' + InttoStr(DBKey);
    SQL.Transaction := ReadTransaction;
    SQL.ExecQuery;
    Result := SQL.Fields[0].AsInteger;
  finally
    SQL.Free;
  end;
end;

function TReplDataBase.GetReadTransaction: TIBTransaction;
begin
  CheckReadTransactionInTransaction;
  Result := FReadTransaction;
end;

function TReplDataBase.GetRelations: TrpRelations;
begin
  if FRelations = nil then
  begin
    FRelations := TrpRelations.Create;
    FRelations.DataBase := Self;
  end;

  Result := FRelations;
end;

function TReplDataBase.GetTransaction: TIBTransaction;
begin
  CheckTransaction;
  Result := FTransaction;
end;

procedure TReplDataBase.IncReplKey(DBKey: Integer);
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := FTransaction;
    SQL.SQL.Add('UPDATE rpl$replicationdb SET replkey = ' +
      'replkey + 1 WHERE dbkey = ' +  IntToStr(DBKey));
    SQL.ExecQuery;
  finally
    SQL.Free;
  end;
end;

function TReplDataBase.NextSeqNo: Integer;
begin
  if FSeqNo = nil then
  begin
    FSeqNo := TIBSQL.Create(nil);
    FSeqNo.Transaction := ReadTransaction;
    FSeqNo.SQL.Add('SELECT GEN_ID(RPL$G_SEQ, 1) AS seqno ' +
      'FROM RDB$DATABASE');
  end;
  FSeqNo.ExecQuery;
  Result := FSeqNo.Fields[0].AsInteger;
  FSeqNo.Close;
end;

function TReplDataBase.NotCommitedTransaction(ADBID: Integer): Integer;
begin
  CheckReadSQL;
  FReadSQL.SQL.Text := Format('SELECT'#13#10 +
    '  min(lh.replkey)'#13#10 +
    'FROM'#13#10 +
    '  rpl$loghist lh'#13#10 +
    'WHERE'#13#10 +
    '  lh.tr_commit = 0 AND'#13#10 +
    '  lh.dbkey = %d', [ADBID]);
  FReadSQL.ExecQuery;
  if not FReadSQL.Fields[0].IsNull then
    Result := DBList[ADBID].ReplKey - FReadSQL.Fields[0].AsInteger
  else
    Result := 0;
end;

procedure TReplDataBase.RemoveConnectNotify(Notify: IConnectChangeNotify);
begin
  if FConnectNotifyList <> nil then
  begin
    FConnectNotifyList.Extract(Pointer(Notify));
    if FConnectNotifyList.Count = 0 then
      FreeAndNil(FConnectNotifyList);
  end;
end;

function TReplDataBase.ReplicationDBCount: Integer;
begin
  CheckReplicationDbList;
  FReplicationDBList.LoadAll;
  Result := FReplicationDBList.Count;
end;

function TReplDataBase.ReplKey(DbKey: Integer): Integer;
begin
  CheckReplicationDbList;
  Result := FReplicationDBList[DbKey].ReplKey;
end;

procedure TReplDataBase.SetDatabaseName(const Value: TIBFileName);
begin
  if Value <> inherited DataBaseName then
  begin
    inherited DataBaseName := Value;
    if FRelations <> nil then
      FRelations.FLoaded := False;
  end;
end;

procedure TReplDataBase.SetFileName(const Value: string);
begin
  FFileName := Value;
end;

procedure TReplDataBase.SetLastProcessReplKey(DBKey: Integer; ReplKey: Integer);
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := Transaction;
    SQL.SQL.Add('UPDATE rpl$replicationdb SET LASTPROCESSREPLKEY = ' +
      IntToStr(ReplKey) + ' WHERE dbkey = ' + IntToStr(DBKey));
    SQL.ExecQuery;
  finally
    SQL.Free;
  end;
end;

procedure TReplDataBase.SetReplKey(DBKey, ReplKey: Integer);
var
  SQL: TIBSQL;
  bNeedStart: boolean;
begin
  SQL := TIBSQL.Create(nil);
  try
    bNeedStart:= not Transaction.InTransaction;
    if bNeedStart then
      Transaction.StartTransaction;
    SQL.Transaction := Transaction;
    SQL.SQL.Add('UPDATE rpl$replicationdb SET replkey = ' +
      IntToStr(ReplKey) + ' WHERE dbkey = ' + IntToStr(DBKey));
    SQL.ExecQuery;
    if bNeedStart then
      Transaction.Commit;
  finally
    SQL.Free;
  end;
end;

procedure TReplDataBase.SetPreserve(const Value: Boolean);
begin
  FPreserve := Value;
end;

procedure TReplDataBase.SetProtocol(const Value: string);
begin
  FProtocol := Value;
end;

procedure TReplDataBase.SetServerName(const Value: string);
begin
  FServerName := Value;
end;

function TReplDataBase.TableExist(Table: TTable): Boolean;
begin
  CheckReadSQL;
  FReadSQL.SQL.Add('SELECT rdb$relation_name FROM rdb$relations WHERE rdb$relation_name = :name');
  FReadSQL.ParamByName('name').AsString := UpperCase(Table.Name);
  FReadSQL.ExecQuery;
  Result := FReadSQL.RecordCount > 0;
end;

{
******************************** TrpFieldsData *********************************
}
{
*********************************** TReplLog ***********************************
}
{
********************************* TrpFieldData *********************************
}
{
********************************* TrpRelations *********************************
}
destructor TrpRelations.Destroy;
begin
  FrpRelation.Free;
  
  inherited;
end;

procedure TrpRelations.CheckLoaded;
var
  IBSQL: TIBSQL;
  R: TrpRelation;
begin
  if FDataBase = nil then
    raise Exception.Create(DataBaseNotAssigned);
  
  if not FLoaded then
  begin
    Clear;
    IBSQL := TIBSQL.Create(nil);
    try
      IBSQL.Transaction := FDataBase.ReadTransaction;
      IBSQL.SQL.Add('SELECT * FROM rpl$relations');
      IBSQL.ExecQuery;
  
      while not IBSQL.Eof do
      begin
        R := TrpRelation.Create;
        Add(R);
        R.FRelationKey := IBSQL.FieldByName(fnId).AsInteger;
        R.FRelationName := IBSQL.FieldByName(fnRelation).AsString;
        if FDataBase.DataBaseInfo.PrimeKeyType = ptUniqueInRelation then
          R.FGeneratorName := IBSQL.FieldByName(fnGeneratorName).AsString;
        R.FDataBase := FDataBase;
        IBSQL.Next;
      end;
    finally
      IBSQL.Free;
    end;
    FLoaded := True;
  end;
end;

function TrpRelations.GetCount: Integer;
begin
  CheckLoaded;
  Result := inherited Count;
end;

function TrpRelations.GetRelations(Key: Integer): TrpRelation;
var
  Index: Integer;
begin
  Index := IndexOfRelation(Key);
  if Index > - 1 then
    Result := TrpRelation(inherited Items[Index])
  else
    Result := nil;
end;

procedure TrpRelations.GetSortCompare;
begin
  FSortCompare := rpRelationIndexesSortCompare;
end;

function TrpRelations.IndexOfRelation(RelationKey: Integer): Integer;
begin
  CheckLoaded;
  
  if FrpRelation = nil then
    FrpRelation := TrpRelation.Create;
  
  FrpRelation.FRelationKey := RelationKey;
  
  Result := inherited IndexOf(FrpRelation);
end;

function TrpRelations.KeyByName(RelationName: string): Integer;
var
  I: Integer;
begin
  Result := - 1;
  CheckLoaded;
  for I := 0 to Count - 1 do
  begin
    if TrpRelation(Items[I]).RelationName = RelationName then
    begin
      Result := TrpRelation(Items[I]).RelationKey;
      Break;
    end;
  end;
end;

procedure TrpRelations.SetDataBase(const Value: TReplDataBase);
begin
  if FDataBase <> Value then
  begin
    FDataBase := Value;
    FLoaded := False;
  end;
end;

{
********************************* TRUIDManager *********************************
}
{
******************************* TRUIDManagerDBU ********************************
}
{
******************************** TRUIDManagerRU ********************************
}
{
********************************** TrpCortege **********************************
}
{
********************************** TrpStream ***********************************
}
{
*********************************** TrpEvent ***********************************
}
{
********************************* TRUIDIndices *********************************
}
{
******************************* TRUIDConformitys *******************************
}
{
********************************** TIDIndices **********************************
}
{
********************************** TRUIDCash ***********************************
}
{
******************************** TRUIDManagerU *********************************
}
{
********************************** TrpFields ***********************************
}
destructor TrpFields.Destroy;
begin
  FField.Free;
  
  inherited;
end;

function TrpFields.GetFields(Index: Integer): TrpField;
begin
  Result := TrpField(inherited Items[Index]);
end;

procedure TrpFields.GetSortCompare;
begin
  FSortCompare := rpFieldSortCompare
end;

function TrpFields.IndexOfField(FieldName: string): Integer;
begin
  if FField = nil then
    FField := TrpField.Create;
  
  FField.FFieldName := FieldName;
  
  Result := inherited IndexOf(FField);
end;

{
******************************** TrpUniqueIndex ********************************
}
{
*********************************** TrpError ***********************************
}
{
********************************* TrpErrorList *********************************
}
{
********************************* TrpRecordSet *********************************
}
{
******************************* TrpRecordSetList *******************************
}
{
******************************** TrpRecordData *********************************
}
{ TrpUniqueIndicesValues }
function TReplDataBase.ConflictCount(DBKey: Integer): Integer;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.transaction := ReadTransaction;
    SQl.SQl.Text := 'SELECT COUNT(*) FROM RPL$MANUAL_LOG WHERE dbkey = :dbkey';
    SQL.ParamByName(fnDbKey).AsInteger := DBKey;
    SQL.ExecQuery;
    Result := SQL.Fields[0].AsInteger;
  finally
    SQL.Free;
  end;
end;

function TrpRelation.NeedSaveRUID(F: TrpField): Boolean;
begin
  Result := (F.FieldType = tfInteger) and (F.FieldSubType = istFieldType) and
    ((FNeedSaveRUIDFields <> nil) and (FNeedSaveRUIDFields.IndexOf(F) > - 1));
end;

function TReplDataBase.GetServerName: string;
begin
  Result := FServerName
end;

initialization
finalization
  _ReplDataBase.Free;
  _CommandString.Free;
end.
