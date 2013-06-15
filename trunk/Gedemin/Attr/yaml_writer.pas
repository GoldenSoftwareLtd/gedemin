
unit yaml_writer;

interface

uses
  Classes, SysUtils, yaml_common;

type
  TyamlWriter = class(TObject)
  private
    FStream: TStream;
    FBuffer: PAnsiChar;
    FBufferStart: Integer;
    FPosition: Integer;
    FIndent: Integer;

    procedure WriteBuffer(const ABuffer: AnsiString);

  public
    constructor Create(AStream: TStream);
    destructor Destroy; override;

    procedure Flush;

    procedure WriteDirective(const ADirective: AnsiString);
    procedure WriteDocumentStart(const Folding: TyamlScalarStyle = sPlain);
    procedure WriteDocumentEnd;
    procedure WriteInteger(const I: Integer);
    procedure WriteLargeInt(const I: Int64);
    procedure WriteTimestamp(const Timestamp: TDateTime);
    procedure WriteDate(const Date: TDateTime);
    procedure WriteFloat(const D: Double);
    procedure WriteCurrency(const C: Currency);
    procedure WriteBCD(const Value: AnsiString);
    procedure WriteBinary(AStream: TStream);
    procedure WriteBoolean(const Value: Boolean);
    procedure WriteNull;
    procedure WriteKey(const AKey: AnsiString);
    procedure WriteChar(const Ch: AnsiChar);
    procedure WriteString(const AStr: AnsiString);
    procedure WriteTag(const ATag: AnsiString);
    procedure WriteSequenceIndicator;
    procedure WriteText(const AText: AnsiString; AQuoting: TyamlScalarQuoting = qPlain; AStyle: TyamlScalarStyle = sPlain);
    procedure WriteComment(const AComment: AnsiString);
    procedure WriteEOL;
    procedure StartNewLine;

    procedure IncIndent;
    procedure DecIndent;
  end;

implementation

uses
  JclStrings, JclMime;

const
  DefBufferSize   = 65536;

constructor TyamlWriter.Create(AStream: TStream);
begin
  if AStream = nil then
    raise EyamlException.Create('Stream is not assigned');

  FStream := AStream;
  GetMem(FBuffer, DefBufferSize);
end;

procedure TyamlWriter.Flush;
begin
  if FPosition > 0 then
  begin
    Inc(FBufferStart, FPosition);
    FStream.WriteBuffer(FBuffer^, FPosition);
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
  Assert(FIndent >= DefIndent);
  Dec(FIndent, DefIndent);
end;

procedure TyamlWriter.IncIndent;
begin
  Inc(FIndent, DefIndent);
end;

procedure TyamlWriter.WriteDocumentStart(const Folding: TyamlScalarStyle = sPlain);
begin
  case Folding of
    sPlain:   WriteBuffer('--- ');
    sLiteral: WriteBuffer('--- | ');
    sFolded:  WriteBuffer('--- > ');
  end;
end;

procedure TyamlWriter.WriteSequenceIndicator;
begin
  WriteBuffer('- ');
end;

procedure TyamlWriter.WriteChar(const Ch: AnsiChar);
begin
  WriteBuffer(Ch);
end;

procedure TyamlWriter.WriteString(const AStr: AnsiString);
begin
  WriteBuffer(AStr);
end;

procedure TyamlWriter.WriteFloat(const D: Double);
var
  TempS: AnsiString;
begin
  TempS := FloatToStr(D);
  if DecimalSeparator <> '.' then
    WriteBuffer(StringReplace(TempS, DecimalSeparator, '.', []))
  else
    WriteBuffer(TempS);
end;

procedure TyamlWriter.WriteCurrency(const C: Currency);
var
  TempS: AnsiString;
begin
  TempS := CurrToStr(C);
  if DecimalSeparator <> '.' then
    WriteBuffer(StringReplace(TempS, DecimalSeparator, '.', []))
  else
    WriteBuffer(TempS);
end;

procedure TyamlWriter.WriteTimestamp(const Timestamp: TDateTime);
begin
  WriteBuffer(FormatDateTime('yyyy-mm-dd"T"hh":"nn":"ss', Timestamp) + TZBiasString);
end;

procedure TyamlWriter.WriteDate(const Date: TDateTime);
begin
  WriteBuffer(FormatDateTime('yyyy-mm-dd', Date));
end;

procedure TyamlWriter.WriteBoolean(const Value: Boolean);
begin
  if Value then
    WriteBuffer('True')
  else
    WriteBuffer('False');
end;

procedure TyamlWriter.WriteNull;
begin
  WriteBuffer('~');
end;

procedure TyamlWriter.WriteBinary(AStream: TStream); 
var
  SS: TStringStream;  
begin
  Assert(AStream <> nil);
  SS := TStringStream.Create('');
  try
    MimeEncodeStream(AStream, SS);
    WriteTag('!!binary');
    WriteText(SS.DataString, qPlain, sFolded);
  finally
    SS.Free;
  end;
end;

procedure TyamlWriter.WriteTag(const ATag: AnsiString);
begin
  WriteBuffer(ATag + ' ');
end;

procedure TyamlWriter.WriteText(const AText: AnsiString; AQuoting: TyamlScalarQuoting = qPlain;
  AStyle: TyamlScalarStyle = sPlain);

  function BreakLine(const S: AnsiString; var B: Integer): AnsiString;
  var
    E: Integer;
  begin
    E := B;
    while (E <= Length(S)) and (not (S[E] in EOL)) do
      Inc(E);
    Result := Copy(S, B, E - B);
    B := E;
    while (B <= Length(S)) and (S[B] in EOL) and (B - E < 2) do
      Inc(B);
  end;

  function QuoteString(const S: AnsiString; QuoteChar: AnsiChar): AnsiString;
  begin
    Result := QuoteChar +
      StringReplace(S, QuoteChar, QuoteChar + QuoteChar, [rfReplaceAll]) +
      QuoteChar;
  end;

  function EscapeString(const S: AnsiString): AnsiString;
  const
    HexDigits: AnsiString = '0123456789ABCDEF';
  var
    L, I: Integer;
  begin
    SetLength(Result, Length(S) * 4 + 2);
    L := 1;
    Result[1] := '"';
    for I := 1 to Length(S) do
    begin
      case S[I] of
        '\':
        begin
          Result[L + 1] := '\';
          Result[L + 2] := '\';
          Inc(L, 2);
        end;

        '"':
        begin
          Result[L + 1] := '\';
          Result[L + 2] := '"';
          Inc(L, 2);
        end;

        #00..#31:
        begin
          Result[L + 1] := '\';
          Result[L + 2] := 'x';
          Result[L + 3] := HexDigits[(Ord(S[I]) div 16) + 1];
          Result[L + 4] := HexDigits[(Ord(S[I]) mod 16) + 1];
          Inc(L, 4);
        end;
      else
        Result[L + 1] := S[I];
        Inc(L);
      end;
    end;
    Inc(L);
    Result[L] := '"';
    SetLength(Result, L);
  end;

var
  P: Integer;
  TempS: AnsiString;
begin
  if AStyle = sPlain then
    case AQuoting of
      qDoubleQuoted: WriteBuffer(EscapeString(AText));
      qSingleQuoted: WriteBuffer(QuoteString(AText, ''''));
      qPlain: WriteBuffer(AText);
    end
  else begin
    if AStyle = sLiteral then
    begin
      WriteString('| ');
      if (AText > '') and (AText[1] in [' ', SpaceSubstitute]) then
        TempS := SpaceSubstitute + AText
      else
        TempS := AText;
    end else
    begin
      WriteString('> ');
      TempS := AText;
    end;

    IncIndent;

    P := 1;
    while P <= Length(TempS) do
    begin
      StartNewLine;
      WriteString(BreakLine(TempS, P));
    end;
    DecIndent;
  end;
end;

procedure TyamlWriter.WriteComment(const AComment: AnsiString);
begin
  WriteBuffer('#' + AComment);
end;

procedure TyamlWriter.WriteBuffer(const ABuffer: AnsiString);
var
  L: Integer;
begin
  L := Length(ABuffer);

  if L > 0 then
  begin
    if L > DefBufferSize then
      raise EyamlException.Create('Data too long');
    if FPosition + L > DefBufferSize then
      Flush;
    Move(ABuffer[1], FBuffer[FPosition], L);
    Inc(FPosition, L);
  end;
end;

procedure TyamlWriter.WriteDocumentEnd;
begin
  WriteBuffer('...');
end;

procedure TyamlWriter.WriteInteger(const I: Integer);
begin
  WriteBuffer(IntToStr(I));
end;

procedure TyamlWriter.WriteKey(const AKey: AnsiString);
begin
  WriteBuffer(AKey + ': ');
end;

procedure TyamlWriter.WriteEOL;
begin
  WriteBuffer(#13#10);
end;

procedure TyamlWriter.StartNewLine;
begin
  if (FPosition = 0) and (FBufferStart = 0) then
    WriteBuffer(StringOfChar(#32, FIndent))
  else
    WriteBuffer(#13#10 + StringOfChar(#32, FIndent));
end;

procedure TyamlWriter.WriteDirective(const ADirective: AnsiString);
begin
  WriteString('%' + ADirective);
end;

procedure TyamlWriter.WriteBCD(const Value: AnsiString);
begin
  Assert(Value > '');
  if DecimalSeparator <> '.' then
    WriteText(StringReplace(Value, DecimalSeparator, '.', []), qDoubleQuoted)
  else
    WriteText(Value, qDoubleQuoted);
end;

procedure TyamlWriter.WriteLargeInt(const I: Int64);
begin
  WriteBuffer(IntToStr(I));
end;

end.
