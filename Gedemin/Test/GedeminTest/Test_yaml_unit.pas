
unit Test_yaml_unit;

interface

uses
  Classes, TestFrameWork, yaml_scanner, yaml_common;

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

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'abc');

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'a');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = '89');
      Check(Scanner.Quoting = qPlain);

      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'b');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = '90');
      Check(Scanner.Quoting = qPlain);

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