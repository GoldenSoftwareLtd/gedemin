
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

    FShutDown: Boolean;

    FLoginInProgress: Boolean;
    FShutDownRequested: Boolean;

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

    FSilentLogin: Boolean;

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
    function GetServerName: String;
    function GetDBID: Integer;
    function GetIsHolding: Boolean;
    function GetHoldingList: String;
    function GetHoldingKey: Integer;
    function GetActiveAccount: Integer;
    function GetIBRole: String;
    function GetReLogining: Boolean;

    procedure OnModifyLog(const AnLogText: String);
    function GetMainWindowCaption: String;
    function GetIsEmbeddedServer: Boolean;
    function BringOnline(const ADBName: String = ''): Boolean;
    function DoConnect: Boolean;
    function DoLogin(NeedReadDBVersion: Boolean): Boolean;

  protected
    function CloseConnection: Boolean;
    function TestConnection: Boolean;

    function RunChangePassDialog: Boolean;

    function EnterCompany: Boolean;

    procedure ConnectionLost;

    procedure DoBeforeChangeCompany;
    procedure DoAfterChangeCompany;
    procedure DoAfterSuccessfullConnection;
    procedure DoBeforeDisconnect;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function LoginSingle: Boolean;

    function Login: Boolean;
    function LoginSilent(AnUserName: String; APassword: String; const ADBPath: string = ''): Boolean;
    function Logoff: Boolean;
    function Relogin: Boolean;
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
  Registry,                 gd_directories_const, jclStrings,
  gd_createable_form,       gd_frmBackup_unit,    gd_CmdLineParams_unit,
  gd_resourcestring,        gsDatabaseShutdown,   gd_security_dlgChangePass,
  jclSysInfo,               gdcUser,              mtd_i_Base,
  evt_i_base,               IBStoredProc,         gd_splash,
  gd_DebugLog,              gdcJournal,           dm_i_ClientReport_unit,
  inst_const,               gdcContacts,          dmDataBase_unit,
  at_classes_body,          at_classes,           dmLogin_unit,
  IBServices,               DBLogDlg,             at_frmSQLProcess,
  Storages,                 mdf_proclist,         gdModify,
  IBDatabaseInfo,           gd_DatabasesList_unit,gd_security_operationconst,
  IBErrorCodes,             gd_common_functions 
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

{ TboLogin }

procedure TboLogin.AddCompanyNotify(Notify: ICompanyChangeNotify);
begin
  Assert(Notify <> nil);
  if FCompanyNotifiers.IndexOf(Pointer(Notify)) = -1 then
  begin
    FCompanyNotifiers.Add(Pointer(Notify));
    ClearHoldingListCache;
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
begin
  Assert(Database <> nil);

  Result := True;
  try
    try
      Database.Connected := False;
    except
      on E: Exception do
        Application.ShowException(E);
    end;

    if Database.Connected then
      Database.ForceClose;

    FCompanyOpened := False;
    FDBIDRead := False;
  except
    on E: Exception do
    begin
      Application.ShowException(E);
      Result := False;
    end;
  end;

  if Result and Shutdown and IsIBUserAdmin then
    BringOnline(Database.DatabaseName);
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

  FConnectNotifiers := TList.Create;
  FCompanyNotifiers := TList.Create;

  FShutDown := False;

  FLoginInProgress := False;
  FShutDownRequested := False;

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

  FLoginControlNexus.Free;

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
  if Assigned(gdSplash) then
    gdSplash.ShowText(sReadingDbScheme);

  InitDatabase(dmLogin.ibtrAttr);
  atDatabase.ProceedLoading(True);

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

function TboLogin.EnterCompany: Boolean;
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Database <> nil);
  Assert(Database.Connected);
  Assert(UserKey > -1);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := Database;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT uc.companykey AS CompanyKey, oc.afull AS AFull, c.name AS CompanyName ' +
      'FROM gd_usercompany uc JOIN gd_contact c ON c.id = uc.companykey  ' +
      '  JOIN gd_ourcompany oc ON oc.companykey = c.id ' +
      'WHERE uc.userkey = :UK';
    q.ParamByName('UK').AsInteger := UserKey;
    q.ExecQuery;

    if q.EOF then
    begin
      q.Close;
      q.SQL.Text :=
        'SELECT oc.companykey AS CompanyKey, c.afull AS AFull, c.name AS CompanyName ' +
        'FROM gd_ourcompany oc JOIN gd_contact c ON c.id = oc.companykey ';
        //'WHERE BIN_AND(BIN_OR(oc.afull, 1), :ig) <> 0';
        //q.ParamByName('ig').AsInteger := InGroup;
      q.ExecQuery;
    end;

    if (not q.EOF) and
      (((q.FieldByName('afull').AsInteger or 1) and Ingroup) <> 0) then
    begin
      if FCompanyOpened then DoBeforeChangeCompany;
      FCompanyKey := q.FieldByName('CompanyKey').AsInteger;
      FCompanyName := q.FieldByName('CompanyName').AsString;
      FCompanyOpened := True;
      DoAfterChangeCompany;
    end else
    begin
      MessageBox(0,
        PChar('У пользователя ' + FUserName + ' нет прав доступа к выбранной '#13#10 +
        'рабочей организации "' + q.FieldByName('CompanyName').AsString + '".'#13#10#13#10 +
        'Зайдите под учетной записью Administrator и установите'#13#10 +
        'в справочнике клиентов полные права доступа на эту организацию.'),
        'Внимание',
        MB_OK or MB_ICONHAND or MB_TASKMODAL);
      FCompanyKey := -1;
      FCompanyName := '';
    end;

    Result := FCompanyName > '';

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
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
  if Database <> nil then
    Result := Database.DatabaseName
  else
    Result := '';
end;

function TboLogin.GetDBID: Integer;
var
  q: TIBSQL;
begin
  Assert(gdcBaseManager <> nil);
  if (not FDBIDRead) and Database.Connected then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text := 'SELECT GEN_ID(gd_g_dbid, 0) FROM rdb$database';
      q.ExecQuery;
      FDBID := q.Fields[0].AsInteger;
      FDBIDRead := True;
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
      ibsql.SQL.Text := 'SELECT LIST(companykey, '','') FROM gd_holding WHERE holdingkey = :holdingkey';
      ibsql.ParamByName('holdingkey').AsInteger := IBLogin.CompanyKey;
      ibsql.ExecQuery;
      Result := IntToStr(IBLogin.CompanyKey);
      if (not ibsql.EOF) and (ibsql.Fields[0].AsString > '') then
        Result := Result + ',' + ibsql.Fields[0].AsString;
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
begin
  Assert(gdcBaseManager <> nil);
  if FIBRole = '' then
  begin
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcBaseManager.ReadTransaction;
      ibsql.SQL.Text := 'SELECT CURRENT_ROLE FROM rdb$database';
      ibsql.ExecQuery;
      FIBRole := ibsql.Fields[0].AsString;
    finally
      ibsql.Free;
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
  if Database <> nil then
    Result := Database.Params.Values[ParamName]
  else
    Result := '';  
end;

function TboLogin.GetServerName: String;
var
  Port: Integer;
  Server, FileName: String;
begin
  ParseDatabaseName(DatabaseName, Server, Port, FileName);
  Result := Server;
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

function TboLogin.Login: Boolean;

  procedure InitDBID(AQ: TIBSQL);
  begin
    // каждая база данных должна иметь свой уникальный идентификатор, который
    // содержится в генераторе GD_G_DBID. сгенерированная, эталонная база
    // имеет идентификатор равный нулю. при каждом подключении мы проверяем,
    // если идентификатор базы равен нулю, то это первое подключение к чистой
    // базе и надо установить ей DBID.
    AQ.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      'BEGIN ' +
      '  IF ((SELECT GEN_ID(gd_g_dbid, 0) FROM rdb$database) = 0) THEN ' +
      '    EXECUTE STATEMENT ''SET GENERATOR gd_g_dbid TO ' + IntToStr(gdcBaseManager.GenerateNewDBID) + '''; ' +
      'END';
    AQ.ExecQuery;
    AQ.Close;
  end;

  function CreateStartUser(const ADBName: String): Boolean;
  var
    DB: TIBDatabase;
    Tr: TIBTransaction;
    q: TIBSQL;
    FSysDBAPassword, FSysDBAUserName: String;
    Server, FileName: String;
    Port: Integer;
  begin
    Result := False;

    FSysDBAPassword := 'masterkey';
    FSysDBAUserName := SysDBAUserName;

    DB := TIBDatabase.Create(nil);
    Tr := TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);
    try
      repeat
        try
          DB.LoginPrompt := False;
          DB.SQLDialect := 3;
          DB.Params.Clear;
          DB.Params.Add('user_name=' + FSysDBAUserName);
          DB.Params.Add('password=' + FSysDBAPassword);
          DB.DatabaseName := ADBName;
          DB.Connected := True;
        except
          FSysDBAPassword := '';
          ParseDatabaseName(ADBName, Server, Port, FileName);
          if Server = '' then Server := 'Firebird';
          MessageBox(0,
            PChar('Сервер ' + Server + ' должен быть настроен для подключения платформы Гедымин.'),
            'Внимание',
            MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
          if not InputQuery(Server, 'Введите пароль учетной записи SYSDBA:', FSysDBAPassword) then
            exit;
        end;
      until DB.Connected;

      Tr.DefaultDatabase := DB;
      Tr.StartTransaction;

      q.Transaction := Tr;
      try
        q.SQL.Text := 'DROP USER STARTUSER';
        q.ExecQuery;
        Tr.Commit;
      except
        Tr.Rollback;
      end;

      Tr.StartTransaction;
      q.SQL.Text := 'CREATE USER STARTUSER PASSWORD ''startuser'' ';
      q.ExecQuery;
      Tr.Commit;

      Result := True;
    finally
      q.Free;
      Tr.Free;
      DB.Free;
    end;
  end;

  function ShutdownDatabase(const ADBName: String): Boolean;
  var
    SN, DN, FSysDBAPassword, FSysDBAUserName: String;
    Port: Integer;
    CS: TIBConfigService;
  begin
    Result := False;

    ParseDatabaseName(ADBName, SN, Port, DN);

    if (DN = '') or (MessageBox(0,
      PChar('В процессе перевода все пользователи будут отключены.'#13#10#13#10 +
      'Перевести БД в однопользовательский режим?'),
      'Внимание',
      MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDNO) then
    begin
      exit;
    end;

    FSysDBAPassword := SysDBAPassword;
    FSysDBAUserName := SysDBAUserName;

    CS := TIBConfigService.Create(nil);
    try
      CS.ServerName := SN;
      CS.DatabaseName := DN;
      if SN > '' then
        CS.Protocol := TCP
      else
        CS.Protocol := Local;
      CS.LoginPrompt := False;
      CS.Params.Clear;
      CS.Params.Add('user_name=' + FSysDBAUserName);
      CS.Params.Add('password=' + FSysDBAPassword);

      repeat
        try
          CS.Active := True;
          CS.ShutdownDatabase(smeForce, 0, omSingle);
          // на классике сервер сразу возвращает выполнение
          // и последующее подключение не пройдет, так как
          // база еще будет переводиться в шатдауна.
          // вроде бы, начиная с версии 2.1 эта пауза уже не
          // будет нужна
          Sleep(4000);
          while CS.IsServiceRunning do Sleep(100);
          Result := True;
        except
          on E: Exception do
          begin
            MessageBox(0, PChar(E.Message), 'Внимание!', MB_OK or MB_ICONHAND or MB_TASKMODAL);
            FSysDBAPassword := '';
            if not InputQuery(SN, 'Введите пароль учетной записи SYSDBA:', FSysDBAPassword) then
              exit;
          end;
        end;
      until Result;
    finally
      CS.Free;
    end;
  end;

  procedure ReadConnectionParams(ASP: TIBStoredProc);
  begin
    FDBVersion := ASP.ParamByName('DBVersion').AsString;
    FDBReleaseDate := ASP.ParamByName('DBReleaseDate').AsDateTime;
    FDBVersionID := ASP.ParamByName('DBVersionID').AsInteger;
    FDBVersionComment := ASP.ParamByName('DBVersionComment').AsString;

    FIBName := ASP.ParamByName('ibname').AsString;
    FIBPassword := ASP.ParamByName('ibpassword').AsString;
    FIBRole := '';
    FIsIBUserAdmin := AnsiCompareText(FIBName, SysDBAUserName) = 0;

    FStartTime := Now;
    FUserKey := ASP.ParamByName('UserKey').AsInteger;
    FIngroup := ASP.ParamByName('Ingroup').AsInteger;
    if FInGroup = 0 then FInGroup := 1;
    FContactKey := ASP.ParamByName('ContactKey').AsInteger;

    FSessionKey := ASP.ParamByName('Session').AsInteger;
    FSubSystemName := ASP.ParamByName('SubsystemName').AsString;
    FGroupName := ASP.ParamByName('GroupName').AsString;
    FUserName := ASP.ParamByName('username').AsString;

    FAuditLevel := TAuditLevel(ASP.ParamByName('auditlevel').AsInteger);
    FAuditCache := ASP.ParamByName('auditcache').AsInteger;
    FAuditMaxDays := ASP.ParamByName('auditmaxdays').AsInteger;
    FAllowUserAudit := ASP.ParamByName('allowuseraudit').AsInteger <> 0;

    FLastUserName := FUserName;
    FLastPassword := ASP.ParamByName('passw').AsString;
  end;

  function StartUserConnect(out WithoutConnection, SingleUserMode: Boolean): Boolean;
  var
    DI: Tgd_DatabaseItem;
    SP: TIBStoredProc;
    Tr: TIBTransaction;
    q: TIBSQL;
    ErrorString: String;
    ContFlag, FirstPass: Boolean;
  begin
    Assert(not Database.Connected);
    FirstPass := True;
    repeat
      DI := gd_DatabasesList.FindSelected;
      if (DI <> nil) and
        (
          ((DI.DIType = ditCmdLine) and (DI.EnteredLogin > '') and (DI.EnteredPassword > ''))
          or
          (DI.DIType = ditSilent)
        ) then
      begin
        WithoutConnection := False;
        SingleUserMode := False;
        Result := FirstPass;

        if (not Result) and (DI.DIType = ditCmdLine) then
        begin
          MessageBox(0,
            PChar('Проверьте параметры в командной строке:'#13#10#13#10 + CmdLine),
            'Внимание',
            MB_OK or MB_ICONHAND or MB_TASKMODAL);
        end;
      end else
        Result := gd_DatabasesList.LoginDlg(WithoutConnection, SingleUserMode, DI)
          and (DI <> nil);

      if (not Result) or WithoutConnection then
        exit;

      Database.DatabaseName := DI.DatabaseName;
      Database.Params.Values[UserNameValue] := 'STARTUSER';
      Database.Params.Values[PasswordValue] := 'startuser';

      repeat
        ContFlag := True;
        try
          Database.Connected := True;

          Tr := TIBTransaction.Create(nil);
          q := TIBSQL.Create(nil);
          SP := TIBStoredProc.Create(nil);
          try
            Tr.DefaultDatabase := Database;
            Tr.StartTransaction;
            q.Transaction := Tr;
            SP.Transaction := Tr;

            try
              InitDBID(q);

              SP.StoredProcName := 'GD_P_SEC_LOGINUSER';
              SP.Prepare;
              SP.ParamByName('username').AsString := DI.EnteredLogin;
              SP.ParamByName('passw').AsString := DI.EnteredPassword;
              SP.ParamByName('subsystem').AsInteger := GD_SYS_GADMIN;
              SP.ExecProc;
              if SP.ParamByName('result').IsNull then
                raise EboLoginError.Create('Ошибка проверки прав доступа');
            except
              on E: Exception do
              begin
                if not gd_CmdLineParams.QuietMode then
                  MessageBox(0,
                    PChar(
                      'Произошел системный сбой при проверке прав пользователя. '#13#10 +
                      'Возможно, указанная база данных повреждена или не является '#13#10 +
                      'базой данных платформы Гедымин.'#13#10#13#10 +
                      'Ошибка: ' + E.Message),
                      'Внимание',
                    MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
                Result := False;
                exit;
              end;
            end;

            case SP.ParamByName('result').AsInteger of
              GD_LGN_UNKNOWN_SUBSYSTEM:
                ErrorString := 'Код подсистемы задан неверно.';
              GD_LGN_SUBSYSTEM_DISABLED:
                ErrorString := 'Подсистема заблокирована. Вход запрещен.';
              GD_LGN_UNKNOWN_USER:
                ErrorString := 'Имя пользователя задано неверно.';
              GD_LGN_INVALID_PASSWORD:
              begin
                if DI.IsAdminLogin and (DI.EnteredPassword = '') then
                  ErrorString :=
                    'Если это ваше первое подключение к базе данных,'#13#10 +
                    'используйте пароль Administrator для учетной'#13#10 +
                    'записи Administrator.'#13#10#13#10 +
                    'В целях безопасности следует после входа в систему'#13#10 +
                    'изменить стандартный пароль.'#13#10#13#10 +
                    'Это можно сделать в Исследователе, в разделе'#13#10 +
                    'Сервис\Администратор\Пользователи.'#13#10 +
                    'Там же можно создать новые учетные записи'#13#10 +
                    'для всех пользователей системы.'#13#10#13#10 +
                    'Не рекомендуется осуществлять повседневную'#13#10 +
                    'работу с системой под учетной записью Administrator.'
                else
                  ErrorString := sIncorrectPassword;
              end;
              GD_LGN_USER_DISABLED:
                ErrorString := 'Учетная запись пользователя заблокирована.'#13#10 +
                  'Обратитесь к администратору системы.';
              GD_LGN_WORK_TIME_VIOLATION:
                ErrorString := 'Вход не в рабочее время запрещен.';
              GD_LGN_USER_ACCESS_DENIED:
                ErrorString := 'Пользователь не имеет прав на вход в подсистему.';
              GD_LGN_GROUP_DISABLED:
                ErrorString := 'Группы, используемые пользователем, заблокированы.';
              GD_LGN_OK_CHANGE_PASSWORD:
              begin
                ErrorString := '';
                FChangePass := True;
              end;
            else
              ErrorString := '';
            end;

            if ErrorString = '' then
            begin
              if SingleUserMode and
                (AnsiComparetext(SP.ParamByName('ibname').AsString, SysDBAUserName) <> 0) then
              begin
                ErrorString :=
                  'Подключение в однопользовательском режиме '#13#10 +
                  'возможно только под учетной записью Administrator!';
              end else
                ReadConnectionParams(SP);
            end;

            Tr.Commit;
          finally
            SP.Free;
            q.Free;
            Tr.Free;
            Database.Connected := False;
          end;
        except
          on E: EIBError do
          begin
            if IsSilentLogin then
            begin
              Result := False;
              exit;
            end;

            if gd_CmdLineParams.QuietMode then
            begin
              ExitCode := E.IBErrorCode;
              Application.Terminate;
              Abort;
            end;

            if E.IBErrorCode = isc_network_error then
            begin
              ErrorString :=
                'Невозможно получить доступ к серверу ' + DI.Server + '.'#13#10#13#10 +
                'Сообщение об ошибке:'#13#10 + E.Message + #13#10#13#10 +
                'Возможные причины:'#13#10 +
                '1) Неверно указано имя сервера или номер порта.'#13#10 +
                '2) Сервер выключен или не подсоединен к сети.'#13#10 +
                '3) На сервере не установлена СУБД Firebird.'#13#10 +
                '4) Сетевое соединение сервера заблокировано файрволлом.';
            end
            else if E.IBErrorCode = isc_io_error then
            begin
              ErrorString :=
                'Невозможно открыть файл базы данных.'#13#10#13#10 +
                '1) Возможно неверно указано полное имя файла БД.'#13#10 +
                '2) Или к базе данных уже кто-то подключен '#13#10 +
                '   в однопользовательском режиме.'#13#10#13#10 +
                'Сообщение об ошибке:'#13#10 + E.Message;
            end
            else if E.IBErrorCode = isc_login then
            begin
              if CreateStartUser(DI.DatabaseName) then
                ContFlag := False
              else
                ErrorString := 'Невозможно настроить сервер для подключения платформы Гедымин.';
            end
            else if E.IBErrorCode = isc_shutdown then
            begin
              if DI.IsAdminLogin then
              begin
                if BringOnline(DI.DatabaseName) then
                  ContFlag := False
                else
                  ErrorString :=
                    'База данных не была переведена в многопользовательский режим.'#13#10#13#10 +
                    'Войдите под учетной записью Administrator и переведите базу'#13#10 +
                    'данных в многопользовательский режим.';
              end else
                ErrorString :=
                  'База данных находится в однопользовательском режиме.'#13#10 +
                  'Для перевода в многопользовательский режим войдите'#13#10 +
                  'под учетной записью Administrator.';
            end else
              ErrorString := E.Message;
          end;
        end;
      until ContFlag;

      if ErrorString > '' then
      begin
        MessageBox(0,
          PChar(ErrorString),
          'Внимание',
          MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      end;

      FirstPass := False;
    until ErrorString = '';
  end;

  function CheckForModify(out NeedReadDBVersion: Boolean): Boolean;
  var
    Mdf: TgdModify;
  begin
    Result := False;
    NeedReadDBVersion := False;

    if DBVersion < cProcList[0].ModifyVersion then
    begin
      MessageBox(0,
        PChar('Структура файла базы данных устарела.'#13#10#13#10 +
        'Версия вашей БД: ' + DBVersion + #13#10#13#10 +
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
            'Необходимо обновить структуру базы данных.'#13#10#13#10 +
            'Версия вашей БД: ' + DBVersion + #13#10#13#10 +
            'Перед обновлением следует создать архивную копию!'),
            'Внимание',
          MB_OKCANCEL or MB_ICONQUESTION or MB_TASKMODAL or MB_TOPMOST) = IDOK then
        begin
          with Tgd_frmBackup.Create(nil) do
          try
            ShowModal;
          finally
            Free;
          end;

          try
            NeedReadDBVersion := True;

            Mdf := TgdModify.Create(nil);
            try
              Mdf.Database := Database;
              Mdf.IBUser := FIBName;
              Mdf.IBPassword := FIBPassword;
              Mdf.ShutdownNeeded := True;
              Mdf.OnLog := OnModifyLog;
              Mdf.Execute;
            finally
              Mdf.Free;
            end;

            // в процессе модифая мог проскочить код, который
            // открыл подключение к БД. Закрываем
            Database.Connected := False;

            MessageBox(0,
              'Процесс обновления завершен.'#13#10#13#10 +
              'Если вы используете сетевую версию программы,'#13#10 +
              'убедитесь что на всех рабочих местах установлена'#13#10 +
              'новейшая версия модуля gedemin.exe.',
              'Внимание',
              MB_OK or MB_ICONINFORMATION or MB_TASKMODAL or MB_TOPMOST);

            Result := True;
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
        end;
      end else
      begin
        MessageBox(0,
          'Структура файла базы данных устарела.'#13#10 +
          'Для ее обновления войдите под учетной записью Administrator.',
          'Внимание',
          MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL or MB_TOPMOST);
      end;
    end else
      Result := True;
  end;

var
  WithoutConnection, SingleUserMode, NeedReadDBVersion: Boolean;
begin
  Assert(gdcBaseManager <> nil);
  Assert(gd_DatabasesList <> nil);
  Assert(Database <> nil);
  Assert(atDatabase <> nil);

  if LoggedIn then
    raise EboLoginError.Create('Can not login twice!');

  Result := False;

  Database.LoginPrompt := False;
  Database.SQLDialect := 3;
  Database.Params.Clear;
  Database.Params.Add('user_name=');
  Database.Params.Add('password=');
  Database.Params.Add(Lc_ctypeValue + '=' + DefaultLc_ctype);

  if not StartUserConnect(WithoutConnection, SingleUserMode) then
    exit;

  if WithoutConnection then
  begin
    Result := True;
    exit;
  end;

  if SingleUserMode and IsIBUserAdmin then
    FShutdown := ShutdownDatabase(Database.DatabaseName);

  FLoginInProgress := True;
  try
    Database.Params.Values[UserNameValue] := FIBName;
    Database.Params.Values[PasswordValue] := FIBPassword;
    Database.Params.Values[SQLRoleNameValue] := DefaultSQLRoleName;

    if not CheckForModify(NeedReadDBVersion) then
      exit;

    {$IFNDEF DEBUG}
    if Assigned(gdSplash) then
      gdSplash.ShowSplash;
    {$ENDIF}

    Result := DoLogin(NeedReadDBVersion);
  finally
    FLoginInProgress := False;
  end;
end;

function TboLogin.LoginSilent(AnUserName, APassword: String; const ADBPath: string = ''): Boolean;
var
  Server, FileName: String;
  Port: Integer;
  DI, SelDI: Tgd_DatabaseItem;
begin
  if ADBPath > '' then
    ParseDatabaseName(ADBPath, Server, Port, FileName)
  else begin
    SelDI := gd_DatabasesList.FindSelected;
    if SelDI = nil then
      FileName := ''
    else begin
      Server := SelDI.Server;
      FileName := SelDI.FileName;
    end;
  end;

  if FileName = '' then
    Result := False
  else begin
    while gd_DatabasesList.FindByName(FileName) <> nil do
      FileName := FileName + '_';
    DI := gd_DatabasesList.Add as Tgd_DatabaseItem;
    DI.Name := FileName;
    DI.Server := Server;
    DI.FileName := FileName;
    DI.EnteredLogin := AnUserName;
    DI.EnteredPassword := APassword;
    DI.DIType := ditSilent;
    DI.Selected := True;

    FSilentLogin := True;
    Result := Login;
  end;
end;

function TboLogin.LoginSingle: Boolean;
begin
  FShutDownRequested := True;
  try
    Result := Login;
  finally
    FShutDownRequested := False;
  end;
end;

function TboLogin.Logoff: Boolean;
begin
  if not LoggedIn then
    raise EboLoginError.Create('You did not login!');

  Result := False;

  if not TestConnection then
  begin
    ConnectionLost;
    FSilentLogin := False;
  end else
  begin
    FLoggingOff := True;
    try
      DoBeforeDisconnect;

      // DoBeforeChangeCompany поставили после DoBeforeDisconnect
      // для избежания двойного сохранения CompanyStorage
      if FCompanyOpened then
        DoBeforeChangeCompany;

      if CloseConnection then
      begin
        FSilentLogin := False;
        Result := True;
      end;
    finally
      FLoggingOff := False;
    end;
  end;  
end;

function TboLogin.OpenCompany(const ShowDialogAnyway: Boolean = False;
  const CK: Integer = -1; const CN: String = ''): Boolean;
var
  ACompanyKey: Integer;
  ACompanyName: String;
  Res: OleVariant;
begin
  Assert(Assigned(gdcBaseManager));

  if (not LoggedIn) and (not FLoginInProgress) then
    raise EboLoginError.Create('You did not login!');

  Result := True;
  ACompanyKey := CK;
  ACompanyName := CN;

  if ACompanyKey > -1 then
    TgdcOurCompany.SaveOurCompany(ACompanyKey)
  else begin
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
        'SELECT companykey FROM gd_ourcompany WHERE COALESCE(disabled, 0) = 0 ',
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

    if (ACompanyKey <> -1) and ((Self.CompanyKey <> ACompanyKey) or (not FCompanyOpened)) then
    begin
      TgdcOurCompany.SaveOurCompany(ACompanyKey);
      ACompanyName := TgdcOurCompany.GetListNameByID(ACompanyKey);
    end else
      Result := False;
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
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Assert(Database <> nil);
  Assert(Database.Connected);

  with TdlgChangePass.Create(nil) do
  try
    UserName := FUserName;

    if ShowModal = mrOk then
    begin
      Tr := TIBTransaction.Create(nil);
      q := TIBSQL.Create(nil);
      try
        Tr.DefaultDatabase := Database;
        Tr.StartTransaction;

        q.Transaction := FTransaction;
        q.SQL.Text := 'UPDATE gd_user SET passw = :p, mustchange = 0 WHERE id = :id';
        q.ParamByName('id').AsInteger := UserKey;
        q.ParamByName('p').AsString := Copy(edPassword.Text, 1, max_password_length);
        q.ExecQuery;

        Tr.Commit;
        Result := True;
      finally
        q.Free;
        Tr.Free;
      end;
    end else
      Result := False;
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
    raise EboLoginError.Create('Can not change subsystem key after login!');
end;

function TboLogin.TestConnection: Boolean;
begin
  Result := (Database <> nil) and Database.TestConnected;
end;

procedure TboLogin.UpdateCompanyData;
begin
//
end;

procedure TboLogin.UpdateUserData;
var
  q: TIBSQL;
begin
  Assert(gdcBaseManager <> nil);
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text := Format('SELECT ingroup FROM gd_user WHERE id=%d', [UserKey]);
    q.ExecQuery;
    FInGroup := q.Fields[0].AsInteger;
  finally
    q.Free;
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

procedure TboLogin.ReadDBVersion;
var
  q: TIBSQL;
begin
  Assert(gdcBaseManager <> nil);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text := 'SELECT FIRST 1 * FROM fin_versioninfo ORDER BY id DESC';
    q.ExecQuery;

    FDBVersion := q.FieldByName('versionstring').AsString;
    FDBReleaseDate := q.FieldByName('releasedate').AsDateTime;
    FDBVersionID := q.FieldByName('id').AsInteger;
    FDBVersionComment := q.FieldByName('comment').AsString;
  finally
    q.Free;
  end;
end;

function TboLogin.IsSilentLogin: Boolean;
begin
  Result := FSilentLogin;
end;

function TboLogin.GetMainWindowCaption: String;
begin
  {$IFDEF NOGEDEMIN}
  Result := CompanyName + ' - ' + UserName;
  {$ELSE}
  Result := 'Гедымин - ' + CompanyName + ' - ' + UserName;
  {$ENDIF}

  {$IFDEF DEBUG}
  Result := Result + ', ' + 'DEBUG MODE';
  {$ENDIF}

  if FShutdown then
    Result := Result + ', ' + 'Однопользовательский режим';
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

function TboLogin.BringOnline(const ADBName: String = ''): Boolean;
var
  DBN, SN, DN, FSysDBAPassword, FSysDBAUserName: String;
  Port: Integer;
  CS: TIBConfigService;
begin
  Assert(Database <> nil);

  Result := False;

  if ADBName > '' then
    DBN := ADBName
  else
    DBN := Database.DatabaseName;

  ParseDatabaseName(DBN, SN, Port, DN);

  if (DN = '') or (MessageBox(0,
    PChar('База данных находится в однопользовательском режиме.'#13#10#13#10 +
    'Перевести в многопользовательский режим?'),
    'Внимание',
    MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDNO) then
  begin
    exit;
  end;

  FSysDBAPassword := SysDBAPassword;
  FSysDBAUserName := SysDBAUserName;

  CS := TIBConfigService.Create(nil);
  try
    CS.ServerName := SN;
    CS.DatabaseName := DN;
    if SN > '' then
      CS.Protocol := TCP
    else
      CS.Protocol := Local;
    CS.LoginPrompt := False;
    CS.Params.Clear;
    CS.Params.Add('user_name=' + FSysDBAUserName);
    CS.Params.Add('password=' + FSysDBAPassword);

    repeat
      try
        CS.Active := True;
        CS.BringDatabaseOnline;
        // на классике сервер сразу возвращает выполнение
        // и последующее подключение не пройдет, так как
        // база еще будет выводиться из шатдауна.
        // вроде бы, начиная с версии 2.1 эта пауза уже не
        // будет нужна
        Sleep(4000);
        while CS.IsServiceRunning do Sleep(100);
        Result := True;
        if AnsiCompareText(DBN, Database.DatabaseName) = 0 then
          FShutdown := False;
      except
        on E: EIBError do
        begin
          if E.IBErrorCode = isc_shutdown then
          begin
            MessageBox(0,
              PChar(
                'В настоящий момент времени другой пользователь'#13#10 +
                'уже подключен к базе данных в однопользовательском режиме.'#13#10#13#10 +
                'Дождитесь завершения его работы и повторите вход в систему.'),
              'Внимание!',
              MB_OK or MB_ICONHAND or MB_TASKMODAL);
            exit;
          end
          else if E.IBErrorCode = 335544835 then
          begin
            // база уже в онлайне
            Result := True;
          end else
          begin
            MessageBox(0, PChar(E.Message), 'Внимание!', MB_OK or MB_ICONHAND or MB_TASKMODAL);
            FSysDBAPassword := '';
            if not InputQuery(SN, 'Введите пароль учетной записи SYSDBA:', FSysDBAPassword) then
              exit;
          end;
        end;
      end;
    until Result;
  finally
    CS.Free;
  end;
end;

function TboLogin.Relogin: Boolean;
begin
  FReLogining := True;
  try
    Result := Logoff and DoLogin(False);
  finally
    FReLogining := False;
  end;
end;

function TboLogin.DoConnect: Boolean;
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Assert(Database <> nil);
  Assert(not Database.Connected);

  Result := False;
  repeat
    try
      Database.Connected := True;

      if Database.LoginPrompt then
      begin
        FIBName := Database.Params.Values[UserNameValue];
        FIBPassword := Database.Params.Values[PasswordValue];

        Tr := TIBTransaction.Create(nil);
        q := TIBSQL.Create(nil);
        try
          Tr.DefaultDatabase := Database;
          Tr.StartTransaction;
          q.Transaction := Tr;
          q.SQL.Text := 'UPDATE gd_user SET ibpassword=:P where ibname=:N';
          q.ParamByName('P').AsString := FIBPassword;
          q.ParamByName('N').AsString := FIBName;
          q.ExecQuery;
          Tr.Commit;
        finally
          q.Free;
          Tr.Free;
        end;
      end;

      Result := True;
    except
      on E: EIBError do
      begin
        if (E.IBErrorCode = isc_login) and IsIBUserAdmin then
        begin
          MessageBox(0,
            'На сервере базы данных был изменен пароль для учетной записи SYSDBA.',
            'Внимание',
            MB_OK or MB_TASKMODAL or MB_ICONQUESTION);
          Database.LoginPrompt := True;
        end
        else if not TgdcUser.CheckIBUser(FIBName, FIBPassword) then
        begin
          MessageBox(0,
            'Отсутствует учетная запись пользователя на сервере базы данных.'#13#10 +
            'Вероятно, файл базы данных был перенесен на другой сервер или сервер '#13#10 +
            'Firebird был переустановлен.'#13#10 +
            ''#13#10 +
            'Зайдите в систему под учетной записью Administrator и в разделе'#13#10 +
            'Исследователь\Сервис\Администратор\Пользователи выполните команду'#13#10 +
            'Пересоздать учетные записи.',
            'Внимание',
            MB_OK or MB_ICONHAND or MB_TASKMODAL);
          break;
        end else
          raise;
      end;
    end;
  until Database.Connected;
end;

function TboLogin.DoLogin(NeedReadDBVersion: Boolean): Boolean;
begin
  if Assigned(gdSplash) then
    gdSplash.ShowText(sDBConnect);

  Result := False;

  if DoConnect then
  try
    if (not FChangePass) or RunChangePassDialog then
    begin
      if NeedReadDBVersion then
        ReadDBVersion;

      DoAfterSuccessfullConnection;

      Result := (not FAutoOpenCompany) or EnterCompany or OpenCompany;
    end;

    if not Result then
      Database.Connected := False;
  except
    Database.Connected := False;
    if Assigned(gdSplash) then
      gdSplash.FreeSplash;
    raise;
  end;
end;

function TboLogin.GetReLogining: Boolean;
begin
  Result := FRelogining;
end;

end.



