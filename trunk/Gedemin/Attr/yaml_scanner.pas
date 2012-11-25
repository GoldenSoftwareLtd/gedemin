
unit yaml_scanner;

interface

uses
  Classes, SysUtils;

type
  TyamlToken = (
    tUndefined,
    tStreamStart,
    tStreamEnd,
    tDocumentStart,
    tDocumentEnd,
    tSequenceStart,
    tScalar,
    tKey);

  TyamlScalarQuoting = (
    qPlain,
    qSingleQuoted,
    qDoubleQuoted);

  TyamlScalarStyle = (
    sLiteral,
    sFolded);

  TyamlScannerState = (
    sAtStreamStart,
    sDirective,
    sDocument,
    sScalar);

{
  |-----------FileSize----------|
  |                             |
  |=============|=====================|
  |#############|################     |
  |#############|################     |
  |#############|################     |
  |=============^==========^====^=====|
  |             |-Position-|    |     |
  |-BufferStart-|               |     |
  |             |--BufferCount--|     |
                |                     |
                |-----BufferSize------|
}

type
  TyamlScanner = class(TObject)
  private
    FStream: TStream;
    FEOF: Boolean;
    FBuffer: PAnsiChar;
    FBufferSize: Integer;
    FBufferStart: Integer;
    FPosition: Integer;
    FBufferCount: Integer;
    FState: TyamlScannerState;
    FScalar: String;
    FQuoting: TyamlScalarQuoting;
    FStyle: TyamlScalarStyle;
    FIndent: Integer;
    FKey: String;

    procedure ReadNextBlock;
    procedure CheckEOF;
    procedure ShiftBuffer(const Offset: Integer);
    procedure SkipUntilEOL;
    procedure SkipSpaces;
    procedure Skip(N: Integer; const Spaces: Boolean = False);
    function GetIndent: Integer;
    function GetChar: Char;
    function GetString(N: Integer): String;
    function PeekChar(const Offset: Integer = 0): Char;

  public
    constructor Create(AStream: TStream; const ABufferSize: Integer = 0);
    destructor Destroy; override;

    function GetNextToken: TyamlToken;

    property EOF: Boolean read FEOF;
    property Quoting: TyamlScalarQuoting read FQuoting;
    property Scalar: String read FScalar;
    property Style: TyamlScalarStyle read FStyle;
    property Indent: Integer read FIndent;
    property Key: String read FKey;
  end;

  EyamlException = class(Exception);
  EyamlSyntaxError = class(EyamlException);

implementation

const
  DefBufferSize  = 65536;
  DefBufferShift = 16384;

{ TyamlScanner }

procedure TyamlScanner.CheckEOF;
begin
  if FEOF then
    raise EyamlSyntaxError.Create('Syntax error');
end;

constructor TyamlScanner.Create(AStream: TStream; const ABufferSize: Integer = 0);
begin
  if AStream = nil then
    raise EyamlException.Create('Stream is not assigned');
  if ABufferSize < 0 then
    raise EyamlException.Create('Invalid buffer size');
  FStream := AStream;
  if ABufferSize = 0 then
    FBufferSize := DefBufferSize
  else
    FBufferSize := ABufferSize;
  GetMem(FBuffer, FBufferSize);
  ReadNextBlock;
  FState := sAtStreamStart;
  FStyle := sLiteral;
end;

destructor TyamlScanner.Destroy;
begin
  FreeMem(FBuffer);
  inherited;
end;

function TyamlScanner.GetChar: Char;
begin
  CheckEOF;
  Result := FBuffer[FPosition];
  Inc(FPosition);
  ReadNextBlock;
end;

function TyamlScanner.GetIndent: Integer;
begin
  Result := 0;
  while PeekChar = #32 do
  begin
    Inc(Result);
    GetChar;
  end;
end;

function TyamlScanner.GetNextToken: TyamlToken;
var
  QuoteMatched: Boolean;
  L: Integer;
begin
  Result := tUndefined;
  while (Result = tUndefined) and (not EOF) do
  begin
    FIndent := GetIndent;

    if EOF then
      continue;

    if PeekChar = '#' then
    begin
      SkipUntilEOL;
      continue;
    end;

    case FState of
      sAtStreamStart:
      begin
        Result := tStreamStart;
        FState := sDirective
      end;

      sDirective:
      begin
        while PeekChar = '%' do
          SkipUntilEOL;
        FState := sDocument;
      end;

      sDocument:
      begin
        if (PeekChar = '-')
          and (PeekChar(1) = '-')
          and (PeekChar(2) = '-') then
        begin
          Skip(3, True);
          if PeekChar = '|' then
          begin
            FStyle := sLiteral;
            SkipUntilEOL;
          end
          else if PeekChar = '>' then
          begin
            FStyle := sFolded;
            SkipUntilEOL;
          end else
            FStyle := sLiteral;
          Result := tDocumentStart;
        end
        else if (PeekChar = '.')
          and (PeekChar(1) = '.')
          and (PeekChar(2) = '.') then
        begin
          Skip(3, True);
          Result := tDocumentEnd;
        end else
          case PeekChar of
            '-':
            begin
              Skip(1, True);
              FState := sDocument;
              Result := tSequenceStart;
            end;

            '"':
            begin
              Skip(1, False);
              FQuoting := qDoubleQuoted;
              FScalar := '';
              FState := sScalar;
            end;

            '''':
            begin
              Skip(1, False);
              FQuoting := qSingleQuoted;
              FScalar := '';
              FState := sScalar;
            end;
          else
            L := 0;
            while (not EOF) and (not (PeekChar(L) in [#13, #10, ':'])) do
              Inc(L);

            if (not EOF) and (L > 0) and (PeekChar(L) = ':') then
            begin
              FKey := Trim(GetString(L));
              Skip(1, True);
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
          if (FQuoting = qSingleQuoted) and (PeekChar = '''') then
          begin
            if PeekChar(1) = '''' then
            begin
              FScalar := FScalar + '''';
              Skip(2, False);
            end else
            begin
              GetChar;
              QuoteMatched := True;
            end;
          end
          else if (FQuoting = qDoubleQuoted) and (PeekChar = '"') then
          begin
            if PeekChar(1) = '"' then
            begin
              FScalar := FScalar + '"';
              Skip(2, False);
            end else
            begin
              GetChar;
              QuoteMatched := True;
            end;
          end
          else if PeekChar in [#10, #13] then
          begin
            while PeekChar in [#10, #13] do GetChar;
            if (FQuoting = qPlain) and (GetIndent = 0) then
              break;
            if FStyle = sLiteral then
              FScalar := FScalar + #13#10
            else
              FScalar := FScalar + ' ';    
          end else
            FScalar := FScalar + GetChar;
        end;
        if (not QuoteMatched) and (FQuoting in [qSingleQuoted, qDoubleQuoted]) then
          raise EyamlSyntaxError.Create('Syntax error');
        SkipSpaces;
        FState := sDocument;
      end;
    end;
  end;

  if Result = tUndefined then
    Result := tStreamEnd;
end;

function TyamlScanner.GetString(N: Integer): String;
var
  L: Integer;
begin
  SetLength(Result, N);
  L := 1;
  while L <= N do
  begin
    Result[L] := GetChar;
    Inc(L);
  end;
end;

function TyamlScanner.PeekChar(const Offset: Integer = 0): Char;
begin
  if (Offset < 0) or (Offset >= FBufferSize) then
    raise EyamlException.Create('Invalid offset');
  if FEOF then
    Result := #0
  else begin
    ShiftBuffer(Offset);
    if FPosition + Offset < FBufferCount then
      Result := FBuffer[FPosition + Offset]
    else
      Result := #0;
  end;
end;

procedure TyamlScanner.ReadNextBlock;
begin
  if FPosition = FBufferCount then
  begin
    Inc(FBufferStart, FBufferCount);
    FPosition := 0;
    FBufferCount := FStream.Read(FBuffer^, FBufferSize);
    FEOF := FBufferCount = 0;
  end;
end;

procedure TyamlScanner.ShiftBuffer(const Offset: Integer);
var
  Shift: Integer;
begin
  if FPosition + Offset >= FBufferCount then
  begin
    Shift := FPosition + Offset - FBufferCount + 1;
    if Shift < DefBufferShift then Shift := DefBufferShift;
    if Shift > FPosition then Shift := FPosition;
    Move(FBuffer[Shift], FBuffer[0], FBufferCount - Shift);
    Dec(FPosition, Shift);
    Dec(FBufferCount, Shift);
    Inc(FBufferStart, Shift);
    Inc(FBufferCount, FStream.Read(FBuffer[FBufferCount], FBufferSize - FBufferCount));
  end;
end;

procedure TyamlScanner.Skip(N: Integer; const Spaces: Boolean = False);
begin
  while N > 0 do
  begin
    GetChar;
    Dec(N);
  end;

  if Spaces then
    SkipSpaces;
end;

procedure TyamlScanner.SkipSpaces;
begin
  while PeekChar in [#32, #10, #13] do
    GetChar;
end;

procedure TyamlScanner.SkipUntilEOL;
begin
  while (not EOF) and (not (PeekChar in [#10, #13])) do GetChar;
  while (not EOF) and (PeekChar in [#10, #13]) do GetChar;
end;

end.
