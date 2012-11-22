
unit Test_yaml_unit;

interface

uses
  Classes, TestFrameWork, yaml_scanner;

type
  TyamlTest = class(TTestCase)
  published
    procedure Test;
  end;

implementation

uses
  SysUtils;

{ TyamlTest }

procedure TyamlTest.Test;
var
  FS: TFileStream;
  Scanner: TyamlScanner;
begin
  FS := TFileStream.Create('c:\golden\gedemin\test\gedemintest\data\yaml\test.yml', fmOpenRead);
  try
    Scanner := TyamlScanner.Create(FS);
    try
      Check(Scanner.GetNextToken = tStreamStart);
      Check(Scanner.GetNextToken = tDocumentStart);
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'aaa "bbb');
      Check(Scanner.Quoting = qDoubleQuoted);
      Check(Scanner.GetNextToken = tDocumentEnd);
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
      Check(Scanner.GetNextToken = tStreamEnd);
    finally
      Scanner.Free;
    end;
  finally
    FS.Free;
  end;
end;

initialization
  RegisterTest('Internals', TyamlTest.Suite);
end.