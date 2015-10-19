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
  TLogRec = record
    Command: String[50];
    ClientName: String[20];
    DT: TDateTime;
    Msg: String[MaxMsgLength];
  end;

  TClient = class(TObject) // или record?
    IP: String;
    Host: String;
    Connected: TDateTime;
    LastTrans: TDateTime;
    Thread: Pointer;
  end;

  Tgedemin_cc_TCPServer = class(TObject)
    protected
      FTCPServer: TIdTCPServer;
      FThreadMgr: TIdThreadMgrDefault;
      FIdAntiFreeze: TIdAntiFreeze;
      procedure FTCPServerConnect(AThread: TIdPeerThread);
      procedure FTCPServerDisconnect(AThread: TIdPeerThread);
      procedure FTCPServerExecute(AThread: TIdPeerThread);
      procedure Refresh;
      procedure AddMsgArr;
      procedure AddMsgDB;
    public
      FBuffer: array[0..MaxBufferSize - 1] of TLogRec;
      FStart, FEnd: Integer;
      procedure Connect;
      procedure Disconnect;
  end;

var
  gedemin_cc_TCPServer: Tgedemin_cc_TCPServer;
  Clients: TThreadList;

implementation

uses
  gedemin_cc_DataModule_unit, gedemin_cc_frmMain_unit;

procedure Tgedemin_cc_TCPServer.Connect;
begin
  FTCPServer := TIdTCPServer.Create(nil);
  FTCPServer.DefaultPort := 27070;
  FTCPServer.Active := True;

  FTCPServer.OnConnect := FTCPServerConnect;
  FTCPServer.OnExecute := FTCPServerExecute;
  FTCPServer.OnDisconnect := FTCPServerDisconnect;
  
  Clients := TThreadList.Create;
end;

procedure Tgedemin_cc_TCPServer.Disconnect;
var
  List: TList;
  I: Integer;
begin
  List := FTCPServer.Threads.LockList;
  try
    Application.ProcessMessages;
    for I := 0 to List.Count - 1 do
    begin
      try
        TIdPeerThread(List.Items[I]).Connection.Disconnect;
      except
        on E: Exception do
        begin
          TIdPeerThread(List.Items[I]).Stop;
        end;
      end;
    end;
  finally
    FTCPServer.Threads.UnlockList;
  end;
  //Sleep(FTCPServer.TerminateWaitTime);

  FTCPServer.Active := False;
  FreeAndNil(FTCPServer);
  FreeAndNil(Clients);
end;

procedure Tgedemin_cc_TCPServer.FTCPServerConnect(AThread: TIdPeerThread);
var
  FClient: TClient;
begin
  FClient := TClient.Create;
  FClient.IP := AThread.Connection.Socket.Binding.PeerIP;
  FClient.Host := GStack.WSGetHostByAddr(FClient.IP);
  FClient.Connected := Now;
  FClient.LastTrans := Now;
  FClient.Thread := AThread;

  AThread.Data := TClient(FClient);

  try
    Clients.LockList.Add(FClient);
  finally
    Clients.UnlockList;
  end;
end;

procedure Tgedemin_cc_TCPServer.FTCPServerDisconnect(AThread: TIdPeerThread);
var
  FClient: TClient;
begin
  FClient := TClient(AThread.Data);

  try
    Clients.LockList.Remove(FClient);
  finally
    Clients.UnlockList;
  end;

  FClient.Free;
  AThread.Data := nil;
end;

procedure Tgedemin_cc_TCPServer.FTCPServerExecute(AThread: TIdPeerThread);
var
  FClient: TClient;   
  LogRec: TLogRec;
  DTRec: String;
  //Msg, Sub: String;
begin
  // создает ли сервер еще одну нить, если запущено более 1
  // экземпл€ра клиента на одном и том же компьютере?
  // при запуске в списке только 1 клиент
  // при закрытии любого экземпл€ра он удал€етс€
  // хот€ на каждое подключение должна создаватьс€ отдельна€ нить

  FClient := TClient(AThread.Data);
  if not AThread.Terminated and AThread.Connection.Connected then
  begin
    try
      if (FEnd = MaxBufferSize) and (FStart > 0) then
        FEnd := 0;
      if (FEnd < MaxBufferSize) or (FEnd < FStart) then
      begin
        AThread.Connection.ReadBuffer (LogRec, SizeOf (LogRec));
        FBuffer[FEnd] := LogRec;
        FClient.LastTrans := Now; // CommandHandler?
        if LogRec.Command = 'RUN' then // √едымин запущен
          Refresh
        else begin
          if LogRec.Command = 'DONE' then // √едымин закрыт
          begin
            try
              Clients.LockList.Remove(FClient);
            finally
              Clients.UnlockList;
            end;
            Refresh; // из списка должен удалитьс€ закрытый клиент
          end
          else begin // ƒругое действие в √едымине
            //
          end;
        end;
        Inc(FEnd);
        DTRec := DateToStr(LogRec.DT) + ', ' + TimeToStr(LogRec.DT);

        frm_gedemin_cc_main.mLog.Lines.Add(DTRec + ' | ' + LogRec.ClientName + ' (' + FClient.Host + ')' + ' | ' + FClient.IP + '  >>  ' + LogRec.Msg);
      end;

      {Msg := AThread.Connection.ReadLn; // запись в массив
      mLog.Lines.Add(FClient.Host + ' | ' + FClient.IP + '  >>  ' + Msg);
      Sub := Copy(Msg,22,Length(Msg)); // зависит от формата даты и времени, переписать (стандартизировать формат)
      if Sub = '√едымин запущен' then
        Refresh;
      if Sub = '√едымин закрыт' then // из списка должен удалитьс€ только закрытый клиент
      begin
        try
          Clients.LockList.Remove(FClient);
        finally
          Clients.UnlockList;
        end;
        Refresh;
      end;}

    finally
      AThread.Connection.Disconnect;
    end;
  end
  else
    frm_gedemin_cc_main.mLog.Lines.Add('Not connected');
end;

procedure Tgedemin_cc_TCPServer.Refresh;
var
  FClient: TClient;
  I: Integer;
begin
  try
    frm_gedemin_cc_main.lbClients.Clear;
    with Clients.LockList do
    begin
      for I := 0 to Count - 1 do
      begin
        FClient := Items[I];
        frm_gedemin_cc_main.lbClients.Items.AddObject(FClient.Host, FClient);
      end;
    end;
  finally
    Clients.UnlockList;
  end;
end;

procedure Tgedemin_cc_TCPServer.AddMsgArr;
begin
  //
  if (FEnd = MaxBufferSize) and (FStart > 0) then
    FEnd := 0;
  if (FEnd < MaxBufferSize) or (FEnd < FStart) then
  begin
    // запись в массив
    Inc(FEnd);
  end;
end;

procedure Tgedemin_cc_TCPServer.AddMsgDB;
begin
  //
  while FStart <> FEnd do
  begin
    // запись в Ѕƒ
    
    if FStart = MaxBufferSize - 1 then
      FStart := 0
    else
      Inc(FStart);
  end;
end;

initialization
  gedemin_cc_TCPServer := Tgedemin_cc_TCPServer.Create;

finalization
  FreeAndNil(gedemin_cc_TCPServer);

end.
