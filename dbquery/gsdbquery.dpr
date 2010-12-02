library gsdbquery;

uses
  FastMM4,
  FastMove,
  ComServ,
  gsdbquery_TLB in 'gsdbquery_TLB.pas',
  obj_QueryList in 'obj_QueryList.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.
