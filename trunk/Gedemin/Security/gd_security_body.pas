
{++

  Copyright (c) 1998-2012 by Golden Software of Belarus

  Module
    gd_security.pas

  Abstract

    Gedemin project. TboLogin, TboJournal components.

  Author

    Basic: UserLogin   Andrei Kireev     (22-aug-99)
           boSecurity  Romanovski Denis  (04-feb-00)

    Andrey Shadevsky

  Revisions history

    1.00    10.05.00    jkl        Initial version.
    1.01    27.06.00    andreik    DBVersion added.
    1.02    10.07.00    andreik    Audit levels added.
    1.03    22.07.00    andreik    Password encryption added.
    1.04    28.07.00    andreik    Some minor changes in boLogin.Loaded.
    2.00    01.03.00    dennis     Completely rebuilt.

--}

unit gd_security_body;

interface

uses
  Windows,            Messages,           SysUtils,           Classes,
  Graphics,           Controls,           Forms,              Dialogs,
  ComCtrls,           DB,                 IBTable,            IBCustomDataSet,
  IBDatabase,         IBSQL,              IB,                 AppEvnts,
  gd_Security,        contnrs,            gdcBaseInterface;

type
  TboLoginConnectionEvent = procedure (Sender: TObject; var CanLogin: Boolean) of object;

  TboLogin = class(TComponent, IboLogin)
  private
    FIBBase: TIBBase;
    FTransaction: TIBTransaction;
    FParams: TStringList;

    FShutDown: Boolean;

    FLoginInProgress: Boolean;
    FShutDownRequested: Boolean;

    FShouldReadParams: Boolean;
    FReLogining: Boolean;

    FCompanyOpened: Boolean;
    FChangePass: Boolean;

    FAutoOpenCompany: Boolean;
    FComputerName: String;

    FConnectNotifiers: TList;
    FCompanyNotifiers: TList;

    FAfterSuccessfullConnection: TNotifyEvent;
    FAfterChangeCompany: TNotifyEvent;
    FBeforeChangeCompany: TNotifyEvent;
    FBeforeDisconnect: TNotifyEvent;

    FLoginControlNexus: TWinControl;

    // Имя и пароль IB
    FIBName: String;
    FIBPassword: String;
    FIBRole: String;
    FIsIBUserAdmin: Boolean;

    //  Свойства сессия
    FStartTime: TDateTime;
    FSessionKey: Integer;

    // Права пользователя
    FIngroup: Integer;
    FGroupName: String;

    // Подсистема
    FSubSystemKey: Integer;
    FSubSystemName: String;

    // Версия базы данных
    FDBVersion: String;
    FDBReleaseDate: TDateTime;
    FDBVersionID: Integer;
    FDBVersionComment: String;

    // Параметры регистрации операций пользователя
    FAuditLevel: TAuditLevel;
    FAuditCache: Integer;
    FAuditMaxDays: Integer;
    FAllowUserAudit: Boolean;

    // Пользователь
    FUserKey: Integer;
    FUserName: String;
    FContactKey: Integer;
    FContactName: String;

    // Данные о последнем подключении
    FLastUserName: String;
    FLastPassword: String;

    // Компания
    FCompanyKey: Integer;
    FCompanyName: String;

    //
    FDBID: Integer;
    FDBIDRead: Boolean;

    //
    FHoldingListCache: String;

    //
    FLoggingOff: Boolean;

    //
    FHoldingCacheKey: Integer;
    FHoldingCacheValue: Boolean;

    //FTempTransaction: TIBTransaction;

    FSilentLogin: Boolean;

    procedure DoOnConnectionParams(Sender: TObject);

    procedure ProceedOpenCompany(NewCompanyKey: Integer; NewCompany: String);

    function GetDatabase: TIBDatabase;
    procedure SetDatabase(const Value: TIBDatabase);

    function GetLoginParam(ParamName: String): String;

    function GetAuditCache: Integer;
    function GetAuditLevel: TAuditLevel;
    function GetAuditMaxDays: Integer;
    function GetAllowUserAudit: Boolean;
    function GetCompanyKey: Integer;
    function GetCompanyName: String;
    function GetContactKey: Integer;
    function GetContactName: String;
    function GetDBReleaseDate: TDateTime;
    function GetDBVersion: String;
    function GetDBVersionComment: String;
    function GetDBVersionID: Integer;
    function GetGroupName: String;
    function GetIngroup: Integer;
    function GetSessionDuration: TDateTime;
    function GetSessionKey: Integer;
    function GetStartTime: TDateTime;
    function GetSubSystemKey: Integer;
    function GetSubSystemName: String;
    function GetUserKey: Integer;
    function GetUserName: String;
    function GetComputerName: String;
    function GetCompanyOpened: Boolean;
    function GetLoggedIn: Boolean;
    function GetIBName: String;
    function GetIBPassw: String;
    function GetDatabaseName: String;
    function GetIsUserAdmin: Boolean;
    function GetShutDown: Boolean;
    function GetShutDownRequested: Boolean;

    procedure SetSubSystemKey(const Value: Integer);
    procedure SetIngroup(const Value: Integer);
    function GetIsIBUserAdmin: Boolean;
    function GetIsShutDown: Boolean;
    function GetServerName: String;
    function GetDBID: Integer;
    function GetIsHolding: Boolean;
    function GetHoldingList: String;
    function GetHoldingKey: Integer;
    function GetActiveAccount: Integer;
    function GetIBRole: String;

    procedure OnModifyLog(const AnLogText: String);
    function GetReLogining: Boolean;
    function GetMainWindowCaption: String;
    function GetIsEmbeddedServer: Boolean;

  protected
    function EstablishConnection: Boolean;
    function CloseConnection: Boolean;
    function TestConnection: Boolean;

    function RunLoginDialog(UnderDatabase: TIBDatabase): Boolean;
    function RunChangePassDialog: Boolean;

    function EnterCompany: Boolean;

    procedure UpdateDatabaseProperties;
    procedure ConnectionLost;

    procedure ReadCommandLineLoginParams;
    procedure ReadRegistryLoginParams;

    procedure WriteShutDownKey(const AShutDown: Boolean);
    function ReadShutDownKey: Boolean;

    procedure DoBeforeChangeCompany;
    procedure DoAfterChangeCompany;
    procedure DoAfterSuccessfullConnection;
    procedure DoBeforeDisconnect;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function LoginSingle: Boolean;
    function BringOnLine: Boolean;

    function Login(ReadParams: Boolean = True; ReLogin: Boolean = False): Boolean;
    function LoginSilent(AnUserName: String; APassword: String; const ADBPath: string = ''): Boolean;
    function Logoff: Boolean;
    function GetLoggingOff: Boolean;
    function IsSilentLogin: Boolean;
    procedure ChangeUser(const AUserKey: Integer; const ACheckMultipleConnections: Boolean = False);

    procedure CloneDatabase(ADatabase: TIBDatabase);

    function OpenCompany(const ShowDialogAnyway: Boolean = False;
      const CK: Integer = -1; const CN: String = ''): Boolean;
    procedure UpdateCompanyData;
    // перечитывает из базы данных свойства текущего пользователя
    procedure UpdateUserData;

    procedure ConnectionLostMessage;

    procedure AddConnectNotify(Notify: IConnectChangeNotify);
    procedure RemoveConnectNotify(Notify: IConnectChangeNotify);

    procedure AddCompanyNotify(Notify: ICompanyChangeNotify);
    procedure RemoveCompanyNotify(Notify: ICompanyChangeNotify);

    //
    procedure ClearHoldingListCache;

    //
    procedure AddEvent(const AData: String;
      const ASource: String = '';
      const AnObjectID: Integer = -1;
      const ATransaction: TObject = nil);

    procedure ReadDBVersion;

    property LoginParam[ParamName: String]: String read GetLoginParam;
    property ChangePass: Boolean read FChangePass;

    property ComputerName: String read GetComputerName;
    property ServerName: String read GetServerName;

    // Состояние
    property CompanyOpened: Boolean read GetCompanyOpened;
    property LoggedIn: Boolean read GetLoggedIn;
    property ShutDown: Boolean read GetShutDown;
    property ShutDownRequested: Boolean read GetShutDownRequested;
    property ReLogining: Boolean read GetReLogining;

    // Имя и пароль IB
    property IBName: String read GetIBName;
    property IBPassword: String read GetIBPassw;
    property IBRole: String read GetIBRole;

    //  Свойства сессии
    property SessionDuration: TDateTime read GetSessionDuration;
    property StartTime: TDateTime read GetStartTime;
    property SessionKey: Integer read GetSessionKey;

    // Права пользователя
    property Ingroup: Integer read GetIngroup write SetIngroup;
    property GroupName: String read GetGroupName;
    property IsUserAdmin: Boolean read GetIsUserAdmin;
    property IsIBUserAdmin: Boolean read FIsIBUserAdmin;
    property IsShutDown: Boolean read GetIsShutDown;

    // Подсистема
    property SubSystemKey: Integer read GetSubSystemKey write SetSubSystemKey;
    property SubSystemName: String read GetSubSystemName;

    // Версия базы данных
    property DatabaseName: String read GetDatabaseName;
    property DBVersion: String read GetDBVersion;
    property DBReleaseDate: TDateTime read GetDBReleaseDate;
    property DBVersionID: Integer read GetDBVersionID;
    property DBVersionComment: String read GetDBVersionComment;

    // Параметры регистрации операций пользователя
    property AuditLevel: TAuditLevel read GetAuditLevel;
    property AuditCache: Integer read GetAuditCache;
    property AuditMaxDays: Integer read GetAuditMaxDays;
    property AllowUserAudit: Boolean read GetAllowUserAudit;

    // Пользователь
    property UserKey: Integer read GetUserKey;
    property UserName: String read GetUserName;
    property ContactKey: Integer read GetContactKey;
    property ContactName: String read GetContactName;

    // Компания
    property CompanyKey: Integer read GetCompanyKey;
    property CompanyName: String read GetCompanyName;
    property IsHolding: Boolean read GetIsHolding;
    property HoldingList: String read GetHoldingList;
    //Возвкащает ID асктивного плана счетов
    property ActiveAccount: Integer read GetActiveAccount;

    //
    property DBID: Integer read GetDBID;

    //
    property MainWindowCaption: String read GetMainWindowCaption;

    //
    property IsEmbeddedServer: Boolean read GetIsEmbeddedServer;

  published
    property Database: TIBDatabase read GetDatabase write SetDatabase;
    property AutoOpenCompany: Boolean read FAutoOpenCompany write FAutoOpenCompany;

    property AfterSuccessfullConnection: TNotifyEvent read FAfterSuccessfullConnection
      write FAfterSuccessfullConnection;
    property BeforeDisconnect: TNotifyEvent read FBeforeDisconnect write
      FBeforeDisconnect;
    property BeforeChangeCompany: TNotifyEvent read FBeforeChangeCompany write
      FBeforeChangeCompany;
    property AfterChangeCompany: TNotifyEvent read FAfterChangeCompany write
      FAfterChangeCompany;
  end;

  EboLoginError = class(Exception);

procedure Register;

implementation

uses
  Registry,                 gd_directories_const, gd_security_dlgLogIn,
  gd_createable_form,       gd_frmBackup_unit,    gd_CmdLineParams_unit,
  gd_resourcestring,        gsDatabaseShutdown,   gd_security_dlgChangePass,
  jclSysInfo,               gdcUser,              mtd_i_Base,
  evt_i_base,               IBStoredProc,         gd_splash,
  gd_DebugLog,              gdcJournal,           dm_i_ClientReport_unit,
  inst_const,               gdcContacts,          dmDataBase_unit,
  at_classes_body,          at_classes,           dmLogin_unit,
  gd_security_dlgDatabases_unit,                  jclStrings,
  IBServices,               DBLogDlg,             at_frmSQLProcess,
  Storages,                 mdf_proclist,         gdModify,
  IBDatabaseInfo
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Register;
begin
  RegisterComponents('gdSecurity', [TboLogin]);
end;

const
  WM_FINISHOPENCOMPANY          = WM_USER + 25487;
  WM_CONNECTIONLOST             = WM_USER + 25488;

type
  TboLoginControlNexus = class(TForm)
  private
    FLogin: TboLogin;

    FNewCompanyKey: Integer;
    FNewCompany: String;

    procedure WMFinishOpenCompany(var Msg: TMessage);
      message WM_FINISHOPENCOMPANY;

    procedure WMConnectionLost(var Msg: TMessage);
      message WM_CONNECTIONLOST;

  public
    constructor Create(ALogin: TboLogin); reintroduce;
    destructor Destroy; override;
  end;

constructor TboLoginControlNexus.Create(ALogin: TboLogin);
begin
  inherited CreateNew(nil);
  FLogin := ALogin;
end;

destructor TboLoginControlNexus.Destroy;
begin
  inherited Destroy;
end;

procedure TboLoginControlNexus.WMFinishOpenCompany(var Msg: TMessage);
begin
  inherited;

  FLogin.ProceedOpenCompany(FNewCompanyKey, FNewCompany);
end;

function CompareAnyString(S1: String; S2: array of String): Boolean;
var
  S: String;
  I: Integer;
begin
  for I := Low(S2) to High(S2) do
  begin
    S := S2[I];
    if AnsiCompareText(S1, S) = 0 then
    begin
      Result := True;
      Exit;
    end;
  end;

  Result := False;
end;

procedure TimedDelay(MilSecs: DWord);
var
  TickCount: DWord;
begin
  TickCount := GetTickCount + MilSecs;
  while TickCount > GetTickCount do
    Application.ProcessMessages;
end;

{ TboLogin }

procedure TboLogin.AddCompanyNotify(Notify: ICompanyChangeNotify);
begin
  Assert(Notify <> nil);
  if FCompanyNotifiers.IndexOf(Pointer(Notify)) = -1 then
  begin
    FCompanyNotifiers.Add(Pointer(Notify));
    ClearHoldingListCache;
    {if Login then Notify.DoAfterChangeCompany;}
  end;
end;

procedure TboLogin.AddConnectNotify(Notify: IConnectChangeNotify);
begin
  Assert(Notify <> nil);
  if FConnectNotifiers.IndexOf(Pointer(Notify)) = -1 then
    FConnectNotifiers.Add(Pointer(Notify));
end;

procedure TboLogin.AddEvent(const AData, ASource: String;
  const AnObjectID: Integer; const ATransaction: TObject);
begin
  TgdcJournal.AddEvent(AData, ASource, AnObjectID,
    ATransaction as TIBTransaction);
end;

function TboLogin.BringOnLine: Boolean;
begin
  if FShutDown then
  with TgsDatabaseShutdown.Create(Self) do
  try
    Database := Self.Database;
    ShowUserDisconnectDialog := False;
    FShutDown := IsShutdowned;

    if FShutDown then
      FShutDown := not BringOnline;

    if not FShutDown then
    begin
      FShutDownRequested := False;
      WriteShutDownKey(False);
    end;
  finally
    Free;
  end;

  Result := not FShutDown;
end;

procedure TboLogin.ClearHoldingListCache;
begin
  FHoldingListCache := '';
  FHoldingCacheKey := -1;
end;

procedure TboLogin.CloneDatabase(ADatabase: TIBDatabase);
begin
  if Assigned(ADatabase) then
  begin
    ADatabase.DatabaseName := Database.DatabaseName;
    ADatabase.Params.Assign(Database.Params);
    ADatabase.LoginPrompt := Database.LoginPrompt;
    ADatabase.DefaultTransaction := Database.DefaultTransaction;
    ADatabase.IdleTimer := Database.IdleTimer;
    ADatabase.SQLDialect := Database.SQLDialect;
    ADatabase.TraceFlags := Database.TraceFlags;
    ADatabase.AllowStreamedConnected := Database.AllowStreamedConnected;
  end;
end;

function TboLogin.CloseConnection: Boolean;
//var
//  Msg: TMsg;
  {$IFDEF DEBUG}var I: Integer;{$ENDIF}
begin
  try
    //
    //  Закрываем подключение,
    //  если закрыть не удается - заставляем закрыться

    try
      Database.Connected := False;
      Result := True;
    except
      {$IFDEF DEBUG}
      for I := 0 to Database.TransactionCount - 1 do
        if (Database.Transactions[I] <> nil) and Database.Transactions[I].Active then
        begin
          if Database.Transactions[I].Owner <> nil then
            OutputDebugString(PChar('Transaction: ' + Database.Transactions[I].Name +
              ' Owner: ' + Database.Transactions[I].Owner.Name))
          else
            OutputDebugString(PChar('Transaction: ' + Database.Transactions[I].Name));
        end;
      {$ENDIF}
      TimedDelay(1000);
      if Database.Connected then
      begin
        Database.ForceClose;
        Result := True;
      end else
        raise;
    end;

    FCompanyOpened := False;
    FDBIDRead := False;
  except
    on E: Exception do
    begin
      Application.ShowException(E);
      Result := False;
    end;
  end;
end;

procedure TboLogin.ConnectionLost;
var
  I: Integer;
  Msg: TMsg;
begin
  if Database.Connected then
    Database.ForceClose;

  //
  // Закрываем все окна

  FreeAllForms(False);

  //
  // Пропускаем все сообщения закрытия окон

  while PeekMessage(Msg, 0, CM_RELEASE, CM_RELEASE, PM_REMOVE) do
  begin
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;

  //
  while PeekMessage(Msg, FLoginControlNexus.Handle,
    WM_CONNECTIONLOST, WM_CONNECTIONLOST, PM_REMOVE) do ;

  for I := FConnectNotifiers.Count - 1 downto 0 do
    IConnectChangeNotify(FConnectNotifiers[I]).DoAfterConnectionLost;
end;

procedure TboLogin.ConnectionLostMessage;
begin
  if Assigned(FLoginControlNexus) then
    PostMessage(FLoginControlNexus.Handle, WM_CONNECTIONLOST, 0, 0);
end;

constructor TboLogin.Create(AnOwner: TComponent);
begin
  Assert(IBLogin = nil, 'Only one instance of IBLogin is allowed');

  inherited;

  FTransaction := TIBTransaction.Create(nil);

  FIBBase := TIBBase.Create(Self);
  FIBBase.Transaction := FTransaction;

  FParams := TStringList.Create;

  FConnectNotifiers := TList.Create;
  FCompanyNotifiers := TList.Create;

  FShutDown := False;

  FLoginInProgress := False;
  FShutDownRequested := False;

  FShouldReadParams := False;
  FReLogining := False;

  FAutoOpenCompany := True;

  FComputerName := GetLocalComputerName;

  FDBIDRead := False;

  FLoginControlNexus := TboLoginControlNexus.Create(Self);

  FCompanyKey  := -1;
  FCompanyName := '';

  IBLogin := Self;
end;

destructor TboLogin.Destroy;
begin
  FTransaction.Free;
  FIBBase.Free;
  FConnectNotifiers.Free;
  FCompanyNotifiers.Free;
  FParams.Free;

  FLoginControlNexus.Free;
  //FTempTransaction.Free;

  inherited;

  IBLogin := nil;
end;

procedure TboLogin.DoAfterChangeCompany;
var
  I: Integer;
begin
  if Assigned(FAfterChangeCompany) then
    FAfterChangeCompany(Self);

  ClearHoldingListCache;  

  for I := 0 to FCompanyNotifiers.Count - 1 do
    ICompanyChangeNotify(FCompanyNotifiers[I]).DoAfterChangeCompany;
end;

procedure TboLogin.DoAfterSuccessfullConnection;
var
  I: Integer;
begin
  ClearHoldingListCache;

  if dm_i_ClientReport <> nil then begin
    dm_i_ClientReport.DoConnect;
  end;

  if Assigned(FAfterSuccessfullConnection) then
    FAfterSuccessfullConnection(Self);

  for I := FConnectNotifiers.Count - 1 downto 0 do
    IConnectChangeNotify(FConnectNotifiers[I]).DoAfterSuccessfullConnection;
end;

procedure TboLogin.DoBeforeChangeCompany;
var
  I: Integer;
begin
  if Assigned(FBeforeChangeCompany) then
    FBeforeChangeCompany(Self);

  for I := 0 to FCompanyNotifiers.Count - 1 do
    ICompanyChangeNotify(FCompanyNotifiers[I]).DoBeforeChangeCompany;
end;

procedure TboLogin.DoBeforeDisconnect;
var
  I: Integer;
  Msg: TMsg;

begin
  //
  // Закрываем все окна

  if not (csDestroying in ComponentState) then
    FreeAllForms(False);

  //
  // Пропускаем все сообщения закрытия окон

  while PeekMessage(Msg, 0, CM_RELEASE, CM_RELEASE, PM_REMOVE) do
  begin
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;

  if Assigned(FBeforeDisconnect) then
    FBeforeDisconnect(Self);

  for I := FConnectNotifiers.Count - 1 downto 0 do
    IConnectChangeNotify(FConnectNotifiers[I]).DoBeforeDisconnect;

  if dm_i_ClientReport <> nil then
    dm_i_ClientReport.DoDisconnect;
end;

procedure TboLogin.OnModifyLog(const AnLogText: String);
begin
  if (StrIPos('ошибк', AnLogText) = 1) or (StrIPos('error', AnLogText) = 1) then
    AddMistake(AnLogText)
  else
    AddText(AnLogText);
end;

procedure TboLogin.DoOnConnectionParams(Sender: TObject);
begin
  with Sender as TdlgSecLogIn do
  begin
    FDBVersion := spUserLogin.ParamByName('DBVersion').AsString;
    FDBReleaseDate := spUserLogin.ParamByName('DBReleaseDate').AsDateTime;
    FDBVersionID := spUserLogin.ParamByName('DBVersionID').AsInteger;
    FDBVersionComment := spUserLogin.ParamByName('DBVersionComment').AsString;

    FIBName := spUserLogin.ParamByName('ibname').AsString;
    FIBPassword := spUserLogin.ParamByName('ibpassword').AsString;
    FIBRole := '';
    FIsIBUserAdmin := AnsiCompareText(FIBName, SysDBAUserName) = 0;

    FStartTime := Now;
    FUserKey := spUserLogin.ParamByName('UserKey').AsInteger;
    FIngroup := spUserLogin.ParamByName('Ingroup').AsInteger;
    if FInGroup = 0 then FInGroup := 1;
    FContactKey := spUserLogin.ParamByName('ContactKey').AsInteger;

    FSessionKey := spUserLogin.ParamByName('Session').AsInteger;
    FSubSystemName := spUserLogin.ParamByName('SubsystemName').AsString;
    FGroupName := spUserLogin.ParamByName('GroupName').AsString;
    FUserName := cbUser.Text;

    FAuditLevel := TAuditLevel(spUserLogin.ParamByName('auditlevel').AsInteger);
    FAuditCache := spUserLogin.ParamByName('auditcache').AsInteger;
    FAuditMaxDays := spUserLogin.ParamByName('auditmaxdays').AsInteger;
    FAllowUserAudit := spUserLogin.ParamByName('allowuseraudit').AsInteger <> 0;

    FLastUserName := UserName;
    FLastPassword := Password;
  end
end;

function TboLogin.EnterCompany: Boolean;
var
  ibsql: TIBSQL;
begin
  FCompanyName := '';
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := FTransaction;

    if not FTransaction.InTransaction then
      FTransaction.StartTransaction;

    ibsql.SQL.Text :=
      'SELECT uc.companykey AS CompanyKey, oc.afull AS AFull, c.name AS CompanyName ' +
      'FROM gd_usercompany uc JOIN gd_contact c ON c.id = uc.companykey  ' +
      '  JOIN gd_ourcompany oc ON oc.companykey = c.id ' +
      'WHERE uc.userkey = :UK';
    ibsql.ParamByName('UK').AsInteger := IBLogin.UserKey;
    ibsql.ExecQuery;

    if ibsql.EOF then
    begin
      ibsql.Close;
      ibsql.SQL.Text :=
        'SELECT oc.companykey AS CompanyKey, c.afull AS AFull, c.name AS CompanyName ' +
        'FROM gd_ourcompany oc JOIN gd_contact c ON c.id = oc.companykey';
      {TODO: под ФБ 2.5 добавить код ниже}
      {WHERE BIN_AND(BIN_OR(oc.afull, 1), <ingroup>) <> 0}  
      ibsql.ExecQuery;
    end;

    if (ibsql.RecordCount > 0) and
      (((ibsql.FieldByName('afull').AsInteger or 1) and FIngroup) <> 0) then
    begin
      if FCompanyOpened then DoBeforeChangeCompany;
      FCompanyKey := ibsql.FieldByName('CompanyKey').AsInteger;
      FCompanyName := ibsql.FieldByName('CompanyName').AsString;
      FCompanyOpened := True;
      DoAfterChangeCompany;
    end else
    begin
      MessageBox(0,
        PChar('У пользователя ' + FUserName + ' нет прав доступа к выбранной '#13#10 +
        'рабочей организации "' + ibsql.FieldByName('CompanyName').AsString + '".'#13#10#13#10 +
        'Зайдите под учетной записью Administrator и установите'#13#10 +
        'в справочнике клиентов полные права доступа на эту организацию.'),
        'Внимание',
        MB_OK or MB_ICONHAND or MB_TASKMODAL);
    end;
  finally
    if FTransaction.InTransaction then
      FTransaction.Commit;
    ibsql.Free;
  end;

  Result := FCompanyName > '';
end;

function TboLogin.EstablishConnection: Boolean;
{const
  Asked: Boolean = False;}
var
  TryLoginDatabase: TIBDatabase;
  Tr: TIBTransaction;
  q: TIBSQL;
  Reg: TRegistry;
  IBSS: TIBSecurityService;
  FSysDBAPassword, FSysDBAUserName: String;


  function SelectAnother: Boolean;
  begin
    Result := False;
    with Tgd_security_dlgDatabases.Create(Self) do
    try
      if (ShowModal = mrOk) and (lv.Selected <> nil) then
      begin
        TryLoginDatabase.Connected := False;
        TryLoginDatabase.DatabaseName := lv.Selected.SubItems[0];

        if gd_CmdLineParams.ServerName = '' then
        begin
          Reg := TRegistry.Create(KEY_WRITE);
          try
            Reg.RootKey := ClientRootRegistryKey;

            if Reg.OpenKey(ClientRootRegistrySubKey, False) then
            begin
              Reg.WriteString(ServerNameValue, TryLoginDatabase.DatabaseName);
              Reg.CloseKey;
            end else
            begin
              MessageBox(0,
                'Информация не может быть сохранена в системном реестре Windows.'#13#10 +
                'Возможно у Вас недостаточно прав доступа или программный продукт'#13#10 +
                'не был установлен надлежащим образом.',
                'Внимание',
                MB_OK or MB_ICONHAND or MB_TASKMODAL);
            end;
          finally
            Reg.Free;
          end;
        end else
        begin
          MessageBox(0,
            'Путь к базе данных указан в командной строке. Его необходимо скорректировать вручную.',
            'Внимание',
            MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
        end;

        Result := True;
      end;
    finally
      Free;
    end;
  end;

  procedure SetupTryLoginDatabase;
  begin
    TryLoginDatabase.LoginPrompt := False;
    TryLoginDatabase.Params.Clear;
    TryLoginDatabase.Params.Add(UserNameValue + '=STARTUSER');
    TryLoginDatabase.Params.Add(PasswordValue +  '=startuser');
    TryLoginDatabase.Params.Add(Lc_ctypeValue + '=' + FParams.Values[Lc_ctypeValue]);
    TryLoginDatabase.DatabaseName := FParams.Values[ServerNameValue];
    TryLoginDatabase.SQLDialect := 3;
  end;

var
  NeedReadDBVersion: Boolean;

begin
  TryLoginDatabase := TIBDatabase.Create(Self);

  try
    SetupTryLoginDatabase;

    try
      repeat
        try
          if Trim(TryLoginDatabase.DatabaseName) = '' then
          begin
            if not SelectAnother then
            begin
              Result := False;
              exit;
            end;
          end;

          TryLoginDatabase.Connected := True;
        except
          on E: EIBError do
          begin
            //
            //  Если база находится в режиме ShutDown,
            //  то необходимо перевести ее в режим
            //  online, если shutdown был произведен
            //  данным пользователем

            Result := False;

            if IsSilentLogin then
              exit;

            if gd_CmdLineParams.QuietMode then
            begin
              ExitCode := E.IBErrorCode;
              Application.Terminate;
              Abort;
            end;

            if (E.IBErrorCode = 335544528) then
            begin
              if not ReadShutDownKey then
              begin
                // база зашатдаунена, но не нами
                if MessageBox(0,
                  PChar('База данных находится в однопользовательском режиме.'#13#10#13#10 +
                  'Перевести базу в многопользовательский режим?'),
                  'Внимание',
                  MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDNO then
                begin
                  if SelectAnother then
                    continue
                  else
                    Abort;
                end;
              end;

              FShutDown := True;

              with TgsDatabaseShutdown.Create(Self) do
              try
                Database := Self.Database;
                Database.DatabaseName := FParams.Values[ServerNameValue];
                ShowUserDisconnectDialog := False;
                FShutDown := IsShutdowned;

                if FShutDown then
                begin
                  FShutDown := not BringOnline;
                end;

                if not FShutDown then
                  WriteShutDownKey(False);
              finally
                Free;
              end;

              SetupTryLoginDatabase;
              TryLoginDatabase.Connected := True;
            end
            else if (E.IBErrorCode = 335544472) then
            begin
              // сервер есть но старт юзера нет
              if MessageBox(0,
                'Указанный сервер Interbase/Firebird/Yaffil не сконфигурирован для работы с системой Гедымин.'#13#10 +
                'Произвести его настройку прямо сейчас?',
                'Ошибка',
                MB_YESNO or MB_ICONEXCLAMATION or MB_TASKMODAL) = IDNO then
              begin
                raise;
              end;

              //...
              FSysDBAPassword := 'masterkey';
              FSysDBAUserName := SysDBAUserName;

              if not LoginDialogEx(IBLogin.ServerName, FSysDBAUserName, FSysDBAPassword, True) then
                raise;

              IBSS := TIBSecurityService.Create(Self);
              try
                IBSS.ServerName := IBLogin.ServerName;
                IBSS.LoginPrompt := False;
                if IBSS.ServerName > '' then
                  IBSS.Protocol := TCP
                else
                  IBSS.Protocol := Local;
                IBSS.Params.Add('user_name=' + SysDBAUserName);
                IBSS.Params.Add('password=' + FSysDBAPassword);
                IBSS.Active := True;
                try
                  IBSS.UserName := 'STARTUSER';
                  IBSS.FirstName := ''; //FieldByName('fullname').AsString;
                  IBSS.MiddleName := '';
                  IBSS.LastName := '';
                  IBSS.UserID := 0;
                  IBSS.GroupID := 0;
                  IBSS.Password := 'startuser';
                  IBSS.AddUser;
                  while IBSS.IsServiceRunning do
                    Sleep(100);
                finally
                  IBSS.Active := False;
                end;
              finally
                IBSS.Free;
              end;
            end
            else
            begin
              MessageBox(0,
                PChar('Невозможно подключиться к базе данных:'#13#10 +
                TryLoginDatabase.DatabaseName + #13#10#13#10 +
                'Сообщение об ошибке:'#13#10 +
                E.Message),
                'Ошибка',
                MB_OK or MB_ICONSTOP or MB_TASKMODAL);

              if SelectAnother then
                continue;

              raise;
            end;  
          end;
        end;
      until TryLoginDatabase.Connected;

      Result := RunLoginDialog(TryLoginDatabase);

      TryLoginDatabase.Connected := False;
      NeedReadDBVersion := False;

      if Result then
      begin
        // если при загрузке пользователь выбрал другую базу
        FParams.Values[ServerNameValue] := TryLoginDatabase.DatabaseName;

        //
        //  Определяем параметры входа
        UpdateDatabaseProperties;

        // modify
        if DBVersion < cProcList[0].ModifyVersion then
        begin
          MessageBox(0,
            PChar('Структура файла базы данных устарела.'#13#10#13#10 +
            'Версия вашей БД: ' + DBVersion + #13#10#13#10 +
            //'Требуется версия: ' + cProcList[0].ModifyVersion + #13#10#13#10 +
            'Обратитесь к разработчикам системы Гедымин.'),
            'Внимание',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL or MB_TOPMOST);
        end
        else if DBVersion <= cProcList[cProcCount - 1].ModifyVersion then
        begin
          if IsIBUserAdmin then
          begin
            if MessageBox(0,
                PChar(
                'Структура файла базы устарела и будет обновлена.'#13#10#13#10 +
                'Версия вашей БД: ' + DBVersion + #13#10#13#10 +
                //'Требуется версия: ' + cProcList[cProcCount - 1].ModifyVersion + #13#10#13#10 +
                'Перед обновлением необходимо создать архивную копию!'),
                'Внимание',
              MB_OKCANCEL or MB_ICONQUESTION or MB_TASKMODAL or MB_TOPMOST) = IDOK then
            begin
              {MessageBox(0,
                'Перед обновлением структуры необходимо создать архивную копию базы данных!',
                'Внимание',
                MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL or MB_TOPMOST);

              MessageBox(0,
                PChar('Структура файла базы будет обновлена.'#13#10#13#10 +
                'Версия вашей БД: ' + DBVersion + #13#10#13#10 +
                'Перед обновлением необходимо создать архивную копию базы данных!'),
                'Внимание',
                MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL or MB_TOPMOST);}

              with Tgd_frmBackup.Create(Application) do
              try
                ShowModal;
              finally
                Free;
              end;

              {MessageBox(0,
                'Перепишите архив на съемный носитель и сохраните в надежном месте!',
                'Внимание',
                MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL or MB_TOPMOST);}

              try
                with TgdModify.Create(nil) do
                try
                  Database := TryLoginDatabase;
                  IBUser := 'SYSDBA';
                  IBPassword := 'masterkey';
                  ShutdownNeeded := True;
                  OnLog := OnModifyLog;
                  Execute;
                finally
                  Free;
                end;

                // в процессе модифая мог проскочить код, который
                // открыл подключение к БД. Закрываем
                if Self.Database.Connected then
                  Self.Database.Connected := False;

                MessageBox(0,
                  'Процесс обновления завершен.'#13#10#13#10 +
                  'Если вы используете сетевую версию программы, убедитесь что на всех'#13#10 +
                  'рабочих местах установлена новейшая версия модуля gedemin.exe.',
                  'Внимание',
                  MB_OK or MB_ICONINFORMATION or MB_TASKMODAL or MB_TOPMOST);
              except
                on E: Exception do
                begin
                  MessageBox(0,
                    PChar('Произошла ошибка, процесс обновления прерван!'#13#10#13#10 +
                    E.Message + #13#10#13#10 +
                    'Устраните ошибки и повторите процесс обновления'),
                    'Внимание',
                    MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL or MB_TOPMOST);
                end;
              end;

              NeedReadDBVersion := True;
            end else
              exit;
          end else
          begin
            {if ServerName = '' then
            begin}
              MessageBox(0,
                'Структура файла базы данных устарела.'#13#10 +
                'Для ее обновления войдите под учетной записью Administrator.',
                'Внимание',
                MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL or MB_TOPMOST);
              exit;
            {end;}
          end;
        end;
        // end modify

        {$IFNDEF DEBUG}
        if Assigned(gdSplash) then
          gdSplash.ShowSplash;
        {$ENDIF}

        //
        //  Если необходимо перевести базу
        //  в однопользовательский режим

        if FShutDownRequested then
          with TgsDatabaseShutdown.Create(Self) do
          try
            Database := Self.Database;
            ShowUserDisconnectDialog := False;
            FShutDown := IsShutdowned;

            if FShutDownRequested then
            begin
              if not FShutDown then
                FShutDown := Shutdown;

              Result := FShutDown;

              if Result then
                WriteShutDownKey(True);
            end;
          finally
            Free;
          end;

        if not Result then Exit;

        //
        //  Осуществляем подключение
        repeat
          try
            Database.Connected := True;
          except
            on E: EIBError do
            begin
              if (E.IBErrorCode = 335544472) and IsIBUserAdmin then
              begin
                MessageBox(0,
                  'На сервере базы данных был изменен пароль для учетной записи SYSDBA.',
                  'Внимание',
                  MB_OK or MB_TASKMODAL or MB_ICONQUESTION);
                Database.LoginPrompt := True;
                continue;
              end;

              // проверим может на сервере нет такого пользователя
              if not TgdcUser.CheckIBUser(FIBName, FIBPassword) then
              begin
                MessageBox(0,
                  'Отсутствует учетная запись пользователя на сервере базы данных.'#13#10 +
                  'Вероятно, файл базы данных был перенесен на другой сервер или сервер '#13#10 +
                  'Interbase/Firebird был переустановлен.'#13#10 +
                  ''#13#10 +
                  'Зайдите в систему под Администратором и в разделе Пользователи'#13#10 +
                  'выполните команду Пересоздать учетные записи.'#13#10 +
                  '',
                  'Внимание',
                  MB_OK or MB_ICONHAND or MB_TASKMODAL);
                Result := False;
                exit;
              end else
                raise;
            end;
          end;
        until Database.Connected;

        { TODO :
по умолчанию ИБИКС если был запрос пароля у пользователя
уберет из списка параметров пароль. мы подправили ИБИКС
правильнее было бы сделать так, чтобы пароль запрашивался
нашим окном, а не стандартными средставми ИБИКСа }
        if Database.Connected and Database.LoginPrompt then
        begin
          Tr := TIBTransaction.Create(nil);
          q := TIBSQL.Create(nil);
          try
            Tr.DefaultDatabase := Database;
            q.Transaction := Tr;
            Tr.StartTransaction;
            q.SQL.Text := 'UPDATE gd_user SET ibpassword=:P where ibname=:N';
            q.ParamByName('P').AsString := Database.Params.Values['password'];
            q.ParamByName('N').AsString := Database.Params.Values['user_name'];
            try
              q.ExecQuery;
              Tr.Commit;
            except
            end;
          finally
            q.Free;
            Tr.Free;
          end;
        end;

        //
        //  Изменяем пароль пользователя

        if FChangePass then
          Result := RunChangePassDialog;

        if NeedReadDBVersion then
          ReadDBVersion;
      end;
    except
      on E: EIBClientError do
      begin
        if (E.SQLCode = 17) then
          MessageBox(0, 'Неверно указан путь к файлу базы данных.', 'Ошибка', MB_OK or MB_ICONHAND or MB_TASKMODAL)
        else
          MessageBox(0, PChar(E.Message), 'Ошибка', MB_OK or MB_ICONHAND or MB_TASKMODAL);

        Result := False;
      end;

      on E: Exception do
      begin
        if not (E is EAbort) then
          MessageBox(0,
            PChar(E.Message),
            'Ошибка',
            MB_OK or MB_ICONHAND or MB_TASKMODAL);
        Result := False;
      end;
    end;
  finally
    TryLoginDatabase.Free;
  end;
end;

function TboLogin.GetActiveAccount: Integer;
var
  SQL: TIBSQL;
begin
  Result := 0;
  if LoggedIn then
  begin
    Assert(Assigned(gdcBaseManager));
    Assert(Assigned(gdcBaseManager.ReadTransaction));

    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      SQL.SQL.Text := 'SELECT * FROM ac_companyaccount WHERE companykey = :ck AND isactive = 1';
      SQL.ParamByName('ck').AsInteger := CompanyKey;
      SQL.ExecQuery;
      if SQL.RecordCount > 0 then
        Result := SQL.FieldByName('accountkey').AsInteger;
    finally
      SQL.Free;
    end;
  end;
end;

function TboLogin.GetAllowUserAudit: Boolean;
begin
  Result := FAllowUserAudit;
end;

function TboLogin.GetAuditCache: Integer;
begin
  Result := FAuditCache;
end;

function TboLogin.GetAuditLevel: TAuditLevel;
begin
  Result := FAuditLevel;
end;

function TboLogin.GetAuditMaxDays: Integer;
begin
  Result := FAuditMaxDays;
end;

function TboLogin.GetCompanyKey: Integer;
begin
  Result := FCompanyKey
end;

function TboLogin.GetCompanyName: String;
begin
  Result := FCompanyName;
end;

function TboLogin.GetCompanyOpened: Boolean;
begin
  Result := FCompanyOpened;
end;

function TboLogin.GetComputerName: String;
begin
  Result := FComputerName;
end;

function TboLogin.GetContactKey: Integer;
begin
  Result := FContactKey
end;

function TboLogin.GetContactName: String;
var
  ibsql: TIBSQL;
begin
  if (FContactKey > 0) and (FContactName = '') then
  begin
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := FTransaction;

      if not FTransaction.InTransaction then
        FTransaction.StartTransaction;

      ibsql.SQL.Text := 'SELECT NAME FROM GD_CONTACT WHERE ID = :ID';
      ibsql.ParamByName('ID').AsInteger := FContactKey;
      ibsql.ExecQuery;

      FContactName := ibsql.Fields[0].AsString;

      FTransaction.Commit;
    finally
      ibsql.Free;
    end;
  end;

  Result := FContactName;
end;

function TboLogin.GetDatabase: TIBDatabase;
begin
  Result := FIBBase.Database;
end;

function TboLogin.GetDatabaseName: String;
begin
  Result := FParams.Values[ServerNameValue];
end;

function TboLogin.GetDBID: Integer;
var
  q: TIBSQL;
begin
{ TODO :
идентификатор базы должен возвращаться сторед процедурой
которая делает логин }
{TODO: Насчет ускорения: может считывать dbid базы один раз при логине?}
  if (not FDBIDRead) and Database.Connected then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Database := Database;
      q.Transaction := Database.InternalTransaction;

      if not q.Transaction.InTransaction then
        q.Transaction.StartTransaction;

      q.SQL.Text := 'SELECT GEN_ID(gd_g_dbid, 0) FROM rdb$database';
      q.ExecQuery;
      FDBID := q.Fields[0].AsInteger;
      FDBIDRead := True;
      q.Close;
      q.Transaction.Commit;
    finally
      q.Free;
    end;
  end;
  Result := FDBID;
end;

function TboLogin.GetDBReleaseDate: TDateTime;
begin
  Result := FDBReleaseDate;
end;

function TboLogin.GetDBVersion: String;
begin
  Result := FDBVersion;
end;

function TboLogin.GetDBVersionComment: String;
begin
  Result := FDBVersionComment;
end;

function TboLogin.GetDBVersionID: Integer;
begin
  Result := FDBVersionID;
end;

function TboLogin.GetGroupName: String;
begin
  Result := FGroupName;
end;

function TboLogin.GetHoldingKey: Integer;
var
  ibsql: TIBSQL;
begin
  Assert(Assigned(gdcBaseManager));
  Assert(Assigned(gdcBaseManager.ReadTransaction));
  Assert(gdcBaseManager.ReadTransaction.InTransaction);

  if IsHolding then
    Result := CompanyKey
  else begin
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcBaseManager.ReadTransaction;

      ibsql.SQL.Text := 'SELECT holdingkey FROM gd_holding WHERE companykey = :key';
      ibsql.ParamByName('key').AsInteger := CompanyKey;
      ibsql.ExecQuery;

      if not ibsql.Eof then
      begin
        Result := ibsql.Fields[0].AsInteger;
      end else
        Result := -1;
    finally
      ibsql.Free;
    end;
  end;
end;


function TboLogin.GetHoldingList: String;
var
  ibsql: TIBSQL;
begin
  Assert(Assigned(gdcBaseManager));

  if FHoldingListCache > '' then
    Result := FHoldingListCache
  else begin
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcBaseManager.ReadTransaction;

      ibsql.SQL.Text := 'SELECT companykey FROM gd_holding WHERE holdingkey = :holdingkey';
      ibsql.ParamByName('holdingkey').AsInteger := IBLogin.CompanyKey;
      ibsql.ExecQuery;

      Result := IntToStr(IbLogin.CompanyKey);
      while not ibsql.Eof do
      begin
        Result := Result + ',' + ibsql.FieldByName('companykey').AsString;
        ibsql.Next;
      end;

      FHoldingListCache := Result;
    finally
      ibsql.Free;
    end;
  end;
end;

function TboLogin.GetIBName: String;
begin
  Result := FIBName;
end;

function TboLogin.GetIBPassw: String;
begin
  Result := FIBPassword;
end;

function TboLogin.GetIBRole: String;
var
  ibsql: TIBSQL;
  ibtr: TIBTransaction;
begin

  if (FIBRole = '') and Assigned(Database) then
  begin
    ibsql := TIBSQL.Create(nil);
    ibtr := TIBTransaction.Create(nil);
    try
      ibtr.DefaultDatabase := Database;
      ibsql.Transaction := ibtr;
      ibtr.StartTransaction;
      ibsql.SQL.Text := 'SELECT CURRENT_ROLE FROM rdb$database';
      ibsql.ExecQuery;
      FIBRole := ibsql.Fields[0].AsString;
      ibtr.Commit;
    finally
      ibsql.Free;
      ibtr.Free;
    end;
  end;
  Result := FIBRole;
end;

function TboLogin.GetIngroup: Integer;
begin
  Result := FIngroup;
  if ((FIngroup and 1) = 0) and (IsIBUserAdmin) then
    Result := Result or 1;
end;

function TboLogin.GetIsHolding: Boolean;
var
  ibsql: TIBSQL;
begin
  if FHoldingCacheKey = IBLogin.CompanyKey then
  begin
    Result := FHoldingCacheValue;
  end else
  begin
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcBaseManager.ReadTransaction;
      ibsql.SQL.Text := 'SELECT companykey FROM gd_holding WHERE holdingkey = :holdingkey';
      ibsql.ParamByName('holdingkey').AsInteger := IBLogin.CompanyKey;
      ibsql.ExecQuery;

      Result := ibsql.RecordCount > 0;

      FHoldingCacheValue := Result;
      FHoldingCacheKey := IBLogin.CompanyKey;
    finally
      ibsql.Free;
    end;
  end;
end;

function TboLogin.GetIsIBUserAdmin: Boolean;
begin
  Result := FIsIBUserAdmin;
end;

function TboLogin.GetIsShutDown: Boolean;
begin
  Result := FShutDown;
end;

function TboLogin.GetIsUserAdmin: Boolean;
begin
  Result := Boolean(FIngroup and 1) or IsIBUserAdmin;
end;

function TboLogin.GetLoggedIn: Boolean;
begin
  Result := (FIBBase.Database <> nil) and FIBBase.Database.Connected;
end;

function TboLogin.GetLoggingOff: Boolean;
begin
  Result := FLoggingOff;
end;

function TboLogin.GetLoginParam(ParamName: String): String;
begin
  Result := FParams.Values[ParamName];
end;

function TboLogin.GetServerName: String;
var
  A, B, I: Integer;
begin
  A := -1;
  for I := 1 to Length(DatabaseName) do
    if DatabaseName[I] = ':' then
    begin
      A := I;
      break;
    end;

  B := -1;
  if A > 0 then
  begin
    for I := A + 1 to Length(DatabaseName) do
      if DatabaseName[I] = ':' then
      begin
        B := I;
        break;
      end;
  end;    

  if A < 2 then
    Result := ''
  else begin
    Result := Copy(DatabaseName, 1, A - 1);

    if B = -1 then
    begin
      if (A = 2) and (A < Length(DatabaseName)) and (DatabaseName[A + 1] in ['\', '/']) then
        Result := '';
    end;
  end;  
end;

function TboLogin.GetSessionDuration: TDateTime;
begin
  Result := Now - FStartTime;
end;

function TboLogin.GetSessionKey: Integer;
begin
  Result := FSessionKey;
end;

function TboLogin.GetShutDown: Boolean;
begin
  Result := FShutDown;
end;

function TboLogin.GetShutDownRequested: Boolean;
begin
  Result := FShutDownRequested;
end;

function TboLogin.GetStartTime: TDateTime;
begin
  Result := FStartTime;
end;

function TboLogin.GetSubSystemKey: Integer;
begin
  Result := FSubSystemKey;
end;

function TboLogin.GetSubSystemName: String;
begin
  Result := FSubSystemName;
end;

function TboLogin.GetUserKey: Integer;
begin
  Result := FUserKey;
end;

function TboLogin.GetUserName: String;
begin
  Result := FUserName;
end;

function TboLogin.Login(ReadParams: Boolean = True; ReLogin: Boolean = False): Boolean;
begin
  //
  //  Осущствляем проверку подключения


  if LoggedIn then
    raise EboLoginError.Create('Can''t login twice!');

  if Assigned(gdSplash) then
    gdSplash.ShowText(sDBConnect);

  FLoginInProgress := True;
  FShouldReadParams := ReadParams;
  FReLogining := ReLogin;
  try
    //
    //  Если осуществляется подключение
    //  первый раз - считываем параметры,

    if not FReLogining then
    begin
      FParams.Clear;

      //
      //  Сначала загружаем установки из реестра,
      //  затем из командной строки

      ReadRegistryLoginParams;
      ReadCommandLineLoginParams;
    end else

    //
    //  иначе - работаем с уже имеющимися

    begin
      FParams.Values[UserNameValue] := FLastUserName;
      FParams.Values[PasswordValue] := FLastPassword;
    end;

    //
    //  Непосредственно осуществляем подключение
    //  и открытие компании

    EstablishConnection;

    Result := LoggedIn;

    if Result then
    begin
      Assert(atDatabase <> nil, 'Не создана база атрибутов');
      try
        if Assigned(gdSplash) then
          gdSplash.ShowText(sReadingDbScheme);

        InitDatabase(dmDatabase.ibdbGAdmin, dmLogin.ibtrAttr);
        //Будем обязательно перечитывать базу
        atDatabase.ProceedLoading(True);
      except
        on E:Exception do
        begin
          Database.Connected := False;
          Result := False;
          if Assigned(gdSplash) then
            gdSplash.FreeSplash;
          raise;
        end;
      end;

      DoAfterSuccessfullConnection;
    end;
    //
    //  Осуществляем открытие компании
    try
      if Result and FAutoOpenCompany and (not EnterCompany) then
        Result := OpenCompany;
    except
      Result := False;
    end;

  finally
    FShouldReadParams := False;
    FReLogining := False;
    FLoginInProgress := False;
  end;
end;

function TboLogin.LoginSilent(AnUserName, APassword: String; const ADBPath: string = ''): Boolean;
begin
  //
  //  Осущствляем проверку подключения

  if LoggedIn then
    raise EboLoginError.Create('Can''t login twice!');

  FLoginInProgress := True;
  FReLogining := True;
  FSilentLogin := True;
  try
    FParams.Clear;

    if ADBPath = '' then
      ReadRegistryLoginParams
    else
      FParams.Values[ServerNameValue]:= ADBPath;
    ReadCommandLineLoginParams;

    FParams.Values[UserNameValue] := AnUserName;
    FParams.Values[PasswordValue] := APassword;

    if FParams.IndexOfName(Lc_ctypeValue) = -1 then
      FParams.Add(Lc_ctypeValue + '=win1251');

    //
    //  Непосредственно осуществляем подключение
    //  и открытие компании

    EstablishConnection;

    Result := LoggedIn;

    if Result then begin
      Assert(atDatabase <> nil, 'Не создана база атрибутов');
      try
        InitDatabase(dmDatabase.ibdbGAdmin, dmLogin.ibtrAttr);
        //Будем обязательно перечитывать базу
        atDatabase.ProceedLoading(True);
      except
        on E:Exception do
        begin
          Database.Connected := False;
          Result := False;
          if Assigned(gdSplash) then
            gdSplash.FreeSplash;
        end;
      end;
      DoAfterSuccessfullConnection;
    end;
    //
    //  Осуществляем открытие компании

    if Result and (not FAutoOpenCompany or not EnterCompany) then
      OpenCompany

  finally
    FLoginInProgress := False;
    FReLogining := True;
  end;
end;

function TboLogin.LoginSingle: Boolean;
begin
  FShutDownRequested := True;

  try
    Result := Login(False);
  finally
    FShutDownRequested := False;
  end;
end;

function TboLogin.Logoff: Boolean;
begin
  if LoggedIn then
  begin
    Result := False;

    if not TestConnection then
    begin
      ConnectionLost;
      FSilentLogin := False;
      Exit;
    end;
  end else
    raise EboLoginError.Create('You havn''t logged in yet!');

  FLoggingOff := True;
  try

    DoBeforeDisconnect;

    // DoBeforeChangeCompany поставили после DoBeforeDisconnect
    // для избежания двойного сохранения CompanyStorage
    if FCompanyOpened then
      DoBeforeChangeCompany;

    CloseConnection;

    //
    //  Если база данных была переведена в однопользовательский
    //  режим - необходимо восстановить ее.

    if FShutDownRequested and FShutDown then
    with TgsDatabaseShutdown.Create(Self) do
    try
      Database := Self.Database;
      ShowUserDisconnectDialog := False;
      FShutDown := IsShutdowned;

      if FShutDown then
        FShutDown := not BringOnline;

      if not FShutDown then
      begin
        FShutDownRequested := False;
        WriteShutDownKey(False);
      end;
    finally
      Free;
    end;

    Result := not LoggedIn;

    if Result then
      FSilentLogin := False;
  finally
    FLoggingOff := False;
  end;
end;

function TboLogin.OpenCompany(const ShowDialogAnyway: Boolean = False;
  const CK: Integer = -1; const CN: String = ''): Boolean;
var
  ACompanyKey: Integer;
  ACompanyName: String;
  Res: OleVariant;
begin
  if not LoggedIn and (not FLoginInProgress) then
    raise EboLoginError.Create('You havn''t logged in yet!');

  ACompanyKey := CK;
  ACompanyName := CN;

  if ACompanyKey = -1 then
  begin
    Assert(Assigned(gdcBaseManager));

    gdcBaseManager.ExecSingleQueryResult(
      'SELECT companykey FROM gd_userCompany WHERE userkey = ' +
        IntToStr(IBLogin.UserKey),
      Null,
      Res);

    if not VarIsEmpty(Res) then
      ACompanyKey := Res[0, 0];

    if ACompanyKey = -1 then
    begin
      gdcBaseManager.ExecSingleQueryResult(
        'SELECT companykey FROM gd_ourcompany WHERE disabled IS NULL OR disabled = 0 ',
        Null,
        Res);

      if (not VarIsEmpty(Res)) and (VarArrayHighBound(Res, 2) = 0) then
        ACompanyKey := Res[0, 0]
      else
        ACompanyKey := TgdcOurCompany.SelectObject(
          'Выберите активную организацию из предложенного списка:',
          'Активная организация',
          63);
    end;

    Result := (ACompanyKey <> -1) and
      ((Self.CompanyKey <> ACompanyKey) or (not FCompanyOpened));

    if Result then
    begin
      TgdcOurCompany.SaveOurCompany(ACompanyKey);
      ACompanyName := TgdcOurCompany.GetListNameByID(ACompanyKey);
    end;
  end else
  begin
    Result := True;
    TgdcOurCompany.SaveOurCompany(ACompanyKey);
  end;

  if Result then
  begin
    // Удаляем все формы
    FreeAllForms(False);

    // передаем управление через сообщение
    with TboLoginControlNexus(FLoginControlNexus) do
    begin
      FNewCompanyKey := ACompanyKey;
      FNewCompany := ACompanyName;
    end;
    PostMessage(FLoginControlNexus.Handle, WM_FINISHOPENCOMPANY, 0, 0);
  end;
end;

procedure TboLogin.ProceedOpenCompany(NewCompanyKey: Integer; NewCompany: String);
begin
  if FCompanyOpened then DoBeforeChangeCompany;

  Self.FCompanyKey := NewCompanyKey;
  Self.FCompanyName := NewCompany;

  FCompanyOpened := True;
  if DataBase.Connected = False then
    DataBase.Connected := True;
  DoAfterChangeCompany;
end;

procedure TboLogin.ReadCommandLineLoginParams;
begin
  UnMethodMacro := gd_CmdLineParams.Unmethod;
  UnEventMacro := gd_CmdLineParams.Unevent;

  if gd_CmdLineParams.UserPassword > '' then
  begin
    if FShouldReadParams then
      FParams.Values[PasswordValue] := gd_CmdLineParams.UserPassword;
    PasswordParamExists := True;
  end;

  if gd_CmdLineParams.UserName > '' then
  begin
    if FShouldReadParams then
      FParams.Values[UserNameValue] := gd_CmdLineParams.UserName;
    UserParamExists := True;
  end;

  if gd_CmdLineParams.ServerName > '' then
  begin
    FParams.Values[ServerNameValue] := gd_CmdLineParams.ServerName;
  end;

  if gd_CmdLineParams.UseLog then
    UseLog := True;

  if gd_CmdLineParams.SaveLogToFile then
  begin
    UseLog := True;
    SaveLogToFile := True;
  end;

  if gd_CmdLineParams.LoadSettingPath > '' then
  begin
    LoadSettingPath := gd_CmdLineParams.LoadSettingPath;
  end;

  if gd_CmdLineParams.LoadSettingFileName > '' then
  begin
    LoadSettingFileName := gd_CmdLineParams.LoadSettingFileName;
  end;
end;

procedure TboLogin.ReadRegistryLoginParams;
var
  Reg: TRegistry;
  Param: String;
begin
{ TODO : этот кусок кода повторяется в слегка измененном виде раз пять по всему гедемину }
  FParams.Values[ServerNameValue] := '';
  FParams.Values[Lc_ctypeValue] := DefaultLc_ctype;

  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := ClientRootRegistryKey;

    if Reg.OpenKeyReadOnly(ClientRootRegistrySubKey) then
    begin
      //
      //  Наименование сервера
      if Reg.ValueExists(ServerNameValue) and (Trim(FParams.Values[ServerNameValue]) = '') then
        FParams.Values[ServerNameValue] := Reg.ReadString(ServerNameValue);

      //
      //  Кодировка
      if Reg.ValueExists(Lc_ctypeValue) then
      begin
        Param := Reg.ReadString(Lc_ctypeValue);

        if Param > '' then
          FParams.Values[Lc_ctypeValue] := Param;
      end;

      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

function TboLogin.ReadShutDownKey: Boolean;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ);

  try
    Reg.RootKey := ClientRootRegistryKey;

    if
      Reg.OpenKeyReadOnly(ClientRootRegistrySubKey) and
      Reg.ValueExists(ShutDownValue)
    then
      Result := Reg.ReadBool(ShutDownValue)
    else
      Result := False;
  finally
    Reg.CloseKey;
    Reg.Free;
  end;
end;

procedure TboLogin.RemoveCompanyNotify(Notify: ICompanyChangeNotify);
begin
  FCompanyNotifiers.Extract(Pointer(Notify));
  ClearHoldingListCache;
end;

procedure TboLogin.RemoveConnectNotify(Notify: IConnectChangeNotify);
begin
  FConnectNotifiers.Extract(Pointer(Notify));
end;

function TboLogin.RunChangePassDialog: Boolean;
var
  ibsql: TIBSQL;
begin
  with TdlgChangePass.Create(Self) do
  try
    UserName := FUserName;

    if Execute then
    begin
      ibsql := TIBSQL.Create(nil);
      try
        if not FTransaction.Active then
          FTransaction.StartTransaction;

        ibsql.Transaction := FTransaction;
        ibsql.SQL.Text :=
          'UPDATE gd_user SET passw = ''' + edPassword.Text +
          ''', mustchange = 0 WHERE id = ' + IntToStr(UserKey);

        try
          ibsql.ExecQuery;
          if FTransaction.InTransaction then
            FTransaction.Commit;

          Result := True;
        except
          if FTransaction.InTransaction then
            FTransaction.Rollback;

          Result := False;
        end;
      finally
        ibsql.Free;
      end;
    end else
      Result := False;
  finally
    Free;
  end;
end;

function TboLogin.RunLoginDialog(UnderDatabase: TIBDatabase): Boolean;
begin
  with TdlgSecLogIn.Create(Self) do
  try
    Database := UnderDatabase;

    SubSystemKey := FSubSystemKey;

    if FShouldReadParams or FReLogining then
    begin
      if FParams.Values[UserNameValue] > '' then
        UserName := FParams.Values[UserNameValue];

      if FParams.Values[PasswordValue] > '' then
        Password := FParams.Values[PasswordValue];
    end;

    PrepareSelf;
    OnConnectionParams := DoOnConnectionParams;

    AdminRightsrequest := FShutDownRequested;
    Result := DoLogin;

    FChangePass := ChangePass;
  finally
    Free;
  end;
end;

procedure TboLogin.SetDatabase(const Value: TIBDatabase);
begin
  FIBBase.Database := Value;
  FTransaction.DefaultDatabase := Value;
end;

procedure TboLogin.SetIngroup(const Value: Integer);
begin
  if FIngroup <> Value then
    FIngroup := Value;
end;

procedure TboLogin.SetSubSystemKey(const Value: Integer);
begin
  if not LoggedIn then
    FSubSystemKey := Value
  else
    raise EboLoginError.Create('Can''t set subsystemkey after log in!');
end;

function TboLogin.TestConnection: Boolean;
begin
  Result := True;
end;

procedure TboLogin.UpdateCompanyData;
begin
//
end;

procedure TboLogin.UpdateDatabaseProperties;
begin
  with Database do
  begin
    Params.Values[UserNameValue] := FIBName;
    Params.Values[PasswordValue] := FIBPassword;
    Params.Values[Lc_ctypeValue] := FParams.Values[Lc_ctypeValue];
    Params.Values[SQL_Role_NameValue] := DefaultSQL_Role_Name;
    DatabaseName := FParams.Values[ServerNameValue];
  end;
end;

procedure TboLogin.UpdateUserData;
var
  Transaction: TIBTransaction;
  q: TIBSQL;
begin
  Transaction := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Transaction.DefaultDatabase := Database;
    Transaction.StartTransaction;
    q.Transaction := Transaction;
    q.Database := Database;
    q.SQL.Text := Format('SELECT ingroup FROM gd_user WHERE id=%d', [UserKey]);
    q.ExecQuery;
    FInGroup := q.Fields[0].AsInteger;
  finally
    q.Free;
    Transaction.Free;
  end;
end;

procedure TboLogin.WriteShutDownKey(const AShutDown: Boolean);
var
  R: TRegistry;
begin
  R := TRegistry.Create;
  try
    R.RootKey := ClientRootRegistryKey;

    if R.OpenKey(ClientRootRegistrySubKey, True) then
    begin
      R.WriteBool(ShutDownValue, AShutDown);
      R.CloseKey;
    end;
  finally
    R.Free;
  end;
end;

procedure TboLoginControlNexus.WMConnectionLost(var Msg: TMessage);
begin
  inherited;
  FLogin.ConnectionLost;
end;

procedure TboLogin.ChangeUser(const AUserKey: Integer;
  const ACheckMultipleConnections: Boolean = False);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  if AUserKey = FUserKey then
    exit;

  if IsIBUserAdmin then
    raise EboLoginError.Create('Can not change Administrator account.');

  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := Database;
    Tr.StartTransaction;

    q.Transaction := Tr;

    if ACheckMultipleConnections then
    begin
      q.SQL.Text := 'select * from mon$attachments where mon$user=' +
        '(select ibname from gd_user WHERE id=:id)';
      q.ParamByName('ID').AsInteger := AUserKey;
      q.ExecQuery;
      if not q.EOF then
        raise EboLoginError.Create(
          'Кто-то уже подключен к базе данных под данной учетной записью.'#13#10 +
          'Системными установками вторичные подключения запрещены.');
    end;

    q.Close;
    q.SQL.Text :=
      'SELECT * FROM gd_user WHERE id = :ID ' +
      'AND disabled = 0 AND lockedout = 0 ' +
      'AND COALESCE(workstart, ''00:00:00'') <= CURRENT_TIME ' +
      'AND COALESCE(workend, ''23:59:59'') >= CURRENT_TIME';
    q.ParamByName('ID').AsInteger := AUserKey;
    q.ExecQuery;

    if q.EOF then
      raise Exception.Create('Invalid user key or account disabled.');

    if AnsiCompareText(q.FieldByName('IBName').AsString, SysDBAUserName) = 0 then
      raise EboLoginError.Create('Can not switch to Administrator account.');

    FIBName := q.FieldByName('IBName').AsString;
    FIBPassword := q.FieldByName('IBPassword').AsString;
    FIsIBUserAdmin := AnsiCompareText(FIBName, SysDBAUserName) = 0;

    FStartTime := Now;
    FUserKey := AUserKey;
    FIngroup := q.FieldByName('InGroup').AsInteger;
    if FInGroup = 0 then FInGroup := 1;
    FContactKey := q.FieldByName('ContactKey').AsInteger;

    FGroupName := TgdcUserGroup.GetGroupList(FInGroup);
    FUserName := q.FieldByName('Name').AsString;

    FAllowUserAudit := q.FieldByName('allowaudit').AsInteger <> 0;

    q.Close;
    q.SQL.Text := 'SELECT GEN_ID(gd_g_session_id, 1) FROM rdb$database ';
    q.ExecQuery;
    FSessionKey := q.Fields[0].AsInteger;

    q.Close;
    q.SQL.Text :=
      'execute block '#13#10 +
      'as '#13#10 +
      'begin '#13#10 +
      '  RDB$SET_CONTEXT(''USER_SESSION'', ''GD_INGROUP'', (SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER)); '#13#10 +
      'end';
    q.ExecQuery;  

    UserStorage.ObjectKey := AUserKey;

    if Application.MainForm <> nil then
      Application.MainForm.Caption := IBLogin.GetMainWindowCaption;
    Application.Title := GetMainWindowCaption;
  finally
    q.Free;
    Tr.Free;
  end;
end;

function TboLogin.GetReLogining: Boolean;
begin
  Result := FReLogining;
end;

procedure TboLogin.ReadDBVersion;
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  if (Database <> nil) and Database.Connected then
  begin
    Tr := TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);
    try
      Tr.DefaultDatabase := Database;
      Tr.StartTransaction;

      q.Transaction := Tr;
      q.SQL.Text := 'SELECT FIRST 1 * FROM fin_versioninfo ORDER BY id DESC';
      q.ExecQuery;

      FDBVersion := q.FieldByName('versionstring').AsString;
      FDBReleaseDate := q.FieldByName('releasedate').AsDateTime;
      FDBVersionID := q.FieldByName('id').AsInteger;
      FDBVersionComment := q.FieldByName('comment').AsString;

      q.Close;
      Tr.Commit;
    finally
      q.Free;
      Tr.Free;
    end;
  end;
end;

function TboLogin.IsSilentLogin: Boolean;
begin
  Result := FSilentLogin;
end;

function TboLogin.GetMainWindowCaption: String;
begin
  {$IFNDEF BMKK}
  Result := 'Гедымин - ' + CompanyName + ' - ' + UserName;
  {$ENDIF}

  {$IFDEF NOGEDEMIN}
  Result := CompanyName + ' - ' + UserName;
  {$ENDIF}

  {$IFDEF DEBUG}
  Result := Format('%s, IBX: %s, JCL: %d.%d, ZLIB: %s, Started: %s',
    [Caption, FloatToStr(IBX_Version), JclVersionMajor, JclVersionMinor, {ZLIB_Version}'xxx',
     FormatDateTime('hh:nn', Now)]);
  Result := Result + ', ' + 'DEBUG MODE';
  {$ENDIF}
end;

function TboLogin.GetIsEmbeddedServer: Boolean;
var
  Res: OleVariant;
begin
  if LoggedIn then
  begin
    gdcBaseManager.ExecSingleQueryResult(
      'SELECT mon$remote_protocol FROM mon$attachments WHERE mon$attachment_id = CURRENT_CONNECTION'
      Null,
      Res);
    Result := (not VarIsEmpty(Res)) and VarIsNull(Res[0, 0]);
  end else
    Result := False;
end;

end.



