unit gdc_frmMD2H_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Contnrs, Forms, Dialogs,
  gdc_frmMDH_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, gdcBase;

type
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
    tbsiSubDetailNew: TTBSubmenuItem;
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
    procedure tbsiSubDetailNewPopup(Sender: TTBCustomItem;
      FromLink: Boolean);

  private
    FgdcSubDetailObject: TgdcBase;

    FpmSubDetailNewObject: TObjectList;

    procedure SetgdcSubDetailObject(const Value: TgdcBase);

    procedure DoOnSubDetailDescendantClick (Sender: TObject);
    procedure FillPopupSubDetailNew(ATBSubmenuItem: TTBSubmenuItem);

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

  FpmSubDetailNewObject.Free;  

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
    {if (FSubType > '') and (FgdcDetailObject <> nil) then
      FgdcDetailObject.SubType := FSubType;}
    if dsSubDetail.DataSet <> Value then
      dsSubDetail.DataSet := Value;
    if FgdcSubDetailObject <> nil then
    begin
      if FgdcSubDetailObject.Owner <> Self then
        FgdcSubDetailObject.FreeNotification(Self);
      FgdcSubDetailObject.OnFilterChanged := DoOnFilterChanged;
      DoOnFilterChanged(nil);
      //tbsiMainMenuDetailObject.Caption := FgdcDetailObject.GetDisplayName(FgdcDetailObject.SubType);
    end;
  end;
end;

procedure Tgdc_frmMD2H.DoOnSubDetailDescendantClick (Sender: TObject);
var
  CE: TgdBaseEntry;
  C: TgdcFullClass;
  Index: Integer;
begin
  if Sender is TTBItem then
  begin
    Index := (Sender as TTBItem).Tag;
    CE := TCreatedObject(FpmSubDetailNewObject[Index]).Obj as TgdBaseEntry;
  end else
    raise Exception.Create('Invalid class.');

  C.gdClass := CE.gdcClass;
  C.SubType := CE.SubType;

  if gdcSubDetailObject <> nil then
    gdcSubDetailObject.CreateDialog(C);
end;

procedure Tgdc_frmMD2H.FillPopupSubDetailNew(ATBSubmenuItem: TTBSubmenuItem);
var
  TBI: TTBItem;
  I: Integer;
begin
  if gdcSubDetailObject = nil then
    raise Exception.Create('gdcSubDetailObject is nil.');

  if FpmSubDetailNewObject <> nil then
  begin
    FpmSubDetailNewObject.Free;
    FpmSubDetailNewObject := nil;
  end;

  FpmSubDetailNewObject := TObjectList.Create;

  gdcSubDetailObject.GetDescendantList(FpmSubDetailNewObject, True);

  ATBSubmenuItem.Clear;

  for I := 0 to FpmSubDetailNewObject.Count - 1 do
  begin
    TBI := TTBItem.Create(ATBSubmenuItem);
    TBI.Tag := I;
    TBI.Caption := TCreatedObject(FpmSubDetailNewObject[I]).Caption;

    if TCreatedObject(FpmSubDetailNewObject[I]).IsSubLevel and gdcObject.IsEmpty then
      TBI.Enabled := False;

    TBI.OnClick := DoOnSubDetailDescendantClick;
    TBI.ImageIndex := 0;

    ATBSubmenuItem.Add(TBI);
  end;
end;

procedure Tgdc_frmMD2H.actSubDetailNewExecute(Sender: TObject);
begin
  if (gdcSubDetailObject <> nil) and (not gdcSubDetailObject.IsAbstractClass) then
    gdcSubDetailObject.CreateDialog;
end;

procedure Tgdc_frmMD2H.actSubDetailNewUpdate(Sender: TObject);
var
  I: Integer;
  DescendantCount: Integer;
  SubMenu: Boolean;
begin
  if gdcSubDetailObject <> nil then
    DescendantCount := gdcSubDetailObject.GetDescendantCount(True)
  else
    DescendantCount := 0;

  actSubDetailNew.Enabled := (gdcObject <> nil)
    and (gdcDetailObject <> nil)
    and (gdcSubDetailObject <> nil)
    and gdcSubDetailObject.CanCreate
    and ((gdcDetailObject.RecordCount > 0)
      or (gdcSubDetailObject.HasSubSet('All')))
    and (DescendantCount > 0);

  SubMenu := DescendantCount > 1;

  if not SubMenu then
    SubMenu := (gdcSubDetailObject <> nil) and (gdcSubDetailObject.IsAbstractClass) and (DescendantCount > 0);

  With tbSubDetailToolbar.Items do
  begin
    for I := 0 to Count - 1 do
    begin
      if (Items[I] is TTBSubmenuItem) and (Items[I].Action = (Sender as TBasicAction)) then
      begin
        (Items[I] as TTBSubmenuItem).DropDownCombo := SubMenu;
        Break;
      end
    end;
  end;
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
  //Path: String;
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

  if UserStorage <> nil then
  begin
    {
    if ((pnlSubdetail.Height > 1) and (pnlSubDetail.Width > 1)) then
    begin
      UserStorage.WriteInteger(BuildComponentPath(pnlSubDetail),
        'Height', pnlSubDetail.Height);
      UserStorage.WriteInteger(BuildComponentPath(pnlSubDetail),
        'Width', pnlSubDetail.Width);
    end;
    }

    {
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
    }
  end;

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
  //Path: String;
  //B: Boolean;
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

  if UserStorage <> nil then
  begin
    {
    pnlSubDetail.Height := UserStorage.ReadInteger(BuildComponentPath(pnlSubDetail),
      'Height', pnlSubDetail.Height);
    pnlSubDetail.Width := UserStorage.ReadInteger(BuildComponentPath(pnlSubDetail),
      'Width', pnlSubDetail.Width);
    }

    {
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
    }
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMMD2H', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMMD2H', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmMD2H.tbsiSubDetailNewPopup(Sender: TTBCustomItem;
  FromLink: Boolean);
begin
  if (TTBSubmenuItem(Sender).DropDownCombo) and (gdcSubDetailObject <> nil) then
    FillPopupSubDetailNew(TTBSubmenuItem(Sender));
end;

initialization
  RegisterFrmClass(Tgdc_frmMD2H);

finalization
  UnRegisterFrmClass(Tgdc_frmMD2H);
end.
