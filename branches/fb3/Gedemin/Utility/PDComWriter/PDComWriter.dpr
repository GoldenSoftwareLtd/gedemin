library PDComWriter;

uses
  ComServ,
  PDComWriter_unit in 'PDComWriter_unit.pas',
  PD_TLB in 'PD_TLB.pas',
  ExecQuadrupleCommand_TLB in 'ExecQuadrupleCommand_TLB.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.
