// ShlTanya, 11.02.2019

unit gd_WebClientControl_unit;

interface

uses
  Classes, Windows, Messages, SyncObjs, SysUtils, idHTTP, idURI, idComponent,
  idThreadSafe, gdMessagedThread, gd_FileList_unit, gd_ProgressNotifier_unit,
  IdSSLOpenSSL, Contnrs, gd_messages_const, gdcBaseInterface;

type
  TgdEmailMessageState = (emsReady, emsSending, emsSent, emsError);

  TgdEmailMessage = class(TObject)
  private
    FID: Word;
    FRecipients: String;
    FSubject: String;
    FBodyText: String;
    FSenderEmail: String;
    FHost: String;
    FPort: Integer;
    FLogin: String;
    FPassw: String;
    FIPSec: String;
    FFileName: String;
    FWipeFile: Boolean;
    FWipeDirectory: Boolean;
    FWndHandle: THandle;
    FThreadID: THandle;
    FErrorMsg: String;
    FState: TgdEmailMessageState;
    FSynchronousSend: Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    property ID: Word read FID write FID;
    property Recipients: String read FRecipients write FRecipients;
    property Subject: String read FSubject write FSubject;
    property BodyText: String read FBodyText write FBodyText;
    property SenderEmail: String read FSenderEmail write FSenderEmail;
    property Host: String read FHost write FHost;
    property Port: Integer read FPort write FPort;
    property Login: String read FLogin write FLogin;
    property Passw: String read FPassw write FPassw;
    property IPSec: String read FIPSec write FIPSec;
    property FileName: String read FFileName write FFileName;
    property WipeFile: Boolean read FWipeFile write FWipeFile;
    property WipeDirectory: Boolean read FWipeDirectory write FWipeDirectory;
    property WndHandle: THandle read FWndHandle write FWndHandle;
    property ThreadID: THandle read FThreadID write FThreadID;
    property ErrorMsg: String read FErrorMsg write FErrorMsg;
    property State: TgdEmailMessageState read FState write FState;
    property SynchronousSend: Boolean read FSynchronousSend write FSynchronousSend;
  end;

  TgdWebClientControl = class(TgdMessagedThread)
  private
    FgdWebServerURL: TidThreadSafeString;
    FConnected: TidThreadSafeInteger;
    FServerFileList: TFLCollection;
    FInUpdate: TidThreadSafeInteger;
    FHTTP: TidHTTP;
    FHandler: TIdSSLIOHandlerSocket;
    FCmdList: TStringList;
    FURI: TidURI;
    FDBID: Integer;
    FCompanyName, FCompanyRUID: String;
    FCompanyPhone, FCompanyEmail: String;
    FLocalIP, FUserName: String;
    FEXEVer: String;
    FUpdateToken: String;
    FPath: String;
    FWebServerResponse: TidThreadSafeString;
    FAutoUpdate: Boolean;
    FQuietMode: Boolean;
    FCanUpdate: Boolean;
    FMandatoryUpdate: Boolean;
    FErrorToSend: TidThreadSafeString;
    FSkipNextException: Boolean;
    FEmailCS: TCriticalSection;
    FEmails: TObjectList;
    FEmailLastID: TID;
    FEmailErrorMsg: String;

    function LoadWebServerURL: Boolean;
    function QueryWebServer: Boolean;
    function LoadFilesList: Boolean;
    function ProcessUpdateCommand: Boolean;
    procedure FinishUpdate;
    procedure SyncFinishUpdate;

    function GetgdWebServerURL: String;
    procedure SetgdWebServerURL(const Value: String);

    procedure DoOnWork(Sender: TObject; AWorkMode: TWorkMode; const AWorkCount: Integer);
    function GetConnected: Boolean;
    function GetInUpdate: Boolean;
    function GetWebServerResponse: String;
    function URIEncodeParam(const AParam: String): String;
    procedure DoSendError;

    procedure DoSendEMail;
    function GetSMTPSettings(const ASMTPKey: TID; out ASenderEMail: String;
      out AHost: String; out APort: Integer; out ALogin: String;
      out APassw: String; out AIPSec: String): Boolean;
    function GetEmailCount: Integer;
    function GetEmailAndLock(const AnID: Word; out AnEmailMessage: TgdEmailMessage): Boolean;

  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;
    function ProcessError(var AMsg: TMsg; var AnErrorMessage: String): Boolean; override;
    procedure LogErrorSync; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConnection;
    procedure StartUpdateFiles;
    procedure SendError(const AnErrorMessage: String; const ASkipNextException: Boolean = False);

    function SendEMail(const AHost: String; const APort: Integer;
      const AnIPSec: String;
      const ALogin: String; const APassw: String;
      const ASenderEmail: String; const ARecipients: String;
      const ASubject: String; const ABodyText: String;
      const AFileName: String = ''; const AWipeFile: Boolean = False;
      const AWipeDirectory: Boolean = False;
      const Sync: Boolean = False;
      const AWndHandle: THandle = 0; const AThreadID: THandle = 0): Word; overload;
    function SendEMail(const ASMTPKey: TID;
      const ARecipients: String;
      const ASubject: String; const ABodyText: String;
      const AFileName: String = ''; const AWipeFile: Boolean = False;
      const AWipeDirectory: Boolean = False;
      const Sync: Boolean = False;
      const AWndHandle: THandle = 0; const AThreadID: THandle = 0): Word; overload;
    function SendEMail(const ASMTPKey: TID;
      const ARecipients: String;
      const ASubject: String; const ABodyText: String;
      const AReportKey: TID; const AnExportType: String;
      const Sync: Boolean = False;
      const AWndHandle: THandle = 0; const AThreadID: THandle = 0): Word; overload;

    function GetEmailState(const AnID: Word; out AState: TgdEmailMessageState; out AnErrorMsg: String;
      const AFreeEmailMessage: Boolean = True): Boolean;

    procedure ClearEmailCallbackHandle(const AWndHandle: THandle; const AThreadID: THandle);

    property gdWebServerURL: String read GetgdWebServerURL write SetgdWebServerURL;
    property WebServerResponse: String read GetWebServerResponse;
    property Connected: Boolean read GetConnected;
    property InUpdate: Boolean read GetInUpdate;
    property EmailCount: Integer read GetEmailCount;
    property EmailErrorMsg: String read FEmailErrorMsg;
  end;

  EgdWebClientControl = class(Exception);

var
  gdWebClientControl: TgdWebClientControl;

  function GetIPSec(AnIPSec: String): TIdSSLVersion;
  function GetEmailTempFileName(const AnExportType: String): String;

implementation

uses
  gdcJournal, gd_security, gdNotifierThread_unit,
  gd_directories_const, JclFileUtils, Forms, gd_CmdLineParams_unit,
  gd_GlobalParams_unit, jclSysInfo, IdSMTP, IdMessage, IBSQL,
  gd_encryption, rp_i_ReportBuilder_unit, rp_ReportClient, IdCoderMIME,
  IBDatabase, gd_common_functions;

function GetIPSec(AnIPSec: String): TIdSSLVersion;
begin
  if AnIPSec = 'SSLV2' then
    Result := sslvSSLv2
  else if AnIPSec = 'SSLV23' then
    Result := sslvSSLv23
  else if AnIPSec = 'SSLV3' then
    Result := sslvSSLv3
  else if AnIPSec = 'TLSV1' then
    Result := sslvTLSv1
  else
    raise Exception.Create('unknown ip security protocol.')
end;

function GetEmailTempDirectory: String;
var
  Ch: array[0..1024] of Char;
  RandDir: String;
begin
  GetTempPath(1024, Ch);

  Result := IncludeTrailingBackSlash(Ch);

  repeat
    RandDir := '_gtemp' + IntToStr(100000 + Random(100000));
  until not DirectoryExists(Result + RandDir);

  Result := Result + RandDir;

  if not CreateDir(Result) then
    raise Exception.Create('Ошибка при создании директории ' + Result + '!');

  Result := IncludeTrailingBackSlash(Result);
end;

function GetEmailTempFileName(const AnExportType: String): String;
var
  Ext: String;
begin
  if (AnExportType = 'BIFF') or (AnExportType = 'EXCEL') then
    Ext := 'XLS'
  else if AnExportType= 'XML' then
    Ext := 'XLSX'
  else if AnExportType= 'WORD' then
    Ext := 'DOC'
  else
    Ext := AnExportType;
  Result := GetEmailTempDirectory + 'report.' + Ext;
end;

{ TgdWebClientControl }

constructor TgdWebClientControl.Create;
begin
  inherited Create(True);
  FreeOnTerminate := False;
  Priority := tpLowest;
  FHTTP := TidHTTP.Create(nil);
  FHandler := TIdSSLIOHandlerSocket.Create(nil);
  FHTTP.IOHandler := FHandler;
  FHTTP.HandleRedirects := True;
  FHTTP.ReadTimeout := gd_GlobalParams.GetWebClientTimeout;
  FHTTP.ConnectTimeout := gd_GlobalParams.GetWebClientTimeout;
  FHTTP.OnWork := DoOnWork;
  FURI := TidURI.Create;
  FgdWebServerURL := TidThreadSafeString.Create;
  FWebServerResponse := TidThreadSafeString.Create;
  FConnected := TidThreadSafeInteger.Create;
  FInUpdate := TidThreadSafeInteger.Create;
  FPath := ExtractFilePath(Application.ExeName);
  FErrorToSend := TidThreadSafeString.Create;
end;

procedure TgdWebClientControl.AfterConnection;
begin
  Assert(IBLogin <> nil);

  if FConnected.Value <> 0 then
    exit;

  gdWebServerURL := gd_GlobalParams.GetWebClientRemoteServer;
  if gdWebServerURL > '' then
  begin
    FURI.URLDecode(gdWebServerURL);
    if FURI.Protocol = '' then
      gdWebServerURL := 'http://' + gdWebServerURL;
  end;

  FDBID := IBLogin.DBID;
  FCompanyName := IBLogin.CompanyName;
  FCompanyRUID := gdcBaseManager.GetRUIDStringByID(IBLogin.CompanyKey);
  FCompanyPhone := IBLogin.CompanyPhone;
  FCompanyEmail := IBLogin.CompanyEmail;
  FLocalIP := GetIPAddress(IBLogin.ComputerName);
  FUserName := IBLogin.UserName;
  if VersionResourceAvailable(Application.EXEName) then
    with TjclFileVersionInfo.Create(Application.EXEName) do
    try
      FEXEVer := BinFileVersion;
    finally
      Free;
    end;
  FUpdateToken := gd_GlobalParams.UpdateToken;
  FAutoUpdate := gd_GlobalParams.AutoUpdate;
  FQuietMode := gd_CmdLineParams.QuietMode;
  FCanUpdate := gd_GlobalParams.CanUpdate;

  PostMsg(WM_GD_AFTER_CONNECTION);
end;

function TgdWebClientControl.QueryWebServer: Boolean;
begin
  Result := False;
  if gdWebServerURL = '' then
    ErrorMessage := 'gdWebServerURL is not assigned.'
  else if InUpdate then
    ErrorMessage := 'Update process is running.'
  else begin
    FURI.URI := gdWebServerURL;
    if gdNotifierThread <> nil then
      gdNotifierThread.Add('Подключение к серверу: ' + FURI.Host + '...', 0, 2000);
    try
      FWebServerResponse.Value := FHTTP.Get(TidURI.URLEncode(gdWebServerURL + '/query?' +
        'dbid=' + IntToStr(FDBID) +
        '&c_name=' + FCompanyName +
        '&c_ruid=' + FCompanyRUID +
        '&loc_ip=' + FLocalIP +
        '&exe_ver=' + FExeVer +
        '&update_token=' + FUpdateToken +
        '&c_phone=' + FCompanyPhone +
        '&c_email=' + FCompanyEmail));
      if gdNotifierThread <> nil then
        gdNotifierThread.Add('Подключение прошло успешно.', 0, 2000);
      Result := True;
    except
      on E: Exception do
      begin
        ErrorMessage := E.Message;
        if gdNotifierThread <> nil then
          gdNotifierThread.Add(ErrorMessage, 0, 2000);
      end;
    end;
  end;
end;

function TgdWebClientControl.LoadWebServerURL: Boolean;
begin
  if gdWebServerURL = '' then
  begin
    FURI.URI := Gedemin_NameServerURL;
    if gdNotifierThread <> nil then
      gdNotifierThread.Add('Опрос сервера: ' + FURI.Host + '...', 0, 2000);
    try
      gdWebServerURL := FHTTP.Get(Gedemin_NameServerURL);
    except
      on E: Exception do
        gdNotifierThread.Add('Ошибка: ' + E.Message, 0, 2000);
    end;
  end;

  if gdWebServerURL > '' then
  begin
    if gdNotifierThread <> nil then
      gdNotifierThread.Add('Определен адрес удаленного сервера: ' + gdWebServerURL, 0, 2000);
    Result := True;
  end else
  begin
    if gdNotifierThread <> nil then
      gdNotifierThread.Add('Адрес удаленного сервера не определен.', 0, 2000);
    Result := False;
  end;
end;

function TgdWebClientControl.LoadFilesList: Boolean;
var
  ResponseData: TStringStream;
begin
  Result := False;

  if not gd_GlobalParams.CanUpdate then
    exit;

  if FServerFileList <> nil then
    FreeAndNil(FServerFileList);

  ResponseData := TStringStream.Create('');
  try
    try
      FHTTP.Get(TidURI.URLEncode(gdWebServerURL + '/get_files_list?' +
        'update_token=' + FUpdateToken +
        '&exe_ver=' + FExeVer),
        ResponseData);
      if ResponseData.Size > 0 then
        ResponseData.Position := 0;
      FServerFileList := TFLCollection.Create;
      FServerFileList.UpdateToken := FUpdateToken;
      FServerFileList.ParseYAML(ResponseData);
      FServerFileList.OnProgressWatch := DoOnProgressWatch;

      if FCmdList = nil then
        FCmdList := TStringList.Create
      else
        FCmdList.Clear;

      Result := True;
      if gdNotifierThread <> nil then
        gdNotifierThread.Add('Загружен список файлов...', 0, 2000);
    except
      on E: Exception do
      begin
        ErrorMessage := E.Message;
        if gdNotifierThread <> nil then
          gdNotifierThread.Add(ErrorMessage, 0, 2000);
      end;
    end;
  finally
    ResponseData.Free;
  end;
end;

function TgdWebClientControl.ProcessMessage(var Msg: TMsg): Boolean;
var
  J: Integer;
begin
  Result := True;
  case Msg.Message of
    WM_GD_AFTER_CONNECTION:
      if (FConnected.Value = 0) and LoadWebServerURL then
      begin
        FConnected.Value := 1;
        PostThreadMessage(ThreadID, WM_GD_QUERY_SERVER, 0, 0);
      end;

    WM_GD_QUERY_SERVER:
      if QueryWebServer then
      begin
        if (Pos('UPDATE', FWebServerResponse.Value) > 0) and FAutoUpdate and FCanUpdate then
          PostThreadMessage(ThreadID, WM_GD_UPDATE_FILES, 0, 0);
      end;

    WM_GD_UPDATE_FILES:
      begin
        FInUpdate.Value := 1;
        if LoadFilesList then
          PostThreadMessage(ThreadID, WM_GD_PROCESS_UPDATE_COMMAND, 0, 0)
        else
          FInUpdate.Value := 0;
      end;

    WM_GD_PROCESS_UPDATE_COMMAND:
      if ProcessUpdateCommand then
        PostThreadMessage(ThreadID, WM_GD_PROCESS_UPDATE_COMMAND, 0, 0)
      else
        PostThreadMessage(ThreadID, WM_GD_FINISH_UPDATE, 0, 0);

    WM_GD_FINISH_UPDATE:
      begin
        FinishUpdate;
        FInUpdate.Value := 0;
      end;

    WM_GD_SEND_ERROR:
      begin
        if (FConnected.Value <> 0) and (FInUpdate.Value = 0) and (FDBID > 0)
          and (FErrorToSend.Value > '') then
        begin
          DoSendError;
        end;
        FErrorToSend.Value := '';
      end;

    WM_GD_SEND_EMAIL:
      begin
        DoSendEMail;
      end;

    WM_GD_FREE_EMAIL_MESSAGE:
      if FEmailCS <> nil then
      begin
        FEmailCS.Enter;
        try
          if FEmails <> nil then
            for J := 0 to FEmails.Count - 1 do
              if (FEmails[J] as TgdEmailMessage).ID = Msg.WParam then
              begin
                FEmails.Delete(J);
                break;
              end;
        finally
          FEmailCS.Leave;
        end;
      end;
  else
    Result := False;
  end;
end;

procedure TgdWebClientControl.LogErrorSync;
var
  SMessage: String;
begin
  SMessage := ErrorMessage + #13#10 + 'Message ID: ' + IntToStr(ErrorMsg.Message);

  TgdcJournal.AddEvent(SMessage, 'HTTPClient', -1, nil, True);

  if InUpdate then
  begin
    FPI.State := psError;
    FPI.Message := SMessage;
    Synchronize(SyncProgressWatch);
  end;
end;

destructor TgdWebClientControl.Destroy;
begin
  inherited;
  FgdWebServerURL.Free;
  FWebServerResponse.Free;
  FConnected.Free;
  FInUpdate.Free;
  FServerFileList.Free;
  FHandler.Free;
  FHTTP.Free;
  FCmdList.Free;
  FURI.Free;
  FErrorToSend.Free;
  FEmails.Free;
  FEmailCS.Free;
end;

function TgdWebClientControl.GetgdWebServerURL: String;
begin
  Result := FgdWebServerURL.Value;
end;

procedure TgdWebClientControl.SetgdWebServerURL(const Value: String);
begin
  FgdWebServerURL.Value := Value;
end;

function TgdWebClientControl.ProcessUpdateCommand: Boolean;
begin
  Result := FServerFileList.UpdateFile(FHTTP, gdWebServerURL,
    FCmdList, FMandatoryUpdate);
end;

procedure TgdWebClientControl.FinishUpdate;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  FName: String;
begin
  FServerFileList.OnProgressWatch := nil;
  if Assigned(FCmdList) then
  try
    if FCmdList.Count > 0 then
    begin
      FCmdList.SaveToFile(FPath + Gedemin_Updater_Ini);
      FName := FPath + Gedemin_Updater;
      FillChar(StartupInfo, SizeOf(TStartupInfo), #0);
      StartupInfo.cb := SizeOf(TStartupInfo);
      if CreateProcess(PChar(FName),
        PChar('"' + FName + '" ' + IntToStr(GetCurrentProcessID)),
        nil, nil, False, NORMAL_PRIORITY_CLASS or CREATE_NO_WINDOW, nil, nil,
        StartupInfo, ProcessInfo) then
      begin
        if ErrorMessage = '' then
          Synchronize(SyncFinishUpdate);
      end else
        ErrorMessage := 'Can not start ' + Gedemin_Updater + '. ' +
          SysErrorMessage(GetLastError);
    end;
  finally
    FreeAndNil(FCmdList);
  end;
end;

procedure TgdWebClientControl.StartUpdateFiles;
begin
  if gd_GlobalParams.CanUpdate and (FConnected.Value <> 0) then
  begin
    FMandatoryUpdate := True;
    PostMsg(WM_GD_UPDATE_FILES);
  end;
end;

procedure TgdWebClientControl.DoOnWork(Sender: TObject;
  AWorkMode: TWorkMode; const AWorkCount: Integer);
begin
  if Terminated then
    Abort;
end;

function TgdWebClientControl.GetConnected: Boolean;
begin
  Result := FConnected.Value <> 0;
end;

function TgdWebClientControl.GetInUpdate: Boolean;
begin
  Result := FInUpdate.Value <> 0;
end;

function TgdWebClientControl.GetWebServerResponse: String;
begin
  Result := FWebServerResponse.Value;
end;

procedure TgdWebClientControl.SyncFinishUpdate;
begin
  gd_GlobalParams.NeedRestartForUpdate := True;
  if gdNotifierThread <> nil then
  begin
    gdNotifierThread.Add('Для завершения процесса обновления необходимо перезапустить приложение.', 0, 600000); // 10 минут
    gdNotifierThread.Add('Прежние версии файлов сохранены с расширением .BAK', 0, 2000);
  end;
end;

function TgdWebClientControl.ProcessError(var AMsg: TMsg;
  var AnErrorMessage: String): Boolean;
begin
  if InUpdate and (AMsg.Message = WM_GD_PROCESS_UPDATE_COMMAND) then
    PostThreadMessage(ThreadID, WM_GD_FINISH_UPDATE, 0, 0);
  Result := True;  
end;

function TgdWebClientControl.URIEncodeParam(const AParam: String): String;
begin
  Result := StringReplace(AParam, '=', '%3D', [rfReplaceAll]);
  Result := StringReplace(Result, '&', '%26', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '%22', [rfReplaceAll]);
  Result := StringReplace(Result, '\', '%5C', [rfReplaceAll]);
  Result := StringReplace(Result, '/', '%2F', [rfReplaceAll]);
  Result := StringReplace(Result, '?', '%3F', [rfReplaceAll]);
  Result := StringReplace(Result, #$0A, '%0A', [rfReplaceAll]);
  Result := StringReplace(Result, #$0D, '%0D', [rfReplaceAll]);
  Result := StringReplace(Result, #$09, '%09', [rfReplaceAll]);
end;

procedure TgdWebClientControl.SendError(const AnErrorMessage: String;
  const ASkipNextException: Boolean = False);
begin
  if (FConnected.Value <> 0) and (FInUpdate.Value = 0) and (FDBID > 0)
    and (FErrorToSend.Value = '') then
  begin
    if not FSkipNextException then
    begin
      FErrorToSend.Value := AnErrorMessage;
      PostMsg(WM_GD_SEND_ERROR);
    end;
    FSkipNextException := ASkipNextException;  
  end;
end;

function TgdWebClientControl.SendEMail(const AHost: String; const APort: Integer;
  const AnIPSec: String; 
  const ALogin: String; const APassw: String;
  const ASenderEmail: String; const ARecipients: String;
  const ASubject: String; const ABodyText: String;
  const AFileName: String = ''; const AWipeFile: Boolean = False;
  const AWipeDirectory: Boolean = False;
  const Sync: Boolean = False;
  const AWndHandle: THandle = 0; const AThreadID: THandle = 0): Word;
var
  ES: TgdEmailMessage;
  State: TgdEmailMessageState;
  Delay: Integer;
begin
  if (ARecipients = '') or (ASenderEmail = '') or (AHost = '') or (APort < 0)
    or (APort > 65535) or (ALogin = '') then
    raise Exception.Create('Неверные параметры электронной почты.');

  if FEmailLastID = $FFFF then
    FEmailLastID := 1
  else
    Inc(FEmailLastID);

  ES := TgdEmailMessage.Create;
  ES.ID := FEmailLastID;
  ES.Recipients := ARecipients;
  ES.Subject := ASubject;
  ES.BodyText := ABodyText;
  ES.SenderEmail := ASenderEmail;
  ES.Host := AHost;
  ES.Port := APort;
  ES.Login := ALogin;
  ES.Passw := APassw;
  ES.IPSec := AnIPSec;
  ES.FileName := AFileName;
  ES.WipeFile := AWipeFile;
  ES.WipeDirectory := AWipeDirectory;
  ES.SynchronousSend := Sync;
  ES.WndHandle := AWndHandle;
  ES.ThreadID := AThreadID;

  if FEmailCS = nil then
    FEmailCS := TCriticalSection.Create;

  FEmailCS.Enter;
  try
    if FEmails = nil then
      FEmails := TObjectList.Create(True);
    FEmails.Add(ES);
  finally
    FEMailCS.Leave;
  end;

  if gdNotifierThread <> nil then
    gdNotifierThread.Add('Отправка сообщения: ' + ExpandMetaVariables(ASubject), 0, 2000);

  PostMsg(WM_GD_SEND_EMAIL);

  if Sync then
  begin
    Delay := 10;
    while GetEmailState(FEmailLastID, State, FEmailErrorMsg, False) and (State in [emsReady, emsSending]) do
    begin
      Sleep(Delay);
      if Delay < 30000 then
        Delay := Delay * 2;
    end;
    PostMsg(WM_GD_FREE_EMAIL_MESSAGE, FEmailLastID);
    if State = emsSent then
      Result := FEmailLastID
    else
      Result := 0;
  end else
    Result := FEmailLastID;
end;

procedure TgdWebClientControl.DoSendError;
begin
  if gdWebServerURL = '' then
    ErrorMessage := 'gdWebServerURL is not assigned.'
  else if InUpdate then
    ErrorMessage := 'Update process is running.'
  else begin
    FURI.URI := gdWebServerURL;
    try
      FHTTP.Get(TidURI.URLEncode(gdWebServerURL + '/send_error?' +
        'dbid=' + IntToStr(FDBID) +
        '&c_name=' + URIEncodeParam(FCompanyName) +
        '&c_ruid=' + URIEncodeParam(FCompanyRUID) +
        '&loc_ip=' + URIEncodeParam(FLocalIP) +
        '&user_name=' + URIEncodeParam(FUserName) +
        '&exe_ver=' + URIEncodeParam(FExeVer) +
        '&error_message=' + URIEncodeParam(FErrorToSend.Value)));
      if gdNotifierThread <> nil then
      begin
        gdNotifierThread.Add('Отослано сообщение об ошибке:', 0, 2000);
        gdNotifierThread.Add(FErrorToSend.Value, 0, 2000);
      end;
    except
      on E: Exception do
      begin
        ErrorMessage := E.Message;
        if gdNotifierThread <> nil then
          gdNotifierThread.Add(ErrorMessage, 0, 2000);
      end;
    end;
  end;
end;

procedure TgdWebClientControl.DoSendEMail;

  function EncodeSubj(const AnSubj: String): String;
  begin
    with TIdEncoderMIME.Create(nil) do
      try
        Result := '=?' + 'Windows-1251' + '?B?' + Encode(AnSubj) + '?=';
      finally
        Free;
      end;
  end;

var
  IdSMTP: TidSMTP;
  Msg: TIdMessage;
  IdSSLIOHandlerSocket: TIdSSLIOHandlerSocket;
  Attachment: TIdAttachment;
  Attachments: TObjectList;
  ES: TgdEmailMessage;
  J: Integer;
  K: Integer;
  _ID: Word;
  _Recipients: String;
  _Subject: String;
  _BodyText: String;
  _SenderEmail: String;
  _Host: String;
  _Port: Integer;
  _Login: String;
  _Passw: String;
  _IPSec: String;
  _FileName: String;
  _WndHandle: THandle;
  _ThreadID: THandle;
  _SynchronousSend: Boolean;
  SL: TStringList;
  PartSL: TStringList;
  Part: TIdText;
begin
  while FEmailCS <> nil do
  begin
    ES := nil;

    FEmailCS.Enter;
    try
      _ID := 0;
      _ThreadID := 0;
      _Port := 0;
      _WndHandle := 0;
      _SynchronousSend := True;

      for J := 0 to FEmails.Count - 1 do
      begin
        if (FEmails[J] as TgdEmailMessage).State = emsReady then
        begin
          ES := FEmails[J] as TgdEmailMessage;
          ES.State := emsSending;
          _ID := ES.ID;
          _Port := ES.Port;
          _Host := ES.Host;
          _Login := ES.Login;
          _Passw := ES.Passw;
          _IPSec := ES.IPSec;
          _Subject := ES.Subject;
          _Recipients := ES.Recipients;
          _SenderEmail := ES.SenderEmail;
          _BodyText := ES.BodyText;
          _FileName := ES.FileName;
          _WndHandle := ES.WndHandle;
          _ThreadID := ES.ThreadID;
          _SynchronousSend := ES.SynchronousSend;
          break;
        end;
      end;
    finally
      FEmailCS.Leave;
    end;

    if ES = nil then
      break;

    try
      IdSMTP := TidSMTP.Create(nil);
      try
        IdSMTP.Port := _Port;
        IdSMTP.Host := _Host;
        if _Login = '<empty login>' then
          IdSMTP.AuthenticationType := atNone
        else
        begin
          IdSMTP.AuthenticationType := atLogin;
          IdSMTP.Username := _Login;
          IdSMTP.Password := _Passw;
        end;

        if _IPSec > '' then
        begin
          IdSSLIOHandlerSocket := TIdSSLIOHandlerSocket.Create(IdSMTP);
          IdSSLIOHandlerSocket.SSLOptions.Method := GetIPSec(_IPSec);
          IdSMTP.IOHandler := IdSSLIOHandlerSocket;
        end;

        IdSMTP.Connect(60000);

        if IdSMTP.Connected then
        begin
          if ((IdSMTP.AuthenticationType = atLogin) and IdSMTP.Authenticate) or
          (IdSMTP.AuthenticationType = atNone) then
          begin
            Msg := TIdMessage.Create(nil);
            Attachments := nil;
            try
              Msg.Subject := EncodeSubj(ExpandMetaVariables(_Subject));
              Msg.Recipients.EMailAddresses := _Recipients;
              Msg.From.Address := _SenderEmail;
              Msg.Body.Text := _BodyText;
              Msg.Date := Now;

              if _FileName > '' then
              begin
                SL := TStringList.Create;
                try
                  SL.CommaText := _FileName;
                  for K := 0 to SL.Count - 1 do
                  begin
                    if Attachments = nil then
                      Attachments := TObjectList.Create(True);

                    if SL.Count = 1 then
                    begin
                      if AnsiSameText(ExtractFileExt(SL[K]), '.HTM') then
                      begin
                        Msg.ContentType := 'multipart/mixed';
                        PartSL := TStringList.Create;
                        try
                          PartSL.LoadFromFile(SL[K]);
                          Part := TIdText.Create(Msg.MessageParts, PartSL);
                          Part.ContentType := 'text/html';
                        finally
                          PartSL.Free;
                        end;
                      end;

                      if AnsiSameText(ExtractFileExt(SL[K]), '.TXT') then
                      begin
                        Msg.ContentType := 'multipart/mixed';
                        PartSL := TStringList.Create;
                        try
                          PartSL.LoadFromFile(SL[K]);
                          Part := TIdText.Create(Msg.MessageParts, PartSL);
                          Part.ContentType := 'text/plain';;
                        finally
                          PartSL.Free;
                        end;
                      end;
                    end;

                    Attachment := TIdAttachment.Create(Msg.MessageParts, SL[K]);
                    Attachment.DeleteTempFile := False;
                    Attachments.Add(Attachment);
                  end;
                finally
                  SL.Free;
                end;
              end;

              IdSMTP.Send(Msg);
              if gdNotifierThread <> nil then
                gdNotifierThread.Add('Сообщение отправлено: ' + ExpandMetaVariables(_Subject), 0, 2000);

              if GetEmailAndLock(_ID, ES) then
              try
                ES.State := emsSent;
              finally
                FEmailCS.Leave;
              end;
            finally
              Attachments.Free;
              Msg.Free;
            end;
          end else
          begin
            if GetEmailAndLock(_ID, ES) then
            try
              ES.State := emsError;
              ES.ErrorMsg := 'Can not authenticate';
              if gdNotifierThread <> nil then
                gdNotifierThread.Add('Ошибка аутентификации при отправке почты', 0, 2000);
            finally
              FEmailCS.Leave;
            end;
          end;
        end;
      finally
        IdSMTP.Free;
      end;
    except
      on E: Exception do
      begin
        if GetEmailAndLock(_ID, ES) then
        try
          ES.State := emsError;
          ES.ErrorMsg := E.Message;
        finally
          FEmailCS.Leave;
        end;
        if gdNotifierThread <> nil then
          gdNotifierThread.Add(E.Message, 0, 2000);
      end;
    end;

    if _ThreadID > 0 then
      PostThreadMessage(_ThreadID, WM_GD_FINISH_SEND_EMAIL, _ID, 0)
    else if _WndHandle > 0 then
      PostMessage(_WndHandle, WM_GD_FINISH_SEND_EMAIL, _ID, 0)
    else if not _SynchronousSend then
      PostMsg(WM_GD_FREE_EMAIL_MESSAGE, _ID);
  end;
end;

function TgdWebClientControl.GetSMTPSettings(const ASMTPKey: TID; out ASenderEMail: String;
  out AHost: String; out APort: Integer; out ALogin: String;
  out APassw: String; out AIPSec: String): Boolean;
var
  q: TIBSQL;
begin
  Assert(gdcBaseManager <> nil);

  if (ASMTPKey = -1) and (gd_GlobalParams.GetWebClientSMTPHost > '') then
  begin
    AHost := gd_GlobalParams.GetWebClientSMTPHost;
    APort := gd_GlobalParams.GetWebClientSMTPPort;
    ASenderEMail := gd_GlobalParams.GetWebClientSMTPEmail;
    ALogin := gd_GlobalParams.GetWebClientSMTPLogin;
    APassw := gd_GlobalParams.GetWebClientSMTPPassw;
    AIPSec := gd_GlobalParams.GetWebClientSMTPIPSec;
    Result := True;
  end else
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;

      q.SQL.Text :=
        'SELECT * FROM gd_smtp s WHERE s.id = :id';
      SetTID(q.ParamByName('id'), ASMTPKey);
      q.ExecQuery;

      if q.EOF then
      begin
        q.Close;
        q.SQL.Text :=
          'SELECT * FROM gd_smtp s WHERE s.principal = 1';
        q.ExecQuery;
      end;

      if not q.EOF then
      begin
        AHost := q.FieldByName('server').AsString;
        APort := q.FieldByName('port').AsInteger;
        ASenderEMail := q.FieldByName('email').AsString;
        ALogin := q.FieldByName('login').AsString;
        APassw := DecryptString(q.FieldByName('passw').AsString, 'PASSW');
        AIPSec := q.FieldByName('ipsec').AsString;
        Result := True;
      end else
        Result := False;
    finally
      q.Free;
    end;
  end;
end;

function TgdWebClientControl.GetEmailCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  if FEmailCS <> nil then
  begin
    FEmailCS.Enter;
    try
      if FEmails <> nil then
      begin
        for I := 0 to FEmails.Count - 1 do
          if (FEmails[I] as TgdEmailMessage).State in [emsReady, emsSending] then
            Result := Result + 1;
      end;      
    finally
      FEmailCS.Leave;
    end;
  end;
end;

function TgdWebClientControl.GetEmailState(const AnID: Word; out AState: TgdEmailMessageState;
  out AnErrorMsg: String; const AFreeEmailMessage: Boolean = True): Boolean;
var
  ES: TgdEmailMessage;
begin
  if GetEmailAndLock(AnID, ES) then
  begin
    AState := ES.State;
    AnErrorMsg := ES.ErrorMsg;
    if AFreeEmailMessage then
      PostMsg(WM_GD_FREE_EMAIL_MESSAGE, ES.ID);
    FEmailCS.Leave;
    Result := True;
  end else
    Result := False;
end;

function TgdWebClientControl.GetEmailAndLock(const AnID: Word; out AnEmailMessage: TgdEmailMessage): Boolean;
var
  J: Integer;
begin
  Result := False;

  if FEmailCS <> nil then
  begin
    FEmailCS.Enter;
    try
      if FEmails <> nil then
        for J := 0 to FEmails.Count - 1 do
          if (FEmails[J] as TgdEmailMessage).ID = AnID then
          begin
            AnEmailMessage := FEmails[J] as TgdEmailMessage;
            Result := True;
            break;
          end;
    finally
      if not Result then
        FEmailCS.Leave;
    end;
  end;
end;

procedure TgdWebClientControl.ClearEmailCallbackHandle(const AWndHandle,
  AThreadID: THandle);
var
  J: Integer;
  ES: TgdEmailMessage;
begin
  if FEmailCS <> nil then
  begin
    FEmailCS.Enter;
    try
      if FEmails <> nil then
        for J := 0 to FEmails.Count - 1 do
        begin
          ES := FEmails[J] as TgdEmailMessage;
          if ((AWndHandle <> 0) and (ES.WndHandle = AWndHandle))
            or ((AThreadID <> 0) and (ES.ThreadID = AThreadID)) then
          begin
            ES.WndHandle := 0;
            ES.ThreadID := 0;
            if ES.State <> emsReady then
              PostMsg(WM_GD_FREE_EMAIL_MESSAGE, ES.ID);
          end;
        end;
    finally
      FEmailCS.Leave;
    end;
  end;
end;

function TgdWebClientControl.SendEMail(const ASMTPKey: TID;
  const ARecipients, ASubject, ABodyText, AFileName: String;
  const AWipeFile, AWipeDirectory, Sync: Boolean; const AWndHandle,
  AThreadID: THandle): Word;
var
  LFromMail: String;
  LHost: String;
  LPort: Integer;
  LLogin: String;
  LPassw: String;
  LIPSec: String;
begin
  if not GetSMTPSettings(ASMTPKey, LFromMail, LHost,
    LPort, LLogin, LPassw, LIPSec) then
  begin
    raise Exception.Create('SMTP settings not found.');
  end;

  Result := SendEMail(LHost, LPort, LIPSec, LLogin, LPassw,
    LFromMail, ARecipients, ASubject, ABodyText,
    AFileName, AWipeFile, AWipeDirectory, Sync,
    AWndHandle, AThreadID);
end;

function TgdWebClientControl.SendEMail(const ASMTPKey: TID;
  const ARecipients, ASubject, ABodyText: String;
  const AReportKey: TID; const AnExportType: String;
  const Sync: Boolean;
  const AWndHandle, AThreadID: THandle): Word;
var
  B: Variant;
  LFileName: String;
begin
  Assert(ClientReport <> nil);

  ClientReport.ExportType := AnExportType;
  ClientReport.ShowProgress := False;

  LFileName := GetEmailTempFileName(AnExportType);
  ClientReport.FileName := LFileName;
  try
    B := VarArrayOf([]);
    ClientReport.BuildReportWithParam(AReportKey, B);
  except
    on E: Exception do
    begin
      DeleteFile(LFileName);
      RemoveDir(ExtractFileDir(LFileName));
      raise;
    end;
  end;

  Result := SendEMail(ASMTPKey, ARecipients, ASubject, ABodyText,
    LFileName, True, True, Sync,
    AWndHandle, AThreadID);
end;

{ TgdEmailMessage }

constructor TgdEmailMessage.Create;
begin
  inherited;
  FState := emsReady;
end;

destructor TgdEmailMessage.Destroy;
var
  K: Integer;
  SL: TStringList;
  SameDir: Boolean;
begin
  if WipeFile then
  begin
    SameDir := True;
    SL := TStringList.Create;
    try
      SL.CommaText := FileName;

      for K := 0 to SL.Count - 1 do
      begin
        DeleteFile(SL[K]);
        if SameDir and (K > 0) then
          SameDir := AnsiSameText(ExtractFileDir(SL[K]), ExtractFileDir(SL[K-1]));
      end;

      if WipeDirectory and SameDir then
        RemoveDir(ExtractFileDir(SL[0]));
    finally
      SL.Free;
    end;
  end;

  inherited;
end;

initialization
  gdWebClientControl := TgdWebClientControl.Create;
  gdWebClientControl.Resume;

finalization
  FreeAndNil(gdWebClientControl);
end.