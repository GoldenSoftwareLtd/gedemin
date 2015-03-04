library VFD_server;

uses
  ComServ,
  gsDRV_TLB in 'gsDRV_TLB.pas',
  main_unit in 'main_unit.pas' {FirichVFD: CoClass};

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin

end.
