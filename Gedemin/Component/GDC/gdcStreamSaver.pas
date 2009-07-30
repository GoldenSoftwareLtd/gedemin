unit gdcStreamSaver;

interface

uses
  gdcBase,              gdcBaseInterface,           classes,
  dbclient,             IBDatabase,                 IBSQL,
  contnrs,              dbgrids,                    comctrls,
  gd_KeyAssoc,          db,                         gdcSetting;

type
  TStreamFileFormat = (ffBinary, ffXML);

  TgsStreamType = (sttUnknown, sttBinaryOld, sttBinaryNew, sttXML);

  TReplaceRecordBehaviour = (rrbAlways, rrbNever, rrbShowDialog);

  TgsStreamLoggingType = (slNone, slSimple, slAll);

  TXMLElementType =
    (etUnknown,                // неизвестный элемент
     etStream,                 // весь поток (или сохраненные данные в XML настройке)
     etHeader,                 // заголовок потока
     etVersion,                // версия потока
     etDBID,                   // DBID базы-источника
     etDataBaseList,           // список баз данных из таблицы RPL_DATABASE
     etDataBase,               //   одна база данных
     etSender,                 // ID базы-источника (из таблицы RPL_DATABASE)
     etReceiver,               // ID целевой базы (из таблицы RPL_DATABASE)
     etReceivedRecordList,     // список записей, получение которых подтверждает база-источник
     etReceivedRecord,         //   одна запись
     etReferencedRecordList,   // список записей, которые не были сохранены в поток, ввиду их предполагаемого присутствия на целевой базе
     etReferencedRecord,       //   одна запись
     etObjectList,             // список бизнес-объектов сохраненных в потоке
     etObject,                 //   один объект
     etOrder,                  // порядок загрузки записей
     etOrderItem,              //   одна запись
     etData,                   // данные датасетов сохраненные в потоке
     etDataset,                //   один датасет
     etSetting,                // настройка
     etSettingHeader,          // шапка настройки
     etSettingPosList,         // список позиций настройки
     etSettingPos,             //   позиция настройки
     etStoragePosList,         // список позиций хранилища в настройке
     etStoragePos,             //   позиция хранилища
     etSettingData,            // данные настройки (из поля DATA)
     etSettingStorage,         // данные настройки (из поля STORAGEDATA)
     etStorage,                // данные хранилища
     etStorageFolder,          // ветка хранилища
     etStorageValue            // параметр ветки хранилища
    );

  TStreamReferencedRecord = record
    SourceID: TID;
    RUID: TRUID;
  end;

  TStreamOrderElement = record
    Index: Integer;
    DSIndex: Integer;
    RecordID: TID;
    Disabled: Boolean;
  end;

  TStreamOrderList = class(TObject)
  protected
    FItems: array of TStreamOrderElement;
    FCount: Integer;
    FSize: Integer;

    function GetOrderElement(Index: Integer): TStreamOrderElement;
  public
    constructor Create;
    destructor Destroy; override;

    function AddItem(AID: TID; ADSIndex: Integer = -1): Integer;
    function Find(const AID: TID; const ADSIndex: Integer = -1; AndDisabled: Boolean = false): Integer;
    procedure Remove(const AID: TID; const ADSIndex: Integer = -1);
    procedure Reset;

    property Count: Integer read FCount;
    property Items[Index: Integer]: TStreamOrderElement read GetOrderElement;
  end;

  TgdcStreamLoadingOrderList = class(TStreamOrderList)
  private
    FIsLoading: Boolean;
    FNext: Integer;
  public
    constructor Create;

    function PopNextElement(out Element: TStreamOrderElement): Boolean;
    function PopElementByID(const AID: TID; out Element: TStreamOrderElement): Boolean;

    procedure SaveToStream(Stream: TStream; const AFormat: TgsStreamType = sttBinaryNew);
    procedure LoadFromStream(Stream: TStream; const AFormat: TgsStreamType = sttBinaryNew);
  end;

  TgdcStreamDataObject = class(TObject)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;

    // если false, то при добавлении нового объекта не будут создаваться
    //   списки таблиц и ссылок в которых ищем объекты дочерние данному
    FIsSave: Boolean;
    // инкрементный ли поток
    FIsIncrementedStream: Boolean;

    // при сохранении в поток, в массив записываем RUID'ы записей получение которых мы подтверждаем
    // при загрузке из потока, в массив записываем RUID'ы записей получение которых подтверждает база-источник потока
    FReceivedRecords: array of TRuid;
    FReceivedRecordsCount: Integer;
    FReceivedRecordsSize: Integer;

    FReferencedRecords: array of TStreamReferencedRecord;
    FReferencedRecordsCount: Integer;
    FReferencedRecordsSize: Integer;

    FIncrDatabaseList: TStringList;

    FCount: Integer;
    FSize: Integer;
    FObjectList: TStringList;
    FObjectArray: array of TgdcBase;
    FClientDSArray: array of TClientDataSet;

    // ссылки из бизнес-объекта
    FObjectForeignKeyFields: array of TStrings;
    FObjectForeignKeyClasses: array of TStrings;
    FObjectCrossTables: array of TStringList;
    // объекты присоединенные 1 к 1
    FOneToOneTables: array of TStrings;
    // детальные ссылки на бизнес-объект
    FObjectDetailReferences: array of TObjectList;

    FStreamDBID: TID;
    FStreamVersion: Integer;

    FOurBaseKey: TID;
    FTargetBaseKey: TID;
    FSourceBaseKey: TID;

    FStorageItemList: TStringList;

    function CheckIndex(const Index: Integer): Boolean;

    procedure FillReferences(const Index: Integer);

    function GetgdcObject(Index: Integer): TgdcBase;
    function GetClientDS(Index: Integer): TClientDataSet;
    function GetObjectDetailReferences(Index: Integer): TObjectList;
    function GetObjectCrossTables(Index: Integer): TStringList;
    function GetReceivedRecord(Index: Integer): TRuid;
    function GetReferencedRecord(Index: Integer): TStreamReferencedRecord;
    procedure SetTransaction(const Value: TIBTransaction);
    function GetObjectForeignKeyFields(Index: Integer): TStrings;
    function GetObjectForeignKeyClasses(Index: Integer): TStrings;
    procedure SetTargetBaseKey(const Value: TID);
    function GetOneToOneTables(Index: Integer): TStrings;
  public
    constructor Create(ADatabase: TIBDatabase = nil; ATransaction:
      TIBTransaction = nil; const ASize: Integer = 32);
    destructor Destroy; override;

    function Add(const AClassName: TgdcClassName; const ASubType: TgdcSubType; const ASetTableName: ShortString = ''; const IsSettingObject: Boolean = false): Integer;
    procedure AddData(const Index: Integer; AObj: TgdcBase); overload;
    procedure AddData(const Index: Integer; const AID: TID); overload;
    function Find(const AClassName: TgdcClassName; const ASubType: TgdcSubType; const ASetTableName: ShortString = ''): Integer;
    function GetObjectIndex(const AClassName: TgdcClassName; const ASubType: TgdcSubType; const ASetTableName: ShortString = ''): Integer;

    procedure AddReceivedRecord(const AXID, ADBID: TID);
    procedure AddReferencedRecord(const AID, AXID, ADBID: TID);
    function FindReferencedRecord(const AID: TID): Integer;

    function GetSetObject(const AClassName: TgdcClassName; const ASubType: TgdcSubType; const ASetTableName: ShortString): TgdcBase;

    procedure CheckGDCObjectsActive;

    property ReceivedRecordsCount: Integer read FReceivedRecordsCount;
    property ReceivedRecord[Index: Integer]: TRuid read GetReceivedRecord;

    property ReferencedRecordsCount: Integer read FReferencedRecordsCount;
    property ReferencedRecord[Index: Integer]: TStreamReferencedRecord read GetReferencedRecord;

    property Count: Integer read FCount;
    property gdcObject[Index: Integer]: TgdcBase read GetgdcObject;
    property ClientDS[Index: Integer]: TClientDataSet read GetClientDS;

    property ObjectForeignKeyFields[Index: Integer]: TStrings read GetObjectForeignKeyFields;
    property ObjectForeignKeyClasses[Index: Integer]: TStrings read GetObjectForeignKeyClasses;
    property OneToOneTables[Index: Integer]: TStrings read GetOneToOneTables;
    property ObjectCrossTables[Index: Integer]: TStringList read GetObjectCrossTables;
    property ObjectDetailReferences[Index: Integer]: TObjectList read GetObjectDetailReferences;

    property StreamDBID: TID read FStreamDBID write FStreamDBID;
    property StreamVersion: Integer read FStreamVersion write FStreamVersion;

    property OurBaseKey: TID read FOurBaseKey write FOurBaseKey;
    property TargetBaseKey: TID read FTargetBaseKey write SetTargetBaseKey;
    property SourceBaseKey: TID read FSourceBaseKey write FSourceBaseKey;

    property StorageItemList: TStringList read FStorageItemList write FStorageItemList;

    property Transaction: TIBTransaction read FTransaction write SetTransaction;

    property DatabaseList: TStringList read FIncrDatabaseList;

    property IsSave: Boolean read FIsSave write FIsSave;
    property IsIncrementedStream: Boolean read FIsIncrementedStream write FIsIncrementedStream;
  end;

  TgdcStreamDataProvider = class(TObject)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;

    FIBSQL: TIBSQL;
    FIbsqlRPLRecordSelect: TIBSQL;
    FIbsqlRPLRecordInsert: TIBSQL;
    FIbsqlRPLRecordDelete: TIBSQL;

    FDataObject: TgdcStreamDataObject;
    FLoadingOrderList: TgdcStreamLoadingOrderList;
    FNowSavedRecords: TStreamOrderList;

    FReplaceRecordBehaviour: TReplaceRecordBehaviour;
    FReplaceFieldList: TStringList;

    FIDMapping: TgdKeyIntAssoc; // карта идентификаторов
    FUpdateList: TObjectList;   // список в котором будут записи, требующие обновления foreignkeys после вставки ссылаемой записи

    FAnAnswer: Word;

    FSaveWithDetailList: TgdKeyArray;
    FNeedModifyList: TgdKeyIntAssoc;

    function GetIbsqlRPLRecordSelect: TIBSQL;
    function GetIbsqlRPLRecordInsert: TIBSQL;
    function GetIbsqlRPLRecordDelete: TIBSQL;

    procedure SetLoadingOrderList(const Value: TgdcStreamLoadingOrderList);
    procedure SetDataObject(const Value: TgdcStreamDataObject);
    //сохраняет все присоединенные объекты для объектов уже сохраненных в клиент-датасетах
    procedure SaveBindedObjects(const AObjectIndex: Integer; const AID: TID);
    // Сохраняет объекты относящиеся как 1 к 1 к сохраняемому бизнес-объекту
    procedure SaveOneToOne(const AObjectIndex: Integer; const AID: TID);
    //сохраняет детальные объекты для БО
    procedure SaveDetail(const AObjectIndex: Integer; const AID: TID);
    //в зависимости от типа объекта, сохраняет определенные объекты
    // например для TgdcExplorer сохраняется функция которую он вызывает
    procedure SaveSpecial(const AObjectIndex: Integer; const AID: TID);
    //сохраняет множества для БО
    procedure SaveSet(AObj: TgdcBase);

    // Выполняет особые для некоторых объектов действия перед сохранением в поток.
    function DoBeforeSaving(AObj: TgdcBase): Boolean;
    // Выполняет особые для некоторых объектов действия после сохранением в поток.
    function DoAfterSaving(AObj: TgdcBase): Boolean;

    // проверяем настройки Гедемина насчет загрузки записей уже существующих на базе,
    //   выводим форму сравнения записей
    function CheckNeedModify(ABaseRecord: TgdcBase; AStreamRecord: TClientDataSet): Boolean;
    // Проверяем по таблице RPL_RECORD необходимость сохранения данной записи в поток
    //  возможно, мы уже отправляли ее на целевую базу
    function CheckNeedSaveRecord(const AID: TID; AModified: TDateTime): Boolean;
    // Проверяем по таблице RPL_RECORD необходимость загрузки данной записи из потока на базу.
    function CheckNeedLoadingRecord(const XID, DBID: TID; AModified: TDateTime): Boolean;

    procedure LoadSetRecord(AObj: TgdcBase; SourceDS: TDataSet);

    procedure InsertRecord(SourceDS: TDataSet; TargetDS: TgdcBase);
    function CopyRecord(SourceDS: TDataSet; TargetDS: TgdcBase): Boolean;
    procedure ApplyDelayedUpdates(SourceKeyValue, TargetKeyValue: Integer);

    procedure AddRecordToRPLRECORDS(const AID: TID; AModified: TDateTime);
    procedure SetTransaction(const Value: TIBTransaction);

    property IbsqlRPLRecordSelect: TIBSQL read GetIbsqlRPLRecordSelect;
    property IbsqlRPLRecordInsert: TIBSQL read GetIbsqlRPLRecordInsert;
    property IbsqlRPLRecordDelete: TIBSQL read GetIbsqlRPLRecordDelete;
  public
    constructor Create(ADatabase: TIBDatabase = nil; ATransaction: TIBTransaction = nil);
    destructor Destroy; override;

    //сохраняет данные объекта в клиент-датасет
    procedure SaveRecord(const AObject: TgdcBase; const ObjectIndex: Integer; const AID: TID; const AWithDetail: Boolean = true); overload;
    procedure SaveRecord(const ObjectIndex: Integer; const AID: TID; const AWithDetail: Boolean = true); overload;

    procedure LoadRecord(AObj: TgdcBase; CDS: TClientDataSet);

    // загружает записи-множества
    procedure LoadSetRecords;

    procedure LoadReceivedRecords;

    // сравнивает список баз данных из потока и из таблицы RPL_DATABASE,
    //  если в потоке появились новые базы, вставляет их в таблицу
    procedure ProcessDatabaseList;

    //Ищет в таблице RPL_RECORD записи отправленные с прошлым потоком
    //  на целевую базу, но не получившие статус Приняты. Спрашиваем переслать ли заново.
    procedure CheckNonConfirmedRecords;
    //Ищем записи пришедшие с целевой базы и требующие подтверждения о принятии.
    //  Сохраняем полученные данные в TgdcStreamDataObject.
    procedure GetRecordsWithInState;

    procedure SaveStorageItem(const ABranchName, AValueName: String);

    procedure LoadStorage;

    procedure Reset;

    property LoadingOrderList: TgdcStreamLoadingOrderList read FLoadingOrderList write SetLoadingOrderList;
    property DataObject: TgdcStreamDataObject read FDataObject write SetDataObject;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
    property ReplaceRecordBehaviour: TReplaceRecordBehaviour read FReplaceRecordBehaviour write FReplaceRecordBehaviour;
    property AnAnswer: Word read FAnAnswer write FAnAnswer;

    property SaveWithDetailList: TgdKeyArray read FSaveWithDetailList write FSaveWithDetailList;
    property NeedModifyList: TgdKeyIntAssoc read FNeedModifyList write FNeedModifyList;
  end;

  TgdcStreamWriterReader = class(TObject)
  private
    FDataObject: TgdcStreamDataObject;
    FLoadingOrderList: TgdcStreamLoadingOrderList;

    procedure SetDataObject(const Value: TgdcStreamDataObject);
    procedure SetLoadingOrderList(const Value: TgdcStreamLoadingOrderList);
  public
    constructor Create(AObjectSet: TgdcStreamDataObject = nil; ALoadingOrderList: TgdcStreamLoadingOrderList = nil);
    destructor Destroy; override;

    procedure SaveToStream(S: TStream); virtual; abstract;
    procedure LoadFromStream(const S: TStream); virtual; abstract;

    procedure SaveStorageToStream(S: TStream); virtual; abstract;
    procedure LoadStorageFromStream(const S: TStream; AnStAnswer: Word); virtual; abstract;

    property DataObject: TgdcStreamDataObject read FDataObject write SetDataObject;
    property LoadingOrderList: TgdcStreamLoadingOrderList read FLoadingOrderList write SetLoadingOrderList;
  end;

  TgdcStreamBinaryWriterReader = class(TgdcStreamWriterReader)
  public
    procedure SaveToStream(S: TStream); override;
    procedure LoadFromStream(const S: TStream); override;

    procedure SaveStorageToStream(S: TStream); override;
    procedure LoadStorageFromStream(const S: TStream; AnStAnswer: Word); override;
  end;

  TgdcStreamXMLWriterReader = class(TgdcStreamWriterReader)
  private
    FElementLevel: Integer;
    // Возвращает открывающий XML-тег
    //   ATag - имя тега
    //   ASingleLineElement - элемент располагается в одну строку
    //   AHasAttribute - содержит ли тег атрибуты
    function AddOpenTag(const ATag: String;
      const ASingleLineElement: Boolean = false; const AHasAttribute: Boolean = false): String;
    // Возвращает закрывающий XML-тег
    //   ATag - имя тега
    //   ASingleLineElement - элемент располагается в одну строку
    //   AShortClosingTag - определяет тип тега ('</TAG>' или '/>')
    function AddCloseTag(const ATag: String;
      const ASingleLineElement: Boolean = false; const AShortClosingTag: Boolean = false): String;
    // Возвращает отформатированный XML-атрибут
    //   ASingleLineElement - элемент располагается в одну строку
    function AddAttribute(const ATag, AValue: String;
      const ASingleLineElement: Boolean = false): String;

    function RepeatString(const StringToRepeat: String; const RepeatCount: Integer): String;
    function GetNextElement(const St: TStream; out ElementStr: String): TXMLElementType;
    function GetTextValueOfElement(const St: TStream; const ElementHeader: String): String;
    function GetParamValueByName(const Str, ParamName: String): String;
    function GetIntegerParamValueByName(const Str, ParamName: String): Integer;
    // заменяет символы   ' " & < >   на   &apos; &quot; &amp; &lt; &gt;   соответственно
    function QuoteString(Str: String): String;
    // заменяет символы   &apos; &quot; &amp; &lt; &gt;   на   ' " & < >   соответственно
    function UnQuoteString(Str: String): String;
    function GetPositionOfString(S: TStream; Str: String): Integer;
    //procedure SaveDataset(S: TStream; CDS: TClientDataSet);
  public
    constructor Create(AObjectSet: TgdcStreamDataObject = nil; ALoadingOrderList: TgdcStreamLoadingOrderList = nil);

    procedure SaveToStream(S: TStream); override;
    procedure LoadFromStream(const S: TStream); override;

    procedure SaveStorageToStream(S: TStream); override;
    procedure LoadStorageFromStream(const S: TStream; AnStAnswer: Word); override;

    procedure SaveXMLSettingToStream(S: TStream);
    procedure LoadXMLSettingFromStream(S: TStream);
    function GetXMLSettingHeader(S: TStream; SettingHeader: TSettingHeader): Boolean;

    property ElementLevel: Integer read FElementLevel write FElementLevel;
  end;

  TgdcStreamSaver = class(TObject)
  private
    FStreamDataProvider: TgdcStreamDataProvider;
    FStreamLoadingOrderList: TgdcStreamLoadingOrderList;
    FDataObject: TgdcStreamDataObject;

    FTransaction: TIBTransaction;
    FTrWasCreated: Boolean;
    FTrWasActive: Boolean;

    // Используется для логгирования ошибок при репликации
    FErrorMessageForSetting: WideString;

    procedure SetTransaction(const Value: TIBTransaction);
    procedure SetSilent(const Value: Boolean);
    function GetSilent: Boolean;
    procedure SetReadUserFromStream(const Value: Boolean);
    function GetReadUserFromStream: Boolean;
    function GetReplaceRecordBehaviour: TReplaceRecordBehaviour;
    procedure SetReplaceRecordBehaviour(
      const Value: TReplaceRecordBehaviour);
    function GetIsAbortingProcess: Boolean;
    procedure SetIsAbortingProcess(const Value: Boolean);
    function GetStreamLogType: TgsStreamLoggingType;
    procedure SetStreamLogType(const Value: TgsStreamLoggingType);
    function GetNeedModifyList: TgdKeyIntAssoc;
    function GetSaveWithDetailList: TgdKeyArray;
    procedure SetNeedModifyList(const Value: TgdKeyIntAssoc);
    procedure SetSaveWithDetailList(const Value: TgdKeyArray);
  public
    constructor Create(ADatabase: TIBDatabase = nil; ATransaction: TIBTransaction = nil);
    destructor Destroy; override;

    // подготавливает объект для инкрементного сохранения, заполняет поля TargetBaseKey
    //   вытягивает записи из RPL_RECORD со статусом irsIn(0)
    procedure PrepareForIncrementSaving(const ABasekey: TID = -1);

    // сохраняет данные переданноо объекта и объектов по ссылкам из него в память
    procedure AddObject(AgdcObject: TgdcBase; const AWithDetail: Boolean = true);
    // сохраняет данные о переданных объектах из памяти в поток
    procedure SaveToStream(S: TStream; const AFormat: TgsStreamType = sttBinaryNew);
    // загружает данные из потока на базу
    procedure LoadFromStream(S: TStream);

    // загружает настройку из XML потока на базу (без активации)
    procedure LoadSettingFromXMLFile(S: TStream);
    // сохраняет данные переданной через AddObject настройки в XML поток
    procedure SaveSettingToXMLFile(S: TStream);

    // используется для активации настройки, загружает данные из потока на базу
    procedure LoadSettingDataFromStream(S: TStream; var WasMetaDataInSetting: Boolean; const DontHideForms: Boolean; var AnAnswer: Word);
    // используется для сохранения данных настройки в блоб
    procedure SaveSettingDataToStream(S: TStream; ASettingKey: TID);
    // используется для сохранения хранилища настройки в блоб
    procedure LoadSettingStorageFromStream(S: TStream; AnStAnswer: Word);
    // используется для сохранения хранилища настройки в блоб
    procedure SaveSettingStorageToStream(S: TStream; ASettingKey: TID);
    // заполняет переданный список РУИДами входящих в настройку объектов (не только позиций настройки)
    procedure FillRUIDListFromStream(S: TStream; RuidList: TStrings; const SettingID: Integer = -1);

    property Silent: Boolean read GetSilent write SetSilent;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
    property ReadUserFromStream: Boolean read GetReadUserFromStream write SetReadUserFromStream;
    property IsAbortingProcess: Boolean read GetIsAbortingProcess write SetIsAbortingProcess;
    property ReplaceRecordBehaviour: TReplaceRecordBehaviour read GetReplaceRecordBehaviour write SetReplaceRecordBehaviour;
    property StreamLogType: TgsStreamLoggingType read GetStreamLogType write SetStreamLogType;

    property SaveWithDetailList: TgdKeyArray read GetSaveWithDetailList write SetSaveWithDetailList;
    property NeedModifyList: TgdKeyIntAssoc read GetNeedModifyList write SetNeedModifyList;

    property ErrorMessageForSetting: WideString read FErrorMessageForSetting;
  end;

const
  XML_TAG_STREAM = 'STREAM';
  XML_TAG_HEADER = 'HEADER';
  XML_TAG_VERSION = 'VERSION';
  XML_TAG_DBID = 'DBID';
  XML_TAG_DATABASE_LIST = 'DATABASE_LIST';
  XML_TAG_DATABASE = 'DATABASE';
  XML_TAG_SENDER = 'SENDER';
  XML_TAG_RECEIVER = 'RECEIVER';
  XML_TAG_RECEIVED_RECORD_LIST = 'RECEIVED_RECORD_LIST';
  XML_TAG_RECEIVED_RECORD = 'RECEIVED_RECORD';
  XML_TAG_REFERENCED_RECORD_LIST = 'REFERENCED_RECORD_LIST';
  XML_TAG_REFERENCED_RECORD = 'REFERENCED_RECORD';
  XML_TAG_OBJECT_LIST = 'OBJECT_LIST';
  XML_TAG_OBJECT = 'OBJECT';
  XML_TAG_LOADING_ORDER = 'LOADING_ORDER';
  XML_TAG_LOADING_ORDER_ITEM = 'ITEM';
  XML_TAG_DATA = 'DATA';
  XML_TAG_DATASET = 'DATASET';

  XML_TAG_SETTING = 'SETTING';
  XML_TAG_SETTING_HEADER = 'SETTING_HEADER';
  XML_TAG_SETTING_POS_LIST = 'SETTING_POS_LIST';
  XML_TAG_SETTING_POS = 'SETTING_POS';
  XML_TAG_STORAGE_POS_LIST = 'STORAGE_POS_LIST';
  XML_TAG_STORAGE_POS = 'STORAGE_POS';
  XML_TAG_SETTING_DATA = 'SETTING_DATA';
  XML_TAG_SETTING_STORAGE = 'SETTING_STORAGE';
  XML_TAG_STORAGE = 'STORAGE';
  XML_TAG_STORAGE_FOLDER = 'STORAGE_FOLDER';
  XML_TAG_STORAGE_VALUE = 'STORAGE_VALUE';

  function GetStreamType(Stream: TStream): TgsStreamType;

implementation

uses
  SysUtils,               at_sql_metadata,       gs_Exception,
  gd_security,            at_classes,            Windows,
  at_sql_parser,          at_sql_setup,          JclStrings,
  at_frmSQLProcess,       graphics,              gdcClasses,
  gdcConstants,           gd_directories_const,  IB,
  IBErrorCodes,           gdcMetadata,           gdcDelphiObject,
  Storages,               Forms,                 controls,
  at_dlgCompareRecords,   Dialogs,               gsStorage,
  gdc_frmStreamSaver,     zlib,                  gdcInvDocument_unit;

type
  TgdcReferenceUpdate = class(TObject)
  public
    FieldName: String;
    ObjectIndex: Integer;
    ID: TID;
    RefID: TID;
  end;

  TIncrRecordState = (irsIn, irsOut, irsIncremented);

  EgsInvalidIndex = class(Exception);
  EgsClientDatasetNotFound = class(Exception);

const
  sqlSelectOurBaseID =
    'SELECT FIRST(1) id FROM rpl_database WHERE isourbase = 1';
  sqlSelectAllBases =
    'SELECT id, name, (SELECT count(id) FROM rpl_database) as BasesCount FROM rpl_database';

  sqlDeleteRPLRecordsByBaseKeyID =
    'DELETE FROM ' +
    '  rpl_record ' +
    'WHERE ' +
    '  basekey = %0:d ' +
    '  AND id = %1:d ';
  sqlDeleteRPLRecordsByIDEditiondate =
    'DELETE FROM ' +
    '  rpl_record ' +
    'WHERE ' +
    '  id = :id ' +
    '  AND editiondate < :editiondate ';
  sqlDeleteRPLRecordsByBaseKeyRUID =
    'DELETE FROM ' +
    '  rpl_record ' +
    'WHERE ' +
    '  basekey = %0:d ' +
    '  AND id = (SELECT FIRST(1) r.id FROM gd_ruid r WHERE r.xid = %1:d AND r.dbid = %2:d)';
  sqlDeleteRPLRecordsByRUID =
    'DELETE FROM ' +
    '  rpl_record ' +
    'WHERE ' +
    '  id = (SELECT FIRST(1) r.id FROM gd_ruid r WHERE r.xid = %1:d AND r.dbid = %2:d)';

  sqlInsertRPLRecordsIDStateEditionDate =
    'INSERT INTO ' +
    '  rpl_record (id, basekey, state, editiondate) ' +
    '  VALUES (:id, %d, :state, :editiondate)';
  sqlInsertRPLRecordsIDBaseKeyState =
    'INSERT INTO ' +
    '  rpl_record (id, basekey, state, editiondate) ' +
    '  VALUES (%d, %d, %d, :editiondate)';

  sqlUpdateRPLRecordsSetStateDate =
    'UPDATE ' +
    '  rpl_record ' +
    'SET ' +
    '  state = %3:d, editiondate = :editdate ' +
    'WHERE ' +
    '  basekey = %0:d ' +
    '  AND id = (SELECT FIRST(1) r.id FROM gd_ruid r WHERE r.xid = %1:d AND r.dbid = %2:d)';
  sqlUpdateRPLRecordsSetStateByBasekeyRUID =
    'UPDATE ' +
    '  rpl_record ' +
    'SET ' +
    '  state = %1:d ' +
    'WHERE ' +
    '  basekey = %0:d ' +
    '  AND id = (SELECT FIRST(1) r.id FROM gd_ruid r WHERE r.xid = :xid AND r.dbid = :dbid)';
  sqlUpdateRPLRecordsSetStateByBasekey =
    'UPDATE ' +
    '  rpl_record ' +
    'SET ' +
    '  state = %1:d ' +
    'WHERE ' +
    '  basekey = %0:d ' +
    '  AND state = 0';

  sqlSelectRPLRecordsByBasekeyState =
    'SELECT ' +
    '  rep.id, ' +
    '  r.xid, ' +
    '  r.dbid, ' +
    '  rep.editiondate, ' +
    '  rep.state ' +
    'FROM ' +
    '  rpl_record rep ' +
    '  JOIN gd_ruid r ON r.id = rep.id ' +
    'WHERE ' +
    '  rep.basekey = %d ' +
    '  AND rep.state = %d';
  sqlSelectRPLRecordsDateStateByBaseKeyID =
    'SELECT ' +
    '  editiondate, ' +
    '  state ' +
    'FROM ' +
    '  rpl_record ' +
    'WHERE ' +
    '  basekey = %0:d ' +
    '  AND id = :id ';
  sqlSelectRPLRecordsDateStateByBaseKeyRUID =
    'SELECT ' +
    '  rep.editiondate, ' +
    '  rep.state ' +
    'FROM ' +
    '  rpl_record rep ' +
    '  JOIN gd_ruid r ON r.id = rep.id ' +
    'WHERE ' +
    '  rep.basekey = %d ' +
    '  AND r.xid = %d AND r.dbid = %d';
  sqlSelectRPLRecordsDateStateByRUID =
    'SELECT ' +
    '  rep.editiondate, ' +
    '  rep.state ' +
    'FROM ' +
    '  rpl_record rep ' +
    '  JOIN gd_ruid r ON r.id = rep.id ' +
    'WHERE ' +
    '  r.xid = %d AND r.dbid = %d';

  xmlHeader = '<?xml version="1.0" encoding="Windows-1251"?>';
  xmlDatasetHeader = '<?xml version="1.0" standalone="yes"?>  <DATAPACKET Version="2.0">';
  xmlDatasetFooter = '</DATAPACKET>';

  NotSavedField = ';LB;RB;CREATORKEY;EDITORKEY;';
  NotSavedFieldRepl = ';LB;RB;';

  INDENT_STR = '  ';
  NEW_LINE = #13#10;

var
  RplDatabaseExists: Boolean;
  IsReadUserFromStream: Boolean;
  SilentMode: Boolean;
  AbortProcess: Boolean;
  StreamLoggingType: TgsStreamLoggingType;

function IIF(Condition: Boolean; Str1, Str2: String): String;
begin
  if Condition then
    Result := Str1
  else
    Result := Str2;
end;

procedure StreamWriteString(St: TStream; const S: String);
var
  L: Integer;
begin
  L := Length(S);
  St.Write(L, SizeOf(L));
  if L > 0 then
    St.Write(S[1], L);
end;

procedure StreamWriteXMLString(St: TStream; const S: String);
var
  L: Integer;
begin
  L := Length(S);
  if L > 0 then
    St.Write(S[1], L);
end;

function GetStreamType(Stream: TStream): TgsStreamType;
var
  I, Position: Integer;
  LeadingChar: Char;
begin
  Result := sttUnknown;
  if Stream.Size > 0 then
  begin
    Position := Stream.Position;
    try
      Stream.Position := 0;
      Stream.ReadBuffer(I, SizeOf(I));
      if I > 1024 then
      begin
        Stream.Position := 0;
        Stream.ReadBuffer(LeadingChar, SizeOf(LeadingChar));
        if LeadingChar = '<' then
          Result := sttXML
        else
          Result := sttBinaryNew;
      end
      else
        Result := sttBinaryOld;
    finally
      Stream.Position := Position;
    end;
  end;
end;

{ TgdcStreamDataObject }

constructor TgdcStreamDataObject.Create(ADatabase: TIBDatabase = nil;
  ATransaction: TIBTransaction = nil; const ASize: Integer = 32);
var
  IBSQL: TIBSQL;
begin
  if Assigned(ADatabase) then
    FDatabase := ADatabase
  else
    FDatabase := gdcBaseManager.Database;
  if Assigned(ATransaction) then
    FTransaction := ATransaction
  else
    FTransaction := gdcBaseManager.ReadTransaction;

  FIsSave := True;
  FIsIncrementedStream := False;

  FCount := 0;
  FSize := ASize;
  SetLength(FObjectArray, ASize);
  SetLength(FObjectForeignKeyFields, ASize);
  SetLength(FObjectForeignKeyClasses, ASize);
  SetLength(FOneToOneTables, ASize);
  SetLength(FObjectCrossTables, ASize);
  SetLength(FObjectDetailReferences, ASize);
  SetLength(FClientDSArray, ASize);

  SetLength(FReceivedRecords, ASize);
  FReceivedRecordsSize := ASize;
  FReceivedRecordsCount := 0;
  SetLength(FReferencedRecords, ASize);
  FReferencedRecordsSize := ASize;
  FReferencedRecordsCount := 0;

  FObjectList := TStringList.Create;
  FObjectList.Sorted := True;

  FIncrDatabaseList := TStringList.Create;

  FStreamDBID := -1;
  FTargetBaseKey := -1;
  FSourceBaseKey := -1;
  FOurBaseKey := -1;

  FStorageItemList := TStringList.Create;

  if Assigned(atDatabase) and Assigned(atDatabase.Relations.ByRelationName('RPL_DATABASE')) then
  begin
    RplDatabaseExists := True;
    IBSQL := TIBSQL.Create(nil);
    try
      IBSQL.Database := gdcBaseManager.Database;
      IBSQL.Transaction := gdcBaseManager.ReadTransaction;
      IBSQL.SQL.Text := sqlSelectOurBaseID;
      IBSQL.ExecQuery;
      if not IBSQL.Eof then
        FOurBaseKey := IBSQL.FieldByName('ID').AsInteger;
    finally
      IBSQL.Free;
    end;
  end
  else
    RplDatabaseExists := False;
end;

destructor TgdcStreamDataObject.Destroy;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
  begin
    FObjectArray[I].Free;
    FClientDSArray[I].Free;
    if FIsSave then
    begin
      FObjectForeignKeyFields[I].Free;
      FObjectForeignKeyClasses[I].Free;
      FOneToOneTables[I].Free;
      FObjectCrossTables[I].Free;
      FObjectDetailReferences[I].Free;
    end;
  end;
  
  SetLength(FObjectArray, 0);
  SetLength(FObjectForeignKeyFields, 0);
  SetLength(FObjectForeignKeyClasses, 0);
  SetLength(FOneToOneTables, 0);
  SetLength(FObjectCrossTables, 0);
  SetLength(FObjectDetailReferences, 0);
  SetLength(FClientDSArray, 0);

  SetLength(FReceivedRecords, 0);
  SetLength(FReferencedRecords, 0);

  FIncrDatabaseList.Free;
  for I := 0 to FObjectList.Count - 1 do
    if Assigned(FObjectList.Objects[I]) then
      FObjectList.Objects[I].Free;
  FObjectList.Free;

  FStorageItemList.Free;

  FDatabase := nil;
  FTransaction := nil;

  inherited;
end;

function TgdcStreamDataObject.Add(const AClassName: TgdcClassName;
  const ASubType: TgdcSubType; const ASetTableName: ShortString = ''; const IsSettingObject: Boolean = false): Integer;
var
  BaseState: TgdcStates;
  gdcSetObject: TgdcBase;
  I: Integer;
  Obj: TgdcBase;
  CDS: TClientDataSet;
  FD: TFieldDef;
begin
  if FCount = FSize then
  begin
    FSize := (FSize + 1) * 2;
    SetLength(FObjectArray, FSize);
    SetLength(FClientDSArray, FSize);
    if FIsSave then
    begin
      SetLength(FObjectForeignKeyFields, FSize);
      SetLength(FObjectForeignKeyClasses, FSize);
      SetLength(FOneToOneTables, FSize);
      SetLength(FObjectCrossTables, FSize);
      SetLength(FObjectDetailReferences, FSize);
    end;  
  end;

  // создаем объект
  Obj := CgdcBase(GetClass(AClassName)).CreateWithParams(nil, FDatabase, FTransaction, ASubType, 'ByID');
  Obj.ReadTransaction := FTransaction;
  if not FIsSave then
  begin
    BaseState := Obj.BaseState;
    Include(BaseState, sLoadFromStream);
    Obj.BaseState := BaseState;
    //Obj.SetRefreshSQLOn(False);
  end;
  Obj.SetTable := ASetTableName;
  if ASetTableName = '' then
    FObjectList.Add(AClassName + '(' + ASubType + ')' + ASetTableName + '=' + IntToStr(FCount))
  else
  begin
    gdcSetObject := CgdcBase(GetClass(AClassName)).CreateWithParams(nil, FDatabase, FTransaction, ASubType, 'All');
    FObjectList.AddObject(AClassName + '(' + ASubType + ')' + ASetTableName + '=' + IntToStr(FCount), gdcSetObject);
  end;

  // создаем соответствующий клиент-датасет
  CDS := TClientDataSet.Create(nil);
  // при сохранении в поток будем создавать поля датасета, при загрузке они создадутся сами
  if IsSave or IsSettingObject then
  begin
    if not Obj.Active then
      Obj.Open;
    for I := 0 to Obj.FieldDefs.Count - 1 do
    begin
      FD := Obj.FieldDefs[I];
      if (not (DB.faReadOnly in FD.Attributes))
        and (not FD.InternalCalcField)
        and (FD.Name <> 'AFULL')
        and (FD.Name <> 'ACHAG')
        and (FD.Name <> 'AVIEW') then
      begin
        CDS.FieldDefs.Add(FD.Name, FD.DataType, FD.Size, False);
      end;
    end;
  end;
  CDS.FieldDefs.Add('_XID', ftInteger, 0, True);
  CDS.FieldDefs.Add('_DBID', ftInteger, 0, True);
  CDS.FieldDefs.Add('_MODIFIED', ftDateTime, 0, True);
  CDS.FieldDefs.Add('_MODIFYFROMSTREAM', ftBoolean, 0, False);
  CDS.FieldDefs.Add('_SETTABLE', ftString, 60, False);
  CDS.CreateDataSet;
  CDS.LogChanges := False;

  FObjectArray[FCount] := Obj;
  FClientDSArray[FCount] := CDS;

  // создаем списки таблиц и ссылок в которых будем искать объекты дочерние данному (только при сохранении)
  if FIsSave then
    Self.FillReferences(FCount);

  Result := FCount;
  Inc(FCount);
end;

procedure TgdcStreamDataObject.FillReferences(const Index: Integer);
var
  I, J: Integer;
  Obj: TgdcBase;
  LT: TStrings;
  TempFieldsList, TempClassesList, TempOneToOneTablesList: TStrings;
  TableList: TStrings;
  OL: TObjectList;
  ListTable: String;
  R: TatRelation;
  F: TField;
  C: TgdcFullClass;
begin
  Obj := FObjectArray[Index];
  ListTable := Obj.GetListTable(Obj.SubType);

  TableList := TStringList.Create;
  TempFieldsList := TStringList.Create;
  TempClassesList := TStringList.Create;
  TempOneToOneTablesList := TStringList.Create;
  try
    if ListTable <> '' then
      TableList.Add(AnsiUpperCase(ListTable));

    // Сохраним все объекты на которые есть ссылки из
    //  главной таблицы текущего объекта, из таблиц участвующих в запросе
    //  и связанных с главной один к одному
    LT := TStringList.Create;
    try
      (LT as TStringList).Duplicates := dupIgnore;
      // Вытащим все таблицы, входящие в запрос
      GetTablesName(Obj.SelectSQL.Text, LT);
      // Оставим только таблицы, имеющие связь один к одному к главной таблице и репрезентирующие текущий объект
      for I := 0 to LT.Count - 1 do
      begin
        if (TableList.IndexOf(LT[I]) = -1)
           and Obj.ClassType.InheritsFrom(GetBaseClassForRelation(LT[I]).gdClass) then
          TableList.Add(LT[I]);
      end;

      // Пробежимся по найденным таблицам, и выберем поля-ссылки
      for J := 0 to TableList.Count - 1 do
      begin
        R := atDatabase.Relations.ByRelationName(TableList.Strings[J]);
        Assert(R <> nil);

        for I := 0 to R.RelationFields.Count - 1 do
        begin
          if not Assigned(R.RelationFields[I].ForeignKey) then
            Continue;

          if (not IsReadUserFromStream and (AnsiPos(';' + Trim(R.RelationFields[I].FieldName) + ';', NotSavedField) > 0)) or
             (IsReadUserFromStream and (AnsiPos(';' + Trim(R.RelationFields[I].FieldName) + ';', NotSavedFieldRepl) > 0)) then
            Continue;

          F := Obj.FindField(R.RelationName, R.RelationFields[I].FieldName);
          if (not Assigned(F)) or (F.DataType <> ftInteger) then
            Continue;

          TempFieldsList.Add(R.RelationName + '=' + R.RelationFields[I].FieldName);
          if R.RelationFields[I].References <> nil then
          begin
            C := GetBaseClassForRelation(R.RelationFields[I].References.RelationName);
            if Assigned(C.gdClass) then
              TempClassesList.Add(C.gdClass.Classname + '=' + C.SubType)
            else
              TempClassesList.Add(R.RelationFields[I].References.RelationName + '=NULL');
          end;
        end;
      end;

      // Теперь найдем все таблицы, первичный ключ которых одновременно
      //  является ссылкой на нашу запись, т.е. таблицы связанные
      //  жесткой связью один-к-одному с нашей таблицей
      //  записи в таких таблицах, в совокупности с записью в главной
      //  таблице, представляют данные одного объекта
      //  пример: gd_contact -- gd_company -- gd_companycode
      LT.Clear;
      OL := TObjectList.Create(False);
      try
        LT.Text := TableList.Text;
        for J := 0 to LT.Count - 1 do
        begin
          atDatabase.ForeignKeys.ConstraintsByReferencedRelation(LT[J], OL);
          for I := 0 to OL.Count - 1 do
            with OL[I] as TatForeignKey do
            begin
              if IsSimpleKey and (Relation.PrimaryKey <> nil)
                and (Relation.PrimaryKey.ConstraintFields.Count = 1)
                and (ConstraintField = Relation.PrimaryKey.ConstraintFields[0])
                {!!!! Для gd_document будем искать только таблицы 1:1 с первичным ключом ID для скорости}
                and (((AnsiCompareText(ListTable, 'GD_DOCUMENT') = 0)
                       and (AnsiCompareText(Relation.PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0))
                     or (AnsiCompareText(ListTable, 'GD_DOCUMENT') <> 0)) then
              begin
                TempOneToOneTablesList.Add(Relation.RelationName);
              end;
            end;
        end;
      finally
        OL.Free;
      end;

      // кросс-таблицы
      LT.Clear;
      FObjectCrossTables[Index] := TStringList.Create;
      atDataBase.GetCrossByRelationName(TableList, LT);
      for I := 0 to LT.Count - 1 do
      begin
        if StrIPos('GD_LASTNUMBER', LT.Names[I]) = 1 then
          continue;
        if StrIPos('FLT_LASTFILTER', LT.Names[I]) = 1 then
          continue;
        FObjectCrossTables[Index].Add(LT.Strings[I]);
      end;
    finally
      LT.Free;
    end;

    // поля-ссылки из детальных объектов
    OL := TObjectList.Create(False);
    try
      FObjectDetailReferences[Index] := TObjectList.Create(False);
      for I := 0 to TableList.Count - 1 do
        atDatabase.ForeignKeys.ConstraintsByReferencedRelation(TableList[I], OL, False);
      for I := 0 to OL.Count - 1 do
      begin
        if TatForeignKey(OL.Items[I]).IsSimpleKey and
          (TatForeignKey(OL.Items[I]).ConstraintField.Field.FieldName = 'DMASTERKEY') then
        begin
          if (TatForeignKey(OL[I]).Relation.RelationName = 'AC_ENTRY') or
             (TatForeignKey(OL[I]).Relation.RelationName = 'AC_RECORD') then
            continue;
          if not Assigned(TatForeignKey(OL.Items[I]).Relation.PrimaryKey) then
            raise EgdcIBError.Create('Ошибка при обработке связи мастер-дитейл: ' +
              ' у таблицы ' + TatForeignKey(OL.Items[I]).Relation.LName + ' отсутствует первичный ключ! ')
          else
            FObjectDetailReferences[Index].Add(OL.Items[I]);
        end;
      end;
    finally
      OL.Free;
    end;

  finally
    TableList.Free;
    FObjectForeignKeyFields[Index] := TempFieldsList;
    FObjectForeignKeyClasses[Index] := TempClassesList;
    FOneToOneTables[Index] := TempOneToOneTablesList;
  end;
end;

procedure TgdcStreamDataObject.AddData(const Index: Integer; AObj: TgdcBase);
var
  I: Integer;
  RUID: TRUID;
  F: TField;
  CDS: TClientDataSet;
  LocName: String;
  R: TatRelation;
begin
  if CheckIndex(Index) then
  begin
    CDS := FClientDSArray[Index];

    if Assigned(frmStreamSaver) then
      with AObj do
        frmStreamSaver.SetProcessText(GetDisplayName(SubType) + #13#10 + '  ' +
          FieldByName(GetListField(SubType)).AsString + #13#10 + '  ' +
          '(' + FieldByName(GetKeyField(SubType)).AsString + ')');

    if StreamLoggingType = slAll then
      if AObj.SetTable = '' then
      begin
        with AObj do
          AddText('Сохранение: ' + GetDisplayName(SubType) + ' ' +
            FieldByName(GetListField(SubType)).AsString + #13#10 +
            ' (' + FieldByName(GetKeyField(SubType)).AsString + ')'#13#10, clBlue);
        Space;
      end
      else
      begin
        R := atDataBase.Relations.ByRelationName(AObj.SetTable);
        if Assigned(R) then
          LocName := R.LName
        else
          LocName := AObj.SetTable;

        with AObj do
          AddText('Сохранение: ' + GetDisplayName(SubType) + ' ' +
            FieldByName(GetListField(SubType)).AsString + #13#10 +
            ' (' + FieldByName(GetKeyField(SubType)).AsString + ') с данными множества ' + LocName + #13#10, clBlue);
        Space;
      end;

    RUID := AObj.GetRUID;
    Assert(RUID.XID > -1, 'TgdcStreamDataObject.AddData: RUID.XID = -1');

    CDS.Append;
    for I := 0 to AObj.FieldCount - 1 do
    begin
      F := CDS.FindField(AObj.Fields[I].FieldName);
      if F <> nil then
      begin
        if (not IsReadUserFromStream and (AnsiPos(';' + F.FieldName + ';', NotSavedField) > 0)) or
           (IsReadUserFromStream and (AnsiPos(';' + F.FieldName + ';', NotSavedFieldRepl) > 0))
        then
          F.Clear
        else
          F.Assign(AObj.Fields[I]);
      end;
    end;

    CDS.FieldByName('_XID').AsInteger := RUID.XID;
    CDS.FieldByName('_DBID').AsInteger := RUID.DBID;
    CDS.FieldByName('_MODIFIED').AsDateTime := AObj.EditionDate;
    CDS.FieldByName('_MODIFYFROMSTREAM').AsBoolean := AObj.ModifyFromStream;
    CDS.FieldByName('_SETTABLE').AsString := AObj.SetTable;
    CDS.Post;
  end;
end;

procedure TgdcStreamDataObject.AddData(const Index: Integer; const AID: TID);
var
  Obj: TgdcBase;
  C: TgdcFullClass;
  ObjectIndex: Integer;
begin
  if CheckIndex(Index) then
  begin
    Obj := FObjectArray[Index];

    if Obj.ID <> AID then
      Obj.ID := AID;
    if not Obj.Active then
      Obj.Open;
    if Obj.RecordCount = 0 then  {!!!!!!!!!!!!!!!!!!}
      Exit;

    C := Obj.GetCurrRecordClass;
    if (Obj.ClassType <> C.gdClass) or (Obj.SubType <> C.SubType) then
    begin
      ObjectIndex := Self.GetObjectIndex(C.gdClass.Classname, C.SubType);
      Self.AddData(ObjectIndex, AID);
    end
    else
      Self.AddData(Index, Obj);
  end;
end;

function TgdcStreamDataObject.Find(const AClassName: TgdcClassName;
  const ASubType: TgdcSubType; const ASetTableName: ShortString = ''): Integer;
var
  strName: String;
begin
  Result := -1;
  strName := AClassName + '(' + ASubType + ')' + ASetTableName;
  if FObjectList.IndexOfName(strName) > -1 then
  begin
    Result := StrToInt(FObjectList.Values[strName]);
  end;
end;

function TgdcStreamDataObject.GetObjectIndex(const AClassName: TgdcClassName;
  const ASubType: TgdcSubType; const ASetTableName: ShortString = ''): Integer;
begin
  Result := Self.Find(AClassName, ASubType, ASetTableName);
  if Result = -1 then
    Result := Self.Add(AClassName, ASubType, ASetTableName);
end;

function TgdcStreamDataObject.GetClientDS(Index: Integer): TClientDataSet;
begin
  Result := nil;
  if CheckIndex(Index) then
  begin
    Result := FClientDSArray[Index];
  end;
end;

function TgdcStreamDataObject.GetgdcObject(Index: Integer): TgdcBase;
begin
  Result := nil;
  if CheckIndex(Index) then
  begin
    // будем возвращать только активные бизнес-объекты, с сабсетом ByID
    try
      if FObjectArray[Index].SubSet <> 'ByID' then
        FObjectArray[Index].SubSet := 'ByID';
      if not FObjectArray[Index].Active then
        FObjectArray[Index].Open;
    except
    end;
    Result := FObjectArray[Index];
  end;
end;

function TgdcStreamDataObject.GetObjectDetailReferences(
  Index: Integer): TObjectList;
begin
  Result := nil;
  if CheckIndex(Index) then
    Result := FObjectDetailReferences[Index];
end;

function TgdcStreamDataObject.GetObjectCrossTables(
  Index: Integer): TStringList;
begin
  Result := nil;
  if CheckIndex(Index) then
    Result := FObjectCrossTables[Index];
end;

function TgdcStreamDataObject.GetObjectForeignKeyFields(Index: Integer): TStrings;
begin
  Result := nil;
  if CheckIndex(Index) then
    Result := FObjectForeignKeyFields[Index];
end;

function TgdcStreamDataObject.GetObjectForeignKeyClasses(Index: Integer): TStrings;
begin
  Result := nil;
  if CheckIndex(Index) then
    Result := FObjectForeignKeyClasses[Index];
end;

function TgdcStreamDataObject.GetOneToOneTables(Index: Integer): TStrings;
begin
  Result := nil;
  if CheckIndex(Index) then
    Result := FOneToOneTables[Index];
end;

procedure TgdcStreamDataObject.AddReceivedRecord(const AXID, ADBID: TID);
begin
  if FReceivedRecordsCount = FReceivedRecordsSize then
  begin
    FReceivedRecordsSize := (FReceivedRecordsSize + 1) * 2;
    SetLength(FReceivedRecords, FReceivedRecordsSize);
  end;
  FReceivedRecords[FReceivedRecordsCount].XID := AXID;
  FReceivedRecords[FReceivedRecordsCount].DBID := ADBID;
  Inc(FReceivedRecordsCount);
end;

function TgdcStreamDataObject.GetReceivedRecord(Index: Integer): TRuid;
begin
  if (Index < 0) or (Index > (FReceivedRecordsCount - 1)) then
    raise EgsInvalidIndex.Create(GetGsException(Self, 'GetReceivedRecord: Invalid index (' + IntToStr(Index) + ')'));
  Result := FReceivedRecords[Index];
end;

procedure TgdcStreamDataObject.AddReferencedRecord(const AID, AXID,
  ADBID: TID);
begin
  if FReferencedRecordsCount = FReferencedRecordsSize then
  begin
    FReferencedRecordsSize := (FReferencedRecordsSize + 1) * 2;
    SetLength(FReferencedRecords, FReferencedRecordsSize);
  end;
  FReferencedRecords[FReferencedRecordsCount].SourceID := AID;
  FReferencedRecords[FReferencedRecordsCount].RUID.XID := AXID;
  FReferencedRecords[FReferencedRecordsCount].RUID.DBID := ADBID;
  Inc(FReferencedRecordsCount);
end;

function TgdcStreamDataObject.GetReferencedRecord(Index: Integer): TStreamReferencedRecord;
begin
  if (Index < 0) or (Index > (FReferencedRecordsCount - 1)) then
    raise EgsInvalidIndex.Create(GetGsException(Self, 'GetReferencedRecord: Invalid index (' + IntToStr(Index) + ')'));
  Result := FReferencedRecords[Index];
end;

function TgdcStreamDataObject.FindReferencedRecord(const AID: TID): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FReferencedRecordsCount - 1 do
    if FReferencedRecords[I].SourceID = AID then
    begin
      Result := I;
      Exit;
    end;
end;

procedure TgdcStreamDataObject.SetTransaction(const Value: TIBTransaction);
begin
  if Assigned(Value) then
    FTransaction := Value;
end;

function TgdcStreamDataObject.GetSetObject(const AClassName: TgdcClassName;
  const ASubType: TgdcSubType; const ASetTableName: ShortString): TgdcBase;
var
  Index: Integer;
begin
  Result := nil;
  Index := FObjectList.IndexOfName(AClassName + '(' + ASubType + ')' + ASetTableName);
  if Index > -1 then
  begin
    Result := TgdcBase(FObjectList.Objects[Index]);
  end;
end;

procedure TgdcStreamDataObject.CheckGDCObjectsActive;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
  begin
    if not FObjectArray[I].Active then
      FObjectArray[I].Open;
  end;
end;

procedure TgdcStreamDataObject.SetTargetBaseKey(const Value: TID);
begin
  FTargetBaseKey := Value;
  if Value > -1 then
    FIsIncrementedStream := True;
end;

function TgdcStreamDataObject.CheckIndex(const Index: Integer): Boolean;
begin
  if (FCount > 0) and ((Index < 0) or (Index > (FCount - 1))) then
    raise EgsInvalidIndex.Create(GetGsException(Self, 'Invalid index (' + IntToStr(Index) + ')'))
  else
    Result := True;
end;

{ TgdcStreamDataProvider }

constructor TgdcStreamDataProvider.Create(ADatabase: TIBDatabase = nil;
  ATransaction: TIBTransaction = nil);
begin
  if Assigned(ADatabase) then
    FDatabase := ADatabase
  else
    FDatabase := gdcBaseManager.Database;
  if Assigned(ATransaction) then
    FTransaction := ATransaction;

  FIBSQL := TIBSQL.Create(nil);
  FIBSQL.Database := FDatabase;
  FIBSQL.Transaction := FTransaction;

  FNowSavedRecords := TStreamOrderList.Create;
  FReplaceFieldList := TStringList.Create;

  FAnAnswer := 0;

  FIDMapping := TgdKeyIntAssoc.Create;
  FUpdateList := TObjectList.Create(True);
end;

destructor TgdcStreamDataProvider.Destroy;
begin
  if Assigned(FNowSavedRecords) then
    FreeAndNil(FNowSavedRecords);
  if Assigned(FDataObject) then
    FDataObject := nil;
  if Assigned(FLoadingOrderList) then
    FLoadingOrderList := nil;
  if Assigned(FDatabase) then
    FTransaction := nil;
  if Assigned(FDatabase) then
    FDatabase := nil;
  if Assigned(FIBSQL) then
    FreeAndNil(FIBSQL);
  if Assigned(FReplaceFieldList) then
    FreeAndNil(FReplaceFieldList);
  if Assigned(FIDMapping) then
    FreeAndNil(FIDMapping);
  if Assigned(FUpdateList) then
    FreeAndNil(FUpdateList);

  if Assigned(FIbsqlRPLRecordSelect) then
    FreeAndNil(FIbsqlRPLRecordSelect);
  if Assigned(FIbsqlRPLRecordInsert) then
    FreeAndNil(FIbsqlRPLRecordInsert);
  if Assigned(FIbsqlRPLRecordDelete) then
    FreeAndNil(FIbsqlRPLRecordDelete);
    
  inherited;
end;

procedure TgdcStreamDataProvider.SaveRecord(const ObjectIndex: Integer;
  const AID: TID; const AWithDetail: Boolean = true);
begin
  Self.SaveRecord(FDataObject.gdcObject[ObjectIndex], ObjectIndex, AID, AWithDetail);
end;

procedure TgdcStreamDataProvider.SaveRecord(const AObject: TgdcBase; const ObjectIndex: Integer;
  const AID: TID; const AWithDetail: Boolean);
var
  XID, DBID: TID;
  C: TgdcFullClass;
  Index: Integer;
  IndexNeedModifyList: Integer;
begin
  // При нажатии Escape прервем процесс
  if not SilentMode and Application.Active and (AbortProcess or ((GetAsyncKeyState(VK_ESCAPE) shr 1) <> 0)) then
  begin
    if (not AbortProcess) and
       (Application.MessageBox('Остановить сохранение данных?', 'Внимание', MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL) = IDYES) then
    begin
      AbortProcess := True;
    end;  
    Exit;
  end;

  // Если объект или инкреметная ссылка на него уже сохранены в потоке
  if (FDataObject.FindReferencedRecord(AID) > -1) or (FLoadingOrderList.Find(AID, ObjectIndex) > -1) then
    Exit;

  // При инкрементном сохранениии не будем сохранять Стандартные записи (ID < 147000000)
  //  предполагаем что они есть на всех базах
  if (FDataObject.TargetBaseKey > -1) and (AID < cstUserIDStart) then
  begin
    gdcBaseManager.GetRUIDByID(AID, XID, DBID);
    FDataObject.AddReferencedRecord(AID, XID, DBID);
    Exit;
  end;

  if AObject.ID <> AID then
    AObject.ID := AID;
  // Если работает репликатор, то не будем прерывать сохранение настройки
  if AObject.RecordCount = 0 then
  begin
    AddMistake(#13#10 + AObject.ClassName + ': Не найдена запись с ID = ' + IntToStr(AID) + #13#10, clRed);
    if not SilentMode then
      raise EgdcIDNotFound.Create(AObject.ClassName + ': Не найдена запись с ID = ' + IntToStr(AID))
    else
      Exit;
  end;

  // Если текущая запись репрезентует объект другого
  //  класса, то сохраним запись от его лица
  C := AObject.GetCurrRecordClass;
  if (AObject.ClassType <> C.gdClass) or (AObject.SubType <> C.SubType) then
  begin
    Index := FDataObject.GetObjectIndex(C.gdClass.Classname, C.SubType);
    Self.SaveRecord(Index, AID, AWithDetail);
  end
  else
  begin

    // По умолчанию устанавливаем флаг Перезаписывать из потока в True
    if Assigned(FNeedModifyList) then
    begin
      // Если нам передан список с значениями флогов, то ищем по нему
      IndexNeedModifyList := FNeedModifyList.IndexOf(AID);
      if IndexNeedModifyList > -1 then
        AObject.ModifyFromStream := (FNeedModifyList.ValuesByIndex[IndexNeedModifyList] = 1)
      else
      begin
        // Если в списке не оказалось нужной позиции, значит она входит в настройку неявно
        //  если работает репликатор, то установим флаг в False 
        if SilentMode then
          AObject.ModifyFromStream := False
        else
          AObject.ModifyFromStream := True;
      end;
    end
    else
      AObject.ModifyFromStream := True;

    // При работе репликатора не будем сохранять метаданные, и типы документов.
    //   Соответствие ключей будем сохранять в отдельный список.
    if SilentMode and (AObject.InheritsFrom(TgdcMetaBase) or AObject.InheritsFrom(TgdcBaseDocumentType)) then
    begin
      gdcBaseManager.GetRUIDByID(AID, XID, DBID);
      FDataObject.AddReferencedRecord(AID, XID, DBID);
      Exit;
    end;

    // Выполнить особые для некоторых объектов действия перед сохранением в поток.
    // Если вернёт false, значит объект не нужно сохранять в поток
    // (например: cистемные домены не сохраняем)
    if DoBeforeSaving(AObject) then
    begin

      // Если поток инкрементынй, то проверим по таблице RPL_RECORD необходимость сохранения записи
      if CheckNeedSaveRecord(AID, AObject.EditionDate) then
      begin
        if FNowSavedRecords.Find(AID, ObjectIndex) = -1 then
        begin
          FNowSavedRecords.AddItem(AID, ObjectIndex);
          SaveBindedObjects(ObjectIndex, AID);
        end;

        SaveSpecial(ObjectIndex, AID);

        // Снова проверим необходимость сохранения объекта, возможно он уже сохранился в функциях выше
        if (FDataObject.FindReferencedRecord(AID) = -1) and (FLoadingOrderList.Find(AID, ObjectIndex) = -1) then
        begin
          // сохранить порядок загрузки объекта
          FLoadingOrderList.AddItem(AID, ObjectIndex);
          // сохранить данные объекта
          FDataObject.AddData(ObjectIndex, AID);

          if FDataObject.TargetBaseKey > -1 then
          begin
            IbsqlRPLRecordInsert.Close;
            IbsqlRPLRecordInsert.ParamByName('ID').AsInteger := AID;
            IbsqlRPLRecordInsert.ParamByName('STATE').AsInteger := Integer(irsOut);
            IbsqlRPLRecordInsert.ParamByName('EDITIONDATE').AsDateTime := AObject.EditionDate;
            IbsqlRPLRecordInsert.ExecQuery;
          end;
        end;

        SaveOneToOne(ObjectIndex, AID);
        SaveSet(AObject);

      end
      else
      begin
        FDataObject.AddReferencedRecord(AID, XID, DBID);
      end;

      // Выполнить особые для некоторых объектов действия после сохранения в поток.
      DoAfterSaving(AObject);

      if AWithDetail or (Assigned(FSaveWithDetailList) and (FSaveWithDetailList.IndexOf(AID) > -1)) then
        SaveDetail(ObjectIndex, AID);

    end;

  end;
end;

procedure TgdcStreamDataProvider.SaveBindedObjects(const AObjectIndex: Integer;
  const AID: TID);
var
  K: Integer;
  ForeignKeyList, ForeignClassesList: TStrings;
  ObjectIndex: Integer;
  Obj: TgdcBase;
  C: TgdcFullClass;
  F: TField;
  RelationName, FieldName: String;
  BindedClassName: TgdcClassName;
  BindedSubType: TgdcSubType;
begin

  Obj := FDataObject.gdcObject[AObjectIndex];
  if Obj.ID <> AID then
    Obj.ID := AID;
    
  ForeignKeyList := FDataObject.ObjectForeignKeyFields[AObjectIndex];
  ForeignClassesList := FDataObject.ObjectForeignKeyClasses[AObjectIndex];

  // запишем в поток объекты на которые ссылаются поля-ссылки
  for K := 0 to ForeignKeyList.Count - 1 do
  begin

    RelationName := ForeignKeyList.Names[K];
    FieldName := Copy(ForeignKeyList[K], Length(RelationName) + 2, MaxInt);
    F := Obj.FindField(RelationName, FieldName);

    if F.IsNull or (FLoadingOrderList.Find(F.AsInteger) > -1) then
      Continue;

    BindedClassName := ForeignClassesList.Names[K];
    BindedSubType := Copy(ForeignClassesList[K], Length(BindedClassName) + 2, MaxInt);

    if BindedSubType = 'NULL' then
    begin
      C := GetBaseClassForRelationByID(BindedClassName,
        Obj.FieldByName(RelationName, FieldName).AsInteger, FTransaction);
      BindedClassName := '';
      if Assigned(C.gdClass) then
      begin
        BindedClassName := C.gdClass.ClassName;
        BindedSubType := C.SubType;
      end;
    end;

    if BindedClassName <> '' then
    begin

      ObjectIndex := FDataObject.GetObjectIndex(BindedClassname, BindedSubType);

      // смысл условия: не допустить зацикливания, когда в записи есть поле-ссылка на эту же запись
      if not (Obj.ClassType.InheritsFrom(FDataObject.gdcObject[ObjectIndex].ClassType) and (F.AsInteger = AID)) then
      begin
        try
          Self.SaveRecord(ObjectIndex, F.AsInteger, False);
          if Obj.ID <> AID then
            Obj.ID := AID;
        except
          on E: EgdcIDNotFound do
          begin
            if Assigned(frmStreamSaver) then
              frmStreamSaver.AddMistake(
                Format('В процессе сохранения возникла ошибка.'#13#10+
                'В таблице %s в поле %s содержится'#13#10+
                'ссылка на объект типа %s'#13#10+
                'с идентификатором %d, однако,'#13#10+
                'такой объект в базе данных не существует.',
                  [RelationName, FieldName,
                  BindedClassName + BindedSubType,
                  Obj.FieldByName(RelationName, FieldName).AsInteger]));
            AddMistake(
              Format('В процессе сохранения возникла ошибка.'#13#10+
              'В таблице %s в поле %s содержится'#13#10+
              'ссылка на объект типа %s'#13#10+
              'с идентификатором %d, однако,'#13#10+
              'такой объект в базе данных не существует.',
                [RelationName, FieldName,
                BindedClassName + BindedSubType,
                Obj.FieldByName(RelationName, FieldName).AsInteger]), clRed);
          end;
        end;
      end;
    end;
  end;
end;

procedure TgdcStreamDataProvider.SaveOneToOne(const AObjectIndex: Integer;
  const AID: TID);
var
  I: Integer;
  ObjIndex: Integer;
  TableName: String;
  OneToOneTables: TStrings;
  C: TgdcFullClass;
begin
  OneToOneTables := FDataObject.OneToOneTables[AObjectIndex];
  for I := 0 to OneToOneTables.Count - 1 do
  begin
    TableName := OneToOneTables[I];
    C := GetBaseClassForRelationByID(TableName, AID, FTransaction);
    //C := GetClassForObjectByID(FDatabase, FTransaction)
    if Assigned(C.gdClass) then
    begin
      ObjIndex := FDataObject.GetObjectIndex(C.gdClass.Classname, C.SubType);
      Self.SaveRecord(ObjIndex, AID, False);
    end;
  end;
end;

procedure TgdcStreamDataProvider.SaveDetail(const AObjectIndex: Integer; const AID: TID);
var
  ObjectIndex: Integer;
  I, J: Integer;
  C: TgdcFullClass;
  ObjDetailReferences: TObjectList;
  KeyArray: TgdKeyArray;
begin
  ObjDetailReferences := FDataObject.ObjectDetailReferences[AObjectIndex];

  for I := 0 to ObjDetailReferences.Count - 1 do
  begin
    FIBSQL.Close;
    //Мы не проверяем наши таблицы на простой первичный ключ, т.к. в список могли попасть только такие таблицы
    FIBSQL.SQL.Text := Format('SELECT DISTINCT %s FROM %s WHERE %s = %s ',
      [TatForeignKey(ObjDetailReferences[I]).Relation.PrimaryKey.ConstraintFields[0].FieldName,
      TatForeignKey(ObjDetailReferences[I]).Relation.RelationName,
      TatForeignKey(ObjDetailReferences[I]).ConstraintField.FieldName, IntToStr(AID)]);
    FIBSQL.ExecQuery;
    if FIBSQL.RecordCount > 0 then
    begin
      KeyArray := TgdKeyArray.Create;
      try
        while not FIBSQL.Eof do
        begin
          if KeyArray.IndexOf(FIBSQL.Fields[0].AsInteger) = -1 then
            KeyArray.Add(FIBSQL.Fields[0].AsInteger);
          FIBSQL.Next;
        end;
        //Находим базовый класс по первому id, т.к. детальные объекты в одной таблице будут одного класса и сабтайпа
        C := GetBaseClassForRelationByID(TatForeignKey(ObjDetailReferences[I]).Relation.RelationName,
          KeyArray.Keys[0], FTransaction);
        if C.gdClass <> nil then
        begin
          ObjectIndex := FDataObject.GetObjectIndex(C.gdClass.Classname, C.SubType);
          for J := 0 to KeyArray.Count - 1 do
            Self.SaveRecord(ObjectIndex, KeyArray.Keys[J]);
        end;
      finally
        KeyArray.Free;
      end;
    end;
  end;
end;

procedure TgdcStreamDataProvider.SaveSpecial(const AObjectIndex: Integer; const AID: TID);

  procedure SaveToStreamDependencies(TempObj: TgdcBase; ADependent_Name: String);
  var
    ibsql, ibsqlID: TIBSQL;
    ClassName: String;
    ObjectIndex: Integer;
  begin
    ibsql := TIBSQL.Create(nil);
    ibsqlID := TIBSQL.Create(nil);
    try
      ibsql.Database := FDatabase;
      ibsqlID.Database := FDatabase;
      if not Assigned(FTransaction) then
      begin
        ibsql.Transaction := gdcBaseManager.ReadTransaction;
        ibsqlID.Transaction := gdcBaseManager.ReadTransaction;
      end
      else
      begin
        ibsql.Transaction := FTransaction;
        ibsqlID.Transaction := FTransaction;
      end;
        
      if AnsiCompareText(TempObj.Classname, 'TgdcIndex') = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'SELECT * FROM rdb$index_segments WHERE rdb$index_name = :indexname';
        ibsql.ParamByName('indexname').AsString := TempObj.FieldByName('indexname').AsString;
        ibsql.ExecQuery;
        if not ibsql.EOF then
        begin
          while not ibsql.Eof do
          begin
            ibsqlID.Close;
            ibsqlID.SQL.Text := 'SELECT * FROM at_relation_fields WHERE fieldname = :fieldname ' +
              ' AND relationkey = :relationkey ';
            ibsqlID.ParamByName('relationkey').AsString := TempObj.FieldByName('relationkey').AsString;
            ibsqlID.ParamByName('fieldname').AsString := AnsiUpperCase(ibsql.FieldByName('rdb$field_name').AsString);
            ibsqlID.ExecQuery;
            if ibsqlID.RecordCount > 0 then
            begin
              ObjectIndex := FDataObject.GetObjectIndex('TgdcRelationField', '');
              Self.SaveRecord(ObjectIndex, ibsqlID.Fields[0].AsInteger);
              if TempObj.ID <> AID then
                TempObj.ID := AID;
            end;
            ibsql.Next;
          end;
        end;
      end
      else
      begin
        ibsql.Close;
        ibsql.SQL.Text := Format('SELECT * FROM rdb$dependencies WHERE rdb$dependent_name = ''%s'' ',
          [ADependent_Name]);
        ibsql.ExecQuery;
        while not ibsql.Eof do
        begin
          ibsqlID.Close;
          case ibsql.FieldByName('rdb$depended_on_type').AsInteger of
            1, 0:
            begin
              if ibsql.FieldByName('rdb$field_name').IsNull then
              begin
                ibsqlID.SQL.Text := Format('SELECT %s FROM %s WHERE %s = ''%s''',
                  ['id', 'at_relations', 'relationname',
                   ibsql.FieldByName('rdb$depended_on_name').AsString]);

                ClassName := 'TgdcRelation';
              end else
              begin
                ibsqlID.SQL.Text := Format('SELECT id FROM at_relation_fields '+
                  ' WHERE fieldname = ''%s'' AND relationname = ''%s''',
                  [ibsql.FieldByName('rdb$field_name').AsString,
                   ibsql.FieldByName('rdb$depended_on_name').AsString]);

                ClassName := 'TgdcRelationField';
              end;
            end;
            5:
            begin
              ibsqlID.SQL.Text := Format('SELECT %s FROM %s WHERE %s = ''%s''',
              ['id', 'at_procedures', 'procedurename',
               ibsql.FieldByName('rdb$depended_on_name').AsString]);
              ClassName := 'TgdcStoredProc';
            end;
            7:
            begin
              ibsqlID.SQL.Text := Format('SELECT %s FROM %s WHERE %s = ''%s''',
              ['id', 'at_exceptions', 'exceptionname',
               ibsql.FieldByName('rdb$depended_on_name').AsString]);
              ClassName := 'TgdcException';
            end
            else
            begin
              ibsqlID.SQL.Text := '';
              ClassName := '';
            end;
          end;
          if ibsqlID.SQL.Text > '' then
          begin
            ibsqlID.ExecQuery;
            if (ibsqlID.RecordCount > 0) and (ibsqlID.Fields[0].AsInteger <> AID) then
            begin
              ObjectIndex := FDataObject.GetObjectIndex(Classname, '');
              Self.SaveRecord(ObjectIndex, ibsqlID.Fields[0].AsInteger);
              if TempObj.ID <> AID then
              begin
                TempObj.ID := AID;
              end;
            end;
          end;
          ibsql.Next;
        end;
      end;
    finally
      ibsql.Free;
      ibsqlID.Free;
    end;
  end;

var
  I: Integer;
  fld: TatRelationField;
  FC: TgdcFullClass;
  ObjectIndex: Integer;
  Obj: TgdcBase;
  AnID: TID;
  FunctionKeyArray: TgdKeyArray;
begin
  Obj := FDataObject.gdcObject[AObjectIndex];
  if Obj.ID <> AID then
    Obj.ID := AID;

  if AnsiCompareText(Obj.Classname, 'TgdcInvDocumentLine') = 0 then
  begin
    for I := 0 to Obj.FieldCount - 1 do
    begin
      if (AnsiPos('"INV_CARD".', Obj.Fields[I].Origin) = 1) and (Obj.Fields[I].DataType = ftInteger)
        and not Obj.Fields[I].IsNull then
      begin
        if FLoadingOrderList.Find(Obj.Fields[I].AsInteger) > -1 then
          Continue;
        fld := atDatabase.FindRelationField('INV_CARD',
          System.Copy(Obj.Fields[I].Origin, 13, Length(Obj.Fields[I].Origin) - 13));
        if Assigned(fld) and Assigned(fld.References) and (Obj.Fields[I].AsInteger <> AID) then
        begin
          FC := GetBaseClassForRelationByID(fld.References.RelationName, Obj.Fields[I].AsInteger, FTransaction);
          if Assigned(FC.gdClass) then
          begin
            ObjectIndex := FDataObject.GetObjectIndex(FC.gdClass.Classname, FC.SubType);
            Self.SaveRecord(ObjectIndex, Obj.Fields[I].AsInteger);
            if Obj.ID <> AID then
              Obj.ID := AID;
          end;
        end;
      end;
    end;
    Exit;
  end;

  if AnsiCompareText(Obj.Classname, 'TgdcFunction') = 0 then
  begin
    // сохраним функции от которых зависит данная функция
    FIBSQL.Close;
    FIBSQL.SQL.Text := 'SELECT addfunctionkey FROM rp_additionalfunction WHERE mainfunctionkey = :mfk ';
    FIBSQL.ParamByName('mfk').AsInteger := AID;
    FIBSQL.ExecQuery;
    if FIBSQL.RecordCount > 0 then
    begin
      FunctionKeyArray := TgdKeyArray.Create;
      try
        while not FIBSQL.Eof do
        begin
          AnID := FIBSQL.FieldByName('ADDFUNCTIONKEY').AsInteger;
          if FunctionKeyArray.IndexOf(AnID) = -1 then
            FunctionKeyArray.Add(AnID);
          FIBSQL.Next;
        end;

        for I := 0 to FunctionKeyArray.Count - 1 do
        begin
          ObjectIndex := FDataObject.GetObjectIndex('TgdcFunction', '');
          Self.SaveRecord(ObjectIndex, FunctionKeyArray.Keys[I]);
        end;
      finally
        FunctionKeyArray.Free;
      end;
    end;
    Exit;
  end;

  if AnsiCompareText(Obj.Classname, 'TgdcExplorer') = 0 then
  begin
    // если из сохраняемой записи исследователя вызывается функция
    if Obj.FieldByName('cmdtype').AsInteger = 1 then
    begin
      AnID := gdcBaseManager.GetIDByRUIDString(Obj.FieldByName('cmd').AsString);
      if AnID > 0 then
      begin
        ObjectIndex := FDataObject.GetObjectIndex('TgdcFunction', '');
        Self.SaveRecord(ObjectIndex, AnID);
      end;
    end;
    Exit;
  end;

  if AnsiCompareText(Obj.Classname, 'TgdcMacrosGroup') = 0 then
  begin
    FIBSQL.Close;
    FIBSQL.SQL.Text := 'SELECT FIRST(1) id FROM evt_object WHERE macrosgroupkey = :mgk';
    FIBSQL.ParamByName('mgk').AsInteger := AID;
    FIBSQL.ExecQuery;
    if FIBSQL.RecordCount > 0 then
    begin
      ObjectIndex := FDataObject.GetObjectIndex('TgdcDelphiObject', '');
      Self.SaveRecord(ObjectIndex, FIBSQL.FieldByName('ID').AsInteger);
    end;
    Exit;
  end;

  if AnsiCompareText(Obj.Classname, 'TgdcReportGroup') = 0 then
  begin
    FIBSQL.Close;
    FIBSQL.SQL.Text := 'SELECT FIRST(1) id FROM evt_object WHERE reportgroupkey = :rgk';
    FIBSQL.ParamByName('rgk').AsInteger := AID;
    FIBSQL.ExecQuery;
    if FIBSQL.RecordCount > 0 then
    begin
      ObjectIndex := FDataObject.GetObjectIndex('TgdcDelphiObject', '');
      Self.SaveRecord(ObjectIndex, FIBSQL.FieldByName('ID').AsInteger);
    end;
    Exit;
  end;

  if AnsiCompareText(Obj.Classname, 'TgdcStoredProc') = 0 then
  begin
    if AnsiPos(UserPrefix, AnsiUpperCase(Obj.FieldByName('procedurename').AsString)) = 1 then
      SaveToStreamDependencies(Obj, Obj.FieldByName('procedurename').AsString);
    Exit;
  end;

  if AnsiCompareText(Obj.Classname, 'TgdcField') = 0 then
  begin
    SaveToStreamDependencies(Obj, Obj.FieldByName('fieldname').AsString);
    Exit;
  end;

  if AnsiCompareText(Obj.Classname, 'TgdcIndex') = 0 then
  begin
    SaveToStreamDependencies(Obj, Obj.FieldByName('indexname').AsString);
    Exit;
  end;

  if AnsiCompareText(Obj.Classname, 'TgdcTrigger') = 0 then
  begin
    SaveToStreamDependencies(Obj, Obj.FieldByName('triggername').AsString);
    Exit;
  end;

  if AnsiCompareText(Obj.Classname, 'TgdcGenerator') = 0 then
  begin
    SaveToStreamDependencies(Obj, Obj.FieldByName('generatorname').AsString);
    Exit;
  end;

  if AnsiCompareText(Obj.Classname, 'TgdcCheckConstraint') = 0 then
  begin
    SaveToStreamDependencies(Obj, Obj.FieldByName('checkname').AsString);
    Exit;
  end;
end;

procedure TgdcStreamDataProvider.SaveSet(AObj: TgdcBase);
var
  I, J: Integer;
  ObjectIndex, ObjectSetIndex: Integer;
  CL: TStringList;
  CrossDS: TDataSource;
  C: TgdcFullClass;
  TempObj: TgdcBase;
  SetKeyArray: TgdKeyArray;
begin
  ObjectIndex := FDataObject.GetObjectIndex(AObj.Classname, AObj.SubType, AObj.SetTable);

  CL := FDataObject.ObjectCrossTables[ObjectIndex];
  CrossDS := TDataSource.Create(nil);
  SetKeyArray := TgdKeyArray.Create;
  try
    CrossDS.DataSet := AObj;
    for I := 0 to CL.Count - 1 do
    begin
      SetKeyArray.Clear;
      C := GetBaseClassForRelation(CL.Values[CL.Names[I]]);
      if C.gdClass <> nil then
      begin
        ObjectIndex := FDataObject.GetObjectIndex(C.gdClass.Classname, C.SubType);
        ObjectSetIndex := FDataObject.GetObjectIndex(C.gdClass.Classname, C.SubType, CL.Names[I]);

        TempObj := FDataObject.GetSetObject(C.gdClass.Classname, C.SubType, CL.Names[I]);
        TempObj.Close;
        if TempObj.SetTable <> CL.Names[I] then
          TempObj.SetTable := CL.Names[I];
        TempObj.MasterSource := CrossDS;
        TempObj.Open;
        TempObj.First;
        while not TempObj.Eof do
        begin
          if SetKeyArray.IndexOf(TempObj.ID) = -1 then
            SetKeyArray.Add(TempObj.ID);
          // сохранить множество
          FDataObject.AddData(ObjectSetIndex, TempObj);
          TempObj.Next;
        end;
        TempObj.Close;

        // сохранить данные главной записи в множестве (без детальных объектов)
        for J := 0 to SetKeyArray.Count - 1 do
          Self.SaveRecord(ObjectIndex, SetKeyArray.Keys[J], False);

      end;
    end;
  finally
    SetKeyArray.Free;
    CrossDS.Free;
  end;
end;

procedure TgdcStreamDataProvider.SetLoadingOrderList(
  const Value: TgdcStreamLoadingOrderList);
begin
  if Value <> nil then
    FLoadingOrderList := Value;
end;

procedure TgdcStreamDataProvider.SetDataObject(
  const Value: TgdcStreamDataObject);
begin
  if Value <> nil then
    FDataObject := Value;
end;

procedure TgdcStreamDataProvider.ApplyDelayedUpdates(SourceKeyValue, TargetKeyValue: Integer);
var
  I: Integer;
  Obj: TgdcBase;
begin
  for I := FUpdateList.Count - 1 downto 0 do
  begin
    if (FUpdateList[I] as TgdcReferenceUpdate).RefID = SourceKeyValue then
    begin
      {На обновление полей в б-о могут быть заданы к-л операции => Сделано через б-о, а не через ibsql}
      Obj := FDataObject.gdcObject[(FUpdateList[I] as TgdcReferenceUpdate).ObjectIndex];
      Obj.ID := (FUpdateList[I] as TgdcReferenceUpdate).ID;
      if Obj.RecordCount > 0 then
      begin
        Obj.Edit;
        Obj.FieldByName((FUpdateList[I] as TgdcReferenceUpdate).FieldName).AsInteger := TargetKeyValue;
        Obj.Post;
      end;
      FUpdateList.Delete(I);
    end;
  end;
end;

function TgdcStreamDataProvider.CopyRecord(SourceDS: TDataSet; TargetDS: TgdcBase): Boolean;
const
  rightsfield = ';ACHAG;AVIEW;AFULL;';
  editorfield = ';EDITORKEY;CREATORKEY;';
var
  I, Key: Integer;
  R: TatRelation;
  F: TatRelationField;
  IsNull: Boolean;
  SourceField, TargetField: TField;
  RU: TgdcReferenceUpdate;
  ErrorSt: String;
  NeedAddToIDMapping: Boolean;
  RUOL: TList;

  ReferencedRecordIndex: Integer;
  ReferencedRecordNewID: TID;
  OrderElement: TStreamOrderElement;
  Obj: TgdcBase;
  CDS: TClientDataSet;
  KeyFieldName: String;
  TargetKeyInt, SourceKeyInt: TID;
begin
  if not (TargetDS.State in [dsInsert, dsEdit]) then
    TargetDS.Edit;
     
  NeedAddToIDMapping := True;
  Result := False;
  RUOL := nil;
  try
    KeyFieldName := TargetDS.GetKeyField(TargetDS.SubType);
    TargetKeyInt := TargetDS.FieldByName(KeyFieldName).AsInteger;
    SourceKeyInt := SourceDS.FieldByName(KeyFieldName).AsInteger;
    //Пробежимся по полям из потока и перенесем их значение в наш объект
    for I := 0 to SourceDS.FieldCount - 1 do
    begin
      SourceField := SourceDS.Fields[I];
      TargetField := TargetDS.FindField(SourceField.FieldName);

      // если вызывался Диалог сравнения записей, и в нем выбрали старое значение этого поля
      //   то не будем перезаписывать его значением из потока
      if (FReplaceFieldList.Count > 0) and (FReplaceFieldList.IndexOf(SourceField.FieldName) <> -1) then
        Continue;

      //Если мы нашли поле в нашем объекте, то поищем к какой таблице оно принадлежит
      if (TargetField <> nil) then
      begin
        R := atDatabase.Relations.ByRelationName(TargetDS.RelationByAliasName(TargetField.FieldName));

        // системных таблиц нет в нашей структуре атДатабэйз
        if R = nil then
        begin
          //Если это ключевое поле, то переходим к следующему полю
          if (AnsiCompareText(SourceField.FieldName, KeyFieldName) = 0) then
            Continue;

          if (TargetField.DataType = ftString) and (SourceField.AsString = '') then
            TargetField.AsString := ''
          else
            TargetField.Assign(SourceField);
          Continue;
        end;

        //Если это поле для установки прав и оно пришло к нам из другой базы
        //то устанавливаем права "для всех"
        if (AnsiPos(';' + AnsiUpperCase(TargetField.FieldName) + ';', rightsfield) > 0) and
          (FDataObject.StreamDBID > -1) and (FDataObject.StreamDBID <> IBLogin.DBID) then
        begin
          TargetField.AsInteger := -1;
          Continue;
        end;

        //Если это поле для указания "Кто редактировал", то считываем текущего пользователя
        if (AnsiPos(';' + AnsiUpperCase(TargetField.FieldName) + ';', editorfield) > 0)
           and (not IsReadUserFromStream) then
        begin
          TargetField.AsInteger := IBLogin.ContactKey;
          Continue;
        end;

        //Если наш объект документ
        if (TargetDS is TgdcDocument) and (TargetField.FieldName = fnDOCUMENTKEY) and (TargetField.Value > 0) then
          Continue;

        //Если наш объект документ и загружаем поле Companykey, то заменим его значение на текущую компанию
        {if (TargetDS is TgdcDocument) and (AnsiCompareText(TargetField.FieldName, fnCompanyKey) = 0) then
        begin
          TargetField.AsInteger := IBLogin.CompanyKey;
          Continue;
        end;}

        F := R.RelationFields.ByFieldName(TargetDS.FieldNameByAliasName(TargetField.FieldName));

        IsNull := False;
        Key := -1;

        if (AnsiCompareText(SourceField.FieldName, KeyFieldName) = 0) then
        begin
          if (F <> nil) and (F.References <> nil) then
          begin
            //Если это ключевое поле и оно является ссылкой, то поищем его в карте идентификаторов
            Key := FIDMapping.IndexOf(SourceField.AsInteger);
            if Key <> -1 then
              Key := FIDMapping.ValuesByIndex[Key];
            if Key > -1 then
            begin
              TargetField.AsInteger := Key;
              NeedAddToIDMapping := False;
            end;
          end;
          //Если это ключевое поле, то переходим к следующему полю
          Continue;
        end;

        //Если это поле-ссылка
        if (F <> nil) and (F.References <> nil) then
        begin
          //Если это поле ссылается на ключевое, то присвоим ему значение ключевого поля
          if (SourceField.AsInteger = SourceKeyInt) and (TargetKeyInt > 0) then
            Key := TargetKeyInt
          else
          begin
            //Ищем его в карте идентификаторов
            Key := FIDMapping.IndexOf(SourceField.AsInteger);
            if Key <> -1 then
            begin
              Key := FIDMapping.ValuesByIndex[Key];
              IsNull := Key = -1;
            end;
          end;

          // если загружаем инкрементный поток, то некоторые записи
          if (Key = -1) and (FDataObject.ReferencedRecordsCount > 0){FDataObject.IsIncrementedStream} then
          begin
            ReferencedRecordIndex := FDataObject.FindReferencedRecord(SourceField.AsInteger);
            if ReferencedRecordIndex > -1 then
            begin
              ReferencedRecordNewID :=
                gdcBaseManager.GetIDByRUID(FDataObject.ReferencedRecord[ReferencedRecordIndex].RUID.XID, FDataObject.ReferencedRecord[ReferencedRecordIndex].RUID.DBID);
              if ReferencedRecordNewID > -1 then
              begin
                Key := ReferencedRecordNewID;
                if FIDMapping.IndexOf(SourceField.AsInteger) = -1 then
                  FIDMapping.ValuesByIndex[FIDMapping.Add(SourceField.AsInteger)] := ReferencedRecordNewID;
              end;
            end;
          end;

          if (Key = -1) and (FLoadingOrderList.Find(SourceField.AsInteger) <> -1) and
            (SourceField.AsInteger <> SourceKeyInt) then
          begin

            // если запись по ссылке, обязательной для заполнения, еще не загружена,
            //   то отменим загрузку текущей записи и загрузим сначала необходимую для ссылки
            if TargetField.Required and FLoadingOrderList.PopElementByID(SourceField.AsInteger, OrderElement) then
            begin
              TargetDS.Cancel;
              Obj := FDataObject.gdcObject[OrderElement.DSIndex];
              CDS := FDataObject.ClientDS[OrderElement.DSIndex];
              if CDS.Locate(Obj.GetKeyField(Obj.SubType), OrderElement.RecordID, []) then
                Self.LoadRecord(Obj, CDS)
              else
                raise EgdcIDNotFound.Create('В потоке не найдена требуемая запись:'#13#10 +
                  Obj.Classname + ' ' + Obj.SubType + ' (' + IntToStr(OrderElement.RecordID) + ')');
              Exit;
            end
            else
            begin
              // иначе, добавим поле в список для заполнения после загрузки необходимой записи
              if not Assigned(RUOL) then
                RUOL := TList.Create;

              RU := TgdcReferenceUpdate.Create;
              RU.FieldName := F.FieldName;
              RU.ObjectIndex := FDataObject.GetObjectIndex(TargetDS.Classname, TargetDS.SubType);
              RU.ID := -1;
              RU.RefID := SourceField.AsInteger;
              FUpdateList.Add(RU);
              RUOL.Add(RU);
              IsNull := True;
            end;
          end
          else
            if (Key = -1) and (SourceField.AsInteger >= cstUserIDStart) then
            begin
              //если мы не нашли нашу ссылку и она не является "стандартной" записью
              //очистим это поле, иначе кинет ошибку ссылочной целостности
              //такие записи могут специально не сохранятся в поток по разным причинам
              //например, в поток не сохраняются системные мета-данные
              IsNull := True;
            end;
        end;

        if IsNull or SourceField.IsNull then
          TargetField.Clear
        else
          if Key = -1 then
            if (TargetField.DataType = ftString) and (SourceField.AsString = '') then
              TargetField.AsString := ''
            else
              TargetField.Assign(SourceField)
          else
            TargetField.AsInteger := Key;
      end;
    end;

    //Стандартные id не должны меняться
    if SourceKeyInt < cstUserIDStart then
      TargetDS.FieldByName(KeyFieldName).AsInteger := SourceKeyInt;

    try
      if TargetDS.State = dsEdit then
      begin
        try
          TargetDS.Post;

          if StreamLoggingType = slAll then
          begin
            AddText('Объект обновлен данными из потока!', clBlack);
            Space;
          end;
        except
          on E: EIBError do
          begin
            if (E.IBErrorCode = isc_no_dup) or (E.IBErrorCode = isc_except) then
            begin
              //мы нашли запись по РУИДУ и попытались обновить ее
              //кинуло ошибку - нельзя сохранить два дублирующихся объекта
              //=> РУИД указывает нам не тот объект
              //=> Делаем Cancel объекту, удаляем некорректный РУИД
              //=> Пытаемся добавить новую запись.
              TargetDS.Cancel;

              AddText('РУИД некорректен. Попытка найти объект по уникальному ключу.', clBlack);
              gdcBaseManager.DeleteRUIDByXID(SourceDS.FieldByName('_XID').AsInteger,
                SourceDS.FieldByName('_DBID').AsInteger, TargetDS.Transaction);
              InsertRecord(SourceDS, TargetDS);
              NeedAddToIDMapping := False;
            end
            else
              raise;
          end;
        end;
      end
      else
        if not TargetDS.CheckTheSame(FAnAnswer, True) then
        begin
          TargetDS.Post;

          if StreamLoggingType = slAll then
          begin
            AddText('Объект добавлен из потока!', clBlack);
            Space;
          end;
        end;

      if NeedAddToIDMapping and (FIDMapping.IndexOf(SourceKeyInt) = -1) then
        FIDMapping.ValuesByIndex[FIDMapping.Add(SourceKeyInt)] := TargetDS.FieldByName(KeyFieldName).AsInteger;

      if Assigned(RUOL) then
      begin
        for I := 0 to RUOL.Count - 1 do
          TgdcReferenceUpdate(RUOL[I]).ID := TargetDS.ID;
      end;

      {TODO: временная мера, переделать на редактирование отдельным объектом}
      TargetKeyInt := TargetDS.ID;
      ApplyDelayedUpdates(SourceKeyInt, TargetDS.FieldByName(KeyFieldName).AsInteger);
      if TargetDS.ID <> TargetKeyInt then
        TargetDS.ID := TargetKeyInt;

      // Успешно скопировали данные
      Result := True;
    except
      on E: EDatabaseError do
      begin
        if TargetDS.State = dsInsert then
          ErrorSt := Format('Невозможно добавить объект: %s %s %s ',
            [TargetDS.ClassName,
             SourceDS.FieldByName(TargetDS.GetListField(TargetDS.SubType)).AsString, IntToStr(SourceKeyInt)])
        else
          ErrorSt := Format('Невозможно обновить объект: %s %s %s',
            [TargetDS.ClassName,
             SourceDS.FieldByName(TargetDS.GetListField(TargetDS.SubType)).AsString, IntToStr(SourceKeyInt)]);

        // удалим проблемный объект из очереди загрузки
        FLoadingOrderList.Remove(SourceKeyInt);
        // во время работы репликатора не будем показавать сообщения
        if not SilentMode then
          MessageBox(TargetDS.ParentHandle, PChar(ErrorSt), 'Ошибка', MB_OK or MB_ICONHAND);

        AddMistake(#13#10 + ErrorSt + #13#10, clRed);
        AddMistake(#13#10 + E.Message + #13#10, clRed);
        Space;
        if Assigned(frmStreamSaver) then
          frmStreamSaver.AddMistake(ErrorSt + #13#10 + E.Message);

        TargetDS.Cancel;
        if FIDMapping.IndexOf(SourceKeyInt) = -1 then
          FIDMapping.ValuesByIndex[FIDMapping.Add(SourceKeyInt)] := -1;
      end;
    end;
  finally
    if Assigned(RUOL) then
      RUOL.Free;
  end;
end;

procedure TgdcStreamDataProvider.InsertRecord(SourceDS: TDataSet; TargetDS: TgdcBase);
var
  RR: TRUIDRec;
begin
  //Вставляем запись в наш объект
  TargetDS.Insert;
  //Если перенос полей из потока прошел корректно
  if CopyRecord(SourceDS, TargetDS) then
  begin
    TargetDS.CheckBrowseMode;
    //Проверяем сохранен ли РУИД в базе
    RR := gdcBaseManager.GetRUIDRecByID(TargetDS.ID, FTransaction);
    if RR.XID = -1 then
    begin
      //Если нет, то вставляем в базу
      gdcBaseManager.InsertRUID(TargetDS.ID, SourceDS.FieldByName('_XID').AsInteger, SourceDS.FieldByName('_DBID').AsInteger,
        SourceDS.FieldByName('_MODIFIED').AsDateTime, IBLogin.ContactKey, FTransaction);
    end else
    begin
      //Если да, то обновляем поля грида по его ID
      gdcBaseManager.UpdateRUIDByID(TargetDS.ID, SourceDS.FieldByName('_XID').AsInteger, SourceDS.FieldByName('_DBID').AsInteger,
        SourceDS.FieldByName('_MODIFIED').AsDateTime, IBLogin.ContactKey, FTransaction);
    end;
    FLoadingOrderList.Remove(SourceDS.FieldByName(TargetDS.GetKeyField(TargetDS.SubType)).AsInteger);
    SourceDS.Delete;
  end;
end;

procedure TgdcStreamDataProvider.LoadRecord(AObj: TgdcBase; CDS: TClientDataSet);
var
  RuidRec: TRuidRec;
  CurrentRecordID, StreamXID, StreamDBID, StreamID: TID;
  Modified, StreamModified: TDateTime;
begin
  Assert(IBLogin <> nil);

  // При нажатии Escape прервем процесс
  if not SilentMode and Application.Active and (AbortProcess or ((GetAsyncKeyState(VK_ESCAPE) shr 1) <> 0)) then
  begin
    if (not AbortProcess) and
       (Application.MessageBox('Остановить загрузку данных?', 'Внимание', MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL) = IDYES) then
    begin
      AbortProcess := True;
    end;  
    Exit;
  end;

  if FReplaceFieldList.Count > 0 then
    FReplaceFieldList.Clear;

  if sFakeLoad in AObj.BaseState then
  begin
    if Assigned(AObj.OnFakeLoad) then
      AObj.OnFakeLoad(AObj, CDS);
    Exit;
  end;

  StreamID := CDS.FieldByName(AObj.GetKeyField(AObj.SubType)).AsInteger;
  StreamXID := CDS.FieldByName('_xid').AsInteger;
  StreamDBID := CDS.FieldByName('_dbid').AsInteger;
  StreamModified := CDS.FieldByName('_modified').AsDateTime;
  Modified := StreamModified;
  // используется в GetRUID
  AObj.StreamXID := StreamXID;
  AObj.StreamDBID := StreamDBID;

  if AObj.SetTable <> '' then
    AObj.SetTable := '';

  Space;
  //Проверяем на соответствие поля для отображения
  if not Assigned(CDS.FindField(AObj.GetListField(AObj.SubType))) then
  begin
    AddText('Считывание объекта ' + AObj.GetDisplayName(AObj.SubType) + ' ' +
        ' (XID =  ' + IntToStr(StreamXID) + ', DBID = ' + IntToStr(StreamDBID) + ')'#13#10, clBlue);

    AddMistake('Структура загружаемого объекта не соответствует '#13#10 +
      ' структуре уже существующего объекта в базе. '#13#10 +
      ' Поле ' + AObj.GetListField(AObj.SubType) + ' не найдено в потоке данных!'#13#10, clRed);

    if Assigned(frmStreamSaver) then
      frmStreamSaver.AddMistake;
  end
  else
  begin
    if Assigned(frmStreamSaver) then
      frmStreamSaver.SetProcessText(AObj.GetDisplayName(AObj.SubType) + #13#10 + '  ' +
        CDS.FieldByName(AObj.GetListField(AObj.SubType)).AsString + #13#10 + '  ' +
        ' (XID =  ' + IntToStr(StreamXID) + ', DBID = ' + IntToStr(StreamDBID) + ')');

    if StreamLoggingType = slAll then
      AddText('Считывание объекта ' + AObj.GetDisplayName(AObj.SubType) + ' ' +
        CDS.FieldByName(AObj.GetListField(AObj.SubType)).AsString + #13#10 +
        ' (XID =  ' + IntToStr(StreamXID) + ', DBID = ' + IntToStr(StreamDBID) + ')'#13#10, clBlue);
  end;

  //Проверим, есть ли у нас такой РУИД
  RuidRec := gdcBaseManager.GetRUIDRecByXID(StreamXID, StreamDBID, FTransaction);
  //Считаем ID, найденное по РУИДУ
  CurrentRecordID := RuidRec.ID;

  //Если мы не нашли РУИД, но наш xid - "Стандартный"
  if (CurrentRecordID = -1) and (StreamXID < cstUserIDStart) then
  begin
    //Попробуем поискать нашу запись
    AObj.ID := StreamXID;
    //Если нашли, то сохраним РУИД
    if not AObj.IsEmpty then
    begin
      gdcBaseManager.InsertRUID(StreamXID, StreamXID, StreamDBID, Date, IBLogin.ContactKey, FTransaction);
      //Сохраним наш XID = id
      CurrentRecordID := StreamXID;
    end;
  end;

  //Если запись в базе не найдена, вставим ее
  if CurrentRecordID = -1 then
  begin
    InsertRecord(CDS, AObj);
    if FDataObject.IsIncrementedStream then
      AddRecordToRPLRECORDS(AObj.ID, Modified);
  end
  else
  begin
    //Попробуем поискать нашу запись
    AObj.ID := CurrentRecordID;
    //Если не нашли, значит РУИД некорректен, удалим его, запись вставим
    if AObj.IsEmpty then
    begin
      gdcBaseManager.DeleteRUIDbyXID(StreamXID, StreamDBID, FTransaction);
      InsertRecord(CDS, AObj);
      if FDataObject.IsIncrementedStream then
        AddRecordToRPLRECORDS(AObj.ID, Modified);
    end
    else
    begin
      if StreamLoggingType = slAll then
        AddText('Объект найден по РУИДу'#13#10, clBlue);

      // Проверяем, необходимо ли нам удалить найденную запись, перед считыванием ее аналога из потока
      if AObj.NeedDeleteTheSame(AObj.SubType)
         and AObj.DeleteTheSame(CurrentRecordID, CDS.FieldByName(AObj.GetListField(AObj.SubType)).AsString) then
      begin
        // Если запись удалена, вставим ее аналог из потока
        InsertRecord(CDS, AObj);
        if FDataObject.IsIncrementedStream then
          AddRecordToRPLRECORDS(AObj.ID, Modified);
      end
      else
      begin
        //Проверим, когда был модифицирован РУИД найденной записи
        Modified := RUIDRec.Modified;
        // Если мы нашли объект по руиду и
        //  дата модификации руида более ранняя, чем загружаемая из потока
        //  или объект нуждается в обновлении данными из потока по умолчанию
        if Assigned(CDS.FindField('_MODIFYFROMSTREAM')) and CDS.FieldByName('_MODIFYFROMSTREAM').AsBoolean
           {(Modified < StreamModified) or } then
        begin
          if AObj.ID <> CurrentRecordID then
            AObj.ID := CurrentRecordID;

          // если поток инкрементный, то проверяем по таблице RPL_RECORD необходимость загрузки записи
          if (not FDataObject.IsIncrementedStream) or CheckNeedLoadingRecord(StreamXID, StreamDBID, StreamModified) then
          begin
            // Уточням, нуждается ли наш объект в обновлении данными из потока
            if CheckNeedModify(AObj, CDS) then
            begin
              // Копирует данные записи из потока в БО на базе
              //   Если вернет false, значит загрузка была прервана для загрузки другой записи перед текущей
              if CopyRecord(CDS, AObj) then
              begin
                // если обновление прошло успешно и мы имеем более раннюю дату модификации руида
                //  изменяем руид
                if (Modified < StreamModified) then
                begin
                  AObj.CheckBrowseMode;
                  gdcBaseManager.UpdateRUIDByXID(AObj.ID, StreamXID, StreamDBID,
                    StreamModified, IBLogin.ContactKey, FTransaction);
                  Modified := StreamModified;
                end;
                if FDataObject.IsIncrementedStream then
                  AddRecordToRPLRECORDS(AObj.ID, Modified);
                // Удалим ключ объекта из очереди загрузки
                FLoadingOrderList.Remove(StreamID);
                CDS.Delete;
              end;
            end
            else
            begin
              //Сохраним соответствие нашего ID и ID из потока в карте идентификаторов
              if FIDMapping.IndexOf(StreamID) = -1 then
                FIDMapping.ValuesByIndex[FIDMapping.Add(StreamID)] := AObj.ID;
              // Удалим ключ объекта из очереди загрузки
              FLoadingOrderList.Remove(StreamID);
              CDS.Delete;
              ApplyDelayedUpdates(StreamID, AObj.ID);
            end;
          end
          else
          begin
            if StreamLoggingType = slAll then
              AddText('Объект найден в RPL_RECORD'#13#10, clBlack);

            //Сохраним соответствие нашего ID и ID из потока в карте идентификаторов
            if FIDMapping.IndexOf(StreamID) = -1 then
              FIDMapping.ValuesByIndex[FIDMapping.Add(StreamID)] := AObj.ID;
            // Удалим ключ объекта из очереди загрузки
            FLoadingOrderList.Remove(StreamID);
            CDS.Delete;
            ApplyDelayedUpdates(StreamID, AObj.ID);
          end;
        end
        else
        begin
          //Сохраним соответствие нашего ID и ID из потока в карте идентификаторов
          if FIDMapping.IndexOf(StreamID) = -1 then
            FIDMapping.ValuesByIndex[FIDMapping.Add(StreamID)] := AObj.ID;
          // Удалим ключ объекта из очереди загрузки
          FLoadingOrderList.Remove(StreamID);
          CDS.Delete;
          ApplyDelayedUpdates(StreamID, AObj.ID);
        end;
      end;
    end;
  end;
end;



procedure TgdcStreamDataProvider.CheckNonConfirmedRecords;
begin
  Exit;
{  if FDataObject.TargetBaseKey > -1 then
  begin
    FIBSQL.Close;
    FIBSQL.SQL.Text := Format(sqlSelectRPLRecordsWithBasekeyState, [FDataObject.TargetBaseKey, Integer(irsOut)]);
    FIBSQL.ExecQuery;
    if FIBSQL.RecordCount > 0 then
    begin
      if MessageBox(0, 'На целевую базу ранее уже отправлялись данные, но не было получено подтверждения об их принятии.'#13#10 +
        'Переслать данные повторно?',
        'Внимание',
        MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES then
      begin

      end;
    end;
  end;}
end;

procedure TgdcStreamDataProvider.GetRecordsWithInState;
begin
  if FDataObject.TargetBaseKey > -1 then
  begin
    FIBSQL.Close;
    FIBSQL.SQL.Text := Format(sqlSelectRPLRecordsByBasekeyState, [FDataObject.TargetBaseKey, Integer(irsIn)]);
    FIBSQL.ExecQuery;
    while not FIBSQL.Eof do
    begin
      FDataObject.AddReceivedRecord(FIBSQL.FieldByName('XID').AsInteger, FIBSQL.FieldByName('DBID').AsInteger);
      FIBSQL.Next
    end;
    // сменим статус у этих записей на irsIncremented (принятие записей подтверждено)
    FIBSQL.Close;
    FIBSQL.SQL.Text := Format(sqlUpdateRPLRecordsSetStateByBasekey, [FDataObject.TargetBaseKey, Integer(irsIncremented)]);
    FIBSQL.ExecQuery;
  end;
end;

procedure TgdcStreamDataProvider.LoadSetRecords;
var
  I: Integer;
  CDS: TClientDataSet;
  Obj: TgdcBase;
begin
  for I := 0 to FDataObject.Count - 1 do
  begin
    CDS := FDataObject.ClientDS[I];
    if (not CDS.IsEmpty) and (CDS.FieldByName('_SETTABLE').AsString <> '') then
    begin
      if Assigned(atDatabase.Relations.ByRelationName(CDS.FieldByName('_SETTABLE').AsString)) then
      begin
        Obj := FDataObject.gdcObject[I];
        CDS.First;
        while not CDS.Eof do
        begin
          Self.LoadSetRecord(Obj, CDS);
          CDS.Next;
        end;
      end
      else
        raise EgdcNoTable.Create(CDS.FieldByName('_SETTABLE').AsString);
    end;
  end;
end;

procedure TgdcStreamDataProvider.LoadSetRecord(AObj: TgdcBase; SourceDS: TDataSet);
const
  sql_SetSelect = 'SELECT * FROM %0:s WHERE %1:s';
  sql_SetUpdate = 'UPDATE %0:s SET %1:s WHERE %2:s';
  sql_SetInsert = 'INSERT INTO %0:s (%1:s) VALUES (%2:s)';
var
  SFld, SValues, SUpdate, SKey: String;
  I: Integer;
  F: TatRelationField;
  Key: Integer;
  Pr: TatPrimaryKey;
  S, S1: String;
  R, R2: TatRelation;
  LocName: String;
begin
  SFld := '';
  SValues := '';
  SUpdate := '';
  {Пробегаемся по полям из потока. Если поле является полем-множеством,
   то формируем соответствующие строки для обновления/вставки}
  for I := 0 to SourceDS.Fields.Count - 1 do
  begin
    if not IsSetField(SourceDS.Fields[I].FieldName) then
      Continue;

    if SFld > '' then SFld := SFld + ',';
    if SValues > '' then SValues := SValues + ',';
    if SUpdate > '' then SUpdate := SUpdate + ',';

    SFld := SFld + GetSetFieldName(SourceDS.Fields[I].FieldName);

    if SourceDS.Fields[I].IsNull then
    begin
      SValues := SValues + 'NULL';
      SUpdate := SUpdate + GetSetFieldName(SourceDS.Fields[I].FieldName) + ' = NULL';
    end
    else if SourceDS.Fields[I].DataType in [ftString, ftDate,
      ftDateTime, ftTime] then
    begin
      SValues := SValues + '''' + SourceDS.Fields[I].AsString + '''';
      SUpdate := SUpdate + GetSetFieldName(SourceDS.Fields[I].FieldName) + ' = ''' +
        SourceDS.Fields[I].AsString + '''';
    end
    else begin
      F := atDataBase.FindRelationField(SourceDS.FieldByName('_SETTABLE').AsString,
        GetSetFieldName(SourceDS.Fields[I].FieldName));
      if (F <> nil) and (F.References <> nil) then
      begin //Если это поле является ссылкой, то поищем его в карте идентификаторов
        Key := FIDMapping.IndexOf(SourceDS.Fields[I].AsInteger);
        if Key > -1 then
        begin
          SKey := IntToStr(FIDMapping.ValuesByIndex[Key]);
        end else
          SKey := SourceDS.Fields[I].AsString;
      end else
        SKey := SourceDS.Fields[I].AsString;
      SKey := StringReplace(SKey, ',', '.', []);
      SValues := SValues + SKey;
      SUpdate := SUpdate + GetSetFieldName(SourceDS.Fields[I].FieldName) + ' = ' + SKey;
    end;
  end;
  if SFld > '' then
  begin
    R2 := atDataBase.Relations.ByRelationName(SourceDS.FieldByName('_SETTABLE').AsString);
    Pr := R2.PrimaryKey;

    if not Assigned(Pr) then
    begin
      {
        если смешали метаданные и данные в одной настройке, то
        переподключения к базе еще не было и информации в atDatabase
        у нас может и не быть. Поэтому перечитаем ее.
      }
      R2.RefreshData(FDatabase, FTransaction, True);
      R2.RefreshConstraints(FDatabase, FTransaction);

      Pr := R2.PrimaryKey;
    end;

    if Assigned(Pr) then
    begin
      try
        S := '';
        for I := 0 to Pr.ConstraintFields.Count -1 do
        begin
          if S > '' then S := S + ' AND ';
          S1 := GetAsSetFieldName(Pr.ConstraintFields[I].FieldName);
          if SourceDS.FieldByName(S1).IsNull then
            S := S + Pr.ConstraintFields[I].FieldName + ' IS NULL'
          else if SourceDS.FieldByName(S1).DataType in [ftString, ftDate,
            ftDateTime, ftTime] then
            S := S + Pr.ConstraintFields[I].FieldName + ' = ''' + SourceDS.FieldByName(S1).AsString + ''''
          else
          begin
            F := atDataBase.FindRelationField(SourceDS.FieldByName('_SETTABLE').AsString,
              GetSetFieldName(SourceDS.FieldByName(S1).FieldName));
            if (F <> nil) and (F.References <> nil) then
            begin //Если это поле является ссылкой, то поищем его в карте идентификаторов
              Key := FIDMapping.IndexOf(SourceDS.FieldByName(S1).AsInteger);
              if Key > -1 then
              begin
                SKey := IntToStr(FIDMapping.ValuesByIndex[Key]);
              end else
                SKey := SourceDS.FieldByName(S1).AsString;
            end else
              SKey := SourceDS.FieldByName(S1).AsString;
            S := S + Pr.ConstraintFields[I].FieldName + ' = ' + SKey;
          end;
        end;
        FIBSQL.Close;
        FIBSQL.SQL.Text := Format(sql_SetSelect, [SourceDS.FieldByName('_SETTABLE').AsString, S]);
        FIBSQL.ExecQuery;

        if FIBSQL.RecordCount > 0 then
        begin
        { TODO -oJulia : Что делать с уже существующими данными? Обновлять?
          В каком-то случае это будет очень плохо, например, таблица gd_lastnumber }
        // FIBSQL.Close;
        //  FIBSQL.SQL.Text := Format(sql_SetUpdate,
        //    [SourceDS.FieldByName('_SETTABLE').AsString, SUpdate, S]);
        end else
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := Format(sql_SetInsert,
            [SourceDS.FieldByName('_SETTABLE').AsString, SFld, SValues]);

          R := atDataBase.Relations.ByRelationName(SourceDS.FieldByName('_SETTABLE').AsString);
          if Assigned(R) then
            LocName := R.LName
          else
            LocName := SourceDS.FieldByName('_SETTABLE').AsString;

          if StreamLoggingType = slAll then
            AddText('Считывание данных множества ' + LocName + #13#10, clBlue);
          FIBSQL.ExecQuery;
        end;
      except
        on E: Exception do
        begin
          AddMistake(E.Message, clRed);
          if Assigned(frmStreamSaver) then
            frmStreamSaver.AddMistake;
        end;
      end;
    end
    else
    begin
      AddMistake(#13#10 + 'Данные множества ' + SourceDS.FieldByName('_SETTABLE').AsString + ' не были добавлены!'#13#10, clRed);
      if Assigned(frmStreamSaver) then
        frmStreamSaver.AddMistake;
    end;
  end;
end;

function TgdcStreamDataProvider.DoBeforeSaving(AObj: TgdcBase): Boolean;
var
  gdcObject: TgdcBase;
  I: Integer;
  LocalID: TID;
begin
  Result := True;
  LocalID := AObj.ID;

  try

    if AnsiCompareText(AObj.Classname, 'TgdcSavedFilter') = 0 then
    begin
      if not AObj.FieldByName('userkey').IsNull then
      begin
        Result := False;
        raise Exception.Create('Фильтр ' + QuotedStr(AObj.FieldByName('name').AsString) + #13#10 +
          'Вы не можете сохранить в настройку пользовательский фильтр с пометкой "Фильтр только для меня"!');
      end;
      Exit;
    end;

    if AnsiCompareText(AObj.Classname, 'TgdcUserStorage') = 0 then
    begin
      if AObj.ID = UserStorage.UserKey then
      begin
        UserStorage.IsModified := True;
        UserStorage.SaveToDatabase;
      end;
      Exit;
    end;

    if AnsiCompareText(AObj.Classname, 'TgdcField') = 0 then
    begin
      //Системные домены не сохраняем!
      if AnsiPos('RDB$', AnsiUpperCase(AObj.FieldByName('fieldname').AsString)) = 1 then
        Result := False;
      Exit;
    end;

    if (AnsiCompareText(AObj.Classname, 'TgdcRelation') = 0)
      or (AnsiCompareText(AObj.Classname, 'TgdcBaseTable') = 0)
      or (AnsiCompareText(AObj.Classname, 'TgdcLBRBTreeTable') = 0)
      or (AnsiCompareText(AObj.Classname, 'TgdcPrimeTable') = 0)
      or (AnsiCompareText(AObj.Classname, 'TgdcTreeTable') = 0) then
    begin
      // Перед сохранением в поток нужно синхронизировать триггеры
      //  т.к. информация о триггерах может не успеть занестись в таблицу at_triggers
      gdcObject := FDataObject.gdcObject[FDataObject.GetObjectIndex('TgdcTrigger', '')];
      (gdcObject as TgdcTrigger).SyncTriggers(AObj.FieldByName('relationname').AsString);
      Exit;
    end;

    if AnsiCompareText(AObj.Classname, 'TgdcStoredProc') = 0 then
    begin
      Assert(AObj.State = dsBrowse);
      try
        (AObj as TgdcStoredProc).PrepareToSaveToStream(true);
      except
        (AObj as TgdcStoredProc).PrepareToSaveToStream(false);
      end;
      Exit;
    end;

    if AnsiCompareText(AObj.Classname, 'TgdcIndex') = 0 then
    begin
      //В поток сохраняем только индексы-атрибуты
      Result := False;
      if AnsiPos(UserPrefix, AnsiUpperCase(AObj.FieldByName('indexname').AsString)) = 1 then
      begin
        //если название индекса совпадает с названием ограничения, то не сохраняем его
        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          ' SELECT * ' +
          ' FROM rdb$relation_constraints ' +
          ' WHERE rdb$constraint_name = rdb$index_name ' +
          '   AND rdb$constraint_name = :indexname';
        FIBSQL.ParamByName('indexname').AsString := AObj.FieldByName('indexname').AsString;
        FIBSQL.ExecQuery;
        if FIBSQL.RecordCount = 0 then
          Result := True;
      end;
      Exit;
    end;

    if AnsiCompareText(AObj.Classname, 'TgdcTrigger') = 0 then
    begin
      //Мы не будем сохранять триггер USR$_BU_INV_CARD в поток,
      //т.к. он генерируется автоматически при изменении структуры таблицы inv_card
      Result := False;
      if (AnsiCompareText('USR$_BU_INV_CARD', Trim(AObj.FieldByName('triggername').AsString)) = 0) then
        Exit;
      for I := 1 to MaxInvCardTrigger do
        if (AnsiCompareText(Format('USR$%d_BU_INV_CARD', [I]), Trim(AObj.FieldByName('triggername').AsString)) = 0) then
          Exit;
      //В поток сохраняем только триггеры-атрибуты
      if AnsiPos(UserPrefix, AnsiUpperCase(AObj.FieldByName('triggername').AsString)) = 1 then
        Result := True;
      Exit;
    end;

    if AnsiCompareText(AObj.Classname, 'TgdcGenerator') = 0 then
    begin
      //В поток сохраняем только генераторы-атрибуты
      if not AnsiPos(UserPrefix, AnsiUpperCase(AObj.FieldByName('generatorname').AsString)) = 1 then
        Result := False;
      Exit;
    end;

    if AnsiCompareText(AObj.Classname, 'TgdcCheckConstraint') = 0 then
    begin
      //В поток сохраняем только чеки-атрибуты
      if not AnsiPos(UserPrefix, AnsiUpperCase(AObj.FieldByName('checkname').AsString)) = 1 then
        Result := False;
      Exit;
    end;

  finally
    // в процессе сохранения присоединенных элементов ID объекта могло изменится,
    // восстановим первоначальное
    if AObj.ID <> LocalID then
      AObj.ID := LocalID;
  end;
end;

function TgdcStreamDataProvider.DoAfterSaving(AObj: TgdcBase): Boolean;
const
  PrNameArray: array [1..3] of String =
    ('USR$_P_EXLIM_%0:S',
     'USR$_P_CHLDCT_%0:S',
     'USR$_P_RESTR_%0:S');
var
  AnObject: TgdcBase;
  I: Integer;
  ObjectIndex: Integer;
  atRelation: TatRelation;
  LocalID: TID;
  KeyArray: TgdKeyArray;
begin
  Result := true;

  if AnsiCompareText(AObj.Classname, 'TgdcStoredProc') = 0 then
  begin
    (AObj as TgdcStoredProc).PrepareToSaveToStream(false);
    Exit;
  end;

  if AnsiCompareText(AObj.Classname, 'TgdcLBRBTreeTable') = 0 then
  begin
    ObjectIndex := FDataObject.GetObjectIndex('TgdcStoredProc', '');
    AnObject := FDataObject.gdcObject[ObjectIndex];
    KeyArray := TgdKeyArray.Create;
    try
      // выберем ИД необходимых процедур
      for I := 1 to Length(PrNameArray) do
      begin
        AnObject.Close;
        AnObject.SubSet := 'ByProcName';
        AnObject.ParamByName('procedurename').AsString :=
          gdcBaseManager.AdjustMetaName(Format(PrNameArray[I], [AnsiUpperCase(AObj.FieldByName('relationname').AsString)]));
        AnObject.Open;
        if (AnObject.ID <> AObj.ID) and (AnObject.RecordCount > 0) then
          if KeyArray.IndexOf(AnObject.ID) = -1 then
            KeyArray.Add(AnObject.ID);
      end;
      // сохраним процедуры в поток
      LocalID := AObj.ID;
      for I := 0 to KeyArray.Count - 1 do
        Self.SaveRecord(ObjectIndex, KeyArray.Keys[I]);
      if AObj.ID <> LocalID then
        AObj.ID := LocalID;
    finally
      KeyArray.Free;
    end;
    Exit;
  end;

  if AnsiCompareText(AObj.Classname, 'TgdcUnknownTable') = 0 then
  begin
    // Сделано для кросс-таблиц. Если это пользовательская таблица и у нее есть
    //   праймари кей, то сохраним в поток поля, входящие в праймари кей
    if AnsiPos(UserPrefix, AObj.FieldByName('relationname').AsString) = 1 then
    begin
      atRelation := atDatabase.Relations.ByRelationName(AObj.FieldByName('relationname').AsString);

      if not Assigned(atRelation) then
        raise EgdcIBError.Create('Таблица ' + AObj.FieldByName('relationname').Asstring +
          ' не найдена! Попробуйте перезагрузиться.');

      if Assigned(atRelation.PrimaryKey) then
      begin
        ObjectIndex := FDataObject.GetObjectIndex('TgdcRelationField', '');
        for I := 0 to atRelation.PrimaryKey.ConstraintFields.Count - 1 do
        begin
          LocalID := AObj.ID;
          Self.SaveRecord(ObjectIndex, atRelation.PrimaryKey.ConstraintFields[I].ID);
          if AObj.ID <> LocalID then
            AObj.ID := LocalID;
        end;
      end;
    end;
    Exit;
  end;

end;

function TgdcStreamDataProvider.CheckNeedSaveRecord(const AID: TID;
  AModified: TDateTime): Boolean;
var
  State: TIncrRecordState;
  RplEditionDate: TDateTime;
begin
  Result := True;

  if FDataObject.IsIncrementedStream then
  begin
    IbsqlRPLRecordSelect.Close;
    IbsqlRPLRecordSelect.ParamByName('ID').AsInteger := AID;
    IbsqlRPLRecordSelect.ExecQuery;
    if IbsqlRPLRecordSelect.RecordCount > 0 then
    begin
      State := TIncrRecordState(IbsqlRPLRecordSelect.FieldByName('STATE').AsInteger);
      RplEditionDate := IbsqlRPLRecordSelect.FieldByName('EDITIONDATE').AsDateTime;
      // если запись уже отправлялась на целевую базу и с тех пор не изменялась, то не сохраняем ее в поток
      if (State = irsIncremented) and (RplEditionDate >= AModified) then
      begin
        Result := False;
      end
      else
      begin
        // удалим из RPL_RECORD информацию о сохраняемой записи
        FIBSQL.Close;
        FIBSQL.SQL.Text := Format(sqlDeleteRPLRecordsByBaseKeyID, [FDataObject.TargetBaseKey, AID]);
        FIBSQL.ExecQuery;
      end;
    end;
  end;
end;

function TgdcStreamDataProvider.CheckNeedLoadingRecord(const XID,
  DBID: TID; AModified: TDateTime): Boolean;
var
  State: TIncrRecordState;
  RplEditionDate: TDateTime;
begin
  Result := True;

  if FDataObject.IsIncrementedStream then
  begin
    FIBSQL.Close;
    FIBSQL.SQL.Text := Format(sqlSelectRPLRecordsDateStateByRUID, [XID, DBID]);
    FIBSQL.ExecQuery;
    if FIBSQL.RecordCount > 0 then
    begin
      State := TIncrRecordState(FIBSQL.FieldByName('STATE').AsInteger);
      RplEditionDate := FIBSQL.FieldByName('EDITIONDATE').AsDateTime;
      if (State = irsIncremented) and (RplEditionDate >= AModified) then
      begin
        FIBSQL.Close;
        FIBSQL.SQL.Text := Format(sqlDeleteRPLRecordsByBaseKeyRUID, [FDataObject.SourceBaseKey, XID, DBID]);
        FIBSQL.ExecQuery;
        Result := False;
      end;
    end;
  end;

end;

procedure TgdcStreamDataProvider.AddRecordToRPLRECORDS(const AID: TID; AModified: TDateTime);
var
  XID, DBID: TID;
begin
  if FDataObject.SourceBaseKey > -1 then
  begin
    IbsqlRPLRecordDelete.Close;
    IbsqlRPLRecordDelete.ParamByName('ID').AsInteger := AID;
    IbsqlRPLRecordDelete.ParamByName('EDITIONDATE').AsDateTime := AModified;
    IbsqlRPLRecordDelete.ExecQuery;

    IbsqlRPLRecordSelect.Close;
    IbsqlRPLRecordSelect.ParamByName('ID').AsInteger := AID;
    IbsqlRPLRecordSelect.ExecQuery;

    if IbsqlRPLRecordSelect.RecordCount = 0 then
    begin
      IbsqlRPLRecordInsert.Close;
      IbsqlRPLRecordInsert.ParamByName('ID').AsInteger := AID;
      IbsqlRPLRecordInsert.ParamByName('STATE').AsInteger := Integer(irsIn);
      IbsqlRPLRecordInsert.ParamByName('EDITIONDATE').AsDateTime := AModified;
      IbsqlRPLRecordInsert.ExecQuery;
      try
        IbsqlRPLRecordInsert.ExecQuery;
      except
        on E: Exception do
        begin
          gdcBaseManager.GetRUIDByID(AID, XID, DBID, FTransaction);
          if Assigned(frmStreamSaver) then
            frmStreamSaver.AddMistake(Format('%s, XID = %d, DBID = %d ', [E.Message, XID, DBID]));
          AddMistake(Format('%s, XID = %d, DBID = %d ', [E.Message, XID, DBID]), clRed);
        end;
      end;
      {if IbsqlRPLRecordInsert.RowsAffected <> 1 then
        raise Exception.Create(GetGsException(Self, 'AddRecordToRPLRECORDS: Ошибка при вставке записи в таблицу RPL_RECORD'));}
    end;    
  end;
end;

procedure TgdcStreamDataProvider.LoadReceivedRecords;
var
  I: Integer;
begin
  if FDataObject.SourceBaseKey > -1 then
  begin
    FIBSQL.Close;
    FIBSQL.SQL.Text := Format(sqlUpdateRPLRecordsSetStateByBasekeyRUID, [FDataObject.SourceBaseKey, Integer(irsIncremented)]);
    for I := 0 to FDataObject.ReceivedRecordsCount - 1 do
    begin
      FIBSQL.Close;
      FIBSQL.ParamByName('XID').AsInteger := FDataObject.ReceivedRecord[I].XID;
      FIBSQL.ParamByName('DBID').AsInteger := FDataObject.ReceivedRecord[I].DBID;
      FIBSQL.ExecQuery;
    end;
  end;  
end;

procedure TgdcStreamDataProvider.SetTransaction(
  const Value: TIBTransaction);
begin
  if Assigned(Value) then
    FTransaction := Value;
end;

procedure TgdcStreamDataProvider.ProcessDatabaseList;
const
  sqlFindDatabaseRecord = 'SELECT * FROM rpl_database WHERE id = %0:s';
  sqlInsertDatabaseRecord = 'INSERT INTO rpl_database (id, name) VALUES (%0:s, ''%1:s'')';
  sqlSetOurDatabase = 'UPDATE rpl_database SET isourbase = 1 WHERE id = %0:d';
var
  I: Integer;
  BaseID, BaseName: String;
begin
  if not FDataObject.IsIncrementedStream then
    Exit;

  if FDataObject.DatabaseList.Count > 0 then
  begin
    for I := 0 to FDataObject.DatabaseList.Count - 1 do
    begin
      BaseID := FDataObject.DatabaseList.Names[I];
      FIBSQL.Close;
      FIBSQL.SQL.Text := Format(sqlFindDatabaseRecord, [BaseID]);
      FIBSQL.ExecQuery;
      if FIBSQL.RecordCount = 0 then
      begin
        BaseName := FDataObject.DatabaseList.Values[BaseID];
        FIBSQL.Close;
        FIBSQL.SQL.Text := Format(sqlInsertDatabaseRecord, [BaseID, BaseName]);
        FIBSQL.ExecQuery;

        if StreamLoggingType = slAll then
          AddText('Добавлена запись в RPL_DATABASE (ID = ' + BaseID + ', NAME = ''' + BaseName + ''')'#13#10, clBlue);
      end;
    end;
  end;

  if (FDataObject.OurBaseKey = -1) and (FDataObject.TargetBaseKey > -1) then
  begin
    FIBSQL.Close;
    FIBSQL.SQL.Text := Format(sqlSetOurDatabase, [FDataObject.TargetBaseKey]);
    FIBSQL.ExecQuery;
    FDataObject.OurBaseKey := FDataObject.TargetBaseKey;

    if StreamLoggingType = slAll then
      AddText('Базе присвоен ID в таблице RPL_DATABASE (ID = ' + IntToStr(FDataObject.OurBaseKey) + ')'#13#10, clBlue);
  end;
end;

function TgdcStreamDataProvider.CheckNeedModify(ABaseRecord: TgdcBase;
  AStreamRecord: TClientDataSet): Boolean;
const
  PassFieldName = ';EDITIONDATE;CREATIONDATE;CREATORKEY;EDITORKEY;ACHAG;AVIEW;AFULL;LB;RB;';
var
  IsDifferent: Boolean;
  NeedModifyFromStream: Boolean;
  I: Integer;
  R: TatRelation;
  F: TatRelationField;
  Key: Integer;
  SourceSt, CurrentSt: String;
begin
  Result := True;

  {case FReplaceRecordBehaviour of
    rrbAlways:
      Exit;
    rrbNever:
    begin
      Result := False;
      Exit;
    end;
  end;}

  // во время работы репликатора не заменяем метаданные или типы документов, другие объекты заменяем без вопросов
  if SilentMode then
  begin
    if ABaseRecord.InheritsFrom(TgdcMetaBase) or ABaseRecord.InheritsFrom(TgdcBaseDocumentType) then
      Result := False
    else
      Result := True;
    Exit;
  end;

  // если наш объект - стандартные мета-данные, то перезаписываем по умолчанию
  if ABaseRecord.InheritsFrom(TgdcMetaBase) and (not (ABaseRecord as TgdcMetaBase).IsUserDefined) then
    Exit;

  case FAnAnswer of
    mrYesToAll:
    begin
      Result := True;
    end;

    mrNoToAll:
    begin
      Result := False;
    end;

    else
    begin
      // Возможно нам выставили флаг "Обновлять из потока" вручную,
      //   тогда нас не интересует ни дата обновления, ни содержимое уже существующей записи
      NeedModifyFromStream := Assigned(AStreamRecord.FindField('_MODIFYFROMSTREAM')) and AStreamRecord.FieldByName('_MODIFYFROMSTREAM').AsBoolean;

      if ABaseRecord.NeedModifyFromStream(ABaseRecord.SubType) <> NeedModifyFromStream then
      begin
        FAnAnswer := MessageDlg('Объект ' + ABaseRecord.GetDisplayName(ABaseRecord.SubType) + ' ' +
          ABaseRecord.FieldByName(ABaseRecord.GetListField(ABaseRecord.SubType)).AsString + ' с идентификатором ' +
          ABaseRecord.FieldByName(ABaseRecord.GetKeyField(ABaseRecord.SubType)).AsString + ' уже существует в базе. ' +
          'Заменить объект? ', mtConfirmation,
          [mbYes, mbYesToAll, mbNo, mbNoToAll], 0);
        case FAnAnswer of
          mrYes, mrYesToAll: Result := True;
          else Result := False;
        end;
      end
      else
      begin
        if Assigned(AStreamRecord.FindField(fneditiondate))
           and Assigned(ABaseRecord.FindField(fneditiondate))
           and (AStreamRecord.FieldByName(fneditiondate).AsDateTime > ABaseRecord.FieldByName(fneditiondate).AsDateTime) then
        begin
          Result := True;
          Exit;
        end;

        Result := False;
        IsDifferent := False;
        // Проверим на отличие содержимого полей загружаемой записи от существующей
        for I := 0 to AStreamRecord.Fields.Count - 1 do
        begin
          // Исключим из проверки поля editiondate, keyfield, editorkey
          if Assigned(ABaseRecord.FindField(AStreamRecord.Fields[I].FieldName)) and
            (AnsiCompareText(Trim(AStreamRecord.Fields[I].FieldName), ABaseRecord.GetKeyField(ABaseRecord.SubType)) <> 0) and
            (AnsiPos(';' + AnsiUpperCase(Trim(AStreamRecord.Fields[I].FieldName)) + ';', PassFieldName) = 0) then
          begin
            F := nil;
            if Assigned(atDatabase) and (AStreamRecord.Fields[I].DataType in [ftInteger, ftSmallInt, ftWord]) then
            begin
             // Проверяем не является ли наше поле ссылкой
              R := atDatabase.Relations.ByRelationName(ABaseRecord.RelationByAliasName(AStreamRecord.Fields[I].FieldName));
              if Assigned(R) then
                F := R.RelationFields.ByFieldName(ABaseRecord.FieldNameByAliasName(AStreamRecord.Fields[I].FieldName));
              if Assigned(F) and Assigned(F.References) then
              begin
                Key := FIDMapping.IndexOf(AStreamRecord.Fields[I].AsInteger);
                if Key <> -1 then
                  Key := FIDMapping.ValuesByIndex[Key];
                if (Key = -1) and (AStreamRecord.Fields[I].AsInteger < cstUserIDStart) then
                  Key := AStreamRecord.Fields[I].AsInteger;

                // Сравниваем наши ссылки
                if (Key > -1) and (Key <> ABaseRecord.FieldByName(AStreamRecord.Fields[I].FieldName).AsInteger) then
                begin
                  IsDifferent := True;
                  Break;
                end;
                Continue;
              end;
            end;

            if (Trim(AStreamRecord.Fields[I].AsString) = '') and (AStreamRecord.Fields[I].AsString > '') then
              // Если строка у нас содержит только пробелы
              //  То оставляем ее такую как есть
              SourceSt := AStreamRecord.Fields[I].AsString
            else
              // В обратном случае убираем ведущие и закрывающие пробелы
              SourceSt := Trim(AStreamRecord.Fields[I].AsString);

            if (Trim(ABaseRecord.FieldByName(AStreamRecord.Fields[I].FieldName).AsString) = '') and
               (ABaseRecord.FieldByName(AStreamRecord.Fields[I].FieldName).AsString > '') then
              CurrentSt := ABaseRecord.FieldByName(AStreamRecord.Fields[I].FieldName).AsString
            else
              CurrentSt := Trim(ABaseRecord.FieldByName(AStreamRecord.Fields[I].FieldName).AsString);

            if AnsiCompareStr(CurrentSt, SourceSt) <> 0 then
            begin
              IsDifferent := True;
              Break;
            end;
          end;
        end;

        //Если загружаемая запись отличается от существующей уточним, нужно ли ее считывать
        if IsDifferent then
        begin
          with TdlgCompareRecords.Create(frmStreamSaver) do
          try
            BaseRecord := ABaseRecord;
            StreamRecord := AStreamRecord;
            ReplaceFieldList := FReplaceFieldList;
            if ShowModal = mrOK then
              Result := True
            else
              Result := False;
          finally
            Free;
          end;
        end;
      end;
    end;
  end;
end;

procedure TgdcStreamDataProvider.Reset;
begin
  FNowSavedRecords.Reset;
end;


procedure TgdcStreamDataProvider.SaveStorageItem(const ABranchName, AValueName: String);
var
  Path, StorageName: String;
  NewFolder: TgsStorageFolder;
  StorageValue: TgsStorageValue;
  Storage: TgsStorage;

  procedure SaveValue(AValue: TgsStorageValue);
  begin
    if Assigned(AValue) then
    begin
      if StreamLoggingType = slAll then
        AddText('Сохранение параметра ' + AValue.Name +
          ' ветки хранилища ' + AValue.Storage.Name + AValue.Parent.Path, clBlue);
      FDataObject.StorageItemList.AddObject(AValue.Storage.Name + AValue.Parent.Path + '\' + AValue.Name, AValue);
    end
    else
      raise EgdcIBError.Create(' Параметр ' + AValue.Name +
        ' ветки хранилища ' + AValue.Storage.Name + AValue.Parent.Path + ' не найден!');
  end;

  procedure SaveFolder(AFolder: TgsStorageFolder);
  var
    I: Integer;
  begin
    if Assigned(AFolder) then
    begin
      if StreamLoggingType = slAll then
        AddText('Сохранение ветки хранилища ' + AFolder.Storage.Name + AFolder.Path, clBlue);

      FDataObject.StorageItemList.AddObject(AFolder.Storage.Name + AFolder.Path + '\', AFolder);

      // Сохраняем подпапки
      for I := 0 to AFolder.FoldersCount - 1 do
        SaveFolder(AFolder.Folders[I]);

      // Сохраняем параметры папки
      for I := 0 to AFolder.ValuesCount - 1 do
        SaveValue(AFolder.Values[I]);  

    end
    else
      raise EgdcIBError.Create(
        'Ветка хранилища "' + AFolder.Storage.Name + AFolder.Path + '" не найдена!'#13#10#13#10 +
        'В настройку можно добавлять только ветки или параметры'#13#10 +
        'глобального хранилища или хранилища пользователя Администратор.');
  end;

begin
  if AnsiPos('\', ABranchName) = 0 then
  begin
    Path := '';
    StorageName := ABranchName;
  end
  else
  begin
    Path := System.Copy(ABranchName, AnsiPos('\', ABranchName), Length(ABranchName) - AnsiPos('\', ABranchName) + 1);
    StorageName := AnsiUpperCase(System.Copy(ABranchName, 1, AnsiPos('\', ABranchName) - 1));
  end;

  if AnsiPos(st_root_Global, StorageName) = 1 then
  begin
    GlobalStorage.CloseFolder(GlobalStorage.OpenFolder('', False, True), False);
    Storage := GlobalStorage;
  end
  else
    if AnsiPos(st_root_User, StorageName) = 1 then
    begin
      UserStorage.CloseFolder(UserStorage.OpenFolder('', False, True), False);
      Storage := UserStorage;
    end
    else
      Storage := nil;

  if Storage = nil then
    NewFolder := nil
  else
    NewFolder := Storage.OpenFolder(Path, False);

  if Assigned(NewFolder) and (AValueName > '') then
    StorageValue := NewFolder.ValueByName(AValueName)
  else
    StorageValue := nil;

  if AValueName > '' then
    SaveValue(StorageValue)
  else
    SaveFolder(NewFolder);

  Storage.CloseFolder(NewFolder);
end;

procedure TgdcStreamDataProvider.LoadStorage;
begin
  //
end;

function TgdcStreamDataProvider.GetIbsqlRPLRecordSelect: TIBSQL;
begin
  if not Assigned(FIbsqlRPLRecordSelect) then
  begin
    FIbsqlRPLRecordSelect := TIBSQL.Create(nil);
    FIbsqlRPLRecordSelect.Database := FDatabase;
    FIbsqlRPLRecordSelect.Transaction := FTransaction;
    if FDataObject.IsSave then
      FIbsqlRPLRecordSelect.SQL.Text := Format(sqlSelectRPLRecordsDateStateByBaseKeyID, [FDataObject.TargetBaseKey])
    else
      FIbsqlRPLRecordSelect.SQL.Text := Format(sqlSelectRPLRecordsDateStateByBaseKeyID, [FDataObject.SourceBaseKey]);
    FIbsqlRPLRecordSelect.Prepare;
  end;
  Result := FIbsqlRPLRecordSelect;
end;

function TgdcStreamDataProvider.GetIbsqlRPLRecordInsert: TIBSQL;
begin
  if not Assigned(FIbsqlRPLRecordInsert) then
  begin
    FIbsqlRPLRecordInsert := TIBSQL.Create(nil);
    FIbsqlRPLRecordInsert.Database := FDatabase;
    FIbsqlRPLRecordInsert.Transaction := FTransaction;
    if FDataObject.IsSave then
      FIbsqlRPLRecordInsert.SQL.Text := Format(sqlInsertRPLRecordsIDStateEditionDate, [FDataObject.TargetBaseKey])
    else
      FIbsqlRPLRecordInsert.SQL.Text := Format(sqlInsertRPLRecordsIDStateEditionDate, [FDataObject.SourceBaseKey]);
    FIbsqlRPLRecordInsert.Prepare;
  end;
  Result := FIbsqlRPLRecordInsert;
end;

function TgdcStreamDataProvider.GetIbsqlRPLRecordDelete: TIBSQL;
begin
  if not Assigned(FIbsqlRPLRecordDelete) then
  begin
    FIbsqlRPLRecordDelete := TIBSQL.Create(nil);
    FIbsqlRPLRecordDelete.Database := FDatabase;
    FIbsqlRPLRecordDelete.Transaction := FTransaction;
    FIbsqlRPLRecordDelete.SQL.Text := sqlDeleteRPLRecordsByIDEditiondate;
    FIbsqlRPLRecordDelete.Prepare;
  end;
  Result := FIbsqlRPLRecordDelete;
end;

{ TStreamOrderList }

constructor TStreamOrderList.Create;
begin
  FCount := 0;
  FSize := 32;
  SetLength(FItems, FSize);
end;

destructor TStreamOrderList.Destroy;
begin
  SetLength(FItems, 0);
end;

function TStreamOrderList.AddItem(AID: TID; ADSIndex: Integer = -1): Integer;
begin
  if FCount = FSize then
  begin
    FSize := (FSize + 1) * 2;
    SetLength(FItems, FSize);
  end;
  FItems[FCount].Index := FCount;
  FItems[FCount].DSIndex := ADSIndex;
  FItems[FCount].RecordID := AID;
  FItems[FCount].Disabled := False;
  Result := FCount;
  Inc(FCount);
end;

function TStreamOrderList.Find(const AID: TID; const ADSIndex: Integer = -1;
  AndDisabled: Boolean = False): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FCount - 1 do
  begin
    if (FItems[I].RecordID = AID) and ((not FItems[I].Disabled) or AndDisabled)
       and ((FItems[I].DSIndex = ADSIndex) or (ADSIndex = -1)) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TStreamOrderList.GetOrderElement(Index: Integer): TStreamOrderElement;
begin
  if (Index < 0) or (Index > (FCount - 1)) then
    raise Exception.Create(GetGsException(Self, 'GetOrderElement: Invalid index (' + IntToStr(Index) + ')'));
  Result := FItems[Index];
end;

procedure TStreamOrderList.Remove(const AID: TID; const ADSIndex: Integer = -1);
var
  I: Integer;
begin
  I := Self.Find(AID, ADSIndex);
  if I > -1 then
    FItems[I].Disabled := True;
end;

procedure TStreamOrderList.Reset;
begin
  FCount := 0;
end;

{ TgdcStreamLoadingOrderList }

constructor TgdcStreamLoadingOrderList.Create;
begin
  inherited;
  FIsLoading := False;
  FNext := 0;
end;

procedure TgdcStreamLoadingOrderList.LoadFromStream(Stream: TStream; const AFormat: TgsStreamType = sttBinaryNew);
var
  I: Integer;
  Index, DSIndex: Integer;
  ID: TID;
begin
  FIsLoading := True;

  if AFormat = sttBinaryNew then
  begin
    Stream.ReadBuffer(I, SizeOf(I));
    SetLength(FItems, I);
    while I > 0 do
    begin
      Stream.ReadBuffer(Index, SizeOf(Index));
      Stream.ReadBuffer(DSIndex, SizeOf(DSIndex));
      Stream.ReadBuffer(ID, SizeOf(ID));
      AddItem(ID, DSIndex);
      Dec(I);
    end;
  end;
end;

procedure TgdcStreamLoadingOrderList.SaveToStream(Stream: TStream; const AFormat: TgsStreamType = sttBinaryNew);
var
  I: Integer;
begin
  if AFormat = sttXML then
  begin
    for I := 0 to FCount - 1 do
      StreamWriteXMLString(Stream, '<ITEM index="' + IntToStr(FItems[I].Index) +
      '" dsindex="' + IntToStr(FItems[I].DSIndex) +
      '" recordid="' + IntToStr(FItems[I].RecordID) + '"/>'#13#10);
  end
  else
  begin
    Stream.Write(FCount, SizeOf(FCount));
    for I := 0 to FCount - 1 do
    begin
      Stream.Write(FItems[I].Index, SizeOf(Integer));
      Stream.Write(FItems[I].DSIndex, SizeOf(Integer));
      Stream.Write(FItems[I].RecordID, SizeOf(TID));
    end;
  end;
end;

function TgdcStreamLoadingOrderList.PopNextElement(out Element: TStreamOrderElement): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := FNext to FCount - 1 do
  begin
    if not FItems[I].Disabled then
    begin
      Element := FItems[I];
      Result := True;
      FNext := I + 1;
      Exit;
    end;
  end;
end;

function TgdcStreamLoadingOrderList.PopElementByID(const AID: TID;
  out Element: TStreamOrderElement): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FCount - 1 do
  begin
    if (not FItems[I].Disabled) and (FItems[I].RecordID = AID) then
    begin
      Element := FItems[I];
      Result := True;
      FNext := 0;
      Exit;
    end;
  end;
end;

{ TgdcStreamWriterReader }

constructor TgdcStreamWriterReader.Create(AObjectSet: TgdcStreamDataObject = nil; ALoadingOrderList: TgdcStreamLoadingOrderList = nil);
begin
  if AObjectSet <> nil then
    FDataObject := AObjectSet;
  if ALoadingOrderList <> nil then
    FLoadingOrderList := ALoadingOrderList;
end;

destructor TgdcStreamWriterReader.Destroy;
begin
  if FDataObject <> nil then
    FDataObject := nil;
  if FLoadingOrderList <> nil then
    FLoadingOrderList := nil;
    
  inherited;  
end;

procedure TgdcStreamWriterReader.SetLoadingOrderList(
  const Value: TgdcStreamLoadingOrderList);
begin
  if Value <> nil then
    FLoadingOrderList := Value;
end;

procedure TgdcStreamWriterReader.SetDataObject(
  const Value: TgdcStreamDataObject);
begin
  if Value <> nil then
    FDataObject := Value;
end;

{ TgdcStreamBinaryWriterReader }

procedure TgdcStreamBinaryWriterReader.LoadFromStream(const S: TStream);

  function StreamReadString(St: TStream): String;
  var
    L: Integer;
  begin
    St.ReadBuffer(L, SizeOf(L));
    SetLength(Result, L);
    if L > 0 then
      St.ReadBuffer(Result[1], L);
  end;

var
  I, J: Integer;
  ID, XID, DBID: TID;
  ObjectIndex: Integer;
  AMissingClassList: TStringList;
  ObjDataLen: Integer;
  C: TClass;
  LoadClassName: TgdcClassName;
  LoadSubType: TgdcSubType;
  LoadSetTable: ShortString;
  MS: TMemoryStream;
  PackStream: TZDecompressionStream;
  UnpackedStream: TMemoryStream;
  BaseID: Integer;
  BaseName: ShortString;
  StreamVersion, StreamDBID: Integer;
  SizeRead: Integer;
  Buffer: array[0..1023] of Char;
begin

  FDataObject.IsSave := False;

  // проверим тот ли поток нам подсунули для считывания
  S.ReadBuffer(I, SizeOf(I));
  if I <> cst_StreamLabel then
    raise Exception.Create(GetGsException(Self, 'LoadFromStream: Invalid stream format'));
  S.ReadBuffer(StreamVersion, SizeOf(StreamVersion));
  FDataObject.StreamVersion := StreamVersion;
  S.ReadBuffer(StreamDBID, SizeOf(StreamDBID));
  FDataObject.StreamDBID := StreamDBID;

  UnpackedStream := TMemoryStream.Create;
  try
    PackStream := TZDecompressionStream.Create(S);
    try
      repeat
        SizeRead := PackStream.Read(Buffer, 1024);
        UnpackedStream.WriteBuffer(Buffer, SizeRead);
      until (SizeRead < 1024);
    finally
      PackStream.Free;
    end;
    UnpackedStream.Position := 0;

    // список баз данных из таблицы RPL_DATABASE
    UnpackedStream.ReadBuffer(I, SizeOf(I));
    if I > 0 then
    begin
      for J := 1 to I do
      begin
        UnpackedStream.ReadBuffer(BaseID, SizeOf(BaseID));
        BaseName := StreamReadString(UnpackedStream);
        FDataObject.DatabaseList.Add(IntToStr(BaseID) + '=' + BaseName);
      end;
    end;

    // считываем ИД базы пославшей поток
    UnpackedStream.ReadBuffer(I, SizeOf(I));
    if I > -1 then
      FDataObject.SourceBaseKey := I;
    // считываем ИД базы на которую поток был отправлен
    UnpackedStream.ReadBuffer(I, SizeOf(I));
    if I > -1 then
      FDataObject.TargetBaseKey := I;

    UnpackedStream.ReadBuffer(I, SizeOf(I));
    if I > 0 then
    begin
      // обрабатываем список RUID'ов записей получение которых подтвердили на исходной базе потока
      for J := 1 to I do
      begin
        UnpackedStream.ReadBuffer(XID, SizeOf(XID));
        UnpackedStream.ReadBuffer(DBID, SizeOf(DBID));
        FDataObject.AddReceivedRecord(XID, DBID);
      end;
    end;

    UnpackedStream.ReadBuffer(I, SizeOf(I));
    if I > 0 then
    begin
      // обрабатываем список RUID'ов и ID записей, которые не пошли в инкрементный поток
      // т.к. они присутствуют на целевой базе
      for J := 1 to I do
      begin
        UnpackedStream.ReadBuffer(ID, SizeOf(ID));
        UnpackedStream.ReadBuffer(XID, SizeOf(XID));
        UnpackedStream.ReadBuffer(DBID, SizeOf(DBID));
        FDataObject.AddReferencedRecord(ID, XID, DBID);
      end;
    end;

    AMissingClassList := TStringList.Create;
    try
      AMissingClassList.Duplicates := dupIgnore;
      AMissingClassList.Sorted := True;

      UnpackedStream.ReadBuffer(I, SizeOf(I));
      while I > 0 do
      begin
        // загружаем класс и подтип сохраненного объекта
        LoadClassName := StreamReadString(UnpackedStream);
        LoadSubType := StreamReadString(UnpackedStream);
        LoadSetTable := StreamReadString(UnpackedStream);

        C := GetClass(LoadClassName);

        {Пропускаем класс, если он не найден}
        if C = nil then
        begin
          AddMistake(#13#10 + 'При загрузке из потока встречен несуществующий класс: ' + LoadClassName + #13#10, clRed);
          if (AMissingClassList.IndexOf(LoadClassName) = -1)
             and (not SilentMode)
             and (MessageBox(0, PChar('При загрузке из потока встречен несуществующий класс: ' + LoadClassName + #13#10#13#10 +
               'Продолжать загрузку?'),
               'Внимание',
            MB_YESNO or MB_ICONEXCLAMATION or MB_TASKMODAL) = IDNO) then
          begin
            raise Exception.Create(GetGsException(Self, 'LoadFromStream: Invalid class name'));
          end
          else
          begin
            AMissingClassList.Add(LoadClassName);
            UnpackedStream.ReadBuffer(ObjDataLen, SizeOf(ObjDataLen));
            UnpackedStream.Seek(ObjDataLen, soFromCurrent);
            Continue;
          end;
        end;

        FDataObject.GetObjectIndex(LoadClassName, LoadSubType, LoadSetTable);

        Dec(I);
      end;

    finally
      AMissingClassList.Free;
    end;

    FLoadingOrderList.LoadFromStream(UnpackedStream);

    while UnpackedStream.Position < UnpackedStream.Size do
    begin
      // загружаем класс и подтип сохраненного объекта
      LoadClassName := StreamReadString(UnpackedStream);
      LoadSubType := StreamReadString(UnpackedStream);
      LoadSetTable := StreamReadString(UnpackedStream);

      ObjectIndex := FDataObject.GetObjectIndex(LoadClassName, LoadSubType, LoadSetTable);

      UnpackedStream.ReadBuffer(I, SizeOf(I));
      MS := TMemoryStream.Create;
      try
        MS.CopyFrom(UnpackedStream, I);
        MS.Position := 0;
        FDataObject.ClientDS[ObjectIndex].LoadFromStream(MS);
      finally
        MS.Free;
      end;
    end;
  finally
    UnpackedStream.Free;
  end;

  for I := 0 to FDataObject.Count - 1 do
    FDataObject.ClientDS[I].Open;

end;

procedure TgdcStreamBinaryWriterReader.SaveToStream(S: TStream);
var
  I, K, CurDBID, CurStrVersion: Integer;
  ID, XID, DBID: Integer;
  PackStream: TZCompressionStream;
  MS: TMemoryStream;
  Obj: TgdcBase;
  IBSQL: TIBSQL;
begin
  // метка потока
  I := cst_StreamLabel;
  S.Write(I, SizeOf(I));
  CurStrVersion := 3;
  S.Write(CurStrVersion, SizeOf(CurStrVersion));
  // DBID
  CurDBID := IBLogin.DBID;
  S.Write(CurDBID, SizeOf(CurDBID));

  PackStream := TZCompressionStream.Create(S, zcMax);
  try
    // если идет инкрементное сохранение
    if FDataObject.TargetBaseKey > -1 then
    begin
      // список баз данных из таблицы RPL_DATABASE
      IBSQL := TIBSQL.Create(nil);
      try
        IBSQL.Database := gdcBaseManager.Database;
        IBSQL.Transaction := gdcBaseManager.ReadTransaction;
        IBSQL.SQL.Text := sqlSelectAllBases;
        IBSQL.ExecQuery;
        if not IBSQL.Eof then
        begin
          I := IBSQL.FieldByName('BASESCOUNT').AsInteger;
          PackStream.Write(I, SizeOf(I));
          while not IBSQL.Eof do
          begin
            I := IBSQL.FieldByName('ID').AsInteger;
            PackStream.Write(I, SizeOf(I));
            StreamWriteString(PackStream, IBSQL.FieldByName('NAME').AsString);
            IBSQL.Next;
          end;
        end;
      finally
        IBSQL.Free;
      end;
      // ID (из таблицы RPL_DATABASE) посылающей поток базы
      PackStream.Write(FDataObject.OurBaseKey, SizeOf(FDataObject.OurBaseKey));
      // ID (из таблицы RPL_DATABASE) принимающей поток базы
      PackStream.Write(FDataObject.TargetBaseKey, SizeOf(FDataObject.TargetBaseKey));
      // здесь запишем RUID'ы записей, получение которых мы подтверждаем
      I := FDataObject.ReceivedRecordsCount;
      PackStream.Write(I, SizeOf(I));
      for K := 0 to I - 1 do
      begin
        XID := FDataObject.ReceivedRecord[K].XID;
        PackStream.Write(XID, SizeOf(XID));
        DBID := FDataObject.ReceivedRecord[K].DBID;
        PackStream.Write(DBID, SizeOf(DBID));
      end;
    end
    else
    begin
      I := 0;
      // RPL_DATABASE
      PackStream.Write(I, SizeOf(I));
      I := -1;
      // OurBaseKey
      PackStream.Write(I, SizeOf(I));
      // TargetBaseKey
      PackStream.Write(I, SizeOf(I));
      I := 0;
      // ReceivedRecords
      PackStream.Write(I, SizeOf(I));
    end;

    // здесь запишем RUID'ы и ID записей, которые не пошли в инкрементный поток
    // т.к. они присутствуют на целевой базе
    I := FDataObject.ReferencedRecordsCount;
    PackStream.Write(I, SizeOf(I));
    for K := 0 to I - 1 do
    begin
      ID := FDataObject.ReferencedRecord[K].SourceID;
      PackStream.Write(ID, SizeOf(ID));
      XID := FDataObject.ReferencedRecord[K].RUID.XID;
      PackStream.Write(XID, SizeOf(XID));
      DBID := FDataObject.ReferencedRecord[K].RUID.DBID;
      PackStream.Write(DBID, SizeOf(DBID));
    end;

    // список бизнес-объектов из пула объектов
    PackStream.Write(FDataObject.Count, SizeOf(FDataObject.Count));
    for K := 0 to FDataObject.Count - 1 do
    begin
      Obj := FDataObject.gdcObject[K];
      StreamWriteString(PackStream, Obj.ClassName);
      StreamWriteString(PackStream, Obj.SubType);
      StreamWriteString(PackStream, Obj.SetTable);
    end;

    // очередь загрузки записей, сохраненных в данном потоке
    FLoadingOrderList.SaveToStream(PackStream);

    //Версия потока не ниже 2
    MS := TMemoryStream.Create;
    try
      for K := 0 to FDataObject.Count - 1 do
      begin
        if FDataObject.ClientDS[K].RecordCount > 0 then
        begin
          Obj := FDataObject.gdcObject[K];

          StreamWriteString(PackStream, Obj.ClassName);
          StreamWriteString(PackStream, Obj.SubType);
          StreamWriteString(PackStream, Obj.SetTable);

          try
            MS.Clear;
            FDataObject.ClientDS[K].SaveToStream(MS, dfBinary);
          except
            MessageBox(0,
              'В процессе сохранения в поток возникла ошибка. Перезагрузите программу.',
              'Внимание',
              MB_OK or MB_ICONHAND or MB_TASKMODAL);
            Abort;
          end;
          I := MS.Size;
          PackStream.Write(I, SizeOf(I));
          PackStream.CopyFrom(MS, 0);
        end;
      end;
    finally
      MS.Free;
    end;
  finally
    PackStream.Free;
  end;
end;

procedure TgdcStreamBinaryWriterReader.LoadStorageFromStream(const S: TStream; AnStAnswer: Word);
var
  StorageName, Path: String;
  NewFolder: TgsStorageFolder;
  BranchName: String;
  L, P: Integer;
  LStorage: TgsStorage;
  OldPos: Integer;
  cstValue: String;
  NeedLoad: Boolean;
begin
  // Пока сделаем загрузку сразу на базу, потом надо будет передать
  //  запись хранилища в базу классу TgdcStreamDataProvider, а здесь грузить только в память
  LStorage := nil;

  while S.Position < S.Size do
  begin
    OldPos := S.Position;
    SetLength(cstValue, Length(cst_StreamValue));
    S.ReadBuffer(cstValue[1], Length(cst_StreamValue));
    if cstValue = cst_StreamValue then
    begin
      S.ReadBuffer(L, SizeOf(L));
      SetLength(cstValue, L);
      S.ReadBuffer(cstValue[1], L);
    end else
    begin
      cstValue := '';
      S.Position := OldPos;
    end;
    // Считываем Хранилище
    S.ReadBuffer(L, SizeOf(L));
    SetLength(BranchName, L);
    S.ReadBuffer(BranchName[1], L);
    P := Pos('\', BranchName);
    if P = 0 then
    begin
      Path := '';
      StorageName := BranchName;
    end else
    begin
      Path := System.Copy(BranchName, P, Length(BranchName) - P + 1);
      StorageName := AnsiUpperCase(System.Copy(BranchName, 1, P - 1));
    end;

    if AnsiPos(st_root_Global, StorageName) = 1 then
    begin
      if LStorage <> GlobalStorage then
      begin
        GlobalStorage.CloseFolder(GlobalStorage.OpenFolder('', False, True), False);
        LStorage := GlobalStorage;
      end;
    end else if AnsiPos(st_root_User, StorageName) = 1 then
    begin
      if LStorage <> UserStorage then
      begin
        UserStorage.CloseFolder(UserStorage.OpenFolder('', False, True), False);
        LStorage := UserStorage;
      end;
    end else
      LStorage := nil;

    NeedLoad := True;
    if LStorage = nil then
    begin
      NewFolder := nil;
    end else
    begin
      if ((AnsiCompareText(st_ds_DFMPath, Path) = 0) or (AnsiCompareText(st_ds_NewFormPath, Path) = 0))
         and (cstValue = '') and (LStorage.FolderExists(Path, False)) then
      begin
        if not SilentMode then
          MessageBox(0,
            PChar('Ветка хранилища "' + Path + '" уже существует в базе.'#13#10 +
            'Ее замена содержимым настройки может привести к потере данных.'#13#10 +
            'Загрузка ветки отменена!'),
            'Внимание',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
        NeedLoad := False;
      end
      else
        if ((AnsiPos(st_ds_DFMPath, Path) = 1) or (AnsiPos(st_ds_NewFormPath, Path) = 1))
           and ((cstValue > '') and (LStorage.ValueExists(Path, cstValue, False))
           or (cstValue = '') and (LStorage.FolderExists(Path, False))) then
        begin
          case AnStAnswer of
            mrYesToAll: NeedLoad := True;
            mrNoToAll: NeedLoad := False;
          else
            if not SilentMode then
              AnStAnswer := MessageDlg('Форма "' + Path + '\' + cstValue + '" уже настроена.'#13#10 +
                'Заменить настройки формы? ', mtConfirmation,
                [mbYes, mbYesToAll, mbNo, mbNoToAll], 0)
            else
              AnStAnswer := mrYes;
            case AnStAnswer of
              mrYes, mrYesToAll: NeedLoad := True;
            else
              NeedLoad := False;
            end;
          end;
        end
        else
          NeedLoad := True;

      if NeedLoad then
        NewFolder := LStorage.OpenFolder(Path, True, False)
      else
        NewFolder := nil;
    end;

    if NeedLoad then
    begin
      if Assigned(NewFolder) then
      begin
        if cstValue > '' then
        begin
          NewFolder.AddValueFromStream(cstValue, S);
          Space;
          if StreamLoggingType = slAll then
            AddText('Загрузка параметра "' + cstValue + '" ветки хранилища "' + StorageName + Path + '"'#13#10, clBlue);
        end else
        begin
          NewFolder.LoadFromStream(S);
          Space;
          if StreamLoggingType = slAll then
            AddText('Загрузка ветки хранилища "' + StorageName + Path + '"'#13#10, clBlue);
        end;
        LStorage.CloseFolder(NewFolder, False);
        LStorage.IsModified := True;
      end
      else
      begin
        AddMistake('Ошибка при считывании данных хранилища!', clRed);
        Space;
        raise Exception.Create('Ошибка при считывании данных хранилища!');
      end;
    end else
    begin
      if cstValue > '' then
        TgsStorageFolder.SkipValueInStream(S)
      else
        TgsStorageFolder.SkipInStream(S);

      if Assigned(NewFolder) then
        LStorage.CloseFolder(NewFolder, False);
    end;
  end;
end;

procedure TgdcStreamBinaryWriterReader.SaveStorageToStream(S: TStream);
var
  I, L: Integer;
  StorageItem: TgsStorageItem;
begin
  if FDataObject.StorageItemList.Count > 0 then
  begin
    FDataObject.StorageItemList.Sort;

    for I := 0 to FDataObject.StorageItemList.Count - 1 do
    begin
      if Assigned(FDataObject.StorageItemList.Objects[I]) then
      begin
        StorageItem := (FDataObject.StorageItemList.Objects[I] as TgsStorageItem);
        if StorageItem is TgsStorageValue then
        begin
          S.WriteBuffer(cst_StreamValue[1], Length(cst_StreamValue));
          L := Length(StorageItem.Name);
          S.WriteBuffer(L, Sizeof(L));
          S.WriteBuffer(StorageItem.Name[1], L);
          L := Length(StorageItem.Parent.Path);
          S.WriteBuffer(L, Sizeof(L));
          S.WriteBuffer(StorageItem.Parent.Path[1], L);
          (StorageItem as TgsStorageValue).SaveToStream(S);
        end
        else
          if StorageItem is TgsStorageFolder then
          begin
            L :=  Length(StorageItem.Path);
            S.WriteBuffer(L, Sizeof(L));
            S.WriteBuffer(StorageItem.Path[1], L);
            (StorageItem as TgsStorageFolder).SaveToStream(S);
          end;
      end;
    end;
  end;
end;



{ TgdcStreamXMLWriterReader }

procedure TgdcStreamXMLWriterReader.LoadFromStream(const S: TStream);
var
  I, J, K: Integer;
  XMLStr: String;
  AMissingClassList: TStringList;
  LoadClassName: TgdcClassName;
  LoadSubType: TgdcSubType;
  LoadSetTable: ShortString;
  C: TClass;
  tempStr_1, tempStr_2: String;
  DatasetStr: String;
  MS: TMemoryStream;
  xmlDatasetHeaderLength, xmlDatasetFooterLength: Integer;
begin
  xmlDatasetHeaderLength := Length(xmlDatasetHeader);
  xmlDatasetFooterLength := Length(xmlDatasetFooter);

  FDataObject.IsSave := False;

  AMissingClassList := TStringList.Create;
  try
    AMissingClassList.Duplicates := dupIgnore;
    AMissingClassList.Sorted := True;

    while S.Position < S.Size do
    begin

      case GetNextElement(S, XMLStr) of

        etVersion:
        begin
          I := StrToInt(GetTextValueOfElement(S, XMLStr));
          FDataObject.StreamVersion := I;
        end;

        etDBID:
        begin
          I := StrToInt(GetTextValueOfElement(S, XMLStr));
          FDataObject.StreamDBID := I;
        end;

        etDatabase:
        begin
          tempStr_1 := GetParamValueByName(XMLStr, 'id');
          tempStr_2 := UnQuoteString(GetParamValueByName(XMLStr, 'name'));
          FDataObject.DatabaseList.Add(tempStr_1 + '=' + tempStr_2);
        end;

        etSender:
        begin
          I := StrToInt(GetTextValueOfElement(S, XMLStr));
          FDataObject.SourceBaseKey := I;
        end;

        etReceiver:
        begin
          I := StrToInt(GetTextValueOfElement(S, XMLStr));
          FDataObject.TargetBaseKey := I;
        end;

        etReceivedRecord:
        begin
          I := GetIntegerParamValueByName(XMLStr, 'xid');
          J := GetIntegerParamValueByName(XMLStr, 'dbid');
          FDataObject.AddReceivedRecord(I, J);
        end;

        etReferencedRecord:
        begin
          I := GetIntegerParamValueByName(XMLStr, 'id');
          J := GetIntegerParamValueByName(XMLStr, 'xid');
          K := GetIntegerParamValueByName(XMLStr, 'dbid');
          FDataObject.AddReferencedRecord(I, J, K);
        end;

        etObject:
        begin
          // загружаем класс и подтип сохраненного объекта
          LoadClassName := UnQuoteString(GetParamValueByName(XMLStr, 'classname'));
          LoadSubType := UnQuoteString(GetParamValueByName(XMLStr, 'subtype'));
          LoadSetTable := UnQuoteString(GetParamValueByName(XMLStr, 'settable'));

          C := GetClass(LoadClassName);

          {Пропускаем класс, если он не найден}
          if C = nil then
          begin
            AddMistake(#13#10 + 'При загрузке из потока встречен несуществующий класс: ' + LoadClassName + #13#10, clRed);
            if (AMissingClassList.IndexOf(LoadClassName) = -1)
               and (not SilentMode)
               and (MessageBox(0, PChar('При загрузке из потока встречен несуществующий класс: ' + LoadClassName + #13#10#13#10 +
                 'Продолжать загрузку?'),
                 'Внимание',
                 MB_YESNO or MB_ICONEXCLAMATION or MB_TASKMODAL) = IDNO) then
            begin
              raise Exception.Create(GetGsException(Self, 'LoadFromStream: Invalid class name'));
            end else
              AMissingClassList.Add(LoadClassName);
          end
          else
            FDataObject.GetObjectIndex(LoadClassName, LoadSubType, LoadSetTable);
        end;

        etOrder:
          FLoadingOrderList.LoadFromStream(S, sttXML);

        etOrderItem:
        begin
          I := GetIntegerParamValueByName(XMLStr, 'dsindex');
          J := GetIntegerParamValueByName(XMLStr, 'recordid');
          FLoadingOrderList.AddItem(J, I);
        end;

        etDataset:
        begin
          I := GetIntegerParamValueByName(XMLStr, 'id');
          DatasetStr := GetTextValueOfElement(S, XMLStr);
          // В настройке мы изменяли форматирование XML который выдает TClientDataset,
          //  теперь вернем его обратно
          DatasetStr := StringReplace(DatasetStr, '>'#13#10'<', '><', [rfReplaceAll]);
          J := Length(DatasetStr);

          DatasetStr := xmlDatasetHeader + DatasetStr + xmlDatasetFooter;

          MS := TMemoryStream.Create;
          try
            MS.WriteBuffer(DatasetStr[1], xmlDatasetHeaderLength + J + xmlDatasetFooterLength);
            MS.Position := 0;
            FDataObject.ClientDS[I].LoadFromStream(MS);
          finally
            MS.Free;
          end;
        end;

      else
        //
      end;

    end;

    for I := 0 to FDataObject.Count - 1 do
      FDataObject.ClientDS[I].Open;

  finally
    AMissingClassList.Free;
  end;

end;

procedure TgdcStreamXMLWriterReader.LoadXMLSettingFromStream(S: TStream);
var
  DataStr: String;
  CDS: TClientDataSet;
  XMLStr: String;
  ModifyDate: TDateTime;
  SettingElementIterator: Integer;
  SettingHeadID: Integer;
begin
  if StreamLoggingType in [slSimple, slAll] then
    AddText(TimeToStr(Time) + ': Началось чтение XML файла.', clBlack);

  ModifyDate := Time;
  CDS := nil;
  SettingHeadID := cstUserIDStart;
  SettingElementIterator := cstUserIDStart;

  FDataObject.IsSave := False;
  FDataObject.Add('TgdcSetting', '', '', True);
  FDataObject.Add('TgdcSettingPos', '', '', True);
  FDataObject.Add('TgdcSettingStorage', '', '', True);

  while S.Position < S.Size do
  begin
    case GetNextElement(S, XMLStr) of

      etSettingHeader:
      begin
        SettingHeadID := SettingElementIterator;
        CDS := FDataObject.ClientDS[0];       // TgdcSetting
        CDS.Insert;
        CDS.FieldByName('ID').AsString := IntToStr(SettingHeadID);
        CDS.FieldByName('NAME').AsString := UnQuoteString(GetParamValueByName(XMLStr, 'name'));
        CDS.FieldByName('VERSION').AsString := GetParamValueByName(XMLStr, 'version');
        CDS.FieldByName('MODIFYDATE').AsString := GetParamValueByName(XMLStr, 'modifydate');
        CDS.FieldByName('DESCRIPTION').AsString := UnQuoteString(GetParamValueByName(XMLStr, 'description'));
        CDS.FieldByName('ENDING').AsString := GetParamValueByName(XMLStr, 'ending');
        CDS.FieldByName('SETTINGSRUID').AsString := GetParamValueByName(XMLStr, 'settingsruid');
        CDS.FieldByName('MINEXEVERSION').AsString := GetParamValueByName(XMLStr, 'minexeversion');
        CDS.FieldByName('MINDBVERSION').AsString := GetParamValueByName(XMLStr, 'mindbversion');
        CDS.FieldByName('_XID').AsString := GetParamValueByName(XMLStr, 'xid');
        CDS.FieldByName('_DBID').AsString := GetParamValueByName(XMLStr, 'dbid');
        CDS.FieldByName('_MODIFIED').AsDateTime := CDS.FieldByName('MODIFYDATE').AsDateTime;
        CDS.Post;
        FLoadingOrderList.AddItem(SettingHeadID, 0);
        Inc(SettingElementIterator);
      end;

      etSettingPosList:
        CDS := FDataObject.ClientDS[1];       // TgdcSettingPos

      etSettingPos:
      begin
        if Assigned(CDS) then
        begin
          CDS.Insert;
          CDS.FieldByName('ID').AsString := IntToStr(SettingElementIterator);
          CDS.FieldByName('SETTINGKEY').AsString := IntToStr(SettingHeadID);
          CDS.FieldByName('CATEGORY').AsString := UnQuoteString(GetParamValueByName(XMLStr, 'category'));
          CDS.FieldByName('OBJECTNAME').AsString := UnQuoteString(GetParamValueByName(XMLStr, 'objectname'));
          CDS.FieldByName('MASTERCATEGORY').AsString := UnQuoteString(GetParamValueByName(XMLStr, 'mastercategory'));
          CDS.FieldByName('MASTERNAME').AsString := UnQuoteString(GetParamValueByName(XMLStr, 'mastername'));
          CDS.FieldByName('OBJECTORDER').AsString := GetParamValueByName(XMLStr, 'objectorder');
          CDS.FieldByName('WITHDETAIL').AsString := GetParamValueByName(XMLStr, 'withdetail');
          CDS.FieldByName('NEEDMODIFY').AsString := GetParamValueByName(XMLStr, 'needmodify');
          CDS.FieldByName('AUTOADDED').AsString := GetParamValueByName(XMLStr, 'autoadded');
          CDS.FieldByName('OBJECTCLASS').AsString := UnQuoteString(GetParamValueByName(XMLStr, 'objectclass'));
          CDS.FieldByName('SUBTYPE').AsString := UnQuoteString(GetParamValueByName(XMLStr, 'subtype'));
          CDS.FieldByName('XID').AsString := GetParamValueByName(XMLStr, 'xid');
          CDS.FieldByName('DBID').AsString := GetParamValueByName(XMLStr, 'dbid');
          CDS.FieldByName('_XID').AsString := GetParamValueByName(XMLStr, '_xid');
          CDS.FieldByName('_DBID').AsString := GetParamValueByName(XMLStr, '_dbid');
          CDS.FieldByName('_MODIFIED').AsDateTime := ModifyDate;
          CDS.Post;
          FLoadingOrderList.AddItem(SettingElementIterator, 1);
          Inc(SettingElementIterator);
        end
        else
        begin
          raise EgsClientDatasetNotFound.Create('Не найден датасет при загрузке позиции настройки');
        end;
      end;

      etStoragePosList:
        CDS := FDataObject.ClientDS[2];       // TgdcSettingStorage

      etStoragePos:
      begin
        if Assigned(CDS) then
        begin
          CDS.Insert;
          CDS.FieldByName('ID').AsString := IntToStr(SettingElementIterator);
          CDS.FieldByName('SETTINGKEY').AsString := IntToStr(SettingHeadID);
          CDS.FieldByName('BRANCHNAME').AsString := UnQuoteString(GetParamValueByName(XMLStr, 'branchname'));
          CDS.FieldByName('VALUENAME').AsString := UnQuoteString(GetParamValueByName(XMLStr, 'valuename'));
          CDS.FieldByName('CRC').AsString := GetParamValueByName(XMLStr, 'crc');
          CDS.FieldByName('_XID').AsString := GetParamValueByName(XMLStr, '_xid');
          CDS.FieldByName('_DBID').AsString := GetParamValueByName(XMLStr, '_dbid');
          CDS.FieldByName('_MODIFIED').AsDateTime := ModifyDate;
          CDS.Post;
          FLoadingOrderList.AddItem(SettingElementIterator, 2);
          Inc(SettingElementIterator);
        end
        else
        begin
          raise EgsClientDatasetNotFound.Create('Не найден датасет при загрузке позиции хранилища в настройке');
        end;
      end;

      etSettingData:
      begin
        DataStr := GetTextValueOfElement(S, XMLStr);

        CDS := FDataObject.ClientDS[0];
        CDS.Edit;
        CDS.FieldByName('DATA').AsString := xmlHeader + #13#10 + Trim(DataStr);
        CDS.Post;
      end;

      etSettingStorage:
      begin
        DataStr := GetTextValueOfElement(S, XMLStr);

        CDS := FDataObject.ClientDS[0];
        CDS.Edit;
        CDS.FieldByName('STORAGEDATA').AsString := Trim(DataStr);
        CDS.Post;
      end;
      
    end;
  end;

  if StreamLoggingType in [slSimple, slAll] then
    AddText(TimeToStr(Time) + ': Закончилось чтение XML файла.', clBlack);
end;

procedure TgdcStreamXMLWriterReader.SaveToStream(S: TStream);
var
  I, K: Integer;
  xmlDatasetHeaderLength, xmlDatasetFooterLength: Integer;
  MS: TMemoryStream;
  Obj: TgdcBase;
  IBSQL: TIBSQL;
  DataStr: String;
begin
  xmlDatasetHeaderLength := Length(xmlDatasetHeader);
  xmlDatasetFooterLength := Length(xmlDatasetFooter);

  // Заголовок XML-документа
  StreamWriteXMLString(S, xmlHeader + NEW_LINE);
  // Откроем корневой тег документа
  StreamWriteXMLString(S, AddOpenTag(XML_TAG_STREAM));
  StreamWriteXMLString(S, AddOpenTag(XML_TAG_HEADER));
  // Версия потока
  StreamWriteXMLString(S, AddOpenTag(XML_TAG_VERSION, true) + '3' + AddCloseTag(XML_TAG_VERSION, true));
  // DBID
  StreamWriteXMLString(S, AddOpenTag(XML_TAG_DBID, true) + IntToStr(IBLogin.DBID) + AddCloseTag(XML_TAG_DBID, true));

  // Если идет инкрементное сохранение
  if FDataObject.TargetBaseKey > -1 then
  begin
    // Список баз данных из таблицы RPL_DATABASE
    IBSQL := TIBSQL.Create(nil);
    try
      IBSQL.Database := gdcBaseManager.Database;
      IBSQL.Transaction := gdcBaseManager.ReadTransaction;
      IBSQL.SQL.Text := sqlSelectAllBases;
      IBSQL.ExecQuery;
      if not IBSQL.Eof then
      begin
        StreamWriteXMLString(S, AddOpenTag(XML_TAG_DATABASE_LIST));
        while not IBSQL.Eof do
        begin
          StreamWriteXMLString(S,
            AddOpenTag(XML_TAG_DATABASE, false, true) +
            AddAttribute('id', IntToStr(IBSQL.FieldByName('ID').AsInteger)) +
            AddAttribute('name', QuoteString(IBSQL.FieldByName('NAME').AsString), true) +
            AddCloseTag(XML_TAG_DATABASE, false, true));
          IBSQL.Next;
        end;
        StreamWriteXMLString(S, AddCloseTag(XML_TAG_DATABASE_LIST));
      end;
    finally
      IBSQL.Free;
    end;

    // ID (из таблицы RPL_DATABASE) посылающей поток базы
    StreamWriteXMLString(S,
      AddOpenTag(XML_TAG_SENDER, true) +
      IntToStr(FDataObject.OurBaseKey) +
      AddCloseTag(XML_TAG_SENDER, true));

    // ID (из таблицы RPL_DATABASE) принимающей поток базы
    StreamWriteXMLString(S,
      AddOpenTag(XML_TAG_RECEIVER, true) +
      IntToStr(FDataObject.TargetBaseKey) +
      AddCloseTag(XML_TAG_RECEIVER, true));

    // Здесь запишем RUID'ы записей, получение которых мы подтверждаем
    I := FDataObject.ReceivedRecordsCount;
    if I > 0 then
    begin
      StreamWriteXMLString(S, AddOpenTag(XML_TAG_RECEIVED_RECORD_LIST));
      for K := 0 to I - 1 do
        StreamWriteXMLString(S,
          AddOpenTag(XML_TAG_RECEIVED_RECORD, false, true) +
          AddAttribute('xid', IntToStr(FDataObject.ReceivedRecord[K].XID)) +
          AddAttribute('dbid', IntToStr(FDataObject.ReceivedRecord[K].DBID), true) +
          AddCloseTag(XML_TAG_RECEIVED_RECORD, false, true));
      StreamWriteXMLString(S, AddCloseTag(XML_TAG_RECEIVED_RECORD_LIST));
    end;
  end;

  // Здесь запишем RUID'ы и ID записей, которые не пошли в инкрементный поток,
  //   т.к. они присутствуют на целевой базе
  I := FDataObject.ReferencedRecordsCount;
  if I > 0 then
  begin
    StreamWriteXMLString(S, AddOpenTag(XML_TAG_REFERENCED_RECORD_LIST));
    for K := 0 to I - 1 do
      StreamWriteXMLString(S,
        AddOpenTag(XML_TAG_REFERENCED_RECORD, false, true) +
        AddAttribute('id', IntToStr(FDataObject.ReferencedRecord[K].SourceID)) +
        AddAttribute('xid', IntToStr(FDataObject.ReferencedRecord[K].RUID.XID)) +
        AddAttribute('dbid', IntToStr(FDataObject.ReferencedRecord[K].RUID.DBID), true) +
        AddCloseTag(XML_TAG_REFERENCED_RECORD, false, true));
    StreamWriteXMLString(S, AddCloseTag(XML_TAG_REFERENCED_RECORD_LIST));
  end;

  // Список бизнес-объектов из пула объектов
  StreamWriteXMLString(S, AddOpenTag(XML_TAG_OBJECT_LIST));
  for K := 0 to FDataObject.Count - 1 do
  begin
    Obj := FDataObject.gdcObject[K];
    StreamWriteXMLString(S,
      AddOpenTag(XML_TAG_OBJECT, false, true) +
      AddAttribute('id', IntToStr(K)) +
      AddAttribute('classname', QuoteString(Obj.ClassName)) +
      AddAttribute('subtype', QuoteString(Obj.SubType)) +
      AddAttribute('settable', QuoteString(Obj.SetTable), true) +
      AddCloseTag(XML_TAG_OBJECT, false, true));
  end;
  StreamWriteXMLString(S, AddCloseTag(XML_TAG_OBJECT_LIST));

  // Очередь загрузки записей, сохраненных в данном потоке
  StreamWriteXMLString(S, AddOpenTag(XML_TAG_LOADING_ORDER));
  with FLoadingOrderList do
    for K := 0 to Count - 1 do
      StreamWriteXMLString(S,
        AddOpenTag(XML_TAG_LOADING_ORDER_ITEM, false, true) +
        AddAttribute('index', IntToStr(Items[K].Index)) +
        AddAttribute('dsindex', IntToStr(Items[K].DSIndex)) +
        AddAttribute('recordid', IntToStr(Items[K].RecordID), true) +
        AddCloseTag(XML_TAG_LOADING_ORDER_ITEM, false, true));
  StreamWriteXMLString(S, AddCloseTag(XML_TAG_LOADING_ORDER));

  // Закроем тег заголовка документа
  StreamWriteXMLString(S, AddCloseTag(XML_TAG_HEADER));

  // Откроем тег данных документа
  StreamWriteXMLString(S, AddOpenTag(XML_TAG_DATA));
  MS := TMemoryStream.Create;
  try
    for K := 0 to FDataObject.Count - 1 do
    begin
      if FDataObject.ClientDS[K].RecordCount > 0 then
      begin
        try
          MS.Clear;
          FDataObject.ClientDS[K].SaveToStream(MS, dfXML);
        except
          MessageBox(0,
            'В процессе сохранения в поток возникла ошибка. Перезагрузите программу.',
            'Внимание',
            MB_OK or MB_ICONHAND or MB_TASKMODAL);
          Abort;
        end;

        SetLength(DataStr, MS.Size - xmlDatasetHeaderLength - xmlDatasetFooterLength);
        MS.Seek(xmlDatasetHeaderLength, soFromBeginning);
        MS.ReadBuffer(DataStr[1], MS.Size - xmlDatasetHeaderLength - xmlDatasetFooterLength);
        
        DataStr := StringReplace(DataStr, '><', '>'#13#10'<', [rfReplaceAll]);

        StreamWriteXMLString(S,
          AddOpenTag(XML_TAG_DATASET, false, true) +
          AddAttribute('id', IntToStr(K)) +
          AddAttribute('classname', QuoteString(FDataObject.gdcObject[K].Classname)) +
          AddAttribute('subtype', QuoteString(FDataObject.gdcObject[K].SubType)) +
          AddAttribute('settable', QuoteString(FDataObject.ClientDS[K].FieldByName('_SETTABLE').AsString), true) +
          '>' + NEW_LINE);

        StreamWriteXMLString(S, DataStr + NEW_LINE);
        //SaveDataset(S, FDataObject.ClientDS[K]);

        StreamWriteXMLString(S, AddCloseTag(XML_TAG_DATASET));
      end;
    end;
  finally
    MS.Free;
  end;
  // Закроем тег данных документа
  StreamWriteXMLString(S, AddCloseTag(XML_TAG_DATA));
  // Закроем корневой тег документа
  StreamWriteXMLString(S, AddCloseTag(XML_TAG_STREAM));
end;

(*
procedure TgdcStreamXMLWriterReader.SaveDataset(S: TStream; CDS: TClientDataSet);
const
  XML_TAG_FIELD_LIST = 'FIELD_LIST';
  XML_TAG_FIELD = 'FIELD';
  XML_TAG_ROW_LIST = 'ROW_LIST';
  XML_TAG_ROW = 'ROW';
var
  I: Integer;
  FD: TFieldDef;
  IsLastAttribute: Boolean;
begin
  // Список полей датасета
  StreamWriteXMLString(S, AddOpenTag(XML_TAG_FIELD_LIST));
  for I := 0 to CDS.FieldDefs.Count - 1 do
  begin
    FD := CDS.FieldDefs[I];
    if (not (DB.faReadOnly in FD.Attributes))
      and (not FD.InternalCalcField)
      and (FD.Name <> 'AFULL')
      and (FD.Name <> 'ACHAG')
      and (FD.Name <> 'AVIEW') then
    begin
      StreamWriteXMLString(S, AddOpenTag(XML_TAG_FIELD, false, true) +
        AddAttribute('name', FD.Name) +
        IIF(AnsiPos('$' ,FD.Name) > 0, AddAttribute('attrname', StringReplace(CDS.Fields[I].FieldName, '$', '_', [rfReplaceAll])), '') +
        AddAttribute('type', 'ftString') +
        IIF(FD.Required, AddAttribute('required', 'true'), '') +
        AddAttribute('width', IntToStr(FD.Size), true) +
        AddCloseTag(XML_TAG_FIELD, false, true));
    end;
  end;
  StreamWriteXMLString(S, AddCloseTag(XML_TAG_FIELD_LIST));
  // Список записей датасета
  StreamWriteXMLString(S, AddOpenTag(XML_TAG_ROW_LIST));
  CDS.First;
  while not CDS.Eof do
  begin
    IsLastAttribute := false;
    StreamWriteXMLString(S, AddOpenTag(XML_TAG_ROW, false, true));
    for I := 0 to CDS.FieldCount - 1 do
    begin
      if I = CDS.FieldCount - 1 then
        IsLastAttribute := true;
      if not CDS.Fields[I].IsNull then
        StreamWriteXMLString(S,
          AddAttribute(AnsiLowerCase(StringReplace(CDS.Fields[I].FieldName, '$', '_', [rfReplaceAll])),
            QuoteString(CDS.Fields[I].AsString), IsLastAttribute));
    end;
    StreamWriteXMLString(S, AddCloseTag(XML_TAG_ROW, false, true));
    CDS.Next;
  end;
  StreamWriteXMLString(S, AddCloseTag(XML_TAG_ROW_LIST));
end;
*)

function TgdcStreamXMLWriterReader.GetNextElement(const St: TStream; out ElementStr: String): TXMLElementType;
var
  TempStr: AnsiChar;
begin
  Result := etUnknown;
  TempStr := Chr(0);
  while (TempStr <> '<') and (St.Position < St.Size) do
    St.ReadBuffer(TempStr, SizeOf(TempStr));

  ElementStr := TempStr;

  TempStr := Chr(0);
  while (TempStr <> '>') and (St.Position < St.Size) do
  begin
    St.ReadBuffer(TempStr, SizeOf(TempStr));
    ElementStr := ElementStr + TempStr;
  end;

  if AnsiCompareText(ElementStr, '<' + XML_TAG_STREAM + '>') = 0 then
  begin
    Result := etStream;
    Exit;
  end;

  if AnsiCompareText(ElementStr, '<' + XML_TAG_VERSION + '>') = 0 then
  begin
    Result := etVersion;
    Exit;
  end;

  if AnsiCompareText(ElementStr, '<' + XML_TAG_DBID + '>') = 0 then
  begin
    Result := etDBID;
    Exit;
  end;

  if AnsiCompareText(ElementStr, '<' + XML_TAG_DATABASE_LIST + '>') = 0 then
  begin
    Result := etDataBaseList;
    Exit;
  end;

  if AnsiCompareText(Copy(ElementStr, 0, 10), '<' + XML_TAG_DATABASE + ' ') = 0 then
  begin
    Result := etDataBase;
    Exit;
  end;

  if AnsiCompareText(ElementStr, '<' + XML_TAG_SENDER + '>') = 0 then
  begin
    Result := etSender;
    Exit;
  end;

  if AnsiCompareText(ElementStr, '<' + XML_TAG_RECEIVER + '>') = 0 then
  begin
    Result := etReceiver;
    Exit;
  end;

  if AnsiCompareText(ElementStr, '<' + XML_TAG_RECEIVED_RECORD_LIST + '>') = 0 then
  begin
    Result := etReceivedRecordList;
    Exit;
  end;

  if AnsiCompareText(Copy(ElementStr, 0, 17), '<' + XML_TAG_RECEIVED_RECORD + ' ') = 0 then
  begin
    Result := etReceivedRecord;
    Exit;
  end;

  if AnsiCompareText(ElementStr, '<' + XML_TAG_REFERENCED_RECORD_LIST + '>') = 0 then
  begin
    Result := etReferencedRecordList;
    Exit;
  end;

  if AnsiCompareText(Copy(ElementStr, 0, 19), '<' + XML_TAG_REFERENCED_RECORD + ' ') = 0 then
  begin
    Result := etReferencedRecord;
    Exit;
  end;

  if AnsiCompareText(ElementStr, '<' + XML_TAG_OBJECT_LIST + '>') = 0 then
  begin
    Result := etObjectList;
    Exit;
  end;

  if AnsiCompareText(Copy(ElementStr, 0, 8), '<' + XML_TAG_OBJECT + ' ') = 0 then
  begin
    Result := etObject;
    Exit;
  end;

  if AnsiCompareText(ElementStr, '<' + XML_TAG_LOADING_ORDER + '>') = 0 then
  begin
    Result := etOrder;
    Exit;
  end;

  if AnsiCompareText(Copy(ElementStr, 0, 6), '<' + XML_TAG_LOADING_ORDER_ITEM + ' ') = 0 then
  begin
    Result := etOrderItem;
    Exit;
  end;

  if AnsiCompareText(ElementStr, '<' + XML_TAG_DATA + '>') = 0 then
  begin
    Result := etData;
    Exit;
  end;

  if AnsiCompareText(Copy(ElementStr, 0, 9), '<' + XML_TAG_DATASET + ' ') = 0 then
  begin
    Result := etDataset;
    Exit;
  end;

  if AnsiCompareText(ElementStr, '<' + XML_TAG_SETTING + '>') = 0 then
  begin
    Result := etSetting;
    Exit;
  end;

  if AnsiCompareText(Copy(ElementStr, 0, 16), '<' + XML_TAG_SETTING_HEADER + ' ') = 0 then
  begin
    Result := etSettingHeader;
    Exit;
  end;

  if AnsiCompareText(ElementStr, '<' + XML_TAG_SETTING_POS_LIST + '>') = 0 then
  begin
    Result := etSettingPosList;
    Exit;
  end;

  if AnsiCompareText(Copy(ElementStr, 0, 13), '<' + XML_TAG_SETTING_POS + ' ') = 0 then
  begin
    Result := etSettingPos;
    Exit;
  end;

  if AnsiCompareText(ElementStr, '<' + XML_TAG_STORAGE_POS_LIST + '>') = 0 then
  begin
    Result := etStoragePosList;
    Exit;
  end;

  if AnsiCompareText(Copy(ElementStr, 0, 13), '<' + XML_TAG_STORAGE_POS + ' ') = 0 then
  begin
    Result := etStoragePos;
    Exit;
  end;

  if AnsiCompareText(ElementStr, '<' + XML_TAG_SETTING_DATA + '>') = 0 then
  begin
    Result := etSettingData;
    Exit;
  end;

  if AnsiCompareText(ElementStr, '<' + XML_TAG_SETTING_STORAGE + '>') = 0 then
  begin
    Result := etSettingStorage;
    Exit;
  end;

  if AnsiCompareText(Copy(ElementStr, 0, 9), '<' + XML_TAG_STORAGE + ' ') = 0 then
  begin
    Result := etStorage;
    Exit;
  end;

  if AnsiCompareText(Copy(ElementStr, 0, 16), '<' + XML_TAG_STORAGE_FOLDER + ' ') = 0 then
  begin
    Result := etStorageFolder;
    Exit;
  end;

  if AnsiCompareText(Copy(ElementStr, 0, 15), '<' + XML_TAG_STORAGE_VALUE + ' ') = 0 then
  begin
    Result := etStorageValue;
    Exit;
  end;
end;

function TgdcStreamXMLWriterReader.GetPositionOfString(S: TStream; Str: String): Integer;
var
  OldPosition: Integer;
  Position: Integer;
  TempChar: String;
  TempStr: String;
begin
  Result := -1;
  OldPosition := S.Position;
  SetLength(TempChar, 100);

  while S.Position < S.Size do
  begin
    S.Read(TempChar[1], 100);
    TempStr := TempStr + TempChar;
    Position := AnsiPos(AnsiUpperCase(Str), AnsiUpperCase(TempStr));
    if Position > 0 then
    begin
      Result := OldPosition + Position - 1;
      Break;
    end;
  end;
  
  S.Position := OldPosition;
end;

function TgdcStreamXMLWriterReader.GetTextValueOfElement(const St: TStream; const ElementHeader: String): String;
var
  TempChar: AnsiChar;
  TempStr: String;
  ElementName: String;
  ElementTextEndPosition: Integer;
begin
  Result := '';

  if AnsiPos(' ', ElementHeader) > 0 then
    ElementName := System.Copy(ElementHeader, AnsiPos('<', ElementHeader) + 1,
      AnsiPos(' ', ElementHeader) - AnsiPos('<', ElementHeader) - 1)
  else
    ElementName := System.Copy(ElementHeader, AnsiPos('<', ElementHeader) + 1,
      AnsiPos('>', ElementHeader) - AnsiPos('<', ElementHeader) - 1);

  ElementTextEndPosition := Self.GetPositionOfString(St, '</' + ElementName + '>');
  if ElementTextEndPosition > 0 then
  begin
    SetLength(TempStr, ElementTextEndPosition - St.Position);
    St.ReadBuffer(TempStr[1], ElementTextEndPosition - St.Position);
    Result := TempStr;
  end
  else
  begin
    St.ReadBuffer(TempChar, SizeOf(TempChar));
    if TempChar <> '<' then
      while (TempChar <> '<') and (St.Position < St.Size) do
      begin
        Result := Result + TempChar;
        St.ReadBuffer(TempChar, SizeOf(TempChar));
      end;
  end;
end;

function TgdcStreamXMLWriterReader.GetParamValueByName(const Str, ParamName: String): String;
var
  I, J, K: Integer;
begin
  Result := '';
  I := AnsiPos(AnsiUpperCase(ParamName), AnsiUpperCase(Str)) + Length(ParamName) + 2;
  J := I;
  for K := J to Length(Str) - 1 do
    if Str[K] = '"' then
    begin
      J := K;
      Break;
    end;
  if J > I then
    Result := Trim(Copy(Str, I, J - I));
end;

function TgdcStreamXMLWriterReader.GetIntegerParamValueByName(const Str, ParamName: String): Integer;
var
  TempStr: String;
begin
  TempStr := GetParamValueByName(Str, ParamName);
  if TempStr = '' then
    Result := 0
  else
    try
      Result := StrToInt(TempStr);
    except
      Result := 0;
    end;
end;

procedure TgdcStreamXMLWriterReader.SaveXMLSettingToStream(S: TStream);
var
  DataStr, StorageDataStr: String;
  CDS: TClientDataSet;

  function SkipToStreamTag(Str: String): String;
  var
    I: Integer;
  begin
    I := AnsiPos('<' + XML_TAG_STREAM + '>', AnsiUpperCase(Str));
    Result := Copy(Str, I, Length(Str));
  end;

begin
  // заголовок XML-документа
  StreamWriteXMLString(S, xmlHeader + NEW_LINE);
  // Откроем корневой тег документа
  StreamWriteXMLString(S, AddOpenTag(XML_TAG_SETTING));
  CDS := FDataObject.ClientDS[FDataObject.GetObjectIndex('TgdcSetting', '')];
  // Откроем тег заголовка настройки
  StreamWriteXMLString(S,
    AddOpenTag(XML_TAG_SETTING_HEADER, false, true) +
    AddAttribute('name', QuoteString(CDS.FieldByName('NAME').AsString)) +
    AddAttribute('version', CDS.FieldByName('VERSION').AsString) +
    AddAttribute('modifydate', CDS.FieldByName('MODIFYDATE').AsString) +
    AddAttribute('xid', CDS.FieldByName('_XID').AsString) +
    AddAttribute('dbid', CDS.FieldByName('_DBID').AsString) +
    AddAttribute('description', QuoteString(CDS.FieldByName('DESCRIPTION').AsString)) +
    AddAttribute('ending', CDS.FieldByName('ENDING').AsString) +
    AddAttribute('settingsruid', CDS.FieldByName('SETTINGSRUID').AsString) +
    AddAttribute('minexeversion', CDS.FieldByName('MINEXEVERSION').AsString) +
    AddAttribute('mindbversion', CDS.FieldByName('MINDBVERSION').AsString, true) +
    '>' + NEW_LINE);

  // Позиции данных настройки
  StreamWriteXMLString(S, AddOpenTag(XML_TAG_SETTING_POS_LIST));
  CDS := FDataObject.ClientDS[FDataObject.GetObjectIndex('TgdcSettingPos', '')];
  if not CDS.IsEmpty then
  begin
    CDS.IndexFieldNames := 'OBJECTORDER';
    CDS.First;
    while not CDS.Eof do
    begin
      StreamWriteXMLString(S,
        AddOpenTag(XML_TAG_SETTING_POS, false, true) +
        AddAttribute('category', QuoteString(CDS.FieldByName('CATEGORY').AsString)) +
        AddAttribute('objectname', QuoteString(CDS.FieldByName('OBJECTNAME').AsString)) +
        AddAttribute('mastercategory', QuoteString(CDS.FieldByName('MASTERCATEGORY').AsString)) +
        AddAttribute('mastername', QuoteString(CDS.FieldByName('MASTERNAME').AsString)) +
        AddAttribute('objectorder', CDS.FieldByName('OBJECTORDER').AsString) +
        AddAttribute('withdetail', CDS.FieldByName('WITHDETAIL').AsString) +
        AddAttribute('needmodify', CDS.FieldByName('NEEDMODIFY').AsString) +
        IIF(Assigned(atDatabase.FindRelationField('AT_SETTINGPOS', 'AUTOADDED')),
          AddAttribute('autoadded', CDS.FieldByName('AUTOADDED').AsString), '') +
        AddAttribute('objectclass', QuoteString(CDS.FieldByName('OBJECTCLASS').AsString)) +
        AddAttribute('subtype', QuoteString(CDS.FieldByName('SUBTYPE').AsString)) +
        AddAttribute('xid', CDS.FieldByName('XID').AsString) +
        AddAttribute('dbid', CDS.FieldByName('DBID').AsString) +
        AddAttribute('_xid', CDS.FieldByName('_XID').AsString) +
        AddAttribute('_dbid', CDS.FieldByName('_DBID').AsString, true) +
        AddCloseTag(XML_TAG_SETTING_POS, false, true));
      CDS.Next;
    end;
  end;
  StreamWriteXMLString(S, AddCloseTag(XML_TAG_SETTING_POS_LIST));

  // Позиции хранилища настройки
  StreamWriteXMLString(S, AddOpenTag(XML_TAG_STORAGE_POS_LIST));
  CDS := FDataObject.ClientDS[FDataObject.GetObjectIndex('TgdcSettingStorage', '')];
  if not CDS.IsEmpty then
  begin
    CDS.First;
    while not CDS.Eof do
    begin
      StreamWriteXMLString(S,
        AddOpenTag(XML_TAG_STORAGE_POS, false, true) +
        AddAttribute('branchname', QuoteString(CDS.FieldByName('BRANCHNAME').AsString)) +
        AddAttribute('valuename', QuoteString(CDS.FieldByName('VALUENAME').AsString)) +
        AddAttribute('crc', CDS.FieldByName('CRC').AsString) +
        AddAttribute('_xid', CDS.FieldByName('_XID').AsString) +
        AddAttribute('_dbid', CDS.FieldByName('_DBID').AsString, true) +
        AddCloseTag(XML_TAG_STORAGE_POS, false, true));
      CDS.Next;
    end;
  end;
  StreamWriteXMLString(S, AddCloseTag(XML_TAG_STORAGE_POS_LIST));
  // Закроем тег заголовка настройки
  StreamWriteXMLString(S, AddCloseTag(XML_TAG_SETTING_HEADER));

  CDS := FDataObject.ClientDS[FDataObject.GetObjectIndex('TgdcSetting', '')];
  
  DataStr := SkipToStreamTag(CDS.FieldByName('DATA').AsString);
  StorageDataStr := CDS.FieldByName('STORAGEDATA').AsString;

  // Данные и хранилище настройки
  StreamWriteXMLString(S, AddOpenTag(XML_TAG_SETTING_DATA));
  StreamWriteXMLString(S, DataStr + NEW_LINE);
  StreamWriteXMLString(S, AddCloseTag(XML_TAG_SETTING_DATA));
  StreamWriteXMLString(S, AddOpenTag(XML_TAG_SETTING_STORAGE));
  StreamWriteXMLString(S, StorageDataStr + NEW_LINE);
  StreamWriteXMLString(S, AddCloseTag(XML_TAG_SETTING_STORAGE));
  StreamWriteXMLString(S, AddCloseTag(XML_TAG_SETTING));
end;

function TgdcStreamXMLWriterReader.GetXMLSettingHeader(S: TStream;
  SettingHeader: TSettingHeader): Boolean;
var
  XMLElement: TXMLElementType;
  XMLStr: String;
  I: Integer;
begin
  Result := True;
  XMLElement := etUnknown;
  try
    while XMLElement <> etSettingHeader do
    begin
      XMLElement := GetNextElement(S, XMLStr);
      case XMLElement of
        etSettingHeader:
        begin
          SettingHeader.RUID := RUID(GetIntegerParamValueByName(XMLStr, 'xid'), GetIntegerParamValueByName(XMLStr, 'dbid'));
          SettingHeader.Name := UnQuoteString(GetParamValueByName(XMLStr, 'name'));
          SettingHeader.Comment := UnQuoteString(GetParamValueByName(XMLStr, 'description'));
          SettingHeader.Date := StrToDateTime(GetParamValueByName(XMLStr, 'modifydate'));
          SettingHeader.Version := GetIntegerParamValueByName(XMLStr, 'version');
          SettingHeader.Ending := GetIntegerParamValueByName(XMLStr, 'ending');
          SettingHeader.InterRUID.CommaText := GetParamValueByName(XMLStr, 'settingsruid');
          SettingHeader.MinEXEVersion := GetParamValueByName(XMLStr, 'minexeversion');
          SettingHeader.MinDBVersion := GetParamValueByName(XMLStr, 'mindbversion');
        end;
      end;
    end;
    // убираем не RUID'ы
    I := 0;
    with SettingHeader do
      while I < InterRUID.Count do
      begin
        if Length(InterRUID[I]) > 0 then
        begin
          // удаляем кавычки, если есть
          if (InterRUID[I][1] = '''') and (InterRUID[i][Length(InterRUID[I])] = '''') then
            InterRUID[I] := Copy(InterRUID[i], 2, Length(InterRUID[i])-2);
          // проверяем корректность RUID'а
          try
            StrToRUID(InterRUID[I]);
          except
            InterRUID.Delete(I);
            Dec(I);
          end;
          Inc(I);
        end
        else
          InterRUID.Delete(I);
      end;
  except
    Result := False;
  end;
end;

function TgdcStreamXMLWriterReader.QuoteString(Str: String): String;
var
  TempStr: String;
begin
  TempStr := StringReplace(Str, '&', '&amp;', [rfReplaceAll, rfIgnoreCase]);
  TempStr := StringReplace(TempStr, '<', '&lt;', [rfReplaceAll, rfIgnoreCase]);
  TempStr := StringReplace(TempStr, '>', '&gt;', [rfReplaceAll, rfIgnoreCase]);
  TempStr := StringReplace(TempStr, '"', '&quot;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(TempStr, '''', '&apos;', [rfReplaceAll, rfIgnoreCase]);
end;

function TgdcStreamXMLWriterReader.UnQuoteString(Str: String): String;
var
  TempStr: String;
begin
  TempStr := StringReplace(Str, '&amp;', '&', [rfReplaceAll, rfIgnoreCase]);
  TempStr := StringReplace(TempStr, '&lt;', '<', [rfReplaceAll, rfIgnoreCase]);
  TempStr := StringReplace(TempStr, '&gt;', '>', [rfReplaceAll, rfIgnoreCase]);
  TempStr := StringReplace(TempStr, '&quot;', '"', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(TempStr, '&apos;', '''', [rfReplaceAll, rfIgnoreCase]);
end;

procedure TgdcStreamXMLWriterReader.LoadStorageFromStream(const S: TStream; AnStAnswer: Word);
var
  ValueName, ValueType: String;
  ValueStr: String;
  BranchName: String;
  StorageName, Path: String;
  XMLStr: String;
  LStorage: TgsStorage;
  StorageFolder: TgsStorageFolder;
  StorageValue: TgsStorageValue;
  L: Integer;
  NeedLoad: Boolean;
  StIn, StOut: TStringStream;
  ValuePosition: Integer;

  function GetValueTypeInt(AType: String): Integer;
  begin
    Result := svtUnknown;
    if AType = 'I' then
      Result := svtInteger
    else
      if AType = 'S' then
        Result := svtString
      else
        if AType = 'St' then
          Result := svtStream
        else
          if AType = 'B' then
            Result := svtBoolean
          else
            if AType = 'D' then
              Result := svtDateTime
            else
              if AType = 'C' then
                Result := svtCurrency;
  end;

begin
  // TODO: Пока сделаем загрузку сразу на базу, потом надо будет передать
  //  запись хранилища в базу классу TgdcStreamDataProvider, а здесь грузить только в память

  LStorage := nil;
  StorageFolder := nil;

  while S.Position < S.Size do
  begin
    case GetNextElement(S, XMLStr) of

      etStorage:
      begin
        StorageName := GetParamValueByName(XMLStr, 'name');

        if AnsiPos(st_root_Global, StorageName) = 1 then
        begin
          if LStorage <> GlobalStorage then
          begin
            GlobalStorage.CloseFolder(GlobalStorage.OpenFolder('', False, True), False);
            LStorage := GlobalStorage;
          end;
        end
        else
          if AnsiPos(st_root_User, StorageName) = 1 then
          begin
            if LStorage <> UserStorage then
            begin
              UserStorage.CloseFolder(UserStorage.OpenFolder('', False, True), False);
              LStorage := UserStorage;
            end;
          end
          else
            LStorage := nil;
      end;

      etStorageFolder:
      begin
        if Assigned(LStorage) then
        begin
          BranchName := GetParamValueByName(XMLStr, 'name');
          Path := BranchName;

          if Assigned(StorageFolder) then
            LStorage.CloseFolder(StorageFolder, False);

          StorageFolder := LStorage.OpenFolder(Path, True, False);

          if StreamLoggingType = slAll then
          begin
            Space;
            AddText('Загрузка ветки хранилища "' + Path + '"', clBlue);
          end
        end;
      end;

      etStorageValue:
      begin
        if Assigned(LStorage) and Assigned(StorageFolder) then
        begin
          ValueName := GetParamValueByName(XMLStr, 'name');
          ValueType := GetParamValueByName(XMLStr, 'type');
          ValueStr := GetTextValueOfElement(S, XMLStr);

          if ((AnsiPos(st_ds_DFMPath, Path) = 1) or (AnsiPos(st_ds_NewFormPath, Path) = 1))
             and LStorage.ValueExists(Path, ValueName, False) then
          begin
            case AnStAnswer of
              mrYesToAll: NeedLoad := True;
              mrNoToAll: NeedLoad := False;
            else
              if not SilentMode then
                AnStAnswer := MessageDlg('Форма "' + Path + '\' + ValueName + '" уже настроена.'#13#10 +
                  'Заменить настройки формы? ', mtConfirmation,
                  [mbYes, mbYesToAll, mbNo, mbNoToAll], 0)
              else
                AnStAnswer := mrYes;
              case AnStAnswer of
                mrYes, mrYesToAll: NeedLoad := True;
              else
                NeedLoad := False;
              end;
            end;
          end
          else
            NeedLoad := True;

          if NeedLoad then
          begin
            StorageFolder.DeleteValue(ValueName);

            L := GetValueTypeInt(ValueType);
            case L of
              svtInteger: StorageValue := TgsIntegerValue.Create(StorageFolder, ValueName);
              svtString: StorageValue := TgsStringValue.Create(StorageFolder, ValueName);
              svtStream: StorageValue := TgsStreamValue.Create(StorageFolder, ValueName);
              svtBoolean: StorageValue := TgsBooleanValue.Create(StorageFolder, ValueName);
              svtDateTime: StorageValue := TgsDateTimeValue.Create(StorageFolder, ValueName);
              svtCurrency: StorageValue := TgsCurrencyValue.Create(StorageFolder, ValueName);
            else
              raise EgsStorageError.Create('Invalid value type');
            end;

            if Assigned(StorageValue) then
            begin
              try
                if StorageValue is TgsStreamValue then
                begin
                  ValuePosition := AnsiPos('<![CDATA[', ValueStr);
                  if ValuePosition > 0 then
                  begin
                    ValuePosition := AnsiPos('object', ValueStr);
                    if ValuePosition > 0 then
                    begin
                      StIn := TStringStream.Create(Copy(ValueStr, ValuePosition, Length(ValueStr) - ValuePosition - 3));
                      StOut := TStringStream.Create('');
                      try
                        ObjectTextToBinary(StIn, StOut);
                        ValueStr := StOut.DataString;
                      finally
                        StOut.Free;
                        StIn.Free;
                      end;
                    end
                    else
                    begin
                      ValuePosition := AnsiPos('<![CDATA[', ValueStr) + 9;
                      ValueStr := Copy(ValueStr, ValuePosition, Length(ValueStr) - ValuePosition - 3);
                    end;
                  end;
                end;

                StorageValue.AsString := ValueStr;
                StorageFolder.WriteValue(StorageValue);
              finally
                StorageValue.Free;
              end;

              if StreamLoggingType = slAll then
                AddText('  Загрузка параметра "' + ValueName + '" ветки хранилища "' + Path + '"', clBlue);
              LStorage.IsModified := True;
            end
            else
            begin
              // Неизвестный тип записи в хранилище
            end;
          end;
        end;
      end;

    else
      //
    end;
  end;
end;

procedure TgdcStreamXMLWriterReader.SaveStorageToStream(S: TStream);
var
  I: Integer;
  FolderName, NextFolderName: String;
  StorageName, NextStorageName: String;
  StorageValue: TgsStorageValue;
  StorageValueStr: String;
  StIn, StOut: TStringStream;
  Sign, Grid: String;

  function GetFolderName(const APath: String): String;
  begin
    Result := System.Copy(APath, 0, LastDelimiter('\', APath) - 1);
      
    if AnsiPos('\', Result) = 0 then
      Result := ''
    else
      Result := System.Copy(Result, AnsiPos('\', Result), Length(Result) - AnsiPos('\', Result) + 1);
  end;

begin
  if FDataObject.StorageItemList.Count > 0 then
  begin
    FDataObject.StorageItemList.Sort;

    StorageName := (FDataObject.StorageItemList.Objects[0] as TgsStorageItem).Storage.Name;
    StreamWriteXMLString(S,
      AddOpenTag(XML_TAG_STORAGE, false) + NEW_LINE +
      AddAttribute('name', StorageName) + '>' + NEW_LINE);

    FolderName := GetFolderName(FDataObject.StorageItemList.Strings[0]);
    StreamWriteXMLString(S,
      AddOpenTag(XML_TAG_STORAGE_FOLDER, false) + NEW_LINE +
      AddAttribute('name', FolderName) + '>' + NEW_LINE);

    if Assigned(frmStreamSaver) then
      frmStreamSaver.SetupProgress(FDataObject.StorageItemList.Count, 'Сохранение хранилища...');

    for I := 0 to FDataObject.StorageItemList.Count - 1 do
    begin
      // Если следующий параметр находится в другом хранилище
      NextStorageName := (FDataObject.StorageItemList.Objects[I] as TgsStorageItem).Storage.Name;
      if AnsiCompareText(NextStorageName, StorageName) <> 0 then
      begin
        StreamWriteXMLString(S, AddCloseTag(XML_TAG_STORAGE_FOLDER) + NEW_LINE);
        FolderName := GetFolderName(FDataObject.StorageItemList.Strings[I]);
        
        StreamWriteXMLString(S, AddCloseTag(XML_TAG_STORAGE) + NEW_LINE);
        StorageName := NextStorageName;
        StreamWriteXMLString(S,
          AddOpenTag(XML_TAG_STORAGE, false) + NEW_LINE +
          AddAttribute('name', StorageName) + '>' + NEW_LINE);

        StreamWriteXMLString(S,
          AddOpenTag(XML_TAG_STORAGE_FOLDER, false) + NEW_LINE +
          AddAttribute('name', FolderName) + '>' + NEW_LINE);
      end;

      // Если следующий параметр находится в другой папке
      NextFolderName := GetFolderName(FDataObject.StorageItemList.Strings[I]);
      if AnsiCompareText(NextFolderName, FolderName) <> 0 then
      begin
        StreamWriteXMLString(S, AddCloseTag(XML_TAG_STORAGE_FOLDER) + NEW_LINE);
        FolderName := NextFolderName;
        StreamWriteXMLString(S,
          AddOpenTag(XML_TAG_STORAGE_FOLDER, false) + NEW_LINE +
          AddAttribute('name', FolderName) + '>' + NEW_LINE);
      end;

      if Assigned(FDataObject.StorageItemList.Objects[I])
         and (FDataObject.StorageItemList.Objects[I] is TgsStorageValue) then
      begin
        StorageValue := (FDataObject.StorageItemList.Objects[I] as TgsStorageValue);
        StreamWriteXMLString(S,
          AddOpenTag(XML_TAG_STORAGE_VALUE, false) + NEW_LINE +
          AddAttribute('name', StorageValue.Name) + NEW_LINE +
          AddAttribute('type', StorageValue.GetTypeName) + '>' + NEW_LINE);

        if (StorageValue is TgsStreamValue) then
        begin
          StorageValueStr := StorageValue.AsString;
          SetLength(Sign, 3);
          SetLength(Grid, 11);
          Sign := Copy(StorageValueStr, 0, 3);
          Grid := Copy(StorageValueStr, 7, 11);
          if (Sign = 'TPF') and (Grid <> 'GRID_STREAM') then
          begin
            StIn := TStringStream.Create(StorageValueStr);
            StOut := TStringStream.Create('');
            try
              StIn.Position := 0;
              ObjectBinaryToText(StIn, StOut);
              StreamWriteXMLString(S, NEW_LINE + '<![CDATA[' + StOut.DataString + ']]>' + NEW_LINE);
              StreamWriteXMLString(S, AddCloseTag(XML_TAG_STORAGE_VALUE) + NEW_LINE);
            finally
              StOut.Free;
              StIn.Free;
            end;
          end
          else
            StreamWriteXMLString(S, NEW_LINE + '<![CDATA[' + StorageValueStr + ']]>' + NEW_LINE);
            StreamWriteXMLString(S, AddCloseTag(XML_TAG_STORAGE_VALUE) + NEW_LINE);
        end
        else
          StreamWriteXMLString(S, StorageValue.AsString);
          StreamWriteXMLString(S, AddCloseTag(XML_TAG_STORAGE_VALUE) + NEW_LINE);
      end;

      if Assigned(frmStreamSaver) then
        frmStreamSaver.Step;

    end;
    StreamWriteXMLString(S, AddCloseTag(XML_TAG_STORAGE_FOLDER) + NEW_LINE);
    StreamWriteXMLString(S, AddCloseTag(XML_TAG_STORAGE));

    if Assigned(frmStreamSaver) then
      frmStreamSaver.Done;

  end;
end;

constructor TgdcStreamXMLWriterReader.Create(
  AObjectSet: TgdcStreamDataObject;
  ALoadingOrderList: TgdcStreamLoadingOrderList);
begin
  inherited Create(AObjectSet, ALoadingOrderList);

  FElementLevel := 0;
end;

function TgdcStreamXMLWriterReader.RepeatString(
  const StringToRepeat: String; const RepeatCount: Integer): String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to RepeatCount - 1 do
    Result := Result + StringToRepeat;
end;

function TgdcStreamXMLWriterReader.AddOpenTag(const ATag: String;
  const ASingleLineElement: Boolean = false; const AHasAttribute: Boolean = false): String;
begin
  Result := RepeatString(INDENT_STR, FElementLevel) + '<' + ATag;
  // Последний символ открывающего тега
  if AHasAttribute then
    Result := Result + ' '
  else
    Result := Result + '>';
  // Перенос на новую строку
  if not ASingleLineElement then
    Result := Result + NEW_LINE;
  // Увеличим уровень вложенности элемента
  Inc(FElementLevel);
end;

function TgdcStreamXMLWriterReader.AddCloseTag(const ATag: String;
  const ASingleLineElement: Boolean = false; const AShortClosingTag: Boolean = false): String;
begin
  // Уменьшим уровень вложенности элемента
  Dec(FElementLevel);
  if not AShortClosingTag then
  begin
    // Отступ перед тегом
    if not ASingleLineElement then
      Result := RepeatString(INDENT_STR, FElementLevel);
    Result := Result + '</' + ATag + '>';
  end  
  else
    Result := ' />';
  Result := Result + NEW_LINE;
end;

function TgdcStreamXMLWriterReader.AddAttribute(const ATag, AValue: String;
  const ASingleLineElement: Boolean = false): String;
begin
  Result := RepeatString(INDENT_STR, FElementLevel) + ATag + '="' + AValue + '"';
  if not ASingleLineElement then
    Result := Result + NEW_LINE;
end;

{ TgdcStreamSaver }

constructor TgdcStreamSaver.Create(ADatabase: TIBDatabase = nil; ATransaction: TIBTransaction = nil);
var
  Database: TIBDatabase;
begin
  if Assigned(ADatabase) then
    Database := ADatabase
  else
    Database := gdcBaseManager.Database;

  FTrWasActive := false;
  FTrWasCreated := false;

  FErrorMessageForSetting := '';

  if Assigned(ATransaction) then
  begin
    FTransaction := ATransaction;

    if FTransaction.InTransaction then
      FTrWasActive := True
    else
      FTransaction.StartTransaction;
  end
  else
  begin
    FTransaction := TIBTransaction.Create(nil);
    FTransaction.DefaultDatabase := Database;
    FTransaction.StartTransaction;
    FTrWasCreated := true;
  end;

  FDataObject := TgdcStreamDataObject.Create(Database, FTransaction);
  FStreamLoadingOrderList := TgdcStreamLoadingOrderList.Create;

  FStreamDataProvider := TgdcStreamDataProvider.Create(Database, FTransaction);
  FStreamDataProvider.DataObject := FDataObject;
  FStreamDataProvider.LoadingOrderList := FStreamLoadingOrderList;

  AbortProcess := False;
  IsReadUserFromStream := False;
  SilentMode := False;
  if Assigned(GlobalStorage) then
    Self.StreamLogType := TgsStreamLoggingType(GlobalStorage.ReadInteger('Options', 'StreamLogType', 2));

  if not Assigned(frmSQLProcess) then
    frmSQLProcess := TfrmSQLProcess.Create(Application);
      
{  if StreamLoggingType in [slSimple, slAll] then
  begin
    Space;
    AddText(TimeToStr(Time) + ': Началась обработка данных в потоке.'#13#10, clBlack, True);
  end; }
end;


destructor TgdcStreamSaver.Destroy;
begin
  if FTransaction.InTransaction then
    if FTrWasActive then
      FTransaction.CommitRetaining
    else
      FTransaction.Commit;

  if Assigned(FStreamDataProvider) then
    FreeAndNil(FStreamDataProvider);
  if Assigned(FStreamLoadingOrderList) then
    FreeAndNil(FStreamLoadingOrderList);
  if Assigned(FDataObject) then
    FreeAndNil(FDataObject);
  if Assigned(FTransaction) then
    if FTrWasCreated then
      FreeAndNil(FTransaction)
    else
      FTransaction := nil;

  inherited;
end;


procedure TgdcStreamSaver.SaveToStream(S: TStream; const AFormat: TgsStreamType = sttBinaryNew);
var
  FStreamWriterReader: TgdcStreamWriterReader;
begin
  if S = nil then
    raise Exception.Create(GetGsException(Self, 'SaveToStream: Не установлен поток'));

  FStreamDataProvider.CheckNonConfirmedRecords;

  //сохранить полученные данные в поток
  case AFormat of
    sttBinaryNew: FStreamWriterReader := TgdcStreamBinaryWriterReader.Create(FDataObject, FStreamLoadingOrderList);
    sttXML: FStreamWriterReader := TgdcStreamXMLWriterReader.Create(FDataObject, FStreamLoadingOrderList);
  else
    FStreamWriterReader := TgdcStreamBinaryWriterReader.Create(FDataObject, FStreamLoadingOrderList);
  end;

  try
    FStreamWriterReader.SaveToStream(S);
  finally
    FStreamWriterReader.Free;
  end;

  if StreamLoggingType in [slSimple, slAll] then
  begin
    Space;
    AddText(TimeToStr(Time) + ': Закончилось сохранение данных в поток.'#13#10, clBlack, True);
    Space;
  end;
end;


procedure TgdcStreamSaver.LoadFromStream(S: TStream);
var
  Obj: TgdcBase;
  CDS: TClientDataSet;
  OrderElement: TStreamOrderElement;
  FStreamWriterReader: TgdcStreamWriterReader;
begin

  try
    if StreamLoggingType in [slSimple, slAll] then
    begin
      Space;
      AddText(TimeToStr(Time) + ': Началась загрузка данных из потока.', clBlack);
    end;

    if Assigned(frmStreamSaver) then
      frmStreamSaver.SetProcessCaptionText('Чтение файла...');

    if GetStreamType(S) = sttXML then
      FStreamWriterReader := TgdcStreamXMLWriterReader.Create(FDataObject, FStreamLoadingOrderList)
    else
      FStreamWriterReader := TgdcStreamBinaryWriterReader.Create(FDataObject, FStreamLoadingOrderList);
      
    try
      FStreamWriterReader.LoadFromStream(S);
    finally
      FStreamWriterReader.Free;
    end;

    // Обработать загруженный список баз данных
    FStreamDataProvider.ProcessDatabaseList;

    if (FDataObject.TargetBaseKey > -1) then
      if (FDataObject.TargetBaseKey = FDataObject.OurBaseKey) then
      begin
        FStreamDataProvider.LoadReceivedRecords;
      end
      else
      begin
        AddMistake(#13#10 + 'Загружаемый поток предназначен для другой базы данных', clRed);
        AddMistake('  ID нашей базы = ' + IntToStr(FDataObject.OurBaseKey), clRed);
        AddMistake('  ID целевой базы потока = ' + IntToStr(FDataObject.TargetBaseKey) + #13#10, clRed);

        if Assigned(frmStreamSaver) then
          frmStreamSaver.AddMistake('Загружаемый поток предназначен для другой базы данных' + #13#10 +
            '  ID нашей базы = ' + IntToStr(FDataObject.OurBaseKey) + #13#10 +
            '  ID целевой базы потока = ' + IntToStr(FDataObject.TargetBaseKey));

        raise Exception.Create('Загружаемый поток предназначен для другой базы данных');
      end;

    if Assigned(frmSQLProcess) then
    begin
      with frmSQLProcess.pb do
      begin
        Min := 0;
        Max := FStreamLoadingOrderList.Count;
        Position := 0;
      end;
    end;

    if Assigned(frmStreamSaver) then
    begin
      frmStreamSaver.Done;
      frmStreamSaver.SetupProgress(FStreamLoadingOrderList.Count, 'Загрузка данных...');
    end;

    //FStreamDataProvider.AnAnswer := 0;         // сбрасывать ли ответ на вопрос о замене объектов, при последовательной загрузке нескольких файлов?

    // загружаем записи из потока на базу
    while FStreamLoadingOrderList.PopNextElement(OrderElement) do
    begin
      Obj := FDataObject.gdcObject[OrderElement.DSIndex];
      CDS := FDataObject.ClientDS[OrderElement.DSIndex];
      if CDS.Locate(Obj.GetKeyField(Obj.SubType), OrderElement.RecordID, []) then
        FStreamDataProvider.LoadRecord(Obj, CDS)
      else
        raise Exception.Create('В потоке не найдена требуемая запись: ' +
          Obj.Classname + ' ' + Obj.SubType + ' (' + IntToStr(OrderElement.RecordID) + ')');

      if AbortProcess then
      begin
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        Exit;
      end;

      if Assigned(frmStreamSaver) then
        frmStreamSaver.Step;
      if Assigned(frmSQLProcess) then
        frmSQLProcess.pb.Position := frmSQLProcess.pb.Position + 1;
    end;

    // загружаем записи-множества на базу
    try
      FStreamDataProvider.LoadSetRecords;
    except
      on E: EgdcNoTable do
      begin
        AddMistake(Format('Не найдена таблица %s для кросс-связи между объектами.', [E.Message]), clRed);
        Space;
        if Assigned(frmStreamSaver) then
          frmStreamSaver.AddMistake(Format('Не найдена таблица %s для кросс-связи между объектами.', [E.Message]));
      end;
    end;

    if FTransaction.InTransaction then
      if FTrWasActive then
        FTransaction.CommitRetaining
      else
        FTransaction.Commit
    else
      FTransaction.Rollback;

    if Assigned(frmStreamSaver) then
      frmStreamSaver.Done;

    if StreamLoggingType in [slSimple, slAll] then
    begin
      Space;
      AddText(TimeToStr(Time) + ': Закончилась загрузка данных из потока.', clBlack);
      Space;
    end;

  except
    on E: Exception do
    begin
      if FTransaction.InTransaction then
        FTransaction.Rollback;
      AddMistake(E.Message, clRed);
      Space;
      if Assigned(frmStreamSaver) then
        frmStreamSaver.AddMistake(E.Message);
      raise;
    end;
  end;
end;


procedure TgdcStreamSaver.SaveSettingDataToStream(S: TStream; ASettingKey: TID);
var
  ibsqlPos: TIBSQL;
  WithDetailList: TgdKeyArray;
  NeedModifyList: TgdKeyIntAssoc;
  IndexNeedModifyList: Integer;
  SaveDetailObjects: Boolean;
  AnID: TID;
  LineObjectID: TID;
  ObjectIndex: Integer;
  PositionsCount: Integer;
begin
  try
    Assert(Assigned(S));
    Assert(ASettingKey > -1);

    ibsqlPos := TIBSQL.Create(nil);
    WithDetailList := TgdKeyArray.Create;
    NeedModifyList := TgdKeyIntAssoc.Create;
    try
      PositionsCount := 0;

      ibsqlPos.Transaction := FTransaction;
      // вытянем позиции сохраняемой настройки
      ibsqlPos.SQL.Text := 'SELECT * FROM at_settingpos WHERE settingkey = :settingkey ' +
        ' ORDER BY objectorder';
      ibsqlPos.ParamByName('settingkey').AsInteger := ASettingKey;
      ibsqlPos.ExecQuery;
      while not ibsqlPos.Eof do
      begin
        LineObjectID := gdcBaseManager.GetIDByRUID(ibsqlPos.FieldByName('xid').AsInteger,
          ibsqlPos.FieldByName('dbid').AsInteger, FTransaction);
        // Если мы не получили ИД объекта по РУИДу, значит объект был удален
        if LineObjectID > -1 then
        begin
          // Если мы должны сохранить объект с детальными объектами, то занесем его id в список
          if ibsqlPos.FieldByName('withdetail').AsInteger = 1 then
            WithDetailList.Add(LineObjectID);
          // Если мы не должны перезаписывать объект данными из потока, то занесем его id в список
          IndexNeedModifyList := NeedModifyList.Add(LineObjectID);
          NeedModifyList.ValuesByIndex[IndexNeedModifyList] := ibsqlPos.FieldByName('needmodify').AsInteger;
        end
        else
        begin
          // Если работает репликатор, то не будем прерывать сохранение настройки
          AddMistake(#13#10 +
            Format('Не удалось получить идентификатор позиции настройки (XID = %0:d, DBID = %1:d)',
            [ibsqlPos.FieldByName('xid').AsInteger, ibsqlPos.FieldByName('dbid').AsInteger]) + #13#10, clRed);
          if not SilentMode then
          begin
            raise Exception.Create('Не удалось получить идентификатор позиции настройки.'#13#10 +
              'Проверьте целостность настройки!');
          end;
        end;
        Inc(PositionsCount);
        ibsqlPos.Next;
      end;

      FStreamDataProvider.SaveWithDetailList := WithDetailList;
      FStreamDataProvider.NeedModifyList := NeedModifyList;

      if Assigned(frmStreamSaver) then
        frmStreamSaver.SetupProgress(PositionsCount, 'Формирование настройки...');

      ibsqlPos.Close;
      ibsqlPos.ExecQuery;
      while not ibsqlPos.Eof do
      begin
        if Assigned(frmStreamSaver) then
          frmStreamSaver.SetProcessText(ibsqlPos.FieldByName('category').AsString + ' ' +
            ibsqlPos.FieldByName('objectname').AsString + #13#10 +
              ' (XID = ' +  ibsqlPos.FieldByName('xid').AsString +
              ', DBID = ' + ibsqlPos.FieldByName('dbid').AsString + ')');

        SaveDetailObjects := ibsqlPos.FieldByName('withdetail').AsInteger = 1;
        AnID := gdcBaseManager.GetIDByRUID(ibsqlPos.FieldByName('xid').AsInteger,
          ibsqlPos.FieldByName('dbid').AsInteger, FTransaction);

        ObjectIndex := FDataObject.GetObjectIndex(ibsqlPos.FieldByName('objectclass').AsString, ibsqlPos.FieldByName('subtype').AsString);

        FStreamDataProvider.Reset;
        FStreamDataProvider.SaveRecord(ObjectIndex, AnID, SaveDetailObjects);

        if Assigned(frmStreamSaver) then
          frmStreamSaver.Step;

        ibsqlPos.Next;
      end;

      if Assigned(GlobalStorage) and
         (TStreamFileFormat(GlobalStorage.ReadInteger('Options', 'StreamSettingType', 0)) = ffXML) then
        Self.SaveToStream(S, sttXML)
      else
        Self.SaveToStream(S, sttBinaryNew);

      if Assigned(frmStreamSaver) then
        frmStreamSaver.Done;

    finally
      NeedModifyList.Free;
      WithDetailList.Free;
      ibsqlPos.Free;
    end;
  except
    if FTransaction.InTransaction then
      FTransaction.Rollback;
    raise;
  end;
end;


procedure TgdcStreamSaver.LoadSettingDataFromStream(S: TStream; var WasMetaDataInSetting: Boolean;
  const DontHideForms: Boolean; var AnAnswer: Word);

var
  RelName: String;
  Obj: TgdcBase;
  CDS: TClientDataSet;
  OrderElement: TStreamOrderElement;
  FStreamWriterReader: TgdcStreamWriterReader;
  WasMetaData: Boolean;

  procedure DisconnectDatabase(const WithCommit: Boolean);
  begin
    if gdcBaseManager.ReadTransaction.InTransaction then
      gdcBaseManager.ReadTransaction.Commit;
    if FTransaction.InTransaction then
    begin
    if WithCommit then
      begin
        FTransaction.Commit;
      end else
      begin
        FTransaction.Rollback;
      end;
    end;
    FTransaction.DefaultDatabase.Connected := False;
  end;

  procedure ConnectDatabase;
  begin
    FTransaction.DefaultDatabase.Connected := True;
    if not FTransaction.InTransaction then
      FTransaction.StartTransaction;
    if not gdcBaseManager.ReadTransaction.InTransaction then
      gdcBaseManager.ReadTransaction.StartTransaction;
  end;

  procedure ReConnectDatabase(const WithCommit: Boolean = True);
  begin
    try
      DisconnectDatabase(WithCommit);
    except
      on E: Exception do
      begin
        if MessageBox(0,
          PChar('В процессе загрузки настройки произошла ошибка:'#13#10 +
          E.Message + #13#10#13#10 +
          'Продолжать загрузку?'),
          'Ошибка',
          MB_ICONEXCLAMATION or MB_YESNO or MB_TASKMODAL) = IDNO then
        begin
          raise;
        end;  
      end;
    end;
    ConnectDatabase;
  end;

  procedure RunMultiConnection;
  var
    WasConnect: Boolean;
    R: TatRelation;
    ibsql: TIBSQL;
  begin
    Assert(atDatabase <> nil, 'Не загружена база атрибутов');
    if atDatabase.InMultiConnection then
    begin
     {Проверим, действительно ли нам необходимо переподключение.
       Если в таблице at_transaction ничего нет, скинем флаг переподключения}
      ibsql := TIBSQL.Create(nil);
      try
        ibsql.Transaction := FTransaction;
        ibsql.SQL.Text := 'SELECT FIRST 1 * FROM at_transaction ';
        ibsql.ExecQuery;

        if ibsql.RecordCount = 0 then
        begin
          atDatabase.CancelMultiConnectionTransaction(True);
        end else
        begin
          with TmetaMultiConnection.Create do
          try
            WasConnect := FTransaction.DefaultDatabase.Connected;
            DisconnectDatabase(True);
            RunScripts(False);
            ConnectDatabase;
            R := atDatabase.Relations.ByRelationName(RelName);
            if Assigned(R) then
              R.RefreshConstraints(FTransaction.DefaultDatabase, FTransaction);
            if not WasConnect then
              DisconnectDatabase(True);
          finally
            Free;
          end;
        end;

      finally
        ibsql.Free;
      end;
    end;
  end;
  
begin

  if GetStreamType(S) = sttXML then
    FStreamWriterReader := TgdcStreamXMLWriterReader.Create(FDataObject, FStreamLoadingOrderList)
  else
    FStreamWriterReader := TgdcStreamBinaryWriterReader.Create(FDataObject, FStreamLoadingOrderList);

  try
    FStreamWriterReader.LoadFromStream(S);
  finally
    FStreamWriterReader.Free;
  end;

  WasMetaData := False;

  if Assigned(frmStreamSaver) then
    frmStreamSaver.SetupProgress(FStreamLoadingOrderList.Count, 'Активация настройки...');

  if Assigned(frmSQLProcess) then
  begin
    with frmSQLProcess.pb do
    begin
      Min := 0;
      Max := FStreamLoadingOrderList.Count;
      Position := 0;
    end;
  end;

  FStreamDataProvider.AnAnswer := AnAnswer;
  try

    // загружаем записи из потока на базу
    while FStreamLoadingOrderList.PopNextElement(OrderElement) do
    begin
      Obj := FDataObject.gdcObject[OrderElement.DSIndex];

      if (Obj.InheritsFrom(TgdcMetaBase)) then
      begin
        WasMetaData := True;
        {Помечаем, что в настройке были мета-данные}
        WasMetaDataInSetting := True;
      end
      else
      begin
        if WasMetaData then
        begin
          if not SilentMode then
            ReconnectDatabase;
        end;

        WasMetaData := False;
      end;

      //При LogOff мы закрыли ReadTransaction. Стартанем ее снова, т.к. она используется при создании gdc-объектов
      ConnectDatabase;
      RunMultiConnection;

      try
        //При открытии может возникнуть ошибка, если мета-данные созданы, но еще не прошел комит
        if Obj.SubSet <> 'ByID' then
          Obj.SubSet := 'ByID';
        if not Obj.Active then
          Obj.Open;
      except
        if not SilentMode then
          ReconnectDatabase;
        if not Obj.Active then
          Obj.Open;
      end;

      CDS := FDataObject.ClientDS[OrderElement.DSIndex];
      if CDS.Locate(Obj.GetKeyField(Obj.SubType), OrderElement.RecordID, []) then
      begin
        try
          FStreamDataProvider.LoadRecord(Obj, CDS);
        except
          on E: Exception do
          begin
            // удалим проблемный объект из очереди загрузки
            FStreamLoadingOrderList.Remove(OrderElement.RecordID);
            if not SilentMode then
            begin
              if FTransaction.InTransaction then
                FTransaction.Rollback;
              AddMistake(E.Message, clRed);
              Space;
              if Assigned(frmStreamSaver) then
                frmStreamSaver.AddMistake(E.Message);
              raise;
            end
            else
            begin
              FErrorMessageForSetting := FErrorMessageForSetting + IntToStr(GetLastError) + ': ' + E.Message + ' ' + Obj.ClassName + '_' + Obj.SubType + #13#10;
              if Obj.State in [dsEdit, dsInsert] then
                Obj.Cancel;
            end;
          end;
        end;
      end
      else
        raise Exception.Create('В потоке не найдена требуемая запись:'#13#10 +
          Obj.Classname + ' ' + Obj.SubType + ' (' + IntToStr(OrderElement.RecordID) + ')');

      if Assigned(frmStreamSaver) then
        frmStreamSaver.Step;

      if Assigned(frmSQLProcess) then
        frmSQLProcess.pb.Position := frmSQLProcess.pb.Position + 1;
      //Если объект - поле, то сохраним имя таблицы, чтобы, если понадобится,
      //после переподключения синхронизировать внешние ключи
      if (Obj is TgdcRelationField) then
        RelName := Obj.FieldByName('relationname').AsString
      else
        RelName := '';
    end;

    // загружаем записи-множества на базу
    try
      FStreamDataProvider.LoadSetRecords;
    except
      on E: EgdcNoTable do
      begin
        AddMistake(Format('Не найдена таблица %s для кросс-связи между объектами.', [E.Message]), clRed);
        Space;
        if Assigned(frmStreamSaver) then
          frmStreamSaver.AddMistake(Format('Не найдена таблица %s для кросс-связи между объектами.', [E.Message]));
      end;
    end;

    RunMultiConnection;

    if Assigned(frmStreamSaver) then
      frmStreamSaver.Done;

  except
    on E: Exception do
    begin
      if FTransaction.InTransaction then
        FTransaction.Rollback;
      AddMistake(E.Message, clRed);
      Space;
      if Assigned(frmStreamSaver) then
        frmStreamSaver.AddMistake(E.Message);
      raise;
    end;
  end;

end;


procedure TgdcStreamSaver.LoadSettingStorageFromStream(S: TStream; AnStAnswer: Word);
var
  StreamWriterReader: TgdcStreamWriterReader;
begin
  if S.Size > 0 then
  begin
    if StreamLoggingType in [slSimple, slAll] then
    begin
      Space;
      AddText(TimeToStr(Time) + ': Началась загрузка хранилища', clBlack);
    end;

    if GetStreamType(S) = sttXML then
      StreamWriterReader := TgdcStreamXMLWriterReader.Create
    else
      StreamWriterReader := TgdcStreamBinaryWriterReader.Create;

    try
      StreamWriterReader.LoadStorageFromStream(S, AnStAnswer);
    finally
      StreamWriterReader.Free;
    end;

    if GlobalStorage.IsModified then
      GlobalStorage.SaveToDatabase;

    if UserStorage.IsModified then
      UserStorage.SaveToDatabase;

    if StreamLoggingType in [slSimple, slAll] then
    begin
      Space;
      AddText(TimeToStr(Time) + ': Закончилась загрузка хранилища', clBlack);
      Space;
    end;
  end;
end;


procedure TgdcStreamSaver.SaveSettingStorageToStream(S: TStream; ASettingKey: TID);
var
  ibsqlPos: TIBSQL;
  FStreamWriterReader: TgdcStreamWriterReader;

  LStorage: TgsStorage;
  BranchName, StorageName, Path: String;
  NewFolder: TgsStorageFolder;
  stValue: TgsStorageValue;
  L: Integer;
begin
  try
    Assert(Assigned(S));
    Assert(ASettingKey > -1);

    if StreamLoggingType in [slSimple, slAll] then
    begin
      Space;
      AddText(TimeToStr(Time) + ': Началось сохранение хранилища', clBlack);
      Space;
    end;

    ibsqlPos := TIBSQL.Create(nil);
    try
      ibsqlPos.Transaction := FTransaction;
      ibsqlPos.SQL.Text := 'SELECT * FROM at_setting_storage WHERE settingkey = :settingkey ';
      ibsqlPos.ParamByName('settingkey').AsInteger := ASettingKey;
      ibsqlPos.ExecQuery;

      if Assigned(GlobalStorage) and
         (TStreamFileFormat(GlobalStorage.ReadInteger('Options', 'StreamSettingType', 0)) = ffXML) then
      begin
        while not ibsqlPos.Eof do
        begin
          FStreamDataProvider.SaveStorageItem(ibsqlPos.FieldByName('branchname').AsString,
            ibsqlPos.FieldByName('valuename').AsString);

          ibsqlPos.Next;
        end;

        FStreamWriterReader := TgdcStreamXMLWriterReader.Create(FDataObject);
        try
          FStreamWriterReader.SaveStorageToStream(S);
        finally
          FStreamWriterReader.Free;
        end;

      end
      else
      begin
        // Сохранение в двоичном формате оставим пока по старому
        LStorage := nil;
        while not ibsqlPos.Eof do
        begin
          BranchName := ibsqlPos.FieldByName('branchname').AsString;

          if AnsiPos('\', BranchName) = 0 then
          begin
            Path := '';
            StorageName := BranchName;
          end else
          begin
            Path := System.Copy(BranchName, AnsiPos('\', BranchName), Length(BranchName) -
              AnsiPos('\', BranchName) + 1);
            StorageName := AnsiUpperCase(System.Copy(BranchName, 1, AnsiPos('\', BranchName) - 1));
          end;
          if AnsiPos(st_root_Global, StorageName) = 1 then
          begin
            if LStorage <> GlobalStorage then
            begin
              GlobalStorage.CloseFolder(GlobalStorage.OpenFolder('', False, True), False);
              LStorage := GlobalStorage;
            end;
          end
          else if AnsiPos(st_root_User, StorageName) = 1 then
          begin
            if LStorage <> UserStorage then
            begin
              UserStorage.CloseFolder(UserStorage.OpenFolder('', False, True), False);
              LStorage := UserStorage;
            end;
          end
          else
            LStorage := nil;

          if LStorage = nil then
            NewFolder := nil
          else
            NewFolder := LStorage.OpenFolder(Path, False);

          if Assigned(NewFolder) and (ibsqlPos.FieldByName('valuename').AsString > '') then
            stValue := NewFolder.ValueByName(ibsqlPos.FieldByName('valuename').AsString)
          else
            stValue := nil;

          if Assigned(NewFolder) then
          begin
            if ibsqlPos.FieldByName('valuename').AsString > '' then
            begin
              if Assigned(stValue) then
              begin
                S.WriteBuffer(cst_StreamValue[1], Length(cst_StreamValue));
                L := Length(ibsqlPos.FieldByName('valuename').AsString);
                S.WriteBuffer(L, Sizeof(L));
                S.WriteBuffer(ibsqlPos.FieldByName('valuename').AsString[1], L);
                L := Length(BranchName);
                S.WriteBuffer(L, Sizeof(L));
                S.WriteBuffer(BranchName[1], L);
                stValue.SaveToStream(S);

                if StreamLoggingType = slAll then
                  AddText('Сохранение параметра ' + ibsqlPos.FieldByName('valuename').AsString +
                    ' ветки хранилища ' + BranchName, clBlue);
              end else
                raise EgdcIBError.Create(' Параметр ' +
                  ibsqlPos.FieldByName('valuename').AsString +
                  ' ветки хранилища ' + BranchName + ' не найден!');
            end else
            begin
              L :=  Length(BranchName);
              S.WriteBuffer(L, Sizeof(L));
              S.WriteBuffer(BranchName[1], L);
              NewFolder.SaveToStream(S);

              if StreamLoggingType = slAll then
                AddText('Сохранение ветки хранилища ' + BranchName, clBlue);
            end;
            LStorage.CloseFolder(NewFolder);
          end else
            raise EgdcIBError.Create(
              'Ветка хранилища "' + BranchName + '" не найдена!'#13#10#13#10 +
              'В настройку можно добавлять только ветки или параметры'#13#10 +
              'глобального хранилища или хранилища пользователя Администратор.');

          ibsqlPos.Next;
        end;
      end;

    finally
      ibsqlPos.Free;
    end;

    if StreamLoggingType in [slSimple, slAll] then
    begin
      Space;
      AddText(TimeToStr(Time) + ': Закончилось сохранение хранилища', clBlack);
      Space;
    end;

  except
    if FTransaction.InTransaction then
      FTransaction.Rollback;
    raise;
  end;
end;


procedure TgdcStreamSaver.FillRUIDListFromStream(S: TStream;
  RuidList: TStrings; const SettingID: Integer = -1);
var
  StPos: TgdcSettingPos;
  OrderElement: TStreamOrderElement;
  Obj: TgdcBase;
  CDS: TClientDataSet;
  FStreamWriterReader: TgdcStreamWriterReader;
begin

  if GetStreamType(S) = sttXML then
    FStreamWriterReader := TgdcStreamXMLWriterReader.Create(FDataObject, FStreamLoadingOrderList)
  else
    FStreamWriterReader := TgdcStreamBinaryWriterReader.Create(FDataObject, FStreamLoadingOrderList);

  try
    FStreamWriterReader.LoadFromStream(S);
  finally
    FStreamWriterReader.Free;
  end;


  if SettingID > 0 then
  begin
    StPos := TgdcSettingPos.Create(nil);
    StPos.AddSubSet('BySetting');
    StPos.AddSubSet('ByRUID');
    StPos.ParamByName('settingkey').AsInteger := SettingID;
  end;

  try

    while FStreamLoadingOrderList.PopNextElement(OrderElement) do
    begin
      Obj := FDataObject.gdcObject[OrderElement.DSIndex];
      CDS := FDataObject.ClientDS[OrderElement.DSIndex];

      if CDS.Locate(Obj.GetKeyField(Obj.SubType), OrderElement.RecordID, []) then

        if Assigned(StPos) then
        begin
        {Если нам передали конкретный id настройки, то будем проверять,
         входит ли руид в позицию настройки
         Необходимо для сохранения списка руидов удаляемой настройки,
         чтобы не удалить случайно объект, который вытягивался ранее по неявным ссылках
         Например, сторед процедура ранее могла использовать поля one, two,
         которые входят явно в другую настройку.
         При новой модификации процедура стала использовать только одно поле two
         Чтобы случайно не удалилось поле One, передаем ид удаляемой настройки =>
         сохраним в список руидов только руид процедуры.}
          StPos.Close;
          StPos.ParamByName('xid').AsString := CDS.FieldByName('_xid').AsString;
          StPos.ParamByName('dbid').AsString := CDS.FieldByName('_dbid').AsString;
          StPos.Open;
          if StPos.RecordCount > 0 then
          begin
            RuidList.Add(CDS.FieldByName('_xid').AsString + ',' +
              CDS.FieldByName('_dbid').AsString + ',' + AnsiUpperCase(Trim(Obj.ClassName)) +
              ','+ AnsiUpperCase(Trim(Obj.SubType)));
          end;
        end
        else
        begin
          RuidList.Add(CDS.FieldByName('_xid').AsString + ',' +
            CDS.FieldByName('_dbid').AsString + ',' + AnsiUpperCase(Trim(Obj.ClassName)) +
            ','+ AnsiUpperCase(Trim(Obj.SubType)));
        end

      else
        raise Exception.Create('В потоке не найдена требуемая запись:'#13#10 +
          Obj.Classname + ' ' + Obj.SubType + ' (' + IntToStr(OrderElement.RecordID) + ')');

      FStreamLoadingOrderList.Remove(OrderElement.RecordID);
    end;

  finally
    if Assigned(StPos) then
      FreeAndNil(StPos);
  end;

end;


procedure TgdcStreamSaver.AddObject(AgdcObject: TgdcBase; const AWithDetail: Boolean = True);
var
  C: TgdcFullClass;
  ObjectIndex: Integer;
  AID: TID;
  IndexNeedModifyList: Integer;
begin
  Assert(AgdcObject <> nil, 'AddObject: AgdcObject = nil');

  AID := AgdcObject.ID;

  if Assigned(NeedModifyList) and (NeedModifyList.IndexOf(AID) = -1) then
  begin
    IndexNeedModifyList := NeedModifyList.Add(AID, True);
    NeedModifyList.ValuesByIndex[IndexNeedModifyList] := Integer(AgdcObject.ModifyFromStream);
  end;

  C := AgdcObject.GetCurrRecordClass;
  ObjectIndex := FDataObject.GetObjectIndex(C.gdClass.Classname, C.SubType);
  try
    FStreamDataProvider.Reset;
    FStreamDataProvider.SaveRecord(ObjectIndex, AID, AWithDetail);
  except
    if FTransaction.InTransaction then
      FTransaction.Rollback;
    raise;
  end;
end;


procedure TgdcStreamSaver.PrepareForIncrementSaving(const ABasekey: TID = -1);
begin
  if ABaseKey > -1 then
  begin
    if ABaseKey <> FDataObject.OurBaseKey then
    begin
      FDataObject.TargetBaseKey := ABaseKey;
      FStreamDataProvider.GetRecordsWithInState;
    end;
  end;
end;


procedure TgdcStreamSaver.SetTransaction(const Value: TIBTransaction);
begin
  if Assigned(Value) then
  begin
    FTransaction := Value;
    FDataObject.Transaction := Value;
    FStreamDataProvider.Transaction := Value;
  end;
end;


procedure TgdcStreamSaver.SetSilent(const Value: Boolean);
begin
  SilentMode := Value;
  if Assigned(frmSQLProcess) and not Assigned(frmStreamSaver) then
    frmSQLProcess.Silent := Value;
end;


function TgdcStreamSaver.GetSilent: Boolean;
begin
  Result := SilentMode;
end;


procedure TgdcStreamSaver.SetReadUserFromStream(const Value: Boolean);
begin
  IsReadUserFromStream := Value;
end;


function TgdcStreamSaver.GetReadUserFromStream: Boolean;
begin
  Result := IsReadUserFromStream;
end;

procedure TgdcStreamSaver.SaveSettingToXMLFile(S: TStream);
var
  FStreamWriterReader: TgdcStreamXMLWriterReader;
begin
  if not Assigned(S) then
    raise Exception.Create(GetGsException(Self, 'SaveToStream: Не установлен поток'));

  FStreamWriterReader := TgdcStreamXMLWriterReader.Create(FDataObject, FStreamLoadingOrderList);
  try
    FStreamWriterReader.SaveXMLSettingToStream(S);
  finally
    FStreamWriterReader.Free;
  end;

  if StreamLoggingType in [slSimple, slAll] then
  begin
    Space;
    AddText(TimeToStr(Time) + ': Закончилось сохранение настройки в XML файл.'#13#10, clBlack, True);
    Space;
  end;

  if FTransaction.InTransaction then
    if FTrWasActive then
      FTransaction.CommitRetaining
    else
      FTransaction.Commit
  else
    FTransaction.Rollback;
end;


procedure TgdcStreamSaver.LoadSettingFromXMLFile(S: TStream);
var
  Obj: TgdcBase;
  CDS: TClientDataSet;
  OrderElement: TStreamOrderElement;
  FStreamWriterReader: TgdcStreamXMLWriterReader;
begin

  try
    if StreamLoggingType in [slSimple, slAll] then
    begin
      Space;
      AddText(TimeToStr(Time) + ': Началась загрузка настройки из XML файла.', clBlack);
    end;

    if Assigned(frmStreamSaver) then
      frmStreamSaver.SetupProgress(1, 'Чтение файла настройки...');

    FStreamWriterReader := TgdcStreamXMLWriterReader.Create(FDataObject, FStreamLoadingOrderList);
    try
      FStreamWriterReader.LoadXMLSettingFromStream(S);
    finally
      FStreamWriterReader.Free;
    end;

    if Assigned(frmStreamSaver) then
    begin
      frmStreamSaver.Done;
      frmStreamSaver.SetupProgress(FStreamLoadingOrderList.Count, 'Загрузка настройки...');
    end;

    if Assigned(frmSQLProcess) then
    begin
      with frmSQLProcess.pb do
      begin
        Min := 0;
        Max := FStreamLoadingOrderList.Count;
        Position := 0;
      end;
    end;

    //FStreamDataProvider.AnAnswer := 0;           // сбрасывать ли ответ на вопрос о замене объектов, при последовательной загрузке нескольких файлов?

    // загружаем записи из потока на базу
    while FStreamLoadingOrderList.PopNextElement(OrderElement) do
    begin
      Obj := FDataObject.gdcObject[OrderElement.DSIndex];
      CDS := FDataObject.ClientDS[OrderElement.DSIndex];
      if CDS.Locate(Obj.GetKeyField(Obj.SubType), OrderElement.RecordID, []) then
        FStreamDataProvider.LoadRecord(Obj, CDS)
      else
        raise Exception.Create('В потоке не найдена требуемая запись:'#13#10 +
          Obj.Classname + ' ' + Obj.SubType + ' (' + IntToStr(OrderElement.RecordID) + ')');

      if Assigned(frmStreamSaver) then
        frmStreamSaver.Step;

      if Assigned(frmSQLProcess) then
        frmSQLProcess.pb.Position := frmSQLProcess.pb.Position + 1;
    end;

    if FTransaction.InTransaction then
      if FTrWasActive then
        FTransaction.CommitRetaining
      else
        FTransaction.Commit
    else
      FTransaction.Rollback;

    if Assigned(frmStreamSaver) then
      frmStreamSaver.Done;

    if StreamLoggingType in [slSimple, slAll] then
    begin
      Space;
      AddText(TimeToStr(Time) + ': Закончилась загрузка настройки из XML файла.', clBlack);
      Space;
    end;

  except
    if FTransaction.InTransaction then
      FTransaction.Rollback;
    raise;
  end;

end;


function TgdcStreamSaver.GetReplaceRecordBehaviour: TReplaceRecordBehaviour;
begin
  Result := FStreamDataProvider.ReplaceRecordBehaviour;
end;


procedure TgdcStreamSaver.SetReplaceRecordBehaviour(const Value: TReplaceRecordBehaviour);
begin
  FStreamDataProvider.ReplaceRecordBehaviour := Value;
end;


function TgdcStreamSaver.GetIsAbortingProcess: Boolean;
begin
  Result := AbortProcess;
end;

procedure TgdcStreamSaver.SetIsAbortingProcess(const Value: Boolean);
begin
  AbortProcess := Value;
end;

function TgdcStreamSaver.GetStreamLogType: TgsStreamLoggingType;
begin
  Result := StreamLoggingType;
end;

procedure TgdcStreamSaver.SetStreamLogType(const Value: TgsStreamLoggingType);
begin
  if StreamLoggingType <> Value then
    StreamLoggingType := Value;
end;

function TgdcStreamSaver.GetNeedModifyList: TgdKeyIntAssoc;
begin
  Result := FStreamDataProvider.NeedModifyList;
end;

function TgdcStreamSaver.GetSaveWithDetailList: TgdKeyArray;
begin
  Result := FStreamDataProvider.SaveWithDetailList;
end;

procedure TgdcStreamSaver.SetNeedModifyList(const Value: TgdKeyIntAssoc);
begin
  FStreamDataProvider.NeedModifyList := Value;
end;

procedure TgdcStreamSaver.SetSaveWithDetailList(const Value: TgdKeyArray);
begin
  FStreamDataProvider.SaveWithDetailList := Value;
end;

end.
