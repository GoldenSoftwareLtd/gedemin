program gdAddMacroCall;

uses
  Forms,
  amc_MainForm in 'amc_MainForm.pas' {frmAddMacroCall},
  amc_Base in 'amc_Base.pas',
  gdStrings in '..\GDMacro\gdStrings.pas',
  frm_AddGaude in 'frm_AddGaude.pas' {frmAddGaude};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmAddMacroCall, frmAddMacroCall);
  Application.CreateForm(TfrmAddGaude, frmAddGaude);
  Application.Run;
end.
