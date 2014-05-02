program gsDBSqueeze;

uses
  FastMM4,
  FastMove,
  Forms,
  gsDBSqueeze_MainForm_unit in 'gsDBSqueeze_MainForm_unit.pas' {gsDBSqueeze_MainForm},
  gsDBSqueeze_DocTypesForm_unit in 'gsDBSqueeze_DocTypesForm_unit.pas' {gsDBSqueeze_DocTypesForm},
  gsDBSqueeze_CardMergeForm_unit in 'gsDBSqueeze_CardMergeForm_unit.pas' {gsDBSqueeze_CardMergeForm},
  gsDBSqueezeIniOptions_unit in 'gsDBSqueezeIniOptions_unit.pas',
  gdMessagedThread in '..\..\Component\gdMessagedThread.pas',
  gsDBSqueezeThread_unit in 'gsDBSqueezeThread_unit.pas',
  gsDBSqueeze_unit in 'gsDBSqueeze_unit.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TgsDBSqueeze_MainForm, gsDBSqueeze_MainForm);
  Application.CreateForm(TgsDBSqueeze_DocTypesForm, gsDBSqueeze_DocTypesForm);
  Application.CreateForm(TgsDBSqueeze_CardMergeForm, gsDBSqueeze_CardMergeForm);
  Application.Run;
end.
