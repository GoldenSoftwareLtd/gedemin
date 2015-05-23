
{++

  Copyright (c) 1998-2014 by Golden Software of Belarus

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
    1.05    12.04.01    andreik    boJournal died.

--}

unit gd_security;

interface

uses
  Windows,            Messages,           SysUtils,           Classes,
  Graphics,           Controls,           Forms,              Dialogs,
  ComCtrls,           DB,                 IBDatabase;

// бітавыя маскі для зарэзерваваных групаў карыстальнікаў
const
  GD_UG_ADMINISTRATORS        = 1;
  GD_UG_POWERUSERS            = 2;
  GD_UG_USERS                 = 4;
  GD_UG_ARCHIVEOPERATORS      = 8;
  GD_UG_PRINTOPERATORS        = 16;
  GD_UG_GUESTS                = 32;

//
const
  GD_POL_EDIT_FILTERS_MASK    = GD_UG_ADMINISTRATORS
                                or GD_UG_POWERUSERS;
  GD_POL_EDIT_FILTERS_ID      = 'EditFilters';
  GD_POL_EDIT_FILTERS_CAPTION = 'Правом изменять фильтры обладают';                                  

  GD_POL_APPL_FILTERS_MASK    = GD_UG_ADMINISTRATORS
                                or GD_UG_POWERUSERS
                                or GD_UG_USERS;
  GD_POL_APPL_FILTERS_ID      = 'ApplyFilters';
  GD_POL_APPL_FILTERS_CAPTION = 'Правом применять фильтры обладают';

  GD_POL_EDIT_UI_MASK         = GD_UG_ADMINISTRATORS
                                or GD_UG_POWERUSERS
                                or GD_UG_USERS;
  GD_POL_EDIT_UI_ID           = 'EditUI';
  GD_POL_EDIT_UI_CAPTION      = 'Правом изменять визуальные настройки обладают';

  GD_POL_CHANGE_WO_MASK       = GD_UG_ADMINISTRATORS
                                or GD_UG_POWERUSERS
                                or GD_UG_USERS;
  GD_POL_CHANGE_WO_ID         = 'ChangeWO';
  GD_POL_CHANGE_WO_CAPTION    = 'Правом изменять рабочую организацию обладают';

  GD_POL_PRINT_MASK           = GD_UG_ADMINISTRATORS
                                or GD_UG_POWERUSERS
                                or GD_UG_USERS
                                or GD_UG_PRINTOPERATORS;
  GD_POL_PRINT_ID             = 'Print';
  GD_POL_PRINT_CAPTION        = 'Правом печатать документы обладают';

  GD_POL_RUN_MACRO_MASK       = GD_UG_ADMINISTRATORS
                                or GD_UG_POWERUSERS
                                or GD_UG_USERS;
  GD_POL_RUN_MACRO_ID         = 'RunMacro';
  GD_POL_RUN_MACRO_CAPTION    = 'Правом выполнять макросы обладают';

  GD_POL_REDUCT_MASK          = GD_UG_ADMINISTRATORS
                                or GD_UG_POWERUSERS;
  GD_POL_REDUCT_ID            = 'Reduct';
  GD_POL_REDUCT_CAPTION       = 'Правом объединять записи обладают';

  GD_POL_REPORT_MASK          = GD_UG_ADMINISTRATORS
                                or GD_UG_POWERUSERS
                                or GD_UG_USERS
                                or GD_UG_PRINTOPERATORS;
  GD_POL_REPORT_ID            = 'Report';
  GD_POL_REPORT_CAPTION       = 'Правом просматривать отчеты обладают';

  GD_POL_DESK_MASK            = GD_UG_ADMINISTRATORS
                                or GD_UG_POWERUSERS
                                or GD_UG_USERS;
  GD_POL_DESK_ID              = 'Desk';
  GD_POL_DESK_CAPTION         = 'Правом изменять рабочий стол обладают';

  GD_POL_CASC_MASK            = GD_UG_ADMINISTRATORS
                                or GD_UG_POWERUSERS;
  GD_POL_CASC_ID              = 'Casc';
  GD_POL_CASC_CAPTION         = 'Правом разрешать конфликты ссылок обладают';

  GD_POL_EQ_MASK            = GD_UG_ADMINISTRATORS
                                or GD_UG_POWERUSERS
                                or GD_UG_USERS;
  GD_POL_EQ_ID              = 'EQ';
  GD_POL_EQ_CAPTION         = 'Правом работать с эквивалентом обладают';

// коды вяртання працэдуры GD_P_SEC_LOGINUSER
const
  GD_LGN_UNKNOWN_SUBSYSTEM    = -1001;
  GD_LGN_SUBSYSTEM_DISABLED   = -1002;
  GD_LGN_UNKNOWN_USER         = -1003;
  GD_LGN_INVALID_PASSWORD     = -1004;
  GD_LGN_USER_DISABLED        = -1005;
  GD_LGN_WORK_TIME_VIOLATION  = -1006;
  GD_LGN_USER_ACCESS_DENIED   = -1007;
  GD_LGN_GROUP_DISABLED       = -1008;
  GD_LGN_OK                   = 1;
  GD_LGN_OK_CHANGE_PASSWORD   = 2;

const
  GD_RTH_ACCESSIBLE           = 1;
  GD_RTH_NOT_ACCESSIBLE       = 0;
  GD_RTH_UNKNOWN              = -1;

const
  SearchMarker = '/*<UserGroups>*/';

type
  TAuditLevel = (alNoAudit, alLow, alMedium, alHigh);

type
  ICompanyChangeNotify = interface
  ['{36F2CBCB-8433-4B0E-83E2-ADD96CE2C60E}']
    procedure DoBeforeChangeCompany;
    procedure DoAfterChangeCompany;
  end;

  IConnectChangeNotify = interface
  ['{BFAA621B-54CA-4C63-A108-F5AA4E7AC581}']
    procedure DoAfterSuccessfullConnection;
    procedure DoBeforeDisconnect;
    procedure DoAfterConnectionLost;
  end;

  IboLogin = interface
  ['{A00D11CF-9BD9-4D27-80B7-3451B1AC3A27}']
    function GetDatabase: TIBDatabase;
    function GetLoginParam(ParamName: String): String;

    function GetAuditCache: Integer;
    function GetAuditLevel: TAuditLevel;
    function GetAuditMaxDays: Integer;
    function GetAllowUserAudit: Boolean;

    function GetCompanyKey: Integer;
    function GetCompanyName: String;
    function GetCompanyPhone: String;
    function GetCompanyEmail: String;
    function GetIsHolding: Boolean;
    function GetHoldingList: String;
    function GetHoldingKey: Integer;

    function GetContactKey: Integer;
    function GetContactName: String;

    function GetDBReleaseDate: TDateTime;
    function GetDBVersion: String;
    function GetDBVersionComment: String;
    function GetDBVersionID: Integer;

    function GetGroupName: String;
    function GetIngroup: Integer;
    procedure SetIngroup(const Value: Integer);

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
    function GetIBRole: String;
    function GetDatabaseName: String;
    function GetIsUserAdmin: Boolean;
    function GetShutDown: Boolean;
    function GetShutDownRequested: Boolean;
    function GetReLogining: Boolean;
    function GetIsIBUserAdmin: Boolean;
    function GetServerName: String;
    function GetDBID: Integer;
    function GetActiveAccount: Integer;

    procedure SetSubSystemKey(const Value: Integer);

    function LoginSingle: Boolean;
    function BringOnLine(const ADBName: String = ''): Boolean;
    procedure ConnectionLost;
    procedure ConnectionLostMessage;

    function Login: Boolean;
    function LoginSilent(AnUserName: String; APassword: String; const ADBPath: string = ''): Boolean;
    function Logoff: Boolean;
    function Relogin: Boolean;
    function GetLoggingOff: Boolean;
    function IsSilentLogin: Boolean;

    procedure CloneDatabase(ADatabase: TIBDatabase);

    function OpenCompany(const ShowDialogAnyway: Boolean = False;
      const CK: Integer = -1; const CN: String = ''): Boolean;
    procedure UpdateCompanyData;
    procedure UpdateUserData;

    procedure AddConnectNotify(Notify: IConnectChangeNotify);
    procedure RemoveConnectNotify(Notify: IConnectChangeNotify);

    procedure AddCompanyNotify(Notify: ICompanyChangeNotify);
    procedure RemoveCompanyNotify(Notify: ICompanyChangeNotify);

    //
    procedure ClearHoldingListCache;
    procedure ChangeUser(const AUserKey: Integer;
      const ACheckMultipleConnections: Boolean = False);

    //
    procedure AddEvent(const AData: String;
      const ASource: String = '';
      const AnObjectID: Integer = -1;
      const ATransaction: TObject = nil);

    function GetMainWindowCaption: String;
    function GetIsEmbeddedServer: Boolean;

    property LoginParam[ParamName: String]: String read GetLoginParam;
    property ComputerName: String read GetComputerName;
    property IBRole: String read GetIBRole;

    property CompanyOpened: Boolean read GetCompanyOpened;
    property LoggedIn: Boolean read GetLoggedIn;
    property ShutDown: Boolean read GetShutDown;
    property ShutDownRequested: Boolean read GetShutDownRequested;
    property ReLogining: Boolean read GetReLogining;

    // Имя и пароль IB
    property IBName: String read GetIBName;
    property IBPassword: String read GetIBPassw;

    //  Свойства сессии
    property SessionDuration: TDateTime read GetSessionDuration;
    property StartTime: TDateTime read GetStartTime;
    property SessionKey: Integer read GetSessionKey;

    // Права пользователя
    property Ingroup: Integer read GetIngroup write SetIngroup;
    property GroupName: String read GetGroupName;
    property IsUserAdmin: Boolean read GetIsUserAdmin;
    property IsIBUserAdmin: Boolean read GetIsIBUserAdmin;

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
    property AllowUserAudit: Boolean read GetAllowUserAudit; // разрешена ли регистрации действий данного пользователя

    // Пользователь
    property UserKey: Integer read GetUserKey;
    property UserName: String read GetUserName;
    property ContactKey: Integer read GetContactKey;
    property ContactName: String read GetContactName;

    // Компания
    property CompanyKey: Integer read GetCompanyKey;
    property CompanyName: String read GetCompanyName;
    property CompanyPhone: String read GetCompanyPhone;
    property CompanyEmail: String read GetCompanyEmail;
    property IsHolding: Boolean read GetIsHolding;     // является ли данная компания холдингом
    property HoldingList: String read GetHoldingList;  // если является, то список ключей компаний входящих в этот холдинг
    property HoldingKey: Integer read GetHoldingKey;   // если, компания входит в некоторый холдинг, то эт его ключ
                                                       // если нет, то -1
                                                       // если сама является холдингом, то HoldingKey = CompanyKey
                                                       // если компания входит в несколько холдингов, то
                                                       // свойство содержит ключ первого из них (по порядку
                                                       // в базе данных)
    //Возвкащает ID асктивного плана счетов
    property ActiveAccount: Integer read GetActiveAccount;
    //
    property DBID: Integer read GetDBID;

    // База данных
    property Database: TIBDatabase read GetDatabase;
    property ServerName: String read GetServerName;

    property LoggingOff: Boolean read GetLoggingOff;

    property MainWindowCaption: String read GetMainWindowCaption;
    property IsEmbeddedServer: Boolean read GetIsEmbeddedServer;
  end;


function FindDigit(const Symbol: Char): Boolean;
function ExtractTableName(KeyWord: String; S: TStrings): String;

function DecryptPassword(const APassword: String): String;

//
// Для ІБ патрэбна, каб усе кампутары падключаліся выкарыстоўваючы
// адзіны шлях да сэрвера і файла базы дадзеных.
//
// Дадзеная функцыя прыабразуе імёны кшталту:
//    \\servername\fullpathtodatabasefile         (NetBEUI)
// да выгляду:
//    servername:fullpathtodatabasefile           (TCP/IP)
//
function AdjustServerName(const AServerName: String): String;

// Функция формирует условие выбора текущей компании с учетом холдинга
// CompKeyFieldName - имя поля (с алиасом) в запросе
function GetCompCondition(const CompKeyFieldName: String): String;

// Глобальная переменная общего текущего пользователя всей системы
// ВНИМАНИЕ! Должен быть только один такой компонент
var
  IBLogin: IboLogin;

implementation

uses
  Registry;

// функцыі для шыфроўкі/дэшыфроўкі пароля

function GetCompCondition(const CompKeyFieldName: String): String;
begin
  if IBLogin <> nil then
    Result := ' ' + CompKeyFieldName + ' IN (' + IBLogin.HoldingList + ') '
  else
    Result := '';
end;

function DecryptPassword(const APassword: String): String;
begin
  Assert(Length(APassword) >= 8);
  Result := APassword;
end;

function AdjustServerName(const AServerName: String): String;
begin
  Result := AServerName;
  if Copy(Result, 1, 2) = '\\' then
  begin
    Delete(Result, 1, 2);
    Insert(':', Result, Pos('\', Result) + 1);
    Delete(Result, Pos('\', Result), 1);
  end;
end;

function FindDigit(const Symbol: Char): Boolean;
const
  Digits = [' ', '+', '-', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
begin
  Result := Symbol in Digits;
end;

function ExtractTableName(KeyWord: String; S: TStrings): String;
var
  I: Integer;
  Flag: Boolean;

  function FindEnd(Symbol: Char): Boolean;
  const
    Str = [' ', ',', '/', '(', #10, #13];//' (,/'#10#13; // Символы которыми может заканчиваться имя таблицы
  begin
    Result := Symbol in Str;
  end;

  function FindLimit(Symbol: Char): Boolean;
  const
    Str = [' ', #10, #13];//' '#10#13; // Символы которые могут предшествовать INTO
  begin
    Result := Symbol in Str;
  end;
begin
  Result := '';
  Flag := False;
  // Проверка наличия в запросе INTO
  I := 1;
  while not Flag and (I <> 0) do
  begin
    I := Pos(AnsiUpperCase(KeyWord), AnsiUpperCase(S.Text));
    Flag := FindLimit(S.Text[I - 1]) and FindLimit(S.Text[I + 4]);
  end;
  if I = 0 then
    exit;
  // Доходим до первого значащего символа
  I := I + 4;
  while (Length(S.Text) >= I) and (S.Text[I] = ' ') do
    Inc(I);
  if Length(S.Text) < I then
    exit;
  // Вытаскиваем имя таблицы
  while not FindEnd(S.Text[I]) do
  begin
    Result := Result + S.Text[I];
    Inc(I);
  end;
end;

initialization
  IBLogin := nil;

finalization
  IBLogin := nil;
end.

