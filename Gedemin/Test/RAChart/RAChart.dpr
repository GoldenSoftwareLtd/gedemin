program RAChart;

uses
  Forms,
  RAChart_unit in 'RAChart_unit.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
