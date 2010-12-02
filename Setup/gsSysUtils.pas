unit gsSysUtils;

interface

// Возвращает строку с последней ошибкой
function GetLastErrorMessage: String;
// Возвращает системную директорию
function SystemDirectory: String;
function GetComputerNameString: String;
function GetWindowsDirectoryString: String;
function GetUserNameString: String;
function GetTempPathString: String;

function GetProgramFilesString: String;    

implementation

uses
  Windows, SysUtils, JclSysInfo;

function GetLastErrorMessage: String;
var
  lpMsgBuf: PChar;
begin
  lpMsgBuf := nil;
  if FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM,
   nil, GetLastError, 0, @lpMsgBuf,
   0, nil) = 0 then
    Result := Format('Код ошибки %d', [GetLastError])
  else
    Result := lpMsgBuf;
  if lpMsgBuf <> nil then
  { TODO -oJKL -cGetLastError : Проверить правильность освобожения }
    LocalFree(Cardinal(lpMsgBuf));
end;

function SystemDirectory: String;
var
  SysDir: PChar;
  Size: Integer;
begin
  Size := GetSystemDirectory(nil, 0);
  GetMem(SysDir, Size);
  try
    if GetSystemDirectory(SysDir, Size) = 0 then
      raise Exception.Create(GetLastErrorMessage)
    else
      Result := SysDir;
  finally
    FreeMem(SysDir, Size);
  end;
end;

function GetTempPathString: String;
var
  TempDir: PChar;
  Size: Integer;
begin
  Size := GetSystemDirectory(nil, 0);
  GetMem(TempDir, Size);
  try
    if GetSystemDirectory(TempDir, Size) = 0 then
      raise Exception.Create(GetLastErrorMessage)
    else
      Result := TempDir;
  finally
    FreeMem(TempDir, Size);
  end;
end;

function GetComputerNameString: String;
var
  CName: PChar;
  I: DWord;
begin
  I := MAX_COMPUTERNAME_LENGTH + 1;
  GetMem(CName, I);
  try
    GetComputerName(CName, I);
    Result := Copy(CName, 1, I);
  finally
    FreeMem(CName);
  end;
end;

function GetUserNameString: String;
var
  CName: PChar;
  I: DWord;
begin
  I := 21;
  GetMem(CName, I);
  try
    GetUserName(CName, I);
    Result := Copy(CName, 1, I);
  finally
    FreeMem(CName);
  end;
end;

function GetWindowsDirectoryString: String;
var
  SysDir: PChar;
  Size: Integer;
begin
  Size := MAX_PATH + 1;
  GetMem(SysDir, Size);
  try
    GetWindowsDirectory(SysDir, Size);
    Result := SysDir;
  finally
    FreeMem(SysDir, Size);
  end;
end;

function GetProgramFilesString: String;    
begin
  Result := GetProgramFilesFolder;
end;


end.
