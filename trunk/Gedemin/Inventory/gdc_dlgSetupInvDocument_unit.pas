
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
  xCalculatorEdit, gdcCustomFunction;

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
    procedure cbTemplateClick(Sender: TObject);
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


  private
    FOperationCount: Integer;// Кол-во сложных операций спереподключением
    FMetaChangeCount: Integer; // Кол-во изменений в метаданных

    FSourceFeatures, FDestFeatures, FMinusFeatures: TStringList; // Список признаков
    FTemplates: TObjectList; // Список шаблонов

    //FReportGroupKey: Integer; // Ключ списка отчетов

    function GetDocument: TgdcInvDocumentType;

    function FindFeature(FeatureName: String;
      const FindUsedFeature: Boolean = False;
      const isMinus: Boolean = False): TListItem;

    procedure PrepareDialog;

    procedure UpdateEditingSettings;
    procedure UpdateInsertingSettings;

    procedure UpdateTabs;
    procedure UpdateTemplate;
    procedure UpdateDocumentTemplates;

    procedure SetupMovementTab;
    procedure SetupFeaturesTab;
    procedure SetupMinusFeaturesTab;

    procedure CreateDocumentTemplateData;

    procedure TestCommon;
    procedure TestMovement;
    procedure TestReferences;

    procedure UpdateFeatureList(const isMinus: Boolean = False);
    procedure AddFeature(UsedFeatures, Features: TListView);
    procedure RemoveFeature(UsedFeatures, Features: TListView);

  protected
    procedure ReadOptions(Stream: TStream);
    procedure WriteOptions(Stream: TStream);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetupDialog; override;
    procedure SetupRecord; override;
    function TestCorrect: Boolean; override;

    property Document: TgdcInvDocumentType read GetDocument;

  end;

  EdlgSetupInvDocument = class(Exception);

var
  gdc_dlgSetupInvDocument: Tgdc_dlgSetupInvDocument;

implementation

{$R *.DFM}

uses
  gdcInvConsts_unit,            dmDatabase_unit,        gdcContacts,
  dmImages_unit,                gdc_inv_dlgPredefinedField_unit,
  gdc_inv_dlgViewFieldEvent_unit,                       gd_ClassList,
  gd_strings,                   gd_security
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;


{Находит последнее вхождение символа в строку. Необходимо для поиска "(" и ")",
т.к. эти символы могут быть использованы в локализованном наименовании поля}  
function LastCharPos(Ch: Char; S: String): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := Length(S) downto 1 do
  begin
    if Ch = S[I] then
    begin
      Result := I;
      Break;
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
    ListView := lvDebitMovementValues else
  if Sender = actAddSubDebitContact then
    ListView := lvSubDebitMovementValues else

  if Sender = actAddCreditContact then
    ListView := lvCreditMovementValues else
  if Sender = actAddSubCreditContact then
    ListView := lvSubCreditMovementValues
  else
    Exit;

  if Sender = actAddDebitContact then
  begin
    Combo := cbDebitMovement;
  end else
  if Sender = actAddCreditContact then
  begin
    Combo := cbCreditMovement;
  end else

  if Sender = actAddSubDebitContact then
  begin
    Combo := cbDebitMovement;
  end else
  if Sender = actAddSubCreditContact then
  begin
    Combo := cbCreditMovement;
  end else
    Exit;


  //
  // Осуществляем выбор товаров из справочника
  if (Combo.ItemIndex <> 1) and (Combo.ItemIndex <> 2)  and (Combo.ItemIndex <> 4) then
  begin
    Contact := TgdcBaseContact.Create(nil);
    BaseClassName := 'gdcContacts'
  end
  else
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
        Item.SubItems.Add(IntToStr(Contact.ID));
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
  end else
  if Sender = actAddCreditContact then
  begin
    Combo := cbCreditMovement;
    Check := nil;
  end else

  if Sender = actAddSubDebitContact then
  begin
    Combo := cbDebitMovement;
    Check := cbUseIncomeSub;
  end else
  if Sender = actAddSubCreditContact then
  begin
    Combo := cbCreditMovement;
    Check := cbUseOutlaySub;
  end else
    Exit;

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
      Features.Selected := Features.Items[Index] else
    if Features.Items.Count > 0 then
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
    ListView := lvDebitMovementValues else
  if Sender = actDeleteSubDebitContact then
    ListView := lvSubDebitMovementValues else

  if Sender = actDeleteCreditContact then
    ListView := lvCreditMovementValues else
  if Sender = actDeleteSubCreditContact then
    ListView := lvSubCreditMovementValues
  else
    Exit;

  if ListView.Selected <> nil then
  begin
    I := ListView.Selected.Index;
    ListView.Selected.Delete;

    if I < ListView.Items.Count then
      ListView.Selected := ListView.Items[I] else

    if ListView.Items.Count > 0 then
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
  end else
  if Sender = actDeleteSubDebitContact then
  begin
    ListView := lvSubDebitMovementValues;
    Combo := cbDebitMovement;
    Check := cbUseIncomeSub;
  end else

  if Sender = actDeleteCreditContact then
  begin
    ListView := lvCreditMovementValues;
    Combo := cbCreditMovement;
    Check := nil;
  end else
  if Sender = actDeleteSubCreditContact then
  begin
    ListView := lvSubCreditMovementValues;
    Combo := cbCreditMovement;
    Check := cbUseOutlaySub;
  end else
    Exit;

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

procedure Tgdc_dlgSetupInvDocument.UpdateFeatureList(const isMinus: Boolean = False);
var
  List: TStringList;
  UsedListView: TListView;
  I: Integer;
begin
  if not isMinus then
  begin
    if rgFeatures.ItemIndex = -1 then Exit;

    UsedListView := lvUsedFeatures;

    case TgdcInvFeatureKind(rgFeatures.ItemIndex) of
      ifkDest:
      begin
        List := FDestFeatures;

        if [TgdcInvRelationType(cbTemplate.ItemIndex)] *
          [irtFeatureChange, irtTransformation] = []
        then
          FSourceFeatures.Clear;
      end;
      ifkSource:
      begin
        List := FSourceFeatures;

        if [TgdcInvRelationType(cbTemplate.ItemIndex)] *
          [irtFeatureChange, irtTransformation] = []
        then
          FDestFeatures.Clear;
      end;
    else
      List := nil;
    end;
  end
  else
  begin
    List := FMinusFeatures;
    UsedListView := lvMinusUsedFeatures;
  end;

  if Assigned(List) then
  begin
    List.Clear;

    for I := 0 to UsedListView.Items.Count - 1 do
    with UsedListView.Items[I] do
      List.AddObject(TatRelationField(Data).FieldName, TatRelationField(Data));
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
  end else

  if Sender = cbCreditMovement then
  begin
    Combo := luCreditFrom;
    LabelCombo := lblCreditFrom;
    CheckBox := cbUseOutlaySub;

    SubLabelCombo := lblCreditSubFrom;
  end else
    Exit;

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
    imctOurDepartment:
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
    if not Assigned(R) then Exit;
    Box.Items.Clear;
    for i:= 0 to R.RelationFields.Count - 1 do
      if R.RelationFields[i].IsUserDefined then
          Box.Items.Add(
            R.RelationFields[i].lname + '(' +
            R.RelationFields[i].fieldname + ')'
          );
    i:= Box.Items.IndexOf(sOldText);
    Box.ItemIndex:= i;
  end;

begin
  rg:= nil;
  cmb:= nil;
  if Sender is TComboBox then begin
    cmb:= Sender as TComboBox;
    if Sender = luDebitFrom then
      rg:= rgDebitFrom
    else if Sender = luDebitSubFrom then
      rg:= rgDebitSubFrom
    else if Sender = luCreditFrom then
      rg:= rgCreditFrom
    else if Sender = luCreditSubFrom then
      rg:= rgCreditSubFrom;
  end
  else if Sender is TRadioGroup then begin
    rg:= Sender as TRadioGroup;
    if Sender = rgDebitFrom then
      cmb:= luDebitFrom
    else if Sender = rgDebitSubFrom then
      cmb:= luDebitSubFrom
    else if Sender = rgCreditFrom then
      cmb:= luCreditFrom
    else if Sender = rgCreditSubFrom then
      cmb:= luCreditSubFrom;
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
  end else

  if Sender = cbUseOutlaySub then
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
end;

constructor Tgdc_dlgSetupInvDocument.Create(AOwner: TComponent);
begin
  inherited;

  FOperationCount := 0;
//  FReportGroupKey := -1;
  FMetaChangeCount := 0;

  FTemplates := TObjectList.Create(False);

  FSourceFeatures := TStringList.Create;
  FDestFeatures := TStringList.Create;
  FMinusFeatures := TStringList.Create;

end;

procedure Tgdc_dlgSetupInvDocument.CreateDocumentTemplateData;
var
  R: TatRelation;
  I: Integer;
begin
  FTemplates.Clear;

  for I := 0 to atDatabase.Relations.Count - 1 do
    if (AnsiPos(UserPrefix, atDatabase.Relations[I].RelationName) = 1) then
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

  FSourceFeatures.Free;
  FDestFeatures.Free;
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
      List := lvFeatures
  end
  else
  begin
    if FindUsedFeature then
      List := lvMinusUsedFeatures
    else
      List := lvMinusFeatures
  end;
  
  for I := 0 to List.Items.Count - 1 do
    if AnsiCompareText(TatRelationField(List.Items[I].Data).FieldName, FeatureName) = 0 then
    begin
      Result := List.Items[I];
      Exit;
    end;

  Result := nil;
end;

function Tgdc_dlgSetupInvDocument.GetDocument: TgdcInvDocumentType;
begin
  Result := gdcObject as TgdcInvDocumentType;
end;

procedure Tgdc_dlgSetupInvDocument.PrepareDialog;
var
  I: Integer;
  Item: TListItem;
  Relation: TatRelation;
begin
  if tsCommon.TabVisible then
    pcMain.ActivePage := tsCommon;

  // Общая страница

  edEnglishName.Text := '';
  edEnglishName.MaxLength := 14;

  cbTemplate.ItemIndex := -1;
  cbDocument.ItemIndex := -1;

  { TODO 1 -oденис -cсделать : Нужно вставить загрузку списка складских документов. }

  // Страница признаков

  lvFeatures.Items.Clear;

  Relation := atDatabase.Relations.ByRelationName('INV_CARD');
  Assert(Relation <> nil);

  for I := 0 to Relation.RelationFields.Count - 1 do
  begin
    if not Relation.RelationFields[I].IsUserDefined then
      Continue;

    Item := lvFeatures.Items.Add;

    if Relation.RelationFields[I].LShortName > '' then
      Item.Caption := Relation.RelationFields[I].LShortName
    else
      Item.Caption := Relation.RelationFields[I].FieldName;

    Item.Data := Relation.RelationFields[I];
  end;

  lvUsedFeatures.Items.Clear;

  // Страница движения

  { TODO : тут "текущей" и "нашей" это синонимы? }
  cbDebitMovement.Items.Clear;
  cbDebitMovement.Items.Add('Нашу организацию');
  cbDebitMovement.Items.Add('Подразделение нашей организации');
  cbDebitMovement.Items.Add('Сотрудника нашей организации');
  cbDebitMovement.Items.Add('Клиента');
  cbDebitMovement.Items.Add('Подразделение клиента');
  cbDebitMovement.Items.Add('Сотрудника клиента');
  cbDebitMovement.Items.Add('Физическое лицо');

  cbCreditMovement.Items.Clear;
  cbCreditMovement.Items.Add('Нашу организацию');
  cbCreditMovement.Items.Add('Подразделение нашей организации');
  cbCreditMovement.Items.Add('Сотрудника нашей организации');
  cbCreditMovement.Items.Add('Клиента');
  cbCreditMovement.Items.Add('Подразделение клиента');
  cbCreditMovement.Items.Add('Сотрудника клиента');
  cbCreditMovement.Items.Add('Физическое лицо');

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
  iblcLineTable.Enabled := Document.State <> dsInsert;
  iblcHeaderTable.Enabled := edEnglishName.Text > '';
end;

procedure Tgdc_dlgSetupInvDocument.ReadOptions(Stream: TStream);
var
  Sources: TgdcInvReferenceSources;
  Direction: TgdcInvMovementDirection;
  Movement: TgdcInvMovementContactOption;
  Version, RelationName, RelationLineName: String;
  RKey: Integer;
  I: Integer;
  Item: TListItem;
  ibsql: TIBSQL;
  R: TatRelation;

  F: TatRelationField;

  procedure UpdateComboBox(Box: TComboBox; FieldName: String);
  begin
    Box.Items.Clear;
    Box.Items.Add(FieldName + '(' + FieldName + ')');
    Box.ItemIndex := 0;
  end;

begin
  ibsql := TIBSQL.Create(nil);
  ibsql.SQL.Text := 'SELECT name FROM gd_contact WHERE id = :id';
  ibsql.Database := Document.Database;
  ibsql.Transaction := Document.Transaction;

  Movement := TgdcInvMovementContactOption.Create;
  with TReader.Create(Stream, 1024) do
  try
    // Общие настройки
    Version := ReadString;

    // Наименования таблиц
    RelationName := ReadString;
    RelationLineName := ReadString;

    if Document.FieldByName('headerrelkey').IsNull then
    begin
      R := atDatabase.Relations.ByRelationName(RelationName);
      if Assigned(R) then
      begin
        if not (Document.State in [dsEdit, dsInsert]) then
          Document.Edit;
        Document.FieldByName('headerrelkey').AsInteger := R.ID;
      end;

    end;

    if Document.FieldByName('linerelkey').IsNull then
    begin
      R := atDatabase.Relations.ByRelationName(RelationLineName);
      if Assigned(R) then
      begin
        if not (Document.State in [dsEdit, dsInsert]) then
          Document.Edit;
        Document.FieldByName('linerelkey').AsInteger := R.ID;
      end;

    end;

    edEnglishName.Text := RelationName;

    if (Version <> gdcInvDocument_Version2_0) and (Version <> gdcInvDocument_Version2_1) and
       (Version <> gdcInvDocument_Version2_2) and (Version <> gdcInvDocument_Version2_3)
    then
    // Тип документа считываем
      ReadInteger;

    // Ключ записи из сиска отчетов
    if (Version = gdcInvDocument_Version2_2) or
      (Version = gdcInvDocument_Version2_3) or
      (Version = gdcInvDocument_Version2_1) or
      (Version = gdcInvDocument_Version2_0) or
      (Version = gdcInvDocument_Version1_9) then
    begin
      RKey := ReadInteger;
      if (RKey > 0) and gdcObject.FieldByName('reportgroupkey').IsNull then
      begin
        if not (gdcObject.State in [dsEdit, dsInsert]) then gdcObject.Edit;
        gdcObject.FieldByName('reportgroupkey').AsInteger := RKey;
      end;
    end;


    UpdateEditingSettings;


    // Приход
    SetLength(Movement.Predefined, 0);
    SetLength(Movement.SubPredefined, 0);

    Movement.RelationName := ReadString;
    Movement.SourceFieldName := ReadString;
    Movement.SubRelationName := ReadString;
    Movement.SubSourceFieldName := ReadString;

    Read(Movement.ContactType, SizeOf(TgdcInvMovementContactType));

    ReadListBegin;
    while not EndOfList do
    begin
      SetLength(Movement.Predefined,
        Length(Movement.Predefined) + 1);
      Movement.Predefined[Length(Movement.Predefined) - 1] :=
        ReadInteger;
    end;
    ReadListEnd;

    ReadListBegin;
    while not EndOfList do
    begin
      SetLength(Movement.SubPredefined,
        Length(Movement.SubPredefined) + 1);
      Movement.SubPredefined[Length(Movement.SubPredefined) - 1] :=
        ReadInteger;
    end;
    ReadListEnd;

    cbDebitMovement.ItemIndex := Integer(Movement.ContactType);
    if AnsiCompareText(Movement.RelationName, RelationName) = 0 then
      rgDebitFrom.ItemIndex := 0
    else
      rgDebitFrom.ItemIndex := 1;

    if cbUseIncomeSub.Checked then
    begin
      if AnsiCompareText(Movement.SubRelationName, RelationName) = 0 then
        rgDebitSubFrom.ItemIndex := 0
      else
        rgDebitSubFrom.ItemIndex := 1;
    end;

    UpdateComboBox(luDebitFrom, Movement.SourceFieldName);
    UpdateComboBox(luDebitSubFrom, Movement.SubSourceFieldName);

    for I := 0 to Length(Movement.Predefined) - 1 do
    begin
      ibsql.Close;
      ibsql.ParamByName('ID').AsInteger := Movement.Predefined[I];
      ibsql.ExecQuery;
      Item := lvDebitMovementValues.Items.Add;
      Item.Caption := ibsql.FieldByName('NAME').AsString;
      Item.SubItems.Add(IntToStr(Movement.Predefined[I]));
      ibsql.Close;
    end;

    for I := 0 to Length(Movement.SubPredefined) - 1 do
    begin
      ibsql.Close;
      ibsql.ParamByName('ID').AsInteger := Movement.SubPredefined[I];
      ibsql.ExecQuery;
      Item := lvSubDebitMovementValues.Items.Add;
      Item.Caption := ibsql.FieldByName('NAME').AsString;
      Item.SubItems.Add(IntToStr(Movement.SubPredefined[I]));
      ibsql.Close;
    end;

    cbDebitMovementChange(cbDebitMovement);
    if cbUseIncomeSub.Visible then
      cbUseIncomeSub.Checked :=
        (Movement.SubRelationName > '') and (Movement.SubSourceFieldName > '');

    cbUseIncomeSubClick(cbUseIncomeSub);


    // Расход
    SetLength(Movement.Predefined, 0);
    SetLength(Movement.SubPredefined, 0);

    Movement.RelationName := ReadString;
    Movement.SourceFieldName := ReadString;

    Movement.SubRelationName := ReadString;
    Movement.SubSourceFieldName := ReadString;

    Read(Movement.ContactType, SizeOf(TgdcInvMovementContactType));

    ReadListBegin;
    while not EndOfList do
    begin
      SetLength(Movement.Predefined,
        Length(Movement.Predefined) + 1);
      Movement.Predefined[Length(Movement.Predefined) - 1] :=
        ReadInteger;
    end;
    ReadListEnd;

    ReadListBegin;
    while not EndOfList do
    begin
      SetLength(Movement.SubPredefined,
        Length(Movement.SubPredefined) + 1);
      Movement.SubPredefined[Length(Movement.SubPredefined) - 1] :=
        ReadInteger;
    end;
    ReadListEnd;

    cbCreditMovement.ItemIndex := Integer(Movement.ContactType);
    if AnsiCompareText(Movement.RelationName, RelationName) = 0 then
      rgCreditFrom.ItemIndex := 0
    else
      rgCreditFrom.ItemIndex := 1;

    if cbUseOutlaySub.Checked then
    begin
      if AnsiCompareText(Movement.SubRelationName, RelationName) = 0 then
        rgCreditSubFrom.ItemIndex := 0
      else
        rgCreditSubFrom.ItemIndex := 1;
    end;

    UpdateComboBox(luCreditFrom, Movement.SourceFieldName);
    UpdateComboBox(luCreditSubFrom, Movement.SubSourceFieldName);

    for I := 0 to Length(Movement.Predefined) - 1 do
    begin
      ibsql.Close;
      ibsql.ParamByName('ID').AsInteger := Movement.Predefined[I];
      ibsql.ExecQuery;
      Item := lvCreditMovementValues.Items.Add;
      Item.Caption := ibsql.FieldByName('NAME').AsString;
      Item.SubItems.Add(IntToStr(Movement.Predefined[I]));
      ibsql.Close;
    end;

    for I := 0 to Length(Movement.SubPredefined) - 1 do
    begin
      ibsql.Close;
      ibsql.ParamByName('ID').AsInteger := Movement.SubPredefined[I];
      ibsql.ExecQuery;
      Item := lvSubCreditMovementValues.Items.Add;
      Item.Caption := ibsql.FieldByName('NAME').AsString;
      Item.SubItems.Add(IntToStr(Movement.SubPredefined[I]));
      ibsql.Close;
    end;

    cbDebitMovementChange(cbCreditMovement);
    if cbUseOutlaySub.Visible then
      cbUseOutlaySub.Checked :=
        (Movement.SubRelationName > '') and (Movement.SubSourceFieldName > '');

    cbUseIncomeSubClick(cbUseIncomeSub);


    // Настройки признаков
    ReadListBegin;
    while not EndOfList do
    begin
      F := atDatabase.FindRelationField('INV_CARD', ReadString);
      if not Assigned(F) then Continue;
      FSourceFeatures.AddObject(F.FieldName, F);
    end;
    ReadListEnd;

    ReadListBegin;
    while not EndOfList do
    begin
      F := atDatabase.FindRelationField('INV_CARD', ReadString);
      if not Assigned(F) then Continue;
      FDestFeatures.AddObject(F.FieldName, F);
    end;
    ReadListEnd;

    SetupFeaturesTab;

    // Настройка справочников
    Read(Sources, SizeOf(TgdcInvReferenceSources));

    cbReference.Checked := irsGoodRef in Sources;
    cbRemains.Checked := irsRemainsRef in Sources;
//  cbFromMacro.Checked := irsMacro in Sources;

    // Настройка FIFO, LIFO
    Read(Direction, SizeOf(TgdcInvMovementDirection));
    rgMovementDirection.ItemIndex := Integer(Direction);

    // Конроль остатков
    cbControlRemains.Checked := ReadBoolean;

    // работа только с текущими остатками
    if (Version = gdcInvDocument_Version1_9) or
      (Version = gdcInvDocument_Version2_0) or
      (Version = gdcInvDocument_Version2_1) or
      (Version = gdcInvDocument_Version2_2) or
      (Version = gdcInvDocument_Version2_3) or
      (Version = gdcInvDocument_Version2_4) or
      (Version = gdcInvDocument_Version2_5)  then
      cbLiveTimeRemains.Checked := ReadBoolean
    else
      cbLiveTimeRemains.Checked := False;

    if not cbRemains.Checked then
    begin
      // Конроль остатков
      cbControlRemains.Checked := False;

      // работа только с текущими остатками
      cbLiveTimeRemains.Checked := False;
    end;

    // Документ может быть отложенным
    cbDelayedDocument.Checked := ReadBoolean;
    // Может использоваться кэширование
    ReadBoolean;

    if (Version = gdcInvDocument_Version2_1) or (Version = gdcInvDocument_Version2_2)
       or (Version = gdcInvDocument_Version2_3) or (Version = gdcInvDocument_Version2_4)
       or (Version = gdcInvDocument_Version2_5)
    then
      cbMinusRemains.Checked := ReadBoolean
    else
      cbMinusRemains.Checked := False;

    gbMinusFeatures.Visible := cbMinusRemains.Checked;

    if not cbRemains.Checked then
      cbMinusRemains.Checked := False;

    if (Version = gdcInvDocument_Version2_2) or (Version = gdcInvDocument_Version2_3)
       or (Version = gdcInvDocument_Version2_4) or (Version = gdcInvDocument_Version2_5)
    then
    begin
      ReadListBegin;
      while not EndOfList do
      begin
        F := atDatabase.FindRelationField('INV_CARD', ReadString);
        if not Assigned(F) then Continue;
        FMinusFeatures.AddObject(F.FieldName, F);
      end;
      ReadListEnd;

      SetupMinusFeaturesTab;
    end;

    if (Version = gdcInvDocument_Version2_3) or (Version = gdcInvDocument_Version2_4) or
       (Version = gdcInvDocument_Version2_5) then
    begin
      cbIsChangeCardValue.Checked := ReadBoolean;
      cbIsAppendCardValue.Checked := ReadBoolean;
    end;
    if (Version = gdcInvDocument_Version2_4) or (Version = gdcInvDocument_Version2_5) then
      cbIsUseCompanyKey.Checked := ReadBoolean
    else
      cbIsUseCompanyKey.Checked := True;

    if (Version = gdcInvDocument_Version2_5) then
      cbSaveRestWindowOption.Checked := ReadBoolean
    else
      cbSaveRestWindowOption.Checked := False;

  finally
    Free;
    ibsql.Free;
    Movement.Free; 
  end;
end;

procedure Tgdc_dlgSetupInvDocument.SetupFeaturesTab;
var
  List: TStringList;
  I: Integer;
  Item, UsedItem: TListItem;
  R: TatRelation;
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

  if rgFeatures.ItemIndex = -1 then Exit;

  case TgdcInvFeatureKind(rgFeatures.ItemIndex) of
    ifkDest: List := FDestFeatures;
    ifkSource: List := FSourceFeatures;
  else
    List := nil;
  end;

  if not Assigned(List) then
    exit;

  R := atDatabase.Relations.ByRelationName('INV_CARD');
  Assert(Assigned(R));

  with R do
    for I := 0 to RelationFields.Count - 1 do
    begin
      if not RelationFields[I].IsUserDefined then Continue;
      Item := lvFeatures.Items.Add;
      Item.Caption := RelationFields[I].LName;
      Item.Data := RelationFields[I];
    end;

  for I := 0 to List.Count - 1 do
  begin
    Item := FindFeature(List[I]);
    if not Assigned(Item) then Continue;

    UsedItem := lvUsedFeatures.Items.Add;
    UsedItem.Caption := Item.Caption;
    UsedItem.Data := Item.Data;
    Item.Delete;
  end;
end;

procedure Tgdc_dlgSetupInvDocument.SetupMovementTab;
  procedure UpdateComboBox(R: TatRelation; Box: TComboBox);
  var
    I: Integer;
    ChosenField: String;
    S, F: Integer;
  begin
    if Box.ItemIndex <> -1 then
    begin
      S := LastCharPos('(', Box.Items[Box.ItemIndex]);
      F := LastCharPos(')', Box.Items[Box.ItemIndex]);
      ChosenField := Copy(Box.Items[Box.ItemIndex], S + 1, F - S - 1);
    end else
      ChosenField := '';

    Box.Items.Clear;

    if Assigned(R) then
    begin
      for i:= 0 to R.RelationFields.Count - 1 do
        if R.RelationFields[i].IsUserDefined then
          Box.Items.Add(
            R.RelationFields[i].lname + '(' +
              R.RelationFields[i].fieldname + ')'
          );
    end;

    if ChosenField > '' then
      for I := 0 to Box.Items.Count - 1 do
        if AnsiPos('(' + ChosenField + ')', Box.Items[I]) > 0 then
        begin
          Box.ItemIndex := I;
          Break;
        end;
  end;

begin
  if pcMain.ActivePage = tsIncomeMovement then
  begin
    if rgDebitFrom.ItemIndex = 0 then
      UpdateComboBox(GetRelation(True), luDebitFrom) else
    if rgDebitFrom.ItemIndex = 1 then
      UpdateComboBox(GetRelation(False), luDebitFrom);

    if rgDebitSubFrom.ItemIndex = 0 then
      UpdateComboBox(GetRelation(True), luDebitSubFrom) else
    if rgDebitSubFrom.ItemIndex = 1 then
      UpdateComboBox(GetRelation(False), luDebitSubFrom);

    cbDebitMovementChange(cbDebitMovement);
  end else

  if pcMain.ActivePage = tsOutlayMovement then
  begin
    if rgCreditFrom.ItemIndex = 0 then
      UpdateComboBox(GetRelation(True), luCreditFrom) else
    if rgCreditFrom.ItemIndex = 1 then
      UpdateComboBox(GetRelation(False), luCreditFrom);

    if rgCreditSubFrom.ItemIndex = 0 then
      UpdateComboBox(GetRelation(True), luCreditSubFrom) else
    if rgCreditSubFrom.ItemIndex = 1 then
      UpdateComboBox(GetRelation(False), luCreditSubFrom);

    cbDebitMovementChange(cbCreditMovement);
  end;
end;

procedure Tgdc_dlgSetupInvDocument.TestCommon;
begin
//Выполняется отдельно (не через общий механизм) потому как важен порядок проверки
//и потому что контрол может быть Disabled
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

end;

function Tgdc_dlgSetupInvDocument.TestCorrect: Boolean;
var
  Stream: TStringStream;
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
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

  UpdateTabs;
  TestCommon;

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
    raise EdlgSetupInvDocument.Create('Укажите, как оформлять приход!');
  end;

  if rgDebitFrom.ItemIndex = -1 then
  begin
    pcMain.ActivePage := tsIncomeMovement;
    rgDebitFrom.SetFocus;
    raise EdlgSetupInvDocument.Create('Укажите, откуда брать приход!');
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
    raise EdlgSetupInvDocument.Create('Укажите, как оформлять расход!');
  end;

  if rgCreditFrom.ItemIndex = -1 then
  begin
    pcMain.ActivePage := tsOutlayMovement;
    rgCreditFrom.SetFocus;
    raise EdlgSetupInvDocument.Create('Укажите, откуда брать расход!');
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
      raise EdlgSetupInvDocument.Create('Укажите, откуда брать ограничение расхода!');
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

  { TODO 1 -oденис -cмакро : Сделать проверку на макрос }
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

procedure Tgdc_dlgSetupInvDocument.UpdateEditingSettings;
var
  R: TatRelation;
  RelType: TgdcInvRelationType;
begin
  cbTemplate.Enabled := False;

  R := atDatabase.Relations.ByID(Document.FieldByName('linerelkey').AsInteger);
  if Assigned(R) then
  begin
    RelType := RelationTypeByRelation(R);
    if RelType <> irtInvalid then
      cbTemplate.ItemIndex := Integer(RelType)
    else
      cbTemplate.ItemIndex := -1;
  end else
    cbTemplate.ItemIndex := -1;

  lblDocument.Visible := False;
  cbDocument.Visible := False;

end;

procedure Tgdc_dlgSetupInvDocument.UpdateInsertingSettings;

begin
  tsFeatures.TabVisible := False;
  tsIncomeMovement.TabVisible := False;
  tsOutlayMovement.TabVisible := False;
  tsReferences.TabVisible := False;
//  tsEditing.TabVisible := False;
  pcMain.ActivePage := tsCommon;

  CreateDocumentTemplateData;
  UpdateDocumentTemplates;
end;

procedure Tgdc_dlgSetupInvDocument.UpdateTabs;
var
  R: TatRelation;
  RelType: TgdcInvRelationType;
begin
  if (Document.State = dsEdit) and (cbTemplate.ItemIndex = -1) and
    (edEnglishName.Text > '') then
  begin
    R := atDatabase.Relations.ByID(Document.FieldByName('linerelkey').AsInteger);

    if Assigned(R) then
    begin
      RelType := RelationTypeByRelation(R);
      if RelType <> irtInvalid then
        cbTemplate.ItemIndex := Integer(RelType)
      else
        cbTemplate.ItemIndex := -1;
    end else
      cbTemplate.ItemIndex := -1;
  end;

  iblcHeaderTable.Enabled := edEnglishName.Text > '';

  iblcLineTable.Enabled := iblcLineTable.ItemIndex >= 0;

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
    IBLogin.IsUserAdmin;

  tsIncomeMovement.TabVisible := tsFeatures.TabVisible;
  tsOutlayMovement.TabVisible := tsFeatures.TabVisible;
  tsReferences.TabVisible := tsFeatures.TabVisible;
end;

procedure Tgdc_dlgSetupInvDocument.UpdateTemplate;
var
  R, RL: TatRelation;

begin
  Assert(Assigned(Document));

  //
  // По изменению шаблона таблицы осуществляем изменение ее структуры.
  // Очищаем таблицу от полей ранее выбранного шаблона

  //
  // Верняя таблица

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
    Document.FieldByName('headerrelkey').AsInteger := R.ID;

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
    Document.FieldByName('linerelkey').AsInteger := RL.ID;

end;

procedure Tgdc_dlgSetupInvDocument.WriteOptions(Stream: TStream);
var
  Sources: TgdcInvReferenceSources;
  Direction: TgdcInvMovementDirection;
  Movement: TgdcInvMovementContactOption;
  R, RL: TatRelation;

  I: Integer;

  function FindFieldInCombo(Box: TComboBox): String;
  var
    S, F: Integer;
  begin
    if Box.ItemIndex = -1 then
      Result := ''
    else
      Result := Box.Items[Box.ItemIndex];

    S := LastCharPos('(', Result);
    F := LastCharPos(')', Result);

    if (Result = '') or (S = 0) or (F = 0) then
    begin
      Result := '';
      Exit;
    end;

    Result := Copy(Result, S + 1, F - S - 1);
  end;

  var
    rpgroupkey: Integer;
begin
  rpgroupkey := Document.FieldByName('reportgroupkey').AsInteger;

  with TWriter.Create(Stream, 1024) do
  try
    // Общие настройки
    WriteString(gdcInvDocument_Version2_5);

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

    Document.FieldByName('reportgroupkey').AsInteger := rpgroupkey;

    // Ключ записи в списке отчетов
    WriteInteger(rpgroupkey);

    // Приход

    Movement := TgdcInvMovementContactOption.Create;
    Movement.ContactType := TgdcInvMovementContactType(cbDebitMovement.ItemIndex);
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
        WriteInteger(StrToInt(lvDebitMovementValues.Items[I].SubItems[0]));
    WriteListEnd;

    WriteListBegin;
      if cbUseIncomeSub.Checked then
        for I := 0 to lvSubDebitMovementValues.Items.Count - 1 do
          WriteInteger(StrToInt(lvSubDebitMovementValues.Items[I].SubItems[0]));
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
        WriteInteger(StrToInt(lvCreditMovementValues.Items[I].SubItems[0]));
    WriteListEnd;

    WriteListBegin;
      if cbUseOutlaySub.Checked then
        for I := 0 to lvSubCreditMovementValues.Items.Count - 1 do
          WriteInteger(StrToInt(lvSubCreditMovementValues.Items[I].SubItems[0]));
    WriteListEnd;

    // Настройки признаков
    WriteListBegin;

    for I := 0 to FSourceFeatures.Count - 1 do
      WriteString(FSourceFeatures[I]);

    WriteListEnd;

    WriteListBegin;

    for I := 0 to FDestFeatures.Count - 1 do
      WriteString(FDestFeatures[I]);

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

    //
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

    for I := 0 to FMinusFeatures.Count - 1 do
      WriteString(FMinusFeatures[I]);

    WriteListEnd;

    WriteBoolean(cbIsChangeCardValue.Checked);
    WriteBoolean(cbIsAppendCardValue.Checked);
    WriteBoolean(cbIsUseCompanyKey.Checked);
    WriteBoolean(cbSaveRestWindowOption.Checked);

  finally
    Free;
  end;
end;

procedure Tgdc_dlgSetupInvDocument.cbTemplateClick(Sender: TObject);
begin
  cbDocument.ItemIndex := 0;

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
    Exit;
  end;

  edEnglishName.Text := TatRelation(cbDocument.Items.Objects[cbDocument.ItemIndex]).RelationName;

  RL := atDatabase.Relations.ByRelationName(
    TatRelation(cbDocument.Items.Objects[cbDocument.ItemIndex]).RelationName + 'LINE');

  if not Assigned(RL) then
  begin
    cbTemplate.ItemIndex := -1;
    Exit;
  end;

  RelType := RelationTypeByRelation(RL);
  if RelType <> irtInvalid then
    cbTemplate.ItemIndex := Integer(RelType)
  else
    cbTemplate.ItemIndex := -1;

  Document.FieldByName('headerrelkey').AsInteger :=
    TatRelation(cbDocument.Items.Objects[cbDocument.ItemIndex]).ID;
  Document.FieldByName('linerelkey').AsInteger := RL.ID;  

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
  begin
    if (AnsiPos(UserPrefix, edEnglishName.Text) = 0) and
      (atDatabase.Relations.ByRelationName(edEnglishName.Text) = nil)
    then
      edEnglishName.Text := UserPrefix + edEnglishName.Text;


    UpdateTemplate;
  end;
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
end;

procedure Tgdc_dlgSetupInvDocument.cbMinusRemainsClick(Sender: TObject);
begin
  gbMinusFeatures.Visible := cbMinusRemains.Checked;
  if cbMinusRemains.Checked then
    SetupMinusFeaturesTab;
end;

procedure Tgdc_dlgSetupInvDocument.SetupMinusFeaturesTab;
var
  List: TStringList;
  I: Integer;
  Item, UsedItem: TListItem;
  R: TatRelation;
  RF: TatRelationField;
begin
  lvMinusFeatures.Items.Clear;
  lvMinusUsedFeatures.Items.Clear;

  List := FMinusFeatures;

  if not Assigned(List) then
    exit;

  R := atDatabase.Relations.ByRelationName('INV_CARD');
  Assert(Assigned(R));

{  with R do
    for I := 0 to RelationFields.Count - 1 do
    begin
      if not RelationFields[I].IsUserDefined then Continue;
      Item := lvMinusFeatures.Items.Add;
      Item.Caption := RelationFields[I].LName;
      Item.Data := RelationFields[I];
    end;}
  for I := 0 to FDestFeatures.Count - 1 do
  begin
    RF := R.RelationFields.ByFieldName(FDestFeatures[I]);
    if Assigned(RF) then
    begin
      Item := lvMinusFeatures.Items.Add;
      Item.Caption := RF.LName;
      Item.Data := RF;
    end;
  end;

  for I := 0 to List.Count - 1 do
  begin
    Item := FindFeature(List[I], False, True);
    if not Assigned(Item) then Continue;

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
  UpdateFeatureList(True);
end;

procedure Tgdc_dlgSetupInvDocument.actRemove_MinusFeatureExecute(
  Sender: TObject);
begin
  RemoveFeature(lvMinusUsedFeatures, lvMinusFeatures);
  UpdateFeatureList(True);
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

  UpdateFeatureList(True);
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

  UpdateFeatureList(True);
end;

procedure Tgdc_dlgSetupInvDocument.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
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

  PrepareDialog;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGSETUPINVDOCUMENT', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGSETUPINVDOCUMENT', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgSetupInvDocument.SetupRecord;
var
  Stream: TStringStream;
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
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
  if Document.State = dsEdit then
  begin
    if not Document.FieldByName('OPTIONS').IsNull then
    begin
      Stream := TStringStream.Create(Document.FieldByName('OPTIONS').AsString);
      try
        ReadOptions(Stream);
      finally
        Stream.Free;
      end;
      UpdateTabs;
    end else
      UpdateEditingSettings;
  end else

  if Document.State = dsInsert then
  begin
    UpdateInsertingSettings;
  end;


  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGSETUPINVDOCUMENT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGSETUPINVDOCUMENT', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgSetupInvDocument);

finalization
  UnRegisterFrmClass(Tgdc_dlgSetupInvDocument);

end.

