// ShlTanya, 09.02.2019

{++

  Copyright (c) 2001 - 2016 by Golden Software of Belarus, Ltd

  Module

    gd_ClassList.pas

  Abstract

    Gedemin project.

  Author

    Mikhailenko Oleg

  Revisions history

    1.00   01.06.01  Andreik Kireev  Initial version.
    1.01   01.10.01  JKL     Class was separated from gdcBase.
    1.02   05.01.02  oleg_m  Fixed some errors
    1.03   08.01.02  oleg_m  Added stream I/O capabilities
    1.04   09.01.02  oleg_m  Added TTypeData field und accesories
    1.05   11.01.02  oleg_m  TTypeData field & Streaming
    1.10   24.01.02  oleg_m  Final version

--}

unit gd_ClassList;

interface

uses
  Contnrs,        Classes,   TypInfo,     Forms,            gd_KeyAssoc,
  gdcBase,        gdc_createable_form,    gdcBaseInterface, at_classes,
  gdcClasses_Interface, gdcInvConsts_unit,IBSQL,            IBDatabase,
  DB,
  {$IFDEF VER130}
  gsStringHashList
  {$ELSE}
  IniFiles
  {$ENDIF}
  ;

// ����� ��� ���������� �������
const
  // ��� ���������� ����� TgdcBase (�����, �.�. ���� ������ ����� ���������)
  keyCustomInsert          = 4;
  keyCustomModify          = 7;
  keyCustomDelete          = 10;
  keyDoAfterDelete         = 13;
  keyDoAfterInsert         = 16;
  keyDoAfterEdit           = 17;
  keyDoAfterOpen           = 19;
  keyDoAfterPost           = 22;
  keyDoAfterCancel         = 23;
  keyDoAfterScroll         = 24;
  keyDoBeforeClose         = 25;
  keyDoBeforeDelete        = 28;
  keyDoBeforeEdit          = 31;
  keyDoBeforeInsert        = 34;
  keyDoBeforePost          = 37;
  keyDoBeforeScroll        = 38;
  keyDoAfterTransactionEnd = 40;
  keyDoOnNewRecord         = 43;
  keyDoOnReportListClick   = 46;
  keyDoAfterExtraChanged   = 49;
  keyDoOnReportClick       = 52;
  keyDoBeforeOpen          = 55;
  key_DoOnNewRecord        = 58;
  keyCopyDialog            = 61;
  keyDoOnFilterChanged     = 64;
  keyDoAfterCustomProcess  = 67;
  keyDoBeforeShowDialog    = 70;
  keyDoAfterShowDialog     = 73;
  keyCreateDialogForm      = 76;
  keyEditDialog            = 79;
  keyCreateDialog          = 82;
  keyDoFieldChange         = 85;
  keyGetSelectClause       = 87;
  keyGetFromClause         = 91;
  keyGetWhereClause        = 93;
  keyGetOrderClause        = 97;
  keyGetGroupClause        = 101;
  keyValidateField         = 103;
  keyCheckTheSameStatement = 107;
  keyCreateFields          = 109;
  keyGetNotCopyField       = 111;
  keyBeforeDestruction     = 113;
  keyAfterConstruction     = 114;
  keyCheckSubSet           = 117;
  keyGetDialogDefaultsFields = 119;

  // ��� ���������� ����� TgdcCreateableForm (�����, �.�. ���� ������ ����� ���������)
  keySaveSettings            = 203;
  keySetup                   = 205;
  keyLoadSettings            = 207;
  keyBeforePost              = 209;
  keyCancel                  = 210;
  keyPost                    = 211;
  keyTestCorrect             = 213;
  keySetChoose               = 217;
  keyLoadSettingsAfterCreate = 219;
  keySyncField               = 221;
  keyNeedVisibleTabSheet     = 223;
  keySaveAndShowTabSheet     = 227;
  keySetupRecord             = 229;
  keyGetgdcClass             = 231;
  keyGetChooseComponentName  = 233;
  keyGetChooseSubSet         = 237;
  keyGetChooseSubType        = 239;
  keyRemoveSubSetList        = 241;
  keySetupDialog             = 243;

const
  // ��������� ��� ����������� �������� ���������� ������� � ���������
  // �������� � ������ ������, ���� ����������� ����� � ������
  SubtypeFlag = '*';
  // ��������� ����� � ������ � ������
  SubtypeDetach = '=';

type
  // ����� ��� ����������� ����� ������� ���������� �������
  TStackStrings = class(TObject)
  private
    FStackString: TStrings;
    function GetFullClassName(const Str: string): TgdcFullClassName;

  public
    destructor Destroy; override;

    function  Add(const FullClassName: TgdcFullClassName): Integer;
    function  AddObject(const FullClassName: TgdcFullClassName;  AObject: TObject): Integer;
    function  IndexOf(const ClassName: String): Integer;
    function  IsEmpty: Boolean;
    function  LastClass: TgdcFullClassName;
    function  LastObject: TObject;
    procedure Clear;
  end;

  // ����� ������������ ��� �������� ��������� ��������� ������
  TgdMethodParam = class
  private
    {������������ ���������}
    FParamName: String;
    {����� ���������}
    FParamClass: TComponentClass;
    {��� ��������� � ��������� ����.}
    FParamTypeName: String;
    {���� (��. TypInfo.pas) }
    FParamFlag: TParamFlag;

    function GetIsParamClass: Boolean;
    procedure SetParamName(const Value: String);
  protected
    {�������� �� ���-�� ���� ����������}
    function EqualsByName(const AParamName: String): Boolean;
    {������ �������� �� ���-�� ���-���: ����������� ��� ����}
    function EqualsFull(const AParam: TgdMethodParam): Boolean;

  public
    constructor Create; overload;
    destructor Destroy; override;

    procedure Assign(ASource: TgdMethodParam);

    property ParamName: String read FParamName write SetParamName;
    property ParamClass: TComponentClass read FParamClass;
    property ParamTypeName: String read FParamTypeName;
    property IsParamClass: Boolean read GetIsParamClass;
    property ParamFlag: TParamFlag read FParamFlag;
  end;

  // �����, �������� ���������� � ������, ������� ��� ���������
  TgdMethod = class
  private
    {������������ ������}
    FName: String;
    {��������� � ����� ������}
    FParams: TList;
    {��������� � ������� ��������� ���� TTypeData}
    FParamsData: TTypeData;
    {��� ���������� � ��������� ����}
    FFuncResType: String;

    procedure FreeFParams;

    function GetParamCount: Integer;
    function GetMethodParam(Index: Integer): TgdMethodParam;
    function AddParamToList(const AParam: TgdMethodParam): Integer; overload;
    function AddParamToList(AParamName, ATypeName: String;
      AParamFlag: TParamFlag): Integer; overload;
    procedure CustomDelete(Index: Integer);
    procedure StoreResultInTD(APosition: Integer);
    procedure AddParamToParamsData(AParamName, AParamType: String;
      AParamFlag: TParamFlag);
    function IsMethodFunction: Boolean;
    function ReadStrFromTD(ATD: TTypeData; var APosition: Integer): String;
    procedure WriteStrToTD(var ATD: TTypeData; var APosition: Integer;
      const S: String);

  protected
    {�������� �� ������������� ��������� � ������ ������ � ������ ���-���}
    function ParamByNameExists(const AParamName: String): Boolean;
    {�������� �� ������������� ��������� � ������ ���-���}
    function ParamExists(const AParam: TgdMethodParam): Boolean;
    {�������� ������� �� ���-��: ������ ��������� ������� ���� ����� �� ���� �
     ������ ����������}
    function Equals(const AMethod: TgdMethod): Boolean;

  public
    constructor Create(AName: String; AKind: TMethodKind; AFuncResType: String = ''); overload;
    destructor Destroy; override;

    function AddParam(AParamName, ATypeName: String;
      AParamFlag: TParamFlag): Integer; overload;
    procedure Clear;
    procedure Assign(ASource: TgdMethod);

    property Name: String read FName write FName;
    property ParamCount: Integer read GetParamCount;
    property Params[Index: Integer]: TgdMethodParam read GetMethodParam;
    property ParamsData: TTypeData read FParamsData write FParamsData;
  end;

  TgdMethodList = class(TList)
  private
    function GetMethod(Index: Integer): TgdMethod;

  protected
    function MethodExists(const AMethod: TgdMethod): Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    {���������� ����� �� �����}
    function MethodByName(const AName: String) : TgdMethod;
    {���������� ������}
    function AddMethod(const AMethod: TgdMethod): Integer;
    {����. ����� � ������}
    function Last: TgdMethod;
    {�������� ������}
    procedure Delete(Index: Integer);
    {������� ������}
    procedure Clear; override;
    {����������}
    procedure Assign(ASource: TgdMethodList);

    property Methods[Index: Integer]: TgdMethod read GetMethod {write SetMethod}; default;
  end;

  TgdClassMethods = class
  private
    FgdcClass: TComponentClass;
    FgdMethods: TgdMethodList;

  public
    constructor Create; overload; {! ����� !}
    constructor Create(AClass: TComponentClass); overload;
    destructor Destroy; override;

    function  GetgdClassMethodsParent: TgdClassMethods;
    procedure Assign(ASource: TgdClassMethods);

    property gdcClass: TComponentClass read FgdcClass write FgdcClass;
    property gdMethods: TgdMethodList read FgdMethods;
  end;

  TgdClassEntry = class;

  TgdFieldDef = class(TObject)
  private
    FRequired: Boolean;
    FSize: Integer;
    FOrigin: String;
    FName: String;
    FDataType: TFieldType;
    FInheritedField: Boolean;

    function GetNullable: String;
    function GetFieldType: String;

  public
    procedure InitFieldDef(F: TField);
    procedure ODataBuild(SL: TStringList); virtual;

    property Name: String read FName write FName;
    property Origin: String read FOrigin write FOrigin;
    property DataType: TFieldType read FDataType write FDataType;
    property Required: Boolean read FRequired write FRequired;
    property Size: Integer read FSize write FSize;
    property InheritedField: Boolean read FInheritedField write FInheritedField;
  end;

  TgdRefFieldDef = class(TgdFieldDef)
  private
    FRefClassName: String;
    FRefSubType: String;

  public
    procedure ODataBuild(SL: TStringList); override;

    property RefClassName: String read FRefClassName write FRefClassName;
    property RefSubType: String read FRefSubType write FRefSubType;
  end;

  TgdFieldDefs = class(TObjectList)
  public
    function IndexOf(const AName: String): Integer;
  end;

  TgdClassEntryCallback = function(ACE: TgdClassEntry; AData1: Pointer;
    AData2: Pointer): Boolean of object;
  TgdClassEntryCallback2 = function(ACE: TgdClassEntry; AData1: Pointer;
    AData2: Pointer): Boolean;

  TgdClassEntry = class(TObject)
  private
    FParent: TgdClassEntry;
    FClass: TClass;
    FSubType: TgdcSubType;
    FClassMethods: TgdClassMethods;
    FCaption: String;
    FChildren: TObjectList;
    FHidden: Boolean;
    FVirtualSubType: Boolean;
    FGroupID: TID;

    function GetChildren(Index: Integer): TgdClassEntry;
    function GetCount: Integer;
    function ListCallback(ACE: TgdClassEntry; AData1: Pointer;
      AData2: Pointer): Boolean;
    function GetCaption: String;

    function GetGroupID: TID; virtual;

  protected
    function Traverse(ACallback: TgdClassEntryCallback; AData1: Pointer; AData2: Pointer;
      const AnIncludeRoot: Boolean = True;
      const AnOnlyDirect: Boolean = False): Boolean; overload;
    function Traverse(ACallback2: TgdClassEntryCallback2; AData1: Pointer; AData2: Pointer;
      const AnIncludeRoot: Boolean = True;
      const AnOnlyDirect: Boolean = False): Boolean; overload;
    function Traverse(AList: TObjectList;
      const AnIncludeRoot: Boolean = True;
      const AnOnlyDirect: Boolean = False): Boolean; overload;
    function GetSubTypeList(ASubTypeList: TStrings; const AnOnlyDirect: Boolean;
      const AVerbose: Boolean): Boolean;

  public
    constructor Create(AParent: TgdClassEntry; const AClass: TClass;
      const ASubType: TgdcSubType = '';
      const ACaption: String = ''); overload; virtual;

    destructor Destroy; override;

    procedure Assign(CE: TgdClassEntry); virtual;
    function Compare(const AClass: TClass; const ASubType: TgdcSubType = ''): Integer; overload;
    function Compare(const AClassName: AnsiString; const ASubType: TgdcSubType = ''): Integer; overload;
    procedure AddChild(AChild: TgdClassEntry);
    procedure RemoveChild(AChild: TgdClassEntry);
    function FindChild(const AClassName: AnsiString): TgdClassEntry;
    function InheritsFromCE(ACE: TgdClassEntry): Boolean;
    function GetRootSubType: TgdClassEntry;
    class function CheckSubType(const ASubType: TgdcSubType): Boolean; virtual;

    property Parent: TgdClassEntry read FParent;
    property TheClass: TClass read FClass;
    property SubType: TgdcSubType read FSubType;
    property Caption: String read GetCaption write FCaption;
    property Count: Integer read GetCount;
    property Children[Index: Integer]: TgdClassEntry read GetChildren;
    property ClassMethods: TgdClassMethods read FClassMethods;
    property Hidden: Boolean read FHidden write FHidden;
    property VirtualSubType: Boolean read FVirtualSubType write FVirtualSubType;
    property GroupID: TID read GetGroupID write FGroupID;
  end;
  CgdClassEntry = class of TgdClassEntry;

  TgdBaseEntry = class(TgdClassEntry)
  private
    FDistinctRelation: String;
    FgdFieldDefs: TgdFieldDefs;

    function GetGdcClass: CgdcBase;
    function GetDistinctRelation: String; virtual;
    procedure SetDistinctRelation(const Value: String);
    function GetGroupID: TID; override;

  public
    constructor Create(AParent: TgdClassEntry; const AClass: TClass;
      const ASubType: TgdcSubType = '';
      const ACaption: String = ''); overload; override;
    destructor Destroy; override;

    procedure LoadFieldDefs;
    procedure ODataBuild(SL, SL2: TStringList);
    function IndexOfFieldDef(const AName: String): Integer;
    function GetEntitySetName: String;
    function GetEntitySetUrl: String;

    property gdcClass: CgdcBase read GetGdcClass;
    property DistinctRelation: String read GetDistinctRelation write SetDistinctRelation;
  end;

  TgdAttrUserDefinedEntry = class(TgdBaseEntry)
  public
    class function CheckSubType(const ASubType: TgdcSubType): Boolean; override;
  end;

  TgdDocumentEntry = class(TgdBaseEntry)
  private
    FTypeID: TID;
    FIsCommon: Boolean;
    FHeaderFunctionKey: TID;
    FLineFunctionKey: TID;
    FDescription: String;
    FOptions: String;
    FIsCheckNumber: TIsCheckNumber;
    FHeaderRelKey: TID;
    FLineRelKey: TID;
    FBranchKey: TID;
    FEditionDate: TDateTime;
    FInvalid: Boolean;

    function GetDistinctRelation: String; override;
    procedure SetHeaderRelKey(const Value: TID);
    procedure SetLineRelKey(const Value: TID);
    function GetHeaderRelName: String;
    function GetLineRelName: String;
    procedure SetInvalid(const Value: Boolean);

  protected
    procedure LoadDEOption(qOpt: TIBSQL); virtual;

  public
    class function CheckSubType(const ASubType: TgdcSubType): Boolean; override;
    procedure Assign(CE: TgdClassEntry); override;
    function FindParentByDocumentTypeKey(const ADocumentTypeKey: TID;
      const APart: TgdcDocumentClassPart): TgdDocumentEntry;
    procedure ParseOptions; virtual;
    procedure ConvertOptions; virtual;
    procedure LoadDE(q, qOpt: TIBSQL; const AnAllowParseOptions: Boolean = False); overload; virtual;
    procedure LoadDE(Tr: TIBTransaction); overload; virtual;

    property HeaderFunctionKey: TID read FHeaderFunctionKey write FHeaderFunctionKey;
    property LineFunctionKey: TID read FLineFunctionKey write FLineFunctionKey;
    property HeaderRelKey: TID read FHeaderRelKey write SetHeaderRelKey;
    property LineRelKey: TID read FLineRelKey write SetLineRelKey;
    property HeaderRelName: String read GetHeaderRelName;
    property LineRelName: String read GetLineRelName;
    property IsCommon: Boolean read FIsCommon write FIsCommon;
    property Description: String read FDescription write FDescription;
    property IsCheckNumber: TIsCheckNumber read FIsCheckNumber write FIsCheckNumber;
    property Options: String read FOptions write FOptions;
    property TypeID: TID read FTypeID write FTypeID;
    property BranchKey: TID read FBranchKey write FBranchKey;
    property EditionDate: TDateTime read FEditionDate write FEditionDate;
    property Invalid: Boolean read FInvalid write SetInvalid;
  end;

  TgdInvDocumentEntryFlag = (
    efControlRemains,
    efLiveTimeRemains,
    efMinusRemains,
    efDelayedDocument,
    efUseCachedUpdates,
    efIsChangeCardValue,
    efIsAppendCardValue,
    efIsUseCompanyKey,
    efSaveRestWindowOption,
    efEndMonthRemains,
    efWithoutSearchRemains,
    efSrcGoodRef,
    efSrcRemainsRef,
    efSrcMacro,
    efDirFIFO,
    efDirLIFO,
    efDirDefault
  );

  TgdInvDocumentEntryFlagProp = (
    fpValue,
    fpIsSet
  );

  TgdInvDocumentEntryFeature = (
    ftSource,
    ftDest,
    ftMinus,
    ftRestrRemainsBy
  );

  TgdInvDocumentEntryMovement = (
    emDebit,
    emCredit
  );

  TgdInvDocumentEntry = class(TgdDocumentEntry)
  private
    FMovement: array[TgdInvDocumentEntryMovement] of TgdcInvMovementContactOption;
    FFeatures: array[TgdInvDocumentEntryFeature] of TStringList;
    FFlags: array[TgdInvDocumentEntryFlag, TgdInvDocumentEntryFlagProp] of Boolean;

    function GetMovementContactOption(
      const AMovement: TgdInvDocumentEntryMovement): TgdcInvMovementContactOption;
  protected
    procedure LoadDEOption(qOpt: TIBSQL); override;

  public
    constructor Create(AParent: TgdClassEntry; const AClass: TClass;
      const ASubType: TgdcSubType = '';
      const ACaption: String = ''); overload; override;
    destructor Destroy; override;

    procedure Assign(CE: TgdClassEntry); override;
    procedure ParseOptions; override;
    procedure ConvertOptions; override;
    procedure LoadDE(Tr: TIBTransaction); overload; override;

    function GetFlag(const AFlag: TgdInvDocumentEntryFlag): Boolean;
    function GetFeaturesCount(const AFeature: TgdInvDocumentEntryFeature): Integer;
    function GetFeature(const AFeature: TgdInvDocumentEntryFeature; const AnIndex: Integer): String;
    function IsExistsFeature(const AFeature: TgdInvDocumentEntryFeature; const Feature: String): Boolean;
    function GetFeaturesText(const AFeature: TgdInvDocumentEntryFeature): String;


    function GetDirection: TgdcInvMovementDirection;
    function GetSources: TgdcInvReferenceSources;

    function GetMCORelationName(const AMovement: TgdInvDocumentEntryMovement): String;
    function GetMCOSourceFieldName(const AMovement: TgdInvDocumentEntryMovement): String;
    function GetMCOSubRelationName(const AMovement: TgdInvDocumentEntryMovement): String;
    function GetMCOSubSourceFieldName(const AMovement: TgdInvDocumentEntryMovement): String;
    function GetMCOContactType(const AMovement: TgdInvDocumentEntryMovement): TgdcInvMovementContactType;
    procedure GetMCOPredefined(const AMovement: TgdInvDocumentEntryMovement; var V: TgdcMCOPredefined);
    function GetMovement(
      const AMovement: TgdInvDocumentEntryMovement): TgdcInvMovementContactOption;

    procedure GetMCOSubPredefined(const AMovement: TgdInvDocumentEntryMovement; var V: TgdcMCOPredefined);
  end;

  TgdInvPriceDocumentEntry = class(TgdDocumentEntry)
  private
    FHeaderFields: TgdcInvPriceFields;
    FLineFields: TgdcInvPriceFields;

  protected
    procedure LoadDEOption(qOpt: TIBSQL); override;

  public
    procedure Assign(CE: TgdClassEntry); override;
    procedure ParseOptions; override;
    procedure ConvertOptions; override;
    procedure LoadDE(Tr: TIBTransaction); overload; override;

    property HeaderFields: TgdcInvPriceFields read FHeaderFields;
    property LineFields: TgdcInvPriceFields read FLineFields;
  end;

  TgdStorageEntry = class(TgdBaseEntry)
  public
    class function CheckSubType(const ASubType: TgdcSubType): Boolean; override;
  end;

  TgdFormEntry = class(TgdClassEntry)
  private
    FAbstractBaseForm: Boolean;
    // ����� ��������� ��� ������������ �� ��������� �������� ����
    FShowInFormEditor: Boolean;

    FMacrosGroupID: TID;

    function GetFrmClass: CgdcCreateableForm;
    function GetGroupID: TID; override;
    function GetMacrosGroupID: TID;
    function GetInitialName: String;

  public
    constructor Create(AParent: TgdClassEntry; const AClass: TClass;
      const ASubType: TgdcSubType = '';
      const ACaption: String = ''); overload; override;

    property frmClass: CgdcCreateableForm read GetFrmClass;
    property AbstractBaseForm: Boolean read FAbstractBaseForm write FAbstractBaseForm;
    property ShowInFormEditor: Boolean read FShowInFormEditor write FShowInFormEditor;
    property MacrosGroupID: TID read GetMacrosGroupID write FMacrosGroupID;
    property InitialName: String read GetInitialName;
  end;

  TgdInitClassEntry = class(TObject)
  public
    procedure Init(CE: TgdClassEntry); virtual;
  end;

  TgdClassList = class(TObject)
  private
    FClasses: array of TgdClassEntry;
    FCount: Integer;
    FFindByRelationCache: TStringList;
    FFindDocByRUIDHdrCache, FFindDocByRUIDLineCache: TStringList;
    FFindDocByIDHdrCache, FFindDocByIDLineCache: TgdKeyObjectAssoc;
    FOldOptions: Boolean;

    function _Find(const AClassName: AnsiString; const ASubType: TgdcSubType;
      out Index: Integer): Boolean;
    procedure _Insert(const Index: Integer; ACE: TgdClassEntry);
    procedure _Grow;
    procedure _Compact;
    function _Create(APrnt: TgdClassEntry; AnEntryClass: CgdClassEntry;
      AClass: TClass; const ASubType: TgdcSubType; const ACaption: String): TgdClassEntry;
    function _FindDoc(ACE: TgdClassEntry; AData1: Pointer;
      AData2: Pointer): Boolean;
    function _FindDocByRUID(ACE: TgdClassEntry; AData1: Pointer;
      AData2: Pointer): Boolean;
    function _CreateFormSubTypes(ACE: TgdClassEntry; Data1,
      Data2: Pointer): Boolean;

  protected
    procedure FreeNotify(CE: TgdClassEntry);

  public
    constructor Create;
    destructor Destroy; override;

    function Add(const AClass: TClass; const ASubType: TgdcSubType;
      const AParentSubType: TgdcSubType; const AnEntryClass: CgdClassEntry;
      const ACaption: String;
      const AnInitProc: TgdInitClassEntry = nil): TgdClassEntry; overload;
    function Add(const AClassName: AnsiString; const ASubType: TgdcSubType;
      const AParentSubType: TgdcSubType; const AnEntryClass: CgdClassEntry;
      const ACaption: String;
      const AnInitProc: TgdInitClassEntry = nil): TgdClassEntry; overload;

    function Find(const AClass: TClass; const ASubType: TgdcSubType = ''): TgdClassEntry; overload;
    function Find(const AClassName: AnsiString; const ASubType: TgdcSubType = ''): TgdClassEntry; overload;
    function Find(const AFullClassName: TgdcFullClassName): TgdClassEntry; overload;
    function Find(AnObj: TgdcBase): TgdBaseEntry; overload;
    function FindDocByTypeID(const ADocTypeID: TID; const APart: TgdcDocumentClassPart;
      const AnUpdate: Boolean = False): TgdDocumentEntry; overload;
    function FindDocByRUID(const ARUID: String; const APart: TgdcDocumentClassPart;
      const AnUpdate: Boolean = False): TgdDocumentEntry;
    function FindByRelation(const ARelationName: String): TgdBaseEntry;
    procedure FindByRelation2(const ARelationName: String; OL: TObjectList);

    function Get(const AClass: CgdClassEntry; const AClassName: AnsiString; const ASubType: TgdcSubType = ''): TgdClassEntry;

    function Traverse(const AClass: TClass; const ASubType: TgdcSubType;
      ACallback: TgdClassEntryCallback; AData1: Pointer; AData2: Pointer;
      const AnIncludeRoot: Boolean = True;
      const AnOnlyDirect: Boolean = False): Boolean; overload;

    function Traverse(const AClass: TClass; const ASubType: TgdcSubType;
      ACallback: TgdClassEntryCallback2; AData1: Pointer; AData2: Pointer;
      const AnIncludeRoot: Boolean = True;
      const AnOnlyDirect: Boolean = False): Boolean; overload;

    function GetSubTypeList(AClass: TClass; const ASubType: TgdcSubType;
      ASubTypeList: TStrings; const AnOnlyDirect: Boolean; const AVerbose: Boolean): Boolean;

    procedure Remove(const AClass: TClass; const ASubType: TgdcSubType = ''); overload;
    procedure Remove(const AClassName: String; const ASubType: TgdcSubType = ''); overload;
    procedure RemoveAllSubTypes;
    procedure RemoveSubType(const ASubType: TgdcSubType);

    procedure AddClassMethods(AClassMethods: TgdClassMethods); overload;
    procedure AddClassMethods(AClass: TComponentClass;
      AMethods: array of TgdMethod); overload;

    procedure LoadUserDefinedClasses;
    function LoadRelation(Prnt: TgdClassEntry; R: TatRelation; ACEAttrUserDefined,
      ACEAttrUserDefinedTree, ACEAttrUserDefinedLBRBTree: TgdClassEntry): TgdClassEntry; overload;
    function LoadRelation(const ARelationName: String): TgdClassEntry; overload;
    procedure CreateFormSubTypes;

    property Count: Integer read FCount;
    property OldOptions: Boolean read FOldOptions write FOldOptions;
  end;

var
  // ��� �������� ������ ������ ������������ ���� � ���� ������
  // ��� �������� �������. ������ ������ ��������� ���, �����
  // ��� ������� �� ������� �����, ��� �������� ���������� ������
  // �� ������ ��� ������ ������� ��� ��� � ������ ����������
  gdcObjectList: TObjectList;

  // ������ �������. ������ ����� ������ ���� ��������������� �����,
  // ����� �� ������ ����������, ��������, ������ ��������� ��������
  // ��� ������ ������� (������, ��� �� ������ ���������� ����� �������
  // �� ��������� ����� ������� ������� (����, � ���, ListTable)

  // ��� GDC-������� � ����
  _gdClassList: TgdClassList;

function gdClassList: TgdClassList;

{����������� ������ � ������ TgdcClassList}
function RegisterGdcClass(const AClass: CgdcBase; const ACaption: String = ''): TgdBaseEntry;
procedure UnregisterGdcClass(AClass: CgdcBase);

// ��������� ����� � ������ �������
{����������� ������ � ������ TgdcClassList}
function RegisterFrmClass(AClass: CgdcCreateableForm; const ACaption: String = ''): TgdFormEntry;
procedure UnRegisterFrmClass(AClass: CgdcCreateableForm);

{����������� ������ ��� ������.}
procedure RegisterFrmClassMethod(const AnClass: TComponentClass; AnMethod: String;
  InputParams: String; OutputParam: String = '');
procedure RegisterGDCClassMethod(const AnClass: TComponentClass; AnMethod: String;
  InputParams: String; OutputParam: String = '');
//�������� ������ $ �� _
function Replace(const Str: string): string;

function SubTypeToComponentName(const ASubType: TgdcSubType): String;
function ComponentNameToSubType(const Str: String): TgdcSubType;

{$IFDEF DEBUG}
var
  glbParamCount, glbMethodCount, glbMethodListCount,
  glbClassMethodCount, glbClassListCount: Integer;
{$ENDIF}

const
   InvDocumentFeaturesNames: array[TgdInvDocumentEntryFeature] of String = (
     'SF',
     'DF',
     'MF',
     'RF'
   );

  InvDocumentEntryFlagFirst = efControlRemains;
  InvDocumentEntryFlagLast = efDirDefault;
  InvDocumentEntryFlagNames: array[InvDocumentEntryFlagFirst..InvDocumentEntryFlagLast] of String = (
    'ControlRemains',
    'LiveTimeRemains',
    'MinusRemains',
    'DelayedDocument',
    'UseCachedUpdates',
    'ChangeCardValue',
    'AppendCardValue',
    'UseCompanyKey',
    'SaveRestWindowOption',
    'EndMonthRemains',
    'WithoutSearchRemains',
    'SrcGoodRef',
    'SrcRemainsRef',
    'SrcMacro',
    'Dir.FIFO',
    'Dir.LIFO',
    'Dir.Default'
   );

implementation

uses
  SysUtils, gs_Exception, gd_security, gsStorage, Storages, gdcClasses,
  gd_directories_const, jclStrings, Windows, gd_CmdLineParams_unit,
  gdcInvDocument_unit, gdcInvPriceList_unit, gd_strings, gd_common_functions,
  at_frmSQLProcess
  {$IFDEF DEBUG}
  , gd_DebugLog
  {$ENDIF}
  ;

type
  TPrefixType = array [0..3] of Char;
  TClassTypeList = (GDC, FRM);
  TAuxRec = record
    ID: TID;
    Part: TgdcDocumentClassPart;
    RUID: String;
    CE: TgdClassEntry;
  end;
  PAuxRec = ^TAuxRec;

const
  PARAM_PREFIX         : TPrefixType = '^PAR';
  METHOD_PREFIX        : TPrefixType = '^MTD';
  METHOD_LIST_PREFIX   : TPrefixType = '^M_L';
  CLASS_METHODS_PREFIX : TPrefixType = '^C_M';
  CLASS_LIST_PREFIX    : TPrefixType = '^C_L';

{$IFDEF METHODSCHECK}
var
  dbgMethodList: TStrings;

const
  mcString = '%s;%s';
{$ENDIF}

//�������� ������ $ �� _
function Replace(const Str: string): string;
var
  I: Integer;
begin
  Result := Str;
  for I := 1 to Length(Str) do
  begin
    if Result[I] = '$' then
      Result[I] := '_';
  end;
end;

function SubTypeToComponentName(const ASubType: TgdcSubType): String;
begin
  Result := ASubType;
  if StrIPos('USR$', Result) = 1 then
    Result[4] := '_';
end;

function ComponentNameToSubType(const Str: string): TgdcSubType;
begin
  Result := Str;
  if StrIPos('USR_', Result) = 1 then
    Result[4] := '$';
end;

function gdClassList: TgdClassList;
begin
  if _gdClassList = nil then
    _gdClassList := TgdClassList.Create;
  Result := _gdClassList;
end;

function RegisterGdcClass(const AClass: CgdcBase; const ACaption: String = ''): TgdBaseEntry;
begin
  Classes.RegisterClass(AClass);
  if AClass.InheritsFrom(TgdcDocument) then
  begin
    if AClass.InheritsFrom(TgdcInvDocument) then
      Result := gdClassList.Add(AClass, '', '', TgdInvDocumentEntry, ACaption) as TgdDocumentEntry
    else if AClass.InheritsFrom(TgdcInvPriceList) then
      Result := gdClassList.Add(AClass, '', '', TgdInvPriceDocumentEntry, ACaption) as TgdDocumentEntry
    else
      Result := gdClassList.Add(AClass, '', '', TgdDocumentEntry, ACaption) as TgdDocumentEntry;
    TgdDocumentEntry(Result).TypeID := CgdcDocument(AClass).ClassDocumentTypeKey;
  end else
    Result := gdClassList.Add(AClass, '', '', TgdBaseEntry, ACaption) as TgdBaseEntry;
end;

procedure UnregisterGdcClass(AClass: CgdcBase);
begin
  if _gdClassList <> nil then
    _gdClassList.Remove(AClass);
  Classes.UnRegisterClass(AClass);
end;

function RegisterFrmClass(AClass: CgdcCreateableForm; const ACaption: String = ''): TgdFormEntry;
begin
  Classes.RegisterClass(AClass);
  Result := gdClassList.Add(AClass, '', '', TgdFormEntry, ACaption) as TgdFormEntry;
end;

procedure UnRegisterFrmClass(AClass: CgdcCreateableForm);
begin
  if _gdClassList <> nil then
    _gdClassList.Remove(AClass);
  Classes.UnRegisterClass(AClass);
end;

procedure CustomRegisterClassMethod(ATypeList: TClassTypeList; const AnClass: TComponentClass; AnMethod: String;
  InputParams: String; OutputParam: String = '');
var
  Method: TgdMethod;
  CursorPos: Integer;
  Str: String;
  L: Integer;
const
  Letters = '1234567890_qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';

  procedure TrimSpace;
  begin
    while (CursorPos > 0) and (CursorPos < L) and (Str[CursorPos] = ' ') do
    begin
      Inc(CursorPos);
    end;
  end;

  function GetCurrentWord: String;
  var
    BeginPos, EndPos: Integer;
  begin
    BeginPos := CursorPos;
    EndPos := CursorPos;
    while BeginPos > 1 do
    begin
      if Str[BeginPos - 1] in ['0'..'9','a'..'z', 'A'..'Z', '_'] then
        Dec(BeginPos)
      else
        Break;
    end;
    while EndPos + 1 <= L do
    begin
      if Str[EndPos + 1] in ['0'..'9','a'..'z', 'A'..'Z', '_'] then
        Inc(EndPos)
      else
        Break;
    end;

    if EndPos >= BeginPos then
      Result := System.Copy(Str, BeginPos, EndPos - BeginPos + 1)
    else
      Result := '';
    CursorPos := EndPos + 1;
  end;

  procedure WorkParam;
  var
    ParamType: String;
    ParamName: String;
    ParamFlag: String;
    PF: TParamFlag;
  begin
    TrimSpace;

    ParamName := '';
    ParamFlag := GetCurrentWord;
    // ���� ����� ���, �� � ParamFlag ����� ���
    if UpperCase(ParamFlag) = 'VAR' then
      PF := pfVar
    else if UpperCase(ParamFlag) = 'CONST' then
      PF := pfConst
    else  if UpperCase(ParamFlag) = 'ARRAY' then
      PF := pfArray
    else if UpperCase(ParamFlag) = 'ADDRESS' then
      PF := pfAddress
    else if UpperCase(ParamFlag) = 'REFERENCE' then
      PF := pfReference
    else if UpperCase(ParamFlag) = 'OUT' then
      PF := pfOut
    else
      begin
        ParamName := ParamFlag;
        ParamFlag := 'REFERENCE';
        PF := pfReference;
      end;

    if Length(ParamName) = 0 then
    begin
      TrimSpace;
      ParamName := GetCurrentWord;
    end;
    TrimSpace;

    if Str[CursorPos] = ':' then
      Inc(CursorPos)
    else
      raise Exception.Create('gd_ClassList: ������ �������. �������:' + IntToStr(CursorPos) + #13#10 +
        '����� ���������');
    TrimSpace;

    ParamType := GetCurrentWord;
    TrimSpace;

    if CursorPos <= L then
    begin
      if Str[CursorPos] = ';' then
      begin
        Inc(CursorPos);
        TrimSpace;
      end else
        if not (CursorPos > L) then
          raise Exception.Create('gd_ClassList: ������ �������. �������:' + IntToStr(CursorPos) + #13#10 +
            '����� ����� � �������');
    end;

    if Assigned(Method) then
      Method.AddParam(ParamName, ParamType, PF);
  end;

begin
  Str:= Trim(InputParams);
  CursorPos := 1;
  L := Length(Str);

  if OutputParam = '' then
    Method := TgdMethod.Create(AnMethod, mkProcedure)
  else
    Method := TgdMethod.Create(AnMethod, mkFunction, OutputParam);
  try
    while CursorPos < Length(Str) do
      WorkParam;
      gdClassList.AddClassMethods(AnClass, Method);
  finally
    Method.Free;
  end;
end;

procedure RegisterGDCClassMethod(const AnClass: TComponentClass; AnMethod: String;
  InputParams: String; OutputParam: String = '');
begin
  CustomRegisterClassMethod(GDC, AnClass, AnMethod, InputParams, OutputParam);
end;

procedure RegisterFrmClassMethod(const AnClass: TComponentClass; AnMethod: String;
  InputParams: String; OutputParam: String = '');
begin
  CustomRegisterClassMethod(FRM, AnClass, AnMethod, InputParams, OutputParam);
end;

{TgdMethodParam}
constructor TgdMethodParam.Create;
begin
  inherited;

  {$IFDEF DEBUG}
  Inc(glbParamCount);
  {$ENDIF}
end;


destructor TgdMethodParam.Destroy;
begin
  inherited;

  {$IFDEF DEBUG}
  Dec(glbParamCount);
  {$ENDIF}
end;

function TgdMethodParam.EqualsByName(const AParamName: String): Boolean;
begin
  Result := AnsiSameText(FParamName, AParamName);
end;

function TgdMethodParam.EqualsFull(const AParam: TgdMethodParam): Boolean;
begin
  Result := (FParamName = AParam.FParamName) and
   (FParamClass = AParam.FParamClass) and
   (FParamTypeName = AParam.FParamTypeName) and
   (FParamName = AParam.FParamName) and
   (FParamFlag = AParam.FParamFlag);
end;

procedure TgdMethodParam.Assign(ASource: TgdMethodParam);
begin
  FParamName := ASource.ParamName;
  FParamClass := ASource.ParamClass;
  FParamTypeName := ASource.ParamTypeName;
  FParamFlag := ASource.FParamFlag;
end;

{TgdMethod}
constructor TgdMethod.Create(AName: String; AKind: TMethodKind;
  AFuncResType: String = '');
begin
  inherited Create;

  if (AKind in [mkFunction, mkClassFunction, mkSafeFunction]) and
    (AFuncResType = '') then
    raise Exception.Create(GetGsException(Self, 'For function you must specify result type !'));

  FName := AName;
  FParams := TList.Create;
  FParamsData.MethodKind := AKind;
  FParamsData.ParamCount := 0;
  FFuncResType := AFuncResType;

  StoreResultInTD(0);

  //only for testing
{$IFDEF DEBUG}
  Inc(glbMethodCount);
{$ENDIF}
end;

procedure TgdMethod.StoreResultInTD(APosition: Integer);
begin
  if IsMethodFunction then
    WriteStrToTD(FParamsData, APosition, FFuncResType);
end;

function TgdMethod.AddParamToList(const AParam: TgdMethodParam): Integer;
begin
  Result := FParams.Add(TgdMethodParam.Create);
  if Assigned(AParam) then
    Params[Result].Assign(AParam);
end;

function TgdMethod.AddParamToList(AParamName, ATypeName: String;
  AParamFlag: TParamFlag): Integer;
begin
  Result := AddParamToList(nil);
  Params[Result].FParamName := AParamName;
  Params[Result].FParamClass := nil;
  Params[Result].FParamTypeName := ATypeName;
  Params[Result].FParamFlag := AParamFlag;
end;

function TgdMethod.AddParam(AParamName, ATypeName: String;
  AParamFlag: TParamFlag): Integer;
begin
  if ParamByNameExists(AParamName) then
    raise Exception.Create(GetGsException(Self, Format('Parameter %s already found for this method !', [AParamName])));

  Result := AddParamToList(AParamName, ATypeName, AParamFlag);
  AddParamToParamsData(AParamName, ATypeName, AParamFlag);
end;

procedure TgdMethod.AddParamToParamsData(AParamName, AParamType: String;
  AParamFlag: TParamFlag);
var
  I, Pos: Integer;
begin
  // Skips existing parameters
  Pos := 0;
  for I := 0 to FParamsData.ParamCount - 1 do
  begin
    Inc(Pos); //Skip flag
    ReadStrFromTD(FParamsData, Pos);
    ReadStrFromTD(FParamsData, Pos);
  end;
  // Writes parameter info erasing func res. type
  FParamsData.ParamList[Pos] := Chr(Ord(AParamFlag));
  Inc(Pos);
  WriteStrToTD(FParamsData, Pos, AParamName);
  WriteStrToTD(FParamsData, Pos, AParamType);
  Inc(FParamsData.ParamCount);
  // Writes func res. type
  StoreResultInTD(Pos);
end;

function TgdMethod.IsMethodFunction: Boolean;
begin
  Result := FParamsData.MethodKind in [mkFunction, mkClassFunction, mkSafeFunction];
end;

function TgdMethod.ParamByNameExists(const AParamName: String): Boolean;
var I: Integer;
begin
  Result := False;
  for I := 0 to FParams.Count - 1 do
    if Params[I].EqualsByName(AParamName) then
    begin
      Result := True;
      Break
    end;
end;

function TgdMethod.ParamExists(const AParam: TgdMethodParam): Boolean;
var I: Integer;
begin
  Result := False;
  for I := 0 to FParams.Count - 1 do
    if Params[I].EqualsFull(AParam) then
    begin
      Result := True;
      Break
    end;
end;

function TgdMethod.Equals(const AMethod: TgdMethod): Boolean;
var
  I: Integer;
begin
  Result := True;

  if (Name <> AMethod.Name) or
   (ParamCount <> AMethod.ParamCount) then
  begin
    Result := False;
    Exit
  end;

  for I := 0 to ParamCount - 1 do
    if not ParamExists(Params[I]) then
    begin
      Result := False;
      Exit
    end;
end;

procedure TgdMethod.CustomDelete(Index: Integer);
begin
  Params[Index].Free;
  FParams.Delete(Index);
end;

procedure TgdMethod.Clear;
begin
  FreeFParams;
  FName := '';
  FFuncResType := '';
  FParamsData.ParamCount := 0;
  while ParamCount > 0 do
    CustomDelete(0);
end;

procedure TgdMethod.Assign(ASource: TgdMethod);
var
  I: Integer;
begin
  Clear;
  FName := ASource.Name;
  FFuncResType := ASource.FFuncResType;
  FParamsData := ASource.ParamsData;
  for I := 0 to ASource.ParamCount - 1 do
    AddParamToList(ASource.Params[I]);
end;

function TgdMethod.GetParamCount: Integer;
begin
  Result := FParams.Count;
end;

destructor TgdMethod.Destroy;
begin
  Clear;
  FreeAndNil(FParams);
  inherited Destroy;

  {$IFDEF DEBUG}
  Dec(glbMethodCount);
  {$ENDIF}
end;

function TgdMethod.GetMethodParam(Index: Integer): TgdMethodParam;
begin
  Assert((Index >= 0) and (Index < ParamCount), 'Index out of range');
  Result := TgdMethodParam(FParams[Index]);
end;

function TgdMethod.ReadStrFromTD(ATD: TTypeData; var APosition: Integer): String;
var
  CharCount:Byte;
begin
  Result := '';
  CharCount := Ord(ATD.ParamList[APosition]);
  Result := Copy(ShortString((@ATD.ParamList[APosition])^), 1, CharCount);
  Inc(APosition, CharCount + 1);
end;

procedure TgdMethod.WriteStrToTD(var ATD: TTypeData; var APosition: Integer;
  const S: String);
begin
  ShortString((@ATD.ParamList[APosition])^) := ShortString(S);
  Inc(APosition, Length(S) + 1);
end;

{TgdMethodList}
constructor TgdMethodList.Create;
begin
  inherited Create;

  //test
{$IFDEF DEBUG}
  Inc(glbMethodListCount);
{$ENDIF}
end;

destructor TgdMethodList.Destroy;
begin
  Clear;

  inherited Destroy;
  //test
{$IFDEF DEBUG}
  Dec(glbMethodListCount);
{$ENDIF}
end;

function TgdMethodList.GetMethod(Index: Integer): TgdMethod;
begin
  Assert((Index >= 0) and (Index < Count), 'Index out of range');
  Result := TgdMethod(inherited Items[Index]);
end;

function TgdMethodList.MethodExists(const AMethod: TgdMethod): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
    if Methods[I].Equals(AMethod) then
    begin
      Result := True;
      Exit;
    end;
end;

function TgdMethodList.MethodByName(const AName: String) : TgdMethod;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if AnsiSameText(Methods[I].Name, AName) then
    begin
      Result := Methods[I];
      Break;
    end;
end;

function TgdMethodList.AddMethod(const AMethod: TgdMethod): Integer;
begin
  if AMethod.Name = '' then
    raise Exception.Create(GetGsException(Self, 'Method must have a name'));
  if MethodExists(AMethod) then
    raise Exception.Create(GetGsException(Self, 'Method ' + AMethod.Name + ' already found in list'));

  Result := Add(TgdMethod.Create('', mkProcedure{�� ���-��}, ''));
  if Assigned(AMethod) then
    Last.Assign(AMethod);
end;

function TgdMethodList.Last: TgdMethod;
begin
  Result := TgdMethod(inherited Last);
end;

procedure TgdMethodList.Delete(Index: Integer);
begin
  Methods[Index].Free;

  inherited Delete(Index);
end;

procedure TgdMethodList.Clear;
begin
  while Count > 0 do
    Delete(0);

  inherited Clear;
end;

procedure TgdMethodList.Assign(ASource: TgdMethodList);
var
  I: Integer;
begin
  Clear;
  for I := 0 to ASource.Count - 1 do
    AddMethod(ASource.Methods[I]);
end;

{TgdClassMethods}

constructor TgdClassMethods.Create;
begin
  inherited Create;

  FgdcClass := nil;
  FgdMethods := TgdMethodList.Create;

  // for testing purpose
{$IFDEF DEBUG}
  Inc(glbClassMethodCount);
{$ENDIF}
end;

constructor TgdClassMethods.Create(AClass: TComponentClass);
begin
  Create;
  FgdcClass := AClass;
end;

procedure TgdClassMethods.Assign(ASource: TgdClassMethods);
begin
  gdcClass := ASource.gdcClass;
  gdMethods.Assign(ASource.gdMethods);
end;

destructor TgdClassMethods.Destroy;
begin
  FgdMethods.Free;

  inherited;

  // for testing purpose
{$IFDEF DEBUG}
  Dec(glbClassMethodCount);
{$ENDIF}
end;

procedure TgdMethod.FreeFParams;
var
  i: Integer;
begin
  for i := 0 to FParams.Count - 1 do
    TgdMethodParam(FParams[i]).Free;
  FParams.Clear;
end;

function TgdMethodParam.GetIsParamClass: Boolean;
begin
  Result := FParamClass <> nil;
end;

procedure TgdMethodParam.SetParamName(const Value: String);
begin
  FParamName := Value;
end;

{TStackStrings}

function TStackStrings.Add(const FullClassName: TgdcFullClassName): Integer;
begin
  if FStackString = nil then
    FStackString := TStringList.Create;

  if Length(Trim(FullClassName.SubType)) = 0 then
    Result := FStackString.Add(FullClassName.gdClassName)
  else
    Result := FStackString.Add(SubtypeFlag + FullClassName.gdClassName +
      SubtypeDetach + FullClassName.SubType);
end;

function TStackStrings.AddObject(const FullClassName: TgdcFullClassName;
  AObject: TObject): Integer;
begin
  Result := Add(FullClassName);
  FStackString.Objects[Result] := AObject;
end;

procedure TStackStrings.Clear;
begin
  FreeAndNil(FStackString);
end;

destructor TStackStrings.Destroy;
begin
  FStackString.Free;
  inherited;
end;

function TStackStrings.GetFullClassName(
  const Str: string): TgdcFullClassName;
var
  SeparPos: Integer;
begin
  if Str[1] = '*' then
  begin
    SeparPos := Pos('=', Str);
    Result.gdClassName := Copy(Str, 2, SeparPos - 2);
    Result.SubType := Copy(Str, SeparPos + 1, Length(Str));
  end else
    Result.gdClassName := Str;
end;

function TStackStrings.IndexOf(const ClassName: String): Integer;
begin
  if FStackString = nil then
    Result := -1
  else
    Result := FStackString.IndexOf(ClassName);
end;

function TStackStrings.IsEmpty: Boolean;
begin
  Result := (FStackString = nil) or (FStackString.Count = 0);
end;

function TStackStrings.LastClass: TgdcFullClassName;
begin
  if FStackString <> nil then
    Result := GetFullClassName(FStackString[FStackString.Count - 1])
  else begin
    Result.gdClassName := '';
    Result.SubType := '';
  end;
end;

function TStackStrings.LastObject: TObject;
begin
  if FStackString <> nil then
    Result := FStackString.Objects[FStackString.Count - 1]
  else
    Result := nil;
end;

function TgdClassMethods.GetgdClassMethodsParent: TgdClassMethods;
var
  CE: TgdClassEntry;
begin
  Result := nil;

  CE := gdClassList.Find(FgdcClass.ClassParent);

  if (CE <> nil) and (CE.ClassMethods <> nil) then
    Result := CE.ClassMethods
end;

{TgdClassEntry}

procedure TgdClassEntry.AddChild(AChild: TgdClassEntry);
begin
  Assert(AChild <> nil);
  Assert(AChild.Parent = Self);
  if FChildren = nil then
    FChildren := TObjectList.Create(False);
  FChildren.Add(AChild);
end;

function TgdClassEntry.Compare(const AClass: TClass;
  const ASubType: TgdcSubType): Integer;
begin
  Assert(AClass <> nil);
  Result := Compare(AClass.ClassName, ASubType);
end;

constructor TgdClassEntry.Create(AParent: TgdClassEntry; const AClass: TClass;
  const ASubType: TgdcSubType = ''; const ACaption: String = '');
begin
  FParent := AParent;
  FClass := AClass;
  FCaption := ACaption;
  FSubType := ASubType;
  FChildren := nil;
  FClassMethods := TgdClassMethods.Create(TComponentClass(FClass));
  if (FSubType > '') and (not CheckSubType(FSubType)) then
    raise Exception.Create('Invalid subtype string.');
end;

destructor TgdClassEntry.Destroy;
begin
  if _gdClassList <> nil then
    _gdClassList.FreeNotify(Self);  
  FChildren.Free;
  FClassMethods.Free;
  inherited;
end;

function TgdClassEntry.GetCount: Integer;
begin
  if FChildren = nil then
    Result := 0
  else
    Result := FChildren.Count;
end;

constructor TgdBaseEntry.Create(AParent: TgdClassEntry;
  const AClass: TClass; const ASubType: TgdcSubType;
  const ACaption: String);
begin
  if (AClass = nil) or (not AClass.InheritsFrom(TgdcBase)) then
    raise Exception.Create('Invalid class');
  inherited;
end;

function TgdBaseEntry.GetDistinctRelation: String;
begin
  if FDistinctRelation > '' then
    Result := FDistinctRelation
  else
    Result := UpperCase(gdcClass.GetListTable(SubType));
end;

function TgdBaseEntry.GetGdcClass: CgdcBase;
begin
  if FClass <> nil then
    Result := CgdcBase(FClass)
  else
    Result := nil;
end;

constructor TgdFormEntry.Create(AParent: TgdClassEntry;
  const AClass: TClass; const ASubType: TgdcSubType;
  const ACaption: String);
begin
  if (AClass = nil) or (not AClass.InheritsFrom(TgdcCreateableForm)) then
    raise Exception.Create('Invalid class');

  inherited;
end;

function TgdFormEntry.GetFrmClass: CgdcCreateableForm;
begin
  if FClass <> nil then
    Result := CgdcCreateableForm(FClass)
  else
    Result := nil;
end;

function TgdFormEntry.GetGroupID: TID;
var
  q: TIBSQL;
begin
  if FGroupID <= 0 then
  begin
    Assert(gdcBaseManager <> nil);

    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text := 'SELECT reportgroupkey FROM evt_object WHERE UPPER(objectname) = :objectname';

      q.Params[0].AsString := UpperCase(InitialName);

      q.ExecQuery;
      if not q.Eof then
        FGroupID := GetTID(q.FieldByName('reportgroupkey'));
    finally
      q.Free;
    end;
  end;

  Result := FGroupID;
end;

function TgdFormEntry.GetMacrosGroupID: TID;
var
  q: TIBSQL;
  ObjectName: String;
begin
  if FMacrosGroupID <= 0 then
  begin
    Assert(gdcBaseManager <> nil);

    ObjectName := InitialName;

    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
        q.SQL.Text :=
          'SELECT macrosgroupkey FROM evt_object ' +
          'WHERE UPPER(objectname) = :objectname AND parent IS NULL';
        q.Params[0].AsString := AnsiUpperCase(ObjectName);
        q.ExecQuery;
        if q.EOF then
        begin
          q.Close;
          q.SQL.Text :=
            'SELECT macrosgroupkey FROM evt_object ' +
            'WHERE UPPER(objectname) = :objectname';
          q.Params[0].AsString := AnsiUpperCase(ObjectName);
          q.ExecQuery;
        end;

        if not q.EOF then
          FMacrosGroupID := GetTID(q.FieldByName('macrosgroupkey'));
    finally
      q.Free;
    end;
  end;

  Result := FMacrosGroupID;
end;

function TgdFormEntry.GetInitialName: String;
begin
  Result := Copy(frmClass.ClassName, 2, 255) + RemoveProhibitedSymbols(SubType);
end;

function TgdClassEntry.GetChildren(Index: Integer): TgdClassEntry;
begin
  Result := FChildren[Index] as TgdClassEntry;
end;

function TgdClassEntry.GetSubTypeList(ASubTypeList: TStrings;
  const AnOnlyDirect: Boolean; const AVerbose: Boolean): Boolean;
var
  I: Integer;
begin
  Assert(ASubTypeList <> nil);

  Result := False;

  for I := 0 to Count - 1 do
  begin
    if Children[I].SubType > '' then
    begin
      if AVerbose then
        ASubTypeList.Add(Children[I].Caption + '=' + Children[I].SubType)
      else
        ASubTypeList.Add(Children[I].SubType);
      Result := True;

      if not AnOnlyDirect then
        Result := Children[I].GetSubTypeList(ASubTypeList, False, AVerbose) or Result;
    end;
  end;
end;

function TgdClassEntry.Traverse(ACallback: TgdClassEntryCallback;
  AData1: Pointer; AData2: Pointer; const AnIncludeRoot, AnOnlyDirect: Boolean): Boolean;
var
  I: Integer;
begin
  Assert(Assigned(ACallback));

  if AnIncludeRoot then
    Result := ACallback(Self, AData1, AData2)
  else
    Result := True;

  I := 0;
  while Result and (I < Count) do
  begin
    if AnOnlyDirect then
      Result := Result and ACallback(Children[I], AData1, AData2)
    else
      Result := Result and Children[I].Traverse(ACallback, AData1, AData2, True, False);
    Inc(I);
  end;
end;

function TgdClassEntry.Traverse(ACallback2: TgdClassEntryCallback2;
  AData1: Pointer; AData2: Pointer; const AnIncludeRoot, AnOnlyDirect: Boolean): Boolean;
var
  I: Integer;
begin
  Assert(Assigned(ACallback2));

  if AnIncludeRoot then
    Result := ACallback2(Self, AData1, AData2)
  else
    Result := True;

  I := 0;
  while Result and (I < Count) do
  begin
    if AnOnlyDirect then
      Result := Result and ACallback2(Children[I], AData1, AData2)
    else
      Result := Result and Children[I].Traverse(ACallback2, AData1, AData2, True, False);
    Inc(I);
  end;
end;

function TgdClassEntry.Compare(const AClassName: AnsiString;
  const ASubType: TgdcSubType): Integer;
begin
  Result := CompareText(FSubType, ASubType);
  if Result = 0 then
    Result := CompareText(FClass.ClassName, AClassName);
end;

procedure TgdClassEntry.RemoveChild(AChild: TgdClassEntry);
begin
  if FChildren <> nil then
    FChildren.Remove(AChild);
end;

function TgdClassEntry.Traverse(AList: TObjectList; const AnIncludeRoot,
  AnOnlyDirect: Boolean): Boolean;
begin
  Assert(AList <> nil);
  Result := Traverse(ListCallBack, AList, nil, AnIncludeRoot, AnOnlyDirect);
end;

function TgdClassEntry.ListCallback(ACE: TgdClassEntry; AData1,
  AData2: Pointer): Boolean;
begin
  TObjectList(AData1).Add(ACE);
  Result := True;
end;

function TgdClassEntry.FindChild(const AClassName: AnsiString): TgdClassEntry;
var
  I: Integer;
begin
  for I := 0 to Self.Count - 1 do
  begin
    Result := FChildren[I] as TgdClassEntry;
    if (CompareText(Result.TheClass.ClassName, AClassName) = 0)
      or (CompareText(Result.SubType, AClassName) = 0) then
    begin
      exit;
    end;
  end;
  Result := nil;
end;

procedure TgdClassEntry.Assign(CE: TgdClassEntry);
begin
  //
end;

function TgdClassEntry.InheritsFromCE(ACE: TgdClassEntry): Boolean;
begin
  Result := (ACE <> nil) and
    (
      (
        Self = ACE
      )
      or
      (
        TheClass.InheritsFrom(ACE.TheClass)
        and
        (TheClass <> ACE.TheClass)
      )
      or
      (
        (TheClass = ACE.TheClass)
        and
        Parent.InheritsFromCE(ACE)
      )
    );
end;

function TgdClassEntry.GetRootSubType: TgdClassEntry;
begin
  Result := Self;
  while (Result.Parent <> nil) and (Result.Parent.SubType > '') do
    Result := Result.Parent;
  if (Result is TgdAttrUserDefinedEntry) and (Result.Parent is TgdBaseEntry)
    and (TgdBaseEntry(Result.Parent).DistinctRelation > '') then
  begin
    Result := Result.Parent;
  end;    
end;

function TgdClassEntry.GetCaption: String;
begin
  if FCaption > '' then
    Result := FCaption
  else if FSubType > '' then
    Result := FSubType
  else if FClass <> nil then
    Result := FClass.ClassName
  else
    Result := '';    
end;

function TgdClassEntry.GetGroupID: TID;
begin
  Result := -1;
end;

class function TgdClassEntry.CheckSubType(const ASubType: TgdcSubType): Boolean;
begin
  // any subtype is valid on this level
  Result := True;  
end;

{TgdClassList}

function TgdClassList.Add(const AClass: TClass;
  const ASubType: TgdcSubType;
  const AParentSubType: TgdcSubType;
  const AnEntryClass: CgdClassEntry;
  const ACaption: String;
  const AnInitProc: TgdInitClassEntry = nil): TgdClassEntry;
var
  Prnt: TgdClassEntry;
  CN: String;
  ParentST: TgdcSubType;
begin
  if AClass = nil then
    raise Exception.Create('Class is not assigned.');

  Result := Find(AClass.ClassName, ASubType);

  if Result <> nil then
  begin
    if Result.FCaption = '' then
      Result.FCaption := ACaption;
  end else
  begin
    if AParentSubType > '' then
    begin
      Prnt := Find(AClass.ClassName, AParentSubType);
      if Prnt = nil then
        raise Exception.Create('Invalid parent subtype');
    end else
    begin
      if ASubType > '' then
      begin
        Prnt := Find(AClass.ClassName);
        if Prnt = nil then
          raise Exception.Create('Invalid class name');
      end else
      begin
        if AClass = TgdcBase then
        begin
          Result := _Create(nil, TgdBaseEntry, AClass, '', '');
          exit;
        end else if AClass = TgdcCreateableForm then
        begin
          Result := _Create(nil, TgdFormEntry, AClass, '', '');
          exit;
        end else if AClass = nil then
          raise Exception.Create('Invalid class name')
        else
          Prnt := Add(AClass.ClassParent, '', '', AnEntryClass, '');
      end;
    end;

    if AnEntryClass.InheritsFrom(Prnt.ClassType) then
      Result := _Create(Prnt, AnEntryClass, AClass, ASubType, ACaption)
    else
      Result := _Create(Prnt, CgdClassEntry(Prnt.ClassType), AClass, ASubType, ACaption);

    if AnInitProc <> nil then
      AnInitProc.Init(Result);

    if (ASubType > '') and AClass.InheritsFrom(TgdcBase)
      and (not CgdcBase(AClass).IsAbstractClass) then
    begin
      CN := CgdcBase(AClass).GetDialogFormClassName(ASubType);
      if (CN > '') and (CN <> TgdcBase.GetDialogFormClassName(ASubType)) then
      begin
        if (Prnt <> nil) and (Prnt.SubType > '') and (Prnt is TgdBaseEntry)
          and (TgdBaseEntry(Prnt).gdcClass.GetDialogFormClassName(Prnt.SubType) = CN) then
        begin
          ParentST := Prnt.SubType;
        end else
          ParentST := '';
        Add(CN, ASubType, ParentST, TgdFormEntry, '');
      end;

      CN := CgdcBase(AClass).GetViewFormClassName(ASubType);
      if CN > '' then
      begin
        if (Prnt <> nil) and (Prnt.SubType > '') and (Prnt is TgdBaseEntry)
          and (TgdBaseEntry(Prnt).gdcClass.GetViewFormClassName(Prnt.SubType) = CN) then
        begin
          ParentST := Prnt.SubType;
        end else
          ParentST := '';
        Add(CN, ASubType, ParentST, TgdDocumentEntry, '');
      end;
    end;
  end;
end;

constructor TgdClassList.Create;
begin
  inherited;

  FFindByRelationCache := TStringList.Create;
  FFindByRelationCache.Sorted := True;
  FFindByRelationCache.Duplicates := dupError;

  FFindDocByRUIDHdrCache := TStringList.Create;
  FFindDocByRUIDHdrCache.Sorted := True;
  FFindDocByRUIDHdrCache.Duplicates := dupError;

  FFindDocByRUIDLineCache := TStringList.Create;
  FFindDocByRUIDLineCache.Sorted := True;
  FFindDocByRUIDLineCache.Duplicates := dupError;

  FFindDocByIDHdrCache := TgdKeyObjectAssoc.Create;
  FFindDocByIDLineCache := TgdKeyObjectAssoc.Create;

  {$IFDEF DEBUG}
  Inc(glbClassListCount);
  {$ENDIF}
end;

destructor TgdClassList.Destroy;
var
  I: Integer;
begin
  FreeAndNil(FFindByRelationCache);
  FreeAndNil(FFindDocByRUIDHdrCache);
  FreeAndNil(FFindDocByRUIDLineCache);
  FreeAndNil(FFindDocByIDHdrCache);
  FreeAndNil(FFindDocByIDLineCache);

  for I := 0 to FCount - 1 do
    FClasses[I].Free;

  inherited;

{$IFDEF DEBUG}
  Dec(glbClassListCount);
{$ENDIF}
end;

function TgdClassList.Find(const AClass: TClass;
  const ASubType: TgdcSubType): TgdClassEntry;
begin
  Assert(AClass <> nil);
  Result := Find(AClass.ClassName, ASubType);
end;

function GetRemoveList(ACE: TgdClassEntry; AData1: Pointer; AData2: Pointer): Boolean;
begin
  TStringList(AData1^).Add(ACE.TheClass.ClassName + '=' + ACE.SubType);
  Result := True;
end;

function ValueFromString(const Str: String): string;
var
  P: Integer;
begin
  Result := '';
  P := AnsiPos('=', Str);
  if (P <> 0) and (P <> Length(Str)) then
    Result := Copy(Str, P + 1, Length(Str) - P);
end;

procedure TgdClassList.Remove(const AClass: TClass;
  const ASubType: TgdcSubType);
begin
  Assert(AClass <> nil);
  Remove(AClass.ClassName, ASubType);
end;

function GetAllSubTypes(ACE: TgdClassEntry; AData1: Pointer; AData2: Pointer): Boolean;
begin
  if ACE.SubType <> '' then
    TStringList(AData1^).Add(ACE.TheClass.ClassName + '=' + ACE.SubType);

  Result := True;
end;

procedure TgdClassList.RemoveAllSubTypes;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
  begin
    if FClasses[I].SubType > '' then
    begin
      if FClasses[I].Parent <> nil then
        FClasses[I].Parent.RemoveChild(FClasses[I]);
      FreeAndNil(FClasses[I]);
    end;
  end;

  _Compact;
end;

procedure TgdClassList.AddClassMethods(AClass: TComponentClass;
  AMethods: array of TgdMethod);
var
  VgdMethodList : TgdMethodList;
  VgdClassMethods : TgdClassMethods;
  I : Integer;
begin
  VgdClassMethods := TgdClassMethods.Create;
  try
    VgdMethodList := TgdMethodList.Create;
    try
      for I := Low(AMethods) to High(AMethods) do
      begin
        VgdMethodList.AddMethod(AMethods[I]);
        {$IFDEF METHODSCHECK}
        if dbgMethodList = nil then
          dbgMethodList := TStringList.Create;
        dbgMethodList.Add(Format(mcString, [AClass.ClassName, AMethods[I].Name]));
        {$ENDIF}
      end;

      VgdClassMethods.gdMethods.Assign(VgdMethodList);
      VgdClassMethods.gdcClass := AClass;
      AddClassMethods(VgdClassMethods);
    finally
      VgdMethodList.Free;
    end;
  finally
    VgdClassMethods.Free;
  end;
end;

procedure TgdClassList.AddClassMethods(
  AClassMethods: TgdClassMethods);
var
  I: Integer;
  CE: TgdClassEntry;
begin
  CE := Find(AClassMethods.gdcClass);

  Assert(CE <> nil);
  
  for I := 0 to AClassMethods.gdMethods.Count - 1 do
    CE.ClassMethods.gdMethods.AddMethod(AClassMethods.gdMethods.Items[I]);
end;

function TgdClassList.Traverse(const AClass: TClass;
  const ASubType: TgdcSubType; ACallback: TgdClassEntryCallback;
  AData1: Pointer; AData2: Pointer; const AnIncludeRoot, AnOnlyDirect: Boolean): Boolean;
var
  CE: TgdClassEntry;
begin
  Assert(Assigned(ACallback));

  CE := Find(AClass, ASubType);
  if CE <> nil then
    Result := CE.Traverse(ACallback, AData1, AData2, AnIncludeRoot, AnOnlyDirect)
  else
    Result := False;
end;

function TgdClassList.Traverse(const AClass: TClass;
  const ASubType: TgdcSubType; ACallback: TgdClassEntryCallback2;
  AData1: Pointer; AData2: Pointer; const AnIncludeRoot, AnOnlyDirect: Boolean): Boolean;
var
  CE: TgdClassEntry;
begin
  Assert(Assigned(ACallback));

  CE := Find(AClass, ASubType);
  if CE <> nil then
    Result := CE.Traverse(ACallback, AData1, AData2, AnIncludeRoot, AnOnlyDirect)
  else
    Result := False;
end;

function TgdClassList.GetSubTypeList(AClass: TClass; const ASubType: TgdcSubType;
  ASubTypeList: TStrings; const AnOnlyDirect: Boolean; const AVerbose: Boolean): Boolean;
var
  CE: TgdClassEntry;
begin
  Assert(AClass <> nil);

  CE := Find(AClass, ASubType);

  if CE = nil then
    raise Exception.Create('Unregistered class.');

  Result := CE.GetSubTypeList(ASubTypeList, AnOnlyDirect, AVerbose);
end;

function TgdClassList._Find(const AClassName: AnsiString; const ASubType: TgdcSubType;
  out Index: Integer): Boolean;
var
  L, H, C: Integer;
begin
  Result := False;
  L := 0;
  H := FCount - 1;
  while L <= H do
  begin
    Index := (L + H) shr 1;
    C := FClasses[Index].Compare(AClassName, ASubType);
    if C < 0 then
      L := Index + 1
    else if C > 0 then
      H := Index - 1
    else begin
      Result := True;
      exit;
    end;
  end;
  Index := L;
end;

procedure TgdClassList._Grow;
begin
  if High(FClasses) = -1 then
    SetLength(FClasses, 2048)
  else
    SetLength(FClasses, High(FClasses) + 1 + 1024);
end;

procedure TgdClassList._Insert(const Index: Integer; ACE: TgdClassEntry);
begin
  if FCount > High(FClasses) then _Grow;
  if Index < FCount then
  begin
    System.Move(FClasses[Index], FClasses[Index + 1],
      (FCount - Index) * SizeOf(FClasses[0]));
  end;
  FClasses[Index] := ACE;
  Inc(FCount);
end;

function GetClassTree(ACE: TgdClassEntry; AData1: Pointer;
  AData2: Pointer): Boolean;
begin
  Assert(ACE <> nil);
  Assert(AData1 <> nil);
  Assert(AData2 <> nil);
  Assert(TClassList(AData1^) <> nil);

  if ACE.SubType = '' then
    TClassList(AData1^).Add(ACE.TheClass);
  Result := True;
end;

function TgdClassList.Find(const AClassName: AnsiString;
  const ASubType: TgdcSubType): TgdClassEntry;
var
  Index: Integer;
begin
  if (AClassName <> '') and _Find(AClassName, ASubType, Index) then
    Result := FClasses[Index]
  else
    Result := nil;
end;

function TgdClassList.Find(const AFullClassName: TgdcFullClassName): TgdClassEntry;
begin
  Result := Find(AFullClassName.gdClassName, AFullClassName.SubType);
end;

function TgdClassList._CreateFormSubTypes(ACE: TgdClassEntry; Data1, Data2: Pointer): Boolean;
var
  CN, Captn: String;
  ParentST: TgdcSubType;
begin
  if (ACE.SubType > '')
    and (not TgdBaseEntry(ACE).gdcClass.IsAbstractClass) then
  begin
    if ACE.TheClass.ClassName <> ACE.Caption then
      Captn := ACE.Caption
    else
      Captn := '';

    if (ACE.TheClass.ClassName = 'TgdcUserDocument') then
    begin
      if (ACE.Parent is TgdBaseEntry) and (ACE.Parent.SubType > '') then
        ParentST := ACE.Parent.SubType
      else
        ParentST := '';

      if (ACE as TgdDocumentEntry).LineRelKey > 0 then
        CN := 'Tgdc_dlgUserComplexDocument'
      else
        CN := 'Tgdc_dlgUserSimpleDocument';
      Add(CN, ACE.SubType, ParentST, TgdFormEntry, Captn);
    end else
    begin
      CN := TgdBaseEntry(ACE).gdcClass.GetDialogFormClassName(ACE.SubType);
      if (CN > '') and (CN <> TgdcBase.GetDialogFormClassName(ACE.SubType)) then
      begin
        if (ACE.Parent is TgdBaseEntry) and (ACE.Parent.SubType > '')
          and (TgdBaseEntry(ACE.Parent).gdcClass.GetDialogFormClassName(ACE.Parent.SubType) = CN) then
        begin
          ParentST := ACE.Parent.SubType;
        end else
          ParentST := '';
        Add(CN, ACE.SubType, ParentST, TgdFormEntry, Captn);
      end;
    end;

    if (ACE.TheClass.ClassName = 'TgdcUserDocument')
      or (ACE.TheClass.ClassName = 'TgdcUserDocumentLine') then
    begin
      if (ACE.Parent is TgdBaseEntry) and (ACE.Parent.SubType > '') then
        ParentST := ACE.Parent.SubType
      else
        ParentST := '';

      if (ACE as TgdDocumentEntry).LineRelKey > 0 then
        CN := 'Tgdc_frmUserComplexDocument'
      else
        CN := 'Tgdc_frmUserSimpleDocument';
      Add(CN, ACE.SubType, ParentST, TgdFormEntry, Captn);
    end else
    begin
      CN := TgdBaseEntry(ACE).gdcClass.GetViewFormClassName(ACE.SubType);
      if CN > '' then
      begin
        if (ACE.Parent is TgdBaseEntry) and (ACE.Parent.SubType > '')
          and (TgdBaseEntry(ACE.Parent).gdcClass.GetViewFormClassName(ACE.Parent.SubType) = CN) then
        begin
          ParentST := ACE.Parent.SubType;
        end else
          ParentST := '';
        Add(CN, ACE.SubType, ParentST, TgdFormEntry, Captn);
      end;
    end;
  end;
  Result := True;
end;

procedure TgdClassList.LoadUserDefinedClasses;

  function LoadDocument(ADocClass: CgdClassEntry; Prnt: TgdClassEntry; q, qOpt: TIBSQL): TgdClassEntry;
  var
    PrevRB: Integer;
  begin
    Result := _Create(Prnt, ADocClass, Prnt.TheClass,
      q.FieldByName('ruid').AsString, q.FieldByName('name').AsString);
    TgdDocumentEntry(Result).LoadDE(q, qOpt, True);
    PrevRB := q.FieldByName('rb').AsInteger;
    q.Next;
    while (not q.EOF) and (q.FieldByName('lb').AsInteger < PrevRB) do
      LoadDocument(ADocClass, Result, q, qOpt);
  end;

  procedure CopySubTree(Src, Dst: TgdClassEntry);
  var
    I: Integer;
    CE: TgdClassEntry;
  begin
    for I := 0 to Src.Count - 1 do
    begin
      CE := _Create(Dst, TgdBaseEntry, Dst.TheClass,
        Src.Children[I].SubType, Src.Children[I].Caption);
      if Src.Children[I].Count > 0 then
        CopySubTree(Src.Children[I], CE);
    end;
  end;

  procedure CopyFormSubTree(Src, Dst: TgdClassEntry);
  var
    I: Integer;
    CE: TgdClassEntry;
  begin
    for I := 0 to Src.Count - 1 do
    begin
      CE := Find(Dst.TheClass.ClassName, Src.Children[I].SubType);
      if CE = nil then
        CE := _Create(Dst, TgdFormEntry, Dst.TheClass,
          Src.Children[I].SubType, Src.Children[I].Caption);
      if Src.Children[I].Count > 0 then
        CopyFormSubTree(Src.Children[I], CE);
    end;
  end;

  procedure CopyDocSubTree(Src, Dst: TgdClassEntry; const AClass: CgdClassEntry);
  var
    I: Integer;
    CE: TgdClassEntry;
  begin
    for I := 0 to Src.Count - 1 do
    begin
      if (Src.Children[I] as TgdDocumentEntry).LineRelKey > 0 then
      begin
        CE := _Create(Dst, AClass, Dst.TheClass,
          Src.Children[I].SubType, Src.Children[I].Caption);
        CE.Assign(Src.Children[I]);
        if Src.Children[I].Count > 0 then
          CopyDocSubTree(Src.Children[I], CE, AClass);
      end;
    end;
  end;

  procedure IterateStorage(F: TgsStorageFolder; APrnt: TgdClassEntry);
  var
    I: Integer;
    Prnt: TgdClassEntry;
  begin
    if APrnt = nil then
      Prnt := Find(F.Name)
    else
    begin
      Prnt := APrnt.FindChild(F.Name);
      if Prnt = nil then
        Prnt := _Create(APrnt, TgdStorageEntry, APrnt.TheClass, F.Name,
          F.ReadString('Caption'));
    end;

    for I := 0 to F.FoldersCount - 1 do
      IterateStorage(F.Folders[I], Prnt);
  end;

  {procedure LoadNewForm;
  var
    FNewForm: TgsStorageFolder;
    I: Integer;
    CEParentForm: TgdClassEntry;
  begin
    FNewForm := GlobalStorage.OpenFolder(st_ds_NewFormPath);
    if Assigned(FNewForm) then
      try
        for I := 0 to FNewForm.FoldersCount - 1 do
        begin
          CEParentForm := Find(FNewForm.Folders[I].ReadString('Class'));
          if CEParentForm is TgdFormEntry then
          begin
            if FNewForm.Folders[I].ReadInteger('InternalType', -1) = st_ds_SimplyForm then
            begin
              _Create(CEParentForm, TgdNewSimpleFormEntry, CEParentForm.TheClass,
                 FNewForm.Folders[I].Name, FNewForm.Folders[I].Name);
            end else
            begin
              //
            end;
          end;
        end;
      finally
        GlobalStorage.CloseFolder(FNewForm);
      end;
  end;}

var
  I, J: Integer;
  CEAttrUserDefined,
  CEAttrUserDefinedTree,
  CEAttrUserDefinedLBRBTree,
  CEUserDocument,
  CEUserDocumentLine,
  CEInvDocument,
  CEInvDocumentLine,
  CEInvPriceList,
  CEInvPriceListLine,
  CEInvRemains,
  CEInvGoodRemains,
  CEStorage: TgdClassEntry;
  DE, DELn: TgdDocumentEntry;
  q, qOpt: TIBSQL;
  FSubTypes: TgsStorageFolder;
  SL: TStringList;
  R: TatRelation;
begin
  Assert(atDatabase <> nil);

  CEAttrUserDefined := Get(TgdBaseEntry, 'TgdcAttrUserDefined');
  CEAttrUserDefinedTree := Get(TgdBaseEntry, 'TgdcAttrUserDefinedTree');
  CEAttrUserDefinedLBRBTree := Get(TgdBaseEntry, 'TgdcAttrUserDefinedLBRBTree');

  for I := 0 to atDatabase.Relations.Count - 1 do
  begin
    R := atDatabase.Relations[I];
    if (R.RelationType = rtTable) and R.IsUserDefined then
      LoadRelation(nil, R, CEAttrUserDefined, CEAttrUserDefinedTree,
        CEAttrUserDefinedLBRBTree);
  end;
  
  CEUserDocument := Get(TgdBaseEntry, 'TgdcUserDocument');
  CEUserDocumentLine := Get(TgdBaseEntry, 'TgdcUserDocumentLine');
  CEInvDocument := Get(TgdBaseEntry, 'TgdcInvDocument');
  CEInvDocumentLine := Get(TgdBaseEntry, 'TgdcInvDocumentLine');
  CEInvPriceList := Get(TgdBaseEntry, 'TgdcInvPriceList');
  CEInvPriceListLine := Get(TgdBaseEntry, 'TgdcInvPriceListLine');

  q := TIBSQL.Create(nil);
  qOpt := TIBSQL.Create(nil);
  try
    qOpt.Transaction := gdcBaseManager.ReadTransaction;
    qOpt.SQL.Text :=
      'SELECT opt.*, rf.relationname, rf.fieldname ' +
      'FROM gd_documenttype_option opt ' +
      '  JOIN gd_documenttype dt ON dt.id = opt.dtkey ' +
      '  LEFT JOIN at_relation_fields rf ON opt.relationfieldkey = rf.id ' +
      'ORDER BY ' +
      '  dt.lb, dt.id';
    qOpt.ExecQuery;

    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT dt.* ' +
      'FROM gd_documenttype dt ' +
      'WHERE dt.documenttype = ''D'' ' +
      'ORDER BY dt.lb, dt.id';
    q.ExecQuery;
    while not q.EOF do
    begin
      if CompareText(q.FieldbyName('classname').AsString, 'TgdcUserDocumentType') = 0 then
        LoadDocument(TgdDocumentEntry, CEUserDocument, q, qOpt)
      else if CompareText(q.FieldbyName('classname').AsString, 'TgdcInvDocumentType') = 0 then
        LoadDocument(TgdInvDocumentEntry, CEInvDocument, q, qOpt)
      else if CompareText(q.FieldbyName('classname').AsString, 'TgdcInvPriceListType') = 0 then
        LoadDocument(TgdInvPriceDocumentEntry, CEInvPriceList, q, qOpt)
      else begin
        DE := FindDocByTypeID(GetTID(q.FieldByName('id')), dcpHeader);
        if DE = nil then
          LoadDocument(TgdDocumentEntry, Get(TgdDocumentEntry, 'TgdcDocument'), q, qOpt)
        else begin
          DE.LoadDE(q, qOpt, True);
          DELn := FindDocByTypeID(GetTID(q.FieldByName('id')), dcpLine);
          if DELn <> nil then
            DELn.Assign(DE);
          q.Next;
        end;
      end;
    end;

    CEInvRemains := Get(TgdBaseEntry, 'TgdcInvRemains');
    CEInvGoodRemains := Get(TgdBaseEntry, 'TgdcInvGoodRemains');

    q.Close;
    q.SQL.Text := 'SELECT name, ruid FROM inv_balanceoption';
    q.ExecQuery;
    while not q.EOF do
    begin
      _Create(CEInvRemains, TgdBaseEntry, CEInvRemains.TheClass,
        q.FieldByName('ruid').AsString, q.FieldByName('name').AsString);
      _Create(CEInvGoodRemains, TgdBaseEntry, CEInvGoodRemains.TheClass,
        q.FieldByName('ruid').AsString, q.FieldByName('name').AsString);
      q.Next;
    end;

    CopySubTree(CEInvDocument, CEInvRemains);
    CopySubTree(CEInvDocument, CEInvGoodRemains);
    CopySubTree(CEInvDocument, Get(TgdBaseEntry, 'TgdcSelectedGood'));
    CopySubTree(CEInvDocument, Get(TgdBaseEntry, 'TgdcInvMovement'));

    //CopyFormSubTree(CEInvDocument, Get(TgdFormEntry, 'Tgdc_frmInvSelectedGoods'));
    CopyFormSubTree(CEInvGoodRemains, Get(TgdFormEntry, 'Tgdc_frmInvSelectGoodRemains'));
    CopyFormSubTree(CEInvRemains, Get(TgdFormEntry, 'Tgdc_frmInvSelectRemains'));
  finally
    qOpt.Free;
    q.Free;
  end;
  
  CopyDocSubTree(CEUserDocument, CEUserDocumentLine, TgdDocumentEntry);
  CopyDocSubTree(CEInvDocument, CEInvDocumentLine, TgdInvDocumentEntry);
  CopyDocSubTree(CEInvPriceList, CEInvPriceListLine, TgdInvPriceDocumentEntry);

  FSubTypes := GlobalStorage.OpenFolder('\SubTypes', False, False);
  try
    if FSubTypes <> nil then
    begin
      // support old format
      if FSubTypes.ValuesCount > 0 then
      begin
        SL := TStringList.Create;
        try
          for I := 0 to FSubTypes.ValuesCount - 1 do
          begin

            // ��� ���������� ���������� � ���������
            // ������ ���� �������
            if AnsiSameText(FSubTypes.Values[I].Name, 'TgdcInvRemains') then
              continue;

            CEStorage := Find(FSubTypes.Values[I].Name);
            if CEStorage <> nil then
            begin
              SL.CommaText := FSubTypes.Values[I].AsString;
              for J := 0 to SL.Count - 1 do
              begin
                if CEStorage.FindChild(SL.Values[SL.Names[J]]) = nil then
                begin
                  if not TgdStorageEntry.CheckSubType(SL.Values[SL.Names[J]]) then
                  begin
                    MessageBox(0,
                      PChar('������ ������� ' + SL.Values[SL.Names[J]] + ', �������� � ��������� ��� ������ ' +
                        CEStorage.TheClass.ClassName + ' ����� ������������ ������.'#13#10 +
                      '������ �� ����� ��������.'),
                      '��������',
                      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
                  end else
                    _Create(CEStorage, TgdStorageEntry, CEStorage.TheClass,
                      SL.Values[SL.Names[J]], SL.Names[J]);
                end;
              end;
            end;
          end;
        finally
          SL.Free;
        end;
      end;

      IterateStorage(FSubTypes, nil);
    end;
  finally
    GlobalStorage.CloseFolder(FSubTypes);
  end;

  //LoadNewForm;

  CreateFormSubTypes;
end;

function TgdClassList.LoadRelation(Prnt: TgdClassEntry; R: TatRelation; ACEAttrUserDefined,
  ACEAttrUserDefinedTree, ACEAttrUserDefinedLBRBTree: TgdClassEntry): TgdClassEntry;
var
  F: TatRelationField;
begin
  F := R.RelationFields.ByFieldName('INHERITEDKEY');

  if (F <> nil) and (F.References <> nil) then
  begin
    if F.References.IsUserDefined then
      Prnt := LoadRelation(nil, F.References, ACEAttrUserDefined,
        ACEAttrUserDefinedTree, ACEAttrUserDefinedLBRBTree)
    else
      Prnt := FindByRelation(F.References.RelationName);
  end;

  if Prnt = nil then
  begin
    if R.IsStandartRelation then
      Prnt := ACEAttrUserDefined
    else if R.IsLBRBTreeRelation then
      Prnt := ACEAttrUserDefinedLBRBTree
    else if R.IsStandartTreeRelation then
      Prnt := ACEAttrUserDefinedTree
    else begin
      Result := nil;
      exit;
    end;
  end;                

  Result := Find(Prnt.TheClass.ClassName, R.RelationName);

  if Result = nil then
  begin
    Result := _Create(Prnt, TgdAttrUserDefinedEntry, Prnt.TheClass,
      R.RelationName, R.LName);
    (Result as TgdBaseEntry).DistinctRelation := R.RelationName;
  end else
    Result.Caption := R.LName;
end;

function TgdClassList.LoadRelation(const ARelationName: String): TgdClassEntry;
var
  R: TatRelation;
begin
  Assert(atDatabase <> nil);
  R := atDatabase.Relations.ByRelationName(ARelationName);
  if (R <> nil) and (R.RelationType = rtTable) and R.IsUserDefined then
    Result := LoadRelation(nil, R, Get(TgdBaseEntry, 'TgdcAttrUserDefined'),
      Get(TgdBaseEntry, 'TgdcAttrUserDefinedTree'),
      Get(TgdBaseEntry, 'TgdcAttrUserDefinedLBRBTree'))
  else
    raise Exception.Create('Invalid relation.');
end;

function TgdClassList.Add(const AClassName: AnsiString;
  const ASubType, AParentSubType: TgdcSubType;
  const AnEntryClass: CgdClassEntry;
  const ACaption: String;
  const AnInitProc: TgdInitClassEntry = nil): TgdClassEntry;
begin
  Result := Find(AClassName, ASubType);

  if Result <> nil then
  begin
    if Result.FCaption = '' then
      Result.FCaption := ACaption;
  end else
    Result := Add(GetClass(AClassName), ASubType, AParentSubType,
      AnEntryClass, ACaption, AnInitProc);
end;

procedure TgdClassList._Compact;
var
  B, E: Integer;
begin
  B := 0;
  while B < FCount do
  begin
    E := B;
    while (E < FCount) and (FClasses[E] = nil) do
      Inc(E);
    if E = FCount then
    begin
      FCount := B;
      break;
    end;
    if E > B then
    begin
      System.Move(FClasses[E], FClasses[B], (FCount - E) * SizeOf(FClasses[0]));
      Dec(FCount, E - B);
    end;
    Inc(B);
  end;
end;

function TgdClassList._Create(APrnt: TgdClassEntry; AnEntryClass: CgdClassEntry;
  AClass: TClass; const ASubType: TgdcSubType; const ACaption: String): TgdClassEntry;
var
  Index: Integer;
begin
  Result := AnEntryClass.Create(APrnt, AClass, ASubType, ACaption);
  if APrnt <> nil then
    APrnt.AddChild(Result);

  if not _Find(Result.TheClass.ClassName, Result.SubType, Index) then
    _Insert(Index, Result)
  else
    raise Exception.Create('Internal consistency check');
end;

procedure TgdClassList.Remove(const AClassName: String;
  const ASubType: TgdcSubType);
var
  Index: Integer;
  OL: TObjectList;
  I: Integer;
begin
  if _Find(AClassName, ASubType, Index) then
  begin
    if FClasses[Index].Parent <> nil then
      FClasses[Index].Parent.RemoveChild(FClasses[Index]);
    OL := TObjectList.Create(False);
    try
      FClasses[Index].Traverse(OL, False);
      FClasses[Index].Free;
      if Index < (FCount - 1) then
        System.Move(FClasses[Index + 1], FClasses[Index],
          (FCount - Index - 1) * SizeOf(FClasses[0]));
      Dec(FCount);
      for I := OL.Count - 1 downto 0 do
      begin
        if _Find(TgdClassEntry(OL[I]).TheClass.ClassName, TgdClassEntry(OL[I]).SubType, Index) then
        begin
          FClasses[Index].Free;
          if Index < (FCount - 1) then
            System.Move(FClasses[Index + 1], FClasses[Index],
              (FCount - Index - 1) * SizeOf(FClasses[0]));
          Dec(FCount);
        end;
      end;
    finally
      OL.Free;
    end;
  end;
end;

procedure TgdClassList.RemoveSubType(const ASubType: TgdcSubType);
var
  I, PrevCount: Integer;
begin
  I := 0;
  while I < FCount do
  begin
    if FClasses[I].SubType = ASubType then
    begin
      PrevCount := FCount;
      Remove(FClasses[I].TheClass.ClassName, ASubType);
      if (PrevCount - FCount) > 1 then
        I := 0;
    end else
      Inc(I);
  end;
end;

function TgdClassList.FindDocByTypeID(const ADocTypeID: TID;
  const APart: TgdcDocumentClassPart; const AnUpdate: Boolean = False): TgdDocumentEntry;
var
  AuxRec: TAuxRec;
  DELn: TgdDocumentEntry;
  Idx: Integer;
begin
  Result := nil;

  if ADocTypeID <= 0 then
    exit;

  if APart = dcpHeader then
  begin
    if FFindDocByIDHdrCache.Find(ADocTypeID, Idx) then
      Result := FFindDocByIDHdrCache.ObjectByIndex[Idx] as TgdDocumentEntry;
  end else
  begin
    if FFindDocByIDLineCache.Find(ADocTypeID, Idx) then
      Result := FFindDocByIDLineCache.ObjectByIndex[Idx] as TgdDocumentEntry;
  end;

  if Result = nil then
  begin
    AuxRec.ID := ADocTypeID;
    AuxRec.Part := APart;
    AuxRec.RUID := '';
    AuxRec.CE := nil;
    Get(TgdDocumentEntry, 'TgdcDocument').Traverse(_FindDoc, @AuxRec, nil, False, False);
    if AuxRec.CE is TgdDocumentEntry then
    begin
      Result := AuxRec.CE as TgdDocumentEntry;

      if APart = dcpHeader then
        FFindDocByIdHdrCache.ObjectByIndex[FFindDocByIdHdrCache.Add(ADocTypeID)] := Result
      else
        FFindDocByIdLineCache.ObjectByIndex[FFindDocByIdLineCache.Add(ADocTypeID)] := Result;
    end;
  end;

  if (Result <> nil) and AnUpdate and Result.Invalid then
  begin
    Result.LoadDE(nil);
    if APart = dcpHeader then
    begin
      DELn := gdClassList.FindDocByTypeID(ADocTypeID, dcpLine);
      if DELn <> nil then
        DELn.Assign(Result);
    end;
  end;
end;

function TgdClassList._FindDoc(ACE: TgdClassEntry; AData1,
  AData2: Pointer): Boolean;
begin
  if (TgdDocumentEntry(ACE).TypeID = PAuxRec(AData1)^.ID)
    and (CgdcDocument(ACE.TheClass).GetDocumentClassPart = PAuxRec(AData1)^.Part)
    and (not CgdcDocument(ACE.TheClass).IsAbstractClass) then
  begin
    PAuxRec(AData1)^.CE := ACE;
    Result := False;
  end else
    Result := True;
end;

function TgdClassList.FindByRelation(
  const ARelationName: String): TgdBaseEntry;

  function GetCommonAncestor(A, B: TgdClassEntry): TgdClassEntry;
  begin
    if A = B then
      Result := A
    else if (A = nil) or (B = nil) then
      Result := nil
    else if B.InheritsFromCE(A) then
      Result := A
    else if A.InheritsFromCE(B) then
      Result := B
    else
      Result := GetCommonAncestor(A.Parent, B.Parent);
  end;

  function Iterate(ACE: TgdBaseEntry; var AFound: TgdBaseEntry): Boolean;
  var
    I: Integer;
  begin
    if CompareText(ARelationName, ACE.DistinctRelation) = 0 then
    begin
      if AFound = nil then
        AFound := ACE
      else begin
        AFound := GetCommonAncestor(AFound, ACE) as TgdBaseEntry;
        Result := False;
        exit;
      end;
    end;

    for I := 0 to ACE.Count - 1 do
    begin
      if not Iterate(ACE.Children[I] as TgdBaseEntry, AFound) then
      begin
        Result := False;
        exit;
      end;
    end;

    Result := True;
  end;

var
  CE: TgdBaseEntry;
  I: Integer;
begin
  I := FFindByRelationCache.IndexOf(ARelationName);
  if I = -1 then
  begin
    Result := nil;
    CE := Find('TgdcBase') as TgdBaseEntry;
    if (CE <> nil) and (ARelationName > '') then
      Iterate(CE, Result);
    if Result <> nil then
      FFindByRelationCache.AddObject(ARelationName, Result);
  end else
    Result := FFindByRelationCache.Objects[I] as TgdBaseEntry;
end;

function TgdClassList.FindDocByRUID(const ARUID: String;
  const APart: TgdcDocumentClassPart; const AnUpdate: Boolean = False): TgdDocumentEntry;
var
  AuxRec: TAuxRec;
  DELn: TgdDocumentEntry;
  Idx: Integer;
  R: TRUID;
begin
  Result := nil;

  if APart = dcpHeader then
  begin
    Idx := FFindDocByRUIDHdrCache.IndexOf(ARUID);
    if Idx <> -1 then
      Result := FFindDocByRUIDHdrCache.Objects[Idx] as TgdDocumentEntry;
  end else
  begin
    Idx := FFindDocByRUIDLineCache.IndexOf(ARUID);
    if Idx <> -1 then
      Result := FFindDocByRUIDLineCache.Objects[Idx] as TgdDocumentEntry;
  end;

  if Result = nil then
  begin
    AuxRec.ID := -1;
    AuxRec.Part := APart;
    AuxRec.RUID := ARUID;
    AuxRec.CE := nil;
    Get(TgdDocumentEntry, 'TgdcDocument').Traverse(_FindDocByRUID, @AuxRec, nil, False, False);

    if AuxRec.CE is TgdDocumentEntry then
    begin
      Result := AuxRec.CE as TgdDocumentEntry;
      if APart = dcpHeader then
        FFindDocByRUIDHdrCache.AddObject(ARUID, Result)
      else
        FFindDocByRUIDLineCache.AddObject(ARUID, Result);
    end else
    begin
      R := StrToRUID(ARUID);
      if R.DBID = cstEtalonDBID then
      begin
        Result := FindDocByTypeID(R.XID, APart, AnUpdate);
        exit;
      end;
    end;
  end;

  if (Result <> nil) and AnUpdate and Result.Invalid then
  begin
    Result.LoadDE(nil);
    if APart = dcpHeader then
    begin
      DELn := gdClassList.FindDocByRUID(ARUID, dcpLine);
      if DELn <> nil then
        DELn.Assign(Result);
    end;
  end;
end;

function TgdClassList._FindDocByRUID(ACE: TgdClassEntry; AData1,
  AData2: Pointer): Boolean;
begin
  if (TgdDocumentEntry(ACE).SubType = PAuxRec(AData1)^.RUID)
    and (CgdcDocument(ACE.TheClass).GetDocumentClassPart = PAuxRec(AData1)^.Part) then
  begin
    PAuxRec(AData1)^.CE := ACE;
    Result := False;
  end else
    Result := True;
end;

function TgdClassList.Find(AnObj: TgdcBase): TgdBaseEntry;
begin
  Assert(AnObj <> nil);
  Result := Find(AnObj.ClassName, AnObj.SubType) as TgdBaseEntry;
end;

function TgdClassList.Get(const AClass: CgdClassEntry; const AClassName: AnsiString;
  const ASubType: TgdcSubType = ''): TgdClassEntry;
begin
  Result := Find(AClassName, ASubType);
  if Result = nil then
    raise Exception.Create('Unknown class name/subtype ' + AClassName + ' ' + ASubType)
  else if not Result.InheritsFrom(AClass) then
    raise Exception.Create('Invalid type cast');
end;

procedure TgdClassList.FreeNotify(CE: TgdClassEntry);

  procedure _Scan(SL: TStringList);
  var
    I: Integer;
  begin
    if SL <> nil then
    begin
      for I := 0 to SL.Count - 1 do
        if SL.Objects[I] = CE then
        begin
          SL.Delete(I);
          break;
        end;
    end;
  end;

  procedure _Scan2(KO: TgdKeyObjectAssoc);
  var
    I: Integer;
  begin
    if KO <> nil then
    begin
      for I := 0 to KO.Count - 1 do
        if KO.ObjectByIndex[I] = CE then
        begin
          KO.Delete(I);
          break;
        end;
    end;
  end;

begin
  _Scan(FFindByRelationCache);
  _Scan(FFindDocByRUIDHdrCache);
  _Scan(FFindDocByRUIDLineCache);
  _Scan2(FFindDocByIDHdrCache);
  _Scan2(FFindDocByIDLineCache);
end;

procedure TgdClassList.CreateFormSubTypes;
begin
  Get(TgdBaseEntry, 'TgdcBase', '').Traverse(_CreateFormSubTypes, nil, nil, False, False);
end;

procedure TgdClassList.FindByRelation2(const ARelationName: String;
  OL: TObjectList);

  function Iterate(ACE: TgdBaseEntry): Boolean;
  var
    I: Integer;
  begin
    if CompareText(ARelationName, ACE.DistinctRelation) = 0 then
      OL.Add(ACE);

    for I := 0 to ACE.Count - 1 do
      Iterate(ACE.Children[I] as TgdBaseEntry);

    Result := True;  
  end;

var
  CE: TgdBaseEntry;
begin
  Assert((OL is TObjectList) and (not OL.OwnsObjects));
  CE := Find('TgdcBase') as TgdBaseEntry;
  if (CE <> nil) and (ARelationName > '') then
    Iterate(CE);
end;

{ TgdDocumentEntry }

procedure TgdDocumentEntry.Assign(CE: TgdClassEntry);
begin
  Assert(CE is TgdDocumentEntry);
  FTypeID := TgdDocumentEntry(CE).TypeID;
  FIsCommon := TgdDocumentEntry(CE).IsCommon;
  FHeaderFunctionKey := TgdDocumentEntry(CE).HeaderFunctionKey;
  FLineFunctionKey := TgdDocumentEntry(CE).LineFunctionKey;
  FDescription := TgdDocumentEntry(CE).Description;
  FIsCheckNumber := TgdDocumentEntry(CE).IsCheckNumber;
  FGroupID := TgdDocumentEntry(CE).GroupID;
  FOptions := TgdDocumentEntry(CE).Options;
  HeaderRelKey := TgdDocumentEntry(CE).HeaderRelKey;
  LineRelKey := TgdDocumentEntry(CE).LineRelKey;
  BranchKey := TgdDocumentEntry(CE).BranchKey;
  FEditionDate := TgdDocumentEntry(CE).FEditionDate;
  FInvalid := TgdDocumentEntry(CE).Invalid;
end;

procedure TgdDocumentEntry.ConvertOptions;
begin
  //
end;

function TgdDocumentEntry.FindParentByDocumentTypeKey(
  const ADocumentTypeKey: TID; const APart: TgdcDocumentClassPart): TgdDocumentEntry;
begin
  Result := Self;
  while Result.TypeID <> ADocumentTypeKey do
  begin
    if (not (Result.Parent is TgdDocumentEntry)) or (Result = Result.GetRootSubType) then
    begin
      Result := nil;
      break;
    end;
    Result := Result.Parent as TgdDocumentEntry;
  end;

  Assert((Result = nil) or (CgdcDocument(Result.TheClass).GetDocumentClassPart = APart));
end;

function TgdDocumentEntry.GetDistinctRelation: String;
begin
  if CgdcDocument(TheClass).GetDocumentClassPart = dcpHeader then
    Result := HeaderRelName
  else
    Result := LineRelName;

  if Result = '' then
    Result := inherited GetDistinctRelation;   
end;

procedure TgdDocumentEntry.LoadDE(q, qOpt: TIBSQL; const AnAllowParseOptions: Boolean = False);
begin
  FTypeID := GetTID(q.FieldByName('id'));
  FIsCommon := q.FieldByName('iscommon').AsInteger > 0;
  FHeaderFunctionKey := GetTID(q.FieldByName('headerfunctionkey'));
  FLineFunctionKey := GetTID(q.FieldByName('linefunctionkey'));
  FDescription := q.FieldByName('description').AsString;
  FIsCheckNumber := TIsCheckNumber(q.FieldByName('ischecknumber').AsInteger);
  FOptions := '';
  FGroupID := GetTID(q.FieldByName('reportgroupkey'));
  FHeaderRelKey := GetTID(q.FieldByName('headerrelkey'));
  FLineRelKey := GetTID(q.FieldByName('linerelkey'));
  FBranchKey := GetTID(q.FieldByName('branchkey'));
  FEditionDate := q.FieldByName('editiondate').AsDateTime;
  if qOpt.EOF or (GetTID(qOpt.FieldbyName('dtkey')) <> GetTID(q.FieldByName('id'))) then
  begin
    if ((Parent is TgdInvDocumentEntry) or (Parent is TgdInvPriceDocumentEntry))
      and (Parent.SubType = '') and (SubType > '')
      and AnAllowParseOptions then
    begin
      FOptions := q.FieldByName('options').AsString;
      ParseOptions;

      if gd_CmdLineParams.ConvertDocOptions then
        ConvertOptions
      else
        gdClassList.OldOptions := True;
    end;
  end else
    LoadDEOption(qOpt);
  FInvalid := False;
end;

function TgdDocumentEntry.GetHeaderRelName: String;
var
  R: TatRelation;
begin
  R := atDatabase.Relations.ByID(FHeaderRelKey);
  if R <> nil then
    Result := R.RelationName
  else
    Result := '';
end;

function TgdDocumentEntry.GetLineRelName: String;
var
  R: TatRelation;
begin
  R := atDatabase.Relations.ByID(FLineRelKey);
  if R <> nil then
    Result := R.RelationName
  else
    Result := '';
end;

procedure TgdDocumentEntry.LoadDE(Tr: TIBTransaction);
var
  q, qOpt: TIBSQL;
  TempTr: TIBTransaction;
begin
  Assert(gdcBaseManager <> nil);
  Assert(FTypeID > 0);

  q := TIBSQL.Create(nil);
  qOpt := TIBSQL.Create(nil);
  TempTr := nil;
  try
    if (Tr = nil) or (not Tr.InTransaction) then
    begin
      TempTr := TIBTransaction.Create(nil);
      TempTr.DefaultAction := taCommit;
      TempTr.DefaultDatabase := gdcBaseManager.Database;
      TempTr.StartTransaction;
      q.Transaction := TempTr;
      qOpt.Transaction := TempTr;
    end else
    begin
      q.Transaction := Tr;
      qOpt.Transaction := Tr;
    end;

    qOpt.SQL.Text :=
      'SELECT opt.*, rf.relationname, rf.fieldname ' +
      'FROM gd_documenttype_option opt ' +
      '  LEFT JOIN at_relation_fields rf ON opt.relationfieldkey = rf.id ' +
      'WHERE ' +
      '  opt.dtkey = :id';
    SetTID(qOpt.ParamByName('id'), TypeID);
    qOpt.ExecQuery;

    q.SQL.Text :=
      'SELECT dt.* ' +
      'FROM gd_documenttype dt ' +
      'WHERE dt.id = :id';
    SetTID(q.ParamByName('id'), TypeID);
    q.ExecQuery;

    LoadDE(q, qOpt);
  finally
    qOpt.Free;
    q.Free;
    TempTr.Free;
  end;
end;

procedure TgdDocumentEntry.LoadDEOption(qOpt: TIBSQL);
begin
  //
end;

procedure TgdDocumentEntry.ParseOptions;
begin
  //
end;

procedure TgdDocumentEntry.SetHeaderRelKey(const Value: TID);
begin
  FHeaderRelKey := Value;
end;

procedure TgdDocumentEntry.SetLineRelKey(const Value: TID);
begin
  FLineRelKey := Value;
end;

procedure TgdBaseEntry.SetDistinctRelation(const Value: String);
begin
  FDistinctRelation := UpperCase(Value);
end;

function TgdBaseEntry.GetGroupID: TID;
var
  q: TIBSQL;
  Tr: TIBTransaction;
  N, UGN: String;
  I: Integer;
begin
  if FGroupID <= 0 then
  begin
    Assert(gdcBaseManager <> nil);

    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text := 'SELECT id FROM rp_reportgroup WHERE usergroupname = :UGN';
      UGN := UpperCase(TheClass.ClassName + SubType);
      q.ParamByName('UGN').AsString := UGN;
      q.ExecQuery;
      if not q.EOF then
        FGroupID := GetTID(q.FieldByName('id'))
      else begin
        q.Close;
        Tr := TIBTransaction.Create(nil);
        try
          try
            Tr.DefaultDatabase := gdcBaseManager.Database;
            Tr.StartTransaction;

            q.Transaction := Tr;
            q.SQL.Text := 'SELECT id FROM rp_reportgroup WHERE name = :name AND parent IS NULL';
            I := 0;
            repeat
              N := gdcClass.GetDisplayName(SubType);
              if I > 0 then
                N := N + IntToStr(I);
              Inc(I);
              q.Close;
              q.ParamByName('name').AsString := N;
              q.ExecQuery;
            until q.EOF;

            FGroupID := gdcBaseManager.GetNextID;

            q.Close;
            q.SQL.Text := 'INSERT INTO RP_REPORTGROUP(ID, USERGROUPNAME, NAME) VALUES (:ID, :UGN, :N)';
            SetTID(q.ParamByName('ID'), FGroupID);
            q.ParamByName('UGN').AsString := UGN;
            q.ParamByName('N').AsString := N;
            q.ExecQuery;

            Tr.Commit;
          except
            FGroupID := -1;
          end;
        finally
          Tr.Free;
        end;
      end;
    finally
      q.Free;
    end;
  end;

  Result := FGroupID;
end;

procedure TgdDocumentEntry.SetInvalid(const Value: Boolean);
var
  DE: TgdDocumentEntry;
begin
  if FInvalid <> Value then
  begin
    FInvalid := Value;
    if CgdcDocument(TheClass).GetDocumentClassPart = dcpHeader then
      DE := gdClassList.FindDocByTypeID(FTypeID, dcpLine)
    else
      DE := gdClassList.FindDocByTypeID(FTypeID, dcpHeader);
    if DE <> nil then
      DE.FInvalid := Value;
  end;
end;

class function TgdDocumentEntry.CheckSubType(
  const ASubType: TgdcSubType): Boolean;
begin
  Result := CheckRUID(ASubType);
end;

{ TgdInitClassEntry }

procedure TgdInitClassEntry.Init(CE: TgdClassEntry);
begin
  //
end;

{ TgdStorageEntry }

class function TgdStorageEntry.CheckSubType(const ASubType: TgdcSubType): Boolean;
begin
  if (ASubType = '') {or (not CharIsAlpha(ASubType[1]))}
    or (not StrIsAlphaNumUnderscore(ASubType))
    or (StrIPos('USR_', ASubType) > 0) then
  begin
    Result := False;
  end else
    Result := inherited CheckSubType(ASubType);
end;

{ TgdInvDocumentEntry }

procedure TgdInvDocumentEntry.Assign(CE: TgdClassEntry);
begin
  inherited;
  FMovement[emDebit].Assign((CE as TgdInvDocumentEntry).FMovement[emDebit]);
  FMovement[emCredit].Assign((CE as TgdInvDocumentEntry).FMovement[emCredit]);
  FFeatures[ftSource].Assign((CE as TgdInvDocumentEntry).FFeatures[ftSource]);
  FFeatures[ftDest].Assign((CE as TgdInvDocumentEntry).FFeatures[ftDest]);
  FFeatures[ftMinus].Assign((CE as TgdInvDocumentEntry).FFeatures[ftMinus]);
  FFeatures[ftRestrRemainsBy].Assign((CE as TgdInvDocumentEntry).FFeatures[ftRestrRemainsBy]);
  FFlags := (CE as TgdInvDocumentEntry).FFlags;
end;

procedure TgdInvDocumentEntry.ConvertOptions;
var
  q, qRUID, qNS, qFindObj: TIBSQL;
  Tr: TIBTransaction;
  NSID, NSHeadObjectID: TID;
  NSPos: Integer;

  procedure AddNSObject(const AnObjectName: String; const AnOptID: TID;
    const ADependentOnID: TID = -1);
  var
    P: Integer;
  begin
    if NSID > -1 then
    begin
      P := 0;

      if ADependentOnID > 147000000 then
      begin
        qFindObj.Close;
        SetTID(qFindObj.ParamByName('nk'), NSID);
        SetTID(qFindObj.ParamByName('id'), ADependentOnID);
        qFindObj.ParamByName('p').AsInteger := NSPos;
        qFindObj.ExecQuery;
        if not qFindObj.EOF then
          P := qFindObj.Fields[0].AsInteger + 1;
        qFindObj.Close;
      end;

      if P = 0 then
      begin
        Inc(NSPos);
        P := NSPos;
      end;

      SetTID(qNS.ParamByName('namespacekey'), NSID);
      qNS.ParamByName('objectname').AsString := Copy(AnObjectName, 1, 60);
      SetTID(qNS.ParamByName('xid'), AnOptID);
      qNS.ParamByName('objectpos').AsInteger := P;
      SetTID(qNS.ParamByName('headobjectkey'), NSHeadObjectID);
      qNS.ParamByName('modified').AsDateTime := EditionDate;
      qNS.ParamByName('curr_modified').AsDateTime := EditionDate;
      qNS.ExecQuery;
    end;
  end;

  function GetOptID: TID;
  begin
    Result := gdcBaseManager.GetNextID;

    SetTID(qRUID.ParamByName('id'), Result);
    qRUID.ExecQuery;
  end;

  procedure ConvertRelationField(const ARelationName, AFieldName: String;
    const AnOptionName: String);
  var
    F: TatRelationField;
    OptID: TID;
  begin
    F := atDatabase.FindRelationField(ARelationName, AFieldName);
    if F <> nil then
    begin
      OptID := GetOptID;

      SetTID(q.ParamByName('id'), OptID);
      SetTID(q.ParamByName('dtkey'), TypeID);
      q.ParamByName('option_name').AsString := AnOptionName;
      q.ParamByName('bool_value').Clear;
      SetTID(q.ParamByName('relationfieldkey'), F.ID);
      q.ParamByName('contactkey').Clear;
      q.ParamByName('editiondate').AsDateTime := EditionDate;
      q.ExecQuery;

      AddNSObject(AnOptionName + '.' + F.FieldName, OptID, F.ID);
    end;
  end;

  procedure ConvertBoolean(const AValue: Boolean; const AnOptionName: String;
    const AnObjectName: String = '');
  var
    OptID: TID;
  begin
    if AValue then
    begin
      OptID := GetOptID;

      SetTID(q.ParamByName('id'), OptID);
      SetTID(q.ParamByName('dtkey'), TypeID);
      q.ParamByName('option_name').AsString := AnOptionName;
      q.ParamByName('bool_value').AsInteger := 1;
      q.ParamByName('relationfieldkey').Clear;
      q.ParamByName('contactkey').Clear;
      q.ParamByName('editiondate').AsDateTime := EditionDate;
      q.ExecQuery;

      if AnObjectName = '' then
        AddNSObject(AnOptionName, OptID)
      else
        AddNSObject(AnObjectName, OptID);
    end;
  end;

  procedure ConvertContact(const AContactKey: TID; const AnOptionName: String);
  var
    OptID: TID;
    R: OleVariant;
  begin
    if gdcBaseManager.ExecSingleQueryResult('SELECT name FROM gd_contact WHERE id=:id',
      TID2V(AContactKey), R) then
    begin
      OptID := GetOptID;

      SetTID(q.ParamByName('id'), OptID);
      SetTID(q.ParamByName('dtkey'), TypeID);
      q.ParamByName('option_name').AsString := AnOptionName;
      q.ParamByName('bool_value').Clear;
      q.ParamByName('relationfieldkey').Clear;
      SetTID(q.ParamByName('contactkey'), AContactKey);
      q.ParamByName('editiondate').AsDateTime := EditionDate;
      q.ExecQuery;

      AddNSObject(AnOptionName + '.' + R[0, 0], OptID, AContactKey);
    end;
  end;

  procedure ConvertInvMovementContactOption(AValue: TgdcInvMovementContactOption;
    const AnOptionName: String);
  var
    J: Integer;
  begin
    ConvertRelationField(AValue.RelationName, AValue.SourceFieldName, AnOptionName + '.SF');
    ConvertRelationField(AValue.SubRelationName, AValue.SubSourceFieldName, AnOptionName + '.SSF');
    ConvertBoolean(True, AnOptionName + '.CT.' + gdcInvMovementContactTypeNames[AValue.ContactType],
      AnOptionName + '.CT');
    for J := Low(AValue.Predefined) to High(AValue.Predefined) do
      ConvertContact(AValue.Predefined[J], AnOptionName + '.Predefined');
    for J := Low(AValue.SubPredefined) to High(AValue.SubPredefined) do
      ConvertContact(AValue.SubPredefined[J], AnOptionName + '.SubPredefined');
  end;

  procedure ConvertFeatures(const AFeature: TgdInvDocumentEntryFeature);
  var
    F: TatRelationField;
    OptID: TID;
    J: Integer;
    UserWarn: Boolean;
  begin
    UserWarn := False;
    for J := 0 to FFeatures[AFeature].Count - 1 do
    begin
      F := atDatabase.FindRelationField('INV_CARD', FFeatures[AFeature][J]);
      if F <> nil then
      begin
        OptID := GetOptID;

        SetTID(q.ParamByName('id'), OptID);
        SetTID(q.ParamByName('dtkey'), TypeID);
        q.ParamByName('option_name').AsString := InvDocumentFeaturesNames[AFeature];
        q.ParamByName('bool_value').Clear;
        SetTID(q.ParamByName('relationfieldkey'), F.ID);
        q.ParamByName('contactkey').Clear;
        q.ParamByName('editiondate').AsDateTime := EditionDate;

        try
          q.ExecQuery;
        except
          on E: Exception do
          begin
            if not UserWarn then
            begin
              MessageBox(0,
                PChar(
                  '��������� ������:'#13#10 +
                  E.Message + #13#10#13#10 +
                  '����������� ����� ����������. �� ��������� �� ������'#13#10 +
                  '��������� ��������, �������� ������� GD_DOCUMENTTYPE_OPTION'#13#10 +
                  '� �������� ��������� �������.'#13#10 +
                  '��������� ���������� � ����.'
                ),
                '������',
                MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
              UserWarn := True;
            end;
            AddMistake(E.Message);
          end;
        end;

        AddNSObject(InvDocumentFeaturesNames[AFeature], OptID, F.ID);
      end;
    end;
  end;

var
  N: TgdInvDocumentEntryFlag;
  P: Integer;
begin
  q := TIBSQL.Create(nil);
  qRUID := TIBSQL.Create(nil);
  qNS := TIBSQL.Create(nil);
  qFindObj := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;

    qRUID.Transaction := Tr;
    qRUID.SQL.Text :=
      'INSERT INTO gd_ruid (id, xid, dbid, modified, editorkey) ' +
      'VALUES (:id, :id, GEN_ID(gd_g_dbid, 0), CURRENT_TIMESTAMP, <CONTACTKEY/>)';

    qNS.Transaction := Tr;
    qNS.SQL.Text :=
      'INSERT INTO at_object (namespacekey, objectname, objectclass, xid, dbid, objectpos, headobjectkey, modified, curr_modified) ' +
      'VALUES (:namespacekey, :objectname, ''TgdcInvDocumentTypeOptions'', :xid, GEN_ID(gd_g_dbid, 0), :objectpos, :headobjectkey, :modified, :curr_modified)';

    qFindObj.Transaction := Tr;
    qFindObj.SQL.Text :=
      'SELECT o.objectpos FROM at_object o ' +
      'JOIN gd_ruid r ON r.xid = o.xid AND r.dbid = o.dbid ' +
      'WHERE o.namespacekey = :nk AND r.id = :id AND o.objectpos > :p';

    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT obj.* ' +
      'FROM at_object obj JOIN gd_ruid r ' +
      '  ON r.xid = obj.xid AND r.dbid = obj.dbid ' +
      'WHERE ' +
      '  r.id = :ID';
    SetTID(q.ParamByName('id'), TypeID);
    q.ExecQuery;

    if not q.EOF then
    begin
      NSID := GetTID(q.FieldByName('namespacekey'));
      NSPos := q.FieldByName('objectpos').AsInteger;
      NSHeadObjectID := GetTID(q.FieldByName('id'));
    end else
    begin
      NSID := -1;
      NSPos := -1;
      NSHeadObjectID := -1;
    end;

    q.Close;
    q.SQL.Text :=
      'INSERT INTO gd_documenttype_option (id, dtkey, option_name, bool_value, relationfieldkey, contactkey, editiondate) ' +
      '  VALUES (:id, :dtkey, :option_name, :bool_value, :relationfieldkey, :contactkey, :editiondate) ';

    ConvertInvMovementContactOption(GetMovementContactOption(emDebit), 'DM');
    ConvertInvMovementContactOption(GetMovementContactOption(emCredit), 'CM');
    ConvertFeatures(ftSource);
    ConvertFeatures(ftDest);
    ConvertFeatures(ftMinus);

    for N := InvDocumentEntryFlagFirst to InvDocumentEntryFlagLast do
      if FFlags[N, fpIsSet] then
      begin
        P := Pos('.', InvDocumentEntryFlagNames[N]);

        if P > 0 then
          ConvertBoolean(FFlags[N, fpValue], Copy(InvDocumentEntryFlagNames[N], 1, P - 1))
        else
          ConvertBoolean(FFlags[N, fpValue], InvDocumentEntryFlagNames[N]);
      end;

    Tr.Commit;
  finally
    qFindObj.Free;
    qNS.Free;
    qRUID.Free;
    q.Free;
    Tr.Free;
  end;
end;

constructor TgdInvDocumentEntry.Create(AParent: TgdClassEntry;
  const AClass: TClass; const ASubType: TgdcSubType;
  const ACaption: String);
begin
  inherited;
  FMovement[emDebit] := TgdcInvMovementContactOption.Create;
  FMovement[emCredit] := TgdcInvMovementContactOption.Create;
  FFeatures[ftSource] := TStringList.Create;
  FFeatures[ftDest] := TStringList.Create;
  FFeatures[ftMinus] := TStringList.Create;
  FFeatures[ftRestrRemainsBy] := TStringList.Create;
end;

destructor TgdInvDocumentEntry.Destroy;
begin
  FMovement[emDebit].Free;
  FMovement[emCredit].Free;
  FFeatures[ftSource].Free;
  FFeatures[ftDest].Free;
  FFeatures[ftMinus].Free;
  FFeatures[ftRestrRemainsBy].Free;  
  inherited;
end;

function TgdInvDocumentEntry.GetDirection: TgdcInvMovementDirection;
begin
  if FFlags[efDirFIFO, fpIsSet] or FFlags[efDirLIFO, fpIsSet] or FFlags[efDirDefault, fpIsSet] then
  begin
    if FFlags[efDirFIFO, fpValue] then
      Result := imdFIFO
    else if FFlags[efDirLIFO, fpValue] then
      Result := imdLIFO
    else
      Result := imdDefault;
  end
  else if Parent is TgdInvDocumentEntry then
    Result := TgdInvDocumentEntry(Parent).GetDirection
  else
    Result := imdFIFO;
end;

function TgdInvDocumentEntry.GetFeature(
  const AFeature: TgdInvDocumentEntryFeature;
  const AnIndex: Integer): String;
begin
  if (AnIndex < 0) or (AnIndex >= GetFeaturesCount(AFeature)) then
    raise Exception.Create('Invalid feature index')
  else if Parent is TgdInvDocumentEntry then
  begin
    if AnIndex < TgdInvDocumentEntry(Parent).GetFeaturesCount(AFeature) then
      Result := TgdInvDocumentEntry(Parent).GetFeature(AFeature, AnIndex)
    else
      Result := FFeatures[AFeature][AnIndex - TgdInvDocumentEntry(Parent).GetFeaturesCount(AFeature)];
  end else
    Result := FFeatures[AFeature][AnIndex];
end;

function TgdInvDocumentEntry.GetFeaturesText(
  const AFeature: TgdInvDocumentEntryFeature): String;
begin
  if Parent is TgdInvDocumentEntry then
  begin
    Result := TgdInvDocumentEntry(Parent).GetFeaturesText(AFeature);
    if (FFeatures[AFeature].Count <> 0) and (Result <> '') then Result := Result + ',';
    Result := Result + FFeatures[AFeature].CommaText;
  end
  else
    Result := FFeatures[AFeature].CommaText;
end;

function TgdInvDocumentEntry.GetFeaturesCount(
  const AFeature: TgdInvDocumentEntryFeature): Integer;
begin
  if Parent is TgdInvDocumentEntry then
    Result := TgdInvDocumentEntry(Parent).GetFeaturesCount(AFeature) + FFeatures[AFeature].Count
  else
    Result := FFeatures[AFeature].Count;
end;

function TgdInvDocumentEntry.GetFlag(const AFlag: TgdInvDocumentEntryFlag): Boolean;
begin
  if AFlag in [efDirFIFO, efDirLIFO, efDirDefault] then
    raise Exception.Create('Can''t get a separate movement direction flag');

  if (not FFlags[AFlag, fpIsSet]) and (Parent is TgdInvDocumentEntry) then
    Result := TgdInvDocumentEntry(Parent).GetFlag(AFlag)
  else
    Result := FFlags[AFlag, fpValue];
end;

function TgdInvDocumentEntry.GetMCOContactType(
  const AMovement: TgdInvDocumentEntryMovement): TgdcInvMovementContactType;
begin
  if (not FMovement[Amovement].ContactTypeSet) and (Parent is TgdInvDocumentEntry) then
    Result := TgdInvDocumentEntry(Parent).GetMCOContactType(AMovement)
  else
    Result := FMovement[AMovement].ContactType;
end;

procedure TgdInvDocumentEntry.GetMCOPredefined(
  const AMovement: TgdInvDocumentEntryMovement; var V: TgdcMCOPredefined);
var
  I, J, K: Integer;
begin
  if Parent is TgdInvDocumentEntry then
    TgdInvDocumentEntry(Parent).GetMCOPredefined(AMovement, V)
  else
    SetLength(V, 0);
  I := Length(V);
  J := Length(FMovement[AMovement].Predefined);
  SetLength(V, I + J);
  for K := 0 to J - 1 do
    V[I + K] := FMovement[AMovement].Predefined[K];
end;

function TgdInvDocumentEntry.GetMCORelationName(
  const AMovement: TgdInvDocumentEntryMovement): String;
begin
  if (FMovement[AMovement].SourceFieldName = '') and (Parent is TgdInvDocumentEntry) then
    Result := TgdInvDocumentEntry(Parent).GetMCORelationName(AMovement)
  else
    Result := FMovement[AMovement].RelationName;
end;

function TgdInvDocumentEntry.GetMCOSourceFieldName(
  const AMovement: TgdInvDocumentEntryMovement): String;
begin
  if (FMovement[Amovement].SourceFieldName = '') and (Parent is TgdInvDocumentEntry) then
    Result := TgdInvDocumentEntry(Parent).GetMCOSourceFieldName(AMovement)
  else
    Result := FMovement[AMovement].SourceFieldName;
end;

procedure TgdInvDocumentEntry.GetMCOSubPredefined(
  const AMovement: TgdInvDocumentEntryMovement; var V: TgdcMCOPredefined);
var
  I, J, K: Integer;
begin
  if Parent is TgdInvDocumentEntry then
    TgdInvDocumentEntry(Parent).GetMCOSubPredefined(AMovement, V)
  else
    SetLength(V, 0);
  I := Length(V);
  J := Length(FMovement[AMovement].SubPredefined);
  SetLength(V, I + J);
  for K := 0 to J - 1 do
    V[I + K] := FMovement[AMovement].SubPredefined[K];
end;

function TgdInvDocumentEntry.GetMCOSubRelationName(
  const AMovement: TgdInvDocumentEntryMovement): String;
begin
  if (FMovement[Amovement].SubSourceFieldName = '') and (Parent is TgdInvDocumentEntry) then
    Result := TgdInvDocumentEntry(Parent).GetMCOSubRelationName(AMovement)
  else
    Result := FMovement[AMovement].SubRelationName;
end;

function TgdInvDocumentEntry.GetMCOSubSourceFieldName(
  const AMovement: TgdInvDocumentEntryMovement): String;
begin
  if (FMovement[Amovement].SubSourceFieldName = '') and (Parent is TgdInvDocumentEntry) then
    Result := TgdInvDocumentEntry(Parent).GetMCOSubSourceFieldName(AMovement)
  else
    Result := FMovement[AMovement].SubSourceFieldName;
end;

function TgdInvDocumentEntry.GetMovement(
  const AMovement: TgdInvDocumentEntryMovement): TgdcInvMovementContactOption;
begin
  if (FMovement[Amovement].RelationName = '') and (Parent is TgdInvDocumentEntry) then
    Result := TgdInvDocumentEntry(Parent).GetMovement(AMovement)
  else
    Result := FMovement[AMovement];
end;

function TgdInvDocumentEntry.GetMovementContactOption(
  const AMovement: TgdInvDocumentEntryMovement): TgdcInvMovementContactOption;
begin
  Result := FMovement[AMovement];
end;

function TgdInvDocumentEntry.GetSources: TgdcInvReferenceSources;
begin
  Result := [];

  if GetFlag(efSrcGoodRef) then
    Include(Result, irsGoodRef);
  if GetFlag(efSrcRemainsRef) then
    Include(Result, irsRemainsRef);
  if GetFlag(efSrcMacro) then
    Include(Result, irsMacro);
end;

function TgdInvDocumentEntry.IsExistsFeature(
  const AFeature: TgdInvDocumentEntryFeature;
  const Feature: String): Boolean;
begin

  if Parent is TgdInvDocumentEntry then
    Result := TgdInvDocumentEntry(Parent).IsExistsFeature(AFeature, Feature)
  else
    Result := False;

  if not Result then
    Result := FFeatures[AFeature].IndexOf(Feature) >= 0;
    
end;

procedure TgdInvDocumentEntry.LoadDE(Tr: TIBTransaction);
begin
  FMovement[emDebit].Clear;
  FMovement[emCredit].Clear;
  FFeatures[ftSource].Clear;
  FFeatures[ftDest].Clear;
  FFeatures[ftMinus].Clear;
  FFeatures[ftRestrRemainsBy].Clear;
  FillChar(FFlags, SizeOf(FFlags), 0);

  inherited;
end;

procedure TgdInvDocumentEntry.LoadDEOption(qOpt: TIBSQL);

  procedure LoadMovementContactOption(const AnOptName: String; M: TgdInvDocumentEntryMovement);
  var
    N: TgdcInvMovementContactType;
    S: String;
  begin
    if Length(AnOptName) < 2 then
      raise Exception.Create('Invalid option name');

    if (AnOptName[1] = 'C') and (AnOptName[2] = 'T') then
    begin
      S := Copy(AnOptName, 4, 255);
      for N := gdcInvMovementContactTypeLow to gdcInvMovementContactTypeHigh do
        if (S = gdcInvMovementContactTypeNames[N]) and (qOpt.FieldbyName('bool_value').AsInteger <> 0) then
        begin
          FMovement[M].ContactType := N;
          FMovement[M].ContactTypeSet := True;
        end;
    end
    else if AnOptName = 'SF' then
    begin
      FMovement[M].RelationName := qOpt.FieldbyName('relationname').AsString;
      FMovement[M].SourceFieldName := qOpt.FieldByName('fieldname').AsString;
    end
    else if AnOptName = 'SSF' then
    begin
      FMovement[M].SubRelationName := qOpt.FieldbyName('relationname').AsString;
      FMovement[M].SubSourceFieldName := qOpt.FieldByName('fieldname').AsString;
    end
    else if AnOptName = 'Predefined' then
      FMovement[M].AddPredefined(GetTID(qOpt.FieldByName('contactkey')))
    else if AnOptName = 'SubPredefined' then
      FMovement[M].AddSubPredefined(GetTID(qOpt.FieldByName('contactkey')));
  end;

  procedure LoadFeatures(R: TatRelation; const AFeature: TgdInvDocumentEntryFeature);
  var
    F: TatRelationField;
  begin
    F := R.RelationFields.ByID(GetTID(qOpt.FieldByName('relationfieldkey')));
    if F <> nil then
      FFeatures[AFeature].Add(F.FieldName);
  end;

var
  OptName: String;
  R: TatRelation;
  N: TgdInvDocumentEntryFlag;
begin
  R := atDatabase.Relations.ByRelationName('INV_CARD');
  Assert(R <> nil);

  while (not qOpt.EOF) and (GetTID(qOpt.FieldbyName('dtkey')) = TypeID) do
  begin
    OptName := qOpt.FieldbyName('option_name').AsString;

    if Length(OptName) < 2 then
      raise Exception.Create('Invalid document type option name');

    if (OptName[1] = 'D') and (OptName[2] = 'M') then
      LoadMovementContactOption(Copy(OptName, 4, 1024), emDebit)
    else if (OptName[1] = 'C') and (OptName[2] = 'M') then
      LoadMovementContactOption(Copy(OptName, 4, 1024), emCredit)
    else if OptName = InvDocumentFeaturesNames[ftSource] then
      LoadFeatures(R, ftSource)
    else if OptName = InvDocumentFeaturesNames[ftDest] then
      LoadFeatures(R, ftDest)
    else if OptName = InvDocumentFeaturesNames[ftMinus] then
      LoadFeatures(R, ftMinus)
    else if OptName = InvDocumentFeaturesNames[ftRestrRemainsBy] then
      LoadFeatures(R, ftRestrRemainsBy)
    else
    begin
      for N := InvDocumentEntryFlagFirst to InvDocumentEntryFlagLast do
        if OptName = InvDocumentEntryFlagNames[N] then
        begin
          FFlags[N, fpValue] := qOpt.FieldbyName('bool_value').AsInteger <> 0;
          FFlags[N, fpIsSet] := True;
          break;
        end;
    end;

    qOpt.Next;
  end;
end;

procedure TgdInvDocumentEntry.ParseOptions;

  procedure SetFlag(const F: TgdInvDocumentEntryFlag; const AValue: Boolean = True);
  begin
    FFlags[F, fpValue] := AValue;
    FFlags[F, fpIsSet] := True;
  end;

var
  Version: String;
  SS: TStringStream;
  F: TatRelationField;
  TempDirection: TgdcInvMovementDirection;
  TempSources: TgdcInvReferenceSources;
  Reader: TReader;
begin
  if Options = '' then
    exit;

  SS := TStringStream.Create(Options);
  Reader :=TReader.Create(SS, 1024);
  with Reader do
  try
    Version := ReadString;

    if Version = gdcInv_Document_Undone then
      raise Exception.Create('������� ��������� ������������� ��������� ��������!');

    // header rel name
    ReadString;
    // line rel name
    ReadString;

    if (Version <> gdcInvDocument_Version2_0) and (Version <> gdcInvDocument_Version2_1) and
       (Version <> gdcInvDocument_Version2_2) and (Version <> gdcInvDocument_Version2_3)
    then
      // ��� ��������� ���������
      ReadInteger;

    // ���� ������ �� ������ �������
    if (Version = gdcInvDocument_Version2_2) or
      (Version = gdcInvDocument_Version2_3) or
      (Version = gdcInvDocument_Version2_1) or
      (Version = gdcInvDocument_Version2_0) or
      (Version = gdcInvDocument_Version1_9) then
    begin
      ReadTID(Reader);
    end;

    // ������
    FMovement[emDebit].RelationName := ReadString;
    FMovement[emDebit].SourceFieldName := ReadString;
    FMovement[emDebit].SubRelationName := ReadString;
    FMovement[emDebit].SubSourceFieldName := ReadString;

    Read(FMovement[emDebit].ContactType, SizeOf(FMovement[emDebit].ContactType));
    FMovement[emDebit].ContactTypeSet := True;

    SetLength(FMovement[emDebit].Predefined, 0);
    ReadListBegin;
    while not EndOfList do
      FMovement[emDebit].AddPredefined(ReadTID(Reader));
    ReadListEnd;

    SetLength(FMovement[emDebit].SubPredefined, 0);
    ReadListBegin;
    while not EndOfList do
      FMovement[emDebit].AddSubPredefined(ReadTID(Reader));
    ReadListEnd;

    // ������
    FMovement[emCredit].RelationName := ReadString;
    FMovement[emCredit].SourceFieldName := ReadString;
    FMovement[emCredit].SubRelationName := ReadString;
    FMovement[emCredit].SubSourceFieldName := ReadString;

    Read(FMovement[emCredit].ContactType, SizeOf(FMovement[emCredit].ContactType));
    FMovement[emCredit].ContactTypeSet := True;

    SetLength(FMovement[emCredit].Predefined, 0);
    ReadListBegin;
    while not EndOfList do
      FMovement[emCredit].AddPredefined(ReadTID(Reader));
    ReadListEnd;

    SetLength(FMovement[emCredit].SubPredefined, 0);
    ReadListBegin;
    while not EndOfList do
      FMovement[emCredit].AddSubPredefined(ReadTID(Reader));
    ReadListEnd;

    // ��������� ���������
    FFeatures[ftSource].Clear;
    ReadListBegin;
    while not EndOfList do
    begin
      F := atDatabase.FindRelationField('INV_CARD', ReadString);
      if (F <> nil) and (FFeatures[ftSource].IndexOf(F.FieldName) = -1) then
        FFeatures[ftSource].AddObject(F.FieldName, F);
    end;
    ReadListEnd;

    FFeatures[ftDest].Clear;
    ReadListBegin;
    while not EndOfList do
    begin
      F := atDatabase.FindRelationField('INV_CARD', ReadString);
      if (F <> nil) and (FFeatures[ftDest].IndexOf(F.FieldName) = -1) then
        FFeatures[ftDest].AddObject(F.FieldName, F);
    end;
    ReadListEnd;

    // ��������� ������������
    Read(TempSources, SizeOf(TgdcInvReferenceSources));

    if irsGoodRef in TempSources then
      SetFlag(efSrcGoodRef);
    if irsRemainsRef in TempSources then
      SetFlag(efSrcRemainsRef);
    if irsMacro in TempSources then
      SetFlag(efSrcMacro);

    // ��������� FIFO, LIFO
    Read(TempDirection, SizeOf(TgdcInvMovementDirection));

    if TempDirection = imdFIFO then
      SetFlag(efDirFIFO)
    else if TempDirection = imdLIFO then
      SetFlag(efDirLIFO)
    else
      SetFlag(efDirDefault);

    // �������� ��������
    SetFlag(efControlRemains, ReadBoolean);

    // ������ ������ � �������� ���������
    if (Version = gdcInvDocument_Version1_9) or
      (Version = gdcInvDocument_Version2_0) or
      (Version = gdcInvDocument_Version2_1) or
      (Version = gdcInvDocument_Version2_2) or
      (Version = gdcInvDocument_Version2_3) or
      (Version = gdcInvDocument_Version2_4) or
      (Version = gdcInvDocument_Version2_5) or
      (Version = gdcInvDocument_Version2_6) or
      (Version = gdcInvDocument_Version3_0)  then
    begin
      SetFlag(efLiveTimeRemains, ReadBoolean);
    end else
      SetFlag(efLiveTimeRemains, False);

    // �������� ����� ���� ����������
    SetFlag(efDelayedDocument, ReadBoolean);

    // ����� �������������� �����������
    SetFlag(efUseCachedUpdates, ReadBoolean);

    if (Version = gdcInvDocument_Version2_1) or (Version = gdcInvDocument_Version2_2)
       or (Version = gdcInvDocument_Version2_3) or (Version = gdcInvDocument_Version2_4)
       or (Version = gdcInvDocument_Version2_5)  or
      (Version = gdcInvDocument_Version2_6) or (Version = gdcInvDocument_Version3_0)
    then
      SetFlag(efMinusRemains, ReadBoolean)
    else
      SetFlag(efMinusRemains, False);

    if (Version = gdcInvDocument_Version2_2) or (Version = gdcInvDocument_Version2_3)
       or (Version = gdcInvDocument_Version2_4) or (Version = gdcInvDocument_Version2_5) or
      (Version = gdcInvDocument_Version2_6) or (Version = gdcInvDocument_Version3_0)
    then
    begin
      ReadListBegin;
      while not EndOfList do
      begin
        F := atDatabase.FindRelationField('INV_CARD', ReadString);
        if (F <> nil) and (FFeatures[ftMinus].IndexOf(F.FieldName) = -1) then
          FFeatures[ftMinus].AddObject(F.FieldName, F);
      end;
      ReadListEnd;
    end;

    if (Version = gdcInvDocument_Version2_3) or (Version = gdcInvDocument_Version2_4) or
       (Version = gdcInvDocument_Version2_5)  or
      (Version = gdcInvDocument_Version2_6) or
      (Version = gdcInvDocument_Version3_0) then
    begin
      SetFlag(efIsChangeCardValue, ReadBoolean);
      SetFlag(efIsAppendCardValue, ReadBoolean);
    end;

    if (Version = gdcInvDocument_Version2_4) or (Version = gdcInvDocument_Version2_5)  or
      (Version = gdcInvDocument_Version2_6) or
      (Version = gdcInvDocument_Version3_0) then
      SetFlag(efIsUseCompanyKey, ReadBoolean)
    else
      SetFlag(efIsUseCompanyKey, True);

    if (Version = gdcInvDocument_Version2_5)  or
      (Version = gdcInvDocument_Version2_6) or
      (Version = gdcInvDocument_Version3_0) then
      SetFlag(efSaveRestWindowOption, ReadBoolean)
    else
      SetFlag(efSaveRestWindowOption, False);

    if (Version = gdcInvDocument_Version2_6) or (Version = gdcInvDocument_Version3_0) then
      SetFlag(efEndMonthRemains, ReadBoolean)
    else
      SetFlag(efEndMonthRemains, False);

    if (Version = gdcInvDocument_Version3_0) then
      SetFlag(efWithoutSearchRemains, ReadBoolean)
    else
      SetFlag(efWithoutSearchRemains, False);

  finally
    Free;
    SS.Free;
  end;
end;

{ TgdInvPriceDocumentEntry }

procedure TgdInvPriceDocumentEntry.Assign(CE: TgdClassEntry);
var
  PE: TgdInvPriceDocumentEntry;
begin
  inherited;
  PE := CE as TgdInvPriceDocumentEntry;
  FHeaderFields := Copy(PE.FHeaderFields, 0, Length(PE.FHeaderFields));
  FLineFields := Copy(PE.FLineFields, 0, Length(PE.FLineFields));
end;

procedure TgdInvPriceDocumentEntry.ConvertOptions;
var
  q, qRUID, qNS, qFindObj: TIBSQL;
  Tr: TIBTransaction;
  NSID, NSHeadObjectID: TID;
  NSPos: Integer;

  procedure AddNSObject(const AnObjectName: String; const AnOptID: TID;
    const ADependentOnID: TID = -1);
  var
    P: Integer;
  begin
    if NSID > -1 then
    begin
      P := 0;

      if ADependentOnID > 147000000 then
      begin
        qFindObj.Close;
        SetTID(qFindObj.ParamByName('nk'), NSID);
        SetTID(qFindObj.ParamByName('id'), ADependentOnID);
        qFindObj.ParamByName('p').AsInteger := NSPos;
        qFindObj.ExecQuery;
        if not qFindObj.EOF then
          P := qFindObj.Fields[0].AsInteger + 1;
        qFindObj.Close;
      end;

      if P = 0 then
      begin
        Inc(NSPos);
        P := NSPos;
      end;

      SetTID(qNS.ParamByName('namespacekey'), NSID);
      qNS.ParamByName('objectname').AsString := Copy(AnObjectName, 1, 60);
      SetTID(qNS.ParamByName('xid'), AnOptID);
      qNS.ParamByName('objectpos').AsInteger := P;
      SetTID(qNS.ParamByName('headobjectkey'), NSHeadObjectID);
      qNS.ParamByName('modified').AsDateTime := EditionDate;
      qNS.ParamByName('curr_modified').AsDateTime := EditionDate;
      qNS.ExecQuery;
    end;
  end;

  function GetOptID: TID;
  begin
    Result := gdcBaseManager.GetNextID;

    SetTID(qRUID.ParamByName('id'), Result);
    qRUID.ExecQuery;
  end;

  procedure ConvertFields(const ARelName: String; const AnOptName: String; const AFields: TgdcInvPriceFields);
  var
    F: TatRelationField;
    OptID: TID;
    J: Integer;
  begin
    for J := Low(AFields) to High(AFields) do
    begin
      F := atDatabase.FindRelationField(ARelName, AFields[J].FieldName);
      if F <> nil then
      begin
        OptID := GetOptID;

        SetTID(q.ParamByName('id'), OptID);
        SetTID(q.ParamByName('dtkey'), TypeID);
        q.ParamByName('option_name').AsString := AnOptName;
        q.ParamByName('bool_value').Clear;
        SetTID(q.ParamByName('relationfieldkey'), F.ID);
        if AFields[J].ContactKey > 0 then
          SetTID(q.ParamByName('contactkey'), AFields[J].ContactKey)
        else
          q.ParamByName('contactkey').Clear;
        if AFields[J].CurrencyKey > 0 then
          SetTID(q.ParamByName('currkey'), AFields[J].CurrencyKey)
        else
          q.ParamByName('currkey').Clear;
        q.ParamByName('editiondate').AsDateTime := EditionDate;
        q.ExecQuery;

        AddNSObject(AnOptName + '.' + F.FieldName, OptID, F.ID);
      end;
    end;
  end;

begin
  q := TIBSQL.Create(nil);
  qRUID := TIBSQL.Create(nil);
  qNS := TIBSQL.Create(nil);
  qFindObj := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;

    qRUID.Transaction := Tr;
    qRUID.SQL.Text :=
      'INSERT INTO gd_ruid (id, xid, dbid, modified, editorkey) ' +
      'VALUES (:id, :id, GEN_ID(gd_g_dbid, 0), CURRENT_TIMESTAMP, <CONTACTKEY/>)';

    qNS.Transaction := Tr;
    qNS.SQL.Text :=
      'INSERT INTO at_object (namespacekey, objectname, objectclass, xid, dbid, objectpos, headobjectkey, modified, curr_modified) ' +
      'VALUES (:namespacekey, :objectname, ''TgdcInvDocumentTypeOptions'', :xid, GEN_ID(gd_g_dbid, 0), :objectpos, :headobjectkey, :modified, :curr_modified)';

    qFindObj.Transaction := Tr;
    qFindObj.SQL.Text :=
      'SELECT o.objectpos FROM at_object o ' +
      'JOIN gd_ruid r ON r.xid = o.xid AND r.dbid = o.dbid ' +
      'WHERE o.namespacekey = :nk AND r.id = :id AND o.objectpos > :p';

    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT obj.* ' +
      'FROM at_object obj JOIN gd_ruid r ' +
      '  ON r.xid = obj.xid AND r.dbid = obj.dbid ' +
      'WHERE ' +
      '  r.id = :ID';
    SetTID(q.ParamByName('id'), TypeID);
    q.ExecQuery;

    if not q.EOF then
    begin
      NSID := GetTID(q.FieldByName('namespacekey'));
      NSPos := q.FieldByName('objectpos').AsInteger;
      NSHeadObjectID := GetTID(q.FieldByName('id'));
    end else
    begin
      NSID := -1;
      NSPos := -1;
      NSHeadObjectID := -1;
    end;

    q.Close;
    q.SQL.Text :=
      'INSERT INTO gd_documenttype_option (id, dtkey, option_name, bool_value, relationfieldkey, contactkey, currkey, editiondate) ' +
      ' VALUES (:id, :dtkey, :option_name, :bool_value, :relationfieldkey, :contactkey, :currkey, :editiondate)';

    ConvertFields('INV_PRICE', 'HF', FHeaderFields);
    ConvertFields('INV_PRICELINE', 'LF', FLineFields);

    Tr.Commit;
  finally
    qFindObj.Free;
    qNS.Free;
    qRUID.Free;
    q.Free;
    Tr.Free;
  end;
end;

procedure TgdInvPriceDocumentEntry.LoadDE(Tr: TIBTransaction);
begin
  SetLength(FHeaderFields, 0);
  SetLength(FLineFields, 0);
  inherited;
end;

procedure TgdInvPriceDocumentEntry.LoadDEOption(qOpt: TIBSQL);
var
  P, PL: TatRelation;
  F: TatRelationField;
  OptName: String;
  NewField: TgdcInvPriceField;
begin
  P := atDatabase.Relations.ByRelationName('INV_PRICE');
  PL := atDatabase.Relations.ByRelationName('INV_PRICELINE');
  Assert((P <> nil) and (PL <> nil));

  while (not qOpt.EOF) and (GetTID(qOpt.FieldbyName('dtkey')) = TypeID) do
  begin
    OptName := qOpt.FieldbyName('option_name').AsString;

    if OptName = 'HF' then
      F := P.RelationFields.ByID(GetTID(qOpt.FieldbyName('relationfieldkey')))
    else
      F := PL.RelationFields.ByID(GetTID(qOpt.FieldbyName('relationfieldkey')));

    if F <> nil then
    begin
      NewField.FieldName := F.FieldName;
      NewField.ContactKey := GetTID(qOpt.FieldbyName('contactkey'));
      NewField.CurrencyKey := GetTID(qOpt.FieldbyName('currkey'));

      if OptName = 'HF' then
      begin
        SetLength(FHeaderFields, Length(FHeaderFields) + 1);
        FHeaderFields[High(FHeaderFields)] := NewField;
      end else
      begin
        SetLength(FLineFields, Length(FLineFields) + 1);
        FLineFields[High(FLineFields)] := NewField;
      end;
    end;

    qOpt.Next;
  end;
end;

procedure TgdInvPriceDocumentEntry.ParseOptions;
var
  Version: String;
  SS: TStringStream;
  Reader: TReader;

  procedure ReadList(const ARelName: String; var L: TgdcInvPriceFields);
  var
    NewField: TgdcInvPriceField;
    R: OleVariant;
  begin
    try
      Reader.ReadListBegin;
      while not Reader.EndOfList do
      begin
        Reader.Read(NewField, SizeOf(TgdcInvPriceField));

        if atDatabase.FindRelationField(ARelName, NewField.FieldName) <> nil then
        begin
          if (NewField.ContactKey > 0) and (not gdcBaseManager.ExecSingleQueryResult(
            'SELECT id FROM gd_contact WHERE id = :id', TID2V(NewField.ContactKey), R)) then
          begin
            NewField.ContactKey := -1;
          end;

          if (NewField.CurrencyKey > 0) and (not gdcBaseManager.ExecSingleQueryResult(
            'SELECT id FROM gd_curr WHERE id = :id', TID2V(NewField.CurrencyKey), R)) then
          begin
            NewField.CurrencyKey := -1;
          end;

          SetLength(L, Length(L) + 1);
          L[Length(L) - 1] := NewField;
        end;
      end;
      Reader.ReadListEnd;
    except
    end;
  end;

begin
  if Options = '' then
    exit;

  SS := TStringStream.Create(Options);
  Reader := TReader.Create(SS, 1024);
  with Reader do
  try
    Version := ReadString;

    // ��� ��������� ���������
    if Version <> gdcInvPrice_Version1_2 then
      ReadInteger;

    // ���� ������ �������
    if (Version = gdcInvPrice_Version1_1) or (Version = gdcInvPrice_Version1_2) then
      ReadTID(Reader);

    // ��������� ����� �����-�����
    ReadList('INV_PRICE', FHeaderFields);

    // ��������� ������� �����-�����
    ReadList('INV_PRICELINE', FLineFields);
  finally
    Reader.Free;
    SS.Free;
  end;
end;

destructor TgdBaseEntry.Destroy;
begin
  FgdFieldDefs.Free;
  inherited;
end;

procedure TgdBaseEntry.LoadFieldDefs;
var
  Obj: TgdcBase;
  RN, FN: String;
  BERef: TgdBaseEntry;
  I, NavStart, NavEnd: Integer;
  FD: TgdFieldDef;
  RFD: TgdRefFieldDef;
  RF: TatRelationField;
begin
  FgdFieldDefs.Free;
  FgdFieldDefs := TgdFieldDefs.Create(True);

  if gdcClass.IsAbstractClass and (gdcClass.GetListTable('') = '') then
    exit;

  NavStart := 0;
  NavEnd := 0;

  Obj := gdcClass.Create(nil);
  try
    Obj.SubType := SubType;
    Obj.SubSet := 'All';
    Obj.Open;

    for I := 0 to Obj.Fields.Count - 1 do
    begin
      {$IFDEF ID64}
      if Obj.Fields[I].DataType in [ftLargeInt] then
      {$ELSE}
      if Obj.Fields[I].DataType in [ftInteger] then
      {$ENDIF}
      begin
        ParseFieldOrigin(Obj.Fields[I].Origin, RN, FN);
        RF := atDatabase.FindRelationField(RN, FN);
        if (RF <> nil) and (RF.References <> nil) then
        begin
          BERef := gdClassList.FindByRelation(RF.References.RelationName);

          if BERef <> nil then
          begin
            RFD := TgdRefFieldDef.Create;
            RFD.InitFieldDef(Obj.Fields[I]);
            if (Parent is TgdBaseEntry) and (TgdBaseEntry(Parent).IndexOfFieldDef(RFD.Name) > -1) then
              RFD.InheritedField := True;
            RFD.RefClassName := BERef.TheClass.ClassName;
            RFD.RefSubType := BERef.SubType;
            FgdFieldDefs.Insert(NavEnd, RFD);
            Inc(NavEnd);
            continue;
          end;
        end;
      end;

      FD := TgdFieldDef.Create;
      FD.InitFieldDef(Obj.Fields[I]);
      if (Parent is TgdBaseEntry) and (TgdBaseEntry(Parent).IndexOfFieldDef(FD.Name) > -1) then
        FD.InheritedField := True;
      FgdFieldDefs.Insert(NavStart, FD);
      Inc(NavStart);
      Inc(NavEnd);
    end;
  finally
    Obj.Free;
  end;
end;

{ TgdFieldDef }

procedure TgdFieldDef.ODataBuild(SL: TStringList);
begin
  if not FInheritedField then
  begin
    SL.Add(
      '<Property Name="' + FName + '"' +
      GetFieldType +
      GetNullable +
      '/>');
  end;    
end;

function TgdFieldDef.GetFieldType: String;
var
  T, S: String;
begin
  S := '';
  case FDataType of
    ftInteger, ftSmallInt: T := 'Edm.Int32';
    ftLargeInt: T := 'Edm.Int64';
    ftString, ftMemo, ftFixedChar, ftWideString:
    begin
      T := 'Edm.String';
      S := ' MaxLength="' + IntToStr(FSize) + '"';
    end;
    ftDate: T := 'Edm.Date';
    ftTime: T := 'Edm.TimeOfDay';
    ftDateTime: T := 'Edm.DateTimeOffset';
    ftFloat: T := 'Edm.Double';
    ftBoolean: T := 'Edm.Boolean';
    ftBlob: T := 'Edm.Binary';
    ftBCD:
    begin
      T := 'Edm.Decimal';
      S := ' Scale="4"';
    end;
  else
    raise Exception.Create('Unsupported data type');
  end;

  Result := ' Type="' + T + '"' + S;
end;

function TgdFieldDef.GetNullable: String;
begin
  if FRequired then
    Result := ' Nullable="false"'
  else
    Result := '';
end;

procedure TgdFieldDef.InitFieldDef(F: TField);
begin
  FRequired := F.Required;
  FSize := F.Size;
  FOrigin := F.Origin;
  FName := F.Name;
  FDataType := F.DataType;
end;

procedure TgdBaseEntry.ODataBuild(SL, SL2: TStringList);

  function GetBaseType: String;
  begin
    {if Parent is TgdBaseEntry then
    begin
      Result := ' BaseType="' + ODataNSDot + Parent.TheClass.ClassName +
        TgdBaseEntry(Parent).SubType + '"';
    end else}
      Result := '';
  end;

  function GetAbstract: String;
  begin
    if gdcClass.IsAbstractClass then
      Result := ' Abstract="true"'
    else
      Result := '';
  end;

var
  I: Integer;
begin
  if gdcClass.IsAbstractClass and (gdcClass.GetListTable('') = '') then
    SL.Add('<EntityType Name="' + TheClass.ClassName + SubType + '"' +
      GetBaseType + GetAbstract + ' />')
  else begin
    if FgdFieldDefs = nil then
      LoadFieldDefs;

    SL.Add('<EntityType Name="' + TheClass.ClassName + SubType + '"' +
      GetBaseType + GetAbstract + '>');
    SL.Add('<Key><PropertyRef Name="ID" /></Key>');

    for I := 0 to FgdFieldDefs.Count - 1 do
      (FgdFieldDefs[I] as TgdFieldDef).ODataBuild(SL);

    SL.Add('</EntityType>');

    SL2.Add('<EntitySet Name="s' + TheClass.ClassName + SubType +
      '" EntityType="' + ODataNSDot + TheClass.ClassName + SubType + '" />');
    //SL2.Add('</EntitySet>');  
  end;
end;

{ TgdRefFieldDef }

procedure TgdRefFieldDef.ODataBuild(SL: TStringList);
begin
  if not FInheritedField then
  begin
    SL.Add(
      '<NavigationProperty Name="' + FName + '"' +
      ' Type="' + ODataNSDot + FRefClassName + FRefSubType + '"' +
      GetNullable +
      '/>');
  end;
end;

{ TgdFieldDefs }

function TgdFieldDefs.IndexOf(const AName: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if (Items[I] as TgdFieldDef).Name = AName then
    begin
      Result := I;
      break;
    end;
end;

function TgdBaseEntry.IndexOfFieldDef(const AName: String): Integer;
begin
  if gdcClass.IsAbstractClass and (gdcClass.GetListTable('') = '') then
    Result := -1
  else begin
    if FgdFieldDefs = nil then
      LoadFieldDefs;
    Result := FgdFieldDefs.IndexOf(AName);
  end;
end;

function TgdBaseEntry.GetEntitySetName: String;
begin
  Result := 's' + gdcClass.ClassName + SubType;
end;

function TgdBaseEntry.GetEntitySetUrl: String;
begin
  if SubType > '' then
    Result := gdcClass.ClassName + '+' + SubType
  else
    Result := gdcClass.ClassName;
end;

{ TgdAttrUserDefinedEntry }

class function TgdAttrUserDefinedEntry.CheckSubType(
  const ASubType: TgdcSubType): Boolean;
begin
  Result := (StrIPos('USR$', ASubType) = 1)
    and (Length(ASubType) <= cstMetaDataNameLength);
end;

initialization
  gdcObjectList := TObjectList.Create(False);

finalization
  FreeAndNil(gdcObjectList);
  FreeAndNil(_gdClassList);

{$IFDEF METHODSCHECK}
  if dbgMethodList <> nil then
  begin
    try
      dbgMethodList.SaveToFile(ExtractFilePath(Application.ExeName) + 'MethodList.txt');
    except
    end;
    dbgMethodList.Free;
  end;
{$ENDIF}

{$IFDEF DEBUG}
  Assert(glbParamCount = 0, '������� �� ��� ���������');
  Assert(glbMethodCount = 0, '������� �� ��� ������');
  Assert(glbMethodListCount = 0, '������� �� ��� m-list');
  Assert(glbClassMethodCount = 0, '������� �� ��� CM');
  Assert(glbClassListCount = 0, '������� �� ��� CL');
{$ENDIF}
end.

