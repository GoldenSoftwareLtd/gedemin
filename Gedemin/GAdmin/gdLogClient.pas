// ShlTanya, 24.02.2019

unit gdLogClient;

interface

uses
  Classes, Dialogs, Windows, SyncObjs, Forms, gdMessagedThread,
  IdTCPConnection, IdTCPClient, IdThreadSafe, IdException, gedemin_cc_const,
  JclSysInfo, gd_security, IBDatabaseInfo, Messages, IdSSLOpenSSL;

const
  DefaultHost = '127.0.0.1';
  ClassName = 'TgdLogClient';

type
  TCRCRecord = record
    ObjClass: String[40];
    ObjSubType: String[31];
    Text: String;
    Comm: String[6];
    CRCSQL: Integer;
  end;

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
    FCRC: array[0..50] of TCRCRecord;
    FCRCI: Integer;                  
    FCRCCS: TCriticalSection;

    function GetConnected: Boolean;

    procedure DoWorkClient;

  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure InitClient;
    procedure DoneClient;
    procedure Log(const AMsg, ASource, AnObjectName: String; const AnObjectID: TID);

    procedure GetCRCSQL(const AText, AnObjectClassName: String);

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

  FCRCCS := TCriticalSection.Create;
end;

destructor TgdLogClient.Destroy;
begin
  inherited;

  FCRCCS.Free;

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

      {if (FindWindow('Tfrm_gedemin_cc_main', nil) = 0) then
      begin
        PostMsg(WM_LOG_LOAD_CC);
        exit;
      end;}

      if FTCPClient = nil then
      begin
        FTCPClient := TIdTCPClient.Create(nil);
        FTCPClient.Host := DefaultHost;
        FTCPClient.Port := DefaultPort;

        //FTCPClient.ReadTimeout := 7000;
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
        on EIdSocketError do
        begin
          //if FAttempts < 2 then
          if FAttempts = 0 then
            PostMsg(WM_LOG_LOAD_CC);
        end;
        on EIdOSSLConnectError do
        begin
          //
        end;
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
      FTCPClient.ReadBuffer(FConnPar, SizeOf(FConnPar));
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
    end;

  else
    Result := False;
  end;
end;

procedure TgdLogClient.Log(const AMsg, ASource, AnObjectName: String; const AnObjectID: TID);
var
  P, L, i: Integer;
  f: Boolean;
  CurrStr: String;
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

      CurrStr := Copy(FBuffer[FEnd].Msg, 1, 8);
      if CurrStr = 'Запись д' then
        CurrStr := 'INSERT';
      if CurrStr = 'Запись и' then
        CurrStr := 'UPDATE';
      if CurrStr = 'Запись у' then
        CurrStr := 'DELETE';
      if CurrStr = 'Запись о' then
        CurrStr := 'SELECT';
      if CurrStr = 'Окно ред' then
        CurrStr := 'SELECT';
      FCRCCS.Enter; // в зависимости от операции выбирать sql-запрос            // Запись добавлена - Insert
      try                                                                       // Запись изменена - Modify (-Update-)
        f := false;                                                             // Запись удалена - Delete
        for i := 0 to 50 do                                                     // Запись открыта в окне для изменения - Select
        begin                                                                   // Окно редактирования закрыто: Ок/Отмена - Refresh (-Select-)
          if (FCRC[i].ObjClass = FBuffer[FEnd].ObjClass) and (FCRC[i].ObjSubType = FBuffer[FEnd].ObjSubType) and (FCRC[i].Comm = CurrStr) then
          begin
            FBuffer[FEnd].CRC := FCRC[i].CRCSQL;
            FBuffer[FEnd].SQL := FCRC[i].Text;
            f := true;
            break;
          end;
        end;
        if not f then
        begin
          FBuffer[FEnd].CRC := 0;
          FBuffer[FEnd].SQL := '-';
        end;
      finally
        FCRCCS.Leave;
      end;

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
      FBuffer[FEnd].CRC := 0;
      FBuffer[FEnd].SQL := '-';
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

procedure TgdLogClient.GetCRCSQL(const AText, AnObjectClassName: String);
var
  ObjClass: String[40];
  ObjSubType: String[31];
  Text: String;
  CRCSQL: Integer;
  PL, PR, L, i: Integer;
  f: Boolean;
  Comm: String[6];
begin
  PL := Pos('(', AnObjectClassName);
  PR := Pos(')', AnObjectClassName);
  if PL = 1 then
    ObjClass := ''
  else
    ObjClass := Copy(AnObjectClassName, 1, PL - 1);
  if ((PR - PL) = 1) then
    ObjSubType := ''
  else
    ObjSubType := Copy(AnObjectClassName, PL + 1, PR - 1);
  Text := AText;
  L := Length(Text);
  CRCSQL := CRC32_P(@Text[1], L, 0);
  Comm := UpperCase(Copy(Trim(Text), 1, 6));

  FCRCCS.Enter;
  try
    f := false;
    for i := 0 to 50 do      // как различить select и refresh?
    begin                    // (+ UPDATE OR INSERT - ?)
      if (FCRC[i].ObjClass = ObjClass)
          and (FCRC[i].ObjSubType = ObjSubType)
          and (FCRC[i].Comm = Comm) then
      begin
        FCRC[i].Text := Text;
        FCRC[i].CRCSQL := CRCSQL;
        f := true;
        break;
      end;
    end;
    if not f then
    begin
      if FCRCI = 50 then
        FCRCI := 0
      else
        Inc(FCRCI);
      FCRC[FCRCI].ObjClass := ObjClass;
      FCRC[FCRCI].ObjSubType := ObjSubType;
      FCRC[FCRCI].Text := Text;
      FCRC[FCRCI].Comm := Comm;
      FCRC[FCRCI].CRCSQL := CRCSQL;
    end;
  finally
    FCRCCS.Leave;
  end;

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
