
unit gdc_frmUserGroup_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ComCtrls, ToolWin, ExtCtrls, IBCustomDataSet, gdcBase, gdcUser,
  IBDatabase, StdCtrls, gsIBLookupComboBox, dmDatabase_unit, TB2Item,
  TB2Dock, TB2Toolbar, gd_MacrosMenu;

type
  Tgdc_frmUserGroup = class(Tgdc_frmSGR)
    gdcUserGroup: TgdcUserGroup;
    IBTransaction: TIBTransaction;
    TBControlItem1: TTBControlItem;
    chbxAllUsers: TCheckBox;
    TBControlItem2: TTBControlItem;
    ibcbUser: TgsIBLookupComboBox;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem1: TTBItem;
    actAddGroupToUser: TAction;

    procedure FormCreate(Sender: TObject);
    procedure ibcbUserChange(Sender: TObject);
    procedure chbxAllUsersClick(Sender: TObject);
    procedure actAddGroupToUserUpdate(Sender: TObject);
    procedure actAddGroupToUserExecute(Sender: TObject);

  protected
    procedure DoOnFilterChanged(Sender: TObject); override;

  public
    procedure SaveSettings; override;
    procedure LoadSettings; override;

    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmUserGroup: Tgdc_frmUserGroup;

implementation

{$R *.DFM}

uses
  Storages, gsStorage_CompPath,  gd_ClassList;
  
class function Tgdc_frmUserGroup.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmUserGroup) then
    gdc_frmUserGroup := Tgdc_frmUserGroup.Create(AnOwner);
  Result := gdc_frmUserGroup;
end;

procedure Tgdc_frmUserGroup.FormCreate(Sender: TObject);
begin
  inherited;
  gdcObject := gdcUserGroup;
  if chbxAllUsers.Checked or (ibcbUser.CurrentKey = '') then
    gdcObject.SubSet := 'All'
  else begin
    gdcObject.SubSet := 'ByUser';
    gdcObject.ParamByName('USERID').AsInteger := ibcbUser.CurrentKeyInt;
  end;
  gdcObject.Open;
  DoOnFilterChanged(Self);
end;

procedure Tgdc_frmUserGroup.ibcbUserChange(Sender: TObject);
begin
  if Assigned(gdcObject) then
  begin
    if ibcbUser.CurrentKey = '' then
      gdcObject.SubSet := 'All'
    else begin
      gdcObject.Subset := 'ByUser';
      gdcObject.ParamByName('USERID').AsInteger := ibcbUser.CurrentKeyInt;
    end;
    gdcObject.Open;
    DoOnFilterChanged(Self);
  end;
end;

procedure Tgdc_frmUserGroup.chbxAllUsersClick(Sender: TObject);
begin
  ibcbUser.Enabled := not chbxAllUsers.Checked;
  if Assigned(gdcObject) then
  begin
    if chbxAllUsers.Checked or (ibcbUser.CurrentKey = '') then
      gdcObject.SubSet := 'All'
    else begin
      gdcObject.SubSet := 'ByUser';
      gdcObject.ParamByName('USERID').AsInteger := ibcbUser.CurrentKeyInt;
    end;
    gdcObject.Open;
    DoOnFilterChanged(Self);
  end;
end;

procedure Tgdc_frmUserGroup.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMUSERGROUP', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMUSERGROUP', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMUSERGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMUSERGROUP',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMUSERGROUP' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if Assigned(UserStorage) then
  begin
    UserStorage.LoadComponent(ibcbUser, ibcbUser.LoadFromStream);
    ibcbUser.CurrentKeyInt := UserStorage.ReadInteger(BuildComponentPath(ibcbUser), 'UserID', -1);
    chbxAllUsers.Checked := UserStorage.ReadBoolean(BuildComponentPath(chbxAllUsers), 'Checked', True);
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMUSERGROUP', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMUSERGROUP', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmUserGroup.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMUSERGROUP', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMUSERGROUP', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMUSERGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMUSERGROUP',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMUSERGROUP' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if Assigned(UserStorage) then
  begin
    UserStorage.SaveComponent(ibcbUser, ibcbUser.SaveToStream);
    UserStorage.WriteInteger(BuildComponentPath(ibcbUser), 'UserID', ibcbUser.CurrentKeyInt);
    UserStorage.WriteBoolean(BuildComponentPath(chbxAllUsers), 'Checked', chbxAllUsers.Checked);
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMUSERGROUP', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMUSERGROUP', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmUserGroup.DoOnFilterChanged(Sender: TObject);
begin
  inherited;
  if chbxAllUsers.Checked or (ibcbUser.CurrentKey = '') then
    //sbMain.Panels[0].Text := 'Все группы. ' + sbMain.Panels[0].Text
  else
    sbMain.Panels[0].Text := 'Группы пользователя: ' + ibcbUser.Text + '. ' + sbMain.Panels[0].Text;
end;

procedure Tgdc_frmUserGroup.actAddGroupToUserUpdate(Sender: TObject);
begin
  actAddGroupToUser.Enabled := (gdcObject <> nil) and
    (gdcObject.Active) and (gdcObject.RecordCount > 0);
end;

procedure Tgdc_frmUserGroup.actAddGroupToUserExecute(Sender: TObject);
begin
  gdcUserGroup.EditDialog('Tgdc_dlgAddGroupToUser');
end;

initialization
  RegisterFrmClass(Tgdc_frmUserGroup);

finalization
  UnRegisterFrmClass(Tgdc_frmUserGroup);
end.
