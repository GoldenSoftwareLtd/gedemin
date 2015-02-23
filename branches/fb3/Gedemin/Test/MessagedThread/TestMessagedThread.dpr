program TestMessagedThread;

uses
  Forms,
  TestMessagedThread_unit in 'TestMessagedThread_unit.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
