
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    at_classes_body.pas

  Abstract

    Classes that provide information
    about interbase database structure
    and structure of user defined tables and fields
    called attributes.

  Author

    Kireev Andrei  (06.11.2000)
    Denis Romanovskki

  Revisions history

    1.0    06.11.2000    Andreik    Initial version.
    2.0    23.01.2001    Denis      Structure changed. Complicated constraints
                                    added. Stream system added. All data is sorted.
    3.0    11.01.2002    Michael    Add ID.

--}


unit at_Classes_body;

interface

uses
  Classes,           Contnrs,           Comctrls,          SysUtils,
  IBDatabase,        DB,                IB,                IBHeader,
  Forms,             IBSQL,             gd_security_OperationConst,
  at_Classes;

const
  ATTR_FILE_NAME = 'g%s.atr';
  //Изменилась версия!!!
  _DATABASE_STREAM_VERSION = '1.6v';

type
  TIBString = String[31];

const
  DefFieldAlignment = faLeft;
  DefColWidth = -1;
  DefSecurity = -1;

type
  TatBodyRelationField = class;
  TatBodyRelationFields = class;
  TatBodyPrimaryKey = class;
  TatBodyForeignKey = class;
  TatBodyRelation = class;
  TatBodyDatabase = class;

  TatBodyField = class(TatField)
  private
    FDatabase: TatDatabase;

    procedure Read(Reader: TReader);
    procedure Write(Writer: TWriter);

    procedure MakeNumerationFromString(const aNumeration: String);
    function MakeStringFromNumeration: String;

    procedure UpdateData;
    function FindNumeration(const Value: String): Integer;
  protected
    function GetIsUserDefined: Boolean; override;
    function GetFieldType: TFieldType; override;
    function GetIsSystem: Boolean; override;

    procedure Clear;

    procedure LoadFromStream(S: TStream);
    procedure SaveToStream(S: TStream);


  public
    constructor Create(ADatabase: TatDatabase);


    procedure RefreshData; overload; override;
    procedure RefreshData(aDatabase: TIBDatabase; aTransaction: TIBTransaction); overload; override;
    procedure RefreshData(SQLRecord: TIBXSQLDA); overload; override;

    function GetNumerationName(const Value: String): String; override;
    function GetNumerationValue(const NameNumeration: String): String; override;


    procedure RecordAcquired; override;
  end;

  TatBodyFields = class(TatFields)
  private
    FList: TObjectList;
    FTreeNode: TTreeNode;
    FDatabase: TatDatabase;

    function Find(const S: string; var Index: Integer): Boolean;

    procedure Read(Reader: TReader);
    procedure Write(Writer: TWriter);

    procedure UpdateData;

  protected
    function GetCount: Integer; override;
    function GetItems(Index: Integer): TatField; override;

    procedure Clear;

    procedure LoadFromStream(S: TStream);
    procedure SaveToStream(S: TStream);

  public
    constructor Create(ADatabase: TatDatabase);
    destructor Destroy; override;

    procedure RefreshData; overload; override;
    procedure RefreshData(aDatabase: TIBDatabase; aTransaction: TIBTransaction); overload; override;

    function Add(atField: TatField): Integer; override;
    function ByFieldName(const AFieldName: String): TatField; override;
    function ByID(const AID: Integer): TatField; override;
    procedure Delete(const Index: Integer); override;
    function FindFirst(const AFieldName: String): TatField; override;
    function IndexOf(AObject: TObject): Integer; override;
  end;

  TatBodyRelation = class(TatRelation)
  private
    procedure Read(Reader: TReader);
    procedure Write(Writer: TWriter);

    procedure UpdateData;

  protected
    function GetIsUserDefined: Boolean; override;
    function GetIsSystem: Boolean; override;
    function GetHasSecurityDescriptors: Boolean; override;
    function GetListField: TatRelationField; override;
    function GetIsStandartTreeRelation: Boolean; override;
    function GetIsLBRBTreeRelation: Boolean; override;
//    function GetExtendedFields(Index: Integer): TatRelationField; override;
//    function GetExtendedFieldsCount: Integer; override;

    procedure Clear;

    procedure LoadFromStream(S: TStream);
    procedure SaveToStream(S: TStream);

    procedure RefreshFormat(aDatabase: TIBDatabase; aTransaction: TIBTransaction);

  public
    constructor Create(atDatabase: TatDatabase);
    destructor Destroy; override;

    procedure RefreshData(const IsRefreshFields: Boolean = False); overload; override;
    procedure RefreshData(SQLRecord: TIBXSQLDA; aDatabase: TIBDatabase;
      aTransaction: TIBTransaction; const IsRefreshFields: Boolean = False); overload; override;
    procedure RefreshData(aDatabase: TIBDatabase; aTransaction: TIBTransaction;
      const IsRefreshFields: Boolean = False); overload; override;

    procedure RefreshConstraints; overload; override;
    procedure RefreshConstraints(aDatabase: TIBDatabase; aTransaction: TIBTransaction); overload; override;

    procedure RecordAcquired; override;
  end;

  TatBodyRelations = class(TatRelations)
  private
    FList: TObjectList;
    FDatabase: TatDatabase;
    FUpdateList: TStringList; // Список объектов, которые нужно обновить

    function Find(const S: string; var Index: Integer): Boolean;

    procedure Read(Reader: TReader);
    procedure Write(Writer: TWriter);

    procedure UpdateData;

  protected
    function GetCount: Integer; override;
    function GetItems(Index: Integer): TatRelation; override;
    function GetTotalFieldCount: Integer;

    procedure Clear;

    procedure LoadFromStream(S: TStream);
    procedure SaveToStream(S: TStream);

  public
    constructor Create(atDatabase: TatDatabase);
    destructor Destroy; override;

    procedure RefreshData(const WithCommit: Boolean = True;
      const IsRefreshFields: Boolean = False); override;
    procedure RefreshData(aDatabase: TIBDatabase; aTransaction: TIBTransaction;
      const isRefreshFields: Boolean = False);
      overload; override;


    function Add(atRelation: TatRelation): Integer; override;
    procedure Delete(Index: Integer); override;
    function Remove(atRelation: TatRelation): Integer; override;

    function ByRelationName(const ARelationName: String): TatRelation; override;
    function ByID(const aID: Integer): TatRelation; override;
    function FindFirst(const ARelationName: String): TatRelation; override;

    procedure NotifyUpdateObject(const ARelationName: String); override;
    function IndexOf(AObject: TObject): Integer; override;

  end;

  TatBodyRelationField = class(TatRelationField)
  private
    FVisible: Boolean;

    procedure Read(Reader: TReader);
    procedure Write(Writer: TWriter);

    procedure UpdateData;

  protected
    function GetIsUserDefined: Boolean; override;
    function GetSQLType: Smallint; override;
    function GetReferenceListField: TatRelationField; override;
    //function GetIsSecurityDescriptor: Boolean; override;
    function GetVisible: Boolean; override;
    procedure SetFieldName(const AFieldName: String); override;

    procedure Clear;

    procedure LoadFromStream(S: TStream);
    procedure SaveToStream(S: TStream);

  public
    constructor Create(atRelation: TatRelation);
    destructor Destroy; override;

    procedure RefreshData; overload; override;
    procedure RefreshData(aDatabase: TIBDatabase; aTransaction: TIBTransaction); overload; override;
    procedure RefreshData(SQLRecord: TIBXSQLDA; aDatabase: TIBDatabase; aTransaction: TIBTransaction); overload; override;

    procedure RecordAcquired; override;

    function InObject(const AName: String): Boolean; override;
  end;

  TatBodyRelationFields = class(TatRelationFields)
  private
    FList: TObjectList;

    function Find(const S: string; var Index: Integer): Boolean;

    procedure Read(Reader: TReader);
    procedure Write(Writer: TWriter);
  protected
    function GetCount: Integer; override;
    function GetItems(Index: Integer): TatRelationField; override;

    procedure Clear;

    procedure LoadFromStream(S: TStream);
    procedure SaveToStream(S: TStream);

  public
    constructor Create(atRelation: TatRelation; const OwnObjects: Boolean = True);
    destructor Destroy; override;

    procedure RefreshData; overload; override;
    procedure RefreshData(aDatabase: TIBDatabase; aTransaction: TIBTransaction);
      overload; override;

    function Add(atRelationField: TatRelationField): Integer; override;
    function AddRelationField(const AFieldName: String): TatRelationField; override;
    function ByFieldName(const AName: String): TatRelationField; override;
    function ByID(const aID: Integer): TatRelationField; override;

    function ByPos(const APosition: Integer): TatRelationField; override;
    procedure Delete(const Index: Integer); override;
    function IndexOf(AObject: TObject): Integer; override;
  end;

  TatBodyForeignKey = class(TatForeignKey)
  private
    FDatabase: TatDatabase;

    procedure Read(Reader: TReader);
    procedure Write(Writer: TWriter);
  protected
    function GetConstraintField: TatRelationField; override;
    function GetReferencesField: TatRelationField; override;
    function GetIsSimpleKey: Boolean; override;

    procedure LoadFromStream(S: TStream);
    procedure SaveToStream(S: TStream);
  public
    constructor Create(ADatabase: TatDatabase);
    destructor Destroy; override;

    procedure RefreshData; overload; override;
    procedure RefreshData(ibsql: TIBSQL); overload; override;
    procedure RefreshData(aDatabase: TIBDatabase; aTransaction: TIBTransaction); overload; override;
  end;

  TatBodyForeignKeys = class(TatForeignKeys)
  private
    FDatabase: TatDatabase;

    FList: TObjectList;

    procedure Read(Reader: TReader);
    procedure Write(Writer: TWriter);

  protected
    function GetCount: Integer; override;
    function GetItems(Index: Integer): TatForeignKey; override;
    function Find(const S: string; var Index: Integer): Boolean; override;

    procedure Clear;

    procedure LoadFromStream(S: TStream);
    procedure SaveToStream(S: TStream);

  public
    constructor Create(ADatabase: TatDatabase);
    destructor Destroy; override;

    function Add(atForeignKey: TatForeignKey): Integer; override;
    procedure Delete(const Index: Integer); override;
    function ByConstraintName(AConstraintName: String): TatForeignKey; override;

{ TODO : вернет только первый! а остальные? }
    function ByRelationAndReferencedRelation(const ARelationName,
      AReferencedRelationName: String): TatForeignKey; override;

    // возвращает список фореин-кеев для заданной таблицы
    // ссылающихся на другие таблицы
    procedure ConstraintsByRelation(const RelationName: String;
      List: TObjectList); override;
    // возвращает список фореин-кеев, ссылающихся на заданную
    // таблицу
    procedure ConstraintsByReferencedRelation(const RelationName: String;
      List: TObjectList; const ClearList: Boolean = True); override;

    function IndexOf(AObject: TObject): Integer; override;
  end;

  TatBodyPrimaryKey = class(TatPrimaryKey)
  private
    FDatabase: TatDatabase;

    procedure Read(Reader: TReader);
    procedure Write(Writer: TWriter);
  protected
    procedure LoadFromStream(S: TStream);
    procedure SaveToStream(S: TStream);

  public
    constructor Create(ADatabase: TatDatabase);
    destructor Destroy; override;

    procedure RefreshData; overload; override;
    procedure RefreshData(ibsql: TIBSQL); overload; override;
    procedure RefreshData(aDatabase: TIBDatabase; aTransaction: TIBTransaction); overload; override;
  end;

  TatBodyPrimaryKeys = class(TatPrimaryKeys)
  private
    FDatabase: TatDatabase;
    FList: TObjectList;

    function Find(const S: string; var Index: Integer): Boolean;

    procedure Read(Reader: TReader);
    procedure Write(Writer: TWriter);
  protected
    function GetCount: Integer; override;
    function GetItems(Index: Integer): TatPrimaryKey; override;

    procedure Clear;

    procedure LoadFromStream(S: TStream);
    procedure SaveToStream(S: TStream);

    procedure CollectRelationConstraints(const RelationName: String;
      List: TObjectList);

  public
    constructor Create(ADatabase: TatDatabase);
    destructor Destroy; override;

    function Add(atPrimaryKey: TatPrimaryKey): Integer; override;
    procedure Delete(const Index: Integer); override;
    function ByConstraintName(AConstraintName: String): TatPrimaryKey; override;

    function IndexOf(AObject: TObject): Integer; override;
  end;

  TatBodyDatabase = class(TatDatabase)
  private
    FAttrVersion: Integer;
    FTreeNexus: TForm;
    FLastRefresh: TDateTime;
    FFileName: String;

    procedure Read(Reader: TReader);
    procedure Write(Writer: TWriter);

  protected
    function GetReadOnly: Boolean; override;
    procedure SetDatabase(Value: TIBDatabase); override;
    procedure SetTransaction(Value: TIBTransaction); override;

    function IsDatabaseDataRequired: Boolean;

    procedure Clear;

    // по-умолчанию, перед считывание структуры из базы мы синхронизируем
    // наши сведения о структуре с реальной структурой мета-данных
    procedure LoadFromDatabase(const Synchronize: Boolean = True);

    procedure LoadFromStream(S: TStream);
    procedure SaveToStream(S: TStream);

    procedure KillGarbage;

  public
    constructor Create;
    destructor Destroy; override;

    procedure ProceedLoading(Force: Boolean = False); override;
    procedure ForceLoadFromDatabase; override;

    function FindRelationField(const ARelationName, ARelationFieldName: String): TatRelationField; override;

    procedure NotifyMultiConnectionTransaction; override;
    procedure CancelMultiConnectionTransaction(const All: Boolean = False); override;

    function StartMultiConnectionTransaction: Boolean; override;
    procedure CheckMultiConnectionTransaction; override;

    procedure SyncIndicesAndTriggers(ATransaction: TIBTransaction); override;
  end;

  EatDatabaseError = class(Exception);

procedure InitDatabase(IBDatabase: TIBDatabase; IBTransaction: TIBTransaction);

procedure GetTableName(DS: TDataSet; const FieldName: String; out AliasName, TableName: String);
//procedure LocalizeDataSet(DS: TDataSet);

function UpdateIBName(const IBName: String): String;

function RelationTypeToChar(const ARelationType: TatRelationType): String;
//function StringToRelationType(const Name: String): TatRelationType;

implementation

uses
  Windows,           JclSysUtils,       Graphics,          Messages,
  gd_resourcestring, IBCustomDataset,   gdcBase,           ZLib,
  IBStoredProc,      JclStrings,        gd_security,       at_sql_setup,
  gd_directories_const,                 at_sql_metadata,
  IBUtils,           gd_splash,         at_frmIBUserList,  iberrorcodes,
  dmDatabase_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  WM_STARTMULTITRANSACTION = WM_USER + 12653;
  WM_LOGOFF                = WM_USER + 12654;

procedure GetTableName(DS: TDataSet; const FieldName: String; out AliasName, TableName: String);
var
  IBXSQLVAR: TIBXSQLVAR;
begin
  AliasName := FieldName;
  TableName := '';

  //исправлено,т.к. не проходила локализация для TIBQuery
  //if DS is TIBDataSet then
  if DS is TIBCustomDataSet then
  begin
    IBXSQLVAR := TIBCustomDataSet(DS).Current.ByName(FieldName);

    if IBXSQLVAR <> nil then
    begin
      TableName := StrPas(IBXSQLVAR.AsXSQLVAR.relname);
      AliasName := StrPas(IBXSQLVAR.AsXSQLVAR.aliasname)
    end;
  end;
end;

(*
procedure LocalizeDataSet(DS: TDataSet);
var
  I: Integer;
  R: TatRelation;
  F: TatRelationField;
  FN, TN: String;
begin
  Assert(Assigned(DS));
  Assert(atDatabase.Loaded);

  for I := 0 to DS.FieldCount - 1 do
  begin
    GetTableName(DS, DS.Fields[I].FieldName, FN, TN);

    R := atDatabase.Relations.ByRelationName(TN);
    if R <> nil then
      F := R.RelationFields.ByFieldName(FN)
    else
      F := nil;
      {F := atDatabase.Relations.ByRelationName('GEDEMINGLOBALNAMESPACE').RelationFields.ByFieldName(FN);}

    if F <> nil then
    begin
      DS.Fields[I].DisplayLabel := F.LName;
      DS.Fields[I].Visible := F.Visible;
      DS.Fields[I].DisplayWidth := F.ColWidth;
      if (DS.Fields[I] is TNumericField) then
        (DS.Fields[I] as TNumericField).DisplayFormat := F.FormatString;
      if (DS.Fields[I] is TDateTimeField) then
        (DS.Fields[I] as TDateTimeField).DisplayFormat := F.FormatString;
    end;
  end;
end;
*)

// Доводит длину имени до 31 символа
function UpdateIBName(const IBName: String): String;
var
  I: Integer;
begin
  Result := IBName;
  SetLength(Result, 31);
  for I := Length(IBName) + 1 to 31 do
    Result[I] := ' ';
end;

function RelationTypeToChar(const ARelationType: TatRelationType): String;
begin
  case ARelationType of
    rtTable: Result := 'T';
    rtView: Result := 'V';
  else
    raise EatDatabaseError.Create('This relation type is not supported!');
  end;
end;

procedure InitDatabase(IBDatabase: TIBDatabase; IBTransaction: TIBTransaction);
begin
  if not Assigned(atDatabase) then
    atDatabase := TatBodyDatabase.Create;

  atDatabase.Database := IBDatabase;
  atDatabase.Transaction := IBTransaction;
  atDatabase.Dialect := IBDatabase.SQLDialect;
end;

function ReadField(F: TIBXSQLVAR; const Default: String): String; overload;
begin
  if F.IsNull then
    Result := Default
  else
    Result := F.AsString;
end;

function ReadField(F: TIBXSQLVAR; const Default: Integer): Integer; overload;
begin
  if F.IsNull then
    Result := Default
  else
    Result := F.AsInteger;
end;

{ TatRelation }

constructor TatBodyRelation.Create;
begin
  inherited Create;

  FRelationFields := TatBodyRelationFields.Create(Self);
  Clear;
  FDatabase := atDatabase;
end;

destructor TatBodyRelation.Destroy;
begin
  FRelationFields.Free;
  inherited;
end;

procedure TatBodyRelation.RefreshData(aDatabase: TIBDatabase;
  aTransaction: TIBTransaction; const IsRefreshFields: Boolean = False);
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);

  try
    ibsql.Database := aDatabase;
    ibsql.Transaction := aTransaction;

    if not ibsql.Transaction.InTransaction then
      ibsql.Transaction.StartTransaction;

    ibsql.Sql.Text :=
      'SELECT '#13#10 +
      '  R.*, A.* '#13#10 +
      'FROM '#13#10 +
      '  AT_RELATIONS A LEFT JOIN RDB$RELATIONS R '#13#10 +
      '    ON R.RDB$RELATION_NAME = A.RELATIONNAME '#13#10 +
      'WHERE '#13#10 +
      '  ((R.RDB$SYSTEM_FLAG = 0) OR (R.RDB$SYSTEM_FLAG IS NULL)) AND '#13#10 +
      '  A.RELATIONNAME = :RN'#13#10 +
      'ORDER BY '#13#10 +
      '  A.LNAME, A.RELATIONNAME ';
    ibsql.ParamByName('RN').AsString := UpdateIBName(FRelationName);

    ibsql.ExecQuery;

    if ibsql.RecordCount > 0 then
      RefreshData(ibsql.Current, aDatabase, aTransaction, isRefreshFields)
    else
      raise EatDatabaseError.CreateFmt(
        'Relation %s not found in AT_RELATIONS table!', [FRelationName]);

    ibsql.Close;
  finally
    ibsql.Free;
  end;

end;

procedure TatBodyRelation.RefreshData(const IsRefreshFields: Boolean = False);
begin
  try
    RefreshData(FDatabase.Database, FDatabase.Transaction, isRefreshFields);

    if FDatabase.Transaction.Active then
      FDatabase.Transaction.Commit;

  finally
    if FDatabase.Transaction.Active then
      FDatabase.Transaction.RollBack;
  end;
end;

procedure TatBodyRelation.RefreshData(SQLRecord: TIBXSQLDA; aDatabase: TIBDatabase;
  aTransaction: TIBTransaction; const IsRefreshFields: Boolean = False);
begin
  if (AnsiCompareText(SQLRecord.ByName('relationname').AsTrimString,
    FRelationName) <> 0) and
    (AnsiCompareText(SQLRecord.ByName('rdb$relation_name').AsTrimString,
    FRelationName) <> 0)
  then
    raise EatDatabaseError.Create('Can''t refresh relation: incorrect relation name!');

  FLName := TrimRight(SQLRecord.ByName('lname').AsString);
  FLShortName := TrimRight(SQLRecord.ByName('lshortname').AsString);
  FDescription := TrimRight(SQLRecord.ByName('description').AsString);

  FaFull := SQLRecord.ByName('afull').AsInteger;
  FaChag := SQLRecord.ByName('achag').AsInteger;
  FaView := SQLRecord.ByName('aview').AsInteger;
  FListField := SQLRecord.ByName('listfield').AsString;
  FExtendedFields := SQLRecord.ByName('extendedfields').AsString;

  FID := SQLRecord.ByName('id').AsInteger;

  FHasRecord := not SQLRecord.ByName('relationname').IsNull;

  FRelationFormat := SQLRecord.ByName('rdb$format').AsInteger;
  FRelationID := SQLRecord.ByName('rdb$relation_id').AsInteger;
  FBranchKey := SQLRecord.ByName('branchkey'). AsInteger;

  if SQLRecord.ByName('rdb$view_blr').IsNull then
    FRelationType := rtTable
  else
    FRelationType := rtView;

  if IsRefreshFields then
    FRelationFields.RefreshData(aDatabase, aTransaction);
  UpdateData;
end;

procedure TatBodyRelation.RefreshConstraints(aDatabase: TIBDatabase;
  aTransaction: TIBTransaction);
var
  ibsql: TIBSQL;
  ForKey: TatForeignKey;
  PrimKey: TatPrimaryKey;
  List: TObjectList;
  I: Integer;
begin
  //без полей не может быть создан ни один констрэйнт
  if RelationFields.Count = 0 then
    Exit;

  ibsql := TIBSQL.Create(nil);
  List := TObjectList.Create(False);

  try
    ibsql.Database := aDatabase;
    ibsql.Transaction := aTransaction;

    if not ibsql.Transaction.InTransaction then
      ibsql.Transaction.StartTransaction;

    ibsql.SQL.Text :=
      'SELECT '#13#10 +
      '  RC.RDB$RELATION_NAME AS RELATIONNAME, '#13#10 +
      '  RC.RDB$CONSTRAINT_NAME AS CONSTRAINTNAME, '#13#10 +
      '  RC.RDB$INDEX_NAME AS INDEXNAME, '#13#10 +
      '  INDSEG.RDB$FIELD_NAME AS FIELDNAME, '#13#10 +
      '  INDSEG.RDB$FIELD_POSITION AS FIELDPOS, '#13#10 +
      '  REFC.RDB$CONST_NAME_UQ AS FCONSTRAINT, '#13#10 +
      '  RC2.RDB$RELATION_NAME AS FRELATIONNAME, '#13#10 +
      '  RC2.RDB$INDEX_NAME AS FINDEXNAME, '#13#10 +
      '  INDSEG2.RDB$FIELD_NAME AS FFIELDNAME'#13#10 +
      ' '#13#10 +
      'FROM '#13#10 +
      '  RDB$RELATION_CONSTRAINTS RC '#13#10 +
      '    JOIN '#13#10 +
      '      RDB$INDEX_SEGMENTS INDSEG '#13#10 +
      '    ON '#13#10 +
      '      RC.RDB$INDEX_NAME = INDSEG.RDB$INDEX_NAME '#13#10 +
      '    JOIN '#13#10 +
      '      RDB$REF_CONSTRAINTS REFC '#13#10 +
      '    ON '#13#10 +
      '      REFC.RDB$CONSTRAINT_NAME = RC.RDB$CONSTRAINT_NAME, '#13#10 +
      '       '#13#10 +
      '  RDB$RELATION_CONSTRAINTS RC2 '#13#10 +
      '    JOIN '#13#10 +
      '      RDB$INDEX_SEGMENTS INDSEG2 '#13#10 +
      '    ON '#13#10 +
      '      RC2.RDB$INDEX_NAME = INDSEG2.RDB$INDEX_NAME '#13#10 +
      ' '#13#10 +
      'WHERE '#13#10 +
      '  RC2.RDB$CONSTRAINT_NAME = REFC.RDB$CONST_NAME_UQ '#13#10 +
      '    AND '#13#10 +
      '  INDSEG.RDB$FIELD_POSITION = INDSEG2.RDB$FIELD_POSITION '#13#10 +
      '    AND '#13#10 +
      '  RC.RDB$RELATION_NAME = :RN '#13#10 +
      ' '#13#10 +
      'ORDER BY '#13#10 +
      '  RC.RDB$CONSTRAINT_NAME, '#13#10 +
      '  INDSEG.RDB$FIELD_POSITION '#13#10 +
      ' '#13#10;
    ibsql.ParamByName('RN').AsString := UpdateIBName(FRelationName);
    ibsql.ExecQuery;

    TatBodyDatabase(FDatabase).FForeignKeys.ConstraintsByRelation(FRelationName, List);

    while (not ibsql.Eof) do
    begin
      ForKey := TatBodyDatabase(FDatabase).FForeignKeys.ByConstraintName(
        ibsql.FieldByName('CONSTRAINTNAME').AsTrimString);

      if not Assigned(ForKey) then
      begin
        ForKey := TatBodyForeignKey.Create(FDatabase);
        TatBodyForeignKey(ForKey).FConstraintName :=
          ibsql.FieldByName('CONSTRAINTNAME').AsTrimString;

        TatBodyDatabase(FDatabase).FForeignKeys.Add(ForKey);
      end;

      ForKey.RefreshData(ibsql);

      if List.IndexOf(ForKey) <> -1 then
        List.Remove(ForKey);

      if (ForKey.ConstraintFields.Count = 0) and
        (TatBodyDatabase(FDatabase).FForeignKeys.IndexOf(ForKey) > -1) then
        TatBodyDatabase(FDatabase).FForeignKeys.Delete(TatBodyDatabase(FDatabase).FForeignKeys.IndexOf(ForKey));
    end;

    ibsql.Close;

    for I := 0 to List.Count - 1 do
    begin
      (List[I] as TatBodyForeignKey).FIsDropped := True;
      Inc(TatBodyDatabase(FDatabase).FGarbageCount);
    end;

    List.Clear;

    ibsql.SQL.Text :=
      'SELECT '#13#10 +
      '  RC.RDB$RELATION_NAME, '#13#10 +
      '  RC.RDB$CONSTRAINT_NAME, '#13#10 +
      '  RC.RDB$INDEX_NAME, '#13#10 +
      '  INDSEG.RDB$FIELD_NAME, '#13#10 +
      '  INDSEG.RDB$FIELD_POSITION '#13#10 +
      ' '#13#10 +
      'FROM '#13#10 +
      '  RDB$RELATION_CONSTRAINTS RC '#13#10 +
      '    JOIN '#13#10 +
      '      RDB$INDEX_SEGMENTS INDSEG '#13#10 +
      '    ON '#13#10 +
      '      RC.RDB$INDEX_NAME = INDSEG.RDB$INDEX_NAME '#13#10 +
      ' '#13#10 +
      'WHERE '#13#10 +
      '  RC.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' '#13#10 +
      '    AND '#13#10 +
      '  RC.RDB$RELATION_NAME = :RN '#13#10 +
      ' '#13#10 +
      'ORDER BY '#13#10 +
      '  INDSEG.RDB$FIELD_POSITION ';
    ibsql.ParamByName('RN').AsString := UpdateIBName(FRelationName);
    TatBodyPrimaryKeys(TatBodyDatabase(FDatabase).FPrimaryKeys).CollectRelationConstraints(FRelationName, List);

    ibsql.ExecQuery;

    while (not ibsql.Eof) do
    begin
      PrimKey := TatBodyDatabase(FDatabase).FPrimaryKeys.ByConstraintName(
        ibsql.FieldByName('RDB$CONSTRAINT_NAME').AsTrimString);

      if not Assigned(PrimKey) then
      begin
        PrimKey := TatBodyPrimaryKey.Create(FDatabase);
        TatBodyPrimaryKey(PrimKey).FConstraintName :=
          ibsql.FieldByName('RDB$CONSTRAINT_NAME').AsTrimString;
        TatBodyDatabase(FDatabase).FPrimaryKeys.Add(PrimKey);
      end;

      PrimKey.RefreshData(ibsql);
      if List.IndexOf(PrimKey) <> -1 then
        List.Remove(PrimKey);

      if (PrimKey.ConstraintFields.Count = 0) and
        (TatBodyDatabase(FDatabase).FPrimaryKeys.IndexOf(PrimKey) > -1) then
        TatBodyDatabase(FDatabase).FPrimaryKeys.Delete(TatBodyDatabase(FDatabase).FPrimaryKeys.IndexOf(PrimKey))
    end;

    ibsql.Close;

    for I := 0 to List.Count - 1 do
    begin
      (List[I] as TatBodyPrimaryKey).FIsDropped := True;
      Inc(TatBodyDatabase(FDatabase).FGarbageCount);
    end;

  finally
    ibsql.Free;
    List.Free;
  end;
end;

procedure TatBodyRelation.RefreshConstraints;
begin
  try
    RefreshConstraints(FDatabase.Database, FDatabase.Transaction);

    FDatabase.Transaction.Commit;

  finally
    if FDatabase.Transaction.Active then
      FDatabase.Transaction.RollBack;
  end;
end;

procedure TatBodyRelation.RecordAcquired;
var
  ibsql: TIBSQL;
begin
  //if FRelationType = rtGedeminGlobalNamespace then Exit;

  Assert(not FHasRecord);
  ibsql := TIBSQL.Create(nil);

  try
    ibsql.Database := FDatabase.Database;
    ibsql.Transaction := FDatabase.Transaction;
    FDatabase.Transaction.Active := True;

    ibsql.SQl.Text := Format(
      'INSERT INTO at_relations (RELATIONNAME, LNAME, LSHORTNAME, DESCRIPTION, ' +
      'RELATIONTYPE, AFULL, ACHAG, AVIEW) VALUES ' +
      '(''%0:s'', ''%0:s'', ''%0:s'', ''%0:s'', ''%1:s'', -1, -1, -1) ',
      [
        UpdateIBName(FRelationName),
        RelationTypeToChar(FRelationType)
      ]
    );

    ibsql.ParamCheck := True;
    ibsql.ExecQuery;
    ibsql.Close;

    FDatabase.Transaction.Commit;
    FHasRecord := True;
  finally
    ibsql.Free;
    if FDatabase.Transaction.Active then
      FDatabase.Transaction.RollBack;
  end;
end;

function TatBodyRelation.GetIsSystem: Boolean;
begin
  // мы проверяем на наличие префикса в имени, а не
  // на то начинается имя с такого префикса или нет
  // преднамеренно. Мы еще не определились будем ли мы
  // хранить имена идентификаторов с кавычками или без
  Result := AnsiPos(SystemPrefix, AnsiUpperCase(FRelationName)) > 0;
end;

function TatBodyRelation.GetIsUserDefined: Boolean;
begin
  // см. комментарий к ГетИзСыстем
  Result := AnsiPos(UserPrefix, AnsiUpperCase(FRelationName)) > 0;
end;

function TatBodyRelation.GetListField: TatRelationField;
var
  I: Integer;
  SL: TStringList;
begin
  Result := RelationFields.ByFieldName(FListField);
  if Result = nil then
     // По умолчанию name
     Result := RelationFields.ByFieldName('name')
  else
    Exit;

  //Для пользовательских таблиц поле usr$name
  if Result = nil then
    Result := RelationFields.ByFieldName('usr$name');

  if Result = nil then
  begin
    if FExtendedFields > '' then
    begin
      SL := TStringList.Create;
      try
        SL.CommaText := StringReplace(FExtendedFields, ';', ',', [rfReplaceAll]);
        for I := 0 to SL.Count - 1 do
        begin
          Result := RelationFields.ByFieldName(SL[I]);
          if Result <> nil then
            exit;
        end;
      finally
        SL.Free;
      end;
    end;

    // Если такого поля нет, то первое текстовое поле, обязательное для заполнения
    if Result = nil then
    begin
      for I := 0 to RelationFields.Count - 1 do
      begin
        if RelationFields[I] <> nil then
        begin
          if (RelationFields[I].SQLType in [blr_text, blr_text2, blr_varying, blr_varying2,
            blr_cstring, blr_cstring2]) and (not RelationFields[I].IsNullable) then
          begin
            if (Result = nil) or (RelationFields[I].FieldPosition < Result.FieldPosition) then
            begin
              Result := RelationFields[I];
            end;
          end;
        end;
      end;
    end;

    // Если такого поля нет, то первое текстовое поле
    if Result = nil then
    begin
      for I := 0 to RelationFields.Count - 1 do
      begin
        if RelationFields[I] <> nil then
        begin
          if RelationFields[I].SQLType in [blr_text, blr_text2, blr_varying, blr_varying2,
            blr_cstring, blr_cstring2] then
          begin
            if (Result = nil) or (RelationFields[I].FieldPosition < Result.FieldPosition) then
            begin
              Result := RelationFields[I];
            end;
          end;
        end;
      end;
    end;

    // Если нет, то первое поле
    if (Result = nil) and (RelationFields.Count > 0) then
      Result := RelationFields[0];
  end;
end;

procedure TatBodyRelation.LoadFromStream(S: TStream);
var
  Reader: TReader;
begin
  Clear;

  Reader := TReader.Create(S, 1024);
  try
    Read(Reader);
  finally
    Reader.Free;
  end;
end;

procedure TatBodyRelation.SaveToStream(S: TStream);
var
  Writer: TWriter;
begin
  Writer := TWriter.Create(S, 1024);
  try
    Write(Writer);
  finally
    Writer.Free;
  end;
end;

procedure TatBodyRelation.RefreshFormat(aDatabase: TIBDatabase; aTransaction: TIBTransaction);
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);

  try
    ibsql.Database := aDatabase;
    ibsql.Transaction := aTransaction;
    if not ibsql.Transaction.InTransaction then
      ibsql.Transaction.StartTransaction;

    ibsql.Sql.Text :=  'SELECT '#13#10 +
      '  r.rdb$format '#13#10 +
      'FROM '#13#10 +
      '  at_relations a LEFT JOIN ' +
      '  rdb$relations r ON a.relationname = r.rdb$relation_name '#13#10 +
      'WHERE '#13#10 +
      '  a.relationname = :relationname';

    ibsql.ParamByName('relationname').AsString := UpdateIBName(FRelationName);
    ibsql.ExecQuery;

    if ibsql.RecordCount > 0 then
      FRelationFormat := ibsql.FieldByName('RDB$FORMAT').AsInteger
    else
      raise EatDatabaseError.CreateFmt(
        'Relation %s not found in AT_RELATIONS table!', [FRelationName]);

    ibsql.Close;
  finally
    ibsql.Free;

  end;
end;

procedure TatBodyRelation.Clear;
begin
  FRelationName := '';
  FLName := '';
  FLShortName := '';
  FDescription := '';

  FTreeNode := nil;
  FHasRecord := False;
  TatBodyRelationFields(FRelationFields).Clear;

  FaFull := -1;
  FaChag := -1;
  FaView := -1;

  FRelationType := rtTable;

  FIsDropped := False;

  FRelationFormat := -1;
  FRelationID := -1;

  FListField := '';
  FExtendedFields := '';
end;

procedure TatBodyRelation.Read(Reader: TReader);
begin
  with Reader do
  begin
    FRelationName := ReadString;
    FLName := ReadString;
    FLShortName := ReadString;
    FDescription := ReadString;

    FHasRecord := ReadBoolean;

    FRelationFormat := ReadInteger;
    FRelationID := ReadInteger;

    FaFull := ReadInteger;
    FaChag := ReadInteger;
    FaView := ReadInteger;

    Read(FRelationType, SizeOf(TatRelationType));

    TatBodyRelationFields(FRelationFields).Read(Reader);
    FID := ReadInteger;

    //FIsCreateCommand := ReadInteger;
    FBranchKey := ReadInteger;
    //С версии 1.2v
    FListField := ReadString;
    FExtendedFields := ReadString;
  end;
end;

procedure TatBodyRelation.Write(Writer: TWriter);
begin
  with Writer do
  begin
    WriteString(FRelationName);
    WriteString(FLName);
    WriteString(FLShortName);
    WriteString(FDescription);

    WriteBoolean(FHasRecord);

    WriteInteger(FRelationFormat);
    WriteInteger(FRelationID);

    WriteInteger(FaFull);
    WriteInteger(FaChag);
    WriteInteger(FaView);

    Write(FRelationType, SizeOf(TatRelationType));

    TatBodyRelationFields(FRelationFields).Write(Writer);
    WriteInteger(FID);
//    WriteInteger(FIsCreateCommand);
    WriteInteger(FBranchKey);
    //С версии 1.2v
    WriteString(FListField);
    WriteString(FExtendedFields);
  end;
end;

procedure TatBodyRelation.UpdateData;
var
  I: Integer;
begin
  for I := 0 to FRelationFields.Count - 1 do
    TatBodyRelationField(FRelationFields[I]).UpdateData;
end;

function TatBodyRelation.GetIsStandartTreeRelation: Boolean;
begin
  Result :=
    Assigned(FRelationFields.ByFieldName('ID'))
      and
    Assigned(FRelationFields.ByFieldName('PARENT'));
end;

function TatBodyRelation.GetIsLBRBTreeRelation: Boolean;
begin
  Result :=
    Assigned(FRelationFields.ByFieldName('ID'))
      and
    Assigned(FRelationFields.ByFieldName('PARENT'))
      and
    Assigned(FRelationFields.ByFieldName('LB'))
      and
    Assigned(FRelationFields.ByFieldName('RB'))
    ;
end;

{ TatBodyRelations }

function TatBodyRelations.Add(atRelation: TatRelation): Integer;
begin
  if not Assigned(atRelation) then Exit;

  if atRelation.RelationName = '' then
    raise EatDatabaseError.Create('Can''t add an empty relation!');

  Find(atRelation.RelationName, Result);
  FList.Insert(Result, atRelation);
end;

constructor TatBodyRelations.Create;
begin
  inherited Create;

  FList := TObjectList.Create;
  FDatabase := atDatabase;
  FUpdateList := TStringList.Create;

  Clear;
end;

procedure TatBodyRelations.Delete(Index: Integer);
begin
  FList.Delete(Index);
end;

destructor TatBodyRelations.Destroy;
begin
  FUpdateList.Free;
  FList.Free;

  inherited;
end;

function TatBodyRelations.ByRelationName(const ARelationName: String): TatRelation;
var
  I: Integer;
begin
  if Find(ExtractIdentifier(FDatabase.Dialect, ARelationName), I) then
    Result := Items[I]
  else
    Result := nil;
end;

function TatBodyRelations.GetCount: Integer;
begin
  TatBodyDatabase(FDatabase).KillGarbage;
  Result := FList.Count;
end;

function TatBodyRelations.GetItems(Index: Integer): TatRelation;
begin
  Result := FList[Index] as TatRelation;
end;

function TatBodyRelations.Find(const S: string; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  if S = '' then
    exit;
  L := 0;
  H := FList.Count - 1;

  while L <= H do
  begin
    I := (L + H) shr 1;
    C := AnsiCompareText((FList[I] as TatRelation).RelationName, S);

    if C < 0 then
      L := I + 1
    else begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
        L := I;
      end;
    end;
  end;

  Index := L;
end;

procedure TatBodyRelations.RefreshData(aDatabase: TIBDatabase;
  aTransaction: TIBTransaction; const isRefreshFields: Boolean = False);
var
  ibsql: TIBSQL;
  Relation: TatRelation;
begin
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Database := aDatabase;
    ibsql.Transaction := aTransaction;
    if not aTransaction.InTransaction then
      aTransaction.Active := True;

    ibsql.SQL.Text :=
      'SELECT '#13#10 +
      '  R.*, A.* '#13#10 +
      'FROM '#13#10 +
      '   AT_RELATIONS A LEFT JOIN RDB$RELATIONS R '#13#10 +
      '    ON R.RDB$RELATION_NAME = A.RELATIONNAME '#13#10 +
      'WHERE '#13#10 +
      '  (R.RDB$SYSTEM_FLAG = 0) OR (R.RDB$SYSTEM_FLAG IS NULL) '#13#10 +
      'ORDER BY '#13#10 +
      '  A.LNAME, A.RELATIONNAME ';

    ibsql.ExecQuery;

    while not ibsql.EOF do
    begin
      Relation := ByRelationName(
        ibsql.FieldByName('RELATIONNAME').AsTrimString);

      if Assigned(Relation) then
        Relation.RefreshData(ibsql.Current, aDatabase, aTransaction)
      else begin
        Relation := TatBodyRelation.Create(FDatabase);
        try
          TatBodyRelation(Relation).FRelationName := ibsql.FieldByName('RELATIONNAME').AsTrimString;
          Relation.RefreshData(ibsql.Current, aDatabase, aTransaction, isRefreshFields);
          Add(Relation);
        except
          Relation.Free;
          raise;
        end;
      end;

      ibsql.Next;
    end;

    ibsql.Close;
  finally
    ibsql.Free;
  end;
end;

procedure TatBodyRelations.RefreshData(const WithCommit: Boolean = True; const IsRefreshFields: Boolean = False);
begin
  try
    RefreshData(FDatabase.Database, FDatabase.Transaction);
    if WithCommit then
      FDatabase.Transaction.Commit;
  finally
    if WithCommit and FDatabase.Transaction.Active then
      FDatabase.Transaction.RollBack;
  end;
end;

function TatBodyRelations.Remove(atRelation: TatRelation): Integer;
begin
  Result := FList.IndexOf(atRelation);
  FList.Delete(Result);
end;

procedure TatBodyRelations.Clear;
begin
  FList.Clear;
  FTreeNode := nil;
end;

procedure TatBodyRelations.LoadFromStream(S: TStream);
var
  Reader: TReader;
begin
  Clear;

  Reader := TReader.Create(S, 1024);
  try
    Read(Reader);
  finally
    Reader.Free;
  end;
end;

procedure TatBodyRelations.SaveToStream(S: TStream);
var
  Writer: TWriter;
begin
  Writer := TWriter.Create(S, 1024);
  try
    Write(Writer);
  finally
    Writer.Free;
  end;
end;

function TatBodyRelations.FindFirst(const ARelationName: String): TatRelation;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    if
      (
        (AnsiPos(ARelationName, AnsiUpperCase(Items[I].RelationName)) > 0)
          or
        (AnsiPos(ARelationName, AnsiUpperCase(Items[I].LName)) > 0)
      )
    then begin
      Result := Items[I];
      exit;
    end;
end;

procedure TatBodyRelations.Read(Reader: TReader);
var
  NewRelation: TatRelation;
begin
  with Reader do
  begin
    ReadListBegin;

    while not EndOfList do
    begin
      NewRelation := TatBodyRelation.Create(FDatabase);
      TatBodyRelation(NewRelation).Read(Reader);
      FList.Add(NewRelation);
    end;

    ReadListEnd;
  end;
end;

procedure TatBodyRelations.Write(Writer: TWriter);
var
  I: Integer;
begin
  with Writer do
  begin
    WriteListBegin;

    for I := 0 to Count - 1 do
      TatBodyRelation(Items[I]).Write(Writer);

    WriteListEnd;
  end;
end;

function TatBodyRelations.GetTotalFieldCount: Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 0 to Count - 1 do
    Inc(Result, Items[I].RelationFields.Count);
end;

procedure TatBodyRelations.UpdateData;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    TatBodyRelation(Items[I]).UpdateData;
end;

procedure TatBodyRelations.NotifyUpdateObject(const ARelationName: String);
begin
  FUpdateList.Add(ARelationName);
end;

function TatBodyRelations.ByID(const aID: Integer): TatRelation;
var
  i: Integer;
begin
  Result := nil;
  for i:= 0 to FList.Count - 1 do
    if (FList[i] as TatRelation).ID = AID then
    begin
      Result := FList[i] as TatRelation;
      Break;
    end;
end;

function TatBodyRelations.IndexOf(AObject: TObject): Integer;
begin
  Result := FList.IndexOf(AObject);
end;

{ TatBodyRelationFields }

function TatBodyRelationFields.Add(atRelationField: TatRelationField): Integer;
begin
  if not Assigned(atRelationField) then Exit;
  if FSorted then
  begin
    Find(atRelationField.FieldName, Result);
    FList.Insert(Result, atRelationField);
  end else
  begin
    FList.Add(atRelationField);
  end;
end;

function TatBodyRelationFields.AddRelationField(
  const AFieldName: String): TatRelationField;
begin
  Result := TatBodyRelationField.Create(FRelation);
  TatBodyRelationField(Result).FieldName := AFieldName;
  TatBodyRelationField(Result).FRelation := FRelation;
  Add(Result);
end;

function TatBodyRelationFields.ByFieldName(
  const AName: String): TatRelationField;
var
  I: Integer;
begin
  if Find(Trim(AName), I) then
    Result := Items[I]
  else
    Result := nil;
end;

function TatBodyRelationFields.ByPos(const APosition: Integer): TatRelationField;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Items[I].FieldPosition = APosition then
    begin
      Result := Items[I];
      Exit;
    end;

  Result := nil;  
end;

procedure TatBodyRelationFields.Clear;
begin
  FList.Clear;
end;

procedure TatBodyRelationFields.RefreshData(aDatabase: TIBDatabase; aTransaction: TIBTransaction);
var
  ibsql: TIBSQL;
  RelationField: TatRelationField;
  fldname: String;
begin
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Database := aDatabase;
    ibsql.Transaction := aTransaction;
    if not ibsql.Transaction.InTransaction then
      ibsql.Transaction.Active := True;

//При создании таблицы у нас не все поля сразу попадают в at_relation_fields (например, id)
//поэтому, приходиться делать сложную проверку сразу двух таблиц (системной rdb$relation_fields
//и нашей at_relation_fields)
    ibsql.SQL.Text :=
      'SELECT '#13#10 +
      '  r.rdb$field_name, r.rdb$relation_name, r.rdb$field_position, ' +
      '  r.rdb$field_source, r.rdb$null_flag, rf.rdb$computed_source , a.*, '#13#10 +
      '  r.rdb$default_source as rdefsource, rf.rdb$default_source as fdefsource, rf.rdb$default_value '#13#10 +
      'FROM '#13#10 +
      '  at_relation_fields a LEFT JOIN rdb$relation_fields r '#13#10 +
      '    ON r.rdb$relation_name = a.relationname AND '#13#10 +
      '    r.rdb$field_name = a.fieldname '#13#10 +
      '    LEFT JOIN rdb$fields rf ON a.fieldsource = rf.rdb$field_name '#13#10 +
      'WHERE '#13#10 +
      '  a.relationname = :RN '#13#10 +
      'ORDER BY 3 ';
    ibsql.ParamByName('RN').AsString := FRelation.RelationName;

    ibsql.ExecQuery;

    while not ibsql.EOF do
    begin
      if ibsql.FieldByName('fieldname').AsTrimString > '' then
        fldname := ibsql.FieldByName('fieldname').AsTrimString
      else
        fldname := ibsql.FieldByName('rdb$field_name').AsTrimString;

      RelationField := ByFieldName(fldname);

      if Assigned(RelationField) then
        RelationField.RefreshData(ibsql.Current, aDatabase, aTransaction)//(ibsql.Current)
      else begin
        RelationField := TatBodyRelationField.Create(FRelation);
        try
          TatBodyRelationField(RelationField).FRelation := FRelation;
          TatBodyRelationField(RelationField).FieldName := fldname;
          RelationField.RefreshData(ibsql.Current, aDatabase, aTransaction);//(ibsql.Current);
          Add(RelationField);
        except
          RelationField.Free;
          raise;
        end;
      end;

      ibsql.Next;
    end;

    ibsql.Close;

    FRelation.RefreshConstraints(aDatabase, aTransaction);
    TatBodyRelation(FRelation).RefreshFormat(aDatabase, aTransaction);

  finally
    ibsql.Free;
  end;
end;

procedure TatBodyRelationFields.RefreshData;
begin
  try
    RefreshData(TatBodyRelation(FRelation).FDatabase.Database,
      TatBodyRelation(FRelation).FDatabase.Transaction);

    TatBodyRelation(FRelation).FDatabase.Transaction.Commit;

{    FRelation.RefreshConstraints;
    TatBodyRelation(FRelation).RefreshFormat;}

  finally
    if TatBodyRelation(FRelation).FDatabase.Transaction.Active then
      TatBodyRelation(FRelation).FDatabase.Transaction.RollBack;
  end;
end;

constructor TatBodyRelationFields.Create;
begin
  inherited Create;
  FList := TObjectList.Create(OwnObjects);
  Clear;
  FRelation := atRelation;
  //По умолчанию будем хранить поля отсортированные по имени
  //Для индексов поля нужно хранить в определенном порядке!!!!
  FSorted := True;
end;

procedure TatBodyRelationFields.Delete(const Index: Integer);
begin
  FList.Delete(Index);
end;

destructor TatBodyRelationFields.Destroy;
begin
  inherited;
  FList.Free;
end;

function TatBodyRelationFields.GetCount: Integer;
begin
  if Assigned(FRelation) then
    TatBodyDatabase(TatBodyRelation(FRelation).FDatabase).KillGarbage;
  Result := FList.Count;
end;

function TatBodyRelationFields.GetItems(Index: Integer): TatRelationField;
begin
  if FList.Count = 0 then
    Result := nil
  else
    Result := FList[Index] as TatRelationField;
end;

function TatBodyRelationFields.Find(const S: string; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  if FSorted then
  begin
    Result := False;
    L := 0;
    H := FList.Count - 1;

    while L <= H do
    begin
      I := (L + H) shr 1;
      C := AnsiCompareText((FList[I] as TatRelationField).FieldName, S);

      if C < 0 then
        L := I + 1
      else begin
        H := I - 1;
        if C = 0 then
        begin
          Result := True;
          L := I;
        end;
      end;
    end;

    Index := L;
  end else
  begin
    Result := False;
    Index := 0;
    for I := 0 to FList.Count - 1 do
      if AnsiCompareText((FList[I] as TatRelationField).FieldName, S) = 0 then
      begin
        Index := I;
        Result := True;
        Break;
      end;
  end;
end;

procedure TatBodyRelationFields.LoadFromStream(S: TStream);
var
  Reader: TReader;
begin
  Clear;

  Reader := TReader.Create(S, 1024);
  try
    Read(Reader);
  finally
    Reader.Free;
  end;
end;

procedure TatBodyRelationFields.SaveToStream(S: TStream);
var
  Writer: TWriter;
begin
  Writer := TWriter.Create(S, 1024);
  try
    Write(Writer);
  finally
    Writer.Free;
  end;
end;

procedure TatBodyRelationFields.Read(Reader: TReader);
var
  NewRelationField: TatRelationField;
begin
  with Reader do
  begin
    ReadListBegin;

    while not EndOfList do
    begin
      NewRelationField := TatBodyRelationField.Create(FRelation);
      TatBodyRelationField(NewRelationField).Read(Reader);
      FList.Add(NewRelationField);
    end;

    ReadListEnd;
  end;
end;

procedure TatBodyRelationFields.Write(Writer: TWriter);
var
  I: Integer;
begin
  with Writer do
  begin
    WriteListBegin;

    for I := 0 to Count - 1 do
      TatBodyRelationField(Items[I]).Write(Writer);

    WriteListEnd;
  end;
end;

function TatBodyRelationFields.ByID(
  const aID: Integer): TatRelationField;
var
  i: Integer;
begin
  Result := nil;
  for i:= 0 to FList.Count - 1 do
    if (FList[i] as TatRelationField).ID = aID then
    begin
      Result := FList[i] as TatRelationField;
      Break;
    end;
end;

function TatBodyRelationFields.IndexOf(AObject: TObject): Integer;
begin
  Result := FList.IndexOf(AObject);
end;

{ TatBodyFields }

function TatBodyFields.Add(atField: TatField): Integer;
begin
  if not Assigned(atField) then Exit;

  if atField.FieldName = '' then
    raise EatDatabaseError.Create('Can''t add an empty field!');

  //поиск в FList, если нет, то возвращает след. индекс.
  Find(atField.FieldName, Result);
  FList.Insert(Result, atField);
end;

function TatBodyFields.ByFieldName(const AFieldName: String): TatField;
var
  I: Integer;
begin
  if Find(ExtractIdentifier(FDatabase.Dialect, AFieldName), I) then
    Result := Items[I]
  else
    Result := nil;
end;

procedure TatBodyFields.Clear;
begin
  FList.Clear;
  FTreeNode := nil;
end;

constructor TatBodyFields.Create;
begin
  FDatabase := ADatabase;
  FList := TObjectList.Create;
  Clear;
end;

procedure TatBodyFields.RefreshData(aDatabase: TIBDatabase;
  aTransaction: TIBTransaction);
var
  ibsql: TIBSQL;
  Field: TatField;
begin
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Database := aDatabase;
    ibsql.Transaction := aTransaction;
    if not ibsql.Transaction.InTransaction then
      ibsql.Transaction.StartTransaction;

    ibsql.SQL.Text :=
      'SELECT '#13#10 +
      '  R.*, F.* '#13#10 +
      'FROM '#13#10 +
      '  AT_FIELDS F LEFT JOIN RDB$FIELDS R ON R.RDB$FIELD_NAME = F.FIELDNAME '#13#10 +
      'ORDER BY '#13#10 +
      '  F.LNAME, F.FIELDNAME ';

    ibsql.ExecQuery;

    while not ibsql.EOF do
    begin
      Field := ByFieldName(ibsql.FieldByName('FIELDNAME').AsTrimString);

      if Assigned(Field) then
        Field.RefreshData(ibsql.Current)
      else begin
        Field := TatBodyField.Create(FDatabase);
        try
          TatBodyField(Field).FFieldName := ibsql.FieldByName('FIELDNAME').AsTrimString;
          Field.RefreshData(ibsql.Current);
          Add(Field);
        except
          Field.Free;
          raise;
        end;
      end;

      ibsql.Next;
    end;

    ibsql.Close;
  finally
    ibsql.Free;
  end;

end;

procedure TatBodyFields.RefreshData;
begin
  try
    RefreshData(FDatabase.Database, FDatabase.Transaction);

    FDatabase.Transaction.Commit;

  finally
    if FDatabase.Transaction.Active then
      FDatabase.Transaction.RollBack;
  end;
end;

procedure TatBodyFields.Delete(const Index: Integer);
begin
  FList.Delete(Index);
end;

destructor TatBodyFields.Destroy;
begin
  inherited;
  FList.Free;
end;

function TatBodyFields.FindFirst(const AFieldName: String): TatField;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if
      (
        (AnsiPos(AFieldName, AnsiUpperCase(Items[I].FieldName)) > 0)
          or
        (AnsiPos(AFieldName, AnsiUpperCase(Items[I].LName)) > 0)
      )
    then begin
      Result := Items[I];
      exit;
    end;
end;

function TatBodyFields.GetCount: Integer;
begin
  TatBodyDatabase(FDatabase).KillGarbage;
  Result := FList.Count;
end;

function TatBodyFields.GetItems(Index: Integer): TatField;
begin
  Result := FList[Index] as TatField;
end;

function TatBodyFields.Find(const S: string; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := FList.Count - 1;

  while L <= H do
  begin
    I := (L + H) shr 1;
    C := AnsiCompareText((FList[I] as TatField).FieldName, S);

    if C < 0 then
      L := I + 1
    else begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
        L := I;
      end;
    end;
  end;

  Index := L;
end;

procedure TatBodyFields.LoadFromStream(S: TStream);
var
  Reader: TReader;
begin
  Clear;

  Reader := TReader.Create(S, 1024);
  try
    Read(Reader);
  finally
    Reader.Free;
  end;
end;

procedure TatBodyFields.SaveToStream(S: TStream);
var
  Writer: TWriter;
begin
  Writer := TWriter.Create(S, 1024);
  try
    Write(Writer);
  finally
    Writer.Free;
  end;
end;

procedure TatBodyFields.Read(Reader: TReader);
var
  NewField: TatBodyField;
begin
  with Reader do
  begin
    ReadListBegin;
    while not EndOfList do
    begin
      NewField := TatBodyField.Create(FDatabase);
      NewField.Read(Reader);
      FList.Add(NewField);
    end;

    ReadListEnd;
  end;
end;

procedure TatBodyFields.Write(Writer: TWriter);
var
  I: Integer;
begin
  with Writer do
  begin
    WriteListBegin;

    for I := 0 to Count - 1 do
      TatBodyField(Items[I]).Write(Writer);

    WriteListEnd;
  end;
end;

procedure TatBodyFields.UpdateData;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    TatBodyField(Items[I]).UpdateData;
end;

function TatBodyFields.ByID(const AID: Integer): TatField;
var
  i: Integer;
begin
  Result := nil;
  for i:= 0 to FList.Count - 1 do
    if TatField(FList[i]).ID = AID then
    begin
      Result := FList[i] as TatField;
      Break;
    end;
end;

function TatBodyFields.IndexOf(AObject: TObject): Integer;
begin
  Result := FList.IndexOf(AObject);
end;

{ TatBodyField }

procedure TatBodyField.Clear;
begin
  FFieldName := '';
  FHasRecord := False;
  FIsDropped := False;

  FLName := '';
  FDescription := '';

  FAlignment := DefFieldAlignment;
  FVisible := True;
  FFormatString := '';
  FColWidth := -1;
  FDisabled := False;
  FReadOnly := False;

  FgdSubType := '';
  FgdClassName := '';
  FgdClass := nil;

  FSQLType := 0;
  FSQLSubType := 0;
  FFieldLength := 0;
  FFieldScale := 0;
  FIsNullable := True;
  FReadOnly := False;

  FRefTableName := '';
  FRefTable := nil;
  FRefListFieldName := '';
  FRefListField := nil;
  FRefCondition := '';

  FSetTableName := '';
  FSetTable := nil;
  FSetListFieldName := '';
  FSetListField := nil;
  FSetCondition := '';

  FTreeNode := nil;
end;

constructor TatBodyField.Create;
begin
  inherited Create;

  FDatabase := ADatabase;
  Clear;
  SetLength(FNumerations, 0);
end;

procedure TatBodyField.RefreshData(aDatabase: TIBDatabase;
  aTransaction: TIBTransaction);
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);

  try
    ibsql.Database := aDatabase;
    ibsql.Transaction := aTransaction;

    if not ibsql.Transaction.InTransaction then
      ibsql.Transaction.Active := True;

    ibsql.Sql.Text := Format
    (
      'SELECT '#13#10 +
      '  R.*, F.* '#13#10 +
      'FROM '#13#10 +
      '  at_fields f LEFT JOIN rdb$fields r ON '#13#10 +
      'r.rdb$field_name = f.fieldname '#13#10 +
      'WHERE f.fieldname = ''%s''',
      [FFieldNAME]
    );
    ibsql.ExecQuery;

    if ibsql.RecordCount > 0 then
      RefreshData(ibsql.Current)
    else
      if Pos('RDB$', FFieldName) = 0 then
        raise EatDatabaseError.CreateFmt(
          'Field Type %s not found in AT_FIELDS table!', [FFieldName]);

    ibsql.Close;

  finally
    ibsql.Free;
  end;
end;

procedure TatBodyField.RefreshData;
begin
  try
    RefreshData(FDatabase.Database, FDatabase.Transaction);

    FDatabase.Transaction.Commit;

  finally
    if FDatabase.Transaction.Active then
      FDatabase.Transaction.RollBack;
  end;
end;

procedure TatBodyField.RefreshData(SQLRecord: TIBXSQLDA);
var
  Stream: TStringStream;
begin
  if (AnsiCompareText(SQLRecord.ByName('FIELDNAME').AsTrimString, FFieldName) <> 0) and
    (AnsiCompareText(SQLRecord.ByName('RDB$FIELD_NAME').AsTrimString, FFieldName) <> 0) then
    raise EatDatabaseError.Create('Can''t refresh field: incorrect field name!');

  FLName := TrimRight(SQLRecord.ByName('LNAME').AsString);
  FDescription := TrimRight(SQLRecord.ByName('DESCRIPTION').AsString);

  FAlignment := StringToFieldAlignment(ReadField(SQLRecord.ByName('ALIGNMENT'), 'L'));

  FFormatString := SQLRecord.ByName('FORMAT').AsString;
  FVisible := Boolean(SQLRecord.ByName('VISIBLE').AsInteger);
  FColWidth := SQLRecord.ByName('COLWIDTH').AsShort;
  FDisabled := Boolean(SQLRecord.ByName('DISABLED').AsShort);

  FID := SQLRecord.ByName('ID').AsInteger;

  FReadOnly := Boolean(SQLRecord.ByName('READONLY').AsShort);

  FgdClassName := SQLRecord.ByName('GDCLASSNAME').AsString;
  if FgdClassName > '' then
  begin
    FgdClass := GetClass(FgdClassName);
    if FgdClass = nil then
      FgdClassName := '';
  end else
    FgdClass := nil;    

  FgdSubType := SQLRecord.ByName('GDSUBTYPE').AsString;

  FSQLType := SQLRecord.ByName('rdb$field_type').AsInteger;
  FSQLSubType := SQLRecord.ByName('rdb$field_sub_type').AsInteger;
  FFieldLength := SQLRecord.ByName('rdb$field_length').AsInteger;
  FFieldScale := SQLRecord.ByName('rdb$field_scale').AsInteger;
  FIsNullable := SQLRecord.ByName('rdb$null_flag').IsNull;

  FRefTableName := TrimRight(SQLRecord.ByName('REFTABLE').AsString);
  FRefCondition := SQLRecord.ByName('REFCONDITION').AsString;
  FRefListFieldName := TrimRight(SQLRecord.ByName('REFLISTFIELD').AsString);

  FHasRecord := not SQLRecord.ByName('FIELDNAME').IsNull;

  FSetTableName := TrimRight(SQLRecord.ByName('SETTABLE').AsString);
  FSetCondition := SQLRecord.ByName('SETCONDITION').AsString;
  FSetListFieldName := TrimRight(SQLRecord.ByName('SETLISTFIELD').AsString);

  Stream := TStringStream.Create(SQLRecord.ByName('Numeration').AsString);
  try
    MakeNumerationFromString(Stream.ReadString(Stream.Size));
  finally
    Stream.Free;
  end;

  UpdateData;
end;

procedure TatBodyField.RecordAcquired;
var
  ibsql: TIBSQL;
begin
  Assert(not FHasRecord);
  ibsql := TIBSQL.Create(nil);

  try
    ibsql.Database := FDatabase.Database;
    ibsql.Transaction := FDatabase.Transaction;

    FDatabase.Transaction.Active := True;

    ibsql.SQl.Text := Format(
      'INSERT INTO at_fields (FIELDNAME, LNAME, DESCRIPTION, ALIGNMENT, ' +
      'VISIBLE, COLWIDTH) VALUES ' +
      '(%0:s, %0:s, %0:s, ''L'', 0, 10) ',
      ['''' + FFieldName + '''']
    );

    ibsql.ParamCheck := True;
    ibsql.ExecQuery;
    ibsql.Close;

    FDatabase.Transaction.Commit;
    FHasRecord := True;
  finally
    ibsql.Free;
    if FDatabase.Transaction.Active then
      FDatabase.Transaction.RollBack;
  end;
end;

function TatBodyField.GetFieldType: TFieldType;
begin
  case FSQLType of
    blr_text, blr_text2, blr_varying, blr_varying2,
    blr_cstring, blr_cstring2:
      Result := ftString;
    blr_short:
    begin
      if (FFieldName = BooleanDomainName) or (FFieldName = BoolNotNullDomainName) then
        Result := ftBoolean
      else

      if (FFieldScale = 0) then
        Result := ftSmallInt
      else
        Result := ftBCD;
    end;
    blr_long:
    begin
      if (FFieldScale = 0) then
        Result := ftInteger
      else

      if (FFieldScale >= (-4)) then
        Result := ftBCD
      else
        Result := ftFloat;
    end;
    blr_quad, blr_blob_id:
      Result := ftInteger;
    blr_float, blr_double, blr_d_float:
      Result := ftFloat;
    blr_timestamp{, blr_date}:
      Result := ftDateTime;
    blr_blob:
    begin
      if (FSQLSubType = 1) then
        Result := ftMemo
      else
        Result := ftBlob;
    end;
    blr_sql_date:
      Result := ftDate;
    blr_sql_time:
      Result := ftTime;
    blr_int64:
    begin
      if (FFieldScale = 0) then
        Result := ftLargeInt
      else

      if (FFieldScale >= (-4)) then
        Result := ftBCD
      else
        Result := ftFloat;
    end;
  else
    Result := ftUnknown;
  end;
end;

function TatBodyField.GetIsSystem: Boolean;
begin
  Result := AnsiPos(SystemPrefix, AnsiUpperCase(FFieldName)) = 1;
end;

function TatBodyField.GetIsUserDefined: Boolean;
begin
  Result := StrIPos(UserPrefix, FFieldName) = 1;
end;

procedure TatBodyField.LoadFromStream(S: TStream);
var
  Reader: TReader;
begin
  Clear;

  Reader := TReader.Create(S, 1024);
  try
    Read(Reader);
  finally
    Reader.Free;
  end;
end;

procedure TatBodyField.SaveToStream(S: TStream);
var
  Writer: TWriter;
begin
  Writer := TWriter.Create(S, 1024);
  try
    Write(Writer);
  finally
    Writer.Free;
  end;
end;

procedure TatBodyField.Read(Reader: TReader);
var
  S: String;
begin
  with Reader do
  begin
    FFieldName := ReadString;
    FHasRecord := ReadBoolean;

    FLName := ReadString;
    FDescription := ReadString;
    FAlignment := StringToFieldAlignment(ReadString);
    FFormatString := ReadString;
    FVisible := ReadBoolean;
    FColWidth := ReadInteger;
    FDisabled := ReadBoolean;

    FSQLType := ReadInteger;
    FSQLSubType := ReadInteger;
    FFieldLength := ReadInteger;
    FFieldScale := ReadInteger;
    FIsNullable := ReadBoolean;

    FRefCondition := ReadString;
    FRefListFieldName := ReadString;
    FRefTableName := ReadString;

    FSetCondition := ReadString;
    FSetListFieldName := ReadString;
    FSetTableName := ReadString;

    FReadOnly := ReadBoolean;

    FgdSubType := ReadString;
    FgdClassName := ReadString;
    if FgdClassName > '' then
    begin
      FgdClass := GetClass(FgdClassName);
      if FgdClass = nil then
        FgdClassName := '';
    end else
      FgdClass := nil;    
    FID := ReadInteger;
    S := ReadString;
    MakeNumerationFromString(S);
  end;
end;

procedure TatBodyField.Write(Writer: TWriter);
begin
  with Writer do
  begin
    WriteString(FFieldName);
    WriteBoolean(FHasRecord);

    WriteString(FLName);
    WriteString(FDescription);
    WriteString(FieldAlignmentToString(FAlignment));
    WriteString(FFormatString);
    WriteBoolean(FVisible);
    WriteInteger(FColWidth);
    WriteBoolean(FDisabled);

    WriteInteger(FSQLType);
    WriteInteger(FSQLSubType);
    WriteInteger(FFieldLength);
    WriteInteger(FFieldScale);
    WriteBoolean(FIsNullable);

    WriteString(FRefCondition);
    WriteString(FRefListFieldName);
    WriteString(FRefTableName);

    WriteString(FSetCondition);
    WriteString(FSetListFieldName);
    WriteString(FSetTableName);

    WriteBoolean(FReadOnly);
    WriteString(FgdSubType);
    WriteString(FgdClassName);

    WriteInteger(FID);
    WriteString(MakeStringFromNumeration);
  end;
end;

procedure TatBodyField.UpdateData;
begin
  FRefTable := TatBodyDatabase(FDatabase).FRelations.ByRelationName(FRefTableName);

  if Assigned(FRefTable) then
    FRefListField := TatBodyRelation(FRefTable).FRelationFields.ByFieldName(FRefListFieldName);

  FSetTable := TatBodyDatabase(FDatabase).FRelations.ByRelationName(FSetTableName);

  if Assigned(FSetTable) then
    FSetListField := TatBodyRelation(FSetTable).FRelationFields.ByFieldName(FSetListFieldName);
end;

function TatBodyField.GetNumerationName(const Value: String): String;
var
  Index: Integer;
begin
  Index := FindNumeration(Value);
  if (Index >= 0) then
    Result := FNumerations[Index].Name
  else
    Result := '';
end;

function TatBodyField.GetNumerationValue(
  const NameNumeration: String): String;
var
  i: Integer;
begin
  Result := #0;
  for i:= Low(FNumerations) to High(FNumerations) do
    if FNumerations[i].Name = NameNumeration then
    begin
      Result := FNumerations[i].Value;
      Break;
    end;
end;

function TatBodyField.FindNumeration(const Value: String): Integer;
var
  L, H, I, C: Integer;
begin
  Result := -1;
  if Value = '' then Exit;
  L := Low(FNumerations);
  H := High(FNumerations);

  while L <= H do
  begin
    I := (L + H) shr 1;
    if Value[1] = FNumerations[i].Value then
      C := 0
    else
      if FNumerations[i].Value > Value[1] then
        C := 1
      else
        C := -1;

    if C < 0 then
      L := I + 1
    else begin
      H := I - 1;
      if C = 0 then
      begin
        Result := i;
        L := I;
      end;
    end;
  end;

end;

type
  TNameNumeration = class
    Name: String;
    constructor Create(const aName: String);
  end;

constructor TNameNumeration.Create(const aName: String);
begin
  Name := aName;
end;

procedure TatBodyField.MakeNumerationFromString(const aNumeration: String);
var
  SList: TStringList;
  S, S1: String;
  i: Integer;
begin
  SList := TStringList.Create;
  try
    SList.Sorted := True;
    S := aNumeration;
    while S > '' do
    begin
      if Pos(#13#10, S) > 0 then
      begin
        S1 := copy(S, 1, Pos(#13#10, S) - 1);
        S := copy(S, Pos(#13#10, S) + 2, Length(S));
      end
      else
      begin
        S1 := S;
        S := '';
      end;
      if Pos(';', S1) > 0 then
        SList.AddObject(copy(S1, 1, Pos(';', S1) - 1),
          TNameNumeration.Create(copy(S1, Pos(';', S1) + 1, Length(S1))));
    end;
    SetLength(FNumerations, SList.Count);
    for i:= 0 to SList.Count - 1 do
    begin
      FNumerations[i].Value := SList[i];
      FNumerations[i].Name := (SList.Objects[i] as TNameNumeration).Name;
    end;
  finally
    for I := 0 to SList.Count - 1 do
      (SList.Objects[I] as TNameNumeration).Free;
    SList.Free;
  end;
end;

function TatBodyField.MakeStringFromNumeration: String;
var
  i: Integer;
begin
  Result := '';
  for i:= Low(FNumerations) to High(FNumerations) do
    Result := Result + FNumerations[i].Value + ';' + FNumerations[i].Name + #13#10;
end;

type
  TTreeViewNexus = class(TForm)
  private
    FDatabase: TatDatabase;

    procedure WMStartMultiTransaction(var Msg: TMessage);
      message WM_STARTMULTITRANSACTION;
    procedure WMLogOff(var Msg: TMessage);
      message WM_LOGOFF;

  protected

  public
    constructor Create(AnOwner: TatDatabase); reintroduce;


  end;


{ TTreeViewNexus }

constructor TTreeViewNexus.Create(AnOwner: TatDatabase);
begin
  inherited CreateNew(nil);

  FDatabase := AnOwner;
end;

procedure TTreeViewNexus.WMStartMultiTransaction(var Msg: TMessage);
begin
  inherited;
  FDatabase.StartMultiConnectionTransaction;
end;

procedure TTreeViewNexus.WMLogOff(var Msg: TMessage);
begin
  inherited;
  if IBLogin.LoggedIn then
    IBLogin.LogOff;
end;


{ TatBodyDatabase }

procedure TatBodyDatabase.Clear;
begin
  Assert(not FLoading);

  TatBodyRelations(FRelations).Clear;
  TatBodyFields(FFields).Clear;
  TatBodyForeignKeys(FForeignKeys).Clear;
  TatBodyPrimaryKeys(FPrimaryKeys).Clear;
  FLoaded := False;
end;

constructor TatBodyDatabase.Create;
begin
  inherited;

  FRelations := TatBodyRelations.Create(Self);
  FFields := TatBodyFields.Create(Self);
  FForeignKeys := TatBodyForeignKeys.Create(Self);
  FPrimaryKeys := TatBodyPrimaryKeys.Create(Self);
  FLoaded := False;
  FLoading := False;

  FTreeNexus := TTreeViewNexus.Create(Self);

  FMultiConnectionTransaction := 0;

  FAttrVersion := 0;

  FGarbageCount := 0;
  FDialect := 3;
end;

destructor TatBodyDatabase.Destroy;
var
  S, CS: TStream;
begin
  if FLoaded and (FFileName > '') then
  begin
    try
      S := TFileStream.Create(FFileName, fmCreate or fmShareExclusive);
      CS := TZCompressionStream.Create(S, zcDefault);
      try
        SaveToStream(CS);
      finally
        CS.Free;
        S.Free;
      end;
    except
      on EFOpenError do
        raise EatDatabaseError.Create('Can''t create attributes file!');
      else
        raise EatDatabaseError.Create('Error during storing of attributes data locally!');
    end;
  end;

  FRelations.Free;
  FFields.Free;
  FForeignKeys.Free;
  FPrimaryKeys.Free;
  FTreeNexus.Free;

  inherited;
end;

function TatBodyDatabase.FindRelationField(const ARelationName,
  ARelationFieldName: String): TatRelationField;
var
  R: TatRelation;
begin
  R := FRelations.ByRelationName(ARelationName);
  if R <> nil then
    Result := R.RelationFields.ByFieldName(ARelationFieldName)
  else
    Result := nil;
end;

function TatBodyDatabase.GetReadOnly: Boolean;
begin
  Result := Boolean(AnsiCompareText(FDatabase.Params.Values['user_name'], SysDBAUserName));
end;

procedure TatBodyDatabase.LoadFromDatabase(const Synchronize: Boolean = True);
var
  ibsql: TIBSQL;
  atRelation: TatBodyRelation;
  atField: TatBodyField;
  atRelationField: TatBodyRelationField;
  atForeignKey: TatBodyForeignKey;
  atPrimaryKey: TatBodyPrimaryKey;
  I, K: Integer;
  DidActivate: Boolean;
begin
  Assert(not FLoading);
  Assert(Assigned(FDatabase));
  Assert(Assigned(FTransaction));

  if Assigned(IBLogin) then
  begin
    IBLogin.AddEvent('Синхронизация и считывание структуры базы данных',
      'Kernel');
  end;    

  Clear;

  //!!!
  Clear_atSQLSetupCache;

  FLoading := True;

  DidActivate := False;
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Database := FDatabase;
    ibsql.Transaction := FTransaction;

    if not FTransaction.InTransaction then
    begin
      FTransaction.StartTransaction;
      DidActivate := True;
    end;

    ////////////////////////////////////////////////////////////////////////////
    // Синхронизируем содержимое ат_ таблиц со структурой базы
    ////////////////////////////////////////////////////////////////////////////

    if Synchronize then
    begin
      if Assigned(gdSplash) then
        gdSplash.ShowText(sSinchronizationAtRelations);
      ibsql.SQL.Text := 'EXECUTE PROCEDURE at_p_sync';
      try
        for I := 0 to 5 do
        begin
          try
            ibsql.ExecQuery;
            FTransaction.Commit;
            Break;
          except
            on E: Exception do
            begin
              if ((E is EIBError) and (((E as EIBError).IBErrorCode = isc_deadlock)
                or ((E as EIBError).IBErrorCode = isc_lock_conflict)))
              then
                Sleep(1000)
              else
                raise;
            end;
          end;
        end;
      except
        on E: Exception do
          Application.HandleException(E);
      end;
    end;

    if not FTransaction.InTransaction then
      FTransaction.StartTransaction;

    ////////////////////////////////////////////////////////////////////////////
    // Считывание типов полей
    ////////////////////////////////////////////////////////////////////////////

    if Assigned(gdSplash) then
      gdSplash.ShowText(sReadingDomens);

    ibsql.Close;
    ibsql.SQL.Text :=
      'SELECT '#13#10 +
      '  R.RDB$FIELD_NAME , F.FIELDNAME, F.LNAME, F.DESCRIPTION, F.ALIGNMENT, '#13#10 +
      '  F.FORMAT, F.VISIBLE, F.COLWIDTH, F.DISABLED, F.ID, F.READONLY, F.GDCLASSNAME, '#13#10 +
      '  F.GDSUBTYPE, R.RDB$FIELD_TYPE, R.RDB$FIELD_SUB_TYPE, R.RDB$FIELD_LENGTH, '#13#10 +
      '  R.RDB$FIELD_SCALE, R.RDB$NULL_FLAG, F.REFTABLE, F.REFCONDITION, F.REFLISTFIELD, '#13#10 +
      '  F.FIELDNAME, F.SETTABLE, F.SETCONDITION, F.NUMERATION, F.SETLISTFIELD '#13#10 +
      'FROM '#13#10 +
      '  RDB$FIELDS R LEFT JOIN AT_FIELDS F ON R.RDB$FIELD_NAME = F.FIELDNAME '#13#10 +
      'ORDER BY '#13#10 +
      '  R.RDB$FIELD_NAME ';

    ibsql.ExecQuery;
    while not ibsql.EOF do
    begin
      atField := TatBodyField.Create(Self);
      try
        atField.FFieldName := ibsql.FieldByName('RDB$FIELD_NAME').AsTrimString;
        atField.RefreshData(ibsql.Current);
        FFields.Add(atField);
      except
        atField.Free;
        raise;
      end;

      ibsql.Next;
    end;

    ////////////////////////////////////////////////////////////////////////////
    // Считывание таблиц
    ////////////////////////////////////////////////////////////////////////////

    if Assigned(gdSplash) then
      gdSplash.ShowText(sReadingRelations);

    //Системные таблицы не считываем
    ibsql.Close;
    ibsql.SQL.Text :=
      'SELECT '#13#10 +
      '  A.RELATIONNAME, R.RDB$RELATION_NAME, A.LNAME, A.LSHORTNAME, A.DESCRIPTION, '#13#10 +
      '  A.AFULL, A.ACHAG, A.AVIEW, A.LISTFIELD, A.EXTENDEDFIELDS, A.ID, R.RDB$FORMAT, '#13#10 +
      '  R.RDB$RELATION_ID, A.BRANCHKEY, R.RDB$VIEW_BLR '#13#10 +
      'FROM '#13#10 +
      '  rdb$relations r LEFT JOIN at_relations a '#13#10 +
      '    ON r.rdb$relation_name = a.relationname '#13#10 +
      'WHERE '#13#10 +
      '  r.rdb$system_flag = 0  AND '#13#10 +
      '  (NOT (r.rdb$relation_name STARTING WITH ''RDB$'')) ' +
      'ORDER BY '#13#10 +
      '  a.lname, r.rdb$relation_name ';

    ibsql.ExecQuery;
    while not ibsql.EOF do
    begin
      atRelation := TatBodyRelation.Create(Self);
      try
        atRelation.FRelationName := ibsql.FieldByName('RDB$RELATION_NAME').AsTrimString;
        atRelation.RefreshData(ibsql.Current, FDatabase, FTransaction);
        FRelations.Add(atRelation);
      except
        atRelation.Free;
        raise;
      end;

      ibsql.Next;
    end;
    ibsql.Close;

    ////////////////////////////////////////////////////////////////////////////
    // считывание полей таблиц
    ////////////////////////////////////////////////////////////////////////////

    if Assigned(gdSplash) then
      gdSplash.ShowText(sReadingFields);

    ibsql.Close;
    ibsql.SQL.Text :=
      'SELECT '#13#10 +
      '  r.rdb$field_name, r.rdb$relation_name, r.rdb$field_position, a.OBJECTS, '#13#10 +
      '  r.rdb$null_flag, rf.rdb$computed_source, a.relationname, a.FIELDNAME, '#13#10 +
      '  r.rdb$default_source as rdefsource, rf.rdb$default_source as fdefsource, '#13#10 +
      '  rf.rdb$default_value, a.lname, a.lshortname, a.description, a.alignment, '#13#10 +
      '  a.format, a.visible, a.colwidth, a.readonly, a.gdclassname, a.gdsubtype, '#13#10 +
      '  a.AFULL, a.ACHAG, a.AVIEW, a.ID, a.fieldsource, a.CROSSTABLE, a.CROSSFIELD '#13#10 +
      'FROM '#13#10 +
      '  rdb$relation_fields r '#13#10 +
      '    LEFT JOIN '#13#10 +
      '      at_relation_fields a '#13#10 +
      '    ON '#13#10 +
      '      r.rdb$relation_name = a.relationname '#13#10 +
      '       AND '#13#10 +
      '      r.rdb$field_name = a.fieldname '#13#10 +
      '    LEFT JOIN rdb$fields rf ON r.rdb$field_source = rf.rdb$field_name '#13#10 +
      ' WHERE ' +
      '  NOT (r.rdb$field_name STARTING WITH ''RDB$'') ' +
      ' '#13#10 +
      'ORDER BY '#13#10 +
      '  r.rdb$relation_name, '#13#10 +
      '  r.rdb$field_position '#13#10;

    ibsql.ExecQuery;
    atRelation := nil;

    while not ibsql.EOF do
    begin
      if
        not Assigned(atRelation) or
        (atRelation.RelationName <> ibsql.FieldByName('RDB$RELATION_NAME').AsTrimString)
      then
        atRelation := FRelations.ByRelationName(
          ibsql.FieldByName('RDB$RELATION_NAME').AsTrimString) as TatBodyRelation;

      if Assigned(atRelation) then
      begin
        if atRelation.FRelationType in [rtTable, rtView] then
        begin
          atRelationField := atRelation.RelationFields.AddRelationField(
            ibsql.FieldByName('RDB$FIELD_NAME').AsTrimString) as TatBodyRelationField;
          atRelationField.RefreshData(ibsql.Current, FDatabase, FTransaction);
        end;
      end;

      ibsql.Next;
    end;
    ibsql.Close;

    ////////////////////////////////////////////////////////////////////////////
    // Считывание главных ключей
    ////////////////////////////////////////////////////////////////////////////

    if Assigned(gdSplash) then
      gdSplash.ShowText(sReadingPrimKeys);

    ibsql.SQL.Text :=
      'SELECT '#13#10 +
      '  RC.RDB$RELATION_NAME, '#13#10 +
      '  RC.RDB$CONSTRAINT_NAME, '#13#10 +
      '  RC.RDB$INDEX_NAME, '#13#10 +
      '  INDSEG.RDB$FIELD_NAME '#13#10 +
      ' '#13#10 +
      'FROM '#13#10 +
      '  RDB$RELATION_CONSTRAINTS RC '#13#10 +
      '    JOIN '#13#10 +
      '      RDB$INDEX_SEGMENTS INDSEG '#13#10 +
      '    ON '#13#10 +
      '      RC.RDB$INDEX_NAME = INDSEG.RDB$INDEX_NAME '#13#10 +
      ' '#13#10 +
      'WHERE '#13#10 +
      '  RC.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' '#13#10 +
      ' '#13#10 +
      'ORDER BY '#13#10 +
      '  RC.RDB$RELATION_NAME, '#13#10 +
      '  RC.RDB$CONSTRAINT_NAME, '#13#10 +
      '  INDSEG.RDB$FIELD_POSITION ';

    ibsql.ExecQuery;

    while not ibsql.EOF do
    begin
      atPrimaryKey := FPrimaryKeys.ByConstraintName(
        ibsql.FieldByName('RDB$CONSTRAINT_NAME').AsTrimString) as TatBodyPrimaryKey;

      if not Assigned(atPrimaryKey) then
      begin
        atPrimaryKey := TatBodyPrimaryKey.Create(Self);
        atPrimaryKey.FConstraintName := ibsql.FieldByName('RDB$CONSTRAINT_NAME').AsTrimString;

        atPrimaryKey.FRelation := FRelations.ByRelationName(
          ibsql.FieldByName('RDB$RELATION_NAME').AsTrimString);

        if Assigned(atPrimaryKey.FRelation) then
          TatBodyRelation(atPrimaryKey.FRelation).FPrimaryKey := atPrimaryKey;

        atPrimaryKey.FIndexName := ibsql.FieldByName('RDB$INDEX_NAME').AsTrimString;
        FPrimaryKeys.Add(atPrimaryKey);
      end;

      if Assigned(atPrimaryKey.Relation) then
        atPrimaryKey.ConstraintFields.Add(
          atPrimaryKey.Relation.RelationFields.ByFieldName(
            ibsql.FieldByName('RDB$FIELD_NAME').AsTrimString));

      ibsql.Next;
    end;

    ////////////////////////////////////////////////////////////////////////////
    // Вытягиваем информацию о внешник ключах
    ////////////////////////////////////////////////////////////////////////////

    if Assigned(gdSplash) then
      gdSplash.ShowText(sReadingForeignKeys);

    ibsql.Close;
    ibsql.SQL.Text :=
      'SELECT '#13#10 +
      '  RC.RDB$RELATION_NAME AS RELATIONNAME, '#13#10 +
      '  RC.RDB$CONSTRAINT_NAME AS CONSTRAINTNAME, '#13#10 +
      '  RC.RDB$INDEX_NAME AS INDEXNAME, '#13#10 +
      '  INDSEG.RDB$FIELD_NAME AS FIELDNAME, '#13#10 +
      '  REFC.RDB$CONST_NAME_UQ AS FCONSTRAINT, '#13#10 +
      '  RC2.RDB$RELATION_NAME AS FRELATIONNAME, '#13#10 +
      '  RC2.RDB$INDEX_NAME AS FINDEXNAME, '#13#10 +
      '  INDSEG2.RDB$FIELD_NAME AS FFIELDNAME, '#13#10 +
      '  REFC.RDB$UPDATE_RULE AS UPDATE_RULE, '#13#10 +
      '  REFC.RDB$DELETE_RULE AS DELETE_RULE '#13#10 +
      ' '#13#10 +
      'FROM '#13#10 +
      '  RDB$RELATION_CONSTRAINTS RC '#13#10 +
      '    JOIN '#13#10 +
      '      RDB$INDEX_SEGMENTS INDSEG '#13#10 +
      '    ON '#13#10 +
      '      RC.RDB$INDEX_NAME = INDSEG.RDB$INDEX_NAME '#13#10 +
      '    JOIN '#13#10 +
      '      RDB$REF_CONSTRAINTS REFC '#13#10 +
      '    ON '#13#10 +
      '      REFC.RDB$CONSTRAINT_NAME = RC.RDB$CONSTRAINT_NAME, '#13#10 +
      '       '#13#10 +
      '  RDB$RELATION_CONSTRAINTS RC2 '#13#10 +
      '    JOIN '#13#10 +
      '      RDB$INDEX_SEGMENTS INDSEG2 '#13#10 +
      '    ON '#13#10 +
      '      RC2.RDB$INDEX_NAME = INDSEG2.RDB$INDEX_NAME '#13#10 +
      ' '#13#10 +
      'WHERE '#13#10 +
      '  RC2.RDB$CONSTRAINT_NAME = REFC.RDB$CONST_NAME_UQ '#13#10 +
      '    AND '#13#10 +
      '  INDSEG.RDB$FIELD_POSITION = INDSEG2.RDB$FIELD_POSITION '#13#10 +
      ' '#13#10 +
      'ORDER BY '#13#10 +
      '  RC.RDB$RELATION_NAME, '#13#10 +
      '  RC.RDB$CONSTRAINT_NAME, '#13#10 +
      '  INDSEG.RDB$FIELD_POSITION '#13#10 +
      ' '#13#10;

    ibsql.ExecQuery;

    while not ibsql.EOF do
    begin
      atForeignKey := FForeignKeys.ByConstraintName(
        ibsql.FieldByName('CONSTRAINTNAME').AsTrimString) as TatBodyForeignKey;

      if not Assigned(atForeignKey) then
      begin
        atForeignKey := TatBodyForeignKey.Create(Self);

        atForeignKey.FConstraintName :=
          ibsql.FieldByName('CONSTRAINTNAME').AsTrimString;

        atForeignKey.FIndexName :=
          ibsql.FieldByName('INDEXNAME').AsTrimString;

        atForeignKey.FRelation := FRelations.ByRelationName(
          ibsql.FieldByName('RELATIONNAME').AsTrimString);

        atForeignKey.FReferencesRelation := FRelations.ByRelationName(
          ibsql.FieldByName('FRELATIONNAME').AsTrimString);

        atForeignKey.FReferencesIndex :=
          ibsql.FieldByName('FINDEXNAME').AsTrimString;

        atForeignKey.FUpdateRule :=
          StringToUpdateDeleteRule(ibsql.FieldByName('UPDATE_RULE').AsTrimString);

        atForeignKey.FDeleteRule :=
          StringToUpdateDeleteRule(ibsql.FieldByName('DELETE_RULE').AsTrimString);

        FForeignKeys.Add(atForeignKey);
      end;

      if Assigned(atForeignKey.FRelation) then
        atForeignKey.FConstraintFields.Add(
          atForeignKey.FRelation.RelationFields.ByFieldName(
            ibsql.FieldByName('FIELDNAME').AsTrimString));

      if Assigned(atForeignKey.FReferencesRelation) then
        atForeignKey.FReferencesFields.Add(
          atForeignKey.FReferencesRelation.RelationFields.ByFieldName(
            ibsql.FieldByName('FFIELDNAME').AsTrimString));

      ibsql.Next;
    end;

    ibsql.Close;

    ////////////////////////////////////////////////////////////////////////////
    // Связываем наименования полей и таблиц с
    // соответствующими объектами
    ////////////////////////////////////////////////////////////////////////////

    TatBodyFields(FFields).UpdateData;
    TatBodyRelations(FRelations).UpdateData;


    for I := 0 to FForeignKeys.Count - 1 do
    with TatBodyForeignKey(FForeignKeys[I]) do
    begin
      if IsSimpleKey then
      begin
        TatBodyRelationField(ConstraintField).FReferences := FReferencesRelation;
        TatBodyRelationField(ConstraintField).FReferencesField := ReferencesField;
      end;

      for K := 0 to FConstraintFields.Count - 1 do
      with TatBodyRelationField(FConstraintFields[K]) do
        FForeignKey := FForeignKeys[I];
    end;

    FLoaded := True;

    FLastRefresh := Now;

    //
    //  Считывание версии атрибутов

    ibsql.SQL.Text := 'SELECT GEN_ID(gd_g_attr_version, 0) FROM RDB$DATABASE';
    ibsql.ExecQuery;
    FAttrVersion := ibsql.Fields[0].AsInteger;
    ibsql.Close;

    if FTransaction.InTransaction then
      FTransaction.Commit;
  finally
    FLoading := False;
    ibsql.Free;

    if DidActivate and FTransaction.InTransaction then
      FTransaction.Commit;
  end;
end;

procedure TatBodyDatabase.LoadFromStream(S: TStream);
const
  BuffSize = 1024 * 32;
var
  Reader: TReader;
  MS: TMemoryStream;
  Buff: array[1..BuffSize] of Char;
  R: Integer;
begin
  Assert(not FLoading);

  Clear;
  FLoaded := False;

  MS := nil;
  FLoading := True;
  try
    if S is TCustomZStream then
    begin
      MS := TMemoryStream.Create;
      R := S.Read(Buff, BuffSize);
      while R > 0 do
      begin
        MS.SetSize(MS.Size + R);
        MS.Write(Buff, R);
        R := S.Read(Buff, BuffSize);
      end;
      MS.Position := 0;
      Reader := TReader.Create(MS, BuffSize);
    end else
      Reader := TReader.Create(S, BuffSize);

    try
      Read(Reader);
      FLoaded := True;
    finally
      Reader.Free;
    end;
  finally
    FLoading := False;
    MS.Free;
  end;
end;

procedure TatBodyDatabase.SaveToStream(S: TStream);
var
  Writer: TWriter;
begin
  Assert(not FLoading);
  Assert(FLoaded);

  Writer := TWriter.Create(S, 1024);
  try
    Write(Writer);
  finally
    Writer.Free;
  end;
end;

procedure TatBodyDatabase.KillGarbage;
var
  I, K: Integer;
begin
  if FGarbageCount > 0 then
  begin
    FGarbageCount := 0;

    ////////////////////////////////////////////////////////////////////////////
    // Удаление мусора из списка таблиц
    ////////////////////////////////////////////////////////////////////////////

    for I := FRelations.Count - 1 downto 0 do
    begin
      if FRelations[I].IsDropped then
        TatBodyRelations(FRelations).FList.Remove(FRelations[I])
      else with TatBodyRelation(FRelations[I]) do
      begin
        for K := FRelationFields.Count - 1 downto 0 do
          if FRelationFields[K].IsDropped then
            TatBodyRelationFields(FRelationFields).FList.Remove(FRelationFields[K]);
      end;
    end;

    ////////////////////////////////////////////////////////////////////////////
    // Удаление мусора из списка типов полей
    ////////////////////////////////////////////////////////////////////////////

    for I := FFields.Count - 1 downto 0 do
      if FFields[I].IsDropped then
        TatBodyFields(FFields).FList.Remove(FFields[I]);

    ////////////////////////////////////////////////////////////////////////////
    // Удаление мусора из списка внешних ключей
    ////////////////////////////////////////////////////////////////////////////

    for I := FForeignKeys.Count - 1 downto 0 do
      if FForeignKeys[I].IsDropped then
      begin
        with TatBodyForeignKey(FForeignKeys[I]) do
        begin
          if FForeignKeys[I].IsSimpleKey then
          begin
            TatBodyRelationField(ConstraintField).FReferences := nil;
            TatBodyRelationField(ConstraintField).FReferencesField := nil;
          end;

          for K := 0 to FConstraintFields.Count - 1 do
          with TatBodyRelationField(FConstraintFields[K]) do
            FForeignKey := nil;
        end;

        TatBodyForeignKeys(FForeignKeys).FList.Remove(FForeignKeys[I]);
      end;

    ////////////////////////////////////////////////////////////////////////////
    // Удаление мусора из списка главных ключей
    ////////////////////////////////////////////////////////////////////////////

    for I := FPrimaryKeys.Count - 1 downto 0 do
      if FPrimaryKeys[I].IsDropped then
      begin
        TatBodyRelation(TatBodyPrimaryKey(FPrimaryKeys[I]).FRelation).FPrimaryKey := nil;
        TatBodyPrimaryKeys(FPrimaryKeys).FList.Remove(FPrimaryKeys[I]);
      end;
  end;
end;

function TatBodyDatabase.StartMultiConnectionTransaction: Boolean;
var
  ibsql: TIBSQL;
  ibtr: TIBTransaction;
begin
  Result := False;

  if FMultiConnectionTransaction = 0 then
    exit;

  if not IBLogin.IsIBUserAdmin then
  begin
    MessageBox(0,
      'Изменение мета-данных может быть выполнено только под учетной записью Administrator!',
      'Внимание',
      MB_OK or MB_ICONSTOP or MB_TASKMODAL
    );
    IBLogin.Database.Connected := False;

    PostMessage(FTreeNexus.Handle, WM_LOGOFF, 0, 0);
    exit;
  end;

  with TfrmIBUserList.Create(nil) do
  try
    if not CheckUsers then
    begin
      MessageBox(0,
        'Изменение мета-данных может быть выполнено только в однопользовательском режиме!',
        'Внимание',
        MB_OK or MB_ICONSTOP or MB_TASKMODAL
      );
      IBLogin.Database.Connected := False;

      PostMessage(FTreeNexus.Handle, WM_LOGOFF, 0, 0);
      exit;
    end;  
  finally
    Free;
  end;

  try
    IBLogin.Database.Connected := False;

    with TmetaMultiConnection.Create do
    try
      if RunScripts then
      begin
        FMultiConnectionTransaction := 0;
        Result := True;
      end;
    finally
      Free;
    end;

    FLoaded := False;
    IBLogin.Database.Connected := True;
  except
    on E: Exception do
    begin
      MessageBox(0,
        PChar(E.Message),
        'Ошибка',
        MB_ICONERROR or MB_OK or MB_TASKMODAL);

      if dmDatabase.ibdbGAdmin.TestConnected then
      begin
        ibsql := TIBSQL.Create(nil);
        ibtr := TIBTransaction.Create(nil);
        try
          ibtr.DefaultDatabase := dmDatabase.ibdbGAdmin;
          ibtr.StartTransaction;
          ibsql.Transaction := ibtr;
          ibsql.SQL.Text := 'DELETE FROM at_transaction';
          ibsql.ExecQuery;
          ibtr.Commit;
        finally
          ibsql.Free;
          ibtr.Free;
        end;
      end;

      Result := False;
    end;
  end;
end;

procedure TatBodyDatabase.ProceedLoading(Force: Boolean = False);
var
  S, DS: TStream;
  Path: array[0..1024] of Char;
begin
  CheckMultiConnectionTransaction;

  if FLoaded and not Force then
    exit;

  try
    GetTempPath(SizeOf(Path), Path);
    FFileName := IncludeTrailingBackslash(Path);
    if Assigned(IBLogin) then
      FFileName := FFileName + Format(ATTR_FILE_NAME, [IntToStr(IBLogin.DBVersionID)])
    else
      FFileName := FFileName + Format(ATTR_FILE_NAME, ['']);

    if FindCmdLineSwitch('NC', ['/', '-'], True) then
    begin
      SysUtils.DeleteFile(FFileName);
      FFileName := '';
    end;

    if (FFileName > '') and FileExists(FFileName) then
    begin
      S := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyWrite);
      try
        DS := TZDecompressionStream.Create(S);
        try
          LoadFromStream(DS);
        finally
          DS.Free;
        end;
      finally
        S.Free;
      end;

      if IsDatabaseDataRequired then
        LoadFromDatabase;
    end else
      LoadFromDatabase;

  except
    on E: Exception do
    begin
      if (E is EFOpenError) or (E is EReadError) or (E is EZDecompressionError) then
        LoadFromDatabase
      else
      begin
        FLoaded := False;
        FLoading := False;
        SysUtils.DeleteFile(FFileName);
        raise EatDatabaseError.Create(
          'Возникла ошибка при сканировании структуры базы данных.'#13#10 +
          'Возможно, необходимо выполнить обновление структуры базы данных.'#13#10 +
          'Сообщение об ошибке: '#13#10#13#10 +
          E.Message);
      end;
    end;
  end;
end;

procedure TatBodyDatabase.ForceLoadFromDatabase;
begin
  LoadFromDatabase;
end;

function TatBodyDatabase.IsDatabaseDataRequired: Boolean;
var
  ibsql: TIBSQL;
  DidActivate: Boolean;
begin
  if Relations.Count = 0 then
    Result := True
  else
  begin
    ibsql := TIBSQL.Create(nil);
    DidActivate := False;
    try
      with ibsql do
      begin
        DidActivate := not FTransaction.InTransaction;

        if DidActivate then
          FTransaction.StartTransaction;

        Transaction := FTransaction;

        SQL.Text := 'SELECT GEN_ID(gd_g_attr_version, 0) FROM RDB$DATABASE';

        ExecQuery;
        Result := Fields[0].AsInteger <> FAttrVersion;
        Close;
      end;
    finally
      if FTransaction.InTransaction and DidActivate then
        FTransaction.Commit;

      ibsql.Free;
    end;
  end;
end;

procedure TatBodyDatabase.Read(Reader: TReader);
var
  Version: String;
begin
  with Reader do
  begin
    Version := ReadString;
    if Version <> _DATABASE_STREAM_VERSION then
    begin
      Exit;
    end;

    TatBodyFields(FFields).Read(Reader);
    TatBodyRelations(FRelations).Read(Reader);

    TatBodyFields(FFields).UpdateData;

    TatBodyPrimaryKeys(FPrimaryKeys).Read(Reader);
    TatBodyForeignKeys(FForeignKeys).Read(Reader);

    TatBodyRelations(FRelations).UpdateData;

    FLastRefresh := ReadDate;

    FAttrVersion := ReadInteger;

    //
    Load_atSQLSetupCache(Reader);
  end;
end;

procedure TatBodyDatabase.Write(Writer: TWriter);
begin
  with Writer do
  begin
    WriteString(_DATABASE_STREAM_VERSION);

    TatBodyFields(FFields).Write(Writer);
    TatBodyRelations(FRelations).Write(Writer);

    TatBodyPrimaryKeys(FPrimaryKeys).Write(Writer);
    TatBodyForeignKeys(FForeignKeys).Write(Writer);

    WriteDate(FLastRefresh);
    WriteInteger(FAttrVersion);

    //
    Save_atSQLSetupCache(Writer);
  end;
end;

procedure TatBodyDatabase.SetDatabase(Value: TIBDatabase);
begin
  FDatabase := Value;

  if Assigned(FTransaction) then
    FTransaction.DefaultDatabase := FDatabase;
end;

procedure TatBodyDatabase.SetTransaction(Value: TIBTransaction);
begin
  FTransaction := Value;

  if Assigned(FTransaction) then
    FTransaction.DefaultDatabase := FDatabase;
end;

procedure TatBodyDatabase.NotifyMultiConnectionTransaction;
begin
  Inc(FMultiConnectionTransaction);
end;

procedure TatBodyDatabase.CancelMultiConnectionTransaction(const All: Boolean = False);
begin
  if All then
    FMultiConnectionTransaction := 0
  else if FMultiConnectionTransaction > 0 then
    Dec(FMultiConnectionTransaction);
end;

procedure TatBodyDatabase.CheckMultiConnectionTransaction;
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := Transaction;
    Transaction.Active := True;

    ibsql.SQL.Text :=
      'SELECT trkey FROM at_transaction';

    ibsql.ExecQuery;

    if ibsql.RecordCount > 0 then
      FMultiConnectionTransaction := 1
    else
      FMultiConnectionTransaction := 0;

    ibsql.Close;

    Transaction.Commit;
  finally
    ibsql.Free;
  end;

  //
  //  Сообщаем себе, что после выполнения алгоритмов нужно
  //  осуществить добавление атрибутов
  if FMultiConnectionTransaction > 0 then
    StartMultiConnectionTransaction;
end;

procedure TatBodyDatabase.SyncIndicesAndTriggers(ATransaction: TIBTransaction);
var
  ibsql: TIBSQL;
  DidActivate: Boolean;
  I: Integer;
begin
  DidActivate := False;
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := ATransaction;

    if not ATransaction.InTransaction then
    begin
      ATransaction.StartTransaction;
      DidActivate := True;
    end;
    try
      ibsql.Close;
      ibsql.SQL.Text := 'EXECUTE PROCEDURE at_p_sync_indexes_all';
      ibsql.ExecQuery;
      ibsql.Close;
      ibsql.SQL.Text := 'EXECUTE PROCEDURE at_p_sync_triggers_all';
      for I := 0 to 5 do
      begin
        try
          ibsql.ExecQuery;
        except
          on E: Exception do
          begin
            if ((E is EIBError) and (((E as EIBError).IBErrorCode = isc_deadlock)
              or ((E as EIBError).IBErrorCode = isc_lock_conflict)))
            then
            begin
              Sleep(3000);
              Continue;
            end else
              raise;
          end;
        end;
        Break;
      end;

      if DidActivate and ATransaction.InTransaction then
        ATransaction.Commit;

    except
      if DidActivate and ATransaction.InTransaction then
        ATransaction.Rollback;
      raise;
    end;
  finally
    ibsql.Free;
  end;
end;

{ TatBodyRelationField }

constructor TatBodyRelationField.Create(atRelation: TatRelation);
begin
  FAlignment := DefFieldAlignment;
  FColWidth := DefColWidth;
  FVisible := True;
  FAFull := DefSecurity;
  FAChag := DefSecurity;
  FAView := DefSecurity;

  FRelation := atRelation;
  FObjectsList := TStringList.Create;
  FObjectsList.Sorted := True;
  FObjectsList.Duplicates := dupError;
end;

function TatBodyRelationField.GetIsUserDefined: Boolean;
begin
  Result := AnsiPos(UserPrefix, AnsiUpperCase(FFieldName)) = 1;
end;

function TatBodyRelationField.GetSQLType: Smallint;
begin
  if Assigned(FField) then
    Result := FField.SQLType
  else
    Result := 0;
end;

function TatBodyRelationField.GetReferenceListField: TatRelationField;
begin

  if Assigned(FField.RefListField) then
    Result := FField.RefListField
  else

  if Assigned(FReferences) then
    Result := FReferences.ListField
  else
    Result := nil;  
end;

procedure TatBodyRelationField.LoadFromStream(S: TStream);
var
  Reader: TReader;
begin
  Clear;

  Reader := TReader.Create(S, 1024);
  try
    Read(Reader);
  finally
    Reader.Free;
  end;
end;

procedure TatBodyRelationField.SaveToStream(S: TStream);
var
  Writer: TWriter;
begin
  Writer := TWriter.Create(S, 1024);
  try
    Write(Writer);
  finally
    Writer.Free;
  end;
end;

procedure TatBodyRelationField.RefreshData(aDatabase: TIBDatabase;
  aTransaction: TIBTransaction);
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);

  try
    ibsql.Database := aDatabase;
    ibsql.Transaction := aTransaction;
    if not ibsql.Transaction.InTransaction then
      ibsql.Transaction.Active := True;

    ibsql.sql.Text := Format
    (
      'SELECT '#13#10 +
      '  r.rdb$field_name, r.rdb$relation_name, r.rdb$field_position, '#13#10 +
      '  r.rdb$field_source, r.rdb$null_flag, a.*, rf.rdb$computed_source, '#13#10 +
      '  r.rdb$default_source as rdefsource, rf.rdb$default_source as fdefsource, rf.rdb$default_value '#13#10 +
      'FROM '#13#10 +
      '  at_relation_fields a LEFT JOIN rdb$relation_fields r '#13#10 +
      '    ON r.rdb$relation_name = a.relationname AND '#13#10 +
      '    r.rdb$field_name = a.fieldname '#13#10 +
      '    LEFT JOIN rdb$fields rf ON a.fieldsource = rf.rdb$field_name '#13#10 +
      'WHERE '#13#10 +
      '  a.relationname = ''%0:s'' AND '#13#10 +
      '  a.fieldname = ''%1:s'' '#13#10 +
      'ORDER BY 3 ',
      [FRelation.RelationName, FFieldName]
    );

    ibsql.ExecQuery;

    if ibsql.RecordCount > 0 then
      RefreshData(ibsql.Current, aDatabase, aTransaction)
    else
      raise EatDatabaseError.CreateFmt(
        'Relation "%s" field "%s" not found in AT_RELATION_FIELDS table!',
        [FRelation.RelationName, FFieldName]);

    ibsql.Close;
  finally
    ibsql.Free;
  end;
end;

procedure TatBodyRelationField.RefreshData;
begin
  try
    RefreshData(TatBodyRelation(FRelation).FDatabase.Database,
      TatBodyRelation(FRelation).FDatabase.Transaction);

    TatBodyRelation(FRelation).FDatabase.Transaction.Commit;

  finally
    if TatBodyRelation(FRelation).FDatabase.Transaction.Active then
      TatBodyRelation(FRelation).FDatabase.Transaction.RollBack;
  end;
end;


procedure TatBodyRelationField.RefreshData(SQLRecord: TIBXSQLDA; aDatabase: TIBDatabase; aTransaction: TIBTransaction);
var
  L: Integer;
begin
  if
    ((AnsiCompareText(SQLRecord.ByName('relationname').AsTrimString,
      FRelation.RelationName) <> 0)
      or
    (AnsiCompareText(SQLRecord.ByName('fieldname').AsTrimString,
      FFieldName) <> 0)) and
    ((AnsiCompareText(SQLRecord.ByName('rdb$relation_name').AsTrimString,
      FRelation.RelationName) <> 0)
      or
    (AnsiCompareText(SQLRecord.ByName('rdb$field_name').AsTrimString,
      FFieldName) <> 0))
  then
    raise EatDatabaseError.Create('Can''t refresh relation field: incorrect relation field name!');

  FLName := TrimRight(SQLRecord.ByName('lname').AsString);
  FLShortName := TrimRight(SQLRecord.ByName('lshortname').AsString);
  FDescription := TrimRight(SQLRecord.ByName('description').AsString);
  FAlignment := StringToFieldAlignment(ReadField(SQLRecord.ByName('alignment'), 'L'));

  FFormatString := ReadField(SQLRecord.ByName('format'), '');
  FVisible := ReadField(SQLRecord.ByName('visible'), 0) <> 0;
  FIsNullable := ReadField(SQLRecord.ByName('rdb$null_flag'), 0) = 0;
  FColWidth := ReadField(SQLRecord.ByName('colwidth'), DefColWidth);
  FReadOnly := Boolean(SQLRecord.ByName('readonly').AsShort);
  FHasDefault := (not SQLRecord.ByName('rdefsource').IsNull) or
    (not SQLRecord.ByName('rdb$default_value').IsNull);

  if FHasDefault then
  begin
    if SQLRecord.ByName('rdefsource').IsNull then
      FDefaultValue := Trim(SQLRecord.ByName('fdefsource').AsString)
    else
      FDefaultValue := Trim(SQLRecord.ByName('rdefsource').AsString);
    if Pos('DEFAULT', AnsiUpperCase(FDefaultValue)) = 1 then
      FDefaultValue := Trim(Copy(FDefaultValue, 8, 1024));
    L := Length(FDefaultValue);
    if (L > 0) and (FDefaultValue[1] = '''') then
      FDefaultValue := Copy(FDefaultValue, 2, L - 2);
  end else
    FDefaultValue := '';

  FgdClassName := SQLRecord.ByName('gdclassname').AsString;
  if FgdClassName > '' then
  begin
    FgdClass := GetClass(FgdClassName);
    if FgdClass = nil then
      FgdClassName := '';
  end else
    FgdClass := nil;    

  FgdSubType := SQLRecord.ByName('gdsubtype').AsString;

  FaFull := SQLRecord.ByName('afull').AsInteger;
  FaChag := SQLRecord.ByName('achag').AsInteger;
  FaView := SQLRecord.ByName('aview').AsInteger;

  FID := SQLRecord.ByName('id').AsInteger;

  FFieldPosition := SQLRecord.ByName('rdb$field_position').AsInteger;

  FField := TatBodyRelation(FRelation).FDatabase.Fields.
    ByFieldName(SQLRecord.ByName('fieldsource').AsTrimString);

  if not Assigned(FField) then
  begin
    FField := TatBodyField.Create(TatBodyRelation(FRelation).FDatabase);
    try
      TatBodyField(Field).FFieldName := SQLRecord.ByName('fieldsource').AsTrimString;
      FField.RefreshData(aDatabase, aTransaction);
      TatBodyRelation(FRelation).FDatabase.Fields.Add(FField);
    except
      FField.Free;
      raise;
    end;
  end;

  FCrossRelationName := TrimRight(SQLRecord.ByName('crosstable').AsString);
  FCrossRelationFieldName := TrimRight(SQLRecord.ByName('crossfield').AsString);

  FHasRecord := not SQLRecord.ByName('relationname').IsNull and
    not SQLRecord.ByName('fieldname').IsNull;

  FIsComputed := not SQLRecord.ByName('rdb$computed_source').IsNull;

  FObjectsList.CommaText := SQLRecord.ByName('objects').AsString;

  UpdateData;
end;

procedure TatBodyRelationField.RecordAcquired;
var
  ibsql: TIBSQL;
begin
  Assert(not FHasRecord);

  if not FRelation.HasRecord then
    FRelation.RecordAcquired;

  if not FField.HasRecord then
    FField.RecordAcquired;

  ibsql := TIBSQL.Create(nil);

  try
    ibsql.Database := TatBodyRelation(FRelation).FDatabase.Database;
    ibsql.Transaction := TatBodyRelation(FRelation).FDatabase.Transaction;

    TatBodyRelation(FRelation).FDatabase.Transaction.Active := True;

    ibsql.SQl.Text := Format(
      'INSERT INTO AT_RELATION_FIELDS (FIELDNAME, RELATIONNAME, FIELDSOURCE, '#13#10 +
      'CROSSTABLE, CROSSFIELD, LNAME, LSHORTNAME, DESCRIPTION, ' +
      'VISIBLE, ALIGNMENT, COLWIDTH, AFULL, ACHAG, AVIEW) VALUES ' +
      '(''%0:s'', ''%1:s'', ''%2:s'', %3:s, %4:s, ''%0:s'', ''%0:s'', ''%0:s'', ' +
      '1, ''L'', 10, -1, -1, -1) ',
      [
        UpdateIBName(FFieldName), UpdateIBName(FRelation.RelationName),
        UpdateIBName(FField.FieldName),
        iff(FCrossRelationName > '', '''' + FCrossRelationName + '''', 'NULL'),
        iff(FCrossRelationFieldName > '', '''' + FCrossRelationFieldName + '''', 'NULL')
      ]
    );

    ibsql.ParamCheck := False;
    ibsql.ExecQuery;
    ibsql.Close;

    TatBodyRelation(FRelation).FDatabase.Transaction.Commit;
    FHasRecord := True;
  finally
    ibsql.Free;
    if TatBodyRelation(FRelation).FDatabase.Transaction.Active then
      TatBodyRelation(FRelation).FDatabase.Transaction.RollBack;
  end;
end;

procedure TatBodyRelationField.Clear;
begin
  FFieldName := '';
  FIsSecurityDescriptor := False;
  FLName := '';
  FLShortName := '';
  FDescription := '';
  FAlignment := DefFieldAlignment;
  FFormatString := '';
  FColWidth := DefColWidth;
  FVisible := True;
  FReadOnly := False;
  FAFull := DefSecurity;
  FAChag := DefSecurity;
  FAView := DefSecurity;

  FReferences := nil;
  FReferencesField := nil;

  FgdClassName := '';
  FgdSubType := '';
  FgdClass := nil;

  FFieldPosition := 0;

  FCrossRelationName := '';
  FCrossRelation := nil;
  FCrossRelationField := nil;
  FCrossRelationFieldName := '';

  FIsDropped := False;
end;

procedure TatBodyRelationField.Read(Reader: TReader);
var
  DataText: String;
begin
  with Reader do
  begin
    FieldName := ReadString;
    FHasRecord := ReadBoolean;

    FLName := ReadString;
    FLShortName := ReadString;
    FDescription := ReadString;
    FAlignment := StringToFieldAlignment(ReadString);
    FFormatString := ReadString;
    FColWidth := ReadInteger;
    FVisible := ReadBoolean;

    FAFull := ReadInteger;
    FAChag := ReadInteger;
    FAView := ReadInteger;

    FFieldPosition := ReadInteger;

    DataText := ReadString;
    FField := TatBodyRelation(FRelation).FDatabase.Fields.ByFieldName(DataText);

    FCrossRelationName := ReadString;
    FCrossRelationFieldName := ReadString;

    FCrossRelation := TatBodyRelation(FRelation).FDatabase.Relations.ByRelationName(FCrossRelationName);

    if Assigned(FField) then
      FCrossRelationField := FField.SetListField
    else
      FCrossRelationField := nil;

    //Оставлено для совместимости считывания аттрибутов
    ReadString; //Категория
    ReadInteger; //Порядок в категории

    FReadOnly := ReadBoolean;

    FgdClassName := ReadString;
    if FgdClassName > '' then
    begin
      FgdClass := GetClass(FgdClassName);
      if FgdClass = nil then
        FgdClassName := '';
    end else
      FgdClass := nil;    

    FgdSubType := ReadString;
    FID := ReadInteger;
    FIsComputed := ReadBoolean;

    FObjectsList.CommaText := ReadString;
    //с версии 1.3
    FHasDefault := ReadBoolean;
    FDefaultValue := ReadString;
    //c версии 1.6
    FIsNullable := ReadBoolean;
  end;
end;

procedure TatBodyRelationField.Write(Writer: TWriter);
begin
  with Writer do
  begin
    WriteString(FFieldName);
    WriteBoolean(FHasRecord);

    WriteString(FLName);
    WriteString(FLShortName);
    WriteString(FDescription);
    WriteString(FieldAlignmentToString(FAlignment));
    WriteString(FFormatString);
    WriteInteger(FColWidth);
    WriteBoolean(FVisible);

    WriteInteger(FAFull);
    WriteInteger(FAChag);
    WriteInteger(FAView);

    WriteInteger(FFieldPosition);

    WriteString(FField.FieldName);

    WriteString(FCrossRelationName);
    WriteString(FCrossRelationFieldName);

    //Оставлено для совместимости при считывании аттрибутов
    WriteString(''); //категория
    WriteInteger(0); //порядок в категории

    WriteBoolean(FReadOnly);

{ TODO :
в одном месте вначале записывается подтип, потом класс,
а в другом сначала класс потом подтип. Плохо! }
    WriteString(FgdClassName);
    WriteString(FgdSubType);
    WriteInteger(FID);
    WriteBoolean(FIsComputed);

    WriteString(FObjectsList.CommaText);
    //с версии 1.3
    WriteBoolean(FHasDefault);
    WriteString(FDefaultValue);
    //с версии 1.6
    WriteBoolean(FIsNullable);
  end;
end;

procedure TatBodyRelationField.UpdateData;
begin
  FCrossRelation := TatBodyRelation(Frelation).FDatabase.Relations.ByRelationName(FCrossRelationName);

  if Assigned(FField) then
    FCrossRelationField := FField.SetListField
  else
    FCrossRelationField := nil;
end;

(*
function TatBodyRelationField.GetIsSecurityDescriptor: Boolean;
begin
  Result := (FieldName = 'AFULL')
    or (FieldName = 'ACHAG')
    or (FieldName = 'AVIEW');
//  Result := StrIPos(FieldName + ',', 'afull,achag,aview,') > 0;
end;
*)

function TatBodyRelationField.GetVisible: Boolean;
begin
  Result := FVisible
    {$IFDEF GEDEMIN}
    // только для проекта Гедемин мы скроем
    // все поля-дескрипторы безопасности
    // от пользовательского ока
    and (not IsSecurityDescriptor)
    {$ENDIF}
end;

destructor TatBodyRelationField.Destroy;
begin
  FObjectsList.Free;
  inherited;
end;

function TatBodyRelationField.InObject(const AName: String): Boolean;
begin
  Result := FObjectsList.IndexOf(AName) <> -1;
end;

procedure TatBodyRelationField.SetFieldName(const AFieldName: String);
begin
  FFieldName := AFieldName;
  FIsSecurityDescriptor := (FFieldName = 'AFULL')
    or (FFieldName = 'ACHAG')
    or (FFieldName = 'AVIEW');
end;

{ TatBodyForeignKeys }

function TatBodyForeignKeys.Add(atForeignKey: TatForeignKey): Integer;
begin
  if not Assigned(atForeignKey) then Exit;

  Find(atForeignKey.ConstraintName, Result);
  FList.Insert(Result, atForeignKey);
end;

procedure TatBodyForeignKeys.Clear;
begin
  FList.Clear;
end;

constructor TatBodyForeignKeys.Create;
begin
  inherited Create;
  FDatabase := ADatabase;

  FList := TObjectList.Create;
end;

procedure TatBodyForeignKeys.Delete(const Index: Integer);
begin
  FList.Delete(Index);
end;

function TatBodyForeignKeys.ByConstraintName(AConstraintName: String): TatForeignKey;
var
  I: Integer;
begin
  if Find(Trim(AConstraintName), I) then
    Result := Items[I]
  else
    Result := nil;  
end;

destructor TatBodyForeignKeys.Destroy;
begin
  inherited;
  FList.Free;
end;

function TatBodyForeignKeys.GetCount: Integer;
begin
  TatBodyDatabase(FDatabase).KillGarbage;
  Result := FList.Count;
end;

function TatBodyForeignKeys.GetItems(Index: Integer): TatForeignKey;
begin
  Result := FList[Index] as TatForeignKey;
end;

function TatBodyForeignKeys.Find(const S: string; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := FList.Count - 1;

  while L <= H do
  begin
    I := (L + H) shr 1;
    C := AnsiCompareText((FList[I] as TatForeignKey).ConstraintName, S);

    if C < 0 then
      L := I + 1
    else begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
        L := I;
      end;
    end;
  end;

  Index := L;
end;

procedure TatBodyForeignKeys.LoadFromStream(S: TStream);
var
  Reader: TReader;
begin
  Reader := TReader.Create(S, 1024);
  try
    Read(Reader);
  finally
    Reader.Free;
  end;
end;

procedure TatBodyForeignKeys.SaveToStream(S: TStream);
var
  Writer: TWriter;
begin
  Writer := TWriter.Create(S, 1024);
  try
    Write(Writer);
  finally
    Writer.Free;
  end;
end;

procedure TatBodyForeignKeys.ConstraintsByRelation(const RelationName: String;
  List: TObjectList);
var
  I: Integer;
  R: TatRelation;
begin
  List.Clear;
  R := FDatabase.Relations.ByRelationName(RelationName);

  if Assigned(R) then
    for I := 0 to Count - 1 do
      if TatBodyForeignKey(Items[I]).FRelation = R then
        List.Add(Items[I]);
end;

procedure TatBodyForeignKeys.Read(Reader: TReader);
var
  NewForeignKey: TatBodyForeignKey;
begin
  with Reader do
  begin
    ReadListBegin;

    while not EndOfList do
    begin
      NewForeignKey := TatBodyForeignKey.Create(FDatabase);
      NewForeignKey.Read(Reader);
      FList.Add(NewForeignKey);
    end;

    ReadListEnd;
  end;
end;

procedure TatBodyForeignKeys.Write(Writer: TWriter);
var
  I: Integer;
begin
  with Writer do
  begin
    WriteListBegin;

    for I := 0 to Count - 1 do
      TatBodyForeignKey(Items[I]).Write(Writer);

    WriteListEnd;
  end;
end;

procedure TatBodyForeignKeys.ConstraintsByReferencedRelation(
  const RelationName: String; List: TObjectList; const ClearList: Boolean = True);
var
  I: Integer;
  R: TatRelation;
begin
  if ClearList then
    List.Clear;
  R := FDatabase.Relations.ByRelationName(RelationName);
  for I := 0 to Count - 1 do
    if Items[I].ReferencesRelation = R then List.Add(Items[I]);
end;

function TatBodyForeignKeys.ByRelationAndReferencedRelation(
  const ARelationName, AReferencedRelationName: String): TatForeignKey;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do with Items[I] do
    if (AnsiCompareText(Relation.RelationName, Trim(ARelationName)) = 0) and
      (AnsiCompareText(ReferencesRelation.RelationName, Trim(AReferencedRelationName)) = 0) then
    begin
      Result := Items[I];
      break;
    end;
end;

function TatBodyForeignKeys.IndexOf(AObject: TObject): Integer;
begin
  Result := FList.IndexOf(AObject);
end;

{ TatBodyPrimaryKey }

constructor TatBodyPrimaryKey.Create;
begin
  inherited Create;

  FDatabase := ADatabase;
  FConstraintFields := TatBodyRelationFields.Create(nil, False);
  FConstraintFields.Sorted := False;
  FIsDropped := False;
end;

destructor TatBodyPrimaryKey.Destroy;
begin
  inherited;
  FConstraintFields.Free;
end;

procedure TatBodyPrimaryKey.RefreshData;
begin
  try
    RefreshData(FDatabase.Database, FDatabase.Transaction);

    FDatabase.Transaction.Commit;

  finally
    if FDatabase.Transaction.Active then
      FDatabase.Transaction.RollBack;
  end;
end;

procedure TatBodyPrimaryKey.RefreshData(aDatabase: TIBDatabase;
  aTransaction: TIBTransaction);
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);

  try
    ibsql.Database := aDatabase;
    ibsql.Transaction := aTransaction;

    if not ibsql.Transaction.InTransaction then
      ibsql.Transaction.StartTransaction;

    ibsql.SQL.Text := Format(
      'SELECT '#13#10 +
      '  RC.RDB$RELATION_NAME, '#13#10 +
      '  RC.RDB$CONSTRAINT_NAME, '#13#10 +
      '  RC.RDB$INDEX_NAME, '#13#10 +
      '  INDSEG.RDB$FIELD_NAME, '#13#10 +
      '  INDSEG.RDB$FIELD_POSITION '#13#10 +
      ' '#13#10 +
      'FROM '#13#10 +
      '  RDB$RELATION_CONSTRAINTS RC '#13#10 +
      '    JOIN '#13#10 +
      '      RDB$INDEX_SEGMENTS INDSEG '#13#10 +
      '    ON '#13#10 +
      '      RC.RDB$INDEX_NAME = INDSEG.RDB$INDEX_NAME '#13#10 +
      ' '#13#10 +
      'WHERE '#13#10 +
      '  RC.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' '#13#10 +
      '    AND '#13#10 +
      '  RC.RDB$CONSTRAINT_NAME = ''%s'' '#13#10 +
      ' '#13#10 +
      'ORDER BY '#13#10 +
      '  RC.RDB$RELATION_NAME, '#13#10 +
      '  INDSEG.RDB$FIELD_POSITION ',
      [UpdateIBName(FConstraintName)]
    );

    ibsql.ExecQuery;

    if ibsql.RecordCount > 0 then
      RefreshData(ibsql)
    else
      raise EatDatabaseError.CreateFmt(
        'Constraint "%s" is dropped!', [FConstraintName]);

    ibsql.Close;

  finally
    ibsql.Free;

  end;
end;

procedure TatBodyPrimaryKey.RefreshData(ibsql: TIBSQL);
begin
  if AnsiCompareText(ibsql.FieldByName('RDB$CONSTRAINT_NAME').AsTrimString,
    FConstraintName) <> 0
  then
    raise EatDatabaseError.Create('Can''t refresh constraint: incorrect constraint name!');

  FConstraintName := ibsql.FieldByName('RDB$CONSTRAINT_NAME').AsTrimString;

  FRelation := FDatabase.Relations.ByRelationName(
    ibsql.FieldByName('RDB$RELATION_NAME').AsTrimString);

  FIndexName := ibsql.FieldByName('RDB$INDEX_NAME').AsTrimString;
  TatBodyRelationFields(FConstraintFields).Clear;

  while not ibsql.EOF do
  begin
    if AnsiCompareText(ibsql.FieldByName('RDB$CONSTRAINT_NAME').AsTrimString,
      FConstraintName) <> 0
    then
      Exit;

    if Assigned(Relation) then
      ConstraintFields.Add(
        Relation.RelationFields.ByFieldName(
          ibsql.FieldByName('RDB$FIELD_NAME').AsTrimString));

    ibsql.Next;
  end;

  if Assigned(FRelation) and (ConstraintFields.Count > 0) then
    TatBodyRelation(FRelation).FPrimaryKey := Self
  else
    TatBodyRelation(FRelation).FPrimaryKey := nil;
end;

procedure TatBodyPrimaryKey.LoadFromStream(S: TStream);
var
  Reader: TReader;
begin
  Reader := TReader.Create(S, 1024);
  try
    Read(Reader);
  finally
    Reader.Free;
  end;
end;

procedure TatBodyPrimaryKey.Read(Reader: TReader);
var
  DataText: String;
begin
  with Reader do
  begin
    FIndexName := ReadString;
    FConstraintName := ReadString;

    DataText := ReadString;
    FRelation := FDatabase.Relations.ByRelationName(DataText);

    ReadListBegin;

    while not EndOfList do
    begin
      DataText := ReadString;

      if Assigned(FRelation) then
        FConstraintFields.Add(FRelation.RelationFields.ByFieldName(DataText));
    end;

    ReadListEnd;

    if Assigned(FRelation) then
      TatBodyRelation(FRelation).FPrimaryKey := Self;
  end;
end;

procedure TatBodyPrimaryKey.Write(Writer: TWriter);
var
  I: Integer;
begin
  Assert(Assigned(FRelation));

  with Writer do
  begin
    WriteString(FIndexName);
    WriteString(FConstraintName);

    WriteString(FRelation.RelationName);

    WriteListBegin;

    for I := 0 to FConstraintFields.Count - 1 do
      WriteString(FConstraintFields[I].FieldName);

    WriteListEnd;
  end;
end;

procedure TatBodyPrimaryKey.SaveToStream(S: TStream);
var
  Writer: TWriter;
begin
  Writer := TWriter.Create(S, 1024);
  try
    Write(Writer);
  finally
    Writer.Free;
  end;
end;

{ TatBodyPrimaryKeys }

function TatBodyPrimaryKeys.Add(atPrimaryKey: TatPrimaryKey): Integer;
begin
  if not Assigned(atPrimaryKey) then Exit;
  Find(atPrimaryKey.ConstraintName, Result);
  FList.Insert(Result, atPrimaryKey);
end;

procedure TatBodyPrimaryKeys.Clear;
begin
  FList.Clear;
end;

constructor TatBodyPrimaryKeys.Create;
begin
  inherited Create;
  FDatabase := ADatabase;
  FList := TObjectList.Create;
end;

procedure TatBodyPrimaryKeys.Delete(const Index: Integer);
begin
  FList.Delete(Index);
end;

function TatBodyPrimaryKeys.ByConstraintName(AConstraintName: String): TatPrimaryKey;
var
  I: Integer;
begin
  if Find(Trim(AConstraintName), I) then
    Result := Items[I]
  else
    Result := nil;  
end;

destructor TatBodyPrimaryKeys.Destroy;
begin
  inherited;
  FList.Free;
end;

function TatBodyPrimaryKeys.GetCount: Integer;
begin
  TatBodyDatabase(FDatabase).KillGarbage;
  Result := FList.Count;
end;

function TatBodyPrimaryKeys.GetItems(Index: Integer): TatPrimaryKey;
begin
  Result := FList[Index] as TatPrimaryKey;
end;

function TatBodyPrimaryKeys.Find(const S: string; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := FList.Count - 1;

  while L <= H do
  begin
    I := (L + H) shr 1;
    C := AnsiCompareText((FList[I] as TatPrimaryKey).ConstraintName, S);

    if C < 0 then
      L := I + 1
    else begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
        L := I;
      end;
    end;
  end;

  Index := L;
end;

procedure TatBodyPrimaryKeys.LoadFromStream(S: TStream);
var
  Reader: TReader;
begin
  Reader := TReader.Create(S, 1024);
  try
    Read(Reader);
  finally
    Reader.Free;
  end;
end;

procedure TatBodyPrimaryKeys.SaveToStream(S: TStream);
var
  Writer: TWriter;
begin
  Writer := TWriter.Create(S, 1024);
  try
    Write(Writer);
  finally
    Writer.Free;
  end;
end;

procedure TatBodyPrimaryKeys.CollectRelationConstraints(const RelationName: String;
  List: TObjectList);
var
  I: Integer;
  R: TatRelation;
begin
  List.Clear;
  R := FDatabase.Relations.ByRelationName(RelationName);

  if Assigned(R) then
    for I := 0 to Count - 1 do
      if TatBodyPrimaryKey(Items[I]).FRelation = R then
        List.Add(Items[I]);
end;

procedure TatBodyPrimaryKeys.Read(Reader: TReader);
var
  NewPrimaryKey: TatBodyPrimaryKey;
begin
  with Reader do
  begin
    ReadListBegin;

    while not EndOfList do
    begin
      NewPrimaryKey := TatBodyPrimaryKey.Create(FDatabase);
      NewPrimaryKey.Read(Reader);
      FList.Add(NewPrimaryKey);
    end;

    ReadListEnd;
  end;
end;

procedure TatBodyPrimaryKeys.Write(Writer: TWriter);
var
  I: Integer;
begin
  with Writer do
  begin
    WriteListBegin;

    for I := 0 to Count - 1 do
      TatBodyPrimaryKey(Items[I]).Write(Writer);

    WriteListEnd;
  end;
end;

function TatBodyPrimaryKeys.IndexOf(AObject: TObject): Integer;
begin
  Result := FList.IndexOf(AObject);
end;

{ TatBodyForeignKey }

constructor TatBodyForeignKey.Create;
begin
  FDatabase := ADatabase;
  FConstraintFields := TatBodyRelationFields.Create(nil, False);
  FReferencesFields := TatBodyRelationFields.Create(nil, False);
  FConstraintFields.Sorted := False;
  FReferencesFields.Sorted := False;
  FIsDropped := False;
end;

destructor TatBodyForeignKey.Destroy;
begin
  FConstraintFields.Free;
  FReferencesFields.Free;

  inherited;
end;

procedure TatBodyForeignKey.RefreshData;
begin
  try
    RefreshData(FDatabase.Database, FDatabase.Transaction);

    FDatabase.Transaction.Commit;

  finally
    if FDatabase.Transaction.Active then
      FDatabase.Transaction.RollBack;
  end;
end;

procedure TatBodyForeignKey.RefreshData(aDatabase: TIBDatabase;
  aTransaction: TIBTransaction);
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);

  try
    ibsql.Database := aDatabase;
    ibsql.Transaction := aTransaction;

    if not ibsql.Transaction.InTransaction then
      ibsql.Transaction.StartTransaction;

    ibsql.SQL.Text := Format(
      'SELECT '#13#10 +
      '  RC.RDB$RELATION_NAME AS RELATIONNAME, '#13#10 +
      '  RC.RDB$CONSTRAINT_NAME AS CONSTRAINTNAME, '#13#10 +
      '  RC.RDB$INDEX_NAME AS INDEXNAME, '#13#10 +
      '  INDSEG.RDB$FIELD_NAME AS FIELDNAME, '#13#10 +
      '  INDSEG.RDB$FIELD_POSITION AS FIELDPOS, '#13#10 +
      '  REFC.RDB$CONST_NAME_UQ AS FCONSTRAINT, '#13#10 +
      '  RC2.RDB$RELATION_NAME AS FRELATIONNAME, '#13#10 +
      '  RC2.RDB$INDEX_NAME AS FINDEXNAME, '#13#10 +
      '  INDSEG2.RDB$FIELD_NAME AS FFIELDNAME, '#13#10 +
      '  REFC.RDB$UPDATE_RULE AS UPDATE_RULE, '#13#10 +
      '  REFC.RDB$DELETE_RULE AS DELETE_RULE '#13#10 +
      ' '#13#10 +
      'FROM '#13#10 +
      '  RDB$RELATION_CONSTRAINTS RC '#13#10 +
      '    JOIN '#13#10 +
      '      RDB$INDEX_SEGMENTS INDSEG '#13#10 +
      '    ON '#13#10 +
      '      RC.RDB$INDEX_NAME = INDSEG.RDB$INDEX_NAME '#13#10 +
      '    JOIN '#13#10 +
      '      RDB$REF_CONSTRAINTS REFC '#13#10 +
      '    ON '#13#10 +
      '      REFC.RDB$CONSTRAINT_NAME = RC.RDB$CONSTRAINT_NAME, '#13#10 +
      '       '#13#10 +
      '  RDB$RELATION_CONSTRAINTS RC2 '#13#10 +
      '    JOIN '#13#10 +
      '      RDB$INDEX_SEGMENTS INDSEG2 '#13#10 +
      '    ON '#13#10 +
      '      RC2.RDB$INDEX_NAME = INDSEG2.RDB$INDEX_NAME '#13#10 +
      ' '#13#10 +
      'WHERE '#13#10 +
      '  RC2.RDB$CONSTRAINT_NAME = REFC.RDB$CONST_NAME_UQ '#13#10 +
      '    AND '#13#10 +
      '  INDSEG.RDB$FIELD_POSITION = INDSEG2.RDB$FIELD_POSITION '#13#10 +
      '    AND '#13#10 +
      '  RC.RDB$CONSTRAINT_NAME = ''%s'' '#13#10 +
      ' '#13#10 +
      'ORDER BY '#13#10 +
      '  RC.RDB$RELATION_NAME, '#13#10 +
      '  INDSEG.RDB$FIELD_POSITION '#13#10 +
      ' '#13#10,
      [FConstraintName]
    );

    ibsql.ExecQuery;

    if ibsql.RecordCount > 0 then
      RefreshData(ibsql)
    else
      raise EatDatabaseError.CreateFmt(
        'Constraint %s is dropped!', [FConstraintName]);

    ibsql.Close;
  finally
    ibsql.Free;
  end;

end;

procedure TatBodyForeignKey.RefreshData(ibsql: TIBSQL);
var
  I: Integer;
begin
  if AnsiCompareText(ibsql.FieldByName('CONSTRAINTNAME').AsTrimString,
    FConstraintName) <> 0
  then
    raise EatDatabaseError.Create('Can''t refresh constraint: incorrect constraint name!');

  FConstraintName :=
    ibsql.FieldByName('CONSTRAINTNAME').AsTrimString;

  FIndexName :=
    ibsql.FieldByName('INDEXNAME').AsTrimString;

  FRelation := FDatabase.Relations.ByRelationName(
    ibsql.FieldByName('RELATIONNAME').AsTrimString);

  FReferencesRelation := FDatabase.Relations.ByRelationName(
    ibsql.FieldByName('FRELATIONNAME').AsTrimString);

  FReferencesIndex :=
    ibsql.FieldByName('FINDEXNAME').AsTrimString;

  FUpdateRule :=
    StringToUpdateDeleteRule(ibsql.FieldByName('UPDATE_RULE').AsTrimString);

  FDeleteRule :=
    StringToUpdateDeleteRule(ibsql.FieldByName('DELETE_RULE').AsTrimString);

  TatBodyRelationFields(FConstraintFields).Clear;
  TatBodyRelationFields(FReferencesFields).Clear;

  try
    while not ibsql.Eof do
    begin
      if AnsiCompareText(ibsql.FieldByName('CONSTRAINTNAME').AsTrimString,
        FConstraintName) <> 0
      then
        Exit;

      if Assigned(FRelation) then
        FConstraintFields.Add(
          FRelation.RelationFields.ByFieldName(
            ibsql.FieldByName('FIELDNAME').AsTrimString));

      if Assigned(FReferencesRelation) then
        FReferencesFields.Add(
          FReferencesRelation.RelationFields.ByFieldName(
            ibsql.FieldByName('FFIELDNAME').AsTrimString));

      ibsql.Next;
    end;

  finally
    if IsSimpleKey then
    begin
      TatBodyRelationField(ConstraintField).FReferences := FReferencesRelation;
      TatBodyRelationField(ConstraintField).FReferencesField := ReferencesField;
    end;

    for I := 0 to FConstraintFields.Count - 1 do
    with TatBodyRelationField(FConstraintFields[I]) do
      FForeignKey := Self;
  end;
end;

procedure TatBodyForeignKey.LoadFromStream(S: TStream);
var
  Reader: TReader;
begin
  Reader := TReader.Create(S, 1024);
  try
    Read(Reader);
  finally
    Reader.Free;
  end;
end;

procedure TatBodyForeignKey.SaveToStream(S: TStream);
var
  Writer: TWriter;
begin
  Writer := TWriter.Create(S, 1024);
  try
    Write(Writer);
  finally
    Writer.Free;
  end;
end;

function TatBodyForeignKey.GetConstraintField: TatRelationField;
begin
  if IsSimpleKey then
    Result := FConstraintFields[0]
  else
    Result := nil;
end;

function TatBodyForeignKey.GetReferencesField: TatRelationField;
begin
  if IsSimpleKey then
    Result := FReferencesFields[0]
  else
    Result := nil;
end;

function TatBodyForeignKey.GetIsSimpleKey: Boolean;
begin
  Result := (FConstraintFields.Count = 1) and (FReferencesFields.Count = 1);
end;

procedure TatBodyForeignKey.Read(Reader: TReader);
var
  DataText: String;
  I: Integer;
begin
  with Reader do
  begin
    FConstraintName := ReadString;
    FIndexName := ReadString;
    FReferencesIndex := ReadString;

    DataText := ReadString;
    FRelation := FDatabase.Relations.ByRelationName(DataText);

    DataText := ReadString;
    FReferencesRelation := FDatabase.Relations.ByRelationName(DataText);

    ReadListBegin;

    while not EndOfList do
    begin
      DataText := ReadString;

      if Assigned(FRelation) then
        FConstraintFields.Add(FRelation.RelationFields.ByFieldName(DataText));
    end;

    ReadListEnd;


    ReadListBegin;

    while not EndOfList do
    begin
      DataText := ReadString;

      if Assigned(FReferencesRelation) then
        FReferencesFields.Add(FReferencesRelation.RelationFields.ByFieldName(DataText));
    end;

    ReadListEnd;

    if IsSimpleKey then
    begin
      TatBodyRelationField(ConstraintField).FReferences := FReferencesRelation;
      TatBodyRelationField(ConstraintField).FReferencesField := ReferencesField;
    end;

    for I := 0 to FConstraintFields.Count - 1 do
    with TatBodyRelationField(FConstraintFields[I]) do
      FForeignKey := Self;
  end;
end;

procedure TatBodyForeignKey.Write(Writer: TWriter);
var
  I: Integer;
begin
  with Writer do
  begin
    WriteString(FConstraintName);
    WriteString(FIndexName);
    WriteString(FReferencesIndex);

    WriteString(FRelation.RelationName);
    WriteString(FReferencesRelation.RelationName);

    WriteListBegin;

    for I := 0 to FConstraintFields.Count - 1 do
      WriteString(FConstraintFields[I].FieldName);

    WriteListEnd;


    WriteListBegin;

    for I := 0 to FReferencesFields.Count - 1 do
      WriteString(FReferencesFields[I].FieldName);

    WriteListEnd;
  end;
end;

function TatBodyRelation.GetHasSecurityDescriptors: Boolean;
begin
  Result :=
    (RelationFields.ByFieldName('AFULL') <> nil) and
    (RelationFields.ByFieldName('ACHAG') <> nil) and
    (RelationFields.ByFieldName('AVIEW') <> nil);
end;

initialization
  atDatabase := TatBodyDatabase.Create;

finalization
  FreeAndNil(atDatabase);

end.

