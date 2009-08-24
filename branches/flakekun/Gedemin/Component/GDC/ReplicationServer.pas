{++

  Copyright (c) 2000-2001 by Golden Software of Belarus

  Module

    rpl_dlgReplicationServer_unit.pas

  Abstract

    Gedemin project.

  Author

    Karpuk Alexander

  Revisions history

    It was created in the summer begining.
    1.00    29.04.02    TipTop       Initial version.

--}

unit ReplicationServer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, IBDatabase, rpl_ReplicationConst, rpl_const;

type
  TLabelStream = array[0..3] of char;

type
  TRUID = record
    XID: Integer;
    DBID: Integer;
  end;

  PReplLog = ^TReplLog;
  TReplLog = record
    Seqno: Integer;
    RelationKey: Integer;
    ReplType: String;
    OldKey: String;
    NewKey: String;
    ReplKey: Integer;
    ActionTime: TDateTime;
    DBKey: Integer;
    RUID: TRUID;
  end;

  PDBState = ^TDBState;
  TDBState = record
    DBState: integer;
    ReplicationID: Integer;
    ErrorDecision: TErrorDecision;
  end;

  PTrigger = ^TTrigger;
  TTrigger = record
    Name: String;
    Relation: String;
    InActive: Integer;
  end;

type
  TTrigerList = class(TList)
  private
    function Get(Index: Integer): TTrigger;
    procedure Put(Index: Integer; const Value: TTrigger);
  public
    function Add(Item: TTrigger): Integer;
    procedure Clear; override;
    procedure Delete(Index: Integer);
    procedure SaveToStream(Stream: TStream);
    procedure ReadFromStream(Stream: TStream);
    function Last: TTrigger;
    property Items[Index: Integer]: TTrigger read Get write Put; default;
  end;

//Хранит информацию о таблице, именах полей и их типах
type
  TReplRelation = class
  private
    FID: Integer;
    FRelation: string;
    FKeys: TStrings;
    FFields: TStrings;
    FTransaction: TIBTransaction;
    procedure SetID(const Value: Integer);
    procedure SetTransaction(const Value: TIBTransaction);
  public
    constructor Create;
    destructor Destroy;

    property ID: Integer read FID write SetID;
    property Relation: string read FRelation write FRelation;
    property Keys: TStrings read FKeys;
    property Fields: TStrings read FFields;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
  end;

//Хранит спиок таблиц
  TReplRelations = class
    FdsRelations: TIBDataSet;
    FList: TObjectList;
  private
    function GetRelations(ID: Integer): TReplRelation;
    procedure SetTransaction(const Value: TIBTransaction);
    function GetTransaction: TIBTransaction;
  public
    constructor Create;
    destructor Destroy;
    function Add(Relation: TReplRelation): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    function IndexOf(Id: Integer): Integer;
    procedure ReadFromDB;

    property Relations[ID: Integer]: TReplRelation read GetRelations; default;
    property Transaction: TIBTransaction read GetTransaction write SetTransaction;
  end;

//Определяет запись в таблике
type
  TCortegeId = record
    RelationKey: Integer;
    Key: string;
  end;

//Класс хранит информацию о ключе
type
  TReplKey = class
  private
    FRelationKey: Integer;
    FKeysValues: TStrings;
    FTransaction: TIBTransaction;
    procedure SetRelationKey(const AValue: Integer);
    procedure SetValue(const AValue: String);
    //Для заданного Ид получает РУИД и сохраняет его в потоке
    procedure SaveID(Id: Integer; Stream: TStream);
    //Читает из потока РУИД получает по нему ИД
    function ReadID(Stream: TStream): Integer;
    function GetValue: String;
    function GetKeys: TStrings;
    procedure SetTransaction(const Value: TIBTransaction);
  public
    constructor Create;
    destructor Destroy; override;
    //Сохраняет данные в поток. Все Ид преобразуются в РУИДы
    procedure SaveToStream(Stream: TStream);
    //Считывает данные из потока. Все РУИДы автом. преобразуются в ИД
    function LoadFromStream(Stream: TStream): Boolean;
    //записывает данные в датасет
    //Возвращает кол-во записанных полей
    function SaveToDataSet(DataSet: TDataSet): Integer;
    //Возвращает строку условия
    function GetSelectWhereClause: string;
    function GetModifyWhereClause: string;
    { TODO : Заменить RelationKey и Value на Cortege }
    property RelationKey: Integer read FRelationKey write SetRelationKey;
    property Value: String read GetValue write SetValue;
    property Keys: TStrings read Getkeys;
    property KeysValues: TStrings read FKeysValues;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
  end;

//класс хранит информацию о полях таблицы в целом
type
  TCortege = class
  private
    FTransaction: TIBTransaction;
    FRelationKey: Integer;
    FSelectClause: String;
    FInsertClause: String;
    FModifyClause: string;
    FDeleteClause: string;
    FKey: TReplKey;
    FFieldsData: TObjectList;
    FdsFields: TIBDataSet;
    //имя таблицы
    FRelation: string;
    FOldKey: TReplKey;
    FNewKey: TReplKey;
    procedure SetRelationKey(const Value: Integer);
    procedure SetTransaction(const Value: TIBTransaction);
    function GetTransaction: TIBTransaction;
    //Инициализация СКЛ запросов
    procedure InitSelectClause;
    procedure InitInsertClause;
    procedure InitModifyClause;
    procedure InitDeleteClause;
    procedure InitSQL;
    function GetFields: TStrings;
    function GetRelation: string;
    procedure SetNewKey(const Value: TReplKey);
    procedure SetOldKey(const Value: TReplKey);
  public
    constructor Create;
    destructor Destroy; override;
    //Вставляет новую запись, сохр. информацию и делает пост
    procedure Insert;
    //Изменяет запись, сохр. информацию и делает пост
    procedure UpDate;
    //Удаляет запись
    procedure Delete;
    //удаляет данные из памяти
    procedure Clear;
    //Сохранает данные в поток
    procedure SaveToStream(Stream: TStream);
    //считывает данные из потока
    procedure LoadFromStream(Stream: TStream);
    //считывает данные в память из БД
    procedure ReadFromDB;
    //записывает данные в датасет
    //Возвращает кол-во записанных полей
    function SaveToDataSet(DataSet: TDataSet): Integer;

    property Transaction: TIBTransaction read GetTransaction write SetTransaction;
    property RelationKey: Integer read FRelationKey write SetRelationKey;
    property NewKey: TReplKey read FNewKey write SetNewKey;
    property OldKey: TReplKey read FOldKey write SetOldKey;
    property Fields: TStrings read GetFields;
    property Relation: string read GetRelation;
  end;

//Класс хранит информацию о событии произошедшем в базе
type
  TReplEvent = class
  private
    FSeqno: Integer;
    FDBKey: Integer;
    FRelationKey: Integer;
    FReplKey: Integer;
    FOldKey: TReplKey;
    FNewKey: TReplKey;
    FReplType: String;
    FActionTime: TDateTime;
    FdsReplLog: TIBDataSet;
    procedure SetSeqno(const Value: Integer);
    procedure SetTransaction(const Value: TIBTransaction);
    function GetTransaction: TIBTransaction;
    function GetRelation: String;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ReadFromDataSet(const DataSet: TDataSet);
    procedure SaveToStream(const Stream: TStream);
    procedure LoadFromStream(const Stream: TStream);

    property RelationKey: Integer read FRelationKey;
    property Relation: String read GetRelation;
    property ReplType: String read FReplType;
    property OldKey: TReplKey read FOldKey;
    property NewKey: TReplKey read FNewKey;
    property ReplKey: Integer read FReplKey;
    property ActionTime: TDateTime read FActionTime;
    property DBKey: Integer read FDBKey;
    property Seqno: Integer read FSeqno write SetSeqno;
    property Transaction: TIBTransaction read GetTransaction write SetTransaction;
  end;

type
  TReplicationServer = class(TComponent)
  private
    { Private declarations }
    //База данных
    FDataBase: TIBDataBase;
    //Транзакция на которой производится репликация
    FTransaction: TIBTransaction;
    //Транзакция для отключения и подключения тригеров
    FTriggerTransaction: TIBTransaction;
    //Способ разрешения конфл.
    FErrorDecision: TErrorDecision;
    FReplKey: Integer;  //Для осн. базы хранит ключ репликации
    FDBKey: Integer;  //Для осн. базы хранит ключ базы с которой произв. репликация
    //Хранит статус базы
    FDBState: TDBState;
    //Список отключённых тригеров
    FTrigerList: TTrigerList;
    //Хранит информацию об обрабатываемом событии
    FReplEvent: TReplEvent;
    //Хранит информацию об обрабатываемой записи
    FCortege: TCortege;
    FPassWord: string;
    FUser: string;
    FDataBaseName: string;
    //ДатаСет с помощью которого будем формировать список репле
    //цируемых событий
    FdsReplLog: TIBDataSet;
    //ДатаСет с помощью которого будем регистрировать
    //информацию о репликации с базой
    FdsLogHist: TIBDataSet;
    // Создать файл экспорта для второстепенной БД
    function CreateExportFile : Boolean;
    //Производит репликацию переданного файла
    function ReplicationFile: Boolean;
    // Обработать импортный файл для второстепенной БД
    function ProcessImportFile : Boolean;
    //Сохраняет данные экспорта в поток
    function DoExport(Stream: TStream): Boolean;
    // Осуществляет обработку файла второстепенной БД, и подготавливает
    //обратный файл для отправки на последнюю. Этот метод вызывается
    //только для главной БД.
    function DoReplication(const FromStream, ToStream: TStream) : Boolean;
    // Обработать импортный файл для второстепенной БД
    function DoProcessImport(const Stream: TStream): Boolean;
    // Позволяет синхронизировать данные между двумя произвольными
    //таблицами. К процесу репликации отношения не имеет. На данный
    //момент реализовывать не надо.
    function Synchronize : Boolean;
    //Процедура подготавливает dsReplLog в котором есть все изменения
    //с учетом их приоритета. Т.е. если с момента последней репл.
    //в базу была вставлена запись и потом изменена то в ДатаСете
    //будет информация только о вставке. Если запись была вставлена,
    //изменена и удалена то в ДатаСете информации о данной записи вообще
    //небудет. Вся информация из таблица REPL_LOG с более низким
    //приоперетом будет удалена
    procedure PrepareSecondBaseReplLog;
    //Процедура подготавливает dsReplLog в котором есть все изменения
    //произошедшие со времени последней репликации с данной базой
    procedure PreparePrimaryBaseReplLog(const DBID: Integer);
    //Отключает все активные тригеры
    function InActiveTrigers: Boolean;
    //Включает все тригера отключ. функцией InActiveTrigers
    function ActiveTrigers: Boolean;
    //Возвращает True если репликация с данным ключем для
    //данной базы уже производилась.
    function IsReplicated(const DBID, ReplKey: Integer): Boolean;
    //Возвращает True если файл с данными уже импортировался
    function IsImported(ReplKey: Integer): Boolean;
    //Увеличиваем текущее значение ключа репликации на 1
    //Возвращается новое значение ключа
    function IncReplId: Integer;
    //Возвращает текущее значение генератора ключа репликации
    function GetReplId: Integer;
    //Возвращает текущее значение генератора ключа событий
    function GetSeqNo: Integer;
    //Увеличивает текущее значение генератора ключа событий на 1
    function IncSeqNo: Integer;
    //Разрешение конфликтных ситуаций
    //dsReplLog должен указывать на ту записи в RPL_LOG для
    //обнаружен конфликт
    function Settlement: Boolean;
    function SettlementPriority: Boolean;
    function SettlementTime: Boolean;
    function SettlementManual: Boolean;
    function SettlementServer: Boolean;
    //Возвращает Тру если в журнале событий есть информация о от
    //что была запись с данным ИД была изменена.
    function RecordChanged(const Key: String; const ReplKey, DBID: Integer): Boolean;
    //Сравнивает приоритеты двух баз данных и возвращает Тру если
    //у первой он больше
    function ComparePriority(const ADBkey, BDBKey: Integer): Boolean;
    //Вставляет новую запись в RPL_LOGHIST и делает пост
    procedure InsertLogHist(ASeqNo, ADBKey, AReplKey: Integer);
    //Регистрация изменений
    procedure Log;
    //Проверяет табл. RPL_MANUAL на наличие записей.
    //Если записи есть то необходима дальнейшее разрешение конфликтов
    function Settlemented: Boolean;
    //Удаляет записи из РПЛ_ЛОГ и РПЛ_ЛОГИСТ для которых произво
    //дилась репликация со всеми базами
    procedure Pack;
    procedure PackPrimaryBase;
    procedure PackSecondBase;
    //Возвращает ТРУ если второстепенная база находится в
    //состоянии ожидания ответного файла с главной базы
    function GetInReplication: Boolean;
    //Возвращает список имен полей обрзующих примари кей
    procedure GetPrimaryFieldList(const RelationKey: Integer;
      const FieldList: TStrings);
    //Возвращает статус поля
    function GetDBState: TDBState;

    property InReplication: Boolean read GetInReplication;
    procedure SetDataBaseName(const Value: string);
    procedure SetPassWord(const Value: string);
    procedure SetUser(const Value: string);
  public
    constructor Create;
    destructor Destroy;
    // Подключение в обнопользовательском режиме
    procedure Login;
    // Отключение
    procedure Logoff;
  published
    { Published declarations }
    property DataBaseName: string read FDataBaseName write SetDataBaseName;
    property PassWord: string read FPassWord write SetPassWord;
    property User: string read FUser write SetUser;
  end;

//возвращает имя таблицы по ид
function GetRelationName(const Id: Integer): String;
//сохраняет метку в поток
procedure SaveLabelToStream(lb: TLabelStream; Stream: TStream);
//сохраняет строку в поток
procedure SaveStringToStream(Str: String; Stream: TStream);
//читает строку из потока
function ReadStringFromStream(Stream: TStream): string;
//проверяет метку в потоке
procedure CheckLabel(const Lb: TLabelStream; const Stream: TStream);
//Возвращает РУИД для данного ИД. если его нет то создает новый
function GetRUID(ID: Integer; Transaction: TIBTransaction): TRUID;
//сохраняет РУИД в поток
procedure SaveRUIDToStream(const RUID: TRUID;
  const Stream: TStream);
//Читает РУИД из потока
procedure ReadRUIDFromStream(var RUID: TRUID;
  const Stream: TStream);
//Возвращает ИД базы
function GetDBID(Transaction: TIBTransaction): Integer;
//Для даного РУИДа возвращает ИД. если его нет то возвращает уникальный ИД
function GetID(const RUID: TRUID; Transaction: TIBTransaction): Integer;
//возвращает уникальный ИД
function GetUniqueID(Transaction: TIBTransaction): Integer;
//Регестрирует РУИД и ИД в БД
procedure AddRUID(const Id: Integer; const RUID: TRUID;
  Transaction: TIBTransaction);
//Декодирует строку содерж. примари кей в список строк.
//в каждой строке содержится отдельный ключ
procedure KeyDecoder(const Key: string; const Keys: TStrings);
//Кодирует ключ
function KeyCoder(const Keys: TStrings): string;

procedure Register;

implementation
uses gsDatabaseShutdown, gd_directories_const, Registry;

var
  Relations: TReplRelations;
const
  RELATION_LABEL = 'RELb';
  FIELD_NAME_LABEL = 'FNLb';
  FIELD_DATA_LABEL = 'FDLb';
  ROLLBACK = 'RLBK';
  REPL_LOG_LIST = 'RLLT';
  REPL_EVENT = 'RLEV';
  REPL_KEY = 'RLKY';
  LblSize = SizeOf(TLabelStream);

const
  MSG_INFORMATION = 'Информация';
  MSG_NO_DATA_CHANGE = 'Со времени последней репликации в базе'#13#10 +
    'данных изменений небыло';
  MSG_DB_ALLREADY_REPLICATED = 'База данных уже реплецирована';
  MSG_WRONG_DATA = 'Ошибочные данные';
  MSG_CANT_FIND_RELATION = 'Нет таблицы с таким ID';
  MSG_STREAM_DO_NOT_INIT = 'Поток неинициализирован';
  MSG_TRANSACTION_DO_NOT_ASSIGNED = 'Транзикция неинициализирована';
  MSG_DATASET_NOT_IN_EDIT_MODE = 'ДатаСет не в режиме редактирования';

function KeyCoder(const Keys: TStrings): string;
var
  I: Integer;
begin
  Result := '';
  if not Assigned(Keys) then
    raise Exception.Create('Список неинициализирован');

  if Keys.Count > 0 then
  begin
    Result := Keys[0];
  for I := 1 to Keys.Count - 1 do
    Result := Result + '|' + Keys[I];
  end;
end;

procedure KeyDecoder(const Key: string; const Keys: TStrings);
var
  Str: String;
begin
  if not Assigned(Keys) then
    raise Exception.Create('Список неинициализирован');
  Keys.Clear;
  Str := Key;
  while Pos('|', Str) > 0 do
  begin
    Keys.Add(Copy(Str, 1, Pos('|', Str) - 1));
    Delete(Str, 1, Pos('|', Str));
  end;
  if Length(Str) > 0 then
    Keys.Add(Str);
end;

procedure AddRUID(const Id: Integer; const RUID: TRUID;
  Transaction: TIBTransaction);
var
  dsRUID: TIBDataSet;
begin
  dsRUID := TIBDataSet.Create(nil);
  try
    dsRUID.Transaction := Transaction;
    dsRUID.SelectSQL.Text := 'SELECT * FROM GD_RUID WHERE id = :id';
    dsRUID.InsertSQL.Text := 'INSERT INTO  gd_ruid (ID, XID, DBID, ' +
      'MODIFIED, EDITORKEY) VALUES(:ID, :XID, :DBID, :MODIFIED, :EDITORKEY)';
    dsRUID.ParamByName('id').AsInteger := Id;
    dsRUID.Open;
    if dsRUID.IsEmpty then
    begin
      dsRUID.Insert;
      try
        dsRUID.FieldByName(fnId).AsInteger := Id;
        dsRUID.FieldByName(fnXId).AsInteger := RUID.XID;
        dsRUID.FieldByName(fnDBID).AsInteger := RUID.DBID;
        dsRUID.FieldByName(fnModified).AsDateTime := Now;
        dsRUID.Post;
      except
        dsRUID.Cancel;
        raise
      end;
    end else
      raise Exception.Create('РУИД для данного ид уже существует');
  finally
    dsRUID.Free;
  end;
end;

function GetUniqueID(Transaction: TIBTransaction): Integer;
var
  dsUniqueId: TIBSQL;
begin
  dsUniqueId := TIBSQL.Create(nil);
  try
    dsUniqueId.SQL.Text :=
      'SELECT GEN_ID(GD_G_UNIQUE, 1) + GEN_ID(gd_g_offset, 0) FROM RDB$DATABASE';
    dsUniqueId.Transaction := Transaction;
    dsUniqueId.ExecQuery;
    Result := dsUniqueId.Fields[0].AsInteger;
  finally
    dsUniqueId.Free;
  end;
end;

function GetID(const RUID: TRUID; Transaction: TIBTransaction): Integer;
var
  DataSet: TIBDataSet;
begin
  DataSet := TIBDataSet.Create(nil);
  try
    DataSet.Transaction := Transaction;
    DataSet.SelectSQL.Text := 'SELECT * FROM gd_RUID WHERE ' +
      'xid = ' + IntToStr(RUID.XID) + ' AND dbid = ' + IntToStr(RUID.DBID);
    DataSet.Open;
    if not DataSet.IsEmpty then
      Result := DataSet.FieldbyName(fnId).AsInteger
    else
    begin
      {Если для данного РУИДа нет ид то получам уникальный
      ид и регестрируем ИД и РУИД в БД}
      Result := GetUniqueID(Transaction);
      AddRUID(Result, RUID, Transaction);
    end;
  finally
    DataSet.Free;
  end;
end;

procedure ReadRUIDFromStream(var RUID: TRUID;
  const Stream: TStream);
begin
  if not Assigned(Stream) then
    raise Exception.Create('Поток неинициализирован');

  {Записываем в поток РУИД записи}
  Stream.ReadBuffer(RUID.XID, SizeOF(RUID.XID));
  Stream.ReadBuffer(RUID.DBID, SizeOf(RUID.DBID));
end;

function GetDBID(Transaction: TIBTransaction): Integer;
var
  dsDBID: TIBDataSet;
begin
  //Получаем ИД базы
  dsDBID := TIBDataSet.Create(nil);
  try
    dsDBID.Transaction := Transaction;
    dsDBID.SelectSQL.Text := 'SELECT gen_id(GD_G_DBID, 0) AS dbid ' +
      'FROM RDB$DATABASE';
    dsDBID.Open;
    Result := dsDBID.FieldByName(fnDBID).AsInteger;
  finally
    dsDBID.Free;
  end;
end;

function GetRelationName(const Id: Integer): String;
begin
  if Assigned(Relations) then
    Result := Relations[ID].Relation;
end;

procedure SaveRUIDToStream(const RUID: TRUID;
  const Stream: TStream);
begin
  if not Assigned(Stream) then
    raise Exception.Create('Поток неинициализирован');

  {Записываем в поток РУИД записи}
  Stream.WriteBuffer(RUID.XID, SizeOF(RUID.XID));
  Stream.WriteBuffer(RUID.DBID, SizeOf(RUID.DBID));
end;

procedure SaveLabelToStream(lb: TLabelStream; Stream: TStream);
begin
  Stream.WriteBuffer(Lb, LblSize);
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
  Str: String;
begin
  Stream.ReadBuffer(L, SizeOf(L));
  SetLength(str, L);
  Stream.ReadBuffer(str[1], L);
  Result := Str;
end;

procedure CheckLabel(const Lb: TLabelStream; const Stream: TStream);
var
  LocLb: TLabelStream;
begin
  Stream.ReadBuffer(LocLb, LblSize);
  if LocLb <> Lb then
    raise Exception.Create(MSG_WRONG_DATA);
end;

procedure Register;
begin
  RegisterComponents('gsReplication', [TReplicationServer]);
end;

{ TReplKey }

constructor TReplKey.Create;
begin
  FKeysValues := TStringList.Create;
end;

destructor TReplKey.Destroy;
begin
  FKeysValues.Free;
  inherited;
end;

function GetRUID(ID: Integer; Transaction: TIBTransaction): TRUID;
var
  dsRUID: TIBDataSet;
begin
  Result.XID := - 1;
  Result.DBID := - 1;
  {Ищем РУИД для данного ключа}

  dsRUID := TIBDataSet.Create(nil);
  try
    dsRUID.Transaction := Transaction;
    dsRUID.SelectSQL.Text := 'SELECT * FROM GD_RUID WHERE id = :id';
    dsRUID.InsertSQL.Text := 'INSERT INTO  gd_ruid (ID, XID, DBID, ' +
      'MODIFIED, EDITORKEY) VALUES(:ID, :XID, :DBID, :MODIFIED, :EDITORKEY)';
    dsRUID.ParamByName(fnId).AsInteger := Id;
    dsRUID.Open;
    if dsRUID.IsEmpty then
    begin
      {Если для данного ключа нет RUIDа то создаем его}
      dsRUID.Insert;
      try
        dsRUID.FieldByName(fnId).AsInteger := Id;
        dsRUID.FieldByName(fnXId).AsInteger := ID;
        dsRUID.FieldByName(fnDBID).AsInteger := GetDBID(Transaction);
        dsRUID.FieldByName(fnModified).AsDateTime := Now;
        dsRUID.Post;
      except
        dsRUID.Cancel;
        raise
      end;
    end;
    Result.XID := dsRUID.FieldByName(fnXId).AsInteger;
    Result.DBID := dsRUID.FieldByName(fnDBID).AsInteger;
  finally
    dsRUID.Free;
  end;
end;


function TReplKey.GetValue: String;
begin
  Result := KeyCoder(FKeysValues);
end;

function TReplKey.GetSelectWhereClause: string;
var
  I: Integer;
begin
  Result := '';
  Assert((FKeysValues.Count = Keys.Count) or (Value = ''),
    'Несоответствие количиства полей и кол-ва параметров');
  Result := keys.Names[0] + '= ''' + FKeysValues[0] + '''';
  for I := 1 to Keys.Count - 1 do
    Result := Result + ' AND ' + Keys.Names[I] + '= ''' +
      FKeysValues[I] + '''';
end;

function TReplKey.LoadFromStream(Stream: TStream): Boolean;
var
  I: Integer;
  Count: Integer;
  ARelationKey: Integer;
begin
  FKeysValues.Clear;

  //проверяем метку
  CheckLabel(REPL_KEY, Stream);
  //кол-во полей
  Stream.ReadBuffer(Count, SizeOf(Count));
  for I := 0 to Count - 1 do
  begin
    //Если поле имеет тип integer то сохраняем РУИД
    //Если нет то сохраняем значение
    if Keys.Values[Keys.Names[I]] = '8' then
      FKeysValues.Add(IntToStr(ReadID(Stream)))
    else
      FKeysValues.Add(ReadStringFromStream(Stream));
  end;
end;

function TReplKey.ReadID(Stream: TStream): Integer;
var
  RUID: TRUID;
begin
  ReadRUIDFromStream(RUID, Stream);
  Result := GetID(RUID, Transaction);
end;

procedure TReplKey.SaveID(Id: Integer; Stream: TStream);
var
  RUID: TRUID;
begin
  RUID := GetRUID(Id, Transaction);
  SaveRUIDToStream(RUID, Stream);
end;

function TReplKey.SaveToDataSet(DataSet: TDataSet): Integer;
var
  I: Integer;
begin
  if not (DataSet.State in [dsEdit, dsInsert]) then
    raise Exception.Create(MSG_DATASET_NOT_IN_EDIT_MODE);

  for I := 0 to Keys.Count - 1 do
  begin
    DataSet.FieldByName(Keys.Names[I]).Value :=
      FKeysValues[I];
  end;
  Result := Keys.Count;
end;

procedure TReplKey.SaveToStream(Stream: TStream);
var
  I: Integer;
  Count: Integer;
begin
  Assert((FKeysValues.Count = Keys.Count) or (Value = ''),
    'Несоответствие количиства полей и кол-ва параметров');
  //метка
  SaveLabelToStream(REPL_KEY, Stream);
  Count := Keys.Count;
  //кол-во полей
  Stream.WriteBuffer(Count, SizeOf(Count));
  for I := 0 to Keys.Count - 1 do
  begin
    //Если поле имеет тип integer то сохраняем РУИД
    //Если нет то сохраняем значение
    if Keys.Values[Keys.Names[I]] = '8' then
      SaveID(StrToInt(FKeysValues[I]), Stream)
    else
      SaveStringToStream(FKeysValues[I], Stream);
  end;
end;

procedure TReplKey.SetRelationKey(const AValue: Integer);
begin
  if FRelationKey <> AValue then
  begin
    FRelationKey := AValue;
    if not Assigned(Relations) then
      raise Exception.Create(MSG_TRANSACTION_DO_NOT_ASSIGNED);
      
  end;
end;

function TReplKey.GetModifyWhereClause: string;
var
  I: Integer;
begin
  Result := '';
  Result := Keys.Names[0] + '= :old_' + Keys.Names[0];
  for I := 1 to Keys.Count - 1 do
    Result := Result + ' AND ' + Keys.Names[I] + '= :old_' +
      Keys.Names[I];
end;

function TReplKey.Getkeys: TStrings;
begin
  if Assigned(Relations) then
    Result := Relations[FRelationKey].Keys;
end;

procedure TReplKey.SetTransaction(const Value: TIBTransaction);
begin
  FTransaction := Value;
end;

procedure TReplKey.SetValue(const AValue: String);
begin
  KeyDecoder(AValue, FKeysValues);
end;

{ TTrigerList }

function TTrigerList.Add(Item: TTrigger): Integer;
var
  TR: PTrigger;
begin
  New(TR);
  TR^ := Item;
  Result := inherited Add(TR);
end;

procedure TTrigerList.Clear;
begin
  while Count > 0 do
    Delete(Count - 1);
  inherited;
end;

procedure TTrigerList.Delete(Index: Integer);
begin
  Dispose(PTrigger(inherited Items[Index]));
  inherited;
end;

function TTrigerList.Get(Index: Integer): TTrigger;
begin
  Result := TTrigger(inherited Items[Index]^);
end;

function TTrigerList.Last: TTrigger;
begin
  Result := Items[Count -1];
end;

procedure TTrigerList.Put(Index: Integer; const Value: TTrigger);
begin
  TTrigger(inherited Items[Index]^) := Value;
end;

procedure TTrigerList.ReadFromStream(Stream: TStream);
begin
  raise Exception.Create('sdfgfdg');
end;

procedure TTrigerList.SaveToStream(Stream: TStream);
begin
  raise Exception.Create('sdfgfdg');
end;

{ TReplEvent }

constructor TReplEvent.Create;
begin
  FdsReplLog := TIBDataSet.Create(nil);
  FdsReplLog.SelectSQL.Text := 'SELECT rl.* FROM rpl_log rl ' +
    'WHERE rl.seqno = :seqno';
  FNewKey := TReplKey.Create;
  FOldKey := TReplKey.Create
end;

destructor TReplEvent.Destroy;
begin
  FdsReplLog.Free;
  FNewKey.Free;
  FOldKey.Free;

  inherited;
end;

function TReplEvent.GetRelation: String;
begin
  if Assigned(Relations) then
    Result := Relations[FRelationKey].Relation;
end;

function TReplEvent.GetTransaction: TIBTransaction;
begin
  Result := FdsReplLog.Transaction;
end;


procedure TReplEvent.LoadFromStream(const Stream: TStream);
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  CheckLabel(REPL_EVENT , Stream);
  Stream.ReadBuffer(FSeqno, SizeOf(Seqno));
  Stream.ReadBuffer(FRelationKey, SizeOf(FRelationKey));
  FOldKey.RelationKey := FRelationKey;
  FNewKey.RelationKey := FrelationKey;
  Stream.ReadBuffer(FReplKey, SizeOf(FReplKey));
  FReplType := ReadStringFromStream(Stream);
  FOldKey.LoadFromStream(Stream);
  FNewKey.LoadFromStream(Stream);
  Stream.ReadBuffer(FActionTime, SizeOf(FActionTime));
  Stream.ReadBuffer(FDBKey, SizeOf(FDBKey));
end;


procedure TReplEvent.ReadFromDataSet(const DataSet: TDataSet);
begin
  FRelationKey := DataSet.FieldByName(fnRelationKey).AsInteger;
  FNewKey.RelationKey := FRelationKey;
  FOldKey.RelationKey := FRelationKey;
  FReplType := DataSet.FieldByName(fnReplType).AsString;
  if FReplType = atInsert then
  begin
    FNewKey.Value := DataSet.FieldByName(fnNewKey).AsString;
    FOldKey.Value := DataSet.FieldByName(fnNewKey).AsString;
  end else
  if FReplType = atUpdate then
  begin
    FOldKey.Value := DataSet.FieldByName(fnOldKey).AsString;
    FNewKey.Value := DataSet.FieldByName(fnNewKey).AsString;
  end else
  begin
    FNewKey.Value := DataSet.FieldByName(fnOldKey).AsString;
    FOldKey.Value := DataSet.FieldByName(fnOldKey).AsString;
  end;
  FReplKey := DataSet.FieldByName(fnReplKey).AsInteger;
  FActionTime := DataSet.FieldByName(fnActionTime).AsDateTime;
  FDBKey := DataSet.FieldByName(fnDBKey).AsInteger;
  FSeqno := DataSet.FieldByName(fnSeqno).AsInteger;
end;

procedure TReplEvent.SaveToStream(const Stream: TStream);
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  SaveLabelToStream(REPL_EVENT , Stream);
  Stream.WriteBuffer(FSeqno, SizeOf(Seqno));
  Stream.WriteBuffer(FRelationKey, SizeOf(FRelationKey));
  Stream.WriteBuffer(FReplKey, SizeOf(FReplKey));
  SaveStringToStream(FReplType, Stream);
  FOldKey.SaveToStream(Stream);
  FNewKey.SaveToStream(Stream);
  Stream.WriteBuffer(FActionTime, SizeOf(FActionTime));
  Stream.WriteBuffer(FDBKey, SizeOf(FDBKey));
end;

procedure TReplEvent.SetSeqno(const Value: Integer);
begin
  if FSeqno <> Value then
  begin
    if Assigned(Transaction) then
    begin
      FdsReplLog.ParamByName(fnSeqNo).AsInteger := Value;
      FdsReplLog.Open;
      ReadFromDataSet(FdsReplLog);
      FdsReplLog.Close;
      FSeqno := Value;
    end else
      raise Exception.Create(MSG_TRANSACTION_DO_NOT_ASSIGNED);
  end;
end;

procedure TReplEvent.SetTransaction(const Value: TIBTransaction);
begin
  FdsReplLog.Transaction := Value;
  FNewKey.Transaction := Value;
  FOldKey.Transaction := Value;
end;

{ TCortege }

constructor TCortege.Create;
begin
  FKey := TReplKey.Create;
  FFieldsData := TObjectList.Create(True);
  FdsFields := TIBDataSet.Create(nil);
end;

destructor TCortege.Destroy;
begin
  FKey.Free;
  FFieldsData.Free;
  FdsFields.Free;
  inherited;
end;


function TCortege.GetTransaction: TIBTransaction;
begin
  Result := FdsFields.Transaction;
end;

procedure TCortege.LoadFromStream(Stream: TStream);
var
  I, Count, Size: Integer;
  DataStream: TMemoryStream;
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

//  FKey.LoadFromStream(Stream);
  CheckLabel(FIELD_DATA_LABEL, Stream);

  Clear;

  Stream.ReadBuffer(Count, SizeOf(Count));
  for I := 0 to Count - 1 do
  begin
    DataStream := TMemoryStream.Create;
    FFieldsData.Add(DataStream);
    Stream.ReadBuffer(Size, SizeOf(Size));
    if Size > 0 then
      DataStream.CopyFrom(Stream, Size);
  end;
end;

procedure TCortege.SaveToStream(Stream: TStream);
var
  Count, Size: Integer;
  I: Integer;
  BlobeStream: TStream;
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  ReadFromDB;

//  FNewKey.SaveToStream(Stream);
  SaveLabelToStream(FIELD_DATA_LABEL, Stream);

  //Сохраняем кол-во сохраняемых полей
  Count := FFieldsData.Count;
  Stream.WriteBuffer(Count, SizeOf(Count));

  for I := 0 to Count - 1 do
  begin
    TStream(FFieldsData[I]).Position := 0;
    Size := TStream(FFieldsData[I]).Size;
    Stream.WriteBuffer(Size, SizeOf(Size));
    if Size > 0 then
      Stream.CopyFrom(TStream(FFieldsData[I]), Size);
  end;
end;

procedure TCortege.SetRelationKey(const Value: Integer);
begin
  if FRelationKey <> Value then
    FRelationKey := Value;
end;

procedure TCortege.SetTransaction(const Value: TIBTransaction);
begin
  FdsFields.Transaction := Value;
end;

procedure TCortege.ReadFromDB;
var
  I, Size : Integer;
  Stream, BlobeStream: TStream;
  IntBuf: Integer;
  FloatBuf: Double;
  StringBuf: string;
  DateTimeBuf: TDateTime;
begin
  Clear;
  InitSQL;
  FdsFields.Open;
  {Если запись была удалена или изменен ключ то запись
  не будет найдена и значит ничего делать ненадо}
  try
    if not FdsFields.IsEmpty then
    begin
      for I := 0 to Fields.Count - 1 do
      begin
        Stream := TMemoryStream.Create;
        FFieldsData.Add(Stream);
        case StrToInt(Fields.Values[Fields.Names[I]]) of
          7, 8, 9:
          begin
            if not FdsFields.FieldByName(Fields.Names[I]).IsNull then
            begin
              IntBuf := FdsFields.FieldByName(Fields.Names[I]).AsInteger;
              Stream.WriteBuffer(IntBuf, SizeOf(IntBuf));
            end;
          end;
          10, 11, 27:
          begin
            if not FdsFields.FieldByName(Fields.Names[I]).IsNull then
            begin
              FloatBuf := FdsFields.FieldByName(Fields.Names[I]).AsFloat;
              Stream.WriteBuffer(FloatBuf, SizeOf(FloatBuf));//с плав. точкой
            end;
          end;
          14, 37:
          begin
            if not FdsFields.FieldByName(Fields.Names[I]).IsNull then
            begin
              StringBuf := FdsFields.FieldByName(Fields.Names[I]).AsString;
              SaveStringToStream(StringBuf, Stream);//строковое
            end;
          end;
          12:
          begin
            if not FdsFields.FieldByName(Fields.Names[I]).IsNull then
            begin
              DateTimeBuf := FdsFields.FieldByName(Fields.Names[I]).AsDateTime;//время
              Stream.WriteBuffer(DateTimeBuf, SizeOf(DateTimeBuf));
            end;
          end;
          261:
          begin
            if not FdsFields.FieldByName(Fields.Names[I]).IsNull then
            begin
              BlobeStream := FdsFields.CreateBlobStream(FdsFields.FieldByName(Fields.Names[I]),
                bmReadWrite);
              try
                {Сохраняем длинну потока}
                Size := BlobeStream.Size;
                Stream.WriteBuffer(Size, SizeOf(Size));
                Stream.CopyFrom(BlobeStream, Size);
              finally
                BlobeStream.Free;
              end;
            end;
          end;
        end;
      end;
    end;
  finally
    FdsFields.Close;
  end;
end;

procedure TCortege.Clear;
begin
  FFieldsData.Clear;
end;

function TCortege.SaveToDataSet(DataSet: TDataSet): Integer;
var
  I: Integer;
  BlobeStream: TStream;
  Size: Integer;
  IntBuf: Integer;
  FloatBuf: Double;
  StringBuf: string;
  DateTimeBuf: TDateTime;
begin
  { TODO :
  Если кол-во потоков данных равно нулю то выходим.
  Хотя это может быть и неправильно }
{  if FFieldsData.Count = 0 then
  begin
    Result := 0;
    Exit;
  end;}
  //Записываю примари кеу
  Result := FNewKey.SaveToDataSet(DataSet);
  Result := 0;
  //записываю данные
  for I := 0 to FFieldsData.Count - 1 do
  begin
    TStream(FFieldsData[I]).Position := 0;
    case StrToInt(Fields.Values[Fields.Names[I]]) of
      7, 8, 9:
      begin
        if TStream(FFieldsData[I]).Size > 0 then
        begin
          TStream(FFieldsData[I]).ReadBuffer(IntBuf, SizeOf(IntBuf));
          DataSet.FieldByName(Fields.Names[I]).AsInteger :=
            IntBuf;
        end;
      end;
      10, 11, 27:
      begin
        if TStream(FFieldsData[I]).Size > 0 then
        begin
          TStream(FFieldsData[I]).ReadBuffer(FloatBuf, SizeOf(FloatBuf));
          DataSet.FieldByName(Fields.Names[I]).AsFloat :=
            FloatBuf;
        end;
      end;
      14, 37:
      begin
        if TStream(FFieldsData[I]).Size > 0 then
        begin
          StringBuf := ReadStringFromStream(TStream(FFieldsData[I]));
          DataSet.FieldByName(Fields.Names[I]).AsString :=
            StringBuf;//строковое
        end;
      end;
      12:
      begin
        if TStream(FFieldsData[I]).Size > 0 then
        begin
          TStream(FFieldsData[I]).ReadBuffer(DateTimeBuf, SizeOf(DateTimeBuf));
          FdsFields.FieldByName(Fields.Names[I]).AsDateTime := DateTimeBuf;//время
        end;
      end;
      261:
      begin
        if TStream(FFieldsData[I]).Size > 0 then
        begin
          BlobeStream := FdsFields.CreateBlobStream(FdsFields.FieldByName(Fields.Names[I]), bmReadWrite);
          try
            {Сохраняем длинну потока}
            TStream(FFieldsData[I]).ReadBuffer(Size, SizeOf(Size));
            BlobeStream.Size := 0;
            BlobeStream.CopyFrom(TStream(FFieldsData[I]), Size);
          finally
            BlobeStream.Free;
          end;
        end;
      end;
    end;
    Inc(Result);
  end;
end;

procedure TCortege.Delete;
begin
  InitSQL;
  FdsFields.Open;
  {Если запись была удалена или изменен ключ то запись
  не будет найдена и значит ничего делать ненадо}
  try
    if not FdsFields.IsEmpty then
    begin
      FdsFields.Delete;
    end else
    begin
      //raise Exception.Create('Записи нет');
    end;
  finally
    FdsFields.Close;
  end;
end;

procedure TCortege.Insert;
begin
  InitSQL;
  FdsFields.Open;
  {Если запись была удалена или изменен ключ то запись
  не будет найдена и значит ничего делать ненадо}
  try
    if FdsFields.IsEmpty then
    begin
      FdsFields.Insert;
    end else
    begin
      //raise Exception.Create('Запись уже существует');
      FdsFields.Edit;
    end;
    try
      if SaveToDataSet(FdsFields) > 0 then
        FdsFields.Post;
    except
      FdsFields.Cancel;
      raise;
    end;
  finally
    FdsFields.Close;
  end;
end;

procedure TCortege.UpDate;
begin
  InitSQL;
  FdsFields.Open;
  {Если запись была удалена или изменен ключ то запись
  не будет найдена и значит ничего делать ненадо}
  try
    if not FdsFields.IsEmpty then
    begin
      FdsFields.Edit;
    end else
    begin
      //raise Exception.Create('Записи нет');
      FdsFields.Insert;
    end;
    if SaveToDataSet(FdsFields) > 0 then
      FdsFields.Post;
  finally
    FdsFields.Close;
  end;
end;

procedure TCortege.InitDeleteClause;
begin
  FDeleteClause := 'DELETE FROM ' + Relation + ' WHERE ' +
    FOldKey.GetSelectWhereClause;
end;

procedure TCortege.InitInsertClause;
var
  I: Integer;
  AFields, Values: string;
begin
  FInsertClause := '';
  if Fields.Count > 0 then
  begin
    AFields := ' (' + Fields.Names[0];
    Values := ' (:' + Fields.Names[0];
    for I := 1 to Fields.Count - 1 do
    begin
      AFields := AFields + ', ' + Fields.Names[I];
      Values := Values + ', :' + Fields.Names[I];
    end;
    for I := 0 to FOldKey.Keys.Count - 1 do
    begin
      AFields := AFields + ', ' + FOldKey.Keys.Names[I];
      Values := Values + ', :' + FOldKey.Keys.Names[I];
    end;
    AFields := AFields + ')';
    Values := Values + ')';
    FInsertClause := 'INSERT INTO ' + Relation + AFields + ' VALUES ' +
      Values;
  end;
end;

procedure TCortege.InitModifyClause;
var
  I: Integer;
  AFields: string;
begin
  FModifyClause := '';
  if Fields.Count > 0 then
  begin
    AFields := AFields + Fields.Names[0] + ' = :new_' + Fields.Names[0];
    for I := 1 to Fields.Count - 1 do
      AFields := AFields + ' , ' + Fields.Names[I] + ' = :new_' + Fields.Names[I];
    FModifyClause := 'UPDATE ' + Relation + ' SET ' + AFields +
      ' WHERE ' + FOldKey.GetModifyWhereClause;
  end;
end;

procedure TCortege.InitSelectClause;
begin
  FSelectClause := 'SELECT * FROM ' + Relation + ' WHERE ' +
    FOldKey.GetSelectWhereClause;
end;

procedure TCortege.InitSQL;
begin
  InitSelectClause;
  InitInsertClause;
  InitModifyClause;
  InitDeleteClause;
  FdsFields.SelectSQL.Text := FSelectClause;
  FdsFields.InsertSQL.Text := FInsertClause;
  FdsFields.ModifySQL.Text := FModifyClause;
  FdsFields.DeleteSQL.Text := FDeleteClause;
end;

function TCortege.GetFields: TStrings;
begin
  if Assigned(Relations) then
  begin
    Result := Relations[FRelationKey].Fields;
  end;
end;

function TCortege.GetRelation: string;
begin
  if Assigned(Relations) then
    Result := Relations[FRelationKey].Relation;
end;

procedure TCortege.SetNewKey(const Value: TReplKey);
begin
  FNewKey := Value;
end;

procedure TCortege.SetOldKey(const Value: TReplKey);
begin
  FOldKey := Value;
end;

{ TReplRelation }

constructor TReplRelation.Create;
begin
  inherited;
  FKeys := TStringList.Create;
  FFields := TStringList.Create;
end;

destructor TReplRelation.Destroy;
begin
  FKeys.Free;
  FFields.Free;
end;


procedure TReplRelation.SetID(const Value: Integer);
var
  DataSet: TIBDataSet;
begin
  if FID <> Value then
  begin
    FID := Value;
    Fields.Clear;
    Keys.Clear;
    DataSet := TIBDataSet.Create(nil);
    try
      DataSet.Transaction := FTransaction;
      DataSet.SelectSQL.Text := 'SELECT k.fieldname as name, f.rdb$field_type  as ftype ' +
        'FROM rdb$fields f, rdb$relation_fields rf, rpl_relations r, rpl_fields k ' +
        'WHERE rf.rdb$relation_name = r.relation AND ' +
        'rf.RDB$FIELD_NAME = k.fieldname AND ' +
        'rf.RDB$FIELD_SOURCE = f.RDB$FIELD_NAME and k.relationkey = r.id and ' +
        'r.id = ' + IntToStr(Value) + 'ORDER BY k.fieldorder';
      DataSet.Open;
      while not DataSet.Eof do
      begin
        Fields.Add(DataSet.FieldByName('name').AsString + '=' +
          IntToStr(DataSet.FieldByName('ftype').AsInteger));
        DataSet.Next;
      end;
      DataSet.Close;
      DataSet.SelectSQL.Text := 'SELECT k.keyname as name, f.rdb$field_type  as ftype ' +
        'FROM rdb$fields f, rdb$relation_fields rf, rpl_relations r, rpl_keys k ' +
        'WHERE rf.rdb$relation_name = r.relation AND ' +
        'rf.RDB$FIELD_NAME = k.keyname AND ' +
        'rf.RDB$FIELD_SOURCE = f.RDB$FIELD_NAME and k.relationkey = r.id and ' +
        'r.id = ' + IntToStr(Value) + 'ORDER BY k.keyorder';
      DataSet.Open;
      while not DataSet.Eof do
      begin
        Keys.Add(DataSet.FieldByName('name').AsString + '=' +
          IntToStr(DataSet.FieldByName('ftype').AsInteger));
        DataSet.Next;
      end;
    finally
      DataSet.Free;
    end;
  end;
end;

procedure TReplRelation.SetTransaction(const Value: TIBTransaction);
begin
  FTransaction := Value;
end;

{ TReplRelations }

function TReplRelations.Add(Relation: TReplRelation): Integer;
begin
  Result := FList.Add(Relation);
end;

procedure TReplRelations.Clear;
begin
  FList.Clear;
end;

constructor TReplRelations.Create;
begin
  inherited;
  FList := TObjectList.Create(True);
  FdsRelations := TIBDataSet.Create(nil);
  FdsRelations.SelectSQL.Text := 'SELECT * FROM rpl_relations';
end;

procedure TReplRelations.Delete(Index: Integer);
begin
  FList.Delete(Index);
end;

destructor TReplRelations.Destroy;
begin
  FList.Free;
  FdsRelations.Free;
end;

function TReplRelations.GetRelations(ID: Integer): TReplRelation;
var
  Index: Integer;
begin
  Result := nil;
  Index := IndexOf(Id);
  if Index > -1 then
    Result := TReplRelation(FList.Items[Index]);
end;

function TReplRelations.GetTransaction: TIBTransaction;
begin
  Result := FdsRelations.Transaction;
end;

function TReplRelations.IndexOf(Id: Integer): Integer;
var
  I: Integer;
begin
  Result := - 1;
  for I := 0 to FList.Count -1 do
  begin
    if TReplRelation(FList.Items[I]).ID = Id then
    begin
      Result := I;
      Break;
    end;
  end;
end;

procedure TReplRelations.ReadFromDB;
var
  Flag: Boolean;
  R: TReplRelation;
begin
  if Assigned(Transaction) then
  begin
    Flag := not Transaction.InTransaction;
    if Flag then
      Transaction.StartTransaction;
    try
      FdsRelations.Open;
      while not FdsRelations.Eof do
      begin
        R := TReplRelation.Create;
        FList.Add(R);
        R.Transaction := Transaction;
        R.Relation := FdsRelations.FieldByName(fnRelation).AsString;
        R.ID := FdsRelations.FieldByName(fnId).AsInteger;
        FdsRelations.Next;
      end;
    finally
      if Flag then Transaction.Commit;
    end;
  end else
    raise Exception.Create(MSG_TRANSACTION_DO_NOT_ASSIGNED);
end;

procedure TReplRelations.SetTransaction(const Value: TIBTransaction);
begin
  FdsRelations.Transaction := Value;
end;

{ TReplicationServer }

function TReplicationServer.ActiveTrigers: Boolean;
var
  dsTriggers: TIBDataSet;
  Trigger: TTrigger;
  I: Integer;
begin
  Result := False;
  dsTriggers := TIBDataSet.Create(Self);
  try
    dsTriggers.Transaction := FTriggerTransaction;
    FTriggerTransaction.StartTransaction;
    try
      dsTriggers.SelectSQL.Text := 'SELECT * FROM rdb$triggers WHERE ' +
        'rdb$trigger_name = :name';
      dsTriggers.ModifySQL.Text := 'UPDATE rdb$triggers SET ' +
        'RDB$TRIGGER_INACTIVE = :new_RDB$TRIGGER_INACTIVE WHERE ' +
         'rdb$trigger_name = :old_rdb$trigger_name';
      for I := 0 to FTrigerList.Count - 1 do
      begin
        dsTriggers.ParamByName('name').AsString := FTrigerList[I].Name;
        dsTriggers.Open;
        dsTriggers.Edit;
        dsTriggers.FieldByName('RDB$TRIGGER_INACTIVE').AsInteger := 0;
        dsTriggers.Post;
        dsTriggers.Close;
      end;
      FTriggerTransaction.Commit;
      Result := True;
    except
      FTriggerTransaction.Rollback;
    end;
  finally
    dsTriggers.Free;
  end;
end;

function TReplicationServer.ComparePriority(const ADBkey,
  BDBKey: Integer): Boolean;
var
  DataSet: TIBDataSet;
  Priority: Integer;
begin
  DataSet := TIBDataSet.Create(Self);
  try
    DataSet.SelectSQL.Text := 'SELECT * FROM rpl_replicationdb WHERE bdkey = :dbkey';
    DataSet.ParamByName('dbkey').AsInteger := ADBKey;
    DataSet.Open;
    Priority := DataSet.FieldByName('fnPriority').AsInteger;
    DataSet.Close;
    DataSet.ParamByName('dbkey').AsInteger := BDBKey;
    DataSet.Open;
    Result := Priority < DataSet.FieldByName('fnPriority').AsInteger;
  finally
    DataSet.Free;
  end;
end;

constructor TReplicationServer.Create;
begin
  FDataBase := TIBDataBase.Create(Self);
  FDataBase.Params.Add('lc_ctype=WIN1251');
  FDataBase.SQLDialect := 3;
  {$IFDEF DEBUG}
  FDataBase.LoginPrompt := False;
  {$ENDIF}

  //Транзакция на которой производится репликация
  FTransaction := TIBTransaction.Create(Self);
  FTransaction.DefaultDatabase := FDataBase;
  //Транзакция для отключения и подключения тригеров
  FTriggerTransaction := TIBTransaction.Create(Self);
  FTriggerTransaction.DefaultDatabase := FDataBase;

  FTrigerList := TTrigerList.Create;

  FReplEvent := TReplEvent.Create;
  FReplEvent.Transaction := FTransaction;

  FCortege := TCortege.Create;
  FCortege.Transaction := FTransaction;
  FCortege.NewKey := FReplEvent.NewKey;
  FCortege.OldKey := FReplEvent.OldKey;
  FdsReplLog := TIBDataSet.Create(Self);
  FdsReplLog.Transaction := FTransaction;
  FdsReplLog.ModifySQL.Text := 'UPDATE rpl_log SET seqno = :new_seqno, ' +
    'relationkey =:new_relationkey, repltype =:new_repltype, oldkey = ' +
    ':new_oldkey, newkey = :new_newkey, replkey = :new_replkey, ' +
    'actiontime = :new_actiontime, dbkey = :new_dbkey WHERE seqno = ' +
    ':old_seqno';
  FdsReplLog.InsertSQL.Text := 'INSERT INTO rpl_log (seqno, relationkey, ' +
    'repltype, oldkey, newkey, replkey, actiontime, dbkey) VALUES ' +
    '(:seqno, :relationkey, :repltype, :oldkey, :newkey, :replkey, ' +
    ':actiontime, :dbkey)';
  FdsReplLog.DeleteSQL.Text := 'DELETE FROM rpl_log WHERE seqno = ' +
    ':old_seqno';
  FdsLogHist := TIBDataSet.Create;
  FdsLogHist.Transaction := FTransaction;
  FdsLogHist.SelectSQL.Text := 'SELECT * FROM rpl_loghist';
  FdsLogHist.InsertSQL.Text := 'INSERT INTO rpl_loghist (seqno, dbkey, ' +
    'replkey) VALUES (:seqno, :dbkey, :replkey)';
end;

function TReplicationServer.CreateExportFile: Boolean;
var
  FileStream: TFileStream;
  MemoryStream: TMemoryStream;
begin
  Result := False;
  { TODO :
  Надо будет придумать какое нибудь сжатие данных  и
  разбитие файла на тома т.к. объём информации может
  быть большой а объём носителей инф. ограничен. }
  {Cтартуем и закраваем транзакцию в процедурах вызывающих
  DoExport. Это позволит бы делать откат при воз-
  никновении ошибок. Например при записи на дискету.}
  FTransaction.StartTransaction;
  try
    if not InReplication or (FDBState.DBState = 0)then
    begin
      if SaveDialog.Execute then
      begin
        MemoryStream := TMemoryStream.Create;
        try
          FileStream := TFileStream.Create(SaveDialog.FileName, fmCreate);
          try
            DoExport(MemoryStream);
            FileStream.CopyFrom(MemoryStream, 0);
            Result := True;
          finally
            FileStream.Free;
          end;
        finally
          MemoryStream.Free;
        end;
      end;
    FTransaction.Commit;
    end else
      MessageBox(Handle, 'База находится в режиме ожидания данных с основной базы', 'Внимание',
        MB_OK);
  except
    FTransaction.Rollback;
  end;
end;

destructor TReplicationServer.Destroy;
begin
  //Отключаемся от базы данных
  Logoff;
  FDataBase.Free;
  FTransaction.Free;
  FTriggerTransaction.Free;
  FTrigerList.Free;
  FReplEvent.Free;
  FCortege.Free;
  FdsReplLog.Free;
  FdsLogHist.Free;
end;

function TReplicationServer.DoExport(Stream: TStream): Boolean;
var
  DBKey, ReplKey, IntBuf: Integer;
  TypeBuf: String;
  ActionTimeBuf: TDateTime;
begin
  { DONE :
    Если запись была вставлена в одной базе, затем изменена в той же
  базе, а потом удалена, то фактически делать ничего не надо хотя
  в RPL_LOG наверняка будет запртоколирована вся цепочка.
    Если запись была вставлена в одной базе, затем изменена в той же
  базе, то надо сохранить только команду вставки, т.к.
  сохранение всех изменеий будет дублировать информацию, что
  приведёт к увеличению файла репликации.
   Возможно имеет смысл чтобы такие вещи отслеживал тригер изменения
  записи, хотя это приведет к увеличению времени изм. записи
    Решение: Предварительная подготовка журнала событий}
  Result := False;
  if not Assigned(Stream) then
    raise Exception.Create('Поток неинициализирован');

  if FDBState.DBState = 0 then
  begin
    {База основная}
    ReplKey := FReplKey;
    DBKey := FDBKey;
    //Получаем ДатаСет с журналом событий произошедших с момента
    //последней репликации
    PreparePrimaryBaseReplLog(DBKey);
  end else
  begin
    //Получаем текущее значение генератора ключа
    //репликации
    ReplKey := GetReplId;
    //Получаем ДатаСет с журналом событий произошедших с момента
    //последней репликации
    PrepareSecondBaseReplLog;
  end;

  {Записываем ключ БД}
  IntBuf := GetDBID(FTransaction);
  Stream.WriteBuffer(IntBuf, SizeOf(IntBuf));
  {Записываем ключ репликации}
  Stream.WriteBuffer(ReplKey, SizeOf(ReplKey));
  
  if not FdsReplLog.IsEmpty then
  begin
    {Начинаем цикл записи данных}
    while not FdsReplLog.Eof do
    begin
      FReplEvent.Seqno := FdsReplLog.FieldByName(fnSeqNo).AsInteger;
      FReplEvent.SaveToStream(Stream);
      FCortege.RelationKey := FReplEvent.RelationKey;

      {Если запись не удалена то производим запись изменений}
      if FReplEvent.ReplType <> atDelete then
      begin
        FCortege.SaveToStream(Stream);
      end;
      {Для основной таблицы отмечаем в РПЛ_ЛОГИСТ что для данной
      записи репликация призошла}
      if FDBState.DBState = 0 then
        InsertLogHist(FdsReplLog.FieldByName(fnSeqNo).AsInteger,
          FDBKey, GetReplId);
      FdsReplLog.Next;
    end;
    if FDBState.DBState > 0 then
      //Увеличиваем значение генератора RPL_G_REPLICATION для второстепенной базы
      IncReplId;
    Result := True;
  end else
  begin
  { TODO : Пока непонятно что делать если ничего неизменялось }
    MessageBox(Handle, MSG_NO_DATA_CHANGE, MSG_INFORMATION, MB_OK or MB_ICONINFORMATION);
  end;
end;

function TReplicationServer.DoProcessImport(
  const Stream: TStream): Boolean;
begin
  Result := False;
  if not Assigned(Stream) then
    raise Exception.Create('Поток неинициализирован');

  {Считываем ключ БД}
  Stream.ReadBuffer(FDBKey, SizeOf(FDBKey));
  { TODO : Добавить проверку }
  {Считываем ключ репликации}
  Stream.ReadBuffer(FReplKey, SizeOf(FReplKey));
  { TODO : Добавить проверку }
  if IsImported(FReplKey) then
  begin
    MessageBox(Handle, MSG_DB_ALLREADY_REPLICATED, MSG_INFORMATION,
      MB_OK or MB_ICONINFORMATION);
    Exit;
  end;

  if InActiveTrigers then
  begin
    try
      PrepareSecondBaseReplLog;
      while Stream.Position < Stream.Size do
      begin
        FReplEvent.LoadFromStream(Stream);
        FCortege.RelationKey := FReplEvent.RelationKey;
        if FReplEvent.ReplType = atInsert then
        begin
          {Запись новая поэтому можно небоятся что она была изменена в
          базе. Поэтому просто производим вставку записи}
          FCortege.LoadFromStream(Stream);
          FCortege.Insert;
        end else
        if FReplEvent.ReplType = atUpdate then
        begin
          FCortege.LoadFromStream(Stream);
          if (not RecordChanged(FReplEvent.OldKey.Value,
            FReplEvent.ReplKey, FReplEvent.DBKey)) or Settlement then
            FCortege.UpDate;
        end else
        if FReplEvent.ReplType = atDelete then
        begin
          if (not RecordChanged(FReplEvent.OldKey.Value,
            FReplEvent.ReplKey, FReplEvent.DBKey)) or Settlement then
            FCortege.Delete
        end;
      end;
      //Удаляем ненужные записи из РПЛ_ЛОГ и РПЛ_ЛОГИСТ
      Pack;
      Result := True;
    finally
      ActiveTrigers;
    end;
  end;
end;

function TReplicationServer.DoReplication(const FromStream,
  ToStream: TStream): Boolean;
begin
  Result := False;
  if not (Assigned(FromStream) or Assigned(ToStream)) then
    raise Exception.Create('Поток неинициализирован');

  {Считываем ключ БД}
  FromStream.ReadBuffer(FDBKey, SizeOf(FDBKey));
  { TODO : Добавить проверку }
  {Считываем ключ репликации}
  FromStream.ReadBuffer(FReplKey, SizeOf(FReplKey));
  { TODO : Добавить проверку }
  if IsReplicated(FDBKey, FReplKey) then
  begin
    MessageBox(Handle, MSG_DB_ALLREADY_REPLICATED, MSG_INFORMATION,
      MB_OK or MB_ICONINFORMATION);
    Exit;
  end;

  if InActiveTrigers then
  begin
    try
      PreparePrimaryBaseReplLog(FDBKey);
      while FromStream.Position < FromStream.Size do
      begin
        FReplEvent.LoadFromStream(FromStream);
        FCortege.RelationKey := FReplEvent.RelationKey;
        if FReplEvent.ReplType = atInsert then
        begin
          {Запись новая поэтому можно небоятся что она была изменена в
          базе. Поэтому просто производим вставку записи}
          FCortege.LoadFromStream(FromStream);
          FCortege.Insert;
        end else
        if FReplEvent.ReplType = atUpdate then
        begin
          FCortege.LoadFromStream(FromStream);
          if (not RecordChanged(FReplEvent.OldKey.Value,
            FReplEvent.ReplKey, FReplEvent.DBKey)) or Settlement then
            FCortege.UpDate;
        end else
        if FReplEvent.ReplType = atDelete then
        begin
          if (not RecordChanged(FReplEvent.OldKey.Value,
            FReplEvent.ReplKey, FReplEvent.DBKey)) or Settlement then
            FCortege.Delete;
        end;
        Log;
      end;
      //Если все в порядке то формируем ответный файл
      DoExport(ToStream);
      //Удаляем ненужные записи из РПЛ_ЛОГ и РПЛ_ЛОГИСТ
      Pack;
      Result := True;
    finally
      ActiveTrigers;
    end;
  end;
end;

function TReplicationServer.GetDBState: TDBState;
var
  DataSet: TIBDataSet;
begin
  DataSet := TIBDataSet.Create(Self);
  try
    DataSet.Transaction := FTransaction;
    DataSet.SelectSQL.Text := 'SELECT * FROM rpl_dbstate';
    DataSet.Open;
    with Result do
    begin
      DBState := DataSet.FieldByName(fnDbState).AsInteger;
      ReplicationID := DataSet.FieldByName(fnReplicationID).AsInteger;
      ErrorDecision := DataSet.FieldByName(fnErrorDecsion).AsInteger;
    end;
  finally
    DataSet.Free;
  end;
end;

function TReplicationServer.GetInReplication: Boolean;
var
  DataSet: TIBDataSet;
begin
  DataSet := TIBDataSet.Create(Self);
  try
    DataSet.Transaction := FTransaction;
    DataSet.SelectSQL.Text := 'SELECT MIN(replkey) AS r FROM rpl_log';
    DataSet.Open;
    Result := GetReplId > DataSet.FieldByName('r').AsInteger;
  finally
    DataSet.Free;
  end;
end;

procedure TReplicationServer.GetPrimaryFieldList(
  const RelationKey: Integer; const FieldList: TStrings);
var
  dsPrimaryKey: TIBDataSet;
begin
  if not Assigned(FieldList) then
     raise Exception.Create('Поток неинициализирован');

  dsPrimaryKey := TIBDataSet.Create(Self);
  try
    dsPrimaryKey.Transaction := FTransaction;
    dsPrimaryKey.SelectSQL.Text := 'SELECT * FROM rpl_keys WHERE ' +
      'relationkey = ' + IntToStr(RelationKey) + 'ORDER BY keyorder';
    dsPrimaryKey.Open;
    while not dsPrimaryKey.Eof do
    begin
      FieldList.Add(dsPrimaryKey.FieldByName(fnKeyName).AsString);
      dsPrimaryKey.Next;
    end;
  finally
    dsPrimaryKey.Free;
  end;
end;

function TReplicationServer.GetReplId: Integer;
var
  DataSet: TIBDataSet;
begin
  DataSet := TIBDataSet.Create(Self);
  try
    DataSet.Transaction := FTransaction;
    DataSet.SelectSQL.Text := 'SELECT GEN_ID(RPL_G_REPLICATION, 0) AS replkey ' +
      'FROM RDB$DATABASE';
    DataSet.Open;
    Result := DataSet.FieldByName(fnReplKey).AsInteger;
  finally
    DataSet.Free;
  end;
end;

function TReplicationServer.GetSeqNo: Integer;
var
  DataSet: TIBDataSet;
begin
  DataSet := TIBDataSet.Create(Self);
  try
    DataSet.Transaction := FTransaction;
    DataSet.SelectSQL.Text := 'SELECT GEN_ID(RPL_G_SEQ, 0) AS seqno ' +
      'FROM RDB$DATABASE';
    DataSet.Open;
    Result := DataSet.FieldByName(fnSeqNo).AsInteger;
  finally
    DataSet.Free;
  end;
end;

function TReplicationServer.InActiveTrigers: Boolean;
var
  dsTriggers: TIBDataSet;
  Trigger: TTrigger;
begin
  Result := False;
  dsTriggers := TIBDataSet.Create(Self);
  try
    dsTriggers.Transaction := FTriggerTransaction;
    FTriggerTransaction.StartTransaction;
    try
      dsTriggers.SelectSQL.Text := 'SELECT * FROM rdb$triggers WHERE ' +
        'rdb$trigger_inactive = 0 AND (rdb$system_flag = 0 OR rdb$system_flag IS NULL)';
      dsTriggers.ModifySQL.Text := 'UPDATE rdb$triggers SET ' +
        'RDB$TRIGGER_INACTIVE = :new_RDB$TRIGGER_INACTIVE WHERE ' +
         'rdb$trigger_name = :old_rdb$trigger_name';
      dsTriggers.Open;
      while not dsTriggers.Eof do
      begin
        Trigger.Name := dsTriggers.FieldByName('rdb$trigger_name').AsString;
        Trigger.Relation := dsTriggers.FieldByName('rdb$relation_name').AsString;
        Trigger.InActive := 0;
        FTrigerList.Add(Trigger);
        dsTriggers.Edit;
        dsTriggers.FieldByName('RDB$TRIGGER_INACTIVE').AsInteger := 1;
        dsTriggers.Post;
        dsTriggers.Next;
      end;
      FTriggerTransaction.Commit;
      Result := True;
    except
      FTriggerTransaction.RollBack;
    end;
  finally
    dsTriggers.Free;
  end;
end;

function TReplicationServer.IncReplId: Integer;
var
  DataSet: TIBDataSet;
begin
  DataSet := TIBDataSet.Create(nil);
  try
    DataSet.Transaction := FTransaction;
    DataSet.SelectSQL.Text := 'SELECT GEN_ID(RPL_G_REPLICATION, 1) AS replkey ' +
      'FROM RDB$DATABASE';
    DataSet.Open;
    Result := DataSet.FieldByName(fnReplKey).AsInteger;
  finally
    DataSet.Free;
  end;
end;

function TReplicationServer.IncSeqNo: Integer;
var
  DataSet: TIBDataSet;
begin
  DataSet := TIBDataSet.Create(Self);
  try
    DataSet.Transaction := FTransaction;
    DataSet.SelectSQL.Text := 'SELECT GEN_ID(RPL_G_SEQ, 1) AS seqno ' +
      'FROM RDB$DATABASE';
    DataSet.Open;
    Result := DataSet.FieldByName(fnSeqNo).AsInteger;
  finally
    DataSet.Free;
  end;
end;

procedure TReplicationServer.InsertLogHist(ASeqNo, ADBKey,
  AReplKey: Integer);
begin
  FdsLogHist.Open;
  try
    FdsLogHist.Insert;
    FdsLogHist.FieldByName(fnSeqNo).AsInteger := ASeqNo;
    FdsLogHist.FieldByName(fnDBKey).AsInteger := ADBKey;
    FdsLogHist.FieldByName(fnReplKey).AsInteger := AReplKey;
    FdsLogHist.Post;
  finally
    FdsLogHist.Close;
  end;
end;

function TReplicationServer.IsImported(ReplKey: Integer): Boolean;
var
  DataSet: TIBDataSet;
begin
  DataSet := TIBDataSet.Create(Self);
  try
    DataSet.SelectSQl.Text := 'SELECT MIN(replkey) FROM rpl_log';
    DataSet.Transaction := FTransaction;
    DataSet.Open;
    Result := DataSet.Fields[0].AsInteger > ReplKey;
  finally
    DataSet.Free;
  end;
end;

function TReplicationServer.IsReplicated(const DBID,
  ReplKey: Integer): Boolean;
var
  DataSet: TIBDataSet;
begin
  DataSet := TIBDataSet.Create(Self);
  try
    DataSet.Transaction := FTransaction;
    DataSet.SelectSQL.Text := 'SELECT seqno FROM rpl_loghist WHERE ' +
      'dbkey = ' + IntToStr(DBID) + ' AND replkey = ' + IntToStr(ReplKey);
    DataSet.Open;
    Result := not DataSet.IsEmpty;
  finally
    DataSet.Free;
  end;
end;

procedure TReplicationServer.Log;
var
  dsLog: TIBDataSet;
begin
  {Создаём ДатаСет с помощ.ю которого будем добавлить данные
  в таблицу RPL_LOG}
  dsLog := TIBDataSet.Create(Self);
  try
    dsLog.Transaction := FTransaction;
    dsLog.SelectSQL.Text := 'SELECT * FROM rpl_log';
    dsLog.InsertSQL.Text := FdsReplLog.InsertSQL.Text;
    dsLog.Open;
    dsLog.Insert;
    with dsLog do
    begin
      {Получаем новое значение счетчика событий}
      FieldByName(fnSeqNo).AsInteger := IncSeqNo;
      FieldByName(fnRelationKey).AsInteger := FReplEvent.RelationKey;
      FieldByName(fnReplType).AsString := FReplEvent.ReplType;
      FieldByName(fnOldKey).AsString := FReplEvent.OldKey.Value;
      FieldByName(fnNewKey).AsString := FReplEvent.NewKey.Value;
      FieldByName(fnDBKey).AsInteger := FReplEvent.DBKey;
      //Ключ репликации устанавливам раным счетчику репликаций для данной
      //базы
      FieldByName(fnReplKey).AsInteger := GetReplId;
      FieldByName(fnActionTime).AsDateTime := FReplEvent.ActionTime;
      Post;
    end;
    with FdsLogHist do
    begin
      if not Active then Open;
      Insert;
      //В журнале историй репликаций создаем запись о том что
      //запись уже реплецировалась
      FieldByName(fnSeqNo).AsInteger := dsLog.FieldByName(fnSeqNo).AsInteger;
      FieldByName(fnDBKey).AsInteger := FReplEvent.DBKey;
      FieldByName(fnReplKey).AsInteger := FReplEvent.ReplKey;
      Post;
    end;
  finally
    dsLog.Free;
  end;
end;

procedure TReplicationServer.Login;
var
  LocResult: Boolean;
begin
  LocResult := True;
  //Нам необходим однопользовательский режим
  //поэтому отключаем других пользавателей
{$IFNDEF DEBUG}
  with TgsDatabaseShutdown.Create(Self) do
  try
    Database := FDataBase;
    ShowUserDisconnectDialog := False;
    if not IsShutdowned then
      LocResult := Shutdown;
  finally
    Free;
  end;
{$ENDIF}

  if not LocResult then Exit;

  //  Осуществляем подключение
  try
    FDataBase.Connected := True;

    FTransaction.StartTransaction;
    try
      FDBState := GetDBState;
    finally
      FTransaction.Commit;
    end;
  except
    Application.Terminate;
  end;
end;

procedure TReplicationServer.Logoff;
begin
  FDataBase.Connected := False;
end;

procedure TReplicationServer.Pack;
begin
  if FDBState.DBState = 0 then
    PackPrimaryBase
  else
    PackSecondBase;
end;

procedure TReplicationServer.PackPrimaryBase;
var
  dsLog, dsLogHist: TIBDataSet;
begin
  dsLogHist := TIBDataSet.Create(Self);
  try
    dsLogHist.Transaction := FTransaction;
    dsLogHist.SelectSQL.Text := 'SELECT lh1.seqno FROM rpl_loghist lh1 ' +
      'WHERE NOT EXISTS(SELECT lh2.seqno FROM rpl_replicationdb rdb, ' +
      'rpl_loghist lh2 WHERE (lh1.seqno =  lh2.seqno) AND (rdb.dbkey = ' +
      'lh2.dbkey) AND (lh2.dbkey <> '+ IntToStr(GetDBID(FTransaction)) + '))';
    dsLogHist.DeleteSQL.Text := 'DELETE FROM rpl_loghist WHERE seqno = :old_seqno';
    dsLogHist.Open;
    if not dsLogHist.IsEmpty then
    begin
      dsLog := TIBDataSet.Create(Self);
      try
        dsLog.Transaction := FTransaction;
        dsLog.SelectSQL.Text := 'SELECT * FROM rpl_log WHERE seqno = :seqno';
        dsLog.DeleteSQL.Text := 'DELETE FROM rpl_log WHERE seqno = :old_seqno';
        while not dsLogHist.Eof do
        begin
          dsLog.ParamByName('seqno').AsInteger :=
            dsLogHist.FieldByName(fnSeqno).AsInteger;
          dsLog.Open;
          dsLog.Delete;
          dsLog.Close;
          dsLogHist.Delete;
        end;
      finally
        dsLog.Free;
      end;
    end;
  finally
    dsLogHist.Free;
  end;
end;

procedure TReplicationServer.PackSecondBase;
var
  DataSet: TIBDataSet;
begin
  DataSet := TIBDataSet.Create(Self);
  try
    DataSet.Transaction := FTransaction;
    DataSet.SelectSQL.Text := 'SELECT * FROM rpl_log WHERE replkey = ' +
      IntToStr(GetReplId - 1);
    DataSet.DeleteSQL.Text := 'DELETE FROM rpl_log WHERE replkey = :old_replkey';
    DataSet.Open;
    while not DataSet.Eof do
      DataSet.Delete;
  finally
    DataSet.Free;
  end;
end;

procedure TReplicationServer.PreparePrimaryBaseReplLog(
  const DBID: Integer);
var
  NewKey, OldKey: Integer;
  RelationKey: Integer;
  ReplType: String;
  SeqNo: Integer;

begin
  if FdsReplLog.Active then
    FdsReplLog.Close;
  FdsReplLog.SelectSQL.Clear;
  //Получаем все изменения произошедшие с момента последней репликации
  //при этом данные упоредочены таким образом что для каждой записи
  //действия будут идти последовательно друг за другом [I]-[U]-[U]-[D]
  FdsReplLog.SelectSQL.Add('SELECT rl.*, r.relation FROM rpl_log rl LEFT JOIN ' +
    'rpl_relations r ON rl.relationkey = r.id WHERE NOT EXISTS( ' +
    'SELECT seqno FROM rpl_loghist WHERE (seqno = rl.seqno) AND ' +
    '(dbkey = ' + IntToStr(DBID) + ')) ');
  FdsReplLog.SelectSQL.Add('ORDER BY rl.relationkey, rl.newkey, rl.seqno');
{  FdsReplLog.Open;
  //Т.к запись могла быть создана, изменена и удалена с момента послед-
  //ней репликации то нам нет необходимости передавать во второстепенную
  //базу информацию о таких записях. Поэтому такие записи мы будем помечать
  //в табл. RPL_LOGHIST как уже переданные.
  if not FdsLogHist.Active then
    FdsLogHist.Open;
  while not FdsReplLog.Eof do
  begin
    NewKey := FdsReplLog.FieldByName(fnNewKey).AsInteger;
    OldKey := FdsReplLog.FieldByName(fnOldKey).AsInteger;
    RelationKey := FdsReplLog.FieldByName(fnRelationKey).AsInteger;
    ReplType := FdsReplLog.FieldByName(fnReplType).AsString;
    SeqNo := FdsReplLog.FieldByName(fnSeqNo).AsInteger;
    if ReplType = atInsert then
    begin
      //Запись была вставлена с момента последней репликации
      //поэтому будем игнорировать все последующие операции изменения данных
      FdsReplLog.Next;
      while (NewKey = FdsReplLog.FieldByName(fnNewKey).AsInteger) and
         (OldKey = FdsReplLog.FieldByName(fnOldKey).AsInteger) and
         (RelationKey = FdsReplLog.FieldByName(fnRelationKey).AsInteger) do
      begin
        if atUpdate = FdsReplLog.FieldByName(fnReplType).AsString then
        begin
          //Все последующие изменения помечаем как реплецированые
          InsertLogHist(FdsReplLog.FieldByName(fnSeqNo).AsInteger,
            DBID, ReplKey);
          FdsReplLog.Next;
        end else
        if atDelete = FdsReplLog.FieldByName(fnReplType).AsString then
        begin
          //Запись была вставлена и удалена с момена последней
          //репликации поэтому просто помечаем что она реплецирована
          InsertLogHist(SeqNo, DBID, ReplKey);
          InsertLogHist(FdsReplLog.FieldByName(fnSeqNo).AsInteger,
            DBID, ReplKey);
          FdsReplLog.Next;
        end;
      end;
    end else
    if ReplType = atUpdate then
    begin
      FdsReplLog.Next;
      while (NewKey = FdsReplLog.FieldByName(fnNewKey).AsInteger) and
         (OldKey = FdsReplLog.FieldByName(fnOldKey).AsInteger) and
         (RelationKey = FdsReplLog.FieldByName(fnRelationKey).AsInteger) do
      begin
        if atUpdate = FdsReplLog.FieldByName(fnReplType).AsString then
        begin
          //Все последующие изменения помечаем как реплецированые
          InsertLogHist(FdsReplLog.FieldByName(fnSeqNo).AsInteger,
            DBID, ReplKey);
          FdsReplLog.Next;
        end else
        if atDelete = FdsReplLog.FieldByName(fnReplType).AsString then
        begin
          //Запись была измененя и удалена с момена последней
          //репликации поэтому просто оставляем информацию об удалении
          InsertLogHist(SeqNo,DBID, ReplKey);
          FdsReplLog.Next
        end;
      end;
    end else
    if ReplType = atDelete then
    begin
      //Запись была удалена поэтому переходим на следующую запись
      FdsReplLog.Next;
    end;
  end;}
  {теперь необходимо переоткрыть ДатаСет с целью обновления
  данных}
//  FdsReplLog.Close;
  FdsReplLog.SelectSQL[1] := 'ORDER BY rl.actiontime';
  FdsReplLog.Open;
end;

procedure TReplicationServer.PrepareSecondBaseReplLog;
var
  NewKey, OldKey: String;
  RelationKey: Integer;
  ReplType: String;
  ActionTime: TDateTime;
begin
  if FdsReplLog.Active then
    FdsReplLog.Close;

  //Получаем все изменения произошедшие с момента последней репликации
  //при этом данные упоредочены таким образом что для каждой записи
  //действия будут идти последовательно друг за другом [I]-[U]-[U]-[D]
  FdsReplLog.SelectSQL.Clear;

  FdsReplLog.SelectSQL.Add('SELECT rl.*, r.relation FROM rpl_log rl LEFT JOIN ' +
    'rpl_relations r ON rl.relationkey = r.id WHERE rl.replkey = ' +
    IntToStr(GetReplId));
  FdsReplLog.SelectSQL.Add('ORDER BY rl.relationkey, rl.newkey, rl.seqno');
{  FdsReplLog.Open;
  while not FdsReplLog.Eof do
  begin
    NewKey := FdsReplLog.FieldByName(fnNewKey).AsString;
    OldKey := FdsReplLog.FieldByName(fnOldKey).AsString;
    RelationKey := FdsReplLog.FieldByName(fnRelationKey).AsInteger;
    ReplType := FdsReplLog.FieldByName(fnReplType).AsString;
    if ReplType = atInsert then
    begin
      //Запись была вставлена с момента последней репликации
      //поэтому будем игнорировать все последующие операции изменения данных
      FdsReplLog.Next;
      while (NewKey = FdsReplLog.FieldByName(fnOldKey).AsString) and
         ((FdsReplLog.FieldByName(fnOldKey).AsString =
         FdsReplLog.FieldByName(fnNewKey).AsString) or
         (FdsReplLog.FieldByName(fnOldKey).AsString = '') or
         (FdsReplLog.FieldByName(fnNewKey).AsString = '')) and
         (RelationKey = FdsReplLog.FieldByName(fnRelationKey).AsInteger) do
      begin
        if atUpdate = FdsReplLog.FieldByName(fnReplType).AsString then
        begin
          // TODO :
          //Неясно  что делать с ActionTime. Пока буду сохранять
          //время последних изменений
          ActionTime := FdsReplLog.FieldByName(fnActionTime).AsDateTime;
          FdsReplLog.Prior;
          FdsReplLog.Edit;
          FdsReplLog.FieldByName(fnActionTime).AsDateTime := ActionTime;
          FdsReplLog.Post;
          FdsReplLog.Next;
          FdsReplLog.Delete;
        end
        else
        if atDelete = FdsReplLog.FieldByName(fnReplType).AsString then
        begin
          //Запись была вставлена и удалена с момена последней
          //репликации поэтому просто удаляем информацию о ней
          FdsReplLog.Prior;
          FdsReplLog.Delete;
          FdsReplLog.Delete;
        end;
      end;
    end else
    if ReplType = atUpdate then
    begin
      FdsReplLog.Next;
      while (NewKey = FdsReplLog.FieldByName(fnOldKey).AsString) and
         ((FdsReplLog.FieldByName(fnOldKey).AsString =
         FdsReplLog.FieldByName(fnNewKey).AsString) or
         (FdsReplLog.FieldByName(fnOldKey).AsString = '') or
         (FdsReplLog.FieldByName(fnNewKey).AsString = '')) and
         (RelationKey = FdsReplLog.FieldByName(fnRelationKey).AsInteger) do
      begin
        if atUpdate = FdsReplLog.FieldByName(fnReplType).AsString then
        begin
          FdsReplLog.Prior;
          FdsReplLog.Delete;
          FdsReplLog.Next;
        end else
        if atDelete = FdsReplLog.FieldByName(fnReplType).AsString then
        begin
          //Запись была измененя и удалена с момена последней
          //репликации поэтому просто оставляем информацию об удалении
          FdsReplLog.Prior;
          FdsReplLog.Delete;
          FdsReplLog.Next
        end;
      end;
    end else
    if ReplType = atDelete then
    begin
      //Запись была удалена поэтому переходим на следующую запись
      FdsReplLog.Next;
    end;
  end;
  //FdsReplLog.Post;
  FdsReplLog.Close;}
  {Изменяем запрос чтобы данные были отсортированы по
  полю seqno}
  FdsReplLog.SelectSQL[1] := 'ORDER BY rl.seqno';
  FdsReplLog.Open;
end;

function TReplicationServer.ProcessImportFile: Boolean;
var
  InputFileStream: TFileStream;
begin
  Result := False;
  if OpenDialog.Execute then
  begin
    {Cтартуем и закраваем транзакцию в процедурах вызывающих
    Replication. Это позволит делать откат при воз-
    никновении ошибок. Например при записи на дискету.}
    FTransaction.StartTransaction;
    try
      InputFileStream := TFileStream.Create(OpenDialog.FileName, fmOpenRead);
      try
        DoProcessImport(InputFileStream);
        Result := True;
      finally
        InputFileStream.Free;
      end;
      FTransaction.Commit;
    except
      FTransaction.Rollback;
    end;
  end;
end;

function TReplicationServer.RecordChanged(const Key: String; const ReplKey,
  DBID: Integer): Boolean;
var
  DataSet: TIBDataSet;
begin
  { TODO :
    Возможно здесь лучше сделать глобальный датасет т.к. проверка
    на изменение записи будет производиться часто и содание каждый
    раз датасета может потребовать много места }
  DataSet := TIBDataSet.Create(Self);
  try
    DataSet.Transaction := FTransaction;
    DataSet.SelectSQL.Text := 'SELECT rl.* FROM rpl_log rl WHERE NOT EXISTS(' +
      'SELECT seqno FROM rpl_loghist WHERE (seqno = rl.seqno) AND (dbkey = :dbid)) AND ' +
      '(newkey = :key) AND (replkey = :replkey)';
    DataSet.ParamByName('key').AsString := Key;
    DataSet.ParamByName('dbid').AsInteger := DBID;
    DataSet.ParamByName('replkey').AsInteger := ReplKey;
    DataSet.Open;
    Result := not DataSet.IsEmpty;
  finally
    DataSet.Free;
  end;
end;

function TReplicationServer.ReplicationFile: Boolean;
var
  InputFileStream: TFileStream;
  OutputFileStream: TFileStream;
  MemoryStream: TMemoryStream;
begin
  Result := False;
  if OpenDialog.Execute then
  begin
    {Cтартуем и закраваем транзакцию в процедурах вызывающих
    Replication. Это позволит делать откат при воз-
    никновении ошибок. Например при записи на дискету.}
    FTransaction.StartTransaction;
    try
      MemoryStream := TMemoryStream.Create;
      try
        InputFileStream := TFileStream.Create(OpenDialog.FileName, fmOpenRead	);
        try
          DoReplication(InputFileStream, MemoryStream);
          if MemoryStream.Size > 0 then
          begin
            if SaveDialog.Execute then
            begin
              OutputFileStream := TFileStream.Create(SaveDialog.FileName, fmCreate);
              try
                OutputFileStream.CopyFrom(MemoryStream, 0);
              finally
                OutputFileStream.Free;
              end;
            end;
          end;
          Result := True;
        finally
          InputFileStream.Free;
        end;
      finally
        MemoryStream.Free;
      end;
      FTransaction.Commit;
    except
      FTransaction.Rollback;
    end;
  end;
end;

procedure TReplicationServer.SetDataBaseName(const Value: string);
begin
  FDataBaseName := Value;
end;

procedure TReplicationServer.SetPassWord(const Value: string);
begin
  FPassWord := Value;
end;

function TReplicationServer.Settlement: Boolean;
begin
  case FDBState.ErrorDecision of
    edPriority: Result := SettlementPriority;
    edTime: Result := SettlementTime;
    edManual: Result := SettlementManual;
    edServer: Result := SettlementServer;
  end;
end;

function TReplicationServer.Settlemented: Boolean;
var
  dsManual: TIBDataSet;
begin
  dsManual := TIBDataSet.Create(Self);
  try
    dsManual.Transaction := FTransaction;
    dsManual.SelectSQL.Text := 'SELECT * FROM rpl_manual';
    dsManual.Open;
    Result := dsManual.IsEmpty;
  finally
    dsManual.Free;
  end;
end;

function TReplicationServer.SettlementManual: Boolean;
{var
  I: Integer;
  DBLine: TfrmManualDBLine;
  H: Integer;
  KeyList: TStrings;
  PrimaryField: TStrings;
  I: Integer;
  Relation: String;
  DataSource: TDataSource;}
begin
  {if dsRelation.Active then
    dsRelation.Close;

  PrimaryField := TStringList.Create;
  try
    GetPrimaryFieldList(ReplLog.RelationKey, PrimaryField);
    KeyList := TStringList.Create;
    try
      KeyDecoder(ReplLog.NewKey, KeyList);
      //Формируем SQL-запрос
      dsRelation.SelectSQL.Clear;
      dsRelation.SelectSQL.Add('SELECT *');
      //Добавляем в SQL запрос имя таблицы
      Relation := GetRelationName(ReplLog.RelationKey);
      dsRelation.SelectSQL.Add('FROM ' +  Relation);
      dsRelation.SelectSQL.Add(' WHERE ');
      for I := 0 to KeyList.Count - 1 do
      begin
        dsRelation.SelectSQL.Add(PrimaryField[I] + ' = ' + KeyList[I]);
        if KeyList.Count > I then
          dsRelation.SelectSQL.Add(' AND ');
      end;
    finally
      KeyList.Free;
    end;
  finally
    PrimaryField.Free;
  end;
  dsRelation.Open;
  DataSource := TDataSource.Create(Self);
  try
    DataSource.DataSet := dsRelation;
    with TdlgSettlementManual.Create(Self) do
    begin
      H := 0;
      for I := 0 to dsRelation.FieldCount - 1 do
      begin
        DBLine.Create(Panel1);
        DbLine.Top := H;
        case GetFieldType(Relation, dsRelation.Fields[I].Name) of
          7, 8, 9, 10, 11, 14, 27, 35: DBLine.LineType := ltEdit;
          37, 261: DBLine.LineType := ltMemo;
        end;
        DBLine.FieldName := dsRelation.Fields[I].Name;
        DBLine.DataField := dsRelation.Fields[I];
        DBLine.DataSource := DataSource;
        H := H + DBLine.Height;
      end;
      if H > Panel1.Height then
        Panel1.Height := H;
      ShowModal;
    end;
  finally
    DataSource.Free;
  end;}
  Result := MessageBox(Handle, 'Заменить существующую запись', 'Вопрос',
    MB_OKCANCEL) = IDOK;
end;

function TReplicationServer.SettlementPriority: Boolean;
begin
  Result := ComparePriority(GetDBID(FTransaction), FReplEvent.DBKey);
end;

function TReplicationServer.SettlementServer: Boolean;
begin
  { TODO : Добавить реализацию }
  Result := False;
end;

function TReplicationServer.SettlementTime: Boolean;
begin
  Result := FdsReplLog.FieldByName(fnActionTime).AsDateTime >
    FReplEvent.ActionTime;
end;

procedure TReplicationServer.SetUser(const Value: string);
begin
  FUser := Value;
end;

function TReplicationServer.Synchronize: Boolean;
begin
  Result := False;
end;

initialization
 Relations := TReplRelations.Create;
 Relations.Transaction := FTransaction;
 Relations.ReadFromDB;

finalization
  Relations.Free;

end.
