
{++

  Copyright (c) 2001-2015 by Golden Software of Belarus

  Module

    at_classes.pas

  Abstract

    Abstract classes that provide information
    about interbase database structure
    and structure of user defined tables and fields
    called attributes.

  Author

    Kireev Andrei  (06.11.2000)
    Denis Romanovskki

  Revisions history

    1.0    ~.01.2002    JKL    Interface was separated.

--}

unit at_classes;

interface

uses
  ComCtrls, DB, IBSQL, Contnrs, gd_security_OperationConst, Classes, IBDatabase;

const
  UserPrefix            = 'USR$';  //��������������� ����-������
  SystemPrefix          = 'RDB$';  //��������� ����-������
  BooleanDomainName     = 'DBOOLEAN';
  BoolNotNullDomainName = 'DBOOLEAN_NOTNULL';
  CrossTablePrefix      = 'USR$CROSS';

type
  TFieldAlignment   = (faLeft, faRight, faCenter, faJustify);
  TatTreeNodeType   = (tntNameAndLocalization, tntLocalization, tntName);
  TUpdateDeleteRule = (udrUnknown, udrRestrict, udrNoAction, udrSetNull, udrSetDefault, udrCascade);

  TatNumerationInfo = record
    Value: String[1];
    Name: String;
  end;

  TarNumeration = array of TatNumerationInfo;

  TatRelationField = class;
  TatRelationFields = class;
  TatPrimaryKey = class;
  TatForeignKey = class;
  TatRelation = class;
  TatDatabase = class;

  TatField = class(TObject)
  private

  protected
    FID: Integer;
    FFieldName: String;

    FHasRecord: Boolean;
    FIsDropped: Boolean;

    FLName: String;
    FDescription: String;
    FAlignment: TFieldAlignment;
    FFormatString: String;
    FVisible: Boolean;
    FColWidth: Smallint;
    FReadOnly: Boolean;

    FgdSubType: String;
    FgdClassName: String;
    FgdClass: TClass;

    FDisabled: Boolean;
    FTreeNode: TTreeNode;

    FSQLType: Smallint;
    FSQLSubType: Smallint;
    FFieldLength: Smallint;
    FFieldScale: Smallint;
    FIsNullable: Boolean;

    FRefCondition: String;
    FRefListFieldName: String;
    FRefTableName: String;
    FRefTable: TatRelation;
    FRefListField: TatRelationField;

    FSetCondition: String;
    FSetListFieldName: String;
    FSetTableName: String;
    FSetTable: TatRelation;
    FSetListField: TatRelationField;

    FNumerations: TarNumeration;

    function GetIsUserDefined: Boolean; virtual; abstract;
    function GetFieldType: TFieldType; virtual; abstract;
    function GetIsSystem: Boolean; virtual; abstract;

  public
    procedure RefreshData; overload; virtual; abstract;
    procedure RefreshData(SQLRecord: TIBXSQLDA); overload; virtual; abstract;
    procedure RefreshData(aDatabase: TIBDatabase; aTransaction: TIBTransaction); overload; virtual; abstract;

    procedure RecordAcquired; virtual; abstract;

    function GetNumerationName(const Value: String): String; virtual; abstract;
    function GetNumerationValue(const NameNumeration: String): String; virtual; abstract;

    property ID: Integer read FID;
    property FieldName: String read FFieldName;
    property FieldType: TFieldType read GetFieldType;
    property SQLType: Smallint read FSQLType write FSQLType; // see IBHeader for constants
    property SQLSubType: Smallint read FSQLSubType;
    property FieldLength: Smallint read FFieldLength;
    property FieldScale: Smallint read FFieldScale;
    property IsNullable: Boolean read FIsNullable;
    property IsUserDefined: Boolean read GetIsUserDefined;
    property IsSystem: Boolean read GetIsSystem;
    property Numerations: TarNumeration read FNumerations;

    property Description: String read FDescription;
    property LName: String read FLName;

    property Alignment: TFieldAlignment read FAlignment;
    property ColWidth: Smallint read FColWidth;
    property Disabled: Boolean read FDisabled;
    property FormatString: String read FFormatString;
    property Visible: Boolean read FVisible;
    property ReadOnly: Boolean read FReadOnly;

    property gdClassName: String read FgdClassName;
    property gdSubType: String read FgdSubType;

    property RefTableName: String read FRefTableName;
    property RefTable: TatRelation read FRefTable;
    property RefListFieldName: String read FRefListFieldName;
    property RefListField: TatRelationField read FRefListField;
    property RefCondition: String read FRefCondition;

    property SetTableName: String read FSetTableName;
    property SetTable: TatRelation read FSetTable;
    property SetListFieldName: String read FSetListFieldName;
    property SetListField: TatRelationField read FSetListField;
    property SetCondition: String read FSetCondition;

    property HasRecord: Boolean read FHasRecord;
    property IsDropped: Boolean read FIsDropped;

  end;

  TatFields = class(TObject)
  private

  protected
    function GetCount: Integer; virtual; abstract;
    function GetItems(Index: Integer): TatField; virtual; abstract;
  public
    procedure RefreshData; overload; virtual; abstract;
    procedure RefreshData(aDatabase: TIBDatabase; aTransaction: TIBTransaction); overload; virtual; abstract;

    function Add(atField: TatField): Integer; virtual; abstract;
    function ByFieldName(const AFieldName: String): TatField; virtual; abstract;
    function ByID(const AID: Integer): TatField; virtual; abstract;
    procedure Delete(const Index: Integer); virtual; abstract;
    function FindFirst(const AFieldName: String): TatField; virtual; abstract;
    function IndexOf(AObject: TObject): Integer; virtual; abstract;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TatField read GetItems; default;

  end;

  TatRelationType = (rtTable, rtView);

  TatRelation = class(TObject)
  protected
    FID: Integer;
    FRelationName: String;
    FLName: String;
    FTreeNode: TTreeNode;
    FHasRecord: Boolean;
    FRelationFields: TatRelationFields;
    FLShortName: String;
    FDescription: String;
    FDatabase: TatDatabase;
    FPrimaryKey: TatPrimaryKey;
    FRelationType: TatRelationType;

    FaFull, FaChag, FaView: TSecurityDescriptor;
    FRelationFormat: Integer;
    FRelationID: Integer;

    FIsDropped: Boolean;
    FBranchKey: Integer;

    FListField: String;
    FExtendedFields: String;

    function GetIsUserDefined: Boolean; virtual; abstract;
    function GetIsSystem: Boolean; virtual; abstract;
    function GetHasSecurityDescriptors: Boolean; virtual; abstract;
    function GetListField: TatRelationField; virtual; abstract;
    function GetIsStandartRelation: Boolean; virtual; abstract;
    function GetIsStandartTreeRelation: Boolean; virtual; abstract;
    function GetIsLBRBTreeRelation: Boolean; virtual; abstract;

  public
    procedure RefreshData(const IsRefreshFields: Boolean = False); overload; virtual; abstract;
    procedure RefreshData(SQLRecord: TIBXSQLDA; aDatabase: TIBDatabase;
      aTransaction: TIBTransaction; const IsRefreshFields: Boolean = False); overload; virtual; abstract;
    procedure RefreshData(aDatabase: TIBDatabase; aTransaction: TIBTransaction;
      const IsRefreshFields: Boolean = False); overload; virtual; abstract;

    procedure RefreshConstraints; overload; virtual; abstract;
    procedure RefreshConstraints(aDatabase: TIBDatabase; aTransaction: TIBTransaction); overload; virtual; abstract;

    procedure RecordAcquired; virtual; abstract;

    //���������� �������, ���� ��������� ���� �������� ������ ���� ����,
    //� ��� �������� �������
    function GetReferencesRelation: TatRelation; virtual; abstract;

    property RelationType: TatRelationType read FRelationType;
    property IsStandartRelation: Boolean read GetIsStandartRelation;
    property IsStandartTreeRelation: Boolean read GetIsStandartTreeRelation;
    property IsLBRBTreeRelation: Boolean read GetIsLBRBTreeRelation;

    property ID: Integer read FID;
    property RelationName: String read FRelationName;
    property HasRecord: Boolean read FHasRecord;
    property IsUserDefined: Boolean read GetIsUserDefined;
    property IsSystem: Boolean read GetIsSystem;
    property HasSecurityDescriptors: Boolean read GetHasSecurityDescriptors;

    property Description: String read FDescription;
    property LName: String read FLName;
    property LShortName: String read FLShortName;

    property RelationFields: TatRelationFields read FRelationFields;
    property PrimaryKey: TatPrimaryKey read FPrimaryKey;

    property RelationFormat: Integer read FRelationFormat;
    property RelationID: Integer read FRelationID;

    property ListField: TatRelationField read GetListField;
    property ExtendedFields: String read FExtendedFields;

    property aFull: TSecurityDescriptor read FaFull;
    property aChag: TSecurityDescriptor read FaChag;
    property aView: TSecurityDescriptor read FaView;

    property IsDropped: Boolean read FIsDropped;
    property BranchKey: Integer read FBranchKey;
  end;

  TatRelations = class(TObject)
  protected
    FTreeNode: TTreeNode;

    function GetCount: Integer; virtual; abstract;
    function GetItems(Index: Integer): TatRelation; virtual; abstract;

  public
    procedure RefreshData(const WithCommit: Boolean = True; const IsRefreshFields: Boolean = False); overload; virtual; abstract;
    procedure RefreshData(aDatabase: TIBDatabase; aTransaction: TIBTransaction;
      const isRefreshFields: Boolean = False);
      overload; virtual; abstract;

    function Add(atRelation: TatRelation): Integer; virtual; abstract;
    procedure Delete(Index: Integer); virtual; abstract;
    function Remove(atRelation: TatRelation): Integer; virtual; abstract;

    function ByRelationName(const ARelationName: String): TatRelation; virtual; abstract;
    function ByID(const aID: Integer): TatRelation; virtual; abstract;
    function FindFirst(const ARelationName: String): TatRelation; virtual; abstract;
    function IndexOf(AObject: TObject): Integer; virtual; abstract;

    procedure NotifyUpdateObject(const ARelationName: String); virtual; abstract;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TatRelation read GetItems; default;
  end;

  TatRelationField = class(TObject)
  protected
    FID: Integer;
    FRelation: TatRelation;
    FFieldName: String;

    FHasRecord: Boolean;

    FLName: String;
    FLShortName: String;
    FDescription: String;
    FAlignment: TFieldAlignment;
    FFormatString: String;
    FColWidth: Smallint;
    FReadOnly: Boolean;

    FgdSubType: String;
    FgdClassName: String;
    FgdClass: TClass;

    FAFull, FAChag, FAView: TSecurityDescriptor;

    FFieldPosition: Integer;

    FField: TatField;

    FReferences: TatRelation;
    FReferencesField: TatRelationField;
    FForeignKey: TatForeignKey;

    FCrossRelationName: String;
    FCrossRelation: TatRelation;
    FCrossRelationField: TatRelationField;
    FCrossRelationFieldName: String;

    FIsDropped: Boolean;
    FIsComputed: Boolean;

    FObjectsList: TStringList;

    FDefaultValue: String;
    FHasDefault: Boolean;
    FIsNullable: Boolean;
    FIsSecurityDescriptor: Boolean;

    function GetIsUserDefined: Boolean; virtual; abstract;
    function GetSQLType: Smallint; virtual; abstract;
    function GetReferenceListField: TatRelationField; virtual; abstract;
    function GetVisible: Boolean; virtual; abstract;
    procedure SetFieldName(const AFieldName: String); virtual; abstract;

  public
    procedure RefreshData; overload; virtual; abstract;
    procedure RefreshData(aDatabase: TIBDatabase; aTransaction: TIBTransaction); overload; virtual; abstract;
    procedure RefreshData(SQLRecord: TIBXSQLDA; aDatabase: TIBDatabase; aTransaction: TIBTransaction); overload; virtual; abstract;

    procedure RecordAcquired; virtual; abstract;

    function InObject(const AName: String): Boolean; virtual; abstract;

    property ID: Integer read FID;
    property FieldName: String read FFieldName write SetFieldName;
    property SQLType: Smallint read GetSQLType;
    property IsUserDefined: Boolean read GetIsUserDefined;

    property Relation: TatRelation read FRelation;
    property Field: TatField read FField;

    property LName: String read FLName;
    property Description: String read FDescription;
    property LShortName: String read FLShortName;

    property Alignment: TFieldAlignment read FAlignment;
    property ColWidth: Smallint read FColWidth;
    property FieldPosition: Integer read FFieldPosition;
    property FormatString: String read FFormatString;
    property Visible: Boolean read GetVisible;
    property ReadOnly: Boolean read FReadOnly;
    property IsNullable: Boolean read FIsNullable;

    property gdClassName: String read FgdClassName;
    property gdClass: TClass read FgdClass;
    property gdSubType: String read FgdSubType;

    property References: TatRelation read FReferences;
    property ReferencesField: TatRelationField read FReferencesField;
    property ForeignKey: TatForeignKey read FForeignKey;
    property ReferenceListField: TatRelationField read GetReferenceListField;

    property CrossRelation: TatRelation read FCrossRelation;
    property CrossRelationName: String read FCrossRelationName;
    property CrossRelationField: TatRelationField read FCrossRelationField;
    property CrossRelationFieldName: String read FCrossRelationFieldName;

    property aFull: TSecurityDescriptor read FaFull;
    property aChag: TSecurityDescriptor read FaChag;
    property aView: TSecurityDescriptor read FaView;

    property HasRecord: Boolean read FHasRecord;

    property IsDropped: Boolean read FIsDropped;

    property IsSecurityDescriptor: Boolean read FIsSecurityDescriptor;

    property IsComputed: Boolean read FIsComputed;
    property HasDefault: Boolean read FHasDefault;
    property DefaultValue: String read FDefaultValue;

    property ObjectsList: TStringList read FObjectsList;
  end;

  TatRelationFields = class(TObject)
  protected
    FRelation: TatRelation;
    FSorted: Boolean;

    function GetCount: Integer; virtual; abstract;
    function GetItems(Index: Integer): TatRelationField; virtual; abstract;
  public

    procedure RefreshData; overload; virtual; abstract;
    procedure RefreshData(aDatabase: TIBDatabase; aTransaction: TIBTransaction);
      overload; virtual; abstract;

    function Add(atRelationField: TatRelationField): Integer; virtual; abstract;
    function AddRelationField(const AFieldName: String): TatRelationField; virtual; abstract;
    function ByFieldName(const AName: String): TatRelationField; virtual; abstract;
    function ByID(const aID: Integer): TatRelationField; virtual; abstract;
    function ByPos(const APosition: Integer): TatRelationField; virtual; abstract;
    procedure Delete(const Index: Integer); virtual; abstract;
    function IndexOf(AObject: TObject): Integer; virtual; abstract;

    property Relation: TatRelation read FRelation write FRelation;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TatRelationField read GetItems; default;

    property Sorted: Boolean read FSorted write FSorted;
  end;

  TatForeignKey = class(TObject)
  private

  protected
    FConstraintName: String;
    FIndexName: String;

    FRelation: TatRelation;
    FReferencesRelation: TatRelation;

    FConstraintFields: TatRelationFields;
    FReferencesFields: TatRelationFields;

    FReferencesIndex: String;

    FIsDropped: Boolean;

    FUpdateRule, FDeleteRule: TUpdateDeleteRule;

    function GetConstraintField: TatRelationField; virtual; abstract;
    function GetReferencesField: TatRelationField; virtual; abstract;

    function GetIsSimpleKey: Boolean; virtual; abstract;
  public
    procedure RefreshData; overload; virtual; abstract;
    procedure RefreshData(ibsql: TIBSQL); overload; virtual; abstract;
    procedure RefreshData(aDatabase: TIBDatabase; aTransaction: TIBTransaction); overload; virtual; abstract;

    property ConstraintName: String read FConstraintName;

    property IndexName: String read FIndexName;

    property Relation: TatRelation read FRelation;
    property ReferencesRelation: TatRelation read FReferencesRelation;

    property IsSimpleKey: Boolean read GetIsSimpleKey;

    property ConstraintField: TatRelationField read GetConstraintField;
    property ReferencesField: TatRelationField read GetReferencesField;

    property ConstraintFields: TatRelationFields read FConstraintFields;
    property ReferencesFields: TatRelationFields read FReferencesFields;

    property ReferencesIndex: String read FReferencesIndex;

    property IsDropped: Boolean read FIsDropped;
    property UpdateRule: TUpdateDeleteRule read FUpdateRule;
    property DeleteRule: TUpdateDeleteRule read FDeleteRule;
  end;

  TatForeignKeys = class(TObject)
  private

  protected
    function GetCount: Integer; virtual; abstract;
    function GetItems(Index: Integer): TatForeignKey; virtual; abstract;
    function Find(const S: string; var Index: Integer): Boolean; virtual; abstract;

  public
    function Add(atForeignKey: TatForeignKey): Integer; virtual; abstract;
    procedure Delete(const Index: Integer); virtual; abstract;
    function ByConstraintName(AConstraintName: String): TatForeignKey; virtual; abstract;
    function ByRelationAndReferencedRelation(const ARelationName,
      AReferencedRelationName: String): TatForeignKey; virtual; abstract;
    function IndexOf(AObject: TObject): Integer; virtual; abstract;

    // ���������� ������ ������-���� ��� �������� �������
    procedure ConstraintsByRelation(const RelationName: String;
      List: TObjectList); virtual; abstract;
    // ���������� ������ ������-����, ����������� �� ��������
    // �������
    procedure ConstraintsByReferencedRelation(const RelationName: String;
      List: TObjectList; const ClearList: Boolean = True;
      const IncludeRefTables: Boolean = True;
      const IncludeSetTables: Boolean = True); virtual; abstract;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TatForeignKey read GetItems; default;
  end;

  TatPrimaryKey = class(TObject)
  private

  protected
    FIndexName: String;
    FConstraintName: String;
    FRelation: TatRelation;
    FConstraintFields: TatRelationFields;

    FIsDropped: Boolean;

  public
    procedure RefreshData; overload; virtual; abstract;
    procedure RefreshData(ibsql: TIBSQL); overload; virtual; abstract;
    procedure RefreshData(aDatabase: TIBDatabase; aTransaction: TIBTransaction); overload; virtual; abstract;

    property Relation: TatRelation read FRelation;
    property ConstraintName: String read FConstraintName;
    property IndexName: String read FIndexName;
    property ConstraintFields: TatRelationFields read FConstraintFields;

    property IsDropped: Boolean read FIsDropped;
  end;

  TatPrimaryKeys = class(TObject)
  private

  protected
    function GetCount: Integer; virtual; abstract;
    function GetItems(Index: Integer): TatPrimaryKey; virtual; abstract;

  public
    function Add(atPrimaryKey: TatPrimaryKey): Integer; virtual; abstract;
    procedure Delete(const Index: Integer); virtual; abstract;
    function ByConstraintName(AConstraintName: String): TatPrimaryKey; virtual; abstract;
    function IndexOf(AObject: TObject): Integer; virtual; abstract;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TatPrimaryKey read GetItems; default;
  end;

  TatDatabase = class(TObject)
  private
    function GetInMultiConnection: Boolean;

  protected
    FRelations: TatRelations;
    FFields: TatFields;
    FForeignKeys: TatForeignKeys;
    FPrimaryKeys: TatPrimaryKeys;

    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    FLoaded: Boolean;
    FLoading: Boolean;
    FMultiConnectionTransaction: Integer;

    FGarbageCount: Integer;
    FDialect: Integer;

    function GetReadOnly: Boolean; virtual; abstract;
    procedure SetDatabase(Value: TIBDatabase); virtual; abstract;
    procedure SetTransaction(Value: TIBTransaction); virtual; abstract;

  public

    procedure IncrementGarbageCount;

    procedure ProceedLoading(Force: Boolean = False); virtual; abstract;
    procedure ForceLoadFromDatabase; virtual; abstract;

    function FindRelationField(const ARelationName, ARelationFieldName: String): TatRelationField; virtual; abstract;

    procedure NotifyMultiConnectionTransaction; virtual; abstract;
    procedure CancelMultiConnectionTransaction(const All: Boolean = False); virtual; abstract;

    function StartMultiConnectionTransaction: Boolean; virtual; abstract;
    procedure CheckMultiConnectionTransaction; virtual; abstract;

    property MultiConnectionTransaction: Integer read FMultiConnectionTransaction;

    property Relations: TatRelations read FRelations;
    property Fields: TatFields read FFields;
    property ForeignKeys: TatForeignKeys read FForeignKeys;
    property PrimaryKeys: TatPrimaryKeys read FPrimaryKeys;

    property Database: TIBDatabase read FDatabase write SetDatabase;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;

    property ReadOnly: Boolean read GetReadOnly;
    property Loaded: Boolean read FLoaded;
    property Loading: Boolean read FLoading;
    property Dialect: Integer read FDialect write FDialect;

    property InMultiConnection: Boolean read GetInMultiConnection;

    //��������� ������������� �������� � ���������
    procedure SyncIndicesAndTriggers(ATransaction: TIBTransaction); virtual; abstract;

    //���������� ������  �����-������ (CL) ��� ������ �� ������ RL �� ����-������ �� ���������
    procedure GetCrossByRelationName(RL: TStrings; CL: TStrings); virtual; abstract;
  end;

function StringToFieldAlignment(const S: String): TFieldAlignment;
function FieldAlignmentToString(const FA: TFieldAlignment): String;
function FieldAlignmentToAlignment(const FA: TFieldAlignment): TAlignment;
function CheckEnName(const AName: String): Boolean;
function StringToUpdateDeleteRule(const S: String): TUpdateDeleteRule;

var
  atDatabase: TatDatabase;

implementation

uses
  SysUtils;

function FieldAlignmentToAlignment(const FA: TFieldAlignment): TAlignment;
begin
  case FA of
    faLeft: Result := taLeftJustify;
    faRight: Result := taRightJustify;
    faCenter: Result := taCenter;
    faJustify: Result := taCenter;
  else
    Result := taLeftJustify;
  end;
end;

function StringToFieldAlignment(const S: String): TFieldAlignment;
begin
  Assert(Length(S) > 0);
  case S[1] of
  'L': Result := faLeft;
  'R': Result := faRight;
  'C': Result := faCenter;
  'J': Result := faJustify;
  else
    raise Exception.Create('Invalid field alignment string.');
  end;
end;

function FieldAlignmentToString(const FA: TFieldAlignment): String;
begin
  case FA of
  faLeft: Result := 'L';
  faRight: Result := 'R';
  faCenter: Result := 'C';
  faJustify: Result := 'J';
  end;
end;

function CheckEnName(const AName: String): Boolean;
var
  I: Integer;
begin
  Result := True;

  if AName > '' then
  begin
    for I := 1 to Length(AName) do
      if not (AName[I] in ['A'..'Z', 'a'..'z', '_', '$', '0'..'9'])  then
      begin
        Result := False;
        break;
      end;
  end;
end;

function StringToUpdateDeleteRule(const S: String): TUpdateDeleteRule;
begin
  if S = 'CASCADE' then Result := udrCascade
  else if S = 'RESTRICT' then Result := udrRestrict
  else if S = 'NO ACTION' then Result := udrNoAction
  else if S = 'SET NULL' then Result := udrSetNull
  else if S = 'SET DEFAULT' then Result := udrSetNull
  else
    raise Exception.Create('Invalid update or delete rule.');
end;

{ TatDatabase }

function TatDatabase.GetInMultiConnection: Boolean;
begin
{FMultiConnectionTransaction - ���� ���������������.
������������� ������� ��� ���������� �������� ��������� ����������������.
��������! �������� ����� ���� ������ �����, � ���� ��������� ����������� �� �������.}
  Result := FMultiConnectionTransaction > 0;
end;

procedure TatDatabase.IncrementGarbageCount;
begin
  Inc(FGarbageCount);
end;

end.

