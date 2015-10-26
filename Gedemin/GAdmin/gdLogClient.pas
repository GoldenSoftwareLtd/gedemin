.
unit gdLogClient;

interface

uses
  Classes, Dialogs, Windows, SyncObjs, Forms, gdMessagedThread, IdTCPConnection, IdTCPClient;

const
  MaxBufferSize = 1024;
  MaxMsgLength = 255;

type
  TLogRecord = record
    Command: String[50];
    ClientName: String[20];
    DT: TDateTime;
    Msg: String[MaxMsgLength];
  end;

  TgdLogClient = class(TgdMessagedThread)
  private
    FBuffer: array[0..MaxBufferSize - 1] of TLogRecord;
    FStart, FEnd: Integer;
    FBufferCS: TCriticalSection;
    FTCPClient: TIdTCPClient;
    FComm: String[50];
    //FOSName: String[255];

  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;
    procedure DoWorkClient;
    procedure Connect;
    procedure Disconnect;
    procedure RunCC;
    //function GetUserFromWindows: string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Start;
    procedure Finish;
    procedure Log(const AMsg: String);
  end;

var
  gdLog: TgdLogClient;

implementation

uses
  SysUtils, gd_messages_const;

constructor TgdLogClient.Create;
begin
  inherited Create(True);
  Priority := tpLowest;
  FBufferCS := TCriticalSection.Create;
end;

destructor TgdLogClient.Destroy;
begin
  inherited;
  FBufferCS.Free;
end;

function TgdLogClient.ProcessMessage(var Msg: TMsg): Boolean;
begin
  Result := True;

  case Msg.Message of

    WM_LOG_INIT:
    begin
      FComm := 'RUN';
      Log('Гедымин запущен');
      //FOSName := GetUserFromWindows;
    end;

    WM_LOG_DONE:
    begin
      FComm := 'DONE';
      Log('Гедымин закрыт');
    end;

    WM_LOG_PROCESS_REC:
    begin
      FBufferCS.Enter;
      try
        while FStart <> FEnd do
        begin
          DoWorkClient;
          if FStart = MaxBufferSize - 1 then
            FStart := 0
          else
            Inc(FStart);
        end;
      finally
        FBufferCS.Leave;
      end;
    end;

  else
    Result := False;
  end;
end;

procedure TgdLogClient.Start;
begin
  PostMsg(WM_LOG_INIT);
end;

procedure TgdLogClient.Finish;
begin
  PostMsg(WM_LOG_DONE);
end;

procedure TgdLogClient.Log(const AMsg: String);
begin
  FBufferCS.Enter;
  try
    if (FEnd = MaxBufferSize) and (FStart > 0) then
      FEnd := 0;

    if (FEnd < MaxBufferSize) or (FEnd < FStart) then
    begin
      FBuffer[FEnd].Command := FComm;
      FBuffer[FEnd].ClientName := FTCPClient.LocalName;
      FBuffer[FEnd].DT := Now;
      FBuffer[FEnd].Msg := Copy(AMsg, 1, MaxMsgLength);
      Inc(FEnd);
    end;
  finally
    FBufferCS.Leave;
  end;
  FComm := ' ';
  PostMsg(WM_LOG_PROCESS_REC);
end;

procedure TgdLogClient.Connect;
begin
  try
    if FTCPClient = nil then
    begin
      FTCPClient := TIdTCPClient.Create(nil);
      FTCPClient.Host := '127.0.0.1';
      FTCPClient.Port := 27070;
    end;

    RunCC; // run CC in local computer

    if not FTCPClient.Connected then
      FTCPClient.Connect; // if CC not run - Socket Error
  except
    raise Exception.Create('Except Connect');
  end;
end;

procedure TgdLogClient.Disconnect;
begin
  FreeAndNil(FTCPClient);
end;

procedure TgdLogClient.DoWorkClient;
begin
  try
    Connect;
    try
      FTCPClient.WriteBuffer(FBuffer[FStart], SizeOf (FBuffer[FStart]), true);
    finally
      Disconnect;
    end;
  except
    raise Exception.Create('Except DoWork');
    exit;
  end;
end;

procedure TgdLogClient.RunCC;
begin
  try
    if FindWindow('Tfrm_gedemin_cc_main', nil) = 0 then
      //WinExec('gedemin_cc.exe', SW_MINIMIZE); // or SW_SHOWMINIMIZED? minimize?
      WinExec('gedemin_cc.exe', SW_HIDE);
  except
    raise Exception.Create('CC not run');
  end;
end;

{function TgdLogClient.GetUserFromWindows: string;
var
  Name : String[255];
begin
  if GetUserName(PChar(Name), 255) then
    Result := Copy(Name, 1, 254)
  else
    Result := 'Unknown';
end;}


initialization
  //gdLog := TgdLogClient.Create;
  //gdLog.Resume;

finalization
  //FreeAndNil(gdLog);
end.
