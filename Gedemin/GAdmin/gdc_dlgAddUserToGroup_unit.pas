// ShlTanya, 24.02.2019

unit gdc_dlgAddUserToGroup_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, StdCtrls, gsIBLookupComboBox, DBCtrls, IBDatabase, Db,
  ActnList, IBCustomDataSet, gdcBase, gdcUser, Grids, DBGrids, gsDBGrid,
  gsIBGrid, Menus;

type
  Tgdc_dlgAddUserToGroup = class(Tgdc_dlgTR)
    actAddGroup: TAction;
    actDeleteGroup: TAction;
    gdcUserGroup: TgdcUserGroup;
    dsUserGroup: TDataSource;
    gbGroups: TGroupBox;
    ibgrUserGroups: TgsIBGrid;
    Memo1: TMemo;
    btnExclude: TButton;
    gbInclude: TGroupBox;
    ibcbGroups: TgsIBLookupComboBox;
    btnInclude: TButton;
    gbUser: TGroupBox;
    DBText1: TDBText;
    Label1: TLabel;
    Label2: TLabel;
    procedure actAddGroupExecute(Sender: TObject);
    procedure actDeleteGroupExecute(Sender: TObject);
    procedure actAddGroupUpdate(Sender: TObject);
    procedure actDeleteGroupUpdate(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);

  public
    procedure SyncControls; override;
    procedure SetupDialog; override;
  end;

var
  gdc_dlgAddUserToGroup: Tgdc_dlgAddUserToGroup;

implementation

{$R *.DFM}

uses
  gd_ClassList;


procedure Tgdc_dlgAddUserToGroup.actAddGroupExecute(Sender: TObject);
begin
  with TgdcUserGroup.CreateSingularByID(Self,
    gdcObject.Database, gdcObject.Transaction,
    ibcbGroups.CurrentKeyInt) as TgdcUserGroup do
  try
    AddUser(gdcObject as TgdcUser);
    gdcUserGroup.Mask := gdcObject.FieldByName('ingroup').AsInteger;
    gdcUserGroup.Open;
  finally
    Free;
  end;
end;

procedure Tgdc_dlgAddUserToGroup.actDeleteGroupExecute(Sender: TObject);
begin
  gdcUserGroup.RemoveUser(gdcObject as TgdcUser);
  gdcUserGroup.Mask := gdcObject.FieldByName('ingroup').AsInteger;
  gdcUserGroup.Open;
end;

procedure Tgdc_dlgAddUserToGroup.actAddGroupUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := ibcbGroups.CurrentKey > '';
end;

procedure Tgdc_dlgAddUserToGroup.actDeleteGroupUpdate(Sender: TObject);
begin
  actDeleteGroup.Enabled := gdcUserGroup.Active and
    (gdcUserGroup.RecordCount > 0);
end;

procedure Tgdc_dlgAddUserToGroup.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGADDUSERTOGROUP', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGADDUSERTOGROUP', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGADDUSERTOGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGADDUSERTOGROUP',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGADDUSERTOGROUP' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  gdcUserGroup.Mask := gdcObject.FieldByName('ingroup').AsInteger;
  gdcUserGroup.Open;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGADDUSERTOGROUP', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGADDUSERTOGROUP', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAddUserToGroup.actOkUpdate(Sender: TObject);
begin
  if Assigned(gdcObject)
    and gdcObject.Active
    and (not gdcObject.IsEmpty)
    and (gdcObject.FieldByName('ingroup').AsInteger <> 0) then
  begin
    inherited;
  end else
    actOk.Enabled := False;
end;

procedure Tgdc_dlgAddUserToGroup.SyncControls;
begin
  inherited;

  if Assigned(gdcObject) then
  begin
    Label2.Caption := '$' +
      IntToHex(gdcObject.FieldByName('ingroup').AsInteger, 8)
  end;
end;

initialization
  RegisterFrmClass(Tgdc_dlgAddUserToGroup);

finalization
  UnRegisterFrmClass(Tgdc_dlgAddUserToGroup);
end.
