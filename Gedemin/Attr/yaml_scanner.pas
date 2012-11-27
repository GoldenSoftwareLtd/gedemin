
unit yaml_scanner;

interface

uses
  Classes, SysUtils, yaml_common;

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


  =====================================
  ... | * | * |#13|#10| * | * | * | ...
  ======================^==============
                        |
                    FLineStart

  FLineStart = 0 at the beggining of a file.                  
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
    FIndent, FBlockIndent: Integer;
    FKey: String;
    FLastBufferChar: AnsiChar;
    FLineStart: Integer;
    FTag: String;

    procedure ReadNextBlock;
    procedure CheckEOF;
    procedure ShiftBuffer(const Offset: Integer);
    procedure SkipUntilEOL;
    procedure SkipSpacesUntilEOL;
    procedure Skip(N: Integer; const Spaces: Boolean = False);
    procedure GetIndent;
    function GetChar: AnsiChar;
    function GetString(N: Integer): String;
    function PeekChar(const Offset: Integer = 0): AnsiChar;

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
    property Tag: String read FTag;
  end;

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
  FStyle := sPlain;
end;

destructor TyamlScanner.Destroy;
begin
  FreeMem(FBuffer);
  inherited;
end;

function TyamlScanner.GetChar: AnsiChar;
begin
  CheckEOF;
  Result := FBuffer[FPosition];
  if Result in EOL then
    FLineStart := FPosition + 1;
  Inc(FPosition);
  ReadNextBlock;
end;

procedure TyamlScanner.GetIndent;
var
  PrevChar: AnsiChar;
begin
  while not EOF do
  begin
    if PeekChar in EOL then
    begin
      SkipSpacesUntilEOL;
      continue;
    end;

    if FPosition > 0 then
      PrevChar := FBuffer[FPosition - 1]
    else
      PrevChar := FLastBufferChar;

    if PrevChar in [#00, #13, #10] then
    begin
      FIndent := 0;
      while PeekChar(FIndent) = #32 do
        Inc(FIndent);
      if not (PeekChar(FIndent + 1) in EOL) then
      begin
        Skip(FIndent, False);
        break;
      end;
    end else
      break;
  end;
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
    GetIndent;

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
          FBlockIndent := 0;
          Skip(3, True);
          Result := tDocumentStart;
        end
        else if (PeekChar = '.')
          and (PeekChar(1) = '.')
          and (PeekChar(2) = '.') then
        begin
          FBlockIndent := 0;
          Skip(3, True);
          Result := tDocumentEnd;
        end else
          case PeekChar of
            '-':
            begin
              FBlockIndent := FPosition - FLineStart;
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

            '>':
            begin
              FStyle := sFolded;
              SkipUntilEOL;
            end;

            '|':
            begin
              FStyle := sLiteral;
              SkipUntilEOL;
            end;

            '''':
            begin
              Skip(1, False);
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
            while not (PeekChar(L) in [#00, #13, #10, ':', '#']) do
              Inc(L);

            if (L > 0) and (PeekChar(L) = ':') then
            begin
              FBlockIndent := FPosition - FLineStart;
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
          else if (PeekChar in EOL) or ((PeekChar = '#') and (FQuoting = qPlain)) then
          begin
            if PeekChar = '#' then
              SkipUntilEOL;
            GetIndent;
            if EOF or ((FQuoting = qPlain) and (FIndent <= FBlockIndent)) then
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
        SkipSpacesUntilEOL;
        FScalar := TrimRight(FScalar);
        FState := sDocument;
      end;

      sTag:
      begin
        Result := tTag;
        while not (PeekChar in [#00, #32, #13, #10]) do
          FTag := FTag + GetChar;
        if EOF or (FTag = '!') or (FTag = '!!') then
          raise EyamlSyntaxError.Create('Syntax error');
        SkipSpacesUntilEOL;
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

function TyamlScanner.PeekChar(const Offset: Integer = 0): AnsiChar;
begin
  if (Offset < 0) or (Offset >= DefBufferShift) then
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
    if FBufferCount > 0 then
      FLastBufferChar := FBuffer[FBufferCount - 1];
    Inc(FBufferStart, FBufferCount);
    Dec(FLineStart, FPosition);
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
    if Shift > 0 then
    begin
      if FPosition = Shift then
        FLastBufferChar := FBuffer[Shift - 1];
      Dec(FLineStart, Shift);  
      Move(FBuffer[Shift], FBuffer[0], FBufferCount - Shift);
      Dec(FPosition, Shift);
      Dec(FBufferCount, Shift);
      Inc(FBufferStart, Shift);
      Inc(FBufferCount, FStream.Read(FBuffer[FBufferCount],
        FBufferSize - FBufferCount));
    end;
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
    SkipSpacesUntilEOL;
end;

procedure TyamlScanner.SkipSpacesUntilEOL;
begin
  while PeekChar = #32 do
    GetChar;
  while PeekChar in EOL do
    GetChar;
end;

procedure TyamlScanner.SkipUntilEOL;
begin
  while not (PeekChar in [#00, #10, #13]) do GetChar;
  while PeekChar in EOL do GetChar;
end;

end.
