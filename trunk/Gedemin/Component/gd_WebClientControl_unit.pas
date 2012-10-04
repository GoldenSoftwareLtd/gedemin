
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

    function QueryWebServer: Boolean;
    function LoadWebServerURL: Boolean;
    function CreateHTTP: TidHTTP;
    procedure UpdateFiles;
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
  gdNotifierThread_unit, gd_directories_const;

const
  WM_GD_AFTER_CONNECTION = WM_USER + 1118;
  WM_GD_QUERY_SERVER =     WM_USER + 1119;
  WM_GD_UPDATE_FILES =     WM_USER + 1120;

  NameServerURL = 'http://gsbelarus.com/gs/gedemin/gdwebserver.xml';
  
{ TgdWebClientThread }

constructor TgdWebClientThread.Create;
begin
  inherited Create(True);
  FreeOnTerminate := False;
  Priority := tpLowest;
  FCS := TCriticalSection.Create;
end;

procedure TgdWebClientThread.AfterConnection;
begin
  PostMsg(WM_GD_AFTER_CONNECTION);
end;

function TgdWebClientThread.QueryWebServer: Boolean;
var
  HTTP: TidHTTP;
  XML: TStringStream;
  ResponseData: TStringStream;
begin
  Assert(Assigned(IBLogin));

  Result := False;

  if gdWebServerURL > '' then
  begin
    HTTP := CreateHTTP;
    XML := TStringStream.Create('');
    ResponseData := TStringStream.Create('');
    try
      XML.WriteString(
        '<?xml version="1.0" encoding="Windows-1251"?>'#13#10 +
        '<QUERY version="1.0">'#13#10 +
        '  <DBID>' + IntToStr(IBLogin.DBID) + '</DBID>'#13#10 +
        '  <CUSTOMERNAME>' + EntityEncode(IBLogin.CompanyName) + '</CUSTOMERNAME>'#13#10 +
        '</QUERY>');

      try
        HTTP.Post(gdWebServerURL + '/query', XML, ResponseData);

        if FServerFileList = nil then
          FServerFileList := TFLCollection.Create;
        FServerFileList.ParseXML(ResponseData.DataString);
        Result := True;
      except
        on E: Exception do
          FErrorMessage := E.Message + ' URL: ' + gdWebServerURL;
      end;
    finally
      ResponseData.Free;
      XML.Free;
      HTTP.Free;
    end;
  end;
end;

function TgdWebClientThread.CreateHTTP: TidHTTP;
begin
  Result := TidHTTP.Create(nil);
  Result.HandleRedirects := True;
  Result.ReadTimeout := 4000;
  Result.ConnectTimeout := 2000;
end;

function TgdWebClientThread.LoadWebServerURL: Boolean;
var
  LocalDoc: OleVariant;
  Sel: OleVariant;
  FHTTP: TidHTTP;
begin
  Result := False;

  gdWebServerURL := '';
  FHTTP := CreateHTTP;
  try
    try
      LocalDoc := CreateOleObject(ProgID_MSXML_DOMDocument);
      LocalDoc.Async := False;
      LocalDoc.SetProperty('SelectionLanguage', 'XPath');

      if LocalDoc.LoadXML(FHTTP.Get(NameServerURL)) then
      begin
        Sel := LocalDoc.SelectSingleNode('/GDWEBSERVER/URL');
        if not VarIsEmpty(Sel) then
        begin
          gdWebServerURL := Sel.NodeTypedValue;
          //gdWebServerURL := 'http://192.168.0.45';
          //gdWebServerURL := 'http://192.168.0.58';
          Result := gdWebServerURL > '';
        end;
      end;
    except
      on E: Exception do
        FErrorMessage := E.Message + ' URL: ' + NameServerURL;
    end;
  finally
    FHTTP.Free;
  end;
end;

procedure TgdWebClientThread.UpdateFiles;
var
  FLCommands: TFLCommands;
begin
  Assert(FServerFileList <> nil);

  FLCommands := TFLCommands.Create;
  try
    FServerFileList.UpdateFiles(FLCommands);
  finally
    FLCommands.Free;
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
        gdNotifierThread.Add('Подключение к серверу ' + NameServerURL, 0, 2000);
        FConnected := True;
      end;

    WM_GD_QUERY_SERVER:
      if QueryWebServer then
      begin
        PostThreadMessage(ThreadID, WM_GD_UPDATE_FILES, 0, 0);
        gdNotifierThread.Add('Подключение к серверу ' + gdWebServerURL, 0, 2000);
      end;

    WM_GD_UPDATE_FILES:
      UpdateFiles;
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
  CoInitialize(nil);
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

initialization
  gdWebClientThread := TgdWebClientThread.Create;
  gdWebClientThread.Resume;

finalization
  FreeAndNil(gdWebClientThread);
end.