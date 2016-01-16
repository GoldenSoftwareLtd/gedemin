unit gedemin_cc_TCPServer_unit;

interface

uses
  Classes, Controls, Forms, SysUtils, FileCtrl, StdCtrls,
  Menus, ExtCtrls, ComCtrls, IdTCPConnection, IdTCPServer, IdSocketHandle,
  IdThreadMgr, IdThreadMgrDefault, IdBaseComponent,
  IdComponent, IdAntiFreezeBase, IdAntiFreeze, IdStack,
  Windows, SyncObjs, gedemin_cc_const{, IdSSLOpenSSL, IdServerIOHandler};

type
  TClientP = ^TClient;

  TccTCPServer = class(TObject)
  private
    FCount: Integer;
    FCurrStr: String;
    FRefLBHandle: THandle;
    FRefMemoHandle: THandle;
    FInsDBHandle: THandle;
    FUpdDSHandle: THandle;
    FRefGrHandle: THandle;
    FCriticalSection: TCriticalSection;

    FTCPServer: TIdTCPServer;

    //SSLIOHandler: TIdServerIOHandlerSSL;

    procedure OnTCPServerExecute(AThread: TIdPeerThread);
    procedure ClientsAdd;
    procedure ClientsRemove;

    //procedure IdServerIOHandlerSSLGetPassword(var Password: String);

  public
    FBuffer: array[0..MaxBufferSize - 1] of TLogRecord;
    FStart, FEnd, FID: Integer;
    FClients: TThreadList;
    FDone, FDoneAll: Boolean;

    constructor Create;
    destructor Destroy; override;

    procedure Update;

    property RefLBHandle: THandle read FRefLBHandle write FRefLBHandle;
    property RefMemoHandle: THandle read FRefMemoHandle write FRefMemoHandle;
    property InsDBHandle: THandle read FInsDBHandle write FInsDBHandle;
    property UpdDSHandle: THandle read FUpdDSHandle write FUpdDSHandle;
    property RefGrHandle: THandle read FRefGrHandle write FRefGrHandle;
  end;

var
  ccTCPServer: TccTCPServer;
  FClientP: TClientP;
  CArr: array of TIdPeerThread;

implementation

uses
  gedemin_cc_DataModule_unit;

constructor TccTCPServer.Create;
{var
  appDir: String;}
begin
  FCount := 0;
  FCriticalSection := TCriticalSection.Create;
  FClients := TThreadList.Create;
  FTCPServer := TIdTCPServer.Create(nil);

  {SSLIOHandler := TIdServerIOHandlerSSL.Create(FTCPServer);
  SSLIOHandler.SSLOptions.Method := sslvTLSv1;
  SSLIOHandler.SSLOptions.Mode := sslmServer;
  SSLIOHandler.SSLOptions.VerifyMode := [];
  SSLIOHandler.SSLOptions.VerifyDepth := 0;
  SSLIOHandler.OnGetPassword := IdServerIOHandlerSSLGetPassword;

  appDir := ExtractFilePath(Application.ExeName);
  SSLIOHandler.SSLOptions.KeyFile := appDir + 'sample.key';
  SSLIOHandler.SSLOptions.CertFile := appDir + 'sample.crt';
  SSLIOHandler.SSLOptions.RootCertFile := appDir + 'sampleRoot.pem';

  FTCPServer.IOHandler := SSLIOHandler;}

  FTCPServer.OnExecute := OnTCPServerExecute;
  FTCPServer.DefaultPort := DefaultPort;
  FTCPServer.Active := True;
  FDone := false;
end;

destructor TccTCPServer.Destroy;
begin
  Assert(FTCPServer <> nil);
  FTCPServer.Active := False;
  //SSLIOHandler.Free;
  FTCPServer.Free;
  FClients.Free;
  FCriticalSection.Free;
  inherited;
end;

{procedure TccTCPServer.IdServerIOHandlerSSLGetPassword(var Password: String);
begin
  Password:= 'aaaa';
end;}

procedure TccTCPServer.Update;
begin
  if FUpdDSHandle <> 0 then
    PostMessage(FUpdDSHandle, WM_CC_UPDATE_DS, 0, 0);
  if FRefGrHandle <> 0 then
    PostMessage(FRefGrHandle, WM_CC_REFRESH_GRID, 0, 0);
end;

procedure TccTCPServer.ClientsAdd;
begin
  try
    FClients.LockList.Add(FClientP);
  finally
    FClients.UnlockList;
  end;
end;

procedure TccTCPServer.ClientsRemove;
begin
  try
    FClients.LockList.Remove(FClientP);
  finally
    FClients.UnlockList;
  end;
end;

procedure TccTCPServer.OnTCPServerExecute(AThread: TIdPeerThread);
var
  LogRec: TLogRecord;
  DTRec: String;
  FClientR: TClient;
  Comm, i: Integer;
  InitPar, ConnPar: TParam;
  RecThread: TIdPeerThread;
  RecClient: TClientP;
begin
  Assert(FClients <> nil);
  RecThread := nil;
  if not AThread.Terminated and AThread.Connection.Connected then
  begin
    AThread.Connection.ReadBuffer(ConnPar, SizeOf(ConnPar));
    Comm := ConnPar.Command;
    case Comm of
      CC_INIT:
      begin
        Inc(FCount);
        InitPar.ID := FCount;
        InitPar.Command := CC_INIT_SUCCESS;
        AThread.Connection.WriteBuffer(InitPar, SizeOf(InitPar));
      end;

      CC_RUN:
      begin
        AThread.Connection.ReadBuffer(FClientR, SizeOf(FClientR));
        Assert(FClients <> nil);

        New(FClientP);
        FClientP^ := FClientR;
        FClientP.Thread := AThread;
        //AThread.Data := TObject(FClientP);
        ClientsAdd;

        if FRefLBHandle <> 0 then
          PostMessage(FRefLBHandle, WM_CC_REFRESH_LB, 0, 0);

        ConnPar.ID := FClientP.ID;
        ConnPar.Command := CC_REC_NOW;
        ConnPar.Done := false;

        AThread.Connection.WriteBuffer(ConnPar, SizeOf(ConnPar), true);
      end;

      CC_REC:
      begin
        try
          FCriticalSection.Enter;
          try
            if (FEnd = MaxBufferSize) and (FStart > 0) then
              FEnd := 0;
            if (FEnd < MaxBufferSize) or (FEnd < FStart) then
            begin
              AThread.Connection.ReadBuffer(LogRec, SizeOf(LogRec));
              FBuffer[FEnd] := LogRec;
            end;
            Inc(FEnd);
          finally
            FCriticalSection.Leave;
          end;
          DTRec := DateTimeToStr(LogRec.DTAct);
          FCurrStr := DTRec + ' | ' + LogRec.IP + ' / ' + LogRec.Host + ' :: ' + LogRec.OSName + '  >>  ' + LogRec.UserName + ' -> ' + LogRec.Msg
                   + ' (' + LogRec.ObjClass + ' / ' + LogRec.ObjSubType + ', ' + IntToStr(LogRec.ObjID) + ')' + ' /// ' + LogRec.DBFileName;
          if FRefMemoHandle <> 0 then
            SendMessage(FRefMemoHandle, WM_CC_REFRESH_MEMO, 0, Integer(PChar(FCurrStr)));
          if FInsDBHandle <> 0 then
            PostMessage(FInsDBHandle, WM_CC_INSERT_DB, 0, 0);
          if FUpdDSHandle <> 0 then
            PostMessage(FUpdDSHandle, WM_CC_UPDATE_DS, 0, 0);
          if FRefGrHandle <> 0 then
            PostMessage(FRefGrHandle, WM_CC_REFRESH_GRID, 0, 0);
        finally
          if (LogRec.Msg = GDDone) then
          begin
            if AThread.Connection.Connected then
              AThread.Connection.Disconnect;
          end
          else
          begin
            //FCriticalSection.Enter;
            //try
              if FDone then // переделать этот код
              begin
                with FClients.LockList do
                try
                  if Count > 0 then
                  begin
                    for i := 0 to Count - 1 do
                    begin
                      RecClient := Items[i];
                      if RecClient.ID = FID then
                      begin
                        RecThread := RecClient.Thread;
                      end;
                    end;
                  end;
                finally
                  FClients.UnlockList;
                end;
              end;
            //finally
              //FCriticalSection.Leave;
            //end;

            if FDoneAll and (CArr = nil) then //
            begin
              with FClients.LockList do
              try
                if Count > 0 then
                begin
                  SetLength(CArr, Count);
                  for i := 0 to Count - 1 do
                  begin
                    RecClient := Items[i];
                    CArr[i] := RecClient.Thread;
                  end;
                end;
              finally
                FClients.UnlockList;
              end;
            end;

            if CArr <> nil then //
            begin
              for i := 0 to High(CArr) do
              begin
                if CArr[i] = AThread then
                  RecThread := CArr[i];
              end;
            end;

            ConnPar.Command := CC_REC_NOW;
            if RecThread = AThread then
            begin
              FCriticalSection.Enter;
              try
                ConnPar.Done := true;
                RecThread.Connection.WriteBuffer(ConnPar, SizeOf(ConnPar), true);
                FDone := false;
              finally
                FCriticalSection.Leave;
              end;
            end
            else
            begin
              ConnPar.Done := false;
              AThread.Connection.WriteBuffer(ConnPar, SizeOf(ConnPar), true);
            end;

            with FClients.LockList do //
            begin
              try
                if Count = 0 then
                begin
                  FDoneAll := false;
                  CArr := nil;
                end;
              finally
                FClients.UnlockList;
              end;
            end;
            
          end;
        end;
      end;

      CC_DONE:
      begin
        AThread.Connection.ReadBuffer(FClientR, SizeOf(FClientR));
        Assert(FClients <> nil);                                       

        FClientP^ := FClientR;
        FClientP.Thread := AThread;
        //AThread.Data := TObject(FClientP);

        ClientsRemove;

        if FRefLBHandle <> 0 then
          PostMessage(FRefLBHandle, WM_CC_REFRESH_LB, 0, 0);

        ConnPar.Command := CC_REC_NOW;
        ConnPar.Done := false;

        AThread.Connection.WriteBuffer(ConnPar, SizeOf(ConnPar), true);
      end;

    else
      // неизвестная команда
    end;
  end
  else
  begin
    FCurrStr := 'Отсутствует соединение';
    if FRefMemoHandle <> 0 then
      SendMessage(FRefMemoHandle, WM_CC_REFRESH_MEMO, 0, Integer(PChar(FCurrStr)));
  end;
end;

initialization
  ccTCPServer := TccTCPServer.Create;

finalization
  FreeAndNil(ccTCPServer);
end.
