unit gdLogClient;

interface

uses
  Classes, Dialogs, Windows, gdMessagedThread, IdTCPConnection, IdTCPClient;

type
  TgdLogClient = class(TgdMessagedThread)
  private
    { Private declarations }
    //FHost: String;
    //FPort: Integer;
    //FMesS: String;

  protected
    TCPClient: TIdTCPClient;
    function ProcessMessage(var Msg: TMsg): Boolean; override;

    //procedure DoWorkLog;
    //procedure DoWorkClient;
    //procedure ShowMesS;

  public
    constructor Create;
    destructor Destroy; override;
    
    procedure Start;
    procedure Finish;
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
end;

destructor TgdLogClient.Destroy;
begin
  inherited;
end;

function TgdLogClient.ProcessMessage(var Msg: TMsg): Boolean;
begin
  Result := True;

  case Msg.Message of

    WM_LOG_INIT:
    begin
    end;

    WM_LOG_DONE:
    begin
    end

  else
    Result := False;
  end;
end;

procedure TgdLogClient.Start;
begin
  PostMsg(WM_LOG_INIT);
end;

procedure TgdLogClient.Finish;
begin
  PostMsg(WM_LOG_DONE);
end;

{
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
    TCPClient := TIdTCPClient.Create(nil);
    TCPClient.Host := FHost;
    TCPClient.Port := FPort;
    while True do
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
}

initialization
  gdLog := TgdLogClient.Create;
  gdLog.Resume;

finalization
  FreeAndNil(gdLog);
end.
