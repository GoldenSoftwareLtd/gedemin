
unit yaml_reader;

interface

uses
  Classes, yaml_common;

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
  TyamlReader = class(TObject)
  private
    FStream: TStream;
    FEOF, FBOL: Boolean;
    FBuffer: PAnsiChar;
    FBufferSize: Integer;
    FBufferStart: Integer;
    FBufferCount: Integer;
    FPosition: Integer;
    FIndent: Integer;
    FInitialIndent: Integer;
    FLine: Integer;
    FPositionInLine: Integer;

    procedure ReadNextBlock;
    procedure CheckEOF;
    procedure GetIndent;
    procedure ShiftBuffer(const Offset: Integer);

  public
    constructor Create(AStream: TStream; const ABufferSize: Integer = 0);
    destructor Destroy; override;

    function GetChar: AnsiChar;
    function PeekChar(const Offset: Integer = 0): AnsiChar;
    procedure SkipUntilEOL;
    procedure SkipSpacesUntilEOL;
    procedure Skip(N: Integer; const Spaces: Boolean = False);
    function GetString(N: Integer): AnsiString;

    property EOF: Boolean read FEOF;
    property Indent: Integer read FIndent;
    property Line: Integer read FLine;
    property PositionInLine: Integer read FPositionInLine;
    property InitialIndent: Integer read FInitialIndent write FInitialIndent;   
  end;

implementation

const
  DefBufferSize  = 65536;
  DefBufferShift = 16384;

{ TyamlReader }

procedure TyamlReader.CheckEOF;
begin
  if FEOF then
    raise EyamlSyntaxError.Create('Syntax error');
end;

constructor TyamlReader.Create(AStream: TStream;
  const ABufferSize: Integer);
begin
  if AStream = nil then
    raise EyamlException.Create('Stream is not assigned');
  FStream := AStream;
  if ABufferSize < 0 then
    raise EyamlException.Create('Invalid buffer size');
  if ABufferSize = 0 then
    FBufferSize := DefBufferSize
  else
    FBufferSize := ABufferSize;
  FInitialIndent := 0;  
  GetMem(FBuffer, FBufferSize);
  ReadNextBlock;
  GetIndent;
end;

destructor TyamlReader.Destroy;
begin
  FreeMem(FBuffer);
  inherited;
end;

function TyamlReader.GetChar: AnsiChar;
begin
  CheckEOF;

  if FBOL then
    GetIndent;

  if EOF then
    Result := #00
  else begin
    Result := FBuffer[FPosition];
    FBOL := Result = #10;
    Inc(FPosition);
    Inc(FPositionInLine);
    ReadNextBlock;
  end;
end;

procedure TyamlReader.GetIndent;
begin
  FIndent := 0;
  while (not EOF) and (FBuffer[FPosition] = #32) do
  begin
    if (FInitialIndent <> 0) and (FInitialIndent <= FIndent) then
      break;
    Inc(FIndent);
    Inc(FPosition);
    ReadNextBlock;
  end;
  FPositionInLine := FIndent;
  FBOL := False;
  Inc(FLine);
end;

function TyamlReader.GetString(N: Integer): AnsiString;
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

function TyamlReader.PeekChar(const Offset: Integer): AnsiChar;
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

procedure TyamlReader.ReadNextBlock;
begin
  if FPosition = FBufferCount then
  begin
    Inc(FBufferStart, FBufferCount);
    FPosition := 0;
    FBufferCount := FStream.Read(FBuffer^, FBufferSize);
    FEOF := FBufferCount = 0;
  end;
end;

procedure TyamlReader.ShiftBuffer(const Offset: Integer);
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
      Move(FBuffer[Shift], FBuffer[0], FBufferCount - Shift);
      Dec(FPosition, Shift);
      Dec(FBufferCount, Shift);
      Inc(FBufferStart, Shift);
      Inc(FBufferCount, FStream.Read(FBuffer[FBufferCount],
        FBufferSize - FBufferCount));
    end;
  end;
end;

procedure TyamlReader.Skip(N: Integer; const Spaces: Boolean);
begin
  while N > 0 do
  begin
    GetChar;
    Dec(N);
  end;

  if Spaces then
    SkipSpacesUntilEOL;
end;

procedure TyamlReader.SkipSpacesUntilEOL;
begin
  while PeekChar = #32 do
    GetChar;
  if PeekChar in EOL then
    SkipUntilEOL;
end;

procedure TyamlReader.SkipUntilEOL;
begin
  while not (PeekChar in [#00, #10, #13]) do GetChar;
  while PeekChar in EOL do GetChar;
  if not EOF then GetIndent;
end;

end.