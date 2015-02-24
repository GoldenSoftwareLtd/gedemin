library DitronEU200CS;

uses
  ComServ,
  gsDRV_TLB in 'gsDRV_TLB.pas',
  Ditron_Unit in 'Ditron_Unit.pas' {DitronEU200CS: CoClass};

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.
