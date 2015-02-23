program TestServer;

uses
  Forms,
  TestServer_Main_unit in 'TestServer_Main_unit.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
