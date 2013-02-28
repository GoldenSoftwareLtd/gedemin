program gsDBSqueeze;

uses
  Forms,
  gsDBSqueeze_MainForm_unit,
  gsDBSqueeze_unit in 'gsDBSqueeze_unit.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TgsDBSqueeze_MainForm, gsDBSqueeze_MainForm);
  Application.Run;
end.
