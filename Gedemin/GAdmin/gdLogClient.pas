unit gdLogClient;

interface

uses
  Classes, Dialogs, Windows, SyncObjs, Forms, gdMessagedThread,
  IdTCPConnection, IdTCPClient, IdThreadSafe;

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
    FConnected: TidThreadSafeInteger;
    FAttempts: Integer;

    function GetConnected: Boolean;

  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;
    procedure DoWorkClient;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Init;
    procedure Done;
    procedure Log(const AMsg: String);

    property Connected: Boolean read GetConnected;
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
  FConnected := TidThreadSafeInteger.Create;
end;

destructor TgdLogClient.Destroy;
begin
  inherited;
  FBufferCS.Free;
  FConnected.Free;
end;

function TgdLogClient.ProcessMessage(var Msg: TMsg): Boolean;
begin
  Result := True;

  case Msg.Message of

    WM_LOG_INIT:
    begin
      if Connected then
        exit;

      if FTCPClient = nil then
      begin
        FTCPClient := TIdTCPClient.Create(nil);
        FTCPClient.Host := '127.0.0.1';
        FTCPClient.Port := 27070;
      end;

      try
        FTCPClient.Connect;
        FConnected.Value := 1;
      except
        if FAttempts = 0 then
          PostMsg(WM_LOG_LOAD_CC);
      end;
    end;

    WM_LOG_LOAD_CC:
    begin
      if (not Connected) and (WinExec('gedemin_cc.exe', SW_HIDE) > 31) then
      begin
        Inc(FAttempts);
        PostMsg(WM_LOG_INIT);
      end;
    end;

    WM_LOG_DONE:
    begin
      FreeAndNil(FTCPClient);
      FConnected.Value := 0;
    end;

    WM_LOG_PROCESS_REC:
    begin
      if (not Connected) or (FTCPClient = nil) then
        exit;

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

procedure TgdLogClient.Init;
begin
  PostMsg(WM_LOG_INIT);
end;

procedure TgdLogClient.Done;
begin
  PostMsg(WM_LOG_DONE);
end;

procedure TgdLogClient.Log(const AMsg: String);
begin
  if not Connected then
    exit;

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

  PostMsg(WM_LOG_PROCESS_REC);
end;

procedure TgdLogClient.DoWorkClient;
begin
  FTCPClient.WriteBuffer(FBuffer[FStart], SizeOf(FBuffer[FStart]), true);
end;

function TgdLogClient.GetConnected: Boolean;
begin
  Result := FConnected.Value <> 0;
end;

initialization
  gdLog := TgdLogClient.Create;
  gdLog.Resume;

finalization
  FreeAndNil(gdLog);
end.
