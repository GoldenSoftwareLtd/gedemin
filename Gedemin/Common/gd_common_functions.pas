
unit gd_common_functions;

interface

uses
  Classes;

// используются для сравнения, если версии введены как строка
function CompareVersion(Ver1, Ver2: String): Integer;
function GetCurEXEVersion: String;
procedure SaveStringToStream(const Str: String; Stream: TStream);
function ReadStringFromStream(Stream: TStream): string;
procedure SaveBooleanToStream(Value: Boolean; Stream: TStream);
function ReadBooleanFromStream(Stream: TStream): Boolean;
procedure SaveIntegerToStream(Value: Integer; Stream: TStream);
function ReadIntegerFromStream(Stream: TStream): Integer;
// возвращает корректное имя файла (оставляет допустимые символы)
function CorrectFileName(const FN: String): String;
procedure ParseDatabaseName(ADatabaseName: String; out AServer: String;
  out APort: Integer; out AFileName: String);
function ALIPAddrToName(IPAddr: String): String;
function AnsiCharToHex(const B: AnsiChar): String;
function HexToAnsiChar(const St: AnsiString; const P: Integer = 1): AnsiChar;

implementation

uses
  Windows, SysUtils, Forms, jclFileUtils, WinSock;

const
  HexDigits: array[0..15] of Char = '0123456789ABCDEF';

function HexToAnsiChar(const St: AnsiString; const P: Integer = 1): AnsiChar;
begin
  Assert((Length(St) - P) > 0);
  Result := Chr((Pos(St[P], HexDigits) - 1) * 16 + (Pos(St[P + 1], HexDigits) - 1));
end;

function AnsiCharToHex(const B: AnsiChar): String;
begin
  Result := HexDigits[Byte(B) div 16] + HexDigits[Byte(B) mod 16];
end;

function ALIPAddrToName(IPAddr: String): String;
var
  SockAddrIn: TSockAddrIn;
  HostEnt: PHostEnt;
  WSAData: TWSAData;
begin
  WSAData.wVersion := 0;
  WSAStartup(MAKEWORD(2,2), WSAData);
  try
    SockAddrIn.sin_addr.s_addr:= inet_addr(PChar(IPAddr));
    HostEnt:= gethostbyaddr(@SockAddrIn.sin_addr.S_addr, 4, AF_INET);
    if HostEnt <> nil then
      Result := StrPas(Hostent^.h_name)
    else
      Result := '';
  finally
    if WSAData.wVersion = 2 then
      WSACleanup;
  end;
end;

procedure ParseDatabaseName(ADatabaseName: String; out AServer: String;
  out APort: Integer; out AFileName: String);
var
  P: Integer;
begin
  ADatabaseName := Trim(ADatabaseName);

  P := Pos(':', ADatabaseName);
  if P = 0 then
  begin
    AServer := '';
    APort := 0;
    AFileName := ADatabaseName;
  end else
  begin
    if Copy(ADatabaseName, P + 1, 1) = '\' then
    begin
      AServer := '';
      APort := 0;
      AFileName := ADatabaseName;
    end else
    begin
      AServer := Copy(ADatabaseName, 1, P - 1);
      AFileName := Copy(ADatabaseName, P + 1, 1024);
      P := Pos('/', AServer);
      if P > 0 then
        APort := StrToIntDef(Copy(AServer, P + 1, 1024), -1)
      else
        APort := 0;  
    end;
  end;

  if (APort < 0) or (APort > MAXWORD) then
    raise Exception.Create('Invalid port number');

  if (ADatabaseName > '') and (AFileName = '') then
    raise Exception.Create('Invalid database file name or alias');
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
  CorrectSymbols = ['A'..'Z', 'a'..'z', 'А'..'я', '_', '0'..'9', ' ', '.', '-'];
var
  i: Integer;
begin
  Result := '';
  for I := 1 to Length(FN) do
    if FN[I] in CorrectSymbols then
      Result := Result + FN[I]
    else
      Result := Result + '_';
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
