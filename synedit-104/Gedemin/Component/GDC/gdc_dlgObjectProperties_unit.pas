unit gdc_dlgObjectProperties_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, ComCtrls, IBDatabase, Db, ActnList, StdCtrls,
  gsIBLookupComboBox, Grids, DBGrids, gsDBGrid, gsIBGrid, IBCustomDataSet,
  gdcBase, gdcBaseInterface, gdcUser, DBCtrls, Menus, gd_security, TB2Dock,
  TB2Toolbar, TB2Item, evt_i_base;

type
  Tgdc_dlgObjectProperties = class(Tgdc_dlgTR)
    pcMain: TPageControl;
    tsGeneral: TTabSheet;
    tsAccess: TTabSheet;
    cbAccessClass: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ibgrUserGroup: TgsIBGrid;
    ibcbUserGroup: TgsIBLookupComboBox;
    memoExclude: TMemo;
    btnExclude: TButton;
    gdcUserGroup: TgdcUserGroup;
    dsUserGroup: TDataSource;
    Label4: TLabel;
    lblClassName: TLabel;
    Label5: TLabel;
    lblName: TLabel;
    gdcUserGroupID: TIntegerField;
    gdcUserGroupNAME: TIBStringField;
    btnInclude: TButton;
    actExclude: TAction;
    actInclude: TAction;
    Label6: TLabel;
    btnIncludeAll: TButton;
    actIncludeAll: TAction;
    Label7: TLabel;
    btnExcludeAll: TButton;
    actExcludeAll: TAction;
    lblObjectID: TLabel;
    btnCopyID: TButton;
    actCopyIDToClipboard: TAction;
    Label9: TLabel;
    lblCurrentRecord: TLabel;
    Label12: TLabel;
    lblParent: TLabel;
    Label14: TLabel;
    lblLB: TLabel;
    Label16: TLabel;
    lblRB: TLabel;
    Label13: TLabel;
    lblParentClassName: TLabel;
    Label15: TLabel;
    lblSubType: TLabel;
    Label17: TLabel;
    lblSubSet: TLabel;
    Label18: TLabel;
    lblListTable: TLabel;
    Label19: TLabel;
    lblClassLabel: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    lblCreationDate: TLabel;
    lblCreator: TLabel;
    lblEditionDate: TLabel;
    lblEditor: TLabel;
    tsAdditional: TTabSheet;
    Label24: TLabel;
    lblRecordCount: TLabel;
    Label26: TLabel;
    lblCacheSize: TLabel;
    Button6: TButton;
    actShowSQL: TAction;
    lblParams: TLabel;
    cbParams: TComboBox;
    Label25: TLabel;
    lblRUID: TLabel;
    btnCopyRUID: TButton;
    actCopyRUIDToClipboard: TAction;
    sbFields: TScrollBox;
    tsFields: TTabSheet;
    sbFields2: TScrollBox;
    chbxUpdateChildren: TCheckBox;
    Label8: TLabel;
    lblConnectedTables: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label27: TLabel;
    edAView: TEdit;
    edAChag: TEdit;
    edAFull: TEdit;
    Label28: TLabel;
    lblExtraConditions: TLabel;
    tsLinks: TTabSheet;
    tbLinks: TTBToolbar;
    ibgrLinks: TgsIBGrid;
    ibdsLinks: TIBDataSet;
    dsLinks: TDataSource;
    actShowLinkObject: TAction;
    TBItem1: TTBItem;
    Label29: TLabel;
    TBControlItem1: TTBControlItem;
    Label30: TLabel;
    cbOpenDoc: TComboBox;
    TBControlItem2: TTBControlItem;
    Button1: TButton;
    actGoToMethods: TAction;
    actGoToMethodsSubtype: TAction;
    Button2: TButton;
    Button3: TButton;
    actGoToMethodsParent: TAction;
    procedure cbAccessClassChange(Sender: TObject);
    procedure actExcludeUpdate(Sender: TObject);
    procedure actExcludeExecute(Sender: TObject);
    procedure actIncludeUpdate(Sender: TObject);
    procedure actIncludeExecute(Sender: TObject);
    procedure actIncludeAllUpdate(Sender: TObject);
    procedure actIncludeAllExecute(Sender: TObject);
    procedure actExcludeAllUpdate(Sender: TObject);
    procedure actExcludeAllExecute(Sender: TObject);
    procedure actCopyIDToClipboardExecute(Sender: TObject);
    procedure tsAccessShow(Sender: TObject);
    procedure actShowSQLExecute(Sender: TObject);
    procedure actShowSQLUpdate(Sender: TObject);
    procedure actCopyRUIDToClipboardExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actShowLinkObjectUpdate(Sender: TObject);
    procedure actShowLinkObjectExecute(Sender: TObject);
    procedure actGoToMethodsExecute(Sender: TObject);
    procedure actGoToMethodsSubtypeExecute(Sender: TObject);
    procedure actGoToMethodsParentExecute(Sender: TObject);
    procedure actGoToMethodsUpdate(Sender: TObject);
    procedure actGoToMethodsSubtypeUpdate(Sender: TObject);
    procedure actGoToMethodsParentUpdate(Sender: TObject);
    procedure actCopyIDToClipboardUpdate(Sender: TObject);

  private
    function GetCurrentSecField(const ATI: TgdcTableInfos = []): TField;

    procedure LabelDblClick(Sender: TObject);
    procedure LabelMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);

    procedure BuildLinks;  

  protected
    procedure SyncCombo;

    procedure IncludeGroups(const AMask: Integer);
    procedure ExcludeGroups(const AMask: Integer);

    procedure Post; override;

    procedure ResizerOnActivate(var Activate: Boolean); override;
    function DlgModified: Boolean; override;

  public
    procedure SetupDialog; override;
    procedure SetupRecord; override;
  end;

var
  gdc_dlgObjectProperties: Tgdc_dlgObjectProperties;

implementation

{$R *.DFM}
uses
  gdcTree, Clipbrd, gd_ClassList, flt_frmSQLEditorSyn_unit,
  ContNrs, at_classes, gdcMetaData, IBUtils, IBSQL, gdcClasses;

{ Tgdc_dlgObjectProperties }

procedure Tgdc_dlgObjectProperties.SyncCombo;
begin
  if pcMain.ActivePage = tsAccess then
  begin
    if GetCurrentSecField <> nil then
    begin
      gdcUserGroup.Mask := GetCurrentSecField.AsInteger;
      gdcUserGroup.Open;
    end
  end;
end;

procedure Tgdc_dlgObjectProperties.cbAccessClassChange(Sender: TObject);
begin
  SyncCombo;
end;

procedure Tgdc_dlgObjectProperties.actExcludeUpdate(Sender: TObject);
begin
  if pcMain.ActivePage = tsAccess then
    actExclude.Enabled := gdcUserGroup.Active and (gdcUserGroup.RecordCount > 0)
    and (GetCurrentSecField <> nil)
    and (gdcUserGroup.ID <> 1); // администраторов нельзя исключать
end;

function Tgdc_dlgObjectProperties.GetCurrentSecField(const ATI: TgdcTableInfos = []): TField;
var
  FN, RN: String;
  I: Integer;
begin
  Result := nil;

  if (not Assigned(gdcObject)) or (cbAccessClass.ItemIndex < 0) then
    exit;

  if ATI = [] then
    case TgdcTableInfo(cbAccessClass.Items.Objects[cbAccessClass.ItemIndex]) of
      tiAView: FN := 'AVIEW';
      tiAChag: FN := 'ACHAG';
      tiAFull: FN := 'AFULL';
    end
  else if tiAFull in ATI then
    FN := 'AFULL'
  else if tiAChag in ATI then
    FN := 'ACHAG'
  else if tiAView in ATI then
    FN := 'AVIEW';

  RN := gdcObject.GetListTable(gdcObject.SubType);

  for I := 0 to gdcObject.FieldCount - 1 do
    if (AnsiCompareText(FN, gdcObject.FieldNameByAliasName(gdcObject.Fields[I].FieldName)) = 0) and
      (AnsiCompareText(RN, gdcObject.RelationByAliasName(gdcObject.Fields[I].FieldName)) = 0) then
    begin
      Result := gdcObject.Fields[I];
      exit;
    end;

  if Result = nil then
  begin
    for I := 0 to gdcObject.FieldCount - 1 do
      if (AnsiCompareText(FN, gdcObject.FieldNameByAliasName(gdcObject.Fields[I].FieldName)) = 0) then
      begin
        Result := gdcObject.Fields[I];
        exit;
      end;
  end;
end;

procedure Tgdc_dlgObjectProperties.actExcludeExecute(Sender: TObject);
begin
  if pcMain.ActivePage = tsAccess then
  begin
    ExcludeGroups(gdcUserGroup.GetGroupMask);
  end;
  SyncCombo;
end;

procedure Tgdc_dlgObjectProperties.actIncludeUpdate(Sender: TObject);
begin
  if pcMain.ActivePage = tsAccess then
    actInclude.Enabled := {(ibcbUserGroup.CurrentKey > '') and} (GetCurrentSecField <> nil);
end;

procedure Tgdc_dlgObjectProperties.actIncludeExecute(Sender: TObject);
begin
  if pcMain.ActivePage = tsAccess then
  begin
    if (ibcbUserGroup.CurrentKey = '') then
    begin
      MessageBox(Handle,
        'Пожалуйста, выберите группу из предложенного списка.',
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      ActiveControl := ibcbUserGroup;
      exit;
    end;

    IncludeGroups(gdcUserGroup.GetGroupMask(ibcbUserGroup.CurrentKeyInt));
  end;
  SyncCombo;
end;

procedure Tgdc_dlgObjectProperties.actIncludeAllUpdate(Sender: TObject);
begin
  if pcMain.ActivePage = tsAccess then
    actIncludeAll.Enabled := GetCurrentSecField <> nil;
end;

procedure Tgdc_dlgObjectProperties.actIncludeAllExecute(Sender: TObject);
begin
  if pcMain.ActivePage = tsAccess then
  begin
    IncludeGroups(-1);
  end;
  SyncCombo;
end;

procedure Tgdc_dlgObjectProperties.actExcludeAllUpdate(Sender: TObject);
begin
  if pcMain.ActivePage = tsAccess then
    actExcludeAll.Enabled := gdcUserGroup.Active and (gdcUserGroup.RecordCount > 0)
      and (GetCurrentSecField <> nil);
end;

procedure Tgdc_dlgObjectProperties.actExcludeAllExecute(Sender: TObject);
begin
  if pcMain.ActivePage = tsAccess then
  begin
    ExcludeGroups(not 1);
  end;
  SyncCombo;
end;

procedure Tgdc_dlgObjectProperties.actCopyIDToClipboardExecute(
  Sender: TObject);
var
  C: TClipboard;
begin
  C := TClipboard.Create;
  try
    C.AsText := IntToStr(gdcObject.ID);
  finally
    C.Free;
  end;
end;

procedure Tgdc_dlgObjectProperties.tsAccessShow(Sender: TObject);
var
  OldCursor: TCursor;
begin
  SyncCombo;

  if pcMain.ActivePage = tsLinks then
  begin
    OldCursor := Screen.Cursor;
    try
      Screen.Cursor := crHourGlass;
      BuildLinks;
      Screen.Cursor := OldCursor;
    except
      Screen.Cursor := OldCursor;
      MessageBox(Handle,
        'Показать ссылки для данного объекта невозможно.',
        'Внимание',
        MB_OK or MB_ICONHAND or MB_TASKMODAL);
      pcMain.ActivePage := tsGeneral;
    end;
  end;
end;

procedure Tgdc_dlgObjectProperties.actShowSQLExecute(Sender: TObject);
var
  P: TParams;
  I: Integer;
begin
  P := nil;
  with TfrmSQLEditorSyn.Create(Self) do
  try
    P := TParams.Create;
    for I := 0 to gdcObject.Params.Count - 1 do
    begin
      P.CreateParam(ftString, gdcObject.Params[I].Name, ptUnknown).Value :=
        gdcObject.Params[I].Value;
    end;

    FDatabase := gdcObject.Database;
    ShowSQL(gdcObject.SelectSQL.Text, P);
  finally
    P.Free;
    Free;
  end;
end;

procedure Tgdc_dlgObjectProperties.actShowSQLUpdate(Sender: TObject);
begin
  actShowSQL.Enabled := (gdcObject <> nil)
    and Assigned(IBLogin)
    and IBLogin.IsUserAdmin;
end;

procedure Tgdc_dlgObjectProperties.ExcludeGroups(const AMask: Integer);
begin
  if (GetCurrentSecField <> nil) then
  begin
    GetCurrentSecField.AsInteger := GetCurrentSecField.AsInteger and
      (not AMask);

    case TgdcTableInfo(cbAccessClass.Items.Objects[cbAccessClass.ItemIndex]) of
      tiAView:
        begin
          if GetCurrentSecField([tiAFull]) <> nil then
            GetCurrentSecField([tiAFull]).AsInteger := GetCurrentSecField([tiAView]).AsInteger and
              (not AMask);
          if GetCurrentSecField([tiAChag]) <> nil then
            GetCurrentSecField([tiAChag]).AsInteger := GetCurrentSecField([tiAChag]).AsInteger and
              (not AMask);
        end;
      tiAChag:
        if GetCurrentSecField([tiAFull]) <> nil then
          GetCurrentSecField([tiAFull]).AsInteger := GetCurrentSecField([tiAView]).AsInteger and
            (not AMask);
      tiAFull: ;
    end;
  end;
end;

procedure Tgdc_dlgObjectProperties.IncludeGroups(const AMask: Integer);
begin
  if (GetCurrentSecField <> nil) then
  begin
    GetCurrentSecField.AsInteger := GetCurrentSecField.AsInteger or
      AMask;

    case TgdcTableInfo(cbAccessClass.Items.Objects[cbAccessClass.ItemIndex]) of
      tiAView: ;
      tiAChag:
        if GetCurrentSecField([tiAView]) <> nil then
          GetCurrentSecField([tiAView]).AsInteger := GetCurrentSecField([tiAView]).AsInteger or
            AMask;
      tiAFull:
        begin
          if GetCurrentSecField([tiAView]) <> nil then
            GetCurrentSecField([tiAView]).AsInteger := GetCurrentSecField([tiAView]).AsInteger or
              AMask;
          if GetCurrentSecField([tiAChag]) <> nil then
            GetCurrentSecField([tiAChag]).AsInteger := GetCurrentSecField([tiAChag]).AsInteger or
              AMask;
        end;
    end;
  end;
end;

procedure Tgdc_dlgObjectProperties.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGOBJECTPROPERTIES', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGOBJECTPROPERTIES', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGOBJECTPROPERTIES') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGOBJECTPROPERTIES',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGOBJECTPROPERTIES' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if Assigned(gdcObject) then
  begin
    lblRUID.Caption := RUIDToStr(gdcObject.GetRUID);
  end else
    lblRUID.Caption := '';
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGOBJECTPROPERTIES', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGOBJECTPROPERTIES', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgObjectProperties.actCopyRUIDToClipboardExecute(
  Sender: TObject);
var
  C: TClipboard;
begin
  C := TClipboard.Create;
  try
    C.AsText := RUIDToStr(gdcObject.GetRUID);
  finally
    C.Free;
  end;
end;

procedure Tgdc_dlgObjectProperties.SetupDialog;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  I: Integer;
  L: TLabel;
  DBE: TDBEdit;
  Lst: TObjectList;
  FK: TatForeignKey;
  PK, PK2: TatPrimaryKey;
  E: TEdit;
  C: TCheckBox; 

begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGOBJECTPROPERTIES', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGOBJECTPROPERTIES', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGOBJECTPROPERTIES') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGOBJECTPROPERTIES',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGOBJECTPROPERTIES' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if Assigned(gdcObject) then
  begin
    lblClassLabel.Caption := gdcObject.GetDisplayName(gdcObject.SubType);
    lblClassName.Caption := gdcObject.ClassName;
    lblParentClassName.Caption := gdcObject.ClassParent.ClassName;
    lblSubType.Caption := gdcObject.SubType;
    lblSubSet.Caption := gdcObject.SubSet;
    lblExtraConditions.Caption := gdcObject.ExtraConditions.Text;
    lblCurrentRecord.Caption := gdcObject.GetCurrRecordClass.gdClass.ClassName;
    lblName.Caption := gdcObject.ObjectName;
    lblListTable.Caption := gdcObject.GetListTable(gdcObject.SubType);

    lblConnectedTables.Text := '';
    Lst := TObjectList.Create(False);
    try
      atDatabase.ForeignKeys.ConstraintsByReferencedRelation(lblListTable.Caption,
        Lst);
      for I := 0 to Lst.Count - 1 do
      begin
        FK := Lst[I] as TatForeignKey;
        PK := FK.ReferencesRelation.PrimaryKey;
        PK2 := FK.Relation.PrimaryKey;
        if (PK <> nil) and (PK.ConstraintFields.Count = 1)
          and (FK.ConstraintFields.Count = 1)
          and (PK2 <> nil) and (PK2.ConstraintFields.Count = 1)
          and (PK2.ConstraintFields[0].FieldName = FK.ConstraintFields[0].FieldName) then
        begin
          if lblConnectedTables.Text > '' then
            lblConnectedTables.Text := lblConnectedTables.Text + ', ';
          lblConnectedTables.Text := lblConnectedTables.Text +
            FK.Relation.RelationName;
        end;
      end;
    finally
      Lst.Free;
    end;

    lblObjectID.Caption := FormatFloat('#,##0', gdcObject.ID);

    if gdcObject is TgdcTree then
    begin
      lblParent.Caption := FormatFloat('#,##0', (gdcObject as TgdcTree).Parent);
      chbxUpdateChildren.Visible := True;
    end else
    begin
      lblParent.Caption := '';
      chbxUpdateChildren.Visible := False;
    end;

    if gdcObject is TgdcLBRBTree then
    begin
      lblLB.Caption := FormatFloat('#,##0', (gdcObject as TgdcLBRBTree).LB);
      lblRB.Caption := FormatFloat('#,##0', (gdcObject as TgdcLBRBTree).RB);
    end else
    begin
      lblLB.Caption := '';
      lblRB.Caption := '';
    end;

    if tiCreationInfo in gdcObject.gdcTableInfos then
    begin
      lblCreationDate.Caption := gdcObject.FieldByName('creationdate').AsString;
      lblCreator.Caption := gdcObject.CreatorName;
    end else
    begin
      lblCreationDate.Caption := '';
      lblCreator.Caption := '';
    end;

    if tiEditionInfo in gdcObject.gdcTableInfos then
    begin
      lblEditionDate.Caption := gdcObject.FieldByName('editiondate').AsString;
      lblEditor.Caption := gdcObject.EditorName;
    end else
    begin
      lblEditionDate.Caption := '';
      lblEditor.Caption := '';
    end;

    if gdcObject.FindField('aview') <> nil then
    begin
      edAView.Text :=
        TgdcUserGroup.GetGroupList(gdcObject.FindField('aview').AsInteger);
    end else
    begin
      edAView.Text := '';
    end;

    if gdcObject.FindField('achag') <> nil then
    begin
      edAChag.Text :=
        TgdcUserGroup.GetGroupList(gdcObject.FindField('achag').AsInteger);
    end else
    begin
      edAChag.Text := '';
    end;

    if gdcObject.FindField('afull') <> nil then
    begin
      edAFull.Text :=
        TgdcUserGroup.GetGroupList(gdcObject.FindField('afull').AsInteger);
    end else
    begin
      edAFull.Text := '';
    end;

    cbParams.Items.Clear;
    if gdcObject.Params.Count = 0 then
      cbParams.Items.Add('Нет параметров')
    else begin
      cbParams.Items.Add('Параметры...');
      for I := 0 to gdcObject.Params.Count - 1 do
        cbParams.Items.Add(Format('%s = %s', [gdcObject.Params[I].Name, gdcObject.Params[I].AsString]));
    end;
    cbParams.ItemIndex := 0;

    if gdcObject.CanChangeRights
      and (TgdcUserGroup.Class_TestUserRights([tiAView], '')) then
    begin
      cbAccessClass.Items.Clear;
      if tiAView in gdcObject.gdcTableInfos then
        cbAccessClass.Items.AddObject('Только просмотр', Pointer(Integer(tiAView)));
      if tiAChag in gdcObject.gdcTableInfos then
        cbAccessClass.Items.AddObject('Просмотр и изменение', Pointer(Integer(tiAChag)));
      if tiAFull in gdcObject.gdcTableInfos then
        cbAccessClass.Items.AddObject('Полный доступ', Pointer(Integer(tiAFull)));

      if cbAccessClass.Items.Count = 0 then
        tsAccess.TabVisible := False
      else begin
        tsAccess.TabVisible := True;
        cbAccessClass.ItemIndex := 0;
        SyncCombo;
      end;
    end else
      tsAccess.TabVisible := False;

    pcMain.ActivePageIndex := 0;

    //
    lblRecordCount.Caption := FormatFloat('#,##0', gdcObject.RecordCount);
    lblCacheSize.Caption := FormatFloat('#,##0', gdcObject.CacheSize);

    for I := 0 to gdcObject.FieldCount - 1 do
    begin
      DBE := TDBEdit.Create(sbFields);
      DBE.Parent := sbFields;
      DBE.Left := 122;
      DBE.Top := I * 20 + 2;
      DBE.Width := sbFields.Width - 122 - 20 - 1;
      DBE.ParentFont := True;
      DBE.DataSource := dsgdcBase;
      DBE.DataField := gdcObject.Fields[I].FieldName;

      L := TLabel.Create(sbFields);
      L.Parent := sbFields;
      L.Left := 5;
      L.Top := I * 20 + 4 + 2;
      L.ParentFont := True;
      L.FocusControl := DBE;
      L.ShowHint := True;
      L.Tag := Integer(gdcObject.Fields[I]);
      L.OnClick := LabelDblClick;
      L.OnDblClick := LabelDblClick;
      L.OnMouseMove := LabelMouseMove;
      with gdcObject.Fields[I] do
      begin
        L.Caption := FieldName + ':';
        L.Hint := FieldName + #13#10 + Origin + ': ' + ClassName + #13#10 + DisplayLabel +
          #13#10'DataSize: ' + IntToStr(DataSize) + '; Size: ' + IntToStr(Size);
        DBE.Hint := L.Hint;
      end;

      E := TEdit.Create(sbFields2);
      E.Parent := sbFields2;
      E.Left := 122;
      E.Top := I * 20 * 2 + 2;
      E.Width := sbFields2.Width - 122 - 20 - 1;
      E.ParentFont := True;
      E.ReadOnly := True;
      E.Text := gdcObject.Fields[I].DefaultExpression;
      E.Color := clBtnFace;

      L := TLabel.Create(sbFields2);
      L.Parent := sbFields2;
      L.Left := 5;
      L.Top := I * 20 * 2 + 4 + 2;
      L.ParentFont := True;
      L.FocusControl := E;
      L.ShowHint := True;

      with gdcObject.Fields[I] do
      begin
        L.Hint := FieldName + #13#10 + Origin + ': ' + ClassName + #13#10 + DisplayLabel;
        E.Hint := L.Hint;
        E.Text := DefaultExpression;
        L.Caption := FieldName + ':';
      end;

      C := TCheckBox.Create(sbFields2);
      C.Parent := sbFields2;
      C.Left := 122;
      C.Top := I * 20 * 2 + 20 + 2;
      C.ParentFont := True;
      C.ShowHint := True;
      C.Caption := 'Not null';
      C.Hint := L.Hint;
      C.Checked := gdcObject.Fields[I].Required;
      C.Enabled := False;

      C := TCheckBox.Create(sbFields2);
      C.Parent := sbFields2;
      C.Left := 122 + 80;
      C.Top := I * 20 * 2 + 20 + 2;
      C.ParentFont := True;
      C.ShowHint := True;
      C.Caption := 'Сохраняется';
      C.Hint := L.Hint;
      C.Checked := Pos(';' + gdcObject.Fields[I].FieldName + ';',
        ';' + gdcObject.GetDialogDefaultsFields) > 0;
      C.Enabled := False;
    end;
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGOBJECTPROPERTIES', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGOBJECTPROPERTIES', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgObjectProperties.Post;
var
  OldUpdateChildren: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGOBJECTPROPERTIES', 'POST', KEYPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGOBJECTPROPERTIES', KEYPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGOBJECTPROPERTIES') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGOBJECTPROPERTIES',
  {M}          'POST', KEYPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGOBJECTPROPERTIES' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if Assigned(gdcObject) and (gdcObject is TgdcTree) then
  begin
    OldUpdateChildren := UpdateChildren_Global;
    try
      UpdateChildren_Global := chbxUpdateChildren.Checked;
      inherited;
    finally
      UpdateChildren_Global := OldUpdateChildren;
    end;
  end else
    inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGOBJECTPROPERTIES', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGOBJECTPROPERTIES', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgObjectProperties.LabelDblClick(Sender: TObject);
var
  F: TField;
  Obj: TgdcRelationField;
begin
  F := Pointer((Sender as TComponent).Tag);

  Obj := TgdcRelationField.Create(nil);
  try
    Obj.SubSet := 'ByFieldName,ByRelationName';
    Obj.ParamByName('RelationName').AsString :=
      ExtractIdentifier(IBLogin.Database.SQLDialect,
        System.Copy(F.Origin, 1, Pos('.', F.Origin) - 1));
    Obj.ParamByName('FieldName').AsString :=
      ExtractIdentifier(IBLogin.Database.SQLDialect,
        System.Copy(F.Origin, Pos('.', F.Origin) + 1, 255));

    Obj.Open;
    if not Obj.EOF then
      Obj.EditDialog;//('TGDC_DLGOBJECTPROPERTIES');    
  finally
    Obj.Free;
  end;

  TLabel(Sender).Font.Color := clWindowText;
  TLabel(Sender).Font.Style := [];
end;

procedure Tgdc_dlgObjectProperties.LabelMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
  if (X > 0) and (X < Width) and (Y > 0) and (Y < Height) then
  begin
    TLabel(Sender).Font.Color := clBlue;
    TLabel(Sender).Font.Style := [fsunderLine];

    for I := 0 to TLabel(Sender).Owner.ComponentCount - 1 do
    begin
      if (TLabel(Sender).Owner.Components[I] is TLabel)
        and (TLabel(Sender).Owner.Components[I] <> Sender) then
      begin
        if TLabel(TLabel(Sender).Owner.Components[I]).Font.Color = clBlue then
        begin
          TLabel(TLabel(Sender).Owner.Components[I]).Font.Color := clWindowText;
          TLabel(TLabel(Sender).Owner.Components[I]).Font.Style := [];
        end;
      end;
    end;
  end else
  begin
    TLabel(Sender).Font.Color := clWindowText;
    TLabel(Sender).Font.Style := [];
  end;
end;

procedure Tgdc_dlgObjectProperties.FormCreate(Sender: TObject);
begin
  inherited;

  if Assigned(IBLogin) and IBLogin.IsUserAdmin then
  begin
    tsAdditional.TabVisible := True;
    tsAccess.TabVisible := True;
    tsFields.TabVisible := True;
    tsLinks.TabVisible := True;
  end else
  begin
    tsAdditional.TabVisible := False;
    tsAccess.TabVisible := False;
    tsFields.TabVisible := False;
    tsLinks.TabVisible := False;
  end;

  cbOpenDoc.ItemIndex := 0;
end;

procedure Tgdc_dlgObjectProperties.ResizerOnActivate(
  var Activate: Boolean);
begin
  Activate := False;
end;

function Tgdc_dlgObjectProperties.DlgModified: Boolean;
begin
  Result := chbxUpdateChildren.Checked or (inherited DlgModified);
end;

procedure Tgdc_dlgObjectProperties.BuildLinks;
var
  SQL: String;
  q: TIBSQL;
  SL: TStringList;

  procedure BuildSQL(F: TatForeignKey);
  var
    S: String;
  begin
    if (Length(SQL) < 48000)
      and (F.Relation.PrimaryKey <> nil)
      and (F.Relation.PrimaryKey.ConstraintFields.Count = 1)
      and (F.ConstraintFields.Count = 1)
      {and (Pos('''' + F.Relation.RelationName + '''', SQL) = 0)} then
    begin
      S := 'SELECT ' +
        'CAST(''' + F.Relation.RelationName + ''' AS VARCHAR(' + IntToStr(cstMetaDataNameLength) + ')),' +
        F.Relation.PrimaryKey.ConstraintFields[0].FieldName +
        ' FROM ' +
        F.Relation.RelationName +
        ' WHERE ' +
        F.ConstraintFields[0].FieldName +
        '=' +
        IntToStr(gdcObject.ID);

      q.Close;
      q.SQL.Text := S;
      q.ExecQuery;

      if not q.EOF then
      begin
        if SQL = '' then
          SQL := S
        else
          SQL := SQL + ' UNION ' + S;
      end;

      q.Close;
    end;
  end;

  procedure Scan(const TableName: string);
  var
    Lst: TObjectList;
    FK: TatForeignKey;
    PK, PK2: TatPrimaryKey;
    I: Integer;
  begin
    if SL.IndexOf(TableName) = -1 then
      SL.Add(TableName)
    else
      exit;
        
    Lst := TObjectList.Create(False);
    try
      atDatabase.ForeignKeys.ConstraintsByReferencedRelation(
        TableName, Lst);
      for I := 0 to Lst.Count - 1 do
      begin
        FK := Lst[I] as TatForeignKey;
        PK := FK.ReferencesRelation.PrimaryKey;
        PK2 := FK.Relation.PrimaryKey;
        if (PK <> nil) and (PK.ConstraintFields.Count = 1)
          and (FK.ConstraintFields.Count = 1)
          and (PK2 <> nil) and (PK2.ConstraintFields.Count = 1)
          and (PK2.ConstraintFields[0].FieldName = FK.ConstraintFields[0].FieldName) then
        begin
          Scan(FK.Relation.RelationName);
        end else
          BuildSQL(FK);
      end;

    finally
      Lst.Free;
    end;
  end;

begin
  SQL := '';
  SL := TStringList.Create;
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    Scan(gdcObject.GetListTable(gdcObject.SubType));
  finally
    q.Free;
    SL.Free;
  end;

  ibdsLinks.Close;

  if SQL > '' then
  begin
    ibdsLinks.Transaction := gdcBaseManager.ReadTransaction;
    ibdsLinks.SelectSQL.Text := SQL;
    ibdsLinks.Open;
  end;

  if ibdsLinks.Active and (ibgrLinks.Columns.Count > 1) then
  begin
    ibgrLinks.Visible := True;
    ibgrLinks.Columns[0].Visible := True;
    ibgrLinks.Columns[0].Title.Caption := 'Таблица';
    ibgrLinks.Columns[1].Visible := True;
    ibgrLinks.Columns[1].Title.Caption := 'ИД';
  end else
    ibgrLinks.Visible := False;
end;

procedure Tgdc_dlgObjectProperties.actShowLinkObjectUpdate(
  Sender: TObject);
begin
  actShowLinkObject.Enabled :=
    ibdsLinks.Active and (not ibdsLinks.IsEmpty);
end;

procedure Tgdc_dlgObjectProperties.actShowLinkObjectExecute(
  Sender: TObject);

  procedure _Show(const T: String; const AnID: Integer);
  var
    FC: TgdcFullClass;
    Obj: TgdcBase;
  begin
    FC := GetBaseClassForRelationByID(T, AnID,
      gdcBaseManager.ReadTransaction);

    if FC.gdClass <> nil then
    begin
      Obj := FC.gdClass.CreateSubType(nil, FC.SubType, 'ByID');
      try
        Obj.ID := AnID;
        Obj.Open;
        if not Obj.IsEmpty then
        begin
          if (Obj is TgdcDocument) and (not Obj.FieldByName('parent').IsNull)
            and (cbOpenDoc.ItemIndex > 0) then
          begin
            _Show(Obj.GetListTable(Obj.SubType),
              Obj.FieldByName('parent').AsInteger);
          end else
            Obj.EditDialog('');
        end;
        Obj.Close;
      finally
        Obj.Free;
      end;
    end else
      MessageBox(Handle,
        'Не существует бизнес-класса для данной таблицы.',
        'Информация',
        MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
  end;

begin
  _Show(ibdsLinks.Fields[0].AsString, ibdsLinks.Fields[1].AsInteger);
end;


procedure Tgdc_dlgObjectProperties.actGoToMethodsExecute(Sender: TObject);
begin
  ModalResult:= mrCancel;
  if Assigned(EventControl) then
    EventControl.GoToClassMethods(lblClassName.Caption, '');
end;

procedure Tgdc_dlgObjectProperties.actGoToMethodsUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= lblClassName.Caption <> '';
end;

procedure Tgdc_dlgObjectProperties.actGoToMethodsSubtypeExecute(
  Sender: TObject);
begin
  ModalResult:= mrCancel;
  if Assigned(EventControl) then
    EventControl.GoToClassMethods(lblClassName.Caption, lblSubType.Caption);
end;

procedure Tgdc_dlgObjectProperties.actGoToMethodsSubtypeUpdate(
  Sender: TObject);
begin
  TAction(Sender).Enabled:= (lblParentClassName.Caption <> '') and
    (lblSubType.Caption <> '');
end;

procedure Tgdc_dlgObjectProperties.actGoToMethodsParentExecute(
  Sender: TObject);
begin
  ModalResult:= mrCancel;
  if Assigned(EventControl) then
    EventControl.GoToClassMethods(lblParentClassName.Caption, '');
end;

procedure Tgdc_dlgObjectProperties.actGoToMethodsParentUpdate(
  Sender: TObject);
begin
  TAction(Sender).Enabled:= lblParentClassName.Caption <> '';
end;

procedure Tgdc_dlgObjectProperties.actCopyIDToClipboardUpdate(
  Sender: TObject);
begin
  actCopyIDToClipboard.Enabled := pcMain.ActivePage = tsGeneral;
end;

initialization
  RegisterFrmClass(Tgdc_dlgObjectProperties);

finalization
  UnRegisterFrmClass(Tgdc_dlgObjectProperties);
end.
