library Pos7300Command;
uses
  ComServ,
  SysUtils,
  Classes,
  Pos7300Command_TLB in 'Pos7300Command_TLB.pas',
  Pos7300Command_unit in 'Pos7300Command_unit.pas' {Pos7300COM: CoClass};

{$R *.TLB}

{$R *.res}

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;
begin
end.

 