program Modify;

uses
  Forms,
  gd_modify_main_unit in 'gd_modify_main_unit.pas' {gd_modify_main},
  msf_CorrectBadInvCard in 'msf_CorrectBadInvCard.pas',
  mdf_AddGoodKeyIntoMovement_unit in 'mdf_AddGoodKeyIntoMovement_unit.pas',
  mdf_AddBranchToBankAndIndex in 'mdf_AddBranchToBankAndIndex.pas',
  mdf_AddEmployeeCmd in 'mdf_AddEmployeeCmd.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(Tgd_modify_main, gd_modify_main);
  Application.Run;
end.
