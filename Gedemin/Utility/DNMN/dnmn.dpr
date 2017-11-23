program dnmn;

uses
  Forms,
  dnmn_frmMain_unit in 'dnmn_frmMain_unit.pas' {dnmn_frmMain},
  dnmn_frmReg_unit in 'dnmn_frmReg_unit.pas' {dnmn_frmReg},
  dnmn_reg in 'dnmn_reg.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(Tdnmn_frmMain, dnmn_frmMain);
  Application.Run;
end.
