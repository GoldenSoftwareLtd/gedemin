program ReportServerTesting;

uses
  Forms,
  sr_MainForm_unit in 'sr_MainForm_unit.pas' {MainReportServer},
  obj_QueryList_unit in 'obj_QueryList_unit.pas' {QueryList: CoClass},
  rp_dlgEditFunction_unit in 'rp_dlgEditFunction_unit.pas' {dlgEditFunction},
  rp_dlgViewResult_unit in 'rp_dlgViewResult_unit.pas' {dlgViewResult},
  rp_frmGrid_unit in 'rp_frmGrid_unit.pas' {frmGrid: TFrame},
  rp_report_const in 'rp_report_const.pas',
  rp_dlgEnterParam_unit in 'rp_dlgEnterParam_unit.pas' {dlgEnterParam},
  rp_frmParamLine_unit in 'rp_frmParamLine_unit.pas' {frmParamLine: TFrame},
  rp_ReportScriptControl in 'rp_ReportScriptControl.pas',
  rp_ReportServer in 'rp_ReportServer.pas',
  dmReport_unit in 'dmReport_unit.pas' {dmReport: TDataModule},
  rp_ReportError in 'rp_ReportError.pas',
  rp_dlgReportOptions_unit in 'rp_dlgReportOptions_unit.pas' {dlgReportOptions};

{$R *.RES}

begin
  Application.Initialize;
//  Application.ShowMainForm := False;
  Application.CreateForm(TMainReportServer, MainReportServer);
  Application.Run;
end.
