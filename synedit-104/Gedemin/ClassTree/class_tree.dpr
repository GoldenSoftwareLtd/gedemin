program class_tree;

uses
  Forms,
  ct_main_form in 'ct_main_form.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
