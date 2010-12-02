program TestPr;

uses
  Forms,
  TestForm_unit in 'TestForm_unit.pas' {Form1},
  TestPr_TLB in 'TestPr_TLB.pas',
  obj_IBQuery_unit in 'obj_IBQuery_unit.pas' {IBQueryTest, QueryList: CoClass};

{$R *.TLB}

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
