
unit TestSQLParser_unit;

interface

uses
  Classes, TestFrameWork, gsTestFrameWork;

type
  TSQLParserTest = class(TgsDBTestCase)
  private
    procedure TestAtSQLParser(const SIn: String);

  published
    procedure TestSQLParser;
  end;

implementation

uses
  SysUtils, jclStrings, flt_sql_parser, at_sql_parser;

{ TSQLParserTest }

procedure TSQLParserTest.TestAtSQLParser(const SIn: String);
var
  Parser: TsqlParser;
  S: String;
begin
  Parser := TsqlParser.Create(SIn);
  try
    Parser.Parse;
    Parser.Build(S);

    FQ.Close;
    FQ.SQL.Text := S;
    FQ.ParamByName('p').AsInteger := -1;
    FQ.ExecQuery;
    Check(FQ.Fields[0].IsNull);
    FQ.Close;
  finally
    Parser.Free;
  end;
end;

procedure TSQLParserTest.TestSQLParser;
var
  Input, Output, Etalon, GroupByFields: TStringList;
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


  GroupByFields := TStringList.Create;
  try
    ExtractSQLGroupBy('SELECT a, SUM(b), SUM(c) FROM gd_contact GROUP BY a', GroupByFields);
    Check(GroupByFields.CommaText = 'a');

    ExtractSQLGroupBy('SELECT a, SUM(b), SUM(c) FROM gd_contact GROUP BY 1', GroupByFields);
    Check(GroupByFields.CommaText = 'a');

    ExtractSQLGroupBy('SELECT a, b, SUM(c) FROM gd_contact GROUP BY a, B', GroupByFields);
    Check(GroupByFields.CommaText = 'a,B');

    ExtractSQLGroupBy('SELECT a, b, SUM(c) FROM gd_contact GROUP BY a, B HAVING SUM(c) > 10', GroupByFields);
    Check(GroupByFields.CommaText = 'a,B');

    ExtractSQLGroupBy('SELECT a,   b,   SUM(c)   FROM gd_contact GROUP BY   1,   2 HAVING SUM(c) > 10', GroupByFields);
    Check(GroupByFields.CommaText = 'a,b');

    ExtractSQLGroupBy('SELECT a, b, SUM(c) FROM gd_contact GROUP BY'#13#10'2, 1 HAVING SUM(c) > 10', GroupByFields);
    Check(GroupByFields.CommaText = 'b,a');

    ExtractSQLGroupBy('SELECT a, b, SUM(c) FROM gd_contact GROUP BY a, B HAVING SUM(c) > 10 UNION ALL SELECT a FROM gd_contact GROUP BY a', GroupByFields);
    Check(GroupByFields.CommaText = 'a,B');

    ExtractSQLGroupBy('SELECT a, b, SUM(c)  FROM gd_contact GROUP BY a,   B'#13#10' HAVING SUM(c) > 10', GroupByFields);
    Check(GroupByFields.CommaText = 'a,B');
  finally
    GroupByFields.Free;
  end;

  TestAtSQLParser(
    'select IIF(((:p) >= 0) AND ((:p) <= 42), ''1-42'', ' +
    '  IIF(((:p) >= 43) AND ((:p) <= 140), ''43-140'', ' +
    '  IIF(((:p) >= 141) AND ((:p) <= 180), ''141-180'', ' +
    '  IIF((:p) > 180, ''>180'', NULL)))) AS birdage ' +
    'from rdb$database ');
  TestAtSQLParser(
    'select CASE WHEN ((:p) >= 0) AND ((:p) <= 42) THEN ''1-42'' ' +
    'WHEN ((:p) >= 43) AND ((:p) <= 140) THEN ''43-140'' ' +
    'WHEN ((:p) >= 141) AND ((:p) <= 180) THEN ''141-180'' ' +
    'WHEN (:p) > 180 THEN ''>180'' ' +
    'END AS birdage from rdb$database ');
end;

initialization
  RegisterTest('Internals', TSQLParserTest.Suite);
end.

