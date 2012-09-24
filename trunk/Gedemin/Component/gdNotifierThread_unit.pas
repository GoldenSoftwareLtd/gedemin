
unit gdNotifierThread_unit;

interface

uses
  Windows, Messages, SyncObjs, gdMessagedThread;

type
  TgdNotifierThread = class(TgdMessagedThread)
  private
    FCriticalSection: TCriticalSection;
    FNotification: String;
    FStartTime: TDateTime;

    procedure SyncNotification;
    function GetNotification: String;
    procedure SetNotification(const Value: String);

  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;
    procedure Timeout; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure StartTimer;
    procedure StopTimer;

    property Notification: String read GetNotification write SetNotification;
  end;

var
  gdNotifierThread: TgdNotifierThread;

implementation

uses
  Classes, SysUtils, gd_main_form;

const
  WM_GD_UPDATE_NOTIFIER = WM_USER + 2001;

{ TgdNotifierThread }

constructor TgdNotifierThread.Create;
begin
  inherited Create(True);
  Priority := tpLowest;
  FCriticalSection := TCriticalSection.Create;
end;

destructor TgdNotifierThread.Destroy;
begin
  inherited;
  FCriticalSection.Free;
end;

function TgdNotifierThread.ProcessMessage(var Msg: TMsg): Boolean;
begin
  if Msg.Message = WM_GD_UPDATE_NOTIFIER then
  begin
    Synchronize(SyncNotification);
    Result := True;
  end else
    Result := False;  
end;

procedure TgdNotifierThread.SyncNotification;
var
  TimeStr: String;
begin
  if (frmGedeminMain <> nil) and frmGedeminMain.Visible then
  begin
    if FStartTime > 0 then
      TimeStr := FormatDateTime('hh:nn:ss', Now - FStartTime) + ' '
    else
      TimeStr := '';
    frmGedeminMain.lblDatabase.Caption := TimeStr + FNotification;
  end;
end;

procedure TgdNotifierThread.StartTimer;
begin
  FCriticalSection.Enter;
  FStartTime := Now;
  FCriticalSection.Leave;
  SetTimeout(1000);
end;

procedure TgdNotifierThread.StopTimer;
begin
  FCriticalSection.Enter;
  FStartTime := 0;
  FCriticalSection.Leave;
  SetTimeout(INFINITE);
end;

procedure TgdNotifierThread.Timeout;
begin
  Synchronize(SyncNotification);
end;

function TgdNotifierThread.GetNotification: String;
begin
  FCriticalSection.Enter;
  Result := FNotification;
  FCriticalSection.Leave;
end;

procedure TgdNotifierThread.SetNotification(const Value: String);
begin
  FCriticalSection.Enter;
  try
    if FNotification <> Value then
    begin
      FNotification := Value;
      PostMsg(WM_GD_UPDATE_NOTIFIER);
     end; 
  finally
    FCriticalSection.Leave;
  end;
end;

initialization
  gdNotifierThread := TgdNotifierThread.Create;
  gdNotifierThread.Resume;

finalization
  FreeAndNil(gdNotifierThread);
end.