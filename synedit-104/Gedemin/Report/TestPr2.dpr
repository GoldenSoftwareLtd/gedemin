program TestPr2;

uses
  Forms,
  rp_BaseReport_unit in 'rp_BaseReport_unit.pas',
  Test2Form in 'Test2Form.pas' {Form1},
  rp_Report in 'rp_Report.pas',
  rp_dlgParams_unit in 'rp_dlgParams_unit.pas' {dlgParams},
  pr_frmValueParam_unit in 'pr_frmValueParam_unit.pas' {frmValueParam: TFrame},
  rp_dlgEditReport_unit in 'rp_dlgEditReport_unit.pas' {dlgEditReport},
  rp_vwReport_unit in 'rp_vwReport_unit.pas' {vwReport},
  gsReportQuery in 'gsReportQuery.pas',
  TestPr2_TLB in 'TestPr2_TLB.pas',
  rp_ScriptProvider_unit in 'rp_ScriptProvider_unit.pas',
  dmDataBase_unit in '..\GAdmin\dmDataBase_unit.pas' {dmDatabase: TDataModule},
  rp_vwFunction_unit in 'rp_vwFunction_unit.pas' {vwFunction},
  obj_1234123 in 'obj_1234123.pas' {coQuery: CoClass};

{$R *.TLB}

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TdmDatabase, dmDatabase);
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TvwFunction, vwFunction);
  Application.Run;
end.
