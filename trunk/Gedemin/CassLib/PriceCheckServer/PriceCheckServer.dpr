program PriceCheckServer;

uses
  Forms,
  PriceCheckServer_Unit in 'PriceCheckServer_Unit.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
