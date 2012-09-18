
unit gd_WebClientControl_unit;

interface

uses
  Classes, idHTTP, SyncObjs;

type
  TgdWebClientThread = class(TThread)
  private
    FCreatedEvent: TEvent;
    FgdWebServerURL: String;
    FServerResponse: String;
    FErrorMessage: String;

    procedure PostMsg(const AMsg: Word);
    procedure LogError;
    function QueryWebServer: Boolean;
    function LoadWebServerURL: Boolean;
    function CreateHTTP: TidHTTP;
    procedure UpdateFiles;

  protected
    procedure Execute; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConnection;

    property gdWebServerURL: String read FgdWebServerURL;
    property ServerResponse: String read FServerResponse;
  end;

var
  gdWebClientThread: TgdWebClientThread;

implementation

uses
  Windows, Messages, SysUtils, ComObj, ActiveX, gdcJournal, gd_FileList_unit,
  gd_security, JclSimpleXML;

const
  WM_GD_EXIT_THREAD =      WM_USER + 117;
  WM_GD_AFTER_CONNECTION = WM_USER + 118;
  WM_GD_QUERY_SERVER =     WM_USER + 119;
  WM_GD_UPDATE_FILES =     WM_USER + 120;

{ TgdWebClientThread }

constructor TgdWebClientThread.Create;
begin
  inherited Create(True);
  FreeOnTerminate := False;
  Priority := tpLowest;
  FCreatedEvent := TEvent.Create(nil, True, False, 'gdWebThreadMsgLoopCreated');
end;

destructor TgdWebClientThread.Destroy;
begin
  if (not Terminated) and (not Suspended) then
    PostMsg(WM_GD_EXIT_THREAD);
  inherited;

  FCreatedEvent.Free;
end;

procedure TgdWebClientThread.Execute;
var
  Msg: TMsg;
begin
  CoInitialize(nil);
  try
    PeekMessage(Msg, 0, WM_USER, WM_USER, PM_NOREMOVE);
    FCreatedEvent.SetEvent;

    while (not Terminated) and GetMessage(Msg, 0, 0, 0)
      and (Msg.Message <> WM_GD_EXIT_THREAD) do
    begin
      case Msg.Message of
        WM_GD_AFTER_CONNECTION:
          if LoadWebServerURL then
            PostThreadMessage(ThreadID, WM_GD_QUERY_SERVER, 0, 0);

        WM_GD_QUERY_SERVER:
          if QueryWebServer or True then
            PostThreadMessage(ThreadID, WM_GD_UPDATE_FILES, 0, 0);

        WM_GD_UPDATE_FILES:
          UpdateFiles;
      else
        TranslateMessage(Msg);
        DispatchMessage(Msg);
      end;

      if FErrorMessage > '' then
        Synchronize(LogError);
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TgdWebClientThread.AfterConnection;
begin
  PostMsg(WM_GD_AFTER_CONNECTION);
end;

procedure TgdWebClientThread.PostMsg(const AMsg: Word);
begin
  if FCreatedEvent.WaitFor(INFINITE) = wrSignaled then
    PostThreadMessage(ThreadID, AMsg, 0, 0);
end;

procedure TgdWebClientThread.LogError;
begin
  if FErrorMessage > '' then
  begin
    TgdcJournal.AddEvent(FErrorMessage, 'HTTPClient', -1, nil, True);
    FErrorMessage := '';
  end;
end;

function TgdWebClientThread.QueryWebServer: Boolean;
var
  HTTP: TidHTTP;
  XML: TStringList;
begin
  Assert(Assigned(IBLogin));

  Result := False;

  if FgdWebServerURL > '' then
  begin
    HTTP := CreateHTTP;
    XML := TStringList.Create;
    try
      XML.Text :=
        '<?xml version="1.0" encoding="Windows-1251"?>'#13#10 +
        '<QUERY>'#13#10 +
        '  <VERSION_1>'#13#10 +
        '    <DBID>' + IntToStr(IBLogin.DBID) + '</DBID>'#13#10 +
        '    <CUSTOMERNAME>' + EntityEncode(IBLogin.CompanyName) + '</CUSTOMERNAME>'#13#10 +
        '  </VERSION_1>'#13#10 +
        '</QUERY>';

      try
        FServerResponse := HTTP.Post(FgdWebServerURL + '/query', XML);
        Result := FServerResponse > '';
      except
        on E: Exception do
          FErrorMessage := E.Message + ' URL: ' + FgdWebServerURL;
      end;
    finally
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
const
  NameServerURL = 'http://gsbelarus.com/gs/gedemin/gdwebserver.xml';
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
          FgdWebServerURL := 'http://192.168.0.58';
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

initialization
  gdWebClientThread := TgdWebClientThread.Create;
  gdWebClientThread.Resume;

finalization
  FreeAndNil(gdWebClientThread);
end.