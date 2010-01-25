program ReportManager;

uses
  Forms,
  CheckServerLoad_unit in 'CheckServerLoad_unit.pas',
  rp_dlgServerConnectOptions_unit in 'rp_dlgServerConnectOptions_unit.pas' {dlgServerConnectOptions},
  gd_Cipher_unit in '..\Component\gd_Cipher_unit.pas',
  rp_server_connect_option in 'rp_server_connect_option.pas',
  ReportManager_TLB in 'ReportManager_TLB.pas',
  obj_ReportManager_unit in 'obj_ReportManager_unit.pas' {SvrMng: CoClass},
  rp_ServerManager_unit in 'rp_ServerManager_unit.pas' {ServerManager},
  rp_SvrMngTemplate_unit in 'rp_SvrMngTemplate_unit.pas' {SvrMngTemplate};

{$R *.TLB}

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TServerManager, ServerManager);
  Application.Run;
end.
