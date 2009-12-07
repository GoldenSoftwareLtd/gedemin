program PrTest2;

uses
  Forms,
  TestForm2_unit in 'TestForm2_unit.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
