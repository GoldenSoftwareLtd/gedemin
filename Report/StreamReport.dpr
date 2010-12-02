program StreamReport;

uses
  Forms,
  MainStrRpt_unit in 'MainStrRpt_unit.pas' {Form1},
  rp_StreamRTF in 'rp_StreamRTF.pas',
  rp_i_ReportBuilder_unit in 'rp_i_ReportBuilder_unit.pas',
  StreamReport_TLB in 'StreamReport_TLB.pas',
  rp_ClassReportFactory in 'rp_ClassReportFactory.pas',
  StreamTestMain in 'StreamTestMain.pas' {Form2},
  rp_StreamNone in 'rp_StreamNone.pas',
  rp_StreamFR in 'rp_StreamFR.pas';

{$R *.TLB}

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
