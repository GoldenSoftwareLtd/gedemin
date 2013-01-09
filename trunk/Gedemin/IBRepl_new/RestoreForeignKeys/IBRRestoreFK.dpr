program IBRRestoreFK;

uses
  Forms,
  ibr_frmRestoreFKMain_unit in 'ibr_frmRestoreFKMain_unit.pas' {frmRestoreFKMain},
  ibr_DBRegistrar_unit in 'ibr_DBRegistrar_unit.pas',
  ibr_BaseTypes_unit in 'ibr_BaseTypes_unit.pas',
  ibr_const in 'ibr_const.pas',
  ibr_GlobalVars_unit in 'ibr_GlobalVars_unit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmRestoreFKMain, frmRestoreFKMain);
  Application.Run;
end.
