
unit gdc_attr_frmSetting_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcSetting, gdc_frmG_unit,
  gdc_frmMDHGR_unit, IBSQL, gd_KeyAssoc, at_SettingWalker;

type
  Tgdc_frmSetting = class(Tgdc_frmMDHGR)
    gdcSetting: TgdcSetting;
    gdcSettingPos: TgdcSettingPos;
    actSetActive: TAction;
    tbiSetActive: TTBItem;
    tbiSetOrder: TTBItem;
    actSetOrder: TAction;
    tbsiCustomOne: TTBSeparatorItem;
    tbiSaveToBlob: TTBItem;
    actSaveToBlob: TAction;
    gdcSettingStorage: TgdcSettingStorage;
    pnlStorage: TPanel;
    TBDockStorage: TTBDock;
    tbStorageToolbar: TTBToolbar;
    tbiStorageDelete: TTBItem;
    tbsStorage: TTBSeparatorItem;
    tbiStorageFind: TTBItem;
    tbiStorageFilter: TTBItem;
    pnlStorageFind: TPanel;
    sbSearchStorage: TScrollBox;
    pnlSearchStorageButton: TPanel;
    btnSearchStorage: TButton;
    btnSearchStorageClose: TButton;
    ibgrStorage: TgsIBGrid;
    spltStorrage: TSplitter;
    dsStorage: TDataSource;
    actStorageDelete: TAction;
    actStorageFind: TAction;
    actStorageFilter: TAction;
    actSearchStorageClose: TAction;
    actSearchStorage: TAction;
    pmStorage: TPopupMenu;
    actAddForm: TAction;
    tbiStorageAdd: TTBItem;
    actWithDetail: TAction;
    tbiWithDetail: TTBItem;
    actReActivate: TAction;
    actValidPos: TAction;
    tbiReActivate: TTBItem;
    tbiValidPos: TTBItem;
    actValidStorage: TAction;
    tbiValidStorage: TTBItem;
    tbsStorage2: TTBSeparatorItem;
    actChooseSetings: TAction;
    tbiChooseSettings: TTBItem;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    TBItem3: TTBItem;
    TBItem4: TTBItem;
    TBItem5: TTBItem;
    TBSeparatorItem3: TTBSeparatorItem;
    TBItem6: TTBItem;
    TBItem7: TTBItem;
    actNeedModify: TAction;
    tbiNeedModify: TTBItem;
    actNeedModifyDefault: TAction;
    tbiNeedModifyDefault: TTBItem;
    actSettingView: TAction;
    tbsCustomTwo: TTBSeparatorItem;
    tbiSettingView: TTBItem;
    tbsiStorage: TTBSubmenuItem;
    tbiFindStorage: TTBItem;
    tbiNewForm: TTBItem;
    tbsStorageTwo: TTBSeparatorItem;
    tbiStorageValid: TTBItem;
    tbiDeleteStorage: TTBItem;
    tbiFilterStorage: TTBItem;
    tbsStorageOne: TTBSeparatorItem;
    tbiDetailNeedModifyDefault: TTBItem;
    tbiDetailNeedModify: TTBItem;
    tbiMainSettingView: TTBItem;
    tbsiServiceMain: TTBSubmenuItem;
    actOpenObject: TAction;
    tbiOpenObject: TTBItem;
    tbimOpenObject: TTBItem;
    actClearDependencies: TAction;
    tbiClearDependencies: TTBItem;
    actAddMissed: TAction;
    TBItem8: TTBItem;
    actSet2Txt: TAction;
    TBItem9: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure actDetailNewExecute(Sender: TObject);
    procedure actSetActiveExecute(Sender: TObject);
    procedure actSetActiveUpdate(Sender: TObject);
    procedure actSetOrderExecute(Sender: TObject);
    procedure actDetailNewUpdate(Sender: TObject);
    procedure actSetOrderUpdate(Sender: TObject);
    procedure actSaveToBlobExecute(Sender: TObject);
    procedure actSaveToBlobUpdate(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actStorageDeleteExecute(Sender: TObject);
    procedure actStorageDeleteUpdate(Sender: TObject);
    procedure actStorageFindExecute(Sender: TObject);
    procedure actStorageFindUpdate(Sender: TObject);
    procedure actStorageFilterExecute(Sender: TObject);
    procedure actStorageFilterUpdate(Sender: TObject);
    procedure actSearchStorageCloseExecute(Sender: TObject);
    procedure actSearchStorageExecute(Sender: TObject);
    procedure ibgrStorageEnter(Sender: TObject);
    procedure actDetailEditExecute(Sender: TObject);
    procedure actDetailDuplicateExecute(Sender: TObject);
    procedure actDetailCopyExecute(Sender: TObject);
    procedure actDetailPasteExecute(Sender: TObject);
    procedure actMainToSettingUpdate(Sender: TObject);
    procedure actDetailToSettingUpdate(Sender: TObject);
    procedure actAddFormExecute(Sender: TObject);
    procedure actAddFormUpdate(Sender: TObject);
    procedure actWithDetailUpdate(Sender: TObject);
    procedure actWithDetailExecute(Sender: TObject);
    procedure actReActivateUpdate(Sender: TObject);
    procedure actReActivateExecute(Sender: TObject);
    procedure actValidPosUpdate(Sender: TObject);
    procedure actValidPosExecute(Sender: TObject);
    procedure actValidStorageUpdate(Sender: TObject);
    procedure actValidStorageExecute(Sender: TObject);
    procedure actChooseSetingsExecute(Sender: TObject);
    procedure actChooseSetingsUpdate(Sender: TObject);
    procedure actNeedModifyExecute(Sender: TObject);
    procedure actNeedModifyUpdate(Sender: TObject);
    procedure actNeedModifyDefaultExecute(Sender: TObject);
    procedure actNeedModifyDefaultUpdate(Sender: TObject);
    procedure actSettingViewExecute(Sender: TObject);
    procedure actSettingViewUpdate(Sender: TObject);
    procedure actOpenObjectUpdate(Sender: TObject);
    procedure actOpenObjectExecute(Sender: TObject);
    procedure actLoadFromFileExecute(Sender: TObject);
    procedure actClearDependenciesExecute(Sender: TObject);
    procedure actClearDependenciesUpdate(Sender: TObject);
    procedure actAddMissedExecute(Sender: TObject);
    procedure actAddMissedUpdate(Sender: TObject);
    procedure actSet2TxtExecute(Sender: TObject);
    procedure actSet2TxtUpdate(Sender: TObject);
    procedure ibgrDetailDblClick(Sender: TObject);

  private
    FFieldStorageOrigin: TStringList;
    FThirdPreservedConditions: String;

    {$IFNDEF NEW_STREAM}
    FIBSQLSelectPos, FIBSQLSelectAllPos, FIBSQLUpdatePos, FIBSQLInsertPos: TIBSQL;
    Offset: Integer;
    {$ENDIF}

    SList, SCount, SDiff, SCRC32: TStringList;
    DontSave, UseRUID, SaveDependencies, DontSaveBLOB,
      OnlyDup, OnlyDiff: Boolean;
    IDLink: TgdKeyStringAssoc;
    Pass: Integer;
    FakeStream: TStream;
    FakeRUIDList, FakeName: String;

    {$IFNDEF NEW_STREAM}
    procedure OnStartLoading(Sender: TatSettingWalker; AnObjectSet: TgdcObjectSet);
    procedure OnObjectLoad(Sender: TatSettingWalker; const AClassName, ASubType: String;
      ADataSet: TDataSet; APrSet: TgdcPropertySet;
      const ASR: TgsStreamRecord);
    {$ENDIF}

    procedure OnStartLoading2(Sender: TatSettingWalker;
      AnObjectSet: TgdcObjectSet);
    procedure OnObjectLoad2(Sender: TatSettingWalker;
      const AClassName, ASubType: String;
      ADataSet: TDataSet; APrSet: TgdcPropertySet;
      const ASR: TgsStreamRecord);

    procedure OnFakeLoad(Sender: TgdcBase; CDS: TDataSet);

  protected
    procedure RemoveSubSetList(S: TStrings); override;

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  gdc_frmSetting: Tgdc_frmSetting;

implementation

uses
  gd_ClassList, gdcBaseInterface, at_frmUserForm_unit,
  gd_directories_const, Storages, frm_SettingView_unit,
  gd_security, gd_common_functions, jclSelected,
  IBDatabase, gdc_attr_dlgSetToTxt_unit, ShellAPI
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  {$IFDEF NEW_STREAM}
  , gdc_frmStreamSaver
  {$ENDIF}
  ;
  
{$R *.DFM}

{ Tgdc_frmSetting }

class function Tgdc_frmSetting.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmSetting) then
    gdc_frmSetting := Tgdc_frmSetting.Create(AnOwner);
  Result := gdc_frmSetting;
end;

procedure Tgdc_frmSetting.FormCreate(Sender: TObject);
begin
  gdcObject := gdcSetting;
  gdcDetailObject := gdcSettingPos;
  inherited;
end;

procedure Tgdc_frmSetting.actDetailNewExecute(Sender: TObject);
begin
  if gdcDetailObject is TgdcSettingPos then
    (gdcDetailObject as TgdcSettingPos).ChooseNewItem;
end;

procedure Tgdc_frmSetting.actSetActiveExecute(Sender: TObject);
begin
  if Assigned(IBLogin) and (not IBLogin.IsIBUserAdmin) then
  begin
    MessageBox(Handle,
      'Активация/деактивация настройки возможна только под учетной записью Administrator.',
      'Отсутствуют права',
      MB_OK or MB_ICONHAND);
    exit;
  end;

  if not actSetActive.Checked then
  begin
    {$IFDEF NEW_STREAM}
    CreateStreamSaverForm;
    frmStreamSaver.SetParams(gdcObject, nil, GetMainBookmarkList);
    frmStreamSaver.ShowActivateSettingForm;
    {$ELSE}
    if MessageBox(Handle, PChar('Активировать настройку "' + gdcObject.FieldByName('name').AsString + '"?'),
      'Активация настройки', MB_ICONQUESTION or MB_YESNO) = IDYES
    then
    begin
      (gdcObject as TgdcSetting).ActivateSetting(nil, GetMainBookmarkList)
    end;
    {$ENDIF}

  end
  else
  begin
    {$IFDEF NEW_STREAM}
    CreateStreamSaverForm;
    frmStreamSaver.SetParams(gdcObject);
    frmStreamSaver.ShowDeactivateSettingForm;
    {$ELSE}
    if MessageBox(Handle, PChar('Деактивировать настройку ' + gdcObject.FieldByName('name').AsString + ' ?'),
      'Деактивация настройки', MB_ICONQUESTION or MB_YESNO) = IDYES
    then
    begin
      (gdcObject as TgdcSetting).DeactivateSetting;
    end;
    {$ENDIF}
  end;
end;

procedure Tgdc_frmSetting.actSetActiveUpdate(Sender: TObject);
begin
  actSetActive.Enabled := (gdcObject.Active) and (gdcObject.RecordCount > 0);
  actSetActive.Checked := actSetActive.Enabled and(gdcObject.FieldByName('Disabled').AsInteger = 0);
  if not actSetActive.Checked then
    actSetActive.Hint := 'Активировать настройку'
  else
    actSetActive.Hint := 'Деактивировать настройку';
end;

procedure Tgdc_frmSetting.actSetOrderExecute(Sender: TObject);
begin
  (gdcObject as TgdcSetting).MakeOrder;
end;

procedure Tgdc_frmSetting.actDetailNewUpdate(Sender: TObject);
begin
  actDetailNew.Enabled := Assigned(gdcObject) and Assigned(gdcDetailObject) and
    (gdcObject.RecordCount > 0) and (gdcDetailObject.Active) and
    (gdcObject.FieldByName('disabled').AsInteger = 0);
end;

procedure Tgdc_frmSetting.actSetOrderUpdate(Sender: TObject);
begin
  actSetOrder.Enabled := Assigned(gdcObject) and Assigned(gdcDetailObject) and
    (gdcObject.RecordCount > 0) and (gdcDetailObject.Active) and
    (gdcDetailObject.RecordCount > 0);
end;

procedure Tgdc_frmSetting.actSaveToBlobExecute(Sender: TObject);
begin
  {$IFDEF NEW_STREAM}
  CreateStreamSaverForm;
  frmStreamSaver.SetParams(gdcObject);
  frmStreamSaver.ShowMakeSettingForm;
  // Переоткроем детальный датасет, т.к. могли быть добавлены скрытые позиции
  gdcDetailObject.CloseOpen;
  {$ELSE}
  if MessageBox(Self.Handle, PChar('Сформировать настройку "' +
    gdcObject.FieldByName(gdcObject.GetListField(gdcObject.SubType)).AsString + '" из выбранных объектов?'), 'Внимание',
    MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDYES then
  begin
    (gdcObject as TgdcSetting).SaveSettingToBlob;
  end;
  {$ENDIF}
end;

procedure Tgdc_frmSetting.actSaveToBlobUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (gdcObject <> nil) and (gdcObject.RecordCount > 0) and
    (gdcObject.FieldByName('disabled').AsInteger = 0);
end;

procedure Tgdc_frmSetting.actSaveToFileExecute(Sender: TObject);
begin
  {$IFDEF NEW_STREAM}
  CreateStreamSaverForm;
  frmStreamSaver.SetParams(gdcObject, gdcDetailObject, GetMainBookmarkList);
  frmStreamSaver.ShowSaveSettingForm;
  {$ELSE}
  actSaveToBlob.Execute;
  inherited;
  {$ENDIF}
end;

procedure Tgdc_frmSetting.actStorageDeleteExecute(Sender: TObject);
begin
  gdcSettingStorage.DeleteMultiple(ibgrStorage.SelectedRows);
end;

procedure Tgdc_frmSetting.actStorageDeleteUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (gdcSettingStorage <> nil) and
    (gdcSettingStorage.RecordCount > 0) and
    (gdcSettingStorage.CanDelete) and
    (gdcSettingStorage.State = dsBrowse);
end;

procedure Tgdc_frmSetting.actStorageFindExecute(Sender: TObject);
begin
  if pnlStorageFind.Visible then
  begin
    actSearchStorageClose.Execute;
    exit;
  end;

  SetupSearchPanel(gdcSettingStorage,
    pnlStorageFind,
    sbSearchStorage,
    nil{sSearchMain},
    FFieldStorageOrigin,
    FThirdPreservedConditions);
end;

procedure Tgdc_frmSetting.actStorageFindUpdate(Sender: TObject);
begin
  actStorageFind.Enabled := gdcSettingStorage <> nil;
  actStorageFind.Checked := pnlStorageFind.Visible;
end;

procedure Tgdc_frmSetting.actStorageFilterExecute(Sender: TObject);
var
  R: TRect;
begin
  with tbStorageToolbar do
  begin
    R := View.Find(tbiStorageFilter).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;
  gdcSettingStorage.PopupFilterMenu(R.Left, R.Bottom);
end;

procedure Tgdc_frmSetting.actStorageFilterUpdate(Sender: TObject);
begin
  actStorageFilter.Enabled := (gdcSettingStorage <> nil) and (gdcSettingStorage.State = dsBrowse);
end;

procedure Tgdc_frmSetting.actSearchStorageCloseExecute(Sender: TObject);
begin
  gdcSettingStorage.ExtraConditions.Text := FThirdPreservedConditions;

  pnlStorageFind.Visible := False;
end;

procedure Tgdc_frmSetting.actSearchStorageExecute(Sender: TObject);
begin
  SearchExecute(gdcSettingStorage, pnlStorageFind, FFieldStorageOrigin,
    FThirdPreservedConditions);
end;

procedure Tgdc_frmSetting.ibgrStorageEnter(Sender: TObject);
begin
//Переделано, т.к.стандарьные формы рассчитаны на один мастер и один дитейл

  actStorageDelete.ShortCut := TextToShortCut(scDelete);

  actDetailNew.ShortCut := 0;
  actDetailEdit.ShortCut := 0;
  actDetailDelete.ShortCut := 0;
  actDetailDuplicate.ShortCut := 0;
  actDetailPrint.ShortCut := 0;
  actDetailCut.ShortCut := 0;
  actDetailCopy.ShortCut := 0;
  actDetailPaste.ShortCut := 0;
  actDetailReduction.ShortCut := 0;

  actNew.ShortCut := 0;
  actEdit.ShortCut := 0;
  actDelete.ShortCut := 0;
  actDuplicate.ShortCut := 0;
  actPrint.ShortCut := 0;
  actCut.ShortCut := 0;
  actCopy.ShortCut := 0;
  actPaste.ShortCut := 0;
  actMainReduction.ShortCut := 0;

end;
// Перекрыт
procedure Tgdc_frmSetting.actDetailEditExecute(Sender: TObject);
begin
end;
// Перекрыт
procedure Tgdc_frmSetting.actDetailDuplicateExecute(Sender: TObject);
begin
end;
// Перекрыт
procedure Tgdc_frmSetting.actDetailCopyExecute(Sender: TObject);
begin
end;
// Перекрыт
procedure Tgdc_frmSetting.actDetailPasteExecute(Sender: TObject);
begin
end;
// Перекрыт

procedure Tgdc_frmSetting.actMainToSettingUpdate(Sender: TObject);
begin
  actMainToSetting.Enabled := False;
end;

procedure Tgdc_frmSetting.actDetailToSettingUpdate(Sender: TObject);
begin
  actDetailToSetting.Enabled := False;
end;

procedure Tgdc_frmSetting.actAddFormExecute(Sender: TObject);
begin
  with Tat_frmUserForm.Create(nil) do
  try
    if Visible then Hide;
    if ShowModal = mrOk then
    begin
      cldsChoose.First;
      while not cldsChoose.Eof do
      begin
        gdcSettingStorage.AddPos(st_root_Global + st_ds_NewFormPath + '\' +
          cldsChoose.FieldByName('formname').AsString, '');
        cldsChoose.Next;
      end;
    end;
  finally
    Free;
  end;
end;

procedure Tgdc_frmSetting.actAddFormUpdate(Sender: TObject);
begin
  actAddForm.Enabled := Assigned(gdcObject) and
    Assigned(gdcSettingStorage) and
    (gdcObject.RecordCount > 0) and
    (gdcSettingStorage.Active) and
    (gdcObject.FieldByName('disabled').AsInteger = 0);
end;

procedure Tgdc_frmSetting.actWithDetailUpdate(Sender: TObject);
begin
  actWithDetail.Enabled := (gdcDetailObject <> nil)
    and (gdcDetailObject.RecordCount > 0)
    and (gdcDetailObject.CanEdit)
    and (gdcDetailObject.FindField('withdetail') <> nil);

  actWithDetail.Checked := actWithDetail.Enabled and (gdcDetailObject.FieldByName('withdetail').AsInteger = 1);
  if actWithDetail.Checked then
    actWithDetail.Hint := 'Сохранять без детальных объектов'
  else
    actWithDetail.Hint := 'Сохранять с детальными объектами';
end;

procedure Tgdc_frmSetting.actWithDetailExecute(Sender: TObject);
begin
  if not actWithDetail.Checked then
    (gdcDetailObject as TgdcSettingPos).SetWithDetail(True, GetDetailBookmarkList)
  else
    (gdcDetailObject as TgdcSettingPos).SetWithDetail(False, GetDetailBookmarkList);
end;

procedure Tgdc_frmSetting.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMSETTING', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMSETTING', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMSETTING') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMSETTING',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMSETTING' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(UserStorage) then
    UserStorage.LoadComponent(ibgrStorage, ibgrStorage.LoadFromStream);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMSETTING', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMSETTING', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}

end;

procedure Tgdc_frmSetting.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMSETTING', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMSETTING', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMSETTING') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMSETTING',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMSETTING' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if Assigned(UserStorage) then
    if ibgrStorage.SettingsModified then
      UserStorage.SaveComponent(ibgrStorage, ibgrStorage.SaveToStream);
  inherited;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMSETTING', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMSETTING', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}

end;

procedure Tgdc_frmSetting.actReActivateUpdate(Sender: TObject);
begin
  actReActivate.Enabled := (gdcObject <> nil) and
    (gdcObject.RecordCount > 0) and
    (gdcObject.FieldByName('Disabled').AsInteger = 0);
end;

procedure Tgdc_frmSetting.actReActivateExecute(Sender: TObject);
begin
  {$IFDEF NEW_STREAM}
  CreateStreamSaverForm;
  frmStreamSaver.SetParams(gdcObject, nil, GetMainBookmarkList);
  frmStreamSaver.ShowReactivateSettingForm;
  {$ELSE}
  (gdcObject as TgdcSetting).ReActivateSetting(GetMainBookmarkList);
  {$ENDIF}
end;

procedure Tgdc_frmSetting.actValidPosUpdate(Sender: TObject);
begin
  actValidPos.Enabled := (gdcObject <> nil) and
    (gdcObject.RecordCount > 0) and
    (gdcObject.FieldByName('Disabled').AsInteger = 0) and
    (gdcDetailObject <> nil) and
    (gdcDetailObject.RecordCount > 0);
end;

procedure Tgdc_frmSetting.actValidPosExecute(Sender: TObject);
begin
  (gdcDetailObject as TgdcSettingPos).Valid;
end;

procedure Tgdc_frmSetting.actValidStorageUpdate(Sender: TObject);
begin
  actValidStorage.Enabled := (gdcObject <> nil) and
    (gdcObject.RecordCount > 0) and
    (gdcObject.FieldByName('Disabled').AsInteger = 0) and
    (gdcSettingStorage <> nil) and
    (gdcSettingStorage.RecordCount > 0);
end;

procedure Tgdc_frmSetting.actValidStorageExecute(Sender: TObject);
begin
  (gdcSettingStorage as TgdcSettingStorage).Valid;
end;

procedure Tgdc_frmSetting.actChooseSetingsExecute(Sender: TObject);
begin
  (gdcObject as TgdcSetting).ChooseMainSetting;
end;

procedure Tgdc_frmSetting.actChooseSetingsUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Assigned(gdcObject) and (gdcObject.RecordCount > 0) and
    (gdcObject.State = dsBrowse);
end;

procedure Tgdc_frmSetting.actNeedModifyExecute(Sender: TObject);
begin
  if not actNeedModify.Checked then
    (gdcDetailObject as TgdcSettingPos).SetNeedModify(True, GetDetailBookmarkList)
  else
    (gdcDetailObject as TgdcSettingPos).SetNeedModify(False, GetDetailBookmarkList);
end;

procedure Tgdc_frmSetting.actNeedModifyUpdate(Sender: TObject);
begin
  actNeedModify.Enabled := (gdcDetailObject <> nil)
    and (gdcDetailObject.RecordCount > 0)
    and (gdcDetailObject.CanEdit)
    and (gdcDetailObject.FindField('needmodify') <> nil);

  actNeedModify.Checked := actNeedModify.Enabled and (gdcDetailObject.FieldByName('needmodify').AsInteger = 1);
  if actNeedModify.Checked then
    actNeedModify.Hint := 'Перезаписывать данными из потока'
  else
   actNeedModify.Hint := 'Не перезаписывать данными из потока';
end;

procedure Tgdc_frmSetting.actNeedModifyDefaultExecute(Sender: TObject);
begin
  if MessageBox(Handle, 'Установить флаг "Обновлять записи данными из настройки" в значение по умолчанию?',
    'Настройка', MB_ICONQUESTION or MB_YESNO) = IDYES
  then
    (gdcDetailObject as TgdcSettingPos).SetNeedModifyDefault;
end;

procedure Tgdc_frmSetting.actNeedModifyDefaultUpdate(Sender: TObject);
begin
  actNeedModifyDefault.Enabled := (gdcDetailObject <> nil)
    and (gdcDetailObject.RecordCount > 0)
    and (gdcDetailObject.CanEdit)
    and (gdcDetailObject.FindField('needmodify') <> nil);
end;

procedure Tgdc_frmSetting.actSettingViewExecute(Sender: TObject);
var
  Stream: TStream;
begin
  with Tfrm_SettingView.Create(Self) do
  try
    Stream := gdcObject.CreateBlobStream(gdcObject.FieldByName('data'), bmRead);
    try
      ReadSetting(Stream);
      ShowModal;
    finally
      FreeAndNil(Stream);
    end;
  finally
    Free;
  end;
end;

procedure Tgdc_frmSetting.actSettingViewUpdate(Sender: TObject);
begin
  actSettingView.Enabled := Assigned(gdcObject) and (gdcObject.Active)
    and (gdcObject.State = dsBrowse) and Assigned(gdcObject.FindField('data'))
    and (gdcObject.CanView)
    and (not gdcObject.IsEmpty);
end;

procedure Tgdc_frmSetting.actOpenObjectUpdate(Sender: TObject);
begin
  actOpenObject.Enabled := gdcSettingPos.Active
    and (gdcSettingPos.RecordCount > 0);
end;

procedure Tgdc_frmSetting.actOpenObjectExecute(Sender: TObject);
var
  ObjID: Integer;
  Obj: TgdcBase;
  Cl: TPersistentClass;
begin
  Obj := nil;
  try
    with gdcSettingPos do
    begin
      ObjID := gdcBaseManager.GetIDByRUID(FieldByName('xid').AsInteger,
        FieldByName('dbid').AsInteger);
      if ObjID <> -1 then
      begin
        Cl := GetClass(FieldByName('objectclass').AsString);
        if (Cl <> nil) and Cl.InheritsFrom(TgdcBase) then
        begin
          Obj := CgdcBase(Cl).CreateWithID(nil, nil, nil,
            ObjID,
            FieldByName('subtype').AsString);
          Obj.Open;
          if not Obj.IsEmpty then
            Obj.EditDialog;
        end;
      end;
    end;
  finally
    Obj.Free;
  end;
end;

procedure Tgdc_frmSetting.actLoadFromFileExecute(Sender: TObject);
var
  ibsql: TIBSQL;
  {$IFDEF NEW_STREAM}
  FN: String;
  {$ENDIF}
begin
  {$IFDEF NEW_STREAM}
  FN := gdcObject.QueryLoadFileName('', gsfExtension, gsfxmlDialogFilter);
  if FN > '' then
  begin
    CreateStreamSaverForm;
    frmStreamSaver.FileName := FN;
    frmStreamSaver.SetParams(gdcObject);
    frmStreamSaver.ShowLoadSettingForm;

    if Assigned(gdcObject) and gdcObject.Active then
    begin
      gdcObject.CloseOpen;

      ibsql := TIBSQL.Create(Self);
      try
        ibsql.Transaction := gdcObject.ReadTransaction;
        // Предыдущая версия настройки удаляется перед загрузкой,
        //  так что загруженная настройка всегда будет иметь макс. ID
        ibsql.SQL.Text := 'SELECT MAX(id) FROM at_setting';
        ibsql.ExecQuery;
        if ibsql.RecordCount > 0 then
        begin
          try
            gdcObject.ID := ibsql.Fields[0].AsInteger;
          except
            gdcObject.First;
          end;
        end;
      finally
        ibsql.Free;
      end;
    end;
  end;
  {$ELSE}
  MessageBox(Handle,
    'Для того, чтобы структуры данных были созданы,'#13#10 +
    'а макросы начали выполняться, настройку,'#13#10 +
    'после ее загрузки в базу данных, необходимо активизировать.'#13#10 +
    'Для этого необходимо установить на нее курсор и выбрать'#13#10 +
    'команду Активизировать на панели инструментов.',
    'Внимание',
    MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);

  inherited;

  if Assigned(gdcObject) and gdcObject.Active then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := gdcObject.ReadTransaction;
      // Предыдущая версия настройки удаляется перед загрузкой,
      //  так что загруженная настройка всегда будет иметь макс. ID
      ibsql.SQL.Text := 'SELECT MAX(id) FROM at_setting';
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        try
          gdcObject.ID := ibsql.Fields[0].AsInteger;
        except
          gdcObject.First;
        end;

        {
        if actSetActive.Enabled
          and (gdcObject.ID = ibsql.Fields[0].AsInteger) then
        begin
          if MessageBox(Handle,
            'Настройка была загружена в базу данных.'#13#10#13#10 +
            'Для того, чтобы структуры данных, входящие в настройку,'#13#10 +
            'были созданы, а макросы начали выполняться, настройку'#13#10 +
            'необходимо активизировать.'#13#10#13#10 +
            'Активизировать настройку прямо сейчас?'#13#10#13#10 +
            'Если вы ответите Нет -- активизировать настройку можно'#13#10 +
            'будет позже, вызвав соответствующую команду на панели инструментов.',
            'Внимание',
            MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES then
          begin
            (gdcObject as TgdcSetting).ActivateSetting(nil, nil);
          end;
        end;
        }
      end;
    finally
      ibsql.Free;
    end;
  end;
  {$ENDIF}
end;

procedure Tgdc_frmSetting.RemoveSubSetList(S: TStrings);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_MDH_REMOVESUBSETLIST('TGDC_FRMSETTING', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMSETTING', KEYREMOVESUBSETLIST);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYREMOVESUBSETLIST]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMSETTING') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(S)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMSETTING',
  {M}        'REMOVESUBSETLIST', KEYREMOVESUBSETLIST, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMSETTING' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  inherited;
  S.Add('BySetting');

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMSETTING', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMSETTING', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmSetting.actClearDependenciesExecute(Sender: TObject);
begin
  if MessageBox(Handle, PChar(Format('Сделать настройку %s независимой от остальных?',
    [gdcObject.FieldByName(gdcObject.GetListField(gdcObject.SubType)).AsString])), 'Внимание',
    MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL or MB_DEFBUTTON2) = IDYES
  then
  begin
    (gdcObject as TgdcSetting).ClearDependencies;
  end;
end;

procedure Tgdc_frmSetting.actClearDependenciesUpdate(Sender: TObject);
begin
  actClearDependencies.Enabled := Assigned(gdcObject) and (gdcObject.RecordCount > 0) and
    (not gdcObject.FieldByName('settingsruid').IsNull);
end;

{$IFNDEF NEW_STREAM}
procedure Tgdc_frmSetting.OnObjectLoad(Sender: TatSettingWalker;
  const AClassName, ASubType: String;
  ADataSet: TDataSet; APrSet: TgdcPropertySet; const ASR: TgsStreamRecord);
var
  C: TPersistentClass;
begin
  while not ADataSet.EOF do
  begin
    if (FIBSQLSelectAllPos.FieldByName('xid').AsInteger = ADataSet.FieldByName('_xid').AsInteger)
      and (FIBSQLSelectAllPos.FieldByName('dbid').AsInteger = ADataSet.FieldByName('_dbid').AsInteger) then
    begin
      FIBSQLSelectAllPos.Next;
      Offset := 0;
    end else
    begin
      C := FindClass(AClassName);

      Assert(C.InheritsFrom(TgdcBase));

      FIBSQLSelectPos.Close;
      FIBSQLSelectPos.ParamByName('xid').AsInteger :=
        ADataSet.FieldByName('_xid').AsInteger;
      FIBSQLSelectPos.ParamByName('dbid').AsInteger :=
        ADataSet.FieldByName('_dbid').AsInteger;
      FIBSQLSelectPos.ExecQuery;
      if FIBSQLSelectPos.EOF then
      begin
        FIBSQLUpdatePos.ParamByName('OO').AsInteger := FIBSQLSelectAllPos.FieldByName('objectorder').AsInteger + Offset;
        FIBSQLUpdatePos.ExecQuery;

        FIBSQLInsertPos.ParamByName('objectclass').AsString := AClassName;
        FIBSQLInsertPos.ParamByName('subtype').AsString := ASubtype;
        FIBSQLInsertPos.ParamByName('category').AsString := Copy(CgdcBase(C).GetDisplayName(ASubType), 1, 20);
        FIBSQLInsertPos.ParamByName('objectname').AsString := Copy(CgdcBase(C).GetListNameByID(
          gdcBaseManager.GetIDByRUID(ADataSet.FieldByName('_xid').AsInteger,
          ADataSet.FieldByName('_dbid').AsInteger), ASubType), 1, 60);
        FIBSQLInsertPos.ParamByName('xid').AsInteger := ADataSet.FieldByName('_xid').AsInteger;
        FIBSQLInsertPos.ParamByName('dbid').AsInteger := ADataSet.FieldByName('_dbid').AsInteger;
        FIBSQLInsertPos.ParamByName('objectorder').AsInteger := FIBSQLSelectAllPos.FieldByName('objectorder').AsInteger + Offset;
        FIBSQLInsertPos.ParamByName('withdetail').AsInteger := 0;
        if CgdcBase(C).NeedModifyFromStream(ASubType) then
          FIBSQLInsertPos.ParamByName('needmodify').AsInteger := 1
        else
          FIBSQLInsertPos.ParamByName('needmodify').AsInteger := 0;

        FIBSQLInsertPos.ExecQuery;
        Inc(Offset);
      end;
    end;

    ADataSet.Next;
  end;
end;

procedure Tgdc_frmSetting.OnStartLoading(Sender: TatSettingWalker; AnObjectSet: TgdcObjectSet);
begin
  Offset := 0;
end;
{$ENDIF}

procedure Tgdc_frmSetting.actAddMissedExecute(Sender: TObject);
{$IFNDEF NEW_STREAM}
var
  SW: TatSettingWalker;
  Tr: TIBTransaction;
{$ENDIF}
begin
  if MessageBox(Self.Handle, PChar('Сформировать настройку "' +
    gdcObject.FieldByName(gdcObject.GetListField(gdcObject.SubType)).AsString + '" из выбранных объектов?'), 'Внимание',
    MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDYES then
  begin
    (gdcObject as TgdcSetting).SaveSettingToBlob;
  end;

  {$IFDEF NEW_STREAM}
  (gdcObject as TgdcSetting).AddMissedPositions;
  gdcDetailObject.CloseOpen;
  {$ELSE}

  Tr := TIBTransaction.Create(nil);
  FIBSQLSelectAllPos := TIBSQL.Create(nil);
  FIBSQLUpdatePos := TIBSQL.Create(nil);
  FIBSQLInsertPos := TIBSQL.Create(nil);
  FIBSQLSelectPos := TIBSQL.Create(nil);
  SW := TatSettingWalker.Create;
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;

    FIBSQLSelectAllPos.Transaction := Tr;
    FIBSQLUpdatePos.Transaction := Tr;
    FIBSQLInsertPos.Transaction := Tr;
    FIBSQLSelectPos.Transaction := Tr;

    FIBSQLSelectAllPos.SQL.Text := 'SELECT * FROM at_settingpos WHERE settingkey = :SK ORDER BY objectorder';
    FIBSQLSelectAllPos.ParamByName('SK').AsInteger := gdcObject.FieldByName('id').AsInteger;
    FIBSQLSelectAllPos.ExecQuery;

    FIBSQLUpdatePos.SQL.Text := 'UPDATE at_settingpos SET objectorder = objectorder + 1 WHERE ' +
      ' settingkey = :SK AND objectorder >= :OO ';
    FIBSQLUpdatePos.ParamByName('SK').AsInteger := gdcObject.FieldByName('id').AsInteger;

    FIBSQLInsertPos.SQL.Text := 'INSERT INTO at_settingpos(settingkey, objectclass, subtype, category, ' +
      'objectname, xid, dbid, objectorder, withdetail, needmodify) VALUES( ' +
      ':settingkey, :objectclass, :subtype, :category, ' +
      ':objectname, :xid, :dbid, :objectorder, :withdetail, :needmodify) ';
    FIBSQLInsertPos.ParamByName('settingkey').AsInteger := gdcObject.FieldByName('id').AsInteger;

    FIBSQLSelectPos.SQL.Text := 'SELECT * FROM at_settingpos WHERE settingkey = :SK AND xid = :XID AND dbid = :DBID ';
    FIBSQLSelectPos.ParamByName('SK').AsInteger := gdcObject.FieldByName('id').AsInteger;

    SW.StartLoading := OnStartLoading;
    SW.ObjectLoad := OnObjectLoad;

    SW.Stream := gdcObject.CreateBlobStream(gdcObject.FieldByName('data'), bmRead);
    try
      SW.ParseStream;
    finally
      SW.Stream.Free;
    end;

    Tr.Commit;

    gdcDetailObject.CloseOpen;
  finally
    FIBSQLSelectAllPos.Free;
    FIBSQLUpdatePos.Free;
    FIBSQLInsertPos.Free;
    FIBSQLSelectPos.Free;
    if Tr.InTransaction then
      Tr.Rollback;
    Tr.Free;
    SW.Free;
  end;
  {$ENDIF}
end;

procedure Tgdc_frmSetting.actAddMissedUpdate(Sender: TObject);
begin
  actAddMissed.Enabled := Assigned(gdcObject)
    and (gdcObject.State = dsBrowse)
    and (gdcObject.RecordCount > 0)
    and Assigned(gdcObject.FindField('data'))
    and gdcObject.CanEdit;
end;

procedure Tgdc_frmSetting.OnObjectLoad2(Sender: TatSettingWalker;
  const AClassName, ASubType: String;
  ADataSet: TDataSet; APrSet: TgdcPropertySet; const ASR: TgsStreamRecord);

  function ByteToHex(const B: Byte): String;
  const
    HexDigits: array[0..15] of Char = '0123456789ABCDEF';
  begin
    Result := HexDigits[B div 16] + HexDigits[B mod 16];
  end;

const
  HexInRow = 16;
  DontSaveList = ';LB;RB;AFULL;ACHAG;AVIEW;EDITORKEY;CREATORKEY;EDITIONDATE;CREATIONDATE;_MODIFIED;';
  UseRUIDList = ';ID;PARENT;PARENTINDEX;';
var
  I, J, K, G, OldP: Integer;
  T, FN: String;
  B, C: PChar;
  Size: Integer;
  Added: Boolean;
  Crc32: Cardinal;
begin
  {
  SList.Add('Версия потока: ' + IntToStr(ASR.StreamVersion));
  SList.Add('Идентификатор базы: ' + IntToStr(ASR.StreamDBID) + #13#10);
  SList.Add('');
  }

  if OnlyDup and (Pass = 0) then
  begin
    ADataSet.First;
    while not ADataSet.EOF do
    begin
      T := ADataSet.FieldByName('_xid').AsString + '_' +
        ADataSet.FieldByName('_dbid').AsString;
      I := SCount.IndexOf(T);
      if I = -1 then
        SCount.Add(T)
      else
        SCount.Objects[I] := Pointer(Integer(SCount.Objects[I]) + 1);
      ADataSet.Next;
    end;
  end else
  begin
    T := 'Class: ' + AClassName;
    if ASubType > '' then
      T := T + '(' + ASubType + ')';
    if FakeName > '' then
      T := T + '  Настр.: ' + FakeName
    else
    begin
      if (Sender.SettingObj <> nil) then
        T := T + '  Настр.: ' + Sender.SettingObj.ObjectName;
    end;
    SList.Add(T);
    Added := False;
    ADataSet.First;
    while not ADataSet.EOF do
    begin
      if OnlyDup then
      begin
        T := ADataSet.FieldByName('_xid').AsString + '_' +
          ADataSet.FieldByName('_dbid').AsString;
        if SCount.IndexOf(T) = -1 then
        begin
          ADataSet.Next;
          continue;
        end;

        if OnlyDiff and (Pass = 2) then
        begin
          if SDiff.IndexOf(T) = -1 then
          begin
            ADataSet.Next;
            continue;
          end;
        end;
      end;

      Added := True;
      SList.Add('');
      OldP := SList.Count;
      for I := 0 to ADataSet.FieldCount - 1 do
      begin
        FN := ADataSet.Fields[I].FieldName;

        if DontSave and (Pos(';' + FN + ';', DontSaveList) <> 0) then
          continue;

        if not ADataSet.Fields[I].IsNull then
        begin
          case ADataSet.Fields[I].DataType of
            ftString:
              SList.Add(Format({'%2d: }'%20s', [{I,} FN]) + ':  "' + ADataSet.Fields[I].AsString + '"');
            ftInteger:
            begin
              if UseRUID and ((Pos(';' + FN + ';', UseRUIDList) <> 0)
                or ((Length(FN) > 3) and (Copy(FN, Length(FN) - 2, 3) = 'KEY'))) then
              begin
                if FN = 'ID' then
                begin
                  K := IDLink.IndexOf(ADataSet.Fields[I].AsInteger);
                  if K <> -1 then
                  begin
                    if IDLink.ValuesByIndex[K] <> (ADataSet.FieldByName('_xid').AsString
                      + '_' + ADataSet.FieldByName('_dbid').AsString) then
                    begin
                      raise Exception.Create('Invalid data stream');
                    end;
                  end else
                  begin
                    K := IDLink.Add(ADataSet.Fields[I].AsInteger);
                    IDLink.ValuesByIndex[K] := ADataSet.FieldByName('_xid').AsString
                      + '_' + ADataSet.FieldByName('_dbid').AsString;
                  end;
                  SList.Add(Format({'%2d: }'%20s', [{I,} FN]) + ':  '
                    + IDLink.ValuesByIndex[K]);
                end else
                begin
                  K := IDLink.IndexOf(ADataSet.Fields[I].AsInteger);
                  if K = -1 then
                    SList.Add(Format({'%2d: }'%20s', [{I,} FN]) + ':  ' + ADataSet.Fields[I].AsString)
                  else
                    SList.Add(Format({'%2d: }'%20s', [{I,} FN]) + ':  '
                      + IDLink.ValuesByIndex[K]);
                end;
              end else
                SList.Add(Format({'%2d: }'%20s', [{I,} FN]) + ':  ' + ADataSet.Fields[I].AsString);
            end;
            ftMemo:
              SList.Add(Format({'%2d: }'%20s', [{I,} FN]) +
                ':'#13#10#13#10 + ADataSet.Fields[I].AsString + #13#10);
            ftBLOB, ftGraphic:
            begin
              if not DontSaveBlob then
              begin
                T := ADataSet.Fields[I].AsString;
                Size := Length(T);
                Size := Size * 3 + ((Size div HexInRow) + 1) * (2 + 4) + 32;
                GetMem(B, Size);
                try
                  C := B;
                  C[0] := #0;
                  for J := 1 to Length(T) do
                  begin
                    if J mod HexInRow = 1 then
                      C := StrCat(C, '    ') + StrLen(C);
                    C := StrCat(C, PChar(ByteToHex(Byte(T[J])) + ' ')) + StrLen(C);
                    if J mod HexInRow = 0 then
                      C := StrCat(C, #13#10) + StrLen(C);
                  end;
                  StrCat(C, #13#10);
                  SList.Add(Format({'%2d: }'%20s', [{I,} FN]) +
                    ':  Size ' + IntToStr(Length(T)) + #13#10#13#10 + B + #13#10);
                finally
                  FreeMem(B, Size);
                end;
              end;
            end;
          else
            SList.Add(Format({'%2d: }'%20s', [{I,} FN]) + ':  ' + ADataSet.Fields[I].AsString);
          end;
        end else
          SList.Add(Format({'%2d: }'%20s', [{I,} FN]) + ':  NULL');
      end;

      if OnlyDup and OnlyDiff and (Pass = 1) then
      begin
        Crc32 := 0;
        for G := OldP to SList.Count - 1 do
        begin
          if Length(SList[G]) > 0 then
            Crc32 := Crc32_P(@(SList[G][1]), Length(SList[G]), Crc32);
        end;

        T := ADataSet.FieldByName('_xid').AsString + '_' +
          AdataSet.FieldByName('_dbid').AsString;
        G := SCRC32.IndexOf(T);
        if G = -1 then
          SCRC32.AddObject(T, Pointer(Crc32))
        else
        begin
          if Pointer(Crc32) <> SCRC32.Objects[G] then
          begin
            if SDiff.IndexOf(T) = -1 then
              SDiff.Add(T);
          end;
        end;
      end;

      ADataSet.Next;
    end;

    if Added then
    begin
      if APrSet.Count > 0 then
        SList.Add(#13#10'Свойства'#13#10);
      for I := 0 to APrSet.Count - 1 do
        SList.Add(Format({'%2d: }'%20s', [{I, }APrSet.Name[I]]) + ':  ' + VarToStr(APrSet.Value[APrSet.Name[I]]));
      SList.Add('');
    end else
      SList.Delete(SList.Count - 1);
  end;
end;

procedure Tgdc_frmSetting.OnStartLoading2(Sender: TatSettingWalker;
  AnObjectSet: TgdcObjectSet);
begin
  //SList.Clear;
end;

procedure Tgdc_frmSetting.actSet2TxtExecute(Sender: TObject);
var
  WorkedOut: TList;
  WasError: Boolean;

  procedure ParseSetting(const AnID: Integer;
    const AFileName: String = '');
  var
    Obj: TgdcBase;
    I, ID: Integer;
    RUID: TRUID;
    SW: TatSettingWalker;
    RuidList: TStringList;
  begin
    if WorkedOut.IndexOf(Pointer(AnID)) <> -1 then
      exit;

    if AFileName = '' then
      Obj := TgdcSetting.CreateSingularByID(Self,
        AnID, gdcObject.SubType)
    else
    begin
      Obj := TgdcSetting.Create(nil);
    end;

    try

      if AFileName > '' then
      begin
        Obj.BaseState := Obj.BaseState + [sFakeLoad];
        Obj.OnFakeLoad := OnFakeLoad;
        Obj.LoadFromFile(AFileName);
      end;

      if SaveDependencies then
      begin
        RuidList := TStringList.Create;
        try
          if AFileName > '' then
            RuidList.CommaText := FakeRuidList
          else
            RuidList.CommaText := Obj.FieldByName('settingsruid').AsString;
          for I := 0 to RuidList.Count - 1 do
          begin
            RUID := StrToRUID(RuidList[I]);
            ID := gdcBaseManager.GetIDByRUID(RUID.XID, RUID.DBID);
            if ID = -1 then
            begin
              SList.Add('');
              SList.Add('Внимание! Настройка с РУИДом ' + RuidList[I] + ''#13#10 +
                'от которой зависит настройка "' + Obj.ObjectName + '" не найдена в базе данных.');
              SList.Add('');
              WasError := True;
            end else
              ParseSetting(ID);
           end;
        finally
          RuidList.Free;
        end;
      end;

      if not (OnlyDup and (Pass = 0)) then
      begin
        SList.Add('');
        SList.Add('Настройка: ' + Obj.ObjectName);
        SList.Add('');
      end;

      IDLink.Clear;

      SW := TatSettingWalker.Create;
      try
        SW.StartLoading := OnStartLoading2;
        SW.ObjectLoad := OnObjectLoad2;

        SW.SettingObj := Obj;
        if AFileName > '' then
        begin
          SW.Stream := FakeStream;
        end else
          SW.Stream := Obj.CreateBlobStream(Obj.FieldByName('data'), bmRead);
        try
          SW.ParseStream;
        finally
          if AFileName = '' then
            SW.Stream.Free;
        end;

        WorkedOut.Add(Pointer(AnID));

      finally
        SW.Free;
      end;
    finally
      Obj.Free;
    end;
  end;

var
  OldCursor: TCursor;
  G: Integer;
  TmpPath: array[0..1024] of Char;
  _paramstr1, _paramstr2: String;
begin
  with Tgdc_attr_dlgSetToTxt.Create(Self) do
  try
    if ShowModal = mrCancel then
      exit;

    DontSave := chbxDontSave.Checked;
    UseRUID := chbxUseRUID.Checked;
    SaveDependencies := chbxSaveDependencies.Checked;
    DontSaveBLOB := chbxDontSaveBLOB.Checked;
    OnlyDup := chbxOnlyDup.Checked;
    OnlyDiff := chbxOnlyDiff.Checked;

    WasError := False;
    OldCursor := Screen.Cursor;
    WorkedOut := TList.Create;
    SList := TStringList.Create;
    SCount := TStringList.Create;
    SDiff := TStringList.Create;
    SCRC32 := TStringList.Create;
    IDLink := TgdKeyStringAssoc.Create;
    FakeStream := TMemoryStream.Create;
    FakeRUIDList := '';
    FakeName := '';
    Pass := 0;
    try
      Screen.Cursor := crHourGlass;

      SCount.Sorted := True;
      SCount.Duplicates := dupError;

      SDiff.Sorted := True;
      SDiff.Duplicates := dupError;

      SCRC32.Sorted := True;
      SCRC32.Duplicates := dupError;

      repeat
        if ibgrMain.SelectedRows.Count < 2 then
          ParseSetting(gdcObject.ID)
        else
        begin
          for G := 0 to ibgrMain.SelectedRows.Count - 1 do
          begin
            ParseSetting(gdcObject.GetIDForBookmark(ibgrMain.SelectedRows[G]));
          end;
        end;

        if OnlyDup and (Pass = 0) then
        begin
          for G := SCount.Count - 1 downto 0 do
          begin
            if SCount.Objects[G] = nil then
              SCount.Delete(G);
          end;

          WorkedOut.Clear;
          Inc(Pass);
        end
        else if OnlyDup and OnlyDiff and (Pass = 1) then
        begin
          SList.Clear;
          WorkedOut.Clear;
          Inc(Pass);
        end else
          break;
      until False;

      SList.SaveToFile(edFile.Text);

      if WasError then
      begin
        MessageBox(Handle,
          'В структуре настроек присутствуют ошибки. Проверьте сформированный файл.',
          'Внимание',
          MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      end else
      begin
        MessageBox(Handle,
          'Сохранение прошло успешно.',
          'Внимание',
          MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
      end;

      if FileExists(edCompare.Text) then
      begin
        _paramstr1 := edFile.Text;

        Pass := 0;
        SList.Clear;
        WorkedOut.Clear;
        SDiff.Clear;
        SCRC32.Clear;
        SCount.Clear;
        IDLink.Clear;
        repeat
          ParseSetting(-1, edCompare.Text);

          if OnlyDup and (Pass = 0) then
          begin
            for G := SCount.Count - 1 downto 0 do
            begin
              if SCount.Objects[G] = nil then
                SCount.Delete(G);
            end;

            WorkedOut.Clear;
            Inc(Pass);
          end
          else if OnlyDup and OnlyDiff and (Pass = 1) then
          begin
            SList.Clear;
            WorkedOut.Clear;
            Inc(Pass);
          end else
            break;
        until False;

        GetTempPath(1024, TmpPath);
        _paramstr2 := TmpPath + 'ttt.tmp';

        SList.SaveToFile(_paramstr2);

        ShellExecute(Handle,
          'open',
          'c:\Program Files\Starbase\StarTeam 5.3\VisDiff.exe',
          PChar(_paramstr1 + ' ' + _paramstr2),
          'c:\Program Files\Starbase\StarTeam 5.3',
          SW_SHOW);
      end;
    finally
      SList.Free;
      SCount.Free;
      SDiff.Free;
      SCRC32.Free;
      IDLink.Free;
      WorkedOut.Free;
      FakeStream.Free;
      Screen.Cursor := OldCursor;
    end;

  finally
    Free;
  end;
end;

procedure Tgdc_frmSetting.actSet2TxtUpdate(Sender: TObject);
begin
  actSet2Txt.Enabled := Assigned(gdcObject) and
    (not gdcObject.IsEmpty);
end;

procedure Tgdc_frmSetting.OnFakeLoad(Sender: TgdcBase; CDS: TDataSet);
begin
  if Sender is TgdcSetting then
  begin
    FakeName := CDS.FieldByName('name').AsString;
    FakeRUIDList := CDS.FieldByName('settingsruid').AsString;
    (CDS.FieldByName('data') as TBlobField).SaveToStream(FakeStream);
    FakeStream.Position := 0;
  end;  
end;

procedure Tgdc_frmSetting.ibgrDetailDblClick(Sender: TObject);
const
  Counter: Integer = 0;
begin
  if (ibgrDetail.GridCoordFromMouse.X >= 0) and
     (ibgrDetail.GridCoordFromMouse.Y >= 0) and
     Assigned(gdcDetailObject) then
  begin
    if (not actDetailEditInGrid.Checked) then
    begin
      if not gdcDetailObject.IsEmpty then
        actOpenObject.Execute;
    end else
    begin
      Inc(Counter);
      if Counter > 2 then
      begin
        MessageBox(Handle,
          PChar('В настоящий момент режим "Редактирование в таблице" включен.'#13#10 +
          'Для того, чтобы по двойному щелчку мыши открывалось диалоговое окно '#13#10 +
          'изменения записи, необходимо выключить этот режим.'#13#10 +
          'Нажмите соответствующую кнопку на панели инструментов.'),
          'Внимание',
          MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
      end;
    end;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_frmSetting);

finalization
  UnRegisterFrmClass(Tgdc_frmSetting);

end.
