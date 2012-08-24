
unit gdc_frmUser_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ComCtrls, ToolWin, ExtCtrls, IBCustomDataSet, gdcBase, gdcUser, gdcConst,
  StdCtrls, gsIBLookupComboBox, IBDatabase, TB2Item, TB2Dock, TB2Toolbar,
  gd_MacrosMenu;

type
  Tgdc_frmUser = class(Tgdc_frmSGR)
    gdcUser: TgdcUser;
    IBTransaction: TIBTransaction;
    actUserGroups: TAction;
    actRecreateAllUsers: TAction;
    TBControlItem1: TTBControlItem;
    chbxAllGroups: TCheckBox;
    TBControlItem2: TTBControlItem;
    ibcbUserGroup: TgsIBLookupComboBox;
    TBSeparatorItem3: TTBSeparatorItem;
    TBItem3: TTBItem;
    TBItem4: TTBItem;
    tbiUsersGroups: TTBItem;
    tbiRecreateAllUsers: TTBItem;
    tbi_mm_sep5_2: TTBSeparatorItem;

    procedure FormCreate(Sender: TObject);
    procedure chbxAllGroupsClick(Sender: TObject);
    procedure ibcbUserGroupChange(Sender: TObject);
    procedure actUserGroupsExecute(Sender: TObject);
    procedure actRecreateAllUsersExecute(Sender: TObject);
    procedure actRecreateAllUsersUpdate(Sender: TObject);

  protected
    procedure DoOnFilterChanged(Sender: TObject); override;

  public
    procedure SaveSettings; override;
    procedure LoadSettings; override;

    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmUser: Tgdc_frmUser;

implementation

{$R *.DFM}

uses
  Storages, gsStorage_CompPath,  gd_ClassList, gd_security;

class function Tgdc_frmUser.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmUser) then
    gdc_frmUser := Tgdc_frmUser.Create(AnOwner);
  Result := gdc_frmUser;
end;

procedure Tgdc_frmUser.FormCreate(Sender: TObject);
begin
  inherited;

  gdcUser.SubType := FSubType;

  if chbxAllGroups.Checked or (ibcbUserGroup.CurrentKey = '') then
  begin
    ibcbUserGroup.CurrentKey := '';
    gdcUser.SubSet := 'All';
  end else
  begin
    gdcUser.SubSet := 'ByUserGroup';
    gdcUser.Groups := TgdcUserGroup.GetGroupMask(ibcbUserGroup.CurrentKeyInt);
  end;

  gdcObject := gdcUser;
  gdcObject.Open;

  DoOnFilterChanged(Self);
end;

procedure Tgdc_frmUser.chbxAllGroupsClick(Sender: TObject);
begin
  ibcbUserGroup.Enabled := not chbxAllGroups.Checked;

  if Assigned(gdcObject) then
  begin
    if chbxAllGroups.Checked or (ibcbUserGroup.CurrentKey = '') then
    begin
      ibcbUserGroup.CurrentKey := '';
      gdcObject.SubSet := 'All';
    end else
    begin
      gdcObject.SubSet := 'ByUserGroup';
      (gdcObject as TgdcUser).Groups := TgdcUserGroup.GetGroupMask(ibcbUserGroup.CurrentKeyInt);
    end;

    gdcObject.Open;

    DoOnFilterChanged(Self);
  end;
end;

procedure Tgdc_frmUser.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMUSER', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMUSER', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMUSER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMUSER',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMUSER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if Assigned(UserStorage) then
  begin
    UserStorage.LoadComponent(ibcbUserGroup, ibcbUserGroup.LoadFromStream);
    ibcbUserGroup.CurrentKeyInt := UserStorage.ReadInteger(BuildComponentPath(ibcbUserGroup), 'GroupID', -1);
    chbxAllGroups.Checked := UserStorage.ReadBoolean(BuildComponentPath(chbxAllGroups), 'Checked', True);
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMUSER', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMUSER', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmUser.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMUSER', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMUSER', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMUSER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMUSER',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMUSER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if Assigned(UserStorage) then
  begin
    UserStorage.SaveComponent(ibcbUserGroup, ibcbUserGroup.SaveToStream);
    UserStorage.WriteInteger(BuildComponentPath(ibcbUserGroup), 'GroupID', ibcbUserGroup.CurrentKeyInt);
    UserStorage.WriteBoolean(BuildComponentPath(chbxAllGroups), 'Checked', chbxAllGroups.Checked);
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMUSER', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMUSER', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmUser.ibcbUserGroupChange(Sender: TObject);
begin
  if Assigned(gdcObject) then
  begin
    if ibcbUserGroup.CurrentKey = '' then
      gdcObject.SubSet := 'All'
    else begin
      gdcObject.SubSet := 'ByUserGroup';
      (gdcObject as TgdcUser).Groups := 1 shl (ibcbUserGroup.CurrentKeyInt - 1);
    end;
    gdcObject.Open;
    DoOnFilterChanged(Self);
  end;   
end;

procedure Tgdc_frmUser.DoOnFilterChanged(Sender: TObject);
begin
  inherited;
  if chbxAllGroups.Checked or (ibcbUserGroup.CurrentKey = '') then
    //sbMain.Panels[0].Text := 'Все группы. ' + sbMain.Panels[0].Text
  else
    sbMain.Panels[0].Text := 'Входят в группу: ' + ibcbUserGroup.Text + '. ' + sbMain.Panels[0].Text;
end;

procedure Tgdc_frmUser.actUserGroupsExecute(Sender: TObject);
begin
  gdcUser.EditDialog('Tgdc_dlgAddUserToGroup');
end;

procedure Tgdc_frmUser.actRecreateAllUsersExecute(Sender: TObject);
begin
  if IBLogin.IsEmbeddedServer then
    MessageBox(Handle,
      'Вы используете встроенный сервер Firebird. Пересоздать пользователей'#13#10 +
      'можно только при сетевом подключении.'#13#10#13#10 +
      'Проверьте, как указан путь к базе данных в параметрах подключения.'#13#10 +
      'Формат сетевого подключения: <сервер>:<путь к базе данных>',
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL)
  else
    gdcUser.RecreateAllUsers;
end;

procedure Tgdc_frmUser.actRecreateAllUsersUpdate(Sender: TObject);
begin
  actRecreateAllUsers.Enabled := gdcUser.Active
    and (gdcUser.RecordCount > 0)
    and Assigned(IBLogin);
end;

initialization
  RegisterFrmClass(Tgdc_frmUser);

finalization
  UnRegisterFrmClass(Tgdc_frmUser);
end.
