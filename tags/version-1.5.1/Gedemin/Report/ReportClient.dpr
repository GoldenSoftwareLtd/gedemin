program ReportClient;

uses
  Forms,
  cl_MainForm_unit in 'cl_MainForm_unit.pas' {MainReportClient},
  rp_ReportMainForm_unit in 'rp_ReportMainForm_unit.pas' {ReportMainForm},
  rp_dlgDefaultServer_unit in 'rp_dlgDefaultServer_unit.pas' {dlgDefaultServer},
  rp_dlgEditReportGroup_unit in 'rp_dlgEditReportGroup_unit.pas' {dlgEditReportGroup},
  rp_msgConnectServer_unit in 'rp_msgConnectServer_unit.pas' {msgConnectServer},
  rp_dlgSelectFunction_unit in 'rp_dlgSelectFunction_unit.pas' {dlgSelectFunction},
  rp_prgReportCount_unit in 'rp_prgReportCount_unit.pas' {prgReportCount},
  rp_msgErrorReport_unit in 'rp_msgErrorReport_unit.pas' {msgErrorReport},
  rp_ErrorMsgFactory in 'rp_ErrorMsgFactory.pas',
  obj_Gedemin in 'obj_Gedemin.pas',
  dmDataBase_unit in '..\GAdmin\dmDataBase_unit.pas' {dmDatabase: TDataModule},
  dmTestReport_unit in 'dmTestReport_unit.pas' {dmTestReport: TDataModule},
  dmClientReport_unit in 'dmClientReport_unit.pas' {dmClientReport: TDataModule},
  obj_dlgParamWindow in 'obj_dlgParamWindow.pas';

{$R *.RES}

begin
  Application.Initialize;
  {$IFDEF GEDEMIN}
  Application.CreateForm(TdmDatabase, dmDatabase);
  {$ELSE}
  Application.CreateForm(TdmTestReport, dmTestReport);
  {$ENDIF}
  Application.CreateForm(TdmClientReport, dmClientReport);
  Application.CreateForm(TMainReportClient, MainReportClient);
  Application.Run;
end.

