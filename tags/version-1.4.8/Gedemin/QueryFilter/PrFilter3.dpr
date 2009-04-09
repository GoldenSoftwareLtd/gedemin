program PrFilter3;

uses
  Forms,
  MainForm3_unit in 'MainForm3_unit.pas' {Form1},
  dmDataBase_unit in '..\GAdmin\dmDataBase_unit.pas' {dmDatabase: TDataModule};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TdmDatabase, dmDatabase);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
