unit gsFDBConvertConsoleView_unit;

interface

uses
  Windows;

  function AttachToConsole: Boolean;
  function ReleaseConsole: Boolean;

  procedure WriteToConsole(const AOutputString: string);
  procedure WriteToConsoleLn(const AOutputString: string);
  function GetInputString(const AComment: String): String;
  function GetConsoleParamValue(const AParamName: String): String;

  // Функция обработки сообщений API-функции копирования файла
  procedure ConsoleCopyProgressRoutine(TotalFileSize, TotalBytesTransferred: Int64);
  // Функция обработки сообщений сервисов сервера
  procedure ConsoleServiceProgressRoutine(const AServiceMessage: String);
  // Функция обработки сообщений при редактировании метаданных
  procedure ConsoleMetadataProgressRoutine(const AMessage: String; const AMaxProgress, ACurrentProgress: Integer);

implementation

uses
  Sysutils, jclStrings, gsFDBConvertLocalization_unit;

const
  ATTACH_PARENT_PROCESS = High(DWORD);

  CONSOLE_LINE_STARTER = ' FBC> ';

var
  ConsoleOutput: Boolean = False;

// Функция обработки сообщений API-функции копирования файла
procedure ConsoleCopyProgressRoutine(TotalFileSize, TotalBytesTransferred: Int64);
begin
  //
end;

// Функция обработки сообщений сервисов сервера
procedure ConsoleServiceProgressRoutine(const AServiceMessage: String);
begin
  if AServiceMessage <> '' then
    WriteToConsoleLn(AServiceMessage);
end;

// Функция обработки сообщений при редактировании метаданных
procedure ConsoleMetadataProgressRoutine(const AMessage: String; const AMaxProgress, ACurrentProgress: Integer);
begin
  // TODO: Установим параметры прогрессбара

  // Выведем переданнное сообщение
  if AMessage <> '' then
    WriteToConsoleLn(AMessage);
end;

function AttachToConsole: Boolean;
var
  AttachConsole: function(dwProcessId: LongWord): LongBool; stdcall;
begin
  if not ConsoleOutput then
  begin
    AttachConsole := GetProcAddress(GetModuleHandle('kernel32.dll'), 'AttachConsole');
    ConsoleOutput := AttachConsole(ATTACH_PARENT_PROCESS);
    if not ConsoleOutput then
      ConsoleOutput := AllocConsole;
  end;
  Result := ConsoleOutput;
end;

function ReleaseConsole: Boolean;
begin
  Result := FreeConsole;
end;

procedure WriteToConsole(const AOutputString: string);
var
  BytesWritten: DWORD;
  OemString: String;
begin
  if AttachToConsole and (AOutputString <> '') then
  begin
    OemString := CONSOLE_LINE_STARTER + StrAnsiToOem(AOutputString);
    WriteConsole(GetStdHandle(STD_OUTPUT_HANDLE), PChar(OemString), Length(OemString), BytesWritten, nil);
  end;
end;

procedure WriteToConsoleLn(const AOutputString: string);
begin
  WriteToConsole(AOutputString + #13#10);
end;

function GetInputString(const AComment: String): String;
const
  BUFFER_SIZE = 16384;
var
  ReadedString: PChar;
  BytesReaded: DWORD;
begin
  Result := '';
  if AttachToConsole then
  begin
    WriteToConsole(AComment + ' ');
    GetMem(ReadedString, BUFFER_SIZE);
    try
      if ReadConsole(GetStdHandle(STD_INPUT_HANDLE), ReadedString, BUFFER_SIZE, BytesReaded, nil) then
        Result := StrLeft(StrOemToAnsi(String(ReadedString)), BytesReaded);
    finally
      FreeMem(ReadedString);
    end;
  end;
end;

function GetConsoleParamValue(const AParamName: String): String;
var
  ParamCounter: Integer;
  InputParamString: String;
begin
  Result := '';
  for ParamCounter := 1 to ParamCount do
  begin                                       
    InputParamString := ParamStr(ParamCounter);
    if AnsiCompareText(InputParamString, '/' + AParamName) = 0 then
      Result := ParamStr(ParamCounter + 1);
  end;
end;

end.
