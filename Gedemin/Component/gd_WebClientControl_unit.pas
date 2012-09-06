
unit gd_WebClientControl_unit;

interface

uses
  Classes, idHTTP, SyncObjs;

type
  TgdWebClientThread = class(TThread)
  private
    FidHTTP: TidHTTP;
    FCreatedEvent: TEvent;
    FgdWebServerURL: String;
    FServerResponse: String;

  protected
    procedure Execute; override;
    procedure PostExitMsg;

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
  Priority := tpLowest;
  FidHTTP := TidHTTP.Create(nil);
  FidHTTP.HandleRedirects := True;
  FCreatedEvent := TEvent.Create(nil, True, False, 'gdWebThreadMsgLoopCreated');
end;

destructor TgdWebClientThread.Destroy;
begin
  if (not Terminated) and (not Suspended) then
    PostExitMsg;
  inherited;

  FCreatedEvent.Free;
  FidHTTP.Free;
end;

procedure TgdWebClientThread.PostExitMsg;
begin
  if FCreatedEvent.WaitFor(INFINITE) = wrSignaled then
    PostThreadMessage(ThreadID, WM_GD_EXIT_THREAD, 0, 0);
end;

procedure TgdWebClientThread.Execute;

  procedure LoadWebServerURL;
  var
    LocalDoc, Sel: OleVariant;
  begin
    LocalDoc := CreateOleObject('MSXML.DOMDocument');
    LocalDoc.Async := False;
    if LocalDoc.Load('http://gsbelarus.com/gs/gedemin/gdwebserver.xml') then
    begin
      LocalDoc.SetProperty('SelectionLanguage', 'XPath');
      Sel := LocalDoc.SelectNodes('/GDWEBSERVER/VERSION_1/URL[1]');
      if Sel.Length > 0 then
        FgdWebServerURL := Sel.Item(0).NodeTypedValue;
    end;
  end;

  procedure QueryServer;
  var
    LocalDoc: OleVariant;
  begin
    Assert(FgdWebServerURL > '');
    LocalDoc := CreateOleObject('MSXML.DOMDocument');
    LocalDoc.Async := False;
    if LocalDoc.Load(FgdWebServerURL) then
    begin
      FServerResponse := LocalDoc.Text;
    end;
  end;

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
        begin
          LoadWebServerURL;
          if FgdWebServerURL > '' then
            PostThreadMessage(ThreadID, WM_GD_QUERY_SERVER, 0, 0);
        end;

        WM_GD_QUERY_SERVER: QueryServer;
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
  if FCreatedEvent.WaitFor(INFINITE) = wrSignaled then
    PostThreadMessage(ThreadID, WM_GD_AFTER_CONNECTION, 0, 0);
end;

initialization
  gdWebClientThread := TgdWebClientThread.Create;
  gdWebClientThread.Resume;

finalization
  FreeAndNil(gdWebClientThread);
end.