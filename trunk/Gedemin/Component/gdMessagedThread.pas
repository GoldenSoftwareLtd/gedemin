
unit gdMessagedThread;

interface

uses
  Classes, Windows, SyncObjs;

type
  TgdMessagedThread = class(TThread)
  private
    FCreatedEvent, FWaitingEvent: TEvent;
    FCriticalSection: TCriticalSection;
    FTimeout: DWORD;
    function GetWaiting: Boolean;

  protected
    FErrorMessage: String;

    procedure PostMsg(const AMsg: Word; const AWParam: WPARAM = 0;
      const ALParam: LPARAM = 0);
    procedure Timeout; virtual;
    procedure Execute; override;
    procedure Setup; virtual;
    procedure TearDown; virtual;
    function ProcessMessage(var Msg: TMsg): Boolean; virtual;
    procedure LogError; virtual;
    procedure SetTimeout(const ATimeout: DWORD);
    procedure Lock;
    procedure Unlock;

    property ErrorMessage: String read FErrorMessage write FErrorMessage;

  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;

    property Waiting: Boolean read GetWaiting;
  end;

implementation

uses
  SysUtils, Messages;

const
  WM_GD_EXIT_THREAD  =      WM_USER + 117;
  WM_GD_UPDATE_TIMER =      WM_USER + 118;

{ TgdMessagedThread }

constructor TgdMessagedThread.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  FTimeOut := INFINITE;
  FCreatedEvent := TEvent.Create(nil, True, False, '');
  FWaitingEvent := TEvent.Create(nil, True, False, '');
  FCriticalSection := TCriticalSection.Create;
end;

destructor TgdMessagedThread.Destroy;
begin
  if not Suspended then
  begin
    if FCreatedEvent.WaitFor(INFINITE) = wrSignaled then
      PostThreadMessage(ThreadID, WM_GD_EXIT_THREAD, 0, 0);
  end;

  inherited;

  FCreatedEvent.Free;
  FWaitingEvent.Free;
  FCriticalSection.Free;
end;

procedure TgdMessagedThread.Execute;
var
  Msg: TMsg;
  HArr: array[0..0] of THandle;
  Res: DWORD;
begin
  PeekMessage(Msg, 0, WM_USER, WM_USER, PM_NOREMOVE);
  FCreatedEvent.SetEvent;
  Setup;
  try
    while (not Terminated) do
    begin
      FWaitingEvent.SetEvent;
      try
        Res := MsgWaitForMultipleObjects(0, HArr, False, FTimeout, QS_ALLINPUT);
      finally
        FWaitingEvent.ResetEvent;
      end;

      if (not Terminated) and (Res = WAIT_TIMEOUT) then
      begin
        Timeout
      end else
      begin
        while (not Terminated) and PeekMessage(Msg, 0, 0, $FFFFFFFF, PM_REMOVE) do
        begin
          case Msg.Message of
            WM_GD_EXIT_THREAD: exit;
            WM_GD_UPDATE_TIMER: FTimeout := Msg.LParam;
          else
            try
              if not ProcessMessage(Msg) then
              begin
                TranslateMessage(Msg);
                DispatchMessage(Msg);
              end;
            except
              on E: Exception do
                FErrorMessage := E.Message;
            end;

            if FErrorMessage > '' then
            begin
              FErrorMessage := FErrorMessage + #13#10 +
                'Message ID: ' + IntToStr(Msg.Message);
              Synchronize(LogError);
              FErrorMessage := '';
            end;
          end;
        end;
      end;
    end;
  finally
    TearDown;
  end;
end;

function TgdMessagedThread.GetWaiting: Boolean;
begin
  Result := FWaitingEvent.WaitFor(0) = wrSignaled;
end;

procedure TgdMessagedThread.Lock;
begin
  FCriticalSection.Enter;
end;

procedure TgdMessagedThread.LogError;
begin
  MessageBox(0,
    PChar(FErrorMessage),
    'Error',
    MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
end;

procedure TgdMessagedThread.PostMsg(const AMsg: Word; const AWParam: WPARAM = 0;
  const ALParam: LPARAM = 0);
begin
  if (not Suspended) and (not Terminated) then
  begin
    if FCreatedEvent.WaitFor(INFINITE) = wrSignaled then
      PostThreadMessage(ThreadID, AMsg, AWParam, ALParam);
  end;
end;

function TgdMessagedThread.ProcessMessage(var Msg: TMsg): Boolean;
begin
  Result := False;
end;

procedure TgdMessagedThread.SetTimeout(const ATimeout: DWORD);
begin
  PostMsg(WM_GD_UPDATE_TIMER, 0, ATimeout);
end;

procedure TgdMessagedThread.Setup;
begin
  //
end;

procedure TgdMessagedThread.TearDown;
begin
  //
end;

procedure TgdMessagedThread.Timeout;
begin
  //
end;

procedure TgdMessagedThread.Unlock;
begin
  FCriticalSection.Leave;
end;

end.