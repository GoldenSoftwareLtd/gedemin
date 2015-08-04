
unit gd_WebClientControl_unit;

interface

uses
  Classes, Windows, Messages, SyncObjs, SysUtils, idHTTP, idURI, idComponent,
  idThreadSafe, gdMessagedThread, gd_FileList_unit, gd_ProgressNotifier_unit,
  IdSSLOpenSSL, Contnrs, gd_messages_const;

type
  TgdEmailMessage = class(TObject)
  private
    FRecipients: String;
    FSubject: String;
    FBodyText: String;
    FFromEMail: String;
    FServer: String;
    FPort: Integer;
    FLogin: String;
    FPassw: String;
    FIPSec: String;
    FTimeOut: Integer;
    FFileName: String;
    FWipeFile: Boolean;
    FWipeDirectory: Boolean;
    FHandle: THandle;
    FThreadID: THandle;
    FAutoTaskKey: Integer;
    FErrorMsg: String;

    procedure ResponseMsg;

  public
    destructor Destroy; override;

    property Recipients: String read FRecipients write FRecipients;
    property Subject: String read FSubject write FSubject;
    property BodyText: String read FBodyText write FBodyText;
    property FromEMail: String read FFromEMail write FFromEMail;
    property Server: String read FServer write FServer;
    property Port: Integer read FPort write FPort;
    property Login: String read FLogin write FLogin;
    property Passw: String read FPassw write FPassw;
    property IPSec: String read FIPSec write FIPSec;
    property TimeOut: Integer read FTimeOut write FTimeOut;
    property FileName: String read FFileName write FFileName;
    property WipeFile: Boolean read FWipeFile write FWipeFile;
    property WipeDirectory: Boolean read FWipeDirectory write FWipeDirectory;
    property Handle: THandle read FHandle write FHandle;
    property ThreadID: THandle read FThreadID write FThreadID;
    property AutoTaskKey: Integer read FAutoTaskKey write FAutoTaskKey;
    property ErrorMsg: String read FErrorMsg write FErrorMsg;
  end;

  TgdWebClientThread = class(TgdMessagedThread)
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

    function GetRecipients(AGroupKey: Integer; ARecipients: String): String;
    function GetSMTPSettings(ASMTPKey: Integer; out AFromMail: String;
      out AServer: String; out APort: Integer; out ALogin: String;
      out APassw: String; out AIPSec: String; out ATimeOut: Integer): Boolean;
    function GetEmailCount: Integer;

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

    procedure SendNameSpaceLog(ARecipients: String;
      ASubject: String; ABodyText: String; AFileName: String);

    procedure SendEMail(const ARecipients: String; const ASubject: String;
      const ABodyText: String; const AFromEMail: String; const AServer: String;
      const APort: Integer; const ALogin: String; const APassw: String; const AnIPSec: String;
      const ATimeOut: Integer; const AFileName: String = ''; const AWipeFile: Boolean = False;
      const AWipeDirectory: Boolean = False; const AHandle: THandle = 0; const AThreadID: THandle = 0;
      const AnAutoTaskKey: Integer = 0);

    procedure SendReport(ARecipients: String; ASubject: String;
      ABodyText: String; ASMTPKey: Integer; AFileName: String; AHandle: THandle);

    procedure BuildAndSendReport(AReportKey: Integer; AnExportType: String;
      ARecipients: String; AGroupKey: Integer; ASMTPKey: Integer;
      AHandle: THandle; AThreadID: THandle; AnAutoTaskKey: Integer);

    procedure WaitingSendingEmail;

    property gdWebServerURL: String read GetgdWebServerURL write SetgdWebServerURL;
    property WebServerResponse: String read GetWebServerResponse;
    property Connected: Boolean read GetConnected;
    property InUpdate: Boolean read GetInUpdate;
    property EmailCount: Integer read GetEmailCount;
  end;

  EgdWebClientThread = class(Exception);

var
  gdWebClientThread: TgdWebClientThread;
  function GetIPSec(AnIPSec: String): TIdSSLVersion;
  function GetTempDirectory: String;
  function GetTempFileName(const AnExportType: String): String;

implementation

uses
  gdcJournal, gd_security, gdcBaseInterface, gdNotifierThread_unit,
  gd_directories_const, JclFileUtils, Forms, gd_CmdLineParams_unit,
  gd_GlobalParams_unit, jclSysInfo, IdSMTP, IdMessage, IBSQL,
  gd_encryption, rp_i_ReportBuilder_unit, rp_ReportClient, IdCoderMIME, IBDatabase;

const
  WM_GD_AFTER_CONNECTION       = WM_USER + 1118;
  WM_GD_QUERY_SERVER           = WM_USER + 1119;
  WM_GD_GET_FILES_LIST         = WM_USER + 1120;
  WM_GD_UPDATE_FILES           = WM_USER + 1121;
  WM_GD_PROCESS_UPDATE_COMMAND = WM_USER + 1122;
  WM_GD_FINISH_UPDATE          = WM_USER + 1123;
  WM_GD_SEND_ERROR             = WM_USER + 1124;
  WM_GD_SEND_EMAIL             = WM_USER + 1125;

type
  TClientReportCracker = class(TClientReport);

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

function GetTempDirectory: String;
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
    
  Result := Result + '\';
end;

function GetTempFileName(const AnExportType: String): String;
begin
  Result := GetTempDirectory + 'report' + '.' + AnExportType;
end;

{ TgdWebClientThread }

constructor TgdWebClientThread.Create;
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

procedure TgdWebClientThread.AfterConnection;
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

function TgdWebClientThread.QueryWebServer: Boolean;
begin
  Result := False;
  if gdWebServerURL = '' then
    ErrorMessage := 'gdWebServerURL is not assigned.'
  else if InUpdate then
    ErrorMessage := 'Update process is running.'
  else begin
    FURI.URI := gdWebServerURL;
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
      gdNotifierThread.Add('Подключение прошло успешно.', 0, 2000);
      Result := True;
    except
      on E: Exception do
      begin
        ErrorMessage := E.Message;
        gdNotifierThread.Add(ErrorMessage, 0, 2000);
      end;
    end;
  end;
end;

function TgdWebClientThread.LoadWebServerURL: Boolean;
begin
  if gdWebServerURL = '' then
  begin
    FURI.URI := Gedemin_NameServerURL;
    gdNotifierThread.Add('Опрос сервера: ' + FURI.Host + '...', 0, 2000);
    gdWebServerURL := FHTTP.Get(Gedemin_NameServerURL);
  end;

  if gdWebServerURL > '' then
  begin
    gdNotifierThread.Add('Определен адрес удаленного сервера: ' + gdWebServerURL, 0, 2000);
    Result := True;
  end else
  begin
    gdNotifierThread.Add('Адрес удаленного сервера не определен.', 0, 2000);
    Result := False;
  end;
end;

function TgdWebClientThread.LoadFilesList: Boolean;
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
      gdNotifierThread.Add('Загружен список файлов...', 0, 2000);
    except
      on E: Exception do
      begin
        ErrorMessage := E.Message;
        gdNotifierThread.Add(ErrorMessage, 0, 2000);
      end;
    end;
  finally
    ResponseData.Free;
  end;
end;

function TgdWebClientThread.ProcessMessage(var Msg: TMsg): Boolean;
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
  else
    Result := False;
  end;
end;

procedure TgdWebClientThread.LogErrorSync;
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

destructor TgdWebClientThread.Destroy;
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

function TgdWebClientThread.GetgdWebServerURL: String;
begin
  Result := FgdWebServerURL.Value;
end;

procedure TgdWebClientThread.SetgdWebServerURL(const Value: String);
begin
  FgdWebServerURL.Value := Value;
end;

function TgdWebClientThread.ProcessUpdateCommand: Boolean;
begin
  Result := FServerFileList.UpdateFile(FHTTP, gdWebServerURL,
    FCmdList, FMandatoryUpdate);
end;

procedure TgdWebClientThread.FinishUpdate;
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

procedure TgdWebClientThread.StartUpdateFiles;
begin
  if gd_GlobalParams.CanUpdate and (FConnected.Value <> 0) then
  begin
    FMandatoryUpdate := True;
    PostMsg(WM_GD_UPDATE_FILES);
  end;
end;

procedure TgdWebClientThread.DoOnWork(Sender: TObject;
  AWorkMode: TWorkMode; const AWorkCount: Integer);
begin
  if Terminated then
    Abort;
end;

function TgdWebClientThread.GetConnected: Boolean;
begin
  Result := FConnected.Value <> 0;
end;

function TgdWebClientThread.GetInUpdate: Boolean;
begin
  Result := FInUpdate.Value <> 0;
end;

function TgdWebClientThread.GetWebServerResponse: String;
begin
  Result := FWebServerResponse.Value;
end;

procedure TgdWebClientThread.SyncFinishUpdate;
begin
  gd_GlobalParams.NeedRestartForUpdate := True;
  if not FQuietMode then
  begin
    MessageBox(0,
      PChar(
        'Для завершения процесса обновления необходимо'#13#10 +
        'перезапустить приложение.'#13#10#13#10 +
        'Прежние версии файлов сохранены с расширением .BAK'),
      'Обновление файлов',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
  end;
end;

function TgdWebClientThread.ProcessError(var AMsg: TMsg;
  var AnErrorMessage: String): Boolean;
begin
  if InUpdate and (AMsg.Message = WM_GD_PROCESS_UPDATE_COMMAND) then
    PostThreadMessage(ThreadID, WM_GD_FINISH_UPDATE, 0, 0);
  Result := True;  
end;

function TgdWebClientThread.URIEncodeParam(const AParam: String): String;
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

procedure TgdWebClientThread.SendError(const AnErrorMessage: String;
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

procedure TgdWebClientThread.SendNameSpaceLog(ARecipients: String;
  ASubject: String; ABodyText: String; AFileName: String);
begin
  SendEMail(ARecipients, ASubject, ABodyText,
    gd_GlobalParams.GetWebClientSMTPEmail,
    gd_GlobalParams.GetWebClientSMTPServer,
    gd_GlobalParams.GetWebClientSMTPPort,
    gd_GlobalParams.GetWebClientSMTPLogin,
    gd_GlobalParams.GetWebClientSMTPPassw,
    gd_GlobalParams.GetWebClientSMTPIPSec,
    gd_GlobalParams.GetWebClientSMTPTimeout,
    AFileName,
    True, True);
end;

procedure TgdWebClientThread.SendEMail(const ARecipients: String; const ASubject: String;
  const ABodyText: String; const AFromEMail: String; const AServer: String; const APort: Integer;
  const ALogin: String; const APassw: String; const AnIPSec: String; const ATimeOut: Integer;
  const AFileName: String = ''; const AWipeFile: Boolean = False; const AWipeDirectory: Boolean = False;
  const AHandle: THandle = 0; const AThreadID: THandle = 0; const AnAutoTaskKey: Integer = 0);
var
  ES: TgdEmailMessage;
begin
  if (ARecipients = '') or (AFromEMail = '') or (AServer = '') or (APort < 0)
    or (APort > 65535) or (ALogin = '') or (ATimeOut < -1) then
    raise Exception.Create('Неверные параметры электронной почты.');

  ES := TgdEmailMessage.Create;
  ES.Recipients := ARecipients;
  ES.Subject := ASubject;
  ES.BodyText := ABodyText;
  ES.FromEMail := AFromEMail;
  ES.Server := AServer;
  ES.Port := APort;
  ES.Login := ALogin;
  ES.Passw := APassw;
  ES.IPSec := AnIPSec;
  ES.TimeOut := ATimeOut;
  ES.FileName := AFileName;
  ES.WipeFile := AWipeFile;
  ES.WipeDirectory := AWipeDirectory;
  ES.Handle := AHandle;
  ES.ThreadID := AThreadID;
  ES.AutoTaskKey := AnAutoTaskKey;

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

  PostMsg(WM_GD_SEND_EMAIL);
end;

procedure TgdWebClientThread.SendReport(ARecipients: String; ASubject: String;
  ABodyText: String; ASMTPKey: Integer; AFileName: String; AHandle: THandle);
var
  LFromMail: String;
  LServer: String;
  LPort: Integer;
  LLogin: String;
  LPassw: String;
  LIPSec: String;
  LTimeOut: Integer;
begin
  if not GetSMTPSettings(ASMTPKey, LFromMail, LServer,
    LPort, LLogin, LPassw, LIPSec, LTimeOut) then
  begin
    raise Exception.Create('not found smtp settings.');
  end;

  if ARecipients = '' then
    raise Exception.Create('not found recipients email addresses.');

  SendEMail(ARecipients, ASubject, ABodyText,
    LFromMail, LServer, LPort, LLogin, LPassw, LIPSec, LTimeOut,
    AFileName, True, True,
    AHandle);
end;

procedure TgdWebClientThread.BuildAndSendReport(AReportKey: Integer; AnExportType: String;
  ARecipients: String; AGroupKey: Integer; ASMTPKey: Integer;
  AHandle: THandle; AThreadID: THandle; AnAutoTaskKey: Integer);

  function GetExportType(AnExportType: String): TExportType;
  begin
    if AnExportType = 'DOC' then
      Result := etWord
    else if AnExportType = 'XLS' then
      Result := etExcel
    else if AnExportType = 'PDF' then
      Result := etPdf
    else if AnExportType = 'XML' then
      Result := etXML
    else
      raise Exception.Create('unknown export type.')
  end;

  function GetSubject(AReportKey: Integer): String;
  begin
    Result := 'Заголовок';
  end;

  function GetBodyText(AReportKey: Integer): String;
  begin
    Result := 'Текст'
  end;

var
  B: Variant;
  LRecipients: String;
  LSubject: String;
  LBodyText: String;
  LFromMail: String;
  LServer: String;
  LPort: Integer;
  LLogin: String;
  LPassw: String;
  LIPSec: String;
  LTimeOut: Integer;
  LFileName: String;
begin
  Assert(ClientReport <> nil);

  if not GetSMTPSettings(ASMTPKey, LFromMail, LServer,
    LPort, LLogin, LPassw, LIPSec, LTimeOut) then
  begin
    raise Exception.Create('not found smtp settings.');
  end;

  LRecipients := GetRecipients(AGroupKey, ARecipients);

  if LRecipients = '' then
    raise Exception.Create('not found recipients email addresses.');

  ClientReport.ExportType := GetExportType(AnExportType);
  ClientReport.ShowProgress := False;


  LFileName := GetTempFileName(AnExportType);
  ClientReport.FileName := LFileName;
  try
    B := VarArrayOf([]);
    TClientReportCracker(ClientReport).BuildReportWithParam(AReportKey, B);

    LSubject := GetSubject(AReportKey);
    LBodyText := GetBodyText(AReportKey);

    SendEMail(LRecipients, LSubject, LBodyText,
      LFromMail, LServer, LPort, LLogin, LPassw, LIPSec, LTimeOut,
      LFileName, True, True,
      AHandle, AThreadID, AnAutoTaskKey);
  except
    on E: Exception do
    begin
      DeleteFile(LFileName);
      RemoveDir(ExtractFileDir(LFileName));
      raise;
    end;
  end;
end;

procedure TgdWebClientThread.WaitingSendingEmail;
begin
  while EmailCount > 0 do
    Sleep(1000);
end;

procedure TgdWebClientThread.DoSendError;
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
      gdNotifierThread.Add('Отослано сообщение об ошибке:', 0, 2000);
      gdNotifierThread.Add(FErrorToSend.Value, 0, 2000);
    except
      on E: Exception do
      begin
        ErrorMessage := E.Message;
        gdNotifierThread.Add(ErrorMessage, 0, 2000);
      end;
    end;
  end;
end;

procedure TgdWebClientThread.DoSendEMail;

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
  ES: TgdEmailMessage;
begin
  ES := nil;

  while EmailCount > 0 do
  begin
    FEmailCS.Enter;
    try
      if FEmails.Count = 0 then
        break;
      ES := FEmails[0] as TgdEmailMessage;
    finally
      FEmailCS.Leave;
    end;

    try
      try
        IdSMTP := TidSMTP.Create(nil);
        try
          IdSMTP.Port := ES.Port;
          IdSMTP.Host := ES.Server;
          IdSMTP.AuthenticationType := atLogin;
          IdSMTP.Username := ES.Login;
          IdSMTP.Password := ES.Passw;

          if ES.IPSec > '' then
          begin
            IdSSLIOHandlerSocket := TIdSSLIOHandlerSocket.Create(IdSMTP);
            IdSSLIOHandlerSocket.SSLOptions.Method := GetIPSec(ES.IPSec);
            IdSMTP.IOHandler := IdSSLIOHandlerSocket;
          end;

          IdSMTP.Connect(ES.TimeOut);

          if IdSMTP.Connected then
          begin
            if IdSMTP.Authenticate then
            begin
              Msg := TIdMessage.Create(nil);
              Attachment := nil;
              try
                Msg.Subject := EncodeSubj(ES.Subject);
                Msg.Recipients.EMailAddresses := ES.Recipients;
                Msg.From.Address := ES.FromEMail;
                Msg.Body.Text := ES.BodyText;
                Msg.Date := Now;

                if ES.FileName <> '' then
                begin
                  Attachment := TIdAttachment.Create(Msg.MessageParts, ES.FileName);
                  Attachment.DeleteTempFile := False;
                end;

                IdSMTP.Send(Msg);
                gdNotifierThread.Add('Сообщение отправлено', 0, 2000);
              finally
                Attachment.Free;
                Msg.Free;
              end;
            end;
          end;
        finally
          IdSMTP.Free;
        end;
      except
        on E: Exception do
        begin
          ErrorMessage := E.Message;
          ES.ErrorMsg := ErrorMessage;
          gdNotifierThread.Add(ErrorMessage, 0, 2000);
        end;
      end;
    finally
      FEmailCS.Enter;
      try
        FEmails.Remove(ES);
      finally
        FEmailCS.Leave;
      end;
    end;
  end;
end;

function TgdWebClientThread.GetRecipients(AGroupKey: Integer; ARecipients: String): String;
var
  q: TIBSQL;
begin
  Assert(gdcBaseManager <> nil);

  Result := '';
  Result := Result + ARecipients;

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT '#13#10 +
      '  c.email '#13#10 +
      'FROM '#13#10 +
      '  gd_contact c '#13#10 +
      '    JOIN '#13#10 +
      '      gd_contactlist g '#13#10 +
      '    ON '#13#10 +
      '      g.contactkey  =  c.id '#13#10 +
      'WHERE '#13#10 +
      '  (g.groupkey  =  :gk) '#13#10 +
      '    AND (c.email IS NOT NULL) '#13#10 +
      '    AND (c.email <> '''')';
    q.ParamByName('gk').AsInteger := AGroupKey;

    q.ExecQuery;

    while not q.EOF do
    begin
      if q.FieldByName('email').AsString > '' then
      begin
        if Result <> '' then
          Result := Result + ',';
        Result := Result + q.FieldByName('email').AsString;
      end;
      q.Next;
    end;
  finally
    q.Free;
  end;
end;

function TgdWebClientThread.GetSMTPSettings(ASMTPKey: Integer; out AFromMail: String;
  out AServer: String; out APort: Integer; out ALogin: String;
  out APassw: String; out AIPSec: String; out ATimeOut: Integer): Boolean;
var
  q: TIBSQL;
begin
  Result := False;

  Assert(gdcBaseManager <> nil);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;

    if ASMTPKey > 0 then
    begin
      q.SQL.Text :=
        'SELECT * FROM gd_smtp s WHERE s.id = :id';
      q.ParamByName('id').AsInteger := ASMTPKey;
    end
    else
      q.SQL.Text :=
        'SELECT * FROM gd_smtp s WHERE s.principal = 1';

    q.ExecQuery;

    if not q.EOF then
    begin
      Result := True;
      AFromMail := q.FieldByName('email').AsString;
      AServer := q.FieldByName('server').AsString;
      APort := q.FieldByName('port').AsInteger;
      ALogin := q.FieldByName('login').AsString;
      APassw := DecryptString(q.FieldByName('passw').AsString, 'PASSW');
      AIPSec := q.FieldByName('ipsec').AsString;
      ATimeOut := q.FieldByName('timeout').AsInteger;
    end;
  finally
    q.Free;
  end;
end;

function TgdWebClientThread.GetEmailCount: Integer;
begin
  if (FEmailCS = nil) or (FEmails = nil) then
    Result := 0
  else begin
    FEmailCS.Enter;
    try
      Result := FEmails.Count;
    finally
      FEmailCS.Leave;
    end;
  end;
end;

{ TgdEmailMessage }

destructor TgdEmailMessage.Destroy;
begin
  ResponseMsg;

  if WipeFile and DeleteFile(FileName) and WipeDirectory then
    RemoveDir(ExtractFileDir(FileName));
  inherited;
end;

procedure TgdEmailMessage.ResponseMsg;
var
  Msg: String;
  LP: Integer;
begin
  if ErrorMsg > '' then
  begin
    Msg := ErrorMsg;
    LP := 0
  end
  else
  begin
    Msg := 'Done';
    LP := 1
  end;

  if AutoTaskKey > 0 then
    PostThreadMessage(ThreadID,
      WM_GD_FINISH_SEND_EMAIL,
      AutoTaskKey,
      Integer(Pointer(PChar(Msg)))
      )
  else if Handle > 0 then
    PostMessage(Handle,
      WM_GD_FINISH_SEND_EMAIL,
      LP,
      Integer(Pointer(PChar(Msg)))
      );
end;

initialization
  gdWebClientThread := TgdWebClientThread.Create;
  gdWebClientThread.Resume;

finalization
  FreeAndNil(gdWebClientThread);
end.