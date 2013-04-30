
{++


  Copyright (c) 2001-2009 by Golden Software of Belarus

  Module

    gdcMetaData.pas

  Abstract

    Gedemin class for user defined tables.

  Author

    Anton Smirnov,
    Denis Romanovski,
    Michael Shoihet,
    Teryokhina Julia

  Revisions history

    1.0    13.11.2001   sai        Initial version.
    2.0    05.12.2001   dennis     Rewritten.
    3.0    10.01.2001   michael    ��������� �������� ���������� ����� � ��
    4.0    08.05.2002   Julia      ��������� ������ TgdcException, TgdcIndex
    4.1    17.05.2002   Julia      �������� ����� TgdcTrigger
    4.2    30.06.2007   Alexandra
                        Alexander  �������� ����� TgdcGenerator
    4.3.   03.10.2007   Alexander  �������� ����� TgdcCheckConstraint
--}

unit gdcMetaData;

interface

uses
  Windows, Classes, Contnrs, IBCustomDataSet, gdcBase, Forms, gd_createable_form,
  at_classes, SysUtils, IBSQL, Db, IBDatabase, gdcBaseInterface, gd_KeyAssoc;

type
  TgdcOnCustomTable = procedure (Sender: TObject; Scripts: TStringList) of object;
  TgdcTableType = (ttUnknow, ttSimpleTable, ttTree, ttIntervalTree, ttCustomTable,
    ttDocument, ttDocumentLine, ttInvSimple, ttInvFeature, ttInvInvent, ttInvTransfrom,
    ttTableToTable, ttPrimeTable);

const
  gdcUserTablesBranchKey = 710000;

type
  TSQLProcessList = class
  private
    FScriptList: TStringList;
    FSuccessfulList: TStringList;
    function GetScript(Index: Integer): String;
    function GetSuccessful(Index: Integer): Integer;
    function GetCount: Integer;

  public
    constructor Create;
    destructor Destroy; override;

    property Script[Index: Integer]: String read GetScript; default;
    property Successful[Index: Integer]: Integer read GetSuccessful;
    property Count: Integer read GetCount;

    procedure Add(const Script: String; const Successful: Boolean = True);
    procedure Delete(Index: Integer);
    procedure Clear;
  end;

  TgdcMetaBase = class(TgdcBase)
  private
    FPostedID: Integer;

  protected
    //���������� ��� �������� ����-������
    //���������, ����� �� ����������� � ����������� ������
    NeedSingleUser: Boolean;

    function GetIsUserDefined: Boolean; virtual;
    function CheckTheSameStatement: String; override;

    procedure ShowSQLProcess(S: TSQLProcessList);

    procedure SaveToStreamDependencies(Stream: TStream;
      ObjectSet: TgdcObjectSet; ADependent_Name: String;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); virtual;

    //��������� ����� �������
    //���������, ����� ����� ���� ���������� ����� ������� � ������ ������
    //�� ��������� ��������� ����� ������� � ������
    function GetCanCreate: Boolean; override;
    function GetCanDelete: Boolean; override;
    function GetCanEdit: Boolean; override;

    function GetRelationName: String; virtual;

    procedure DoAfterTransactionEnd(Sender: TObject); override;
    procedure DoAfterPost; override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function CommitRequired: Boolean; override;
    class function GetSubSetList: String; override;
    class function IsAbstractClass: Boolean; override;
    class function NeedModifyFromStream(const SubType: String): Boolean; override;

    function GetDialogDefaultsFields: String; override;

    property IsUserDefined: Boolean read GetIsUserDefined;
    property RelationName: String read GetRelationName;
  end;

  TgdcRelationField = class;
  TgdcTableField = class;

  CgdcTable = class of TgdcTable;

  TgdcField = class(TgdcMetaBase)
  private
    procedure MetaDataCreate;
    procedure Drop;

  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    function CreateDialogForm: TCreateableForm; override;

    procedure _DoOnNewRecord; override;
    procedure DoBeforePost; override;

    procedure CustomDelete(Buff: Pointer); override;
    procedure CustomInsert(Buff: Pointer); override;

    procedure GetWhereClauseConditions(S: TStrings); override;

    function CheckTheSameStatement: String; override;
    function GetIsUserDefined: Boolean; override;

    function GetCanDelete: Boolean; override;

  public
    constructor Create(AnOwner: TComponent); override;

    function GetDomainText(const WithCharSet: Boolean = True; const OnlyDataType: Boolean = False): String;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray;
      const SaveDetailObjects: Boolean = True); override;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcFieldInfo = class(TgdcMetaBase)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    function CreateDialogForm: TCreateableForm; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;
  end;


  TgdcRelation = class(TgdcMetaBase)
  protected
    FTableType: TgdcTableType;

    function CreateGrantSQL: String;

    procedure CreateRelationSQL(Scripts: TSQLProcessList); virtual; abstract;

    procedure MetaDataCreate;

    function GetSelectClause: String; override;
    function CreateDialogForm: TCreateableForm; override;

{    function DoesExplorerCommandExist: Boolean;
    procedure CreateExplorerCommand;
    procedure DeleteExplorerCommand;    }

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomDelete(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    function CheckTheSameStatement: String; override;
    function GetIsUserDefined: Boolean; override;

    procedure _DoOnNewRecord; override;
    procedure DoBeforePost; override;
    procedure CreateFields; override;

    function GetTableType: TgdcTableType; virtual; abstract;

    procedure GetWhereClauseConditions(S: TStrings); override;

    function GetCanDelete: Boolean; override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetListFieldExtended(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;

    class function GetSubSetList: String; override;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;

    function GetCurrRecordClass: TgdcFullClass; override;

    property TableType: TgdcTableType read GetTableType;

    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;

    //��������� ����������� ���������� �������. ������������ ������� �� ������� ������
    procedure TestRelationName;

    class function IsAbstractClass: Boolean; override;

  end;

  TgdcBaseTable = class(TgdcRelation)
  private
    FOnCustomTable: TgdcOnCustomTable;
    FgdcTableField: TgdcTableField;
    FAdditionCreateField: TStringList;
    FNeedPredefinedFields: Boolean;

    function GetgdcTableField: TgdcTableField;

  protected
    procedure DropTable; virtual;
    procedure DropCrossTable;
    function CreateInsertTrigger: String;
    function CreateEditorForeignKey: String;
    function CreateInsertEditorTrigger: String;
    function CreateUpdateEditorTrigger: String;

    function CreateDialogForm: TCreateableForm; override;

    procedure _DoOnNewRecord; override;
    procedure CustomDelete(Buff: Pointer); override;
    procedure CustomInsert(Buff: Pointer); override;

    function GetTableType: TgdcTableType; override;

    procedure NewField(FieldName, LName, FieldSource, Description,
      LShortName, Alignment, ColWidth, ReadOnly, Visible: String);

    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function GetCurrRecordClass: TgdcFullClass; override;

    procedure MakePredefinedRelationFields; virtual;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    //������� ���������� ���� ����� �������, ������� ������ � �������� ���
    class function GetPrimaryFieldName: String; virtual;

    property gdcTableField: TgdcTableField read GetgdcTableField;
    property AdditionCreateField: TStringList read FAdditionCreateField write FAdditionCreateField;

    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;

  published
    property OnCustomTable: TgdcOnCustomTable read FOnCustomTable
      write FOnCustomTable;
  end;

  //������������ ��� ������ � �����-��������� ��� �������� �� �� ������
  TgdcUnknownTable = class(TgdcBaseTable)
  private
    function CreateUnknownTable: String;
    function GetSimulateFieldName: String;

  protected
    procedure CreateRelationSQL(Scripts: TSQLProcessList); override;

  public
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
    procedure MakePredefinedRelationFields; override;

    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;
  end;


  TgdcTable = class(TgdcBaseTable)
  end;

  TgdcPrimeTable = class(TgdcTable)
  private
    function CreatePrimeTable: String;

  protected
    procedure CreateRelationSQL(Scripts: TSQLProcessList); override;
    procedure _DoOnNewRecord; override;

  public
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;

  end;

  TgdcSimpleTable = class(TgdcTable)
  private
    function CreateSimpleTable: String;

  protected
    procedure CreateRelationSQL(Scripts: TSQLProcessList); override;
    procedure _DoOnNewRecord; override;

  public
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
    procedure MakePredefinedRelationFields; override;
  end;

  TgdcTableToTable = class(TgdcTable)
  private
    FIDDomain: String;

    function CreateSimpleTable: String;
    function CreateNewDomain: String;
    function CreateForeignKey: String;

  protected
    procedure DropTable; override;
    procedure CreateRelationSQL(Scripts: TSQLProcessList); override;
    procedure CustomInsert(Buff: Pointer); override;

    procedure _DoOnNewRecord; override;

    function GetReferenceName: String;

  public
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;

    property ReferenceName: String read GetReferenceName;// write SetReferenceName;
  end;

  TgdcTreeTable = class(TgdcTable)
  private
    function CreateTreeTable: String;

  protected
    procedure CreateRelationSQL(Scripts: TSQLProcessList); override;
    procedure _DoOnNewRecord; override;

  public
     class function GetDisplayName(const ASubType: TgdcSubType): String; override;
     procedure MakePredefinedRelationFields; override;
  end;

  TgdcLBRBTreeTable = class(TgdcTable)
  private
    function CreateIntervalTreeTable: String;

  protected
     procedure DropTable; override;

     procedure CreateRelationSQL(Scripts: TSQLProcessList); override;
     procedure _DoOnNewRecord; override;

  public
     class function GetDisplayName(const ASubType: TgdcSubType): String; override;
     procedure MakePredefinedRelationFields; override;

     procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
       PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
       WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;
  end;

  TgdcView = class(TgdcRelation)
  private
    function CreateView: String;
    procedure DropView(ViewCreateList: TStringList);
    procedure AddRelationField;
    procedure RemoveRelationField;

  protected
    procedure CreateRelationSQL(Scripts: TSQLProcessList); override;

    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure _DoOnNewRecord; override;

    function CreateDialogForm: TCreateableForm; override;

    procedure CustomDelete(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;
    procedure CustomInsert(Buff: Pointer); override;

    function GetTableType: TgdcTableType; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;

    procedure ReCreateView;

    function GetViewTextBySource(const Source: String): String;
    function GetAlterViewTextBySource(const Source: String): String;
  end;


  TgdcRelationField = class(TgdcMetaBase)
  private
    FCrossRelationID: String;
    FChangeComputed: Boolean;

    function GetKeyName(IsPrimary: Boolean; ARelationName: String;
      UniqueID: String): String;

    function NextCrossRelationName: String;

    function CreateFieldSQL: String;
    function CreateFieldConstraintSQL: String;
    function CreateDropFieldConstraintSQL: String;
    function CreateDefaultSQL(DefaultValue: String): String;

    function CreateCrossRelationSQL: String;
    function CreateCrossRelationTriggerSQL: String;
    function CreateCrossRelationPrimarySQL: String;
    function CreateCrossRelationForeign1SQL: String;
    function CreateCrossRelationForeign2SQL: String;
    function CreateDropCrossSimulateField: String;
    function CreateCrossRelationGrantSQL: String;

    procedure CreateInvCardTrigger(ResultList: TSQLProcessList;
      const IsDrop: Boolean = False);

    procedure AlterAcEntryBalanceAndRecreateTrigger(ResultList: TSQLProcessList; const IsDrop: Boolean = False);

    function CreateAccCirculationList(const IsDrop: Boolean = False): String;

    function CreateDropFieldSQL: String;
    function CreateDropCrossTableSQL: String;
    function CreateDropTriggerSQL: String;

    procedure DropField;
    procedure AddField;
    procedure UpdateField;

  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetOrderClause: String; override;

    function CreateDialogForm: TCreateableForm; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;
    procedure CustomDelete(Buff: Pointer); override;

    procedure _DoOnNewRecord; override;
    procedure DoBeforePost; override;
    procedure DoBeforeEdit; override;
    procedure DoAfterEdit; override;
    procedure CreateFields; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

    function CheckTheSameStatement: String; override;
    function GetIsUserDefined: Boolean; override;

    function GetCanDelete: Boolean; override;
    function GetCanEdit: Boolean; override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetSubSetList: String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetListFieldExtended(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;

    property ChangeComputed: Boolean read FChangeComputed write FChangeComputed;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;

    function GetCurrRecordClass: TgdcFullClass; override;

    function ReadObjectState(AFieldId, AClassName: String): Integer;

  end;


  TgdcTableField = class(TgdcRelationField)
  private
    //������������ ��� �������� �� ������������ ������������ ��� CachedUpdates
    FFieldList: TStringList;

  protected
    procedure _DoOnNewRecord; override;
    procedure DoBeforeInsert; override;
    procedure DoBeforePost; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    function CheckFieldName: Boolean;
  end;


  TgdcViewField = class(TgdcRelationField)
  protected
    procedure CustomDelete(Buff: Pointer); override;
    procedure _DoOnNewRecord; override;

  public
    constructor Create(AnOwner: TComponent); override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcStoredProc = class(TgdcMetaBase)
  private
    IsSaveToStream: Boolean;
    procedure SaveStoredProc(const isNew: Boolean);
    procedure DropStoredProc;

    function GetParamsText: String;

  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function CreateDialogForm: TCreateableForm; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;
    procedure CustomDelete(Buff: Pointer); override;

    procedure GetWhereClauseConditions(S: TStrings); override;

    procedure _DoOnNewRecord; override;
    procedure DoBeforePost; override;

    function CheckTheSameStatement: String; override;

    function GetCanEdit: Boolean; override;
    function GetCanDelete: Boolean; override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    function GetCreateProcedureText: String;
    function GetAlterProcedureText: String;

    procedure PrepareToSaveToStream(BeforeSave: Boolean);
    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcException = class(TgdcMetaBase)
  private
    procedure MetaDataCreate;
    procedure MetaDataAlter;
    procedure Drop;

  protected
    function CreateDialogForm: TCreateableForm; override;
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomDelete(Buff: Pointer); override;
    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    procedure DoBeforePost; override;

    function CheckTheSameStatement: String; override;

    function GetCanDelete: Boolean; override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcIndex = class(TgdcMetaBase)
  private
    //���� ��� ������������� � �����
    IsSync: Boolean;
    FChangeActive: Boolean;

    //������������ ��� �������� �� ������������ ������������ ��� CachedUpdates
    FIndexList: TStringList;

    procedure MetaDataCreate;
    procedure MetaDataAlter;
    procedure Drop;

  protected
    function CreateDialogForm: TCreateableForm; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetSelectClause: String; override;

    procedure CustomDelete(Buff: Pointer); override;
    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    procedure DoBeforeOpen; override;
    procedure DoAfterOpen; override;
    procedure _DoOnNewRecord; override;
    procedure DoBeforeEdit; override;
    procedure DoBeforeInsert; override;
    procedure DoBeforePost; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

    function CheckTheSameStatement: String; override;

    procedure SaveToStreamDependencies(Stream: TStream;
      ObjectSet: TgdcObjectSet; ADependent_Name: String;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;

    function GetCanDelete: Boolean; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;

    class function GetSubSetList: String; override;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;

    procedure SyncIndices(const ARelationName: String; const NeedRefresh: Boolean = True);
    procedure SyncAllIndices(const NeedRefresh: Boolean = True);

    property ChangeActive: Boolean read FChangeActive write FChangeActive;

    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;

    function CheckIndexName: Boolean;
  end;

  TgdcTrigger = class(TgdcMetaBase)
  private
    //���� ��� ������������� � �����
    IsSync: Boolean;
    FChangeName: Boolean;

    procedure MetaDataCreate;
    procedure MetaDataAlter;
    procedure Drop;

  protected
    function CreateDialogForm: TCreateableForm; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetSelectClause: String; override;

    procedure CustomDelete(Buff: Pointer); override;
    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    procedure DoBeforeEdit; override;
    procedure DoBeforeOpen; override;
    procedure DoBeforePost; override;
    procedure _DoOnNewRecord; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

    function CheckTheSameStatement: String; override;

    function GetCanDelete: Boolean; override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetSubSetList: String; override;

    procedure SyncTriggers(const ARelationName: String; const NeedRefresh: Boolean = True);
    procedure SyncAllTriggers(const NeedRefresh: Boolean = True);

    function CalcPosition(RelationName: String; TriggerType: Integer): Integer;

    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcCheckConstraint = class(TgdcMetaBase)
  private
    FChangeName: Boolean;

    procedure MetaDataCreate;
    procedure MetaDataAlter;
    procedure Drop;
  protected
    function CreateDialogForm: TCreateableForm; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetSelectClause: String; override;

    procedure CustomDelete(Buff: Pointer); override;
    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    procedure _DoOnNewRecord; override;    
    procedure DoBeforeEdit; override;
    procedure DoBeforePost; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

    function CheckTheSameStatement: String; override;

    function GetCanDelete: Boolean; override;
    function GetCanEdit: Boolean; override;    
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;

    class function GetSubSetList: String; override;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;

    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;

    function CheckName: Boolean;
  end;


  TgdcGenerator = class(TgdcMetaBase)
  private
    FChangeName: Boolean;

    procedure MetaDataCreate;
    procedure MetaDataAlter;
    procedure Drop;

  protected
    function CreateDialogForm: TCreateableForm; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetSelectClause: String; override;

    procedure CustomDelete(Buff: Pointer); override;
    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    procedure DoBeforeEdit; override;
    procedure DoBeforePost; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

    function CheckTheSameStatement: String; override;
    function GetCanDelete: Boolean; override;
    function GetCanEdit: Boolean; override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

   // procedure SyncGenerators(const NeedRefresh: Boolean = True);

    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
  end;

  EgdcIBError = class(Exception);

  procedure Register;
  function GetKeyFieldName(const ARelationName: String): String;
  function GetTableTypeByName(const ARelationName: String): TgdcTableType;
  function GetDefValueInQuotes(const DefaultValue: String): String;
  function GetSimulateFieldNameByRel(RelName: String): String;

const
//����� ����� ����-������
  cstMetaDataNameLength = 31;
  MaxInvCardTrigger = 5;

implementation

uses
  gdc_frmField_unit, gdc_frmRelation_unit, gdc_frmTable_unit,

  gdc_dlgField_unit, gdc_dlgRelation_unit, gdc_dlgRelationField_unit,

  at_frmSQLProcess, at_frmIBUserList, gd_security, gdc_attr_dlgView_unit,

  gdc_attr_frmStoredProc_unit, gdc_attr_dlgStoredProc_unit,

  gd_ClassList, IBHeader, Graphics, dmDatabase_unit, at_sql_parser,

  jclStrings, gdc_attr_dlgException_unit, gdc_frmException_unit,

  gdc_attr_dlgIndices_unit, gdc_attr_dlgTrigger_unit,

  gdc_attr_frmTrigger_unit, gdc_attr_frmIndices_unit, Dialogs, ib,

  at_sql_setup, IBQuery, gd_directories_const, gdcInvDocumentCache_unit,

  gdc_attr_dlgGenerator_unit, gdc_attr_frmGenerator_unit, gdc_attr_frmCheckConstraint_unit,

  gdc_attr_dlgCheckConstraint_unit, gdcLBRBTreeMetaData
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

var
//���������, ��� ���� ������������� �������� �������� USR$_BU_INV_CARD
//����� ���� ������ ������ � ������ ��������������� � ��
  InvCardTriggerImitate: array[1..MaxInvCardTrigger] of Boolean;
//���������, ��� ���� ������������� �������� �������� USR$_BU_INV_CARD
//����� ���� ������ ������ � ������ ��������������� � ��
  InvCardTriggerDrop: array[1..MaxInvCardTrigger] of Boolean;

procedure Register;
begin
  RegisterComponents(
    'gdcMetaData',
    [
      TgdcField, TgdcRelation, TgdcTable,
      TgdcView, TgdcRelationField, TgdcTableField, TgdcViewField, TgdcStoredProc,
      TgdcException, TgdcIndex, TgdcTrigger, TgdcPrimeTable, TgdcGenerator, TgdcCheckConstraint
    ]
  );
end;

function GetFieldType(const AnID: Integer): Integer;
var
  Obj: TgdcField;
begin
  Obj := TgdcField.CreateSubType(nil, '', 'ByID');
  try
    Obj.ID := AnID;
    Obj.Open;
    if Obj.RecordCount > 0 then
      Result := Obj.FieldByName('ffieldtype').AsInteger
    else
      Result := -1;
  finally
    Obj.Free;
  end;
end;

//������� ���������� �������� ������ ����� �� �������� ������� � ����
function GetForeignName(const ATableName, ForeignField: String): String;
begin
  if AnsiPos(UserPrefix, ATableName) = 1 then
  begin
    Result := 'USR$FK_' + Copy(ATableName, 5, Length(ATableName) - 4) + '_' + ForeignField;
  end else
  begin
    Result := Copy(ATableName, 1, AnsiPos('_', ATableName)) + 'FK_' +
      Copy(ATableName, AnsiPos('_', ATableName) + 1, Length(ATableName) - AnsiPos('_', ATableName)) +
      '_' + ForeignField;
  end;

  if Length(Result) > cstMetaDataNameLength then
    Result := gdcBaseManager.AdjustMetaName(Result);
end;

//������� ���������� �������� �������� �� �������� ������� � �������
function GetTriggerName(const ATableName, APosition: String; PosNumber: Integer): String;
begin
  if AnsiPos(UserPrefix, ATableName) = 1 then
  begin
    Result := 'USR$' + APosition + '_' + Copy(ATableName, 5, Length(ATableName) - 4) + IntToStr(PosNumber);
  end else
  begin
    Result := Copy(ATableName, 1, AnsiPos('_', ATableName)) + APosition + '_'  +
      Copy(ATableName, AnsiPos('_', ATableName) + 1, Length(ATableName) - AnsiPos('_', ATableName)) +
      IntToStr(PosNumber);
  end;

  if Length(Result) > cstMetaDataNameLength then
    Result := gdcBaseManager.AdjustMetaName(Result);
end;

// ���������� ������������� ��� Interbase-������ ����
function GetUniqueID(D: TIBDatabase; T: TIBTransaction;
  GenName: String = 'gd_g_triggercross'): String;
var
  ibsqlWork: TIBSQL;
  DidActivate: Boolean;
begin
  DidActivate := not T.InTransaction;
  ibsqlWork := TIBSQL.Create(nil);
  try
    ibsqlWork.Database := D;
    ibsqlWork.Transaction := T;
    if DidActivate then T.StartTransaction;
    ibsqlWork.SQL.Text := Format(
      'SELECT GEN_ID(%s, 1) FROM rdb$database', [GenName]
    );
    ibsqlWork.ExecQuery;
    Result := ibsqlWork.Fields[0].AsString;
  finally
    ibsqlWork.Close;
    ibsqlWork.Free;

    if DidActivate then
      T.Commit;
  end;
end;

{ TgdcField }

constructor TgdcField.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpModify, cpDelete];
end;

function TgdcField.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCFIELD', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFIELD', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFIELD',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFIELD' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dlgField.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFIELD', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFIELD', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcField.CustomDelete(Buff: Pointer);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  DelFieldName: String;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCFIELD', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFIELD', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFIELD',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  DelFieldName := FieldByName('fieldname').AsString;
  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('fieldname').AsString)) = 0 then
    raise EgdcIBError.Create('�� �� ������ ������� ����������������� �����!');
  Drop;

  if Assigned(atDatabase) then
    atDatabase.IncrementGarbageCount;

  inherited;

  if Assigned(atDatabase) and Assigned(atDatabase.Fields.ByFieldName(DelFieldName)) and
    not (atDatabase.InMultiConnection) then
    atDatabase.Fields.Delete(atDatabase.Fields.IndexOf(atDatabase.Fields.ByFieldName(DelFieldName)));

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFIELD', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFIELD', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcField.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCFIELD', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFIELD', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFIELD',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if AnsiPos(UserPrefix, AnsiUpperCase(Trim(FieldByName('fieldname').AsString))) = 1 then
    MetaDataCreate;

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFIELD', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFIELD', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcField._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCFIELD', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFIELD', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFIELD',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  FieldByName('alignment').AsString := 'L';
  FieldByName('visible').AsString := '1';
  FieldByName('readonly').AsString := '0';

  FieldByName('fieldname').AsString := '';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFIELD', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFIELD', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcField.Drop;
var
  FSQL: TSQLProcessList;
begin
  FSQL := TSQLProcessList.Create;
  try
    FSQL.Add(Format('DROP DOMAIN %s', [FieldByName('fieldname').AsString]));
    ShowSQLProcess(FSQL);
  finally
    FSQL.Free;
  end;
end;

function TgdcField.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCFIELD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFIELD', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFIELD',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFIELD' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'FROM at_fields z ' +

    '  LEFT JOIN at_relations refr ON ' +
    '    z.reftablekey = refr.id ' +

    '  LEFT JOIN at_relation_fields refrf ON ' +
    '    z.reflistfield = refrf.fieldname ' +
    '      AND ' +
    '    refrf.relationkey = refr.id ' +

    '  LEFT JOIN at_relations setr ON ' +
    '    z.settablekey = setr.id ' +

    '  LEFT JOIN at_relation_fields setrf ON ' +
    '    z.setlistfieldkey = setrf.id ' +
    '      AND ' +
    '    setrf.relationkey = setr.id ' +

    '  LEFT JOIN rdb$fields rdb ON z.fieldname = rdb.rdb$field_name ' +

    '    LEFT JOIN ' +
    '      RDB$CHARACTER_SETS CS ' +
    '    ON ' +
    '      rdb.RDB$CHARACTER_SET_ID = CS.RDB$CHARACTER_SET_ID ' +

    '    LEFT JOIN ' +
    '      RDB$COLLATIONS CL ' +
    '    ON ' +
    '      rdb.RDB$COLLATION_ID = CL.RDB$COLLATION_ID ' +
    '        AND ' +
    '      rdb.RDB$CHARACTER_SET_ID = CL.RDB$CHARACTER_SET_ID ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFIELD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFIELD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcField.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcField.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'LNAME';
end;

class function TgdcField.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'AT_FIELDS';
end;

function TgdcField.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCFIELD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFIELD', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFIELD',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFIELD' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'SELECT ' +
    '  z.*, refr.lname as reflname, refrf.lname as reflistlname, ' +
    '  setr.lname as setlistlname, rdb.rdb$null_flag AS FLAG, ' +

    '  rdb.rdb$field_type as ffieldtype, ' +
    '  rdb.rdb$field_sub_type as fsubtype, ' +
    '  rdb.rdb$field_precision as fprecision, ' +
    '  rdb.rdb$field_scale as fscale, ' +
    '  rdb.rdb$field_length as flength, ' +
    '  rdb.rdb$character_length as fcharlength, ' +
    '  rdb.rdb$segment_length as seglength, ' +

    '  rdb.rdb$validation_source AS checksource, ' +
    '  rdb.rdb$default_source as defsource, ' +

    '  rdb.rdb$computed_source as computed_value, ' +

    '  cs.rdb$character_set_name AS charset, ' +
    '  cl.rdb$collation_name AS collation ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFIELD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFIELD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcField.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('OnlyAttribute') then
    S.Add('z.fieldname LIKE ''USR$%''');
  if HasSubSet('ByFieldName') then
    S.Add('z.fieldname = :fieldname  ')
  else
    if not HasSubSet('ByID') then
      S.Add('NOT (z.fieldname LIKE ''RDB$%'') ');
end;

function TgdcField.GetDomainText(const WithCharSet: Boolean = True; const OnlyDataType: Boolean = False): String;

  function FormFloatDomain(dsDomain: TIBCustomDataSet): String;
  var
    fscale: Integer;
  begin
    if dsDomain.FieldByName('fsubtype').AsInteger = 1 then
     Result := 'NUMERIC'
    else
     Result := 'DECIMAL';

    if dsDomain.FieldByName('fscale').AsInteger < 0 then
     fscale := -dsDomain.FieldByName('fscale').AsInteger
    else
     fscale := dsDomain.FieldByName('fscale').AsInteger;

    if dsDomain.FieldByName('fprecision').AsInteger = 0 then
     Result := Format('%s(9, %s)',
        [Result, IntToStr(fscale)])
    else
     Result := Format('%s(%s, %s)',
        [Result, dsDomain.FieldByName('fprecision').AsString, IntToStr(fscale)]);
  end;

  function GetDomain (dsDomain: TIBCustomDataSet): String;
  var
    S, S1: String;
    Stream: TStringStream;
  begin
    case dsDomain.FieldByName('ffieldtype').AsInteger of

    blr_Text, blr_varying:
      begin
        if dsDomain.FieldByName('ffieldtype').AsInteger = blr_Text then
          Result := 'CHAR'
        else
          Result := 'VARCHAR';
          
        // ��������� ����� ���� (http://tracker.firebirdsql.org/browse/CORE-2228)
        if dsDomain.FieldByName('fcharlength').AsInteger > 0 then
          Result := Format('%s(%s)', [Result, dsDomain.FieldByName('fcharlength').AsString])
        else
          Result := Format('%s(%s)', [Result, dsDomain.FieldByName('flength').AsString]);

        if WithCharSet and (dsDomain.FieldByName('CHARSET').AsString <> '') then
        begin
          Result := Format('%s CHARACTER SET %s',
            [Result, Trim(dsDomain.FieldByName('CHARSET').AsString)]);
        end;
      end;

    blr_d_float, blr_double, blr_float:
      Result := 'DOUBLE PRECISION';

    blr_int64:
      if (dsDomain.FieldByName('fsubtype').AsInteger > 0) or
        (dsDomain.FieldByName('fprecision').AsInteger > 0) or
        (dsDomain.FieldByName('fscale').AsInteger < 0) then
      begin
        Result := FormFloatDomain(dsDomain)
      end else
        Result := 'BIGINT';

    blr_long:
      if (dsDomain.FieldByName('fsubtype').AsInteger > 0) or
        (dsDomain.FieldByName('fprecision').AsInteger > 0) or
        (dsDomain.FieldByName('fscale').AsInteger < 0) then
      begin
        Result := FormFloatDomain(dsDomain)
      end else
        Result := 'INTEGER';

    blr_short:
      if (dsDomain.FieldByName('fsubtype').AsInteger > 0) or
        (dsDomain.FieldByName('fprecision').AsInteger > 0) or
        (dsDomain.FieldByName('fscale').AsInteger < 0) then
      begin
        Result := FormFloatDomain(dsDomain)
      end else
        Result := 'SMALLINT';

    blr_sql_time:
      Result := 'TIME';

    blr_sql_date:
      Result := 'DATE';

    blr_timestamp:
      Result := 'TIMESTAMP';

    blr_blob:
      begin
        Result := 'BLOB';
        Result := Format
        (
          ' %s SUB_TYPE %s SEGMENT SIZE %s',
          [
            Result,
            dsDomain.FieldByName('fsubtype').AsString,
            dsDomain.FieldByName('seglength').AsString
          ]
        );
        if WithCharSet and (dsDomain.FieldByName('CHARSET').AsString <> '') then
        begin
          Result := Format('%s CHARACTER SET %s',
            [Result, dsDomain.FieldByName('CHARSET').AsString]);
        end;

      end;
    else
      raise EgdcIBError.Create('����������� ��� ������');
    end;

    // ������������� �������� �� ���������
    if (not OnlyDataType) and (dsDomain.FieldByName('defsource').AsString <> '') then
    begin
      if AnsiPos('DEFAULT', AnsiUpperCase(Trim(dsDomain.FieldByName('defsource').AsString))) <> 1 then
        Result := Result + ' DEFAULT ' + GetDefValueInQuotes(dsDomain.FieldByName('defsource').AsString)
      else
        Result := Result + ' ' + dsDomain.FieldByName('defsource').AsString;
    end;

    // ������������� �������� NOT NULL
    if (not OnlyDataType) and (dsDomain.FieldByName('flag').AsInteger = 1) then
      Result := Result + ' NOT NULL';

    // ���� ������������ �����������
    if not OnlyDataType then
    begin
      if dsDomain.FieldByName('checksource').AsString <> '' then
      begin
        if Pos('CHECK', dsDomain.FieldByName('checksource').AsString) = 0 then
          Result := Result + ' CHECK' + '(' + dsDomain.FieldByName('checksource').AsString + ')'
        else
          Result := Result + ' ' + dsDomain.FieldByName('checksource').AsString;
      end
      else
        if not dsDomain.FieldByName('numeration').IsNull then
        begin
          if dsDomain.FieldByName('flag').AsInteger = 0 then
            Result := Result + ' CHECK ((VALUE IS NULL) OR (VALUE IN ( '
          else
            Result := Result + ' CHECK ((VALUE IN ( ';
          Stream := TStringStream.Create(dsDomain.FieldByName('numeration').AsString);
          try
            S := Stream.ReadString(Stream.Size);
            while S <> '' do
            begin
              S1 := System.copy(S, 1, 1);
              if Pos(#13#10, S) > 0 then
                S := System.copy(S, Pos(#13#10, S) + 2, Length(S))
              else
                S := '';
              if S <> '' then
                Result := Result + '''' + S1 + ''','
              else
                Result := Result + '''' + S1 + '''';
            end;
            Result := Result + ')))';
          finally
            Stream.Free;
          end;
        end;
    end;

    // ������������� COLLATION ��� ��������� �����
    if WithCharSet and (dsDomain.FieldByName('collation').AsString <> '') and
      (dsDomain.FieldByName('ffieldtype').AsInteger <> blr_blob)
    then
    begin
      if Pos('COLLATE', AnsiUpperCase(dsDomain.FieldByName('collation').AsString)) = 0 then
        Result := Result + ' COLLATE ' + dsDomain.FieldByName('collation').AsString
      else
        Result := Result + dsDomain.FieldByName('collation').AsString;
    end;

    Result := Trim(Result);
  end;

var
  qry: TIBDataSet;
  DidActivate: Boolean;

begin
  if (RecordCount > 0) or (State = dsInsert) then
    Result := GetDomain(Self)
  else if HasSubSet('ByFieldName') and Active then
  begin
    qry := TIBDataSet.Create(nil);
    try
      qry.Transaction := Transaction;
      DidActivate := False;
      try
        DidActivate := ActivateTransaction;
        qry.SelectSQL.Text := 'SELECT ' +
          '  z.*, refr.lname as reflname, refrf.lname as reflistlname, ' +
          '  setr.lname as setlistlname, rdb.rdb$null_flag AS flag, ' +

          '  rdb.rdb$field_type as ffieldtype, ' +
          '  rdb.rdb$field_sub_type as fsubtype, ' +
          '  rdb.rdb$field_precision as fprecision, ' +
          '  rdb.rdb$field_scale as fscale, ' +
          '  rdb.rdb$field_length as flength, ' +
          '  rdb.rdb$character_length as fcharlength, ' +
          '  rdb.rdb$segment_length as seglength, ' +

          '  rdb.rdb$validation_source AS checksource, ' +
          '  rdb.rdb$default_source as defsource, ' +

          '  rdb.rdb$computed_source as computed_value, ' +

          '  cs.rdb$character_set_name AS charset, ' +
          '  cl.rdb$collation_name AS collation ' +

          '  FROM rdb$fields rdb ' +

          '    LEFT JOIN ' +
          '      rdb$character_sets cs ' +
          '    ON ' +
          '      rdb.rdb$character_set_id = cs.rdb$character_set_id ' +

          '    LEFT JOIN ' +
          '      rdb$collations cl ' +
          '    ON ' +
          '      rdb.rdb$collation_id = cl.rdb$collation_id ' +
          '        AND ' +
          '      rdb.rdb$character_set_id = cl.rdb$character_set_id ' +

          '    LEFT JOIN at_fields z ON ' +
          '     rdb.rdb$field_name = z.fieldname ' +

          '    LEFT JOIN at_relations refr ON ' +
          '      z.reftablekey = refr.id ' +

          '    LEFT JOIN at_relation_fields refrf ON ' +
          '      z.reflistfield = refrf.fieldname ' +
          '        AND ' +
          '      refrf.relationkey = refr.id ' +

          '    LEFT JOIN at_relations setr ON ' +
          '      z.settablekey = setr.id ' +

          '    LEFT JOIN at_relation_fields setrf ON ' +
          '      z.setlistfieldkey = setrf.id ' +
          '        AND ' +
          '      setrf.relationkey = setr.id ' +

          ' WHERE rdb.rdb$field_name = :fieldname ';

        qry.ParamByName('fieldname').AsString := ParamByName('fieldname').AsString;
        qry.Open;

        Result := GetDomain(qry);

        if DidActivate and Transaction.InTransaction then
          Transaction.Commit;
      except
        if DidActivate and Transaction.InTransaction then
          Transaction.Rollback;
        raise;
      end;
    finally
      qry.Free;
    end;
  end
  else
    raise EgdcIBError.Create('����������� ��� ������');
end;

procedure TgdcField.MetaDataCreate;
var
  FSQL: TSQLProcessList;
begin
  FSQL := TSQLProcessList.Create;
  try
    FSQL.Add(Format ('CREATE DOMAIN %s AS %s',
      [ FieldByName('fieldname').AsString,
      GetDomainText]));
    ShowSQLProcess(FSQL);
  finally
    FSQL.Free;
    NeedSingleUser := False;
  end;
end;

function TgdcField.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCFIELD', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFIELD', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFIELD',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFIELD' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
//����������� ������ ���� �� ��������������
  if FieldByName(GetKeyField(SubType)).AsInteger < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT %s FROM %s WHERE UPPER(fieldname)=''%s'' ',
      [GetKeyField(SubType), GetListTable(SubType), AnsiUpperCase(FieldByName('fieldname').AsString)]);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFIELD', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFIELD', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

function TgdcField.GetIsUserDefined: Boolean;
begin
  Result := StrIPos(USERPREFIX, FieldByName('fieldname').AsString) = 1;
end;

class function TgdcField.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByFieldName;';
end;

function TgdcFieldInfo.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCFIELDINFO', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFIELDINFO', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFIELDINFO') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFIELDINFO',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFIELDINFO' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := nil;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFIELDINFO', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFIELDINFO', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

function TgdcFieldInfo.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCFIELDINFO', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFIELDINFO', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFIELDINFO') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFIELDINFO',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFIELDINFO' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'FROM ' +
    '  rdb$fields z ' +

    '    LEFT JOIN ' +
    '      rdb$character_sets cs ' +
    '    ON ' +
    '      z.rdb$character_set_id = cs.rdb$character_set_id ' +

    '    LEFT JOIN ' +
    '      rdb$collations cl ' +
    '    ON ' +
    '      z.rdb$collation_id = cl.rdb$collation_id ' +
    '        AND ' +
    '      z.rdb$character_set_id = cl.rdb$character_set_id ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFIELDINFO', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFIELDINFO', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcFieldInfo.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'rdb$field_name';
end;

class function TgdcFieldInfo.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcFieldInfo.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'rdb$fields';
end;

function TgdcFieldInfo.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCFIELDINFO', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFIELDINFO', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFIELDINFO') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFIELDINFO',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFIELDINFO' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'SELECT ' +
    '  z.rdb$field_name as name, ' +
    '  z.rdb$field_type as ffieldtype, ' +
    '  z.rdb$field_sub_type as fsubtype, ' +
    '  z.rdb$field_precision as fprecision, ' +
    '  z.rdb$field_scale as fscale, ' +
    '  z.rdb$field_length as flength, ' +
    '  z.rdb$character_length as fcharlength, ' +
    '  z.rdb$segment_length as seglength, ' +
    '  z.rdb$null_flag as nullflag, ' +

    '  z.rdb$validation_source AS checksource, ' +
    '  z.rdb$default_source as defsource, ' +

    '  cs.rdb$character_set_name AS charset, ' +
    '  cl.rdb$collation_name AS collation ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFIELDINFO', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFIELDINFO', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcFieldInfo.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('OnlyAttribute') then
    S.Add('z.rdb$field_name LIKE ''USR$%''');
  if HasSubSet('ByFieldName') then
    S.Add('z.rdb$field_name = :FieldName ');
end;

class function TgdcField.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmField';
end;

procedure TgdcField.DoBeforePost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  ibsql: TIBSQL;
  DidActivate: Boolean;
  S: String;
  I: Integer;

begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCFIELD', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFIELD', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFIELD',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('defsource').AsString := Trim(FieldByName('defsource').AsString);
  if not (sMultiple in BaseState) then
  begin
    if FieldByName('lname').AsString = '' then
      FieldByName('lname').AsString := Trim(FieldByName('fieldname').AsString);

    if FieldByName('description').AsString = '' then
      FieldByName('description').AsString := Trim(FieldByName('lname').AsString);

    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := Transaction;
      DidActivate := False;
      try
        DidActivate := ActivateTransaction;

        //��������� �������� ��� ������-������
        if (FieldByName('reftable').AsString > '') and
          (FieldByName('reftablekey').IsNull) then
        begin
          ibsql.Close;
          ibsql.SQL.Text := 'SELECT * FROM at_relations WHERE relationname = :RN';
          ibsql.ParamByName('RN').AsString := AnsiUpperCase(Trim(FieldByName('reftable').AsString));
          ibsql.ExecQuery;
          if ibsql.RecordCount > 0 then
            FieldByName('reftablekey').AsInteger := ibsql.FieldByName('id').AsInteger;
        end;

        if (Trim(FieldByName('reftable').AsString) = '') and
          (FieldByName('reftablekey').AsInteger > 0) then
        begin
          ibsql.Close;
          ibsql.SQL.Text := 'SELECT * FROM at_relations WHERE id = :id';
          ibsql.ParamByName('id').AsInteger := FieldByName('reftablekey').AsInteger;
          ibsql.ExecQuery;
          if ibsql.RecordCount > 0 then
            FieldByName('reftable').AsString := ibsql.FieldByName('relationname').AsString;
        end;

        //��������� �������� ��� �����-������
        if (FieldByName('reflistfield').AsString > '') and
          (FieldByName('reflistfieldkey').IsNull) then
        begin
          ibsql.Close;
          ibsql.SQL.Text := 'SELECT * FROM at_relation_fields WHERE relationname = :RN AND fieldname = :FN';
          ibsql.ParamByName('RN').AsString := AnsiUpperCase(Trim(FieldByName('reftable').AsString));
          ibsql.ParamByName('FN').AsString := AnsiUpperCase(Trim(FieldByName('reflistfield').AsString));
          ibsql.ExecQuery;
          if ibsql.RecordCount > 0 then
            FieldByName('reflistfieldkey').AsInteger := ibsql.FieldByName('id').AsInteger;
        end;

        if (Trim(FieldByName('reflistfield').AsString) = '') and
          (FieldByName('reflistfieldkey').AsInteger > 0) then
        begin
          ibsql.Close;
          ibsql.SQL.Text := 'SELECT * FROM at_relation_fields WHERE id = :id';
          ibsql.ParamByName('id').AsInteger := FieldByName('reflistfieldkey').AsInteger;
          ibsql.ExecQuery;
          if ibsql.RecordCount > 0 then
            FieldByName('reflistfield').AsString := ibsql.FieldByName('fieldname').AsString;
        end;

        //��������� �������� ��� ������-��������
        if (FieldByName('settable').AsString > '') and
          (FieldByName('settablekey').IsNull) then
        begin
          ibsql.Close;
          ibsql.SQL.Text := 'SELECT * FROM at_relations WHERE relationname = :RN';
          ibsql.ParamByName('RN').AsString := AnsiUpperCase(Trim(FieldByName('settable').AsString));
          ibsql.ExecQuery;
          if ibsql.RecordCount > 0 then
            FieldByName('settablekey').AsInteger := ibsql.FieldByName('id').AsInteger;
        end;

        if (Trim(FieldByName('settable').AsString) = '') and
          (FieldByName('settablekey').AsInteger > 0) then
        begin
          ibsql.Close;
          ibsql.SQL.Text := 'SELECT * FROM at_relations WHERE id = :id';
          ibsql.ParamByName('id').AsInteger := FieldByName('settablekey').AsInteger;
          ibsql.ExecQuery;
          if ibsql.RecordCount > 0 then
            FieldByName('settable').AsString := ibsql.FieldByName('relationname').AsString;
        end;

        //��������� �������� ��� �����-��������
        if (FieldByName('setlistfield').AsString > '') and
          (FieldByName('setlistfieldkey').IsNull) then
        begin
          ibsql.Close;
          ibsql.SQL.Text := 'SELECT * FROM at_relation_fields WHERE relationname = :RN AND fieldname = :FN';
          ibsql.ParamByName('RN').AsString := AnsiUpperCase(Trim(FieldByName('settable').AsString));
          ibsql.ParamByName('FN').AsString := AnsiUpperCase(Trim(FieldByName('setlistfield').AsString));
          ibsql.ExecQuery;
          if ibsql.RecordCount > 0 then
            FieldByName('setlistfieldkey').AsInteger := ibsql.FieldByName('id').AsInteger;
        end;

        if (Trim(FieldByName('setlistfield').AsString) = '') and
          (FieldByName('setlistfieldkey').AsInteger > 0) then
        begin
          ibsql.Close;
          ibsql.SQL.Text := 'SELECT * FROM at_relation_fields WHERE id = :id';
          ibsql.ParamByName('id').AsInteger := FieldByName('setlistfieldkey').AsInteger;
          ibsql.ExecQuery;
          if ibsql.RecordCount > 0 then
            FieldByName('setlistfield').AsString := ibsql.FieldByName('fieldname').AsString;
        end;

        if DidActivate and Transaction.InTransaction then
          Transaction.Commit;

      except
        if DidActivate and Transaction.InTransaction then
          Transaction.Rollback;
        raise;
      end;
    finally
      ibsql.Free;
    end;
  end;

  if (Trim(FieldByName('fieldname').AsString) = '') then
    raise Exception.Create('������� ������������ ������!');
 //  ��� ������� ������ ��������� ������
 //  ���������� �������
  S := Trim(AnsiUpperCase(FieldByName('fieldname').AsString));
   for I := 1 to Length(S) do
     if not (S[I] in ['A'..'Z', '_', '0'..'9', '$']) then
     begin
       FieldByName('fieldname').FocusControl;
       raise Exception.Create('�������� ������ ������ ���� �� ���������� �����!');
     end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFIELD', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFIELD', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcField._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet;
  PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True);
begin
  SaveToStreamDependencies(Stream, ObjectSet,
    FieldByName('fieldname').AsString, PropertyList, BindedList, WithDetailList, SaveDetailObjects);

  //��������� ������ �� ���������!
  if AnsiPos('RDB$', AnsiUpperCase(FieldByName('fieldname').AsString)) <> 1 then
    inherited;
end;

class function TgdcField.GetDisplayName(const ASubType: TgdcSubType): String;
begin
  Result := '�����';
end;

function TgdcField.GetCanDelete: Boolean;
begin
  Result := inherited GetCanDelete and Active and
    (AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('fieldname').AsString)) = 1);
end;

{ TgdcRelation }

constructor TgdcRelation.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpDelete, cpModify];
end;

function TgdcRelation.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCRELATION', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATION', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATION' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := nil;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATION', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATION', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcRelation._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCRELATION', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATION', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATION',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  FieldByName('relationname').AsString := '';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATION', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATION', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcRelation.GetCurrRecordClass: TgdcFullClass;
begin
  Result := inherited GetCurrRecordClass;
  if RecordCount > 0 then
  begin
    if FieldByName('relationtype').AsString = 'T' then
      Result.gdClass := CgdcBase(TgdcTable)
    else if FieldByName('relationtype').AsString = 'V' then
      Result.gdClass := CgdcBase(TgdcView);
    Result.SubType := '';  
  end;
end;

class function TgdcRelation.GetDisplayName(const ASubType: TgdcSubType): String;
begin
  Result := '������� � �������������';
end;

class function TgdcRelation.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'id';
end;

class function TgdcRelation.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'lname';
end;

class function TgdcRelation.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'at_relations';
end;

function TgdcRelation.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCRELATION', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATION', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATION' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetSelectClause;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATION', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATION', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcRelation.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('OnlyAttribute') then
    S.Add('z.relationname LIKE ''USR$%''');
  if HasSubSet('ByRelationName') then
    S.Add(' z.relationname = :relationname ');
end;

class function TgdcRelation.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByRelationName;';
end;

function TgdcRelation.CreateGrantSQL: String;
begin
  Result := Format
  (
    'GRANT ALL ON %s TO administrator',
    [FieldByName('relationname').AsString]
  );

end;


procedure TgdcRelation.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCRELATION', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATION', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATION',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('relationname').AsString)) = 1 then
    MetaDataCreate;

  inherited;

  atDatabase.Relations.RefreshData(Database, Transaction, True);
  Clear_atSQLSetupCache;

  if Assigned(gdcInvDocumentCache) then
    gdcInvDocumentCache.Clear;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATION', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATION', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcRelation.MetaDataCreate;
var
  FSQL: TSQLProcessList;
begin
  FSQL := TSQLProcessList.Create;
  try
    CreateRelationSQL(FSQL);
    ShowSQLProcess(FSQL);
  finally
    FSQL.Free;
    NeedSingleUser := False;
  end;
end;

function TgdcRelation.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCRELATION', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATION', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATION' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
//����������� ������ ���� �� ��������������
  if FieldByName(GetKeyField(SubType)).AsInteger < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT %s FROM %s WHERE UPPER(relationname)=''%s'' ',
      [GetKeyField(SubType), GetListTable(SubType), AnsiUpperCase(FieldByName('relationname').AsString)]);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATION', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATION', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

function TgdcRelation.GetIsUserDefined: Boolean;
begin
  Result := StrIPos(UserPrefix, FieldByName('relationname').AsString) = 1;
end;

procedure TgdcRelation.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCRELATION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATION', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATION',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

{  if ((TableType <> ttCustomTable) and (TableType <> ttUnknow))
    or (AnsiUpperCase(FieldByName('relationtype').AsString) = 'V')
  then
  begin
    if FieldByName('branchkey').AsInteger > 0 then
      CreateExplorerCommand
    else
      DeleteExplorerCommand;
  end;}

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcRelation.DoBeforePost;
var
  ibsql: TIBSQL;
  S: String;
  L: Integer;
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCRELATION', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATION', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATION',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  TestRelationName;

  inherited;

  if not (sMultiple in BaseState) then
  begin
    if FieldByName('lname').IsNull then
      FieldByName('lname').AsString := FieldByName('relationname').AsString;

    if FieldByName('lshortname').IsNull then
      FieldByName('lshortname').AsString := FieldByName('lname').AsString;

    if FieldByName('description').AsString = '' then
      FieldByName('description').AsString := FieldByName('lname').AsString;
  end;

  {  ���� �� � ��������� �������� �� ������, �������� �������� �� ������������ lname, lshortname
  ��� ������������ ������������, ��������������� ���
  �������� ���� ����� ������ � ����, ������� �����!!!}

  if (sLoadFromStream in BaseState) then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      if Transaction.InTransaction then
        ibsql.Transaction := Transaction
      else
        ibsql.Transaction := ReadTransaction;

      ibsql.SQL.Text := 'SELECT * FROM at_relations WHERE UPPER(lname) = :lname and id <> :id';
      ibsql.ParamByName('lname').AsString := AnsiUpperCase(FieldByName('lname').AsString);
      ibsql.ParamByName('id').AsInteger := ID;
      ibsql.ExecQuery;

      if ibsql.RecordCount > 0 then
      begin
        S := FieldByName('lname').AsString + FieldByName(GetKeyField(SubType)).AsString;
        L := Length(S);
        if L > 60 then
        begin
          S := System.Copy(FieldByName('lname').AsString, 1,
            L - Length(FieldByName(GetKeyField(SubType)).AsString)) +
            FieldByName(GetKeyField(SubType)).AsString;
        end;
        FieldByName('lname').AsString := S;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM at_relations WHERE UPPER(lshortname) = :lshortname and id <> :id';
      ibsql.ParamByName('lshortname').AsString := AnsiUpperCase(FieldByName('lshortname').AsString);
      ibsql.ParamByName('id').AsInteger := ID;
      ibsql.ExecQuery;

      if ibsql.RecordCount > 0 then
      begin
        S := FieldByName('lshortname').AsString + FieldByName(GetKeyField(SubType)).AsString;
        L := Length(S);
        if L > 60 then
        begin
          S := System.Copy(FieldByName('lshortname').AsString, 1,
            L - Length(FieldByName(GetKeyField(SubType)).AsString)) +
            FieldByName(GetKeyField(SubType)).AsString;
        end;
        FieldByName('lshortname').AsString := S;
      end;

      ibsql.Close;

    finally
      ibsql.Free;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATION', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATION', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

class function TgdcRelation.GetListFieldExtended(
  const ASubType: TgdcSubType): String;
begin
  Result := 'relationname';
end;

procedure TgdcRelation._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet;
  PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True);
var
  FgdcTrigger: TgdcTrigger;
  C: TgdcFullClass;
begin
  //����� ����������� � ����� ����� ���������������� ��������
  //�.�. ���������� � ��������� ����� �� ������ ��������� � �������
  //at_triggers
  C := GetCurrRecordClass;
  if ((not Assigned(ObjectSet)) or (ObjectSet.Find(ID) = -1))
    and ((Self.ClassType = C.gdClass) and (Self.SubType = C.SubType)) then
  begin
    FgdcTrigger := TgdcTrigger.Create(nil);
    try
      FgdcTrigger.Transaction := Transaction;
      FgdcTrigger.SyncTriggers(FieldByName('relationname').AsString);
    finally
      FgdcTrigger.Free;
    end;
  end;
  inherited;
end;

function TgdcRelation.GetCanDelete: Boolean;
begin
  Result := inherited GetCanDelete and Active and
    (AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('relationname').AsString)) = 1);
end;

procedure TgdcRelation.CustomDelete(Buff: Pointer);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  DelRelName: String;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCRELATION', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATION', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATION',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  DelRelName := FieldByName('relationname').AsString;

  inherited;

  Clear_atSQLSetupCache;

  if Assigned(atDatabase) and Assigned(atDatabase.Relations.ByRelationName(DelRelName)) and
    not (atDatabase.InMultiConnection) then
  begin
    atDatabase.Relations.Remove(atDatabase.Relations.ByRelationName(DelRelName));
  end;

  if Assigned(gdcInvDocumentCache) then
    gdcInvDocumentCache.Clear;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATION', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATION', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}

end;

procedure TgdcRelation.TestRelationName;
var
  S: String;
  I: Integer;
  Tbl: TatRelation;
begin
  if (State = dsInsert) and not(sLoadFromStream in BaseState) then
    with FieldByName('relationname') do
    try
      //  ��� ������� ������ ��������� ������
      //  ���������� �������
      S := Trim(AnsiUpperCase(AsString));
      if S = '' then
      begin
        FieldByName('relationname').FocusControl;
        raise Exception.Create('������� ������������ �������/�������������!');
      end;

      for I := 1 to Length(S) do
        if not (S[I] in ['A'..'Z', '_', '0'..'9', '$']) then
        begin
          FieldByName('relationname').FocusControl;
          raise Exception.Create('�������� ������ ���� �� ���������� �����!');
        end;

      //
      //  ���� ������� ������� ������������ �� ���������� -
      //  ������������ ��� ��������������

      if (AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('relationname').AsString)) <> 1)
      then
        FieldByName('relationname').AsString := UserPrefix + FieldByName('relationname').AsString;

      if (TableType <> ttUnknow) then
      begin
        if (AnsiPos('USR$CROSS', AnsiUpperCase(AsString)) = 1) then
          raise Exception.Create('�������� ���������������� �������/������������� �� ����� ���������� � USR$CROSS!');

        if (AsString[Length(FieldByName('relationname').AsString)] in ['0'..'9', '_']) then
          raise Exception.Create('�������� ���������������� �������/������������� �� ����� ������������� �� _ ��� �����!');
      end;

      Tbl := atDatabase.Relations.ByRelationName(AsString);
      //������� � ����� ������������� ��� ����������
      if Assigned(Tbl) and (Tbl.ID <> ID) then
      begin
        FieldByName('relationname').FocusControl;
        raise EgdcIBError.Create('������������ �������/������������� ����������� � ��� ������������!')
      end;

    except
      FocusControl;
      raise;
    end;
end;

procedure TgdcRelation.CreateFields;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCRELATION', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATION', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATION',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('lname').Required := False;
  FieldByName('lshortname').Required := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATION', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATION', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

class function TgdcRelation.IsAbstractClass: Boolean;
begin
  Result := inherited IsAbstractClass;
  if not Result then
  begin
    Result := Self.ClassNameIs('TgdcRelation') or Self.ClassNameIs('TgdcTable') or
      Self.ClassNameIs('TgdcBaseTable');
  end;
end;

{ TgdcTable }

constructor TGDCBASETABLE.Create(AnOwner: TComponent);
begin
  inherited;

  FTableType := ttUnknow;
  FOnCustomTable := nil;
  FAdditionCreateField := TStringList.Create;
  FNeedPredefinedFields := False;
end;

function TGDCBASETABLE.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCBASETABLE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASETABLE', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASETABLE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASETABLE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASETABLE' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dlgRelation.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASETABLE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASETABLE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

function TGDCBASETABLE.CreateInsertTrigger: String;
begin
  Result := Format
  (
    'CREATE TRIGGER %1:s FOR %0:s '#13#10 +
    '  BEFORE INSERT '#13#10 +
    '  POSITION 0 '#13#10 +
    'AS '#13#10 +
    'BEGIN '#13#10 +
    '  IF (NEW.id IS NULL) THEN '#13#10 +
    '    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1); '#13#10 +
    'END',
    [FieldByName('relationname').AsString,
     gdcBaseManager.AdjustMetaName('usr$bi_' + FieldByName('relationname').AsString)]
  );
end;

procedure TgdcBaseTable.NewField(FieldName,
  LName, FieldSource, Description, LShortName, Alignment, ColWidth,
  ReadOnly, Visible: String);
begin
  Assert(Assigned(gdcTableField), '�� ����� ������ ������ � �����');

  with gdcTableField do
  begin
    Insert;
    FieldByName('fieldname').AsString := FieldName;
    FieldByName('lname').AsString := LName;
    FieldByName('fieldsource').AsString := FieldSource;
    FieldByName('description').AsString := Description;
    FieldByName('lshortname').AsString := LShortName;
    FieldByName('alignment').AsString := Alignment;
    FieldByName('colwidth').AsString := ColWidth;
    FieldByName('readonly').AsString := ReadOnly;
    FieldByName('visible').AsString := Visible;
    FieldByName('afull').AsString := '-1';
    FieldByName('achag').AsString := '-1';
    FieldByName('aview').AsString := '-1';
    Post;
  end;
end;

procedure TGDCBASETABLE.CustomDelete(Buff: Pointer);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  DelRelName: String;
  DidActivate: Boolean;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBASETABLE', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASETABLE', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASETABLE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASETABLE',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASETABLE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  DelRelName := FieldByName('relationname').AsString;
  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('relationname').AsString)) = 0 then
    raise EgdcIBError.Create('�� �� ������ ������� ����������������� �������');

  DidActivate := False;
  try
    DidActivate := ActivateTransaction;

    DropTable;
    CustomExecQuery(
        'DELETE FROM at_relations WHERE id = :ID', Buff);
    Clear_atSQLSetupCache;

    if Assigned(atDatabase) and Assigned(atDatabase.Relations.ByRelationName(DelRelName)) and
      not (atDatabase.InMultiConnection) then
      atDatabase.Relations.Remove(atDatabase.Relations.ByRelationName(DelRelName));

    if DidActivate and Transaction.InTransaction then
      Transaction.Commit;
  except
    if DidActivate and Transaction.InTransaction then
      Transaction.Rollback;
    raise;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASETABLE', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASETABLE', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TGDCBASETABLE._DoOnNewRecord;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  gdcTF: TgdcTableField;
  MS: TDataSource;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASETABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASETABLE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASETABLE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASETABLE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASETABLE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  FieldByName('relationtype').AsString := 'T';

  if sLoadFromStream in BaseState then
  begin
    gdcTF := GetgdcTableField;
    if not Assigned(gdcTF) then
    begin
      gdcTF := TgdcTableField.CreateSubType(Self, '', 'ByRelation');
      MS := TDataSource.Create(Self);
      MS.DataSet := Self;
      gdcTF.MasterField := 'id';
      gdcTF.DetailField := 'relationkey';
      gdcTF.MasterSource := MS;
      gdcTF.Open;
    end;
    FNeedPredefinedFields := True;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASETABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASETABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TGDCBASETABLE.DropTable;
var
  ibsql: TIBSQL;
  FSQL: TSQLProcessList;
begin
  ibsql := CreateReadIBSQL;
  FSQL := TSQLProcessList.Create;
  try
    ibsql.SQL.Text := 'SELECT * FROM rdb$dependencies WHERE rdb$depended_on_name = :depname ' +
      ' AND (rdb$dependent_type = 1 OR rdb$dependent_type = 5) ';
    ibsql.ParamByName('depname').AsString := FieldByName('relationname').AsString;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
      raise EgdcIBError.Create('������ ������� ������� �.�. ��� ������������ � ���������� ��� ��������������');

    ibsql.Close;

    ibsql.SQL.Text := 'SELECT * FROM rdb$triggers WHERE rdb$relation_name = :relname AND rdb$system_flag = 0';
    ibsql.ParamByName('relname').AsString := FieldByName('relationname').AsString;
    ibsql.ExecQuery;

    while not ibsql.EOF do
    begin
      FSQL.Add(Format('DROP TRIGGER %s', [ibsql.FieldByName('rdb$trigger_name').AsString]), False);
      ibsql.Next;
    end;

    ibsql.Close;
    ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints WHERE rdb$relation_name = :relname ' +
      'AND rdb$constraint_type = ''FOREIGN KEY'' ';
    ibsql.ParamByName('relname').AsString := FieldByName('relationname').AsString;
    ibsql.ExecQuery;

    while not ibsql.EOF do
    begin
      FSQL.Add(Format('ALTER TABLE %s DROP CONSTRAINT %s ',
        [FieldByName('relationname').AsString,
        ibsql.FieldByName('rdb$constraint_name').AsString]), False);

      ibsql.Next;
    end;

    ibsql.Close;
    ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints WHERE rdb$relation_name = :relname ' +
      'AND rdb$constraint_type = ''PRIMARY KEY'' ';
    ibsql.ParamByName('relname').AsString := FieldByName('relationname').AsString;
    ibsql.ExecQuery;

    while not ibsql.EOF do
    begin
      FSQL.Add(Format('ALTER TABLE %s DROP CONSTRAINT %s ',
        [FieldByName('relationname').AsString,
        ibsql.FieldByName('rdb$constraint_name').AsString]), False);

      ibsql.Next;
    end;

    ibsql.Close;

    DropCrossTable;

    FSQL.Add('DROP TABLE ' + FieldByName('relationname').AsString);
    case TableType of
      ttIntervalTree: FSQL.Add(Format('DELETE FROM GD_COMMAND WHERE classname = ''TgdcAttrUserDefinedLBRBTree'' AND ' +
          ' UPPER(SubType) = UPPER(''%s'')', [FieldByName('relationname').AsString]));
      ttTree: FSQL.Add(Format('DELETE FROM GD_COMMAND WHERE classname = ''TgdcAttrUserDefinedTree'' AND ' +
          ' UPPER(SubType) = UPPER(''%s'')', [FieldByName('relationname').AsString]));
      else
        FSQL.Add(Format('DELETE FROM GD_COMMAND WHERE classname = ''TgdcAttrUserDefined'' AND ' +
          ' UPPER(SubType) = UPPER(''%s'')', [FieldByName('relationname').AsString]));
    end;

    //��������� ���� �� � ������� foreign keys
    //���� ����, ������� ��� ����� �� �������, � ������ ����� ��������������� � ����
    ibsql.Close;
    ibsql.SQL.Text := 'SELECT rc.rdb$constraint_name, rc.rdb$index_name, ' +
      ' rf.rdb$update_rule, rf.rdb$delete_rule ' +
      ' FROM rdb$relations r ' +
      ' LEFT JOIN rdb$relation_constraints rc ' +
      '   ON r.rdb$relation_name = rc.rdb$relation_name ' +
      ' LEFT JOIN rdb$ref_constraints rf ' +
      '   ON rf.rdb$constraint_name = rc.rdb$constraint_name ' +
      ' WHERE ' +
      '   rc.rdb$constraint_type = ''FOREIGN KEY''' +
      '   AND r.rdb$relation_name = :relationname ';
    ibsql.ParamByName('relationname').AsString := FieldByName('relationname').AsString;
    ibsql.ExecQuery;

    if ibsql.RecordCount > 0 then
      atDatabase.NotifyMultiConnectionTransaction;
    ShowSQLProcess(FSQL);

  finally

    ibsql.Free;
    FSQL.Free;
  end;
end;

function TGDCBASETABLE.GetCurrRecordClass: TgdcFullClass;
var
  S: String;
begin
  Result := inherited GetCurrRecordClass;
  if RecordCount > 0 then
  begin
    S := Self.ClassName;
    case TableType of
      ttTableToTable: S := 'TgdcTableToTable';
      ttSimpleTable: S := 'TgdcSimpleTable';
      ttTree: S := 'TgdcTreeTable';
      ttIntervalTree: S := 'TgdcLBRBTreeTable';
      ttCustomTable: S := 'TgdcCustomTable';
      ttDocument: S := 'TgdcDocumentTable';
      ttDocumentLine: S := 'TgdcDocumentLineTable';
      ttInvSimple: S := 'TgdcInvSimpleDocumentLineTable';
      ttInvFeature: S := 'TgdcInvFeatureDocumentLineTable';
      ttInvInvent: S := 'TgdcInvInventDocumentLineTable';
      ttInvTransfrom: S := 'TgdcInvTransformDocumentLineTable';
      ttUnknow: S := 'TgdcUnknownTable';
      ttPrimeTable: S := 'TgdcPrimeTable';
    end;
    if (S > '') and (GetClass(S) <> nil) then
      Result.gdClass := CgdcBase(GetClass(S));
  end;
end;

class function TGDCBASETABLE.GetDisplayName(const ASubType: TgdcSubType): String;
begin
  Result := '�������';
end;

function TGDCBASETABLE.GetgdcTableField: TgdcTableField;
var
  i: Integer;
begin
  FgdcTableField := nil;
  for i:= 0 to DetailLinksCount - 1 do
    if (DetailLinks[i] is TgdcTableField) and ((DetailLinks[i] as TgdcTableField).CachedUpdates or (sLoadFromStream in BaseState))
    then
    begin
      FgdcTableField := DetailLinks[i] as TgdcTableField;
      Break;
    end;
  Result := FgdcTableField;
end;

function TGDCBASETABLE.GetTableType: TgdcTableType;
begin
  if not (State in [dsInsert]) then
    FTableType := GetTableTypeByName(FieldByName('relationname').AsString);
  Result := FTableType;
end;

procedure TGDCBASETABLE.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add(' z.relationtype = ''T'' ');
end;

procedure TGDCBASETABLE.MakePredefinedRelationFields;
begin
  TestRelationName;

  if (sLoadFromStream in BaseState) and
    (AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('relationname').AsString)) <> 1)
  then
    Exit;

//������ ��� ���������������� ������!!!!!
  if (AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('relationname').AsString)) <> 1)
  then
    FieldByName('relationname').AsString := UserPrefix +
        FieldByName('relationname').AsString;

  if (State = dsInsert) and Assigned(gdcTableField) then
  begin
    NewField('ID',
      '�������������', 'DINTKEY', '�������������', '�������������',
      'L', '10', '1', '0');
  end;
end;

destructor TGDCBASETABLE.Destroy;
begin
  FreeAndNil(FAdditionCreateField);
  inherited;

end;

class function TGDCBASETABLE.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmTable';
end;

{ TgdcTable }

{ TgdcView }

constructor TgdcView.Create(AnOwner: TComponent);
begin
  inherited;
end;

function TgdcView.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCVIEW', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCVIEW', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCVIEW') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCVIEW',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCVIEW' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_attr_dlgView.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCVIEW', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCVIEW', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

function TgdcView.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCVIEW', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCVIEW', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCVIEW') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCVIEW',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCVIEW' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetSelectClause + ', rdb.rdb$view_source as view_source ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCVIEW', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCVIEW', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcView.GetDisplayName(const ASubType: TgdcSubType): String;
begin
  Result := '�������������';
end;

procedure TgdcView.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add('z.relationtype = ''V'' ');
end;

function TgdcView.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCVIEW', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCVIEW', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCVIEW') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCVIEW',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCVIEW' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetFromClause(ARefresh) +
    ' LEFT JOIN rdb$relations rdb ON z.relationname = rdb.rdb$relation_name ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCVIEW', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCVIEW', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcView.CustomDelete(Buff: Pointer);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  DelRelName: String;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCVIEW', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCVIEW', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCVIEW') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCVIEW',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCVIEW' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  DelRelName := FieldByName('relationname').AsString;
  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('relationname').AsString)) = 0
  then
    raise EgdcIBError.Create('�� �� ������ ������� ����������������� �������������');

  DropView(nil);
  CustomExecQuery(' DELETE FROM at_relations WHERE id = :OLD_ID ', Buff);
  Clear_atSQLSetupCache;

  if Assigned(atDatabase) and Assigned(atDatabase.Relations.ByRelationName(DelRelName)) and
    not (atDatabase.InMultiConnection) then
    atDatabase.Relations.Remove(atDatabase.Relations.ByRelationName(DelRelName));
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCVIEW', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCVIEW', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcView.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCVIEW', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCVIEW', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCVIEW') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCVIEW',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCVIEW' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  AddRelationField;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCVIEW', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCVIEW', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcView.AddRelationField;
var
  ibsql: TIBSQL;
  gdcViewField: TgdcRelationField;
  i: Integer;
  DidActivate: Boolean;
begin
  gdcViewField := nil;
  for i:= 0 to DetailLinksCount - 1 do
    if (DetailLinks[i] is TgdcRelationField) then
    begin
      gdcViewField := DetailLinks[i] as TgdcRelationField;
      Break;
    end;

  if Assigned(gdcViewField) then
  begin
    DidActivate := False;
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Database := Database;
      ibsql.Transaction := Transaction;

      DidActivate := ActivateTransaction;

      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields WHERE rdb$relation_name = :relname';
      ibsql.ParamByName('relname').AsString := FieldByName('relationname').AsString;
      ibsql.ExecQuery;
      while not ibsql.EOF do
      begin
        gdcViewField.Insert;
        try
          gdcViewField.FieldByName('relationkey').AsInteger := FieldByName('id').AsInteger;
          gdcViewField.FieldByName('relationname').AsString := Trim(FieldByName('relationname').AsString);
          gdcViewField.FieldByName('fieldname').AsString := Trim(ibsql.FieldByName('rdb$field_name').AsString);
          gdcViewField.FieldByName('fieldsource').AsString := Trim(ibsql.FieldByName('rdb$field_source').AsString);
          gdcViewField.FieldByName('lname').AsString := gdcViewField.FieldByName('fieldname').AsString;
          gdcViewField.FieldByName('lshortname').AsString := gdcViewField.FieldByName('fieldname').AsString;
          gdcViewField.Post;
        except
          gdcViewField.Cancel;
          raise;
        end;
        ibsql.Next;
      end;
      ibsql.Close;
    finally
      if DidActivate then
        Transaction.Commit;

      ibsql.Free;
    end;
  end;
end;

function TgdcView.CreateView: String;
begin
  Result := GetViewTextBySource(FieldByName('view_source').AsString);
end;

procedure TgdcView.DropView(ViewCreateList: TStringList);
var
  FSQL: TSQLProcessList;
  ibsql: TIBSQL;
  DidActivate: Boolean;
  gdcView: TgdcView;
begin
  NeedSingleUser := True;
  FSQL := TSQLProcessList.Create;
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := Transaction;
    DidActivate := False;
    try
      if Assigned(ViewCreateList) then
      begin
        ibsql.Close;
        ibsql.SQl.Text := 'SELECT r.* FROM rdb$view_relations rdb' +
          ' LEFT JOIN at_relations r ON r.relationname = rdb.rdb$view_name ' +
          ' WHERE rdb.rdb$relation_name = :rn ';
        ibsql.ParamByName('rn').AsString := FieldByName('relationname').AsString;
        ibsql.ExecQuery;
        if ibsql.RecordCount > 0 then
        begin
          gdcView := TgdcView.CreateSubType(nil, '', 'ByID');
          try
            gdcView.Transaction := Transaction;
            while not ibsql.Eof do
            begin
              gdcView.Close;
              gdcView.ID := ibsql.FieldByName('id').AsInteger;
              gdcView.Open;
              if (gdcView.RecordCount > 0) and (gdcView.IsUserDefined) then
              begin
                if (ViewCreateList.IndexOfName(IntToStr(gdcView.ID)) = -1)
                  and (ID <> gdcView.ID) then
                begin
                  ViewCreateList.Add(IntToStr(gdcView.ID) + '=' +
                    gdcView.GetViewTextBySource(gdcView.FieldByName('view_source').AsString));
                  gdcView.DropView(ViewCreateList);
                end;
              end;
              ibsql.Next;
            end;
          finally
            gdcView.Free;
          end;
        end;
      end;

      FSQL.Add('DROP VIEW ' + FieldByName('relationname').AsString);
      FSQL.Add(Format('DELETE FROM GD_COMMAND WHERE classname = ''TgdcAttrUserDefined'' AND ' +
        ' UPPER(SubType) = UPPER(''%s'')', [FieldByName('relationname').AsString]));

      ShowSQLProcess(FSQL);

      if DidActivate and Transaction.InTransaction then
        Transaction.Commit;
    except
      if DidActivate and Transaction.InTransaction then
        Transaction.Rollback;
      raise;
    end;
  finally
    FSQL.Free;
    ibsql.Free;
  end;
end;

procedure TgdcView._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCVIEW', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCVIEW', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCVIEW') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCVIEW',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCVIEW' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('relationtype').AsString := 'V';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCVIEW', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCVIEW', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcView.GetTableType: TgdcTableType;
begin
  Result := FTableType;
end;

procedure TgdcView.CreateRelationSQL(Scripts: TSQLProcessList);
begin
  Scripts.Add(CreateView);
  Scripts.Add(CreateGrantSQL);
end;

class function TgdcView.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmRelation';
end;

procedure TgdcView.ReCreateView;
var
  FSQL: TSQLProcessList;
  ViewCreateList: TStringList;
  I: Integer;
begin
  Assert(State = dsEdit, '������ ������ ���������� � ��������� ��������������!');
  Assert(atDatabase <> nil, '�� ��������� ���� ���������!');
  Assert(AnsiPos(UserPrefix, FieldByName('relationname').AsString) = 1,
    '�� �� ������ ����������� ����������� �������������!');

  ViewCreateList := TStringList.Create;
  FSQL := TSQLProcessList.Create;
  try
    if not Database.IsFirebird25Connect then
    begin
      DropView(ViewCreateList);
      MetaDataCreate;
      for I := 0 to ViewCreateList.Count - 1 do
        FSQL.Add(ViewCreateList.Values[ViewCreateList.Names[I]], False);

      if ViewCreateList.Count > 0 then
        atDatabase.NotifyMultiConnectionTransaction;

      ShowSQLProcess(FSQL);

      RemoveRelationField;
      AddRelationField;
    end else
    begin
      FSQL.Add(GetAlterViewTextBySource(FieldByName('view_source').AsString));
      ShowSQLProcess(FSQL);

      RemoveRelationField;
      AddRelationField;
    end;
  finally
    ViewCreateList.Free;
    FSQL.Free;
  end;
end;

procedure TgdcView.RemoveRelationField;
var
  gdcViewField: TgdcRelationField;
  I: Integer;
begin
  NeedSingleUser := True;
  ExecSingleQuery(Format('DELETE FROM at_relation_fields WHERE relationkey = %s',
    [FieldByName(GetKeyField(SubType)).AsString]));

  gdcViewField := nil;
  for I := 0 to DetailLinksCount - 1 do
    if (DetailLinks[i] is TgdcRelationField) then
    begin
      gdcViewField := DetailLinks[i] as TgdcRelationField;
      Break;
    end;

  if Assigned(gdcViewField) then
    gdcViewField.CloseOpen;

end;


procedure TgdcView.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCVIEW', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCVIEW', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCVIEW') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCVIEW',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCVIEW' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if (sLoadFromStream in BaseState) and
    (AnsiPos(UserPrefix, FieldByName('relationname').AsString) = 1)
  then
    ReCreateView;

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCVIEW', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCVIEW', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

function TgdcView.GetViewTextBySource(const Source: String): String;
var
  i: Integer;
  S: TStringList;
begin
  if AnsiPos('CREATE VIEW', AnsiUpperCase(Source)) > 0 then
  begin
    Result := Source;
  end
  else
  begin
    S := TStringList.Create;
    try
      GetFieldsName(Source, S);
      if S.Count = 0 then
        raise EgdcIBError.Create('������ ��� �������� �������������: ���������� ����� ����� ����!');
      Result := Format('CREATE VIEW %s ('#13#10, [FieldByName('relationname').AsString]);
      for i := 0 to S.Count - 2 do
        Result := Result + S[i] + ', ' + #13#10;
      Result := Result + S[S.Count - 1] +  #13#10 + ' )'#13#10 + ' AS ' + Source;
    finally
      S.Free;
    end;
  end;
end;

function TgdcView.GetAlterViewTextBySource(const Source: String): String;
var
  i: Integer;
  S: TStringList;
begin
  if AnsiPos('ALTER VIEW', AnsiUpperCase(Source)) > 0 then
  begin
    Result := Source;
  end
  else if AnsiPos('CREATE VIEW', AnsiUpperCase(Source)) > 0 then
  begin
    Result := StringReplace(Source, 'CREATE VIEW', 'ALTER VIEW', [rfIgnoreCase]);
  end else
  begin
    S := TStringList.Create;
    try
      GetFieldsName(Source, S);
      if S.Count = 0 then
        raise EgdcIBError.Create('������ ��� �������� �������������: ���������� ����� ����� ����!');
      Result := Format('ALTER VIEW %s ('#13#10, [FieldByName('relationname').AsString]);
      for i := 0 to S.Count - 2 do
        Result := Result + S[i] + ', ' + #13#10;
      Result := Result + S[S.Count - 1] +  #13#10 + ' )'#13#10 + ' AS ' + Source;
    finally
      S.Free;
    end;
  end;
end;

{ TgdcRelationField }

procedure TgdcRelationField.AddField;
var
  FQuery: TSQLProcessList;
  ibsql: TIBSQL;
  S: String;
  //��������� ������������� �� ��� �������� �� ���������
  IsSetDefault: Boolean;
  DefValue: String;
  DidActivate: Boolean;
  NeedMultiConnection: Boolean;
  CrossTableKey: Integer;
  FDefaultvalue: String;
  L: Integer;
  FFieldType: Integer;
  R: OleVariant;
begin
  { ���������� ���� }

  FQuery := TSQLProcessList.Create;
  ibsql := TIBSQL.Create(nil);
  IsSetDefault := False;
  DefValue := '';
  NeedMultiConnection := False;

  try
    DidActivate := False;
    try
      DidActivate := ActivateTransaction;
      ibsql.Transaction := Transaction;

      if FieldByName('computed_value').IsNull and (FieldByName('refrelationname').AsString <> '') then
      begin
        FQuery.Add(CreateFieldSQL);
        FQuery.Add(CreateFieldConstraintSQL);

        NeedMultiConnection := True;

      end
      else
      begin
        if FieldByName('computed_value').IsNull and
           (FieldByName('refcrossrelation').AsString <> '') then
        begin

          FQuery.Add(CreateFieldSQL);
        {���� �� ��������� ���� �� ������, �� �����-������� ��� �������,
         ������ ������� ������ ����������� ������-��� �
         ������� ����, ������� ���� �������� ������� ��� �������� �����-�������}
          if (not (sLoadFromStream in BaseState)) then
          begin
            FQuery.Add(CreateCrossRelationSQL);
            FQuery.Add(CreateCrossRelationTriggerSQL);
            FQuery.Add(CreateCrossRelationGrantSQL);
          end else
          begin
            FQuery.Add(CreateCrossRelationPrimarySQL);
            FQuery.Add(CreateCrossRelationForeign1SQL);
            FQuery.Add(CreateCrossRelationForeign2SQL);
            FQuery.Add(CreateDropCrossSimulateField);
          end;

          NeedMultiConnection := True;
        end
        else
          FQuery.Add(CreateFieldSQL);
      end;    

      CreateInvCardTrigger(FQuery);
      // �������� ���� � ������� AC_ENTRY_BALANCE � ����������� ������� ������������� �� ������ � ������ AC_ENTRY
      AlterAcEntryBalanceAndRecreateTrigger(FQuery);

      S := CreateAccCirculationList;
      if S <> '' then
        FQuery.Add(S);

      //��������� �������� �� ���������
      if (FieldByName('nullflag').AsInteger = 1) and
        (FieldByName('computed_value').IsNull) or
        (not FieldByName('defsource').IsNull)
      then
      begin
        FFieldType := GetFieldType(FieldByName('fieldsourcekey').AsInteger);
        if (FFieldType in [blr_Text, blr_varying,
          blr_Text2, blr_varying2, blr_cstring, blr_cstring2]) then
        begin
          FDefaultValue := Trim(FieldByName('defsource').AsString);
          if Pos('DEFAULT', FDefaultValue) = 1 then
            FDefaultValue := Trim(System.Copy(FDefaultValue, 8, 1024));
          L := Length(FDefaultValue);
          if (L > 0) and (FDefaultValue[1] = '''') then
            FDefaultValue := System.Copy(FDefaultValue, 2, L - 2);

          if (System.Length(FDefaultValue) > FieldByName('stringlength').AsInteger)
          then
            raise EgdcIBError.Create(Format('����� �������� �� ��������� ��������� ���������� (%s �������(��))!',
              [FieldByName('stringlength').AsString]));
        end;

        //���� ��� �� �������� �� ������,
        //������� �� ������ �
        //������������ ����� ���������� �������� �� ���������,
        //������� ������ ��� ����� �������� �� ���������
        if (not (sLoadFromStream in BaseState)) then
        begin
          try
            gdcBaseManager.ExecSingleQueryResult('SELECT FIRST 1 * FROM ' + FieldByName('relationname').AsString, '', R);
          except
          end;

          if not VarIsEmpty(R) and
            (MessageBox(0,
              PChar('������ �� ���������� �������� ��� ���� ' +
              FieldByName('fieldname').AsString + '?'),
              '��������� �������� �� ���������',
              MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDYES) then
          begin
            DefValue := FieldByName('defsource').AsString;
            repeat
              if not InputQuery('�������� �� ���������', '������� �������� ��� ���� ' +
                FieldByName('fieldname').AsString, DefValue)
              then
              begin
                DefValue := '';
                Break;
              end;
              DefValue := Trim(DefValue);
              if (FFieldType in [blr_Text, blr_varying,
                 blr_Text2, blr_varying2, blr_cstring, blr_cstring2]) and
               (Length(DefValue) > FieldByName('stringlength').AsInteger)
              then
                MessageBox(ParentHandle, PChar(Format('����� �������� �� ��������� ��������� ���������� (%s �������(��))!',
                  [FieldByName('stringlength').AsString])), '��������!',
                  MB_OK or MB_ICONERROR or MB_TASKMODAL);
            until (not(FFieldType in [blr_Text, blr_varying,
               blr_Text2, blr_varying2, blr_cstring, blr_cstring2])) or
               (Length(DefValue) <= FieldByName('stringlength').AsInteger);

            if DefValue > '' then
              IsSetDefault := True;
          end
        end else
        begin
          IsSetDefault := True;
          DefValue := Trim(FieldByName('defsource').AsString);
        end;
      end;

      if (FieldByName('crosstable').AsString <> '') and not (sLoadFromStream in BaseState) then
      begin
        atDatabase.NotifyMultiConnectionTransaction;
        CrossTableKey := gdcBaseManager.GetNextID;
        FQuery.Add(Format(
          'INSERT INTO at_relations (id, relationname, relationtype, lname, ' +
          'lshortname, description, afull, achag, aview) VALUES' +
          '(%1:s, ''%0:s'', ''T'', ''%0:s'', ''%0:s'', ''%0:s'', -1, -1, -1)',
          [FieldByName('crosstable').AsString, IntToStr(CrossTableKey)]
        ));
        FQuery.Add(Format('UPDATE at_relation_fields SET crosstablekey = %s' +
          ' WHERE id = %s', [IntToStr(CrossTableKey), FieldByName('id').AsString]));
      end;

      if (FieldByName('nullflag').AsInteger = 1) and
       IsSetDefault or NeedMultiConnection then
      begin
        if ((FieldByName('nullflag').AsInteger = 1) and
          (FieldByName('computed_value').IsNull) or
          (not FieldByName('defsource').IsNull))
          and (DefValue > '') then
        begin
          FQuery.Add(CreateDefaultSQL(DefValue));
        end;
        atDatabase.NotifyMultiConnectionTransaction;
      end;

      {������� ����� ��������� �������, ����� ���� �����-�� ������� ������������ ������� �����}
      if (sLoadFromStream in BaseState) and Self.IsUserDefined  then
        FQuery.Add(Format('UPDATE rdb$relation_fields SET rdb$field_position = %0:d ' +
          ' WHERE rdb$relation_name = ''%2:s'' AND rdb$field_name = ''%1:s'' ',
        [FieldByName('rdb$field_position').AsInteger,
         AnsiUpperCase(Trim(FieldByName('fieldname').AsString)),
         AnsiUpperCase(FieldByName('relationname').AsString)]));

      ShowSQLProcess(FQuery);

      if (not atDatabase.InMultiConnection) and (not FieldByName('computed_value').IsNull) then
      begin
        ibsql.Close;
        ibsql.SQL.Text := Format(
          ' SELECT * FROM rdb$relation_fields WHERE rdb$relation_name = ''%s'' AND ' +
          ' rdb$field_name = ''%s'' ', [FieldByName('relationname').AsString,
          FieldByName('fieldname').AsString]);
        ibsql.ExecQuery;
        FieldByName('fieldsource').AsString := ibsql.FieldByName('rdb$field_source').AsString;
        ibsql.Close;

        FieldByName('fieldsourcekey').AsInteger := gdcBaseManager.GetNextID;
        ibsql.SQL.Text := Format(
          ' INSERT INTO at_fields (id, fieldname, lname) VALUES (%s, ''%s'', ''%s'') ',
          [FieldByName('fieldsourcekey').AsString,
           FieldByName('fieldsource').AsString, FieldByName('fieldsource').AsString]);
        ibsql.ExecQuery;
      end;

      if DidActivate and Transaction.InTransaction then
        Transaction.Commit;

    except
      if DidActivate and Transaction.InTransaction then
        Transaction.Rollback;
      raise;
    end;

  finally
    FQuery.Free;
    ibsql.Free;
    NeedSingleUser := False;
  end;
end;

procedure TgdcRelationField.DropField;
var
  FQuery: TSQLProcessList;
  ibsql: TIBSQL;
  S: String;
  NeedMultiConnection: Boolean;
begin
  FQuery := TSQLProcessList.Create;
  ibsql := CreateReadIBSQL;
  try
    NeedMultiConnection := False;

    if FieldByName('refrelationname').AsString <> '' then
      FQuery.Add(CreateDropFieldConstraintSQL)

    else if FieldByName('crosstable').AsString <> '' then
    begin
      FQuery.Add(CreateDropTriggerSQL, False);
      FQuery.Add(CreateDropCrossTableSQL, False);
      NeedMultiConnection := True;
    end;

    if AnsiCompareText(FieldByName('relationname').AsString, 'INV_CARD') = 0 then
    begin
      CreateInvCardTrigger(FQuery, True);
      NeedMultiConnection := True;
    end;

    if AnsiCompareText(Trim(FieldByName('relationname').AsString), 'AC_ENTRY') = 0 then
    begin
      S := CreateAccCirculationList(True);
      if S <> '' then
        FQuery.Add(S);
      // ����������� ������� ������������� �� ������ � ������ AC_ENTRY, ������� ���� �� AC_ENTRY_BALANCE  
      AlterAcEntryBalanceAndRecreateTrigger(FQuery, True);
      NeedMultiConnection := True;
    end;

    FQuery.Add(CreateDropFieldSQL, False);

    if (FieldByName('deleterule').AsString > '') or NeedMultiConnection then
      atDatabase.NotifyMultiConnectionTransaction;
    ShowSQLProcess(FQuery);

  finally
    ibsql.Free;
    FQuery.Free;
  end;
end;

procedure TgdcRelationField.UpdateField;
var
  FQuery: TSQLProcessList;
  q: TIBSQL;
  S: String;
begin
  FQuery := TSQLProcessList.Create;
  try
    { ��������� ���� }
    if FChangeComputed
      or ((sLoadFromStream in BaseState) and Self.IsUserDefined
        and (FieldByName('computed_value').AsString > '')) then
    begin
      if not Database.IsFirebird25Connect then
      begin
        q := TIBSQL.Create(nil);
        try
          q.Transaction := ReadTransaction;
          q.SQL.Text :=
            'SELECT f.rdb$computed_source ' +
            'FROM rdb$relation_fields r JOIN rdb$fields f ' +
            '  ON r.rdb$field_source = f.rdb$field_name ' +
            'WHERE r.rdb$relation_name = :RN AND r.rdb$field_name = :FN ';
          q.ParamByName('FN').AsString := AnsiUpperCase(Trim(FieldByName('fieldname').AsString));
          q.ParamByName('RN').AsString := AnsiUpperCase(Trim(FieldByName('relationname').AsString));
          q.ExecQuery;

          if AnsiCompareText(Trim(FieldByName('computed_value').AsString),
            Trim(q.Fields[0].AsString)) <> 0 then
          begin
            DropField;
            AddField;
          end;
        finally
          q.Free;
        end;
      end
      else
      begin
        S := Trim(FieldByName('computed_value').AsString);
        while (Length(S) > 0) and (S[1] = '(') and (S[Length(S)] = ')') do
          S := System.Copy(S, 2, Length(S) - 2);
        FQuery.Add(Format
        (
          'ALTER TABLE %s ALTER %s COMPUTED BY (%s)',
          [FieldByName('relationname').AsString, FieldByName('fieldname').AsString,
          S]
        ));
      end;
    end;

    {������� ����� ��������� ������� ����� ���� ���-�� ��������� ������� �����}
    if (sLoadFromStream in BaseState) and Self.IsUserDefined then
    begin
      FQuery.Add(Format('UPDATE rdb$relation_fields SET rdb$field_position = %0:d ' +
        ' WHERE rdb$relation_name = ''%2:s'' AND rdb$field_name = ''%1:s'' ',
        [FieldByName('rdb$field_position').AsInteger,
         AnsiUpperCase(Trim(FieldByName('fieldname').AsString)),
         AnsiUpperCase(FieldByName('relationname').AsString)]));
    end;

    ShowSQLProcess(FQuery);

  finally
    FQuery.Free;
  end;
end;

constructor TgdcRelationField.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpModify, cpDelete];
end;

function TgdcRelationField.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCRELATIONFIELD', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATIONFIELD', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATIONFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATIONFIELD',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATIONFIELD' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dlgRelationField.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATIONFIELD', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATIONFIELD', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcRelationField.CustomDelete(Buff: Pointer);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  DelFieldName: String;
  DelFieldRelName: String;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCRELATIONFIELD', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATIONFIELD', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATIONFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATIONFIELD',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATIONFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  DelFieldName := FieldByName('fieldname').AsString;
  DelFieldRelName := FieldByName('relationname').AsString;
  if Pos(UserPrefix, AnsiUpperCase(FieldByName('fieldname').AsString)) = 0 then
    raise EgdcIBError.Create('�� �� ������ ������� ����������������� ����!');

  DropField;

  CustomExecQuery(
    ' DELETE FROM at_relation_fields ' +
    ' WHERE ID = :OLD_ID ',
    Buff
  );

  Clear_atSQLSetupCache;

  if Assigned(atDatabase) and Assigned(atDatabase.FindRelationField(DelFieldRelName, DelFieldName))and
    not (atDatabase.InMultiConnection)
  then
    atDatabase.Relations.ByRelationName(DelFieldRelName).RelationFields.Delete(
      atDatabase.Relations.ByRelationName(DelFieldRelName).RelationFields.IndexOf(
        atDatabase.FindRelationField(DelFieldRelName, DelFieldName)));
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATIONFIELD', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATIONFIELD', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcRelationField.CustomInsert(Buff: Pointer);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  R: TatRelation;
  F: TatRelationField;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCRELATIONFIELD', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATIONFIELD', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATIONFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATIONFIELD',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATIONFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if (Pos(UserPrefix, AnsiUpperCase(FieldByName('fieldname').AsString)) = 1) and
     (FieldByName('relationtype').AsString = 'T')
  then
    AddField;

//�.�. ��� ������������ ���� ��������� ��������� �����,
// �� �� ������ ����� ����� �������� ��� ���� � ���� �������

  if ((FieldByName('computed_value').IsNull) or
    (not atDatabase.InMultiConnection)) and
    (not FieldByName('fieldsourcekey').IsNull)
  then
  begin
    inherited;

    R := atDatabase.Relations.ByID(FieldByName('relationkey').AsInteger);
    if Assigned(R) then
    begin
      F := atDataBase.FindRelationField(FieldByName('relationname').AsString,
        FieldByName('fieldname').AsString);
      if not Assigned(F) then
        F := R.RelationFields.AddRelationField(FieldByName('fieldname').AsString);
      F.RefreshData(Database, Transaction);
      R.RefreshConstraints(Database, Transaction);
    end;
  end else
    atDatabase.NotifyMultiConnectionTransaction;
  Clear_atSQLSetupCache;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATIONFIELD', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATIONFIELD', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcRelationField.CustomModify(Buff: Pointer);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  R: TatRelation;
  F: TatRelationField;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCRELATIONFIELD', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATIONFIELD', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATIONFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATIONFIELD',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATIONFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  UpdateField;
  if (not FieldByName('fieldsourcekey').IsNull) then
  begin
    inherited;

{    R := atDatabase.Relations.ByID(FieldByName('relationkey').AsInteger);
    if Assigned(R) then
      R.RelationFields.RefreshData(Database, Transaction);}
    R := atDatabase.Relations.ByID(FieldByName('relationkey').AsInteger);
    if Assigned(R) then
    begin
      F := atDataBase.FindRelationField(FieldByName('relationname').AsString,
        FieldByName('fieldname').AsString);
      if not Assigned(F) then
        F := R.RelationFields.AddRelationField(FieldByName('fieldname').AsString);
      F.RefreshData(Database, Transaction);
      R.RefreshConstraints(Database, Transaction);
    end;
  end else

  if (Pos(UserPrefix, AnsiUpperCase(FieldByName('fieldname').AsString)) = 1) and
    (FieldByName('relationtype').AsString = 'T')
  then
    atDatabase.NotifyMultiConnectionTransaction;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATIONFIELD', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATIONFIELD', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcRelationField._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCRELATIONFIELD', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATIONFIELD', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATIONFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATIONFIELD',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATIONFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  FChangeComputed := False;

  FieldByName('nullflag').AsInteger := 0;

  if (FieldByName('objects').AsString = '')
    and (not (sLoadFromStream in BaseState)) then
  begin
    FieldByName('objects').AsString := 'TgdcBase';
  end;

  with FgdcDataLink do
    if Active and (DataSet is TgdcRelation) then
      FieldByName('relationname').AsString := DataSet.FieldByName('relationname').AsString;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATIONFIELD', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATIONFIELD', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcRelationField.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCRELATIONFIELD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATIONFIELD', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATIONFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATIONFIELD',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATIONFIELD' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result :=
    ' FROM at_relation_fields z ' +
    ' LEFT JOIN at_relations rel ON z.relationkey = rel.id ' +
    ' LEFT JOIN at_fields f ON z.fieldsourcekey = f.id ' +
    ' LEFT JOIN rdb$fields rdbf ON f.fieldname = rdbf.rdb$field_name ' +
    ' LEFT JOIN rdb$relation_fields rf ' +
    '   ON rf.rdb$field_name = z.fieldname ' +
    '     AND rf.rdb$relation_name = z.relationname';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATIONFIELD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATIONFIELD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcRelationField.GetKeyField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcRelationField.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'lname';
end;

class function TgdcRelationField.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'at_relation_fields';
end;

function TgdcRelationField.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCRELATIONFIELD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATIONFIELD', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATIONFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATIONFIELD',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATIONFIELD' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result :=
    'SELECT ' +
    '  z.*, f.reftable as refrelationname, ' +
    '  f.reflistfield, f.settable as refcrossrelation, f.setlistfield, ' +
    '  f.setlistfieldkey, rel.relationtype, ' +
    '  rdbf.rdb$character_length as stringlength, rf.rdb$default_source as defsource, ' +
    '  rdbf.rdb$computed_source as computed_value, rdbf.rdb$null_flag as sourcenullflag, ' +
    '  rf.rdb$null_flag as nullflag, ' +
    '  rf.rdb$field_position ';
    
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATIONFIELD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATIONFIELD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcRelationField.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('OnlyAttribute') then
    S.Add('z.fieldname LIKE ''USR$%''');
  if HasSubSet('ByRelation') then
    S.Add('z.relationkey = :relationkey ');
  if HasSubSet('ByFieldName') then
    S.Add('z.fieldname = :fieldname ');
  if HasSubSet('ByRelationName') then
    S.Add('z.relationname = :relationname ');
end;

function TgdcRelationField.CreateCrossRelationGrantSQL: String;
begin
  Result := Format
  (
    ' GRANT ALL ON %s TO administrator ',
    [FieldByName('crosstable').AsString]
  );
end;

function TgdcRelationField.CreateCrossRelationSQL: String;
var
  S1, S2, N1, N2, N3: String;
begin
  NeedSingleUser := True;

  S1 := FieldByName('relationname').AsString;
  S2 := FieldByName('refcrossrelation').AsString;

  if AnsiPos('USR$', S1) <> 1 then
    S1 := 'USR$' + S1;

  if AnsiPos('USR$', S2) <> 1 then
    S2 := 'USR$' + S2;

  if S1 = S2 then
    S2 := S2 + '_r';

  N1 := GetKeyName(True, FieldByName('crosstable').AsString, GetUniqueID(Database, ReadTransaction));
  N2 := GetKeyName(False, FieldByName('crosstable').AsString, GetUniqueID(Database, ReadTransaction));
  N3 := GetKeyName(False, FieldByName('crosstable').AsString, GetUniqueID(Database, ReadTransaction));

  Result := Format
  (
    'CREATE TABLE %0:s ( %1:s dintkey, %2:s dintkey, ' +
    'CONSTRAINT %7:s PRIMARY KEY (%1:s, %2:s), ' +
    'CONSTRAINT %8:s FOREIGN KEY (%1:s) REFERENCES %3:s (%5:s) ON DELETE CASCADE ON UPDATE CASCADE, ' +
    'CONSTRAINT %9:s FOREIGN KEY (%2:s) REFERENCES %4:s (%6:s) /*ON DELETE CASCADE*/ ON UPDATE CASCADE' +
    ')',
    [
      FieldByName('crosstable').AsString,
      gdcBaseManager.AdjustMetaName(S1 + 'KEY'),
      gdcBaseManager.AdjustMetaName(S2 + 'KEY'),
      FieldByName('relationname').AsString,
      FieldByName('refcrossrelation').AsString,
      GetKeyFieldName(FieldByName('relationname').AsString),
      GetKeyFieldName(FieldByName('refcrossrelation').AsString),
      N1,
      N2,
      N3
    ]
  );

end;

function TgdcRelationField.CreateCrossRelationTriggerSQL: String;
var
  S1, S2: String;
  ibsql: TIBSQL;
  DidActivate: Boolean;
begin
  S1 := FieldByName('relationname').AsString;
  S2 := FieldByName('refcrossrelation').AsString;

  if AnsiPos('USR$', S1) <> 1 then
    S1 := 'USR$' + S1;

  if AnsiPos('USR$', S2) <> 1 then
    S2 := 'USR$' + S2;

  if S1 = S2 then
    S2 := S2 + '_r';

  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := Transaction;
    DidActivate := False;
    try
      DidActivate := ActivateTransaction;

      ibsql.SQL.Text := 'SELECT rdb$field_type FROM rdb$fields WHERE rdb$field_name = ''' +
        FieldByName('fieldsource').AsString + '''';
      ibsql.ExecQuery;
      if RecordCount = 0 then
        raise EgdcIBError.Create('����� ' + FieldByName('fieldsource').AsString +
          ' �� ������! ���������� ���������������! ');

      if (ibsql.FieldByName('rdb$field_type').AsInteger in [blr_Text, blr_varying])
      then
      begin
        Result := Format
        (
          'CREATE TRIGGER %11:s FOR %0:s' + #13#10 +
          '  BEFORE UPDATE ' + #13#10 +
          '  POSITION %1:s ' + #13#10 +
          'AS ' + #13#10 +
          '  DECLARE VARIABLE attr VARCHAR(60); ' + #13#10 +
          '  DECLARE VARIABLE text VARCHAR(254); ' + #13#10 +
          'BEGIN '+ #13#10 +
          '  text = ''''; ' + #13#10 +
          '  FOR '+ #13#10 +
          '    SELECT L.%10:s ' + #13#10 +
          '      FROM ' + #13#10 +
          '        %2:s C JOIN %3:s L ON C.%5:s = L.%6:s ' + #13#10 +
          '      WHERE C.%4:s = NEW.%9:s ' + #13#10 +
          '      INTO :attr ' + #13#10 +
          '  DO ' + #13#10 +
          '  BEGIN ' + #13#10 +
          '    IF ((:text <> '''') AND (g_s_length(:text) < 254)) THEN ' + #13#10 +
          '      text = :text || '' ''; ' + #13#10 +
          '    text = :text || g_s_copy(:attr, 1, 254 - g_s_length(:text)); ' + #13#10 +
          '  END ' + #13#10 +
          '  NEW.%8:s = g_s_copy(:text, 1, %7:s); ' + #13#10 +
          'END',
          [
            FieldByName('relationname').AsString{0},
            System.Copy(FCrossRelationID, 1, AnsiPos('_', FCrossRelationID) - 1){1},
            FieldByName('crosstable').AsString{2},
            FieldByName('refcrossrelation').AsString{3},
            gdcBaseManager.AdjustMetaName(S1 + 'key'){4},
            gdcBaseManager.AdjustMetaName(S2 + 'key'){5},
            GetKeyFieldName(FieldByName('refcrossrelation').AsString){6},
            //���� ������ ������, �� ������ ����
            IntToStr(FieldByName('stringlength').AsInteger){7},
            FieldByName('fieldname').AsString{8},
            GetKeyFieldName(FieldByName('relationname').AsString){9},
            FieldByName('setlistfield').AsString {10},
            gdcBaseManager.AdjustMetaName('usr$bi_' + FieldByName('crosstable').AsString)
          ]
        );

      end;

      if DidActivate and Transaction.InTransaction then
        Transaction.Commit;
    except
      if DidActivate and Transaction.InTransaction then
        Transaction.Rollback;

      raise;
    end;
  finally
    ibsql.Free;
  end;
end;

function TgdcRelationField.CreateDefaultSQL(DefaultValue: String): String;
begin
  Result := Format(
    'UPDATE %s SET %s = %s',
    [FieldByName('relationname').AsString, FieldByName('fieldname').AsString,
    GetDefValueInQuotes(DefaultValue)]
    );
end;

function TgdcRelationField.CreateDropFieldConstraintSQL: String;
var
  Relation: TatRelation;
  RelationField: TatRelationField;
begin
  Relation := atDatabase.Relations.ByRelationName(FieldByName('relationname').AsString);
  RelationField := Relation.RelationFields.ByFieldName(FieldByName('fieldname').AsString);
  if Assigned(RelationField.ForeignKey) then
    Result := Format
    (
      'ALTER TABLE %s DROP CONSTRAINT %s',
      [
        FieldByName('relationname').AsString,
        RelationField.ForeignKey.ConstraintName
      ]
    )
  else
    Result := '';
end;

function TgdcRelationField.CreateDropCrossTableSQL: String;
begin
  Result := Format
  (
    'DROP TABLE %s',
    [FieldByName('crosstable').AsString]
  );

end;

function TgdcRelationField.CreateDropFieldSQL: String;
begin
  Result := Format
  (
    'ALTER TABLE %s DROP %s',
    [
      FieldByName('relationname').AsString,
      FieldByName('fieldname').AsString
    ]
  );

end;

function TgdcRelationField.CreateDropTriggerSQL: String;
var
  ibsql: TIBSQL;
begin
  Result := '';
  ibsql := TIBSQL.Create(Self);
  if Transaction.Active then
    ibsql.Transaction := Transaction
  else
    ibsql.Transaction := gdcBaseManager.ReadTransaction;

  try
    ibsql.SQL.Text := Format('SELECT * FROM rdb$triggers ' +
      ' WHERE (rdb$trigger_name = ''%0:s'')',
      [UpperCase(gdcBaseManager.AdjustMetaName('USR$BI_' + FieldByName('crosstable').AsString))]);
    ibsql.ExecQuery;

    if ibsql.RecordCount > 0 then
    Result := Format
    (
      'DROP TRIGGER %s',
      [gdcBaseManager.AdjustMetaName('USR$BI_' + FieldByName('crosstable').AsString)]
    );
  finally
    ibsql.Free
  end;
end;

function TgdcRelationField.CreateFieldConstraintSQL: String;
var
  NextConstraintName: String;
  TableNameWithoutPrefix: String;
begin
  NeedSingleUser := True;

  if Pos(UserPrefix, AnsiUpperCase(FieldByName('relationname').AsString)) = 1 then
    TableNameWithoutPrefix := System.copy(FieldByName('relationname').AsString, Length(UserPrefix) + 1,
      Length(FieldByName('relationname').AsString))
  else
    TableNameWithoutPrefix := FieldByName('relationname').AsString;
  NextConstraintName := gdcBaseManager.AdjustMetaName(Format(UserPrefix + 'fk%s%s',
    [TableNameWithoutPrefix, GetUniqueID(Database, ReadTransaction)]));

  Result := Format
  (
    ' ALTER TABLE %s ADD CONSTRAINT %s FOREIGN KEY (%s) REFERENCES %s (%s) ON UPDATE CASCADE ',
    [
      FieldByName('relationname').AsString,
      NextConstraintName,
      FieldByName('fieldname').AsString,
      FieldByName('RefRelationName').AsString,
      GetKeyFieldName(FieldByName('RefRelationName').AsString)
    ]
  );
  if (not FieldByName('deleterule').IsNull) and (FieldByName('deleterule').AsString <> 'RESTRICT') then
    Result := Result + Format(' ON DELETE %s', [FieldByName('deleterule').AsString]);
end;

function TgdcRelationField.CreateFieldSQL: String;
var
  ibsql: TIBSQL;
  DidActivate: Boolean;
  S: String;
begin
  ibsql := TIBSQL.Create(nil);
  try
    DidActivate := False;
    try
      DidActivate := ActivateTransaction;
      ibsql.Transaction := Transaction;

      if FieldByName('computed_value').IsNull then
      begin

        //�.�. ������ � ��� ����� ����������� � ����������������
        //���������� ���� ������� ��������
        ibsql.SQL.Text := 'SELECT * FROM at_fields WHERE fieldname = :fn';
        ibsql.ParamByName('fn').AsString := FieldByName('fieldsource').AsString;
        ibsql.ExecQuery;

        if ibsql.RecordCount = 0 then
          raise EgdcIBError.Create('��� ' + FieldByName('fieldsource').AsString +
            ' �� ������! ');

        Result := Format
        (
          'ALTER TABLE %s ADD %s %s',
          [FieldByName('relationname').AsString, FieldByName('fieldname').AsString,
          FieldByName('fieldsource').AsString]
        );

        if not FieldByName('defsource').IsNull then
        begin
          if AnsiPos('DEFAULT', AnsiUpperCase(Trim(FieldByName('defsource').AsString))) = 0 then
            Result := Result + ' DEFAULT ' +  GetDefValueInQuotes(FieldByName('defsource').AsString)
          else
            Result := Result + ' ' + FieldByName('defsource').AsString ;
        end;

        if FieldByName('nullflag').AsInteger = 1 then
        begin
          Result := Result + ' NOT NULL';
        end;
      end
      else
        if not FieldByName('computed_value').IsNull then
        begin
          S := Trim(FieldByName('computed_value').AsString);
          while (Length(S) > 0) and (S[1] = '(') and (S[Length(S)] = ')') do
            S := System.Copy(S, 2, Length(S) - 2);
          Result := Format
          (
            'ALTER TABLE %s ADD %s COMPUTED BY (%s)',
            [FieldByName('relationname').AsString, FieldByName('fieldname').AsString,
            S]
          );
        end else
          raise EgdcIBError.Create('��� ��������� ��� ������������ ����');
    except
      if DidActivate and Transaction.InTransaction then
        Transaction.Rollback;
      raise;
    end;

  finally
    ibsql.Free;
  end;
end;

procedure TgdcRelationField.CreateInvCardTrigger(ResultList: TSQLProcessList;
  const IsDrop: Boolean = False);
var
  ibsql: TIBSQL;
  isAlter: Boolean;
  CountUpdate: Integer;
  ibsqlR: TIBSQL;
  DidActivate: Boolean;
  I: Integer;
  InvTriggerName: String;
  Result: String;
  HasAdded: Boolean;
begin
  HasAdded := False;
  if ANSICompareText(FieldByName('relationname').AsString, 'INV_CARD') = 0 then
  begin
    ibsqlR := TIBSQL.Create(nil);
    ibsql := TIBSQL.Create(nil);
    DidActivate := False;
    try
      ibsqlR.Transaction := Transaction;
      DidActivate := ActivateTransaction;
      ibsql.Transaction := Transaction;
      ibsqlR.SQL.Text := 'SELECT COUNT(id) AS FCount FROM at_relation_fields ' +
        ' WHERE relationname = ''INV_CARD''' +
        '   AND fieldname LIKE ''USR$%''';
      ibsqlR.ExecQuery;
      if ibsqlR.FieldByName('fcount').AsInteger > 50 * MaxInvCardTrigger then
        raise EgdcIBError.Create('Gedemin �� ������������ ����� ' +
          IntToStr(50 * MaxInvCardTrigger) + ' ���������������� ����� � inv_card!');

      ibsqlR.Close;
      ibsqlR.SQL.Text := 'SELECT * FROM at_relation_fields WHERE relationname = ''INV_CARD''';
      ibsqlR.ExecQuery;
      if ibsqlR.RecordCount > 0 then
      begin
        for I := 1 to MaxInvCardTrigger do
        begin
          Result := '';
          if I = 1 then
            InvTriggerName := 'USR$_BU_INV_CARD'
          else
            InvTriggerName := Format('USR$%d_BU_INV_CARD', [I]);
          if not atDatabase.InMultiConnection then
          begin
            //� ���������� ������ (����� �� ����� ����������������) ��� ����� ������ ���� ����
            InvCardTriggerImitate[I] := False;
            InvCardTriggerDrop[I] := False;
          end;

          ibsql.Close;
          if atDatabase.InMultiConnection and InvCardTriggerImitate[I] then
            ibsql.SQL.Text := 'SELECT CAST(rdb$trigger_name AS VARCHAR(31)) FROM rdb$triggers t ' +
            ' WHERE t.rdb$trigger_name = ''' + InvTriggerName + ''' ' +
            ' UNION ' +
            ' SELECT CAST(triggername AS VARCHAR(31)) FROM at_triggers att  ' +
            ' WHERE att.triggername = ''' + InvTriggerName + ''''
          else
            ibsql.SQL.Text := 'SELECT CAST(rdb$trigger_name AS VARCHAR(31)) FROM rdb$triggers t ' +
            ' WHERE t.rdb$trigger_name = ''' + InvTriggerName + ''' ';

          ibsql.ExecQuery;
          //�� ����� ��������� ������� ������ � ��� ������, ���� �� ��� ���� � ����
          // � �� ���������� ���� "������� ������"
          isAlter := (ibsql.RecordCount > 0) and (not InvCardTriggerDrop[I]);
          {if isAlter then
            Result := 'ALTER TRIGGER ' + InvTriggerName + #13#10
          else}
          begin
            Result := 'CREATE OR ALTER TRIGGER ' + InvTriggerName + ' FOR INV_CARD '#13#10;
            if atDatabase.InMultiConnection then
            begin
              //���� �� � ������ ���������������, ��������, ���������� �� ��� ���� ������� � ��������� �������
              //���� �������� ���, �� ����������� ��� ��������, ����� ���� �������
              //� ��������� ���� �������� ��������
              ibsql.Close;
              ibsql.SQL.Text := ' SELECT CAST(triggername AS VARCHAR(31)) FROM at_triggers att  ' +
                ' WHERE att.triggername = ''' + InvTriggerName + '''';
              ibsql.ExecQuery;
              if ibsql.RecordCount = 0 then
              begin
                //���� �� � ������ ���������������, �� ��������� �������� ��������
                ibsql.Close;
                ibsql.SQL.Text := 'INSERT INTO at_triggers(triggername, relationname, relationkey)' +
                  'VALUES (''' + InvTriggerName + ''', ''INV_CARD'', ' +
                  ibsqlR.FieldByName('relationkey').AsString + ')';
                ibsql.ExecQuery;
                InvCardTriggerImitate[I] := True;
              end;
            end;
          end;

          Result := Result +
            '  BEFORE UPDATE '#13#10 +
            '  POSITION 10 '#13#10 +
            'AS '#13#10 +
            'BEGIN '#13#10;

          CountUpdate := 0;

          while not ibsqlR.Eof do
          begin
            if (AnsiPos(UserPrefix, AnsiUpperCase(ibsqlR.FieldByName('fieldname').AsString)) = 1) and
              (not IsDrop or
                (isDrop and (AnsiCompareText(ibsqlR.FieldByName('fieldname').AsString, FieldByName('fieldname').AsString) <> 0))
               )
            then
            begin
              Result := Result +
                Format(
                  '  IF ( '#13#10 +
                  '       (OLD.%0:s IS NULL AND NEW.%0:s IS NOT NULL) OR '#13#10 +
                  '       (OLD.%0:s IS NOT NULL AND NEW.%0:s IS NULL) OR '#13#10 +
                  '       (OLD.%0:s <> NEW.%0:s) '#13#10 +
                  '     ) '#13#10 +
                  '  THEN '#13#10 +
                  '  BEGIN '#13#10 +
                  '    IF (OLD.%0:s IS NULL) THEN '#13#10 +
                  '      UPDATE inv_card SET %0:s = NEW.%0:s '#13#10 +
                  '      WHERE parent = NEW.id AND %0:s IS NULL; '#13#10 +
                  '    ELSE '#13#10 +
                  '      UPDATE inv_card SET %0:s = NEW.%0:s '#13#10 +
                  '      WHERE parent = NEW.id AND %0:s = OLD.%0:s; '#13#10 +
                  '  END '#13#10,
                  [ibsqlR.FieldByName('fieldname').AsString]);
              Inc(CountUpdate);
              if CountUpdate = 50  then
                Break;
            end;
            ibsqlR.Next;
          end;

          if (not isDrop) and (ibsqlR.Eof) and (not HasAdded)
            and (CountUpdate < 50) then
          begin
            Result := Result +
              Format(
                '  IF ( '#13#10 +
                '       (OLD.%0:s IS NULL AND NEW.%0:s IS NOT NULL) OR '#13#10 +
                '       (OLD.%0:s IS NOT NULL AND NEW.%0:s IS NULL) OR '#13#10 +
                '       (OLD.%0:s <> NEW.%0:s) '#13#10 +
                '     ) '#13#10 +
                '  THEN '#13#10 +
                '  BEGIN '#13#10 +
                '    IF (OLD.%0:s IS NULL) THEN '#13#10 +
                '      UPDATE inv_card SET %0:s = NEW.%0:s '#13#10 +
                '      WHERE parent = NEW.id AND %0:s IS NULL; '#13#10 +
                '    ELSE '#13#10 +
                '      UPDATE inv_card SET %0:s = NEW.%0:s '#13#10 +
                '      WHERE parent = NEW.id AND %0:s = OLD.%0:s; '#13#10 +
                '  END '#13#10,
                [FieldByName('fieldname').AsString]);
            Inc(CountUpdate);
            HasAdded := True;
          end;

          if CountUpdate = 0 then
          begin
            if IsDrop then
            begin
              //���� ���� "������� ������" �� ����������, �� ������� �������
              if (not InvCardTriggerDrop[I]) and IsAlter  then
              begin
                Result := 'DROP TRIGGER ' + InvTriggerName;
                //���� �� � ������ ���������������
                //������������� ���� "������� ������" � ������
                InvCardTriggerDrop[I] := atDatabase.InMultiConnection;
              end else
                Result := '';
              //���������� ���� �������� ��������
              InvCardTriggerImitate[I] := False;
            end else
              Result := '';
          end
          else
          begin
            Result := Result + 'END';
            InvCardTriggerDrop[I] := False;
          end;

          if Result > '' then
            ResultList.Add(Result);
        end;
      end;
    finally
      ibsql.Free;
      ibsqlR.Free;
      if DidActivate and Transaction.InTransaction then
        Transaction.Commit;
    end;
  end;
end;

procedure TgdcRelationField.AlterAcEntryBalanceAndRecreateTrigger(ResultList: TSQLProcessList;
  const IsDrop: Boolean = False);
var
  ibsqlR: TIBSQL;
  DidActivate: Boolean;
  gdcField: TgdcField;
  AcEntryBalanceStr: String;
  ACTriggerText: String;
  ACFieldList, NewFieldList, OLDFieldList: String;
begin
  if (AnsiCompareText(FieldByName('relationname').AsString, 'AC_ENTRY') = 0)
     and Assigned(atDatabase.Relations.ByRelationName('AC_ENTRY_BALANCE')) then
  begin
    // ���� ���� ���������, �� ������� �������� ���, � ����� ������� �������
    //  ���� ���������, �� ��������, ������� ������� - ����� ����
    if not IsDrop then
    begin
      // ��������� ���������� ���� � AC_ENTRY_BALANCE
      AcEntryBalanceStr := Format('ALTER TABLE ac_entry_balance ADD %s %s',
        [FieldByName('fieldname').AsString, FieldByName('fieldsource').AsString]);
      ResultList.Add(AcEntryBalanceStr);
    end;

    ibsqlR := TIBSQL.Create(nil);
    gdcField := TgdcField.Create(nil);
    DidActivate := False;
    try
      gdcField.SubSet := 'ByFieldName';
      ibsqlR.Transaction := Transaction;
      DidActivate := ActivateTransaction;
      ibsqlR.SQL.Text :=
        'SELECT fieldname, fieldsource FROM at_relation_fields f WHERE relationname = ''AC_ENTRY'' AND fieldname STARTING WITH ''USR$''';
      ibsqlR.ExecQuery;

      ACFieldList := '';
      NewFieldList := '';
      OLDFieldList := '';
      while not ibsqlR.Eof do
      begin
        // ���� ���� ���������, �� �� �������� ��� � ��������������� �������
        if not isDrop or
          (IsDrop and (ANSICompareText(ibsqlR.FieldByName('fieldname').AsString, FieldByName('fieldname').AsString) <> 0)) then
        begin
          gdcField.Close;
          gdcField.ParamByName('fieldname').AsString := Trim(ibsqlR.FieldByName('fieldsource').AsString);
          gdcField.Open;

          ACFieldList := ACFieldList + ', ' + Trim(ibsqlR.FieldByName('FIELDNAME').AsString) + #13#10;
          NEWFieldList := NEWFieldList + ', NEW.' + Trim(ibsqlR.FieldByName('FIELDNAME').AsString) + #13#10;
          OLDFieldList := OLDFieldList + ', OLD.' + Trim(ibsqlR.FieldByName('FIELDNAME').AsString) + #13#10;
        end;
        
        ibsqlR.Next;
      end;

      // ���� ���� ���������
      if not IsDrop then
      begin
        ACFieldList := ACFieldList + ', ' + Trim(FieldByName('fieldname').AsString) + #13#10;
        NEWFieldList := NEWFieldList + ', NEW.' + Trim(FieldByName('fieldname').AsString) + #13#10;
        OLDFieldList := OLDFieldList + ', OLD.' + Trim(FieldByName('fieldname').AsString) + #13#10;
      end;

      ACTriggerText :=
        ' CREATE OR ALTER TRIGGER ac_entry_do_balance FOR ac_entry '#13#10 +
        ' ACTIVE AFTER INSERT OR UPDATE OR DELETE POSITION 15 '#13#10 +
        ' AS '#13#10 +
        ' BEGIN '#13#10 +
        '  IF (GEN_ID(gd_g_entry_balance_date, 0) > 0) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    IF (INSERTING AND ((NEW.entrydate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0))) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      INSERT INTO AC_ENTRY_BALANCE '#13#10 +
        '        (companykey, accountkey, currkey, '#13#10 +
        '         debitncu, debitcurr, debiteq, '#13#10 +
        '         creditncu, creditcurr, crediteq ' +
          ACFieldList + ') '#13#10 +
        '      VALUES '#13#10 +
        '     (NEW.companykey, '#13#10 +
        '      NEW.accountkey, '#13#10 +
        '      NEW.currkey, '#13#10 +
        '      NEW.debitncu, '#13#10 +
        '      NEW.debitcurr, '#13#10 +
        '      NEW.debiteq, '#13#10 +
        '      NEW.creditncu, '#13#10 +
        '      NEW.creditcurr, '#13#10 +
        '      NEW.crediteq ' +
          NEWFieldList + '); '#13#10 +
        '    END '#13#10 +
        '    ELSE '#13#10 +
        '    IF (UPDATING AND ((OLD.entrydate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0))) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      INSERT INTO AC_ENTRY_BALANCE '#13#10 +
        '        (companykey, accountkey, currkey, '#13#10 +
        '         debitncu, debitcurr, debiteq, '#13#10 +
        '         creditncu, creditcurr, crediteq ' +
          ACFieldList + ') '#13#10 +
        '      VALUES '#13#10 +
        '        (OLD.companykey, '#13#10 +
        '         OLD.accountkey, '#13#10 +
        '         OLD.currkey, '#13#10 +
        '         -OLD.debitncu, '#13#10 +
        '         -OLD.debitcurr, '#13#10 +
        '         -OLD.debiteq, '#13#10 +
        '         -OLD.creditncu, '#13#10 +
        '         -OLD.creditcurr, '#13#10 +
        '         -OLD.crediteq ' +
          OLDFieldList + '); '#13#10 +
        '      IF ((NEW.entrydate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0)) THEN '#13#10 +
        '        INSERT INTO AC_ENTRY_BALANCE '#13#10 +
        '          (companykey, accountkey, currkey, '#13#10 +
        '           debitncu, debitcurr, debiteq, '#13#10 +
        '           creditncu, creditcurr, crediteq '#13#10 +
          ACFieldList + ') '#13#10 +
        '         VALUES '#13#10 +
        '           (NEW.companykey, '#13#10 +
        '            NEW.accountkey, '#13#10 +
        '            NEW.currkey, '#13#10 +
        '            NEW.debitncu, '#13#10 +
        '            NEW.debitcurr, '#13#10 +
        '            NEW.debiteq, '#13#10 +
        '            NEW.creditncu, '#13#10 +
        '            NEW.creditcurr, '#13#10 +
        '            NEW.crediteq ' +
          NEWFieldList + '); '#13#10 +
        '    END '#13#10 +
        '    ELSE '#13#10 +
        '    IF (DELETING AND ((OLD.entrydate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0))) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      INSERT INTO AC_ENTRY_BALANCE '#13#10 +
        '        (companykey, accountkey, currkey, '#13#10 +
        '         debitncu, debitcurr, debiteq, '#13#10 +
        '         creditncu, creditcurr, crediteq '#13#10 +
          ACFieldList + ') '#13#10 +
        '      VALUES '#13#10 +
        '       (OLD.companykey, '#13#10 +
        '        OLD.accountkey, '#13#10 +
        '        OLD.currkey, '#13#10 +
        '        -OLD.debitncu, '#13#10 +
        '        -OLD.debitcurr, '#13#10 +
        '        -OLD.debiteq, '#13#10 +
        '        -OLD.creditncu, '#13#10 +
        '        -OLD.creditcurr, '#13#10 +
        '        -OLD.crediteq ' +
          OLDFieldList + '); '#13#10 +
        '    END '#13#10 +
        '  END '#13#10 +
        ' END ';

      // ������������ ������� �� AC_ENTRY
      ResultList.Add(ACTriggerText);
    finally
      ibsqlR.Free;
      gdcField.Free;
      if DidActivate and Transaction.InTransaction then
        Transaction.Commit;
    end;

    // ���� ���� ���������
    if IsDrop then
    begin
      // ������� ���� � AC_ENTRY_BALANCE
      AcEntryBalanceStr := Format('ALTER TABLE ac_entry_balance DROP %s', [FieldByName('fieldname').AsString]);
      ResultList.Add(AcEntryBalanceStr);
    end;
  end;
end;

function TgdcRelationField.NextCrossRelationName: String;
begin
  Assert(IBLogin <> nil);

  FCrossRelationID := GetUniqueID(Database, ReadTransaction) + '_' +
    IntToStr(IBLogin.DBID);
  Result := AnsiUpperCase(Format('usr$cross%s',
    [FCrossRelationID]));
end;

function GetKeyFieldName(const ARelationName: String): String;
var
  Keys: TatPrimaryKey;
  Relation: TatRelation;
  TblType: TgdcTableType;
begin
  Relation := atDatabase.Relations.ByRelationName(ARelationName);

  if Assigned(Relation) and Assigned(Relation.PrimaryKey) then
  begin
    Keys := Relation.PrimaryKey;

    if Keys.ConstraintFields.Count > 1 then
      raise EgdcIBError.Create('������ ����� ���� ����������� ������ �� ��������� ����!')
    else
      Result := Keys.ConstraintFields[0].FieldName;
  end else
  begin
    TblType := GetTableTypeByName(ARelationName);
    case TblType of
      ttDocument, ttDocumentLine, ttInvSimple,
      ttInvFeature, ttInvInvent, ttInvTransfrom: Result := 'DOCUMENTKEY';
      else Result := 'ID';
    end;
  end;
end;

//��������� �������� �� ��������� � �������
//��� ���� ���� ��������: ���� �������� ��� � ��������, �� ��� ��� � ������������
//� �������� ������, ���� ������� ����������� ������ ������, �� ��� �����������
function GetDefValueInQuotes(const DefaultValue: String): String;
var
  I: Integer;
  DefSt: String;
  L: Tcst_def_KeyWords;
begin
  if AnsiPos('DEFAULT', Trim(AnsiUpperCase(DefaultValue))) = 1 then
    DefSt := Trim(Copy(Trim(DefaultValue), 8, Length(Trim(DefaultValue)) - 1))
  else
    DefSt := DefaultValue;

  for L := Low(cst_def_KeyWords) to High(cst_def_KeyWords) do
  begin
    if AnsiCompareText(DefSt, cst_def_KeyWords[L]) = 0 then
    begin
      Result := DefSt;
      Exit;
    end;
  end;

  if (DefSt[1] = '''') and (DefSt[Length(DefSt)] = '''') then
  begin
    Result := DefSt;
  end else
  begin
    Result := '';
    for I := 1 to Length(DefSt) do
    begin
      if DefSt[I] = '''' then
        Result := Result + '''';
      Result := Result + DefSt[I];
    end;
    Result := '''' + Result + '''';
  end;

end;

function GetTableTypeByName(const ARelationName: String): TgdcTableType;
var
  R: TatRelation;
  RF: TatRelationField;
begin
  Result := ttUnknow;
  if AnsiPos(UserPrefix, AnsiUpperCase(Trim(ARelationName))) = 1 then
  begin
    R := atDatabase.Relations.ByRelationName(ARelationName);
    if not Assigned(R) then
      raise EgdcIBError.Create('������ ��� ���������� ���������. ������������� ���������!');
      
    if Assigned(R) then
    begin
      RF := R.RelationFields.ByFieldName('LB');
      if Assigned(RF) then
        Result := ttIntervalTree
      else
      begin
        RF := R.RelationFields.ByFieldName('PARENT');
        if Assigned(RF) then
          Result := ttTree
        else
        begin
          RF := R.RelationFields.ByFieldName('TOCARDKEY');
          if Assigned(RF) then
            Result := ttInvFeature
          else
          begin
            RF := R.RelationFields.ByFieldName('TOQUANTITY');
            if Assigned(RF) then
              Result := ttInvInvent
            else
            begin
              RF := R.RelationFields.ByFieldName('OUTQUANTITY');
              if Assigned(RF) then
                Result := ttInvTransfrom
              else
              begin
                RF := R.RelationFields.ByFieldName('FROMCARDKEY');
                if Assigned(RF) then
                  Result := ttInvSimple
                else
                begin
                  RF := R.RelationFields.ByFieldName('MASTERKEY');
                  if Assigned(RF) then
                    Result := ttDocumentLine
                  else
                  begin
                    RF := R.RelationFields.ByFieldName('DOCUMENTKEY');
                    if Assigned(RF) then
                      Result := ttDocument
                    else
                    begin
                      RF := R.RelationFields.ByFieldName('ID');
                      if Assigned(RF) then
                      begin
                        if RF.Field.RefTable <> nil then
                          Result := ttTableToTable
                        else begin
                          RF := R.RelationFields.ByFieldName('EDITORKEY');
                          if Assigned(RF) then
                            Result := ttSimpleTable
                          else
                            Result := ttPrimeTable;
                        end;
                      end
                      else
                        Result := ttUnknow;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

class function TgdcRelationField.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByFieldName;ByRelation;ByRelationName;';
end;

procedure TgdcRelationField.CreateFields;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCRELATIONFIELD', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATIONFIELD', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATIONFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATIONFIELD',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATIONFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('fieldsourcekey').Required := False;
  FieldByName('relationtype').Required := False;
  FieldByName('lname').Required := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATIONFIELD', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATIONFIELD', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

procedure TgdcRelationField.DoBeforePost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  ibsql: TIBSQL;
  Field: TgdcField;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCRELATIONFIELD', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATIONFIELD', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATIONFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATIONFIELD',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATIONFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  //���� defsource � ��� BLOB, ������������� ������ � ����.
  //����� �� ������ ������ ������� ���� #13#10
  FieldByName('defsource').AsString := Trim(FieldByName('defsource').AsString);

  if (not (sMultiple in BaseState)) and (not (sLoadFromStream in BaseState)) then
  begin
    ibsql := CreateReadIBSQL;
    try
      if (FieldByName('relationname').AsString > '') and
        (FieldByName('relationkey').IsNull) then
      begin
        {�� ����� ������� ������ ���� �������}
        ibsql.Close;
        ibsql.SQL.Text := 'SELECT * FROM at_relations WHERE relationname = :RN';
        ibsql.ParamByName('RN').AsString := AnsiUpperCase(Trim(FieldByName('relationname').AsString));
        ibsql.ExecQuery;
        if ibsql.RecordCount > 0 then
          FieldByName('relationkey').AsInteger := ibsql.FieldByName('id').AsInteger;
      end;

      if (Trim(FieldByName('relationname').AsString) = '') and
        (FieldByName('relationkey').AsInteger > 0) then
      begin
        {�� ����� ������� ��������� ��� �������}
        ibsql.Close;
        ibsql.SQL.Text := 'SELECT * FROM at_relations WHERE id = :id';
        ibsql.ParamByName('id').AsInteger := FieldByName('relationkey').AsInteger;
        ibsql.ExecQuery;
        if ibsql.RecordCount > 0 then
          FieldByName('relationname').AsString := ibsql.FieldByName('relationname').AsString;
      end;

      if not FieldByName('computed_value').IsNull then
      begin
        FieldByName('refrelationname').Clear;
        FieldByName('refcrossrelation').Clear;
      end;

      if FieldByName('fieldsourcekey').IsNull and
        (FieldByName('fieldsource').AsString > '') then
      begin
        {�� �������� ������ ��������� ���� ������}
        ibsql.Close;
        ibsql.SQL.Text := 'SELECT id FROM at_fields WHERE fieldname = :fieldname';
        ibsql.ParamByName('fieldname').AsString := FieldByName('fieldsource').AsString;
        ibsql.ExecQuery;
        if ibsql.RecordCount > 0 then
          FieldByName('fieldsourcekey').AsString := ibsql.FieldByName('id').AsString;
      end;

      //���������� �������� �� ������
      if FieldByName('fieldsourcekey').IsNull then
      begin
        if FieldByName('visible').IsNull then
          FieldByName('visible').AsInteger := 1;

        if FieldByName('alignment').IsNull then
          FieldByName('alignment').AsString := 'L';

        if FieldByName('colwidth').AsInteger = 0 then
          FieldByName('colwidth').AsInteger := 20;

        if FieldByName('readonly').IsNull then
          FieldByName('readonly').AsInteger := 0;
      end else
      begin
        Field := TgdcField.Create(nil);
        try
          Field.SubSet := 'ByID';
          Field.ID := StrToInt(FieldByName('fieldsourcekey').AsString);
          Field.Open;
          if Field.RecordCount > 0 then
          begin
            FieldByName('refrelationname').AsString := Field.FieldByName('reftable').AsString;
            FieldByName('refcrossrelation').AsString := Field.FieldByName('settable').AsString;
            FieldByName('setlistfield').AsString := Field.FieldByName('setlistfield').AsString;
            FieldByName('stringlength').AsString := Field.FieldByName('fcharlength').AsString;
            if Field.FieldByName('flag').AsInteger > 0 then
              FieldByName('nullflag').AsInteger := Field.FieldByName('flag').AsInteger;

            if FieldByName('visible').IsNull then
            begin
              FieldByName('visible').AsInteger := Field.FieldByName('visible').AsInteger;
            end;

            if FieldByName('format').AsString = '' then
              FieldByName('format').AsString :=
                Field.FieldByName('format').AsString;

            if FieldByName('alignment').IsNull then
            begin
              if Field.FieldByName('alignment').IsNull then
               FieldByName('alignment').AsString := 'L'
              else
                FieldByName('alignment').AsString :=
                  Field.FieldByName('alignment').AsString;
            end;

            if FieldByName('colwidth').AsInteger = 0 then
            begin
              if Field.FieldByName('colwidth').AsInteger > 0 then
                FieldByName('colwidth').AsInteger :=
                  Field.FieldByName('colwidth').AsInteger
              else
                FieldByName('colwidth').AsInteger := 20;
            end;

            if FieldByName('readonly').IsNull then
              FieldByName('readonly').AsInteger :=
                Field.FieldByName('readonly').AsInteger;

             if FieldByName('gdclassname').AsString = '' then
               FieldByName('gdclassname').AsString :=
                 Field.FieldByName('gdclassname').AsString;

             if FieldByName('gdsubtype').AsString = '' then
               FieldByName('gdsubtype').AsString :=
                 Field.FieldByName('gdsubtype').AsString;
          end;
        finally
          Field.Free;
        end;
      end;

      {��������� ������ � �����-���������}
      if (State = dsEdit) and (FieldByName('crosstable').AsString > '')
        and (FieldByName('crosstablekey').IsNull)
      then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'SELECT id FROM at_relations WHERE relationname = :relationname';
        ibsql.ParamByName('relationname').AsString := FieldByName('crosstable').AsString;
        ibsql.ExecQuery;
        if ibsql.RecordCount > 0 then
          FieldByName('crosstablekey').AsString := ibsql.FieldByName('id').AsString;
      end;

      if (FieldByName('refcrossrelation').AsString <> '') and (State = dsInsert) then
      begin
        FieldByName('crosstable').AsString :=
          NextCrossRelationName;

        FieldByName('crossfieldkey').AsString :=
          FieldByName('setlistfieldkey').AsString;

        FieldByName('crossfield').AsString :=
          FieldByName('setlistfield').AsString;
      end;

      if FieldByName('lname').AsString = '' then
        FieldByName('lname').AsString := FieldByName('fieldname').AsString;

      if FieldByName('lshortname').AsString = '' then
        FieldByName('lshortname').AsString := System.Copy(FieldByName('lname').AsString, 1,
          FieldByName('lshortname').Size);

    finally
      ibsql.Free;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATIONFIELD', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATIONFIELD', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

function TgdcRelationField.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCRELATIONFIELD', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATIONFIELD', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATIONFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATIONFIELD',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATIONFIELD' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
//����������� ������ ���� �� ��������������
  if FieldByName(GetKeyField(SubType)).AsInteger < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT %s FROM %s WHERE UPPER(relationname)=''%s'' AND UPPER(fieldname) = ''%s'' ',
      [GetKeyField(SubType), GetListTable(SubType),
       AnsiUpperCase(FieldByName('relationname').AsString),
       AnsiUpperCase(FieldByName('fieldname').AsString)]);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATIONFIELD', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATIONFIELD', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

function TgdcRelationField.GetIsUserDefined: Boolean;
begin
  Result := StrIPos(USERPREFIX, FieldByName('fieldname').AsString) = 1;
end;

procedure TgdcRelationField.DoBeforeEdit;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCRELATIONFIELD', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATIONFIELD', KEYDOBEFOREEDIT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREEDIT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATIONFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATIONFIELD',
  {M}          'DOBEFOREEDIT', KEYDOBEFOREEDIT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATIONFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FChangeComputed := False;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATIONFIELD', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATIONFIELD', 'DOBEFOREEDIT', KEYDOBEFOREEDIT);
  {M}  end;
  {END MACRO}
end;

class function TgdcRelationField.GetListFieldExtended(
  const ASubType: TgdcSubType): String;
begin
  Result := 'fieldname,relationname'
end;

function TgdcRelationField.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCRELATIONFIELD', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRELATIONFIELD', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRELATIONFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRELATIONFIELD',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRELATIONFIELD' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if HasSubSet('ByRelation') then
    Result := ' ORDER BY rdb$field_position '
  else
    Result := inherited GetOrderClause;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATIONFIELD', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATIONFIELD', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcRelationField.GetDisplayName(const ASubType: TgdcSubType): String;
begin
  Result := '����';
end;

function TgdcRelationField.GetCurrRecordClass: TgdcFullClass;
begin
  Result := inherited GetCurrRecordClass;
  if RecordCount > 0 then
  begin
    if FieldByName('relationtype').AsString = 'T' then
      Result.gdClass := CgdcBase(TgdcTableField)
    else if FieldByName('relationtype').AsString = 'V' then
      Result.gdClass := CgdcBase(TgdcViewField);
    Result.SubType := '';
  end;
end;

function TgdcRelationField.ReadObjectState(AFieldId,
  AClassName: String): Integer;
var
  F: TatRelationField;
  OL: TStringList;
begin
  Result := 2;
  if not Assigned(atDatabase) then
    atDatabase := at_Classes.atDatabase;

  F := atDatabase.FindRelationField(FieldByName('relationname').AsString,
    FieldByName('fieldname').AsString);
  if F <> nil then
  begin
    if F.InObject(AClassName) then
      Result := 1;
  end else
  begin
    OL := TStringList.Create;
    try
      OL.CommaText := FieldByName('objects').AsString;
      if OL.IndexOf(AClassName) > -1 then
        Result := 1;
    finally
      OL.Free;
    end;
  end;
end;

function TgdcRelationField.GetCanDelete: Boolean;
begin
  Result := inherited GetCanDelete and Active and
    (AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('fieldname').AsString)) = 1);
end;

procedure TgdcRelationField.DoAfterEdit;
begin
  inherited;
  if FieldByName('nullflag').IsNull then
    FieldByName('nullflag').AsInteger := 0;
end;

function TgdcRelationField.CreateCrossRelationForeign1SQL: String;
var
  S1: String;
  FName: String;
begin
  NeedSingleUser := True;
  S1 := FieldByName('relationname').AsString;
  if AnsiPos('USR$', S1) <> 1 then
    S1 := 'USR$' + S1;

  FName := GetKeyName(False, FieldByName('crosstable').AsString, GetUniqueID(Database, ReadTransaction));

  Result := Format('ALTER TABLE %0:s ADD CONSTRAINT %1:s FOREIGN KEY (%2:s) ' +
    'REFERENCES %3:s (%4:s) ON DELETE CASCADE ON UPDATE CASCADE',
    [FieldByName('crosstable').AsString, FName,
     gdcBaseManager.AdjustMetaName(S1 + 'KEY'),
     FieldByName('relationname').AsString,
     GetKeyFieldName(FieldByName('relationname').AsString),
     UserPrefix]);
end;

function TgdcRelationField.CreateCrossRelationForeign2SQL: String;
var
  S2, S1: String;
  FName: String;
begin
  NeedSingleUser := True;
  S1 := FieldByName('relationname').AsString;
  S2 := FieldByName('refcrossrelation').AsString;

  if AnsiPos('USR$', S1) <> 1 then
    S1 := 'USR$' + S1;

  if AnsiPos('USR$', S2) <> 1 then
    S2 := 'USR$' + S2;

  if S1 = S2 then
    S2 := S2 + '_r';

  FName := GetKeyName(False, FieldByName('crosstable').AsString, GetUniqueID(Database, ReadTransaction));
  Result := Format('ALTER TABLE %0:s ADD CONSTRAINT %1:s FOREIGN KEY (%2:s) ' +
    'REFERENCES %3:s (%4:s) /*ON DELETE CASCADE*/ ON UPDATE CASCADE',
    [FieldByName('crosstable').AsString, FName,
     gdcBaseManager.AdjustMetaName(S2 + 'KEY'),
     FieldByName('refcrossrelation').AsString,
     GetKeyFieldName(FieldByName('refcrossrelation').AsString),
     UserPrefix]);
end;

function TgdcRelationField.CreateCrossRelationPrimarySQL: String;
var
  S1,  S2: String;
  PName: String;
begin
  NeedSingleUser := True;
  S1 := FieldByName('relationname').AsString;
  S2 := FieldByName('refcrossrelation').AsString;

  if AnsiPos('USR$', S1) <> 1 then
    S1 := 'USR$' + S1;

  if AnsiPos('USR$', S2) <> 1 then
    S2 := 'USR$' + S2;

  if S1 = S2 then
    S2 := S2 + '_r';

  PName := GetKeyName(True, FieldByName('crosstable').AsString, GetUniqueID(Database, ReadTransaction));
  Result := Format('ALTER TABLE %0:s ADD CONSTRAINT %1:s PRIMARY KEY (%2:s, %3:s) ',
    [FieldByName('crosstable').AsString, PName,
     gdcBaseManager.AdjustMetaName(S1 + 'KEY'),
     gdcBaseManager.AdjustMetaName(S2 + 'KEY')]);
end;

function TgdcRelationField.CreateDropCrossSimulateField: String;
begin
  NeedSingleUser := True;
  Result := Format('ALTER TABLE %0:s DROP %1:s ',
    [FieldByName('crosstable').AsString,
     GetSimulateFieldNameByRel(FieldByName('crosstable').AsString)]);
end;

function TgdcRelationField.CreateAccCirculationList(const IsDrop: Boolean = False): String;
var
  ibsqlR: TIBSQL;
  DidActivate: Boolean;
  FieldList: String;
  TextSQL: String;
  gdcField: TgdcField;
begin
  Result := '';
  if ANSICompareText(Trim(FieldByName('relationname').AsString), 'AC_ENTRY') = 0 then
  begin
    ibsqlR := TIBSQL.Create(nil);
    gdcField := TgdcField.Create(nil);
    DidActivate := False;
    try
      gdcField.SubSet := 'ByFieldName';
      ibsqlR.Transaction := Transaction;
      DidActivate := ActivateTransaction;
      ibsqlR.SQL.Text := 'SELECT * FROM at_relation_fields f WHERE relationname = ''AC_ENTRY'' AND fieldname LIKE ''USR$%''';
      ibsqlR.ExecQuery;
      Result :=
        'ALTER PROCEDURE AC_ACCOUNTEXSALDO '#13#10 +
        '  (DATEEND DATE, '#13#10 +
        '   ACCOUNTKEY INTEGER, '#13#10 +
        '   FIELDNAME VARCHAR(60), '#13#10 +
        '   COMPANYKEY INTEGER, '#13#10 +
        '   ALLHOLDINGCOMPANIES INTEGER,'#13#10 +
        '   INGROUP INTEGER,'#13#10 +
        '   CURRKEY INTEGER)'#13#10 +
        'RETURNS (DEBITSALDO NUMERIC(15, 4), '#13#10 +
        '   CREDITSALDO NUMERIC(15, 4), '#13#10 +
        '   CURRDEBITSALDO NUMERIC(15,4),'#13#10 +
        '   CURRCREDITSALDO NUMERIC(15,4),'#13#10 +
        '   EQDEBITSALDO NUMERIC(15,4),'#13#10 +
        '   EQCREDITSALDO NUMERIC(15,4))'#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE SALDO NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE SALDOCURR NUMERIC(15,4);'#13#10 +
        '  DECLARE VARIABLE SALDOEQ NUMERIC(15,4);'#13#10;

      FieldList := '';
      TextSQL := '';
      while not ibsqlR.EOF do
      begin
        if not isDrop or (IsDrop and (ANSICompareText(ibsqlR.FieldByName('fieldname').AsString, FieldByName('fieldname').AsString) <> 0)) then
        begin
          gdcField.Close;
          gdcField.ParamByName('fieldname').AsString := ibsqlR.FieldByName('fieldsource').AsString;
          gdcField.Open;
          FieldList := FieldList + Format('  DECLARE VARIABLE %s ' + gdcField.GetDomainText(False, True) + ';', [ibsqlR.FieldByName('fieldname').AsString]) + #13#10;
          TextSQL := TextSQL +
          '  IF (FIELDNAME = ''' + ibsqlR.FieldByName('fieldname').AsString + ''') THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    FOR '#13#10 +
          '      SELECT ' + ibsqlR.FieldByName('fieldname').AsString + ', SUM(e.debitncu - e.creditncu), '#13#10 +
          '        SUM(e.debitcurr - e.creditcurr), '#13#10 +
          '        SUM(e.debiteq - e.crediteq)'#13#10 +
          '        FROM ac_entry e LEFT JOIN ac_record r ON e.recordkey = r.id '#13#10 +
          '        WHERE e.accountkey = :accountkey and e.entrydate < :DATEEND AND '#13#10 +
          '        (r.companykey = :companykey OR'#13#10 +
          '        (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
          '        r.companykey IN ('#13#10 +
          '          SELECT'#13#10 +
          '            h.companykey'#13#10 +
          '          FROM'#13#10 +
          '            gd_holding h'#13#10 +
          '          WHERE'#13#10 +
          '            h.holdingkey = :companykey))) AND'#13#10 +
          '        G_SEC_TEST(r.aview, :ingroup) <> 0 AND'#13#10 +
          '        ((0 = :currkey) OR (e.currkey = :currkey))'#13#10 +
          '      GROUP BY ' + ibsqlR.FieldByName('fieldname').AsString + ' '#13#10 +
          '      INTO :' + ibsqlR.FieldByName('fieldname').AsString + ', :SALDO, :SALDOCURR, :SALDOEQ '#13#10 +
          '    DO '#13#10 +
          '    BEGIN '#13#10 +
          '      IF (SALDO IS NULL) THEN '#13#10 +
          '        SALDO = 0; '#13#10 +
          '      IF (SALDO > 0) THEN '#13#10 +
          '        DEBITSALDO = DEBITSALDO + SALDO; '#13#10 +
          '      ELSE '#13#10 +
          '        CREDITSALDO = CREDITSALDO - SALDO; '#13#10 +
          '      IF (SALDOCURR IS NULL) THEN'#13#10 +
          '         SALDOCURR = 0;'#13#10 +
          '       IF (SALDOCURR > 0) THEN'#13#10 +
          '         CURRDEBITSALDO = CURRDEBITSALDO + SALDOCURR;'#13#10 +
          '       ELSE'#13#10 +
          '         CURRCREDITSALDO = CURRCREDITSALDO - SALDOCURR;'#13#10 +
          '      IF (SALDOEQ IS NULL) THEN'#13#10 +
          '         SALDOEQ = 0;'#13#10 +
          '       IF (SALDOEQ > 0) THEN'#13#10 +
          '         EQDEBITSALDO = EQDEBITSALDO + SALDOEQ;'#13#10 +
          '       ELSE'#13#10 +
          '         EQCREDITSALDO = EQCREDITSALDO - SALDOEQ;'#13#10 +
          '    END '#13#10 +
          '  END '#13#10;
        end;
        ibsqlR.Next
      end;
      Result := Result + FieldList +
        'BEGIN '#13#10 +
        '  DEBITSALDO = 0; '#13#10 +
        '  CREDITSALDO = 0; '#13#10 +
        '  CURRDEBITSALDO = 0; '#13#10 +
        '  CURRCREDITSALDO = 0; '#13#10 +
        '  EQDEBITSALDO = 0; '#13#10 +
        '  EQCREDITSALDO = 0; '#13#10 +
        TextSQL + '  SUSPEND; '#13#10 +
        'END '#13#10;
    finally
      ibsqlR.Free;
      if DidActivate and Transaction.InTransaction then
        Transaction.Commit;
    end;
  end;
end;

function TgdcRelationField.GetKeyName(IsPrimary: Boolean;
  ARelationName: String; UniqueID: String): String;
var
  S: String;
begin
  if IsPrimary then
    S := 'PK_' + ARelationName + '_' + UniqueID
  else
    S := 'FK_' + ARelationName + '_' + UniqueID;
  Result := gdcBaseManager.AdjustMetaName(S);
end;

function TgdcRelationField.GetCanEdit: Boolean;
begin
  if State = dsInsert then
    Result := True
  else
    Result := TestUserRights([tiAChag]);
end;

{ TgdcTableField }

constructor TgdcTableField.Create(AnOwner: TComponent);
begin
  inherited;
  FFieldList := TStringList.Create;
  FFieldList.Sorted := True;
end;

procedure TgdcTableField._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCTABLEFIELD', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTABLEFIELD', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTABLEFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTABLEFIELD',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTABLEFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('relationtype').AsString := 'T';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTABLEFIELD', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTABLEFIELD', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

class function TgdcTableField.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmTable';
end;

function TgdcTableField.CheckFieldName: Boolean;
begin
  Result := True;

  if Assigned(atDatabase) then
  begin
    if Assigned(atDatabase.FindRelationField(FieldByName('relationname').AsString,
      FieldByName('fieldname').AsString))
    then
    begin
      Result := False;
    end else

    if CachedUpdates then
    begin
      if FFieldList.IndexOf(AnsiUpperCase(FieldByName('fieldname').AsString) + '=' +
        AnsiUpperCase(FieldByName('relationname').AsString)) > -1
      then
        Result := False;
    end;

  end;
end;

procedure TgdcTableField.DoBeforeInsert;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  BM: TBookmarkStr;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCTABLEFIELD', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTABLEFIELD', KEYDOBEFOREINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTABLEFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTABLEFIELD',
  {M}          'DOBEFOREINSERT', KEYDOBEFOREINSERT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTABLEFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  if CachedUpdates then
  begin
    FFieldList.Clear;
    DisableControls;
    BM := BookMark;

    First;
    while not EOF do
    begin
      FFieldList.Add(AnsiUpperCase(FieldByName('fieldname').AsString) + '=' +
        AnsiUpperCase(FieldByName('relationname').AsString));
      Next;
    end;

    BookMark := BM;
    EnableControls;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTABLEFIELD', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTABLEFIELD', 'DOBEFOREINSERT', KEYDOBEFOREINSERT);
  {M}  end;
  {END MACRO}
end;

destructor TgdcTableField.Destroy;
begin
  FFieldList.Free;
  inherited;
end;

procedure TgdcTableField.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCTABLEFIELD', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTABLEFIELD', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTABLEFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTABLEFIELD',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTABLEFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  //�������� �� ������������ ������������ ����
  if (State = dsInsert) and (not CheckFieldName)
  then
  begin
    FieldByName('fieldname').FocusControl;
    raise EgdcIBError.Create('�������� ���� ����������� � ��� ������������!');
  end;

  //���� �� �������� ������������� ���� � ��� ���� �� ������� ���
  if (State = dsInsert) and FieldByName('computed_value').IsNull and
    FieldByName('fieldsourcekey').IsNull and FieldByName('fieldsource').IsNull then
  begin
    FieldByName('fieldsourcekey').FocusControl;
    raise EgdcIBError.Create('�������� ��� ����!');
  end;

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTABLEFIELD', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTABLEFIELD', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

{ TgdcViewField }

constructor TgdcViewField.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpModify, cpDelete];
end;

procedure TgdcViewField.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCVIEWFIELD', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCVIEWFIELD', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCVIEWFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCVIEWFIELD',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCVIEWFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCVIEWFIELD', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCVIEWFIELD', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

class function TgdcViewField.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmRelation';
end;

procedure TgdcViewField._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCVIEWFIELD', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCVIEWFIELD', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCVIEWFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCVIEWFIELD',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCVIEWFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('relationtype').AsString := 'V';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCVIEWFIELD', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCVIEWFIELD', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

{ TgdcStoredProc }

function TgdcStoredProc.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCSTOREDPROC', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSTOREDPROC', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSTOREDPROC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSTOREDPROC',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSTOREDPROC' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
//����������� ������ ���� �� ��������������
  if FieldByName(GetKeyField(SubType)).AsInteger < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT %s FROM %s WHERE UPPER(procedurename) = ''%s''',
      [GetKeyField(SubType), GetListTable(SubType),
       AnsiUpperCase(FieldByName('procedurename').AsString)]);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSTOREDPROC', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSTOREDPROC', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

constructor TgdcStoredProc.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  CustomProcess := [cpInsert, cpModify, cpDelete];
end;

function TgdcStoredProc.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCSTOREDPROC', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSTOREDPROC', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSTOREDPROC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSTOREDPROC',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSTOREDPROC' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_attr_dlgStoredProc.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSTOREDPROC', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSTOREDPROC', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcStoredProc.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCSTOREDPROC', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSTOREDPROC', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSTOREDPROC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSTOREDPROC',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSTOREDPROC' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('procedurename').AsString)) = 0 then
    raise EgdcIBError.Create('�� �� ������ ������� ����������������� ���������!');

  DropStoredProc;
  inherited;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSTOREDPROC', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSTOREDPROC', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcStoredProc.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCSTOREDPROC', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSTOREDPROC', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSTOREDPROC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSTOREDPROC',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSTOREDPROC' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  FieldByName('RDB$PROCEDURE_NAME').AsString := AnsiUpperCase(FieldByName('procedurename').AsString);

  SaveStoredProc(True);
  CustomExecQuery(
    'UPDATE rdb$procedures SET rdb$description = :new_rdb$description ' +
    ' WHERE rdb$procedure_name = :new_rdb$procedure_name ', Buff, False);

  inherited;

  atDatabase.Fields.RefreshData(Database, Transaction);
  atDatabase.Relations.RefreshData(Database, Transaction, True);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSTOREDPROC', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSTOREDPROC', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcStoredProc.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCSTOREDPROC', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSTOREDPROC', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSTOREDPROC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSTOREDPROC',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSTOREDPROC' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if IsSaveToStream then
  //��� ���������� � ����� �� ��������� ������ ���� ���� - proceduresource
    inherited
  else
  begin
    if (Pos('ALTER PROCEDURE', AnsiUpperCase(FieldByName('rdb$procedure_source').AsString)) > 0)
      or (sLoadFromStream in BaseState)
    then
      SaveStoredProc(False);

    CustomExecQuery(
      'UPDATE rdb$procedures SET rdb$description = :new_rdb$description ' +
      ' WHERE rdb$procedure_name = :new_rdb$procedure_name ', Buff);

    inherited;
    atDatabase.Fields.RefreshData(Database, Transaction);
    atDatabase.Relations.RefreshData(Database, Transaction, True);
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSTOREDPROC', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSTOREDPROC', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcStoredProc.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCSTOREDPROC', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSTOREDPROC', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSTOREDPROC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSTOREDPROC',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSTOREDPROC' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  if (Trim(FieldByName('rdb$procedure_source').AsString) = '') then
    raise Exception.Create('���� ��������� ������!');

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSTOREDPROC', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSTOREDPROC', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcStoredProc.DropStoredProc;
var
  FSQL: TSQLProcessList;
begin
  FSQL := TSQLProcessList.Create;
  try
    FSQL.Add('DROP PROCEDURE ' + FieldByName('procedurename').AsString);
    ShowSQLProcess(FSQL);
  finally
    FSQL.Free;
  end;
end;

function TgdcStoredProc.GetAlterProcedureText: String;
begin
  Result := Format('ALTER PROCEDURE %0:s ' + GetParamsText + ' AS'#13#10'%1:s',
    [FieldByName('procedurename').AsString,
     FieldByName('rdb$procedure_source').AsString]);
end;

function TgdcStoredProc.GetCanDelete: Boolean;
begin
  Result := inherited GetCanDelete and Active and
    (AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('procedurename').AsString)) = 1);
end;

function TgdcStoredProc.GetCanEdit: Boolean;
begin
  Result := inherited GetCanEdit and Active and
    (AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('procedurename').AsString)) = 1);
end;

function TgdcStoredProc.GetCreateProcedureText: String;
begin
  Result := Format('CREATE PROCEDURE %0:s ' + GetParamsText + ' AS'#13#10'%1:s',
    [FieldByName('procedurename').AsString,
     FieldByName('rdb$procedure_source').AsString]);
end;

class function TgdcStoredProc.GetDisplayName(const ASubType: TgdcSubType): String;
begin
  Result := '���������';
end;

function TgdcStoredProc.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCSTOREDPROC', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSTOREDPROC', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSTOREDPROC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSTOREDPROC',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSTOREDPROC' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' FROM at_procedures z LEFT JOIN rdb$procedures p ' +
    ' ON p.rdb$procedure_name = z.procedurename ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSTOREDPROC', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSTOREDPROC', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcStoredProc.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'id';
end;

class function TgdcStoredProc.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'procedurename';
end;

class function TgdcStoredProc.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'at_procedures';
end;

function TgdcStoredProc.GetParamsText: String;
var
  ibsql: TIBSQl;
  S1, S2: String;
  gdcField: TgdcField;
begin
  Result := '';
  ibsql := CreateReadIBSQL;
  gdcField := TgdcField.Create(Self);
  try
    gdcField.Database := Database;
    gdcField.Transaction := Transaction;

    gdcField.SubSet := 'ByFieldName';

    ibsql.SQL.Text := 'SELECT * FROM rdb$procedure_parameters pr ' +
                      'WHERE pr.rdb$procedure_name = :pn AND pr.rdb$parameter_type = :pt ' +
                      'ORDER BY pr.rdb$parameter_number ASC ';
    ibsql.ParamByName('pn').AsString := FieldByName('procedurename').AsString;
    ibsql.ParamByName('pt').AsInteger := 0;
    ibsql.ExecQuery;

    S1 := '';
    while not ibsql.EOF do
    begin
      gdcField.ParamByName('fieldname').AsString := ibsql.FieldByName('rdb$field_source').AsString;
      gdcField.Open;
      if S1 = '' then
        S1 := '('#13#10;
      S1 := S1 + '    ' + Trim(ibsql.FieldByName('rdb$parameter_name').AsString) + ' ' +
         gdcField.GetDomainText(False, True);
      ibsql.Next;
      if not ibsql.EOF then
        S1 := S1 + ','#13#10
      else
        S1 := S1 + ')';
      gdcField.Close;
    end;

    S1 := S1 + #13#10;

    ibsql.Close;
    ibsql.ParamByName('pt').AsInteger := 1;

    ibsql.ExecQuery;
    S2 := '';
    while not ibsql.EOF do
    begin
      gdcField.ParamByName('fieldname').AsString := ibsql.FieldByName('rdb$field_source').AsString;
      gdcField.Open;
      if S2 = '' then
        S2 := 'RETURNS ( '#13#10;
      S2 := S2 + '    ' + Trim(ibsql.FieldByName('rdb$parameter_name').AsString) + ' ' + gdcField.GetDomainText(False, True);
      gdcField.Close;
      ibsql.Next;
      if not ibsql.EOF then
        S2 := S2 + ','#13#10
      else
        S2 := S2 + ')'#13#10;
    end;

    Result := S1 + S2;
  finally
    ibsql.Free;
    gdcField.Free;
  end;
end;

function TgdcStoredProc.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCSTOREDPROC', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSTOREDPROC', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSTOREDPROC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSTOREDPROC',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSTOREDPROC' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := 'SELECT z.*, p.rdb$procedure_name, ' +
            'p.rdb$procedure_id, ' +
            'p.rdb$procedure_inputs, ' +
            'p.rdb$procedure_outputs, ' +
            'p.rdb$description, ' +
            'p.rdb$procedure_source, ' +
            'p.rdb$procedure_blr, ' +
            'p.rdb$security_class, ' +
            'p.rdb$owner_name, ' +
            'p.rdb$runtime, ' +
            'p.rdb$system_flag ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSTOREDPROC', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSTOREDPROC', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcStoredProc.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByProcName;';
end;

class function TgdcStoredProc.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_attr_frmStoredProc';
end;

procedure TgdcStoredProc.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('OnlyAttribute') then
    S.Add('z.procedurename LIKE ''USR$%''');
  if HasSubSet('ByProcName') then
    S.Add('z.procedurename = :procedurename');
end;

procedure TgdcStoredProc.SaveStoredProc(const isNew: Boolean);
var
  FSQL: TSQLProcessList;
  BracketPos: Integer;
begin
  FSQL := TSQLProcessList.Create;
  try
    if (sLoadFromStream in BaseState) then
    begin
      if isNew then
        //� ���� proceduresource �������� ����� ��� �������� ���������
        FSQL.Add(FieldByName('proceduresource').AsString)
      else
      begin
        //���� �� ��������� � ������ �����������, �� ������� Create �� Alter
        FSQL.Add('ALTER ' +  System.Copy(Trim(FieldByName('proceduresource').AsString), Length('CREATE') + 1,
          Length(FieldByName('proceduresource').AsString) - Length('CREATE')));
      end;
    end
    else if sCopy in BaseState then
    begin
      // ��� ����������� ��������� ��������� ��� �� ��������� � �� �� ����� �������� �� ����� GetParamText
      // ������� ��������� ����� �������
      BracketPos := Pos('(', FieldByName('proceduresource').AsString);

      FSQL.Add(Format('CREATE PROCEDURE %0:s %1:s',
        [FieldByName('procedurename').AsString,
         System.Copy(FieldByName('proceduresource').AsString, BracketPos,
           Length(FieldByName('proceduresource').AsString) - BracketPos + 1)]));
    end
    else
      FSQL.Add(FieldByName('rdb$procedure_source').AsString);

    if isNew then
      FSQL.Add(Format('GRANT EXECUTE ON PROCEDURE %s TO administrator',
        [FieldByName('procedurename').AsString]));

    ShowSQLProcess(FSQL);
  finally
    FSQL.Free;
    NeedSingleUser := False;
  end;
end;

procedure TgdcStoredProc._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCSTOREDPROC', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSTOREDPROC', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSTOREDPROC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSTOREDPROC',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSTOREDPROC' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('rdb$procedure_source').AsString :=
    #13#10'BEGIN '#13#10 + (*'  SUSPEND;'*)#13#10 + 'END;';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSTOREDPROC', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSTOREDPROC', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcStoredProc.PrepareToSaveToStream(BeforeSave: Boolean);
begin
  if BeforeSave then
  begin
    IsSaveToStream := True;
    Edit;
    FieldByName('proceduresource').AsString := GetCreateProcedureText;
    Post;
  end
  else
    IsSaveToStream := False;
end;

procedure TgdcStoredProc._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet;
  PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True);
begin
  Assert(State = dsBrowse);
  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('procedurename').AsString)) =  1
  then
    SaveToStreamDependencies(Stream, ObjectSet,
      FieldByName('procedurename').AsString, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
  IsSaveToStream := True;
  try
    Edit;
    FieldByName('proceduresource').AsString := GetCreateProcedureText;
    Post;
    inherited;
  finally
    IsSaveToStream := False;
  end;

end;

{ TgdcSimpleTable }

procedure TgdcSimpleTable.CreateRelationSQL(Scripts: TSQLProcessList);
begin
  Scripts.Add(CreateSimpleTable);
  Scripts.Add(CreateEditorForeignKey);
  if (not (sLoadFromStream in BaseState)) then
  begin
    Scripts.Add(CreateInsertTrigger);
    Scripts.Add(CreateInsertEditorTrigger);
    Scripts.Add(CreateUpdateEditorTrigger);
  end;
  Scripts.Add(CreateGrantSQL);
end;

function TgdcSimpleTable.CreateSimpleTable: String;
begin
  Result := Format
  (
    'CREATE TABLE %0:s (id dintkey, disabled ddisabled, editiondate deditiondate, ' +
    'editorkey dintkey, PRIMARY KEY (id))',
    [FieldByName('relationname').AsString]
  );
end;


class function TgdcSimpleTable.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  Result := '������� � ���������������';
end;

procedure TgdcSimpleTable.MakePredefinedRelationFields;
begin
  inherited;
  if (State = dsInsert) and Assigned(gdcTableField) then
  begin
    NewField('DISABLED',
      '�� �������', 'DDISABLED', '�� �������', '�� �������',
      'L', '10', '1', '0');
    NewField('EDITIONDATE',
      '���� �����������', 'DEDITIONDATE', '���� �����������', '���� �����������',
      'L', '20', '1', '0');
    NewField('EDITORKEY',
      '��� �������������', 'DINTKEY', '��� �������������', '��� �������������',
      'L', '20', '1', '0');
  end;

end;

procedure TgdcSimpleTable._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCSIMPLETABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSIMPLETABLE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSIMPLETABLE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSIMPLETABLE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSIMPLETABLE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FTableType := ttSimpleTable;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSIMPLETABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSIMPLETABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

{ TgdcTreeTable }

procedure TgdcTreeTable.CreateRelationSQL(Scripts: TSQLProcessList);
begin
  Scripts.Add(CreateTreeTable);
  Scripts.Add(CreateEditorForeignKey);
  if (not (sLoadFromStream in BaseState)) then
  begin
    Scripts.Add(CreateInsertTrigger);
    Scripts.Add(CreateInsertEditorTrigger);
    Scripts.Add(CreateUpdateEditorTrigger);
  end;
  Scripts.Add(CreateGrantSQL);
end;

function TgdcTreeTable.CreateTreeTable: String;
begin
  NeedSingleUser := True;

  Result := Format
  (
    'CREATE TABLE %0:s ( id dintkey, parent dforeignkey, disabled ddisabled,' +
    'editiondate deditiondate, ' +
    'editorkey dintkey, ' +
    'PRIMARY KEY (id), ' +
    'FOREIGN KEY (parent) REFERENCES %0:s (id) ' +
    'ON DELETE CASCADE ON UPDATE CASCADE )',
    [FieldByName('relationname').AsString]
  );

end;

class function TgdcTreeTable.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  Result := '������� ������';
end;

procedure TgdcTreeTable.MakePredefinedRelationFields;
begin
  inherited;

  if (State = dsInsert) and Assigned(gdcTableField) then
  begin
    NewField('PARENT',
      '��������', 'DFOREIGNKEY', '��������', '��������',
      'L', '10', '1', '0');
    NewField('DISABLED',
      '�� �������', 'DDISABLED', '�� �������', '�� �������',
      'L', '10', '1', '0');
    NewField('EDITIONDATE',
      '���� �����������', 'DEDITIONDATE', '���� �����������', '���� �����������',
      'L', '20', '1', '0');
    NewField('EDITORKEY',
      '��� �������������', 'DINTKEY', '��� �������������', '��� �������������',
      'L', '20', '1', '0');
  end;

end;


procedure TgdcTreeTable._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCTREETABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTREETABLE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTREETABLE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTREETABLE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTREETABLE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FTableType := ttTree;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTREETABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTREETABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

{ TgdcLBRBTreeTable }

procedure TgdcLBRBTreeTable.MakePredefinedRelationFields;
begin
  inherited;
  if (State = dsInsert) and Assigned(gdcTableField) then
  begin
    NewField('PARENT',
      '��������', 'DFOREIGNKEY', '��������', '��������',
      'L', '10', '1', '0');
    NewField('LB',
      '����� �������', 'DLB', '����� �������', '����� �������',
      'L', '10', '1', '0');
    NewField('RB',
      '������ �������', 'DRB', '������ �������', '������ �������',
      'L', '10', '1', '0');
    NewField('DISABLED',
      '�� �������', 'DDISABLED', '�� �������', '�� �������',
      'L', '10', '1', '0');
    NewField('EDITIONDATE',
      '���� �����������', 'DEDITIONDATE', '���� �����������', '���� �����������',
      'L', '20', '1', '0');
    NewField('EDITORKEY',
      '��� �������������', 'DINTKEY', '��� �������������', '��� �������������',
      'L', '20', '1', '0');
  end;
end;

function TgdcLBRBTreeTable.CreateIntervalTreeTable: String;
begin
  NeedSingleUser := True;

  Result := Format
  (
    'CREATE TABLE %0:s (id dintkey, parent dforeignkey, lb dlb, rb drb, disabled ddisabled,' +
    'editiondate deditiondate, ' +
    'editorkey dintkey, ' +
    'PRIMARY KEY (id), ' +
    'FOREIGN KEY (parent) ' +
    'REFERENCES %0:s (id) ON DELETE CASCADE ON UPDATE CASCADE/*, CHECK(lb <= rb) */ )',
    [FieldByName('relationname').AsString]
  );
end;

class function TgdcLBRBTreeTable.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  Result := '������������ ������';
end;

procedure TgdcLBRBTreeTable.CreateRelationSQL(Scripts: TSQLProcessList);
var
  N: String;
  SL: TStringList;
  I: Integer;
begin
  Scripts.Add(CreateIntervalTreeTable);
  Scripts.Add(CreateGrantSQL);
  Scripts.Add(CreateEditorForeignKey);
  if (not (sLoadFromStream in BaseState)) then
  begin
    Scripts.Add(CreateInsertEditorTrigger);
    Scripts.Add(CreateUpdateEditorTrigger);

    N := FieldByName('relationname').AsString;
    if StrIPos(UserPrefix, N) = 1 then
      System.Delete(N, 1, Length(UserPrefix));
    if StrIPos('_', N) = 1 then
      System.Delete(N, 1, 1);

    SL := TStringList.Create;
    try
      CreateLBRBTreeMetaDataScript(SL, UserPrefix, N, FieldByName('relationname').AsString);
      for I := 0 to SL.Count - 1 do
      begin
        Scripts.Add(SL[I]);
      end;
    finally
      SL.Free;
    end;

    //����� ��������� ���������������, ����� ������������������ ���������
    atDatabase.NotifyMultiConnectionTransaction;
  end;
end;

procedure TgdcLBRBTreeTable._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCLBRBTREETABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCLBRBTREETABLE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCLBRBTREETABLE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCLBRBTREETABLE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCLBRBTREETABLE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FTableType := ttIntervalTree;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCLBRBTREETABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCLBRBTREETABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcLBRBTreeTable.DropTable;
var
  ibsql: TIBSQL;
  FSQL: TSQLProcessList;
begin
  ibsql := CreateReadIBSQL;
  FSQL := TSQLProcessList.Create;
  try

    ibsql.SQL.Text := Format('SELECT * FROM rdb$dependencies WHERE rdb$depended_on_name = :depname ' +
      ' AND (rdb$dependent_type = 1 OR rdb$dependent_type = 5) AND ' +
      ' (rdb$dependent_name <> ''%1:s'') AND ' +
      ' (rdb$dependent_name <> ''%2:s'') AND ' +
      ' (rdb$dependent_name <> ''%3:s'')',
      [FieldByName('relationname').AsString,
       AnsiUpperCase(gdcBaseManager.AdjustMetaName('USR$_P_CHLDCT_' + FieldByName('relationname').AsString)),
       AnsiUpperCase(gdcBaseManager.AdjustMetaName('USR$_P_EXLIM_' + FieldByName('relationname').AsString)),
       AnsiUpperCase(gdcBaseManager.AdjustMetaName('USR$_P_RESTR_' + FieldByName('relationname').AsString))]);
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
      raise EgdcIBError.Create('������ ������� ������� �.�. ��� ������������ � ���������� ��� ��������������');

    ibsql.Close;
    ibsql.SQL.Text := Format('SELECT * FROM rdb$triggers ' +
      ' WHERE (rdb$trigger_name = ''%0:s'') OR ' +
      ' (rdb$trigger_name = ''%1:s'')',
      [AnsiUpperCase(gdcBaseManager.AdjustMetaName('USR$BI_' + FieldByName('relationname').AsString)),
       AnsiUpperCase(gdcBaseManager.AdjustMetaName('USR$BU_' + FieldByName('relationname').AsString))]);
    ibsql.ExecQuery;
    while not ibsql.Eof do
    begin
      FSQL.Add(Format('DROP TRIGGER %0:s',
        [ibsql.FieldByName('rdb$trigger_name').AsString]), False);
      ibsql.Next;
    end;

    ibsql.Close;
    ibsql.SQL.Text := Format('SELECT * FROM rdb$procedures ' +
      ' WHERE (rdb$procedure_name = ''%0:s'')',
      [AnsiUpperCase(gdcBaseManager.AdjustMetaName('USR$_P_RESTR_' + FieldByName('relationname').AsString))]);
    ibsql.ExecQuery;
    while not ibsql.Eof do
    begin
      FSQL.Add(Format('DROP PROCEDURE %0:s',
        [ibsql.FieldByName('rdb$procedure_name').AsString]), False);
      ibsql.Next;
    end;

    ibsql.Close;
    ibsql.SQL.Text := Format('SELECT * FROM rdb$procedures ' +
      ' WHERE (rdb$procedure_name = ''%0:s'') ',
      [AnsiUpperCase(gdcBaseManager.AdjustMetaName('USR$_P_EXLIM_' + FieldByName('relationname').AsString))]);
    ibsql.ExecQuery;
    while not ibsql.Eof do
    begin
      FSQL.Add(Format('DROP PROCEDURE %0:s',
        [ibsql.FieldByName('rdb$procedure_name').AsString]), False);
      ibsql.Next;
    end;

    ibsql.Close;
    ibsql.SQL.Text := Format('SELECT * FROM rdb$procedures ' +
      ' WHERE (rdb$procedure_name = ''%0:s'') ',
      [AnsiUpperCase(gdcBaseManager.AdjustMetaName('USR$_P_CHLDCT_' + FieldByName('relationname').AsString))]);
    ibsql.ExecQuery;
    while not ibsql.Eof do
    begin
      FSQL.Add(Format('DROP PROCEDURE %0:s',
        [ibsql.FieldByName('rdb$procedure_name').AsString]), False);
      ibsql.Next;
    end;

    ibsql.Close;
    ibsql.SQL.Text := Format('SELECT * FROM rdb$exceptions ' +
      ' WHERE (rdb$exception_name = ''%0:s'') ',
      [AnsiUpperCase(gdcBaseManager.AdjustMetaName('USR$_E_TR_' + FieldByName('relationname').AsString))]);
    ibsql.ExecQuery;
    while not ibsql.Eof do
    begin
      FSQL.Add(Format('DROP EXCEPTION %0:s',
        [ibsql.FieldByName('rdb$exception_name').AsString]), False);
      ibsql.Next;
    end;

    ibsql.Close;
    ibsql.SQL.Text := 'SELECT * FROM rdb$triggers WHERE rdb$relation_name = :relname AND rdb$system_flag = 0';
    ibsql.ParamByName('relname').AsString := FieldByName('relationname').AsString;
    ibsql.ExecQuery;
    while not ibsql.EOF do
    begin
      FSQL.Add(Format('DROP TRIGGER %S',
        [ibsql.FieldByName('rdb$trigger_name').AsString]), False);
      ibsql.Next;
    end;

    ibsql.Close;
    ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints WHERE rdb$relation_name = :relname ' +
      'AND rdb$constraint_type = ''FOREIGN KEY'' ';
    ibsql.ParamByName('relname').AsString := FieldByName('relationname').AsString;
    ibsql.ExecQuery;
    while not ibsql.EOF do
    begin
      FSQL.Add(Format('ALTER TABLE %s DROP CONSTRAINT %s ',
        [FieldByName('relationname').AsString,
         ibsql.FieldByName('rdb$constraint_name').AsString]), False);
      ibsql.Next;
    end;

    ibsql.Close;
    ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints WHERE rdb$relation_name = :relname ' +
      'AND rdb$constraint_type = ''PRIMARY KEY'' ';
    ibsql.ParamByName('RELNAME').AsString := FieldByName('relationname').AsString;
    ibsql.ExecQuery;
    while not ibsql.EOF do
    begin
      FSQL.Add(Format('ALTER TABLE %s DROP CONSTRAINT %s ',
        [FieldByName('relationname').AsString,
         ibsql.FieldByName('rdb$constraint_name').AsString]), False);
      ibsql.Next;
    end;

    ibsql.Close;
    DropCrossTable;
    FSQL.Add('DROP TABLE ' + FieldByName('relationname').AsString);
    FSQL.Add(Format('DELETE FROM GD_COMMAND WHERE classname = ''TgdcAttrUserDefinedLBRBTree'' AND ' +
      ' UPPER(SubType) = UPPER(''%s'')', [FieldByName('relationname').AsString]));

    ibsql.Close;

    atDatabase.NotifyMultiConnectionTransaction;
    ShowSQlProcess(FSQL);
  finally
    ibsql.Free;
    FSQL.Free;
  end;
end;

procedure TgdcLBRBTreeTable._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet; PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean);
const
  PrNameArray: array [1..3] of String =
    ('USR$_P_EXLIM_%0:S',
     'USR$_P_CHLDCT_%0:S',
     'USR$_P_RESTR_%0:S');
var
  AnObject: TgdcStoredProc;
  I: Integer;
begin
  inherited;
  { TODO -o��� : ������������� �������� ������� ������ ��� ������������ ���������.
  ���� ��������� � ��������� ������ ��������� �������, �� �� ������ ��������� ... }
  AnObject := TgdcStoredProc.CreateSubType(nil, '', 'ByProcName');
  try
    for I := 1 to Length(PrNameArray) do
    begin
      AnObject.Close;
      AnObject.ParamByName('procedurename').AsString :=
        gdcBaseManager.AdjustMetaName(Format(PrNameArray[I],
          [AnsiUpperCase(FieldByName('relationname').AsString)]));
      AnObject.Open;
      if (AnObject.ID <> ID) and (AnObject.RecordCount > 0) then
        AnObject._SaveToStream(Stream, ObjectSet, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
    end;
  finally
    AnObject.Free;
  end;
end;

{ TgdcMetaBase }

function TgdcMetaBase.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCMETABASE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMETABASE', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMETABASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMETABASE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMETABASE' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited CheckTheSameStatement;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMETABASE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMETABASE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcMetaBase.CommitRequired: Boolean;
begin
  Result := True;
end;

constructor TgdcMetaBase.Create(AnOwner: TComponent);
begin
  inherited;
  NeedSingleUser := False;
  FPostedID := -1;
end;

procedure TgdcMetaBase.DoAfterPost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCMETABASE', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMETABASE', KEYDOAFTERPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMETABASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMETABASE',
  {M}          'DOAFTERPOST', KEYDOAFTERPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMETABASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  inherited;

  if Transaction.InTransaction then
    FPostedID := ID
  else
    FPostedID := -1;  

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMETABASE', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMETABASE', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcMetaBase.DoAfterTransactionEnd(Sender: TObject);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_SENDER('TGDCMETABASE', 'DOAFTERTRANSACTIONEND', KEYDOAFTERTRANSACTIONEND)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMETABASE', KEYDOAFTERTRANSACTIONEND);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERTRANSACTIONEND]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMETABASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(Sender)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMETABASE',
  {M}          'DOAFTERTRANSACTIONEND', KEYDOAFTERTRANSACTIONEND, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMETABASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if (FPostedID > 0) and (FPostedID = ID) then
  begin
    FPostedID := -1;
    InternalRefreshRow;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMETABASE', 'DOAFTERTRANSACTIONEND', KEYDOAFTERTRANSACTIONEND)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMETABASE', 'DOAFTERTRANSACTIONEND', KEYDOAFTERTRANSACTIONEND);
  {M}  end;
  {END MACRO}
end;

function TgdcMetaBase.GetCanCreate: Boolean;
begin
  Assert(IBLogin <> nil);
  Result := inherited GetCanCreate and IBLogin.IsIBUserAdmin;
end;

function TgdcMetaBase.GetCanDelete: Boolean;
begin
  Assert(IBLogin <> nil);
  Result := inherited GetCanDelete and IBLogin.IsIBUserAdmin;
end;

function TgdcMetaBase.GetCanEdit: Boolean;
begin
  Assert(IBLogin <> nil);
  Result := inherited GetCanEdit and IBLogin.IsIBUserAdmin;
end;

function TgdcMetaBase.GetDialogDefaultsFields: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCMETABASE', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMETABASE', KEYGETDIALOGDEFAULTSFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETDIALOGDEFAULTSFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMETABASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMETABASE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMETABASE' then
  {M}        begin
  {M}          Result := Inherited GETDIALOGDEFAULTSFIELDS;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := '';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMETABASE', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMETABASE', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS);
  {M}  end;
  {END MACRO}
end;

function TgdcMetaBase.GetIsUserDefined: Boolean;
begin
  Result := StrIPos(UserPrefix, ObjectName) = 1;
end;

function TgdcMetaBase.GetRelationName: String;
begin
  if Active and (FindField('relationname') <> nil) then
    Result := FieldByName('relationname').AsString
  else
    Result := '';
end;

class function TgdcMetaBase.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'OnlyAttribute;';
end;

class function TgdcMetaBase.IsAbstractClass: Boolean;
begin
  Result := Self.ClassNameIs('TgdcMetaBase');
end;

class function TgdcMetaBase.NeedModifyFromStream(
  const SubType: String): Boolean;
begin
  Result := True;
end;

procedure TgdcMetaBase.SaveToStreamDependencies(Stream: TStream;
  ObjectSet: TgdcObjectSet; ADependent_Name: String;
  PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True);
var
  ibsql: TIBSQL;
  ibsqlID: TIBSQL;
  AnObject: TgdcBase;
  C: TgdcFullClass;
  Cl: CgdcBase;
begin
  C := GetCurrRecordClass;
  if (Assigned(ObjectSet)) and (ObjectSet.Find(ID) > -1)
    or ((Self.ClassType <> C.gdClass) or (Self.SubType <> C.SubType))
  then
    Exit;

  ibsql := CreateReadIBSQL;
  ibsqlID := CreateReadIBSQL;
  try
    ibsql.SQL.Text := Format('SELECT * FROM rdb$dependencies WHERE  '+
      ' rdb$dependent_name = ''%s'' ',
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

            Cl := TgdcRelation;
          end else
          begin
            ibsqlID.SQL.Text := Format('SELECT id FROM at_relation_fields '+
              ' WHERE fieldname = ''%s'' AND relationname = ''%s''',
              [ibsql.FieldByName('rdb$field_name').AsString,
               ibsql.FieldByName('rdb$depended_on_name').AsString]);

            Cl := TgdcRelationField;
          end;
        end;
        5:
        begin
          ibsqlID.SQL.Text := Format('SELECT %s FROM %s WHERE %s = ''%s''',
          ['id', 'at_procedures', 'procedurename',
            ibsql.FieldByName('rdb$depended_on_name').AsString]);
          Cl := TgdcStoredProc;
        end;
        7:
        begin
          ibsqlID.SQL.Text := Format('SELECT %s FROM %s WHERE %s = ''%s''',
          ['id', 'at_exceptions', 'exceptionname',
            ibsql.FieldByName('rdb$depended_on_name').AsString]);
          Cl := TgdcException;
        end
        else
        begin
          ibsqlID.SQL.Text := '';
          Cl := nil;
        end;
      end;
      if ibsqlID.SQL.Text > '' then
      begin
        ibsqlID.ExecQuery;
        if ibsql.RecordCount > 0 then
        begin
          AnObject := Cl.CreateSubType(nil, '', 'ByID');
          try
            AnObject.ID := ibsqlID.Fields[0].AsInteger;
            AnObject.Open;
            if (AnObject.ID <> ID) and (AnObject.RecordCount > 0) then
              AnObject._SaveToStream(Stream, ObjectSet, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
          finally
            AnObject.Free;
          end;
        end;
      end;
      ibsql.Next;
    end;
  finally
    ibsql.Free;
    ibsqlID.Free;
  end;
end;

procedure TgdcMetaBase.ShowSQLProcess(S: TSQLProcessList);
var
  TransactionKey: String;
  ibsql: TIBSQL;
  DidActivate: Boolean;
  I: Integer;
begin
  Assert(Assigned(atDatabase));

  if NeedSingleUser then
    with TfrmIBUserList.Create(nil) do
    try
      if not CheckUsers then
        raise EgdcIBError.Create('� ���� ���������� ������ ������������! ' +
          ' ������� �������� ���������� ����������!');
    finally
      Free;
    end;

  DidActivate := False;
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Database := Database;
    ibsql.Transaction := Transaction;
    DidActivate := ActivateTransaction;

    try
      if atDatabase.InMultiConnection then
      begin
        TransactionKey := IntToStr(GetNextID);

        ibsql.Close;
        ibsql.SQL.Text :=
          'INSERT INTO at_transaction (trkey, numorder, script, successfull) ' +
          'VALUES (:trkey, :numorder, :script, :successfull)';

        ibsql.ParamCheck := True;
        ibsql.Prepare;

        //  ������������ ���������� ���� ��������, ������� ������ ����
        //  �������� ����� ���������������
        for i := 0 to S.Count - 1 do
        begin
          if Trim(S[I]) > '' then
          begin
            AddText('���������� SQL-�������...', clGreen);
            AddText({TranslateText(}S[I]{)} + #13#10, clBlack);

            ibsql.ParamByName('trkey').AsString := TransactionKey;
            ibsql.ParamByName('numorder').AsInteger := i + 1;
            ibsql.ParamByName('script').AsString := S[I];
            ibsql.ParamByName('successfull').AsString := IntToStr(S.Successful[I]);
            ibsql.ParamCheck := True;
            ibsql.ExecQuery;
            ibsql.Close;

            //AddText('SQL-������ ��������!', clGreen);
          end;
        end;

      end else

      for i := 0 to S.Count - 1 do
      begin
        if Trim(S[I]) > '' then
        begin
          AddText('������ SQL-�������...', clBlue);
          AddText({TranslateText(}S[I]{)}, clBlack);

          ibsql.Close;
          ibsql.ParamCheck := False;
          ibsql.SQL.Text := S[I];
          ibsql.ExecQuery;

          //AddText('SQL-������ ��������!', clBlue);
        end;
      end;

    except
      on E: Exception do
      begin
        if DidActivate and Transaction.InTransaction then
          Transaction.Rollback;
        AddMistake(E.Message, clRed);
        raise;
      end;
    end;

    if atDatabase.InMultiConnection then
      AddText( '������ ������� �������� ���������� ' +
        '������! ��� �� ��������� ���������� ��������������� � ' +
        '���� ������!' + #13#10, clGreen);
  finally
   if DidActivate then
      Transaction.Commit;
    ibsql.Free;
  end;
end;

{ TgdcException }

function TgdcException.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCEXCEPTION', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEXCEPTION', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEXCEPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEXCEPTION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEXCEPTION' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
//����������� ������ ���� �� ��������������
  if FieldByName(GetKeyField(SubType)).AsInteger < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT %s FROM %s WHERE UPPER(exceptionname) = ''%s''',
      [GetKeyField(SubType), GetListTable(SubType),
       AnsiUpperCase(FieldByName('exceptionname').AsString)]);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEXCEPTION', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEXCEPTION', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

constructor TgdcException.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpModify, cpDelete];
end;

function TgdcException.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCEXCEPTION', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEXCEPTION', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEXCEPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEXCEPTION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEXCEPTION' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dlgException.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEXCEPTION', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEXCEPTION', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcException.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCEXCEPTION', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEXCEPTION', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEXCEPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEXCEPTION',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEXCEPTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('exceptionname').AsString)) = 0 then
    raise EgdcIBError.Create('�� �� ������ ������� ����������������� ����������');

  Drop;
  inherited;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEXCEPTION', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEXCEPTION', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcException.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCEXCEPTION', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEXCEPTION', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEXCEPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEXCEPTION',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEXCEPTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('exceptionname').AsString)) = 1 then
    MetaDataCreate;
  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEXCEPTION', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEXCEPTION', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcException.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCEXCEPTION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEXCEPTION', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEXCEPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEXCEPTION',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEXCEPTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
    MetaDataAlter;
    inherited;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEXCEPTION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEXCEPTION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcException.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  S: String;
  I: Integer;

begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCEXCEPTION', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEXCEPTION', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEXCEPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEXCEPTION',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEXCEPTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if not (sMultiple in BaseState) then
  begin
    if FieldByName('lmessage').AsString = '' then
      FieldByName('lmessage').AsString := Trim(FieldByName('exceptionmessage').AsString);
  end;

  if (Trim(FieldByName('exceptionname').AsString) = '') then
  begin
    FieldByName('exceptionname').FocusControl;
    raise Exception.Create('������� ������������!');
  end;
 //  ��� ���� ������ ��������� ������
 //  ���������� �������
  S := Trim(AnsiUpperCase(FieldByName('exceptionname').AsString));
   for I := 1 to Length(S) do
     if not (S[I] in ['A'..'Z', '_', '0'..'9', '$']) then
     begin
       FieldByName('exceptionname').FocusControl;
       raise Exception.Create('�������� ������ ���� �� ���������� �����!');
     end;
 //  ��� ���� ������ ��������� ������
 //  ���������� �������
  S := Trim(AnsiUpperCase(FieldByName('exceptionmessage').AsString));
   for I := 1 to Length(S) do
     if (S[I] in ['�'..'�']) then
     begin
       FieldByName('exceptionmessage').FocusControl;
       raise Exception.Create('��������� ������ ���� �� ���������� �����!');
     end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEXCEPTION', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEXCEPTION', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcException.Drop;
var
  FSQL: TSQLProcessList;
begin
  FSQL := TSQLProcessList.Create;
  try
    FSQL.Add(Format('DROP EXCEPTION %s', [FieldByName('exceptionname').AsString]));
    ShowSQLProcess(FSQL);
  finally
    FSQL.Free;
  end;
end;

function TgdcException.GetCanDelete: Boolean;
begin
  Result := inherited GetCanDelete and Active and
    (AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('exceptionname').AsString)) = 1);
end;

class function TgdcException.GetDisplayName(const ASubType: TgdcSubType): String;
begin
  Result := '����������';
end;

function TgdcException.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCEXCEPTION', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEXCEPTION', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEXCEPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEXCEPTION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEXCEPTION' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' FROM at_exceptions z LEFT JOIN rdb$exceptions e ' +
    ' ON e.rdb$exception_name = z.exceptionname '
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEXCEPTION', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEXCEPTION', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcException.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'id';
end;

class function TgdcException.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'exceptionname';
end;

class function TgdcException.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'at_exceptions';
end;

function TgdcException.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCEXCEPTION', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEXCEPTION', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEXCEPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEXCEPTION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEXCEPTION' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := 'SELECT z.*, e.rdb$exception_number as exceptionnumber,' +
    ' e.rdb$message as exceptionmessage, '+
    ' e.rdb$description as description, e.rdb$system_flag as system_flag ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEXCEPTION', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEXCEPTION', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcException.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmException';
end;

procedure TgdcException.MetaDataAlter;
var
  FSQL: TSQLProcessList;
begin
  FSQL := TSQLProcessList.Create;
  try
    FSQL.Add(Format('ALTER EXCEPTION %s ''%s''',
      [ FieldByName('exceptionname').AsString,
        FieldByName('exceptionmessage').AsString]));

    ShowSQLProcess(FSQL);
  finally
    FSQL.Free;
  end;
end;

procedure TgdcException.MetaDataCreate;
var
  FSQL: TSQLProcessList;
begin
  FSQL := TSQLProcessList.Create;
  try
    FSQL.Add(Format('CREATE EXCEPTION %s ''%s''',
      [FieldByName('exceptionname').AsString,
       FieldByName('exceptionmessage').AsString]));

    ShowSQLProcess(FSQL);
  finally
    FSQL.Free;
    NeedSingleUser := False;
  end;

end;

{ TgdcIndex }

constructor TgdcIndex.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpModify, cpDelete];
  FIndexList := TStringList.Create;
  FIndexList.Sorted := True;
end;

function TgdcIndex.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCINDEX', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINDEX', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINDEX') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINDEX',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINDEX' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dlgIndices.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINDEX', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINDEX', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;


procedure TgdcIndex.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINDEX', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINDEX', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINDEX') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINDEX',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINDEX' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('indexname').AsString)) = 0 then
    raise EgdcIBError.Create('�� �� ������ ������� ����������������� ������!');
  Drop;
  inherited;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINDEX', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINDEX', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcIndex.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINDEX', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINDEX', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINDEX') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINDEX',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINDEX' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('indexname').AsString)) = 1 then
    MetaDataCreate;
  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINDEX', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINDEX', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcIndex.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINDEX', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINDEX', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINDEX') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINDEX',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINDEX' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  MetaDataAlter;
  inherited;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINDEX', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINDEX', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcIndex.Drop;
var
  FSQL: TSQLProcessList;
begin
  Assert(atDatabase <> nil);
  FSQL := TSQLProcessList.Create;
  try
    FSQL.Add(Format('DROP INDEX %s',
      [FieldByName('indexname').AsString]));
    atDatabase.NotifyMultiConnectionTransaction;
    ShowSQLProcess(FSQL);
  finally
    FSQL.Free;
  end;
end;

class function TgdcIndex.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'id';
end;

class function TgdcIndex.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'indexname';
end;

class function TgdcIndex.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'at_indices';
end;

procedure TgdcIndex.MetaDataAlter;
var
  FSQL: TSQLProcessList;
  subtext: String;
begin
  if FieldByName('changedata').AsInteger = 1 then
  begin
    try
      Drop;
    except
    end;
    MetaDataCreate;
  end;

  if FieldByName('changeactive').AsInteger = 1 then
  begin
    FSQL := TSQLProcessList.Create;
    try
      if FieldByName('index_inactive').AsInteger > 0 then
        subtext := 'INACTIVE'
      else
        subtext := 'ACTIVE';

      FSQL.Add(Format('ALTER INDEX %s %s',
        [FieldByName('indexname').AsString, subtext]));

      ShowSQLProcess(FSQL);
    finally
      FSQL.Free;
    end;
  end;
end;

procedure TgdcIndex.MetaDataCreate;
var
  FSQL: TSQLProcessList;
  subtext: String;
  sorder: String;
begin
  FSQL := TSQLProcessList.Create;
  try
    if FieldByName('unique_flag').AsInteger > 0 then
      subtext := 'UNIQUE'
    else
      subtext := '';

    if FieldByName('rdb$index_type').AsInteger > 0 then
      sorder := 'DESCENDING'
    else
      sorder := '';

    FSQL.Add(Format('CREATE %s %s INDEX %s ON %s (%s)',
      [subtext, sorder, FieldByName('indexname').AsString,
      FieldByName('relationname').AsString, FieldByName('fieldslist').AsString]));

    ShowSQLProcess(FSQL);
  finally
    FSQL.Free;
    NeedSingleUser := False;
  end;
end;

class function TgdcIndex.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByRelation;';
end;

procedure TgdcIndex.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('OnlyAttribute') then
    S.Add('z.indexname LIKE ''USR$%''');
  if HasSubSet('ByRelation') then
    S.Add('z.relationkey = :relationkey');
end;

function TgdcIndex.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCINDEX', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINDEX', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINDEX') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINDEX',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINDEX' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' FROM at_indices z LEFT JOIN rdb$indices ri ON ri.rdb$index_name = z.indexname ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINDEX', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINDEX', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcIndex.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCINDEX', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINDEX', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINDEX') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINDEX',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINDEX' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' SELECT z.*, ri.rdb$index_name, ri.rdb$relation_name, ' +
    ' ri.rdb$index_id, ri.rdb$unique_flag, ri.rdb$description, ri.rdb$segment_count, ' +
    ' ri.rdb$index_inactive, ri.rdb$index_type, ri.rdb$foreign_key, ' +
    ' ri.rdb$system_flag, 0 as changeactive, 0 as changedata ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINDEX', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINDEX', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcIndex._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINDEX', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINDEX', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINDEX') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINDEX',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINDEX' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  FieldByName('rdb$index_type').AsInteger := 0;
  FieldByName('unique_flag').AsInteger := 0;
  FieldByName('index_inactive').AsInteger := 0;

  with FgdcDataLink do
   if Active and (DataSet is TgdcRelation) then
     FieldByName('relationname').AsString := DataSet.FieldByName('relationname').AsString;

  FieldByName('indexname').AsString := UserPrefix + '_X_' + FieldByName('relationname').AsString +
     GetUniqueID(Database, ReadTransaction);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINDEX', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINDEX', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcIndex.DoAfterOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINDEX', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINDEX', KEYDOAFTEROPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTEROPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINDEX') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINDEX',
  {M}          'DOAFTEROPEN', KEYDOAFTEROPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINDEX' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('changeactive').Required := False;
  FieldByName('changedata').Required := False;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINDEX', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINDEX', 'DOAFTEROPEN', KEYDOAFTEROPEN);
  {M}  end;
  {END MACRO}
end;

procedure TgdcIndex.SyncIndices(const ARelationName: String; const NeedRefresh: Boolean = True);
begin
  if (IsSync) or (not Active) then
  begin
    ExecSingleQuery(Format('EXECUTE PROCEDURE at_p_sync_indexes(''%s'')',
      [AnsiUpperCase(TRIM(ARelationName))]));
    if Active and NeedRefresh then
      CloseOpen;
    IsSync := False;
  end;
end;

procedure TgdcIndex.DoBeforeOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINDEX', 'DOBEFOREOPEN', KEYDOBEFOREOPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINDEX', KEYDOBEFOREOPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREOPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINDEX') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINDEX',
  {M}          'DOBEFOREOPEN', KEYDOBEFOREOPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINDEX' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  //����� �������� ������� ��������� � �������������
  //��� ������� ��-�� ����, ���
  //1) ������ �� �� ���������� ��� ��������� ��������
  //2) ������������� ����� ���� �������� ���������� ���������������
  IsSync := True;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINDEX', 'DOBEFOREOPEN', KEYDOBEFOREOPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINDEX', 'DOBEFOREOPEN', KEYDOBEFOREOPEN);
  {M}  end;
  {END MACRO}
end;

procedure TgdcIndex.DoBeforeEdit;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINDEX', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINDEX', KEYDOBEFOREEDIT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREEDIT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINDEX') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINDEX',
  {M}          'DOBEFOREEDIT', KEYDOBEFOREEDIT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINDEX' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FChangeActive := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINDEX', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINDEX', 'DOBEFOREEDIT', KEYDOBEFOREEDIT);
  {M}  end;
  {END MACRO}
end;

class function TgdcIndex.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmIndices';
end;

class function TgdcIndex.GetDisplayName(const ASubType: TgdcSubType): String;
begin
  Result := '������';
end;

procedure TgdcIndex._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet;
  PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True);
var
  ibsql: TIBSQL;
begin
  //� ����� ��������� ������ �������-��������
  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('indexname').AsString)) = 1 then
  begin
    ibsql := CreateReadIBSQL;
    try
      //���� �������� ������� ��������� � ��������� �����������, �� �� ��������� ���
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints ' +
        ' WHERE rdb$constraint_name = rdb$index_name ' +
        ' AND rdb$constraint_name = :indexname';
      ibsql.ParamByName('indexname').AsString := FieldByName('indexname').AsString;
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        SaveToStreamDependencies(Stream, ObjectSet,
          FieldByName('indexname').AsString, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
        inherited;
      end;
    finally
      ibsql.Free;
    end;
  end;
end;

procedure TgdcIndex.SyncAllIndices(const NeedRefresh: Boolean = True);
begin
  ExecSingleQuery('EXECUTE PROCEDURE at_p_sync_indexes_all');
  if NeedRefresh and Active then
    CloseOpen;
end;

function TgdcIndex.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCINDEX', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINDEX', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINDEX') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINDEX',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINDEX' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
//����������� ������ ���� �� ��������������
  if FieldByName(GetKeyField(SubType)).AsInteger < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT %s FROM %s WHERE UPPER(indexname)=''%s'' ',
      [GetKeyField(SubType), GetListTable(SubType), AnsiUpperCase(FieldByName('indexname').AsString)]);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINDEX', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINDEX', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcIndex.SaveToStreamDependencies(Stream: TStream;
  ObjectSet: TgdcObjectSet; ADependent_Name: String;
  PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True);
var
  ibsql: TIBSQL;
  ibsqlID: TIBSQL;
  AnObject: TgdcBase;
  C: TgdcFullClass;

begin
//�.�. ������� � ��� ����� ������ ����������� ������, ��� ���� �������
//��������� �������� � ��������� ��� ����
  C := GetCurrRecordClass;
  if (Assigned(ObjectSet)) and (ObjectSet.Find(ID) > -1)
    or ((Self.ClassType <> C.gdClass) or (Self.SubType <> C.SubType))
  then
    Exit;

  ibsql := CreateReadIBSQL;
  ibsqlID := CreateReadIBSQL;
  try
    ibsql.SQL.Text := 'SELECT * FROM rdb$index_segments WHERE rdb$index_name = :indexname';
    ibsql.ParamByName('indexname').AsString := FieldByName('indexname').AsString;
    ibsql.ExecQuery;
    while not ibsql.Eof do
    begin
      ibsqlID.Close;
      ibsqlID.SQL.Text := 'SELECT * FROM at_relation_fields WHERE fieldname = :fieldname ' +
        ' AND relationkey = :relationkey ';
      ibsqlID.ParamByName('relationkey').AsString := FieldByName('relationkey').AsString;
      ibsqlID.ParamByName('fieldname').AsString := AnsiUpperCase(ibsql.FieldByName('rdb$field_name').AsString);
      ibsqlID.ExecQuery;
      if ibsqlID.RecordCount > 0 then
      begin
        AnObject := TgdcRelationField.CreateSubType(nil, '', 'ByID');
        try
          AnObject.ID := ibsqlID.Fields[0].AsInteger;
          AnObject.Open;
          if AnObject.RecordCount > 0 then
            AnObject._SaveToStream(Stream, ObjectSet, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
        finally
          AnObject.Free;
        end;
      end;
      ibsql.Next;
    end;
  finally
    ibsql.Free;
    ibsqlID.Free;
  end;
end;

function TgdcIndex.GetCanDelete: Boolean;
begin
  Result := inherited GetCanDelete and Active and
    (AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('indexname').AsString)) = 1);
end;

destructor TgdcIndex.Destroy;
begin
  FIndexList.Free;
  inherited;
end;

procedure TgdcIndex.DoBeforeInsert;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  BM: TBookmarkStr;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINDEX', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINDEX', KEYDOBEFOREINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINDEX') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINDEX',
  {M}          'DOBEFOREINSERT', KEYDOBEFOREINSERT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINDEX' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  if CachedUpdates then
  begin
    FIndexList.Clear;
    DisableControls;
    BM := BookMark;

    First;
    while not EOF do
    begin
      FIndexList.Add(AnsiUpperCase(FieldByName('indexname').AsString));
      Next;
    end;

    BookMark := BM;
    EnableControls;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINDEX', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINDEX', 'DOBEFOREINSERT', KEYDOBEFOREINSERT);
  {M}  end;
  {END MACRO}
end;

function TgdcIndex.CheckIndexName: Boolean;
var
  ibsql: TIBSQL;
begin
  Result := True;

  ibsql := CreateReadIBSQL;
  try
    ibsql.SQL.Text := 'SELECT * FROM rdb$indices WHERE rdb$index_name = :indexname';
    ibsql.ParamByName('indexname').AsString := FieldByName('indexname').AsString;
    ibsql.ExecQuery;

    if ibsql.RecordCount > 0 then
    begin
      Result := False;
    end else

    if CachedUpdates then
    begin
      if FIndexList.IndexOf(AnsiUpperCase(FieldByName('indexname').AsString)) > -1
      then
        Result := False;
    end;

  finally
    ibsql.Free;
  end;
end;

procedure TgdcIndex.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  S: String;
  I: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINDEX', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINDEX', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINDEX') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINDEX',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINDEX' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  if (Trim(FieldByName('indexname').AsString) = '') then
  begin
    FieldByName('indexname').FocusControl;
    raise Exception.Create('������� ������������!');
  end;
    
 //  ��� ������� ������ ��������� ������
 //  ���������� �������
  S := Trim(AnsiUpperCase(FieldByName('indexname').AsString));
   for I := 1 to Length(S) do
     if not (S[I] in ['A'..'Z', '_', '0'..'9', '$']) then
     begin
       FieldByName('indexname').FocusControl;
       raise Exception.Create('�������� ������ ���� �� ���������� �����!');
     end;

  if (Trim(FieldByName('fieldslist').AsString) = '') then
  begin
    FieldByName('fieldslist').FocusControl;
    raise Exception.Create('������� ������ �����, �� ������� ��������� ������!');
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINDEX', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINDEX', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

{ TgdcTrigger }

constructor TgdcTrigger.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpModify, cpDelete];
end;

function TgdcTrigger.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCTRIGGER', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTRIGGER', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTRIGGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTRIGGER',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTRIGGER' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dlgTrigger.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTRIGGER', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTRIGGER', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcTrigger.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCTRIGGER', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTRIGGER', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTRIGGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTRIGGER',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTRIGGER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('triggername').AsString)) = 0 then
    raise EgdcIBError.Create('�� �� ������ ������� ����������������� �������!');

  Drop;
  inherited;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTRIGGER', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTRIGGER', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcTrigger.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCTRIGGER', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTRIGGER', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTRIGGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTRIGGER',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTRIGGER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('triggername').AsString)) = 1 then
    MetaDataCreate;
  inherited;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTRIGGER', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTRIGGER', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcTrigger.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCTRIGGER', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTRIGGER', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTRIGGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTRIGGER',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTRIGGER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  MetaDataAlter;
  inherited;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTRIGGER', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTRIGGER', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcTrigger.DoBeforeOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCTRIGGER', 'DOBEFOREOPEN', KEYDOBEFOREOPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTRIGGER', KEYDOBEFOREOPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREOPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTRIGGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTRIGGER',
  {M}          'DOBEFOREOPEN', KEYDOBEFOREOPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTRIGGER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  //����� �������� �������� ��������� � �������������
  IsSync := True;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTRIGGER', 'DOBEFOREOPEN', KEYDOBEFOREOPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTRIGGER', 'DOBEFOREOPEN', KEYDOBEFOREOPEN);
  {M}  end;
  {END MACRO}
end;

procedure TgdcTrigger.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  S: String;
  I: Integer;
  
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCTRIGGER', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTRIGGER', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTRIGGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTRIGGER',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTRIGGER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if (Trim(FieldByName('triggername').AsString) = '') then
  begin
    FieldByName('triggername').FocusControl;
    raise Exception.Create('������� ������������!');
  end;

 //  ��� ������� ������ ��������� ������
 //  ���������� �������
  S := Trim(AnsiUpperCase(FieldByName('triggername').AsString));
   for I := 1 to Length(S) do
     if not (S[I] in ['A'..'Z', '_', '0'..'9', '$']) then
     begin
       FieldByName('triggername').FocusControl;
       raise Exception.Create('�������� ������ ���� �� ���������� �����!');
     end;

  if not (sMultiple in BaseState) then
  begin
    if FieldByName('relationname').AsString = '' then
      FieldByName('relationname').AsString :=
        AnsiUpperCase(Trim(atDataBase.Relations.ByID(FieldByName('relationkey').AsInteger).RelationName));

    if FieldByName('rdb$trigger_name').AsString = '' then
      FieldByName('rdb$trigger_name').AsString := Trim(FieldByName('triggername').AsString);
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTRIGGER', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTRIGGER', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcTrigger._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCTRIGGER', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTRIGGER', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTRIGGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTRIGGER',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTRIGGER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('trigger_inactive').AsInteger := 0;
  FieldByName('rdb$trigger_source').AsString := 'AS' + #13#10 + 'BEGIN' + #13#10 +
    '/*���� ��������*/' + #13#10 + 'END';

  with FgdcDataLink do
    if Active and (DataSet is TgdcRelation) then
      FieldByName('relationname').AsString := DataSet.FieldByName('relationname').AsString;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTRIGGER', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTRIGGER', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcTrigger.Drop;
var
  FSQL: TSQLProcessList;
begin
  FSQL := TSQLProcessList.Create;
  try
    FSQL.Add(Format('DROP TRIGGER %s',
      [FieldByName('triggername').AsString]));

    ShowSQLProcess(FSQL);
  finally
    FSQL.Free;
  end;

end;

function TgdcTrigger.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCTRIGGER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTRIGGER', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTRIGGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTRIGGER',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTRIGGER' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' FROM at_triggers z LEFT JOIN rdb$triggers t ON z.triggername = t.rdb$trigger_name '
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTRIGGER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTRIGGER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcTrigger.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'id';
end;

class function TgdcTrigger.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'triggername';
end;

class function TgdcTrigger.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'at_triggers';
end;

function TgdcTrigger.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCTRIGGER', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTRIGGER', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTRIGGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTRIGGER',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTRIGGER' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'SELECT z.*, t.rdb$trigger_name, t.rdb$trigger_sequence, t.rdb$trigger_type, ' +
    ' t.rdb$trigger_source, t.rdb$trigger_blr, t.rdb$description, t.rdb$system_flag, ' +
    ' t.rdb$flags ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTRIGGER', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTRIGGER', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcTrigger.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByRelation;';
end;

procedure TgdcTrigger.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('OnlyAttribute') then
    S.Add('z.triggername LIKE ''USR$%''');
  if HasSubSet('ByRelation') then
    S.Add(' z.relationkey = :relationkey ');
end;

procedure TgdcTrigger.MetaDataAlter;
var
  FSQL: TSQLProcessList;
  subtext: String;
  activetext: string;
begin
  FSQL := TSQLProcessList.Create;
  try
      if Trim(FieldByName('triggername').AsString) <>
      Trim(FieldByName('rdb$trigger_name').AsString) then
    begin
    //���� ���� �������� ��� ��������, �� ...
      Drop;
      MetaDataCreate;
    end
    else begin
      if FieldByName('trigger_inactive').AsInteger > 0 then
        activetext := 'INACTIVE'
      else
        activetext := 'ACTIVE';

      case FieldByName('rdb$trigger_type').AsInteger of
        1: subtext := 'BEFORE INSERT';
        2: subtext := 'AFTER INSERT';
        3: subtext := 'BEFORE UPDATE';
        4: subtext := 'AFTER UPDATE';
        5: subtext := 'BEFORE DELETE';
        6: subtext := 'AFTER DELETE';
        17: subtext := 'BEFORE INSERT OR UPDATE';
        18: subtext := 'AFTER INSERT OR UPDATE';
        25: subtext := 'BEFORE INSERT OR DELETE';
        26: subtext := 'AFTER INSERT OR DELETE';
        27: subtext := 'BEFORE UPDATE OR DELETE';
        28: subtext := 'AFTER UPDATE OR DELETE';
        113: subtext := 'BEFORE INSERT OR UPDATE OR DELETE';
        114: subtext := 'AFTER INSERT OR UPDATE OR DELETE';
      end;

      FSQL.Add(Format('ALTER TRIGGER %s %s %s POSITION %s ' +
        ' %s ', [FieldByName('triggername').AsString, activetext,
         subtext, FieldByName('rdb$trigger_sequence').AsString,
         FieldByName('rdb$trigger_source').AsString]));
      ShowSQLProcess(FSQL);
    end;
  finally
    FSQL.Free;
  end;
end;

procedure TgdcTrigger.MetaDataCreate;
var
  FSQL: TSQLProcessList;
  subtext: String;
begin
  case FieldByName('rdb$trigger_type').AsInteger of
    1: subtext := 'BEFORE INSERT';
    2: subtext := 'AFTER INSERT';
    3: subtext := 'BEFORE UPDATE';
    4: subtext := 'AFTER UPDATE';
    5: subtext := 'BEFORE DELETE';
    6: subtext := 'AFTER DELETE';
    17: subtext := 'BEFORE INSERT OR UPDATE';
    18: subtext := 'AFTER INSERT OR UPDATE';
    25: subtext := 'BEFORE INSERT OR DELETE';
    26: subtext := 'AFTER INSERT OR DELETE';
    27: subtext := 'BEFORE UPDATE OR DELETE';
    28: subtext := 'AFTER UPDATE OR DELETE';
    113: subtext := 'BEFORE INSERT OR UPDATE OR DELETE';
    114: subtext := 'AFTER INSERT OR UPDATE OR DELETE';
  else
    subtext := '';
  end;

  if subtext > '' then
  begin
    FSQL := TSQLProcessList.Create;
    try
      FSQL.Add(Format('CREATE TRIGGER %s FOR %s '#13#10 + '%s'#13#10 + 'POSITION %s ' +
        ' %s ',[FieldByName('triggername').AsString, FieldByName('relationname').AsString,
         subtext, FieldByName('rdb$trigger_sequence').AsString,
         FieldByName('rdb$trigger_source').AsString]));
      ShowSQLProcess(FSQL);
    finally
      FSQL.Free;
      NeedSingleUser := False;
    end;
  end else
    AddMistake('��� �������� ' + FieldByName('triggername').AsString +
      ' ������� ������� �������� ���� rdb$trigger_type.', clRed);
end;

procedure TgdcTrigger.SyncTriggers(const ARelationName: String; const NeedRefresh: Boolean = True);
begin
  if (IsSync) or (not Active) then
  begin
    ExecSingleQuery(Format('EXECUTE PROCEDURE at_p_sync_triggers(''%s'')',
      [AnsiUpperCase(TRIM(ARelationName))]));
    if Active and NeedRefresh then
      CloseOpen;
    IsSync := False;
  end;
end;

function TgdcTrigger.CalcPosition(RelationName: String; TriggerType: Integer): Integer;
var
  ibsql: TIBSQL;
  DidActivate: Boolean;
begin
  Result := 0;

  DidActivate := False;
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Database := Database;
    ibsql.Transaction := Transaction;

    DidActivate := ActivateTransaction;

    ibsql.SQL.Text := Format('SELECT MAX(rdb$trigger_sequence) as maxpos FROM rdb$triggers ' +
      ' WHERE rdb$relation_name = ''%s'' AND rdb$trigger_type = %d ', [RelationName, TriggerType]);
    ibsql.ExecQuery;

    if not ibsql.FieldByName('maxpos').IsNull then
      Result := ibsql.FieldByName('maxpos').AsInteger + 1;

  finally
    if DidActivate then
      Transaction.Commit;

    ibsql.Free;
  end;
end;

procedure TgdcTrigger.DoBeforeEdit;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCTRIGGER', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTRIGGER', KEYDOBEFOREEDIT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREEDIT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTRIGGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTRIGGER',
  {M}          'DOBEFOREEDIT', KEYDOBEFOREEDIT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTRIGGER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FChangeName := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTRIGGER', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTRIGGER', 'DOBEFOREEDIT', KEYDOBEFOREEDIT);
  {M}  end;
  {END MACRO}
end;

class function TgdcTrigger.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmTrigger';
end;

procedure TgdcTrigger.SyncAllTriggers(const NeedRefresh: Boolean = True);
begin
  ExecSingleQuery('EXECUTE PROCEDURE at_p_sync_triggers_all');
  if NeedRefresh and Active then
    CloseOpen;
end;

procedure TgdcTrigger._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet;
  PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True);
var
  I: Integer;
begin
  //�� �� ����� ��������� ������� USR$_BU_INV_CARD � �����,
  //�.�. �� ������������ ������������� ��� ��������� ��������� ������� inv_card
  if (AnsiCompareText('USR$_BU_INV_CARD', Trim(FieldByName('triggername').AsString)) = 0) then
    Exit;
  for I := 1 to MaxInvCardTrigger do
    if (AnsiCompareText(Format('USR$%d_BU_INV_CARD', [I]), Trim(FieldByName('triggername').AsString)) = 0) then
      Exit;
  //� ����� ��������� ������ ��������-��������
  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('triggername').AsString)) = 1 then
  begin
    SaveToStreamDependencies(Stream, ObjectSet,
      FieldByName('triggername').AsString, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
    inherited;
  end;
end;

function TgdcTrigger.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCTRIGGER', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTRIGGER', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTRIGGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTRIGGER',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTRIGGER' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
//����������� ������ ���� �� ��������������
  if FieldByName(GetKeyField(SubType)).AsInteger < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT %s FROM %s WHERE UPPER(triggername)=''%s'' ',
      [GetKeyField(SubType), GetListTable(SubType), AnsiUpperCase(FieldByName('triggername').AsString)]);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTRIGGER', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTRIGGER', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcTrigger.GetDisplayName(const ASubType: TgdcSubType): String;
begin
  Result := '�������';
end;

function TgdcTrigger.GetCanDelete: Boolean;
begin
  Result := inherited GetCanDelete and Active and
    (AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('triggername').AsString)) = 1);
end;

{ TgdcTableToTable }

procedure TgdcTableToTable.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCTABLETOTABLE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTABLETOTABLE', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTABLETOTABLE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTABLETOTABLE',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTABLETOTABLE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  //�������������� ���������� � ����� ������
  if FIDDomain = '' then Exit;
  Assert(atDatabase <> nil);
  CustomExecQuery(Format('INSERT INTO at_fields (' +
    ' fieldname, ' +
    ' lname, ' +
    ' description, ' +
    ' reftable, ' +
    ' reflistfield, ' +
    ' reftablekey, ' +
    ' reflistfieldkey) ' +
    ' VALUES ('+
    ' ''%0:s'', ''%0:s'', ''������ �� ������� %1:s'',' +
    ' ''%1:s'', ''%2:s'', %3:d, %4:d )',
    [FIDDomain, GetReferenceName,
     atDatabase.Relations.ByRelationName(GetReferenceName).ListField.FieldName,
     atDatabase.Relations.ByRelationName(GetReferenceName).ID,
     atDatabase.Relations.ByRelationName(GetReferenceName).ListField.ID
    ]), Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTABLETOTABLE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTABLETOTABLE', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

function TgdcTableToTable.CreateNewDomain: String;
begin
//����� �� primary key �������
  if FIDDomain = '' then
    FIDDomain := FieldByName('relationname').AsString + 'PK_' + GetUniqueID(Database, ReadTransaction);

  if AnsiPos(UserPrefix, AnsiUpperCase(FIDDomain)) <> 1 then
    FIDDomain := UserPrefix + FIDDomain;
  Result := Format('CREATE DOMAIN %s AS INTEGER NOT NULL',
    [FIDDomain]);

end;

procedure TgdcTableToTable.CreateRelationSQL(Scripts: TSQLProcessList);
begin
  Scripts.Add(CreateNewDomain);
  Scripts.Add(CreateSimpleTable);
  Scripts.Add(CreateForeignKey);
  if (not (sLoadFromStream in BaseState)) then
  begin
    Scripts.Add(CreateInsertTrigger);
  end;
  Scripts.Add(CreateGrantSQL);
end;

function TgdcTableToTable.CreateSimpleTable: String;
begin
  Result := Format
  (
    'CREATE TABLE %0:s (id %1:s, PRIMARY KEY (id))',
    [FieldByName('relationname').AsString, FIDDomain]
  );
end;

class function TgdcTableToTable.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  Result := '������� �� �������';
end;

function TgdcTableToTable.CreateForeignKey: String;
var
  NextConstraintName: String;
  TableNameWithoutPrefix: String;
begin
  NeedSingleUser := True;
  if Pos(UserPrefix, AnsiUpperCase(FieldByName('relationname').AsString)) = 1 then
    TableNameWithoutPrefix := System.copy(FieldByName('relationname').AsString, Length(UserPrefix) + 1,
      Length(FieldByName('relationname').AsString))
  else
    TableNameWithoutPrefix := FieldByName('relationname').AsString;
  NextConstraintName := gdcBaseManager.AdjustMetaName(Format(UserPrefix + 'fk%s%s',
    [TableNameWithoutPrefix, GetUniqueID(Database, ReadTransaction)]));


 Result := Format
  (
    ' ALTER TABLE %s ADD CONSTRAINT %s FOREIGN KEY (id) REFERENCES %s (%s) ON UPDATE CASCADE ON DELETE CASCADE',
    [
      FieldByName('relationname').AsString,
      NextConstraintName,
      GetReferenceName,
      GetKeyFieldName(GetReferenceName)
    ]
  );
end;

procedure TgdcTableToTable._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCTABLETOTABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTABLETOTABLE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTABLETOTABLE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTABLETOTABLE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTABLETOTABLE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FIDDomain := '';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTABLETOTABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTABLETOTABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcTableToTable.DropTable;
var
  ibsql: TIBSQL;
  FSQL: TSQLProcessList;
  KeyField: TatRelationField;
  KeyDomain: TatField;
begin
  Assert(atDatabase <> nil);

  ibsql := CreateReadIBSQL;
  FSQL := TSQLProcessList.Create;
  try
    KeyField := atDatabase.FindRelationField(FieldByName('relationname').AsString,
      GetKeyField(SubType));

    if KeyField = nil then
      raise EgdcIBError.Create('��� �������� ������� ��������� ������. ��������� ���������������');

    KeyDomain := KeyField.Field;
    if (KeyDomain = nil) or (KeyDomain.RefTable = nil) then
       raise EgdcIBError.Create('��� �������� ������� ��������� ������. ��������� ���������������');

    ibsql.SQL.Text := 'SELECT * FROM rdb$dependencies WHERE rdb$depended_on_name = :depname ' +
      ' AND (rdb$dependent_type = 1 OR rdb$dependent_type = 5) ';
    ibsql.ParamByName('depname').AsString := FieldByName('relationname').AsString;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
      raise EgdcIBError.Create('������ ������� ������� �.�. ��� ������������ � ���������� ��� ��������������');

    ibsql.Close;
    ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints WHERE rdb$relation_name = :relname ' +
      'AND rdb$constraint_type = ''FOREIGN KEY'' ';
    ibsql.ParamByName('relname').AsString := FieldByName('relationname').AsString;
    ibsql.ExecQuery;
    while not ibsql.EOF do
    begin
      FSQL.Add(Format('ALTER TABLE %s DROP CONSTRAINT %s ',
        [FieldByName('relationname').AsString, ibsql.FieldByName('rdb$constraint_name').AsString]),
        False);
      ibsql.Next;
    end;

    ibsql.Close;
    ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints WHERE rdb$relation_name = :relname ' +
      'AND rdb$constraint_type = ''PRIMARY KEY'' ';
    ibsql.ParamByName('relname').AsString := FieldByName('relationname').AsString;
    ibsql.ExecQuery;
    while not ibsql.EOF do
    begin
      FSQL.Add(Format('ALTER TABLE %s DROP CONSTRAINT %s ',
        [FieldByName('relationname').AsString, ibsql.FieldByName('RDB$CONSTRAINT_NAME').AsString]), False);
      ibsql.Next;
    end;

    ibsql.Close;

    DropCrossTable;
    FSQL.Add('DROP TABLE ' + FieldByName('relationname').AsString);

    FSQL.Add(Format('DROP DOMAIN %s', [KeyDomain.FieldName]));

    FSQL.Add(Format('DELETE FROM gd_command WHERE classname = ''TgdcAttrUserDefined'' AND ' +
      ' UPPER(SubType) = UPPER(''%s'')', [FieldByName('relationname').AsString]));

    atDatabase.NotifyMultiConnectionTransaction;
    ShowSQLProcess(FSQL);

  finally
    ibsql.Free;
    FSQL.Free;
  end;
end;

function TgdcTableToTable.GetReferenceName: String;
var
  q: TIBSQL;
begin
  q := CreateReadIBSQL;
  try
    q.Close;
    if FieldByName('referencekey').AsInteger > 0 then
    begin
      q.SQL.Text := 'SELECT relationname FROM at_relations WHERE id = :id';
      q.ParamByName('id').AsInteger := FieldByName('referencekey').AsInteger;
      q.ExecQuery;
    end;

    if q.RecordCount = 0 then
    begin
      FieldByName('referencekey').FocusControl;
      raise EgdcIBError.Create('�� �� ������� �������-������!');
    end else
      Result :=  q.FieldByName('relationname').AsString;
      
  finally
    q.Free;
  end;
end;

class function TgdcBaseTable.GetPrimaryFieldName: String;
begin
  Result := 'ID';
end;

procedure TgdcBaseTable._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet;
  PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True);
var
  FgdcIndex: TgdcIndex;
  C: TgdcFullClass;
begin
  //����� ����������� � ����� ����� ���������������� �������
  //�.�. ���������� �� �������� ����� �� ������ ��������� � �������
  //at_indices
  C := GetCurrRecordClass;
  if ((not Assigned(ObjectSet)) or (ObjectSet.Find(ID) = -1))
    and ((Self.ClassType = C.gdClass) and (Self.SubType = C.SubType)) then
  begin
    FgdcIndex := TgdcIndex.Create(nil);
    try
      FgdcIndex.Transaction := Transaction;
      FgdcIndex.SyncIndices(FieldByName('relationname').AsString);
    finally
      FgdcIndex.Free;
    end;
  end;
  inherited;

end;

function TgdcBaseTable.CreateEditorForeignKey: String;
begin
  NeedSingleUser := True;
  Result :=  Format('ALTER TABLE %s ADD CONSTRAINT %s ' +
    ' FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey) ' +
    ' ON UPDATE CASCADE',
    [FieldByName('relationname').AsString,
     GetForeignName(FieldByName('relationname').AsString, 'editorkey')]);
end;

function TgdcBaseTable.CreateInsertEditorTrigger: String;
begin
  Result := Format(
    ' CREATE TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
    ' BEFORE INSERT POSITION %3:s '#13#10 +
    ' AS '#13#10 +
    ' BEGIN '#13#10 +
    '   IF (NEW.editorkey IS NULL) THEN '#13#10 +
    '     NEW.editorkey = %2:s; '#13#10 +
    '   IF (NEW.editiondate IS NULL) THEN '#13#10 +
    '     NEW.editiondate = CURRENT_TIMESTAMP;'#13#10 +
    ' END ',
    [FieldByName('relationname').AsString,
     GetTriggerName(FieldByName('relationname').AsString, 'BI', 5),
     IntToStr(cstAdminKey), IntToStr(5)]);
end;

function TgdcBaseTable.CreateUpdateEditorTrigger: String;
begin
  Result := Format(
    ' CREATE TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
    ' BEFORE UPDATE POSITION %3:s '#13#10 +
    ' AS '#13#10 +
    ' BEGIN '#13#10 +
    '   IF (NEW.editorkey IS NULL) THEN '#13#10 +
    '     NEW.editorkey = %2:s; '#13#10 +
    '   IF (NEW.editiondate IS NULL) THEN '#13#10 +
    '     NEW.editiondate = CURRENT_TIMESTAMP;'#13#10 +
    ' END ',
    [FieldByName('relationname').AsString,
     GetTriggerName(FieldByName('relationname').AsString, 'BU', 5),
     IntToStr(cstAdminKey), IntToStr(5)]);
end;

procedure TgdcBaseTable.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBASETABLE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASETABLE', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASETABLE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASETABLE',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASETABLE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  if FNeedPredefinedFields then
  begin
    MakePredefinedRelationFields;
    FNeedPredefinedFields := False;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASETABLE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASETABLE', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBaseTable.DropCrossTable;
var
  ibsql: TIBSQL;
  gdcRelField: TgdcRelationField;
  DidActivate: Boolean;
begin
  ibsql := TIBSQL.Create(nil);
  gdcRelField := TgdcRelationField.CreateSubType(nil, '', 'ByID');
  try
    ibsql.Transaction := Transaction;
    gdcRelField.Transaction := Transaction;
    DidActivate := False;
    try
      DidActivate := ActivateTransaction;

//��������� ���� �� � ������� ����-������ �� ������� ���������
      ibsql.SQL.Text := 'SELECT id, crosstablekey, crosstable FROM at_relation_fields ' +
        ' WHERE relationkey = :relationkey AND crosstablekey IS NOT NULL ';
      ibsql.ParamByName('relationkey').AsInteger := ID;
      ibsql.ExecQuery;

      while not ibsql.Eof do
      begin
//������� ������ �� �������-���������
        gdcRelField.Close;
        gdcRelField.ID := ibsql.FieldByName('id').AsInteger;
        gdcRelField.Open;
        if gdcRelField.RecordCount > 0 then
          gdcRelField.Delete;

        ibsql.Next;
      end;

      if DidActivate and Transaction.InTransaction then
        Transaction.Commit;

    except
      if DidActivate and Transaction.InTransaction then
        Transaction.Rollback;
      raise;
    end;
  finally
    ibsql.Free;
    gdcRelField.Free;
  end;
end;

{ TgdcUnknownTable }

procedure TgdcUnknownTable.CreateRelationSQL(Scripts: TSQLProcessList);
begin
  if sLoadFromStream in BaseState then
  begin
    Scripts.Add(CreateUnknownTable);
    Scripts.Add(CreateGrantSQL);
  end;
end;

function TgdcUnknownTable.CreateUnknownTable: String;
begin
  Result := Format
  (
    'CREATE TABLE %0:s (%1:s dintkey)',
    [FieldByName('relationname').AsString,
     GetSimulateFieldName]
  );
end;

class function TgdcUnknownTable.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  Result := '�������'
end;

function GetSimulateFieldNameByRel(RelName: String): String;
begin
// ��� ���� ��� �������� �����-������� (������� �� ����� ���� ������� ��� �����,
//  � ��� ���������� �� ������ �� �� ����� ����� ��� ��������� �� ����, ������ ��������� ����� ����,
//  ������� � ����������� ���������
  if AnsiPos(UserPrefix, RelName) = 1 then
    Result := 'USR' + Copy(RelName, 5, Length(RelName) - 4)
  else
    Result := '';
  Result := gdcBaseManager.AdjustMetaName(Result);
end;


function TgdcUnknownTable.GetSimulateFieldName: String;
begin
  Result := GetSimulateFieldNameByRel(FieldByName('relationname').AsString);
end;

procedure TgdcUnknownTable.MakePredefinedRelationFields;
begin
//�� ����� ����������������� �����
end;

procedure TgdcUnknownTable._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet; PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean);
var
  gdcRField: TgdcRelationField;
  atRelation: TatRelation;
  I: Integer;
begin
  Assert(atDatabase <> nil, '�� ��������� ���� ���������!');
  inherited;
  {������� ��� �����-������. ���� ��� ���������������� ������� � � ��� ����
   �������� ���, �� �������� � ����� ����, �������� � �������� ���}
  if AnsiPos(UserPrefix, FieldByName('relationname').Asstring) = 1 then
  begin
    atRelation := atDatabase.Relations.ByRelationName(FieldByName('relationname').Asstring);

    if not Assigned(atRelation) then
      raise EgdcIBError.Create('������� ' + FieldByName('relationname').Asstring +
        ' �� �������! ���������� ���������������.');

    if Assigned(atRelation.PrimaryKey) then
    begin
      gdcRField := TgdcRelationField.CreateSubType(nil, '', 'ByID');
      try
        for I := 0 to atRelation.PrimaryKey.ConstraintFields.Count - 1 do
        begin
          gdcRField.Close;
          gdcRField.ID := atRelation.PrimaryKey.ConstraintFields[I].ID;
          gdcRField.Open;
          if gdcRField.RecordCount > 0 then
          begin
            gdcRField._SaveToStream(Stream, ObjectSet, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
          end;
        end;
      finally
        gdcRField.Free;
      end;
    end;
  end;
end;

{ TSQLProcessList }

procedure TSQLProcessList.Add(const Script: String; const Successful: Boolean = True);
begin
  FScriptList.Add(Script);
  if Successful then
    FSuccessfulList.Add('1')
  else
    FSuccessfulList.Add('0');
end;

procedure TSQLProcessList.Clear;
begin
  FScriptlist.Clear;
  FSuccessfulList.Clear;
end;

constructor TSQLProcessList.Create;
begin
  inherited;
  FScriptList := TStringList.Create;
  FSuccessfulList := TStringList.Create;
end;

procedure TSQLProcessList.Delete(Index: Integer);
begin
  FScriptlist.Delete(Index);
  FSuccessfulList.Delete(Index);
end;

destructor TSQLProcessList.Destroy;
begin
  FScriptlist.Free;
  FSuccessfulList.Free;
  inherited;
end;

function TSQLProcessList.GetCount: Integer;
begin
  Result := FScriptList.Count;
end;

function TSQLProcessList.GetScript(Index: Integer): String;
begin
  Result := FScriptList[Index];
end;

function TSQLProcessList.GetSuccessful(Index: Integer): Integer;
begin
  Result := StrToInt(FSuccessfulList[Index]);
end;

var
  TrCount: Integer;

{ TgdcPrimeTable }

procedure TgdcPrimeTable._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCPRIMETABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCPRIMETABLE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCPRIMETABLE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCPRIMETABLE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCPRIMETABLE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FTableType := ttPrimeTable;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCPRIMETABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCPRIMETABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcPrimeTable.CreatePrimeTable: String;
begin
  Result := Format
  (
    'CREATE TABLE %0:s (id dintkey, PRIMARY KEY (id))',
    [FieldByName('relationname').AsString]
  );

end;

procedure TgdcPrimeTable.CreateRelationSQL(Scripts: TSQLProcessList);
begin
  Scripts.Add(CreatePrimeTable);
  if (not (sLoadFromStream in BaseState)) then
  begin
    Scripts.Add(CreateInsertTrigger);
  end;
  Scripts.Add(CreateGrantSQL);
end;

class function TgdcPrimeTable.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  Result := '������� ������� � ���������������'
end;

{ TgdcGenerator }

constructor TgdcGenerator.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpModify, cpDelete];
end;

function TgdcGenerator.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCGENERATOR', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCGENERATOR', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCGENERATOR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCGENERATOR',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCGENERATOR' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
    Result := Tgdc_dlgGenerator.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCGENERATOR', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCGENERATOR', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcGenerator.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCGENERATOR', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCGENERATOR', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCGENERATOR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCGENERATOR',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCGENERATOR' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('generatorname').AsString)) = 0 then
    raise EgdcIBError.Create('�� �� ������ ������� ����������� ���������!');

  Drop;
  inherited;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCGENERATOR', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCGENERATOR', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcGenerator.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCGENERATOR', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCGENERATOR', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCGENERATOR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCGENERATOR',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCGENERATOR' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('generatorname').AsString)) = 1 then
    MetaDataCreate;
  inherited;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCGENERATOR', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCGENERATOR', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcGenerator.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCGENERATOR', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCGENERATOR', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCGENERATOR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCGENERATOR',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCGENERATOR' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  MetaDataAlter;
  inherited;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCGENERATOR', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCGENERATOR', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcGenerator.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  S: String;
  I: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCGENERATOR', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCGENERATOR', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCGENERATOR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCGENERATOR',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCGENERATOR' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if (Trim(FieldByName('generatorname').AsString) = '') then
  begin
    FieldByName('generatorname').FocusControl;
    raise Exception.Create('������� ������������ ����������!');
  end;

 //  ��� ���������� ������ ��������� ������
 //  ���������� �������
  S := Trim(AnsiUpperCase(FieldByName('generatorname').AsString));
   for I := 1 to Length(S) do
     if not (S[I] in ['A'..'Z', '_', '0'..'9', '$']) then
     begin
       FieldByName('generatorname').FocusControl;
       raise Exception.Create('�������� ���������� ������ ���� �� ���������� �����!');
     end;

  if not (sMultiple in BaseState) then
  begin
    if FieldByName('rdb$generator_name').AsString = '' then
      FieldByName('rdb$generator_name').AsString := Trim(FieldByName('generatorname').AsString);
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCGENERATOR', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCGENERATOR', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcGenerator.Drop;
var
  FSQL: TSQLProcessList;
begin
  FSQL := TSQLProcessList.Create;
  try
    FSQL.Add(Format('DROP GENERATOR %s',
      [FieldByName('generatorname').AsString]));

    ShowSQLProcess(FSQL);
  finally
    FSQL.Free;
  end;
end;

function TgdcGenerator.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCGENERATOR', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCGENERATOR', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCGENERATOR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCGENERATOR',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCGENERATOR' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' FROM at_generators z LEFT JOIN rdb$generators t ON z.generatorname = t.rdb$generator_name '
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCGENERATOR', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCGENERATOR', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcGenerator.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'id';
end;

class function TgdcGenerator.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'generatorname';
end;

class function TgdcGenerator.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'at_generators';
end;

function TgdcGenerator.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCGENERATOR', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCGENERATOR', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCGENERATOR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCGENERATOR',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCGENERATOR' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'SELECT z.*, t.* ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCGENERATOR', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCGENERATOR', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcGenerator.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('OnlyAttribute') then
    S.Add('COALESCE(T.RDB$SYSTEM_FLAG, 0) <> 1');
end;

procedure TgdcGenerator.MetaDataAlter;
var
  FSQL: TSQLProcessList;
begin
  FSQL := TSQLProcessList.Create;
  try
    if Trim(FieldByName('generatorname').AsString) <>
       Trim(FieldByName('rdb$generator_name').AsString) then
    begin
    //���� ���� �������� ��� ����������, �����������?
      Drop;
      MetaDataCreate;
    end;
  finally
    FSQL.Free;
  end;
end;

procedure TgdcGenerator.MetaDataCreate;
var
  FSQL: TSQLProcessList;
begin
  FSQL := TSQLProcessList.Create;
  try
    FSQL.Add(Format('CREATE GENERATOR %s ',[AnsiUpperCase(FieldByName('generatorname').AsString)]));
    ShowSQLProcess(FSQL);
  finally
    FSQL.Free;
    NeedSingleUser := False;
  end;
end;

procedure TgdcGenerator.DoBeforeEdit;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCGENERATOR', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCGENERATOR', KEYDOBEFOREEDIT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREEDIT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCGENERATOR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCGENERATOR',
  {M}          'DOBEFOREEDIT', KEYDOBEFOREEDIT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCGENERATOR' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FChangeName := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCGENERATOR', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCGENERATOR', 'DOBEFOREEDIT', KEYDOBEFOREEDIT);
  {M}  end;
  {END MACRO}
end;

class function TgdcGenerator.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmGenerator';
end;

procedure TgdcGenerator._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet;
  PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True);
begin
  //� ����� ��������� ������ ����������-��������
  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('generatorname').AsString)) = 1 then
  begin
    SaveToStreamDependencies(Stream, ObjectSet,
      FieldByName('generatorname').AsString, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
    inherited;
  end;
end;

function TgdcGenerator.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCGENERATOR', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCGENERATOR', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCGENERATOR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCGENERATOR',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCGENERATOR' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
//����������� ������ ���� �� ��������������
  if FieldByName(GetKeyField(SubType)).AsInteger < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT %s FROM %s WHERE UPPER(generatorname)=''%s'' ',
      [GetKeyField(SubType), GetListTable(SubType), AnsiUpperCase(FieldByName('generatorname').AsString)]);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCGENERATOR', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCGENERATOR', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcGenerator.GetDisplayName(const ASubType: TgdcSubType): String;
begin
  Result := '���������';
end;

function TgdcGenerator.GetCanDelete: Boolean;
begin
  Result := inherited GetCanDelete and Active and
    (AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('generatorname').AsString)) = 1);
end;

function TgdcGenerator.GetCanEdit: Boolean;
begin
  Result := inherited GetCanEdit and Active and
    (AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('generatorname').AsString)) = 1);
end;

{ TgdcCheckConstraint }

procedure TgdcCheckConstraint._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet; PropertyList: TgdcPropertySets;
  BindedList: TgdcObjectSet; WithDetailList: TgdKeyArray;
  const SaveDetailObjects: Boolean);
begin
  inherited;
  //� ����� ��������� ������ ����-��������
  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('checkname').AsString)) = 1 then
  begin
    SaveToStreamDependencies(Stream, ObjectSet,
      FieldByName('checkname').AsString, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
    inherited;
  end;
end;

function TgdcCheckConstraint.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCCHECKCONSTRAINT', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKCONSTRAINT', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKCONSTRAINT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKCONSTRAINT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKCONSTRAINT' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
//����������� ������ ���� �� ��������������
  if FieldByName(GetKeyField(SubType)).AsInteger < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT %s FROM %s WHERE UPPER(checkname)=''%s'' ',
      [GetKeyField(SubType), GetListTable(SubType), AnsiUpperCase(FieldByName('checkname').AsString)]);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKCONSTRAINT', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKCONSTRAINT', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

constructor TgdcCheckConstraint.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpModify, cpDelete];
end;

function TgdcCheckConstraint.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCCHECKCONSTRAINT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKCONSTRAINT', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKCONSTRAINT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKCONSTRAINT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKCONSTRAINT' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
    Result := Tgdc_dlgCheckConstraint.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKCONSTRAINT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKCONSTRAINT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCheckConstraint.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCHECKCONSTRAINT', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKCONSTRAINT', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKCONSTRAINT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKCONSTRAINT',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKCONSTRAINT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('checkname').AsString)) = 0 then
    raise EgdcIBError.Create('�� �� ������ ������� ����������� �����������!');

  Drop;
  inherited;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKCONSTRAINT', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKCONSTRAINT', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCheckConstraint.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCHECKCONSTRAINT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKCONSTRAINT', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKCONSTRAINT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKCONSTRAINT',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKCONSTRAINT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('checkname').AsString)) = 1 then
    MetaDataCreate;
  inherited;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKCONSTRAINT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKCONSTRAINT', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCheckConstraint.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCHECKCONSTRAINT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKCONSTRAINT', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKCONSTRAINT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKCONSTRAINT',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKCONSTRAINT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  MetaDataAlter;
  inherited;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKCONSTRAINT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKCONSTRAINT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

destructor TgdcCheckConstraint.Destroy;
begin
  inherited;

end;

procedure TgdcCheckConstraint.DoBeforeEdit;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCHECKCONSTRAINT', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKCONSTRAINT', KEYDOBEFOREEDIT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREEDIT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKCONSTRAINT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKCONSTRAINT',
  {M}          'DOBEFOREEDIT', KEYDOBEFOREEDIT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKCONSTRAINT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FChangeName := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKCONSTRAINT', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKCONSTRAINT', 'DOBEFOREEDIT', KEYDOBEFOREEDIT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCheckConstraint.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  S: String;
  I: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCHECKCONSTRAINT', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKCONSTRAINT', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKCONSTRAINT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKCONSTRAINT',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKCONSTRAINT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if (Trim(FieldByName('checkname').AsString) = '') then
  begin
    FieldByName('checkname').FocusControl;
    raise Exception.Create('������� ������������ �����������!');
  end;

 //  ��� ���������� ������ ��������� ������
 //  ���������� �������
  S := Trim(AnsiUpperCase(FieldByName('checkname').AsString));
   for I := 1 to Length(S) do
     if not (S[I] in ['A'..'Z', '_', '0'..'9', '$']) then
     begin
       FieldByName('checkname').FocusControl;
       raise Exception.Create('�������� ����������� ������ ���� �� ���������� �����!');
     end;

  if (Trim(FieldByName('RDB$TRIGGER_SOURCE').AsString) = '') then
  begin
    FieldByName('RDB$TRIGGER_SOURCE').FocusControl;
    raise Exception.Create('������� ������� �����������!');
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCGENERATOR', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKCONSTRAINT', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCheckConstraint.Drop;
var
  FSQL: TSQLProcessList;
begin
  FSQL := TSQLProcessList.Create;
  try
    if Assigned(FgdcDataLink) then
      with FgdcDataLink do
        if Active and (DataSet is TgdcRelation) then
          FSQL.Add(Format('ALTER TABLE %s DROP CONSTRAINT %s',
          [DataSet.FieldByName('relationname').AsString, FieldByName('checkname').AsString]))
    else
      FSQL.Add(Format('ALTER TABLE %s DROP CONSTRAINT %s',
        [Trim(FieldByName('RDB$RELATION_NAME').AsString), FieldByName('checkname').AsString]));

    ShowSQLProcess(FSQL);
  finally
    FSQL.Free;
  end;
end;

class function TgdcCheckConstraint.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  Result := '�����������';
end;

function TgdcCheckConstraint.GetFromClause(
  const ARefresh: Boolean): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCCHECKCONSTRAINT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKCONSTRAINT', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKCONSTRAINT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKCONSTRAINT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKCONSTRAINT' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' FROM AT_CHECK_CONSTRAINTS Z ' +
    ' LEFT JOIN RDB$CHECK_CONSTRAINTS C ON C.RDB$CONSTRAINT_NAME = Z.CHECKNAME ' +
    ' LEFT JOIN RDB$TRIGGERS T ON T.RDB$TRIGGER_NAME = C.RDB$TRIGGER_NAME ' +
    ' LEFT JOIN AT_RELATIONS R ON R.RELATIONNAME = T.RDB$RELATION_NAME ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKCONSTRAINT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKCONSTRAINT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcCheckConstraint.GetKeyField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'id';
end;

class function TgdcCheckConstraint.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'checkname';
end;

class function TgdcCheckConstraint.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'AT_CHECK_CONSTRAINTS';
end;

function TgdcCheckConstraint.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCCHECKCONSTRAINT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKCONSTRAINT', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKCONSTRAINT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKCONSTRAINT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKCONSTRAINT' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'SELECT Z.*, T.RDB$TRIGGER_SOURCE, T.RDB$RELATION_NAME';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKCONSTRAINT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKCONSTRAINT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcCheckConstraint.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByRelation;';
end;

class function TgdcCheckConstraint.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmCheckConstraint';
end;

procedure TgdcCheckConstraint.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add('T.RDB$TRIGGER_TYPE = 1');
  if HasSubSet('OnlyAttribute') then
    S.Add('z.checkname LIKE ''USR$%''');
  if HasSubSet('ByRelation') then
    S.Add('r.id = :relationkey');
end;

procedure TgdcCheckConstraint.MetaDataAlter;
begin
  Drop;
  MetaDataCreate;
end;

procedure TgdcCheckConstraint.MetaDataCreate;
var
  FSQL: TSQLProcessList;
begin
  FSQL := TSQLProcessList.Create;
  try
    if Assigned(FgdcDataLink) then
      with FgdcDataLink do
        if Active and (DataSet is TgdcRelation) then
          FSQL.Add(Format('ALTER TABLE %s ADD CONSTRAINT %s %s',
           [DataSet.FieldByName('relationname').AsString,
            FieldByName('checkname').AsString, FieldByName('RDB$TRIGGER_SOURCE').AsString]))
    else
      FSQL.Add(Format('ALTER TABLE %s ADD CONSTRAINT %s %s',
       [Trim(FieldByName('RDB$RELATION_NAME').AsString),
        FieldByName('checkname').AsString, FieldByName('RDB$TRIGGER_SOURCE').AsString]));

    ShowSQLProcess(FSQL);
  finally
    FSQL.Free;
    NeedSingleUser := False;
  end;
end;

function TgdcCheckConstraint.GetCanDelete: Boolean;
begin
  Result := inherited GetCanDelete and Active and
    (AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('checkname').AsString)) = 1);
end;

function TgdcCheckConstraint.GetCanEdit: Boolean;
begin
  Result := inherited GetCanEdit and Active and
    (AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('checkname').AsString)) = 1);
end;

function TgdcCheckConstraint.CheckName: Boolean;
var
  ibsql: TIBSQL;
begin
  Result := True;

  ibsql := CreateReadIBSQL;
  try
    ibsql.SQL.Text := 'SELECT * FROM RDB$CHECK_CONSTRAINTS WHERE RDB$CONSTRAINT_NAME = :checkname';
    ibsql.ParamByName('checkname').AsString := FieldByName('checkname').AsString;
    ibsql.ExecQuery;

    if ibsql.RecordCount > 0 then
    begin
      Result := False;
    end else
  finally
    ibsql.Free;
  end;
end;

procedure TgdcCheckConstraint._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCHECKCONSTRAINT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKCONSTRAINT', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKCONSTRAINT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKCONSTRAINT',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKCONSTRAINT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  with FgdcDataLink do
   if Active and (DataSet is TgdcRelation) then
     FieldByName('checkname').AsString := UserPrefix + 'CHECK_' + DataSet.FieldByName('relationname').AsString +
       GetUniqueID(Database, ReadTransaction);
  FieldByName('RDB$TRIGGER_SOURCE').AsString := 'CHECK ()';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINDEX', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKCONSTRAINT', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

initialization
  RegisterGdcClass(TgdcMetaBase);
  RegisterGdcClass(TgdcField);
  RegisterGdcClass(TgdcFieldInfo);
  RegisterGdcClass(TgdcRelation);
  RegisterGdcClass(TgdcBaseTable);
  RegisterGdcClass(TgdcTable);
  RegisterGdcClass(TgdcSimpleTable);
  RegisterGdcClass(TgdcPrimeTable);
  RegisterGdcClass(TgdcUnknownTable);
  RegisterGdcClass(TgdcTableToTable);
  RegisterGdcClass(TgdcTreeTable);
  RegisterGdcClass(TgdcLBRBTreeTable);
  RegisterGdcClass(TgdcView);
  RegisterGdcClass(TgdcRelationField);
  RegisterGdcClass(TgdcTableField);
  RegisterGdcClass(TgdcViewField);
  RegisterGdcClass(TgdcStoredProc);
  RegisterGdcClass(TgdcException);
  RegisterGdcClass(TgdcIndex);
  RegisterGdcClass(TgdcTrigger);
  RegisterGdcClass(TgdcGenerator);
  RegisterGdcClass(TgdcCheckConstraint);

  for TrCount := 1 to MaxInvCardTrigger do
  begin
    InvCardTriggerImitate[TrCount] := False;
    InvCardTriggerDrop[TrCount] := False;
  end;

finalization
  UnRegisterGdcClass(TgdcMetaBase);
  UnRegisterGdcClass(TgdcField);
  UnRegisterGdcClass(TgdcFieldInfo);
  UnRegisterGdcClass(TgdcRelation);
  UnRegisterGdcClass(TgdcTable);
  UnRegisterGdcClass(TgdcBaseTable);
  UnRegisterGdcClass(TgdcSimpleTable);
  UnRegisterGdcClass(TgdcPrimeTable);  
  UnRegisterGdcClass(TgdcUnknownTable);
  UnRegisterGdcClass(TgdcTableToTable);
  UnRegisterGdcClass(TgdcTreeTable);
  UnRegisterGdcClass(TgdcLBRBTreeTable);
  UnRegisterGdcClass(TgdcView);
  UnRegisterGdcClass(TgdcRelationField);
  UnRegisterGdcClass(TgdcTableField);
  UnRegisterGdcClass(TgdcViewField);
  UnRegisterGdcClass(TgdcStoredProc);
  UnRegisterGdcClass(TgdcException);
  UnRegisterGdcClass(TgdcIndex);
  UnRegisterGdcClass(TgdcTrigger);
  UnRegisterGdcClass(TgdcGenerator);
  UnRegisterGdcClass(TgdcCheckConstraint);

end.
