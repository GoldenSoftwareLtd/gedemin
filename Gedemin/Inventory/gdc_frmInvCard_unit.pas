unit gdc_frmInvCard_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcInvMovement, gdcInvDocument_unit,
  Buttons, Mask, xDateEdits, at_classes, IBDatabase, gsIBLookupComboBox,
  gsPeriodEdit;

type
  Tgdc_frmInvCard = class(Tgdc_frmSGR)
    gdcInvCard: TgdcInvCard;
    Panel1: TPanel;
    TBControlItem1: TTBControlItem;
    lStart: TLabel;
    sbRun: TSpeedButton;
    actRun: TAction;
    cbAllInterval: TCheckBox;
    tbGoodInfo: TTBToolbar;
    TBItem1: TTBItem;
    Panel2: TPanel;
    TBControlItem2: TTBControlItem;
    Label1: TLabel;
    edBeginRest: TEdit;
    Label2: TLabel;
    edEndRest: TEdit;
    actOptions: TAction;
    TBItem2: TTBItem;
    actChooseIgnoryFeatures: TAction;
    TBItem3: TTBItem;
    cbIncludeInvMovement: TCheckBox;
    ibtrCommon: TIBTransaction;
    tbContact: TTBToolbar;
    Panel3: TPanel;
    TBControlItem3: TTBControlItem;
    Label3: TLabel;
    iblcContact: TgsIBLookupComboBox;
    gsPeriodEdit: TgsPeriodEdit;
    bSetCurrent: TButton;
    actSetCurrent: TAction;
    actListDocument: TAction;
    TBItem4: TTBItem;
    nListDocument: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actRunExecute(Sender: TObject);
    procedure actRunUpdate(Sender: TObject);
    procedure cbAllIntervalClick(Sender: TObject);
    procedure actOptionsExecute(Sender: TObject);
    procedure actChooseIgnoryFeaturesExecute(Sender: TObject);
    procedure cbIncludeInvMovementClick(Sender: TObject);
    procedure iblcPlaceChange(Sender: TObject);
    procedure iblcContactChange(Sender: TObject);
    procedure actSetCurrentExecute(Sender: TObject);
    procedure actSetCurrentUpdate(Sender: TObject);
    procedure actListDocumentExecute(Sender: TObject);
  private
    { Private declarations }
    isHolding: Integer;

  protected
    procedure DoDestroy; override;

  public
    { Public declarations }
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    procedure LoadSettings; override;
    procedure SaveSettings; override;

    procedure RunCard;

  end;

var
  gdc_frmInvCard: Tgdc_frmInvCard;

implementation

{$R *.DFM}

uses
  Storages, gsStorage_CompPath, dmDatabase_unit,
  gdc_attr_frmRelationField_unit, gdcBaseInterface,
  gd_ClassList, IBSQL, gdc_createable_form,
  gdcAcctEntryRegister, gdcClasses, gdcClasses_interface
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

class function Tgdc_frmInvCard.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmInvCard) then
    gdc_frmInvCard := Tgdc_frmInvCard.Create(AnOwner);

  Result := gdc_frmInvCard;

end;

procedure Tgdc_frmInvCard.FormCreate(Sender: TObject);
var
  Stream: TStringStream;
begin
  inherited;
//  gdcObject := gdcInvCard;
  ibtrCommon.StartTransaction;
  IsHolding := -1;
  dsMain.DataSet := gdcInvCard;
  Stream := TStringStream.Create('');
  try
    UserStorage.ReadStream(Name + '\InvCard', 'ViewFeatures', Stream);
    gdcInvCard.ViewFeatures.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create('');
  try
    UserStorage.ReadStream(Name + '\InvCard', 'IgnoryFeatures', Stream);
    gdcInvCard.IgnoryFeatures.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure Tgdc_frmInvCard.actEditExecute(Sender: TObject);
var
  gdcInvDocument: TgdcInvDocument;
begin
  gdcInvDocument := TgdcInvDocument.Create(Self);
  try
    gdcInvDocument.SubType := gdcObject.FieldByName('ruid').AsString;
    gdcInvDocument.SubSet := 'ByID';
    gdcInvDocument.ID := GetTID(gdcObject.FieldByName('parent'));
    gdcInvDocument.Open;
    if gdcInvDocument.EditDialog then
    begin
      gdcObject.Close;
      gdcObject.Open;
    end;
  finally
    gdcInvDocument.Free;
  end;
end;

procedure Tgdc_frmInvCard.actRunExecute(Sender: TObject);
var
  Saldo: Currency;
  ibsql: TIBSQL;
  NameContact: String;
  isOK: Boolean;
begin
  {if not cbAllInterval.Checked and (xdeStart.Date > xdeFinish.Date) then
  begin
    MessageBox(Handle, 'Неверен интервал просмотра', 'Внимание', mb_OK or mb_IconInformation);
    exit;
  end;}

  if isHolding = -1 then
  begin
    if gdcObject.HasSubSet('ByHolding') then
      isHolding := 1
    else
      isHolding := 0;
  end;

  tbContact.Visible := isHolding = 1;

  gdcObject.Close;
  if cbIncludeInvMovement.Checked then
    gdcObject.AddSubSet('ByAllMovement')
  else
    gdcObject.RemoveSubSet('ByAllMovement');

  if iblcContact.CurrentKeyInt > 0 then
  begin
    (gdcObject as TgdcInvCard).ContactKey := iblcContact.CurrentKeyInt;
    gdcObject.RemoveSubSet('ByHolding');
    gdcObject.AddSubSet('ByContact');
  end
  else
  begin
    if isHolding = 1 then
    begin
      gdcObject.AddSubSet('ByHolding');
      gdcObject.RemoveSubSet('ByContact');
    end;
    (gdcObject as TgdcInvCard).ContactKey := -1;
  end;

   
  gdcObject.ExtraConditions.Clear;

  if not cbAllInterval.Checked then
    gdcObject.ExtraConditions.Add(' m.movementdate >= :datebegin and m.movementdate <= :dateend ');


  isOk := True;
  repeat
    try
      if Assigned(gdcInvCard.gdcInvRemains) and gdcInvCard.gdcInvRemains.Active then
        gdcInvCard.SetRemainsConditions
      else
        if Assigned(gdcInvCard.gdcInvDocumentLine) and gdcInvCard.gdcInvDocumentLine.Active then
          gdcInvCard.SetDocumentLineConditions
        else
          if gdcObject.HasSubSet('ByContact') then
            SetTID(gdcObject.ParamByName('contactkey'), iblcContact.CurrentKeyInt);  

      if not cbAllInterval.Checked then
      begin
        gdcObject.ParamByName('datebegin').AsDateTime := gsPeriodEdit.Date;
        gdcObject.ParamByName('dateend').AsDateTime := gsPeriodEdit.EndDate;
      end;

      gdcObject.Open;

      isOk := True;
    except
      gdcInvCard.ViewFeatures.Clear;
      gdcInvCard.ReInitialized;
      if not isOk then
        raise
      else
        isOK := False;
    end;
  until isOk;

  if not cbAllInterval.Checked then
  begin
    Saldo := gdcInvCard.GetRemainsOnDate(gsPeriodEdit.Date - 1, False);
    edBeginRest.Text := FloatToStr(Saldo);
  end
  else
  begin
    Saldo := 0;
    edBeginRest.Text := '';
  end;

  gdcObject.DisableControls;
  try
    gdcObject.First;
    while not gdcObject.EOF do
    begin
      gdcObject.Edit;
      gdcObject.FieldByName('REMAINS').AsCurrency := Saldo + gdcObject.FieldByName('debit').AsCurrency -
        gdcObject.FieldByName('credit').AsCurrency;
      Saldo := gdcObject.FieldByName('REMAINS').AsCurrency;
      gdcObject.Post;
      gdcObject.Next;
    end;
  finally
    gdcObject.EnableControls;
  end;

  ibgrMain.ColumnByField(gdcObject.FieldByName('REMAINS')).Visible := True;
  ibgrMain.ColumnByField(gdcObject.FieldByName('REMAINS')).Title.Caption := 'Остаток';
  ibgrMain.ColumnByField(gdcObject.FieldByName('DEPOTNAME')).Visible := True;
  ibgrMain.ColumnByField(gdcObject.FieldByName('DEPOTNAME')).Title.Caption := 'Подразделение';


  NameContact := '';
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := gdcInvCard.ReadTransaction;
    ibsql.SQL.Text := 'SELECT name FROM gd_contact WHERE id = :id';
    if gdcInvCard.HasSubSet('ByHolding') then
      SetTID(ibsql.ParamByName('id'), -1)
    else
      SetTID(ibsql.ParamByName('id'), GetTID(gdcInvCard.ParamByName('contactkey')));
    ibsql.ExecQuery;

    NameContact := ibsql.FieldByName('name').AsString;
  finally
    ibsql.Free;
  end;

  Caption := Format('Карточка по ТМЦ: %s %s по %s ', [gdcInvCard.FieldByName('goodname').AsString,
    gdcInvCard.FieldByName('valuename').AsString, NameContact]);

  Saldo := gdcInvCard.GetRemainsOnDate(gsPeriodEdit.Date, cbAllInterval.Checked);
  edEndRest.Text := FloatToStr(Saldo);

end;

procedure Tgdc_frmInvCard.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMINVCARD', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMINVCARD', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMINVCARD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMINVCARD',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMINVCARD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  gsPeriodEdit.AssignPeriod(UserStorage.ReadString(BuildComponentPath(gsPeriodEdit),
    'Period', ''));

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMINVCARD', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMINVCARD', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
  
end;

procedure Tgdc_frmInvCard.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMINVCARD', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMINVCARD', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMINVCARD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMINVCARD',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMINVCARD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  UserStorage.WriteString(BuildComponentPath(gsPeriodEdit), 'Period', gsPeriodEdit.Text);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMINVCARD', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMINVCARD', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}

end;

procedure Tgdc_frmInvCard.actRunUpdate(Sender: TObject);
begin
  inherited;
  gsPeriodEdit.Enabled := not cbAllInterval.Checked;
  lStart.Enabled := not cbAllInterval.Checked;
end;

procedure Tgdc_frmInvCard.cbAllIntervalClick(Sender: TObject);
begin
  actRun.Execute;
end;

procedure Tgdc_frmInvCard.RunCard;
begin
  actRun.Execute;
end;

procedure Tgdc_frmInvCard.actOptionsExecute(Sender: TObject);
var
  R: TatRelation;
  F: TatRelationField;
  i: Integer;
begin
  with Tgdc_attr_frmRelationField.Create(Self) do
    try
      gdcTableField.ExtraConditions.Clear;
      gdcTableField.ExtraConditions.Add('z.relationname = ''INV_CARD'' AND z.fieldname LIKE ''USR$%''');
      for i:= 0 to gdcInvCard.RemainsFeatures.Count - 1 do
        gdcTableField.ExtraConditions.Add('z.fieldname <> ''' + gdcInvCard.RemainsFeatures[i] + '''');

      SetChoose(gdcTableField);
      gdcTableField.SelectedID.Clear;

      for i:= 0 to gdcInvCard.ViewFeatures.Count - 1 do
      begin
        R := atDatabase.Relations.ByRelationName('INV_CARD');
        if Assigned(R) then
        begin
          F := R.RelationFields.ByFieldName(gdcInvCard.ViewFeatures[i]);
          if Assigned(F) then
          begin
            gdcTableField.SelectedID.Add(F.ID);
            ibgrMain.CheckBox.AddCheck(F.ID);
          end;
        end;
      end;

      gdcTableField.SubSet := 'All';
      gdcTableField.Open;
      if ShowModal = mrOk then
      begin
        gdcTableField.SubSet := 'OnlySelected';
        gdcTableField.Open;
        gdcTableField.First;
        gdcInvCard.Close;
        gdcInvCard.ViewFeatures.Clear;
        while not gdcTableField.EOF do
        begin
          gdcInvCard.ViewFeatures.Add(gdcTableField.FieldByName('fieldname').AsString);
          gdcTableField.Next;
        end;
        gdcTableField.Close;
        gdcInvCard.SubSet := 'ByID';
        gdcInvCard.SubSet := 'ByContact';
        RunCard;
      end;
    finally
      Free;
    end;
end;

procedure Tgdc_frmInvCard.actChooseIgnoryFeaturesExecute(Sender: TObject);
var
  R: TatRelation;
  F: TatRelationField;
  i: Integer;
begin
  with Tgdc_attr_frmRelationField.Create(Self) do
    try
      gdcTableField.ExtraConditions.Clear;
      gdcTableField.ExtraConditions.Add('z.relationname = ''INV_CARD'' AND z.fieldname LIKE ''USR$%''');
{      for i:= 0 to gdcInvCard.RemainsFeatures.Count - 1 do
        gdcTableField.ExtraConditions.Add('z.fieldname <> ''' + gdcInvCard.RemainsFeatures[i] + '''');}

      SetChoose(gdcTableField);
      gdcTableField.SelectedID.Clear;

      for i:= 0 to gdcInvCard.IgnoryFeatures.Count - 1 do
      begin
        R := atDatabase.Relations.ByRelationName('INV_CARD');
        if Assigned(R) then
        begin
          F := R.RelationFields.ByFieldName(gdcInvCard.IgnoryFeatures[i]);
          if Assigned(F) then
          begin
            gdcTableField.SelectedID.Add(F.ID);
            ibgrMain.CheckBox.AddCheck(F.ID);
          end;
        end;
      end;

      gdcTableField.SubSet := 'All';
      gdcTableField.Open;
      if ShowModal = mrOk then
      begin
        gdcTableField.SubSet := 'OnlySelected';
        gdcTableField.Open;
        gdcTableField.First;
        gdcInvCard.Close;
        gdcInvCard.IgnoryFeatures.Clear;
        while not gdcTableField.EOF do
        begin
          gdcInvCard.IgnoryFeatures.Add(gdcTableField.FieldByName('fieldname').AsString);
          gdcTableField.Next;
        end;
        gdcTableField.Close;
        gdcInvCard.SubSet := 'ByID';
        gdcInvCard.SubSet := 'ByContact';
        RunCard;
      end;
    finally
      Free;
    end;
end;

procedure Tgdc_frmInvCard.DoDestroy;
var
  Stream: TStringStream;
begin
  inherited;

  try
    Stream := TStringStream.Create('');
    try
      gdcInvCard.ViewFeatures.SaveToStream(Stream);
      UserStorage.WriteStream(Name + '\InvCard', 'ViewFeatures', Stream);
    finally
      Stream.Free;
    end;

    Stream := TStringStream.Create('');
    try
      gdcInvCard.IgnoryFeatures.SaveToStream(Stream);
      UserStorage.WriteStream(Name + '\InvCard', 'IgnoryFeatures', Stream);
    finally
      Stream.Free;
    end;
  except
    Application.HandleException(Self);
  end;
end;

procedure Tgdc_frmInvCard.cbIncludeInvMovementClick(Sender: TObject);
begin
  actRun.Execute;
end;

procedure Tgdc_frmInvCard.iblcPlaceChange(Sender: TObject);
begin
  actRun.Execute;
end;

procedure Tgdc_frmInvCard.iblcContactChange(Sender: TObject);
begin
  if gdcInvCard.ContactKey <> iblcContact.CurrentKeyInt then
    actRun.Execute;
end;

procedure Tgdc_frmInvCard.actSetCurrentExecute(Sender: TObject);
begin
  iblcContact.CurrentKey := gdcInvCard.FieldByName('DEPOTKEY').AsString;
end;

procedure Tgdc_frmInvCard.actSetCurrentUpdate(Sender: TObject);
begin
  actSetCurrent.Enabled := not gdcInvCard.IsEmpty;
end;

procedure Tgdc_frmInvCard.actListDocumentExecute(Sender: TObject);
var
  Cl: TPersistentClass;
  F: TgdcFullClass;
  FormList: TgdcCreateableForm;
  gdcInvDocument: TgdcInvDocument;
begin
  gdcInvDocument := TgdcInvDocument.Create(Self);
  try
    gdcInvDocument.SubType := gdcObject.FieldByName('ruid').AsString;
    gdcInvDocument.SubSet := 'ByID';
    gdcInvDocument.ID := GetTID(gdcObject.FieldByName('parent'));
    gdcInvDocument.Open;

    if (gdcInvDocument.RecordCount > 0) then begin
      if GetTID(gdcInvDocument.FieldByName('documenttypekey')) <> DefaultDocumentTypeKey then
      begin
        F := TgdcDocument.GetDocumentClass(GetTID(gdcInvDocument.FieldByName('documenttypekey')), dcpHeader);
        Cl := Classes.GetClass(F.gdClass.ClassName);
        FormList := CgdcBase(Cl).CreateViewForm(Application, '', F.SubType, False) as TgdcCreateableForm;
        if Assigned(FormList) and Assigned(FormList.gdcObject) and Assigned(FormList.gdcObject.FindField('ID')) then
        begin
          if Assigned(FormList.gdcObject.Filter) and (GetTID(FormList.gdcObject.Filter.CurrentFilter) > 0)
            and (FormList.gdcObject.Filter.FilterData.FilterText <> '') then
            MessageBox(Handle, 'Внимание! На форме включена фильтрация данных.', PChar('Внимание!'), mb_OK or MB_ICONWARNING or MB_TASKMODAL);
          FormList.gdcObject.Locate('ID', TID2V(gdcObject.FieldByName('parent')),[]);
         end;
        if FormList <> nil then
          FormList.Show;
      end;
    end
    else
      MessageDlg('Документ не выбран.', mtInformation, [mbOk], -1)
  finally
    gdcInvDocument.Free;
  end;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmInvCard);

finalization
  UnRegisterFrmClass(Tgdc_frmInvCard);

end.
