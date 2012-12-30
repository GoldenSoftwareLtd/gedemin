unit gdc_dlgObjectProperties_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, ComCtrls, IBDatabase, Db, ActnList, StdCtrls,
  gsIBLookupComboBox, Grids, DBGrids, gsDBGrid, gsIBGrid, IBCustomDataSet,
  gdcBase, gdcBaseInterface, gdcUser, DBCtrls, Menus, gd_security, TB2Dock,
  TB2Toolbar, TB2Item, evt_i_base, SynEdit, SynEditHighlighter,
  SynHighlighterGeneral, yaml_parser;

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
    gdcUserGroupID: TIntegerField;
    gdcUserGroupNAME: TIBStringField;
    btnInclude: TButton;
    actExclude: TAction;
    actInclude: TAction;
    Label6: TLabel;
    btnIncludeAll: TButton;
    actIncludeAll: TAction;
    btnExcludeAll: TButton;
    actExcludeAll: TAction;
    tsAdditional: TTabSheet;
    Label24: TLabel;
    lblRecordCount: TLabel;
    Label26: TLabel;
    lblCacheSize: TLabel;
    Button6: TButton;
    actShowSQL: TAction;
    lblParams: TLabel;
    cbParams: TComboBox;
    sbFields: TScrollBox;
    tsFields: TTabSheet;
    sbFields2: TScrollBox;
    chbxUpdateChildren: TCheckBox;
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
    btnClassMethods: TButton;
    actGoToMethods: TAction;
    actGoToMethodsSubtype: TAction;
    btnSubTypeMethods: TButton;
    btnParentMethods: TButton;
    actGoToMethodsParent: TAction;
    mProp: TMemo;
    tsYAML: TTabSheet;
    mYAMLFile: TSynEdit;
    SynGeneralSyn: TSynGeneralSyn;
    bLoad: TButton;
    bSave: TButton;
    actSaveYAML: TAction;
    actLoadYAML: TAction;
    procedure cbAccessClassChange(Sender: TObject);
    procedure actExcludeUpdate(Sender: TObject);
    procedure actExcludeExecute(Sender: TObject);
    procedure actIncludeUpdate(Sender: TObject);
    procedure actIncludeExecute(Sender: TObject);
    procedure actIncludeAllUpdate(Sender: TObject);
    procedure actIncludeAllExecute(Sender: TObject);
    procedure actExcludeAllUpdate(Sender: TObject);
    procedure actExcludeAllExecute(Sender: TObject);
    procedure tsAccessShow(Sender: TObject);
    procedure actShowSQLExecute(Sender: TObject);
    procedure actShowSQLUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actShowLinkObjectUpdate(Sender: TObject);
    procedure actShowLinkObjectExecute(Sender: TObject);
    procedure actGoToMethodsExecute(Sender: TObject);
    procedure actGoToMethodsSubtypeExecute(Sender: TObject);
    procedure actGoToMethodsParentExecute(Sender: TObject);
    procedure actGoToMethodsUpdate(Sender: TObject);
    procedure actGoToMethodsSubtypeUpdate(Sender: TObject);
    procedure actGoToMethodsParentUpdate(Sender: TObject); 
    procedure actSaveYAMLExecute(Sender: TObject);
    procedure actLoadYAMLExecute(Sender: TObject);

  private 
    function GetCurrentSecField(const ATI: TgdcTableInfos = []): TField;

    procedure LabelDblClick(Sender: TObject);
    procedure LabelMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);

    procedure BuildLinks;
    procedure BuildYAML(AStream: TStream); 
    procedure LoadObject(AMapping: TyamlMapping; ATr: TIBTransaction);

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
  ContNrs, at_classes, gdcMetaData, IBUtils, IBSQL, gdcClasses,
  yaml_common, yaml_writer, jclStrings, at_sql_parser;

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

procedure Tgdc_dlgObjectProperties.tsAccessShow(Sender: TObject);
var
  OldCursor: TCursor;
  SS: TStringStream;
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
  end else
  if pcMain.ActivePage = tsYAML then
  begin
    if Assigned(gdcObject) then
    begin
      SS := TStringStream.Create('');
      try
        BuildYAML(SS);
        mYAMLFile.Text := SS.DataString;
      finally
        SS.Free;
      end;
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
            GetCurrentSecField([tiAFull]).AsInteger := GetCurrentSecField([tiAFull]).AsInteger and
              (not AMask);
          if GetCurrentSecField([tiAChag]) <> nil then
            GetCurrentSecField([tiAChag]).AsInteger := GetCurrentSecField([tiAChag]).AsInteger and
              (not AMask);
        end;
      tiAChag:
        if GetCurrentSecField([tiAFull]) <> nil then
          GetCurrentSecField([tiAFull]).AsInteger := GetCurrentSecField([tiAFull]).AsInteger and
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
  Lst: TObjectList;
  FK: TatForeignKey;
  PK, PK2: TatPrimaryKey;
  I: Integer;
  S: String;

  function AddSpaces(const S: String): String;
  begin
    Result := S + StringOfChar(' ', 20 - Length(S));
  end;

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
  with mProp.Lines do
  begin
    Clear;
    Add(AddSpaces('Метка типа:') + gdcObject.GetDisplayName(gdcObject.SubType));
    Add(AddSpaces('Тип объекта:') + gdcObject.ClassName);
    Add(AddSpaces('Тип родителя:') + gdcObject.ClassParent.ClassName);
    Add(AddSpaces('Подтип:') + gdcObject.SubType);
    if gdcObject.Owner is TCustomForm then
    begin
      Add(AddSpaces('Принадлежит форме:') + gdcObject.Owner.Name);
      Add(AddSpaces('Класс формы:') + gdcObject.Owner.ClassName);
    end;
    if gdcObject.GetDlgForm is TCustomForm then
    begin
      Add(AddSpaces('Текущая форма:') + gdcObject.GetDlgForm.Name);
      Add(AddSpaces('Класс тек. формы:') + gdcObject.GetDlgForm.ClassName);
    end;
    Add(AddSpaces('Подмножество:') + gdcObject.SubSet);
    if Trim(gdcObject.ExtraConditions.CommaText) > '' then
      Add(AddSpaces('Доп. условия:') + Trim(gdcObject.ExtraConditions.CommaText));
    Add(AddSpaces('Тип текущей записи:') + gdcObject.GetCurrRecordClass.gdClass.ClassName);
    Add(AddSpaces('Идентификатор:') + IntToStr(gdcObject.ID));
    Add(AddSpaces('RUID:') + RUIDToStr(gdcObject.GetRUID));
    Add(AddSpaces('Наименование:') + gdcObject.ObjectName);
    if gdcObject is TgdcTree then
      Add(AddSpaces('Родитель:') + IntToStr((gdcObject as TgdcTree).Parent));
    if gdcObject is TgdcLBRBTree then
    begin
      Add(AddSpaces('Левая граница:') + IntToStr((gdcObject as TgdcLBRBTree).LB));
      Add(AddSpaces('Правая граница:') + IntToStr((gdcObject as TgdcLBRBTree).RB));
    end;
    Add(AddSpaces('Главная таблица:') + gdcObject.GetListTable(gdcObject.SubType));
    S := '';
    Lst := TObjectList.Create(False);
    try
      atDatabase.ForeignKeys.ConstraintsByReferencedRelation(gdcObject.GetListTable(gdcObject.SubType),
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
          if S > '' then S := S + ', ';
          S := S + FK.Relation.RelationName;
        end;
      end;
    finally
      Lst.Free;
    end;
    if S > '' then Add(AddSpaces('Связанные таблицы:') + S);
    if tiCreationInfo in gdcObject.gdcTableInfos then
    begin
      Add(AddSpaces('Когда создан:') + gdcObject.FieldByName('creationdate').AsString);
      if gdcObject.CreatorName > '' then
        Add(AddSpaces('Кем создан:') + gdcObject.CreatorName);
    end;
    if tiEditionInfo in gdcObject.gdcTableInfos then
    begin
      Add(AddSpaces('Когда изменен:') + gdcObject.FieldByName('editiondate').AsString);
      if gdcObject.EditorName > '' then
        Add(AddSpaces('Кем изменен:') + gdcObject.EditorName);
    end;
    if gdcObject.FindField('aview') <> nil then
      Add(AddSpaces('Только просмотр:') + TgdcUserGroup.GetGroupList(gdcObject.FindField('aview').AsInteger));
    if gdcObject.FindField('achag') <> nil then
      Add(AddSpaces('Просм. и изменение:') + TgdcUserGroup.GetGroupList(gdcObject.FindField('achag').AsInteger));
    if gdcObject.FindField('afull') <> nil then
      Add(AddSpaces('Полный доступ:') + TgdcUserGroup.GetGroupList(gdcObject.FindField('afull').AsInteger));

  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGOBJECTPROPERTIES', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGOBJECTPROPERTIES', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
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
    chbxUpdateChildren.Visible := gdcObject is TgdcTree;

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
  EventControl.GoToClassMethods(gdcObject.ClassName, '');
end;

procedure Tgdc_dlgObjectProperties.actGoToMethodsUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= (gdcObject <> nil) and (EventControl <> nil)
    and IBLogin.IsIBUserAdmin;
end;

procedure Tgdc_dlgObjectProperties.actGoToMethodsSubtypeExecute(
  Sender: TObject);
begin
  ModalResult:= mrCancel;
  EventControl.GoToClassMethods(gdcObject.ClassName, gdcObject.SubType);
end;

procedure Tgdc_dlgObjectProperties.actGoToMethodsSubtypeUpdate(
  Sender: TObject);
begin
  TAction(Sender).Enabled:= (gdcObject <> nil) and (EventControl <> nil)
    and (gdcObject.SubType > '')
    and IBLogin.IsIBUserAdmin;
end;

procedure Tgdc_dlgObjectProperties.actGoToMethodsParentExecute(
  Sender: TObject);
begin
  ModalResult:= mrCancel;
  EventControl.GoToClassMethods(gdcObject.ClassParent.ClassName, '');
end;

procedure Tgdc_dlgObjectProperties.actGoToMethodsParentUpdate(
  Sender: TObject);
begin
  TAction(Sender).Enabled:= (gdcObject <> nil) and (EventControl <> nil)
    and IBLogin.IsIBUserAdmin;
end;

procedure Tgdc_dlgObjectProperties.BuildYAML(AStream: TStream);

  function AddSpaces(const Name: String): String;
  begin
    Result := Name + StringOfChar(' ', 20 - Length(Name));
  end;

  function BinToHexString(Source: AnsiString): string;
  const
    DefSymbol = 16;
  var
    I: Integer;
  begin
    Result := '';
    for I := 1 to Length(Source) do
    begin
      Result := Result + IntToHex(Ord(Source[I]), 2) + #32;
      if (I mod DefSymbol) = 0 then
        Result := Result + #13#10;
    end;

    if Length(Source) mod DefSymbol = 0 then
      SetLength(Result, Length(Result) - 3)
    else
      SetLength(Result, Length(Result) - 1);
  end;

  procedure AddSet(AObj: TgdcBase; AWriter: TyamlWriter);
  var
    I, K: Integer;
    F, FD: TatRelationField;
    AddedTitle: Boolean;
    q: TIBSQL;
    RL, LT: TStrings;
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      AddedTitle := False;

      RL := TStringList.Create;
      try
        if AObj.GetListTable(AObj.SubType) <> '' then
          RL.Add(AnsiUpperCase(AObj.GetListTable(AObj.SubType)));

        LT := TStringList.Create;
        try
          (LT as TStringList).Duplicates := dupIgnore;
          GetTablesName(AObj.SelectSQL.Text, LT);
          for I := 0 to LT.Count - 1 do
          begin
            if (RL.IndexOf(LT[I]) = -1)
              and AObj.ClassType.InheritsFrom(GetBaseClassForRelation(LT[I]).gdClass)
            then
              RL.Add(LT[I]);
          end;
        finally
          LT.Free;
        end;

        for I := 0 to atDatabase.PrimaryKeys.Count - 1 do
          with atDatabase.PrimaryKeys[I] do
          if ConstraintFields.Count > 1 then
          begin
            F := nil;
            FD := nil;

            for K := 0 to RL.Count - 1 do
            begin
              if (ConstraintFields[0].References <> nil) and
                (AnsiCompareText(ConstraintFields[0].References.RelationName,
                 RL[K]) = 0)
              then
              begin
                F := ConstraintFields[0];
                Break;
              end;
            end;

            if not Assigned(F) then
              continue;

            for K := 1 to ConstraintFields.Count - 1 do
            begin
              if (ConstraintFields[K].References <> nil) and
                 (ConstraintFields[K] <> F) and (FD = nil)
              then
              begin
                FD := ConstraintFields[K];
                Break;
              end else

              if (ConstraintFields[K].References <> nil) and
                 (ConstraintFields[K] <> F) and (FD <> nil)
              then
              begin
                continue;
              end;
            end;

            if not Assigned(FD) then
              continue;

              q.Close;
              q.SQL.Text := 'SELECT ' + FD.FieldName +
                ' FROM ' + FD.Relation.RelationName +
                ' WHERE ' + F.FieldName + ' = ' + AObj.FieldByName(F.ReferencesField.FieldName).AsString;
              q.ExecQuery;

              if q.RecordCount > 0 then
              begin
                if not AddedTitle then
                begin
                  AddedTitle := True;
                  AWriter.StartNewLine;
                  AWriter.WriteKey('$Set');
                  AWriter.IncIndent;
                end;

                AWriter.StartNewLine;
                AWriter.WriteKey('Table');
                AWriter.WriteString(FD.Relation.RelationName);

                AWriter.StartNewLine;
                AWriter.WriteKey('Items');

                AWriter.IncIndent;
                while not q.Eof do
                begin
                  AWriter.StartNewLine;
                  AWriter.WriteSequenceIndicator;
                  AWriter.WriteString(gdcBaseManager.GetRUIDStringByID(q.Fields[0].AsInteger, AObj.Transaction));
                  q.Next;
                end;
                AWriter.DecIndent;

                if AddedTitle then
                  AWriter.DecIndent;
              end;
          end;
        finally
          RL.Free;
        end;
    finally
      q.Free;
    end;
  end;

const
  PassFieldName = ';ID;EDITIONDATE;CREATIONDATE;CREATORKEY;EDITORKEY;ACHAG;AVIEW;AFULL;LB;RB;';
var
  I, L: Integer;
  R: TatRelation;
  F: TField;
  FN: String;
  RF: TatRelationField;
  FK: TatForeignKey;
  RN: String;
  Writer: TyamlWriter;
  C: TgdcFullClass;
  Obj: TgdcBase;
  q: TIBSQL;
begin
  q := TIBSQL.Create(nil);
  Writer := TyamlWriter.Create(AStream);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    C := gdcObject.GetCurrRecordClass;
    Writer.WriteDocumentStart;
    Writer.StartNewLine;
    Writer.WriteKey(AddSpaces('$ObjectClass'));
    Writer.WriteString(C.gdClass.Classname);
    if C.SubType <> '' then
    begin
      Writer.StartNewLine;
      Writer.WriteKey(AddSpaces('$SubType'));
      Writer.WriteText(C.SubType);
    end;
    Writer.StartNewLine;
    Writer.WriteKey(AddSpaces('$RUID'));
    Writer.WriteString(gdcBaseManager.GetRUIDStringByID(gdcObject.ID, gdcObject.Transaction));

    for I := 0 to gdcObject.Fields.Count - 1 do
    begin
      FN := '';

      F := gdcObject.Fields[I];
      if (StrIPos(F.FieldName, PassFieldName) > 0) or F.IsNull then
      begin
        continue;
      end else
        if (F.Origin > '') then
        begin
          L := 0;
          RN := '';
          while F.Origin[L] <> '.' do
          begin
            if F.Origin[L] <> '"' then
              RN := RN + F.Origin[L];
            Inc(L);
          end;

          if RN > '' then
          begin
            R := atDatabase.Relations.ByRelationName(RN);
            if Assigned(R) then
            begin
              RF := R.RelationFields.ByFieldName(F.FieldName);
              if Assigned(RF) then
              begin
                if Assigned(RF.CrossRelation) then
                begin
                  continue;
                end else
                if Assigned(RF.ForeignKey) then
                begin
                  FK := RF.ForeignKey;

                  if FK.IsSimpleKey and Assigned(FK.Relation.PrimaryKey)
                    and (FK.Relation.PrimaryKey.ConstraintFields.Count = 1)
                    and (FK.ConstraintField = FK.Relation.PrimaryKey.ConstraintFields[0])
                  then
                    continue;

                  C := GetBaseClassForRelation(RF.References.RelationName);
                  if C.gdClass <> nil then
                  begin
                    Obj := C.gdClass.CreateWithID(nil,
                      nil,
                      nil,
                      F.AsInteger,
                      C.SubType);
                    try
                      Obj.Open;
                      if (Obj.RecordCount > 0) and (Obj.GetListField(Obj.SubType) <> '') then
                      begin
                        if Obj is TgdcTree then
                        begin
                          FN := TgdcTree(Obj).GetPath
                        end else
                          FN := Obj.FieldByName(Obj.GetListField(Obj.SubType)).AsString;
                      end;
                    finally
                      Obj.Free;
                    end;
                  end;

                  Writer.StartNewLine;
                  Writer.WriteKey(AddSpaces(F.FieldName));
                  Writer.WriteString(gdcBaseManager.GetRUIDStringByID(F.AsInteger, gdcObject.Transaction));
                  Writer.WriteChar(' ');
                  Writer.WriteText(FN, qSingleQuoted);
                  continue;
                end;
              end;
            end;
          end;
        end;

        Writer.StartNewLine;
        Writer.WriteKey(AddSpaces(F.FieldName));
        case F.DataType of
          ftDate: Writer.WriteDate(F.AsDateTime);
          ftDateTime: Writer.WriteTimestamp(F.AsDateTime);
          ftMemo: Writer.WriteText(F.AsString, qPlain, sLiteral);
          ftBlob, ftGraphic: Writer.WriteText(BinToHexString(F.AsString), qPlain, sFolded);
          ftInteger, ftLargeint, ftSmallint, ftWord: Writer.WriteInteger(F.AsInteger);
          ftBoolean: Writer.WriteBoolean(F.AsBoolean);
          ftFloat, ftCurrency: Writer.WriteFloat(F.AsFloat);
        else
          Writer.WriteText(F.AsString, qSingleQuoted);
        end;

    end;

    AddSet(gdcObject, Writer);

    Writer.StartNewLine;
    Writer.WriteDocumentEnd;
    Writer.StartNewLine;
  finally
    q.Free;
    Writer.Free;
  end;
end;

procedure Tgdc_dlgObjectProperties.actSaveYAMLExecute(Sender: TObject);
var
  Stream: TFileStream;
begin
  with TSaveDialog.Create(Self) do
  try
    DefaultExt := '*.yml';
    Filter := '*.yml|*.yml';
    Title := 'Сохранить объект в файл.';
    if Execute then
    begin
      if
        not FileExists(FileName)
          or
        (MessageBox(Handle, PChar(Format('Заменить существующий файл %s?', [FileName])),
          'Внимание', MB_YESNO or MB_ICONQUESTION) = ID_YES)
      then
      try
        Stream := TFileStream.Create(FileName, fmCreate);

        try
          BuildYAML(Stream);
        finally
          Stream.Free;
        end;
      except
        raise EgsDBGridException.Create(Format('Can''t write to file %s', [FileName]));
      end;
    end;
  finally
    Free;
  end;

end;

procedure Tgdc_dlgObjectProperties.actLoadYAMLExecute(Sender: TObject);
var
  FS: TFileStream;
  Parser: TyamlParser;
  D: TyamlDocument;
  I: Integer;
  Transaction: TIBTransaction;
begin
  with TOpenDialog.Create(Self) do
  try
    DefaultExt := '*.yml';
    Filter := '*.yml|*.yml';
    Title := 'Загрузить объект из файла.';
    if Execute then
    begin
      try
        FS := TFileStream.Create(FileName, fmOpenRead);
        Parser := TyamlParser.Create;
        Transaction := TIBTransaction.Create(nil);
        try
          Transaction.DefaultDatabase := IBLogin.Database;
          Transaction.StartTransaction;
          try

            Parser.Parse(FS);
            for I := 0 to Parser.YAMLStream.Count - 1 do
            begin
              D := Parser.YAMLStream[I] as TyamlDocument;
              if (D[0] is TyamlMapping) then
                LoadObject(D[0] as TyamlMapping, Transaction)
              else
                raise Exception.Create('Invalid object!');
            end;

            if Transaction.InTransaction then
              Transaction.Commit;
          except
            on E: Exception do
            begin
              if Transaction.InTransaction then
                Transaction.Rollback;
              raise;
            end;
          end;
        finally
          Parser.Free;
          FS.Free;
          Transaction.Free;
        end;

       { Stream := TFileStream.Create(FileName, fmOpenRead);
        Parser := TyamlParser.Create;
        try
          Parser.Parse(Stream);
          CreateObject(Parser.YAMLStream[0] as TyamlDocument);
        finally
          Parser.Free;
          Stream.Free;
        end;  }
      except
        raise EgsDBGridException.Create(Format('Can''t read from file %s', [FileName]));
      end;
    end;
  finally
    Free;
  end;

end;

procedure Tgdc_dlgObjectProperties.LoadObject(AMapping: TyamlMapping; ATr: TIBTransaction);

  function HexStringToBin(const HexStr: AnsiString): String;
  var
    I: Integer;
  begin
    SetLength(Result, round(Length(HexStr)/2));
    I := HexToBin(PAnsiChar(HexStr), PAnsiChar(Result), Length(result));
    SetLength(Result, I);
  end;

  procedure LoadSet(AValue: TyamlMapping; AnID: Integer; ATransaction: TIBTransaction);
  var
    RN: String;
    I, J: Integer;
    q: TIBSQL;
    R: TatRelation;
    Items: TyamlSequence;
    ID: Integer;
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := ATransaction;

      RN := '';
      for I := 0 to AValue.Count - 1 do
      begin
        if (AValue[I] as TyamlKeyValue).Key = 'Table' then
        begin
          RN := ((AValue[I] as TyamlKeyValue).Value as TyamlScalar).AsString;
          if RN = '' then
            raise Exception.Create('Table not found!');
          continue;
        end else
        if (AValue[I] as TyamlKeyValue).Key = 'Items' then
        begin
          R := atDatabase.Relations.ByRelationName(RN);
          if Assigned(R) then
          begin
            q.Close;
            q.SQl.Text := 'INSERT INTO ' + RN + '(' + R.PrimaryKey.ConstraintFields[0].FieldName +
              ', ' + R.PrimaryKey.ConstraintFields[1].FieldName + ') VALUES(:id1, :id2)';

            if not ((AValue[I] as TyamlKeyValue).Value is TyamlSequence) then
              raise Exception.Create('Invalid set object!');

            Items := (AValue[I] as TyamlKeyValue).Value as TyamlSequence;

            for J := 0 to Items.Count - 1 do
            begin
              if not (Items[J] is TyamlScalar) then
                raise Exception.Create('Invalid data!');

              ID := gdcBaseManager.GetIDByRUIDString((Items[J] as TyamlScalar).AsString, ATransaction);
              if ID > 0 then
              begin
                q.Close;
                q.ParamByName('id1').AsInteger := AnID;
                q.ParambyName('id2').AsInteger := ID;
                q.ExecQuery;
              end else
                raise Exception.Create('Id not found!');
            end;
          end else
            raise Exception.Create('Table ''' +  RN + ''' not found in databese!');

          RN := '';
        end;
      end;
    finally
      q.Free;
    end;
  end;

var
  I, K: Integer;
  SubType, ClassName: string;
  Obj: TgdcBase;
  RN, Temps: String;
  ID: Integer;
  F: TField;
  L: Integer;
  R: TatRelation;
  RF: TatRelationField;
  Value: TyamlNode;
  RUID: String;
  RuidRec: TRuidRec;
begin
  Assert(ATr <> nil);
  Assert(gdcBaseManager <> nil);
  Assert(AMapping <> nil);

  ClassName := AMapping.ReadString('$ObjectClass');
  SubType := AMapping.ReadString('$SubType');
  RUID := AMapping.ReadString('$RUID');

  if (ClassName = '') or (RUID = '') then
   raise Exception.Create('Invalid object!');


  Obj := CgdcBase(GetClass(ClassName)).CreateWithParams(nil, ATr.DefaultDatabase, ATr, SubType);
  try
   RuidRec := gdcBaseManager.GetRUIDRecByXID(StrToRUID(RUID).XID, StrToRUID(RUID).DBID, ATr);
   if RuidRec.ID > 0 then
   begin
     Obj.Subset := 'ByID';
     Obj.ID := RuidRec.ID;
     Obj.Open;
     if Obj.RecordCount = 0 then
     begin
       gdcBaseManager.DeleteRUIDbyXID(RuidRec.XID, RuidRec.DBID, ATr);
       Obj.Insert;
     end else
       Obj.Edit;
   end else
   begin
     Obj.Open;
     Obj.Insert;
   end;

   for I := 0 to Obj.Fields.Count - 1 do
   begin
     F := Obj.Fields[I];
     Value := AMapping.FindByName(F.FieldName);
     if Value <> nil then
     begin
       if not (Value is TyamlScalar) then
         raise Exception.Create('Invalid data!');

       if (F.Origin > '') then
       begin
         L := 0;
         RN := '';
         while F.Origin[L] <> '.' do
         begin
           if F.Origin[L] <> '"' then
             RN := RN + F.Origin[L];
           Inc(L);
         end;

         if RN > '' then
         begin
           R := atDatabase.Relations.ByRelationName(RN);
           if Assigned(R) then
           begin
             RF := R.RelationFields.ByFieldName(F.FieldName);
             if Assigned(RF) and Assigned(RF.ForeignKey)then
             begin
               Temps := (Value as TyamlScalar).AsString;
               RUID := '';
               for K := 1 to Length(Temps) do
               begin
                 if not CharIsDigit(Temps[K]) and (Temps[K] <> '_') then
                   break;
                 RUID := RUID + Temps[K];
               end;

               if (RUID > '') and (CheckRUID(RUID)) then
               begin
                 ID := gdcBaseManager.GetIDByRUIDString(RUID, ATr);
                 if ID > 0 then
                 begin
                   Obj.FieldByName(F.FieldName).AsInteger := ID;
                   continue;
                 end
                 else
                   raise Exception.Create('Id not found!');
               end else
                 raise Exception.Create('Invalid RUID!');
             end;
           end;
         end;
       end;
       case F.DataType of
         ftDateTime: Obj.FieldByName(F.FieldName).AsDateTime := (Value as TyamlDateTime).AsDateTime;
         ftDate: Obj.FieldByName(F.FieldName).AsDateTime := (Value as TyamlDate).AsDate;
         ftInteger, ftLargeint, ftSmallint, ftWord: Obj.FieldByName(F.FieldName).AsInteger := (Value as TyamlScalar).AsInteger;
         ftFloat, ftCurrency: Obj.FieldByName(F.FieldName).AsFloat := (Value as TyamlScalar).AsFloat;
         ftBlob, ftGraphic:
         begin
           Temps := (Value as TyamlScalar).AsString;
           Temps := StringReplace(Temps, #32, '', [rfReplaceAll]);
           Obj.FieldByName(F.FieldName).AsString := HexStringToBin(Temps);
         end;
       else
         Obj.FieldByName(F.FieldName).AsString := Trim((Value as TyamlScalar).AsString);
       end;
     end;
   end;

   Obj.Post;

    if gdcBaseManager.GetRUIDRecByID(Obj.ID, ATr).XID = -1 then
    begin
      gdcBaseManager.InsertRUID(Obj.ID, RuidRec.XID,
        RuidRec.DBID,
        Now, IBLogin.ContactKey, ATr);
    end else
    begin 
      gdcBaseManager.UpdateRUIDByID(Obj.ID, RuidRec.XID,
        RuidRec.DBID,
        Now, IBLogin.ContactKey, ATr);
    end;

   Value := AMapping.FindByName('$Set');
   if (Value <> nil) and (Value is TyamlMapping) then
     LoadSet(Value as TyamlMapping, Obj.ID, ATr);

  finally
   Obj.Free;
  end; 
end; 

initialization
  RegisterFrmClass(Tgdc_dlgObjectProperties);

finalization
  UnRegisterFrmClass(Tgdc_dlgObjectProperties);
end.
