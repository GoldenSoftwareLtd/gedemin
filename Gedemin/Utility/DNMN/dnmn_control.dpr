program dnmn_control;

uses
  Forms,
  dnmn_control_frmMain_unit in 'dnmn_control_frmMain_unit.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
