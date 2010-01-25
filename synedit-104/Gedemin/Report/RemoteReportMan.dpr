program RemoteReportMan;

uses
  Forms,
  MainRM_unit in 'MainRM_unit.pas' {Form1},
  rp_SvrMngTemplate_unit in 'rp_SvrMngTemplate_unit.pas' {SvrMngTemplate},
  rp_RemoteManager_unit in 'rp_RemoteManager_unit.pas' {RemoteManager};

{$R *.RES}

//{$R ReportManager.TLB}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
