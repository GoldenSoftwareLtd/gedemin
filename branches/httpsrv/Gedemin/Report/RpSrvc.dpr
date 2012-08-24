
{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    RpSrvc.dpr

  Abstract

    Gedemin project. REPORT SERVER SERVICE.

  Author

    Andrey Shadevsky

  Revisions history

    1.00   ~20.09.01    JKL        Initial version.
    1.01    08.11.01    JKL        The system is more reliable.
                                   Big work for testing working
                                   perfomance in error environment.

--}

program RpSrvc;

uses
  SvcMgr,
  Forms,
  SysUtils,
  Windows,
  Classes,
  ReportServer_TLB in 'ReportServer_TLB.pas',
  CheckServerLoad_unit in 'CheckServerLoad_unit.pas',
  rp_ExecuteThread_unit in 'rp_ExecuteThread_unit.pas',
  rp_report_const in 'rp_report_const.pas',
  thrd_Event,
  rp_ServerService_unit in 'rp_ServerService_unit.pas' {srvcReportServer: TService},
  rp_MainForm_unit in 'rp_MainForm_unit.pas' {UnvisibleForm};

{$R *.RES}

begin
  if (ParamCount > 0) and (AnsiUpperCase(ParamStr(1)) = '/A') then
  begin
    Forms.Application.Initialize;
    Forms.Application.CreateForm(TUnvisibleForm, UnvisibleForm);
    Forms.Application.Run;
  end else
  begin
    SvcMgr.Application.Initialize;
    SvcMgr.Application.CreateForm(TsrvcReportServer, srvcReportServer);
    SvcMgr.Application.Run;
  end;
end.

