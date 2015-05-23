program gdMacro;

uses
  Forms,
  mcr_MainForm in 'mcr_MainForm.pas' {frm_mcrMainForm},
  mcr_Foundation in 'mcr_Foundation.pas',
  mcr_frmGauge in 'mcr_frmGauge.pas' {frmGauge};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(Tfrm_mcrMainForm, frm_mcrMainForm);
  Application.Run;
end.
