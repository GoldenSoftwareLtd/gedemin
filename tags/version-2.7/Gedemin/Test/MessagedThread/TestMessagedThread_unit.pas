unit TestMessagedThread_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_ProgressNotifier_unit, StdCtrls, gdMessagedThread, ActnList;

type
  TMyThread = class(TgdMessagedThread)
  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;

  public
    procedure Start;
  end;

const
  WM_MY_NOTIFY = WM_USER + 1234;

type
  TForm1 = class(TForm, IgdProgressWatch)
    m: TMemo;
    ActionList1: TActionList;
    actStart: TAction;
    Button1: TButton;
    actStop: TAction;
    Button2: TButton;
    procedure actStartUpdate(Sender: TObject);
    procedure actStartExecute(Sender: TObject);
    procedure actStopUpdate(Sender: TObject);
    procedure actStopExecute(Sender: TObject);

  private
    FThread: TMyThread;

    procedure UpdateProgress(const AProgressInfo: TgdProgressInfo);
    procedure MyNotify(var Msg: TMessage);
      message WM_MY_NOTIFY;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

const
  WM_GD_STEP_1 = WM_GD_THREAD_USER + 1;
  WM_GD_STEP_2 = WM_GD_THREAD_USER + 2;
  WM_GD_STEP_3 = WM_GD_THREAD_USER + 3;

constructor TForm1.Create(AnOwner: TComponent);
begin
  inherited;
  FThread := TMyThread.Create(True);
  FThread.ProgressWatch := Self;
end;

destructor TForm1.Destroy;
begin
  FThread.Free;
  inherited;
end;

procedure TForm1.UpdateProgress(const AProgressInfo: TgdProgressInfo);
begin
  if AProgressInfo.State = psThreadStarted then
    m.Lines.Add('Start')
  else if AProgressInfo.State = psTerminating then
  begin
    m.Lines.Add('Terminating');
    PostMessage(Handle, WM_MY_NOTIFY, 1, 0);
  end
  else if AProgressInfo.State = psThreadFinishing then
  begin
    m.Lines.Add('Finishing');
    PostMessage(Handle, WM_MY_NOTIFY, 2, 0);
  end else
  if AProgressInfo.Message > '' then
    m.Lines.Add(AProgressInfo.Message);
end;

procedure TForm1.actStartUpdate(Sender: TObject);
begin
  actStart.Enabled := FThread.Suspended;
end;

procedure TForm1.actStartExecute(Sender: TObject);
begin
  FThread.Start;
end;

{ TMyThread }

function TMyThread.ProcessMessage(var Msg: TMsg): Boolean;
begin
  Result := True;

  case Msg.Message of
    WM_GD_STEP_1:
    begin
      LogMessage(psMessage, 'Step1');
      Sleep(2000);
      PostMsg(WM_GD_STEP_2);
    end;

    WM_GD_STEP_2:
    begin
      LogMessage(psMessage, 'Step2');
      Sleep(2000);
      PostMsg(WM_GD_STEP_3);
    end;

    WM_GD_STEP_3:
    begin
      LogMessage(psMessage, 'Step3');
      Sleep(2000);
      ExitThread;
    end;

  else
    Result := False;
  end;
end;

procedure TMyThread.Start;
begin
  if Suspended then
    Resume;
  PostMsg(WM_GD_STEP_1);
end;

procedure TForm1.actStopUpdate(Sender: TObject);
begin
  actStop.Enabled := (not FThread.Suspended)
    and (not FThread.Terminated);
end;

procedure TForm1.actStopExecute(Sender: TObject);
begin
  m.Lines.Add('Terminate');
  FThread.Terminate;
end;

procedure TForm1.MyNotify(var Msg: TMessage);
begin
  if not FThread.Suspended then
    FThread.WaitFor;
  if Msg.WParam = 1 then
    m.Lines.Add('Terminated')
  else if Msg.WParam = 2 then
  begin
    m.Lines.Add('Finished');
    FThread.Free;
    FThread := TMyThread.Create(True);
    FThread.ProgressWatch := Self;
  end;
end;

end.
