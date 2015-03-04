unit Pos7300Command_unit;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, ActiveX, Classes, ComObj, Pos7300Command_TLB, StdVcl, ShellApi, Variants, Dialogs,  SysUtils;

type
  TPos7300COM = class(TAutoObject, IPos7300COM)
  protected
    procedure ExecuteSelfTest; safecall;
    procedure ClearScreen; safecall;
    procedure MoveMostLeft; safecall;
    procedure PutString(const ToInput: WideString); safecall;
    procedure HorizontalScroll; safecall;
    procedure VerticalScroll; safecall;
    procedure OwerwriteMode; safecall;
    procedure ClearLine; safecall;
    procedure MoveMostRight; safecall;
    procedure BackSpace; safecall;
    procedure Up; safecall;
    procedure Down; safecall;
    procedure Left; safecall;
    procedure Right; safecall;
    procedure CarriageReturn; safecall;
    procedure MoveTo(x, y: Shortint); safecall;
  public
    procedure Initialize; override;
  end;

implementation
uses ComServ;

//*************
{Открыть СОМ-порт как файл}
function OpenPort(out OverWrite: TOverlapped): THandle;
var
  hPort: THandle;
  dcb: TDCB;
begin
  try
    hPort := CreateFile('COM1', GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0);
    if hPort = INVALID_HANDLE_VALUE then
      raise Exception.Create('Error opening port');
    if not SetCommMask(hPort, EV_RXCHAR) then
      raise Exception.Create('Error setting port mask');
    if not GetCommState(hPort, Dcb) then
      raise Exception.Create('Error setting port state');
    Dcb.BaudRate := CBR_9600;
    Dcb.Parity := NOPARITY;
    Dcb.ByteSize := 8;
    Dcb.StopBits := ONESTOPBIT;
    if not SetCommState(hPort, Dcb)then
      raise Exception.Create('Error setting port state');
    OverWrite.hEvent := CreateEvent(nil, True, False, nil);
    if not PurgeComm(hPort, PURGE_TXCLEAR or PURGE_RXCLEAR) then
      raise Exception.Create('Error purging port');
    if OverWrite.hEvent = Null then
      raise Exception.Create('Error creating write event');
    Result := hPort;
  except
    Result := 0;
  end;
end;

{Перевод символа в кодовую таблицу дисплея}
function GetCharCode(Letter: Char): integer;
var OrdValue: integer;
begin
  OrdValue := ord(Letter);
  if (OrdValue > 32) and (OrdValue <= 127) then
    Result := OrdValue { АНГЛИЙСКИЕ СИМВОЛЫ }
  else
    if (OrdValue > 191) and (OrdValue <= 239) then{ РУССКИЕ СИМВОЛЫ А .. п}
      Result := OrdValue - 64
    else
      if (OrdValue > 239) and (OrdValue <= 255) then{ РУССКИЕ СИМВОЛЫ А .. п}
        Result := OrdValue - 16
      else
        if (OrdValue <= 32) then
          Result := OrdValue + 223
        else
          Result := 255;
end;

{Команда с 2 параметрами}
procedure ExecDoubleCommand(param1, param2: byte);
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

{Команда с 1 параметром}
procedure ExecSingleCommand(param1: byte);
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

//*************


procedure TPos7300COM.Initialize;
begin
  inherited;
end;


{Запустить тест}
procedure TPos7300COM.ExecuteSelfTest;
begin
  ExecDoubleCommand(31, 64);
end;
//**************

{Очистить экран}
procedure TPos7300COM.ClearScreen;
begin
  MoveMostLeft;
  ExecSingleCommand(12);
end;

{Очистить текущую строку}
procedure TPos7300COM.ClearLine;
begin
  ExecSingleCommand(24);
end;
//**************
{движения курсора}
procedure TPos7300COM.Up;
begin
  ExecDoubleCommand(0, 72);
end;

procedure TPos7300COM.Down;
begin
  ExecDoubleCommand(0, 80);
end;

procedure TPos7300COM.Left;
begin
  ExecDoubleCommand(0, 75);
end;

procedure TPos7300COM.Right;
begin
  ExecDoubleCommand(0, 77);
end;

{Стать в крайнюю левую позицию}
procedure TPos7300COM.MoveMostLeft;
begin
  ExecDoubleCommand(0, 71);
end;

{перейти в крайнюю правую позицию}
procedure TPos7300COM.MoveMostRight;
begin
  ExecDoubleCommand(0, 79);
end;

{установить позицию курсора}
procedure TPos7300COM.MoveTo(x, y: Shortint);
var
  hPort: THandle;
  OverWrite: TOverlapped;
  dwWrite: DWORD;
  WriteBytes: array [1..4] of Byte;
begin
  if ((x >0) and (x <= 20) and ((y = 1) or (y = 2)))then
  begin
    hPort := OpenPort(OverWrite);
    if hPort > 0 then
      try
        WriteBytes[1] := 27;
        WriteBytes[2] := 80;
        WriteBytes[3] := x;
        WriteBytes[4] := y;
        WriteFile(hPort, WriteBytes, SizeOf(WriteBytes),  dwWrite, @OverWrite);
      finally
        CloseHandle(hPort);
      end;
  end;
end;
//**************
procedure TPos7300COM.BackSpace;
begin
  ExecSingleCommand(8);
end;

{Возврат каретки}
procedure TPos7300COM.CarriageReturn;
begin
  ExecSingleCommand(13);
end;

//**************
{Горизонтальный скролл}
procedure TPos7300COM.HorizontalScroll;
begin
  ExecDoubleCommand(27, 19);
end;

{Вертикальный скролл}
procedure TPos7300COM.VerticalScroll;
begin
  ExecDoubleCommand(27, 18);
end;

{Режим оверрайт}
procedure TPos7300COM.OwerwriteMode;
begin
  ExecDoubleCommand(27,17);
end;

//**************
{Вывести строку}
procedure TPos7300COM.PutString(const ToInput: WideString);
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
    WriteBytes[Counter] := GetCharCode(s[i]);
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
  TAutoObjectFactory.Create(ComServer, TPos7300COM, Class_Pos7300COM,
    ciMultiInstance, tmApartment);
end.

//***********


