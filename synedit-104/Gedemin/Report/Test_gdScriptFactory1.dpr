program Test_gdScriptFactory1;

uses                              
  Forms,
  Test_gdScriptFactory in 'Test_gdScriptFactory.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
