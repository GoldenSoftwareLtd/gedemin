unit gdv_frmInvCard_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdv_frmG_unit, flt_sqlFilter, gd_ReportMenu, Menus, gd_MacrosMenu,
  ActnList, Db, StdCtrls, Mask, xDateEdits, Buttons, ExtCtrls, TB2Item,
  TB2Dock, TB2Toolbar, Grids, DBGrids, gsDBGrid, gsIBGrid, CheckLst, IBDatabase,
  gdvParamPanel, dmImages_unit, gsIBLookupComboBox, IBCustomDataSet, IBSQL,
  gdcBase, gdcInvMovement, dmDatabase_unit, ComCtrls, gdv_InvCardConfig_unit,
  gdcInvDocument_unit, gdv_frAcctTreeAnalytic_unit, contnrs,
  gdv_frAcctAnalytics_unit, xCalculatorEdit, frFieldVlues_unit, gd_security,
  gsPeriodEdit, gdcAcctConfig;

type
  TgdvInvCardFieldInfoRec = record
    FieldName: string;
    Caption: string;
  end;

  Tgdv_frmInvCard = class(Tgdv_frmG)
    pnlLeft: TPanel;
    splLeft: TSplitter;
    ibgrMain: TgsIBGrid;
    actShowParamPanel: TAction;
    tbiShowParamPanel: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    gdcInvCard: TgdcInvCard;
    TBControlItem2: TTBControlItem;
    chkAllInterval: TCheckBox;
    actSaveConfig: TAction;
    actSaveGridSetting: TAction;
    actClearGridSetting: TAction;
    tbConfig: TTBToolbar;
    TBControlItem3: TTBControlItem;
    TBItem5: TTBItem;
    iSaveGridSettings: TTBItem;
    iClearSaveGrid: TTBItem;
    pCofiguration: TPanel;
    lConfiguration: TLabel;
    cmbConfig: TgsIBLookupComboBox;
    StatusBar1: TStatusBar;
    Panel2: TPanel;
    Bevel1: TBevel;
    actEditInGrid: TAction;
    TBItem2: TTBItem;
    TBSeparatorItem2: TTBSeparatorItem;
    TBSeparatorItem3: TTBSeparatorItem;
    tbiEditInGrid: TTBItem;
    actEdit: TAction;
    tbGoodInfo: TTBToolbar;
    TBItem3: TTBItem;
    TBControlItem4: TTBControlItem;
    Panel3: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    edBeginRest: TEdit;
    edEndRest: TEdit;
    Transaction: TIBTransaction;
    sbLeft: TScrollBox;
    pnlTop: TPanel;
    chkInternalOps: TCheckBox;
    ppCardFields: TgdvParamPanel;
    lbCard: TCheckListBox;
    spl1: TSplitter;
    ppGoodFields: TgdvParamPanel;
    lbGood: TCheckListBox;
    gdcConfig: TgdcInvCardConfig;
    TBSeparatorItem4: TTBSeparatorItem;
    frGoodValues: TfrFieldValues;
    frCardValues: TfrFieldValues;
    actInputParams: TAction;
    actShowCard: TAction;
    frMainValues: TfrFieldValues;
    frCreditDocs: TfrFieldValues;
    frDebitDocs: TfrFieldValues;
    chkGroupByDoc: TCheckBox;
    cmbGood: TgsIBLookupComboBox;
    TBControlItem5: TTBControlItem;
    cmbDept: TgsIBLookupComboBox;
    TBControlItem6: TTBControlItem;
    procedure actShowParamPanelExecute(Sender: TObject);
    procedure actRunExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actRunUpdate(Sender: TObject);
    procedure actSaveConfigExecute(Sender: TObject);
    procedure cmbConfigChange(Sender: TObject);
    procedure actSaveGridSettingUpdate(Sender: TObject);
    procedure actClearGridSettingUpdate(Sender: TObject);
    procedure actSaveGridSettingExecute(Sender: TObject);
    procedure gdcInvCardGetSelectClause(Sender: TObject;
      var Clause: String);
    procedure gdcInvCardGetGroupClause(Sender: TObject;
      var Clause: String);
    procedure actEditInGridExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure ibgrMainDblClick(Sender: TObject);
    procedure actEditInGridUpdate(Sender: TObject);
    procedure actEditUpdate(Sender: TObject);
    procedure chkInternalOpsClick(Sender: TObject);
    procedure gdcInvCardFilterRecord(DataSet: TDataSet;
      var Accept: Boolean);
    procedure lbCardClick(Sender: TObject);
    procedure lbCardKeyPress(Sender: TObject; var Key: Char);
    procedure actClearGridSettingExecute(Sender: TObject);
    procedure gdcInvCardGetFromClause(Sender: TObject; var Clause: String);
    procedure frMainValuesResize(Sender: TObject);
    procedure actShowCardExecute(Sender: TObject);
  private
    procedure UpdateFieldsDataList;
    procedure PrepareConfigPanel;
    procedure DoLoadConfig(Config: TInvCardConfig);
    procedure DoSaveConfig(Config: TInvCardConfig);
    procedure DoSetConfigValues(Config: TInvCardConfig);
  protected
    procedure ParamsVisible(Value: Boolean);
    class function ConfigClassName: string; virtual;
    function  GetIndexByFieldName(lb: TCheckListBox; Field: string): integer;
    procedure SetCollumnsVisible;
    procedure SetBaseCollumnsVisible;
    function InputParams: boolean;
  public
    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  gdv_frmInvCard: Tgdv_frmInvCard;

const
  BaseInvCardFieldCount = 5;
  BaseInvCardFieldList: array[0 .. BaseInvCardFieldCount - 1] of TgdvInvCardFieldInfoRec =(
    (FieldName: 'DOCUMENTDATE'; Caption: 'Дата'),
    (FieldName: 'DOCNAME'; Caption: 'Документ'),
//    (FieldName: 'CON_USR$CONTACTKEY_NAME'; Caption: 'Откуда\куда'),
    (FieldName: 'NAME'; Caption: 'Откуда\куда'),
    (FieldName: 'DEBIT'; Caption: 'Приход'),
    (FieldName: 'CREDIT'; Caption: 'Расход')
    );

implementation

{$R *.DFM}

uses
  gd_ClassList, at_Classes, gdv_dlgConfigName_unit, AcctStrings, gdcConstants,
  gd_security_operationconst, gdcBaseInterface, frFieldValuesLineConfig_unit,
  gdv_dlgInvCardParams_unit;

{ Tgdv_frmInvCard }

procedure Tgdv_frmInvCard.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDV_FRMG', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDV_FRMINVCARD', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDV_FRMINVCARD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDV_FRMINVCARD',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDV_FRMINVCARD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  PrepareConfigPanel; 

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDV_FRMG', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDV_FRMINVCARD', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdv_frmInvCard.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDV_FRMG', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDV_FRMINVCARD', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDV_FRMINVCARD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDV_FRMINVCARD',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDV_FRMINVCARD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDV_FRMG', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDV_FRMINVCARD', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdv_frmInvCard.FormCreate(Sender: TObject);
var
  FieldList: TObjectList;
begin
  Transaction.DefaultDataBase := gdcBaseManager.Database;
  gdcObject:= gdcInvCard;
  inherited;
  cmbConfig.Condition := Format('CLASSNAME = ''%s''', [ConfigClassName]);
  gdcObject.Open;
  gdcConfig.Open;
  ppCardFields.Visible:= True;
  spl1.Visible:= True;
  ppGoodFields.Visible:= True;
  frMainValues.ViewKind:= vkSimple;
  FieldList:= TObjectList.Create;
  FieldList.OwnsObjects:= False;
  try
    FieldList.Add(atDataBase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName('GOODKEY'));
    FieldList.Add(atDataBase.Relations.ByRelationName('INV_MOVEMENT').RelationFields.ByFieldName('CONTACTKEY'));
    frMainValues.Sorted:= False;
    frMainValues.UpdateFieldList(FieldList);
    frMainValues.Lines[0].lblName.Caption:= 'ТМЦ:';
    frMainValues.Lines[1].lblName.Caption:= 'Подразделение:';
    frMainValues.UpdateFrameHeight;
    frMainValues.UpdateLines;
    FieldList.Clear;
    FieldList.Add(atDataBase.Relations.ByRelationName('GD_DOCUMENT').RelationFields.ByFieldName('DOCUMENTTYPEKEY'));
    frDebitDocs.UpdateFieldList(FieldList);
    frDebitDocs.UpdateFrameHeight;
    frDebitDocs.UpdateLines;
    frCreditDocs.UpdateFieldList(FieldList);
    frCreditDocs.UpdateFrameHeight;
    frCreditDocs.UpdateLines;
  finally
    FieldList.Free;
  end;
  SetBaseCollumnsVisible;
end;

procedure Tgdv_frmInvCard.ParamsVisible(Value: Boolean);
begin
  splLeft.Visible:= Value;
  pnlLeft.Visible:= Value;
end;

procedure Tgdv_frmInvCard.PrepareConfigPanel;
var
  i: integer;
  R: TatRelation;
begin
  lbCard.Items.Clear;
  lbGood.Items.Clear;

  R := atDatabase.Relations.ByRelationName('INV_CARD');
  Assert(Assigned(R));
  with R do begin
    for i := 0 to RelationFields.Count - 1 do begin
      if not RelationFields[i].IsUserDefined then Continue;
      lbCard.Items.AddObject(RelationFields[i].LName, RelationFields[i]);
    end;
  end;

  R := atDatabase.Relations.ByRelationName('GD_GOOD');
  Assert(Assigned(R));
  with R do begin
    for i := 0 to RelationFields.Count - 1 do begin
      if (RelationFields[i].FieldName = 'ID') or (RelationFields[i].FieldName = 'PARENT') or
         (RelationFields[i].FieldName = 'EDITIONDATE') or  (RelationFields[i].FieldName = 'EDITORKEY') or
         (RelationFields[i].FieldName = 'DISABLED') or (RelationFields[i].FieldName = 'RESERVED') then Continue;
      lbGood.Items.AddObject(RelationFields[i].LName, RelationFields[i]);
    end;
  end;
end;

procedure Tgdv_frmInvCard.actShowParamPanelExecute(Sender: TObject);
begin
  ParamsVisible(tbiShowParamPanel.Checked);
end;

procedure Tgdv_frmInvCard.actRunExecute(Sender: TObject);
var
  i: integer;
  Saldo: Currency;
  GoodV, DeptV, DocsD, DocsC, sDocs: string;
begin
  GoodV:= frMainValues.Lines[frMainValues.IndexOf('GOODKEY')].Condition;
  DeptV:= frMainValues.Lines[frMainValues.IndexOf('CONTACTKEY')].Condition;
  DocsD:= frDebitDocs.Lines[0].Condition;
  DocsC:= frCreditDocs.Lines[0].Condition;
  if (GoodV = '') and (frGoodValues.Condition = '') then
    raise Exception.Create('Необходимо выбрать ТМЦ или задать признаки товара!');

  gdcObject.Close;
  gdcObject.ExtraConditions.Clear;

  sDocs:= '';
  if DocsD <> '' then
    sDocs:= ' credit > 0 AND doct.id' + DocsD;
  if DocsC <> '' then begin
    if sDocs <> '' then
      sDocs:= ' ((' + sDocs + ') or (debit > 0 AND doct.id' + DocsC + '))'
    else
      sDocs:= ' debit > 0 AND doct.id' + DocsC;
  end;

  gdcObject.ExtraConditions.Add(sDocs);
  if GoodV <> '' then
    gdcObject.ExtraConditions.Add(' z.goodkey' + GoodV);
  if DeptV <> '' then
    gdcObject.ExtraConditions.Add(' ((m.contactkey' + DeptV + ') or (m.contactkey = :contactkey))');
  if not chkAllInterval.Checked then begin
    gdcObject.ExtraConditions.Add(' m.movementdate >= :datebegin and m.movementdate <= :dateend ');
    gdcObject.ParamByName('datebegin').AsDateTime := gsPeriodEdit.Date;
    gdcObject.ParamByName('dateend').AsDateTime := gsPeriodEdit.EndDate;
  end;

  gdcInvCard.ViewFeatures.Clear;
  for i:= 0 to lbCard.Items.Count - 1 do begin
    if not lbCard.Checked[i] then Continue;
    gdcInvCard.ViewFeatures.Add((lbCard.Items.Objects[i] as TatRelationField).FieldName);
  end;

  frCardValues.Alias:= 'c';
  frGoodValues.Alias:= 'g';
  gdcObject.ExtraConditions.Add(frCardValues.Condition);
  gdcObject.ExtraConditions.Add(frGoodValues.Condition);

  gdcInvCard.SubSet:= 'ByID';
  gdcInvCard.SubSet:= 'ByGoodDetail';

  gdcInvCard.Filtered:= not chkInternalOps.Checked;
  if chkInternalOps.Checked then
    gdcInvCard.AddSubSet('ByAllMovement')
  else
    gdcInvCard.RemoveSubSet('ByAllMovement');
  gdcInvCard.Open;

  if not chkAllInterval.Checked then begin
    Saldo:= gdcInvCard.GetRemainsOnDate(gsPeriodEdit.Date - 1, False, DeptV);
    edBeginRest.Text:= FloatToStr(Saldo);
  end
  else
    edBeginRest.Text:= '';

  Saldo:= gdcInvCard.GetRemainsOnDate(gsPeriodEdit.EndDate, chkAllInterval.Checked, DeptV);
  edEndRest.Text:= FloatToStr(Saldo);

  if cmbConfig.CurrentKeyInt > -1 then begin
    if (gdcConfig.ID > -1) and (gdcConfig.Config <> nil) and (gdcConfig.Config.GridSettings.Size > 0) then
      ibgrMain.LoadFromStream(gdcConfig.Config.GridSettings);
  end
  else
    SetCollumnsVisible;
end;

procedure Tgdv_frmInvCard.DoLoadConfig(Config: TInvCardConfig);
var
  i: integer;
begin
  with Config do begin
    if GoodValue <> cInputParam then
      frMainValues.Lines[frMainValues.IndexOf('GOODKEY')].Value:= GoodValue;
    if DeptValue <> cInputParam then
      frMainValues.Lines[frMainValues.IndexOf('CONTACTKEY')].Value:= DeptValue;
    if DebitDocsValue <> cInputParam then
      frDebitDocs.Values:= DebitDocsValue;
    if CreditDocsValue <> cInputParam then
      frCreditDocs.Values:= CreditDocsValue;
    gsPeriodEdit.AssignPeriod(BeginDate, EndDate);
    chkInternalOps.Checked:= InternalOps;
    chkAllInterval.Checked:= AllInterval;
    if (not chkAllInterval.Checked) and (not InputInterval) then
      gsPeriodEdit.AssignPeriod(BeginDate, EndDate);
    gdcObject.Filtered:= not InternalOps;

    for i:= 0 to lbCard.Items.Count - 1 do begin
      lbCard.Checked[i]:= CardFields.IndexOf((lbCard.Items.Objects[i] as TatRelationField).FieldName) > -1;
    end;
    for i:= 0 to lbGood.Items.Count - 1 do begin
      lbGood.Checked[i]:= GoodFields.IndexOf((lbGood.Items.Objects[i] as TatRelationField).FieldName) > -1;
    end;
    UpdateFieldsDataList;
    frCardValues.Values:= CardValues;
    frGoodValues.Values:= GoodValues;

    if GridSettings.Size > 0 then
      ibgrMain.LoadFromStream(GridSettings);
  end;
  SetCollumnsVisible;
end;

procedure Tgdv_frmInvCard.DoSetConfigValues(Config: TInvCardConfig);
begin
  with Config do begin
    GoodValue:= frMainValues.Lines[frMainValues.IndexOf('GOODKEY')].Value;
    DeptValue:= frMainValues.Lines[frMainValues.IndexOf('CONTACTKEY')].Value;
    DebitDocsValue:= frDebitDocs.Values;
    CreditDocsValue:= frCreditDocs.Values;
    BeginDate:= gsPeriodEdit.Date;
    EndDate:= gsPeriodEdit.EndDate;
    CardValues:= frCardValues.Values;
    GoodValues:= frGoodValues.Values;
    InternalOps:= chkInternalOps.Checked;
    AllInterval:= chkAllInterval.Checked;
  end;
end;

procedure Tgdv_frmInvCard.DoSaveConfig(Config: TInvCardConfig);
var
  i: integer;
begin
  with Config do begin
    CardFields.Clear;
    for i:= 0 to lbCard.Items.Count - 1 do begin
      if lbCard.Checked[i] then
        CardFields.Add((lbCard.Items.Objects[i] as TatRelationField).FieldName);
    end;
    GoodFields.Clear;
    for i:= 0 to lbGood.Items.Count - 1 do begin
      if lbGood.Checked[i] then
        GoodFields.Add((lbGood.Items.Objects[i] as TatRelationField).FieldName);
    end;
  end;
  DoSetConfigValues(Config);
end;

class function Tgdv_frmInvCard.ConfigClassName: string;
begin
  Result:= 'TInvCardConfig';
end;

procedure Tgdv_frmInvCard.actRunUpdate(Sender: TObject);
begin
  inherited;
  gsPeriodEdit.Enabled := not chkAllInterval.Checked;
  lblPeriod.Enabled := not chkAllInterval.Checked;
end;

function Tgdv_frmInvCard.GetIndexByFieldName(lb: TCheckListBox; Field: string): integer;
var
  i: integer;
begin
  Result:= -1;
  for i:= 0 to lb.Items.Count - 1 do begin
    if (lb.Items.Objects[i] as TatRelationField).FieldName = Field then begin
      Result:= i;
      Exit;
    end;
  end;
end;

procedure Tgdv_frmInvCard.actSaveConfigExecute(Sender: TObject);
var
  D: TdlgConfigName;
begin
  D:= TdlgConfigName.Create(nil);
  try
    D.iblName.Condition := cmbConfig.Condition;
    D.iblName.CurrentKey := cmbConfig.CurrentKey;
    D.iblName.gdClassName := cmbConfig.gdClassName;
    if D.ShowModal = mrOk then begin
      if D.iblName.CurrentKey <> '' then begin
        if Application.MessageBox(
            PChar(Format(MSG_CONFIGEXITS, [D.ConfigName])),
            PChar(MSG_WARNING),
            MB_YESNO or MB_TASKMODAL or MB_ICONQUESTION) <> IDYES then begin
          Exit;
        end;
      end
      else begin
        gdcConfig.Insert;
        gdcConfig.FieldByName('name').AsString:= D.ConfigName;
        gdcConfig.FieldByName('showinexplorer').AsInteger := 0;
//        gdcConfig.FieldByName('folder').AsInteger := AC_ACCOUNTANCY;
//        gdcConfig.FieldByName('imageindex').AsInteger := iiGreenCircle;
        gdcConfig.FieldByName('classname').AsString := ConfigClassName;
        gdcConfig.Post;
      end;
      DoSaveConfig(gdcConfig.Config);
      gdcConfig.SaveConfig;
      Transaction.CommitRetaining;
    end;
  finally
    D.Free;
  end;
end;

procedure Tgdv_frmInvCard.cmbConfigChange(Sender: TObject);
begin
  if  cmbConfig.CurrentKeyInt > -1 then begin
    gdcConfig.CLoseOpen;
    gdcConfig.ID:= cmbConfig.CurrentKeyInt;
    DoLoadConfig(gdcConfig.Config);
  end;
end;

procedure Tgdv_frmInvCard.actSaveGridSettingUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := cmbConfig.CurrentKey > ''
end;

procedure Tgdv_frmInvCard.actClearGridSettingUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := cmbConfig.CurrentKey > ''
end;

procedure Tgdv_frmInvCard.actSaveGridSettingExecute(Sender: TObject);
begin
  gdcConfig.SaveGrid(ibgrMain);
  Transaction.CommitRetaining;
end;

procedure Tgdv_frmInvCard.gdcInvCardGetFromClause(Sender: TObject;
  var Clause: String);
var
  F: TatRelationField;
  i: integer;
  TAlias: string;
begin
  for i:= 0 to lbGood.Items.Count - 1 do begin
    if not lbGood.Checked[i] then Continue;
    F:= (lbGood.Items.Objects[i] as TatRelationField);
    if F.IsUserDefined or (F.References = nil) then Continue;
    TAlias:= ' G_' + F.FieldName;
    Clause:= Clause + ' LEFT JOIN ' + F.References.RelationName + TAlias +
      ' ON ' + TAlias + '.' + F.ReferencesField.FieldName + ' = ' + F.FieldName
  end;
end;

procedure Tgdv_frmInvCard.gdcInvCardGetSelectClause(Sender: TObject;
  var Clause: String);
var
  i: integer;
  F: TatRelationField;
  TAlias: string;
begin
  for i := 0 to lbGood.Items.Count - 1 do begin
    if not lbGood.Checked[i] then Continue;
    F := (lbGood.Items.Objects[i] as TatRelationField);
    if F.FieldName = 'NAME' then Continue;
    Clause := Clause + ', g.' + F.FieldName;
    if F.IsUserDefined or (F.References = nil) then Continue;
    TAlias:= 'G_' + F.FieldName;
    Clause:= Clause + ', ' + TAlias + '.' + F.ReferenceListField.FieldName + ' AS ' +
      TAlias + '_' + F.ReferenceListField.FieldName;
  end;
end;

procedure Tgdv_frmInvCard.gdcInvCardGetGroupClause(Sender: TObject;
  var Clause: String);
var
  i: integer;
  F: TatRelationField;
  TAlias: string;
  HavingClause: String;
begin
  //в данный код groupclause может прийти с having
  //что делает данный код ошибочным
  //разделим clause на две составляющие.
  HavingClause := '';
  i := AnsiPos('HAVING', Clause);
  if i > 0 then
  begin
    HavingClause := Copy(Clause, i, Length(Clause) - i + 1);
    Clause := Copy(Clause, 0, i - 1);
  end;

  for i := 0 to lbGood.Items.Count - 1 do
  begin
    if not lbGood.Checked[i] then Continue;
    F := (lbGood.Items.Objects[i] as TatRelationField);
    if F.FieldName = 'NAME' then Continue;
    Clause := Clause + ', g.' + F.FieldName;
    if F.IsUserDefined or (F.References = nil) then Continue;
    TAlias := ', G_' + F.FieldName;
    Clause := Clause + TAlias + '.' + F.ReferenceListField.FieldName;
  end;
  Clause := Clause + ' ' + HavingClause;
end;

procedure Tgdv_frmInvCard.actEditInGridExecute(Sender: TObject);
var
  I: Integer;
begin
  I := ibgrMain.SelectedIndex;

  ibgrMain.ReadOnly:= tbiEditInGrid.Checked;
  if tbiEditInGrid.Checked then begin
    ibgrMain.Options := ibgrMain.Options + [dgEditing, dgIndicator];
  end else begin
    ibgrMain.Options := ibgrMain.Options - [dgEditing, dgIndicator];
  end;
  ibgrMain.SettingsModified := True;

  ibgrMain.SelectedIndex := I;
end;

procedure Tgdv_frmInvCard.actEditExecute(Sender: TObject);
var
  gdcInvDocument: TgdcInvDocument;
begin
  gdcInvDocument := TgdcInvDocument.Create(Self);
  try
    gdcInvDocument.SubType := gdcObject.FieldByName('ruid').AsString;
    gdcInvDocument.SubSet := 'ByID';
    gdcInvDocument.ID := gdcObject.FieldByName('parent').AsInteger;
    gdcInvDocument.Open;
    if gdcInvDocument.EditDialog then begin
      gdcObject.CloseOpen;
    end;
  finally
    gdcInvDocument.Free;
  end;
end;

procedure Tgdv_frmInvCard.ibgrMainDblClick(Sender: TObject);
begin
  actEdit.Execute;
end;

procedure Tgdv_frmInvCard.actEditInGridUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= gdcObject.ID > 0;
end;

procedure Tgdv_frmInvCard.actEditUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= gdcObject.ID > 0;
end;

procedure Tgdv_frmInvCard.chkInternalOpsClick(Sender: TObject);
begin
  gdcObject.Filtered:= not chkInternalOps.Checked;
end;

procedure Tgdv_frmInvCard.gdcInvCardFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
begin
  Accept:= gdcObject.FieldByName('debit').AsCurrency <> gdcObject.FieldByName('credit').AsCurrency
end;

procedure Tgdv_frmInvCard.UpdateFieldsDataList;
var
  i: integer;
  FieldList: TObjectList;
begin
  sbLeft.AutoScroll:= False;
  FieldList:= TObjectList.Create(False);
  try
    for i:= 0 to lbCard.Items.Count - 1 do begin
      if lbCard.Checked[i] then
        FieldList.Add(lbCard.Items.Objects[i]);
    end;
    frCardValues.UpdateFieldList(FieldList);
    frCardValues.Visible:= frCardValues.Count > 0;
    FieldList.Clear;
    for i:= 0 to lbGood.Items.Count - 1 do begin
      if lbGood.Checked[i] then
        FieldList.Add(lbGood.Items.Objects[i]);
    end;
    frGoodValues.UpdateFieldList(FieldList);
    frGoodValues.Visible:= frGoodValues.Count > 0;
  finally
    FieldList.Free;
    sbLeft.AutoScroll:= True;
  end;
end;

procedure Tgdv_frmInvCard.lbCardClick(Sender: TObject);
begin
  UpdateFieldsDataList;
end;

procedure Tgdv_frmInvCard.lbCardKeyPress(Sender: TObject; var Key: Char);
begin
  UpdateFieldsDataList;
end;

procedure Tgdv_frmInvCard.actClearGridSettingExecute(Sender: TObject);
begin
  gdcConfig.ClearGrid;
  Transaction.CommitRetaining;
end;

procedure Tgdv_frmInvCard.SetCollumnsVisible;
var
  i, j, k: integer;
  sFieldName: string;
  Field: TatRelationField;
begin
  SetBaseCollumnsVisible;
  for i:= 0 to ibgrMain.Columns.Count - 1 do begin
    if ibgrMain.Columns.Items[i].Field.FieldName = 'GOODNAME' then begin
      for j:= 0 to lbGood.Items.Count - 1 do begin
        if (lbGood.Items.Objects[j] as TatRelationField).FieldName = 'NAME' then begin
          ibgrMain.Columns[i].Visible:= lbGood.Checked[j];
          Break;
        end;
      end;
      Continue;
    end;
    for j:= 0 to lbCard.Items.Count - 1 do begin
      Field:= (lbCard.Items.Objects[j] as TatRelationField);
      if ibgrMain.Columns[i].Field.FieldName = Field.FieldName then begin
        if Field.References <> nil then begin
          ibgrMain.Columns[i].Visible:= False;
          sFieldName:= 'C_' + Field.FieldName + '_' + Field.Field.RefListFieldName;
          for k:= 0 to ibgrMain.Columns.Count - 1 do begin
            if ibgrMain.Columns[k].Field.FieldName = sFieldName then begin
              ibgrMain.Columns[k].Visible:= lbCard.Checked[j];
              Break;
            end;
          end;
        end
        else begin
          ibgrMain.Columns[i].Visible:= lbCard.Checked[j];
          Break;
        end;
      end;
    end;
    for j:= 0 to lbGood.Items.Count - 1 do begin
      Field:= (lbGood.Items.Objects[j] as TatRelationField);
      if Field.FieldName = 'NAME' then Continue;
      if ibgrMain.Columns[i].Field.FieldName = Field.FieldName then begin
        if Field.References <> nil then begin
          ibgrMain.Columns[i].Visible:= False;
          if Field.Field.RefListFieldName = '' then
            sFieldName:= 'G_' + Field.FieldName + '_' + Field.References.ListField.FieldName
          else
            sFieldName:= 'G_' + Field.FieldName + '_' + Field.Field.RefListFieldName;
          for k:= 0 to ibgrMain.Columns.Count - 1 do begin
            if ibgrMain.Columns[k].Field.FieldName = sFieldName then begin
              ibgrMain.Columns[k].Visible:= lbGood.Checked[j];
              Break;
            end;
          end;
        end
        else begin
          ibgrMain.Columns[i].Visible:= lbGood.Checked[j];
          Break;
        end;
      end;
    end;
  end;
end;

procedure Tgdv_frmInvCard.frMainValuesResize(Sender: TObject);
begin
  pnlTop.Height:= frMainValues.Height + 20;//36;
end;

procedure Tgdv_frmInvCard.actShowCardExecute(Sender: TObject);
begin
  if not InputParams then begin
    Free;
  end
  else begin
    try
      actRun.Execute;
      tbiShowParamPanel.Checked:= False;
      pnlLeft.Visible:= False;
      splLeft.Visible:= False;
      Show;
    except
      on E: Exception do begin
        Free;
      end;
    end;
  end;
end;

function Tgdv_frmInvCard.InputParams: boolean;
var
  frm: Tgdv_dlgInvCardParams;
begin
  Result:= True;
  if gdcConfig.InputParamsCount = 0 then
    Exit;
  if (cmbGood.CurrentKeyInt > 0) or (cmbDept.CurrentKeyInt > 0) then begin
    if cmbGood.CurrentKeyInt > 0 then
      frMainValues.Lines[0].Value:= '$0' + cmbGood.CurrentKey;
    if cmbDept.CurrentKeyInt > 0 then
      frMainValues.Lines[1].Value:= '$0' + cmbDept.CurrentKey;
    Exit;
  end;
  frm:= Tgdv_dlgInvCardParams.Create(self);
  try
    frm.gdcObject:= gdcConfig;
    frm.PrepareDialog;
    frm.ShowModal;
    if frm.ModalResult = mrOk then begin
      if frm.frMainValues.LinesCount > 0 then begin
        frMainValues.NeedClearValues:= False;
        frMainValues.Values:= frm.frMainValues.Values;
      end;
      if frm.frGoodValues.LinesCount > 0 then begin
        frGoodValues.NeedClearValues:= False;
        frGoodValues.Values:= frm.frGoodValues.Values;
      end;
      if frm.frCardValues.LinesCount > 0 then begin
        frCardValues.NeedClearValues:= False;
        frCardValues.Values:= frm.frCardValues.Values;
      end;
      if not chkAllInterval.Checked then
        gsPeriodEdit.AssignPeriod(frm.gsPeriodEdit.Text);
      ppCardFields.Unwraped:= False;
      ppGoodFields.Unwraped:= False;
    end
    else begin
      Result:= False;
    end;
  finally
    frm.Free;
  end;
end;

procedure Tgdv_frmInvCard.SetBaseCollumnsVisible;
var
  i, j, k: integer;
  bDocsD, bDocsC: boolean;
begin
  k:= 0;
  bDocsD:= frDebitDocs.Lines[0].Condition <> '';
  bDocsC:= frCreditDocs.Lines[0].Condition <> '';
  for i:= 0 to BaseInvCardFieldCount - 1 do begin
    for j:= i to ibgrMain.Columns.Count - 1 do begin
      if (BaseInvCardFieldList[i].FieldName = 'DEBIT') and (bDocsD or bDocsC) then
        ibgrMain.Columns[j].Visible:= bDocsD and
          (ibgrMain.Columns[j].Field.FieldName = BaseInvCardFieldList[i].FieldName)
      else if (BaseInvCardFieldList[i].FieldName = 'CREDIT') and (bDocsD or bDocsC) then
        ibgrMain.Columns[j].Visible:= bDocsC and
          (ibgrMain.Columns[j].Field.FieldName = BaseInvCardFieldList[i].FieldName)
      else
      ibgrMain.Columns[j].Visible:=
        (ibgrMain.Columns[j].Field.FieldName = BaseInvCardFieldList[i].FieldName);
      if ibgrMain.Columns[j].Visible then begin
        if j > k then
          k:= j + 1;
        ibgrMain.Columns[j].Title.Caption:= BaseInvCardFieldList[i].Caption;
        ibgrMain.Columns[j].Index:= i;
        Break;
      end;
    end;
  end;
  for i:= BaseInvCardFieldCount to ibgrMain.Columns.Count - 1 do
    ibgrMain.Columns[i].Visible:= False;
end;

initialization
  RegisterFrmClass(Tgdv_frmInvCard);

finalization
  UnRegisterFrmClass(Tgdv_frmInvCard);

end.
