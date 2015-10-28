unit gedemin_cc_TCPServer_unit;

interface

uses
  Classes, Controls, Forms, SysUtils, FileCtrl, StdCtrls,
  Menus, ExtCtrls, ComCtrls, IdTCPConnection, IdTCPServer, IdSocketHandle,
  IdThreadMgr, IdThreadMgrDefault, IdBaseComponent,
  IdComponent, IdAntiFreezeBase, IdAntiFreeze, IdStack;

const
  MaxBufferSize = 1024;
  MaxMsgLength = 255;

type
  TClient = class (TObject) //record
    ID: Integer;
    IP: String[15];
    Host: String[30];
    Connected: TDateTime;
    LastTrans: TDateTime;
  end;

  TLogRec = record
    Command: String[50];
    ID: Integer;
    IP: String[15];
    Host: String[20];
    DT: TDateTime;
    Msg: String[MaxMsgLength];
  end;

  TInitPar = record
    Command: String[50];
    ID: Integer;
  end;

  TccTCPServer = class(TObject)
  protected
    FTCPServer: TIdTCPServer;
    FClients: TThreadList;
    FThreadMgr: TIdThreadMgrDefault;
    FIdAntiFreeze: TIdAntiFreeze;

    procedure FTCPServerConnect(AThread: TIdPeerThread);
    procedure FTCPServerDisconnect(AThread: TIdPeerThread);
    procedure FTCPServerExecute(AThread: TIdPeerThread);
    procedure Refresh;

  public
    FBuffer: array[0..MaxBufferSize - 1] of TLogRec;
    FStart, FEnd: Integer;
    FCount: Integer;

    constructor Create;
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
  end;

var
  ccTCPServer: TccTCPServer;

implementation

uses
  gedemin_cc_DataModule_unit, gedemin_cc_frmMain_unit;

constructor TccTCPServer.Create;
begin
  FClients := TThreadList.Create;

  FTCPServer := TIdTCPServer.Create(nil);
  FTCPServer.OnConnect := FTCPServerConnect;
  FTCPServer.OnExecute := FTCPServerExecute;
  FTCPServer.OnDisconnect := FTCPServerDisconnect;
  FTCPServer.DefaultPort := 27070;
end;

destructor TccTCPServer.Destroy;
begin
  FTCPServer.Free;
  FClients.Free;
  inherited;
end;

procedure TccTCPServer.Connect;
begin
  FTCPServer.Active := True;
end;

procedure TccTCPServer.Disconnect;
begin
  Assert(FTCPServer <> nil);
  FTCPServer.Active := False;
end;

procedure TccTCPServer.FTCPServerConnect(AThread: TIdPeerThread);
begin
  //
end;

procedure TccTCPServer.FTCPServerDisconnect(AThread: TIdPeerThread);
begin
  //
end;

procedure TccTCPServer.FTCPServerExecute(AThread: TIdPeerThread);
const // составить список сообщений, а не это
  INIT = 1;
  RUN = 2;
  DONE = 3;
  REC = 4;
var
  LogRec: TLogRec;
  DTRec: String;
  FClient: TClient;
  Comm: Integer;
  InitPar: TInitPar;
  i: Integer;
begin
  // создает ли сервер еще одну нить, если запущено более
  // 1 экземпл€ра клиента на одном и том же компьютере?
  Assert(FClients <> nil);

  if not AThread.Terminated and AThread.Connection.Connected then
  begin
    Comm := StrToInt(AThread.Connection.ReadLn());
    // PostThreadMessage(ThreadID, Comm, 0, 0); ???
    case Comm of
      INIT:
      begin
        Inc(FCount);
        InitPar.ID := FCount;
        InitPar.Command := 'INIT_SUCCESS';
        AThread.Connection.WriteBuffer(InitPar, SizeOf(InitPar));
      end;

      RUN:
      begin
        AThread.Connection.ReadBuffer(LogRec, SizeOf(LogRec));
        Assert(FClients <> nil);

        FClient.ID := LogRec.ID;
        FClient.IP := LogRec.IP;
        FClient.Host := LogRec.Host;
        FClient.Connected := LogRec.DT;
        FClient.LastTrans := LogRec.DT;

        try
          FClients.LockList.Add(FClient);
        finally
          FClients.UnlockList;
        end;

        Refresh;

        AThread.Connection.WriteLn('REC');
      end;

      DONE:
      begin
        AThread.Connection.ReadBuffer(LogRec, SizeOf(LogRec));
        Assert(FClients <> nil);
        // определить клиент дл€ удалени€
        FClient.ID := LogRec.ID;
        FClient.IP := LogRec.IP;
        FClient.Host := LogRec.Host;
        FClient.Connected := LogRec.DT;
        FClient.LastTrans := LogRec.DT;

        for i := 0 to FClients.LockList.Count - 1 do
        begin
          if FClients.LockList.Items[i] = FClient then
          begin
            try
              FClients.LockList.Remove(FClient);
            finally
              FClients.UnlockList;
            end;
            Refresh;
          end;
        end;
      end;

      REC:
      begin
        try
          if (FEnd = MaxBufferSize) and (FStart > 0) then
            FEnd := 0;
          if (FEnd < MaxBufferSize) or (FEnd < FStart) then
          begin
            AThread.Connection.ReadBuffer(LogRec, SizeOf(LogRec));
            FBuffer[FEnd] := LogRec;
          end;
          Inc(FEnd);
          DTRec := DateTimeToStr(LogRec.DT);
          frm_gedemin_cc_main.mLog.Lines.Add(DTRec + ' | ' + LogRec.Host + '  >>  ' + LogRec.Msg);
         finally
           //AThread.Connection.Disconnect;
           DM.InsertDB;
           DM.UpdateGrid;
         end;
      end;
    else
      //
    end;
  end
  else
    frm_gedemin_cc_main.mLog.Lines.Add('Not connected');
end;

procedure TccTCPServer.Refresh;
var
  FClient: TClient;
  I: Integer;
begin
  Assert(FClients <> nil);
  try
    frm_gedemin_cc_main.lbClients.Clear;
    with FClients.LockList do
    begin
      for I := 0 to Count - 1 do
      begin
        FClient := Items[I];
        frm_gedemin_cc_main.lbClients.Items.AddObject(FClient.Host, TObject(FClient));
      end;
    end;
  finally
    FClients.UnlockList;
  end;
end;

initialization
  ccTCPServer := TccTCPServer.Create;

finalization
  FreeAndNil(ccTCPServer);
end.
