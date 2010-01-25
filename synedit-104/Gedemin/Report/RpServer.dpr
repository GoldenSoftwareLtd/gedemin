program RpServer;

uses
  SvcMgr,
  rs_srvMainForm_unit in 'rs_srvMainForm_unit.pas' {srvMainForm: TService};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TsrvMainForm, srvMainForm);
  Application.Run;
end.
