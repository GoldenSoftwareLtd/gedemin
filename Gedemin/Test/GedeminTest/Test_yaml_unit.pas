
unit Test_yaml_unit;

interface

uses
  Classes, TestFrameWork, gsTestFrameWork;

type
  TyamlTest = class(TgsTestCase)
  private
    procedure TransformationStream(AInPut, AOutPut: TStream);

  published
    procedure TestScanner;
    procedure TestWriter;
    procedure TestParser;   
  end;

implementation

uses
  SysUtils, yaml_reader, yaml_scanner, yaml_common, yaml_writer, yaml_parser;

{ TyamlTest }

procedure TyamlTest.TestScanner;
var
  FS: TFileStream;
  Scanner: TyamlScanner;
begin
  FS := TFileStream.Create(TestDataPath + '\yaml\test.yml', fmOpenRead);
  try
    Scanner := TyamlScanner.Create(FS);
    try
      Check(Scanner.GetNextToken = tStreamStart);
      Check(Scanner.GetNextToken = tDocumentStart);
      Check(Scanner.Line = 2);
      Check(Scanner.Indent = 0);

      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'aaa "bbb');
      Check(Scanner.Quoting = qDoubleQuoted);

      Check(Scanner.GetNextToken = tDocumentStart);
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'aaa ''bbb');
      Check(Scanner.Quoting = qSingleQuoted);

      Check(Scanner.GetNextToken = tDocumentStart);
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = '123');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tDocumentStart);
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = '123 456'#13#10'789 876'#13#10'543');
      Check(Scanner.Quoting = qPlain);
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'abc  def');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tDocumentStart);
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = '123 456 789 876 543');
      Check(Scanner.Quoting = qPlain);
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'abc  def');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tDocumentStart);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'abc');

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'a');
      Check(Scanner.Line = 20);
      Check(Scanner.Indent = 2);

      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = '89');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'b');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = '90');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'c');

      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'Item 1');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'Item 2');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'nm');

      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'a');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = '1');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'b');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = '2');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'c');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = '345 678 9078');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'd');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = '55');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tDocumentStart);

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'a');

      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'Item1');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'Item2');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'b');

      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'Item3');
      Check(Scanner.Quoting = qPlain);
      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'Item4');
      Check(Scanner.Quoting = qPlain);
      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'Item5');
      Check(Scanner.Quoting = qDoubleQuoted);
      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'Item6');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = '123 456   '#13#10#13#10'  789 111'#13#10'568');
      Check(Scanner.Quoting = qPlain);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'Item7');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = '123 456   789 111     568');
      Check(Scanner.Quoting = qPlain);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'Item8');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'test | test');
      Check(Scanner.Quoting = qDoubleQuoted);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'Item9');
      Check(Scanner.GetNextToken = tTag);
      Check(Scanner.Tag = '!!int');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = '67');
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'c');
      Check(Scanner.GetNextToken = tTag);
      Check(Scanner.Tag = '!!seq');
      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'Item1');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tDocumentStart);

      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'a');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'b');
      Check(Scanner.Quoting = qPlain);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'c');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'd');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'f');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'e');
      Check(Scanner.Quoting = qPlain);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'g');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'i');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tSequenceStart);

      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'n');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'm');
      Check(Scanner.Quoting = qPlain);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'k');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 's');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 't');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'o');
      Check(Scanner.Quoting = qPlain);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'p');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'q');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tSequenceStart);

      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'a');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'b');
      Check(Scanner.Quoting = qPlain);
      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'd');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'e');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'z');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'x');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'k');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'test'#13#10'#.##.#');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'l');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'test #.##.#');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'n');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = '#.##.#');
      Check(Scanner.Quoting = qSingleQuoted);

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'm');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'test');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tDocumentStart);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.GetNextToken = tScalar);

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'j');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = #13#10'test');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'p');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'i'#13#10#13#10#13#10'j');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'o');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'h'#13#10'  '#13#10'h');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'h');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'test'#13#10#13#10'  '#13#10'test');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 's');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = '#^   test');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tDocumentStart);

      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tSequenceStart);

      Check(Scanner.GetNextToken = tDocumentEnd);
      Check(Scanner.GetNextToken = tStreamEnd);
    finally
      Scanner.Free;
    end;
  finally
    FS.Free;
  end;
end;

procedure TyamlTest.TransformationStream(AInPut, AOutPut: TStream);
var
  Scanner: TyamlScanner;
  Writer: TyamlWriter;
  Token: TyamlToken;
  PrevIndent, CurrLine: Integer;
begin
  Scanner := TyamlScanner.Create(AInput);
  Writer := TyamlWriter.Create(AOutput);
  try
    Token := Scanner.GetNextToken;
    PrevIndent := Scanner.Indent;
    CurrLine := Scanner.Line;

    while Token <> tStreamEnd do
    begin
      if Scanner.Indent > PrevIndent then
        Writer.IncIndent
      else if Scanner.Indent < PrevIndent then
        Writer.DecIndent;

      if Scanner.Line > CurrLine then
        Writer.StartNewLine;

      case Token of
        tDocumentStart: Writer.WriteDocumentStart;
        tDocumentEnd: Writer.WriteDocumentEnd;
        tKey: Writer.WriteKey(Scanner.Key);
        tScalar: Writer.WriteText(Scanner.Scalar, Scanner.Quoting,
          Scanner.Style);
        tSequenceStart: Writer.WriteSequenceIndicator;
        tTag: Writer.WriteTag(Scanner.Tag);
      end;

      PrevIndent := Scanner.Indent;
      CurrLine := Scanner.Line;
      Token := Scanner.GetNextToken;
    end;
  finally
    Writer.Free;
    Scanner.Free;
  end;
end;

procedure TyamlTest.TestWriter;
var
  FS: TFileStream;
  S1, S2: TStringStream;
begin
  FS := TFileStream.Create(TestDataPath + '\yaml\test.yml', fmOpenRead);
  S1 := TStringStream.Create('');
  S2 := TStringStream.Create('');
  try
    TransformationStream(FS, S1);
    S1.Position := 0;
    TransformationStream(S1, S2);
    Check(S1.DataString = S2.DataString);
  finally
    FS.Free;
    S1.Free;
    S2.Free;
  end;
end;

procedure TyamlTest.TestParser;
var
  FS: TFileStream;
  Parser: TyamlParser;   
  M: TyamlMapping;
begin
  FS := TFileStream.Create(TestDataPath + '\yaml\test.yml', fmOpenRead);
  Parser := TyamlParser.Create;
  try
    Parser.Parse(FS);

    Check(((Parser.YAMLStream[0] as TYAMLDocument)[0] as TyamlString).AsString = 'aaa "bbb');
    Check(((Parser.YAMLStream[1] as TYAMLDocument)[0] as TyamlString).AsString = 'aaa ''bbb');
    Check(((Parser.YAMLStream[2] as TYAMLDocument)[0] as TyamlInteger).AsInteger = 123);
    Check(((Parser.YAMLStream[9] as TYAMLDocument)[0] as TyamlSequence)[1] is TyamlSequence);
    M := (Parser.YAMLStream[8] as TYAMLDocument)[0] as TyamlMapping;
    Check(M[0] is TyamlKeyValue);
    Check((M[0] as TyamlKeyValue).Value is TyamlScalar);
    Check(((M[0] as TyamlKeyValue).Value as TyamlScalar).AsString = '123 456   '#13#10' 111');
    Check(((M[5] as TyamlKeyValue).Value as TyamlScalar).AsString = '   test');
  finally
    Parser.Free;
    FS.Free;
  end;
end;

initialization
  RegisterTest('Internals', TyamlTest.Suite);
end.