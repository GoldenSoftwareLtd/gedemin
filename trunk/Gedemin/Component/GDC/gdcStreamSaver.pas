unit gdcStreamSaver;

interface

uses
  gdcBase,              gdcBaseInterface,           classes,
  IBDatabase,           IBSQL,                      gdcLBRBTreeMetaData,
  contnrs,              dbgrids,                    comctrls,
  gd_KeyAssoc,          db,                         gsStorage,
  gsStreamHelper,       gdcSetting,                 dbclient,
  gdcTableMetaData;
type
  // ��������� ������ ����� ��������
  //   lsNotLoaded - ������ �� ��������� (��������� ������ ������)
  //   lsModified - ������ ��������� ������ ������
  //   lsCreated - ������ ������� (������ �� ����)
  TLoadedRecordState = (lsNotLoaded, lsModified, lsCreated);

  TReplaceRecordBehaviour = (rrbDefault, rrbAlways, rrbNever, rrbCompareDialog);
  // ��� �����������:
  //  slNone - �� �������� ������ � ���
  //  slSimple - �������� ������ �������� ��������� (������/����� �������� � �.�.)
  //  slAll - �������� ��� ���������
  TgsStreamLoggingType = (slNone, slSimple, slAll);
  // ��������� (<TAG> ��� <TAG />) ��� �������� (</TAG>) ��� ��������
  TgsXMLElementPosition = (epOpening, epClosing);
  // ���
  TgsMultiLineXMLTagValueType = (tgtText, tgtBlob, tgtXML);

  TXMLElementType =
    (etUnknown,                // ����������� �������
     etStream,                 // ���� ����� (��� ����������� ������ � XML ���������)
     etHeader,                 // ��������� ������
     etVersion,                // ������ ������
     etDBID,                   // DBID ����-���������
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
     etDatasetRow              // ������ ��������
    );

  TgsXMLElement = record
    Tag: TXMLElementType;
    Position: TgsXMLElementPosition;
    ElementString: String;
  end;
    
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
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;

    // ���� false, �� ��� ���������� ������ ������� �� ����� �����������
    //   ������ ������ � ������ � ������� ���� ������� �������� �������
    FIsSave: Boolean;
    // ������������ �� �����
    FIsIncrementedStream: Boolean;

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

    FIncrDatabaseList: TStringList;

    // ������ �������� ���������� � �����, ����� �������� ������� ������-������� � ��������
    //  ������ ������, ��������� ������ � �.�.
    FObjectArray: array of TStreamObjectRecord;
    FCount: Integer;
    FSize: Integer;

    FStreamDBID: TID;
    FStreamVersion: Integer;

    FOurBaseKey: TID;
    FTargetBaseKey: TID;
    FSourceBaseKey: TID;

    FStorageItemList: TStringList;

    function CheckIndex(const Index: Integer): Boolean;

    function CreateBusinessObject(const AClassName: TgdcClassName; const ASubType: TgdcSubType = '';
      const ASetTableName: ShortString = ''): TgdcBase;
    function CreateDataset(ABusinessObject: TgdcBase): TDataSet;
    procedure FillReferences(var ADataObject: TStreamObjectRecord);

    function GetgdcObject(Index: Integer): TgdcBase;
    function GetClientDS(Index: Integer): TDataSet;
    function GetObjectDetailReferences(Index: Integer): TObjectList;
    function GetObjectCrossTables(Index: Integer): TStringList;
    function GetReceivedRecord(Index: Integer): TRuid;
    function GetReferencedRecord(Index: Integer): TStreamReferencedRecord;
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
    procedure AddData(const Index: Integer; AObj: TgdcBase); overload;
    procedure AddData(const Index: Integer; const AID: TID); overload;
    function Find(const AClassName: TgdcClassName; const ASubType: TgdcSubType = ''; const ASetTableName: ShortString = ''): Integer;
    function GetObjectIndex(const AClassName: TgdcClassName; const ASubType: TgdcSubType = ''; const ASetTableName: ShortString = ''): Integer;

    procedure AddReceivedRecord(const AXID, ADBID: TID);
    procedure AddReferencedRecord(const AID, AXID, ADBID: TID);
    function FindReferencedRecord(const AID: TID): Integer;

    function GetSetObject(const AClassName: TgdcClassName; const ASubType: TgdcSubType; const ASetTableName: ShortString): TgdcBase;

    // ������� ������ � ����������� ��������
    procedure Clear;

    property ReceivedRecordsCount: Integer read FReceivedRecordsCount;
    property ReceivedRecord[Index: Integer]: TRuid read GetReceivedRecord;

    property ReferencedRecordsCount: Integer read FReferencedRecordsCount;
    property ReferencedRecord[Index: Integer]: TStreamReferencedRecord read GetReferencedRecord;

    property Count: Integer read FCount;
    property gdcObject[Index: Integer]: TgdcBase read GetgdcObject;
    property ClientDS[Index: Integer]: TDataSet read GetClientDS;

    property ObjectForeignKeyFields[Index: Integer]: TStringList read GetObjectForeignKeyFields;
    property ObjectForeignKeyClasses[Index: Integer]: TStringList read GetObjectForeignKeyClasses;
    property OneToOneTables[Index: Integer]: TStringList read GetOneToOneTables;
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

    //FReplaceRecordBehaviour: TReplaceRecordBehaviour;
    FReplaceFieldList: TStringList;

    FIDMapping: TgdKeyIntAssoc; // ����� ���������������
    FUpdateList: TObjectList;   // ������ � ������� ����� ������, ��������� ���������� foreignkeys ����� ������� ��������� ������

    FReplaceRecordAnswer: Word;

    FSaveWithDetailList: TgdKeyArray;
    FNeedModifyList: TgdKeyIntAssoc;
    FLBRBTree: TLBRBTreeMetaNames;
    FBaseBITriggerName: String;
    FBaseTableTriggersName: TBaseTableTriggersName;

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

    procedure AddRecordToRPLRECORDS(const AID: TID; AModified: TDateTime);
    procedure SetTransaction(const Value: TIBTransaction);

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

    // ���������� ������ ��� ������ �� ������ � �� ������� RPL_DATABASE,
    //  ���� � ������ ��������� ����� ����, ��������� �� � �������
    procedure ProcessDatabaseList;

    //���� � ������� RPL_RECORD ������ ������������ � ������� �������
    //  �� ������� ����, �� �� ���������� ������ �������. ���������� ��������� �� ������.
    procedure CheckNonConfirmedRecords;
    //���� ������ ��������� � ������� ���� � ��������� ������������� � ��������.
    //  ��������� ���������� ������ � TgdcStreamDataObject.
    procedure GetRecordsWithInState;

    procedure SaveStorageItem(const ABranchName, AValueName: String);

    procedure LoadStorage;

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
  public
    constructor Create(AObjectSet: TgdcStreamDataObject = nil; ALoadingOrderList: TgdcStreamLoadingOrderList = nil);
    destructor Destroy; override;

    procedure SaveToStream(S: TStream); virtual;
    procedure LoadFromStream(const S: TStream); virtual;

    procedure SaveStorageToStream(S: TStream); virtual;
    procedure LoadStorageFromStream(const S: TStream; var AnStAnswer: Word); virtual;

    property Stream: TStream read FStream write SetStream;
    property DataObject: TgdcStreamDataObject read FDataObject write SetDataObject;
    property LoadingOrderList: TgdcStreamLoadingOrderList read FLoadingOrderList write SetLoadingOrderList;
  end;

  TgdcStreamBinaryWriterReader = class(TgdcStreamWriterReader)
  public
    procedure SaveToStream(S: TStream); override;
    procedure LoadFromStream(const S: TStream); override;

    procedure SaveStorageToStream(S: TStream); override;
    procedure LoadStorageFromStream(const S: TStream; var AnStAnswer: Word); override;
  end;

  TgdcStreamXMLWriterReader = class(TgdcStreamWriterReader)
  private
    // ��������� �������� ��������
    FAttributeList: TStringList;
    // � XML ������ ��������� ���� ���������� $, ����� ����� ������� ������������
    //  ����� ��������� ���������� � $ � ��������� � _
    FFieldCorrList: TStringList;
    // ������ �� ������ ����� ������
    FElementLevel: Integer;
    FDoInsertXMLHeader: Boolean;
    // ������ �������� �� TgdcDataObject, ������� �������� ��/������� � XML � ������ ������
    FCurrentDatasetKey: Integer;
    // ���������� ����������� XML-��� (<TAG ...>)
    //   ATag - ��� ����
    //   ASingleLine - ������� ������������� � ���� ������
    function AddOpenTag(const ATag: String; const ASingleLine: Boolean = false): String;
    // ���������� ����������� XML-��� (</TAG>)
    //   ATag - ��� ����
    function AddCloseTag(const ATag: String): String;
    // ���������� ������� XML-������� � ��������� ���������� (<TAG>...</TAG>)
    //  ATag - ��� ����
    //  AValue - ���������� ��������
    function AddElement(const ATag, AValue: String): String;
    // ���������� �������� (<TAG ... />) XML-�������
    //   ATag - ��� ����
    //   ASingleLine - ������� ������������� � ���� ������
    function AddShortElement(const ATag: String; const ASingleLine: Boolean = false): String;
    // ��������� XML-������� � ������ ���������� �������� ��������
    procedure AddAttribute(const AAttributeName, AValue: String);

    function InternalGetNextElement: String;

    function GetXMLElementPosition(const AElementStr: String): TgsXMLElementPosition;
    function GetNextElement: TgsXMLElement;
    function GetTextValueOfElement(const ElementHeader: String): String;
    function GetParamValueByName(const Str, ParamName: String): String;
    function GetIntegerParamValueByName(const Str, ParamName: String): Integer;
    // �������� �������   ' " & < >   ��   &apos; &quot; &amp; &lt; &gt;   ��������������
    function QuoteString(Str: String): String;
    // �������� �������   &apos; &quot; &amp; &lt; &gt;   ��   ' " & < >   ��������������
    function UnQuoteString(Str: String): String;
    function GetPositionOfString(const Str: String): Integer;

    // � XML ���� ������ � ���� ��������� ����������� �� ���������
    //  ������� ������� ������ ������ ��� ����������
    procedure InternalSaveSettingToStream;
    procedure InternalSaveToStream;

    // ��������� BLOB-�������� ���������
    procedure SaveStorageValue(AField: TField);
    // ��������� ���������� � ������ ��������
    procedure SaveDataset(CDS: TDataSet);
    // ��������� �������� ���� �������� � ���� ���������� ����
    procedure SaveDatasetFieldValue(AField: TField);
    // ��������� �������������� �������� ��� ������������������ ����� <L>
    procedure SaveMemoTagValue(const AMemoValue: String; AMLType: TgsMultiLineXMLTagValueType = tgtText);

    // ��������� ������ � ���� �������� �� �����
    procedure ParseFieldDefinition(const ElementStr: String);
    // ��������� ��������� ������ �������� �� �����
    procedure ParseDatasetRecord;
    // ��������� ���������� �������� ������
    procedure ParseDatasetFieldValue(AField: TField; const AFieldValue: String);
    // ��������� ���������� �������� ������
    function ParseStorageValue(const AFieldValue: String): String;
    // ��������� ��������������� �������� ���� �������� (<L>..</L>)
    function ParseMemoTagValue(const ATagValue: String; AMLType: TgsMultiLineXMLTagValueType = tgtText): String;

    procedure ParseSettingHeader(const ElementStr: String; const ARecordKey: Integer);
    procedure ParseSettingPosition(const ElementStr: String; const ARecordKey, AHeaderKey: Integer);
  protected
    class procedure StreamWriteXMLString(St: TStream; const S: String; const DoConvertToUTF8: Boolean = True);
    class function ConvertUTFToAnsi(AUTFStr: AnsiString): String;
  public
    constructor Create(AObjectSet: TgdcStreamDataObject = nil; ALoadingOrderList: TgdcStreamLoadingOrderList = nil);
    destructor Destroy; override;

    procedure SaveToStream(S: TStream); override;
    procedure LoadFromStream(const S: TStream); override;

    function GetXMLSettingHeader(S: TStream; SettingHeader: TSettingHeader): Boolean;

    property ElementLevel: Integer read FElementLevel write FElementLevel;
    property DoInsertXMLHeader: Boolean read FDoInsertXMLHeader write FDoInsertXMLHeader;
  end;

  TgdcStreamSaver = class(TObject)
  private
    FStreamFormat: TgsStreamType;

    FStreamDataProvider: TgdcStreamDataProvider;
    FStreamLoadingOrderList: TgdcStreamLoadingOrderList;
    FDataObject: TgdcStreamDataObject;

    FTransaction: TIBTransaction;
    FTrWasCreated: Boolean;
    FTrWasActive: Boolean;

    FSavingSettingData: Boolean;

    // ������������ ��� ������������ ������ ��� ����������
    FErrorMessageForSetting: WideString;

    procedure SetTransaction(const Value: TIBTransaction);
    procedure SetSilent(const Value: Boolean);
    function GetSilent: Boolean;
    procedure SetReplicationMode(const Value: Boolean);
    function GetReplicationMode: Boolean;
    procedure SetReadUserFromStream(const Value: Boolean);
    function GetReadUserFromStream: Boolean;
    {function GetReplaceRecordBehaviour: TReplaceRecordBehaviour;
    procedure SetReplaceRecordBehaviour(const Value: TReplaceRecordBehaviour);}
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
  public
    constructor Create(ADatabase: TIBDatabase = nil; ATransaction: TIBTransaction = nil);
    destructor Destroy; override;

    // �������������� ������ ��� ������������� ����������, ��������� ���� TargetBaseKey
    //   ���������� ������ �� RPL_RECORD �� �������� irsIn(0)
    procedure PrepareForIncrementSaving(const ABasekey: TID = -1);

    // ��������� ������ ����������� ������� � �������� �� ������� �� ���� � ������
    procedure AddObject(AgdcObject: TgdcBase; const AWithDetail: Boolean = true);
    // ��������� ������ � ���������� �������� �� ������ � �����
    procedure SaveToStream(S: TStream);
    // ��������� ������ �� ������ �� ����
    procedure LoadFromStream(S: TStream);
    // �������� ���������� � ���� ����������� ��������
    procedure Clear;

    // ������������ ��� ��������� ���������, ��������� ������ �� ������ �� ����
    procedure LoadSettingDataFromStream(S: TStream; var WasMetaDataInSetting: Boolean; const DontHideForms: Boolean; var AnAnswer: Word);
    // ������������ ��� ���������� ������ ��������� � ����
    procedure SaveSettingDataToStream(S: TStream; ASettingKey: TID);
    // ������������ ��� ���������� ��������� ��������� � ����
    procedure LoadSettingStorageFromStream(S: TStream; var AnStAnswer: Word);
    // ������������ ��� ���������� ��������� ��������� � ����
    procedure SaveSettingStorageToStream(S: TStream; ASettingKey: TID);
    // ��������� ���������� ������ ������� �������� � ��������� �������� (�� ������ ������� ���������)
    procedure FillRUIDListFromStream(S: TStream; RuidList: TStrings; const SettingID: Integer = -1);

    property Silent: Boolean read GetSilent write SetSilent;
    property ReplicationMode: Boolean read GetReplicationMode write SetReplicationMode;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
    property ReadUserFromStream: Boolean read GetReadUserFromStream write SetReadUserFromStream;
    property IsAbortingProcess: Boolean read GetIsAbortingProcess write SetIsAbortingProcess;
    //property ReplaceRecordBehaviour: TReplaceRecordBehaviour read GetReplaceRecordBehaviour write SetReplaceRecordBehaviour;
    property ReplaceRecordAnswer: Word read GetReplaceRecordAnswer write SetReplaceRecordAnswer;
    property StreamLogType: TgsStreamLoggingType read GetStreamLogType write SetStreamLogType;
    property StreamFormat: TgsStreamType read FStreamFormat write SetStreamFormat;

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
  XML_TAG_LOADING_ORDER = 'LOADING_ORDER';
  XML_TAG_LOADING_ORDER_ITEM = 'ITEM';
  XML_TAG_DATA = 'DATA';
  XML_TAG_DATASET = 'DATASET';

  XML_TAG_SETTING = 'SETTING';
  XML_TAG_SETTING_HEADER = 'SETTING_HEADER';
  XML_TAG_SETTING_POS_LIST = 'SETTING_POS_LIST';
  XML_TAG_SETTING_POS = 'SETTING_POS';
  XML_TAG_SETTING_DATA = 'SETTING_DATA';
  XML_TAG_SETTING_STORAGE = 'SETTING_STORAGE';

  XML_TAG_DATASET_METADATA = 'METADATA';
  XML_TAG_DATASET_FIELD = 'FIELD';
  XML_TAG_DATASET_ROWDATA = 'ROWDATA';
  XML_TAG_DATASET_ROW = 'ROW';

  XML_CDATA_BEGIN = '<![CDATA[';
  XML_CDATA_END = ']]>';

  XML_TAG_MULTILINE_SPLITTER = 'L';

  DETAIL_DOMAIN_SIMPLE = 'DMASTERKEY';
  DETAIL_DOMAIN_TREE = 'DPARENT';

  cst_StreamVersionNew = 3;
  WIN1251_CODEPAGE = 1251;

  function GetStreamType(Stream: TStream): TgsStreamType;

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
  gdcReport;              //  gdcLBRBTreeMetaData;

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

  xmlHeader = '<?xml version="1.0" encoding="utf-8"?>';

  INDENT_STR = ' ';
  NEW_LINE = #13#10;
  RIGHTS_FIELD = ',ACHAG,AVIEW,AFULL,';

  XID_FIELD = '_XID';
  DBID_FIELD = '_DBID';
  MODIFIED_FIELD = '_MODIFIED';
  MODIFY_FROM_STREAM_FIELD = '_MODIFYFROMSTREAM';
  INSERT_FROM_STREAM_FIELD = '_INSERTFROMSTREAM';
  SET_TABLE_FIELD = '_SETTABLE';

  DEFAULT_ARRAY_SIZE = 32;

var
  RplDatabaseExists: Boolean;
  IsReadUserFromStream: Boolean;
  SilentMode: Boolean;
  IsReplicationMode: Boolean;
  AbortProcess: Boolean;
  StreamLoggingType: TgsStreamLoggingType;

function IIF(Condition: Boolean; Str1, Str2: String): String;
begin
  if Condition then
    Result := Str1
  else
    Result := Str2;
end;

function IsXML(const CheckStr: String): Boolean;
begin
  if (AnsiPos(XML_TAG_STREAM, CheckStr) > 0)
     or (AnsiPos(XML_TAG_SETTING, CheckStr) > 0)
     or (AnsiPos(xmlHeader, CheckStr) > 0)
     or (AnsiPos('<?XML', UpperCase(Trim(CheckStr))) = 1) then
    Result := True
  else
    Result := False;
end;

function GetStreamType(Stream: TStream): TgsStreamType;
const
  STREAM_TEST_STRING_SIZE = 100;
var
  I, Position: Integer;
  StreamTestString: String;
  StreamTestStringSize: Integer;
begin
  Result := sttUnknown;
  if Stream.Size > 0 then
  begin
    // �� �� ����� ��������� �� ������ ������ ��������, ��� � ��� ���������
    if Stream.Size >= STREAM_TEST_STRING_SIZE then
      StreamTestStringSize := STREAM_TEST_STRING_SIZE
    else
      StreamTestStringSize := Stream.Size;
    // �������� ������� � ������, ����� ����� �������� � ���
    Position := Stream.Position;
    try
      Stream.Position := 0;
      Stream.ReadBuffer(I, SizeOf(I));
      // � ����� ������
      if I > 1024 then
      begin
        Stream.Position := 0;
        SetLength(StreamTestString, StreamTestStringSize);
        Stream.ReadBuffer(StreamTestString[1], StreamTestStringSize);
        if IsXML(StreamTestString) then
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
  FStorageItemList.Free;

  FDatabase := nil;
  FTransaction := nil;

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
  I: Integer;
  RUID: TRUID;
  F: TField;
  CDS: TDataSet;
  LocName, NotSavedField: String;
  R: TatRelation;
  TableInfo: TgdcTableInfos;
begin
  if CheckIndex(Index) then
  begin
    CDS := FObjectArray[Index].CDS;
    NotSavedField := ',' + AObj.GetNotStreamSavedField(IsReplicationMode) + ',';

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

    RUID := AObj.GetRUID;

    CDS.Append;
    for I := 0 to AObj.FieldCount - 1 do
    begin
      // ��� ���������-�������� ����� ��������� ������ ����-��������� (S$...)
      if (AObj.SetTable = '') or IsSetField(AObj.Fields[I].FieldName) then
      begin
        F := CDS.FindField(AObj.Fields[I].FieldName);
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
      CDS.FieldByName(XID_FIELD).AsInteger := RUID.XID;
      CDS.FieldByName(DBID_FIELD).AsInteger := RUID.DBID;

      TableInfo := AObj.GetTableInfos(AObj.SubType);
      // ����� ��������� ���� MODIFIED_FIELD ������ ���� ���� ����������� ���������� � ��
      if (tiCreationInfo in TableInfo) or (tiEditionInfo in TableInfo) then
        CDS.FieldByName(MODIFIED_FIELD).AsDateTime := AObj.EditionDate;
    end
    else
      CDS.FieldByName(SET_TABLE_FIELD).AsString := AObj.SetTable;
    CDS.FieldByName(INSERT_FROM_STREAM_FIELD).AsBoolean := AObj.ModifyFromStream;
    CDS.FieldByName(MODIFY_FROM_STREAM_FIELD).AsBoolean := AObj.ModifyFromStream;
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
    Obj := FObjectArray[Index].gdcObject;

    if Obj.ID <> AID then
      Obj.ID := AID;
    {if not Obj.Active then
      Obj.Open;}
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
  TableInfo: TgdcTableInfos;
begin
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
      and ((ABusinessObject.SetTable = '') or IsSetField(FD.Name)) then
    begin
      Dataset.FieldDefs.Add(FD.Name, FD.DataType, FD.Size, False);
    end;
  end;
  // ��� �����-������ ��� �� ����� ���� ����� � ���� �����������
  if ABusinessObject.SetTable = '' then
  begin
    Dataset.FieldDefs.Add(XID_FIELD, ftInteger, 0, True);
    Dataset.FieldDefs.Add(DBID_FIELD, ftInteger, 0, True);
    TableInfo := ABusinessObject.GetTableInfos(ABusinessObject.SubType);
    // ����� ��������� ���� MODIFIED_FIELD ������ ���� ���� ����������� ���������� � ��
    if (tiCreationInfo in TableInfo) or (tiEditionInfo in TableInfo) then
      Dataset.FieldDefs.Add(MODIFIED_FIELD, ftDateTime, 0, True);
  end;
  Dataset.FieldDefs.Add(INSERT_FROM_STREAM_FIELD, ftBoolean, 0, False);
  Dataset.FieldDefs.Add(MODIFY_FROM_STREAM_FIELD, ftBoolean, 0, False);
  Dataset.FieldDefs.Add(SET_TABLE_FIELD, ftString, 60, False);

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
  FStorageItemList.Clear;

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
  if not SilentMode and Application.Active and (AbortProcess or ((GetAsyncKeyState(VK_ESCAPE) shr 1) <> 0)) then
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

  // ��� ������������ ����������� �� ����� ��������� ����������� ������ (ID < cstUserIDStart)
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
    if SourceKeyInt < cstUserIDStart then
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
        FLoadingOrderList.Remove(SourceKeyInt);
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
begin
  //��������� ������ � ��� ������
  TargetDS.Insert;
  //���� ������� ����� �� ������ ������ ���������
  if CopyRecord(SourceDS, TargetDS) then
  begin
    TargetDS.CheckBrowseMode;
    // ���� � �������� ��� ���� ������� ��������� �������, �� ������� ������� �����
    if Assigned(SourceDS.FindField(MODIFIED_FIELD)) then
      Modified := SourceDS.FieldByName(MODIFIED_FIELD).AsDateTime
    else
      Modified := Now;

    //��������� �������� �� ���� � ����
    if gdcBaseManager.GetRUIDRecByID(TargetDS.ID, FTransaction).XID = -1 then
    begin
      //���� ���, �� ��������� � ����
      gdcBaseManager.InsertRUID(TargetDS.ID, SourceDS.FieldByName(XID_FIELD).AsInteger,
        SourceDS.FieldByName(DBID_FIELD).AsInteger,
        Modified, IBLogin.ContactKey, FTransaction);
    end
    else
    begin
      //���� ��, �� ��������� ���� ����� �� ��� ID
      gdcBaseManager.UpdateRUIDByID(TargetDS.ID, SourceDS.FieldByName(XID_FIELD).AsInteger,
        SourceDS.FieldByName(DBID_FIELD).AsInteger,
        Modified, IBLogin.ContactKey, FTransaction);
    end;
    FLoadingOrderList.Remove(SourceDS.FieldByName(TargetDS.GetKeyField(TargetDS.SubType)).AsInteger);
    SourceDS.Delete;
  end;
end;

procedure TgdcStreamDataProvider.LoadRecord(AObj: TgdcBase; CDS: TDataSet);
var
  RuidRec: TRuidRec;
  CurrentRecordID, StreamXID, StreamDBID, StreamID: TID;
  Modified, StreamModified: TDateTime;
  IsRecordLoaded: Boolean;
begin
  Assert(IBLogin <> nil);

  // ��� ������� Escape ������� �������
  if not SilentMode and Application.Active and (AbortProcess or ((GetAsyncKeyState(VK_ESCAPE) shr 1) <> 0)) then
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

  StreamID := CDS.FieldByName(AObj.GetKeyField(AObj.SubType)).AsInteger;
  StreamXID := CDS.FieldByName(XID_FIELD).AsInteger;
  StreamDBID := CDS.FieldByName(DBID_FIELD).AsInteger;
  // ���� � �������� ��� ���� ������� ��������� �������, �� ������� ������� �����
  if Assigned(CDS.FindField(MODIFIED_FIELD)) then
    StreamModified := CDS.FieldByName(MODIFIED_FIELD).AsDateTime
  else
    StreamModified := Now;
  Modified := StreamModified;
  // ������������ � GetRUID
  AObj.StreamXID := StreamXID;
  AObj.StreamDBID := StreamDBID;

  if AObj.SetTable <> '' then
    AObj.SetTable := '';

  //��������� �� ������������ ���� ��� �����������
  if not Assigned(CDS.FindField(AObj.GetListField(AObj.SubType))) then
  begin
    AddText(Format('������ %s (XID = %d, DBID = %d)',
      [AObj.GetDisplayName(AObj.SubType), StreamXID, StreamDBID]), clBlue);

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
         StreamXID, StreamDBID]));

    if StreamLoggingType = slAll then
      AddText(Format('������ %s "%s" (XID = %d, DBID = %d)',
        [AObj.GetDisplayName(AObj.SubType), CDS.FieldByName(AObj.GetListField(AObj.SubType)).AsString,
         StreamXID, StreamDBID]), clBlue);
  end;

  //��������, ���� �� � ��� ����� ����
  RuidRec := gdcBaseManager.GetRUIDRecByXID(StreamXID, StreamDBID, FTransaction);
  //������� ID, ��������� �� �����
  CurrentRecordID := RuidRec.ID;

  //���� �� �� ����� ����, �� ��� xid - "�����������"
  if (CurrentRecordID = -1) and (StreamXID < cstUserIDStart) then
  begin
    //��������� �������� ���� ������
    AObj.ID := StreamXID;
    //���� �����, �� �������� ����
    if not AObj.IsEmpty then
    begin
      gdcBaseManager.InsertRUID(StreamXID, StreamXID, StreamDBID, Date, IBLogin.ContactKey, FTransaction);
      //�������� ��� XID = id
      CurrentRecordID := StreamXID;
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
      gdcBaseManager.DeleteRUIDbyXID(StreamXID, StreamDBID, FTransaction);
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
        if Assigned(CDS.FindField(MODIFY_FROM_STREAM_FIELD)) and CDS.FieldByName(MODIFY_FROM_STREAM_FIELD).AsBoolean then
        begin
          if AObj.ID <> CurrentRecordID then
            AObj.ID := CurrentRecordID;

          // ���� ����� ������������, �� ��������� �� ������� RPL_RECORD ������������� �������� ������
          if (not FDataObject.IsIncrementedStream) or CheckNeedLoadingRecord(StreamXID, StreamDBID, StreamModified) then
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
                if (Modified < StreamModified) then
                begin
                  AObj.CheckBrowseMode;
                  gdcBaseManager.UpdateRUIDByXID(AObj.ID, StreamXID, StreamDBID,
                    StreamModified, IBLogin.ContactKey, FTransaction);
                  Modified := StreamModified;
                end;
                // ������� ������ � �������� ������ � ������� RPL_RECORDS, ��� ������������� ������
                if FDataObject.IsIncrementedStream then
                  AddRecordToRPLRECORDS(AObj.ID, Modified);
                // ������ ���� ������� �� ������� ��������
                FLoadingOrderList.Remove(StreamID);
                IsRecordLoaded := True;
              end;
            end
            else
            begin
              //�������� ������������ ������ ID � ID �� ������ � ����� ���������������
              AddToIDMapping(StreamID, AObj.ID, lsNotLoaded);
              // ������ ���� ������� �� ������� ��������
              FLoadingOrderList.Remove(StreamID);
              IsRecordLoaded := True;
              ApplyDelayedUpdates(StreamID, AObj.ID);
            end;
          end
          else
          begin
            if StreamLoggingType = slAll then
              AddText('������ ������ � RPL_RECORD', clBlack);

            //�������� ������������ ������ ID � ID �� ������ � ����� ���������������
            AddToIDMapping(StreamID, AObj.ID, lsNotLoaded);
            // ������ ���� ������� �� ������� ��������
            FLoadingOrderList.Remove(StreamID);
            IsRecordLoaded := True;
            ApplyDelayedUpdates(StreamID, AObj.ID);
          end;
        end
        else
        begin
          //�������� ������������ ������ ID � ID �� ������ � ����� ���������������
          AddToIDMapping(StreamID, AObj.ID, lsNotLoaded);
          // ������ ���� ������� �� ������� ��������
          FLoadingOrderList.Remove(StreamID);
          IsRecordLoaded := True;
          ApplyDelayedUpdates(StreamID, AObj.ID);
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
    if Assigned(CDS.FindField(SET_TABLE_FIELD)) then
    begin
      CurrentSetTableName := CDS.FieldByName(SET_TABLE_FIELD).AsString;
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
            if CDS.FieldByName(MODIFY_FROM_STREAM_FIELD).AsBoolean then
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
  if Assigned(atDatabase.Relations.ByRelationName(SourceDS.FieldByName(SET_TABLE_FIELD).AsString)) then
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
        F := atDataBase.FindRelationField(SourceDS.FieldByName(SET_TABLE_FIELD).AsString,
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
      R2 := atDataBase.Relations.ByRelationName(SourceDS.FieldByName(SET_TABLE_FIELD).AsString);
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
              F := atDataBase.FindRelationField(SourceDS.FieldByName(SET_TABLE_FIELD).AsString,
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
            FIBSQL.SQL.Text := Format(sql_SetSelect, [SourceDS.FieldByName(SET_TABLE_FIELD).AsString, S]);
            FIBSQL.ExecQuery;

            if FIBSQL.RecordCount > 0 then
            begin
            { TODO -oJulia : ��� ������ � ��� ������������� �������? ���������?
              � �����-�� ������ ��� ����� ����� �����, ��������, ������� gd_lastnumber }
            // FIBSQL.Close;
            //  FIBSQL.SQL.Text := Format(sql_SetUpdate,
            //    [SourceDS.FieldByName(SET_TABLE_FIELD).AsString, SUpdate, S]);
            end
            else
            begin
              FIBSQL.Close;
              FIBSQL.SQL.Text := Format(sql_SetInsert,
                [SourceDS.FieldByName(SET_TABLE_FIELD).AsString, SFld, SValues]);

              R := atDataBase.Relations.ByRelationName(SourceDS.FieldByName(SET_TABLE_FIELD).AsString);
              if Assigned(R) then
                LocName := R.LName
              else
                LocName := SourceDS.FieldByName(SET_TABLE_FIELD).AsString;

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
        AddWarning('������ ��������� ' + SourceDS.FieldByName(SET_TABLE_FIELD).AsString + ' �� ���� ���������!', clRed);
        if Assigned(frmStreamSaver) then
          frmStreamSaver.AddWarning;
      end;
    end;
  end
  else
    raise EgdcNoTable.Create(SourceDS.FieldByName(SET_TABLE_FIELD).AsString);
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
        if (AnsiCompareText(AObj.FieldByName('indexname').AsString, FLBRBTree.LBIndexName) = 0)
          or (AnsiCompareText(AObj.FieldByName('indexname').AsString, FLBRBTree.RBIndexName) = 0) then
        begin
          exit;
        end;

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
      exit;
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
      begin
        if (AnsicompareText(AObj.FieldByName('triggername').AsString, FLBRBTree.BITriggerName) = 0)
          or (AnsicompareText(AObj.FieldByName('triggername').AsString, FLBRBTree.BUTriggerName) = 0)
          or (AnsicompareText(AObj.FieldByName('triggername').AsString, FLBRBTree.BI5TriggerName) = 0)
          or (AnsicompareText(AObj.FieldByName('triggername').AsString, FLBRBTree.BU5TriggerName) = 0)
          or (AnsicompareText(AObj.FieldByName('triggername').AsString, FBaseBITriggerName) = 0)
          or (AnsicompareText(AObj.FieldByName('triggername').AsString, FBaseTableTriggersName.BITriggerName) = 0)
          or (AnsicompareText(AObj.FieldByName('triggername').AsString, FBaseTableTriggersName.BI5TriggerName) = 0)
          or (AnsicompareText(AObj.FieldByName('triggername').AsString, FBaseTableTriggersName.BU5TriggerName) = 0) then
          exit;
        Result := True;
      end;
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

  if AObj is TgdcLBRBTreeTable then
    GetLBRBTreeDependentNames(AObj.FieldByName('RELATIONNAME').AsString, FTransaction, FLBRBTree);

  if (AObj is TgdcPrimeTable) or (AObj is TgdcTableToTable) then
    FBaseBITriggerName := GetBaseTableBITriggerName(AObj.FieldByName('RELATIONNAME').AsString, FTransaction);

  if (AObj is TgdcSimpleTable) or (AObj is TgdcTreeTable) then
    GetBaseTableTriggersName(AObj.FieldByName('RELATIONNAME').AsString, FTransaction, FBaseTableTriggersName); 

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
      NeedModifyFromStream := Assigned(AStreamRecord.FindField(MODIFY_FROM_STREAM_FIELD)) and
        AStreamRecord.FieldByName(MODIFY_FROM_STREAM_FIELD).AsBoolean;

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
            (AnsiPos(';' + AnsiUpperCase(Trim(AStreamRecord.Fields[I].FieldName)) + ';', PassFieldName) = 0) then
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

procedure TgdcStreamDataProvider.SaveStorageItem(const ABranchName, AValueName: String);
var
  Path, StorageName: String;
  StorageFolder: TgsStorageFolder;
  StorageValue: TgsStorageValue;
  Storage: TgsStorage;

  procedure SaveValue(AValue: TgsStorageValue);
  begin
    if Assigned(AValue) then
    begin
      if StreamLoggingType = slAll then
        AddText(Format('���������� ��������� %s ����� ��������� %s', [AValueName, ABranchName]), clBlue);
      FDataObject.StorageItemList.AddObject(ABranchName + '\' + AValueName, AValue);
    end
    else
      raise EgsStorageError.Create('�������� ' + AValueName +
        ' ����� ��������� ' + ABranchName + ' �� ������!'#13#10 +
        '��������� ����������� ��������� ���������!');
  end;

  procedure SaveFolder(AFolder: TgsStorageFolder);
  var
    I: Integer;
  begin
    if Assigned(AFolder) then
    begin
      if StreamLoggingType = slAll then
        AddText('���������� ����� ��������� ' + ABranchName, clBlue);

      FDataObject.StorageItemList.AddObject(ABranchName + '\', AFolder);

      // ��������� ��������
      for I := 0 to AFolder.FoldersCount - 1 do
        SaveFolder(AFolder.Folders[I]);

      // ��������� ��������� �����
      for I := 0 to AFolder.ValuesCount - 1 do
        SaveValue(AFolder.Values[I]);

    end
    else
      raise EgsStorageError.Create(
        '����� ��������� "' + ABranchName + '" �� �������!'#13#10#13#10 +
        '� ��������� ����� ��������� ������ ����� ��� ���������'#13#10 +
        '����������� ��������� ��� ��������� ������������ �������������.'#13#10 +
        '��������� ����������� ��������� ���������!');
  end;

begin
  // ������� ������������ ��������� �� ����������� ����
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
  // ��������� � ���������� ���������
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
  // ���������� ������� ����� ���������
  if Storage = nil then
    StorageFolder := nil
  else
    StorageFolder := Storage.OpenFolder(Path, False);
  // ���� ��� �������� �������� ���������, �� ������� ���
  if Assigned(StorageFolder) and (AValueName > '') then
    StorageValue := StorageFolder.ValueByName(AValueName)
  else
    StorageValue := nil;
  // ���� ��� �������� �������� ��������� �� �������� ���,
  //  ����� �������� ��� �����
  if AValueName > '' then
    SaveValue(StorageValue)
  else
    SaveFolder(StorageFolder);
  // ������� ����� ���������
  if Assigned(StorageFolder) then
    Storage.CloseFolder(StorageFolder);
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

procedure TgdcStreamWriterReader.LoadStorageFromStream(const S: TStream; var AnStAnswer: Word);
begin
  FStream := S;
end;

procedure TgdcStreamWriterReader.SaveStorageToStream(S: TStream);
begin
  FStream := S;
end;

procedure TgdcStreamWriterReader.SaveToStream(S: TStream);
begin
  FStream := S;
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
begin
  inherited;

  FDataObject.IsSave := False;

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
        //FDataObject.ClientDS[ObjectIndex].Open;
      finally
        MS.Free;
      end;
    end;
  finally
    UnpackedStream.Free;
  end;

  {for I := 0 to FDataObject.Count - 1 do
    FDataObject.ClientDS[I].Open;}

end;

procedure TgdcStreamBinaryWriterReader.SaveToStream(S: TStream);
var
  I, K, CurDBID, CurStreamVersion: Integer;
  ID, XID, DBID: Integer;
  PackStream: TZCompressionStream;
  MS: TMemoryStream;
  Obj: TgdcBase;
  IBSQL: TIBSQL;
begin
  inherited;

  // ����� ������
  I := cst_StreamLabel;
  S.Write(I, SizeOf(I));
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

    //������ ������ �� ���� 2
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

procedure TgdcStreamBinaryWriterReader.LoadStorageFromStream(const S: TStream; var AnStAnswer: Word);
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
  inherited;

  // ���� ������� �������� ����� �� ����, ����� ���� ����� ��������
  //  ������ ��������� � ���� ������ TgdcStreamDataProvider, � ����� ������� ������ � ������
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
    // ��������� ���������
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
            PChar('����� ��������� "' + Path + '" ��� ���������� � ����.'#13#10 +
            '�� ������ ���������� ��������� ����� �������� � ������ ������.'#13#10 +
            '�������� ����� ��������!'),
            '��������',
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
              AnStAnswer := MessageDlg('����� "' + Path + '\' + cstValue + '" ��� ���������.'#13#10 +
                '�������� ��������� �����? ', mtConfirmation,
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
          if StreamLoggingType = slAll then
            AddText('�������� ��������� "' + cstValue + '" ����� ��������� "' + StorageName + Path + '"', clBlue);
        end else
        begin
          NewFolder.LoadFromStream(S);
          if StreamLoggingType = slAll then
            AddText('�������� ����� ��������� "' + StorageName + Path + '"', clBlue);
        end;
        LStorage.CloseFolder(NewFolder, False);
        //LStorage.IsModified := True;
      end
      else
      begin
        AddMistake(Format('������ ��� ���������� ������ ���������! ���� %s �� ������.', [Path]), clRed);
        raise Exception.Create(Format('������ ��� ���������� ������ ���������! ���� %s �� ������.', [Path]));
      end
    end
    else
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
  inherited;

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

constructor TgdcStreamXMLWriterReader.Create(
  AObjectSet: TgdcStreamDataObject;
  ALoadingOrderList: TgdcStreamLoadingOrderList);
begin
  inherited Create(AObjectSet, ALoadingOrderList);

  FCurrentDatasetKey := -1;
  FDoInsertXMLHeader := True;
  FElementLevel := 0;

  FAttributeList := TStringList.Create;
  FFieldCorrList := TStringList.Create;
end;

destructor TgdcStreamXMLWriterReader.Destroy;
begin
  inherited;
  FFieldCorrList.Free;
  FAttributeList.Free;
end;

procedure TgdcStreamXMLWriterReader.LoadFromStream(const S: TStream);
var
  I, J, K: Integer;
  XMLElement: TgsXMLElement;
  AMissingClassList: TStringList;
  LoadClassName: TgdcClassName;
  LoadSubType: TgdcSubType;
  LoadSetTable: ShortString;
  SettingHeaderKey, SettingElementIterator: Integer;
  C: TClass;
begin
  inherited;

  FDataObject.IsSave := False;
  SettingHeaderKey := cstUserIDStart;
  SettingElementIterator := cstUserIDStart;

  AMissingClassList := TStringList.Create;
  try
    AMissingClassList.Duplicates := dupIgnore;
    AMissingClassList.Sorted := True;

    while S.Position < S.Size do
    begin
      XMLElement := GetNextElement;

      case XMLElement.Tag of
        etVersion:
        begin
          if XMLElement.Position = epOpening then
          begin
            I := StrToInt(GetTextValueOfElement(XMLElement.ElementString));
            FDataObject.StreamVersion := I;
          end;
        end;

        etDBID:
        begin
          if XMLElement.Position = epOpening then
          begin
            I := StrToInt(GetTextValueOfElement(XMLElement.ElementString));
            FDataObject.StreamDBID := I;
          end;
        end;

        etDatabase:
        begin
          if XMLElement.Position = epOpening then
            FDataObject.DatabaseList.Add(
              GetParamValueByName(XMLElement.ElementString, 'id') + '=' +
              ConvertUTFToAnsi(UnQuoteString(GetParamValueByName(XMLElement.ElementString, 'name'))));
        end;

        etSender:
        begin
          if XMLElement.Position = epOpening then
          begin
            I := StrToInt(GetTextValueOfElement(XMLElement.ElementString));
            FDataObject.SourceBaseKey := I;
          end;
        end;

        etReceiver:
        begin
          if XMLElement.Position = epOpening then
          begin
            I := StrToInt(GetTextValueOfElement(XMLElement.ElementString));
            FDataObject.TargetBaseKey := I;
          end;
        end;

        etReceivedRecord:
        begin
          I := GetIntegerParamValueByName(XMLElement.ElementString, 'xid');
          J := GetIntegerParamValueByName(XMLElement.ElementString, 'dbid');
          FDataObject.AddReceivedRecord(I, J);
        end;

        etReferencedRecord:
        begin
          I := GetIntegerParamValueByName(XMLElement.ElementString, 'id');
          J := GetIntegerParamValueByName(XMLElement.ElementString, 'xid');
          K := GetIntegerParamValueByName(XMLElement.ElementString, 'dbid');
          FDataObject.AddReferencedRecord(I, J, K);
        end;

        etOrderItem:
        begin
          I := GetIntegerParamValueByName(XMLElement.ElementString, 'objectkey');
          J := GetIntegerParamValueByName(XMLElement.ElementString, 'recordid');
          FLoadingOrderList.AddItem(J, I);
        end;

        etDataset:
        begin
          // �������� ������ ������������ ��������
          if XMLElement.Position = epOpening then
          begin
            FCurrentDatasetKey := GetIntegerParamValueByName(XMLElement.ElementString, 'objectkey');

            // ��������� ����� � ������ ������������ �������
            LoadClassName := UnQuoteString(GetParamValueByName(XMLElement.ElementString, 'classname'));
            LoadSubType := UnQuoteString(GetParamValueByName(XMLElement.ElementString, 'subtype'));
            LoadSetTable := UnQuoteString(GetParamValueByName(XMLElement.ElementString, 'settable'));

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
              FDataObject.Add(LoadClassName, LoadSubType, LoadSetTable, FCurrentDatasetKey);
          end
          else
            FCurrentDatasetKey := -1;  
        end;

        // ���������� ��������
        etDatasetMetaData:
        begin
          // ������� ������ ������������ �������� �������� �����, � �������� ��������� XML
          if XMLElement.Position = epOpening then
          begin
            // ������� ������ ������������ �������� ����� � XML �����
            FFieldCorrList.Clear;
            // ������� � ������� ������� ����� ��������� �����
            FDataObject.ClientDS[FCurrentDatasetKey].Close;
            FDataObject.ClientDS[FCurrentDatasetKey].FieldDefs.Clear;
          end
          else
          begin
            if FCurrentDatasetKey > -1 then
            begin
              // �������� ������� �� ������ ���������� �����
              TClientDataset(FDataObject.ClientDS[FCurrentDatasetKey]).CreateDataset;
              TClientDataset(FDataObject.ClientDS[FCurrentDatasetKey]).LogChanges := False;
            end
            else
              raise EgsXMLParseException.Create(Format('������ ����������� ��� </%0:s> ��� ������������ ���� <%1:s>',
                [XML_TAG_DATASET_METADATA, XML_TAG_DATASET]));
          end;
        end;

        // ���� ��������
        etDatasetField:
        begin
          if FCurrentDatasetKey > -1 then
          begin
            ParseFieldDefinition(XMLElement.ElementString);
          end
          else
            raise EgsXMLParseException.Create(Format('������ ������� <%0:s> ��� �������� <%1:s>',
              [XML_TAG_DATASET_FIELD, XML_TAG_DATASET]));
        end;

        // ������ ��������
        etDatasetRowData:
        begin
          if FCurrentDatasetKey = -1 then
            raise EgsXMLParseException.Create(Format('������ ������� <%0:s> ��� �������� <%1:s>',
              [XML_TAG_DATASET_ROWDATA, XML_TAG_DATASET]));
        end;

        // ������ ��������
        etDatasetRow:
        begin
          if FCurrentDatasetKey > -1 then
            ParseDatasetRecord
          else
            raise EgsXMLParseException.Create(Format('������ ������� <%0:s> ��� �������� <%1:s>',
              [XML_TAG_DATASET_ROW, XML_TAG_DATASET]));
        end;

        // ��������� ���������
        etSettingHeader:
        begin
          if XMLElement.Position = epOpening then
          begin
            FCurrentDatasetKey := FDataObject.Add('TgdcSetting', '', '', -1, True);
            SettingHeaderKey := SettingElementIterator;
            ParseSettingHeader(XMLElement.ElementString, SettingElementIterator);
            FLoadingOrderList.AddItem(SettingElementIterator, FCurrentDatasetKey);
            Inc(SettingElementIterator);
          end;
        end;

        // ������ ������� ���������
        etSettingPosList:
          if XMLElement.Position = epOpening then
            FCurrentDatasetKey := FDataObject.Add('TgdcSettingPos', '', '', -1, True);

        // ������� ���������
        etSettingPos:
        begin
          ParseSettingPosition(XMLElement.ElementString, SettingElementIterator, SettingHeaderKey);
          FLoadingOrderList.AddItem(SettingElementIterator, FCurrentDatasetKey);
          Inc(SettingElementIterator);
        end;

        // ������ ���������
        etSettingData:
        begin
          if XMLElement.Position = epOpening then
          begin
            FCurrentDatasetKey := FDataObject.GetObjectIndex('TgdcSetting');
            FDataObject.ClientDS[FCurrentDatasetKey].Edit;
            FDataObject.ClientDS[FCurrentDatasetKey].FieldByName('DATA').AsString :=
              GetTextValueOfElement(XMLElement.ElementString);
            FDataObject.ClientDS[FCurrentDatasetKey].Post;
          end;
        end;
      end;
    end;

  finally
    AMissingClassList.Free;
  end;
end;

procedure TgdcStreamXMLWriterReader.SaveToStream(S: TStream);
begin
  inherited;

  if (FDataObject.Count > 0) and (FDataObject.gdcObject[0] is TgdcSetting) then
    InternalSaveSettingToStream
  else
    InternalSaveToStream;
end;

procedure TgdcStreamXMLWriterReader.SaveDataset(CDS: TDataSet);
var
  I: Integer;
  FD: TFieldDef;
begin
  // ������� ��� ���������� ��������
  StreamWriteXMLString(Stream, AddOpenTag(XML_TAG_DATASET_METADATA));
  // ������ ����� ��������
  for I := 0 to CDS.FieldDefs.Count - 1 do
  begin
    FD := CDS.FieldDefs[I];
    if AnsiPos('$', FD.Name) > 0 then
    begin
      AddAttribute('name', UpperCase(StringReplace(CDS.Fields[I].FieldName, '$', '_', [rfReplaceAll])));
      AddAttribute('originalname', UpperCase(FD.Name));
    end
    else
      AddAttribute('name', UpperCase(FD.Name));
    AddAttribute('type', FieldTypeToString(FD.DataType));
    // ������ �������������� ���� ��� ����������
    if FD.Required then
      AddAttribute('required', '1');
    // ��� ����� � ������������� ������ ������ ��������
    if (FD.DataType in [ftCurrency, ftBCD]) and (FD.Precision > 0) then
      AddAttribute('precision', IntToStr(FD.Precision));
    // ��� ����� � �������� ����� ������ ������ ����
    //  ��� ����� � ������������� ������ ������ ���-�� ������ ����� �������
    if FD.Size > 0 then
      if FD.DataType in [ftString, ftWideString, ftBytes, ftVarBytes] then
        AddAttribute('size', IntToStr(FD.Size))
      else if FD.DataType in [ftBCD, ftCurrency] then
        AddAttribute('decimals', IntToStr(FD.Size));

    StreamWriteXMLString(Stream, AddShortElement(XML_TAG_DATASET_FIELD, True));
  end;
  // ������� ��� ���������� ��������
  StreamWriteXMLString(Stream, AddCloseTag(XML_TAG_DATASET_METADATA));

  // ������� ��� ������ ��������
  StreamWriteXMLString(Stream, AddOpenTag(XML_TAG_DATASET_ROWDATA));
  CDS.First;
  while not CDS.Eof do
  begin
    StreamWriteXMLString(Stream, AddOpenTag(XML_TAG_DATASET_ROW));
    for I := 0 to CDS.FieldCount - 1 do
    begin
      if not CDS.Fields[I].IsNull then
        SaveDatasetFieldValue(CDS.Fields[I]);
    end;
    StreamWriteXMLString(Stream, AddCloseTag(XML_TAG_DATASET_ROW));
    CDS.Next;
  end;
  // ������� ��� ������ ��������
  StreamWriteXMLString(Stream, AddCloseTag(XML_TAG_DATASET_ROWDATA));
end;

function TgdcStreamXMLWriterReader.GetNextElement: TgsXMLElement;
var
  ElementBeginChars: String;
begin
  Result.Tag := etUnknown;
  // ������� ����� �������� � �����������
  Result.ElementString := InternalGetNextElement;
  // ������� ��� �������� (�����������/�����������)
  Result.Position := GetXMLElementPosition(Result.ElementString);
  if Result.Position = epOpening then
    ElementBeginChars := '<'
  else
    ElementBeginChars := '</';

  if AnsiCompareText(Result.ElementString, ElementBeginChars + XML_TAG_STREAM + '>') = 0 then
  begin
    Result.Tag := etStream;
    Exit;
  end;

  if AnsiCompareText(Result.ElementString, ElementBeginChars + XML_TAG_VERSION + '>') = 0 then
  begin
    Result.Tag := etVersion;
    Exit;
  end;

  if AnsiCompareText(Result.ElementString, ElementBeginChars + XML_TAG_DBID + '>') = 0 then
  begin
    Result.Tag := etDBID;
    Exit;
  end;

  if AnsiCompareText(Result.ElementString, ElementBeginChars + XML_TAG_DATABASE_LIST + '>') = 0 then
  begin
    Result.Tag := etDataBaseList;
    Exit;
  end;

  if (AnsiPos(ElementBeginChars + XML_TAG_DATABASE + ' ', Result.ElementString) > 0)
     or (AnsiPos(ElementBeginChars + XML_TAG_DATABASE + NEW_LINE, Result.ElementString) > 0) then
  begin
    Result.Tag := etDataBase;
    Exit;
  end;

  if AnsiCompareText(Result.ElementString, ElementBeginChars + XML_TAG_SENDER + '>') = 0 then
  begin
    Result.Tag := etSender;
    Exit;
  end;

  if AnsiCompareText(Result.ElementString, ElementBeginChars + XML_TAG_RECEIVER + '>') = 0 then
  begin
    Result.Tag := etReceiver;
    Exit;
  end;

  if AnsiCompareText(Result.ElementString, ElementBeginChars + XML_TAG_RECEIVED_RECORD_LIST + '>') = 0 then
  begin
    Result.Tag := etReceivedRecordList;
    Exit;
  end;

  if (AnsiPos(ElementBeginChars + XML_TAG_RECEIVED_RECORD + ' ', Result.ElementString) > 0)
     or (AnsiPos(ElementBeginChars + XML_TAG_RECEIVED_RECORD + NEW_LINE, Result.ElementString) > 0) then
  begin
    Result.Tag := etReceivedRecord;
    Exit;
  end;

  if AnsiCompareText(Result.ElementString, ElementBeginChars + XML_TAG_REFERENCED_RECORD_LIST + '>') = 0 then
  begin
    Result.Tag := etReferencedRecordList;
    Exit;
  end;

  if (AnsiPos(ElementBeginChars + XML_TAG_REFERENCED_RECORD + ' ', Result.ElementString) > 0)
     or (AnsiPos(ElementBeginChars + XML_TAG_REFERENCED_RECORD + NEW_LINE, Result.ElementString) > 0) then
  begin
    Result.Tag := etReferencedRecord;
    Exit;
  end;

  if AnsiCompareText(Result.ElementString, ElementBeginChars + XML_TAG_LOADING_ORDER + '>') = 0 then
  begin
    Result.Tag := etOrder;
    Exit;
  end;

  if (AnsiPos(ElementBeginChars + XML_TAG_LOADING_ORDER_ITEM + ' ', Result.ElementString) > 0)
     or (AnsiPos(ElementBeginChars + XML_TAG_LOADING_ORDER_ITEM + NEW_LINE, Result.ElementString) > 0) then
  begin
    Result.Tag := etOrderItem;
    Exit;
  end;

  if AnsiCompareText(Result.ElementString, ElementBeginChars + XML_TAG_DATA + '>') = 0 then
  begin
    Result.Tag := etData;
    Exit;
  end;

  if (AnsiPos(ElementBeginChars + XML_TAG_DATASET + ' ', Result.ElementString) > 0)
     or (AnsiPos(ElementBeginChars + XML_TAG_DATASET + NEW_LINE, Result.ElementString) > 0) then
  begin
    Result.Tag := etDataset;
    Exit;
  end;

  if AnsiCompareText(Result.ElementString, ElementBeginChars + XML_TAG_SETTING + '>') = 0 then
  begin
    Result.Tag := etSetting;
    Exit;
  end;

  if (AnsiPos(ElementBeginChars + XML_TAG_SETTING_HEADER + ' ', Result.ElementString) > 0)
     or (AnsiPos(ElementBeginChars + XML_TAG_SETTING_HEADER + NEW_LINE, Result.ElementString) > 0) then
  begin
    Result.Tag := etSettingHeader;
    Exit;
  end;

  if AnsiCompareText(Result.ElementString, ElementBeginChars + XML_TAG_SETTING_POS_LIST + '>') = 0 then
  begin
    Result.Tag := etSettingPosList;
    Exit;
  end;

  if (AnsiPos(ElementBeginChars + XML_TAG_SETTING_POS + ' ', Result.ElementString) > 0)
     or (AnsiPos(ElementBeginChars + XML_TAG_SETTING_POS + NEW_LINE, Result.ElementString) > 0) then
  begin
    Result.Tag := etSettingPos;
    Exit;
  end;

  if AnsiCompareText(Result.ElementString, ElementBeginChars + XML_TAG_SETTING_DATA + '>') = 0 then
  begin
    Result.Tag := etSettingData;
    Exit;
  end;

  // ���������� ��������
  if AnsiCompareText(Result.ElementString, ElementBeginChars + XML_TAG_DATASET_METADATA + '>') = 0 then
  begin
    Result.Tag := etDatasetMetaData;
    Exit;
  end;
  // ���� ��������
  if (AnsiPos(ElementBeginChars + XML_TAG_DATASET_FIELD + ' ', Result.ElementString) > 0)
     or (AnsiPos(ElementBeginChars + XML_TAG_DATASET_FIELD + NEW_LINE, Result.ElementString) > 0) then
  begin
    Result.Tag := etDatasetField;
    Exit;
  end;
  // ������ ��������
  if AnsiCompareText(Result.ElementString, ElementBeginChars + XML_TAG_DATASET_ROWDATA + '>') = 0 then
  begin
    Result.Tag := etDatasetRowData;
    Exit;
  end;
  // ������ ��������
  if AnsiCompareText(Result.ElementString, ElementBeginChars + XML_TAG_DATASET_ROW + '>') = 0 then
  begin
    Result.Tag := etDatasetRow;
    Exit;
  end;
end;

function TgdcStreamXMLWriterReader.GetPositionOfString(const Str: String): Integer;
const
  SEEK_CHAR_COUNT = 100;
var
  OldPosition: Integer;
  Position: Integer;
  TempStrPosition: Integer;
  FirstStringBuff, SecondStringBuff: String;
  UpperCaseSearchString: String;
begin
  Result := -1;
  // �������� ��������� ������� � ������
  OldPosition := Stream.Position;
  TempStrPosition := 0;
  UpperCaseSearchString := AnsiUpperCase(Str);
  SetLength(FirstStringBuff, SEEK_CHAR_COUNT);
  SetLength(SecondStringBuff, SEEK_CHAR_COUNT);

  Stream.Read(FirstStringBuff[1], SEEK_CHAR_COUNT);
  Position := AnsiPos(UpperCaseSearchString, AnsiUpperCase(FirstStringBuff));
  if Position > 0 then
  begin
    Result := OldPosition + TempStrPosition + Position - 1;
  end
  else
  begin
    while Stream.Position < Stream.Size do
    begin
      Stream.Read(SecondStringBuff[1], SEEK_CHAR_COUNT);
      Position := AnsiPos(UpperCaseSearchString, AnsiUpperCase(FirstStringBuff + SecondStringBuff));
      if Position > 0 then
      begin
        Result := OldPosition + TempStrPosition + Position - 1;
        Break;
      end
      else
        TempStrPosition := TempStrPosition + SEEK_CHAR_COUNT;

      FirstStringBuff := SecondStringBuff;
    end;
  end;
  // ������ ����� � ��������� �������
  Stream.Position := OldPosition;
end;

function TgdcStreamXMLWriterReader.GetTextValueOfElement(const ElementHeader: String): String;
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

  ElementTextEndPosition := Self.GetPositionOfString('</' + ElementName + '>');
  if ElementTextEndPosition > 0 then
  begin
    SetLength(TempStr, ElementTextEndPosition - Stream.Position);
    Stream.ReadBuffer(TempStr[1], ElementTextEndPosition - Stream.Position);
    Result := TempStr;
  end
  else
  begin
    Stream.ReadBuffer(TempChar, SizeOf(TempChar));
    if TempChar <> '<' then
      while (TempChar <> '<') and (Stream.Position < Stream.Size) do
      begin
        Result := Result + TempChar;
        Stream.ReadBuffer(TempChar, SizeOf(TempChar));
      end;
  end;
  // ������ ������� �������� � �������
  Result := Trim(Result);
end;

function TgdcStreamXMLWriterReader.GetParamValueByName(const Str, ParamName: String): String;
var
  ParamStartPosition, ParamValueStartPosition, ParamValueEndPosition: Integer;
  StringPosCounter: Integer;
  TempParamName: String;
begin
  Result := '';
  TempParamName := ParamName + '="';
  ParamStartPosition := AnsiPos(AnsiUpperCase(TempParamName), AnsiUpperCase(Str));
  // ���� ������� ������������ � ��������
  if ParamStartPosition > 0 then
  begin
    ParamValueStartPosition := ParamStartPosition + Length(TempParamName);
    ParamValueEndPosition := ParamValueStartPosition;
    for StringPosCounter := ParamValueEndPosition to Length(Str) - 1 do
      if Str[StringPosCounter] = '"' then
      begin
        ParamValueEndPosition := StringPosCounter;
        Break;
      end;
    if ParamValueEndPosition > ParamValueStartPosition then
      Result := Trim(Copy(Str, ParamValueStartPosition, ParamValueEndPosition - ParamValueStartPosition));
  end;
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

function TgdcStreamXMLWriterReader.GetXMLSettingHeader(S: TStream;
  SettingHeader: TSettingHeader): Boolean;
var
  XMLElement: TgsXMLElement;
  I: Integer;
begin
  Result := False;
  Stream := S;

  XMLElement.Tag := etUnknown;
  try
    while XMLElement.Tag <> etSettingHeader do
    begin
      XMLElement := GetNextElement;
      case XMLElement.Tag of
        // ���� ����� ��� STREAM ������ ��� SETTING_HEADER,
        //  ������ ������ ������� ���� ������, � �� ���������
        etStream:
          Exit;

        etSettingHeader:
        begin
          if XMLElement.Position = epOpening then
          begin
            SettingHeader.RUID := RUID(GetIntegerParamValueByName(XMLElement.ElementString, 'xid'),
              GetIntegerParamValueByName(XMLElement.ElementString, 'dbid'));
            SettingHeader.Name :=
              UnQuoteString(ConvertUTFToAnsi(GetParamValueByName(XMLElement.ElementString, 'name')));
            SettingHeader.Comment :=
              UnQuoteString(ConvertUTFToAnsi(GetParamValueByName(XMLElement.ElementString, 'description')));
            SettingHeader.Date := SafeStrToDateTime(GetParamValueByName(XMLElement.ElementString, 'modifydate'));
            SettingHeader.Version := GetIntegerParamValueByName(XMLElement.ElementString, 'version');
            SettingHeader.Ending := GetIntegerParamValueByName(XMLElement.ElementString, 'ending');
            SettingHeader.InterRUID.CommaText := GetParamValueByName(XMLElement.ElementString, 'settingsruid');
            SettingHeader.MinEXEVersion := GetParamValueByName(XMLElement.ElementString, 'minexeversion');
            SettingHeader.MinDBVersion := GetParamValueByName(XMLElement.ElementString, 'mindbversion');
          end;
        end;

      end;
    end;

    // ������� �� RUID'�
    I := 0;
    with SettingHeader do
      while I < InterRUID.Count do
      begin
        if Length(InterRUID[I]) > 0 then
        begin
          // ������� �������, ���� ����
          if (InterRUID[I][1] = '''') and (InterRUID[i][Length(InterRUID[I])] = '''') then
            InterRUID[I] := Copy(InterRUID[i], 2, Length(InterRUID[i])-2);
          // ��������� ������������ RUID'�
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

    Result := True;  
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

function TgdcStreamXMLWriterReader.AddOpenTag(const ATag: String; const ASingleLine: Boolean = false): String;
var
  AttributeCounter: Integer;
  AttributeName: String;
begin
  Result := Format('%s<%s', [StringOfChar(INDENT_STR, FElementLevel * 2), ATag]);
  // ���� � ������ ���������� ���-�� ����, ������� �� � ���� �������
  if FAttributeList.Count > 0 then
  begin
    for AttributeCounter := 0 to FAttributeList.Count - 1 do
    begin
      if not ASingleLine then
        Result := Result + NEW_LINE + StringOfChar(INDENT_STR, (FElementLevel + 1) * 2)
      else
        Result := Result + ' ';
      AttributeName := FAttributeList.Names[AttributeCounter];
      Result := Format('%s%s="%s"', [Result, AttributeName, FAttributeList.Values[AttributeName]]);
    end;
    // ������� ������ ����������
    FAttributeList.Clear;
  end;
  Result := Result + '>' + NEW_LINE;
  // �������� ������� ����������� ��������
  Inc(FElementLevel);
end;

function TgdcStreamXMLWriterReader.AddCloseTag(const ATag: String): String;
begin
  // �������� ������� ����������� ��������
  Dec(FElementLevel);
  Result := Format('%s</%s>%s', [StringOfChar(INDENT_STR, FElementLevel * 2), ATag, NEW_LINE]);
end;

function TgdcStreamXMLWriterReader.AddElement(const ATag, AValue: String): String;
var
  AttributeCounter: Integer;
  AttributeName: String;
begin
  Result := Format('%s<%s', [StringOfChar(INDENT_STR, FElementLevel * 2), ATag]);
  // ���� � ������ ���������� ���-�� ����, ������� �� � ���� �������
  if FAttributeList.Count > 0 then
  begin
    for AttributeCounter := 0 to FAttributeList.Count - 1 do
    begin
      AttributeName := FAttributeList.Names[AttributeCounter];
      Result := Format('%s %s="%s"', [Result, AttributeName, FAttributeList.Values[AttributeName]]);
    end;
    // ������� ������ ����������
    FAttributeList.Clear;
  end;

  Result := Format('%s>%s</%s>%s', [Result, AValue, ATag, NEW_LINE]);
end;

function TgdcStreamXMLWriterReader.AddShortElement(const ATag: String;
  const ASingleLine: Boolean = false): String;
var
  AttributeCounter: Integer;
  AttributeName: String;
begin
  Result := Format('%s<%s', [StringOfChar(INDENT_STR, FElementLevel * 2), ATag]);
  // ���� � ������ ���������� ���-�� ����, ������� �� � ���� �������
  if FAttributeList.Count > 0 then
  begin
    for AttributeCounter := 0 to FAttributeList.Count - 1 do
    begin
      if not ASingleLine then
        Result := Result + NEW_LINE + StringOfChar(INDENT_STR, (FElementLevel + 1) * 2)
      else
        Result := Result + ' ';
      AttributeName := FAttributeList.Names[AttributeCounter];
      Result := Format('%s%s="%s"', [Result, AttributeName, FAttributeList.Values[AttributeName]]);
    end;
    // ������� ������ ����������
    FAttributeList.Clear;
  end;
  Result := Format('%s/>%s', [Result, NEW_LINE]);
end;

procedure TgdcStreamXMLWriterReader.AddAttribute(const AAttributeName, AValue: String);
begin
  FAttributeList.Add(AAttributeName + '=' + AValue);
end;

procedure TgdcStreamXMLWriterReader.SaveStorageValue(AField: TField);
var
  StorageValueStr: String;
  StIn, StOut: TStringStream;
  Sign, Grid: String;
begin
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

      SaveMemoTagValue(StOut.DataString, tgtText);
    finally
      StOut.Free;
      StIn.Free;
    end;
  end
  else
  begin
    SaveMemoTagValue(MimeEncodeString(StorageValueStr), tgtBlob);
  end;
end;

procedure TgdcStreamXMLWriterReader.ParseFieldDefinition(const ElementStr: String);
var
  Dataset: TDataset;
  FieldDefinition: TFieldDef;
  XMLFieldName, DatasetFieldName: String;
begin
  // ������� ����������� �������
  Dataset := DataObject.ClientDS[FCurrentDatasetKey];

  // ��������� ������ ������������ �������� ��������� XML � �������� �������� ����� 
  XMLFieldName := GetParamValueByName(ElementStr, 'name');
  DatasetFieldName := GetParamValueByName(ElementStr, 'originalname');
  if DatasetFieldName = '' then
    DatasetFieldName := XMLFieldName;
  FFieldCorrList.Add(XMLFieldName + '=' + DatasetFieldName);

  // ������� ���� � �������
  FieldDefinition := Dataset.FieldDefs.AddFieldDef;
  FieldDefinition.Name := DatasetFieldName;
  FieldDefinition.DataType := StringToFieldType(GetParamValueByName(ElementStr, 'type'));
  FieldDefinition.Precision := GetIntegerParamValueByName(ElementStr, 'precision');
  // ��� ����� ����������� SIZE, ��� �������� � ������������� ������ - DECIMALS
  FieldDefinition.Size := GetIntegerParamValueByName(ElementStr, 'size') + GetIntegerParamValueByName(ElementStr, 'decimals');
  FieldDefinition.Required := GetIntegerParamValueByName(ElementStr, 'required') = 1;
end;

procedure TgdcStreamXMLWriterReader.ParseDatasetRecord;
var
  XMLElementStr: String;
  ElementName: String;
  ElementValue: String;
  DatasetFieldName: String;
  DatasetField: TField;
  XMLElementPosition: TgsXMLElementPosition;
  Dataset: TDataset;

  function GetElementName(const AXMLElement: String): String;
  begin
    if AXMLElement[2] = '/' then
      Result := Copy(AXMLElement, 3, Length(AXMLElement) - 3)
    else
      Result := Copy(AXMLElement, 2, Length(AXMLElement) - 2);
  end;
  
begin
  XMLElementStr := InternalGetNextElement;
  XMLElementPosition := GetXMLElementPosition(XMLElementStr);
  ElementName := GetElementName(XMLElementStr);

  Dataset := DataObject.ClientDS[FCurrentDatasetKey];
  Dataset.Insert;
  // ������� �� ��������� ������ �� XML
  while (ElementName <> '') and (ElementName <> XML_TAG_DATASET_ROW) do
  begin
    if XMLElementPosition = epOpening then
    begin
      ElementValue := GetTextValueOfElement(XMLElementStr);
      // ������� �������� ��� ����, �������� � �������� �������������� $ � ���� �������� �� _
      DatasetFieldName := FFieldCorrList.Values[ElementName];
      if DatasetFieldName <> '' then
      begin
        DatasetField := Dataset.FindField(DatasetFieldName);
        // ���� ���� ����� ����, ������� ��������� ����������
        if Assigned(DatasetField) then
          ParseDatasetFieldValue(DatasetField, ElementValue);
      end;
    end;
    // ������� ��������� �������
    XMLElementStr := InternalGetNextElement;
    XMLElementPosition := GetXMLElementPosition(XMLElementStr);
    ElementName := GetElementName(XMLElementStr);
  end;
  Dataset.Post;
end;

procedure TgdcStreamXMLWriterReader.SaveDatasetFieldValue(AField: TField);
var
  CurrentFieldName: String;
begin
  CurrentFieldName := UpperCase(StringReplace(AField.FieldName, '$', '_', [rfReplaceAll]));

  case AField.DataType of
    ftMemo:
    begin
      StreamWriteXMLString(Stream, AddOpenTag(CurrentFieldName));
      if IsXML(AField.AsString) then
        SaveMemoTagValue(AField.AsString, tgtXML)
      else
        SaveMemoTagValue(AField.AsString, tgtText);
      StreamWriteXMLString(Stream, AddCloseTag(CurrentFieldName));
    end;

    ftBLOB, ftGraphic:
    begin
      StreamWriteXMLString(Stream, AddOpenTag(CurrentFieldName));
      // ���� ���� ���� ����������� ��� ���������, �� � ��� ����� ���� DFM � ��� �� ���� ����������
      if AnsiCompareText(FDataObject.gdcObject[FCurrentDatasetKey].Classname, 'TgdcStorageValue') = 0 then
        SaveStorageValue(AField)
      else if IsXML(AField.AsString) then    // ���� � ����������� ���� ��������� XML
        // ������� ������ �� �������� <L>line_text</L>
        SaveMemoTagValue(AField.AsString, tgtXML)
      else
        SaveMemoTagValue(MimeEncodeString(AField.AsString), tgtBlob);
      StreamWriteXMLString(Stream, AddCloseTag(CurrentFieldName));
    end;

    ftDate, ftDateTime, ftTime:
      StreamWriteXMLString(Stream, AddElement(CurrentFieldName, SafeDateTimeToStr(AField.AsDateTime)));

    ftFloat, ftCurrency, ftBCD:
      StreamWriteXMLString(Stream, AddElement(CurrentFieldName, SafeFloatToStr(AField.AsFloat)));
  else
    StreamWriteXMLString(Stream, AddElement(CurrentFieldName, QuoteString(AField.AsString)));
  end;
end;

// ����� �������� ������ ����� � ������������� STRING � ���� <L>
//  � ������ ����� ���� ����������� �������
procedure TgdcStreamXMLWriterReader.SaveMemoTagValue(const AMemoValue: String;
  AMLType: TgsMultiLineXMLTagValueType = tgtText);
var
  MemoString: String;
  Prefix, Postfix: String;
  IndentStr: String;
begin
  MemoString := Trim(AMemoValue);

  IndentStr := StringOfChar(INDENT_STR, FElementLevel * 2);
  Prefix := IndentStr + XML_CDATA_BEGIN + #13#10 + IndentStr;
  Postfix := #13#10 + IndentStr + XML_CDATA_END + #13#10;

  {// XML �� ����� ��������� � <L>
  if AMLType = tgtXML then
    // ������� ��� �������� ������ �� ������ + ������� ������
    MemoString :=
      Prefix +
      StringReplace(MemoString, #13#10, #13#10 + IndentStr,
        [rfReplaceAll, rfIgnoreCase]) +
      Postfix
  else}
    // ������� ��� �������� ������ �� �������� - �������� ���� <L> + ������ + ������� ������
    MemoString :=
      Prefix + '<' + XML_TAG_MULTILINE_SPLITTER + '>' +
      StringReplace(MemoString, #13#10,
        '</' + XML_TAG_MULTILINE_SPLITTER + '>'#13#10 + IndentStr + '<' + XML_TAG_MULTILINE_SPLITTER + '>',
        [rfReplaceAll, rfIgnoreCase]) +
      '</' + XML_TAG_MULTILINE_SPLITTER + '>' + Postfix;

  // ������� � �����
  if AMLType = tgtText then
    StreamWriteXMLString(Stream, MemoString)
  else
    // ���� ��� BLOB- ��� XML-��������, �� �� ����� ���������� � UTF-8
    StreamWriteXMLString(Stream, MemoString, False);
end;

procedure TgdcStreamXMLWriterReader.ParseDatasetFieldValue(AField: TField; const AFieldValue: String);
begin
  case AField.DataType of
    ftMemo:
      if IsXML(AFieldValue) then
        AField.AsString := ParseMemoTagValue(AFieldValue, tgtXML)
      else
        // ���� ������ ���� �������� ��� ������ ��������� <L>element_text</L>
        //  � ������ �� ������� ��������� ���� ������ ������ ����������� ����� QuoteString
        AField.AsString := ConvertUTFToAnsi(ParseMemoTagValue(AFieldValue, tgtText));

    ftBLOB, ftGraphic:
    begin
      // ���� ���� ���� ����������� ��� ���������, �� � ��� ����� ���� DFM � ��� �� ���� ����������
      if AnsiCompareText(FDataObject.gdcObject[FCurrentDatasetKey].Classname, 'TgdcStorageValue') = 0 then
        AField.AsString := ParseStorageValue(AFieldValue)
      else if IsXML(AFieldValue) then    // ���� � ����������� ���� ��������� XML
        AField.AsString := ParseMemoTagValue(AFieldValue, tgtXML)
      else
        // ���� ������ ���� �������� ��� ������ ��������� <L>element_text</L>
        AField.AsString := MimeDecodeString(ParseMemoTagValue(AFieldValue, tgtBlob));
    end;

    ftDate, ftDateTime, ftTime:
      AField.AsDateTime := SafeStrToDateTime(AFieldValue);

    ftFloat, ftCurrency, ftBCD:
      AField.AsFloat := SafeStrToFloat(AFieldValue);
  else
    AField.AsString := UnQuoteString(ConvertUTFToANSI(AFieldValue));
  end;
end;

function TgdcStreamXMLWriterReader.ParseMemoTagValue(const ATagValue: String;
  AMLType: TgsMultiLineXMLTagValueType = tgtText): String;
var
  StringList: TStringList;
  StringCounter: Integer;
begin
  // ������� ���� <![CDATA[  ]]>
  Result := StringReplace(ATagValue, XML_CDATA_BEGIN, '', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, XML_CDATA_END, '', [rfReplaceAll, rfIgnoreCase]);
  // ������� ������� �������������� XML
  StringList := TStringList.Create;
  try
    StringList.Text := Result;
    for StringCounter := 0 to StringList.Count - 1 do
      StringList.Strings[StringCounter] := Trim(StringList.Strings[StringCounter]);
    // ������� ������ ����������� � ��������� <![CDATA[ 
    if Trim(StringList.Strings[0]) = '' then
      StringList.Delete(0);
    // ������� ������ ����������� � ��������� ]]>
    if Trim(StringList.Strings[StringList.Count - 1]) = '' then
      StringList.Delete(StringList.Count - 1);
    // ������� ���� XML_TAG_MULTILINE_SPLITTER
    Result := StringReplace(StringList.Text, '<' + XML_TAG_MULTILINE_SPLITTER + '>', '', [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, '</' + XML_TAG_MULTILINE_SPLITTER + '>', '', [rfReplaceAll, rfIgnoreCase]);
  finally
    StringList.Free;
  end;
end;

function TgdcStreamXMLWriterReader.ParseStorageValue(const AFieldValue: String): String;
var
  StIn, StOut: TStringStream;
begin
  // ���� ��� �������� TgsStreamValue, �� ��� ��� ��������� ����
  //  ��� �������� ������ (�������� ��������� �����)
  if AnsiPos('object', AFieldValue) > 0 then
  begin
    // ����������� ��������� ����� � ����������� �������
    StIn := TStringStream.Create(ConvertUTFToANSI(ParseMemoTagValue(AFieldValue)));
    StOut := TStringStream.Create('');
    try
      ObjectTextToBinary(StIn, StOut);
      Result := StOut.DataString;
    finally
      StOut.Free;
      StIn.Free;
    end;
  end
  else
  begin
    // ���������� �������� ������ �� ���������� �������
    Result := MimeDecodeString(ParseMemoTagValue(AFieldValue));
  end;
end;

function TgdcStreamXMLWriterReader.InternalGetNextElement: String;
var
  TempStr: AnsiChar;
begin
  TempStr := Chr(0);
  while (TempStr <> '<') and (Stream.Position < Stream.Size) do
    Stream.ReadBuffer(TempStr, SizeOf(TempStr));

  Result := TempStr;

  TempStr := Chr(0);
  while (TempStr <> '>') and (Stream.Position < Stream.Size) do
  begin
    Stream.ReadBuffer(TempStr, SizeOf(TempStr));
    Result := Result + TempStr;
  end;

  Result := Result;
end;

function TgdcStreamXMLWriterReader.GetXMLElementPosition(const AElementStr: String): TgsXMLElementPosition;
begin
  if AElementStr[2] = '/' then
    Result := epClosing
  else
    Result := epOpening;
end;

procedure TgdcStreamXMLWriterReader.ParseSettingHeader(
  const ElementStr: String; const ARecordKey: Integer);
var
  Dataset: TDataset;
begin
  Dataset := FDataObject.ClientDS[FCurrentDatasetKey];
  Dataset.Insert;
  Dataset.FieldByName('ID').AsInteger := ARecordKey;
  Dataset.FieldByName('NAME').AsString :=
    UnQuoteString(ConvertUTFToAnsi(GetParamValueByName(ElementStr, 'name')));
  Dataset.FieldByName('VERSION').AsString := GetParamValueByName(ElementStr, 'version');
  Dataset.FieldByName('MODIFYDATE').AsDateTime := SafeStrToDateTime(GetParamValueByName(ElementStr, 'modifydate'));
  Dataset.FieldByName('DESCRIPTION').AsString :=
    UnQuoteString(ConvertUTFToAnsi(GetParamValueByName(ElementStr, 'description')));
  Dataset.FieldByName('ENDING').AsString := GetParamValueByName(ElementStr, 'ending');
  Dataset.FieldByName('SETTINGSRUID').AsString := GetParamValueByName(ElementStr, 'settingsruid');
  Dataset.FieldByName('MINEXEVERSION').AsString := GetParamValueByName(ElementStr, 'minexeversion');
  Dataset.FieldByName('MINDBVERSION').AsString := GetParamValueByName(ElementStr, 'mindbversion');
  Dataset.FieldByName(XID_FIELD).AsString := GetParamValueByName(ElementStr, 'xid');
  Dataset.FieldByName(DBID_FIELD).AsString := GetParamValueByName(ElementStr, 'dbid');
  //Dataset.FieldByName(MODIFIED_FIELD).AsDateTime := Dataset.FieldByName('MODIFYDATE').AsDateTime;
  Dataset.Post;
end;

procedure TgdcStreamXMLWriterReader.ParseSettingPosition(
  const ElementStr: String; const ARecordKey, AHeaderKey: Integer);
var
  Dataset: TDataset;
begin
  Dataset := FDataObject.ClientDS[FCurrentDatasetKey];
  Dataset.Insert;
  Dataset.FieldByName('ID').AsInteger := ARecordKey;
  Dataset.FieldByName('SETTINGKEY').AsInteger := AHeaderKey;
  Dataset.FieldByName('CATEGORY').AsString :=
    UnQuoteString(ConvertUTFToAnsi(GetParamValueByName(ElementStr, 'category')));
  Dataset.FieldByName('OBJECTNAME').AsString :=
    UnQuoteString(ConvertUTFToAnsi(GetParamValueByName(ElementStr, 'objectname')));
  Dataset.FieldByName('MASTERCATEGORY').AsString :=
    UnQuoteString(ConvertUTFToAnsi(GetParamValueByName(ElementStr, 'mastercategory')));
  Dataset.FieldByName('MASTERNAME').AsString :=
    UnQuoteString(ConvertUTFToAnsi(GetParamValueByName(ElementStr, 'mastername')));
  Dataset.FieldByName('OBJECTORDER').AsString := GetParamValueByName(ElementStr, 'objectorder');
  Dataset.FieldByName('WITHDETAIL').AsString := GetParamValueByName(ElementStr, 'withdetail');
  Dataset.FieldByName('NEEDMODIFY').AsString := GetParamValueByName(ElementStr, 'needmodify');
  Dataset.FieldByName('AUTOADDED').AsString := GetParamValueByName(ElementStr, 'autoadded');
  Dataset.FieldByName('OBJECTCLASS').AsString := UnQuoteString(GetParamValueByName(ElementStr, 'objectclass'));
  Dataset.FieldByName('SUBTYPE').AsString := UnQuoteString(GetParamValueByName(ElementStr, 'subtype'));
  Dataset.FieldByName('XID').AsString := GetParamValueByName(ElementStr, 'xid');
  Dataset.FieldByName('DBID').AsString := GetParamValueByName(ElementStr, 'dbid');
  Dataset.FieldByName(XID_FIELD).AsString := GetParamValueByName(ElementStr, '_xid');
  Dataset.FieldByName(DBID_FIELD).AsString := GetParamValueByName(ElementStr, '_dbid');
  //Dataset.FieldByName(MODIFIED_FIELD).AsDateTime := Time;
  Dataset.Post;
end;

procedure TgdcStreamXMLWriterReader.InternalSaveToStream;
var
  I, K: Integer;
  IBSQL: TIBSQL;
begin
    // ��������� XML-���������
  if FDoInsertXMLHeader then
    StreamWriteXMLString(Stream, xmlHeader + NEW_LINE);
  // ������� �������� ��� ���������
  StreamWriteXMLString(Stream, AddOpenTag(XML_TAG_STREAM));
  StreamWriteXMLString(Stream, AddOpenTag(XML_TAG_HEADER));
  // ������ ������
  StreamWriteXMLString(Stream, AddElement(XML_TAG_VERSION, IntToStr(cst_StreamVersionNew)));
  // DBID
  StreamWriteXMLString(Stream, AddElement(XML_TAG_DBID, IntToStr(IBLogin.DBID)));

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
        StreamWriteXMLString(Stream, AddOpenTag(XML_TAG_DATABASE_LIST));
        while not IBSQL.Eof do
        begin
          AddAttribute('id', IntToStr(IBSQL.FieldByName('ID').AsInteger));
          AddAttribute('name', QuoteString(IBSQL.FieldByName('NAME').AsString));
          StreamWriteXMLString(Stream, AddShortElement(XML_TAG_DATABASE));
          IBSQL.Next;
        end;
        StreamWriteXMLString(Stream, AddCloseTag(XML_TAG_DATABASE_LIST));
      end;
    finally
      IBSQL.Free;
    end;

    // ID (�� ������� RPL_DATABASE) ���������� ����� ����
    StreamWriteXMLString(Stream, AddElement(XML_TAG_SENDER, IntToStr(FDataObject.OurBaseKey)));
    // ID (�� ������� RPL_DATABASE) ����������� ����� ����
    StreamWriteXMLString(Stream, AddElement(XML_TAG_RECEIVER, IntToStr(FDataObject.TargetBaseKey)));

    // ����� ������� RUID'� �������, ��������� ������� �� ������������
    I := FDataObject.ReceivedRecordsCount;
    if I > 0 then
    begin
      StreamWriteXMLString(Stream, AddOpenTag(XML_TAG_RECEIVED_RECORD_LIST));
      for K := 0 to I - 1 do
      begin
        AddAttribute('xid', IntToStr(FDataObject.ReceivedRecord[K].XID));
        AddAttribute('dbid', IntToStr(FDataObject.ReceivedRecord[K].DBID));
        StreamWriteXMLString(Stream, AddShortElement(XML_TAG_RECEIVED_RECORD));
      end;
      StreamWriteXMLString(Stream, AddCloseTag(XML_TAG_RECEIVED_RECORD_LIST));
    end;
  end;

  // ����� ������� RUID'� � ID �������, ������� �� ����� � ������������ �����,
  //   �.�. ��� ������������ �� ������� ����
  I := FDataObject.ReferencedRecordsCount;
  if I > 0 then
  begin
    StreamWriteXMLString(Stream, AddOpenTag(XML_TAG_REFERENCED_RECORD_LIST));
    for K := 0 to I - 1 do
    begin
      AddAttribute('id', IntToStr(FDataObject.ReferencedRecord[K].SourceID));
      AddAttribute('xid', IntToStr(FDataObject.ReferencedRecord[K].RUID.XID));
      AddAttribute('dbid', IntToStr(FDataObject.ReferencedRecord[K].RUID.DBID));
      StreamWriteXMLString(Stream, AddShortElement(XML_TAG_REFERENCED_RECORD));
    end;
    StreamWriteXMLString(Stream, AddCloseTag(XML_TAG_REFERENCED_RECORD_LIST));
  end;

  // ������� �������� �������, ����������� � ������ ������
  StreamWriteXMLString(Stream, AddOpenTag(XML_TAG_LOADING_ORDER));
  with FLoadingOrderList do
    for K := 0 to Count - 1 do
    begin
      AddAttribute('index', IntToStr(Items[K].Index));
      AddAttribute('objectkey', IntToStr(Items[K].DSIndex));
      AddAttribute('recordid', IntToStr(Items[K].RecordID));
      StreamWriteXMLString(Stream, AddShortElement(XML_TAG_LOADING_ORDER_ITEM));
    end;
  StreamWriteXMLString(Stream, AddCloseTag(XML_TAG_LOADING_ORDER));

  // ������� ��� ��������� ���������
  StreamWriteXMLString(Stream, AddCloseTag(XML_TAG_HEADER));

  // ������� ��� ������ ���������
  StreamWriteXMLString(Stream, AddOpenTag(XML_TAG_DATA));
  for K := 0 to FDataObject.Count - 1 do            //FDataObject.gdcObject[FCurrentDatasetKey].Classname
  begin
    if FDataObject.ClientDS[K].RecordCount > 0 then
    begin                                                    
      FCurrentDatasetKey := K;
      try
        AddAttribute('objectkey', IntToStr(K));
        AddAttribute('classname', QuoteString(FDataObject.gdcObject[K].Classname));
        AddAttribute('subtype', QuoteString(FDataObject.gdcObject[K].SubType));
        AddAttribute('settable', QuoteString(FDataObject.ClientDS[K].FieldByName(SET_TABLE_FIELD).AsString));
        StreamWriteXMLString(Stream, AddOpenTag(XML_TAG_DATASET));

        SaveDataset(DataObject.ClientDS[K]);

        StreamWriteXMLString(Stream, AddCloseTag(XML_TAG_DATASET));
      finally
        FCurrentDatasetKey := -1;
      end;
    end;
  end;
  // ������� ��� ������ ���������
  StreamWriteXMLString(Stream, AddCloseTag(XML_TAG_DATA));
  // ������� �������� ��� ���������
  StreamWriteXMLString(Stream, AddCloseTag(XML_TAG_STREAM));
end;

procedure TgdcStreamXMLWriterReader.InternalSaveSettingToStream;
var
  CDS: TDataSet;
  AutoAddedExists: Boolean;
begin
  // ��������� XML-���������
  StreamWriteXMLString(Stream, xmlHeader + NEW_LINE);
  // ������� �������� ��� ���������
  StreamWriteXMLString(Stream, AddOpenTag(XML_TAG_SETTING));
  CDS := FDataObject.ClientDS[FDataObject.GetObjectIndex('TgdcSetting')];
  // ������� ��� ��������� ���������
  AddAttribute('name', QuoteString(CDS.FieldByName('NAME').AsString));
  AddAttribute('version', CDS.FieldByName('VERSION').AsString);
  AddAttribute('modifydate', SafeDateTimeToStr(CDS.FieldByName('MODIFYDATE').AsDateTime));
  AddAttribute('xid', CDS.FieldByName(XID_FIELD).AsString);
  AddAttribute('dbid', CDS.FieldByName(DBID_FIELD).AsString);
  AddAttribute('description', QuoteString(CDS.FieldByName('DESCRIPTION').AsString));
  AddAttribute('ending', CDS.FieldByName('ENDING').AsString);
  AddAttribute('settingsruid', CDS.FieldByName('SETTINGSRUID').AsString);
  AddAttribute('minexeversion', CDS.FieldByName('MINEXEVERSION').AsString);
  AddAttribute('mindbversion', CDS.FieldByName('MINDBVERSION').AsString);
  StreamWriteXMLString(Stream, AddOpenTag(XML_TAG_SETTING_HEADER));

  // ������� ������ ���������
  StreamWriteXMLString(Stream, AddOpenTag(XML_TAG_SETTING_POS_LIST));
  CDS := FDataObject.ClientDS[FDataObject.GetObjectIndex('TgdcSettingPos')];
  if not CDS.IsEmpty then
  begin
    AutoAddedExists := Assigned(atDatabase.FindRelationField('AT_SETTINGPOS', 'AUTOADDED'));
    TClientDataset(CDS).IndexFieldNames := 'OBJECTORDER';
    CDS.First;
    while not CDS.Eof do
    begin
      AddAttribute('category', QuoteString(CDS.FieldByName('CATEGORY').AsString));
      AddAttribute('objectname', QuoteString(CDS.FieldByName('OBJECTNAME').AsString));
      AddAttribute('mastercategory', QuoteString(CDS.FieldByName('MASTERCATEGORY').AsString));
      AddAttribute('mastername', QuoteString(CDS.FieldByName('MASTERNAME').AsString));
      AddAttribute('objectorder', CDS.FieldByName('OBJECTORDER').AsString);
      AddAttribute('withdetail', CDS.FieldByName('WITHDETAIL').AsString);
      AddAttribute('needmodify', CDS.FieldByName('NEEDMODIFY').AsString);
      if AutoAddedExists then
        AddAttribute('autoadded', CDS.FieldByName('AUTOADDED').AsString);
      AddAttribute('objectclass', QuoteString(CDS.FieldByName('OBJECTCLASS').AsString));
      AddAttribute('subtype', QuoteString(CDS.FieldByName('SUBTYPE').AsString));
      AddAttribute('xid', CDS.FieldByName('XID').AsString);
      AddAttribute('dbid', CDS.FieldByName('DBID').AsString);
      AddAttribute('_xid', CDS.FieldByName(XID_FIELD).AsString);
      AddAttribute('_dbid', CDS.FieldByName(DBID_FIELD).AsString);

      StreamWriteXMLString(Stream, AddShortElement(XML_TAG_SETTING_POS));
      CDS.Next;
    end;
  end;
  StreamWriteXMLString(Stream, AddCloseTag(XML_TAG_SETTING_POS_LIST));

  // ������� ��� ��������� ���������
  StreamWriteXMLString(Stream, AddCloseTag(XML_TAG_SETTING_HEADER));

  CDS := FDataObject.ClientDS[FDataObject.GetObjectIndex('TgdcSetting')];
  // ������ ���������
  StreamWriteXMLString(Stream, AddOpenTag(XML_TAG_SETTING_DATA));
  // ������ ��������� ��� ��������������� � UTF8, ������� ������ �������������� �� ����
  StreamWriteXMLString(Stream, CDS.FieldByName('DATA').AsString, False);
  StreamWriteXMLString(Stream, AddCloseTag(XML_TAG_SETTING_DATA));

  StreamWriteXMLString(Stream, AddCloseTag(XML_TAG_SETTING));
end;

class procedure TgdcStreamXMLWriterReader.StreamWriteXMLString(St: TStream;
  const S: String; const DoConvertToUTF8: Boolean = True);
var
  L: Integer;
  AnsiStr: AnsiString;
begin
  // ��� ������������� ���������������� ������ � UTF8
  if DoConvertToUTF8 then
    AnsiStr := WideStringToUTF8(StringToWideStringEx(S, WIN1251_CODEPAGE))
  else
    AnsiStr := S;

  L := Length(AnsiStr);
  if L > 0 then
    St.Write(AnsiStr[1], L);
end;

class function TgdcStreamXMLWriterReader.ConvertUTFToAnsi(AUTFStr: AnsiString): String;
begin
  Result := WideStringToStringEx(UTF8ToWideString(AUTFStr), WIN1251_CODEPAGE);
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

  FSavingSettingData := False;
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
    sttBinaryNew: FStreamWriterReader := TgdcStreamBinaryWriterReader.Create(FDataObject, FStreamLoadingOrderList);
    sttXML:
    begin
      FStreamWriterReader := TgdcStreamXMLWriterReader.Create(FDataObject, FStreamLoadingOrderList);
      // ���� ����������� ������ ���������
      if FSavingSettingData then
      begin
        // ������� ��������� ������ � ������� XML �����, ����� ����� ������� ��������� � ������ ���������
        (FStreamWriterReader as TgdcStreamXMLWriterReader).ElementLevel := 2;
        // �� ����� ��������� ��������� XML �����
        (FStreamWriterReader as TgdcStreamXMLWriterReader).DoInsertXMLHeader := False;
      end;
    end;
  else
    FStreamWriterReader := TgdcStreamBinaryWriterReader.Create(FDataObject, FStreamLoadingOrderList);
  end;

  try
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
      FStreamWriterReader.LoadFromStream(S);
    finally
      FStreamWriterReader.Free;
    end;

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

  // ������� ������ � �������
  FErrorMessageForSetting := '';
end;


procedure TgdcStreamSaver.SaveSettingDataToStream(S: TStream; ASettingKey: TID);
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
    Assert(Assigned(S));
    Assert(ASettingKey > -1);

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

      // �������� ��������� ������ � ����� � ��������� �������
      FSavingSettingData := True;
      Self.SaveToStream(S);
      FSavingSettingData := False;

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


procedure TgdcStreamSaver.LoadSettingDataFromStream(S: TStream; var WasMetaDataInSetting: Boolean;
  const DontHideForms: Boolean; var AnAnswer: Word);

var
  RelName: String;
  Obj: TgdcBase;
  CDS: TDataSet;
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

  procedure RunMultiConnection;
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
    frmStreamSaver.SetupProgress(FStreamLoadingOrderList.Count, '��������� ���������...');

  if Assigned(frmSQLProcess) then
  begin
    with frmSQLProcess.pb do
    begin
      Min := 0;
      Max := FStreamLoadingOrderList.Count;
      Position := 0;
    end;
  end;

  // ����� ����� ������������ �� ������ � ������ �������� (���� ������ ���������)
  if AnAnswer <> mrNone then
    FStreamDataProvider.ReplaceRecordAnswer := AnAnswer;
  try

    // ��������� ������ �� ������ �� ����
    while FStreamLoadingOrderList.PopNextElement(OrderElement) do
    begin
      Obj := FDataObject.gdcObject[OrderElement.DSIndex];

      if (Obj.InheritsFrom(TgdcMetaBase)) then
      begin
        WasMetaData := True;
        {��������, ��� � ��������� ���� ����-������}
        WasMetaDataInSetting := True;
      end
      else
      begin
        if WasMetaData then
        begin
          if not (SilentMode or IsReplicationMode) then
            ReconnectDatabase;
        end;

        WasMetaData := False;
      end;

      //��� LogOff �� ������� ReadTransaction. ��������� �� �����, �.�. ��� ������������ ��� �������� gdc-��������
      ConnectDatabase;
      RunMultiConnection;

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
              FErrorMessageForSetting := FErrorMessageForSetting + IntToStr(GetLastError) + ': ' + E.Message + ' ' + Obj.ClassName + '_' + Obj.SubType + #13#10;
              if Obj.State in [dsEdit, dsInsert] then
                Obj.Cancel;
            end;
          end;
        end;
      end
      else
        raise Exception.Create('� ������ �� ������� ������:'#13#10 +
          Obj.Classname + ' ' + Obj.SubType + ' (' + IntToStr(OrderElement.RecordID) + ')');

      if Assigned(frmStreamSaver) then
        frmStreamSaver.Step;

      if Assigned(frmSQLProcess) then
        frmSQLProcess.pb.Position := frmSQLProcess.pb.Position + 1;
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

    RunMultiConnection;
    // ������ ��������� ������������� ����� �� ������ � ������ ��������
    AnAnswer := FStreamDataProvider.ReplaceRecordAnswer;

    if Assigned(frmStreamSaver) then
      frmStreamSaver.Done;

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


procedure TgdcStreamSaver.LoadSettingStorageFromStream(S: TStream; var AnStAnswer: Word);
var
  StreamWriterReader: TgdcStreamWriterReader;
begin
  if S.Size > 0 then
  begin
    if StreamLoggingType in [slSimple, slAll] then
      AddText('������ �������� ���������', clBlack);

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
      AddText('��������� �������� ���������', clBlack);
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
      AddText('������ ���������� ���������', clBlack);

    ibsqlPos := TIBSQL.Create(nil);
    try
      ibsqlPos.Transaction := FTransaction;
      ibsqlPos.SQL.Text := 'SELECT * FROM at_setting_storage WHERE settingkey = :settingkey AND (NOT branchname LIKE ''#%'')';
      ibsqlPos.ParamByName('settingkey').AsInteger := ASettingKey;
      ibsqlPos.ExecQuery;

      if FStreamFormat <> sttBinaryNew then
      begin
        while not ibsqlPos.Eof do
        begin
          FStreamDataProvider.SaveStorageItem(ibsqlPos.FieldByName('branchname').AsString,
            ibsqlPos.FieldByName('valuename').AsString);

          ibsqlPos.Next;
        end;

        FStreamWriterReader := TgdcStreamXMLWriterReader.Create(FDataObject);
        try
          (FStreamWriterReader as TgdcStreamXMLWriterReader).ElementLevel := 2;
          FStreamWriterReader.SaveStorageToStream(S);
        finally
          FStreamWriterReader.Free;
        end;

      end
      else
      begin
        // ���������� � �������� ������� ������� ���� �� �������
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
                  AddText('���������� ��������� ' + ibsqlPos.FieldByName('valuename').AsString +
                    ' ����� ��������� ' + BranchName, clBlue);
              end else
                raise EgdcIBError.Create(' �������� ' +
                  ibsqlPos.FieldByName('valuename').AsString +
                  ' ����� ��������� ' + BranchName + ' �� ������!');
            end else
            begin
              L :=  Length(BranchName);
              S.WriteBuffer(L, Sizeof(L));
              S.WriteBuffer(BranchName[1], L);
              NewFolder.SaveToStream(S);

              if StreamLoggingType = slAll then
                AddText('���������� ����� ��������� ' + BranchName, clBlue);
            end;
            LStorage.CloseFolder(NewFolder);
          end else
            raise EgdcIBError.Create(
              '����� ��������� "' + BranchName + '" �� �������!'#13#10#13#10 +
              '� ��������� ����� ��������� ������ ����� ��� ���������'#13#10 +
              '����������� ��������� ��� ��������� ������������ �������������.');

          ibsqlPos.Next;
        end;
      end;

    finally
      ibsqlPos.Free;
    end;

    if StreamLoggingType in [slSimple, slAll] then
      AddText('��������� ���������� ���������', clBlack);
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
  CDS: TDataSet;
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
        {���� ��� �������� ���������� id ���������, �� ����� ���������,
         ������ �� ���� � ������� ���������
         ���������� ��� ���������� ������ ������ ��������� ���������,
         ����� �� ������� �������� ������, ������� ����������� ����� �� ������� �������
         ��������, ������ ��������� ����� ����� ������������ ���� one, two,
         ������� ������ ���� � ������ ���������.
         ��� ����� ����������� ��������� ����� ������������ ������ ���� ���� two
         ����� �������� �� ��������� ���� One, �������� �� ��������� ��������� =>
         �������� � ������ ������ ������ ���� ���������.}
          StPos.Close;
          StPos.ParamByName('xid').AsString := CDS.FieldByName(XID_FIELD).AsString;
          StPos.ParamByName('dbid').AsString := CDS.FieldByName(DBID_FIELD).AsString;
          StPos.Open;
          if StPos.RecordCount > 0 then
          begin
            RuidList.Add(CDS.FieldByName(XID_FIELD).AsString + ',' +
              CDS.FieldByName(DBID_FIELD).AsString + ',' + AnsiUpperCase(Trim(Obj.ClassName)) +
              ','+ AnsiUpperCase(Trim(Obj.SubType)));
          end;
        end
        else
        begin
          RuidList.Add(CDS.FieldByName(XID_FIELD).AsString + ',' +
            CDS.FieldByName(DBID_FIELD).AsString + ',' + AnsiUpperCase(Trim(Obj.ClassName)) +
            ','+ AnsiUpperCase(Trim(Obj.SubType)));
        end

      else
        raise Exception.Create('� ������ �� ������� ��������� ������:'#13#10 +
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
    FStreamDataProvider.ClearNowSavedRecordsList;
    FStreamDataProvider.SaveRecord(ObjectIndex, AID, AWithDetail);
  except
    if FTransaction.InTransaction then
      FTransaction.Rollback;
    raise;
  end;
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
