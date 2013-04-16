
unit yaml_scanner;

interface

uses
  Classes, yaml_common, yaml_reader;

type
  TyamlToken = (
    tUndefined,
    tStreamStart,
    tStreamEnd,
    tDocumentStart,
    tDocumentEnd,
    tSequenceStart,
    tScalar,
    tKey,
    tTag);

  TyamlScannerState = (
    sAtStreamStart,
    sDirective,
    sDocument,
    sScalar,
    sTag);

type
  TyamlScanner = class(TObject)
  private
    FReader: TyamlReader;
    FState: TyamlScannerState;
    FScalar: AnsiString;
    FQuoting: TyamlScalarQuoting;
    FStyle: TyamlScalarStyle;
    FBlockIndent: Integer;
    FKey: AnsiString;
    FTag: AnsiString;
    FIndent: Integer;
    FLine: Integer;
    FToken: TyamlToken;
    FSetEOF: Boolean;
    FStopKey: AnsiString;

    function GetEOF: Boolean;

  public
    constructor Create(AStream: TStream);
    destructor Destroy; override;

    function GetNextToken: TyamlToken;

    property EOF: Boolean read GetEOF;
    property Indent: Integer read FIndent;
    property Line: Integer read FLine;
    property StopKey: AnsiString read FStopKey write FStopKey;

    property Token: TyamlToken read FToken;
    property Quoting: TyamlScalarQuoting read FQuoting;
    property Scalar: AnsiString read FScalar;
    property Style: TyamlScalarStyle read FStyle;
    property Key: AnsiString read FKey;
    property Tag: AnsiString read FTag;
  end;

implementation

uses
  SysUtils;

{ TyamlScanner }

constructor TyamlScanner.Create(AStream: TStream);
begin
  FReader := TyamlReader.Create(AStream);
  FState := sAtStreamStart;
  FStyle := sPlain;
  FSetEOF := False;
  FStopKey := '';
end;

destructor TyamlScanner.Destroy;
begin
  FReader.Free;
  inherited;
end;

function TyamlScanner.GetEOF: Boolean;
begin
  Result := FReader.EOF or FSetEOF;
end;

function TyamlScanner.GetNextToken: TyamlToken;
var
  QuoteMatched: Boolean;
  L: Integer;
begin
  Result := tUndefined;
  FStyle := sPlain;
  while (Result = tUndefined) and (not EOF) do
  begin  
    FLine := FReader.Line;
    FIndent := FReader.Indent;

    case FState of
      sAtStreamStart:
      begin
        Result := tStreamStart;
        FState := sDirective
      end;

      sDirective:
      begin
        while FReader.PeekChar = '%' do
          FReader.SkipUntilEOL;
        FState := sDocument;
      end;

      sDocument:
      begin
        if (FReader.PeekChar = '-')
          and (FReader.PeekChar(1) = '-')
          and (FReader.PeekChar(2) = '-') then
        begin
          FBlockIndent := 0;
          FReader.Skip(3, True);
          Result := tDocumentStart;
        end
        else if (FReader.PeekChar = '.')
          and (FReader.PeekChar(1) = '.')
          and (FReader.PeekChar(2) = '.') then
        begin
          FBlockIndent := 0;
          FReader.Skip(3, True);
          Result := tDocumentEnd;
        end else
          case FReader.PeekChar of
            '#':
            begin
              FReader.SkipUntilEOL;
              continue;
            end;
            '-':
            begin
              if FReader.PeekChar(1) in [#32, #13, #10] then
              begin
                FBlockIndent := FReader.PositionInLine;
                FReader.Skip(1, True);
                FState := sDocument;
                Result := tSequenceStart;
              end else
              begin
                FQuoting := qPlain;
                FScalar := '';
                FState := sScalar;
              end;
            end;

            '"':
            begin
              FReader.Skip(1, False);
              FQuoting := qDoubleQuoted;
              FScalar := '';
              FState := sScalar;
            end;

            '>':
            begin
              FStyle := sFolded;
              FReader.SkipUntilEOL;
              FReader.InitialIndent := FReader.PositionInLine;
              FQuoting := qPlain;
              FScalar := '';
              FState := sScalar;
            end;

            '|':
            begin
              FStyle := sLiteral;
              FReader.SkipUntilEOL;
              FReader.InitialIndent := FReader.PositionInLine;
              FQuoting := qPlain;
              FScalar := '';
              FState := sScalar;
            end;

            '''':
            begin
              FReader.Skip(1, False);
              FQuoting := qSingleQuoted;
              FScalar := '';
              FState := sScalar;
            end;

            '!':
            begin
              FTag := '';
              FState := sTag;
            end;
          else
            L := 0;
            while not (FReader.PeekChar(L) in [#00, #13, #10, ':', '#']) do
              Inc(L);

            if (L > 0) and (FReader.PeekChar(L) = ':') and (FReader.PeekChar(L + 1) in [#32, #13, #10]) then
            begin
              FBlockIndent := FReader.PositionInLine;
              FKey := Trim(FReader.GetString(L));
              FReader.Skip(2, True);
              FState := sDocument;
              Result := tKey;
            end else
            begin
              FQuoting := qPlain;
              FScalar := '';
              FState := sScalar;
            end;
          end;
      end;

      sScalar:
      begin
        QuoteMatched := False;
        Result := tScalar;
        while (not EOF) and (not QuoteMatched) do
        begin
          if (FQuoting = qSingleQuoted) and (FReader.PeekChar = '''') then
          begin
            if FReader.PeekChar(1) = '''' then
            begin
              FScalar := FScalar + '''';
              FReader.Skip(2, False);
            end else
            begin
              FReader.GetChar;
              QuoteMatched := True;
            end;
          end
          else if (FQuoting = qDoubleQuoted) and (FReader.PeekChar = '"') then
          begin
            if FReader.PeekChar(1) = '"' then
            begin
              FScalar := FScalar + '"';
              FReader.Skip(2, False);
            end else
            begin
              FReader.GetChar;
              QuoteMatched := True;
            end;
          end
          else if (FReader.PeekChar = '#')  and (FQuoting = qPlain) and (FStyle = sPlain) then
          begin
            FReader.SkipUntilEOL;
            if EOF or ((FQuoting = qPlain) and (FReader.Indent <= FBlockIndent)) then
              break;
            if FStyle = sLiteral then
              FScalar := FScalar + #13#10
            else
              FScalar := FScalar + ' ';
          end
          else if FReader.PeekChar in EOL then
          begin
            FReader.SkipUntilEOL;
            if (FQuoting = qPlain) and ((FReader.Indent <= FBlockIndent) or ((FStyle = sPlain) and (FReader.PeekChar in ['-', '!']))) then
              break;
            if FStyle = sLiteral then
              FScalar := FScalar + #13#10
            else
              FScalar := FScalar + ' ';
          end else
            FScalar := FScalar + FReader.GetChar;
        end;
        if FQuoting in [qSingleQuoted, qDoubleQuoted] then
          if not QuoteMatched  then
            raise EyamlSyntaxError.Create('Syntax error')
          else
            FReader.SkipSpacesUntilEOL;
        FScalar := TrimRight(FScalar);
        FReader.InitialIndent := 0;
        FState := sDocument;
      end;

      sTag:
      begin
        Result := tTag;
        while not (FReader.PeekChar in [#00, #32, #13, #10]) do
          FTag := FTag + FReader.GetChar;
        if EOF or (FTag = '!') or (FTag = '!!') then
          raise EyamlSyntaxError.Create('Syntax error');
        FReader.SkipSpacesUntilEOL;
        FState := sDocument;
      end;
    end;
  end;

  if (Result = tKey) and (FStopKey > '') and (FKey = FStopKey) then
  begin
    FSetEOF := True;
    Result := tStreamEnd;
  end;

  if Result = tUndefined then
    Result := tStreamEnd;

  FToken := Result;
end;

end.
