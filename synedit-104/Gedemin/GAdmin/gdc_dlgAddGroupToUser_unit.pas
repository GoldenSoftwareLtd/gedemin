
unit gdc_dlgAddGroupToUser_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, StdCtrls, gsIBLookupComboBox, DBCtrls, IBDatabase, Db,
  ActnList, IBCustomDataSet, gdcBase, gdcUser, Grids, DBGrids, gsDBGrid,
  gsIBGrid, Menus;

type
  Tgdc_dlgAddGroupToUser = class(Tgdc_dlgTR)
    actAddUser: TAction;
    actDeleteUser: TAction;
    dsUser: TDataSource;
    gbUsers: TGroupBox;
    ibgrUsers: TgsIBGrid;
    Memo1: TMemo;
    btnExclude: TButton;
    gbInclude: TGroupBox;
    ibcbUser: TgsIBLookupComboBox;
    btnInclude: TButton;
    gbGroup: TGroupBox;
    DBText1: TDBText;
    gdcUser: TgdcUser;
    procedure actAddUserExecute(Sender: TObject);
    procedure actDeleteUserExecute(Sender: TObject);
    procedure actAddUserUpdate(Sender: TObject);
    procedure actDeleteUserUpdate(Sender: TObject);

  public
    procedure SetupDialog; override;

  end;

var
  gdc_dlgAddGroupToUser: Tgdc_dlgAddGroupToUser;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_dlgAddGroupToUser.actAddUserExecute(Sender: TObject);
begin
  (gdcObject as TgdcUserGroup).AddUser(ibcbUser.CurrentKeyInt);
  gdcUser.CloseOpen;
end;

procedure Tgdc_dlgAddGroupToUser.actDeleteUserExecute(Sender: TObject);
begin
  (gdcObject as TgdcUserGroup).RemoveUser(gdcUser.ID);
  gdcUser.CloseOpen;
end;

procedure Tgdc_dlgAddGroupToUser.actAddUserUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := ibcbUser.CurrentKey > '';
end;

procedure Tgdc_dlgAddGroupToUser.actDeleteUserUpdate(Sender: TObject);
begin
  actDeleteUser.Enabled := gdcUser.Active and
    (gdcUser.RecordCount > 0);
end;

procedure Tgdc_dlgAddGroupToUser.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGADDGROUPTOUSER', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGADDGROUPTOUSER', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGADDGROUPTOUSER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGADDGROUPTOUSER',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGADDGROUPTOUSER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  gdcUser.Groups := (gdcObject as TgdcUserGroup).GetGroupMask;
  gdcUser.Open;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGADDGROUPTOUSER', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGADDGROUPTOUSER', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgAddGroupToUser);

finalization
  UnRegisterFrmClass(Tgdc_dlgAddGroupToUser);

end.
