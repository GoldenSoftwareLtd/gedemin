unit gdc_dlgInvCardConfig_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, ComCtrls, StdCtrls, gsIBLookupComboBox, Mask, DBCtrls,
  IBDatabase, Menus, Db, ActnList, at_Classes, gdcInvMovement, Buttons,
  contnrs, frFieldVlues_unit, frFieldValuesLine_unit,
  frFieldValuesLineConfig_unit, xDateEdits, ExtCtrls;

type
  Tgdc_dlgInvCardConfig = class(Tgdc_dlgTR)
    pcMain: TPageControl;
    tsCommon: TTabSheet;
    Label1: TLabel;
    lblShow: TLabel;
    dbedName: TDBEdit;
    cmbShow: TgsIBLookupComboBox;
    tsViewFeatures: TTabSheet;
    pcViewFeatures: TPageControl;
    tsViewCard: TTabSheet;
    tsViewGood: TTabSheet;
    acrAddCardField: TAction;
    actRemoveCardField: TAction;
    actAddAllCardField: TAction;
    actRemoveAllCardField: TAction;
    actAddGoodField: TAction;
    actRemoveGoodField: TAction;
    actAddAllGoodField: TAction;
    actRemoveAllGoodField: TAction;
    Label3: TLabel;
    lbAllCard: TListBox;
    lbUsedCard: TListBox;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lbAllGood: TListBox;
    lbUsedGood: TListBox;
    chkInternalOps: TCheckBox;
    lblImage: TLabel;
    cmbImages: TComboBox;
    chkShowInExplorer: TDBCheckBox;
    chkAllInterval: TCheckBox;
    btnAddAll: TBitBtn;
    btnAdd: TBitBtn;
    btnRemove: TBitBtn;
    btnRemoveAll: TBitBtn;
    btnAddAllGood: TBitBtn;
    btnAddGood: TBitBtn;
    btnRemoveGood: TBitBtn;
    btnRemoveAllGood: TBitBtn;
    tsFields: TTabSheet;
    pcValues: TPageControl;
    tsCardValues: TTabSheet;
    tsGoodValues: TTabSheet;
    pnlDate: TPanel;
    Bevel1: TBevel;
    Label6: TLabel;
    xdeStart: TxDateEdit;
    Label7: TLabel;
    xdeFinish: TxDateEdit;
    chkInputInterval: TCheckBox;
    frMainValues: TfrFieldValues;
    frCardValues: TfrFieldValues;
    frGoodValues: TfrFieldValues;
    Label8: TLabel;
    Bevel2: TBevel;
    frDebitDocsValues: TfrFieldValues;
    frCreditDocsValues: TfrFieldValues;
    procedure chkShowInExplorerClick(Sender: TObject);
    procedure acrAddCardFieldExecute(Sender: TObject);
    procedure actRemoveCardFieldExecute(Sender: TObject);
    procedure actAddAllCardFieldExecute(Sender: TObject);
    procedure actRemoveAllCardFieldExecute(Sender: TObject);
    procedure actAddGoodFieldExecute(Sender: TObject);
    procedure actRemoveGoodFieldExecute(Sender: TObject);
    procedure actAddAllGoodFieldExecute(Sender: TObject);
    procedure actRemoveAllGoodFieldExecute(Sender: TObject);
    procedure cmbImagesMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure cmbImagesDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure pcMainChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure chkAllIntervalClick(Sender: TObject);
  private
    procedure PrepareDialog;
    procedure LoadConfig;
    procedure SaveConfig;
    procedure MoveField(lbFrom, lbTo: TListBox);
    function  GetGDC: TgdcInvCardConfig;
    procedure UpdateFieldValuesFrame;
  public
    procedure SetupDialog; override;
    procedure SetupRecord; override;
    function TestCorrect: Boolean; override;
    procedure BeforePost; override;
  end;

var
  gdc_dlgInvCardConfig: Tgdc_dlgInvCardConfig;

implementation

{$R *.DFM}

uses
  gd_ClassList, dmImages_unit;

procedure Tgdc_dlgInvCardConfig.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGINVCARDCONFIG', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGINVCARDCONFIG', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGINVCARDCONFIG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGINVCARDCONFIG',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGINVCARDCONFIG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  PrepareDialog;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGINVCARDCONFIG', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGINVCARDCONFIG', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgInvCardConfig.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGINVCARDCONFIG', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGINVCARDCONFIG', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGINVCARDCONFIG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGINVCARDCONFIG',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGINVCARDCONFIG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if dsgdcBase.DataSet.State = dsEdit then
    LoadConfig;

  if gdcObject.FieldByName('imageindex').IsNull then
    cmbImages.ItemIndex := -1
  else
    cmbImages.ItemIndex := gdcObject.FieldByName('imageindex').AsInteger;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGINVCARDCONFIG', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGINVCARDCONFIG', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgInvCardConfig.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGINVCARDCONFIG', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGINVCARDCONFIG', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGINVCARDCONFIG') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGINVCARDCONFIG',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGINVCARDCONFIG' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Result:= True;
  if not ((frMainValues.Lines[frMainValues.IndexOf('GOODKEY')].Value = '') or
          (TfrFieldValuesLineConfig(frMainValues.Lines[frMainValues.IndexOf('GOODKEY')]).chkInputParam.Checked)) and
         (frGoodValues.Condition = '') then begin
    Result:= False;
    raise Exception.Create('Необходимо выбрать ТМЦ или задать признаки товара!');
  end;
  if not chkAllInterval.Checked and not chkInputInterval.Checked and (xdeStart.Date > xdeFinish.Date) then begin
    Result:= False;
    raise Exception.Create('Дата начала должна быть меньше либо равна дате окончания!');
  end;

  if not (GetGDC.State in [dsEdit, dsInsert]) then
    dsgdcBase.DataSet.Edit;

  SaveConfig;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGINVCARDCONFIG', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGINVCARDCONFIG', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgInvCardConfig.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGINVCARDCONFIG', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGINVCARDCONFIG', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGINVCARDCONFIG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGINVCARDCONFIG',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGINVCARDCONFIG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if cmbImages.ItemIndex = -1 then
    gdcObject.FieldByName('imageindex').Clear
  else
    gdcObject.FieldByName('imageindex').AsInteger := cmbImages.ItemIndex;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGINVCARDCONFIG', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGINVCARDCONFIG', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgInvCardConfig.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  pcMain.ActivePage:= tsCommon;
  frMainValues.ViewKind:= vkConfig;
  frCardValues.ViewKind:= vkConfig;
  frGoodValues.ViewKind:= vkConfig;
  frDebitDocsValues.ViewKind:= vkConfig;
  frCreditDocsValues.ViewKind:= vkConfig;
  cmbImages.Items.Clear;
  for I := 0 to dmImages.il16x16.Count - 1 do begin
    cmbImages.Items.Add(IntToStr(I));
  end;

  inherited;

end;

procedure Tgdc_dlgInvCardConfig.chkShowInExplorerClick(Sender: TObject);
begin
  lblShow.Enabled:= chkShowInExplorer.Checked;
  cmbShow.Enabled:= chkShowInExplorer.Checked;
  lblImage.Enabled:= chkShowInExplorer.Checked;
  cmbImages.Enabled:= chkShowInExplorer.Checked;
end;

procedure Tgdc_dlgInvCardConfig.MoveField(lbFrom, lbTo: TListBox);
var
  Index: Integer;
begin
  Index:= lbFrom.ItemIndex;
  if Index = -1 then
    Exit;
  if not Assigned(lbFrom.Items.Objects[Index]) then
    Exit;

  lbTo.Items.AddObject(lbFrom.Items[Index], lbFrom.Items.Objects[Index]);
  lbFrom.Items.Delete(Index);
  if Index < lbFrom.Items.Count then
    lbFrom.ItemIndex:= Index
  else if lbFrom.Items.Count > 0 then
    lbFrom.ItemIndex:= Index - 1
end;

procedure Tgdc_dlgInvCardConfig.PrepareDialog;
var
  I: Integer;
  Relation: TatRelation;
  FieldList: TObjectList;
begin
  { TODO : Ограничить поля для суммирования }
  pcMain.ActivePage := tsCommon;
  pcViewFeatures.ActivePageIndex := 0;
  pcValues.ActivePageIndex := 0;

  lbAllCard.Items.Clear;
  lbUsedCard.Items.Clear;
  lbAllGood.Items.Clear;
  lbUsedGood.Items.Clear;


  Relation := atDatabase.Relations.ByRelationName('INV_CARD');
  Assert(Relation <> nil);

  for I := 0 to Relation.RelationFields.Count - 1 do
  begin
    if not Relation.RelationFields[I].IsUserDefined then
      Continue;

    lbAllCard.Items.AddObject(Relation.RelationFields[I].LName, Relation.RelationFields[I]);
  end;

  Relation := atDatabase.Relations.ByRelationName('GD_GOOD');
  Assert(Relation <> nil);

  for I := 0 to Relation.RelationFields.Count - 1 do
  begin
//    if not Relation.RelationFields[I].IsUserDefined then
//      Continue;

    lbAllGood.Items.AddObject(Relation.RelationFields[I].LName, Relation.RelationFields[I]);
  end;

  FieldList:= TObjectList.Create;
  FieldList.OwnsObjects:= False;
  try
    FieldList.Add(atDataBase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName('GOODKEY'));
    FieldList.Add(atDataBase.Relations.ByRelationName('INV_MOVEMENT').RelationFields.ByFieldName('CONTACTKEY'));
    frMainValues.UpdateFieldList(FieldList);
    frMainValues.Lines[frMainValues.IndexOf('GOODKEY')].lblName.Caption:= 'ТМЦ:';
    frMainValues.Lines[frMainValues.IndexOf('CONTACTKEY')].lblName.Caption:= 'Подразделение:';
    frMainValues.UpdateFrameHeight;
    FieldList.Clear;
    FieldList.Add(atDataBase.Relations.ByRelationName('GD_DOCUMENT').RelationFields.ByFieldName('DOCUMENTTYPEKEY'));
    frDebitDocsValues.UpdateFieldList(FieldList);
    frDebitDocsValues.Lines[0].lblName.Caption:= 'Документы прихода:';
    frDebitDocsValues.UpdateFrameHeight;
    frDebitDocsValues.UpdateLines;
    frCreditDocsValues.UpdateFieldList(FieldList);
    frCreditDocsValues.Lines[0].lblName.Caption:= 'Документы расхода:';
    frCreditDocsValues.UpdateFrameHeight;
    frCreditDocsValues.UpdateLines;
  finally
    FieldList.Free;
  end;
end;

procedure Tgdc_dlgInvCardConfig.acrAddCardFieldExecute(Sender: TObject);
begin
  MoveField(lbAllCard, lbUsedCard);
end;

procedure Tgdc_dlgInvCardConfig.actRemoveCardFieldExecute(Sender: TObject);
begin
  MoveField(lbUsedCard, lbAllCard);
end;

procedure Tgdc_dlgInvCardConfig.actAddAllCardFieldExecute(Sender: TObject);
begin
  while lbAllCard.Items.Count > 0 do begin
    lbAllCard.ItemIndex:= 0;
    MoveField(lbAllCard, lbUsedCard);
  end;
end;

procedure Tgdc_dlgInvCardConfig.actRemoveAllCardFieldExecute(
  Sender: TObject);
begin
  while lbUsedCard.Items.Count > 0 do begin
    lbUsedCard.ItemIndex:= 0;
    MoveField(lbUsedCard, lbAllCard);
  end;
end;

procedure Tgdc_dlgInvCardConfig.actAddGoodFieldExecute(Sender: TObject);
begin
  MoveField(lbAllGood, lbUsedGood);
end;

procedure Tgdc_dlgInvCardConfig.actRemoveGoodFieldExecute(Sender: TObject);
begin
  MoveField(lbUsedGood, lbAllGood);
end;

procedure Tgdc_dlgInvCardConfig.actAddAllGoodFieldExecute(Sender: TObject);
begin
  while lbAllGood.Items.Count > 0 do begin
    lbAllGood.ItemIndex:= 0;
    MoveField(lbAllGood, lbUsedGood);
  end;
end;

procedure Tgdc_dlgInvCardConfig.actRemoveAllGoodFieldExecute(
  Sender: TObject);
begin
  while lbUsedGood.Items.Count > 0 do begin
    lbUsedGood.ItemIndex:= 0;
    MoveField(lbUsedGood, lbAllGood);
  end;
end;

procedure Tgdc_dlgInvCardConfig.LoadConfig;
var
  i: integer;
begin
  PrepareDialog;

  chkInternalOps.Checked:= GetGDC.Config.InternalOps;
  chkAllInterval.Checked:= GetGDC.Config.AllInterval;
  pnlDate.Visible:= not chkAllInterval.Checked;
  if pnlDate.Visible then begin
    chkInputInterval.Checked:= GetGDC.Config.InputInterval;
    if not chkInputInterval.Checked then begin
      xdeStart.Date:= GetGDC.Config.BeginDate;
      xdeFinish.Date:= GetGDC.Config.EndDate;
    end;
  end;

  frMainValues.Lines[frMainValues.IndexOf('GOODKEY')].Value:= GetGDC.Config.GoodValue;
  frMainValues.Lines[frMainValues.IndexOf('CONTACTKEY')].Value:= GetGDC.Config.DeptValue;
  frDebitDocsValues.Values:= GetGDC.Config.DebitDocsValue;
  frCreditDocsValues.Values:= GetGDC.Config.CreditDocsValue;

  lblShow.Enabled:= chkShowInExplorer.Checked;
  cmbShow.Enabled:= chkShowInExplorer.Checked;
  lblImage.Enabled:= chkShowInExplorer.Checked;
  cmbImages.Enabled:= chkShowInExplorer.Checked;

  for i:= lbAllCard.Items.Count - 1 downto 0 do begin
    if GetGDC.Config.CardFields.IndexOf((lbAllCard.Items.Objects[i] as TatRelationField).FieldName) > -1 then begin
      lbAllCard.ItemIndex:= i;
      MoveField(lbAllCard, lbUsedCard);
    end;
  end;
  for i:= lbAllGood.Items.Count - 1 downto 0 do begin
    if GetGDC.Config.GoodFields.IndexOf((lbAllGood.Items.Objects[i] as TatRelationField).FieldName) > -1 then begin
      lbAllGood.ItemIndex:= i;
      MoveField(lbAllGood, lbUsedGood);
    end;
  end;
  UpdateFieldValuesFrame;
  frCardValues.Values:= GetGDC.Config.CardValues;
  frGoodValues.Values:= GetGDC.Config.GoodValues;
end;

function Tgdc_dlgInvCardConfig.GetGDC: TgdcInvCardConfig;
begin
  Result:= gdcObject as TgdcInvCardConfig;
end;

procedure Tgdc_dlgInvCardConfig.SaveConfig;
var
  i: integer;
begin
  GetGDC.Config.InternalOps:= chkInternalOps.Checked;
  GetGDC.Config.AllInterval:= chkAllInterval.Checked;
  if not chkAllInterval.Checked then begin
    GetGDC.Config.InputInterval:= chkInputInterval.Checked;
    if not chkInputInterval.Checked then begin
      GetGDC.Config.BeginDate:= xdeStart.Date;
      GetGDC.Config.EndDate:= xdeFinish.Date;
    end;
  end;
  GetGDC.Config.GoodValue:= frMainValues.Lines[frMainValues.IndexOf('GOODKEY')].Value;
  GetGDC.Config.DeptValue:= frMainValues.Lines[frMainValues.IndexOf('CONTACTKEY')].Value;
  GetGDC.Config.DebitDocsValue:= frDebitDocsValues.Values;
  GetGDC.Config.CreditDocsValue:= frCreditDocsValues.Values;
  GetGDC.Config.CardFields.Clear;
  GetGDC.Config.GoodFields.Clear;
  for i:= 0 to lbUsedCard.Items.Count - 1 do begin
    GetGDC.Config.CardFields.Add((lbUsedCard.Items.Objects[i] as TatRelationField).FieldName);
  end;
  for i:= 0 to lbUsedGood.Items.Count - 1 do begin
    GetGDC.Config.GoodFields.Add((lbUsedGood.Items.Objects[i] as TatRelationField).FieldName);
  end;
  GetGDC.Config.CardValues:= frCardValues.Values;
  GetGDC.Config.GoodValues:= frGoodValues.Values;
  GetGDC.SaveConfig;
end;

procedure Tgdc_dlgInvCardConfig.cmbImagesMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
begin
  Height := 20;
end;

procedure Tgdc_dlgInvCardConfig.cmbImagesDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  cmbImages.Canvas.Brush.Style := bsSolid;
  if odFocused in State then
    cmbImages.Canvas.Brush.Color := clHighlight
  else
    cmbImages.Canvas.Brush.Color := clWindow;
  cmbImages.Canvas.FillRect(Rect);
  dmImages.il16x16.Draw(cmbImages.Canvas, Rect.Left + 2, Rect.Top + 2, Index, Control.Enabled);
end;

procedure Tgdc_dlgInvCardConfig.pcMainChange(Sender: TObject);
begin
  UpdateFieldValuesFrame;
end;

procedure Tgdc_dlgInvCardConfig.UpdateFieldValuesFrame;
var
  i: integer;
  FieldList: TObjectList;
begin
  FieldList:= TObjectList.Create;
  FieldList.OwnsObjects:= False;
  try
    for i:= 0 to lbUsedCard.Items.Count - 1 do begin
      FieldList.Add(lbUsedCard.Items.Objects[i]);
    end;
    frCardValues.UpdateFieldList(FieldList);
    FieldList.Clear;
    for i:= 0 to lbUsedGood.Items.Count - 1 do begin
      FieldList.Add(lbUsedGood.Items.Objects[i]);
    end;
    frGoodValues.UpdateFieldList(FieldList);
  finally
    FieldList.Free;
  end;
end;

procedure Tgdc_dlgInvCardConfig.Button1Click(Sender: TObject);
begin
  ShowMessage(frGoodValues.Values);
end;

procedure Tgdc_dlgInvCardConfig.chkAllIntervalClick(Sender: TObject);
begin
  pnlDate.Visible:= not chkAllInterval.Checked;
end;

initialization
  RegisterFrmClass(Tgdc_dlgInvCardConfig);

finalization
  UnRegisterFrmClass(Tgdc_dlgInvCardConfig);

end.
