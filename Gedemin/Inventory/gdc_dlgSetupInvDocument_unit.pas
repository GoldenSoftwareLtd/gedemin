
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
    cbEndMonthRemains: TCheckBox;
    cbWithoutSearchRemains: TCheckBox;
    lblNotification: TLabel;

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
    procedure cbTemplateChange(Sender: TObject);
    procedure iblcHeaderTableChange(Sender: TObject);


  private
    FOperationCount: Integer;// ���-�� ������� �������� �����������������
    FMetaChangeCount: Integer; // ���-�� ��������� � ����������

    FTemplates: TObjectList; // ������ ��������

    //FReportGroupKey: Integer; // ���� ������ �������

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
    procedure ReadOptions;
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


{������� ��������� ��������� ������� � ������. ���������� ��� ������ "(" � ")",
�.�. ��� ������� ����� ���� ������������ � �������������� ������������ ����}  
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
  // ������������ ����� ������� �� �����������
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
        List := Document.DestFeatures;

        if [TgdcInvRelationType(cbTemplate.ItemIndex)] *
          [irtFeatureChange, irtTransformation] = []
        then
          Document.SourceFeatures.Clear;
      end;
      ifkSource:
      begin
        List := Document.SourceFeatures;

        if [TgdcInvRelationType(cbTemplate.ItemIndex)] *
          [irtFeatureChange, irtTransformation] = []
        then
          Document.DestFeatures.Clear;
      end;
    else
      List := nil;
    end;
  end
  else
  begin
    List := Document.MinusFeatures;
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
      LabelCombo.Caption := '���� ����� ��������:';
      Combo.Visible := True;

      SubLabelCombo.Caption := '����������� ����������:';

      CheckBox.Checked := False;
      CheckBox.Visible := False;

      cbUseIncomeSubClick(CheckBox);
    end;
    imctOurDepartment, imctOurDepartAndPeople:
    begin
      LabelCombo.Caption := '���� ������������� ����� ��������:';
      Combo.Visible := True;

      SubLabelCombo.Caption := '���� ������������� ����� ��������:';

      CheckBox.Visible := True;
      cbUseIncomeSubClick(CheckBox);
    end;
    imctOurPeople:
    begin
      LabelCombo.Caption := '���� ���������� ����� ��������:';
      Combo.Visible := True;

      SubLabelCombo.Caption := '���� ������������� ����� ��������:';

      CheckBox.Visible := True;
      cbUseIncomeSubClick(CheckBox);
    end;
    imctCompany:
    begin
      LabelCombo.Caption := '���� �������:';
      Combo.Visible := True;

      SubLabelCombo.Caption := '����������� ����������';

      CheckBox.Checked := False;
      CheckBox.Visible := False;

      cbUseIncomeSubClick(CheckBox);
    end;
    imctCompanyDepartment:
    begin
      LabelCombo.Caption := '���� ������������� �������:';
      Combo.Visible := True;

      SubLabelCombo.Caption := '���� �������:';

      CheckBox.Visible := False;
      CheckBox.Checked := True;
      cbUseIncomeSubClick(CheckBox);
    end;
    imctCompanyPeople:
    begin
      LabelCombo.Caption := '���� ���������� �������:';
      Combo.Visible := True;

      SubLabelCombo.Caption := '���� �������:';

      CheckBox.Visible := False;
      CheckBox.Checked := True;
      cbUseIncomeSubClick(CheckBox);
    end;
    imctPeople:
    begin
      LabelCombo.Caption := '���� ����������� ����:';
      Combo.Visible := True;

      SubLabelCombo.Caption := '����������� ����������';

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
      0: UpdateBox(cmb, GetRootRelation(True));
      1: UpdateBox(cmb, GetRootRelation(False));
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
  cbWithoutSearchRemains.Visible := not cbControlRemains.Checked and (cbTemplate.ItemIndex = 1);
end;

constructor Tgdc_dlgSetupInvDocument.Create(AOwner: TComponent);
begin
  inherited;

  FOperationCount := 0;
  FMetaChangeCount := 0;

  FTemplates := TObjectList.Create(False);

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

  // ����� ��������

  edEnglishName.Text := '';
  edEnglishName.MaxLength := 14;

  cbTemplate.ItemIndex := -1;
  cbDocument.ItemIndex := -1;

  { TODO 1 -o����� -c������� : ����� �������� �������� ������ ��������� ����������. }

  // �������� ���������

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

  // �������� ��������

  { TODO : ��� "�������" � "�����" ��� ��������? }
  cbDebitMovement.Items.Clear;
  cbDebitMovement.Items.Add('���� �����������');
  cbDebitMovement.Items.Add('������������� ����� �����������');
  cbDebitMovement.Items.Add('���������� ����� �����������');
  cbDebitMovement.Items.Add('�������');
  cbDebitMovement.Items.Add('������������� �������');
  cbDebitMovement.Items.Add('���������� �������');
  cbDebitMovement.Items.Add('���������� ����');
  cbDebitMovement.Items.Add('������������� ��� ���������� ����� �����������');

  cbCreditMovement.Items.Clear;
  cbCreditMovement.Items.Add('���� �����������');
  cbCreditMovement.Items.Add('������������� ����� �����������');
  cbCreditMovement.Items.Add('���������� ����� �����������');
  cbCreditMovement.Items.Add('�������');
  cbCreditMovement.Items.Add('������������� �������');
  cbCreditMovement.Items.Add('���������� �������');
  cbCreditMovement.Items.Add('���������� ����');
  cbCreditMovement.Items.Add('������������� ��� ���������� ����� �����������');


  // �������� �����������
  cbReference.Checked := False;
  cbRemains.Checked := False;
  rgMovementDirection.Visible := False;
  cbControlRemains.Visible := False;
  cbMinusRemains.Visible := False;
  cbLiveTimeRemains.Visible := False;

  rgMovementDirection.ItemIndex := 0;

  // �������� ��������������
  cbDelayedDocument.Checked := False;
  iblcLineTable.Enabled := Document.State <> dsInsert;
  iblcHeaderTable.Enabled := edEnglishName.Text > '';
end;

procedure Tgdc_dlgSetupInvDocument.ReadOptions;
var
{  Sources: TgdcInvReferenceSources;
  Direction: TgdcInvMovementDirection;
  Movement: TgdcInvMovementContactOption;
  Version, RelationName, RelationLineName: String;}
  I: Integer;
  Item: TListItem;
  ibsql: TIBSQL;

  procedure UpdateComboBox(Box: TComboBox; FieldName: String);
  begin
    Box.Items.Clear;
    Box.Items.Add(FieldName + '(' + FieldName + ')');
    Box.ItemIndex := 0;
  end;

begin
  ibsql := TIBSQL.Create(nil);
  ibsql.SQL.Text := 'SELECT name FROM gd_contact WHERE id = :id';
  ibsql.Transaction := Document.Transaction;

 { Movement := TgdcInvMovementContactOption.Create;
  with TReader.Create(Stream, 1024) do}
  try
    // ����� ���������
{    Version := ReadString;

    // ������������ ������
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

    end; }

    edEnglishName.Text := Document.RelationName;

{    if (Version <> gdcInvDocument_Version2_0) and (Version <> gdcInvDocument_Version2_1) and
       (Version <> gdcInvDocument_Version2_2) and (Version <> gdcInvDocument_Version2_3)
    then
    // ��� ��������� ���������
      ReadInteger;

    // ���� ������ �� ����� �������
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
 }

    UpdateEditingSettings;


    // ������
{
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
 }
    cbDebitMovement.ItemIndex := Integer(Document.DebitMovement.ContactType);
    if AnsiCompareText(Document.DebitMovement.RelationName, Document.RelationName) = 0 then
      rgDebitFrom.ItemIndex := 0
    else
      rgDebitFrom.ItemIndex := 1;

    if cbUseIncomeSub.Checked then
    begin
      if AnsiCompareText(Document.DebitMovement.SubRelationName, Document.RelationName) = 0 then
        rgDebitSubFrom.ItemIndex := 0
      else
        rgDebitSubFrom.ItemIndex := 1;
    end;

    UpdateComboBox(luDebitFrom, Document.DebitMovement.SourceFieldName);
    UpdateComboBox(luDebitSubFrom, Document.DebitMovement.SubSourceFieldName);

    for I := 0 to Length(Document.DebitMovement.Predefined) - 1 do
    begin
      ibsql.Close;
      ibsql.ParamByName('ID').AsInteger := Document.DebitMovement.Predefined[I];
      ibsql.ExecQuery;
      Item := lvDebitMovementValues.Items.Add;
      Item.Caption := ibsql.FieldByName('NAME').AsString;
      Item.SubItems.Add(IntToStr(Document.DebitMovement.Predefined[I]));
      ibsql.Close;
    end;

    for I := 0 to Length(Document.DebitMovement.SubPredefined) - 1 do
    begin
      ibsql.Close;
      ibsql.ParamByName('ID').AsInteger := Document.DebitMovement.SubPredefined[I];
      ibsql.ExecQuery;
      Item := lvSubDebitMovementValues.Items.Add;
      Item.Caption := ibsql.FieldByName('NAME').AsString;
      Item.SubItems.Add(IntToStr(Document.DebitMovement.SubPredefined[I]));
      ibsql.Close;
    end;

    cbDebitMovementChange(cbDebitMovement);
    if cbUseIncomeSub.Visible then
      cbUseIncomeSub.Checked :=
        (Document.DebitMovement.SubRelationName > '') and (Document.DebitMovement.SubSourceFieldName > '');

    cbUseIncomeSubClick(cbUseIncomeSub);


    // ������
    cbCreditMovement.ItemIndex := Integer(Document.CreditMovement.ContactType);
    if AnsiCompareText(Document.CreditMovement.RelationName, Document.RelationName) = 0 then
      rgCreditFrom.ItemIndex := 0
    else
      rgCreditFrom.ItemIndex := 1;

    if cbUseOutlaySub.Checked then
    begin
      if AnsiCompareText(Document.CreditMovement.SubRelationName, Document.RelationName) = 0 then
        rgCreditSubFrom.ItemIndex := 0
      else
        rgCreditSubFrom.ItemIndex := 1;
    end;

    UpdateComboBox(luCreditFrom, Document.CreditMovement.SourceFieldName);
    UpdateComboBox(luCreditSubFrom, Document.CreditMovement.SubSourceFieldName);

    for I := 0 to Length(Document.CreditMovement.Predefined) - 1 do
    begin
      ibsql.Close;
      ibsql.ParamByName('ID').AsInteger := Document.CreditMovement.Predefined[I];
      ibsql.ExecQuery;
      if not ibsql.EOF then
      begin
        Item := lvCreditMovementValues.Items.Add;
        Item.Caption := ibsql.FieldByName('NAME').AsString;
        Item.SubItems.Add(IntToStr(Document.CreditMovement.Predefined[I]));
      end;  
      ibsql.Close;
    end;

    for I := 0 to Length(Document.CreditMovement.SubPredefined) - 1 do
    begin
      ibsql.Close;
      ibsql.ParamByName('ID').AsInteger := Document.CreditMovement.SubPredefined[I];
      ibsql.ExecQuery;
      if not ibsql.EOF then
      begin
        Item := lvSubCreditMovementValues.Items.Add;
        Item.Caption := ibsql.FieldByName('NAME').AsString;
        Item.SubItems.Add(IntToStr(Document.CreditMovement.SubPredefined[I]));
      end;  
      ibsql.Close;
    end;

    cbDebitMovementChange(cbCreditMovement);
    if cbUseOutlaySub.Visible then
      cbUseOutlaySub.Checked :=
        (Document.CreditMovement.SubRelationName > '') and (Document.CreditMovement.SubSourceFieldName > '');

    cbUseIncomeSubClick(cbUseIncomeSub);


    // ��������� ���������
    SetupFeaturesTab;

    // ��������� ������������
{    Read(Sources, SizeOf(TgdcInvReferenceSources)); }

    cbReference.Checked := irsGoodRef in Document.Sources;
    cbRemains.Checked := irsRemainsRef in Document.Sources;
//  cbFromMacro.Checked := irsMacro in Sources;

    // ��������� FIFO, LIFO
{    Read(Direction, SizeOf(TgdcInvMovementDirection));}
    rgMovementDirection.ItemIndex := Integer(Document.Direction);

    // ������� ��������
    cbControlRemains.Checked := Document.ControlRemains;

    // ������ ������ � �������� ���������
    cbLiveTimeRemains.Checked := Document.LiveTimeRemains;

    if not cbRemains.Checked then
    begin
      // ������� ��������
      cbControlRemains.Checked := False;

      // ������ ������ � �������� ���������
      cbLiveTimeRemains.Checked := False;
    end;

    // �������� ����� ���� ����������
    cbDelayedDocument.Checked := Document.DelayedDocument;
    // ����� �������������� �����������

    cbMinusRemains.Checked := Document.MinusRemains;
    gbMinusFeatures.Visible := cbMinusRemains.Checked;

    if not cbRemains.Checked then
      cbMinusRemains.Checked := False;

{    if (Version = gdcInvDocument_Version2_2) or (Version = gdcInvDocument_Version2_3)
       or (Version = gdcInvDocument_Version2_4) or (Version = gdcInvDocument_Version2_5) or
      (Version = gdcInvDocument_Version2_6)
    then
    begin
      ReadListBegin;
      while not EndOfList do
      begin
        F := atDatabase.FindRelationField('INV_CARD', ReadString);
        if not Assigned(F) then Continue;
        Document.MinusFeatures.AddObject(F.FieldName, F);
      end;
      ReadListEnd;
}
      SetupMinusFeaturesTab;
{    end;}

{    if (Version = gdcInvDocument_Version2_3) or (Version = gdcInvDocument_Version2_4) or
       (Version = gdcInvDocument_Version2_5)  or
      (Version = gdcInvDocument_Version2_6) then
    begin}
      cbIsChangeCardValue.Checked := Document.IsChangeCardValue;
      cbIsAppendCardValue.Checked := Document.IsAppendCardValue;
{    end;}
    cbIsUseCompanyKey.Checked := Document.IsUseCompanyKey;
    cbSaveRestWindowOption.Checked := Document.SaveRestWindowOption;
    cbEndMonthRemains.Checked := Document.EndMonthRemains;

    cbWithoutSearchRemains.Visible := not cbControlRemains.Checked and (cbTemplate.ItemIndex = 1);
    if cbWithoutSearchRemains.Visible then
      cbWithoutSearchRemains.Checked := Document.WithoutSearchRemains
    else
      cbWithoutSearchRemains.Checked := False;

  finally
    ibsql.Free;
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
    ifkDest: List := Document.DestFeatures;
    ifkSource: List := Document.SourceFeatures;
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
      UpdateComboBox(GetRootRelation(True), luDebitFrom) else
    if rgDebitFrom.ItemIndex = 1 then
      UpdateComboBox(GetRootRelation(False), luDebitFrom);

    if rgDebitSubFrom.ItemIndex = 0 then
      UpdateComboBox(GetRootRelation(True), luDebitSubFrom) else
    if rgDebitSubFrom.ItemIndex = 1 then
      UpdateComboBox(GetRootRelation(False), luDebitSubFrom);

    cbDebitMovementChange(cbDebitMovement);
  end else

  if pcMain.ActivePage = tsOutlayMovement then
  begin
    if rgCreditFrom.ItemIndex = 0 then
      UpdateComboBox(GetRootRelation(True), luCreditFrom) else
    if rgCreditFrom.ItemIndex = 1 then
      UpdateComboBox(GetRootRelation(False), luCreditFrom);

    if rgCreditSubFrom.ItemIndex = 0 then
      UpdateComboBox(GetRootRelation(True), luCreditSubFrom) else
    if rgCreditSubFrom.ItemIndex = 1 then
      UpdateComboBox(GetRootRelation(False), luCreditSubFrom);

    cbDebitMovementChange(cbCreditMovement);
  end;
end;

procedure Tgdc_dlgSetupInvDocument.TestCommon;
begin
//����������� �������� (�� ����� ����� ��������) ������ ��� ����� ������� ��������
//� ������ ��� ������� ����� ���� Disabled
  if Trim(edEnglishName.Text) = '' then
  begin
    if edEnglishName.CanFocus then
      edEnglishName.SetFocus;
    raise EdlgSetupInvDocument.Create('������� ������������ �� ���������� �����!');
  end;

  if cbTemplate.ItemIndex = -1 then
  begin
    if cbTemplate.CanFocus then
      cbTemplate.SetFocus;
    raise EdlgSetupInvDocument.Create('������� ������ ���������!');
  end;

  if gdcObject.FieldByName('headerrelkey').IsNull then
  begin
    gdcObject.FieldByName('headerrelkey').FocusControl;
    raise EdlgSetupInvDocument.Create('������� �������-����� ���������!');
  end;

  if gdcObject.FieldByName('linerelkey').IsNull then
  begin
    gdcObject.FieldByName('linerelkey').FocusControl;
    raise EdlgSetupInvDocument.Create('������� �������-������� ���������!');
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
  // �������� �������

  if cbDebitMovement.ItemIndex = -1 then
  begin
    pcMain.ActivePage := tsIncomeMovement;
    cbDebitMovement.SetFocus;
    raise EdlgSetupInvDocument.Create('�������, ��� ��������� ������!');
  end;

  if rgDebitFrom.ItemIndex = -1 then
  begin
    pcMain.ActivePage := tsIncomeMovement;
    rgDebitFrom.SetFocus;
    raise EdlgSetupInvDocument.Create('�������, ������ ����� ������!');
  end;

  if luDebitFrom.ItemIndex = -1 then
  begin
    pcMain.ActivePage := tsIncomeMovement;
    if luDebitFrom.CanFocus then
      luDebitFrom.SetFocus;
    raise EdlgSetupInvDocument.Create('������� ���� ��� �������!');
  end;

  if cbUseIncomeSub.Checked then
  begin
    if rgDebitSubFrom.ItemIndex = -1 then
    begin
      pcMain.ActivePage := tsIncomeMovement;
      if luDebitSubFrom.CanFocus then
        luDebitSubFrom.SetFocus;
      raise EdlgSetupInvDocument.Create('�������, ������ ����� ����������� �������!');
    end;

    if luDebitSubFrom.ItemIndex = -1 then
    begin
      pcMain.ActivePage := tsIncomeMovement;
      if luDebitSubFrom.CanFocus then
        luDebitSubFrom.SetFocus;
      raise EdlgSetupInvDocument.Create('������� ���� ����������� �������!');
    end;

    if (rgDebitFrom.ItemIndex = 0) and (rgDebitSubFrom.ItemIndex = 1) then
    begin
      pcMain.ActivePage := tsIncomeMovement;
      if luDebitSubFrom.CanFocus then
        luDebitSubFrom.SetFocus;
      raise EdlgSetupInvDocument.Create(
        '����������� �� ����� ���� � ������� ���������, ���� ���� ������� ' +
        '���������� � "�����" ���������!');
    end;
  end;

  //
  // �������� �������

  if cbCreditMovement.ItemIndex = -1 then
  begin
    pcMain.ActivePage := tsOutlayMovement;
    cbCreditMovement.SetFocus;
    raise EdlgSetupInvDocument.Create('�������, ��� ��������� ������!');
  end;

  if rgCreditFrom.ItemIndex = -1 then
  begin
    pcMain.ActivePage := tsOutlayMovement;
    rgCreditFrom.SetFocus;
    raise EdlgSetupInvDocument.Create('�������, ������ ����� ������!');
  end;

  if luCreditFrom.ItemIndex = -1 then
  begin
    pcMain.ActivePage := tsOutlayMovement;
    if luCreditFrom.CanFocus then
      luCreditFrom.SetFocus;
    raise EdlgSetupInvDocument.Create('������� ���� ��� �������!');
  end;

  if cbUseOutlaySub.Checked then
  begin
    if rgCreditSubFrom.ItemIndex = -1 then
    begin
      pcMain.ActivePage := tsOutlayMovement;
      if luCreditSubFrom.CanFocus then
        luCreditSubFrom.SetFocus;
      raise EdlgSetupInvDocument.Create('�������, ������ ����� ����������� �������!');
    end;

    if luCreditSubFrom.ItemIndex = -1 then
    begin
      pcMain.ActivePage := tsOutlayMovement;
      if luCreditSubFrom.CanFocus then
        luCreditSubFrom.SetFocus;
      raise EdlgSetupInvDocument.Create('������� ���� ����������� �������!');
    end;

    if (rgCreditFrom.ItemIndex = 0) and (rgCreditSubFrom.ItemIndex = 1) then
    begin
      pcMain.ActivePage := tsOutlayMovement;
      if luCreditSubFrom.CanFocus then
        luCreditSubFrom.SetFocus;
      raise EdlgSetupInvDocument.Create(
        '����������� �� ����� ���� � ������� ���������, ���� ���� ������� ' +
        '���������� � "�����" ���������!');
    end;
  end;

  //
  // ����� ��������

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
      '��� ��������� ������������� ���� ������� � ������� ������ ��������� ' +
      '������ ��� � �����, ��� � ������� ���������!');
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
      '��� ��������� �������������, ���� � ������, � ������ � ������� ���������, ' +
      '������ �������������� ���� ����� ����!');
  end;
end;

procedure Tgdc_dlgSetupInvDocument.TestReferences;
begin
  if not cbReference.Checked and not cbRemains.Checked then
  begin
    pcMain.ActivePage := tsReferences;
    cbReference.SetFocus;
    raise EdlgSetupInvDocument.Create('������� ���� �� ���� �� ����������!');
  end;

  if cbRemains.Checked and (rgMovementDirection.ItemIndex = -1) then
  begin
    pcMain.ActivePage := tsReferences;
    cbRemains.SetFocus;
    raise EdlgSetupInvDocument.Create('������� ��� ����������� ��������!');
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
      '������ ��� ��������� ������ ����������� �������� � ���������!');
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
      '������ ��� ��������� �� ����� �������� �� ������������ �������!');
  end;

  if
    (TgdcInvRelationType(cbTemplate.ItemIndex) = irtInventorization)
      and
    cbLiveTimeRemains.Checked
  then begin
    cbLiveTimeRemains.Checked := False;
    MessageBox(Handle,
      '������������������ �������� ������ �������� ������ � ��������� �� ����. ' +
        '��������������� ����� ��������� �������������!',
      '��������',
      MB_OK or MB_ICONEXCLAMATION);
  end;

  { TODO 1 -o����� -c����� : ������� �������� �� ������ }
end;

procedure Tgdc_dlgSetupInvDocument.UpdateDocumentTemplates;
var
  I: Integer;
begin
  cbDocument.Items.Clear;

  cbDocument.Items.AddObject('��� �������', nil);

  for I := 0 to FTemplates.Count - 1 do
    cbDocument.Items.AddObject((FTemplates[I] as TatRelation).LName, FTemplates[I]);
end;

procedure Tgdc_dlgSetupInvDocument.UpdateEditingSettings;
var
  R: TatRelation;
  RelType: TgdcInvRelationType;
begin
  cbTemplate.Enabled := False;

  R := GetRootRelation(False);
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
  UpdateTabs;

  pcMain.ActivePage := tsCommon;

  lblDocument.Visible := True;
  cbDocument.Visible := True;

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
  cbWithoutSearchRemains.Visible := (cbTemplate.ItemIndex = 1) and not cbControlRemains.Checked;
end;

procedure Tgdc_dlgSetupInvDocument.UpdateTemplate;
var
  R, RL: TatRelation;

begin
  Assert(Assigned(Document));

  //
  // �� ��������� ������� ������� ������������ ��������� �� ���������.
  // ������� ������� �� ����� ����� ���������� �������

  //
  // ������� �������

  if (Document.State = dsInsert) then
  begin
    if (cbDocument.ItemIndex <> -1) and (cbDocument.ItemIndex <> 0) then
      R := cbDocument.Items.Objects[cbDocument.ItemIndex] as TatRelation
    else
      R := nil;

  end else
    R := nil;

  //
  // ������������ ������� �����, ���� ������� ����� �������

  if Assigned(R) then
    Document.FieldByName('headerrelkey').AsInteger := R.ID;

  //
  // ������ �������

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
  // ������������ ������� �����, ���� ������� ����� �������

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

  Movement := nil;
  with TWriter.Create(Stream, 1024) do
  try
    // ����� ���������
    WriteString(gdcInvDocument_Version3_0);

    R := GetRelation(True);
    RL := GetRelation(False);
    if not(Assigned(R) and Assigned(RL)) then
      raise EdlgSetupInvDocument.Create('�� ������� ������� ��� ���������!');

    // ������������ ������
    WriteString(R.RelationName);
    WriteString(RL.RelationName);

     //
    // ������������ �������� ������ � ������ �������

    if not Document.UpdateReportGroup('��������� ����',
      Document.FieldByName('name').AsString, rpgroupkey, True)
    then
      raise EdlgSetupInvDocument.Create('Report Group Key not created!');

    Document.FieldByName('reportgroupkey').AsInteger := rpgroupkey;

    // ���� ������ � ������ �������
    WriteInteger(rpgroupkey);

    // ������

    Movement := TgdcInvMovementContactOption.Create;
    Movement.ContactType := TgdcInvMovementContactType(cbDebitMovement.ItemIndex);

    R := GetRootRelation(True);
    RL := GetRootRelation(False);
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

    // ������
    Movement.ContactType := TgdcInvMovementContactType(cbCreditMovement.ItemIndex);
    R := GetRootRelation(True);
    RL := GetRootRelation(False);
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

    // ��������� ���������
    WriteListBegin;

    for I := 0 to Document.SourceFeatures.Count - 1 do
      WriteString(Document.SourceFeatures[I]);

    WriteListEnd;

    WriteListBegin;

    for I := 0 to Document.DestFeatures.Count - 1 do
      WriteString(Document.DestFeatures[I]);

    WriteListEnd;

    // ��������� ������������
    Sources := [];

    if cbReference.Checked then
      Sources := Sources + [irsGoodRef];
    if cbRemains.Checked then
      Sources := Sources + [irsRemainsRef];

    Write(Sources, SizeOf(TgdcInvReferenceSources));

    // ��������� FIFO, LIFO
    Direction := TgdcInvMovementDirection(rgMovementDirection.ItemIndex);
    Write(Direction, SizeOf(TgdcInvMovementDirection));

    // ������ ���� ������������ ������� ��������� ������� �������� checkbox-��

    if cbRemains.Checked then
    begin
      // �������� ��������
      WriteBoolean(cbControlRemains.Checked);

      // ������ ������ � �������� ���������
      WriteBoolean(cbLiveTimeRemains.Checked);
    end else

    begin
      // �������� ��������
      WriteBoolean(False);

      // ������ ������ � �������� ���������
      WriteBoolean(False);
    end;

    // ������������ ���������
    WriteBoolean(cbDelayedDocument.Checked);

    // ����������� ������
    WriteBoolean(False);

    // ������������� �������
    if cbRemains.Checked then
      WriteBoolean(cbMinusRemains.Checked)
    else
      WriteBoolean(False);

    // ��������� ��������� ��� ������������� ��������
    WriteListBegin;

    for I := 0 to Document.MinusFeatures.Count - 1 do
      WriteString(Document.MinusFeatures[I]);

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

procedure Tgdc_dlgSetupInvDocument.cbTemplateClick(Sender: TObject);
begin
  //cbDocument.ItemIndex := 0;

  //UpdateTabs;
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
  List: TStringList;
  I: Integer;
  Item, UsedItem: TListItem;
  R: TatRelation;
  RF: TatRelationField;
begin
  lvMinusFeatures.Items.Clear;
  lvMinusUsedFeatures.Items.Clear;

  List := Document.MinusFeatures;

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
  for I := 0 to Document.DestFeatures.Count - 1 do
  begin
    RF := R.RelationFields.ByFieldName(Document.DestFeatures[I]);
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

  if Document.State in [dsEdit, dsInsert] then
  begin
    if not Document.FieldByName('OPTIONS').IsNull then
    begin
      ReadOptions;
      UpdateTabs;
    end
    else
      if Document.State = dsEdit then
      begin
        UpdateEditingSettings;
        lblNotification.Visible := False;
      end else
      begin
        UpdateInsertingSettings;
        lblNotification.Visible := True;
      end;
  end;

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

initialization
  RegisterFrmClass(Tgdc_dlgSetupInvDocument);

finalization
  UnRegisterFrmClass(Tgdc_dlgSetupInvDocument);
end.

