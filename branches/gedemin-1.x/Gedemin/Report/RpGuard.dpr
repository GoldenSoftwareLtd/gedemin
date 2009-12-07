program RpGuard;

uses
  SvcMgr,
  rp_MainGuard in 'rp_MainGuard.pas' {ReportGuard: TService};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TReportGuard, ReportGuard);
  Application.Run;
end.
