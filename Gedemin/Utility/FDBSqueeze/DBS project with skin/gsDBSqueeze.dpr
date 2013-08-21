program gsDBSqueeze;

uses
  FastMM4,
  FastMove,
  Forms,
  gsDBSqueeze_MainForm_unit, 
  gsDBSqueeze_unit in 'gsDBSqueeze_unit.pas',
  gsDBSqueezeThread_unit in 'gsDBSqueezeThread_unit.pas',
  gdMessagedThread in '..\..\..\Component\gdMessagedThread.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TgsDBSqueeze_MainForm, gsDBSqueeze_MainForm);
  Application.Run;
end.
