library MegaWDriverCOM;

uses
  SysUtils,
  Classes,
  ComServ,
  MegaWDriverCOM_TLB in 'MegaWDriverCOM_TLB.pas',
  unit_MegaWDriver in 'unit_MegaWDriver.pas' {MegaWDriver: CoClass};

{$R *.TLB}

{$R *.res}
exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;
begin
end.
 