// ShlTanya, 17.02.2019

{++

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Module

    gsDatabaseShutdown.pas,
    gsDatabaseShutdown_dlgShowUsers_unit.pas, *.dfm

  Abstract

    Кампанэнт прызначаны для пераводу базы дадзеных у стан Шатдаун.
    Увага! Перавесці ў Шатдаўн можа толькі СЫСДБА, альбо Ўладальнік --
    карыстальнік, які стварыў базу.

    Кампанэнт падключаецца да кампанэнта базы дадзеных і атрымлівае
    адтуль усю інфармацыю для падключэньня да базы дадзеных.

    Мае ўласцівасці: Колькасць актыўных карыстальнікаў.

    Мае метад для пераводу базы ў стан Шатдаўн. Вяртае Ісціна, калі
    база паспяхова пераведзена, 0 -- у адваротным выпадку.

    Мае ўласцівасць, ці выводзіць дыялог са сьпісам падключаных карыстальнікаў
    перад адключэньнем.

    Мае уласьцівасьць ці знаходзіцца база ў стане Шатдаўн.

    Івент OnGetUserName дазваляе замяніць імя карыстальніка ІБ на
    імя, напрыклад, чалавека, які стаіць за гэтым карыстальнікам. 

  Author

    Andrei Kireev (05-Nov-2000)

  Revisions history

    1.00    05-Nov-2000    andreik    Initial version.
    1.01    08-Jan-2001    denis      BringOnline method added.

--}

unit gsDatabaseShutdown;

interface

uses
  Classes, IBDatabase, IBServices;

type
  TOnGetUserNameEvent = procedure(var UserName: String) of object;

  TgsDatabaseShutdown = class(TComponent)
  private
    FDatabase: TIBDatabase;
    FShowUserDisconnectDialog: Boolean;
    FConfigService: TIBConfigService;

    procedure SetDatabase(const Value: TIBDatabase);
    function GetShutdownCode: Integer;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function Shutdown: Boolean;
    function BringOnline: Boolean;

  published
    property Database: TIBDatabase read FDatabase write SetDatabase;
    property ShowUserDisconnectDialog: Boolean read FShowUserDisconnectDialog
      write FShowUserDisconnectDialog default True;
  end;

implementation

uses
  Windows, IB, IBSQL, SysUtils, at_frmIBUserList,
  gd_common_functions, gd_directories_const
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{ TgsDatabaseShutdown }

constructor TgsDatabaseShutdown.Create(AnOwner: TComponent);
begin
  inherited;
  FConfigService := TIBConfigService.Create(nil);
  FShowUserDisconnectDialog := True;
end;

destructor TgsDatabaseShutdown.Destroy;
begin
  FConfigService.Free;
  inherited;
end;

procedure TgsDatabaseShutdown.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDatabase) then
    FDatabase := nil;
end;

procedure TgsDatabaseShutdown.SetDatabase(const Value: TIBDatabase);
var
  I, Port: Integer;
  SN, DN: String;
begin
  if FDatabase <> Value then
  begin
    if FDatabase <> nil then
      FDatabase.RemoveFreeNotification(Self);
    FDatabase := Value;
    if FDatabase <> nil then
    begin
      FDatabase.FreeNotification(Self);

      ParseDatabaseName(FDatabase.DatabaseName, SN, Port, DN);
      FConfigService.ServerName := SN;
      FConfigService.DatabaseName := DN;
      FConfigService.LoginPrompt := False;

      if SN > '' then
        FConfigService.Protocol := TCP
      else
        FConfigService.Protocol := Local;

      FConfigService.Params.Clear;
      I := FDatabase.Params.IndexOfName(UserNameValue);
      if I > -1 then
        FConfigService.Params.Add(FDatabase.Params[I]);
      I := FDatabase.Params.IndexOfName(PasswordValue);
      if I > -1 then
        FConfigService.Params.Add(FDatabase.Params[I]);
    end;
  end;
end;

function TgsDatabaseShutdown.Shutdown: Boolean;
begin
  Assert(Assigned(FDatabase));

  if FDatabase.Connected then
  begin
    if GetShutdownCode > 0 then
    begin
      Result := True;
      exit;
    end;

    if FShowUserDisconnectDialog then
    begin
      with TfrmIBUserList.Create(nil) do
      try
        if not CheckUsers then
        begin
          Result := False;
          exit;
        end;
      finally
        Free;
      end;
    end;
  end;

  Result := False;
  FConfigService.Active := True;
  try
    try
      FConfigService.ShutdownDatabase(smeForce, 0, omSingle);
      // на классике сервер сразу возвращает выполнение
      // и последующее подключение не пройдет, так как
      // база еще будет выводиться из шатдауна.
      // вроде бы, начиная с версии 2.1 эта пауза уже не
      // будет нужна
      Sleep(4000);
      while FConfigService.IsServiceRunning do Sleep(100);
      Result := True;
    except
      on E: Exception do
        MessageBox(0,
          PChar('Базу данных не удалось перевести в однопользовательский режим.'#13#10#13#10 +
          E.Message),
          'Внимание!',
          MB_OK or MB_ICONHAND or MB_TASKMODAL);
    end;
  finally
    FConfigService.Active := False;
  end;
end;

function TgsDatabaseShutdown.BringOnline: Boolean;
begin
  Assert(FDatabase <> nil);

  if FDatabase.Connected and (GetShutdownCode = 0) then
  begin
    Result := True;
    exit;
  end;

  Result := False;
  FConfigService.Active := True;
  try
    try
      FConfigService.BringDatabaseOnline;
      // на классике сервер сразу возвращает выполнение
      // и последующее подключение не пройдет, так как
      // база еще будет выводиться из шатдауна.
      // вроде бы, начиная с версии 2.1 эта пауза уже не
      // будет нужна
      Sleep(4000);
      while FConfigService.IsServiceRunning do Sleep(100);
      Result := True;
    except
      on E: Exception do
        MessageBox(0,
          PChar('Базу данных не удалось перевести в многопользовательский режим.'#13#10#13#10 +
          E.Message),
          'Внимание!',
          MB_OK or MB_ICONHAND or MB_TASKMODAL);
    end;
  finally
    FConfigService.Active := False;
  end;
end;

function TgsDatabaseShutdown.GetShutdownCode: Integer;
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Assert(FDatabase <> nil);
  Assert(FDatabase.Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text := 'SELECT mon$shutdown_mode FROM mon$database';
    q.ExecQuery;

    Assert(not q.EOF);
    Result := q.Fields[0].AsInteger;
  finally
    q.Free;
    Tr.Free;
  end;
end;

end.

