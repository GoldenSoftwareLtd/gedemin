program TestPeriodEdit;

uses
  Forms,
  TestPeriodEdit_unit in 'TestPeriodEdit_unit.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
