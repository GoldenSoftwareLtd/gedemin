
unit gdc_dlgSetupInvDocument_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList,  StdCtrls, ExtCtrls, ComCtrls, ToolWin,
  gdcBase, Db, gdc_dlgG_unit, gdcInvDocument_Unit, gsIBLookupComboBox,
  Mask, DBCtrls, at_classes, Contnrs, IBCustomDataSet,
  ImgList, IBDatabase, IBSQL, TB2Item, TB2Dock, TB2Toolbar,
  Grids, DBGrids, gsDBGrid, gsIBGrid, gdcMetaData, gdc_dlgTR_unit,
  gdc_dlgDocumentType_unit, gdcAcctTransaction, gdcClasses, Menus,
  gdcDelphiObject, gd_createable_form, gdcFunction,
  xCalculatorEdit, gdcCustomFunction, gd_ClassList;

type
  Tgdc_dlgSetupInvDocument = class(Tgdc_dlgDocumentType)
    cbTemplate: TComboBox;
    lblDocument: TLabel;
    cbDocument: TComboBox;
    tsFeatures: TTabSheet;
    lvFeatures: TListView;
    lvUsedFeatures: TListView;
    btnAdd: TButton;
    btnRemove: TButton;
    btnAddAll: TButton;
    btnRemoveAll: TButton;
    rgFeatures: TRadioGroup;
    actAddFeature: TAction;
    actRemoveFeature: TAction;
    actAddAllFeatures: TAction;
    actRemoveAllFeatures: TAction;
    tsIncomeMovement: TTabSheet;
    Label6: TLabel;
    lblDebitFrom: TLabel;
    lblDebitSubFrom: TLabel;
    lblDebitValue: TLabel;
    lblSubDebitValue: TLabel;
    cbDebitMovement: TComboBox;
    lvDebitMovementValues: TListView;
    btnAddDebitValue: TButton;
    btnDeleteDebitValue: TButton;
    rgDebitFrom: TRadioGroup;
    luDebitFrom: TComboBox;
    luDebitSubFrom: TComboBox;
    lvSubDebitMovementValues: TListView;
    btnAddSubDebitValue: TButton;
    btnDeleteSubDebitValue: TButton;
    rgDebitSubFrom: TRadioGroup;
    cbUseIncomeSub: TCheckBox;
    actAddDebitContact: TAction;
    actDeleteDebitContact: TAction;
    tsOutlayMovement: TTabSheet;
    Label8: TLabel;
    lblCreditFrom: TLabel;
    lblCreditSubFrom: TLabel;
    lblCreditValue: TLabel;
    lblSubCreditValue: TLabel;
    cbCreditMovement: TComboBox;
    lvCreditMovementValues: TListView;
    btnAddCreditValue: TButton;
    btnDeleteCreditValue: TButton;
    rgCreditFrom: TRadioGroup;
    luCreditFrom: TComboBox;
    luCreditSubFrom: TComboBox;
    lvSubCreditMovementValues: TListView;
    btnAddSubCreditValue: TButton;
    btnDeleteSubCreditValue: TButton;
    rgCreditSubFrom: TRadioGroup;
    cbUseOutlaySub: TCheckBox;
    actAddCreditContact: TAction;
    actDeleteCreditContact: TAction;
    tsReferences: TTabSheet;
    rgMovementDirection: TRadioGroup;
    cbRemains: TCheckBox;
    cbReference: TCheckBox;
    cbControlRemains: TCheckBox;
    cbLiveTimeRemains: TCheckBox;
    cbDelayedDocument: TCheckBox;
    actAddSubDebitContact: TAction;
    actDeleteSubDebitContact: TAction;
    actAddSubCreditContact: TAction;
    actDeleteSubCreditContact: TAction;
    actAddAmountField: TAction;
    actCreateCalcMacros: TAction;
    actViewCalcMacros: TAction;
    actDeleteCalcMacros: TAction;
    actDelAmountField: TAction;
    lFormatDoc: TLabel;
    cbMinusRemains: TCheckBox;
    gbMinusFeatures: TGroupBox;
    lvMinusFeatures: TListView;
    btnAdd_Minus: TButton;
    btnRemove_Minus: TButton;
    btnAddAll_Minus: TButton;
    btnRemoveAll_Minus: TButton;
    lvMinusUsedFeatures: TListView;
    actAdd_MinusFeature: TAction;
    actRemove_MinusFeature: TAction;
    actAddAll_MinusFeature: TAction;
    actRemoveAll_MinusFeature: TAction;
    cbIsChangeCardValue: TCheckBox;
    cbIsAppendCardValue: TCheckBox;
    cbIsUseCompanyKey: TCheckBox;
    cbSaveRestWindowOption: TCheckBox;
    cbEndMonthRemains: TCheckBox;
    cbWithoutSearchRemains: TCheckBox;
    lblNotification: TLabel;
    lblRestrictBy: TLabel;
    luRestrictBy: TComboBox;

    procedure actAddFeatureExecute(Sender: TObject);
    procedure actRemoveFeatureExecute(Sender: TObject);
    procedure actAddAllFeaturesExecute(Sender: TObject);
    procedure actRemoveAllFeaturesExecute(Sender: TObject);

    procedure actAddFeatureUpdate(Sender: TObject);
    procedure actRemoveFeatureUpdate(Sender: TObject);
    procedure actAddAllFeaturesUpdate(Sender: TObject);
    procedure actRemoveAllFeaturesUpdate(Sender: TObject);

    procedure actAddDebitContactExecute(Sender: TObject);
    procedure actDeleteDebitContactExecute(Sender: TObject);

    procedure actDeleteDebitContactUpdate(Sender: TObject);
    procedure actAddDebitContactUpdate(Sender: TObject);
    procedure cbDebitMovementChange(Sender: TObject);
    procedure cbUseIncomeSubClick(Sender: TObject);
    procedure cbRemainsClick(Sender: TObject);
    procedure cbDocumentClick(Sender: TObject);
    procedure pcMainChange(Sender: TObject);
    procedure pcMainChanging(Sender: TObject; var AllowChange: Boolean);
    procedure rgFeaturesClick(Sender: TObject);
    procedure iblcLineTableChange(Sender: TObject);
    procedure cbMinusRemainsClick(Sender: TObject);
    procedure actAdd_MinusFeatureExecute(Sender: TObject);
    procedure actRemove_MinusFeatureExecute(Sender: TObject);
    procedure actAddAll_MinusFeatureExecute(Sender: TObject);
    procedure actRemoveAll_MinusFeatureExecute(Sender: TObject);
    procedure luCreditFromDropDown(Sender: TObject);
    procedure cbTemplateChange(Sender: TObject);
    procedure iblcHeaderTableChange(Sender: TObject);

  private
    FTemplates: TObjectList;
    FDestFeatures: TStringList;
    FSourceFeatures: TStringList;
    FMinusFeatures: TStringList;

    function GetDocument: TgdcInvDocumentType;

    function FindFeature(FeatureName: String;
      const FindUsedFeature: Boolean = False;
      const isMinus: Boolean = False): TListItem;

    procedure UpdateTabs;
    procedure UpdateTemplate;
    procedure UpdateDocumentTemplates;

    procedure SetupMovementTab;
    procedure SetupFeaturesTab;
    procedure SetupMinusFeaturesTab;

    procedure CreateDocumentTemplateData;

    procedure TestMovement;
    procedure TestReferences;

    procedure UpdateFeatureList;
    procedure AddFeature(UsedFeatures, Features: TListView);
    procedure RemoveFeature(UsedFeatures, Features: TListView);
    function GetMinusFeatures: TStringList;

  protected
    FIDE, FIDEParent: TgdInvDocumentEntry;

    procedure SetupDialog; override;
    procedure SetupRecord; override;
    function TestCorrect: Boolean; override;
    procedure Post; override;
    procedure AfterPost; override;
    function FindFieldInCombo(Box: TComboBox): String;
    procedure ReadOptions;
    procedure WriteOptions(Stream: TStream);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Document: TgdcInvDocumentType read GetDocument;
    property DestFeatures: TStringList read FDestFeatures;
    property SourceFeatures: TStringList read FSourceFeatures;
    property MinusFeatures: TStringList read GetMinusFeatures;
  end;

  EdlgSetupInvDocument = class(Exception);

var
  gdc_dlgSetupInvDocument: Tgdc_dlgSetupInvDocument;

implementation

{$R *.DFM}

uses
  gdcInvConsts_unit,              dmDatabase_unit,        gdcContacts,
  dmImages_unit,                  gdc_inv_dlgPredefinedField_unit,
  gdc_inv_dlgViewFieldEvent_unit, gdcClasses_interface,
  gd_strings,                     gd_security,
  gdcBaseInterface
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{Находит последнее вхождение символа в строку. Необходимо для поиска "(" и ")",
т.к. эти символы могут быть использованы в локализованном наименовании поля}  
function LastCharPos(const Ch: Char; const S: String): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := Length(S) downto 1 do
  begin
    if Ch = S[I] then
    begin
      Result := I;
      break;
    end;
  end;
end;

{ Tgdc_dlgSetupInvDocument }

procedure Tgdc_dlgSetupInvDocument.actAddAllFeaturesExecute(
  Sender: TObject);
var
  Item: TListItem;
  I: Integer;
begin
  for I := 0 to lvFeatures.Items.Count - 1 do
  begin
    Item := lvUsedFeatures.Items.Add;
    Item.Caption := lvFeatures.Items[I].Caption;
    Item.Data := lvFeatures.Items[I].Data;
  end;

  lvFeatures.Items.Clear;

  UpdateFeatureList;
end;

procedure Tgdc_dlgSetupInvDocument.actAddAllFeaturesUpdate(
  Sender: TObject);
begin
  actAddAllFeatures.Enabled := lvFeatures.Items.Count > 0;
end;

procedure Tgdc_dlgSetupInvDocument.actAddDebitContactExecute(
  Sender: TObject);
var
  Contact: TgdcBaseContact;
  ListView: TListView;
  Item: TListItem;
  BaseClassName: String;
  Combo: TComboBox;
  V: OleVariant;
begin
  if Sender = actAddDebitContact then
  begin
    ListView := lvDebitMovementValues;
    Combo := cbDebitMovement;
  end
  else if Sender = actAddSubDebitContact then
  begin
    ListView := lvSubDebitMovementValues;
    Combo := cbDebitMovement;
  end
  else if Sender = actAddCreditContact then
  begin
    ListView := lvCreditMovementValues;
    Combo := cbCreditMovement;
  end
  else if Sender = actAddSubCreditContact then
  begin
    ListView := lvSubCreditMovementValues;
    Combo := cbCreditMovement;
  end else
    exit;

  //
  // Осуществляем выбор товаров из справочника
  if (Combo.ItemIndex <> 1) and (Combo.ItemIndex <> 2)  and (Combo.ItemIndex <> 4) then
  begin
    Contact := TgdcBaseContact.Create(nil);
    BaseClassName := 'gdcContacts'
  end else
  begin
    Contact := TgdcDepartment.Create(nil);
    if (Combo.ItemIndex = 1) then
      BaseClassName := 'gdcDepartment'
    else
      BaseClassName := 'gdcPeople';
  end;

  try
    if Contact.ChooseItems(V, BaseClassName, cst_AllContact) then
    begin
      Contact.SubSet := 'OnlySelected';
      Contact.Open;
      while not Contact.Eof do
      begin
        Item := ListView.Items.Add;
        Item.Caption := Contact.FieldByName('name').AsString;
        Item.SubItems.Add(TID2S(Contact.ID));
        Contact.Next;
      end;
    end;
  finally
    Contact.Free;
  end;
end;

procedure Tgdc_dlgSetupInvDocument.actAddDebitContactUpdate(
  Sender: TObject);
var
  Combo: TComboBox;
  Check: TCheckBox;
begin
  if Sender = actAddDebitContact then
  begin
    Combo := cbDebitMovement;
    Check := nil;
  end
  else if Sender = actAddCreditContact then
  begin
    Combo := cbCreditMovement;
    Check := nil;
  end
  else if Sender = actAddSubDebitContact then
  begin
    Combo := cbDebitMovement;
    Check := cbUseIncomeSub;
  end
  else if Sender = actAddSubCreditContact then
  begin
    Combo := cbCreditMovement;
    Check := cbUseOutlaySub;
  end else
    exit;

  (Sender as TAction).Enabled :=
    (Combo.ItemIndex <> -1) and ((Check = nil) or Check.Checked);
end;

procedure Tgdc_dlgSetupInvDocument.AddFeature(UsedFeatures, Features: TListView);
var
  Item: TListItem;
  Index: Integer;
begin
  if Features.Selected <> nil then
  begin
    Item := UsedFeatures.Items.Add;
    Item.Caption := Features.Selected.Caption;
    Item.Data := Features.Selected.Data;

    Index := Features.Selected.Index;
    Features.Selected.Delete;

    if Index < Features.Items.Count then
      Features.Selected := Features.Items[Index]
    else if Features.Items.Count > 0 then
      Features.Selected := Features.Items[Features.Items.Count - 1];
  end;
end;

procedure Tgdc_dlgSetupInvDocument.actAddFeatureExecute(Sender: TObject);
begin
  AddFeature(lvUsedFeatures, lvFeatures);
  UpdateFeatureList;
end;

procedure Tgdc_dlgSetupInvDocument.actAddFeatureUpdate(Sender: TObject);
begin
  actAddFeature.Enabled := lvFeatures.Selected <> nil;
end;

procedure Tgdc_dlgSetupInvDocument.actDeleteDebitContactExecute(
  Sender: TObject);
var
  I: Integer;
  ListView: TListView;
begin
  if Sender = actDeleteDebitContact then
    ListView := lvDebitMovementValues
  else if Sender = actDeleteSubDebitContact then
    ListView := lvSubDebitMovementValues
  else if Sender = actDeleteCreditContact then
    ListView := lvCreditMovementValues
  else if Sender = actDeleteSubCreditContact then
    ListView := lvSubCreditMovementValues
  else
    exit;

  if ListView.Selected <> nil then
  begin
    I := ListView.Selected.Index;
    ListView.Selected.Delete;

    if I < ListView.Items.Count then
      ListView.Selected := ListView.Items[I]
    else if ListView.Items.Count > 0 then
      ListView.Selected := ListView.Items[ListView.Items.Count - 1];
  end;
end;

procedure Tgdc_dlgSetupInvDocument.actDeleteDebitContactUpdate(
  Sender: TObject);
var
  ListView: TListView;
  Combo: TComboBox;
  Check: TCheckBox;
begin
  if Sender = actDeleteDebitContact then
  begin
    ListView := lvDebitMovementValues;
    Combo := cbDebitMovement;
    Check := nil;
  end
  else if Sender = actDeleteSubDebitContact then
  begin
    ListView := lvSubDebitMovementValues;
    Combo := cbDebitMovement;
    Check := cbUseIncomeSub;
  end
  else if Sender = actDeleteCreditContact then
  begin
    ListView := lvCreditMovementValues;
    Combo := cbCreditMovement;
    Check := nil;
  end
  else if Sender = actDeleteSubCreditContact then
  begin
    ListView := lvSubCreditMovementValues;
    Combo := cbCreditMovement;
    Check := cbUseOutlaySub;
  end else
    exit;

  (Sender as TAction).Enabled := (Combo.ItemIndex <> -1) and
    (ListView.Selected <> nil) and ((Check = nil) or Check.Checked);
end;

procedure Tgdc_dlgSetupInvDocument.actRemoveAllFeaturesExecute(
  Sender: TObject);
var
  Item: TListItem;
  I: Integer;
begin
  for I := 0 to lvUsedFeatures.Items.Count - 1 do
  begin
    Item := lvFeatures.Items.Add;
    Item.Caption := lvUsedFeatures.Items[I].Caption;
    Item.Data := lvUsedFeatures.Items[I].Data;
  end;

  lvUsedFeatures.Items.Clear;

  UpdateFeatureList;
end;

procedure Tgdc_dlgSetupInvDocument.actRemoveAllFeaturesUpdate(
  Sender: TObject);
begin
  actRemoveAllFeatures.Enabled := lvUsedFeatures.Items.Count > 0;
end;

procedure Tgdc_dlgSetupInvDocument.RemoveFeature(UsedFeatures, Features: TListView);
var
  Item: TListItem;
  Index: Integer;
begin
  if UsedFeatures.Selected <> nil then
  begin
    Item := Features.Items.Add;
    Item.Caption := UsedFeatures.Selected.Caption;
    Item.Data := UsedFeatures.Selected.Data;

    Index := UsedFeatures.Selected.Index;
    UsedFeatures.Selected.Delete;

    if Index < UsedFeatures.Items.Count then
      UsedFeatures.Selected := UsedFeatures.Items[Index] else
    if UsedFeatures.Items.Count > 0 then
      UsedFeatures.Selected := UsedFeatures.Items[UsedFeatures.Items.Count - 1];
  end;
end;

procedure Tgdc_dlgSetupInvDocument.actRemoveFeatureExecute(
  Sender: TObject);
begin
  RemoveFeature(lvUsedFeatures, lvFeatures);
  UpdateFeatureList;
end;

procedure Tgdc_dlgSetupInvDocument.actRemoveFeatureUpdate(Sender: TObject);
begin
  actRemoveFeature.Enabled := lvUsedFeatures.Selected <> nil;
end;

procedure Tgdc_dlgSetupInvDocument.UpdateFeatureList;
var
  List: TStringList;
  UsedListView: TListView;
  I: Integer;
begin
  if rgFeatures.ItemIndex = -1 then
    exit;

  UsedListView := lvUsedFeatures;

  case TgdcInvFeatureKind(rgFeatures.ItemIndex) of
    ifkDest:
    begin
      List := FDestFeatures;
      if [TgdcInvRelationType(cbTemplate.ItemIndex)] * [irtFeatureChange, irtTransformation] = [] then
        FSourceFeatures.Clear;
    end;
    ifkSource:
    begin
      List := FSourceFeatures;
      if [TgdcInvRelationType(cbTemplate.ItemIndex)] * [irtFeatureChange, irtTransformation] = [] then
        FDestFeatures.Clear;
    end;
  else
    List := nil;
  end;

  if List <> nil then
  begin
    List.Clear;
    for I := 0 to UsedListView.Items.Count - 1 do
      if UsedListView.Items[I].Data <> nil then
        List.AddObject(TatRelationField(UsedListView.Items[I].Data).FieldName,
          UsedListView.Items[I].Data);
  end;    
end;

procedure Tgdc_dlgSetupInvDocument.cbDebitMovementChange(Sender: TObject);
var
  Combo: TComboBox;
  LabelCombo, SubLabelCombo: TLabel;
  CheckBox: TCheckBox;
begin
  if Sender = cbDebitMovement then
  begin
    Combo := luDebitFrom;
    LabelCombo := lblDebitFrom;
    CheckBox := cbUseIncomeSub;

    SubLabelCombo := lblDebitSubFrom;
  end
  else if Sender = cbCreditMovement then
  begin
    Combo := luCreditFrom;
    LabelCombo := lblCreditFrom;
    CheckBox := cbUseOutlaySub;

    SubLabelCombo := lblCreditSubFrom;
  end else
    exit;

  case TgdcInvMovementContactType((Sender as TComboBox).ItemIndex) of
    imctOurCompany:
    begin
      LabelCombo.Caption := 'Поле нашей компании:';
      Combo.Visible := True;

      SubLabelCombo.Caption := 'Ограничение невозможно:';

      CheckBox.Checked := False;
      CheckBox.Visible := False;

      cbUseIncomeSubClick(CheckBox);
    end;

    imctOurDepartment, imctOurDepartAndPeople:
    begin
      LabelCombo.Caption := 'Поле подразделения нашей компании:';
      Combo.Visible := True;

      SubLabelCombo.Caption := 'Поле подразделения нашей компании:';

      CheckBox.Visible := True;
      cbUseIncomeSubClick(CheckBox);
    end;

    imctOurPeople:
    begin
      LabelCombo.Caption := 'Поле сотрудника нашей компании:';
      Combo.Visible := True;

      SubLabelCombo.Caption := 'Поле подразделения нашей компании:';

      CheckBox.Visible := True;
      cbUseIncomeSubClick(CheckBox);
    end;

    imctCompany:
    begin
      LabelCombo.Caption := 'Поле клиента:';
      Combo.Visible := True;

      SubLabelCombo.Caption := 'Ограничение невозможно';

      CheckBox.Checked := False;
      CheckBox.Visible := False;

      cbUseIncomeSubClick(CheckBox);
    end;

    imctCompanyDepartment:
    begin
      LabelCombo.Caption := 'Поле подразделения клиента:';
      Combo.Visible := True;

      SubLabelCombo.Caption := 'Поле клиента:';

      CheckBox.Visible := False;
      CheckBox.Checked := True;
      cbUseIncomeSubClick(CheckBox);
    end;

    imctCompanyPeople:
    begin
      LabelCombo.Caption := 'Поле сотрудника клиента:';
      Combo.Visible := True;

      SubLabelCombo.Caption := 'Поле клиента:';

      CheckBox.Visible := False;
      CheckBox.Checked := True;
      cbUseIncomeSubClick(CheckBox);
    end;

    imctPeople:
    begin
      LabelCombo.Caption := 'Поле физического лица:';
      Combo.Visible := True;

      SubLabelCombo.Caption := 'Ограничение невозможно';

      CheckBox.Checked := False;
      CheckBox.Visible := False;

      cbUseIncomeSubClick(CheckBox);
    end;
  end;
end;

procedure Tgdc_dlgSetupInvDocument.luCreditFromDropDown(Sender: TObject);
var
  rg: TRadioGroup;
  cmb: TComboBox;

  procedure UpdateBox(Box: TComboBox; R: TatRelation);
  var
    i: Integer;
    sOldText: string;
  begin
    sOldText:= Box.Text;
    Box.Enabled := Assigned(R);
    if not Assigned(R) then
      exit;
    Box.Items.Clear;
    for i:= 0 to R.RelationFields.Count - 1 do
      if R.RelationFields[i].IsUserDefined then
          Box.Items.Add(
            R.RelationFields[i].lname + '(' +
            R.RelationFields[i].fieldname + ')'
          );
    i := Box.Items.IndexOf(sOldText);
    Box.ItemIndex := i;
  end;

begin
  rg := nil;
  cmb := nil;
  if Sender is TComboBox then begin
    cmb := Sender as TComboBox;
    if Sender = luDebitFrom then
      rg := rgDebitFrom
    else if Sender = luDebitSubFrom then
      rg := rgDebitSubFrom
    else if Sender = luCreditFrom then
      rg := rgCreditFrom
    else if Sender = luCreditSubFrom then
      rg := rgCreditSubFrom;
  end
  else if Sender is TRadioGroup then begin
    rg := Sender as TRadioGroup;
    if Sender = rgDebitFrom then
      cmb := luDebitFrom
    else if Sender = rgDebitSubFrom then
      cmb := luDebitSubFrom
    else if Sender = rgCreditFrom then
      cmb := luCreditFrom
    else if Sender = rgCreditSubFrom then
      cmb := luCreditSubFrom;
  end;

  if Assigned(rg) and Assigned(cmb) then
    case rg.ItemIndex of
      0: UpdateBox(cmb, GetRelation(True));
      1: UpdateBox(cmb, GetRelation(False));
      else
        cmb.Items.Clear;
    end
  else
    cmb.Items.Clear;
end;

procedure Tgdc_dlgSetupInvDocument.cbUseIncomeSubClick(Sender: TObject);
begin
  if Sender = cbUseIncomeSub then
  begin
    rgDebitSubFrom.Enabled := (Sender as TCheckBox).Checked;
    lblDebitSubFrom.Enabled := (Sender as TCheckBox).Checked;
    luDebitSubFrom.Enabled := (Sender as TCheckBox).Checked;
    lblSubDebitValue.Enabled := (Sender as TCheckBox).Checked;
    lvSubDebitMovementValues.Enabled := (Sender as TCheckBox).Checked;
  end
  else if Sender = cbUseOutlaySub then
  begin
    rgCreditSubFrom.Enabled := (Sender as TCheckBox).Checked;
    lblCreditSubFrom.Enabled := (Sender as TCheckBox).Checked;
    luCreditSubFrom.Enabled := (Sender as TCheckBox).Checked;
    lblSubCreditValue.Enabled := (Sender as TCheckBox).Checked;
    lvSubCreditMovementValues.Enabled := (Sender as TCheckBox).Checked;
  end;
end;

procedure Tgdc_dlgSetupInvDocument.cbRemainsClick(Sender: TObject);
begin
  rgMovementDirection.Visible := cbRemains.Checked;
  cbControlRemains.Visible := cbRemains.Checked;
  cbLiveTimeRemains.Visible := cbRemains.Checked;
  cbMinusRemains.Visible := cbRemains.Checked;
  cbWithoutSearchRemains.Visible := not cbControlRemains.Checked and (cbTemplate.ItemIndex = 1);
  lblRestrictBy.Visible := cbRemains.Checked;
  luRestrictBy.Visible := cbRemains.Checked;
end;

constructor Tgdc_dlgSetupInvDocument.Create(AOwner: TComponent);
begin
  inherited;
  FTemplates := TObjectList.Create(False);
  FDestFeatures := TStringList.Create;
  FSourceFeatures := TStringList.Create;
end;

procedure Tgdc_dlgSetupInvDocument.CreateDocumentTemplateData;
var
  R: TatRelation;
  I: Integer;
begin
  FTemplates.Clear;

  for I := 0 to atDatabase.Relations.Count - 1 do
    if atDatabase.Relations[I].IsUserDefined then
    begin
      R := atDatabase.Relations.ByRelationName(
        atDatabase.Relations[I].RelationName + 'LINE');

      if Assigned(R) and (RelationTypeByRelation(R) <> irtInvalid) then
        FTemplates.Add(atDatabase.Relations[I]);
    end;
end;

destructor Tgdc_dlgSetupInvDocument.Destroy;
begin
  FTemplates.Free;
  FDestFeatures.Free;
  FSourceFeatures.Free;
  FMinusFeatures.Free;
  inherited;
end;

function Tgdc_dlgSetupInvDocument.FindFeature(FeatureName: String;
  const FindUsedFeature: Boolean = False;
  const isMinus: Boolean = False): TListItem;
var
  I: Integer;
  List: TListView;
begin
  if not isMinus then
  begin
    if FindUsedFeature then
      List := lvUsedFeatures
    else
      List := lvFeatures;
  end else
  begin
    if FindUsedFeature then
      List := lvMinusUsedFeatures
    else
      List := lvMinusFeatures;
  end;

  for I := 0 to List.Items.Count - 1 do
    if AnsiSameText(TatRelationField(List.Items[I].Data).FieldName, FeatureName) then
    begin
      Result := List.Items[I];
      exit;
    end;

  Result := nil;
end;

function Tgdc_dlgSetupInvDocument.GetDocument: TgdcInvDocumentType;
begin
  Result := gdcObject as TgdcInvDocumentType;
end;

procedure Tgdc_dlgSetupInvDocument.ReadOptions;
var
  I: Integer;
  Item: TListItem;
  q: TIBSQL;
  V: TgdcMCOPredefined;
  IDE: TgdInvDocumentEntry;
  RestrictRemainsBy: string;

  procedure UpdateComboBox(CB: TComboBox; const FieldName: String);
  begin
    CB.Items.Clear;
    CB.Items.Add(FieldName + '(' + FieldName + ')');
    CB.ItemIndex := 0;
  end;

begin
  if FIDE <> nil then
    IDE := FIDE
  else if FIDEParent <> nil then
    IDE := FIDEParent
  else
    exit;

  q := TIBSQL.Create(nil);
  try
    q.Transaction := Document.Transaction;
    q.SQL.Text := 'SELECT name FROM gd_contact WHERE id = :id';

    edEnglishName.Text := Document.DocRelationName;

    // Приход

    cbDebitMovement.ItemIndex := Integer(IDE.GetMCOContactType(emDebit));
    if AnsiSameText(IDE.GetMCORelationName(emDebit), Document.DocRelationName) then
      rgDebitFrom.ItemIndex := 0
    else
      rgDebitFrom.ItemIndex := 1;

    if cbUseIncomeSub.Checked then
    begin
      if AnsiSameText(IDE.GetMCOSubRelationName(emDebit), Document.DocRelationName) then
        rgDebitSubFrom.ItemIndex := 0
      else
        rgDebitSubFrom.ItemIndex := 1;
    end;

    UpdateComboBox(luDebitFrom, IDE.GetMCOSourceFieldName(emDebit));
    UpdateComboBox(luDebitSubFrom, IDE.GetMCOSubSourceFieldName(emDebit));

    IDE.GetMCOPredefined(emDebit, V);

    for I := Low(V) to High(V) do
    begin
      q.Close;
      SetTID(q.ParamByName('ID'), V[I]);
      q.ExecQuery;
      if q.EOF then
        continue;
      Item := lvDebitMovementValues.Items.Add;
      Item.Caption := q.FieldByName('NAME').AsTrimString;
      Item.SubItems.Add(TID2S(V[I]));
    end;

    IDE.GetMCOSubPredefined(emDebit, V);

    for I := Low(V) to High(V) do
    begin
      q.Close;
      SetTID(q.ParamByName('ID'), V[I]);
      q.ExecQuery;
      if q.EOF then
        continue;
      Item := lvSubDebitMovementValues.Items.Add;
      Item.Caption := q.FieldByName('NAME').AsTrimString;
      Item.SubItems.Add(TID2S(V[I]));
    end;

    cbDebitMovementChange(cbDebitMovement);
    if cbUseIncomeSub.Visible then
      cbUseIncomeSub.Checked :=
        (IDE.GetMCOSubRelationName(emDebit) > '') and (IDE.GetMCOSubSourceFieldName(emDebit) > '');

    cbUseIncomeSubClick(cbUseIncomeSub);

    // Расход

    cbCreditMovement.ItemIndex := Integer(IDE.GetMCOContactType(emCredit));
    if AnsiSameText(IDE.GetMCORelationName(emCredit), Document.DocRelationName) then
      rgCreditFrom.ItemIndex := 0
    else
      rgCreditFrom.ItemIndex := 1;

    if cbUseOutlaySub.Checked then
    begin
      if AnsiSameText(IDE.GetMCOSubRelationName(emCredit), Document.DocRelationName) then
        rgCreditSubFrom.ItemIndex := 0
      else
        rgCreditSubFrom.ItemIndex := 1;
    end;

    UpdateComboBox(luCreditFrom, IDE.GetMCOSourceFieldName(emCredit));
    UpdateComboBox(luCreditSubFrom, IDE.GetMCOSubSourceFieldName(emCredit));

    IDE.GetMCOPredefined(emCredit, V);

    for I := Low(V) to High(V) do
    begin
      q.Close;
      SetTID(q.ParamByName('ID'), V[I]);
      q.ExecQuery;
      if q.EOF then
        continue;
      Item := lvCreditMovementValues.Items.Add;
      Item.Caption := q.FieldByName('NAME').AsTrimString;
      Item.SubItems.Add(TID2S(V[I]));
    end;

    IDE.GetMCOSubPredefined(emCredit, V);

    for I := Low(V) to High(V) do
    begin
      q.Close;
      SetTID(q.ParamByName('ID'), V[I]);
      q.ExecQuery;
      if q.EOF then
        continue;
      Item := lvSubCreditMovementValues.Items.Add;
      Item.Caption := q.FieldByName('NAME').AsTrimString;
      Item.SubItems.Add(TID2S(V[I]));
    end;

    cbDebitMovementChange(cbCreditMovement);
    if cbUseOutlaySub.Visible then
      cbUseOutlaySub.Checked :=
        (IDE.GetMCOSubRelationName(emCredit) > '') and (IDE.GetMCOSubSourceFieldName(emCredit) > '');

    cbUseIncomeSubClick(cbUseIncomeSub);

    // Настройки признаков
    FDestFeatures.Clear;
    for I := 0 to IDE.GetFeaturesCount(ftDest) - 1 do
      FDestFeatures.Add(IDE.GetFeature(ftDest, I));
    FSourceFeatures.Clear;
    for I := 0 to IDE.GetFeaturesCount(ftSource) - 1 do
      FSourceFeatures.Add(IDE.GetFeature(ftSource, I));
    SetupFeaturesTab;

    // Настройка справочников
    cbReference.Checked := irsGoodRef in IDE.GetSources;
    cbRemains.Checked := irsRemainsRef in IDE.GetSources;
//  cbFromMacro.Checked := irsMacro in Sources;

    // Ограничение отбора остатков по признаку
    if IDE.GetFeaturesCount(ftRestrRemainsBy) > 0 then
      RestrictRemainsBy := IDE.GetFeature(ftRestrRemainsBy, 0);
    if RestrictRemainsBy > '' then
    begin
      for I := 0 to luRestrictBy.Items.Count - 1 do
        if Pos('(' + RestrictRemainsBy + ')', luRestrictBy.Items[I]) > 0 then
        begin
          luRestrictBy.ItemIndex := I;
          break;
        end;
    end;

    // Настройка FIFO, LIFO
    rgMovementDirection.ItemIndex := Integer(IDE.GetDirection);

    // Конроль остатков
    cbControlRemains.Checked := IDE.GetFlag(efControlRemains);

    // работа только с текущими остатками
    cbLiveTimeRemains.Checked := IDE.GetFlag(efLiveTimeRemains);

    if not cbRemains.Checked then
    begin
      // Конроль остатков
      cbControlRemains.Checked := False;

      // работа только с текущими остатками
      cbLiveTimeRemains.Checked := False;
    end;

    // Документ может быть отложенным
    cbDelayedDocument.Checked := IDE.GetFlag(efDelayedDocument);

    cbMinusRemains.Checked := IDE.GetFlag(efMinusRemains);
    gbMinusFeatures.Visible := cbMinusRemains.Checked;

    if not cbRemains.Checked then
      cbMinusRemains.Checked := False;

    SetupMinusFeaturesTab;

    cbIsChangeCardValue.Checked := IDE.GetFlag(efIsChangeCardValue);
    cbIsAppendCardValue.Checked := IDE.GetFlag(efIsAppendCardValue);
    cbIsUseCompanyKey.Checked := IDE.GetFlag(efIsUseCompanyKey);
    cbSaveRestWindowOption.Checked := IDE.GetFlag(efSaveRestWindowOption);
    cbEndMonthRemains.Checked := IDE.GetFlag(efEndMonthRemains);

    cbWithoutSearchRemains.Visible := not cbControlRemains.Checked and (cbTemplate.ItemIndex = 1);
    if cbWithoutSearchRemains.Visible then
      cbWithoutSearchRemains.Checked := IDE.GetFlag(efWithoutSearchRemains)
    else
      cbWithoutSearchRemains.Checked := False;
  finally
    q.Free;
  end;
end;

procedure Tgdc_dlgSetupInvDocument.SetupFeaturesTab;
var
  I: Integer;
  Item, UsedItem: TListItem;
  R: TatRelation;
  List: TStringList;
begin
  if TgdcInvRelationType(cbTemplate.ItemIndex) = irtInventorization then
  begin
    rgFeatures.ItemIndex := 1;
    rgFeatures.Visible := False;
  end else begin
    rgFeatures.Visible := True;
  end;

  lvFeatures.Items.Clear;
  lvUsedFeatures.Items.Clear;
  
  case rgFeatures.ItemIndex of
    0: List := FDestFeatures;
    1: List := FSourceFeatures;
  else
    exit;
  end;

  R := atDatabase.Relations.ByRelationName('INV_CARD');
  Assert(R <> nil);

  for I := 0 to R.RelationFields.Count - 1 do
  begin
    if not R.RelationFields[I].IsUserDefined then
      continue;
    Item := lvFeatures.Items.Add;
    Item.Caption := R.RelationFields[I].LName;
    Item.Data := R.RelationFields[I];
  end;

  for I := 0 to List.Count - 1 do
  begin
    Item := FindFeature(List[I]);
    if Item = nil then
      continue;

    UsedItem := lvUsedFeatures.Items.Add;
    UsedItem.Caption := Item.Caption;
    UsedItem.Data := Item.Data;
    Item.Delete;
  end;
end;

procedure Tgdc_dlgSetupInvDocument.SetupMovementTab;

  procedure UpdateComboBox(const AHeaderTable: Boolean; Box: TComboBox);
  var
    I: Integer;
    ChosenField: String;
    S, F: Integer;
    IDE: TgdInvDocumentEntry;
    R: TatRelation;
  begin
    if Box.ItemIndex <> -1 then
    begin
      S := LastCharPos('(', Box.Items[Box.ItemIndex]);
      F := LastCharPos(')', Box.Items[Box.ItemIndex]);
      ChosenField := Copy(Box.Items[Box.ItemIndex], S + 1, F - S - 1);
    end else
      ChosenField := '';

    Box.Items.Clear;

    IDE := FIDEParent;
    R := GetRelation(AHeaderTable);

    while R <> nil do
    begin
      for I := 0 to R.RelationFields.Count - 1 do
        if R.RelationFields[i].IsUserDefined then
        begin
          Box.Items.Add(R.RelationFields[I].lname + '(' +
            R.RelationFields[I].fieldname + ')');
        end;

      if IDE <> nil then
      begin
        if AHeaderTable then
          R := atDatabase.Relations.ByRelationName(IDE.HeaderRelName)
        else
          R := atDatabase.Relations.ByRelationName(IDE.LineRelName);

        if IDE.Parent is TgdInvDocumentEntry then
          IDE := IDE.Parent as TgdInvDocumentEntry
        else
          IDE := nil;
      end else
        break;
    end;

    if ChosenField > '' then
    begin
      for I := 0 to Box.Items.Count - 1 do
        if Pos('(' + ChosenField + ')', Box.Items[I]) > 0 then
        begin
          Box.ItemIndex := I;
          break;
        end;
    end;
  end;

begin
  if pcMain.ActivePage = tsIncomeMovement then
  begin
    if rgDebitFrom.ItemIndex = 0 then
      UpdateComboBox(True, luDebitFrom) else
    if rgDebitFrom.ItemIndex = 1 then
      UpdateComboBox(False, luDebitFrom);

    if rgDebitSubFrom.ItemIndex = 0 then
      UpdateComboBox(True, luDebitSubFrom) else
    if rgDebitSubFrom.ItemIndex = 1 then
      UpdateComboBox(False, luDebitSubFrom);

    cbDebitMovementChange(cbDebitMovement);
  end else

  if pcMain.ActivePage = tsOutlayMovement then
  begin
    if rgCreditFrom.ItemIndex = 0 then
      UpdateComboBox(True, luCreditFrom) else
    if rgCreditFrom.ItemIndex = 1 then
      UpdateComboBox(False, luCreditFrom);

    if rgCreditSubFrom.ItemIndex = 0 then
      UpdateComboBox(True, luCreditSubFrom) else
    if rgCreditSubFrom.ItemIndex = 1 then
      UpdateComboBox(False, luCreditSubFrom);

    cbDebitMovementChange(cbCreditMovement);
  end;
end;

function Tgdc_dlgSetupInvDocument.TestCorrect: Boolean;
var
  //Stream: TStringStream;
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Stream: TStringStream;
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGSETUPINVDOCUMENT', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGSETUPINVDOCUMENT', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGSETUPINVDOCUMENT') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGSETUPINVDOCUMENT',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGSETUPINVDOCUMENT' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  if gdClassList.OldOptions then
  begin
    MessageBox(Handle,
      'Необходимо сконвертировать параметры типа документа в новый формат!',
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    Result := False;
    exit;
  end;

  UpdateTabs;

//Выполняется отдельно (не через общий механизм) потому как важен порядок проверки
//и потому что контрол может быть Disabled
  if Trim(edEnglishName.Text) = '' then
  begin
    if edEnglishName.CanFocus then
      edEnglishName.SetFocus;
    raise EdlgSetupInvDocument.Create('Укажите наименование на английском языке!');
  end;

  if cbTemplate.ItemIndex = -1 then
  begin
    if cbTemplate.CanFocus then
      cbTemplate.SetFocus;
    raise EdlgSetupInvDocument.Create('Укажите шаблон документа!');
  end;

  if gdcObject.FieldByName('headerrelkey').IsNull then
  begin
    gdcObject.FieldByName('headerrelkey').FocusControl;
    raise EdlgSetupInvDocument.Create('Укажите таблицу-шапку документа!');
  end;

  if gdcObject.FieldByName('linerelkey').IsNull then
  begin
    gdcObject.FieldByName('linerelkey').FocusControl;
    raise EdlgSetupInvDocument.Create('Укажите таблицу-позицию документа!');
  end;

  Result := inherited TestCorrect;

  if Result then
  begin
    TestMovement;
    TestReferences;

    Stream := TStringStream.Create('');
    try
      WriteOptions(Stream);
      Document.FieldByName('options').AsString := Stream.DataString;
    finally
      Stream.Free;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGSETUPINVDOCUMENT', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGSETUPINVDOCUMENT', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgSetupInvDocument.TestMovement;
begin
  //
  // Проверка прихода

  if cbDebitMovement.ItemIndex = -1 then
  begin
    pcMain.ActivePage := tsIncomeMovement;
    cbDebitMovement.SetFocus;
    raise EdlgSetupInvDocument.Create('Укажите как оформлять приход!');
  end;

  if rgDebitFrom.ItemIndex = -1 then
  begin
    pcMain.ActivePage := tsIncomeMovement;
    rgDebitFrom.SetFocus;
    raise EdlgSetupInvDocument.Create('Укажите откуда брать приход!');
  end;

  if luDebitFrom.ItemIndex = -1 then
  begin
    pcMain.ActivePage := tsIncomeMovement;
    if luDebitFrom.CanFocus then
      luDebitFrom.SetFocus;
    raise EdlgSetupInvDocument.Create('Укажите поле для прихода!');
  end;

  if cbUseIncomeSub.Checked then
  begin
    if rgDebitSubFrom.ItemIndex = -1 then
    begin
      pcMain.ActivePage := tsIncomeMovement;
      if luDebitSubFrom.CanFocus then
        luDebitSubFrom.SetFocus;
      raise EdlgSetupInvDocument.Create('Укажите, откуда брать ограничение расхода!');
    end;

    if luDebitSubFrom.ItemIndex = -1 then
    begin
      pcMain.ActivePage := tsIncomeMovement;
      if luDebitSubFrom.CanFocus then
        luDebitSubFrom.SetFocus;
      raise EdlgSetupInvDocument.Create('Укажите поле ограничения расхода!');
    end;

    if (rgDebitFrom.ItemIndex = 0) and (rgDebitSubFrom.ItemIndex = 1) then
    begin
      pcMain.ActivePage := tsIncomeMovement;
      if luDebitSubFrom.CanFocus then
        luDebitSubFrom.SetFocus;
      raise EdlgSetupInvDocument.Create(
        'Ограничение не может быть в позиции документа, если поле прихода ' +
        'отражается в "шапке" документа!');
    end;
  end;

  //
  // Проверка расхода

  if cbCreditMovement.ItemIndex = -1 then
  begin
    pcMain.ActivePage := tsOutlayMovement;
    cbCreditMovement.SetFocus;
    raise EdlgSetupInvDocument.Create('Укажите как оформлять расход!');
  end;

  if rgCreditFrom.ItemIndex = -1 then
  begin
    pcMain.ActivePage := tsOutlayMovement;
    rgCreditFrom.SetFocus;
    raise EdlgSetupInvDocument.Create('Укажите откуда брать расход!');
  end;

  if luCreditFrom.ItemIndex = -1 then
  begin
    pcMain.ActivePage := tsOutlayMovement;
    if luCreditFrom.CanFocus then
      luCreditFrom.SetFocus;
    raise EdlgSetupInvDocument.Create('Укажите поле для расхода!');
  end;

  if cbUseOutlaySub.Checked then
  begin
    if rgCreditSubFrom.ItemIndex = -1 then
    begin
      pcMain.ActivePage := tsOutlayMovement;
      if luCreditSubFrom.CanFocus then
        luCreditSubFrom.SetFocus;
      raise EdlgSetupInvDocument.Create('Укажите откуда брать ограничение расхода!');
    end;

    if luCreditSubFrom.ItemIndex = -1 then
    begin
      pcMain.ActivePage := tsOutlayMovement;
      if luCreditSubFrom.CanFocus then
        luCreditSubFrom.SetFocus;
      raise EdlgSetupInvDocument.Create('Укажите поле ограничения расхода!');
    end;

    if (rgCreditFrom.ItemIndex = 0) and (rgCreditSubFrom.ItemIndex = 1) then
    begin
      pcMain.ActivePage := tsOutlayMovement;
      if luCreditSubFrom.CanFocus then
        luCreditSubFrom.SetFocus;
      raise EdlgSetupInvDocument.Create(
        'Ограничение не может быть в позиции документа, если поле расхода ' +
        'отражается в "шапке" документа!');
    end;
  end;

  //
  // Общая проверка

  if
    (TgdcInvRelationType(cbTemplate.ItemIndex) = irtTransformation)
      and
    (
      (rgDebitFrom.ItemIndex = 0) and (rgCreditFrom.ItemIndex = 1)
        or
      (rgDebitFrom.ItemIndex = 1) and (rgCreditFrom.ItemIndex = 0)
    )
  then begin
    pcMain.ActivePage := tsIncomeMovement;
    if luDebitSubFrom.CanFocus then
      luDebitSubFrom.SetFocus;
    raise EdlgSetupInvDocument.Create(
      'Для документа трансформации поля прихода и расхода должны находится ' +
      'только или в шапке, или в позиции документа!');
  end;

  if
    (TgdcInvRelationType(cbTemplate.ItemIndex) = irtTransformation)
      and
    (rgDebitFrom.ItemIndex = 1) and (rgCreditFrom.ItemIndex = 1)
      and
    (luDebitFrom.ItemIndex <> luCreditFrom.ItemIndex)
  then begin
    pcMain.ActivePage := tsIncomeMovement;
    if luCreditSubFrom.CanFocus then
      luCreditSubFrom.SetFocus;
    raise EdlgSetupInvDocument.Create(
      'Для документа трансформации, если и приход, и расход в позиции документа, ' +
      'должно использоваться одно общее поле!');
  end;
end;

procedure Tgdc_dlgSetupInvDocument.TestReferences;
begin
  if not cbReference.Checked and not cbRemains.Checked then
  begin
    pcMain.ActivePage := tsReferences;
    cbReference.SetFocus;
    raise EdlgSetupInvDocument.Create('Укажите хотя бы один из источников!');
  end;

  if cbRemains.Checked and (rgMovementDirection.ItemIndex = -1) then
  begin
    pcMain.ActivePage := tsReferences;
    cbRemains.SetFocus;
    raise EdlgSetupInvDocument.Create('Укажите вид определения остатков!');
  end;

  if
    (TgdcInvRelationType(cbTemplate.ItemIndex) in
      [irtInventorization, irtFeatureChange, irtTransformation])
      and
    not cbRemains.Checked
  then begin
    pcMain.ActivePage := tsReferences;
    cbRemains.SetFocus;
    raise EdlgSetupInvDocument.Create(
      'Данный тип документа должен обязательно работать с остатками!');
  end;

  if
    (TgdcInvRelationType(cbTemplate.ItemIndex) in
      [irtInventorization])
      and
    cbReference.Checked
  then begin
    pcMain.ActivePage := tsReferences;
    cbReference.SetFocus;
    raise EdlgSetupInvDocument.Create(
      'Данный тип документа не может работать со справочником товаров!');
  end;

  if
    (TgdcInvRelationType(cbTemplate.ItemIndex) = irtInventorization)
      and
    cbLiveTimeRemains.Checked
  then begin
    cbLiveTimeRemains.Checked := False;
    MessageBox(Handle,
      'Инвентаризационный документ должен работать только с остатками на дату. ' +
        'Соответствующая опция отключена автоматически!',
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION);
  end;
end;

procedure Tgdc_dlgSetupInvDocument.UpdateDocumentTemplates;
var
  I: Integer;
begin
  cbDocument.Items.Clear;
  cbDocument.Items.AddObject('Без шаблона', nil);
  for I := 0 to FTemplates.Count - 1 do
    cbDocument.Items.AddObject((FTemplates[I] as TatRelation).LName, FTemplates[I]);
end;

procedure Tgdc_dlgSetupInvDocument.UpdateTabs;
var
  R: TatRelation;
  RelType: TgdcInvRelationType;
  IDE: TgdInvDocumentEntry;
begin
  if cbTemplate.ItemIndex = -1 then
  begin
    if FIDEParent <> nil then
      IDE := FIDEParent
    else
      IDE := nil;

    while cbTemplate.ItemIndex = -1 do
    begin
      if IDE = nil then
        R := GetRelation(False)
      else
        R := atDatabase.Relations.ByRelationName(IDE.LineRelName);

      if R <> nil then
      begin
        RelType := RelationTypeByRelation(R);
        if RelType <> irtInvalid then
          cbTemplate.ItemIndex := Integer(RelType);
      end;

      if (IDE = nil) or (not (IDE.Parent is TgdInvDocumentEntry)) then
        break
      else
        IDE := IDE.Parent as TgdInvDocumentEntry;  
    end;
  end;

  iblcHeaderTable.Enabled := edEnglishName.Text > '';
  iblcLineTable.Enabled := iblcLineTable.ItemIndex >= 0;

  if iblcLineTable.gdClassName <> 'TgdcInheritedDocumentTable' then
    case cbTemplate.ItemIndex of
    0: iblcLineTable.gdClassName := 'TgdcInvSimpleDocumentLineTable';
    1: iblcLineTable.gdClassName := 'TgdcInvFeatureDocumentLineTable';
    2: iblcLineTable.gdClassName := 'TgdcInvInventDocumentLineTable';
    3: iblcLineTable.gdClassName := 'TgdcInvTransformDocumentLineTable';
    end;

  tsFeatures.TabVisible :=
    (edDocumentName.Text > '') and
    (edEnglishName.Text > '') and
    (cbTemplate.ItemIndex <> -1) and
    (not gdcObject.FieldByName('headerrelkey').IsNull) and
    (not gdcObject.FieldByName('linerelkey').IsNull) and
    IBLogin.IsUserAdmin;

  tsIncomeMovement.TabVisible := tsFeatures.TabVisible;
  tsOutlayMovement.TabVisible := tsFeatures.TabVisible;
  tsReferences.TabVisible := tsFeatures.TabVisible;
  cbWithoutSearchRemains.Visible := (cbTemplate.ItemIndex = 1) and (not cbControlRemains.Checked);
end;

procedure Tgdc_dlgSetupInvDocument.UpdateTemplate;
var
  R, RL: TatRelation;

begin
  Assert(Document <> nil);

  //
  // По изменению шаблона таблицы осуществляем изменение ее структуры.
  // Очищаем таблицу от полей ранее выбранного шаблона

  //
  // Верхняя таблица

  if (Document.State = dsInsert) then
  begin
    if (cbDocument.ItemIndex <> -1) and (cbDocument.ItemIndex <> 0) then
      R := cbDocument.Items.Objects[cbDocument.ItemIndex] as TatRelation
    else
      R := nil;

  end else
    R := nil;

  //
  // Осуществляем перенос полей, если берется копия таблицы

  if Assigned(R) then
    SetTID(Document.FieldByName('headerrelkey'), R.ID);

  //
  // Нижняя таблица

  if (Document.State = dsInsert) then
  begin
    if (cbDocument.ItemIndex <> -1) and (cbDocument.ItemIndex <> 0) then
    begin
      R := cbDocument.Items.Objects[cbDocument.ItemIndex] as TatRelation;
      RL := atDatabase.Relations.ByRelationName(R.RelationName + 'LINE');
    end else begin
      RL := nil;
    end;
  end else
    RL := nil;

  //
  // Осуществляем перенос полей, если берется копия таблицы

  if Assigned(RL) then
    SetTID(Document.FieldByName('linerelkey'), RL.ID);
end;

procedure Tgdc_dlgSetupInvDocument.WriteOptions(Stream: TStream);
var
  Sources: TgdcInvReferenceSources;
  Direction: TgdcInvMovementDirection;
  Movement: TgdcInvMovementContactOption;
  R, RL: TatRelation;

  I: Integer;

  var
    rpgroupkey: TID;
begin
  rpgroupkey := GetTID(Document.FieldByName('reportgroupkey'));

  Movement := nil;
  with TWriter.Create(Stream, 1024) do
  try
    // Общие настройки
    WriteString(gdcInvDocument_Version3_0);

    R := GetRelation(True);
    RL := GetRelation(False);
    if not(Assigned(R) and Assigned(RL)) then
      raise EdlgSetupInvDocument.Create('Не выбраны таблицы для документа!');

    // Наименования таблиц
    WriteString(R.RelationName);
    WriteString(RL.RelationName);

     //
    // Осуществляем создание записи в списке отчетов

    if not Document.UpdateReportGroup('Складской учет',
      Document.FieldByName('name').AsString, rpgroupkey, True)
    then
      raise EdlgSetupInvDocument.Create('Report Group Key not created!');

    SetTID(Document.FieldByName('reportgroupkey'), rpgroupkey);

    // Ключ записи в списке отчетов
    WriteInteger(rpgroupkey);

    // Приход

    Movement := TgdcInvMovementContactOption.Create;
    Movement.ContactType := TgdcInvMovementContactType(cbDebitMovement.ItemIndex);

    R := GetRelation(True);
    RL := GetRelation(False);
    if rgDebitFrom.ItemIndex = 0 then
      Movement.RelationName := R.RelationName
    else
      Movement.RelationName := RL.RelationName;

    Movement.SourceFieldName := FindFieldInCombo(luDebitFrom);

    if cbUseIncomeSub.Checked then
    begin
      if rgDebitSubFrom.ItemIndex = 0 then
        Movement.SubRelationName := R.RelationName
      else
        Movement.SubRelationName := RL.RelationName;

      Movement.SubSourceFieldName := FindFieldInCombo(luDebitSubFrom);
    end else begin
      Movement.SubSourceFieldName := '';
      Movement.SubRelationName := '';
    end;

    WriteString(Movement.RelationName);
    WriteString(Movement.SourceFieldName);

    WriteString(Movement.SubRelationName);
    WriteString(Movement.SubSourceFieldName);
    Write(Movement.ContactType, SizeOf(TgdcInvMovementContactType));

    WriteListBegin;
      for I := 0 to lvDebitMovementValues.Items.Count - 1 do
        WriteInteger(GetTID(lvDebitMovementValues.Items[I].SubItems[0]));
    WriteListEnd;

    WriteListBegin;
      if cbUseIncomeSub.Checked then
        for I := 0 to lvSubDebitMovementValues.Items.Count - 1 do
          WriteInteger(GetTID(lvSubDebitMovementValues.Items[I].SubItems[0]));
    WriteListEnd;

    // Расход
    Movement.ContactType := TgdcInvMovementContactType(cbCreditMovement.ItemIndex);
    R := GetRelation(True);
    RL := GetRelation(False);
    if rgCreditFrom.ItemIndex = 0 then
      Movement.RelationName := R.RelationName
    else
      Movement.RelationName := RL.RelationName;

    Movement.SourceFieldName := FindFieldInCombo(luCreditFrom);

    if cbUseOutlaySub.Checked then
    begin
      if rgCreditSubFrom.ItemIndex = 0 then
        Movement.SubRelationName := R.RelationName
      else
        Movement.SubRelationName := RL.RelationName;

      Movement.SubSourceFieldName := FindFieldInCombo(luCreditSubFrom);
    end else begin
      Movement.SubSourceFieldName := '';
      Movement.SubRelationName := '';
    end;

    WriteString(Movement.RelationName);
    WriteString(Movement.SourceFieldName);

    WriteString(Movement.SubRelationName);
    WriteString(Movement.SubSourceFieldName);
    Write(Movement.ContactType, SizeOf(TgdcInvMovementContactType));

    WriteListBegin;
      for I := 0 to lvCreditMovementValues.Items.Count - 1 do
        WriteInteger(GetTID(lvCreditMovementValues.Items[I].SubItems[0]));
    WriteListEnd;

    WriteListBegin;
      if cbUseOutlaySub.Checked then
        for I := 0 to lvSubCreditMovementValues.Items.Count - 1 do
          WriteInteger(GetTID(lvSubCreditMovementValues.Items[I].SubItems[0]));
    WriteListEnd;

    // Настройки признаков
    WriteListBegin;

    for I := 0 to SourceFeatures.Count - 1 do
      WriteString(SourceFeatures[I]);

    WriteListEnd;

    WriteListBegin;

    for I := 0 to DestFeatures.Count - 1 do
      WriteString(DestFeatures[I]);

    WriteListEnd;

    // Настройка справочников
    Sources := [];

    if cbReference.Checked then
      Sources := Sources + [irsGoodRef];
    if cbRemains.Checked then
      Sources := Sources + [irsRemainsRef];

    Write(Sources, SizeOf(TgdcInvReferenceSources));

    // Настройка FIFO, LIFO
    Direction := TgdcInvMovementDirection(rgMovementDirection.ItemIndex);
    Write(Direction, SizeOf(TgdcInvMovementDirection));

    // Только если используются остатки сохраняем текущее значение checkbox-ов

    if cbRemains.Checked then
    begin
      // Контроль остатков
      WriteBoolean(cbControlRemains.Checked);

      // Работа только с текущими остатками
      WriteBoolean(cbLiveTimeRemains.Checked);
    end else

    begin
      // Контроль остатков
      WriteBoolean(False);

      // Работа только с текущими остатками
      WriteBoolean(False);
    end;

    // Отложенность документа
    WriteBoolean(cbDelayedDocument.Checked);

    // Кэширование данных
    WriteBoolean(False);

    // Отрицательные остатки
    if cbRemains.Checked then
      WriteBoolean(cbMinusRemains.Checked)
    else
      WriteBoolean(False);

    // Настройки признаков для отрицательных остатков
    WriteListBegin;

    for I := 0 to MinusFeatures.Count - 1 do
      WriteString(MinusFeatures[I]);

    WriteListEnd;

    WriteBoolean(cbIsChangeCardValue.Checked);
    WriteBoolean(cbIsAppendCardValue.Checked);
    WriteBoolean(cbIsUseCompanyKey.Checked);
    WriteBoolean(cbSaveRestWindowOption.Checked);
    WriteBoolean(cbEndMonthRemains.Checked);
    if not cbControlRemains.Checked then
      WriteBoolean(cbWithoutSearchRemains.Checked)
    else
      WriteBoolean(False);

  finally
    Movement.Free;
    Free;
  end;
end;

procedure Tgdc_dlgSetupInvDocument.cbTemplateChange(Sender: TObject);
begin
  UpdateTabs;
end;

procedure Tgdc_dlgSetupInvDocument.cbDocumentClick(Sender: TObject);
var
  RelType: TgdcInvRelationType;
  RL: TatRelation;
begin
  if (cbDocument.ItemIndex = -1) or
    (cbDocument.Items.Objects[cbDocument.ItemIndex] = nil)
  then begin
    UpdateTabs;
    exit;
  end;

  edEnglishName.Text := TatRelation(cbDocument.Items.Objects[cbDocument.ItemIndex]).RelationName;

  RL := atDatabase.Relations.ByRelationName(
    TatRelation(cbDocument.Items.Objects[cbDocument.ItemIndex]).RelationName + 'LINE');

  if RL = nil then
  begin
    cbTemplate.ItemIndex := -1;
    exit;
  end;

  RelType := RelationTypeByRelation(RL);
  if RelType <> irtInvalid then
    cbTemplate.ItemIndex := Integer(RelType)
  else
    cbTemplate.ItemIndex := -1;

  SetTID(Document.FieldByName('headerrelkey'),
    TatRelation(cbDocument.Items.Objects[cbDocument.ItemIndex]).ID);
  SetTID(Document.FieldByName('linerelkey'), RL.ID);  

  UpdateTabs;
end;

procedure Tgdc_dlgSetupInvDocument.pcMainChange(Sender: TObject);
begin
  if (pcMain.ActivePage = tsIncomeMovement) or
    (pcMain.ActivePage = tsOutlayMovement)
  then
    SetupMovementTab
  else if pcMain.ActivePage = tsFeatures then
    SetupFeaturesTab
  else if pcMain.ActivePage = tsReferences then
    SetupMinusFeaturesTab
  else
    inherited;
end;

procedure Tgdc_dlgSetupInvDocument.pcMainChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  if pcMain.ActivePage = tsCommon then
    UpdateTemplate;
end;

procedure Tgdc_dlgSetupInvDocument.rgFeaturesClick(Sender: TObject);
begin
  SetupFeaturesTab;
end;

procedure Tgdc_dlgSetupInvDocument.iblcLineTableChange(Sender: TObject);
begin
  inherited;
  if iblcLineTable.CurrentKey = '' then
    cbTemplate.Enabled := True;
  UpdateTabs;  
end;

procedure Tgdc_dlgSetupInvDocument.cbMinusRemainsClick(Sender: TObject);
begin
  gbMinusFeatures.Visible := cbMinusRemains.Checked;
  if cbMinusRemains.Checked then
    SetupMinusFeaturesTab;
end;

procedure Tgdc_dlgSetupInvDocument.SetupMinusFeaturesTab;
var
  I: Integer;
  Item, UsedItem: TListItem;
  R: TatRelation;
  RF: TatRelationField;
  IDE: TgdInvDocumentEntry;
begin
  lvMinusFeatures.Items.Clear;
  lvMinusUsedFeatures.Items.Clear;

  if FIDE <> nil then
    IDE := FIDE
  else if FIDEParent <> nil then
    IDE := FIDEParent
  else
    exit;

  if IDE.GetFeaturesCount(ftMinus) = 0 then
    exit;

  R := atDatabase.Relations.ByRelationName('INV_CARD');
  Assert(R <> nil);

  for I := 0 to IDE.GetFeaturesCount(ftDest) - 1 do
  begin
    RF := R.RelationFields.ByFieldName(IDE.GetFeature(ftDest, I));
    if RF <> nil then
    begin
      Item := lvMinusFeatures.Items.Add;
      Item.Caption := RF.LName;
      Item.Data := RF;
    end;
  end;

  for I := 0 to IDE.GetFeaturesCount(ftMinus) - 1 do
  begin
    Item := FindFeature(IDE.GetFeature(ftMinus, I), False, True);
    if Item = nil then
      continue;

    UsedItem := lvMinusUsedFeatures.Items.Add;
    UsedItem.Caption := Item.Caption;
    UsedItem.Data := Item.Data;
    Item.Delete;
  end;
end;

procedure Tgdc_dlgSetupInvDocument.actAdd_MinusFeatureExecute(
  Sender: TObject);
begin
  AddFeature(lvMinusUsedFeatures, lvMinusFeatures);
end;

procedure Tgdc_dlgSetupInvDocument.actRemove_MinusFeatureExecute(
  Sender: TObject);
begin
  RemoveFeature(lvMinusUsedFeatures, lvMinusFeatures);
end;

procedure Tgdc_dlgSetupInvDocument.actAddAll_MinusFeatureExecute(
  Sender: TObject);
var
  Item: TListItem;
  I: Integer;
begin
  for I := 0 to lvMinusFeatures.Items.Count - 1 do
  begin
    Item := lvMinusUsedFeatures.Items.Add;
    Item.Caption := lvMinusFeatures.Items[I].Caption;
    Item.Data := lvMinusFeatures.Items[I].Data;
  end;

  lvMinusFeatures.Items.Clear;
end;

procedure Tgdc_dlgSetupInvDocument.actRemoveAll_MinusFeatureExecute(
  Sender: TObject);
var
  Item: TListItem;
  I: Integer;
begin
  for I := 0 to lvMinusUsedFeatures.Items.Count - 1 do
  begin
    Item := lvMinusFeatures.Items.Add;
    Item.Caption := lvMinusUsedFeatures.Items[I].Caption;
    Item.Data := lvMinusUsedFeatures.Items[I].Data;
  end;

  lvMinusUsedFeatures.Items.Clear;
end;

procedure Tgdc_dlgSetupInvDocument.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  I: Integer;
  Item: TListItem;
  Relation: TatRelation;
  ibsql: TIBSQL;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGSETUPINVDOCUMENT', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGSETUPINVDOCUMENT', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGSETUPINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGSETUPINVDOCUMENT',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGSETUPINVDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  // Страница признаков
  lvFeatures.Items.Clear;
  luRestrictBy.Items.Clear;

  Relation := atDatabase.Relations.ByRelationName('INV_CARD');
  Assert(Relation <> nil);

    ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := Document.Transaction;
    ibsql.SQL.Text := 'SELECT ind.RDB$INDEX_NAME ' +
      'FROM RDB$INDICES ind ' +
      'JOIN RDB$INDEX_SEGMENTS inds ON ind.RDB$INDEX_NAME = inds.RDB$INDEX_NAME ' +
      'WHERE ind.RDB$RELATION_NAME = :RELATION_NAME ' +
      'and inds.RDB$FIELD_NAME = :FIELD_NAME ';

    for I := 0 to Relation.RelationFields.Count - 1 do
    begin
      ibsql.ParamByName('RELATION_NAME').Value := 'INV_CARD';
      ibsql.ParamByName('FIELD_NAME').Value := Relation.RelationFields[I].FieldName;
      ibsql.ExecQuery;
      if (Relation.RelationFields[I].Field.FieldType in [ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency, ftBCD, ftLargeint])
        and (ibsql.RecordCount > 0) then
        luRestrictBy.Items.Add(Relation.RelationFields[I].LShortName +
          '('+Relation.RelationFields[I].FieldName+')');

      ibsql.Close;
     end;

  finally
    ibsql.free;
  end;

  for I := 0 to Relation.RelationFields.Count - 1 do
  begin

    if not Relation.RelationFields[I].IsUserDefined then
      continue;

    Item := lvFeatures.Items.Add;

    if Relation.RelationFields[I].LShortName > '' then
      Item.Caption := Relation.RelationFields[I].LShortName
    else
      Item.Caption := Relation.RelationFields[I].FieldName;

    Item.Data := Relation.RelationFields[I];
  end;

  lvUsedFeatures.Items.Clear;

  // Страница движения
  cbDebitMovement.Items.Clear;
  cbDebitMovement.Items.Add('Нашу организацию');
  cbDebitMovement.Items.Add('Подразделение нашей организации');
  cbDebitMovement.Items.Add('Сотрудника нашей организации');
  cbDebitMovement.Items.Add('Клиента');
  cbDebitMovement.Items.Add('Подразделение клиента');
  cbDebitMovement.Items.Add('Сотрудника клиента');
  cbDebitMovement.Items.Add('Физическое лицо');
  cbDebitMovement.Items.Add('Подразделение или сотрудника нашей организации');

  cbCreditMovement.Items.Assign(cbDebitMovement.Items);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGSETUPINVDOCUMENT', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGSETUPINVDOCUMENT', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgSetupInvDocument.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  DE, DEParent: TgdDocumentEntry;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGSETUPINVDOCUMENT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGSETUPINVDOCUMENT', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGSETUPINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGSETUPINVDOCUMENT',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGSETUPINVDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  cbTemplate.ItemIndex := -1;
  cbDocument.ItemIndex := -1;

  DE := gdClassList.FindDocByTypeID(gdcObject.ID, dcpHeader, True);
  DEParent := gdClassList.FindDocByTypeID(GetTID(gdcObject.FieldByName('parent')), dcpHeader, True);

  if (DE <> nil) then
    FIDE := DE as TgdInvDocumentEntry
  else
    FIDE := nil;

  if (DEParent <> nil) then
    FIDEParent := DEParent as TgdInvDocumentEntry
  else
    FIDEParent := nil;

  if FIDEParent <> nil then
  begin
    iblcHeaderTable.gdClassName := 'TgdcInheritedDocumentTable';
    iblcLineTable.gdClassName := 'TgdcInheritedDocumentTable';
  end else
  begin
    iblcHeaderTable.gdClassName := 'TgdcDocumentTable';
    iblcLineTable.gdClassName := 'TgdcDocumentLineTable';
  end;

  if (FIDE <> nil) or (FIDEParent <> nil) then
  begin
    cbTemplate.Enabled := False;
    lblDocument.Visible := False;
    cbDocument.Visible := False;
    lblNotification.Visible := False;
  end else
  begin
    lblDocument.Visible := True;
    cbDocument.Visible := True;

    CreateDocumentTemplateData;
    UpdateDocumentTemplates;
    lblNotification.Visible := True;
  end;

  // Страница справочники
  cbReference.Checked := False;
  cbRemains.Checked := False;
  rgMovementDirection.Visible := False;
  cbControlRemains.Visible := False;
  cbMinusRemains.Visible := False;
  cbLiveTimeRemains.Visible := False;

  rgMovementDirection.ItemIndex := 0;

  // Страница редактирование
  cbDelayedDocument.Checked := False;
  iblcLineTable.Enabled := FIDE <> nil;
  iblcHeaderTable.Enabled := edEnglishName.Text > '';

  ReadOptions;
  UpdateTabs;
  
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGSETUPINVDOCUMENT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGSETUPINVDOCUMENT', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgSetupInvDocument.iblcHeaderTableChange(Sender: TObject);
begin
  inherited;
  UpdateTabs;
end;

function Tgdc_dlgSetupInvDocument.FindFieldInCombo(Box: TComboBox): String;
var
  S, F: Integer;
begin
  if Box.ItemIndex = -1 then
  begin
    Result := '';
    exit;
  end;

  Result := Box.Items[Box.ItemIndex];

  S := LastCharPos('(', Result);
  F := LastCharPos(')', Result);

  if (S = 0) or (F = 0) then
    Result := ''
  else
    Result := Copy(Result, S + 1, F - S - 1);
end;

function Tgdc_dlgSetupInvDocument.GetMinusFeatures: TStringList;
var
  I: Integer;
begin
  if FMinusFeatures = nil then
    FMinusFeatures := TStringList.Create
  else
    FMinusFeatures.Clear;

  for I := 0 to lvMinusUsedFeatures.Items.Count - 1 do
    if lvMinusUsedFeatures.Items[I].Data <> nil then
      FMinusFeatures.Add(TatRelationField(lvMinusUsedFeatures.Items[I].Data).FieldName);

  Result := FMinusFeatures;
end;

procedure Tgdc_dlgSetupInvDocument.Post;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  RGKey: TID;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGSETUPINVDOCUMENT', 'POST', KEYPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGSETUPINVDOCUMENT', KEYPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGSETUPINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGSETUPINVDOCUMENT',
  {M}          'POST', KEYPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGSETUPINVDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Assert(gdcObject.Transaction.InTransaction);

  RGKey := GetTID(gdcObject.FieldByName('reportgroupkey'));
  if not Document.UpdateReportGroup('Складской учет', gdcObject.FieldByName('name').AsString, RGKey, True) then
    raise EgdcInvDocumentType.Create('Report Group Key has not been created!');

  SetTID(gdcObject.FieldByName('reportgroupkey'), RGKey);

  inherited;                      

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGSETUPINVDOCUMENT', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGSETUPINVDOCUMENT', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgSetupInvDocument.AfterPost;
var
  R, RL, CurrR: TatRelation;
  DE: TgdDocumentEntry;
  IE: TgdInvDocumentEntry;
  V: TgdcMCOPredefined;
  RestrictRemainsBy: TStringList;
  S, F: integer;
begin
  inherited;


  Document.InitOpt;

  try
    DE := gdClassList.FindDocByTypeID(gdcObject.ID, dcpHeader, True);
    if DE is TgdInvDocumentEntry then
      IE := DE as TgdInvDocumentEntry
    else
      raise EgdcInvDocumentType.Create('Not an inventory document type');

    R := GetRelation(True);
    RL := GetRelation(False);
    if (R = nil) or (RL = nil) then
      raise EgdcInvDocumentType.Create('Не выбраны таблицы для документа!');

    // Приход

    if IE.GetMCOContactType(emDebit) <> TgdcInvMovementContactType(cbDebitMovement.ItemIndex) then
      Document.UpdateContactTypeOption(TgdcInvMovementContactType(cbDebitMovement.ItemIndex), 'DM');

    if rgDebitFrom.ItemIndex = 0 then
      CurrR := R
    else
      CurrR := RL;

    if (IE.GetMCORelationName(emDebit) <> CurrR.RelationName)
      or (IE.GetMCOSourceFieldName(emDebit) <> FindFieldInCombo(luDebitFrom)) then
    begin
      Document.UpdateRF(CurrR.RelationFields.ByFieldName(FindFieldInCombo(luDebitFrom)), 'DM.SF');
    end;

    if cbUseIncomeSub.Checked then
    begin
      if rgDebitSubFrom.ItemIndex = 0 then
        CurrR := R
      else
        CurrR := RL;

      if (IE.GetMCOSubRelationName(emDebit) <> CurrR.RelationName) or (IE.GetMCOSubSourceFieldName(emDebit) <> FindFieldInCombo(luDebitSubFrom)) then
        Document.UpdateRF(CurrR.RelationFields.ByFieldName(FindFieldInCombo(luDebitSubFrom)), 'DM.SSF');
    end else
      Document.UpdateRF(nil, 'DM.SSF');

    IE.GetMCOPredefined(emDebit, V);

    Document.UpdateContactList(lvDebitMovementValues, 'DM.Predefined', V);

    IE.GetMCOSubPredefined(emDebit, V);

    Document.UpdateContactList(lvSubDebitMovementValues, 'DM.SubPredefined', V);

    // Расход

    if (IE.GetMCOContactType(emCredit) <> TgdcInvMovementContactType(cbCreditMovement.ItemIndex)) then
      Document.UpdateContactTypeOption(TgdcInvMovementContactType(cbCreditMovement.ItemIndex), 'CM');

    if rgCreditFrom.ItemIndex = 0 then
      CurrR := R
    else
      CurrR := RL;

    if (IE.GetMCORelationName(emCredit) <> CurrR.RelationName) or (IE.GetMCOSourceFieldName(emCredit) <> FindFieldInCombo(luCreditFrom)) then
      Document.UpdateRF(CurrR.RelationFields.ByFieldName(FindFieldInCombo(luCreditFrom)), 'CM.SF');

    if cbUseOutlaySub.Checked then
    begin
      if rgCreditSubFrom.ItemIndex = 0 then
        CurrR := R
      else
        CurrR := RL;

      if (IE.GetMCOSubRelationName(emCredit) <> CurrR.RelationName) or (IE.GetMCOSubSourceFieldName(emCredit) <> FindFieldInCombo(luCreditSubFrom)) then
        Document.UpdateRF(CurrR.RelationFields.ByFieldName(FindFieldInCombo(luCreditSubFrom)), 'CM.SSF');
    end else
      Document.UpdateRF(nil, 'CM.SSF');

    IE.GetMCOPredefined(emCredit, V);

    Document.UpdateContactList(lvCreditMovementValues, 'CM.Predefined', V);

    IE.GetMCOSubPredefined(emCredit, V);

    Document.UpdateContactList(lvSubCreditMovementValues, 'CM.SubPredefined', V);

    // Настройки признаков
    Document.UpdateFeatures(ftSource, SourceFeatures);
    Document.UpdateFeatures(ftDest, DestFeatures);

    // Настройка справочников
    Document.UpdateFlag(efSrcGoodRef, cbReference.Checked);
    Document.UpdateFlag(efSrcRemainsRef, cbRemains.Checked);

    RestrictRemainsBy := TStringList.Create();
    try
      if luRestrictBy.ItemIndex <> -1 then
      begin
        S := LastCharPos('(', luRestrictBy.Items[luRestrictBy.ItemIndex]);
        F := LastCharPos(')', luRestrictBy.Items[luRestrictBy.ItemIndex]);
        RestrictRemainsBy.Add(Copy(luRestrictBy.Items[luRestrictBy.ItemIndex], S + 1, F - S - 1));
      end;
      Document.UpdateFeatures(ftRestrRemainsBy, RestrictRemainsBy);
    finally
      RestrictRemainsBy.Free;
    end;

    if IE.GetDirection <> TgdcInvMovementDirection(rgMovementDirection.ItemIndex) then
    begin
      case TgdcInvMovementDirection(rgMovementDirection.ItemIndex) of
        imdFIFO: Document.UpdateFlag(efDirFIFO, True, False);
        imdLIFO: Document.UpdateFlag(efDirLIFO, True, False);
      else
        Document.UpdateFlag(efDirDefault, True, False);
      end;
    end;

    // Только если используются остатки сохраняем текущее значение checkbox-ов
    if cbRemains.Checked then
    begin
      Document.UpdateFlag(efControlRemains, cbControlRemains.Checked);
      Document.UpdateFlag(efLiveTimeRemains, cbLiveTimeRemains.Checked);
      Document.UpdateFlag(efMinusRemains, cbMinusRemains.Checked);
    end else
    begin
      Document.UpdateFlag(efControlRemains, False);
      Document.UpdateFlag(efLiveTimeRemains, False);
      Document.UpdateFlag(efMinusRemains, False);
    end;

    Document.UpdateFlag(efDelayedDocument, cbDelayedDocument.Checked);

    Document.UpdateFeatures(ftMinus, MinusFeatures);

    Document.UpdateFlag(efIsChangeCardValue, cbIsChangeCardValue.Checked);
    Document.UpdateFlag(efIsAppendCardValue, cbIsAppendCardValue.Checked);
    Document.UpdateFlag(efIsUseCompanyKey, cbIsUseCompanyKey.Checked);
    Document.UpdateFlag(efSaveRestWindowOption, cbSaveRestWindowOption.Checked);
    Document.UpdateFlag(efEndMonthRemains, cbEndMonthRemains.Checked);
    if not cbControlRemains.Checked then
      Document.UpdateFlag(efWithoutSearchRemains, cbWithoutSearchRemains.Checked)
    else
      Document.UpdateFlag(efWithoutSearchRemains, False);
  finally
    Document.DoneOpt;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_dlgSetupInvDocument);

finalization
  UnRegisterFrmClass(Tgdc_dlgSetupInvDocument);
end.

