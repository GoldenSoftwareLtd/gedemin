program TestSimpleFilter;

uses
  Forms,
  tsf_MaimForm_unit in 'tsf_MaimForm_unit.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
