program DeleteProp;

uses
  Forms,
  DeleteProp_MainForm_Unit in 'DeleteProp_MainForm_Unit.pas' {frmDeleteProp_MainForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Delete properties';
  Application.CreateForm(TfrmDeleteProp_MainForm, frmDeleteProp_MainForm);
  Application.Run;
end.
