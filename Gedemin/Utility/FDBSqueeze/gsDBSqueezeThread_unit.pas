unit gsDBSqueezeThread_unit;

interface

uses
  Classes, SyncObjs, Messages, gsDBSqueeze_unit, gdMessagedThread, Windows;

const
  WM_DBS_LOG        = WM_USER + 1;

  WM_DBS_NONE       = WM_USER + 2;
  WM_DBS_CONNECT    = WM_USER + 3;
  WM_DBS_DISCONNECT = WM_USER + 4;
  WM_DBS_EXIT       = WM_USER + 5;

type
  TgsDBSqueezeCommand = (dbscNone, dbscConnect, dbscDisconnect, dbscExit);


  TgsDBSqueezeThread = class(TgdMessagedThread)
  private
    //Окно, в которе будем отправлять нотификации/информацию
    FwndForNotify : THandle;

    FDBSqueeze: TgsDBSqueeze;

    FCSConnected: TCriticalSection; //


    FCommand: TgsDBSqueezeCommand;
    FOnLogEvent: TOnLogEvent;
  //  FMessage: String;
    FConnected: Boolean;

    function GetBusy: Boolean;
    function GetConnected: Boolean;

  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;


   // procedure Execute; override;
    procedure SetCommand(const ACmd: TgsDBSqueezeCommand);
    procedure LogEvent(const S: String);

  public
    constructor Create(AWndForNotify : THandle); reintroduce;
    destructor Destroy; override;

    procedure SetDBParams(const ADBName: string;
      const AUserName: string; const APassword: String);
    procedure Connect;
    procedure Disconnect;

    property Busy: Boolean read GetBusy;
    property OnLogEvent: TOnLogEvent read FOnLogEvent write FOnLogEvent;
    property Connected: Boolean read GetConnected;
  end;

implementation

//uses
//  Windows;

{ TgsDBSqueezeThread }

{
procedure TgsDBSqueezeThread.Execute;
begin
  while not Terminated do
  begin
    if not GetWaiting then
    begin
      FCommand := dbscNone;
      Break;
    end;


    case FCommand of

    end;

    //FEvent.ResetEvent;
  end;
end;
}




constructor TgsDBSqueezeThread.Create(AWndForNotify : THandle); //reintroduce;
begin
  inherited Create(True);
  FCommand := dbscNone;
  FDBSqueeze := TgsDBSqueeze.Create;
  FDBSqueeze.OnLogEvent := LogEvent;

  //Запомним хендл окна
  FwndForNotify := AWndForNotify;
  // Поток чистит память сам по завершению
  FreeOnTerminate := True;

  FCSConnected := TCriticalSection.Create;
  Resume;
end;

destructor TgsDBSqueezeThread.Destroy;
begin
  if not Suspended then
    SetCommand(dbscExit); //PostMsg(WM_DBS_EXIT);
  inherited;
  FDBSqueeze.Free;

  FCSConnected.Free;
end;


/////////////////////////////
function TgsDBSqueezeThread.ProcessMessage(var Msg: TMsg): Boolean;
begin
  Result := True;

  case Msg.Message of
  WM_DBS_CONNECT:
  begin
    Lock;
    try
      FDBSqueeze.Connect;
      FDBSqueeze.BeforeMigrationPrepareDB;
      FCommand := dbscNone;

      FCSConnected.Enter;
      try
        FConnected := FDBSqueeze.Connected;
      finally
        FCSConnected.Leave;
      end;
    finally
      Unlock;
    end;
  end;

  WM_DBS_DISCONNECT:
  begin
    Lock;
    try
      FDBSqueeze.AfterMigrationPrepareDB;
      FDBSqueeze.Disconnect;
      FCommand := dbscNone;

      FCSConnected.Enter;
      try
        FConnected := FDBSqueeze.Connected;
      finally
        FCSConnected.Leave;
      end;
    finally
      Unlock;
    end;
  end;

  WM_DBS_EXIT:
  begin
    FCommand := dbscNone;
    Break;
  end;

  else
    Result := False;
  end;
end;
///////////////////////////


procedure TgsDBSqueezeThread.SetDBParams(const ADBName, AUserName,
  APassword: String);
begin
  Lock;
  try
    FDBSqueeze.DatabaseName := ADBName;
    FDBSqueeze.UserName := AUserName;
    FDBSqueeze.Password := APassword;
  finally
    Unlock;
  end;
end;

procedure TgsDBSqueezeThread.Connect;
begin
  SetCommand(dbscConnect);    //PostMsg(WM_DBS_CONNECT);
end;

procedure TgsDBSqueezeThread.Disconnect;
begin
  SetCommand(dbscDisconnect); //PostMsg(WM_DBS_DISCONNECT);
end;


procedure TgsDBSqueezeThread.SetCommand(const ACmd: TgsDBSqueezeCommand);
begin
  Lock;
  FCommand := ACmd;
  Unlock;
  //FEvent.SetEvent;
  case ACmd of
  dbscNone: PostMsg(WM_DBS_NONE);

  dbscConnect: PostMsg(WM_DBS_CONNECT);

  dbscDisconnect: PostMsg(WM_DBS_DISCONNECT);

  dbscExit: PostMsg(WM_DBS_EXIT);
  end;
end;


function TgsDBSqueezeThread.GetBusy: Boolean;
begin
  Lock;
  Result := (not Suspended) and (FCommand <> dbscNone);
  Unlock;
end;

procedure TgsDBSqueezeThread.LogEvent(const S: String);
begin
  //FMessage := S;
  //Synchronize(SyncLogEvent);

{  PostMsg(WM_DBS_LOG, 0, Integer(Pointer(S)));       }

  SendMessage(
      FwndForNotify,                        //Хендл окна
      WM_DBS_LOG,                           //Сообщение
      0,
      Integer(Pointer(S))                   //Текст
      );
end;

function TgsDBSqueezeThread.GetConnected: Boolean;
begin
  FCSConnected.Enter;
  Result := FConnected;
  FCSConnected.Leave;
end;


end.
