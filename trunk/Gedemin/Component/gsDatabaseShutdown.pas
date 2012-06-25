

{++

  Copyright (c) 2000 by Golden Software of Belarus

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
  Classes, IBDatabaseInfo, IBDatabase, IBServices;

type
  TOnGetUserNameEvent = procedure(var UserName: String) of object;

  TgsDatabaseShutdown = class(TComponent)
  private
    FDatabase: TIBDatabase;
    FShowUserDisconnectDialog: Boolean;
    FDatabaseInfo: TIBDatabaseInfo;
    FConfigService: TIBConfigService;
    FStatisticalService: TIBStatisticalService;
    FOnGetUserName: TOnGetUserNameEvent;
    FSL: TStringList;

    function GetUsersCount: Integer;
    procedure SetDatabase(const Value: TIBDatabase);
    function GetIsShutdowned: Boolean;
    function GetUserNames: TStrings;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function Shutdown(const Mode: TShutdownMode = Forced): Boolean;
    function BringOnline: Boolean;
    procedure ShowUsers;

    property UserNames: TStrings read GetUserNames;
    property UsersCount: Integer read GetUsersCount;
    property IsShutdowned: Boolean read GetIsShutdowned;

  published
    property Database: TIBDatabase read FDatabase write SetDatabase;
    property ShowUserDisconnectDialog: Boolean read FShowUserDisconnectDialog
      write FShowUserDisconnectDialog default True;
    property OnGetUserName: TOnGetUserNameEvent read FOnGetUserName write FOnGetUserName;
  end;

implementation

uses
  IB, JclStrings, gsDatabaseShutdown_dlgShowUsers_unit, Forms,
  Controls, Windows, SysUtils, gd_resourcestring, IBErrorCodes
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{ TgsDatabaseShutdown }

constructor TgsDatabaseShutdown.Create(AnOwner: TComponent);
begin
  inherited;
  FDatabaseInfo := TIBDatabaseInfo.Create(Self);
  FConfigService := TIBConfigService.Create(Self);
  FStatisticalService := TIBStatisticalService.Create(Self);
  FShowUserDisconnectDialog := True;
  FSL := TStringList.Create;
end;

destructor TgsDatabaseShutdown.Destroy;
begin
  inherited;
  FSL.Free;
end;

function TgsDatabaseShutdown.GetIsShutdowned: Boolean;
var
  I, P, J: Integer;
  SN, DN, S: String;
begin
  Assert(Assigned(FDatabase));

  Result := False;

  P := Pos(':', FDatabase.DatabaseName);
  if (P > 0) and (Pos(':', Copy(FDatabase.DatabaseName, P + 1, 1024)) > 0) then
    SN := Copy(FDatabase.DatabaseName, 1, P - 1)
  else
    SN := '';

  if SN = '' then
    DN := FDatabase.DatabaseName
  else
    DN := Copy(FDatabase.DatabaseName, Length(SN) + 2, 1024);

  FStatisticalService.ServerName := SN;
  FStatisticalService.DatabaseName := DN;
  if SN > '' then
    FStatisticalService.Protocol := TCP
  else
    FStatisticalService.Protocol := Local;
  FStatisticalService.Params.Text := FDatabase.Params.Text;
  if FStatisticalService.Params.IndexOfName('user_name') = -1 then
    FStatisticalService.Params.Add('user_name=SYSDBA');
  J := 0;
  for I := FStatisticalService.Params.Count - 1 downto 0 do
  begin
    if AnsiCompareText(FStatisticalService.Params.Names[I], 'password') = 0 then
    begin
      Inc(J);
      continue;
    end;
    if AnsiCompareText(FStatisticalService.Params.Names[I], 'user_name') = 0 then
    begin
      Inc(J);
      continue;
    end;
    FStatisticalService.Params.Delete(I);
  end;
  FStatisticalService.LoginPrompt := J <> 2;
  FStatisticalService.Options := [HeaderPages];

  repeat
    try
      FStatisticalService.Active := True;
    except
      on E: EIBError do
      begin
        if E.IBErrorCode = isc_login then
        begin
          FStatisticalService.LoginPrompt := True;
        end else
          raise;
      end;
    end;
  until FStatisticalService.Active;

  FDatabase.Params.Values['user_name'] := FStatisticalService.Params.Values['user_name'];
  FDatabase.Params.Values['password'] := FStatisticalService.Params.Values['password'];

  try
    FStatisticalService.ServiceStart;
    while not FStatisticalService.EOF do
    begin
      S := FStatisticalService.GetNextLine;
      if (StrIPos('shutdown', S) > 0) or (StrIPos('single-user maintenance', S) > 0)
        or (StrIPos('multi-user maintenance', S) > 0) then
      begin
        Result := True;
      end;
    end;
  finally
    FStatisticalService.Active := False;
  end;
end;

function TgsDatabaseShutdown.GetUserNames: TStrings;
var
  I: Integer;
  S: String;
begin
  if Assigned(FOnGetUserName) then
  begin
    FSL.Assign(FDatabaseInfo.UserNames);
    for I := 0 to FSL.Count - 1 do
    begin
      S := FSL[I];
      FOnGetUserName(S);
      FSL[I] := S;
    end;
    Result := FSL;
  end else
    Result := FDatabaseInfo.UserNames;
end;

function TgsDatabaseShutdown.GetUsersCount: Integer;
begin
  Result := FDatabaseInfo.UserNames.Count;
end;

procedure TgsDatabaseShutdown.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDatabase) then
    FDatabase := nil;
end;

procedure TgsDatabaseShutdown.SetDatabase(const Value: TIBDatabase);
begin
  if FDatabase <> Value then
  begin
    if FDatabase <> nil then
      FDatabase.RemoveFreeNotification(Self);
    FDatabase := Value;
    FDatabaseInfo.Database := FDatabase;
    if Value <> nil then
      Value.FreeNotification(Self);
    // кампанэнт FConfigService будзем настраіваць кожным разам
    // перад выкарыстаньнем
  end;
end;

procedure TgsDatabaseShutdown.ShowUsers;
begin
  with TgsDatabaseShutdown_dlgShowUsers.Create(nil) do
  try
    Caption := sgsDatabaseShutdownShowUsersDlgCaption;
    btnOk.Caption := 'Закрыть';
    btnCancel.Visible := False;
    DatabaseShutdown := Self;
    edDatabaseName.Text := FDatabase.DatabaseName;
    Timer.Enabled := True;
    ShowModal;
  finally
    Free;
  end;
end;

function TgsDatabaseShutdown.Shutdown(const Mode: TShutdownMode = Forced): Boolean;
var
  I: Integer;
begin
  Assert(Assigned(FDatabase));

  {
  Result := IsShutdowned;

  if Result then
    exit;
  }

  Result := False;

  if FDatabase.Connected and (UsersCount > 1) and FShowUserDisconnectDialog then
  begin
    with TgsDatabaseShutdown_dlgShowUsers.Create(nil) do
    try
      Caption := sgsDatabaseShutdownShutdownDlgCaption;
      btnOk.Caption := 'Перевести';
      btnCancel.Visible := True;
      DatabaseShutdown := Self;
      edDatabaseName.Text := FDatabase.DatabaseName;
      Timer.Enabled := True;
      if ShowModal = mrCancel then
        exit;
    finally
      Free;
    end;
  end;

  FConfigservice.ServerName := Copy(FDatabase.DatabaseName, 1, Pos(':', FDatabase.DatabaseName) - 1);
  FConfigService.DatabaseName := Copy(FDatabase.DatabaseName, Pos(':', FDatabase.DatabaseName) + 1, 1024);

  if Pos(':', FConfigService.DatabaseName) > 0 then
    FConfigService.Protocol := TCP
  else begin
    FConfigService.Protocol := Local;
    FConfigservice.ServerName := '';
    FConfigService.DatabaseName := FDatabase.DatabaseName;

    Result := True;
    Exit;
  end;

  FConfigService.Params.Text := FDatabase.Params.Text;
  for I := FConfigService.Params.Count - 1 downto 0 do
  begin
    if AnsiCompareText(FConfigService.Params.Names[I], 'password') = 0 then
      continue;
    if AnsiCompareText(FConfigService.Params.Names[I], 'user_name') = 0 then
      continue;
    FConfigService.Params.Delete(I);
  end;
  FConfigService.LoginPrompt := False;

  FConfigService.Active := True;
  try
    try
      FConfigService.ShutdownDatabase(Mode, 0);
      // на классике сервер сразу возвращает выполнение
      // и последующее подключение не пройдет, так как
      // база еще будет выводиться из шатдауна.
      // вроде бы, начиная с версии 2.1 эта пауза уже не
      // будет нужна
      Sleep(4000);
      while FConfigService.IsServiceRunning do Sleep(100);
      Result := True;
    except
      MessageBox(0,
        'Базу данных не удалось перевести в однопользовательский режим.',
        'Внимание!',
        MB_OK or MB_ICONHAND or MB_TASKMODAL);
    end;
  finally
    FConfigService.Active := False;
  end;
end;

function TgsDatabaseShutdown.BringOnline: Boolean;
var
  I, P: Integer;
  SN, DN: String;
begin
  Result := not IsShutdowned;

  if not Result then
  begin
    P := Pos(':', FDatabase.DatabaseName);
    if (P > 0) and (Pos(':', Copy(FDatabase.DatabaseName, P + 1, 1024)) > 0) then
      SN := Copy(FDatabase.DatabaseName, 1, P - 1)
    else
      SN := '';

    if SN = '' then
      DN := FDatabase.DatabaseName
    else
      DN := Copy(FDatabase.DatabaseName, Length(SN) + 2, 1024);

    FConfigservice.ServerName := SN;
    FConfigService.DatabaseName := DN;
    if SN > '' then
      FConfigService.Protocol := TCP
    else
      FConfigService.Protocol := Local;
    FConfigService.Params.Text := FDatabase.Params.Text;

    for I := FConfigService.Params.Count - 1 downto 0 do
    begin
      if AnsiCompareText(FConfigService.Params.Names[I], 'password') = 0 then
        continue;
      if AnsiCompareText(FConfigService.Params.Names[I], 'user_name') = 0 then
        continue;
      FConfigService.Params.Delete(I);
    end;
    FConfigService.LoginPrompt := False;

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
        MessageBox(0,
          'Базу данных не удалось перевести рабочий режим.',
          'Внимание!',
          MB_OK or MB_ICONHAND or MB_TASKMODAL);
      end;
    finally
      FConfigService.Active := False;
    end;
  end;
end;

end.

