program pAddId;

uses
  Forms,
  AddIDUnit1 in 'AddIDUnit1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
