
unit gdMessagedThread;

interface

uses
  Classes, Windows, Messages, SyncObjs, gd_ProgressNotifier_unit, idThreadSafe;

type
  TgdMessagedThread = class(TThread)
  private
    FCreatedEvent, FWaitingEvent: TEvent;
    FCriticalSection: TCriticalSection;
    FTimeout: DWORD;

    //function GetWaiting: Boolean;
    procedure Lock;
    procedure Unlock;

  protected
    FErrorMessage: String;
    FErrorMsg: TMsg;
    FProgressWatch: IgdProgressWatch;
    FPI: TgdProgressInfo;
    FDone: Boolean;

    procedure PostMsg(const AMsg: Word; const AWParam: WPARAM = 0;
      const ALParam: LPARAM = 0);
    procedure Timeout; virtual;
    procedure Execute; override;
    procedure Setup; virtual;
    procedure TearDown; virtual;
    function ProcessMessage(var Msg: TMsg): Boolean; virtual;
    function ProcessError(var AMsg: TMsg; var AnErrorMessage: String): Boolean; virtual;
    procedure LogErrorSync; virtual;
    procedure SetTimeout(const ATimeout: DWORD);
    procedure SyncProgressWatch;
    function GetProgressWatch: IgdProgressWatch;
    procedure SetProgressWatch(const Value: IgdProgressWatch);
    procedure LogMessage(const AState: TgdProgressState;
      const AMessage: String = '');
    procedure DoOnProgressWatch(Sender: TObject; const AProgressInfo: TgdProgressInfo);
    procedure ExitThread;
    procedure DoTerminate; override;

    property ErrorMessage: String read FErrorMessage write FErrorMessage;
    property ErrorMsg: TMsg read FErrorMsg write FErrorMsg;

  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;

    procedure WaitForIdle;

    //property Waiting: Boolean read GetWaiting;
    property ProgressWatch: IgdProgressWatch read GetProgressWatch write SetProgressWatch;
  end;

implementation

uses
  SysUtils, gd_messages_const;

{ TgdMessagedThread }

constructor TgdMessagedThread.Create(CreateSuspended: Boolean);
begin
  FTimeOut := INFINITE;
  FCreatedEvent := TEvent.Create(nil, True, False, '');
  FWaitingEvent := TEvent.Create(nil, True, False, '');
  FCriticalSection := TCriticalSection.Create;
  inherited Create(CreateSuspended);
end;

destructor TgdMessagedThread.Destroy;
begin
  if (not FDone) and (not Suspended) then
  begin
    if FCreatedEvent.WaitFor(INFINITE) = wrSignaled then
      PostThreadMessage(ThreadID, WM_GD_EXIT_THREAD, 0, 0);
  end;

  inherited;

  FCreatedEvent.Free;
  FWaitingEvent.Free;
  FCriticalSection.Free;
end;

procedure TgdMessagedThread.DoOnProgressWatch(Sender: TObject;
  const AProgressInfo: TgdProgressInfo);
begin
  FPI := AProgressInfo;
  Synchronize(SyncProgressWatch);
end;

procedure TgdMessagedThread.DoTerminate;
begin
  FDone := True;
  inherited;
end;

procedure TgdMessagedThread.Execute;
var
  Msg: TMsg;
  HArr: array[0..0] of THandle;
  Res: DWORD;
begin
  PeekMessage(Msg, 0, WM_USER, WM_USER, PM_NOREMOVE);
  FCreatedEvent.SetEvent;
  LogMessage(psThreadStarted);
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
        Timeout;
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
              FErrorMsg := Msg;
              if ProcessError(FErrorMsg, FErrorMessage) then
                Synchronize(LogErrorSync);
              FErrorMessage := '';
              FErrorMsg.Message := 0;
            end;
          end;
        end;
      end;
    end;
  finally
    TearDown;
    if Terminated then
      LogMessage(psTerminating)
    else
      LogMessage(psThreadFinishing);
  end;
end;

procedure TgdMessagedThread.ExitThread;
begin
  PostMsg(WM_GD_EXIT_THREAD);
end;

function TgdMessagedThread.GetProgressWatch: IgdProgressWatch;
begin
  Lock;
  try
    Result := FProgressWatch;
  finally
    Unlock;
  end;
end;

{
function TgdMessagedThread.GetWaiting: Boolean;
begin
  Result := FWaitingEvent.WaitFor(0) = wrSignaled;
end;
}

procedure TgdMessagedThread.Lock;
begin
  FCriticalSection.Enter;
end;

procedure TgdMessagedThread.LogErrorSync;
begin
  if Assigned(FProgressWatch) then
  begin
    FPI.State := psError;
    FPI.Message := ErrorMessage;
    FProgressWatch.UpdateProgress(FPI);
  end else
    MessageBox(0,
      PChar(ErrorMessage + #13#10 + 'Message ID: ' +
        IntToStr(ErrorMsg.Message)),
      'Error',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
end;

procedure TgdMessagedThread.LogMessage(const AState: TgdProgressState;
  const AMessage: String = '');
begin
  FPI.State := AState;
  FPI.Message := AMessage;
  Synchronize(SyncProgressWatch);
end;

procedure TgdMessagedThread.PostMsg(const AMsg: Word; const AWParam: WPARAM = 0;
  const ALParam: LPARAM = 0);
begin
  if (not FDone) and (not Suspended) and (not Terminated) then
  begin
    if FCreatedEvent.WaitFor(30000) = wrSignaled then
      PostThreadMessage(ThreadID, AMsg, AWParam, ALParam)
    else
      raise Exception.Create('Thread ' + Self.ClassName + ' is not created.');
  end;
end;

function TgdMessagedThread.ProcessError(var AMsg: TMsg;
  var AnErrorMessage: String): Boolean;
begin
  Result := True;
end;

function TgdMessagedThread.ProcessMessage(var Msg: TMsg): Boolean;
begin
  Result := False;
end;

procedure TgdMessagedThread.SetProgressWatch(
  const Value: IgdProgressWatch);
begin
  Lock;
  try
    FProgressWatch := Value;
  finally
    Unlock;
  end;
end;

procedure TgdMessagedThread.SetTimeout(const ATimeout: DWORD);
begin
  PostMsg(WM_GD_UPDATE_TIMER, 0, ATimeout);
end;

procedure TgdMessagedThread.Setup;
begin
  //
end;

procedure TgdMessagedThread.SyncProgressWatch;
begin
  if Assigned(FProgressWatch) then
    FProgressWatch.UpdateProgress(FPI);
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

procedure TgdMessagedThread.WaitForIdle;
var
  Msg: TMsg;
  H: THandle;
begin
  // How does TThread.WaitFor not cause a lockup?
  // http://www.devsuperpage.com/search/Articles.aspx?hl=en&G=1&ArtID=951084

  if (not FDone) and (not Suspended) and (FCreatedEvent.WaitFor(0) = wrSignaled) then
  begin
    H := FWaitingEvent.Handle;
    if GetCurrentThreadID = MainThreadID then
      while MsgWaitForMultipleObjects(1, H, False, INFINITE,
        QS_SENDMESSAGE) = WAIT_OBJECT_0 + 1 do PeekMessage(Msg, 0, 0, 0, PM_NOREMOVE)
    else WaitForSingleObject(H, INFINITE);
  end;
end;

end.