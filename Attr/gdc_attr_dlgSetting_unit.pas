unit gdc_attr_dlgSetting_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, StdCtrls, Mask, DBCtrls, Menus, Db, ActnList, ExtCtrls,
  XPBevel, Buttons;

type
  Tgdc_dlgSetting = class(Tgdc_dlgG)
    Label1: TLabel;
    dbeName: TDBEdit;
    Label2: TLabel;
    dbmDescription: TDBMemo;
    Label3: TLabel;
    dbeVersion: TDBEdit;
    dbcbEnding: TDBCheckBox;
    pMinVersions: TPanel;
    Label4: TLabel;
    dbeMinExeVersion: TDBEdit;
    btnCurExeVersion: TBitBtn;
    btnCurDBVersion: TBitBtn;
    dbeMinDBVersion: TDBEdit;
    Label5: TLabel;
    procedure dbmDescriptionEnter(Sender: TObject);
    procedure dbmDescriptionExit(Sender: TObject);
    procedure btnCurExeVersionClick(Sender: TObject);
    procedure btnCurDBVersionClick(Sender: TObject);
    procedure dbcbEndingClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  end;

var
  gdc_dlgSetting: Tgdc_dlgSetting;

implementation

uses
  gd_ClassList, gd_security, gd_common_functions;

{$R *.DFM}

procedure Tgdc_dlgSetting.dbmDescriptionEnter(Sender: TObject);
begin
  inherited;
  btnOk.Default := False;
end;

procedure Tgdc_dlgSetting.dbmDescriptionExit(Sender: TObject);
begin
  inherited;
  btnOk.Default := True;
end;

procedure Tgdc_dlgSetting.btnCurExeVersionClick(Sender: TObject);
begin
  inherited;

  gdcObject.FieldByName('MinExeVersion').AsString := GetCurEXEVersion;
  dbeMinExeVersion.SetFocus;
end;

procedure Tgdc_dlgSetting.btnCurDBVersionClick(Sender: TObject);
begin
  inherited;

  gdcObject.FieldByName('MinDBVersion').AsString := IBLogin.DBVersion;
  dbeMinDBVersion.SetFocus;
end;

procedure Tgdc_dlgSetting.dbcbEndingClick(Sender: TObject);
begin
  inherited;
                                                
  if not (gdcObject.State in [dsEdit, dsInsert]) then Exit;
                                  
  pMinVersions.Enabled := dbcbEnding.Checked;
  if not pMinVersions.Enabled then
  begin
    gdcObject.FieldByName('MinExeVersion').Clear;
    gdcObject.FieldByName('MinDBVersion').Clear;
  end;
end;

procedure Tgdc_dlgSetting.FormShow(Sender: TObject);
begin
  inherited;

  pMinVersions.Enabled := Boolean(gdcObject.FieldByName('Ending').AsInteger);
end;

initialization
  RegisterFrmClass(Tgdc_dlgSetting);

finalization
  UnRegisterFrmClass(Tgdc_dlgSetting);

end.
