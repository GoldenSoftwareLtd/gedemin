unit gdLogClient;

interface

uses
  Classes, Dialogs, Windows, gdMessagedThread, IdTCPConnection, IdTCPClient;

type
  TgdLogClient = class(TgdMessagedThread)
  private
    { Private declarations }
    FHost: String;
    FPort: Integer;
    FMesS: String;

  protected
    Client: TIdTCPClient;
    procedure Execute; override;
    procedure DoWorkLog;
    procedure DoWorkClient;
    procedure ShowMesS;

  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  gdLog: TgdLogClient;

implementation

uses
  SysUtils;

constructor TgdLogClient.Create;
begin
  inherited Create(True);
  Priority := tpLowest;
end;

destructor TgdLogClient.Destroy;
begin
  gdLog.Free;
  inherited;
end;

procedure TgdLogClient.Execute;
begin
  Synchronize(DoWorkLog);
  DoWorkClient;
end;

procedure TgdLogClient.DoWorkLog;
begin
  ShowMessage('gdLog run');

  // Нужно задать реальный хост и порт сервера
  FHost := '127.0.0.1';
  FPort := 7070;
end;

procedure TgdLogClient.DoWorkClient;
begin
  try
    Client := TIdTCPClient.Create(nil);
    Client.Host := FHost;
    Client.Port := FPort;
    while True do
    begin
      with Client do
      begin
        if Terminated then Exit;
        try
          Connect;
          try
            if Terminated then Exit;
            FMesS := ReadLn;
            Synchronize(ShowMesS);
          finally
            Disconnect;
          end; // try finally
        except
          Exit;
          //on E: Exception do MessageBox(0, PChar('Ошибка при подключении к серверу: ' + E.Message), 'Ошибка', MB_OK or MB_TASKMODAL or MB_ICONHAND);
        end; // try except
        if Terminated then Exit;
        sleep(3000);
      end; // with
    end; // while True
  except
    //
    Exit;
  end; // try except
end;

procedure TgdLogClient.ShowMesS;
begin
  ShowMessage(FMesS);
end;

initialization
  gdLog := TgdLogClient.Create;
  gdLog.Resume;

finalization
  FreeAndNil(gdLog);      
end.
