unit gdLogClient;

interface

uses
  Classes, Dialogs, Windows, SyncObjs, gdMessagedThread, IdTCPConnection, IdTCPClient;

const
  MaxBufferSize = 1024;
  MaxMsgLength = 255;

type
  TLogRecord = record
    DT: TDateTime;
    Msg: String[MaxMsgLength];
  end;

  TgdLogClient = class(TgdMessagedThread)
  private
    FBuffer: array[0..MaxBufferSize - 1] of TLogRecord;
    FStart, FEnd: Integer;
    FBufferCS: TCriticalSection;

  protected
    TCPClient: TIdTCPClient;
    function ProcessMessage(var Msg: TMsg): Boolean; override;
    procedure DoWorkClient;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Start;
    procedure Finish;
    procedure Log(const AMsg: String);
    procedure Connect;
    procedure Disconnect;
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
  if TCPClient <> nil then
    TCPClient.Free;
end;

function TgdLogClient.ProcessMessage(var Msg: TMsg): Boolean;
begin
  Result := True;

  case Msg.Message of

    WM_LOG_INIT:
    begin

    end;

    WM_LOG_DONE:
    begin

    end;

    WM_LOG_PROCESS_REC:
    begin
      FBufferCS.Enter;
      try
        while FStart <> FEnd do
        begin
          // FBbuffer[FStart] -- log record for processing

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
      FBuffer[FEnd].DT := Now;
      FBuffer[FEnd].Msg := Copy(AMsg, 1, MaxMsgLength);
      Inc(FEnd);
    end;

  finally
    FBufferCS.Leave;
  end;
  DoWorkClient;
  PostMsg(WM_LOG_PROCESS_REC);
end;

procedure TgdLogClient.Connect;
begin
  if not TCPClient.Connected then
  begin
    TCPClient.Host := '127.0.0.1';
    TCPClient.Port := 7070;
    TCPClient.Connect;
    ShowMessage('Connect');
  end;
end;

procedure TgdLogClient.Disconnect;
begin
  if TCPClient.Connected then
    TCPClient.Disconnect;
end;

procedure TgdLogClient.DoWorkClient;
begin
    TCPClient := TIdTCPClient.Create(nil);
    Connect;
    TCPClient.WriteLn('Message');
    ShowMessage(TCPClient.ReadLn);
    Disconnect;
end;


initialization
  gdLog := TgdLogClient.Create;
  gdLog.Resume;

finalization
  FreeAndNil(gdLog);
end.
