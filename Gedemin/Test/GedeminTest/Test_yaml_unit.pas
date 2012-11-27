
unit Test_yaml_unit;

interface

uses
  Classes, TestFrameWork, yaml_scanner, yaml_common, yaml_writer;

type
  TyamlTest = class(TTestCase)
  private
    procedure TransformationStream(AInPut, AOutPut: TStream);
  published
    procedure Test;
    procedure Test_CompareStream;
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
      Check(Scanner.GetNextToken = tSequenceStart);
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = 'Item5');
      Check(Scanner.Quoting = qDoubleQuoted);
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'Item6');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = '123 456'#13#10'789 111'#13#10'568');
      Check(Scanner.Quoting = qPlain); 
      Check(Scanner.GetNextToken = tKey);
      Check(Scanner.Key = 'Item7');
      Check(Scanner.GetNextToken = tScalar);
      Check(Scanner.Scalar = '123 456 789 111 568');
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
  Indents: TList;
  LastToken: TyamlToken;

  function ChangeIndent: Boolean;
  begin
    Result := True;
    if Scanner.Indent > Integer(Indents.Last) then
    begin
      Writer.IncIndent;
      Indents.Add(Pointer(Scanner.Indent))
    end
    else if Scanner.Indent < Integer(Indents.Last) then
    begin
      Writer.DecIndent;
      Indents.Delete(Indents.Count - 1);
    end else
      Result := False;
  end;
begin
  Scanner := TyamlScanner.Create(AInPut);
  try
    Writer := TyamlWriter.Create(AOutPut);
    try
      Token := Scanner.GetNextToken;
      Indents := TList.Create;
      try
        Indents.Add(Pointer(Scanner.Indent));
        While Token <> tStreamEnd do
        begin
          case Token of
            tDocumentStart: Writer.WriteDocumentStart;
            tKey:
            begin
             if (not ChangeIndent) and  (LastToken = tSequenceStart) then
               Writer.WriteKey(Scanner.Key, False)
             else
               Writer.WriteKey(Scanner.Key)
            end;
            tScalar: Writer.WriteScalar(Scanner.Scalar, Scanner.Quoting, False);
            tSequenceStart:
            begin
              ChangeIndent;
              Writer.WriteSequenceIndicator;
            end;
          end;
          LastToken := Token;
          Token := Scanner.GetNextToken;
        end;
      finally
        Indents.Free;
      end;
    finally
      Writer.Flush;
      Writer.Free;
    end;
  finally
    Scanner.Free;
  end;
end;

procedure TyamlTest.Test_CompareStream;
var
  InPutFS: TFileStream;
  OutPutFS: TFileStream;
begin
  InPutFS := TFileStream.Create('c:\input.yml', fmOpenRead);
  OutPutFS := TFileStream.Create('c:\output.yml', fmCreate);
  try
    TransformationStream(InPutFS, OutPutFS);
  finally
    InPutFS.Free;
    OutPutFS.Free;
  end;
end;

initialization
  RegisterTest('Internals', TyamlTest.Suite);
end.