// ShlTanya, 09.03.2019

unit gdccClient_unit;

interface

uses
  Classes, Windows, Messages, ContNrs, SyncObjs, gdMessagedThread,
  idThread, idThreadSafe, IdTCPClient, gdccGlobal, at_Log, gdccConst;

type
  TgdccClient = class(TgdMessagedThread)
  private
    FConnectionID: TidThreadSafeInteger;
    FTCPClient: TIdTCPClient;
    FReceivedCommands: TObjectList;
    FFileHandle: THandle;
    FHost: String;
    FPort: Integer;
    FLogStr: TidThreadSafeString;
    FProcesses: TgdccProcesses;
    FSendCS: TCriticalSection;
    FSendQueue: TObjectList;
    FProgressCanceled: TidThreadSafeInteger;
    FWaitingForCommand, FWaitedForCommand: TidThreadSafeInteger;
    FLogShown: Boolean;
    FDebugMode: Boolean;

    function GetProgressCanceled: Boolean;
    procedure SetProgressCanceled(const Value: Boolean);
    function GetConnected: Boolean;
    function GetLogStr: String;

  protected
    procedure Timeout; override;
    function ProcessMessage(var Msg: TMsg): Boolean; override;

  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    procedure AddLogRecord(const ASrc, S: String; const ALogType: Integer = gdcc_lt_Info;
      const AShowLog: Boolean = False);
    procedure SendCommand(const ACommand: Integer; AData: TStream;
      const AFreeIt: Boolean; const AWaitForCommand: Integer = gdcc_cmd_Unknown); overload;
    procedure SendCommand(const ACommand: Integer;
      const AWaitForCommand: Integer = gdcc_cmd_Unknown); overload;
    procedure SendCommand(const ACommand, AData: Integer;
      const AWaitForCommand: Integer = gdcc_cmd_Unknown); overload;
    function WaitForCommand(const ACommand, AMaxWait: Integer): Boolean;

    function StartPerfCounter(const ASrc, AName: String): Integer;
    procedure StopPerfCounter(const AnID: Integer);

    property ProgressCanceled: Boolean read GetProgressCanceled write SetProgressCanceled;
    property Connected: Boolean read GetConnected;
    property LogStr: String read GetLogStr;
    property DebugMode: Boolean read FDebugMode write FDebugMode;
  end;

var
  gdccClient: TgdccClient;

implementation

uses
  SysUtils, Forms, gd_messages_const, ShellAPI, gd_common_functions, idException,
  gd_directories_const, gd_GlobalParams_unit;

type
  TSendItem = class
  public
    FCommand: Integer;
    FData: TStream;
    FWaitForCommand: Integer;

    destructor Destroy; override;
  end;

{ TgdccClient }

procedure TgdccClient.AddLogRecord(const ASrc, S: String;
  const ALogType: Integer; const AShowLog: Boolean);
var
  St: TStream;
begin
  if not Connected then
    exit;

  St := TMemoryStream.Create;
  SaveIntegerToStream(ALogType, St);
  SaveStringToStream(ASrc, St);
  SaveStringToStream(S, St);

  SendCommand(gdcc_cmd_Record, St, True);
  if AShowLog and (not FLogShown) then
  begin
    FLogShown := True;
    SendCommand(gdcc_cmd_ShowLog);
  end;
end;

procedure TgdccClient.Connect;
begin
  if not Connected then
    PostMsg(WM_GDCC_CONNECT);
end;

constructor TgdccClient.Create(CreateSuspended: Boolean);
var
  S: String;
begin
  S := gd_GlobalParams.GetGDCCHost;
  if S = '' then
  begin
    FHost := gdccDefAddress;
    FPort := gdccDefPort;
  end else
  begin
    if Pos(':', S) > 0 then
    begin
      FHost := Copy(S, 1, Pos(':', S) - 1);
      if FHost = '' then
        FHost := gdccDefAddress;
      FPort := StrToIntDef(Copy(S, Pos(':', S) + 1, 256), gdccDefPort);
    end else
    begin
      FHost := S;
      FPort := gdccDefPort;
    end;
  end;
  FProcesses := TgdccProcesses.Create;
  FConnectionID := TidThreadSafeInteger.Create;
  FConnectionID.Value := 0;
  FProgressCanceled := TidThreadSafeInteger.Create;
  FSendCS := TCriticalSection.Create;
  FLogStr := TidThreadSafeString.Create;
  FWaitingForCommand := TidThreadSafeInteger.Create;
  FWaitedForCommand := TidThreadSafeInteger.Create;
  inherited Create(CreateSuspended);
  Priority := tpLower;
end;

destructor TgdccClient.Destroy;
begin
  Disconnect;
  inherited;
  FConnectionID.Free;
  FProgressCanceled.Free;
  FTCPClient.Free;
  FReceivedCommands.Free;
  FSendCS.Free;
  FSendQueue.Free;
  FProcesses.Free;
  FLogStr.Free;
  FWaitingForCommand.Free;
  FWaitedForCommand.Free;
end;

procedure TgdccClient.Disconnect;
begin
  if Connected then
    PostMsg(WM_GDCC_DISCONNECT);
end;

function TgdccClient.GetProgressCanceled: Boolean;
begin
  Result := FprogressCanceled.Value <> 0;
end;

function TgdccClient.ProcessMessage(var Msg: TMsg): Boolean;
var
  LoadCC: Boolean;
  MutexHandle: THandle;
  Cmd: TgdccCommand;
  SendMsg: Boolean;
  Ver: Cardinal;
  St: TStream;
  I: TSendItem;
  K: Integer;
begin
  Result := True;

  case Msg.Message of
    WM_GDCC_CONNECT:
    begin
      if FConnectionID.Value = 0 then
      begin
        if FHost = gdccDefAddress then
        begin
          MutexHandle := CreateMutex(nil, True, PChar(gdccMutexName));
          LoadCC := (MutexHandle <> 0) and (GetLastError <> ERROR_ALREADY_EXISTS);
          if MutexHandle <> 0 then
          begin
            ReleaseMutex(MutexHandle);
            CloseHandle(MutexHandle);
          end;

          if LoadCC then
          begin
            FFileHandle := ShellExecute(0,
              'open',
              Gedemin_Control_Center,
              nil,
              PChar(ExtractFilePath(Application.EXEName)),
              SW_SHOW);

            // надо ли тут этот слип не понятно
            // как-бы даем время запуститься TCP
            // серверу на стороне GDCC  
            Sleep(400);
          end;

          if LoadCC and (FFileHandle <= 32) then
            exit;
        end;    

        if FTCPClient = nil then
        begin
          FTCPClient := TIdTCPClient.Create(nil);
          FTCPClient.Host := FHost;
          FTCPClient.Port := FPort;
          FTCPClient.ReadTimeOut := 2000;
        end;

        try
          FTCPClient.Connect;
        except
          FreeAndNil(FTCPClient);
        end;

        if FTCPClient <> nil then
        begin
          St := TMemoryStream.Create;
          try
            SaveStringToStream(FTCPClient.LocalName, St);
            if TgdccCommand.WriteCommand(FTCPClient, gdcc_cmd_Connect, St)
              and (TgdccCommand.ReadCommand(FTCPClient, Ver) = gdcc_cmd_AckConnect)
              and (Ver = gdccVersion) then
            begin
              FConnectionID.Value := 1;
              SetTimeOut(2000);
            end;
          finally
            St.Free;
          end;
        end;
      end;
    end;

    WM_GDCC_DISCONNECT:
    begin
      if FConnectionID.Value <> 0 then
      begin
        FConnectionID.Value := 0;
        if (FTCPClient <> nil) and FTCPClient.Connected then
        begin
          try
            TgdccCommand.WriteCommand(FTCPClient, gdcc_cmd_Disconnect, FFileHandle);
          finally
            FTCPClient.Disconnect;
          end;
        end;
      end;
    end;

    WM_GDCC_COMMANDRECEIVED:
    begin
      if FReceivedCommands <> nil then
      begin
        while FReceivedCommands.Count > 0 do
        begin
          try
            case (FReceivedCommands[0] as TgdccCommand).Hdr.Command of
              gdcc_cmd_CancelProgress:
                ProgressCanceled := True;

              gdcc_cmd_ServerClosing:
              begin
                FConnectionID.Value := 0;
                FreeAndNil(FTCPClient);
                SetTimeOut(INFINITE);
              end;

              gdcc_cmd_LogTransfered:
              begin
                if (FReceivedCommands[0] as TgdccCommand).Stream <> nil then
                  FLogStr.Value := ReadStringFromStream((FReceivedCommands[0] as TgdccCommand).Stream);
              end;
            end;

            if FWaitingForCommand.Value = (FReceivedCommands[0] as TgdccCommand).Hdr.Command then
              FWaitedForCommand.Value := (FReceivedCommands[0] as TgdccCommand).Hdr.Command;
          finally
            FReceivedCommands.Delete(0);
          end;
        end;
      end;
    end;

    WM_GDCC_SENDCOMMAND:
    begin
      if FConnectionID.Value <> 0 then
      begin
        K := 0;

        FSendCS.Enter;
        try
          if (FSendQueue <> nil) and (FSendQueue.Count > 0) then
          begin
            I := FSendQueue[0] as TSendItem;
            FSendQueue.Extract(I);
            K := FSendQueue.Count;
          end else
            I := nil;
        finally
          FSendCS.Leave;
        end;

        if I <> nil then
        try
          if TgdccCommand.WriteCommand(FTCPClient, I.FCommand, I.FData) then
          begin
            if I.FWaitForCommand <> gdcc_cmd_Unknown then
            begin
              FWaitingForCommand.Value := I.FWaitForCommand;
              FWaitedForCommand.Value := 0;
            end;
          end else
          begin
            FConnectionID.Value := 0;
            FreeAndNil(FTCPClient);
            PostMsg(WM_GDCC_CONNECT);
          end;
        finally
          I.Free;
        end;  

        if FConnectionID.Value <> 0 then
        begin
          PostMsg(WM_GDCC_RECEIVECOMMAND);

          if K > 0 then
            PostMsg(WM_GDCC_SENDCOMMAND);
        end;
      end;
    end;

    WM_GDCC_RECEIVECOMMAND:
    begin
      if (FConnectionID.Value <> 0) and (FTCPClient <> nil) and FTCPClient.Connected then
      begin
        try
          if FTCPClient.InputBuffer.Size < SizeOf(TgdccHeader) then
            FTCPClient.ReadFromStack(False, 0, False);
          SendMsg := False;
          while FTCPClient.Connected and (FTCPClient.InputBuffer.Size >= SizeOf(TgdccHeader)) do
          begin
            Cmd := TgdccCommand.Create;
            try
              if Cmd.Read(FTCPClient) then
              begin
                if FReceivedCommands = nil then
                  FReceivedCommands := TObjectList.Create(True);
                FReceivedCommands.Add(Cmd);
                Cmd := nil;
                SendMsg := True;
              end;
            finally
              Cmd.Free;
            end;
          end;
          if SendMsg then
            PostMsg(WM_GDCC_COMMANDRECEIVED);
        except
          on EidSocketError do
            FConnectionID.Value := 0;
        end;
      end else
        SetTimeout(INFINITE);
    end;

  else
    Result := False;
  end;
end;

procedure TgdccClient.SendCommand(const ACommand: Integer; AData: TStream;
  const AFreeIt: Boolean; const AWaitForCommand: Integer = gdcc_cmd_Unknown);
var
  I: TSendItem;
begin
  if Connected then
  begin
    I := TSendItem.Create;
    I.FCommand := ACommand;
    I.FWaitForCommand := AWaitForCommand;
    if AFreeIt then
      I.FData := AData
    else begin
      if (AData <> nil) and (AData.Size > 0) then
      begin
        I.FData := TMemoryStream.Create;
        I.FData.CopyFrom(AData, 0);
      end;
    end;

    FSendCS.Enter;
    try
      if FSendQueue = nil then
        FSendQueue := TObjectList.Create(True);

      if FSendQueue.Count > 10000 then
        FSendQueue.Delete(0);

      FSendQueue.Add(I);
    finally
      FSendCS.Leave;
    end;

    if AWaitForCommand <> gdcc_cmd_Unknown then
    begin
      FWaitingForCommand.Value := gdcc_cmd_Unknown;
      FWaitedForCommand.Value := gdcc_cmd_Unknown;
    end;

    PostMsg(WM_GDCC_SENDCOMMAND);
  end
  else if AFreeIt then
    AData.Free;
end;

procedure TgdccClient.SendCommand(const ACommand: Integer;
  const AWaitForCommand: Integer = gdcc_cmd_Unknown);
begin
  SendCommand(ACommand, nil, False, AWaitForCommand);
end;

procedure TgdccClient.SetProgressCanceled(const Value: Boolean);
begin
  if Value then
    FProgressCanceled.Value := 1
  else
    FProgressCanceled.Value := 0;
end;

procedure TgdccClient.Timeout;
begin
  if FConnectionID.Value <> 0 then
    PostMsg(WM_GDCC_RECEIVECOMMAND)
  else
    SetTimeout(INFINITE);
end;

function TgdccClient.StartPerfCounter(const ASrc, AName: String): Integer;
var
  NewProcess: TgdccProcess;
begin
  if not Connected then
  begin
    Result := -1;
    exit;
  end;

  NewProcess := FProcesses.AddAndLock;
  try
    NewProcess.Src := ASrc;
    NewProcess.Name := AName;
    Result := NewProcess.ID;
  finally
    FProcesses.Unlock;
  end;
end;

procedure TgdccClient.StopPerfCounter(const AnID: Integer);
var
  St: TStream;
  P: TgdccProcess;
begin
  if not Connected then
    exit;

  St := nil;

  if FProcesses.FindAndLock(AnID, P) then
  try
    P.DoStop;
    St := TMemoryStream.Create;
    try
      P.SaveToStream(St);
    except
      St.Free;
      raise;
    end;
    FProcesses.Remove(P);
  finally
    FProcesses.Unlock;
  end;

  if St <> nil then
    SendCommand(gdcc_cmd_Process, St, True);
end;

function TgdccClient.GetConnected: Boolean;
begin
  Result := FConnectionID.Value <> 0;
end;

procedure TgdccClient.SendCommand(const ACommand, AData: Integer;
  const AWaitForCommand: Integer = gdcc_cmd_Unknown);
var
  St: TStream;
begin
  if not Connected then
    exit;

  St := TMemoryStream.Create;
  SaveIntegerToStream(AData, St);

  SendCommand(ACommand, St, True, AWaitForCommand);
end;

function TgdccClient.WaitForCommand(const ACommand,
  AMaxWait: Integer): Boolean;
var
  T: Integer;
begin
  Result := False;
  T := 0;
  while Connected and (not Result) do
  begin
    if FWaitedForCommand.Value = ACommand then
      Result := True
    else if T <= AMaxWait then
    begin
      Sleep(40);
      Inc(T, 40);
    end else
      break;
  end;
end;

function TgdccClient.GetLogStr: String;
begin
  Result := FLogStr.Value;
end;

{ TSendItem }

destructor TSendItem.Destroy;
begin
  FData.Free;
  inherited;
end;


initialization
  gdccClient := TgdccClient.Create(True);
  gdccClient.Resume;

finalization
  FreeAndNil(gdccClient);
end.
