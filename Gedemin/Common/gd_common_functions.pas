
unit gd_common_functions;

interface

uses
  Classes;

function GetCurEXEVersion: String;
procedure SaveStringToStream(const Str: String; Stream: TStream);
function ReadStringFromStream(Stream: TStream): string;
procedure SaveBooleanToStream(Value: Boolean; Stream: TStream);
function ReadBooleanFromStream(Stream: TStream): Boolean;
procedure SaveIntegerToStream(Value: Integer; Stream: TStream);
function ReadIntegerFromStream(Stream: TStream): Integer;
// ���������� ���������� ��� ����� (��������� ���������� �������)
function CorrectFileName(const FN: String): String;
procedure ParseDatabaseName(ADatabaseName: String; out AServer: String;
  out APort: Integer; out AFileName: String);
function ALIPAddrToName(IPAddr: String): String;
function AnsiCharToHex(const B: AnsiChar): String;
function HexToAnsiChar(const St: AnsiString; const P: Integer = 1): AnsiChar;
function TryObjectBinaryToText(var S: String): Boolean;
function TryObjectTextToBinary(var S: String): Boolean;
function GetFileLastWrite(const AFullName: String): TDateTime;
function ParseFieldOrigin(const AnOrigin: String; out ARelationName, AFieldName: String): Boolean;
function ExpandMetaVariables(const S: String): String;
function AddSpaces(const S: String): String;
function BooleanToString(const B: Boolean): String;

implementation

uses
  Windows, SysUtils, Forms, jclFileUtils, WinSock;

function BooleanToString(const B: Boolean): String;
begin
  if B then
    Result := 'True'
  else
    Result := 'False';
end;

function AddSpaces(const S: String): String;
begin
  Result := S + StringOfChar(' ', 20 - Length(S));
end;

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
  CorrectSymbols = ['A'..'Z', 'a'..'z', '�'..'�', '_', '0'..'9', ' ', '.', '-'];
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

function TryObjectBinaryToText(var S: String): Boolean;
var
  StIn, StOut: TStringStream;
begin
  if (UpperCase(Copy(S, 0, 3)) = 'TPF') and (UpperCase(Copy(S, 7, 11)) <> 'GRID_STREAM') then
  begin
    StIn := TStringStream.Create(S);
    StOut := TStringStream.Create('');
    try
      try
        ObjectBinaryToText(StIn, StOut);
        S := StOut.DataString;
        Result := True;
      except
        Result := False;
      end;
    finally
      StIn.Free;
      StOut.Free;
    end;
  end else
    Result := False;
end;

function TryObjectTextToBinary(var S: String): Boolean;
var
  StIn, StOut: TStringStream;
begin
  if AnsiPos('object', S) > 0 then
  begin
    StIn := TStringStream.Create(S);
    StOut := TStringStream.Create('');
    try
      try
        ObjectTextToBinary(StIn, StOut);
        S := StOut.DataString;
        Result := True;
      except
        Result := False;
      end;
    finally
      StOut.Free;
      StIn.Free;
    end;
  end else
    Result := False;
end;

function GetFileLastWrite(const AFullName: String): TDateTime;
var
  T: TFileTime;
  S, L: TSystemTime;
  f: THandle;
  TZ: TTimeZoneInformation;
begin
  Result := 0;
  begin
    f := FileOpen(AFullName, fmOpenRead or fmShareDenyNone);
    try
      if (f <> 0) and GetFileTime(f, nil, nil, @T)
        and (GetTimeZoneInformation(TZ) <> $FFFFFFFF)
        and FileTimeToSystemTime(T, S)
        and SystemTimeToTzSpecificLocalTime(@TZ, S, L) then
      begin
        Result := EncodeDate(L.wYear, L.wMonth, L.wDay) +
          EncodeTime(L.wHour, L.wMinute, L.wSecond, 0);
      end;
    finally
      FileClose(f);
    end;
  end;
end;

function ParseFieldOrigin(const AnOrigin: String; out ARelationName, AFieldName: String): Boolean;
var
  P: Integer;
begin
  ARelationName := '';
  AFieldName := '';

  if AnOrigin > '' then
  begin
    if AnOrigin[1] = '"' then
    begin
      P := 2;
      while (P <= Length(AnOrigin)) and (AnOrigin[P] <> '"') do
        Inc(P);
      if (P < Length(AnOrigin)) and (AnOrigin[P + 1] = '.') then
      begin
        ARelationName := Copy(AnOrigin, 2, P - 2);
        AFieldName := Copy(AnOrigin, P + 3, Length(AnOrigin) - P - 3);
      end
      else if P = Length(AnOrigin) then
        AFieldName := Copy(AnOrigin, 2, P - 2);
    end else
    begin
      P := Pos('.', AnOrigin);
      if P > 0 then
      begin
        ARelationName := Copy(AnOrigin, 1, P - 1);
        AFieldName := Copy(AnOrigin, P + 1, 255);
      end else
        AFieldName := AnOrigin;
    end;
  end;

  Result := AFieldName > '';
end;

function ExpandMetaVariables(const S: String): String;
begin
  Result := StringReplace(S,      '[YYYY]', FormatDateTime('yyyy', Now), [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '[MM]',   FormatDateTime('mm', Now), [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '[DD]',   FormatDateTime('dd', Now), [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '[HH]',   FormatDateTime('hh', Now), [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '[NN]',   FormatDateTime('nn', Now), [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '[SS]',   FormatDateTime('ss', Now), [rfReplaceAll, rfIgnoreCase]);
end;

end.
