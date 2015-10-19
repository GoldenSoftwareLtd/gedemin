unit gedemin_cc_frmMain_unit;

interface

uses
  Classes, Controls, Forms, SysUtils, FileCtrl, StdCtrls,
  Menus, ExtCtrls, ComCtrls, Grids, DBGrids, Db,
  IdTCPConnection, IdTCPServer, IdSocketHandle,
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

  Tfrm_gedemin_cc_main = class(TForm)
    pnlTop: TPanel;
    pnlLeft: TPanel;
    pnlRight: TPanel;
    pnlBottom: TPanel;
    pnlCenter: TPanel;
    pnlFilt: TPanel;
    mLog: TMemo;
    lbClients: TListBox;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    DBGrid1: TDBGrid;
    SB: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private

  protected
    FTCPServer: TIdTCPServer;
    FThreadMgr: TIdThreadMgrDefault;
    FIdAntiFreeze: TIdAntiFreeze;
    procedure FTCPServerConnect(AThread: TIdPeerThread);
    procedure FTCPServerDisconnect(AThread: TIdPeerThread);
    procedure FTCPServerExecute(AThread: TIdPeerThread);
    procedure Connect;
    procedure Disconnect;
    procedure Refresh;
    procedure AddMsgArr;
    procedure AddMsgDB;
  public
    FBuffer: array[0..MaxBufferSize - 1] of TLogRec;
    FStart, FEnd: Integer;
  end;

var
  frm_gedemin_cc_main: Tfrm_gedemin_cc_main;
  Clients: TThreadList;

implementation

uses
  gedemin_cc_DataModule_unit;

{$R *.DFM}

procedure Tfrm_gedemin_cc_main.FormCreate(Sender: TObject);
begin
  SB.Panels[0].Text := DM.IBDB.DatabaseName;
  Connect;
end;

procedure Tfrm_gedemin_cc_main.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Disconnect;
end;

procedure Tfrm_gedemin_cc_main.Connect;
begin
  FTCPServer := TIdTCPServer.Create(nil);
  FTCPServer.DefaultPort := 27070;
  FTCPServer.Active := True;

  FTCPServer.OnConnect := FTCPServerConnect;
  FTCPServer.OnExecute := FTCPServerExecute;
  FTCPServer.OnDisconnect := FTCPServerDisconnect;
  
  Clients := TThreadList.Create;
end;

procedure Tfrm_gedemin_cc_main.Disconnect;
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

procedure Tfrm_gedemin_cc_main.FTCPServerConnect(AThread: TIdPeerThread);
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

procedure Tfrm_gedemin_cc_main.FTCPServerDisconnect(AThread: TIdPeerThread);
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

procedure Tfrm_gedemin_cc_main.FTCPServerExecute(AThread: TIdPeerThread);
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
        FClient.LastTrans := Now;
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
        mLog.Lines.Add(DTRec + ' | ' + LogRec.ClientName + ' (' + FClient.Host + ')' + ' | ' + FClient.IP + '  >>  ' + LogRec.Msg);
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
    mLog.Lines.Add('Not connected');
end;

procedure Tfrm_gedemin_cc_main.Refresh;
var
  FClient: TClient;
  I: Integer;
begin
  try
    lbClients.Clear;
    with Clients.LockList do
    begin
      for I := 0 to Count - 1 do
      begin
        FClient := Items[I];
        lbClients.Items.AddObject(FClient.Host, FClient);
      end;
    end;
  finally
    Clients.UnlockList;
  end;
end;

procedure Tfrm_gedemin_cc_main.AddMsgArr;
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

procedure Tfrm_gedemin_cc_main.AddMsgDB;
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

end.
