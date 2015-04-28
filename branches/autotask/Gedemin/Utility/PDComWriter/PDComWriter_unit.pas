unit PDComWriter_unit;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, ActiveX, Classes, ComObj, ComServ, PDComWriter_TLB, StdVcl, ShellApi, Variants, Dialogs,  SysUtils;

type
  TPD = class(TAutoObject, IPD)
  protected
    procedure InitCOM(ComNumber, BaudRate: Integer); safecall;
    procedure ExecSingleCommand(param1: Shortint); safecall;
    procedure ExecDoubleCommand(param1, param2: Shortint); safecall;
    procedure ExecTrippleCommand(param1, param2, param3: Shortint); safecall;
    procedure ExecQuadrupleCommand(param1, param2, param3, param4: Shortint); safecall;
    procedure PutString(const ToInput: WideString); safecall;
  private
    FComName: String;
    FBaudRate: Integer;
    FParity: Integer;
    FStopBits: Integer;
    function OpenPort(out OverWrite: TOverlapped): THandle;
  public
    procedure Initialize; override;
  end;

implementation

procedure TPD.Initialize;
begin
  inherited;
  FComName := 'COM1';
  FBaudRate := CBR_9600;
  FParity := NOPARITY;
  FStopBits := ONESTOPBIT;
end;

{Открыть СОМ-порт как файл}
function TPD.OpenPort(out OverWrite: TOverlapped): THandle;
var
  hPort: THandle;
  dcb: TDCB;
begin
  //try
    hPort := CreateFile(PAnsiChar(FComName), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0);
    if hPort = INVALID_HANDLE_VALUE then
      raise Exception.Create('Error opening port');
    if not SetCommMask(hPort, EV_RXCHAR) then
      raise Exception.Create('Error setting port mask');
    if not GetCommState(hPort, Dcb) then
      raise Exception.Create('Error setting port state');
    Dcb.BaudRate := FBaudRate;
    Dcb.Parity := FParity;
    Dcb.ByteSize := 8;
    Dcb.StopBits := FStopBits;
    if not SetCommState(hPort, Dcb)then
      raise Exception.Create('Error setting port state');
    OverWrite.hEvent := CreateEvent(nil, True, False, nil);
    if not PurgeComm(hPort, PURGE_TXCLEAR or PURGE_RXCLEAR) then
      raise Exception.Create('Error purging port');
    if OverWrite.hEvent = Null then
      raise Exception.Create('Error creating write event');
    Result := hPort;
 { except
    Result := 0;
  end; }
end;


procedure TPD.InitCOM(ComNumber, BaudRate: Integer);
begin
  if (ComNumber >= 1) and (ComNumber <= 32) then
    FComName := 'COM' + IntToStr(ComNumber);
  FBaudRate := BaudRate;
end;

{Команда с 1 параметром}
procedure TPD.ExecSingleCommand(param1: Shortint);
var
  hPort: THandle;
  OverWrite: TOverlapped;
  dwWrite: DWORD;
  WriteBytes: Byte;
begin
  hPort := OpenPort(OverWrite);
  if hPort > 0 then
    try
      WriteBytes := param1;
      WriteFile(hPort, WriteBytes, SizeOf(WriteBytes),  dwWrite, @OverWrite);
    finally
      CloseHandle(hPort);
    end;
end;

{Команда с 2 параметрами}
procedure TPD.ExecDoubleCommand(param1, param2: Shortint);
var
  hPort: THandle;
  OverWrite: TOverlapped;
  dwWrite: DWORD;
  WriteBytes: array [1..2] of Byte;
begin
  hPort := OpenPort(OverWrite);
  if hPort > 0 then
    try
      WriteBytes[1] := param1;
      WriteBytes[2] := param2;
      WriteFile(hPort, WriteBytes, SizeOf(WriteBytes),  dwWrite, @OverWrite);
    finally
      CloseHandle(hPort);
    end;
end;

{Команда с 3 параметрами}
procedure TPD.ExecTrippleCommand(param1, param2, param3: Shortint);
var
  hPort: THandle;
  OverWrite: TOverlapped;
  dwWrite: DWORD;
  WriteBytes: array [1..3] of Byte;
begin
  hPort := OpenPort(OverWrite);
  if hPort > 0 then
    try
      WriteBytes[1] := param1;
      WriteBytes[2] := param2;
      WriteBytes[3] := param3;
      WriteFile(hPort, WriteBytes, SizeOf(WriteBytes),  dwWrite, @OverWrite);
    finally
      CloseHandle(hPort);
    end;
end;

{Команда с 4 параметрами}
procedure TPD.ExecQuadrupleCommand(param1, param2, param3, param4: Shortint);
var
  hPort: THandle;
  OverWrite: TOverlapped;
  dwWrite: DWORD;
  WriteBytes: array [1..4] of Byte;
begin
  hPort := OpenPort(OverWrite);
  if hPort > 0 then
    try
      WriteBytes[1] := param1;
      WriteBytes[2] := param2;
      WriteBytes[3] := param3;
      WriteBytes[4] := param4;
      WriteFile(hPort, WriteBytes, SizeOf(WriteBytes),  dwWrite, @OverWrite);
    finally
      CloseHandle(hPort);
    end;
end;

procedure TPD.PutString(const ToInput: WideString);
var
  hPort: THandle;
  OverWrite: TOverlapped;
  dwWrite: DWORD;
  WriteBytes: array [1..14] of Byte;
  i,j, counter: integer;
  S: String;
begin
  for i := 1 to 14 do
    WriteBytes[i] := 0;

  counter := 1;

  S := WideCharToString(PWideChar(ToInput));
  for i := 1 to Length(ToInput) do
  begin
    WriteBytes[Counter] := Ord(s[i]);
    if (Counter = 14) or (i = Length(ToInput)) then
    begin
      for j := Counter + 1 to 14 do
        WriteBytes[j] := 0;
      Counter := 0;
      hPort := OpenPort(OverWrite);
      if hPort > 0 then
        try
          WriteFile(hPort, WriteBytes, SizeOf(WriteBytes),  dwWrite, @OverWrite);
        finally
          CloseHandle(hPort);
        end;
    end;
    Counter := Counter + 1;
  end;
end;


initialization
  TAutoObjectFactory.Create(ComServer, TPD, Class_PD,
    ciMultiInstance, tmApartment);
end.
