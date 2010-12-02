program Setting;

uses
  Forms,
  st_MainSetTest_unit in 'st_MainSetTest_unit.pas' {MainForm},
  st_inistorage in 'st_inistorage.pas',
  st_dlgSelectSettings_unit in 'st_dlgSelectSettings_unit.pas' {dlgSelectSettings},
  st_dlgEditSetting_unit in 'st_dlgEditSetting_unit.pas' {dlgEditSetting};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
