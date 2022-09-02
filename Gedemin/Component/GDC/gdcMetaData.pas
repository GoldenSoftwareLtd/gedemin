// ShlTanya, 10.02.2019

{++

  Copyright (c) 2001-2022 by Golden Software of Belarus, Ltd

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
    3.0    10.01.2001   michael    Добавлено создание методанных прямо в БО
    4.0    08.05.2002   Julia      Добавлены классы TgdcException, TgdcIndex
    4.1    17.05.2002   Julia      Добавлен класс TgdcTrigger
    4.2    30.06.2007   Alexandra
                        Alexander  Добавлен класс TgdcGenerator
    4.3.   03.10.2007   Alexander  Добавлен класс TgdcCheckConstraint
--}

unit gdcMetaData;

interface

uses
  Windows, Classes, Contnrs, IBCustomDataSet, gdcBase, Forms, gd_createable_form,
  at_classes, SysUtils, IBSQL, Db, IBDatabase, gdcBaseInterface, gd_KeyAssoc;

type
  TgdcOnCustomTable = procedure (Sender: TObject; Scripts: TStringList) of object;

  TgdcTableType = (
    ttUnknow,
    ttSimpleTable,
    ttTree,
    ttIntervalTree,
    ttCustomTable,
    ttDocument,
    ttDocumentLine,
    ttInvSimple,
    ttInvFeature,
    ttInvInvent,
    ttInvTransfrom,
    ttTableToTable,
    ttPrimeTable,
    ttInheritedTable,
    ttInheritedDocumentTable);

  TgdcTablePersistence = (
    tpRegular,
    tpGTTConnection,
    tpGTTTransaction);

  TgdcMetadataScript = (
    mdsNone,
    mdsCreate,
    mdsAlter,
    mdsDrop);

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

  CgdcMetaBase = class of TgdcMetaBase;
  TgdcMetaBase = class(TgdcBase)
  protected
    //Изменяется при создании мета-данных
    //Указывает, нужно ли подключение в однопользовательском режиме
    FNeedSingleUser: Boolean;
    FSkipMetadata: Boolean;
    FMetaDataScript: TgdcMetadataScript;
    FDeletedID: TID;

    function GetIsUserDefined: Boolean; virtual;
    function GetIsFirebirdObject: Boolean; virtual;
    function GetIsDerivedObject: Boolean; virtual;
    function GetFirebirdObjectName: String; virtual;
    function GetFirebirdObjectNameField: String; virtual;
    function GetObjectName: String; override;

    procedure ShowSQLProcess(S: TSQLProcessList); overload;
    procedure ShowSQLProcess(const S: String); overload;

    procedure SaveToStreamDependencies(Stream: TStream;
      ObjectSet: TgdcObjectSet; ADependent_Name: String;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); virtual;

    //считывают права доступа
    //добавлены, чтобы можно было определять права доступа к каждой записи
    //по умолчанию считывают права доступа к классу
    function GetCanDelete: Boolean; override;
    function GetCanEdit: Boolean; override;
    function GetCanAddToNS: Boolean; override;

    function GetRelationName: String; virtual;

    procedure DoBeforePost; override;
    procedure DoAfterPost; override;
    procedure DoAfterDelete; override;
    procedure DoBeforeInsert; override;
    procedure DoBeforeEdit; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

    procedure CustomDelete(Buff: Pointer); override;
    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    procedure GetMetadataScript(S: TSQLProcessList; const AMetadata: TgdcMetadataScript); virtual;
    procedure SyncAtDatabase(const AnID: TID; const AMetadata: TgdcMetadataScript); virtual;
    procedure SyncRDBObjects; virtual;
    procedure CheckDependencies; virtual;
    procedure DropDependencies; virtual;
    procedure MakePredefinedObjects; virtual;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetSubSetList: String; override;
    class function IsAbstractClass: Boolean; override;
    class function NeedModifyFromStream(const SubType: String): Boolean; override;
    class function Class_TestUserRights(const SS: TgdcTableInfos;
      const ST: String): Boolean; override;

    function GetDialogDefaultsFields: String; override;
    function GetAutoObjectsNames(SL: TStrings): Boolean; virtual;
    procedure GetProperties(ASL: TStrings); override;
    function CheckObjectName(const ARaiseException: Boolean = True;
      const AFocusControl: Boolean = True; const AFieldName: String = ''): Boolean; virtual;
    function CheckTheSameStatement: String; override;

    property IsUserDefined: Boolean read GetIsUserDefined;
    property IsFirebirdObject: Boolean read GetIsFirebirdObject;
    property IsDerivedObject: Boolean read GetIsDerivedObject;
    property RelationName: String read GetRelationName;
    property FirebirdObjectName: String read GetFirebirdObjectName;
  end;

  TgdcRelationField = class;
  TgdcTableField = class;

  CgdcTable = class of TgdcTable;

  TgdcField = class(TgdcMetaBase)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;

    procedure _DoOnNewRecord; override;
    procedure DoBeforePost; override;

    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetFirebirdObjectNameField: String; override;
    procedure SyncAtDatabase(const AnID: TID; const AMetadata: TgdcMetadataScript); override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    function GetDomainText(const WithCharSet: Boolean = True; const OnlyDataType: Boolean = False): String;
    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray;
      const SaveDetailObjects: Boolean = True); override;
  end;

  TgdcRelation = class(TgdcMetaBase)
  protected
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;
    procedure SyncAtDatabase(const AnID: TID; const AMetadata: TgdcMetadataScript); override;
    procedure CheckDependencies; override;
    procedure DropDependencies; override;
    function GetFirebirdObjectNameField: String; override;

    function GetIsDerivedObject: Boolean; override;

    procedure DoBeforePost; override;
    procedure CreateFields; override;

    function GetTableType: TgdcTableType; virtual; abstract;

    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetCanView: Boolean; override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetListFieldExtended(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function IsAbstractClass: Boolean; override;

    function GetCurrRecordClass: TgdcFullClass; override;
    function CheckObjectName(const ARaiseException: Boolean = True;
      const AFocusControl: Boolean = True; const AFieldName: String = ''): Boolean; override;

    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;

    property TableType: TgdcTableType read GetTableType;
  end;

  TgdcBaseTable = class(TgdcRelation)
  private
    FOnCustomTable: TgdcOnCustomTable;

  protected
    function CreateGenerator: String;
    function CreateInsertTrigger: String;
    function CreateEditorForeignKey: String;
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;
    procedure MakePredefinedObjects; override;
    procedure _DoOnNewRecord; override;
    function GetTableType: TgdcTableType; override;
    procedure NewField(FieldName, LName, FieldSource, Description,
      LShortName, Alignment, ColWidth, ReadOnly, Visible: String);
    procedure GetWhereClauseConditions(S: TStrings); override;
    //Функция возвращяет поля через запятую, которые входят в праймари кей

  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function CreateInsertEditorTrigger(const ARelationName: String): String; virtual;
    class function CreateUpdateEditorTrigger(const ARelationName: String): String; virtual;
    class function GetPrimaryFieldName: String; virtual;

    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;

  published
    property OnCustomTable: TgdcOnCustomTable read FOnCustomTable
      write FOnCustomTable;
  end;

  //используется для работы с кросс-таблицами при загрузке их из потока
  TgdcUnknownTable = class(TgdcBaseTable)
  protected
    procedure CustomInsert(Buff: Pointer); override;
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;
    procedure MakePredefinedObjects; override;

  public
    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;
  end;

  TgdcTable = class(TgdcBaseTable)
  protected
    procedure SyncAtDatabase(const AnID: TID; const AMetadata: TgdcMetadataScript); override;
  end;

  TgdcPrimeTable = class(TgdcTable)
  protected
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;
    procedure MakePredefinedObjects; override;

  public
    class function CreateInsertEditorTrigger(const ARelationName: String): String; override;
    class function CreateUpdateEditorTrigger(const ARelationName: String): String; override;
  end;

  TgdcSimpleTable = class(TgdcTable)
  protected
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;
    procedure MakePredefinedObjects; override;
  end;

  TgdcTableToTable = class(TgdcTable)
  private
    FIDDomain: String;

  protected
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;
    procedure SyncAtDatabase(const AnID: TID; const AMetadata: TgdcMetadataScript); override;
    procedure MakePredefinedObjects; override;

  public
    function GetReferenceName: String;
  end;

  TgdcInheritedTable = class(TgdcTableToTable)
  public
    class function GetPrimaryFieldName: String; override;
  end;

  TgdcTreeTable = class(TgdcTable)
  protected
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;
    procedure MakePredefinedObjects; override;
  end;

  TgdcLBRBTreeTable = class(TgdcTable)
  protected
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;
    procedure MakePredefinedObjects; override;
    procedure CheckDependencies; override;
    procedure DropDependencies; override;

  public
    function GetAutoObjectsNames(SL: TStrings): Boolean; override;
  end;

  TgdcView = class(TgdcRelation)
  protected
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;
    procedure MakePredefinedObjects; override;
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure _DoOnNewRecord; override;
    procedure CustomModify(Buff: Pointer); override;
    function GetTableType: TgdcTableType; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    function GetViewTextBySource(const Source: String): String;
    function GetAlterViewTextBySource(const Source: String): String;
  end;

  TgdcRelationField = class(TgdcMetaBase)
  protected
    function GetObjectName: String; override;
    function GetFirebirdObjectNameField: String; override;

    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetOrderClause: String; override;

    procedure _DoOnNewRecord; override;
    procedure DoBeforePost; override;
    procedure CreateFields; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function GetSubSetList: String; override;
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetListFieldExtended(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    function CheckTheSameStatement: String; override;
    function GetCurrRecordClass: TgdcFullClass; override;
  end;

  TgdcTableField = class(TgdcRelationField)
  private
    function CreateCrossRelationSQL: String;
    function CreateCrossRelationTriggerSQL: String;

    procedure CreateInvCardTrigger(ResultList: TSQLProcessList;
      const IsDrop: Boolean = False);
    procedure AlterAcEntryBalanceAndRecreateTrigger(ResultList: TSQLProcessList; const IsDrop: Boolean = False);
    function CreateAccCirculationList(const IsDrop: Boolean = False): String;

  protected
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;
    procedure MakePredefinedObjects; override;
    procedure SyncAtDatabase(const AnID: TID; const AMetadata: TgdcMetadataScript); override;
    procedure SyncRDBObjects; override;
    procedure _DoOnNewRecord; override;
    procedure CustomInsert(Buff: Pointer); override;
    function GetIsDerivedObject: Boolean; override;

  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    function CheckObjectName(const ARaiseException: Boolean = True;
      const AFocusControl: Boolean = True; const AFieldName: String = ''): Boolean; override;
  end;

  TgdcViewField = class(TgdcRelationField)
  protected
    procedure _DoOnNewRecord; override;

  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcStoredProc = class(TgdcMetaBase)
  private
    function GetParamsText: String;

  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;

    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    // Список полей, которые не надо сохранять в поток.
    class function GetNotStreamSavedField(const IsReplicationMode: Boolean = False): String; override;

    function GetProcedureText: String;

    procedure PrepareToSaveToStream(BeforeSave: Boolean);
    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;
  end;

  TgdcException = class(TgdcMetaBase)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcIndex = class(TgdcMetaBase)
  protected
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetSelectClause: String; override;

    procedure DoAfterOpen; override;
    procedure _DoOnNewRecord; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

    procedure SaveToStreamDependencies(Stream: TStream;
      ObjectSet: TgdcObjectSet; ADependent_Name: String;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;

    function GetIsFirebirdObject: Boolean; override;

  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    function CheckObjectName(const ARaiseException: Boolean = True;
      const AFocusControl: Boolean = True; const AFieldName: String = ''): Boolean; override;
    procedure SyncIndices(const ARelationName: String; const NeedRefresh: Boolean = True);
    procedure SyncAllIndices(const NeedRefresh: Boolean = True);

    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;
  end;

  TgdcBaseTrigger = class(TgdcMetaBase)
  protected
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetSelectClause: String; override;
    procedure DoBeforePost; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetCanEdit: Boolean; override;
    function GetIsDerivedObject: Boolean; override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
    // Список полей, которые не надо сохранять в поток.
    class function GetNotStreamSavedField(const IsReplicationMode: Boolean = False): String; override;
    class procedure EnumTriggerTypes(S: TStrings); virtual;

    procedure SyncAllTriggers(const NeedRefresh: Boolean = True);

    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;

    function ComposeTriggerName: String; virtual;
  end;

  TgdcTrigger = class(TgdcBaseTrigger)
  protected
    procedure _DoOnNewRecord; override;

  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
    class procedure EnumTriggerTypes(S: TStrings); override;

    procedure SyncTriggers(const ARelationName: String; const NeedRefresh: Boolean = True);

    function CalcPosition(RelationName: String; TriggerType: Integer): Integer;
    function ComposeTriggerName: String; override;
  end;

  TgdcDBTrigger = class(TgdcBaseTrigger)
  protected
    procedure _DoOnNewRecord; override;

  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
    class procedure EnumTriggerTypes(S: TStrings); override;
  end;

  TgdcCheckConstraint = class(TgdcMetaBase)
  protected
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetSelectClause: String; override;

    procedure _DoOnNewRecord; override;

    procedure GetWhereClauseConditions(S: TStrings); override;
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;

  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;

    class function GetSubSetList: String; override;

    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;
  end;

  TgdcGenerator = class(TgdcMetaBase)
  protected
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetSelectClause: String; override;
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;
  end;

  EgdcIBError = class(Exception);

procedure Register;

function GetKeyFieldName(const ARelationName: String): String;
function GetTableTypeByName(const ARelationName: String): TgdcTableType;
function GetDefValueInQuotes(const DefaultValue: String): String;
function GetSimulateFieldNameByRel(RelName: String): String;
function GetObjectNameByRelName(const ARelName, APrefix: String): String;

//Возвращает значение по-умолчанию в зависимости от переданного параметра
function GetDefaultExpression(const ADefaultExpression: String): Variant;

const
  MaxInvCardTrigger = 5;

implementation

uses
  gdc_frmField_unit, gdc_frmRelation_unit, gdc_frmTable_unit,
  gdc_attr_frmRelationField_unit, gdc_dlgField_unit, gdc_dlgRelation_unit,
  gdc_dlgRelationField_unit, at_frmSQLProcess, at_frmIBUserList,
  gd_security, gdc_attr_dlgView_unit, gdc_attr_frmStoredProc_unit,
  gdc_attr_dlgStoredProc_unit, gd_ClassList, IBHeader, Graphics,
  dmDatabase_unit, at_sql_parser, jclStrings, gdc_attr_dlgException_unit,
  gdc_frmException_unit, gdc_attr_dlgIndices_unit, gdc_attr_dlgTrigger_unit,
  gdc_attr_frmTrigger_unit, gdc_attr_frmDBTrigger_unit,
  gdc_attr_frmIndices_unit, Dialogs, ib, at_sql_setup, gd_directories_const,
  gdcTriggerhelper, gdc_attr_dlgGenerator_unit, gdc_attr_frmGenerator_unit,
  gdc_attr_frmCheckConstraint_unit, gdc_attr_dlgCheckConstraint_unit,
  gdcLBRBTreeMetaData, gd_common_functions, gd_messages_const
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

type
  Tcst_def_KeyWords = (
    KW_CURRENT_DATE,
    KW_CURRENT_TIME,
    KW_CURRENT_USER,
    KW_CURRENT_ROLE,
    KW_CURRENT_TIMESTAMP,
    KW_CURRENT_TIMESTAMP_0,
    KW_NOW,
    KW_NULL);

const
  cst_def_KeyWords: array[Tcst_def_KeyWords] of String = (
    'CURRENT_DATE',
    'CURRENT_TIME',
    'CURRENT_USER',
    'CURRENT_ROLE',
    'CURRENT_TIMESTAMP',
    'CURRENT_TIMESTAMP(0)',
    'NOW',
    'NULL');

var
//Указывает, что было съимитировано создание триггера USR$_BU_INV_CARD
//Может быть истина только в режиме переподключения к БД
  InvCardTriggerImitate: array[1..MaxInvCardTrigger] of Boolean;
//Указывает, что было съимитировано удаление триггера USR$_BU_INV_CARD
//Может быть истина только в режиме переподключения к БД
  InvCardTriggerDrop: array[1..MaxInvCardTrigger] of Boolean;

procedure Register;
begin
  RegisterComponents(
    'gdcMetaData',
    [
      TgdcField, TgdcRelation, TgdcTable,
      TgdcView, TgdcRelationField, TgdcTableField, TgdcViewField, TgdcStoredProc,
      TgdcException, TgdcIndex, TgdcTrigger, TgdcDBTrigger, TgdcPrimeTable, TgdcGenerator, TgdcCheckConstraint
    ]
  );
end;

function GetFieldType(const AnID: TID): Integer;
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

//Функция возвращает название форейн ключа по названию таблицы и поля
function GetForeignName(const ATableName, ForeignField: String): String;
begin
  if AnsiPos(UserPrefix, ATableName) = 1 then
  begin
    Result := 'USR$FK_' + Copy(ATableName, Length(UserPrefix) + 1, 1024) + '_' + ForeignField;
  end else
  begin
    Result := Copy(ATableName, 1, AnsiPos('_', ATableName)) + 'FK_' +
      Copy(ATableName, AnsiPos('_', ATableName) + 1, Length(ATableName) - AnsiPos('_', ATableName)) +
      '_' + ForeignField;
  end;

  if Length(Result) > cstMetaDataNameLength then
    Result := gdcBaseManager.AdjustMetaName(Result);
end;

//Функция возвращает название триггера по названию таблицы и позиции
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

function GetObjectNameByRelName(const ARelName, APrefix: String): String;
var
  S: String;
  I: Integer;
begin
  S := ARelName;
  if Pos(UserPrefix, S) = 1 then
    S := System.Copy(S, Length(UserPrefix) + 1, 256);
  I := Pos('_', S);
  if I = 0 then
    Result := gdcBaseManager.AdjustMetaName(UserPrefix + APrefix + S)
  else
    Result := gdcBaseManager.AdjustMetaName(UserPrefix +
       System.Copy(S, 1, I - 1) + APrefix + System.Copy(S, I + 1, 256));
end;

// Уникальный идентификатор для Interbase-овских имен
function GetUniqueID(D: TIBDatabase; T: TIBTransaction;
  const GenName: String = 'GD_G_TRIGGERCROSS'): String;
var
  ibsqlWork: TIBSQL;
begin
  Assert(gdcBaseManager <> nil);
  ibsqlWork := TIBSQL.Create(nil);
  try
    ibsqlWork.Transaction := gdcBaseManager.ReadTransaction;
    ibsqlWork.SQL.Text := Format(
      'SELECT GEN_ID(%s, 1) FROM rdb$database', [GenName]
    );
    ibsqlWork.ExecQuery;
    Result := ibsqlWork.Fields[0].AsString;
  finally
    ibsqlWork.Free;
  end;
end;

//Возвращает значение по-умолчанию в зависимости от переданного параметра
function GetDefaultExpression(const ADefaultExpression: String): Variant;
var
  H, M, S, Ms: Word;
begin
  Assert(IBLogin <> nil);
  Assert(ADefaultExpression > '');

  Result := ADefaultExpression;

  case ADefaultExpression[1] of
    'C':
    begin
      if AnsiCompareText(ADefaultExpression, cst_def_KeyWords[KW_CURRENT_DATE]) = 0 then
        Result := Date
      else if AnsiCompareText(ADefaultExpression, cst_def_KeyWords[KW_CURRENT_TIME]) = 0 then
        Result := Time
      else if AnsiCompareText(ADefaultExpression, cst_def_KeyWords[KW_CURRENT_TIMESTAMP]) = 0 then
        Result := Now
      else if AnsiCompareText(ADefaultExpression, cst_def_KeyWords[KW_CURRENT_TIMESTAMP_0]) = 0 then
      begin
        DecodeTime(Now, H, M, S, Ms);
        Result := EncodeTime(H, M, S, 0);
      end
      else if AnsiCompareText(ADefaultExpression, cst_def_KeyWords[KW_CURRENT_USER]) = 0 then
        Result := IBLogin.IBName
      else if AnsiCompareText(ADefaultExpression, cst_def_KeyWords[KW_CURRENT_ROLE]) = 0 then
        Result := IBLogin.IBRole;
    end;

    'N':
    begin
      if AnsiCompareText(ADefaultExpression, cst_def_KeyWords[KW_NOW]) = 0 then
        Result := Now
      else if AnsiCompareText(ADefaultExpression, cst_def_KeyWords[KW_NULL]) = 0 then
        Result := System.Null;
    end;
  end;
end;

{ TgdcField }

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
  FieldByName('visible').AsInteger := 1;
  FieldByName('readonly').AsInteger := 0;
  FieldByName('fieldname').AsString := '';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFIELD', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFIELD', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
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
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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
  if HasSubSet('ByFieldName') then
    S.Add('z.fieldname = :fieldname')
  else if not HasSubSet('ByID') then
    S.Add('NOT (z.fieldname LIKE ''RDB$%'')');
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

        // проверяем длину поля (http://tracker.firebirdsql.org/browse/CORE-2228)
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
      raise EgdcIBError.Create('Неопределен тип домена');
    end;

    // Устанавливаем значение по умолчанию
    if (not OnlyDataType) and (dsDomain.FieldByName('defsource').AsString <> '') then
    begin
      if AnsiPos('DEFAULT', AnsiUpperCase(Trim(dsDomain.FieldByName('defsource').AsString))) <> 1 then
        Result := Result + ' DEFAULT ' + GetDefValueInQuotes(dsDomain.FieldByName('defsource').AsString)
      else
        Result := Result + ' ' + dsDomain.FieldByName('defsource').AsString;
    end;

    // Устанавливаем значение NOT NULL
    if (not OnlyDataType) and (dsDomain.FieldByName('flag').AsInteger = 1) then
      Result := Result + ' NOT NULL';

    // Если используются ограничения
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

    // Устанавливаем COLLATION для строковых полей
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
    raise EgdcIBError.Create('Неопределен тип домена');
end;

class function TgdcField.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByFieldName;';
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
  q: TIBSQL;
  DidActivate: Boolean;
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

  if not (sMultiple in BaseState) then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := Transaction;
      DidActivate := False;
      try
        DidActivate := ActivateTransaction;

        //Установим значения для таблиц-ссылок
        if (FieldByName('reftable').AsString > '') and
          (FieldByName('reftablekey').IsNull) then
        begin
          q.Close;
          q.SQL.Text := 'SELECT id FROM at_relations WHERE relationname = :RN';
          q.ParamByName('RN').AsString := AnsiUpperCase(Trim(FieldByName('reftable').AsString));
          q.ExecQuery;
          if not q.EOF then
            SetTID(FieldByName('reftablekey'), q.FieldByName('id'));
        end;

        if (Trim(FieldByName('reftable').AsString) = '') and
          (GetTID(FieldByName('reftablekey')) > 0) then
        begin
          q.Close;
          q.SQL.Text := 'SELECT relationname FROM at_relations WHERE id = :id';
          SetTID(q.ParamByName('id'), FieldByName('reftablekey'));
          q.ExecQuery;
          if not q.EOF then
            FieldByName('reftable').AsString := q.FieldByName('relationname').AsString;
        end;

        //Установим значения для полей-ссылок
        if (FieldByName('reflistfield').AsString > '') and
          (FieldByName('reflistfieldkey').IsNull) then
        begin
          q.Close;
          q.SQL.Text := 'SELECT id FROM at_relation_fields WHERE relationname = :RN AND fieldname = :FN';
          q.ParamByName('RN').AsString := AnsiUpperCase(Trim(FieldByName('reftable').AsString));
          q.ParamByName('FN').AsString := AnsiUpperCase(Trim(FieldByName('reflistfield').AsString));
          q.ExecQuery;
          if not q.EOF then
            SetTID(FieldByName('reflistfieldkey'), q.FieldByName('id'));
        end;

        if (Trim(FieldByName('reflistfield').AsString) = '') and
          (GetTID(FieldByName('reflistfieldkey')) > 0) then
        begin
          q.Close;
          q.SQL.Text := 'SELECT fieldname FROM at_relation_fields WHERE id = :id';
          SetTID(q.ParamByName('id'), FieldByName('reflistfieldkey'));
          q.ExecQuery;
          if not q.EOF then
            FieldByName('reflistfield').AsString := q.FieldByName('fieldname').AsString;
        end;

        //Установим значения для таблиц-множеств
        if (FieldByName('settable').AsString > '') and
          (FieldByName('settablekey').IsNull) then
        begin
          q.Close;
          q.SQL.Text := 'SELECT id FROM at_relations WHERE relationname = :RN';
          q.ParamByName('RN').AsString := AnsiUpperCase(Trim(FieldByName('settable').AsString));
          q.ExecQuery;
          if not q.EOF then
            SetTID(FieldByName('settablekey'), q.FieldByName('id'));
        end;

        if (Trim(FieldByName('settable').AsString) = '') and
          (GetTID(FieldByName('settablekey')) > 0) then
        begin
          q.Close;
          q.SQL.Text := 'SELECT relationname FROM at_relations WHERE id = :id';
          SetTID(q.ParamByName('id'), FieldByName('settablekey'));
          q.ExecQuery;
          if not q.EOF then
            FieldByName('settable').AsString := q.FieldByName('relationname').AsString;
        end;

        //Установим значения для полей-множеств
        if (FieldByName('setlistfield').AsString > '') and
          (FieldByName('setlistfieldkey').IsNull) then
        begin
          q.Close;
          q.SQL.Text := 'SELECT id FROM at_relation_fields WHERE relationname = :RN AND fieldname = :FN';
          q.ParamByName('RN').AsString := AnsiUpperCase(Trim(FieldByName('settable').AsString));
          q.ParamByName('FN').AsString := AnsiUpperCase(Trim(FieldByName('setlistfield').AsString));
          q.ExecQuery;
          if not q.EOF then
            SetTID(FieldByName('setlistfieldkey'), q.FieldByName('id'));
        end;

        if (Trim(FieldByName('setlistfield').AsString) = '') and
          (GetTID(FieldByName('setlistfieldkey')) > 0) then
        begin
          q.Close;
          q.SQL.Text := 'SELECT fieldname FROM at_relation_fields WHERE id = :id';
          SetTID(q.ParamByName('id'), FieldByName('setlistfieldkey'));
          q.ExecQuery;
          if not q.EOF then
            FieldByName('setlistfield').AsString := q.FieldByName('fieldname').AsString;
        end;

        if DidActivate and Transaction.InTransaction then
          Transaction.Commit;
      except
        if DidActivate and Transaction.InTransaction then
          Transaction.Rollback;
        raise;
      end;
    finally
      q.Free;
    end;
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
  if IsFirebirdObject or IsDerivedObject then
    exit;

  SaveToStreamDependencies(Stream, ObjectSet,
    FieldByName('fieldname').AsString, PropertyList, BindedList, WithDetailList,
    SaveDetailObjects);

  inherited;
end;

class function TgdcField.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgField';
end;

function TgdcField.GetFirebirdObjectNameField: String;
begin
  Result := 'fieldname';
end;

procedure TgdcField.SyncAtDatabase(const AnID: TID; const AMetadata: TgdcMetadataScript);
begin
  inherited;

  if (AMetadata = mdsDrop) and (atDatabase.Fields.ByID(AnID) <> nil) then
    atDatabase.Fields.Delete(atDatabase.Fields.IndexOf(atDatabase.Fields.ByID(AnID)));
end;

procedure TgdcField.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
begin
  case AMetadata of
    mdsCreate: S.Add('CREATE DOMAIN ' + FirebirdObjectName + ' AS ' + GetDomainText);
    mdsDrop: S.Add('DROP DOMAIN ' + FirebirdObjectName);
  end;
end;

{ TgdcRelation }

function TgdcRelation.GetCurrRecordClass: TgdcFullClass;
var
  CE: TgdClassEntry;
begin
  if not IsEmpty then
  begin
    if FieldByName('relationtype').AsString = 'T' then
    begin
      CE := nil;

      if FieldByName('relationname').AsString > '' then
        case GetTableTypeByName(FieldByName('relationname').AsString) of
          ttInheritedTable:      CE := gdClassList.Get(TgdBaseEntry, 'TgdcInheritedTable', '');
          ttTableToTable:        CE := gdClassList.Get(TgdBaseEntry, 'TgdcTableToTable', '');
          ttSimpleTable:         CE := gdClassList.Get(TgdBaseEntry, 'TgdcSimpleTable', '');
          ttTree:                CE := gdClassList.Get(TgdBaseEntry, 'TgdcTreeTable', '');
          ttIntervalTree:        CE := gdClassList.Get(TgdBaseEntry, 'TgdcLBRBTreeTable', '');
          ttCustomTable:         CE := gdClassList.Get(TgdBaseEntry, 'TgdcCustomTable', '');
          ttDocument:            CE := gdClassList.Get(TgdBaseEntry, 'TgdcDocumentTable', '');
          ttDocumentLine:        CE := gdClassList.Get(TgdBaseEntry, 'TgdcDocumentLineTable', '');
          ttInvSimple:           CE := gdClassList.Get(TgdBaseEntry, 'TgdcInvSimpleDocumentLineTable', '');
          ttInvFeature:          CE := gdClassList.Get(TgdBaseEntry, 'TgdcInvFeatureDocumentLineTable', '');
          ttInvInvent:           CE := gdClassList.Get(TgdBaseEntry, 'TgdcInvInventDocumentLineTable', '');
          ttInvTransfrom:        CE := gdClassList.Get(TgdBaseEntry, 'TgdcInvTransformDocumentLineTable', '');
          ttUnknow:              CE := gdClassList.Get(TgdBaseEntry, 'TgdcUnknownTable', '');
          ttPrimeTable:          CE := gdClassList.Get(TgdBaseEntry, 'TgdcPrimeTable', '');
          ttInheritedDocumentTable: CE := gdClassList.Get(TgdBaseEntry, 'TgdcInheritedDocumentTable', '');
        end;

      if CE is TgdBaseEntry then
        Result.gdClass := TgdBaseEntry(CE).gdcClass
      else if Self is TgdcBaseTable then
        Result.gdClass := CgdcBase(Self.ClassType)
      else
        Result.gdClass := TgdcTable;
    end
    else if FieldByName('relationtype').AsString = 'V' then
      Result.gdClass := TgdcView
    else
      raise EgdcException.CreateObj('Invalid relation type', Self);
  end else
    Result.gdClass := CgdcBase(Self.ClassType);

  Result.SubType := SubType;
  FindInheritedSubType(Result);
end;

class function TgdcRelation.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'lname';
end;

class function TgdcRelation.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'at_relations';
end;

procedure TgdcRelation.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByRelationName') then
    S.Add(' z.relationname = :relationname ');
end;

class function TgdcRelation.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByRelationName;';
end;

procedure TgdcRelation.DoBeforePost;
var
  q: TIBSQL;
  S: String;
  L: Integer;
  V: Variant;
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

  if not (sMultiple in BaseState) then
  begin
    if FieldByName('lname').IsNull then
      FieldByName('lname').AsString := FieldByName('relationname').AsString;

    if FieldByName('lshortname').IsNull then
      FieldByName('lshortname').AsString := FieldByName('lname').AsString;

    if FieldByName('description').AsString = '' then
      FieldByName('description').AsString := FieldByName('lname').AsString;

    if (sLoadFromStream in BaseState) and (State = dsEdit) then
    begin
      V := GetOldFieldValue('listfield');
      if (not VarIsEmpty(V)) and (not VarIsNull(V)) and (V > '') then
        FieldByName('listfield').AsString := V;

      V := GetOldFieldValue('extendedfields');
      if (not VarIsEmpty(V)) and (not VarIsNull(V)) and (V > '') then
        FieldByName('extendedfields').AsString := V;
    end;
  end;

  {  Если мы в состоянии загрузки из потока, выполним проверку на уникальность lname, lshortname
  При дублировании наименования, подкорректируем его
  Проверка идет через запрос к базе, никаких кэшей!!!}

  if (sLoadFromStream in BaseState) then
  begin
    q := TIBSQL.Create(nil);
    try
      if Transaction.InTransaction then
        q.Transaction := Transaction
      else
        q.Transaction := ReadTransaction;

      q.SQL.Text := 'SELECT * FROM at_relations WHERE UPPER(lname) = :lname and id <> :id';
      q.ParamByName('lname').AsString := AnsiUpperCase(FieldByName('lname').AsString);
      SetTID(q.ParamByName('id'), ID);
      q.ExecQuery;

      if not q.EOF then
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

      q.Close;
      q.SQL.Text := 'SELECT * FROM at_relations WHERE UPPER(lshortname) = :lshortname and id <> :id';
      q.ParamByName('lshortname').AsString := AnsiUpperCase(FieldByName('lshortname').AsString);
      SetTID(q.ParamByName('id'), ID);
      q.ExecQuery;

      if not q.EOF then
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
    finally
      q.Free;
    end;
  end;

  inherited;

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
  //Перед сохранением в поток нужно синхронизировать триггеры
  //т.к. информация о триггерах может не успеть занестись в таблицу
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

class function TgdcRelation.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := '';
end;

function TgdcRelation.GetIsDerivedObject: Boolean;
begin
  Result := StrIPos('USR$CROSS', FieldByName('relationname').AsString) = 1;
end;

function TgdcRelation.GetCanView: Boolean;
begin
  if (not IsEmpty) and IsFirebirdObject then
    Result := False
  else
    Result := inherited GetCanView;
end;

function TgdcRelation.CheckObjectName(const ARaiseException,
  AFocusControl: Boolean; const AFieldName: String): Boolean;
var
  FN, S: String;
begin
  Result := inherited CheckObjectName(ARaiseException, AFocusControl, AFieldName);

  if Result and (State = dsInsert) and (not (sLoadFromStream in BaseState))
    and (TableType <> ttUnknow) then
  begin
    if AFieldName = '' then
      FN := GetFirebirdObjectNameField
    else
      FN := AFieldName;

    S := FieldByName(FN).AsString;

    if StrIPos('USR$CROSS', S) = 1 then
    begin
      if AFocusControl then
        FieldByName(FN).FocusControl;
      if ARaiseException then
        raise Exception.Create('Наименование таблицы/представления не может начинаться с USR$CROSS')
      else begin
        Result := False;
        exit;
      end;
    end;

    if (S[Length(S)] in ['0'..'9', '_']) then
    begin
      if AFocusControl then
        FieldByName(FN).FocusControl;
      if ARaiseException then
        raise Exception.Create('Наименование таблицы/представления не может заканчиваться на _ или цифру')
      else begin
        Result := False;
        exit;
      end;
    end;
  end;
end;

procedure TgdcRelation.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
begin
  case AMetadata of
    mdsCreate: S.Add('GRANT ALL ON ' + FieldByName('relationname').AsString + ' TO administrator');
  end;
end;

procedure TgdcRelation.SyncAtDatabase(const AnID: TID; const AMetadata: TgdcMetadataScript);
var
  R: TatRelation;
begin
  inherited;
  if AMetadata = mdsDrop then
  begin
    R := atDatabase.Relations.ByID(AnID);
    if R <> nil then
    begin
      gdClassList.RemoveSubType(R.RelationName);
      atDatabase.Relations.Delete(atDatabase.Relations.IndexOf(R));
    end;
  end else
    atDatabase.Relations.RefreshData(Database, Transaction, True);
  Clear_atSQLSetupCache;
end;

function TgdcRelation.GetFirebirdObjectNameField: String;
begin
  Result := 'relationname';
end;

procedure TgdcRelation.DropDependencies;
var
  q: TIBSQL;
  gdcTrigger: TgdcBaseTrigger;
  gdcRelField: TgdcRelationField;
begin
  inherited;

  q := CreateReadIBSQL;
  try
    gdcTrigger := TgdcBaseTrigger.Create(nil);
    try
      gdcTrigger.Transaction := Transaction;
      gdcTrigger.SubSet := 'ByRelation,OnlyAttribute';
      SetTID(gdcTrigger.ParamByName('relationkey'), ID);
      gdcTrigger.Open;
      while not gdcTrigger.EOF do
        gdcTrigger.Delete;
    finally
      gdcTrigger.Free;
    end;

    gdcRelField := TgdcRelationField.CreateSubType(nil, '', 'ByID');
    try
      gdcRelField.Transaction := Transaction;

      q.SQL.Text :=
        'SELECT id, crosstablekey, crosstable FROM at_relation_fields ' +
        'WHERE relationkey = :relationkey AND crosstablekey IS NOT NULL ';
      SetTID(q.ParamByName('relationkey'), ID);
      q.ExecQuery;

      while not q.Eof do
      begin
        gdcRelField.ID := GetTID(q.FieldByName('id'));
        gdcRelField.Open;
        if not gdcRelField.EOF then
          gdcRelField.Delete;
        gdcRelField.Close;

        q.Next;
      end;
    finally
      gdcRelField.Free;
    end;
  finally
    q.Free;
  end;
end;

procedure TgdcRelation.CheckDependencies;
var
  q: TIBSQL;
begin
  inherited;

  q := CreateReadIBSQL;
  try
    q.SQL.Text :=
      'SELECT * FROM rdb$dependencies ' +
      'WHERE rdb$depended_on_name = :depname ' +
      '  AND (rdb$dependent_type = 1 OR rdb$dependent_type = 5) ';
    q.ParamByName('depname').AsString := FieldByName('relationname').AsString;
    q.ExecQuery;
    if not q.EOF then
    begin
      raise EgdcIBError.Create('Нельзя удалить таблицу (представление) т.к. ' +
        'она используется в процедурах или представлениях!');
    end;
  finally
    q.Free;
  end;
end;

{ TgdcTable }

function TgdcBaseTable.CreateInsertTrigger: String;
var
  GeneratorStr: String;
begin
  if FieldByName('generatorname').AsString = '' then
  begin
    Result := Format
    (
      'CREATE OR ALTER TRIGGER %1:s FOR %0:s '#13#10 +
      '  BEFORE INSERT '#13#10 +
      '  POSITION 0 '#13#10 +
      'AS '#13#10 +
      'BEGIN '#13#10 +
      '  IF (NEW.id IS NULL) THEN '#13#10 +
      '    EXECUTE PROCEDURE gd_p_getnextid_ex '#13#10 +
      '      RETURNING_VALUES NEW.id; '#13#10 +
      'END',
      [FieldByName('relationname').AsString,
       gdcBaseManager.AdjustMetaName('usr$bi_' + FieldByName('relationname').AsString)]
    );
  end else
  begin
    GeneratorStr := Format('GEN_ID(gd_g_offset, 0) + GEN_ID(%0:s, 1)',
      [FieldByName('generatorname').AsString]);

    Result := Format
    (
      'CREATE OR ALTER TRIGGER %1:s FOR %0:s '#13#10 +
      '  BEFORE INSERT '#13#10 +
      '  POSITION 0 '#13#10 +
      'AS '#13#10 +
      'BEGIN '#13#10 +
      '  IF (NEW.id IS NULL) THEN '#13#10 +
      '    NEW.id = %2:s;'#13#10 +
      'END',
      [FieldByName('relationname').AsString,
       gdcBaseManager.AdjustMetaName('usr$bi_' + FieldByName('relationname').AsString),
       GeneratorStr]
    );
  end;
end;

procedure TgdcBaseTable.NewField(FieldName,
  LName, FieldSource, Description, LShortName, Alignment, ColWidth,
  ReadOnly, Visible: String);
var
  q: TIBSQL;
  FSK: TID;
  DidActivate: Boolean;
begin
  Assert(Transaction <> nil);

  q := TIBSQL.Create(nil);
  try
    DidActivate := ActivateTransaction;
    q.Transaction := Transaction;

    q.SQL.Text := 'SELECT id FROM at_fields WHERE fieldname = :fn';
    q.ParamByName('fn').AsString := FieldSource;
    q.ExecQuery;

    if q.EOF then
      raise EgdcIBError.Create('Invalid field source')
    else
      FSK := GetTID(q.Fields[0]);
    q.Close;

    q.SQL.Text :=
      'INSERT INTO at_relation_fields ' +
      '  (relationname, relationkey, fieldname, lname, fieldsource, fieldsourcekey, description, ' +
      '   lshortname, alignment, colwidth, readonly, visible, afull, achag, aview) ' +
      'VALUES ' +
      '  (:relationname, :relationkey, :fieldname, :lname, :fieldsource, :fieldsourcekey, :description, ' +
      '   :lshortname, :alignment, :colwidth, :readonly, :visible, :afull, :achag, :aview) ';
    q.ParamByName('relationname').AsString := FieldByName('relationname').AsString;
    SetTID(q.ParamByName('relationkey'), ID);
    q.ParamByName('fieldname').AsString := FieldName;
    q.ParamByName('lname').AsString := LName;
    q.ParamByName('fieldsource').AsString := FieldSource;
    SetTID(q.ParamByName('fieldsourcekey'), FSK);
    q.ParamByName('description').AsString := Description;
    q.ParamByName('lshortname').AsString := LShortName;
    q.ParamByName('alignment').AsString := Alignment;
    q.ParamByName('colwidth').AsString := ColWidth;
    q.ParamByName('readonly').AsString := ReadOnly;
    q.ParamByName('visible').AsString := Visible;
    q.ParamByName('afull').AsString := '-1';
    q.ParamByName('achag').AsString := '-1';
    q.ParamByName('aview').AsString := '-1';
    q.ExecQuery;

    if DidActivate then
      Transaction.Commit;
  finally
    q.Free;
  end;
end;

procedure TGDCBASETABLE._DoOnNewRecord;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
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

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASETABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASETABLE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TGDCBASETABLE.GetTableType: TgdcTableType;
begin
  if not (State in [dsInsert]) then
    Result := GetTableTypeByName(FieldByName('relationname').AsString)
  else if Self.ClassType = TgdcSimpleTable then
    Result := ttSimpleTable
  else if Self.ClassType = TgdcTreeTable then
    Result := ttTree
  else if Self.ClassType = TgdcLBRBTreeTable then
    Result := ttIntervalTree
  else if Self.ClassType = TgdcPrimeTable then
    result := ttPrimeTable
  else
    Result := ttUnknow;
end;

procedure TGDCBASETABLE.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add(' z.relationtype = ''T'' ');
end;

class function TGDCBASETABLE.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmTable';
end;

{ TgdcView }

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
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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
  Result := ttUnknow;
end;

class function TgdcView.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmRelation';
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

  inherited;

  if IsUserDefined then
    MakePredefinedObjects;

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
  if (StrIPos('CREATE OR ALTER VIEW', Source) > 0) or (StrIPos('CREATE VIEW', Source) > 0) then
    Result := Source
  else begin
    S := TStringList.Create;
    try
      GetFieldsName(Source, S);
      if S.Count = 0 then
        raise EgdcIBError.Create('Ошибка при создании представления: количество полей равно нулю!');
      Result := 'CREATE OR ALTER VIEW ' + FieldByName('relationname').AsString + #13#10;
      if S[0] <> '*' then
      begin
        Result := Result + '  ('#13#10;
        for i := 0 to S.Count - 1 do
        begin
          Result := Result + '    ' + S[i];
          if i < S.Count - 1 then
            Result := Result + ','#13#10;
        end;
        Result := Result + '  )'#13#10;
      end;
      Result := Result + 'AS'#13#10 + Source;
    finally
      S.Free;
    end;
  end;
end;

function TgdcView.GetAlterViewTextBySource(const Source: String): String;
begin
  if (StrIPos('CREATE OR ALTER VIEW', Source) > 0) or (StrIPos('ALTER VIEW', Source) > 0) then
    Result := Source
  else
    Result := GetViewTextBySource(Source);
end;

class function TgdcView.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_attr_dlgView';
end;

procedure TgdcView.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
begin
  case AMetadata of
    mdsCreate:
      S.Add(GetViewTextBySource(FieldByName('view_source').AsString));

    mdsAlter:
    begin
      S.Add(GetAlterViewTextBySource(FieldByName('view_source').AsString));
      S.Add('DELETE FROM at_relation_fields WHERE relationkey = ' + TID2S(ID));
    end;

    mdsDrop:
    begin
      S.Add('DROP VIEW ' + FieldByName('relationname').AsString);
      S.Add('DELETE FROM GD_COMMAND WHERE classname = ''TgdcAttrUserDefined'' AND ' +
        ' UPPER(SubType) = ''' + UpperCase(FieldByName('relationname').AsString) + '''');
    end;
  end;

  inherited;
end;

procedure TgdcView.MakePredefinedObjects;
var
  q: TIBSQL;
  gdcViewField: TgdcRelationField;
  DidActivate: Boolean;
begin
  inherited;

  DidActivate := False;
  gdcViewField := TgdcViewField.Create(nil);
  q := TIBSQL.Create(nil);
  try
    DidActivate := ActivateTransaction;

    gdcViewField.Transaction := Self.Transaction;
    gdcViewField.ReadTransaction := Self.ReadTransaction;
    gdcViewField.Open;

    q.Transaction := Transaction;
    q.SQL.Text :=
      'SELECT * FROM rdb$relation_fields WHERE rdb$relation_name = :relname';
    q.ParamByName('relname').AsString := FieldByName('relationname').AsString;
    q.ExecQuery;

    while not q.EOF do
    begin
      gdcViewField.Insert;
      try
        SetTID(gdcViewField.FieldByName('relationkey'), ID);
        gdcViewField.FieldByName('relationname').AsString := q.FieldByName('rdb$relation_name').AsTrimString;
        gdcViewField.FieldByName('fieldname').AsString := q.FieldByName('rdb$field_name').AsTrimString;
        gdcViewField.FieldByName('fieldsource').AsString := q.FieldByName('rdb$field_source').AsTrimString;
        gdcViewField.FieldByName('lname').AsString := q.FieldByName('rdb$field_name').AsTrimString;
        gdcViewField.FieldByName('lshortname').AsString := q.FieldByName('rdb$field_name').AsTrimString;
        gdcViewField.Post;
      except
        gdcViewField.Cancel;
        raise;
      end;
      q.Next;
    end;
  finally
    q.Free;
    gdcViewField.Free;
    if DidActivate and Transaction.InTransaction then
      Transaction.Commit;
  end;
end;

{ TgdcRelationField }

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
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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
  if HasSubSet('ByRelation') then
    S.Add('z.relationkey = :relationkey ');
  if HasSubSet('ByFieldName') then
    S.Add('z.fieldname = :fieldname ');
  if HasSubSet('ByRelationName') then
    S.Add('z.relationname = :relationname ');
end;

function TgdcTableField.CreateCrossRelationSQL: String;
var
  S1, S2: String;
begin
  S1 := FieldByName('relationname').AsString;
  S2 := FieldByName('refcrossrelation').AsString;

  if StrIPos(UserPrefix, S1) <> 1 then
    S1 := UserPrefix + S1;

  if StrIPos(UserPrefix, S2) <> 1 then
    S2 := UserPrefix + S2;

  if S1 = S2 then
    S2 := S2 + '_r';

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
      gdcBaseManager.AdjustMetaName(FieldByName('crosstable').AsString + '_PK'),
      gdcBaseManager.AdjustMetaName(FieldByName('crosstable').AsString + '_FK_1'),
      gdcBaseManager.AdjustMetaName(FieldByName('crosstable').AsString + '_FK_2')
    ]
  );
end;

function TgdcTableField.CreateCrossRelationTriggerSQL: String;
var
  S1, S2: String;
  TriggerPos: String;
begin
  if FieldByName('stringlength').AsInteger < 1 then
  begin
    Result := '';
    exit;
  end;

  S1 := FieldByName('relationname').AsString;
  S2 := FieldByName('refcrossrelation').AsString;

  if StrIPos(UserPrefix, S1) <> 1 then
    S1 := UserPrefix + S1;

  if StrIPos(UserPrefix, S2) <> 1 then
    S2 := UserPrefix + S2;

  if S1 = S2 then
    S2 := S2 + '_r';

  TriggerPos := System.Copy(FieldByName('crosstable').AsString, Length(CrossTablePrefix) + 1,
    AnsiPos('_', FieldByName('crosstable').AsString) - (1 + Length(CrossTablePrefix)));
  Result := Format
  (
    'CREATE OR ALTER TRIGGER %11:s FOR %0:s' + #13#10 +
    '  BEFORE UPDATE ' + #13#10 +
    '  POSITION %1:s ' + #13#10 +
    'AS ' + #13#10 +
    '  DECLARE VARIABLE attr VARCHAR(8192); ' + #13#10 +
    '  DECLARE VARIABLE text VARCHAR(8192) = ''''; ' + #13#10 +
    'BEGIN '+ #13#10 +
    '  FOR '+ #13#10 +
    '    SELECT L.%10:s ' + #13#10 +
    '      FROM ' + #13#10 +
    '        %2:s C JOIN %3:s L ON C.%5:s = L.%6:s ' + #13#10 +
    '      WHERE C.%4:s = NEW.%9:s AND L.%10:s > '''' ' + #13#10 +
    '      INTO :attr ' + #13#10 +
    '  DO ' + #13#10 +
    '  BEGIN ' + #13#10 +
    '    IF (CHARACTER_LENGTH(:text) > %7:s) THEN ' + #13#10 +
    '      LEAVE; ' + #13#10 +
    '    text = :text || SUBSTRING(:attr FROM 1 FOR 254) || '' ''; ' + #13#10 +
    '  END ' + #13#10 +
    '  NEW.%8:s = TRIM(SUBSTRING(:text FROM 1 FOR %7:s)); ' + #13#10 +
    'END',
    [
      FieldByName('relationname').AsString{0},
      //System.Copy(FCrossRelationID, 1, AnsiPos('_', FCrossRelationID) - 1){1},
      TriggerPos,
      FieldByName('crosstable').AsString{2},
      FieldByName('refcrossrelation').AsString{3},
      gdcBaseManager.AdjustMetaName(S1 + 'key'){4},
      gdcBaseManager.AdjustMetaName(S2 + 'key'){5},
      GetKeyFieldName(FieldByName('refcrossrelation').AsString){6},
      //Если пустая строка, то вернет ноль
      IntToStr(FieldByName('stringlength').AsInteger){7},
      FieldByName('fieldname').AsString{8},
      GetKeyFieldName(FieldByName('relationname').AsString){9},
      FieldByName('setlistfield').AsString {10},
      gdcBaseManager.AdjustMetaName('usr$bi_' + FieldByName('crosstable').AsString)
    ]
  );
end;

procedure TgdcTableField.CreateInvCardTrigger(ResultList: TSQLProcessList;
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
  if AnsiSameText(FieldByName('relationname').AsString, 'INV_CARD') then
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
        raise EgdcIBError.Create('Gedemin не поддерживает более ' +
          IntToStr(50 * MaxInvCardTrigger) + ' пользовательских полей в inv_card!');

      ibsqlR.Close;
      ibsqlR.SQL.Text :=
        'SELECT * FROM at_relation_fields WHERE relationname = ''INV_CARD'' ORDER BY fieldname';
      ibsqlR.ExecQuery;
      if not ibsqlR.EOF then
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
            //В нормальном режиме (когда не нужно переподключаться) эти флаги должны быть Ложь
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
          //мы будем обновлять триггер только в том случае, если он уже есть в базе
          // и не установлен флаг "Триггер удален"
          isAlter := (not ibsql.EOF) and (not InvCardTriggerDrop[I]);
          Result := 'CREATE OR ALTER TRIGGER ' + InvTriggerName + ' FOR INV_CARD '#13#10;
          if atDatabase.InMultiConnection then
          begin
            //если мы в режиме переподключения, проверим, существует ли уже этот триггер в системной таблице
            //если триггера нет, то съимитируем его создание, через нашу таблицу
            //и установим флаг имитации триггера
            ibsql.Close;
            ibsql.SQL.Text := ' SELECT CAST(triggername AS VARCHAR(31)) FROM at_triggers att  ' +
              ' WHERE att.triggername = ''' + InvTriggerName + '''';
            ibsql.ExecQuery;
            if ibsql.RecordCount = 0 then
            begin
              //если мы в режиме переподключения, то имитируем создание триггера
              ibsql.Close;
              ibsql.SQL.Text := 'INSERT INTO at_triggers(triggername, relationname, relationkey)' +
                'VALUES (''' + InvTriggerName + ''', ''INV_CARD'', ' +
                ibsqlR.FieldByName('relationkey').AsString + ')';
              ibsql.ExecQuery;
              InvCardTriggerImitate[I] := True;
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
              //Если флаг "Триггер удален" не установлен, то удаляем триггер
              if (not InvCardTriggerDrop[I]) and IsAlter  then
              begin
                Result := 'DROP TRIGGER ' + InvTriggerName;
                //Если мы в режиме переподключения
                //устанавливаем флаг "Триггер удален" в Истина
                InvCardTriggerDrop[I] := atDatabase.InMultiConnection;
              end else
                Result := '';
              //Сбрасываем флаг имитации триггера
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

procedure TgdcTableField.AlterAcEntryBalanceAndRecreateTrigger(ResultList: TSQLProcessList;
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
    DidActivate := False;
    try
      DidActivate := ActivateTransaction;
      // Если поле создается, то сначала создадим его, а потом изменим триггер
      //  Если удаляется, то наоборот, сначала триггер - потом поле
      if not IsDrop then
      begin
        // Добавляем идентичное поле в AC_ENTRY_BALANCE
        gdcField := TgdcField.Create(nil);
        try
          // Получим текст домена
          gdcField.Transaction := Transaction;
          gdcField.SubSet := 'ByFieldName';
          gdcField.ParamByName('fieldname').AsString := Trim(FieldByName('fieldsource').AsString);
          gdcField.Open;
          {if gdcField.EOF then
            AddWarning('Unknown domain ' + FieldByName('fieldsource').AsString);}
          // Добавим поле в ac_entry_balance
          AcEntryBalanceStr := Format('ALTER TABLE ac_entry_balance ADD %s %s',
            [FieldByName('fieldname').AsString, gdcField.GetDomainText(False, True)]);
          ResultList.Add(AcEntryBalanceStr);
        finally
          FreeAndNil(gdcField);
        end;
      end;

      // Получим список полей ac_entry
      ibsqlR := TIBSQL.Create(nil);
      try
        ibsqlR.Transaction := Transaction;
        ibsqlR.SQL.Text :=
          'SELECT fieldname, fieldsource FROM at_relation_fields f WHERE relationname = ''AC_ENTRY'' AND fieldname STARTING WITH ''USR$''';
        ibsqlR.ExecQuery;

        ACFieldList := '';
        NewFieldList := '';
        OLDFieldList := '';
        while not ibsqlR.Eof do
        begin
          // Если поле удаляется, то не включаем его в пересоздаваемый триггер
          if not isDrop or
            (IsDrop and (ANSICompareText(ibsqlR.FieldByName('fieldname').AsString, FieldByName('fieldname').AsString) <> 0)) then
          begin
            ACFieldList := ACFieldList + ', '#13#10 + Trim(ibsqlR.FieldByName('FIELDNAME').AsString);
            NEWFieldList := NEWFieldList + ', '#13#10'NEW.' + Trim(ibsqlR.FieldByName('FIELDNAME').AsString);
            OLDFieldList := OLDFieldList + ', '#13#10'OLD.' + Trim(ibsqlR.FieldByName('FIELDNAME').AsString);
          end;

          ibsqlR.Next;
        end;

        // Если поле создается
        if not IsDrop then
        begin
          ACFieldList := ACFieldList + ', '#13#10 + Trim(FieldByName('fieldname').AsString);
          NEWFieldList := NEWFieldList + ', '#13#10'NEW.' + Trim(FieldByName('fieldname').AsString);
          OLDFieldList := OLDFieldList + ', '#13#10'OLD.' + Trim(FieldByName('fieldname').AsString);
        end;

        // Текст пересоздаваемого триггера
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
          '         creditncu, creditcurr, crediteq' +
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
          '      NEW.crediteq' +
            NEWFieldList + '); '#13#10 +
          '    END '#13#10 +
          '    ELSE '#13#10 +
          '    IF (UPDATING AND ((OLD.entrydate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0))) THEN '#13#10 +
          '    BEGIN '#13#10 +
          '      INSERT INTO AC_ENTRY_BALANCE '#13#10 +
          '        (companykey, accountkey, currkey, '#13#10 +
          '         debitncu, debitcurr, debiteq, '#13#10 +
          '         creditncu, creditcurr, crediteq' +
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
          '         -OLD.crediteq' +
            OLDFieldList + '); '#13#10 +
          '      IF ((NEW.entrydate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0)) THEN '#13#10 +
          '        INSERT INTO AC_ENTRY_BALANCE '#13#10 +
          '          (companykey, accountkey, currkey, '#13#10 +
          '           debitncu, debitcurr, debiteq, '#13#10 +
          '           creditncu, creditcurr, crediteq' +
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
          '            NEW.crediteq' +
            NEWFieldList + '); '#13#10 +
          '    END '#13#10 +
          '    ELSE '#13#10 +
          '    IF (DELETING AND ((OLD.entrydate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0))) THEN '#13#10 +
          '    BEGIN '#13#10 +
          '      INSERT INTO AC_ENTRY_BALANCE '#13#10 +
          '        (companykey, accountkey, currkey, '#13#10 +
          '         debitncu, debitcurr, debiteq, '#13#10 +
          '         creditncu, creditcurr, crediteq' +
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
          '        -OLD.crediteq' +
            OLDFieldList + '); '#13#10 +
          '    END '#13#10 +
          '  END '#13#10 +
          ' END ';
        // Пересоздадим триггер на AC_ENTRY
        ResultList.Add(ACTriggerText);
      finally
        ibsqlR.Free;
      end;

      // Если поле удаляется
      if IsDrop then
      begin
        // Удаляем поле в AC_ENTRY_BALANCE
        AcEntryBalanceStr := Format('ALTER TABLE ac_entry_balance DROP %s', [FieldByName('fieldname').AsString]);
        ResultList.Add(AcEntryBalanceStr);
      end;
    finally
      if DidActivate and Transaction.InTransaction then
        Transaction.Commit;
    end;
  end;
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
      raise EgdcIBError.Create('Ссылка может быть установлена только на единичный ключ!')
    else
      Result := Keys.ConstraintFields[0].FieldName;
  end else
  begin
    TblType := GetTableTypeByName(ARelationName);
    case TblType of
      ttDocument, ttDocumentLine, ttInvSimple,
      ttInvFeature, ttInvInvent, ttInvTransfrom: Result := 'DOCUMENTKEY';
      ttInheritedTable: Result := 'INHERITEDKEY';
      else Result := 'ID';
    end;
  end;
end;

//Заключает значение по умолчанию в кавычки
//При этом идет проверка: если значение уже в кавычках, то оно так и возвращается
//в обратном случае, если кавычка встречается внутри текста, то она удваивается
function GetDefValueInQuotes(const DefaultValue: String): String;
var
  L: Tcst_def_KeyWords;
begin
  Result := Trim(DefaultValue);

  if StrIPos('DEFAULT', Result) = 1 then
    Result := Trim(System.Copy(Result, 8, 32000));

  for L := Low(cst_def_KeyWords) to High(cst_def_KeyWords) do
  begin
    if AnsiSameText(Result, cst_def_KeyWords[L]) then
      exit;
  end;

  if StrToIntDef(Result, 0) <> StrToIntDef(Result, -1) then
  begin
    if not ((Result > '') and (Result[1] = '''') and (Result[Length(Result)] = '''')) then
      Result := '''' + StringReplace(Result, '''', '''''', [rfReplaceAll]) + '''';
  end;    
end;

function GetTableTypeByName(const ARelationName: String): TgdcTableType;
var
  R: TatRelation;
  RF: TatRelationField;
  BE: TgdBaseEntry;
begin
  R := atDatabase.Relations.ByRelationName(ARelationName);
  if R = nil then
    raise EgdcIBError.Create('В объекте atDatabase не найдена таблица ' + ARelationName);

  Result := ttUnknow;

  if not R.IsUserDefined then
    exit;

  if R.RelationFields.ByFieldName('INHERITEDKEY') <> nil then
    Result := ttInheritedTable
  else if R.IsLBRBTreeRelation then
    Result := ttIntervalTree
  else if R.IsStandartTreeRelation then
    Result := ttTree
  else if R.RelationFields.ByFieldName('TOCARDKEY') <> nil then
    Result := ttInvFeature
  else if R.RelationFields.ByFieldName('TOQUANTITY') <> nil then
    Result := ttInvInvent
  else if R.RelationFields.ByFieldName('OUTQUANTITY') <> nil then
    Result := ttInvTransfrom
  else if R.RelationFields.ByFieldName('FROMCARDKEY') <> nil then
    Result := ttInvSimple
  else if R.RelationFields.ByFieldName('MASTERKEY') <> nil then
    Result := ttDocumentLine
  else if R.RelationFields.ByFieldName('DOCUMENTKEY') <> nil then
  begin
    BE := gdClassList.FindByRelation(ARelationName);
    if (BE is TgdDocumentEntry) and (BE.Parent is TgdDocumentEntry)
      and (TgdDocumentEntry(BE.Parent).SubType > '') then
      Result := ttInheritedDocumentTable
    else
      Result := ttDocument;
  end else begin
    RF := R.RelationFields.ByFieldName('ID');
    if RF <> nil then
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
  q: TIBSQL;
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

  //Поле defsource у нас BLOB, редактируется обычно в мемо.
  //Чтобы не попали лишние символы типа #13#10
  FieldByName('defsource').AsString := Trim(FieldByName('defsource').AsString);

  //мы не знаем id cross таблицы(для старых настроек)
  if  (sLoadFromStream in BaseState) and (FieldByName('crosstable').AsString > '') then
    FieldByName('crosstablekey').AsString := '';

  if not (sMultiple in BaseState) then
  begin
    q := CreateReadIBSQL;
    try
      if not FieldByName('computed_value').IsNull then
      begin
        FieldByName('refrelationname').Clear;
        FieldByName('refcrossrelation').Clear;
      end;

      if FieldByName('fieldsourcekey').IsNull and
        (FieldByName('fieldsource').AsString > '') then
      begin
        q.Close;
        q.SQL.Text := 'SELECT id FROM at_fields WHERE fieldname = :fieldname';
        q.ParamByName('fieldname').AsString := FieldByName('fieldsource').AsString;
        q.ExecQuery;
        if not q.EOF then
          SetTID(FieldByName('fieldsourcekey'), q.FieldByName('id'))
        else if StrIPos('RDB$', FieldByName('fieldsource').AsString) = 1 then
        begin
          Field := TgdcField.Create(nil);
          try
            Field.Transaction := Transaction;
            Field.ReadTransaction := ReadTransaction;
            Field.Open;
            Field.Insert;
            Field.FieldByName('fieldname').AsString := FieldByName('fieldsource').AsString;
            Field.FieldByName('lname').AsString := FieldByName('fieldsource').AsString;
            Field.FieldByName('description').AsString := FieldByName('fieldsource').AsString;
            Field.Post;
            SetTID(FieldByName('fieldsourcekey'), Field.ID);
          finally
            Field.Free;
          end;
        end;
      end;

      if (FieldByName('relationname').AsString > '') and
        FieldByName('relationkey').IsNull then
      begin
        q.Close;
        q.SQL.Text := 'SELECT * FROM at_relations WHERE relationname = :RN';
        q.ParamByName('RN').AsString := AnsiUpperCase(Trim(FieldByName('relationname').AsString));
        q.ExecQuery;
        if not q.EOF then
          SetTID(FieldByName('relationkey'), q.FieldByName('id'));
      end;

      if (Trim(FieldByName('relationname').AsString) = '') and
        (GetTID(FieldByName('relationkey')) > -1) then
      begin
        q.Close;
        q.SQL.Text := 'SELECT * FROM at_relations WHERE id = :id';
        SetTID(q.ParamByName('id'), FieldByName('relationkey'));
        q.ExecQuery;
        if not q.EOF then
          FieldByName('relationname').AsString := q.FieldByName('relationname').AsString;
      end;

      if  not (sLoadFromStream in BaseState) then
      begin
        //Считывание настроек из домена
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
            Field.Transaction := Transaction;
            Field.ReadTransaction := ReadTransaction;
            Field.SubSet := 'ByID';
            Field.ID := GetTID(FieldByName('fieldsourcekey'));
            Field.Open;
            if not Field.EOF then
            begin
              FieldByName('refrelationname').AsString := Field.FieldByName('reftable').AsString;
              FieldByName('refcrossrelation').AsString := Field.FieldByName('settable').AsString;
              FieldByName('setlistfield').AsString := Field.FieldByName('setlistfield').AsString;
              FieldByName('stringlength').AsString := Field.FieldByName('fcharlength').AsString;
              if Field.FieldByName('flag').AsInteger > 0 then
              begin
                if Field.FieldByName('flag').IsNull then
                  FieldByName('nullflag').Clear
                else
                  FieldByName('nullflag').AsInteger := Field.FieldByName('flag').AsInteger;
              end;

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

        {Установка связей с кросс-таблицами}
        if (State = dsEdit) and (FieldByName('crosstable').AsString > '')
          and FieldByName('crosstablekey').IsNull then
        begin
          q.Close;
          q.SQL.Text := 'SELECT id FROM at_relations WHERE relationname = :relationname';
          q.ParamByName('relationname').AsString := FieldByName('crosstable').AsString;
          q.ExecQuery;
          if not q.EOF then
            FieldByName('crosstablekey').AsString := q.FieldByName('id').AsString;
        end;

        if (FieldByName('refcrossrelation').AsString > '') and (State = dsInsert) then
        begin
          FieldByName('crosstable').AsString :=
            'USR$CROSS' + GetUniqueID(Database, ReadTransaction) + '_' + IntToStr(IBLogin.DBID);
          FieldByName('crossfieldkey').AsString := FieldByName('setlistfieldkey').AsString;
          FieldByName('crossfield').AsString := FieldByName('setlistfield').AsString;
        end;

        if FieldByName('lname').AsString = '' then
          FieldByName('lname').AsString := FieldByName('fieldname').AsString;

        if FieldByName('lshortname').AsString = '' then
          FieldByName('lshortname').AsString := System.Copy(FieldByName('lname').AsString, 1,
            FieldByName('lshortname').Size);
      end;
    finally
      q.Free;
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
  {M}                raise Exception.Create('Для метода ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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

  if State = dsInactive then
    Result :=
      'SELECT id FROM at_relation_fields ' +
      'WHERE UPPER(relationname)=UPPER(:relationname) AND UPPER(fieldname) = UPPER(:fieldname)'
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format(
      'SELECT id FROM at_relation_fields ' +
      'WHERE UPPER(relationname)=UPPER(''%s'') AND UPPER(fieldname) = UPPER(''%s'') ',
      [FieldByName('relationname').AsString, FieldByName('fieldname').AsString]);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATIONFIELD', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATIONFIELD', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
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
  {M}                raise Exception.Create('Для метода ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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
    Result := ' ORDER BY rf.rdb$field_position '
  else
    Result := inherited GetOrderClause;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRELATIONFIELD', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRELATIONFIELD', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcRelationField.GetCurrRecordClass: TgdcFullClass;
begin
  Result.gdClass := CgdcBase(Self.ClassType);
  Result.SubType := SubType;

  if not IsEmpty then
  begin
    if FieldByName('relationtype').AsString = 'T' then
      Result.gdClass := TgdcTableField
    else if FieldByName('relationtype').AsString = 'V' then
      Result.gdClass := TgdcViewField;
  end;

  FindInheritedSubType(Result);
end;

function TgdcTableField.CreateAccCirculationList(const IsDrop: Boolean = False): String;
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
      ibsqlR.SQL.Text :=
        'SELECT * FROM at_relation_fields f ' +
        'WHERE relationname = ''AC_ENTRY'' AND fieldname LIKE ''USR$%'' ' +
        'ORDER BY fieldname';
      ibsqlR.ExecQuery;
      Result :=
        'ALTER PROCEDURE AC_ACCOUNTEXSALDO '#13#10 +
        '  (DATEEND DATE, '#13#10 +
        '   ACCOUNTKEY TYPE OF DINTKEY, '#13#10 +
        '   FIELDNAME VARCHAR(60), '#13#10 +
        '   COMPANYKEY TYPE OF DINTKEY, '#13#10 +
        '   ALLHOLDINGCOMPANIES INTEGER,'#13#10 +
        '   INGROUP INTEGER,'#13#10 +
        '   CURRKEY TYPE OF DINTKEY)'#13#10 +
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

class function TgdcRelationField.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgRelationField';
end;

function TgdcRelationField.GetObjectName: String;
begin
  if Active then
  begin
    if (FieldByName('lname').AsString > '') and
      (FieldByName('lname').AsString  <> FieldByName('fieldname').AsString) then
    begin
      Result := FieldByName('lname').AsString + ', ' +
        FieldByName('relationname').AsString + '.' +
        FieldByName('fieldname').AsString
    end else
      Result :=
        FieldByName('relationname').AsString + '.' +
        FieldByName('fieldname').AsString;
  end else
    Result := inherited GetObjectName;
end;

class function TgdcRelationField.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_attr_frmRelationField';
end;

function TgdcRelationField.GetFirebirdObjectNameField: String;
begin
  Result := 'fieldname';
end;

procedure TgdcTableField.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
var
  DefClause, NullClause, CompClause: String;
  NextConstraintName: String;
  TableNameWithoutPrefix: String;
  DeleteRule: String;
  RF: TatRelationField;
  TN: String;
  Res: OleVariant;
  q: TIBSQL;
  T1, T2: Integer;
begin
  inherited;

  case AMetadata of

    mdsCreate:
    begin
      if FieldByName('computed_value').IsNull then
      begin
        if FieldByName('defsource').IsNull then
          DefClause := ''
        else
          DefClause := 'DEFAULT ' + GetDefValueInQuotes(FieldByName('defsource').AsString);

        if FieldByName('nullflag').AsInteger <> 0 then
          NullClause := 'NOT NULL'
        else
          NullClause := '';

        S.Add(Format
          (
            'ALTER TABLE %s ADD %s %s %s %s',
            [FieldByName('relationname').AsString, FieldByName('fieldname').AsString,
            FieldByName('fieldsource').AsString, DefClause, NullClause]
          )
        );

        if FieldByName('refrelationname').AsString > '' then
        begin
          //проверяем совпадает ли домен//

          q := TIBSQL.Create(nil);
          try
            if Transaction.InTransaction then
              q.Transaction := Transaction
            else
              q.Transaction := ReadTransaction;

            q.SQL.Text := Format
              (
                'SELECT COUNT(*) FROM at_relation_fields z ' +
                'LEFT OUTER JOIN at_fields f ON z.fieldsourcekey = f.id ' +
                'WHERE f.fieldname = ''%s'' ', [FieldByName('fieldsource').AsString]
              );

            q.ExecQuery;

            if q.Fields[0].AsInteger = 0 then
            begin
              q.Close;

              q.SQL.Text := Format
              (
                'SELECT f.rdb$field_type FROM rdb$relation_fields rf ' +
                'JOIN rdb$fields f ON rf.rdb$field_source = f.rdb$field_name ' +
                'WHERE rf.rdb$relation_name = ''%s'' and rf.rdb$field_name = ''%s'' ' ,
                [FieldByName('RefRelationName').AsString, GetKeyFieldName(FieldByName('RefRelationName').AsString)]
              );
              q.ExecQuery;
              T1 := q.Fields[0].AsInteger;

              q.Close;
              q.SQL.Text := Format
              (
                'SELECT f.rdb$field_type FROM rdb$fields f ' +
                'WHERE f.rdb$field_name = ''%s'' ' ,
                [FieldByName('fieldsource').AsString]
              );
              q.ExecQuery;
              T2 := q.Fields[0].AsInteger;
              q.Close;

              if T1 <> T2 then
              begin
                if T1 = 16 then
                  S.Add(Format('ALTER DOMAIN %s TYPE BIGINT', [FieldByName('fieldsource').AsString]));

                if T1 = 8 then
                  S.Add(Format('ALTER DOMAIN %s TYPE INTEGER', [FieldByName('fieldsource').AsString]));
              end;
            end;

          finally
            q.Free;
          end;

          if StrIPos(UserPrefix, FieldByName('relationname').AsString) = 1 then
            TableNameWithoutPrefix := System.Copy(FieldByName('relationname').AsString, Length(UserPrefix) + 1, 1024)
          else
            TableNameWithoutPrefix := FieldByName('relationname').AsString;

          NextConstraintName := gdcBaseManager.AdjustMetaName(Format(UserPrefix + 'FK_%s_%s',
            [TableNameWithoutPrefix, FieldByName('fieldname').AsString]));

          DeleteRule := UpperCase(Trim(FieldByName('deleterule').AsString));

          if (DeleteRule = 'CASCADE') or (DeleteRule = 'SET DEFAULT') or (DeleteRule = 'SET NULL') then
            DeleteRule := 'ON DELETE ' + DeleteRule
          else
            DeleteRule := '';

          S.Add(Format
            (
              ' ALTER TABLE %s ADD CONSTRAINT %s FOREIGN KEY (%s) REFERENCES %s (%s) ON UPDATE CASCADE %s',
              [
                FieldByName('relationname').AsString,
                NextConstraintName,
                FieldByName('fieldname').AsString,
                FieldByName('RefRelationName').AsString,
                GetKeyFieldName(FieldByName('RefRelationName').AsString),
                DeleteRule
              ]
            ));
        end else
        if FieldByName('refcrossrelation').AsString > '' then
        begin
          S.Add(CreateCrossRelationSQL);
          S.Add(CreateCrossRelationTriggerSQL);
          S.Add('GRANT ALL ON ' + FieldByName('crosstable').AsString + ' TO administrator ');
        end;

        CreateInvCardTrigger(S);

        // Добавить поле в таблицу AC_ENTRY_BALANCE и пересоздать триггер синхронизации ее данных и данных AC_ENTRY
        AlterAcEntryBalanceAndRecreateTrigger(S);

        S.Add(CreateAccCirculationList);
      end else
      begin
        CompClause := Trim(FieldByName('computed_value').AsString);
        while (Length(CompClause) > 0) and (CompClause[1] = '(') and (CompClause[Length(CompClause)] = ')') do
          CompClause := System.Copy(CompClause, 2, Length(CompClause) - 2);
        S.Add(Format
        (
          'ALTER TABLE %s ADD %s COMPUTED BY (%s)',
          [FieldByName('relationname').AsString, FieldByName('fieldname').AsString,
          CompClause]
        ));
      end;

      if (sLoadFromStream in BaseState) and Self.IsUserDefined
        and (not FieldByName('rdb$field_position').IsNull) then
      begin
        S.Add(Format('ALTER TABLE %2:s ALTER COLUMN %1:s POSITION %0:d ',
          [FieldByName('rdb$field_position').AsInteger + 1,
           FieldByName('fieldname').AsString,
           FieldByName('relationname').AsString]));
      end;
    end;

    mdsDrop:
    begin
      if FieldByName('refrelationname').AsString <> '' then
      begin
        RF := atDatabase.FindRelationField(FieldByName('relationname').AsString,
          FieldByName('fieldname').AsString);
        if (RF <> nil) and (RF.ForeignKey <> nil) then
          S.Add(Format
          (
            'ALTER TABLE %s DROP CONSTRAINT %s',
            [
              RF.Relation.RelationName,
              RF.ForeignKey.ConstraintName
            ]
          ));
      end
      else if FieldByName('crosstable').AsString <> '' then
      begin
        TN := UpperCase(gdcBaseManager.AdjustMetaName('USR$BI_' + FieldByName('crosstable').AsString));

        if ExecSingleQueryResult('SELECT rdb$trigger_name FROM rdb$triggers WHERE rdb$trigger_name = ''' + TN + '''', 0, Res) then
          S.Add('DROP TRIGGER ' + TN);

        S.Add('DROP TABLE ' + FieldByName('crosstable').AsString);
      end;

      if AnsiSameText(FieldByName('relationname').AsString, 'INV_CARD') then
        CreateInvCardTrigger(S, True);

      if AnsiSameText(FieldByName('relationname').AsString, 'AC_ENTRY') then
      begin
        S.Add(CreateAccCirculationList(True));
        // Пересоздать триггер синхронизации ее данных и данных AC_ENTRY, удалить поле из AC_ENTRY_BALANCE
        AlterAcEntryBalanceAndRecreateTrigger(S, True);
      end;

      S.Add('ALTER TABLE ' + FieldByName('relationname').AsString + ' DROP ' + FieldByName('fieldname').AsString);
    end;

    mdsAlter:
    begin
      if not FieldByName('computed_value').IsNull then
      begin
        CompClause := Trim(FieldByName('computed_value').AsString);
        while (Length(CompClause) > 0) and (CompClause[1] = '(') and (CompClause[Length(CompClause)] = ')') do
          CompClause := System.Copy(CompClause, 2, Length(CompClause) - 2);
        S.Add(Format
        (
          'ALTER TABLE %s ALTER %s COMPUTED BY (%s)',
          [FieldByName('relationname').AsString, FieldByName('fieldname').AsString,
          CompClause]
        ));
      end;

      if (sLoadFromStream in BaseState) and (not FieldByName('rdb$field_position').IsNull) then
      begin
        S.Add(Format('ALTER TABLE %2:s ALTER COLUMN %1:s POSITION %0:d ',
          [FieldByName('rdb$field_position').AsInteger + 1,
           FieldByName('fieldname').AsString,
           FieldByName('relationname').AsString]));
      end;
    end;
  end;
end;

procedure TgdcTableField.MakePredefinedObjects;
var
  IsSetDefault: Boolean;
  FDefaultValue: String;
  L: Integer;
  FFieldType: Integer;
  R: OleVariant;
begin
  inherited;

  IsSetDefault := False;

  //Установка значения по умолчанию
  if (FieldByName('nullflag').AsInteger <> 0) or (not FieldByName('defsource').IsNull) then
  begin
    if FieldByName('defsource').IsNull then
      FDefaultValue := ''
    else begin
      FDefaultValue := Trim(FieldByName('defsource').AsString);
      if Pos('DEFAULT', FDefaultValue) = 1 then
        FDefaultValue := Trim(System.Copy(FDefaultValue, 8, 1024));
      L := System.Length(FDefaultValue);
      if (L > 0) and (FDefaultValue[1] = '''') then
        FDefaultValue := System.Copy(FDefaultValue, 2, L - 2);
    end;

    FFieldType := GetFieldType(GetTID(FieldByName('fieldsourcekey')));

    if (FFieldType in [blr_Text, blr_varying,
      blr_Text2, blr_varying2, blr_cstring, blr_cstring2]) then
    begin
      if System.Length(FDefaultValue) > FieldByName('stringlength').AsInteger then
        raise EgdcIBError.Create(Format('Длина значения по умолчанию превышает размер поля (%s)!',
          [FieldByName('stringlength').AsString]));
    end;

    //если это не загрузка из потока,
    //таблица не пустая и
    //пользователь хочет установить значение по умолчанию,
    //выводим диалог для ввода занчения по умолчанию
    if (not (sLoadFromStream in BaseState)) and (([sView, sDialog] * BaseState) <> []) then
    begin
      if
        gdcBaseManager.ExecSingleQueryResult(
          'SELECT RDB$RELATION_NAME FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = :RN',
           FieldByName('relationname').AsString, R)
        and
        gdcBaseManager.ExecSingleQueryResult(
          'SELECT FIRST 1 * FROM ' + FieldByName('relationname').AsString,
          '', R)
        and
        (MessageBox(0,
          PChar('Установить значение поля ' +
          FieldByName('fieldname').AsString +
          ' для существующих записей?'),
          'Установка значения',
          MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDYES) then
      begin
        repeat
          if not InputQuery('Значение', 'Введите значение для поля ' +
            FieldByName('fieldname').AsString, FDefaultValue) then
          begin
            MessageBox(0,
            PChar('Ввод значения для поля отменен.'),'Внимание',
            MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
            exit;
          end;
          FDefaultValue := Trim(FDefaultValue);
        until FDefaultValue <> '';

        if FFieldType in [blr_Text, blr_varying, blr_Text2, blr_varying2, blr_cstring, blr_cstring2] then
          FDefaultValue := System.Copy(FDefaultValue, 1, FieldByName('stringlength').AsInteger);
        IsSetDefault := True;
      end
    end else
      IsSetDefault := not FieldByName('defsource').IsNull;
  end;

  if IsSetDefault then
    ExecSingleQuery(Format(
      'UPDATE %s SET %s = %s WHERE %s IS NULL',
      [FieldByName('relationname').AsString, FieldByName('fieldname').AsString,
        GetDefValueInQuotes(FDefaultValue), FieldByName('fieldname').AsString]
    ));
end;

procedure TgdcTableField.SyncAtDatabase(const AnID: TID;
  const AMetadata: TgdcMetadataScript);
var
  R: TatRelation;
  F: TatRelationField;
begin
  inherited;

  case AMetadata of

    mdsCreate, mdsAlter:
    begin
      R := atDatabase.Relations.ByID(GetTID(FieldByName('relationkey')));
      if R <> nil then
      begin
        F := R.RelationFields.ByFieldName(FieldByName('fieldname').AsString);
        if not Assigned(F) then
          F := R.RelationFields.AddRelationField(FieldByName('fieldname').AsString);
        F.RefreshData(Database, Transaction);
        R.RefreshConstraints(Database, Transaction);
      end;
    end;

    mdsDrop:
    begin
      F := atDatabase.FindRelationField(AnID);

      if F <> nil then
        F.Relation.RelationFields.Delete(F.Relation.RelationFields.IndexOf(F));
    end;
  end;

  Clear_atSQLSetupCache;
end;

procedure TgdcTableField.SyncRDBObjects;
var
  Res: OleVariant;
begin
  inherited;

  if (FieldByName('crosstable').AsString > '') and
    FieldByName('crosstablekey').IsNull then
  begin
    SetTID(FieldByName('crosstablekey'), gdcBaseManager.GetNextID);
    ExecSingleQuery(Format(
      'INSERT INTO at_relations (id, relationname, relationtype, lname, ' +
      'lshortname, description, afull, achag, aview) VALUES' +
      '(%1:d, ''%0:s'', ''T'', ''%0:s'', ''%0:s'', ''%0:s'', -1, -1, -1)',
      [FieldByName('crosstable').AsString, TID264(FieldByName('crosstablekey'))]
    ));
  end;

  if FieldByName('fieldsourcekey').IsNull and FieldByName('fieldsource').IsNull then
  begin
    if ExecSingleQueryResult(Format(
      'SELECT rdb$field_source ' +
      'FROM rdb$relation_fields ' +
      'WHERE rdb$relation_name = ''%s'' AND rdb$field_name = ''%s'' ',
        [FieldByName('relationname').AsString, FieldByName('fieldname').AsString]), 0, Res) then
    begin
      FieldByName('fieldsource').AsString := Res[0, 0];
    end;

    SetTID(FieldByName('fieldsourcekey'), gdcBaseManager.GetNextID);
    ExecSingleQuery(Format(
      'INSERT INTO at_fields (id, fieldname, lname) VALUES (%d, ''%s'', ''%s'') ',
      [TID264(FieldByName('fieldsourcekey')),
       FieldByName('fieldsource').AsString, FieldByName('fieldsource').AsString]));
  end;
end;

{ TgdcTableField }

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

procedure TgdcTableField.CustomInsert(Buff: Pointer);
begin
  //не загружаем поля cross таблиц из потока(для старых настроек)
  if (not (sLoadFromStream in BaseState)) or
    (StrIPos(CrossTablePrefix, FieldByName('relationname').AsString) <> 1) then
  begin
    inherited;
  end;
end;

function TgdcTableField.GetIsDerivedObject: Boolean;
begin
  Result := (StrIPos('USR$', FieldByName('relationname').AsString) = 1)
    and (StrIPos('USR$', FieldByName('fieldname').AsString) <> 1);
end;

function TgdcTableField.CheckObjectName(const ARaiseException,
  AFocusControl: Boolean; const AFieldName: String): Boolean;
begin
  Result := inherited CheckObjectName(ARaiseException, AFocusControl, AFieldName);

  if not Result then
    exit;

  //Проверим на дублирование наименования поля
  if (State = dsInsert) and (atDatabase.FindRelationField(FieldbyName('relationname').AsString,
    FieldByName('fieldname').AsString) <> nil) then
  begin
    if AFocusControl then
      FieldByName('fieldname').FocusControl;
    if ARaiseException then
      raise EgdcIBError.Create('Название поля дублируется с уже существующим!')
    else begin
      Result := False;
      exit;
    end;
  end;

  //Если мы добавили невычисляемое поле и при этом не указали тип
  if (State = dsInsert) and FieldByName('computed_value').IsNull and
    FieldByName('fieldsourcekey').IsNull and FieldByName('fieldsource').IsNull then
  begin
    if AFocusControl then
      FieldByName('fieldsourcekey').FocusControl;
    if ARaiseException then
      raise EgdcIBError.Create('Выберите тип поля!')
    else begin
      Result := False;
      exit;
    end;
  end;
end;

{ TgdcViewField }

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

function TgdcStoredProc.GetProcedureText: String;
begin
  if (State = dsInsert) and (FieldByName('rdb$procedure_source').AsString = '') then
    Result :=
      'CREATE OR ALTER PROCEDURE ' + FieldByName('procedurename').AsString + #13#10 +
      '  (I INTEGER, D DATE, ...) '#13#10 +
      '  RETURNS'#13#10 +
      '  (N NUMERIC(15, 2), S VARCHAR(60), ...)'#13#10 +
      'AS'#13#10 +
      '  DECLARE VARIABLE V INTEGER = 0;'#13#10 +
      'BEGIN'#13#10 +
      '  --SUSPEND;'#13#10 +
      'END'
  else
    Result := Format('CREATE OR ALTER PROCEDURE %0:s ' + GetParamsText + ' AS'#13#10'%1:s',
      [FieldByName('procedurename').AsString,
       FieldByName('rdb$procedure_source').AsString]);
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
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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
  q: TIBSQl;
  S1, S2: String;
  gdcField: TgdcField;
  ProcedureName: String;
begin
  Result := '';
  q := CreateReadIBSQL;
  gdcField := TgdcField.Create(nil);
  try
    gdcField.Transaction := Transaction;
    gdcField.SubSet := 'ByFieldName';

    ProcedureName := Trim(FieldByName('procedurename').AsString);
    // Если мы находимся в состоянии копирования объекта, то параметры еще не создались,
    //  поэтому обращаемся к параметрам оригинальной процедуры
    if (sCopy in BaseState) and (CopiedObjectKey > -1) then
    begin
      q.SQL.Text :=
        'SELECT procedurename FROM at_procedures WHERE id = :id';
      SetTID(q.ParamByName('id'), CopiedObjectKey);
      q.ExecQuery;
      if not q.EOF then
        ProcedureName := q.FieldByName('procedurename').AsTrimString;
    end;

    q.Close;
    q.SQL.Text := 'SELECT * FROM rdb$procedure_parameters pr ' +
                      'WHERE pr.rdb$procedure_name = :pn AND pr.rdb$parameter_type = :pt ' +
                      'ORDER BY pr.rdb$parameter_number ASC ';
    q.ParamByName('pn').AsString := ProcedureName;
    q.ParamByName('pt').AsInteger := 0;
    q.ExecQuery;

    S1 := '';
    while not q.EOF do
    begin
      gdcField.ParamByName('fieldname').AsString := q.FieldByName('rdb$field_source').AsTrimString;
      gdcField.Open;
      if S1 = '' then
        S1 := '('#13#10;
      S1 := S1 + '    ' + q.FieldByName('rdb$parameter_name').AsTrimString + ' ';
      If StrIPos('RDB$', q.FieldByName('rdb$field_source').AsTrimString) = 1 then
        S1 := S1 + gdcField.GetDomainText(False, True)
      else
        S1 := S1 + q.FieldByName('rdb$field_source').AsTrimString;
      q.Next;
      if not q.EOF then
        S1 := S1 + ','#13#10
      else
        S1 := S1 + ')';
      gdcField.Close;
    end;

    S1 := S1 + #13#10;

    q.Close;
    q.ParamByName('pt').AsInteger := 1;

    q.ExecQuery;
    S2 := '';
    while not q.EOF do
    begin
      gdcField.ParamByName('fieldname').AsString := q.FieldByName('rdb$field_source').AsTrimString;
      gdcField.Open;
      if S2 = '' then
        S2 := 'RETURNS ( '#13#10;
      S2 := S2 + '    ' + q.FieldByName('rdb$parameter_name').AsTrimString + ' ';
      If StrIPos('RDB$', q.FieldByName('rdb$field_source').AsTrimString) = 1 then
        S2 := S2 + gdcField.GetDomainText(False, True)
      else
        S2 := S2 + q.FieldByName('rdb$field_source').AsTrimString;

      gdcField.Close;
      q.Next;
      if not q.EOF then
        S2 := S2 + ','#13#10
      else
        S2 := S2 + ')'#13#10;
    end;

    Result := S1 + S2;
  finally
    q.Free;
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
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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
  if HasSubSet('ByProcName') then
    S.Add('z.procedurename = :procedurename');
end;

procedure TgdcStoredProc.PrepareToSaveToStream(BeforeSave: Boolean);
var
  S: String;
begin
  if BeforeSave then
  begin
    FSkipMetadata := True;
    S := GetProcedureText;
    if FieldByName('proceduresource').AsString <> S then
    begin
      if State in [dsEdit, dsInsert] then
        FieldByName('proceduresource').AsString := S
      else
      begin
        Edit;
        FieldByName('proceduresource').AsString := S;
        Post;
      end;
    end;
  end else
    FSkipMetadata := False;
end;

procedure TgdcStoredProc._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet;
  PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True);
var
  S: String;
begin
  Assert(State = dsBrowse);

  if IsUserDefined then
    SaveToStreamDependencies(Stream, ObjectSet,
      FieldByName('procedurename').AsString, PropertyList, BindedList, WithDetailList, SaveDetailObjects);

  FSkipMetadata := True;
  try
    S := GetProcedureText;
    if FieldByName('proceduresource').AsString <> S then
    begin
      Edit;
      FieldByName('proceduresource').AsString := S;
      Post;
    end;
    inherited;
  finally
    FSkipMetadata := False;
  end;
end;

class function TgdcStoredProc.GetNotStreamSavedField(const IsReplicationMode: Boolean): String;
begin
  Result := inherited GetNotStreamSavedField(IsReplicationMode);
  if Result <> '' then
    Result := Result + ',RDB$PROCEDURE_BLR,RDB$PROCEDURE_SOURCE'
  else
    Result := 'RDB$PROCEDURE_BLR,RDB$PROCEDURE_SOURCE';
end;

class function TgdcStoredProc.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_attr_dlgStoredProc';
end;

procedure TgdcStoredProc.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
var
  C: String;
begin
  case AMetadata of
    mdsCreate, mdsAlter:
    begin
      if (sLoadFromStream in BaseState) then
        S.Add(StringReplace(FieldByName('proceduresource').AsString,
          'CREATE PROCEDURE', 'CREATE OR ALTER PROCEDURE', []))
      else if sCopy in BaseState then
        S.Add(GetProcedureText)
      else
        S.Add(FieldByName('rdb$procedure_source').AsString);

      S.Add('GRANT EXECUTE ON PROCEDURE ' + FieldByName('procedurename').AsString + ' TO administrator');

      C := 'COMMENT ON PROCEDURE ' + FieldByName('procedurename').AsString + ' IS ';
      if FieldByName('rdb$description').IsNull then
        S.Add(C + 'NULL')
      else
        S.Add(C + '''' +
          StringReplace(FieldByName('rdb$description').AsString, '''', '''''',
          [rfReplaceAll]) + '''');
    end;

    mdsDrop: S.Add('DROP PROCEDURE ' + FieldByName('procedurename').AsString);
  end;
end;

{ TgdcSimpleTable }

procedure TgdcSimpleTable.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
begin
  if AMetadata = mdsCreate then
  begin
    S.Add(
      'CREATE TABLE '+ FieldByName('relationname').AsString +
      '(id dintkey, disabled ddisabled, editiondate deditiondate, ' +
      'editorkey dintkey, PRIMARY KEY (id))'
    );
    S.Add(CreateEditorForeignKey);
    S.Add(CreateGenerator);
    S.Add(CreateInsertTrigger);
    S.Add(CreateInsertEditorTrigger(FieldByName('relationname').AsString));
    S.Add(CreateUpdateEditorTrigger(FieldByName('relationname').AsString));
  end;

  inherited;
end;

procedure TgdcSimpleTable.MakePredefinedObjects;
begin
  inherited;
  NewField('DISABLED',
    'Не активно', 'DDISABLED', 'Не активно', 'Не активно',
    'L', '10', '1', '0');
  NewField('EDITIONDATE',
    'Дата модификации', 'DEDITIONDATE', 'Дата модификации', 'Дата модификации',
    'L', '20', '1', '0');
  NewField('EDITORKEY',
    'Кто модифицировал', 'DINTKEY', 'Кто модифицировал', 'Кто модифицировал',
    'L', '20', '1', '0');
end;

{ TgdcTreeTable }

procedure TgdcTreeTable.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
begin
  if AMetadata = mdsCreate then
  begin
    S.Add
    (
      'CREATE TABLE ' + FieldByName('relationname').AsString +
      '( id dintkey, parent dparent, disabled ddisabled,' +
      'editiondate deditiondate, ' +
      'editorkey dintkey, ' +
      'PRIMARY KEY (id), ' +
      'FOREIGN KEY (parent) REFERENCES ' + FieldByName('relationname').AsString +
      ' (id) ON DELETE CASCADE ON UPDATE CASCADE )'
    );
    S.Add(CreateEditorForeignKey);
    S.Add(CreateGenerator);
    S.Add(CreateInsertTrigger);
    S.Add(CreateInsertEditorTrigger(FieldByName('relationname').AsString));
    S.Add(CreateUpdateEditorTrigger(FieldByName('relationname').AsString));
  end;

  inherited;
end;

procedure TgdcTreeTable.MakePredefinedObjects;
begin
  inherited;
  NewField('PARENT',
    'Родитель', 'DPARENT', 'Родитель', 'Родитель',
    'L', '10', '1', '0');
  NewField('DISABLED',
    'Не активно', 'DDISABLED', 'Не активно', 'Не активно',
    'L', '10', '1', '0');
  NewField('EDITIONDATE',
    'Дата модификации', 'DEDITIONDATE', 'Дата модификации', 'Дата модификации',
    'L', '20', '1', '0');
  NewField('EDITORKEY',
    'Кто модифицировал', 'DINTKEY', 'Кто модифицировал', 'Кто модифицировал',
    'L', '20', '1', '0');
end;

{ TgdcLBRBTreeTable }

procedure TgdcLBRBTreeTable.CheckDependencies;
var
  Names: TLBRBTreeMetaNames;
begin
  // Проверяем, есть ли для нашей таблицы зависимые хранимые процедуры или представления,
  // кроме стандартных частей интервального дерева.
  if GetLBRBTreeDependentNames(FieldByName('relationname').AsString, ReadTransaction, Names) > 3 then  // 3 SP
    raise EgdcIBError.Create('Нельзя удалить таблицу т.к. она используется в процедурах или представлениях');
end;

procedure TgdcLBRBTreeTable.DropDependencies;
var
  gdcProc: TgdcStoredProc;
  gdcException: TgdcException;
  Names: TLBRBTreeMetaNames;
begin
  inherited;

  GetLBRBTreeDependentNames(FieldByName('relationname').AsString, ReadTransaction, Names);

  gdcProc := TgdcStoredProc.Create(nil);
  try
    gdcProc.Transaction := Transaction;
    gdcProc.SubSet := 'ByProcName';

    gdcProc.ParamByName('procedurename').AsString := Names.RestrName;
    gdcProc.Open;
    if not gdcProc.EOF then
      gdcProc.Delete;
    gdcProc.Close;

    gdcProc.ParamByName('procedurename').AsString := Names.ExLimName;
    gdcProc.Open;
    if not gdcProc.EOF then
      gdcProc.Delete;
    gdcProc.Close;

    gdcProc.ParamByName('procedurename').AsString := Names.ChldCtName;
    gdcProc.Open;
    if not gdcProc.EOF then
      gdcProc.Delete;
  finally
    gdcProc.Free;
  end;

  gdcException := TgdcException.Create(nil);
  try
    gdcException.Transaction := Transaction;
    gdcException.SubSet := 'ByObjectName';
    gdcException.ParamByName('objectname').AsString := Names.ExceptName;
    gdcException.Open;
    if not gdcException.EOF then
      gdcException.Delete;
    gdcException.Close;
  finally
    gdcException.Free;
  end;
end;

function TgdcLBRBTreeTable.GetAutoObjectsNames(SL: TStrings): Boolean;
var
  LBRBTree: TLBRBTreeMetaNames;
begin
  inherited GetAutoObjectsNames(SL);

  GetLBRBTreeDependentNames(FieldByName('relationname').AsString, Transaction, LBRBTree);

  SL.Add(LBRBTree.ChldCtName);
  SL.Add(LBRBTree.ExLimName);
  SL.Add(LBRBTree.RestrName);
  SL.Add(LBRBTree.ExceptName);
  SL.Add(LBRBTree.BITriggerName);
  SL.Add(LBRBTree.BUTriggerName);
  SL.Add(LBRBTree.LBIndexName);
  SL.Add(LBRBTree.RBIndexName);
  SL.Add(LBRBTree.ChkName);

  Result := True;
end;

procedure TgdcLBRBTreeTable.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
var
  N: String;
  SL: TStringList;
  I: Integer;
begin
  if AMetadata = mdsCreate then
  begin
    S.Add
    (
      'CREATE TABLE ' + FieldByName('relationname').AsString +
      '(id dintkey, parent dparent, lb dlb, rb drb, disabled ddisabled,' +
      'editiondate deditiondate, ' +
      'editorkey dintkey, ' +
      'PRIMARY KEY (id), ' +
      'FOREIGN KEY (parent) ' +
      'REFERENCES ' + FieldByName('relationname').AsString +
      ' (id) ON DELETE CASCADE ON UPDATE CASCADE)'
    );
    S.Add(CreateEditorForeignKey);

    S.Add(CreateInsertEditorTrigger(FieldByName('relationname').AsString));
    S.Add(CreateUpdateEditorTrigger(FieldByName('relationname').AsString));

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
        S.Add(SL[I]);
      end;
    finally
      SL.Free;
    end;
  end;

  inherited;
end;

procedure TgdcLBRBTreeTable.MakePredefinedObjects;
begin
  inherited;
  NewField('PARENT',
    'Родитель', 'DPARENT', 'Родитель', 'Родитель',
    'L', '10', '1', '0');
  NewField('LB',
    'Левая граница', 'DLB', 'Левая граница', 'Левая граница',
    'L', '10', '1', '0');
  NewField('RB',
    'Правая граница', 'DRB', 'Правая граница', 'Правая граница',
    'L', '10', '1', '0');
  NewField('DISABLED',
    'Не активно', 'DDISABLED', 'Не активно', 'Не активно',
    'L', '10', '1', '0');
  NewField('EDITIONDATE',
    'Дата модификации', 'DEDITIONDATE', 'Дата модификации', 'Дата модификации',
    'L', '20', '1', '0');
  NewField('EDITORKEY',
    'Кто модифицировал', 'DINTKEY', 'Кто модифицировал', 'Кто модифицировал',
    'L', '20', '1', '0');
end;

{ TgdcMetaBase }

procedure TgdcMetaBase.DropDependencies;
begin
  //
end;

function TgdcMetaBase.CheckObjectName(const ARaiseException: Boolean = True;
  const AFocusControl: Boolean = True; const AFieldName: String = ''): Boolean;
var
  S, FN: String;
  I: Integer;
  F: TField;
  Res: OleVariant;
begin
  if AFieldName = '' then
    FN := GetFirebirdObjectNameField
  else
    FN := AFieldName;

  S := FieldByName(FN).AsString;

  if (State = dsInsert) and (StrIPos(UserPrefix, S) <> 1) then
  begin
    S := gdcBaseManager.AdjustMetaName(UserPrefix + S);
    FieldByName(FN).AsString := S;
  end;

  if Trim(StringReplace(S, UserPrefix, '', [rfReplaceAll, rfIgnoreCase])) = '' then
  begin
    if AFocusControl then
      FieldByName(FN).FocusControl;
    if ARaiseException then
      raise Exception.Create('Введите название!')
    else begin
      Result := False;
      exit;
    end;
  end;

  if S[1] in ['0'..'9'] then
  begin
    if AFocusControl then
      FieldByName(FN).FocusControl;
    if ARaiseException then
      raise Exception.Create('Название не может начинаться с цифры!')
    else begin
      Result := False;
      exit;
    end;
  end;

  for I := 1 to Length(S) do
  begin
    if not (S[I] in ['A'..'Z', '_', '0'..'9', '$']) then
    begin
      if AFocusControl then
        FieldByName(FN).FocusControl;
      if ARaiseException then
        raise Exception.Create('Название может состоять из латинских букв, цифр, знака подчеркивания и $')
      else begin
        Result := False;
        exit;
      end;
    end;
  end;

  if (State = dsInsert) and (not (Self is TgdcRelationField)) then
  begin
    if ExecSingleQueryResult(
      'SELECT ' + GetKeyField(SubType) +
      ' FROM ' + GetListTable(SubType) +
      ' WHERE UPPER(' + GetFirebirdObjectNameField + ') = ''' + UpperCase(S) + '''', 0, Res) then
    begin
      if AFocusControl then
        FieldByName(FN).FocusControl;
      if ARaiseException then
        raise Exception.Create('В базе данных найден объект с названием: ' + S)
      else begin
        Result := False;
        exit;
      end;
    end;
  end;

  if State = dsInsert then
  begin
    F := FindField('lname');
    if (F <> nil) and (F.AsString = '') then
      F.AsString := System.Copy(S, 1, F.Size);

    F := FindField('lshortname');
    if (F <> nil) and (F.AsString = '') then
      F.AsString := System.Copy(S, 1, F.Size);

    F := FindField('description');
    if (F <> nil) and (F.AsString = '') then
      F.AsString := System.Copy(S, 1, F.Size);
  end;

  Result := True;
end;

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
  {M}                raise Exception.Create('Для метода ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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

  if State = dsInactive then
    Result :=
      'SELECT ' + GetKeyField(SubType) + ' FROM ' + GetListTable(SubType) +
      '  WHERE UPPER(' + GetFirebirdObjectNameField + ') = UPPER(:' + GetFirebirdObjectNameField + ')'
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result :=
      'SELECT ' + GetKeyField(SubType) + ' FROM ' + GetListTable(SubType) +
      '  WHERE UPPER(' + GetFirebirdObjectNameField + ') = UPPER(''' +
        FirebirdObjectName + ''')';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMETABASE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMETABASE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcMetaBase.Class_TestUserRights(const SS: TgdcTableInfos;
  const ST: String): Boolean;
begin
  Assert(IBLogin <> nil);

  if (not IBLogin.IsIBUserAdmin) and ((tiAChag in SS) or (tiAFull in SS)) then
    Result := False
  else
    Result := inherited Class_TestUserRights(SS, ST);
end;

constructor TgdcMetaBase.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpModify, cpDelete];
end;

procedure TgdcMetaBase.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  FSQL: TSQLProcessList;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCMETABASE', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMETABASE', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMETABASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMETABASE',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMETABASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if IsUserDefined then
  begin
    CheckDependencies;

    FNeedSingleUser := True;
    DropDependencies;

    FSQL := TSQLProcessList.Create;
    try
      FMetaDataScript := mdsDrop;
      GetMetadataScript(FSQL, FMetaDataScript);
      ShowSQLProcess(FSQL);
    finally
      FSQL.Free;
    end;
  end else
    FMetaDataScript := mdsNone;

  FDeletedID := ID;

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMETABASE', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMETABASE', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcMetaBase.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  FSQL: TSQLProcessList;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCMETABASE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMETABASE', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMETABASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMETABASE',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMETABASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if IsUserDefined then
  begin
    FSQL := TSQLProcessList.Create;
    try
      FMetaDataScript := mdsCreate;
      GetMetadataScript(FSQL, FMetaDataScript);
      ShowSQLProcess(FSQL);
    finally
      FSQL.Free;
    end;

    if not atDatabase.InMulticonnection then
      SyncRDBObjects;
  end else
    FMetadataScript := mdsNone;

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMETABASE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMETABASE', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcMetaBase.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  FSQL: TSQLProcessList;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCMETABASE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMETABASE', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMETABASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMETABASE',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMETABASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if IsUserDefined and (not FSkipMetadata) then
  begin
    FNeedSingleUser := True;
    FSQL := TSQLProcessList.Create;
    try
      FMetaDataScript := mdsAlter;
      GetMetadataScript(FSQL, FMetaDataScript);
      ShowSQLProcess(FSQL);
    finally
      FSQL.Free;
    end;
  end else
    FMetaDataScript := mdsNone;

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMETABASE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMETABASE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
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

  if FMetadataScript <> mdsNone then
  begin
    if Transaction.InTransaction then
      Transaction.CommitRetaining;

    if (FMetaDataScript = mdsCreate) and IsUserDefined then
      MakePredefinedObjects;

    if Assigned(atDatabase) and (not atDatabase.InMultiConnection) then
      SyncAtDatabase(ID, FMetadataScript);
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMETABASE', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMETABASE', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcMetaBase.DoBeforeEdit;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCMETABASE', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMETABASE', KEYDOBEFOREEDIT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREEDIT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMETABASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMETABASE',
  {M}          'DOBEFOREEDIT', KEYDOBEFOREEDIT, Params, LResult) then exit;
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

  FieldByName(GetFirebirdObjectNameField).ReadOnly := True;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMETABASE', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMETABASE', 'DOBEFOREEDIT', KEYDOBEFOREEDIT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcMetaBase.DoBeforeInsert;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCMETABASE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMETABASE', KEYDOBEFOREINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMETABASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMETABASE',
  {M}          'DOBEFOREINSERT', KEYDOBEFOREINSERT, Params, LResult) then exit;
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

  FieldByName(GetFirebirdObjectNameField).ReadOnly := False;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMETABASE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMETABASE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcMetaBase.DoBeforePost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCMETABASE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMETABASE', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMETABASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMETABASE',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
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

  if (not (sLoadFromStream in BaseState)) and (not IsFirebirdObject) and (not IsDerivedObject) then
    CheckObjectName;

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMETABASE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMETABASE', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

function TgdcMetaBase.GetAutoObjectsNames(SL: TStrings): Boolean;
begin
  Result := False;
end;

function TgdcMetaBase.GetCanAddToNS: Boolean;
begin
  if IsDerivedObject then
    Result := False
  else
    Result := inherited GetCanAddToNS;  
end;

function TgdcMetaBase.GetCanDelete: Boolean;
begin
  if IsUserDefined then
    Result := inherited GetCanDelete
  else
    Result := False;
end;

function TgdcMetaBase.GetCanEdit: Boolean;
begin
  if IsFirebirdObject or IsDerivedObject then
    Result := False
  else
    Result := inherited GetCanEdit;
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
  {M}                raise Exception.Create('Для метода ''' + 'GETDIALOGDEFAULTSFIELDS' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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

function TgdcMetaBase.GetFirebirdObjectName: String;
begin
  Result := FieldByName(GetFirebirdObjectNameField).AsString;
end;

function TgdcMetaBase.GetFirebirdObjectNameField: String;
begin
  Result := GetListField(SubType);
end;

function TgdcMetaBase.GetIsDerivedObject: Boolean;
begin
  Result := False;
end;

function TgdcMetaBase.GetIsFirebirdObject: Boolean;
var
  F: TField;
begin
  F := FindField('RDB$SYSTEM_FLAG');
  Result := ((F is TIntegerField) and (F.AsInteger <> 0))
    or (StrIPos('RDB$', FirebirdObjectName) = 1)
    or (StrIPos('MON$', FirebirdObjectName) = 1);
end;

function TgdcMetaBase.GetIsUserDefined: Boolean;
begin
  Result := (not IsFirebirdObject)
    and (StrIPos(UserPrefix, FirebirdObjectName) = 1);
end;

procedure TgdcMetaBase.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
begin
  //
end;

function TgdcMetaBase.GetObjectName: String;
var
  F: TField;
begin
  if Active then
  begin
    F := FindField('lname');
    if (F <> nil) and (F.AsString <> FirebirdObjectName) then
      Result := F.AsString + ', ' + FirebirdObjectName
    else
      Result := FirebirdObjectName;
  end else
    Result := inherited GetObjectName;
end;

procedure TgdcMetaBase.GetProperties(ASL: TStrings);
begin
  inherited;

  if IsUserDefined then
    ASL.Add(AddSpaces('User defined') + 'Yes')
  else
    ASL.Add(AddSpaces('User defined') + 'No');

  if IsFirebirdObject then
    ASL.Add(AddSpaces('Firebird object') + 'Yes')
  else
    ASL.Add(AddSpaces('Firebird object') + 'No');

  if IsDerivedObject then
    ASL.Add(AddSpaces('Derived object') + 'Yes')
  else
    ASL.Add(AddSpaces('Derived object') + 'No');

  ASL.Add(AddSpaces('Fb object name') + FirebirdObjectName);
end;

function TgdcMetaBase.GetRelationName: String;
var
  F: TField;
begin
  F := FindField('relationname');
  if Active and (F <> nil) then
    Result := F.AsString
  else
    Result := '';
end;

class function TgdcMetaBase.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'OnlyAttribute;ByObjectName;';
end;

procedure TgdcMetaBase.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('OnlyAttribute') then
    S.Add('z.' + GetFirebirdObjectNameField + ' LIKE ''USR$%''');
  if HasSubSet('ByObjectName') then
    S.Add('z.' + GetFirebirdObjectNameField + '=:objectname');
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
  AnObject: TgdcMetaBase;
  C: TgdcFullClass;
  Cl: CgdcMetaBase;
begin
  C := GetCurrRecordClass;

  if (Assigned(ObjectSet) and (ObjectSet.Find(ID) > -1))
    or (Self.ClassType <> C.gdClass)
    or (Self.SubType <> C.SubType) then
  begin
    exit;
  end;

  ibsql := CreateReadIBSQL;
  ibsqlID := CreateReadIBSQL;
  try
    ibsql.SQL.Text :=
      'SELECT * FROM rdb$dependencies WHERE rdb$dependent_name = :dn';
    ibsql.ParamByName('dn').AsString := ADependent_Name;
    ibsql.ExecQuery;
    while not ibsql.Eof do
    begin
      ibsqlID.Close;
      case ibsql.FieldByName('rdb$depended_on_type').AsInteger of
        1, 0:
        begin
          if ibsql.FieldByName('rdb$field_name').IsNull then
          begin
            ibsqlID.SQL.Text :=
              'SELECT id FROM at_relations WHERE relationname = :rn';
            ibsqlID.ParamByName('rn').AsString := ibsql.FieldByName('rdb$depended_on_name').AsTrimString;
            Cl := TgdcRelation;
          end else
          begin
            ibsqlID.SQL.Text :=
              'SELECT id FROM at_relation_fields WHERE fieldname = :fn AND relationname = :rn';
            ibsqlID.ParamByName('fn').AsString := ibsql.FieldByName('rdb$field_name').AsTrimString;
            ibsqlID.ParamByName('rn').AsString := ibsql.FieldByName('rdb$depended_on_name').AsTrimString;
            Cl := TgdcRelationField;
          end;
        end;
        5:
        begin
          ibsqlID.SQL.Text :=
            'SELECT id FROM at_procedures WHERE procedurename = :pn';
          ibsqlID.ParamByName('pn').AsString := ibsql.FieldByName('rdb$depended_on_name').AsTrimString;
          Cl := TgdcStoredProc;
        end;
        7:
        begin
          ibsqlID.SQL.Text :=
            'SELECT id FROM at_exceptions WHERE exceptionname = :en';
          ibsqlID.ParamByName('en').AsString := ibsql.FieldByName('rdb$depended_on_name').AsTrimString;
          Cl := TgdcException;
        end
      else
        Cl := nil;
        ibsqlID.SQL.Text := '';
      end;

      if ibsqlID.SQL.Text > '' then
      begin
        ibsqlID.ExecQuery;
        if not ibsqlID.EOF then
        begin
          AnObject := Cl.CreateSubType(nil, '', 'ByID');
          try
            AnObject.ID := GetTID(ibsqlID.Fields[0]);
            AnObject.Open;
            if (not AnObject.EOF)
              and (AnObject.ID <> ID)
              and (not AnObject.IsFirebirdObject)
              and (not AnObject.IsDerivedObject) then
            begin
              AnObject._SaveToStream(Stream, ObjectSet, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
            end;
          finally
            AnObject.Free;
          end;
        end;
        ibsqlID.Close;
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
  TransactionKey: TID;
  q: TIBSQL;
  DidActivate: Boolean;
  I: Integer;
begin
  Assert(Assigned(atDatabase));

  if S.Count = 0 then
    exit;

  DidActivate := False;
  q := TIBSQL.Create(nil);
  try
    q.Transaction := Transaction;
    DidActivate := ActivateTransaction;

    try
      if atDatabase.InMultiConnection then
      begin
        TransactionKey := GetNextID;

        q.SQL.Text :=
          'INSERT INTO at_transaction (trkey, numorder, script, successfull) ' +
          'VALUES (:trkey, :numorder, :script, :successfull)';

        AddText('Сохранение команд для отложенного выполнения:');

        //  Осуществляем сохранение всех скриптов, которые должны быть
        //  запущены после переподключения
        for i := 0 to S.Count - 1 do
        begin
          if Trim(S[I]) > '' then
          begin
            AddText(S[I]);

            SetTID(q.ParamByName('trkey'), TransactionKey);
            q.ParamByName('numorder').AsInteger := i + 1;
            q.ParamByName('script').AsString := S[I];
            q.ParamByName('successfull').AsInteger := S.Successful[I];
            q.ExecQuery;
            q.Close;
          end;
        end;

        AddText('Окончено сохранение команд для отложенного выполнения.');
      end else
      begin
        if FNeedSingleUser then
        begin
          with TfrmIBUserList.Create(nil) do
          try
            if not CheckUsers then
              raise EgdcIBError.Create(
                'К базе данных подключены другие пользователи!'#13#10 +
                'Процесс создания метаданных остановлен!');
          finally
            Free;
          end;
        end;

        for I := 0 to S.Count - 1 do
        begin
          if Trim(S[I]) > '' then
          begin
            AddText(S[I], 'sql');
            Transaction.ExecSQLImmediate(S[I]);
          end;
        end;
      end;
    except
      on E: Exception do
      begin
        if DidActivate and Transaction.InTransaction then
          Transaction.Rollback;
        AddMistake(E.Message);
        raise;
      end;
    end;

    if atDatabase.InMultiConnection and (not (sLoadFromStream in BaseState)) then
      AddText('Для выполнения операции необходимо переподключение к базе данных!');
  finally
    q.Free;
    if DidActivate and Transaction.InTransaction then
       Transaction.Commit;
  end;
end;

procedure TgdcMetaBase.ShowSQLProcess(const S: String);
var
  FSQL: TSQLProcessList;
begin
  FSQL := TSQLProcessList.Create;
  try
    FSQL.Add(S);
    ShowSQLProcess(FSQL);
  finally
    FSQL.Free;
  end;
end;

procedure TgdcMetaBase.SyncAtDatabase(const AnID: TID; const AMetadata: TgdcMetadataScript);
begin

end;

procedure TgdcMetaBase.MakePredefinedObjects;
begin
  //
end;

procedure TgdcMetaBase.CheckDependencies;
begin
  //
end;

procedure TgdcMetaBase.SyncRDBObjects;
begin
  //
end;

procedure TgdcMetaBase.DoAfterDelete;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCMETABASE', 'DOAFTERDELETE', KEYDOAFTERDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMETABASE', KEYDOAFTERDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMETABASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMETABASE',
  {M}          'DOAFTERDELETE', KEYDOAFTERDELETE, Params, LResult) then exit;
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

  if FMetadataScript <> mdsNone then
  begin
    if Transaction.InTransaction then
      Transaction.CommitRetaining;

    if Assigned(atDatabase) and (not atDatabase.InMultiConnection) and (FDeletedID > 0) then
      SyncAtDatabase(FDeletedID, mdsDrop);
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMETABASE', 'DOAFTERDELETE', KEYDOAFTERDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMETABASE', 'DOAFTERDELETE', KEYDOAFTERDELETE);
  {M}  end;
  {END MACRO}
end;

{ TgdcException }

class function TgdcException.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgException';
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
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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

  Result :=
    'FROM at_exceptions z ' +
    '  LEFT JOIN rdb$exceptions e ON e.rdb$exception_name = z.exceptionname ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEXCEPTION', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEXCEPTION', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcException.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'exceptionname';
end;

class function TgdcException.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'at_exceptions';
end;

procedure TgdcException.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
begin
  case AMetadata of
    mdsCreate: S.Add('CREATE EXCEPTION ' + FirebirdObjectName + ' ''' +
       FieldByName('exceptionmessage').AsString + '''');
    mdsAlter: S.Add('ALTER EXCEPTION ' + FirebirdObjectName + ' ''' +
       FieldByName('exceptionmessage').AsString + '''');
    mdsDrop: S.Add('DROP EXCEPTION ' + FirebirdObjectName);
  end;
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
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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

  Result :=
    'SELECT z.*, ' +
    '  e.rdb$exception_number as exceptionnumber,' +
    '  e.rdb$message as exceptionmessage, '+
    '  e.rdb$description as description, ' +
    '  e.rdb$system_flag as system_flag ';
    
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

{ TgdcIndex }

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

class function TgdcIndex.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByRelation;';
end;

procedure TgdcIndex.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
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
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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

  FieldByName('indexname').AsString :=
    GetObjectNameByRelName(FieldByName('relationname').AsString, '_X_');

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
  ExecSingleQuery(Format('EXECUTE PROCEDURE at_p_sync_indexes(''%s'')',
    [AnsiUpperCase(TRIM(ARelationName))]));
  if Active and NeedRefresh then
    CloseOpen;
end;

class function TgdcIndex.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmIndices';
end;

procedure TgdcIndex._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet;
  PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True);
var
  ibsql: TIBSQL;
begin
  if IsUserDefined then
  begin
    ibsql := CreateReadIBSQL;
    try
      //если название индекса совпадает с названием ограничения, то не сохраняем его
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints ' +
        ' WHERE rdb$constraint_name = rdb$index_name ' +
        ' AND rdb$constraint_name = :indexname';
      ibsql.ParamByName('indexname').AsString := FieldByName('indexname').AsString;
      ibsql.ExecQuery;
      if ibsql.EOF then
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
//т.к. индексы у нас могут начать сохраняться раньше, чем поля таблицы
//попробуем вытянуть и сохранить эти поля
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
          AnObject.ID := GetTID(ibsqlID.Fields[0]);
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

function TgdcIndex.GetIsFirebirdObject: Boolean;
begin
  Result := (inherited GetIsFirebirdObject)
    or (FieldByName('RDB$FOREIGN_KEY').AsString > '');
end;

class function TgdcIndex.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgIndices';
end;

function TgdcIndex.CheckObjectName(const ARaiseException,
  AFocusControl: Boolean; const AFieldName: String): Boolean;
var
  Res: OleVariant;
begin
  Result := inherited CheckObjectName(ARaiseException, AFocusControl, AFieldName);

  if not Result then
    exit;

  if Trim(FieldByName('fieldslist').AsString) = '' then
  begin
    if AFocusControl then
      FieldByName('fieldslist').FocusControl;

    if ARaiseException then
      raise Exception.Create('Укажите список полей, по которым создается индекс!')
    else begin
      Result := False;
      exit;
    end;
  end;

  if ExecSingleQueryResult('SELECT rdb$index_name FROM rdb$indices WHERE rdb$index_name = :indexname',
    FieldByName('indexname').AsString, Res) then
  begin
    if AFocusControl then
      FieldByName('indexname').FocusControl;

    if ARaiseException then
      raise Exception.Create('Индекс с таким именем уже существует!')
    else begin
      Result := False;
      exit;
    end;
  end;
end;

procedure TgdcIndex.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);

  procedure CreateIndex;
  var
    Uq, Ordr: String;
  begin
    if FieldByName('unique_flag').AsInteger <> 0 then
      Uq := 'UNIQUE'
    else
      Uq := '';

    if FieldByName('rdb$index_type').AsInteger <> 0 then
      Ordr := 'DESCENDING'
    else
      Ordr := '';

    S.Add(Format('CREATE %s %s INDEX %s ON %s (%s)',
      [Uq, Ordr, FieldByName('indexname').AsString,
      FieldByName('relationname').AsString, FieldByName('fieldslist').AsString]));
  end;

  procedure DropIndex;
  begin
    S.Add('DROP INDEX ' + FieldByName('indexname').AsString);
  end;

begin
  inherited;

  case AMetadata of
    mdsCreate: CreateIndex;
    mdsDrop: DropIndex;

    mdsAlter:
    begin
      if FieldByName('changedata').AsInteger <> 0 then
      begin
        DropIndex;
        CreateIndex;
      end
      else if FieldByName('changeactive').AsInteger <> 0 then
      begin
        if FieldByName('index_inactive').AsInteger <> 0 then
          S.Add('ALTER INDEX ' + FieldByName('indexname').AsString + ' INACTIVE')
        else
          S.Add('ALTER INDEX ' + FieldByName('indexname').AsString + ' ACTIVE')
      end;
    end;
  end;
end;

{ TgdcBaseTrigger }

function TgdcBaseTrigger.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCBASETRIGGER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASETRIGGER', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASETRIGGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASETRIGGER',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASETRIGGER' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' FROM at_triggers z LEFT JOIN rdb$triggers t ON z.triggername = t.rdb$trigger_name '
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASETRIGGER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASETRIGGER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcBaseTrigger.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCBASETRIGGER', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASETRIGGER', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASETRIGGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASETRIGGER',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASETRIGGER' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'SELECT z.*, t.rdb$trigger_name, t.rdb$trigger_sequence, t.rdb$trigger_type, ' +
    ' t.rdb$trigger_source, t.rdb$trigger_blr, t.rdb$description, t.rdb$system_flag, ' +
    ' t.rdb$flags, t.rdb$trigger_inactive ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASETRIGGER', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASETRIGGER', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBaseTrigger.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASETRIGGER', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASETRIGGER', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASETRIGGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASETRIGGER',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASETRIGGER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if not (sMultiple in BaseState) then
  begin
    if (FieldByName('rdb$trigger_type').asinteger <= 114) and
       (FieldByName('relationname').AsString = '') then
      FieldByName('relationname').AsString :=
        AnsiUpperCase(Trim(atDataBase.Relations.ByID(GetTID(FieldByName('relationkey'))).RelationName));

    if FieldByName('rdb$trigger_name').AsString = '' then
      FieldByName('rdb$trigger_name').AsString := Trim(FieldByName('triggername').AsString);
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASETRIGGER', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASETRIGGER', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBaseTrigger.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByRelation') then
    S.Add(' z.relationkey = :relationkey ');
  if HasSubSet('ByTriggerName') then
    S.Add(' z.triggername = :triggername ');
  if HasSubSet('ByDBTriggers') then
    S.Add(' t.rdb$trigger_type >= 8192 ');
end;

function TgdcBaseTrigger.GetIsDerivedObject: Boolean;
begin
  Result :=
    (
      FirebirdObjectName > ''
    )
    and
    (
      (StrIPos('USR$BI_USR$CROSS', FirebirdObjectName) = 1)
      or
      (GetTriggerName(FieldByName('relationname').AsString, 'BI', 5) = FirebirdObjectName)
      or
      (GetTriggerName(FieldByName('relationname').AsString, 'BU', 5) = FirebirdObjectName)
      or
      (gdcBaseManager.AdjustMetaName('usr$bi_' + FieldByName('relationname').AsString) =
         FirebirdObjectName)
    );
end;

class function TgdcBaseTrigger.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'triggername';
end;

class function TgdcBaseTrigger.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'at_triggers';
end;

class function TgdcBaseTrigger.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgTrigger';
end;

class function TgdcBaseTrigger.GetNotStreamSavedField(const IsReplicationMode: Boolean): String;
begin
  Result := inherited GetNotStreamSavedField(IsReplicationMode);
  if Result > '' then
    Result := Result + ',';
  Result := Result + 'RDB$TRIGGER_BLR';
end;

procedure TgdcBaseTrigger.SyncAllTriggers(const NeedRefresh: Boolean = True);
begin
  ExecSingleQuery('EXECUTE PROCEDURE at_p_sync_triggers_all');
  if NeedRefresh and Active then
    CloseOpen;
end;

procedure TgdcBaseTrigger._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet;
  PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True);
var
  I: Integer;
begin
  //Мы не будем сохранять триггер USR$_BU_INV_CARD в поток,
  //т.к. он генерируется автоматически при изменении структуры таблицы inv_card
  if (AnsiCompareText('USR$_BU_INV_CARD', Trim(FieldByName('triggername').AsString)) = 0) then
    Exit;
  for I := 1 to MaxInvCardTrigger do
    if (AnsiCompareText(Format('USR$%d_BU_INV_CARD', [I]), Trim(FieldByName('triggername').AsString)) = 0) then
      Exit;
  //В поток сохраняем только триггеры-атрибуты
  if IsUserDefined then
  begin
    SaveToStreamDependencies(Stream, ObjectSet,
      FieldByName('triggername').AsString, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
    inherited;
  end;
end;

class procedure TgdcBaseTrigger.EnumTriggerTypes(S: TStrings);
begin
  //
end;

function TgdcBaseTrigger.ComposeTriggerName: String;
begin
  Result := '';
end;

procedure TgdcBaseTrigger.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
var
  ActiveText, SubText: String;
begin
  inherited;

  case AMetadata of
    mdsDrop: S.Add('DROP TRIGGER ' + FieldByName('rdb$trigger_name').AsString);

    mdsCreate, mdsAlter:
    begin
      //Если было изменено имя триггера, то удалим триггер со старым именем
      if not AnsiSameText(Trim(FieldByName('triggername').AsString), Trim(FieldByName('rdb$trigger_name').AsString)) then
        S.Add('DROP TRIGGER ' + FieldByName('rdb$trigger_name').AsString);

      // Создание\изменение триггера
      if FieldByName('trigger_inactive').AsInteger <> 0 then
        ActiveText := 'INACTIVE'
      else
        ActiveText := 'ACTIVE';

      SubText := gdcTriggerHelper.GetTypeName(FieldByName('rdb$trigger_type').AsInteger);

      if FieldByName('rdb$trigger_type').AsInteger <= 114 then
        S.Add(Format('CREATE OR ALTER TRIGGER %s FOR %s %s %s POSITION %s ' +
          ' %s ', [FieldByName('triggername').AsString, FieldByName('relationname').AsString,
          ActiveText, SubText, FieldByName('rdb$trigger_sequence').AsString,
          FieldByName('rdb$trigger_source').AsString]))
      else
        S.Add(Format('CREATE OR ALTER TRIGGER %s %s %s %s',
          [FieldByName('triggername').AsString, ActiveText, SubText,
          FieldByName('rdb$trigger_source').AsString]));
    end;
  end;
end;

function TgdcBaseTrigger.GetCanEdit: Boolean;
begin
  if not IsUserDefined then
    Result := False
  else
    Result := inherited GetCanEdit;
end;

class function TgdcBaseTrigger.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByRelation;';
end;

{ TgdcTrigger }

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
    '/*Тело триггера*/' + #13#10 + 'END';

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


class function TgdcTrigger.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByTriggerName;';
end;

procedure TgdcTrigger.SyncTriggers(const ARelationName: String; const NeedRefresh: Boolean = True);
begin
  ExecSingleQuery(Format('EXECUTE PROCEDURE at_p_sync_triggers(''%s'')',
    [AnsiUpperCase(TRIM(ARelationName))]));
  if Active and NeedRefresh then
    CloseOpen;
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

class function TgdcTrigger.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmTrigger';
end;

class procedure TgdcTrigger.EnumTriggerTypes(S: TStrings);
begin
  gdcTriggerHelper.EnumTableTriggerTypes(S);
end;

function TgdcTrigger.ComposeTriggerName: String;
begin

end;

{ TgdcDBTrigger }

procedure TgdcDBTrigger._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCDBTRIGGER', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCDBTRIGGER', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCDBTRIGGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCDBTRIGGER',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCDBTRIGGER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('trigger_inactive').AsInteger := 0;
  FieldByName('rdb$trigger_source').AsString := 'AS' + #13#10 + 'BEGIN' + #13#10 +
    '/*Тело триггера*/' + #13#10 + 'END';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCDBTRIGGER', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCDBTRIGGER', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

class function TgdcDBTrigger.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByDBTriggers;';
end;

class function TgdcDBTrigger.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmDBTrigger';
end;

class procedure TgdcDBTrigger.EnumTriggerTypes(S: TStrings);
begin
  gdcTriggerHelper.EnumDBTriggerTypes(S);
end;

{ TgdcTableToTable }

function TgdcTableToTable.GetReferenceName: String;
var
  q: TIBSQL;
begin
  q := CreateReadIBSQL;
  try
    q.Close;
    if GetTID(FieldByName('referencekey')) > 0 then
    begin
      q.SQL.Text := 'SELECT relationname FROM at_relations WHERE id = :id';
      SetTID(q.ParamByName('id'), FieldByName('referencekey'));
      q.ExecQuery;
    end;

    if q.EOF then
    begin
      if sDialog in BaseState then
        FieldByName('referencekey').FocusControl;
      raise EgdcIBError.Create('Не указана таблица-ссылка!');
    end else
      Result := q.FieldByName('relationname').AsString;
  finally
    q.Free;
  end;
end;

procedure TgdcTableToTable.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
var
  KeyField: TatRelationField;
  KeyDomain: TatField;
begin
  if AMetadata = mdsCreate then
  begin
    FIDDomain := gdcBaseManager.AdjustMetaName(FieldByName('relationname').AsString + '_DPK');
    {$IFDEF ID64}
    S.Add('CREATE DOMAIN ' + FIDDomain + ' AS BIGINT NOT NULL');
    {$ELSE}
    S.Add('CREATE DOMAIN ' + FIDDomain + ' AS INTEGER NOT NULL');
    {$ENDIF}

    S.Add(Format
      (
        'CREATE TABLE %s (%s %s, CONSTRAINT %s PRIMARY KEY (%s))',
        [
          FieldByName('relationname').AsString,
          GetPrimaryFieldName,
          FIDDomain,
          gdcBaseManager.AdjustMetaName(FieldByName('relationname').AsString + '_PK'),
          GetPrimaryFieldName
        ]
      )
    );
    S.Add(Format
      (
        'ALTER TABLE %s ADD CONSTRAINT %s FOREIGN KEY (%s) REFERENCES %s (%s) ON UPDATE CASCADE ON DELETE CASCADE',
        [
          FieldByName('relationname').AsString,
          gdcBaseManager.AdjustMetaName(FieldByName('relationname').AsString + '_FK'),
          GetPrimaryFieldName,
          GetReferenceName,
          GetKeyFieldName(GetReferenceName)
        ]
      )
    );
  end;

  inherited;

  if AMetadata = mdsDrop then
  begin
    KeyField := atDatabase.FindRelationField(FieldByName('relationname').AsString,
      GetKeyFieldName(FieldByName('relationname').AsString));

    if KeyField <> nil then
    begin
      KeyDomain := KeyField.Field;

      if (KeyDomain <> nil) and KeyDomain.IsUserDefined then
      begin
        S.Add('DROP DOMAIN ' + KeyDomain.FieldName);
        FIDDomain := KeyDomain.FieldName;
      end;
    end;
  end;
end;

procedure TgdcTableToTable.SyncAtDatabase(const AnID: TID;
  const AMetadata: TgdcMetadataScript);
begin
  inherited;

  if AMetadata = mdsDrop then
  begin
    if atDatabase.Fields.ByFieldName(FIDDomain) <> nil then
      atDatabase.Fields.Delete(atDatabase.Fields.IndexOf(atDatabase.Fields.ByFieldName(FIDDomain)));
  end;
end;

procedure TgdcTableToTable.MakePredefinedObjects;
begin
  inherited;

  if (FIDDomain > '') and (atDatabase.Relations.ByRelationName(GetReferenceName) <> nil) then
  begin
    ExecSingleQuery(Format('INSERT INTO at_fields (' +
      ' fieldname, ' +
      ' lname, ' +
      ' description, ' +
      ' reftable, ' +
      ' reflistfield, ' +
      ' reftablekey, ' +
      ' reflistfieldkey) ' +
      ' VALUES ('+
      ' ''%0:s'', ''%0:s'', ''Ссылка на таблицу %1:s'',' +
      ' ''%1:s'', ''%2:s'', %3:d, %4:d )',
      [FIDDomain, GetReferenceName,
       atDatabase.Relations.ByRelationName(GetReferenceName).ListField.FieldName,
       TID264(atDatabase.Relations.ByRelationName(GetReferenceName).ID),
       TID264(atDatabase.Relations.ByRelationName(GetReferenceName).ListField.ID)
      ]));
  end;
end;

{ TgdcInheritedTable }

class function TgdcInheritedTable.GetPrimaryFieldName: String;
begin
  Result := 'INHERITEDKEY';
end;

{ TgdcBaseTable }

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
  //Перед сохранением в поток нужно синхронизировать индексы
  //т.к. информация об индексах может не успеть занестись в таблицу
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
  Result :=  Format('ALTER TABLE %s ADD CONSTRAINT %s ' +
    ' FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey) ' +
    ' ON UPDATE CASCADE',
    [FieldByName('relationname').AsString,
     GetForeignName(FieldByName('relationname').AsString, 'editorkey')]);
end;

class function TgdcBaseTable.CreateInsertEditorTrigger(const ARelationName: String): String;
begin
  Result := Format(
    ' CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
    ' BEFORE INSERT POSITION %3:s '#13#10 +
    ' AS '#13#10 +
    ' BEGIN '#13#10 +
    '   IF (NEW.editorkey IS NULL) THEN '#13#10 +
    '     NEW.editorkey = RDB$GET_CONTEXT(''USER_SESSION'', ''GD_CONTACTKEY'');'#13#10 +
    '   IF (NEW.editiondate IS NULL) THEN '#13#10 +
    '     NEW.editiondate = CURRENT_TIMESTAMP(0);'#13#10 +
    ' END ',
    [ARelationName,
     GetTriggerName(ARelationName, 'BI', 5),
     IntToStr(cstAdminKey), IntToStr(5)]);
end;

class function TgdcBaseTable.CreateUpdateEditorTrigger(const ARelationName: String): String;
begin
  Result := Format(
    ' CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
    ' BEFORE UPDATE POSITION %3:s '#13#10 +
    ' AS '#13#10 +
    ' BEGIN '#13#10 +
    '   IF (NEW.editorkey IS NULL) THEN '#13#10 +
    '     NEW.editorkey = RDB$GET_CONTEXT(''USER_SESSION'', ''GD_CONTACTKEY'');'#13#10 +
    '   IF (NEW.editiondate IS NULL) THEN '#13#10 +
    '     NEW.editiondate = CURRENT_TIMESTAMP(0);'#13#10 +
    ' END ',
    [ARelationName,
     GetTriggerName(ARelationName, 'BU', 5),
     IntToStr(cstAdminKey), IntToStr(5)]);
end;

procedure TgdcBaseTable.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
begin
  inherited;

  case AMetadata of
    mdsDrop:
    begin
      S.Add('DROP TABLE ' + FieldByName('relationname').AsString);
      S.Add('DELETE FROM GD_COMMAND WHERE UPPER(subtype) = ''' + UpperCase(FieldByName('relationname').AsString) + '''');
    end;
  end;
end;

procedure TgdcBaseTable.MakePredefinedObjects;
begin
  inherited;

  NewField(GetPrimaryFieldName,
    'Идентификатор', 'DINTKEY', 'Идентификатор', 'Идентификатор',
    'L', '10', '1', '0');
end;

function TgdcBaseTable.CreateGenerator: String;
var q: TIBSQL;
begin
  if FieldByName('generatorname').AsString <> '' then
  begin
    // если необходимо, создаем генератор
    Assert(Transaction <> nil);
    q := TIBSQL.Create(nil);
    try
      q.Transaction := Transaction;
      q.SQL.Text := 'SELECT RDB$GENERATOR_ID FROM RDB$GENERATORS WHERE RDB$GENERATOR_NAME = :gn';
      q.ParamByName('gn').AsString := FieldByName('generatorname').AsString;
      q.ExecQuery;

      if q.RecordCount = 0 then
        Result := 'CREATE GENERATOR ' + FieldByName('generatorname').AsString;
    finally;
     q.Close;
    end;
  end;

end;

{ TgdcUnknownTable }

procedure TgdcUnknownTable.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCUNKNOWNTABLE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUNKNOWNTABLE', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUNKNOWNTABLE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUNKNOWNTABLE',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUNKNOWNTABLE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if (not (sLoadFromStream in BaseState)) or
    (StrIPos(CrossTablePrefix, FieldByName('relationname').AsString) <> 1) then
  begin
    inherited;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUNKNOWNTABLE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUNKNOWNTABLE', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

function GetSimulateFieldNameByRel(RelName: String): String;
begin
// Имя поля для создания кросс-таблицы (таблица не может быть создана без полей,
//  а при считывании из потока мы не можем знать как называюся ее поля, посему создается левое поле,
//  которое в последствии удаляется
  if AnsiPos(UserPrefix, RelName) = 1 then
    Result := 'USR' + Copy(RelName, 5, Length(RelName) - 4)
  else
    Result := '';
  Result := gdcBaseManager.AdjustMetaName(Result);
end;

procedure TgdcUnknownTable._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet; PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean);
var
  gdcRField: TgdcRelationField;
  atRelation: TatRelation;
  I: Integer;
begin
  Assert(atDatabase <> nil, 'Не загружена база атрибутов!');
  inherited;
  {Сделано для кросс-таблиц. Если это пользовательская таблица и у нее есть
   праймари кей, то сохраним в поток поля, входящие в праймари кей}
  if IsUserDefined then
  begin
    atRelation := atDatabase.Relations.ByRelationName(FieldByName('relationname').Asstring);

    if not Assigned(atRelation) then
      raise EgdcIBError.Create('Таблица ' + FieldByName('relationname').Asstring +
        ' не найдена! Попробуйте перезагрузиться.');

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

procedure TgdcUnknownTable.MakePredefinedObjects;
begin
  //inherited;
end;

procedure TgdcUnknownTable.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
begin
  if sLoadFromStream in BaseState then
  begin
    if AMetadata = mdsCreate then
    begin
      if sLoadFromStream in BaseState then
      begin
        S.Add
        (
          'CREATE TABLE ' + FieldByName('relationname').AsString +
          '(' + GetSimulateFieldNameByRel(FieldByName('relationname').AsString) + ' dintkey)'
        );
      end;
    end;

    inherited;
  end;  
end;

{ TSQLProcessList }

procedure TSQLProcessList.Add(const Script: String; const Successful: Boolean = True);
begin
  if Script > '' then
  begin
    FScriptList.Add(Script);
    if Successful then
      FSuccessfulList.Add('1')
    else
      FSuccessfulList.Add('0');
  end;
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

{ TgdcTable }

procedure TgdcTable.SyncAtDatabase(const AnID: TID; const AMetadata: TgdcMetadataScript);
var
  Prnt: TgdClassEntry;
  CE: TgdClassEntry;
begin
  inherited;

  case AMetadata of
    mdsCreate:
    begin
      Prnt := nil;

      if Self is TgdcLBRBTreeTable then
        Prnt := gdClassList.Get(TgdBaseEntry, 'TgdcAttrUserDefinedLBRBTree')
      else if Self is TgdcTreeTable then
        Prnt := gdClassList.Get(TgdBaseEntry, 'TgdcAttrUserDefinedTree')
      else if Self is TgdcInheritedTable then
        Prnt := gdClassList.FindByRelation((Self as TgdcInheritedTable).GetReferenceName)
      else if (Self is TgdcSimpleTable) or (Self is TgdcPrimeTable) or (Self is TgdcTableToTable) then
        Prnt := gdClassList.Get(TgdBaseEntry, 'TgdcAttrUserDefined');

      if Prnt = nil then
        raise EgdcException.CreateObj('Unknown metadata class.', Self);

      CE := gdClassList.Add(Prnt.TheClass, FieldByName('relationname').AsString,
        Prnt.SubType, CgdClassEntry(TgdAttrUserDefinedEntry), FieldByName('lname').AsString);

      if CE <> nil then
        (CE as TgdBaseEntry).DistinctRelation := UpperCase(FieldByName('relationname').AsString);
    end;

    mdsAlter:
      if FieldChanged('lname') then
        gdClassList.LoadRelation(FieldByName('relationname').AsString);
  end;
end;

{ TgdcPrimeTable }

class function TgdcPrimeTable.CreateInsertEditorTrigger(const ARelationName: String): String;
begin
  Result := Format(
    ' CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
    ' BEFORE INSERT POSITION %3:s '#13#10 +
    ' AS '#13#10 +
    ' BEGIN '#13#10 +
    '   IF (NEW.editiondate IS NULL) THEN '#13#10 +
    '     NEW.editiondate = CURRENT_TIMESTAMP(0);'#13#10 +
    ' END ',
    [ARelationName,
     GetTriggerName(ARelationName, 'BI', 5),
     IntToStr(cstAdminKey), IntToStr(5)]);
end;

class function TgdcPrimeTable.CreateUpdateEditorTrigger(const ARelationName: String): String;
begin
  Result := Format(
    ' CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
    ' BEFORE UPDATE POSITION %3:s '#13#10 +
    ' AS '#13#10 +
    ' BEGIN '#13#10 +
    '   IF (NEW.editiondate IS NULL) THEN '#13#10 +
    '     NEW.editiondate = CURRENT_TIMESTAMP(0);'#13#10 +
    ' END ',
    [ARelationName,
     GetTriggerName(ARelationName, 'BU', 5),
     IntToStr(cstAdminKey), IntToStr(5)]);
end;

procedure TgdcPrimeTable.MakePredefinedObjects;
begin
  inherited;
  NewField('EDITIONDATE',
    'Дата модификации', 'DEDITIONDATE', 'Дата модификации', 'Дата модификации',
    'L', '20', '1', '0');
end;

procedure TgdcPrimeTable.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
begin
  if AMetadata = mdsCreate then
  begin
    S.Add
    (
      'CREATE TABLE ' + FieldByName('relationname').AsString +
      '(id dintkey, editiondate deditiondate, PRIMARY KEY (id))'
    );
    S.Add(CreateGenerator);
    S.Add(CreateInsertTrigger);
    S.Add(CreateInsertEditorTrigger(FieldByName('relationname').AsString));
    S.Add(CreateUpdateEditorTrigger(FieldByName('relationname').AsString));
  end;

  inherited;
end;

{ TgdcGenerator }

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
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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

  Result :=
    'FROM at_generators z ' +
    '  LEFT JOIN rdb$generators t ON z.generatorname = t.rdb$generator_name ';
    
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCGENERATOR', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCGENERATOR', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcGenerator.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'GENERATORNAME';
end;

class function TgdcGenerator.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'AT_GENERATORS';
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
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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
  //В поток сохраняем только генераторы-атрибуты
  if IsUserDefined then
  begin
    SaveToStreamDependencies(Stream, ObjectSet,
      FieldByName('generatorname').AsString, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
    inherited;
  end;
end;

class function TgdcGenerator.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgGenerator';
end;

procedure TgdcGenerator.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
begin
  case AMetadata of
    mdsCreate: S.Add('CREATE GENERATOR ' + FirebirdObjectName);
    mdsDrop: S.Add('DROP GENERATOR ' + FirebirdObjectName);
  end;
end;

{ TgdcCheckConstraint }

procedure TgdcCheckConstraint._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet; PropertyList: TgdcPropertySets;
  BindedList: TgdcObjectSet; WithDetailList: TgdKeyArray;
  const SaveDetailObjects: Boolean);
begin
  inherited;
  //В поток сохраняем только чеки-атрибуты
  if IsUserDefined then
  begin
    SaveToStreamDependencies(Stream, ObjectSet,
      FirebirdObjectName, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
    inherited;
  end;
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
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
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
  if HasSubSet('ByRelation') then
    S.Add('r.id = :relationkey');
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
     FieldByName('checkname').AsString := gdcBaseManager.AdjustMetaName(
       GetObjectNameByRelName(DataSet.FieldByName('relationname').AsString, '_CHK_'));
  FieldByName('RDB$TRIGGER_SOURCE').AsString := 'CHECK ()';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINDEX', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKCONSTRAINT', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

class function TgdcCheckConstraint.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgCheckConstraint';
end;

class function TgdcBaseTable.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgRelation';
end;

procedure TgdcCheckConstraint.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
begin
  case AMetadata of
    mdsCreate:
    begin
      if Assigned(FgdcDataLink) then
        with FgdcDataLink do
          if Active and (DataSet is TgdcRelation) then
            S.Add(Format('ALTER TABLE %s ADD CONSTRAINT %s %s',
             [DataSet.FieldByName('relationname').AsString,
              FieldByName('checkname').AsString, FieldByName('RDB$TRIGGER_SOURCE').AsString]))
      else
        S.Add(Format('ALTER TABLE %s ADD CONSTRAINT %s %s',
         [Trim(FieldByName('RDB$RELATION_NAME').AsString),
          FieldByName('checkname').AsString, FieldByName('RDB$TRIGGER_SOURCE').AsString]));
    end;

    mdsDrop: S.Add(Format('ALTER TABLE %s DROP CONSTRAINT %s',
      [FieldByName('RDB$RELATION_NAME').AsString, FieldByName('checkname').AsString]));

    mdsAlter:
    begin
      GetMetaDataScript(S, mdsDrop);
      GetMetaDataScript(S, mdsCreate);
    end;
  end;
end;

initialization
  RegisterGdcClass(TgdcMetaBase);
  RegisterGdcClass(TgdcField, 'Домен');
  RegisterGdcClass(TgdcRelation, 'Отношение');
  RegisterGdcClass(TgdcBaseTable, 'Таблица');
  RegisterGdcClass(TgdcTable);
  RegisterGdcClass(TgdcSimpleTable, 'Таблица с идентификатором и служебными полями');
  RegisterGdcClass(TgdcPrimeTable, 'Таблица с идентификатором');
  RegisterGdcClass(TgdcUnknownTable, 'Таблица');
  RegisterGdcClass(TgdcTableToTable, 'Таблица, связанная 1-к-1');
  RegisterGdcClass(TgdcInheritedTable, 'Наследованная таблица');
  RegisterGdcClass(TgdcTreeTable, 'Простое дерево');
  RegisterGdcClass(TgdcLBRBTreeTable, 'Интервальное дерево');
  RegisterGdcClass(TgdcView, 'Представление');
  RegisterGdcClass(TgdcRelationField, 'Поле');
  RegisterGdcClass(TgdcTableField);
  RegisterGdcClass(TgdcViewField);
  RegisterGdcClass(TgdcStoredProc, 'Процедура');
  RegisterGdcClass(TgdcException, 'Исключение');
  RegisterGdcClass(TgdcIndex, 'Индекс');
  RegisterGdcClass(TgdcTrigger, 'Триггер');
  RegisterGdcClass(TgdcDBTrigger, 'Триггер БД');
  RegisterGdcClass(TgdcGenerator, 'Генератор');
  RegisterGdcClass(TgdcCheckConstraint, 'Ограничение');

  for TrCount := 1 to MaxInvCardTrigger do
  begin
    InvCardTriggerImitate[TrCount] := False;
    InvCardTriggerDrop[TrCount] := False;
  end;

finalization
  UnregisterGdcClass(TgdcMetaBase);
  UnregisterGdcClass(TgdcField);
  UnregisterGdcClass(TgdcRelation);
  UnregisterGdcClass(TgdcTable);
  UnregisterGdcClass(TgdcBaseTable);
  UnregisterGdcClass(TgdcSimpleTable);
  UnregisterGdcClass(TgdcPrimeTable);
  UnregisterGdcClass(TgdcUnknownTable);
  UnregisterGdcClass(TgdcTableToTable);
  UnregisterGdcClass(TgdcInheritedTable);
  UnregisterGdcClass(TgdcTreeTable);
  UnregisterGdcClass(TgdcLBRBTreeTable);
  UnregisterGdcClass(TgdcView);
  UnregisterGdcClass(TgdcRelationField);
  UnregisterGdcClass(TgdcTableField);
  UnregisterGdcClass(TgdcViewField);
  UnregisterGdcClass(TgdcStoredProc);
  UnregisterGdcClass(TgdcException);
  UnregisterGdcClass(TgdcIndex);
  UnregisterGdcClass(TgdcTrigger);
  UnregisterGdcClass(TgdcDBTrigger);
  UnregisterGdcClass(TgdcGenerator);
  UnregisterGdcClass(TgdcCheckConstraint);
end.


