program Report;

uses
  Forms,
  Main in 'MAIN.PAS' {MainForm},
  dm1 in 'dm1.pas' {dm: TDataModule};

{$R *.RES}

begin
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(Tdm, dm);
  Application.Run;
end.
