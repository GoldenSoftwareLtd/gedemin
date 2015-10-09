unit frm_gedemin_cc_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ShellApi, Menus, IdTCPConnection, IdTCPServer,
  IdSocketHandle, IdThreadMgr, IdThreadMgrDefault, IdBaseComponent,
  IdComponent, IdAntiFreezeBase, IdAntiFreeze, IdStack;


type
  TClient = class(TObject) // или record?
    IP: String;
    Host: String;
    Connected: TDateTime;
    //LastTrans: TDateTime;
    Thread: Pointer;
  end;

  Tfrm_gedemin_cc_main = class(TForm)
    mLog: TMemo;
    btSave: TButton;
    SaveDialog1: TSaveDialog;
    ClientsListBox: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btSaveClick(Sender: TObject);

  private

  protected
    FTCPServer: TIdTCPServer;
    FThreadMgr: TIdThreadMgrDefault;
    FIdAntiFreeze: TIdAntiFreeze;
    procedure FTCPServerConnect(AThread: TIdPeerThread);
    procedure FTCPServerDisconnect(AThread: TIdPeerThread);
    procedure FTCPServerExecute(AThread: TIdPeerThread);
    procedure Refresh;
  public

  end;

var
  frm_gedemin_cc_main: Tfrm_gedemin_cc_main;
  Clients: TThreadList;

implementation


{$R *.DFM}

procedure Tfrm_gedemin_cc_main.FormCreate(Sender: TObject);
begin
  FTCPServer := TIdTCPServer.Create(nil);
  FTCPServer.DefaultPort := 27070;
  FTCPServer.Active := True;

  FTCPServer.OnConnect := FTCPServerConnect;
  FTCPServer.OnExecute := FTCPServerExecute;
  FTCPServer.OnDisconnect := FTCPServerDisconnect;

  Clients := TThreadList.Create;
end;

procedure Tfrm_gedemin_cc_main.FormClose(Sender: TObject;
  var Action: TCloseAction);
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
  Msg, Sub: String;
begin
  FClient := TClient(AThread.Data);
  if not AThread.Terminated and AThread.Connection.Connected then
  begin
    try
      Msg := AThread.Connection.ReadLn;
      mLog.Lines.Add(FClient.Host + ' | ' + FClient.IP + '  >>  ' + Msg);
      Sub := Copy(Msg,24,Length(Msg));
      if Sub = 'Гедымин запущен' then
        Refresh;
      if Sub = 'Гедымин закрыт' then
        ClientsListBox.Clear;
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
    ClientsListBox.Clear;
    with Clients.LockList do
    begin
      for I := 0 to Count - 1 do
      begin
        FClient := Items[I];
        ClientsListBox.Items.AddObject(FClient.Host, FClient);
      end;
    end;
  finally
    Clients.UnlockList;
  end;
end;

procedure Tfrm_gedemin_cc_main.btSaveClick(Sender: TObject);
var FName: String;
begin
  SaveDialog1.FileName := 'Log';
  if SaveDialog1.Execute then
    begin
      FName := SaveDialog1.FileName;
      mLog.Lines.SaveToFile(FName);
    end;
end;

end.
