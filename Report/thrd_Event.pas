unit thrd_Event;

interface

uses
  Classes, IPCThrd, Windows, JclDebug;

const
  EventPrefix = '_EVENT';

type
  PServerEventCode = ^TServerEventCode;
  TServerEventCode = Integer;

type
  TReportServerEvent = procedure(const AnEventCode: TServerEventCode) of object;

type
  TServerEventThread = class(TJclDebugThread)
  private
    FName: String;
    FEvent: TEvent;
    FMemory: TSharedMem;
    FOnEvent: TReportServerEvent;
    FLastResult: TServerEventCode;

    procedure SendEvent;
    procedure CreateVars;
  public
    constructor Create(AnName: String);
    destructor Destroy; override;

    procedure UserTerminate;
    procedure Execute; override;
    property OnEvent: TReportServerEvent read FOnEvent write FOnEvent;
  end;

implementation

{ TEventThread }

constructor TServerEventThread.Create(AnName: String);
begin
  FName := AnName;

  inherited Create(True);

  Synchronize(CreateVars);
end;

procedure TServerEventThread.CreateVars;
begin
  FEvent := TEvent.Create(FName, False);
  FMemory := TSharedMem.Create(FName + EventPrefix, SizeOf(TServerEventCode));
  FreeOnTerminate := False;
end;

destructor TServerEventThread.Destroy;
begin
  FMemory.Free;
  FEvent.Free;

  inherited Destroy;
end;

procedure TServerEventThread.Execute;
var
  WaitResult: Integer;
begin
  while not Terminated do
  begin
    WaitResult := WaitForSingleObject(FEvent.Handle, INFINITE);
    if WaitResult = WAIT_OBJECT_0 then
    begin
      FLastResult := PServerEventCode(FMemory.Buffer)^;
      Synchronize(SendEvent);
    end;
  end;
end;

procedure TServerEventThread.SendEvent;
begin
  if Assigned(FOnEvent) then
    FOnEvent(FLastResult);
end;

procedure TServerEventThread.UserTerminate;
begin
  Terminate;
  FEvent.Signal;
end;

end.
