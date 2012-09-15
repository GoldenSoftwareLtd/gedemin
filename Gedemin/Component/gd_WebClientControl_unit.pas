
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

  protected
    procedure Execute; override;
    procedure PostMsg(const AMsg: Word);

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
  Windows, Messages, SysUtils, ComObj, ActiveX;

const
  WM_GD_EXIT_THREAD = WM_USER + 117;
  WM_GD_AFTER_CONNECTION = WM_USER + 118;
  WM_GD_QUERY_SERVER = WM_USER + 119;

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
  LocalDoc: OleVariant;

  procedure LoadWebServerURL;
  var
    Sel: OleVariant;
    FHTTP: TidHTTP;
  begin
    FHTTP := TidHTTP.Create(nil);
    try
      FHTTP.HandleRedirects := True;
      FHTTP.ReadTimeout := 4000;
      FHTTP.ConnectTimeout := 4000;
      try
        if LocalDoc.LoadXML(FHTTP.Get('http://gsbelarus.com/gs/gedemin/gdwebserver.xml')) then
        begin
          Sel := LocalDoc.SelectSingleNode('/GDWEBSERVER/VERSION_1/URL');
          if not VarIsEmpty(Sel) then
            FgdWebServerURL := Sel.NodeTypedValue;
        end;
      except
      end;
    finally
      FHTTP.Free;
    end;
  end;

  procedure QueryWebServer;
  var
    FHTTP: TidHTTP;
  begin
    FHTTP := TidHTTP.Create(nil);
    try
      FHTTP.HandleRedirects := True;
      FHTTP.ReadTimeout := 4000;
      FHTTP.ConnectTimeout := 4000;
      if FgdWebServerURL > '' then
      try
        FServerResponse := FHTTP.Get(FgdWebServerURL);
      except
      end;
    finally
      FHTTP.Free;
    end;
  end;

var
  Msg: TMsg;
begin
  CoInitialize(nil);
  try
    LocalDoc := CreateOleObject('MSXML.DOMDocument');
    LocalDoc.Async := False;
    LocalDoc.SetProperty('SelectionLanguage', 'XPath');

    PeekMessage(Msg, 0, WM_USER, WM_USER, PM_NOREMOVE);
    FCreatedEvent.SetEvent;

    while (not Terminated) and GetMessage(Msg, 0, 0, 0)
      and (Msg.Message <> WM_GD_EXIT_THREAD) do
    begin
      case Msg.Message of
        WM_GD_AFTER_CONNECTION:
        begin
          if FgdWebServerURL = '' then
            LoadWebServerURL;
          if FgdWebServerURL > '' then
            PostThreadMessage(ThreadID, WM_GD_QUERY_SERVER, 0, 0);
        end;

        WM_GD_QUERY_SERVER: QueryWebServer;
      else
        TranslateMessage(Msg);
        DispatchMessage(Msg);
      end;
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

initialization
  gdWebClientThread := TgdWebClientThread.Create;
  gdWebClientThread.Resume;

finalization
  FreeAndNil(gdWebClientThread);
end.