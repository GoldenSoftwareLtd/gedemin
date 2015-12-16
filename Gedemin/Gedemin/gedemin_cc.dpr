program gedemin_cc;

{$R '..\Component\indy\Indy50.res' '..\Component\indy\Indy50.rc'}

uses
  Forms,
  gedemin_cc_frmMain_unit in 'gedemin_cc_frmMain_unit.pas',
  gedemin_cc_DataModule_unit in 'gedemin_cc_DataModule_unit.pas' {DM: TDataModule},
  gedemin_cc_TCPServer_unit in 'gedemin_cc_TCPServer_unit.pas',
  gedemin_cc_const in 'gedemin_cc_const.pas',
  DBGrids in '..\component\DBGrids.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(Tfrm_gedemin_cc_main, frm_gedemin_cc_main);
  Application.Run;
end.
