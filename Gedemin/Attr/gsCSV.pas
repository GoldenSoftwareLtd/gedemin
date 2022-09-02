// ShlTanya, 03.02.2019

unit gsCSV;

interface

uses
  Classes;

type
  TgsCSVWriter = class(TObject)
  private
    FStream: TStream;
    FBOL: Boolean;

    procedure SetStream(const Value: TStream);
    procedure WriteBuffer(const S: AnsiString);

  public
    constructor Create;
    destructor Destroy; override;

    procedure WriteInteger(const I: Integer);
    procedure WriteLargeInt(const I: Int64);
    procedure WriteTimestamp(const Timestamp: TDateTime);
    procedure WriteDate(const Date: TDateTime);
    procedure WriteFloat(const D: Double);
    procedure WriteCurrency(const C: Currency);
    procedure WriteBCD(const Value: AnsiString);
    procedure WriteBoolean(const Value: Boolean); overload;
    procedure WriteBoolean(const Value: Integer); overload;
    procedure WriteNull;
    procedure WriteChar(const Ch: AnsiChar);
    procedure WriteString(const AStr: AnsiString);

    procedure NewLine;

    property Stream: TStream read FStream write SetStream;
  end;

implementation

uses
  SysUtils, IBHeader, yaml_common;

const
  FieldDelimiter = ',';
  RecordDelimiter = #13#10;

constructor TgsCSVWriter.Create;
begin
  FBOL := True;
end;

destructor TgsCSVWriter.Destroy;
begin
end;

procedure TgsCSVWriter.NewLine;
begin
  if FBOL then
    raise Exception.Create('CSV: at beginning of a line');
  WriteBuffer(RecordDelimiter);
  FBOL := True;
end;

procedure TgsCSVWriter.SetStream(const Value: TStream);
begin
  FStream := Value;
  FBOL := True;
end;

procedure TgsCSVWriter.WriteBCD(const Value: AnsiString);
begin
  Assert(Value > '');
  if DecimalSeparator <> '.' then
    WriteBuffer(StringReplace(Value, DecimalSeparator, '.', []))
  else
    WriteBuffer(Value);
end;

procedure TgsCSVWriter.WriteBoolean(const Value: Integer);
begin
  WriteBoolean(Value <> 0);
end;

procedure TgsCSVWriter.WriteBoolean(const Value: Boolean);
begin
  if Value then
    WriteBuffer('True')
  else
    WriteBuffer('False');
end;

procedure TgsCSVWriter.WriteBuffer(const S: AnsiString);
var
  Buff: AnsiString;
begin
  if not Assigned(FStream) then
    raise Exception.Create('CSV output stream is not assigned.');

  if FBOL then
  begin
    FBOL := False;
    if S > '' then
      FStream.WriteBuffer(S[1], Length(S));
  end else
  begin
    Buff := FieldDelimiter + S;
    FStream.WriteBuffer(Buff[1], Length(Buff));
  end;
end;

procedure TgsCSVWriter.WriteChar(const Ch: AnsiChar);
begin
  WriteBuffer(Ch);
end;

procedure TgsCSVWriter.WriteCurrency(const C: Currency);
var
  TempS: AnsiString;
begin
  TempS := CurrToStr(C);
  if DecimalSeparator <> '.' then
    WriteBuffer(StringReplace(TempS, DecimalSeparator, '.', []))
  else
    WriteBuffer(TempS);
end;

procedure TgsCSVWriter.WriteDate(const Date: TDateTime);
begin
  WriteBuffer(FormatDateTime('yyyy-mm-dd', Date));
end;

procedure TgsCSVWriter.WriteFloat(const D: Double);
var
  TempS: AnsiString;
begin
  TempS := FloatToStr(D);
  if DecimalSeparator <> '.' then
    WriteBuffer(StringReplace(TempS, DecimalSeparator, '.', []))
  else
    WriteBuffer(TempS);
end;

procedure TgsCSVWriter.WriteInteger(const I: Integer);
begin
  WriteBuffer(IntToStr(I));
end;

procedure TgsCSVWriter.WriteLargeInt(const I: Int64);
begin
  WriteBuffer(IntToStr(I));
end;

procedure TgsCSVWriter.WriteNull;
begin
  WriteBuffer('');
end;

procedure TgsCSVWriter.WriteString(const AStr: AnsiString);
var
  OutStr: AnsiString;
  InP, OutP: Integer;
begin
  SetLength(OutStr, Length(AStr) * 2 + 2);
  OutStr[1] := '"';
  InP := 1;
  OutP := 2;
  while InP <= Length(AStr) do
  begin
    case AStr[InP] of
      '"':
      begin
        OutStr[OutP] := '"';
        OutStr[OutP + 1] := '"';
        Inc(OutP, 2);
      end;

      #13:
      begin
        OutStr[OutP] := '\';
        OutStr[OutP + 1] := 'r';
        Inc(OutP, 2);
      end;

      #10:
      begin
        OutStr[OutP] := '\';
        OutStr[OutP + 1] := 'n';
        Inc(OutP, 2);
      end;

      '\':
      begin
        OutStr[OutP] := '\';
        OutStr[OutP + 1] := '\';
        Inc(OutP, 2);
      end;

      FieldDelimiter:
      begin
        OutStr[OutP] := FieldDelimiter;
        Inc(OutP);
      end;
    else
      OutStr[OutP] := AStr[InP];
      Inc(OutP);
    end;
    Inc(InP);
  end;
  OutStr[OutP] := '"';
  SetLength(OutStr, OutP);
  WriteBuffer(OutStr);
end;

procedure TgsCSVWriter.WriteTimestamp(const Timestamp: TDateTime);
begin
  WriteBuffer(FormatDateTime('yyyy-mm-dd"T"hh":"nn":"ss', Timestamp) + TZBiasString);
end;

end.