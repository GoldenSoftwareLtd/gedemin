library CassT15;

uses
  ComServ,
  gsDRV_TLB in 'gsDRV_TLB.pas',
  Unit1 in 'Unit1.pas' {Scale15T: CoClass};

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.
