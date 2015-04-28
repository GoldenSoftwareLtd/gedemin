unit rpl_BaseTypes_unit;

interface
uses IBDataBase, IBSQL, rpl_const, Classes, IBCustomDataSet, db, contnrs, Forms, Windows,
  SysUtils, IBHeader, ZLib, dialogs, Controls;
{ DONE -oTipTop -cсделать :
Реализовать список индексов таблиц и записей для журнала
событий. Это позволит увеличить скорость поиска измененных
записей при обработке реплики. Желательно чтобы хранилась
информация о соответствии старого ключа новому ключу }
{ DONE -oTipTop -cВажно :
ВНИМАНИЕ! Перед обработкой данных из файла реплики
необходимо в таб. RPL_LOGHIST отметить запись для
которых подтвержнена транзакция. }
{ DONE :
Если отсортировать изменения в базе по таблицам то SQL запросы
можно формировать для группы изменений, т.к. для одной таблицы
запросы идентичны }
{ DONE :
Интересную идею я нашел в ибрепликаторе: необходимо иметь
возможность изменять разделитель первичного ключа, если он
сосоит из нескольких полей. По умолчанию в ибрепликаторе стоит
#5 }
{ TODO :
Наверно нужно отказаться от таблицы JuxtaPosition. При подготовке
к репликации нужно отмечать поля первичных ключей и поля кандидаты
на первичный ключ. Пользователь должен выбрать как осуществлять
поиск записи. }
{ DONE : Реализовать кеширование РУИДов }
const
  DataNoPassed = -1;
  DataPassed = 0;
  DataCommited = 1;
type
  TRUIDType = (rtNone, rtInteger, rtString, rtFloat, rtDateTime);

  //Тип репликации
  TReplDirection = (
    rdToServer = 0,      //Однонаправленная, от второстепенных баз к серверу
    rdFromServer = 1,    //Однонаправленная, от сервера к второстепенным базам
    rdDual = 2           //Двунаправленная репликация
    );

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
    Direction: TReplDirection;
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

  TReplDataBase = class;
  TrpRelation = class;
  TReplLog = class;
  TRUIDConformitys = class;
  TrpEvent = class;
  TRUIDCash =class;

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
    
  TrplStreamHeader = class (TObject)
  private
    FDBKey: Integer;
    FLastProcessReplKey: Integer;
    FReplKey: Integer;
    FSchema: Integer;
    FStreamInfo: TStreamInfo;
    FToDBKey: Integer;
    procedure SetDBKey(const Value: Integer);
    procedure SetLastProcessReplKey(const Value: Integer);
    procedure SetReplKey(const Value: Integer);
    procedure SetSchema(const Value: Integer);
    procedure SetStreamInfo(const Value: TStreamInfo);
    procedure SetToDBKey(const Value: Integer);
  public
    constructor Create;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property DBKey: Integer read FDBKey write SetDBKey;
    property ToDBKey: Integer read FToDBKey write SetToDBKey;
    property LastProcessReplKey: Integer read FLastProcessReplKey write
            SetLastProcessReplKey;
    property ReplKey: Integer read FReplKey write SetReplKey;
    property Schema: Integer read FSchema write SetSchema;
    property StreamInfo: TStreamInfo read FStreamInfo write SetStreamInfo;
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
  
  TKeyIndex = class (TObject)
  private
    FIndex: Integer;
    FNewKey: string;
    FOldKey: string;
  public
    property Index: Integer read FIndex write FIndex;
    property NewKey: string read FNewKey write FNewKey;
    property OldKey: string read FOldKey write FOldKey;
  end;

  TKeyIndices = class (TSortedList)
  protected
    FKeyIndex: TKeyIndex;
    procedure GetSortCompare; override;
  public
    destructor Destroy; override;
    function IndexOfOldKey(OldKey: string): Integer;
  end;

  TRelationIndex = class (TObject)
  private
    FIndex: Integer;
    FKeyIndexes: TKeyIndices;
    FRelationKey: Integer;
    function GeTKeyIndices: TKeyIndices;
  public
    destructor Destroy; override;
    property Index: Integer read FIndex write FIndex;
    property KeyIndexes: TKeyIndices read GeTKeyIndices;
    property RelationKey: Integer read FRelationKey write FRelationKey;
  end;

  TRelationIndices = class (TSortedList)
  protected
    FRelationIndex: TRelationIndex;
    procedure GetSortCompare; override;
  public
    destructor Destroy; override;
    function IndexOfRelation(RelationKey: Integer): Integer;
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
    FNotNull: Boolean;
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
    property NotNull: Boolean read FNotNull;
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

  TrpUniqueIndicesValues = class (TSortedList)
  private
//    FValue: TrpUniqueIndexValue;

    function GetValues(Index: Integer): TrpUniqueIndexValue;
    procedure SetValues(Index: Integer; const Value: TrpUniqueIndexValue);
  protected
    procedure GetSortCompare; override;
  public
    property Values[Index: Integer]: TrpUniqueIndexValue read GetValues write SetValues;
  end;
  
  //Список уникальных индексов
  TrpUniqueIndex = class (TObject)
  private
    FDelFieldsValue: TStringList;
    FFields: TrpFields;
    FIndexName: string;
    FValues: TrpUniqueIndicesValues;
    function GetDelFieldsValue: TStrings;
    function GetFields: TrpFields;
    function GetValues: TrpUniqueIndicesValues;
    procedure SetIndexName(const Value: string);
  public
    destructor Destroy; override;
    property DelFieldsValue: TStrings read GetDelFieldsValue;
    property Fields: TrpFields read GetFields;
    property IndexName: string read FIndexName write SetIndexName;
    property Values: TrpUniqueIndicesValues read GetValues;
  end;
  
  TrpUniqueIndices = class (TObjectList)
  private
    function GetIndices(Index: Integer): TrpUniqueIndex;
  public
    function IndexOf(IndexName: String): Integer;
    function IndexOfByField(FieldName: String): Integer;
    property Indices[Index: Integer]: TrpUniqueIndex read GetIndices; default;
  end;

  //Список таблиц, участвующих в репликации
  TrpRelation = class (TObject)
  private
    FDataBase: TReplDataBase;
    FFieldIndicesInited: Boolean;
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
    FUniqueIndices: TrpUniqueIndices;
    FNeedSaveRUIDFields: TrpFields;
    FGeneratorName: string;
    procedure SetGeneratorName(const Value: string); virtual;
    procedure CheckLoaded; virtual;
    function GetDeleteSQL: TStrings; virtual;
    function GetInsertSQL: TStrings; virtual;
    function GetModifySQL: TStrings; virtual;
    function GetSelectSQL: TStrings; virtual;
    function GetUniqueIndices: TrpUniqueIndices;
    function IBSQL: TIBSQL;
    function Loaded: Boolean; virtual;
    procedure LoadUniqeIndices; virtual;
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
    property UniqueIndices: TrpUniqueIndices read GetUniqueIndices;
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
  TRUIDManager = class (TObject)
  private
    FDataBase: TReplDataBase;
    function GetRUIDConf: TRUIDConformitys;
    procedure SetDataBase(const Value: TReplDataBase);
  protected
    FGenIDSQL: TIBSQL;
    FInsertRUIDSQL: TIBSQL;
    FRUIDCash: TRUIDCash;
    FRUIDConf: TRUIDConformitys;
    FSelectIDSQL: TIBSQL;
    FSelectRUIDSQL: TIBSQL;
    procedure CheckDataBase;
    procedure CheckGenIdSQL; virtual;
    procedure CheckInsertRUIDSQL; virtual;
    procedure CheckRUIDCash;
    procedure CheckSelectIdSQL; virtual;
    procedure CheckSelectRUIDSQL; virtual;
    function GetInsertRUIDSQL: string; virtual; abstract;
    function GetSelectIdSQL: string; virtual; abstract;
    function GetSelectRUIDSQL: string; virtual; abstract;
  public
    destructor Destroy; override;
    procedure AddRUID(Id: Integer; RUID: TRUID); virtual; abstract;
    function GetId(const RUID: TRUID): Integer; virtual; abstract;
    function GetNextId(RelationId: Integer = 0): Integer; virtual; abstract;
    function GetRUID(Id: Integer; RelationId: Integer = 0): TRUID; virtual; 
            abstract;
    property DataBase: TReplDataBase read FDataBase write SetDataBase;
    property RUIDConf: TRUIDConformitys read GetRUIDConf;
  end;

  //класс менаджера руидов для баз у которых ид уникально в пределах таблицы
  TRUIDManagerDBU = class (TRUIDManager)
  protected
    procedure CheckGenIdSQL; override;
    function GetInsertRUIDSQL: string; override;
    function GetSelectIdSQL: string; override;
    function GetSelectRUIDSQL: string; override;
    function RecordWithIDExists(ID: integer): boolean;
  public
    procedure AddRUID(Id: Integer; RUID: TRUID); override;
    function GetId(const RUID: TRUID): Integer; override;
    function GetNextId(RelationId: Integer = 0): Integer; override;
    function GetRUID(Id: Integer; RelationId: Integer = 0): TRUID; override;
  end;
  
  //класс менаджера руидов для баз у которых ид уникально для всех баз
  TRUIDManagerRU = class (TRUIDManager)
  protected
    FLastRelationKey: Integer;
    function GetInsertRUIDSQL: string; override;
    function GetSelectIdSQL: string; override;
    function GetSelectRUIDSQL: string; override;
  public
    procedure AddRUID(Id: Integer; RUID: TRUID); override;
    function GetId(const RUID: TRUID): Integer; override;
    function GetNextId(RelationId: Integer = 0): Integer; override;
    function GetRUID(Id: Integer; RelationId: Integer = 0): TRUID; override;
  end;
  
  TRUIDManagerU = class (TRUIDManager)
  protected
    function GetInsertRUIDSQL: string; override;
    function GetSelectIdSQL: string; override;
    function GetSelectRUIDSQL: string; override;
  public
    procedure AddRUID(Id: Integer; RUID: TRUID); override;
    function GetId(const RUID: TRUID): Integer; override;
    function GetNextId(RelationId: Integer = 0): Integer; override;
    function GetRUID(Id: Integer; RelationId: Integer = 0): TRUID; override;
  end;
  
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
    FLog: TReplLog;
    FPreserve: Boolean;
    FProtocol: string;
    FReadSQL: TIBSQL;
    FReadTransaction: TIBTransaction;
    FRelations: TrpRelations;
    FReplicationDBList: TReplicationDBList;
    FRUIDManager: TRUIDManager;
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
    function GetLog: TReplLog;
    function GetReadTransaction: TIBTransaction;
    function GetRelations: TrpRelations;
    function GetRUIDManager: TRUIDManager;
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
    function CanRepl(AFromDBID, AToDBID: Integer): Boolean; overload;
    function CanRepl(ADBID: Integer): Boolean; overload;
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
    function GetId(RUID: TRUID): Integer;
    function GetNextID(RelationKey: Integer = 0): Integer;
    function GetreplFileInfo(const S: TStrings; FileName: string): Boolean; overload;
    function GetreplFileInfo(const S: TStrings; FileName: string; ALastReplKey: Integer): Boolean; overload;
    function GetRUID(Id: Integer; RelationId: Integer = 0): TRUID;
    procedure GetShortDbReport(const S: TStrings; DBKey: Integer);
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
    property Log: TReplLog read GetLog;
    property Preserve: Boolean read FPreserve write SetPreserve;
    property Protocol: string read FProtocol write SetProtocol;
    property ReadTransaction: TIBTransaction read GetReadTransaction;
    property Relations: TrpRelations read GetRelations;
    property RUIDManager: TRUIDManager read GetRUIDManager;
    property ServerName: string read GetServerName write SetServerName;
    property Transaction: TIBTransaction read GetTransaction;
    procedure SetReplKey(DBKey: Integer; ReplKey: Integer);
  published
    property DatabaseName: TIBFileName read GetDBName write SetDatabaseName;
  end;

  TSeqnoIndex = class (TObject)
  private
    FIndex: Integer;
    FSeqno: Integer;
    procedure SetIndex(const Value: Integer);
    procedure SetSeqno(const Value: Integer);
  public
    property Index: Integer read FIndex write SetIndex;
    property Seqno: Integer read FSeqno write SetSeqno;
  end;

  TSeqnoIndices = class (TSortedList)
  private
    function GetSeqnos(Seqno: Integer): TSeqnoIndex;
  protected
    FSeqnoIndex: TSeqnoIndex;
    procedure GetSortCompare; override;
  public
    destructor Destroy; override;
    function IndexOfSeqno(Seqno: Integer): Integer;
    property Seqnos[Seqno: Integer]: TSeqnoIndex read GetSeqnos;
  end;

  //Обект хранит данные поля
  TReplLog = class (TList)
  private
    FDBKey: Integer;
    FDeleteLogHistSQL: TIBSQL;
    FInsertLogHistSQL: TIBSQL;
    FInsertLogSQL: TIBSQL;
    FRelationIndexes: TRelationIndices;
    FSeqnoIndices: TSeqnoIndices;
    FUpdateLogHistSQL: TIBSQL;
    procedure CheckLogHistSQL;
    function GetLogs(Index: Integer): TReplLogRecord;
    function GetLogsBySeqno(Seqno: Integer): TReplLogRecord;
    procedure ReadFromDB;
    procedure ReadLogRecordFromSQL(var RL: TReplLogRecord; SQL: TIBSQL);
    procedure SetDBKey(const Value: Integer);
    function GetChangesCount: Integer;
  public
    destructor Destroy; override;
    function Add(Item: TReplLogRecord): Integer;
    procedure Clear; override;
    procedure Delete(Index: Integer);
    procedure EnterHistLog(SeqNo, CorrDBKey, ReplicaKey: Integer; TrCommit:
            Integer);
    procedure MarkTransferedRecords(ReplKey: Integer);
    function IndexOfOldKey(RelationKey: Integer; OldKey: string): Integer;
    function IndexOfSeqno(Seqno: Integer): Integer;
    function Log(Event: TrpEvent): Integer;
    procedure Pack(ReplKey: Integer);
    procedure PackDB;
    procedure SortLog;
    procedure SortLogFinal;
    procedure TransactionCommit(DBKey, ReplKey: Integer);
    property DBKey: Integer read FDBKey write SetDBKey;
    property Logs[Index: Integer]: TReplLogRecord read GetLogs; default;
    property LogsBySeqno[Seqno: Integer]: TReplLogRecord read GetLogsBySeqno;
    property ChangesCount: Integer read GetChangesCount;
  end;

  TrpFieldData = class (TObject)
  private
    FData: TStream;
    FField: TrpField;
    FIsNull: Boolean;
    FRUID: string;
    function GetData: TStream;
    function GetValue: Variant;
    function GetValueStr: string;
    procedure SetIsNull(const Value: Boolean);
  public
    destructor Destroy; override;
    property Data: TStream read GetData;
    property Field: TrpField read FField write FField;
    property IsNull: Boolean read FIsNull write SetIsNull;
    property Value: Variant read GetValue;
    property ValueStr: string read GetValueStr;
    property ValueRUID: string read FRUID write FRUID;
  end;
  

  TrpFieldsData = class (TObjectList)
  private
    function GetFieldData(Index: Integer): TrpFieldData;
    procedure SetFieldData(Index: Integer; const Value: TrpFieldData);
  public
    function IndexOfData(FieldName: string): Integer;
    property FieldData[Index: Integer]: TrpFieldData read GetFieldData write 
            SetFieldData; default;
  end;
  
  TrpCortege = class (TObject)
  private
    FDeleteRefSQL: TIBSQL;
    FDeleteSQL: TIBSQL;
    FFieldsData: TrpFieldsData;
    FInsertSQL: TIBSQL;
    FKey: string;
    FKeyDivider: string;
    FKeyList: TStrings;
    FOnDeleteError: TrpErrorEvent;
    FOnPostError: TrpErrorEvent;
    FRefTableSQL: TIBSQL;
    FCheckForInsertSQL: TIBSQL;
    FRelation: TrpRelation;
    FRelationKey: Integer;
    FSelectSQL: TIBSQL;
    FSelectSQLAssigned: Boolean;
    FSQLAssigned: Boolean;
    FStates: TrpCortegeStates;
    FUpdateForeignKeySQL: TIBSQL;
    FUpdateSQL: TIBSQL;
    FIsEmptyFieldsData: boolean;
    function CheckFKRecordDeleted: Boolean;
    procedure CheckRefTableSQL;
    procedure CheckForInsertSQL;
    procedure CheckSelectSQL;
    procedure CheckSQL;
    function GetUIndexValue(UIndex: TrpUniqueIndex): string;
    procedure SaveForeignKey(FieldName: string; ID: Integer; Stream: TStream);
    procedure SelectFromDB;
    procedure SetKey(const Value: string);
    procedure SetOnDeleteError(const Value: TrpErrorEvent);
    procedure SetOnPostError(const Value: TrpErrorEvent);
    procedure SetRelationKey(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    function Delete: Boolean;
    procedure DeleteReference;
    function Insert: Boolean;
    procedure LoadFromDB;
    procedure LoadFromStream(Stream: TStream);
    //Сохраняет значения уникальных индексов
    //для текущей записи
    procedure SaveIndicesValue;
    procedure SaveToDataSet(DataSet: TDataSet);
    procedure SaveToDB(IBSQL: TIBSQL);
    procedure SaveToStream(Stream: TStream);
    function Update: Boolean;
    procedure UpdateForeignKey;
    property Key: string write SetKey;
    property OnDeleteError: TrpErrorEvent read FOnDeleteError write
            SetOnDeleteError;
    property OnPostError: TrpErrorEvent read FOnPostError write SetOnPostError;
    property RelationKey: Integer read FRelationKey write SetRelationKey;
    property Relation: TrpRelation read FRelation;
    property States: TrpCortegeStates read FStates;
    property FieldsData: TrpFieldsData read FFieldsData;
    property IsEmptyFieldsData: boolean read FIsEmptyFieldsData;
    function CheckFKRecords: Boolean;
  end;

  TrpStream = class (TObject)
  private
    FStream: TStream;
  public
    procedure Read(var Buffer; Count: Integer);
    procedure Write(var Buffer; Count: Integer);
  end;

  TrpEvent = class (TObject)
  private
    FActionTime: TDateTime;
    FKeyDivider: string;
    FKeyList: TStrings;
    FLogSQL: TIBSQL;
    FNewKey: string;
    FOldKey: string;
    FRelationKey: Integer;
    FReplType: string;
    FSeqno: Integer;
    procedure LoadKeyFromStream(var Key: string; const Stream: TStream);
    procedure SaveKeyToStream(const Key: string; const Stream: TStream);
    procedure SetSeqno(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(LogRecord: TReplLogRecord);
    procedure LoadFromStream(const Stream: TStream);
    procedure ReadFromDB(SQL: TIBSQL);
    procedure SaveToDb(SQL: TIBSQL);
    procedure SaveToStream(const Stream: TStream);
    property ActionTime: TDateTime read FActionTime write FActionTime;
    property NewKey: string read FNewKey;
    property OldKey: string read FOldKey;
    property RelationKey: Integer read FRelationKey;
    property ReplType: string read FReplType write FreplType;
    property Seqno: Integer read FSeqno write SetSeqno;
  end;

  TRUIDConformitys = class (TSortedList)
  private
    FRUIDConf: TRUIDConformity;
    function Get(Index: Integer): TRUIDConformity;
    procedure Put(Index: Integer; const Value: TRUIDConformity);
  protected
    procedure GetSortCompare; override;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    function Add(Item: TRUIDConformity): Integer;
    procedure Clear; override;
    procedure ClearField(DBKey: Integer);
    procedure Conformity(PID, SID: Integer; RelationKey: Integer; ReplKey: 
            Integer);
    procedure Delete(Index: Integer);
    procedure DeleteFromDB;
    procedure DeleteFromList(ReplId: Integer);
    function IndexOfConfRUID(RUID: TRUID): Integer;
    function IndexOfRUID(RUID: TRUID): Integer;
    procedure Invert;
    procedure LoadFromField(DBKey: Integer);
    procedure ReadFromStream(Stream: TStream);
    procedure RollBack(ReplID: Integer);
    procedure SaveToDB;
    procedure SaveToField(DBKey: Integer);
    procedure SaveToStream(Stream: TStream); overload;
    procedure SaveToStream(Stream: TStream; ReplID: Integer); overload;
    procedure SetReplKey(ReplID: Integer);
    property Items[Index: Integer]: TRUIDConformity read Get write Put; default;
  end;
  
  TIDIndices = class (TSortedList)
  protected
    procedure GetSortCompare; override;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    function Add(Id, RelationKey: Integer; RUIDIndex: PRUIDIndex): Integer;
    function IndexOfID(ID, RelationKey: Integer): Integer;
    procedure Insert(Index: Integer; Item: Pointer);
    function RUIDIndex(ID, RelationKey: Integer): PRUIDIndex;
  end;
  
  TRUIDIndices = class (TSortedList)
  protected
    procedure GetSortCompare; override;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    function Add(RUID: TRUID; IDIndex: PIDIndex): Integer;
    function IDIndex(RUID: TRUID): PIDIndex;
    function IndexOfRUID(RUID: TRUID): Integer;
    procedure Insert(Index: Integer; Item: Pointer);
  end;
  
  //Хранит информ. о конфликтной ситуации
  TRUIDCash = class (TObject)
  private
    FIDIndices: TIDIndices;
    FRUIDIndices: TRUIDIndices;
    procedure Check;
  public
    procedure Add(Id: Integer; RUID: TRUID);
    function GetIdByRUID(RUID: TRUID): Integer;
    function GetRUIDByID(ID, RelationKey: Integer): TRUID;
  end;
  
  TrpError = class (TObject)
  private
    FData: TStream;
    FErrorCode: Integer;
    FErrorDescription: string;
    FReplKey: Integer;
    function GetData: TStream;
    procedure SetReplKey(const Value: Integer);
  public
    destructor Destroy; override;
    procedure LoadFromDb(SQL: TIBSQL);
    procedure SaveToDb(SQL: TIBSQL);
    property Data: TStream read GetData;
    property ErrorCode: Integer read FErrorCode write FErrorCode;
    property ErrorDescription: string read FErrorDescription write 
            FErrorDescription;
    property ReplKey: Integer read FReplKey write SetReplKey;
  end;
  
  TrpErrorList = class (TObjectList)
  private
    function GetErrors(Index: Integer): TrpError;
  public
    procedure LoadFromDb(DBKey: Integer);
    procedure SaveToDb(DBKey: Integer);
    property Errors[Index: Integer]: TrpError read GetErrors; default;
  end;

  TrpRecordData = class (TObject)
  private
    FData: TStream;
    FUniqueInices: TrpUniqueIndices;
    function GetData: TStream;
    function GetUniqueInices: TrpUniqueIndices;
  public
    property Data: TStream read GetData;
    property UniqueInices: TrpUniqueIndices read GetUniqueInices;
  end;
  
  TrpRecordSet = class (TSortedList)
  private
    FRelationKey: Integer;
  protected
    procedure GetSortCompare; override;
  public
    destructor Destroy; override;
    property RelationKey: Integer read FRelationKey write FRelationKey;
  end;

  TrpRecordSetList = class (TSortedList)
  private
    FRecordSet: TrpRecordSet;
    function GetRelationsData(RelationKey: Integer): TrpRecordSet;
  protected
    procedure GetSortCompare; override;
  public
    destructor Destroy; override;
    function IndexOfRelation(RelationKey: Integer): Integer;
    property RelationsData[RelationKey: Integer]: TrpRecordSet read
            GetRelationsData;
  end;

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

function AskQuestionResult(Message: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): TModalResult;
function AskQuestion(Message, Caption: string): Boolean; overload;
function AskQuestion(Message: string): Boolean; overload;
function GetNewDBID: Integer;

function GetDataBaseName(Server, Path, Protocol: string): string;

function GetDiretionString(Direction: TReplDirection): string;
function GetErrorDecisionString(ED: TErrorDecision): string;
function GetDBStateString(DBState: TDBState): string;
function GetDBPriorityString(Priority: TrplPriority): string;

function ReadId(Stream: TStream): Integer;
procedure SaveID(ID, RelationKey: Integer; Stream: TStream);
procedure OriginNames(Origin: string; out TableName: string;
  out FieldName: string);
function FieldTypeStr(FieldType: Integer): string;
function FieldSubTypeStr(FieldType, FieldSubType: Integer): string;
function ReplTypeStr(ReplType: string): string;
function ShiftString(S: string; C: Integer): string;
procedure ReadComandLineLoginParams(CommandLines: TStrings);
function CommandString: TStrings;
function CompareAnyString(S1: String; S2: array of String): Boolean;

implementation
uses rpl_ResourceString_unit, Variants, rpl_GlobalVars_unit, rpl_ProgressState_Unit;
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

function GetDiretionString(Direction: TReplDirection): string;
begin
  case Direction of
    rdDual: Result := MSG_REPORT_DUAL;
    rdFromServer: Result := MSG_REPORT_FROMSERVER;
    rdToServer: Result := MSG_REPORT_TOSERVER;
  end;
end;

function GetErrorDecisionString(ED: TErrorDecision): string;
begin
  case ED of
    edServer: Result := MSG_REPORT_ERR_DECISION_SERVER;
    edPriority: Result := MSG_REPORT_ERR_DECISION_PRIORITY;
    edTime: Result := MSG_REPORT_ERR_DECISION_TIME;
  end;
end;

function GetDBStateString(DBState: TDBState): string;
begin
  case DBState of
    dbsMain: Result := dbs_Main;
    dbsSecondary: Result := dbs_Secondary;
  end;
end;

function GetDBPriorityString(Priority: TrplPriority): string;
begin
  case Priority of
    prHighest: Result := dbp_Highest;
    prHigh: Result := dbp_High;
    prNormal: Result := dbp_Normal;
    prLow: Result := dbp_Low;
    prLowest: Result := dbp_Lowest;
  end;
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

function AskQuestionResult(Message: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): TModalResult;
begin
  Result:= gvAskQuestionResult;
  if gvAskQuestion then
  begin
    Application.NormalizeTopMosts;
    Result := MessageDlg(Message, DlgType, Buttons, 0);
    Application.RestoreTopMosts;
  end;
end;

function AskQuestion(Message, Caption: string): Boolean;
begin
  Result := True;
  if gvAskQuestion then
  begin
    Application.NormalizeTopMosts;
    Result := MessageBox(Application.Handle, PChar(Message),
      PChar(Caption), MB_YESNO + MB_APPLMODAL + MB_ICONQUESTION) = ID_YES;
    Application.RestoreTopMosts;
  end;
end;

function AskQuestion(Message: string): Boolean; overload;
begin
  Result := AskQuestion(Message, Application.MainForm.Caption);
end;

procedure SaveID(ID, RelationKey: Integer; Stream: TStream);
var
  RUID: TRUID;
begin
  RUID := ReplDataBase.GetRUID(ID, RelationKey);
  Stream.WriteBuffer(RUID, SizeOf(RUID));
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

function ReplTypeStr(ReplType: string): string;
begin
  Result := '';
  case ReplType[1] of
    atInsert: Result := rtInsert;
    atUpdate: Result := rtUpdate;
    atDelete: result := rtDelete;
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

function ReadId(Stream: TStream): Integer;
var
  RUID: TRUID;
begin
  Stream.ReadBuffer(RUID, SizeOf(RUID));
  Result := ReplDataBase.GetId(RUID);
end;

function ReadIdAndRUID(Stream: TStream; var RUIDStr: string): Integer;
var
  RUID: TRUID;
begin
  Stream.ReadBuffer(RUID, SizeOf(RUID));
  Result := ReplDataBase.GetId(RUID);
  RUIDStr:= IntToStr(RUID.XID) + '_' + IntToStr(RUID.DBID) 
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

function DoSortLogFinal(Item1, Item2: Pointer): Integer;
var
  Rl1, RL2: TReplLogRecord;
begin
  Result:= 0;
  RL1 := TReplLogRecord(Item1^);
  RL2 := TReplLogRecord(Item2^);
  if (RL1.ReplType <> atDelete) and (RL2.ReplType <> atDelete) then begin
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
  end
  else if (RL1.ReplType = atDelete) and (RL2.ReplType <> atDelete) then Result:= 1
  else if (RL1.ReplType <> atDelete) and (RL2.ReplType = atDelete) then Result:= -1
  else if (RL1.ReplType = atDelete) and (RL2.ReplType = atDelete) then begin
    Result := RL2.RelationKey - RL1.RelationKey;
    if Result = 0 then begin
      if Double(RL1.ActionTime) - Double(RL2.ActionTime) > 0 then
        Result := 1
      else if Double(RL1.ActionTime) - Double(RL2.ActionTime) < 0 then
        Result := -1
      else begin
        Result := RL1.Seqno - RL2.Seqno;
      end;
    end;
  end;
end;

function RelationIndexesSortCompare(Item1, Item2: Pointer): Integer;
begin
  Result := TRelationIndex(Item1).FRelationKey - TRelationIndex(Item2).FRelationKey;
end;

function KeyIndexesOldKeyCompare(Item1, Item2: Pointer): Integer;
begin
  Result := CompareStr(TKeyIndex(Item1).OldKey, TKeyIndex(Item2).OldKey);
end;

function rpRelationIndexesSortCompare(Item1, Item2: Pointer): Integer;
begin
  Result := TrpRelation(Item1).FRelationKey - TrpRelation(Item2).FRelationKey;
end;

function rpFieldSortCompare(Item1, Item2: Pointer): Integer;
begin
  Result :=  CompareStr(TrpField(Item1).FFieldName, TrpField(Item2).FFieldName);
end;

function SeqnoIndicesSortCompare(Item1, Item2: Pointer): Integer;
begin
  Result := TSeqnoIndex(Item1).Seqno - TSeqnoIndex(Item2).Seqno;
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

function RelationDataSortCompare(Item1, Item2: Pointer): Integer;
var
  R1, R2: TrpRecordSet;
begin
  R1 := TrpRecordSet(Item1);
  R2 := TrpRecordSet(Item2);
  Result := R1.RelationKey - R2.RelationKey;
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
destructor TSeqnoIndices.Destroy;
begin
  FSeqnoIndex.Free;
  
  inherited;
end;

function TSeqnoIndices.GetSeqnos(Seqno: Integer): TSeqnoIndex;
var
  Index: Integer;
begin
  Index := IndexOfSeqno(Seqno);
  if Index > - 1 then
    Result := TSeqnoIndex(inherited Items[Index])
  else
    Result := nil;
end;

procedure TSeqnoIndices.GetSortCompare;
begin
  FSortCompare := SeqnoIndicesSortCompare;
end;

function TSeqnoIndices.IndexOfSeqno(Seqno: Integer): Integer;
begin
  if FSeqnoIndex = nil then
    FSeqnoIndex := TSeqnoIndex.Create;
  
  FSeqnoIndex.Seqno := Seqno;
  
  Result := inherited IndexOf(Pointer(Seqno));
end;

{
******************************* TrplStreamHeader *******************************
}
constructor TrplStreamHeader.Create;
begin
  Move(StreamLabel, FStreamInfo.StreamLabel, SizeOf(StreamLabel));
  FStreamInfo.Version := StreamVersion;
  FStreamInfo.PackType := sptNormal;
end;

procedure TrplStreamHeader.LoadFromStream(Stream: TStream);
begin
    { TODO :
Из за компрессии файла реплики
проверку на размер пришлось убрать
TDecomressionStream.Size возвращает 0 }

//  if Stream.Size < SizeOf(FStreamInfo) then
//   raise Exception.Create(InvalidStreamData);

  Stream.Read(FStreamInfo, SizeOf(FStreamInfo));
  if not CompareMem(@FStreamInfo.StreamLabel, @StreamLabel, SizeOf(StreamLabel)) then
    raise Exception.Create(InvalidStreamData);
  Stream.Read(FDBKey, SizeOf(FDBKey));
  Stream.Read(FLastProcessReplKey, SizeOf(FLastProcessReplKey));
  Stream.Read(FReplKey, SizeOf(FReplKey));
  Stream.Read(FSchema, SizeOf(FSchema));
  if FStreamInfo.Version > 2 then
    Stream.Read(FToDBKey, SizeOf(FToDBKey));
end;

procedure TrplStreamHeader.SaveToStream(Stream: TStream);
begin
  Stream.Write(FStreamInfo, SizeOf(FStreamInfo));
  Stream.Write(FDBKey, SizeOf(FDBKey));
  Stream.Write(FLastProcessReplKey, SizeOf(FLastProcessReplKey));
  Stream.Write(FReplKey, SizeOf(FReplKey));
  Stream.Write(FSchema, SizeOf(FSchema));
  Stream.Write(FToDBKey, SizeOf(FToDBKey));
end;

procedure TrplStreamHeader.SetDBKey(const Value: Integer);
begin
  FDBKey := Value;
end;

procedure TrplStreamHeader.SetLastProcessReplKey(const Value: Integer);
begin
  FLastProcessReplKey := Value;
end;

procedure TrplStreamHeader.SetReplKey(const Value: Integer);
begin
  FReplKey := Value;
end;

procedure TrplStreamHeader.SetSchema(const Value: Integer);
begin
  FSchema := Value;
end;

procedure TrplStreamHeader.SetStreamInfo(const Value: TStreamInfo);
begin
  FStreamInfo := Value;
end;

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
destructor TRelationIndex.Destroy;
begin
  FKeyIndexes.Free;
  
  inherited;
end;

function TRelationIndex.GeTKeyIndices: TKeyIndices;
begin
  if FKeyIndexes = nil then
    FKeyIndexes := TKeyIndices.Create;
  
  Result := FKeyIndexes;
end;

{
********************************* TKeyIndices **********************************
}
destructor TKeyIndices.Destroy;
begin
  FKeyIndex.Free;
  
  inherited;
end;

procedure TKeyIndices.GetSortCompare;
begin
  FSortCompare := KeyIndexesOldKeyCompare
end;

function TKeyIndices.IndexOfOldKey(OldKey: string): Integer;
begin
  if FKeyIndex = nil then
    FKeyIndex := TKeyIndex.Create;
  
  FKeyIndex.FOldKey := OldKey;
  
  Result := inherited IndexOf(FKeyIndex);
end;

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
    FIBSQL.SQL.Add(
      'SELECT ' +
      '  rplf.fieldname, f.rdb$field_type AS fieldtype, ' +
      '  f.rdb$field_sub_type as fieldsubtype, ' +
      '  (SELECT 1 FROM rdb$relation_constraints rc JOIN ' +
      '    rdb$index_segments i_s ON rc.rdb$index_name = i_s.rdb$index_name ' +
      '   WHERE rc.rdb$relation_name = rplr.relation AND rc.rdb$constraint_type = ' +
      '    ''PRIMARY KEY'' AND i_s.rdb$field_name = rplf.fieldname) AS IsPrimeKey, ' +
      '    rf.rdb$null_flag AS NotNull ' +
      'FROM rpl$fields rplf ' +
      '  JOIN rpl$relations rplr ON rplr.id = rplf.relationkey ' +
      '  JOIN rdb$relation_fields rf ON rf.rdb$relation_name = rplr.relation ' +
      '    AND rf.rdb$field_name = rplf.fieldname ' +
      '  JOIN rdb$fields f ON f.rdb$field_name = rf.rdb$field_source ' +
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
        F.FNotNull := FIBSQL.FieldByName(fnNotNull).AsInteger > 0;
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
    LoadUniqeIndices;
  
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

function TrpRelation.GetUniqueIndices: TrpUniqueIndices;
begin
  if FUniqueIndices = nil then
  begin
    FUniqueIndices := TrpUniqueIndices.Create;
  end;
  
  Result := FUniqueIndices;
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

procedure TrpRelation.LoadUniqeIndices;
var
  SQL: TIBSQL;
  Index, UIndex: Integer;
  U: TrpUniqueIndex;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := RepldataBase.ReadTransaction;
    //Загружаем уникальные ключи
    SQL.SQL.Text := SELECT_UNIQUE_INDICES;
    SQL.ParamByName(fnRelationName).AsString := RelationName;
    SQL.ExecQuery;
  
    while not SQL.Eof do
    begin
      Index := FFields.IndexOfField(Trim(SQL.FieldByName(fnName).AsString));
      if Index > - 1 then
      begin
        FFields[Index].FUnique := True;
        //Запоминаем уникальный индекс
        UIndex := UniqueIndices.IndexOf(Trim(SQL.FieldByName(fnIndexname).AsString));
        if UIndex = - 1 then
        begin
          U := TrpUniqueIndex.Create;
          U.IndexName := Trim(SQL.FieldByName(fnIndexName).AsString);
          UIndex := UniqueIndices.Add(U);
        end;
        UniqueIndices[UIndex].Fields.Add(FFields[Index]);
      end;
      
      SQL.Next;
    end;
  finally
    SQL.Free;
  end;
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
function TrpUniqueIndices.GetIndices(Index: Integer): TrpUniqueIndex;
begin
  Result := TrpUniqueIndex(Items[Index])
end;

function TrpUniqueIndices.IndexOf(IndexName: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if IndexName = Indices[I].IndexName then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TrpUniqueIndices.IndexOfByField(FieldName: String): Integer;
var
  I: Integer;
  Index: Integer;
begin
  Result := - 1;
  for I := 0 to Count - 1 do
  begin
    Index := Indices[I].Fields.IndexOfField(FieldName);
    if Index >  - 1 then
    begin
      Result := I;
      Break;
    end;
  end;
end;

{
******************************* TRelationIndices *******************************
}
destructor TRelationIndices.Destroy;
begin
  FRelationIndex.Free;
  
  inherited;
end;

procedure TRelationIndices.GetSortCompare;
begin
  FSortCompare := RelationIndexesSortCompare;
end;

function TRelationIndices.IndexOfRelation(RelationKey: Integer): Integer;
begin
  if FRelationIndex = nil then
    FRelationIndex := TRelationIndex.Create;
  
  FRelationIndex.FRelationKey := RelationKey;
  
  Result := inherited IndexOf(FRelationIndex);
end;

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
procedure TSeqnoIndex.SetIndex(const Value: Integer);
begin
  FIndex := Value;
end;

procedure TSeqnoIndex.SetSeqno(const Value: Integer);
begin
  FSeqno := Value;
end;

{
******************************** TReplDataBase *********************************
}
destructor TReplDataBase.Destroy;
begin
  FReadSQL.Free;
  FReadTransaction.Free;
  FTransaction.Free;
  FRelations.Free;
  FRUIDManager.Free;
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

function TReplDataBase.CanRepl(AFromDBID, AToDBID: Integer): Boolean;
begin
  CheckReplicationDbList;
  Result := (FReplicationDBList.IndexOfDb(AFromDBID) > - 1) and
    (DataBaseInfo.DBID <> AFromDBID) and (DataBaseInfo.DBID = AToDBID);
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
  try
    FReadSQl.ExecQuery;
    Result:= FReadSQL.Fields[0].AsInteger;
  except
    Result:= -1;
  end;
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
  
    FreeAndNil(FRUIDManager);
    FreeAndNil(FRelations);
    FreeAndNil(FReplicationDBList);
    FreeAndNil(FLog);
  
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
      Direction:= TReplDirection(FReadSQL.FieldByName(fnDirection).AsInteger);
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
    S.Add(Format(MSG_REPORT_ERROR_DECISION, [GetErrorDecisionString(ErrorDecision)]));
    S.Add(Format(MSG_REPORT_REPL_KEY, [Schema]));
    S.Add(Format(MSG_REPORT_REPLTYPE, [GetDiretionString(DataBaseInfo.Direction)]));
    S.Add('');
  
    S.Add(Format(MSG_REPORT_CURRENT_DB_ALIAS, [FReplicationDBList[DBID].DBName]));
    S.Add(Format(MSG_REPORT_DB_KEY, [DBID]));
    S.Add(Format(MSG_REPORT_DB_STATE, [GetDBStateString(DBState)]));
    S.Add(Format(MSG_REPORT_DB_PRIORITY,
      [GetDBPriorityString(TrplPriority(FReplicationDBList[DBID].Priority))]));
  end;
  S.Add('');
  S.Add(MSG_REPORT_TRANSFER_DATA_TO);
  
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
  S.Add(Format(MSG_REPORT_DB_ALIAS, [DB.DBName]));
  S.Add(Format(MSG_REPORT_DB_KEY, [DB.DBKey]));
  S.Add(Format(MSG_REPORT_DB_STATE, [GetDBStateString(DB.DBState)]));
  S.Add(Format(MSG_REPORT_DB_PRIORITY, [GetDBPriorityString(TrplPriority(DB.Priority))]));
  if (DataBaseInfo.Direction = rdDual) or
     ((DataBaseInfo.Direction = rdFromServer) and (DataBaseInfo.DBState = dbsMain)) or
     ((DataBaseInfo.Direction = rdToServer) and (DataBaseInfo.DBState = dbsSecondary)) then begin
    S.Add(Format(MSG_REPORT_REGISTRED_CHANGES_COUNT, [CountChanges(DBKey)]));
    S.Add(Format(MSG_REPORT_REPL_COUNT, [DB.ReplKey - 1]));
    if DB.ReplKey > 1 then begin
      S.Add(Format(MSG_REPORT_LAST_REPL_DATE, [DateTimeToStr(DB.ReplData)]));
      S.Add(Format(MSG_REPORT_NOT_COMMIT, [NotCommitedTransaction(DBKey)]));
    end;
  end;
  if (DataBaseInfo.Direction = rdDual) or
     ((DataBaseInfo.Direction = rdFromServer) and (DataBaseInfo.DBState = dbsSecondary)) or
     ((DataBaseInfo.Direction = rdToServer) and (DataBaseInfo.DBState = dbsMain)) then begin
    S.Add(Format(MSG_REPORT_PROCESS_REPL_COUNT, [DB.LastProcessReplKey]));
    if DB.LastProcessReplKey > 0 then begin
      S.Add(Format(MSG_REPORT_LAST_PROCESS_REPL_DATE, [DateTimeToStr(DB.LastProcessReplData)]));
      S.Add(Format(MSG_REPORT_CONFLICT_COUNT, [ConflictCount(DBKey)]));
    end;
  end;
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

function TReplDataBase.GetId(RUID: TRUID): Integer;
begin
  Result := RUIDManager.GetID(RUID);
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

function TReplDataBase.GetLog: TReplLog;
begin
  if FLog = nil then
  begin
    FLog := TReplLog.Create;
  end;
  Result := FLog;
end;

function TReplDataBase.GetNextID(RelationKey: Integer = 0): Integer;
begin
  Result := RUIDManager.GetNextId(RelationKey);
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

function TReplDataBase.GetreplFileInfo(const S: TStrings; FileName: string): Boolean;
var
  F, ZF: TStream;
  Header: TrplStreamHeader;
  LastReplKey: Integer;
  iCount: Integer;
  Db: TReplicationDB;
begin
  Result := True;
  if SysUtils.FileExists(FileName) then
  begin
    F := TFileStream.Create(FileName, fmOpenRead);
    ZF:= TDecompressionStream.Create(F);
    try
      Header := TrplStreamHeader.Create;
      try
        try
          try
            Header.LoadFromStream(ZF);
          except
            raise Exception.Create(Format(ERR_ON_READING_FILE, [FileName]));
          end;

          {$IFDEF CHECKSTREAM}
          if Header.StreamInfo.Version <> StreamVersion then
            raise Exception.Create(InvalidStreamVersion);
          {$ENDIF}
          if not CanRepl(Header.DBKey, Header.ToDBKey) then
             raise Exception.Create(InvalidDataBaseKey);
          //Проверяем ключ схемы репликации
          if Header.Schema <> DataBaseInfo.Schema then
            raise Exception.Create(InvalidSchema);

          LastReplKey := LastProcessReplKey[Header.DBKey];
          if Header.ReplKey < LastReplKey + 1 then
            raise Exception.Create(AlreadyReplicated)
          else
          if Header.ReplKey > LastReplKey + 1 then
            raise Exception.Create(Format(MissingFiles, [Header.ReplKey - LastReplKey - 1]));

          if ReplKey(Header.DBKey) - 1 > Header.LastProcessReplKey then
            raise Exception.Create(OneNotConfirmedTransaction);

          ZF.Read(iCount, SizeOf(iCount));

          S.Add(Format(MSG_REPORT_DB_FILE_NAME, [FileName]));
          DB := DBList[Header.DBKey];

          S.Add(Format(MSG_REPORT_DB_ALIAS, [DB.DBName]));
          S.Add(Format(MSG_REPORT_DB_KEY, [DB.DBKey]));
          S.Add(Format(MSG_REPORT_DB_STATE, [GetDBStateString(DB.DBState)]));
          S.Add(Format(MSG_REPORT_DB_PRIORITY, [GetDBPriorityString(TrplPriority(DB.Priority))]));

          if iCount > -1 then
            S.Add(' ' + Format(NRecordPassed, [iCount]));
          Result := True;
        except
          on E: Exception do
          begin
            S.Add(E.Message);
            Result := False;
          end;
        end;
      finally
        Header.Free;
      end;
    finally
      ZF.Free;
      F.Free;
    end;
  end else
  begin
    Result := False;
    S.Add(Format(MSG_FILE_NOT_FOUND, [FileName]));
  end;
  if not Result then S.Add(CANT_REPL);
end;

function TReplDataBase.GetreplFileInfo(const S: TStrings; FileName: string; ALastReplKey: Integer): Boolean;
var
  F, ZF: TStream;
  Header: TrplStreamHeader;
  iCount: Integer;
  Db: TReplicationDB;
begin
  Result := True;
  if SysUtils.FileExists(FileName) then
  begin
    F := TFileStream.Create(FileName, fmOpenRead);
    ZF:= TDecompressionStream.Create(F);
    try
      Header := TrplStreamHeader.Create;
      try
        try
          try
            Header.LoadFromStream(ZF);
          except
            raise Exception.Create(Format(ERR_ON_READING_FILE, [FileName]));
          end;

          {$IFDEF CHECKSTREAM}
          if Header.StreamInfo.Version <> StreamVersion then
            raise Exception.Create(InvalidStreamVersion);
          {$ENDIF}
          if not CanRepl(Header.DBKey, Header.ToDBKey) then
             raise Exception.Create(InvalidDataBaseKey);
          //Проверяем ключ схемы репликации
          if Header.Schema <> DataBaseInfo.Schema then
            raise Exception.Create(InvalidSchema);

          if Header.ReplKey < ALastReplKey + 1 then
            raise Exception.Create(AlreadyReplicated)
          else
          if Header.ReplKey > ALastReplKey + 1 then
            raise Exception.Create(Format(MissingFiles, [Header.ReplKey - ALastReplKey - 1]));

          if ReplKey(Header.DBKey) - 1 > Header.LastProcessReplKey then begin
            if ReplKey(Header.DBKey) - Header.LastProcessReplKey - 1 = 1 then
              raise Exception.Create(OneNotConfirmedTransaction)
            else
              raise Exception.Create(Format(ManyNotConfirmedTransaction, [ReplKey(Header.DBKey) - Header.LastProcessReplKey - 1]));
          end;

          ZF.Read(iCount, SizeOf(iCount));

          S.Add(Format(MSG_REPORT_DB_FILE_NAME, [FileName]));
          DB := DBList[Header.DBKey];

          S.Add(Format(MSG_REPORT_DB_ALIAS, [DB.DBName]));
          S.Add(Format(MSG_REPORT_DB_KEY, [DB.DBKey]));
          S.Add(Format(MSG_REPORT_DB_STATE, [GetDBStateString(DB.DBState)]));
          S.Add(Format(MSG_REPORT_DB_PRIORITY, [GetDBPriorityString(TrplPriority(DB.Priority))]));

          if iCount > -1 then
            S.Add('  ' + Format(NRecordPassed, [iCount]));
          Result := True;
        except
          on E: Exception do
          begin
            S.Add(E.Message);
            Result := False;
          end;
        end;
      finally
        Header.Free;
      end;
    finally
      ZF.Free;
      F.Free;
    end;
  end else
  begin
    Result := False;
    S.Add(Format(MSG_FILE_NOT_FOUND, [FileName]));
  end;
  if not Result then S.Add(CANT_REPL);
end;

function TReplDataBase.GetRUID(Id: Integer; RelationId: Integer = 0): TRUID;
begin
  Result := RUIDManager.GetRUID(Id, RelationId);
end;

function TReplDataBase.GetRUIDManager: TRUIDManager;
begin
  if FRUIDManager = nil then
  begin
    case DataBaseInfo.PrimeKeyType of
      ptNatural: FRUIDManager := nil;
      ptUniqueInDb:
      begin
        FRUIDManager := TRUIDManagerDBU.Create;
        FRUIDManager.DataBase := Self;
      end;
      ptUniqueInRelation:
      begin
        FRUIDManager := TRUIDManagerRU.Create;
        FRUIDManager.DataBase := Self;
      end;
    end;
  end;
  
  Result := FRUIDManager;
end;

procedure TReplDataBase.GetShortDbReport(const S: TStrings; DBKey: Integer);
var
  Db: TReplicationDB;
begin
  {$IFDEF DEBUG}
  Exit;
  {$ENDIF}
  DB := DBList[DBKey];
  if (DataBaseInfo.Direction = rdDual) or
     ((DataBaseInfo.Direction = rdFromServer) and (DataBaseInfo.DBState = dbsMain)) or
     ((DataBaseInfo.Direction = rdToServer) and (DataBaseInfo.DBState = dbsSecondary)) then begin
    S.Add(Format(MSG_REPORT_REGISTRED_CHANGES_COUNT, [CountChanges(DBKey)]));
    S.Add(Format(MSG_REPORT_REPL_COUNT, [DB.ReplKey - 1]));
    if DB.ReplKey > 1 then begin
      S.Add(Format(MSG_REPORT_LAST_REPL_DATE, [DateTimeToStr(DB.ReplData)]));
      S.Add(Format(MSG_REPORT_NOT_COMMIT, [NotCommitedTransaction(DBKey)]));
    end;
  end;
  if (DataBaseInfo.Direction = rdDual) or
     ((DataBaseInfo.Direction = rdFromServer) and (DataBaseInfo.DBState = dbsSecondary)) or
     ((DataBaseInfo.Direction = rdToServer) and (DataBaseInfo.DBState = dbsMain)) then begin
    S.Add(Format(MSG_REPORT_PROCESS_REPL_COUNT, [DB.LastProcessReplKey]));
    if DB.LastProcessReplKey > 0 then begin
      S.Add(Format(MSG_REPORT_LAST_PROCESS_REPL_DATE, [DateTimeToStr(DB.LastProcessReplData)]));
      S.Add(Format(MSG_REPORT_CONFLICT_COUNT, [ConflictCount(DBKey)]));
    end;
  end;
{  S.Add(Format(MSG_REPORT_REGISTRED_CHANGES_COUNT, [CountChanges(DBKey)]));
  S.Add(Format(MSG_REPORT_NOT_COMMIT, [NotCommitedTransaction(DBKey)]));
  S.Add(Format(MSG_REPORT_CONFLICT_COUNT, [ConflictCount(DBKey)]));}
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
    SQL.SQL.Add('UPDATE rpl$replicationdb ' +
      ' SET replkey = replkey + 1, repldate = :date ' +
      ' WHERE dbkey = ' +  IntToStr(DBKey));
    SQL.ParamByName('date').AsDateTime:= Now;
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
    SQL.SQL.Add('UPDATE rpl$replicationdb ' +
      ' SET LastProcessReplKey = ' + IntToStr(ReplKey) +
      ' , LastProcessReplDate = :date' +
      ' WHERE dbkey = ' + IntToStr(DBKey));
    SQL.ParamByName('date').AsDateTime:= Now;
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
function TrpFieldsData.GetFieldData(Index: Integer): TrpFieldData;
begin
  Result := TrpFieldData(inherited Items[Index]);
end;

function TrpFieldsData.IndexOfData(FieldName: string): Integer;
var
  I: Integer;
begin
  Result := - 1;
  for I := 0 to Count - 1 do
  begin
    if FieldName = FieldData[I].Field.FieldName then
    begin
      Result := I;
      Break;
    end;
  end;
end;

procedure TrpFieldsData.SetFieldData(Index: Integer; const Value: TrpFieldData);
begin
  
end;

{
*********************************** TReplLog ***********************************
}
destructor TReplLog.Destroy;
begin
  FRelationIndexes.Free;
  FSeqnoIndices.Free;
  FInsertLogHistSQL.Free;
  FUpdateLogHistSQL.Free;
  FDeleteLogHistSQL.Free;
  FInsertLogSQL.Free;
  
  inherited;
end;

function TReplLog.Add(Item: TReplLogRecord): Integer;
var
  RL: PReplLogRecord;
begin
  New(RL);
  RL^ := Item;
  Result := inherited Add(RL);
end;

procedure TReplLog.CheckLogHistSQL;
begin
  if FInsertLogHistSQL = nil then
  begin
    FInsertLogHistSQL := TIBSQL.Create(nil);
    FInsertLogHistSQL.Transaction := ReplDataBase.Transaction;
    FInsertLogHistSQL.SQL.Add('INSERT INTO rpl$loghist (seqno, dbkey, ' +
      'replkey, tr_commit) VALUES (:seqno, :dbkey, :replkey, :tr_commit)');
  end;
  
  if FUpdateLogHistSQL = nil then
  begin
    FUpdateLogHistSQL := TIBSQL.Create(nil);
    FUpdateLogHistSQL.Transaction := ReplDataBase.Transaction;
    FUpdateLogHistSQL.SQL.Add('UPDATE rpl$loghist SET tr_commit = :tr_commit ' +
      ' WHERE seqno = :seqno AND dbkey = :dbkey');
  end;
  FInsertLogHistSQL.Close;
  FUpdateLogHistSQL.Close;
end;

procedure TReplLog.Clear;
begin
  while Count > 0 do
    Delete(Count - 1);
  inherited;
end;

procedure TReplLog.Delete(Index: Integer);
begin
  Dispose(PReplLogRecord(inherited Items[Index]));
  inherited Delete(Index);
end;

procedure TReplLog.EnterHistLog(SeqNo, CorrDBKey, ReplicaKey: Integer;
        TrCommit: Integer);
begin
  // tr_commit = -1 - инф. не передана
  // tr_commit =  0 - инф. передана
  // tr_commit =  1 - получено подтверждение
  { TODO -cНа заметку :
  Идеалогия поменялась.
  Т.к. в репллог поподают записи, которые ещё не передавались, то
  дополнительноу проверки  на наличие записи в rpl_loghist производить ненадо.

  Для главной базы перед удалением записи из rpl_log предварительно
  необходимо убедится в том, что информация об изменении передана
  на все второстепенные базы и пришло подтверждение со всех второстепенных баз.
  Это можно сделать проверкой кол-ва записей в rpl_loghist с заданным seqno и
  dbkey у которых tr_commit = 1 }
  CheckLogHistSQL;
  FInsertLogHistSQL.ParamByName(fnSeqno).AsInteger := SeqNo;
  FInsertLogHistSQL.ParamByName(fnDBKey).AsInteger := CorrDBKey;
  FInsertLogHistSQL.ParamByName(fnReplKey).AsInteger := ReplicaKey;
  FInsertLogHistSQL.ParamByName(fnTR_Commit).AsInteger := TrCommit;
  FInsertLogHistSQL.ExecQuery;
end;

function TReplLog.GetLogs(Index: Integer): TReplLogRecord;
begin
  Result := TReplLogRecord(inherited Items[Index]^);
end;

function TReplLog.GetLogsBySeqno(Seqno: Integer): TReplLogRecord;
var
  Index: Integer;
begin
  Index := IndexOfSeqno(Seqno);
  if Index > - 1 then
    Result := TReplLogRecord(inherited Items[Index]^)
  else
    raise Exception.Create(SeqnoNotFound);
end;

function TReplLog.IndexOfOldKey(RelationKey: Integer; OldKey: string): Integer;
var
  I: Integer;
  LRelationKey: Integer;
  LNewKey: string;
  RI: TRelationIndex;
  KI: TKeyIndex;
  RIndex, KIndex: Integer;
begin
  if FRelationIndexes =  nil then
  begin
    FRelationIndexes := TRelationIndices.Create;

    LRelationKey := 0;
    LNewKey := '';
    { TODO -oTipTop -cВажно :
      Данный код основан на предположении что ид таблицы больше 0, а
      ключ не может быть равен пустой строке. Может я неправ?
      Вовсяком случае ключ не может быть NULL}
    { TODO -cВнимание :
    ВНИМАНИЕ!!!!
    В новых дятлах возможно создание уникального индекса
    который может содержать значение NULL }
    RI := nil;
    KI := nil;
    for I := 0 to Count - 1 do
    begin
      if not PReplLogRecord(Items[I])^.NeedDelete then
      begin
        if LRelationKey <> PReplLogRecord(Items[I])^.RelationKey then
        begin
          RI := TRelationIndex.Create;
          RI.RelationKey := PReplLogRecord(Items[I])^.RelationKey;
          RI.FIndex := I;
          FRelationIndexes.Add(RI);
          LRelationKey := PReplLogRecord(Items[I])^.RelationKey;
        end;
        if (LNewKey <> Logs[I].OldKey) and (RI <> nil) then
        begin
          KI := TKeyIndex.Create;
          RI.KeyIndexes.Add(KI);
          KI.OldKey := PReplLogRecord(Items[I])^.OldKey;
          KI.FIndex := I;
        end;
        if KI <> nil then
          KI.FNewKey := PReplLogRecord(Items[I])^.NewKey;
        LNewKey := PReplLogRecord(Items[I])^.NewKey;
      end;
    end;
  end;

  Result := - 1;
  RIndex := FRelationIndexes.IndexOfRelation(RelationKey);
  if RIndex > - 1 then
  begin
    RI := TRelationIndex(FRelationIndexes[RIndex]);
    KIndex := RI.KeyIndexes.IndexOfOldKey(OldKey);
    if KIndex > - 1 then
    begin
      KI := TKeyIndex(RI.KeyIndexes[KIndex]);
      Result := KI.Index;
    end;
  end;
end;

function TReplLog.IndexOfSeqno(Seqno: Integer): Integer;
var
  I: Integer;
  S: TSeqnoIndex;
begin
  if FSeqnoIndices = nil then
  begin
    FSeqnoIndices := TSeqnoIndices.Create;
    for I := 0 to Count - 1 do
    begin
      if not PReplLogRecord(Items[I])^.NeedDelete then
      begin
        S := TSeqnoIndex.Create;
        S.Seqno := Logs[I].Seqno;
        S.Index := I;
      end;
    end;
  end;

  Result := FSeqnoIndices.Seqnos[Seqno].Index;
end;

function TReplLog.Log(Event: TrpEvent): Integer;
begin
  { TODO : Если корбаза одна, то регестрировать изменения не надо }
  if FInsertLogSQL = nil then
  begin
    FInsertLogSQL := TIBSQL.Create(nil);
    FInsertLogSQL.Transaction := ReplDataBase.Transaction;
    FInsertLogSQL.SQL.Add('INSERT INTO rpl$log (seqno, repltype, relationkey, newkey, ' +
      'oldkey, actiontime, DBKEY) VALUES(:seqno, :repltype, :relationkey, :newkey, ' +
      ':oldkey, :actiontime, :dbkey)');
  end;

  Result := ReplDataBase.NextSeqNo;
  FInsertLogSQL.ParamByName(fnSeqNo).AsInteger := Result;
  FInsertLogSQL.ParamByName(fnRelationKey).AsInteger := Event.FRelationKey;
  FInsertLogSQL.ParamByName(fnOldKey).AsString := Event.FOldKey;
  FInsertLogSQL.ParamByName(fnNewKey).AsString := Event.FNewKey;
  FInsertLogSQL.ParamByName(fnRepltype).AsString := Event.FReplType;
  FInsertLogSQL.ParamByName(fnActionTime).AsDateTime := Event.FActionTime;

  FInsertLogSQL.ParamByName(fnDBKey).AsInteger := FDbKey;


  FInsertLogSQL.ExecQuery;
  FInsertLogSQL.Close;
end;

procedure TReplLog.Pack(ReplKey: Integer);
var
  I: Integer;
  RL1, RL2: PReplLogRecord;
  
  {$IFDEF DEBUG}
  procedure Invalid(exp: Boolean);
  begin
    if exp then
    begin
      raise Exception.Create(Format('Ошибка'#13#10'за операцией %s идет %s'#13#10 +
        '№ первой операции %d, № второй %d', [RL1^.ReplType, RL2^.ReplType,
        RL1^.Seqno, RL2^.Seqno]));
    end;
  end;
  {$ENDIF}
  
begin
  ProgressState.MaxMinor := Count;
  if FRelationIndexes <> nil then
    FreeAndNil(FRelationIndexes);
  if FSeqnoIndices <> nil then
    FreeAndNil(FSeqnoIndices);
  I := 0;
  { DONE :
  Удалять записи не надо. просто помечать что изменения были
  переданы }
  while I < Count - 1 do
  begin
    RL1 := inherited Items[I];
    if (RL1^.ReplType = atInsert) then
    begin
      Inc(I);
      ProgressState.MinorProgress(Self);
      if I < Count then
        RL2 := inherited Items[I]
      else
        RL2 := nil;

      while (I < Count) and  (RL2 <> nil) and (RL1^.RelationKey = RL2^.RelationKey) and
        ((RL1^.OldKey = RL2^.NewKey) or (RL1^.NewKey = RL2^.OldKey)) do
      begin
        if (RL2^.ReplType = atUpdate) or (RL2^.ReplType = atInsert) then
        begin
          //Запись была вставлена и изменена с момента последней репликации
          //поэтому  в команду инсерта перепишим время модификации и ключи записи
          //и удалим информ. об изменении
          if RL1^.Seqno < RL2^.Seqno then begin
            RL1^.NewKey := RL2^.NewKey;
            RL1^.ActionTime := RL2^.ActionTime;
          end;
          RL2^.NeedDelete := True;
          Inc(I);
          ProgressState.MinorProgress(Self);
          //После удаления записи I указывает на другую запись поэтому
          //обновляем информацию о записи
          if I < Count then
            RL2 := inherited Items[I];
        end else
        if RL2^.ReplType = atDelete then
        begin
          //Запись была вставлена и удалена с момента последней репликации
          //поэтому  удаляем информацию о записи
          RL1^.NeedDelete := True;
          ProgressState.MinorProgress(Self);
          RL2^.NeedDelete := True;
          Inc(I);

          ProgressState.MinorProgress(Self);
          Break;
        end;
      end;
    end else
    if RL1^.ReplType = atUpdate then
    begin
      Inc(I);
      ProgressState.MinorProgress(Self);
      if I < Count then
        RL2 := inherited Items[I]
      else
        RL2 := nil;

      while (I < Count) and (RL2 <> nil) and (RL1^.RelationKey = RL2^.RelationKey)and
        ((RL1^.OldKey = RL2^.NewKey) or (RL1^.NewKey = RL2^.OldKey)) do
      begin
        if (RL2^.ReplType = atUpdate) or (RL2^.ReplType = atInsert) then
        begin
          //Запись была вставлена и изменена с момента последней репликации
          //поэтому  в команду инсерта перепишим время модификации и ключи записи
          //и удалим информ. об изменении
          if RL1^.Seqno < RL2^.Seqno then begin
            RL1^.NewKey := RL2^.NewKey;
            RL1^.ActionTime := RL2^.ActionTime;
          end;
          RL2^.NeedDelete := True;
          Inc(I);
          ProgressState.MinorProgress(Self);
          //После удаления записи I указывает на другую запись поэтому
          //обновляем информацию о записи
          if I < Count then
            RL2 := inherited Items[I];
        end else
        if RL2^.ReplType = atDelete then
        begin
          //Запись была ИЗМЕНЕНА и удалена с момена последней
          //репликации поэтому просто оставляем информацию об удалении
          RL1^.NeedDelete := True;
          Inc(I);
          ProgressState.MinorProgress(Self);
          Break;
        end;
      end;
    end else
    begin
      //Запись была удалена. Переходим на слудующую запись
      Inc(I);
      ProgressState.MinorProgress(Self);
      if I < Count then
        RL2 := inherited Items[I]
      else
        RL2 := nil;

      while (I < Count) and (RL2 <> nil) and (RL1^.RelationKey = RL2^.RelationKey)and
        (RL1^.OldKey = RL2^.NewKey) do
      begin
        if (RL2^.ReplType = atUpdate) or (RL2^.ReplType = atInsert) then
        begin
          //Если в репл. участвуют более 2 баз то на обной запись
          //могла быть удалена а на другой изменена
          RL1^.NeedDelete := True;
          Inc(I);
          ProgressState.MinorProgress(Self);
          Break;
        end else
        if RL2^.ReplType = atDelete then
        begin
          //Если в репл. участвуют более 2 баз то на двух
          //базах запись могла быть удалена
          RL1^.NewKey := RL2^.NewKey;
          RL1^.ActionTime := RL2^.ActionTime;
          RL2^.NeedDelete := True;
          Inc(I);
          ProgressState.MinorProgress(Self);
          //После удаления записи I указывает на другую запись поэтому
          //обновляем информацию о записи
          if I < Count then
            RL2 := inherited Items[I];
        end;
      end;
    end;
  end;
end;

procedure TReplLog.PackDB;
var
  SQL: TIBSQL;
const
  cDbCount = 'dbcount';
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReplDataBase.Transaction;
    SQL.SQL.Add('DELETE FROM rpl$log l WHERE (SELECT COUNT(*) FROM rpl$loghist lh ' +
      ' WHERE lh.tr_commit = 1 AND l.seqno = lh.seqno) = :dbcount');
   if ReplDataBase.DataBaseInfo.DBState = dbsMain then
     SQL.ParamByName(cDbCount).AsInteger := ReplDataBase.ReplicationDBCount - 1
   else
     SQL.ParamByName(cDbCount).AsInteger := 1;
   SQL.ExecQuery;
  finally
    SQL.Free;
  end;
end;

procedure TReplLog.ReadFromDB;
var
  SQL: TIBSQL;
  RL: TReplLogRecord;
begin
  SQL := TIBSQL.Create(nil);
  try
    Clear;
    SQL.Transaction := ReplDataBase.ReadTransaction;
    { TODO -cЭксперемент -oTipTop :
      Нужно поэксперементировать на больших данных. Возможно
      запрос SELECT rl.* FROM rpl_log rl WHERE NOT EXISTS( SELECT lh.seqno
      FROM rpl_loghist lh WHERE (lh.seqno = rl.seqno) AND
      (lh.dbkey = :dbkey) AND (tr_commit <> -1) ) работает быстрее }
 {   SQL.SQL.Text := 'SELECT SEQNO, RELATIONKEY, REPLTYPE, OLDKEY, NEWKEY, ' +
      ' ACTIONTIME FROM rpl$log l WHERE NOT l.seqno IN(SELECT lh.seqno FROM ' +
      ' rpl$loghist lh WHERE lh.dbkey = :dbkey AND lh.tr_commit <> - 1) ';}

     SQL.SQL.Text := 'SELECT l.* FROM rpl$log l WHERE ' +
       ' NOT EXISTS(SELECT lh.seqno ' +
       '     FROM rpl$loghist lh WHERE (lh.seqno = l.seqno) AND ' +
       '     (lh.dbkey = :dbkey) AND (lh.tr_commit <> -1) ) ' +
       ' and ((l.dbkey <> :dbkey1) or (l.dbkey is null)) ';

    SQl.ParamByName('dbkey').AsInteger := FDBKey;
    SQl.ParamByName('dbkey1').AsInteger := FDBKey;
    SQL.ExecQuery;
    while not SQL.Eof do
    begin
      RL.NeedDelete := False;
      ReadLogRecordFromSQL(RL, SQL);
      Add(Rl);
      SQL.Next;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TReplLog.ReadLogRecordFromSQL(var RL: TReplLogRecord; SQL: TIBSQL);
begin
  RL.Seqno := SQL.FieldByName(fnSeqNo).AsInteger;
  RL.ReplType := SQL.FieldByName(fnRepltype).AsString[1];
  RL.RelationKey := SQL.FieldByName(fnRelationKey).AsInteger;
  case RL.ReplType of
    atInsert:
    begin
      RL.NewKey := SQL.FieldByName(fnNewKey).AsString;
      RL.OldKey := RL.NewKey;
    end;
    atUpdate:
    begin
      RL.NewKey := SQL.FieldByName(fnNewKey).AsString;
      RL.OldKey := SQL.FieldByName(fnOldKey).AsString;
    end;
    atDelete:
    begin
      RL.NewKey := SQL.FieldByName(fnOldKey).AsString;
      RL.OldKey := RL.NewKey;
    end;
  end;
  RL.ActionTime := SQL.FieldByName(fnActionTime).AsDateTime;
end;

procedure TReplLog.SetDBKey(const Value: Integer);
begin
  if ReplDataBase.CanRepl(Value) then
  begin
    if FDBKey <> Value then
    begin
      FDBKey := Value;
      ReadFromDB;
    end;
  end else
    raise Exception.Create(InvalidDataBaseKey);
end;

procedure TReplLog.SortLog;
begin
  if FRelationIndexes <> nil then
    FreeAndNil(FRelationIndexes);
  if FSeqnoIndices <> nil then
    FreeAndNil(FSeqnoIndices);

  Sort(DoSortLog);
end;

procedure TReplLog.SortLogFinal;
begin
  Sort(DoSortLogFinal);
end;

procedure TReplLog.TransactionCommit(DBKey, ReplKey: Integer);
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReplDataBase.Transaction;
    SQL.SQL.Add(Format('UPDATE rpl$loghist SET tr_commit = 1 ' +
      'WHERE dbkey = %d and replkey <= %d', [DBKey, ReplKey]));
    SQL.ExecQuery;
  finally
    SQl.Free;
  end;
end;

{
********************************* TrpFieldData *********************************
}
destructor TrpFieldData.Destroy;
begin
  FData.Free;
  
  inherited;
end;

function TrpFieldData.GetData: TStream;
begin
  if FData = nil then
    FData := TMemoryStream.Create;
  Result := FData;
end;

function TrpFieldData.GetValue: Variant;
var
  IntBuf: Integer;
  FloatBuf: Double;
  StringBuf: string;
  DateTimeBuf: TDateTime;
begin
  Result := Null;
  if Data.Size = 0 then Exit;
  
  Data.Position := 0;
  case FField.FieldType of
    7, 8, 9, 16:
    begin
      if not IsNull then
      begin
        Data.ReadBuffer(IntBuf, SizeOf(IntBuf));
        Result := IntBuf;
      end;
    end;
    10, 11, 27:
    begin
      if not IsNull then
      begin
        Data.ReadBuffer(FloatBuf, SizeOf(FloatBuf));//с плав. точкой
        Result := FloatBuf;
      end;
    end;
    14, 37, 40:
    begin
      if not IsNull then
      begin
        SaveStringToStream(StringBuf, Data);//строковое
        Result := StringBuf;
      end;
    end;
    12, 13, 35:
    begin
      if not IsNull then
      begin
        Data.WriteBuffer(DateTimeBuf, SizeOf(DateTimeBuf));
        Result := DateTimeBuf;
      end;
    end;
    tfBlob: raise Exception.Create(CantReturnBlobValue);
  end;
end;

function TrpFieldData.GetValueStr: string;
var
  IntBuf: Integer;
  Int64Buf: Int64;
  SmallIntBuf: smallint;
  FloatBuf: Double;
  StringBuf: string;
  DateTimeBuf: TDateTime;
begin
  Result := '';
  if Data.Size = 0 then Exit;

  Data.Position := 0;
  case FField.FieldType of
    7:
    begin
      if not IsNull then
      begin
        Data.ReadBuffer(SmallIntBuf, SizeOf(SmallIntBuf));
        Result := IntToStr(SmallIntBuf);
      end;
    end;
    8, 9:
    begin
      if not IsNull then
      begin
        Data.ReadBuffer(IntBuf, SizeOf(IntBuf));
        Result := IntToStr(IntBuf);
      end;
    end;
    16:
    begin
      if not IsNull then
      begin
        Data.ReadBuffer(Int64Buf, SizeOf(Int64Buf));
        Result := IntToStr(Int64Buf);
      end;
    end;
    10, 11, 27:
    begin
      if not IsNull then
      begin
        Data.ReadBuffer(FloatBuf, SizeOf(FloatBuf));//с плав. точкой
        Result := FloatToStr(FloatBuf);
      end;
    end;
    14, 37, 40:
    begin
      if not IsNull then
      begin
        SaveStringToStream(StringBuf, Data);//строковое
        Result := StringBuf;
      end;
    end;
    12, 13, 35:
    begin
      if not IsNull then
      begin
        Data.WriteBuffer(DateTimeBuf, SizeOf(DateTimeBuf));
        Result := DateTimeToStr(DateTimeBuf);
      end;
    end;
    tfBlob: raise Exception.Create(CantReturnBlobValue);
  end;
end;

procedure TrpFieldData.SetIsNull(const Value: Boolean);
begin
  FIsNull := Value;
end;

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
destructor TRUIDManager.Destroy;
begin
  FSelectRUIDSQL.Free;
  FInsertRUIDSQL.Free;
  FSelectIDSQL.Free;
  FGenIDSQL.Free;
  FRUIDConf.Free;
  FRUIDCash.Free;
  
  inherited;
end;

procedure TRUIDManager.CheckDataBase;
begin
  if FDataBase = nil then
    raise Exception.Create(DataBaseNotAssigned);
end;

procedure TRUIDManager.CheckGenIdSQL;
begin
  if FGenIDSQL = nil then
  begin
    CheckDataBase;
    FGenIDSQL := TIBSQL.Create(nil);
    FGenIDSQL.Transaction := FDataBase.Transaction;
  end;
  FGenIDSQL.Close;
end;

procedure TRUIDManager.CheckInsertRUIDSQL;
begin
  if FInsertRUIDSQL = nil then
  begin
    CheckDataBase;
    FInsertRUIDSQL := TIBSQL.Create(nil);
    FInsertRUIDSQL.Transaction := FDataBase.Transaction;
    FInsertRUIDSQL.SQL.Add(GetInsertRUIDSQL);
    FInsertRUIDSQL.Prepare;
  end;
  FInsertRUIDSQL.Close;
end;

procedure TRUIDManager.CheckRUIDCash;
begin
  if FRUIDCash = nil then
    FRUIDCash := TRUIDCash.Create;
end;

procedure TRUIDManager.CheckSelectIdSQL;
begin
  if FSelectIDSQL = nil then
  begin
    CheckDataBase;
    FSelectIDSQL := TIBSQL.Create(nil);
    FSelectIDSQL.Transaction := FDataBase.Transaction;
    FSelectIDSQL.SQL.Add(GetSelectIdSQL);
    FSelectIDSQL.Prepare;
  end;
  FSelectIDSQL.Close;
end;

procedure TRUIDManager.CheckSelectRUIDSQL;
begin
  if FSelectRUIDSQL = nil then
  begin
    CheckDataBase;
    FSelectRUIDSQL := TIBSQL.Create(nil);
    FSelectRUIDSQL.Transaction := FDataBase.Transaction;
    FSelectRUIDSQL.SQL.Add( GetSelectRUIDSQL);
    FSelectRUIDSQL.Prepare;
  end;
  FSelectRUIDSQL.Close;
end;

function TRUIDManager.GetRUIDConf: TRUIDConformitys;
begin
  if FRUIDConf = nil then
  begin
    FRUIDConf := TRUIDConformitys.Create;
  end;
  
  Result := FRUIDConf;
end;

procedure TRUIDManager.SetDataBase(const Value: TReplDataBase);
begin
  FDataBase := Value;
end;

{
******************************* TRUIDManagerDBU ********************************
}
procedure TRUIDManagerDBU.AddRUID(Id: Integer; RUID: TRUID);
begin
  CheckRUIDCash;
  
  CheckInsertRUIDSQL;
    {$IFDEF DEBUG}
  if (FInsertRUIDSQL.ParamByName('id').Index <> 0) or
    (FInsertRUIDSQL.ParamByName('xid').Index <> 1) or
    (FInsertRUIDSQL.ParamByName('dbid').Index <> 2) then
    raise Exception.Create('Проверь индексы');
    {$ENDIF}
  FInsertRUIDSQL.Params[0].AsInteger := Id;
  FInsertRUIDSQL.Params[1].AsInteger := RUID.XID;
  FInsertRUIDSQL.Params[2].AsInteger := RUID.DBID;
  //  FInsertRUIDSQL.Params[3].AsDateTime := Now;
  FInsertRUIDSQL.ExecQuery;
  
  FRUIDCash.Add(ID, RUID);
end;

procedure TRUIDManagerDBU.CheckGenIdSQL;
begin
  if FGenIDSQL = nil then
  begin
    inherited;
    FGenIDSQL.SQL.Add(Format('SELECT gen_id(%s, 1) FROM rdb$database',
      [FDataBase.DataBaseInfo.GeneratorName]));
  end;
  FGenIDSQl.Close;
end;

function TRUIDManagerDBU.GetId(const RUID: TRUID): Integer;
var
  Id: Integer;
  Index: Integer;
  R: TRUID;
begin
  CheckRUIDCash;
  Result := FRUIDCash.GetIdByRUID(RUID);
  if Result = - 1 then
  begin
    CheckSelectIDSQL;
  
    //Возможно было установлено соответствие РУИДов.
    Index := RUIDConf.IndexOfRUID(RUID);
    if Index > - 1 then
      R := RUIDConf.Items[Index].ConfRUID
    else
      R := RUID;
  
    {$IFDEF DEBUG}
    if (FSelectIDSQL.ParamByName('xid').Index <> 0) or
      (FSelectIDSQL.ParamByName('dbid').Index <> 1) then
      raise Exception.Create('Проверь индексы');
    {$ENDIF}
    FSelectIDSQL.Params[0].AsInteger := R.XID;
    FSelectIDSQL.Params[1].AsInteger := R.DBID;
    FSelectIDSQL.ExecQuery;
    if FSelectIDSQL.RecordCount > 0 then
    begin
      {$IFDEF DEBUG}
      if FSelectIDSQL.FieldByName('id').Index <> 0 then
        raise Exception.Create('Проверь индексы');
      {$ENDIF}
      Result := FSelectIDSQL.Fields[0].AsInteger;
      FRUIDCash.Add(Result, RUID);
    end else
    begin
      {Если для данного РУИДа нет ид то получам уникальный
      ид и регестрируем ИД и РУИД в БД}
      Id := FDataBase.GetNextID;
      AddRUID(ID, R);
      Result := id;
    end;
  end;
end;

function TRUIDManagerDBU.GetInsertRUIDSQL: string;
begin
  Result := 'INSERT INTO  gd_ruid (ID, XID, DBID' +
    ') VALUES(:ID, :XID, :DBID)'
end;

function TRUIDManagerDBU.GetNextId(RelationId: Integer = 0): Integer;
begin
  CheckGenIdSQL;
  FGenIDSQL.ExecQuery;
  Result := FGenIDSQL.Fields[0].AsInteger;
end;

function TRUIDManagerDBU.GetRUID(Id: Integer; RelationId: Integer = 0): TRUID;
{var
  q: TIBSQL;}
begin
  CheckRUIDCash;
  Result := FRUIDCash.GetRUIDByID(ID, RelationId);
  if Result.XID = - 1 then
  begin
    CheckSelectRUIDSQL;

    {$IFDEF DEBUG}
    if FSelectRUIDSQL.ParamByName('id').Index <> 0 then
      raise Exception.Create('Проверь индексы');
    {$ENDIF}
    FSelectRUIDSQL.Params[0].AsInteger := Id;
{    FSelectRUIDSQL.Params[1].AsInteger := Id;
    FSelectRUIDSQL.Params[2].AsInteger := FDataBase.DataBaseInfo.DBID;}
    FSelectRUIDSQL.ExecQuery;
    try
      Result.RelationID := RelationId;
      if FSelectRUIDSQL.RecordCount = 0 then
      begin
        Result.XID := ID;
        Result.DBID := FDataBase.DataBaseInfo.DBID;

        AddRUID(Id, Result);
      end
{      else if (FSelectRUIDSQL.FieldByName('xid').AsInteger <> ID) then begin
        if RecordWithIDExists(ID) then begin
        end
        else begin
          q:= TIBSQL.Create(nil);
          try
            q.Transaction := FDataBase.Transaction;
            q.SQL.Add('DELETE FROM gd_ruid WHERE xid=:xid and dbid=:dbid');
            q.Prepare;
            q.ParamByName('xid').AsInteger:= ID;
            q.ParamByName('dbid').AsInteger:= FDataBase.DataBaseInfo.DBID;
            q.ExecQuery;
            Result.XID := ID;
            Result.DBID := FDataBase.DataBaseInfo.DBID;
            AddRUID(Id, Result);
          finally
            q.Free;
          end;
        end;
      end}
      else begin
        {$IFDEF DEBUG}
        if (FSelectRUIDSQL.FieldByName('xid').Index <> 0) or
          (FSelectRUIDSQL.FieldByName('dbid').Index <> 1) then
          raise Exception.Create('Проверь индексы');
        {$ENDIF}
        Result.XID := FSelectRUIDSQL.Fields[0].AsInteger;
        Result.DBID := FSelectRUIDSQL.Fields[1].AsInteger;
        //Кешируем результат
        FRUIDCash.Add(Id, Result);
      end;
    finally
      FSelectRUIDSQL.Close;
    end;
  end;
end;

function TRUIDManagerDBU.RecordWithIDExists(ID: integer): boolean;
var
  q, q1: TIBSQL;
begin
  Result:= False;
  q:= TIBSQL.Create(nil);
  q1:= TIBSQL.Create(nil);
  q.Transaction:= FDataBase.Transaction;
  q1.Transaction:= FDataBase.Transaction;
  q.SQL.Text:=
    'SELECT rdb$relation_name rn ' +
    'FROM rdb$relation_fields ' +
    'WHERE rdb$field_name = ''ID''';
  try
    q.ExecQuery;
    while not q.Eof do begin
      q1.Close;
      q1.SQL.Text:=
        'SELECT Count(*) ' +
        'FROM ' + q.FieldByName('rn').AsString +
        ' WHERE id = :id';
      try
        q1.Prepare;
        q1.ParamByName('id').AsInteger:= ID;
        q1.ExecQuery;
        if q1.Fields[0].AsInteger > 0 then begin
          Result:= True;
          Break;
        end;
      except
      end;
      q.Next;
    end;
  finally
    q.Free;
    q1.Free;
  end;
end;

function TRUIDManagerDBU.GetSelectIdSQL: string;
begin
  Result := 'SELECT id FROM GD_RUID WHERE xid = :xid AND dbid = :dbid';
end;

function TRUIDManagerDBU.GetSelectRUIDSQL: string;
begin
  Result := 'SELECT xid, dbid FROM GD_RUID WHERE id = :id';
//  Result := 'SELECT xid, dbid FROM GD_RUID WHERE (id = :id) or (xid = :xid AND dbid = :dbid)';
end;

{
******************************** TRUIDManagerRU ********************************
}
procedure TRUIDManagerRU.AddRUID(Id: Integer; RUID: TRUID);
begin
  CheckRUIDCash;
  CheckInsertRUIDSQL;
  {$IFDEF DEBUG}
  if (FSelectRUIDSQL.ParamByName('id').Index <> 0) or
    (FSelectRUIDSQL.ParamByName('xid').Index <> 1) or
    (FSelectRUIDSQL.ParamByName('dbid').Index <> 2) or
    (FSelectRUIDSQL.ParamByName('modified').Index <> 3) or
    (FSelectRUIDSQL.ParamByName('relationid').Index <> 4) then
    raise Exception.Create('Проверь индексы');
  {$ENDIF}
  
  FInsertRUIDSQL.ParamByName('id').AsInteger := Id;
  FInsertRUIDSQL.ParamByName('xid').AsInteger := RUID.XID;
  FInsertRUIDSQL.ParamByName('dbid').AsInteger := RUID.DBID;
  {$IFDEF GEDEMIN}
  FInsertRUIDSQL.ParamByName('modified').AsDateTime := Now;
  {$ENDIF}
  FInsertRUIDSQL.ParamByName('relationid').AsInteger := RUID.RelationID;
  FInsertRUIDSQL.ExecQuery;
  FRUIDCash.Add(Id, RUID);
end;

function TRUIDManagerRU.GetId(const RUID: TRUID): Integer;
var
  Id: Integer;
  R: TRUID;
  Index: Integer;
begin
  CheckRUIDCash;
  Result := FRUIDCash.GetIdByRUID(RUID);
  if Result = - 1 then
  begin
    CheckSelectIdSQL;
  
    //Возможно было установлено соответствие РУИДов.
    Index := RUIDConf.IndexOfRUID(RUID);
    if Index > - 1 then
      R := RUIDConf.Items[Index].ConfRUID
    else
      R := RUID;
  
    {$IFDEF DEBUG}
    if (FSelectIDSQL.ParamByName('xid').Index <> 0) or
      (FSelectIDSQL.ParamByName('dbid').Index <> 1) or
      (FSelectIDSQL.ParamByName('relationid').Index <> 2) then
      raise Exception.Create('Проверь индексы');
    {$ENDIF}

    FSelectIDSQL.Params[0].AsInteger := R.XID;
    FSelectIDSQL.Params[1].AsInteger := R.DBID;
    FSelectIDSQL.Params[2].AsInteger := R.RelationID;
    FSelectIDSQL.ExecQuery;
    if FSelectIDSQL.RecordCount > 0 then
    begin
      {$IFDEF DEBUG}
      if FSelectIDSQL.FieldByName('id').Index <> 0 then
        raise Exception.Create('Проверь индексы');
      {$ENDIF}

      Result := FSelectIDSQL.Fields[0].AsInteger;
      FRUIDCash.Add(Result, RUID);
    end else
    begin
      {Если для данного РУИДа нет ид то получам уникальный
      ид и регестрируем ИД и РУИД в БД}
      Id := FDataBase.GetNextID(R.RelationID);
      AddRUID(ID, R);
      Result := ID;
    end;
  end;
end;

function TRUIDManagerRU.GetInsertRUIDSQL: string;
begin
  Result := 'INSERT INTO  gd_ruid (ID, XID, DBID, ' +
    'RELATIONID) VALUES(:ID, :XID, :DBID, :RELATIONID)'
end;

function TRUIDManagerRU.GetNextId(RelationId: Integer = 0): Integer;
var
  R: TrpRelation;
begin
  CheckGenIdSQL;
  
  if FLastRelationKey <> RelationId then
  begin
    R := FDataBase.Relations[RelationId];
    if R <> nil then
    begin
      {$IFDEF DEBUG}
      if Trim(R.GeneratorName) = '' then
        raise Exception.Create('Invalid generator name');
      {$ENDIF}
      FGenIDSQL.SQL.Clear;
      FGenIDSQL.SQL.Add('SELECT gen_id(' + R.GeneratorName + ', 1) FROM ' +
        'rdb$database');
      FLastRelationKey := RelationId;
    end else
      raise Exception.Create(InvalidRelationKey);
  end;
  
  FGenIDSQL.ExecQuery;
  Result := FGenIDSQL.Fields[0].AsInteger;
end;

function TRUIDManagerRU.GetRUID(Id: Integer; RelationId: Integer = 0): TRUID;
begin
  CheckRUIDCash;
  Result := FRUIDCash.GetRUIDByID(ID, RelationId);
  if Result.XID = - 1 then
  begin
    CheckSelectRUIDSQL;
    Result.RelationID := RelationId;
    {$IFDEF DEBUG}
    if (FSelectRUIDSQL.ParamByName('id').Index <> 0) or
      (FSelectRUIDSQL.ParamByName('relationid').Index <> 1) then
      raise Exception.Create('Проверь индексы');
    {$ENDIF}

    FSelectRUIDSQL.Params[0].AsInteger := Id;
    FSelectRUIDSQL.Params[1].AsInteger := RelationId;
    FSelectRUIDSQL.ExecQuery;
      Result.RelationID := RelationId;
      if FSelectRUIDSQL.RecordCount = 0 then
      begin
        Result.XID := ID;
        Result.DBID := FDataBase.DataBaseInfo.DBID;
  
        AddRUID(Id, Result);
      end else
      begin
        {$IFDEF DEBUG}
        if (FSelectRUIDSQL.FieldByName('xid').Index <> 0) or
          (FSelectRUIDSQL.FieldByName('dbid').Index <> 1) then
          raise Exception.Create('Проверь индексы');
        {$ENDIF}
        Result.XID := FSelectRUIDSQL.Fields[0].AsInteger;
        Result.DBID := FSelectRUIDSQL.Fields[1].AsInteger;
  
        FRUIDCash.Add(Id, Result);
      end;
  end;
end;

function TRUIDManagerRU.GetSelectIdSQL: string;
begin
  Result := 'SELECT id FROM GD_RUID WHERE xid = :xid AND dbid = :dbid AND relationid = :relationid';
end;

function TRUIDManagerRU.GetSelectRUIDSQL: string;
begin
  Result := 'SELECT xid, dbid FROM GD_RUID WHERE id = :id AND relationid = :relationid';
end;

{
********************************** TrpCortege **********************************
}
constructor TrpCortege.Create;
begin
  FFieldsData := TrpFieldsData.Create;
  FKeyList := TStringList.Create;
  FKeyDivider := ''//ReplDataBase.DataBaseInfo.KeyDivider;
end;

destructor TrpCortege.Destroy;
begin
  FKeyList.Free;
  
  FSelectSQL.Free;
  {$IFDEF JUXTA}
  FJuxtaSQL.Free;
  {$ENDIF}
  FInsertSQL.Free;
  FUpdateSQL.Free;
  FDeleteSQL.Free;
  
  FFieldsData.Free;
  FRefTableSQL.Free;
  FDeleteRefSQL.Free;
  FUpdateForeignKeySQL.Free;

  inherited;
end;

function TrpCortege.CheckFKRecords: Boolean;
var
  F: TrpField;
  i, iData: integer;
begin
  Result:= False;
  try
  for I := 0 to FRelation.Fields.Count - 1 do begin
    F := FRelation.Fields[I];
    if F.IsForeign then begin
      iData:= FFieldsData.IndexOfData(FRelation.Fields[i].FieldName);
      if iData > -1 then begin
        if not FFieldsData[iData].IsNull then begin
          CheckForInsertSQL;
          FCheckForInsertSQL.SQL.Text:= Format(cCheckFKForInsert,
            [FRelation.Fields[i].ReferenceField.FieldName,
             FRelation.Fields[i].ReferenceField.Relation.RelationName,
             FRelation.Fields[i].ReferenceField.FieldName,
             FFieldsData[iData].ValueStr]);
          try
            FCheckForInsertSQL.ExecQuery;
            Result:= not FCheckForInsertSQL.Eof;
            if not Result then begin
              CheckForInsertSQL;
              FCheckForInsertSQL.SQL.Text:= cLogForFKDeleted + QuotedStr('%' + FFieldsData[iData].ValueStr + '%');
              FCheckForInsertSQL.ParamByName('rel').AsInteger:= FRelation.Fields[i].ReferenceField.Relation.RelationKey;
              try
                FCheckForInsertSQL.ExecQuery;
                Result:= FCheckForInsertSQL.Eof;
              finally
              end;
              Exit;
            end;
          except
          end;
        end;
      end;
    end;
  end;
  except
  end;
end;

function TrpCortege.CheckFKRecordDeleted: Boolean;
var
  I, J, K, Index: Integer;
  UIndex: TrpUniqueIndex;
  UIValue: string;
  F, F1: TrpField;
  L: TList;
  R: TrpRelation;
begin
  Result := False;
  if FKeyDivider = '' then
    FKeyDivider := ReplDataBase.DataBaseInfo.KeyDivider;

  L := TList.Create;
  try
    for I := 0 to FRelation.Fields.Count - 1 do
    begin
      F := FRelation.Fields[I];
      if F.IsForeign then
      begin
        R := F.ReferenceField.Relation;
        Index := R.UniqueIndices.IndexOfByField(F.ReferenceField.FieldName);
        if Index > - 1 then
        begin
          UIndex := F.ReferenceField.Relation.UniqueIndices[Index];
          if L.IndexOf(UIndex) = - 1 then
          begin
            L.Add(UIndex);
            UIValue := '';
            for J := 0 to UIndex.Fields.Count - 1 do
            begin
              F1 := UIndex.Fields[J];
              for K := 0 to F1.ForeignFieldCount - 1 do
              begin
                if F1.ForeignFields[K].Relation = FRelation then
                begin
                  Index := FFieldsData.IndexOfData(F1.ForeignFields[K].FieldName);
                  if Index > - 1 then
                  begin
                    if not FFieldsData[Index].IsNull then
                    begin
                      if UIValue > '' then
                        UIValue := UIValue + FKeyDivider;

                      UIValue := UIValue + FFieldsData[Index].ValueStr;
                    end;
                  end{ else
                    raise Exception.Create(InvalidFieldName)};
                end;
              end;
            end;

            if UIValue > '' then
            begin
              Result := UIndex.DelFieldsValue.IndexOf(UIValue) > - 1;
              if Result then exit;
            end;
          end;
        end;{ else
          raise Exception.Create(InvalidFieldName);}
      end;
    end;
  finally
    L.Free;
  end;
end;

procedure TrpCortege.CheckForInsertSQL;
begin
  if FCheckForInsertSQL = nil then
  begin
    FCheckForInsertSQL := TIBSQL.Create(nil);
    FCheckForInsertSQL.Transaction := ReplDataBase.Transaction;
  end;
  FCheckForInsertSQL.Close;
end;

procedure TrpCortege.CheckRefTableSQL;
begin
  if FRefTableSQL = nil then
  begin
    FRefTableSQL := TIBSQL.Create(nil);
    FRefTableSQL.Transaction := ReplDataBase.Transaction;
//    FRefTableSQL.SQL.Text := cRefTableSQL;
    FRefTableSQL.SQL.Text := cRefTableSQLNoCascade;
  end;
  FRefTableSQL.Close;
end;

procedure TrpCortege.CheckSelectSQL;
begin
  if FSelectSQL = nil then
  begin
    FSelectSQL := TIBSQL.Create(nil);
    FSelectSQL.Transaction := ReplDataBase.Transaction;
  end;
  
  if not FSelectSQLAssigned then
  begin
    FSelectSQL.SQL.Assign(FRelation.SelectSQL);
    FSelectSQLAssigned := True;
  end;
  FSelectSQL.Close;
end;

procedure TrpCortege.CheckSQL;
begin
  CheckSelectSQL;
  {$IFDEF JUXTA}
  if (FRelation.JuxtaPosition.Count > 0) and
    (FJuxtaSQL = nil) then
  begin
    FJuxtaSQL := TIBSQL.Create(nil);
    FJuxtaSQL.Transaction := ReplDataBase.Transaction;
  end;
  {$ENDIF}
  if FInsertSQL = nil then
  begin
    FInsertSQL := TIBSQL.Create(nil);
    FInsertSQL.Transaction := ReplDataBase.Transaction;
  end;

  if FUpdateSQL = nil then
  begin
    FUpdateSQL := TIBSQL.Create(nil);
    FUpdateSQL.Transaction := ReplDataBase.Transaction;
  end;
  
  if FDeleteSQL = nil then
  begin
    FDeleteSQL := TIBSQL.Create(nil);
    FDeleteSQL.Transaction := ReplDataBase.Transaction;
  end;
  
  if not FSQLAssigned then
  begin
    FUpdateSQL.SQL.Assign(FRelation.ModifySQL);
    FInsertSQL.SQL.Assign(FRelation.InsertSQL);
    FDeleteSQL.SQL.Assign(FRelation.DeleteSQL);
    {$IFDEF JUXTA}
    if FRelation.JuxtaPosition.Count > 0 then
      FJuxtaSQL.SQL.Assign(FRelation.JuxtaPositionSQL);
    {$ENDIF}
    FSQLAssigned := True;
  end;
  {$IFDEF JUXTA}
  if FJuxtaSQL <> nil then
    FJuxtaSQL.Close;
  {$ENDIF}
  FInsertSQL.Close;
  FUpdateSQL.Close;
  FDeleteSQL.Close;
end;

function TrpCortege.Delete: Boolean;
var
  I: Integer;
  DataAction: TDataAction;
begin
  Include(FStates, csDelete);
  try
    CheckSQL;
    {Если запись была удалена или изменен ключ то запись
    не будет найдена и значит ничего делать ненадо}
    SelectFromDB;
    Result := False;
    if FSelectSQL.RecordCount > 0 then
    begin
      for I := 0 to FRelation.Keys.Count - 1 do
        FDeleteSQL.ParamByName(FRelation.Keys[I].FieldName).AsString := FKeyList[I];
      repeat
        try
          //Производим удаление записей которые ссылаются на данную запись
          //Для ускорения будем удалять ссылки в обработкчике ошибок
          DataAction := daAbort;
          FDeleteSQL.ExecQuery;
          Result := True;
        except
          on E: Exception do
          begin
            { TODO -oTipTop -cСделать :
            Нужно отказаться от удаления ссылок при первом проходе
            т.к. информация об удалениии ссылок может содержаться в
            файле реплики и сделается двойная работа }
            LoadFromDB;
            if Assigned(OnDeleteError) then
              OnDeleteError(FDeleteSQL, E, DataAction);
            if DataAction = daFail then raise;
            Result := False;
          end;
        end;
      until DataAction = daAbort;
    end;
  finally
    Exclude(FStates, csDelete);
  end;
end;

procedure TrpCortege.DeleteReference;
var
  FieldValue: Variant;
  Index, iStep: Integer;

  function DelRef(ARel, AField: string; AVal: variant): boolean;
  var
    RefTblSQL, DelSQL, SelSQL: TIBSQL;
  begin
    Inc(iStep);
    if iStep > MAX_DELETE_REFERENCE_COUNT then begin
      Result:= False;
      Exit;
    end;
    Result:= True;
    DelSQL:= TIBSQL.Create(nil);
    try
      DelSQL.Transaction := ReplDataBase.Transaction;
      DelSQL.SQL.Add(Format('DELETE FROM %s WHERE %s = %s', [ARel, AField, AVal]));
      try
        DelSQL.ExecQuery;
      except
        on E: Exception do begin
          if IsForegnKeyError(E) then begin
            RefTblSQL:= TIBSQL.Create(nil);
            SelSQL:= TIBSQL.Create(nil);
            try
              RefTblSQL.Transaction := ReplDataBase.Transaction;
              SelSQL.Transaction := ReplDataBase.Transaction;
//              RefTblSQL.SQL.Text := cRefTableSQL;
              RefTblSQL.SQL.Text := cRefTableSQLNoCascade;
              RefTblSQL.ParamByName(fnRelationName).AsString := ARel;
              try
                RefTblSQL.ExecQuery;
                while not RefTblSQL.Eof do begin
                  SelSQL.Close;
                  SelSQL.SQL.Clear;
                  SelSQL.SQL.Add(Format('SELECT %s FROM %s WHERE %s=%s',
                    [RefTblSQL.FieldByName(fnOnFieldname).AsString,
                     ARel,
                     AField,
                     AVal]));
                  try
                    SelSQL.ExecQuery;
                    while not SelSQL.Eof do begin
                      if not VarIsNull(SelSQL.Fields[0].Value) then begin
                        if DelRef(Trim(RefTblSQL.FieldByName(fnRelationname).AsString), Trim(RefTblSQL.FieldByName(fnFieldname).AsString), SelSQL.Fields[0].Value) then begin
                          Dec(iStep);
                          SelSQL.Next;
                        end
                        else begin
                          Result:= False;
                          Break;
                        end;
                      end;
                    end;
                  except
                    Result:= False;
                  end;
                  if Result then
                    RefTblSQL.Next
                  else
                    Break;
                end;
                if Result then
                  DelSQL.ExecQuery;
              except
                Result:= False;
              end;
            finally
              SelSQL.Free;
              RefTblSQL.Free;
            end;
          end;
        end;
      end;
    finally
      DelSQL.Free;
    end;
  end;

begin
  CheckRefTableSQL;

  FRefTableSQL.ParamByName(fnRelationName).AsString := FRelation.RelationName;
  FRefTableSQL.ExecQuery;
  if FRefTableSQL.RecordCount > 0 then
  begin
    if FDeleteRefSQL = nil then
    begin
      FDeleteRefSQL := TIBSQl.Create(nil);
      FDeleteRefSQL.Transaction := ReplDataBase.Transaction;
    end;

    while not FRefTableSQL.Eof do
    begin
      iStep:= 0;
      Index := FFieldsData.IndexOfData(Trim(FRefTableSQL.FieldByName('OnFieldName').AsString));
      if Index > - 1 then
      begin
        FieldValue := FFieldsData.FieldData[Index].Value;
      end else
        raise Exception.Create(InvalidFieldName);

      if not VarIsNull(FieldValue) then
      begin
        DelRef(Trim(FRefTableSQL.FieldByName(fnRelationname).AsString), Trim(FRefTableSQL.FieldByName(fnFieldname).AsString), FieldValue)
{        FDeleteRefSQL.SQL.Clear;
        FDeleteRefSQL.SQL.Add(Format('DELETE FROM %s WHERE %s = %s',
          [FRefTableSQL.FieldByName(fnRelationname).AsString,
          FRefTableSQL.FieldByName(fnFieldname).AsString,
          FieldValue]));

        try
          try
            FDeleteRefSQL.ExecQuery;
          except
            FDeleteRefSQL.Close;
            FDeleteRefSQL.SQL.Clear;
            FDeleteRefSQL.SQL.Add(Format('UPDATE %s SET %s = null WHERE %s = %s',
              [FRefTableSQL.FieldByName(fnRelationname).AsString,
               FRefTableSQL.FieldByName(fnFieldname).AsString,
               FRefTableSQL.FieldByName(fnFieldname).AsString,
               FieldValue]));
            try
              FDeleteRefSQL.ExecQuery;
            except
              Exit
            end;
          end;
        finally
          FDeleteRefSQL.Close;
        end;}
      end;
      FRefTableSQL.Next;
    end;
  end;
end;

function TrpCortege.GetUIndexValue(UIndex: TrpUniqueIndex): string;
var
  I, Index: Integer;
  IntBuf: Integer;
  FloatBuf: Double;
  StringBuf: string;
  DateTimeBuf: TDateTime;
  QuardBuf: TISC_QUAD;
  ShortBuf: Short;
  DoubleBuf: Double;
  Int64Buf: Int64;
  CurrencyBuf: Currency;
  rpF: TrpField;
  FD: TrpFieldData;
begin
  if FKeyDivider = '' then
    FKeyDivider := ReplDataBase.DataBaseInfo.KeyDivider;

  Result := '';
  for I := 0 to UIndex.Fields.Count - 1 do
  begin
    rpF := UIndex.Fields[I];
    Index := FFieldsData.IndexOfData(rpF.FieldName);
    FD := FFieldsData[Index];

    if Result > '' then Result := Result + FKeyDivider;

    if FD.IsNull then
    begin
      Result := Result + 'NULL';
    end else
    begin
      FD.Data.Position := 0;
      case rpF.FFieldType of
        tfInteger:
        begin
          if rpF.FieldSubType = istFieldType then
          begin
            FD.Data.ReadBuffer(IntBuf, SizeOf(IntBuf));
            Result := Result + IntToStr(IntBuf);
          end else
          begin
            FD.Data.ReadBuffer(CurrencyBuf, SizeOf(CurrencyBuf));
            Result := Result + CurrToStr(CurrencyBuf);
          end;
        end;
        tfInt64:
        begin
          if rpF.FieldSubType = istFieldType then
          begin
            FD.Data.ReadBuffer(Int64Buf, SizeOf(Int64Buf));
            Result := Result + IntToStr(Int64Buf);
          end else
          begin
            FD.Data.ReadBuffer(CurrencyBuf, SizeOf(CurrencyBuf));
            Result := Result + CurrToStr(CurrencyBuf);
          end;
        end;
        tfSmallInt:
        begin
          if rpF.FieldSubType = istFieldType then
          begin
            FD.Data.ReadBuffer(ShortBuf, SizeOf(ShortBuf));
            Result := Result + IntToStr(ShortBuf);
          end else
          begin
            FD.Data.ReadBuffer(CurrencyBuf, SizeOf(CurrencyBuf));
            Result := Result + CurrToStr(CurrencyBuf);
          end;
        end;
        tfQuard:
        begin
          raise Exception.Create('Не поддерживает тип Quard');
          FD.Data.ReadBuffer(QuardBuf, SizeOf(QuardBuf));
        end;
        tfD_Float, tfDouble:
        begin
          FD.Data.ReadBuffer(DoubleBuf, SizeOf(DoubleBuf));
          Result := Result + FloatToStr(DoubleBuf);
        end;
        tfFloat:
        begin
          FD.Data.ReadBuffer(FloatBuf, SizeOf(FloatBuf));
          Result := Result + FloatToStr(FloatBuf);
        end;
        tfChar, tfCString, tfVarChar:
        begin
          StringBuf := ReadStringFromStream(FD.Data);
          Result := Result +  StringBuf;
        end;
        tfDate, tfTime, tfTimeStamp:
        begin
          FD.Data.ReadBuffer(DateTimeBuf, SizeOf(DateTimeBuf));
          Result := Result + DateTimeToStr(DateTimeBuf);
        end;
        tfBlob:
        begin
          raise Exception.Create('Не поддерживает тип Blob');
        end;
      end;
    end;
  end;
end;

function TrpCortege.Insert: Boolean;
var
  I: Integer;
  SQL: TIBSQL;
  DataAction: TDataAction;
begin
  Include(FStates, csInsert);
  try
    CheckSQL;

    SelectFromDB;
    Result := False;
    if not CheckFKRecordDeleted then
    begin
      if FSelectSQL.RecordCount = 0 then
      begin

        SQL := FInsertSQL;
      end else
      begin
        Include(FStates, csUpdate);

        for I := 0 to FRelation.Keys.Count - 1 do
        begin
          FUpdateSQL.ParamByName('OLD_' + FRelation.Keys[I].FieldName).AsString :=
            FKeyList[I];
        end;
        SQL := FUpdateSQL;
      end;
//      SaveToDB(SQL);

      repeat
        try
          SaveToDB(SQL);
          DataAction := daAbort;
          SQL.ExecQuery;
          Result := True;
        except
          on E: Exception do begin
            if Assigned(OnPostError) then
            begin
              OnPostError(SQL, E, DataAction);
              if DataAction = daFail then raise;
              Result := False;
            end;
          end;
        end;
      until DataAction = daAbort;
    end else
    begin
      SaveIndicesValue;
    end;
  finally
    Exclude(FStates, csInsert);
    Exclude(FStates, csUpdate);
  end;
end;

procedure TrpCortege.LoadFromDB;
var
  I: Integer;
  IntBuf: Integer;
  FloatBuf: Double;
  StringBuf: string;
  DateTimeBuf: TDateTime;
  QuardBuf: TISC_QUAD;
  ShortBuf: Short;
  DoubleBuf: Double;
  Int64Buf: Int64;
  CurrencyBuf: Currency;
  FD: TrpFieldData;
  F: TIBXSQLVAR;
begin
  { TODO -cСделать :
  Нужно отказаться от функций As.. и сделать
  считывание и запись данных с использованием
  свойств SQLType, FieldSize и т.д. Т.е. считать размер данных,
  ыделить буффер такого размера и скопировать данные.
  Поидее это даст припост в производительность и небудет
  ошибок с преобразованием данных }
  if not (csLoaded in FStates) then
  begin
    FIsEmptyFieldsData:= True;
    SelectFromDB;
      {Если запись была удалена или изменен ключ то запись
      не будет найдена и значит ничего делать ненадо}
    try
      if FSelectSQL.RecordCount > 0 then
      begin
        for I := 0 to FRelation.Fields.Count - 1 do
        begin
          if FFieldsData.Count < I + 1 then
          begin
            FD := TrpFieldData.Create;
            FD.Field := FRelation.Fields[I];
            FFieldsData.Add(FD);
          end else
          begin
            FD := FFieldsData[I];
            FD.Data.Position := 0;
          end;
            //Запоминаем указатель на поле
          F := FSelectSQL.Fields[FRelation.Fields[I].FieldIndex];
          FD.IsNull := F.IsNull;

          if not FD.IsNull then
          begin
            FIsEmptyFieldsData:= False;
            case FD.Field.FieldType of
              tfInteger, tfInt64, tfSmallInt:
              begin
                if FD.Field.FieldSubType = istFieldType then
                begin
                  case Fd.Field.FieldType of
                    tfInteger:
                    begin
                      IntBuf := F.AsInteger;//целочисленное
                      FD.Data.WriteBuffer(IntBuf, SizeOf(IntBuf));
                    end;
                    tfInt64:
                    begin
                      Int64Buf := F.AsInt64;
                      Fd.Data.WriteBuffer(Int64Buf, SizeOf(Int64Buf));
                    end;
                    tfSmallInt:
                    begin
                      ShortBuf := F.AsShort;
                      FD.Data.WriteBuffer(ShortBuf, SizeOf(ShortBuf));
                    end;
                  end;
                end else
                begin
                  CurrencyBuf := F.AsCurrency;
                  FD.Data.WriteBuffer(CurrencyBuf, SizeOf(CurrencyBuf));
                end;
              end;
              tfQuard:
              begin
                QuardBuf := F.AsQuad;
                FD.Data.WriteBuffer(QuardBuf, SizeOf(QuardBuf));
              end;
              tfD_Float, tfDouble:
              begin
                DoubleBuf := F.AsDouble;
                FD.Data.WriteBuffer(DoubleBuf, SizeOf(DoubleBuf));
              end;
              tfFloat:
              begin
                FloatBuf := F.AsFloat;
                FD.Data.WriteBuffer(FloatBuf, SizeOf(FloatBuf));
              end;
              tfChar, tfCString, tfVarChar:
              begin
                StringBuf := F.AsString;
                FD.Data.Size := 0;
                SaveStringToStream(StringBuf, FD.Data);//строковое
              end;
              tfDate, tfTime, tfTimeStamp:
              begin
                DateTimeBuf := F.AsDateTime;//время
                FD.Data.WriteBuffer(DateTimeBuf, SizeOf(DateTimeBuf));
              end;
              tfBlob:
              begin
                FD.Data.Size := 0;
                F.SaveToStream(FD.Data);
              end;
            end;
          end;
        end;
      end;
    finally
      FSelectSQL.Close;
      Include(FStates, csLoaded);
    end;
  end
  else begin
    for i:= 0 to FFieldsData.Count - 1 do begin
      if not FFieldsData[i].IsNull then begin
        FIsEmptyFieldsData:= False;
        Break;
      end;
    end;
  end;
end;

procedure TrpCortege.LoadFromStream(Stream: TStream);
var
  I, Count, ASize: Integer;
  Id: Integer;
  FD: TrpFieldData;
  F: TrpField;
  sTmp: string;

  {$IFDEF DEBUG}
  var
    Lb: Integer;
  {$ENDIF}

begin
  FIsEmptyFieldsData:= True;
  Stream.ReadBuffer(Count, SizeOf(Count));
  {$IFDEF DEBUG}
  //Т.к. запись могла быть удалена, то кол-во переданнх полей может быть равна 0
  if (Count <> FRelation.Fields.Count) and (Count <> 0) then
    raise Exception.Create('Кол-во переданных полей не соответствует кол-во полей в таблице');
  {$ENDIF}
  
  for I := 0 to Count - 1 do
  begin
    {$IFDEF DEBUG}
    Stream.ReadBuffer(Lb, SizeOf(Lb));
    if Lb <> cLb then
      raise Exception.Create('CRC error');
    {$ENDIF}
  
    F := FRelation.Fields[I];
    if FFieldsData.Count < Count then
    begin
      FD := TrpFieldData.Create;
      FD.FField := F;
      FFieldsData.Add(FD);
    end else
    begin
      FD := FFieldsData[i];
      FD.Data.Position := 0;
    end;
  
    Stream.ReadBuffer(ASize, SizeOf(ASize));
    FD.IsNull := ASize = 0;
    if not FD.IsNull then
    begin
      FIsEmptyFieldsData:= False;
      {$IFNDEF INTKEY}
      ...
      {$ENDIF}
      if (F.FFieldType = tfInteger) and (F.FieldSubType = istFieldType) then
      begin
        if (F.IsForeign) or (F.IsPrimeKey) or FRelation.NeedSaveRUID(FD.Field) then
          Id := ReadIdAndRUID(Stream, sTmp)
//          Id := ReadId(Stream)
        else
          Stream.ReadBuffer(Id, SizeOf(ID));

        FD.Data.Size := SizeOf(Id);
        FD.Data.WriteBuffer(Id, SizeOf(Id));
        if (F.IsForeign) or (F.IsPrimeKey) or FRelation.NeedSaveRUID(FD.Field) then
          FD.FRUID:= sTmp
        else
          FD.FRUID:= '';
      end else
      begin
        FD.Data.Size := ASize;
        FD.Data.CopyFrom(Stream, ASize);
      end;
    end;
  end;
end;

procedure TrpCortege.SaveForeignKey(FieldName: string; ID: Integer; Stream: 
        TStream);
var
  RefField: TrpField;
  RUID: TRUID;
begin
  RefField := FRelation.Fields[FRelation.Fields.IndexOfField(FieldName)].ReferenceField;
  if RefField <> nil then
  begin
    RUID := ReplDataBase.GetRUID(ID, RefField.Relation.RelationKey);
    Stream.WriteBuffer(RUID, SizeOf(RUID));
  end else
    raise Exception.Create(InvalidFieldName);
end;

procedure TrpCortege.SaveIndicesValue;
var
  J: Integer;
  UIndex: TrpUniqueIndex;
  UIValue: string;
begin
  if FKeyDivider = '' then
    FKeyDivider := ReplDataBase.DataBaseInfo.KeyDivider;
  
  for J := 0 to FRelation.UniqueIndices.Count - 1 do
  begin
    UIndex := FRelation.UniqueIndices[J];
    UIValue := GetUIndexValue(UIndex);
  
    if UIValue > '' then
    begin
      if UIndex.DelFieldsValue.IndexOf(UIValue) = - 1 then
      begin
        UIndex.DelFieldsValue.Add(UIValue);
      end;
    end;
  end;
end;

procedure TrpCortege.SaveToDataSet(DataSet: TDataSet);
var
  I: Integer;
  IntBuf: Integer;
  FloatBuf: Double;
  StringBuf: string;
  DateTimeBuf: TDateTime;
  QuardBuf: TISC_QUAD;
  ShortBuf: Short;
  DoubleBuf: Double;
  Int64Buf: Int64;
  CurrencyBuf: Currency;
  F: TField;
  rpF: TrpField;
  FD: TrpFieldData;
  Str: TStream;
begin
    //Ситуация когда переданно 0 полей возникает когда
    //запись удалена по внешнему ключу с ONDELETE CASCADE
  for I := 0 to FFieldsData.Count - 1 do
  begin
    FD := FFieldsData[I];
    F := DataSet.FieldByName(FD.FField.FieldName);
    if FD.IsNull then
      F.Clear
    else
    begin
      FD.Data.Position := 0;
      rpF := FD.FField;
      case rpF.FFieldType of
        tfInteger:
        begin
            {$IFNDEF INTKEY}
          ...
            {$ENDIF}
          if rpF.FieldSubType = istFieldType then
          begin
            FD.Data.ReadBuffer(IntBuf, SizeOf(IntBuf));
            { TODO -cСделать : Сопоставление руидов }
            if rpF.IsForeign and (rpF.Conformity) and (not F.IsNull) then
            begin
                //Если поле типа интеджер и является форигнкеем
                //и в поле уже записано значение и текущая команда вставка
                //то пытаемся установить
                //соответствие иначе просто записываем новое значение
                { TODO : Реализовать сопоставление руидов }

              F.AsInteger := IntBuf;
            end else
              F.AsInteger := IntBuf;
          end else
          begin
            FD.Data.ReadBuffer(CurrencyBuf, SizeOf(CurrencyBuf));
            F.AsCurrency := CurrencyBuf;
          end;
        end;
        tfInt64:
        begin
          if rpF.FieldSubType = istFieldType then
          begin
            FD.Data.ReadBuffer(Int64Buf, SizeOf(Int64Buf));
            F.AsInteger := Int64Buf;
          end else
          begin
            FD.Data.ReadBuffer(CurrencyBuf, SizeOf(CurrencyBuf));
            F.AsCurrency := CurrencyBuf;
          end;
        end;
        tfSmallInt:
        begin
          if rpF.FieldSubType = istFieldType then
          begin
            FD.Data.ReadBuffer(ShortBuf, SizeOf(ShortBuf));
            F.AsInteger := ShortBuf;
          end else
          begin
            FD.Data.ReadBuffer(CurrencyBuf, SizeOf(CurrencyBuf));
            F.AsCurrency := CurrencyBuf;
          end;
        end;
        tfQuard:
        begin
          FD.Data.ReadBuffer(QuardBuf, SizeOf(QuardBuf));
          raise Exception.Create('TField не поддерживает тип Quard');
  //          F.AsQuad := QuardBuf;
        end;
        tfD_Float, tfDouble:
        begin
          FD.Data.ReadBuffer(DoubleBuf, SizeOf(DoubleBuf));
          F.AsFloat := DoubleBuf;
        end;
        tfFloat:
        begin
          FD.Data.ReadBuffer(FloatBuf, SizeOf(FloatBuf));
          F.AsFloat := FloatBuf;
        end;
        tfChar, tfCString, tfVarChar:
        begin
          StringBuf := ReadStringFromStream(FD.Data);
          F.AsString := StringBuf;//строковое
        end;
        tfDate, tfTime, tfTimeStamp:
        begin
          FD.Data.ReadBuffer(DateTimeBuf, SizeOf(DateTimeBuf));
          F.AsDateTime := DateTimeBuf;//время
        end;
        tfBlob:
        begin
          Str := DataSet.CreateBlobStream(F, bmRead);
          try
            Str.CopyFrom(FD.Data, FD.Data.Size);
          finally
            Str.Free;
          end;
        end;
      end;
    end;
  end;
end;

procedure TrpCortege.SaveToDB(IBSQL: TIBSQL);
var
  I: Integer;
  IntBuf: Integer;
  FloatBuf: Double;
  StringBuf: string;
  DateTimeBuf: TDateTime;
  QuardBuf: TISC_QUAD;
  ShortBuf: Short;
  DoubleBuf: Double;
  Int64Buf: Int64;
  CurrencyBuf: Currency;
  F: TIBXSQLVAR;
  rpF: TrpField;
  FD: TrpFieldData;
begin
  //Ситуация когда переданно 0 полей возникает когда
  //запись удалена по внешнему ключу с ONDELETE CASCADE
  for I := 0 to FFieldsData.Count - 1 do
  begin
    FD := FFieldsData[I];
    F := IBSQL.ParamByName(FD.FField.FieldName);
//    if (FD.FField.FieldName = 'NAME') then
    if FD.IsNull then
      F.Clear
    else
    begin
      FD.Data.Position := 0;
      rpF := FD.FField;
      case rpF.FFieldType of
        tfInteger:
        begin
          {$IFNDEF INTKEY}
          ...
          {$ENDIF}
          if rpF.FieldSubType = istFieldType then
          begin
            FD.Data.ReadBuffer(IntBuf, SizeOf(IntBuf));
            { TODO -cСделать : Сопоставление руидов }
            if (rpF.IsForeign or rpF.IsPrimeKey) and rpF.Conformity and not F.IsNull then
            begin
              //Если поле типа интеджер и является форигнкеем
              //и в поле уже записано значение и текущая команда вставка
              //то пытаемся установить
              //соответствие иначе просто записываем новое значение
              { TODO : Реализовать сопоставление руидов }
  
              F.AsInteger := IntBuf;
            end else
              F.AsInteger := IntBuf;
          end else
          begin
            FD.Data.ReadBuffer(CurrencyBuf, SizeOf(CurrencyBuf));
            F.AsCurrency := CurrencyBuf;
          end;
        end;
        tfInt64:
        begin
          if rpF.FieldSubType = istFieldType then
          begin
            FD.Data.ReadBuffer(Int64Buf, SizeOf(Int64Buf));
            F.AsInt64 := Int64Buf;
          end else
          begin
            FD.Data.ReadBuffer(CurrencyBuf, SizeOf(CurrencyBuf));
            F.AsCurrency := CurrencyBuf;
          end;
        end;
        tfSmallInt:
        begin
          if rpF.FieldSubType = istFieldType then
          begin
            FD.Data.ReadBuffer(ShortBuf, SizeOf(ShortBuf));
            F.AsShort := ShortBuf;
          end else
          begin
            FD.Data.ReadBuffer(CurrencyBuf, SizeOf(CurrencyBuf));
            F.AsCurrency := CurrencyBuf;
          end;
        end;
        tfQuard:
        begin
          FD.Data.ReadBuffer(QuardBuf, SizeOf(QuardBuf));
          F.AsQuad := QuardBuf;
        end;
        tfD_Float, tfDouble:
        begin
          FD.Data.ReadBuffer(DoubleBuf, SizeOf(DoubleBuf));
          F.AsDouble := DoubleBuf;
        end;
        tfFloat:
        begin
          FD.Data.ReadBuffer(FloatBuf, SizeOf(FloatBuf));
          F.AsFloat := FloatBuf;
        end;
        tfChar, tfCString, tfVarChar:
        begin
          StringBuf := ReadStringFromStream(FD.Data);
          F.AsString := StringBuf;//строковое
        end;
        tfDate, tfTime, tfTimeStamp:
        begin
          FD.Data.ReadBuffer(DateTimeBuf, SizeOf(DateTimeBuf));
          F.AsDateTime := DateTimeBuf;//время
        end;
        tfBlob:
        begin
          F.LoadFromStream(FD.Data);
        end;
      end;
    end;
  end;
end;

procedure TrpCortege.SaveToStream(Stream: TStream);
var
  Count, Size: Integer;
  I, IntBuf: Integer;
  FD: TrpFieldData;
  
  {$IFDEF DEBUG}
  const
    Lb: Integer = cLB;
  {$ENDIF}
  
begin
  //Сохраняем кол-во сохраняемых полей
  Count := FFieldsData.Count;
  Stream.WriteBuffer(Count, SizeOf(Count));

  for I := 0 to Count - 1 do
  begin
    {$IFDEF DEBUG}
    Stream.WriteBuffer(Lb, SizeOf(Lb));
    {$ENDIF}
    FD := FFieldsData[I];
    FD.Data.Position := 0;
    if FD.IsNull then
      Size := 0
    else
      Size := FD.Data.Size;

    Stream.WriteBuffer(Size, SizeOf(Size));
    if Size > 0 then
    begin
      {$IFNDEF INTKEY}
      ...
      {$ENDIF}
      if (FD.Field.FieldType = tfInteger) and
        (FD.Field.FieldSubType = istFieldType) then
      begin
        FD.Data.ReadBuffer(IntBuf, Size);
        if FD.Field.IsPrimeKey or FRelation.NeedSaveRUID(FD.Field) then
          SaveID(IntBuf, FRelationKey, Stream)
        else
        if FD.Field.IsForeign then
          SaveForeignKey(FD.Field.FieldName, IntBuf, Stream)
        else
          Stream.WriteBuffer(IntBuf, SizeOf(IntBuf));
      end else
        Stream.CopyFrom(FD.Data, Size);
    end;
  end;
end;

procedure TrpCortege.SelectFromDB;
var
  I: Integer;
begin
  if not (csSelected in FStates) then
  begin
    CheckSelectSQL;
    {$IFDEF DEBUG}
    if FKeyList.Count <> FRelation.Keys.Count then
      raise Exception.Create('Проверь кол-во полей, Фёдор');
    {$ENDIF}
    for I := 0 to FRelation.Keys.Count - 1 do
      FSelectSQL.ParamByName(FRelation.Keys[I].FieldName).AsString := FKeyList[I];
  
    FSelectSQL.ExecQuery;
    Include(FStates, csSelected);
  end;
end;

procedure TrpCortege.SetKey(const Value: string);
var
  P: Integer;
begin
  if FKey <> Value then
  begin
    FKey := Value;
    if FKeyDivider = '' then
      FKeyDivider := ReplDataBase.DataBaseInfo.KeyDivider;
  
    P := Pos(FKeyDivider, FKey);
    if P = 0 then
    begin
      if (FKeyList.Count > 1) or (FKeyList.Count = 0) then
      begin
        FKeyList.Clear;
        FKeyList.Add(FKey);
      end else
        FKeyList[0] := FKey;
    end else
      FKeyList.Text := StringReplace(FKey, FKeyDivider,
        #13#10, [rfReplaceAll]);
  end;
  Exclude(FStates, csLoaded);
  Exclude(FStates, csSelected);
end;

procedure TrpCortege.SetOnDeleteError(const Value: TrpErrorEvent);
begin
  FOnDeleteError := Value;
end;

procedure TrpCortege.SetOnPostError(const Value: TrpErrorEvent);
begin
  FOnPostError := Value;
end;

procedure TrpCortege.SetRelationKey(const Value: Integer);
begin
  if FRelationKey <> Value then
  begin
    FRelation := ReplDataBase.Relations[Value];
    if FRelation <> nil then
      FRelationKey := Value
    else
      raise Exception.Create(InvalidRelationKey);
  
    FSQLAssigned := False;
    FSelectSQLAssigned := False;
  
    FFieldsData.Clear;
  
    Exclude(FStates, csLoaded);
    Exclude(FStates, csSelected);
  end;
end;

function TrpCortege.Update: Boolean;
begin
  Result := Insert;
end;

procedure TrpCortege.UpdateForeignKey;
var
  Index: Integer;
begin
  if csUpdate in FStates then
  begin
    //Обновлять внешние ключи есть смысл только если происходит обновление записи
    CheckRefTableSQL;
  
    FRefTableSQL.ParamByName(fnRelation).AsString := FRelation.FRelationName;
    FRefTableSQL.ExecQuery;
    if not FRefTableSQL.EOf then
    begin
      { TODO :
      Теоретически в момент вызова данной функции FSelectSQL должен
      содержать необходимый результат }
      //SelectFromDB;
  
      if FUpdateForeignKeySQL = nil then
      begin
        FUpdateForeignKeySQL := TIBSQL.Create(nil);
        FUpdateForeignKeySQL.Transaction := ReplDataBase.Transaction;
      end;
  
      while not FRefTableSQL.Eof do
      begin
        Index := FFieldsData.IndexOfData(FRefTableSQL.FieldByName(fnOnFieldName).AsString);
        if Index > - 1 then
        begin
          FUpdateForeignKeySQL.SQL.Clear;
          FUpdateForeignKeySQL.SQL.Add(Format('UPDATE %s SET %s = :newvalue WHERE %s = :oldvalue',
            [FRefTableSQL.FieldByName(fnRelation).AsString,
             FRefTableSQl.FieldByName(fnFieldname).AsString,
             FRefTableSQl.FieldByName(fnFieldname).AsString]));
          FUpdateForeignKeySQL.ParamByName(fnNewValue).Value :=
            FFieldsData.FieldData[Index].Value;
          FUpdateForeignKeySQL.ParamByName(fnOldValue).Value :=
            FSelectSQL.FieldByName(FRefTableSQL.FieldByName(fnOnFieldName).AsString).Value;
          { TODO :
          А что если на данный внишний ключ ссылается еще какой
          нибудь внешнией ключ?}
          { TODO :
          Тут х-ня написана. Такой код не будет работать потому, что записи
          со значением ключа NewValue нет, а значит и СКЛ запрос не пройдет.
          Пока видно только два выхода:
            1. Перед репликацией всем внешним ключам, у которых  правило
            обновления стоит NONE, устанавлитать правило обновления CASCADE
            2. Перед изменением записи всем значениям внешних ключей устанавливать
            значение NULL, а после изменеия записи присваивать новые значения}
          try
            FUpdateForeignKeySQL.ExecQuery;
          except
          end;
          FUpdateForeignKeySQL.Close;
        end else
          raise Exception.Create(Format(FieldNotFound, [FRefTableSQL.FieldByName('onfieldname').AsString,
            FRelation.RelationName]));
        FRefTableSQL.Next;
      end;
    end;
  end;
end;

{
********************************** TrpStream ***********************************
}
procedure TrpStream.Read(var Buffer; Count: Integer);
begin
  FStream.Read(Buffer, Count);
end;

procedure TrpStream.Write(var Buffer; Count: Integer);
begin
  FStream.Write(Buffer, Count);
end;

{
*********************************** TrpEvent ***********************************
}
constructor TrpEvent.Create;
begin
  FKeyDivider := '';  //ReplDataBase.DataBaseInfo.KeyDivider;
end;

destructor TrpEvent.Destroy;
begin
  FLogSQL.Free;
  FKeyList.Free;
  
  inherited;
end;

procedure TrpEvent.Assign(LogRecord: TReplLogRecord);
begin
  FSeqno := LogRecord.Seqno;
  FRelationKey := LogRecord.RelationKey;
  FReplType := LogRecord.ReplType;
  case FReplType[1] of
    atInsert:
    begin
      FNewKey := LogRecord.NewKey;
      FOldKey := FNewKey;
    end;
    atUpdate:
    begin
      FOldKey := LogRecord.OldKey;
      FNewKey := LogRecord.NewKey;
    end;
    atDelete:
    begin
      FNewKey := LogRecord.OldKey;
      FOldKey := FNewKey;
    end;
  end;
  FActionTime := LogRecord.ActionTime;
end;

procedure TrpEvent.LoadFromStream(const Stream: TStream);
begin
  Stream.ReadBuffer(FSeqno, SizeOf(Seqno));
  Stream.ReadBuffer(FRelationKey, SizeOf(FRelationKey));
  FReplType := ReadStringFromStream(Stream);
  LoadKeyFromStream(FOldKey, Stream);
  //См. пометки к SaveToStream
  if FReplType = atUpdate then
    LoadKeyFromStream(FNewKey, Stream)
  else
    FNewKey := FOldKey;
  Stream.ReadBuffer(FActionTime, SizeOf(FActionTime));
end;

procedure TrpEvent.LoadKeyFromStream(var Key: string; const Stream: TStream);
var
  R: TrpRelation;
  I: Integer;
  ID: Integer;
begin
  R := ReplDataBase.Relations[FRelationKey];
  if R <> nil then
  begin
    Key := '';
    if FKeyDivider = '' then
      FKeyDivider := ReplDataBase.DataBaseInfo.KeyDivider;
  
    for I := 0 to R.Keys.Count - 1 do
    begin
      {$IFNDEF INTKEY}
      ...
      {$ENDIF}
      if Key > '' then
        Key := Key + FKeyDivider;
  
      if (R.Keys[I].FieldType = tfInteger) and
        (R.Keys[I].FieldSubType = istFieldType) then
      begin
        ID := ReadID(Stream);
        Key := Key + IntToStr(Id);
      end else
        Key := Key + ReadStringFromStream(Stream);
    end;
  end else
    raise Exception.Create(InvalidRelationKey);
end;

procedure TrpEvent.ReadFromDB(SQL: TIBSQL);
begin
  FSeqno := SQL.FieldByName(fnSeqno).AsInteger;
  FRelationKey := SQL.FieldByName(fnRelationKey).AsInteger;
  FReplType := SQL.FieldByName(fnReplType).AsString;
  case FReplType[1] of
    atInsert:
    begin
      FNewKey := SQL.FieldByName(fnNewKey).AsString;
      FOldKey := FNewKey;
    end;
    atUpdate:
    begin
      FOldKey := SQL.FieldByName(fnOldKey).AsString;
      FNewKey := SQL.FieldByName(fnNewKey).AsString;
    end;
    atDelete:
    begin
      FNewKey := SQL.FieldByName(fnOldKey).AsString;
      FOldKey := FNewKey;
    end;
  end;
  FActionTime := SQL.FieldByName(fnActionTime).AsDateTime;
end;

procedure TrpEvent.SaveKeyToStream(const Key: string; const Stream: TStream);
var
  R: TrpRelation;
  I: Integer;
  P: Integer;
begin
  R := ReplDataBase.Relations[FRelationKey];
  if R <> nil then
  begin
    if FKeyList = nil then
      FKeyList := TStringList.Create;
  
    if FKeyDivider = '' then
      FKeyDivider := ReplDataBase.DataBaseInfo.KeyDivider;
  
    P := Pos(FKeyDivider, Key);
    if P = 0 then
    begin
      if (FKeyList.Count > 1) or (FKeyList.Count = 0) then
      begin
        FKeyList.Clear;
        FKeyList.Add(Key);
      end else
        FKeyList[0] := Key;
    end else
      FKeyList.Text := StringReplace(Key, FKeyDivider,
        #13#10, [rfReplaceAll]);
  
    for I := 0 to R.Keys.Count - 1 do
    begin
      {$IFNDEF INTKEY}
      ...
      {$ENDIF}
      if (R.Keys[I].FieldType = tfInteger) and
        (R.Keys[I].FieldSubType = istFieldType) then
      begin
        SaveID(StrToInt(FKeyList[I]), FRelationKey, Stream);
      end else
        SaveStringToStream(FKeyList[I], Stream);
    end;
  end else
    raise Exception.Create(InvalidRelationKey);
end;

procedure TrpEvent.SaveToDb(SQL: TIBSQL);
begin
  with SQL do
  begin
    ParamByName(fnSeqno).AsInteger := FSeqno;
    ParamByName(fnRelationKey).AsInteger := FRelationKey;
    ParamByName(fnReplType).AsString := FReplType;
    ParamByName(fnOldKey).AsString := FOldKey;
    ParamByName(fnNewKey).AsString := FNewKey;
    ParamByName(fnActionTime).AsDateTime := FActionTime;
  end;
end;

procedure TrpEvent.SaveToStream(const Stream: TStream);
begin
  Stream.WriteBuffer(FSeqno, SizeOf(Seqno));
  Stream.WriteBuffer(FRelationKey, SizeOf(FRelationKey));
  SaveStringToStream(FReplType, Stream);
  SaveKeyToStream(FOldKey, Stream);
  //Для Insert и Delete ключи равно равны, поэтому записываем один ключ.
  //Это болжно уменьшить размер файла
  if FReplType = atUpdate then
    SaveKeyToStream(FNewKey, Stream);
  Stream.WriteBuffer(FActionTime, SizeOf(FActionTime));
end;

procedure TrpEvent.SetSeqno(const Value: Integer);
begin
  if Value <> FSeqno then
  begin
    if FLogSQL = nil then
    begin
      FLogSQL := TIBSQL.Create(nil);
      FLogSQL.Transaction := ReplDataBase.ReadTransaction;
      FLogSQL.SQL.Text := 'SELECT seqno, newkey, oldkey, relationkey, repltype, actiontime ' +
        ' FROM rpl$log WHERE seqno = :seqno';
    end;
  
    FLogSQL.ParamByName(fnSeqno).AsInteger := Value;
    FLogSQL.ExecQuery;
    ReadFromDB(FLogSQL);
    FLogSQL.Close;
  end;
end;

{
********************************* TRUIDIndices *********************************
}
function TRUIDIndices.Add(RUID: TRUID; IDIndex: PIDIndex): Integer;
var
  L, H, I, C: Integer;
  RUIDIndex: TRUIDIndex;
  P: PRUIDIndex;
begin
  if FSorted then
  begin
    I := 0;
    RUIDIndex.RUID := RUID;
    RUIDIndex.IDIndex := IDIndex;
    L := 0;
    H := Count - 1;
    while L <= H do
    begin
      I := (L + H) shr 1;
      C := FSortCompare(Items[I], @RUIDIndex);
      if C < 0 then
        L := I + 1
      else
      begin
        H := I - 1;
        if C = 0 then
        begin
          Result := I;
          //найден, выходим
          Exit;
        end;
      end;
    end;
    //Раз сюда дошли то I содержит индекс вставки элемента
    Result := I;
    New(P);
    P^ := RUIDIndex;
    inherited Insert(I, P);
  end else
  begin
    New(P);
    P^.RUID := RUID;
    P^.IDIndex := IDIndex;
    Result := inherited Add(P);
  end;
end;

procedure TRUIDIndices.GetSortCompare;
begin
  FSortCompare := RUIDIndicesSortCompare;
end;

function TRUIDIndices.IDIndex(RUID: TRUID): PIDIndex;
var
  Index: Integer;
begin
  Index := IndexOfRUID(RUID);
  if Index > - 1 then
    Result := TRUIDIndex(Items[Index]^).IDIndex
  else
    Result := nil;
end;

function TRUIDIndices.IndexOfRUID(RUID: TRUID): Integer;
var
  R: TRUIDIndex;
begin
  R.RUID := RUID;
  Result := IndexOf(@R);
end;

procedure TRUIDIndices.Insert(Index: Integer; Item: Pointer);
begin
  inherited;
  FSorted := False;
end;

procedure TRUIDIndices.Notify(Ptr: Pointer; Action: TListNotification);
begin
  //Как взрослые делаем удаление черен уведомление
  if Action = lnDeleted then
    Dispose(PIDIndex(Ptr));
end;

{
******************************* TRUIDConformitys *******************************
}
function TRUIDConformitys.Add(Item: TRUIDConformity): Integer;
var
  TR: PRUIDConformity;
begin
  New(TR);
  TR^ := Item;
  Result := inherited Add(TR);
end;

procedure TRUIDConformitys.Clear;
begin
  while Count > 0 do
    Delete(Count - 1);
  inherited;
end;

procedure TRUIDConformitys.ClearField(DBKey: Integer);
var
  SQL: TIBSQL;
begin
  if ReplDataBase.CanRepl(DBKey) then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.Transaction;
      SQL.SQL.Add('UPDATE rpl$replicationdb SET ruidconformity = :ruidconformity');
      SQL.ParamByName('ruidconformity').Clear;
      SQL.ExecQuery;
    finally
      SQL.Free;
    end;
  end else
    raise Exception.Create(InvalidDataBaseKey);
end;

procedure TRUIDConformitys.Conformity(PID, SID: Integer; RelationKey: Integer; 
        ReplKey: Integer);
var
  RC: TRUIDConformity;
  Index: Integer;
begin
  RC.RUID := ReplDataBase.RUIDManager.GetRUID(PID, RelationKey);
  RC.ConfRUID := ReplDataBase.RUIDManager.GetRUID(SID, RelationKey);
  RC.ReplID := ReplKey;
  if not CompareMem(@RC.RUID, @RC.ConfRUID, SizeOF(TRUID)) then
  begin
    Index := IndexOfRUID(RC.RUID);
    if Index = - 1 then
    begin
      Add(RC);
    end else
    begin
      Items[Index] := RC;
    end;
  end;
end;

procedure TRUIDConformitys.Delete(Index: Integer);
begin
  //  Dispose(PRUIDConformity(inherited Items[Index]));
  inherited;
end;

procedure TRUIDConformitys.DeleteFromDB;
var
  SQL: TIBSQL;
  I: Integer;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReplDataBase.Transaction;
    SQL.SQL.Text := 'DELETE FROM gd_RUID WHERE ' +
      'xid = :xid and dbid = :dbid';
    SQL.Prepare;
    for I := 0 to Count - 1 do
    begin
      SQL.ParamByName('xid').AsInteger := Items[I].ConfRUID.XID;
      SQL.ParamByName('dbid').AsInteger := Items[I].ConfRUID.DBID;
      SQL.ExecQuery;
      SQL.Close;
    end;
  //    Clear;
  finally
    SQL.Free;
  end;
end;

procedure TRUIDConformitys.DeleteFromList(ReplId: Integer);
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
  begin
    if Items[I].ReplID <= ReplId then
      Delete(I);
  end;
end;

function TRUIDConformitys.Get(Index: Integer): TRUIDConformity;
begin
  Result := TRUIDConformity(inherited Items[Index]^);
end;

procedure TRUIDConformitys.GetSortCompare;
begin
  FSortCompare := RUIDConformitysSortCompare;
end;

function TRUIDConformitys.IndexOfConfRUID(RUID: TRUID): Integer;
begin
  Result := Count - 1;
  for Result := Result downto 0 do
  begin
    if (Items[Result].ConfRUID.XID = RUID.XID) and
      (Items[Result].ConfRUID.DBID = RUID.DBID) then
      Break;
  end;
end;

function TRUIDConformitys.IndexOfRUID(RUID: TRUID): Integer;
begin
  FRUIDConf.RUID := RUID;
  Result := IndexOf(@FRUIDConf);
end;

procedure TRUIDConformitys.Invert;
var
  I: Integer;
  C: TRUIDConformity;
  R: TRUID;
begin
  for I := 0 to Count -1 do
  begin
    C := Items[I];
    R := C.RUID;
    C.RUID := C.ConfRUID;
    C.ConfRUID := R;
    Items[I] := C;
  end;
  FSorted := False;
end;

procedure TRUIDConformitys.LoadFromField(DBKey: Integer);
var
  SQL: TIBSQL;
  S: TStream;
begin
  if ReplDataBase.CanRepl(DBKey) then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.Transaction;
      SQL.SQL.Add('SELECT ruidconformity FROM rpl$replicationdb WHERE dbkey = ' +
        IntToStr(DBKey));
      SQL.ExecQuery;
      s := TMemoryStream.Create;
      try
        SQL.FieldByName('ruidconformity').SaveToStream(S);
        if S.Size > 0 then
        begin
          S.Position := 0;
          ReadFromStream(S);
        end;
      finally
        S.Free;
      end;
    finally
      SQL.Free;
    end;
  end else
    raise Exception.Create(InvalidDataBaseKey);
end;

procedure TRUIDConformitys.Notify(Ptr: Pointer; Action: TListNotification);
begin
  if Action = lnDeleted then
  begin
    Dispose(PRUIDConformity(Ptr));
  end else
    inherited;
end;

procedure TRUIDConformitys.Put(Index: Integer; const Value: TRUIDConformity);
begin
  TRUIDConformity(inherited Items[Index]^) := Value;
end;

procedure TRUIDConformitys.ReadFromStream(Stream: TStream);
var
  I, ACount: Integer;
  R: TRUIDConformity;
begin
  Clear;
  Stream.ReadBuffer(ACount, SizeOf(ACount));
  for I := 0 to ACount - 1 do
  begin
    Stream.ReadBuffer(R, SizeOf(R));
    Add(R);
  end;
end;

procedure TRUIDConformitys.RollBack(ReplID: Integer);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if Items[I].ReplID >= ReplID then
      PRUIDConformity(inherited Items[I])^.ReplID := - 1;
  end;
end;

procedure TRUIDConformitys.SaveToDB;
var
  SQL: TIBSQL;
  I: Integer;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReplDataBase.Transaction;
    SQL.SQL.Text := 'UPDATE gd_ruid SET xid = :new_xid, dbid = :new_dbid WHERE ' +
      'xid = :old_xid and dbid = :old_dbid';
  
    for I := 0 to Count - 1 do
    begin
      SQL.ParamByName('old_xid').AsInteger := Items[I].ConfRUID.XID;
      SQL.ParamByName('old_dbid').AsInteger := Items[I].ConfRUID.DBID;
      SQL.ParamByName('new_xid').AsInteger := Items[I].RUID.XID;
      SQL.ParamByName('new_dbid').AsInteger := Items[I].RUID.DBID;
      SQL.ExecQuery;
      SQL.Close;
    end;
    Clear;
  finally
    SQL.Free;
  end;
end;

procedure TRUIDConformitys.SaveToField(DBKey: Integer);
var
  SQL: TIBSQL;
  S: TStream;
begin
  if ReplDataBase.CanRepl(DBKey) then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReplDataBase.Transaction;
      SQL.SQL.Add('UPDATE rpl$replicationdb SET ruidconformity = :ruidconformity');
      S := TMemoryStream.Create;
      try
        SaveToStream(S);
        S.Position := 0;
        SQL.ParamByName('ruidconformity').LoadFromStream(S);
        SQL.ExecQuery;
      finally
        S.Free;
      end;
    finally
      SQL.Free;
    end;
  end else
    raise Exception.Create(InvalidDataBaseKey);
end;

procedure TRUIDConformitys.SaveToStream(Stream: TStream);
var
  I: Integer;
  R: TRUIDConformity;
begin
  Stream.WriteBuffer(Count, SizeOf(Count));
  for I := 0 to Count -1 do
  begin
    R := Items[I];
    Stream.WriteBuffer(R, SizeOf(R));
  end;
end;

procedure TRUIDConformitys.SaveToStream(Stream: TStream; ReplID: Integer);
var
  I: Integer;
  R: TRUIDConformity;
  lCount: Integer;
begin
  lCount := 0;
  for I := 0 to Count - 1 do
  begin
    if Items[i].ReplID = ReplID then
      Inc(lCount);
  end;
  
  Stream.WriteBuffer(lCount, SizeOf(lCount));
  
  for I := 0 to Count -1 do
  begin
    R := Items[I];
    if R.ReplID = ReplID then
      Stream.WriteBuffer(R, SizeOf(R));
  end;
end;

procedure TRUIDConformitys.SetReplKey(ReplID: Integer);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if Items[I].ReplID = - 1 then
      PRUIDConformity(inherited Items[I])^.ReplID := ReplID;
  end;
end;

{
********************************** TIDIndices **********************************
}
function TIDIndices.Add(Id, RelationKey: Integer; RUIDIndex: PRUIDIndex): 
        Integer;
var
  L, H, I, C: Integer;
  IDIndex: TIDIndex;
  P: PIDIndex;
begin
  if FSorted then
  begin
    I := 0;
    IDIndex.Id := Id;
    IDIndex.RelationKey := RelationKey;
    IDIndex.RUIDIndex := RUIDIndex;
    L := 0;
    H := Count - 1;
    while L <= H do
    begin
      I := (L + H) shr 1;
      C := FSortCompare(Items[I], @IDIndex);
      if C < 0 then
        L := I + 1
      else
      begin
        H := I - 1;
        if C = 0 then
        begin
          Result := I;
          //найден, выходим
          Exit;
        end;
      end;
    end;
    //Раз сюда дошли то I содержит индекс вставки элемента
    Result := I;
    New(P);
    P^ := IDIndex;
    inherited Insert(I, P);
  end else
  begin
    New(P);
    P^.Id := Id;
    P^.RelationKey := RelationKey;
    P^.RUIDIndex := RUIDIndex;
    Result := inherited Add(P);
  end;
end;

procedure TIDIndices.GetSortCompare;
begin
  FSortCompare := IDIndicesSortCompare;
end;

function TIDIndices.IndexOfID(ID, RelationKey: Integer): Integer;
var
  I: TIDIndex;
begin
  I.Id := ID;
  I.RelationKey := RelationKey;
  Result := IndexOf(@I);
end;

procedure TIDIndices.Insert(Index: Integer; Item: Pointer);
begin
  inherited;
  FSorted := False;
end;

procedure TIDIndices.Notify(Ptr: Pointer; Action: TListNotification);
begin
  //Как взрослые делаем удаление черен уведомление
  if Action = lnDeleted then
    Dispose(PIDIndex(Ptr));
end;

function TIDIndices.RUIDIndex(ID, RelationKey: Integer): PRUIDIndex;
var
  Index: Integer;
begin
  Index := IndexOfID(ID, RelationKey);
  if Index > - 1 then
    Result := TIDIndex(Items[Index]^).RUIDIndex
  else
    Result := nil;
end;

{
********************************** TRUIDCash ***********************************
}
procedure TRUIDCash.Add(Id: Integer; RUID: TRUID);
var
  IdIndex, RUIDIndex: Integer;
begin
  Check;
  IdIndex := FIDIndices.Add(ID, RUID.RelationID, nil);
  RUIDIndex := FRUIDIndices.Add(RUID, nil);
  
  PIDIndex(FIDIndices.Items[IdIndex])^.RUIDIndex := PRUIDIndex(FRUIDIndices[RUIDIndex]);
  PRUIDIndex(FRUIDIndices[RUIDIndex])^.IDIndex := PIDIndex(FIDIndices.Items[IdIndex]);
end;

procedure TRUIDCash.Check;
begin
  if FIDIndices = nil then
    FIDIndices := TIDIndices.Create;
  if FRUIDIndices = nil then
    FRUIDIndices := TRUIDIndices.Create;
end;

function TRUIDCash.GetIdByRUID(RUID: TRUID): Integer;
var
  IdIndex: PIDIndex;
begin
  Check;
  IdIndex := FRUIDIndices.IDIndex(RUID);
  if IdIndex <> nil then
    Result := IdIndex^.Id
  else
    Result := -1;
end;

function TRUIDCash.GetRUIDByID(ID, RelationKey: Integer): TRUID;
var
  RUIDIndex: PRUIDIndex;
begin
  Check;
  RUIDIndex := FIDIndices.RUIDIndex(ID, RelationKey);
  if RUIDIndex <> nil then
    Result := RUIDIndex.RUID
  else
    Result.XID := - 1;
end;

{
******************************** TRUIDManagerU *********************************
}
procedure TRUIDManagerU.AddRUID(Id: Integer; RUID: TRUID);
begin
end;

function TRUIDManagerU.GetId(const RUID: TRUID): Integer;
begin
  Result := RUID.XID;
end;

function TRUIDManagerU.GetInsertRUIDSQL: string;
begin
end;

function TRUIDManagerU.GetNextId(RelationId: Integer = 0): Integer;
begin
  Result := - 1;
end;

function TRUIDManagerU.GetRUID(Id: Integer; RelationId: Integer = 0): TRUID;
begin
  Result := RUID(ID, 0, 0);
end;

function TRUIDManagerU.GetSelectIdSQL: string;
begin
end;

function TRUIDManagerU.GetSelectRUIDSQL: string;
begin
end;

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
destructor TrpUniqueIndex.Destroy;
begin
  FFields.Free;
  FDelFieldsValue.Free;
  
  inherited;
end;

function TrpUniqueIndex.GetDelFieldsValue: TStrings;
begin
  if FDelFieldsValue = nil then
  begin
    FDelFieldsValue := TStringList.Create;
    FDelFieldsValue.Sorted := True;
  end;
  
  Result := FDelFieldsValue;
end;

function TrpUniqueIndex.GetFields: TrpFields;
begin
  if FFields = nil then
  begin
    FFields := TrpFields.Create;
    FFields.OwnObjects := False;
  end;
  Result := FFields;
end;

function TrpUniqueIndex.GetValues: TrpUniqueIndicesValues;
begin
  if FValues = nil then
    FValues := TrpUniqueIndicesValues.Create;
  
  Result := FValues
end;

procedure TrpUniqueIndex.SetIndexName(const Value: string);
begin
  FIndexName := Value;
end;

{
*********************************** TrpError ***********************************
}
destructor TrpError.Destroy;
begin
  FData.Free;
  inherited;
end;

function TrpError.GetData: TStream;
begin
  if FData = nil then
    FData := TMemoryStream.Create;
  
  Result :=  FData;
end;

procedure TrpError.LoadFromDb(SQL: TIBSQL);
var
  E: TrpEvent;
  C: TrpCortege;
  Str: TStream;
begin
  Data.Position := 0;
  E := TrpEvent.Create;
  C := TrpCortege.Create;
  Str := TMemoryStream.Create;
  try
    E.ReadFromDB(SQL);

    if E.ReplType <> atDelete then
    begin
      SQL.FieldByName(fnCortege).SaveToStream(Str);
      Str.Position := 0;

      C.RelationKey := E.RelationKey;
      C.LoadFromStream(Str);
    end;

    FErrorCode := SQL.FieldbyName(fnErrorCode).AsInteger;
    FErrorDescription := SQL.FieldByName(fnErrorDescription).AsString;
    FreplKey := SQL.FieldByName(fnreplKey).AsInteger;

    Data.Size := 0;
    E.SaveToStream(Data);
    if E.ReplType <> atDelete then
    begin
      C.SaveToStream(Data);
    end;
  finally
    E.Free;
    C.Free;
    Str.Free;
  end;
end;

procedure TrpError.SaveToDb(SQL: TIBSQL);
var
  E: TrpEvent;
  C: TrpCortege;
  Str: TStream;
begin
  if (FData <> nil) and (FData.Size > 0) then
  begin
    FData.Position := 0;
    E := TrpEvent.Create;
    C := TrpCortege.Create;
    Str := TMemoryStream.Create;
    try
      E.LoadFromStream(FData);
      if E.ReplType <> atDelete then
      begin
        C.RelationKey := E.RelationKey;

        C.LoadFromStream(FData);
      end;

      E.SaveToDb(SQL);

      if E.ReplType <> atDelete then
      begin
        C.SaveToStream(Str);
        Str.Position := 0;
        SQL.ParamByName(fnCortege).LoadFromStream(Str)
      end else
      begin
        SQL.ParamByName(fnCortege).Clear;
      end;

      SQL.ParamByName(fnErrorCode).AsInteger := FErrorCode;
      SQL.ParamByName(fnErrorDescription).AsString := FErrorDescription;
      SQL.ParamByName(fnReplKey).AsInteger := FReplKey;
    finally
      E.Free;
      C.Free;
      Str.Free;
    end;
  end;
end;

procedure TrpError.SetReplKey(const Value: Integer);
begin
  FReplKey := Value;
end;

{
********************************* TrpErrorList *********************************
}
function TrpErrorList.GetErrors(Index: Integer): TrpError;
begin
  Result := TrpError(Items[Index]);
end;

procedure TrpErrorList.LoadFromDb(DBKey: Integer);
var
  DSQL, SQL: TIBSQL;
  E: TrpError;
begin
  Clear;
  SQL := TIBSQL.Create(nil);
  DSQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReplDataBase.ReadTransaction;
    DSQL.Transaction := ReplDataBase.Transaction;

    SQL.SQL.Text := 'SELECT * FROM rpl$manual_log WHERE dbkey = :dbkey';
    DSQL.SQL.Text := 'DELETE FROM rpl$manual_log WHERE seqno = :seqno AND dbkey = :dbkey';

    SQL.ParamByName(fnDBKey).AsInteger := DBKey;
    SQL.ExecQuery;
    while not SQL.Eof do
    begin
      E := TrpError.Create;
      try
        E.LoadFromDb(SQL);

        Add(E);
        DSQL.ParamByName(fnSeqNo).AsInteger := SQL.FieldByName(fnSeqNo).AsInteger;
        DSQL.ParamByName(fnDBKey).AsInteger := DBKey;
        DSQL.ExecQuery;
      except
        E.Free;
      end;
      SQL.Next;
    end;
  finally
    SQL.Free;
    DSQL.Free;
  end;
end;

procedure TrpErrorList.SaveToDb(DBKey: Integer);
var
  I: Integer;
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReplDataBase.Transaction;
    SQL.SQL.Text := 'INSERT INTO rpl$manual_log (SEQNO, RELATIONKEY, REPLTYPE, DBKEY, REPLKEY, ' +
      'OLDKEY, NEWKEY, ACTIONTIME, CORTEGE, ERRORCODE, ERRORDESCRIPTION) VALUES (:SEQNO, :RELATIONKEY, :REPLTYPE, :DBKEY, :REPLKEY, ' +
      ':OLDKEY, :NEWKEY, :ACTIONTIME, :CORTEGE, :ERRORCODE, :ERRORDESCRIPTION)';
    for I := 0 to Count - 1 do
    begin
      SQl.Close;
      Errors[I].SaveToDb(SQL);
      SQL.ParamByName(fnDBKey).AsInteger := DBKey;
      SQL.ExecQuery;
    end;
  finally
    SQL.Free;
  end;
end;

{
********************************* TrpRecordSet *********************************
}
destructor TrpRecordSet.Destroy;
begin
  inherited Destroy;
end;

{
******************************* TrpRecordSetList *******************************
}
destructor TrpRecordSetList.Destroy;
begin
  FreeAndNil(FRecordSet);
  inherited Destroy;
end;

function TrpRecordSetList.GetRelationsData(RelationKey: Integer): TrpRecordSet;
var
  Index: Integer;
  R: TrpRecordSet;
begin
  Index := IndexOfRelation(RelationKey);
  
  if Index = - 1 then
  begin
    R := TrpRecordSet.Create;
    R.RelationKey := RelationKey;
    Index := Add(R);
  end;
  
  Result := TrpRecordSet(inherited Items[Index]);
end;

procedure TrpRecordSetList.GetSortCompare;
begin
  FSortCompare := RelationDataSortCompare;
end;

function TrpRecordSetList.IndexOfRelation(RelationKey: Integer): Integer;
var
  Index: Integer;
begin
  Index := ReplDatabase.Relations.IndexofRelation(RelationKey);

  if Index > - 1 then
  begin
    if FRecordSet = nil then
      FRecordSet := TrpRecordSet.Create;

    FRecordSet.RelationKey := RelationKey;

    Result := inherited IndexOf(FRecordSet);
  end else
  begin
    raise Exception.Create(InvalidRelationKey);
  end;
end;

{
******************************** TrpRecordData *********************************
}
function TrpRecordData.GetData: TStream;
begin
  if FData = nil then
    FData := TMemoryStream.Create;

  Result := FData;
end;

function TrpRecordData.GetUniqueInices: TrpUniqueIndices;
begin
  if FUniqueInices = nil then
    FUniqueInices := TrpUniqueIndices.Create;

  Result := FUniqueInices
end;

{ TrpUniqueIndicesValues }
function UniqueIndicesValueSortCompare(Item1, Item2: Pointer): Integer;
begin
  Result := AnsiCompareStr(PrpUniqueIndexValue(Item1)^.Value, PrpUniqueIndexValue(Item2)^.Value);
end;

procedure TrpUniqueIndicesValues.GetSortCompare;
begin
  FSortCompare := UniqueIndicesValueSortCompare;
end;

function TrpUniqueIndicesValues.GetValues(
  Index: Integer): TrpUniqueIndexValue;
begin
  Result := PrpUniqueIndexValue(Items[Index])^;
end;

procedure TrpUniqueIndicesValues.SetValues(Index: Integer;
  const Value: TrpUniqueIndexValue);
var
  V:  PrpUniqueIndexValue;
begin
  V := PrpUniqueIndexValue(Items[Index]);
  V^ := Value;
end;

function TReplDataBase.ConflictCount(DBKey: Integer): Integer;
begin
  CheckReadSQL;
  FReadSQL.SQL.Text := 'SELECT COUNT(*) FROM RPL$MANUAL_LOG WHERE dbkey = :dbkey';
  FReadSQL.ParamByName(fnDbKey).AsInteger := DBKey;
  try
    FReadSQl.ExecQuery;
    Result:= FReadSQL.Fields[0].AsInteger;
  except
    Result:= -1;
  end;
end;

procedure TrpRecordSet.GetSortCompare;
begin

end;

procedure TReplLog.MarkTransferedRecords(ReplKey: Integer);
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    Clear;
    SQL.Transaction := ReplDataBase.Transaction;
    SQL.SQL.Text :=
      'INSERT INTO rpl$loghist (seqno, dbkey, replkey, tr_commit)' +
      ' SELECT SEQNO, :dbkey, :replkey, 0 ' +
      ' FROM rpl$log l WHERE NOT l.seqno IN(SELECT lh.seqno FROM ' +
      ' rpl$loghist lh WHERE lh.dbkey = :dbkey AND lh.tr_commit <> - 1) ';
    SQl.ParamByName('dbkey').AsInteger := FDBKey;
    SQl.ParamByName('replkey').AsInteger := ReplKey;
    SQL.ExecQuery;
  finally
    SQL.Free;
  end;
end;

function TReplLog.GetChangesCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    if not PReplLogRecord(Items[i])^.NeedDelete then
      Inc(Result);
  end;
end;

function TrpRelation.NeedSaveRUID(F: TrpField): Boolean;
begin
  {$IFNDEF INTKEY}
  ...
  {$ENDIF}
  Result := (F.FieldType = tfInteger) and (F.FieldSubType = istFieldType) and
    ((FNeedSaveRUIDFields <> nil) and (FNeedSaveRUIDFields.IndexOf(F) > - 1));
end;

function TReplDataBase.GetServerName: string;
begin
  Result := FServerName
end;

procedure TrplStreamHeader.SetToDBKey(const Value: Integer);
begin
  FToDBKey := Value;
end;

initialization

finalization
  _ReplDataBase.Free;
  _CommandString.Free;
end.
