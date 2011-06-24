
unit Test_AtSQLSetup_unit;

interface

uses
  Classes, TestFrameWork, gsTestFrameWork;

type
  TSQLSetupTest = class(TgsDBTestCase)
  published
    procedure TestAtSQLSetup;
  end;

implementation

uses
  SysUtils, at_sql_setup, at_sql_parser, jclStrings, gdcBaseInterface;

procedure TSQLSetupTest.TestAtSQLSetup;
var
  Input, Output, Etalon: TStringList;
  I: Integer;
  InputFileName, OutputFileName: String;
begin
  if not FSettingsLoaded then
    exit;

  Input := TStringList.Create;
  Output := TStringList.Create;
  Etalon := TStringList.Create;
  try
    for I := 0 to MAXINT do
    begin
      InputFileName :=  Format('D:\Golden\Gedemin\Test\GedeminTest\Data\AtSQLSetup\input.%.3d.sql', [I]);
      OutputFileName := Format('D:\Golden\Gedemin\Test\GedeminTest\Data\AtSQLSetup\output.%.3d.sql', [I]);

      if I = 0 then
      begin
        Check(FileExists(InputFileName), 'Файл не найден: ' + InputFileName);
        Check(FileExists(OutputFileName), 'Файл не найден: ' + OutputFileName);
      end else
      begin
        if (not FileExists(InputFileName)) or (not FileExists(OutputFileName)) then
          break;
      end;

      Input.LoadFromFile(InputFileName);
      TrimStrings(Input);

      Etalon.LoadFromFile(OutputFileName);
      TrimStrings(Etalon);

      with TatSQLSetup.Create(nil) do
      try
        Output.Text := PrepareSQL(gdcBaseManager.ProcessSQL(Input.Text));
      finally
        Free;
      end;
      TrimStrings(Output);

      Check(AnsiCompareText(Output.Text, Etalon.Text) = 0, 'Error in test #' + IntToStr(I));
    end;

  finally
    Input.Free;
    Output.Free;
    Etalon.Free;
  end;
end;

initialization
  RegisterTest('DB', TSQLSetupTest.Suite);
end.
