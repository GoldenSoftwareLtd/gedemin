unit gdc_frmMD2H_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDH_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, gdcBase;

type
  TCrTBItem = Class(TTBItem);
  
  Tgdc_frmMD2H = class(Tgdc_frmMDH)
    pnlSubDetail: TPanel;
    sSubDetail: TSplitter;
    TbDockSubDetail: TTBDock;
    tbSubDetailToolbar: TTBToolbar;
    actSubDetailNew: TAction;
    dsSubDetail: TDataSource;
    actSubDetailEdit: TAction;
    actSubDetailDelete: TAction;
    actSubDetailDuplicate: TAction;
    actSubDetailPrint: TAction;
    actSubDetailReduction: TAction;
    actSubDetailFilter: TAction;
    actSubDetailProperties: TAction;
    tbiSubdetailPrint: TTBItem;
    tbiSubDetailFilter: TTBItem;
    tbiSubDetailRed: TTBItem;
    tbiSubDetailDup: TTBItem;
    tbiSubDetailDel: TTBItem;
    tbiSubDetailEdit: TTBItem;
    tbsSubdetail1: TTBSeparatorItem;
    tbiSubDetailNew: TTBItem;
    procedure actSubDetailNewExecute(Sender: TObject);
    procedure actSubDetailNewUpdate(Sender: TObject);
    procedure actSubDetailEditExecute(Sender: TObject);
    procedure actSubDetailEditUpdate(Sender: TObject);
    procedure actSubDetailDeleteExecute(Sender: TObject);
    procedure actSubDetailDeleteUpdate(Sender: TObject);
    procedure actSubDetailDuplicateExecute(Sender: TObject);
    procedure actSubDetailDuplicateUpdate(Sender: TObject);
    procedure actSubDetailReductionExecute(Sender: TObject);
    procedure actSubDetailReductionUpdate(Sender: TObject);
    procedure actSubDetailPrintExecute(Sender: TObject);
    procedure actSubDetailPrintUpdate(Sender: TObject);
    procedure actSubDetailFilterExecute(Sender: TObject);
    procedure actSubDetailFilterUpdate(Sender: TObject);
    procedure actSubDetailPropertiesExecute(Sender: TObject);
    procedure actSubDetailPropertiesUpdate(Sender: TObject);
    procedure TbDockSubDetailRequestDock(Sender: TObject;
      Bar: TTBCustomDockableWindow; var Accept: Boolean);
    procedure TBDockDetailRequestDock(Sender: TObject;
      Bar: TTBCustomDockableWindow; var Accept: Boolean);
    procedure TBDockTopRequestDock(Sender: TObject;
      Bar: TTBCustomDockableWindow; var Accept: Boolean);
    procedure tbiSubDetailNewPopup(Sender: TTBCustomItem;
      FromLink: Boolean);

  private
    FgdcSubDetailObject: TgdcBase;

    procedure SetgdcSubDetailObject(const Value: TgdcBase);

    procedure DoOnSubDetailDescendantClick (Sender: TObject);

  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    function Get_SelectedKey: OleVariant; override; safecall;

  public
    destructor Destroy; override;

    procedure SaveSettings; override;
    procedure LoadSettingsAfterCreate; override;

    property gdcSubDetailObject: TgdcBase read FgdcSubDetailObject
      write SetgdcSubDetailObject;
  end;

var
  gdc_frmMD2H: Tgdc_frmMD2H;

implementation

{$R *.DFM}

uses
  gd_ClassList, Storages, gsStorage_CompPath;

{ Tgdc_frmMD2H }

destructor Tgdc_frmMD2H.Destroy;
begin
  if Assigned(FgdcSubDetailObject) then
    FgdcSubDetailObject.OnFilterChanged := nil;
  inherited;
end;

procedure Tgdc_frmMD2H.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  if (Operation = opRemove) and (AComponent = FgdcSubDetailObject) then
  begin
    FGdcSubDetailObject := nil;
  end;
end;

procedure Tgdc_frmMD2H.SetgdcSubDetailObject(const Value: TgdcBase);
begin
  if FgdcSubDetailObject <> Value then
  begin
    if Assigned(FgdcSubDetailObject) then
      FgdcSubDetailObject.RemoveFreeNotification(Self);

    FgdcSubDetailObject := Value;
    if dsSubDetail.DataSet <> Value then
      dsSubDetail.DataSet := Value;
    if FgdcSubDetailObject <> nil then
    begin
      if FgdcSubDetailObject.Owner <> Self then
        FgdcSubDetailObject.FreeNotification(Self);
      FgdcSubDetailObject.OnFilterChanged := DoOnFilterChanged;
      DoOnFilterChanged(nil);

      if gdClassList.Get(TgdBaseEntry,
        FgdcSubDetailObject.ClassName, FgdcSubDetailObject.SubType).Count > 0 then
      begin
        TCrTBItem(tbiSubDetailNew).ItemStyle :=
          TCrTBItem(tbiSubDetailNew).ItemStyle + [tbisSubMenu, tbisSubitemsEditable, tbisCombo];
        tbiSubDetailNew.OnPopup := tbiSubDetailNewPopup;
      end;
    end;
  end;
end;

procedure Tgdc_frmMD2H.DoOnSubDetailDescendantClick (Sender: TObject);
var
  CE: TgdBaseEntry;
  C: TgdcFullClass;
begin
  if (gdcSubDetailObject <> nil) and ((Sender as TTBItem).Tag <> 0) then
  begin
    CE := TgdBaseEntry((Sender as TTBItem).Tag);
    C.gdClass := CE.gdcClass;
    C.SubType := CE.SubType;
    gdcSubDetailObject.CreateDialog(C);
  end;
end;

procedure Tgdc_frmMD2H.actSubDetailNewExecute(Sender: TObject);
begin
  gdcSubDetailObject.CreateDescendant;
end;

procedure Tgdc_frmMD2H.actSubDetailNewUpdate(Sender: TObject);
begin
  actSubDetailNew.Enabled := (gdcObject <> nil)
    and (gdcDetailObject <> nil)
    and (gdcSubDetailObject <> nil)
    and gdcSubDetailObject.CanCreate
    and ((gdcDetailObject.RecordCount > 0)
      or (gdcSubDetailObject.HasSubSet('All')));
end;

procedure Tgdc_frmMD2H.actSubDetailEditExecute(Sender: TObject);
begin
  gdcSubDetailObject.EditMultiple2(Get_SelectedKey[2]);
end;

procedure Tgdc_frmMD2H.actSubDetailEditUpdate(Sender: TObject);
begin
  actSubDetailEdit.Enabled := (gdcObject <> nil)
    and (gdcDetailObject <> nil)
    and (gdcSubDetailObject <> nil)
    and (gdcSubDetailObject.RecordCount > 0)
    and gdcSubDetailObject.CanView;
end;

procedure Tgdc_frmMD2H.actSubDetailDeleteExecute(Sender: TObject);
begin
  gdcSubDetailObject.DeleteMultiple2(Get_SelectedKey[2]);
end;

procedure Tgdc_frmMD2H.actSubDetailDeleteUpdate(Sender: TObject);
begin
   actSubDetailDelete.Enabled :=
    (gdcSubDetailObject <> nil) and
    (gdcSubDetailObject.RecordCount > 0)  and
    gdcSubDetailObject.CanDelete;
end;

procedure Tgdc_frmMD2H.actSubDetailDuplicateExecute(Sender: TObject);
begin
  gdcSubDetailObject.CopyDialog;
end;

procedure Tgdc_frmMD2H.actSubDetailDuplicateUpdate(Sender: TObject);
begin
  actSubDetailDuplicate.Enabled :=
    (gdcSubDetailObject <> nil)
    and (gdcSubDetailObject.RecordCount > 0)
    and gdcSubDetailObject.CanCreate
    and gdcSubDetailObject.CanEdit;
end;

procedure Tgdc_frmMD2H.actSubDetailReductionExecute(Sender: TObject);
begin
  gdcSubDetailObject.Reduction(nil);
end;

procedure Tgdc_frmMD2H.actSubDetailReductionUpdate(Sender: TObject);
begin
  actSubDetailReduction.Enabled := (gdcSubDetailObject <> nil)
    and (gdcSubDetailObject.State = dsBrowse)
    and gdcSubDetailObject.CanDelete;
end;

procedure Tgdc_frmMD2H.actSubDetailPrintExecute(Sender: TObject);
var
  R: TRect;
begin
  with tbSubDetailToolbar do
  begin
    R := View.Find(tbiSubDetailPrint).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;
  gdcSubDetailObject.PopupReportMenu(R.Left, R.Bottom);
end;

procedure Tgdc_frmMD2H.actSubDetailPrintUpdate(Sender: TObject);
begin
  actSubDetailPrint.Enabled := gdcSubDetailObject <> nil;
end;

procedure Tgdc_frmMD2H.actSubDetailFilterExecute(Sender: TObject);
var
  R: TRect;
begin
  with tbSubDetailToolbar do
  begin
    R := View.Find(tbiSubDetailFilter).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;
  gdcSubDetailObject.PopupFilterMenu(R.Left, R.Bottom);
end;

procedure Tgdc_frmMD2H.actSubDetailFilterUpdate(Sender: TObject);
begin
  actSubDetailFilter.Enabled := gdcSubDetailObject <> nil;
end;

procedure Tgdc_frmMD2H.actSubDetailPropertiesExecute(Sender: TObject);
begin
  gdcSubDetailObject.EditMultiple2(Get_SelectedKey[2], 'Tgdc_dlgObjectProperties');
end;

procedure Tgdc_frmMD2H.actSubDetailPropertiesUpdate(Sender: TObject);
begin
  actSubDetailProperties.Enabled := Assigned(gdcSubDetailObject)
    and (gdcSubDetailObject.RecordCount > 0)
    and (gdcSubDetailObject.State = dsBrowse);
end;

procedure Tgdc_frmMD2H.TbDockSubDetailRequestDock(Sender: TObject;
  Bar: TTBCustomDockableWindow; var Accept: Boolean);
begin
  Accept := (Bar <> tbMainToolbar)
    and (Bar <> tbMainCustom)
    and (Bar <> tbMainInvariant)
    and (Bar <> tbDetailToolbar)
    and (Bar <> tbDetailCustom);
end;

procedure Tgdc_frmMD2H.TBDockDetailRequestDock(Sender: TObject;
  Bar: TTBCustomDockableWindow; var Accept: Boolean);
begin
  inherited;

  Accept := Accept and (Bar <> tbSubdetailToolbar);
end;

procedure Tgdc_frmMD2H.TBDockTopRequestDock(Sender: TObject;
  Bar: TTBCustomDockableWindow; var Accept: Boolean);
begin
  inherited;

  Accept := Accept and (Bar <> tbSubdetailToolbar);
end;

function Tgdc_frmMD2H.Get_SelectedKey: OleVariant;
begin
  Result := VarArrayOf([VarArrayOf([]), VarArrayOf([]), VarArrayOf([])]);
end;

procedure Tgdc_frmMD2H.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMMD2H', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMMD2H', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMMD2H') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMMD2H',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMMD2H' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMMD2H', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMMD2H', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmMD2H.LoadSettingsAfterCreate;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMMD2H', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMMD2H', KEYLOADSETTINGSAFTERCREATE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGSAFTERCREATE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMMD2H') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMMD2H',
  {M}          'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMMD2H' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMMD2H', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMMD2H', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmMD2H.tbiSubDetailNewPopup(Sender: TTBCustomItem;
  FromLink: Boolean);
begin
  if gdcSubDetailObject <> nil then
    FillPopupNew(gdcSubDetailObject, Sender, DoOnSubDetailDescendantClick);
end;

initialization
  RegisterFrmClass(Tgdc_frmMD2H);

finalization
  UnRegisterFrmClass(Tgdc_frmMD2H);
end.
