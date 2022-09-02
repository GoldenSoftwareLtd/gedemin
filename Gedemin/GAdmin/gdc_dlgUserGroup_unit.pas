// ShlTanya, 24.02.2019

unit gdc_dlgUserGroup_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, Mask, Db, IBCustomDataSet, IBQuery, IBUpdateSQL, ExtCtrls,
  ActnList, IBDatabase, ComCtrls, gdc_dlgG_unit, Menus;

type
  Tgdc_dlgUserGroup = class(Tgdc_dlgG)
    dbeName: TDBEdit;
    dbmDiscription: TDBMemo;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    cbDisabled: TDBCheckBox;
    actUsers: TAction;
    DBText1: TDBText;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    actRights: TAction;
    procedure actUsersExecute(Sender: TObject);
    procedure actRightsExecute(Sender: TObject);
  end;

var
  gdc_dlgUserGroup: Tgdc_dlgUserGroup;

implementation

uses
  dmDataBase_unit, gd_ClassList, gdcUserGroup_dlgSetRights_unit, gdcUser;

{$R *.DFM}

// Просмотр пользователей относящихся к данной группе

procedure Tgdc_dlgUserGroup.actUsersExecute(Sender: TObject);
begin
  if gdcObject.State = dsInsert then
    actApply.Execute;

  if gdcObject.State <> dsInsert then
    gdcObject.EditDialog('Tgdc_dlgAddGroupToUser');
end;

procedure Tgdc_dlgUserGroup.actRightsExecute(Sender: TObject);
begin
  if gdcObject.State = dsInsert then
    actApply.Execute;

  if gdcObject.State <> dsInsert then
    with TgdcUserGroup_dlgsetRights.Create(Self) do
    try
      FGroupMask := (gdcObject as TgdcUserGroup).GetGroupMask;
      lblGroupName.Caption := dbeName.Text;
      ShowModal;
    finally
      Free;
    end;
end;

initialization
  RegisterFrmClass(Tgdc_dlgUserGroup);

finalization
  UnRegisterFrmClass(Tgdc_dlgUserGroup);

end.
