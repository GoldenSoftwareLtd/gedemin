program gsDBSqueeze;

uses
  FastMM4,
  FastMove,
  Forms,
  gsDBSqueeze_MainForm_unit in 'gsDBSqueeze_MainForm_unit.pas' {gsDBSqueeze_MainForm},
  gsDBSqueezeIniOptions_unit in 'gsDBSqueezeIniOptions_unit.pas',
  gdMessagedThread in '..\..\Component\gdMessagedThread.pas',
  gsDBSqueezeThread_unit in 'gsDBSqueezeThread_unit.pas',
  gsDBSqueeze_unit in 'gsDBSqueeze_unit.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TgsDBSqueeze_MainForm, gsDBSqueeze_MainForm);
  Application.Run;
end.
