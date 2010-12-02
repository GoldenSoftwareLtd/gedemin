program SingleFilter;

uses
  gd_memory_manager in '..\Component\gd_memory_manager.pas',
  Forms,
  MainForm4_unit in 'MainForm4_unit.pas' {Form1},
  flt_ScriptInterface in 'flt_ScriptInterface.pas',
  flt_ScriptInterface_body in 'flt_ScriptInterface_body.pas',
  flt_dlg_dlgQueryParam_unit in 'flt_dlg_dlgQueryParam_unit.pas' {dlgQueryParam},
  flt_dlg_frmParamLine_unit in 'flt_dlg_frmParamLine_unit.pas' {dlg_frmParamLine: TFrame};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
