
unit gd_WebClientControl_unit;

interface

uses
  Classes, Windows, Messages, idHTTP, gdMessagedThread;

type
  TgdWebClientThread = class(TgdMessagedThread)
  private
    FgdWebServerURL: String;
    FServerResponse: String;

    function QueryWebServer: Boolean;
    function LoadWebServerURL: Boolean;
    function CreateHTTP: TidHTTP;
    procedure UpdateFiles;

  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;
    procedure LogError; override;
    procedure Setup; override;
    procedure TearDown; override;

  public
    constructor Create;

    procedure AfterConnection;

    property gdWebServerURL: String read FgdWebServerURL;
    property ServerResponse: String read FServerResponse;
  end;

var
  gdWebClientThread: TgdWebClientThread;

implementation

uses
  SysUtils, ComObj, ActiveX, gdcJournal, gd_FileList_unit,
  gd_security, JclSimpleXML, gdNotifierThread_unit;

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
end;

procedure TgdWebClientThread.AfterConnection;
begin
  PostMsg(WM_GD_AFTER_CONNECTION);
end;

function TgdWebClientThread.QueryWebServer: Boolean;
var
  HTTP: TidHTTP;
  XML: TStringStream;
  ResponseData: TMemoryStream;
begin
  Assert(Assigned(IBLogin));

  Result := False;

  if FgdWebServerURL > '' then
  begin
    HTTP := CreateHTTP;
    XML := TStringStream.Create('');
    ResponseData := TMemoryStream.Create;
    try
      XML.WriteString(
        '<?xml version="1.0" encoding="Windows-1251"?>'#13#10 +
        '<QUERY>'#13#10 +
        '  <VERSION_1>'#13#10 +
        '    <DBID>' + IntToStr(IBLogin.DBID) + '</DBID>'#13#10 +
        '    <CUSTOMERNAME>' + EntityEncode(IBLogin.CompanyName) + '</CUSTOMERNAME>'#13#10 +
        '  </VERSION_1>'#13#10 +
        '</QUERY>');

      try
        HTTP.Post(FgdWebServerURL + '/query', XML, ResponseData);
        FServerResponse := IntToStr(ResponseData.Size);
        Result := FServerResponse > '';
      except
        on E: Exception do
          FErrorMessage := E.Message + ' URL: ' + FgdWebServerURL;
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
  FgdWebServerURL := '';
  FHTTP := CreateHTTP;
  try
    try
      LocalDoc := CreateOleObject('MSXML.DOMDocument');
      LocalDoc.Async := False;
      LocalDoc.SetProperty('SelectionLanguage', 'XPath');

      if LocalDoc.LoadXML(FHTTP.Get(NameServerURL)) then
      begin
        Sel := LocalDoc.SelectSingleNode('/GDWEBSERVER/VERSION_1/URL');
        if not VarIsEmpty(Sel) then
        begin
          FgdWebServerURL := Sel.NodeTypedValue;
          //FgdWebServerURL := 'http://192.168.0.45';
          //FgdWebServerURL := 'http://192.168.0.58';
          Result := FgdWebServerURL > '';
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
  LocalFiles: TgdFSOCollection;
begin
  LocalFiles := TgdFSOCollection.Create;
  try
    LocalFiles.Build;
  finally
    LocalFiles.Free;
  end;
end;

function TgdWebClientThread.ProcessMessage(var Msg: TMsg): Boolean;
begin
  Result := True;
  case Msg.Message of
    WM_GD_AFTER_CONNECTION:
      if LoadWebServerURL then
      begin
        PostThreadMessage(ThreadID, WM_GD_QUERY_SERVER, 0, 0);
        gdNotifierThread.Add('Подключение к серверу ' + NameServerURL, 0, 2000);
      end;

    WM_GD_QUERY_SERVER:
      if QueryWebServer or True then
      begin
        PostThreadMessage(ThreadID, WM_GD_UPDATE_FILES, 0, 0);
        gdNotifierThread.Add('Подключение к серверу ' + FgdWebServerURL, 0, 2000);
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

initialization
  gdWebClientThread := TgdWebClientThread.Create;
  gdWebClientThread.Resume;

finalization
  FreeAndNil(gdWebClientThread);
end.