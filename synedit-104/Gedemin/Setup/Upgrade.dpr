program Upgrade;

uses
  Forms,
  gd_upgrade_main_unit in 'gd_upgrade_main_unit.pas' {frmMain};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
