unit gdcStreamSaver;

interface

uses
  gdcBase,              gdcBaseInterface,           classes,
  IBDatabase,           IBSQL,                      dbclient,
  contnrs,              dbgrids,                    comctrls,
  gd_KeyAssoc,          db,                         gsStorage,
  gsStreamHelper,       gdcSetting,                 gd_XMLWriterReader;

type
  // ��������� ������ ����� ��������
  //   lsNotLoaded - ������ �� ��������� (��������� ������ ������)
  //   lsModified - ������ ��������� ������ ������
  //   lsCreated - ������ ������� (������ �� ����)
  TLoadedRecordState = (lsNotLoaded, lsModified, lsCreated);
  // ��������� ��� �������� ������������� �������
  //   rrbDefault - �� ��������� ��� �������
  //   rrbAlways - ������ �������� �����
  //   rrbNever - ������� �� �������� �����
  //   rrbCompareDialog - �������� ������ ��������� ��������
  TReplaceRecordBehaviour = (rrbDefault, rrbAlways, rrbNever, rrbCompareDialog);
  // ��� �����������:
  //  slNone - �� �������� ������ � ���
  //  slSimple - �������� ������ �������� ��������� (������/����� �������� � �.�.)
  //  slAll - �������� ��� ���������
  TgsStreamLoggingType = (slNone, slSimple, slAll);

  TgsExtSettingFileType = (eftUnknown, eftFunction, eftForm, eftReportTemplate, eftStoredProcedure, eftTrigger, eftGrid);

  TXMLElementType =
    (etUnknown,                // ����������� �������
     etStream,                 // ���� ����� (��� ����������� ������ � XML ���������)
     etHeader,                 // ��������� ������
     etDataBaseList,           // ������ ��� ������ �� ������� RPL_DATABASE
     etDataBase,               //   ���� ���� ������
     etSender,                 // ID ����-��������� (�� ������� RPL_DATABASE)
     etReceiver,               // ID ������� ���� (�� ������� RPL_DATABASE)
     etReceivedRecordList,     // ������ �������, ��������� ������� ������������ ����-��������
     etReceivedRecord,         //   ���� ������
     etReferencedRecordList,   // ������ �������, ������� �� ���� ��������� � �����, ����� �� ��������������� ����������� �� ������� ����
     etReferencedRecord,       //   ���� ������
     etOrder,                  // ������� �������� �������
     etOrderItem,              //   ���� ������
     etData,                   // ������ ��������� ����������� � ������
     etDataset,                //   ���� �������

     etSetting,                // ���������
     etSettingHeader,          // ����� ���������
     etSettingPosList,         // ������ ������� ���������
     etSettingPos,             //   ������� ���������
     etSettingData,            // ������ ��������� (�� ���� DATA)

     etDatasetMetaData,        // ���������� ��������
     etDatasetField,           // ���� ��������
     etDatasetRowData,         // ������ ��������
     etDatasetRow             // ������ ��������
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

  TStreamObjectRecord = record
    ClassName: String;
    SubType: String;
    SetTable: String;
    gdcObject: TgdcBase;
    gdcSetObject: TgdcBase;
    CDS: TDataSet;
    ObjectForeignKeyFields: TStringList;
    ObjectForeignKeyClasses: TStringList;
    OneToOneTables: TStringList;
    ObjectCrossTables: TStringList;
    ObjectDetailReferences: TObjectList;
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
    procedure Clear; virtual;

    property Count: Integer read FCount;
    property Items[Index: Integer]: TStreamOrderElement read GetOrderElement;
  end;

  TgdcStreamLoadingOrderList = class(TStreamOrderList)
  private
    FIsLoading: Boolean;
    FNext: Integer;
  public
    constructor Create;
    procedure Clear; override;

    function PopNextElement(out Element: TStreamOrderElement): Boolean;
    function PopElementByID(const AID: TID; out Element: TStreamOrderElement): Boolean;

    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream);
  end;

  TLoadedRecordStateList = class(TgdKeyIntAssoc)
  private
    FStateArray: array of TLoadedRecordState;

    function GetStateByIndex(Index: Integer): TLoadedRecordState;
    procedure SetStateByIndex(Index: Integer; const Value: TLoadedRecordState);
    function GetStateByKey(Key: Integer): TLoadedRecordState;
    procedure SetStateByKey(Key: Integer; const Value: TLoadedRecordState);
  protected
    procedure Grow; override;
    procedure InsertItem(const Index, Value: Integer); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Delete(const Index: Integer); override;

    property StateByIndex[Index: Integer]: TLoadedRecordState read GetStateByIndex
      write SetStateByIndex;
    property StateByKey[Key: Integer]: TLoadedRecordState read GetStateByKey
      write SetStateByKey;
  end;

  TgdcStreamDataObject = class(TObject)
  private
    // ������������ �� �����
    FIsIncrementedStream: Boolean;
    FIncrDatabaseList: TStringList;
    // ��� ���������� � �����, � ������ ���������� RUID'� ������� ��������� ������� �� ������������
    // ��� �������� �� ������, � ������ ���������� RUID'� ������� ��������� ������� ������������ ����-�������� ������
    FReceivedRecords: array of TRuid;
    FReceivedRecordsCount: Integer;
    FReceivedRecordsSize: Integer;
    // ������ ������� �� �������� ������� "�� �����������\�� ���� ���������" � �����
    //  �� ��� ��� ���� ��������, �� ������ �� ������� ����������� � ������ �����������
    //  ��������, � ������ ������������ ID ������ � ������ � RUID
    FReferencedRecords: array of TStreamReferencedRecord;
    FReferencedRecordsCount: Integer;
    FReferencedRecordsSize: Integer;

    FOurBaseKey: TID;
    FTargetBaseKey: TID;
    FSourceBaseKey: TID;

    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;

    // ���� false, �� ��� ���������� ������ ������� �� ����� �����������
    //   ������ ������ � ������ � ������� ���� ������� �������� �������
    FIsSave: Boolean;

    // ������ �������� ���������� � �����, ����� �������� ������� ������-������� � ��������
    //  ������ ������, ��������� ������ � �.�.
    FObjectArray: array of TStreamObjectRecord;
    FCount: Integer;
    FSize: Integer;

    FSettingHeaderDataset: TDataset;
    FSettingPosDataset: TDataset;

    FStreamDBID: TID;
    FStreamVersion: Integer;

    function CheckIndex(const Index: Integer): Boolean;

    function GetReceivedRecord(Index: Integer): TRuid;
    function GetReferencedRecord(Index: Integer): TStreamReferencedRecord;

    function CreateBusinessObject(const AClassName: TgdcClassName; const ASubType: TgdcSubType = '';
      const ASetTableName: ShortString = ''): TgdcBase;
    function CreateDataset(ABusinessObject: TgdcBase): TDataSet;
    procedure FillReferences(var ADataObject: TStreamObjectRecord);

    function GetgdcObject(Index: Integer): TgdcBase;
    function GetClientDS(Index: Integer): TDataSet;
    function GetObjectDetailReferences(Index: Integer): TObjectList;
    function GetObjectCrossTables(Index: Integer): TStringList;
    procedure SetTransaction(const Value: TIBTransaction);
    function GetObjectForeignKeyFields(Index: Integer): TStringList;
    function GetObjectForeignKeyClasses(Index: Integer): TStringList;
    procedure SetTargetBaseKey(const Value: TID);
    function GetOneToOneTables(Index: Integer): TStringList;
  public
    constructor Create(ADatabase: TIBDatabase = nil; ATransaction:
      TIBTransaction = nil; const ASize: Integer = 32);
    destructor Destroy; override;

    function Add(const AClassName: TgdcClassName; const ASubType: TgdcSubType = '';
      const ASetTableName: ShortString = ''; const AObjectKey: Integer = -1; const AIsSettingObject: Boolean = False): Integer;
    procedure AddData(const Index: Integer; const AID: TID); overload;
    procedure AddData(const Index: Integer; AObj: TgdcBase); overload;
    procedure AddData(const ADataset: TDataset; AObj: TgdcBase); overload;

    // ������� ������� ��� �������� ���������� ���������
    procedure CreateSettingMetadata;

    function Find(const AClassName: TgdcClassName; const ASubType: TgdcSubType = ''; const ASetTableName: ShortString = ''): Integer;
    function GetObjectIndex(const AClassName: TgdcClassName; const ASubType: TgdcSubType = ''; const ASetTableName: ShortString = ''): Integer;
    function GetSetObject(const AClassName: TgdcClassName; const ASubType: TgdcSubType; const ASetTableName: ShortString): TgdcBase;
    // ������� ������ � ����������� ��������
    procedure Clear;

    procedure AddReceivedRecord(const AXID, ADBID: TID);
    procedure AddReferencedRecord(const AID, AXID, ADBID: TID);
    function FindReferencedRecord(const AID: TID): Integer;

    property ReceivedRecordsCount: Integer read FReceivedRecordsCount;
    property ReceivedRecord[Index: Integer]: TRuid read GetReceivedRecord;

    property ReferencedRecordsCount: Integer read FReferencedRecordsCount;
    property ReferencedRecord[Index: Integer]: TStreamReferencedRecord read GetReferencedRecord;

    property OurBaseKey: TID read FOurBaseKey write FOurBaseKey;
    property TargetBaseKey: TID read FTargetBaseKey write SetTargetBaseKey;
    property SourceBaseKey: TID read FSourceBaseKey write FSourceBaseKey;
    property DatabaseList: TStringList read FIncrDatabaseList;
    property IsIncrementedStream: Boolean read FIsIncrementedStream write FIsIncrementedStream;

    property Count: Integer read FCount;
    property gdcObject[Index: Integer]: TgdcBase read GetgdcObject;
    property ClientDS[Index: Integer]: TDataSet read GetClientDS;

    property SettingHeaderDataset: TDataset read FSettingHeaderDataset;
    property SettingPosDataset: TDataset read FSettingPosDataset;

    property ObjectForeignKeyFields[Index: Integer]: TStringList read GetObjectForeignKeyFields;
    property ObjectForeignKeyClasses[Index: Integer]: TStringList read GetObjectForeignKeyClasses;
    property OneToOneTables[Index: Integer]: TStringList read GetOneToOneTables;
    property ObjectCrossTables[Index: Integer]: TStringList read GetObjectCrossTables;
    property ObjectDetailReferences[Index: Integer]: TObjectList read GetObjectDetailReferences;

    property StreamDBID: TID read FStreamDBID write FStreamDBID;
    property StreamVersion: Integer read FStreamVersion write FStreamVersion;

    property Transaction: TIBTransaction read FTransaction write SetTransaction;
    property IsSave: Boolean read FIsSave write FIsSave;
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

    //FReplaceRecordBehaviour: TReplaceRecordBehaviour;
    FReplaceFieldList: TStringList;
    FIsLoadingSettingMetadata: Boolean;

    FIDMapping: TgdKeyIntAssoc; // ����� ���������������
    FUpdateList: TObjectList;   // ������ � ������� ����� ������, ��������� ���������� foreignkeys ����� ������� ��������� ������

    FReplaceRecordAnswer: Word;

    FSaveWithDetailList: TgdKeyArray;
    FNeedModifyList: TgdKeyIntAssoc;

    function GetIbsqlRPLRecordSelect: TIBSQL;
    function GetIbsqlRPLRecordInsert: TIBSQL;
    function GetIbsqlRPLRecordDelete: TIBSQL;

    procedure SetLoadingOrderList(const Value: TgdcStreamLoadingOrderList);
    procedure SetDataObject(const Value: TgdcStreamDataObject);
    //��������� ��� �������������� ������� ��� �������� ��� ����������� � ������-���������
    procedure SaveBindedObjects(const AObjectIndex: Integer; const AID: TID);
    // ��������� ������� ����������� ��� 1 � 1 � ������������ ������-�������
    procedure SaveOneToOne(const AObjectIndex: Integer; const AID: TID);
    //��������� ��������� ������� ��� ��
    procedure SaveDetail(const AObjectIndex: Integer; const AID: TID);
    //� ����������� �� ���� �������, ��������� ������������ �������
    // �������� ��� TgdcExplorer ����������� ������� ������� �� ��������
    procedure SaveSpecial(const AObjectIndex: Integer; const AID: TID);
    //��������� ��������� ��� ��
    procedure SaveSet(AObj: TgdcBase);

    // ��������� ������ ��� ��������� �������� �������� ����� ����������� � �����.
    function DoBeforeSaving(AObj: TgdcBase): Boolean;
    // ��������� ������ ��� ��������� �������� �������� ����� ����������� � �����.
    function DoAfterSaving(AObj: TgdcBase): Boolean;

    function GetNeedModifyFlagOnSaving(const AObjectKey: TID): Boolean;
    // ��������� ��������� �������� ������ �������� ������� ��� ������������ �� ����,
    //   ������� ����� ��������� �������
    function CheckNeedModify(ABaseRecord: TgdcBase; AStreamRecord: TDataSet): Boolean;
    // ��������� �� ������� RPL_RECORD ������������� ���������� ������ ������ � �����
    //  ��������, �� ��� ���������� �� �� ������� ����
    function CheckNeedSaveRecord(const AID: TID; AModified: TDateTime): Boolean;
    // ��������� �� ������� RPL_RECORD ������������� �������� ������ ������ �� ������ �� ����.
    function CheckNeedLoadingRecord(const XID, DBID: TID; AModified: TDateTime): Boolean;

    procedure LoadSetRecord(SourceDS: TDataSet; AObj: TgdcBase);

    procedure InsertRecord(SourceDS: TDataSet; TargetDS: TgdcBase);
    function CopyRecord(SourceDS: TDataSet; TargetDS: TgdcBase): Boolean;
    procedure ApplyDelayedUpdates(SourceKeyValue, TargetKeyValue: Integer);
    procedure AddToIDMapping(const AKey, AValue: Integer; const ARecordState: TLoadedRecordState);
    procedure RemoveFromLoadingOrder(const AID: Integer);

    procedure AddRecordToRPLRECORDS(const AID: TID; AModified: TDateTime);
    procedure SetTransaction(const Value: TIBTransaction);

    function GetRUIDList: String;

    property IbsqlRPLRecordSelect: TIBSQL read GetIbsqlRPLRecordSelect;
    property IbsqlRPLRecordInsert: TIBSQL read GetIbsqlRPLRecordInsert;
    property IbsqlRPLRecordDelete: TIBSQL read GetIbsqlRPLRecordDelete;
  public
    constructor Create(ADatabase: TIBDatabase = nil; ATransaction: TIBTransaction = nil);
    destructor Destroy; override;

    //��������� ������ ������� � ������-�������
    procedure SaveRecord(const AObject: TgdcBase; const ObjectIndex: Integer; const AID: TID; const AWithDetail: Boolean = true); overload;
    procedure SaveRecord(const ObjectIndex: Integer; const AID: TID; const AWithDetail: Boolean = true); overload;

    procedure LoadRecord(AObj: TgdcBase; CDS: TDataSet);
    // ��������� ������-���������
    procedure LoadSetRecords;
    procedure LoadReceivedRecords;
    // ��������� ����� � ������� ��������� �� ��
    procedure LoadSettingMetadata;

    // ���������� ������ ��� ������ �� ������ � �� ������� RPL_DATABASE,
    //  ���� � ������ ��������� ����� ����, ��������� �� � �������
    procedure ProcessDatabaseList;

    //���� � ������� RPL_RECORD ������ ������������ � ������� �������
    //  �� ������� ����, �� �� ���������� ������ �������. ���������� ��������� �� ������.
    procedure CheckNonConfirmedRecords;
    //���� ������ ��������� � ������� ���� � ��������� ������������� � ��������.
    //  ��������� ���������� ������ � TgdcStreamDataObject.
    procedure GetRecordsWithInState;

    procedure ClearNowSavedRecordsList;
    procedure Clear;

    property LoadingOrderList: TgdcStreamLoadingOrderList read FLoadingOrderList write SetLoadingOrderList;
    property DataObject: TgdcStreamDataObject read FDataObject write SetDataObject;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
    //property ReplaceRecordBehaviour: TReplaceRecordBehaviour read FReplaceRecordBehaviour write FReplaceRecordBehaviour;
    property ReplaceRecordAnswer: Word read FReplaceRecordAnswer write FReplaceRecordAnswer;

    property SaveWithDetailList: TgdKeyArray read FSaveWithDetailList write FSaveWithDetailList;
    property NeedModifyList: TgdKeyIntAssoc read FNeedModifyList write FNeedModifyList;
  end;

  TgdcStreamWriterReader = class(TObject)
  private
    FStream: TStream;

    FDataObject: TgdcStreamDataObject;
    FLoadingOrderList: TgdcStreamLoadingOrderList;

    procedure SetDataObject(const Value: TgdcStreamDataObject);
    procedure SetLoadingOrderList(const Value: TgdcStreamLoadingOrderList);
    procedure SetStream(const Value: TStream);
    function GetFileName: String;
    procedure SetFileName(const Value: String);
  protected
    FFileDir: String;            // 'd:\work\'
    FFileName: String;           // 'setting.gsf'
  public
    constructor Create(AObjectSet: TgdcStreamDataObject = nil; ALoadingOrderList: TgdcStreamLoadingOrderList = nil);
    destructor Destroy; override;

    procedure SaveToStream(S: TStream); virtual;
    procedure LoadFromStream(const S: TStream); virtual;

    property Stream: TStream read FStream write SetStream;
    property FileName: String read GetFileName write SetFileName;
    property DataObject: TgdcStreamDataObject read FDataObject write SetDataObject;
    property LoadingOrderList: TgdcStreamLoadingOrderList read FLoadingOrderList write SetLoadingOrderList;
  end;

  TgdcStreamBinaryWriterReader = class(TgdcStreamWriterReader)
  public
    procedure SaveToStream(S: TStream); override;
    procedure LoadFromStream(const S: TStream); override;
  end;

  TgdcStreamXMLWriterReader = class(TgdcStreamWriterReader)
  private
    // � XML ������ ��������� ���� ���������� $, ����� ����� ������� ������������
    //  ����� ��������� ���������� � $ � ��������� � _
    FFieldCorrList: TStringList;
    // ������ �� ������� �������������� �������
    FCurrentDataset: TDataset;
    FCurrentDatasetKey: Integer;
    FCurrentDatasetModifyFromStream: Boolean;
    // ���� ������� ������������ ������
    FCurrentRecordKey: TID;
    // ������ �� ������� ��
    FCurrentGdcObject: TgdcBase;

    function ExtFolderExists: Boolean;
    function GetExtFolderName(const AFileType: TgsExtSettingFileType): String;
    function GetExtFileExtrension(const AFileType: TgsExtSettingFileType): String;

    // � XML ���� ������ � ���� ��������� ����������� �� ���������
    //  ������� ������� ������ ������ ��� ����������
    procedure InternalSaveSettingToStream(XMLWriter: Tgd_XMLWriter);
    procedure InternalSaveToStream(XMLWriter: Tgd_XMLWriter);

    // ��������� BLOB-�������� ���������
    function ConvertStorageBlobValue(AField: TField): String;
    // ��������� �������������� �������� ��� ������������������ ����� <L>
    function ConvertToMultilineMemoTag(const AMemoValue: String): String;
    // ��������� ���������� � ������ ��������
    procedure WriteDataset(XMLWriter: Tgd_XMLWriter; CDS: TDataSet);
    // ��������� �������� ���� �������� � ���� ���������� ����
    procedure WriteDatasetField(XMLWriter: Tgd_XMLWriter; AField: TField);
    // ��������� ���������� �������� �� ������� ���� � ���������� ������
    function WriteValueToExtFile(const AValue: String; const AFileName: String; const AFileType: TgsExtSettingFileType): String;

    // ��������� ���������� �������� ������
    function ParseStorageBlobValue(const AFieldValue: String): String;
    // ��������� ��������������� �������� ���� �������� (<L>..</L>)
    function ParseMultilineMemoTag(const ATagValue: String): String;
    // ��������� ������ � ���� �������� �� �����
    procedure ReadFieldDefinition(XMLReader: Tgd_XMLReader; XMLElement: TgsXMLElement);
    // ��������� ��������� ������ �������� �� �����
    procedure ReadDatasetRecord(XMLReader: Tgd_XMLReader; XMLElement: TgsXMLElement);
    // ��������� ���������� �������� ������
    procedure ReadDatasetField(XMLReader: Tgd_XMLReader; XMLElement: TgsXMLElement; AField: TField);
    // ���������� ����� ����������� �������� �����
    function ReadValueFromExtFile(const AFileName: String): String;

    function GetElementType(const AElement: TgsXMLElement): TXMLElementType;
  public
    constructor Create(AObjectSet: TgdcStreamDataObject = nil; ALoadingOrderList: TgdcStreamLoadingOrderList = nil);
    destructor Destroy; override;

    procedure SaveToStream(S: TStream); override;
    procedure LoadFromStream(const S: TStream); override;

    function GetXMLSettingHeader(S: TStream; SettingHeader: TSettingHeader): Boolean;
  end;

  TgdcStreamSaver = class(TObject)
  private
    FStreamFormat: TgsStreamType;
    FFileName: String;

    FStreamDataProvider: TgdcStreamDataProvider;
    FStreamLoadingOrderList: TgdcStreamLoadingOrderList;
    FDataObject: TgdcStreamDataObject;

    FTransaction: TIBTransaction;
    FTrWasCreated: Boolean;
    FTrWasActive: Boolean;

    FSavingSetting: Boolean;
    // ������������ ��� ������������ ������ ��� ����������
    FErrorMessageForSetting: WideString;

    procedure SetTransaction(const Value: TIBTransaction);
    procedure SetSilent(const Value: Boolean);
    function GetSilent: Boolean;
    procedure SetReplicationMode(const Value: Boolean);
    function GetReplicationMode: Boolean;
    procedure SetReadUserFromStream(const Value: Boolean);
    function GetReadUserFromStream: Boolean;
    function GetIsAbortingProcess: Boolean;
    procedure SetIsAbortingProcess(const Value: Boolean);
    function GetStreamLogType: TgsStreamLoggingType;
    procedure SetStreamLogType(const Value: TgsStreamLoggingType);
    function GetNeedModifyList: TgdKeyIntAssoc;
    function GetSaveWithDetailList: TgdKeyArray;
    procedure SetNeedModifyList(const Value: TgdKeyIntAssoc);
    procedure SetSaveWithDetailList(const Value: TgdKeyArray);
    procedure SetStreamFormat(const Value: TgsStreamType);
    function GetReplaceRecordAnswer: Word;
    procedure SetReplaceRecordAnswer(const Value: Word);

    // ��������� ������� �� ������� ���������� ���������
    procedure SaveSettingData(const ASettingKey: TID);
  public
    constructor Create(ADatabase: TIBDatabase = nil; ATransaction: TIBTransaction = nil);
    destructor Destroy; override;

    // �������������� ������ ��� ������������� ����������, ��������� ���� TargetBaseKey
    //   ���������� ������ �� RPL_RECORD �� �������� irsIn(0)
    procedure PrepareForIncrementSaving(const ABasekey: TID = -1);

    // ��������� ������ ���������� ������� � �������� �� ������� �� ���� � ������
    procedure AddObject(AgdcObject: TgdcBase; const AWithDetail: Boolean = true);
    // ��������� ����� � ������� ���������� ���������
    procedure AddSetting(AgdcSetting: TgdcSetting);

    // ��������� ������ � ���������� �������� �� ������ � �����
    procedure SaveToStream(S: TStream);
    procedure SaveToFile(AFileName: String);
    // ��������� ������ �� ������ �� ����
    procedure LoadFromStream(S: TStream);
    procedure LoadFromFile(AFileName: String);
    // �������� ���������� � ���� ����������� ��������
    procedure Clear;

    // ������������ ��� ���������, ��������� ������ �� ������ �� ����
    procedure ActivateSetting(var WasMetaDataInSetting: Boolean; var AnAnswer: Word);

    property Silent: Boolean read GetSilent write SetSilent;
    property ReplicationMode: Boolean read GetReplicationMode write SetReplicationMode;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
    property ReadUserFromStream: Boolean read GetReadUserFromStream write SetReadUserFromStream;
    property IsAbortingProcess: Boolean read GetIsAbortingProcess write SetIsAbortingProcess;
    //property ReplaceRecordBehaviour: TReplaceRecordBehaviour read GetReplaceRecordBehaviour write SetReplaceRecordBehaviour;
    property ReplaceRecordAnswer: Word read GetReplaceRecordAnswer write SetReplaceRecordAnswer;
    property StreamLogType: TgsStreamLoggingType read GetStreamLogType write SetStreamLogType;
    property StreamFormat: TgsStreamType read FStreamFormat write SetStreamFormat;

    property FileName: String read FFileName write FFileName;

    property SaveWithDetailList: TgdKeyArray read GetSaveWithDetailList write SetSaveWithDetailList;
    property NeedModifyList: TgdKeyIntAssoc read GetNeedModifyList write SetNeedModifyList;

    property ErrorMessageForSetting: WideString read FErrorMessageForSetting;
  end;

  TgdRPLDatabase = class(TObject)
  private
    FID: TID;
    FName: String;
    FIsOurBase: Boolean;
    procedure SetID(const Value: TID);

    procedure SetDefaultValues;
  public
    constructor Create;

    property ID: TID read FID write SetID;
    property Name: String read FName;
    property IsOurBase: Boolean read FIsOurBase;
  end;

  function IsXML(const CheckStr: String): Boolean;

const
  cst_StreamVersionNew = 4;
  gsfNewVersion = 2;

implementation

uses
  SysUtils,                 at_sql_metadata,         gs_Exception,
  gd_security,              at_classes,              Windows,
  at_sql_parser,            at_sql_setup,            JclStrings,
  at_frmSQLProcess,         graphics,                gdcClasses,
  gdcConstants,             gd_directories_const,    IB,
  IBErrorCodes,             gdcMetadata,             gdcFilter,
  Storages,                 Forms,                   controls,
  at_dlgCompareRecords,     Dialogs,                 ComObj,
  gdc_frmStreamSaver,       zlib,                    gdcInvDocument_unit,
  flt_SafeConversion_unit,  JclMime,                 jclUnicode,
  gdcFunction,              gdcExplorer,             gdcMacros,
  gdcReport,                gdcLBRBTreeMetaData,     FileCtrl,
  gdcStorage,               gsDesktopManager,        gd_createable_form;

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
  EgsXMLParseException = class(Exception);
  EgsUnknownDatabaseKey = class(Exception);

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

  sqlInsertRPLRecordsIDStateEditionDate =
    'INSERT INTO ' +
    '  rpl_record (id, basekey, state, editiondate) ' +
    '  VALUES (:id, %d, :state, :editiondate)';

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
  sqlSelectRPLRecordsDateStateByRUID =
    'SELECT ' +
    '  rep.editiondate, ' +
    '  rep.state ' +
    'FROM ' +
    '  rpl_record rep ' +
    '  JOIN gd_ruid r ON r.id = rep.id ' +
    'WHERE ' +
    '  r.xid = %d AND r.dbid = %d';

  NEW_LINE = #13#10;
  RIGHTS_FIELD = ',ACHAG,AVIEW,AFULL,';

  XML_TAG_STREAM = 'STREAM';
  XML_TAG_HEADER = 'HEADER';
  XML_TAG_DATABASE_LIST = 'DATABASE_LIST';
  XML_TAG_DATABASE = 'DATABASE';
  XML_TAG_SENDER = 'SENDER';
  XML_TAG_RECEIVER = 'RECEIVER';
  XML_TAG_RECEIVED_RECORD_LIST = 'RECEIVED_RECORD_LIST';
  XML_TAG_RECEIVED_RECORD = 'RECEIVED_RECORD';
  XML_TAG_REFERENCED_RECORD_LIST = 'REFERENCED_RECORD_LIST';
  XML_TAG_REFERENCED_RECORD = 'REFERENCED_RECORD';
  XML_TAG_LOADING_ORDER = 'LOADING_ORDER';
  XML_TAG_LOADING_ORDER_ITEM = 'ITEM';
  XML_TAG_DATA = 'DATA';
  XML_TAG_DATASET = 'DATASET';

  XML_TAG_SETTING = 'SETTING';
  XML_TAG_SETTING_HEADER = 'SETTING_HEADER';
  XML_TAG_SETTING_POS_LIST = 'SETTING_POS_LIST';
  XML_TAG_SETTING_POS = 'SETTING_POS';
  XML_TAG_SETTING_DATA = 'SETTING_DATA';

  XML_TAG_DATASET_METADATA = 'METADATA';
  XML_TAG_DATASET_FIELD = 'FIELD';
  XML_TAG_DATASET_ROWDATA = 'ROWDATA';
  XML_TAG_DATASET_ROW = 'ROW';

  DETAIL_DOMAIN_SIMPLE = 'DMASTERKEY';
  DETAIL_DOMAIN_TREE = 'DPARENT';

  PARAM_RUID = 'RUID';
  PARAM_MODIFIED = 'MODIFIED';
  PARAM_MODIFY_FROM_STREAM = 'MODIFYFROMSTREAM';
  PARAM_INSERT_FROM_STREAM = 'INSERTFROMSTREAM';
  PARAM_SET_TABLE = 'SETTABLE';

  XML_P_FILE = 'file';
  XML_P_VERSION = 'version';
  XML_P_OBJECTKEY = 'objkey';
  XML_P_RECORDKEY = 'reckey';
  XML_P_ID = 'id';
  XML_P_XID = 'xid';
  XML_P_DBID = 'dbid';

  DEFAULT_ARRAY_SIZE = 32;

  EXT_FOLDER_NAME = 'data';

var
  RplDatabaseExists: Boolean;
  IsReadUserFromStream: Boolean;
  SilentMode: Boolean;
  IsReplicationMode: Boolean;
  AbortProcess: Boolean;
  StreamLoggingType: TgsStreamLoggingType;

function IsXML(const CheckStr: String): Boolean;
begin
  if (AnsiPos(XML_TAG_STREAM, CheckStr) > 0)
     or (AnsiPos(XML_TAG_SETTING, CheckStr) > 0)
     or (AnsiPos(XML_PROLOG, CheckStr) > 0)
     or (AnsiPos('<?XML', UpperCase(Trim(CheckStr))) = 1) then
    Result := True
  else
    Result := False;
end;

{ TgdcStreamDataObject }

constructor TgdcStreamDataObject.Create(ADatabase: TIBDatabase = nil;
  ATransaction: TIBTransaction = nil; const ASize: Integer = DEFAULT_ARRAY_SIZE);
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

  SetLength(FReceivedRecords, ASize);
  FReceivedRecordsSize := ASize;
  FReceivedRecordsCount := 0;
  SetLength(FReferencedRecords, ASize);
  FReferencedRecordsSize := ASize;
  FReferencedRecordsCount := 0;

  FIncrDatabaseList := TStringList.Create;

  FStreamDBID := -1;
  FTargetBaseKey := -1;
  FSourceBaseKey := -1;
  FOurBaseKey := -1;

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
    FObjectArray[I].gdcObject.Free;
    if Assigned(FObjectArray[I].gdcSetObject) then
      FObjectArray[I].gdcSetObject.Free;
    FObjectArray[I].CDS.Free;
    if FIsSave then
    begin
      FObjectArray[I].ObjectForeignKeyFields.Free;
      FObjectArray[I].ObjectForeignKeyClasses.Free;
      FObjectArray[I].OneToOneTables.Free;
      FObjectArray[I].ObjectCrossTables.Free;
      FObjectArray[I].ObjectDetailReferences.Free;
    end;
  end;

  SetLength(FObjectArray, 0);

  SetLength(FReceivedRecords, 0);
  SetLength(FReferencedRecords, 0);

  FIncrDatabaseList.Free;

  FDatabase := nil;
  FTransaction := nil;

  if Assigned(FSettingHeaderDataset) then
    FreeAndNil(FSettingHeaderDataset);
  if Assigned(FSettingPosDataset) then
    FreeAndNil(FSettingPosDataset);

  inherited;
end;

function TgdcStreamDataObject.Add(const AClassName: TgdcClassName; const ASubType: TgdcSubType = '';
  const ASetTableName: ShortString = ''; const AObjectKey: Integer = -1; const AIsSettingObject: Boolean = False): Integer;
var
  CurrentObjectIndex: Integer;
begin
  // ������� � ����� ������� ������� ��������� ������
  if AObjectKey > -1 then
  begin
    if AObjectKey > FCount then
    begin
      FCount := AObjectKey;
      CurrentObjectIndex := FCount;
    end
    else
    begin
      CurrentObjectIndex := AObjectKey;
    end
  end
  else
    CurrentObjectIndex := FCount;
  // ��������, ������� �� ������� �������
  if FCount >= FSize then
  begin
    FSize := (FCount + 1) * 2;
    SetLength(FObjectArray, FSize);
  end;
  Inc(FCount);

  if FObjectArray[CurrentObjectIndex].ClassName <> '' then
    raise Exception.Create('TgdcStreamDataObject.Add: ������� �������� �������� � ���������� OBJECTKEY');

  FObjectArray[CurrentObjectIndex].ClassName := AClassName;
  FObjectArray[CurrentObjectIndex].SubType := ASubType;
  FObjectArray[CurrentObjectIndex].SetTable := ASetTableName;

  // ��� ���������� �������� ������-������ � �������,
  //  �� ����� �������� ������� ��������� �� ���� ������������� � GetGdcObject � GetClientDS
  if FIsSave or AIsSettingObject then
  begin
    // ������� �� � ������ ��������
    FObjectArray[CurrentObjectIndex].gdcObject := CreateBusinessObject(AClassName, ASubType, ASetTableName);
    // ���� ������� ������� ���������, �� �������� ������-���������
    if ASetTableName <> '' then
      FObjectArray[CurrentObjectIndex].gdcSetObject :=
        CgdcBase(GetClass(AClassName)).CreateWithParams(nil, FDatabase, FTransaction, ASubType, 'All')
    else
      FObjectArray[CurrentObjectIndex].gdcSetObject := nil;
    // �������� � ������� ������� � ������
    FObjectArray[CurrentObjectIndex].CDS := CreateDataset(FObjectArray[CurrentObjectIndex].gdcObject);
    // ������� ������ ������ � ������ � ������� ����� ������ ������� �������� �������
    if FIsSave then
      Self.FillReferences(FObjectArray[CurrentObjectIndex]);
  end;

  Result := CurrentObjectIndex;
end;

procedure TgdcStreamDataObject.FillReferences(var ADataObject: TStreamObjectRecord);
var
  I, J: Integer;
  Obj: TgdcBase;
  LT: TStrings;
  TableList: TStrings;
  OL: TObjectList;
  ListTable, NotSavedField: String;
  R: TatRelation;
  F: TField;
  C: TgdcFullClass;
begin
  Obj := ADataObject.gdcObject;
  ListTable := Obj.GetListTable(Obj.SubType);
  NotSavedField := ',' + Obj.GetNotStreamSavedField(IsReplicationMode) + ',';

  TableList := TStringList.Create;
  try
    ADataObject.ObjectForeignKeyFields := TStringList.Create;
    ADataObject.ObjectForeignKeyClasses := TStringList.Create;
    ADataObject.OneToOneTables := TStringList.Create;

    if ListTable <> '' then
      TableList.Add(AnsiUpperCase(ListTable));

    // �������� ��� ������� �� ������� ���� ������ ��
    //  ������� ������� �������� �������, �� ������ ����������� � �������
    //  � ��������� � ������� ���� � ������
    LT := TStringList.Create;
    try
      (LT as TStringList).Duplicates := dupIgnore;
      // ������� ��� �������, �������� � ������
      GetTablesName(Obj.SelectSQL.Text, LT);
      // ������� ������ �������, ������� ����� ���� � ������ � ������� ������� � ���������������� ������� ������
      for I := 0 to LT.Count - 1 do
      begin
        if (TableList.IndexOf(LT[I]) = -1)
           and Obj.ClassType.InheritsFrom(GetBaseClassForRelation(LT[I]).gdClass) then
          TableList.Add(LT[I]);
      end;

      // ���������� �� ��������� ��������, � ������� ����-������
      for J := 0 to TableList.Count - 1 do
      begin
        R := atDatabase.Relations.ByRelationName(TableList.Strings[J]);
        if Assigned(R) then
        begin
          for I := 0 to R.RelationFields.Count - 1 do
          begin
            F := Obj.FindField(R.RelationName, R.RelationFields[I].FieldName);

            if Assigned(F) and (F.DataType = ftInteger)
              and Assigned(R.RelationFields[I].ForeignKey)
              and (AnsiPos(',' + Trim(R.RelationFields[I].FieldName) + ',', NotSavedField) = 0) then
            begin
              ADataObject.ObjectForeignKeyFields.Add(R.RelationName + '=' + R.RelationFields[I].FieldName);
              if Assigned(R.RelationFields[I].References) then
              begin
                C := GetBaseClassForRelation(R.RelationFields[I].References.RelationName);
                if Assigned(C.gdClass) then
                  ADataObject.ObjectForeignKeyClasses.Add(C.gdClass.Classname + '=' + C.SubType)
                else
                  ADataObject.ObjectForeignKeyClasses.Add(R.RelationFields[I].References.RelationName + '=NULL');
              end;
            end;
          end;
        end
        else
          raise EgdcNoTable.Create(TableList.Strings[J]);
      end;

      // ������ ������ ��� �������, ��������� ���� ������� ������������
      //  �������� ������� �� ���� ������, �.�. ������� ���������
      //  ������� ������ ����-�-������ � ����� ��������
      //  ������ � ����� ��������, � ������������ � ������� � �������
      //  �������, ������������ ������ ������ �������
      //  ������: gd_contact -- gd_company -- gd_companycode
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
              if IsSimpleKey and Assigned(Relation.PrimaryKey)
                and (Relation.PrimaryKey.ConstraintFields.Count = 1)
                and (ConstraintField = Relation.PrimaryKey.ConstraintFields[0])
                {!!!! ��� gd_document ����� ������ ������ ������� 1:1 � ��������� ������ ID ��� ��������}
                and (((AnsiCompareText(ListTable, 'GD_DOCUMENT') = 0)
                       and (AnsiCompareText(Relation.PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0))
                     or (AnsiCompareText(ListTable, 'GD_DOCUMENT') <> 0)) then
              begin
                ADataObject.OneToOneTables.Add(Relation.RelationName);
              end;
            end;
        end;
      finally
        OL.Free;
      end;

      // �����-�������
      LT.Clear;
      ADataObject.ObjectCrossTables := TStringList.Create;
      atDataBase.GetCrossByRelationName(TableList, LT);
      for I := 0 to LT.Count - 1 do
      begin
        if StrIPos('GD_LASTNUMBER', LT.Names[I]) = 1 then
          continue;
        if StrIPos('FLT_LASTFILTER', LT.Names[I]) = 1 then
          continue;
        ADataObject.ObjectCrossTables.Add(LT.Strings[I]);
      end;
    finally
      LT.Free;
    end;

    // ����-������ �� ��������� ��������
    OL := TObjectList.Create(False);
    try
      ADataObject.ObjectDetailReferences := TObjectList.Create(False);
      for I := 0 to TableList.Count - 1 do
        atDatabase.ForeignKeys.ConstraintsByReferencedRelation(TableList[I], OL, False);
      for I := 0 to OL.Count - 1 do
      begin
        if TatForeignKey(OL.Items[I]).IsSimpleKey and
          (AnsiPos(';' + TatForeignKey(OL.Items[I]).ConstraintField.Field.FieldName + ';',
            ';' + DETAIL_DOMAIN_SIMPLE + ';' + DETAIL_DOMAIN_TREE + ';') > 0) then
        begin
          if (TatForeignKey(OL[I]).Relation.RelationName = 'AC_ENTRY') or
             (TatForeignKey(OL[I]).Relation.RelationName = 'AC_RECORD') then
            continue;
          if Assigned(TatForeignKey(OL.Items[I]).Relation.PrimaryKey) then
            ADataObject.ObjectDetailReferences.Add(OL.Items[I])
          else
            raise EgdcIBError.Create('������ ��� ��������� ����� ������-������: ' +
              ' � ������� ' + TatForeignKey(OL.Items[I]).Relation.LName + ' ����������� ��������� ����!');
        end;
      end;
    finally
      OL.Free;
    end;

  finally
    TableList.Free;
  end;
end;

procedure TgdcStreamDataObject.AddData(const Index: Integer; AObj: TgdcBase);
var
  LocName: String;
  R: TatRelation;
begin
  if CheckIndex(Index) then
  begin
    if Assigned(frmStreamSaver) then
      with AObj do
        frmStreamSaver.SetProcessText(Format('%s%s  %s%s  (%s)',
          [GetDisplayName(SubType), NEW_LINE, FieldByName(GetListField(SubType)).AsString,
          NEW_LINE, FieldByName(GetKeyField(SubType)).AsString]));

    if StreamLoggingType = slAll then
      if AObj.SetTable = '' then
      begin
        with AObj do
          AddText(Format('����������: %s %s (%s)', [GetDisplayName(SubType),
            FieldByName(GetListField(SubType)).AsString, FieldByName(GetKeyField(SubType)).AsString]),
            clBlue);
      end
      else
      begin
        R := atDataBase.Relations.ByRelationName(AObj.SetTable);
        if Assigned(R) then
          LocName := R.LName
        else
          LocName := AObj.SetTable;

        with AObj do
          AddText(Format('����������: %s %s (%s) � ������� ��������� %s', [GetDisplayName(SubType),
            FieldByName(GetListField(SubType)).AsString, FieldByName(GetKeyField(SubType)).AsString,
            LocName]), clBlue);
      end;

    Self.AddData(FObjectArray[Index].CDS, AObj);
  end;
end;

procedure TgdcStreamDataObject.AddData(const ADataset: TDataset; AObj: TgdcBase);
var
  I: Integer;
  TableInfo: TgdcTableInfos;
  RUID: TRUID;
  F: TField;
  NotSavedField: String;
begin
  if Assigned(ADataset) and Assigned(AObj) then
  begin
    RUID := AObj.GetRUID;
    NotSavedField := ',' + AObj.GetNotStreamSavedField(IsReplicationMode) + ',';

    ADataset.Append;
    for I := 0 to AObj.FieldCount - 1 do
    begin
      // ��� ���������-�������� ����� ��������� ������ ����-��������� (S$...)
      if (AObj.SetTable = '') or IsSetField(AObj.Fields[I].FieldName) then
      begin
        F := ADataset.FindField(AObj.Fields[I].FieldName);
        if Assigned(F) then
        begin
          if AnsiPos(',' + F.FieldName + ',', NotSavedField) > 0 then
            F.Clear
          else
            F.Assign(AObj.Fields[I]);
        end;
      end;
    end;
    // ��� �����-������ ��� �� ����� ���� ����� � ���� �����������
    if AObj.SetTable = '' then
    begin
      ADataset.FieldByName('_' + PARAM_RUID).AsString := RuidToStr(RUID);

      TableInfo := AObj.GetTableInfos(AObj.SubType);
      // ����� ��������� ���� PARAM_MODIFIED ������ ���� ���� ����������� ���������� � ��
      if (tiCreationInfo in TableInfo) or (tiEditionInfo in TableInfo) then
        ADataset.FieldByName('_' + PARAM_MODIFIED).AsDateTime := AObj.EditionDate;
    end
    else
      ADataset.FieldByName('_' + PARAM_SET_TABLE).AsString := AObj.SetTable;
    // ���� ���� ������� �� ���������� �� �������� �� ��������� ��� ������� ������, �� �� ����� ��� ���������
    if False then
      ADataset.FieldByName('_' + PARAM_INSERT_FROM_STREAM).AsBoolean := False;       // TODO: ����� �� ��������� ��� ������ ��
    // ���� ���� ����������� �� ���������� �� �������� �� ��������� ��� ������� ������, �� �� ����� ��� ���������
    if AObj.ModifyFromStream <> AObj.NeedModifyFromStream(AObj.SubType) then
      ADataset.FieldByName('_' + PARAM_MODIFY_FROM_STREAM).AsBoolean := AObj.ModifyFromStream;
    ADataset.Post;
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
    Obj := FObjectArray[Index].gdcObject;

    if Obj.ID <> AID then
      Obj.ID := AID;
    if Obj.RecordCount > 0 then
    begin
      C := Obj.GetCurrRecordClass;
      if (Obj.ClassType <> C.gdClass) or (Obj.SubType <> C.SubType) then
      begin
        ObjectIndex := Self.GetObjectIndex(C.gdClass.Classname, C.SubType);
        Self.AddData(ObjectIndex, AID);
      end
      else
        Self.AddData(Index, Obj);
    end
    else
      AddWarning(Format('������� ��������� ������ ������� %s(%s) c ID = %d, �� ������������� � ��.',
        [Obj.Classname, Obj.SubType, AID]), clBlack);
  end;
end;

function TgdcStreamDataObject.Find(const AClassName: TgdcClassName;
  const ASubType: TgdcSubType = ''; const ASetTableName: ShortString = ''): Integer;
var
  ObjectCounter: Integer;
begin
  Result := -1;
  for ObjectCounter := 0 to FCount - 1 do
    if (FObjectArray[ObjectCounter].ClassName = AClassName)
       and (FObjectArray[ObjectCounter].SubType = ASubType)
       and (FObjectArray[ObjectCounter].SetTable = ASetTableName) then
      Result := ObjectCounter;
end;

function TgdcStreamDataObject.GetObjectIndex(const AClassName: TgdcClassName;
  const ASubType: TgdcSubType = ''; const ASetTableName: ShortString = ''): Integer;
begin
  Result := Self.Find(AClassName, ASubType, ASetTableName);
  if Result = -1 then
    Result := Self.Add(AClassName, ASubType, ASetTableName);
end;


function TgdcStreamDataObject.GetClientDS(Index: Integer): TDataSet;
var
  Dataset: TDataSet;
begin
  Result := nil;
  if CheckIndex(Index) then
  begin
    Dataset := FObjectArray[Index].CDS;
    // ���� ������� ��� �� ������ (��� ��������) - �������� ���
    if not Assigned(Dataset) then
    begin
      Dataset := TClientDataSet.Create(nil);
      Dataset.FieldDefs.Add('ID', ftInteger, 0, False);
      TClientDataset(Dataset).CreateDataset;
      TClientDataset(Dataset).LogChanges := False;
    end;
    FObjectArray[Index].CDS := Dataset;
    Result := Dataset;
  end;
end;

function TgdcStreamDataObject.GetgdcObject(Index: Integer): TgdcBase;
var
  BusinessObject: TgdcBase;
begin
  Result := nil;
  if CheckIndex(Index) then
  begin
    BusinessObject := FObjectArray[Index].gdcObject;
    // ���� �� ��� �� ������ (��� ��������) - �������� ���
    if not Assigned(BusinessObject) then
      BusinessObject :=
        CreateBusinessObject(FObjectArray[Index].Classname, FObjectArray[Index].SubType, FObjectArray[Index].SetTable);
    // ����� ���������� ������ �������� ������-�������, � �������� ByID
    try
      if BusinessObject.SubSet <> 'ByID' then
        BusinessObject.SubSet := 'ByID';
      if not BusinessObject.Active then
        BusinessObject.Open;
    except
    end;
    FObjectArray[Index].gdcObject := BusinessObject;
    Result := BusinessObject;
  end;
end;

function TgdcStreamDataObject.GetObjectDetailReferences(Index: Integer): TObjectList;
begin
  Result := nil;
  if CheckIndex(Index) then
    Result := FObjectArray[Index].ObjectDetailReferences;
end;

function TgdcStreamDataObject.GetObjectCrossTables(Index: Integer): TStringList;
begin
  Result := nil;
  if CheckIndex(Index) then
    Result := FObjectArray[Index].ObjectCrossTables;
end;

function TgdcStreamDataObject.GetObjectForeignKeyFields(Index: Integer): TStringList;
begin
  Result := nil;
  if CheckIndex(Index) then
    Result := FObjectArray[Index].ObjectForeignKeyFields;
end;

function TgdcStreamDataObject.GetObjectForeignKeyClasses(Index: Integer): TStringList;
begin
  Result := nil;
  if CheckIndex(Index) then
    Result := FObjectArray[Index].ObjectForeignKeyClasses;
end;

function TgdcStreamDataObject.GetOneToOneTables(Index: Integer): TStringList;
begin
  Result := nil;
  if CheckIndex(Index) then
    Result := FObjectArray[Index].OneToOneTables;
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
  Index := Self.Find(AClassName, ASubType, ASetTableName);
  if Index > -1 then
  begin
    Result := FObjectArray[Index].gdcSetObject;
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

function TgdcStreamDataObject.CreateDataset(ABusinessObject: TgdcBase): TDataSet;
var
  I: Integer;
  Dataset: TDataSet;
  FD: TFieldDef;
  NotSavedField: String;
begin
  // ���� �� ����������� � ����
  NotSavedField := ',' + ABusinessObject.GetNotStreamSavedField(IsReplicationMode) + ',';
  // ������� ��������������� ������-�������
  Dataset := TClientDataSet.Create(nil);
  for I := 0 to ABusinessObject.FieldDefs.Count - 1 do
  begin
    FD := ABusinessObject.FieldDefs[I];
    // �� ��������� ����������� ����, ���� ��� ��������� ���� �������,
    //  ��� �����-������ ��������� ������ 'S$...' ����
    if (not (DB.faReadOnly in FD.Attributes))
      and (not FD.InternalCalcField)
      and (AnsiPos(',' + AnsiUpperCase(FD.Name) + ',', RIGHTS_FIELD) = 0)
      and ((ABusinessObject.SetTable = '') or IsSetField(FD.Name))
      and (AnsiPos(',' + FD.Name + ',', NotSavedField) = 0) then
    begin
      Dataset.FieldDefs.Add(FD.Name, FD.DataType, FD.Size, False);
    end;
  end;
  // ��������� ����
  Dataset.FieldDefs.Add('_' + PARAM_RUID, ftString, 21, False);
  Dataset.FieldDefs.Add('_' + PARAM_MODIFIED, ftDateTime, 0, False);
  Dataset.FieldDefs.Add('_' + PARAM_INSERT_FROM_STREAM, ftBoolean, 0, False);
  Dataset.FieldDefs.Add('_' + PARAM_MODIFY_FROM_STREAM, ftBoolean, 0, False);
  Dataset.FieldDefs.Add('_' + PARAM_SET_TABLE, ftString, 60, False);

  with Dataset as TClientDataset do
  begin
    CreateDataSet;
    Open;
    LogChanges := False;
  end;

  Result := Dataset;
end;

function TgdcStreamDataObject.CreateBusinessObject(const AClassName: TgdcClassName; const ASubType: TgdcSubType = '';
  const ASetTableName: ShortString = ''): TgdcBase;
var
  BObject: TgdcBase;
  BaseState: TgdcStates;
begin
  // ������� ������-������
  BObject := CgdcBase(GetClass(AClassName)).CreateWithParams(nil, FDatabase, FTransaction, ASubType, 'ByID');
  BObject.ReadTransaction := FTransaction;
  if not FIsSave then
  begin
    BaseState := BObject.BaseState;
    Include(BaseState, sLoadFromStream);
    BObject.BaseState := BaseState;
  end;
  BObject.SetTable := ASetTableName;
  BObject.Open;
  
  // ������ ��������� � �������� ������-������
  Result := BObject;
end;

procedure TgdcStreamDataObject.Clear;
var
  I: Integer;
begin
  // ������� ������ � ����������� �������� � ��������� � ���� ��������
  for I := 0 to FCount - 1 do
  begin
    FObjectArray[I].gdcObject.Free;
    if Assigned(FObjectArray[I].gdcSetObject) then
      FObjectArray[I].gdcSetObject.Free;
    FObjectArray[I].CDS.Free;

    if Assigned(FObjectArray[I].ObjectForeignKeyFields) then
      FObjectArray[I].ObjectForeignKeyFields.Clear;
    if Assigned(FObjectArray[I].ObjectForeignKeyClasses) then
      FObjectArray[I].ObjectForeignKeyClasses.Clear;
    if Assigned(FObjectArray[I].OneToOneTables) then
      FObjectArray[I].OneToOneTables.Clear;
    if Assigned(FObjectArray[I].ObjectCrossTables) then
      FObjectArray[I].ObjectCrossTables.Clear;
    if Assigned(FObjectArray[I].ObjectDetailReferences) then
      FObjectArray[I].ObjectDetailReferences.Clear;
  end;
  // ������� ������ ������ �� �������
  SetLength(FObjectArray, 0);
  SetLength(FReceivedRecords, 0);
  SetLength(FReferencedRecords, 0);
  // ������� ���������������� ������
  FIncrDatabaseList.Clear;

  // ������ ����������������� ������� ������
  FCount := 0;
  FSize := DEFAULT_ARRAY_SIZE;
  SetLength(FObjectArray, FSize);

  FReceivedRecordsSize := DEFAULT_ARRAY_SIZE;
  FReceivedRecordsCount := 0;
  SetLength(FReceivedRecords, FReceivedRecordsSize);

  FReferencedRecordsSize := DEFAULT_ARRAY_SIZE;
  FReferencedRecordsCount := 0;
  SetLength(FReferencedRecords, FReferencedRecordsSize);

  if Assigned(FSettingHeaderDataset) then
    FreeAndNil(FSettingHeaderDataset);
  if Assigned(FSettingPosDataset) then
    FreeAndNil(FSettingPosDataset);
end;

procedure TgdcStreamDataObject.CreateSettingMetadata;
var
  gdcObject: TgdcBase;
begin
  if not Assigned(FSettingHeaderDataset) then
  begin
    gdcObject := CreateBusinessObject('TgdcSetting', '', '');
    try
      FSettingHeaderDataset := CreateDataset(gdcObject);
    finally
      FreeAndNil(gdcObject);
    end;
  end;
  // ���� ������� ��� ������� ��������� �� ������ - �������, � �������� ������
  if not Assigned(FSettingPosDataset) then
  begin
    gdcObject := CreateBusinessObject('TgdcSettingPos', '', '');
    try
      FSettingPosDataset := CreateDataset(gdcObject);
    finally
      FreeAndNil(gdcObject);
    end;
  end;
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

  FReplaceRecordAnswer := mrNone;
  FIsLoadingSettingMetadata := False;

  FIDMapping := TLoadedRecordStateList.Create;
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
begin
  // ��� ������� Escape ������� �������
  if AbortProcess or ((not SilentMode) and frmSQLProcess.Active and ((GetAsyncKeyState(VK_ESCAPE) shr 1) <> 0)) then
  begin
    if (not AbortProcess) and
       (Application.MessageBox('���������� ���������� ������?', '��������', MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL) = IDYES) then
    begin
      AbortProcess := True;
    end;  
    Exit;
  end;

  // ���� ������ ��� ����������� ������ �� ���� ��� ��������� � ������
  if (FDataObject.FindReferencedRecord(AID) > -1) or (FLoadingOrderList.Find(AID, ObjectIndex) > -1) then
    Exit;

  // ��� ������������ ����������� �� ����� ��������� ����������� ������ (ID < 147000000)
  //  ������������ ��� ��� ���� �� ���� �����
  if (FDataObject.TargetBaseKey > -1) and (AID < cstUserIDStart) then
  begin
    gdcBaseManager.GetRUIDByID(AID, XID, DBID);
    FDataObject.AddReferencedRecord(AID, XID, DBID);
    Exit;
  end;

  if AObject.ID <> AID then
    AObject.ID := AID;

  if AObject.RecordCount = 0 then
  begin
    AddMistake(AObject.ClassName + ': �� ������� ������ � ID = ' + IntToStr(AID), clRed);
    // ���� �������� ����������, �� �� ����� ��������� ���������� ���������
    if SilentMode then
      Exit
    else
      raise EgdcIDNotFound.Create(AObject.ClassName + ': �� ������� ������ � ID = ' + IntToStr(AID));  
  end;

  // ���� ������� ������ ������������ ������ �������
  //  ������, �� �������� ������ �� ��� ����
  C := AObject.GetCurrRecordClass;
  if (AObject.ClassType <> C.gdClass) or (AObject.SubType <> C.SubType) then
  begin
    Index := FDataObject.GetObjectIndex(C.gdClass.Classname, C.SubType);
    Self.SaveRecord(Index, AID, AWithDetail);
  end
  else
  begin
    // ���������\������ ���� "�������������� �� ������"
    AObject.ModifyFromStream := GetNeedModifyFlagOnSaving(AID);

    // ��� ������ ����������� �� ����� ��������� ����������, � ���� ����������.
    //   ������������ ������ ����� ��������� � ������ ����������� �������
    if IsReplicationMode and (AObject.InheritsFrom(TgdcMetaBase) or AObject.InheritsFrom(TgdcBaseDocumentType)) then
    begin
      gdcBaseManager.GetRUIDByID(AID, XID, DBID);
      FDataObject.AddReferencedRecord(AID, XID, DBID);
      Exit;
    end;

    // ��������� ������ ��� ��������� �������� �������� ����� ����������� � �����.
    // ���� ����� false, ������ ������ �� ����� ��������� � �����
    // (��������: c�������� ������ �� ���������)
    if DoBeforeSaving(AObject) then
    begin

      // ���� ����� ������������, �� �������� �� ������� RPL_RECORD ������������� ���������� ������
      if CheckNeedSaveRecord(AID, AObject.EditionDate) then
      begin
        if FNowSavedRecords.Find(AID, ObjectIndex) = -1 then
        begin
          FNowSavedRecords.AddItem(AID, ObjectIndex);
          // ��������� ������ �������
          FDataObject.AddData(ObjectIndex, AID);
          SaveBindedObjects(ObjectIndex, AID);
        end;

        SaveSpecial(ObjectIndex, AID);

        // ����� �������� ������������� ���������� �������, �������� �� ��� ���������� � �������� ����
        if (FDataObject.FindReferencedRecord(AID) = -1) and (FLoadingOrderList.Find(AID, ObjectIndex) = -1) then
        begin
          // ��������� ������� �������� �������
          FLoadingOrderList.AddItem(AID, ObjectIndex);
          // �������� ������ � �������� ������� � ��� ����������
          if FDataObject.TargetBaseKey > -1 then
          begin
            IbsqlRPLRecordInsert.Close;
            IbsqlRPLRecordInsert.ParamByName('ID').AsInteger := AID;
            IbsqlRPLRecordInsert.ParamByName('STATE').AsInteger := Integer(irsOut);
            IbsqlRPLRecordInsert.ParamByName('EDITIONDATE').AsDateTime := AObject.EditionDate;
            IbsqlRPLRecordInsert.ExecQuery;
          end;

          SaveOneToOne(ObjectIndex, AID);
          SaveSet(AObject);
        end;
      end
      else
      begin
        FDataObject.AddReferencedRecord(AID, XID, DBID);
      end;

      // ��������� ������ ��� ��������� �������� �������� ����� ���������� � �����.
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

  // ������� � ����� ������� �� ������� ��������� ����-������
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

      // ����� �������: �� ��������� ������������, ����� � ������ ���� ����-������ �� ��� �� ������
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
              frmStreamSaver.AddWarning(
                Format('� �������� ���������� �������� ������.' + NEW_LINE+
                '� ������� %s � ���� %s ����������' + NEW_LINE+
                '������ �� ������ ���� %s' + NEW_LINE +
                '� ��������������� %d, ������,' + NEW_LINE +
                '����� ������ � ���� ������ �� ����������.',
                  [RelationName, FieldName,
                  BindedClassName + BindedSubType,
                  Obj.FieldByName(RelationName, FieldName).AsInteger]));
            AddWarning(
              Format('� �������� ���������� �������� ������.' + NEW_LINE +
              '� ������� %s � ���� %s ����������' + NEW_LINE +
              '������ �� ������ ���� %s' + NEW_LINE +
              '� ��������������� %d, ������,' + NEW_LINE +
              '����� ������ � ���� ������ �� ����������.',
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
    // ���� ����������� ������ - ��� ������� ������ (�� ������)
    if TatForeignKey(ObjDetailReferences.Items[I]).ConstraintField.Field.FieldName = DETAIL_DOMAIN_SIMPLE then
    begin
      FIBSQL.Close;
      //�� �� ��������� ���� ������� �� ������� ��������� ����, �.�. � ������ ����� ������� ������ ����� �������
      FIBSQL.SQL.Text := Format('SELECT DISTINCT %s FROM %s WHERE %s = %s ',
        [TatForeignKey(ObjDetailReferences[I]).Relation.PrimaryKey.ConstraintFields[0].FieldName,
        TatForeignKey(ObjDetailReferences[I]).Relation.RelationName,
        TatForeignKey(ObjDetailReferences[I]).ConstraintField.FieldName, IntToStr(AID)]);
      FIBSQL.ExecQuery;
      if FIBSQL.RecordCount > 0 then
      begin
        KeyArray := TgdKeyArray.Create;
        try
          // �������� ������ ���������������� ��������� ��������
          while not FIBSQL.Eof do
          begin
            if KeyArray.IndexOf(FIBSQL.Fields[0].AsInteger) = -1 then
              KeyArray.Add(FIBSQL.Fields[0].AsInteger);
            FIBSQL.Next;
          end;
          //������� ������� ����� �� ������� id, �.�. ��������� ������� � ����� ������� ����� ������ ������ � ��������
          C := GetBaseClassForRelationByID(TatForeignKey(ObjDetailReferences[I]).Relation.RelationName,
            KeyArray.Keys[0], FTransaction);
          if Assigned(C.gdClass) then
          begin
            ObjectIndex := FDataObject.GetObjectIndex(C.gdClass.Classname, C.SubType);
            for J := 0 to KeyArray.Count - 1 do
              Self.SaveRecord(ObjectIndex, KeyArray.Keys[J]);
          end;
        finally
          KeyArray.Free;
        end;
      end;
    end
    // ���� ����������� ������ - ������
    else if TatForeignKey(ObjDetailReferences.Items[I]).ConstraintField.Field.FieldName = DETAIL_DOMAIN_TREE then
    begin
      FIBSQL.Close;
      //�� �� ��������� ���� ������� �� ������� ��������� ����, �.�. � ������ ����� ������� ������ ����� �������
      FIBSQL.SQL.Text := Format('SELECT DISTINCT %s FROM %s WHERE %s = %s ',
        [TatForeignKey(ObjDetailReferences[I]).Relation.PrimaryKey.ConstraintFields[0].FieldName,
        TatForeignKey(ObjDetailReferences[I]).Relation.RelationName,
        TatForeignKey(ObjDetailReferences[I]).ConstraintField.FieldName, IntToStr(AID)]);
      FIBSQL.ExecQuery;
      if FIBSQL.RecordCount > 0 then
      begin
        KeyArray := TgdKeyArray.Create;
        try
          // �������� ������ ���������������� ��������� ��������
          while not FIBSQL.Eof do
          begin
            if KeyArray.IndexOf(FIBSQL.Fields[0].AsInteger) = -1 then
              KeyArray.Add(FIBSQL.Fields[0].AsInteger);
            FIBSQL.Next;
          end;

          for J := 0 to KeyArray.Count - 1 do
          begin
            //������� ������� ����� ��� ������� ID, �.�. � ������ ����� ���� ��������� ��������� �������
            C := GetBaseClassForRelationByID(TatForeignKey(ObjDetailReferences[I]).Relation.RelationName,
              KeyArray.Keys[J], FTransaction);
            if Assigned(C.gdClass) then
            begin
              ObjectIndex := FDataObject.GetObjectIndex(C.gdClass.Classname, C.SubType);
              Self.SaveRecord(ObjectIndex, KeyArray.Keys[J]);
            end;
          end;
        finally
          KeyArray.Free;
        end;
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
              ObjectIndex := FDataObject.GetObjectIndex('TgdcRelationField');
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
              ObjectIndex := FDataObject.GetObjectIndex(Classname);
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

  if Obj is TgdcInvDocumentLine then
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

  if Obj is TgdcFunction then
  begin
    // �������� ������� �� ������� ������� ������ �������
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
          ObjectIndex := FDataObject.GetObjectIndex('TgdcFunction');
          Self.SaveRecord(ObjectIndex, FunctionKeyArray.Keys[I]);
        end;
      finally
        FunctionKeyArray.Free;
      end;
    end;
    Exit;
  end;

  if Obj is TgdcExplorer then
  begin
    // ���� �� ����������� ������ ������������� ���������� �������
    if Obj.FieldByName('cmdtype').AsInteger = 1 then
    begin
      AnID := gdcBaseManager.GetIDByRUIDString(Obj.FieldByName('cmd').AsString);
      if AnID > 0 then
      begin
        ObjectIndex := FDataObject.GetObjectIndex('TgdcFunction');
        Self.SaveRecord(ObjectIndex, AnID);
      end;
    end;
    Exit;
  end;

  if Obj is TgdcMacrosGroup then
  begin
    FIBSQL.Close;
    FIBSQL.SQL.Text := 'SELECT FIRST(1) id FROM evt_object WHERE macrosgroupkey = :mgk';
    FIBSQL.ParamByName('mgk').AsInteger := AID;
    FIBSQL.ExecQuery;
    if FIBSQL.RecordCount > 0 then
    begin
      ObjectIndex := FDataObject.GetObjectIndex('TgdcDelphiObject');
      Self.SaveRecord(ObjectIndex, FIBSQL.FieldByName('ID').AsInteger);
    end;
    Exit;
  end;

  if Obj is TgdcReportGroup then
  begin
    FIBSQL.Close;
    FIBSQL.SQL.Text := 'SELECT FIRST(1) id FROM evt_object WHERE reportgroupkey = :rgk';
    FIBSQL.ParamByName('rgk').AsInteger := AID;
    FIBSQL.ExecQuery;
    if FIBSQL.RecordCount > 0 then
    begin
      ObjectIndex := FDataObject.GetObjectIndex('TgdcDelphiObject');
      Self.SaveRecord(ObjectIndex, FIBSQL.FieldByName('ID').AsInteger);
    end;
    Exit;
  end;

  if Obj is TgdcStoredProc then
  begin
    if AnsiPos(UserPrefix, AnsiUpperCase(Obj.FieldByName('procedurename').AsString)) = 1 then
      SaveToStreamDependencies(Obj, Obj.FieldByName('procedurename').AsString);
    Exit;
  end;

  if Obj is TgdcField then
  begin
    SaveToStreamDependencies(Obj, Obj.FieldByName('fieldname').AsString);
    Exit;
  end;

  if Obj is TgdcIndex then
  begin
    SaveToStreamDependencies(Obj, Obj.FieldByName('indexname').AsString);
    Exit;
  end;

  if Obj is TgdcTrigger then
  begin
    SaveToStreamDependencies(Obj, Obj.FieldByName('triggername').AsString);
    Exit;
  end;

  if Obj is TgdcGenerator then
  begin
    SaveToStreamDependencies(Obj, Obj.FieldByName('generatorname').AsString);
    Exit;
  end;

  if Obj is TgdcCheckConstraint then
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
      if Assigned(C.gdClass) then
      begin
        ObjectIndex := FDataObject.GetObjectIndex(C.gdClass.Classname, C.SubType);
        ObjectSetIndex := FDataObject.GetObjectIndex(C.gdClass.Classname, C.SubType, CL.Names[I]);
        // ������� ������ �� ���� � ������ �� master-detail � ������� ��������
        TempObj := FDataObject.GetSetObject(C.gdClass.Classname, C.SubType, CL.Names[I]);
        TempObj.Close;
        if TempObj.SetTable <> CL.Names[I] then
          TempObj.SetTable := CL.Names[I];
        TempObj.MasterSource := CrossDS;
        // � �������-��������� ��������� ����� �� �������� ModifyFromStream,
        //  ��� � �������� ������� � ���������
        TempObj.ModifyFromStream := GetNeedModifyFlagOnSaving(AObj.ID);
        TempObj.Open;
        TempObj.First;
        while not TempObj.Eof do
        begin
          if SetKeyArray.IndexOf(TempObj.ID) = -1 then
            SetKeyArray.Add(TempObj.ID);
          // ��������� ���������
          FDataObject.AddData(ObjectSetIndex, TempObj);
          TempObj.Next;
        end;
        TempObj.Close;

        // ��������� ������ ��������� ������ � ��������� (��� ��������� ��������)
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
  CDS: TDataSet;
  KeyFieldName: String;
  TargetKeyInt, SourceKeyInt: TID;
  LoadedRecordState: TLoadedRecordState;
begin
  if not (TargetDS.State in [dsInsert, dsEdit]) then
    TargetDS.Edit;
     
  NeedAddToIDMapping := True;
  LoadedRecordState := lsCreated;
  Result := False;
  RUOL := nil;
  try
    KeyFieldName := TargetDS.GetKeyField(TargetDS.SubType);
    TargetKeyInt := TargetDS.FieldByName(KeyFieldName).AsInteger;
    SourceKeyInt := SourceDS.FieldByName(KeyFieldName).AsInteger;
    //���������� �� ����� �� ������ � ��������� �� �������� � ��� ������
    for I := 0 to SourceDS.FieldCount - 1 do
    begin
      SourceField := SourceDS.Fields[I];
      TargetField := TargetDS.FindField(SourceField.FieldName);

      // ���� ��������� ������ ��������� �������, � � ��� ������� ������ �������� ����� ����
      //   �� �� ����� �������������� ��� ��������� �� ������
      if (FReplaceFieldList.Count > 0) and (FReplaceFieldList.IndexOf(SourceField.FieldName) <> -1) then
        Continue;

      //���� �� ����� ���� � ����� �������, �� ������ � ����� ������� ��� �����������
      if Assigned(TargetField) then
      begin
        R := atDatabase.Relations.ByRelationName(TargetDS.RelationByAliasName(TargetField.FieldName));

        // ��������� ������ ��� � ����� ��������� ����������
        if R = nil then
        begin
          //���� ��� �������� ����, �� ��������� � ���������� ����
          if (AnsiCompareText(SourceField.FieldName, KeyFieldName) = 0) then
            Continue;

          if (TargetField.DataType = ftString) and (SourceField.AsString = '') then
            TargetField.AsString := ''
          else
            TargetField.Assign(SourceField);
          Continue;
        end;

        // ����� ������� ����� �������� ��� ������-������
        if AnsiPos(',' + AnsiUpperCase(TargetField.FieldName) + ',', RIGHTS_FIELD) > 0 then
          Continue;

        //���� ��� ���� ��� �������� "��� ������������", �� ��������� �������� ������������
        if (AnsiPos(';' + AnsiUpperCase(TargetField.FieldName) + ';', editorfield) > 0)
           and (not IsReadUserFromStream) then
        begin
          TargetField.AsInteger := IBLogin.ContactKey;
          Continue;
        end;

        //���� ��� ������ ��������
        if (TargetDS is TgdcDocument) and (TargetField.FieldName = fnDOCUMENTKEY) and (TargetField.Value > 0) then
          Continue;

        //���� ��� ������ �������� � ��������� ���� Companykey, �� ������� ��� �������� �� ������� ��������
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
            //���� ��� �������� ���� � ��� �������� �������, �� ������ ��� � ����� ���������������
            Key := FIDMapping.IndexOf(SourceField.AsInteger);
            if Key <> -1 then
              Key := FIDMapping.ValuesByIndex[Key];
            if Key > -1 then
            begin
              TargetField.AsInteger := Key;
              NeedAddToIDMapping := False;
            end;
          end;
          //���� ��� �������� ����, �� ��������� � ���������� ����
          Continue;
        end;

        //���� ��� ����-������
        if (F <> nil) and (F.References <> nil) then
        begin
          //���� ��� ���� ��������� �� ��������, �� �������� ��� �������� ��������� ����
          if (SourceField.AsInteger = SourceKeyInt) and (TargetKeyInt > 0) then
            Key := TargetKeyInt
          else
          begin
            //���� ��� � ����� ���������������
            Key := FIDMapping.IndexOf(SourceField.AsInteger);
            if Key <> -1 then
            begin
              Key := FIDMapping.ValuesByIndex[Key];
              IsNull := Key = -1;
            end;
          end;

          // ���� ��������� ������������ ����� ��� ����� �� �����������, �� ��������� ������
          //  ����� ���� �� ��������� � ������, ������ ��� �������� ������������ ID - XID+DBID
          if (Key = -1) and (FDataObject.ReferencedRecordsCount > 0) then
          begin
            ReferencedRecordIndex := FDataObject.FindReferencedRecord(SourceField.AsInteger);
            if ReferencedRecordIndex > -1 then
            begin
              ReferencedRecordNewID :=
                gdcBaseManager.GetIDByRUID(FDataObject.ReferencedRecord[ReferencedRecordIndex].RUID.XID, FDataObject.ReferencedRecord[ReferencedRecordIndex].RUID.DBID);
              if ReferencedRecordNewID > -1 then
              begin
                Key := ReferencedRecordNewID;
                AddToIDMapping(SourceField.AsInteger, Key, lsNotLoaded);
              end;
            end;
          end;

          if (Key = -1) and (FLoadingOrderList.Find(SourceField.AsInteger) <> -1) and
            (SourceField.AsInteger <> SourceKeyInt) then
          begin

            // ���� ������ �� ������, ������������ ��� ����������, ��� �� ���������,
            //   �� ������� �������� ������� ������ � �������� ������� ����������� ��� ������
            if TargetField.Required and FLoadingOrderList.PopElementByID(SourceField.AsInteger, OrderElement) then
            begin
              TargetDS.Cancel;
              Obj := FDataObject.gdcObject[OrderElement.DSIndex];
              CDS := FDataObject.ClientDS[OrderElement.DSIndex];
              if CDS.Locate(Obj.GetKeyField(Obj.SubType), OrderElement.RecordID, []) then
                Self.LoadRecord(Obj, CDS)
              else
                raise EgdcIDNotFound.Create('� ������ �� ������� ��������� ������: ' +
                  Obj.Classname + ' ' + Obj.SubType + ' (' + IntToStr(OrderElement.RecordID) + ')');
              Exit;
            end
            else
            begin
              // �����, ������� ���� � ������ ��� ���������� ����� �������� ����������� ������
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
              //���� �� �� ����� ���� ������ � ��� �� �������� "�����������" �������
              //������� ��� ����, ����� ����� ������ ��������� �����������
              //����� ������ ����� ���������� �� ���������� � ����� �� ������ ��������
              //��������, � ����� �� ����������� ��������� ����-������
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

    //����������� id �� ������ ��������
    if (SourceKeyInt < cstUserIDStart) and not FIsLoadingSettingMetadata then
      TargetDS.FieldByName(KeyFieldName).AsInteger := SourceKeyInt;

    try
      if TargetDS.State = dsEdit then
      begin
        try
          TargetDS.Post;
          LoadedRecordState := lsModified;
          if StreamLoggingType = slAll then
            AddText('������ �������� ������� �� ������!', clBlack);
        except
          {on E: EIBError do
          begin
            if (E.IBErrorCode = isc_no_dup) or (E.IBErrorCode = isc_except) then
            begin
              //�� ����� ������ �� ����� � ���������� �������� ��
              //������ ������ - ������ ��������� ��� ������������� �������
              //=> ���� ��������� ��� �� ��� ������
              //=> ������ Cancel �������, ������� ������������ ����
              //=> �������� �������� ����� ������.
              TargetDS.Cancel;

              AddText('���� �����������. ������� ����� ������ �� ����������� �����.', clBlack);
              gdcBaseManager.DeleteRUIDByXID(SourceDS.FieldByName(XID_FIELD).AsInteger,
                SourceDS.FieldByName(DBID_FIELD).AsInteger, TargetDS.Transaction);
              InsertRecord(SourceDS, TargetDS);
              NeedAddToIDMapping := False;
            end
            else
              raise;
          end;}
          raise;
        end;
      end
      else
      begin
        TargetDS.StreamProcessingAnswer := ReplaceRecordAnswer;
        if not TargetDS.CheckTheSame(True) then
        begin
          TargetDS.Post;

          {if StreamLoggingType = slAll then
          begin
            AddText('������ �������� �� ������!', clBlack);
            Space;
          end;}
        end;
      end;  

      if NeedAddToIDMapping then
        AddToIDMapping(SourceKeyInt, TargetDS.FieldByName(KeyFieldName).AsInteger, LoadedRecordState);

      if Assigned(RUOL) then
      begin
        for I := 0 to RUOL.Count - 1 do
          TgdcReferenceUpdate(RUOL[I]).ID := TargetDS.ID;
      end;

      TargetKeyInt := TargetDS.ID;
      ApplyDelayedUpdates(SourceKeyInt, TargetDS.FieldByName(KeyFieldName).AsInteger);
      if TargetDS.ID <> TargetKeyInt then
        TargetDS.ID := TargetKeyInt;

      // ������� ����������� ������
      Result := True;
    except
      on E: EDatabaseError do
      begin
        if TargetDS.State = dsInsert then
          ErrorSt := Format('���������� �������� ������: %s %s %s ',
            [TargetDS.ClassName,
             SourceDS.FieldByName(TargetDS.GetListField(TargetDS.SubType)).AsString, IntToStr(SourceKeyInt)])
        else
          ErrorSt := Format('���������� �������� ������: %s %s %s',
            [TargetDS.ClassName,
             SourceDS.FieldByName(TargetDS.GetListField(TargetDS.SubType)).AsString, IntToStr(SourceKeyInt)]);

        // ������ ���������� ������ �� ������� ��������
        RemoveFromLoadingOrder(SourceKeyInt);
        // �� ����� ������ ����������� �� ����� ���������� ���������
        if not SilentMode then
          MessageBox(TargetDS.ParentHandle, PChar(ErrorSt), '������', MB_OK or MB_ICONHAND);

        //AddMistake(ErrorSt, clRed);
        AddMistake(E.Message, clRed);
        if Assigned(frmStreamSaver) then
          frmStreamSaver.AddWarning(ErrorSt + NEW_LINE + E.Message);

        TargetDS.Cancel;
        AddToIDMapping(SourceKeyInt, -1, lsNotLoaded);
      end;
    end;
  finally
    if Assigned(RUOL) then
      RUOL.Free;
  end;
end;

procedure TgdcStreamDataProvider.InsertRecord(SourceDS: TDataSet; TargetDS: TgdcBase);
var
  Modified: TDateTime;
  RUID: TRUID;
begin
  //��������� ������ � ��� ������
  TargetDS.Insert;
  //���� ������� ����� �� ������ ������ ���������
  if CopyRecord(SourceDS, TargetDS) then
  begin
    TargetDS.CheckBrowseMode;
    // ���� � �������� ��� ���� ������� ��������� �������, �� ������� ������� �����
    if not SourceDS.FieldByName('_' + PARAM_MODIFIED).IsNull then
      Modified := SourceDS.FieldByName('_' + PARAM_MODIFIED).AsDateTime
    else
      Modified := Now;

    RUID := StrToRUID(SourceDS.FieldByName('_' + PARAM_RUID).AsString);
    //��������� �������� �� ���� � ����
    if gdcBaseManager.GetRUIDRecByID(TargetDS.ID, FTransaction).XID = -1 then
    begin
      //���� ���, �� ��������� � ����
      gdcBaseManager.InsertRUID(TargetDS.ID, RUID.XID, RUID.DBID, Modified, IBLogin.ContactKey, FTransaction);
    end
    else
    begin
      //���� ��, �� ��������� ���� ����� �� ��� ID
      gdcBaseManager.UpdateRUIDByID(TargetDS.ID, RUID.XID, RUID.DBID, Modified, IBLogin.ContactKey, FTransaction);
    end;
    RemoveFromLoadingOrder(SourceDS.FieldByName(TargetDS.GetKeyField(TargetDS.SubType)).AsInteger);
    SourceDS.Delete;
  end;
end;

procedure TgdcStreamDataProvider.LoadRecord(AObj: TgdcBase; CDS: TDataSet);
var
  RuidRec, StreamRUIDRec: TRuidRec;
  RUID: TRUID;
  CurrentRecordID: TID;
  Modified: TDateTime;
  IsRecordLoaded: Boolean;
begin
  // ��� ������� Escape ������� �������
  if AbortProcess or ((not SilentMode) and frmSQLProcess.Active and ((GetAsyncKeyState(VK_ESCAPE) shr 1) <> 0)) then
  begin
    if (not AbortProcess) and
       (Application.MessageBox('���������� �������� ������?', '��������', MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL) = IDYES) then
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

  StreamRUIDRec.ID := CDS.FieldByName(AObj.GetKeyField(AObj.SubType)).AsInteger;
  RUID := StrToRUID(CDS.FieldByName('_' + PARAM_RUID).AsString);
  StreamRUIDRec.XID := RUID.XID;
  StreamRUIDRec.DBID := RUID.DBID;
  // ���� � �������� ��� ���� ������� ��������� �������, �� ������� ������� �����
  if not CDS.FieldByName('_' + PARAM_MODIFIED).IsNull then
    StreamRUIDRec.Modified := CDS.FieldByName('_' + PARAM_MODIFIED).AsDateTime
  else
    StreamRUIDRec.Modified := Now;
  Modified := StreamRUIDRec.Modified;
  // ������������ � GetRUID
  AObj.StreamXID := StreamRUIDRec.XID;
  AObj.StreamDBID := StreamRUIDRec.DBID;

  if AObj.SetTable <> '' then
    AObj.SetTable := '';

  //��������� �� ������������ ���� ��� �����������
  if not Assigned(CDS.FindField(AObj.GetListField(AObj.SubType))) then
  begin
    AddText(Format('������ %s (XID = %d, DBID = %d)',
      [AObj.GetDisplayName(AObj.SubType), StreamRUIDRec.XID, StreamRUIDRec.DBID]), clBlue);

    AddWarning('��������� ������������ ������� �� ������������� ��������� ��� ������������� ������� � ����. ' + NEW_LINE +
      ' ���� ' + AObj.GetListField(AObj.SubType) + ' �� ������� � ������ ������!', clRed);

    if Assigned(frmStreamSaver) then
      frmStreamSaver.AddWarning;
  end
  else
  begin
    if Assigned(frmStreamSaver) then
      frmStreamSaver.SetProcessText(Format('%s%s  "%s"%s  (XID = %d, DBID = %d)',
        [AObj.GetDisplayName(AObj.SubType), NEW_LINE, CDS.FieldByName(AObj.GetListField(AObj.SubType)).AsString, NEW_LINE,
         StreamRUIDRec.XID, StreamRUIDRec.DBID]));

    if StreamLoggingType = slAll then
      AddText(Format('������ %s "%s" (XID = %d, DBID = %d)',
        [AObj.GetDisplayName(AObj.SubType), CDS.FieldByName(AObj.GetListField(AObj.SubType)).AsString,
         StreamRUIDRec.XID, StreamRUIDRec.DBID]), clBlue);
  end;

  //��������, ���� �� � ��� ����� ����
  RuidRec := gdcBaseManager.GetRUIDRecByXID(StreamRUIDRec.XID, StreamRUIDRec.DBID, FTransaction);
  //������� ID, ��������� �� �����
  CurrentRecordID := RuidRec.ID;

  //���� �� �� ����� ����, �� ��� xid - "�����������"
  if (CurrentRecordID = -1) and (StreamRUIDRec.XID < cstUserIDStart) then
  begin
    //��������� �������� ���� ������
    AObj.ID := StreamRUIDRec.XID;
    //���� �����, �� �������� ����
    if not AObj.IsEmpty then
    begin
      gdcBaseManager.InsertRUID(StreamRUIDRec.XID, StreamRUIDRec.XID, StreamRUIDRec.DBID, Date, IBLogin.ContactKey, FTransaction);
      //�������� ��� XID = id
      CurrentRecordID := StreamRUIDRec.XID;
    end;
  end;

  //���� ������ � ���� �� �������, ������� ��
  if CurrentRecordID = -1 then
  begin
    InsertRecord(CDS, AObj);
    if FDataObject.IsIncrementedStream then
      AddRecordToRPLRECORDS(AObj.ID, Modified);
  end
  else
  begin
    //��������� �������� ���� ������
    AObj.ID := CurrentRecordID;
    //���� �� �����, ������ ���� �����������, ������ ���, ������ �������
    if AObj.IsEmpty then
    begin
      gdcBaseManager.DeleteRUIDbyXID(StreamRUIDRec.XID, StreamRUIDRec.DBID, FTransaction);
      InsertRecord(CDS, AObj);
      if FDataObject.IsIncrementedStream then
        AddRecordToRPLRECORDS(AObj.ID, Modified);
    end
    else
    begin
      if StreamLoggingType = slAll then
        AddText('������ ������ �� �����', clBlue);

      // ���������, ���������� �� ��� ������� ��������� ������, ����� ����������� �� ������� �� ������
      if AObj.NeedDeleteTheSame(AObj.SubType)
         and AObj.DeleteTheSame(CurrentRecordID, CDS.FieldByName(AObj.GetListField(AObj.SubType)).AsString) then
      begin
        // ���� ������ �������, ������� �� ������ �� ������
        InsertRecord(CDS, AObj);
        if FDataObject.IsIncrementedStream then
          AddRecordToRPLRECORDS(AObj.ID, Modified);
      end
      else
      begin
        //��������, ����� ��� ������������� ���� ��������� ������
        Modified := RUIDRec.Modified;
        IsRecordLoaded := False;
        // ���� �� ����� ������ �� ����� �
        //  ������ ��������� � ���������� ������� �� ������
        if Assigned(CDS.FindField('_' + PARAM_MODIFY_FROM_STREAM)) and CDS.FieldByName('_' + PARAM_MODIFY_FROM_STREAM).AsBoolean then
        begin
          if AObj.ID <> CurrentRecordID then
            AObj.ID := CurrentRecordID;

          // ���� ����� ������������, �� ��������� �� ������� RPL_RECORD ������������� �������� ������
          if (not FDataObject.IsIncrementedStream) or CheckNeedLoadingRecord(StreamRUIDRec.XID, StreamRUIDRec.DBID, StreamRUIDRec.Modified) then
          begin
            // �������, ��������� �� ��� ������ � ���������� ������� �� ������
            if CheckNeedModify(AObj, CDS) then
            begin
              // �������� ������ ������ �� ������ � �� �� ����
              //   ���� ������ false, ������ �������� ���� �������� ��� �������� ������ ������ ����� �������
              if CopyRecord(CDS, AObj) then
              begin
                // ���� ���������� ������ ������� � �� ����� ����� ������ ���� ����������� �����
                //  �������� ����
                if (Modified < StreamRUIDRec.Modified) then
                begin
                  AObj.CheckBrowseMode;
                  gdcBaseManager.UpdateRUIDByXID(AObj.ID, StreamRUIDRec.XID, StreamRUIDRec.DBID,
                    StreamRUIDRec.Modified, IBLogin.ContactKey, FTransaction);
                  Modified := StreamRUIDRec.Modified;
                end;
                // ������� ������ � �������� ������ � ������� RPL_RECORDS, ��� ������������� ������
                if FDataObject.IsIncrementedStream then
                  AddRecordToRPLRECORDS(AObj.ID, Modified);
                // ������ ���� ������� �� ������� ��������
                RemoveFromLoadingOrder(StreamRUIDRec.ID);
                IsRecordLoaded := True;
              end;
            end
            else
            begin
              //�������� ������������ ������ ID � ID �� ������ � ����� ���������������
              AddToIDMapping(StreamRUIDRec.ID, AObj.ID, lsNotLoaded);
              // ������ ���� ������� �� ������� ��������
              RemoveFromLoadingOrder(StreamRUIDRec.ID);
              IsRecordLoaded := True;
              ApplyDelayedUpdates(StreamRUIDRec.ID, AObj.ID);
            end;
          end
          else
          begin
            if StreamLoggingType = slAll then
              AddText('������ ������ � RPL_RECORD', clBlack);

            //�������� ������������ ������ ID � ID �� ������ � ����� ���������������
            AddToIDMapping(StreamRUIDRec.ID, AObj.ID, lsNotLoaded);
            // ������ ���� ������� �� ������� ��������
            RemoveFromLoadingOrder(StreamRUIDRec.ID);
            IsRecordLoaded := True;
            ApplyDelayedUpdates(StreamRUIDRec.ID, AObj.ID);
          end;
        end
        else
        begin
          //�������� ������������ ������ ID � ID �� ������ � ����� ���������������
          AddToIDMapping(StreamRUIDRec.ID, AObj.ID, lsNotLoaded);
          // ������ ���� ������� �� ������� ��������
          RemoveFromLoadingOrder(StreamRUIDRec.ID);
          IsRecordLoaded := True;
          ApplyDelayedUpdates(StreamRUIDRec.ID, AObj.ID);
        end;
        // ���� ������ ����������� ��� ������ �� �����, ������ �� �� ������
        if IsRecordLoaded then
          CDS.Delete;
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
      if MessageBox(0, '�� ������� ���� ����� ��� ������������ ������, �� �� ���� �������� ������������� �� �� ��������.'#13#10 +
        '��������� ������ ��������?',
        '��������',
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
    // ������ ������ � ���� ������� �� irsIncremented (�������� ������� ������������)
    FIBSQL.Close;
    FIBSQL.SQL.Text := Format(sqlUpdateRPLRecordsSetStateByBasekey, [FDataObject.TargetBaseKey, Integer(irsIncremented)]);
    FIBSQL.ExecQuery;
  end;
end;

procedure TgdcStreamDataProvider.LoadSetRecords;
var
  I: Integer;
  CDS: TDataSet;
  CurrentSetTableName: String;
  Obj: TgdcBase;
begin
  for I := 0 to FDataObject.Count - 1 do
  begin
    CDS := FDataObject.ClientDS[I];
    if Assigned(CDS.FindField('_' + PARAM_SET_TABLE)) then
    begin
      CurrentSetTableName := CDS.FieldByName('_' + PARAM_SET_TABLE).AsString;
      // ��� ����� ������� � ��������� ��������-����������
      if (not CDS.IsEmpty) and (CurrentSetTableName <> '') then
      begin
        // ���� �������-��������� ���������� �� ����� ����
        if Assigned(atDatabase.Relations.ByRelationName(CurrentSetTableName)) then
        begin
          Obj := FDataObject.gdcObject[I];
          CDS.First;
          while not CDS.Eof do
          begin
            // ���� ��� �������� ������� ��������� ��� ���������� ���� "�������������� �� ������"
            if CDS.FieldByName('_' + PARAM_MODIFY_FROM_STREAM).AsBoolean then
              Self.LoadSetRecord(CDS, Obj);
            CDS.Next;
          end;
        end
        else
          raise EgdcNoTable.Create(CurrentSetTableName);
      end;
    end;  
  end;
end;

procedure TgdcStreamDataProvider.LoadSetRecord(SourceDS: TDataSet; AObj: TgdcBase);
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
  LoadedRecordState: TLoadedRecordState;
begin
  if Assigned(atDatabase.Relations.ByRelationName(SourceDS.FieldByName('_' + PARAM_SET_TABLE).AsString)) then
  begin
    SFld := '';
    SValues := '';
    SUpdate := '';
    LoadedRecordState := lsNotLoaded;
    // ����������� �� ����� �� ������. ���� ���� �������� �����-����������,
    //   �� ��������� ��������������� ������ ��� ����������/�������
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
      else if SourceDS.Fields[I].DataType in [ftString, ftDate, ftDateTime, ftTime] then
      begin
        SValues := SValues + '''' + SourceDS.Fields[I].AsString + '''';
        SUpdate := SUpdate + GetSetFieldName(SourceDS.Fields[I].FieldName) + ' = ''' +
          SourceDS.Fields[I].AsString + '''';
      end
      else
      begin
        F := atDataBase.FindRelationField(SourceDS.FieldByName('_' + PARAM_SET_TABLE).AsString,
          GetSetFieldName(SourceDS.Fields[I].FieldName));
        if (F <> nil) and (F.References <> nil) then
        begin //���� ��� ���� �������� �������, �� ������ ��� � ����� ���������������
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

    // ���� �������������� ����-���������, �� ������� �������� � ��
    if SFld > '' then
    begin
      R2 := atDataBase.Relations.ByRelationName(SourceDS.FieldByName('_' + PARAM_SET_TABLE).AsString);
      Pr := R2.PrimaryKey;

      if not Assigned(Pr) then
      begin
        {
          ���� ������� ���������� � ������ � ����� ���������, ��
          ��������������� � ���� ��� �� ���� � ���������� � atDatabase
          � ��� ����� � �� ����. ������� ���������� ��.
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
            else if SourceDS.FieldByName(S1).DataType in [ftString, ftDate, ftDateTime, ftTime] then
              S := S + Pr.ConstraintFields[I].FieldName + ' = ''' + SourceDS.FieldByName(S1).AsString + ''''
            else
            begin
              F := atDataBase.FindRelationField(SourceDS.FieldByName('_' + PARAM_SET_TABLE).AsString,
                GetSetFieldName(SourceDS.FieldByName(S1).FieldName));
              if (F <> nil) and (F.References <> nil) then
              begin
                //���� ��� ���� �������� �������, �� ������ ��� � ����� ���������������
                Key := FIDMapping.IndexOf(SourceDS.FieldByName(S1).AsInteger);
                if Key > -1 then
                begin
                  SKey := IntToStr(FIDMapping.ValuesByIndex[Key]);
                  // ������������ ��� ������ ����� ����� � ��������� ����� ������� ������
                  if I = 0 then
                    LoadedRecordState := TLoadedRecordStateList(FIDMapping).StateByIndex[Key];
                end
                else
                  SKey := SourceDS.FieldByName(S1).AsString;
              end
              else
                SKey := SourceDS.FieldByName(S1).AsString;
              S := S + Pr.ConstraintFields[I].FieldName + ' = ' + SKey;
            end;
          end;

          // ������� �� ��������� ������� ������ - ��������� �� ����� ���������,
          //  ���� ������� ������ �� ���� ��������� ��� �������� �� ���������
          if LoadedRecordState <> lsNotLoaded then
          begin
            FIBSQL.Close;
            FIBSQL.SQL.Text := Format(sql_SetSelect, [SourceDS.FieldByName('_' + PARAM_SET_TABLE).AsString, S]);
            FIBSQL.ExecQuery;

            if FIBSQL.RecordCount > 0 then
            begin
            { TODO -oJulia : ��� ������ � ��� ������������� �������? ���������?
              � �����-�� ������ ��� ����� ����� �����, ��������, ������� gd_lastnumber }
            // FIBSQL.Close;
            //  FIBSQL.SQL.Text := Format(sql_SetUpdate,
            //    [SourceDS.FieldByName('_' + PARAM_SET_TABLE).AsString, SUpdate, S]);
            end
            else
            begin
              FIBSQL.Close;
              FIBSQL.SQL.Text := Format(sql_SetInsert,
                [SourceDS.FieldByName('_' + PARAM_SET_TABLE).AsString, SFld, SValues]);

              R := atDataBase.Relations.ByRelationName(SourceDS.FieldByName('_' + PARAM_SET_TABLE).AsString);
              if Assigned(R) then
                LocName := R.LName
              else
                LocName := SourceDS.FieldByName('_' + PARAM_SET_TABLE).AsString;

              if StreamLoggingType = slAll then
                AddText('���������� ������ ��������� ' + LocName, clBlue);
              FIBSQL.ExecQuery;
            end;
          end;  
        except
          on E: Exception do
          begin
            AddWarning(E.Message, clRed);
            if Assigned(frmStreamSaver) then
              frmStreamSaver.AddWarning;
          end;
        end;
      end
      else
      begin
        AddWarning('������ ��������� ' + SourceDS.FieldByName('_' + PARAM_SET_TABLE).AsString + ' �� ���� ���������!', clRed);
        if Assigned(frmStreamSaver) then
          frmStreamSaver.AddWarning;
      end;
    end;
  end
  else
    raise EgdcNoTable.Create(SourceDS.FieldByName('_' + PARAM_SET_TABLE).AsString);
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
    if AObj is TgdcSavedFilter then
    begin
      if not AObj.FieldByName('userkey').IsNull then
      begin
        Result := False;
        raise Exception.Create('������ ' + QuotedStr(AObj.FieldByName('name').AsString) + #13#10 +
          '�� �� ������ ��������� � ��������� ���������������� ������ � �������� "������ ������ ��� ����"!');
      end;
      Exit;
    end;

    if AObj is TgdcField then
    begin
      //��������� ������ �� ���������!
      if StrIPos('RDB$', AObj.FieldByName('fieldname').AsString) = 1 then
        Result := False;
      Exit;
    end;

    if AObj is TgdcRelation then
    begin
      // ����� ����������� � ����� ����� ���������������� ��������
      //  �.�. ���������� � ��������� ����� �� ������ ��������� � ������� at_triggers
      gdcObject := FDataObject.gdcObject[FDataObject.GetObjectIndex('TgdcTrigger')];
      (gdcObject as TgdcTrigger).SyncTriggers(AObj.FieldByName('relationname').AsString);
      Exit;
    end;

    if AObj is TgdcStoredProc then
    begin
      Assert(AObj.State = dsBrowse);
      try
        (AObj as TgdcStoredProc).PrepareToSaveToStream(true);
      except
        (AObj as TgdcStoredProc).PrepareToSaveToStream(false);
      end;
      Exit;
    end;

    if AObj is TgdcIndex then
    begin
      //� ����� ��������� ������ �������-��������
      Result := False;
      if StrIPos(UserPrefix, AObj.FieldByName('indexname').AsString) = 1 then
      begin
        //���� �������� ������� ��������� � ��������� �����������, �� �� ��������� ���
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

    if AObj is TgdcTrigger then
    begin
      //�� �� ����� ��������� ������� USR$_BU_INV_CARD � �����,
      //�.�. �� ������������ ������������� ��� ��������� ��������� ������� inv_card
      Result := False;
      if (AnsiCompareText('USR$_BU_INV_CARD', Trim(AObj.FieldByName('triggername').AsString)) = 0) then
        Exit;
      for I := 1 to MaxInvCardTrigger do
        if (AnsiCompareText(Format('USR$%d_BU_INV_CARD', [I]), Trim(AObj.FieldByName('triggername').AsString)) = 0) then
          Exit;
      //� ����� ��������� ������ ��������-��������
      if AnsiPos(UserPrefix, AnsiUpperCase(AObj.FieldByName('triggername').AsString)) = 1 then
        Result := True;
      Exit;
    end;

    if AObj is TgdcGenerator then
    begin
      //� ����� ��������� ������ ����������-��������
      if StrIPos(UserPrefix, AObj.FieldByName('generatorname').AsString) <> 1 then
        Result := False;
      Exit;
    end;

    if AObj is TgdcCheckConstraint then
    begin
      //� ����� ��������� ������ ����-��������
      if StrIPos(UserPrefix, AObj.FieldByName('checkname').AsString) <> 1 then
        Result := False;
      Exit;
    end;

  finally
    // � �������� ���������� �������������� ��������� ID ������� ����� ���������,
    // ����������� ��������������
    if AObj.ID <> LocalID then
      AObj.ID := LocalID;
  end;
end;

function TgdcStreamDataProvider.DoAfterSaving(AObj: TgdcBase): Boolean;
var
  I: Integer;
  ObjectIndex: Integer;
  atRelation: TatRelation;
  LocalID: TID;
begin
  Result := True;

  if AObj is TgdcStoredProc then
  begin
    (AObj as TgdcStoredProc).PrepareToSaveToStream(false);
    Exit;
  end;

  if AObj is TgdcUnknownTable then
  begin
    // ������� ��� �����-������. ���� ��� ���������������� ������� � � ��� ����
    //   �������� ���, �� �������� � ����� ����, �������� � �������� ���
    if AnsiPos(UserPrefix, AObj.FieldByName('relationname').AsString) = 1 then
    begin
      atRelation := atDatabase.Relations.ByRelationName(AObj.FieldByName('relationname').AsString);

      if not Assigned(atRelation) then
        raise EgdcIBError.Create('������� ' + AObj.FieldByName('relationname').Asstring +
          ' �� �������! ���������� ���������������.');

      if Assigned(atRelation.PrimaryKey) then
      begin
        ObjectIndex := FDataObject.GetObjectIndex('TgdcRelationField');
        for I := 0 to atRelation.PrimaryKey.ConstraintFields.Count - 1 do
        begin
          LocalID := AObj.ID;
          try
            Self.SaveRecord(ObjectIndex, atRelation.PrimaryKey.ConstraintFields[I].ID);
          finally
            if AObj.ID <> LocalID then
              AObj.ID := LocalID;
          end;    
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
      // ���� ������ ��� ������������ �� ������� ���� � � ��� ��� �� ����������, �� �� ��������� �� � �����
      if (State = irsIncremented) and (RplEditionDate >= AModified) then
      begin
        Result := False;
      end
      else
      begin
        // ������ �� RPL_RECORD ���������� � ����������� ������
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
            frmStreamSaver.AddWarning(Format('%s, XID = %d, DBID = %d ', [E.Message, XID, DBID]));
          AddWarning(Format('%s, XID = %d, DBID = %d ', [E.Message, XID, DBID]), clRed);
        end;
      end;
      {if IbsqlRPLRecordInsert.RowsAffected <> 1 then
        raise Exception.Create(GetGsException(Self, 'AddRecordToRPLRECORDS: ������ ��� ������� ������ � ������� RPL_RECORD'));}
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
          AddText('��������� ������ � RPL_DATABASE (ID = ' + BaseID + ', NAME = ''' + BaseName + ''')', clBlue);
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
      AddText('���� �������� ID � ������� RPL_DATABASE (ID = ' + IntToStr(FDataObject.OurBaseKey) + ')', clBlue);
  end;
end;

function TgdcStreamDataProvider.CheckNeedModify(ABaseRecord: TgdcBase;
  AStreamRecord: TDataSet): Boolean;
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

  // �� ����� ������ ����������� �� �������� ���������� ��� ���� ����������, ������ ������� �������� ��� ��������
  if IsReplicationMode then
  begin
    if ABaseRecord.InheritsFrom(TgdcMetaBase) or ABaseRecord.InheritsFrom(TgdcBaseDocumentType) then
      Result := False
    else
      Result := True;
    Exit;
  end;

  // ���� ��� ������ - ����������� ����-������, �� �������������� �� ���������
  if ABaseRecord.InheritsFrom(TgdcMetaBase) and (not (ABaseRecord as TgdcMetaBase).IsUserDefined) then
    Exit;

  // ���� ������ ��� ����������� ������, �� �� �������� ������������
  if ABaseRecord.ID < cstUserIDStart then
  begin
    Result := False;
    Exit;
  end;

  case ReplaceRecordAnswer of
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
      // �������� ��� ��������� ���� "��������� �� ������" �������,
      //   ����� ��� �� ���������� �� ���� ����������, �� ���������� ��� ������������ ������
      NeedModifyFromStream := Assigned(AStreamRecord.FindField('_' + PARAM_MODIFY_FROM_STREAM)) and
        AStreamRecord.FieldByName('_' + PARAM_MODIFY_FROM_STREAM).AsBoolean;

      if ABaseRecord.NeedModifyFromStream(ABaseRecord.SubType) <> NeedModifyFromStream then
      begin
        ReplaceRecordAnswer := MessageDlg('������ ' + ABaseRecord.GetDisplayName(ABaseRecord.SubType) + ' ' +
          ABaseRecord.FieldByName(ABaseRecord.GetListField(ABaseRecord.SubType)).AsString + ' � ��������������� ' +
          ABaseRecord.FieldByName(ABaseRecord.GetKeyField(ABaseRecord.SubType)).AsString + ' ��� ���������� � ����. ' +
          '�������� ������? ', mtConfirmation,
          [mbYes, mbYesToAll, mbNo, mbNoToAll], 0);
        case ReplaceRecordAnswer of
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
        // �������� �� ������� ����������� ����� ����������� ������ �� ������������
        for I := 0 to AStreamRecord.Fields.Count - 1 do
        begin
          // �������� �� �������� ���� editiondate, keyfield, editorkey
          if Assigned(ABaseRecord.FindField(AStreamRecord.Fields[I].FieldName)) and
            (AnsiCompareText(Trim(AStreamRecord.Fields[I].FieldName), ABaseRecord.GetKeyField(ABaseRecord.SubType)) <> 0) and
            (AnsiPos(';' + AnsiUpperCase(Trim(AStreamRecord.Fields[I].FieldName)) + ';', PassFieldName) = 0) and
            (AnsiPos(',' + AnsiUpperCase(Trim(AStreamRecord.Fields[I].FieldName)) + ',', ',' + ABaseRecord.GetNotStreamSavedField + ',') = 0) then
          begin
            F := nil;
            if Assigned(atDatabase) and (AStreamRecord.Fields[I].DataType in [ftInteger, ftSmallInt, ftWord]) then
            begin
             // ��������� �� �������� �� ���� ���� �������
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

                // ���������� ���� ������
                if (Key > -1) and (Key <> ABaseRecord.FieldByName(AStreamRecord.Fields[I].FieldName).AsInteger) then
                begin
                  IsDifferent := True;
                  Break;
                end;
                Continue;
              end;
            end;

            if (Trim(AStreamRecord.Fields[I].AsString) = '') and (AStreamRecord.Fields[I].AsString > '') then
              // ���� ������ � ��� �������� ������ �������
              //  �� ��������� �� ����� ��� ����
              SourceSt := AStreamRecord.Fields[I].AsString
            else
              // � �������� ������ ������� ������� � ����������� �������
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

        //���� ����������� ������ ���������� �� ������������ �������, ����� �� �� ���������
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

procedure TgdcStreamDataProvider.ClearNowSavedRecordsList;
begin
  // ������� ������ ������� ������� ����������� ��� ���������� ���������� ������������ �������
  FNowSavedRecords.Clear;
end;

procedure TgdcStreamDataProvider.Clear;
begin
  // ������� ��������������� ������
  ClearNowSavedRecordsList;
  FIDMapping.Clear;
  FUpdateList.Clear;
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
    begin
      if FDataObject.TargetBaseKey > 0 then
        FIbsqlRPLRecordInsert.SQL.Text := Format(sqlInsertRPLRecordsIDStateEditionDate, [FDataObject.TargetBaseKey])
      else
        raise EgsUnknownDatabaseKey.Create(GetGsException(Self, '������� �������� ���� ������� ���� ������ (' + IntToStr(FDataObject.TargetBaseKey) + ')'));
    end
    else
    begin
      if FDataObject.SourceBaseKey > 0 then
        FIbsqlRPLRecordInsert.SQL.Text := Format(sqlInsertRPLRecordsIDStateEditionDate, [FDataObject.SourceBaseKey])
      else
        raise EgsUnknownDatabaseKey.Create(GetGsException(Self, '������� �������� ���� �������� ���� ������ (' + IntToStr(FDataObject.SourceBaseKey) + ')'));
    end;
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

function TgdcStreamDataProvider.GetNeedModifyFlagOnSaving(const AObjectKey: TID): Boolean;
var
  IndexNeedModifyList: Integer;
begin
  // �� ��������� ������������� ���� �������������� �� ������ � True
  if Assigned(FNeedModifyList) then
  begin
    // ���� ��� ������� ������ � ���������� ������, �� ���� �� ����
    IndexNeedModifyList := FNeedModifyList.IndexOf(AObjectKey);
    if IndexNeedModifyList > -1 then
      Result := (FNeedModifyList.ValuesByIndex[IndexNeedModifyList] = 1)
    else
    begin
      // ���� � ������ �� ��������� ������ �������, ������ ��� ������ � ��������� ������
      //  ���� �������� ����������, �� ��������� ���� � False
      if IsReplicationMode then
        Result := False
      else
        Result := True;
    end;
  end
  else
    Result := True;
end;

procedure TgdcStreamDataProvider.AddToIDMapping(const AKey,
  AValue: Integer; const ARecordState: TLoadedRecordState);
var
  IDMappingIndex: Integer;
begin
  if (FIDMapping.IndexOf(AKey) = -1) then
  begin
    IDMappingIndex := FIDMapping.Add(AKey);
    FIDMapping.ValuesByIndex[IDMappingIndex] := AValue;
    TLoadedRecordStateList(FIDMapping).StateByIndex[IDMappingIndex] := ARecordState;
  end;
end;

procedure TgdcStreamDataProvider.LoadSettingMetadata;
var
  gdcObject: TgdcBase;
begin
  if Assigned(FDataObject.SettingHeaderDataset) then
  begin
    FIsLoadingSettingMetadata := True;
    try
      // ���������� ������ ������ ���� �������� ����������� ���������
      FDataObject.SettingHeaderDataset.Edit;
      FDataObject.SettingHeaderDataset.FieldByName('DATA').AsString := GetRUIDList;
      FDataObject.SettingHeaderDataset.Post;

      // ������ ����� ���������
      gdcObject := FDataObject.gdcObject[FDataObject.GetObjectIndex('TgdcSetting', '', '')];
      Self.LoadRecord(gdcObject, FDataObject.SettingHeaderDataset);
      // ������ ������� ���������
      gdcObject := FDataObject.gdcObject[FDataObject.GetObjectIndex('TgdcSettingPos', '', '')];
      FDataObject.SettingPosDataset.First;
      while not FDataObject.SettingPosDataset.Eof do
      begin
        Self.LoadRecord(gdcObject, FDataObject.SettingPosDataset);
        FDataObject.SettingPosDataset.Next;
      end;
    finally
      FIsLoadingSettingMetadata := False;

      // ��� �������� �� ��������� ������������ �� ��� ������� � ������ �� � ������ ������������
      //  ������� ���, ����� �������� ������� ��� �������� ������ ��������� � ������ �� ��
      Self.Clear;
    end;
  end
  else
  begin
    raise Exception.Create('TgdcStreamDataProvider.LoadSettingMetadata: �� ������� ������ ���������');
  end;
end;

function TgdcStreamDataProvider.GetRUIDList: String;
var
  I: Integer;
  SL: TStringList;
  CDS: TDataset;
begin
  Result := '';
  SL := TStringList.Create;
  try
    for I := 0 to FDataObject.Count - 1 do
    begin
      CDS := FDataObject.ClientDS[I];
      if Assigned(CDS.FindField('_' + PARAM_RUID)) then
      begin
        CDS.First;
        while not CDS.Eof do
        begin
          SL.Add(CDS.FieldByName('_' + PARAM_RUID).AsString);
          CDS.Next;
        end;
      end;
    end;
    Result := SL.CommaText;
  finally
    FreeAndNil(SL);
  end;
end;

procedure TgdcStreamDataProvider.RemoveFromLoadingOrder(const AID: Integer);
begin
  // �� ����� ������� ������ �� ������� �������� ���� ������ ���������� ���������,
  //  �.�. �� �� ���� ���������� ������������ ��������� ������� � 147000000,
  //  � ������ �� ����� ������� �� ������� ���������� ������ ���������
  if not FIsLoadingSettingMetadata then
    FLoadingOrderList.Remove(AID);
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

procedure TStreamOrderList.Clear;
begin
  // ������� ������ �������
  SetLength(FItems, 0);
  // ������ �������������� ������
  FCount := 0;
  FSize := 32;
  SetLength(FItems, FSize);
end;

{ TgdcStreamLoadingOrderList }

constructor TgdcStreamLoadingOrderList.Create;
begin
  inherited;
  FIsLoading := False;
  FNext := 0;
end;

procedure TgdcStreamLoadingOrderList.LoadFromStream(Stream: TStream);
var
  I: Integer;
  Index, DSIndex: Integer;
  ID: TID;
begin
  FIsLoading := True;

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

procedure TgdcStreamLoadingOrderList.SaveToStream(Stream: TStream);
var
  I: Integer;
begin
  Stream.Write(FCount, SizeOf(FCount));
  for I := 0 to FCount - 1 do
  begin
    Stream.Write(FItems[I].Index, SizeOf(Integer));
    Stream.Write(FItems[I].DSIndex, SizeOf(Integer));
    Stream.Write(FItems[I].RecordID, SizeOf(TID));
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

procedure TgdcStreamLoadingOrderList.Clear;
begin
  inherited;
  FNext := 0;
end;

{ TgdcStreamWriterReader }

constructor TgdcStreamWriterReader.Create(AObjectSet: TgdcStreamDataObject = nil; ALoadingOrderList: TgdcStreamLoadingOrderList = nil);
begin
  FStream := nil;
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

procedure TgdcStreamWriterReader.SetStream(const Value: TStream);
begin
  if Value <> nil then
    FStream := Value;
end;

procedure TgdcStreamWriterReader.LoadFromStream(const S: TStream);
begin
  FStream := S;
end;

procedure TgdcStreamWriterReader.SaveToStream(S: TStream);
begin
  FStream := S;
end;

function TgdcStreamWriterReader.GetFileName: String;
begin
  Result := FFileDir + FFileName;
end;

procedure TgdcStreamWriterReader.SetFileName(const Value: String);
begin
  FFileDir := ExtractFileDir(Value);
  FFileName := ExtractFileName(Value);
end;

{ TgdcStreamBinaryWriterReader }

procedure TgdcStreamBinaryWriterReader.LoadFromStream(const S: TStream);
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
  SettingHeader: TSettingHeader;
  CDS: TDataset;
begin
  inherited;

  FDataObject.IsSave := False;

  S.ReadBuffer(I, SizeOf(I));
  // �������� ��� ���������
  if I = gsfID then
  begin
    // ������ ������ ���������
    S.ReadBuffer(I, SizeOf(I));
    if I <> gsfNewVersion then
      raise Exception.Create(GetGsException(Self, 'LoadFromStream: Invalid stream format'));

    FDataObject.CreateSettingMetadata;
    // �������� ��������� ���������
    SettingHeader := TSettingHeader.Create;
    try
      SettingHeader.LoadFromStream(S);
      CDS := FDataObject.SettingHeaderDataset;
      CDS.Insert;
      CDS.FieldByName('ID').AsInteger := gdcBaseManager.GetIDbyRUID(SettingHeader.RUID.XID, SettingHeader.RUID.DBID);
      CDS.FieldByName('NAME').AsString := SettingHeader.Name;
      CDS.FieldByName('DESCRIPTION').AsString := SettingHeader.Comment;
      CDS.FieldByName('VERSION').AsInteger := SettingHeader.Version;
      CDS.FieldByName('MODIFYDATE').AsDateTime := SettingHeader.Date;
      CDS.FieldByName('ENDING').AsInteger := SettingHeader.Ending;
      CDS.FieldByName('SETTINGSRUID').AsString := SettingHeader.InterRUID.CommaText;
      CDS.FieldByName('MINEXEVERSION').AsString := SettingHeader.MinExeVersion;
      CDS.FieldByName('MINDBVERSION').AsString := SettingHeader.MinDBVersion;
      CDS.FieldByName('_' + PARAM_RUID).AsString := RuidToStr(SettingHeader.RUID);
      CDS.Post;
    finally
      FreeAndNil(SettingHeader);
    end;

    // ������� ���������
    UnpackedStream := TMemoryStream.Create;
    try
      PackStream := TZDecompressionStream.Create(S);
      try
        repeat
          SizeRead := PackStream.Read(Buffer, 1024);
          UnpackedStream.WriteBuffer(Buffer, SizeRead);
        until (SizeRead < 1024);
      finally
        FreeAndNil(PackStream);
      end;
      UnpackedStream.Position := 0;

      UnpackedStream.ReadBuffer(I, SizeOf(I));
      MS := TMemoryStream.Create;
      try
        MS.CopyFrom(UnpackedStream, I);
        MS.Position := 0;
        TClientDataset(FDataObject.SettingPosDataset).LoadFromStream(MS);
      finally
        FreeAndNil(MS);
      end;
    finally
      FreeAndNil(UnpackedStream);
    end;
  end;

  // �������� ��� �� ����� ��� ��������� ��� ����������
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

    // ������ ��� ������ �� ������� RPL_DATABASE
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

    // ��������� �� ���� ��������� �����
    UnpackedStream.ReadBuffer(I, SizeOf(I));
    if I > -1 then
      FDataObject.SourceBaseKey := I;
    // ��������� �� ���� �� ������� ����� ��� ���������
    UnpackedStream.ReadBuffer(I, SizeOf(I));
    if I > -1 then
      FDataObject.TargetBaseKey := I;

    UnpackedStream.ReadBuffer(I, SizeOf(I));
    if I > 0 then
    begin
      // ������������ ������ RUID'�� ������� ��������� ������� ����������� �� �������� ���� ������
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
      // ������������ ������ RUID'�� � ID �������, ������� �� ����� � ������������ �����
      // �.�. ��� ������������ �� ������� ����
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
        // ��������� ����� � ������ ������������ �������
        LoadClassName := StreamReadString(UnpackedStream);
        LoadSubType := StreamReadString(UnpackedStream);
        LoadSetTable := StreamReadString(UnpackedStream);

        C := GetClass(LoadClassName);

        {���������� �����, ���� �� �� ������}
        if C = nil then
        begin
          AddWarning('��� �������� �� ������ �������� �������������� �����: ' + LoadClassName, clRed);
          if Assigned(frmStreamSaver) then
            frmStreamSaver.AddWarning;
          if (AMissingClassList.IndexOf(LoadClassName) = -1)
             and (not SilentMode)
             and (MessageBox(0, PChar('��� �������� �� ������ �������� �������������� �����: ' + LoadClassName + #13#10#13#10 +
               '���������� ��������?'),
               '��������',
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

    // ���� ���� ��������� ����� ���������, �� ����� ��������� �������
    if Assigned(FDataObject.SettingHeaderDataset) then
    begin
      UnpackedStream.ReadBuffer(I, SizeOf(I));
      MS := TMemoryStream.Create;
      try
        MS.CopyFrom(UnpackedStream, I);
        MS.Position := 0;
        TClientDataset(FDataObject.SettingPosDataset).LoadFromStream(MS);
      finally
        FreeAndNil(MS);
      end;
    end;

    while UnpackedStream.Position < UnpackedStream.Size do
    begin
      // ��������� ����� � ������ ������������ �������
      LoadClassName := StreamReadString(UnpackedStream);
      LoadSubType := StreamReadString(UnpackedStream);
      LoadSetTable := StreamReadString(UnpackedStream);

      ObjectIndex := FDataObject.GetObjectIndex(LoadClassName, LoadSubType, LoadSetTable);

      UnpackedStream.ReadBuffer(I, SizeOf(I));
      MS := TMemoryStream.Create;
      try
        MS.CopyFrom(UnpackedStream, I);
        MS.Position := 0;
        TClientDataset(FDataObject.ClientDS[ObjectIndex]).LoadFromStream(MS);
      finally
        MS.Free;
      end;
    end;
  finally
    UnpackedStream.Free;
  end;
end;

procedure TgdcStreamBinaryWriterReader.SaveToStream(S: TStream);
var
  I, K, CurDBID, CurStreamVersion: Integer;
  ID, XID, DBID: Integer;
  PackStream: TZCompressionStream;
  MS: TMemoryStream;
  Obj: TgdcBase;
  IBSQL: TIBSQL;
  SettingHeader: TSettingHeader;
  RUID: TRUID;
  CDS: TDataset;
begin
  inherited;

  // ���� ���� ��������� ���������, �� ������� ���
  if Assigned(FDataObject.SettingHeaderDataset) then
  begin
    // ��������� �����
    I := gsfID;
    S.Write(i, SizeOf(i));
    // ������ ������ ���������
    I := gsfNewVersion;
    S.Write(i, SizeOf(i));

    SettingHeader := TSettingHeader.Create;
    try
      CDS := FDataObject.SettingHeaderDataset;

      RUID := StrToRUID(CDS.FieldByName('_' + PARAM_RUID).AsString);
      SettingHeader.RUID.XID := RUID.XID;
      SettingHeader.RUID.DBID := RUID.DBID;
      SettingHeader.Name := CDS.FieldByName('NAME').AsString;
      SettingHeader.Comment := CDS.FieldByName('DESCRIPTION').AsString;
      SettingHeader.Date := CDS.FieldByName('MODIFYDATE').AsDateTime;
      SettingHeader.Version := CDS.FieldByName('VERSION').AsInteger;
      SettingHeader.Ending := CDS.FieldByName('ENDING').AsInteger;
      SettingHeader.InterRUID.CommaText := CDS.FieldByName('SETTINGSRUID').AsString;
      SettingHeader.MinExeVersion := CDS.FieldByName('MINEXEVERSION').AsString;
      SettingHeader.MinDBVersion := CDS.FieldByName('MINDBVERSION').AsString;
      // ��������� ��������� ��������� � ������
      SettingHeader.SaveToStream(S);
    finally
      FreeAndNil(SettingHeader);
    end;
  end;

  // ����� ������
  I := cst_StreamLabel;
  S.Write(I, SizeOf(I));
  // ������� ������ � ��������� �������
  Stream.WriteBuffer(cst_WithVersion[1], Length(cst_WithVersion));
  // ������� ������ ������
  CurStreamVersion := cst_StreamVersionNew;
  S.Write(CurStreamVersion, SizeOf(CurStreamVersion));
  // DBID
  CurDBID := IBLogin.DBID;
  S.Write(CurDBID, SizeOf(CurDBID));

  PackStream := TZCompressionStream.Create(S, zcMax);
  try
    // ���� ���� ������������ ����������
    if FDataObject.TargetBaseKey > -1 then
    begin
      // ������ ��� ������ �� ������� RPL_DATABASE
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
      // ID (�� ������� RPL_DATABASE) ���������� ����� ����
      PackStream.Write(FDataObject.OurBaseKey, SizeOf(FDataObject.OurBaseKey));
      // ID (�� ������� RPL_DATABASE) ����������� ����� ����
      PackStream.Write(FDataObject.TargetBaseKey, SizeOf(FDataObject.TargetBaseKey));
      // ����� ������� RUID'� �������, ��������� ������� �� ������������
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

    // ����� ������� RUID'� � ID �������, ������� �� ����� � ������������ �����
    // �.�. ��� ������������ �� ������� ����
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

    // ������ ������-�������� �� ���� ��������
    PackStream.Write(FDataObject.Count, SizeOf(FDataObject.Count));
    for K := 0 to FDataObject.Count - 1 do
    begin
      Obj := FDataObject.gdcObject[K];
      StreamWriteString(PackStream, Obj.ClassName);
      StreamWriteString(PackStream, Obj.SubType);
      StreamWriteString(PackStream, Obj.SetTable);
    end;

    // ������� �������� �������, ����������� � ������ ������
    FLoadingOrderList.SaveToStream(PackStream);

    MS := TMemoryStream.Create;
    try
      // ���� ���� ����� ���������, �� �������� � �������
      if Assigned(FDataObject.SettingHeaderDataset) then
      begin
        // ������� ���������
        try
          TClientDataset(FDataObject.SettingPosDataset).SaveToStream(MS, dfBinary);
        except
          MessageBox(0,
            '� �������� ���������� � ����� �������� ������. ������������� ���������.',
            '��������',
            MB_OK or MB_ICONHAND or MB_TASKMODAL);
          Abort;
        end;
        I := MS.Size;
        PackStream.Write(I, SizeOf(I));
        PackStream.CopyFrom(MS, 0);
      end;

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
            TClientDataset(FDataObject.ClientDS[K]).SaveToStream(MS, dfBinary);
          except
            MessageBox(0,
              '� �������� ���������� � ����� �������� ������. ������������� ���������.',
              '��������',
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

{ TgdcStreamXMLWriterReader }

constructor TgdcStreamXMLWriterReader.Create(
  AObjectSet: TgdcStreamDataObject;
  ALoadingOrderList: TgdcStreamLoadingOrderList);
begin
  inherited Create(AObjectSet, ALoadingOrderList);

  FCurrentRecordKey := -1;
  FCurrentDatasetModifyFromStream := False;
  FCurrentDataset := nil;
  FCurrentDatasetKey := -1;
  FCurrentGdcObject := nil;
  FFieldCorrList := TStringList.Create;
end;

destructor TgdcStreamXMLWriterReader.Destroy;
begin
  inherited;
  FFieldCorrList.Free;
end;

procedure TgdcStreamXMLWriterReader.LoadFromStream(const S: TStream);
var
  I, J, K: Integer;
  LoadClassName: TgdcClassName;
  LoadSubType: TgdcSubType;
  LoadSetTable: ShortString;
  SettingHeaderKey, SettingElementIterator: Integer;
  C: TClass;
  AMissingClassList: TStringList;
  XMLReader: Tgd_XMLReader;
  XMLElement: TgsXMLElement;
begin
  inherited;

  FDataObject.IsSave := False;
  SettingElementIterator := cstUserIDStart;
  SettingHeaderKey := SettingElementIterator;

  AMissingClassList := TStringList.Create;
  XMLReader := Tgd_XMLReader.Create;
  try
    AMissingClassList.Duplicates := dupIgnore;
    AMissingClassList.Sorted := True;

    XMLReader.Stream := S;
    while XMLReader.GetNextElement(XMLElement) do
    begin
      case GetElementType(XMLElement) of
        etHeader:
        begin
          if XMLElement.Kind = epOpening then
          begin
            FDataObject.StreamVersion := XMLReader.GetIntegerParamValueByName(XMLElement, XML_P_VERSION);
            FDataObject.StreamDBID := XMLReader.GetIntegerParamValueByName(XMLElement, XML_P_DBID);
          end;
        end;

        etDatabase:
        begin
          if XMLElement.Kind = epOpening then
            FDataObject.DatabaseList.Add(
              XMLReader.GetParamValueByName(XMLElement, XML_P_ID) + '=' +
              XMLReader.GetParamValueByName(XMLElement, 'name'));
        end;

        etSender:
        begin
          if XMLElement.Kind = epOpening then
            FDataObject.SourceBaseKey := XMLReader.GetIntegerTextValueOfElement(XMLElement);
        end;

        etReceiver:
        begin
          if XMLElement.Kind = epOpening then
            FDataObject.TargetBaseKey := XMLReader.GetIntegerTextValueOfElement(XMLElement);
        end;

        etReceivedRecord:
        begin
          I := XMLReader.GetIntegerParamValueByName(XMLElement, XML_P_XID);
          J := XMLReader.GetIntegerParamValueByName(XMLElement, XML_P_DBID);
          FDataObject.AddReceivedRecord(I, J);
        end;

        etReferencedRecord:
        begin
          I := XMLReader.GetIntegerParamValueByName(XMLElement, XML_P_ID);
          J := XMLReader.GetIntegerParamValueByName(XMLElement, XML_P_XID);
          K := XMLReader.GetIntegerParamValueByName(XMLElement, XML_P_DBID);
          FDataObject.AddReferencedRecord(I, J, K);
        end;

        etOrderItem:
        begin
          I := XMLReader.GetIntegerParamValueByName(XMLElement, XML_P_OBJECTKEY);
          J := XMLReader.GetIntegerParamValueByName(XMLElement, XML_P_RECORDKEY);
          FLoadingOrderList.AddItem(J, I);
        end;

        etDataset:
        begin
          // �������� ������ ������������ ��������
          if XMLElement.Kind = epOpening then
          begin
            FCurrentDatasetKey := XMLReader.GetIntegerParamValueByName(XMLElement, XML_P_OBJECTKEY);
            FCurrentDatasetModifyFromStream := StrToBool(XMLReader.GetParamValueByName(XMLElement, PARAM_MODIFY_FROM_STREAM));

            // ��������� ����� � ������ ������������ �������
            LoadClassName := XMLReader.GetParamValueByName(XMLElement, 'classname');
            LoadSubType := XMLReader.GetParamValueByName(XMLElement, 'subtype');
            LoadSetTable := XMLReader.GetParamValueByName(XMLElement, 'settable');

            C := GetClass(LoadClassName);

            // ���������� �����, ���� �� �� ������
            if C = nil then
            begin
              AddMistake('��� �������� �� ������ �������� �������������� �����: ' + LoadClassName, clRed);
              if (AMissingClassList.IndexOf(LoadClassName) = -1)
                 and (not SilentMode)
                 and (MessageBox(0, PChar('��� �������� �� ������ �������� �������������� �����: ' + LoadClassName + #13#10#13#10 +
                   '���������� ��������?'),
                   '��������',
                   MB_YESNO or MB_ICONEXCLAMATION or MB_TASKMODAL) = IDNO) then
              begin
                raise Exception.Create(GetGsException(Self, 'LoadFromStream: Invalid class name'));
              end else
                AMissingClassList.Add(LoadClassName);
            end
            else
            begin
              FCurrentDataset := FDataObject.ClientDS[FDataObject.Add(LoadClassName, LoadSubType, LoadSetTable, FCurrentDatasetKey)];
              FCurrentGdcObject := FDataObject.gdcObject[FCurrentDatasetKey];
            end;
          end
          else
          begin
            FCurrentDataset := nil;
            FCurrentGdcObject := nil;
          end;
        end;

        // ���������� ��������
        etDatasetMetaData:
        begin
          // ������� ������ ������������ �������� �������� �����, � �������� ��������� XML
          if XMLElement.Kind = epOpening then
          begin
            if Assigned(FCurrentDataset) then
            begin
              // ������� ������ ������������ �������� ����� � XML �����
              FFieldCorrList.Clear;
              // ������� � ������� ������� ����� ��������� �����
              FCurrentDataset.Close;
              FCurrentDataset.FieldDefs.Clear;
            end
            else
              raise EgsXMLParseException.Create(Format('������ ������� <%0:s> ��� �������� <%1:s>',
                [XML_TAG_DATASET_METADATA, XML_TAG_DATASET]));
          end
          else
          begin
            if Assigned(FCurrentDataset) then
            begin
              // ������� ��������� ����
              FCurrentDataset.FieldDefs.Add('_' + PARAM_RUID, ftString, 21, False);
              FCurrentDataset.FieldDefs.Add('_' + PARAM_MODIFIED, ftDateTime, 0, False);
              FCurrentDataset.FieldDefs.Add('_' + PARAM_INSERT_FROM_STREAM, ftBoolean, 0, False);
              FCurrentDataset.FieldDefs.Add('_' + PARAM_MODIFY_FROM_STREAM, ftBoolean, 0, False);
              FCurrentDataset.FieldDefs.Add('_' + PARAM_SET_TABLE, ftString, 60, False);
              // �������� ������� �� ������ ���������� �����
              TClientDataset(FCurrentDataset).CreateDataset;
              TClientDataset(FCurrentDataset).LogChanges := False;
            end
            else
              raise EgsXMLParseException.Create(Format('������ ����������� ��� </%0:s> ��� ������������ ���� <%1:s>',
                [XML_TAG_DATASET_METADATA, XML_TAG_DATASET]));
          end;
        end;

        // ���� ��������
        etDatasetField:
        begin
          if Assigned(FCurrentDataset) then
            // ������� XML �������� ����
            ReadFieldDefinition(XMLReader, XMLElement)
          else
            raise EgsXMLParseException.Create(Format('������ ������� <%0:s> ��� �������� <%1:s>',
              [XML_TAG_DATASET_FIELD, XML_TAG_DATASET]));
        end;

        // ������ ��������
        etDatasetRowData:
        begin
          if not Assigned(FCurrentDataset) then
            raise EgsXMLParseException.Create(Format('������ ������� <%0:s> ��� �������� <%1:s>',
              [XML_TAG_DATASET_ROWDATA, XML_TAG_DATASET]));
        end;

        // ������ ��������
        etDatasetRow:
        begin
          if Assigned(FCurrentDataset) then
            ReadDatasetRecord(XMLReader, XMLElement)
          else
            raise EgsXMLParseException.Create(Format('������ ������� <%0:s> ��� �������� <%1:s>',
              [XML_TAG_DATASET_ROW, XML_TAG_DATASET]));
        end;

        // ��������� ���������
        etSettingHeader:
        begin
          if XMLElement.Kind = epOpening then
          begin
            SettingHeaderKey := SettingElementIterator;
            Inc(SettingElementIterator);

            FDataObject.CreateSettingMetadata;
            FCurrentDataset := FDataObject.SettingHeaderDataset;
            // ������ ����� ���������
            FCurrentDataset.Insert;
            FCurrentDataset.FieldByName('ID').AsInteger := SettingHeaderKey;
            FCurrentDataset.FieldByName('_' + PARAM_RUID).AsString := XMLReader.GetParamValueByName(XMLElement, PARAM_RUID);
            FCurrentDataset.FieldByName('NAME').AsString := XMLReader.GetParamValueByName(XMLElement, 'name');
            FCurrentDataset.FieldByName('DESCRIPTION').AsString := XMLReader.GetParamValueByName(XMLElement, 'description');
            FCurrentDataset.FieldByName('MODIFYDATE').AsDateTime := SafeStrToDateTime(XMLReader.GetParamValueByName(XMLElement, 'modifydate'));
            FCurrentDataset.FieldByName('VERSION').AsInteger := XMLReader.GetIntegerParamValueByName(XMLElement, 'version');
            FCurrentDataset.FieldByName('ENDING').AsInteger := XMLReader.GetIntegerParamValueByName(XMLElement, 'ending');
            FCurrentDataset.FieldByName('SETTINGSRUID').AsString := XMLReader.GetParamValueByName(XMLElement, 'settingsruid');
            FCurrentDataset.FieldByName('MINEXEVERSION').AsString := XMLReader.GetParamValueByName(XMLElement, 'minexeversion');
            FCurrentDataset.FieldByName('MINDBVERSION').AsString  := XMLReader.GetParamValueByName(XMLElement, 'mindbversion');
            FCurrentDataset.Post;
          end;
        end;

        // ������ ������� ���������
        etSettingPosList:
          if XMLElement.Kind = epOpening then
            FCurrentDataset := FDataObject.SettingPosDataset
          else
            FCurrentDataset := nil;

        // ������� ���������
        etSettingPos:
        begin
          if Assigned(FDataObject.SettingHeaderDataset) then
          begin
            FCurrentDataset.Insert;
            FCurrentDataset.FieldByName('ID').AsInteger := SettingElementIterator;
            FCurrentDataset.FieldByName('SETTINGKEY').AsInteger := SettingHeaderKey;
            FCurrentDataset.FieldByName('CATEGORY').AsString := XMLReader.GetParamValueByName(XMLElement, 'category');
            FCurrentDataset.FieldByName('OBJECTNAME').AsString := XMLReader.GetParamValueByName(XMLElement, 'objectname');
            FCurrentDataset.FieldByName('MASTERCATEGORY').AsString := XMLReader.GetParamValueByName(XMLElement, 'mastercategory');
            FCurrentDataset.FieldByName('MASTERNAME').AsString := XMLReader.GetParamValueByName(XMLElement, 'mastername');
            FCurrentDataset.FieldByName('OBJECTORDER').AsString := XMLReader.GetParamValueByName(XMLElement, 'objectorder');
            FCurrentDataset.FieldByName('WITHDETAIL').AsString := XMLReader.GetParamValueByName(XMLElement, 'withdetail');
            FCurrentDataset.FieldByName('NEEDMODIFY').AsString := XMLReader.GetParamValueByName(XMLElement, 'needmodify');
            FCurrentDataset.FieldByName('AUTOADDED').AsString := XMLReader.GetParamValueByName(XMLElement, 'autoadded');
            FCurrentDataset.FieldByName('OBJECTCLASS').AsString := XMLReader.GetParamValueByName(XMLElement, 'objectclass');
            FCurrentDataset.FieldByName('SUBTYPE').AsString := XMLReader.GetParamValueByName(XMLElement, 'subtype');
            FCurrentDataset.FieldByName('XID').AsString := XMLReader.GetParamValueByName(XMLElement, XML_P_XID);
            FCurrentDataset.FieldByName('DBID').AsString := XMLReader.GetParamValueByName(XMLElement, XML_P_DBID);
            FCurrentDataset.FieldByName('_' + PARAM_RUID).AsString := XMLReader.GetParamValueByName(XMLElement, PARAM_RUID);
            FCurrentDataset.Post;
            Inc(SettingElementIterator);
          end
          else
            raise Exception.Create('�� ������ ������ FDataObject.SettingHeaderDataset');
        end;

        // ������ ���������
        etSettingData:
        begin
          if XMLElement.Kind = epOpening then
          begin
          
          end;
        end;
      end;
    end;
  finally
    FreeAndNil(XMLReader);
    FreeAndNil(AMissingClassList);
  end;
end;

procedure TgdcStreamXMLWriterReader.SaveToStream(S: TStream);
var
  XMLWriter: Tgd_XMLWriter;
begin
  inherited;

  XMLWriter := Tgd_XMLWriter.Create;
  try
    XMLWriter.Stream := Stream;

    XMLWriter.AddProlog;

    if Assigned(FDataObject.SettingHeaderDataset) then
      InternalSaveSettingToStream(XMLWriter)
    else
      InternalSaveToStream(XMLWriter);
  finally
    FreeAndNil(XMLWriter);
  end;
end;

procedure TgdcStreamXMLWriterReader.WriteDataset(XMLWriter: Tgd_XMLWriter; CDS: TDataSet);
var
  I: Integer;
  FD: TFieldDef;
  KeyField: TField;
begin
  // ������� ��� ��������
  XMLWriter.AddAttribute(XML_P_OBJECTKEY, IntToStr(FCurrentDatasetKey));
  XMLWriter.AddAttribute('classname', FCurrentGdcObject.Classname);
  XMLWriter.AddAttribute('subtype', FCurrentGdcObject.SubType);
  XMLWriter.AddAttribute('settable', FCurrentDataset.FieldByName('_' + PARAM_SET_TABLE).AsString);
  XMLWriter.AddAttribute(PARAM_INSERT_FROM_STREAM, BoolToStr(True));                   // TODO: ����� �� ��������� ��� ������ ��
  XMLWriter.AddAttribute(PARAM_MODIFY_FROM_STREAM, BoolToStr(FCurrentGdcObject.NeedModifyFromStream(FCurrentGdcObject.SubType)));
  XMLWriter.AddOpenTag(XML_TAG_DATASET);
  // ������� ��� ���������� ��������
  XMLWriter.AddOpenTag(XML_TAG_DATASET_METADATA);
  // ������ ����� ��������
  for I := 0 to CDS.FieldDefs.Count - 1 do
  begin
    // �� ����� ��������� ���������� ��������� �����
    if StrLeft(CDS.Fields[I].FieldName, 1) <> '_' then
    begin
      FD := CDS.FieldDefs[I];
      if AnsiPos('$', FD.Name) > 0 then
      begin
        XMLWriter.AddAttribute('name', UpperCase(StringReplace(CDS.Fields[I].FieldName, '$', '_', [rfReplaceAll])));
        XMLWriter.AddAttribute('originalname', UpperCase(FD.Name));
      end
      else
        XMLWriter.AddAttribute('name', UpperCase(FD.Name));
      XMLWriter.AddAttribute('type', FieldTypeToString(FD.DataType));
      // ������ �������������� ���� ��� ����������
      if FD.Required then
        XMLWriter.AddAttribute('required', '1');
      // ��� ����� � ������������� ������ ������ ��������
      if (FD.DataType in [ftCurrency, ftBCD]) and (FD.Precision > 0) then
        XMLWriter.AddAttribute('precision', IntToStr(FD.Precision));
      // ��� ����� � �������� ����� ������ ������ ����
      //  ��� ����� � ������������� ������ ������ ���-�� ������ ����� �������
      if FD.Size > 0 then
        if FD.DataType in [ftString, ftWideString, ftBytes, ftVarBytes] then
          XMLWriter.AddAttribute('size', IntToStr(FD.Size))
        else if FD.DataType in [ftBCD, ftCurrency] then
          XMLWriter.AddAttribute('decimals', IntToStr(FD.Size));

      XMLWriter.AddShortElement(XML_TAG_DATASET_FIELD, True);
    end;
  end;
  // ������� ��� ���������� ��������
  XMLWriter.AddCloseTag(XML_TAG_DATASET_METADATA);

  // ������� ��� ������ ��������
  XMLWriter.AddOpenTag(XML_TAG_DATASET_ROWDATA);
  FCurrentRecordKey := -1;
  CDS.First;
  while not CDS.Eof do
  begin
    // ��������� �������� ������ ��������
    if not CDS.FieldByName('_' + PARAM_RUID).IsNull then
      XMLWriter.AddAttribute(PARAM_RUID, CDS.FieldByName('_' + PARAM_RUID).AsString);

    if not CDS.FieldByName('_' + PARAM_MODIFIED).IsNull then
      XMLWriter.AddAttribute(PARAM_MODIFIED, CDS.FieldByName('_' + PARAM_MODIFIED).AsString);

    if not CDS.FieldByName('_' + PARAM_INSERT_FROM_STREAM).IsNull then
      XMLWriter.AddAttribute(PARAM_INSERT_FROM_STREAM, CDS.FieldByName('_' + PARAM_INSERT_FROM_STREAM).AsString);

    if not CDS.FieldByName('_' + PARAM_MODIFY_FROM_STREAM).IsNull then
      XMLWriter.AddAttribute(PARAM_MODIFY_FROM_STREAM, CDS.FieldByName('_' + PARAM_MODIFY_FROM_STREAM).AsString);

    if not CDS.FieldByName('_' + PARAM_SET_TABLE).IsNull then
      XMLWriter.AddAttribute(PARAM_SET_TABLE, CDS.FieldByName('_' + PARAM_SET_TABLE).AsString);

    // ��� ������ ��������
    XMLWriter.AddOpenTag(XML_TAG_DATASET_ROW, True);
    try
      KeyField := CDS.FindField(FCurrentGdcObject.GetKeyField(FCurrentGdcObject.SubType));
      if Assigned(KeyField) then
        FCurrentRecordKey := KeyField.AsInteger;

      for I := 0 to CDS.FieldCount - 1 do
      begin
        // �� ����� ��������� �������� ������ �����, ����� ��������� ���� ���������� � �������� ROW
        if (not CDS.Fields[I].IsNull) and (StrLeft(CDS.Fields[I].FieldName, 1) <> '_') then
          WriteDatasetField(XMLWriter, CDS.Fields[I]);
      end;
    finally
      FCurrentRecordKey := -1;
    end;
    XMLWriter.AddCloseTag(XML_TAG_DATASET_ROW);
    CDS.Next;
  end;
  // ������� ��� ������ ��������
  XMLWriter.AddCloseTag(XML_TAG_DATASET_ROWDATA);
  // ������� ��� ��������
  XMLWriter.AddCloseTag(XML_TAG_DATASET);
end;

function TgdcStreamXMLWriterReader.GetXMLSettingHeader(S: TStream;
  SettingHeader: TSettingHeader): Boolean;
var
  XMLReader: Tgd_XMLReader;
  XMLElement: TgsXMLElement;
  I: Integer;
begin
  Result := False;

  XMLReader := Tgd_XMLReader.Create;
  try
    XMLReader.Stream := S;

    while XMLReader.GetNextElement(XMLElement) do
    begin
      case GetElementType(XMLElement) of
        // ���� ����� ��� STREAM ������ ��� SETTING_HEADER,
        //  ������ ������ ������� ���� ������, � �� ���������
        etStream:
          Exit;

        etSettingHeader:
        begin
          if XMLElement.Kind = epOpening then
          begin
            SettingHeader.RUID := StrToRUID(XMLReader.GetParamValueByName(XMLElement, 'ruid'));
            SettingHeader.Name := XMLReader.GetParamValueByName(XMLElement, 'name');
            SettingHeader.Comment := XMLReader.GetParamValueByName(XMLElement, 'description');
            SettingHeader.Date := SafeStrToDateTime(XMLReader.GetParamValueByName(XMLElement, 'modifydate'));
            SettingHeader.Version := XMLReader.GetIntegerParamValueByName(XMLElement, 'version');
            SettingHeader.Ending := XMLReader.GetIntegerParamValueByName(XMLElement, 'ending');
            SettingHeader.InterRUID.CommaText := XMLReader.GetParamValueByName(XMLElement, 'settingsruid');
            SettingHeader.MinEXEVersion := XMLReader.GetParamValueByName(XMLElement, 'minexeversion');
            SettingHeader.MinDBVersion := XMLReader.GetParamValueByName(XMLElement, 'mindbversion');
          end;

          // ������� �� RUID'�
          I := 0;
          while I < SettingHeader.InterRUID.Count do
          begin
            if Length(SettingHeader.InterRUID[I]) > 0 then
            begin
              // ������� �������, ���� ����
              if (SettingHeader.InterRUID[I][1] = '''') and (SettingHeader.InterRUID[i][Length(SettingHeader.InterRUID[I])] = '''') then
                SettingHeader.InterRUID[I] := Copy(SettingHeader.InterRUID[i], 2, Length(SettingHeader.InterRUID[i])-2);
              // ��������� ������������ RUID'�
              try
                StrToRUID(SettingHeader.InterRUID[I]);
              except
                SettingHeader.InterRUID.Delete(I);
                Dec(I);
              end;
              Inc(I);
            end
            else
              SettingHeader.InterRUID.Delete(I);
          end;

          // ������� ����� ���������, �������
          Result := True;
          Break;
        end;
      end;
    end;
  finally
    FreeAndNil(XMLReader);
  end;
end;

function TgdcStreamXMLWriterReader.ConvertStorageBlobValue(AField: TField): String;
var
  StorageValueStr: String;
  StIn, StOut: TStringStream;
  Sign, Grid: String;
begin
  Result := '';

  StorageValueStr := AField.AsString;
  SetLength(Sign, 3);
  SetLength(Grid, 11);
  Sign := UpperCase(Copy(StorageValueStr, 0, 3));
  Grid := UpperCase(Copy(StorageValueStr, 7, 11));
  if (Sign = 'TPF') and (Grid <> 'GRID_STREAM') then
  begin
    StIn := TStringStream.Create(StorageValueStr);
    StOut := TStringStream.Create('');
    try
      StIn.Position := 0;
      ObjectBinaryToText(StIn, StOut);
      Result := StOut.DataString;
    finally
      StOut.Free;
      StIn.Free;
    end;
  end
  else if IsXML(StorageValueStr) then
  begin
    Result := StorageValueStr;
  end
  else
    Result := ConvertToMultilineMemoTag(MimeEncodeString(StorageValueStr));
end;

procedure TgdcStreamXMLWriterReader.ReadFieldDefinition(XMLReader: Tgd_XMLReader; XMLElement: TgsXMLElement);
var
  FieldDefinition: TFieldDef;
  XMLFieldName, DatasetFieldName: String;
begin
  // ��������� ������ ������������ �������� ��������� XML � �������� �������� �����
  XMLFieldName := XMLReader.GetParamValueByName(XMLElement, 'name');
  DatasetFieldName := XMLReader.GetParamValueByName(XMLElement, 'originalname');
  if DatasetFieldName = '' then
    DatasetFieldName := XMLFieldName;
  FFieldCorrList.Add(XMLFieldName + '=' + DatasetFieldName);

  // ������� ���� � �������
  FieldDefinition := FCurrentDataset.FieldDefs.AddFieldDef;
  FieldDefinition.Name := DatasetFieldName;
  FieldDefinition.DataType := StringToFieldType(XMLReader.GetParamValueByName(XMLElement, 'type'));
  FieldDefinition.Precision := XMLReader.GetIntegerParamValueByName(XMLElement, 'precision');
  // ��� ����� ����������� SIZE, ��� �������� � ������������� ������ - DECIMALS
  FieldDefinition.Size :=
    XMLReader.GetIntegerParamValueByName(XMLElement, 'size') + XMLReader.GetIntegerParamValueByName(XMLElement, 'decimals');
  FieldDefinition.Required := XMLReader.GetIntegerParamValueByName(XMLElement, 'required') = 1;
end;

procedure TgdcStreamXMLWriterReader.ReadDatasetRecord(XMLReader: Tgd_XMLReader; XMLElement: TgsXMLElement);
var
  FieldXMLElement: TgsXMLElement;
  DatasetFieldName: String;
  DatasetField: TField;
  ParamValue: String;
begin
  FCurrentDataset.Insert;
  // ��������� ��������� ������
  ParamValue := XMLReader.GetParamValueByName(XMLElement, PARAM_RUID);
  if ParamValue <> '' then
    FCurrentDataset.FieldByName('_' + PARAM_RUID).AsString := ParamValue;

  ParamValue := XMLReader.GetParamValueByName(XMLElement, PARAM_MODIFIED);
  if ParamValue <> '' then
    FCurrentDataset.FieldByName('_' + PARAM_MODIFIED).AsDateTime := SafeStrToDateTime(ParamValue)
  else
    FCurrentDataset.FieldByName('_' + PARAM_MODIFIED).AsDateTime := Now;  

  ParamValue := XMLReader.GetParamValueByName(XMLElement, PARAM_INSERT_FROM_STREAM);
  if ParamValue <> '' then
    FCurrentDataset.FieldByName('_' + PARAM_INSERT_FROM_STREAM).AsBoolean := StrToBool(ParamValue);

  ParamValue := XMLReader.GetParamValueByName(XMLElement, PARAM_MODIFY_FROM_STREAM);
  if ParamValue <> '' then
    FCurrentDataset.FieldByName('_' + PARAM_MODIFY_FROM_STREAM).AsBoolean := StrToBool(ParamValue);

  ParamValue := XMLReader.GetParamValueByName(XMLElement, PARAM_SET_TABLE);
  if ParamValue <> '' then
    FCurrentDataset.FieldByName('_' + PARAM_SET_TABLE).AsString := ParamValue;

  // �������� ����� �� ���������
  FCurrentDataset.FieldByName('_' + PARAM_MODIFY_FROM_STREAM).AsBoolean := FCurrentDatasetModifyFromStream;
  // ������ �������� ����� ������ �� XML
  while XMLReader.GetNextElement(FieldXMLElement) do
  begin
    // ���� ����� �� ����� ������, �� ������� �� �����
    if (FieldXMLElement.Tag = XML_TAG_DATASET_ROW) and (FieldXMLElement.Kind = epClosing) then
      Break;

    if FieldXMLElement.Kind in [epOpening, epShort] then
    begin
      // ������� �������� ��� ����, �������� � �������� �������������� $ � ���� �������� �� _
      DatasetFieldName := FFieldCorrList.Values[FieldXMLElement.Tag];
      if DatasetFieldName <> '' then
      begin
        DatasetField := FCurrentDataset.FindField(DatasetFieldName);
        // ���� ���� ����� ����, ������� ��������� ����������
        if Assigned(DatasetField) then
          ReadDatasetField(XMLReader, FieldXMLElement, DatasetField);
      end;
    end;
  end;
  FCurrentDataset.Post;
end;

procedure TgdcStreamXMLWriterReader.WriteDatasetField(XMLWriter: Tgd_XMLWriter; AField: TField);
var
  CurrentFieldName: String;
  StorageValueStr: String;
  StorageValuePath: String;

  procedure WriteIntCDATAElement(const TagName, TagValue: String);
  begin
    XMLWriter.AddOpenTag(TagName);
    XMLWriter.AddTextValue(TagValue, True);
    XMLWriter.AddCloseTag(TagName);
  end;

  procedure WriteExtElement(const TagName, TagValue, FileName: String; const ValueType: TgsExtSettingFileType);
  var
    ExtFileName: String;
  begin
    ExtFileName := WriteValueToExtFile(TagValue, FileName, ValueType);
    XMLWriter.AddAttribute(XML_P_FILE, ExtFileName);
    XMLWriter.AddShortElement(TagName, True);
  end;

begin
  CurrentFieldName := UpperCase(StringReplace(AField.FieldName, '$', '_', [rfReplaceAll]));

  case AField.DataType of
    ftMemo, ftBLOB, ftGraphic:
    begin
      if (AnsiCompareText(FCurrentGdcObject.Classname, 'TgdcFunction') = 0)
         and (AnsiCompareText(AField.FieldName, 'SCRIPT') = 0) then
      begin
        WriteExtElement(CurrentFieldName, AField.AsString, FCurrentDataset.FieldByName('name').AsString, eftFunction);
      end
      else if (AnsiCompareText(FCurrentGdcObject.Classname, 'TgdcTemplate') = 0)
         and (AnsiCompareText(AField.FieldName, 'TEMPLATEDATA') = 0) then
      begin
        WriteExtElement(CurrentFieldName, AField.AsString, FCurrentDataset.FieldByName('name').AsString, eftReportTemplate);
      end
      else if (AnsiCompareText(FCurrentGdcObject.Classname, 'TgdcStoredProc') = 0)
         and (AnsiCompareText(AField.FieldName, 'PROCEDURESOURCE') = 0) then
      begin
        WriteExtElement(CurrentFieldName, AField.AsString, FCurrentDataset.FieldByName('procedurename').AsString, eftStoredProcedure);
      end
      else if (AnsiCompareText(FCurrentGdcObject.Classname, 'TgdcTrigger') = 0)
         and (AnsiCompareText(AField.FieldName, 'RDB$TRIGGER_SOURCE') = 0) then
      begin
        WriteExtElement(CurrentFieldName, AField.AsString, FCurrentDataset.FieldByName('triggername').AsString, eftTrigger);
      end
      else if AnsiCompareText(FCurrentGdcObject.Classname, 'TgdcStorageValue') = 0 then
      begin
        // ���� ���� ���� ����������� ��� ���������, �� � ��� ����� ���� DFM � ��� �� ���� ����������
        StorageValueStr := ConvertStorageBlobValue(AField);
        if AnsiPos('object', StorageValueStr) = 1 then
        begin
          // �������� �� ����������� ������ ��������� � �������� ���� � ����
          FCurrentGdcObject.ID := FCurrentRecordKey;
          StorageValuePath := StrRestOf(TgdcStorageValue(FCurrentGdcObject).GetPath, 2);       // ������ ������ ����

          WriteExtElement(CurrentFieldName, StorageValueStr, StorageValuePath, eftForm);
        end
        else if IsXML(StorageValueStr) then
        begin
          // �������� �� ����������� ������ ��������� � �������� ���� � ����
          FCurrentGdcObject.ID := FCurrentRecordKey;
          StorageValuePath := StrRestOf(TgdcStorageValue(FCurrentGdcObject).GetPath, 2);       // ������ ������ ����

          WriteExtElement(CurrentFieldName, StorageValueStr, StorageValuePath, eftGrid);
        end
        else
        begin
          WriteIntCDATAElement(CurrentFieldName, StorageValueStr);
        end;
      end
      else
      begin
        if IsXML(AField.AsString) or not (AField.DataType in [ftBLOB, ftGraphic]) then
          WriteIntCDATAElement(CurrentFieldName, ConvertToMultilineMemoTag(AField.AsString))
        else
          WriteIntCDATAElement(CurrentFieldName, ConvertToMultilineMemoTag(MimeEncodeString(AField.AsString)));
      end;
    end;

    ftDate, ftDateTime, ftTime:
      XMLWriter.AddElement(CurrentFieldName, SafeDateTimeToStr(AField.AsDateTime));

    ftFloat, ftCurrency, ftBCD:
      XMLWriter.AddElement(CurrentFieldName, SafeFloatToStr(AField.AsFloat));
  else
    XMLWriter.AddElement(CurrentFieldName, AField.AsString);
  end;
end;

// ����� �������� ������ ����� � ������������� STRING � ���� <L>
//  � ������ ����� ���� ����������� �������
function TgdcStreamXMLWriterReader.ConvertToMultilineMemoTag(const AMemoValue: String): String;
begin
  Result := Trim(AMemoValue);

  // ������� ��� �������� ������ �� �������� - �������� ���� <L> + ������ + ������� ������
  Result :=
    '<' + XML_TAG_MULTILINE_SPLITTER + '>' +
    StringReplace(Result, NEW_LINE,
      '</' + XML_TAG_MULTILINE_SPLITTER + '>' + NEW_LINE + '<' + XML_TAG_MULTILINE_SPLITTER + '>',
      [rfReplaceAll, rfIgnoreCase]) +
    '</' + XML_TAG_MULTILINE_SPLITTER + '>';
end;

function TgdcStreamXMLWriterReader.WriteValueToExtFile(const AValue, AFileName: String; const AFileType: TgsExtSettingFileType): String;
var
  FileStream: TFileStream;
  FolderName: String;
  FileFolderName: String;

  function CorrectFileName(const FN: String): String;
  const
    CorrectSymbols = ['A'..'Z', 'a'..'z', '�'..'�', '_', '0'..'9', ' ', '(', ')', '$', '.'];
  var
    i: Integer;
  begin
    Result := '';
    for I := 1 to Length(FN) do
      if FN[I] in CorrectSymbols then
        Result := Result + FN[I]
      else
        Result := Result + '_';
  end;

begin
  if ExtFolderExists then
  begin
    FolderName := FFileDir + '\' + EXT_FOLDER_NAME;
    FileFolderName := GetExtFolderName(AFileType);
    if ForceDirectories(FolderName + '\' + FileFolderName) then
    begin
      Result := FileFolderName + '\' + CorrectFileName(AFileName) + '.' + GetExtFileExtrension(AFileType);

      FileStream := TFileStream.Create(FolderName + '\' + Result, fmCreate);
      try
        StreamWritePlainString(FileStream, AValue);
      finally
        FreeAndNil(FileStream);
      end;
    end;
  end;
end;

function TgdcStreamXMLWriterReader.ReadValueFromExtFile(const AFileName: String): String;
var
  FileStream: TFileStream;
  FullFileName: String;
begin
  if ExtFolderExists then
  begin
    FullFileName := FFileDir + '\' + EXT_FOLDER_NAME + '\' + AFileName;
    if FileExists(FullFileName) then
    begin
      FileStream := TFileStream.Create(FullFileName, fmOpenRead	or fmShareDenyWrite);
      try
        SetLength(Result, FileStream.Size);
        FileStream.Read(Result[1], FileStream.Size);
      finally
        FreeAndNil(FileStream);
      end;
    end;
  end;
end;

procedure TgdcStreamXMLWriterReader.ReadDatasetField(
  XMLReader: Tgd_XMLReader; XMLElement: TgsXMLElement; AField: TField);
var
  ElementValue: String;
  ExtFileName: String;
begin
  ExtFileName := XMLReader.GetParamValueByName(XMLElement, XML_P_FILE);
  if ExtFileName <> '' then
  begin
    ElementValue := ReadValueFromExtFile(ExtFileName);
    if AnsiCompareText(FCurrentGdcObject.Classname, 'TgdcStorageValue') = 0 then
      AField.AsString := ParseStorageBlobValue(ElementValue)
    else
      AField.AsString := ElementValue;
  end
  else
  begin
    ElementValue := XMLReader.GetTextValueOfElement(XMLElement);

    case AField.DataType of
      ftMemo, ftBLOB, ftGraphic:
        if IsXML(ElementValue) or not (AField.DataType in [ftBLOB, ftGraphic]) then
          AField.AsString := ParseMultilineMemoTag(ElementValue)
        else
          AField.AsString := MimeDecodeString(ParseMultilineMemoTag(ElementValue));

      ftDate, ftDateTime, ftTime:
        AField.AsDateTime := SafeStrToDateTime(ElementValue);

      ftFloat, ftCurrency, ftBCD:
        AField.AsFloat := SafeStrToFloat(ElementValue);
    else
      AField.AsString := ElementValue;
    end;
  end;
end;

function TgdcStreamXMLWriterReader.ParseMultilineMemoTag(const ATagValue: String): String;
var
  StringList: TStringList;
  StringCounter: Integer;
begin
  // ������� ������� �������������� XML
  StringList := TStringList.Create;
  try
    StringList.Text := ATagValue;
    for StringCounter := 0 to StringList.Count - 1 do
    begin
      StringList.Strings[StringCounter] := Trim(StringList.Strings[StringCounter]);
      StringList.Strings[StringCounter] := StrMid(StringList.Strings[StringCounter], 4, StrLength(StringList.Strings[StringCounter]) - 7);
    end;
    // ������� ���� XML_TAG_MULTILINE_SPLITTER
    //Result := StringReplace(StringList.Text, '<' + XML_TAG_MULTILINE_SPLITTER + '>', '', [rfReplaceAll, rfIgnoreCase]);
    //Result := StringReplace(Result, '</' + XML_TAG_MULTILINE_SPLITTER + '>', '', [rfReplaceAll, rfIgnoreCase]);
    Result := StringList.Text;
  finally
    StringList.Free;
  end;
end;

function TgdcStreamXMLWriterReader.ParseStorageBlobValue(const AFieldValue: String): String;
var
  StIn, StOut: TStringStream;
begin
  // ���� ��� �������� TgsStreamValue, �� ��� ��� ��������� ����
  //  ��� �������� ������ (�������� ��������� �����)
  if AnsiPos('object', AFieldValue) > 0 then
  begin
    // ����������� ��������� ����� � ����������� �������
    StIn := TStringStream.Create(AFieldValue);
    StOut := TStringStream.Create('');
    try
      ObjectTextToBinary(StIn, StOut);
      Result := StOut.DataString;
    finally
      StOut.Free;
      StIn.Free;
    end;
  end
  else if IsXML(AFieldValue) then
  begin
    Result := AFieldValue;
  end
  else
    Result := MimeDecodeString(AFieldValue);
end;

procedure TgdcStreamXMLWriterReader.InternalSaveToStream(XMLWriter: Tgd_XMLWriter);
var
  I, K: Integer;
  IBSQL: TIBSQL;
begin
  // ������� �������� ��� ���������
  XMLWriter.AddOpenTag(XML_TAG_STREAM);
  XMLWriter.AddAttribute(XML_P_VERSION, IntToStr(cst_StreamVersionNew));
  XMLWriter.AddAttribute(XML_P_DBID, IntToStr(IBLogin.DBID));
  XMLWriter.AddOpenTag(XML_TAG_HEADER);

  // ���� ���� ������������ ����������
  if FDataObject.TargetBaseKey > -1 then
  begin
    // ������ ��� ������ �� ������� RPL_DATABASE
    IBSQL := TIBSQL.Create(nil);
    try
      IBSQL.Database := gdcBaseManager.Database;
      IBSQL.Transaction := gdcBaseManager.ReadTransaction;
      IBSQL.SQL.Text := sqlSelectAllBases;
      IBSQL.ExecQuery;
      if not IBSQL.Eof then
      begin
        XMLWriter.AddOpenTag(XML_TAG_DATABASE_LIST);
        while not IBSQL.Eof do
        begin
          XMLWriter.AddAttribute(XML_P_ID, IntToStr(IBSQL.FieldByName('ID').AsInteger));
          XMLWriter.AddAttribute('name', IBSQL.FieldByName('NAME').AsString);
          XMLWriter.AddShortElement(XML_TAG_DATABASE);
          IBSQL.Next;
        end;
        XMLWriter.AddCloseTag(XML_TAG_DATABASE_LIST);
      end;
    finally
      IBSQL.Free;
    end;

    // ID (�� ������� RPL_DATABASE) ���������� ����� ����
    XMLWriter.AddElement(XML_TAG_SENDER, IntToStr(FDataObject.OurBaseKey));
    // ID (�� ������� RPL_DATABASE) ����������� ����� ����
    XMLWriter.AddElement(XML_TAG_RECEIVER, IntToStr(FDataObject.TargetBaseKey));

    // ����� ������� RUID'� �������, ��������� ������� �� ������������
    I := FDataObject.ReceivedRecordsCount;
    if I > 0 then
    begin
      XMLWriter.AddOpenTag(XML_TAG_RECEIVED_RECORD_LIST);
      for K := 0 to I - 1 do
      begin
        XMLWriter.AddAttribute(XML_P_XID, IntToStr(FDataObject.ReceivedRecord[K].XID));
        XMLWriter.AddAttribute(XML_P_DBID, IntToStr(FDataObject.ReceivedRecord[K].DBID));
        XMLWriter.AddShortElement(XML_TAG_RECEIVED_RECORD);
      end;
      XMLWriter.AddCloseTag(XML_TAG_RECEIVED_RECORD_LIST);
    end;
  end;

  // ����� ������� RUID'� � ID �������, ������� �� ����� � ������������ �����,
  //   �.�. ��� ������������ �� ������� ����
  I := FDataObject.ReferencedRecordsCount;
  if I > 0 then
  begin
    XMLWriter.AddOpenTag(XML_TAG_REFERENCED_RECORD_LIST);
    for K := 0 to I - 1 do
    begin
      XMLWriter.AddAttribute(XML_P_ID, IntToStr(FDataObject.ReferencedRecord[K].SourceID));
      XMLWriter.AddAttribute(XML_P_XID, IntToStr(FDataObject.ReferencedRecord[K].RUID.XID));
      XMLWriter.AddAttribute(XML_P_DBID, IntToStr(FDataObject.ReferencedRecord[K].RUID.DBID));
      XMLWriter.AddShortElement(XML_TAG_REFERENCED_RECORD);
    end;
    XMLWriter.AddCloseTag(XML_TAG_REFERENCED_RECORD_LIST);
  end;

  // ������� �������� �������, ����������� � ������ ������
  XMLWriter.AddOpenTag(XML_TAG_LOADING_ORDER);
  for K := 0 to FLoadingOrderList.Count - 1 do
  begin
    XMLWriter.AddAttribute(XML_P_OBJECTKEY, IntToStr(FLoadingOrderList.Items[K].DSIndex));
    XMLWriter.AddAttribute(XML_P_RECORDKEY, IntToStr(FLoadingOrderList.Items[K].RecordID));
    XMLWriter.AddShortElement(XML_TAG_LOADING_ORDER_ITEM, True);
  end;
  XMLWriter.AddCloseTag(XML_TAG_LOADING_ORDER);

  // ������� ��� ��������� ���������
  XMLWriter.AddCloseTag(XML_TAG_HEADER);

  // ������� ��� ������ ���������
  XMLWriter.AddOpenTag(XML_TAG_DATA);
  for K := 0 to FDataObject.Count - 1 do
  begin
    if FDataObject.ClientDS[K].RecordCount > 0 then
    begin
      FCurrentDatasetKey := K;
      FCurrentDataset := FDataObject.ClientDS[K];
      FCurrentGdcObject := FDataObject.gdcObject[K];
      try
        WriteDataset(XMLWriter, FCurrentDataset);
      finally
        FCurrentGdcObject := nil;
        FCurrentDataset := nil;
        FCurrentDatasetKey := -1;
      end;
    end;
  end;
  // ������� ��� ������ ���������
  XMLWriter.AddCloseTag(XML_TAG_DATA);
  // ������� �������� ��� ���������
  XMLWriter.AddCloseTag(XML_TAG_STREAM);
end;

procedure TgdcStreamXMLWriterReader.InternalSaveSettingToStream(XMLWriter: Tgd_XMLWriter);
var
  CDS: TDataSet;
  AutoAddedExists: Boolean;
begin
  // ������� �������� ��� ���������
  XMLWriter.AddOpenTag(XML_TAG_SETTING);
  // ������� ��� ��������� ���������
  CDS := FDataObject.SettingHeaderDataset;
  XMLWriter.AddAttribute('name', CDS.FieldByName('name').AsString);
  XMLWriter.AddAttribute('version', CDS.FieldByName('version').AsString);
  XMLWriter.AddAttribute('modifydate', SafeDateTimeToStr(CDS.FieldByName('modifydate').AsDateTime));
  XMLWriter.AddAttribute('description', CDS.FieldByName('description').AsString);
  XMLWriter.AddAttribute('ending', CDS.FieldByName('ending').AsString);
  XMLWriter.AddAttribute('settingsruid', CDS.FieldByName('settingsruid').AsString);
  XMLWriter.AddAttribute('minexeversion', CDS.FieldByName('minexeversion').AsString);
  XMLWriter.AddAttribute('mindbversion', CDS.FieldByName('mindbversion').AsString);
  XMLWriter.AddAttribute(PARAM_RUID, CDS.FieldByName('_' + PARAM_RUID).AsString);
  XMLWriter.AddOpenTag(XML_TAG_SETTING_HEADER);

  // ������� ������ ���������
  XMLWriter.AddOpenTag(XML_TAG_SETTING_POS_LIST);
  CDS := FDataObject.SettingPosDataset;
  if not CDS.IsEmpty then
  begin
    AutoAddedExists := Assigned(atDatabase.FindRelationField('AT_SETTINGPOS', 'AUTOADDED'));
    TClientDataset(CDS).IndexFieldNames := 'OBJECTORDER';
    CDS.First;
    while not CDS.Eof do
    begin
      XMLWriter.AddAttribute('category', CDS.FieldByName('CATEGORY').AsString);
      XMLWriter.AddAttribute('objectname', CDS.FieldByName('OBJECTNAME').AsString);
      XMLWriter.AddAttribute('mastercategory', CDS.FieldByName('MASTERCATEGORY').AsString);
      XMLWriter.AddAttribute('mastername', CDS.FieldByName('MASTERNAME').AsString);
      XMLWriter.AddAttribute('objectorder', CDS.FieldByName('OBJECTORDER').AsString);
      XMLWriter.AddAttribute('withdetail', CDS.FieldByName('WITHDETAIL').AsString);
      XMLWriter.AddAttribute('needmodify', CDS.FieldByName('NEEDMODIFY').AsString);
      if AutoAddedExists then
        XMLWriter.AddAttribute('autoadded', CDS.FieldByName('AUTOADDED').AsString);
      XMLWriter.AddAttribute('objectclass', CDS.FieldByName('OBJECTCLASS').AsString);
      XMLWriter.AddAttribute('subtype', CDS.FieldByName('SUBTYPE').AsString);
      XMLWriter.AddAttribute('xid', CDS.FieldByName('XID').AsString);
      XMLWriter.AddAttribute('dbid', CDS.FieldByName('DBID').AsString);
      XMLWriter.AddAttribute(PARAM_RUID, CDS.FieldByName('_' + PARAM_RUID).AsString);

      XMLWriter.AddShortElement(XML_TAG_SETTING_POS);
      CDS.Next;
    end;
  end;
  XMLWriter.AddCloseTag(XML_TAG_SETTING_POS_LIST);

  // ������� ��� ��������� ���������
  XMLWriter.AddCloseTag(XML_TAG_SETTING_HEADER);

  // ������ ���������
  XMLWriter.AddOpenTag(XML_TAG_SETTING_DATA);
  InternalSaveToStream(XMLWriter);
  XMLWriter.AddCloseTag(XML_TAG_SETTING_DATA);

  XMLWriter.AddCloseTag(XML_TAG_SETTING);
end;

function TgdcStreamXMLWriterReader.ExtFolderExists: Boolean;
begin
  Result := False;

  if FFileDir <> '' then
  begin
    Result := ForceDirectories(FFileDir + '\' + EXT_FOLDER_NAME);
  end;
end;

function TgdcStreamXMLWriterReader.GetElementType(const AElement: TgsXMLElement): TXMLElementType;
begin
  Result := etUnknown;
  if AnsiCompareText(AElement.Tag, XML_TAG_STREAM) = 0 then
    Result := etStream
  else if AnsiCompareText(AElement.Tag, XML_TAG_HEADER) = 0 then
    Result := etHeader
  else if AnsiCompareText(AElement.Tag, XML_TAG_DATABASE_LIST) = 0 then
    Result := etDataBaseList
  else if AnsiCompareText(AElement.Tag, XML_TAG_DATABASE) = 0 then
    Result := etDataBase
  else if AnsiCompareText(AElement.Tag, XML_TAG_SENDER) = 0 then
    Result := etSender
  else if AnsiCompareText(AElement.Tag, XML_TAG_RECEIVER) = 0 then
    Result := etReceiver
  else if AnsiCompareText(AElement.Tag, XML_TAG_RECEIVED_RECORD_LIST) = 0 then
    Result := etReceivedRecordList
  else if AnsiCompareText(AElement.Tag, XML_TAG_RECEIVED_RECORD) = 0 then
    Result := etReceivedRecord
  else if AnsiCompareText(AElement.Tag, XML_TAG_REFERENCED_RECORD_LIST) = 0 then
    Result := etReferencedRecordList
  else if AnsiCompareText(AElement.Tag, XML_TAG_REFERENCED_RECORD) = 0 then
    Result := etReferencedRecord
  else if AnsiCompareText(AElement.Tag, XML_TAG_LOADING_ORDER) = 0 then
    Result := etOrder
  else if AnsiCompareText(AElement.Tag, XML_TAG_LOADING_ORDER_ITEM) = 0 then
    Result := etOrderItem
  else if AnsiCompareText(AElement.Tag, XML_TAG_DATA) = 0 then
    Result := etData
  else if AnsiCompareText(AElement.Tag, XML_TAG_DATASET) = 0 then
    Result := etDataset
  else if AnsiCompareText(AElement.Tag, XML_TAG_SETTING) = 0 then
    Result := etSetting
  else if AnsiCompareText(AElement.Tag, XML_TAG_SETTING_HEADER) = 0 then
    Result := etSettingHeader
  else if AnsiCompareText(AElement.Tag, XML_TAG_SETTING_POS_LIST) = 0 then
    Result := etSettingPosList
  else if AnsiCompareText(AElement.Tag, XML_TAG_SETTING_POS) = 0 then
    Result := etSettingPos
  else if AnsiCompareText(AElement.Tag, XML_TAG_SETTING_DATA) = 0 then
    Result := etSettingData
  else if AnsiCompareText(AElement.Tag, XML_TAG_DATASET_METADATA) = 0 then
    Result := etDatasetMetaData        // ���������� ��������
  else if AnsiCompareText(AElement.Tag, XML_TAG_DATASET_FIELD) = 0 then
    Result := etDatasetField           // ���� ��������
  else if AnsiCompareText(AElement.Tag, XML_TAG_DATASET_ROWDATA) = 0 then
    Result := etDatasetRowData         // ������ ��������
  else if AnsiCompareText(AElement.Tag, XML_TAG_DATASET_ROW) = 0 then
    Result := etDatasetRow;            // ������ ��������
end;

function TgdcStreamXMLWriterReader.GetExtFolderName(
  const AFileType: TgsExtSettingFileType): String;
begin
  case AFileType of
    eftFunction:
      Result := 'function';
    eftForm:
      Result := 'form';
    eftReportTemplate:
      Result := 'report';
    eftStoredProcedure:
      Result := 'stored_procedure';
    eftTrigger:
      Result := 'trigger';
    eftGrid:
      Result := 'grid';
  else
    Result := 'unknown';
  end;
end;

function TgdcStreamXMLWriterReader.GetExtFileExtrension(
  const AFileType: TgsExtSettingFileType): String;
begin
  case AFileType of
    eftFunction:
      Result := 'vbs';
    eftForm:
      Result := 'dfm';
    eftReportTemplate:
      Result := 'fr';
    eftStoredProcedure, eftTrigger:
      Result := 'sql';
    eftGrid:
      Result := 'grid';
  else
    Result := 'txt';
  end;
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
  FSavingSetting := false;
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
  IsReplicationMode := False;
  // �� ��������� ��������� � ����� �������� �������
  FStreamFormat := sttBinaryNew;
  // ��������� �� ����������, ��������� �������� ���������� �������� ��� ������ �������
  if Assigned(GlobalStorage) then
    Self.StreamLogType := TgsStreamLoggingType(GlobalStorage.ReadInteger('Options', 'StreamLogType', 2));
  // �������� ����� SQL ����
  if not Assigned(frmSQLProcess) then
    frmSQLProcess := TfrmSQLProcess.Create(Application);
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


procedure TgdcStreamSaver.SaveToStream(S: TStream);
var
  FStreamWriterReader: TgdcStreamWriterReader;
begin
  if S = nil then
    raise Exception.Create(GetGsException(Self, 'SaveToStream: �� ���������� �����'));

  FStreamDataProvider.CheckNonConfirmedRecords;

  //��������� ���������� ������ � �����
  case FStreamFormat of
    sttBinaryNew:
      FStreamWriterReader := TgdcStreamBinaryWriterReader.Create(FDataObject, FStreamLoadingOrderList);

    sttXML:
      FStreamWriterReader := TgdcStreamXMLWriterReader.Create(FDataObject, FStreamLoadingOrderList);
  else
    FStreamWriterReader := TgdcStreamBinaryWriterReader.Create(FDataObject, FStreamLoadingOrderList);
  end;

  try
    // ��������� �������� ������� ��� ����� ��� ��������� ���� ���������� ������� ������
    FStreamWriterReader.FileName := FFileName;
    // �������� ������ � �����
    FStreamWriterReader.SaveToStream(S);
  finally
    FStreamWriterReader.Free;
  end;

  if StreamLoggingType in [slSimple, slAll] then
    AddText('����������� ���������� ������ � �����.', clBlack);
end;


procedure TgdcStreamSaver.LoadFromStream(S: TStream);
var
  Obj: TgdcBase;
  CDS: TDataSet;
  OrderElement: TStreamOrderElement;
  FStreamWriterReader: TgdcStreamWriterReader;
begin

  try
    if StreamLoggingType in [slSimple, slAll] then
      AddText('�������� �������� ������ �� ������.', clBlack);

    if Assigned(frmStreamSaver) then
      frmStreamSaver.SetProcessCaptionText('������ �����...');

    // ��������� ��� ������, � �������� ��������������� �������� ������
    case GetStreamType(S) of
      sttBinaryNew: FStreamWriterReader := TgdcStreamBinaryWriterReader.Create(FDataObject, FStreamLoadingOrderList);
      sttXML: FStreamWriterReader := TgdcStreamXMLWriterReader.Create(FDataObject, FStreamLoadingOrderList);
    else
      raise Exception.Create('����������� ��� ������');
    end;

    // �������� ������ �� ������ � ������
    try
      // ��������� ��������� ������� ��� ����� ��� ��������� ���� �������� ������� ������
      FStreamWriterReader.FileName := FFileName;
      FStreamWriterReader.LoadFromStream(S);
    finally
      FStreamWriterReader.Free;
    end;

    // ���� � ����� ���� ��������� ���������, ������ ������ ������ �� �� ����� ���������� � ActivateSetting
    //  ����� ������ ������ ������� �����
    if not Assigned(FDataObject.SettingHeaderDataset) then
    begin
      // ���������� ����������� ������ ��� ������
      FStreamDataProvider.ProcessDatabaseList;

      if (FDataObject.TargetBaseKey > -1) then
        if (FDataObject.TargetBaseKey = FDataObject.OurBaseKey) then
        begin
          FStreamDataProvider.LoadReceivedRecords;
        end
        else
        begin
          AddMistake('����������� ����� ������������ ��� ������ ���� ������. ID ����� ���� = '
            + IntToStr(FDataObject.OurBaseKey) + '. ID ������� ���� ������ = ' + IntToStr(FDataObject.TargetBaseKey) + '.', clRed);

          if Assigned(frmStreamSaver) then
            frmStreamSaver.AddMistake('����������� ����� ������������ ��� ������ ���� ������' + #13#10 +
              '  ID ����� ���� = ' + IntToStr(FDataObject.OurBaseKey) + #13#10 +
              '  ID ������� ���� ������ = ' + IntToStr(FDataObject.TargetBaseKey));

          raise Exception.Create('����������� ����� ������������ ��� ������ ���� ������');
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
        frmStreamSaver.SetupProgress(FStreamLoadingOrderList.Count, '�������� ������...');
      end;

      // ��������� ������ �� ������ �� ����
      while FStreamLoadingOrderList.PopNextElement(OrderElement) do
      begin
        Obj := FDataObject.gdcObject[OrderElement.DSIndex];
        CDS := FDataObject.ClientDS[OrderElement.DSIndex];
        if CDS.Locate(Obj.GetKeyField(Obj.SubType), OrderElement.RecordID, []) then
          FStreamDataProvider.LoadRecord(Obj, CDS)
        else
          raise Exception.Create('� ������ �� ������� ��������� ������: ' +
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

      // ��������� ������-��������� �� ����
      try
        FStreamDataProvider.LoadSetRecords;
      except
        on E: EgdcNoTable do
        begin
          AddMistake(Format('�� ������� ������� %s ��� �����-����� ����� ���������.', [E.Message]), clRed);
          if Assigned(frmStreamSaver) then
            frmStreamSaver.AddMistake(Format('�� ������� ������� %s ��� �����-����� ����� ���������.', [E.Message]));
        end;
      end;

      if FTransaction.InTransaction then
        if FTrWasActive then
          FTransaction.CommitRetaining
        else
          FTransaction.Commit
      else
        FTransaction.Rollback;
    end;

    if Assigned(frmStreamSaver) then
      frmStreamSaver.Done;

    if StreamLoggingType in [slSimple, slAll] then
      AddText('����������� �������� ������ �� ������.', clBlack);
  except
    on E: Exception do
    begin
      if FTransaction.InTransaction then
        FTransaction.Rollback;
      AddMistake(E.Message, clRed);
      if Assigned(frmStreamSaver) then
        frmStreamSaver.AddMistake(E.Message);
      raise;
    end;
  end;
end;


procedure TgdcStreamSaver.Clear;
begin
  // ������� ������� ������� � ��������������� ��������
  FDataObject.Clear;
  FStreamDataProvider.Clear;
  FStreamLoadingOrderList.Clear;

  FErrorMessageForSetting := '';
end;

procedure TgdcStreamSaver.SaveSettingData(const ASettingKey: TID);
var
  ibsqlPos: TIBSQL;
  WithDetailList: TgdKeyArray;
  NeedModifyList: TgdKeyIntAssoc;
  NeedInsertList: TgdKeyIntAssoc;
  IndexNeedModifyList: Integer;
  SaveDetailObjects: Boolean;
  AnID: TID;
  LineObjectID: TID;
  ObjectIndex: Integer;
  PositionsCount: Integer;
begin
  try
    ibsqlPos := TIBSQL.Create(nil);
    WithDetailList := TgdKeyArray.Create;
    NeedModifyList := TgdKeyIntAssoc.Create;
    NeedInsertList := TgdKeyIntAssoc.Create;
    try
      PositionsCount := 0;
      ibsqlPos.Transaction := FTransaction;

      // ������� ������� ����������� ���������
      ibsqlPos.SQL.Text := 'SELECT * FROM at_settingpos WHERE settingkey = :settingkey ' +
        ' ORDER BY objectorder';
      ibsqlPos.ParamByName('settingkey').AsInteger := ASettingKey;
      ibsqlPos.ExecQuery;
      while not ibsqlPos.Eof do
      begin
        LineObjectID := gdcBaseManager.GetIDByRUID(ibsqlPos.FieldByName('xid').AsInteger,
          ibsqlPos.FieldByName('dbid').AsInteger, FTransaction);
        // ���� �� �� �������� �� ������� �� �����, ������ ������ ��� ������
        if LineObjectID > -1 then
        begin
          // ���� �� ������ ��������� ������ � ���������� ���������, �� ������� ��� id � ������
          if ibsqlPos.FieldByName('withdetail').AsInteger = 1 then
            WithDetailList.Add(LineObjectID);
          // ���� �� �� ������ �������������� ������ ������� �� ������, �� ������� ��� id � ������
          IndexNeedModifyList := NeedModifyList.Add(LineObjectID);
          NeedModifyList.ValuesByIndex[IndexNeedModifyList] := ibsqlPos.FieldByName('needmodify').AsInteger;
          // �������� ������ ������������� ���������� ��������
          if Assigned(atDatabase.FindRelationField('AT_SETTINGPOS', 'NEEDINSERT')) then
          begin
            IndexNeedModifyList := NeedInsertList.Add(LineObjectID);
            NeedInsertList.ValuesByIndex[IndexNeedModifyList] := ibsqlPos.FieldByName('needinsert').AsInteger;
          end;
        end
        else
        begin
          // ���� �������� ����������, �� �� ����� ��������� ���������� ���������
          AddMistake(Format('�� ������� �������� ������������� ������� ��������� (XID = %0:d, DBID = %1:d)',
            [ibsqlPos.FieldByName('xid').AsInteger, ibsqlPos.FieldByName('dbid').AsInteger]), clRed);
          if not SilentMode then
          begin
            raise Exception.Create('�� ������� �������� ������������� ������� ���������.'#13#10 +
              '��������� ����������� ���������!');
          end;
        end;
        Inc(PositionsCount);
        ibsqlPos.Next;
      end;

      FStreamDataProvider.SaveWithDetailList := WithDetailList;
      FStreamDataProvider.NeedModifyList := NeedModifyList;

      if Assigned(frmStreamSaver) then
        frmStreamSaver.SetupProgress(PositionsCount, '������������ ���������...');

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

        FStreamDataProvider.ClearNowSavedRecordsList;
        FStreamDataProvider.SaveRecord(ObjectIndex, AnID, SaveDetailObjects);

        if Assigned(frmStreamSaver) then
          frmStreamSaver.Step;

        ibsqlPos.Next;
      end;

      if Assigned(frmStreamSaver) then
        frmStreamSaver.Done;

    finally
      NeedInsertList.Free;
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

procedure TgdcStreamSaver.ActivateSetting(var WasMetaDataInSetting: Boolean; var AnAnswer: Word);
var
  RelName, SettingName: String;
  Obj: TgdcBase;
  CDS: TDataSet;
  OrderElement: TStreamOrderElement;
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
          PChar('� �������� �������� ��������� ��������� ������:'#13#10 +
          E.Message + #13#10#13#10 +
          '���������� ��������?'),
          '������',
          MB_ICONEXCLAMATION or MB_YESNO or MB_TASKMODAL) = IDNO then
        begin
          raise;
        end;
      end;
    end;
    ConnectDatabase;
  end;

(*  procedure RunMultiConnection;
  var
    WasConnect: Boolean;
    R: TatRelation;
    ibsql: TIBSQL;
  begin
    Assert(atDatabase <> nil, '�� ��������� ���� ���������');
    if atDatabase.InMultiConnection then
    begin
     {��������, ������������� �� ��� ���������� ���������������.
       ���� � ������� at_transaction ������ ���, ������ ���� ���������������}
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
  end; *)

begin
  WasMetaData := False;
  SettingName := FDataObject.SettingHeaderDataset.FieldByName('NAME').AsString;

  if not SilentMode then
  begin
    AddText('������ �������� ��������� ' + SettingName, clBlack);
    if Assigned(frmSQLProcess) then
    begin
      frmSQLProcess.Caption := '�������� ���������: ' + SettingName;
      frmSQLProcess.pb.Min := 0;
      frmSQLProcess.pb.Max := FStreamLoadingOrderList.Count;
      frmSQLProcess.pb.Position := 0;
    end;

    if Assigned(frmStreamSaver) then
    begin
      frmStreamSaver.SetProcessText(SettingName, True);
      frmStreamSaver.SetupProgress(FStreamLoadingOrderList.Count, '�������� ���������...');
    end;
  end;

  // ����� ����� ������������ �� ������ � ������ �������� (���� ������ ���������)
  if AnAnswer <> mrNone then
    FStreamDataProvider.ReplaceRecordAnswer := AnAnswer;
  try
    // �������� ���������� ��������� (������� � �����)
    FStreamDataProvider.LoadSettingMetadata;

    // ��������� ������ ��������� �� ����
    while FStreamLoadingOrderList.PopNextElement(OrderElement) do
    begin
      Obj := FDataObject.gdcObject[OrderElement.DSIndex];

(*      if (Obj.InheritsFrom(TgdcMetaBase)) then
      begin
        WasMetaData := True;
        WasMetaDataInSetting := True;    // ��������� ��� ����������� ���������, ��� � ���� ���� ����������
      end
      else
      begin
        if WasMetaData then
        begin
          if not (SilentMode or IsReplicationMode) then
            ReconnectDatabase;
          WasMetaData := False;
        end;
      end;

      //��� LogOff �� ������� ReadTransaction. ��������� �� �����, �.�. ��� ������������ ��� �������� gdc-��������
      ConnectDatabase;
      RunMultiConnection; *)

      try
        //��� �������� ����� ���������� ������, ���� ����-������ �������, �� ��� �� ������ �����
        if Obj.SubSet <> 'ByID' then
          Obj.SubSet := 'ByID';
        if not Obj.Active then
          Obj.Open;
      except
        if not (SilentMode or IsReplicationMode) then
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
            // ������ ���������� ������ �� ������� ��������
            FStreamLoadingOrderList.Remove(OrderElement.RecordID);
            if not (SilentMode or IsReplicationMode) then
            begin
              if FTransaction.InTransaction then
                FTransaction.Rollback;
              AddMistake(E.Message, clRed);
              if Assigned(frmStreamSaver) then
                frmStreamSaver.AddMistake(E.Message);
              raise;
            end
            else
            begin
              FErrorMessageForSetting := FErrorMessageForSetting +
                IntToStr(GetLastError) + ': ' + E.Message + ' ' + Obj.ClassName + '_' + Obj.SubType + #13#10;
              if Obj.State in [dsEdit, dsInsert] then
                Obj.Cancel;
            end;
          end;
        end;
      end
      else
        raise Exception.Create('� ������ �� ������� ������:'#13#10 +
          Obj.Classname + ' ' + Obj.SubType + ' (' + IntToStr(OrderElement.RecordID) + ')');

      if not SilentMode then
      begin
        if Assigned(frmStreamSaver) then
          frmStreamSaver.Step;
        if Assigned(frmSQLProcess) then
          frmSQLProcess.pb.Position := frmSQLProcess.pb.Position + 1;
      end;
      //���� ������ - ����, �� �������� ��� �������, �����, ���� �����������,
      //����� ��������������� ���������������� ������� �����
      if (Obj is TgdcRelationField) then
        RelName := Obj.FieldByName('relationname').AsString
      else
        RelName := '';
    end;

    // ��������� ������-��������� �� ����
    try
      FStreamDataProvider.LoadSetRecords;
    except
      on E: EgdcNoTable do
      begin
        AddMistake(Format('�� ������� ������� %s ��� �����-����� ����� ���������.', [E.Message]), clRed);
        if Assigned(frmStreamSaver) then
          frmStreamSaver.AddMistake(Format('�� ������� ������� %s ��� �����-����� ����� ���������.', [E.Message]));
      end;
    end;

  (*  RunMultiConnection;  *)
    // ������ ��������� ������������� ����� �� ������ � ������ ��������
    AnAnswer := FStreamDataProvider.ReplaceRecordAnswer;

    if not SilentMode then
    begin
      AddText('��������� �������� ��������� ' + SettingName, clBlack);
      if Assigned(frmSQLProcess) then
        frmSQLProcess.Caption := '���������� SQL ������';
      if Assigned(frmStreamSaver) then
        frmStreamSaver.Done;
    end;
  except
    on E: Exception do
    begin
      if FTransaction.InTransaction then
        FTransaction.Rollback;
      if not SilentMode then
      begin
        AddMistake(E.Message, clRed);
        if Assigned(frmStreamSaver) then
          frmStreamSaver.AddMistake(E.Message);
      end
      else
        FErrorMessageForSetting := FErrorMessageForSetting + E.Message + #13#10;
      raise;
    end;
  end;
end;

procedure TgdcStreamSaver.AddObject(AgdcObject: TgdcBase; const AWithDetail: Boolean = True);
var
  C: TgdcFullClass;
  ObjectIndex: Integer;
  AID: TID;
  IndexNeedModifyList: Integer;
begin
  AID := AgdcObject.ID;

  if Assigned(NeedModifyList) and (NeedModifyList.IndexOf(AID) = -1) then
  begin
    IndexNeedModifyList := NeedModifyList.Add(AID, True);
    NeedModifyList.ValuesByIndex[IndexNeedModifyList] := Integer(AgdcObject.ModifyFromStream);
  end;

  C := AgdcObject.GetCurrRecordClass;
  ObjectIndex := FDataObject.GetObjectIndex(C.gdClass.Classname, C.SubType);
  try
    FStreamDataProvider.ClearNowSavedRecordsList;
    FStreamDataProvider.SaveRecord(ObjectIndex, AID, AWithDetail);
  except
    if FTransaction.InTransaction then
      FTransaction.Rollback;
    raise;
  end;
end;

procedure TgdcStreamSaver.AddSetting(AgdcSetting: TgdcSetting);
var
  ibsqlPos: TIBSQL;
  gdcSettingPos: TgdcSettingPos;
begin
  FSavingSetting := True;

  // �������� ������ ����� ���������
  FDataObject.CreateSettingMetadata;
  FDataObject.AddData(FDataObject.SettingHeaderDataset, AgdcSetting);

  // �������� ������� ���������
  ibsqlPos := TIBSQL.Create(nil);
  gdcSettingPos := TgdcSettingPos.Create(nil);
  try
    ibsqlPos.Transaction := FTransaction;
    gdcSettingPos.SubSet := ssByID;
    gdcSettingPos.Open;

    // ������� ������� ����������� ���������
    ibsqlPos.SQL.Text :=
      ' SELECT id FROM at_settingpos ' +
      ' WHERE settingkey = :settingkey ' +
      ' ORDER BY objectorder';
    ibsqlPos.ParamByName('settingkey').AsInteger := AgdcSetting.ID;
    ibsqlPos.ExecQuery;
    while not ibsqlPos.Eof do
    begin
      gdcSettingPos.ID := ibsqlPos.FieldByName('id').AsInteger;
      if gdcSettingPos.ID = ibsqlPos.FieldByName('id').AsInteger then
        FDataObject.AddData(FDataObject.SettingPosDataset, gdcSettingPos)
      else
        raise Exception.Create('�� ������� ������� ���������');

      ibsqlPos.Next;
    end;
  finally
    FreeAndNil(gdcSettingPos);
    FreeAndNil(ibsqlPos);
  end;

  // �������� ������� �� ������� ���������
  Self.SaveSettingData(AgdcSetting.ID);
end;

procedure TgdcStreamSaver.PrepareForIncrementSaving(const ABasekey: TID = -1);
var
  TargetBase: TgdRPLDatabase;
begin
  // ���� ��� �������� �������� ���� ���� ������
  if ABaseKey > -1 then
  begin
    //  ���� ���� ���� �� �������� ������ ����� ����
    if ABaseKey <> FDataObject.OurBaseKey then
    begin
      TargetBase := TgdRPLDatabase.Create;
      try
        TargetBase.ID := ABasekey;
        if TargetBase.ID > 0 then
          AddText(Format('���������� � ������������� ���������� �� ���� "%0:s"', [TargetBase.Name]), clBlack)
        else
          raise EgsUnknownDatabaseKey.Create(GetGsException(Self, '������� �������� ���� ������� ���� ������ (' + IntToStr(ABasekey) + ')'));
      finally
        TargetBase.Free;
      end;
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

procedure TgdcStreamSaver.SetReplicationMode(const Value: Boolean);
begin
  IsReplicationMode := Value;
  if Assigned(frmSQLProcess) and not Assigned(frmStreamSaver) then
    frmSQLProcess.Silent := Value;
end;

function TgdcStreamSaver.GetReplicationMode: Boolean;
begin
  Result := IsReplicationMode;
end;

procedure TgdcStreamSaver.SetReadUserFromStream(const Value: Boolean);
begin
  IsReadUserFromStream := Value;
end;

function TgdcStreamSaver.GetReadUserFromStream: Boolean;
begin
  Result := IsReadUserFromStream;
end;

{function TgdcStreamSaver.GetReplaceRecordBehaviour: TReplaceRecordBehaviour;
begin
  Result := FStreamDataProvider.ReplaceRecordBehaviour;
end;

procedure TgdcStreamSaver.SetReplaceRecordBehaviour(const Value: TReplaceRecordBehaviour);
begin
  FStreamDataProvider.ReplaceRecordBehaviour := Value;
end;}

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

procedure TgdcStreamSaver.SetStreamFormat(const Value: TgsStreamType);
begin
  if (Value >= Low(TgsStreamType)) and (Value <= High(TgsStreamType)) then
    FStreamFormat := Value
  else
    raise Exception.Create(Format('������� ����������� ��� ������ (%d)', [Integer(Value)]));
end;

function TgdcStreamSaver.GetReplaceRecordAnswer: Word;
begin
  Result := FStreamDataProvider.ReplaceRecordAnswer;
end;

procedure TgdcStreamSaver.SetReplaceRecordAnswer(const Value: Word);
begin
  FStreamDataProvider.ReplaceRecordAnswer := Value;
end;

procedure TgdcStreamSaver.LoadFromFile(AFileName: String);
var
  FS: TFileStream;
begin
  FFileName := AFileName;

  FS := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Self.LoadFromStream(FS);
  finally
    FreeAndNil(FS);
    FFileName := '';
  end;
end;

procedure TgdcStreamSaver.SaveToFile(AFileName: String);
var
  FS: TFileStream;
begin
  FFileName := AFileName;

  FS := TFileStream.Create(AFileName, fmCreate or fmShareExclusive);
  try
    Self.SaveToStream(FS);
  finally
    FreeAndNil(FS);
    FFileName := '';
  end;
end;

{ TgdRPLDatabase }

constructor TgdRPLDatabase.Create;
begin
  Self.SetDefaultValues;
end;

procedure TgdRPLDatabase.SetDefaultValues;
begin
  FID := -1;
  FName := '';
  FIsOurBase := false;
end;

procedure TgdRPLDatabase.SetID(const Value: TID);
var
  ibsql: TIBSQL;
begin
  // ���� ���������� ���� ���� ������ ������ ��, ����� ��������� �������� �� ���������
  if Value > -1 then
  begin
    ibsql := TIBSQL.Create(nil);
    try
      // ������ �� ������� RPL_DATABASE ��� ���� ������ � �������� �� ��� ������� �����
      ibsql.Transaction := gdcBaseManager.ReadTransaction;
      ibsql.SQL.Text := 'SELECT name, isourbase FROM rpl_database WHERE id = :basekey';
      ibsql.ParamByName('BASEKEY').AsInteger := Value;
      ibsql.ExecQuery;
      // ���� ����� ����� ����, �������� ��������, ����� ��������� �������� �� ���������
      if ibsql.RecordCount > 0 then
      begin
        FID := Value;
        FName := ibsql.FieldByName('NAME').AsString;
        FIsOurBase := (ibsql.FieldByName('ISOURBASE').AsInteger = 1);
      end
      else
        Self.SetDefaultValues;
    finally
      ibsql.Free;
    end;
  end
  else
    Self.SetDefaultValues;
end;

{ TLoadedRecordStateList }

constructor TLoadedRecordStateList.Create;
begin
  inherited Create;
  SetLength(FStateArray, Size);
end;

procedure TLoadedRecordStateList.Delete(const Index: Integer);
begin
  CheckIndex(Index);
  System.Move(FStateArray[Index + 1], FStateArray[Index],
    (Count - Index) * SizeOf(FStateArray[0]));
  // ��������� ����� ����� ��������� � ������������
  // �������
  inherited Delete(Index);
end;

destructor TLoadedRecordStateList.Destroy;
begin
  SetLength(FStateArray, 0);
  inherited;
end;

function TLoadedRecordStateList.GetStateByIndex(Index: Integer): TLoadedRecordState;
begin
  CheckIndex(Index);
  Result := FStateArray[Index];
end;

function TLoadedRecordStateList.GetStateByKey(Key: Integer): TLoadedRecordState;
var
  Index: Integer;
begin
  if Find(Key, Index) then
    Result := FStateArray[Index]
  else
    raise Exception.Create(Format('TLoadedRecordStateList.GetStateByKey: Invalid key value (%d)', [Key]));
end;

procedure TLoadedRecordStateList.Grow;
begin
  inherited;
  SetLength(FStateArray, Size);
end;

procedure TLoadedRecordStateList.InsertItem(const Index, Value: Integer);
begin
  inherited;
  // ����� ������ ������������� ������
  // ��������� ����� (������) ��� ���������
  // �� ������
  if Index < (Count - 1) then
    System.Move(FStateArray[Index], FStateArray[Index + 1],
      ((Count - 1) - Index) * SizeOf(FStateArray[0]));
  FStateArray[Index] := lsNotLoaded;
end;

procedure TLoadedRecordStateList.SetStateByIndex(Index: Integer;
  const Value: TLoadedRecordState);
begin
  CheckIndex(Index);
  FStateArray[Index] := Value;
end;

procedure TLoadedRecordStateList.SetStateByKey(Key: Integer;
  const Value: TLoadedRecordState);
var
  Index: Integer;
begin
  if Find(Key, Index) then
    FStateArray[Index] := Value
  else
    raise Exception.Create(Format('TLoadedRecordStateList.GetStateByKey: Invalid key value (%d)', [Key]));
end;

end.
