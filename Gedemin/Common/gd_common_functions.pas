
unit gd_common_functions;

interface

uses
  Classes, Windows;

function GetCurEXEVersion: String;
procedure SaveStringToStream(const Str: String; Stream: TStream);
function ReadStringFromStream(Stream: TStream): String;
procedure SaveBooleanToStream(const Value: Boolean; Stream: TStream);
function ReadBooleanFromStream(Stream: TStream): Boolean;
procedure SaveIntegerToStream(const Value: Integer; Stream: TStream);
function ReadIntegerFromStream(Stream: TStream): Integer;
procedure SaveInt64ToStream(const Value: Int64; Stream: TStream);
function ReadInt64FromStream(Stream: TStream): Int64;
procedure SaveCardinalToStream(const Value: Cardinal; Stream: TStream);
function ReadCardinalFromStream(Stream: TStream): Cardinal;
procedure SaveDateTimeToStream(const Value: TDateTime; Stream: TStream);
function ReadDateTimeFromStream(Stream: TStream): TDateTime;
procedure SaveStreamToStream(Value: TStream; Stream: TStream);
procedure ReadStreamFromStream(Dest: TStream; Source: TStream);
// возвращает корректное имя файла (оставляет допустимые символы)
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
function AddSpaces(const S: String = ''): String;
function BooleanToString(const B: Boolean): String;
function ForceForegroundWindow(hwnd: THandle): boolean;
function DecodeUTF8(const Source: AnsiString): WideString;
function WideStringToStringEx(const WS: WideString; out CharReplace: LongBool): String;
function NameCase(const S: String): String;

implementation

uses
  SysUtils, Forms, jclFileUtils, WinSock, gd_directories_const;

function NameCase(const S: String): String;
begin
  if Length(S) > 1 then
    Result := AnsiUpperCase(Copy(S, 1, 1)) + AnsiLowerCase(Copy(S, 2, MAXINT))
  else
    Result := AnsiLowerCase(S);
end;

function ForceForegroundWindow(hwnd: THandle): boolean;
{
found here:
http://delphi.newswhat.com/geoxml/forumhistorythread?groupname=borland.public.delphi.rtl.win32&messageid=501_3f8aac4b@newsgroups.borland.com
}
const
  SPI_GETFOREGROUNDLOCKTIMEOUT = $2000;
  SPI_SETFOREGROUNDLOCKTIMEOUT = $2001;
var
  ForegroundThreadID: DWORD;
  ThisThreadID: DWORD;
  timeout: DWORD;
begin
  if IsIconic(hwnd) then ShowWindow(hwnd, SW_RESTORE);
  if GetForegroundWindow = hwnd then Result := true
  else begin
    // Windows 98/2000 doesn't want to foreground a window when some other
    // window has keyboard focus

    if ((Win32Platform = VER_PLATFORM_WIN32_NT) and (Win32MajorVersion > 4)) or
       ((Win32Platform = VER_PLATFORM_WIN32_WINDOWS) and ((Win32MajorVersion > 4) or
                                                          ((Win32MajorVersion = 4) and (Win32MinorVersion > 0)))) then begin
      // Code from Karl E. Peterson, www.mvps.org/vb/sample.htm
      // Converted to Delphi by Ray Lischner
      // Published in The Delphi Magazine 55, page 16

      Result := false;
      ForegroundThreadID := GetWindowThreadProcessID(GetForegroundWindow,nil);
      ThisThreadID := GetWindowThreadPRocessId(hwnd,nil);
      if AttachThreadInput(ThisThreadID, ForegroundThreadID, true) then
      begin
        BringWindowToTop(hwnd); // IE 5.5 related hack
        SetForegroundWindow(hwnd);
        AttachThreadInput(ThisThreadID, ForegroundThreadID, false);  // bingo
        Result := (GetForegroundWindow = hwnd);
      end;
      if not Result then begin
        // Code by Daniel P. Stasinski

        SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @timeout, 0);
        SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, TObject(0), SPIF_SENDCHANGE);
        BringWindowToTop(hwnd); // IE 5.5 related hack
        SetForegroundWindow(hWnd);
        SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, TObject(timeout), SPIF_SENDCHANGE);
      end;
    end
    else begin
      BringWindowToTop(hwnd); // IE 5.5 related hack
      SetForegroundWindow(hwnd);
    end;

    Result := (GetForegroundWindow = hwnd);
  end;
end; { ForceForegroundWindow }

function BooleanToString(const B: Boolean): String;
begin
  if B then
    Result := 'True'
  else
    Result := 'False';
end;

function AddSpaces(const S: String = ''): String;
begin
  if S > '' then
    Result := S + StringOfChar(' ', 20 - Length(S)) + ' = '
  else
    Result := StringOfChar(' ', 23);  
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

function ReadStringFromStream(Stream: TStream): String;
var
  L: Integer;
begin
  Stream.ReadBuffer(L, SizeOf(L));
  if L > 0 then
  begin
    SetLength(Result, L);
    Stream.ReadBuffer(Result[1], L);
  end else if L < 0 then
    raise Exception.Create('Invalid stream format')
  else
    Result := '';
end;

procedure SaveBooleanToStream(const Value: Boolean; Stream: TStream);
begin
  Stream.WriteBuffer(Value, SizeOf(Value));
end;

function ReadBooleanFromStream(Stream: TStream): Boolean;
begin
  Stream.ReadBuffer(Result, SizeOf(Result));
end;

procedure SaveIntegerToStream(const Value: Integer; Stream: TStream);
begin
  Stream.WriteBuffer(Value, SizeOf(Value));
end;

function ReadIntegerFromStream(Stream: TStream): Integer;
begin
  Stream.ReadBuffer(Result, SizeOf(Result));
end;

procedure SaveInt64ToStream(const Value: Int64; Stream: TStream);
begin
  Stream.WriteBuffer(Value, SizeOf(Value));
end;

function ReadInt64FromStream(Stream: TStream): Int64;
begin
  Stream.ReadBuffer(Result, SizeOf(Result));
end;

procedure SaveCardinalToStream(const Value: Cardinal; Stream: TStream);
begin
  Stream.WriteBuffer(Value, SizeOf(Value));
end;

function ReadCardinalFromStream(Stream: TStream): Cardinal;
begin
  Stream.ReadBuffer(Result, SizeOf(Result));
end;

procedure SaveDateTimeToStream(const Value: TDateTime; Stream: TStream);
begin
  Stream.WriteBuffer(Value, SizeOf(Value));
end;

function ReadDateTimeFromStream(Stream: TStream): TDateTime;
begin
  Stream.ReadBuffer(Result, SizeOf(Result));
end;

procedure SaveStreamToStream(Value: TStream; Stream: TStream);
var
  Size: Integer;
begin
  if Value = nil then
    Size := 0
  else
    Size := Value.Size;

  Stream.WriteBuffer(Size, SizeOf(Size));

  if Size > 0 then
    Stream.CopyFrom(Value, 0);
end;

procedure ReadStreamFromStream(Dest: TStream; Source: TStream);
var
  Size: Integer;
begin
  Source.ReadBuffer(Size, SizeOf(Size));
  if Size > 0 then
    Dest.CopyFrom(Source, Size)
  else if Size < 0 then
    raise Exception.Create('Invalid stream format');
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

function WideStringToStringEx(const WS: WideString; out CharReplace: LongBool): String;
var
  InputLength,
  OutputLength: Integer;
begin
  CharReplace := False;
  InputLength := Length(WS);
  OutputLength := WideCharToMultiByte(WIN1251_CODEPAGE, 0, PWideChar(WS), InputLength, nil, 0, nil, nil);
  SetLength(Result, OutputLength);
  WideCharToMultiByte(WIN1251_CODEPAGE, 0, PWideChar(WS), InputLength, PChar(Result), OutputLength, nil, @CharReplace);
end;

function DecodeUTF8(const Source: AnsiString): WideString;
var
  Index, SourceLength, ResultLength, FChar, NChar: Cardinal;
begin
  Result := '';
  Index := 0;
  SourceLength := Length(Source);
  SetLength(Result, SourceLength);
  ResultLength := 0;
  while Index < SourceLength do
  begin
    Inc(Index);
    FChar := Ord(Source[Index]);
    if FChar >= $80 then
    begin
      Inc(Index);
      if Index > SourceLength then
        break;
      FChar := FChar and $3F;
      if (FChar and $20) <> 0 then
      begin
        FChar := FChar and $1F;
        NChar := Ord(Source[Index]);
        if (NChar and $C0) <> $80 then
          break;
        FChar := (FChar shl 6) or (NChar and $3F);
        Inc(Index);
        if Index > SourceLength then
          break;
      end;
      NChar := Ord(Source[Index]);
      if (NChar and $C0) <> $80 then
        break;
      Inc(ResultLength);
      Result[ResultLength] := WideChar((FChar shl 6) or (NChar and $3F));
    end
    else begin
     Inc(ResultLength);
     Result[ResultLength] := WideChar(FChar);
    end;
  end;
  SetLength(Result, ResultLength);
end;

end.
