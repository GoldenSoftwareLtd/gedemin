unit gdLogClient;

interface

uses
  Classes, Dialogs, Windows, SyncObjs, Forms, gdMessagedThread,
  IdTCPConnection, IdTCPClient, IdThreadSafe, gedemin_cc_const,
  JclSysInfo, gd_security, IBDatabaseInfo, Messages{, IdSSLOpenSSL};

const
  DefaultHost = '127.0.0.1';
  ClassName = 'TgdLogClient';

type
  TgdLogClient = class(TgdMessagedThread)
  private
    FBuffer: array[0..MaxBufferSize - 1] of TLogRecord;
    FStart, FEnd: Integer;
    FBufferCS: TCriticalSection;
    FDoneEvent: TEvent;
    FTCPClient: TIdTCPClient;
    FConnected: TidThreadSafeInteger;
    FAttempts: Integer;
    FInitPar, FConnPar: TParam;
    FClient: TClient;
    //SSLIOHandler: TIdSSLIOHandlerSocket;

    function GetConnected: Boolean;

    procedure DoWorkClient;

  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure InitClient;
    procedure DoneClient;
    procedure Log(const AMsg, ASource, AnObjectName: String; const AnObjectID: Integer);

    property Connected: Boolean read GetConnected;
  end;

var
  gdLog: TgdLogClient;

implementation

uses
  SysUtils, gd_messages_const, jclSelected;

constructor TgdLogClient.Create;
begin
  inherited Create(True);
  Priority := tpLowest;
  FBufferCS := TCriticalSection.Create;
  FDoneEvent := TEvent.Create(nil, True, False, '');
  FConnected := TidThreadSafeInteger.Create;
end;

destructor TgdLogClient.Destroy;
begin
  inherited;
  FDoneEvent.Free;
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
        FTCPClient.Host := DefaultHost;
        FTCPClient.Port := DefaultPort;
      end;
      {if SSLIOHandler = nil then
      begin
        SSLIOHandler := TIdSSLIOHandlerSocket.Create(FTCPClient);
        SSLIOHandler.SSLOptions.Method := sslvTLSv1;
        SSLIOHandler.SSLOptions.Mode := sslmUnassigned;
        SSLIOHandler.SSLOptions.VerifyMode := [];
        SSLIOHandler.SSLOptions.VerifyDepth := 0;
      end;}
      try
        //FTCPClient.IOHandler := SSLIOHandler;
        FTCPClient.Connect;
        FConnected.Value := 1;
        FInitPar.ID := 0;
        FInitPar.Command := CC_INIT;
        FInitPar.Done := false;
        FTCPClient.WriteBuffer(FInitPar, SizeOf(FInitPar), true);
        FTCPClient.ReadBuffer(FInitPar, SizeOf(FInitPar));
        if FInitPar.Command = CC_INIT_SUCCESS then
        begin
          FClient.ID := FInitPar.ID;
          FClient.Host := GetLocalComputerName;
          FClient.IP := GetIPAddress(FClient.Host);
          FClient.OSName := GetLocalUserName;
          FClient.Connected := Now;
          FConnPar.ID := FClient.ID;
          FConnPar.Command := CC_RUN;
          FConnPar.Done := false;
          FTCPClient.WriteBuffer(FConnPar, SizeOf(FConnPar), true);
          FTCPClient.WriteBuffer(FClient, SizeOf(FClient), true);
          Log(GDRun, ClassName, '', 0);
        end;
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
      FDoneEvent.SetEvent;
      if (not Connected) or (FTCPClient = nil) then
        exit;
      FTCPClient.ReadBuffer(FConnPar, SizeOf(FConnPar)); //
      FConnPar.Command := CC_DONE;
      FTCPClient.WriteBuffer(FConnPar, SizeOf(FConnPar), true);
      FTCPClient.WriteBuffer(FClient, SizeOf(FClient), true);
      Log(GDDone, ClassName, '', 0);
    end;
    WM_LOG_FREE:
    begin
      FTCPClient.InputBuffer.Clear;
      FTCPClient.Disconnect;
      //FreeAndNil(SSLIOHandler);
      FreeAndNil(FTCPClient);
      FConnected.Value := 0;
      FDoneEvent.ResetEvent;
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
      {if FConnPar.Done then
      begin
        FConnPar.Done := false;
        PostMessage(Application.Handle, WM_QUIT, 0, 0);
      end;}
    end;
  else
    Result := False;
  end;
end;

procedure TgdLogClient.Log(const AMsg, ASource, AnObjectName: String; const AnObjectID: Integer);
var
  P, L: Integer;
begin
  if not Connected then
    exit;
  FBufferCS.Enter;
  try
    if (FEnd = MaxBufferSize) and (FStart > 0) then
      FEnd := 0;
    if (FEnd < MaxBufferSize) or (FEnd < FStart) then
    begin
      P := Pos(' ', ASource);
      L := Length(ASource);
      FBuffer[FEnd].ID := FClient.ID;
      FBuffer[FEnd].DTAct := Now;
      FBuffer[FEnd].IP := FClient.IP;
      FBuffer[FEnd].Host := FClient.Host;
      FBuffer[FEnd].OSName := FClient.OSName;
      FBuffer[FEnd].Msg := Copy(AMsg, 1, MaxMsgLength);
      if P <> 0 then
      begin
        FBuffer[FEnd].ObjClass := Copy(ASource, 1, P - 1);
        FBuffer[FEnd].ObjSubType := Copy(ASource, P + 1, L);
      end
      else
      begin
        FBuffer[FEnd].ObjClass := Copy(ASource, 1, L);
        FBuffer[FEnd].ObjSubType := '';
      end;
      FBuffer[FEnd].ObjName := AnObjectName;
      if (FBuffer[FEnd].ObjClass = '') then FBuffer[FEnd].ObjClass := '-';
      if (FBuffer[FEnd].ObjSubType = '') then FBuffer[FEnd].ObjSubType := '-';
      if (FBuffer[FEnd].ObjName = '') then FBuffer[FEnd].ObjName := '-';
      FBuffer[FEnd].ObjID := AnObjectID;
      if Assigned(IBLogin) and IBLogin.LoggedIn then
      begin
        FBuffer[FEnd].UserName := IBLogin.UserName;
        FBuffer[FEnd].DBFileName := IBLogin.DatabaseName;
      end
      else
      begin
        FBuffer[FEnd].UserName := '-';
        FBuffer[FEnd].DBFileName := '-';
      end;

      FBuffer[FEnd].OP := '--------';
      FBuffer[FEnd].SQL := '-';
      FBuffer[FEnd].CRC := 0;
      FBuffer[FEnd].Param := '?.?.?';
      FBuffer[FEnd].Inti := 0;
      FBuffer[FEnd].Str := '?';
      FBuffer[FEnd].Dt := 0;
      FBuffer[FEnd].Curr := 0;
      FBuffer[FEnd].Floati := 0;
      Inc(FEnd);
    end;
  finally
    FBufferCS.Leave;
  end;
  PostMsg(WM_LOG_PROCESS_REC);
end;

procedure TgdLogClient.InitClient;
begin
  PostMsg(WM_LOG_INIT);
end;

procedure TgdLogClient.DoneClient;
begin
  PostMsg(WM_LOG_DONE);
end;

procedure TgdLogClient.DoWorkClient;
var
  Comm: Integer;
begin
  try
    FTCPClient.ReadBuffer(FConnPar, SizeOf(FConnPar)); //
    if FConnPar.Done then
    begin
      FConnPar.Done := false;
      PostMessage(Application.Handle, WM_QUIT, 0, 0);
    end;
    Comm := FConnPar.Command;
    case Comm of
      CC_REC_NOW:
      begin
        FConnPar.Command := CC_REC;
        FTCPClient.WriteBuffer(FConnPar, SizeOf(FConnPar), true);
        FTCPClient.WriteBuffer(FBuffer[FStart], SizeOf(FBuffer[FStart]), true);
        if (FBuffer[FStart].Msg = GDDone) then
          PostMsg(WM_LOG_FREE);
      end;
    end;
  except
    exit;
    //raise;
  end;
end;

function TgdLogClient.GetConnected: Boolean;
begin
  Result := FConnected.Value <> 0;
end;

initialization
  gdLog := TgdLogClient.Create;
  gdLog.Resume;
  gdLog.InitClient;

finalization
  try
    gdLog.DoneClient;
  finally
    if (gdLog.FDoneEvent.WaitFor(0) = wrSignaled) then
      FreeAndNil(gdLog);
  end;
end.
