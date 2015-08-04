
{++

  Copyright (c) 2000-2015 by Golden Software of Belarus

  Module

    gd_directories_const.pas

  Abstract

    Names of default directories and system registry entries
    for Gedemin project.

  Author

    Andrei Kireev (06-Jul-00)

  Contact address

    http://www.gsbelarus.com

  Revisions history

    1.00    08-Jul-00    andreik    Initial version.

--}

unit gd_directories_const;

interface

uses
  Windows, Registry, inst_const;

const
  SysDBAUserName                  = 'SYSDBA';
  SysDBAPassword                  = 'masterkey';
  UserNameValue                   = 'USER_NAME';
  PasswordValue                   = 'PASSWORD';
  ShutDownValue                   = 'SHUTDOWN';
  SQLRoleNameValue                = 'sql_role_name';
  DefaultSQLRoleName              = 'ADMINISTRATOR';
  Lc_ctypeValue                   = 'Lc_ctype';
  DefaultLc_ctype                 = 'win1251';

  // імя файла базы дадзеных
  DatabaseFileName                = 'GDBASE.FDB';
  // Mutex
  GedeminMutexName                = 'Gedemin_Application_Mutex';
  GedeminSetupMutexName           = 'Gedemin_Application_Mutex_Setup';
  // канстанты патрэбныя для апгрэйда
  DBUpgradeVersionFileName        = 'gdbase.ver';
  DBUpgradeExcludeTablesFileName  = 'excltbl.txt';
  DBUpgradeMergeTablesFileName    = 'mergtbl.txt';

  // імя архіўнага файла, трэба выкарыстоўваць разам з
  // функцыяй FormatDateTime
  ArchiveFileName                 = 'GDBASE_%s.BK';
  // маска для функцыі FormatDateTime
  ArchiveFileDateTimeMask         = 'DDMMYY_HHNN';

  // ўсе настройкі на сэрвере захоўваюцца ў рэестры
  // па гэтым ключы, альбо ягоных падключах
  ServerRootRegistryKey           = HKEY_LOCAL_MACHINE;
  ServerRootRegistrySubKey        = cServerRegPath + '\';

  // шлях да файла базы дадзеных
  DatabaseDirectoryValue          = 'DatabaseDirectory';
  DefaultDatabaseDirectory        = 'c:\Program files\Golden Software\Gedemin\Database\';

  // шлях, дзе захоўваюцца архівы базы дадзеных
  ArchiveDirectoryValue           = 'ArchiveDirectory';
  DefaultArchiveDirectory         = 'c:\Program files\Golden Software\Gedemin\Archive\';

  // ўсе настройкі на кліенце захоўваюцца ў
  // рэестры па гэтым ключы, альбо ягоных падключах
  ClientRootRegistryKey           = HKEY_LOCAL_MACHINE;
  ClientRootRegistrySubKey        = cClientRegPath + '\';
  ClientAccessRegistrySubKey      = ClientRootRegistrySubKey + 'Access';

  // Help dir value in registry
  HelpDirValueName                = 'HelpDir';

  // шлях да сэрвера і файла базы дадзеных на ім
  ServerNameValue                 = 'SERVERNAME';

  // Interbase user prefix
  UserNamePrefix                  = 'USER_';
  UserPassPrefix                  = 'pass_';

  // папка для ўсіх праграмаў і файлаў праекта Гедемін
  RootDirectoryValue              = 'RootDirectory';
  DefaultRootDirectory            = 'c:\Program files\Golden Software\Gedemin\';

  // папка для службовых праграмаў праекта Гедемін
  ToolsDirectoryValue             = 'ToolsDirectory';
  DefaultToolsDirectory           = 'c:\Program files\Golden Software\Gedemin\Tools\';

  // Папка для хранения параметров подключения сервера отчетов к базе
  cReportServerKey                = 'ReportServer\';
  cReportServerUser               = 'ServerUser';
  cReportServerPass               = 'ServerPass';
  cReportServerPath               = 'ServerPath';
  cReportServerDepend             = 'Depend';

  // upgrade program
  DBUpgradeRegistrySubKey         = 'DBUpgrade\';
  DBUpgradeBackupFileNameValue    = 'BackupFileName';
  DBUpgradeTargetDatabaseNameValue= 'TargetDatabaseNameValue';
  DBUpgradeServerName             = 'ServerName';

  //
  ScriptRegistrySubKey            = 'Script\';
  ScriptTimeOutValue              = 'TimeOut';
  DefaultScriptTimeOut            = 60000;

  ADMIN_KEY                       = 150001;

  //Ключ реестра по которому прописываются программы которые надо
  //запустить один раз после перезагрузки
  RUN_ONCE_KEY = '\' + cRunOnceRegPath;

  //Количество дополнительного места на диске необходимое для запуска Upgrade
  //Основное место необходимое для upgrade вычисляется из размера базы для
  // апгрейда * 4
  UPGRADE_SIZE                    = 1;

  //Колличество места на диске в MB необходимый для начала установки
  //базы данных
  SETUP_DATABASE_SIZE             = 50;

  //
  MSG_INBOX_KEY                   = 450010;
  MSG_OUTBOX_KEY                  = 450020;
  MSG_SENTBOX_KEY                 = 450025;
  MSG_DRAFTBOX_KEY                = 450030;
  MSG_TRASHBOX_KEY                = 450040;

  //
  FLT_FG_10LAST                   = 850001;
  FLT_FG_ALL                      = 850005;
  FLT_FG_FINANCE                  = 850010;
  FLT_FG_DATETIME                 = 850015;
  FLT_FG_MATH                     = 850020;
  FLT_FG_TEXT                     = 850025;

  // мы захоўваем настройкі карыстальніка ў сховішчы карыстальніка
  // ніжэй прыведзены канстанты для парамэтраў настройкі
  st_OptionsPath                  = 'Options';

  // запрашивать сохранение перед выходом из диалога
  // по Отмене. Булевское значение.
  st_AskDialogCancel              = 'AskDialogCancel';

  // дэсктоп
  st_dt_DesktopOptionsPath        = st_OptionsPath + '\Desktop';
  st_dt_LoadDesktopOnStartup      = 'LoadDesktopOnStartup';
  st_dt_LoadOnStartup             = 'LoadOnStartup';

  // live updates
  st_lu_OptionsPath               = st_OptionsPath + '\LiveUpdates';
  st_lu_Enabled                   = 'Enabled';
  st_lu_Server                    = 'Server';
  st_lu_Version                   = 'Version';

  // options for messaging subsystem
  st_ms_OptionsPath               = st_OptionsPath + '\Messaging';
  st_ms_CompanyKey                = 'CompanyKey';

  // DFM store path for designing system
  st_ds_DFMPath                   = '\DFM';
  // Store path for new user created form
  st_ds_NewFormPath               = '\NewForm';

  // Internal Form type - Byte
  st_ds_InternalType              = 'InternalType';
  //1 Simply form
  //2 GDC form
  st_ds_SimplyForm                = 1;
  st_ds_GDCForm                   = 2;

  // Class name wrom form inherited - String
  st_ds_FormClass                 = 'Class';
  // GDS object for form - String
  st_ds_FormGDCObjectClass        = 'GDCClass';
  // Subtype of GDC object of form - String
  st_ds_FormGDCSubtype            = 'GDCSubType';
  // Parameter for store dfm resource
  st_ds_UserFormDFM               = 'dfm';
  // undefined gdc subtype name for undefined subtypes
  SubtypeDefaultName              = 'default';

  // maximal user name and password lengths
  max_username_length             = 20;
  max_password_length             = 20; // увы, но такой параметр в сторед процедуре

  //Идентификатор эталонной БД (используется при сохранении руида для стандартных записей)
  cstEtalonDBID                   = 17;
  //Стартовое значение идентификатора для пользовательских записей
  cstUserIDStart                  = 147000000;
  //Идентификатор Администратора из таблицы gd_people
  cstAdminKey                     = 650002;

  //Константы типов налогов
  cst_txMonthID                   = 350001;
  cst_txQuarterID                 = 350002;
  cst_txArbitraryID               = 350003;

  //Глобальное хранилище
  st_root_Global                  = 'GLOBAL';
  //Пользовательское хранилище
  st_root_User                    = 'USER';
  //Хранилище компании
  st_root_Company                 = 'COMPANY';

  // по этим гуидам мы ищем библиотеки в реестре
  MIDAS_TYPELIB_GUID              = '{83F57D68-CA9A-11D2-9088-00C04FA35CFA}';
  MIDAS_GUID1                     = '{9E8D2FA1-591C-11D0-BF52-0020AF32BD64}';
  MIDAS_GUID2                     = '{9E8D2FA1-591C-11D0-BF52-0020AF32BD64}';
  MIDAS_GUID3                     = '{9E8D2FA1-591C-11D0-BF52-0020AF32BD64}';
  MIDAS_GUID4                     = '{9E8D2FA1-591C-11D0-BF52-0020AF32BD64}';
  GSDBQUERY_GUID                  = '{7C916B87-94DF-4712-A5AC-10C971C7E160}';

  //
  ProgID_MSXML_DOMDocument        = 'MSXML2.DOMDocument.6.0';
  ProgID_MSXML_XMLSchemaCache     = 'MSXML2.XMLSchemaCache.6.0';

  //
  Gedemin_NameServerURL           = 'http://gsbelarus.com/gs/gedemin/gdwebserver';

  //
  Gedemin_Updater                 = 'gedemin_upd.exe';
  Gedemin_Updater_Ini             = 'gedemin_upd.ini';

  //
  DEFAULT_WEB_SERVER_PORT            = 80;
  STORAGE_WEB_SERVER_PORT_VALUE_NAME = 'WebServerPort';

  //
  WIN1251_CODEPAGE                = 1251;

  SM_REMOTESESSION                = $1000;

  cstMetaDataNameLength           = 31;

function IsGedeminSystemID(const AnID: Integer): Boolean;
function IsGedeminNonSystemID(const AnID: Integer): Boolean;

implementation

function IsGedeminSystemID(const AnID: Integer): Boolean;
begin
  Result := AnID < cstUserIDStart;
end;

function IsGedeminNonSystemID(const AnID: Integer): Boolean;
begin
  Result := AnID >= cstUserIDStart;
end;

end.
