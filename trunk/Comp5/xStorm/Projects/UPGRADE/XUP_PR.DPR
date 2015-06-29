program XUp_pr;

uses
  Forms,
  xUp_uni in 'XUP_UNI.PAS' {Form1};

{$R *.RES}

begin
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
