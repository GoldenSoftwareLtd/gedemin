program PrFilter;

uses
  Forms,
  MainForm_unit in 'MainForm_unit.pas' {Form1},
  dmDataBase_unit in '..\GAdmin\dmDataBase_unit.pas' {dmDatabase: TDataModule},
  flt_dlgFunctionMaster_unit in 'flt_dlgFunctionMaster_unit.pas' {dlgFunctionMaster},
  flt_TextSQL_forFilter in 'flt_TextSQL_forFilter.pas',
  flt_frmSQLEditor_unit in 'flt_frmSQLEditor_unit.pas' {frmSQLEditor};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Фильтрация';
  Application.CreateForm(TdmDatabase, dmDatabase);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
