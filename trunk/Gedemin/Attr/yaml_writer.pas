unit yaml_writer;

interface

uses
  Classes, SysUtils, yaml_common;

type
  TyamlWriter = class(TObject)
  private
    FStream: TStream;
    FBuffer: PAnsiChar;
    FPosition: Integer;
    FIndent: Integer;
    FBOF: Boolean;

    procedure WriteBuffer(const ABuffer: AnsiString;
      const StartNewLine: Boolean = True);

  public
    constructor Create(AStream: TStream);
    destructor Destroy; override;

    procedure Flush;

    procedure WriteDocumentStart(const Folding: TyamlScalarStyle = sPlain);
    procedure WriteDocumentEnd;
    procedure WriteInteger(const I: Integer; const StartNewLine: Boolean = True);
    procedure WriteKey(const AKey: String; const StartNewLine: Boolean = True);

    procedure IncIndent;
    procedure DecIndent;
  end;

implementation

uses
  JclStrings;

const
  DefBufferSize   = 65536;

constructor TyamlWriter.Create(AStream: TStream);
begin
  if AStream = nil then
    raise EyamlException.Create('Stream is not assigned');

  FStream := AStream;
  GetMem(FBuffer, DefBufferSize);
  FillChar(FBuffer^, DefBufferSize, #32);
  FBOF := True;
end;

procedure TyamlWriter.Flush;
begin
  if FPosition > 0 then
  begin
    FStream.WriteBuffer(FBuffer^, FPosition);
    FillChar(FBuffer^, FPosition, #32);
    FPosition := 0;
  end;  
end;

destructor TyamlWriter.Destroy;
begin
  if FPosition > 0 then
  try
    FStream.WriteBuffer(FBuffer^, FPosition);
  except
  end;  
  FreeMem(FBuffer);
  inherited;
end;

procedure TyamlWriter.DecIndent;
begin
  Assert(FIndent >= 2);
  Dec(FIndent, 2);
end;

procedure TyamlWriter.IncIndent;
begin
  Inc(FIndent, 2);
end;

procedure TyamlWriter.WriteDocumentStart(const Folding: TyamlScalarStyle = sPlain);
begin
  case Folding of
    sPlain:   WriteBuffer('--- ');
    sLiteral: WriteBuffer('--- | ');
    sFolded:  WriteBuffer('--- > ');
  end;
end;

procedure TyamlWriter.WriteBuffer(const ABuffer: AnsiString;
  const StartNewLine: Boolean = True);
var
  L, TL: Integer;
begin
  L := Length(ABuffer);

  if StartNewLine and (not FBOF) then
  begin
    TL := 2 + FIndent + L;
    if TL > DefBufferSize then
      raise EyamlException.Create('Data too long');
    if FPosition + TL > DefBufferSize then
      Flush;
    FBuffer[FPosition] := #13;
    FBuffer[FPosition + 1] := #10;
    Inc(FPosition, 2 + FIndent);
    if L > 0 then
    begin
      Move(ABuffer[1], FBuffer[FPosition], L);
      Inc(FPosition, L);
    end;
  end
  else if L > 0 then
  begin
    if L > DefBufferSize then
      raise EyamlException.Create('Data too long');
    if FPosition + L > DefBufferSize then
      Flush;
    Move(ABuffer[1], FBuffer[FPosition], L);
    Inc(FPosition, L);
    FBOF := False;
  end;
end;

procedure TyamlWriter.WriteDocumentEnd;
begin
  WriteBuffer('...');
end;

procedure TyamlWriter.WriteInteger(const I: Integer;
  const StartNewLine: Boolean = True);
begin
  WriteBuffer(IntToStr(I), StartNewLine);
end;

procedure TyamlWriter.WriteKey(const AKey: String;
  const StartNewLine: Boolean);
begin
  WriteBuffer(AKey + ': ', StartNewLine);
end;

end.
