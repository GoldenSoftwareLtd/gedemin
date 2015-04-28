library amc100f;

uses
  ComServ,
  gsDRV_TLB in 'gsDRV_TLB.pas',
  amc_unit in 'amc_unit.pas' {TAMC100F: CoClass};

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.
