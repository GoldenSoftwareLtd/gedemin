program ct_viewer;

uses
  Forms,
  ct_viewer_main_form in 'ct_viewer_main_form.pas' {Form1},
  ct_frmblob in 'ct_frmblob.pas' {frmBlob};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
