
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdcInvDocument_unit.pas

  Abstract

    Business class. Inventory base document.

  Author

    Romanovski Denis (17-09-2001)

  Revisions history

    Initial  17-09-2001  Dennis  Initial version.
    Changed  09-11-2001  Michael Minor changes
--}

unit gdcInvDocument_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdcBase, gd_createable_form, gdcClasses, at_Classes, gdcInvConsts_unit,
  gdcInvMovement, IBDatabase, DB, IBSQL, IB, IBErrorCodes,
  gdcBaseInterface, ComObj, gd_resourcestring, gd_KeyAssoc;

const
  //
  // Версия документа для потока

  // Незаконченный документ (не до конца настроенный документ)
  gdcInv_Document_Undone = 'UNDONE';
  // Версия 1.6
  gdcInvDocument_Version1_6 = 'IDV1.6';
  // Версия 1.7
  gdcInvDocument_Version1_7 = 'IDV1.7';
  // Версия 1.8
  gdcInvDocument_Version1_8 = 'IDV1.8';
  // Версия 1.9
  gdcInvDocument_Version1_9 = 'IDV1.9';
  // Версия 2.0
  gdcInvDocument_Version2_0 = 'IDV2.0';
  // Версия 2.1
  gdcInvDocument_Version2_1 = 'IDV2.1';
  // Версия 2.2
  gdcInvDocument_Version2_2 = 'IDV2.2';
  // Версия 2.3
  gdcInvDocument_Version2_3 = 'IDV2.3';
  // Версия 2.4
  gdcInvDocument_Version2_4 = 'IDV2.4';
  // Версия 2.5
  gdcInvDocument_Version2_5 = 'IDV2.5';
  // Версия 2.6
  gdcInvDocument_Version2_6 = 'IDV2.6';


{$IFDEF DEBUGMOVE}
const
  TimeCustomInsertUSR: LongWord = 0;
  TimeCustomInsertDoc: LongWord = 0;
  TimeDoOnNewRecord: LongWord = 0;
  TimeGetRemains: LongWord = 0;
  TimeMakeMovement: LongWord = 0;
  TimeMakePos: LongWord = 0;
  TimeMakeInsert: LongWord = 0;
  TimeQueryList: LongWord = 0;
  TimeFillPosition: LongWord = 0;

  TimePostInPosition: LongWord = 0;
{$ENDIF}


type
  TgdcInvRelationAlias = record
    RelationName: String[31];
    AliasName: String[31];
  end;

  TgdcInvRelationAliases = array of TgdcInvRelationAlias;

type
  TgdcInvDocumentType = class;

  TgdcInvBaseDocument = class;
  TgdcInvBaseDocumentClass = class of TgdcInvBaseDocument;

  TgdcInvBaseDocument = class(TgdcDocument)
  private
    FRelationName, FRelationLineName: String; // Наименование физической таблицы
    FMovementSource, FMovementTarget:
      TgdcInvMovementContactOption; // Источник и получатель движения7

    FDocumentTypeKey: Integer; // Тип документа
    FReportGroupKey: Integer; // Ключ группы отчетов
    FBranchKey: Integer; // Ветка в исследователе


    FSetupProceeded: Boolean; // Осуществлено ли чтение и настройка документа
    FCurrentStreamVersion: String; // Версия настроек, считанных из потока

    FContact: TIBSQL;

    function EnumRelationFields(const Alias: String; SkipList: String;
      const UseDot: Boolean = True): String;
    function EnumModificationList(const ExcludeField: String = ''): String;

    function EnumRelationJoins(Relations: TgdcInvRelationAliases): String;
    function EnumJoinedListFields(Relations: TgdcInvRelationAliases): String;

    function GetRelation: TatRelation;
    function GetRelationLine: TatRelation;

    function GetRelationType: TgdcInvRelationType;

    procedure CreateContactSQL;
    procedure UpdatePredefinedFields;

  protected
    FStreamOptions: TStream;

    procedure CreateFields; override;
    procedure SetActive(Value: Boolean); override;

    procedure SetSubType(const Value: String); override;

    procedure WriteOptions(Stream: TStream); virtual;

    function GetJoins: TStringList; virtual; abstract;
    procedure SetJoins(const Value: TStringList); virtual; abstract;

    function GetGroupID: Integer; override;
    function GetNotCopyField: String; override;
    function CheckTheSameStatement: String; override;

    property Joins: TStringList read GetJoins write SetJoins;

  public
    constructor Create(AnOwner: TComponent); override;
    constructor CreateSubType(AnOwner: TComponent; const ASubType: TgdcSubType;
      const ASubSet: TgdcSubSet = 'All'); override;

    destructor Destroy; override;

    function JoinListFieldByFieldName(const AFieldName, AAliasName, AJoinFieldName: String): String;

    procedure ReadOptions(Stream: TStream); virtual;

    class function GetSubTypeList(SubTypeList: TStrings): Boolean; override;
    class function IsAbstractClass: Boolean; override;

    property MovementSource: TgdcInvMovementContactOption read FMovementSource; // Источник движения
    property MovementTarget: TgdcInvMovementContactOption read FMovementTarget; // получатель движения

    property RelationName: String read FRelationName;
    property RelationLineName: String read FRelationLineName;

    property Relation: TatRelation read GetRelation;
    property RelationLine: TatRelation read GetRelationLine;

    function DocumentTypeKey: Integer; override;

    property RelationType: TgdcInvRelationType read GetRelationType;

    property CurrentStreamVersion: String read FCurrentStreamVersion;

    property BranchKey: Integer read FBranchKey;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;


  TgdcInvDocument = class(TgdcInvBaseDocument)
  private
    FJoins: TStringList;

//    FIsPrePosted: Boolean;

  protected

    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetGroupClause: String; override;
    function GetOrderClause: String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    procedure _DoOnNewRecord; override;

    procedure DoAfterCancel; override;
    procedure DoAfterClose; override;
    procedure DoAfterDelete; override;
    procedure DoAfterOpen; override;
    procedure DoAfterPost; override;

    function CreateDialogForm: TCreateableForm; override;

    function GetJoins: TStringList; override;
    procedure SetJoins(const Value: TStringList); override;
    function GetDetailObject: TgdcDocument; override;

  public
    procedure InternalSetFieldData(Field: TField; Buffer: Pointer); override;
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetDocumentClassPart: TgdcDocumentClassPart; override;

//    procedure PrePostDocumentData;

  published

  end;

  TgdcInvDocumentLine = class(TgdcInvBaseDocument)
  private
    FSourceFeatures, FDestFeatures, FMinusFeatures: TgdcInvFeatures; // Массив настроек признаков
    FDirection: TgdcInvMovementDirection; // Направление движения (FIFO, LIFO)

    FMovement: TgdcInvMovement; // Объект работы с движением ТМЦ

    FLineJoins: TStringList; // Список соединений с другими таблицами
    FSources: TgdcInvReferenceSources; // Источники справочной информации

    FGoodSQL: TIBSQL; // Запрос к справочнику товаров
    FViewMovementPart: TgdcInvMovementPart; // Вариант визуального представления

    FControlRemains: Boolean; // Нужно ли контролировать остатки
    FLiveTimeRemains: Boolean; // Работа только с текущими остатками
    FEndMonthRemains: Boolean; // Контроль на конец месяца

    FUseCachedUpdates: Boolean; // Нужно ли использовать CachedUpdates
    FCanBeDelayed: Boolean; // Отложенность документа
    FisErrorUpdate: Boolean; //
    FisErrorInsert: Boolean;
    FIsMinusRemains: Boolean;
    FisSetFeaturesFromRemains: Boolean;
    FisChangeCardValue: Boolean;
    FisAppendCardValue: Boolean;
    FSavePoint: String;
    FisCheckDestFeatures: Boolean;
    FisChooseRemains: Boolean;
    FUseGoodKeyForMakeMovement: Boolean;
    FIsMakeMovementOnFromCardKeyOnly: Boolean;
    FIsUseCompanyKey: Boolean;
    FSaveRestWindowOption: Boolean;

    function EnumCardFields(const Alias: String; Kind: TgdcInvFeatureKind;
      const AsName: String = ''): String;
    function IsFeatureUsed(const FieldName: String; Features: TgdcInvFeatures): Boolean;

    procedure SetViewMovementPart(const Value: TgdcInvMovementPart);
    procedure SetIsMakeMovementOnFromCardKeyOnly(const Value: Boolean);

  protected

    procedure WriteOptions(Stream: TStream); override;

    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetGroupClause: String; override;
    function GetOrderClause: String; override;

    function GetNotCopyField: String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;
    procedure CustomDelete(Buff: Pointer); override;

    function CreateDialogForm: TCreateableForm; override;
    procedure CreateFields; override;

    procedure _DoOnNewRecord; override;
    procedure DoBeforeInsert; override;
    procedure DoAfterCancel; override;
    procedure DoBeforePost; override;
    procedure DoOnCalcFields; override;

    function GetJoins: TStringList; override;
    procedure SetJoins(const Value: TStringList); override;

    procedure GetWhereClauseConditions(S: TStrings); override;

    procedure SetSubType(const Value: String); override;
    function GetMasterObject: TgdcDocument; override;
    procedure SaveHeader;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure ReadOptions(Stream: TStream); override;

    function ChooseRemains: Boolean;
    function SelectGoodFeatures: Boolean;

    procedure UpdateGoodNames;
    procedure SetFeatures(isFrom, isTo: Boolean);

    class function GetDocumentClassPart: TgdcDocumentClassPart; override;

    property Sources: TgdcInvReferenceSources read FSources;
    property Direction: TgdcInvMovementDirection read FDirection;

    property SourceFeatures: TgdcInvFeatures read FSourceFeatures;
    property DestFeatures: TgdcInvFeatures read FDestFeatures;
    property MinusFeatures : TgdcInvFeatures read FMinusFeatures;

    property ViewMovementPart: TgdcInvMovementPart read FViewMovementPart write SetViewMovementPart;
    property ControlRemains: Boolean read FControlRemains write FControlRemains;
    property Movement: TgdcInvMovement read FMovement;
    property UseCachedUpdates: Boolean read FUseCachedUpdates;
    property CanBeDelayed: Boolean read FCanBeDelayed;
    property LiveTimeRemains: Boolean read FLiveTimeRemains write FLiveTimeRemains;
    property EndMonthRemains: Boolean read FEndMonthRemains write FEndMonthRemains;
    property isMinusRemains: Boolean read FIsMinusRemains write FIsMinusRemains;
    property isSetFeaturesFromRemains: Boolean read FisSetFeaturesFromRemains
      write FisSetFeaturesFromRemains;
    property isChooseRemains: Boolean read FisChooseRemains
      write FisChooseRemains;


    property isChangeCardValue: Boolean read FisChangeCardValue write FisChangeCardValue;
    property isAppendCardValue: Boolean read FisAppendCardValue write FisAppendCardValue;
    property isUseCompanyKey: Boolean read FIsUseCompanyKey write FIsUseCompanyKey;
    property SaveRestWindowOption: Boolean read FSaveRestWindowOption write FSaveRestWindowOption;
    property SavePoint: String read FSavePoint;

    property isCheckDestFeatures: Boolean read FisCheckDestFeatures write FisCheckDestFeatures default True;
    property UseGoodKeyForMakeMovement: Boolean read FUseGoodKeyForMakeMovement write FUseGoodKeyForMakeMovement default False;
    property IsMakeMovementOnFromCardKeyOnly: Boolean read FIsMakeMovementOnFromCardKeyOnly write SetIsMakeMovementOnFromCardKeyOnly default False; 

    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;

  published

  end;

  TgdcInvDocumentType = class(TgdcDocumentType)
  protected
    procedure CreateFields; override;

    function CreateDialogForm: TCreateableForm; override;

    procedure DoBeforePost; override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function InvDocumentTypeBranchKey: Integer;
    class function GetHeaderDocumentClass: CgdcBase; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  EgdcInvBaseDocument = class(Exception);
  EgdcInvDocument = class(Exception);
  EgdcInvDocumentLine = class(Exception);
  EgdcInvDocumentType = class(Exception);

procedure Register;

function RelationTypeByRelation(Relation: TatRelation): TgdcInvRelationType;

implementation

uses
  gd_security_OperationConst, gdc_dlgSetupInvDocument_unit, gdc_dlgG_unit,
  gdc_dlgInvDocument_unit, gdc_dlgInvDocumentLine_unit,
  at_sql_setup, gdc_frmInvDocument_unit, gdc_frmInvDocumentType_unit,
  gd_ClassList, gdc_dlgViewMovement_unit, gdcInvDocumentCache_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Register;
begin
  RegisterComponents('GDC', [TgdcInvDocumentType, TgdcInvDocument, TgdcInvDocumentLine]);
end;

function RelationTypeByRelation(Relation: TatRelation): TgdcInvRelationType;
begin
  if not Assigned(Relation) then
    Result := irtInvalid else

  with Relation.RelationFields do
  begin
    if
      (ByFieldName('MASTERKEY') <> nil) and
      (ByFieldName('DOCUMENTKEY') <> nil) and
      (ByFieldName('FROMCARDKEY') <> nil) and
      (ByFieldName('TOCARDKEY') <> nil) and
      (ByFieldName('QUANTITY') <> nil)
    then
      Result := irtFeatureChange else

    if
      (ByFieldName('MASTERKEY') <> nil) and
      (ByFieldName('DOCUMENTKEY') <> nil) and
      (ByFieldName('FROMCARDKEY') <> nil) and
      (ByFieldName('FROMQUANTITY') <> nil) and
      (ByFieldName('TOQUANTITY') <> nil)
    then
      Result := irtInventorization else

    if
      (ByFieldName('MASTERKEY') <> nil) and
      (ByFieldName('DOCUMENTKEY') <> nil) and
      (ByFieldName('FROMCARDKEY') <> nil) and
      (ByFieldName('INQUANTITY') <> nil) and
      (ByFieldName('OUTQUANTITY') <> nil)
    then
      Result := irtTransformation else

    if
      (ByFieldName('MASTERKEY') <> nil) and
      (ByFieldName('DOCUMENTKEY') <> nil) and
      (ByFieldName('FROMCARDKEY') <> nil) and
      (ByFieldName('QUANTITY') <> nil)
    then
      Result := irtSimple

    else
      Result := irtInvalid;
  end;
end;


{ TgdcInvBaseDocument }

constructor TgdcInvBaseDocument.Create(AnOwner: TComponent);
begin
  inherited;

  FMovementSource := TgdcInvMovementContactOption.Create;
  FMovementTarget := TgdcInvMovementContactOption.Create;

  FRelationName := '';
  FRelationLineName := '';
  FDocumentTypeKey := -1;
  FReportGroupKey := -1;
  FBranchKey := -1;

  FMovementSource.RelationName := '';
  FMovementSource.SourceFieldName := '';
  FMovementSource.SubRelationName := '';
  FMovementSource.SubSourceFieldName := '';

  SetLength(FMovementSource.Predefined, 0);
  SetLength(FMovementSource.SubPredefined, 0);

  FMovementTarget.RelationName := '';
  FMovementTarget.SourceFieldName := '';
  FMovementTarget.SubRelationName := '';
  FMovementTarget.SubSourceFieldName := '';

  FContact := nil;

  SetLength(FMovementTarget.Predefined, 0);
  SetLength(FMovementTarget.SubPredefined, 0);

  FSetupProceeded := False;
  FCurrentStreamVersion := gdcInv_Document_Undone;
end;

procedure TgdcInvBaseDocument.CreateContactSQL;
begin
  if not Assigned(FContact) then
  begin
    FContact := TIBSQL.Create(nil);
    FContact.SQL.Text := 'SELECT id, name FROM gd_contact WHERE id = :id';
  end;

  if FContact.Transaction = nil then
    FContact.Transaction := ReadTransaction;

  if FContact.Database = nil then
    FContact.Database := Database;
end;

procedure TgdcInvBaseDocument.CreateFields;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  I: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVBASEDOCUMENT', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEDOCUMENT', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEDOCUMENT',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if (csDesigning in ComponentState) or (DocumentTypeKey = -1) then
    Exit;

  FieldByName('documentkey').Required := False;

  for I := 0 to Joins.Count - 1 do
    FieldByName(Joins.Values[Joins.Names[I]]).Required := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEDOCUMENT', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEDOCUMENT', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

constructor TgdcInvBaseDocument.CreateSubType(AnOwner: TComponent;
  const ASubType: TgdcSubType; const ASubSet: TgdcSubSet = 'All');
begin
  inherited;

end;

destructor TgdcInvBaseDocument.Destroy;
begin
  if Assigned(FContact) then
    FContact.Free;

  FMovementSource.Free;
  FMovementTarget.Free;

  inherited;
end;

function TgdcInvBaseDocument.DocumentTypeKey: Integer;
begin
  // FDocumentTypeKey - Ключ документа, считывается при смене сабтайпа
  Result := FDocumentTypeKey;
end;

function TgdcInvBaseDocument.EnumModificationList(const ExcludeField: String = ''): String;
var
  I: Integer;
  R: TatRelation;
begin
  if Self is TgdcInvDocument then
    R := Relation
  else
    R := RelationLine;

  Assert(R <> nil, 'Relation not assigned!');

  Result := '';

  for I := 0 to R.RelationFields.Count - 1 do
  begin
    if AnsiPos(R.RelationFields[I].FieldName + ';', ExcludeField) <> 0 then Continue;
    Result := Result +
      R.RelationFields[I].FieldName +
      ' = :' +
      R.RelationFields[I].FieldName;

    if I < R.RelationFields.Count - 1 then
      Result := Result + ', ';
  end;
end;

function TgdcInvBaseDocument.EnumRelationFields(const Alias: String;
  SkipList: String; const UseDot: Boolean = True): String;
var
  I: Integer;
  R: TatRelation;
begin
  if Self is TgdcInvDocument then
    R := Relation
  else
    R := RelationLine;

  Assert(R <> nil, 'Relation not assigned!');

  Result := '';

  for I := 0 to R.RelationFields.Count - 1 do
  begin
    if AnsiPos(R.RelationFields[I].FieldName + ';', SkipList) <> 0 then Continue;

    Result := Result + Alias;

    if UseDot then
      Result := Result + '.';

    Result := Result +
      R.RelationFields[I].FieldName;

    if I < R.RelationFields.Count - 1 then
      Result := Result + ', ';
  end;
end;

function TgdcInvBaseDocument.EnumRelationJoins(Relations: TgdcInvRelationAliases): String;
var
  R: TatRelation;
  I, K: Integer;
  InnerJoins, LeftJoins: TStringList;
  Line: String;
begin
  Result := '';
  InnerJoins := TStringList.Create;
  LeftJoins := TStringList.Create;

  try
    for I := 1 to Length(Relations) do
    begin
      R := atDatabase.Relations.ByRelationName(Relations[I - 1].RelationName);

      Assert(R <> nil, 'Relation not found!');

      for K := 1 to R.RelationFields.Count do
      with R.RelationFields[K - 1] do
      begin
        if not IsUserDefined or not Visible or (References = nil) then
          Continue;

        // Если признак не используется и является ссылкой,
        // то пропускаем его

        Line := '';
        if (Self is TgdcInvDocumentLine) then
        with (Self as TgdcInvDocumentLine) do
          if (AnsiCompareText(R.RelationName, 'INV_CARD') = 0) then
          begin
            if (RelationType <> irtFeatureChange) and
              not IsFeatureUsed(FieldName, SourceFeatures) and
              not IsFeatureUsed(FieldName, DestFeatures)
            then
              Continue
            else
              if (RelationType = irtFeatureChange) and
                 (
                 ((Relations[I - 1].AliasName = 'CARD') and not IsFeatureUsed(FieldName, SourceFeatures)) or
                 ((Relations[I - 1].AliasName = 'TOCARD') and not IsFeatureUsed(FieldName, DestFeatures))
                 )
              then
                Continue;
          end;

        if Field.IsNullable then
          Line := 'LEFT JOIN '
        else
          Line := 'JOIN ';

        Line := Line +
          Format(
            '%0:s %1:s_%2:s ON (%1:s.%2:s = %1:s_%2:s.%3:s) ',
            [
              References.RelationName,
              Relations[I - 1].AliasName,
              FieldName,
              References.PrimaryKey.ConstraintFields.ByPos(0).FieldName
            ]
          );

        FSQLSetup.Ignores.AddAliasName(
          Relations[I - 1].AliasName + '_' + FieldName);

        if Field.IsNullable then
          LeftJoins.Add(Line)
        else
          InnerJoins.Add(Line);
      end;
    end;

    for I := 0 to InnerJoins.Count - 1 do
      Result := Result + InnerJoins[I];

    for I := 0 to LeftJoins.Count - 1 do
      Result := Result + LeftJoins[I];
  finally
    InnerJoins.Free;
    LeftJoins.Free;
  end;
end;

function TgdcInvBaseDocument.EnumJoinedListFields(Relations: TgdcInvRelationAliases): String;
var
  R: TatRelation;
  I, K: Integer;
  ListFieldName: String;
begin
  Joins.Clear;
  Result := '';

  for I := 1 to Length(Relations) do
  begin
    R := atDatabase.Relations.ByRelationName(Relations[I - 1].RelationName);

    Assert(R <> nil, 'Relation not found!');

    for K := 1 to R.RelationFields.Count do
    with R.RelationFields[K - 1] do
    begin
      if not IsUserDefined or not Visible or (References = nil) then
        Continue;

      // Если признак не используется и является ссылкой,
      // то пропускаем его

      if (Self is TgdcInvDocumentLine) then
        with (Self as TgdcInvDocumentLine) do
          if (AnsiCompareText(R.RelationName, 'INV_CARD') = 0) then
          begin
            if (RelationType <> irtFeatureChange) and
              not IsFeatureUsed(FieldName, SourceFeatures) and
              not IsFeatureUsed(FieldName, DestFeatures)
            then
              Continue
            else
              if (RelationType = irtFeatureChange) and
                 (
                 ((Relations[I - 1].AliasName = 'CARD') and not IsFeatureUsed(FieldName, SourceFeatures)) or
                 ((Relations[I - 1].AliasName = 'TOCARD') and not IsFeatureUsed(FieldName, DestFeatures))
                 )
              then
                Continue;
          end;

      if Assigned(Field.RefListField) then
        ListFieldName := Field.RefListField.FieldName
      else
        ListFieldName := References.ListField.FieldName;

      Result := Result + ', ' +
        Relations[I - 1].AliasName + '_' + FieldName + '.' +
          ListFieldName +
        ' as ' +
        Relations[I - 1].AliasName + '_' + FieldName + '_' + ListFieldName;
    end;
  end;
end;

function TgdcInvBaseDocument.GetGroupID: Integer;
begin
  Result := FReportGroupKey;
end;

function TgdcInvBaseDocument.GetRelation: TatRelation;
begin
  Assert(atDatabase <> nil, 'Attributes database not assigned!');
  Result := atDatabase.Relations.ByRelationName(FRelationName);
end;

function TgdcInvBaseDocument.GetRelationLine: TatRelation;
begin
  Assert(atDatabase <> nil, 'Attributes database not assigned!');
  Result := atDatabase.Relations.ByRelationName(FRelationLineName);
end;

function TgdcInvBaseDocument.GetRelationType: TgdcInvRelationType;
begin
  Result := RelationTypeByRelation(RelationLine);
end;

class function TgdcInvBaseDocument.GetSubTypeList(SubTypeList: TStrings): Boolean;
{var
  ibsql: TIBSQL;
  ibtr: TIBTransaction;}
begin
  Assert(Assigned(gdcInvDocumentCache));

  Result := gdcInvDocumentCache.GetSubTypeList(TgdcInvDocumentType.InvDocumentTypeBranchKey,
    SubTypeList);

end;

function TgdcInvBaseDocument.JoinListFieldByFieldName(
  const AFieldName, AAliasName, AJoinFieldName: String): String;
begin
  Result := AAliasName + '_' + AFieldName + '_' + AJoinFieldName;
end;

procedure TgdcInvBaseDocument.ReadOptions(Stream: TStream);
var
  Index: Integer;
begin
  Assert(not Active);

    { TODO -oJulia : Это зачем? }
    {Active := False;}

    Index := CacheDocumentTypeByRUID(SubType);
    if Index > - 1 then
    begin
      FReportGroupKey := DocTypeCache.CacheItemsByIndex[Index].ReportGroupKey;
      FBranchKey := DocTypeCache.CacheItemsByIndex[Index].BranchKey;
    end else
      raise EgdcInvDocumentType.Create('Складской документ не найден!');


    with TReader.Create(Stream, 1024) do
    try
      FCurrentStreamVersion := ReadString;

      if FCurrentStreamVersion = gdcInv_Document_Undone then
        raise EgdcInvBaseDocument.
          Create('Попытка загрузить незаконченный складской документ!');

      FRelationName := ReadString;
      FRelationLineName := ReadString;

      if (FCurrentStreamVersion <> gdcInvDocument_Version2_0) and
         (FCurrentStreamVersion <> gdcInvDocument_Version2_1) and
         (FCurrentStreamVersion <> gdcInvDocument_Version2_2) and
         (FCurrentStreamVersion <> gdcInvDocument_Version2_3) and
         (FCurrentStreamVersion <> gdcInvDocument_Version2_4) and
         (FCurrentStreamVersion <> gdcInvDocument_Version2_5) and
         (FCurrentStreamVersion <> gdcInvDocument_Version2_6)
      then
        //Раньше считывался тип документа
        ReadInteger;

      if (FCurrentStreamVersion = gdcInvDocument_Version1_9) or
        (FCurrentStreamVersion = gdcInvDocument_Version2_0) or
        (FCurrentStreamVersion = gdcInvDocument_Version2_1) or
        (FCurrentStreamVersion = gdcInvDocument_Version2_2) or
        (FCurrentStreamVersion = gdcInvDocument_Version2_3) or
        (FCurrentStreamVersion = gdcInvDocument_Version2_4) or
        (FCurrentStreamVersion = gdcInvDocument_Version2_5) or
        (FCurrentStreamVersion = gdcInvDocument_Version2_6)
      then
        //Раньше считывался кей группы отчетов
        ReadInteger;

      SetLength(FMovementTarget.Predefined, 0);
      SetLength(FMovementTarget.SubPredefined, 0);

      FMovementTarget.RelationName := ReadString;
      FMovementTarget.SourceFieldName := ReadString;
      FMovementTarget.SubRelationName := ReadString;
      FMovementTarget.SubSourceFieldName := ReadString;
      Read(FMovementTarget.ContactType, SizeOf(TgdcInvMovementContactType));

      ReadListBegin;
      while not EndOfList do
      begin
        SetLength(FMovementTarget.Predefined,
          Length(FMovementTarget.Predefined) + 1);
        FMovementTarget.Predefined[Length(FMovementTarget.Predefined) - 1] :=
          ReadInteger;
      end;
      ReadListEnd;

      ReadListBegin;
      while not EndOfList do
      begin
        SetLength(FMovementTarget.SubPredefined,
          Length(FMovementTarget.SubPredefined) + 1);
        FMovementTarget.SubPredefined[Length(FMovementTarget.SubPredefined) - 1] :=
          ReadInteger;
      end;
      ReadListEnd;


      SetLength(FMovementSource.Predefined, 0);
      SetLength(FMovementSource.SubPredefined, 0);

      FMovementSource.RelationName := ReadString;
      FMovementSource.SourceFieldName := ReadString;
      FMovementSource.SubRelationName := ReadString;
      FMovementSource.SubSourceFieldName := ReadString;

      Read(FMovementSource.ContactType, SizeOf(TgdcInvMovementContactType));

      ReadListBegin;
      while not EndOfList do
      begin
        SetLength(FMovementSource.Predefined,
          Length(FMovementSource.Predefined) + 1);
        FMovementSource.Predefined[Length(FMovementSource.Predefined) - 1] :=
          ReadInteger;
      end;
      ReadListEnd;

      ReadListBegin;
      while not EndOfList do
      begin
        SetLength(FMovementSource.SubPredefined,
          Length(FMovementSource.SubPredefined) + 1);
        FMovementSource.SubPredefined[Length(FMovementSource.SubPredefined) - 1] :=
          ReadInteger;
      end;
      ReadListEnd;

      if Self is TgdcInvDocument then
        FSetupProceeded := True;
    finally
      Free;
    end;
end;

procedure TgdcInvBaseDocument.UpdatePredefinedFields;
var
  RelName: String;

  procedure CheckMovement(M: TgdcInvMovementContactOption);
  begin
    if
      (AnsiCompareText(M.SubRelationName, RelName) = 0)
        and
      (Length(M.SubPredefined) > 0)
    then begin
      CreateContactSQL;
      FieldByName(M.SubSourceFieldName).AsInteger := M.SubPredefined[0];

      FContact.Close;
      FContact.ParamByName('id').AsInteger := M.SubPredefined[0];
      FContact.ExecQuery;

      if (FContact.RecordCount > 0) and
        (FindField(JoinListFieldByFieldName(M.SubSourceFieldName, 'INVDOC', 'NAME')) <> nil)
      then
        FieldByName(JoinListFieldByFieldName(M.SubSourceFieldName, 'INVDOC', 'NAME')).AsString :=
          FContact.FieldByName('name').AsString;

      FContact.Close;
    end;

    if
      (AnsiCompareText(M.RelationName, RelName) = 0)
        and
      (Length(M.Predefined) > 0)
        and
      (Length(M.SubPredefined) = 0)
    then begin
      CreateContactSQL;
      FieldByName(M.SourceFieldName).AsInteger := M.Predefined[0];

      FContact.Close;
      FContact.ParamByName('id').AsInteger := M.Predefined[0];
      FContact.ExecQuery;

      if FContact.RecordCount > 0 then
      begin
        if GetDocumentClassPart = dcpHeader then
          FieldByName(JoinListFieldByFieldName(M.SourceFieldName, 'INVDOC', 'NAME')).AsString :=
            FContact.FieldByName('name').AsString
        else
          FieldByName(JoinListFieldByFieldName(M.SourceFieldName, 'INVLINE', 'NAME')).AsString :=
            FContact.FieldByName('name').AsString;
      end;
      FContact.Close;
    end;
  end;

begin
  if State <> dsInsert then Exit;

  if Self is TgdcInvDocument then
    RelName := RelationName
  else
    RelName := RelationLineName;

  CheckMovement(MovementSource);
  CheckMovement(MovementTarget);
end;

procedure TgdcInvBaseDocument.WriteOptions(Stream: TStream);
var
  I: Integer;
begin
  with TWriter.Create(Stream, 1024) do
  try
    {
      TODO 3 -oденис -cсделать:
      Проверка на случай создания поля с переподключением к DB: gdcInv_Document_Undone.
    }

    WriteString(gdcInvDocument_Version2_6);
    WriteString(FRelationName);
    WriteString(FRelationLineName);
    //WriteInteger(FDocumentTypeKey);

    WriteInteger(FReportGroupKey);

    WriteString(FMovementTarget.RelationName);
    WriteString(FMovementTarget.SourceFieldName);
    WriteString(FMovementTarget.SubRelationName);
    WriteString(FMovementTarget.SubSourceFieldName);
    Write(FMovementTarget.ContactType, SizeOf(TgdcInvMovementContactType));

    WriteListBegin;
      for I := 0 to Length(FMovementTarget.Predefined) - 1 do
        WriteInteger(FMovementTarget.Predefined[I]);
    WriteListEnd;

    WriteListBegin;
      for I := 0 to Length(FMovementTarget.SubPredefined) - 1 do
        WriteInteger(FMovementTarget.SubPredefined[I]);
    WriteListEnd;

    WriteString(FMovementSource.RelationName);
    WriteString(FMovementSource.SourceFieldName);
    WriteString(FMovementSource.SubRelationName);
    WriteString(FMovementSource.SubSourceFieldName);
    Write(FMovementSource.ContactType, SizeOf(TgdcInvMovementContactType));

    WriteListBegin;
      for I := 0 to Length(FMovementSource.Predefined) - 1 do
        WriteInteger(FMovementSource.Predefined[I]);
    WriteListEnd;

    WriteListBegin;
      for I := 0 to Length(FMovementSource.SubPredefined) - 1 do
        WriteInteger(FMovementSource.SubPredefined[I]);
    WriteListEnd;
  finally
    Free;
  end;
end;

function TgdcInvBaseDocument.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCINVBASEDOCUMENT', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEDOCUMENT', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEDOCUMENT',
  {M}          'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETNOTCOPYFIELD' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEDOCUMENT' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetNotCopyField + ',DOCUMENTKEY';

  if GetDocumentClassPart <> dcpHeader then
    Result := Result + ',MASTERKEY';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEDOCUMENT', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEDOCUMENT', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvBaseDocument.SetSubType(const Value: String);
var
  Stream: TStream;
  Index: Integer;
begin
  if (SubType <> Value) then
  begin
    inherited;

    FDocumentTypeKey := -1;

    if SubType > '' then
    begin
      Index := CacheDocumentTypeByRUID(Value);
      if Index > -1 then
      begin
        FDocumentTypeKey := DocTypeCache.CacheItemsByIndex[Index].ID;

        Stream := TStringStream.Create(DocTypeCache.CacheItemsByIndex[Index].Options);
        try
          ReadOptions(Stream);
        finally
          Stream.Free;
        end;
      end else
        raise EgdcInvBaseDocument.Create(sInventoryDocumentDontFound);
    end;
  end;
end;

procedure TgdcInvBaseDocument.SetActive(Value: Boolean);
begin
  if (SubType > '') or not Value then
    inherited
  else
{    MessageBox(0,
      'Нельзя открывать складской документ не присвоив подтип!',
      'Внимание',
      MB_ICONHAND or MB_OK)};
end;

class function TgdcInvBaseDocument.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmInvDocument';
end;

function TgdcInvBaseDocument.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCINVBASEDOCUMENT', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEDOCUMENT', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEDOCUMENT',
  {M}          'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TGDCINVBASEDOCUMENT(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEDOCUMENT' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := '';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEDOCUMENT', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEDOCUMENT', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcInvBaseDocument.IsAbstractClass: Boolean;
begin
  Result := Self.ClassNameIs('TgdcInvBaseDocument');
end;

{ TgdcInvDocument }

constructor TgdcInvDocument.Create(AnOwner: TComponent);
begin
  inherited;

  FJoins := TStringList.Create;
//  FIsPrePosted := False;

end;

function TgdcInvDocument.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCINVDOCUMENT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENT', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENT',
  {M}          'CREATEDIALOGFORM', KEYCREATEDIALOGFORM, Params, LResult) then
  {M}          begin
  {M}            Result := nil;
  {M}            if VarType(LResult) <> varDispatch then
  {M}              raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен не объект.')
  {M}            else
  {M}              if IDispatch(LResult) = nil then
  {M}                raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                  'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен пустой (null) объект.');
  {M}            Result := GetInterfaceToObject(LResult) as TCreateableForm;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENT' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := TdlgInvDocument.CreateSubType(ParentForm, SubType);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvDocument.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVDOCUMENT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENT', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENT',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  CustomExecQuery(
    Format(
      'INSERT INTO %s ' +
      '  (%s) ' +
      'VALUES ' +
      '  (%s) ',
      [FRelationName, EnumRelationFields('', '', False), EnumRelationFields(':', '', False)]
    ),
    Buff
  );
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENT', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvDocument.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVDOCUMENT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENT', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENT',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery(
    Format(
      'UPDATE %s ' +
      'SET ' +
      '  %s ' +
      'WHERE ' +
      '  (DOCUMENTKEY = :NEW_DOCUMENTKEY) ',
      [FRelationName, EnumModificationList]
    ),
    Buff
  );
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

destructor TgdcInvDocument.Destroy;
begin
  FJoins.Free;
  inherited;
end;

procedure TgdcInvDocument.DoAfterCancel;
begin
  inherited;
//  FIsPrePosted := False;
end;

procedure TgdcInvDocument.DoAfterClose;
begin
  inherited;
//  FIsPrePosted := False;
end;

procedure TgdcInvDocument.DoAfterDelete;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVDOCUMENT', 'DOAFTERDELETE', KEYDOAFTERDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENT', KEYDOAFTERDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENT',
  {M}          'DOAFTERDELETE', KEYDOAFTERDELETE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
//  FIsPrePosted := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENT', 'DOAFTERDELETE', KEYDOAFTERDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENT', 'DOAFTERDELETE', KEYDOAFTERDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvDocument.DoAfterOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVDOCUMENT', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENT', KEYDOAFTEROPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTEROPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENT',
  {M}          'DOAFTEROPEN', KEYDOAFTEROPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
//  FIsPrePosted := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENT', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENT', 'DOAFTEROPEN', KEYDOAFTEROPEN);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvDocument.DoAfterPost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVDOCUMENT', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENT', KEYDOAFTERPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENT',
  {M}          'DOAFTERPOST', KEYDOAFTERPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
//  FIsPrePosted := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENT', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENT', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvDocument._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVDOCUMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENT', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENT',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  FieldByName('DOCUMENTKEY').AsInteger := FieldByName('ID').AsInteger;
  FieldByName('DELAYED').AsInteger := 0;

  UpdatePredefinedFields;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

class function TgdcInvDocument.GetDocumentClassPart: TgdcDocumentClassPart;
begin
  Result := dcpHeader;
end;

function TgdcInvDocument.GetFromClause(const ARefresh: Boolean = False): String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Relations: TgdcInvRelationAliases;
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCINVDOCUMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENT', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENT' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if (csDesigning in ComponentState) or (DocumentTypeKey = -1) then
  begin
    Result := inherited GetFromClause(ARefresh);
    Exit;
  end;

  SetLength(Relations, 1);
  Relations[0].RelationName := RelationName;
  Relations[0].AliasName := 'INVDOC';

  Result := Format(
    inherited GetFromClause(ARefresh) +
    '  JOIN %s INVDOC ON (Z.ID = INVDOC.DOCUMENTKEY) AND z.documenttypekey = %d ',
    [FRelationName, DocumentTypeKey]
  );
  if ARefresh then
    Result := Result + ' AND z.id = :NEW_id '#13#10
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvDocument.GetGroupClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETGROUPCLAUSE('TGDCINVDOCUMENT', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENT', KEYGETGROUPCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETGROUPCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENT',
  {M}          'GETGROUPCLAUSE', KEYGETGROUPCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETGROUPCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENT' then
  {M}        begin
  {M}          Result := Inherited GetGroupClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := '';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENT', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENT', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvDocument.GetJoins: TStringList;
begin
  Result := FJoins;
end;

function TgdcInvDocument.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCINVDOCUMENT', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENT', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENT' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := '';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENT', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENT', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvDocument.GetSelectClause: String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Relations: TgdcInvRelationAliases;
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCINVDOCUMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENT', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENT' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if (csDesigning in ComponentState) or (DocumentTypeKey = -1) then
  begin
    Result := inherited GetSelectClause;
    Exit;
  end;

  SetLength(Relations, 1);
  Relations[0].RelationName := RelationName;
  Relations[0].AliasName := 'INVDOC';

  Result := Format(
    inherited GetSelectClause +
    ', %s ',
    [EnumRelationFields('INVDOC', '')]
  );
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvDocument.SetJoins(const Value: TStringList);
begin
  if Value <> nil then
    FJoins.Assign(Value);
end;

class function TgdcInvDocument.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmInvDocument';
end;

procedure TgdcInvDocument.GetWhereClauseConditions(S: TStrings);
var
  Str: String;
  i: Integer;
begin
  inherited;
  if HasSubSet('OnlySelected') then
  begin
    Str := '';
    for I := 0 to SelectedID.Count - 1 do
    begin
      if Length(Str) >= 8192 then break;
      Str := Str + IntToStr(SelectedID[I]) + ',';
    end;
    if Str = '' then
      Str := '-1'
    else
      SetLength(Str, Length(Str) - 1);
    S.Add(Format('%s.%s IN (%s)', ['INVDOC', 'documentkey', Str]));
  end;

end;

procedure TgdcInvDocument.InternalSetFieldData(Field: TField;
  Buffer: Pointer);
var
  DocumentLine: TgdcInvDocumentLine;
  dsMain: TDataSource;
  i: Integer;
  DidActivate: Boolean;

  procedure MakeMovementOnLine;
  var
    FLSavePoint: String;
  begin
    if DocumentLine.FieldByName('masterkey').AsInteger = FieldByName('id').AsInteger then
    begin

      FLSavePoint := '';
      if not Transaction.Active then
      begin
        DidActivate := True;
        Transaction.StartTransaction;
      end
      else
      begin
        FLSavePoint := 'S' + System.Copy(StringReplace(
          StringReplace(
            StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
            '-', '', [rfReplaceAll]), 1, 30);
        try
          Transaction.SetSavePoint(FLSavePoint);
          //ExecSingleQuery('SAVEPOINT ' + FLSavePoint);
        except
          FLSavePoint := '';
        end;

      end;

      try

        try
          DocumentLine.Movement.gdcDocumentLine := DocumentLine;
          DocumentLine.Movement.Database := DocumentLine.Database;
          DocumentLine.Movement.ReadTransaction := DocumentLine.Transaction;
          DocumentLine.Movement.Transaction := DocumentLine.Transaction;
          DocumentLine.Movement.CreateAllMovement(ipsmPosition);
        except

          on E: Exception do
          begin
            if (DocumentLine.Movement.CountPositionChanged >= 0) and (not (sLoadFromStream in DocumentLine.BaseState) and not (sLoadFromStream in BaseState) ) then
            begin
              MessageBox(ParentHandle,
                PChar(E.Message),
                PChar(sAttention),
                MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
              if DidActivate then
                Transaction.Rollback
              else
              begin
                Transaction.RollBackToSavePoint(FLSavePoint);
                Transaction.ReleaseSavePoint(FLSavePoint);
                //ExecSingleQuery('ROLLBACK TO ' + FLSavePoint);
                //ExecSingleQuery('RELEASE SAVEPOINT ' + FLSavePoint);
                FLSavePoint := '';
                if sDialog in BaseState then
                  Field.FocusControl;
              end;
              if not DidActivate and not Transaction.InTransaction  then
                Transaction.StartTransaction;
              abort;
            end
            else begin
              raise;
            end;
          end;
        end;
      finally
        if FLSavePoint <> '' then
          Transaction.ReleaseSavePoint(FLSavePoint);
          //ExecSingleQuery('RELEASE SAVEPOINT ' + FLSavePoint);
        if Transaction.InTransaction and DidActivate then
          Transaction.Commit;
      end;
    end;
  end;

begin
  inherited;

  if FDataTransfer then
    exit;

  if (UpperCase(Field.FieldName) = 'DELAYED')
       or (UpperCase(Field.FieldName) = 'DOCUMENTDATE')
       or
     (
     (UpperCase(Field.FieldName) = MovementSource.SourceFieldName) AND
     (ANSICompareText(MovementSource.RelationName, RelationName) = 0)
     ) or
     (
     (UpperCase(Field.FieldName) = MovementTarget.SourceFieldName) AND
     (ANSICompareText(MovementTarget.RelationName, RelationName) = 0)
     )
  then
  begin
    if (Field.Dataset.State = dsInsert) or (Field.Dataset.State = dsEdit)
    then
    begin
      if UpperCase(Field.FieldName) = 'DOCUMENTDATE' then
      begin
        if FieldByName('documentdate').IsNull  and
           (not (sLoadFromStream in BaseState)) then
        begin
          MessageBox(ParentHandle,
            PChar(sSetDocumentDate),
            PChar(sAttention),
            mb_Ok or mb_IconInformation or MB_TASKMODAL);
          FieldByName('documentdate').FocusControl;
          abort;
        end
        else
        begin
          if FieldByName('documentdate').IsNull then
            exit;
        end;
      end;

      DidActivate := False;
      try
        if DetailLinksCount > 0 then
        begin
          for i:= 0 to DetailLinksCount - 1 do
            if DetailLinks[i] is TgdcInvDocumentLine then
            begin
              DocumentLine := DetailLinks[i] as TgdcInvDocumentLine;
              if DocumentLine.Active then
                MakeMovementOnLine;
            end;
        end
        else
        begin
          DidActivate := ActivateTransaction;
          dsMain := TDataSource.Create(Owner);
          DocumentLine := GetDetailObject as TgdcInvDocumentLine;
          try
            dsMain.DataSet := Self;
            DocumentLine.SubSet := 'ByParent';
            DocumentLine.MasterField := 'id';
            DocumentLine.DetailField := 'parent';
            DocumentLine.MasterSource := dsMain;
            DocumentLine.Open;
            MakeMovementOnLine;
          finally
            DocumentLine.Free;
            dsMain.Free;
          end;
        end;
      finally
        if DidActivate and Transaction.InTransaction then
          Transaction.Commit;
      end;
    end;
  end;
end;

function TgdcInvDocument.GetDetailObject: TgdcDocument;
begin
  Result := TgdcInvDocumentLine.CreateSubType(Owner, SubType);
end;

{ TgdcInvDocumentLine }

function TgdcInvDocumentLine.ChooseRemains: Boolean;
var
  FLocalSavePoint: String;
  F: TComponent;
begin
  F := Self.FindComponent('gdc_frmInvSelectRemains' + Self.SubType);
  if Assigned(F) then
  begin
    (F as TForm).BringToFront;
    Result := True;
    exit;
  end;
  SaveHeader;
  if Transaction.InTransaction then
  begin
    FLocalSavePoint := 'S' + System.Copy(StringReplace(
      StringReplace(
        StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
        '-', '', [rfReplaceAll]), 1, 30);
    try
      Transaction.SetSavePoint(FLocalSavePoint);
      //ExecSingleQuery('SAVEPOINT ' + FLocalSavePoint);
    except
      FLocalSavePoint := '';
    end;
  end else
    FLocalSavePoint := '';

  try
    FMovement.gdcDocumentLine := Self;
    FMovement.Database := Database;
    if Transaction.InTransaction then
      FMovement.ReadTransaction := Transaction
    else
      FMovement.ReadTransaction := ReadTransaction;
    FMovement.Transaction := Transaction;
    Result := FMovement.ChooseRemains;

    if not Result then
    begin
      if FLocalSavePoint > '' then
      begin
        try
          if Transaction.InTransaction then
          begin
            Transaction.RollBackToSavePoint(FLocalSavePoint);
            Transaction.ReleaseSavePoint(FLocalSavePoint);
            //ExecSingleQuery('ROLLBACK TO ' + FLocalSavePoint);
            //ExecSingleQuery('RELEASE SAVEPOINT ' + FLocalSavePoint);
            FLocalSavePoint := '';
          end;
          Close;
          Open;
        except
          FLocalSavePoint := '';
        end;
      end;
    end
  finally
    if FLocalSavePoint > '' then
    begin
      try
        if Transaction.InTransaction then
          Transaction.ReleaseSavePoint(FLocalSavePoint);
          //ExecSingleQuery('RELEASE SAVEPOINT ' + FLocalSavePoint);
        FLocalSavePoint := '';
      except
        FLocalSavePoint := '';
      end;
    end;
  end;
end;

constructor TgdcInvDocumentLine.Create(AnOwner: TComponent);
begin
  inherited;

  FisSetFeaturesFromRemains := False;
  FisChooseRemains := False;
  FisErrorUpdate := False;
  FisErrorInsert := False;

  FUseGoodKeyForMakeMovement := False;
  FIsMakeMovementOnFromCardKeyOnly := False;

  FisCheckDestFeatures := True;

  CustomProcess := [cpInsert, cpModify, cpDelete];

  FLineJoins := TStringList.Create;
  if not (csDesigning in ComponentState) then
    FMovement := TgdcInvMovement.CreateSubType(Self, SubType);

  SetLength(FSourceFeatures, 0);
  SetLength(FDestFeatures, 0);
  SetLength(FMinusFeatures, 0);  

  FSources := [];
  FDirection := imdFIFO;

  FGoodSQL := nil;
  FControlRemains := False;
  FIsMinusRemains := False;

  FViewMovementPart := impAll;

  FLiveTimeRemains := False;
  FEndMonthRemains := False;
  FUseCachedUpdates := False;
  FCanBeDelayed := False;
end;

function TgdcInvDocumentLine.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCINVDOCUMENTLINE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENTLINE', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENTLINE',
  {M}          'CREATEDIALOGFORM', KEYCREATEDIALOGFORM, Params, LResult) then
  {M}          begin
  {M}            Result := nil;
  {M}            if VarType(LResult) <> varDispatch then
  {M}              raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен не объект.')
  {M}            else
  {M}              if IDispatch(LResult) = nil then
  {M}                raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                  'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен пустой (null) объект.');
  {M}            Result := GetInterfaceToObject(LResult) as TCreateableForm;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENTLINE' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := TdlgInvDocumentLine.CreateSubType(ParentForm, SubType);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENTLINE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENTLINE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvDocumentLine.CreateFields;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  F: TField;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVDOCUMENTLINE', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENTLINE', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENTLINE',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if (csDesigning in ComponentState) or (DocumentTypeKey = -1) then
    Exit;

  FieldByName('GOODNAME').Required := False;
  FieldByName('GOODALIAS').Required := False;

  if FindField('REMAINS') <> nil then
    FieldByName('REMAINS').ReadOnly := True;

  if RelationType in [irtTransformation, irtInventorization] then
  begin
    F := TFloatField.Create(Self);
    F.Calculated := True;
    F.FieldName := 'QUANTITY';
    F.DataSet := Self;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENTLINE', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENTLINE', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvDocumentLine.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
       S: String;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVDOCUMENTLINE', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENTLINE', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENTLINE',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  try
    try
      FSavePoint := '';

      if Transaction.InTransaction then
      begin
        FSavepoint := 'S' + System.Copy(StringReplace(
          StringReplace(
            StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
            '-', '', [rfReplaceAll]), 1, 30);
        try
          Transaction.SetSavePoint(FSavepoint);
          //ExecSingleQuery('SAVEPOINT ' + FSavepoint);
        except
          FSavepoint := '';
        end;
      end;

      try
        CustomExecQuery(
          Format(
            'DELETE FROM %s WHERE documentkey = :old_documentkey',
            [FRelationLineName]),
          Buff
        );
      except
        on E: EIBError do
        begin
          if E.IBErrorCode = isc_except then
          begin
            S := String(PChar(StatusVectorArray[7]));
            if (S = 'GD_E_BLOCK') then
            begin
              MessageBox(ParentHandle,
                'Период заблокирован для изменений.'#13#10 +
                'Вы можете только просматривать данные и не можете их изменять.'#13#10 +
                'Отменить блокировку можно в окне Опции, меню Сервис.',
                'Период заблокирован',
                MB_OK or MB_ICONEXCLAMATION);
              abort;
            end
            else if (Pos('USR', S) > 0) then
              //пользовательское исключение
              raise
            else
            begin
              with Tgdc_dlgViewMovement.Create(ParentForm) do
                try
                  DocumentKey := FieldByName('documentkey').AsInteger;
                  if CompareText(FMovementTarget.RelationName, RelationLineName) = 0 then
                    ContactKey := FieldByName(FMovementTarget.SourceFieldName).AsInteger
                  else
                    ContactKey := MasterSource.DataSet.FieldByName(FMovementTarget.SourceFieldName).AsInteger;
                  GoodName := FieldByName('goodname').AsString;
                  Transaction := Self.ReadTransaction;
                  ShowModal;
                finally
                  Free;
                end;
              abort;
            end
          end else
            raise;
        end;

      end;

      inherited;
    except
      if FSavePoint > '' then
      begin
        try
          if Transaction.InTransaction then
          begin
            Transaction.RollBackToSavePoint(FSavepoint);
            Transaction.ReleaseSavePoint(FSavepoint);
            //ExecSingleQuery('ROLLBACK TO ' + FSavepoint);
            //ExecSingleQuery('RELEASE SAVEPOINT ' + FSavepoint);
          end;
          FSavepoint := '';
        except
          FSavepoint := '';
        end;
      end;
      raise;
    end;
  finally
    if FSavePoint > '' then
      Transaction.ReleaseSavePoint(FSavepoint);
      //ExecSingleQuery('RELEASE SAVEPOINT ' + FSavepoint);
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENTLINE', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENTLINE', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvDocumentLine.CustomInsert(Buff: Pointer);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  DataSet: TgdcBase;
  ADataSource: TDataSource;
  isCreate: Boolean;
{$IFDEF DEBUGMOVE}
  TimeTmp: LongWord;
{$ENDIF}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVDOCUMENTLINE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENTLINE', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENTLINE',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  {$IFDEF DEBUGMOVE}
  TimeTmp := GetTickCount;
  TimePostInPosition := GetTickCount;
  TimeMakeMovement := 0;
  {$ENDIF}
  FSavePoint := '';
  DataSet := nil;
  aDataSource := nil;
  isCreate := False;  

  if Transaction.InTransaction then
  begin
(*    FSavepoint := 'S' + System.Copy(StringReplace(
      StringReplace(
        StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
        '-', '', [rfReplaceAll]), 1, 30);
    try
      ExecSingleQuery('SAVEPOINT ' + FSavepoint);
    except
      FSavepoint := '';
    end;*)
    FSavepoint := '';
  end;

  try

    inherited;
    {$IFDEF DEBUGMOVE}
    TimeCustomInsertDoc := GetTickCount - TimeTmp;
    {$ENDIF}

    try

      FMovement.gdcDocumentLine := Self;
      FMovement.Database := Database;
      FMovement.Transaction := Transaction;
      FMovement.ReadTransaction := Transaction;
      if Assigned(MasterSource) and Assigned(MasterSource.DataSet) then
        DataSet := MasterSource.DataSet as TgdcBase
      else
        DataSet := nil;

      //Для загружаемого из потока объекта обязательно должен быть мастер!!!
      if (sLoadFromStream in BaseState) and (not Assigned(DataSet)) then
      begin
        ADataSource := TDataSource.Create(Self);
        DataSet := TgdcInvDocument.CreateWithID(Self, Database, Transaction,
          FieldByName('parent').AsInteger, SubType);
        DataSet.ReadTransaction := ReadTransaction;
        DataSet.Open;
        ADataSource.DataSet := DataSet;
        Self.MasterSource := ADataSource;
        isCreate := True;
      end;

      if Assigned(DataSet) and (sDialog in DataSet.BaseState) and not CachedUpdates
      then
        FMovement.CreateMovement(ipsmPosition)
      else
        FMovement.CreateMovement(ipsmDocument);

      {$IFDEF DEBUGMOVE}
      TimeTmp := GetTickCount;
      {$ENDIF}
      CustomExecQuery(
        Format(
          'INSERT INTO %s ' +
          '  (%s, disabled) ' +
          'VALUES ' +
          '  (%s, %d) ',
          [FRelationLineName,
            EnumRelationFields('', 'DISABLED;', False), EnumRelationFields(':', 'DISABLED;', False),
            FieldByName('linedisabled').AsInteger]
        ),
        Buff
      );
      {$IFDEF DEBUGMOVE}
      TimeCustomInsertUSR := GetTickCount - TimeTmp;
      {$ENDIF}
    except
{      if FSavePoint > '' then
      begin
        try
          if Transaction.InTransaction then
          begin
            ExecSingleQuery('ROLLBACK TO ' + FSavepoint);
            ExecSingleQuery('RELEASE SAVEPOINT ' + FSavepoint);
          end;
          FSavepoint := '';
        except
          FSavepoint := '';
        end;
      end
      else
      begin
        FisErrorInsert := True;
        try
          inherited CustomDelete(Buff);
        finally
          FisErrorInsert := False;
        end;
      end;}
      raise;
    end;
  finally
    if isCreate then
    begin
      Self.MasterSource := nil;
      aDataSource.Free;
      DataSet.Free;
    end;
    if FSavePoint > '' then
    begin
      try
        if Transaction.InTransaction then
          Transaction.ReleaseSavePoint(FSavepoint);
          //ExecSingleQuery('RELEASE SAVEPOINT ' + FSavepoint);
        FSavepoint := '';
      except
        FSavepoint := '';
      end;
    end;
  end;

{$IFDEF DEBUGMOVE}
  if not IsChooseRemains then
  begin
    TimePostInPosition := GetTickCount - TimePostInPosition;
    ShowMessage('Итого сохранение ' + IntToStr(TimePostInPosition) +
    ' Поиск остатков ' + IntToStr(TimeGetRemains) +
    ' Формирование движения ' + IntToStr(TimeMakeMovement));
  end;
{$ENDIF}

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENTLINE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENTLINE', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvDocumentLine.CustomModify(Buff: Pointer);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  DataSet: TgdcBase;
  ADataSource: TDataSource;
  isCreate: Boolean;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVDOCUMENTLINE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENTLINE', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENTLINE',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FSavePoint := '';

  if Transaction.InTransaction then
  begin
    FSavepoint := 'S' + System.Copy(StringReplace(
      StringReplace(
        StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
        '-', '', [rfReplaceAll]), 1, 30);
    try
      Transaction.SetSavePoint(FSavepoint);
      //ExecSingleQuery('SAVEPOINT ' + FSavepoint);
    except
      FSavepoint := '';
    end;
  end;

  ADataSource := nil;

  if Assigned(MasterSource) and Assigned(MasterSource.DataSet) then
    DataSet := MasterSource.DataSet as TgdcBase
  else
    DataSet := nil;
  isCreate := False;

  try
    try

      FMovement.gdcDocumentLine := Self;
      FMovement.Database := Database;
      FMovement.ReadTransaction := Transaction;
      FMovement.Transaction := Transaction;

      //Для загружаемого из потока объекта обязательно должен быть мастер!!!
      if {(sLoadFromStream in BaseState) and }(not Assigned(DataSet)) then
      begin
        ADataSource := TDataSource.Create(Self);
        DataSet := TgdcInvDocument.CreateWithID(Self, Database, Transaction,
          FieldByName('parent').AsInteger, SubType);
        DataSet.ReadTransaction := ReadTransaction;
        DataSet.Open;
        ADataSource.DataSet := DataSet;
        Self.MasterSource := ADataSource;
        isCreate := True;
      end;

      if Assigned(DataSet) and (sDialog in DataSet.BaseState) and not CachedUpdates
      then
        FMovement.CreateMovement(ipsmPosition)
      else
        FMovement.CreateMovement(ipsmDocument);

       CustomExecQuery(
        Format(
          'UPDATE %s ' +
          'SET ' +
          '  %s, disabled = %d ' +
          'WHERE ' +
          '  (documentkey = :new_documentkey) ',
          [FRelationLineName, EnumModificationList('DISABLED;'), FieldByName('linedisabled').AsInteger]
        ),
        Buff
      );

    except
      FisErrorUpdate := True;

      if FSavePoint > '' then
      begin
        try
          if Transaction.InTransaction then
          begin
            Transaction.RollBackToSavePoint(FSavepoint);
            Transaction.ReleaseSavePoint(FSavepoint);
            //ExecSingleQuery('ROLLBACK TO ' + FSavepoint);
            //ExecSingleQuery('RELEASE SAVEPOINT ' + FSavepoint);
          end;
          FSavepoint := '';
          FisErrorUpdate := False;
        except
          FSavepoint := '';
        end;
      end;

      raise;
    end;
  finally
    if isCreate then
    begin
      Self.MasterSource := nil;
      aDataSource.Free;
      DataSet.Free;
    end;

    if FSavePoint > '' then
    begin
      try
        if Transaction.InTransaction then
          Transaction.ReleaseSavePoint(FSavepoint);
          //ExecSingleQuery('RELEASE SAVEPOINT ' + FSavepoint);
        FSavepoint := '';
      except
        FSavepoint := '';
      end;
    end;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENTLINE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENTLINE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

destructor TgdcInvDocumentLine.Destroy;
begin
  FreeAndNil(FLineJoins);
//  FreeAndNil(FMovement);

  if Assigned(FGoodSQL) then
    FreeAndNil(FGoodSQL);

  inherited;
end;

procedure TgdcInvDocumentLine.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  //Times: LongWord;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVDOCUMENTLINE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENTLINE', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENTLINE',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

{$IFDEF DEBUGMOVE}
  TimePostInPosition := GetTickCount;
{$ENDIF}

  if sLoadFromStream in BaseState then
    isCheckDestFeatures := False;

  if FieldByName('GOODKEY').IsNull or (FieldByName('GOODKEY').AsInteger = 0) then
  begin
    if not (sLoadFromStream in BaseState) then
      MessageBox(ParentHandle, PChar(s_InvChooseGood), PChar(sAttention),
        mb_Ok or mb_IconInformation or mb_SystemModal);
    abort;
  end;


  inherited;

  if not (sMultiple in BaseState) then
  begin


//    UpdateGoodNames;

    if
      ((irsRemainsRef in FSources) and
      (not (irsGoodRef in FSources) or (sLoadFromStream in BaseState))  and
      (RelationType <> irtTransformation))
        or
      ((RelationType = irtTransformation) and (FindField('OUTQUANTITY') <> nil) AND
      (FieldByName('OUTQUANTITY').AsCurrency > 0))
    then begin
      FMovement.gdcDocumentLine := Self;
      FMovement.Database := Database;
      if Transaction.InTransaction then
      begin
        FMovement.ReadTransaction := Transaction;
        FMovement.Transaction := Transaction;
      end
      else
        FMovement.ReadTransaction := ReadTransaction;
      FMovement.GetRemains;
    end;
  end;
{$IFDEF DEBUGMOVE}
  TimePostInPosition := GetTickCount - TimePostInPosition;
{$ENDIF}

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENTLINE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENTLINE', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvDocumentLine.DoOnCalcFields;
begin
  inherited;

  if (csDesigning in ComponentState) or (DocumentTypeKey = -1) then
    Exit;

  case RelationType of
    irtTransformation:
    begin
      if ViewMovementPart = impIncome then
        FieldByName('QUANTITY').AsCurrency := FieldByName('INQUANTITY').AsCurrency
      else
        if ViewMovementPart = impExpense then
           FieldByName('QUANTITY').AsCurrency := - FieldByName('OUTQUANTITY').AsCurrency
         else
           FieldByName('QUANTITY').AsCurrency := FieldByName('INQUANTITY').AsCurrency
             - FieldByName('OUTQUANTITY').AsCurrency;
    end;
    irtInventorization:
    begin
      FieldByName('QUANTITY').AsCurrency :=
        FieldByName('TOQUANTITY').AsCurrency - FieldByName('FROMQUANTITY').AsCurrency;
    end;
  end;
end;

procedure TgdcInvDocumentLine._DoOnNewRecord;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
{$IFDEF DEBUGMOVE}
  TempTime: LongWord;
{$ENDIF}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVDOCUMENTLINE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENTLINE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENTLINE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  {$IFDEF DEBUGMOVE}
  TempTime := GetTickCount;
  {$ENDIF}


  inherited;

  FieldByName('MASTERKEY').AsInteger := FieldByName('Parent').AsInteger;
  FieldByName('DOCUMENTKEY').AsInteger := FieldByName('ID').AsInteger;

  case RelationType of
    irtFeatureChange:
    begin
      FieldByName('FROMCARDKEY').Required := False;
      FieldByName('TOCARDKEY').Required := False;
    end;
    irtSimple, irtInventorization:
    begin
      FieldByName('FROMCARDKEY').Required := False;
    end;
    irtTransformation:
    begin
      FieldByName('FROMCARDKEY').Required := False;

      if (ViewMovementPart = impIncome) then
        FieldByName('INQUANTITY').AsCurrency := 0
      else
        FieldByName('OUTQUANTITY').AsCurrency := 0;
    end;
  end;

  UpdatePredefinedFields;

  {$IFDEF DEBUGMOVE}
  TimeDoOnNewRecord := TimeDoOnNewRecord + GetTickCount - TempTime;
  {$ENDIF}


  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENTLINE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENTLINE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcInvDocumentLine.EnumCardFields(const Alias: String; Kind: TgdcInvFeatureKind;
  const AsName: String = ''): String;
var
  I: Integer;
  Relation: TatRelation;
  Features: TgdcInvFeatures;
begin
  Assert(atDatabase <> nil, 'Attributes database not assigned!');

  Relation := atDatabase.Relations.ByRelationName('INV_CARD');
  Assert(Relation <> nil, 'Relation not assigned!');

  Result := '';

  SetLength(Features, 0);

  if RelationType <> irtTransformation then
  begin
    if (Kind = ifkDest) and (Length(FDestFeatures) > 0) then
      Features := FDestFeatures
    else
      if (Kind = ifkSource) and (Length(FSourceFeatures) > 0) then
        Features := FSourceFeatures;
  end else begin
    if Kind = ifkDest then
       Features := FDestFeatures
    else
       Features := FSourceFeatures;
  end;

  if (Kind = ifkSource) or (RelationType = irtTransformation) then
    Result := Result + ', ' + Alias + '.GOODKEY';

  for I := 0 to Relation.RelationFields.Count - 1 do
  begin
    if not IsFeatureUsed(Relation.RelationFields[I].FieldName, Features) then Continue;

    Result := Result + ', ' + Alias + '.' +
      Relation.RelationFields[I].FieldName;

    if AsName > '' then
      Result := Result + ' AS ' + AsName + Relation.RelationFields[I].FieldName;
  end;
end;


class function TgdcInvDocumentLine.GetDocumentClassPart: TgdcDocumentClassPart;
begin
  Result := dcpLine;
end;

function TgdcInvDocumentLine.GetFromClause(const ARefresh: Boolean = False): String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Ignore: TatIgnore;
  Relations: TgdcInvRelationAliases;
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCINVDOCUMENTLINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENTLINE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENTLINE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENTLINE' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if (csDesigning in ComponentState) or (DocumentTypeKey = -1) then
  begin
    Result := inherited GetFromClause(ARefresh);
    Exit;
  end;

  Result := Format(
    inherited GetFromClause(ARefresh) +
    '  LEFT JOIN %s INVLINE ON (Z.ID = INVLINE.DOCUMENTKEY) ' +

    '  LEFT JOIN INV_CARD CARD ON (CARD.ID = INVLINE.FROMCARDKEY) ' +

    '  LEFT JOIN GD_GOOD G ON (G.ID = CARD.GOODKEY) ' +
    '  LEFT JOIN GD_VALUE V ON (G.VALUEKEY = V.ID) ',
    [FRelationLineName]
  );

  FSQLSetup.Ignores.AddAliasName('CARD');

  SetLength(Relations, 1);
  Relations[0].RelationName := 'INV_CARD';
  Relations[0].AliasName := 'CARD';

  if RelationType = irtFeatureChange then
  begin
    Result := Result +
      '  LEFT JOIN INV_CARD TOCARD ON (TOCARD.ID = INVLINE.TOCARDKEY) ';

    Ignore := FSQLSetup.Ignores.Add;
    Ignore.AliasName := 'TOCARD';

    SetLength(Relations, 2);
    Relations[1].RelationName := 'INV_CARD';
    Relations[1].AliasName := 'TOCARD';
  end;

  Result := Result + ' ' + EnumRelationJoins(Relations);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENTLINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENTLINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvDocumentLine.GetGroupClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETGROUPCLAUSE('TGDCINVDOCUMENTLINE', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENTLINE', KEYGETGROUPCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETGROUPCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENTLINE',
  {M}          'GETGROUPCLAUSE', KEYGETGROUPCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETGROUPCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENTLINE' then
  {M}        begin
  {M}          Result := Inherited GetGroupClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := '';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENTLINE', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENTLINE', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvDocumentLine.GetJoins: TStringList;
begin
  Result := FLineJoins;
end;

function TgdcInvDocumentLine.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCINVDOCUMENTLINE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENTLINE', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENTLINE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENTLINE' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := '';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENTLINE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENTLINE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvDocumentLine.GetSelectClause: String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  SkipList, Prefix: String;
  Relations: TgdcInvRelationAliases;
  FeaturesText: String;
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCINVDOCUMENTLINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENTLINE', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENTLINE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENTLINE' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if (csDesigning in ComponentState) or (DocumentTypeKey = -1) then
  begin
    Result := inherited GetSelectClause;
    Exit;
  end;

  if (RelationType = irtTransformation) then
  begin
    if (ViewMovementPart = impIncome) then
      SkipList := 'OUTQUANTITY;'
    else
      if ViewMovementPart = impExpense then
        SkipList := 'INQUANTITY;';
  end else begin
    SkipList := '';
  end;

  if RelationType = irtTransformation then
  begin
    if ViewMovementPart in [impIncome, impAll] then
      Prefix := INV_DESTFEATURE_PREFIX
    else
      Prefix := INV_SOURCEFEATURE_PREFIX;
  end else

  if (Length(SourceFeatures) > 0) or (RelationType = irtFeatureChange) then
    Prefix := INV_SOURCEFEATURE_PREFIX else

  if (Length(DestFeatures) > 0) then
    Prefix := INV_DESTFEATURE_PREFIX;

  SetLength(Relations, 1);
  Relations[0].RelationName := 'INV_CARD';
  Relations[0].AliasName := 'CARD';

  if RelationType = irtFeatureChange then
  begin
    SetLength(Relations, 2);
    Relations[1].RelationName := 'INV_CARD';
    Relations[1].AliasName := 'TOCARD';
  end;

  if RelationType = irtTransformation then
  begin
    if FViewMovementPart = impIncome then
      FeaturesText := EnumCardFields('CARD', ifkDest, Prefix) else
    if FViewMovementPart = impExpense then
      FeaturesText := EnumCardFields('CARD', ifkSource, Prefix)
    else
      FeaturesText := EnumCardFields('CARD', ifkDest, INV_DESTFEATURE_PREFIX) +
        EnumCardFields('CARD', ifkSource, INV_SOURCEFEATURE_PREFIX);
  end else
    FeaturesText := EnumCardFields('CARD', ifkSource, Prefix);

  Result := Format(
    inherited GetSelectClause +
    ', G.NAME AS GOODNAME, G.ALIAS AS GOODALIAS, G.VALUEKEY, G.GROUPKEY, V.NAME, INVLINE.disabled AS LINEDISABLED ' +
    '%s%s%s',
    [
      EnumRelationFields('INVLINE', SkipList),
      EnumJoinedListFields(Relations),
      FeaturesText
    ]
  );

  if (RelationType = irtFeatureChange) or (Length(FDestFeatures) > 0) then
  begin
    if (RelationType = irtFeatureChange) then
      Result := Result + EnumCardFields('TOCARD', ifkDest, INV_DESTFEATURE_PREFIX)
    else
      Result := Result + EnumCardFields('CARD', ifkDest, INV_DESTFEATURE_PREFIX);
  end;

  Result := Result + ' ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENTLINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENTLINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvDocumentLine.GetWhereClauseConditions(S: TStrings);
begin
  inherited;

  if (csDesigning in ComponentState) or (DocumentTypeKey = -1) then
    Exit;

  if RelationType = irtTransformation then
  begin
    if ViewMovementPart = impIncome then
      S.Add(' INVLINE.INQUANTITY <> 0 AND INVLINE.INQUANTITY IS NOT NULL')

    else if ViewMovementPart = impExpense then
      S.Add(' INVLINE.OUTQUANTITY <> 0 AND INVLINE.OUTQUANTITY IS NOT NULL');
  end;

  S.Add('INVLINE.documentkey IS NOT NULL');

end;

function TgdcInvDocumentLine.IsFeatureUsed(const FieldName: String;
  Features: TgdcInvFeatures): Boolean;
var
  I: Integer;
begin
  for I := 0 to Length(Features) - 1 do
    if AnsiCompareText(Features[I], FieldName) = 0 then
    begin
      Result := True;
      Exit;
    end;

  Result := False;
end;

procedure TgdcInvDocumentLine.ReadOptions(Stream: TStream);
var
  F: TatRelationField;
begin
  inherited;
  with TReader.Create(Stream, 1024) do
  try
    SetLength(FSourceFeatures, 0);
    SetLength(FDestFeatures, 0);
    SetLength(FMinusFeatures, 0);    

    ReadListBegin;
    SetLength(FSourceFeatures, 0);
    while not EndOfList do
    begin
      // Проверяем наличие поля в INV_CARD
      F := atDatabase.FindRelationField('INV_CARD', ReadString);
      if Assigned(F) then
      begin
        SetLength(FSourceFeatures, Length(FSourceFeatures) + 1);
        FSourceFeatures[Length(FSourceFeatures) - 1] := F.FieldName;
      end;
    end;
    ReadListEnd;

    ReadListBegin;
    SetLength(FDestFeatures, 0);
    while not EndOfList do
    begin
      // Проверяем наличие поля в INV_CARD
      F := atDatabase.FindRelationField('INV_CARD', ReadString);
      if Assigned(F) then
      begin
        SetLength(FDestFeatures, Length(FDestFeatures) + 1);
        FDestFeatures[Length(FDestFeatures) - 1] := F.FieldName;
      end;
    end;
    ReadListEnd;

    Read(FSources, SizeOf(TgdcInvReferenceSources));
    Read(FDirection, SizeOf(TgdcInvMovementDirection));

    FControlRemains := ReadBoolean;

    if (FCurrentStreamVersion = gdcInvDocument_Version1_9) or
      (FCurrentStreamVersion = gdcInvDocument_Version2_0) or
      (FCurrentStreamVersion = gdcInvDocument_Version2_1) or
      (FCurrentStreamVersion = gdcInvDocument_Version2_2) or
      (FCurrentStreamVersion = gdcInvDocument_Version2_3) or
      (FCurrentStreamVersion = gdcInvDocument_Version2_4) or
      (FCurrentStreamVersion = gdcInvDocument_Version2_5) or
      (FCurrentStreamVersion = gdcInvDocument_Version2_6) then
      FLiveTimeRemains := ReadBoolean
    else
      FLiveTimeRemains := False;

    if not (irsRemainsRef in FSources) then
    begin
      FControlRemains := False;
      FLiveTimeRemains := False;
    end;

    FCanBeDelayed := ReadBoolean;
    FUseCachedUpdates := ReadBoolean;
    if (FCurrentStreamVersion = gdcInvDocument_Version2_1) or
       (FCurrentStreamVersion = gdcInvDocument_Version2_2) or
       (FCurrentStreamVersion = gdcInvDocument_Version2_3) or
       (FCurrentStreamVersion = gdcInvDocument_Version2_4) or
       (FCurrentStreamVersion = gdcInvDocument_Version2_5) or
       (FCurrentStreamVersion = gdcInvDocument_Version2_6)
    then
      FisMinusRemains := ReadBoolean
    else
      FisMinusRemains := False;

    if (FCurrentStreamVersion = gdcInvDocument_Version2_2) or
       (FCurrentStreamVersion = gdcInvDocument_Version2_3) or
       (FCurrentStreamVersion = gdcInvDocument_Version2_4) or
       (FCurrentStreamVersion = gdcInvDocument_Version2_5) or
       (FCurrentStreamVersion = gdcInvDocument_Version2_6)
    then
    begin
      ReadListBegin;
      SetLength(FMinusFeatures, 0);
      while not EndOfList do
      begin
        // Проверяем наличие поля в INV_CARD
        F := atDatabase.FindRelationField('INV_CARD', ReadString);
        if Assigned(F) then
        begin
          SetLength(FMinusFeatures, Length(FMinusFeatures) + 1);
          FMinusFeatures[Length(FMinusFeatures) - 1] := F.FieldName;
        end;
      end;
      ReadListEnd;

    end;

    if (FCurrentStreamVersion = gdcInvDocument_Version2_3) or
       (FCurrentStreamVersion = gdcInvDocument_Version2_4) or
       (FCurrentStreamVersion = gdcInvDocument_Version2_5) or
       (FCurrentStreamVersion = gdcInvDocument_Version2_6) then
    begin
      FIsChangeCardValue := ReadBoolean;
      FIsAppendCardValue := ReadBoolean;
    end
    else
    begin
      FIsChangeCardValue := False;
      FIsAppendCardValue := False;
    end;

    if (FCurrentStreamVersion = gdcInvDocument_Version2_4) or
       (FCurrentStreamVersion = gdcInvDocument_Version2_5) or
       (FCurrentStreamVersion = gdcInvDocument_Version2_6)
    then
      FIsUseCompanyKey := ReadBoolean
    else
      FIsUseCompanyKey := True;

    if (FCurrentStreamVersion = gdcInvDocument_Version2_5) or
       (FCurrentStreamVersion = gdcInvDocument_Version2_6) then
      FSaveRestWindowOption := ReadBoolean
    else
      FSaveRestWindowOption := False;

    if (FCurrentStreamVersion = gdcInvDocument_Version2_6) then
      FEndMonthRemains :=  ReadBoolean
    else
      FEndMonthRemains := False;  


    FSetupProceeded := True;
  finally
    Free;
  end;
end;

function TgdcInvDocumentLine.SelectGoodFeatures: Boolean;
begin
  SaveHeader;
  FSavepoint := '';
  if Transaction.InTransaction then
  begin
    FSavepoint := 'S' + System.Copy(StringReplace(
      StringReplace(
        StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
        '-', '', [rfReplaceAll]), 1, 30);
    try
      Transaction.SetSavePoint(FSavepoint);
      //ExecSingleQuery('SAVEPOINT ' + FSavepoint);
    except
      FSavepoint := '';
    end;
  end;

  try
    FMovement.gdcDocumentLine := Self;
    FMovement.Database := Database;
    if Transaction.InTransaction then
      FMovement.ReadTransaction := Transaction
    else
      FMovement.ReadTransaction := ReadTransaction;
    FMovement.Transaction := Transaction;
    Result := FMovement.SelectGoodFeatures;

    if not Result then
    begin
      if FSavePoint > '' then
      begin
        try
          if Transaction.InTransaction then
          begin
            Transaction.RollBackToSavePoint(FSavepoint);
            Transaction.ReleaseSavePoint(FSavepoint);
            //ExecSingleQuery('ROLLBACK TO ' + FSavepoint);
            //ExecSingleQuery('RELEASE SAVEPOINT ' + FSavepoint);
          end;
          FSavepoint := '';
          Close;
          Open;
        except
          FSavepoint := '';
        end;
      end;
    end
  finally
    if FSavePoint > '' then
    begin
      try
        if Transaction.InTransaction then
          Transaction.ReleaseSavePoint(FSavepoint);
          //ExecSingleQuery('RELEASE SAVEPOINT ' + FSavepoint);
        FSavepoint := '';
      except
        FSavepoint := '';
      end;
    end;
  end;
end;

procedure TgdcInvDocumentLine.SetJoins(const Value: TStringList);
begin
  if Value <> nil then
    FLineJoins.Assign(Value);
end;

procedure TgdcInvDocumentLine.SetViewMovementPart(
  const Value: TgdcInvMovementPart);
begin
  if FViewMovementPart <> Value then
  begin
    Close;
    FViewMovementPart := Value;
    FSQLInitialized := False;

    {if FgdcDataLink.Active then
      FgdcDataLink.RefreshParams(True);}
  end;
end;

procedure TgdcInvDocumentLine.UpdateGoodNames;
begin
  if not (State in dsEditModes) then
    Edit;

  if not Assigned(FGoodSQL) then
  begin
    FGoodSQL := TIBSQL.Create(nil);
    FGoodSQL.Database := Database;
    FGoodSQL.Transaction := ReadTransaction;
    FGoodSQL.SQL.Text := 'SELECT name, alias FROM gd_good WHERE id = :id';
  end;

  FGoodSQL.Transaction := ReadTransaction;
//  Transaction.Active := True;

  FGoodSQL.ParamByName('ID').AsInteger := FieldByName('GoodKey').AsInteger;
  FGoodSQL.ExecQuery;

  if FGoodSQL.RecordCount > 0 then
  begin
    FieldByName('GOODNAME').AsString := FGoodSQL.FieldByName('NAME').AsString;
    FieldByName('GOODALIAS').AsString := FGoodSQL.FieldByName('ALIAS').AsString;
  end;

  FGoodSQL.Close;

end;

procedure TgdcInvDocumentLine.WriteOptions(Stream: TStream);
var
  I: Integer;
begin
  inherited;

  with TWriter.Create(Stream, 1024) do
  try
    WriteListBegin;
    for I := 0 to Length(FSourceFeatures) - 1 do
      WriteString(FSourceFeatures[I]);
    WriteListEnd;

    WriteListBegin;
    for I := 0 to Length(FDestFeatures) - 1 do
      WriteString(FDestFeatures[I]);
    WriteListEnd;

    Write(FSources, SizeOf(TgdcInvReferenceSources));
    Write(FDirection, SizeOf(TgdcInvMovementDirection));

    WriteBoolean(FControlRemains);
    WriteBoolean(FLiveTimeRemains);
    WriteBoolean(FCanBeDelayed);
    WriteBoolean(FUseCachedUpdates);
    WriteBoolean(FisMinusRemains);
    WriteListBegin;
    for I := 0 to Length(FMinusFeatures) - 1 do
      WriteString(FMinusFeatures[I]);
    WriteListEnd;
    WriteBoolean(FIsChangeCardValue);
    WriteBoolean(FIsAppendCardValue);
    WriteBoolean(FIsUseCompanyKey);
    WriteBoolean(FSaveRestWindowOption);
    WriteBoolean(FEndMonthRemains);

  finally
    Free;
  end;
end;

procedure TgdcInvDocumentLine.SetSubType(const Value: String);
begin
  inherited;
  if Assigned(FMovement) then
    FMovement.SubType := Value;
end;

procedure TgdcInvDocumentLine.DoAfterCancel;
var
  DataSet: TgdcBase;
begin
  inherited;
  if FisErrorUpdate then
  begin
    try
      FMovement.gdcDocumentLine := Self;
      FMovement.Database := Database;
      FMovement.ReadTransaction := Transaction;
      FMovement.Transaction := Transaction;

      if Assigned(MasterSource) and Assigned(MasterSource.DataSet) then
        DataSet := MasterSource.DataSet as TgdcBase
      else
        DataSet := nil;

      if Assigned(DataSet) and (sDialog in DataSet.BaseState) and not CachedUpdates
      then
        FMovement.CreateMovement(ipsmPosition)
      else
        FMovement.CreateMovement(ipsmDocument);
    except
      on E:Exception do
      begin
        if not (sLoadFromStream in BaseState) then
          MessageBox(ParentHandle, PChar(Format(s_InvErrorSaveHeadDocument,
            [E.Message])), PChar(sAttention), mb_OK or mb_IconInformation);
        Transaction.RollbackRetaining;
        Close;
        Open;
      end;
    end;
    FisErrorUpdate := False;
  end;
end;

procedure TgdcInvDocumentLine.SetFeatures(isFrom, isTo: Boolean);
var
  ibsql: TIBSQL;
  i: Integer;
begin
  try
    FisSetFeaturesFromRemains := True;
    if isFrom and not FieldByName('FROMCARDKEY').IsNull then
    begin
      ibsql := TIBSQL.Create(Self);
      try
        ibsql.Transaction := ReadTransaction;
        ibsql.SQL.Text := 'SELECT * FROM inv_card WHERE id = :id';
        ibsql.ParamByName('id').AsInteger := FieldByName('fromcardkey').AsInteger;
        ibsql.ExecQuery;
        if ibsql.RecordCount > 0 then
        begin
          for i:= Low(FSourceFeatures) to High(FSourceFeatures) do
            FieldByName('FROM_' + FSourceFeatures[i]).AsVariant :=
              ibsql.FieldByName(FSourceFeatures[i]).AsVariant;
        end;
        ibsql.Close;
      finally
        ibsql.Free;
      end;
    end;
    if isTo then
    begin
      for i:= Low(FSourceFeatures) to High(FSourceFeatures) do
        if Assigned(FindField('TO_' + FSourceFeatures[i])) then
          FieldByName('TO_' + FSourceFeatures[i]).AsVariant :=
             FieldByName('FROM_' + FSourceFeatures[i]).AsVariant;
    end;
  finally
    FisSetFeaturesFromRemains := False;
  end;
end;

procedure TgdcInvDocumentLine._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet; PropertyList: TgdcPropertySets;
  BindedList: TgdcObjectSet; WithDetailList: TgdKeyArray;
  const SaveDetailObjects: Boolean);
var
  I: Integer;
  fld: TatRelationField;
  Obj: TgdcBase;
  FC: TgdcFullClass;
begin
 if ((ObjectSet <> nil) and (ObjectSet.Find(ID) > -1)) then
   Exit;
{Перед сохранением документа необходимо сохранить ссылки из карточки}
  for I := 0 to FieldCount - 1 do
  begin
    if (AnsiPos('"INV_CARD".', Fields[I].Origin) = 1) and (Fields[I].DataType = ftInteger)
      and not Fields[I].IsNull then
    begin
      fld := atDatabase.FindRelationField('INV_CARD',
        System.Copy(Fields[I].Origin, 13, Length(Fields[I].Origin) - 13));
      if Assigned(fld) and Assigned(fld.References) and (Fields[I].AsInteger <> ID) then
      begin
        FC := GetBaseClassForRelationByID(fld.References.RelationName, Fields[I].AsInteger, Transaction);
        if Assigned(FC.gdClass) then
        begin
          Obj := FC.gdClass.CreateWithID(nil, Database, Transaction,
            Fields[I].AsInteger, FC.SubType);
          try
            if Transaction.InTransaction then
              Obj.ReadTransaction := Transaction
            else
              Obj.ReadTransaction := ReadTransaction;
            Obj.FReadUserFromStream := Self.FReadUserFromStream;  
            Obj.Open;
            if Obj.RecordCount = 1 then
            begin
              Obj._SaveToStream(Stream, ObjectSet, PropertyList, BindedList,
                WithDetailList, SaveDetailObjects);
            end;
          finally
            Obj.Free;
          end;
        end;
      end;
    end;
  end;
  inherited;
end;

function TgdcInvDocumentLine.GetMasterObject: TgdcDocument;
begin
  Result := TgdcInvDocument.CreateSubType(Owner, SubType);
end;


function TgdcInvDocumentLine.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCINVDOCUMENTLINE', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENTLINE', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENTLINE',
  {M}          'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETNOTCOPYFIELD' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TGDCINVDOCUMENTLINE(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENTLINE' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetNotCopyField + ',FROMCARDKEY,TOCARDKEY';
  
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENTLINE', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENTLINE', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvDocumentLine.DoBeforeInsert;

  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVDOCUMENTLINE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENTLINE', KEYDOBEFOREINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENTLINE',
  {M}          'DOBEFOREINSERT', KEYDOBEFOREINSERT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  SaveHeader;
  inherited;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENTLINE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENTLINE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT);
  {M}  end;
  {END MACRO}
end;


procedure TgdcInvDocumentLine.SaveHeader;
var
  R: TatRelation;
  F: TatRelationField;
begin
  if Assigned(MasterSource) and Assigned(MasterSource.DataSet) and
     (MasterSource.DataSet.State in [dsInsert]) and
     (MasterSource.DataSet is TgdcInvBaseDocument)
  then
  begin
    if ((AnsiCompareText(MovementSource.RelationName,
         (MasterSource.DataSet as TgdcInvBaseDocument).RelationName) = 0) and
       MasterSource.DataSet.FieldByName(MovementSource.SourceFieldName).IsNull)
    then
    begin
      R := atDatabase.Relations.ByRelationName(MovementSource.RelationName);
      if Assigned(R) then
      begin
        F := R.RelationFields.ByFieldName(MovementSource.SourceFieldName);
        if Assigned(F) then
          MessageBox(ParentHandle, PChar(s_InvEmptyField + F.LName), PChar(sAttention),
            mb_Ok or mb_IconInformation)
        else
          MessageBox(ParentHandle, PChar(s_InvEmptyField), PChar(sAttention),
            mb_Ok or mb_IconInformation);
        abort;
      end;
    end;

    if ((AnsiCompareText(MovementTarget.RelationName,
         (MasterSource.DataSet as TgdcInvBaseDocument).RelationName) = 0) and
       MasterSource.DataSet.FieldByName(MovementTarget.SourceFieldName).IsNull)
    then
    begin
      R := atDatabase.Relations.ByRelationName(MovementTarget.RelationName);
      if Assigned(R) then
      begin
        F := R.RelationFields.ByFieldName(MovementTarget.SourceFieldName);
        if Assigned(F) then
          MessageBox(ParentHandle, PChar(s_InvEmptyField + F.LName), PChar(sAttention),
            mb_Ok or mb_IconInformation)
        else
          MessageBox(ParentHandle, PChar(s_InvEmptyField), PChar(sAttention),
            mb_Ok or mb_IconInformation);
        abort;
      end;
    end;

    try
      MasterSource.DataSet.Post;
    except
      on E: Exception do
      begin
        MessageBox(ParentHandle, PChar(Format(s_InvErrorSaveHeadDocument, [E.Message])),
          PChar(sAttention), mb_ok or mb_IconInformation);
        abort;
      end;
    end;
  end;

end;

procedure TgdcInvDocumentLine.SetIsMakeMovementOnFromCardKeyOnly(
  const Value: Boolean);
begin
  if Value <> FIsMakeMovementOnFromCardKeyOnly then
  begin
    FIsMakeMovementOnFromCardKeyOnly := Value;
    Movement.ClearCardQuery;
  end;
end;

{ TgdcInvDocumentType }

constructor TgdcInvDocumentType.Create(AnOwner: TComponent);
begin
  inherited;

  CustomProcess := [cpInsert, cpModify];
end;

function TgdcInvDocumentType.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCINVDOCUMENTTYPE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENTTYPE', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENTTYPE',
  {M}          'CREATEDIALOGFORM', KEYCREATEDIALOGFORM, Params, LResult) then
  {M}          begin
  {M}            Result := nil;
  {M}            if VarType(LResult) <> varDispatch then
  {M}              raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен не объект.')
  {M}            else
  {M}              if IDispatch(LResult) = nil then
  {M}                raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                  'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен пустой (null) объект.');
  {M}            Result := GetInterfaceToObject(LResult) as TCreateableForm;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENTTYPE' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dlgSetupInvDocument.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENTTYPE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENTTYPE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvDocumentType.CreateFields;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVDOCUMENTTYPE', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENTTYPE', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENTTYPE',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENTTYPE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FieldByName('headerrelkey').Required := True;
  FieldByName('linerelkey').Required := True;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENTTYPE', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENTTYPE', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvDocumentType.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVDOCUMENTTYPE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENTTYPE', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENTTYPE',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENTTYPE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  //складские документы не могут быть общими!
  FieldByName('iscommon').AsInteger := 0;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENTTYPE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENTTYPE', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

class function TgdcInvDocumentType.GetHeaderDocumentClass: CgdcBase;
begin
  Result := TgdcInvDocument;
end;

class function TgdcInvDocumentType.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmInvDocumentType';
end;

class function TgdcInvDocumentType.InvDocumentTypeBranchKey: Integer;
begin
  Result := INV_DOC_INVENTBRANCH;
end;

initialization
  RegisterGdcClass(TgdcInvBaseDocument);
  RegisterGdcClass(TgdcInvDocumentType);
  RegisterGdcClass(TgdcInvDocument);
  RegisterGdcClass(TgdcInvDocumentLine);

finalization
  UnRegisterGdcClass(TgdcInvBaseDocument);
  UnRegisterGdcClass(TgdcInvDocumentType);
  UnRegisterGdcClass(TgdcInvDocument);
  UnRegisterGdcClass(TgdcInvDocumentLine);

end.

