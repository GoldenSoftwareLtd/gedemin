// ShlTanya, 24.02.2019

unit gsFTPClient;

interface

uses
  Windows, Classes, SysUtils, WinInet;

type
  TgsFTPClient = Class(TObject)
  private
    hConnection: HINTERNET;
    hSession: HINTERNET;
    FApplicationName: String;
    FServerName: String;
    FServerPort: Integer;
    FUserName: String;
    FPassword: String;
    FTimeout : Integer;
    FLastError: Integer;

    FFiles: String;

    function ChangeDirectory(RemotePath: String): Boolean;

    procedure SetApplicationName(const AValue: String);
    procedure SetServerName(const AValue: String);
    procedure SetServerPort(const AValue: Integer);
    procedure SetUserName(const AValue: String);
    procedure SetPassword(const AValue: String);
    procedure SetTimeOut(const AValue: Integer);
    function GetConnected: Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    function Connect: Boolean;
    function GetFile(RemoteFile, LocalFile, RemotePath: String; Overwrite: Boolean): Boolean;
    function PutFile(LocalFile, RemoteFile, RemotePath: String; Overwrite: Boolean): Boolean;
    function GetAllFiles(const RemotePath: String): Boolean;
    function DeleteFile(RemoteFile, RemotePath: String): Boolean;
    function DeleteDir(DirName: String): Boolean;
    function CreateDir(DirName: String): Boolean;
    function RenameFile(OldName, NewName, Path: String): Boolean;
    function GetCurrentDirectory: String;
    function SetCurrentDirectory(const RemotePath: String): Boolean;

    procedure Close;

    property ApplicationName: String read FApplicationName write SetApplicationName;
    property ServerName: String read FServerName write SetServerName;
    property ServerPort: Integer read FServerPort write SetServerPort;
    property Password: String read FPassword write SetPassword;
    property TimeOut: Integer read FTimeout write SetTimeOut;
    property Files: String read FFiles;
    property Connected: Boolean read GetConnected;
    property LastError: Integer read FLastError;
    property UserName: String read FUserName write SetUserName;
  end;

  EgsFTPClient = class(Exception);

implementation

constructor TgsFTPClient.Create;
begin
  inherited Create;
  FApplicationName := 'Gedemin';
  FServerName := '';
  FServerPort := INTERNET_DEFAULT_FTP_PORT;
  FUserName := 'anonymous';
  FPassword := 'guest';
  FTimeOut := 60 * 1000;
  FFiles := '';
end;

procedure TgsFTPClient.Close;
begin
  FLastError := 0;

  if hSession <> nil then
  begin
    InternetCloseHandle(hSession);
    hSession := nil;
  end;

  if hConnection <> nil then
  begin
    InternetCloseHandle(hConnection);
    hConnection := nil;
  end;
end;

procedure TgsFTPClient.SetApplicationName(const AValue: String);
begin
  if FApplicationName <> AValue then
  begin
    Close;
    FApplicationName := AValue;
  end;
end;

procedure TgsFTPClient.SetServerName(const AValue: String);
begin
  if FServerName <> AValue then
  begin
    Close;
    FServerName := AValue;
  end;
end;

procedure TgsFTPClient.SetServerPort(const AValue: Integer);
begin
  if FServerPort <> AValue then
  begin
    Close;
    FServerPort := AValue;
  end;
end;

procedure TgsFTPClient.SetUserName(const AValue: String);
begin
  if FUserName <> AValue then
  begin
    Close;
    FUserName := AValue;
  end;
end;

procedure TgsFTPClient.SetPassword(const AValue: String);
begin
  if FPassword <> AValue then
  begin
    Close;
    FPassword := AValue;
  end;
end;

function TgsFTPClient.Connect: Boolean;
begin
  FLastError := 0;

  if not Connected then
  begin
    hConnection := InternetOpen(
      PChar(ApplicationName),
      INTERNET_OPEN_TYPE_DIRECT,
      nil,
      nil,
      0);

    if hConnection <> nil then
    begin
      if not InternetSetOption(hConnection, INTERNET_OPTION_CONNECT_TIMEOUT, @FTimeout, SizeOf(FTimeout))
        or not InternetSetOption(hConnection, INTERNET_OPTION_RECEIVE_TIMEOUT, @FTimeout, SizeOf(FTimeout))
        or not InternetSetOption(hConnection, INTERNET_OPTION_SEND_TIMEOUT, @FTimeout, SizeOf(FTimeout)) then
      begin
        Close;
        FLastError := GetLastError;
      end else
      begin
        hSession := InternetConnect(hConnection,
          PChar(FServerName),
          ServerPort,
          PChar(FUserName),
          PChar(FPassword),
          INTERNET_SERVICE_FTP,
          INTERNET_FLAG_PASSIVE,
          0);

        if hSession = nil then
        begin
          Close;
          FLastError := GetLastError;
        end
      end;
    end else
      FLastError := GetLastError;
  end;

  Result := FLastError = 0;
end;

function TgsFTPClient.ChangeDirectory(RemotePath: String): Boolean;
var
  CurrentDir: array[0..4096] of Char;
  Buff: Cardinal;
begin
  FLastError := 0;

  if hSession = nil then
    Result := False
  else begin
    Buff := SizeOf(CurrentDir);
    if FtpGetCurrentDirectory(hSession, @CurrentDir, Buff) then
    begin
      if CurrentDir <> RemotePath then
      begin
        while (StrPas(CurrentDir) <> '/') and (FLastError = 0) do
        begin
          if FtpSetCurrentDirectory(hSession, '..') then
          begin
            if not FtpGetCurrentDirectory(hSession, @CurrentDir, Buff) then
              FLastError := GetLastError;
          end else
            FLastError := GetLastError;
        end;
      end;

      if not FtpSetCurrentDirectory(hSession, PChar(RemotePath)) then
      begin
        FLastError := GetLastError;
      end;
    end else
      FLastError := GetLastError;

    Result := FLastError = 0;
  end;
end;

function TgsFTPClient.GetFile(RemoteFile, LocalFile, RemotePath: String; Overwrite: Boolean): Boolean;
begin
  if RemotePath > '' then
  begin
    if RemotePath[Length(RemotePath)] <> '/' then
      RemotePath := RemotePath + '/';
    RemoteFile := RemotePath + RemoteFile;
  end;

  if FtpGetFile(hSession, PChar(RemoteFile), PChar(LocalFile), (not Overwrite), 0, FTP_TRANSFER_TYPE_BINARY, 0) then
    FLastError := 0
  else
    FLastError := GetLastError;

  Result := FLastError = 0;  
end;

function TgsFTPClient.PutFile(LocalFile, RemoteFile, RemotePath: String; Overwrite: Boolean): Boolean;
begin
  if RemotePath > '' then
  begin
    if RemotePath[Length(RemotePath)] <> '/' then
      RemotePath := RemotePath + '/';
    RemoteFile := RemotePath + RemoteFile;
  end;

  if FtpPutFile(hSession, PChar(LocalFile), PChar(RemoteFile), FTP_TRANSFER_TYPE_BINARY, 0) then
    FLastError := 0
  else
    FLastError := GetLastError;

  Result := FLastError = 0;  
end;

function TgsFTPClient.GetAllFiles(const RemotePath: String): Boolean;
var
  fd: WIN32_FIND_DATA;
  hFile: Pointer;
begin
  FFiles := '';
  Result := ChangeDirectory(RemotePath);
  if Result then
  begin
    FLastError := 0;
    hFile := FtpFindFirstFile(hSession, '*.*', fd, 0, 0);
    try
      if hFile = nil then
      begin
        FLastError := GetLastError;
        if FLastError = ERROR_NO_MORE_FILES then
          FLastError := 0;
      end else
      begin
        repeat
          if (fd.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
          begin
            FFiles := FFiles + fd.cFileName + ';';
          end;
        until not InternetFindNextFile(hFile, @fd);
      end;
    finally
      if hFile <> nil then InternetCloseHandle(hFile);
    end;
    Result := FLastError = 0;
  end;
end;

function TgsFTPClient.DeleteFile(RemoteFile, RemotePath: String): Boolean;
begin
  if RemotePath > '' then
  begin
    if RemotePath[Length(RemotePath)] <> '/' then
      RemotePath := RemotePath + '/';
    RemoteFile := RemotePath + RemoteFile;
  end;

  if FtpDeleteFile(hSession, PChar(RemoteFile)) then
    FLastError := 0
  else
    FLastError := GetLastError;

  Result := FLastError = 0;  
end;

function TgsFTPClient.DeleteDir(DirName: String): Boolean;
begin
  if (hSession <> nil) then
  begin
    if FtpRemoveDirectory(hSession, PChar(DirName)) then
      FLastError := 0
    else
      FLastError := GetLastError;

    Result := FLastError = 0;  
  end else
    Result := False;
end;

function TgsFTPClient.CreateDir(DirName: string): Boolean;
begin
  if (hSession <> nil) then
  begin
    if FtpCreateDirectory(hSession, PChar(DirName)) then
      FLastError := 0
    else
      FLastError := GetLastError;

    Result := FLastError = 0;  
  end else
    Result := False;
end;

function TgsFTPClient.RenameFile(OldName, NewName, Path: String): Boolean;
begin
  Result := ChangeDirectory(Path);
  if Result then
  begin
    if FtpRenameFile(hSession, PChar(OldName), PChar(NewName)) then
      FLastError := 0
    else
      FLastError := GetLastError;
    Result := FLastError = 0;  
  end;
end;

destructor TgsFTPClient.Destroy;
begin
  Close;
  inherited;    
end;

procedure TgsFTPClient.SetTimeOut(const AValue: Integer);
begin
  if FTimeout <> AValue then
  begin
    Close;
    FTimeout := AValue;
  end;  
end;

function TgsFTPClient.GetConnected: Boolean;
var
  CurrentDir: array[0..4096] of Char;
  Buff: Cardinal;
begin
  if hSession <> nil then
  begin
    Buff := SizeOf(CurrentDir);
    Result := FtpGetCurrentDirectory(hSession, @CurrentDir, Buff);
    if not Result then
      Close;
  end else
    Result := False;
end;

function TgsFTPClient.GetCurrentDirectory: String;
var
  CurrentDir: array[0..4096] of Char;
  Buff: Cardinal;
begin
  Result := '';
  if hSession <> nil then
  begin
    Buff := SizeOf(CurrentDir);
    if FtpGetCurrentDirectory(hSession, @CurrentDir, Buff) then
    begin
      FLastError := 0;
      Result := CurrentDir;
    end else
      FLastError := GetLastError;
  end;
end;

function TgsFTPClient.SetCurrentDirectory(const RemotePath: String): Boolean;
begin
  Result := ChangeDirectory(RemotePath);
end;

end.
