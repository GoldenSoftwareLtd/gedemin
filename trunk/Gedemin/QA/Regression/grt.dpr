program grt;

uses
  Forms,
  grt_main_unit in 'grt_main_unit.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
