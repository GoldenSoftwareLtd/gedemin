
unit gd_common_functions;

interface

uses
  Classes;

// используются для сравнения, если версии введены как строка
function CompareVersion(Ver1, Ver2: String): Integer;
function GetCurEXEVersion: String;
//сохраняет строку в поток
procedure SaveStringToStream(const Str: String; Stream: TStream);
//читает строку из потока
function ReadStringFromStream(Stream: TStream): string;
procedure SaveBooleanToStream(Value: Boolean; Stream: TStream);
function ReadBooleanFromStream(Stream: TStream): Boolean;
procedure SaveIntegerToStream(Value: Integer; Stream: TStream);
function ReadIntegerFromStream(Stream: TStream): Integer;
// возвращает корректное имя файла (оставляет допустимые символы)
function CorrectFileName(const FN: String): String;
function ExtractServerName(const DatabaseName: String): String;

implementation

uses
  SysUtils, Forms, jclFileUtils;

function ExtractServerName(const DatabaseName: String): String;
var
  P: Integer;
begin
  P := Pos(':', DatabaseName);
  if (P > 0) and (Pos(':', Copy(DatabaseName, P + 1, 1024)) > 0) then
  begin
    Result := Copy(DatabaseName, 1, P - 1);
  end else
    Result := '';
end;

function CompareVersion(Ver1, Ver2: String): Integer;
var
  i: Integer;
  v1, v2: String;
begin
  Result := 0;
  i := 1;
  while (i <= 4) and (Result = 0) do
  begin
    if i < 4 then
    begin
      v1 := Copy(Ver1, 1, Pos('.', Ver1)-1);
      v2 := Copy(Ver2, 1, Pos('.', Ver2)-1);
      Delete(Ver1, 1, Pos('.', Ver1));
      Delete(Ver2, 1, Pos('.', Ver2));
    end else
    begin
      v1 := Ver1;
      v2 := Ver2;
    end;

    try
      Result := StrToInt(v1) - StrToInt(v2);
      Inc(i);
    except
      Result := -10;
      Break;
    end;
  end;
end;

function GetCurEXEVersion: String;
begin
  if VersionResourceAvailable(Application.EXEName) then
    with TjclFileVersionInfo.Create(Application.EXEName) do
    try
      Result := BinFileVersion;
    finally
      Free;
    end
  else
    Result := '';
end;

function CorrectFileName(const FN: String): String;
const
  CorrectSymbols = ['A'..'Z', 'a'..'z', 'А'..'я', '_', '0'..'9', ' '];
var
  i: Integer;
begin
  Result := '';
  for I := 1 to Length(FN) do
    if FN[I] in CorrectSymbols then
      Result := Result + FN[I];
end;

procedure SaveStringToStream(const Str: String; Stream: TStream);
var
  L: Integer;
begin
  L := Length(Str);
  Stream.WriteBuffer(L, SizeOf(L));
  if L > 0 then
    Stream.WriteBuffer(Str[1], L);
end;

function ReadStringFromStream(Stream: TStream): string;
var
  L: Integer;
  Str: String;
begin
  Stream.ReadBuffer(L, SizeOf(L));
  SetLength(str, L);
  if L > 0 then
    Stream.ReadBuffer(str[1], L)
  else
    Str := '';
  Result := Str;
end;

procedure SaveBooleanToStream(Value: Boolean; Stream: TStream);
var
  B: Boolean;
begin
  B := Value;
  Stream.WriteBuffer(B, SizeOf(B));
end;

function ReadBooleanFromStream(Stream: TStream): Boolean;
begin
  Stream.ReadBuffer(Result, SizeOf(Result));
end;

procedure SaveIntegerToStream(Value: Integer; Stream: TStream);
var
  B: Integer;
begin
  B := Value;
  Stream.WriteBuffer(B, SizeOf(B));
end;

function ReadIntegerFromStream(Stream: TStream): Integer;
begin
  Stream.ReadBuffer(Result, SizeOf(Result));
end;

end.
