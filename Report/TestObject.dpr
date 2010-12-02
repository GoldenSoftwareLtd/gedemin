program TestObject;

uses
  Forms,
  TestObjectMain_unit in 'TestObjectMain_unit.pas' {Form1},
  obj_QueryList in 'obj_QueryList.pas',
  ReportServer_TLB in 'ReportServer_TLB.pas',
  to_fr_ReportPage in 'to_fr_ReportPage.pas' {frReportPage: TFrame},
  gd_MultiStringList in 'gd_MultiStringList.pas';

{$R *.RES}

begin
  Application.Initialize;
//  Application.CreateForm(TdmDatabase, dmDatabase);
  Application.CreateForm(TForm1, Form1);
//  Application.CreateForm(TfrmRealizationBill, frmRealizationBill);
//  frmRealizationBill.Show;
  Application.Run;
end.
