
unit gd_WebClientControl_unit;

interface

uses
  Classes, Windows, Messages, SyncObjs, idHTTP, gdMessagedThread,
  gd_FileList_unit;

type
  TgdWebClientThread = class(TgdMessagedThread)
  private
    FCS: TCriticalSection;
    FgdWebServerURL: String;
    FServerFileList: TFLCollection;
    FConnected: Boolean;
    FHTTP: TidHTTP;
    FCmdList: TStringList;

    function QueryWebServer: Boolean;
    function LoadWebServerURL: Boolean;
    function UpdateFiles: Boolean;
    function ProcessUpdateCommand: Boolean;
    procedure FinishUpdate;

    function GetgdWebServerURL: String;
    procedure SetgdWebServerURL(const Value: String);

  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;
    procedure LogError; override;
    procedure Setup; override;
    procedure TearDown; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConnection;

    property gdWebServerURL: String read GetgdWebServerURL write SetgdWebServerURL;
  end;

var
  gdWebClientThread: TgdWebClientThread;

implementation

uses
  SysUtils, ComObj, ActiveX, gdcJournal, gd_security, JclSimpleXML,
  gdNotifierThread_unit, gd_directories_const, JclFileUtils, idURI,
  Forms;

const
  WM_GD_AFTER_CONNECTION       = WM_USER + 1118;
  WM_GD_QUERY_SERVER           = WM_USER + 1119;
  WM_GD_GET_FILES_LIST         = WM_USER + 1120;
  WM_GD_UPDATE_FILES           = WM_USER + 1121;
  WM_GD_PROCESS_UPDATE_COMMAND = WM_USER + 1122;
  WM_GD_FINISH_UPDATE          = WM_USER + 1123;

{ TgdWebClientThread }

constructor TgdWebClientThread.Create;
begin
  inherited Create(True);
  FreeOnTerminate := False;
  Priority := tpLowest;
  FCS := TCriticalSection.Create;
  FHTTP := TidHTTP.Create(nil);
  FHTTP.HandleRedirects := True;
  FHTTP.ReadTimeout := 88000;
  FHTTP.ConnectTimeout := 44000;
end;

procedure TgdWebClientThread.AfterConnection;
begin
  PostMsg(WM_GD_AFTER_CONNECTION);
end;

function TgdWebClientThread.QueryWebServer: Boolean;
var
  ResponseData: TStringStream;
begin
  Result := False;
  if IBLogin = nil then
    FErrorMessage := 'IBLogin is not assigned.'
  else if gdWebServerURL = '' then
    FErrorMessage := 'gdWebServerURL is not assigned.'
  else begin
    ResponseData := TStringStream.Create('');
    try
      FHTTP.Get(TidURI.URLEncode(gdWebServerURL + '/query?' +
        'dbid=' + IntToStr(IBLogin.DBID) +
        '&cust_name=' + IBLogin.CompanyName), ResponseData);
      if FServerFileList = nil then
        FServerFileList := TFLCollection.Create;
      FServerFileList.ParseXML(ResponseData.DataString);
      Result := True;
    finally
      ResponseData.Free;
    end;
  end;
end;

function TgdWebClientThread.LoadWebServerURL: Boolean;
begin
  gdWebServerURL := '';
  gdWebServerURL := FHTTP.Get(Gedemin_NameServerURL);
  //!!!
  //gdWebServerURL := 'http://192.168.0.35';
  gdWebServerURL := 'http://127.0.0.1';
  //!!!
  Result := gdWebServerURL > '';
end;

function TgdWebClientThread.UpdateFiles: Boolean;
begin
  Result := FServerFileList <> nil;
  if not Result then
    FErrorMessage := 'FServerFileList is not assigned.'
  else begin
    if FCmdList = nil then
      FCmdList := TStringList.Create
    else
      FCmdList.Clear;  
  end;
end;

function TgdWebClientThread.ProcessMessage(var Msg: TMsg): Boolean;
begin
  Result := True;
  case Msg.Message of
    WM_GD_AFTER_CONNECTION:
      if (not FConnected) and LoadWebServerURL then
      begin
        PostThreadMessage(ThreadID, WM_GD_QUERY_SERVER, 0, 0);
        gdNotifierThread.Add('Подключение к серверу ' + Gedemin_NameServerURL, 0, 2000);
        FConnected := True;
      end;

    WM_GD_QUERY_SERVER:
      if QueryWebServer then
      begin
        PostThreadMessage(ThreadID, WM_GD_UPDATE_FILES, 0, 0);
        gdNotifierThread.Add('Подключение к серверу ' + gdWebServerURL, 0, 2000);
      end;

    WM_GD_UPDATE_FILES:
      if UpdateFiles then
        PostThreadMessage(ThreadID, WM_GD_PROCESS_UPDATE_COMMAND, 0, 0);

    WM_GD_PROCESS_UPDATE_COMMAND:
      if ProcessUpdateCommand then
        PostThreadMessage(ThreadID, WM_GD_PROCESS_UPDATE_COMMAND, 0, 0)
      else
        PostThreadMessage(ThreadID, WM_GD_FINISH_UPDATE, 0, 0);

    WM_GD_FINISH_UPDATE:
      FinishUpdate;        
  else
    Result := False;
  end;
end;

procedure TgdWebClientThread.LogError;
begin
  if FErrorMessage > '' then
  begin
    TgdcJournal.AddEvent(FErrorMessage, 'HTTPClient', -1, nil, True);
    FErrorMessage := '';
  end;
end;

procedure TgdWebClientThread.Setup;
begin
  inherited;
  Assert(CoInitialize(nil) = S_OK);
end;

procedure TgdWebClientThread.TearDown;
begin
  CoUninitialize;
  inherited;
end;

destructor TgdWebClientThread.Destroy;
begin
  inherited;
  FCS.Free;
  FServerFileList.Free;
  FHTTP.Free;
  FCmdList.Free;
end;

function TgdWebClientThread.GetgdWebServerURL: String;
begin
  FCS.Enter;
  Result := FgdWebServerURL;
  FCS.Leave;
end;

procedure TgdWebClientThread.SetgdWebServerURL(const Value: String);
begin
  FCS.Enter;
  FgdWebServerURL := Value;
  FCS.Leave;
end;

function TgdWebClientThread.ProcessUpdateCommand: Boolean;
begin
  Result := FServerFileList.UpdateFile(FHTTP, FgdWebServerURL, FCmdList);
end;

procedure TgdWebClientThread.FinishUpdate;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  FPath, FName: String;
begin
  if Assigned(FCmdList) then
  try
    if FCmdList.Count > 0 then
    begin
      FPath := ExtractFilePath(Application.ExeName);
      FCmdList.SaveToFile(FPath + Gedemin_Updater_Ini);
      FName := FPath + Gedemin_Updater;
      FillChar(StartupInfo, SizeOf(TStartupInfo), #0);
      StartupInfo.cb := SizeOf(TStartupInfo);
      if not CreateProcess(PChar(FName), nil, nil, nil, False,
        NORMAL_PRIORITY_CLASS or CREATE_NO_WINDOW, nil, nil,
        StartupInfo, ProcessInfo) then
      begin
        FErrorMessage := 'Can not start ' + Gedemin_Updater + '. ' +
          SysErrorMessage(GetLastError);
      end;
    end;
  finally
    FreeAndNil(FCmdList);
  end;
end;

initialization
  gdWebClientThread := TgdWebClientThread.Create;
  gdWebClientThread.Resume;

finalization
  FreeAndNil(gdWebClientThread);
end.