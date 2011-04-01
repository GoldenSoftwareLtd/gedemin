
unit TestSQLParser_unit;

interface

uses
  Classes, TestFrameWork;

type
  TSQLParserTest = class(TTestCase)
  published
    procedure TestSQLParser;
  end;

implementation

uses
  SysUtils, jclStrings, flt_sql_parser;

{ TSQLParserTest }

procedure TSQLParserTest.TestSQLParser;
var
  Input, Output, Etalon: TStringList;
  I: Integer;
  InputFileName, OutputFileName: String;
begin
  // тэставаньне разбору СКЛ запытаў мае на мэце праверыць працу
  // функцыі ExtractTablesList
  // зходныя запыты ляжаць у файлах у падкаталёгу SQLParser
  // файлы з запытамі: input.000, input.001, ...
  // файлы з карэктным выхадам: output.000, output.001

  Input := TStringList.Create;
  Output := TStringList.Create;
  Etalon := TStringList.Create;
  try

    for I := 0 to MAXINT do
    begin

      InputFileName := Format('d:\golden\gedemin\qa\regression\SQLParser\input.%.3d', [I]);
      OutputFileName := Format('d:\golden\gedemin\qa\regression\SQLParser\output.%.3d', [I]);

      {
      InputFileName := Format('%s\SQLParser\input.%.3d', [
        ExcludeTrailingBackSlash(ExtractFilePath(Application.EXEName)), I]);
      OutputFileName := Format('%s\SQLParser\output.%.3d', [
        ExcludeTrailingBackSlash(ExtractFilePath(Application.EXEName)), I]);
      }

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

      ExtractTablesList(Input.Text, Output);
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
  RegisterTest('Internals', TSQLParserTest.Suite);
end.

