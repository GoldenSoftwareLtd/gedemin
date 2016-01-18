unit gdModify;

interface

uses
  Classes, IBDatabase, sysutils;

type
  TModifyLog = procedure(const AnLogText: String) of object;
  TProcAddr = procedure(IBDB: TIBDatabase; Log: TModifyLog);

  EgsWrongServerVersion = class(Exception)
  public
    constructor Create(const Msg: string);
  end;

type
  TgdModify = class(TComponent)
  private
    FIBDatabase: TIBDatabase;
    FDBVersion: String;
    FModifyLog: TModifyLog;
    FShutDownNeeded: Boolean;
    FIBUser, FIBPassword: String;

    procedure SetDatabase(const Value: TIBDatabase);
    function ShutDown: Boolean;
    function BringOnLine: Boolean;
    procedure ReadDBVersion;
    procedure DoModifyLog(const AnLogText: String);

  public
    procedure Execute;
    property IBUser: String read FIBUser write FIBUser;
    property IBPassword: String read FIBPassword write FIBPassword;

  published
    property ShutDownNeeded: Boolean read FShutDownNeeded write FShutDownNeeded;
    property Database: TIBDatabase read FIBDatabase write SetDatabase;
    property OnLog: TModifyLog read FModifyLog write FModifyLog;
  end;

implementation

uses
  mdf_proclist, gsDatabaseShutdown, DbLogDlg, IBSQL, IBStoredProc, Forms;

{ TgdModify }

function TgdModify.BringOnLine: Boolean;
begin
  with TgsDatabaseShutdown.Create(nil) do
  try
    Database := FIBDatabase;
    ShowUserDisconnectDialog := False;
    try
      Result := BringOnline;
    except
      on E: Exception do
      begin
        Application.ShowException(E);
        Result := False;
      end;
    end;
  finally
    Free;
  end;
end;

procedure TgdModify.DoModifyLog(const AnLogText: String);
begin
  if Assigned(FModifyLog) then
    FModifyLog(AnLogText);
end;

procedure TgdModify.Execute;
var
  I: Integer;
  FIBOpened: Boolean;
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  DoModifyLog('Процесс обновления может занять несколько десятков минут.');
  DoModifyLog('Дождитесь его завершения. Не снимайте задачу и не перезагружайте компьютер.');
  DoModifyLog('');

  DoModifyLog('Начат процесс модификации БД');
  FIBOpened := FIBDatabase.Connected;

  if not FIBDatabase.Connected then
  begin
    FIBDatabase.LoginPrompt := False;

    FIBDatabase.Params.Values['user_name'] := FIBUser;
    FIBDatabase.Params.Values['password'] := FIBPassword;
    try
      FIBDatabase.Connected := True;
    except
      FIBDatabase.Params.Values['user_name'] := 'SYSDBA';
      FIBDatabase.Params.Values['password'] := 'masterkey';
    end;

    if not FIBDatabase.Connected then
    begin
      try
        FIBDatabase.Connected := True;
      except
        if not LoginDialogEx(FIBDatabase.DatabaseName, FIBUser, FIBPassword, False) then
          Exit;
        FIBDatabase.Params.Values['user_name'] := FIBUser;
        FIBDatabase.Params.Values['password'] := FIBPassword;
      end;
    end;

    FIBDatabase.Connected := False;
  end;

  try
    if FShutDownNeeded then
      ShutDown;
    try
      FIBDatabase.Connected := True;
      ReadDBVersion;
      try
        try
          for I := 0 to cProcCount - 1 do
            if FDBVersion <= cProcList[I].ModifyVersion then
            begin
              DoModifyLog('>  Номер версии базы данных: ' + cProcList[I].ModifyVersion);
              cProcList[I].ModifyProc(FIBDatabase, DoModifyLog);
            end;
          DoModifyLog('Процесс модификации БД завершен');
        except
          on E: EgsWrongServerVersion do
          begin
            DoModifyLog(E.Message + #13#10 + '  Процесс модификации прерван!');
            raise;
          end;
        else
          raise;
        end;

        if FIBDatabase.Connected then
        begin
          Tr := TIBTransaction.Create(nil);
          q := TIBSQL.Create(nil);
          try
            Tr.DefaultDatabase := FIBDatabase;
            Tr.StartTransaction;

            q.Transaction := Tr;
            q.SQL.Text :=
              'SELECT GEN_ID(gd_g_attr_version, 1) FROM rdb$database';
            q.ExecQuery;

            DoModifyLog('Очищен кэш информации о структуре базы данных.');

            Tr.Commit;
          finally
            q.Free;
            Tr.Free;
          end;
        end;
      finally
        if not FIBOpened and FIBDatabase.Connected then
          FIBDatabase.Connected := False;
      end;
    finally
      if FShutDownNeeded then
        BringOnLine;
    end;
  finally
    if not FIBOpened and FIBDatabase.Connected then
      FIBDatabase.Connected := False;
  end;
end;

procedure TgdModify.ReadDBVersion;
var
  IBSP: TIBStoredProc;
  IBTr: TIBTransaction;
begin
  IBSP := TIBStoredProc.Create(nil);
  try
    IBTr := TIBTransaction.Create(nil);
    try
      IBTr.DefaultDatabase := FIBDatabase;
      IBTr.StartTransaction;
      IBSP.Transaction := IBTr;
      try
        IBSP.StoredProcName := 'FIN_P_VER_GETDBVERSION';
        IBSP.ExecProc;
        FDBVersion := IBSP.ParamByName('versionstring').AsString;
      except
        DoModifyLog('Предупреждение! Невозможно получить версию текущей базы данных');
        FDBVersion := '';
      end;
    finally
      if IBTr.InTransaction then
        IBTr.Commit;
      IBTr.Free;
    end;
  finally
    IBSP.Free;
  end;
  //DoModifyLog('Номер версии исходной базы данных: ' + FDBVersion);
end;

procedure TgdModify.SetDatabase(const Value: TIBDatabase);
begin
  FIBDatabase := Value;
end;

function TgdModify.ShutDown: Boolean;
begin
  with TgsDatabaseShutdown.Create(nil) do
  try
    Database := FIBDatabase;
    ShowUserDisconnectDialog := False;
    Result := Shutdown;
  finally
    Free;
  end;
end;

{ EgsWrongServerVersion }

constructor EgsWrongServerVersion.Create(const Msg: string);
begin
  if Msg <> '' then
    Message := 'Неверная версия сервера, необходимая версия: ' + Msg
  else
    Message := 'Неверная версия сервера';
end;

end.
