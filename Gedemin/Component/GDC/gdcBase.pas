(*

������������.

�� �������� ������, ���� ���� ���� aview � ��� ���� � ������������
�� �������� ������.

���� ���� ���� achag � � ������������ ��� ���� �� ���������, �� �� ������
�������������, ����������, �������.

���� ���� ���� afull � � ������������ ��� ����, �� �� ������ �����������
�������.

����������� ������ �������� � ��� ����� �������� �� �����. �� ������
������������ ��������������, ������� ����� �������� �� ����� ������������.

���������� ���� �� ���������.

�� ������ ��������� ����-�������� ��� �������� ������:

�������� �������, ��������/���������, ��������, ����� ���� ������� � ������.
��� ��������� ����� ������
� ���������� ����. ����� ������ ��� ��������� �������� �� ��������:
�� ��������� �� ���, ���� �� ����� � ������������ �� ���, ���� ��
����� � ������������ �� ���������� �������� �������� ��� ������� �������.

� ������� ��_��������� �� ������� ����� GDC.
��� ���� �������� ������� ��������: 7000000-7999999
��� ������� ������� ��������� �������� � ������������ ���������������.
��. � ���� ����� ���� ���������, �������������� � ������
�� + 2, + 4 � �.�.
��� �������� -- ������� �� ������, ��������, ���������, ��������, ����� ����,
������.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~
��� ����������� ������-��������� �� ������ ����������� ��� ������-�������.
����������, ��� ������-��������� ������ ����� ����� ������� �������.
����� ��� ����������� �� ������ ������� ��������������� ������,
� ������� ����� ����, �������� � ���� �������.

��� ����, ����� ������ ������-������ ������� ��� ����� ���������� �����
����� ���� � ���� ������� �������� �� ����� � ������ ��������.


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

���������� ������������. �� ������ �� ������� ����. ��� ���� ����� ������ �����������
�� ��������� ���������.

1. ������ ������ ������ �������� ���� ����������.
2. ��������� ����� ������-������ ������� ����� ����� ����������.
3. ���������� ����������� ������������� ��� �������� ��������.
4. ��� �������� �������� ���������� �� ����������� �����, � ����� ��������� �����.
5. �� ��������� ������ ������-������ ������� ����� ������ ����������.
   ��������, ���� ��� �������������� ������ ���������� ���������� ����, �
   � ��� ���� ������, ��������� � ������ ���������, �� ��� ��������������
   ��� �������� ����������� ���� ����������. �.�. �� ����� � ������, �������
   �����, �������� � ��� ������. ����� ������ ���� ������ ������� ����������.
   ������ ���������. � �� ����������� ���� ������ ����� �� ������. � ���� ������
   � ����� ������-������� ��������� �� ����������, � � ���, ��� ��� � ������ --
   ����������. ��� �� ������ �����������.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

���������� ����� �� ����� �������� � ������� ����� -- ��� ������ ��������,
���������� �������. ����� ��� ����? ��������, � ������ ������ ������ � ����� �����
����� ������������ �� ������������. ��� ����������� ����������� ��� ������ ���������,
������ ��� ��������, � ������� � ����������� ������� ����������� �������
���������� ������� ����� � ������� ������ � ���������� ���� �� ������ ���������.
����, ����� � ���� ������ ���������� �� �����������. �.�. ����� ������ ��������
������-������ � ���� ��� �������� ���, ��� ���������� �������, �� ���������� �� ���������.

������, ��� �� ����� �����, ��� ���������� �������? ��������� ��� ����� ������
������������� � ������������. ������ ������, ��� ������, �������� �� ���� �
����������. ������������ ��� ���������� ������ �����������.

             01-11-2001  sai     1. ��������� ��� ������ ��� ������ � ������ ��������
                                 TgdcFindObject, TgdcFindObjectList
                                 2. ���������� ������ Find, Choose, ChooseElement
                                 3. ��������� ����� ������ gdc_dlgFind
             17-11-2001 Michael  ��������� ������� OnAfterInitSQL - ��� ����������� ���������
                                 ������, ������� ���������� ������.
             18-06-2002 Julie    1. ������� ��� ������ ��� ������ � ������� ��������
                                 TgdcFindObject, TgdcFindObjectList
                                 2. ������� ������ Find, Choose, ChooseElement
                                 3. ������� ����� ������ gdc_dlgFind
             25-06-2002 DAlex    ������������� ������ ���������� �������

             11-09-2003 Yuri     1. ������� CorrectFileName � gd_common_functions.pas;
                                 2. ������� ������������� HideFieldsList ��� ����������� �������.
*)

unit gdcBase;

interface

uses
  Classes,              Windows,               Controls,         DB,
  IB,                   IBHeader,              IBDatabase,       IBCustomDataSet,
  IBSQL,                SysUtils,              DBGrids,          Forms,
  gdcBaseInterface,     Contnrs,               Clipbrd,          MSScriptControl_TLB,
  menus,                flt_QueryFilterGDC,    at_sql_setup,     gd_createable_form,
  ActnList,             gsStorage,             gd_KeyAssoc,      ExtCtrls,
  Graphics,             mtd_i_Base,            evt_i_Base,       zlib,
  gdcConstants,         Registry,              gsStreamHelper,   gd_directories_const;

resourcestring
  strHaventRights =
    '����������� ����� ������� �� ���������� ��������: %s'#13#10#13#10'�����: %s'#13#10'������: %s'#13#10'��������: %s';
  strHaventRightsShort =
    '����������� ����� ������� �� ���������� ��������: %s'#13#10#13#10'�����: %s';
  strCreate = '�������� �������';
  strView = '��������';
  strEdit = '�������������� �������';
  strPrint = '������ �������';
  strDelete = '�������� �������';
  strChangeRights = '��������� ����';

const
  ////////////////////////////////////////////////////////////
  // ��������� �������� ��������, ������������ ������� �����
  GDC_OP_ACCESS          =  2;
  GDC_OP_CREATE          =  4;
  GDC_OP_CHANGE          =  6;
  GDC_OP_DELETE          =  8;
  GDC_OP_PRINT           = 10;
  GDC_OP_CHANGERIGHT     = 12;

  //
  CST_REPORTCAPTION      = '������';
  CST_REPORTGROUPID      = -1;
  CST_REPORTREGISTRYLIST = '�������� ������-��������';

  CST_MACROSMENU         = '�������� ������-��������';

  // �������� ����� �� ������� ����������� ���������� �������
  GDC_SC_MACROSMODULE    = 'frmExplorer';
  GDC_SC_TYPEEVENT       = 'E';
  GDC_SC_TYPEMACROS      = 'M';
  CST_ALL                = 'All';

  // ����� �������, ��� ������� ����������� ���������� ���������
  GDC_CUSTOMINSERT       = 'CUSTOMINSERT';
  GDC_CUSTOMMODIFY       = 'CUSTOMMODIFY';
  GDC_CUSTOMDELETE       = 'CUSTOMDELETE';
  GDC_DOAFTERDELETE      = 'DOAFTERDELETE';
  GDC_DOAFTERINSERT      = 'DOAFTERINSERT';
  GDC_DOAFTEREDIT        = 'DOAFTEREDIT';
  GDC_DOAFTEROPEN        = 'DOAFTEROPEN';
  GDC_DOAFTERPOST        = 'DOAFTERPOST';
  GDC_DOAFTERCANCEL      = 'DOAFTERCANCEL';
  GDC_DOBEFORECLOSE      = 'DOBEFORECLOSE';
  GDC_DOBEFOREDELETE     = 'DOBEFOREDELETE';
  GDC_DOBEFOREEDIT       = 'DOBEFOREEDIT';
  GDC_DOBEFOREINSERT     = 'DOBEFOREINSERT';
  GDC_DOBEFOREPOST       = 'DOBEFOREPOST';
  GDC_DOAFTERTRANSACTIONEND = 'DOAFTERTRANSACTIONEND';
  GDC_GETNOTCOPYFIELD    = 'GETNOTCOPYFIELD';
  GDC_GETDIALOGDEFAULTSFIELDS = 'GETDIALOGDEFAULTSFIELDS';


  // ����� �������, � ������� ������������ ������ ���������
  GDC_BASE               = 'TGDCBASE';

  cCut                   = True;
  cCopy                  = False;

  //������ ���������� � ������ �-�
  cst_StreamVersion = 2;
  cst_WithVersion   = 'SAVE_TO_STREAM_WITH_VERSION';
  cst_StreamLabel = $55443322;

  //
  DefQueryFiltered = False;

  //
  ValidCharsForNames: set of char = ['A'..'Z', 'a'..'z', '0'..'9', '$', '_'];

type
  /////////////////////////////////////////////////////////////
  // ���� �������, �������������� ������ ��������
  TgdcEventTypes = (etAfterCancel, etAfterClose, etAfterDelete, etAfterEdit,
                 etAfterInsert, etAfterOpen, etAfterPost, etAfterRefresh,
                 etAfterScroll, etBeforeCancel, etBeforeClose, etBeforeDelete,
                 etBeforeEdit, etBeforeInsert, etBeforeOpen, etBeforePost,
                 etBeforeRefresh, etBeforeScroll, etOnCalcFields, etOnNewRecord,
                 etOnFieldChange, etAfterInternalPostRecord, etBeforeInternalPostRecord,
                 etAfterInternalDeleteRecord, etBeforeInternalDeleteRecord);

const
  /////////////////////////////////////////////////////////////
  // ������������ ����� �������
  gdcEventTypesString: array[TgdcEventTypes] of String =
                ('AfterCancel', 'AfterClose', 'AfterDelete', 'AfterEdit',
                 'AfterInsert', 'AfterOpen', 'AfterPost', 'AfterRefresh',
                 'AfterScroll', 'BeforeCancel', 'BeforeClose', 'BeforeDelete',
                 'BeforeEdit', 'BeforeInsert', 'BeforeOpen', 'BeforePost',
                 'BeforeRefresh', 'BeforeScroll', 'OnCalcFields', 'OnNewRecord',
                 'OnFieldChange', 'AfterInternalPostRecord', 'BeforeInternalPostRecord',
                 'AfterInternalDeleteRecord', 'BeforeInternalDeleteRecord');

// ��� ��� �������� ������� ������� ���������� ����� ���������� InitSQL
// SQLText - ����� �������
// isReplaceSQL - �������� ��������� InitSQL ������ �� SQLText ��� ���

type
  TgdcAfterInitSQL = procedure (Sender: TObject;
    var SQLText: String; var isReplaceSQL: Boolean) of object;

  // ����������� ����� ���������� ���������� ���� ����� ������
  // ������� ��� �������������� �������
  TgdcDoBeforeShowDialog = procedure (Sender: TObject;
    DlgForm: TCustomForm) of object;

  // ����������� ����� �������� ���������� ���� ����� ������
  // ������� ��� �������������� �������
  TgdcDoAfterShowDialog = procedure (Sender: TObject;
    DlgForm: TCustomForm; IsOk: Boolean) of object;

  TgdcOnGetSQLClause = procedure(Sender: TObject; var Clause: String) of Object;

type
  /////////////////////////////////////////////////////////////
  //  ��������� �������
  TgdcState = (
    sNone,
    sView,           // ������ ��������� � �����
    sDialog,         // ������ ��������� � ����������� ����
    sSubDialog,
    sSyncControls,
    sLoadFromStream, // ���� �������� �� ������
    sMultiple,       // ���� ��������� ������������ ���������� �������
    sFakeLoad,       // ���������� ������ � ������ ��� ������ � ����
    sPost,           // ����������, ���� ���� Cancel ������ �����
                     // ����� ������, ���� ������ ���������� � ����� ��������������
                     // � ����� ��������, �� ��� ���� � ��� ������ �� ��������
    sCopy,           // ������ � ��������� ����������� ������ �� ������� �������
    sSkipMultiple,   // ���� ��������� ���������� ������� � ������������ ������ �������
                     // ���������� �������. ����� ����� ������ � ������������ �
                     // ������ sMultiple
    sAskMultiple     // ���� ��������� ���������� ������� � ������������ ����������
                     // �������� � ������ ������������� �������. ����� ����� ������
                     // � ������������ � ������ sMultiple
  );
  TgdcStates = set of TgdcState;

  TgdcBase = class;
  CgdcBase = class of TgdcBase;
                    
  //��� ��� �������� ������ ����������� �� ������
  TgsStreamRecord = record
    StreamVersion: Integer;
    StreamDBID: Integer;
  end;

  TOnFakeLoad = procedure(Sender: TgdcBase; CDS: TDataSet)
    of object;

  //////////////////////////////////////////////////////////
  // ��������� ������ ������� ������ ������ �������
  // ������������� �������� ���������� ������ ������� �
  // �������, ������ ������, ������� ����� ��������������
  // ��� ��������/�������� ����� ����������
  TgdcFullClass = record
    gdClass: CgdcBase;
    SubType: TgdcSubType;
  end;

  //
  TgdcSetAttribute = class(TObject)
  private
    FCrossRelationName: String;
    FReferenceRelationName: String;
    FObjectLinkFieldName: String;
    FReferenceLinkFieldName: String;
    FReferenceObjectNameFieldName: String;
    FSQL, FInsertSQL: String;
    FCaption: String;
    FHasAdditionalFields: Boolean;

  public
    constructor Create(const ACrossRelationName: String;
      const AReferenceRelationName: String;
      const AObjectLinkFieldName: String;
      const AReferenceLinkFieldName: String;
      const AReferenceObjectNameFieldName: String;
      const ASQL: String;
      const AnInsertSQL: String;
      const ACaption: String;
      const AHasAdditionalFields: Boolean);

    property CrossRelationName: String read FCrossRelationName;
    property ReferenceRelationName: String read FReferenceRelationName;
    property ObjectLinkFieldName: String read FObjectLinkFieldName;
    property ReferenceLinkFieldName: String read FReferenceLinkFieldName;
    property ReferenceObjectNameFieldName: String read FReferenceObjectNameFieldName;
    property SQL: String read FSQL;
    property InsertSQL: String read FInsertSQL;
    property Caption: String read FCaption;
    property HasAdditionalFields: Boolean read FHasAdditionalFields;
  end;

  TgdcCompoundClass = class(TObject)
  private
    FgdClass: CgdcBase;
    FSubType: TgdcSubType;
    FLinkRelationName, FLinkFieldName: String;

  public
    constructor Create(const AgdClass: CgdcBase;
      const ASubType: TgdcSubType;
      const ALinkRelationName: String;
      const ALinkFieldName: String);

    property gdClass: CgdcBase read FgdClass;
    property SubType: TgdcSubType read FSubType;
    property LinkRelationName: String read FLinkRelationName;
    property LinkFieldName: String read FLinkFieldName;
  end;

  //
  TgdcObjectSet = class
  private
    FgdClass: CgdcBase;
    FSubType: TgdcSubType;
    //ID ������ �������� � ��� �� �������, � ������� ��� ���� ��������
    FArray: array of TID;
    FgdClassList: TStringList;
    FCount: Integer;
    FMin, FMax: TID;
             
    function Get_gdClass: CgdcBase;
    function Get_gdClassName: String;
    function GetCount: Integer;
    function GetItems(Index: Integer): TID;
    procedure Set_gdClass(const Value: CgdcBase);
    function GetSize: Integer;
    function GetSubType: TgdcSubType;
    procedure SetSubType(const Value: TgdcSubType);

    function FormClassSubTypeString(const gdClassName, SubType, ASetTable: String): String;
    function GetgdInfo(Index: Integer): String;

  public
    constructor Create(AgdClass: CgdcBase; const ASubType: TgdcSubType; const ASize: Integer = 32);
    destructor Destroy; override;

    function Add(const AnID: TID; const AgdClassName: String;
       const ASubType: String; const ASetTable: String ): Integer;
    procedure AddgdClass(const Index: Integer; const AgdClassName: String;
      const ASubType: String; const ASetTable: String);

    function Find(const AnID: TID): Integer;
    function FindgdClass(const Index: Integer; const AgdClassName: String;
      const ASubType: String; const ASetTable: String): Boolean;
    function FindgdClassByID(const AnID: TID; const AgdClassName: String;
      const ASubType: String; const ASetTable: String): Boolean;

    procedure Remove(const AnID: TID);
    procedure Delete(const Index: Integer);

    procedure LoadFromStream(S: TStream);
    procedure SaveToStream(S: TStream);

    property gdClass: CgdcBase read Get_gdClass write Set_gdClass;
    property gdClassName: String read Get_gdClassName;
    property SubType: TgdcSubType read GetSubType write SetSubType;
    property Items[Index: Integer]: TID read GetItems; default;
    property gdInfo[Index: Integer]: String read GetgdInfo;
    property Count: Integer read GetCount;
    property Size: Integer read GetSize;

    function GetClassFromString(const AText: String): String;
    function GetSubTypeFromString(const AText: String): String;
    function GetSetTableFromString(const AText: String): String;
  end;

  TgdcObjectSets = class(TObjectList)
  public
    constructor Create;

    function Find(C: TgdcFullClass): TgdcObjectSet;

    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
  end;

  //////////////////////////////////////////////////////////
  // ��� �� ����_����� ������ �������� �������� ���� ��������,
  // ���_� �� ������ _ ������ ���� ��� ������_���� ��������
  TgdcBaseManager = class(TComponent, IgdcBaseManager)
  private
    FIBBase: TIBBase;
    FReadTransaction: TIBTransaction;
    FExplorer: TgdcBase;
    FNextIDSQL: TIBSQL;
    FIBSQL: TIBSQL;
    FIDCurrent, FIDLimit: Integer;

    // �� ������ ����� ���� ������ �� ���� ��������� � �������
    // ������ -- ��������� �� �����
    // ������ -- ��������� �� ������ -- ������
    // ��������� ��� -- ����������� ������������
    // � ��������� ������� aview, achag, afull
    FSecDescArr: array of array of Integer;

    function GetDatabase: TIBDatabase;
    procedure SetDatabase(const Value: TIBDatabase);
    function GetExplorer: IgdcBase;
    procedure SetExplorer(const Value: IgdcBase);

    function GetReadTransaction: TIBTransaction;

    procedure LoadSecDescArr(AnExplorer: TgdcBase);
    procedure SortSecDescArr;
    procedure RemoveDuplicates;
    function IndexOfClass(C: TClass; const ASubType: TgdcSubType): Integer;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    //  TZCompressionLevel = (zcNone, zcFastest, zcDefault, zcMax);
    procedure PackStream(SourceStream, DestStream: TStream; CompressionLevel: TZCompressionLevel);
    procedure UnPackStream(SourceStream, DestStream: TStream);

    function GetIDByRUID(const XID, DBID: TID; const Tr: TIBTransaction = nil): TID;
    function GetIDByRUIDString(const RUID: TRUIDString; const Tr: TIBTransaction = nil): TID;
    //���������� ���� xid, dbid �� ������� gd_ruid �� id
    //���� ������ �� id �� ������� ������� ����� ����
    procedure GetRUIDByID(const ID: TID; out XID, DBID: TID; const Tr: TIBTransaction = nil);
    function  GetRUIDStringByID(const ID: TID; const Tr: TIBTransaction = nil): TRUIDString;
    //���������� ���� xid, dbid �� ������� gd_ruid �� id
    //���� ������ �� id �� ������� ������ xid = id, dbid = IBLogin.DBID
    function ProcessSQL(const S: String): String;
    function AdjustMetaName(const S: AnsiString; const MaxLength: Integer = cstMetaDataNameLength): AnsiString;

    //
    procedure ClearSecDescArr;

    //
    function GetNextID(const ResetCache: Boolean = False): TID;

    procedure IDCacheInit;
    procedure IDCacheFlush;

    //
    function GenerateNewDBID: TID;

    // AnAccess: 0, 1, 2 -- aview, achag, afull
    function Class_TestUserRights(C: TClass;
      const ASubType: TgdcSubType; const AnAccess: Integer): Boolean;
    procedure Class_GetSecDesc(C: TClass; const ASubType: TgdcSubType;
      out AView, AChag, AFull: Integer);
    procedure Class_SetSecDesc(C: TClass; const ASubType: TgdcSubType;
      const AView, AChag, AFull: Integer);

    //��������� ���� �� ������������
    //���������� id ��� -1 � ������, ���� ���� �� ����������
    function GetRUIDRecByXID(const XID, DBID: TID; Transaction: TIBTransaction): TRUIDRec;
    function GetRUIDRecByID(const AnID: TID; Transaction: TIBTransaction): TRUIDRec;

    procedure DeleteRUIDByXID(const XID, DBID: TID; Transaction: TIBTransaction);
    procedure DeleteRUIDByID(const AnID: TID; Transaction: TIBTransaction);

    procedure UpdateRUIDByXID(const AnID, AXID, ADBID: TID; const AModified: TDateTime;
      const AnEditorKey: Integer; Transaction: TIBTransaction);
    procedure UpdateRUIDByID(const AnID, AXID, ADBID: TID; const AModified: TDateTime;
      const AnEditorKey: Integer; Transaction: TIBTransaction);

    procedure InsertRUID(const AnID, AXID, ADBID: TID; const AModified: TDateTime;
      const AnEditorKey: Integer; Transaction: TIBTransaction);

    procedure RemoveRUIDFromCache(const AXID, ADBID: TID);

    // ��������� �������� SQL ������
    // ������ �� ������
    procedure ExecSingleQuery(const S: String; const Transaction: TIBTransaction = nil); overload;
    procedure ExecSingleQuery(const S: String; Param: Variant; const Transaction: TIBTransaction = nil); overload;
    function ExecSingleQueryResult(const S: String; Param: Variant;
      out Res: OleVariant; const Transaction: TIBTransaction = nil): Boolean; 

    procedure ChangeRUID(const AnOldXID, AnOldDBID, ANewXID, ANewDBID: TID;
      ATr: TIBTRansaction);

    property ReadTransaction: TIBTransaction read GetReadTransaction;

  published
    property Database: TIBDatabase read GetDatabase write SetDatabase;
  end;

  EgdcBaseManager = class(Exception);

  //////////////////////////////////////////////////////////
  // �����_��, ���������� � �_�������� �� ����������� ���
  // �� _ � ������ _ � ����_� �������� ������ _�������
  // ���_ � �����������_ ������_ (_� -- ������ �� ���)
  // �� �����_� ���� �����_�� �����_ ������-��_����
  TgdcDataLink = class(TDataLink)
  private
    FMasterField: TStringList;
    FDetailField: TStringList;
    FDetailObject: TgdcBase;

    function GetDetailField: String;
    function GetMasterField: String;
    procedure SetDetailField(const Value: String);
    procedure SetMasterField(const Value: String);

  protected
    FLinkEstablished: Boolean;

    procedure ActiveChanged; override;
    procedure EditingChanged; override;
    procedure RecordChanged(F: TField); override;

  public
    constructor Create(ADetailObject: TgdcBase);
    destructor Destroy; override;

    property MasterField: String read GetMasterField write SetMasterField;
    property DetailField: String read GetDetailField write SetDetailField;
  end;

  //////////////////////////////////////////////////////////
  // for transferring gdc objects via clipboard
  // we register our own clipboard format
  TObjectData = record
    ID: TID;
    ObjectName: array[0..63] of Char;
    ClassName: array[0..63] of Char;
    SubType: array[0..63] of Char;
  end;
  TObjectArr = array[0..0] of TObjectData;
  PgdcClipboardData = ^TgdcClipboardData;
  TgdcClipboardData = record
    Signature: Longint;
    Version: Longint;
    ClassName: array[0..63] of Char;
    SubType: array[0..63] of Char;
    Obj: TgdcBase;
    Cut: Boolean;
    ObjectCount: Integer;
    ObjectArr: TObjectArr;
  end;

  /////////////////////////////////////////////////////////
  // ���� ������ ������� �������� � ���������� ��������,
  // �� �� ������ ����������� ������������� ������ �
  // ��������� �������, ���������, �������� ��-������

  TgsCustomProcess = (cpInsert, cpModify, cpDelete);
  TgsCustomProcesses = set of TgsCustomProcess;

  /////////////////////////////////////////////////////////
  // ������������ ��� ���������� �������� ����� �� ��������������
  // ��� ���� ����� � ����������� ����� ���� �������� �����������
  TFieldValue = class(TObject)
  public
    FieldName: String;
    Value: String;
    IsNull: Boolean;
  end;

  TgdcPropertySet = class
  private
    FRUIDSt: String;
    FPropertyList: TStrings;
    FValueArray: Variant;
    FgdClass: CgdcBase;
    FSubType: TgdcSubType;
    function GetCount: Integer;
    function GetValue(APropertyName: String): Variant;
    function GetName(Index: Integer): String;

  public
    constructor Create(const ARUIDSt: String; AgdClass: CgdcBase; ASubType: TgdcSubType);
    destructor Destroy; override;

    property RUIDSt: String read FRUIDSt;
    property gdClass: CgdcBase read FgdClass;
    property SubType: TgdcSubType read FSubType;

    property Value[APropertyName: String]: Variant read GetValue;
    property Name[Index: Integer]: String read GetName;
    property Count: Integer read GetCount;

    function Find(APropertyName: String): Integer;
    function GetIndexValue(APropertyName: String): Integer;

    procedure Add(APropertyName: String; Value: Variant);
    procedure SetValue(APropertyName: String; Value: Variant);

    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);

    procedure Clear;
  end;

  TgdcPropertySets = class(TStringList)
  private
    FOwnsObjects: Boolean;
    function GetObject(Index: Integer): TgdcPropertySet; reintroduce; overload;
    procedure PutObject(Index: Integer; const Value: TgdcPropertySet); reintroduce; overload;

  public
    constructor Create;
    destructor Destroy; override;

    function Add(const ARUIDSt: String; AgdClassName: String;
      ASubType: TgdcSubType): Integer; reintroduce; overload;

    function AddObject(const S: string; AObject: TgdcPropertySet): Integer; reintroduce; overload;

    property OwnsObjects: Boolean read FOwnsObjects write FOwnsObjects;
    property Objects[Index: Integer]: TgdcPropertySet read GetObject write PutObject;

    procedure SaveToStream(S: TStream); override;
    procedure LoadFromStream(S: TStream); override;

    procedure Clear; override;
  end;

  TgdcBaseInitProc = procedure(Obj: TgdcBase) of object;

  /////////////////////////////////////////////////////////
  // ������ ���� ��� ����� ��'����

  TgdcBase = class(TIBCustomDataSet, IgdcBase)
  private
    FParentForm: TWinControl;
    FDetailLinks: TObjectList;
    FSubSets: TStringList;
    FgdcTableInfos: TgdcTableInfos;
    FNameInScript: String;
    FEventList: TStringList;
    FBaseState: TgdcStates;
    FpmReport: TPopupMenu;
    FQueryFilter: TQueryFilterGDC;
    FOnFilterChanged: TNotifyEvent;
    FOldValues: TObjectList;
    FSubType: TgdcSubType;
    FCustomProcess: TgsCustomProcesses;
    FExecQuery: TIBSQL;
    FUpdateableFields: String;
    FExtraConditions: TStringList;
    FSelectedID: TgdKeyArray;
    FDlgStack: TObjectStack;
    FSavedParams: TObjectList;
    FSetMasterField, FSetItemField: String;
    FSetAttributes: TObjectList;

    FBeforeShowDialog: TgdcDoBeforeShowDialog;
    FAfterShowDialog: TgdcDoAfterShowDialog;

    FAfterInitSQL: TgdcAfterInitSQL;

    FGetDialogDefaultsFieldsCached: Boolean;
    FGetDialogDefaultsFieldsCache: String;
    FRefreshMaster: Boolean;

    // ���� ��� ���������� ������� ���������
    FClassMethodAssoc: TgdKeyIntAndStrAssoc;
    FVarParam: TVarParamEvent;
    FReturnVarParam: TVarParamEvent;

    FSetTable: String;

    FUseScriptMethod: Boolean;

    FSyncList: TList;
    FOnGetSelectClause: TgdcOnGetSQLClause;
    FOnGetWhereClause: TgdcOnGetSQLClause;
    FOnGetOrderClause: TgdcOnGetSQLClause;
    FOnGetFromClause: TgdcOnGetSQLClause;
    FOnGetGroupClause: TgdcOnGetSQLClause;
    FQueryFiltered: Boolean;

    FIsNewRecord: Boolean;

    FFieldsCallDoChange: TStringList;
    FModifyFromStream: Boolean;

    FVariables: TgdVariables;
    FObjects: TgdObjects;

    FSetRefreshSQLOn: Boolean;

    SLInitial, SLChanged: TStringList;

    {������ ���� �������, ����������� �� ������}
    FStreamXID, FStreamDBID: TID;
    FOnFakeLoad: TOnFakeLoad;
    FStreamSilentProcessing: Boolean;
    FStreamProcessingAnswer: Word;

    FCopiedObjectKey: TID;

    FPostCount: Integer;
    FInDoFieldChange: Boolean;
    FInternalProcess: Boolean;

    function GetMethodControl: IMethodControl;

    function GetDetailField: String;
    function GetMasterField: String;
    function GetMasterSource: TDataSource;

    procedure SetDetailField(const Value: String);
    procedure SetMasterField(const Value: String);

    function GetID: Integer;
    procedure SetID(const Value: Integer);

    // ������ �� ����������
    function GetNameInScript: String;

    // ������� ������ ������, � ������� � ���� ��������, ������� ��������
    // ����-������, ����������� �� ������� ������. ������� � ���������� ����
    procedure IsUse;

    //
    function GetObject: TObject;

    // ������ ������ �� ��������� ��
    procedure PrintReport(const ID: Integer);
    function GetHasWhereClause: Boolean;

    // ��� ��������� ���� ����������: ��������� ��� ����
    // ����������� ��� ���
    function TestCopyField(const FieldName, DontCopyList: String): Boolean;

    // ������������ ����������� ���� �� ������� �������
    // ��������� ��� ������� �������
    procedure MakeReportMenu;
    //
    procedure DoOnFilterChanged(Sender: TObject; const AnCurrentFilter: Integer);

    function GetDetailLinks(Index: Integer): TgdcBase;
    function GetDetailLinksCount: Integer;
    function GetCreationDate: TDateTime;
    function GetCreatorKey: TID;
    function GetCreatorName: String;
    function GetEditionDate: TDateTime;
    function GetEditorKey: TID;
    function GetEditorName: String;
    function GetExtraConditions: TStrings;

    procedure DoAfterExtraChanged(Sender: TObject);
    procedure DoAfterSelectedChanged(Sender: TObject);
    function GetDSModified: Boolean;
    function GetSelectedID: TgdKeyArray;
    function GetSubSet: TgdcSubSet;
    function GetSubSetCount: Integer;
    function GetSubSets(Index: Integer): TgdcSubSet;
    procedure SetSubSets(Index: Integer; const Value: TgdcSubSet);

    // ��������� ��� ����������� ������� TgdcBase ��� ���������� �� �� ��������
    class procedure RegisterMethod;

    function IsSubSetStored: Boolean;
    function IsNameInScriptStored: Boolean;
    function IsReadTransactionStored: Boolean;
    function IsTransactionStored: Boolean;
    procedure SetSelectedID(const Value: TgdKeyArray);
    procedure SetSetTable(const Value: String);
    procedure SetUseScriptMethod(const Value: Boolean);

    //��������� ����-����� ��������-����������
    function GetSetTableJoin: String;
    //��������� ������-����� ������ �������-���������
    function GetSetTableSelect: String;
    //��������� ������-����� ������ �������������� ������-�����������
    function GetInheritedTableSelect: String;
    //��������� ����-����� ��������������� ���������-������������
    function GetInheritedTableJoin: String;

    procedure SetExtraConditions(const Value: TStrings);
    procedure SetOnGetSelectClause(const Value: TgdcOnGetSQLClause);
    procedure SetOnGetFromClause(const Value: TgdcOnGetSQLClause);
    procedure SetOnGetGroupClause(const Value: TgdcOnGetSQLClause);
    procedure SetOnGetOrderClause(const Value: TgdcOnGetSQLClause);
    procedure SetOnGetWhereClause(const Value: TgdcOnGetSQLClause);
    procedure SetQueryFiltered(const Value: Boolean);
    function GetObjects(Name: String): IDispatch;
    function GetVariables(Name: String): OleVariant;
    procedure SetObjects(Name: String; const Value: IDispatch);
    procedure SetVariables(Name: String; const Value: OleVariant);
    function GetSQLSetup: TatSQLSetup;

    procedure PrepareSLInitial;
    procedure PrepareSLChanged;

    procedure UpdateOldValues(Field: TField);
    procedure CheckDoFieldChange;
    function GetSetAttributes(Index: Integer): TgdcSetAttribute;
    function GetSetAttributesCount: Integer;
    procedure CheckSetAttributes;
    procedure SetStreamDBID(const Value: TID);
    procedure SetStreamXID(const Value: TID);

    function GetCompoundClasses(Index: Integer): TgdcCompoundClass;
    function GetCompoundClassesCount: Integer;

  protected
    FgdcDataLink: TgdcDataLink;
    FInternalTransaction: TIBTransaction;
    FID: TID;
    FObjectName: String;
    FSQLSetup: TatSQLSetup;
    FDSModified: Boolean;
    FSQLInitialized: Boolean;
    FIgnoreDataSet: TObjectList;

// ���� ��������� ��� MasterSource ��������������� ��� ���������� �����
// � ������� �������� ����������� �� ����.
    FIsInternalMasterSource: Boolean;

    // ������������ ��� �������� � ������ ������� �����
    // ������������� � TgdcCreateableForm ��� ����������� �����
    FCurrentForm: TObject;
    FGroupID: Integer; //������������� ������ �������

    FCompoundClasses: TObjectList;

    // ����� ������ �������
    procedure DoOnReportListClick(Sender: TObject);

    //
    procedure CopyEventHandlers(Dest, Source: TgdcBase);
    procedure ResetEventHandlers(Obj: TgdcBase);

    function GetObjectName: String; virtual;
    procedure SetObjectName(const Value: String);

    // ������ ��� ���������� ������� ���������
    // ����� ���������� �� Inherited � �������
    // � ������ �������������� �������� ���������� �� ������� �
    // �����  ������ �����. ���������� ��������� ���� � ���������� ������ �����
    // Name - ��� �������������� ������, AnParams - ���������� ������ ���������� ������
    function OnInvoker(const Name: WideString; AnParams: OleVariant): OleVariant; virtual;
    // ����� ������� ���� ������� ������ ����������� ������
    // AClass, AMethod - ��� ������ � ������, �� �������� ���������� ���������
    procedure ClearMacrosStack2(const AClass, AMethod: String;
      const AMethodKey: Byte);
    // ����� ������������� �����, �� �������� ������� ������ ���������� �����
    // ��������� �������� ��� ����, ����� �����, ��� �����������
    procedure SetFirstMethodAssoc(const AClass: String;
      const AMethodKey: Byte);
    // ���������� ������ ������ ��� ���������� ������� ���������
    procedure CreateKeyList;

    //
    procedure SetSubSet(const Value: TgdcSubSet); virtual;

    // ������ ������. OnClick - � PopupMenu
    procedure DoOnReportClick(Sender: TObject); virtual;

    // ���������, �������� �� ���������� ����� �������� �������� ������
    // ���� ��� -- �������� ����������
    class procedure CheckClass(C: TClass);

    // ������������� DataBase � Transaction ��� FIBSQL
    //procedure SetIBSQL;

    // ��������� �������� ��� ������
    // ������ �� ������
    procedure ExecSingleQuery(const S: String); overload;
    procedure ExecSingleQuery(const S: String; Param: Variant); overload;
    function ExecSingleQueryResult(const S: String; Param: Variant;
      out Res: OleVariant): Boolean;

    // ������� �������� ������� ������. ���� �� ��� �������, �� ����������
    // ������, ���� ���, �� �������� ���� �� ������� ����������� ������
    // ��-�� ������� �� ������� ���������� ��������
    { TODO :
������ �� ������������ �������� �� ��� ��������� ������.
���, ���� ������ ������ ������� ��-�� ���������� ����
(�� ������ ��), �� ��� ����� �������� ����� ������������ ���
����� ���� ��������� ��������� �����������. }
    function DeleteRecord: Boolean; virtual;

    procedure SetMasterSource(Value: TDataSource); virtual;

    // � ����������� �� �������������� ������� �����������
    // ��������� � ���� ������ � �������� � ������� ������ �������.
    // ������ ��������� ������� �������� ����� ������� � �����
    // ������� � �������� ������� ����� AND.
    // ����� � ����� ������ ������� ��������� ������� ��������������
    // ������ �� ������.
    // ���� ���� ��������� ������� ������� ����� ���������� ���, ��
    // �� ���� ������� � ����� ������, ������ ���.
    // �������� � ���������� ������� �� ���������.
    // WHERE ��������� �� ����!
    procedure GetWhereClauseConditions(S: TStrings); virtual;

    // ����� �� �������_���� "�� ����", ��������� ��� �
    // ������, ��_� ��������� ���� ����� ������_
    function GetSelectClause: String; virtual;
    // ��������� �����������, �������������, ��������, ��������
    // ����������� �� � ������ WHERE � � ������ FROM
    // ��� ������������ ������� ��� ������� ������ ��
    // ������ ���������� �� ���� �����������
    // ��� ��� ��� ���������� ����� ���� �������, ��������� �� ��
    function GetFromClause(const ARefresh: Boolean = False): String; virtual;

    function GetWhereClause: String; virtual;
    function GetGroupClause: String; virtual;
    function GetOrderClause: String; virtual;

    // ��������� ������_ �������� ������ ��� ������
    // ��� ���������� ��'���� _� ��������
    function GetSelectSQLText: String; virtual;
    function GetModifySQLText: String; virtual;
    function GetInsertSQLText: String; virtual;
    function GetDeleteSQLText: String; virtual;
    function GetRefreshSQLText: String; virtual;

    // _�_����_��� ��� ����������
    procedure InitSQL;
    function DoAfterInitSQL(const AnSQLText: String): String; dynamic;

    // ��������� ��'��� ������������� � ���� ���_�� � �������_�
    // ����_���, ���� �� _������ �� ���_� ����_�� �������_
    // _������ � ���� ��������
    //
    // ������� ����� ����� �������� �� ��������� ����
    // � �������������� ����, ���_ ����� ���������� _������
    // �_ ������� ���_��� �������. �_��� ��'������� ������
    // ������, ����� ������ �������� ��������, �����, ���_
    // ���_��� �������, ������� ���� � ������� ����, ��_
    // ��� ���� �� ���� �� �������� �������� ������ _�����,
    // ����� ������ ���_��� _ ���������� � ���������� ���������
    // �_�����_.
    //
    // ��� ������: ��� �������� ����������.
    procedure CustomInsert(Buff: Pointer); virtual;
    procedure CustomModify(Buff: Pointer); virtual;
    procedure CustomDelete(Buff: Pointer); virtual;

    //
    procedure _CustomInsert(Buff: Pointer); virtual;
    procedure _CustomModify(Buff: Pointer); virtual;
    procedure _CustomDelete(Buff: Pointer); virtual;

    // ����� ���������� ����� ��������� ������ �� ��������� ��
    // ����������, ��������������, ��������
    procedure DoAfterCustomProcess(Buff: Pointer; Process: TgsCustomProcess); virtual;

    // ���������� �������, ��������������� � CustomInsert & CustomModify
    procedure CustomExecQuery(const ASQL: String; Buff: Pointer; const IsParser: Boolean = True);

    //
    procedure RefreshParams;

    procedure LoadDialogDefaults(F: TgsStorageFolder; Dlg: TForm); overload; virtual;
    procedure SaveDialogDefaults(F: TgsStorageFolder; Dlg: TForm); overload; virtual;

    // ����������� ����� ��� ���������� ��������� ��������:
    // 1. �������� ���� �� �������� ������. ������, ��������� ������ ����
    //    �������� ����� �������, ����� � ������������ �� ���� �����������
    //    ������� ����� ������, ���� � ���� ��� ����. �� ����
    //    ���-���� �� ����� �� ����� ������, �� ���� �������� ����������.
    // 2. ������������� ����������� ��������������.
    // 3. ������������� ���� ������� � ������.
    // 4. ������������� ������ ����� ���������� ��-���������.
    // 5. ����� ������� ����������� �������
    // 6. ������������� ����� ���������� ���������� ����������,
    //    (���� ������ ������������ � ���������� ����).
    procedure DoOnNewRecord; override;
    procedure _DoOnNewRecord; virtual;

    // ��� ������������� ������ ���_�� �� ������������� ����������
    // ����. ����� ��� �� ������_ ��� �� ����� ��� ����� �������� _
    // ������_��, ��� _ ��������� ����� �������
    function CreateDialogForm: TCreateableForm; virtual;

    // !!!
    // ����� ���������� �������, ��� ��� ��������_���_ ����� ��'����
    procedure InternalPostRecord(Qry: TIBSQL; Buff: Pointer); override;
    procedure InternalDeleteRecord(Qry: TIBSQL; Buff: Pointer); override;

    // �� ��� ��'��� ����_���� ����� � ����-���-�����, �_ ��_�������
    // ���_� ��������� �_ ����� ���� ���, ���� ������ _��_��
    // ���_ �� -- _���
    function AcceptClipboard(CD: PgdcClipboardData): Boolean; virtual;

    // �������� ��� �������� ������� ������� ��� ����������� ������ � ���������
    // ��������. AnOldID -- ������������� �������� ������� ������
    // ANewID -- ������������� ������-����� � ������� �������
    //procedure CopyDetailTable(const AMasterTableName: String;
    //  const AnOldID, ANewID: Integer);

    //
    procedure Loaded; override;

    //
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    //
    procedure InternalOpen; override;
    procedure InternalSetParamsFromCursor; override;

    //
    procedure DoBeforeOpen; override;

    // ������������ ������ ����� �� ������ ��������� ������:
    // 1. ��������� ���������� ���������� ����������� � ���������
    //    �������� (���� �� ����������� ������������ � ��.)
    // 2. ���������� ��������� �����, ����������� DisplayLabel
    procedure CreateFields; override;

    //������������� ������� ��� ������� ��������
    procedure DoAfterDelete; override;
    procedure DoAfterInsert; override;
    procedure DoAfterEdit; override;
    procedure DoAfterOpen; override;
    procedure DoAfterPost; override;
    procedure DoAfterCancel; override;
    procedure DoAfterScroll; override;
    procedure DoBeforeScroll; override;
    procedure DoBeforeClose; override;
    procedure DoBeforeDelete; override;
    procedure DoBeforeEdit; override;
    procedure DoBeforeInsert; override;
    procedure DoBeforePost; override;
    function CallDoFieldChange(Field: TField): Boolean; virtual;
    procedure DoFieldChange(Field: TField); virtual;

    procedure DoAfterTransactionEnd(Sender: TObject); override;

    procedure LoadEventList; virtual;
    function GetGroupID: Integer; virtual;

    // ������ �����, ������� �� ���� ����������
    // ��� ����������� �������
    // ������������ ����� ��������� �������
    // ������ ������� �� �������������!
    function GetNotCopyField: String; virtual;

    // ��� ������� ��� ���������� � �������� �� ������
    // ��������� ��������
    procedure AddDetailLink(AnObject: TgdcBase);
    procedure RemoveDetailLink(AnObject: TgdcBase);

    // ��� ������ ����������� ���� �� �������������� �� �������
    // ����������� ���� �� ������ ��������� ����� ���� ���� ��������
    // � ���� ���������� ����, ��� ����, ����� ��� ������� �� ������ ��
    // ������� �� � �������� ���������
    // ������������ Cancel �� �� �����, ��� ��� ������ � ��� ���� ��
    // ��� ����
    procedure InternalSetFieldData(Field: TField; Buffer: Pointer); override;

    //
    procedure SetSubType(const Value: TgdcSubType); virtual;
    function GetSubType: TgdcSubType; virtual;

    // ���� ������-������ ������������ ����� ����������� ������ ��
    // ���������� ������, �� ����� ���������� ��������� ��������:
    // ��� �������, ������� ������ �����, ������� ���������� ������
    // �� ������� ������ � ������� ���������. ������ ������
    // ������� ��������� ������: ������������ ������, ������������ ��.
    // ���������, ����������� ��������� ���� ������� ��������� � �������.
    // ��� �������������� ������ ������� ������� ���������� ����
    // � ������� ������������ ���� ��� ������/�������������� ������������
    // ������, ���������� ������ ��� ���������/������ ������� ���������
    // ����� ��� ������ ������������ ���������. ���� � ���������� ������
    // ������� ������ ������� ���������, �� ���� �������� ����
    // ����������� ���������. ������ ������ ��� ���������� ��� ���
    // ������ (�������) ��������� � ��������� ��������������.
    // ��� ������� ������ �������� ������������ ����� SyncField
    // �� ���������� ����� ����� ��������� ������ ����. ����
    // ��� ��������� ���������� ���� (� ����� ������� ��� ����� ����,
    // �������� ������ �� ������ � ������� ������ ���������) ����������
    // �������� �������� ������� ���� ������-�������, ���������
    // ����������� ����� �������, �� ������� ���� ������, ��
    // ���� ����� ������ ���� �������� � � ��� ������ ���� ������
    // � �������� ������, ������� �� ���������� ������ �� ���������
    // �������.
    //
    // ...����� ����� ���������� SyncControls � ����������� ����.
    procedure SyncField(Field: TField); virtual;

    //
    procedure SetCustomProcess(const Value: TgsCustomProcesses);
    function GetCustomProcess: TgsCustomProcesses; virtual;

    // ��������������� �������. � ��� �������, � ������ ���� ��� ����
    // ����� ����������� ��������� ����: ���_���� = :��������
    // ������ ������� ���������� ��� ���� �� ��������� ����� ���������
    // ���� ����� �������� � ������� �� ���������� -- ������������ ������ ������
    function GetFieldNameComparedToParam(const AParamName: String): String;

    // ��������:
    // ��� ���������� ������� � ������ �� ����������� �� ����
    // ����� ������� � ��������� �������, �� ������� ���
    // ���������. ������ ���������� �������������� ����� �����������
    // �������� �������.
    // ������ ���������� ������, ����� ���������� ������ ���� ���������
    // � �������� �������, �.�. ������� ������� ������, �����
    // ������ �� ������� ���� ������ � � ����� ��
    // ������� ������ ��������� ��������������.
    // ������:
    // � �������� ����� ���� ����, ���� ��� ��������� ���������� ������
    // ��� �� �������� ������� ������� gd_companyaccount. ������
    // ���� ����� ���� ���������� �������������. ������ ���� ������
    // � ���������, ������� �� ����������� ����� ���� ������.
    // ������ ������ ���� ����������� ���������.
    // ���� �� ������ �������� �������� �������. ��� ��� ��������
    // � ������� gd_company ��������� ���� companyaccountkey
    // ������� �������� ������ �� ������� ����. ���� ����� ����
    // � �� ���������.
    // ���� ��� ���������� ������� �������� ��������� �����������
    // ������������������, �.�. ������� ��������� ������ ����, �� �������
    // ���� ������, ����� ������ ��������, �� ��� �������� � ����
    // ��������� ��������. ������ ����� ����������������� ������ ����
    // �� �� �������� ������������ ������ �� ������ ��������, �������
    // ��� �� ��������� � ������������� ���� �� �������.
    // �������� �������� �������� ���������� �������� � ��������
    // �������: ������� ������ ��������, ����� ����.
    // � ������� ���������� ��� ���� ������. ��� ���������� False
    // ���� ��������� ������ ������� ���������� � ������, ���� ��������.
    function IsReverseOrder(const AFieldName: String): Boolean; virtual;

    //
    procedure InternalPrepare; override;
    procedure InternalUnPrepare; override;

    // ������� ��������� ����� ������������� ���
    // �������� �������� � ����������
    function CreateReadIBSQL: TIBSQL; overload;
    function CreateReadIBSQL(out DidActivate: Boolean): TIBSQL; overload;

    //
    procedure SetTransaction(Value: TIBTransaction); override;
    procedure SetReadTransaction(const Value: TIBTransaction); override;

    // ������������� ����� GetCustomProcess ����� �������� ����, ���
    // � ����������� �� ��������� ������� ����� ����������� �������
    // ��� ������� ������ ������
    // ��������, ���� �� ������������ ����� ����������� ������ ��
    // ���������� ������, �� ����������� ����� ���������� ������ �������
    // ��������� �������: ���� ���������� ������ ���� �������� �������
    // �� ������ ��������� �� ���� � ����� �������� ���������� ��������
    // �������������� �����������, ���� �� ��������� ��������� �����
    // � � �������� � � �������������� ��������, �� ���������� ���������
    // ������� ������
    property CustomProcess: TgsCustomProcesses read GetCustomProcess write SetCustomProcess;

    //�������������� ������� ��� ������� �������
    function GetReductionCondition: String; virtual;
    function GetReductionTable: String; virtual;

    // ��� ���������� ������� ���������
    function GetGdcInterface(Source: TObject): IDispatch;
    function GetInterfaceToObject(Source: IDispatch): TObject;
    // ������ ��� ���������� Var-����������
    function GetVarInterface(const AnValue: Variant): OleVariant;
    function GetVarParam(const AnValue: Variant): OleVariant;


    // �������� ��� ���������� ������� ���������
    // �������� ���������� ������������� ����������� Inherited
    // ��� ������ �����
    // ��� ���������� �������, ����� �� ��������� � ������ ����� ������ ��
    property gdcBaseMethodControl: IMethodControl read GetMethodControl;
    // ��� �������� �����.����� ������� ����� ������, �� �������� ������� �������
    // ������������, ����� �����, ����� �������� ���� LastCallClass
    property ClassMethodAssoc: TgdKeyIntAndStrAssoc read FClassMethodAssoc;

    function GetCanChangeRights: Boolean; virtual;
    function GetCanCreate: Boolean; virtual;
    function GetCanDelete: Boolean; virtual;
    function GetCanEdit: Boolean; virtual;
    function GetCanPrint: Boolean; virtual;
    function GetCanView: Boolean; virtual;

    function GetCanModify: Boolean; override;

    //
    procedure SetBaseState(const ABaseState: TgdcStates);

    //
    procedure DoBeforeInternalPostRecord; virtual;
    procedure DoAfterInternalPostRecord; virtual;

    //
    function GetFieldByNameValue(const AField: String): Variant;

    {���������� ���� �������, ������������ �� ������
    �������� ����� ���� ������������ ��� �������� �����-������ ��������, ��������� �� ������������.
    � ��������� �������� ������ � gd_ruid ����������� �� �����}
    function GetRuidFromStream: TRUID;

    //
    function GetSecCondition: String; virtual;

    //
    procedure CheckCompoundClasses; virtual;
    function GetCompoundMasterTable: String; virtual;

    procedure FindInheritedSubType(var FC: TgdcFullClass);

  public
    FReadUserFromStream: Boolean;
    // 1
    constructor Create(AnOwner: TComponent); override;

    // 2-3
    constructor CreateSubType(AnOwner: TComponent;
      const ASubType: TgdcSubType;
      const ASubSet: TgdcSubSet = 'All'); virtual;

    // 3-6
    constructor CreateWithParams(AnOwner: TComponent;
      ADatabase: TIBDatabase;
      ATransaction: TIBTransaction;
      const ASubType: TgdcSubType = '';
      const ASubSet: TgdcSubSet = 'All';
      const AnID: Integer = -1); virtual;

    // 4-5
    constructor CreateWithID(AnOwner: TComponent;
      ADatabase: TIBDatabase;
      ATransaction: TIBTransaction;
      const AnID: Integer;
      const ASubType: String = ''); virtual;

    destructor Destroy; override;

    procedure BeforeDestruction; override;

    // ������ �����, �������� ������� �����������
    // � ������������� ������������� � ���� � ���������� ���� ��� �����
    // ����� ������
    // ����� ����� ��������� ������ � �������. � ����� �� ������� ������ ����� � �������
    // ������ ������ -- ������ ������
    function GetDialogDefaultsFields: String; virtual;

    // �������������� ��� ����� ������� ��������� ���������������
    procedure AfterConstruction; override;

    // ������� ���������� ������ ��� ������ �������
    // �� �������������� �����
    function CheckTheSameStatement: String; virtual;

    // ������� ����� ������ (Insert). �������� �� ��������� (Post).
    // ��������� ������.
    // ��������, ����� ������ ��� ���������� � ����.
    // ������ ������� ���������� ����� ���������� ������
    // �, ���� ��� ����, ��������� ������ �� ��� � ������
    // ������. ���� ������ ��� -- ������ ����.
    // ��� ���� ������� ����� ������� �� ��������� ������� ����� Cancel.
    function CheckTheSame(Modify: Boolean = False): Boolean;
    //������� ������ �� �������������� � �� ����
    //������������ ������ ��� �������� ������ �� ������
    function DeleteTheSame(AnID: Integer; AName: String): Boolean;
    //������� �������� ������������� ����������� ������ ������� �� SourceDS
    //��� ������� ����� editiondate, editorkey
    function CheckNeedModify(SourceDS: TDataSet; IDMapping: TgdKeyIntAssoc): Boolean;

    //
    procedure Prepare;
    procedure UnPrepare;

    // ���� ������� ��� ��������� � ��������� ��������������
    // � ����� ������ ����, �� ������� ��������� ����������� �� ����
    // �������� ������, ������ ����������� �����.
    // ������ ��� ��� ����, ����� �������� ��������� �� �� ������
    // ����������, ����� ������������ ����� � ���������� ����
    // ������ ��������� ������ � ����� �� ��
    procedure Post; override;

    // ������� �������� ������� �� ���������� ��������
    // �� ������ �������� ������ �� ���������� ���
    // ���������� ������������, ������� ������ ������������
    // ��� ����������: All � ByID
    function CheckSubSet(const ASubSet: String): Boolean; virtual;

    //
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;

    procedure LoadDialogDefaults; overload; virtual;
    procedure SaveDialogDefaults; overload; virtual;

{
    ��� TgdcBase ���������  ������
    1)    procedure ChooseItems(); overload;
        ������������ ����� �� ������� ���� �� ����, ��� � ������ ��������� �����
    2)    procedure ChooseItems(Cl: CgdcBase; out KeyArray: TgdKeyArray;); overload;
        ������������ ����� �� ������� ���� Cl
    ��� ������ ������� �� ��������.
    ����� ��������� ������ � ������ ������ ��������� � �������� SelectedID �������,
    ���������� ChooseItems, �� ������ ������ ��� ����������� ���������� KeyArray.

    ��� ������ Choose ���������� ��������� � gdc-������� ��������� ������:
    // ��������� ��� �����
        class function GetViewFormClassName(const ASubType: TgdcSubType): String; virtual;
    � ����� ���������  ������ ��� gdc_creatable_form
    //���������� ��������� ����� ��� ������ Choose
          procedure SetChoose(AnObject: TgdcBase); virtual; AnObject - ������ ��������� ChooseItems
    � FormCreate �������, ����� ������ ����� �������������� ��� Choose
    (��� ���� ������-������). �� ��������� ������� ������� ������.
    (��������, FgdcLinkChoose := gdcDetailObject)

}
    function ChooseItems(out AChosenIDInOrder: OleVariant;
      const ChooseComponentName: String = '';
      const ChooseSubSet: String = '';
      const ChooseExtraConditions: String = ''): Boolean; overload;

    function ChooseItems(Cl: CgdcBase;
      KeyArray: TgdKeyArray;
      out AChosenIDInOrder: OleVariant;
      const ChooseComponentName: String = '';
      const ChooseSubSet: String = '';
      const ChooseSubType: TgdcSubType = '';
      const ChooseExtraConditions: String = ''): Boolean; overload;

    // �� ���������� ��� ������� ��� �������� ������
    // � ������� ����, ����� ������ ��� �� ���������
    // ����� ������������ ����������� ������� ��� ���
    // ���� ������ ��������� �� �����, �� ������������
    // ����� �����. ���� ��� ������� ������� ���������� ����
    // �� ������������ ����� ����������� ����
    function ParentHandle: Integer;

    // ������� �� ����� ���� �� ������� ��������� ��� ������� �������
    procedure PopupReportMenu(const X, Y: Integer);

    //
    procedure PopupFilterMenu(const X, Y: Integer);

    // ������� ���������� ����� ������� (��)
    // ���������� �� (��� ������ ��)
    //    procedure Find;

    // �� ��������� ������������� ����� �������, ��
    // �� ���� � TIBCustomDataSet
    function ParamByName(Idx : String) : TIBXSQLVAR;

    // ������� ���� ���_� _ �������� ������ ��� ��� �������������
    function CreateDialog(const ADlgClassName: String = ''): Boolean; overload; virtual;
    function CreateDialog(C: CgdcBase): Boolean; overload; virtual;
    function CreateDialog(C: TgdcFullClass; const AnInitProc: TgdcBaseInitProc = nil): Boolean; overload; virtual;

    // ������ ����� ������, � ��������������� ������� ��������
    function CreateDescendant: Boolean; virtual;

    // ������� ���_� �������� ���_�� _ �������� ������ ��� ��� �������������
    function CopyDialog: Boolean; virtual;

    // ����������� ����� ���������� ���������� ���� ����� ������
    // ������� ��� �������������� �������
    procedure DoBeforeShowDialog(DlgForm: TCreateableForm); virtual;

    // ����������� ����� �������� ���������� ���� ����� ������
    // ������� ��� �������������� �������
    procedure DoAfterShowDialog(DlgForm: TCreateableForm; IsOk: Boolean); virtual;

    // ������� ������ �������_ ���_��, ������� ���� ��������_��
    function DeleteMultiple(BL: TBookmarkList): Boolean;
    function DeleteMultiple2(BL: OleVariant): Boolean;

    // ������������� �������� ���_��
    // � �������, ������ _��_��, ���_ ����������_�
    // ����� �� �� _ ������ � ���������� �������
    function EditDialog(const ADlgClassName: String = ''): Boolean; virtual; { �� ������� ����� ��� �������� }

    // ������� �������� ������ ���_� �� �������������
    // ����� �������� �� ���_�� ���_�� _ �������� _�
    // ������_����� ��� ����, ��_� ���_ ��������� ���
    // ��� �������������
    function EditMultiple(BL: TBookmarkList; const ADlgClassName: String = ''): Boolean;
    function EditMultiple2(BL: OleVariant; const ADlgClassName: String = ''): Boolean;

    // ������� ���i�������� �������� ���i��
    // � �������� �����, � �����, ����� ����������� ��������
    // ��������. �������� ����������� ����� ������� �
    // ������ ��������, ����������� �� �������� ������
    function Copy(const AFields: String; AValues: Variant; const ACopyDetail: Boolean = False;
      const APost: Boolean = True; const AnAppend: Boolean = False): Boolean; virtual;
    // ����� ������������ ��� ������������ ������-�������� � ���������� ��� ��� ���������
    function CopyObject(const ACopyDetailObjects: Boolean = False;
      const AShowEditDialog: Boolean = False): Boolean; virtual;
    // �������� ��� �������� �������������, �������� Copy(True)
    function CopyWithDetail: Boolean;

    // ������� ������ ���_� (���_ �� �����������)
    // _ ������� ��������. ������� ���������� ��� �������������
    // � ���������� ������ (������ ��������)
    procedure CreateNext;

    // ��������� ������ � �����������
    // �������� � ��������� ������� ������ (BL = nil) ��� ������ �������
    procedure CopyToClipboard(BL: TBookmarkList; const ACut: Boolean = cCopy);
    function PasteFromClipboard(const ATestKeyboard: Boolean = False): Boolean;

    // ���������� ������, ���� � ���������� ���� ��������
    // ������� ����� ���� ���������
    function CanPasteFromClipboard: Boolean; virtual;

    // ��������� ��������� �������� ��������� ���� � �������� ������
    // ��� ����� ����������� ��������� ���
    procedure AssignField(const AnID: Integer; const AFieldName: String; AValue: Variant);

    // ��������� ���� ������� �� ������ ���������� � �����
    // ������ ������� ��������� ������� ����� ��� ���� �� �����
    // ����������. ������� ������ ������� ������ ���� �����, ����������� ������
    // � �������.
    // ������ ������ ������������ ������ � �������.
    function HideFieldsList: String; virtual;
    function ShowFieldInGrid(AField: TField): Boolean;

    // ��������� ���������� �������� � �����������
    // ������� �������
    procedure CloseOpen;

    // �� ��������� ��������� ������� ������ "����������"
    // � ���� ������������� ������, ��������� ���������
    function GetIDForBookmark(const Bm: TBookmarkStr): TID;

    // ���������� �������� ��������� ���� ��� ������, ��������
    // ���������������
    function GetFieldValueForID(const AnID: TID; const AFieldName: String): Variant;
    function GetFieldValueForBookmark(const ABookmark: TBookmarkStr; const AFieldName: String): Variant;
    procedure SetValueForBookmark(const ABookmark: TBookmarkStr; const AFieldName: String; const AValue: Variant);

    // ��� �������� ������ ��� �������� �������� �������� �
    // ����_ _ �������� _� ������
    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); virtual;
    procedure _LoadFromStream(Stream: TStream; IDMapping: TgdKeyIntAssoc;
      ObjectSet: TgdcObjectSet; UpdateList: TObjectList);

    //�������� ������ �� ������ � ������� ������
    procedure _LoadFromStreamInternal(Stream: TStream;
      IDMapping: TgdKeyIntAssoc; ObjectSet: TgdcObjectSet;
      UpdateList: TObjectList; StreamRecord: TgsStreamRecord);

    procedure SaveToStream(Stream: TStream; DetailDS: TgdcBase;
      const BL: TBookmarkList = nil; const OnlyCurrent: Boolean = True);
    procedure LoadFromStream(Stream: TStream);

    function QuerySaveFileName(
      const AFileName: String = '';     
      const aDefaultExt: String = datExtension;
      const aFilter: String = datDialogFilter): String; virtual;
    function QueryLoadFileName(
      const AFileName: String = '';
      const aDefaultExt: String = datExtension;
      const aFilter: String = datDialogFilter): String; virtual;

    procedure SaveToFile(const AFileName: String = ''; const ADetail: TgdcBase = nil;
      const BL: TBookmarkList = nil; const OnlyCurrent: Boolean = True; StreamFormat: TgsStreamType = sttUnknown); virtual;
    procedure LoadFromFile(const AFileName: String = ''); virtual;

    // ������� ���� �������
    function Reduction(BL: TBookmarkList): Boolean; virtual;
    function InternalReduction(const ACondemnedKey: TID = -1; const AMasterKey: TID = -1): Boolean;

    // ����� ��������� ��������� �� ������� � ��������
    // ���������, � ������ ��������� � �� ������ �� ��
    // � ��������� ������ ������������ ����������.
    // ����� ����������� � ������ ������� ������� ���������
    // ��������� �������� �� ��������� ������ ����� ��
    // ������� ������. �.�. ����� ���� ���� ���������, ���
    // ������� ������ ��������.
    procedure CheckCurrentRecord;

    //
    function GetCurrRecordClass: TgdcFullClass; virtual;

    // ���������� �������� ����������� ���� �� �����
    class function GetListNameByID(const AnID: TID;
      const ASubType: TgdcSubType = ''): String;

    //
    function TestUserRights(const SS: TgdcTableInfos): Boolean;

    //
    class function Class_TestUserRights(const SS: TgdcTableInfos;
      const ST: String): Boolean; virtual;

    // ����� ������� ����� ����������� �������, ��� ���� ����������
    // ��������� ��������:
    // 1. ����������
    // 2. ������������
    // 3. DialogActions
    //
    procedure Assign(Source: TPersistent); override;

    //
    // ���������� ������ �������, ���������� ���������
    // ��� ������� ������. ������������ � ������� ������
    // ������ ��� �������� �������
    class function GetChildrenClass(const ASubType: TgdcSubType;
      AnOL: TObjectList; const AnIncludeRoot: Boolean = True;
      const AnOnlyDirect: Boolean = False;
      const AnIncludeAbstract: Boolean = False): Boolean; virtual;

    // ������������� ������������ ����������� ������� ���� �� �������
    // ����������� ��� ������� ������
    function QueryDescendant: TgdcFullClass;

    // �������� ��������� � �����, ������������ ��������� � sSubDialog
    procedure RevertRecord;

    //��������� RefreshSQL
    procedure SetRefreshSQLOn(SetOn: Boolean);

    // ��������� ��������� ���������� ������ ����������� ����������
    // �� �������� �������. �������� ������������� � ������.
    // ����������� ����� ������: ����������� ������ ���������� ��������
    // ��� ���.
    procedure GetDistinctColumnValues(const AFieldName: String; S: TStrings; const DoSort: Boolean = True);

    // ������� ���������� ��������� ���������� �������� ��������������
    // �������. ���� �������� ���������� � ������, �� ����������
    // �������������. ������� ������ ���� �������������� ��� ���
    // ��������, ������� ���������� ���� ���������� ��� �������������.
    function GetNextID(const Increment: Boolean = True; const ResetCache: Boolean = False): Integer; virtual;

    //
    function HasAttribute: Boolean;

    //
    function GetRUID: TRUID;

    // Issue 2162
    procedure Resync(Mode: TResyncMode); override;

    // ������� ����� ��� ��������� ��������, ��� ��������� ��
    // ��������� ���� ����� ���� ������������� ���������, �� ��������
    // �������� ����� ������ ��� ������ �������
    class function CreateViewForm(AnOwner: TComponent; const AClassName: String = '';
      const ASubType: String = ''; const ANewInstance: Boolean = False): TForm; 

    //���������� ��� ������ ����� ��� �������������� ������
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; virtual;

    //
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; virtual;

    // ������� ��������� ���������� ������� � ��������� �� � ���������
    class procedure RefreshStats;

    // ���������� ������� ��� ������� ��� ���. ���������� ��� ���
    // ���������� ��������� ������� ������� � ������.
    class function IsBigTable: Boolean;

    //
    class function IsAbstractClass: Boolean; virtual;

    // ������� ��'��� _ �������� ���_� � �������� _�
    // ���_ ������ ���� � ���� -- �_������ ��������� �_������
    class function CreateSingularByID(AnOwner: TComponent; ADatabase: TIBDatabase;
      ATransaction: TIBTransaction; const AnID: TID; const ASubType: String = ''): TgdcBase; overload; virtual;
    class function CreateSingularByID(AnOwner: TComponent;
      const AnID: TID; const ASubType: String = ''): TgdcBase; overload; virtual;

    // ������� ����_�� ��'����
    // ���_ �������� ��'���� ���������� � ����� ����_��,
    // ���� ���� �� _��. ���_ � �������_�, �������� ��������
    // ���_�-��-������, ����� ���_�-��-�����_�_�, ����� ����-��-�����_�_�
    // ���� ����� ������� ������ _�� ������� ����_��
    // ������� ����_��, ���� ��� ����_��, ����� ���_� ���� �����������
    // ���_� _ �����_ ���_� ��'��� ��������� ���� _ ���� ������_��� ��������
    // ����
    class function GetListTable(const ASubType: TgdcSubType): String; virtual;
    class function GetDistinctTable(const ASubType: TgdcSubType): String; virtual;
    // ���� � ������ ��'����
    class function GetListField(const ASubType: TgdcSubType): String; virtual;
    // ���� ��� ������������ ����������� � ������ (����� ,)
    class function GetListFieldExtended(const ASubType: TgdcSubType): String; virtual;
    // ��i�� ��� ��'����
    class function GetListTableAlias: String; virtual;
    // ���� � _������_������� ��'����
    class function GetKeyField(const ASubType: TgdcSubType): String; virtual;

    // ������ �����, ������� �� ���� ��������� � �����.
    //  ������������ ����� ��������� �������,
    //  ������: 'LB,RB,CREATORKEY,EDITORKEY'
    class function GetNotStreamSavedField(const IsReplicationMode: Boolean = False): String; virtual;

    // ����� ����������� ���������� ��'���� � �����
    // ������� ���_�� � ����_��
    class function GetRestrictCondition(const ATableName, ASubType: String): String; virtual;

    // ���_ ����� ����� ������_ ����� ��'����, ���������������
    // �������� ������ ����������_��
    // ��-����������, ������_�� �����_������ ���� ������� ����_��
    class function GetDisplayName(const ASubType: TgdcSubType): String; virtual;

    // �������, ���������� ������ ��������� �������� � SubTypeList � �������
    // �������������� ��� �������=������
    // ������� ���������� True, ���� ������� ����, ����� - False

    //Subtype -- ������.
    //OnlyDirect -- ���� True, �� ������������ ������ ���������������� ����������.
    //� ��������� ������ -- ������������ ��� �������� �����������.
    class function GetSubTypeList(ASubTypeList: TStrings;
      const ASubType: String = ''; const AnOnlyDirect: Boolean = False;
      const AVerbose: Boolean = True): Boolean; virtual;

    //
    class function CheckSubType(const ASubType: String): Boolean;

    // ������ _��������� �� ��������� ������� ����_�� ��, ��������������
    // ����������. ���_� ����� ���� ����� ���� ���� ����_���� � ���� ������
    // ������ ����� ���� �� �������� _ _�_����_������ ��'��� ����������.
    class function GetTableInfos(const ASubType: String): TgdcTableInfos; virtual;

    // ������ ���_� ������������ ������� ��� ��������� �����
    // ������� ������������ ������� � ������. �����_ ������ � ���_��
    // ������� ����������� ������� � ������.
    // �������:
    //   All;ByID;ByName;OnlySelected;
    class function GetSubSetList: String; virtual;

    // ��������� ������ ������� ������� ������������� ������ ���
    // ������� ���������� ������. ��������, � �������� ��������������
    // ���������� �������� ��������/��������� ���������� � ����
    // ���������� �� ������. ��� �������� ����� �������� �� ������
    // ����� ����� ������ ������ ����������� ���� ������� �����.
    class function CommitRequired: Boolean; virtual;

    // ������� ���������� �������� ������ ��� �����������,
    // ��������, � ������
    class procedure GetClassImage(const ASizeX, ASizeY: Integer; AGraphic: TGraphic); virtual;

    // ��� ��������� ������ ���� (TField.FieldName) ����������
    // ��� �������
    function RelationByAliasName(const AnAliasName: String): String;

    // ��� ��������� ������ ���� (TField.FieldName) ����������
    // ���������� ��� ���� � �������
    function FieldNameByAliasName(const AnAliasName: String): String;

    // ������� ���� �� ����� ������� � ����� ����� ���� � �������
    // (�� ������, ������� ����� ���� ������ ��� ���� � �������!)
    // ��� ���� � ��� ������� ���������� ��� �������
    // ������� �� �����������
    function FindField(const ARelationName, AFieldName: String): TField; overload;
    function FieldByName(const ARelationName, AFieldName: String): TField; overload;

    //
    procedure AddToSelectedID(const AnID: Integer = -1); overload;
    procedure AddToSelectedID(ASelectedID: TgdKeyArray); overload;
    procedure AddToSelectedID(BL: TBookmarkList); overload;
    procedure RemoveFromSelectedID(const AnID: Integer = -1); overload;
    procedure RemoveFromSelectedID(BL: TBookmarkList); overload;
    procedure SaveSelectedToStream(S: TStream);
    procedure LoadSelectedFromStream(S: TStream);

    //
    procedure GetDependencies(ATr: TIBTransaction; const ASessionID: Integer;
      const AnIncludeSystemObjects: Boolean = False;
      const AnIgnoreFields: String = '');

    //
    class function SelectObject(const AMessage: String = '';
      const ATitle: String = '';
      const AHelpCtxt: Integer = 0;
      const ACondition: String = '';
      const ADefaultID: Integer = -1): TID; virtual;

    // ������_ �������� _�� ��'���� ��� ��������� _�,
    // ����_ ������� ��������_��� �������
    class function QGetNameForID(const AnID: TID; const ASubType: String = ''): String;
    class function QGetNameForID2(const AnID: TID; const ASubType: TgdcSubType): String;

    // ������� ���������� ������� ���������� �����, ���� ���� ��� nil ���� ���
    function GetDlgForm: TForm;


    function  ObjectExists(const Name: String): Boolean;
    function  VariableExists(Name: String): Boolean;
    // ��������� ������ ��� ������������� � ������-��������
    // ��������� ���� ��� �������� Variables
    procedure AddVariableItem(const Name: String);
    // ��������� ���� ��� �������� Objects
    procedure AddObjectItem(const Name: String);

    // �������� ������ ��� ������������� � ������-��������
    // � �� �������� ��������� ������� �����
    // ������ ���������� ����������� � �����
    property Variables[Name: String]: OleVariant read GetVariables write SetVariables;
    // ������ �������� ����������� � �����
    property Objects[Name: String]: IDispatch read GetObjects write SetObjects;

    // ��� ������ _�� ������ �� �����
    //  property DisplayName: String read GetDisplayName;

    // ��� ������� �� ����� ������� _ ���� ����� �������
    // ��������_ ������� (�����)
    // �� ����_��, ParentForm -- �����, �� ���� �������_���
    // ��, ���_��� ����� ��� �������� �������� ��
    property ParentForm: TWinControl read FParentForm;

    // ������� ��� ��������� _� ���� �� ����� �� �������������...
    property ID: Integer read GetID write SetID;

    //
    property ObjectName: String read GetObjectName write SetObjectName;

    // ���������� ��������� ��������, ��������� � ������ �����
    // master-detail
    property DetailLinksCount: Integer read GetDetailLinksCount;
    // ��������� �� ���� �� ������ ��������� ��������
    property DetailLinks[Index: Integer]: TgdcBase read GetDetailLinks;

    //
    property EventList: TStringList read FEventList;

    property Params;
    property gdcTableInfos: TgdcTableInfos read FgdcTableInfos;

    // ��������� �������
    property BaseState: TgdcStates read FBaseState write SetBaseState;

    property SelectSQL;
    property GroupID: Integer read GetGroupID;

    // ������������ ������ ��� ��������� � ���� ������
    property HasWhereClause: Boolean read GetHasWhereClause;

    //
    property Filter: TQueryFilterGDC read FQueryFilter;

    // �������, ������� ���������� ����� INITSQL � ���� ����������� �������� ��������� ������
    // ���� ��������� � ������ �����, ���� ���� ����������, � ����� ������ ������� � ��������.
    property OnAfterInitSQL: TgdcAfterInitSQL read FAfterInitSQL write FAfterInitSQL;

    // �� �����_ �������� ����� ��������_������ _��������� �� ���������_��
    // ���� _ ���� ���������� ��'����, ��������� _ ���� _ ���� �������������
    //
    // ��� ������ ������� ����_�� ���_�� ���� ���_:
    //   creationdate dcreationdate
    //   creatorkey   dforeignkey
    // �/���
    //   editiondate  deditiondate
    //   editorkey    dforeignkey
    // ���������� ����� ��븢 ���� �� ���� �_����-��'���
    // �������� ������ �� _� ����� ���� ���������� �����_����_ (��. �_���)
    // ����� ���������� ����������� �� ��븢 ��'����
    // � �����_� ������� ��������� ����� ��������� � gdcTableInfos
    // �_ ���� ���_� ���_ � ����_��. �������, ��� ���������� FindField
    // ���������, �� ��� ���� ��������� ���� �� � ������� ����_��, �
    // � �����������.
    // ������� ������ ������� _������ �� ����� ����:
    // �������� _� �� �������������, �� ���� ������_�� �������_
    // �����_ _ ���������� ���_��. ���� � ������� �������� �����
    // �� ����� ���������.
    // ����������� _��������� ����� � ����������� ���� �����_����_ ��'����.
    property CreationDate: TDateTime read GetCreationDate;
    property CreatorKey: TID read GetCreatorKey;
    property CreatorName: String read GetCreatorName;
    property EditionDate: TDateTime read GetEditionDate;
    property EditorKey: TID read GetEditorKey;
    property EditorName: String read GetEditorName;

    // ���� ����������� � ������ �� ����� ����� ��� �������� ������
    // �������� ������ ������ � ������ �������� (���� ����� ����)
    // �� ��������� ���������
    property RefreshMaster: Boolean read FRefreshMaster write FRefreshMaster;

    //
    property DSModified: Boolean read GetDSModified;

    //
    property SelectedID: TgdKeyArray read GetSelectedID write SetSelectedID;

    property SubSetCount: Integer read GetSubSetCount;
    property SubSets[Index: Integer]: TgdcSubSet read GetSubSets write SetSubSets;

    function HasSubSet(const ASubSet: TgdcSubSet): Boolean;
    procedure DeleteSubSet(const Index: Integer);
    procedure RemoveSubSet(const ASubSet: TgdcSubSet);
    procedure AddSubSet(const ASubSet: TgdcSubSet);
    procedure ClearSubSets;

    //
    procedure SetInclude(const AnID: TID); virtual;
    //��������� ������� ������
    procedure SetExclude(const Reopen: Boolean); virtual;

    function GetClassName: String;

    // ���������� ������, ���� �������� ���� ���� ��������
    // � �������� �������������� ������� ������
    function FieldChanged(const AFieldName: String): Boolean;
    function GetOldFieldValue(const AFieldName: String): Variant;

    // ��������� ��� ������������� ���� �������
    property CanCreate: Boolean read GetCanCreate;
    property CanEdit: Boolean read GetCanEdit;
    property CanView: Boolean read GetCanView;
    property CanDelete: Boolean read GetCanDelete;
    property CanPrint: Boolean read GetCanPrint;
    property CanChangeRights: Boolean read GetCanChangeRights;

    //
    //property QSelect;

    //������� ������������ ��� �������� ������ �� ������
    //�� ���� ������ �� CheckTheSameStatement, � ���� ������� ��,
    //�� �������� �������� ������� �� ������
    //���� NeedModifyFromStream ����� ���������� ����, ���������� �� ����� (��������, � ���������)
    class function NeedModifyFromStream(const SubType: String): Boolean; virtual;

    //������� ������������ ��� �������� ������ �� ������
    //�� ���� ������ �� CheckTheSameStatement, � ���� ������� ��,
    //�� �������� �������
    //���������� ��� �������� ��������� ������-������ ��������
    //��������, ��� �������� ���������, ���� �� ��� ����� ��������, �� �� ������� ������
    //���� NeedDeleteTheSame ����� ���������� ����, �������� �� �����
    class function NeedDeleteTheSame(const SubType: String): Boolean; virtual;

    property UseScriptMethod: Boolean read FUseScriptMethod write SetUseScriptMethod;

    //��������� ����� write ����� ����� ���� ��������� ����� �� �����
    //���������� � ������, �.�. �� ����� ��������� ���-���
    property ExtraConditions: TStrings read GetExtraConditions write SetExtraConditions;

    //
    property QueryFiltered: Boolean read FQueryFiltered write SetQueryFiltered default DefQueryFiltered;

    // ������ �����, ��� ������� ���������� ������� DoFieldChange
    // ���� ������ ����, �� ������� ���������� ��� ���� �����.
    property FieldsCallDoChange: TStringList read FFieldsCallDoChange;

    property SQLSetup: TatSQLSetup read GetSQLSetup;

    //
    property OnFakeLoad: TOnFakeLoad read FOnFakeLoad write FOnFakeLoad;

    //
    property PostCount: Integer read FPostCount;

    property StreamXID: TID read FStreamXID write SetStreamXID;
    property StreamDBID: TID read FStreamDBID write SetStreamDBID;
    property StreamSilentProcessing: Boolean read FStreamSilentProcessing write FStreamSilentProcessing;
    property StreamProcessingAnswer: Word read FStreamProcessingAnswer write FStreamProcessingAnswer;
    // ��� ����������� ������ ���� ��������� ���� ������������ ������
    property CopiedObjectKey: TID read FCopiedObjectKey write FCopiedObjectKey;

    //
    property SetAttributesCount: Integer read GetSetAttributesCount;
    property SetAttributes[Index: Integer]: TgdcSetAttribute read GetSetAttributes;

    //
    property CompoundClassesCount: Integer read GetCompoundClassesCount;
    property CompoundClasses[Index: Integer]: TgdcCompoundClass read GetCompoundClasses;

  published
    //� ��� ���� �����-�������, ������� �� ��������� ���������� ��� ������
    //�������������� �� ��� ��� �������� �� ������
    //������ ��� ������ ����� ����������� ��������, �����������
    //�������������� �� ��� ������ � ������� ����� ����� �������� � �������� ������
    //��� �������� ������������ ������ ��� �������� �� ������, � ������ ��� ����� ��������� � �����!!!
    property ModifyFromStream: Boolean read FModifyFromStream write FModifyFromStream
      stored False;

    //
    property SubType: TgdcSubType read GetSubType write SetSubType;

    // ��� �����_�� �����_ ������-��_����
    property MasterSource: TDataSource read GetMasterSource write SetMasterSource;
    property MasterField: String read GetMasterField write SetMasterField;
    property DetailField: String read GetDetailField write SetDetailField;

    // ���������� ��'���� � ��� ���������_ ��'���� ��������� ����
    // �������� ���� ���������� -- �������� ��������
    // ��� ������������_ ������� ����� ����������
    property SubSet: TgdcSubSet read GetSubSet write SetSubSet
      stored IsSubSetStored;

    //
    property SetTable: String read FSetTable write SetSetTable;

    // ��� ���������� ��� ������������� � ��������
    property NameInScript: String read GetNameInScript write FNameInScript
      stored IsNameInScriptStored;

    // ���������� ����� ���������� ������, ����� ���������, �����
    // ����� ���� ���������� ��������� ������� �� ������
    property OnFilterChanged: TNotifyEvent read FOnFilterChanged write FOnFilterChanged;

    // ������������ �����_����_
    property Active default False;
    property CachedUpdates;
    property Database stored False;

    //
    property ReadTransaction stored IsReadTransactionStored;
    property Transaction stored IsTransactionStored;

    // ������� ���������� ����� ��������� ����������� ����
    property BeforeShowDialog: TgdcDoBeforeShowDialog read FBeforeShowDialog write FBeforeShowDialog;
    // ������� ���������� ����� �������� ����������� ����
    property AfterShowDialog: TgdcDoAfterShowDialog read FAfterShowDialog write FAfterShowDialog;

    //
    property Filtered;
    property OnFilterRecord;

    property OnGetSelectClause: TgdcOnGetSQLClause read FOnGetSelectClause write SetOnGetSelectClause;
    property OnGetFromClause: TgdcOnGetSQLClause read FOnGetFromClause write SetOnGetFromClause;
    property OnGetWhereClause: TgdcOnGetSQLClause read FOnGetWhereClause write SetOnGetWhereClause;
    property OnGetGroupClause: TgdcOnGetSQLClause read FOnGetGroupClause write SetOnGetGroupClause;
    property OnGetOrderClause: TgdcOnGetSQLClause read FOnGetOrderClause write SetOnGetOrderClause;

  end;

  CIBError = class of EIBError;

  ////////////////////////////////////////////////////////
  // ������������ ��� ���������������� �� �������
  // ��������� ��� �� ��
  EgdcIBError = class(EIBError)
  private
    FOriginalClass: CIBError;

  public
    constructor CreateObj(E: EIBError; AnObj: TgdcBase);

    property OriginalClass: CIBError read FOriginalClass;
  end;

  EgdcIDNotFound = class(EgdcIBError)
  end;

  ////////////////////////////////////////////////////////
  // ������������ ��� ���������������� �� �������,
  // ������������ � ������-�������
  EgdcException = class(Exception)
  public
    constructor CreateObj(const AMessage: String; AnObj: TgdcBase); overload;
  end;

  EgdcNoTable = class(EgdcException);

  ////////////////////////////////////////////////////////
  // ������������ ��� ���������������� � ��������� �
  // ����������� ���� � ������������
  EgdcUserHaventRights = class(EgdcException);

  //� Delphi 5 ������ ������ ������������� �� ������������
  //� Delphi 7+ ����� ������������ TDragObjectEx
  TgdcDragObject = class(TDragObject)
  protected
    procedure Finished(Target: TObject; X, Y: Integer; Accepted: Boolean); override;
  public
    BL: TBookmarkList;
    SourceControl: TWinControl;
  end;

  {
  TIBCustomDataSetCrack = class(TIBCustomDataSet);

  ������ ����:

    ...
    var
      DidActivate: Boolean;
    begin
      DidActivate := ActivateTransaction;
      try
        ...
        try
          ...
        except
          if DidActivate and Transaction.InTransaction then
            Transaction.Rollback;
          raise;
        end;
        ...
      finally
        if DidActivate and Transaction.InTransaction then
          Transaction.Commit;
      end;
    end

  ����� ������:

    ...
    var
      I: IgdcTransactionGuard;
    begin
      I := TgdcTransactionGuard.Create(Transaction);
      ...
      try
        ...
      except
        I.Action := taRollback;
        raise;
      end;
    end
  }

  {IgdcTransactionGuard = interface
    function GetTransaction: TIBTransaction;
    function GetAction: TTransactionAction;
    procedure SetAction(AnAction: TTransactionAction);

    property Action: TTransactionAction read GetAction write SetAction;
    property Transaction: TIBTransaction read GetTransaction;
  end;}

  {
  TgdcTransactionGuard = class(TInterfacedObject, IgdcTransactionGuard)
  private
    FTransaction: TIBTransaction;
    FDidActivate: Boolean;
    FAction: TTransactionAction;

    function GetAction: TTransactionAction;
    procedure SetAction(AnAction: TTransactionAction);
    function GetTransaction: TIBTransaction;

  public
    constructor Create(ATransaction: TIBTransaction);
    destructor Destroy; override;

    property Action: TTransactionAction read GetAction write SetAction;
    property Transaction: TIBTransaction read GetTransaction;
  end;
  }

  {
  ������ ����:

    ...
    var
      DidActivate: Boolean;
      q: TIBSQL;
    begin
      q := TIBSQL.Create(nil);
      DidActivate := ActivateTransaction;
      try
        q.Transaction := Transaction;
        ...
        try
          ...
        except
          if DidActivate and Transaction.InTransaction then
            Transaction.Rollback;
          raise;
        end;
        ...
      finally
        q.Free;
        if DidActivate and Transaction.InTransaction then
          Transaction.Commit;
      end;
    end

  ����� ������:

    ...
    var
      I: IgdcQTransactionGuard;
    begin
      I := TgdcQTransactionGuard.Create(Transaction);
      ...
      try
        ...
      except
        I.Action := taRollback;
        raise;
      end;
    end

    � IBSQL �� ���������� ��� I.q
  }

  {
  IgdcQTransactionGuard = interface(IgdcTransactionGuard)
    function GetQ: TIBSQL;

    property q: TIBSQL read GetQ;
  end;
  }

  {
  TgdcQTransactionGuard = class(TgdcTransactionGuard, IgdcQTransactionGuard)
  private
    Fq: TIBSQL;

    function GetQ: TIBSQL;

  public
    constructor Create(ATransaction: TIBTransaction);
    destructor Destroy; override;

    property q: TIBSQL read GetQ;
  end;
  }

var
  // �� ������������ ���� ������ ��� �������� �������� �����
  // ���������
  gdcClipboardFormat: Word;
  CacheDBID: TID;

const
  gdcClipboardFormatName: array[0..12] of Char = 'AndreiKireev'#00;
  gdcCurrentClipboardSignature = $56889103;
  gdcCurrentClipboardVersion = $00000001;

// ���������� �������� ����������� ������� ����� ���
// ��������� �������, �.�. ��� GD_CONTACT ������ TgdcBaseContact,
// � �� TgdcContact ��� TgdcContactList
// ���� ��� ������� ��� �������� ������. ��������, ��� ����� �������,
// �� ���������� ������ ������: �����=��� � ������=������ ������
function GetBaseClassForRelation(const ARelationName: String): TgdcFullClass;
function GetBaseClassForRelationByID(const ARelationName: String;
  const AnID: Integer; ibtr: TIBTransaction): TgdcFullClass;

//
function GetClassForObjectByID(ADatabase: TIBDatabase; ATransaction: TIBTransaction;
  AClass: CgdcBase; ASubType: TgdcSubType; const AnID: Integer): TgdcFullClass;

//
procedure Register;

// helper function
function IndexOfStr(const S: String; const A: array of String): Integer;

//
function MakeFullClass(C: CgdcBase; const ASubType: TgdcSubType): TgdcFullClass;

//
function gdcFullClass(const AgdClass: CgdcBase;
  const ASubType: TgdcSubType): TgdcFullClass;
function gdcFullClassName(const AgdClassName: TgdcClassName;
  const ASubType: TgdcSubType): TgdcFullClassName;

function CreateSelectedArr(Obj: TgdcBase;
  BL: TBookmarkList): OleVariant;

function  CheckNameChar(const Key: Char): Char;
procedure CheckClipboardForName;
function GetUserByTransaction(const ATrID: Integer): String;

implementation

{$R gdcClasses.dcr}

uses
  IBTable,                      DBClient,                     gd_security,
  at_classes,                   dialogs,                      jclSelected,
  gdc_frmG_unit,                ActiveX,                      IBUtils,
  rp_BaseReport_Unit,           IBQuery,                      rp_dlgEnterParam_unit,
  Gedemin_TLB,                  jclStrings,                   gdcMetaData,
  IBErrorCodes,                 gd_strings,                   gdc_createable_form,
  TypInfo,                      dmImages_unit,                gd_ClassList,
  Messages,                     gsIBLookupCombobox,           comctrls,
  gsDBDelete_dlgTableValues,    rp_ReportClient,              gdc_dlgQueryDescendant_unit,
  gdc_dlgObjectProperties_unit, gsDBReduction,                
  flt_sql_parser,               JclStrHashMap,                gdDBImpExp_unit,
  gdcClasses,                   gdc_dlgG_unit,                gdc_dlgSelectObject_unit,
  mtd_i_Inherited,              gdcOLEClassList,              prp_methods,
  gs_Exception,                 Storages,
  at_sql_parser,                scrReportGroup,               at_frmSQLProcess,
  DBConsts,                     gd_common_functions,          ComObj,
  gdc_frmMDH_unit,              AcctUtils
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub, gd_localization
  {$ENDIF}
  , gdc_frmStreamSaver, gdcStreamSaver, gdcLBRBTreeMetaData, gdcTableMetaData;

const
  cst_sql_SelectRuidByID =
    'SELECT * FROM gd_ruid WHERE id=:id';
  cst_sql_SelectRuidByXID =
    'SELECT * FROM gd_ruid WHERE xid=:xid AND dbid=:dbid';
  cst_sql_InsertRuid =
    'INSERT INTO gd_ruid (id, xid, dbid, modified, editorkey) VALUES ' +
    ' (:id, :xid, :dbid, :modified, :editorkey) ';
  cst_sql_UpdateRuidByXID =
    'UPDATE gd_ruid SET editorkey = :editorkey, id = :id, ' +
    ' modified=:modified WHERE xid=:xid AND dbid=:dbid';
  cst_sql_UpdateRuidByID =
    'UPDATE gd_ruid SET editorkey = :editorkey, ' +
    ' modified=:modified, xid=:xid, dbid=:dbid WHERE id = :id';
  cst_sql_DeleteRuidByXID =
    'DELETE FROM gd_ruid WHERE xid=:xid AND dbid=:dbid';
  cst_sql_DeleteRuidByID =
    'DELETE FROM gd_ruid WHERE id=:id';

var
  CacheList: TStringHashMap;
  UseSavepoints: Boolean;
  {$IFDEF DEBUG}
  InvokeCounts: TStringList;
  {$ENDIF}

type
  TgdcReferenceUpdate = class(TObject)
  public
    FieldName: String;
    FullClass: TgdcFullClass;
    ID: TID;
    RefID: TID;
  end;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcBaseManager]);
end;

function CheckNameChar(const Key: Char): Char;
begin
  if not (Key in ValidCharsForNames) and (Ord(Key) <> 8) then begin
    Beep;
    Result:= Chr(0);
  end
  else
    Result:= Key;
end;

procedure CheckClipboardForName;
var
  ss: string;
  i: integer;
begin
  if Clipboard.HasFormat(CF_TEXT) then begin
    ss:= Clipboard.AsText;
    for i:= Length(ss) downto 1 do
      if CheckNameChar(ss[i]) = Chr(0) then
        ss[i]:= '|';
      while Pos('|', ss) > 0 do begin
        Delete(ss, Pos('|', ss), 1);
      end;
    Clipboard.AsText:= ss;
  end
  else
    Clipboard.AsText:= '';
end;

function GetUserByTransaction(const ATrID: Integer): String;
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT COALESCE(u.name, a.mon$user) || '' ('' || a.mon$remote_address || '')'' ' +
      'FROM mon$transactions s ' +
      'JOIN mon$attachments a ON a.mon$attachment_id = s.mon$attachment_id ' +
      'LEFT JOIN gd_user u ON a.mon$user = u.ibname ' +
      'WHERE s.mon$transaction_id = ' + IntToStr(ATrID);
    q.ExecQuery;
    if q.Eof then
      Result := ''
    else
      Result := q.Fields[0].AsTrimString;
  finally
    q.Free;
    Tr.Free;   
  end;
end;

function gdcFullClass(const AgdClass: CgdcBase;
  const ASubType: TgdcSubType): TgdcFullClass;
begin
  Result.gdClass := AgdClass;
  Result.SubType := ASubType;
end;

function gdcFullClassName(const AgdClassName: TgdcClassName;
  const ASubType: TgdcSubType): TgdcFullClassName;
begin
  Result.gdClassName := AgdClassName;
  Result.SubType := ASubType;
end;

function CreateSelectedArr(Obj: TgdcBase;
  BL: TBookmarkList): OleVariant;
var
  I: Integer;
  Found: Boolean;
begin
  if (Obj = nil) or (not Obj.Active) or Obj.IsEmpty then
    Result := VarArrayOf([])
  else
  begin
    if BL <> nil then
    begin
      {$IFDEF GEDEMIN}
      if (BL.GetDataSet = nil) or (not BL.GetDataSet.Active) or BL.GetDataSet.IsEmpty then
      begin
        Result := VarArrayOf([]);
        exit;
      end;

      if BL.GetDataSet <> Obj then
        raise Exception.CreateFmt('BookmarkList doesnt belong to the dataset %s',
          [Obj.Name]);

      {$ENDIF}
      BL.Refresh;
    end;

    if (BL = nil) or (BL.Count = 0)
      or ((BL.Count = 1) and (BL[0] <> Obj.Bookmark)) then
    begin
      Result := VarArrayOf([Obj.ID]);
    end
    else
    begin
      Result := VarArrayCreate([0, BL.Count - 1], varVariant);

      Found := False;
      for I := 0 to BL.Count - 1 do
      begin
        if not Found then
        begin
          if BL.Items[I] = Obj.Bookmark then
            Found := True;
        end;
        Result[I] := Obj.GetIDForBookmark(BL.Items[I]);
      end;

      if not Found then
      begin
        VarArrayRedim(Result, VarArrayHighBound(Result, 1) + 1);
        Result[VarArrayHighBound(Result, 1)] := Obj.ID;
      end;
    end;
  end;
end;

function IndexOfStr(const S: String; const A: array of String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(A) do
    if S = A[I] then Result := I;
end;

function MakeFullClass(C: CgdcBase; const ASubType: TgdcSubType): TgdcFullClass;
begin
  Result.gdClass := C;
  Result.SubType := ASubType;
end;

function GetClassForObjectByID(ADatabase: TIBDatabase; ATransaction: TIBTransaction;
  AClass: CgdcBase; ASubType: TgdcSubType; const AnID: Integer): TgdcFullClass;
var
  Obj: TgdcBase;
begin
  Result.gdClass := nil;
  Result.SubType := '';
  Obj := nil;

  try
    while (Obj = nil) and (AClass <> nil) and (AClass <> TgdcBase) do
    begin
      try
        Obj := AClass.CreateSingularByID(nil,
          ADatabase, ATransaction,
          AnID, ASubType);
      except
        on EgdcIDNotFound do
        begin
          if ASubType > '' then
            ASubType := ''
          else
            AClass := CgdcBase(AClass.ClassParent);
        end else
          raise;
      end;
    end;

    if Obj <> nil then
    begin
      Result := Obj.GetCurrRecordClass;
    end;
  finally
    Obj.Free;
  end;
end;

function GetBaseClassForRelationByID(const ARelationName: String; const AnID: Integer;
  ibtr: TIBTransaction): TgdcFullClass;
var
  Obj: TgdcBase;
  DidActivate: Boolean;
begin
  Assert(ARelationName > '');
  Assert(AnID > 0);
  Assert(Assigned(ibtr));

  Result := GetBaseClassForRelation(ARelationName);

  if Result.gdClass <> nil then
  begin
    DidActivate := not ibtr.InTransaction;
    if DidActivate then
      ibtr.StartTransaction;
    try
      Obj := Result.gdClass.CreateWithID(nil, ibtr.DefaultDatabase, ibtr, AnID, Result.SubType);
      try
        Obj.ReadTransaction := ibtr;
        Obj.Open;
        if Obj.EOF then
        begin
          Result.gdClass := nil;
          Result.SubType := '';
        end else
          Result := Obj.GetCurrRecordClass;
      finally
        Obj.Free;
      end;
    finally
      if DidActivate and ibtr.InTransaction then
        ibtr.Rollback;
    end;
  end;
end;

function GetBaseClassForRelation(const ARelationName: String): TgdcFullClass;
var
  BE: TgdBaseEntry;
  R: TatRelation;
begin
  Assert(gdClassList <> nil);
  BE := gdClassList.FindByRelation(ARelationName);
  if BE <> nil then
  begin
    Result.gdClass := BE.gdcClass;
    Result.SubType := BE.SubType;
  end else
  begin
    R := atDatabase.Relations.ByRelationName(ARelationName);
    if (R <> nil) and (R.PrimaryKey <> nil)
      and (R.PrimaryKey.ConstraintFields.Count = 1) then
    begin
      R := R.PrimaryKey.ConstraintFields[0].References;

      if R <> nil then
        Result := GetBaseClassForRelation(R.RelationName)
      else begin
        Result.gdClass := nil;
        Result.SubType := '';
      end;
    end else
    begin
      Result.gdClass := nil;
      Result.SubType := '';
    end;
  end;
end;

procedure MakeFieldList(Fields: String; List: TStrings);
begin
  List.CommaText := StringReplace(Fields, ';', ',', [rfReplaceAll]);
end;

function gdcFullClassToString(const AgdcFullClass: TgdcFullClass): String;
begin
  Result := '^' + AgdcFullClass.gdClass.ClassName + '^' + AgdcFullClass.SubType;
end;

function StringTogdcFullClass(const AString: String): TgdcFullClass;
var
  I: Integer;
begin
  Assert(AString > '');
  Assert(AString[1] = '^');

  I := Pos('^', Copy(AString, 2, 1024));
  Result.gdClass := CgdcBase(FindClass(Copy(AString, 2, I - 1)));
  Result.SubType := Copy(AString, I + 2, 1024);
end;

{ TgdcBase }

procedure TgdcBase.DoAfterDelete;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASE', 'DOAFTERDELETE', KEYDOAFTERDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOAFTERDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOAFTERDELETE', KEYDOAFTERDELETE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  FDSModified := True;

  if FRefreshMaster and Assigned(FgdcDataLink) and Assigned(FgdcDataLink.DataSet)
    and (FgdcDataLink.DataSet.State = dsBrowse) then
  begin
    FgdcDataLink.DataSet.Refresh;
  end;  

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOAFTERDELETE', KEYDOAFTERDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOAFTERDELETE', KEYDOAFTERDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.DoAfterInsert;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASE', 'DOAFTERINSERT', KEYDOAFTERINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOAFTERINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOAFTERINSERT', KEYDOAFTERINSERT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if not FDataTransfer then
    inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOAFTERINSERT', KEYDOAFTERINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOAFTERINSERT', KEYDOAFTERINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.DoAfterEdit;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASE', 'DOAFTEREDIT', KEYDOAFTEREDIT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOAFTEREDIT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTEREDIT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOAFTEREDIT', KEYDOAFTEREDIT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if not FDataTransfer then
    inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOAFTEREDIT', KEYDOAFTEREDIT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOAFTEREDIT', KEYDOAFTEREDIT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.DoAfterOpen;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  I: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASE', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOAFTEROPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTEROPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOAFTEROPEN', KEYDOAFTEROPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  FID := -1;
  FObjectName := '';

  inherited DoAfterOpen;

  //��������� ����������� ������� ��� �����-
  if Assigned(EventControl) then
    EventControl.SetChildEvents(Self);

  if not (csDesigning in ComponentState) then
    SetDefaultFields(False);

  //
  FAggregatesObsolete := True;

  //���� � ��� ���� �������-���������,
  //�� ������� ���������� ��� �������������� ������ ���� �������-���������
  if FSetTable > '' then
  begin
    for I := 0 to Fields.Count - 1 do
      if AnsiPos(cstSetPrefix, Fields[I].FieldName) = 1 then
        Fields[I].ReadOnly := False
      else
        Fields[I].ReadOnly := True;
    FieldByName(GetListField(SubType)).ReadOnly := False;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOAFTEROPEN', KEYDOAFTEROPEN);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.DoAfterPost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  FM, FD: TField;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASE', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOAFTERPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOAFTERPOST', KEYDOAFTERPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  inherited;

  Inc(FPostCount);

  CheckDoFieldChange;

  // ��������:
  // ���� ����������� ������ �������, ��� ��������
  // ��������������� ������������ ����������������
  // � � ���� ����������� ������, ��, ����� ��������-��������,
  // ��� ������ �� ����� �����, ��������� �� ����������������
  // �������� �� (������ ��� ����� ���: SELECT * FROM ... WHERE id=:ID).
  // �� �������� ������������� ����� ��������� � ���������
  if HasSubSet('ByID') then
  begin
    ParamByName(GetKeyField(SubType)).AsInteger := ID;
  end else
  if HasSubSet('ByName') then
  begin
    ParamByName(GetListField(SubType)).AsString := ObjectName;
  end;

  //
  if FRefreshMaster
    and Assigned(FgdcDataLink)
    and Assigned(FgdcDataLink.DataSet)
    and (FgdcDataLink.DataSet.State = dsBrowse) then
  begin
    FgdcDataLink.DataSet.Refresh;
  end;

  //
  if Assigned(MasterSource)
    and (MasterSource.DataSet is TgdcBase)
    and ((sDialog in TgdcBase(MasterSource.DataSet).BaseState)
      or (sDialog in FBaseState))
    and (not HasSubSet('ByRootID'))
    and (UserStorage.ReadBoolean('Options', 'WarnMDMism', True, False)) then
  begin
    FM := TgdcBase(MasterSource.DataSet).FindField(MasterField);
    FD := FindField(GetFieldNameComparedToParam(DetailField));
    if (FM <> nil) and (FD <> nil) then
    begin
      if FM.AsString <> FD.AsString then
      begin
        MessageBox(ParentHandle,
          PChar(Format('��������, ��������� ������ "%s"'#13#10'�� ������������� �������� ������� "%s"'#13#10#13#10,
            [GetDisplayName(SubType) + ': ' + ObjectName,
              TgdcBase(MasterSource.DataSet).GetDisplayName(TgdcBase(MasterSource.DataSet).SubType) + ': ' + TgdcBase(MasterSource.DataSet).ObjectName]) +
          '����� ���������� ������ �� ����� ���� �� ����� � ������.'),
          '��������',
          MB_OK or MB_ICONINFORMATION);
      end;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.DoAfterCancel;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASE', 'DOAFTERCANCEL', KEYDOAFTERCANCEL)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOAFTERCANCEL);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERCANCEL]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOAFTERCANCEL', KEYDOAFTERCANCEL, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if not FDataTransfer then
    inherited;

  CheckDoFieldChange;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOAFTERCANCEL', KEYDOAFTERCANCEL)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOAFTERCANCEL', KEYDOAFTERCANCEL);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.DoBeforeClose;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASE', 'DOBEFORECLOSE', KEYDOBEFORECLOSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOBEFORECLOSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFORECLOSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOBEFORECLOSE', KEYDOBEFORECLOSE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FInternalProcess then
    raise EgdcException.Create('������� ������� ����� ������ � ��������� ���������� ���������!');

  inherited;

  if Assigned(EventControl) then
    EventControl.ResetChildEvents(Self);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOBEFORECLOSE', KEYDOBEFORECLOSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOBEFORECLOSE', KEYDOBEFORECLOSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.DoBeforeDelete;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  J: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASE', 'DOBEFOREDELETE', KEYDOBEFOREDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOBEFOREDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOBEFOREDELETE', KEYDOBEFOREDELETE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  if (not CanDelete) and (not IBLogin.IsUserAdmin) then
    raise EgdcUserHaventRights.CreateFmt(strHaventRights,
      [strDelete, ClassName, SubType, GetDisplayName(SubType)]);

  if CacheList <> nil then
  begin
    J := ID;
    CacheList.RemoveData(J);
  end;

  DeleteFromLookupCache(IntToStr(ID));

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOBEFOREDELETE', KEYDOBEFOREDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOBEFOREDELETE', KEYDOBEFOREDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.DoBeforeEdit;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASE', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOBEFOREEDIT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREEDIT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOBEFOREEDIT', KEYDOBEFOREEDIT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if FOldValues <> nil then
    FOldValues.Clear;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOBEFOREEDIT', KEYDOBEFOREEDIT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.DoBeforeInsert;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOBEFOREINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOBEFOREINSERT', KEYDOBEFOREINSERT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if not FDataTransfer then
  begin
    if FSetTable > '' then
      Abort;

    if (not CanCreate) and (not IBLogin.IsIBUserAdmin) then
      raise EgdcUserHaventRights.CreateFmt(strHaventRights,
        [strCreate, ClassName, SubType, GetDisplayName(SubType)]);

    inherited;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT);
  {M}  end;
  {END MACRO}
end;

(*

  ����� ����������� ������ �������������� �������� ������������
  ������������. ������������� ����� ������� ����� �� ����� �������.

*)
procedure TgdcBase.DoBeforePost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  F: TField;
  AFull, AChag, AView: Integer;
  {MD: TgdcBase;}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  if (not CanEdit) and (not IBLogin.IsUserAdmin) then
    raise EgdcUserHaventRights.CreateFmt(strHaventRights,
      [strEdit, ClassName, SubType, GetDisplayName(SubType)]);

  if dsEdit = State then
  begin
    if tiEditorKey in gdcTableInfos then
      FieldByName(fnEditorKey).AsInteger := IBLogin.ContactKey;
    if (tiEditionDate in gdcTableInfos) and ((not (sLoadFromStream in BaseState)) or FieldByName(fnEditionDate).IsNull) then
      FieldByName(fnEditionDate).AsDateTime := SysUtils.Now;
  end;

  // ����� ������������� sMultiple
  // � ������ ������������ ����������� �����
  // ��������� ������������ �������� ���������� ����� �
  // ����������� �� �������� ������ �����
  // ��� �����, ���������� ������ ��� ����� �����
  // ��, ����� ���� �������������� ���������� ������������
  // ��� �������
  // ������� � ������� �������������� ���� �������:
  // � ������������ �����������, ���� ������� ������������
  // ������, �� ��� ���������������� ������ �������������
  // ���� � ���� ��������� ������� ������� � ������
  // ������������ ��� �������������� (��������, ���� �� ��� ������)
  // �� ��� ���������� ��������� ������������ (��� ������ ������!)
  // ���� ��� �� ������� � ������� ������������ � ���� ������
  // �����������, �� ��� ���������� ������ ������������� ��
  // ���� �� ������. ��! ������-������ �������� ��� ��������
  // (������������ ���� �������� ������������) � �������� �� ����
  // ��������� ��������� �������. ��� �������� � ����, ��� ���� �������
  // ������������ � ���, � �� ����������� �� ����: ���� ��� ���������
  // ��� ���, ����� ���������������� ������� ������������� �� ������ ������
  //
  // ������� � ���� �� ���������: ��� �������������� ������������ ����������
  // ������� � ��������� ������ ������� (BaseState) ��������������� ����
  // sMultiple. �����������, ���� � ���� � ������������� ���������
  // ����� �������� (���� ������������ ����� ����� � ����������� ��
  // �������� ������) ������ ��������� �� ���� ���� � ���������
  // ������������ ������ ���� ���� �� ����������.

  F := FindField('afull');

  if (F <> nil) then
  begin
    AFull := F.AsInteger or 1;
    if AFull <> F.AsInteger then
      F.AsInteger := AFull;
  end;

  if (F <> nil) and (FindField('achag') <> nil) then
  begin
    AChag := FieldByName('achag').AsInteger or F.AsInteger;
    if AChag <> FieldByName('achag').AsInteger then
      FieldByName('achag').AsInteger := AChag;
  end;

  if FindField('AChag') <> nil then
    F := FindField('AChag');

  if (F <> nil) and (FindField('AView') <> nil) then
  begin
    AView := FieldByName('AView').AsInteger or F.AsInteger;
    if AView <> FieldByName('AView').AsInteger then
      FieldByName('AView').AsInteger := AView;
  end;

  inherited DoBeforePost;

  { ��. http://code.google.com/p/gedemin/issues/detail?id=2867}
  {if Assigned(MasterSource) and (MasterSource.DataSet is TgdcBase) then
  begin
    MD := MasterSource.DataSet as TgdcBase;
    if (State = dsInsert)
      and (not CachedUpdates)
      and (MD.State = dsInsert)
      and (AnsiCompareText(MasterField, MD.GetKeyField(MD.SubType)) <> 0)
      and (Transaction = MD.Transaction)
      and (MD.FIgnoreDataSet.IndexOf(Self) = -1) then
    begin
      MD.FIgnoreDataSet.Add(Self);
      try
        MD.Post;
      finally
        MD.FIgnoreDataSet.Remove(Self);
      end;
    end;
  end;}

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;
// End Event

function TgdcBase.AcceptClipboard(CD: PgdcClipboardData): Boolean;
var
  Bm: String;
  Obj: TgdcBase;
begin
  Result := False;

  if (CD.ClassName = Self.ClassName) and (CD.SubType = Self.SubType)
    and (CD.ObjectCount > 0) and (not CD.Cut) then
  begin
    Bm := Bookmark;
    if Locate('ID', CD.ObjectArr[0].ID, []) then
    begin
      Result := CopyDialog;
      if not Result then
        Bookmark := Bm;
    end else
    begin
      Obj := CgdcBase(FindClass(CD.ClassName)).CreateWithParams(Owner,
        Database,
        Transaction,
        SubType,
        'ByID',
        CD.ObjectArr[0].ID);
      try
        Obj.Open;
        if not Obj.EOF then
        begin
          Result := Obj.CopyDialog;
          if Result then
          begin
            Close;
            Open;
            Locate('ID', Obj.ID, []);
          end;
        end;
      finally
        Obj.Free;
      end;
    end;
  end;
end;

procedure TgdcBase.AfterConstruction;
begin
  inherited AfterConstruction;

  if gdcBaseManager <> nil then
  begin
    if Transaction = nil then
    begin
      FInternalTransaction := TIBTransaction.Create(nil);
      FInternalTransaction.Params.Text := 'read_committed'#13#10'rec_version'#13#10'nowait';
      FInternalTransaction.Name := 'ibtrInternal';
      FInternalTransaction.AutoStopAction := saNone;
      Transaction := FInternalTransaction;
    end;

    if gdcBaseManager.ReadTransaction <> nil then
    begin
      ReadTransaction := gdcBaseManager.ReadTransaction;

// �������� �� �� ��� Owner is TgdcBase ��������� ������, ���
// ����� ���� FreeNotification, �� �� ��������� ���� ���������� � ���, �������
// � ��� ��������� � ���� ��� ����, ���-�� ��� �������� �������, ��  ��� ���� �� �� ������
// FreeNotification, ������ �� ������������� �� ������, �� ��������� �������� ��� �� �����,
// ����� ���� ���������� ������.

      if not (Owner is TgdcBase) then
        ReadTransaction.FreeNotification(Self);
    end;

    if Database = nil then
      Database := gdcBaseManager.Database;

    if Transaction.DefaultDatabase <> Database then
      Transaction.DefaultDatabase := Database;

    FQueryFilter := TQueryFilterGDC.Create(Self);
    FQueryFilter.OnFilterChanged := DoOnFilterChanged;
    FQueryFilter.Name := 'flt_' + RemoveProhibitedSymbols(System.copy(ClassName, 2, 255));
    FQueryFilter.Database := Database;
    QueryFiltered := False;
  end;
end;

procedure TgdcBase.AssignField(const AnID: Integer;
  const AFieldName: String; AValue: Variant);
var
  Q: TIBSQL;
  Obj: TgdcBase;
  C: TClass;
  DidActivate: Boolean;
begin
  if Active then
  begin
    C := GetCurrRecordClass.gdClass;
    Obj := CgdcBase(C).CreateWithID(Owner, Database, Transaction, AnID);
    try
      Obj.Assign(Self);
      Obj.Open;
      if Obj.RecordCount > 0 then
      begin
        Obj.Edit;
        try
          if VarIsNull(AValue) then
            Obj.FieldByName(AFieldName).Clear
          else
            Obj.FieldByName(AFieldName).AsVariant := AValue;
          Obj.Post;
        except
          if Obj.State in dsEditModes then
            Obj.Cancel;
          raise;
        end;
        { TODO : �� ���� �� �� ������� ������� �� ��� ���?? }
        if Transaction.InTransaction then
          Transaction.CommitRetaining;
      end;
    finally
      Obj.Free;
    end;
  end else
  begin
    DidActivate := False;
    Q := TIBSQL.Create(nil);
    try
      Q.Database := Database;
      Q.Transaction := Transaction;
      DidActivate := ActivateTransaction;
      Q.SQL.Text := Format('UPDATE %s SET %s=:V WHERE %s=%d',
        [GetListTable(SubType), AFieldName, GetKeyField(SubType), AnID]);
      Q.Prepare;
      if VarIsNull(AValue) then
        Q.ParamByName('V').Clear
      else
        Q.ParamByName('V').AsVariant := AValue;

      Q.ExecQuery;
    finally
      if DidActivate then
        Transaction.Commit;
      Q.Free;
    end;
  end;
end;

function TgdcBase.CanPasteFromClipboard: Boolean;
begin
  Result := Active
    and Clipboard.HasFormat(gdcClipboardFormat)
    and CanEdit;
end;

procedure TgdcBase.CloseOpen;
var
  OldID: TID;
begin
  if Active and not IsEmpty then
    OldID := ID
  else
    OldID := -1;
  Close;
  Open;
  if OldID <> -1 then
    Locate(GetKeyField(SubType), OldID, []);
end;

function TgdcBase.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCBASE', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETNOTCOPYFIELD' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}//          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := GetKeyField(SubType);
  if tiCreatorKey in gdcTableInfos then
    Result := Result + ',CREATORKEY';
  if tiCreationDate in gdcTableInfos then
    Result := Result + ',CREATIONDATE';
  if tiEditorKey in gdcTableInfos then
    Result := Result + ',EDITORKEY';
  if tiEditionDate in gdcTableInfos then
    Result := Result + ',EDITIONDATE';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}
end;

function TgdcBase.TestCopyField(const FieldName, DontCopyList: String): Boolean;
var
  F: TField;
begin
  if FDataTransfer or (StrIPos(',' + FieldName + ',', ',' + DontCopyList + ',') = 0) then
  begin
    F := FindField(FieldName);
    Result := (F <> nil) and (not F.ReadOnly);
  end else
    Result := False;
end;

function TgdcBase.CopyObject(const ACopyDetailObjects: Boolean = False;
  const AShowEditDialog: Boolean = False): Boolean;
var
  MasterObject, DetailObject, CopyObject: TgdcBase;
  LinkObj, LinkCopy: TgdcBase;
  DS: TDataSource;
  C, CFull: TgdcFullClass;
  I, J: Integer;
  LinkTableList: TStringList;
  OL: TObjectList;
  F, DetailField: TField;
  DoPostRecord: Boolean;
  ErrorMessage: String;

  // �������� ������ �������
  procedure CopyRecordData(Source, Dest: TgdcBase);
  var
    I: Integer;
    DontCopyList: String;
  begin
    DontCopyList := Source.GetNotCopyField;
    for I := 0 to Dest.FieldCount - 1 do
    begin
      if Dest.TestCopyField(Dest.Fields[I].FieldName, DontCopyList)       // �� ������ �� ���� � ������ ������������ �����
         and (Assigned(Source.FindField(Dest.Fields[I].FieldName))) then
        Dest.Fields[I].Assign(Source.FieldByName(Dest.Fields[I].FieldName));
    end;
  end;

  // �������� ������������� ������ � ����� �� ���������� ������ ��� � �������������
  function CheckTheSameRecord(AObject: TgdcBase): Boolean;
  var
    ibsql: TIBSQL;
    ChkStm: String;
  begin
    ChkStm := AObject.CheckTheSameStatement;
    if ChkStm = '' then
      Result := False
    else begin
      ibsql := TIBSQL.Create(nil);
      try
        if Transaction.Active then
          ibsql.Transaction := Transaction
        else
          ibsql.Transaction := gdcBaseManager.ReadTransaction;
        ibsql.SQL.Text := ChkStm;
        ibsql.ExecQuery;
        Result := not ibsql.EOF;
      finally
        ibsql.Free;
      end;
    end;
  end;

  procedure SetNewListFieldValue(AObject: TgdcBase);
  var
    ListField: TField;
  begin
    // ������� ���� �����������
    ListField := AObject.FindField(AObject.GetListField(AObject.SubType));
    if Assigned(ListField) then
    begin
      // ���� ListField - VARCHAR �� ���������� COPY
      if ListField.DataType = ftString then
        ListField.AsString := ListField.AsString + '_COPY';
    end;
  end;

  // ������� �������� ����� �� ������ ����-���������,
  // � ASetFKeyList ����� �������� ������� ������ �� ������-��������
  function IsHaveSetRecords(AObject: TgdcBase; ASetFKeyList: TObjectList = nil): Boolean;
  var
    SetLinkTableList: TStringList;
    OL: TObjectList;
    I, J: Integer;
  begin
    // ����� ������ �������������� � ������� (1-�-1)
    SetLinkTableList := TStringList.Create;
    OL := TObjectList.Create(False);
    try
      atDatabase.ForeignKeys.ConstraintsByReferencedRelation(AObject.GetListTable(AObject.SubType), OL);
      for I := 0 to OL.Count - 1 do
        with OL[I] as TatForeignKey do
      begin
        if IsSimpleKey
          and (Relation.PrimaryKey <> nil)
          and (Relation.PrimaryKey.ConstraintFields.Count = 1)
          and (ConstraintField = Relation.PrimaryKey.ConstraintFields[0]) then
        begin
          SetLinkTableList.Add(Relation.RelationName);
        end;
      end;

      SetLinkTableList.Add(AObject.GetListTable(AObject.SubType));
      // ���� �� ��������
      for I := 0 to SetLinkTableList.Count - 1 do
      begin
        // ����� ������� ������ �� ������-��������
        atDatabase.ForeignKeys.ConstraintsByReferencedRelation(SetLinkTableList[I], OL);
        for J := 0 to OL.Count - 1 do
          with OL[J] as TatForeignKey do
          begin
            if (Relation.PrimaryKey <> nil)
              and (Relation.PrimaryKey.ConstraintFields.Count > 1)
              and (Relation.PrimaryKey.ConstraintFields[0] = ConstraintField) then
            begin
              if Assigned(ASetFKeyList) then
              begin
                // ���� ������� ������, �� ������� ������ � ����
                ASetFKeyList.Add(OL[J]);
              end
              else
              begin
                // ����� ������ ������� ��� ������ ���� � ������ �� �������
                Result := True;
                Exit;
              end;
            end;
          end;
      end;
    finally
      OL.Free;
      SetLinkTableList.Free;
    end;

    // ���� ������ ������������ ���������� True, ����� False
    if Assigned(ASetFKeyList) and (ASetFKeyList.Count > 0) then
      Result := True
    else
      Result := False;
  end;

  // ����������� ������ ��������-��������
  procedure CopyRecordSetData(Source, Dest: TgdcBase);
  var
    I, K: Integer;
    qIn, qOut: TIBSQL;
    DidActivate: Boolean;
  begin
    if Source.SetAttributesCount = 0 then
      exit;

    qIn := TIBSQL.Create(nil);
    qIn.Transaction := Dest.Transaction;

    qOut := TIBSQL.Create(nil);
    qOut.Transaction := Dest.Transaction;

    if not Dest.Transaction.InTransaction then
    begin
      Dest.Transaction.StartTransaction;
      DidActivate := True;
    end else
      DidActivate := False;

    try
      for I := 0 to Source.SetAttributesCount - 1 do
      begin
        qOut.SQL.Text := Source.SetAttributes[I].InsertSQL;

        qIn.Close;
        qIn.SQL.Text := Source.SetAttributes[I].SQL;
        qIn.ParamByName('rf').AsInteger := Source.ID;
        qIn.ExecQuery;
        while not qIn.EOF do
        begin
          for K := 0 to qIn.Current.Count - 1 do
          begin
            if CompareText(qIn.Fields[K].Name, Source.SetAttributes[I].ReferenceObjectNameFieldName) = 0 then
              continue;

            if CompareText(qIn.Fields[K].Name, Source.SetAttributes[I].ObjectLinkFieldName) = 0 then
              qOut.ParamByName(qIn.Fields[K].Name).AsInteger := Dest.ID
            else
              qOut.ParamByName(qIn.Fields[K].Name).Assign(qIn.Fields[K]);
          end;

          qOut.ExecQuery;
          qIn.Next;
        end;
      end;
      if DidActivate and Dest.Transaction.InTransaction then
        Dest.Transaction.Commit;
    finally
      qIn.Free;
      qOut.Free;
      if DidActivate and Dest.Transaction.InTransaction then
        Dest.Transaction.Rollback;
    end;
  end;

begin
  CheckBrowseMode;

  C := GetCurrRecordClass;
  // ���� ���������� ������ ���� �� ������ � �������� ��� � Self
  if (C.gdClass = Self.ClassType) and (C.SubType = Self.SubType) then
  begin
    // �������� ������� ������ ���� �� ������, ��� � ����������, ��������� ��������������� ������ �� ��������� ������
    MasterObject := C.gdClass.CreateWithParams(Owner,
      Database,
      Transaction,
      C.SubType,
      'ByID',
      Self.ID);
    MasterObject.ReadTransaction := Self.ReadTransaction;
    CopyEventHandlers(MasterObject, Self);

    // ������ ��� ������ ��������� � ��������� �����������
    Include(FBaseState, sCopy);
    // �������� ID ����������� ������� (����� ������������ �� _DoOnNewRecord ������������� ������)
    FCopiedObjectKey := Self.ID;

    LinkTableList := TStringList.Create;
    try
      MasterObject.Open;

      // ���� ����� ��������: ���������� ���������. ����� ���������� ���������
      // � �������������� ������� TgdcAttrUserDefined, ��������� ������ ����-�-������
      // � ���������. ��, �� ����� ��������� ���������� ���, �� ��������� �
      // ������������ ������ �� ���������� ����. ��������������, ��� �����������
      // ������ �� ���� �� ����������. ������, �� ����� ��� ��������.
      OL := TObjectList.Create(False);
      try
        atDatabase.ForeignKeys.ConstraintsByReferencedRelation(GetListTable(SubType), OL);
        for I := 0 to OL.Count - 1 do
          with OL[I] as TatForeignKey do
          begin
            if IsSimpleKey
              and Assigned(Relation.PrimaryKey)
              and (Relation.PrimaryKey.ConstraintFields.Count = 1)
              and (ConstraintField = Relation.PrimaryKey.ConstraintFields[0])
              and (Pos('USR$', Relation.RelationName) = 1) then
            begin
              if GetBaseClassForRelation(Relation.RelationName).gdClass.ClassName = 'TgdcAttrUserDefined' then
              begin
                // ��������, ��� �� ����� ������������ ��� ������-������
                // ��������� � ����� ��������. ��������� ��� ����������
                // ����������� ��������� (���������) �������� ���� ���� (���� �������� ����������� ��������� ��������).
                for J := 0 to Self.DetailLinksCount - 1 do
                begin
                  if AnsiCompareText(
                       TgdcBase(Self.DetailLinks[J]).GetListTable(TgdcBase(Self.DetailLinks[J]).SubType), Relation.RelationName) = 0 then
                    Break;

                  if J = Self.DetailLinksCount - 1 then
                    LinkTableList.Add(AnsiUpperCase(Relation.RelationName));
                end;
              end;
            end;
          end;
      finally
        OL.Free;
      end;

      // ���� � ������� ��� �������������� ������� 1-�-1 � ������� ��������, ��
      //  �� ����� ������ Post ������, ����� ������� � ���������� ������ ��� Post
      if (LinkTableList.Count > 0) or (SetAttributesCount > 0) or ACopyDetailObjects then
        DoPostRecord := True
      else
        DoPostRecord := False;

      // ����� �������������� ��� ����� ��������� �������� � ���������������� �������
      DS := TDataSource.Create(Owner);
      try
        DS.Dataset := MasterObject;
        // ����������� ��������� ������-��������
        if DoPostRecord and ACopyDetailObjects then
        begin
          for I := 0 to Self.DetailLinksCount - 1 do
          begin
            // �������� ����� ������� ������ ���������� �������
            C := TgdcBase(Self.DetailLinks[I]).GetCurrRecordClass;
            DetailObject := C.gdClass.CreateWithParams(Owner,
                Database,
                Transaction,
                TgdcBase(Self.DetailLinks[I]).SubType,
                TgdcBase(Self.DetailLinks[I]).SubSet,
                -1);
            // ��������� ����������� ������� ���������� �������
            CopyEventHandlers(DetailObject, Self.DetailLinks[I]);
            // ��������� ��������� ����� master-detail
            DetailObject.MasterSource := DS;
            DetailObject.MasterField := Self.DetailLinks[I].MasterField;
            DetailObject.DetailField := Self.DetailLinks[I].DetailField;
            DetailObject.Open;
            // ������� ��������� ��������� ������ � ������ MasterObject'�
            MasterObject.AddDetailLink(DetailObject);
          end;
        end;

        // �������� ����� ������
        Self.Insert;
        try
          // ����������� ������ ����� ������
          CopyRecordData(MasterObject, Self);
          // �� ����� ��������� ����� ��������� ������
          if (Self is TgdcDocument) and Self.FieldByName('number').IsNull then
            Self.FieldByName('number').AsString := ' ';

          if DoPostRecord then
          begin
            // ���� ���������� ����� �� ������ (� ������ ���������� ������)
            //  �� ���������� �������� �������� ������ �����
            if CheckTheSameRecord(Self) then
              SetNewListFieldValue(Self);
            try
              Self.Post;
            except
              on E: Exception do
              begin
                // ������� ������ � dsInsert, �������������� �� ����� ���������� 1-�-1, ��������� � ���������
                DoPostRecord := False;

                ErrorMessage := '�� ������� ����������� ��� ���� ������������ ������. ��������� ������������ ����������!';
                // �������������� ������� ����� � ����� ������
                if IBLogin.IsUserAdmin then
                  ErrorMessage := ErrorMessage + #13#10 + E.Message;
                // ������� ���������
                MessageBox(ParentHandle, PChar(ErrorMessage), '��������', MB_OK or MB_ICONINFORMATION);
              end;
            end;
          end;

          // ����������� ��������-��������
          if DoPostRecord then
            CopyRecordSetData(MasterObject, Self);
        except
          if Self.State in dsEditModes then
            Self.Cancel;
          raise;
        end;

        if DoPostRecord then
        begin
          // ����������� ������� 1-�-1 ��� ������ �������
          for I := 0 to LinkTableList.Count - 1 do
          begin
            CFull := GetBaseClassForRelation(LinkTableList[I]);
            LinkObj := CFull.gdClass.CreateWithParams(Owner,
              Database,
              Transaction,
              CFull.SubType,
              'ByID',
              MasterObject.ID);
            try
              LinkObj.Open;
              if not LinkObj.EOF then
              begin
                LinkCopy := CFull.gdClass.CreateWithParams(Owner,
                  Database,
                  Transaction,
                  CFull.SubType,
                  'ByID',
                  -1);
                try
                  LinkCopy.Open;
                  // ������ ��� ������ ��������� � ��������� �����������
                  LinkCopy.BaseState := LinkCopy.BaseState + [sCopy];
                  LinkCopy.Insert;
                  CopyRecordData(LinkObj, LinkCopy);
                  LinkCopy.ID := Self.ID;
                  LinkCopy.Post;
                  CopyRecordSetData(LinkObj, LinkCopy);
                finally
                  LinkCopy.Free;
                end;
              end;
            finally
              LinkObj.Free;
            end;
          end;
        end;

        // ���� ���� ����������, �� ��������� ����� ��������� �������
        if DoPostRecord and ACopyDetailObjects then
        begin
          for I := 0 to MasterObject.DetailLinksCount - 1 do
          begin
            // �� ����� ����� ���� ��������� ��������, ������������
            // � ������. ���������� ����� ������: �� ����� ����� ������ ���������,
            // ������ ������� ��������� � ������ ������. ��� ���������, ����������
            // ��� ��������� � ���������. ��������, ��� ��� �����������, ������
            // ������ �� ������� �������.
            F := MasterObject.FindField(MasterObject.DetailLinks[I].MasterField);
            if Assigned(F) and (F is TIntegerField) and (MasterObject.ID = F.AsInteger) then
            begin
              // ������ ��� ������ ��������� � ��������� �����������
              Self.DetailLinks[I].BaseState := Self.DetailLinks[I].BaseState + [sCopy];
              try
                // �������� �� ������ ������
                MasterObject.DetailLinks[I].First;
                while not MasterObject.DetailLinks[I].Eof do
                begin
                  // �������� ID ������������ ��������� ������
                  Self.DetailLinks[I].CopiedObjectKey := MasterObject.DetailLinks[I].ID;
                  // ������� ���������� �������
                  Self.DetailLinks[I].Insert;
                  try
                    CopyRecordData(MasterObject.DetailLinks[I], Self.DetailLinks[I]);
                    // ��������� ������ �� ������ master
                    DetailField := Self.DetailLinks[I].FindField(Self.DetailLinks[I].GetFieldNameComparedToParam(Self.DetailLinks[I].DetailField));
                    if Assigned(DetailField) then
                    begin
                      if DetailField.AsInteger <> Self.ID then
                        DetailField.AsInteger := Self.ID;
                    end;
                    Self.DetailLinks[I].Post;
                    // ����������� ������ �������� ��������� � ��������
                    CopyRecordSetData(MasterObject.DetailLinks[I], Self.DetailLinks[I]);
                    // ������� ID ����������� �������
                    Self.DetailLinks[I].CopiedObjectKey := -1;
                  except
                    on E: Exception do
                    begin
                      if Self.DetailLinks[I].State in dsEditModes then
                        Self.DetailLinks[I].Cancel;
                      MessageBox(ParentHandle,
                        PChar(Format('������ ����������� ���������� �������: '#13#10'"%s"',
                          [E.Message])),
                        '��������',
                        MB_OK or MB_ICONERROR);
                    end;
                  end;
                  MasterObject.DetailLinks[I].Next;
                end;
              finally
                // ������ ��� ������ ����� �� ��������� �����������
                Self.DetailLinks[I].BaseState := Self.DetailLinks[I].BaseState - [sCopy];
              end;
            end;
          end;
        end;
      finally
        DS.Free;
      end;

      // ���� ���������� ��������, ������� ������ �������������� �������������� �������
      if AShowEditDialog then
      begin
        FDSModified := True;
        if not Self.EditDialog then
        begin
          if DoPostRecord then
            Self.Delete
          else if Self.State in dsEditModes then
            Self.Cancel;
        end
      end
      else
      begin
        if not DoPostRecord then
        begin
          // ���� ���������� ����� �� ������ (� ������ ���������� ������)
          //  �� ���������� �������� �������� ������ �����
          if CheckTheSameRecord(Self) then
            SetNewListFieldValue(Self);
          Self.Post;
        end;
      end;
    finally
      FreeAndNil(LinkTableList);
      // ������� ID ����������� �������
      FCopiedObjectKey := -1;
      // ������ ��� ������ ������� �� ��������� �����������
      Exclude(FBaseState, sCopy);

      // ������ ��������� �������, �������������� ��� �����������
      while MasterObject.DetailLinksCount > 0 do
        MasterObject.DetailLinks[0].Free;

      MasterObject.Free;
    end;

    Result := True;
  end
  else
  begin
    // ���� ���������� ������ ���������� ������� ��� ��������� �� Self,
    //  �� �������� ��� ���� ��������� ��, ��������� ������, � ��������� ��������� � Self
    CopyObject := C.gdClass.CreateWithParams(Owner,
      Database,
      Transaction,
      C.SubType,
      'ByID',
      ID);
    try
      CopyEventHandlers(CopyObject, Self);
      try
        CopyObject.Open;
        // ������� ����������� � �� ����������� ������ � ��������
        Result := CopyObject.CopyObject(ACopyDetailObjects, AShowEditDialog);
        // ���� ������������ ���������� ����������� - ��������� ��������� � ������� Self
        if Result and Active and CopyObject.Active then
        begin
          FDataTransfer := True;
          ResetEventHandlers(Self);
          try
            Insert;
            try
              CopyRecordData(CopyObject, Self);
              Post;
            except
              if State in dsEditModes then
                Cancel;
              raise;
            end;
          finally
            FDataTransfer := False;
          end;
        end;
      finally
        CopyEventHandlers(Self, CopyObject);
      end;
    finally
      FreeAndNil(CopyObject);
    end;
  end;
end;

function TgdcBase.Copy(const AFields: String;
  AValues: Variant;
  const ACopyDetail: Boolean = False;
  const APost: Boolean = True;
  const AnAppend: Boolean = False): Boolean;
var
  V: array of Variant;
  I: Integer;
  L: TList;
  C: TgdcFullClass;
  Obj: TgdcBase;
  F: TField;
  DontCopyList: String;
begin
  CheckBrowseMode;

  C := GetCurrRecordClass;

  if (C.gdClass = Self.ClassType) and (C.SubType = Self.SubType) then
  begin

    // ������ �������� ����� ������ ���� ����������� ��������
    if (AFields > '') and (not VarIsArray(AValues)) then
      AValues := VarArrayOf([AValues]);

    // �������� �������� ������� ������
    SetLength(V, FieldCount);
    for I := 0 to FieldCount - 1 do
    begin
      if Fields[I].IsNull then
        V[I] := Fields[I].Value
      else
        V[I] := Fields[I].AsString;
    end;

    // ������� ����� � ��������� � ��� �������� �����
    // �������� ������, ����� ���������� �����
    // � �����, ��� ������� ������ ������ ��������
    {
    if AnAppend then
      Append
    else
      Insert;
    try
      DuplicateRow(Self, AFields, AValues);
    except
      if State in dsEditModes then
        Cancel;
      raise;
    end;
    }

    L := TList.Create;
    try
      GetFieldList(L, AFields);
      if AnAppend then
        Append
      else
        Insert;
      try
        DontCopyList := GetNotCopyField;
        for I := 0 to FieldCount - 1 do
          if L.IndexOf(Fields[I]) >= 0 then
            Fields[I].AsVariant := AValues[L.IndexOf(Fields[I])]
          else
            if TestCopyField(Fields[I].FieldName, DontCopyList) then
            begin
              if VarIsNull(V[I]) then
                Fields[I].Clear
              else
                Fields[I].AsString := V[I];
            end;
        if APost then
          Post;
      except
        if State in dsEditModes then
          Cancel;
        raise;
      end;
    finally
      L.Free;
    end;

    Result := True;
  end
  else
  begin
    Obj := C.gdClass.CreateWithParams(Owner,
      Database,
      Transaction,
      C.SubType,
      'ByID',
      ID);
    try
      CopyEventHandlers(Obj, Self);
      try
        Obj.Open;
        Result := Obj.Copy(AFields, AValues, ACopyDetail, True);
        if Result and Active and Obj.Active then
        begin
          FDataTransfer := True;
          ResetEventHandlers(Self);
          try
            if AnAppend then
              Append
            else
              Insert;
            try
              DontCopyList := GetNotCopyField;
              for I := 0 to FieldCount - 1 do
              begin
                F := Obj.FindField(Fields[I].FieldName);
                if Assigned(F) and TestCopyField(Fields[I].FieldName, DontCopyList) then
                begin
                  Fields[I].Assign(F);
                end;
              end;
              Post;
            except
              if State in dsEditModes then
                Cancel;
              raise;
            end;
          finally
            FDataTransfer := False;
          end;
        end;
      finally
        CopyEventHandlers(Self, Obj);
      end;
    finally
      Obj.Free;
    end;
  end;
end;

function TgdcBase.CopyWithDetail: Boolean;
begin
  Result := Self.CopyObject(True);
end;

{

������� ���������� ����������� ������ �� ����� RDB$ �������, � ����� atDatabase!
��� ��� ��������� �������� ���������� � � ���������������� ������� ������.

procedure TgdcBase.CopyDetailTable(const AMasterTableName: String;
  const AnOldID, ANewID: Integer);
var
  q: TIBSQL;
  ibtS: TIBQuery;
  ibtD: TIBTable;
  I: Integer;
  DidActivate: Boolean;
begin
  DidActivate := False;
  q := TIBSQL.Create(Self);
  ibtS := TIBQuery.Create(Self);
  ibtD := TIBTable.Create(Self);
  try
    q.Database := Database;
    q.Transaction := Transaction;

    ibtS.Database := Database;
    ibtS.Transaction := Transaction;
    ibtS.Unidirectional := True;

    ibtD.Database := Database;
    ibtD.Transaction := Transaction;
    ibtD.Unidirectional := True;

    DidActivate := ActivateTransaction;

    // ������������ ������ ������ � ������������� ������
    // �������� ������ ����������� ������, ��� ����
    // ������ ��� (����-������ �� ������� �������), ���
    // ���� ���������� ����� � ������� �������
    q.SQL.Text :=
      'SELECT rc2.rdb$relation_name, is1.rdb$field_name, is2.rdb$field_name ' +
      'FROM ' +
      '  rdb$relation_constraints rc ' +
      '  JOIN rdb$ref_constraints rf ' +
      '    ON rc.rdb$constraint_name = rf.rdb$const_name_uq ' +
      '    AND rc.rdb$relation_name = :RN AND rc.rdb$constraint_type = ''PRIMARY KEY'' ' +
      '  JOIN rdb$relation_constraints rc2 ' +
      '    ON rc2.rdb$constraint_name = rf.rdb$constraint_name ' +
      '    AND rc2.rdb$constraint_type = ''FOREIGN KEY'' ' +
      '  JOIN rdb$indices ri ' +
      '    ON ri.rdb$index_name = rc2.rdb$index_name ' +
      '  JOIN rdb$index_segments is1 ' +
      '    ON is1.rdb$index_name = ri.rdb$index_name ' +
      '  JOIN rdb$indices ri2 ' +
      '    ON ri2.rdb$index_name = rc.rdb$index_name ' +
      '  JOIN rdb$index_segments is2 ' +
      '    ON is2.rdb$index_name = ri2.rdb$index_name ' +
      ' ';
    q.Prepare;
    q.ParamByName('RN').AsString := GetListTable(SubType);
    q.ExecQuery;

    while not q.EOF do
    begin
      ibtS.SQL.Text := Format('SELECT * FROM %s WHERE %s=%d',
        [q.Fields[0].AsString, q.Fields[1].AsString, AnOldID]);
      ibtS.Open;

      ibtD.TableName := q.Fields[0].AsString;
      ibtD.Open;

      ibtS.First;
      while not ibtS.EOF do
      begin
        ibtD.Insert;
        try
          for I := 0 to ibtS.FieldCount - 1 do
            if AnsiCompareText(ibtS.Fields[I].FieldName, Trim(q.Fields[1].AsString)) = 0 then
              ibtD.FieldByName(ibtS.Fields[I].FieldName).AsInteger := ANewID
            else if AnsiCompareText(ibtS.Fields[I].FieldName, Trim(q.Fields[2].AsString)) = 0 then
              ibtD.FieldByName(ibtS.Fields[I].FieldName).Clear
            else if (not ((db.faReadOnly in ibtD.FieldDefList[I].Attributes) and (ibtD.FieldDefList[I].InternalCalcField = True))) then
              ibtD.FieldByName(ibtS.Fields[I].FieldName).Assign(ibtS.Fields[I]);

          ibtD.Post;
        except
          if ibtD.State in dsEditModes then
            ibtD.Cancel;
          raise;
        end;
        ibtS.Next;
      end;
      ibtS.Close;
      ibtD.Close;

      q.Next;
    end;

    q.Close;
  finally
    if DidActivate then
      Transaction.Commit;

    q.Free;
    ibtS.Free;
    ibtD.Free;
  end;
end;}

function TgdcBase.CopyDialog: Boolean;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  UserChoice: Boolean;
begin
  {@UNFOLD MACRO INH_ORIG_COPYDIALOG('TGDCBASE', 'COPYDIALOG', KEYCOPYDIALOG)}
  {M}//  Result := False;
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYCOPYDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCOPYDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'COPYDIALOG', KEYCOPYDIALOG, Params, LResult) then
  {M}          begin
  {M}            Result := False;
  {M}            if VarType(LResult) = varBoolean then
  {M}              Result := Boolean(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'COPYDIALOG' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Result := False;//Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  // �� �� ����� ������ ��� ��������� DetailLinksCount
  // ��� ��� ������������ ������� ����� ���� �� ������ ����������.
  // ��������, �� ���� � ����������� ���� �������������� ������
  // Attachment. �� �� ��������� � �����. ����������, ���
  // � ����� ������, ������� �� �� DetailLinksCount, ������
  // ���������� ������ � ���������� ��� �� �� � �����.
  // ����� ���������? ������� �� ������������. 
  if (sView in BaseState)
    and (Owner is Tgdc_frmMDH)
    and (Tgdc_frmMDH(Owner).gdcObject = Self)
    and (DetailLinksCount > 0) then
  begin
    case MessageBox(ParentHandle,
      '���������� ������ � ���������?',
      '��������',
      MB_YESNOCANCEL or MB_ICONQUESTION or MB_TASKMODAL) of
      IDYES: UserChoice := True;
      IDNO: UserChoice := False;
    else
      begin
        Result := False;
        exit;
      end;
    end;
  end
  else
    UserChoice := True;

  if (DetailLinksCount > 0) and UserChoice then
    Result := CopyObject(True, True)
  else
    Result := CopyObject(False, True);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'COPYDIALOG', KEYCOPYDIALOG)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'COPYDIALOG', KEYCOPYDIALOG);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.CopyToClipboard(BL: TBookmarkList; const ACut: Boolean = False);
var
  H: THandle;
  P: PgdcClipboardData;
  I, IC: Integer;
  Accept: Boolean;
  C: TgdcFullClass;
begin
  if (not Active) or IsEmpty then
    raise EgdcException.Create('Dataset is not active or empty');

  if BL <> nil then
    BL.Refresh;

  if (BL = nil) or (BL.Count = 0) then IC := 1 else
    IC := BL.Count;
  H := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE,
    SizeOf(TgdcClipboardData) -
    SizeOf(TObjectArr) + IC * SizeOf(TObjectData));
  if H <> 0 then
  begin
    P := GlobalLock(H);
    if P <> nil then
    begin
      P^.Signature := gdcCurrentClipboardSignature;
      P^.Version := gdcCurrentClipboardVersion;
      StrPCopy(P^.ClassName, System.Copy(Self.ClassName, 1, 63));
      StrPCopy(P^.SubType, System.Copy(Self.SubType, 1, 63));
      P^.Obj := Self;
      P^.Cut := ACut;
      P^.ObjectCount := IC;
      if (BL = nil) or (BL.Count = 0) then
      begin
        P^.ObjectArr[0].ID := Self.ID;
        StrPLCopy(P^.ObjectArr[0].ObjectName, Self.ObjectName, 63);
        C := GetCurrRecordClass;
        StrPLCopy(P^.ObjectArr[0].ClassName, C.gdClass.ClassName, 63);
        StrPLCopy(P^.ObjectArr[0].SubType, C.SubType, 63);
      end else
      begin
        try
          for I := 0 to BL.Count - 1 do
          begin
            FPeekBuffer := FBufferCache + PInteger(BL[I])^ * _RecordBufferSize;

            if PRecordData(FPeekBuffer)^.rdUpdateStatus = usDeleted then
              continue;

            if Filtered and Assigned(OnFilterRecord) then
            begin
              Accept := True;
              OnFilterRecord(Self, Accept);
              if not Accept then
                continue;
            end;

            P^.ObjectArr[I].ID := FieldByName(GetKeyField(SubType)).AsInteger;
            StrPLCopy(P^.ObjectArr[I].ObjectName, Self.ObjectName, 63);
            C := GetCurrRecordClass;
            StrPLCopy(P^.ObjectArr[I].ClassName, C.gdClass.ClassName, 63);
            StrPLCopy(P^.ObjectArr[I].SubType, C.SubType, 63);
          end;
        finally
          FPeekBuffer := nil;
        end;
      end;
      GlobalUnlock(H);
      Clipboard.SetAsHandle(gdcClipboardFormat, H);
    end;
  end;
end;

constructor TgdcBase.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FReadUserFromStream := False;
  FIsInternalMasterSource := False;
  FVariables := nil;//TgdVariables.Create;
  FObjects := nil;//TgdObjects.Create;

  FIgnoreDataSet := TObjectList.Create(False);

  FUseScriptMethod := True;
  FIsNewRecord := False;
  FQueryFiltered := DefQueryFiltered;

  FAfterInitSQL := nil;
  FSQLInitialized := False;
  FGetDialogDefaultsFieldsCached := False;
  FSavedParams := TObjectList.Create(True);
  FRefreshMaster := False;

  FSubSets := TStringList.Create;
  FSubSets.Sorted := False;
  FSubSets.Duplicates := dupError;
  FSubSets.Add('All');

  FBaseState := [];
  FID := -1;
  FGroupID := -1;
  FObjectName := '';
  FSQLSetup := TatSQLSetup.Create(nil);
  FExtraConditions := TStringList.Create;
  FExtraConditions.OnChange := DoAfterExtraChanged;
  FDSModified := False;
  FDlgStack := TObjectStack.Create;

  FQueryFilter := nil;

  FBeforeShowDialog := nil;
  FAfterShowDialog := nil;

{ TODO :
����� �� ������ ����! ������ ������� ������������ ��������
� �� ������ ����� ��������!

��������, ����� �������� ��������. ������ ���� ��� ����������
������������ ����. ������� ������ ������� ������ �������� ���
������ ���������. ����� ������ �������� �� �����������.
}
  FCustomProcess := [];
  FgdcDataLink := TgdcDataLink.Create(Self);
  FDetailLinks := TObjectList.Create(False);

  if AnOwner is TWinControl then
  begin
    FParentForm := AnOwner as TWinControl;

    if FParentForm is TgdcCreateableForm then
      Include(FBaseState, sView);
  end else
    FParentForm := nil;

  FSubType := '';

  gdcObjectList.Add(Self);

  FNameInScript := '';
  FEventList := TStringList.Create;
  LoadEventList;

  FSelectedID := TgdKeyArray.Create;
  FSelectedID.Sorted := False;
  FSelectedID.OnChange := DoAfterSelectedChanged;

  FgdcTableInfos := GetTableInfos(FSubType);

  FClassMethodAssoc := TgdKeyIntAndStrAssoc.Create;

  if Assigned(InheritedMethodInvoker) and (not UnMethodMacro) then
    InheritedMethodInvoker.RegisterMethodInvoker(Self, OnInvoker);

  FFieldsCallDoChange := TStringList.Create;
  FFieldsCallDoChange.Sorted := True;
  FFieldsCallDoChange.Duplicates := dupIgnore;

  CreateKeyList;
  FModifyFromStream := NeedModifyFromStream(SubType);

  FSetRefreshSQLOn := True;
  FStreamXID := -1;
  FStreamDBID := -1;

  Self.StreamSilentProcessing := False;
  Self.StreamProcessingAnswer := mrNone;
end;

procedure TgdcBase.Prepare;
begin
  InternalPrepare;
end;

function TgdcBase.CreateDialog(const ADlgClassName: String = ''): Boolean;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  DlgForm: TCreateableForm;
  InTransaction: Boolean;
  C: TClass;
  FormClass: String;
  FSavePoint: String;
  NewID: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_CREATEDIALOG('TGDCBASE', 'CREATEDIALOG', KEYCREATEDIALOG)}
  {M}  Result := False;
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYCREATEDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ADlgClassName]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'CREATEDIALOG', KEYCREATEDIALOG, Params, LResult) then
  {M}          begin
  {M}            Result := False;
  {M}            if VarType(LResult) = varBoolean then
  {M}              Result := Boolean(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'CREATEDIALOG' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Result := False;//Inherited CreateDialog(ADlgClassName);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if (not CanCreate) and (not IBLogin.IsUserAdmin) then
    raise EgdcUserHaventRights.CreateFmt(strHaventRights,
      [strCreate, ClassName, SubType, GetDisplayName(SubType)]);

  DlgForm := nil;

  if ADlgClassName <> '' then
  begin
    if Assigned(GlobalStorage) then
    begin
      FormClass := GlobalStorage.ReadString(st_ds_NewFormPath + '\' + ADlgClassName, st_ds_FormClass);
      if FormClass <> '' then
      begin
        C := GetClass(FormClass);
        if Assigned(C) then
        begin
          DlgForm := CCreateableForm(C).CreateUser(FParentForm, ADlgClassName)
        end;
      end;
    end;
  end;

  if DlgForm = nil then
    DlgForm := CreateDialogForm;

  if not Assigned(DlgForm) then
  begin
    Result := False;
    exit;
  end;

  if not (DlgForm is Tgdc_dlgG) then
  begin
    DlgForm.Free;
    Result := False;
    exit;
  end;

  with DlgForm as Tgdc_dlgG do
  try
    FSavepoint := '';
    InTransaction := Transaction.InTransaction;
    try
      {savepoints support}
      if InTransaction and UseSavepoints then
      begin
        FSavepoint := 'S' + System.Copy(StringReplace(
          StringReplace(
            StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
            '-', '', [rfReplaceAll]), 1, 30);
        try
          Transaction.SetSavePoint(FSavepoint);
        except
          UseSavepoints := False;
          FSavepoint := '';
        end;
      end;
      {end savepoints support}

      try
        FDlgStack.Push(DlgForm);

        if not Self.Active then
          Open;

        if Self.State <> dsInsert then
          Self.Insert;

        NewID := Self.ID;

        if sDialog in FBaseState then
        begin
          Include(FBaseState, sSubDialog);
        end else
          Include(FBaseState, sDialog);

        if not CanView then
        begin
          raise EgdcUserHaventRights.CreateFmt(strHaventRights,
            [strView, ClassName, SubType, GetDisplayName(SubType)]);
        end;

        LoadDialogDefaults;

        Setup(Self);

        DoBeforeShowDialog(DlgForm);
        Result := (ShowModal = mrOk) or MultipleCreated;
        if IBLogin.Database.Connected then
        begin
          DoAfterShowDialog(DlgForm, Result);

          if ModalResult = mrOk then
            SaveDialogDefaults;

          if not (sSubDialog in FBaseState) then
          begin
            if Self.State in dsEditModes then
              if ModalResult = mrOk then
                Self.Post
              else
                Self.Cancel;

            if Transaction.InTransaction then
            begin
              if (not InTransaction) then
              begin
                if Result then
                  Transaction.Commit
                else
                  Transaction.Rollback;

                {$IFDEF DEBUG}
                OutputDebugString('���� �� ������� ����������');
                {$ENDIF}
              end else
              begin
                if FSavePoint > '' then
                begin
                  if (ModalResult <> mrOk) then
                  begin
                    try
                      Transaction.RollBackToSavePoint(FSavepoint);
                      Transaction.ReleaseSavePoint(FSavepoint);
                      FSavepoint := '';
                    except
                      FSavepoint := '';
                    end;
                  end else
                  begin
                    try
                      Transaction.ReleaseSavePoint(FSavepoint);
                      FSavepoint := '';
                    except
                      FSavepoint := '';
                    end;
                  end;
                end;
              end;
            end;
          end else
          begin
            if (ModalResult <> mrOk) and Transaction.InTransaction
              and (FSavepoint > '') then
            begin
              try
                Transaction.RollBackToSavePoint(FSavepoint);
                Transaction.ReleaseSavePoint(FSavepoint);
                FSavepoint := '';
              except
                FSavepoint := '';
              end;
            end;
          end;

          if not (sSubDialog in BaseState) then
          begin
            if ModalResult <> mrOk then
            begin
              if ((CustomProcess * [cpInsert, cpModify]) <> [])
                or (NewID = Self.ID) then
              begin
                Self.Refresh;
              end;
            end;
          end;
        end;
      except
        if Self.State in dsEditModes then
          Self.Cancel;

        raise;
      end;
    except
      if Transaction.InTransaction then
      begin
        if InTransaction then
        begin
          if FSavepoint = '' then
            Transaction.RollbackRetaining
          else
          begin
            try
              Transaction.RollBackToSavePoint(FSavepoint);
              Transaction.ReleaseSavePoint(FSavepoint);
            except
            end;
          end;
        end else
          Transaction.Rollback;
      end;

      raise;
    end;
  finally
    if sSubDialog in FBaseState then
    begin
      Exclude(FBaseState, sSubDialog);
    end else
      Exclude(FBaseState, sDialog);

    FDlgStack.Pop;

    Free;

    if not IBLogin.Database.Connected then
      IBLogin.ConnectionLostMessage;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'CREATEDIALOG', KEYCREATEDIALOG)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'CREATEDIALOG', KEYCREATEDIALOG);
  {M}  end;
  {END MACRO}
end;

function TgdcBase.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCBASE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'CREATEDIALOGFORM', KEYCREATEDIALOGFORM, Params, LResult) then
  {M}          begin
  {M}            Result := nil;
  {M}            if VarType(LResult) <> varDispatch then
  {M}              raise Exception.Create('������-�������: ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + '��� ������ ''' +
  {M}                'CREATEDIALOGFORM' + ' ''' + '������ ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + #10#13 + '�� ������� ��������� �� ������.')
  {M}            else
  {M}              if IDispatch(LResult) = nil then
  {M}                raise Exception.Create('������-�������: ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + '��� ������ ''' +
  {M}                  'CREATEDIALOGFORM' + ' ''' + '������ ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + #10#13 + '�� ������� ��������� ������ (null) ������.');
  {M}            Result := GetInterfaceToObject(LResult) as TCreateableForm;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Result := nil;//Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := TgdFormEntry(gdClassList.Get(TgdFormEntry, GetDialogFormClassName(SubType), SubType)).frmClass.CreateSubType(FParentForm, SubType);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.CreateNext;
begin
  CheckActive;
  if State in dsEditModes then
    Post;
  if [sDialog, sSubDialog] * BaseState = [sDialog] then
  begin
    SaveDialogDefaults;
    Insert;
    LoadDialogDefaults;
  end else
    Insert;
end;

class function TgdcBase.CreateSingularByID(AnOwner: TComponent;
  ADatabase: TIBDatabase; ATransaction: TIBTransaction;
  const AnID: TID; const ASubType: String = ''): TgdcBase;
begin
  Result := Self.CreateWithID(AnOwner, ADatabase, ATransaction, AnID, ASubType);
  Result.Open;
  Result.Next;
  if Result.RecordCount = 0 then
  begin
    Result.Free;
    raise EgdcIDNotFound.Create(Self.ClassName + ASubType +
      ': ID not found (' + IntToStr(AnID) + ')');
  end else if Result.RecordCount > 1 then
  begin
    Result.Free;
    raise EgdcIDNotFound.Create(Self.ClassName + ': ���� ������������� (' +
      IntToStr(AnID) + ') ���������� ��������� �������! '#13#10 +
      '��������� ������������ ���������� ������� (�������� SelectSQL)');
  end else
    Result.First;
end;

constructor TgdcBase.CreateWithID;
begin
  CreateWithParams(AnOwner,
    ADatabase,
    ATransaction,
    ASubType,
    'ByID',
    AnID);
end;

constructor TgdcBase.CreateWithParams(AnOwner: TComponent;
  ADatabase: TIBDatabase;
  ATransaction: TIBTransaction;
  const ASubType: TgdcSubType = '';
  const ASubSet: TgdcSubSet = 'All';
  const AnID: Integer = -1);
begin
  CreateSubType(AnOwner, ASubType, ASubSet);
  inherited Database := ADatabase;
  inherited Transaction := ATransaction;
  if (SubSet = 'ByID') and (AnID <> -1) then
  begin
    UniDirectional := True;
    FID := AnID;
  end;
end;

procedure TgdcBase.CustomExecQuery(const ASQL: String; Buff: Pointer; const IsParser: Boolean = True);
var
  S: String;
  DidActivate: Boolean;
  FN: String;
  F: TField;
  Parser: TsqlParser;
  I: Integer;
begin
  if not Assigned(FExecQuery) then
    FExecQuery := TIBSQL.Create(nil);

  if FExecQuery.Transaction <> Transaction then
    FExecQuery.Transaction := Transaction;

  if FExecQuery.Database <> Database then
    FExecQuery.Database := Database;

  if IsParser then
  begin
    with TatSQLSetup.Create(nil) do
    try
      S := PrepareSQL(ASQL, Self.ClassName + '(' + Self.SubType + ')');
      if FExecQuery.SQL.Text <> S then
        FExecQuery.SQL.Text := S;
    finally
      Free;
    end;
  end
  else
    if FExecQuery.SQL.Text <> ASQL then
      FExecQuery.SQL.Text := ASQL;

  DidActivate := False;
  try
    DidActivate := ActivateTransaction;

    FExecQuery.Prepare;
    SetInternalSQLParams(FExecQuery, Buff);
    try
      FExecQuery.ExecQuery;
      if FExecQuery.Open then
        FExecQuery.Close;
    except
      on E: EIBInterbaseError do
      begin
      {TODO ���� ����� ���� �����-�� ����������. ���� ����� ��������� ���������� Required, ��
       CheckRequiredFields ��� �������� ��� �������� �� ����� ��� �� ������ (��-����� ��� ����),
       ����� ���� �������� �� ������� ����� �������� ������, � �� ����� ����� ������������ ValidateField
       (��� ������ �����-�� ������ �����)
       ��� �����, ��� ���� ��� ��������� ���������� ������ ������ �� ������� ������,
       � ������ ���������}
        if (E.IBErrorCode = isc_not_valid) and (sDialog in FBaseState) then
        begin
          Parser := TsqlParser.Create(FExecQuery.SQL.Text);
          try
            Parser.Parse;
            if (Parser.Statements.Count = 1) and (Parser.Statements[0] is TsqlInsert) then
            begin
              with TsqlInsert(Parser.Statements[0]) do
              begin
                FN := '';
                for I := 0 to Fields.Count - 1 do
                begin
                  if StrIPos(TsqlField(Fields[I]).FieldName, E.Message) > 0 then
                  begin
                    if Length(TsqlField(Fields[I]).FieldName) > Length(FN) then
                      FN := TsqlField(Fields[I]).FieldName;
                  end;
                end;
                if FN > '' then
                begin
                  F := FindField(Table.TableName, FN);
                  if F <> nil then
                  begin
                    F.FocusControl;
                    raise EIBInterbaseError.Create(E.SQLCode, E.IBErrorCode,
                      '���������� ��������� ���� "' + F.DisplayName + '"');
                  end;
                end;
              end;
            end;
          finally
            Parser.Free;
          end;
          raise;
        end else
          raise;
      end;
    end;
  finally
    if DidActivate then
      Transaction.Commit;
  end;
end;

function TgdcBase.DeleteMultiple(BL: TBookmarkList): Boolean;
begin
  Result := DeleteMultiple2(CreateSelectedArr(Self, BL));
end;

destructor TgdcBase.Destroy;
var
  Index: Integer;
begin
  FFieldsCallDoChange.Free;
  if Assigned(FInternalTransaction) then
    FreeAndNil(FInternalTransaction);
  if Assigned(FDetailLinks) then
    FreeAndNil(FDetailLinks);
  if (FgdcDataLink <> nil) and (FgdcDataLink.DataSet is TgdcBase) then
    (FgdcDataLink.DataSet as TgdcBase).RemoveDetailLink(Self);
  if Assigned(FgdcDataLink) then
    FreeAndNil(FgdcDataLink);

  if gdcObjectList <> nil then
  begin
    for Index := gdcObjectList.Count - 1 downto 0 do
      if gdcObjectList[Index] = Self then
      begin
        gdcObjectList.Delete(Index);
        break;
      end;
  end;

  FEventList.Free;
  FreeAndNil(FQueryFilter);
  FOldValues.Free;
  FExecQuery.Free;
  FExtraConditions.Free;
  FSelectedID.Free;
  FSavedParams.Free;
  FreeAndNil(FSubSets);
  FIgnoreDataSet.Free;

  FreeAndNil(FSQLSetup);
  FDlgStack.Free;
  FSyncList.Free;

  SLInitial.Free;
  SLChanged.Free;

  if Assigned(InheritedMethodInvoker) then
    InheritedMethodInvoker.UnRegisterMethodInvoker(Self);

  if FClassMethodAssoc <> nil then
  begin
    for Index := 0 to FClassMethodAssoc.Count - 1 do
      if FClassMethodAssoc.IntByIndex[Index] <> 0 then
        TObject(FClassMethodAssoc.IntByIndex[Index]).Free;
    FreeAndNil(FClassMethodAssoc);
  end;  

  FVariables.Free;
  FObjects.Free;

  FSetAttributes.Free;
  FCompoundClasses.Free;

  inherited Destroy;
end;

procedure TgdcBase.MakeReportMenu;
var
  MenuItem: TMenuItem;
  DidActivate: Boolean;
  ReportGroup: TscrReportGroup;
  SQL: TIBSQL;

  procedure FillMenu(const Parent: TObject);
  var
    I: Integer;
    M: TMenuItem;
    Index: Integer;
    AddCount: Integer;
  begin
    Assert((Parent is TMenuItem) or (Parent is TPopUpMenu));

    if (Parent is TMenuItem) then
    begin
      Index := (Parent as TMenuItem).Tag;
      (Parent as TMenuItem).Clear;
    end else
      Index := 0;

    AddCount := 0;
    if (ReportGroup.Count > 0) and (Index < ReportGroup.Count) then
    begin
      for I := Index to ReportGroup.Count - 1 do
      begin
        if ReportGroup.GroupItems[Index].Id = ReportGroup.GroupItems[I].Parent then
        begin
          M := TMenuItem.Create(Self);
          M.Tag := I;
          M.Caption := ReportGroup.GroupItems[I].Name;
          if (Parent is TMenuItem) then
            (Parent as TMenuItem).Add(M)
          else
            (Parent as TPopUpMenu).Items.Add(M);
          FillMenu(M);
          Inc(AddCount);
        end;
      end;
      for I := 0 to ReportGroup.GroupItems[Index].ReportList.Count - 1 do
      begin
        M := TMenuItem.Create(Self);
        M.Tag := ReportGroup.GroupItems[Index].ReportList.Report[I].Id;
        M.Caption := ReportGroup.GroupItems[Index].ReportList.Report[I].Name;
        M.OnClick := DoOnReportClick;
        if (Parent is TMenuItem) then
          (Parent as TMenuItem).Add(M)
        else
          (Parent as TPopUpMenu).Items.Add(M);
        Inc(AddCount);
      end;
    end;
    if AddCount = 0 then
    begin
      M := TMenuItem.Create(Self);
      M.Name := 'N' + IntToStr(Index);
      M.Caption := '�����';
      M.Enabled := False;
      if (Parent is TMenuItem) then
        (Parent as TMenuItem).Add(M)
      else
        (Parent as TPopUpMenu).Items.Add(M);
    end;
  end;

begin
  //��� ��������� �������, ���������� ��� �������� ���������� ������������ ����
  if FpmReport <> nil then
  begin
    FpmReport.Free;
    FpmReport := nil;
  end;

  if not Assigned(FpmReport) then
    FpmReport := TPopupMenu.Create(Self);
  FpmReport.AutoLineReduction := Menus.maAutomatic;

  DidActivate := False;
  try
    if IBLogin.IsUserAdmin then
    begin
      MenuItem := TMenuItem.Create(FpmReport);
      MenuItem.Caption := cst_Reportregistrylist;
      MenuItem.OnClick := DoOnReportListClick;
      FpmReport.Items.Add(MenuItem);
    end;

    ReportGroup := TscrReportGroup.Create(FUseScriptMethod);
    try
      ReportGroup.Transaction := ReadTransaction;
      DidActivate := ActivateReadTransaction;

      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := ReadTransaction;
        SQL.SQL.Text := 'SELECT * FROM evt_object WHERE Upper(objectname) = :objectname';
        if Assigned(Owner) then
        begin
          if Owner is TCreateableForm then
            SQL.Params[0].AsString := UpperCase(TCreateableForm(Owner).InitialName)
          else
            SQL.Params[0].AsString := UpperCase(Owner.Name);
        end;    
        SQL.ExecQuery;
        if not SQl.Eof then
          ReportGroup.Load(SQl.FieldByName('reportgroupkey').AsInteger);
      finally
        SQL.Free;
      end;

      if (ReportGroup.Count > 1) or ((ReportGroup.Count = 1) and (ReportGroup[0].ReportList.Count > 0)) then
      begin
        MenuItem := TMenuItem.Create(FpmReport);
        MenuItem.Caption := '-';
        FpmReport.Items.Add(MenuItem);

        FillMenu(FpmReport);
      end;

      ReportGroup.Load(GroupID);
      if (ReportGroup.Count > 1) or ((ReportGroup.Count = 1) and (ReportGroup[0].ReportList.Count > 0)) then
      begin
        MenuItem := TMenuItem.Create(FpmReport);
        MenuItem.Caption := '-';
        FpmReport.Items.Add(MenuItem);

        FillMenu(FpmReport);
      end;
    finally
      ReportGroup.Free;
    end;

  finally
    if DidActivate then
      DeactivateReadTransaction;
  end;
end;

procedure TgdcBase.DoBeforeOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASE', 'DOBEFOREOPEN', KEYDOBEFOREOPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOBEFOREOPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREOPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOBEFOREOPEN', KEYDOBEFOREOPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if (not CanView) and (not IBLogin.IsUserAdmin) then
  begin
    if SubType > '' then
      raise EgdcUserHaventRights.CreateFmt(strHaventRights,
        [strView, ClassName, SubType, GetDisplayName(SubType)])
    else
      raise EgdcUserHaventRights.CreateFmt(strHaventRightsShort,
        [strView, ClassName])
  end;

  if not FSQLInitialized then
    InitSQL;

  if HasSubSet('ByID') and (FID > -1) then
    ParamByName(GetKeyField(SubType)).AsInteger := FID
  else if HasSubSet('ByName') and (FObjectName > '') then
    ParamByName(GetListField(SubType)).AsString := FObjectName;

  inherited DoBeforeOpen;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOBEFOREOPEN', KEYDOBEFOREOPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOBEFOREOPEN', KEYDOBEFOREOPEN);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.DoOnNewRecord;
begin

  if FDataTransfer then
    exit;
  FIsNewRecord := True;
  try
    _DoOnNewRecord;
  finally
    FIsNewRecord := False;
  end;

  inherited DoOnNewRecord;
end;

function TgdcBase.EditDialog(const ADlgClassName: String = ''): Boolean;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  C: TClass;
  CFull: TgdcFullClass;
  Obj: TgdcBase;
  DlgForm: TCreateableForm;
  I, NewID: Integer;
  F: TField;
  InTransaction: Boolean;
  FormClass: String;
  FSavepoint: String;
begin
  {@UNFOLD MACRO INH_ORIG_EDITDIALOG('TGDCBASE', 'EDITDIALOG', KEYEDITDIALOG)}
  {M}  Result := False;
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYEDITDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYEDITDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ADlgClassName]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'EDITDIALOG', KEYEDITDIALOG, Params, LResult) then
  {M}          begin
  {M}            Result := False;
  {M}            if VarType(LResult) = varBoolean then
  {M}              Result := Boolean(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'EDITDIALOG' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}          Exit;
  {M}    end;
  {END MACRO}

  if not Active then
    raise EgdcException.CreateObj('Dataset is not active.', Self);

  DlgForm := nil;

  CFull := GetCurrRecordClass;

  if ((UpperCase(ADlgClassName) = 'TGDC_DLGOBJECTPROPERTIES') and Assigned(CFull.gdClass))
    or ((CFull.gdClass = Self.ClassType) and (CFull.SubType = Self.SubType)) then
  begin
    C := GetClass(ADlgClassName);

    if (C <> nil) and (C.InheritsFrom(TCreateableForm)) then
      DlgForm := CCreateableForm(C).Create(FParentForm)
    else
    begin
      if (ADlgClassName > '') and Assigned(GlobalStorage) and (GlobalStorage.ValueExists(st_ds_NewFormPath + '\' + ADlgClassName, st_ds_FormClass)) then
      begin
        FormClass := GlobalStorage.ReadString(st_ds_NewFormPath + '\' + ADlgClassName, st_ds_FormClass);
        if FormClass <> '' then
        begin
          C := GetClass(FormClass);
          if Assigned(C) then
          begin
            DlgForm := CCreateableForm(C).CreateUser(FParentForm, ADlgClassName)
          end;
        end;
      end;
    end;

    if DlgForm = nil then
      DlgForm := CreateDialogForm;

    if not (DlgForm is Tgdc_dlgG) then
    begin
      DlgForm.Free;
      Result := False;
      exit;
    end;

    if Assigned(DlgForm) then
      with DlgForm do
    try
      FSavepoint := '';
      InTransaction := Transaction.Active;
      try
        {savepoints support}
        if InTransaction and UseSavepoints then
        begin
          FSavepoint := 'S' + System.Copy(StringReplace(
            StringReplace(
              StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
              '-', '', [rfReplaceAll]), 1, 30);
          try
            Transaction.SetSavePoint(FSavepoint);
          except
            UseSavepoints := False;
            FSavepoint := '';
          end;
        end;
        {end savepoints support}

        try
          FDlgStack.Push(DlgForm);

          if sMultiple in BaseState then
          begin
            PrepareSLInitial;
          end;

          NewID := -1;

          if not (Self.State in dsEditModes) then
          begin
            if CanModify then
            begin
              if RecordCount = 0 then
              begin
                Self.Insert;
                NewID := ID;
              end else
                Self.Edit;
            end;
          end;  

          if sDialog in FBaseState then
          begin
            Include(FBaseState, sSubDialog);
          end else
            Include(FBaseState, sDialog);

          if not CanView then
          begin
            raise EgdcUserHaventRights.CreateFmt(strHaventRights,
              [strView, ClassName, SubType, GetDisplayName(SubType)]);
          end;

          Setup(Self);

          DoBeforeShowDialog(DlgForm);

          Result := ShowModal = mrOk;
          if IBLogin.Database.Connected then
          begin
            DoAfterShowDialog(DlgForm, Result);

            if not (sSubDialog in FBaseState) then
            begin
              if Self.State in dsEditModes then
                if Result then
                  Self.Post
                else
                  Self.Cancel;

              if Transaction.InTransaction then
              begin
                if not InTransaction then
                begin
                  if Result then
                    Transaction.Commit
                  else
                    Transaction.Rollback;

                  {$IFDEF DEBUG}
                  OutputDebugString('���� �� ������� ����������!');
                  {$ENDIF}
                end else
                begin
                  if FSavepoint > '' then
                  begin
                    if (not Result) then
                    begin
                      try
                        Transaction.RollBackToSavePoint(FSavepoint);
                        Transaction.ReleaseSavePoint(FSavepoint);
                        FSavepoint := '';
                      except
                        FSavepoint := '';
                      end;
                    end;

                    if FSavepoint > '' then
                    begin
                      try
                        Transaction.ReleaseSavePoint(FSavepoint);
                        FSavepoint := '';
                      except
                        FSavepoint := '';
                      end;
                    end;
                  end;
                end;
              end;

            end else
            begin
              if Result then
                FDSModified := True
              else if InTransaction and Transaction.InTransaction
                and (FSavepoint > '') then
              begin
                try
                  Transaction.RollBackToSavePoint(FSavepoint);
                  Transaction.ReleaseSavePoint(FSavepoint);
                  FSavepoint := '';
                except
                  FSavepoint := '';
                end;
              end;
            end;

            if not (sSubDialog in BaseState) then
            begin
              if (not Result) and (NewID > -1) then
              begin
                if ((CustomProcess * [cpInsert, cpModify]) <> [])
                  or (NewID = Self.ID) then
                begin
                  Self.Refresh;
                end;
              end;
            end;
          end;
        except
          if Self.State in dsEditModes then
            Self.Cancel;

          raise;
        end;
      except
        if Transaction.InTransaction then
        begin
          if InTransaction then
          begin
            if FSavepoint = '' then
              Transaction.RollbackRetaining
            else begin
              try
                Transaction.RollBackToSavePoint(FSavepoint);
                Transaction.ReleaseSavePoint(FSavepoint);
              except
              end;
            end;
          end else
            Transaction.Rollback;
        end;

        raise;
      end;
    finally
      if sSubDialog in FBaseState then
      begin
        Exclude(FBaseState, sSubDialog);
      end else
        Exclude(FBaseState, sDialog);

      FDlgStack.Pop;

      Free;

      if not IBLogin.Database.Connected then
        IBLogin.ConnectionLostMessage
      else
      begin
        if (not Result) and (not (sDialog in FBaseState)) then
        begin
          for I := 0 to FDetailLinks.Count - 1 do
            if (FDetailLinks[I] <> nil)
              and (DetailLinks[I].Transaction <> DetailLinks[I].ReadTransaction)
            then
            begin
              DetailLinks[I].Close;
              DetailLinks[I].Open;
            end;
        end;
      end;
    end else
      Result := False;
  end else
  begin
    C := CFull.gdClass;

    if not Assigned(C) then
      raise EgdcException.Create('GetCurrRecordClass ������ nil �����.');

    Obj := CgdcBase(C).CreateWithID(Owner, Database, Transaction, ID, CFull.SubType);
    try
      Obj.SetBaseState(Self.BaseState);

      CopyEventHandlers(Obj, Self);
      try
        if sMultiple in Obj.BaseState then
        begin
          Obj.SLInitial := TStringList.Create;
          Obj.SLChanged := TStringList.Create;
        end;

        Obj.Open;

        if Obj.RecordCount = 0 then
        begin
          MessageBox(ParentHandle,
            '���������� ������� ��������� ������ �� ��������������.'#13#10 +
            '��������, �������� ����������� ������ ��� ���������� �������� ������.'#13#10#13#10 +
            '� ������ ���������� �������� ���������� � ���������� ��������������.',
            '��������',
            MB_OK or MB_ICONHAND or MB_TASKMODAL);
          Abort;
        end;

        Result := Obj.EditDialog(ADlgClassName);

        if Result and Active and Obj.Active then
        begin
          { TODO :
  ��� ��������: ������ � ���������� ����� ���� �������
  �������� � ������� ������������ ������ ���� ������
  ������� ���� �������������� �������. � ���� ����� �������
  �� �����...

  ���������� ��� �������� ������ ����� ���� ���-�� � ���
  ���������������� ������. }
          FDataTransfer := True;
          try
            ResetEventHandlers(Self);

            Edit;
            try
              for I := 0 to FieldCount - 1 do
              begin
                F := Obj.FindField(Fields[I].FieldName);
                if Assigned(F) then
                  Fields[I].Assign(F);
              end;
              Post;
            except
              if State in dsEditModes then
                Cancel;
              raise;  
            end;
          finally
            FDataTransfer := False;
          end;

          if sMultiple in Obj.BaseState then
          begin
            SLInitial.Assign(Obj.SLInitial);
            SLChanged.Assign(Obj.SLChanged);
          end;
        end;

      finally
        CopyEventHandlers(Self, Obj);
      end;

    finally
      Obj.Free;
    end;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'EDITDIALOG', KEYEDITDIALOG)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'EDITDIALOG', KEYEDITDIALOG);
  {M}  end;
  {END MACRO}
end;

function TgdcBase.EditMultiple(BL: TBookmarkList; const ADlgClassName: String = ''): Boolean;
begin
  Result := EditMultiple2(CreateSelectedArr(Self, BL), ADlgClassName);
end;

function TgdcBase.GetDeleteSQLText: String;
begin
  Result := Format('DELETE FROM %s WHERE %s=:OLD_%s ',
    [GetListTable(SubType), GetKeyField(SubType), GetKeyField(SubType)]);
end;

function TgdcBase.GetDetailField: String;
begin
  if FgdcDataLink <> nil then
    Result := FgdcDataLink.DetailField
  else
    Result := '';
end;

class function TgdcBase.GetDisplayName(const ASubType: TgdcSubType): String;
var
  R: TatRelation;
  CE: TgdClassEntry;
begin
  CE := gdClassList.Get(TgdBaseEntry, Self.ClassName, ASubType);
  Result := CE.Caption;
  if (Result = '') and Assigned(atDatabase) then
  begin
    R := atDatabase.Relations.ByRelationName(GetDistinctTable(ASubType));
    if R <> nil then
      Result := R.LName;
  end;
end;

function TgdcBase.GetGroupClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR                                                                        
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETGROUPCLAUSE('TGDCBASE', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYGETGROUPCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETGROUPCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'GETGROUPCLAUSE', KEYGETGROUPCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETGROUPCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Result := '';//Inherited GetGroupClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := '';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcBase.GetID: Integer;
var
  F: TField;
begin
  if Active then
  begin
    F := FieldByName(GetKeyField(SubType));
    if F.IsNull then
      Result := -1
    else
      Result := F.AsInteger;
  end else
    Result := FID;
end;

function TgdcBase.GetInsertSQLText: String;
var
  I: Integer;
  F, V: String;
  SL: TStrings;
  LT, LF: String;
  IsUserTable: Boolean;
begin
  Assert(GetListTable(SubType) > '');

  LT := GetListTable(SubType);
  LF := GetListField(SubType);

  IsUserTable := StrIPos(UserPrefix, LT) = 1;

  if Database = nil then
    Result := Format('INSERT INTO %s (%s) VALUES (:NEW_%s) ', [LT, LF, LF])
  else begin
    SL := TStringList.Create;
    try
      Database.GetFieldNames(LT, SL);
      Result := 'INSERT INTO ' + LT + ' (';
      F := '';
      V := '';
      for I := 0 to SL.Count - 1 do
        if (IsUserTable or (StrIPos(UserPrefix, SL[I]) <> 1)) and //�������� ������� ��� ���������� ����
          (not Database.Has_Computed_BLR(UpperCase(LT), UpperCase(SL[I]))) and
          (UpperCase(SL[I]) <> 'LB') and
          (UpperCase(SL[I]) <> 'RB') then
        begin
          F := F + SL[I] + ',';
          V := V + ':NEW_' + SL[I] + ',';
        end;
      SetLength(F, Length(F) - 1);
      SetLength(V, Length(V) - 1);
      Result := Result + F + ') VALUES (' + V + ') ';

      FUpdateableFields := F;
    finally
      SL.Free;
    end;
  end;
end;

class function TgdcBase.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

function TgdcBase.GetMasterField: String;
begin
  if FgdcDataLink <> nil then
    Result := FgdcDataLink.MasterField
  else
    Result := '';  
end;

function TgdcBase.GetMasterSource: TDataSource;
begin
  if FgdcDataLink <> nil then
    Result := FgdcDataLink.DataSource
  else
    Result := nil;
end;

function TgdcBase.GetModifySQLText: String;
var
  I: Integer;
  SL: TStrings;
  LT, KF, LF: String;
  IsUserTable: Boolean;
begin
  Assert(GetListTable(SubType) > '');

  LT := GetListTable(SubType);
  KF := GetKeyField(SubType);
  LF := GetListField(SubType);

  IsUserTable := StrIPos(UserPrefix, LT) = 1;

  if (Database = nil) then
    Result := Format('UPDATE %s SET %s=:NEW_%s WHERE %s=:OLD_%s ',
      [LT, LF, LF, KF, KF])
  else begin
    SL := TStringList.Create;
    try
      Database.GetFieldNames(LT, SL);
      if SL.Count < 2 then
      begin
        if (LF = '') or (KF = '') then
        begin
          if atDatabase.Relations.ByRelationName(LT) = nil then
            raise EgdcNoTable.CreateObj(
              '� ���� ������ ����������� ������� � ������ ' + LT + '.',
              Self);

          raise EgdcException.CreateObj(
            '�� ���������� �������� ���� ��� ���� ��� �����������.'#13#10 +
            '���� � ������ ������ ���������� �������� ���������, ��,'#13#10 +
            '��������, � ������������ ���� ������� ��������, �� �� ��������'#13#10 +
            '����������� � ���� �������. ��� ���� ��������� �������, ���'#13#10 +
            '������� ������������� ����������� ����� �������������� ����.',
            Self);
        end;

        Result := Format('UPDATE %s SET %s=:NEW_%s WHERE %s=:OLD_%s ',
          [LT, LF, LF, KF, KF]);
      end else begin
        Result := 'UPDATE ' + LT + ' SET ';
        for I := 0 to SL.Count - 1 do
          if (AnsiCompareText(SL[I], KF) <> 0) and
             (IsUserTable or (Pos(UserPrefix, UpperCase(SL[I])) <> 1)) and
             (not Database.Has_Computed_BLR(UpperCase(LT), UpperCase(SL[I]))) and
             (UpperCase(SL[I]) <> 'LB') and
             (UpperCase(SL[I]) <> 'RB') then
            Result := Result + SL[I] + '=:NEW_' + SL[I] + ',';
        SetLength(Result, Length(Result) - 1);
        Result := Result + ' WHERE ' + KF + '=:OLD_' + KF + ' ';
      end;
    finally
      SL.Free;
    end;
  end;
end;

function TgdcBase.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCBASE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'GETORDERCLAUSE', KEYGETORDERCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Result := '';//Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := '';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcBase.GetRefreshSQLText: String;

  function GetWhereClauseForSet: String;
  var
    I: Integer;
    KFL: TStringList;
    R: TatRelation;
  begin
    Result := '';

    //��������� ���� �� � ��� �������-���������
    if (FSetTable = '') or (atDatabase = nil) then
      Exit;

{    Result := cstSetAlias + '.' + FSetItemField + ' = :NEW_' +
      cstSetPrefix + FSetItemField;}

    { TODO :
���� ������������ ����� ����������� ����, ��
�������������� ������� ������ ��������� � ������
�������. ���� ��� � ������ � ������ ��� � �������. }
   //� ���� �� ������������ ����������� ���� �����, �� �� ����� �� ������ ��������,
   //����� �������� ��� ������� �� ���� � ����� �����, �������� ������-����,
   //������ ���� ������ � ����, ��� � ������� gd_goodtax

    R := atDatabase.Relations.ByRelationName(FSetTable);

    Assert(Assigned(R));

    if Assigned(R.PrimaryKey)
    then
    begin
      KFL := TStringList.Create;
      try
        with atDatabase.Relations.ByRelationName(FSetTable).PrimaryKey do
        for I := 0 to ConstraintFields.Count - 1 do
          KFL.Add(AnsiUpperCase(Trim(ConstraintFields[I].FieldName)));

        Result := '';
        for I := 0 to KFL.Count - 1 do
        begin
          if Result > '' then
            Result := Result + ' AND ';
          Result := Result + cstSetAlias + '.' + KFL[I] + ' = :NEW_' + cstSetPrefix + KFL[I];
        end;

      finally
        KFL.Free;
      end;
    end;

  end;
var
  SelectClause, FromClause, Cond: String;
begin
  SelectClause := GetSelectClause + ' ' + GetInheritedTableSelect;
  if Assigned(FOnGetSelectClause) then
    FOnGetSelectClause(Self, SelectClause);

  FromClause := GetFromClause(True) + ' ' + GetInheritedTableJoin;
  if Assigned(FOnGetFromClause) then
    FOnGetFromClause(Self, FromClause);

  if FSetTable > '' then
    Result :=
      SelectClause + ' ' + GetSetTableSelect +
      FromClause + ' ' + GetSetTableJoin +
      Format('WHERE %s ', [GetWhereClauseForSet])
  else
  begin
    Cond := Format('%s.%s=:NEW_%s', [GetListTableAlias,
      GetKeyField(SubType), GetKeyField(SubType)]);

    Result :=
      SelectClause + ' ' +
      FromClause + ' ';

    if StrIPos(Cond,
      StringReplace(FromClause, ' ', '', [rfReplaceAll])) = 0 then
    begin
      Result := Result + ' WHERE ' + Cond;
    end;
  end;
end;

class function TgdcBase.GetRestrictCondition(
  const ATableName, ASubType: String): String;
begin
  Result := '';
end;

function TgdcBase.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCBASE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Result := '';//Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := Format('SELECT %s.* ', [GetListTableAlias])

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcBase.GetSetTableSelect: String;
begin
  if FSetTable > '' then
    Result := Format(', %s.* ', [cstSetAlias])
  else
    Result := '';
end;

function TgdcBase.GetInheritedTableSelect: String;
var
  CE: TgdClassEntry;

  procedure IterateAncestor(BE: TgdBaseEntry; var SQL: String);
  var
    RA: String;
    R: TatRelation;
    I: Integer;
  begin
    if BE <> BE.GetRootSubType then
    begin
      if BE.Parent is TgdBaseEntry then
        IterateAncestor(BE.Parent as TgdBaseEntry, SQL);

      if BE.DistinctRelation <> TgdBaseEntry(BE.Parent).DistinctRelation then
      begin
        RA := gdcBaseManager.AdjustMetaName('d_' + BE.DistinctRelation);
        R := atDatabase.Relations.ByRelationName(BE.DistinctRelation);
        if R = nil then
          raise EgdcException.CreateObj('Unknown relation ' + BE.DistinctRelation, Self);
        for I := 0 to R.RelationFields.Count - 1 do
        begin
          if R.RelationFields[I].IsUserDefined then
            SQL := SQL + ', ' + RA + '.' + R.RelationFields[I].FieldName + ' ' +
              gdcBaseManager.AdjustMetaName(RA + '_' + R.RelationFields[I].FieldName,
              31 - 4); // account for "new_" prefix
        end;
      end;
    end;
  end;

begin
  Result := '';
  CE := gdClassList.Get(TgdBaseEntry, Self.ClassName, SubType);
  //if CE is TgdAttrUserDefinedEntry then
    IterateAncestor(CE as TgdBaseEntry, Result);
end;

function TgdcBase.GetInheritedTableJoin: String;
var
  CE: TgdClassEntry;

  procedure IterateAncestor(BE: TgdBaseEntry; var SQL: String;
    const LinkFieldName: String);
  var
    N: String;
  begin
    if BE <> BE.GetRootSubType then
    begin
      if BE.Parent is TgdBaseEntry then
        IterateAncestor(BE.Parent as TgdBaseEntry, SQL, LinkFieldName);
      N := gdcBaseManager.AdjustMetaName('d_' + BE.DistinctRelation);

      if BE.DistinctRelation <> TgdBaseEntry(BE.Parent).DistinctRelation then
      begin
        SQL := SQL + ' JOIN ' + BE.DistinctRelation + ' ' + N +
          ' ON ' + N + '.' + LinkFieldName + ' = ' + GetListTableAlias + '.id';
      end;
    end;
  end;

begin
  Result := '';
  CE := gdClassList.Get(TgdBaseEntry, Self.ClassName, SubType);
  if CE is TgdAttrUserDefinedEntry then
    IterateAncestor(CE as TgdBaseEntry, Result, 'inheritedkey')
  else if CE is TgdDocumentEntry then
    IterateAncestor(CE as TgdBaseEntry, Result, 'documentkey');
end;

function TgdcBase.GetSetTableJoin: String;
var
  PK: TatPrimaryKey;
  R: TatRelation;
  I: Integer;
  OL: TObjectList;
  LinkTableList: TStrings;

begin
  Result := '';
  if (FSetTable > '') and (atDatabase <> nil) and (atDatabase.Relations <> nil) then
  begin
    R := atDatabase.Relations.ByRelationName(FSetTable);

    if R <> nil then
      PK := R.PrimaryKey
    else
      PK := nil;

    if (PK = nil) or (PK.ConstraintFields.Count < 2) then
      raise EgdcException.CreateObj('� ������� ������ ' + FSetTable +
        ' ��������� ���� ������ �������� �� ���� ��� ����� �����.', Self)
    else begin
      FSetItemField := '';
      FSetMasterField := '';

      // ������ ������ ��� �������, ��������� ���� ������� ������������
      // �������� ������� �� ���� ������, �.�. ������� ���������
      // ������� ������ ����-�-������ � ����� ��������
      // ������ � ����� ��������, � ������������ � ������� � �������
      // �������, ������������ ������ ������ �������
      // ������: gd_contact -- gd_company -- gd_companycode
      LinkTableList := TStringList.Create;
      try
        OL := TObjectList.Create(False);
        try
          atDatabase.ForeignKeys.ConstraintsByReferencedRelation(
            GetListTable(SubType), OL);
          for I := 0 to OL.Count - 1 do
            with OL[I] as TatForeignKey do
          begin
            if IsSimpleKey
              and (Relation.PrimaryKey <> nil)
              and (Relation.PrimaryKey.ConstraintFields.Count = 1)
              and (ConstraintField = Relation.PrimaryKey.ConstraintFields[0]) then
            begin
              //�������� ������ �� �������, ������� ��������� �� ������� ������� 1:1
              LinkTableList.Add(AnsiUpperCase(Trim(Relation.RelationName)));
            end;
          end;
        finally
          OL.Free;
        end;

        //������� � ������ � ������� ������� �������
        LinkTableList.Add(AnsiUpperCase(GetListTable(SubType)));
        (LinkTableList as TStringList).Sorted := True;

        for I := 0 to PK.ConstraintFields.Count - 1 do
        begin
          if PK.ConstraintFields[I].References = nil then
            continue;

          if (FSetMasterField = '')
          then
          begin
            FSetMasterField := PK.ConstraintFields[I].FieldName;
          end else

          if (FSetItemField = '') and (I > 0) then
          begin
            if (LinkTableList.IndexOf(AnsiUpperCase(Trim(PK.ConstraintFields[I].References.RelationName))) > -1) then
              FSetItemField := PK.ConstraintFields[I].FieldName
            else begin
              FSetItemField := FSetMasterField;
              FSetMasterField := PK.ConstraintFields[I].FieldName;
            end;
          end;

          if (FSetItemField > '') and
           (FSetMasterField > '')
          then
            Break;
        end;

        if (FSetItemField = '') or (FSetMasterField = '') then
          raise EgdcException.Create('� ������� ' + FSetTable + ' ������� ������!');

        Result :=
          Format('JOIN %0:s %5:s ON %5:s.%1:s = :MASTER_RECORD_ID AND %5:s.%2:s = %3:s.%4:s ',
          [FSetTable, FSetMasterField, FSetItemField, GetListTableAlias, GetKeyField(SubType), cstSetAlias]);
      finally
        LinkTableList.Free;
      end;
    end;
  end;
end;

function TgdcBase.GetSelectSQLText: String;

  function HasAggregates(S: String): Boolean;
  begin
    S := StringReplace(S, ' ', '', [rfReplaceAll]);
    S := StringReplace(S, #13, '', [rfReplaceAll]);
    S := StringReplace(S, #10, '', [rfReplaceAll]);
    Result := (StrIPos('SUM(', S) > 0)
      or (StrIPos('LIST(', S) > 0)
      or (StrIPos('MIN(', S) > 0)
      or (StrIPos('MAX(', S) > 0)
      or (StrIPos('AVG(', S) > 0);
  end;

var
  SelectClause, FromClause, WhereClause, GroupClause, OrderClause: String;
begin
  SelectClause := GetSelectClause + ' ' + GetInheritedTableSelect;
  if Assigned(FOnGetSelectClause) then
    FOnGetSelectClause(Self, SelectClause);

  FromClause := GetFromClause + ' ' + GetInheritedTableJoin;
  if Assigned(FOnGetFromClause) then
    FOnGetFromClause(Self, FromClause);

  WhereClause := GetWhereClause;
  if Assigned(FOnGetWhereClause) then
    FOnGetWhereClause(Self, WhereClause);

  GroupClause := GetGroupClause;
  if Assigned(FOnGetGroupClause) then
    FOnGetGroupClause(Self, GroupClause);

  OrderClause := GetOrderClause;
  if Assigned(FOnGetOrderClause) then
    FOnGetOrderClause(Self, OrderClause);

  Result :=
    SelectClause + ' ' + GetSetTableSelect +
    FromClause + ' ' + GetSetTableJoin +
    WhereClause + ' ';
  if (GroupClause > '') and
    ((not HasSubSet('ByID')) or (HasAggregates(SelectClause))) then
  begin
    Result := Result +
      GroupClause + ' ';
  end;
  if (not HasSubSet('ByID')) and (not HasSubSet('ByName')) then
  begin
    Result := Result +
      OrderClause;
  end;
end;

function TgdcBase.GetWhereClause: String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  SL: TStringList;
  I: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_GETWHERECLAUSE('TGDCBASE', 'GETWHERECLAUSE', KEYGETWHERECLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYGETWHERECLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETWHERECLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'GETWHERECLAUSE', KEYGETWHERECLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETWHERECLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Result := '';//Inherited GetWhereClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  SL := TStringList.Create;
  try
    SL.Duplicates := dupIgnore;
    GetWhereClauseConditions(SL);
    for I := 0 to FExtraConditions.Count - 1 do
      SL.Add(FExtraConditions[I]);
    for I := SL.Count - 1 downto 0 do
      if Trim(SL[I]) = '' then
        SL.Delete(I);

    if SL.Count > 0 then
    begin
      Result := 'WHERE ' + SL[0];
      for I := 1 to SL.Count - 1 do
        Result := Result + ' AND ' + SL[I];
    end else
      Result := '';
  finally
    SL.Free;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'GETWHERECLAUSE', KEYGETWHERECLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'GETWHERECLAUSE', KEYGETWHERECLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.InitSQL;
var
  SQLText, FullClassName: String;
  {$IFDEF DEBUG}T: TDateTime;{$ENDIF}
begin
  {$IFDEF DEBUG}
  T := Now;
  {$ENDIF}

  if FSQLInitialized then
    exit;

  // ��������, ����� ����������-���� �� ���������
  // �.�. � ������ �� �������� ������� � �����
  // ��� �� ��������� � � ��� ����� ��������
  SetDefaultFields(True);
  DestroyFields;

  if not (csDesigning in ComponentState) then
  begin
    FullClassName := Self.ClassName + '(' + Self.SubType + ')';
    with FSQLSetup do
    begin
      //� Select-������ ���������� ������ ��������� ���������
      SelectSQL.Text := PrepareSQL(GetSelectSQLText, FullClassName);
      ModifySQL.Text := PrepareSQL(GetModifySQLText, FullClassName);
      InsertSQL.Text := PrepareSQL(GetInsertSQLText, FullClassName);
      DeleteSQL.Text := {PrepareSQL(}GetDeleteSQLText{)};
      if FSetRefreshSQLOn then
        RefreshSQL.Text := PrepareSQL(GetRefreshSQLText, FullClassName)
      else
        RefreshSQL.Text := '';
    end;
  end else
  begin
    SelectSQL.Text := GetSelectSQLText;
    ModifySQL.Text := GetModifySQLText;
    InsertSQL.Text := GetInsertSQLText;
    DeleteSQL.Text := GetDeleteSQLText;
    if FSetRefreshSQLOn then
      RefreshSQL.Text := GetRefreshSQLText
    else
      RefreshSQL.Text := '';
  end;

  // ������� �� �������� �������. ��� ����������� ��� ������������� �� ���.

  SQLText := DoAfterInitSQL(SelectSQL.Text);
  if SQLText > '' then
    SelectSQL.Text := SQLText;

  FSQLInitialized := True;

  {$IFDEF DEBUG}
  //if Now - T > 1 / (24 * 60 * 60) then
    OutputDebugString(PChar(Name + '.InitSQL: ' + FormatDateTime('s.z', Now - T)));
  {$ENDIF}
end;

procedure TgdcBase.InternalPostRecord(Qry: TIBSQL; Buff: Pointer);
var
  i, j, k, CutOff: Integer;
  pbd: PBlobDataArray;
  DidActivate: Boolean;
  FSavepoint, S: String;
  RF: TatRelationField;
begin
  {$R-}
  FInternalProcess := True;
  try
    if not FDataTransfer then
    begin

      if Assigned(UpdateObject) then
      begin
        if (Qry = QDelete) then
          UpdateObject.Apply(DB.ukDelete)
        else
          if (Qry = QInsert) then
            UpdateObject.Apply(DB.ukInsert)
          else
            UpdateObject.Apply(DB.ukModify);
      end
      else
      begin
        FSavepoint := '';
        DidActivate := ActivateTransaction;
        try
          {savepoints support}
          if (not DidActivate) and UseSavepoints then
          begin
            FSavepoint := 'S' + System.Copy(StringReplace(
              StringReplace(
                StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
                '-', '', [rfReplaceAll]), 1, 30);
            try
              Transaction.SetSavePoint(FSavepoint);
            except
              UseSavepoints := False;
              FSavepoint := '';
            end;
          end;
          {end savepoints support}

          DoBeforeInternalPostRecord;

          pbd := PBlobDataArray(PChar(Buff) + FBlobCacheOffset);
          j := 0;
          for i := 0 to FieldCount - 1 do
            if Fields[i].IsBlob then
            begin
              k := FMappedFieldPosition[Fields[i].FieldNo -1];
              if pbd^[j] <> nil then
              begin
                pbd^[j].Finalize;
                PISC_QUAD(
                  PChar(Buff) + PRecordData(Buff)^.rdFields[k].fdDataOfs)^ :=
                  pbd^[j].BlobID;
                PRecordData(Buff)^.rdFields[k].fdIsNull := pbd^[j].Size = 0;
              end;
              Inc(j);
            end;

          CheckRequiredFields;

          if (Qry = QInsert) then
            S := '������ ���������'
          else
            S := '������ ��������';

          IBLogin.AddEvent(S,
            Self.ClassName + ' ' + Self.SubType,
            ID,
            Transaction);

          { TODO :
  ��� ��������� ���������� ����������.
  �������� ��������� �������:
  �������� ��������� ������ ������ ��� �������,
  ���� �������� �� ��� ���������. ���� �� ������
  � ������ �������� �� �� ������ ����������,
  � �� ��������� ��� ���������� � �� ����� �������,
  �� ��������� ����������. �������� ��� �������.
  ��������� ���������� � ��������� ��� ��-�����.
  ��� �� ����� ���� ���. ���� �� ������� �� ����
  ����������.

  ��������! ��� ������ ����� ��� ����������:
  read_committed
  rec_version
  nowait

  ��� ���������� ������� ���� ����� ���� ������ ��� ������.
  �� �� ��������� ��� ������.}
          CutOff := 5;
          repeat
            try
              { TODO : � ������ ������ ��������� ������������ ����� ��������� 0 }
              //FRowsAffected := 0;
              if (Qry = QInsert) then
                _CustomInsert(Buff)
              else if (Qry = QModify) then
                _CustomModify(Buff);
              CutOff := 0;
            except
              on E: EIBError do
              begin
                if (E.IBErrorCode = isc_lock_conflict) or (E.IBErrorCode = isc_deadlock) then
                begin
                  if (CutOff > 1) and DidActivate and AllowCloseTransaction then
                  begin
                    Transaction.Rollback;
                    Sleep(500);
                    Dec(CutOff);
                    Transaction.StartTransaction;
                  end else
                  begin
                    if sDialog in BaseState then
                    begin
                      MessageBox(ParentHandle, PChar(
                        '������ �������� ����������. ������ �� ����� ���� ��������� ������.'#13#10#13#10 +
                        '������ ������������ �������������: ' + GetUserByTransaction(StatusVectorArray[9]) + #13#10 +
                        '��������� �������:'#13#10 +
                        '  1. ������ ������������ � ���� ������ � ������ ������ �������� ������.'#13#10 +
                        '  2. �������� ������ �������� � ������ ������ � ������ ���� ���������. '#13#10 +
                        '  3. ��������� ������ ������ �� ����� ��������� ������ ������, �������'#13#10 +
                        '     ����������� ������ ������������ ��� ������� ���������� � ������ ���� ���������.'#13#10#13#10 +
                        '���������� ��������� ������ ����� ��� �������� ���� (������) � ������� ������� ������'#13#10 +
                        '��-�����������, �� ��������� ������� ����� ���������� ���� �� ������.'#13#10 +
                        ''#13#10 +
                        '� ������ ���������� �������� ���������� � ��������������.'),
                        '��������',
                        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
                      Abort;
                    end else
                      raise;
                  end;
                end else
                  raise;
              end else
                raise;
            end;
          until CutOff = 0;

          if (ID >= cstUserIDStart)
            and Assigned(IBLogin)
            and IBLogin.IsIBUserAdmin
            and Assigned(gdcBaseManager)
            and (not (sLoadFromStream in BaseState))
            and Assigned(atDatabase) then
          begin
            RF := atDatabase.FindRelationField(GetListTable(SubType), GetKeyField(SubType));

            if (RF <> nil) and (RF.References = nil) then
            begin
              if (Qry = QInsert) then
              begin
                ExecSingleQuery(
                  'UPDATE OR INSERT INTO gd_ruid (id, xid, dbid, modified, editorkey) ' +
                  'VALUES (:id, :id, :dbid, CURRENT_TIMESTAMP, :ek) ' +
                  'MATCHING (id)', VarArrayOf([Self.ID, IBLogin.DBID, IBLogin.ContactKey]));
              end else
              if (Qry = QModify) then
              begin
                ExecSingleQuery(
                  'UPDATE gd_ruid SET modified = CURRENT_TIMESTAMP,' +
                  'editorkey = :ek WHERE id = :id', VarArrayOf([IBLogin.ContactKey, Self.ID]));
              end;
            end;
          end;

          DoAfterInternalPostRecord;

          if DidActivate and AllowCloseTransaction then
            Transaction.Commit;

          if (FSavepoint > '') and Transaction.InTransaction then
          begin
            try
              Transaction.ReleaseSavePoint(FSavepoint);
            except
              // ��������� ����������, ����
              // ��������� ��� �������, ����. ���������� ���������
              // ��� �������� � ����� ����������
            end;
          end;
        except
          if DidActivate and AllowCloseTransaction then
            Transaction.Rollback
          else if (FSavepoint > '') and Transaction.InTransaction then
          begin
            try
              Transaction.RollBackToSavePoint(FSavepoint);
              Transaction.ReleaseSavePoint(FSavepoint);
            except
              // ��������� ����������, ����
              // ��������� ��� �������, ����. ���������� ���������
              // ��� �������� � ����� ����������
            end;
          end;
          raise;
        end;
      end;
    end;

    PRecordData(Buff)^.rdUpdateStatus := usUnmodified;
    PRecordData(Buff)^.rdCachedUpdateStatus := cusUnmodified;
    SetModified(False);
    WriteRecordCache(PRecordData(Buff)^.rdRecordNumber, Buff);

    if not FDataTransfer then
    begin
      if (ForcedRefresh or FNeedsRefresh) and CanRefresh then
      begin
        FSavedFlag := True;
        try
          FSavedRN := PRecordData(Buff)^.rdRecordNumber;
          InternalRefreshRow;
        finally
          FSavedFlag := False;
        end;
      end;
    end;
  finally
    FInternalProcess := False;
  end;
end;

procedure TgdcBase.InternalDeleteRecord(Qry: TIBSQL; Buff: Pointer);
var
  DidActivate: Boolean;
  CFull: TgdcFullClass;
  C: CgdcBase;
  Obj: TgdcBase;
  CutOff: Integer;
  FirstPass: Boolean;
  FSavepoint: String;
  RF: TatRelationField;
begin
  FInternalProcess := True;
  try
    if (Assigned(FUpdateObject) and (FUpdateObject.GetSQL(DB.ukDelete).Text > '')) then
      FUpdateObject.Apply(DB.ukDelete)
    else if not FDataTransfer then
    begin
      if GetCurrRecordClass.gdClass = Self.ClassType then
      begin
        //!!!
        FSavepoint := '';
        DidActivate := ActivateTransaction;
        try
        //!!!
          {savepoints support}
          if (not DidActivate) and UseSavepoints then
          begin
            FSavepoint := 'S' + System.Copy(StringReplace(
              StringReplace(
                StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
                '-', '', [rfReplaceAll]), 1, 30);
            try
              Transaction.SetSavePoint(FSavepoint);
            except
              UseSavepoints := False;
              FSavepoint := '';
            end;
          end;
          {end savepoints support}

          if Assigned(BeforeInternalDeleteRecord) then
            BeforeInternalDeleteRecord(Self);

          IBLogin.AddEvent('������ �������',
            Self.ClassName + ' ' + Self.SubType,
            ID,
            Transaction);

          { TODO : ��. ����������� � ������������ }
          CutOff := 5;
          repeat
            try
              if (Qry = QDelete) then
                _CustomDelete(Buff);
              CutOff := 0;
            except
              on E: EIBError do
              begin
                if (E.IBErrorCode = isc_lock_conflict) or (E.IBErrorCode = isc_deadlock) then
                begin
                  if (CutOff > 1) and DidActivate and AllowCloseTransaction then
                  begin
                    Transaction.Rollback;
                    Sleep(500);
                    Dec(CutOff);
                    Transaction.StartTransaction;
                  end else
                  begin
                    if sDialog in BaseState then
                    begin
                      MessageBox(ParentHandle, PChar(
                        '������ �������� ����������. ������ �� ����� ���� ��������� ������.'#13#10#13#10 +
                        '������ ������������ �������������: ' + GetUserByTransaction(StatusVectorArray[9]) + #13#10 +
                        '��������� �������:'#13#10 +
                        '  1. ������ ������������ � ���� ������ � ������ ������ �������� ������.'#13#10 +
                        '  2. �������� ������ �������� � ������ ������ � ������ ���� ���������. '#13#10 +
                        '  3. ��������� ������ ������ �� ����� ��������� ������ ������, �������'#13#10 +
                        '     ����������� ������ ������������ ��� ������� ���������� � ������ ���� ���������.'#13#10#13#10 +
                        '���������� ��������� ������ ����� ��� �������� ���� (������) � ������� ������� ������'#13#10 +
                        '��-�����������, �� ��������� ������� ����� ���������� ���� �� ������.'#13#10 +
                        ''#13#10 +
                        '� ������ ���������� �������� ���������� � ��������������.'),
                        '��������',
                        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
                      Abort;
                    end else
                      raise;
                  end;
                end else
                  raise;
              end else
                raise;
            end;
          until CutOff = 0;

          if Assigned(IBLogin)
            and IBLogin.IsIBUserAdmin
            and Assigned(gdcBaseManager)
            and Assigned(atDatabase) then
          begin
            RF := atDatabase.FindRelationField(GetListTable(SubType), GetKeyField(SubType));

            if (RF <> nil) and (RF.References = nil) then
              gdcBaseManager.DeleteRUIDByID(ID, Transaction);
          end;

          if Assigned(AfterInternalDeleteRecord) then
            AfterInternalDeleteRecord(Self);
        //!!!

          if DidActivate and AllowCloseTransaction then
            Transaction.Commit;

          if (FSavepoint > '') and Transaction.InTransaction then
          begin
            try
              Transaction.ReleaseSavePoint(FSavepoint);
            except
            end;
          end;
        except
          if DidActivate and AllowCloseTransaction then
            Transaction.Rollback
          else if (FSavepoint > '') and Transaction.InTransaction then
          begin
            try
              Transaction.RollBackToSavePoint(FSavepoint);
              Transaction.ReleaseSavePoint(FSavepoint);
            except
            end;
          end;
          raise;
        end;
        //!!!
      end else
      begin
        FirstPass := True;
        repeat
          CFull := GetCurrRecordClass;
          C := CFull.gdClass;
          Obj := CgdcBase(C).CreateWithID(Owner, Database, Transaction,
            ID, CFull.SubType);
          try
            if sMultiple in Self.BaseState then
            begin
              Obj.BaseState := Obj.BaseState + [sMultiple];
              if sAskMultiple in Self.BaseState then
                Obj.BaseState := Obj.BaseState + [sAskMultiple];
              if sSkipMultiple in Self.BaseState then
                Obj.BaseState := Obj.BaseState + [sSkipMultiple];
            end;

            Obj.Open;
            if Obj.RecordCount = 0 then
            begin
              if FirstPass then
              begin
                FirstPass := False;
                InternalRefresh;
                continue;
              end else
              begin
                MessageBox(ParentHandle,
                  '���������� ������� ��������� ������.'#13#10 +
                  '��������, �������� ����������� ������ ��� ���������� �������� ������.'#13#10#13#10 +
                  '� ������ ���������� �������� ���������� � ���������� ��������������.',
                  '��������',
                  MB_OK or MB_ICONHAND or MB_TASKMODAL);
                Abort;
              end;
            end;

            Obj.Delete;

            if sMultiple in Self.BaseState then
            begin
              if sAskMultiple in Obj.BaseState then
                Include(FBaseState, sAskMultiple)
              else
                Exclude(FBaseState, sAskMultiple);

              if sSkipMultiple in Obj.BaseState then
                Include(FBaseState, sSkipMultiple)
              else
                Exclude(FBaseState, sSkipMultiple);
            end;

            break;
          finally
            Obj.Free;
          end;
        until False;
      end;
    end;
    with PRecordData(Buff)^ do
    begin
      rdUpdateStatus := usDeleted;
      rdCachedUpdateStatus := cusUnmodified;
    end;
    WriteRecordCache(PRecordData(Buff)^.rdRecordNumber, Buff);
  finally
    FInternalProcess := False;
  end;
end;

class function TgdcBase.IsBigTable: Boolean;
begin
  //...
  Result := False;
end;

procedure TgdcBase.Loaded;
begin
  inherited Loaded;
  QueryFiltered := True;
end;

function TgdcBase.CheckNeedModify(SourceDS: TDataSet; IDMapping: TgdKeyIntAssoc): Boolean;
const
  PassFieldName = ';EDITIONDATE;CREATIONDATE;CREATORKEY;EDITORKEY;ACHAG;AVIEW;AFULL;LB;RB;';
var
  IsDifferent: Boolean;
  I: Integer;
  R: TatRelation;
  F: TatRelationField;
  Key: Integer;
  SourceSt, CurrentSt: String;
begin
  Result := True;

  //���� ��� ������ - ����������� ����-������, �� �������������� �� ���������
  if Self.InheritsFrom(TgdcMetaBase) and (not (Self as TgdcMetaBase).IsUserDefined) then
    Exit;

  case Self.StreamProcessingAnswer of
    mrYesToAll: Result := True;
    mrNoToAll: Result := False;
    else
    begin
      if NeedModifyFromStream(SubType) <> ModifyFromStream then
     {�������� ��� ��������� ���� "��������� �� ������" �������,
      ����� ��� �� ���������� �� ���� ����������, �� ���������� ��� ������������ ������}
      begin
        {$IFDEF DUNIT_TEST}
        Self.StreamProcessingAnswer := mrYesToAll;
        {$ELSE}
        Self.StreamProcessingAnswer := MessageDlg('������ ' + GetDisplayName(SubType) + ' ' +
          FieldByName(GetListField(SubType)).AsString + ' � ��������������� ' +
          FieldByName(GetKeyField(SubType)).AsString + ' ��� ���������� � ����. ' +
          '�������� ������? ', mtConfirmation,
          [mbYes, mbYesToAll, mbNo, mbNoToAll], 0);
        {$ENDIF}
        case Self.StreamProcessingAnswer of
          mrYes, mrYesToAll: Result := True;
          else Result := False;
        end;
      end
      else
      begin
        if Assigned(SourceDS.FindField(fneditiondate)) and Assigned(FindField(fneditiondate)) then
        begin
          Result := False;
          if (SourceDS.FieldByName(fneditiondate).AsDateTime <= FieldByName(fneditiondate).AsDateTime) then
          begin
            IsDifferent := False;

            //�������� �� ������� ����������� ����� ����������� ������ �� ������������
            for I := 0 to SourceDS.Fields.Count - 1 do
            begin
              if Assigned(FindField(SourceDS.Fields[I].FieldName)) and
                //�������� �� �������� ���� editiondate, keyfield, editorkey
                (AnsiCompareText(Trim(SourceDS.Fields[I].FieldName), GetKeyField(SubType)) <> 0) and
                (AnsiPos(';' + AnsiUpperCase(Trim(SourceDS.Fields[I].FieldName)) + ';', PassFieldName) = 0) then
              begin
                F := nil;
                if Assigned(atDatabase) and (SourceDS.Fields[I].DataType in [ftInteger, ftSmallInt, ftWord]) then
                begin
                 //��������� �� �������� �� ���� ���� �������
                  R := atDatabase.Relations.ByRelationName(RelationByAliasName(SourceDS.Fields[I].FieldName));
                  if Assigned(R) then
                    F := R.RelationFields.ByFieldName(FieldNameByAliasName(SourceDS.Fields[I].FieldName));
                  if Assigned(F) and Assigned(F.References) then
                  begin
                    //���� ��� ������� SourceDS �� ������ (IDMapping <> nil)
                    //�� ���� ����������� ����� ������
                    //� �������� ������ (�.�. ���� ��� ������� ������������ SourceDS)
                    //����� ������� ��������
                    if Assigned(IDMapping) then
                    begin
                      Key := IDMapping.IndexOf(SourceDS.Fields[I].AsInteger);
                      if Key <> -1 then
                      begin
                        Key := IDMapping.ValuesByIndex[Key];
                      end;
                      if (Key = -1) and (SourceDS.Fields[I].AsInteger < cstUserIDStart) then
                        Key := SourceDS.Fields[I].AsInteger;
                    end
                    else
                      Key := SourceDS.Fields[I].AsInteger;

                    //���������� ���� ������
                    if (Key <> FieldByName(SourceDS.Fields[I].FieldName).AsInteger) then
                    begin
                      IsDifferent := True;
                      Break;
                    end;
                    Continue;
                  end;
                end;

                if (Trim(SourceDS.Fields[I].AsString) = '') and (SourceDS.Fields[I].AsString > '') then
                //���� ������ � ��� �������� ������ �������
                //�� ��������� �� ����� ��� ����
                  SourceSt := SourceDS.Fields[I].AsString
                else
                //� �������� ������ ������� ������� � ����������� �������
                  SourceSt := Trim(SourceDS.Fields[I].AsString);

                if (Trim(FieldByName(SourceDS.Fields[I].FieldName).AsString) = '') and
                   (FieldByName(SourceDS.Fields[I].FieldName).AsString > '') then
                  CurrentSt := FieldByName(SourceDS.Fields[I].FieldName).AsString
                else
                  CurrentSt := Trim(FieldByName(SourceDS.Fields[I].FieldName).AsString);

                if (CurrentSt <> SourceSt) then
                begin
                  IsDifferent := True;
                  Break;
                end;
              end;
            end;

            if IsDifferent then
            begin
              //���� ����������� ������ ���������� �� ������������ �������, ����� �� �� ���������
              {$IFDEF DUNIT_TEST}
              Self.StreamProcessingAnswer := mrYesToAll;
              {$ELSE}
              Self.StreamProcessingAnswer := MessageDlg('������ ' + GetDisplayName(SubType) + ' ' +
                FieldByName(GetListField(SubType)).AsString + ' � ��������������� ' +
                FieldByName(GetKeyField(SubType)).AsString + ' ����� ����� ������� �����������, ' +
                '��� ����������� �� ������. �������� ������? ', mtConfirmation,
                [mbYes, mbYesToAll, mbNo, mbNoToAll], 0);
              {$ENDIF}  
              case Self.StreamProcessingAnswer of
                mrYes, mrYesToAll: Result := True;
                else Result := False;
              end;
            end;
          end else if (SourceDS.FieldByName(fneditiondate).AsDateTime > FieldByName(fneditiondate).AsDateTime) then
          begin
            Result := True;
          end;
        end;
      end;
    end;
  end;
end;

procedure TgdcBase._LoadFromStreamInternal(Stream: TStream; IDMapping: TgdKeyIntAssoc;
  ObjectSet: TgdcObjectSet; UpdateList: TObjectList; StreamRecord: TgsStreamRecord);

  procedure InsertRecord(SourceDS: TDataSet; TargetDS: TgdcBase; UL: TObjectList); forward;

  procedure AddToIDMapping(const AKey, AValue: Integer; const ARecordState: TLoadedRecordState);
  var
    IDMappingIndex: Integer;
  begin
    if (IDMapping.IndexOf(AKey) = -1) then
    begin
      IDMappingIndex := IDMapping.Add(AKey);
      IDMapping.ValuesByIndex[IDMappingIndex] := AValue;
      TLoadedRecordStateList(IDMapping).StateByIndex[IDMappingIndex] := ARecordState;
    end;
  end;

  procedure CopySetRecord(SourceDS: TDataSet);
  const
    sql_SetSelect = 'SELECT * FROM %0:s WHERE %1:s';
    sql_SetUpdate = 'UPDATE %0:s SET %1:s WHERE %2:s';
    sql_SetInsert = 'INSERT INTO %0:s (%1:s) VALUES (%2:s)';
  var
    ibsql: TIBSQL;
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
        F := atDataBase.FindRelationField(SourceDS.FieldByName('_SETTABLE').AsString,
          GetSetFieldName(SourceDS.Fields[I].FieldName));
        if (F <> nil) and (F.References <> nil) then
        begin
          // ���� ��� ���� �������� �������, �� ������ ��� � ����� ���������������
          Key := IDMapping.IndexOf(SourceDS.Fields[I].AsInteger);
          if Key > -1 then
            SKey := IntToStr(IDMapping.ValuesByIndex[Key])
          else
            SKey := SourceDS.Fields[I].AsString;
        end
        else
          SKey := SourceDS.Fields[I].AsString;
        SKey := StringReplace(SKey, ',', '.', []);   
        SValues := SValues + SKey;
        SUpdate := SUpdate + GetSetFieldName(SourceDS.Fields[I].FieldName) + ' = ' + SKey;
      end;
    end;

    // ���� �������������� ����-���������, �� ������� �������� � ��
    if SFld > '' then
    begin
      R2 := atDataBase.Relations.ByRelationName(SourceDS.FieldByName('_SETTABLE').AsString);
      Pr := R2.PrimaryKey;

      if not Assigned(Pr) then
      begin
        {
          ���� ������� ���������� � ������ � ����� ���������, ��
          ��������������� � ���� ��� �� ���� � ���������� � atDatabase
          � ��� ����� � �� ����. ������� ���������� ��.
        }
        R2.RefreshData(Transaction.DefaultDatabase, Transaction, True);
        R2.RefreshConstraints(Transaction.DefaultDatabase, Transaction);

        Pr := R2.PrimaryKey;
      end;

      if Assigned(Pr) then
      begin
        try
          S := '';
          for I := 0 to Pr.ConstraintFields.Count - 1 do
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
              begin
                // ���� ��� ���� �������� �������, �� ������ ��� � ����� ���������������
                Key := IDMapping.IndexOf(SourceDS.FieldByName(S1).AsInteger);
                if Key > -1 then
                begin
                  SKey := IntToStr(IDMapping.ValuesByIndex[Key]);
                  // ������������ ��� ������ ����� ����� � ��������� ����� ������� ������
                  if I = 0 then
                    LoadedRecordState := TLoadedRecordStateList(IDMapping).StateByIndex[Key];
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
            ibsql := TIBSQL.Create(nil);
            try
              ibsql.Transaction := Transaction;
              ibsql.SQL.Text := Format(sql_SetSelect, [SourceDS.FieldByName('_SETTABLE').AsString, S]);
              ibsql.ExecQuery;

              if ibsql.RecordCount > 0 then
              begin
              { TODO -oJulia : ��� ������ � ��� ������������� �������? ���������?
                � �����-�� ������ ��� ����� ����� �����, ��������, ������� gd_lastnumber }
      {          ibsql.Close;
                ibsql.SQL.Text := Format(sql_SetUpdate,
                  [SourceDS.FieldByName('_SETTABLE').AsString, SUpdate, S]);}
              end
              else
              begin
                ibsql.Close;
                ibsql.SQL.Text := Format(sql_SetInsert,
                  [SourceDS.FieldByName('_SETTABLE').AsString, SFld, SValues]);

                R := atDataBase.Relations.ByRelationName(SourceDS.FieldByName('_SETTABLE').AsString);
                if Assigned(R) then
                  LocName := R.LName
                else
                  LocName := SourceDS.FieldByName('_SETTABLE').AsString;

                AddText('���������� ������ ��������� ' + LocName + #13#10, clBlue);
                ibsql.ExecQuery;
              end;
            finally
              ibsql.Free;
            end;
          end;
        except
          on E: Exception do
          begin
            AddMistake(E.Message, clRed);
          end;
        end;
      end
      else
      begin
        AddWarning(#13#10 + '������ ��������� ' + SourceDS.FieldByName('_SETTABLE').AsString + ' �� ���� ���������!'#13#10, clRed);
      end;
    end;
  end;

  procedure ApplyDelayedUpdates(UL: TObjectList; SourceKeyValue, TargetKeyValue: Integer);
  var
    I: Integer;
    Obj: TgdcBase;
  begin
    for I := UL.Count - 1 downto 0 do
    begin
      if (UL[I] as TgdcReferenceUpdate).RefID = SourceKeyValue then
      begin
        // �� ���������� ����� � �-� ����� ���� ������ �-� �������� => ������� ����� �-�, � �� ����� ibsql
        Obj := (UL[I] as TgdcReferenceUpdate).FullClass.gdClass.CreateSubType(nil,
          (UL[I] as TgdcReferenceUpdate).FullClass.SubType, 'ByID');
        try
          // ���������� ������ ���� �������
          Obj.Transaction := Transaction;
          Obj.ReadTransaction := Transaction;
          Obj.ID := (UL[I] as TgdcReferenceUpdate).ID;
          Obj.Open;
          if Obj.RecordCount > 0 then
          begin
            Obj.BaseState := Obj.BaseState + [sLoadFromStream];
            Obj.Edit;
            Obj.FieldByName((UL[I] as TgdcReferenceUpdate).FieldName).AsInteger := TargetKeyValue;
            Obj.Post;
          end;
        finally
          Obj.Free;
        end;
        UL.Delete(I);
      end;
    end;
  end;

  function CopyRecord(SourceDS: TDataSet; TargetDS: TgdcBase; UL: TObjectList): Boolean;
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
    LoadedRecordState: TLoadedRecordState;
    RUOL: TList;
  begin
    NeedAddToIDMapping := True;
    LoadedRecordState := lsCreated;
    Result := False;
    RUOL := nil;

    try
      // ���������� �� ����� �� ������ � ��������� �� �������� � ��� ������
      for I := 0 to SourceDS.FieldCount - 1 do
      begin
        SourceField := SourceDS.Fields[I];
        TargetField := TargetDS.FindField(SourceField.FieldName);

        // ���� �� ����� ���� � ����� �������, �� ������ � ����� ������� ��� �����������
        if (TargetField <> nil) then
        begin
          R := atDatabase.Relations.ByRelationName(TargetDS.RelationByAliasName(TargetField.FieldName));

          // ��������� ������ ��� � ����� ��������� ����������
          if R = nil then
          begin
            // ���� ��� �������� ����, �� ��������� � ���������� ����
            if (AnsiCompareText(SourceField.FieldName, TargetDS.GetKeyField(TargetDS.SubType)) = 0) then
              Continue;

            if (TargetField.DataType = ftString) and (SourceField.AsString = '') then
              TargetField.AsString := ''
            else
              TargetField.Assign(SourceField);
            Continue;
          end;

          // ���� ��� ������� ����� ������ ��������� ���� ��� ��������� ���� � ��� ������ � ��� �� ������ ����
          //   �� ������������� ����� "��� ����"
          // ��� ���������� ������ �� ������� ����� �������
          {if (TargetDS.State = dsInsert)
             and (AnsiPos(';' + AnsiUpperCase(TargetField.FieldName) + ';', rightsfield) > 0)
             and (StreamRecord.StreamDBID > -1) and (StreamRecord.StreamDBID <> IBLogin.DBID) then
          begin
            TargetField.AsInteger := -1;
            Continue;
          end;}
          // ������ ��������� ����� ���� �������, ��������� ��
          if AnsiPos(';' + AnsiUpperCase(TargetField.FieldName) + ';', rightsfield) > 0 then
            Continue;

          //���� ��� ���� ��� �������� "��� ������������", �� ��������� �������� ������������
          if (AnsiPos(';' + AnsiUpperCase(TargetField.FieldName) + ';', editorfield) > 0)
          then
          begin
            TargetField.AsInteger := IBLogin.ContactKey;
            Continue;
          end;

          //���� ��� ������ ��������
          if (TargetDS is TgdcDocument) and (TargetField.FieldName = fnDOCUMENTKEY)
            and (TargetField.Value > 0)
          then
            continue;

          F := R.RelationFields.ByFieldName(TargetDS.FieldNameByAliasName(TargetField.FieldName));

          IsNull := False;
          Key := -1;

          if (AnsiCompareText(SourceField.FieldName, TargetDS.GetKeyField(TargetDS.SubType)) = 0) then
          begin
            if (F <> nil) and (F.References <> nil) then
            begin
              //���� ��� �������� ���� � ��� �������� �������, �� ������ ��� � ����� ���������������
              Key := IDMapping.IndexOf(SourceField.AsInteger);
              if Key <> -1 then
              begin
                Key := IDMapping.ValuesByIndex[Key];
              end;
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
            if (ObjectSet.Find(SourceField.AsInteger) <> -1) and
              (SourceField.AsInteger = SourceDS.FieldByName(TargetDS.GetKeyField(TargetDS.SubType)).AsInteger) and
              (TargetDS.FieldByName(TargetDS.GetKeyField(TargetDS.SubType)).AsInteger > 0)
            then
              Key := TargetDS.FieldByName(TargetDS.GetKeyField(TargetDS.SubType)).AsInteger
            else
            begin
              if SourceField.IsNull then
                IsNull := True
              else if SourceField.AsInteger < cstUserIDStart then
                Key := SourceField.AsInteger
              else begin
                //���� ��� � ����� ���������������
                Key := IDMapping.IndexOf(SourceField.AsInteger);
                if Key <> -1 then
                begin
                  Key := IDMapping.ValuesByIndex[Key];
                  IsNull := Key = -1;
                end;
              end;  
            end;

            if (Key = -1) and (ObjectSet.Find(SourceField.AsInteger) <> -1) and
              (SourceField.AsInteger <> SourceDS.FieldByName(TargetDS.GetKeyField(TargetDS.SubType)).AsInteger) then
            begin
              if not Assigned(RUOL) then
                RUOL := TList.Create;

              RU := TgdcReferenceUpdate.Create;
              RU.FieldName := F.FieldName;
              RU.FullClass.gdClass := CgdcBase(Self.ClassType);
              RU.FullClass.SubType := Self.SubType;
              RU.ID := -1;
              RU.RefID := SourceField.AsInteger;
              UL.Add(RU);
              RUOL.Add(RU);
              IsNull := True;
            end else if (Key = -1) and (SourceField.AsInteger >= cstUserIDStart) then
            begin
              //���� �� �� ����� ���� ������ � ��� �� �������� "�����������" �������
              //������� ��� ����, ����� ����� ������ ��������� �����������
              //����� ������ ����� ���������� �� ���������� � ����� �� ������ ��������
              //��������, � ����� �� ����������� ��������� ����-������
              IsNull := True;
            end;
          end;

          if Key = -1 then
          begin
            if IsNull then
              TargetField.Clear
            else
            begin
              if SourceField.IsNull then
                TargetField.Clear
              else
              begin
                if (TargetField.DataType = ftString) and (SourceField.AsString = '') then
                  TargetField.AsString := ''
                else
                  TargetField.Assign(SourceField);
              end;
            end
          end else
          begin
            if IsNull then
              TargetField.Clear
            else
              TargetField.AsInteger := Key;
          end;
        end;
      end;

      //����������� id �� ������ ��������
      if SourceDS.FieldByName(TargetDS.GetKeyField(TargetDS.SubType)).AsInteger < cstUserIDStart then
        TargetDS.FieldByName(TargetDS.GetKeyField(TargetDS.SubType)).AsInteger :=
          SourceDS.FieldByName(TargetDS.GetKeyField(TargetDS.SubType)).AsInteger;

      try
        if TargetDS.State = dsEdit then
        begin
          try
            TargetDS.Post;
            AddText('������ �������� ������� �� ������!', clBlack);
            LoadedRecordState := lsModified;
          except
            on E: EIBError do
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
                gdcBaseManager.DeleteRUIDByXID(SourceDS.FieldByName('_XID').AsInteger,
                  SourceDS.FieldByName('_DBID').AsInteger, Transaction);
                InsertRecord(SourceDS, TargetDS, UL);
                NeedAddToIDMapping := False;
              end else
                raise;
            end;
          end;
        end
        else if not TargetDS.CheckTheSame(True) then
          TargetDS.Post;

        if NeedAddToIDMapping then
          AddToIDMapping(SourceDS.FieldByName(TargetDS.GetKeyField(SubType)).AsInteger, TargetDS.ID, LoadedRecordState);

        if Assigned(RUOL) then
        begin
          for I := 0 to RUOL.Count - 1 do
            TgdcReferenceUpdate(RUOL[I]).ID := TargetDS.ID;
        end;

        ApplyDelayedUpdates(UL,
          SourceDS.FieldByName(TargetDS.GetKeyField(SubType)).AsInteger,
          TargetDS.ID);
        ObjectSet.Remove(SourceDS.FieldByName(TargetDS.GetKeyField(SubType)).AsInteger);

        Result := True;
      except
        on E: EDatabaseError do
        begin
          if TargetDS.State = dsInsert then
            ErrorSt := Format('���������� �������� ������: %s %s %s ',
              [TargetDS.ClassName,
               SourceDS.FieldByName(TargetDS.GetListField(TargetDS.SubType)).AsString,
               SourceDS.FieldByName(TargetDS.GetKeyField(TargetDS.SubType)).AsString])
          else
            ErrorSt := Format('���������� �������� ������: %s %s %s',
              [TargetDS.ClassName,
               SourceDS.FieldByName(TargetDS.GetListField(TargetDS.SubType)).AsString,
               SourceDS.FieldByName(TargetDS.GetKeyField(TargetDS.SubType)).AsString]);

          //AddMistake(ErrorSt, clRed);
          AddMistake(E.Message, clRed);

          TargetDS.Cancel;
          AddToIDMapping(SourceDS.FieldByName(TargetDS.GetKeyField(SubType)).AsInteger, -1, lsNotLoaded);
        end;
      end;
    finally
      if Assigned(RUOL) then
        RUOL.Free;
    end;
  end;

  procedure InsertRecord(SourceDS: TDataSet; TargetDS: TgdcBase; UL: TObjectList);
  var
    RR: TRUIDRec;
  begin
    //��������� ������ � ��� ������
    TargetDS.Insert;
    //���� ������� ����� �� ������ ������ ���������
    if CopyRecord(SourceDS, TargetDS, UL) then
    begin
      TargetDS.CheckBrowseMode;
      //��������� �������� �� ���� � ����
      RR := gdcBaseManager.GetRUIDRecByID(TargetDS.ID, Transaction);
      if RR.XID = -1 then
      begin
        //���� ���, �� ��������� � ����
        gdcBaseManager.InsertRUID(TargetDS.ID, SourceDS.FieldByName('_XID').AsInteger, SourceDS.FieldByName('_DBID').AsInteger,
          SourceDS.FieldByName('_MODIFIED').AsDateTime, IBLogin.ContactKey, Transaction);
      end else
      begin
        //���� ��, �� ��������� ���� ���� �� ��� ID
        gdcBaseManager.UpdateRUIDByID(TargetDS.ID, SourceDS.FieldByName('_XID').AsInteger, SourceDS.FieldByName('_DBID').AsInteger,
          SourceDS.FieldByName('_MODIFIED').AsDateTime, IBLogin.ContactKey, Transaction);
      end;
    end;
  end;

var
  CDS: TClientDataSet;
  I, D: Integer;
  MS: TMemoryStream;
  Modified: TDateTime;
  DidActivate: Boolean;
  RuidRec: TRuidRec;
begin
  Assert(IBLogin <> nil);

  //���������, ��� ����� �������� �� ������
  Include(FBaseState, sLoadFromStream);
  //��������� ������ �������
  CDS := TClientDataSet.Create(nil);
  try
    Stream.ReadBuffer(I, SizeOf(I));
    MS := TMemoryStream.Create;
    try
      MS.CopyFrom(Stream, I);
      MS.Position := 0;
      CDS.LoadFromStream(MS);
    finally
      MS.Free;
    end;

    CDS.Open;

    if sFakeLoad in BaseState then
    begin
      if Assigned(OnFakeLoad) then
        OnFakeLoad(Self, CDS);

      exit;
    end;

    //��������� �� ������������ ���� ��� �����������
    if (CDS.FindField(GetListField(SubType)) = nil) then
    begin
      AddText('������ "' + GetDisplayName(GetSubType) + '" (XID =  ' + CDS.FieldByName('_xid').AsString + ', DBID = ' +
        CDS.FieldByName('_dbid').AsString + ')', clBlue);

      AddMistake('��������� ������������ ������� �� ������������� ��������� ��� ������������� ������� � ����. '#13#10 +
        ' ���� ' + GetListField(SubType) + ' �� ������� � ������ ������!', clRed);
    end
    else
    begin
      AddText('������ "' + GetDisplayName(GetSubType) + ' ' + CDS.FieldByName(GetListField(SubType)).AsString +
        '" (XID =  ' + CDS.FieldByName('_xid').AsString + ', DBID = ' +
        CDS.FieldByName('_dbid').AsString + ')', clBlue);
    end;

    FStreamXID := CDS.FieldByName('_xid').AsInteger;
    FStreamDBID := CDS.FieldByName('_dbid').AsInteger;

    DidActivate := False;
    try
      DidActivate := ActivateTransaction;

      //��������, ���� �� � ��� ����� ����
      RuidRec := gdcBaseManager.GetRUIDRecByXID(CDS.FieldByName('_XID').AsInteger,
        CDS.FieldByName('_DBID').AsInteger,
        Transaction);
      //������� id, ��������� �� �����
      D := RuidRec.ID;

      //���� �� �� ����� ����, �� ��� xid - "�����������"
      if (D = -1) and (CDS.FieldByName('_XID').AsInteger < cstUserIDStart) then
      begin
        //��������� �������� ���� ������
        if SubSet <> 'ByID' then
          SubSet := 'ByID';
        ID := CDS.FieldByName('_XID').AsInteger;
        Open;

        //���� �����, �� �������� ����
        if not EOF then
        begin
          gdcBaseManager.InsertRUID(CDS.FieldByName('_XID').AsInteger,
            CDS.FieldByName('_XID').AsInteger,
            CDS.FieldByName('_DBID').AsInteger, Date, IBLogin.ContactKey, Transaction);
          //�������� ��� XID = id
          D := CDS.FieldByName('_XID').AsInteger;
        end;
      end;

      //���� ������ � ���� �� �������, ������� ��
      if D = -1 then
      begin
        InsertRecord(CDS, Self, UpdateList);
      end else
      begin
        //��������, ����� ��� ������������� ���� ��������� ������
        Modified := RUIDRec.Modified;

        //��������� �������� ���� ������
        if SubSet <> 'ByID' then
          SubSet := 'ByID';
        ID := D;
        Open;

        if EOF then
        begin
        //���� �� �����, ������ ���� �����������, ������ ���, ������ �������
          gdcBaseManager.DeleteRUIDbyXID(CDS.FieldByName('_XID').AsInteger,
            CDS.FieldByName('_DBID').AsInteger, Transaction);

          InsertRecord(CDS, Self, UpdateList);
        end else
        begin
          // ������ �������, ���� ���������
          AddText('������ ������ �� �����'#13#10, clBlue);

          //���������, ���������� �� ��� ������� ��������� ������, ����� ����������� �� ������� �� ������
          if NeedDeleteTheSame(SubType) and
            DeleteTheSame(D, CDS.FieldByName(GetListField(SubType)).AsString)
          then
          begin
            //���� ������ �������, ������� �� ������ �� ������
            InsertRecord(CDS, Self, UpdateList);
          end else

          //���� �� ����� ������ �� ����� �
          //���� ���� ����������� ����� ����� ������, ��� ����������� �� ������
          //��� ������ ��������� � ���������� ������� �� ������ �� ���������

          if ModifyFromStream {or (Modified < CDS.FieldByName('_modified').AsDateTime)} then
          begin
            if ID <> D then
            begin
              ID := D;
            end;

            //�������, ��������� �� ��� ������ � ���������� ������� �� ������
            if CheckNeedModify(CDS, IDMapping) then
            begin
              Edit;
              //���� ���������� ������ ������� � �� ����� ����� ������ ���� ����������� �����
              //�������� ����
              if CopyRecord(CDS, Self, UpdateList) and
                (Modified < CDS.FieldByName('_modified').AsDateTime) then
              begin
                CheckBrowseMode;

                gdcBaseManager.UpdateRUIDByXID(ID, CDS.FieldByName('_XID').AsInteger, CDS.FieldByName('_DBID').AsInteger,
                  CDS.FieldByName('_MODIFIED').AsDateTime, IBLogin.ContactKey, Transaction);
              end;
            end
            else
            begin
              //�������� ������������ ������ ID � ID �� ������ � ����� ���������������
              AddToIDMapping(CDS.FieldByName(GetKeyField(SubType)).AsInteger, ID, lsNotLoaded);

              ApplyDelayedUpdates(UpdateList,
                CDS.FieldByName(GetKeyField(SubType)).AsInteger, ID);
            end;
          end
          else
          begin
            //�������� ������������ ������ ID � ID �� ������ � ����� ���������������
            AddToIDMapping(CDS.FieldByName(GetKeyField(SubType)).AsInteger, ID, lsNotLoaded);

            ApplyDelayedUpdates(UpdateList,
              CDS.FieldByName(GetKeyField(SubType)).AsInteger, ID);
          end;
        end;
      end;

      //���� ���� ����-���������, �� ���������� ��
      CopySetRecord(CDS);
    finally
      if DidActivate and Transaction.InTransaction then
        Transaction.Commit;
    end;
  finally
    CDS.Free;
    Exclude(FBaseState, sLoadFromStream);
  end;
end;

procedure TgdcBase._LoadFromStream(Stream: TStream; IDMapping: TgdKeyIntAssoc;
  ObjectSet: TgdcObjectSet; UpdateList: TObjectList);
var
  I: Integer;
  Obj: TgdcBase;
  C: TClass;
  IDMappingCreated: Boolean;
  LoadClassName, LoadSubType: String;
  ULCreated: Boolean;
  DidActivate: Boolean;
  OldPos: Integer;
  stVersion: String;
  stRecord: TgsStreamRecord;
  RecCount: Integer;
  PrSet: TgdcPropertySet;
  PropInfo: PPropInfo;
  ObjList: TStringList;
  Ind, ObjDataLen: Integer;
  AClassList: TStringList;
begin
  Assert(IBLogin <> nil, 'IBLogin not assigned');
  Assert(atDatabase <> nil, 'atDatabase not assigned');
  Assert(ObjectSet <> nil, 'ObjectSet not assigned');

  Obj := nil;

  if not (sFakeLoad in BaseState) then
  begin
    CheckBrowseMode;

    if Assigned(frmStreamSaver) then
      frmStreamSaver.SetupProgress(ObjectSet.Count, '��������...');

    AddText('������ �������� ������ �� ������.', clBlack);

    if Assigned(frmSQLProcess) and Assigned(ObjectSet) then
    begin
      with frmSQLProcess.pb do
      begin
        Min := 0;
        Max := ObjectSet.Count;
        Position := 0;
      end;
    end;
  end;

  ObjList := TStringList.Create;

  //���� ����������
  //������� ����� ���������������
  if IDMapping = nil then
  begin
    IDMapping := TLoadedRecordStateList.Create;
    IDMappingCreated := True;
  end else
    IDMappingCreated := False;

  if UpdateList = nil then
  begin
    UpdateList := TObjectList.Create(True);
    ULCreated := True;
  end else
    ULCreated := False;

  PrSet := TgdcPropertySet.Create('', nil, '');
  AClassList := TStringList.Create;
  try
    AClassList.Duplicates := dupIgnore;
    AClassList.Sorted := True;

    DidActivate := False;
    try
      DidActivate := ActivateTransaction;

      RecCount := 0;
      SetLength(stVersion, Length(cst_WithVersion));
      while Stream.Position < Stream.Size do
      begin
        // �������� ��� �� ����� ��� ��������� ��� ���������� ��
        Stream.ReadBuffer(I, SizeOf(I));
        if I <> cst_StreamLabel then
          raise EgdcException.CreateObj('Invalid stream format', Self);

        OldPos := Stream.Position;
        try
          Stream.ReadBuffer(stVersion[1], Length(cst_WithVersion));
        except
          break;
        end;
        if stVersion = cst_WithVersion then
        begin
          Stream.ReadBuffer(stRecord.StreamVersion, SizeOf(stRecord.StreamVersion));
          if stRecord.StreamVersion >= 1 then
            Stream.ReadBuffer(stRecord.StreamDBID, SizeOf(stRecord.StreamDBID));
        end else
        begin
          stRecord.StreamVersion := 0;
          stRecord.StreamDBID := -1;
          Stream.Position := OldPos;
        end;
        // ��������� ����� � ������ ������������ �������
        LoadClassName := StreamReadString(Stream);
        LoadSubType := StreamReadString(Stream);

        //��������� �������� ModifyFromStream
        //��� ������ ������ �� ���� 2
        if stRecord.StreamVersion >= 2 then
        begin
          PrSet.LoadFromStream(Stream);
        end;

        C := GetClass(LoadClassName);

        // ���������� �����, ���� �� �� ������
        if C = nil then
        begin
          if not Self.StreamSilentProcessing then
          begin
            if (AClassList.IndexOf(LoadClassName) = -1)
              and (MessageBox(ParentHandle,
                PChar('��� �������� �� ������ �������� �������������� �����: ' + LoadClassName + #13#10#13#10 +
                '���������� ��������?'),
                '��������',
                MB_YESNO or MB_ICONEXCLAMATION or MB_TASKMODAL) = IDNO) then
            begin
              raise EgdcException.CreateObj('Invalid class name', Self);
            end;
            // ������� � ������ ������������ �������
            AClassList.Add(LoadClassName);
          end;
          Stream.ReadBuffer(ObjDataLen, SizeOf(ObjDataLen));
          Stream.Seek(ObjDataLen, soFromCurrent);
          Continue;
        end;

        if (Obj = nil)
          or (Obj.ClassType <> C)
          or (LoadSubType <> Obj.SubType) then
        begin
          Ind := ObjList.IndexOf(LoadClassName + '('+ LoadSubType + ')');
          if Ind = -1 then
          begin
            Obj := CgdcBase(C).CreateWithParams(nil,
              Database, Transaction, LoadSubType);
            if sFakeLoad in BaseState then
            begin
              Obj.BaseState := Obj.BaseState + [sFakeLoad];
              Obj.OnFakeLoad := Self.OnFakeLoad;
            end;
            Obj.ReadTransaction := Transaction;
            //������� ������
            Obj.SetRefreshSQLOn(False);
            ObjList.AddObject(LoadClassName + '('+ LoadSubType + ')', Obj);
            ObjList.Sort;
          end
          else
            Obj := TgdcBase(ObjList.Objects[Ind]);
        end;

        Obj.StreamSilentProcessing := Self.StreamSilentProcessing;
        Obj.StreamProcessingAnswer := Self.StreamProcessingAnswer;

        if Obj.SubSet <> 'ByID' then
          Obj.SubSet := 'ByID';
        Obj.Open;

         //��������� ��������
        //��� ������ ������ �� ���� 2
        if stRecord.StreamVersion >= 2 then
        begin
          for I := 0 to PrSet.Count - 1 do
          begin
            PropInfo := GetPropInfo(Obj.ClassInfo, PrSet.Name[I]);
            if (PropInfo <> nil) then
            begin
              SetPropValue(Obj, PrSet.Name[I], PrSet.Value[PrSet.Name[I]]);
            end;
          end;
        end;

          //�� ���� ����� ��������������� ������ �������� �������� =>
          //������ ������ ������, �������� ������� � 10 ���
        Obj._LoadFromStreamInternal(Stream, IDMapping, ObjectSet, UpdateList,
          stRecord);
        inc(RecCount);
        // ������ _LoadFromStreamInternal ���� ����� ���������, �������� ��� ������ ��������
        if Obj.StreamProcessingAnswer <> mrNone then
          Self.StreamProcessingAnswer := Obj.StreamProcessingAnswer;

        if not (sFakeLoad in BaseState) then
        begin
          if Assigned(frmStreamSaver) then
            frmStreamSaver.Step;

          if Assigned(frmSQLProcess) then
          begin
            frmSQLProcess.pb.Position := frmSQLProcess.pb.Position + 1;
          end;
        end;

        if ((RecCount mod 500) = 0) and DidActivate and Transaction.InTransaction then
        begin
          Transaction.Commit;
          RecCount := 0;
        end;

      end;

      if DidActivate and Transaction.InTransaction then
        Transaction.Commit;

      if not (sFakeLoad in BaseState) then
      begin
        if Assigned(frmStreamSaver) then
          frmStreamSaver.Done;

        AddText('��������� �������� ������ �� ������.', clBlack);
      end;

    except
      on E: Exception do
      begin
        if DidActivate and Transaction.InTransaction then
          Transaction.Rollback;
        if not (sFakeLoad in BaseState) then
        begin
          if Assigned(frmStreamSaver) then
            frmStreamSaver.AddMistake(E.Message);

          AddMistake(E.Message, clRed);
        end;
        raise;
      end;
    end;
  finally
    PrSet.Free;
    AClassList.Free;

    if IDMappingCreated then
      IDMapping.Free;

    if ULCreated then
      UpdateList.Free;

    for I := 0 to ObjList.Count - 1 do
    begin
      Obj := TgdcBase(ObjList.Objects[I]);
      ObjList.Objects[I] := nil;
      if Assigned(Obj) then
        FreeAndNil(Obj);
    end;
    ObjList.Free;

  end;
end;

procedure TgdcBase.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  if (Operation = Classes.opRemove) and (AComponent <> nil) then
  begin
    if AComponent = FInternalTransaction then
      FInternalTransaction := nil
    else if AComponent = MasterSource then
      MasterSource := nil
    else if AComponent = ReadTransaction then
      ReadTransaction := nil
    else if AComponent is TgdcBase then
      RemoveDetailLink(AComponent as TgdcBase);
  end;
end;

function TgdcBase.ParamByName(Idx: String): TIBXSQLVAR;
begin
  InternalPrepare;
  Result := QSelect.ParamByName(Idx);
end;

function TgdcBase.PasteFromClipboard(const ATestKeyboard: Boolean = False): Boolean;
var
  H: THandle;
  P: PgdcClipboardData;
begin
  Result := False;

  if not CanPasteFromClipboard then
    exit;

  H := Clipboard.GetAsHandle(gdcClipboardFormat);
  if H <> 0 then
  begin
    P := GlobalLock(H);
    try
      if (P <> nil)
        and (P^.Signature = gdcCurrentClipboardSignature)
        and (P^.Version = gdcCurrentClipboardVersion)
        and ((P^.ClassName = '') or (GetClass(P^.ClassName) <> nil))
      then begin
        if ATestKeyboard then
          P.Cut := not (GetAsyncKeyState(VK_CONTROL) < 0);

        if (P^.Obj <> nil) and (gdcObjectList.IndexOf(P^.Obj) = -1) then
          P^.Obj := nil;

        Result := (P^.ObjectCount > 0) and AcceptClipboard(P);
      end;
    finally
      GlobalUnlock(H);
    end;
  end;
end;

class procedure TgdcBase.RefreshStats;
begin
  //...
end;

(*

  ���������� ������� ��������� �������:
  1. �������� ������ �������, ���� ����������� ������� ��
     ������ ��������
  2. ��������� � ���� ������
  3. �������� � �����

*)
procedure TgdcBase._SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
  PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True);

const
  NotSavedField = ';LB;RB;CREATORKEY;EDITORKEY;';
  NotSavedFieldRepl = ';LB;RB;';

  procedure SaveBindedObjectsForTable(const ATableName: String; ReversedList: TgdcObjectSets);
  var
    R: TatRelation;
    I: Integer;
    Obj: TgdcBase;
    C: TgdcFullClass;
    OS: TgdcObjectSet;
    F: TField;
  begin
    Assert(Assigned(ReversedList));

    // ������ ��� ���� ������ � ������� � �����
    // ������� �� ������� ��� ���������
    R := atDatabase.Relations.ByRelationName(ATableName);
    Assert(R <> nil);

    for I := 0 to R.RelationFields.Count - 1 do
    begin

      if (not FReadUserFromStream and (AnsiPos(';' + Trim(R.RelationFields[I].FieldName) + ';', NotSavedField) > 0)) or
         (FReadUserFromStream and (AnsiPos(';' + Trim(R.RelationFields[I].FieldName) + ';', NotSavedFieldRepl) > 0))
      then
        continue;

      F := FindField(R.RelationName, R.RelationFields[I].FieldName);
      if (F = nil) or F.IsNull or (F.DataType <> ftInteger) then
      begin
        continue;
      end;

      if R.RelationFields[I].gdClass <> nil then
      begin
        C.gdClass := CgdcBase(R.RelationFields[I].gdClass);
        C.SubType := R.RelationFields[I].gdSubType;
      end else
      begin
        C.gdClass := nil;
        C.SubType := '';
      end;

      if (C.gdClass = nil) and (R.RelationFields[I].References <> nil) then
      begin
        C := GetBaseClassForRelationByID(R.RelationFields[I].References.RelationName,
          FieldByName(R.RelationName, R.RelationFields[I].FieldName).AsInteger,
          Self.Transaction);
      end;

// ����� ������� �������, ����������� ������������, ����� � ������ ���� ����-������
// �� ��� �� ������
//!!!!
      if (C.gdClass <> nil) and
        (not (Self.ClassType.InheritsFrom(C.gdClass) and (F.AsInteger = ID))) then
      begin
        if IsReverseOrder(F.FieldName) then
        begin
          OS := ReversedList.Find(C);
          if OS = nil then
          begin
            OS := TgdcObjectSet.Create(C.gdClass, C.SubType);
            ReversedList.Add(OS);
          end;
          OS.Add(F.AsInteger, C.gdClass.ClassName, C.SubType, '');
        end else
        begin
          try
            Obj := C.gdClass.CreateSingularByID(nil,
                Database,
                Transaction,
                F.AsInteger,
                C.SubType);
            try
              if (not (Obj is TgdcMetaBase)) or (not TgdcMetaBase(Obj).IsDerivedObject) then
              begin
                //��������� ���� ������ ������� � �� ���������, ������� ����� Self
                //������ ���� �������� ����� Self.ModifyFromStream ���������� �� �������� ���������������� �� ���������
                // (�� �����-�������)
                if Self.ModifyFromStream <> Self.NeedModifyFromStream(Self.SubType) then
                begin
                  Obj.ModifyFromStream := Self.ModifyFromStream;
                end;
                Obj.StreamSilentProcessing := Self.StreamSilentProcessing;
                Obj.StreamProcessingAnswer := Self.StreamProcessingAnswer;
                Obj.FReadUserFromStream := Self.FReadUserFromStream;
                Obj._SaveToStream(Stream, ObjectSet, PropertyList, BindedList, WithDetailList, False);
              end;  
            finally
              Obj.Free;
            end;
          except
            on E: EgdcIDNotFound do
            begin
              MessageBox(0,
                PChar(Format('� �������� ���������� �������� ������.'#13#10+
                '� ������� %s � ���� %s ����������'#13#10+
                '������ �� ������ ���� %s'#13#10+
                '� ��������������� %d, ������,'#13#10+
                '����� ������ � ���� ������ �� ����������.'#13#10+
                '���������, ��������� �� ����� �������-�����'#13#10+
                '� ������ � ���������� ��� ����� ����.',
                  [ATableName, R.RelationFields[I].FieldName,
                  C.gdClass.ClassName + C.SubType,
                  FieldByName(R.RelationName, R.RelationFields[I].FieldName).AsInteger])),
                '������',
                MB_OK or MB_ICONHAND or MB_TASKMODAL);
              raise;
            end;
          end;
        end;
      end;
    end;
  end;

var
  RUID: TRUID;
  CDS: TClientDataSet;
  MS: TMemoryStream;
  ObjectSetCreated: Boolean;
  OL, DL: TObjectList;
  ReversedList: TgdcObjectSets;
  LinkTableList: TStringList;
  ibsql: TIBSQL;
  CurDBID: Integer;
  CurStrVersion: Integer;
  F: TField;
  C: TgdcFullClass;
  PropertyListIndex: Integer;
  PropInfo: PPropInfo;
  FD: TFieldDef;
  {$IFDEF DEBUG}Ch: array[0..255] of Char;{$ENDIF}


  procedure SaveToStreamCLDS(Obj: TgdcBase);
  var
    I, K: Integer;
    PrSets: TgdcPropertySet;
    PrList: TStringList;
    LocName: String;
    R: TatRelation;
  begin
    if SetTable > '' then
    begin
      R := atDataBase.Relations.ByRelationName(SetTable);
      if Assigned(R) then
        LocName := R.LName
      else
        LocName := SetTable;

      AddText('����������: ' + GetDisplayName(GetSubType) + ' ' +
        FieldByName(GetListField(SubType)).AsString + #13#10 +
        ' (' + FieldByName(GetKeyField(SubType)).AsString + ') ' +
        ' � ������� ��������� ' + LocName + #13#10,
        clBlue);
      if Assigned(frmStreamSaver) then
        frmStreamSaver.SetProcessText('����������: ' + GetDisplayName(GetSubType) + ' ' +
          FieldByName(GetListField(SubType)).AsString + #13#10 +
          ' (' + FieldByName(GetKeyField(SubType)).AsString + ') ' +
          ' � ������� ��������� ' + LocName);
    end
    else
    begin
      AddText('����������: ' + GetDisplayName(GetSubType) + ' ' +
        FieldByName(GetListField(SubType)).AsString +
        ' (' + FieldByName(GetKeyField(SubType)).AsString + ')',
        clBlue);
      if Assigned(frmStreamSaver) then
        frmStreamSaver.SetProcessText('����������: ' + GetDisplayName(GetSubType) + ' ' +
          FieldByName(GetListField(SubType)).AsString +
          ' (' + FieldByName(GetKeyField(SubType)).AsString + ')');
    end;

    RUID := GetRUID;

    CDS := TClientDataSet.Create(nil);
    try
      for I := 0 to Obj.FieldDefs.Count - 1 do
      begin
        FD := Obj.FieldDefs[I];
        if (not (DB.faReadOnly in FD.Attributes))
          and (not FD.InternalCalcField)
          and (FD.Name <> 'AFULL')
          and (FD.Name <> 'ACHAG')
          and (FD.Name <> 'AVIEW') then
        begin
          //��������� �������� - false, �.�. ��������� �������� � ����������� ������ ������
          //Interbase ��������� ������ ������ � null,
          //� ClientDataset - ���
          CDS.FieldDefs.Add(FD.Name, FD.DataType, FD.Size, False);
        end;
      end;

      CDS.FieldDefs.Add('_XID', ftInteger, 0, True);
      CDS.FieldDefs.Add('_DBID', ftInteger, 0, True);
      CDS.FieldDefs.Add('_MODIFIED', ftDateTime, 0, True);
      CDS.FieldDefs.Add('_SETTABLE', ftString, 60, False);

      CDS.CreateDataSet;

      CDS.Insert;
      try
        for K := 0 to Obj.FieldCount - 1 do
        begin
          F := CDS.FindField(Obj.Fields[K].FieldName);
          if F <> nil then
          begin
            if (not FReadUserFromStream and (AnsiPos(';' + F.FieldName + ';', NotSavedField) > 0)) or
               (FReadUserFromStream and (AnsiPos(';' + F.FieldName + ';', NotSavedFieldRepl) > 0))
            then
              F.Clear
            else
              F.Assign(Obj.Fields[K]);
          end;
        end;
        CDS.FieldByName('_XID').AsInteger := RUID.XID;
        CDS.FieldByName('_DBID').AsInteger := RUID.DBID;
        CDS.FieldByName('_MODIFIED').AsDateTime := EditionDate;
        CDS.FieldByName('_SETTABLE').AsString := SetTable;
        CDS.Post;
      except
        if CDS.State in dsEditModes then
          CDS.Cancel;
        raise;
      end;


      // ������� ����� ������, ����� ����� ����� �� ��
      // ��� ��������� ��� ����������
      I := cst_StreamLabel;
      Stream.Write(I, SizeOf(I));

      //��������� 08.10.02 ������ ������ ������
      Stream.WriteBuffer(cst_WithVersion[1], Length(cst_WithVersion));
      CurStrVersion := cst_StreamVersion;
      Stream.Write(CurStrVersion, sizeof(CurStrVersion));
      //��������� 08.10.02 ������ id ��
      //������ ������ �� ���� 1
      CurDBID := IBLogin.DBID;
      Stream.Write(CurDBID, SizeOf(CurDBID));

      StreamWriteString(Stream, Obj.ClassName);
      StreamWriteString(Stream, Obj.SubType);

      //������ ������ �� ���� 2
      PrSets := TgdcPropertySet.Create(RUIDToStr(Obj.GetRUID),
        CgdcBase(Obj.ClassType), Obj.SubType);
      PrList := TStringList.Create;
      try
        PrList.CommaText := 'ModifyFromStream';
        for I := 0 to PrList.Count - 1 do
        begin
          PropInfo := GetPropInfo(Obj.ClassInfo, PrList[I]);
          if (PropInfo <> nil) then
          begin
            PrSets.Add(PrList[I], GetPropValue(Obj, PrList[I], False));
          end;
        end;
        PrSets.SaveToStream(Stream);
      finally
        PrSets.Free;
        PrList.Free;
      end;

      MS := TMemoryStream.Create;
      try
        try
          CDS.SaveToStream(MS);
        except
          MessageBox(0,
            '� �������� ���������� � ����� �������� ������. ������������� ���������.',
            '��������',
            MB_OK or MB_ICONHAND or MB_TASKMODAL);
          Abort;
        end;
        I := MS.Size;
        Stream.Write(I, SizeOf(I));
        Stream.CopyFrom(MS, 0);
      finally
        MS.Free;
      end;
    finally
      CDS.Free;
    end;
  end;

var
  I, J: Integer;
  Obj: TgdcBase;
  ObjectIDIndex: Integer;
  BaseClassList: TStringList;
  DidCreate: Boolean;
  //���� ��� �����-������
  CL: TStringList;
  CrossDS: TDataSource;
  //���� ��� ������, ����������� � �������
  LT: TStrings;
  TreeDependentNames: TLBRBTreeMetaNames;
  BaseTableTriggersName: TBaseTableTriggersName;
begin
  CheckBrowseMode;

  Assert(IBLogin <> nil);
  Assert(atDatabase <> nil);

  if ObjectSet = nil then
  begin
    ObjectSet := TgdcObjectSet.Create(TgdcBase, '');
    ObjectSetCreated := True;
  end else
    ObjectSetCreated := False;

  ReversedList := TgdcObjectSets.Create;

  try
    // ���� ������ � �������� �� ��� �������� � ������,
    // �� �������, ������ �� �����
    if (SetTable > '') and (ObjectSet.Find(ID) > -1) then
    begin
      //���� ���� ������ �� ��� ���������, �� �� ��������� ������ ���������, ��������� � ���
      // ���� ������� ������ ������������ ������ �������
      // ������, �� �������� ��������� � ������� ��� �����
      // ���������� � ������

      C := GetCurrRecordClass;

      if (Self.ClassType <> C.gdClass) or (Self.SubType <> C.SubType) then
      begin
        try
          Obj := C.gdClass.CreateSingularByID(nil,
            Database, Transaction, ID, C.SubType);
          try
            if (SetTable > '') and Assigned(MasterSource) then
            begin
              Obj.Close;
              Obj.SetTable := SetTable;
              Obj.MasterSource := MasterSource;
              //��������� ���� ������ ������� � �� ���������, ������� ����� Self
              //������ ���� �������� ����� Self.ModifyFromStream ���������� �� �������� ���������������� �� ���������
              // (�� �����-�������)
              Obj.Open;
            end;
            if Self.ModifyFromStream <> Self.NeedModifyFromStream(Self.SubType) then
            begin
              Obj.ModifyFromStream := Self.ModifyFromStream;
            end;
            Obj.StreamSilentProcessing := Self.StreamSilentProcessing;
            Obj.StreamProcessingAnswer := Self.StreamProcessingAnswer;
            Obj.FReadUserFromStream := Self.FReadUserFromStream;
            Obj._SaveToStream(Stream, ObjectSet, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
          finally
            Obj.Free;
          end;
        except
          on E: Exception do
          begin
            if (not Self.StreamSilentProcessing) and (not (E is EAbort)) then
              MessageBox(ParentHandle,
                PChar(Format('�������� ����������� ������. '#13#10# +
                '�������������� ���������� � ���� �������'#13#10# +
                'c ��������������� %d: %s (������: "%s")'#13#10# +
                '�� ������������� ����������������.'#13#10#13#10 +
                '������ �� ����� ��������.', [ID, C.gdClass.ClassName, C.SubType])),
                '������',
                MB_OK or MB_ICONEXCLAMATION);

            AddWarning(E.Message, clRed);
          end;
        end;
      end else
      begin
        {����� ����� ����������� �� �������-��������� � �������� ������}
        if not (Assigned(BindedList) and
          BindedList.FindgdClassByID(ID, ClassName, SubType, SetTable)) then
        begin
          DidCreate := not Assigned(BindedList);
          if DidCreate then
            BindedList := TgdcObjectSet.Create(nil, '');
          try
            BindedList.Add(ID, ClassName, SubType, SetTable);
            SaveBindedObjectsForTable(SetTable, ReversedList);
          finally
            if DidCreate and Assigned(BindedList) then
              FreeAndNil(BindedList);
          end;
        end;

        ObjectSet.Add(ID, ClassName, SubType, SetTable);
        SaveToStreamCLDS(Self);
      end;
      exit;
    end
    else if ObjectSet.Find(ID) > -1 then
      exit;

    {������� �������� ��� ������� �� ����������� ������}
    if Assigned(PropertyList) then
    begin
      PropertyListIndex := PropertyList.IndexOf(RUIDToStr(Self.GetRUID));
      if PropertyListIndex > -1 then
        for I := 0 to PropertyList.Objects[PropertyListIndex].Count - 1 do
        begin
          PropInfo := GetPropInfo(Self.ClassInfo,
            PropertyList.Objects[PropertyListIndex].Name[I]);
          if (PropInfo <> nil) then
          begin
            SetPropValue(Self, PropertyList.Objects[PropertyListIndex].Name[I],
              PropertyList.Objects[PropertyListIndex].Value[
                PropertyList.Objects[PropertyListIndex].Name[I]]);
          end;
        end;
    end;

    LinkTableList := TStringList.Create;
    BaseClassList := TStringList.Create;
    BaseClassList.Sorted := True;

    ibsql := CreateReadIBSQL;

    try
      // ���� ������� ������ ������������ ������ �������
      // ������, �� �������� ��������� � ������� ��� �����
      // ���������� � ������
      C := GetCurrRecordClass;

      if (Self.ClassType <> C.gdClass) or (Self.SubType <> C.SubType) then
      begin
        try
          Obj := C.gdClass.CreateSingularByID(nil,
            Database, Transaction, ID, C.SubType);
          try
            if (SetTable > '') and Assigned(MasterSource) then
            begin
              Obj.Close;
              Obj.SetTable := SetTable;
              Obj.MasterSource := MasterSource;
              //��������� ���� ������ ������� � �� ���������, ������� ����� Self
              //������ ���� �������� ����� Self.ModifyFromStream ���������� �� �������� ���������������� �� ���������
              // (�� �����-�������)
              Obj.Open;
            end;
            if Self.ModifyFromStream <> Self.NeedModifyFromStream(Self.SubType) then
            begin
              Obj.ModifyFromStream := Self.ModifyFromStream;
            end;
            Obj.StreamSilentProcessing := Self.StreamSilentProcessing;
            Obj.StreamProcessingAnswer := Self.StreamProcessingAnswer;
            Obj.FReadUserFromStream := Self.FReadUserFromStream;
            Obj._SaveToStream(Stream, ObjectSet, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
          finally
            Obj.Free;
          end;
        except
          on E: Exception do
          begin
            if (not Self.StreamSilentProcessing) and (not (E is EAbort)) then
              MessageBox(ParentHandle,
                PChar(Format('�������� ����������� ������. '#13#10# +
                '�������������� ���������� � ���� �������'#13#10# +
                'c ��������������� %d: %s (������: "%s")'#13#10# +
                '�� ������������� ����������������.'#13#10#13#10 +
                '������ �� ����� ��������.', [ID, C.gdClass.ClassName, C.SubType])),
                '������',
                MB_OK or MB_ICONEXCLAMATION);

            AddWarning(E.Message, clRed);
          end;
        end;
      end else
      begin
        {$IFDEF DEBUG}
        OutputDebugString(PChar(ClassName + ' ' + FormatDateTime('hh:nn:ss.zzz', Now)));
        {$ENDIF}

        if not (Assigned(BindedList) and
          BindedList.FindgdClassByID(ID, ClassName, SubType, SetTable)) then
        begin
          // �������� ��� ������� �� ������� ���� ������ ��
          // ������� ������� �������� �������, �� ������ ����������� � �������
          // � ��������� � ������� ���� � ������ � �� SetTable
          DidCreate := not Assigned(BindedList);
          if DidCreate then
            BindedList := TgdcObjectSet.Create(nil, '');
          LT := TStringList.Create;
          try
            (LT as TStringList).Duplicates := dupIgnore;
            {������� ��� �������, �������� � ������}
            GetTablesName(SelectSQL.Text, LT);

            LinkTableList.Clear;
            LinkTableList.Add(GetListTable(SubType));
            {������� ������ �������, ������� ����� ���� � ������ � ������� �������
             � ���������������� ������� ������}
             { TODO -oJulia :
� ��������� ����� ���� ��������: GetBaseClassForRelation ����� ������� ������������ �������
�� ������� ����� �� ����������, ���������, ��� id �������� � �������� ���� }
            for I := 0 to LT.Count - 1 do
            begin
              if LinkTableList.IndexOf(LT[I]) = -1 then
              begin
                if Self.ClassType.InheritsFrom(GetBaseClassForRelation(LT[I]).gdClass) then
                  LinkTableList.Add(LT[I]);
              end;
            end;

            BindedList.Add(ID, ClassName, SubType, SetTable);

            for I := 0 to LinkTableList.Count - 1 do
              SaveBindedObjectsForTable(LinkTableList[I], ReversedList);

            if SetTable > '' then
              SaveBindedObjectsForTable(SetTable, ReversedList);
          finally
            LT.Free;
            if DidCreate and Assigned(BindedList) then
              FreeAndNil(BindedList);
          end;
        end;

        // ��� ��������� ������������ ���������� �������
        // ��� �� ������ ��������� ������ � ������� ���������������
        if ObjectSet.FindgdClassByID(ID, ClassName, SubType, SetTable) then
          exit;

        ObjectIDIndex := ObjectSet.Add(ID, ClassName, SubType, SetTable);

        //�������� ���� ������� � �����
        SaveToStreamCLDS(Self);
        //��� �������� ��� ��������� ��� ������, ���������� ���� ��������� ������  �������� ����� � �������
        if SetTable > '' then Exit;

        LinkTableList.Clear;
        // ������ ������ ��� �������, ��������� ���� ������� ������������
        // �������� ������� �� ���� ������, �.�. ������� ���������
        // ������� ������ ����-�-������ � ����� ��������
        // ������ � ����� ��������, � ������������ � ������� � �������
        // �������, ������������ ������ ������ �������
        // ������: gd_contact -- gd_company -- gd_companycode
        OL := TObjectList.Create(False);
        try
          atDatabase.ForeignKeys.ConstraintsByReferencedRelation(
            GetListTable(SubType), OL);
          for I := 0 to OL.Count - 1 do
            with OL[I] as TatForeignKey do
          begin
            if IsSimpleKey
              and (Relation.PrimaryKey <> nil)
              and (Relation.PrimaryKey.ConstraintFields.Count = 1)
              and (ConstraintField = Relation.PrimaryKey.ConstraintFields[0])
              {!!!! ��� gd_document ����� ������ ������ ������� 1:1 � ��������� ������ ID ��� ��������}
              and (((AnsiCompareText(GetListTable(SubType), 'GD_DOCUMENT') = 0) and
                    (AnsiCompareText(Relation.PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0)
                   ) or
                   (AnsiCompareText(GetListTable(SubType), 'GD_DOCUMENT') <> 0)
                  )
            then
            begin
              LinkTableList.Add(Relation.RelationName);
              SaveBindedObjectsForTable(Relation.RelationName, ReversedList);
            end;
          end;
        finally
          OL.Free;
        end;

        Obj := nil;
        C := GetBaseClassForRelation(GetListTable(GetSubType));
        BaseClassList.Clear;
        BaseClassList.Add(C.gdClass.ClassName + '(' + C.SubType + ')');
        try
          for I := 0 to LinkTableList.Count - 1 do
          begin
            //���� ����� ������, ������� ��������� �� ��� ������ ���� � ������
            //���� ���������������� �������, �� �� ������ �������� ��������
            //����� ���������� ���������� �������� - �� ���� ID - ��������� ��������:
            //�������� (������� ������) � �������
            //� �������� �����, ������� ��������� �� �������� ������
            C := GetBaseClassForRelationByID(LinkTableList[I], ID, Self.Transaction);

            if Assigned(C.gdClass) and
              (BaseClassList.IndexOf(C.gdClass.ClassName + '(' + C.SubType + ')') = -1)
            then
            begin
              BaseClassList.Add(C.gdClass.ClassName + '(' + C.SubType + ')');
              if (Obj = nil) or (Obj.ClassType <> C.gdClass) or (Obj.SubType <> C.SubType) then
              begin
                if Assigned(Obj) then
                  FreeAndNil(Obj);
                Obj := C.gdClass.CreateSubType(nil, C.SubType, 'ByID');
              end;
              Obj.Close;
              Obj.Transaction := Transaction;
              Obj.ID := ID;
              //��������� ���� ������ ������� � �� ���������, ������� ����� Self
              Obj.ModifyFromStream := Self.ModifyFromStream;
              Obj.Open;
              if Obj.RecordCount > 0 then
              begin
                C := Obj.GetCurrRecordClass;

                while Assigned(C.gdClass) and ((Obj.ClassType <> C.gdClass) or (Obj.SubType <> C.SubType)) do
                begin
                  FreeAndNil(Obj);
                  Obj := C.gdClass.CreateSubType(nil, C.SubType, 'ByID');
                  Obj.Transaction := Transaction;
                  Obj.ID := ID;
                  Obj.Open;
                  C := Obj.GetCurrRecordClass;
                end;

                if Assigned(C.gdClass) and
                  (not ObjectSet.FindgdClass(ObjectIDIndex, C.gdClass.ClassName, C.SubType, '')) then
                begin
                  if Obj.RecordCount > 0 then
                  begin
                    AddText('����������: ' + Obj.GetDisplayName(Obj.GetSubType) + ' ' +
                      Obj.FieldByName(Obj.GetListField(Obj.SubType)).AsString +
                      ' (' + Obj.FieldByName(Obj.GetKeyField(Obj.SubType)).AsString + ')',
                      clBlue);
                    if Assigned(frmStreamSaver) then
                      frmStreamSaver.SetProcessText(Obj.GetDisplayName(Obj.GetSubType) + ' ' +
                        Obj.FieldByName(Obj.GetListField(Obj.SubType)).AsString +
                        ' (' + Obj.FieldByName(Obj.GetKeyField(Obj.SubType)).AsString + ')');
                    SaveToStreamCLDS(Obj);
                    ObjectIDIndex := ObjectSet.Add(Obj.ID, Obj.ClassName, Obj.SubType, Obj.SetTable);
                  end;
                end;
              end;
            end;
          end;
        finally
          if Assigned(Obj) then
            FreeAndNil(Obj);
        end;

        for I := 0 to ReversedList.Count - 1 do
        begin
          for J := 0 to (ReversedList[I] as TgdcObjectSet).Count - 1 do
          begin
            Obj := (ReversedList[I] as TgdcObjectSet).gdClass.CreateSingularByID(nil,
              Database, Transaction,
              (ReversedList[I] as TgdcObjectSet).Items[J],
              (ReversedList[I] as TgdcObjectSet).SubType);
            try
              //��������� ���� ������ ������� � �� ���������, ������� ����� Self
              //������ ���� �������� ����� Self.ModifyFromStream ���������� �� �������� ���������������� �� ���������
              // (�� �����-�������)
              if Self.ModifyFromStream <> Self.NeedModifyFromStream(Self.SubType) then
              begin
                Obj.ModifyFromStream := Self.ModifyFromStream;
              end;
              Obj.StreamSilentProcessing := Self.StreamSilentProcessing;
              Obj.StreamProcessingAnswer := Self.StreamProcessingAnswer;
              Obj.FReadUserFromStream := Self.FReadUserFromStream;
              Obj._SaveToStream(Stream, ObjectSet, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
            finally
              Obj.Free;
            end;
          end;
        end;

        // ������ ���� ��������� ��� ��������� �������
        // ��������� ������ �� ������� ��������� �������:
        // 1. ������ ������ ������ ������, ����������� �� ���� �������
        // !!!!! � �� ��������� � ��� �������
        // 2. �� ������ ����� ������ �� �����, ������� ������� ��
        //    ������ ���� � ��� ������ �������
        //    DMASTERKEY
        // 3. ������� ������� ������ ��� ������, ��� �������
        //    ������� ��� �����
        // 4. ������� ���������� �������� �� ��������� �������
        // 5. ������������� �������������� �������: ������ ��
        //    ������ ������
        // 6. ��������� ������� � ����������� ��������
        // 7. ��������� ��� ��� ������ � ������

        {��������� ���� �� ������������� ���� "� ����������",
        ���� �� ���������� ������� � ������ ��������, ������� ����� ��������� � ����������
        ������ ������ ����������� ����� ����������� ��������� ������������ ��������.
        � ������� ���������� ����� ������ ������� "��������� � ����������".
        ������ ���� �� ������ �� ������, ���� ������� ��-��������� ����. ������� ��������� ��� �������� ����� ������}
        if SaveDetailObjects or (Assigned(WithDetailList) and (WithDetailList.IndexOf(ID) > -1)) then
        begin
          DL := TObjectList.Create(False);
          try
            atDatabase.ForeignKeys.ConstraintsByReferencedRelation(
              GetListTable(SubType), DL, True);

            // ��� �������� �� ����� ��������� ��������� ����������
            if Self is TgdcLBRBTreeTable then
              GetLBRBTreeDependentNames(Self.FieldByName('relationname').AsString, ReadTransaction, TreeDependentNames);

            if (Self is TgdcPrimeTable) or (Self is TgdcTableToTable) then
              GetBaseTableTriggersName(Self.FieldByName('relationname').AsString, ReadTransaction, BaseTableTriggersName, True);
            if (Self is TgdcSimpleTable) or (Self is TgdcTreeTable) then
              GetBaseTableTriggersName(Self.FieldByName('relationname').AsString, ReadTransaction, BaseTableTriggersName);
            //������� ��� ����� �� �������� ����������� � ����� 1:1
            //� ������� �������
            for I := 0 to LinkTableList.Count - 1 do
              atDatabase.ForeignKeys.ConstraintsByReferencedRelation(
                LinkTableList[I], DL, False);

            for I := 0 to DL.Count - 1 do
            begin
              if TatForeignKey(DL[I]).IsSimpleKey and
                (TatForeignKey(DL[I]).ConstraintField.Field.FieldName = 'DMASTERKEY') then
              begin
                if (TatForeignKey(DL[I]).Relation.RelationName = 'AC_ENTRY') or
                   (TatForeignKey(DL[I]).Relation.RelationName = 'AC_RECORD') then
                  continue;  
                if not Assigned(TatForeignKey(DL[I]).Relation.PrimaryKey) then
                  raise EgdcIBError.Create('������ ��� ��������� ����� ������-������: ' +
                    ' � ������� ' + TatForeignKey(DL[I]).Relation.LName + ' ����������� ��������� ����! ');

                ibsql.Close;
                //�� �� ��������� ���� ������� �� �������
                //��������� ����, �.�. � ������ ����� �������
                //������ ����� �������
                ibsql.SQL.Text := Format('SELECT %s FROM %s WHERE %s = %s ',
                  [TatForeignKey(DL[I]).Relation.PrimaryKey.ConstraintFields[0].FieldName,
                  TatForeignKey(DL[I]).Relation.RelationName,
                  TatForeignKey(DL[I]).ConstraintField.FieldName,
                  FieldByName(GetKeyField(SubType)).AsString]);
                ibsql.ExecQuery;
                if ibsql.RecordCount > 0 then
                begin
                  //������� ������� ����� �� ������� id, �.�. ��������� ������� � ����� ������� ����� ������ ������ � ��������
                  C := GetBaseClassForRelationByID(TatForeignKey(DL[I]).Relation.RelationName,
                    ibsql.Fields[0].AsInteger, Self.Transaction);
                  if C.gdClass <> nil then
                  begin
                    //������� ��� ��������� � ����� �������
                    Obj := C.gdClass.CreateSubType(nil, C.SubType, 'ByID');
                    try
                      Obj.Transaction := Transaction;
                      while not ibsql.Eof do
                      begin
                        Obj.ID := ibsql.Fields[0].AsInteger;
                        //��������� ���� ������ ������� � �� ���������, ������� ����� Self
                        //������ ���� �������� ����� Self.ModifyFromStream ���������� �� �������� ���������������� �� ���������
                        // (�� �����-�������)
                        if Self.ModifyFromStream <> Self.NeedModifyFromStream(Self.SubType) then
                        begin
                          Obj.ModifyFromStream := Self.ModifyFromStream;
                        end;
                        Obj.Open;

                        // ��� �������� �� ����� ��������� ��������� ����������
                        if Self is TgdcLBRBTreeTable then
                        begin
                          if Obj is TgdcTrigger then
                          begin
                            if (AnsiCompareText(Trim(Obj.FieldByName('rdb$trigger_name').AsString), TreeDependentNames.BITriggerName) = 0)
                               or (AnsiCompareText(Trim(Obj.FieldByName('rdb$trigger_name').AsString), TreeDependentNames.BUTriggerName) = 0)
                               or (AnsiCompareText(Trim(Obj.FieldByName('rdb$trigger_name').AsString), TreeDependentNames.BI5TriggerName) = 0)
                               or (AnsiCompareText(Trim(Obj.FieldByName('rdb$trigger_name').AsString), TreeDependentNames.BU5TriggerName) = 0) then
                            begin
                              ibsql.Next;
                              Continue;
                            end;
                          end
                          else
                           if Obj is TgdcIndex then
                           begin
                             if (AnsiCompareText(Trim(Obj.FieldByName('RDB$INDEX_NAME').AsString), TreeDependentNames.LBIndexName) = 0)
                               or (AnsiCompareText(Trim(Obj.FieldByName('RDB$INDEX_NAME').AsString), TreeDependentNames.RBIndexName) = 0) then
                             begin
                               ibsql.Next;
                               Continue;
                             end;
                           end;
                        end;

                        if (Self is TgdcSimpleTable) or (Self is TgdcTreeTable)
                          or (Self is TgdcPrimeTable) or (Self is TgdcTableToTable) then
                        begin
                          if Obj is TgdcTrigger then
                          begin
                            if (AnsiCompareText(Trim(Obj.FieldByName('rdb$trigger_name').AsString), BaseTableTriggersName.BITriggerName) = 0)
                              or (AnsiCompareText(Trim(Obj.FieldByName('rdb$trigger_name').AsString), BaseTableTriggersName.BI5TriggerName) = 0)
                              or (AnsiCompareText(Trim(Obj.FieldByName('rdb$trigger_name').AsString), BaseTableTriggersName.BU5TriggerName) = 0)
                              or (StrIPos(';' + Trim(Obj.FieldByName('rdb$trigger_name').AsString) + ';', ';' + BaseTableTriggersName.CrossTriggerName) <> 0) then
                            begin
                              ibsql.Next;
                              Continue;
                            end;
                          end;
                        end;

                        if (Self is TgdcSimpleTable)
                          or (Self is TgdcTreeTable)
                          or (Self is TgdcLBRBTreeTable)
                          or (Self is TgdcPrimeTable)
                          or (Self is TgdcTableToTable) then
                        begin
                          if Obj is TgdcRelationField then
                          begin
                            if (AnsiCompareText(Trim(Obj.FieldByName('fieldname').AsString), 'ID') = 0)
                              or (AnsiCompareText(Trim(Obj.FieldByName('fieldname').AsString), 'PARENT') = 0)
                              or (AnsiCompareText(Trim(Obj.FieldByName('fieldname').AsString), 'LB') = 0)
                              or (AnsiCompareText(Trim(Obj.FieldByName('fieldname').AsString), 'RB') = 0)
                              or (AnsiCompareText(Trim(Obj.FieldByName('fieldname').AsString), 'EDITIONDATE') = 0)
                              or (AnsiCompareText(Trim(Obj.FieldByName('fieldname').AsString), 'EDITORKEY') = 0)
                              or (AnsiCompareText(Trim(Obj.FieldByName('fieldname').AsString), 'DISABLED') = 0)
                              or (AnsiCompareText(Trim(Obj.FieldByName('fieldname').AsString), 'RESERVED') = 0) then
                            begin
                              ibsql.Next;
                              Continue;
                            end;
                          end;
                        end;

                        if not Obj.EOF then
                        begin
                          if (not (Obj is TgdcMetaBase)) or (not TgdcMetaBase(Obj).IsDerivedObject) then
                          begin
                            Obj._SaveToStream(Stream, ObjectSet, PropertyList, BindedList,
                              WithDetailList,
                              SaveDetailObjects);
                          end;    
                        end;
                        ibsql.Next;
                      end;
                    finally
                      Obj.Free;
                    end;
                  end;
                end;
              end;
            end;
          finally
            DL.Free;
          end;
        end;

        //������� ������� ������� � ������
        LinkTableList.Add(GetListTable(SubType));
        {���� � ��� ���� ����-���������, �� �������� ���������� �� ��������}
        CL := TStringList.Create;
        CrossDS := TDataSource.Create(nil);
        try
          CrossDS.DataSet := Self;
          atDataBase.GetCrossByRelationName(LinkTableList, CL);
          for I := 0 to CL.Count - 1 do
          begin
            if StrIPos('GD_LASTNUMBER', CL.Names[I]) = 1 then
              continue;

            if StrIPos('FLT_LASTFILTER', CL.Names[I]) = 1 then
              continue;

            //������� ������� �����
            C := GetBaseClassForRelation(CL.Values[CL.Names[I]]);
            if C.gdClass <> nil then
            begin
              //������� ��� ��������� � �������� ����������
              Obj := C.gdClass.CreateSubType(nil, C.SubType, '');
              try
                Obj.Transaction := Transaction;
                Obj.SetTable := CL.Names[I];
                Obj.MasterSource := CrossDS;
                //��������� ���� ������ ������� � �� ���������, ������� ����� Self
                //������ ���� �������� ����� Self.ModifyFromStream ���������� �� �������� ���������������� �� ���������
                // (�� �����-�������)
                if Self.ModifyFromStream <> Self.NeedModifyFromStream(Self.SubType) then
                begin
                  Obj.ModifyFromStream := Self.ModifyFromStream;
                end;
                Obj.StreamSilentProcessing := Self.StreamSilentProcessing;
                Obj.StreamProcessingAnswer := Self.StreamProcessingAnswer;
                Obj.FReadUserFromStream := Self.FReadUserFromStream;
                Obj.Open;
                while not Obj.Eof do
                begin
                  //��� ���������
                  Obj._SaveToStream(Stream, ObjectSet, PropertyList, BindedList, WithDetailList, False);
                  Obj.Next;
                end;
              finally
                Obj.Free;
              end;
            end;

          end;
        finally
          CL.Free;
          CrossDS.Free;
        end;

      end;
    finally
      LinkTableList.Free;
      BaseClassList.Free;
      ibsql.Free;
    end;
  finally
    ReversedList.Free;
    if ObjectSetCreated then
      ObjectSet.Free;
  end;
end;

procedure TgdcBase.SetDetailField(const Value: String);
begin
  if FgdcDataLink <> nil then
    FgdcDataLink.DetailField := Value;
end;

procedure TgdcBase.SetID(const Value: Integer);
begin
  Assert(Value >= -1, 'Invalid id specified');
  if Value = -1 then
  begin
    Close;
    FID := -1;
  end else
  begin
    if State in dsEditModes then
    begin
      FieldByName(GetKeyField(SubType)).AsInteger := Value;
    end
    else if State = dsInactive then
    begin
      FID := Value;
    end
    else if HasSubSet('ByID') then
    begin
      Close;
      FID := Value;
      Open;
    end else
      if not Locate(GetKeyField(SubType), Value, []) then
        raise EgdcException.CreateObj('Invalid id specified', Self);
  end;
end;

procedure TgdcBase.SetMasterField(const Value: String);
begin
  if FgdcDataLink <> nil then
    FgdcDataLink.MasterField := Value;
end;

procedure TgdcBase.SetMasterSource(Value: TDataSource);
var
  isActive: Boolean;
begin
  if IsLinkedTo(Value) then
    IBError(ibxeCircularReference, [nil]);

  if (FgdcDataLink <> nil) and (MasterSource <> Value) then
  begin
    if FgdcDataLink.DataSet is TgdcBase then
      (FgdcDataLink.DataSet as TgdcBase).RemoveDetailLink(Self);

    FgdcDataLink.DataSource := Value;
    FgdcDataLink.FLinkEstablished := False;

    if Assigned(MasterSource) and (MasterSource.DataSet is TIBCustomDataSet) then
    begin
      if not FIsInternalMasterSource then
      begin
        Transaction := (MasterSource.DataSet as TIBCustomDataSet).Transaction;
        if Assigned(Transaction) and Transaction.InTransaction then
          ReadTransaction := Transaction
        else
          ReadTransaction := (MasterSource.DataSet as TIBCustomDataSet).ReadTransaction;
      end;    
    end else
    begin
      { TODO :
����� ���� ������ �� ������� ������ ��� ������������
MasterSource = nil? �� ������� �� ����������, �� ���������
�������. }
      if (not (State in dsEditModes))
        and (not (csDestroying in ComponentState)) then
      begin
        isActive := Active;
        Close;
        Transaction := FInternalTransaction;
        if Assigned(gdcBaseManager) then
          ReadTransaction := gdcBaseManager.ReadTransaction
        else
          ReadTransaction := nil;
        Active := isActive;
      end;
    end;

    if FgdcDataLink.DataSet is TgdcBase then
      (FgdcDataLink.DataSet as TgdcBase).AddDetailLink(Self);
  end;
end;

{ TgdcDataLink }

procedure TgdcDataLink.ActiveChanged;
begin
  //FTimer.Enabled := False;
  if DataSet = nil then
    FLinkEstablished := False
  else if (FMasterField.Count > 0) and (FDetailField.Count > 0)
    and (FDetailObject <> nil) then
  begin
    if not DataSet.Active then
    begin
      FDetailObject.Close;
    end else begin
      if not FLinkEstablished then
      begin
        if (DataSet is TIBCustomDataSet) then
        begin
          if (FDetailObject.Transaction = nil) or (FDetailObject.Transaction = FDetailObject.FInternalTransaction) then
          begin
            { TODO : �� ������ �� ���, ���� ���� �� ������ � �������� ���������? }
            FDetailObject.Close;
            FDetailObject.Transaction := (DataSet as TIBCustomDataSet).Transaction;
          end;

          if (FDetailObject.ReadTransaction = nil)
            or (FDetailObject.ReadTransaction <> (DataSet as TIBCustomDataSet).ReadTransaction)
            or ((DataSet as TIBCustomDataSet).Transaction.InTransaction) then
          begin
            { TODO : �� ������ �� ���, ���� ���� �� ������ � �������� ���������? }
            FDetailObject.Close;
            if (DataSet as TIBCustomDataSet).Transaction.InTransaction then
              FDetailObject.ReadTransaction := (DataSet as TIBCustomDataSet).Transaction
            else
              FDetailObject.ReadTransaction := (DataSet as TIBCustomDataSet).ReadTransaction;
          end;
        end;

        if DataSet is TgdcBase then
          (DataSet as TgdcBase).AddDetailLink(FDetailObject);

        FLinkEstablished := True;
      end;

      if FDetailObject.Active then
        FDetailObject.RefreshParams
      else
        FDetailObject.Open;
    end;
  end;
end;

constructor TgdcDataLink.Create(ADetailObject: TgdcBase);
begin
  inherited Create;
  FDetailObject := ADetailObject;
  FMasterField := TStringList.Create;
  FDetailField := TStringList.Create;
  FLinkEstablished := False;
end;

destructor TgdcDataLink.Destroy;
begin
  //FTimer.Free;
  if FDetailObject <> nil then
  begin
    if DataSet is TgdcBase then
      (DataSet as TgdcBase).RemoveDetailLink(FDetailObject);
    FDetailObject.FgdcDataLink := nil;
  end;  
  FMasterField.Free;
  FDetailField.Free;
  inherited;
end;

procedure TgdcDataLink.EditingChanged;
begin
  if (DataSet <> nil) and (DataSet.State in dsEditModes) then
  begin
    if (FDetailObject <> nil) and (FDetailObject.State in dsEditModes) then
    begin
      if (DataSet as TgdcBase).FIgnoreDataSet.IndexOf(FDetailObject) = -1 then
        FDetailObject.Post;
    end;
  end;
end;

function TgdcDataLink.GetDetailField: String;
begin
  Result := StringReplace(FDetailField.CommaText, ',', ';', [rfReplaceAll]);
end;

function TgdcDataLink.GetMasterField: String;
begin
  Result := StringReplace(FMasterField.CommaText, ',', ';', [rfReplaceAll]);
end;

procedure TgdcDataLink.RecordChanged(F: TField);
begin
  if (F = nil) and Assigned(FDetailObject) and FDetailObject.Active then
  begin
    if DataSet is TgdcBase then
    begin
      if (DataSet as TgdcBase).FIgnoreDataSet.IndexOf(FDetailObject) = -1 then
        FDetailObject.RefreshParams;
    end else
      FDetailObject.RefreshParams;
  end;
end;

procedure TgdcDataLink.SetDetailField(const Value: String);
begin
  FDetailField.CommaText := StringReplace(Value, ';', ',', [rfReplaceAll]);
end;

procedure TgdcDataLink.SetMasterField(const Value: String);
begin
  FMasterField.CommaText := StringReplace(Value, ';', ',', [rfReplaceAll]);
end;

{ TgdcBaseManager }

function TgdcBaseManager.AdjustMetaName(const S: AnsiString;
  const MaxLength: Integer): AnsiString;
var
  Tmp, S1: AnsiString;
begin
  S1 := AnsiUpperCase(S);

  if Length(S1) <= MaxLength then
    Result := S1
  else begin
    Tmp := IntToStr(Crc32_P(@S1[1], Length(S1), 0));
    Result := Copy(S1, 1, MaxLength - Length(Tmp)) + Tmp;
  end;
end;

function TgdcBaseManager.GetRUIDRecByXID(const XID, DBID: TID;
  Transaction: TIBTransaction): TRUIDRec;
begin
  if (XID < cstUserIDStart) and (DBID = cstEtalonDBID) then
  begin
    Result.ID := XID;
    Result.XID := XID;
    Result.DBID := DBID;
    Result.Modified := 0;
    Result.EditorKey := -1;
  end else
  begin
    FIBSQL.Close;
    try
      if Assigned(Transaction) and Transaction.InTransaction then
        FIBSQL.Transaction := Transaction
      else
        FIBSQL.Transaction := ReadTransaction;

      FIBSQL.SQL.Text := cst_sql_SelectRUIDBYXID;
      FIBSQL.ParamByName(fnXID).AsInteger := XID;
      FIBSQL.ParamByName(fnDBID).AsInteger := DBID;
      FIBSQL.ExecQuery;

      if FIBSQL.EOF then
      begin
        Result.ID := -1;
        Result.Modified := 0;
        Result.EditorKey := -1;
      end else
      begin
        Result.ID := FIBSQL.FieldByName(fnId).AsInteger;
        Result.Modified := FIBSQL.FieldByName(fnModified).AsDateTime;
        Result.EditorKey := FIBSQL.FieldByName(fnEditorkey).AsInteger;
      end;
      
      Result.XID := XID;
      Result.DBID := DBID;
    finally
      FIBSQL.Close;
    end;
  end;
end;

constructor TgdcBaseManager.Create(AnOwner: TComponent);
begin
  Assert(gdcBaseManager = nil, 'Only one instance of gdcBaseManager is allowed');
  inherited Create(AnOwner);
  FIBBase := TIBBase.Create(Self);
  FReadTransaction := TIBTransaction.Create(nil);
  FReadTransaction.Params.Text := 'read_committed'#13#10'rec_version'#13#10'nowait'#13#10'read'#13#10;
  FReadTransaction.Name := 'InternalRead';
  FReadTransaction.AutoStopAction := saNone;
  gdcBaseManager := Self;
  FIBSQL := TIBSQL.Create(nil);
  FIDCurrent := 0;
  FIDLimit := -1;
end;

procedure TgdcBaseManager.DeleteRUIDByXID(const XID, DBID: TID;
  Transaction: TIBTransaction);
var
  DidActivate: Boolean;
  Tr: TIBTransaction;
  WasCreate: Boolean;
begin
  if Assigned(Transaction) then
  begin
    WasCreate := False;
    Tr := Transaction;
  end else
  begin
    WasCreate := True;
    Tr := TIBTransaction.Create(nil);
  end;
  try
    if WasCreate then
      Tr.DefaultDatabase := Self.Database;

    FIBSQL.Close;
    DidActivate := not Tr.InTransaction;
    try
      if DidActivate then Tr.StartTransaction;

      FIBSQL.Transaction := Tr;
      FIBSQL.SQL.Text := cst_sql_DeleteRUIDByXID;
      FIBSQL.ParamByName(fnXID).AsInteger := XID;
      FIBSQL.ParamByName(fnDBID).AsInteger := DBID;
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      if DidActivate and Tr.InTransaction then
        Tr.Commit;

      RemoveRUIDFromCache(XID, DBID);
    except
      if DidActivate and Tr.InTransaction then
        Tr.Rollback;
      raise;
    end;
  finally
    if WasCreate then
      Tr.Free;
  end;
end;

destructor TgdcBaseManager.Destroy;
begin
  gdcBaseManager := nil;
  if Assigned(FReadTransaction) and FReadTransaction.InTransaction then
    FReadTransaction.Commit;

  FIBSQL.Free;
  FreeAndNil(FReadTransaction);
  FreeAndNil(FIBBase);
  FNextIDSQL.Free;
  ClearSecDescArr;
  inherited;
end;

function TgdcBaseManager.GenerateNewDBID: TID;
var
  D: TDateTime;
begin
  D := Abs(Now - EncodeDate(2003, 08, 06));
  while D > 10 * 365 do
    D := D - (10 * 365) + 0.5;
  Result := Round(D * 24 * 60 * 60 * 6.8) + 2000;
end;

function TgdcBaseManager.GetDatabase: TIBDatabase;
begin
  if Assigned(FIBBase) then
    Result := FIBBase.Database
  else
    Result := nil;
end;

function TgdcBaseManager.GetExplorer: IgdcBase;
begin
  Result := FExplorer;
end;

function TgdcBaseManager.GetIDByRUID(const XID, DBID: TID; const Tr: TIBTransaction = nil): TID;
begin
  Result := GetIDByRUIDString(RUIDToStr(XID, DBID), Tr);
end;

function TgdcBaseManager.GetIDByRUIDString(const RUID: TRUIDString;
  const Tr: TIBTransaction = nil): TID;
var
  R: TRUID;
begin
  if RUID = '' then
  begin
    Result := -1;
    exit;
  end;

  if CacheList = nil then
    CacheList := TStringHashMap.Create(CaseSensitiveTraits, 1024);

  if Assigned(IBLogin) and (IBLogin.DBID <> CacheDBID) then
  begin
    CacheList.Clear;
    CacheDBID := IBLogin.DBID;
  end;

  if not CacheList.Find(RUID, Result) then
  begin
    R := StrToRUID(RUID);
    Result := GetRUIDRecByXID(R.XID, R.DBID, Tr).ID;
    if Result > -1 then
      CacheList.Add(RUID, Result)
    else
      //�������� ���� ��� �� ����� � �������
      if IBLogin.DBID = R.DBID then
        Result := R.XID;
  end;
end;

function TgdcBaseManager.GetNextID(const ResetCache: Boolean = False): TID;
begin
  if (FIDLimit < 0) or ResetCache then
    IDCacheInit;

  if FIDCurrent <= FIDLimit then
  begin
    Result := FIDCurrent;
  end else
  begin
    if FNextIDSQL = nil then
    begin
      if GetSystemMetrics(SM_REMOTESESSION) <> 0 then
        IDCacheStep := 1;

      FNextIDSQL := TIBSQL.Create(nil);
      FNextIDSQL.Transaction := gdcBaseManager.ReadTransaction;
      FNextIDSQL.SQL.Text := 'SELECT GEN_ID(gd_g_unique, ' +
        IntToStr(IDCacheStep) + ') + GEN_ID(gd_g_offset, 0) FROM rdb$database';
    end;

    FNextIDSQL.ExecQuery;
    FIDLimit := FNextIDSQL.Fields[0].AsInteger;
    FNextIDSQL.Close;
    FIDCurrent := FIDLimit - IDCacheStep + 1;
    Result := FIDCurrent;
  end;
  Inc(FIDCurrent);
end;

procedure TgdcBaseManager.IDCacheInit;
var
  Reg: TRegistry;
  TempIDCurrent, TempIDLimit, Test: Integer;
  ExpDate: TDate;
begin
  FIDLimit := -1;
  FIDCurrent := 0;

  if GetSystemMetrics(SM_REMOTESESSION) = 0 then
  begin
    try
      Reg := TRegistry.Create;
      try
        Reg.LazyWrite := False;
        Reg.RootKey := HKEY_CURRENT_USER;
        if Reg.OpenKey(IDCacheRegKey + IntToStr(IBLogin.DBID), false) then
        try
          TempIDCurrent := Reg.ReadInteger(IDCacheCurrentName);
          TempIDLimit := Reg.ReadInteger(IDCacheLimitName);
          Test := not Reg.ReadInteger(IDCacheTestName);
          ExpDate := Reg.ReadDate(IDCacheExpDateName);
          if Reg.DeleteValue(IDCacheCurrentName) and (TempIDCurrent xor Test = TempIDLimit)
            and (SysUtils.Date < ExpDate) then
          begin
            FIDLimit := TempIDLimit;
            FIDCurrent := TempIDCurrent;
          end;
        finally
          Reg.CloseKey;
        end;
      finally
        Reg.Free;
      end;
    except
      FIDLimit := -1;
      FIDCurrent := 0;
    end;
  end;
end;

procedure TgdcBaseManager.IDCacheFlush;
var
  Reg: TRegistry;
begin
  if (FIDLimit > 0)
    and (GetSystemMetrics(SM_REMOTESESSION) = 0) then
  begin
    Reg := TRegistry.Create;
    try
      Reg.LazyWrite := False;
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.OpenKey(IDCacheRegKey + IntToStr(IBLogin.DBID), True);
      Reg.WriteInteger(IDCacheCurrentName, FIDCurrent);
      Reg.WriteInteger(IDCacheLimitName, FIDLimit);
      Reg.WriteInteger(IDCacheTestName, not(FIDCurrent xor FIDLimit));
      Reg.WriteDate(IDCacheExpDateName, SysUtils.Date + 15);
      FIDLimit := -1;
    finally
      Reg.CloseKey;
      Reg.Free;
    end;
  end;
end;


function TgdcBaseManager.GetReadTransaction: TIBTransaction;
begin
  if Assigned(FReadTransaction)
    and (not FReadTransaction.InTransaction)
    and Assigned(FReadTransaction.DefaultDatabase)
    and (FReadTransaction.DefaultDatabase.Connected) then
  begin
    FReadTransaction.StartTransaction;
  end;

  Result := FReadTransaction;
end;

procedure TgdcBaseManager.GetRUIDByID(const ID: TID; out XID, DBID: TID;
  const Tr: TIBTransaction = nil);
var
  RR: TRuidRec;
begin
  if ID = -1 then
  begin
    XID := -1;
    DBID := -1;
  end else
  begin
    RR := GetRUIDRecByID(ID, Tr);
    if RR.XID = -1 then
    begin
      XID := ID;

      if ID < cstUserIDStart then
        DBID := cstEtalonDBID
      else begin
        DBID := IBLogin.DBID;
        InsertRUID(ID, XID, DBID, Now, IBLogin.ContactKey, Tr);
      end;
    end else
    begin
      XID := RR.XID;
      DBID := RR.DBID;
    end;
  end;
end;

function TgdcBaseManager.GetRUIDStringByID(const ID: TID;
  const Tr: TIBTransaction = nil): TRUIDString;
var
  RUID: TRUID;
begin
  GetRUIDByID(ID, RUID.XID, RUID.DBID, Tr);
  Result := RUIDToStr(RUID);
end;

procedure TgdcBaseManager.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  if Operation = Classes.opRemove then
  begin
    if AComponent = Database then
      Database := nil;
    if AComponent = FExplorer then
      FExplorer := nil;
    if AComponent = FReadTransaction then
    begin
      raise Exception.Create(GetGsException(Self,
        'Cannot delete global read transaction'));
    end;    
  end;
end;

function TgdcBase.GetRUID: TRUID;
var
  XID, DBID: TID;
begin
  if (State = dsInactive) or IsEmpty then
    raise EgdcException.CreateObj('Cannot generate RUID for an empty object.', Self);
  if sLoadFromStream in BaseState then
  begin
    Result := GetRuidFromStream;
  end else
  begin
    gdcBaseManager.GetRUIDByID(ID, XID, DBID, Transaction);
    Result.XID := XID;
    Result.DBID := DBID;
  end;
end;

procedure TgdcBaseManager.PackStream(SourceStream, DestStream: TStream; CompressionLevel: TZCompressionLevel);
var
  Z: TZCompressionStream;
begin
  Z := TZCompressionStream.Create(DestStream, CompressionLevel);
  try
    DestStream.CopyFrom(SourceStream, 0)
  finally
    Z.Free
  end
end;

function TgdcBaseManager.ProcessSQL(const S: String): String;
var
  I, K, J: Integer;
  XID, DBID, ID: TID;
  Tmp: String;
begin
  Result := S;
  
  // ���� �� ����� ���� ��������� ��������������, �� ������� ��� ���������� ���������
  if StrIPos('/>', S) = 0 then
    Exit;

  I := 0;
  repeat
    if I > 0 then
    begin
      K := StrIPos('XID', Copy(Result, I + 6, 255));
      if K = 0 then
        raise EgdcBaseManager.Create('Invalid RUID data.');
      J := I + 6 + K + 4 - 1;
      Tmp := '';
      while (J < Length(Result)) and (Result[J] in ['0'..'9', '"', '=', ' ']) do
      begin
        if Result[J] in ['0'..'9'] then
          Tmp := Tmp + Result[J];
        Inc(J);
      end;
      XID := StrToIntDef(Tmp, -1);
      if XID = -1 then
        raise EgdcBaseManager.Create('Invalid RUID data.');

      K := StrIPos('DBID', Copy(Result, J, 255));
      if K = 0 then
        raise EgdcBaseManager.Create('Invalid RUID data.');
      J := J + K + 5 - 1;
      Tmp := '';
      while (J < Length(Result)) and (Result[J] in ['0'..'9', '"', '=', ' ']) do
      begin
        if Result[J] in ['0'..'9'] then
          Tmp := Tmp + Result[J];
        Inc(J);
      end;
      DBID := StrToIntDef(Tmp, -1);
      if DBID = -1 then
        raise EgdcBaseManager.Create('Invalid RUID data.');

      K := Pos('/>', Copy(Result, J, 255));
      if K = 0 then
        raise EgdcBaseManager.Create('Invalid RUID data.');

      ID := GetIDByRUID(XID, DBID);
      if ID = -1 then
        raise EgdcBaseManager.Create('Unknown RUID.');

      Delete(Result, I, J + K - I + 1);
      Insert(IntToStr(ID), Result, I);
    end;
    I := StrIPos('<RUID ', Result);
  until I = 0;

  I := 0;
  repeat
    if I > 0 then
    begin
      Delete(Result, I, Length('<INGROUP/>'));
      Insert(IntToStr(IBLogin.InGroup), Result, I);
    end;
    I := StrIPos('<INGROUP/>', Result);
  until I = 0;

  I := 0;
  repeat
    if I > 0 then
    begin
      Delete(Result, I, Length('<COMPANYKEY/>'));
      Insert(IntToStr(IBLogin.CompanyKey), Result, I);
    end;
    I := StrIPos('<COMPANYKEY/>', Result);
  until I = 0;

  I := 0;
  repeat
    if I > 0 then
    begin
      Delete(Result, I, Length('<CONTACTKEY/>'));
      Insert(IntToStr(IBLogin.ContactKey), Result, I);
    end;
    I := StrIPos('<CONTACTKEY/>', Result);
  until I = 0;

  I := 0;
  repeat
    if I > 0 then
    begin
      Delete(Result, I, Length('<HOLDINGLIST/>'));
      Insert(IBLogin.HoldingList, Result, I);
    end;
    I := StrIPos('<HOLDINGLIST/>', Result);
  until I = 0;

  I := 0;
  repeat
    if I > 0 then
    begin
      Delete(Result, I, Length('<NCU/>'));
      Insert(IntToStr(GetNCUKey), Result, I);
    end;
    I := StrIPos('<NCU/>', Result);
  until I = 0;
end;

procedure TgdcBaseManager.SetDatabase(const Value: TIBDatabase);
begin
  if (Database <> Value)
    and Assigned(FIBBase)
    and Assigned(FReadTransaction) then
  begin
    FIBBase.Database := Value;
    FReadTransaction.DefaultDatabase := Value;
  end;
end;

class function TgdcBase.CreateViewForm(AnOwner: TComponent;
  const AClassName: String = ''; const ASubType: String = '';
  const ANewInstance: Boolean = False): TForm;
var
  CE: TgdClassEntry;
  F: TgdcCreateableForm;
begin
  Assert(IBLogin <> nil);
  Assert(atDatabase <> nil);

  if atDatabase.InMultiConnection then
  begin
    MessageBox(0,
      '���������� ��������������� � ���� ������.',
      '��������',
      MB_OK or MB_ICONHAND or MB_TASKMODAL);
    Abort;
  end;

  { TODO :
��������! ����� TestConnected ����� ��������
� ������ ������������������! }
  if (not IBLogin.LoggedIn) or (not IBlogin.Database.TestConnected) then
  begin
    raise EgdcException.Create(
      '���� ������ �� ���������� ��� �������� ���������� � ����� ������');
  end;

  if not Class_TestUserRights([tiAView], ASubType) then
    raise EgdcUserHaventRights.Create('��� ���� ��� �������� �����.'#13#10 +
      '��� ������: ' + Self.ClassName + #13#10 +
      '������: ' + ASubType);

  CE := gdClassList.Find(AClassName, ASubType);
  if not (CE is TgdFormEntry) then
    CE := gdClassList.Find(GetViewFormClassName(ASubType), ASubType);
  if (CE is TgdFormEntry) and CE.TheClass.InheritsFrom(TgdcCreateableForm) then
  begin
    if ANewInstance then
      Result := nil
    else
      Result := CgdcCreateableForm(CE.TheClass).FindForm(CgdcCreateableForm(CE.TheClass), ASubType);
    if Result = nil then
    begin
      F := nil;
      try
        F := CgdcCreateableForm(CE.TheClass).CreateSubType(AnOwner, ASubType);
        F.Setup(F.gdcObject);
      except
        F.Free;
        raise;
      end;
      Result := F;
    end;
  end else
    Result := nil;
end;

procedure TgdcBase.SetSubSet(const Value: TgdcSubSet);
var
  I: Integer;
begin
  if not (csLoading in ComponentState) then
    Close;
  if (csDesigning in ComponentState) then
    FSubSets.CommaText := Value
  else if SubSet <> Value then
  begin
    FSubSets.CommaText := Value;
    if FSubSets.Count = 0 then
      raise EgdcException.CreateObj(Format('Invalid subset "%s" specified.', [Value]), Self);
    for I := 0 to FSubSets.Count - 1 do
      if not CheckSubSet(FSubSets[I]) then
        raise EgdcException.CreateObj(Format('Invalid subset "%s" specified.', [Value]), Self);
    UniDirectional := HasSubSet('ByID');
    if (not UniDirectional) and HasSubSet('ByName') then
      BufferChunks := 2;
    FSQLInitialized := False;
    if Assigned(FOnFilterChanged) then
      FOnFilterChanged(Self);
  end;
end;

function TgdcBase.CheckSubSet(const ASubSet: String): Boolean;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKSUBSET('TGDCBASE', 'CHECKSUBSET', KEYCHECKSUBSET)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYCHECKSUBSET);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKSUBSET]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ASubSet]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'CHECKSUBSET', KEYCHECKSUBSET, Params, LResult) then
  {M}          begin
  {M}            if VarType(LResult) = varBoolean then
  {M}              Result := Boolean(LResult)
  {M}            else
  {M}              begin
  {M}                Result := False;
  {M}                raise Exception.Create('��� ������ ''' + 'CHECKSUBSET' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Result := False;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Pos(';' + ASubSet + ';', ';' + GetSubSetList) > 0;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'CHECKSUBSET', KEYCHECKSUBSET)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'CHECKSUBSET', KEYCHECKSUBSET);
  {M}  end;
  {END MACRO}
end;

// �������
function TgdcBase.Reduction(BL: TBookmarkList): Boolean;
begin
  if BL <> nil then
    BL.Refresh;

  if (BL <> nil) and (BL.Count > 1) then
    Result := InternalReduction(GetIDForBookmark(BL[0]), GetIDForBookmark(BL[1]))
  else
    Result := InternalReduction;
end;

function TgdcBase.InternalReduction(const ACondemnedKey: TID = -1; const AMasterKey: TID = -1): Boolean;
var
  FgsDBReduction: TgsDBReductionWizard;
  C: TClass;
  S: String;
  DidActivate: Boolean;
begin
  if Assigned(GlobalStorage) and Assigned(IBLogin)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_REDUCT_ID, GD_POL_REDUCT_MASK, False) and IBLogin.InGroup) = 0) then
  begin
    raise EgdcUserHaventRights.Create('����������� ������� ��������� �������� ����������� �������� ������������.');
  end;

  DidActivate := False;
  FgsDBReduction := TgsDBReductionWizard.Create(nil);
  try
    DidActivate := ActivateTransaction;

    FgsDBReduction.Database := DataBase;
    FgsDBReduction.Transaction := Transaction;

    FgsDBReduction.Table := GetReductionTable;
    FgsDBReduction.MainTable := GetListTable(SubType);
    FgsDBReduction.KeyField := GetKeyField(SubType);
    FgsDBReduction.ListField := GetListField(SubType);
    FgsDBReduction.AddCondition := GetReductionCondition;
    FgsDBReduction.HideFields := HideFieldsList + 'LB;RB;';

    if ACondemnedKey >= 0 then
      FgsDBReduction.CondemnedKey := IntToStr(ACondemnedKey)
    else
      FgsDBReduction.CondemnedKey := IntToStr(ID);

    if AMasterKey >= 0 then
      FgsDBReduction.MasterKey := IntToStr(AMasterKey);

    C := GetCurrRecordClass.gdClass;

    if C <> nil then
      S := C.ClassName
    else
      S := '';

    Result := FgsDBReduction.Wizard(S, SubType);

    if DidActivate then
      Transaction.Commit;
  finally
    if DidActivate and Transaction.InTransaction then
      Transaction.Rollback;
    FgsDBReduction.Free;
  end;
end;

procedure _Traverse(CE: TgdClassEntry; q: TIBSQL; const ARoot: Boolean;
  const AnID: TID; var ASubType: TgdcSubType);
var
  I: Integer;
begin
  for I := 0 to CE.Count - 1 do
  begin
    _Traverse(CE.Children[I], q, False, AnID, ASubType);
    if ASubType > '' then
      exit;
  end;

  if (not ARoot) and (CE is TgdAttrUserDefinedEntry) then
  begin
    q.SQL.Text :=
      'SELECT inheritedkey FROM ' + (CE as TgdBaseEntry).DistinctRelation +
      ' WHERE inheritedkey = :id';
    q.ParamByName('id').AsInteger := AnID;
    q.ExecQuery;
    if not q.EOF then
      ASubType := CE.SubType;
    q.Close;
  end;
end;

procedure TgdcBase.FindInheritedSubType(var FC: TgdcFullClass);
var
  q: TIBSQL;
  CE: TgdClassEntry;
  S: TgdcSubType;
begin
  if not IsEmpty then
  begin
    CE := gdClassList.Find(FC.gdClass.ClassName, FC.SubType);

    if not (CE is TgdBaseEntry) then
    begin
      FC.SubType := '';
      CE := gdClassList.Get(TgdBaseEntry, FC.gdClass.ClassName, FC.SubType);
    end;

    if CE.Count > 0 then
    begin
      S := '';
      q := TIBSQL.Create(nil);
      try
        q.Transaction := ReadTransaction;
        _Traverse(CE, q, True, ID, S);
      finally
        q.Free;
      end;
      if S > '' then
        FC.SubType := S;
    end;
  end;
end;

function TgdcBase.GetCurrRecordClass: TgdcFullClass;
begin
  Result.gdClass := CgdcBase(Self.ClassType);
  Result.SubType := SubType;
  FindInheritedSubType(Result);
end;

function TgdcBase.GetNameInScript: String;
begin
  if FNameInScript > '' then
    Result := FNameInScript
  else
    Result := Name;
end;

function TgdcBase.CreateDescendant: Boolean;
begin
  Result := CreateDialog(QueryDescendant);
end;

function TgdcBase.CreateDialog(C: CgdcBase): Boolean;
begin
  Result := CreateDialog(MakeFullClass(C, ''));
end;

function TgdcBase.CreateDialog(C: TgdcFullClass;
  const AnInitProc: TgdcBaseInitProc = nil): Boolean;
var
  Obj: TgdcBase;
  I: Integer;
  F: TField;
begin
  if C.gdClass <> nil then
  begin
    CheckClass(C.gdClass);
    if (C.gdClass = Self.ClassType) and AnsiSameText(C.SubType, SubType) then
      Result := CreateDialog
    else begin
      Obj := C.gdClass.CreateWithParams(Owner, Database, Transaction,
        C.SubType, 'OnlySelected');
      if Assigned(AnInitProc) then
        AnInitProc(Obj);
      try
        // ����������� ���� ��������� �������!
        //Obj.MasterField := MasterField;
        //Obj.DetailField := DetailField;
        CopyEventHandlers(Obj, Self);
        try

          //Obj.Assign(Self);

          Result := Obj.CreateDialog;

          if Result and Active and Obj.Active then
          begin
            FDataTransfer := True;

            ResetEventHandlers(Self);
            try
              { TODO : �������� ������ ���� ������! ��������� ������ ����� ����� }

              Obj.First;
              while not Obj.EOF do
              begin
                Insert;
                try
                  for I := 0 to FieldCount - 1 do
                  begin
                    F := Obj.FindField(Fields[I].FieldName);
                    if Assigned(F) then
                      Fields[I].Assign(F);
                  end;
                  Post;
                except
                  if State in dsEditModes then
                    Cancel;
                  raise;
                end;
                Obj.Next;
              end;
            finally
              FDataTransfer := False;
            end;
          end;

        finally
          CopyEventHandlers(Self, Obj);
        end;

      finally
        Obj.Free;
      end;
    end;
  end else
    Result := False;
end;


// ����� ������ �������
procedure TgdcBase.DoOnReportListClick(Sender: TObject);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_SENDER('TGDCBASE', 'DOONREPORTLISTCLICK', KEYDOONREPORTLISTCLICK)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOONREPORTLISTCLICK);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOONREPORTLISTCLICK]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(Sender)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOONREPORTLISTCLICK', KEYDOONREPORTLISTCLICK, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
//  ClientReport.Execute(GroupID);
  if Assigned(EventControl) then
  begin
    EventControl.EditObject(Self, emReport);
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOONREPORTLISTCLICK', KEYDOONREPORTLISTCLICK)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOONREPORTLISTCLICK', KEYDOONREPORTLISTCLICK);
  {M}  end;
  {END MACRO}
end;

// ����� ������ ��� ������
procedure TgdcBase.DoOnReportClick(Sender: TObject);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_SENDER('TGDCBASE', 'DOONREPORTCLICK', KEYDOONREPORTCLICK)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOONREPORTCLICK);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOONREPORTCLICK]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(Sender)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOONREPORTCLICK', KEYDOONREPORTCLICK, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  PrintReport((Sender as TMenuItem).Tag);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOONREPORTCLICK', KEYDOONREPORTCLICK)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOONREPORTCLICK', KEYDOONREPORTCLICK);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.PrintReport(const ID: Integer);
begin
  Assert(ClientReport <> nil, '�� ��������� ������ �������');
  if Assigned(FCurrentForm) and FCurrentForm.InheritsFrom(TCreateableForm) then
    ClientReport.BuildReport(GetGdcOLEObject(FCurrentForm) as IDispatch, ID)
  else
    ClientReport.BuildReport(Unassigned, ID);
end;

procedure TgdcBase.IsUse;
var
  I: Integer;
  LI: TListItem;
  FTableList, FForeignList, FKeyList: TStringList;
  FKeyField: String;
  FTable, FKey: String;
  OL: TObjectList;

  // ���������� ��������� ���� ��� �������� �������
  function GetPrimary(const TableName: String): String;
  var
    R: TatRelation;
  begin
    R := atDatabase.Relations.ByRelationName(TableName);
    if (R = nil) or (R.PrimaryKey.ConstraintFields.Count <> 1) then
      Result := ''
    else
      Result := R.PrimaryKey.ConstraintFields[0].FieldName;
  end;

  procedure AddTable(const TableName: String);
  var
    sql: TIBSQL;
    I: Integer;
    FK: TatForeignKey;
    Lst: TObjectList;
  begin
    sql := TIBSQL.Create(nil);
    Lst := TObjectList.Create(False);
    try
      if Transaction.InTransaction then
        sql.Transaction := Transaction
      else
        sql.Transaction := ReadTransaction;

      atDatabase.ForeignKeys.ConstraintsByReferencedRelation(TableName, Lst);
      for I := 0 to Lst.Count - 1 do
      begin
        FK := Lst[I] as TatForeignKey;

        if FK.IsSimpleKey and (GetPrimary(FK.Relation.RelationName) > '') then
        begin
          sql.Close;
          sql.SQL.Text := 'SELECT FIRST 1 * FROM ' + FK.Relation.RelationName +
            ' WHERE ' + FK.ConstraintFields[0].FieldName + '=' + FKey;
          sql.ExecQuery;
          if not sql.EOF then
          begin
            FTableList.Add(FK.Relation.RelationName);
            FForeignList.Add(FK.ConstraintFields[0].FieldName);
            FKeyList.Add(GetPrimary(FK.Relation.RelationName));
          end;
        end;
      end;
    finally
      Lst.Free;
      sql.Free;
    end;
  end;

var
  gdcCurrClass: TgdcBase;
  gdcClassByRecord: TgdcBase;
  GroupName: String;
  FC: TgdcFullClass;
  qryID: TIBSQL;
  IDList: TStringList;
  FNotEof: Boolean;
begin
  if UserStorage.ReadBoolean('Options', 'DelSilent', False, False) then
    exit;

  if (GlobalStorage.ReadInteger('Options\Policy',
    GD_POL_CASC_ID, GD_POL_CASC_MASK, False) and IBLogin.InGroup) = 0 then
  begin
    MessageBox(ParentHandle,
      PChar('������ ���������� �������, ��� ��� ���������� ������ ������, ������� �� ��� ���������.'#13#10 +
      '������ ���������� ���������� ��������� �������� ����������� ��������� �������� ������������.'),
      '��������',
      MB_OK or MB_ICONHAND or MB_TASKMODAL);
    exit;
  end;

  FTableList := TStringList.Create;
  FForeignList := TStringList.Create;
  FKeyList := TStringList.Create;
  IDList := TStringList.Create;
  try
    FTable := GetListTable(SubType);
    FKeyField := GetPrimary(FTable);
    FKey := FieldByName(FKeyField).AsString;

    Assert(FKeyField > '', '� ������� ����������� �������� ����.');
    AddTable(FTable);
    //���������� ��� �������, ������� ����� � ������� �������� ����� 1:1
    OL := TObjectList.Create(False);
    try
      atDatabase.ForeignKeys.ConstraintsByReferencedRelation(
        GetListTable(SubType), OL);
      for I := 0 to OL.Count - 1 do
        with OL[I] as TatForeignKey do
      begin
        if IsSimpleKey
          and (Relation.PrimaryKey <> nil)
          and (Relation.PrimaryKey.ConstraintFields.Count = 1)
          and (ConstraintField = Relation.PrimaryKey.ConstraintFields[0]) then
        begin
          AddTable(Relation.RelationName);
        end;
      end;
    finally
      OL.Free;
    end;

    if FTableList.Count <> 0 then
    begin
      qryID := TIBSQL.Create(nil);
      try
        if Transaction.InTransaction then
          qryID.Transaction := Transaction
        else
          qryID.Transaction := ReadTransaction;

        with TdlgTableValues.Create(Self) do
        try
          lvTables.Items.BeginUpdate;
          for I := 0 to FTableList.Count - 1 do
          begin
            qryID.Close;
            //������� ��� �������� ��������� ���� �� ��������� ������
            qryID.SQL.Text := Format('SELECT %0:s as ID FROM %1:s WHERE %2:s = %3:s ',
              [FKeyList[I], FTableList[I], FForeignList[I], FKey]);
            qryID.ExecQuery;
            //������� ������� ����� ��� �������
            //FC := GetBaseClassForRelation(FTableList[I]);
            FC := GetBaseClassForRelationByID(FTableList[I], qryID.FieldByName(fnID).AsInteger, Transaction);
            //���� �� �� ����� ������� ����� ��� ������� ���������� ��������
            if FC.gdClass = nil then
            begin
              raise EgdcException.Create('���������� ������� ������ "' + GetDisplayName(SubType) + '" '
                + FieldByName(GetListField(SubType)).AsString + ' � ���������������: ' + IntToStr(ID) +
                #13#10#13#10 + '�� ������ ������ ��������� ������ � ������� ' + FTableList[I] + '.');
            end;

            //������� ������ ������ �� id
            if FC.gdClass.ClassName <> 'TgdcInvBaseRemains' then
            begin
              gdcCurrClass := FC.gdClass.CreateSingularByID(nil,
                qryID.FieldByName(fnID).AsInteger, FC.SubType);
              try
                //��������� ��� ID  � ������
                IDList.Clear;
                while (not qryID.Eof) and (IDList.Count < 1000)do
                begin
                  //������� ������ ������, ���� �������� ������
                  IDList.Add(qryID.FieldByName(fnID).AsString);
                  qryID.Next;
                end;
                //������������� ����, ������� �� �� ���� ������
                FNotEof := not qryID.Eof;
                qryID.Close;
                //�� ������� ������ ������� ���������� ����� �������
                FC := gdcCurrClass.GetCurrRecordClass;
                if not Assigned(FC.gdClass) then
                  raise EgdcException.Create(Format('��� ������� "%s" �� ������ ������-�����! ', [FTableList[I]]));

                //������� ������, ����� �������� ��� ������������ ��� � ��������� ��� � ������
                gdcClassByRecord := FC.gdClass.CreateSubType(nil, FC.SubType);
                try
                  if (gdcClassByRecord is TgdcDocument) then
                  begin
                    GroupName := gdcClassByRecord.GetDisplayName(gdcClassByRecord.SubType) +
                      ' (' + (gdcClassByRecord as TgdcDocument).DocumentName + ')';
                  end else
                    GroupName := gdcClassByRecord.GetDisplayName(gdcClassByRecord.SubType);

                  AddNewObject(GroupName, FC, IDList, FNotEof);
                  LI := lvTables.Items.Add;
                  LI.Caption := GroupName;
                finally
                  gdcClassByRecord.Free;
                end;
                
              finally
                gdcCurrClass.Free;
              end;
            end;
          end;
          if lvTables.Items.Count <> 0 then
            lvTables.Items[lvTables.Items.Count - 1].Selected := True;
          lvTables.Items.EndUpdate;

          Caption := '�������� ������: "' + ObjectName + '" ���� "' +
            GetDisplayName(SubType) + '", ��: ' + IntToStr(ID);

          ShowModal;
        finally
          Free;
        end
      finally
        qryID.Free;
      end;
    end
    else
      raise EgdcException.Create('���������� ������� ������ "' + GetDisplayName(SubType) + '" "'
        + FieldByName(GetListField(SubType)).AsString + '" � ���������������: ' + IntToStr(ID) +
        #13#10#13#10 + '��������, �� ������ ������ ��������� ������ ������.');
  finally
    FTableList.Free;
    FForeignList.Free;
    FKeyList.Free;
    IDList.Free;
  end;
end;

procedure TgdcBase.ExecSingleQuery(const S: String);
begin
  gdcBaseManager.ExecSingleQuery(S, varNull, Transaction);
end;

function TgdcBase.DeleteRecord: Boolean;
var
  I: Integer;
  DL: TgdcBase;
  DidActivate, OldFiltered: Boolean;
  F: TField;
begin
  Result := False;
  try
    DidActivate := False;
    try
      // ���� ������ ����� �� ����� � � ���� ���� ���������
      // �������� ���������-�������, �� ������ ������� �������
      if sView in BaseState then
      begin
        for I := 0 to Self.DetailLinksCount - 1 do
        begin
          DL := TgdcBase(Self.DetailLinks[I]);

          // �� ����� ����� ���� ��������� ��������, ������������
          // � ������. ���������� ����� ������: �� ����� ����� ������ ���������,
          // ������ ������� ��������� � ������ ������. ��� ���������, ����������
          // ��� ��������� � ���������. ��������, ��� ��� ��������, ������
          // ������ �� ������� �������.
          {
          if CompareText(DL.DetailField, DL.GetKeyField(DL.SubType)) = 0 then
          begin
            continue;
          end;
          }
          F := Self.FindField(DL.MasterField);
          if (not (F is TIntegerField)) or (Self.ID <> F.AsInteger) then
            continue;

          if (Self is TgdcDocument) and (SubType <> DL.SubType) then
          begin
            continue;
          end;

          // ��� ��� ������� ����� ������� ��� �� �����
          if not Transaction.InTransaction then
          begin
            DidActivate := True;
            Transaction.StartTransaction;
          end;

          OldFiltered := DL.Filtered;
          //DL.DisableControls;
          try
            // �� ������ ������� ��� ������,
            // ������������� ������� ������ � ��������
            // ���� �� ���
            if DL.Filtered then
              DL.Filtered := False;

            DL.First;
            while not DL.EOF do
            begin
              // ���� �� ��� ������ � ��������� �������� ����� �������,
              // �� ������ ��������� � ���� ���. ��������� ����� ������
              // � ��� ��� ����� ���� �� �� ��������, ����� ��
              // ����� ������� ������� ������.
              try
                if DL.CanDelete then
                  DL.DeleteRecord
                else
                  DL.Next;
              except
                on EAbort do raise;
              else
                break;
              end;
            end;
          finally
            if DL.Filtered <> OldFiltered then
              DL.Filtered := OldFiltered;
          end;
        end;
      end;

      // ���������������� ������ ��� � ����������� ����� � ������ Post!
      try
        Delete;
      except
        on E: EIBError do
        begin
          if ((E.IBErrorCode = isc_lock_conflict) or (E.IBErrorCode = isc_deadlock))
            and (sView in BaseState) then
          begin
            MessageBox(ParentHandle, PChar(
              '��������� �������� ��� �������� ������.'#13#10 +
              '������ ������������ �������������: ' + GetUserByTransaction(StatusVectorArray[9]) + #13#10 +
              '��������, ������ ���������� � ������� ������ �������'#13#10 +
              '��� ���� ������� �������� (�������) ������ �������������.'#13#10#13#10 +
              '�������� ��������������, �������� ������ � ����������'#13#10 +
              '��������� �������� �����.'#13#10#13#10 +
              '� ������ ���������� ������ �������� ����������'#13#10 +
              '� ���������� ��������������.'),
              '��������',
              MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
            Abort;
          end else
            raise;
        end;
      else
        raise;
      end;

      if DidActivate and Transaction.InTransaction then
        Transaction.Commit;

      Result := True

    except
      if DidActivate and Transaction.InTransaction then
      begin
        Transaction.Rollback;

        for I := 0 to Self.DetailLinksCount - 1 do
        begin
          DL := TgdcBase(Self.DetailLinks[I]);

          // �� ����� ����� ���� ��������� ��������, ������������
          // � ������. ���������� ����� ������: �� ����� ����� ������ ���������,
          // ������ ������� ��������� � ������ ������. ��� ���������, ����������
          // ��� ��������� � ���������. ��������, ��� ��� ��������, ������
          // ������ �� ������� �������.
          {
          if CompareText(DL.DetailField, DL.GetKeyField(DL.SubType)) = 0 then
          begin
            continue;
          end;
          }
          F := Self.FindField(DL.MasterField);
          if (not (F is TIntegerField)) or (Self.ID <> F.AsInteger) then
            continue;

          try
            DL.Close;
            DL.Open;
          except
          end;
        end;
      end;
      raise;
    end;

  except
    on E: EIBError do
    begin
      if ((E.IBErrorCode = isc_foreign_key) or ((E.IBErrorCode = isc_except) and (
          StrIPos('GD_E_FKMANAGER', E.Message) > 0)))
        and (sView in FBaseState) then
      begin
        // ������� ������������� ����� ������, ����� ����� ���� ����� ����������� ������
        if IBLogin.IsUserAdmin then
        begin
          if Application.MessageBox(PChar(Format('%s'#13#10'�������� ����� ����������� �������?', [E.Message])),
            '��������', MB_YESNO + MB_ICONERROR + MB_APPLMODAL) = IDYES then
          begin
            isUse;
            Abort;
          end
        end
        else
        begin
          isUse;
          Abort;
        end;
      end else
        raise EgdcIBError.CreateObj(E, Self);
    end;
  end;
end;

class procedure TgdcBase.CheckClass(C: TClass);
begin
  if not C.InheritsFrom(Self) then
    raise EgdcIBError.Create('Invalid gdc class specified');
end;

function TgdcBase.GetGroupID: Integer;
var
  q: TIBSQL;
  DidActivate: Boolean;
  N, UGN: String;
  I: Integer;
begin
  if (FGroupID <= 0) and (Transaction <> nil) then
  begin
    UGN := UpperCase(ClassName + SubType);
    q := TIBSQL.Create(nil);
    try
      q.Transaction := ReadTransaction;
      q.SQL.Text := 'SELECT id FROM rp_reportgroup WHERE usergroupname = :UGN';
      q.ParamByName('UGN').AsString := UGN;
      q.ExecQuery;
      if q.RecordCount > 0 then
        FGroupID := q.FieldByName(fnID).AsInteger
      else
      begin
        q.Close;

        DidActivate := not Transaction.InTransaction;
        if DidActivate then
          Transaction.StartTransaction;
        try
          q.Transaction := Transaction;
          q.ExecQuery;
          if q.RecordCount > 0 then
            FGroupID := q.FieldByName(fnID).AsInteger
          else begin
            FGroupID := GetNextID;
            q.Close;
            q.SQL.Text := 'SELECT id FROM rp_reportgroup WHERE name = :name AND parent IS NULL';
            I := 0;

            repeat
              N := GetDisplayName(SubType);
              if I > 0 then
                N := N + IntToStr(I);
              Inc(I);
              q.Close;
              q.ParamByName('name').AsString := N;
              q.ExecQuery;
            until q.RecordCount = 0;

            q.Close;
            q.SQL.Text := 'INSERT INTO RP_REPORTGROUP(ID, USERGROUPNAME, NAME) VALUES (:ID, :UGN, :N)';
            q.ParamByName('ID').AsInteger := FGroupID;
            q.ParamByName('UGN').AsString := UGN;
            q.ParamByName('N').AsString := N;
            q.ExecQuery;
          end;
          if DidActivate then
            Transaction.Commit;
        except
          if Transaction.InTransaction and DidActivate then
            Transaction.Rollback;
          FGroupID := -1;
        end;
      end;
    finally
      q.Free;
    end;
  end;
  Result := FGroupID;
end;

procedure TgdcBase.LoadEventList;
begin
  FEventList.Add(gdcEventTypesString[etAfterCancel]);
  FEventList.Add(gdcEventTypesString[etAfterClose]);
  FEventList.Add(gdcEventTypesString[etAfterDelete]);
  FEventList.Add(gdcEventTypesString[etAfterEdit]);
  FEventList.Add(gdcEventTypesString[etAfterInsert]);
  FEventList.Add(gdcEventTypesString[etAfterOpen]);
  FEventList.Add(gdcEventTypesString[etAfterPost]);
  FEventList.Add(gdcEventTypesString[etAfterRefresh]);
  FEventList.Add(gdcEventTypesString[etAfterScroll]);
  FEventList.Add(gdcEventTypesString[etBeforeCancel]);
  FEventList.Add(gdcEventTypesString[etBeforeClose]);
  FEventList.Add(gdcEventTypesString[etBeforeDelete]);
  FEventList.Add(gdcEventTypesString[etBeforeEdit]);
  FEventList.Add(gdcEventTypesString[etBeforeInsert]);
  FEventList.Add(gdcEventTypesString[etBeforeOpen]);
  FEventList.Add(gdcEventTypesString[etBeforePost]);
  FEventList.Add(gdcEventTypesString[etBeforeRefresh]);
  FEventList.Add(gdcEventTypesString[etBeforeScroll]);
  FEventList.Add(gdcEventTypesString[etOnCalcFields]);
  FEventList.Add(gdcEventTypesString[etOnNewRecord]);
  FEventList.Add(gdcEventTypesString[etOnFieldChange]);
  FEventList.Add(gdcEventTypesString[etAfterInternalPostRecord]);
  FEventList.Add(gdcEventTypesString[etBeforeInternalPostRecord]);
  FEventList.Add(gdcEventTypesString[etAfterInternalDeleteRecord]);
  FEventList.Add(gdcEventTypesString[etBeforeInternalDeleteRecord]);
end;

procedure TgdcBase.CreateFields;
var
  LocalHideFieldsList: String;

  function ShowRelationFieldInGrid(AField: TField; const AFieldName: String;
    const RF: TatRelationField): Boolean;
  begin
    Result := AField.Visible
      and (
        (StrIPos(AFieldName, LocalHideFieldsList) = 0)
        or
        (StrIPos(';' + AFieldName + ';', LocalHideFieldsList) = 0)
      );

    if Result and (not IBLogin.IsUserAdmin) and (RF <> nil) then
    begin
      if (RF.aView and IBLogin.Ingroup) = 0 then
      begin
        Result := False;
      end else if (RF.aChag and IBLogin.Ingroup) = 0 then
      begin
        AField.ReadOnly := True;
      end;
    end;
  end;

var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  I: Integer;
  F: TatRelationField;
  FieldName, RelationName: String;
  FFieldList: TStringHashMap;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASE', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  LocalHideFieldsList := ';' + HideFieldsList;
  FFieldList := TStringHashMap.Create(CaseSensitiveTraits, 256);
  try
    // ���������� �������� ����� �����
    for I := 0 to FieldCount - 1 do
    begin
      ParseFieldOrigin(Fields[I].Origin, RelationName, FieldName);
      F := atDatabase.FindRelationField(RelationName, FieldName);

      if F <> nil then
      begin
        Fields[I].DisplayLabel := F.LName;
        if FFieldList.Has(F.LName) then
        begin
          if F.Relation <> nil then
            Fields[I].DisplayLabel := F.LName + ' (' + F.Relation.LName + ')';
        end else
          FFieldList.Add(F.LName, I);

        if F.CrossRelation <> nil then
          Fields[I].ReadOnly := True;
      end;
      // ��� �����, ������� �� ������ � ������� �� ���������� ������
      // � ���� ��� ������� �� ������������� ����������� ���������
      // �� ������� Required
      if (CustomProcess * [cpInsert, cpModify]) = [] then
        if StrIPos(',' + Fields[I].FieldName + ',', ',' + FUpdateableFields + ',') = 0 then
        begin
          Fields[I].Required := False;
        end;

      if RelationName > '' then
        Fields[I].Visible := ShowRelationFieldInGrid(Fields[I], FieldName, F)//ShowFieldInGrid(Fields[I]);
      else
        Fields[I].Visible := True;
    end;
  finally
    FFieldList.Free;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

function TgdcBase.GetHasWhereClause: Boolean;
begin
  Result := (GetWhereClause > '') or
    (Assigned(IBLogin) and ([tiAView, tiAChag, tiAFull] * gdcTableInfos <> []));
end;

class function TgdcBase.GetListTableAlias: String;
begin
  // default table alias
  Result := 'z';
end;

function TgdcBase.QueryDescendant: TgdcFullClass;
var
  OL: TObjectList;
begin
  Result.gdClass := nil;
  Result.SubType := '';

  OL := TObjectList.Create(False);
  try
    if not GetChildrenClass(SubType, OL) then
    begin
      Result.gdClass := CgdcBase(Self.ClassType);
      Result.SubType := SubType;
      exit;
    end;

    if OL.Count = 1 then
    begin
      Result.gdClass := TgdBaseEntry(OL[0]).gdcClass;
      Result.SubType := TgdBaseEntry(OL[0]).SubType;
      exit;
    end;

    with Tgdc_dlgQueryDescendant.Create(ParentForm) do
    try
      FillrgObjects(OL);

      if (ShowModal = mrOk) and (rgObjects.ItemIndex > -1) then
      begin
        Result.gdClass := TgdBaseEntry(rgObjects.Items.Objects[rgObjects.ItemIndex]).gdcClass;
        Result.SubType := TgdBaseEntry(rgObjects.Items.Objects[rgObjects.ItemIndex]).SubType;
      end;
    finally
      Free;
    end;
  finally
    OL.Free;
  end;
end;

class function TgdcBase.GetListNameByID(const AnID: TID;
  const ASubType: TgdcSubType = ''): String;
var
  q: TIBSQL;
begin
  Assert(Assigned(gdcBaseManager) and Assigned(gdcBaseManager.Database));
  Assert(Assigned(gdcBaseManager.ReadTransaction));
  Assert(gdcBaseManager.ReadTransaction.InTransaction);
  Assert(GetListField(ASubType) > '');
  Assert(GetKeyField(ASubType) > '');

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text := 'SELECT ' + GetListField(ASubType) + ' FROM ' +
      GetListTable(ASubType) + ' WHERE ' + GetKeyField(ASubType) + ' = :ID';
    q.Params[0].AsInteger := AnID;
    q.ExecQuery;
    if q.EOF then
      Result := ''
    else
      Result := q.Fields[0].AsString;
    q.Close;
  finally
    q.Free;
  end;
end;

procedure TgdcBase.PopupReportMenu(const X, Y: Integer);
var
  Pt: TPoint;
  Msg: TMsg;
begin
  MakeReportMenu;

  if (X = -1) and (Y = -1) then
    GetCursorPos(Pt)
  else
    Pt := Point(X, Y);

  FpmReport.Popup(Pt.X, Pt.Y);

  if PeekMessage(Msg, PopupList.Window, WM_COMMAND, WM_COMMAND, PM_NOREMOVE)
    and (not Application.Terminated) then
  begin
    Application.ProcessMessages;
  end;
end;

procedure TgdcBase.PopupFilterMenu(const X, Y: Integer);
var
  S: String;
begin
  if (GlobalStorage.ReadInteger('Options\Policy', GD_POL_APPL_FILTERS_ID,
    GD_POL_APPL_FILTERS_MASK, False) and IBLogin.InGroup) = 0 then
  begin
    S := '���������� �������� ��� �������� ������������ ���������'#13#10 +
      '����������� ��������� �������� ������������.';
    if FQueryFilter.FilterName > '' then
    begin
      S := S + #13#10#13#10 +
        '�������� ��������� �������������� ������� �� ������'#13#10 +
        '���������������� ������������ ������ Ctrl-F5.';
    end;

    raise EgdcUserHaventRights.Create(S);
  end;

  if Assigned(FQueryFilter) then
    FQueryFilter.PopupMenu(X, Y);
end;

procedure TgdcBase.DoOnFilterChanged(Sender: TObject;
  const AnCurrentFilter: Integer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_DOONFILTERCHANGED('TGDCBASE', 'DOONFILTERCHANGED', KEYDOONFILTERCHANGED)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOONFILTERCHANGED);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOONFILTERCHANGED]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self),
  {M}          GetGdcInterface(Sender), AnCurrentFilter]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOONFILTERCHANGED', KEYDOONFILTERCHANGED, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if Assigned(FOnFilterChanged) then
    FOnFilterChanged(Sender);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOONFILTERCHANGED', KEYDOONFILTERCHANGED)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOONFILTERCHANGED', KEYDOONFILTERCHANGED);
  {M}  end;
  {END MACRO}
end;

{procedure TgdcBase.SetIBSQL;
begin
  FIBSQL.Close;
  FIBSQL.DataBase := DataBase;
  FIBSQL.Transaction := Transaction;
end;}

function TgdcBase.GetDetailLinks(Index: Integer): TgdcBase;
begin
  Result := FDetailLinks[Index] as TgdcBase;
end;

function TgdcBase.GetDetailLinksCount: Integer;
begin
  Result := FDetailLinks.Count;
end;

procedure TgdcBase.AddDetailLink(AnObject: TgdcBase);
begin
  if Assigned(FDetailLinks) and (FDetailLinks.IndexOf(AnObject) = -1) then
  begin
    FDetailLinks.Add(AnObject);
    AnObject.FreeNotification(Self);
  end;
end;

procedure TgdcBase.RemoveDetailLink(AnObject: TgdcBase);
begin
  if Assigned(FDetailLinks) then
  begin
    if FDetailLinks.Remove(AnObject) >= 0 then
      AnObject.RemoveFreeNotification(Self);
  end;
end;

class function TgdcBase.GetChildrenClass(const ASubType: TgdcSubType;
  AnOL: TObjectList; const AnIncludeRoot: Boolean = True;
  const AnOnlyDirect: Boolean = False;
  const AnIncludeAbstract: Boolean = False): Boolean;

  procedure _Traverse(CE: TgdClassEntry; AnOL: TObjectList;
    AnIncludeAbstract: Boolean; AnOnlyDirect: Boolean);
  var
    I: Integer;
  begin
    if CE.Hidden then
      exit;

    if AnIncludeAbstract then
      AnOL.Add(CE)
    else if not TgdBaseEntry(CE).gdcClass.IsAbstractClass then
      AnOL.Add(CE);

    if not AnOnlyDirect then
      for I := 0 to CE.Count - 1 do
        _Traverse(CE.Children[I], AnOL, AnIncludeAbstract, AnOnlyDirect);
  end;

var
  I: Integer;
  CE: TgdClassEntry;
begin
  Assert(AnOL <> nil);

  AnOL.Clear;

  CE := gdClassList.Get(TgdBaseEntry, Self.ClassName, ASubType);

  if AnIncludeRoot then
  begin
    if AnIncludeAbstract then
      AnOL.Add(CE)
    else if not TgdBaseEntry(CE).gdcClass.IsAbstractClass then
      AnOL.Add(CE);
  end;

  for I := 0 to CE.Count - 1 do
    _Traverse(CE.Children[I], AnOL, AnIncludeAbstract, AnOnlyDirect);

  Result := AnOL.Count > 0;
end;

function TgdcBase.RelationByAliasName(const AnAliasName: String): String;
begin
  Result := QSelect.FieldByName(AnAliasName).AsXSQLVAR.relname;
end;

function TgdcBase.FieldNameByAliasName(const AnAliasName: String): String;
var
  RelationName, FieldName: String;
begin
  ParseFieldOrigin(FieldByName(AnAliasName).Origin, RelationName, FieldName);
  Result := FieldName;
end;

procedure TgdcBase.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBASE', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FSetTable = '' then
  begin
    SetInternalSQLParams(FQDelete, Buff);
    FQDelete.ExecQuery;
    FLastQuery := lqDelete;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBASE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FSetTable = '' then
  begin
    SetInternalSQLParams(QInsert, Buff);
    QInsert.ExecQuery;
    FLastQuery := lqInsert;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.CustomModify(Buff: Pointer);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  QModifySet: TIBSQL;
  DidActivate: Boolean;

  function GetModifySQLTextForSet: String;
  var
    I: Integer;
    SL: TStrings;
    KFL: TStringList;
    ModifiedFields: String;
    KeyFields: String;
    R: TatRelation;
  begin
    Result := '';
    //��������� ���� �� � ��� �������-���������
    if (FSetTable = '') or (atDatabase = nil) or (Database = nil) then
      Exit;

    R := atDatabase.Relations.ByRelationName(FSetTable);

    Assert(Assigned(R));

    //��������� ���� �� � ������� ��������� ��������� ��������� ����
    if Assigned(R.PrimaryKey) and
      (atDatabase.Relations.ByRelationName(FSetTable).PrimaryKey.ConstraintFields.Count > 1)
    then
    begin
      KFL := TStringList.Create;
      SL := TStringList.Create;
      try
        with atDatabase.Relations.ByRelationName(FSetTable).PrimaryKey do
        for I := 0 to ConstraintFields.Count - 1 do
          KFL.Add(AnsiUpperCase(Trim(ConstraintFields[I].FieldName)));

        Database.GetFieldNames(FSetTable, SL);

        ModifiedFields := '';
        for I := 0 to SL.Count - 1 do
        begin
          //� ������ SET �������� ��� ���� (� ��� ����� � ��������)
          if ModifiedFields > '' then
            ModifiedFields := ModifiedFields + ', ';
          ModifiedFields := ModifiedFields + SL[I] + ' = :NEW_' + cstSetPrefix + SL[I];
        end;

        KeyFields := '';
        for I := 0 to KFL.Count - 1 do
        begin
          if KeyFields > '' then
            KeyFields := KeyFields + ' AND ';
          KeyFields := KeyFields + KFL[I] + ' = :OLD_' + cstSetPrefix + KFL[I];
        end;

        Result := Format('UPDATE %0:s SET %1:s WHERE %2:s',
          [FSetTable, ModifiedFields, KeyFields]);

      finally
        KFL.Free;
        SL.Free;
      end;
    end;
  end;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBASE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  DidActivate := False;
  try
    DidActivate := ActivateTransaction;

    if FSetTable > '' then
    begin
      QModifySet := TIBSQL.Create(nil);
      try
        QModifySet.Transaction := Transaction;
        QModifySet.Close;
        QModifySet.SQL.Text := GetModifySQLTextForSet;
        if QModifySet.SQL.Text > '' then
        begin
          SetInternalSQLParams(QModifySet, Buff);
          QModifySet.ExecQuery;
        end;
      finally
        QModifySet.Free;
      end;
      FLastQuery := lqNone;
    end else
    begin
      SetInternalSQLParams(QModify, Buff);
      QModify.ExecQuery;
      FLastQuery := lqUpdate;
    end;

    if DidActivate and Transaction.InTransaction then
      Transaction.Commit;

  except
    if DidActivate and Transaction.InTransaction then
      Transaction.Rollback;
    raise;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

function TgdcBase.GetObjectName: String;
begin
  if Active then
  begin
    if AnsiCompareText(GetListField(SubType), GetKeyField(SubType)) = 0 then
      Result := GetDisplayName(SubType) + ', ����: ' + RUIDToStr(GetRUID)
    else
      Result := Trim(FieldByName(GetListField(SubType)).AsString);
  end else
    Result := FObjectName;
end;

procedure TgdcBase.SetObjectName(const Value: String);
begin
  if Value = '' then
  begin
    Close;
    FObjectName := '';
  end else
  begin
    if State in dsEditModes then
    begin
      FieldByName(GetListField(SubType)).AsString := Value;
    end
    else if State = dsInactive then
    begin
      FObjectName := Value;
    end
    else if HasSubSet('ByName') then
    begin
      Close;
      FObjectName := Value;
      Open;
    end else
      if not Locate(GetListField(SubType), Value, []) then
        raise EgdcException.CreateObj('Invalid object name specified', Self);
  end;
end;

procedure TgdcBase.SetRefreshSQLOn(SetOn: Boolean);
var
  WasActive: Boolean;
begin
  if FSetRefreshSQLOn <> SetOn then
  begin
    if FSQLInitialized then
    begin
      WasActive := Active;
      if WasActive then
        Close;

      if SetOn then
      begin
        if not (csDesigning in ComponentState) then
        begin
          RefreshSQL.Text := FSQLSetup.PrepareSQL(GetRefreshSQLText, Self.ClassName +
            '(' + Self.SubType + ')');
        end else
          RefreshSQL.Text := GetRefreshSQLText;

      end else
        RefreshSQL.Text := '';

      if WasActive then
        Open;
    end;

    FSetRefreshSQLOn := SetOn;
  end;
end;

procedure TgdcBase.RevertRecord;
var
  I: Integer;
begin
  Assert(sSubDialog in FBaseState);
  Assert(State in dsEditModes);
  if FOldValues <> nil then
  begin
    for I := FOldValues.Count - 1 downto 0 do
    begin
      if (FOldValues[I] as TFieldValue).IsNull then
        FieldByName((FOldValues[I] as TFieldValue).FieldName).Clear
      else
        FieldByName((FOldValues[I] as TFieldValue).FieldName).AsString :=
          (FOldValues[I] as TFieldValue).Value;
    end;
    FOldValues.Clear;
  end;  
end;

procedure TgdcBase.SetSubType(const Value: TgdcSubType);
begin
  if FSubType <> Value then
  begin
    if (FSubType > '') and (ComponentState * [csDesigning, csLoading] = []) then
      raise EgdcException.CreateObj('Can not change subtype', Self);

    if not CheckSubType(Value) then
    begin
      if (StrIPos('usr_', Self.Name) = 1) or (StrIPos('usrg_', Self.Name) = 1) then
      begin
        if (Self.ClassName = 'TgdcAttrUserDefined')
          or (Self.ClassName = 'TgdcAttrUserDefinedTree')
          or(Self.ClassName = 'TgdcAttrUserDefinedLBRBTree') then
        begin
          gdClassList.Add(Self.ClassName, Value, Self.SubType,
            TgdAttrUserDefinedEntry, '')
        end else
          gdClassList.Add(Self.ClassName, Value, Self.SubType,
            CgdClassEntry(gdClassList.Get(TgdBaseEntry, Self.ClassName, Self.SubType).ClassType), '')
      end
      else
        raise EgdcException.CreateObj('Invalid subtype specified', Self);
    end;

    Close;
    FSubType := Value;
    FGroupID := -1;
    FgdcTableInfos := GetTableInfos(FSubType);
    FModifyFromStream := NeedModifyFromStream(SubType);
    if Assigned(FQueryFilter) then
      FQueryFilter.Name := 'flt_' + RemoveProhibitedSymbols(FSubType) + System.copy(ClassName, 2, 255);
    FSQLInitialized := False;
  end;
end;

constructor TgdcBase.CreateSubType(AnOwner: TComponent;
  const ASubType: TgdcSubType; const ASubSet: TgdcSubSet = 'All');
begin
  Create(AnOwner);
  SubType := ASubType; // ��� ������ ���� ����������� ������������ ��������!
  if ASubSet = '' then
    SubSet := 'All'
  else
    SubSet := ASubSet;
end;

procedure TgdcBaseManager.SetExplorer(const Value: IgdcBase);
begin
  if Assigned(FExplorer) then
    FExplorer.RemoveFreeNotification(Self);

  if Value <> nil then
  begin
    FExplorer := Value.GetObject as TgdcBase;
    FExplorer.FreeNotification(Self);

    LoadSecDescArr(FExplorer);
  end else
    FExplorer := nil;
end;

procedure TgdcBaseManager.UnPackStream(SourceStream, DestStream: TStream);
var
  Z: TZDecompressionStream;
begin
  Z := TZDecompressionStream.Create(SourceStream);
  try
    DestStream.CopyFrom(Z, 0)
  finally
    Z.Free
  end
end;

procedure TgdcBaseManager.UpdateRUIDByXID(const AnID, AXID, ADBID: TID; const AModified: TDateTime;
  const AnEditorKey: Integer; Transaction: TIBTransaction);
var
  DidActivate: Boolean;
  Tr: TIBTransaction;
  WasCreate: Boolean;
begin
  if Assigned(Transaction) then
  begin
    WasCreate := False;
    Tr := Transaction;
  end else
  begin
    WasCreate := True;
    Tr := TIBTransaction.Create(nil);
    Tr.DefaultDatabase := Self.Database;
  end;
  try
    FIBSQL.Close;
    DidActivate := not Tr.InTransaction;
    try
      if DidActivate then Tr.StartTransaction;

      FIBSQL.Transaction := Tr;
      FIBSQL.SQL.Text := cst_sql_UpdateRUIDByXID;
      FIBSQL.ParamByName(fnid).AsInteger := AnID;
      FIBSQL.ParamByName(fnxid).AsInteger := AXID;
      FIBSQL.ParamByName(fndbid).AsInteger := ADBID;
      FIBSQL.ParamByName(fneditorkey).AsInteger := AnEditorKey;
      FIBSQL.ParamByName(fnmodified).AsDateTime := AModified;

      FIBSQL.ExecQuery;
      FIBSQL.Close;

      if DidActivate and Tr.InTransaction then
        Tr.Commit;

      RemoveRUIDFromCache(AXID, ADBID);
    except
      if DidActivate and Tr.InTransaction then
        Tr.Rollback;
      raise;
    end;
  finally
    if WasCreate then
      Tr.Free;
  end;
end;

function TgdcBaseManager.GetRUIDRecByID(const AnID: TID;
  Transaction: TIBTransaction): TRUIDRec;
begin
  FIBSQL.Close;
  try
    if Assigned(Transaction) and Transaction.InTransaction then
      FIBSQL.Transaction := Transaction
    else
      FIBSQL.Transaction := ReadTransaction;

    FIBSQL.SQL.Text := cst_sql_SelectRUIDByID;
    FIBSQL.ParamByName(fnID).AsInteger := AnID;
    FIBSQL.ExecQuery;

    if FIBSQL.EOF then
    begin
      Result.ID := AnID;
      Result.Modified := 0;
      Result.EditorKey := -1;
      Result.XID := -1;
      Result.DBID := -1;
    end else
    begin
      Result.ID := FIBSQL.FieldByName(fnid).AsInteger;
      Result.Modified := FIBSQL.FieldByName(fnmodified).AsDateTime;
      Result.EditorKey := FIBSQL.FieldByName(fneditorkey).AsInteger;
      Result.XID := FIBSQL.FieldByName(fnxid).AsInteger;
      Result.DBID := FIBSQL.FieldByName(fndbid).AsInteger;
    end;
  finally
    FIBSQL.Close;
  end;
end;

procedure TgdcBaseManager.InsertRUID(const AnID, AXID, ADBID: TID;
  const AModified: TDateTime; const AnEditorKey: Integer;
  Transaction: TIBTransaction);
var
  DidActivate: Boolean;
  Tr: TIBTransaction;
  WasCreate: Boolean;
  S: String;
begin
  if AXID < cstUserIDStart then
    exit;

  if Assigned(Transaction) then
  begin
    WasCreate := False;
    Tr := Transaction;
  end else
  begin
    WasCreate := True;
    Tr := TIBTransaction.Create(nil);
  end;

  try
    if WasCreate then
      Tr.DefaultDatabase := Self.Database;

    FIBSQL.Close;
    DidActivate := not Tr.InTransaction;
    try
      if DidActivate then
        Tr.StartTransaction;

      FIBSQL.Transaction := Tr;
      FIBSQL.SQL.Text :=
        'INSERT INTO gd_ruid (id, xid, dbid, editorkey, modified) ' +
        '  VALUES (:id, :xid, :dbid, :editorkey, :modified) ';
      FIBSQL.ParamByName('id').AsInteger := AnID;
      FIBSQL.ParamByName('xid').AsInteger := AXID;
      FIBSQL.ParamByName('dbid').AsInteger := ADBID;
      FIBSQL.ParamByName('editorkey').AsInteger := AnEditorKey;
      FIBSQL.ParamByName('modified').AsDateTime := AModified;

      try
        FIBSQL.ExecQuery;
      except
        FIBSQL.SQL.Text :=
          'SELECT id FROM gd_ruid WHERE xid = :xid AND dbid = :dbid';
        FIBSQL.ParamByName('xid').AsInteger := AXID;
        FIBSQL.ParamByName('dbid').AsInteger := ADBID;
        FIBSQL.ExecQuery;

        if not FIBSQL.Eof then
          raise EgdcException.Create(
            '������� �������� ������������� ���� � ������� GD_RUID.'#13#10 +
            'ID=' + IntToStr(AnID) + ', XID=' + IntToStr(AXID) + ', DBID=' + IntToStr(ADBID));

        RemoveRUIDFromCache(AXID, ADBID);

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'UPDATE gd_ruid SET id = :id, editorkey = :editorkey, modified = :modified ' +
          'WHERE xid = :xid AND dbid = :dbid ';
        FIBSQL.ParamByName('id').AsInteger := AnID;
        FIBSQL.ParamByName('xid').AsInteger := AXID;
        FIBSQL.ParamByName('dbid').AsInteger := ADBID;
        FIBSQL.ParamByName('editorkey').AsInteger := AnEditorKey;
        FIBSQL.ParamByName('modified').AsDateTime := AModified;
        FIBSQL.ExecQuery;
        FIBSQL.Close;

        IBLogin.AddEvent('��� ������� ������� RUID ��� ID=' + IntToStr(AnID) +
          ' ����������, ��� ������ � ����� ID ��� ����������.',
          'TgdcBaseManager');
      end;

      if DidActivate and Tr.InTransaction then
      begin
        Tr.Commit;

        if CacheList <> nil then
        begin
          S := RUIDToStr(AXID, ADBID);
          if not CacheList.Has(S) then
            CacheList.Add(S, AnID);
        end;
      end;
    except
      if DidActivate and Tr.InTransaction then
        Tr.Rollback;
      raise;
    end;
  finally
    if WasCreate then
      Tr.Free;
  end;
end;

procedure TgdcBaseManager.DeleteRUIDByID(const AnID: TID;
  Transaction: TIBTransaction);
var
  DidActivate: Boolean;
  Tr: TIBTransaction;
  WasCreate: Boolean;
begin
  if Assigned(Transaction) then
  begin
    WasCreate := False;
    Tr := Transaction;
  end else
  begin
    WasCreate := True;
    Tr := TIBTransaction.Create(nil);
    Tr.DefaultDatabase := Self.Database;
  end;
  try
    FIBSQL.Close;
    DidActivate := not Tr.InTransaction;
    try
      if DidActivate then Tr.StartTransaction;

      FIBSQL.Transaction := Tr;
      FIBSQL.SQL.Text := cst_sql_DeleteRUIDByID;
      FIBSQL.ParamByName(fnID).AsInteger := AnID;
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      if DidActivate and Tr.InTransaction then
        Tr.Commit;

      if CacheList <> nil then
        CacheList.RemoveData(AnID);
    except
      if DidActivate and Tr.InTransaction then
        Tr.Rollback;
      raise;
    end;
  finally
    if WasCreate then
      Tr.Free;
  end;
end;

procedure TgdcBaseManager.UpdateRUIDByID(const AnID, AXID, ADBID: TID;
  const AModified: TDateTime; const AnEditorKey: Integer;
  Transaction: TIBTransaction);
var
  DidActivate: Boolean;
  Tr: TIBTransaction;
  WasCreate: Boolean;
begin
  if Assigned(Transaction) then
  begin
    WasCreate := False;
    Tr := Transaction;
  end else
  begin
    WasCreate := True;
    Tr := TIBTransaction.Create(nil);
  end;
  try
    if WasCreate then
      Tr.DefaultDatabase := Self.Database;

    FIBSQL.Close;
    DidActivate := not Tr.InTransaction;
    try
      if DidActivate then Tr.StartTransaction;

      FIBSQL.Transaction := Tr;
      FIBSQL.SQL.Text := cst_sql_UpdateRUIDByID;
      FIBSQL.ParamByName(fnxid).AsInteger := AXID;
      FIBSQL.ParamByName(fndbid).AsInteger := ADBID;
      FIBSQL.ParamByName(fnid).AsInteger := AnID;
      FIBSQL.ParamByName(fneditorkey).AsInteger := AnEditorKey;
      FIBSQL.ParamByName(fnmodified).AsDateTime := AModified;

      FIBSQL.ExecQuery;
      FIBSQL.Close;

      if DidActivate and Tr.InTransaction then
        Tr.Commit;

      if CacheList <> nil then
        CacheList.RemoveData(AnID);
    except
      if DidActivate and Tr.InTransaction then
        Tr.Rollback;
      raise;
    end;
  finally
    if WasCreate then
      Tr.Free;
  end;
end;

procedure TgdcBaseManager.ExecSingleQuery(const S: String; const Transaction: TIBTransaction);
begin
  ExecSingleQuery(S, varNull, Transaction);
end;

procedure TgdcBaseManager.ExecSingleQuery(const S: String; Param: Variant; const Transaction: TIBTransaction);
var
  q: TIBSQL;
  I, J, CutOff: Integer;
  DidActivate: Boolean;
  Tr: TIBTransaction;
  St: String;
begin
  Tr := Transaction;
  if Tr = nil then
  begin
    Tr := TIBTransaction.Create(nil);
    Tr.DefaultDatabase := Database;
  end;
  try
    DidActivate := False;
    q := TIBSQL.Create(nil);
    try
      q.Database := Database;
      q.Transaction := Tr;
      DidActivate := not Tr.InTransaction;
      if DidActivate then Tr.StartTransaction;
      try
        CutOff := 5;
        repeat
          try
            q.Close;
            q.SQL.Text := S;
            q.Prepare;
            if q.Params.Count > 0 then
            begin
              if not VarIsArray(Param) then
                Param := VarArrayOf([Param]);
              if q.Params.Count > (VarArrayHighBound(Param, 1) + 1) then
              begin
                St := '';
                J := 0;
                for I := 0 to q.Params.Count - 1 do
                begin
                  if Pos(q.Params[I].Name + ',', St) > 0 then
                    continue;
                  q.Params[I].AsVariant := Param[J];
                  St := St + q.Params[I].Name + ',';
                  Inc(J);
                end;
                if J <> (VarArrayHighBound(Param, 1) + 1) then
                  raise Exception.Create('Invalid param count');
              end
              else if q.Params.Count = (VarArrayHighBound(Param, 1) + 1) then
              begin
                for I := 0 to q.Params.Count - 1 do
                begin
                  q.Params[I].AsVariant := Param[I];
                end;
              end else
                raise Exception.Create('Invalid param count');
            end;
            q.ExecQuery;
            CutOff := 0;
          except
              on E: EIBError do
              begin
                if (E.IBErrorCode = isc_lock_conflict) or (E.IBErrorCode = isc_deadlock) then
                begin
                  if (CutOff > 1) and DidActivate {and AllowCloseTransaction} then
                  begin
                    Tr.Rollback;
                    Sleep(500);
                    Dec(CutOff);
                    Tr.StartTransaction;
                  end else
                  begin
                    MessageBox(Application.Handle, PChar(
                      '������ �������� ����������. ������ �� ����� ���� �������� ������.'#13#10#13#10 +
                      '������ ������������ �������������: ' + GetUserByTransaction(StatusVectorArray[9]) + #13#10 +
                      '��������� �������:'#13#10 +
                      '  1. ������ ������������ � ���� ������ � ������ ������ �������� ������.'#13#10 +
                      '  2. �������� ������ �������� � ������ ������ � ������ ���� ���������. '#13#10 +
                      '  3. ��������� ������ ������ �� ����� ��������� ������ ������, �������'#13#10 +
                      '     ����������� ������ ������������ ��� ������� ���������� � ������ ���� ���������.'#13#10#13#10 +
                      '���������� ��������� ������ ����� ��� �������� ���� (������) � ������� ������� ������'#13#10 +
                      '��-�����������, �� ��������� ������� ����� ���������� ���� �� ������.'#13#10 +
                      ''#13#10 +
                      '� ������ ���������� �������� ���������� � ��������������.'),
                      '��������',
                      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
                    Abort;
                  end;
                end else
                  raise;
              end else
                raise;
          end;
        until CutOff = 0;
      except
        if DidActivate and Tr.InTransaction then
          Tr.RollBack;
        raise;
      end;

      if DidActivate and Tr.InTransaction then
        Tr.Commit;
    finally
      if DidActivate and Tr.InTransaction then
        Tr.Rollback;
      q.Free;
    end;
  finally
    if Transaction = nil then
      Tr.Free;
  end;
end;

function TgdcBaseManager.ExecSingleQueryResult(const S: String;
  Param: Variant; out Res: OleVariant; const Transaction: TIBTransaction): Boolean;
var
  q: TIBSQL;
  I, J, CutOff: Integer;
  DidActivate: Boolean;
  Tr: TIBTransaction;
  St: String;
begin
  Result := False;
  Tr := Transaction;
  if Tr = nil then
  begin
    Tr := TIBTransaction.Create(nil);
    Tr.DefaultDatabase := Database;
  end;
  try
    DidActivate := False;
    q := TIBSQL.Create(nil);
    try
      q.Transaction := Tr;
      DidActivate := not Tr.InTransaction;
      if DidActivate then Tr.StartTransaction;
      try
        CutOff := 5;
        repeat
          try
            q.Close;
            q.SQL.Text := S;
            q.Prepare;
            if q.Params.Count > 0 then
            begin
              if not VarIsArray(Param) then
                Param := VarArrayOf([Param]);
              if q.Params.Count > (VarArrayHighBound(Param, 1) + 1) then
              begin
                St := ',';
                J := 0;
                for I := 0 to q.Params.Count - 1 do
                begin
                  if Pos(',' + q.Params[I].Name + ',', St) > 0 then
                    continue;
                  q.Params[I].AsVariant := Param[J];
                  St := St + q.Params[I].Name + ',';
                  Inc(J);
                end;
                if J <> (VarArrayHighBound(Param, 1) + 1) then
                  raise Exception.Create('Invalid param count');
              end
              else if q.Params.Count = (VarArrayHighBound(Param, 1) + 1) then
              begin
                for I := 0 to q.Params.Count - 1 do
                begin
                  q.Params[I].AsVariant := Param[I];
                end;
              end else
                raise Exception.Create('Invalid param count');
            end;
            q.ExecQuery;
            CutOff := 0;

            if q.EOF then
              Res := Unassigned
            else
            begin
              Res := VarArrayCreate([0, q.Current.Count - 1, 0, 0], varVariant);
              J := 0;
              while not q.EOF do
              begin
                for I := 0 to q.Current.Count - 1 do
                begin
                  if q.Fields[I].IsNull then
                  begin
                    Res[I, J] := q.Fields[I].AsVariant;
                  end else
                  begin
                    if (q.Fields[I].Data.SQLType and (not 1)) = SQL_BLOB then
                    begin
                      Res[I, J] := q.Fields[I].AsString;
                    end else
                    begin
                      if (q.Fields[I].Data.SQLType and (not 1)) <> SQL_INT64 then
                        Res[I, J] := q.Fields[I].AsVariant
                      else
                        Res[I, J] := q.Fields[I].AsString;
                    end;
                  end;
                end;
                q.Next;
                if not q.EOF then
                begin
                  Inc(J);
                  VarArrayReDim(Res, J);
                end;
              end;
              Result := True;
            end;

          except
            on E: EIBError do
            begin
              if (E.IBErrorCode = isc_lock_conflict) or (E.IBErrorCode = isc_deadlock) then
              begin
                if (CutOff > 1) and DidActivate {and AllowCloseTransaction} then
                begin
                  Tr.Rollback;
                  Sleep(500);
                  Dec(CutOff);
                  Tr.StartTransaction;
                end else
                begin
                  MessageBox(Application.Handle, PChar(
                    '������ �������� ����������. ������ �� ����� ���� �������� ������.'#13#10#13#10 +
                    '������ ������������ �������������: ' + GetUserByTransaction(StatusVectorArray[9]) + #13#10 +
                    '��������� �������:'#13#10 +
                    '  1. ������ ������������ � ���� ������ � ������ ������ �������� ������.'#13#10 +
                    '  2. �������� ������ �������� � ������ ������ � ������ ���� ���������. '#13#10 +
                    '  3. ��������� ������ ������ �� ����� ��������� ������ ������, �������'#13#10 +
                    '     ����������� ������ ������������ ��� ������� ���������� � ������ ���� ���������.'#13#10#13#10 +
                    '���������� ��������� ������ ����� ��� �������� ���� (������) � ������� ������� ������'#13#10 +
                    '��-�����������, �� ��������� ������� ����� ���������� ���� �� ������.'#13#10 +
                    ''#13#10 +
                    '� ������ ���������� �������� ���������� � ��������������.'),
                    '��������',
                    MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
                  Abort;
                end;
              end else
                raise;
            end else
              raise;
          end;
        until CutOff = 0;
      except
        if DidActivate and Tr.InTransaction then
          Tr.RollBack;
        raise;
      end;
    finally
      if DidActivate and Tr.InTransaction then
        Tr.Commit;
      q.Free;
    end;
  finally
    if Transaction = nil then
      Tr.Free;
  end;
end;

procedure TgdcBaseManager.LoadSecDescArr(AnExplorer: TgdcBase);
var
  I: Integer;
  Bm: String;
  P: PString;
  C: TPersistentClass;
begin
  ClearSecDescArr;
  SetLength(FSecDescArr, AnExplorer.RecordCount, 5);
  AnExplorer.DisableControls;
  try
    I := 0;
    Bm := AnExplorer.Bookmark;
    AnExplorer.First;
    while not AnExplorer.EOF do
    begin
      if AnExplorer.FieldByName('classname').AsString > '' then
      begin
        C := GetClass(AnExplorer.FieldByName('classname').AsString);
        if C <> nil then
        begin
          FSecDescArr[I, 0] := Integer(C);
          New(P);
          P^ := AnExplorer.FieldByname('subtype').AsString;
          FSecDescArr[I, 1] := Integer(P);
          FSecDescArr[I, 2] := AnExplorer.FieldByname('aview').AsInteger;
          FSecDescArr[I, 3] := AnExplorer.FieldByname('achag').AsInteger;
          FSecDescArr[I, 4] := AnExplorer.FieldByname('afull').AsInteger;
          Inc(I);
        end;
      end;

      AnExplorer.Next;
    end;
    AnExplorer.Bookmark := Bm;
  finally
    AnExplorer.EnableControls;
  end;

  SetLength(FSecDescArr, I, 5);
  SortSecDescArr;
  RemoveDuplicates;
end;

procedure TgdcBaseManager.ClearSecDescArr;
var
  I: Integer;
  P: PString;
begin
  for I := 0 to High(FSecDescArr) do
  begin
    P := Pointer(FSecDescArr[I, 1]);
    Dispose(P);
  end;
  FSecDescArr := nil;
end;

procedure TgdcBaseManager.SortSecDescArr;

  procedure QuickSort(iLo, iHi: Integer);

    function GetS(Ind: Integer): String;
    begin
       Result := Format('%10d%s', [FSecDescArr[Ind, 0], PString(FSecDescArr[Ind, 1])^]);
    end;

  var
    Lo, Hi, I, A: Integer;
    Mid: String;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := GetS((Lo + Hi) div 2);
    repeat
      while GetS(Lo) < Mid do Inc(Lo);
      while GetS(Hi) > Mid do Dec(Hi);
      if Lo <= Hi then
      begin
        for I := 0 to 4 do
        begin
          A := FSecDescArr[Lo, I];
          FSecDescArr[Lo, I] := FSecDescArr[Hi, I];
          FSecDescArr[Hi, I] := A;
        end;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then QuickSort(iLo, Hi);
    if Lo < iHi then QuickSort(Lo, iHi);
  end;

begin
  if High(FSecDescArr) > Low(FSecDescArr) then
    QuickSort(Low(FSecDescArr), High(FSecDescArr));
end;

procedure TgdcBaseManager.RemoveDuplicates;
var
  I, J, K: Integer;
  P1, P2: PString;
begin
  K := 0;
  I := Low(FSecDescArr) + 1;
  while I <= (High(FSecDescArr) - K) do
  begin
    if FSecDescArr[I - 1, 0] = FSecDescArr[I, 0] then
    begin
      P1 := PString(FSecDescArr[I - 1, 1]);
      P2 := PString(FSecDescArr[I, 1]);
      if P1^ = P2^ then
      begin
        Dispose(P2);
        for J := I + 1 to High(FSecDescArr) do
        begin
          FSecDescArr[J - 1, 0] := FSecDescArr[J, 0];
          FSecDescArr[J - 1, 1] := FSecDescArr[J, 1];
          FSecDescArr[J - 1, 2] := FSecDescArr[J, 2];
          FSecDescArr[J - 1, 3] := FSecDescArr[J, 3];
          FSecDescArr[J - 1, 4] := FSecDescArr[J, 4];
        end;
        Inc(K);
        continue;
      end;
    end;
    Inc(I);
  end;
  if K > 0 then
    SetLength(FSecDescArr, High(FSecDescArr) + 1 - K, 5);
end;

function TgdcBaseManager.IndexOfClass(C: TClass;
  const ASubType: TgdcSubType): Integer;

  function Find(Lo, Hi: Integer): Integer;
  var
    Mid: Integer;
  begin
    if Hi < Lo then
      Result := -1
    else
    begin
      Mid := (Lo + Hi) div 2;
      if (Integer(C) < FSecDescArr[Mid, 0])
        or ((Integer(C) = FSecDescArr[Mid, 0])
          and (ASubType < PString(FSecDescArr[Mid, 1])^)) then
      begin
        Result := Find(Lo, Mid - 1);
      end else if (Integer(C) > FSecDescArr[Mid, 0])
        or ((Integer(C) = FSecDescArr[Mid, 0])
          and (ASubType > PString(FSecDescArr[Mid, 1])^)) then
      begin
        Result := Find(Mid + 1, Hi);
      end else
      begin
        Result := Mid;
      end;
    end;
  end;

begin
  Result := Find(Low(FSecDescArr), High(FSecDescArr));
end;

function TgdcBaseManager.Class_TestUserRights(C: TClass;
  const ASubType: TgdcSubType; const AnAccess: Integer): Boolean;
var
  I: Integer;
begin
  I := IndexOfClass(C, ASubType);
  if (I = -1)
    or (Assigned(IBLogin) and (IBLogin.IsUserAdmin)) then
  begin
    Result := True;
  end else
  begin
    Result := (FSecDescArr[I, 4] and IBLogin.InGroup) <> 0;
    if (not Result) and (AnAccess < 2) then
      Result := (FSecDescArr[I, 3] and IBLogin.InGroup) <> 0;
    if (not Result) and (AnAccess < 1) then
      Result := (FSecDescArr[I, 2] and IBLogin.InGroup) <> 0;
  end;
end;

procedure TgdcBaseManager.Class_GetSecDesc(C: TClass;
  const ASubType: TgdcSubType; out AView, AChag, AFull: Integer);
var
  I: Integer;
begin
  I := IndexOfClass(C, ASubType);
  if I = -1 then
  begin
    AView := -1;
    AChag := -1;
    AFull := -1;
  end else
  begin
    AView := FSecDescArr[I, 2];
    AChag := FSecDescArr[I, 3];
    AFull := FSecDescArr[I, 4];
  end;
end;

function TgdcBase.GetSubType: TgdcSubType;
begin
  Result := FSubType;
end;

function TgdcBase.ParentHandle: Integer;
begin
  Result := 0;

  if (FDlgStack.Count > 0) and (FDlgStack.Peek <> nil) and (FDlgStack.Peek is TForm) then
    Result := (FDlgStack.Peek as TForm).Handle
  else if Assigned(FgdcDataLink) and (FgdcDataLink.DataSet is TgdcBase) then
    Result := (FgdcDataLink.DataSet as TgdcBase).ParentHandle;

  if (Result = 0) and Assigned(FParentForm) then
    Result := FParentForm.Handle;
end;

procedure TgdcBase.Post;

  function ViolationOfPrimaryKey(const S: String): Boolean;
  var
    R: OleVariant;
    P: PChar;
  begin
    P := Pointer(StatusVectorArray[3]);
    ExecSingleQueryResult(
      'SELECT rdb$constraint_name FROM rdb$relation_constraints WHERE rdb$constraint_name = :N ' +
      'AND rdb$constraint_type = ''PRIMARY KEY'' ',
      String(P),
      R);
    Result := not VarIsEmpty(R);
  end;

var
  I, C: Integer;
  Det: TgdcBase;
  F: TField;
begin
  if sLoadFromStream in BaseState then
  begin
    for I := 0 to FieldCount - 1 do
    begin
      if Fields[I].Required and Fields[I].IsNull and (Fields[I].DataType = ftString)
      then
      begin
        {���� �� ��������� �� ������ ��������� ������������ ������, ������� ����
         �����-�� ������ �������, �� IB ��������� �� ��� NULL. �������� ������}
        Fields[I].Value := ' ';
      end;
    end;
  end;

  if FDataTransfer then
    inherited Post
  else begin

    if (State = dsEdit) and (sDialog in FBaseState) and
      (not Modified) then
    begin
      Include(FBaseState, sPost);
      try
        Cancel;
      finally
        Exclude(FBaseState, sPost);
      end;
    end else
    begin
      for I := 0 to FDetailLinks.Count - 1 do
      begin
        Det := FDetailLinks[I] as TgdcBase;
        if (Det.State = dsInsert)
          and (AnsiCompareText(Det.GetFieldNameComparedToParam(Det.DetailField), Det.GetKeyField(Det.SubType)) = 0)
          and (Det.Transaction = Self.Transaction)
          and (AnsiCompareText(Det.MasterField, GetKeyField(SubType)) <> 0) then
        begin
          F := FindField(Det.MasterField);
          if F <> nil then
          begin
            FIgnoreDataSet.Add(Det);
            try
              F.Clear;
              inherited Post;
              Edit;
              F.AsInteger := Det.ID;
              Det.Post;
            finally
              FIgnoreDataSet.Remove(Det);
            end;
          end;
        end;
      end;

      if (sMultiple in BaseState) and (sDialog in BaseState) then
      begin
        PrepareSLChanged;
      end;

      // ���������������� ������ ��� � ����������� ����� � ������ Delete!
      C := 0;
      repeat
        try
          inherited Post;
          break;
        except
          on E: EIBError do
          begin
            if (E.IBErrorCode = isc_unique_key_violation) and (C = 0)
              and ViolationOfPrimaryKey(E.Message) then
            begin
              FieldByName(GetKeyField(SubType)).AsInteger := GetNextID(True, True);
              Inc(C);
            end
            else if ((E.IBErrorCode = isc_lock_conflict) or (E.IBErrorCode = isc_deadlock))
              and (sView in BaseState) then
            begin
              MessageBox(ParentHandle, PChar(
                '��������� �������� ��� ������ � ���� ������.'#13#10 +
                '������ ������������ �������������: ' + GetUserByTransaction(StatusVectorArray[9]) + #13#10 +
                '��������, ������ ���������� � ������� ������ �������'#13#10 +
                '��� ���� ������� �������� (�������) ������ �������������.'#13#10#13#10 +
                '�������� ��������������, �������� ������ � ����������'#13#10 +
                '��������� �������� �����.'#13#10#13#10 +
                '� ������ ���������� ������ �������� ����������'#13#10 +
                '� ���������� ��������������.'),
                '��������',
                MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
              Abort;
            end else
              raise;
          end;
        else
          raise;
        end;
      until False;

      FDSModified := Transaction.InTransaction;
      if HasSubSet('OnlySelected') then
        FSelectedID.Add(ID, True);
    end;
    if FOldValues <> nil then
      FOldValues.Clear;
  end;
end;

procedure TgdcBase.Assign(Source: TPersistent);
var
  I: Integer;
begin
  if not Self.InheritsFrom(Source.ClassType) then
    raise EgdcException.Create('Object of invalid class specified');

  if Active then
    raise EgdcException.Create('Object is not closed');

  Transaction := (Source as TgdcBase).Transaction;
  SubType := (Source as TgdcBase).SubType;
  SubSet := (Source as TgdcBase).SubSet;

  for I := 0 to (Source as TgdcBase).Params.Count - 1 do
  begin
    ParamByName((Source as TgdcBase).Params[I].Name).AsString :=
      (Source as TgdcBase).Params[I].AsString;
  end;
end;

procedure TgdcBase.SyncField(Field: TField);
begin
  if ((sDialog in FBaseState)
    and (FDlgStack.Count > 0)
    and (FDlgStack.Peek is Tgdc_dlgG))
    and ((FDlgStack.Peek as Tgdc_dlgG).gdcObject <> nil) then // ��������� ������� -- ��� ��������� ������� ��������� ������ ��� Setup ������� ��� ���
  begin
    if FSyncList = nil then
      FSyncList := TList.Create;

    if FSyncList.IndexOf(Field) = -1 then
    begin
      FSyncList.Add(Field);
      try
        if (FDlgStack.Peek as Tgdc_dlgG).CallSyncField(Field, FSyncList) then
          (FDlgStack.Peek as Tgdc_dlgG).SyncField(Field, FSyncList);
      finally
        FSyncList.Remove(Field);
      end;
    end;

    if (not (sSyncControls in FBaseState)) then
    begin
      Include(FBaseState, sSyncControls);
      try
        (FDlgStack.Peek as Tgdc_dlgG).SyncControls;
      finally
        Exclude(FBaseState, sSyncControls);
      end;
    end;
  end
  else if (MasterSource <> nil) and (MasterSource.DataSet is TgdcBase) then
  begin
    (MasterSource.DataSet as TgdcBase).SyncField(Field);
  end;
end;

function TgdcBase.FieldChanged(const AFieldName: String): Boolean;
var
  I: Integer;
begin
  Result := (FOldValues = nil) or (FOldValues.Count = 0);
  if not Result then
  begin
    for I := 0 to FOldValues.Count - 1 do
      if AnsiCompareText((FOldValues[I] as TFieldValue).FieldName, AFieldName) = 0 then
      begin
        Result := True;
        exit;
      end;
  end;    
end;

function TgdcBase.GetCustomProcess: TgsCustomProcesses;
begin
  Result := FCustomProcess;
end;

procedure TgdcBase.SetCustomProcess(const Value: TgsCustomProcesses);
begin
  FCustomProcess := Value;
end;

procedure TgdcBase._CustomInsert(Buff: Pointer);
var
  OldState: TDataSetState;
  CE: TgdClassEntry;

  procedure UserDefinedCustomInsert(BE: TgdBaseEntry);
  var
    I: Integer;
    RelationName, FieldName: String;
    F, V: String;
  begin
    if (BE.Parent <> nil) and (BE.Parent <> BE.GetRootSubType) then
      UserDefinedCustomInsert(BE.Parent as TgdBaseEntry);

    if BE.DistinctRelation <> TgdBaseEntry(BE.Parent).DistinctRelation then
    begin
      if BE is TgdDocumentEntry then
        F := 'DOCUMENTKEY,'
      else
        F := 'INHERITEDKEY,';

      V := ':NEW_ID,';

      for I := 0 to FieldCount - 1 do
      begin
        ParseFieldOrigin(Fields[I].Origin, RelationName, FieldName);

        if RelationName = BE.DistinctRelation then
        begin
          F := F + FieldName + ',';
          V := V + ':NEW_' + Fields[I].FieldName + ',';
        end;
      end;

      SetLength(F, Length(F) - 1);
      SetLength(V, Length(V) - 1);

      CustomExecQuery('INSERT INTO ' + BE.DistinctRelation +
        ' (' + F + ') VALUES (' + V + ')', Buff, False);
    end
  end;

begin
  OldState := State;
  CustomInsert(Buff);
  CE := gdClassList.Get(TgdBaseEntry, Self.ClassName, SubType);
  if (not (CE is TgdStorageEntry)) and (CE <> CE.GetRootSubType) then
    UserDefinedCustomInsert(CE as TgdBaseEntry);
  DoAfterCustomProcess(Buff, cpInsert);
  if OldState <> State then
    MessageBox(ParentHandle,
      PChar('����������� ��������� ��������� ������ ������!'#13#10#13#10 +
      '��. http://code.google.com/p/gedemin/issues/detail?id=1702'),
      '��������',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
end;

procedure TgdcBase._CustomModify(Buff: Pointer);
var
  OldState: TDataSetState;
  CE: TgdClassEntry;

  procedure UserDefinedCustomModify(BE: TgdBaseEntry; const LinkFieldName: String);
  var
    I: Integer;
    RelationName, FieldName: String;
    S: String;
  begin
    if (BE.Parent <> nil) and (BE.Parent <> BE.GetRootSubType) then
      UserDefinedCustomModify(BE.Parent as TgdBaseEntry, LinkFieldName);

    if BE.DistinctRelation <> TgdBaseEntry(BE.Parent).DistinctRelation then
    begin
      S := '';
      for I := 0 to FieldCount - 1 do
      begin
        ParseFieldOrigin(Fields[I].Origin, RelationName, FieldName);

        if (RelationName = BE.DistinctRelation) and FieldChanged(Fields[I].FieldName) then
          S := S + FieldName + ' = :NEW_' + Fields[I].FieldName + ',';
      end;

      if S > '' then
      begin
        SetLength(S, Length(S) - 1);
        CustomExecQuery('UPDATE ' + BE.DistinctRelation + ' SET ' +
          S + ' WHERE ' + LinkFieldName + ' = :OLD_ID', Buff, False);
      end;
    end;
  end;
  
begin
  OldState := State;
  CustomModify(Buff);
  CE := gdClassList.Get(TgdBaseEntry, Self.ClassName, SubType);
  if (not (CE is TgdStorageEntry)) and (CE <> CE.GetRootSubType) then
  begin
    if CE is TgdDocumentEntry then
      UserDefinedCustomModify(CE as TgdBaseEntry, 'documentkey')
    else
      UserDefinedCustomModify(CE as TgdBaseEntry, 'inheritedkey');
  end;
  DoAfterCustomProcess(Buff, cpModify);
  if OldState <> State then
    MessageBox(ParentHandle,
      PChar('����������� ��������� ��������� ������ ������!'#13#10#13#10 +
      '��. http://code.google.com/p/gedemin/issues/detail?id=1702'),
      '��������',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
end;

procedure TgdcBase._CustomDelete(Buff: Pointer);
begin
  if sLoadFromStream in BaseState then
    CustomDelete(Buff)
  else
    try
      CustomDelete(Buff);
    except
      on Ex: EIBError do
      begin
        if (Ex.IBErrorCode = isc_foreign_key) or ((Ex.IBErrorCode = isc_except) and (
          StrIPos('GD_E_FKMANAGER', Ex.Message) > 0)) then
        begin
          if sMultiple in BaseState then
          begin
            if sAskMultiple in BaseState then
            begin
              if MessageBox(ParentHandle,
                PChar('������ "' + ObjectName + '" ���������� ������� ��� ��� �� ��� ��������� ������ ������.'#13#10#13#10 +
                '���������� ��������� ������ � ���������� �������� �� ������?'),
                '��������',
                MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES then
              begin
                BaseState := BaseState + [sSkipMultiple];
              end;
              BaseState := BaseState - [sAskMultiple];
            end;

            if not (sSkipMultiple in BaseState) then
              isUse;
          end else
            isUse;
          Abort;
        end else
          raise;
      end;
    end;

  DoAfterCustomProcess(Buff, cpDelete);
end;

class function TgdcBase.GetSubTypeList(ASubTypeList: TStrings;
  const ASubType: String = ''; const AnOnlyDirect: Boolean = False;
  const AVerbose: Boolean = True): Boolean;
begin
  Assert(ASubTypeList <> nil);
  Result := gdClassList.GetSubTypeList(Self, ASubType, ASubTypeList,
    AnOnlyDirect, AVerbose);
end;

function TgdcBase.GetNextID(const Increment: Boolean = True; const ResetCache: Boolean = False): Integer;
var
  q: TIBSQL;
begin
  if Increment and Assigned(gdcBaseManager) then
    Result := gdcBaseManager.GetNextID(ResetCache)
  else
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := ReadTransaction;
      if Increment then
        q.SQL.Text := 'SELECT GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0) FROM rdb$database'
      else
        q.SQL.Text := 'SELECT GEN_ID(gd_g_unique, 0) + GEN_ID(gd_g_offset, 0) FROM rdb$database';
      q.ExecQuery;
      Result := q.Fields[0].AsInteger;
    finally
      q.Free;
    end;
  end;
end;

class function TgdcBase.GetTableInfos(const ASubType: String): TgdcTableInfos;
var
  R: TatRelation;
begin
  Assert(Assigned(atDatabase));
  R := atDatabase.Relations.ByRelationName(GetListTable(ASubType));
  Result := [];
  if (R <> nil) and (R.RelationFields <> nil) then
  begin
    if R.RelationFields.ByFieldName(GetKeyField(ASubType)) <> nil then
      Include(Result, gdcBaseInterface.tiID);
    if R.RelationFields.ByFieldName(fnxid) <> nil then
      Include(Result, gdcBaseInterface.tiXID);
    if R.RelationFields.ByFieldName(fndbid) <> nil then
      Include(Result, gdcBaseInterface.tiDBID);
    if R.RelationFields.ByFieldName(fncreationdate) <> nil then
      Include(Result, tiCreationDate);
    if R.RelationFields.ByFieldName(fncreatorkey) <> nil then
      Include(Result, tiCreatorKey);
    if R.RelationFields.ByFieldName(fneditiondate) <> nil then
      Include(Result, tiEditionDate);
    if R.RelationFields.ByFieldName(fneditorkey) <> nil then
      Include(Result, tiEditorKey);
    if R.RelationFields.ByFieldName(fndisabled) <> nil then
      Include(Result, tiDisabled);
    if R.RelationFields.ByFieldName(fnaview) <> nil then
      Include(Result, tiAView);
    if R.RelationFields.ByFieldName(fnachag) <> nil then
      Include(Result, tiAChag);
    if R.RelationFields.ByFieldName(fnafull) <> nil then
      Include(Result, tiAFull);
  end;
end;

function TgdcBase.HasAttribute: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FieldCount - 1 do
    if AnsiCompareText(System.Copy(Fields[I].FieldName, 1, 4), UserPrefix) = 0 then
    begin
      Result := True;
      exit;
    end;
end;

procedure TgdcBase.DoAfterCustomProcess(Buff: Pointer;
  Process: TgsCustomProcess);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_DOAFTERCUSTOMPROCESS('TGDCBASE', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOAFTERCUSTOMPROCESS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERCUSTOMPROCESS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self),
  {M}          Integer(Buff), TgsCustomProcess(Process)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  // should be overridden by descendant classes

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS);
  {M}  end;
  {END MACRO}
end;

{ EgdcBase }

constructor EgdcIBError.CreateObj(E: EIBError; AnObj: TgdcBase);
begin
  Assert(E is EIBError);
  Assert(AnObj is TgdcBase);
  FOriginalClass := CIBError(E.ClassType);
  Create(E.SQLCode, E.IBErrorCode,
    Format('%s'#13#10#13#10'Class: %s'#13#10'Object: %s'#13#10'SubType: %s'#13#10'SubSet: %s'#13#10'ID: %d'#13#10,
      [E.Message, AnObj.ClassName, AnObj.Name, AnObj.SubType, AnObj.SubSet, AnObj.ID]));
end;

procedure TgdcBase.DoAfterShowDialog(DlgForm: TCreateableForm;
  IsOk: Boolean);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_DOAFTERSHOWDIALOG('TGDCBASE', 'DOAFTERSHOWDIALOG', KEYDOAFTERSHOWDIALOG)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOAFTERSHOWDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERSHOWDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self),
  {M}          GetGdcInterface(DlgForm), IsOk]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOAFTERSHOWDIALOG', KEYDOAFTERSHOWDIALOG, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if Assigned(FAfterShowDialog) then
    FAfterShowDialog(Self, DlgForm, IsOk);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOAFTERSHOWDIALOG', KEYDOAFTERSHOWDIALOG)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOAFTERSHOWDIALOG', KEYDOAFTERSHOWDIALOG);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.DoBeforeShowDialog(DlgForm: TCreateableForm);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_DOBEFORESHOWDIALOG('TGDCBASE', 'DOBEFORESHOWDIALOG', KEYDOBEFORESHOWDIALOG)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOBEFORESHOWDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFORESHOWDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(DlgForm)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOBEFORESHOWDIALOG', KEYDOBEFORESHOWDIALOG, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if Assigned(FBeforeShowDialog) then
    FBeforeShowDialog(Self, DlgForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOBEFORESHOWDIALOG', KEYDOBEFORESHOWDIALOG)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOBEFORESHOWDIALOG', KEYDOBEFORESHOWDIALOG);
  {M}  end;
  {END MACRO}
end;

class function TgdcBase.GetSubSetList: String;
begin
  Result := 'All;ByID;ByName;OnlySelected;';
end;

procedure TgdcBaseManager.Class_SetSecDesc(C: TClass;
  const ASubType: TgdcSubType; const AView, AChag, AFull: Integer);
var
  I: Integer;
begin
  I := IndexOfClass(C, ASubType);
  if I > -1 then
  begin
    FSecDescArr[I, 2] := AView;
    FSecDescArr[I, 3] := AChag;
    FSecDescArr[I, 4] := AFull;
  end;
end;

procedure TgdcBaseManager.RemoveRUIDFromCache(const AXID, ADBID: TID);
var
  S: String;
begin
  if CacheList <> nil then
  begin
    S := RUIDToStr(AXID, ADBID);
    if CacheList.Has(S) then
      CacheList.Remove(S);
  end;    
end;

procedure TgdcBaseManager.ChangeRUID(const AnOldXID, AnOldDBID, ANewXID,
  ANewDBID: TID; ATr: TIBTRansaction);
var
  OldRUIDString, NewRUIDString: String;
  OldRUIDParam, NewRUIDParam: String;
  SName: String;
  q: TIBSQL;
begin
  Assert(ATr <> nil);
  Assert(ATr.InTransaction);

  OldRUIDString := RUIDToStr(AnOldXID, AnOldDBID);
  NewRUIDString := RUIDToStr(ANewXID, ANewDBID);

  OldRUIDParam := IntToStr(AnOldXID) + ', ' + IntToStr(AnOldDBID);
  NewRUIDParam := IntToStr(ANewXID) + ', ' + IntToStr(ANewDBID);

  SName := 'S' + OldRUIDString;
  ATr.SetSavePoint(SName);
  try
    q := TIBSQL.Create(nil);
    try
      q.Transaction := ATr;

      q.SQL.Text :=
        'UPDATE gd_ruid SET xid = :new_xid, dbid = :new_dbid, ' +
        '  modified = CURRENT_TIMESTAMP(0) ' +
        'WHERE xid = :old_xid AND dbid = :old_dbid';
      q.ParamByName('old_xid').AsInteger := AnOldXID;
      q.ParamByName('old_dbid').AsInteger := AnOldDBID;
      q.ParamByName('new_xid').AsInteger := ANewXID;
      q.ParamByName('new_dbid').AsInteger := ANewDBID;
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE gd_command SET cmd = :new, ' +
        '  editiondate = CURRENT_TIMESTAMP(0) ' +
        'WHERE cmd = :old';
      q.ParamByName('old').AsString := OldRUIDString;
      q.ParamByName('new').AsString := NewRUIDString;
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE gd_function SET script = REPLACE(script, :old, :new), ' +
        '  editiondate = CURRENT_TIMESTAMP(0) ' +
        'WHERE POSITION(:old IN script) > 0';
      q.ParamByName('old').AsString := OldRUIDString;
      q.ParamByName('new').AsString := NewRUIDString;
      q.ExecQuery;

      q.ParamByName('old').AsString := OldRUIDParam;
      q.ParamByName('new').AsString := NewRUIDParam;
      q.ExecQuery;

      q.ParamByName('old').AsString := StringReplace(OldRUIDParam, ' ', '', []);
      q.ParamByName('new').AsString := StringReplace(NewRUIDParam, ' ', '', []);
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE gd_documenttype SET ruid = :new, ' +
        '  editiondate = CURRENT_TIMESTAMP(0) ' +
        'WHERE ruid = :old';
      q.ParamByName('old').AsString := OldRUIDString;
      q.ParamByName('new').AsString := NewRUIDString;
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE inv_balanceoption SET ruid = :new ' +
        '  WHERE ruid = :old';
      q.ParamByName('old').AsString := OldRUIDString;
      q.ParamByName('new').AsString := NewRUIDString;
      q.ExecQuery;

      q.SQL.Text :=
        'DELETE FROM at_object o ' +
        'WHERE ' +
        '  o.xid = :xid AND o.dbid = :dbid ' +
        '  AND (EXISTS (SELECT * FROM at_object o2 ' +
        '    WHERE o2.namespacekey = o.namespacekey ' +
        '      AND o2.xid = :old_xid AND o2.dbid = :old_dbid))';
      q.ParamByName('old_xid').AsInteger := AnOLDXID;
      q.ParamByName('old_dbid').AsInteger := AnOldDBID;
      q.ParamByName('xid').AsInteger := ANewXID;
      q.ParamByName('dbid').AsInteger := ANewDBID;
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE at_object SET xid = :xid, dbid = :dbid WHERE xid = :old_xid AND dbid = :old_dbid';
      q.ParamByName('old_xid').AsInteger := AnOLDXID;
      q.ParamByName('old_dbid').AsInteger := AnOldDBID;
      q.ParamByName('xid').AsInteger := ANewXID;
      q.ParamByName('dbid').AsInteger := ANewDBID;
      q.ExecQuery;

      q.SQL.Text :=
        'DELETE FROM at_settingpos p ' +
        'WHERE ' +
        '  p.xid = :xid AND p.dbid = :dbid ' +
        '  AND (EXISTS (SELECT * FROM at_settingpos p2 ' +
        '    WHERE p2.settingkey = p.settingkey ' +
        '      AND p2.xid = :old_xid AND p2.dbid = :old_dbid))';
      q.ParamByName('old_xid').AsInteger := AnOLDXID;
      q.ParamByName('old_dbid').AsInteger := AnOldDBID;
      q.ParamByName('xid').AsInteger := ANewXID;
      q.ParamByName('dbid').AsInteger := ANewDBID;
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE at_settingpos SET xid = :xid, dbid = :dbid WHERE xid = :old_xid AND dbid = :old_dbid';
      q.ParamByName('old_xid').AsInteger := AnOLDXID;
      q.ParamByName('old_dbid').AsInteger := AnOldDBID;
      q.ParamByName('xid').AsInteger := ANewXID;
      q.ParamByName('dbid').AsInteger := ANewDBID;
      q.ExecQuery;
    finally
      q.Free;
    end;

    ATr.ReleaseSavePoint(SName);
  except
    ATr.RollBackToSavePoint(SName);
    raise;
  end;

  RemoveRUIDFromCache(AnOldXID, AnOldDBID);
  RemoveRUIDFromCache(ANewXID, ANewDBID);
end;

{ TgdcObjectSet }

constructor TgdcObjectSet.Create(AgdClass: CgdcBase; const ASubType: TgdcSubType; const ASize: Integer = 32);
begin
  FgdClass := AgdClass;
  FSubType := ASubType;
  FCount := 0;
  SetLength(FArray, ASize);
  FgdClassList := TStringList.Create;
  FMin := High(TID);
  FMax := Low(TID);
end;

destructor TgdcObjectSet.Destroy;
begin
  inherited;
  SetLength(FArray, 0);
  FgdClassList.Free;
end;

function TgdcObjectSet.Get_gdClass: CgdcBase;
begin
  Result := FgdClass;
end;

function TgdcObjectSet.Get_gdClassName: String;
begin
  if FgdClass <> nil then
    Result := FgdClass.ClassName
  else
    Result := '';
end;

function TgdcObjectSet.GetCount: Integer;
begin
  Result := FCount;
end;

function TgdcObjectSet.GetItems(Index: Integer): TID;
begin
  if (Index < 0) or (Index >= FCount) then
    raise Exception.Create(GetGsException(Self, 'Invalid index'));
  Result := FArray[Index];
end;

procedure TgdcObjectSet.Set_gdClass(const Value: CgdcBase);
begin
  if FgdClass <> Value then
  begin
    FgdClass := Value;
    FCount := 0;
  end;  
end;

function TgdcObjectSet.Add(const AnID: TID; const AgdClassName: String;
  const ASubType: String; const ASetTable: String ): Integer;
begin
  Result := Find(AnID);
  if Result = -1 then
  begin
    if FCount = Size then
      SetLength(FArray, (Size + 1) * 2);
    FArray[FCount] := AnID;
    Result := FCount;
    AddgdClass(Result, AgdClassName, ASubType, ASetTable);
    Inc(FCount);
    if AnID > FMax then FMax := AnID;
    if AnID < FMin then FMin := AnID;
  end else
  begin
    AddgdClass(Result, AgdClassName, ASubType, ASetTable);
  end;
end;

function TgdcObjectSet.GetSize: Integer;
begin
  Result := High(FArray) - Low(FArray) + 1;
end;

class function TgdcBase.GetListTable(const ASubType: TgdcSubType): String;
var
  CE: TgdClassEntry;
begin
  if ASubType > '' then
  begin
    CE := gdClassList.Get(TgdBaseEntry, Self.ClassName, ASubType);
    if CE is TgdAttrUserDefinedEntry then
      Result := CE.GetRootSubType.SubType
    else
      Result := '';
  end else
    Result := '';
end;

class function TgdcBase.GetListField(const ASubType: TgdcSubType): String;
var
  CE: TgdClassEntry;
  R: TatRelation;
begin
  if ASubType > '' then
  begin
    CE := gdClassList.Get(TgdBaseEntry, Self.ClassName, ASubType);
    if CE is TgdAttrUserDefinedEntry then
    begin
      R := atDatabase.Relations.ByRelationName(GetListTable(ASubType));
      if Assigned(R) then
        Result := R.ListField.FieldName
      else
        Result := '';
    end else
      Result := '';
  end else
    Result := '';
end;

procedure TgdcBase.GetDistinctColumnValues(const AFieldName: String;
  S: TStrings; const DoSort: Boolean);
var
  q: TIBSQL;
begin
  Assert(S <> nil);
  Assert(AFieldName > '');

  S.Clear;
  q := TIBSQL.Create(nil);
  try
    q.Database := Database;
    q.Transaction := ReadTransaction;
    q.SQL.Text := 'SELECT DISTINCT ' + AFieldName + ' FROM ' + GetListTable(SubType);
    if DoSort then
      q.SQL.Text := q.SQL.Text + ' ORDER BY 1';
    q.ExecQuery;
    while not q.EOF do
    begin
      S.Add(q.Fields[0].AsString);
      q.Next;
    end;
    q.Close;
  finally
    q.Free;
  end;
end;

function TgdcBase.GetFieldNameComparedToParam(
  const AParamName: String): String;

{ TODO :
�����������: �� �� ������������ IN, BETWEEN
}

{ TODO : 
��������! ���� ������! ���� � ������� ���������
����������� �����, �� ����� ������� ������������
��������!

��������� �� �� ����� ����� ��� �������, � ������ �� �����...

}

  function _Sub(const S, AParamName: String; out ARelationName, AFieldName: String): Boolean;
  var
    B, E: Integer;
    Found: Boolean;
  begin
    if AParamName > '' then
    begin
      E := Pos(':' + UpperCase(AParamName), UpperCase(S)) - 1;
      B := 0;
      Found := True;
      repeat
        while (E > 0) and (S[E] in [' ', '=', '!', '<', '>', ')', '+', '-', '*', '/', '|', '"', #9, #13, #10]) do
          Dec(E);
        if E > 0 then
        begin
          B := E - 1;
          if S[E + 1] = '"' then
          begin
            while (B > 0) and (S[B] <> '"') do
              Dec(B);
          end else
          begin
            while (B > 0) and (S[B] in ['A'..'Z', 'a'..'z', '0'..'9', '_', '$']) do
              Dec(B);
          end;

          AFieldName := System.Copy(S, B + 1, E - B);

          if (B > 0) and (S[B] = '"') then
            Dec(B);

          if (AFieldName > '')
            and (not (AFieldName[1] in ['A'..'Z', 'a'..'z', '_']))
            and (S[E + 1] <> '"') then
          begin
            E := B;
            Found := False;
          end else
          begin
            Found := True;
            if S[E + 1] = '"' then
              AFieldName := '"' + AFieldName + '"';
          end;
        end else
          AFieldName := '';
      until Found;

      if (B > 1) and (S[B] = '.') then
      begin
        Dec(B);
        if S[B] = '"' then
          Dec(B);
        E := B;
        if S[E + 1] = '"' then
          while (B > 0) and (S[B] <> '"') do
            Dec(B)
        else
          while (B > 0) and (S[B] in ['A'..'Z', 'a'..'z', '0'..'9', '_', '$']) do
            Dec(B);
        ARelationName := System.Copy(S, B + 1, E - B);
        if S[E + 1] = '"' then
          ARelationName := '"' + ARelationName + '"';
      end else
        ARelationName := '';
    end else
    begin
      AFieldName := '';
      ARelationName := '';
    end;

    Result := AFieldName > '';
  end;

var
  RN, FromClause, WhereClause: String;
  F: TField;
  S: TStringList;
  I: Integer;

begin
  FromClause := GetFromClause;
  if Assigned(FOnGetFromClause) then
    FOnGetFromClause(Self, FromClause);

  WhereClause := GetWhereClause;
  if Assigned(FOnGetWhereClause) then
    FOnGetWhereClause(Self, WhereClause);

  if _Sub(FromClause + ' ' + WhereClause, AParamName, RN, Result) then
  begin
    {����� ���������, ��� ���� �� ������� ������� ������ ������������ ��������}
    if (RN > '') and (AnsiCompareText(GetListTableAlias, RN) <> 0) then
    begin
      S := TStringList.Create;
      try
        GetTableAliasOriginField(SelectSQL.Text, S);

        F := nil;

        for I := 0 to S.Count - 1 do
        begin
          if AnsiCompareText(S.Values[S.Names[I]], RN + '.' + Result) = 0 then
          begin
            F := FindField(S.Names[I]);
            Break;
          end;
        end;
      finally
        S.Free;
      end;
    end else
    begin
      F := FindField(Result);
    end;

    if F <> nil then
      Result := F.FieldName
    else
      Result := '';

  end else
    Result := '';
end;

procedure TgdcBase.LoadDialogDefaults(F: TgsStorageFolder; Dlg: TForm);
var
  L: TList;
  I: Integer;
begin
  L := TList.Create;
  try
    GetFieldList(L, GetDialogDefaultsFields);

    for I := 0 to L.Count - 1 do
    begin
      if TField(L[I]).IsNull and (not TField(L[I]).ReadOnly) then
      begin
        if F.ValueExists(TField(L[I]).FieldName) then
        try

          if TField(L[I]) is TIntegerField then
            TField(L[I]).AsInteger := F.ReadInteger(TField(L[I]).FieldName)
          else if TField(L[I]) is TNumericField then
            TField(L[I]).AsCurrency := F.ReadCurrency(TField(L[I]).FieldName)
          else if TField(L[I]) is TDateTimeField then
            TField(L[I]).AsDateTime := F.ReadDateTime(TField(L[I]).FieldName, Now)
          else
            TField(L[I]).AsString := F.ReadString(TField(L[I]).FieldName);
        except
          on Exception do
            F.DeleteValue(TField(L[I]).FieldName);
        end;
      end;
    end;  
  finally
    L.Free;
  end;
end;

procedure TgdcBase.SaveDialogDefaults(F: TgsStorageFolder; Dlg: TForm);
var
  L, L2: TList;
  I: Integer;
  PropInfo: PPropInfo;
  Fld: TField;
begin
  L := TList.Create;
  L2 := TList.Create;
  try
    if Dlg = nil then
      GetFieldList(L2, GetDialogDefaultsFields)
    else
    begin
      GetFieldList(L, GetDialogDefaultsFields);

      // the intention here is to store only those
      // field values which controls are on the form
      { TODO :
  ��� �� ��������. ���� �� ��������� ������ ��������
  ������� ����� ������ ������. � ��� ��������������
  � ��������, � ��� ��� ������ }
      with Dlg do
        for I := 0 to ComponentCount - 1 do
        begin
          PropInfo := GetPropInfo(Components[I].ClassInfo, 'DataSource');
          if (PropInfo <> nil)
            and (PropInfo^.PropType^.Kind = tkClass)
            and (GetTypeData(PropInfo^.PropType^).ClassType.InheritsFrom(TDataSource)) then
          begin
            PropInfo := GetPropInfo(Components[I].ClassInfo, 'DataField');
            if (PropInfo <> nil) and (PropInfo^.PropType^.Kind = tkLString) then
            begin
              Fld := Self.FindField(GetStrProp(Components[I], PropInfo));
              if (Fld <> nil) and (L.IndexOf(Fld) <> -1) then
                L2.Add(Fld);
            end;
          end;
        end;
    end;

    for I := 0 to L2.Count - 1 do
    begin
      if TField(L2[I]).IsNull or TField(L2[I]).ReadOnly or TField(L2[I]).Calculated then
        F.DeleteValue(TField(L2[I]).FieldName)
      else
      begin
        if TField(L2[I]) is TIntegerField then
          F.WriteInteger(TField(L2[I]).FieldName, TField(L2[I]).AsInteger)
        else if TField(L2[I]) is TNumericField then
          F.WriteCurrency(TField(L2[I]).FieldName, TField(L2[I]).AsCurrency)
        else if TField(L2[I]) is TDateTimeField then
          F.WriteDateTime(TField(L2[I]).FieldName, TField(L2[I]).AsDateTime)
        else
          F.WriteString(TField(L2[I]).FieldName, TField(L2[I]).AsString);
      end;
    end;

  finally
    L.Free;
    L2.Free;
  end;
end;

function TgdcBase.GetDialogDefaultsFields: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
const
  Prohibited =
    ';ID;NAME;AFULL;ACHAG;AVIEW;RESERVED;PARENT;CREATIONDATE;CREATORKEY;EDITIONDATE;EDITORKEY;LB;RB;RUID;XID;DBID;';
var
  SL: TStringList;
  I: Integer;
  F: TField;
  Proh: String;
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCBASE', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYGETDIALOGDEFAULTSFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETDIALOGDEFAULTSFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETDIALOGDEFAULTSFIELDS' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}//          Result := Inherited GETDIALOGDEFAULTSFIELDS;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FGetDialogDefaultsFieldsCached then
    Result := FGetDialogDefaultsFieldsCache
  else begin
    Result := '';
    Proh := ';' + GetListField(SubType) + Prohibited +
      StringReplace(GetNotCopyField, ',', ';', [rfReplaceAll]) + ';';

    SL := TStringList.Create;
    try
      Database.GetFieldNames(GetListTable(SubType), SL);
      for I := 0 to SL.Count - 1 do
        if StrIPos(';' + SL[I] + ';', Proh) = 0 then
        begin
          F := FindField(SL[I]);
          if (F <> nil) and (F.DefaultExpression = '') and (not (F is TBlobField)) and (F.Size < 64) then
            Result := Result + F.FieldName + ';';
        end;
    finally
      SL.Free;
    end;

    FGetDialogDefaultsFieldsCached := True;
    FGetDialogDefaultsFieldsCache := Result;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS);
  {M}  end;
  {END MACRO}
end;

function TgdcBase.ShowFieldInGrid(AField: TField): Boolean;
var
  RN, FN: String;
  RF: TatRelationField;
begin
  Assert((AField <> nil) and (AField.DataSet = Self));

  ParseFieldOrigin(AField.Origin, RN, FN);

  if RN = '' then
  begin
    Result := True;
    exit;
  end;

  Result := AField.Visible
    and (StrIPos(';' + FN + ';', ';' + HideFieldsList) = 0);

  if Result and (not IBLogin.IsUserAdmin) then
  begin
    RF := atDatabase.FindRelationField(RN, FN);
    if RF <> nil then
    begin
      if (RF.aView and IBLogin.Ingroup) = 0 then
      begin
        Result := False;
      end
      else if (RF.aChag and IBLogin.Ingroup) = 0 then
      begin
        AField.ReadOnly := True;
      end;
    end;
  end;
end;

function TgdcBase.HideFieldsList: String;
begin
  Result := 'afull;achag;aview;';
end;

function TgdcObjectSet.Find(const AnID: TID): Integer;
var
  I: Integer;
begin
  Result := -1;
  if (AnID >= FMin) and (AnID <= FMax) then
  begin
    for I := 0 to Count - 1 do
      if Items[I] = AnID then
      begin
        Result := I;
        break;
      end;
  end;    
end;

procedure TgdcObjectSet.LoadFromStream(S: TStream);
var
  I: Integer;
  ID: TID;
  St: String;
begin
  if S.Position >= S.Size then
    Exit;
  S.ReadBuffer(I, SizeOf(I));
  if I > 1024 then
    raise EgdcException.Create('������������ �����!'); 
  SetLength(St, I);
  S.ReadBuffer(St[1], I);
  FgdClass := CgdcBase(FindClass(St));
  FCount := 0;
  S.ReadBuffer(I, SizeOf(I));
  while I > 0 do
  begin
    S.ReadBuffer(ID, SizeOf(ID));
{ TODO -oJulia : ���� ��������� �� ������ ����� ��� ������������ ������� � ��������� }
    Add(ID, '', '', '');
    Dec(I);
  end;
end;

procedure TgdcObjectSet.SaveToStream(S: TStream);
var
  I: Integer;
  ID: TID;
begin
  I := Length(gdClassName);
  S.Write(I, SizeOf(I));
  S.Write(gdClassName[1], I);
  I := Count;
  S.Write(I, SizeOf(I));
  for I := 0 to Count - 1 do
  begin
    ID := Items[I];
    S.Write(ID, SizeOf(ID));
  end;
end;

procedure TgdcObjectSet.Remove(const AnID: TID);
var
  I: Integer;
begin
  I := Find(AnID);
  if I <> -1 then
    Delete(I);
end;

procedure TgdcObjectSet.Delete(const Index: Integer);
var
  J: Integer;
  ID: TID;
begin
  if (Index < 0) or (Index >= Count) then
    raise Exception.Create(GetGsException(Self, 'Index is out of bounds'));
  ID := FArray[Index];
  for J := Index to Count - 2 do
    FArray[J] := FArray[J + 1];
  Dec(FCount);
  FgdClassList.Delete(Index);
  if ID = FMax then
  begin
    FMax := Low(TID);
    for J := 0 to FCount - 1 do
    begin
      if FArray[J] > FMax then FMax := FArray[J];
    end;
  end;
  if ID = FMin then
  begin
    FMin := High(TID);
    for J := 0 to FCount - 1 do
    begin
      if FArray[J] < FMin then FMin := FArray[J];
    end;
  end;
end;

function TgdcObjectSet.GetSubType: TgdcSubType;
begin
  Result := FSubType;
end;

procedure TgdcObjectSet.SetSubType(const Value: TgdcSubType);
begin
  if Value <> FSubType then
  begin
    FSubType := Value;
    FCount := 0;
  end;
end;

procedure TgdcObjectSet.AddgdClass(const Index: Integer; const AgdClassName,
  ASubType, ASetTable: String);
begin
  if (Index < 0) or (Index > FgdClassList.Count) then
  begin
    raise EgdcException.Create('TgdcObjectSet: ������������ ������!');
  end;

  if Index = FgdClassList.Count then
  begin
    FgdClassList.Add(FormClassSubTypeString(AgdClassName, ASubType, AsetTable))
  end else
  begin
    FgdClassList[Index] := FgdClassList[Index] + ',' +
      FormClassSubTypeString(AgdClassName, ASubType, ASetTable);
  end;
end;

function TgdcObjectSet.FindgdClass(const Index: Integer; const AgdClassName,
  ASubType: String; const ASetTable: String): Boolean;
var
  St, SubSt: String;
  Pos: Integer;
begin
  Result := False;
  if Index > -1 then
  begin
    St := FgdClassList[Index];
    Pos := AnsiPos(',', St);
    if Pos = 0 then
    begin
      Result := St = FormClassSubTypeString(AgdClassName, ASubType, ASetTable);
    end else
    begin
      while Pos > 0 do
      begin
        SubSt := Copy(St, 1, Pos - 1);
        if SubSt = FormClassSubTypeString(AgdClassName, ASubType, ASetTable) then
        begin
          Result := True;
          Exit;
        end;
        St := Copy(St, Pos + 1, Length(St) - Pos);
        Pos := AnsiPos(',', St);
      end;
      Result := St = FormClassSubTypeString(AgdClassName, ASubType, ASetTable);
    end;
  end;
end;

function TgdcObjectSet.FormClassSubTypeString(const gdClassName,
  SubType, ASetTable: String): String;
begin
  Result := AnsiUpperCase(gdClassName) + '(' + AnsiUpperCase(SubType) + ')' + ASetTable;
end;

function TgdcObjectSet.FindgdClassByID(const AnID: TID; const AgdClassName,
  ASubType: String; const ASetTable: String): Boolean;
begin
  Result := FindgdClass(Find(AnID), AgdClassName, ASubType, ASetTable);
end;

function TgdcObjectSet.GetgdInfo(Index: Integer): String;
begin
  if (Index < 0) or (Index >= FCount) then
    raise Exception.Create(GetGsException(Self, 'Invalid index'));
  Result := FgdClassList[Index];
end;


function TgdcObjectSet.GetClassFromString(const AText: String): String;
var
  Ps: Integer;
begin
  Ps := AnsiPos('(', AText);
  if Ps > 0 then
    Result := Copy(AText, 0, Ps - 1)
  else
    Result := '';
end;

function TgdcObjectSet.GetSetTableFromString(const AText: String): String;
var
  Ps: Integer;
begin
  Ps := AnsiPos(')', AText);
  if Ps > 0 then
    Result := Copy(AText, Ps + 1, Length(AText) - Ps)
  else
    Result := '';
end;

function TgdcObjectSet.GetSubTypeFromString(const AText: String): String;
var
  Ps, Ps1: Integer;
begin
  Ps := AnsiPos('(', AText);
  Ps1 := AnsiPos(')', AText);
  if (Ps > 0) and (Ps1 > Ps) then
    Result := Copy(AText, Ps + 1, Ps1 - Ps - 1)
  else
    Result := '';
end;

{ TgdcObjectSets }

constructor TgdcObjectSets.Create;
begin
  inherited Create(True);
end;

function TgdcObjectSets.Find(C: TgdcFullClass): TgdcObjectSet;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Result := (Items[I] as TgdcObjectSet);
    if (Result.gdClass = C.gdClass) and (Result.SubType = C.SubType) then
      exit;
  end;
  Result := nil;
end;

procedure TgdcObjectSets.LoadFromStream(S: TStream);
var
  I: Integer;
  ObjectSet: TgdcObjectSet;
begin
  Clear;
  S.ReadBuffer(I, SizeOf(I));
  if I <> $66778899 then
    raise Exception.Create(GetGsException(Self, 'Invalid stream format'));
  S.ReadBuffer(I, SizeOf(I));
  while I > 0 do
  begin
    ObjectSet := TgdcObjectSet.Create(TgdcBase, '');
    ObjectSet.LoadFromStream(S);
    Add(ObjectSet);
    Dec(I);
  end;
end;

procedure TgdcObjectSets.SaveToStream(S: TStream);
var
  I: Integer;
begin
  I := $66778899;
  S.Write(I, SizeOf(I));
  I := Count;
  S.Write(I, SizeOf(I));
  for I := 0 to Count - 1 do
    (Items[I] as TgdcObjectSet).SaveToStream(S);
end;

function TgdcBase.FindField(const ARelationName,
  AFieldName: String): TField;
var
  I: Integer;
  Origin: String;
begin
  Result := nil;
  Origin := UpperCase('"' + ARelationName + '"."' + AFieldName + '"');
  for I := 0 to FieldCount - 1 do
  begin
    if Fields[I].Origin = Origin then
    begin
      Result := Fields[I];
      exit;
    end;
  end;
end;

function TgdcBase.FieldByName(const ARelationName,
  AFieldName: String): TField;
begin
  Result := FindField(ARelationName, AFieldName);
  if Result = nil then
    raise EgdcException.CreateObj(
      Format('Field "%s" (relation "%s") not found',
        [AFieldName, ARelationName]), Self);
end;

function TgdcBase.IsReverseOrder(const AFieldName: String): Boolean;
begin
  Result := False;
end;

procedure TgdcBase.LoadFromFile(const AFileName: String);
var
  StreamSaver: TgdcStreamSaver;
  StreamFormat: TgsStreamType;
  FileName: String;
  S: TStream;
begin
  FileName := QueryLoadFileName(AFileName, datExtension, datxmlDialogFilter);
  if FileName <> '' then
  begin
    // ��������� �� ������ ������
    S := TFileStream.Create(AFileName, fmOpenRead);
    try
      StreamFormat := GetStreamType(S);
    finally
      S.Free;
    end;

    if StreamFormat <> sttBinaryOld then
    begin
      StreamSaver := TgdcStreamSaver.Create(Self.Database, Self.Transaction);
      StreamSaver.Silent := Self.StreamSilentProcessing;
      S := TFileStream.Create(AFileName, fmOpenRead);
      try
        //StreamSaver.Silent := True;
        StreamSaver.LoadFromStream(S);
        if StreamSaver.IsAbortingProcess then
          Exit;
      finally
        S.Free;
        StreamSaver.Free;
      end;
    end
    else
    begin
      S := TFileStream.Create(AFileName, fmOpenRead);
      try
        Self.LoadFromStream(S);
      finally
        S.Free;
      end;
    end;
  end;
end;

procedure TgdcBase.SaveToFile(const AFileName: String = ''; const ADetail: TgdcBase = nil;
  const BL: TBookmarkList = nil; const OnlyCurrent: Boolean = True; StreamFormat: TgsStreamType = sttUnknown);
var
  StreamSaver: TgdcStreamSaver;
  FileName: String;
  S: TStream;
  Bm: TBookmarkStr;
  I: Integer;

  procedure SaveDetail;
  var
    DBm: TBookmarkStr;
  begin
    if Assigned(ADetail) then
    begin
      ADetail.BlockReadSize := 1;
      try
        DBm := ADetail.Bookmark;
        ADetail.First;
        while not ADetail.Eof do
        begin
          StreamSaver.AddObject(ADetail);
          if StreamSaver.IsAbortingProcess then
            Exit;
          ADetail.Next;
        end;
        ADetail.Bookmark := DBm;
      finally
        ADetail.BlockReadSize := 0;
      end;
    end;
  end;

begin
  if Assigned(BL) then
    BL.Refresh;

  // ���� ������ ����� �� �������, �� ������� ������ �� ���������
  if StreamFormat = sttUnknown then
    StreamFormat := GetDefaultStreamFormat(False);
  case StreamFormat of
    sttXML:
      FileName := Self.QuerySaveFileName(AFileName, xmlExtension, xmlDialogFilter)
  else
    FileName := Self.QuerySaveFileName(AFileName, datExtension, datDialogFilter);
  end;

  // ���� ������������ ������ ����
  if FileName <> '' then
  begin
    if StreamFormat <> sttBinaryOld then
    begin
      StreamSaver := TgdcStreamSaver.Create(Self.Database, Self.Transaction);
      try
        StreamSaver.Silent := Self.StreamSilentProcessing;
        // ���� ������� ������������ ����������, �� ��������� �� ������� ����
        {if IncrementDatabaseKey > 0 then
          StreamSaver.PrepareForIncrementSaving(IncrementDatabaseKey);}

        // ���� ��������� ������ ���� ������
        if OnlyCurrent then
        begin
          if Assigned(frmStreamSaver) then
            frmStreamSaver.SetupProgress(1, '���������� ������...');
          StreamSaver.AddObject(Self);
          if StreamSaver.IsAbortingProcess then
            Exit;
          SaveDetail;
          if Assigned(frmStreamSaver) then
            frmStreamSaver.Step;
        end
        else
        begin
          Bm := Self.Bookmark;
          Self.BlockReadSize := 1;

          try
            // ���� �� ������� BookmarkList, �� ��������� ���� �������
            if not Assigned(BL) then
            begin
              if Assigned(frmStreamSaver) then
                frmStreamSaver.SetupProgress(Self.RecordCount,  '���������� ������...');
              Self.First;
              while not Self.Eof do
              begin
                StreamSaver.AddObject(Self);
                if StreamSaver.IsAbortingProcess then
                  Exit;
                SaveDetail;
                Self.Next;
                if Assigned(frmStreamSaver) then
                  frmStreamSaver.Step;
              end;
            end else
            begin
              if Assigned(frmStreamSaver) then
                frmStreamSaver.SetupProgress(BL.Count,  '���������� ������...');
              BL.Refresh;
              for I := 0 to BL.Count - 1 do
              begin
                Self.Bookmark := BL[I];
                StreamSaver.AddObject(Self);
                if StreamSaver.IsAbortingProcess then
                  Exit;
                SaveDetail;
                if Assigned(frmStreamSaver) then
                  frmStreamSaver.Step;
              end;
            end;
          finally
            Self.Bookmark := Bm;
            Self.BlockReadSize := 0;
          end;
        end;

        if Assigned(frmStreamSaver) then
          frmStreamSaver.SetProcessCaptionText('������ � ����...');

        // ��������� � ����������� �� ���������� � ���������� ���� �����
        StreamSaver.StreamFormat := StreamFormat;
        S := TFileStream.Create(FileName, fmCreate);
        try
          StreamSaver.SaveToStream(S);
        finally
          S.Free;
        end;
      finally
        StreamSaver.Free;
      end;
    end
    else
    begin
      if Assigned(frmStreamSaver) then
        frmStreamSaver.SetupProgress(1, '���������� ������...');

      S := TFileStream.Create(FileName, fmCreate);
      try
        Self.SaveToStream(S, ADetail, BL, OnlyCurrent);
      finally
        S.Free;
      end;
    end;

    if Assigned(frmStreamSaver) then
      frmStreamSaver.Done;
  end;
end;

{��-��������� ��� ����� ������ ��� ���������� ��� ���������� ������� �
 �������, �� ������� ��� ���������, ������ ����� ������������� ����
 "�������������� ������� �� ������"}
procedure TgdcBase.SaveToStream(Stream: TStream;  DetailDS: TgdcBase;
  const BL: TBookmarkList = nil; const OnlyCurrent: Boolean = True);
var
  MS: TMemoryStream;
  OS: TgdcObjectSet;
  Bm: TBookmarkStr;
  I: Integer;
  WasActive: Boolean;

  procedure SaveDetail;
  var
    DBm: TBookmarkStr;
    OldModifyFS: Boolean;
  begin
    if DetailDS <> nil then
    begin
      OldModifyFS := DetailDS.ModifyFromStream;
      DetailDS.ModifyFromStream := True;
      DetailDS.DisableControls;
      try
        DBm := DetailDS.Bookmark;
        DetailDS.First;
        while not DetailDS.EOF do
        begin
          DetailDS._SaveToStream(MS, OS, nil, nil, nil);
          DetailDS.Next;
        end;
        DetailDS.Bookmark := DBm;
      finally
        DetailDS.EnableControls;
        DetailDS.ModifyFromStream := OldModifyFS;
      end;
    end;
  end;

var
  OldModifyFS: boolean;
begin
  MS := TMemoryStream.Create;
  OS := TgdcObjectSet.Create(TgdcBase, '');

  AddText('�������� ���������� ������ � �����.', clBlack);

  WasActive := Transaction.InTransaction;

  try
    if BL <> nil then
      BL.Refresh;

    if DetailDS <> nil then
      DetailDS.DisableControls;

    OldModifyFS := ModifyFromStream;
    ModifyFromStream := True;
    try
      if OnlyCurrent then
      begin
        _SaveToStream(MS, OS, nil, nil, nil);
        SaveDetail;
      end else begin
        Bm := Bookmark;
        DisableControls;

        try
          if BL = nil then
          begin
            First;
            while not EOF do
            begin
              _SaveToStream(MS, OS, nil, nil, nil);
              SaveDetail;
              Next;
            end;
          end else
          begin
            for I := 0 to BL.Count - 1 do
            begin
              Bookmark := BL[I];
              _SaveToStream(MS, OS, nil, nil, nil);
              SaveDetail;
            end;
          end;
        finally
          Bookmark := Bm;
          EnableControls;
        end;
      end;
    finally
      if DetailDS <> nil then
        DetailDS.EnableControls;
      ModifyFromStream := OldModifyFS;
    end;

    // � �������� ���������� �� ������������ �����
    // �������� ������ �� ������������
    if Transaction.InTransaction then
    begin
      if WasActive then
        Transaction.CommitRetaining
      else
        Transaction.Commit;
    end;

  finally
    AddText('��������� ���������� ������ � �����.', clBlack);

    OS.SaveToStream(Stream);
    Stream.CopyFrom(MS, 0);

    MS.Free;
    OS.Free;
  end;
end;

procedure TgdcBase.LoadFromStream(Stream: TStream);
var
  OS: TgdcObjectSet;
  DidActivate: Boolean;
begin
  DidActivate := False;
  OS := TgdcObjectSet.Create(TgdcBase, '');
  try
    try
      DidActivate := ActivateTransaction;
      OS.LoadFromStream(Stream);
      _LoadFromStream(Stream, nil, OS, nil);
      if DidActivate and Transaction.InTransaction then
        Transaction.Commit;
    except
      if DidActivate and Transaction.InTransaction then
        Transaction.Rollback;
      raise;
    end;
  finally
    OS.Free;
  end;
end;

function TgdcBase.QuerySaveFileName(const AFileName: String = '';
  const aDefaultExt: String = datExtension;
  const aFilter: String = datDialogFilter): String;
begin
  if AFileName = '' then
  begin
    with TSaveDialog.Create(FParentForm) do
    try
      Options := [ofOverwritePrompt,ofHideReadOnly,ofPathMustExist,
        ofNoReadOnlyReturn,ofEnableSizing];
      DefaultExt := aDefaultExt;
      Filter := aFilter;
      if Assigned(UserStorage) then
      begin
        InitialDir := UserStorage.ReadString('GDC\' + Self.ClassName + SubType, 'SaveDir', '');
        FileName := CorrectFileName(FieldByName(GetListField(SubType)).AsString);
      end;
      if not Execute then
      begin
        Result := '';
        exit;
      end;
      if Assigned(UserStorage) then
      begin
        UserStorage.WriteString('GDC\' + Self.ClassName + SubType, 'SaveDir', InitialDir);
      end;
      Result := FileName;
    finally
      Free;
    end
  end else
    Result := AFileName;
end;

function TgdcBase.QueryLoadFileName(
  const AFileName: String = '';
  const aDefaultExt: String = datExtension;
  const aFilter: String = datDialogFilter): String;
begin
  Result := AFileName;

  if not FileExists(Result) then
  begin
    with TOpenDialog.Create(nil) do
    try
      Options := [ofPathMustExist, ofFileMustExist, ofEnableSizing];
      DefaultExt := aDefaultExt;
      Filter := aFilter;
      {$IFDEF GEDEMIN}
      if (AFileName = '') and Assigned(UserStorage) then
      begin
        InitialDir := UserStorage.ReadString('GDC\' + Self.ClassName + SubType, 'SaveDir', '');
        FileName := UserStorage.ReadString('GDC\' + Self.ClassName + SubType, 'SaveFileName', '');
      end else
      {$ENDIF}
        FileName := Result;
      if not Execute then
        Result := ''
      else
      begin
        {$IFDEF GEDEMIN}
        if (AFileName = '') and Assigned(UserStorage) then
        begin
          UserStorage.WriteString('GDC\' + Self.ClassName + SubType, 'SaveDir', InitialDir);
          UserStorage.WriteString('GDC\' + Self.ClassName + SubType, 'SaveFileName', FileName);
        end;
        {$ENDIF}
        Result := FileName;
      end;
    finally
      Free;
    end;
  end;
end;

procedure TgdcBase.GetWhereClauseConditions(S: TStrings);
var
  I: Integer;
  Str: String;
begin
  { TODO :
������ ��� �� ����� ���� ��������!
�������� � �������� ��� ��������� }
  if HasSubSet('ByID') then
    S.Add(Format('%s.%s=:%s', [GetListTableAlias, GetKeyField(SubType), GetKeyField(SubType)]))
  else if HasSubSet('ByName') then
    S.Add(Format('%s.%s=:%s', [GetListTableAlias, GetListField(SubType), GetListField(SubType)]))
  { TODO -oJulia : �������� �� ������ � �������� ByID,
  �� � � �������� OnlySelected. � ��������� �������
  ��� ���� ����� ����������� ��� ���������. ��� �����,
  ��� �� ���������� ������� ByID.
  ��� ������ ��������� ���������, ������ ��� ���� ������ �����
  �������������� �� �������������� � �������.
  ������� �� ����� ������������� ��� ���� (��� �������)
  ��� ��������, � ������� ��������. }
  else if HasSubSet('OnlySelected') then
  begin
    Str := '';
    for I := 0 to FSelectedID.Count - 1 do
    begin
      if Length(Str) >= 8192 then break;
      Str := Str + IntToStr(FSelectedID[I]) + ',';
    end;
    if Str = '' then
      Str := '-1'
    else
      SetLength(Str, Length(Str) - 1);
    S.Add(Format('%s.%s IN (%s)', [GetListTableAlias, GetKeyField(SubType), Str]));
  end;
  
  S.Add(GetSecCondition);
end;

function TgdcBase.GetCreationDate: TDateTime;
begin
  if tiCreationDate in gdcTableInfos then
    Result := FieldByName(fncreationdate).AsDateTime
  else
    Result := GetEditionDate;
end;

function TgdcBase.GetCreatorKey: TID;
begin
  if tiCreatorKey in gdcTableInfos then
    Result := FieldByName(fncreatorkey).AsInteger
  else
    Result := GetEditorKey;
end;

function TgdcBase.GetCreatorName: String;
var
  q: TIBSQL;
begin
  q := TIBSQL.Create(nil);
  try
    q.Database := Database;
    q.Transaction := ReadTransaction;
    q.SQL.Text := 'SELECT name FROM gd_contact WHERE id=:ID';
    q.Params[0].AsInteger := CreatorKey;
    q.ExecQuery;
    if q.EOF then
      Result := ''
    else
      Result := q.Fields[0].AsString;
  finally
    q.Free;
  end;
end;

function TgdcBase.GetEditionDate: TDateTime;
var
  RR: TRUIDRec;
begin
  if tiEditionDate in gdcTableInfos then
    Result := FieldByName(fneditiondate).AsDateTime
  else begin
    RR := gdcBaseManager.GetRUIDRecByID(ID, ReadTransaction);
    if RR.XID = -1 then
      Result := Now
    else
      Result := RR.Modified;
  end;
end;

function TgdcBase.GetEditorKey: TID;
var
  RR: TRUIDRec;
begin
  if tiEditorKey in gdcTableInfos then
    Result := FieldByName(fneditorkey).AsInteger
  else begin
    RR := gdcBaseManager.GetRUIDRecByID(ID, ReadTransaction);
    if RR.XID = -1 then
      Result := IBLogin.ContactKey
    else
      Result := RR.EditorKey;
  end;
end;

function TgdcBase.GetEditorName: String;
var
  q: TIBSQL;
begin
  q := TIBSQL.Create(nil);
  try
    q.Database := Database;
    q.Transaction := ReadTransaction;
    q.SQL.Text := 'SELECT name FROM gd_contact WHERE id=:ID';
    q.Params[0].AsInteger := EditorKey;
    q.ExecQuery;
    if q.EOF then
      Result := ''
    else
      Result := q.Fields[0].AsString;
  finally
    q.Free;
  end;
end;

function TgdcBase.GetExtraConditions: TStrings;
begin
  Result := FExtraConditions;
end;

procedure TgdcBase.DoAfterExtraChanged(Sender: TObject);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  WasActive: Boolean;
begin
  {@UNFOLD MACRO INH_ORIG_SENDER('TGDCBASE', 'DOAFTEREXTRACHANGED', KEYDOAFTEREXTRACHANGED)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOAFTEREXTRACHANGED);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTEREXTRACHANGED]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(Sender)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOAFTEREXTRACHANGED', KEYDOAFTEREXTRACHANGED, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  WasActive := Active;
  Close;
  FSQLInitialized := False;
  Active := WasActive;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOAFTEREXTRACHANGED', KEYDOAFTEREXTRACHANGED)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOAFTEREXTRACHANGED', KEYDOAFTEREXTRACHANGED);
  {M}  end;
  {END MACRO}
end;

function TgdcBase.GetDSModified: Boolean;
begin
  Result := FDSModified or
    (State = dsInsert) or
    ((FOldValues <> nil) and (FOldValues.Count > 0)) or
    (CachedUpdates and UpdatesPending);
end;

procedure TgdcBase.DoAfterTransactionEnd(Sender: TObject);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_SENDER('TGDCBASE', 'DOAFTERTRANSACTIONEND', KEYDOAFTERTRANSACTIONEND)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOAFTERTRANSACTIONEND);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERTRANSACTIONEND]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(Sender)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOAFTERTRANSACTIONEND', KEYDOAFTERTRANSACTIONEND, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FDSModified := False;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOAFTERTRANSACTIONEND', KEYDOAFTERTRANSACTIONEND)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOAFTERTRANSACTIONEND', KEYDOAFTERTRANSACTIONEND);
  {M}  end;
  {END MACRO}
end;

function TgdcBase.GetSelectedID: TgdKeyArray;
begin
  Result := FSelectedID;
end;

procedure TgdcBase.AddToSelectedID(const AnID: Integer = -1);
var
  AddId: Integer;
begin
  if AnID = -1 then
    AddId := ID
  else
    AddId := AnID;

  FSelectedID.Add(AddId, True);

  if HasSubSet('OnlySelected') then
    FSQLInitialized := False;
end;

procedure TgdcBase.AddToSelectedID(ASelectedID: TgdKeyArray);
var
  I: Integer;
begin
  for I := 0 to ASelectedID.Count - 1 do
    FSelectedID.Add(ASelectedID.Keys[I], True);

  if HasSubSet('OnlySelected') then
    FSQLInitialized := False;
end;

procedure TgdcBase.RemoveFromSelectedID(const AnID: Integer = -1);
var
  DelId: Integer;
begin
  if AnID = -1 then
    DelId := ID
  else
    DelId := AnID;

  FSelectedID.Remove(DelId);

  { TODO :
��� ������� �������� ������� ��� ��������� ������
��������� ����� ���������� �� �������� �� �����
��������� � ����� ������� � ������� � ���������������
������������� ��, �� ���������� ������ ��� ���������������
������, ��� ����� ���� ����� ������! }
  if HasSubSet('OnlySelected') then
    FSQLInitialized := False;
end;

function TgdcBase.CheckTheSame(Modify: Boolean = False): Boolean;
var
  q: TIBSQL;
  I: Integer;
  CDS: TClientDataSet;
  R: TatRelation;
  F: TatRelationField;
  ChkStm: String;
begin
  if not (State = dsInsert) then
    raise EgdcException.CreateObj('������ ������ ���������� � ��������� �������!', Self);

  Result := False;
  ChkStm := CheckTheSameStatement;

  if ChkStm = '' then
    exit;

  q := TIBSQL.Create(nil);
  try
    q.Database := Database;
    q.Transaction := ReadTransaction;
    q.SQL.Text := ChkStm;
    q.ExecQuery;
    q.Next;

    if q.RecordCount = 1 then
    begin       
      AddText('������ ������ �� ����������� ����� ' + ClassName + ' ' +
        RUIDToStr(GetRUID) + ' "' + FieldByName(GetListField(SubType)).AsString + '"', clBlack);
      if (sLoadFromStream in BaseState) and NeedDeleteTheSame(SubType) then
      begin
        DeleteTheSame(q.Fields[0].AsInteger, FieldByName(GetListField(SubType)).AsString);
      end else
      begin
        CDS := TClientDataSet.Create(nil);
        try
          if Modify and (sLoadFromStream in BaseState) then
          begin
            for I := 0 to FieldDefs.Count - 1 do
            begin
            //����� ��������� ���� ��-������, �.�. ��� ����� ����� ��� ��� ���� �������������
              CDS.FieldDefs.Add(FieldDefs[I].Name, FieldDefs[I].DataType, FieldDefs[I].Size, False)
            end;
            CDS.CreateDataSet;
            CDS.Open;
            CDS.Insert;
            try
              for I := 0 to Fields.Count - 1 do
              begin
                if (CDS.FieldByName(Fields[I].FieldName).DataType = ftString) and
                  (FieldByName(Fields[I].FieldName).AsString = '')
                then
                  CDS.FieldByName(Fields[I].FieldName).AsString := ''
                else
                  CDS.FieldByName(Fields[I].FieldName).Value := FieldByName(Fields[I].FieldName).Value;
              end;
              CDS.Post;
            except
              if CDS.State in dsEditModes then
                CDS.Cancel;
              raise;
            end;
          end;

          Cancel;
          ID := q.Fields[0].AsInteger;
          Result := RecordCount > 0;
          if not Result then
            raise EgdcIBError.Create('������ ' + GetListTable(SubType) + ' '+
              ' � ��������������� ' +  q.Fields[0].AsString +
              ' �� �������! ');

          if Modify and
            (
              ModifyFromStream
              and
              (sLoadFromStream in BaseState)
              and
              CheckNeedModify(CDS, nil)
            ) then
          begin
            try
              Edit;
              try
                for I := 0 to Fields.Count - 1 do
                begin
                  R := nil;
                  F := nil;
                  if (FieldByName(Fields[I].FieldName).AsString = IntToStr(ID)) and
                    Assigned(atDatabase) then
                  begin
                   //��������� �� �������� �� ���� ����, ���������� �������� = keyfield, �������
                    R := atDatabase.Relations.ByRelationName(RelationByAliasName(Fields[I].FieldName));
                    if Assigned(R) then
                      F := R.RelationFields.ByFieldName(FieldNameByAliasName(Fields[I].FieldName));
                  end;

                  if ((not Assigned(R)) or (not Assigned(F)) or (F.References = nil)) and
                    (AnsiCompareText(Fields[I].FieldName, GetKeyField(SubType)) <> 0)
                  then
                  begin
                    if (FieldByName(Fields[I].FieldName).DataType = ftString) and
                      (CDS.FieldByName(Fields[I].FieldName).AsString = '')
                    then
                      FieldByName(Fields[I].FieldName).AsString := ''
                    else
                      FieldByName(Fields[I].FieldName).Value := CDS.FieldByName(Fields[I].FieldName).Value;
                  end;
                end;
                Post;
              except
                if State in dsEditModes then
                  Cancel;
                raise;
              end;
              AddText('�������� ������ ' + ClassName + ' ' + RUIDToStr(GetRUID) + ' "' +
                FieldByName(GetListField(SubType)).AsString + '"', clBlack);
            except
              Cancel;
            end;
          end;
        finally
          CDS.Free;
        end;
      end;
    end;
  finally
    q.Free;
  end;
end;

function TgdcBase.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  F: TField;
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCBASE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Result := '';//inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result := ''
  else begin
    F := FieldByName(GetKeyField(SubType));
    if (not EOF) and (F.AsInteger < cstUserIDStart) and (not F.IsNull) then
      Result := Format('SELECT %0:s FROM %1:s WHERE %0:s=%2:d ',
        [GetKeyField(SubType), GetListTable(SubType), F.AsInteger])
    else
      Result := '';
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcBase.CommitRequired: Boolean;
begin
  Result := False;
end;

procedure TgdcBase.ExecSingleQuery(const S: String; Param: Variant);
begin
  gdcBaseManager.ExecSingleQuery(S, Param, Transaction);
end;

function TgdcBase.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCBASE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Result := '';//Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := Format('FROM %s %s ', [GetListTable(SubType), GetListTableAlias]);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.InternalSetFieldData(Field: TField; Buffer: Pointer);
var
  DW: Integer;
begin
  if FDataTransfer then
    inherited InternalSetFieldData(Field, Buffer)
  else begin
    if State = dsEdit then
    begin
      if TestUserRights([tiAChag]) then
      begin
        if (not FIsNewRecord) and ((FBaseState * [sDialog, sView]) <> [])
          and (not (sLoadFromStream in FBaseState)) then
        begin
          if
            ((Field.DataType = ftString)
              and ((Field.FieldName = 'NAME') or (Field.FieldName = 'USR$NAME') or (Field.FieldName = 'FULLNAME'))) or
            ((Field.DataType = ftInteger)
              and ((Field.FieldName = 'PARENT') or (Field.FieldName = 'COMPANYKEY'))) or
            ((Field.DataType = ftDate)
              and (Field.FieldName = 'DOCUMENTDATE')) then
          begin
            if not TestUserRights([tiAFull]) then
              raise EgdcUserHaventRights.CreateObj('��� ��������� ���� ' + Field.DisplayName + ' ���������� ������ ����� �������.',
                Self);
          end;
        end;
      end;

      UpdateOldValues(Field);
    end;
    inherited InternalSetFieldData(Field, Buffer);
    if not FIsNewRecord then
    begin
      if ([sView, sDialog] * BaseState <> [])
        and (not Field.IsNull)
        and Assigned(GlobalStorage) then
      begin
        if (Field is TDateTimeField) or (Field is TDateField) then
        begin
          DW := GlobalStorage.ReadInteger('Options', 'DatesWindow', 10, False);
          if (DW > 0) and
            (Field.AsDateTime > 1) and
            ((Field.AsDateTime < Now - DW * 365) or (Field.AsDateTime > Now + DW * 365)) then
          begin
            // ���� ���������� �����, ��� ������� ��� ���� ��������� �� ����� ���������,
            // ���� ������������ ParentHandle, �� ���������� ����� ����� '��������'.
            MessageBox(Application.Handle,
              PChar('���������, �������� �� ��������� ���� ���� "' +
                FormatDateTime('dd.mm.yyyy', Field.AsDateTime) + '" ����������.'#13#10#13#10 +
                '��������� ������ �������� ����� � ���� �����, ���� ������.'),
              '��������',
              MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
          end;
        end;
      end;

      {������ �����: ���� ������ ����� ��� ������� �������� DoFieldChange
       ����, �� ����� ���������� ��� ���� �� ������������ ����� � ��������
       ���� ������ �� ����, �� ���������� ������ ��� �����, ���������� � ������
      }
      {if ((FFieldsCallDoChange.Count = 0) and (not Field.Calculated)) or
        (FFieldsCallDoChange.IndexOf(Field.FieldName) > -1) then}
      FInDoFieldChange := True;
      try
        if CallDoFieldChange(Field) then
        begin
          DoFieldChange(Field);
        end;
        SyncField(Field);
      finally
        FInDoFieldChange := False;
      end;
    end;
  end;
end;

procedure TgdcBase.InternalPrepare;
var
  I, J: Integer;
begin
  if not FSQLInitialized then
    InitSQL;

  try
    inherited InternalPrepare;
  except
    Clear_atSQLSetupCache;
    raise;
  end;

  { TODO :
���������-��������������� ���� ������ �� ���������
������� �� ��������� � ����� ������-������ }
  if FSavedParams.Count > 0 then
  begin
    for I := 0 to FSavedParams.Count - 1 do
      for J := 0 to Params.Count - 1 do
        with FSavedParams[I] as TFieldValue do
          if AnsiCompareText(Params[J].Name, FieldName) = 0 then
          begin
            if IsNull then
              Params[J].Clear
            else
              Params[J].AsString := Value;
            break;  
          end;

    FSavedParams.Clear;
  end;
end;

procedure TgdcBase.UnPrepare;
begin
  InternalUnprepare;
  FSQLInitialized := False;
end;

procedure TgdcBase.InternalOpen;
begin
  ActivateConnection;
  ActivateReadTransaction;
  if not FSQLInitialized then
    InitSQL;
  InternalSetParamsFromCursor;
  try
    inherited InternalOpen;
  except
    on E: EIBError do
    begin
      if E.IBErrorCode = isc_io_error then
      begin
        MessageBox(ParentHandle,
          '��������� ������ ��� �������� ����� ����������.'#13#10 +
          '��������, ����������� ��������� ����� �� �����, ���'#13#10 +
          '��������� ������� ��� ��������� ������ �������'#13#10 +
          'Interbase/Firebird. ���������� �����, ��������� ������'#13#10 +
          '����� ��� ���������������� ������, ����� �� ��������'#13#10 +
          '� ������� ������� ������.',
          '������',
          MB_OK or MB_ICONHAND);
        Abort;
      end else
        raise;
    end;
  end;
end;

procedure TgdcBase._DoOnNewRecord;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  FN: String;
  I, AView, AChag, AFull: Integer;
  MO: TDataSet;
  F: TField;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  // �������� ����� �� �������� ������
  if not CanCreate then
    raise EgdcException.CreateObj('Access denied', Self);

  // ����������� ���������� ������������� ������
  if gdcBaseInterface.tiID in gdcTableInfos then
  begin
    FieldByName(GetKeyField(SubType)).AsInteger := GetNextID;
  end;

  if gdcBaseInterface.tiXID in gdcTableInfos then
  begin
    FieldByName(fnxid).AsInteger := FieldByName(GetKeyField(SubType)).AsInteger;
  end;

  if gdcBaseInterface.tiDBID in gdcTableInfos then
  begin
    if FieldByName(GetKeyField(SubType)).AsInteger < cstUserIDStart then
      FieldByName(fndbid).AsInteger := cstEtalonDBID
    else
      FieldByName(fndbid).AsInteger := IBLogin.DBID;
  end;

  // ���� ���� ���� ���������, �� ����������� ���
  if gdcBaseInterface.tiDisabled in gdcTableInfos then
  begin
    FieldByName(fndisabled).AsInteger := 0;
  end;

  if tiCreatorKey in gdcTableInfos then
    FieldByName(fnCREATORKEY).AsInteger := IBLogin.ContactKey;

  if tiCreationDate in gdcTableInfos then
    FieldByName(fnCREATIONDATE).AsDateTime := SysUtils.Now;

  if tiEditorKey in gdcTableInfos then
    FieldByName(fnEDITORKEY).AsInteger := IBLogin.ContactKey;

  if tiEditionDate in gdcTableInfos then
    FieldByName(fnEDITIONDATE).AsDateTime := SysUtils.Now;

  // ���� ������ ������ � ������ ��������, �� ����������������� ������
  if (MasterSource <> nil)
    and (MasterSource.DataSet <> nil)
    and MasterSource.DataSet.Active
    and (FgdcDataLink.FMasterField.Count > 0)
    and (FgdcDataLink.FDetailField.Count > 0) then
  begin
    MO := MasterSource.DataSet;

    if (tiAView in gdcTableInfos) and (MO.FindField(fnaview) <> nil) then
      FieldByName(fnaview).AsInteger := MO.FieldByName(fnaview).AsInteger;
    if (tiAChag in gdcTableInfos) and (MO.FindField(fnachag) <> nil) then
      FieldByName(fnachag).AsInteger := MO.FieldByName(fnachag).AsInteger;
    if (tiAFull in gdcTableInfos) and (MO.FindField(fnafull) <> nil) then
      FieldByName(fnafull).AsInteger := MO.FieldByName(fnafull).AsInteger;
  end
  else begin
    MO := nil;

    gdcBaseManager.Class_GetSecDesc(Self.ClassType, SubType,
      AView, AChag, AFull);

    if tiAView in gdcTableInfos then
      FieldByName(fnaview).AsInteger := AView;
    if tiAChag in gdcTableInfos then
      FieldByName(fnachag).AsInteger := AChag;
    if tiAFull in gdcTableInfos then
      FieldByName(fnafull).AsInteger := AFull;
  end;

  if (MO <> nil) and (MO.State <> dsSetKey) then
    with FgdcDataLink do
  begin
    if FSetTable = '' then
    begin
      for I := 0 to FDetailField.Count - 1 do
        if (UpperCase(FDetailField[I]) <> 'LB') and (UpperCase(FDetailField[I]) <> 'RB') then
        begin
          FN := GetFieldNameComparedToParam(FDetailField[I]);

          if (AnsiCompareText(GetKeyField(SubType), FN) <> 0)
            or (not MO.FieldByName(FMasterField[I]).IsNull) then
          begin
            if FindField(FN) <> nil then
            begin
              FieldByName(FN).Assign(MO.FieldByName(FMasterField[I]));
            end;
            {��������� ���� ����� �� �������������� � �������, ��������,
             ��� ��������, ��� ����� ���� ����� :rootid}
          end;
        end
    end else begin
      { TODO : ��������������� ����������� ��� ���� �� }
      FieldByName(cstSetPrefix + FSetMasterField).AsInteger := MO.FieldByName(fnid).AsInteger;
      FieldByName(cstSetPrefix + FSetItemField).AsInteger := ID;
    end;
  end;

  { TODO : � ���� ��� ���������� ���� ������� �������� ������ ������? }
  for i := 0 to Fields.Count - 1 do
  begin
    F := Fields[i];

    if F.IsNull and (F.DefaultExpression > '') then
    try
      F.Value := GetDefaultExpression(F.DefaultExpression);
    except
    end
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

class function TgdcBase.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := '';
end;

class function TgdcBase.IsAbstractClass: Boolean;
begin
  Result := Self.ClassNameIs('TgdcBase');
end;

function TgdcBase.GetSubSet: TgdcSubSet;
begin
  if Assigned(FSubSets) then
    Result := FSubSets.CommaText
  else
    Result := '';
end;

function TgdcBase.GetSubSetCount: Integer;
begin
  Result := FSubSets.Count;
end;

function TgdcBase.GetSubSets(Index: Integer): TgdcSubSet;
begin
  Result := FSubSets[Index];
end;

procedure TgdcBase.SetSubSets(Index: Integer; const Value: TgdcSubSet);
begin
  if CheckSubSet(Value) then
    FSubSets[Index] := Value
  else
    raise EgdcException.CreateObj('Invalid sub set', Self);  
end;

procedure TgdcBase.DeleteSubSet(const Index: Integer);
var
  WasActive: Boolean;
begin
  if Index > -1 then
  begin
    WasActive := Active;
    Close;
    FSubSets.Delete(Index);
    FSQLInitialized := False;
    Active := WasActive;
    if Assigned(FOnFilterChanged) then
      FOnFilterChanged(Self);
  end;
end;

function TgdcBase.HasSubSet(const ASubSet: TgdcSubSet): Boolean;
begin
  Result := FSubSets.IndexOf(ASubSet) <> -1;
end;

procedure TgdcBase.RemoveSubSet(const ASubSet: TgdcSubSet);
begin
  DeleteSubSet(FSubSets.IndexOf(ASubSet));
end;

procedure TgdcBase.AddSubSet(const ASubSet: TgdcSubSet);
var
  WasActive: Boolean;
begin
  if not CheckSubSet(ASubSet) then
    raise EgdcException.CreateObj('Invalid sub set', Self);

  if (FSubSets.IndexOf(ASubSet) = -1) then
  begin
    WasActive := Active;
    Close;
    FSubSets.Add(ASubSet);
    FSQLInitialized := False;
    Active := WasActive;
    if Assigned(FOnFilterChanged) then
      FOnFilterChanged(Self);
  end;
end;

procedure TgdcBase.ClearSubSets;
var
  WasActive: Boolean;
begin
  WasActive := Active;
  Close;
  FSubSets.Clear;
  FSubSets.Add('All');
  FSQLInitialized := False;
  Active := WasActive;
  if Assigned(FOnFilterChanged) then
    FOnFilterChanged(Self);
end;

procedure TgdcBase.InternalUnPrepare;
var
  I: Integer;
  FV: TFieldValue;
  SL: TStringList;
begin
  FSavedParams.Clear;
  SL := TStringList.Create;
  try
    for I := 0 to Params.Count - 1 do
    begin
      if SL.IndexOf(Params[I].Name) = -1 then
      begin
        FV := TFieldValue.Create;
        FV.FieldName := Params[I].Name;
        FV.Value := Params[I].AsString;
        FV.IsNull := Params[I].IsNull;
        FSavedParams.Add(FV);
        SL.Add(Params[I].Name);
      end;
    end;
  finally
    SL.Free;
  end;

  inherited;
end;

procedure TgdcBase.LoadDialogDefaults;
{$IFDEF GEDEMIN}
var
  F: TgsStorageFolder;
  DlgForm: TForm;
  N: String;
{$ENDIF}
begin
  if Assigned(UserStorage) and UserStorage.ReadBoolean('Options', 'DialogDefaults', True) then
  begin
    {$IFDEF GEDEMIN}
    N := 'GDC\' + ClassName + SubType + '\';
    if FDlgStack.Count > 0 then
    begin
      DlgForm := FDlgStack.Peek as TForm;
      N := N + DlgForm.ClassName;
    end else
    begin
      DlgForm := nil;
      N := N + '_Saved';
    end;

    if Assigned(UserStorage) then
    begin
      F := UserStorage.OpenFolder(N, False, False);
      try
        if F <> nil then
          LoadDialogDefaults(F, DlgForm);
      finally
        UserStorage.CloseFolder(F);
      end;
    end;
    {$ENDIF}
    {
    end else
      raise Exception.Create(GetGsException(Self, 'No dialog form found'));
    }
  end;
end;

procedure TgdcBase.SaveDialogDefaults;
{$IFDEF GEDEMIN}
var
  DlgForm: TForm;
  F: TgsStorageFolder;
  FolderName: String;
  Created, NoData: Boolean;
{$ENDIF}
begin
  if Assigned(UserStorage) and UserStorage.ReadBoolean('Options', 'DialogDefaults', True) then
  begin
    {$IFDEF GEDEMIN}
    FolderName := 'GDC\' + ClassName + SubType + '\';
    if FDlgStack.Count > 0 then
    begin
      DlgForm := FDlgStack.Peek as TForm;
      FolderName := FolderName + DlgForm.ClassName;
    end else
    begin
      DlgForm := nil;
      FolderName := FolderName + '_Saved';
    end;

    if Assigned(UserStorage) and (GetDialogDefaultsFields > '') then
    begin
      Created := not UserStorage.FolderExists(FolderName, False);
      F := UserStorage.OpenFolder(FolderName, True, False);
      try
        if F <> nil then
          SaveDialogDefaults(F, DlgForm);
        NoData := Created and (F.FoldersCount = 0) and (F.ValuesCount = 0);
      finally
        UserStorage.CloseFolder(F, False);
      end;
      if NoData then
      begin
        UserStorage.DeleteFolder(FolderName, False);
        FolderName := 'GDC\' + ClassName + SubType;
        F := UserStorage.OpenFolder(FolderName, False, False);
        try
          NoData := (F <> nil) and (F.FoldersCount = 0) and (F.ValuesCount = 0);
        finally
          UserStorage.CloseFolder(F, False);
        end;
        if NoData then
        begin
          UserStorage.DeleteFolder(FolderName, False);
        end;
      end;
      UserStorage.CloseFolder(UserStorage.OpenFolder('\', False), True);
    end;
    {$ENDIF}
  end;
end;

function TgdcBase.CreateReadIBSQL: TIBSQL;
begin
  Result := TIBSQL.Create(nil);
  Result.Database := Database;
  if ReadTransaction = nil then
    Result.Transaction := gdcBaseManager.ReadTransaction
  else
    Result.Transaction := ReadTransaction;
end;

function TgdcBase.CreateReadIBSQL(out DidActivate: Boolean): TIBSQL;
begin
  Result := CreateReadIBSQL;
  DidActivate := not Result.Transaction.InTransaction;
  if DidActivate then
    Result.Transaction.StartTransaction;
end;

class function TgdcBase.CreateSingularByID(AnOwner: TComponent;
  const AnID: TID; const ASubType: String): TgdcBase;
begin
  if AnID = -1 then
    raise EgdcIDNotFound.Create(Self.ClassName + ': empty ID (-1) specified')
  else
  begin
    Result := Self.CreateSubType(AnOwner, ASubType, 'ByID');
    Result.ParamByName(Result.GetKeyField(ASubType)).AsInteger := AnID;
    Result.Open;
    Result.Next;
    if Result.RecordCount = 0 then
    begin
      Result.Free;
      raise EgdcIDNotFound.Create(Self.ClassName + ': ID not found (' + IntToStr(AnID) + ')');
    end else if Result.RecordCount > 1 then
    begin
      Result.Free;
      raise EgdcIDNotFound.Create(Self.ClassName + ': ���� ������������� (' +
        IntToStr(AnID) + ') ���������� ��������� �������! '#13#10 +
        '��������� ������������ ���������� ������� (�������� SelectSQL)');
    end else
       Result.First;
  end;
end;

procedure TgdcBase.SetTransaction(Value: TIBTransaction);
var
  OldTr: TIBTransaction;
  I: Integer;
begin
  if Transaction <> Value then
  begin
    // ���� �� �������� ��������� ������ ���������� ������
    // ���������� � ���������� ���������� ������������ ������
    // � ��� � ��� �������, �� ������� ������.
    // ����� �������� ������� � ���, ��� ����������� �����
    // ������� ��������, ����������� ��������� ���������,
    // ������ ������� ���������� �, �� ������ ��, �.�. ��
    // �������� ������� �������� �������� �������������
    // ����������
    if Assigned(Transaction) and (Transaction = FInternalTransaction)
      and Transaction.InTransaction
      and (Transaction.SQLObjectCount = 1) then
    begin
      if Transaction <> ReadTransaction then
        raise Exception.Create(GetGsException(Self, 'Transaction active'))
      else
        Transaction.Commit;
    end;

    OldTr := Transaction;

    inherited;

    if FDetailLinks <> nil then
    begin
      for I := 0 to FDetailLinks.Count - 1 do
      begin
        if (FDetailLinks[I] is TIBCustomDataSet)
          and (TIBCustomDataSet(FDetailLinks[I]).Transaction = OldTr) then
        begin
          TIBCustomDataSet(FDetailLinks[I]).Transaction := Value;
        end;
      end;
    end;  
  end;
end;

procedure TgdcBase.InternalSetParamsFromCursor;
var
  i: Integer;
  cur_param: TIBXSQLVAR;
  cur_field: TField;
  s: TStream;
begin
  if FQSelect.SQL.Text = '' then
    IBError(ibxeEmptyQuery, [nil]);
  {if not FInternalPrepared then
    InternalPrepare;}
  if (SQLParams.Count > 0) and (FgdcDataLink <> nil) and (FgdcDataLink.DataSet <> nil)
    and (FgdcDataLink.FDetailField.Count > 0) then
  begin
    for I := 0 to FgdcDataLink.FMasterField.Count - 1 do
    begin
      cur_field := FgdcDataLink.DataSet.FindField(FgdcDataLink.FMasterField[I]);
      cur_param := ParamByName(FgdcDataLink.FDetailField[I]);
      if (cur_field <> nil) then
      begin
        if (cur_field.IsNull) then
        begin
          {
          ���� ������ ��������, � ������ ������� ���������, ��
          ���� � ������� �� ����� �� ����� ������
          �� ���������� ������� ���������� ������� ������
          ��������� �������� ��������� ���, �� �����
          ����� �� ������� ���������� �������� � �������
          ��������� ���������� �������.
          ���� ����������� -1.
          }
          { TODO : ����� ��� ��������� �� ������� ���������? }

          if (FgdcDataLink.DataSet.IsEmpty
              {$IFDEF NEW_GRID}
              or ((FgdcDataLink.DataSet is TIBCustomDataSet) and (PRecordData(FgdcDataLink.DataSet.ActiveBuffer)^.rdRecordKind <> rkRecord))
              {$ENDIF}
              )
            and (cur_field.DataType = ftInteger) then
          begin
            cur_param.AsLong := -1;
          end else
            cur_param.IsNull := True;
        end
        else case cur_field.DataType of
          ftString:
            cur_param.AsString := cur_field.AsString;
          ftBoolean, ftSmallint, ftWord:
            cur_param.AsShort := cur_field.AsInteger;
          ftInteger:
          {begin
            if FgdcDataLink.DataSet.IsEmpty then
              cur_param.AsLong := -1
            else}
              cur_param.AsLong := cur_field.AsInteger;
          {end;}
          ftLargeInt:
            cur_param.AsInt64 := TLargeIntField(cur_field).AsLargeInt;
          ftFloat, ftCurrency:
           cur_param.AsDouble := cur_field.AsFloat;
          ftBCD:
            cur_param.AsCurrency := cur_field.AsCurrency;
          ftDate:
            cur_param.AsDate := cur_field.AsDateTime;
          ftTime:
            cur_param.AsTime := cur_field.AsDateTime;
          ftDateTime:
            cur_param.AsDateTime := cur_field.AsDateTime;
          ftBlob, ftMemo:
          begin
            s := nil;
            try
              s := FgdcDataLink.DataSource.DataSet.
                     CreateBlobStream(cur_field, DB.bmRead);
              cur_param.LoadFromStream(s);
            finally
              s.free;
            end;
          end;
          else
            IBError(ibxeNotSupported, [nil]);
        end;
      end;
    end;

    {
    for i := 0 to SQLParams.Count - 1 do
    begin
      cur_field := DataSource.DataSet.FindField(SQLParams[i].Name);
      cur_param := SQLParams[i];
      if (cur_field <> nil) then
      begin
        if (cur_field.IsNull) then
          cur_param.IsNull := True
        else case cur_field.DataType of
          ftString:
            cur_param.AsString := cur_field.AsString;
          ftBoolean, ftSmallint, ftWord:
            cur_param.AsShort := cur_field.AsInteger;
          ftInteger:
            cur_param.AsLong := cur_field.AsInteger;
          ftLargeInt:
            cur_param.AsInt64 := TLargeIntField(cur_field).AsLargeInt;
          ftFloat, ftCurrency:
           cur_param.AsDouble := cur_field.AsFloat;
          ftBCD:
            cur_param.AsCurrency := cur_field.AsCurrency;
          ftDate:
            cur_param.AsDate := cur_field.AsDateTime;
          ftTime:
            cur_param.AsTime := cur_field.AsDateTime;
          ftDateTime:
            cur_param.AsDateTime := cur_field.AsDateTime;
          ftBlob, ftMemo:
          begin
            s := nil;
            try
              s := DataSource.DataSet.
                     CreateBlobStream(cur_field, bmRead);
              cur_param.LoadFromStream(s);
            finally
              s.free;
            end;
          end;
          else
            IBError(ibxeNotSupported, [nil]);
        end;
      end;
    end;
    }
  end;
end;

procedure TgdcBase.RefreshParams;
var
  DataSet: TDataSet;

  function NeedsRefreshing : Boolean;
  var
    i : Integer;
    cur_param: TIBXSQLVAR;
    cur_field: TField;
  begin
    Result := true;
    i := 0;
    while (i < FgdcDataLink.FMasterField.Count) and (Result) do
    begin
      cur_field := MasterSource.DataSet.FindField(FgdcDataLink.FMasterField[I]);
      try
        cur_param := ParamByName(FgdcDataLink.FDetailField[I]);
      except
        MessageBox(0,
          PChar('������ ������: ' + MasterSource.DataSet.Name + #13#10 +
          '��������� ������: ' + Self.Name + #13#10#13#10 +
          '��������, � ��������� ������� ����������� �������� "' + FgdcDataLink.FDetailField[I] +
          '", ������� ������������ � ����� ������-������.'),
          '������',
          MB_OK or MB_ICONSTOP or MB_TASKMODAL);
        raise;
      end;
      if (cur_field <> nil) then
      begin
        if (cur_field.IsNull) then
          Result := Result and cur_param.IsNull
        else
        case cur_field.DataType of
          ftString:
            Result := Result and (cur_param.AsString = cur_field.AsString);
          ftBoolean, ftSmallint, ftWord:
            Result := Result and (cur_param.AsShort = cur_field.AsInteger);
          ftInteger:
            Result := Result and (cur_param.AsLong = cur_field.AsInteger);
          ftLargeInt:
            Result := Result and (cur_param.AsInt64 = TLargeIntField(cur_field).AsLargeInt);
          ftFloat, ftCurrency:
            Result := Result and (cur_param.AsDouble = cur_field.AsFloat);
          ftBCD:
            Result := Result and (cur_param.AsCurrency = cur_field.AsCurrency);
          ftDate:
            Result := Result and (cur_param.AsDate = cur_field.AsDateTime);
          ftTime:
            Result := Result and (cur_param.AsTime = cur_field.AsDateTime);
          ftDateTime:
            Result := Result and (cur_param.AsDateTime = cur_field.AsDateTime);
          else
            Result := false;
        end;
      end;
      Inc(i);
    end;
    Result := not Result;
  end;

begin
  if Assigned(FgdcDataLink) and (FgdcDataLink.DataSource <> nil) then
  begin
    DataSet := FgdcDataLink.DataSource.DataSet;
    if DataSet = Self then
      DatabaseError(SCircularDataLink, Self);
    if DataSet <> nil then
    begin
      if DataSet.Active
        and (DataSet.State <> dsSetKey)
        and NeedsRefreshing then
      begin
        DisableControls;
        try
          Close;
          Open;
        finally
          EnableControls;
        end;
      end;
    end;
  end;
end;

function TgdcBase.OnInvoker(const Name: WideString; AnParams: OleVariant): OleVariant;
var
  LBuff: Pointer;
  LSender: TObject;
  UpperName: string;
  {$IFDEF DEBUG}
  Index: Integer;
  C: Integer;
  {$ENDIF}
begin
  // �������� ����� ������
  UpperName := AnsiUpperCase(Name);

  {$IFDEF DEBUG}
  if InvokeCounts = nil then
  begin
    InvokeCounts := TStringList.Create;
  end;

  Index := InvokeCounts.IndexOfName(UpperName);
  if Index = - 1 then
  begin
     InvokeCounts.Add(Format('%s=1', [UpperName]));
  end else
  begin
    C := StrToInt(InvokeCounts.Values[UpperName]);
    Inc(C);
    InvokeCounts.Values[UpperName] := IntToStr(C);
  end;
  {$ENDIF}

  if  UpperName = 'DOFIELDCHANGE' then
  begin
    DoFieldChange(InterfaceToObject(AnParams[1]) as TField);
  end else
  if  UpperName = GDC_CUSTOMINSERT then
  begin
   {�������������� ���������� ��� ������ �����:
    ��������� �� ��������:
    Param := ����������_�_����(AnParams[...]);
    ��������� �� ������
    Param := ����������_�_����(getVarParam(AnParams[...]));}

    LBuff := Pointer(Integer(AnParams[1]));
    // ����� ������ ����� � ����������� �����������
    // ���� ��� ������, �� �����: Result  := �����_�����, ���� ���, �� �����_�����
    CustomInsert(LBuff);
    // ���� ���� var-��������� �������� �������� ���������� �� ������ � ���������� ������ AnParams
    { EventControl.GetParamInInterface(IDispatch(AnParams[...]), Param);
      ....
    }
  end else
  if  UpperName = '_DOONNEWRECORD' then
  begin
    _DoOnNewRecord;
  end else
  if  UpperName = GDC_CUSTOMDELETE then
  begin
    LBuff := Pointer(Integer(AnParams[1]));
    CustomDelete(LBuff);
  end else
  if  UpperName = GDC_CUSTOMMODIFY then
  begin
    LBuff := Pointer(Integer(AnParams[1]));
    CustomModify(LBuff);
  end else
  if  UpperName = GDC_DoAfterDelete then
  begin
    DoAfterDelete;
  end else
  if  UpperName = GDC_DOAFTERINSERT then
  begin
    DoAfterInsert;
  end else
  if  UpperName = GDC_DOAFTEREDIT then
  begin
    DoAfterEdit;
  end else
  if  UpperName = GDC_DOAFTERPOST then
  begin
    DoAfterPost;
  end else
  if  UpperName = GDC_DOAFTERCANCEL then
  begin
    DoAfterCancel;
  end else
  if  UpperName = GDC_DOBEFOREDELETE then
  begin
    DoBeforeDelete;
  end else
  if  UpperName = GDC_DOBEFOREEDIT then
  begin
    DoBeforeEdit;
  end else
  if  UpperName = GDC_DOBEFOREINSERT then
  begin
    DoBeforeInsert;
  end else
  if  UpperName = GDC_DOBEFOREPOST then
  begin
    DoBeforePost;
  end else
  if  UpperName = 'DOAFTERCUSTOMPROCESS' then
  begin
    LBuff := Pointer(Integer(AnParams[1]));
    DoAfterCustomProcess(LBuff, TgsCustomProcess(AnParams[2]));
  end else
  if  UpperName = GDC_DOAFTEROPEN then
  begin
    DoAfterOpen;
  end else
  if  UpperName = GDC_DOAFTERTRANSACTIONEND then
  begin
    LSender := InterfaceToObject(AnParams[1]);

    DoAfterTransactionEnd(LSender);
  end else
  if  UpperName = GDC_DOBEFORECLOSE then
  begin
    DoBeforeClose;
  end else
  if  UpperName = 'DOBEFOREOPEN' then
  begin
    DoBeforeOpen;
  end else
  if  UpperName = 'CREATEFIELDS' then
  begin
    CreateFields;
  end else
{ if  UpperName = GDC_DOONNEWRECORD then
  begin
    DoOnNewRecord;
  end else}
  if  UpperName = GDC_GETNOTCOPYFIELD then
  begin
    Result := GetNotCopyField;
  end else
  if  UpperName = GDC_GETDIALOGDEFAULTSFIELDS then
  begin
    Result := GetDialogDefaultsFields;
  end else
  if  UpperName = 'DOBEFORESHOWDIALOG' then
  begin
    DoBeforeShowDialog(InterfaceToObject(AnParams[1]) as TCreateableForm);
  end else
  if  UpperName = 'DOAFTERSHOWDIALOG' then
  begin
    DoAfterShowDialog(InterfaceToObject(AnParams[1]) as TCreateableForm,
      Boolean(AnParams[2]));
  end else
  if  UpperName = 'CREATEDIALOGFORM' then
  begin
    Result := GetGdcInterface(CreateDialogForm) as IgsCreateableForm;
  end else
  if  UpperName = 'EDITDIALOG' then
  begin
    Result := EditDialog(String(AnParams[1]));
  end else
  if  UpperName = 'CREATEDIALOG' then
  begin
    Result := CreateDialog(String(AnParams[1]));
  end else
  if  UpperName = 'CHECKSUBSET' then
  begin
    Result := CheckSubSet(String(AnParams[1]));
  end else
  if  UpperName = 'COPYDIALOG' then
  begin
    Result := CopyDialog;
  end else
  if  UpperName = 'GETSELECTCLAUSE' then
  begin
    Result := GetSelectClause;
  end else
  if  UpperName = 'GETFROMCLAUSE' then
  begin
    Result := GetFromClause(Boolean(AnParams[1]));
  end else
  if  UpperName = 'GETWHERECLAUSE' then
  begin
    Result := GetWhereClause;
  end else
  if  UpperName = 'GETORDERCLAUSE' then
  begin
    Result := GetOrderClause;
  end else
  if  UpperName = 'GETGROUPCLAUSE' then
  begin
    Result := GetGroupClause;
  end else
  if  UpperName = 'CHECKTHESAMESTATEMENT' then
  begin
    Result := CheckTheSameStatement;
  end else
  if  UpperName = 'BEFOREDESTRUCTION' then
  begin
    BeforeDestruction;
  end else
  if  UpperName = 'DOONFILTERCHANGED' then
  begin
    DoOnFilterChanged(InterfaceToObject(AnParams[1]), Integer(AnParams[2]));
//    procedure (Sender: TObject; const AnCurrentFilter: Integer);
  end else
  if  UpperName = 'DOONREPORTLISTCLICK' then
  begin
    DoOnReportListClick(InterfaceToObject(AnParams[1]));
  end else
  if  UpperName = 'DOAFTEREXTRACHANGED' then
  begin
    DoAfterExtraChanged(InterfaceToObject(AnParams[1]));
  end else
  if  UpperName = 'DOONREPORTCLICK' then
  begin
    DoOnReportClick(InterfaceToObject(AnParams[1]));
  end else

  ;
end;

class procedure TgdcBase.RegisterMethod;
begin
  // ��� ����������� ��� ��������� ������� �� ��� ����:
  // ������ - Object � �������� - Variable.

  // !!! ��� VAR-���������� - var-�������� ����������� � �������� ������
  // var � ��� ��� ������. ������!!!
  // ������ RegisterClassMethod(TgdcBase, 'VarMethod', 'Self: Object; var Param: Object', '');

  RegisterGDCClassMethod(TgdcBase, 'CustomInsert', 'Self: Object; Buff: Variable', '');
  RegisterGDCClassMethod(TgdcBase, 'CustomModify', 'Self: Object; Buff: Variable', '');
  RegisterGDCClassMethod(TgdcBase, 'CustomDelete', 'Self: Object; Buff: Variable', '');

  RegisterGDCClassMethod(TgdcBase, 'DoAfterDelete', 'Self: Object', '');
  RegisterGDCClassMethod(TgdcBase, 'DoAfterInsert', 'Self: Object', '');
  RegisterGDCClassMethod(TgdcBase, 'DoAfterEdit', 'Self: Object', '');
  RegisterGDCClassMethod(TgdcBase, 'DoAfterOpen', 'Self: Object', '');
  RegisterGDCClassMethod(TgdcBase, 'DoAfterPost', 'Self: Object', '');
  RegisterGDCClassMethod(TgdcBase, 'DoAfterCancel', 'Self: Object', '');
  RegisterGDCClassMethod(TgdcBase, 'DoAfterScroll', 'Self: Object', '');
  RegisterGDCClassMethod(TgdcBase, 'DoBeforeScroll', 'Self: Object', '');
  RegisterGDCClassMethod(TgdcBase, 'DoBeforeClose', 'Self: Object', '');
  RegisterGDCClassMethod(TgdcBase, 'DoBeforeDelete', 'Self: Object', '');
  RegisterGDCClassMethod(TgdcBase, 'DoBeforeEdit', 'Self: Object', '');
  RegisterGDCClassMethod(TgdcBase, 'DoBeforeInsert', 'Self: Object', '');
  RegisterGDCClassMethod(TgdcBase, 'DoBeforePost', 'Self: Object', '');
  RegisterGDCClassMethod(TgdcBase, 'DoAfterTransactionEnd', 'Self: Object; Field: Object', '');
//  RegisterGDCClassMethod(TgdcBase, 'DoOnNewRecord', 'Self: Object', '');

  RegisterGDCClassMethod(TgdcBase, 'DoOnReportListClick', 'Self: Object; Sender: Object', '');
  RegisterGDCClassMethod(TgdcBase, 'DoAfterExtraChanged', 'Self: Object; Sender: Object', '');
  RegisterGDCClassMethod(TgdcBase, 'DoOnReportClick', 'Self: Object; Sender: Object', '');

  RegisterGDCClassMethod(TgdcBase, 'DoBeforeOpen', 'Self: Object', '');
  RegisterGDCClassMethod(TgdcBase, '_DoOnNewRecord', 'Self: Object', '');
  RegisterGDCClassMethod(TgdcBase, 'CopyDialog', 'Self: Object', 'Variable');

  RegisterGDCClassMethod(TgdcBase, 'DoOnFilterChanged',
    'Self: Object; Sender: Object; AnCurrentFilter: Variable', '');
  RegisterGDCClassMethod(TgdcBase, 'DoAfterCustomProcess',
    'Self: Object; Buff: Variable; Process: Variable', '');
  RegisterGDCClassMethod(TgdcBase, 'DoBeforeShowDialog',
    'Self: Object; DlgForm: Object', '');
  RegisterGDCClassMethod(TgdcBase, 'DoAfterShowDialog',
    'Self: Object; DlgForm: Object; IsOk: Variable', '');
  RegisterGDCClassMethod(TgdcBase, 'CreateDialogForm', 'Self: Object', 'Object');
  RegisterGDCClassMethod(TgdcBase, 'EditDialog',
    'Self: Object; ADlgClassName: Variable', 'Variable');
  RegisterGDCClassMethod(TgdcBase, 'CreateDialog',
    'Self: Object; ADlgClassName: Variable', 'Variable');
  RegisterGDCClassMethod(TgdcBase, 'DoFieldChange', 'Self: Object; Field: Object', '');

  RegisterGDCClassMethod(TgdcBase, 'GetSelectClause',
    'Self: Object', 'Variable');
  RegisterGDCClassMethod(TgdcBase, 'GetFromClause',
    'Self: Object; ARefresh: Variable', 'Variable');
  RegisterGDCClassMethod(TgdcBase, 'GetWhereClause',
    'Self: Object', 'Variable');
  RegisterGDCClassMethod(TgdcBase, 'GetOrderClause',
    'Self: Object', 'Variable');
  RegisterGDCClassMethod(TgdcBase, 'GetGroupClause',
    'Self: Object', 'Variable');

  RegisterGDCClassMethod(TgdcBase, 'CheckTheSameStatement',
    'Self: Object', 'Variable');

  RegisterGDCClassMethod(TgdcBase, 'CreateFields', 'Self: Object', '');
  RegisterGDCClassMethod(TgdcBase, 'GetNotCopyField', 'Self: Object', 'Variable');
  RegisterGDCClassMethod(TgdcBase, 'GetDialogDefaultsFields', 'Self: Object', 'Variable');
  RegisterGDCClassMethod(TgdcBase, 'BeforeDestruction', 'Self: Object', 'Variable');

  RegisterGDCClassMethod(TgdcBase, 'CheckSubSet',
    'Self: Object; ASubSet:Variable', 'Variable');
end;

function TgdcBase.IsSubSetStored: Boolean;
begin
  Result := SubSet <> 'All';
end;

function TgdcBase.IsNameInScriptStored: Boolean;
begin
  Result := (FNameInScript > '') and (FNameInScript <> Name);
end;

function TgdcBase.IsReadTransactionStored: Boolean;
begin
  Result :=
    ((gdcBaseManager = nil) or (gdcBaseManager.ReadTransaction <> ReadTransaction));
end;

function TgdcBase.IsTransactionStored: Boolean;
begin
  Result := (Transaction <> FInternalTransaction)
    and ((MasterSource = nil) or (not (MasterSource.DataSet is TgdcBase))
      or (Transaction <> TgdcBase(MasterSource.DataSet).Transaction));
end;

procedure TgdcBase.CheckCurrentRecord;
begin
  CheckActive;
  if IsEmpty then
    raise Exception.Create(GetGsException(Self, 'Record is not accessible'));
end;

{ TClassListForMethod }

{ TgdcTransactionGuard }

{
constructor TgdcTransactionGuard.Create(ATransaction: TIBTransaction);
begin
  FTransaction := ATransaction;
  if FTransaction.InTransaction then
    FDidActivate := False
  else begin
    FDidActivate := True;
    FTransaction.StartTransaction;
  end;
  FAction := taCommit;
end;

destructor TgdcTransactionGuard.Destroy;
begin
  if FDidActivate and FTransaction.InTransaction then
    case FAction of
      taCommit: FTransaction.Commit;
      taRollback: FTransaction.Rollback;
      taCommitRetaining: FTransaction.CommitRetaining;
      taRollbackRetaining: FTransaction.RollbackRetaining;
    end;
  inherited;
end;

function TgdcTransactionGuard.GetAction: TTransactionAction;
begin
  Result := FAction;
end;

function TgdcTransactionGuard.GetTransaction: TIBTransaction;
begin
  Result := FTransaction;
end;

procedure TgdcTransactionGuard.SetAction(AnAction: TTransactionAction);
begin
  FAction := AnAction;
end;
}

{ TgdcQTransactionGuard }

{
constructor TgdcQTransactionGuard.Create(ATransaction: TIBTransaction);
begin
  inherited Create(ATransaction);
  Fq := TIBSQL.Create(nil);
  Fq.Transaction := Transaction;
end;

destructor TgdcQTransactionGuard.Destroy;
begin
  FreeAndNil(Fq);
  inherited;
end;

function TgdcQTransactionGuard.GetQ: TIBSQL;
begin
  Result := Fq;
end;
}

function TgdcBase.GetReductionCondition: String;
begin
  Result := '';
end;

function TgdcBase.GetReductionTable: String;
begin
  Result := GetListTable(SubType);
end;

procedure TgdcBase.SetSelectedID(const Value: TgdKeyArray);
begin
  FSelectedID.Assign(Value);
  FSQLInitialized := False;
end;

{DoProcess ���������, �������� �� ����� ��� ��������� ��������� �������}
//ChooseComponentName ��������� �� ������ ������� �� ����� ����������� �������
//ChooseSubSet ��������� ������ ��� �������, �� �������� ������� �������
//�� ��������� ������������ ������, �������� ���������� �� �����
function TgdcBase.ChooseItems(out AChosenIDInOrder: OleVariant;
  const ChooseComponentName: String = '';
  const ChooseSubSet: String = '';
  const ChooseExtraConditions: String = ''): Boolean;
var
  ChComponent: TComponent;
  F: TForm;
begin
  Result := False;
  if Self.Owner = nil then
    F := CreateViewForm(Application, '', SubType, True)
  else
    F := CreateViewForm(Self.Owner, '', SubType, True);

  if F <> nil then
    with F as Tgdc_frmG do
    try
      {���� �� ������ ���� � �������� �����������, �� �������� �� �� ������ � ���.
       �� ��������� � ��� ����� ���� ������ ����������.}
       { TODO -o���� : �� �������������� ����� �-� }
      if Self.Transaction.InTransaction then
      begin
        gdcObject.Close;
        gdcObject.ReadTransaction := Self.Transaction;
        gdcObject.Open;
      end;

      ChComponent := FindComponent(ChooseComponentName);
      if Assigned(ChComponent) and (ChComponent is TgdcBase) then
      begin
        gdcLinkChoose := (ChComponent as TgdcBase);
      end else if (F is Tgdc_frmMDH) then
      begin
      {���� �� ������ ���� ��������� �� �������� ����� ���� �����, ������ ��� ����:
       1) ���� ����� ���������� � ������ ������� ���������, �� ����� ����� �� ����������
       2) ���� ����� ������ � ������ ������� ���������, �� ����� ����� �� �������
       3) ���� ����� ������ ������� ���������� �� ������ ����������, �� ����� ����� �� ����������
       4) ���� ����� ������ ������� ���������� �� ������ �������, �� ����� ����� �� �������
       �����, ����� ����� ���� �� ����������, ������� ������� ��� ������ ������ ��-���������}
        if Assigned((F as Tgdc_frmMDH).gdcDetailObject) and
          (Self.ClassType = (F as Tgdc_frmMDH).gdcDetailObject.ClassType)
        then
          gdcLinkChoose := (F as Tgdc_frmMDH).gdcDetailObject

        else if Assigned((F as Tgdc_frmMDH).gdcObject) and
          (Self.ClassType = (F as Tgdc_frmMDH).gdcObject.ClassType)
        then
          gdcLinkChoose := (F as Tgdc_frmMDH).gdcObject

        else if Assigned((F as Tgdc_frmMDH).gdcDetailObject) and
          Self.InheritsFrom((F as Tgdc_frmMDH).gdcDetailObject.ClassType)
        then
          gdcLinkChoose := (F as Tgdc_frmMDH).gdcDetailObject

        else if Assigned((F as Tgdc_frmMDH).gdcObject) and
          Self.InheritsFrom((F as Tgdc_frmMDH).gdcObject.ClassType)
        then
          gdcLinkChoose := (F as Tgdc_frmMDH).gdcObject;
      end;

      SetChoose(Self);

      if (ChooseSubSet > '') or (ChooseExtraConditions > '') then
      begin
        gdcLinkChoose.Close;
        if ChooseSubSet > '' then
        begin
          gdcLinkChoose.SubSet := gdcLinkChoose.SubSet + ',' + ChooseSubSet;
        end;
        {ExtraConditions ����� ���� ������������ �� ���������������� ������ ��� ����� �-�,
        ������� �� �������� ��, � �� ������ �������}
        gdcLinkChoose.ExtraConditions.Add(ChooseExtraConditions);
        gdcLinkChoose.Open;
      end;

      if ShowModal = mrOk then
      begin
        AChosenIDInOrder := ChosenIDInOrder;

        FSelectedID.Assign(gdcChooseObject.SelectedID);
        //���� ������ ������ OnlySelected - ������������� ������
        if HasSubSet('OnlySelected') then
        begin
          FDSModified := True;
          CloseOpen;
        end;
        Result := True;
      end;
    finally
      Free;
    end;
end;

function TgdcBase.ChooseItems(Cl: CgdcBase; KeyArray: TgdKeyArray;
  out AChosenIDInOrder: OleVariant;
  const ChooseComponentName: String = '';
  const ChooseSubSet: String = ''; const ChooseSubType: TgdcSubType = '';
  const ChooseExtraConditions: String = ''): Boolean;
var
  Obj: TgdcBase;
  ChComponent: TComponent;
  F: TForm;
begin
  Result := False;
  if Cl <> nil then
    Obj := Cl.CreateSubType(Owner, ChooseSubType)
  else
    Obj := CgdcBase(Self.ClassType).CreateSubType(Owner, ChooseSubType);
  try
    Obj.Transaction := Transaction;

    if Obj.Owner = nil then
      F := CreateViewForm(Application, '', Obj.SubType, True)
    else
      F := CreateViewForm(Obj.Owner, '', Obj.SubType, True);

    if F is Tgdc_frmG then  
    begin
      with F as Tgdc_frmG do
      begin
        try
        {���� �� ������ ���� � �������� �����������, �� �������� �� �� ������ � ���.
         �� ��������� � ��� ����� ���� ������ ����������.}
         { TODO -o���� : �� �������������� ����� �-� }
          if Obj.Transaction.InTransaction then
          begin
            gdcObject.Close;
            gdcObject.ReadTransaction := Obj.Transaction;
            gdcObject.Open;
          end;

          ChComponent := FindComponent(ChooseComponentName);
          if Assigned(ChComponent) and (ChComponent is TgdcBase) then
          begin
            gdcLinkChoose := (ChComponent as TgdcBase);
          end else if (F is Tgdc_frmMDH) then
          begin
            {���� �� ������ ���� ��������� �� �������� ����� ���� �����, ������ ��� ����:
           1) ���� ����� ���������� � ������ ������� ���������, �� ����� ����� �� ����������
           2) ���� ����� ������ � ������ ������� ���������, �� ����� ����� �� �������
           3) ���� ����� ������ ������� ���������� �� ������ ����������, �� ����� ����� �� ����������
           4) ���� ����� ������ ������� ���������� �� ������ �������, �� ����� ����� �� �������
           �����, ����� ����� ���� �� ����������, ������� ������� ��� ������ ������ ��-���������}
            if Assigned((F as Tgdc_frmMDH).gdcDetailObject) and
              (Obj.ClassType = (F as Tgdc_frmMDH).gdcDetailObject.ClassType)
            then
              gdcLinkChoose := (F as Tgdc_frmMDH).gdcDetailObject

            else if Assigned((F as Tgdc_frmMDH).gdcObject) and
              (Obj.ClassType = (F as Tgdc_frmMDH).gdcObject.ClassType)
            then
              gdcLinkChoose := (F as Tgdc_frmMDH).gdcObject

            else if Assigned((F as Tgdc_frmMDH).gdcDetailObject) and
              Obj.InheritsFrom((F as Tgdc_frmMDH).gdcDetailObject.ClassType)
            then
              gdcLinkChoose := (F as Tgdc_frmMDH).gdcDetailObject

            else if Assigned((F as Tgdc_frmMDH).gdcObject) and
              Obj.InheritsFrom((F as Tgdc_frmMDH).gdcObject.ClassType)
            then
              gdcLinkChoose := (F as Tgdc_frmMDH).gdcObject;
          end;

          if Assigned(KeyArray) then
            Obj.SelectedID.Assign(KeyArray);

          SetChoose(Obj);

          if (ChooseSubSet > '') or (ChooseExtraConditions > '') then
          begin
            gdcLinkChoose.Close;
            try
              if ChooseSubSet > '' then
              begin
                gdcLinkChoose.SubSet := gdcLinkChoose.SubSet + ',' + ChooseSubSet;
              end;
              {ExtraConditions ����� ���� ������������ �� ���������������� ������ ��� ����� �-�,
              ������� �� �������� ��, � �� ������ �������}
              if ChooseExtraConditions > '' then
                gdcLinkChoose.ExtraConditions.Add(ChooseExtraConditions);
            finally
              gdcLinkChoose.Open;
            end;
          end;

          if F.Visible then
            F.Hide;

          if ShowModal = mrOk then
          begin
            AChosenIDInOrder := ChosenIDInOrder;

            Obj.SelectedID.Assign(gdcChooseObject.SelectedID);
            //Obj.Close;
            //Obj.SubSet := 'OnlySelected';
            //Obj.Open;
            //���� ������ ������ OnlySelected - ������������� ������
            if HasSubSet('OnlySelected') then
            begin
              FDSModified := True;
              CloseOpen;
            end;
            Result := True;
          end;
        finally
          Free;
        end;
      end;
    end;
    if Assigned(KeyArray) then
      KeyArray.Assign(Obj.SelectedID);
  finally
    Obj.Free;
  end;
end;

procedure TgdcBase.SetSetTable(const Value: String);
var
  WasActive: Boolean;
begin
  if FSetTable <> Value then
  begin
    WasActive := Active;
    Close;
    FSetTable := Value;
    if FSetTable > '' then
    begin
      MasterField := 'ID';
      DetailField := 'MASTER_RECORD_ID';
    end;
    FSetMasterField := '';
    FSetItemField := '';
    FSQLInitialized := False;
    Active := WasActive; 
  end;
end;

procedure TgdcBase.SetExclude(const Reopen: Boolean);
var
  Bm: String;
  ibsql: TIBSQL;
  Buff: Pointer;
  DidActivate: Boolean;

  function GetWhereClauseForSet: String;
  var
    I: Integer;
    KFL: TStringList;
    R: TatRelation;
  begin
    Result := '';
    //��������� ���� �� � ��� �������-���������
    if (FSetTable = '') or (atDatabase = nil) then
      Exit;

    R := atDatabase.Relations.ByRelationName(FSetTable);

    Assert(Assigned(R));

    if Assigned(R.PrimaryKey)
    then
    begin
      KFL := TStringList.Create;
      try
        with atDatabase.Relations.ByRelationName(FSetTable).PrimaryKey do
        for I := 0 to ConstraintFields.Count - 1 do
          KFL.Add(AnsiUpperCase(Trim(ConstraintFields[I].FieldName)));

        Result := '';
        for I := 0 to KFL.Count - 1 do
        begin
          if Result > '' then
            Result := Result + ' AND ';
          Result := Result + KFL[I] + ' = :OLD_' + cstSetPrefix + KFL[I];
        end;

      finally
        KFL.Free;
      end;
    end;
  end;
begin
  CheckBrowseMode;
  DidActivate := False;
  try
    DidActivate := ActivateTransaction;

    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := Transaction;
      ibsql.SQl.Text := (Format('DELETE FROM %0:s WHERE %s', [FSetTable, GetWhereClauseForSet]));
      Buff := GetActiveBuf;
      SetInternalSQLParams(ibsql, Buff);
      ibsql.ExecQuery;
    finally
      ibsql.Free;
    end;

    FDSModified := True;

    if DidActivate and Transaction.InTransaction then
      Transaction.Commit;
  except
    if DidActivate and Transaction.InTransaction then
      Transaction.Rollback;
  end;

  if Reopen then
  begin
    FDataTransfer := True;
    try
      Bm := Bookmark;
      DisableControls;
      try
        Close;
        Open;
        if BookmarkValid(Pointer(Bm)) then
          Bookmark := Bm;
      finally
        EnableControls;
      end;
    finally
      FDataTransfer := False;
    end;
  end;

end;

procedure TgdcBase.SetInclude(const AnID: TID);
begin
  CheckBrowseMode;

  if AnID = -1 then
    exit;

  ExecSingleQuery(Format(
    'UPDATE OR INSERT INTO %s (%s, %s) VALUES (%d, %d) MATCHING (%s, %s)',
    [FSetTable, FSetMasterField, FSetItemField,
     ParamByName('MASTER_RECORD_ID').AsInteger, AnID,
     FSetMasterField, FSetItemField]));

  FDSModified := True;

  DisableControls;
  try
    Close;
    Open;
    Locate(cstSetPrefix + FSetItemField, AnID, []);
  finally
    EnableControls;
  end;
end;

function TgdcBase.GetMethodControl: IMethodControl;
begin
  if (not Assigned(MethodControl)) or UnMethodMacro or (not UseScriptMethod)
    or (FClassMethodAssoc = nil) then
  begin
    Result := nil;
  end else
    Result := MethodControl;
end;

function TgdcBase.GetGdcInterface(Source: TObject): IDispatch;
begin
  Result := GetGdcOLEObject(Source) as IDispatch;
end;

function TgdcBase.GetClassName: String;
begin
  Result := Self.ClassName;
end;

procedure TgdcBase.DoFieldChange(Field: TField);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_DOFIELDCHANGE('TGDCBASE', 'DOFIELDCHANGE', KEYDOFIELDCHANGE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOFIELDCHANGE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOFIELDCHANGE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(Field)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOFIELDCHANGE', KEYDOFIELDCHANGE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  //

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOFIELDCHANGE', KEYDOFIELDCHANGE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOFIELDCHANGE', KEYDOFIELDCHANGE);
  {M}  end;
  {END MACRO}
end;

function TgdcBase.GetInterfaceToObject(Source: IDispatch): TObject;
begin
  Result := InterfaceToObject(Source);
end;

function TgdcBase.GetIDForBookmark(const Bm: TBookmarkStr): TID;
var
  Accept: Boolean;
begin
  Result := -1;
  FPeekBuffer := FBufferCache + PInteger(Bm)^ * _RecordBufferSize;
  try
    if PRecordData(FPeekBuffer)^.rdUpdateStatus = usDeleted then
      exit;

    if Filtered and Assigned(OnFilterRecord) then
    begin
      Accept := True;
      OnFilterRecord(Self, Accept);
      if not Accept then
        exit;
    end;

    Result := FieldByName(GetKeyField(SubType)).AsInteger;
  finally
    FPeekBuffer := nil;
  end;
end;

procedure TgdcBase.AddToSelectedID(BL: TBookmarkList);
var
  I: Integer;
begin
  if Assigned(BL) then
    BL.Refresh;

  if (BL = nil) or (BL.Count = 0) then
    AddToSelectedID(-1)
  else
    for I := 0 to BL.Count - 1 do
      AddToSelectedID(GetIDForBookmark(BL[I]));
end;

procedure TgdcBase.RemoveFromSelectedID(BL: TBookmarkList);
var
  I: Integer;
begin
  if Assigned(BL) then
    BL.Refresh;

  if (BL = nil) or (BL.Count = 0) then
    RemoveFromSelectedID(-1)
  else
    for I := 0 to BL.Count - 1 do
      RemoveFromSelectedID(GetIDForBookmark(BL[I]));
end;

procedure TgdcBase.SetBaseState(const ABaseState: TgdcStates);
begin
  FBaseState := ABaseState;
end;

procedure TgdcBase.SetFirstMethodAssoc(const AClass: String;
  const AMethodKey: Byte);
begin
  if FClassMethodAssoc.StrByKey[AMethodKey] = '' then
    FClassMethodAssoc.StrByKey[AMethodKey] := AClass;
end;

class function TgdcBase.QGetNameForID(const AnID: TID; const ASubType: String = ''): String;
var
  q: TIBSQL;
  DidActivate: Boolean;
begin
  Assert(Assigned(gdcBaseManager));
  Assert(Assigned(gdcBaseManager.ReadTransaction));

  DidActivate := False;
  q := TIBSQL.Create(nil);
  try
    q.Database := gdcBaseManager.Database;
    q.Transaction := gdcBaseManager.ReadTransaction;

    DidActivate := not q.Transaction.InTransaction;
    if DidActivate then
      q.Transaction.StartTransaction;

    q.SQL.Text := Format('SELECT %s FROM %s WHERE %s = %d',
      [GetListField(ASubType), GetListTable(ASubType), GetKeyField(ASubType), AnID]);
    q.ExecQuery;

    if q.EOF then
      Result := ''
    else
      Result := q.Fields[0].AsTrimString;

    q.Close;
  finally
    if DidActivate and q.Transaction.InTransaction then
      q.Transaction.Commit;

    q.Free;
  end;
end;

procedure TgdcBase.ClearMacrosStack2(const AClass, AMethod: String;
  const AMethodKey: Byte);
var
  Index: Integer;
begin
  Assert(FClassMethodAssoc <> nil);
  if FClassMethodAssoc.StrByKey[AMethodKey] = AClass then
  begin
    Index := FClassMethodAssoc.IndexOf(AMethodKey);
    FClassMethodAssoc.StrByIndex[Index] := '';
    if FClassMethodAssoc.IntByIndex[Index] > 0 then
      TStackStrings(FClassMethodAssoc.IntByIndex[Index]).Clear;
  end;
end;

class function TgdcBase.QGetNameForID2(const AnID: TID;
  const ASubType: TgdcSubType): String;
begin
  Result := QGetNameForID(AnID, ASubType);
end;

procedure TgdcBase.CreateKeyList;
begin
  FClassMethodAssoc.Add(keyCustomInsert);
  FClassMethodAssoc.Add(keyCustomModify);
  FClassMethodAssoc.Add(keyCustomDelete);
  FClassMethodAssoc.Add(keyDoAfterDelete);
  FClassMethodAssoc.Add(keyDoAfterInsert);
  FClassMethodAssoc.Add(keyDoAfterEdit);
  FClassMethodAssoc.Add(keyDoAfterOpen);
  FClassMethodAssoc.Add(keyDoAfterPost);
  FClassMethodAssoc.Add(keyDoAfterCancel);
  FClassMethodAssoc.Add(keyDoBeforeClose);
  FClassMethodAssoc.Add(keyDoBeforeDelete);
  FClassMethodAssoc.Add(keyDoBeforeEdit);
  FClassMethodAssoc.Add(keyDoBeforeInsert);
  FClassMethodAssoc.Add(keyDoBeforePost);
  FClassMethodAssoc.Add(keyDoAfterTransactionEnd);
  FClassMethodAssoc.Add(keyDoOnReportListClick);
  FClassMethodAssoc.Add(keyDoAfterExtraChanged);
  FClassMethodAssoc.Add(keyDoOnReportClick);
  FClassMethodAssoc.Add(keyDoBeforeOpen);
  FClassMethodAssoc.Add(key_DoOnNewRecord);
  FClassMethodAssoc.Add(keyCopyDialog);
  FClassMethodAssoc.Add(keyDoOnFilterChanged);
  FClassMethodAssoc.Add(keyDoAfterCustomProcess);
  FClassMethodAssoc.Add(keyDoBeforeShowDialog);
  FClassMethodAssoc.Add(keyDoAfterShowDialog);
  FClassMethodAssoc.Add(keyCreateDialogForm);
  FClassMethodAssoc.Add(keyEditDialog);
  FClassMethodAssoc.Add(keyCreateDialog);
  FClassMethodAssoc.Add(keyDoFieldChange);
  FClassMethodAssoc.Add(keyGetSelectClause);
  FClassMethodAssoc.Add(keyGetFromClause);
  FClassMethodAssoc.Add(keyGetWhereClause);
  FClassMethodAssoc.Add(keyGetOrderClause);
  FClassMethodAssoc.Add(keyGetGroupClause);
  FClassMethodAssoc.Add(keyCheckTheSameStatement);
  FClassMethodAssoc.Add(keyCreateFields);
  FClassMethodAssoc.Add(keyGetNotCopyField);
  FClassMethodAssoc.Add(keyGetDialogDefaultsFields);
  FClassMethodAssoc.Add(keyBeforeDestruction);
  FClassMethodAssoc.Add(keyCheckSubSet);
  FClassMethodAssoc.Add(keyDoAfterScroll);
  FClassMethodAssoc.Add(keyDoBeforeScroll);
end;

class procedure TgdcBase.GetClassImage(const ASizeX, ASizeY: Integer;
  AGraphic: TGraphic);
begin
  if (ASizeX = 16) and (ASizeY = 16) and (AGraphic is TBitmap) then
    dmImages.il16x16.GetBitmap(0, TBitmap(AGraphic));
end;

function TgdcBase.GetFieldValueForID(const AnID: TID;
  const AFieldName: String): Variant;
var
  Accept: Boolean;
  S: String;
  I: Integer;
begin
  S := GetKeyField(SubType);

  if FieldByName(S).AsInteger = AnID then
  begin
    Result := FieldByName(AFieldName).Value;
  end else
  begin
    Result := Unassigned;

    try
      for I := 0 to FRecordCount - 1 do
      begin
        FPeekBuffer := FBufferCache + _RecordBufferSize * I;

        if PRecordData(FPeekBuffer)^.rdUpdateStatus <> usDeleted then
        begin
          if FieldByName(S).AsInteger = AnID then
          begin
            Accept := True;

            if Filtered and Assigned(OnFilterRecord) then
              OnFilterRecord(Self, Accept);

            if Accept then
            begin
              Result := FieldByName(AFieldName).Value;
              exit;
            end;
          end;
        end;
      end;
    finally
      FPeekBuffer := nil;
    end;
  end;
end;

function TgdcBase.GetFieldValueForBookmark(const ABookmark: TBookmarkStr;
  const AFieldName: String): Variant;
var
  Accept: Boolean;
  Offs: Integer;
begin
  Result := Unassigned;
  Offs := PInteger(ABookmark)^ * _RecordBufferSize;
  if (Offs < CacheSize) and (Offs >= 0) then
  begin
    FPeekBuffer := FBufferCache + Offs;
    try
      if PRecordData(FPeekBuffer)^.rdUpdateStatus = usDeleted then
        exit;

      if Filtered and Assigned(OnFilterRecord) then
      begin
        Accept := True;
        OnFilterRecord(Self, Accept);
        if not Accept then
          exit;
      end;

      Result := FieldByName(AFieldName).Value;
    finally
      FPeekBuffer := nil;
    end;
  end;
end;

function TgdcBase.GetVarInterface(const AnValue: Variant): OleVariant;
begin
  if Assigned(FVarParam) then
    Result := FVarParam(AnValue)
  else
    Result := AnValue;
end;

function TgdcBase.GetVarParam(const AnValue: Variant): OleVariant;
begin
  if Assigned(FReturnVarParam) then
    Result := FReturnVarParam(AnValue)
  else
    Result := AnValue;
end;

class function TgdcBase.GetListFieldExtended(
  const ASubType: TgdcSubType): String;
begin
  Result := '';
end;

procedure TgdcBase.UpdateOldValues(Field: TField);
var
  I: Integer;
  Found: Boolean;
  FV: TFieldValue;
begin
  Found := False;
  if FOldValues <> nil then
  begin
    for I := 0 to FOldValues.Count - 1 do
      if AnsiCompareText((FOldValues[I] as TFieldValue).FieldName, Field.FieldName) = 0 then
      begin
        // ���� ���� ������������� ������ � ������ ��� ������������
        // �������������� �������� �� �������, ��� ���� �� ������� ������
        if ((FOldValues[I] as TFieldValue).Value = Field.AsString) and
          ((FOldValues[I] as TFieldValue).IsNull = Field.IsNull) then
        begin
          FOldValues.Delete(I);
          { TODO : ��� ��� ������� ��������! }
          FDSModified := True;
        end;
        Found := True;
        break;
      end;
  end;
  if not Found then
  begin
    if FOldValues = nil then
      FOldValues := TObjectList.Create(True);
    FV := TFieldValue.Create;
    FV.FieldName := Field.FieldName;
    FV.Value := Field.AsString;
    FV.IsNull := Field.IsNull;
    FOldValues.Add(FV);
  end;
end;

function TgdcBase.CreateBlobStream(Field: TField;
  Mode: TBlobStreamMode): TStream;
begin
  if (State = dsEdit) and (Mode in [DB.bmWrite, DB.bmReadWrite]) then
    UpdateOldValues(Field);

  Result := inherited CreateBlobStream(Field, Mode);

  if (State = dsEdit) and (Mode in [DB.bmWrite, DB.bmReadWrite]) then
    FDSModified := True;
end;

class function TgdcBase.NeedModifyFromStream(
  const SubType: String): Boolean;
begin
//� ����� ������ ��������� ������� �� ������ �� �����
//��� �������� ����������� ������ ����� ������ ��� ��������
  Result := False;
end;

procedure TgdcBase.LoadSelectedFromStream(S: TStream);
begin
  FSelectedID.LoadFromStream(S);
end;

procedure TgdcBase.SaveSelectedToStream(S: TStream);
begin
  FSelectedID.SaveToStream(S);
end;

procedure TgdcBase.CopyEventHandlers(Dest, Source: TgdcBase);
begin
  if Assigned(EventControl) then
    EventControl.AssignEvents(TComponent(Source), Dest);

  // ����������� ���� ��������� �������!
  //Dest.MasterField := Source.MasterField;
  //Dest.DetailField := Source.DetailField;
  Dest.MasterSource := Source.MasterSource;

  Dest.AfterCancel := Source.AfterCancel;
  Dest.AfterClose := Source.AfterClose;
  Dest.AfterDelete := Source.AfterDelete;
  Dest.AfterEdit := Source.AfterEdit;
  Dest.AfterInsert := Source.AfterInsert;
  Dest.AfterInternalDeleteRecord := Source.AfterInternalDeleteRecord;
  Dest.AfterInternalPostRecord := Source.AfterInternalPostRecord;
  Dest.AfterOpen := Source.AfterOpen;
  Dest.AfterPost := Source.AfterPost;
  Dest.AfterRefresh := Source.AfterRefresh;
  Dest.AfterScroll := Source.AfterScroll;
  Dest.AfterShowDialog := Source.AfterShowDialog;
  Dest.BeforeCancel := Source.BeforeCancel;
  Dest.BeforeClose := Source.BeforeClose;
  Dest.BeforeDelete := Source.BeforeDelete;
  Dest.BeforeEdit := Source.BeforeEdit;
  Dest.BeforeInsert := Source.BeforeInsert;
  Dest.BeforeInternalDeleteRecord := Source.BeforeInternalDeleteRecord;
  Dest.BeforeInternalPostRecord := Source.BeforeInternalPostRecord;
  Dest.BeforeOpen := Source.BeforeOpen;
  Dest.BeforePost := Source.BeforePost;
  Dest.BeforeRefresh := Source.BeforeRefresh;
  Dest.BeforeScroll := Source.BeforeScroll;
  Dest.BeforeShowDialog := Source.BeforeShowDialog;
  Dest.OnCalcFields := Source.OnCalcFields;
  Dest.OnDeleteError := Source.OnDeleteError;
  Dest.OnEditError := Source.OnEditError;
  Dest.OnNewRecord := Source.OnNewRecord;
  Dest.OnPostError := Source.OnPostError;
  Dest.OnUpdateError := Source.OnUpdateError;
  Dest.OnUpdateRecord := Source.OnUpdateRecord;
end;

procedure TgdcBase.ResetEventHandlers(Obj: TgdcBase);
begin
  Obj.AfterCancel := nil;
  Obj.AfterClose := nil;
  Obj.AfterDelete := nil;
  Obj.AfterEdit := nil;
  Obj.AfterInsert := nil;
  Obj.AfterInternalDeleteRecord := nil;
  Obj.AfterInternalPostRecord := nil;
  Obj.AfterOpen := nil;
  Obj.AfterPost := nil;
  Obj.AfterRefresh := nil;
  Obj.AfterScroll := nil;
  Obj.AfterShowDialog := nil;
  Obj.BeforeCancel := nil;
  Obj.BeforeClose := nil;
  Obj.BeforeDelete := nil;
  Obj.BeforeEdit := nil;
  Obj.BeforeInsert := nil;
  Obj.BeforeInternalDeleteRecord := nil;
  Obj.BeforeInternalPostRecord := nil;
  Obj.BeforeOpen := nil;
  Obj.BeforePost := nil;
  Obj.BeforeRefresh := nil;
  Obj.BeforeScroll := nil;
  Obj.BeforeShowDialog := nil;
  Obj.OnCalcFields := nil;
  Obj.OnDeleteError := nil;
  Obj.OnEditError := nil;
  Obj.OnNewRecord := nil;
  Obj.OnPostError := nil;
  Obj.OnUpdateError := nil;
  Obj.OnUpdateRecord := nil;
end;

procedure TgdcBase.SetValueForBookmark(const ABookmark: TBookmarkStr;
  const AFieldName: String; const AValue: Variant);
var
  Accept: Boolean;
  OldDS, DS: TDataSetState;
  Offs: Integer;
begin
  Offs := PInteger(ABookmark)^ * _RecordBufferSize;
  if Offs < CacheSize then
  begin
    FPeekBuffer := FBufferCache + Offs;
    try
      if PRecordData(FPeekBuffer)^.rdUpdateStatus = usDeleted then
        exit;

      if Filtered and Assigned(OnFilterRecord) then
      begin
        Accept := True;
        OnFilterRecord(Self, Accept);
        if not Accept then
          exit;
      end;

      Move(PChar(Self)[(1+8+26) * SizeOf(Integer) + SizeOf(TFilterOptions)], OldDS, SizeOf(OldDS));
      DS := dsEdit;
      Move(DS, PChar(Self)[(1+8+26) * SizeOf(Integer) + SizeOf(TFilterOptions)], SizeOf(DS));
      FieldByName(AFieldName).Value := AValue;
      Move(OldDS, PChar(Self)[(1+8+26) * SizeOf(Integer) + SizeOf(TFilterOptions)], SizeOf(OldDS));
    finally
      FPeekBuffer := nil;
    end;
  end;  
end;

function TgdcBase.GetCanChangeRights: Boolean;
begin
  Result := TestUserRights([tiAFull])
    and (Transaction <> gdcBaseManager.ReadTransaction);
end;

function TgdcBase.GetCanCreate: Boolean;
begin
  Result := Class_TestUserRights([tiAChag], SubType)
    and (Transaction <> gdcBaseManager.ReadTransaction)
    and GetCanModify;
end;

function TgdcBase.GetCanDelete: Boolean;
begin
  Result := TestUserRights([tiAFull])
    and (Transaction <> gdcBaseManager.ReadTransaction);
end;

function TgdcBase.GetCanEdit: Boolean;
begin
  if State = dsInsert then
    Result := True
  else
    Result := TestUserRights([tiAChag])
      and (Transaction <> gdcBaseManager.ReadTransaction);
end;

function TgdcBase.GetCanPrint: Boolean;
begin
  Result := TestUserRights([tiAView])
    and Assigned(GlobalStorage)
    and Assigned(IBlogin)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_REPORT_ID, GD_POL_REPORT_MASK, False) and IBLogin.InGroup) <> 0);
end;

function TgdcBase.GetCanView: Boolean;
begin
  Result := TestUserRights([tiAView]);
end;

procedure TgdcBase.SetUseScriptMethod(const Value: Boolean);
begin
  FUseScriptMethod := Value;
end;

class function TgdcBase.NeedDeleteTheSame(const SubType: String): Boolean;
begin
//��� ����������� �������� �������� �� �����������!!!!!!
  Result := False;
end;

function TgdcBase.DeleteTheSame(AnID: Integer; AName: String): Boolean;
begin
  Result := False;

  //����������� ������ �� ������� �� �����
  if AnID < cstUserIDStart then
    exit;

  if not (sLoadFromStream in BaseState) then
    raise EgdcException.Create('������ ������ ���� � ��������� �������� �� ������!');

  ID := AnID;
  if Active and (not IsEmpty) then
  begin
    Delete;
    gdcBaseManager.DeleteRUIDByID(AnID, Transaction);
    Result := True;
  end;
end;

class function TgdcBase.SelectObject(const AMessage: String = '';
  const ATitle: String = '';
  const AHelpCtxt: Integer = 0;
  const ACondition: String = '';
  const ADefaultID: Integer = -1): TID;
begin
  with Tgdc_dlgSelectObject.Create(Application) do
  try
    if ATitle > '' then
      Caption := ATitle;

    if AMessage > '' then
      lMessage.Caption := AMessage;

    if AHelpCtxt > 0 then
      HelpContext := AHelpCtxt;

    IBTransaction.DefaultDatabase := gdcBaseManager.Database;
    lkup.Database := gdcBasemanager.Database;
    lkup.gdClassName := Self.ClassName;
    if ACondition > '' then
      lkup.Condition := ACondition;
    if ADefaultID > 0 then
      lkup.CurrentKeyInt := ADefaultID;  
    if ShowModal = mrOk then
      Result := lkup.CurrentKeyInt
    else
      Result := -1;
  finally
    Free;
  end;
end;

{ EgdcException }

constructor EgdcException.CreateObj(const AMessage: String;
  AnObj: TgdcBase);
begin
  Assert(AnObj is TgdcBase);
  CreateFmt('%s'#13#10#13#10'Class: %s'#13#10'Object: %s'#13#10'SubType: %s'#13#10'SubSet: %s'#13#10'ID: %d'#13#10,
    [
      {$IFDEF LOCALIZATION}
      Translate(AMessage, AnObj),
      {$ELSE}
      AMessage,
      {$ENDIF}
      AnObj.ClassName, AnObj.Name, AnObj.SubType, AnObj.SubSet, AnObj.ID]);
end;

procedure TgdcBase.DoAfterInternalPostRecord;
begin
  if Assigned(AfterInternalPostRecord) then
    AfterInternalPostRecord(Self);
end;

procedure TgdcBase.DoBeforeInternalPostRecord;
begin
  if Assigned(BeforeInternalPostRecord) then
    BeforeInternalPostRecord(Self);
end;

function TgdcBase.TestUserRights(const SS: TgdcTableInfos): Boolean;
var
  M: Integer;
begin
  {$IFDEF NEW_GRID}
  if RecordKind <> rkRecord then
  begin
    Result := False;
    exit;
  end;
  {$ENDIF}

  Assert(Assigned(IBLogin));

  if ((FBaseState * [sDialog, sView]) = [])
    or (sLoadFromStream in FBaseState) then
  begin
    Result := True;
    exit;
  end;

  if IBLogin.IsUserAdmin then
    Result := True
  else
  begin
    if Active and (not IsEmpty)
      and ((FgdcTableInfos * [tiAFull, tiAChag, tiAView]) <> []) then
    begin
      {if (tiCreationInfo in FgdcTableInfos) and
        (FieldByName('creatorkey').AsInteger = IBLogin.ContactKey) then
      begin
        Result := True;
      end else}
      begin
        M := 1;
        if tiAFull in FgdcTableInfos then
          M := M or FieldByName('afull').AsInteger;
        if (tiAChag in FgdcTableInfos) and
          ((tiAChag in SS) or (not (tiAFull in FgdcTableInfos))) then
          M := M or FieldByName('achag').AsInteger;
        if (tiAView in FgdcTableInfos) and
          ((tiAView in SS) or ((FgdcTableInfos * [tiAChag, tiAFull]) = [])) then
          M := M or FieldByName('aview').AsInteger;
        Result := (M and IBLogin.InGroup) <> 0;
      end;
    end else
      Result := True;
  end;

  Result := Result and Class_TestUserRights(SS, Self.SubType);
end;

class function TgdcBase.Class_TestUserRights(
  const SS: TgdcTableInfos; const ST: String): Boolean;
begin
  if tiAView in SS then
    Result := gdcBaseManager.Class_TestUserRights(Self, ST, 0)
  else if tiAChag in SS then
    Result := gdcBaseManager.Class_TestUserRights(Self, ST, 1)
  else
    Result := gdcBaseManager.Class_TestUserRights(Self, ST, 2)
end;

procedure TgdcBase.SetExtraConditions(const Value: TStrings);
begin
  FExtraConditions.Assign(Value);
end;

function TgdcBase.GetObject: TObject;
begin
  Result := Self;
end;

function TgdcBase.GetFieldByNameValue(const AField: String): Variant;
begin
  Result := FieldByName(AField).Value;
end;

procedure TgdcBase.SetOnGetSelectClause(const Value: TgdcOnGetSQLClause);
begin
  if (Addr(FOnGetSelectClause) <> Addr(Value)) and not Active then
    FSQLInitialized := False;
  FOnGetSelectClause := Value;
end;

procedure TgdcBase.SetOnGetFromClause(const Value: TgdcOnGetSQLClause);
begin
  if (Addr(FOnGetFromClause) <> Addr(Value)) and not Active then
    FSQLInitialized := False;
  FOnGetFromClause := Value;
end;

procedure TgdcBase.SetOnGetGroupClause(const Value: TgdcOnGetSQLClause);
begin
  if (Addr(FOnGetGroupClause) <> Addr(Value)) and not Active then
    FSQLInitialized := False;
  FOnGetGroupClause := Value;
end;

procedure TgdcBase.SetOnGetOrderClause(const Value: TgdcOnGetSQLClause);
begin
  if (Addr(FOnGetOrderClause) <> Addr(Value)) and not Active then
    FSQLInitialized := False;
  FOnGetOrderClause := Value;
end;

procedure TgdcBase.SetOnGetWhereClause(const Value: TgdcOnGetSQLClause);
begin
  if (Addr(FOnGetWhereClause) <> Addr(Value)) and not Active then
    FSQLInitialized := False;
  FOnGetWhereClause := Value;
end;

procedure TgdcBase.SetQueryFiltered(const Value: Boolean);
begin
  if not (csDesigning in ComponentState) then
  begin
    Assert(Assigned(FQueryFilter));
    if not Value then
      FQueryFilter.IBDataSet := nil
    else
      FQueryFilter.IBDataSet := Self;
  end;
  FQueryFiltered := Value;
end;

{ TgdcPropertySet }

procedure TgdcPropertySet.Add(APropertyName: String;
  Value: Variant);
var
  ACount: Integer;
begin
  Assert(Count = 0);

  ACount := Count;
  FPropertyList.Add(AnsiUpperCase(APropertyName) + '=' + IntToStr(ACount));
  VarArrayRedim(FValueArray, Count);
  if VarType(Value) = varBoolean then
  begin
    if Boolean(Value) then
      FValueArray[Count] := 1
    else
      FValueArray[Count] := 0;
  end
  else
    FValueArray[Count] := Value;
end;

procedure TgdcPropertySet.Clear;
begin
  FPropertyList.Clear;
  FValueArray := VarArrayOf([]);
end;

constructor TgdcPropertySet.Create(const ARUIDSt: String;
  AgdClass: CgdcBase; ASubType: TgdcSubType);
begin
  inherited Create;
  FgdClass := AgdClass;
  FSubType := ASubType;
  FPropertyList := TStringList.Create;
  (FPropertyList as TStringList).Sorted := True;
  FValueArray := VarArrayOf([]);
end;

destructor TgdcPropertySet.Destroy;
begin
  FPropertyList.Free;
  inherited;
end;

function TgdcPropertySet.Find(APropertyName: String): Integer;
begin
  Result := FPropertyList.IndexOfName(AnsiUpperCase(APropertyName));
end;

function TgdcPropertySet.GetCount: Integer;
begin
  Result := FPropertyList.Count;
end;

function TgdcPropertySet.GetIndexValue(APropertyName: String): Integer;
var
  Index: Integer;
begin
  Index := Find(APropertyName);
  if Index = -1 then
    raise EgdcException.Create('�������� ' +  APropertyName + ' �� �������!');

  Result := StrToInt(FPropertyList.Values[FPropertyList.Names[Index]]) + 1;
end;

function TgdcPropertySet.GetName(Index: Integer): String;
begin
  Result := FPropertyList.Names[Index];
end;

function TgdcPropertySet.GetValue(APropertyName: String): Variant;
begin
  Result := FValueArray[GetIndexValue(APropertyName)];
end;

procedure TgdcPropertySet.LoadFromStream(S: TStream);
var
  Reader: TReader;

  procedure _ReadVariant(var FValue: Variant);
  const
    ValTtoVarT: array[TValueType] of Integer = (varNull, varError, varByte,
      varSmallInt, varInteger, varDouble, varString, varError, varBoolean,
      varBoolean, varError, varError, varString, varEmpty, varError, varSingle,
      varCurrency, varDate, varOleStr, varError);
  var
    ValType: TValueType;
  begin
    ValType := Reader.NextValue;
    case ValType of
      vaNil, vaNull:
      begin
        if Reader.ReadValue = vaNil then
          VarClear(FValue) else
          FValue := NULL;
      end;
      vaInt8: TVarData(FValue).VByte := Byte(Reader.ReadInteger);
      vaInt16: TVarData(FValue).VSmallint := Smallint(Reader.ReadInteger);
      vaInt32: TVarData(FValue).VInteger := Reader.ReadInteger;
      vaExtended: TVarData(FValue).VDouble := Reader.ReadFloat;
      vaSingle: TVarData(FValue).VSingle := Reader.ReadSingle;
      vaCurrency: TVarData(FValue).VCurrency := Reader.ReadCurrency;
      vaDate: TVarData(FValue).VDate := Reader.ReadDate;
      vaString, vaLString: FValue := Reader.ReadString;
      vaWString: FValue := Reader.ReadWideString;
      vaFalse, vaTrue: TVarData(FValue).VBoolean := Reader.ReadValue = vaTrue;
    else
      raise EgdcException.Create('���������� ������� ��������!');
    end;
    TVarData(FValue).VType := ValTtoVarT[ValType];
  end;

var
  I: Integer;
  FClassName: String;
  FName: String;
  FValue: Variant;
  FCount: Integer;
begin
  Clear;
  Reader := TReader.Create(S, 1024);
  try
    FRUIDSt := Reader.ReadString;
    FClassName := Reader.ReadString;
    FgdClass := CgdcBase(GetClass(FClassName));
    FSubType := Reader.ReadString;
    FCount := Reader.ReadInteger;
    for I := 0 to FCount - 1 do
    begin
      FName := Reader.ReadString;
      _ReadVariant(FValue);
      Add(FName, FValue);
    end;
  finally
    Reader.Free;
  end;
end;

procedure TgdcPropertySet.SaveToStream(S: TStream);
var
  Writer: TWriter;

  procedure _WriteVariant(Value: Variant);
  begin
    case VarType(Value) of
      varEmpty: Writer.WriteIdent('Nil');
      varNull: Writer.WriteIdent('Null');
      varOleStr: Writer.WriteWideString(Value);
      varString: Writer.WriteString(Value);
      varByte, varSmallInt, varInteger: Writer.WriteInteger(Value);
      varSingle: Writer.WriteSingle(Value);
      varDouble: Writer.WriteFloat(Value);
      varCurrency: Writer.WriteCurrency(Value);
      varDate: Writer.WriteDate(Value);
      varBoolean: Writer.WriteBoolean(Value);
      else
        try
          Writer.WriteString(Value);
        except
          raise EgdcException.Create('���������� ��������� ��������!');
        end;
    end;
  end;
var
  I: Integer;
begin
  Writer := TWriter.Create(S, 1024);
  try
    Writer.WriteString(FRUIDSt);
    Writer.WriteString(FgdClass.ClassName);
    Writer.WriteString(FSubType);
    Writer.WriteInteger(Count);
    for I := 0 to Count - 1 do
    begin
      Writer.WriteString(Name[I]);
      _WriteVariant(Value[Name[I]]);
    end;
  finally
    Writer.Free;
  end;
end;

procedure TgdcPropertySet.SetValue(APropertyName: String;
  Value: Variant);
begin
  if VarType(Value) = varBoolean then
  begin
    if Boolean(Value) then
      FValueArray[GetIndexValue(APropertyName)] := 1
    else
      FValueArray[GetIndexValue(APropertyName)] := 0;
  end
  else
    FValueArray[GetIndexValue(APropertyName)] := Value;
end;

{ TgdcPropertySets }

function TgdcPropertySets.Add(const ARUIDSt: String;
  AgdClassName: String; ASubType: TgdcSubType): Integer;
var
  Obj: TgdcPropertySet;
begin
  if IndexOf(ARuidSt) > -1 then
    raise EgdcException.Create('TgdcPropertSets: ������������ ������!');
  Obj := TgdcPropertySet.Create(ARuidSt, CgdcBase(GetClass(AgdClassName)), ASubType);
  Result := AddObject(ARuidSt, Obj);
end;

function TgdcPropertySets.AddObject(const S: string;
  AObject: TgdcPropertySet): Integer;
begin
  if (AObject = nil) or not(AObject.InheritsFrom(TgdcPropertySet)) then
    raise EgdcException.Create('TgdcPropertySets: ������� ������������ ������!');
  Result := inherited AddObject(S, AObject);
end;

procedure TgdcPropertySets.Clear;
var
  I: Integer;
begin
  if FOwnsObjects then
    for I := 0 to Count - 1 do
      Objects[I].Free;
  inherited;
end;

constructor TgdcPropertySets.Create;
begin
  inherited;
  FOwnsObjects := True;
  Sorted := True;
end;

destructor TgdcPropertySets.Destroy;
var
  I: Integer;
begin
  if FOwnsObjects then
    for I := 0 to Count - 1 do
      Objects[I].Free;
  inherited;
end;

function TgdcPropertySets.GetObject(Index: Integer): TgdcPropertySet;
begin
  Result := (inherited GetObject(Index)) as TgdcPropertySet;
end;

procedure TgdcPropertySets.LoadFromStream(S: TStream);
var
  I, J: Integer;
  FCount: Integer;
  FRUID: String;
  Obj: TgdcPropertySet;
begin
  Clear;
  S.ReadBuffer(FCount, SizeOf(FCount));

  for I := 0 to FCount - 1 do
  begin
    S.ReadBuffer(J, SizeOf(J));
    SetLength(FRUID, J);
    S.ReadBuffer(FRUID[1], J);
    Obj := TgdcPropertySet.Create(FRUID, nil, '');
    Obj.LoadFromStream(S);
    AddObject(FRUID, Obj);
  end;
end;

procedure TgdcPropertySets.PutObject(Index: Integer;
  const Value: TgdcPropertySet);
begin
  inherited PutObject(Index, Value);
end;

procedure TgdcPropertySets.SaveToStream(S: TStream);
var
  I, J: Integer;
begin
  I := Count;
  S.Write(I, Sizeof(I));
  for I := 0 to Count - 1 do
  begin
    J := Length(Strings[I]);
    S.Write(J, SizeOf(J));
    S.Write(Strings[I][1], J);
    Objects[I].SaveToStream(S);
  end;
end;

procedure TgdcBase.AddObjectItem(const Name: String);
begin
  if FObjects = nil then
    FObjects := TgdObjects.Create;
  FObjects.AddObject(Name);
end;

procedure TgdcBase.AddVariableItem(const Name: String);
begin
  if FVariables = nil then
    FVariables := TgdVariables.Create;
  FVariables.AddVariable(Name)
end;

function TgdcBase.GetObjects(Name: String): IDispatch;
begin
  if FObjects = nil then
    FObjects := TgdObjects.Create;
  Result := FObjects.Objects[Name];
end;

function TgdcBase.GetVariables(Name: String): OleVariant;
begin
  if FVariables = nil then
    FVariables := TgdVariables.Create;
  Result := FVariables[Name];
end;

procedure TgdcBase.SetObjects(Name: String; const Value: IDispatch);
begin
  if FObjects = nil then
    FObjects := TgdObjects.Create;
  FObjects.Objects[Name] := Value;
end;

procedure TgdcBase.SetVariables(Name: String; const Value: OleVariant);
begin
  if FVariables = nil then
    FVariables := TgdVariables.Create;
  FVariables[Name] := Value;
end;

procedure TgdcBase.SetReadTransaction(const Value: TIBTransaction);
var
  OldTr: TIBTransaction;
  I: Integer;
begin
  if not (csDestroying in ComponentState) then
  begin
    if ReadTransaction <> Value then
    begin
      OldTr := ReadTransaction;

      inherited;

      if FDetailLinks <> nil then
      begin
        for I := 0 to FDetailLinks.Count - 1 do
        begin
          if (FDetailLinks[I] is TIBCustomDataSet)
            and (TIBCustomDataSet(FDetailLinks[I]).ReadTransaction = OldTr) then
          begin
            TIBCustomDataSet(FDetailLinks[I]).ReadTransaction := Value;
          end;
        end;
      end;
    end;
  end;  
end;

function TgdcBase.ObjectExists(const Name: String): Boolean;
begin
  if FObjects = nil then
    Result := False
  else
    Result := FObjects.ObjectExists(Name);
end;

function TgdcBase.VariableExists(Name: String): Boolean;
begin
  if FVariables = nil then
    Result := False
  else
    Result := FVariables.VariableExists(Name);
end;

procedure TgdcBase.BeforeDestruction;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASE', 'BEFOREDESTRUCTION', KEYBEFOREDESTRUCTION)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYBEFOREDESTRUCTION);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREDESTRUCTION]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'BEFOREDESTRUCTION', KEYBEFOREDESTRUCTION, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'BEFOREDESTRUCTION', KEYBEFOREDESTRUCTION)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'BEFOREDESTRUCTION', KEYBEFOREDESTRUCTION);
  {M}  end;
  {END MACRO}
end;

function TgdcBase.GetSQLSetup: TatSQLSetup;
begin
  Result := FSQLSetup;
end;

procedure TgdcBase.DoAfterSelectedChanged(Sender: TObject);
begin
  {���� ������������� ������� �� �����, �������� ���������� �������� ����� ���� � �����}
  if HasSubSet('OnlySelected') then
    FSQLInitialized := False;
end;

procedure TgdcBase.PrepareSLChanged;
var
  J: Integer;
  F: TField;
begin
  Assert(Assigned(SLInitial));
  Assert(Assigned(SLChanged));
  for J := 0 to SLInitial.Count - 1 do
  begin
    F := FieldByName(SLInitial.Names[J]);
    if
      (F.IsNull and (SLInitial.Objects[J] = nil)) or
      ((not F.IsNull) and (SLInitial.Objects[J] <> nil)) or
      (F.AsString <> SLInitial.Values[SLInitial.Names[J]]) then
    begin
      if SLChanged.IndexOfName(SLInitial.Names[J]) <> -1 then
        SLChanged.Delete(SLChanged.IndexOfName(SLInitial.Names[J]));

      if F.IsNull then
      begin
        SLChanged.AddObject(SLInitial.Names[J] + '=', Pointer(1));
      end else
        SLChanged.Add(SLInitial.Names[J] + '=' + F.AsString);
    end;
  end;
end;

procedure TgdcBase.PrepareSLInitial;
var
  I: Integer;
  F: TField;
  BS: TStream;
  TempS: String;
begin
  Assert(Assigned(SLInitial));

  GetFieldNames(SLInitial);
  for I := 0 to SLInitial.Count - 1 do
  begin
    F := FieldByName(SLInitial[I]);

    if F.IsNull then
    begin
      SLInitial.Objects[I] := Pointer(1);
      SLInitial[I] := SLInitial[I] + '=';
      continue;
    end else
      SLInitial.Objects[I] := nil;

    if F is TBlobField then
    begin
      BS := CreateBlobStream(F, DB.bmRead);
      try
        SetLength(TempS, 4096);
        if BS.Read(TempS[1], 4096) < 4096 then
          SLInitial[I] := SLInitial[I] + '=' + F.AsString;
      finally
        BS.Free;
      end;
    end else
    begin
      SLInitial[I] := SLInitial[I] + '=' + F.AsString;
    end;
  end;
  for I := SLInitial.Count - 1 downto 0 do
  begin
    if Pos('=', SLInitial[I]) = 0 then
      SLInitial.Delete(I);
  end;
end;

class function TgdcBase.GetDialogFormClassName(
  const ASubType: TgdcSubType): string;
begin
  // ������ ���������! �� ������� ������� ����!
  Result := 'Tgdc_dlgObjectProperties';
end;

function TgdcBase.DeleteMultiple2(BL: OleVariant): Boolean;
var
  I: Integer;
  OldState: TgdcStates;
begin
  Result := False;

  // ���� ���������� �����, �� ������� ����� ���������� ����� ���������
  // ���� ������������ ParentHandle, �� ����� ��������� ����� '��������'.
  if VarIsEmpty(BL)
    or (VarArrayHighBound(BL, 1) = -1)
    or ((VarArrayHighBound(BL, 1) = 0) and (BL[0] = ID))then
  begin
    if (RecordCount > 0) and
       (
         (not (sView in BaseState)) or
         (MessageBox(Application.Handle,
           PChar(Format('������� ���������� ������ "%s"?', [ObjectName])),
           '��������!',
           MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES)
       ) then
    begin
      Result := DeleteRecord;
    end;
  end
  else
  begin
    if (not (sView in BaseState)) or
         (MessageBox(Application.Handle,
            PChar(
              '�������� �������: ' + FormatFloat('#,##0', VarArrayHighBound(BL, 1) + 1) + #13#10 +
              '�������?'),
            '��������!',
            MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES) then
    begin
      OldState := FBaseState;
      try
        if VarArrayHighBound(BL, 1) > VarArrayLowBound(BL, 1) then
        begin
          Include(FBaseState, sMultiple);
          Include(FBaseState, sAskMultiple);
          Exclude(FBaseState, sSkipMultiple);
        end;

        for I := VarArrayHighBound(BL, 1) downto VarArrayLowBound(BL, 1) do
        begin
          if Locate(GetKeyField(SubType), BL[I], []) then
          begin
            try
              if DeleteRecord then
                Result := True;
            except
              on EAbort do
              begin
                if not ((sMultiple in FBaseState) and (sSkipMultiple in FBaseState)) then
                  raise;
              end;
            end;
          end;
        end;
      finally
        FBaseState := OldState;
      end;
    end;
  end;
end;

function TgdcBase.EditMultiple2(BL: OleVariant;
  const ADlgClassName: String): Boolean;
var
  I, K, ErrCount: Integer;
  Bm: TID;
  CFull: TgdcFullClass;
begin
  Assert(not (sMultiple in BaseState));

  if not
       (
         (sDialog in BaseState)
         or
         (
           Assigned(MasterSource)
           and
           (MasterSource.DataSet is TgdcBase)
           and (sDialog in (MasterSource.DataSet as TgdcBase).BaseState)
         )
       )
     and
       (Transaction <> ReadTransaction)
  then
  begin
    if Transaction.Active then
      raise Exception.Create('Transaction must be closed!');
  end;

  if IsEmpty
    or VarIsEmpty(BL)
    or (VarArrayHighBound(BL, 1) = -1)
    or ((VarArrayHighBound(BL, 1) = 0) and (BL[0] = ID)) then
  begin
    Result := EditDialog(ADlgClassName);
  end
  else begin
    if (VarArrayHighBound(BL, 1) > 0)
      and Assigned(UserStorage)
      and UserStorage.ReadBoolean('Options\Confirmations', 'EditMultiple', True) then
    begin
      if MessageBox(ParentHandle,
        PChar(
          '�������� ��� �������������� �������: ' +
          FormatFloat('#,##0', VarArrayHighBound(BL, 1) + 1) + '. ����������?'),
        '��������',
        MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDNO then
      begin
        Result := False;
        exit;
      end;
    end;

    CFull := GetCurrRecordClass;

    Assert(SLInitial = nil);
    Assert(SLChanged = nil);

    SLInitial := TStringList.Create;
    SLChanged := TStringList.Create;
    try
      Include(FBaseState, sMultiple);
      Bm := ID;
      Result := EditDialog(ADlgClassName);
      if Result then
      begin
        if Bm <> ID then
        begin
          MessageBox(ParentHandle,
            '���� �������� ������ ���� ������. '#13#10 +
            '���������, �� ����������� �� � ��� ��������������. '#13#10 +
            '���� ��, �� �������� �� � ��������� �������������� ������ �������.',
            '��������',
            MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
          exit;
        end;

        if UpperCase(ADlgClassName) = 'TGDC_DLGOBJECTPROPERTIES' then
        begin
          if tiAView in FgdcTableInfos then
          begin
            if SLChanged.IndexOfName('AVIEW') = -1 then
            begin
              SLChanged.Add('AVIEW=' + FieldByName('AVIEW').AsString);
            end;
          end;

          if tiAChag in FgdcTableInfos then
          begin
            if SLChanged.IndexOfName('ACHAG') = -1 then
            begin
              SLChanged.Add('ACHAG=' + FieldByName('ACHAG').AsString);
            end;
          end;

          if tiAFull in FgdcTableInfos then
          begin
            if SLChanged.IndexOfName('AFULL') = -1 then
            begin
              SLChanged.Add('AFULL=' + FieldByName('AFULL').AsString);
            end;
          end;
        end;

        if SLChanged.Count > 0 then
        begin
          DisableControls;
          ErrCount := 0;
          try
            for I := VarArrayLowBound(BL, 1) to VarArrayHighBound(BL, 1) do
            begin
              if (BL[I] = Bm) {or not BookmarkValid(Pointer(BL[I]))} then
                continue;
              if not Locate(GetKeyField(SubType), BL[I], []) then
                continue;
              if (GetCurrRecordClass.gdClass <> CFull.gdClass)
                or (GetCurrRecordClass.SubType <> CFull.SubType) then
              begin
                MessageBox(ParentHandle,
                  '��� ��������� �������� ������ ������ �����.'#13#10 +
                  '��������� ����� ��������� �� �� ���� �������.',
                  '��������',
                  MB_OK or MB_TASKMODAL or MB_ICONEXCLAMATION);
                continue;
              end;
              try
                Edit;
                try
                  for K := 0 to SLChanged.Count - 1 do
                  begin
                    { TODO : �������� ���� ������������ }
                    if FindField(SLChanged.Names[K]) <> nil then
                    begin
                      if SLChanged.Objects[K] <> nil then
                        FieldByName(SLChanged.Names[K]).Clear
                      else
                        FieldByName(SLChanged.Names[K]).AsString := SLChanged.Values[SLChanged.Names[K]];
                    end;
                  end;
                  Post;
                except
                  if State = dsEdit then
                    Cancel;
                  raise;
                end;
              except
                if MessageBox(ParentHandle,
                  '��� ��������� ������ ��������� ������.'#13#10 +
                  '���������� ��������� ��������� ���������� �������?',
                  '��������',
                  MB_YESNO or MB_ICONEXCLAMATION or MB_TASKMODAL) = IDNO then
                begin
                  raise;
                end;

                Inc(ErrCount);
              end;
            end;

            if RecordCount > 0 then
            begin
              try
                Locate(GetKeyField(SubType), Bm, []);
              except
                on E: EDatabaseError do
                begin
                  if not Filtered then
                    raise;
                end;
              end;
            end else
              First;
          finally
            EnableControls;
          end;

          if ErrCount > 0 then
          begin
            MessageBox(ParentHandle,
              PChar(Format('� �������� �������������� �������� ������ � %d ������(��).',
                [ErrCount])),
              '��������',
              MB_OK or MB_ICONHAND or MB_TASKMODAL);
          end;
        end;
      end;
    finally
      Exclude(FBaseState, sMultiple);
      FreeAndNil(SLInitial);
      FreeAndNil(SLChanged);
    end;
  end;
end;

function TgdcBase.CallDoFieldChange(Field: TField): Boolean;
begin
  { TODO : ��������������� Field.ReadOnly ��-�� Issue 1493.
           �� ��������, ���� ��������� ReadOnly � ���������� ����. }
  Result := ((FFieldsCallDoChange.Count = 0)
    and (not (Field.FieldKind in [fkCalculated, fkInternalCalc]))
    {and (not Field.ReadOnly)}) or
   (FFieldsCallDoChange.IndexOf(Field.FieldName) > -1) and not (sLoadFromStream in BaseState);
end;

function TgdcBase.ExecSingleQueryResult(const S: String; Param: Variant;
  out Res: OleVariant): Boolean;
begin
  Result := gdcBaseManager.ExecSingleQueryResult(S, Param, Res, Transaction);
end;

function TgdcBase.GetRuidFromStream: TRUID;
begin
  if sLoadFromStream in BaseState then
  begin
    if (FStreamXID = -1) or (FStreamDBID = -1) then
      raise EgdcException.CreateObj('�� ������ RUID ��� �������, ������������ �� ������.', Self);
    Result.XID := FStreamXID;
    Result.DBID := FStreamDBID;
  end else
    raise EgdcException.CreateObj('������ ������ ���������� � ��������� �������� �� ������.', Self);
end;

function TgdcBase.GetSecCondition: String;
begin
  Result := '';
  // ���� ������������ �������������, �� ��� �����
  // ������� �������� ������ ������ �������� �� 0
  // �.�. ������ ��������� �� � ������ ��� ��������
  if Assigned(IBLogin) and (not IBLogin.IsUserAdmin) then
  begin
    if tiAView in gdcTableInfos then
      Result := Result + Format(' BIN_AND(BIN_OR(%s.aview, 1), %d) <> 0 ',
        [GetListTableAlias, IBLogin.InGroup])
    else if tiAChag in gdcTableInfos then
      Result := Result + Format(' BIN_AND(BIN_OR(%s.achag, 1), %d) <> 0 ',
        [GetListTableAlias, IBLogin.InGroup])
    else if tiAFull in gdcTableInfos then
      Result := Result + Format(' BIN_AND(BIN_OR(%s.afull, 1), %d) <> 0 ',
        [GetListTableAlias, IBLogin.InGroup]);
  end;
end;

function TgdcBase.GetDlgForm: TForm;
begin
  if (FDlgStack.Count > 0) and (FDlgStack.Peek <> nil) and (FDlgStack.Peek is TForm) then
    Result := FDlgStack.Peek as TForm
  else
    Result := nil;
end;

procedure TgdcBase.DoAfterScroll;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASE', 'DOAFTERSCROLL', KEYDOAFTERSCROLL)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOAFTERSCROLL);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERSCROLL]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOAFTERSCROLL', KEYDOAFTERSCROLL, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOAFTERSCROLL', KEYDOAFTERSCROLL)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOAFTERSCROLL', KEYDOAFTERSCROLL);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBase.DoBeforeScroll;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASE', 'DOBEFORESCROLL', KEYDOBEFORESCROLL)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASE', KEYDOBEFORESCROLL);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFORESCROLL]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASE',
  {M}          'DOBEFORESCROLL', KEYDOBEFORESCROLL, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASE', 'DOBEFORESCROLL', KEYDOBEFORESCROLL)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASE', 'DOBEFORESCROLL', KEYDOBEFORESCROLL);
  {M}  end;
  {END MACRO}
end;

function TgdcBase.DoAfterInitSQL(const AnSQLText: String): String;
var
  IsReplaceSQL: Boolean;
begin
  if Assigned(FAfterInitSQL) then
  begin
    Result := AnSQLText;
    IsReplaceSQL := False;
    FAfterInitSQL(Self, Result, IsReplaceSQL);
    if not IsReplaceSQL then
      Result := '';
  end else
    Result := '';
end;

function TgdcBase.GetOldFieldValue(const AFieldName: String): Variant;
var
  I: Integer;
begin
  Result := Unassigned;
  if FOldValues <> nil then
  begin
    for I := 0 to FOldValues.Count - 1 do
      if AnsiCompareText((FOldValues[I] as TFieldValue).FieldName, AFieldName) = 0 then
      begin
        if (FOldValues[I] as TFieldValue).IsNull then
          Result := Null
        else
          Result := (FOldValues[I] as TFieldValue).Value;
        exit;
      end;
  end;    
end;

procedure TgdcBase.CheckDoFieldChange;
begin
  if FInDoFieldChange then
  begin
    MessageBox(ParentHandle,
      '������ �������� ������ Post � Cancel ������ ������������ DoFieldChange � SyncField.',
      '��������',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
  end;
end;

function TgdcBase.GetCanModify: Boolean;
begin
  // inherited GetCanModify ��������� FLiveMode, �������
  // ���������������� ������ � �������� Prepare
  Result := (not InternalPrepared) or (inherited GetCanModify);
end;

class function TgdcBase.GetNotStreamSavedField(const IsReplicationMode: Boolean = False): String;
begin
  if IsReplicationMode then
    Result := 'LB,RB'
  else
    Result := 'LB,RB,CREATORKEY,EDITORKEY';
end;

{ TgdcDragObject }

procedure TgdcDragObject.Finished(Target: TObject; X, Y: Integer;
  Accepted: Boolean);
begin
  inherited;
  Free;
end;

procedure TgdcBase.Resync(Mode: TResyncMode);
begin
  if FInitializingEdit or (sDialog in FBaseState) or (sSubDialog in FBaseState) then
  begin
    FSavedFlag := True;
    try
      if GetActiveBuf <> nil then
        FSavedRN := PRecordData(GetActiveBuf)^.rdRecordNumber;
      inherited;
    finally
      FSavedFlag := False;
    end;
  end else
    inherited;
end;

class function TgdcBase.CheckSubType(const ASubType: String): Boolean;
begin
  Result := gdClassList.Find(Self, ASubType) <> nil;
end;

{ TgdcSetAttribute }

constructor TgdcSetAttribute.Create(const ACrossRelationName,
  AReferenceRelationName, AObjectLinkFieldName, AReferenceLinkFieldName,
  AReferenceObjectNameFieldName, ASQL, AnInsertSQL, ACaption: String;
  const AHasAdditionalFields: Boolean);
begin
  FCrossRelationName := ACrossRelationName;
  FReferenceRelationName := AReferenceRelationName;
  FObjectLinkFieldName := AObjectLinkFieldName;
  FReferenceLinkFieldName := AReferenceLinkFieldName;
  FReferenceObjectNameFieldName := AReferenceObjectNameFieldName;
  FSQL := ASQL;
  FInsertSQL := AnInsertSQL;
  FCaption := ACaption;
  FHasAdditionalFields := AHasAdditionalFields;
end;

function TgdcBase.GetSetAttributes(Index: Integer): TgdcSetAttribute;
begin
  CheckSetAttributes;
  if (FSetAttributes = nil) or (Index < 0) or (Index >= FSetAttributes.Count) then
    raise EgdcException.CreateObj('Invalid index', Self);
  Result := FSetAttributes[Index] as TgdcSetAttribute;
end;

function TgdcBase.GetSetAttributesCount: Integer;
begin
  CheckSetAttributes;
  if FSetAttributes = nil then
    Result := 0
  else
    Result := FSetAttributes.Count;
end;

procedure TgdcBase.CheckSetAttributes;
var
  I, J, K: Integer;
  PK: TatPrimaryKey;
  RL: TStringList;
  Capt, Fields: String;
  C: TgdcFullClass;
begin
  if FSetAttributes <> nil then
    exit;

  FSetAttributes := TObjectList.Create(True);

  RL := TStringList.Create;
  try
    RL.Sorted := True;
    RL.Duplicates := dupIgnore;

    GetTablesName(SelectSQL.Text, TStrings(RL));

    for I := RL.Count - 1 downto 0 do
    begin
      if not Self.ClassType.InheritsFrom(GetBaseClassForRelation(RL[I]).gdClass) then
        RL.Delete(I);
    end;

    for I := 0 to atDatabase.PrimaryKeys.Count - 1 do
    begin
      PK := atDatabase.PrimaryKeys[I];

      if (PK.ConstraintFields.Count < 2)
        or (PK.ConstraintFields[0].References = nil)
        or (PK.ConstraintFields[1].References = nil)
        or (RL.IndexOf(PK.ConstraintFields[0].References.RelationName) = -1) then
        continue;

      Capt := '';

      for J := 0 to PK.ConstraintFields[0].References.RelationFields.Count - 1 do
        if PK.ConstraintFields[0].References.RelationFields[J].CrossRelation = PK.Relation then
        begin
          Capt := PK.ConstraintFields[0].References.RelationFields[J].LShortName;
          break;
        end;

      if Capt = '' then
      begin
        C := GetBaseClassForRelation(PK.Relation.RelationName);
        if C.gdClass <> nil then
          Capt := C.gdClass.GetDisplayName(C.SubType)
        else
          Capt := PK.Relation.LShortName;
      end;

      Fields := '';
      for K := 0 to PK.Relation.RelationFields.Count - 1 do
        Fields := Fields + ':' + PK.Relation.RelationFields[K].FieldName + ',';
      SetLength(Fields, Length(Fields) - 1);

      FSetAttributes.Add(TgdcSetAttribute.Create(
        PK.Relation.RelationName,
        PK.ConstraintFields[1].References.RelationName,
        PK.ConstraintFields[0].FieldName,
        PK.ConstraintFields[1].FieldName,
        'refobjectname_',
        'SELECT cr.*, ' +
        '  rf.' + PK.ConstraintFields[1].References.ListField.FieldName + ' AS refobjectname_ ' +
        'FROM ' +
        '  ' + PK.Relation.RelationName + ' cr ' +
        '    JOIN ' + PK.ConstraintFields[1].References.RelationName + ' rf ' +
        '      ON cr.' + PK.ConstraintFields[1].FieldName + '=' +
            PK.ConstraintFields[1].ReferencesField.FieldName + ' ' +
        'WHERE ' +
        '  cr.' + PK.ConstraintFields[0].FieldName + '=:rf',
        'UPDATE OR INSERT INTO ' + PK.Relation.RelationName +
        ' (' + StringReplace(Fields, ':', '', [rfReplaceAll]) + ') ' +
        'VALUES' +
        ' (' + Fields + ') ' +
        'MATCHING (' + PK.ConstraintFields[0].FieldName + ',' +
          PK.ConstraintFields[1].FieldName + ')',
        Capt, PK.Relation.RelationFields.Count > 2));
    end;
  finally
    RL.Free;
  end;
end;

procedure TgdcBase.GetDependencies(ATr: TIBTransaction; const ASessionID: Integer;
  const AnIncludeSystemObjects: Boolean = False;
  const AnIgnoreFields: String = '');

  const
    LimitCount = 8192;

  procedure _ProcessObject(AnObject: TgdcBase; const ALevel: Integer;
    AProcessed: TgdKeyArray; AHash: TStringHashMap; AnObjects: TObjectList;
    AqInsert: TIBSQL; var ACount: Integer; const AnIgnoreFields: String);
  var
    I, RefCount: Integer;
    RelationName, FieldName: String;
    R: TatRelation;
    F: TatRelationField;
    C, CCurr: TgdcFullClass;
    Obj, TempObj: TgdcBase;
    ArrObjects: array[0..1024] of TgdcBase;
    ArrIDs: array[0..1024] of TID;
    Locked: Boolean;
  begin
    if ACount >= LimitCount then
      exit;

    if AProcessed.IndexOf(AnObject.ID) = -1 then
      AProcessed.Add(AnObject.ID)
    else
      exit;

    R := nil;
    RefCount := 0;

    for I := 0 to AnObject.FieldCount - 1 do
    begin
      if AnObject.Fields[I].DataType <> ftInteger then
        continue;

      if AProcessed.IndexOf(AnObject.Fields[I].AsInteger) <> -1 then
        continue;  

      ParseFieldOrigin(AnObject.Fields[I].Origin, RelationName, FieldName);

      if RelationName = '' then
        continue;

      if StrIPos(';' + FieldName + ';', AnIgnoreFields) > 0 then
        continue;

      if (R = nil) or (AnsiCompareText(R.RelationName, RelationName) <> 0) then
        R := atDatabase.Relations.ByRelationName(RelationName);

      if R = nil then
        continue;

      F := R.RelationFields.ByFieldName(FieldName);

      if (F = nil) or (F.References = nil) then
        continue;

      C := GetBaseClassForRelation(F.References.RelationName);

      if C.gdClass = nil then
        continue;

      Obj := nil;
      AHash.Find(C.gdClass.ClassName + C.SubType, Obj);
      Locked := (Obj <> nil) and Obj.Active;

      if (Obj = nil) or Locked then
      begin
        Obj := C.gdClass.Create(nil);
        AnObjects.Add(Obj);
        if not Locked then
          AHash.Add(C.gdClass.ClassName + C.SubType, Obj);
        Obj.SubType := C.SubType;
        Obj.SubSet := 'ByID';
      end;

      Obj.ID := AnObject.Fields[I].AsInteger;
      Obj.Open;

      if Obj.EOF then
      begin
        Obj.Close;
        continue;
      end;

      CCurr := Obj.GetCurrRecordClass;

      if (CCurr.gdClass.ClassName <> Obj.ClassName) or (CCurr.SubType <> Obj.SubType) then
      begin
        Obj.Close;

        Obj := nil;
        AHash.Find(CCurr.gdClass.ClassName + CCurr.SubType, Obj);
        Locked := (Obj <> nil) and Obj.Active;

        if (Obj = nil) or Locked then
        begin
          Obj := CCurr.gdClass.Create(nil);
          AnObjects.Add(Obj);
          if not Locked then
            AHash.Add(CCurr.gdClass.ClassName + CCurr.SubType, Obj);
          Obj.SubType := CCurr.SubType;
          Obj.SubSet := 'ByID';
        end;

        Obj.ID := AnObject.Fields[I].AsInteger;
        Obj.Open;
      end;

      if Obj.EOF then
      begin
        Obj.Close;
        continue;
      end;

      if
        (
          (Obj is TgdcMetaBase)
          and
          (
            TgdcMetaBase(Obj).IsUserDefined
            or
            AnIncludeSystemObjects
          )
        )
        or
        (
          (not (Obj is TgdcMetaBase))
          and
          (
            (Obj.ID >= cstUserIDStart)
            or
            AnIncludeSystemObjects
          )
        ) then
      begin
        AqInsert.ParamByName('reflevel').AsInteger := ALevel;
        AqInsert.ParamByName('relationname').AsString := RelationName;
        AqInsert.ParamByName('fieldname').AsString := FieldName;
        AqInsert.ParamByName('crossrelation').AsInteger := 0;
        AqInsert.ParamByName('refobjectid').AsInteger := Obj.ID;
        AqInsert.ParamByName('refobjectname').AsString := System.Copy(Obj.ObjectName, 1, 60);
        AqInsert.ParamByName('refrelationname').AsString := R.RelationName;
        AqInsert.ParamByName('refclassname').AsString := Obj.ClassName;
        AqInsert.ParamByName('refsubtype').AsString := Obj.SubType;
        if Obj.FindField('editiondate') <> nil then
          AqInsert.ParamByName('refeditiondate').AsDateTime := Obj.FieldByName('editiondate').AsDateTime
        else
          AqInsert.ParamByName('refeditiondate').Clear;
        AqInsert.ExecQuery;
        Inc(ACount);
      end;

      if RefCount < High(ArrObjects) then
      begin
        ArrObjects[RefCount] := Obj;
        ArrIDs[RefCount] := Obj.ID;
        Inc(RefCount);
      end;

      Obj.Close;
    end;

    for I := 0 to RefCount - 1 do
    begin
      if not ArrObjects[I].Active then
      begin
        TempObj := ArrObjects[I];
        TempObj.ID := ArrIDs[I];
        TempObj.Open;
      end else
      begin
        TempObj := ArrObjects[I].CreateSingularByID(nil, ArrIDs[I],
          ArrObjects[I].SubType);
      end;

      try
        if not TempObj.EOF then
          _ProcessObject(TempObj, ALevel + 1, AProcessed, AHash,
          AnObjects, AqInsert, ACount, AnIgnoreFields);
      finally
        if TempObj = ArrObjects[I] then
          ArrObjects[I].Close
        else
          TempObj.Free;
      end;    
    end;

    for I := 0 to AnObject.SetAttributesCount - 1 do
    begin
      C := GetBaseClassForRelation(AnObject.SetAttributes[I].ReferenceRelationName);

      if C.gdClass = nil then
        continue;

      Obj := nil;
      AHash.Find(C.gdClass.ClassName + C.SubType + AnObject.SetAttributes[I].CrossRelationName, Obj);
      Locked := (Obj <> nil) and Obj.Active;

      if (Obj = nil) or Locked then
      begin
        Obj := C.gdClass.Create(nil);
        AnObjects.Add(Obj);
        if not Locked then
          AHash.Add(C.gdClass.ClassName + C.SubType + AnObject.SetAttributes[I].CrossRelationName, Obj);
        Obj.SubType := C.SubType;
        Obj.SubSet := 'All';
        Obj.SetTable := AnObject.SetAttributes[I].CrossRelationName;
      end;

      Obj.ParamByName('master_record_id').AsInteger := AnObject.ID;
      Obj.Open;

      while not Obj.Eof do
      begin
        CCurr := Obj.GetCurrRecordClass;

        if (CCurr.gdClass.ClassName <> Obj.ClassName) or (CCurr.SubType <> Obj.SubType) then
        begin
          TempObj := nil;
          AHash.Find(CCurr.gdClass.ClassName + CCurr.SubType, TempObj);
          Locked := (TempObj <> nil) and TempObj.Active;

          if (TempObj = nil) or Locked then
          begin
            TempObj := CCurr.gdClass.Create(nil);
            AnObjects.Add(TempObj);
            if not Locked then
              AHash.Add(CCurr.gdClass.ClassName + CCurr.SubType, TempObj);
            TempObj.SubType := CCurr.SubType;
            TempObj.SubSet := 'ByID';
          end;

          TempObj.ID := Obj.ID;
          TempObj.Open;
        end else
          TempObj := Obj;

        if AProcessed.IndexOf(TempObj.ID) = -1 then
        begin
          if
            (
              AnIncludeSystemObjects
              or
              (TempObj.ID >= cstUserIDStart)
              or
              (
                (TempObj is TgdcMetaBase)
                and
                TgdcMetaBase(TempObj).IsUserDefined
              )
            )
            and
            (
              ACount < LimitCount
            ) then
          begin
            AqInsert.ParamByName('reflevel').AsInteger := ALevel;
            AqInsert.ParamByName('relationname').AsString := AnObject.SetAttributes[I].CrossRelationName;
            AqInsert.ParamByName('fieldname').AsString := AnObject.SetAttributes[I].ReferenceLinkFieldName;
            AqInsert.ParamByName('crossrelation').AsInteger := 1;
            AqInsert.ParamByName('refobjectid').AsInteger := TempObj.ID;
            AqInsert.ParamByName('refobjectname').AsString := System.Copy(TempObj.ObjectName, 1, 60);
            AqInsert.ParamByName('refrelationname').AsString := AnObject.SetAttributes[I].ReferenceRelationName;
            AqInsert.ParamByName('refclassname').AsString := TempObj.ClassName;
            AqInsert.ParamByName('refsubtype').AsString := TempObj.SubType;
            if TempObj.FindField('editiondate') <> nil then
              AqInsert.ParamByName('refeditiondate').AsDateTime := TempObj.FieldByName('editiondate').AsDateTime
            else
              AqInsert.ParamByName('refeditiondate').Clear;
            AqInsert.ExecQuery;
            Inc(ACount);
          end;

          _ProcessObject(TempObj, ALevel + 1, AProcessed, AHash,
            AnObjects, AqInsert, ACount, AnIgnoreFields);

          if TempObj <> Obj then
            TempObj.Close;  
        end;

        Obj.Next;
      end;

      Obj.Close;
    end;
  end;

var
  Hash: TStringHashMap;
  Processed: TgdKeyArray;
  Objects: TObjectList;
  q: TIBSQL;
  Count: Integer;
  C: TgdcFullClass;
  Obj: TgdcBase;
begin
  Assert(atDatabase <> nil);
  Assert(ATr <> nil);
  Assert(ATr.InTransaction);
  Assert(not EOF);

  C := GetCurrRecordClass;
  if (C.gdClass = Self.ClassType) and (C.SubType = Self.SubType) then
    Obj := Self
  else
    Obj := C.gdClass.CreateSingularByID(nil, Database, Transaction, ID, C.SubType);

  Hash := TStringHashMap.Create(CaseSensitiveTraits, 1024);
  Processed := TgdKeyArray.Create;
  Objects := TObjectList.Create(True);
  q := TIBSQL.Create(nil);
  try
    q.Transaction := ATr;
    q.SQL.Text :=
      'DELETE FROM gd_object_dependencies WHERE sessionid = :sessionid';
    q.ParamByName('sessionid').AsInteger := ASessionID;
    q.ExecQuery;

    q.SQL.Text :=
      'UPDATE OR INSERT INTO gd_object_dependencies ( ' +
      '  sessionid, masterid, reflevel, relationname, fieldname, crossrelation, ' +
      '  refobjectid, refobjectname, refrelationname, refclassname, refsubtype, ' +
      '  refeditiondate) ' +
      'VALUES ' +
      '  (:sessionid, :masterid, :reflevel, :relationname, :fieldname, :crossrelation, ' +
      '  :refobjectid, :refobjectname, :refrelationname, :refclassname, :refsubtype, ' +
      '  :refeditiondate) ' +
      'MATCHING (sessionid, masterid, reflevel, relationname, fieldname, refobjectid)';
    q.ParamByName('sessionid').AsInteger := ASessionID;
    q.ParamByName('masterid').AsInteger := Self.ID;

    Count := 0;
    _ProcessObject(Obj, 0, Processed, Hash, Objects, q, Count,
      AnIgnoreFields + ';LB;RB;AVIEW;ACHAG;AFULL;RESERVED;');
  finally
    q.Free;
    Processed.Free;
    Hash.Free;
    Objects.Free;
    if Obj <> Self then
      Obj.Free;
  end;
end;

procedure TgdcBase.SetStreamDBID(const Value: TID);
begin
  if not (sLoadFromStream in BaseState) then
    raise EgdcException.CreateObj('������ ������ ���������� � ��������� �������� �� ������.', Self);
  FStreamDBID := Value;
end;

procedure TgdcBase.SetStreamXID(const Value: TID);
begin
  if not (sLoadFromStream in BaseState) then
    raise EgdcException.CreateObj('������ ������ ���������� � ��������� �������� �� ������.', Self);
  FStreamXID := Value;
end;

{ TgdcCompoundClass }

constructor TgdcCompoundClass.Create(const AgdClass: CgdcBase;
  const ASubType: TgdcSubType; const ALinkRelationName: String;
  const ALinkFieldName: String);
begin
  FgdClass := AgdClass;
  FSubType := ASubType;
  FLinkFieldName := ALinkFieldName;
  FLinkRelationName := ALinkRelationName;
end;

function TgdcBase.GetCompoundClasses(Index: Integer): TgdcCompoundClass;
begin
  CheckCompoundClasses;
  if FCompoundClasses <> nil then
    Result := FCompoundClasses[Index] as TgdcCompoundClass
  else
    Result := nil;
end;

function TgdcBase.GetCompoundClassesCount: Integer;
begin
  CheckCompoundClasses;
  if FCompoundClasses <> nil then
    Result := FCompoundClasses.Count
  else
    Result := 0;
end;

procedure TgdcBase.CheckCompoundClasses;
var
  L: TObjectList;
  I: Integer;
  F: TatForeignKey;
  FC: TgdcFullClass;
begin
  Assert(atDatabase <> nil);

  if FCompoundClasses <> nil then
    exit;

  L := TObjectList.Create(False);
  try
    atDatabase.ForeignKeys.ConstraintsByReferencedRelation(
      GetCompoundMasterTable, L, False, True, False);

    for I := 0 to L.Count - 1 do
    begin
      F := L[I] as TatForeignKey;
      if (F.ConstraintFields.Count = 1)
        and ((F.ConstraintFields[0].FieldName = 'MASTERKEY')
          or (F.ConstraintFields[0].Field.FieldName = 'DMASTERKEY')) then
      begin
        FC := GetBaseClassForRelation(F.Relation.RelationName);
        if (FC.gdClass <> nil) and (not FC.gdClass.IsAbstractClass)
          and (F.ConstraintFields[0].Relation.RelationName <> 'AC_RECORD') then
        begin
          if FCompoundClasses = nil then
            FCompoundClasses := TObjectList.Create(True);
          FCompoundClasses.Add(
            TgdcCompoundClass.Create(FC.gdClass, FC.SubType,
              F.ConstraintFields[0].Relation.RelationName,
              F.ConstraintFields[0].FieldName));
        end;
      end;
    end;
  finally
    L.Free;
  end;
end;

function TgdcBase.GetCompoundMasterTable: String;
begin
  Result := GetListTable(SubType);
end;

class function TgdcBase.GetDistinctTable(const ASubType: TgdcSubType): String;
begin
  Result := (gdClassList.Get(TgdBaseEntry, Self.ClassName,
    ASubType) as TgdBaseEntry).DistinctRelation;
end;

initialization
  UseSavepoints := True;
  gdcClipboardFormat := RegisterClipboardFormat(gdcClipboardFormatName);

  RegisterGDCClass(TgdcBase);

  // ����������� ������� TgdcBase ��� ���������� �� �� ��������
  TgdcBase.RegisterMethod;

  CacheDBID := -1;
  CacheList := nil;

finalization
  FreeAndNil(CacheList);
  UnregisterGdcClass(TgdcBase);

  {$IFDEF DEBUG}
  if InvokeCounts <> nil then
  try
    InvokeCounts.SaveToFile(ExtractFilePath(Application.EXEName) + 'invoke.log');
  except
  end;  
  FreeAndNil(InvokeCounts);
  {$ENDIF}

{***@DECLARE MACRO Inh_Params (%Var%)
%Var%
  Params, LResult: Variant;
  Index: Integer;
  InheritedFlag: Boolean;
END MACRO}

{***@DECLARE MACRO Inh_Body(%ClassName%, %MethodName%)
  try
    if Assigned(MethodControl) then
    begin
      InheritedFlag := False;
      SetFirstClassMethod(%ClassName%, %MethodName%);
      Index := LastCallClass.IndexOf(%MethodName%);
      if (Index = -1) or (TStrings(LastCallClass.Objects[Index]).IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcOLEObject(Self) as IDispatch]);
        if MethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, Params, LResult) then exit;
      end else
        if (TStrings(LastCallClass.Objects[Index]).IndexOf(%ClassName%) > -1) and
          (TStrings(LastCallClass.Objects[Index])[TStrings(LastCallClass.Objects[Index]).Count - 1]
          <> %ClassName%) then
        begin
          InheritedFlag := True;
        end;
    end else
      InheritedFlag := True;

    if InheritedFlag then
    begin
END MACRO}

{***@DECLARE MACRO Inh_Finally (%ClassName%, %MethodName%)
    end;
  finally
    if Assigned(MethodControl) then
      ClearMacrosStack(%ClassName%, %MethodName%);
  end;
END MACRO}


//For methods without parameters
{
    procedure DoAfterDelete; override;
    procedure DoAfterInsert; override;
    procedure DoAfterEdit; override;
    procedure DoAfterOpen; override;
    procedure DoAfterPost; override;
    procedure DoAfterCancel; override;
    procedure DoBeforeClose; override;
    procedure DoBeforeDelete; override;
    procedure DoBeforeEdit; override;
    procedure DoBeforeInsert; override;
    procedure DoBeforePost; override;
    procedure DoOnNewRecord; override;
    procedure DoBeforeOpen; override;
    procedure _DoOnNewRecord; virtual;

}
{@DECLARE MACRO INH_ORIG_WITHOUTPARAM(%ClassName%, %MethodName%, %MethodKey%)
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self)]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then exit;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Inherited;
          Exit;
        end;
    end;
END MACRO}


{FOR
    procedure CustomInsert(Buff: Pointer); virtual;
    procedure CustomModify(Buff: Pointer); virtual;
    procedure CustomDelete(Buff: Pointer); virtual;
}
{@DECLARE MACRO Inh_Orig_CustomInsert(%ClassName%, %MethodName%, %MethodKey%)
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          exit;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Inherited;
          Exit;
        end;
    end;
END MACRO}

// For methods with Sender
{
    procedure DoOnReportListClick(Sender: TObject);
    procedure DoAfterTransactionEnd(Sender: TObject); override;
    procedure DoAfterExtraChanged(Sender: TObject);
    procedure DoOnReportClick(Sender: TObject); virtual;
}

{@DECLARE MACRO Inh_Orig_Sender(%ClassName%, %MethodName%, %MethodKey%)
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(Sender)]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          exit;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Inherited;
          Exit;
        end;
    end;
END MACRO}

//     procedure DoFieldChange(Field: TField); virtual;
{@DECLARE MACRO Inh_Orig_DoFieldChange(%ClassName%, %MethodName%, %MethodKey%)
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(Field)]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          exit;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Inherited;
          Exit;
        end;
    end;
END MACRO}


//     procedure DoOnFilterChanged(Sender: TObject; const AnCurrentFilter: Integer);
{@DECLARE MACRO Inh_Orig_DoOnFilterChanged(%ClassName%, %MethodName%, %MethodKey%)
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self),
          GetGdcInterface(Sender), AnCurrentFilter]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          exit;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Inherited;
          Exit;
        end;
    end;
END MACRO}

//     procedure DoAfterCustomProcess(Buff: Pointer; Process: TgsCustomProcess); virtual;
{@DECLARE MACRO Inh_Orig_DoAfterCustomProcess(%ClassName%, %MethodName%, %MethodKey%)
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self),
          Integer(Buff), TgsCustomProcess(Process)]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          exit;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Inherited;
          Exit;
        end;
    end;
END MACRO}

//    procedure DoBeforeShowDialog(DlgForm: TCreateableForm); virtual;
{@DECLARE MACRO Inh_Orig_DoBeforeShowDialog(%ClassName%, %MethodName%, %MethodKey%)
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(DlgForm)]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          exit;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Inherited;
          Exit;
        end;
    end;
END MACRO}

//    procedure DoAfterShowDialog(DlgForm: TCreateableForm; IsOk: Boolean); virtual;
{@DECLARE MACRO Inh_Orig_DoAfterShowDialog(%ClassName%, %MethodName%, %MethodKey%)
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self),
          GetGdcInterface(DlgForm), IsOk]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          exit;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Inherited;
          Exit;
        end;
    end;
END MACRO}

//    function CreateDialogForm: TCreateableForm; virtual;
{@DECLARE MACRO Inh_Orig_funcCreateDialogForm(%ClassName%, %MethodName%, %MethodKey%)
  try
    Result := nil;
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self)]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          begin
            Result := nil;
            if VarType(LResult) <> varDispatch then
              raise Exception.Create('������-�������: ' + Self.ClassName +
                TgdcBase(Self).SubType + %MethodName% + #13#10 + '��� ������ ''' +
                %MethodName% + ' ''' + '������ ' + Self.ClassName +
                TgdcBase(Self).SubType + #10#13 + '�� ������� ��������� �� ������.')
            else
              if IDispatch(LResult) = nil then
                raise Exception.Create('������-�������: ' + Self.ClassName +
                  TgdcBase(Self).SubType + %MethodName% + #13#10 + '��� ������ ''' +
                  %MethodName% + ' ''' + '������ ' + Self.ClassName +
                  TgdcBase(Self).SubType + #10#13 + '�� ������� ��������� ������ (null) ������.');
            Result := GetInterfaceToObject(LResult) as TCreateableForm;
            exit;
          end;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Result := Inherited CreateDialogForm;
          Exit;
        end;
    end;
END MACRO}

//    function EditDialog(const ADlgClassName: String = ''): Boolean;
{@DECLARE MACRO Inh_Orig_EditDialog(%ClassName%, %MethodName%, %MethodKey%)
  Result := False;
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self), ADlgClassName]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          begin
            Result := False;
            if VarType(LResult) = varBoolean then
              Result := Boolean(LResult)
            else
              begin
                raise Exception.Create('��� ������ ''' + %MethodName% + ' ''' +
                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
                  '�� ������� ��������� �� ������� ���');
              end;
            exit;
          end;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
          Exit;
    end;
END MACRO}


//    function CreateDialog(const ADlgClassName: String = ''): Boolean; overload; virtual;
{@DECLARE MACRO Inh_Orig_CreateDialog(%ClassName%, %MethodName%, %MethodKey%)
  Result := False;
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self), ADlgClassName]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          begin
            Result := False;
            if VarType(LResult) = varBoolean then
              Result := Boolean(LResult)
            else
              begin
                raise Exception.Create('��� ������ ''' + %MethodName% + ' ''' +
                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
                  '�� ������� ��������� �� ������� ���');
              end;
            exit;
          end;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Result := Inherited CreateDialog(ADlgClassName);
          Exit;
        end;
    end;
END MACRO}

//    class function CreateViewForm(AnOwner: TComponent;
//      const AClassName: String = '';
//      const ASubType: String = ''): TForm; virtual;
{@DECLARE MACRO Inh_Orig_CreateViewForm(%ClassName%, %MethodName%, %MethodKey%)
  Result := nil;
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self),
          GetGdcInterface(AnOwner), AClassName, ASubType]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          begin
            Result := False;
            if VarType(LResult) = varBoolean then
              Result := GetInterfaceToObject(LResult) as TForm
            else
              begin
                raise Exception.Create('��� ������ ''' + %MethodName% + ' ''' +
                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
                  '�� ������� ��������� �� ������');
              end;
            exit;
          end;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Result := Inherited;
          Exit;
        end;
    end;
END MACRO}

//    function CopyDialog: Boolean;
{@DECLARE MACRO Inh_Orig_CopyDialog(%ClassName%, %MethodName%, %MethodKey%)
  Result := False;
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self)]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          begin
            Result := False;
            if VarType(LResult) = varBoolean then
              Result := Boolean(LResult)
            else
              begin
                raise Exception.Create('��� ������ ''' + %MethodName% + ' ''' +
                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
                  '�� ������� ��������� �� ������� ���');
              end;
            exit;
          end;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Result := Inherited CopyDialog;
          Exit;
        end;
    end;
END MACRO}

//    function: String;
{@DECLARE MACRO Inh_Orig_OutString(%ClassName%, %MethodName%, %MethodKey%)
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self)]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          begin
            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
              Result := String(LResult)
            else
              begin
                raise Exception.Create('��� ������ ''' + %MethodName% + ' ''' +
                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
                  '�� ������� ��������� �� ��������� ���');
              end;
            exit;
          end;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Result := Inherited;
          Exit;
        end;
    end;
END MACRO}


{@DECLARE MACRO Inh_Orig_GetSelectClause(%ClassName%, %MethodName%, %MethodKey%)
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self)]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          begin
            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
              Result := String(LResult)
            else
              begin
                raise Exception.Create('��� ������ ''' + %MethodName% + ' ''' +
                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
                  '�� ������� ��������� �� ��������� ���');
              end;
            exit;
          end;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Result := Inherited GetSelectClause;
          Exit;
        end;
    end;
END MACRO}

{@DECLARE MACRO Inh_Orig_GetWhereClause(%ClassName%, %MethodName%, %MethodKey%)
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self)]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          begin
            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
              Result := String(LResult)
            else
              begin
                raise Exception.Create('��� ������ ''' + %MethodName% + ' ''' +
                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
                  '�� ������� ��������� �� ��������� ���');
              end;
            exit;
          end;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Result := Inherited GetWhereClause;
          Exit;
        end;
    end;
END MACRO}

{@DECLARE MACRO Inh_Orig_GetGroupClause(%ClassName%, %MethodName%, %MethodKey%)
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self)]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          begin
            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
              Result := String(LResult)
            else
              begin
                raise Exception.Create('��� ������ ''' + %MethodName% + ' ''' +
                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
                  '�� ������� ��������� �� ��������� ���');
              end;
            exit;
          end;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Result := Inherited GetGroupClause;
          Exit;
        end;
    end;
END MACRO}

{@DECLARE MACRO Inh_Orig_GetOrderClause(%ClassName%, %MethodName%, %MethodKey%)
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self)]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          begin
            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
              Result := String(LResult)
            else
              begin
                raise Exception.Create('��� ������ ''' + %MethodName% + ' ''' +
                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
                  '�� ������� ��������� �� ��������� ���');
              end;
            exit;
          end;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Result := Inherited GetOrderClause;
          Exit;
        end;
    end;
END MACRO}

{@DECLARE MACRO Inh_Orig_CheckTheSameStatement(%ClassName%, %MethodName%, %MethodKey%)
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self)]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          begin
            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
              Result := String(LResult)
            else
              begin
                raise Exception.Create('��� ������ ''' + %MethodName% + ' ''' +
                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
                  '�� ������� ��������� �� ��������� ���');
              end;
            exit;
          end;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Result := Inherited CheckTheSameStatement;
          Exit;
        end;
    end;
END MACRO}

//    function GetFromClause(const ARefresh: Boolean = False): String;
{@DECLARE MACRO Inh_Orig_GetFromClause(%ClassName%, %MethodName%, %MethodKey%)
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          begin
            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
              Result := String(LResult)
            else
              begin
                raise Exception.Create('��� ������ ''' + %MethodName% + ' ''' +
                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
                  '�� ������� ��������� �� ��������� ���');
              end;
            exit;
          end;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Result := Inherited GetFromClause(ARefresh);
          Exit;
        end;
    end;
END MACRO}

//    function GetNotCopyField: String;
{@DECLARE MACRO Inh_Orig_GetNotCopyField(%ClassName%, %MethodName%, %MethodKey%)
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self)]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          begin
            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
              Result := String(LResult)
            else
              begin
                raise Exception.Create('��� ������ ''' + %MethodName% + ' ''' +
                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
                  '�� ������� ��������� �� ��������� ���');
              end;
            exit;
          end;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Result := Inherited GetNotCopyField;
          Exit;
        end;
    end;
END MACRO}

//    function CheckSubSet(const ASubSet: String): Boolean;
{@DECLARE MACRO Inh_Orig_CheckSubSet(%ClassName%, %MethodName%, %MethodKey%)
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self), ASubSet]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          begin
            if VarType(LResult) = varBoolean then
              Result := Boolean(LResult)
            else
              begin
                Result := False;
                raise Exception.Create('��� ������ ''' + %MethodName% + ' ''' +
                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
                  '�� ������� ��������� �� ������� ���');
              end;
            exit;
          end;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Result := Inherited CheckSubSet(ASubSet);
          Exit;
        end;
    end;
END MACRO}


//    function OutBoolean: Boolean;
{@DECLARE MACRO Inh_Orig_OutBoolean(%ClassName%, %MethodName%, %MethodKey%)
  try
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self)]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then
          begin
            if VarType(LResult) = varBoolean then
              Result := Boolean(LResult)
            else
              begin
                raise Exception.Create('��� ������ ''' + %MethodName% + ' ''' +
                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
                  '�� ������� ��������� �� ������� ���');
              end;
            exit;
          end;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Result := Inherited;
          Exit;
        end;
    end;
END MACRO}

{@DECLARE MACRO Inh_Orig_Params(%Var%)
%Var%
  Params, LResult: Variant;
  tmpStrings: TStackStrings;
END MACRO}

{@DECLARE MACRO Inh_Orig_Finally(%ClassName%, %MethodName%, %MethodKey%)
  finally
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
      ClearMacrosStack2(%ClassName%, %MethodName%, %MethodKey%);
  end;
END MACRO}



// �������� ��� ���������� �������
(*
// CURR_CLASS - ������� �����
// CURR_METHOD - ������� �����
// KEY_CURR_METHOD - ���� ��� �������� ������
VAR
  // ���������� ����������� ��� ����������
  Params, LResult: Variant;
  tmpStrings: TStackStrings;
begin
  try
    // ������ ��������� ���������� ������
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
    begin
      // ��������� ������� ������
      SetFirstMethodAssoc('CURR_CLASS', KEY_CURR_METHOD);
      // �������� �� ����� ��������� ���� TStackStrings ��� �������� ������
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_CURR_METHOD]);
      // ���� ��������� ����������� ��� ������� ������ � ��� ���, �� ��������
      // ������, ����� �� ����� ������ �� ������� �������
      if (tmpStrings = nil) or (tmpStrings.IndexOf('CURR_CLASS') = -1) then
      begin
        // ������������ ����������� ������� ���������� ��� ������ �������
        // Self ���������� ������, ����� ��������� ������, ���� ��� ����
        // !!! ��� Var-���������� �������� ����� ����� GetVarInterface
        // ������: Params := VarArrayOf([GetGdcInterface(Self), GetVarInterface(Var_Param)]);
        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'CURR_CLASS',
          'CURR_METHOD', KEY_CURR_METHOD, Params, LResult) then
        begin
          // ���� ���� Var-��������, �� ������� ��� �� �������
          // ������: Var_Param := ����������_�_����(getVarParam(Params[...]));
          exit;
        end;
      end else
        // ���� ������� ����� �� ��������� � ��������� ������ ���� �����-�����
        // ��� ���������� - ��������� �� Inherited � ���������� ������ ��������
        if tmpStrings.LastClass.gdClassName <> 'CURR_CLASS' then
        begin       
          Inherited;
          Exit;
        end;
    end;

// !!!_�����-�����_!!!
   ...
// !!!�����_�����-�����_!!!

  finally
    // !!! ������� ����� �����������, �.�.
    // ���� ���� �� ���������, �� ��� ��������� ������ ������ �� �� ����������.
    // ���� ��� ������ ���������� � ���� try finally, ��� � finally ClearMacrosStack2
    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
      ClearMacrosStack2('CURR_CLASS', 'CURR_METHOD', KEY_CURR_METHOD);
  end;
*)
end.

