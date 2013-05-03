program FDBExtractData;

uses
  Forms,
  gs_frmFDBExtractData_unit in 'gs_frmFDBExtractData_unit.pas' {gs_frmFDBExtractData},
  FDBExtractData_unit in 'FDBExtractData_unit.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(Tgs_frmFDBExtractData, gs_frmFDBExtractData);
  Application.Run;
end.
