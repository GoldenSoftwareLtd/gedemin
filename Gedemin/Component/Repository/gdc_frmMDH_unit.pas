//

unit gdc_frmMDH_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmG_unit, ExtCtrls, IBDatabase, Db, flt_sqlFilter,
  Menus, ActnList,  ComCtrls, ToolWin, gdcBase, gdcBaseInterface, DBGrids,
  IBCustomDataSet, gdcConst, TB2Item, TB2Dock, TB2Toolbar,
  StdCtrls, gd_MacrosMenu, Grids, gsDBGrid, gsIBGrid, amSplitter;

type
  TCrTBItem = Class(TTBItem);

  Tgdc_frmMDH = class(Tgdc_frmG)
    sMasterDetail: TSplitter;
    pnlDetail: TPanel;
    actDetailNew: TAction;
    actDetailEdit: TAction;
    actDetailDelete: TAction;
    actDetailDuplicate: TAction;
    actDetailPrint: TAction;
    actDetailCut: TAction;
    actDetailCopy: TAction;
    actDetailPaste: TAction;
    dsDetail: TDataSource;
    pmDetail: TPopupMenu;
    nDetailNew: TMenuItem;
    nDetailEdit: TMenuItem;
    nDetailDel: TMenuItem;
    actDetailFind: TAction;
    nSepartor5: TMenuItem;
    nDetailFind: TMenuItem;
    actDetailReduction: TAction;
    nDetailReduction: TMenuItem;
    actDetailFilter: TAction;
    tbDetailCustom: TTBToolbar;
    tbDetailToolbar: TTBToolbar;
    actDetailProperties: TAction;
    nDetailProperties: TMenuItem;
    actSearchDetail: TAction;
    actSearchdetailClose: TAction;
    pnlSearchDetail: TPanel;
    sbSearchDetail: TScrollBox;
    pnlSearchDetailButton: TPanel;
    btnSearchDetail: TButton;
    btnSearchDetailClose: TButton;
    tbiDetailFilter: TTBItem;
    tbiDetailPrint: TTBItem;
    tbsiMainMenuDetailObject: TTBSubmenuItem;
    tbi_mm_DetailEdit: TTBItem;
    tbi_mm_DetailDelete: TTBItem;
    tbi_mm_DetailDuplicate: TTBItem;
    tbi_mm_DetailReduction: TTBItem;
    tbi_mm_DetailSep1: TTBSeparatorItem;
    tbi_mm_DetailCopy: TTBItem;
    tbi_mm_DetailCut: TTBItem;
    tbi_mm_DetailPaste: TTBItem;
    tbi_mm_DetailSep2: TTBSeparatorItem;
    tbi_mm_DetailFind: TTBItem;
    tbi_mm_DetailFilter: TTBItem;
    tbi_mm_DetailPrint: TTBItem;
    actDetailAddToSelected: TAction;
    actDetailRemoveFromSelected: TAction;
    actDetailOnlySelected: TAction;
    tbiDetailOnlySelected: TTBItem;
    actDetailAddToSelected1: TMenuItem;
    actDetailRemoveFromSelected1: TMenuItem;
    actDetailQExport: TAction;
    nDetailQExport: TMenuItem;
    nDetailDup: TMenuItem;
    actDetailToSetting: TAction;
    miDetailSetting: TMenuItem;
    sprDetailSetting: TMenuItem;
    actDetailSaveToFile: TAction;
    actDetailLoadFromFile: TAction;
    TBSeparatorItem1: TTBSeparatorItem;
    m_DetailLoadFromFile: TTBItem;
    m_DetailSaveToFile: TTBItem;
    chbxFuzzyMatchDetail: TCheckBox;
    actDetailEditInGrid: TAction;
    tbiDetailEditInGrid: TTBItem;
    tbiDetailMenuAddToSelected: TTBItem;
    actDetailLinkObject: TAction;
    tbiDetailLinkObject: TTBItem;
    tbi_mm_DetailNew: TTBItem;
    tbiDetailNew: TTBItem;
    procedure actDetailEditExecute(Sender: TObject);
    procedure actDetailNewExecute(Sender: TObject);
    procedure actDetailNewUpdate(Sender: TObject);
    procedure actDetailEditUpdate(Sender: TObject);
    procedure actDetailDeleteExecute(Sender: TObject);
    procedure actDetailDeleteUpdate(Sender: TObject);
    procedure actDetailDuplicateExecute(Sender: TObject);
    procedure actDetailDuplicateUpdate(Sender: TObject);
    procedure actDetailFilterExecute(Sender: TObject);
    procedure actDetailPrintExecute(Sender: TObject);
    procedure actDetailCutUpdate(Sender: TObject);
    procedure actDetailCopyUpdate(Sender: TObject);
    procedure actDetailPasteUpdate(Sender: TObject);
    procedure actDetailCopyExecute(Sender: TObject);
    procedure actDetailPasteExecute(Sender: TObject);
    procedure actDetailCutExecute(Sender: TObject);
    procedure actDetailFindExecute(Sender: TObject);
    procedure actDetailReductionExecute(Sender: TObject);
    procedure actDetailPrintUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actDetailPropertiesExecute(Sender: TObject);
    procedure actDetailPropertiesUpdate(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actSaveToFileUpdate(Sender: TObject);
    procedure actDetailFindUpdate(Sender: TObject);
    procedure actSearchDetailExecute(Sender: TObject);
    procedure actSearchdetailCloseExecute(Sender: TObject);
    procedure actDetailAddToSelectedExecute(Sender: TObject);
    procedure actDetailAddToSelectedUpdate(Sender: TObject);
    procedure actDetailRemoveFromSelectedExecute(Sender: TObject);
    procedure actDetailRemoveFromSelectedUpdate(Sender: TObject);
    procedure actDetailOnlySelectedExecute(Sender: TObject);
    procedure actDetailOnlySelectedUpdate(Sender: TObject);
    procedure actDetailQExportExecute(Sender: TObject);
    procedure actDetailQExportUpdate(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actDetailReductionUpdate(Sender: TObject);
    procedure actDetailToSettingExecute(Sender: TObject);
    procedure actDetailToSettingUpdate(Sender: TObject);
    procedure actDetailSaveToFileExecute(Sender: TObject);
    procedure actDetailSaveToFileUpdate(Sender: TObject);
    procedure actDetailLoadFromFileExecute(Sender: TObject);
    procedure actDetailLoadFromFileUpdate(Sender: TObject);
    procedure pnlMainResize(Sender: TObject);
    procedure TBDockTopRequestDock(Sender: TObject;
      Bar: TTBCustomDockableWindow; var Accept: Boolean);
    procedure TBDockDetailRequestDock(Sender: TObject;
      Bar: TTBCustomDockableWindow; var Accept: Boolean);
    procedure actEditExecute(Sender: TObject);
    procedure actPropertiesExecute(Sender: TObject);
    procedure actCommitExecute(Sender: TObject);
    procedure actDetailLinkObjectUpdate(Sender: TObject);
    procedure actDetailLinkObjectExecute(Sender: TObject);
    procedure actDetailFilterUpdate(Sender: TObject);
    procedure pnlSearchDetailEnter(Sender: TObject);
    procedure pnlSearchDetailExit(Sender: TObject);
    procedure tbiDetailNewPopup(Sender: TTBCustomItem; FromLink: Boolean);

  private
    FgdcDetailObject: TgdcBase;
    FFieldOriginDetail: TStringList;
    FDetailPreservedConditions: String;

    procedure DoOnDetailDescendantClick (Sender: TObject);

  protected
    FSavedMasterSource: TDataSource;
    FSavedSubSet: String;

    procedure SetgdcDetailObject(const Value: TgdcBase); virtual;
    
    procedure RemoveSubSetList(S: TStrings); virtual;

    class procedure RegisterMethod;

    function OnInvoker(const Name: WideString; AnParams: OleVariant): OleVariant; override;

    procedure DoOnFilterChanged(Sender: TObject); override;

    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;

    procedure SetShortCut(const Master: Boolean); override;
    procedure DoCreate; override;
    function Get_SelectedKey: OleVariant; override; safecall;
    procedure DoShowAllFields(Sender: TObject); override;

  public
    destructor Destroy; override;
    function GetDetailBookmarkList: TBookmarkList; virtual;
    property gdcDetailObject: TgdcBase read FgdcDetailObject write SetgdcDetailObject;

    procedure SaveSettings; override;
    procedure LoadSettings; override;
    procedure LoadSettingsAfterCreate; override;
  end;

var
  gdc_frmMDH: Tgdc_frmMDH;

implementation

uses
  dmDatabase_unit, gsStorage_CompPath, dmImages_unit, gd_createable_form,
  gdcLink,
  {$IFDEF QEXPORT}
  VExportDlg,
  {$ENDIF}
  gd_security, Storages, gd_ClassList, at_AddToSetting,
  prp_methods
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  , gdc_frmStreamSaver;

{$R *.DFM}

procedure Tgdc_frmMDH.actDetailEditExecute(Sender: TObject);
begin
  gdcDetailObject.EditMultiple2(Get_SelectedKey[1]);
end;

procedure Tgdc_frmMDH.actDetailNewExecute(Sender: TObject);
begin
  gdcDetailObject.CreateDescendant;
end;

procedure Tgdc_frmMDH.actDetailNewUpdate(Sender: TObject);
begin
  actDetailNew.Enabled := (gdcObject <> nil)
    and (gdcDetailObject <> nil)
    and gdcDetailObject.CanCreate
    and ((gdcObject.RecordCount > 0) or (gdcDetailObject.HasSubSet('All')));
end;

procedure Tgdc_frmMDH.actDetailEditUpdate(Sender: TObject);
begin
  actDetailEdit.Enabled := (gdcObject <> nil)
    and (gdcDetailObject <> nil)
    and (gdcDetailObject.RecordCount > 0)
    and gdcDetailObject.CanView;
end;

procedure Tgdc_frmMDH.actDetailDeleteExecute(Sender: TObject);
begin
  gdcDetailObject.DeleteMultiple2(Get_SelectedKey[1]);
end;

procedure Tgdc_frmMDH.actDetailDeleteUpdate(Sender: TObject);
begin
   actDetailDelete.Enabled :=
    (gdcDetailObject <> nil) and
    (gdcDetailObject.RecordCount > 0)  and
    gdcDetailObject.CanDelete;
end;

procedure Tgdc_frmMDH.actDetailDuplicateExecute(Sender: TObject);
begin
  gdcDetailObject.CopyDialog;
end;

procedure Tgdc_frmMDH.actDetailDuplicateUpdate(Sender: TObject);
begin
  actDetailDuplicate.Enabled :=
    (gdcDetailObject <> nil)
    and (gdcDetailObject.RecordCount > 0)
    and gdcDetailObject.CanCreate
    and gdcDetailObject.CanEdit;
end;

procedure Tgdc_frmMDH.actDetailFilterExecute(Sender: TObject);
var
  R: TRect;
begin
  with tbDetailToolbar do
  begin
    R := View.Find(tbiDetailFilter).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;
  gdcDetailObject.PopupFilterMenu(R.Left, R.Bottom);
end;

procedure Tgdc_frmMDH.actDetailPrintExecute(Sender: TObject);
var
  R: TRect;
begin
  with tbDetailToolbar do
  begin
    R := View.Find(tbiDetailPrint).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;
  gdcDetailObject.PopupReportMenu(R.Left, R.Bottom);
end;

procedure Tgdc_frmMDH.actDetailCutUpdate(Sender: TObject);
begin
  actDetailCut.Enabled :=
    (gdcDetailObject <> nil) and
    (gdcDetailObject.RecordCount > 0) and
    (gdcDetailObject.State = dsBrowse) and
    gdcDetailObject.CanDelete;
end;

procedure Tgdc_frmMDH.actDetailCopyUpdate(Sender: TObject);
begin
  actDetailCopy.Enabled :=
    (gdcDetailObject <> nil) and
    (gdcDetailObject.RecordCount > 0) and
    (gdcDetailObject.State = dsBrowse) and
    gdcDetailObject.CanEdit;
end;

procedure Tgdc_frmMDH.actDetailPasteUpdate(Sender: TObject);
begin
  actDetailPaste.Enabled := (gdcDetailObject <> nil) and
    (gdcDetailObject.CanPasteFromClipboard);
end;

procedure Tgdc_frmMDH.actDetailCopyExecute(Sender: TObject);
begin
  inherited;
  gdcDetailObject.CopyToClipboard(GetDetailBookmarkList, cCopy);
end;

procedure Tgdc_frmMDH.actDetailPasteExecute(Sender: TObject);
begin
  inherited;
  gdcDetailObject.PasteFromClipboard;
end;

procedure Tgdc_frmMDH.actDetailCutExecute(Sender: TObject);
begin
  inherited;
  gdcDetailObject.CopyToClipboard(GetDetailBookmarkList, cCut);
end;

procedure Tgdc_frmMDH.SetShortCut(const Master: Boolean);
begin
  if Master then
  begin
    inherited SetShortCut(Master);

    actDetailNew.ShortCut := 0;
    actDetailEdit.ShortCut := 0;
    actDetailDelete.ShortCut := 0;
    actDetailDuplicate.ShortCut := 0;
    actDetailPrint.ShortCut := 0;
    actDetailCut.ShortCut := 0;
    actDetailCopy.ShortCut := 0;
    actDetailPaste.ShortCut := 0;
    actDetailReduction.ShortCut := 0;
  end
  else
  begin
    actDetailNew.ShortCut := TextToShortCut(scNew);
    actDetailEdit.ShortCut := TextToShortCut(scEdit);
    actDetailDelete.ShortCut := TextToShortCut(scDelete);
    actDetailDuplicate.ShortCut := TextToShortCut(scDuplicate);
    actDetailPrint.ShortCut := TextToShortCut(scPrint);
    //actDetailCut.ShortCut := TextToShortCut(scCut);
    //actDetailCopy.ShortCut := TextToShortCut(scCopy);
    //actDetailPaste.ShortCut := TextToShortCut(scPaste);
    actDetailReduction.ShortCut := TextToShortCut(scReduction);

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
end;

function Tgdc_frmMDH.GetDetailBookmarkList: TBookmarkList;
begin
  Result := nil;
end;

procedure Tgdc_frmMDH.actDetailFindExecute(Sender: TObject);
begin
  if pnlSearchDetail.Visible then
  begin
    actSearchDetailClose.Execute;
    exit;
  end;

  SetupSearchPanel(gdcDetailObject,
    pnlSearchDetail,
    sbSearchDetail,
    nil{sSearchDetail},
    FFieldOriginDetail,
    FDetailPreservedConditions);
end;

procedure Tgdc_frmMDH.actDetailReductionExecute(Sender: TObject);
begin
  gdcDetailObject.Reduction(nil);
end;

procedure Tgdc_frmMDH.actDetailPrintUpdate(Sender: TObject);
begin
  actDetailPrint.Enabled := (gdcDetailObject <> nil)
    and (gdcDetailObject.CanPrint)
    and (gdcDetailObject.State = dsBrowse);
end;

procedure Tgdc_frmMDH.FormCreate(Sender: TObject);
begin
  // переодически "слетают" картинки при перестройке проекта
  // что ж, будем жестко их присваивать
  if dmImages <> nil then
  begin
    tbDetailToolbar.Images := dmImages.il16x16;
    tbDetailCustom.Images := dmImages.il16x16;
    pmDetail.Images := dmImages.il16x16;
  end;

  inherited;
end;

procedure Tgdc_frmMDH.actDetailPropertiesExecute(Sender: TObject);
begin
  //gdcDetailObject.EditMultiple(GetDetailBookmarkList, 'Tgdc_dlgObjectProperties');
  gdcDetailObject.EditMultiple2(Get_SelectedKey[1], 'Tgdc_dlgObjectProperties');
end;

procedure Tgdc_frmMDH.actDetailPropertiesUpdate(Sender: TObject);
begin
  actDetailProperties.Enabled := Assigned(gdcDetailObject) and
    (gdcDetailObject.RecordCount > 0) and (gdcDetailObject.State = dsBrowse);
end;

procedure Tgdc_frmMDH.SetgdcDetailObject(const Value: TgdcBase);
begin
  if FgdcDetailObject <> Value then
  begin
    if Assigned(FgdcDetailObject) then
      FgdcDetailObject.RemoveFreeNotification(Self);

    FgdcDetailObject := Value;
    if (FSubType > '') and (FgdcDetailObject <> nil) and FgdcDetailObject.CheckSubType(FSubType) then
      FgdcDetailObject.SubType := FSubType;
    if dsDetail.DataSet <> Value then
      dsDetail.DataSet := Value;
    if FgdcDetailObject <> nil then
    begin
      if FgdcDetailObject.Owner <> Self then
        FgdcDetailObject.FreeNotification(Self);
      FgdcDetailObject.OnFilterChanged := DoOnFilterChanged;
      DoOnFilterChanged(nil);

      if gdClassList.Get(TgdBaseEntry,
        FgdcDetailObject.ClassName, FgdcDetailObject.SubType).Count > 0 then
      begin
        if (Self.ClassName <> 'Tgdc_frmUserComplexDocument')
          and (Self.ClassName <> 'Tgdc_frmInvDocument')
          and (Self.ClassName <> 'Tgdc_frmInvPriceList') then
        begin
          TCrTBItem(tbiDetailNew).ItemStyle :=
            TCrTBItem(tbiDetailNew).ItemStyle + [tbisSubMenu, tbisSubitemsEditable, tbisCombo];
          tbiDetailNew.OnPopup := tbiDetailNewPopup;
        end;
      end;
    end;
  end;
end;

procedure Tgdc_frmMDH.DoOnDetailDescendantClick(Sender: TObject);
var
  CE: TgdBaseEntry;
  C: TgdcFullClass;
begin
  if (gdcDetailObject <> nil) and ((Sender as TTBItem).Tag <> 0) then
  begin
    CE := TgdBaseEntry((Sender as TTBItem).Tag);
    C.gdClass := CE.gdcClass;
    C.SubType := CE.SubType;
    gdcDetailObject.CreateDialog(C);
  end;
end;

procedure Tgdc_frmMDH.actSaveToFileExecute(Sender: TObject);
var
  frmStreamSaver: TForm;
begin
  frmStreamSaver := Tgdc_frmStreamSaver.CreateAndAssign(Self);
  if MessageBox(Handle,
    'Сохранить объект вместе с детальными объектами?',
    'Внимание',
    MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES then
    (frmStreamSaver as Tgdc_frmStreamSaver).SetParams(gdcObject, gdcDetailObject)
  else
    (frmStreamSaver as Tgdc_frmStreamSaver).SetParams(gdcObject);
  (frmStreamSaver as Tgdc_frmStreamSaver).ShowSaveForm;
end;

procedure Tgdc_frmMDH.actSaveToFileUpdate(Sender: TObject);
begin
  if FgdcDetailObject <> nil then
    inherited
  else
    actSaveToFile.Enabled := False;
end;

procedure Tgdc_frmMDH.actDetailFindUpdate(Sender: TObject);
begin
  actDetailFind.Enabled := (gdcDetailObject <> nil)
    and (gdcDetailObject.State = dsBrowse);
  actDetailFind.Checked := pnlSearchDetail.Visible;
end;

destructor Tgdc_frmMDH.Destroy;
begin
  if Assigned(FgdcDetailObject) then
    FgdcDetailObject.OnFilterChanged := nil;

  inherited;
  FFieldOriginDetail.Free;
end;

procedure Tgdc_frmMDH.actSearchDetailExecute(Sender: TObject);
begin
  SearchExecute(gdcDetailObject, pnlSearchdetail, FFieldOriginDetail,
    FDetailPreservedConditions, chbxFuzzyMatchDetail.Checked);
end;

procedure Tgdc_frmMDH.actSearchdetailCloseExecute(Sender: TObject);
var
  I: Integer;
begin
  if pnlSearchDetail.Visible then
  begin
    gdcDetailObject.ExtraConditions.Text := FDetailPreservedConditions;
    FreeAndNil(FFieldOriginDetail);
    for I := sbSearchDetail.ControlCount - 1 downto 0 do
    begin
      sbSearchDetail.Controls[I].Free;
    end;
    pnlSearchDetail.Visible := False;
  end;
end;

procedure Tgdc_frmMDH.actDetailAddToSelectedExecute(Sender: TObject);
begin
  gdcDetailObject.AddToSelectedID;
end;

procedure Tgdc_frmMDH.actDetailAddToSelectedUpdate(Sender: TObject);
begin
  actDetailAddToSelected.Enabled := Assigned(gdcDetailObject)
    and gdcDetailObject.Active
    and (not gdcDetailObject.IsEmpty)
    and Assigned(GlobalStorage)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_EDIT_FILTERS_ID, GD_POL_EDIT_FILTERS_MASK, False)
        and IBLogin.InGroup) <> 0);
end;

procedure Tgdc_frmMDH.actDetailRemoveFromSelectedExecute(Sender: TObject);
begin
  gdcDetailObject.RemoveFromSelectedID;
end;

procedure Tgdc_frmMDH.actDetailRemoveFromSelectedUpdate(Sender: TObject);
begin
  actDetailRemoveFromSelected.Enabled := Assigned(gdcDetailObject)
    and gdcDetailObject.Active
    and (not gdcDetailObject.IsEmpty)
    and (gdcDetailObject.SelectedID.IndexOf(gdcDetailObject.ID) <> -1)
    and Assigned(GlobalStorage)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_EDIT_FILTERS_ID, GD_POL_EDIT_FILTERS_MASK, False)
        and IBLogin.InGroup) <> 0);
end;

procedure Tgdc_frmMDH.actDetailOnlySelectedExecute(Sender: TObject);
begin
  if gdcDetailObject.HasSubSet('OnlySelected') then
    gdcDetailObject.RemoveSubSet('OnlySelected')
  else if gdcDetailObject.SelectedID.Count > 0 then
    gdcDetailObject.AddSubSet('OnlySelected');
end;

procedure Tgdc_frmMDH.actDetailOnlySelectedUpdate(Sender: TObject);
begin
  if Assigned(gdcDetailObject) then
  begin
    actDetailOnlySelected.Enabled := (gdcDetailObject <> nil)
      and (gdcDetailObject.Active)
      and Assigned(GlobalStorage)
      and ((GlobalStorage.ReadInteger('Options\Policy',
        GD_POL_EDIT_FILTERS_ID, GD_POL_EDIT_FILTERS_MASK, False) and IBLogin.InGroup) <> 0);
    actDetailOnlySelected.Checked := gdcDetailObject.HasSubSet('OnlySelected');
  end else
    actDetailOnlySelected.Enabled := False;
end;

procedure Tgdc_frmMDH.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMMDH', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMMDH', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMMDH') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMMDH',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMMDH' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMMDH', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMMDH', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmMDH.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Path: String;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMMDH', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMMDH', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMMDH') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMMDH',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMMDH' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if UserStorage <> nil then
  begin
    if ((pnlMain.Height > 1) and (pnlMain.Width > 1))
      or UserStorage.ReadBoolean('Options', 'HideMaster', False) then
    begin
      UserStorage.WriteInteger(BuildComponentPath(pnlMain), 'Height', pnlMain.Height);
      UserStorage.WriteInteger(BuildComponentPath(pnlMain), 'Width', pnlMain.Width);
    end;

    if Assigned(gdcDetailObject) and (not FInChoose) then
    begin
      Path := BuildComponentPath(gdcDetailObject, 'Selected');

      if (not gdcDetailObject.HasSubSet('OnlySelected'))
        and (gdcDetailObject.SelectedID.Count = 0) then
      begin
        UserStorage.DeleteFolder(Path);
      end else
      begin
        if (gdcDetailObject.SelectedID.WasModified) then
          UserStorage.SaveComponent(gdcDetailObject,
            gdcDetailObject.SaveSelectedToStream, 'Selected');
        UserStorage.WriteBoolean(Path, 'OnlySelected',
          gdcDetailObject.HasSubSet('OnlySelected'))
      end;
    end;
  end;

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMMDH', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMMDH', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmMDH.LoadSettingsAfterCreate;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Path: String;
  B: Boolean;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMMDH', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMMDH', KEYLOADSETTINGSAFTERCREATE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGSAFTERCREATE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMMDH') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMMDH',
  {M}          'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMMDH' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if UserStorage <> nil then
  begin
    pnlMain.Height := UserStorage.ReadInteger(BuildComponentPath(pnlMain),
      'Height', pnlMain.Height);
    pnlMain.Width := UserStorage.ReadInteger(BuildComponentPath(pnlMain),
      'Width', pnlMain.Width);

    if Assigned(gdcDetailObject) then
    begin
      UserStorage.LoadComponent(gdcDetailObject, gdcDetailObject.LoadSelectedFromStream, 'Selected', False);
      Path := BuildComponentPath(gdcDetailObject, 'Selected');
      B := UserStorage.ReadInteger(Path, 'OnlySelected', 0) <> 0;
      if B xor gdcDetailObject.HasSubSet('OnlySelected') then
      begin
        if B then
          gdcDetailObject.AddSubSet('OnlySelected')
        else
          gdcDetailObject.RemoveSubSet('OnlySelected');
      end;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMMDH', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMMDH', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE);
  {M}end;
  {END MACRO}
end;

function Tgdc_frmMDH.Get_SelectedKey: OleVariant;
var
  M, D: Variant;
  MGr, DGr: TDBGrid;
  I: Integer;
begin
  MGr := nil;
  DGr := nil;

  for I := 0 to ComponentCount - 1 do
  begin
    if (Components[I] is TDBGrid) and (TDBGrid(Components[I]).DataSource <> nil) then
    begin
      if TDBGrid(Components[I]).DataSource.DataSet = gdcObject then
      begin
        MGr := Components[I] as TDBGrid;
      end
      else if TDBGrid(Components[I]).DataSource.DataSet = gdcDetailObject then
        DGr := Components[I] as TDBGrid;
    end;
  end;

  if (MGr = nil) or (DGr = nil) then
  begin
    if gdcObject.Active and (gdcObject.RecordCount > 0) then
      M := VarArrayOf([gdcObject.ID])
    else
      M := VarArrayOf([]);

    if gdcDetailObject.Active and (gdcDetailObject.RecordCount > 0) then
      D := VarArrayOf([gdcDetailObject.ID])
    else
      D := VarArrayOf([]);

    Result := VarArrayOf([M, D]);
  end else
    Result := VarArrayOf([CreateSelectedArr(gdcObject, MGr.SelectedRows),
      CreateSelectedArr(gdcDetailObject, DGr.SelectedRows)])
end;

procedure Tgdc_frmMDH.actDetailQExportExecute(Sender: TObject);
{$IFDEF QEXPORT}
var
  ed: TVExportDialog;
{$ENDIF}
begin
  {$IFDEF QEXPORT}
  ed := TVExportDialog.Create(Self);
  try
    ed.DataSet := gdcDetailObject;
    ed.Execute;
  finally
    ed.free;
  end;
  {$ENDIF}
end;

procedure Tgdc_frmMDH.actDetailQExportUpdate(Sender: TObject);
begin
  {$IFDEF QEXPORT}
  actQExport.Visible := True;
  actQExport.Enabled := Assigned(gdcDetailObject)
    and (gdcDetailObject.State = dsBrowse);
  {$ELSE}
  actQExport.Visible := False;
  {$ENDIF}
end;

procedure Tgdc_frmMDH.actDeleteExecute(Sender: TObject);
begin
  gdcObject.DeleteMultiple2(Get_SelectedKey[0]);
end;

procedure Tgdc_frmMDH.actDetailReductionUpdate(Sender: TObject);
begin
  actDetailReduction.Enabled := (gdcDetailObject <> nil)
    and (gdcDetailObject.State = dsBrowse)
    and gdcDetailObject.CanDelete;
end;

procedure Tgdc_frmMDH.actDetailToSettingExecute(Sender: TObject);
begin
  AddToSetting(False, '', '', gdcDetailObject, GetDetailBookmarkList);
end;

procedure Tgdc_frmMDH.actDetailToSettingUpdate(Sender: TObject);
begin
  actDetailToSetting.Enabled := (gdcDetailObject <> nil)
    and (gdcDetailObject.RecordCount > 0)
    and (gdcDetailObject.State = dsBrowse)
    and gdcDetailObject.CanEdit;
end;

procedure Tgdc_frmMDH.actDetailSaveToFileExecute(Sender: TObject);
var
  frmStreamSaver: TForm;
begin
  frmStreamSaver := Tgdc_frmStreamSaver.CreateAndAssign(Self);
  (frmStreamSaver as Tgdc_frmStreamSaver).SetParams(gdcDetailObject);
  (frmStreamSaver as Tgdc_frmStreamSaver).ShowSaveForm;
end;

procedure Tgdc_frmMDH.actDetailSaveToFileUpdate(Sender: TObject);
begin
  actDetailSaveToFile.Enabled := (gdcDetailObject <> nil)
    and (gdcDetailObject.RecordCount > 0)
    and (gdcDetailObject.State = dsBrowse)
    and gdcDetailObject.CanEdit;
end;

procedure Tgdc_frmMDH.actDetailLoadFromFileExecute(Sender: TObject);
var
  frmStreamSaver: TForm;
begin
  frmStreamSaver := Tgdc_frmStreamSaver.CreateAndAssign(Self);
  (frmStreamSaver as Tgdc_frmStreamSaver).SetParams(gdcDetailObject);
  (frmStreamSaver as Tgdc_frmStreamSaver).ShowLoadForm;
  gdcDetailObject.CloseOpen;
end;

procedure Tgdc_frmMDH.actDetailLoadFromFileUpdate(Sender: TObject);
begin
  actDetailLoadFromFile.Enabled := (gdcDetailObject <> nil)
    and (gdcDetailObject.State = dsBrowse)
    and gdcDetailObject.CanCreate;
end;

procedure Tgdc_frmMDH.pnlMainResize(Sender: TObject);
const
  HideMessage: Boolean = False;
var
  slSubSet: TStringList;
  I: Integer;
  rmSubSet: TStringList;
begin
  inherited;

  if (gdcDetailObject <> nil) and (gdcObject <> nil) then
  begin
    if ((pnlMain.Width = 1) or (pnlMain.Height = 1))
      and (gdcDetailObject.MasterSource <> nil) then
    begin
      slSubSet := TStringList.Create;
      rmSubSet := TStringList.Create;
      try
        RemoveSubSetList(rmSubSet);
        slSubSet.CommaText := gdcDetailObject.SubSet;
        for I := slSubSet.Count - 1 downto 0 do
        begin
          if rmSubSet.IndexOf(slSubSet[I]) > -1 then
             slSubSet.Delete(I);
        end;
        if slSubSet.Count = 0 then
          slSubSet.Add('All');

        gdcDetailObject.Close;

        FSavedMasterSource := gdcDetailObject.MasterSource;
        FSavedSubSet := gdcDetailObject.SubSet;

        gdcDetailObject.MasterSource := nil;
        gdcDetailObject.SubSet := slSubSet.CommaText;//'All';

        gdcDetailObject.Open;

        gdcObject.Close;
      finally
        slSubSet.Free;
        rmSubSet.Free;
      end;

      tbMainToolbar.Visible := False;
      tbMainInvariant.Visible := False;
      tbChooseMain.Visible := False;
      tbMainCustom.Visible := False;

    end else if ((pnlMain.Width > 1) and (pnlMain.Height > 1))
      and (gdcDetailObject.MasterSource = nil)
      and (FSavedSubSet > '') then
    begin
      gdcDetailObject.Close;

      gdcDetailObject.MasterSource := FSavedMasterSource;
      gdcDetailObject.SubSet := FSavedSubSet;

      FSavedMasterSource := nil;
      FSavedSubSet := '';

      gdcObject.Open;
      gdcDetailObject.Open;

      tbMainToolbar.Visible := True;
      tbMainInvariant.Visible := True;
      tbChooseMain.Visible := True;
      tbMainCustom.Visible := True;
    end;

    if Assigned(UserStorage)
      and (not UserStorage.ReadBoolean('Options', 'HideMaster', False))
      and (Assigned(gdcDetailObject))
      and (gdcDetailObject.MasterSource = nil)
      and (not (cfsSetting in CreateableFormState))
      and (not HideMessage)
      and ((pnlMain.Width <= 1) or (pnlMain.Height <= 1))
    then
    begin
      MessageBox(Handle,
        'При следующей загрузке программы главная панель будет открыта.'#13#10 +
        'Если Вы хотите, чтобы состояние главной панели сохранялось, установите'#13#10 +
        'соответствующий флаг в окне "Опции" пункта "Сервис" главного меню.',
        'Внимание',
        MB_OK or MB_ICONINFORMATION);
      HideMessage := True;
    end;

  end;
end;

procedure Tgdc_frmMDH.RemoveSubSetList(S: TStrings);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_MDH_REMOVESUBSETLIST('TGDC_FRMMDH', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMMDH', KEYREMOVESUBSETLIST);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYREMOVESUBSETLIST]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMMDH') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(S)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMMDH',
  {M}        'REMOVESUBSETLIST', KEYREMOVESUBSETLIST, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMMDH' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  S.Clear;
  S.Add('ByLBRB');
  S.Add('ByParent');
  S.Add('ByRootID');

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMMDH', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMMDH', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST);
  {M}end;
  {END MACRO}
end;

class procedure Tgdc_frmMDH.RegisterMethod;
begin
  RegisterFrmClassMethod(Tgdc_frmMDH, 'RemoveSubSetList', 'Self: Object; S: Object', '');
end;

function Tgdc_frmMDH.OnInvoker(const Name: WideString;
  AnParams: OleVariant): OleVariant;
begin
  if  AnsiUpperCase(Name) = 'REMOVESUBSETLIST' then
  begin
    RemoveSubSetList(InterfaceToObject(AnParams[1]) as TStrings)
  end else
    inherited OnInvoker(Name, AnParams);
end;

procedure Tgdc_frmMDH.DoOnFilterChanged(Sender: TObject);
var
  S, H: String;
begin
  S := '';
  H := '';

  if Assigned(gdcObject)
    and Assigned(gdcObject.Filter)
    and (gdcObject.Filter.FilterName > '') then
  begin
    S := gdcObject.Filter.FilterName;
    actFilter.Hint := gdcObject.Filter.FilterName + #13#10#13#10 + gdcObject.Filter.FilterString;
    H := 'Главный объект: ' + actFilter.Hint;
    actFilter.ImageIndex := 257;
  end else
  begin
    actFilter.Hint := 'Фильтр';
    actFilter.ImageIndex := 20;
  end;

  if Assigned(gdcDetailObject)
    and Assigned(gdcDetailObject.Filter)
    and (gdcDetailObject.Filter.FilterName > '') then
  begin
    if S > '' then
      S := S + ', ';

    if H > '' then
      H := H + #13#10 + #13#10;

    S := S + gdcDetailObject.Filter.FilterName;

    actDetailFilter.Hint := gdcDetailObject.Filter.FilterName + #13#10#13#10 + gdcDetailObject.Filter.FilterString;
    H := H + 'Детальный объект: ' + actDetailFilter.Hint;
    actDetailFilter.ImageIndex := 257;
  end else
  begin
    actDetailFilter.Hint := 'Фильтр';
    actDetailFilter.ImageIndex := 20;
  end;

  if S > '' then
    sbMain.Panels[0].Text := 'Фильтр: ' + S
  else
    sbMain.Panels[0].Text := 'Нет фильтрации';

  sbMain.Hint := H;  
end;

procedure Tgdc_frmMDH.TBDockTopRequestDock(Sender: TObject;
  Bar: TTBCustomDockableWindow; var Accept: Boolean);
begin
  Accept := ((Bar <> tbDetailToolbar)
    and (Bar <> tbDetailCustom)) or (not tbMainToolbar.Visible);
end;

procedure Tgdc_frmMDH.TBDockDetailRequestDock(Sender: TObject;
  Bar: TTBCustomDockableWindow; var Accept: Boolean);
begin
  Accept := (Bar <> tbMainToolbar)
    and (Bar <> tbMainCustom)
    and (Bar <> tbMainInvariant);
end;

procedure Tgdc_frmMDH.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  if (Operation = opRemove) and (AComponent = FgdcDetailObject) then
  begin
    FGdcDetailObject := nil;
  end;
end;

procedure Tgdc_frmMDH.actEditExecute(Sender: TObject);
begin
  gdcObject.EditMultiple2(Get_SelectedKey[0]);
end;

procedure Tgdc_frmMDH.actPropertiesExecute(Sender: TObject);
begin
  gdcObject.EditMultiple2(Get_SelectedKey[0], 'Tgdc_dlgObjectProperties');
end;

procedure Tgdc_frmMDH.DoCreate;
begin
  inherited;

  // идея такая, что пользователь не может скрыть тулбар,
  // если на нем есть кнопки
  tbDetailCustom.Visible := tbDetailCustom.Items.Count > 0;
end;

procedure Tgdc_frmMDH.actCommitExecute(Sender: TObject);
begin
  if Assigned(gdcDetailObject) then
  begin
    if gdcDetailObject.State in dsEditModes then
      gdcDetailObject.Post;

    if (gdcDetailObject.Transaction <> gdcObject.Transaction)
      and (gdcDetailObject.Transaction.InTransaction)
      and (gdcDetailObject.Transaction <> gdcDetailObject.ReadTransaction) then
    begin
      gdcDetailObject.Transaction.Commit;
    end;
  end;

  inherited;
end;

procedure Tgdc_frmMDH.actDetailLinkObjectUpdate(Sender: TObject);
begin
  actDetailLinkObject.Enabled := Assigned(gdcDetailObject)
    and (gdcDetailObject.State in [dsBrowse, dsEdit])
    and (not gdcDetailObject.IsEmpty)
    and gdcDetailObject.CanView;
end;

procedure Tgdc_frmMDH.actDetailLinkObjectExecute(Sender: TObject);
var
  R: TRect;
begin
  if FgdcLink = nil then
  begin
    FgdcLink := TgdcLink.Create(nil);
  end;

  with tbDetailToolbar do
  begin
    R := View.Find(tbiDetailLinkObject).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;

  FgdcLink.ObjectKey := gdcDetailObject.ID;
  FgdcLink.PopupMenu(R.Left, R.Bottom);
end;

procedure Tgdc_frmMDH.actDetailFilterUpdate(Sender: TObject);
begin
  actDetailFilter.Enabled := (gdcDetailObject <> nil)
    and (gdcDetailObject.State = dsBrowse);
end;

procedure Tgdc_frmMDH.pnlSearchDetailEnter(Sender: TObject);
begin
  inherited;
  btnOkChoose.Default := False;
end;

procedure Tgdc_frmMDH.pnlSearchDetailExit(Sender: TObject);
begin
  inherited;
  btnOkChoose.Default := True;
end;

procedure Tgdc_frmMDH.DoShowAllFields(Sender: TObject);
var
  I: Integer;
begin
  Assert(Sender is TWinControl);

  if TWinControl(Sender).Parent = sbSearchDetail then
  begin
    if pnlSearchDetail.Visible then
    begin
      gdcDetailObject.ExtraConditions.Text := FDetailPreservedConditions;
      FreeAndNil(FFieldOriginDetail);

      for I := sbSearchDetail.ControlCount - 1 downto 0 do
      begin
        sbSearchDetail.Controls[I].Free;
      end;

      SetupSearchPanel(gdcDetailObject,
        pnlSearchDetail,
        sbSearchDetail,
        nil{sSearchDetail},
        FFieldOriginDetail,
        FDetailPreservedConditions,
        True);
    end;
  end else
    inherited;
end;

procedure Tgdc_frmMDH.tbiDetailNewPopup(Sender: TTBCustomItem;
  FromLink: Boolean);
begin
  if gdcDetailObject <> nil then
    FillPopupNew(gdcDetailObject, Sender, DoOnDetailDescendantClick);
end;

initialization
  RegisterFrmClass(Tgdc_frmMDH);
  Tgdc_frmMDH.RegisterMethod;

finalization
  UnRegisterFrmClass(Tgdc_frmMDH);

{@DECLARE MACRO Inh_MDH_RemoveSubSetList(%ClassName%, %MethodName%, %MethodKey%)
try
  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  begin
    SetFirstMethodAssoc(%ClassName%, %MethodKey%);
    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
    if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
    begin
      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(S)]);
      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
        %MethodName%, %MethodKey%, Params, LResult) then exit;
    end else
      if tmpStrings.LastClass.gdClassName <> %ClassName% then
      begin
        Inherited;
        Exit;
      end;
  end;
END MACRO}
  
end.


