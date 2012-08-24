{++

  Copyright (c) 2002-2003 by Golden Software of Belarus

  Module

    gsGedeminInstall.pas
                                                   
  Abstract
           
    Инсталляция для Гедымина.
 
  Author

    Andrey Shadevsky
                      
  Revisions history

    1.00    21.11.02    JKL        Initial version.
    1.01    08.01.03    JKL        Beta version.
    1.02    20.02.03    JKL        Some bugs was fixed. (CheckIBClientVersion Path, ...)
    1.03    02.04.03    JKL        Finall version.
    1.1     dd.09.03    Yuri       Удалил сервер отчетов,
    1.2     27.10.03    Yuri       Подправил проверку версий
    1.3     03.11.03    Yuri       Подправил обработку путей (backslash, shortpath, etc.)
    1.4     04.12.03    Yuri       Установка Yaffil'а без удаления др. IB-серверов
    1.5     30.12.03    Yuri       Исправления в процедуре ChangePassword                 

    
--}

unit gsGedeminInstall;

interface

uses
  Classes, Windows, JclSysInfo, inst_InstallList, IBServices;
{ DONE -oJKL :
-1. Копирование БД
-2. Модифай/Апгрейд
-3. Uninstall
-4. Проверка должна осуществляться следующим образом. Если Interbase Установлен ниже 6.0,
   то предлагать переустановить в противном случае генерить Exception
   Если нет то предлогать заменить сервер. CheckIBServer
-5. DeleteService
-6. INI file for InstallType
-7. Проверка версии клиента
}

type
  TArchiveType = (artFile, artZip, artRes);
  {Тип хранения данных artFile - файлы (для тестирования), artZip - ZIP архив,
   artRes - Res файл}

type
  TIBVersion = (ibsAbsent, ibsRight, ibsWrong, ibsExact);

  TInstFileVersion = record
    dwFileVersionMS, dwFileVersionLS: DWORD;
  end;

  TIBCloneType = (ctUnknown, ctInterbase, ctFirebird, ctYaffil);

  TIBServerClone = record
    FileCompany: TIBCloneType;
    FileVersion: String;
    FileDate: Integer;
  end;
                      
  TWinVersionType = (wvtAny, wvtWin9x, wvtWinNT);          
  TWinLanguageType = (wltAny, wltRUS, wltENG);

type
  TInstallFile = record
    FileName: String;                            // Имя файла
    FileTargetPath: String;                      // Путь файла для копирования
                                                 // Точное соответствие, Регистрировать, Shared, EXE-архив
    IsRewrite, IsRegistered, IsShared, isSelfExtract: Boolean;
    WinVersionType: TWinVersionType;             // тип ОС
    WinLanguageType: TWinLanguageType;           // тип языка ОС
    MinVersion: TInstFileVersion;                // Мин. версия файла которая подходит, IsRewrite игнорируется
    IsSearchDouble: Boolean;                     // Поиск файлов с таким именем на компьютере
    LinkName: String;                            // Наименование линка для exe
    IsMakeDesktopIcon: Boolean;                  // создавать ли ярлык на раб. столе
  end;    

  TInstallType = (itLocal, itMulti);
  // Основные типы инсталляции
  TInstallModule = (imServer, imServerDll, imClient, imGedemin, {imReport, }imDatabase);
  TInstallModules = set of TInstallModule;

  TQueryInstallType = procedure(Sender: TObject; AnInstallType: TInstallType) of object;
  TQueryInstallModules = procedure(Sender: TObject; AnInstallModules: TInstallModules) of object;
  TInstallLog = procedure(const AnMessage: String) of object;
  TInstallFinish = procedure(AnSuccess: Boolean; AnErrorMessage: String) of object;
  TStringArray = array[0..$8F] of String;
  PStringArray = ^TStringArray;
  TGetStarted = function(const AnUninstall: Boolean = False): Boolean of object;
  PGetStarted = ^TGetStarted;

type
  TGedeminInstall = class(TComponent)
  private
    FWindowsVersion: TWindowsVersion;            // Версия windows
    FWinRussian: Boolean;                        // Русская ли винда
    FRestartRequired: Boolean;                  // Флаг необходимости перезагрузки
    FIBFirstInstall: Boolean;                   // Флаг первой инсталляции IB

    FIBUser, FIBPassword: String;

    FArchiveType: TArchiveType;                 // Тип архива хранящий данные
    FTargetProgramPath: String;                 // Путь инсталяции программы
    FTargetInterbasePath: String;               // Путь инсталяции IB файлов
    FDatabasePath: String;                      // Путь к базе данных
    FBackupPath: String;                        // Путь к bk
    FServerExePath: String;                     // Путь к Interbase серверу
    FGuardExePath: String;                      // Путь к Interbase Guardian
    FTempFileName: String;

    FInstallType: TInstallType;                 // Тип установки
    FInstallModules: TInstallModules;           // Устанавливаемые модули
    FYetInstalledModules: TInstallModules;      // Уже проинсталлированные модули
    FInitialInstallModules: TInstallModules;    // Устанавливаемые модули на момент запуска инсталляции (из FInstallModules модули вычитаются)

    // События
    FQueryInstallType: TQueryInstallType;       // Событие для запроса типа инсталяции
    FQueryInstallModules: TQueryInstallModules; // Событие для запроса модулей
    FInstallLog: TInstallLog;                   // Лог событие
    FInstallFinish: TInstallFinish;             // Завершение процесса

    FUnInstallList: TInstallList;               // Список проведденных операций
    FOldUnInstallList: TInstallList;            // Список старых
                       
//    FDelayedFilesList: TStringList;             // список файлов, оставленных для удаления после перезагрузки

    FPasswordQuered: Boolean;                   // Флаг необходимости считывания пароля БД
    FNewPasswordQuered: Boolean;                // Флаг запроса у юзера нового пароля для SYSDBA   
    {$IFDEF DEBUG}
    FLogList: TStrings;
    {$ENDIF}
    FExistsServerType: TIBServerClone;          // Тип уже установленного сервера
    FInstallServerType: TIBServerClone;         // Тип сервера в инсталляции
    FExistsClientType: TIBServerClone;          // Тип уже установленного клиента
    FInstallClientType: TIBServerClone;         // Тип клиента в инсталляции
 
    FInstallRootDir: String;
    FLocalErrorCode: Cardinal;
    FNeedSelfExtractInfo: Boolean;
    FBreakProcess: Boolean; 

    procedure SetTargetInterbasePath(const Value: String);
    function ExtractIBPathFromFileName(const Value: String): String;
    procedure SetTargetProgramPath(const Value: String);
    function GetCorrectPath(const aPath: String): String;
    function GetSourceMainPath: String;
    function GetLogFileName: String;
    procedure CheckServerName2;
//    procedure RemoveDelayed(AnPathList: TStrings);
  public
    function CheckTCPIP: Boolean;
    function CheckIBClientVersion(var AnVersion: String;
      var AnCanClientUpdate: Boolean): TIBVersion;
    // Проверка версии Interbase server
    function CheckIBServerVersion(var AnVersion: String;
      var AnCanServerUpdate: Boolean): TIBVersion;
    // Поиск файла AnFileName в системных директориях. Возвращает список AnPathList
    procedure FindFile(AnFileName: String; AnPathList: TStrings; AnClearList: Boolean = True);
    procedure FindGedemin(AnPathList: TStrings);
    // Копирование файла AnFileSource -> AnFileTarget
    // AnFileSource, AnFileTarget - полный путь
    procedure ReplaceFile(AnFileSource, AnFileTarget: String);
    // Переименование файла
    procedure RenameInstFile(AnFileSource, AnFileTarget: String);
    // Копирование файла с потока AnStreamSource -> AnFileTarget
    // AnFileTarget - полный путь
    procedure ReplaceFileFromStream(AnStreamSource: TStream; AnFileTarget: String);
    // Процедура копирует файл инсталяции из раздела по указанному пути
    // AnFileSource - Раздел + Имя_файла (IBFiles/gds32.dll)
    // AnFileTarget - пролный_путь_куда_копировать (C:\WinNT\System32\gds32.dll)
    procedure CopySourceFile(AnFileSource, AnFileTarget: String);
    // Создаем директорию для копирования
    procedure CreateDirectory(AnPath: String);
    // Проверяем дату файлов. AnFileSource - имя раздела, AnFileTarget - имя файла, AnExactly - точное совпадение
    function CheckFileVersion(AnFileSource: TInstallFile; AnFileTarget: String): Boolean;
    // Проверяем дату саморасп. архивов.
//    function CheckSelfExtractVersion(aSelfExtractName: String): Boolean;
    // Зашариваем файл в реестре                     
    procedure SharedFile(AnFilePath: String; AnIsFileExists: Boolean);
    // Расшариваем файл в реестре. AnDeleteFile - надо ли удалять файл если он не используется
    procedure UnSharedFile(AnFilePath: String; AnRegisterFile: Boolean; AnDeleteFile: Boolean = True);
    // Удаляет файл
    procedure DeleteTargetFile(AnFileTarget: String);
    // Генерим log событие
    procedure DoLog(AnMessage: String);
    // Инициируем событие окончания инсталляции
    procedure DoFinish(AnSuccess: Boolean; AnErrorMessage: String = '');
    // Проверка количества найденых файлов
    function CheckPathList(AnPathList: TStrings; const AnSourceFile: String;
      var AnTargetPath: String): Boolean;
    // Регистрирует файл в реестре
    procedure RegisterFile(AnFilePath: String);
    // Удаляем регистрацию
    procedure UnRegisterFile(AnFilePath: String);
    // Заменяет условные символы в пути на истинный путь
    function ParseTargetPath(AnPath: String): String;
    // Возвращает полный путь для копирования файла
    function GetTargetFileName(AnInstallFile: TInstallFile): String;
    // Инсталляция одного файла со всеми проверками
    function InstallFile(AnInstallFile: TInstallFile; AnSharedNeeded: Boolean;
      const AnModulePrefix: Char; const AnOnlyShared: Boolean = False): String;
    // Установка самораспаковывающейся программы   
    function InstallSelfExtract(AnInstallFile: TInstallFile): String;
    // Вывод вспомогательной информации об установке саморасп. архивов   
    function ShowSelfExtractInfo(const aProgramName: String): Integer;  
    // Создание shortcut
    procedure CreateFileLink(const AnTargetPath, AnFileName, AnLinkName: String; const IsDesktopIcon: Boolean = False);
    // Деинсталляция одного файла
    procedure UninstallFile(AnFileName: String; AnIsShared, AnIsRegister: Boolean); overload;
    procedure UninstallFile(AnInstallFile: TInstallFile); overload;
    // Проверка прав пользователя
    function CheckUserRight: Boolean;
    // Запрос типа инсталляции
    function DoQueryInstallType: TInstallType;
    // Запрос инсталируемых модулей
    function DoQueryInstallModules: TInstallModules;
    // Подготовка к инсталляции IB сервера. Остановка загруженых и т.д.
    procedure PrepareInstallIBServer(const AnUninstall: Boolean = False);
    // Подготовка к инсталяции БД. Запуск IB сервера и т.д.
    procedure PrepareInstallDatabase;
    // Непосредственно инсталляция в зависимости от типа установки
    procedure InstallBody;
    // Проверяет запущен ли IB сервер
    function IbServerStarted(const AnUninstall: Boolean = False): Boolean;

{    // Проверяет запущен ли сервер отчетов
    function ReportServerStarted(const AnUninstall: Boolean = False): Boolean; sty}

    // Останов сервиса сервера
    procedure StopServiceServer(const AnServiceNames: PStringArray; const AnCount: Integer);
    // Останов приложения сервера
    procedure StopAppServer(const AnServerHandle: HWND;
      const AnAppNames: PStringArray; const AnCount: Integer);
    // Запускает сервис сервера
    procedure StartServiceServer(const AnServiceName, AnDisplayName,
      AnServiceFile: String; const AnStartType: Cardinal;
      const AnSetFailureActions: Boolean; const AnDependencies: PChar = nil);
    // Запускает сервер как приложение
    procedure StartAppServer(AnServiceName, AnServiceFile: String;
      const AnProc: TGetStarted);
    // Удаление сервиса
    procedure RemoveService(AnServiceName: String);
    // Получение хендла IB сервера
    function GetServerHandle: HWND;
    // Получение хендла IB guard
    function GetGuardHandle: HWND;
{    // Получение хендла сервера отчетов
    function GetReportHandle: HWND; sty}
    // Перезапуск системы
    procedure ShutDownNeeded;
    // Перезапуск системы
    procedure DoShutDown;
    // Читаем из реестра какие модули уже проинсталлированны
    procedure ReadInstalledModules;
    // Возвращает чарсет
    function GetCharset: String;
    // Поиск пути к базы даных
    function GetDatabasePath: String;
    // Проверка наличия Interbase сервера на удаленном компьютере
    function TestIBServer(const AComputerName, AUserName, APassword: String): Boolean;
    // Проверка наличия IB user
    function TestIBUser(const AComputerName, AUserName: String): Boolean;
    // Проверка наличия БД
    function TestIBDatabase(const ADatabaseName, AUserName, APassword: String;
      var AnErrorMessage: String): Boolean;
    // Апгрейд БД
    procedure UpgradeDatabase(const AnServerName, AnDatabaseFile,
      AnEtalonFile: String);
    // Дабавляет нового IB пользователя
    procedure AddIBUser(const AComputerName, AUserName, AUserPassword: String);
    // Изменяет существующего IB юзера
    procedure ModifyIBUser(const AComputerName, AUserName, AUserPassword: String);
    // Список компьютеров в сети
    procedure EnumNetworkComputers(P: PNetResource; List: TStrings);
    // Восстановление БД
    procedure RestoreDB(AnServerName, AnDatabaseTarget, AnSourceBk: String);
    // Запрос пароля
    procedure QueryPassword;
    // Запрос на изменение пароля SYSDBA
    procedure ChangePassword(const aDBFileName: String);
{    // Присваивоение роли администратора пользователю
    procedure SetUserRole(const AnUser: String); sty}
    // Возвращает путь к файлу данных деинсталяции
    function GetUninstallDatFile: String;
    // Сохранение файла данных деинсталяции
    procedure SaveUninstall;
    function GetFileParams(const AnFilePath: String): String;

{    // Запуск сервера отчетов
    procedure StartReportServer(const AnReportServerPath, AnReportGuardPath: String); 
    // Останов сервера отчетов
    procedure StopReportServer; sty}

    // Получаем путь к ПУСКу
    function GetStartProgramDir: String;

{    // Извлекаем имя сервера из сетевого пути
    function ExtractServerName(AnPath: String): String; sty}

// Чтение списка файлов из files.ini (если есть)
    procedure ReadInstallFiles;

    function OwnerHandle: Integer;
    function GetTempFileName: String;
(*    procedure SetSettingNeeded(const ADatabaseName: String; const AnSettingNeeded: Boolean = True); sty *)
    procedure SetNullID(const ADatabaseName: String);
    function GetFileFromList(const AnList: TStrings; const AnPath: String;
      const AnExcept: Boolean = False): String;
    function GetProtocol: TProtocol;
    function GetInstallLanguage: Word;
    function CheckServerName(const AnName: String): Boolean;

  protected
    procedure Loaded; override;
    procedure RunSelfCopy(AnParams: String);
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;
  // Точки входа
    // Удаление старого ИБ сервера
    procedure DeleteOldIBServer;
    // Проверка существования путей Гедемина
    procedure CheckGedeminServerPaths;

  // Основные методы инсталлятора
    // Выполняет инсталляцию сервера одного из клонов IB
    procedure InstallIBServer(const AnVersion: TIBVersion);
    // Выполняет инсталляцию dll файлов для сервера
    procedure InstallServerDll;
    // Устанавливает IB client
    procedure InstallIBClient(const AnVersion: TIBVersion);
    // Выполняет инсталляцию Gedemin
    procedure InstallGedemin;

{    // Выполняет инсталяцию сервера отчетов
    procedure InstallReportServer; sty}
    
    // Выполняет необходимые манипуляции с базой данных ???Upgrade, Modify???
    procedure InstallDatabase;

  // Главная функция для запуска инсталляции
    procedure StartInstall;
  // Главная функция для запуска деинсталляции
    procedure StartUninstall;
  // Установка флана прерывания процесса
    procedure DoBreak;

    property InstallType: TInstallType read FInstallType write FInstallType;
    property InstallModules: TInstallModules read FInstallModules write FInstallModules;
    property YetInstalledModules: TInstallModules read FYetInstalledModules;
    property LogFileName: String read GetLogFileName;
    property InstallRootDir: String read FInstallRootDir;
  published
    property ArchiveType: TArchiveType read FArchiveType write FArchiveType;
    property ProgramPath: String read FTargetProgramPath write SetTargetProgramPath;
    property InterbasePath: String read FTargetInterbasePath write SetTargetInterbasePath;
    property QueryInstallType: TQueryInstallType read FQueryInstallType write FQueryInstallType;
    property QueryInstallModules: TQueryInstallModules read FQueryInstallModules write FQueryInstallModules;
    property InstallLog: TInstallLog read FInstallLog write FInstallLog;
    property InstallFinish: TInstallFinish read FInstallFinish write FInstallFinish;
  end;

const
  cSystemPath = '{SYSTEM}';
  cInterbasePath = '{INTERBASE}';
  cProgrammPath = '{PROGRAMM}';
  cDatabasePath = '{DATABASE}\';

  cServerFlags = [imServer, imServerDll, imDatabase];
  cClientFlags = [imClient, imGedemin];
//  cReportFlags = [imClient, ImReport];

  cBkPref = 'bk_';
  NewPrefix = 'New_';

procedure Register;

function GetLocalDatabase(AnDBPath: String): String;
// Возвращает локальный путь к базе из сетевого
function GetServerDatabase(AnDBPath: String): String;

implementation

uses
  JclFileUtils, SysUtils, Registry, Forms, gsSysUtils, inst_files, WinSvc,
  JclSecurity, DbLogDlg, FileCtrl, inst_dlgSelectDatabase_unit,
  IBDatabase, IBSQL, gd_directories_const, inst_const, ShellApi, gd_boDBUpgrade,
  {rp_server_connect_option, }IB, gsShortCut, JclShell, ShlObj, inst_var, Controls,
  inst_dlgRenameFile_unit, {inst_OpenDir_unit, }JclLanMan, inst_string_const, ActiveX,
  ComObj, Dialogs, inst_frmProgress_unit, inst_service_config2, inst_memsize,
  inst_dlgChooseDB_unit, inst_dlgSelfExtrInfo_unit, WinSock, JclLocales, JclStrings
  {$IFDEF INSTALL}
  ,ComServ
  {$ENDIF}
  ;


type
  TDllRegister = function: HResult; stdcall;
  TWSAEnumProtocols = function(lpiProtocols: PINT;
   lpProtocolBuffer: Pointer; lpdwBufferLength: LPDWORD): Integer; stdcall;
  TQueryServiceConfig2 = function(hService: SC_HANDLE; dwInfoLevel: DWORD;
    lpBuffer: Pointer; cbBufSize: DWORD; pcbBytesNeeded: LPDWORD): BOOL; stdcall;
  TChangeServiceConfig2 = function(hService: SC_HANDLE; dwInfoLevel: DWORD;
    lpInfo: Pointer): BOOL; stdcall;

const
  clInterbase = 'INTERBASE';
  clFireBird  = 'FIREBIRD';
  clYaffil    = 'YAFFIL';

procedure Register;
begin
  RegisterComponents('Install', [TGedeminInstall]);
end;

{ TGedeminInstall }

procedure TGedeminInstall.AddIBUser(const AComputerName, AUserName,
  AUserPassword: String);
begin
  with TIBSecurityservice.Create(nil) do
  try
    ServerName := AComputerName;
    Protocol := GetProtocol;
    LoginPrompt := False;
    Params.Add('user_name=' + FIBUser);
    Params.Add('password=' + FIBPassword);
    Active := True;
    try
      UserName := AUserName;
      Password := AUserPassword;
      try
        AddUser;
      except
        on E: Exception do
          raise Exception.Create(Format(cExpCreateUser, [E.Message]));
      end;
    finally
      Active := False;
    end;
  finally
    Free;
  end;
end;

procedure TGedeminInstall.ChangePassword(const aDBFileName: String);
var
{  IBDatabase: TIBDatabase;
  IBTransaction: TIBTransaction;}
  IBSQLWork: TIBSQL;
  TempPass: String;
begin 
  { DONE -oJKL : Необходимо реализовать смену пароля }
  if FIBFirstInstall and
     (InstallType = itMulti) and
     (not FNewPasswordQuered) then
    begin
      if (MessageBox(OwnerHandle, PChar(Format(cFirstChangePassword, [vServerName])),
           'Внимание', MB_YESNO or MB_ICONQUESTION) = IDYES) and
         LoginDialogEx('Введите новый пароль', FIBUser, TempPass, True) then
        begin
          ModifyIBUser(GetComputerNameString, FIBUser, TempPass);
          FIBPassword := TempPass;
          FPasswordQuered := True;
        end;
      FNewPasswordQuered := True;      // юзеру задавался вопрос
    end;

  // Сервер может уже стоять с другим паролем, поэтому меняем по умолчанию
  if FIBPassword <> cSysPass then
  begin
    { DONE -oJKL : Подключение к базе изменение пароля для администратора }
    Assert(FDatabasePath <> '');
{\Yuri/}
    IBSQLWork := TIBSQL.Create(nil);
    try
      IBSQLWork.Transaction := TIBTransaction.Create(nil);
      try
        IBSQLWork.Database := TIBDatabase.Create(nil);
        try     
          IBSQLWork.Database.DatabaseName := aDBFileName;////ADatabaseName;
          IBSQLWork.Database.Params.Add('user_name=' + FIBUser);
          IBSQLWork.Database.Params.Add('password=' + FIBPassword);
          IBSQLWork.Database.Params.Add('lc_ctype=' + DefaultLc_ctype); //!!
          IBSQLWork.Database.SQLDialect := 3;
          IBSQLWork.Database.LoginPrompt := False;
          IBSQLWork.Transaction.DefaultDatabase := IBSQLWork.Database;
          IBSQLWork.Database.Connected := True;
          IBSQLWork.Transaction.StartTransaction;
          IBSQLWork.SQL.Text := 'UPDATE gd_user SET ibpassword = ' +
                                AnsiQuotedStr(FIBPassword, '''') +
                                ' WHERE id = ' + IntToStr(ADMIN_KEY);
          IBSQLWork.ExecQuery;
          IBSQLWork.Transaction.Commit;
        finally
          IBSQLWork.Database.Free;
        end;
      finally
        IBSQLWork.Transaction.Free;
      end;
    finally
      IBSQLWork.Free;
    end;
{/Yuri\}

(*    IBDatabase := TIBDatabase.Create(nil);
    try
      IBDatabase.DatabaseName := aDBFileName;//FDatabasePath;
      IBDatabase.Params.Add('user_name=' + FIBUser);
      IBDatabase.Params.Add('password=' + FIBPassword);
      IBDatabase.Params.Add('lc_ctype=' + DefaultLc_ctype);
      IBDatabase.SQLDialect := 3;
      IBDatabase.LoginPrompt := False;
      IBDatabase.Open;

      IBTransaction := TIBTransaction.Create(nil);
      try
        IBDatabase.DefaultTransaction := IBTransaction;
        IBTransaction.DefaultDatabase := IBDatabase;
        IBTransaction.StartTransaction;

        IBSQLWork := TIBSQL.Create(nil);
        try
          IBSQLWork.Database := IBDatabase;
          ibSQLWork.SQL.Text := 'UPDATE gd_user SET ibpassword = ' +
                                AnsiQuotedStr(FIBPassword, '''') +
                                ' WHERE id = ' + IntToStr(ADMIN_KEY);
//          ShowMessage('bef ExecQuery');
          ibSQLWork.ExecQuery;
//          ShowMessage('aft ExecQuery');

          IBTransaction.Commit;

          IBDatabase.Close;
        finally
          ibSQLWork.Free;
        end;
      finally
        IBTransaction.Free;
      end;
    finally
      IBDatabase.Free;
    end;*)
  end;

end;

function TGedeminInstall.CheckFileVersion(AnFileSource: TInstallFile;
  AnFileTarget: String): Boolean;
var
  FVI: TJclFileVersionInfo;                            
begin
  DoLog('Проверка версии файла: ' + AnFileTarget);
  case FArchiveType of
    artFile:
    begin
      if not FileExists(GetSourceMainPath + AnFileSource.FileName) then
        raise Exception.Create(Format(cExpInstallationFailed,
         [GetSourceMainPath + AnFileSource.FileName]));

      // Если для файла задана минимальная версия, то проверяем по ней
      if (AnFileSource.MinVersion.dwFileVersionMS <> 0) or
         (AnFileSource.MinVersion.dwFileVersionLS <> 0) then 
      begin
        if FileExists(AnFileTarget) then
        begin           
          FVI := JclFileUtils.TJclFileVersionInfo.Create(AnFileTarget);
          try
            Result := (FVI.FixedInfo.dwFileVersionMS < AnFileSource.MinVersion.dwFileVersionMS) or
                      ( (FVI.FixedInfo.dwFileVersionMS = AnFileSource.MinVersion.dwFileVersionMS) and
                        (FVI.FixedInfo.dwFileVersionLS < AnFileSource.MinVersion.dwFileVersionLS)  );
          finally
            FVI.Free;
          end;
        end else
          Result := True;
      end else
        // В противном случае по дате файла
        if AnFileSource.IsRewrite then
          Result := FileAge(GetSourceMainPath + AnFileSource.FileName) <> FileAge(AnFileTarget)
        else
          Result := FileAge(GetSourceMainPath + AnFileSource.FileName) > FileAge(AnFileTarget);
    end;
    {artZip:;
    artRes:;}
  else
    raise Exception.Create(cExpWrongArchiveType);
  end;
end;
(*
// Проверяем дату саморасп. архивов.
function TGedeminInstall.CheckSelfExtractVersion(aSelfExtractName: String): Boolean;
begin
  Result := False;
{    FVI := JclFileUtils.TJclFileVersionInfo.Create(AnFileTarget);
    try
      Result := (FVI.FixedInfo.dwFileVersionMS < AnFileSource.MinVersion.dwFileVersionMS)
       or ((FVI.FixedInfo.dwFileVersionMS = AnFileSource.MinVersion.dwFileVersionMS)
       and (FVI.FixedInfo.dwFileVersionLS < AnFileSource.MinVersion.dwFileVersionLS));
    finally
      FVI.Free;
    end;}

//cSelfExtractVerPath
end;
*)
procedure TGedeminInstall.CheckGedeminServerPaths;
begin

end;

function TGedeminInstall.CheckIBClientVersion(var AnVersion: String;
  var AnCanClientUpdate: Boolean): TIBVersion;
var
  SL: TStrings;
  J: Integer;
  STmp, STmp2, IBClientPath: String;
  ExistsClientInfo, InstallClientInfo: TIBServerClone;
  ValidIBDate: TDateTime;

  function GetClientCloneVersion(AnFileName: String): TIBServerClone;
  var
    TempStr: String;
  begin
    Assert(FileExists(AnFileName), 'Файл не найден ' + AnFileName);
    Result.FileDate := FileAge(AnFileName);
    with JclFileUtils.TJclFileVersionInfo.Create(AnFileName) do
    try
      TempStr := ProductName;

      if Pos(clInterbase, AnsiUpperCase(TempStr)) > 0 then
        Result.FileCompany := ctInterbase
      else
        if Pos(clFireBird, AnsiUpperCase(TempStr)) > 0 then
          Result.FileCompany := ctFirebird
        else
          if Pos(clYaffil, AnsiUpperCase(TempStr)) > 0 then
            Result.FileCompany := ctYaffil
          else
            // В некоторых версиях Firebird строка была пуста
            if TempStr = '' then
              Result.FileCompany := ctFirebird
            else
              Result.FileCompany := ctUnknown;
      case Result.FileCompany of
        ctInterbase: TempStr := 'Interbase';
        ctFirebird:  TempStr := 'Firebird';
        ctYaffil:    TempStr := 'Yaffil';
        ctUnknown:   TempStr := 'Неизвестный';
      end;
      Result.FileVersion := Format('%s клиент c версией файла: %s, датой: %s',
       [TempStr, BinFileVersion, DateTimeToStr(FileDateToDateTime(Result.FileDate))]);
    finally
      Free;
    end;
  end;   // function GetClientCloneVersion

begin
  ValidIBDate := EncodeDate(2003, 12, 29);
  Result := ibsAbsent;
  AnCanClientUpdate := False;

  SL := TStringList.Create;
  try
    for J := 0 to vClientListCount - 1 do
      if Pos(AnsiUpperCase(vMainClientFileName), AnsiUpperCase(vClientList[J].FileName)) > 0 then
      begin
        STmp := GetSourceMainPath + vClientList[J].FileName;
        IBClientPath := ExtractFilePath(GetTargetFileName(vClientList[J]));
        Break;
      end;

    InstallClientInfo := GetClientCloneVersion(STmp);
    FInstallClientType := InstallClientInfo;

    FindFile(vMainClientFileName, SL);
    if SL.Count > 0 then
    begin
      // Ищем файл сервера в каталоге прописанном в реестре
      STmp2 := GetFileFromList(SL, IBClientPath);
      if STmp2 = '' then
        STmp2 := SL[0];

      ExistsClientInfo := GetClientCloneVersion(STmp2);
      FExistsClientType := ExistsClientInfo;

      AnVersion := ExistsClientInfo.FileVersion;

      if (ExistsClientInfo.FileCompany = ctYaffil) and
         (ExistsClientInfo.FileDate >= DateTimeToFileDate(ValidIBDate)) then
        Result := ibsRight
      else 
        Result := ibsWrong;

      // Проверяем на точное соответствие
      if (InstallClientInfo.FileDate = ExistsClientInfo.FileDate) and
         (InstallClientInfo.FileCompany = ExistsClientInfo.FileCompany) then
        Result := ibsExact;                                           
      // Проверяем на совпадение типов клонов и на необходимость апгрейда
      AnCanClientUpdate := // Yuri (InstallClientInfo.FileCompany = ctYaffil) and
                           (InstallClientInfo.FileCompany = ExistsClientInfo.FileCompany) and
                           (InstallClientInfo.FileDate > ExistsClientInfo.FileDate);
    end;
  finally
    SL.Free;
  end;
end;

function TGedeminInstall.CheckIBServerVersion(var AnVersion: String;
  var AnCanServerUpdate: Boolean): TIBVersion;
const
//  ValidIBDate = 36700; //23.06.2000
  ValidIBFileDate = 798824673; // 29.12.2003 
var
  SL: TStrings;
  IBServerProperties: TIBServerProperties;
  J: Integer;
  STmp, STmp2: String; 
  ExistsServerInfo, InstallServerInfo: TIBServerClone;
  CantLoad: Boolean;
//  InterbasePath1: String;    

  function GetServerCloneVersion(AnFileName: String): TIBServerClone;
  var
    TempStr: String;
  begin
    Assert(FileExists(AnFileName), 'Файл не найден ' + AnFileName);
    Result.FileDate := FileAge(AnFileName);
    with JclFileUtils.TJclFileVersionInfo.Create(AnFileName) do
    try
      TempStr := ProductName;

      if Pos(clInterbase, AnsiUpperCase(TempStr)) > 0 then
        Result.FileCompany := ctInterbase
      else
        if Pos(clFireBird, AnsiUpperCase(TempStr)) > 0 then
          Result.FileCompany := ctFirebird
        else
          if Pos(clYaffil, AnsiUpperCase(TempStr)) > 0 then
            Result.FileCompany := ctYaffil
          else
            // В некоторых версиях Firebird строка была пуста
            if TempStr = '' then
              Result.FileCompany := ctFirebird
            else begin 
              Result.FileCompany := ctUnknown;
              TempStr := 'Неизвестный сервер';
            end;

      Result.FileVersion := TempStr + ' c версией файла: ' + BinFileVersion;
    finally
      Free;
    end;
  end;

  function CheckStringVersion(AnVer: String): TIBVersion;
  const
    cVersionDigits = ['0'..'9', '.'];
  var
    S: String;
    I: Integer;
  begin 
//    Result := ibsRight;
    AnVer := AnsiUpperCase(AnVer);
{    // Firebird подходит
    if Pos(clFirebird, AnVer) > 0 then
      Exit;  // Yuri - не подходит!}

    // Yaffil подходит
    if Pos(clYaffil, AnVer) = 0 then
    begin
      Result := ibsWrong;
      Exit;
    end;

    // Вытягиваем версию
    i := 1;
    S := '';
    while I <= Length(AnVer) do
    begin
      if AnVer[I] in cVersionDigits then
      begin
        while (I <= Length(AnVer)) and (AnVer[I] in cVersionDigits) do
        begin
          S := S + AnVer[I];
          Inc(I);
        end;
        Break;
      end;
      Inc(I);
    end;
    if S <> '' then
    begin            
      if S >= '1.2.877' then
        Result := ibsRight
      else
        Result := ibsWrong;
    end else
      Result := ibsWrong;
(*
    // Вытягиваем версию
    I := 1;
    while I <= Length(AnVer) do
    begin
      if AnVer[I] in cVersionDigits then
      begin
        while (I <= Length(AnVer)) and (AnVer[I] in cVersionDigits) do
        begin
          S := S + AnVer[I];
          Inc(I);
        end;
        Break;
      end;
      Inc(I);
    end;
    // Проверяем
    if S <> '' then
    begin
      if StrToInt(S) < 6 then
        Result := ibsWrong;
    end else
      Result := ibsWrong; *)
  end;
begin
// dd
  DoLog('Проверка версии сервера базы данных');
  FLocalErrorCode := 0;
  AnVersion := '';
  AnCanServerUpdate := False;
  CantLoad := False;
  try
    if not TestIBServer(GetComputerNameString, FIBUser, FIBPassword) then
    begin
      if FLocalErrorCode = 335544472 then        // = isc_login
        QueryPassword
      else
        CantLoad := True;
    end else
      FPasswordQuered := True;
  except
    QueryPassword;
  end;

  // Получаем информацию о сервере в инсталляции
  for J := 0 to vServerListCount - 1 do
    if Pos(AnsiUpperCase(vMainServerFileName), AnsiUpperCase(vServerList[J].FileName)) > 0 then
    begin
      STmp := GetSourceMainPath + vServerList[J].FileName;
      Break;
    end;
  InstallServerInfo := GetServerCloneVersion(STmp);
  FInstallServerType := InstallServerInfo;

  Result := ibsAbsent;
  try
    // Пытаемся подключиться к серверу
    if not CantLoad and
       TestIBServer(GetComputerNameString, FIBUser, FIBPassword) then
    begin
      FLocalErrorCode := 0;
      IBServerProperties := TIBServerProperties.Create(nil);
      try
        IBServerProperties.ServerName := GetComputerNameString;
        IBServerProperties.Params.Add('user_name=' + FIBUser);
        IBServerProperties.Params.Add('password=' + FIBPassword);
        IBServerProperties.LoginPrompt := False;
        IBServerProperties.Protocol := GetProtocol;
        IBServerProperties.Options := [Database, {License, LicenseMask, }ConfigParameters, Version];

        try
          IBServerProperties.Active := True;
          // Считываем информацию о версии сервера
          IBServerProperties.Fetch;
//          IBServerProperties.FetchVersionInfo;
          AnVersion := IBServerProperties.VersionInfo.ServerVersion;
// Yuri          InterbasePath := IBServerProperties.ConfigParams.BaseLocation;
          // Вытягиваем из строки значение и сравниваем
          Result := CheckStringVersion(AnVersion);  // Yuri - проверяем только клон (Yaffil или нет)
        except
          AnVersion := 'Interbase server неизвестной версии';
          Result := ibsWrong;
//          exit;
        end;
      finally
        IBServerProperties.Free;
      end;
    end else       // не подключились к серверу
    begin
      SL := TStringList.Create;
      try
        SL.Clear;
        for J := 0 to cServerExeCount - 1 do
          // Поиск файла сервера
          FindFile(cServerExeNames[J], SL, False);
        if SL.Count > 0 then
        begin
          // Если нашли, то определяем его версию
          { DONE -oJKL : Временно. Надо определять версию из файла. }

          // Ищем файл сервера в каталоге прописанном в реестре
          STmp2 := GetFileFromList(SL, InterbasePath);
          if STmp2 = '' then
          begin
            STmp2 := SL[0];
// sty            InterbasePath := ExtractIBPathFromFileName(SL[0]);
          end;

          ExistsServerInfo := GetServerCloneVersion(STmp2);
          AnVersion := ExistsServerInfo.FileVersion;
                                          
          if (ExistsServerInfo.FileCompany = ctYaffil) and
             (ExistsServerInfo.FileDate >= {DateTimeToFileDate(}ValidIBFileDate{)}) then
            Result := ibsRight 
          else
            Result := ibsWrong;  
        end;
      finally
        SL.Free;
      end;
    end;

    // Проверяем точное совпадение
    SL := TStringList.Create;
    try
      SL.Clear;
      for J := 0 to cGuardExeCount - 1 do
        FindFile(cGuardExeNames[J], SL, False);
      FGuardExePath := GetFileFromList(SL, InterbasePath);
      SL.Clear;
      for J := 0 to cServerExeCount - 1 do
        // Поиск файла сервера
        FindFile(cServerExeNames[J], SL, False);
      if SL.Count > 0 then
      begin
        // Ищем файл сервера в каталоге прописанном в реестре
        STmp2 := GetFileFromList(SL, InterbasePath);
        // Если файл сервера не найден в пути прописанном в реестре, то ставим сервер заново
        // Все старые деактивируем
        if STmp2 = '' then
        begin
          Result := ibsWrong;
          Exit;
        end else
          FServerExePath := STmp2;

        ExistsServerInfo := GetServerCloneVersion(STmp2);
        FExistsServerType := ExistsServerInfo;

        // Проверяем на точное соответствие
        if (InstallServerInfo.FileDate = ExistsServerInfo.FileDate) and
           (InstallServerInfo.FileCompany = ExistsServerInfo.FileCompany) then
          Result := ibsExact;

        // Проверяем на совпадение типов клонов и на необходимость апгрейда
        AnCanServerUpdate := (InstallServerInfo.FileCompany = ExistsServerInfo.FileCompany) and
                             (InstallServerInfo.FileDate > ExistsServerInfo.FileDate);
      end;
    finally
      SL.Free;
    end;

  except
    // При отсутствии gds32.dll или fbclient.dll кидает ошибку
    // т.е. если IB на компьютере еще не устанавливался
    on E: Exception do
    begin
    end;
  end;
  if FLocalErrorCode = 335544472 then  // = isc_login
    raise Exception.Create('Your user name and password are not defined. ' +
      'Ask your database administrator to set up a ' + vServerName + ' login');
end;

function TGedeminInstall.CheckPathList(AnPathList: TStrings;
  const AnSourceFile: String; var AnTargetPath: String): Boolean;
var
  I: Integer;
  S: String;
begin
  Result := True;
  case AnPathList.Count of
//  -1:;
    0:
      begin
        AnPathList.Add(AnTargetPath);
//        ShowMessage('0. ' + AnTargetPath);
      end;
{    1:
    if AnsiUpperCase(AnTargetPath) <> AnsiUpperCase(AnPathList.Strings[0]) then
    begin
      DoLog('На вашем компьютере обнаружен файл ' + AnPathList.Strings[0] +
       '. Директория для инсталляции не совпадает');// и будет заменена на существующую.');
//      AnTargetPath := AnPathList.Strings[0];
    end;}
  else
    if (AnPathList.Count = 1) and
       (AnsiUpperCase(AnTargetPath) = AnsiUpperCase(AnPathList.Strings[0])) then
      Exit;

//  ShowMessage('1. ' + AnsiUpperCase(AnTargetPath) + '.' + AnsiUpperCase(AnPathList.Strings[0]));
//    S := Format('ВНИМАНИЕ!!! В системных директориях найдено %d файлов %s. Они будут переименованы.',
//     [AnPathList.Count, ExtractFileName(AnPathList.Strings[0])]);
//    MessageBox(OwnerHandle, PChar(S), 'Внимание', MB_OK or MB_ICONWARNING);
//    DoLog(S);
    if not FileExists(GetSourceMainPath + AnSourceFile) then
      raise Exception.Create(Format(cExpInstallationFailed,
       [GetSourceMainPath + AnSourceFile]));
    for I := 0 to AnPathList.Count - 1 do
      if (AnsiUpperCase(AnTargetPath) <> AnsiUpperCase(AnPathList.Strings[I])) and
// Сейчас необходимость проверки задается в файле
{        (ExtractFileName(AnsiUpperCase(AnTargetPath)) <> 'LICENSE.TXT') and
        (ExtractFileName(AnsiUpperCase(AnTargetPath)) <> 'README.TXT') and}
        FileExists(AnTargetPath) then
      begin
{        S := Format('Обнаружен файл %s. Он будет переименован %s.',
         [AnPathList.Strings[I], ExtractFilePath(AnPathList.Strings[I]) +
          cBkPref + ExtractFileName(AnPathList.Strings[I])]);}
        S := ExtractFilePath(AnPathList.Strings[I]) + cBkPref +
          ExtractFileName(AnPathList.Strings[I]);
//        ShowMessage(AnPathList.Strings[I] + '. ' + ExtractFileName(AnPathList.Strings[I]));
        with TdlgRenameFile.Create(Owner) do
        try                                                                    
//          ShowMessage(AnPathList.Strings[I] + '. ' + #13#10 + GetSourceMainPath + '___' + AnSourceFile);
          case ShowModalEx(AnPathList.Strings[I], GetSourceMainPath + AnSourceFile, S) of
            rrRename:
            begin
              RenameInstFile(AnPathList.Strings[I], S);               
              DoLog('Файл ' + AnPathList.Strings[I] + ' переименован в ' + S);
            end;
            rrReplace:
            begin
              CopySourceFile(AnSourceFile, AnPathList.Strings[I]);
              DoLog('Файл ' + AnPathList.Strings[I] + ' заменен'); // + 'файлом из инсталляции'
            end;
            rrNone: DoLog('Файл ' + AnPathList.Strings[I] + ' оставлен без изменений');
            rrDelete:
            begin
              DeleteTargetFile(AnPathList.Strings[I]);
              DoLog('Файл ' + AnPathList.Strings[I] + ' удален');
            end;
          else
            raise Exception.Create(cExpUnknownActionType);
          end;
        finally
          Free;
        end;
//        MessageBox(OwnerHandle, PChar(S), 'Внимание', MB_OK or MB_ICONWARNING);
      end;
  end;
  { DONE -oJKL -cCheckPathList :
1. Запрос на продолжение
2. Возможно предлагать удаление
3. Ставить первой системную директорию }
end;

function TGedeminInstall.CheckTCPIP: Boolean;
var
  LibHandle: HINST;
  WSAEnumProtocols: TWSAEnumProtocols;
  lpProtocolBuffer: TWSAPROTOCOL_INFO;
  BufSize: Integer;
  ProcCount: Integer;
  WSAData: TWSAData;
  Protocol: Integer;
begin
  Result := False;
  LibHandle := LoadLibrary('WS2_32.DLL');
  if LibHandle <> 0 then
  begin
    WSAStartup($0101, WSAData);
    @WSAEnumProtocols := GetProcAddress(LibHandle, 'WSAEnumProtocolsA');
    if @WSAEnumProtocols <> nil then
    begin
      BufSize := SizeOf(lpProtocolBuffer);
      Protocol := IPPROTO_TCP;
      FillChar(lpProtocolBuffer, BufSize, #0);
      ProcCount := WSAEnumProtocols(@Protocol, @lpProtocolBuffer, @BufSize);
      if ProcCount = -1 then
        DoLog(Format('Ошибка при проверке протокола: %d, протокол: %d', [GetLastError, lpProtocolBuffer.iProtocol]))
      else
        Result := (ProcCount <> 0);// or (lpProtocolBuffer.iProtocol = IPPROTO_TCP);
    end;
    WSACleanup;
  end;
  if LibHandle <> 0 then
    FreeLibrary(LibHandle);
end;

// Проверка прав пользователя. OK, если Administrator или не WinNT  
function TGedeminInstall.CheckUserRight: Boolean;
begin 
  DoLog('Проверка прав пользователя');
  Result := (FWindowsVersion < wvWinNT31) or JclSecurity.IsAdministrator;
end;

procedure TGedeminInstall.CopySourceFile(AnFileSource,
  AnFileTarget: String);
begin
  DoLog('Копируется файл: ' + AnFileTarget);
  case FArchiveType of
    artFile: ReplaceFile(GetSourceMainPath + AnFileSource, AnFileTarget);
    {artZip:;
    artRes:;}
  else
    raise Exception.Create(cExpWrongArchiveType);
  end;
end;

constructor TGedeminInstall.Create(Owner: TComponent);
begin
  inherited;

//  ShowMessage(JclFileUtils.PathGetShortName('C:\PROGRAM FILES\YAFFIL\BIN\GDS32.DLL'));

  FWinRussian := (GetInstallLanguage = 419);

  FArchiveType := artFile;
  FIBUser := SysDBAUserName;
  FIBPassword := cSysPass;
  FPasswordQuered := False;
  FNewPasswordQuered := False; 
  FIBFirstInstall := True;
  FNeedSelfExtractInfo := True; 

  if not (csDesigning in ComponentState) then
  begin
    FUnInstallList := TInstallList.Create;
    FOldUnInstallList := TInstallList.Create;
    FWindowsVersion := JclSysInfo.GetWindowsVersion;

    ReadInstallFiles;           // 1
    ReadInstalledModules;       // 2
    {$IFDEF DEBUG}
    FLogList := TStringList.Create;
    {$ENDIF}
//    FDelayedFilesList := TStringList.Create;
  end;
end;

procedure TGedeminInstall.CreateDirectory(AnPath: String);
var
  SL: TStrings;
  I: Integer;
begin
  AnPath := ExcludeTrailingBackslash(AnPath);
  SL := TStringList.Create;
  try
    // Создаем список до первой существующей директории
    while not DirectoryExists(AnPath) and
          (AnPath <> '') do
    begin
      if ExcludeTrailingBackslash(AnPath) = ExtractFileDrive(AnPath) then
        raise Exception.Create('Не найден диск ' + AnPath);
      SL.Add(AnPath);
      AnPath := ExtractFileDir(AnPath);
    end;
    // Создаем в обратном порядке
    for I := SL.Count - 1 downto 0 do
      if not CreateDir(SL.Strings[I]) then
        raise Exception.Create(Format(cExpCantCreateFolder, [SL.Strings[I]]));
  finally
    SL.Free;                           
  end;
end;

procedure TGedeminInstall.CreateFileLink(const AnTargetPath, AnFileName, AnLinkName: String; const isDesktopIcon: Boolean = False);
const
  cExe = '.EXE';
var
  TargetPath, LinkName, LinkFile: String;
begin
  if (cExe = AnsiUpperCase(ExtractFileExt(AnFileName))) or (AnLinkName <> '') then
  begin

    if Trim(AnLinkName) = '' then
      LinkName := ChangeFileExt(ExtractFileName(AnFileName), '')
    else
      LinkName := AnLinkName;
                                      
    if isDesktopIcon then    // нужен ярлык на Рабочем столе  
    begin
      LinkFile := jclSysInfo.GetDesktopFolder + '\' + LinkName + '.lnk';
      if CreateLink(AnFileName, LinkFile, '') then
        FUnInstallList.AddFile(cL, LinkFile, False, False);
    end;
 
    TargetPath := AnTargetPath + vLinkMainPath;
    CreateDirectory(TargetPath);
    LinkFile := TargetPath + '\' + LinkName + '.lnk';
    if CreateLink(AnFileName, LinkFile, '') then
      FUnInstallList.AddFile(cL, LinkFile, False, False);

  end;
end;

procedure TGedeminInstall.DeleteOldIBServer;
begin

end;

procedure TGedeminInstall.RemoveService(AnServiceName: String);
var
  HSCM: Cardinal;
  HSvr: Cardinal;
begin
  // Открываем менеджер
//  DoLog('Попытка открыть SCManager');
  HSCM := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
//  DoLog('SCManager открыт');
  if HSCM <> 0 then
  begin
    HSvr := OpenService(HSCM, PChar(AnServiceName), SERVICE_ALL_ACCESS);
    if HSvr <> 0 then
    begin
      if not DeleteService(HSvr) then
        raise Exception.Create(GetLastErrorMessage);
      CloseServiceHandle(HSvr);
    end;
    // Закрываем менеджер
    CloseServiceHandle(HSCM);
  end else
    raise Exception.Create(cExpCantConnectServiceManager);
end;

procedure TGedeminInstall.DeleteTargetFile(AnFileTarget: String);
var
  BatName: String;
  SR: TSearchRec;
  I: Integer;
  F: TextFile;
  Reg: TRegistry;
  SysDir, WinDir: array[0..1024] of Char;
begin
  GetSystemDirectory(SysDir, SizeOf(SysDir) - 1);
  GetWindowsDirectory(WinDir, SizeOf(WinDir) - 1);

  if (StrIPos(SysDir, AnFileTarget) = 1) or
    (StrIPos(WinDir, AnFileTarget) = 1) then
  begin
    DoLog('Файл "' + AnFileTarget + '" не будет удален, так как находится в системном каталоге.');
    exit;
  end;

  DoLog('Удаляется файл ' + AnFileTarget);

  if FileExists(AnFileTarget) then
    if not DeleteFile(AnFileTarget) then
    begin
      // ... проверяем его атрибуты ...
      if (FileGetAttr(AnFileTarget) and (faReadOnly or faHidden)) <> 0 then
      begin
        // ... и если надо снимаем ReadOnly ...
        if FileSetAttr(AnFileTarget, FileGetAttr(AnFileTarget) and $3C) = 0 then
        begin
          // ... пытаемся скопировать еще раз.
          if DeleteFile(AnFileTarget) then
            Exit;
        end
      end;

      DoLog(Format('Файл %s оставлен для последующего удаления', [AnFileTarget]));

      if FWindowsVersion > wvWinME then
      begin
        // Если NT и выше используем MoveFileEx
        if not MoveFileEx(PChar(AnFileTarget), nil, MOVEFILE_DELAY_UNTIL_REBOOT +
         MOVEFILE_REPLACE_EXISTING) then
          raise Exception.Create(GetLastErrorMessage);
        if not MoveFileEx(PChar(ExtractFileDir(AnFileTarget)), nil, MOVEFILE_DELAY_UNTIL_REBOOT +
         MOVEFILE_REPLACE_EXISTING) then
          raise Exception.Create(GetLastErrorMessage);
      end else
      begin
        BatName := GetTempFileName;
        AssignFile(F, BatName);
        if FileExists(BatName) then
          Append(F)
        else
          Rewrite(F);
        try
          Writeln(F, Format('DEL "%s"', [AnFileTarget]));
          Writeln(F, Format('RMDIR "%s"', [ExtractFileDir(AnFileTarget)]));
        finally
          CloseFile(F);
        end;
        // Прописываем вызов бат файла в реестре
        Reg := TRegistry.Create;
        try
          Reg.RootKey := HKEY_LOCAL_MACHINE;
          if Reg.OpenKey(cRunOnceRegPath, True) then
          begin
            Reg.WriteString('GedeminUninstall', BatName);
            Reg.CloseKey;
          end;
        finally
          Reg.Free;
        end;

      end;
      FRestartRequired := True;
    end;

  I := 1;
  while I <> 0 do
  begin
    AnFileTarget := ExtractFileDir(AnFileTarget);
    I := FindFirst(AnFileTarget + '\*', $FF, SR);
    while (I = 0) do
    begin
      if (SR.Name <> '.') and (SR.Name <> '..') then
        Break;
      I := FindNext(SR);
    end;
    FindClose(SR);
    if I <> 0 then
    begin
      JclFileUtils.DeleteDirectory(AnFileTarget, False);
    end;
  end;
end;

destructor TGedeminInstall.Destroy;
var
  F: TextFile;
begin
  if not (csDesigning in ComponentState) then
  begin
    if (FUnInstallList.Count > 0) then
    begin
      CreateDirectory(ExtractFileDir(GetUninstallDatFile));
      SaveUninstall;

      FUnInstallList.Free;
      FOldUnInstallList.Free;
    end;

    if (FTempFileName <> '') and FileExists(FTempFileName) then
    begin
      AssignFile(F, GetTempFileName);
      Append(F);
      try
        Writeln(F, Format('DEL "%s"', [GetTempFileName]));
        Writeln(F, 'echo on');
        Writeln(F, 'Закройте окно');
        Writeln(F, 'echo off');
      finally
        CloseFile(F);
      end;
    end;

    {$IFDEF DEBUG}
    FreeAndNil(FLogList);
    {$ENDIF}
//    FreeAndNil(FDelayedFilesList);
  end;

  inherited;
end;

procedure TGedeminInstall.DoFinish(AnSuccess: Boolean;
  AnErrorMessage: String = '');
begin
  if Assigned(FInstallFinish) then
    FInstallFinish(AnSuccess, AnErrorMessage);
end;

procedure TGedeminInstall.DoLog(AnMessage: String);
begin
  if Assigned(FInstallLog) then
    FInstallLog(AnMessage);
  {$IFDEF DEBUG}
  FLogList.Add(AnMessage);
  {$ENDIF}
end;

function TGedeminInstall.DoQueryInstallModules: TInstallModules;
begin
  if Assigned(FQueryInstallModules) then
    FQueryInstallModules(Self, FInstallModules);
  Result := FInstallModules;
end;

function TGedeminInstall.DoQueryInstallType: TInstallType;
begin
  if Assigned(FQueryInstallType) then
    FQueryInstallType(Self, FInstallType);
  Result := FInstallType;
end;

procedure TGedeminInstall.EnumNetworkComputers(P: PNetResource;
  List: TStrings);
var
  H: THandle;
  NumEntries, BufSize, I: DWORD;
  NetResource: array[1..1024] of TNetResource;
//  ComputerNameSize: DWORD;
//  ComputerName: array[0..MAX_COMPUTERNAME_LENGTH + 1] of Char;
begin
  if WNetOpenEnum(
    RESOURCE_GLOBALNET,
    RESOURCETYPE_DISK,
    RESOURCEUSAGE_CONTAINER,
    P,
    H) = NO_ERROR then
  begin
    NumEntries := 1024;
    BufSize := SizeOf(NetResource);
    if (WNetEnumResource(H, NumEntries, @NetResource, BufSize) = NO_ERROR) then
    begin
      for I := 1 to NumEntries do
      begin
        EnumNetworkComputers(@NetResource[I], List);
        if (Copy(Netresource[I].lpRemoteName, 1, 2) = '\\') and (not (Pos('\', Copy(Netresource[I].lpRemoteName, 3, 255)) > 0)) then
        begin
          List.Add(Copy(Netresource[I].lpRemoteName, 3, 255)); // выдаляем \\
          DoLog('Найден ресурс: ' + Netresource[I].lpRemoteName);
        end;
      end;
    end;

    WNetCloseEnum(H);
  end;
end;

procedure TGedeminInstall.FindFile(AnFileName: String;
  AnPathList: TStrings; AnClearList: Boolean = True);
var
  TempPathList: TStrings;
  VarName: String;
  VarBuff: Pointer;
  BuffSize: Integer;
  SystemPath, SingleSystemPath: String;
  LastIndex, I: Integer;
//  SR: TSearchRec;
  Reg: TRegistry;
  SL: TStrings;
begin
  if AnClearList then
    AnPathList.Clear;
  // Находим переменную системы PATH
  VarName := 'Path'#0;
  BuffSize := GetEnvironmentVariable(@VarName[1], nil, 0);
  GetMem(VarBuff, BuffSize);
  try
    GetEnvironmentVariable(@VarName[1], VarBuff, BuffSize);
    SystemPath := PChar(VarBuff);
  finally
    FreeMem(VarBuff, BuffSize);
  end;

  TempPathList := TStringList.Create;
  try
    // Создаем список для поиска файла во всех директориях прописанных в переменной PATH
    I := 0;
    repeat
      LastIndex := I + 1;
      I := Pos(';', SystemPath);
      if I = 0 then
        I := Length(SystemPath) + 1
      else
        SystemPath[I] := '_';
      // Выделяем директории по одной строке и приведим к длинному формату
      TempPathList.Add(AnsiUpperCase(JclFileUtils.PathGetLongName(Copy(SystemPath, LastIndex, I - LastIndex)) + '\' + AnFileName));
    until I > Length(SystemPath);

    // Производим поиск по реестру SharedDLL
    Reg := TRegistry.Create(KEY_READ);
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      if Reg.OpenKeyReadOnly(cSharedDLLRegPath) then
      begin
        SL := TStringList.Create;
        try
          Reg.GetValueNames(SL);
          for I := 0 to SL.Count - 1 do
            if Pos(AnsiUpperCase(AnFileName), AnsiUpperCase(SL.Strings[I])) > 0 then
            begin
              // Так надо, чтобы не проверять является ли найденый текст действительно файлом
              TempPathList.Add(AnsiUpperCase(ExtractFilePath(SL.Strings[I]) + AnFileName));
            end;
        finally
          SL.Free;
        end;
        Reg.CloseKey;
      end;

{      // Interbase
      if Reg.OpenKeyReadOnly(cInterbaseRegPath) then
      begin
        // Так надо, чтобы не проверять является ли найденый текст действительно файлом
        if Reg.ValueExists(RootDirectoryValue) then
          TempPathList.Add(GetCorrectPath(AnsiUpperCase(Reg.ReadString(RootDirectoryValue))) + '\' + AnFileName);
        if Reg.ValueExists(cIBValueServerDir) then
          TempPathList.Add(GetCorrectPath(AnsiUpperCase(Reg.ReadString(cIBValueServerDir))) + '\' + AnFileName);
        Reg.CloseKey;
      end;
      // Interbase 2
      if Reg.OpenKeyReadOnly(cInterbaseRegPath2) then
      begin
        // Так надо, чтобы не проверять является ли найденый текст действительно файлом
        if Reg.ValueExists(RootDirectoryValue) then
          TempPathList.Add(GetCorrectPath(AnsiUpperCase(Reg.ReadString(RootDirectoryValue))) + '\' + AnFileName);
        if Reg.ValueExists(cIBValueServerDir) then
          TempPathList.Add(GetCorrectPath(AnsiUpperCase(Reg.ReadString(cIBValueServerDir))) + '\' + AnFileName);
        Reg.CloseKey;
      end;

      // Firebird
      if Reg.OpenKeyReadOnly(cFirebirdRegPath) then
      begin
        // Так надо, чтобы не проверять является ли найденый текст действительно файлом
        if Reg.ValueExists(RootDirectoryValue) then
          TempPathList.Add(GetCorrectPath(AnsiUpperCase(Reg.ReadString(RootDirectoryValue))) + '\' + AnFileName);
        if Reg.ValueExists(cIBValueServerDir) then
          TempPathList.Add(GetCorrectPath(AnsiUpperCase(Reg.ReadString(cIBValueServerDir))) + '\' + AnFileName)
        else
          if Reg.ValueExists(RootDirectoryValue) then
            TempPathList.Add(GetCorrectPath(AnsiUpperCase(Reg.ReadString(RootDirectoryValue))) + '\BIN\' + AnFileName);
        Reg.CloseKey;
      end;}

      // Yaffil
      if Reg.OpenKeyReadOnly(cYaffilRegPath) then
      begin
        // Так надо, чтобы не проверять является ли найденый текст действительно файлом
        if Reg.ValueExists(RootDirectoryValue) then
          TempPathList.Add(GetCorrectPath(AnsiUpperCase(Reg.ReadString(RootDirectoryValue))) + '\' + AnFileName);
        if Reg.ValueExists(cIBValueServerDir) then
          TempPathList.Add(GetCorrectPath(AnsiUpperCase(Reg.ReadString(cIBValueServerDir))) + '\' + AnFileName);
        Reg.CloseKey;
      end;

    finally
      Reg.Free;
    end;

    if FileExists(InterbasePath + '\' + AnFileName) then
      TempPathList.Add(InterbasePath + '\' + AnFileName);

    if FileExists(ExtractFilePath(FServerExePath) + AnFileName) then
      TempPathList.Add(ExtractFilePath(FServerExePath) + AnFileName);

    // НЕПОСРЕДСТВЕННО ПОИСК
    for I := 0 to TempPathList.Count - 1 do
    begin
      SingleSystemPath := TempPathList.Strings[I];
{      if POS('FIREBIRD', TempPathList.Strings[I]) > 0 then
        ShowMessage(TempPathList.Strings[I]);}
      while (Length(SingleSystemPath) > 0) and (SingleSystemPath[1] = '\') do
        Delete(SingleSystemPath, 1, 1);
      if {(FindFirst(SingleSystemPath, $2F, SR) = 0) }
        FileExists(SingleSystemPath) and
        (AnPathList.IndexOf(SingleSystemPath) = -1) and
        DirectoryExists(ExtractFileDir(SingleSystemPath)) then
      begin       
        AnPathList.Add(SingleSystemPath);
//        ShowMessage('ss. ' + SingleSystemPath);
      end;
//      FindClose(SR);
    end;

    // Если ничего не найдено добавляем системный каталог
{    if (AnPathList.Count = 0) and NotEmpty then
      AnPathList.Add(SystemPath + '\' + AnFileName);}
  finally
    TempPathList.Free;
  end;
end;

function TGedeminInstall.GetCharset: String;
begin
  Result := DefaultLc_ctype;//'WIN1251';
end;

function TGedeminInstall.GetDatabasePath: String;
const
  cDoubleSlash = '\\';
var
  SL: TStrings;
  I, AskMode: Integer;
  Reg: TRegistry;
  TempPath, LServerVersion, LErrMessage: String;
  LBreaked, SInst: Boolean;
begin
  try
    if Trim(FDatabasePath) = '' then
    begin
      { DONE -oJKL : Возможно, стоит подключаться под StartUser }
//      QueryPassword;

      AskMode := 1;

      if MessageBox(OwnerHandle, cAutoSearchDB, 'Вопрос', MB_YESNO or MB_ICONQUESTION) = IDYES then
      begin
        // Поиск по реестру удаленных машин
        SL := TStringList.Create;
        try
          // Составляем список компьютеров
          EnumNetworkComputers(nil, SL);
          SL.Insert(0, GetComputerNameString);
          FBreakProcess := False;     
          for I := 0 to SL.Count - 1 do
          begin
            {$IFDEF DEBUG}
            DoLog('');
            {$ENDIF}

            // Проверяем существование IBServer
            if TestIBServer(SL.Strings[I], cStartUser, cStartPass) then
            begin
              // Считываем версию сервера
              with TIBServerProperties.Create(nil) do
              try
                ServerName := SL.Strings[I];
                Params.Add('user_name=' + cStartUser);
                Params.Add('password=' + cStartPass);
                LoginPrompt := False;
                Protocol := GetProtocol;

                try
                  Active := True;
                  // Считываем информацию о версии сервера
                  FetchVersionInfo;
                  LServerVersion := VersionInfo.ServerVersion;
                except
                  LServerVersion := vServerName;
                end;
              finally
                Free;
              end;

              DoLog('На компьютере ' + SL.Strings[I] + ' обнаружен ' + LServerVersion);
              Reg := TRegistry.Create;
              try
                TempPath := '';
                // Ищем в реестре удаленного компьютера
                Reg.RootKey := HKEY_LOCAL_MACHINE;
                if Reg.RegistryConnect(cDoubleSlash + SL.Strings[I]) then
                begin
                  SInst := False;
                  // Проверяем инсталирован ли сервер
                  if Reg.OpenKeyReadOnly(cServerRegPath) then
                  begin
  {                  if Reg.ValueExists(cGDValueServerDBName) then
                      TempPath := Reg.ReadString(cGDValueServerDBName);}
                    // Читаем путь из старой инсталяции
                    if Reg.ValueExists(DatabaseDirectoryValue) then
                      TempPath := SL.Strings[I] + ':' + Reg.ReadString(DatabaseDirectoryValue) +
                        '\' + vMainDatabaseFile;
                    // Сервер проинсталлирован
                    SInst := True;
                    Reg.CloseKey;
                  end;
                  // Если сервер проинсталирован читаем путь из путей новой инсталляции
                  if SInst and Reg.OpenKeyReadOnly(cGedeminRoot) then
                  begin
                    if Reg.ValueExists(cGDDatabase) then
                      TempPath := Reg.ReadString(cGDDatabase);
                    Reg.CloseKey;
                  end;
                end else
                  DoLog('Не удалось подключиться к удаленному реестру');

                // Проверяем БД
                if (Trim(TempPath) <> '') and
                   TestIBDatabase(TempPath, cStartUser, cStartPass, LErrMessage) then
                  if (MessageBox(OwnerHandle, PChar(Format(cDBDetected, [TempPath])), 'Вопрос', MB_YESNO or MB_ICONQUESTION) = IDYES) then
                  begin
                    FDatabasePath := TempPath;
                    Break;
                  end else
                    AskMode := 3;
              finally
                Reg.Free;
              end;
            end;   // if TestIBServer
            if FBreakProcess then
            begin
              AskMode := 4;
              FBreakProcess := False;
              Break;
            end;
            Application.ProcessMessages;
          end;     // for I := 0 to кол-во компов
        finally
          SL.Free;
        end;
      end else
        AskMode := 0;

      TempPath := '';
      LBreaked := False;

      // Если не удалось найти БД предлагаем ввести вручную
      while (Trim(FDatabasePath) = '') and
            not TestIBDatabase(TempPath, cStartUser, cStartPass, LErrMessage) and
            not LBreaked do
      begin
        case AskMode of
          1:       // БД не обнаружена
            MessageBox(OwnerHandle, cCantDetectDB, 'Внимание!', MB_OK or MB_ICONEXCLAMATION);
          2:       // не удалось подключиться к БД  
            MessageBox(OwnerHandle, PChar(Format(cCantConnectDB, [TempPath, LErrMessage])),
             'Внимание', MB_OK or MB_ICONEXCLAMATION);
          3:       // пользователь отказался от предложенной (-ых) БД                          
            MessageBox(OwnerHandle, cNotAppropriateDB, 'Внимание', MB_OK or MB_ICONInformation);
          4:       // поиск прерван
            MessageBox(OwnerHandle, cBreakSearchDB, 'Внимание', MB_OK or MB_ICONInformation);
        end;
        with TdlgSelectDatabase.Create(nil) do
        try
          if Execute then
            TempPath := FileName
          else begin
            LBreaked := True;
            TempPath := '';
          end;
        finally
          Free;
        end;
        AskMode := 2;
      end;

      if Trim(FDatabasePath) = '' then
        FDatabasePath := TempPath;

    end;

    if Trim(FDatabasePath) = '' then
      raise Exception.Create(cExpCantDetectDB)
    else
      DoLog('Установлено подключение к базе данных: ' + FDatabasePath);

  finally
    Result := FDatabasePath;
  end;
end;

function GetLocalDatabase(AnDBPath: String): String;
var                             
  FirstPos, J: Integer;
begin
  FirstPos := 0;
  Result := AnDBPath;
  for J := 1 to Length(AnDBPath) do
    if AnDBPath[J] = ':' then
    begin
      if FirstPos = 0 then
        FirstPos := J
      else
        Result := Copy(AnDBPath, FirstPos + 1, Length(AnDBPath));
    end;
end;
(*
function TGedeminInstall.GetReportHandle: HWND;
begin
  Result := FindWindow('TUnvisibleForm', nil);
end;
 sty *)
function TGedeminInstall.GetServerHandle: HWND;
begin
  Result := FindWindow('ib_server', nil);
  if Result = 0 then
    Result := FindWindow('ibremote', nil);
  if Result = 0 then
    Result := FindWindow(nil, 'InterBase Server');
  if Result = 0 then
    Result := FindWindow(nil, 'Firebird Server');
  if Result = 0 then
    Result := FindWindow(nil, 'Yaffil Server');
  if Result = 0 then
    Result := FindWindow('YA_Server', nil);
  if Result = 0 then
    Result := FindWindow(nil, 'Yaffil SQL Server');
  if Result = 0 then
    Result := FindWindow(nil, 'Yaffil SQL Server (SS)');
end;

function TGedeminInstall.GetSourceMainPath: String;
var
  Path: String;
begin
  if Trim(FInstallRootDir) = '' then               
    Result := ExtractFilePath(Application.ExeName)
  else begin
    while True do
      if not FileExists(ExcludeTrailingBackslash(FInstallRootDir) + '\' + cUninstallFileName) then
        case MessageBox(OwnerHandle, PChar(Format('Не удается найти инсталляционные данные в папке %s. ' +
         'Возможно вы устанавливали программу с компакт диска. В этом случае вставьте компакт-диск ' +
         'в устройство чтения компакт-дисков и повторите попытку. ' +
         'Хотите указать путь вручную?', [FInstallRootDir])), 'Внимание!', MB_YESNO or MB_ICONWARNING) of
          IDYES:
            begin
              if SelectDirectory('Укажите папку', '', Path) then
              begin
                FInstallRootDir := Path;
              end;
            end;
{            with TOpenDir.Create(nil) do
            try
              if Execute(FInstallRootDir) then
                FInstallRootDir := Directory;
            finally
              Free;
            end; sty}
          IDNO:
            if not FileExists(ExcludeTrailingBackslash(FInstallRootDir) + '\' + cUninstallFileName) then
              raise Exception.Create('Не удалось найти папку с инсталляционными данными.');
        end
      else
        Break;

    Result := ExcludeTrailingBackslash(FInstallRootDir ) + '\';
  end;
end;

function TGedeminInstall.GetStartProgramDir: String;
begin
  Result := JclShell.GetSpecialFolderLocation(CSIDL_COMMON_PROGRAMS);
  if Result = '' then
    Result := JclShell.GetSpecialFolderLocation(CSIDL_PROGRAMS);
  if Result = '' then
    Result := JclShell.GetSpecialFolderLocation(CSIDL_STARTUP);
  if Result = '' then
    Result := JclShell.GetSpecialFolderLocation(CSIDL_COMMON_STARTUP);
end;

function TGedeminInstall.GetTargetFileName(
  AnInstallFile: TInstallFile): String;
begin
  Result := ParseTargetPath(AnInstallFile.FileTargetPath +
   ExtractFileName(AnInstallFile.FileName));
end;

function TGedeminInstall.GetUninstallDatFile: String;
begin
  Result := FTargetProgramPath + '\Uninstall\uninstall.dat';
end;

function TGedeminInstall.IbServerStarted(const AnUninstall: Boolean = False): Boolean;
begin
  Result := (GetServerHandle <> 0);
  if not Result then
  begin
    if not AnUninstall then
      QueryPassword;
    Result := TestIBServer(GetComputerNameString, FIBUser, FIBPassword);
  end;
end;

procedure TGedeminInstall.InstallBody;
var
  IbVer: TIBVersion;
  S: String;
  Reg: TRegistry;
  IsServer: Boolean;
  CanServerUpdate: Boolean;
  MsgBxRes: Integer;
begin
  FExistsServerType.FileCompany := ctUnknown;
  FExistsServerType.FileDate := 0;
  FExistsServerType.FileVersion := '';
  FInstallServerType.FileCompany := ctUnknown;
  FInstallServerType.FileDate := 0;
  FInstallServerType.FileVersion := '';
  FExistsClientType.FileCompany := ctUnknown;
  FExistsClientType.FileDate := 0;
  FExistsClientType.FileVersion := '';
  FInstallClientType.FileCompany := ctUnknown;
  FInstallClientType.FileDate := 0;
  FInstallClientType.FileVersion := '';

  IsServer := (imServer in FInstallModules) or (imServer in FYetInstalledModules);
  // Порядок инсталляции менять НЕЛЬЗЯ!!!
  // #1
  if imServer in FInstallModules then
  begin
    // Получаем версию IB Server
//    DoLog('Перед проверкой версии');
    IbVer := CheckIBServerVersion(S, CanServerUpdate);
    if S <> '' then
      DoLog('Обнаружен ' + S);

    // Если сервер загружен как приложение, то под NT его надо выгружать,
    // чтобы загрузить как сервис.
    PrepareInstallIBServer;
                         
    // Проверка Yaffil'a и запрос на изменение при несоответствии
    if (IbVer = ibsWrong) and
       (MessageBox(OwnerHandle, PChar(Format(cIBDetected, [S])), 'Внимание',
         MB_YESNO or MB_ICONWARNING) = IDNO) then
      raise Exception.Create(Format(cExpIBDetected, [S]));

    // Запрос на замену обнаруженного сервера при первой инсталляции
//    if ((IbVer in [ibsAbsent, ibsWrong, ibsExact]) or
    if (FYetInstalledModules = []) and
       (IbVer = ibsRight) then
    begin
      MsgBxRes := MessageBox(OwnerHandle, PChar(Format(cRightIBDetected,
        [S, vServerVersion])), 'Внимание', MB_YESNOCANCEL or MB_ICONQUESTION);
      case MsgBxRes of
        IDNO: IbVer := ibsWrong;
        IDCANCEL: raise Exception.Create(cExpInstallBreak);
      end;
    end;

    // Запрос на апгрейд установленого сервера при последующих инсталляциях
    if CanServerUpdate and
       not (FYetInstalledModules = []) and
       (MessageBox(OwnerHandle, PChar(Format(cUpdateIBServer, [S, vServerVersion])),
         'Внимание', MB_YESNO or MB_ICONQUESTION) = IDYES) then
      IbVer := ibsWrong;

    if not CanServerUpdate and
       (FYetInstalledModules <> []) and
       (IbVer = ibsRight) then
      MessageBox(OwnerHandle, PChar(Format(cRightClientCantUpdate, [S, vServerVersion])),
       'Внимание', MB_OK or MB_ICONWARNING);

    // Инсталляция сервера
    InstallIBServer(IbVer);

    // Проверка версии вставлена в качестве флага. True - если надо устанавливать
    // False - если версия подходит, надо только зашарить
(*    InstallIBServer(not ((IbVer in [ibsAbsent, ibsWrong]) or ((FYetInstalledModules = []) and
      (IbVer = ibsRight) and (MessageBox(OwnerHandle, PChar(Format(cRightIBDetected,
      [S, vServerVersion])), 'Внимание', MB_YESNO or MB_ICONQUESTION) = IDNO))));*)
    DoLog('');
    ShutDownNeeded;
  end;
  // #2
  if imServerDll in FInstallModules then
  begin
    InstallServerDll;
    DoLog('');
    ShutDownNeeded;
  end;
  // #3
  if imDatabase in FInstallModules then
  begin
    CheckServerName2;
    PrepareInstallDatabase;
    InstallDatabase;
    DoLog('');
    ShutDownNeeded;
  end;
  // #4
  if (imClient in FInstallModules) then
  begin
    IbVer := CheckIBClientVersion(S, CanServerUpdate);
    if S <> '' then
      DoLog('Обнаружен ' + S);
//    if ((IbVer in [ibsAbsent, ibsWrong, ibsExact]) or
      
// если еще ничего не установлего и версия = ibsRight и не устанавляваем серверную часть,
// то спрашиваем, а не обновить ли вам клиента?
    if (IbVer = ibsWrong) and
       not IsServer and                                     
       (MessageBox(OwnerHandle, PChar(Format(cClientDetected, [S, vServerVersion])),
         'Внимание', MB_YESNO or MB_ICONQUESTION) = IDNO) then
      raise Exception.Create(Format(cExpIBDetected, [S]));

    if (FYetInstalledModules = []) and
       (IbVer = ibsRight) and
       not IsServer and
       (MessageBox(OwnerHandle, PChar(Format(cRightClientDetected, [S, vServerVersion])),
         'Внимание', MB_YESNO or MB_ICONQUESTION) = IDNO) then
      IbVer := ibsWrong;

// Запрос на апгрейд при последующих (FYetInstalledModules <> []) инсталляциях
    if CanServerUpdate and
       not (FYetInstalledModules = []) and
       not IsServer and
       (MessageBox(OwnerHandle, PChar(Format(cUpdateIBServer, [S, FInstallClientType.FileVersion])),
         'Внимание', MB_YESNO or MB_ICONQUESTION) = IDYES) then
      IbVer := ibsWrong;

// Выдаем предупреждение о несовпадении версии клиента инсталляции и существующего
    if not CanServerUpdate and (FYetInstalledModules <> []) and
       not IsServer and (IbVer = ibsRight) then
      MessageBox(OwnerHandle, PChar(Format(cRightClientCantUpdate, [S, vServerVersion])),
        'Внимание', MB_OK or MB_ICONWARNING);

    InstallIBClient(IbVer);
(*    InstallIBClient(not ((IbVer in [ibsAbsent, ibsWrong]) or
      ((FYetInstalledModules = []) and (IbVer = ibsRight) and not IsServer and
      (MessageBox(OwnerHandle, PChar(Format(cRightClientDetected, [S, vServerVersion])),
      'Внимание', MB_YESNO or MB_ICONQUESTION) = IDNO))));*)
    DoLog('');
    ShutDownNeeded;
  end;
  // #5
  if imGedemin in FInstallModules then
  begin
    InstallGedemin;
    DoLog('');
    ShutDownNeeded;
  end;
  
(*
  // #6
  if imReport in FInstallModules then
  begin
    { TODO -oJKL : Возможно надо добавлять флаг клиента что количество шаред было корректрным. }
    InstallReportServer;
    DoLog('');
    ShutDownNeeded;
  end else
    // Если выбрали установку сервера БД, без установки сервера отчетов, то запускаем сервер отчетов
    if (imReport in FYetInstalledModules) and {???} (imServer in FInitialInstallModules) then
      {StartReportServer(ReportServerPath)} - ну ваще!!;
 sty *)

  // Получаем путь деинсталлятора
  S := ExtractFilePath(GetUninstallDatFile) + ExtractFileName(cUninstallFileName);
  CopySourceFile(cUninstallFileName, S);
  // Регистрируем деинcталятор
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(cUnInstallPath, True) then
    begin
      Reg.WriteString(cUnDisplayName, 'Программный комплекс Гедымин');
      Reg.WriteString(cUninstallString, S);
      Reg.WriteString(cInstallSource, ExcludeTrailingBackslash(GetSourceMainPath));
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
  // Регистрируем файлы деинсталятора для деинсталяции
  FUnInstallList.AddFile(cL, S, False, False);
  FUnInstallList.AddFile(cL, GetUninstallDatFile, False, False);
  FUnInstallList.AddFile(cL, GetLogFileName, False, False);
end;

procedure TGedeminInstall.InstallDatabase;
const
  cBkExt = '.bk';
var
  Reg: TRegistry;
  {LocalServerName, }LocalDatabasePath, LocalBackupPath: String;
  BackupFile, RestoreFile, TempDBPath: String;
  BackupDate: TDateTime;
  FW, SW, TW, FoW: Word;
  I, J: Integer;             
  DrvType: Integer;          // тип диска
  S: String;
  NewDatabase, isLocalDatabase: Boolean;
  SL: TStrings;

  function WordToStr(Value: Word): String;
  var
    J: Integer;
  begin
    Result := Format('%2u', [Value]);
    for J := 1 to Length(Result) do
      if Result[J] = ' ' then
        Result[J] := '0';
  end;

  function GetServerName: String;
  begin
    if FInstallType = itLocal then
      Result := ''
    else
      Result := GetComputerNameString + ':';
  end;
begin
  DoLog('Начат процесс установки базы данных');
  
{  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(cServerRegPath, True) then
    begin
      if Reg.ValueExists(cGDValueServerDBName) then
        FDatabasePath := Reg.ReadString(cGDValueServerDBName);
      if (Trim(FDatabasePath) = '') and Reg.ValueExists(cGDValueServerDB) then
        FDatabasePath := Reg.ReadString(cGDValueServerDB) + vMainDatabaseFile;
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;}

  NewDatabase := False;
                                        
  isLocalDataBase := True;
                       
//  CompareText(GetServerDatabase(FDatabasePath), GetComputerNameString) <> 0 then
                                                                                    
  DrvType := GetDriveType(PChar(ExtractFileDrive(GetLocalDatabase(FDatabasePath)) + '\'));
  if DrvType in [0, 1, DRIVE_REMOTE, DRIVE_CDROM] then
    isLocalDataBase := False;

{  if isLocalDataBase then
  begin}

  // Получаем локальный путь к базе данных
  if (Trim(FDatabasePath) = '') or not isLocalDataBase then
  begin
{    ShowMessage(FDatabasePath);
    if not isLocalDataBase then ShowMessage(IntToStr(DrvType));}
    LocalDatabasePath := FTargetProgramPath + '\Database';
    if MessageBox(OwnerHandle, PChar(Format(cDefaultDBPath, ['', LocalDatabasePath,
     vMainDatabaseFile])), 'Вопрос', MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2) = IDYES then
      // Инсталлятор запрашивает не только путь, но и наименование БД
      with TSaveDialog.Create(nil) do
      try
        FileName := vMainDatabaseFile;
        InitialDir := LocalDatabasePath;
        Title := cDBPathDlgTitle;
        while True do                  
        begin
          if Execute then
          begin
            DrvType := GetDriveType(PChar(ExtractFileDrive(FileName) + '\'));
//            ShowMessage(IntToStr(DrvType) + '. ' + ExtractFileDrive(FileName)+'\');
            case DrvType of
              0:
                MessageBox(OwnerHandle, cErrDrvType0, 'Внимание!', MB_OK or MB_ICONERROR);
              1:
                MessageBox(OwnerHandle, cErrDrvType1, 'Внимание!', MB_OK or MB_ICONERROR);
              DRIVE_REMOTE:
                MessageBox(OwnerHandle, cErrDrvTypeDRIVE_REMOTE, 'Внимание!', MB_OK or MB_ICONERROR);
              DRIVE_CDROM:
                MessageBox(OwnerHandle, cErrDrvTypeDRIVE_CDROM, 'Внимание!', MB_OK or MB_ICONERROR);
            else
              begin 
                LocalDatabasePath := ExtractFileDir(FileName);
                vMainDatabaseFile := ExtractFileName(FileName);
                Break;
              end;
            end;   //case
          end else
            Break;
        end;       // while True
      finally
        Free;
      end;
{      with TOpenDir.Create(nil) do
      try
        if Execute(LocalDatabasePath) then
          LocalDatabasePath := Directory;
      finally
        Free;
      end;}
    LocalDatabasePath := ExcludeTrailingBackslash(LocalDatabasePath) + '\' + vMainDatabaseFile;
    // Если надо устанавливаем путь подключения
//    LocalServerName := GetComputerNameString;
    FDatabasePath := GetServerName + LocalDatabasePath;
    NewDatabase := True;
  end else
  begin
    LocalDatabasePath := GetLocalDatabase(FDatabasePath);
//    LocalServerName := GetServerDatabase(FDatabasePath);
  end;

  // Устанавливаем путь архива
  if Trim(FBackupPath) = '' then
    LocalBackupPath := ExtractFilePath(LocalDatabasePath) + 'Archive\'
  else
    LocalBackupPath := FBackupPath;

{  if CompareText(LocalServerName, GetComputerNameString) <> 0 then
  begin
    S := Format('Вы не можете установить сервер на этом компьютере. ' +
     'База данных %s не относится к данному компьютеру.', [FDatabasePath]);

    if not((imGedemin in FInstallModules) and (imReport in FInstallModules)) or (MessageBox(OwnerHandle,
     PChar(S + ' Вы хотите прервать инсталяцию?'), 'Внимание', MB_YESNO or MB_ICONQUESTION) = IDYES) then
      raise Exception.Create(S)
    else
    begin
      DoLog('Процесс инсталяции базы данных был прерван. ' + S);
      Exit;
    end;
  end;}

  // Определяем имя файла архива
  BackupDate := Now;
  DecodeDate(BackupDate, FW, SW, TW);
  BackupFile := 'gd' + WordToStr(FW) + WordToStr(SW) + WordToStr(TW);
  if FileExists(LocalBackupPath + BackupFile + cBkExt) then
  begin
    DecodeTime(BackupDate, FW, SW, TW, FoW);
    BackupFile := BackupFile + WordToStr(FW) + WordToStr(SW) + WordToStr(TW) + WordToStr(FoW);
  end;

  // Присваиваем полное имя файла архива
  LocalBackupPath := LocalBackupPath + BackupFile + cBkExt;
  // Запрашиваем пароль
  QueryPassword;
  
//  ShowMessage(vDatabaseList[I].FileName + '. ' + vDatabaseList[I].FileTargetPath);
  // Копировать файлы надо после инициализации переменной FDatabasePath
  for I := 0 to vDatabaseListCount - 1 do
    InstallFile(vDatabaseList[I], False, cD);

  RestoreFile := ChangeFileExt(LocalDatabasePath, '.bk');
  CreateDirectory(ExtractFileDir(LocalDatabasePath));
  CopySourceFile(DatabaseBK, RestoreFile);
  FUnInstallList.AddFile(cD, RestoreFile, False, False);
//  if not CopyFile(DatabaseBK, RestoreFile, False) then
//    raise Exception.Create('Нельзя создать файл ' + RestoreFile);

  { TODO -oJKL :
Было бы не плохо сделать проверку на необходимость
перезагрузки и разделить на две части в данном месте }

  //if TestIBDatabase(GetComputerNameString + ':' + TempDBPath, FIBUser, FIBPassword, S) then

  SL := TStringList.Create;
  try
    with TdlgChooseDB.Create(Owner) do
    try
      if (imDatabase in FYetInstalledModules) and
         (MessageBox(OwnerHandle, 'Вы хотите выполнить процедуру обновления (upgrade) для уже установленных баз данных?',
           'Вопрос', MB_YESNO or MB_ICONQUESTION) = IDYES) then
        if UpgradeDatabase(SL, FDatabasePath, GetSourceMainPath + cMainDBListFile) then
        begin
          if SL.Count > 0 then
          begin
            for J := 0 to SL.Count - 1 do
            begin
              TempDBPath := SL[J];
              if TestIBDatabase(GetServerName + TempDBPath, FIBUser, FIBPassword, S) then
              begin
                // Если база есть производим модифай и апгрейд
                { DONE -oJKL : Копирование базы с выполнением Upgrade и Modify }
            //    DoLog('Начат процесс создания архива базы данных');
            //    DoLog('Архив базы данных успешно создан');
                if NewDatabase then
                  MessageBox(OwnerHandle, PChar('В указанной папке уже обнаружена база данных: ' +
                   TempDBPath), 'Внимание', MB_OK or MB_ICONINFORMATION);
                DoLog('Обнаружена база данных: ' + TempDBPath);
                if MessageBox(OwnerHandle, PChar(Format(cUpgradeDB, [TempDBPath])),
                 'Вопрос', MB_YESNO or MB_ICONQUESTION) = IDYES then
                begin
            //    DoLog('Начат процесс подготовки к upgrade базы данных');
            //    DoLog('База данных подготовлена к upgrade');

                  DoLog('Начат процесс обновления (upgrade) базы данных');
                  Self.UpgradeDatabase(GetComputerNameString, GetLocalDatabase(TempDBPath), RestoreFile);
            //      DoLog('Upgrade базы данных успешно завершен');
                end;
(*                if FIBFirstInstall and vSetSetting and{or} (MessageBox(OwnerHandle, 'Произвести обновление ' +
                 'настроек при первом запуске Gedemin?', 'Вопрос', MB_YESNO or MB_ICONQUESTION) = IDYES) then
                begin
                  SetSettingNeeded(TempDBPath);
                  DoLog('При первом запуске Gedemin будет произведено обновление настроек.');
                end; sty *)
              end else
              begin
                TempDBPath := GetLocalDatabase(TempDBPath);
                if FileExists(TempDBPath) then
                begin                                                       
                  I := MessageBox(OwnerHandle, PChar(Format(cRightDBDetectedWithErr, [TempDBPath, S])),
                   'Внимание', MB_YESNOCANCEL or MB_ICONWARNING);
                  case I of
                    IDYES:
                    begin
                      with TSaveDialog.Create(nil) do
                      try
                        FileName := ExtractFileName(TempDBPath);
                        InitialDir := TempDBPath;
                        Title := cDBPathDlgTitle;
                        Options := Options + [ofOverwritePrompt];
                        if Execute then
                        begin
                          TempDBPath := FileName;
                          if LocalDatabasePath = SL[J] then
                          begin
                            vMainDatabaseFile := ExtractFileName(FileName);
                            FDatabasePath := GetServerName + TempDBPath;
                          end
                        end else
                          if MessageBox(OwnerHandle, 'Вы хотите прервать установку?',
                           'Вопрос', MB_YESNO or MB_ICONWARNING) = IDYES then
                            raise Exception.Create(cExpInstallBreak);
                      finally
                        Free;
                      end;

                      Reg := TRegistry.Create;
                      try
                        Reg.RootKey := HKEY_LOCAL_MACHINE;
                        if Reg.OpenKey(cAddDatabaseRegPath, True) then
                        begin
                          Reg.DeleteValue(GetServerName + SL[J]);
                          Reg.WriteString(GetServerName + TempDBPath, '0');
                          Reg.CloseKey;
                        end;
                      finally
                        Reg.Free;
                      end;
                    end;
                    IDCANCEL: raise Exception.Create(cExpInstallBreak);
                  end;
                end;
                // Слово "копирование" будет понятнее пользователю!
                DoLog('Начат процесс копирования базы данных');
                RestoreDB(GetComputerNameString, TempDBPath, RestoreFile);
                DoLog('База данных успешно скопирована');
                // Меняем пароль для SYSDBA если IB устанавливается впервые
                ChangePassword(GetServerName + TempDBPath);
                SetNullID(GetServerName + TempDBPath);
{                SetSettingNeeded(GetServerName + TempDBPath, vSetSetting); sty }
              end;
            end;
//            ChangePassword;
          end else
            MessageBox(OwnerHandle, 'На вашем компьютере не обнаружено ни одной ' +
             'базы данных.', 'Внимание', MB_OK or MB_ICONWARNING);
        end;

      if (imDatabase in FYetInstalledModules) then
        if not TestIBDatabase(FDatabasePath, FIBUser, FIBPassword, S) then
        begin
          if MessageBox(OwnerHandle, PChar('Не удалось подключиться к текущей базе данных ' +
           FDatabasePath + '. Установить ее заново?'), 'Внимание', MB_YESNO or MB_ICONWARNING) = ID_YES then
            FYetInstalledModules := FYetInstalledModules - [imDatabase];
        end;

//      if not (imDatabase in FYetInstalledModules) then
      begin
        if (InstallDatabase(SL, FDatabasePath, GetSourceMainPath + cMainDBListFile)) or not (imDatabase in FYetInstalledModules) then
        begin
          if not (imDatabase in FYetInstalledModules) then
            SL.Add(LocalDatabasePath + '=');
          if SL.Count > 0 then
          begin
            for I := 0 to SL.Count - 1 do
            begin
              if CompareText(LocalDatabasePath, SL.Names[I]) <> 0 then
              begin
                RestoreFile := SL.Names[I];
                TempDBPath := ExtractFilePath(LocalDatabasePath) + ExtractFileName(RestoreFile);
                CopySourceFile(RestoreFile, TempDBPath);
                RestoreFile := TempDBPath;
                TempDBPath := ChangeFileExt(TempDBPath, ExtractFileExt(LocalDatabasePath));
                if MessageBox(OwnerHandle, PChar(Format(cDefaultDBPath, ['"' + SL.Values[SL.Names[I]] + '"',
                 ExtractFileDir(TempDBPath), ExtractFileName(TempDBPath)])), 'Вопрос',
                 MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2) = IDYES then
                  // Инсталлятор запрашивает не только путь но и наименование БД
                  with TSaveDialog.Create(nil) do   
                  try
                    FileName := ExtractFileName(TempDBPath);
                    InitialDir := ExtractFileDir(TempDBPath);
                    Title := cDBPathDlgTitle;
                    if Execute then
                      TempDBPath := FileName;
                  finally
                    Free;
                  end;
              end else
              begin
                RestoreFile := ChangeFileExt(LocalDatabasePath, '.bk');
                TempDBPath := SL.Names[I];
              end;

              J := IDNO;
              if FileExists(TempDBPath) then
                J := MessageBox(OwnerHandle, PChar(Format(cRightDBDetected, [TempDBPath])),
                  'Внимание', MB_YESNOCANCEL or MB_ICONWARNING);
              case J of
                IDYES, IDNO:
                begin
                  if J = IDNO then
                  begin
                    DoLog('Начат процесс копирования базы данных');
                    RestoreDB(GetComputerNameString, TempDBPath, RestoreFile);
                    FUnInstallList.AddFile(cB, TempDBPath, False, False);
                    DoLog('База данных успешно скопирована');
                  end;
                  // Меняем пароль для SYSDBA если IB устанавливается впервые
                  ChangePassword(GetServerName + TempDBPath);
{                  SetSettingNeeded(GetServerName + TempDBPath, vSetSetting); sty }
                  if J = IDNO then
                    SetNullID(GetServerName + TempDBPath);
                  // Удаляем bk файл
                  DeleteTargetFile(RestoreFile);
                  Reg := TRegistry.Create;
                  try
                    Reg.RootKey := HKEY_LOCAL_MACHINE;
                    if Reg.OpenKey(cAddDatabaseRegPath, True) then
                    begin
                      Reg.WriteString(GetServerName + TempDBPath, '0');
                      Reg.CloseKey;
                    end;
                    if (imClient in FInstallModules) or (imClient in FYetInstalledModules) then
                      if Reg.OpenKey(ClientAccessRegistrySubKey + '\' + SL.Values[SL.Names[I]], True) then
                      begin
                        Reg.WriteString(cValueDatabase, GetServerName + TempDBPath);
                        Reg.CloseKey;
                      end;
                  finally
                    Reg.Free;
                  end;
                end;
              end;
            end; 
//            ChangePassword;
          end;
{          else
            MessageBox(OwnerHandle, 'Вы уже установили все доступные базы данных.',
             'Внимание', MB_OK or MB_ICONWARNING);}
        end;
      end;
    finally
      Free;
    end;
  finally
    SL.Free;
  end;

  // Удаляем bk файл
  DeleteTargetFile(RestoreFile);

  // Прописываем ключи в реестре
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(cGedeminRoot, True) then
    begin
      Reg.WriteString(cGDDatabase, FDatabasePath);
      Reg.CloseKey;
    end;
    if Reg.OpenKey(cServerRegPath, True) then
    begin
      Reg.WriteString(DatabaseDirectoryValue, ExtractFilePath(LocalDatabasePath));
//      Reg.WriteString(cGDValueServerDBName, FDatabasePath);
      Reg.WriteString(cGDValueServerArchive, ExtractFilePath(LocalBackupPath));
      Reg.CloseKey;              
    end;
  finally
    Reg.Free;
  end;
  
//  end;   // isLocalDatabase

  FInstallModules := FInstallModules - [imDatabase];

  DoLog('Процесс установки базы данных завершен');
end;

function TGedeminInstall.InstallFile(AnInstallFile: TInstallFile;
  AnSharedNeeded: Boolean; const AnModulePrefix: Char;
  const AnOnlyShared: Boolean = False): String;
var
  SL: TStrings;
  TargetFileName: String;
  FileAlreadyExists: Boolean;
begin

  SL := TStringList.Create;
  try
    TargetFileName := GetTargetFileName(AnInstallFile);
    FileAlreadyExists := FileExists(TargetFileName);
                                              
    // Создаем список файлов
    FindFile(ExtractFileName(AnInstallFile.FileName), SL);

    // Не копируем если установлен флаг только shared и такой файл обнаружен на диске
    // Каталог в данном случае значения не имеет
    // Для IbServer и IBClient
    if not (AnOnlyShared and (SL.Count > 0)) then
    begin
      if AnsiUpperCase(ExtractFileName(AnInstallFile.FileName)) = AnsiUpperCase(vMainGedeminFile) then
        FindGedemin(SL);
      // Получаем полное имя файла куда копировать
      // Проверям корректность найденного
      if AnInstallFile.IsSearchDouble then
        CheckPathList(SL, AnInstallFile.FileName, TargetFileName);
      // Проверяем версию файла
      if CheckFileVersion(AnInstallFile, TargetFileName) then
        CopySourceFile(AnInstallFile.FileName, TargetFileName);
      // Если надо регистрируем
      if AnInstallFile.IsRegistered then
        RegisterFile(TargetFileName);
    end else
    begin
      // Ищем файл в директории которой мы должны скопировать не найден, берем
      // первый найденый
      if not FileExists(TargetFileName) then
      begin
        TargetFileName := SL[0];
        FileAlreadyExists := True;
      end;
    end;
    // Если надо, указываем совместное использование
    if AnInstallFile.IsShared and
       (FOldUnInstallList.FindFile(AnModulePrefix, TargetFileName) = -1) then
      SharedFile(TargetFileName, FileAlreadyExists);

    // Заполняем список Uninstall
    FUnInstallList.AddFile(AnModulePrefix, TargetFileName, AnInstallFile.IsShared, AnInstallFile.IsRegistered);

  finally
    Result := TargetFileName;
    SL.Free;
  end;
end;

function TGedeminInstall.InstallSelfExtract(AnInstallFile: TInstallFile): String;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  R: Cardinal;
  Ch: array[0..3] of Char;

  function IsWin9xME: Boolean;
  begin
//    Result := IsWin98 or IsWin98SE or IsWinME;
    Result := Win32Platform = VER_PLATFORM_WIN32_WINDOWS;
  end;
  function IsWinNTBased: Boolean;
  begin
    Result := Win32Platform = VER_PLATFORM_WIN32_NT;//{IsWinNT3 or IsWinNT4 or - не поддерживаем} IsWin2K or IsWinXP or IsWin2003srv;
  end;

begin

// выходим, если тип ОС или язык ОС не совпадает с требуемыми
  if ( (IsWin9xME)    and (AnInstallFile.WinVersionType = wvtWinNT) ) or
     ( (IsWinNTBased) and (AnInstallFile.WinVersionType = wvtWin9x) ) or
     ( (AnInstallFile.WinLanguageType = wltRUS) and not FWinRussian) or
     ( (AnInstallFile.WinLanguageType = wltENG) and FWinRussian) then Exit;

// проверяем версию архива
//  if CheckSelfExtractVersion(AnInstallFile.FileName) then

  {
  if FNeedSelfExtractInfo then
  begin
    if ShowSelfExtractInfo(AnInstallFile.LinkName) = mrNo then
      FNeedSelfExtractInfo := False;
  end;
  }   

  FillChar(StartupInfo, SizeOf(TStartupInfo), #0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_SHOWDEFAULT;

  {TODO: правильнее было бы предусмотреть в нашем INI файле возможность
  задания параметров командной строки }
  StrCopy(Ch, ' /Q');

  if not CreateProcess(PChar(GetSourceMainPath + AnInstallFile.FileName),
    Ch, nil, nil, False,
    NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo) then
  begin
    DoLog('Ошибка запуска ' + AnInstallFile.FileName);
    MessageBox(OwnerHandle, PChar('Установка ' + AnInstallFile.FileName + ' не была произведена!'), 'Ошибка', MB_OK or MB_ICONEXCLAMATION);
    Exit;
  end else
  begin
    DoLog('Запущен ' + AnInstallFile.FileName);
    GetExitCodeProcess(ProcessInfo.hProcess, R);

//    Application.Minimize;
    Application.ProcessMessages;

    while (R = STILL_ACTIVE) and GetExitCodeProcess(ProcessInfo.hProcess, R) do
    begin
      Sleep(100);
    end;

//    Application.Restore;
  end;

// записываем в реестр версию архива
end;

function TGedeminInstall.ShowSelfExtractInfo(const aProgramName: String): Integer;
begin
  with Tinst_dlgSelfExtrInfo.Create(nil) do
  try
    ProgramName := aProgramName;
    Result := ShowModal; 
  finally
    Free;
  end;
end;

procedure TGedeminInstall.InstallGedemin;
var
  I: Integer;
  Reg: TRegistry;
  StartProgrammDir: String;
begin
  DoLog('Начат процесс установки комплекса Гедымин');

  StartProgrammDir := ExcludeTrailingBackslash(GetStartProgramDir);

//  ShowMessage(vGedeminList[I].FileName + '. ' + vGedeminList[I].FileTargetPath);
  FRestartRequired := False;
  for I := 0 to vGedeminListCount - 1 do
    if vGedeminList[I].isSelfExtract then
      InstallSelfExtract(vGedeminList[I])
    else begin
      CreateFileLink(StartProgrammDir,
        InstallFile(vGedeminList[I], not (imGedemin in FYetInstalledModules), cG),
        vGedeminList[I].LinkName,
        vGedeminList[I].IsMakeDesktopIcon);
    end;

  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(cClientRegPath, True) then
    begin
      if not Reg.ValueExists(RootDirectoryValue) then
        Reg.WriteString(RootDirectoryValue, ParseTargetPath(cProgrammPath));
      if not Reg.ValueExists(cGDToolsDirectory) then                                
        Reg.WriteString(cGDToolsDirectory, ParseTargetPath(cProgrammPath) + '\Tools');
      if not Reg.ValueExists(Lc_ctypeValue) then
        Reg.WriteString(Lc_ctypeValue, GetCharset);
      Reg.CloseKey;
    end;
    if Reg.OpenKey(cGedeminRoot, True) then
    begin
      //!!!
      GetDatabasePath;
      if not Reg.ValueExists(cGDDatabase) then
        Reg.WriteString(cGDDatabase, GetDatabasePath);
      Reg.CloseKey;
    end;
    if Reg.OpenKey(cSettingRegPath, True) then
    begin
      Reg.WriteString(cPackageSearchPath, GetSourceMainPath + vMainSettingPath);
      Reg.CloseKey;
    end; //Yuri

(*    if Reg.OpenKey(cSettingRegPath, True) then
    begin
      Reg.WriteString(cSettingIni, GetSourceMainPath + vMainSettingPath + cMainSettingFile);
      Reg.CloseKey;
    end; sty*)
  finally
    Reg.Free;
  end;

  FInstallModules := FInstallModules - [imGedemin];

  DoLog('Процесс установки комплекса Гедымин завершен');
end;

procedure TGedeminInstall.InstallIBClient(const AnVersion: TIBVersion);
var
  I: Integer;
  Reg: TRegistry;
//  CurrentClientType: TIBCloneType;
begin
  if AnVersion <> ibsRight then
  begin
    DoLog('Начат процесс установки ' + vServerName + ' Client');

    FRestartRequired := False;
    for I := 0 to vClientListCount - 1 do
      InstallFile(vClientList[I], not (imClient in FYetInstalledModules), cC{, AnVersion = ibsExact});
  end;
   
// Yuri: CurrentClientType всегда равен ctYaffil
{  if AnVersion = ibsRight then
    CurrentClientType := FExistsClientType.FileCompany
  else
    CurrentClientType := FInstallClientType.FileCompany;}

  // Нельзя ничего писать если не совпадает версия сервера и клиента
  if (FExistsClientType.FileCompany <> FExistsServerType.FileCompany) and
     (FExistsServerType.FileCompany <> ctUnknown) then
  begin
    DoLog(cWrongClientType);
    MessageBox(OwnerHandle, PChar(cWrongClientType), 'Внимание', MB_OK or MB_ICONWARNING);
  end else
    // Также ничего не пишет если установлен сервер, т.к. по одной gds32.dll
    // нельзя определить нужный путь к каталогу Interbase
    if (imServer in FInitialInstallModules) or
       not (imServer in FYetInstalledModules) then 
    begin
{      if CurrentClientType <> ctYaffil then
      begin
        Reg := TRegistry.Create;
        try
          Reg.RootKey := HKEY_LOCAL_MACHINE;
          if Reg.OpenKey(cInterbaseRegPath, True) then
          begin
            Reg.WriteString(cIBValueVersion, vServerVersion);
            Reg.WriteString(RootDirectoryValue, ParseTargetPath(cInterbasePath));
            Reg.CloseKey;
          end;
        finally
          Reg.Free;
        end;
      end else}
      begin
        Reg := TRegistry.Create;
        try
          Reg.RootKey := HKEY_LOCAL_MACHINE;
          if Reg.OpenKey(cYaffilRegPath, True) then
          begin
            Reg.WriteString(cIBValueVersion, vServerVersion);
            Reg.WriteString(RootDirectoryValue, ParseTargetPath(cInterbasePath));
            Reg.CloseKey;
          end;
        finally
          Reg.Free;
        end;
      end;
    end;

  FInstallModules := FInstallModules - [imClient];

  if (AnVersion = ibsExact) then
    DoLog('Процесс установки ' + vServerName + ' Client завершен');
end;

procedure TGedeminInstall.InstallIBServer(const AnVersion: TIBVersion);
const
  cBin = '\BIN\';
var
  I: Integer;
  Reg: TRegistry;
  S: String;
//  CurrentServerType: TIBCloneType;
  InterbasePath1: String;
begin                                                
  if (AnVersion <> ibsRight) and (AnVersion <> ibsExact) then
  begin 
    DoLog('Начат процесс установки ' + vServerName);
    FRestartRequired := False;

    for I := 0 to vServerListCount - 1 do
    begin
      S := InstallFile(vServerList[I], not (imServer in FYetInstalledModules), cS{, AnVersion = ibsExact});
      if Pos(AnsiUpperCase(vMainServerFileName), AnsiUpperCase(vServerList[I].FileName)) > 0 then
        FServerExePath := S;
      if Pos(AnsiUpperCase(vMainGuardFileName), AnsiUpperCase(vServerList[I].FileName)) > 0 then
        FGuardExePath := S;
    end;
  end;

  S := InterbasePath1;
  if S = '' then
  begin
    I := Pos(cBin, AnsiUpperCase(FServerExePath));
    if I > 0 then
    begin
      S := ExtractFilePath(FServerExePath);
      if I = Length(S) - Length(cBin) + 1 then
        Delete(S, I, Length(cBin) - 1);
    end else
      S := ExtractFilePath(FServerExePath);
  end;

// Yuri: CurrentServerType всегда равен ctYaffil  
{  if AnVersion = ibsRight then
    CurrentServerType := FExistsServerType.FileCompany
  else
    CurrentServerType := FInstallServerType.FileCompany;}

{ TODO -oYuri : Заменить использованием утилиты instreg.exe }
{  if CurrentServerType <> ctYaffil then
  begin
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      if Reg.OpenKey(cInterbaseRegPath, True) then
      begin
        Reg.WriteString(cIBValueVersion, vServerVersion);
        Reg.WriteString(RootDirectoryValue, S);
        Reg.WriteString(cIBValueServerDir, ExtractFilePath(FServerExePath));
        Reg.WriteString(cIBValueGrdOpt, '1');
        Reg.WriteString(cIBValueDM, '-r');
        Reg.CloseKey;
      end;
    finally
      Reg.Free;
    end;
  end else}
  begin
    InterbasePath1 := ExcludeTrailingBackslash(FTargetInterbasePath);
    if Pos(' ', InterbasePath1) > 0 then
      InterbasePath1 := '"' + InterbasePath1 + '"';

    {if not FileExists(FTargetInterbasePath + 'bin\instreg.exe') or
       (ShellExecute(OwnerHandle, 'open', PChar(FTargetInterbasePath + 'bin\instreg.exe'),
         PChar('install ' + InterbasePath), PChar(FTargetInterbasePath), SW_HIDE) <= 32) then}
{ не получается через instreg.exe, потому что под Win98 неправильно прописывает путь -
 используется два слэша: "..\yaffil\\bin\" }

      begin        // если нет утилиты или не удалось запустить, то прописываем вручную
        Reg := TRegistry.Create;
        try
          Reg.RootKey := HKEY_LOCAL_MACHINE;
          if Reg.OpenKey(cYaffilRegPath, True) then
          begin
            Reg.WriteString(cIBValueVersion, vServerVersion);
            Reg.WriteString(RootDirectoryValue, S);
            Reg.WriteString(cIBValueServerDir, ExtractFilePath(FServerExePath));
            Reg.WriteString(cIBValueGrdOpt, '1');
            Reg.WriteString(cIBValueDCM, '');
            Reg.CloseKey;              
          end;
        finally
          Reg.Free;
        end;  
      end;
{    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      if Reg.OpenKey(cYaffilRegPath, True) then
      begin
        Reg.WriteString(cIBValueVersion, vServerVersion);
        Reg.WriteString(RootDirectoryValue, S);
        Reg.WriteString(cIBValueServerDir, ExtractFilePath(FServerExePath));
        Reg.WriteString(cIBValueGrdOpt, '1');
        Reg.WriteString(cIBValueDCM, '');
        Reg.CloseKey;
      end;
    finally
      Reg.Free;
    end; sty}
  end;

  if FIBFirstInstall then
  begin
    FIBUser := SysDBAUserName;
    FIBPassword := cSysPass;
  end;

  { DONE -oJKL -cStartService :
Надо решить надо ли отдельно ставить сервер отдельно клиент.
Т.е. если мы поставили обе части, а потом удаляем сервер должен ли
у нас работать клиент!!!(базы нет), и должен ли у нас работать сервер
после удаления клиента!!!(вроде должен) }
  FInstallModules := FInstallModules - [imServer{, imClient}];

  if (AnVersion = ibsExact) then
    DoLog('Процесс установки ' + vServerName + ' завершен');
end;
(*
procedure TGedeminInstall.InstallReportServer;
var
  I: Integer;
  ReportUser, ReportPass: String;
  ReportServerPath, ReportGuardPath: String;
  SL: TStrings;
  S: String;
begin
  DoLog('Начат процесс инсталляции сервера отчетов');

  // Останавливаем сервер отчетов
  StopReportServer;

  ReportServerPath := '';
  // Копируем необходимые файлы
  FRestartRequired := False;
  for I := 0 to vReportListCount - 1 do
  begin
    S := InstallFile(vReportList[I], not (imReport in FYetInstalledModules), cR);
    if Pos(AnsiUpperCase(vMainReportFile), AnsiUpperCase(vReportList[I].FileName)) > 0 then
      ReportServerPath := S;
    if Pos(AnsiUpperCase(vMainReportServiceFile), AnsiUpperCase(vReportList[I].FileName)) > 0 then
      ReportGuardPath := S;
  end;


  // Получаем путь к базе данных
  GetDatabasePath;

  if not (imReport in FYetInstalledModules) then
  begin
    { DONE -oJKL : Надо реализовать присвоение ролей для нового юзера в базе. }
    QueryPassword;

    ReportUser := 'REPORTSERVER';
    ReportPass := '';

    MessageBox(OwnerHandle, PChar(Format(cQueryReportPassword, [{vServerName}])), 'Внимание',
     MB_OK or MB_ICONINFORMATION);
    while not TestIBDatabase(FDatabasePath, ReportUser, ReportPass, S) do
      if {FIBFirstInstall and }LoginDialogEx('Сервер отчетов', ReportUser, ReportPass, False) then
      begin
        if not TestIBUser(ExtractServerName(FDatabasePath), ReportUser) then
          AddIBUser(ExtractServerName(FDatabasePath), ReportUser, ReportPass);
        SetUserRole(ReportUser);
      end else
      begin
        ReportUser := FIBUser;
        ReportPass := FIBPassword;
      end;

    // Пишем пользователя и пароль для подключения к базе данных
    SetReportServerConnectParam(ReportUser, ReportPass, FDatabasePath);
  end;

  { TODO -oJKL :
Надо реализовать проверку на необходимость перезагрузки
и разделить на две части }

  // Ищем файл после перезагрузки
  SL := TStringList.Create;
  try
    FindFile(vMainReportFile, SL);
    if (ReportServerPath = '') then
    begin
      if (SL.Count > 0) then
        ReportServerPath := SL[0]
      else
        raise Exception.Create(Format(cExpCantFindReportServer, [vMainReportFile]));
    end;
  finally
    SL.Free;
  end;

  // После перезагрузки
//  if (ParamCount > 0) and (imServer in FYetInstalledModules) and (FWindowsVersion < wvWinNT31) then
//    PrepareInstallDatabase;
  // Запускаем сервер отчетов
  StartReportServer(ReportServerPath, ReportGuardPath);

  FInstallModules := FInstallModules - [imReport];

  DoLog('Процесс инсталляции сервера отчетов завершен');
end;
sty *)

procedure TGedeminInstall.Loaded;
begin
  inherited;
end;

procedure TGedeminInstall.ModifyIBUser(const AComputerName, AUserName,
  AUserPassword: String);
begin              
  with TIBSecurityService.Create(nil) do
  try
    ServerName := AComputerName;
    Protocol := GetProtocol;
    LoginPrompt := False;
    Params.Add('user_name=' + FIBUser);
    Params.Add('password=' + FIBPassword);
    Active := True;
    try
      UserName := AUserName;
      Password := AUserPassword;
      try
        ModifyUser;
      except
        on E: Exception do
          raise Exception.Create(Format(cExpPassChange, [E.Message]));
      end;
    finally
      Active := False;
    end;
  finally
    Free;
  end;
end;

function TGedeminInstall.ParseTargetPath(AnPath: String): String;
begin
  Result := AnPath;
  // {SYSTEM}
  if Pos(cSystemPath, Result) = 1 then
  begin
    Delete(Result, 1, Length(cSystemPath));
    Insert(SystemDirectory, Result, 1);
  end;
  // {INTERBASE}
  if Pos(cInterbasePath, Result) = 1 then
  begin
    Delete(Result, 1, Length(cInterbasePath));
    if FTargetInterbasePath <> '' then
      Insert(FTargetInterbasePath, Result, 1)
    else
      Insert(ExtractFilePath(FTargetProgramPath) + vServerName + '\', Result, 1);
  end;
  // {PROGRAMM}
  if Pos(cProgrammPath, Result) = 1 then
  begin
    Delete(Result, 1, Length(cProgrammPath));
    Insert(FTargetProgramPath, Result, 1);
  end;
  // {DATABASE}
  if Pos(cDatabasePath, Result) = 1 then
  begin                         
    Delete(Result, 1, Length(cDatabasePath));
    Insert(ExtractFilePath(GetLocalDatabase(FDatabasePath)), Result, 1);
  end;
end;

procedure TGedeminInstall.PrepareInstallDatabase;
const
  cWaitTime = 0.000115; // ~10s
var
  CurTime: TDateTime;
  IsWin2000: Boolean;
begin
  DoLog(Format('Запуск сервера базы данных', [{vServerName}]));
  // Запускаем сервер
  if not IbServerStarted then
  begin
    if FWindowsVersion < wvWinNT31 then
    begin 
{      if Trim(FGuardExePath) = '' then // - Yuri}
        StartAppServer(vServerName, FServerExePath + ' -a', IBServerStarted)
{      else
        StartAppServer(vServerName, FGuardExePath + ' -a', IBServerStarted) //- Yuri}
    end else  
    begin
      IsWin2000 := FWindowsVersion > wvWinNT4;
      if (Trim(FGuardExePath) = '') or IsWin2000 then
        StartServiceServer(vIBServiceName, vIBServiceDisplayName, FServerExePath, SERVICE_AUTO_START, IsWin2000)
      else
      begin
        StartServiceServer(vIBServiceName, vIBServiceDisplayName, FServerExePath, SERVICE_DEMAND_START, False);
        StartServiceServer(vIBGuardServiceName, vIBGuardServiceDisplayName, FGuardExePath, SERVICE_AUTO_START, False);
      end;
    end;
  end;

  QueryPassword;                          
  // Ждем подключения
  CurTime := Now;
  while not TestIBServer(GetComputerNameString, FIBUser, FIBPassword) and
        (Now - CurTime < cWaitTime) do
    Sleep(50);

  if TestIBServer(GetComputerNameString, FIBUser, FIBPassword) then
  begin
    DoLog(Format('Сервер базы данных запущен', [{vServerName}]));
    // Проверяем существование user STARTUSER
    DoLog('Проверка пользователей');
    if not TestIBUser(GetComputerNameString, cStartUser) then
    begin
      DoLog('Добавлен пользователь ' + cStartUser);
      AddIBUser(GetComputerNameString, cStartUser, cStartPass);
    end;
  end else
    raise Exception.Create(cExpCantAttachToServer);
end;

procedure TGedeminInstall.PrepareInstallIBServer(const AnUninstall: Boolean = False);
var
  LastSH, CurSH: HWND;
begin
  if IbServerStarted(AnUninstall) then
  begin
    DoLog(Format('Останов работы сервера базы данных', [{vServerName}]));
    // Останавливаем сервер отчетов
{    StopReportServer; sty } 
    // Выгружаем сервисы
    if FWindowsVersion >= wvWinNT31 then
      StopServiceServer(@cServiceServerNames, cServiceServerCount);

    // Выгружаем все приложения IBGuard
    LastSH := 0;
    CurSH := GetGuardHandle;
    while CurSH <> LastSH do
    begin
      StopAppServer(CurSH, @cAppServerNames, cAppServerCount);
      LastSH := CurSH;
      CurSH := GetGuardHandle;
    end;

    // Выгружаем все приложения IBServer
    LastSH := 0;
    CurSH := GetServerHandle;
    while CurSH <> LastSH do
    begin
      StopAppServer(CurSH, @cAppServerNames, cAppServerCount);
      LastSH := CurSH;
      CurSH := GetServerHandle;
    end;

    if IbServerStarted(AnUninstall) then
      raise Exception.Create(cExpCantUnloadServer);
      
    DoLog(Format('Сервер базы данных остановлен', [{vServerName}]));
  end;
end;

procedure TGedeminInstall.QueryPassword;
var
  Reg: TRegistry;
  LQueryPassword: Boolean;
begin
  if not FPasswordQuered then
  begin
    LQueryPassword := True;

    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      if Reg.OpenKeyReadOnly(cGedeminRoot) then
      begin
        if Reg.ValueExists(cGDValueQueryPass) then
          LQueryPassword := Reg.ReadInteger(cGDValueQueryPass) <> 0;
        Reg.CloseKey;
      end;
    finally
      Reg.Free;
    end;

    if FIBFirstInstall or not LQueryPassword then
    begin
      FIBUser := SysDBAUserName;
      FIBPassword := cSysPass;
      if InstallType = itLocal then
      begin
        Reg := TRegistry.Create;
        try
          Reg.RootKey := HKEY_LOCAL_MACHINE;
          if Reg.OpenKey(cGedeminRoot, True) then
          begin
            Reg.WriteInteger(cGDValueQueryPass, 0);
            Reg.CloseKey;
          end;
        finally
          Reg.Free;
        end;
      end;
    end else
    begin
      // Запрашиваем пароль для подключения к базе данных
      MessageBox(OwnerHandle, PChar(Format(cQueryPassword, [])),
        'Внимание', MB_OK or MB_ICONINFORMATION);
      if not LoginDialog('Введите пароль', FIBUser, FIBPassword) then
        raise Exception.Create(cExpInstallBreak);
    end;
          
    FPasswordQuered := True;
  end;
end;

procedure TGedeminInstall.ReadInstalledModules;
var
  Reg: TRegistry;
  SL: TStrings;
  ParamStr: String;
  J: Integer;
begin
  // Удаляем автозагрузку инсталяции из реестра. (Имитация RunOnce)
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;

    if Reg.OpenKey(cUnInstallPath, True) then
    begin
      FInstallRootDir := Reg.ReadString(cUninstallString);
      if CompareText(FInstallRootDir, Application.ExeName) = 0 then
        FInstallRootDir := Reg.ReadString(cInstallSource)
      else
        FInstallRootDir := '';
      Reg.CloseKey;
    end;

    if Reg.OpenKey(cRunRegPath, True) then
    //if Reg.OpenKey(cRunOnceRegPath, True) then
    begin
      if Reg.ValueExists(cGedeminInstall) then
      begin
        ParamStr := GetFileParams(Reg.ReadString(cGedeminInstall));
        if (ParamCount = 0) and (ParamStr <> '') then
        begin                                                                      
          if (MessageBox(OwnerHandle, 'Программа установки потребовала перезагрузку. ' +
            'Если вы выполнили перезагрузку компьютера и программа установки не запустилась автоматически, ' +
            'нажмите кнопку "Да" для продолжения установки. В противном случае нажмите кнопку "Нет" и ' +
            'выполните перезагрузку компьютера.'#13#10 + 'Продолжить установку?',
            'Вопрос', MB_YESNO or MB_ICONQUESTION) = IDYES) then 
          begin
            RunSelfCopy(ParamStr);
          end;
          Application.Terminate;
          Exit;
        end;
        Reg.DeleteValue(cGedeminInstall);
      end;
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;

  { TODO -oJKL : Возможно считывание надо сделать из реестра в виде строки 5 компонент }
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKeyReadOnly(cGedeminRoot) then
    begin
      if Reg.ValueExists(cGDValueRootPath) then
        ProgramPath := JclFileUtils.PathGetLongName(Reg.ReadString(cGDValueRootPath));
      if Reg.ValueExists(cGDDatabase) then
        FDatabasePath := Reg.ReadString(cGDDatabase);
      Reg.CloseKey;
    end;

    if Reg.OpenKeyReadOnly(cServerRegPath) then
    begin
      FYetInstalledModules := cServerFlags + [imClient];
      {if Reg.ValueExists(cGDValueServerDBName) then
        FDatabasePath := Reg.ReadString(cGDValueServerDBName);}
      if (Trim(FDatabasePath) = '') and
         Reg.ValueExists(DatabaseDirectoryValue) then
        FDatabasePath := GetComputerNameString + ':' + Reg.ReadString(DatabaseDirectoryValue) +
          vMainDatabaseFile;
      if Reg.ValueExists(cGDValueServerArchive) then
        FBackupPath := Reg.ReadString(cGDValueServerArchive);
      Reg.CloseKey;
    end;

    if Reg.OpenKeyReadOnly(cClientRegPath) then
    begin
      FYetInstalledModules := FYetInstalledModules + cClientFlags;
      if Reg.ValueExists(RootDirectoryValue) then
        ProgramPath := JclFileUtils.PathGetLongName(Reg.ReadString(RootDirectoryValue));
      if (Trim(FDatabasePath) = '') and
         Reg.ValueExists(cGDDatabase) then
        FDatabasePath := Reg.ReadString(cGDDatabase);
      Reg.CloseKey;
    end;

    // Yaffil
    if Reg.OpenKeyReadOnly(cYaffilRegPath) then
    begin
      FIBFirstInstall := False;           
      if Reg.ValueExists(RootDirectoryValue) then
        InterbasePath := JclFileUtils.PathGetLongName(Reg.ReadString(RootDirectoryValue));
      Reg.CloseKey;  
    end; 

{    // Firebird
    if (InterbasePath = '') and
       Reg.OpenKeyReadOnly(cFirebirdRegPath) then
    begin
      FIBFirstInstall := False;
      if Reg.ValueExists(RootDirectoryValue) then
        InterbasePath := JclFileUtils.PathGetLongName(Reg.ReadString(RootDirectoryValue));
      Reg.CloseKey;
    end;

    // Interbase
    if (InterbasePath = '') and
       Reg.OpenKeyReadOnly(cInterbaseRegPath) then
    begin
      FIBFirstInstall := False;
      if Reg.ValueExists(RootDirectoryValue) then
        InterbasePath := JclFileUtils.PathGetLongName(Reg.ReadString(RootDirectoryValue));
      Reg.CloseKey;                         
    end;

    // Interbase 2
    if (InterbasePath = '') and
       Reg.OpenKeyReadOnly(cInterbaseRegPath2) then
    begin
      FIBFirstInstall := False;
      if Reg.ValueExists(RootDirectoryValue) then
        InterbasePath := JclFileUtils.PathGetLongName(Reg.ReadString(RootDirectoryValue));
      Reg.CloseKey;
    end;}
                        
    SL := TStringList.Create;
    try
      SL.Clear;
      for J := 0 to cServerExeCount - 1 do
        // Поиск файла сервера
        FindFile(cServerExeNames[J], SL, False);
      FServerExePath := GetFileFromList(SL, InterbasePath);
      SL.Clear;
      for J := 0 to cGuardExeCount - 1 do
        // Поиск файла сервера
        FindFile(cGuardExeNames[J], SL, False);
      FGuardExePath := GetFileFromList(SL, InterbasePath);
    finally
      SL.Free;                                          
    end;

    //FIBFirstInstall := not ((InterbasePath <> '') or (FServerExePath <> ''));
    FIBFirstInstall := (FServerExePath = '') or (InterbasePath = '');

{    if Reg.OpenKeyReadOnly(cReportRegPath) then
    begin
      FYetInstalledModules := FYetInstalledModules + cReportFlags;
      Reg.CloseKey;
    end; sty}
    if not DirectoryExists(ProgramPath) then
      FYetInstalledModules := [];
  finally
    Reg.Free;
  end;

  if FileExists(GetUninstallDatFile) and
     ( (FYetInstalledModules <> []) or (ParamCount > 0) ) then
    FOldUnInstallList.LoadFromFile(GetUninstallDatFile);
end;

procedure TGedeminInstall.RegisterFile(AnFilePath: String);
var
  Handle: HINST;
  DllRegister: TDllRegister;

  function LoadTypeLibrary: ITypeLib;
  begin
    OleCheck(LoadTypeLib(PWideChar(WideString(AnFilePath)), Result));
  end;

  procedure RegisterTypeLibrary;
  var
    Name: WideString;
    HelpPath: WideString;
  begin
    try
      Name := AnFilePath;
      HelpPath := ExtractFilePath(AnFilePath);
      OleCheck(RegisterTypeLib(LoadTypeLibrary, PWideChar(Name), PWideChar(HelpPath)));
      DoLog(Format('Файл %s успешно зарегистрирован', [AnFilePath]));
    except
      on E: Exception do
        DoLog(Format('При попытке регистрации %s возникла ошибка: %s', [AnFilePath, E.Message]));
    end;
  end;
begin
  DoLog(Format('Файл %s регистрируется в реестре', [AnFilePath]));

  if (AnsiUpperCase(ExtractFileExt(AnFilePath)) = '.DLL') or
   (AnsiUpperCase(ExtractFileExt(AnFilePath)) = '.OCX') then
  begin
    Handle := LoadLibrary(PChar(AnFilePath));
    if Handle <> 0 then
    try
      @DllRegister := GetProcAddress(Handle, 'DllRegisterServer');
      if @DllRegister <> nil then
      begin
        if DllRegister <> S_OK then
          raise Exception.Create(Format(cExpCantRegFile, [AnFilePath]));
        DoLog(Format('Файл %s успешно зарегистрирован', [AnFilePath]));
      end else
        DoLog(Format('Не удалось найти точку входа DllRegisterServer для %s', [AnFilePath]));
    finally
      FreeLibrary(Handle);
    end;
  end else
    if AnsiUpperCase(ExtractFileExt(AnFilePath)) = '.EXE' then
      RegisterTypeLibrary
    else
      DoLog(Format('Файл %s не может быть зарегистрирован.', [AnFilePath]));
end;

procedure TGedeminInstall.ReplaceFile(AnFileSource, AnFileTarget: String);

var
  S, BatName: String;
begin
  // Создаем директорию, в которую будем копировать файл
  CreateDirectory(ExtractFileDir(AnFileTarget));
                                       
  // Пробуем скопировать файл
  if not CopyFile(PChar(AnFileSource), PChar(AnFileTarget), False) then
  begin
    // Не удалось скопировать файл

    // Если исходного файла нет, генерим ошибку
    if not FileExists(AnFileSource) then
      raise Exception.Create(Format(cExpInstallationFailed, [AnFileSource]));

{  faReadOnly  = $00000001;
  faHidden    = $00000002;
  faSysFile   = $00000004;
  faVolumeID  = $00000008;
  faDirectory = $00000010;
  faArchive   = $00000020;
  faAnyFile   = $0000003F;}

    // Если такой файл уже существует ...
    if FileExists(AnFileTarget) then
    begin
      // ... проверяем его атрибуты ...
//      if (FileGetAttr(AnFileTarget) and (faReadOnly or faHidden)) <> 0 then
      if ((FileGetAttr(AnFileTarget) and faReadOnly) = faReadOnly) {or
         (FileGetAttr(AnFileTarget) and faHidden) = faHidden) }then
      begin
        // ... и если надо снимаем ReadOnly ...              
//        if FileSetAttr(AnFileTarget, FileGetAttr(AnFileTarget) and $3C) = 0 then
        if FileSetAttr(AnFileTarget, FileGetAttr(AnFileTarget) and not faReadOnly) = 0 then
        begin
          // ... пытаемся скопировать еще раз.
          if CopyFile(PChar(AnFileSource), PChar(AnFileTarget), False) then
            Exit;
        end else
          raise Exception.Create(Format(cExpCantSetFileAttr, [AnFileTarget]));
      end;

      // Если файл не удалось скопировать возможно он используется
        { TODO 3 -oJKL -cMoveFile :
        Надо точно проверять используется он или нет
        и в зависимости от этого генерить ошибку }
      if True then
      begin
        // Создаем копию файла
        S := ExtractFilePath(AnFileTarget) + NewPrefix + ExtractFileName(AnFileTarget);

        if not CopyFile(PChar(AnFileSource), PChar(S), False) then
          raise Exception.Create(Format(cExpCantReplaceFile, [S, AnFileTarget]))
        else
          if (FileGetAttr(AnFileTarget) and faReadOnly) <> 0 then
          begin
            // ... и если надо снимаем ReadOnly ...
            if FileSetAttr(S, FileGetAttr(S) and not faReadOnly) <> 0 then
              raise Exception.Create(Format(cExpCantSetFileAttr, [S]));
          end;
        
//        RenameFile(S, AnFileTarget);
        if FWindowsVersion > wvWinME then
        begin
        { DONE -oJKL -cMoveFile : Не работает замена после перезагрузки }
          // Если NT и выше используем MoveFileEx
          if not MoveFileEx(PChar(S), PChar(AnFileTarget),
                   MOVEFILE_DELAY_UNTIL_REBOOT + MOVEFILE_REPLACE_EXISTING) then
            raise Exception.Create(GetLastErrorMessage);
        end else   // wvWinME и ниже
        begin
          // Иначе через реестр и функции системы
          // Создаем бат файл
          BatName := GetWindowsDirectoryString + '\WININIT.INI';
          WritePrivateProfileString('Rename',
            PChar(JclFileUtils.PathGetShortName(AnFileTarget)),
            PChar(JclFileUtils.PathGetShortName(S)), PChar(BatName));
        end;  
        FRestartRequired := True;
      end else
        raise Exception.Create(Format(cExpCantReplaceFile2, [AnFileTarget]));
    end;
  end else                                                       
    if (FileGetAttr(AnFileTarget) and faReadOnly) <> 0 then
    begin                                                            
      // ... и если надо снимаем ReadOnly ...
      if FileSetAttr(AnFileTarget, FileGetAttr(AnFileTarget) and not faReadOnly) <> 0 then
        raise Exception.Create(Format(cExpCantSetFileAttr, [AnFileTarget]));
    end;
end;

procedure TGedeminInstall.ReplaceFileFromStream(AnStreamSource: TStream;
  AnFileTarget: String);
begin
{ TODO -oJKL -cSaveFileStream : Сохранение файла из потока вместе с
оригинальной версией и датой }
end;
(*
function TGedeminInstall.ReportServerStarted(const AnUninstall: Boolean = False): Boolean;
begin
  Result := (GetReportHandle <> 0);
end;
*)
procedure TGedeminInstall.RestoreDB(AnServerName, AnDatabaseTarget, AnSourceBk: String);
var
  LocBKFileName: String;
begin

  case FArchiveType of
    artFile: LocBKFileName := AnSourceBk;
    { TODO : Для других типов хранилища: создать копию BK файла и присвоить путь }
//    artZip:;
//    artRes:;
  else
    raise Exception.Create(cExpWrongArchiveType);
  end;

  with TIBRestoreService.Create(nil) do
  try
    ServerName := AnServerName;
    Params.Clear;
    Params.Add('user_name=' + FIBUser);
    Params.Add('password=' + FIBPassword);
    Options := Options + [Replace];
    LoginPrompt := False;
    BackupFile.Add(LocBKFileName);
    DatabaseName.Add(AnDatabaseTarget);
    PageSize := 8192;
    PageBuffers := GetPageBuffers(PageSize);
    Protocol := GetProtocol;
    Active := True;
    try
      ServiceStart;
      while not EOF do
      begin
        //Application.ProcessMessages;
        //AddMessage(GetNextLine);
        GetNextLine;
      end;
    finally
      Active := False;
    end;
  finally
    Free;
  end;
end;

procedure TGedeminInstall.SaveUninstall;
begin
  FOldUnInstallList.MergeList(FUnInstallList);
  CreateDirectory(ExtractFileDir(GetUninstallDatFile));
  FOldUnInstallList.SaveToFile(GetUninstallDatFile);
end;

procedure TGedeminInstall.SetTargetInterbasePath(const Value: String);
begin
  FTargetInterbasePath := Trim(Value);
  if FTargetInterbasePath = ''  then Exit;

  if (FTargetInterbasePath[Length(FTargetInterbasePath)] = '/') then
    Delete(FTargetInterbasePath, Length(FTargetInterbasePath), 1)
  else
    FTargetInterbasePath := ExcludeTrailingBackSlash(FTargetInterbasePath);

{  if (FTargetInterbasePath <> '') and
     (FTargetInterbasePath[Length(FTargetInterbasePath)] = '/') then
    FTargetInterbasePath[Length(FTargetInterbasePath)] := '\';}

{  if (FTargetInterbasePath <> '') and
     (FTargetInterbasePath[Length(FTargetInterbasePath)] <> '\') then
    FTargetInterbasePath := FTargetInterbasePath + '\';}
end;

procedure TGedeminInstall.SetTargetProgramPath(const Value: String);
begin
  FTargetProgramPath := Trim(Value);

  if (FTargetProgramPath = '') then Exit;

{  if (FTargetProgramPath[Length(FTargetProgramPath)] <> '\') then
    Delete(FTargetProgramPath, Length(FTargetProgramPath), 1)
  else}
    FTargetProgramPath := ExcludeTrailingBackSlash(FTargetProgramPath);
end;

function TGedeminInstall.GetCorrectPath(const aPath: String): String;
begin
  Result := ExcludeTrailingBackSlash(aPath);
  while Pos('\\', Result) > 0 do
    Delete(Result, Pos('\\', Result), 1);
end;

procedure TGedeminInstall.SharedFile(AnFilePath: String; AnIsFileExists: Boolean);
var
  Reg: TRegistry;
  I, J: Integer;
begin
  DoLog(Format('Файл %s регистрируется для совместного использования', [AnFilePath]));

  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(cSharedDLLRegPath, True) then
    begin
      if Reg.ValueExists(AnFilePath) then
      begin
        case Reg.GetDataType(AnFilePath) of
          rdInteger: I := Reg.ReadInteger(AnFilePath);
          rdBinary: Reg.ReadBinaryData(AnFilePath, I, SizeOf(I));
        else
          raise Exception.Create(cExpWrongDataType);
        end;
        Inc(I);
      end else
      begin
        I := 1;
        // NT ..., ... не пишет shared для нее и при деинсталяции удаляется
        // потом не загружается
        // Если файл уже существует а shared для него не был создан,
        // то увеличиваем его счетчик на 1, чтобы при деинсталяции не удалить
        if AnIsFileExists then
          Inc(I);
        // Старая проверка, в теории можно удалить, но проверять лениво
        if I = 1 then
          for J := 0 to cWinCount - 1 do
            if Pos(cWinFiles[J], AnsiUpperCase(AnFilePath)) > 0 then
              Inc(I);
      end;
      Reg.WriteInteger(AnFilePath, I);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TGedeminInstall.ShutDownNeeded;
var
  S: String;
  Reg: TRegistry;
//  TP: _TOKEN_PRIVILEGES;
//  TokHndl, PrHndl: Cardinal;
//  BuffLen: Cardinal;
begin
  if not FRestartRequired or Application.Terminated then
    Exit;

  // Создаем строку запуска
  S := Application.ExeName;
  if imServer in FInstallModules then
    S := S + ' ' + cimServer;
  if imServerDll in FInstallModules then
    S := S + ' ' + cimServerDll;
  if imGedemin in FInstallModules then
    S := S + ' ' + cimGedemin;
{  if imReport in FInstallModules then
    S := S + ' ' + cimReport; sty}
  if imClient in FInstallModules then
    S := S + ' ' + cimClient;
  if imDatabase in FInstallModules then
    S := S + ' ' + cimDatabase;
  if FIBFirstInstall then
    S := S + ' ' + cimFirstIB;
  if FPasswordQuered then
  begin
    S := S + ' ' + cimUser + ' ' + FIBUser;
    S := S + ' ' + cimPassword + ' ' + FIBPassword;
  end;
  S := S + ' ' + cimIBPath + ' "' + FServerExePath + '"';
//  S := S + ' ' + cimGDPath + ' "' + FTargetProgramPath + '"';
  // Сохраняем ее в реестре
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(cRunRegPath, True) then
    //if Reg.OpenKey(cRunOnceRegPath, True) then
    begin
      Reg.WriteString(cGedeminInstall, S);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;

  SaveUninstall;
  
  if MessageBox(OwnerHandle, cShutDownSystem, 'Вопрос', MB_ICONQUESTION or MB_YESNO) = IDNO then
  begin
    MessageBox(OwnerHandle, cShutDownNeeded, 'Внимание', MB_OK or MB_ICONINFORMATION);
    Application.Terminate;
    raise EAbort.Create('Для продолжения установки необходимо выполнить перезагрузку системы.');
  end;

  // Перегружаем компьютер
  DoShutDown;
(*
  try
    // Если NT и выше устанавливаем права для процесса на перезагрузку
    if FWindowsVersion > wvWinME then
    begin
      PrHndl := GetCurrentProcess;
      if PrHndl <> 0 then
      try
        if OpenProcessToken(PrHndl, TOKEN_ADJUST_PRIVILEGES, TokHndl) then
        begin
          TP.PrivilegeCount := 1;
          TP.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
          if LookupPrivilegeValue(nil, 'SeShutdownPrivilege', TP.Privileges[0].Luid) then
          begin
            if not AdjustTokenPrivileges(TokHndl, False, TP, 0, nil, BuffLen) then
              raise EAbort.Create(GetLastErrorMessage);
          end else
            raise EAbort.Create(GetLastErrorMessage);
        end else
          raise EAbort.Create(GetLastErrorMessage);
      finally
        CloseHandle(PrHndl);
      end else
        raise EAbort.Create(GetLastErrorMessage);
    end;

    // Перегружаем систему
    if not ExitWindowsEx(EWX_REBOOT{ + EWX_FORCE}, 0) then
      raise EAbort.Create(GetLastErrorMessage);
  except
    on E: Exception do
    begin
      S := Format('Не удалось перегрузить систему (%s). ' +
       'Для продолжения установки проделайте эту операцию вручную.', [E.Message]);
      DoLog(S);
      MessageBox(OwnerHandle, PChar(S), 'Внимание', MB_OK or MB_ICONINFORMATION);
      Application.Terminate;
      raise EAbort.Create(S);
    end;
  end;
*)

  Application.Terminate;
  raise EAbort.Create('Идет перезагрузка системы...');
end;
                                          
procedure TGedeminInstall.DoShutDown;
var
  TP: _TOKEN_PRIVILEGES;
  TokHndl, PrHndl: Cardinal;
  BuffLen: Cardinal;
  S: String;
begin 
  // Перегружаем компьютер
  try
    // Если NT и выше устанавливаем права для процесса на перезагрузку
    if FWindowsVersion > wvWinME then
    begin
      PrHndl := GetCurrentProcess;
      if PrHndl <> 0 then
      try
        if OpenProcessToken(PrHndl, TOKEN_ADJUST_PRIVILEGES, TokHndl) then
        begin
          TP.PrivilegeCount := 1;
          TP.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
          if LookupPrivilegeValue(nil, 'SeShutdownPrivilege', TP.Privileges[0].Luid) then
          begin
            if not AdjustTokenPrivileges(TokHndl, False, TP, 0, nil, BuffLen) then
              raise EAbort.Create(GetLastErrorMessage);
          end else
            raise EAbort.Create(GetLastErrorMessage);
        end else
          raise EAbort.Create(GetLastErrorMessage);
      finally
        CloseHandle(PrHndl);
      end else
        raise EAbort.Create(GetLastErrorMessage);
    end;

    // Перегружаем систему
    if not ExitWindowsEx(EWX_REBOOT{ + EWX_FORCE}, 0) then
      raise EAbort.Create(GetLastErrorMessage);
  except
    on E: Exception do
    begin
      S := Format('Не удалось перегрузить систему (%s). ' +
       'Для продолжения установки проделайте эту операцию вручную.', [E.Message]);
      DoLog(S);
      MessageBox(OwnerHandle, PChar(S), 'Внимание', MB_OK or MB_ICONINFORMATION);
      Application.Terminate;
      raise EAbort.Create(S);
    end;
  end;
end;

procedure TGedeminInstall.StartAppServer(AnServiceName, AnServiceFile: String;
  const AnProc: TGetStarted);
const
  cMinus = '-';
  cSlash = '/';
  cWaitTime = 0.000115; // ~10s
var
  I: Integer;
  Reg: TRegistry;
  Params: String;
  CurTime: TDateTime;
begin
  { DONE -oJKL : Запуск сервера как приложения }
  // Прописываем запуск сервера в реестре
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(cRunRegPath, True) then
    begin
      { DONE -oJKL : Надо guard запускать }
      if not Reg.ValueExists(AnServiceName) then
        Reg.WriteString(AnServiceName, AnServiceFile);
      {$IFDEF DEBUG}
      ShowMessage(AnServiceFile);
      {$ENDIF} 
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;

  if not AnProc then
  begin
    Params := '';
    I := Pos(cMinus, AnServiceFile);
    if I > 0 then
    begin
      Params := Copy(AnServiceFile, I, MAXINT);
      AnServiceFile := Trim(Copy(AnServiceFile, 1, I - 1));
    end;
    I := Pos(cSlash, AnServiceFile);
    if I > 0 then
    begin
      Params := Params + Copy(AnServiceFile, I, MAXINT);
      AnServiceFile := Trim(Copy(AnServiceFile, 1, I - 1));
    end;
    // Запускаем сервер
//    ShowMessage(AnServiceFile + '. ' + Params + '. ');
//    ShowMessage(AnServiceFile + '. ' + Params);
    if ShellExecute(0, 'open', PChar(AnServiceFile), PChar(Params), '', 0) <= 32 then
      raise Exception.Create(Format(cExpStartError, [AnServiceName]));
    // Ждем максимум 10 сек выгрузки окна
    CurTime := Now;
    while not AnProc and (Now - CurTime < cWaitTime) do
      Sleep(50);
  end;
end;

procedure TGedeminInstall.StartInstall;
var
  Reg: TRegistry;

  function ParamsPresent: Boolean;
  var
    I, J: Integer;
    SL: TStrings;
  begin
    Result := False;
    { DONE -oJKL -cStartInstall : Проверка ключей }
    I := 1;
    while I <= ParamCount do
    begin
      if ParamStr(I) = cimServer then
      begin
        FInstallModules := FInstallModules + [imServer];
        Result := True;
      end else
      if ParamStr(I) = cimServerDll then
      begin
        FInstallModules := FInstallModules + [imServerDll];
        Result := True;
      end else
      if ParamStr(I) = cimClient then
      begin
        FInstallModules := FInstallModules + [imClient];
        Result := True;
      end else
      if ParamStr(I) = cimDatabase then
      begin
        FInstallModules := FInstallModules + [imDatabase];
        Result := True;
      end else
      if ParamStr(I) = cimGedemin then
      begin
        FInstallModules := FInstallModules + [imGedemin];
        Result := True;
      end else
{      if ParamStr(I) = cimReport then
      begin
        FInstallModules := FInstallModules + [imReport];
        Result := True;
      end else sty}
      if ParamStr(I) = cimIBPath then
      begin
        Inc(I);
        FServerExePath := ParamStr(I);
        FTargetInterbasePath := ExtractIBPathFromFileName(ParamStr(I));
        SL := TStringList.Create;
        try
          for J := 0 to cGuardExeCount - 1 do
            FindFile(cGuardExeNames[J], SL, False);
          FGuardExePath := GetFileFromList(SL, InterbasePath);
        finally
          SL.Free;
        end;
      end else
      if ParamStr(I) = cimUser then
      begin
        Inc(I);
        FIBUser := ParamStr(I);
        FPasswordQuered := True;
      end else
      if ParamStr(I) = cimPassword then
      begin
        Inc(I);
        FIBPassword := ParamStr(I);
        FPasswordQuered := True;
      end else
{      if ParamStr(I) = cimGDPath then
      begin
        Inc(I);
        FTargetProgramPath := ParamStr(I);
      end else}
      if ParamStr(I) = cimFirstIB then
        FIBFirstInstall := True
      else
         raise Exception.Create(cExpWrongInstallParam);
      Inc(I);
    end;
  end;
begin
  try
    if not ParamsPresent then
    begin
      // Проверка прав пользователя
      if not (CheckUserRight or
         (MessageBox(OwnerHandle,
           cAdminInstall,
           'Внимание',
           MB_ICONWARNING or MB_YESNO or MB_TASKMODAL) = IDNO) ) then
        raise Exception.Create(cExpAdminInstall);
      // Запрос типа установки
      DoQueryInstallType;
      DoQueryInstallModules;
      // Проверка TCI/IP
      { TODO -oJKL -cStartInstall : Проверить будет ли локально IB работать без WinSock2 }
      if (FInstallType = itMulti) and vCheckTCPIP and not CheckTCPIP then
      begin
        if MessageBox(OwnerHandle,
          'Не удается определить протокол TCP/IP. Возможна некорректная работа программы.'#13#10 +
          'Продолжить установку?',
          'Внимание',
          MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDNO then
        begin
          raise Exception.Create(cExpWinSock);
        end;  
      end;
    end;

    FInitialInstallModules := FInstallModules;

    // Пишем путь куда будет инсталлироваться сервер
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      if Reg.OpenKey(cGedeminRoot, True) then
      begin
        if not Reg.ValueExists(cGDValueRootPath) then
          Reg.WriteString(cGDValueRootPath, FTargetProgramPath);
        Reg.CloseKey;
      end;
    finally
      Reg.Free;
    end;

    // Приступаем непосредственно к инсталляции
    InstallBody;

    DoFinish(True, 'Установка успешно завершена');
  except
    on E: EAbort do
    begin
      DoFinish(False, E.Message);
      Exit;
    end;
    on E: Exception do
    begin
//      MessageBox(OwnerHandle, PChar('В процессе инсталляции возникли следующие проблемы: ' +
//       E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
      DoLog('');
      DoFinish(False, 'В процессе установки возникла ОШИБКА: ' + E.Message);
      DoLog('');
{ TODO -oYuri : Почему нельзя на Win98, а если нельзя - почему можно на WinME. }
      if (FYetInstalledModules = []) and   
         ( {(FWindowsVersion < wvWin98) or }(FWindowsVersion > wvWinMe{98SE}) ) and
         (MessageBox(OwnerHandle, 'Хотите откатить инсталляцию?',
           'Вопрос', MB_YESNO or MB_ICONQUESTION) = IDYES) then
      begin
        FOldUnInstallList.MergeList(FUnInstallList);
        DoLog('Будет произведен откат инсталляции');
        StartUninstall;                   
      end;
    end;
  end;
end;
(*
procedure TGedeminInstall.StartReportServer(const AnReportServerPath, AnReportGuardPath: String);
var
  Dependencies: String;
  IsWin2000: Boolean;
begin
  if FWindowsVersion < wvWinNT31 then
    StartAppServer(cReportServiceName, AnReportServerPath + ' /A', ReportServerStarted)
  else
  begin
    IsWin2000 := FWindowsVersion > wvWinNT4;
    if (imServer in FYetInstalledModules) or (imServer in FInitialInstallModules) then
    begin
      Dependencies := vIBServiceName + #0;
      StartServiceServer(cReportServiceName, cReportDisplayName, AnReportGuardPath,
      SERVICE_AUTO_START, IsWin2000, @Dependencies[1]);
    end else
      StartServiceServer(cReportServiceName, cReportDisplayName, AnReportGuardPath, SERVICE_AUTO_START, IsWin2000);
  end;
end;
 sty *)
procedure TGedeminInstall.StartServiceServer(const AnServiceName, AnDisplayName,
  AnServiceFile: String;  const AnStartType: Cardinal;
  const AnSetFailureActions: Boolean; const AnDependencies: PChar = nil);
const
  cWaitTime = 0.000115; // ~10s
var
  HSCM: Cardinal;
  HSvr: Cardinal;
  SS: _SERVICE_STATUS;
  QSC: PQueryServiceConfigA;
  BytesNeeded: Cardinal;
  ServiceArg: PChar;
  CurTime: TDateTime;
  DllHnd: HINST;
  ChangeServiceConfig2: TChangeServiceConfig2;
  QueryServiceConfig2: TQueryServiceConfig2;
  PInfo: PSERVICE_FAILURE_ACTIONS;
  ArrayCreated: Boolean;
{  InterbasePath: String;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  R: Cardinal; }
begin
  // Открываем менеджер
//  DoLog('Попытка открыть SCManager');
  HSCM := OpenSCManager(nil, nil, GENERIC_READ + SC_MANAGER_CREATE_SERVICE);
//  DoLog('SCManager открыт');
  if HSCM <> 0 then
  begin
    // Открываем сервис
    HSvr := OpenService(HSCM, PChar(AnServiceName), SERVICE_START +
     SERVICE_QUERY_STATUS + SERVICE_CHANGE_CONFIG + SERVICE_QUERY_CONFIG);
    if HSvr <> 0 then
    begin
      // Получаем размер
      QueryServiceConfig(HSvr, nil, 0, BytesNeeded);
      GetMem(QSC, BytesNeeded);
      try
        // Получаем текущий статус
        if not QueryServiceConfig(HSvr, QSC, BytesNeeded, BytesNeeded) then
          raise Exception.Create(Format(cExpQueryServiceConfig, [GetLastErrorMessage]));
        if (QSC.dwStartType <> AnStartType) or
          (AnsiUpperCase(AnServiceFile) <> AnsiUpperCase(QSC.lpBinaryPathName)) then
        begin
          { DONE -oJKL -cStartService : Прописывать путь к серверу. Т.к. он может поменяться в теории }
          { DONE -oJKL : Надо guard запускать }
          if not ChangeServiceConfig(HSvr, QSC.dwServiceType, AnStartType, QSC.dwErrorControl,
           PChar(AnServiceFile), QSC.lpLoadOrderGroup, nil, AnDependencies,
           QSC.lpServiceStartName, nil, QSC.lpDisplayName) then
            raise Exception.Create(Format(cExpChangeServiceConfig, [GetLastErrorMessage]));
        end;
      finally
        FreeMem(QSC);
      end;
    end else
      // Если сервис не создан, то ...
      if (GetLastError = ERROR_SERVICE_DOES_NOT_EXIST) then
      begin 
(*                        
 не логично все это

      InterbasePath := ExcludeTrailingBackslash(FTargetInterbasePath);
        if Pos(' ', InterbasePath) > 0 then
          InterbasePath := '"' + InterbasePath + '"';

        FillChar(StartupInfo, SizeOf(TStartupInfo), #0);
        StartupInfo.cb := SizeOf(TStartupInfo);
        StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
        StartupInfo.wShowWindow := SW_HIDE;

        if not CreateProcess(PChar(FTargetInterbasePath + 'bin\instsvc.exe'), PChar(' install ' + InterbasePath + ' -auto '),
          nil, nil, False, NORMAL_PRIORITY_CLASS, nil, PChar(FTargetInterbasePath), StartupInfo, ProcessInfo) then
        begin
          MessageBox(OwnerHandle, PChar('Установка ' + FTargetInterbasePath + 'bin\instsvc.exe' + 'не была произведена!'), 'Ошибка', MB_OK or MB_ICONERROR);
        end else
        begin
          GetExitCodeProcess(ProcessInfo.hProcess, R);
          Application.ProcessMessages;
          while (R = STILL_ACTIVE) and GetExitCodeProcess(ProcessInfo.hProcess, R) do
          begin 
            Sleep(100);
          end;
        end;
        Sleep(500);          // на всякий случай. Yuri
        HSvr := OpenService(HSCM, PChar(AnServiceName), SERVICE_START +
          SERVICE_QUERY_STATUS + SERVICE_CHANGE_CONFIG + SERVICE_QUERY_CONFIG);*)

        // Пытаемся зарегистрировать сервис
        HSvr := CreateService(HSCM, PChar(AnServiceName), PChar(AnDisplayName),
         SERVICE_START + SERVICE_QUERY_STATUS + SERVICE_CHANGE_CONFIG +
         SERVICE_QUERY_CONFIG, SERVICE_WIN32_OWN_PROCESS or SERVICE_INTERACTIVE_PROCESS,
         AnStartType, SERVICE_ERROR_IGNORE, PChar(AnServiceFile), nil, nil,
         AnDependencies, nil, nil);
        
        if HSvr = 0 then
          raise Exception.Create(Format(cExpCreateService, [GetLastErrorMessage]));
      end else
        raise Exception.Create(Format(cExpOpenService, [GetLastErrorMessage]));

    Assert(HSvr <> 0, 'Ошибка в логике процедуры');

    // Устанавливаем действие при сбое для Win2000 и выше
    if AnSetFailureActions then
    begin
      DllHnd := LoadLibrary('advapi32.dll');
      if DllHnd <> 0 then
      try
        // Вызываем функции динамически, чтобы под всеми MSW работало.
        @ChangeServiceConfig2 := GetProcAddress(DllHnd, 'ChangeServiceConfig2A');
        if @ChangeServiceConfig2 <> nil then
        begin
          @QueryServiceConfig2 := GetProcAddress(DllHnd, 'QueryServiceConfig2A');
          if @QueryServiceConfig2 <> nil then
          begin
            QueryServiceConfig2(HSvr, SERVICE_CONFIG_FAILURE_ACTIONS, nil, 0, @BytesNeeded);
            if BytesNeeded < SizeOf(TSERVICE_FAILURE_ACTIONS) then
              BytesNeeded := SizeOf(TSERVICE_FAILURE_ACTIONS);
            GetMem(PInfo, BytesNeeded);
            try
              QueryServiceConfig2(HSvr, SERVICE_CONFIG_FAILURE_ACTIONS, PInfo, BytesNeeded, @BytesNeeded);
              PInfo^.cActions := 3;
              PInfo^.dwResetPeriod := 86400;
              ArrayCreated := False;
              if not Assigned(PInfo^.lpsaActions) then
              begin
                GetMem(PInfo^.lpsaActions, SizeOf(TSCAction) * 3);
                ArrayCreated := True;
              end;
              try
                PSCActionArray(PInfo^.lpsaActions)[0]._Type := SC_ACTION_RESTART;
                PSCActionArray(PInfo^.lpsaActions)[0].Delay := 0;
                PSCActionArray(PInfo^.lpsaActions)[1]._Type := SC_ACTION_RESTART;
                PSCActionArray(PInfo^.lpsaActions)[1].Delay := 0;
                PSCActionArray(PInfo^.lpsaActions)[2]._Type := SC_ACTION_RESTART;
                PSCActionArray(PInfo^.lpsaActions)[2].Delay := 0;
                if not ChangeServiceConfig2(HSvr, SERVICE_CONFIG_FAILURE_ACTIONS, PInfo) then
                  DoLog(Format('Произошла ошибка при попытке установить действия для ' +
                   'обработки ошибок для службы %s: %s', [AnServiceName, GetLastErrorMessage]))
                else
                  DoLog('Установлены действия при возникновении ошибок для службы ' + AnServiceName);
              finally
                if ArrayCreated then
                  FreeMem(PInfo^.lpsaActions);
              end;
            finally
              FreeMem(PInfo);
            end;
          end else
            DoLog('Не удалось найти точку входа QueryServiceConfig2A для advapi32.dll');
        end else
          DoLog('Не удалось найти точку входа ChangeServiceConfig2A для advapi32.dll');
      finally
        FreeLibrary(DllHnd);
      end else
        DoLog('Не удалось загрузить advapi32.dll');
    end;

    // Проверяем запущен ли он ...
    if not QueryServiceStatus(HSvr, SS) then
      raise Exception.Create(Format(cExpQueryServiceStatus, [GetLastErrorMessage]));

    // Если не запущен, то запускаем его
    if not (SS.dwCurrentState = SERVICE_RUNNING) and (AnStartType = SERVICE_AUTO_START) then
    begin
      // Запускаем сервис
      if StartService(HSvr, 0, ServiceArg) then
      begin
        CurTime := Now;
        repeat
          Sleep(50);
          if not QueryServiceStatus(HSvr, SS) then
            raise Exception.Create(Format(cExpQueryServiceStatus, [GetLastErrorMessage]));
        until (SS.dwCurrentState <> SERVICE_START_PENDING) or (Now - CurTime > cWaitTime);//= SERVICE_RUNNING)
        if SS.dwCurrentState <> SERVICE_RUNNING then
          raise Exception.Create(Format(cExpCantStartService, [AnServiceName]));
      end else
        raise Exception.Create(Format(cExpStartService, [GetLastErrorMessage]));
    end;
    // Закрываем service
    CloseServiceHandle(HSvr);

    // Закрываем менеджер
    CloseServiceHandle(HSCM);
  end else
    raise Exception.Create(cExpCantConnectServiceManager);
end;

procedure TGedeminInstall.StartUninstall;
var
  I: Integer;
  Reg: TRegistry;
  SL: TStrings;
  LAskDatabaseDelete: Integer;
begin
  DoLog('Начат процесс удаления');

  FRestartRequired := False;
  try
    if not (CheckUserRight or (MessageBox(OwnerHandle, cAdminUninstall, 'Внимание',
     MB_ICONWARNING or MB_YESNO) = IDNO)) then
      raise Exception.Create(cExpAdminUninstall);
{    StopReportServer; sty }
    PrepareInstallIBServer(True);
    with TfrmProgress.Create(Owner) do
    try
      ProgressBar.Max := FOldUnInstallList.Count;
      ProgressBar.Position := 0;//FOldUnInstallList.Count;
      ProgressBar.Min := 0;
      Visible := True;
      LAskDatabaseDelete := -1;
      for I := 0 to FOldUnInstallList.Count - 1 do
      begin                             
        if (FOldUnInstallList.FileModule[I] = cB) and
           (LAskDatabaseDelete = -1) then
          LAskDatabaseDelete := MessageBox(OwnerHandle, 'Вы хотите удалить все установленные базы данных?',
           'Внимание', MB_YESNO or MB_ICONWARNING or MB_DEFBUTTON2);

        if (FOldUnInstallList.FileModule[I] <> cB) or (LAskDatabaseDelete = IDYES) then
          UninstallFile(FOldUnInstallList.FileName[I], FOldUnInstallList.IsShared[I],
           FOldUnInstallList.IsRegister[I]);
        ProgressBar.Position := ProgressBar.Position + 1;//- 1;
        Application.ProcessMessages;  
      end;  
    finally
      Free;
    end;

{    // Удаляем сервис сервера отчетов
    if FWindowsVersion >= wvWinNT31 then
      RemoveService(cReportServiceName); sty}

    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;

      if Reg.KeyExists(cGedeminRoot) then
        Reg.DeleteKey(cGedeminRoot);

      if Reg.KeyExists(cUnInstallPath) then
        Reg.DeleteKey(cUnInstallPath);

      SL := TStringList.Create;
      try
        FindFile(vMainServerFileName, SL);
        if SL.Count = 0 then
        begin
{          if Reg.OpenKey(cInterbaseRegPath, True) then
          begin
            if Reg.ValueExists(cIBValueDM) then
              Reg.DeleteValue(cIBValueDM);
            if Reg.ValueExists(cIBValueServerDir) then
              Reg.DeleteValue(cIBValueServerDir);
            if Reg.ValueExists(cIBValueGrdOpt) then
              Reg.DeleteValue(cIBValueGrdOpt);
            Reg.CloseKey;
            if FWindowsVersion >= wvWinNT31 then
              RemoveService(vIBServiceName);
          end;
          if Reg.OpenKey(cInterbaseRegPath2, True) then
          begin
            if Reg.ValueExists(cIBValueDM) then
              Reg.DeleteValue(cIBValueDM);
            if Reg.ValueExists(cIBValueServerDir) then
              Reg.DeleteValue(cIBValueServerDir);
            if Reg.ValueExists(cIBValueGrdOpt) then
              Reg.DeleteValue(cIBValueGrdOpt);
            Reg.CloseKey;
            if FWindowsVersion >= wvWinNT31 then
              RemoveService(vIBServiceName);
          end;
          if Reg.OpenKey(cFirebirdRegPath, True) then
          begin
            if Reg.ValueExists(cIBValueDM) then
              Reg.DeleteValue(cIBValueDM);
            if Reg.ValueExists(cIBValueServerDir) then
              Reg.DeleteValue(cIBValueServerDir);
            if Reg.ValueExists(cIBValueGrdOpt) then
              Reg.DeleteValue(cIBValueGrdOpt);
            Reg.CloseKey;
            if FWindowsVersion >= wvWinNT31 then
              RemoveService(vIBServiceName);
          end;}
          if Reg.OpenKey(cYaffilRegPath, True) then
          begin
            if Reg.ValueExists(cIBValueDM) then
              Reg.DeleteValue(cIBValueDM);
            if Reg.ValueExists(cIBValueServerDir) then
              Reg.DeleteValue(cIBValueServerDir);
            if Reg.ValueExists(cIBValueGrdOpt) then
              Reg.DeleteValue(cIBValueGrdOpt);
            Reg.CloseKey;
            if FWindowsVersion >= wvWinNT31 then
              RemoveService(vIBServiceName);
          end;
        end;

        FindFile(vMainClientFileName, SL);
//        RemoveDelayed(SL);
        if SL.Count = 0 then
        begin
{          if Reg.KeyExists(ExtractFileDir(cInterbaseRegPath)) then
            Reg.DeleteKey(ExtractFileDir(cInterbaseRegPath));
          if Reg.KeyExists(ExtractFileDir(cInterbaseRegPath2)) then
            Reg.DeleteKey(ExtractFileDir(cInterbaseRegPath2));
          if Reg.KeyExists(ExtractFileDir(cFirebirdRegPath)) then
            Reg.DeleteKey(ExtractFileDir(cFirebirdRegPath));}
          if Reg.KeyExists(ExtractFileDir(cYaffilRegPath)) then
            Reg.DeleteKey(ExtractFileDir(cYaffilRegPath));
        end {else
          ShowMessage(SL[0])};

      finally
        SL.Free;
      end;
    finally
      Reg.Free;
    end;
    DoFinish(True, 'Удаление успешно завершено');
  except
    on E: Exception do
    begin
      DoFinish(False, E.Message);
      MessageBox(OwnerHandle, PChar(Format(cUninstallMistake, [E.Message])),
       'Ошибка', MB_OK or MB_ICONERROR);
    end;
  end;

  if FRestartRequired and
     (MessageBox(OwnerHandle, cRemoveUninstall, 'Вопрос', MB_YESNO or MB_ICONQUESTION ) = IDYES) then
    DoShutDown;
//    MessageBox(OwnerHandle, cRemoveUninstall, 'Внимание', MB_OK or MB_ICONINFORMATION);

  {$IFDEF DEBUG}
  try                                          
    FLogList.SaveToFile(FTargetProgramPath + '\uninstall.log');
  except
  end;
  {$ENDIF}
//  ShutDownNeeded;
end;

procedure TGedeminInstall.DoBreak;
begin
  FBreakProcess := True; 
end;

procedure TGedeminInstall.StopAppServer(const AnServerHandle: HWND;
  const AnAppNames: PStringArray; const AnCount: Integer);
const
  cWaitTime = 0.000115; // ~10s
var
  IBHndl: HWND;
  PrHndl, ExitCode: Cardinal;
  PrID: Cardinal;
  CurTime: TDateTime;
  Reg: TRegistry;
  SL: TStrings;
  I, J: Integer;
  S: String;
begin
  try
    { DONE -oJKL : Возможно надо сделать выгрузку всех окон }
    IBHndl := AnServerHandle;
    // Проверяем загружен ли сервер
    if IBHndl <> 0 then
    begin
      // Получаем ID процесса
      GetWindowThreadProcessId(IBHndl, @PrID);
      if PrID <> 0 then
      begin
        // Получаем handle процесса
        PrHndl := OpenProcess(PROCESS_TERMINATE + PROCESS_QUERY_INFORMATION, False, PrID);
        if PrHndl <> 0 then
        begin
          // Получаем код выхода
          if GetExitCodeProcess(PrHndl, ExitCode) then
          begin
            // Завершаем процесс
            if TerminateProcess(PrHndl, ExitCode) then
            begin
              // Ждем максимум 10 сек выгрузки окна
              CurTime := Now;
              // Теоретически может быть другое окно -> GetServerHandle = IBHndl
              while (GetServerHandle = IBHndl) and (Now - CurTime < cWaitTime) do
                Sleep(50);
            end else   
              raise Exception.Create(GetLastErrorMessage);
          end else
            raise Exception.Create(GetLastErrorMessage);
          // Закрываем handle
          CloseHandle(PrHndl);
        end;
      end;
    end;
    // Удаляем из реестра все ссылки для запуска IB
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      if Reg.OpenKey(cRunRegPath, True) then
      begin
        SL := TStringList.Create;
        try
          Reg.GetValueNames(SL);
          for I := 0 to SL.Count - 1 do
            if Reg.GetDataType(SL[I]) in [rdString, rdExpandString] then
            begin
              S := Reg.ReadString(SL[I]);
              for J := 0 to AnCount - 1 do
                if Pos(AnAppNames[J], AnsiUpperCase(S)) > 0 then
                begin
                  Reg.DeleteValue(SL[I]);
                  Break;
                end;
            end;
        finally
          SL.Free;
        end;
        Reg.CloseKey;
      end;
    finally
      Reg.Free;
    end;

  except
    on E: Exception do
      DoLog('Ошибка: ' + E.Message);
  end;
end;
(*
procedure TGedeminInstall.StopReportServer;
begin
  if FWindowsVersion >= wvWinNT31 then
    StopServiceServer(@cServiceReportNames, cServiceReportCount);
  StopAppServer(GetReportHandle, @cAppReportNames, cAppReportCount)
end;
 sty *)
 
procedure TGedeminInstall.StopServiceServer(const AnServiceNames: PStringArray;
  const AnCount: Integer);
const
  cWaitTime = 0.000115; // ~10s
var
  HSCM: Cardinal;
  HSvr: Cardinal;
  I: Integer;
  SS: _SERVICE_STATUS;
  QSC: PQueryServiceConfigA;
  BytesNeeded: Cardinal;
  CurTime: TDateTime;
begin
  try
    // Открываем менеджер
    HSCM := OpenSCManager(nil, nil, GENERIC_READ);
    if HSCM <> 0 then
    begin
      for I := 0 to AnCount - 1 do
      begin
        // Открываем сервис
        HSvr := OpenService(HSCM, PChar(AnServiceNames[I]), SERVICE_STOP +
         SERVICE_QUERY_STATUS + SERVICE_CHANGE_CONFIG + SERVICE_QUERY_CONFIG);
        if HSvr <> 0 then
        begin
          // Получаем размер
          QueryServiceConfig(HSvr, nil, 0, BytesNeeded);
          GetMem(QSC, BytesNeeded);
          try
            // Получаем текущий статус
            if not QueryServiceConfig(HSvr, QSC, BytesNeeded, BytesNeeded) then
              raise Exception.Create(GetLastErrorMessage);
            if QSC.dwStartType <> SERVICE_DEMAND_START then
            begin
              if not ChangeServiceConfig(HSvr, QSC.dwServiceType, SERVICE_DEMAND_START, QSC.dwErrorControl,
               nil, nil, nil, nil, nil, nil, QSC.lpDisplayName) then
                raise Exception.Create(GetLastErrorMessage);
            end;
          finally
            FreeMem(QSC);
          end;
                                
          // Останавливаем сервис
          CurTime := Now;
          if ControlService(HSvr, SERVICE_CONTROL_STOP, SS) then
            repeat
              Sleep(50);
              if not QueryServiceStatus(HSvr, SS) then
                raise Exception.Create(GetLastErrorMessage);
            until (SS.dwCurrentState = SERVICE_STOPPED) or (Now - CurTime > cWaitTime)
          ;//else
            //raise Exception.Create(GetLastErrorMessage);
          Sleep(100);
          // Закрываем handle
          CloseServiceHandle(HSvr);
        end;
      end;
      // Закрываем менеджер
      CloseServiceHandle(HSCM);
    end else
      raise Exception.Create(cExpCantConnectServiceManager);
  except
    on E: Exception do
      DoLog('Ошибка: ' + E.Message);
  end;
end;

function TGedeminInstall.TestIBDatabase(const ADatabaseName, AUserName,
  APassword: String; var AnErrorMessage: String): Boolean;
begin
  Result := False;
  AnErrorMessage := '';

  {$IFDEF DEBUG}
  DoLog(AUserName + '/' + APassword);
  {$ENDIF}

  with TIBDatabase.Create(nil) do
  try
    DatabaseName := ADatabaseName;
    Params.Add('user_name=' + AUserName);
    Params.Add('password=' + APassword);
    Params.Add('lc_ctype=WIN1251');
    LoginPrompt := False;
    try
      Connected := True;
    except
      on E: Exception do
      begin
        AnErrorMessage := E.Message;
        exit;
      end;
    end;
    Result := True;
  finally
    Free;
  end;
end;

function TGedeminInstall.TestIBServer(const AComputerName, AUserName,
  APassword: String): Boolean;
var
  IBServerProperties: TIBServerProperties;
begin
  Result := False;
  try
    {$IFDEF DEBUG}
    DoLog(AUserName + '/' + APassword + '/' + AComputerName);
    {$ENDIF}

    IBServerProperties := TIBServerProperties.Create(nil);
    try
      IBServerProperties.ServerName := AComputerName;
      IBServerProperties.Params.Add('user_name=' + AUserName);
      IBServerProperties.Params.Add('password=' + APassword);
      IBServerProperties.LoginPrompt := False;
      IBServerProperties.Protocol := GetProtocol;

      try
        IBServerProperties.Active := True;
      except
        on E: EIBError do
        begin
          //SetLastError(E.IBErrorCode);
          FLocalErrorCode := E.IBErrorCode;
          {$IFDEF DEBUG}
          DoLog('Проверка сервера: ' + E.Message);
          {$ENDIF}
          exit;
        end;
      else
        exit;
      end;

      Result := True;

    finally
      if IBServerProperties.Active then
        IBServerProperties.Active := False;
      IBServerProperties.Free;
    end;
  except
    Result := False;
  end;
end;

function TGedeminInstall.TestIBUser(const AComputerName, AUserName: String): Boolean;
var
  IBSecurityService: TIBSecurityService;
begin
  try
    IBSecurityService := TIBSecurityService.Create(nil);
    try
      IBSecurityService.ServerName := AComputerName;
      IBSecurityService.Protocol := GetProtocol;
      IBSecurityService.Params.Add('user_name=' + FIBUser);
      IBSecurityService.Params.Add('password=' + FIBPassword);
      IBSecurityService.LoginPrompt := False;
      IBSecurityService.Active := True;
      try
        IBSecurityService.DisplayUser(AUserName);
        while IBSecurityService.IsServiceRunning do Sleep(5);
        Result := (IBSecurityService.UserInfoCount = 1) and
                  (IBSecurityService.UserInfo[0].UserName = AUserName);
      finally     
        IBSecurityService.Active := False;
      end;
    finally
      IBSecurityservice.Free;
    end;
  except
    on E: Exception do
    begin
      DoLog('Ошибка: ' + E.Message);
      Result := False;
    end;
  end;
end;

procedure TGedeminInstall.UninstallFile(AnFileName: String;
  AnIsShared, AnIsRegister: Boolean);
begin
  { DONE -oJKL : Надо сделать проверку необходимости регистрации }
  try
    if AnIsShared then
      UnSharedFile(AnFileName, AnIsRegister)
    else
    begin
      if AnIsRegister then
        UnRegisterFile(AnFileName);
      DeleteTargetFile(AnFileName);
    end;
  except
    on E: Exception do
      DoLog('Ошибка: ' + E.Message);
  end;
end;

procedure TGedeminInstall.UninstallFile(AnInstallFile: TInstallFile);
var
  TargetFileName: String;
begin
  try
    // Получаем полное имя файла куда копировать
    TargetFileName := GetTargetFileName(AnInstallFile);
    DoLog('Удаляется файл ' + TargetFileName);
    if AnInstallFile.IsShared then
      UnSharedFile(TargetFileName, AnInstallFile.IsRegistered)
    else
    begin
      if AnInstallFile.IsRegistered then
        UnRegisterFile(TargetFileName);
      DeleteTargetFile(TargetFileName);
    end;
  except
    On E: Exception do
      DoLog('Ошибка: ' + E.Message);
  end;
end;

procedure TGedeminInstall.UnRegisterFile(AnFilePath: String);
var
  Handle: HINST;
  DllRegister: TDllRegister;

  function LoadTypeLibrary: ITypeLib;
  begin
    OleCheck(LoadTypeLib(PWideChar(WideString(AnFilePath)), Result));
  end;

  procedure UnregisterTypeLibrary;
  type
    TUnregisterProc = function(const GUID: TGUID; VerMajor, VerMinor: Word;
      LCID: TLCID; SysKind: TSysKind): HResult stdcall;
  var
    Handle: THandle;
    UnregisterProc: TUnregisterProc;
    LibAttr: PTLibAttr;
    TypeLib: ITypeLib;
  begin
    try
      Handle := GetModuleHandle('OLEAUT32.DLL');
      if Handle <> 0 then
      begin
        @UnregisterProc := GetProcAddress(Handle, 'UnRegisterTypeLib');
        if @UnregisterProc <> nil then
        begin
          TypeLib := LoadTypeLibrary;
          OleCheck(TypeLib.GetLibAttr(LibAttr));
          {$IFDEF INSTALL}
          with LibAttr^ do
            UnregisterProc(guid, wMajorVerNum, wMinorVerNum, lcid, syskind);
          {$ENDIF}
          TypeLib.ReleaseTLibAttr(LibAttr);
          DoLog(Format('Регистрация для файла %s успешно закончена', [AnFilePath]));
        end;
      end;
    except
      on E: Exception do
        DoLog(Format('При попытке удаления регистрации %s возникла ошибка: %s', [AnFilePath, E.Message]));
    end;
  end;
{  procedure UnRegisterTypeLibrary;
  var
    Name: WideString;
    HelpPath: WideString;
  begin
    try
      Name := AnFilePath;
      HelpPath := ExtractFilePath(AnFilePath);
      OleCheck(ComServ.UnregisterTypeLibrary(LoadTypeLibrary));
      DoLog(Format('Файл %s успешно зарегистрирован', [AnFilePath]));
    except
      on E: Exception do
        DoLog(Format('При попытке регистрации %s возникла ошибка: %s', [AnFilePath, E.Message]));
    end;
  end;}                    
begin 
  DoLog(Format('Удаляется регистрация из реестра для файла %s ', [AnFilePath]));
  if (AnsiUpperCase(ExtractFileExt(AnFilePath)) = '.DLL') or
   (AnsiUpperCase(ExtractFileExt(AnFilePath)) = '.OCX') then
  begin
    Handle := LoadLibrary(PChar(AnFilePath));
    if Handle <> 0 then
    try
      @DllRegister := GetProcAddress(Handle, 'DllUnregisterServer');
      if @DllRegister <> nil then
      begin
        if DllRegister <> S_OK then
          raise Exception.Create(Format(cExpCantUnregFile, [AnFilePath]));
        DoLog(Format('Регистрация для файла %s успешно удалена', [AnFilePath]));
      end else
        DoLog(Format('Не удалось найти точку входа DllUnregisterServer для %s', [AnFilePath]));
    finally
      FreeLibrary(Handle);
    end;
  end else
    if AnsiUpperCase(ExtractFileExt(AnFilePath)) = '.EXE' then
      UnRegisterTypeLibrary
    else
      DoLog(Format('Файл %s не может быть зарегистрирован.', [AnFilePath]));
end;

procedure TGedeminInstall.UnSharedFile(AnFilePath: String; AnRegisterFile: Boolean;
  AnDeleteFile: Boolean = True);
var
  Reg: TRegistry;
  I: Integer;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(cSharedDLLRegPath, True) then
    begin
      if Reg.ValueExists(AnFilePath) then
      begin
        I := Reg.ReadInteger(AnFilePath);
        Dec(I);
        // Если файл больше ни кем не используется, удаляем его
        if (I = 0) then
        begin
          if AnDeleteFile then
          begin
            if AnRegisterFile then
              UnRegisterFile(AnFilePath);
            DeleteTargetFile(AnFilePath);
          end;
          // Галимая 98 винда валится если ключ удалить !!!
          if FWindowsVersion >= wvWinNT31 then
            Reg.DeleteValue(AnFilePath)
          else
            Reg.WriteInteger(AnFilePath, I);
        end else
          Reg.WriteInteger(AnFilePath, I);
      end else
        DeleteTargetFile(AnFilePath);
    end;
  finally
    Reg.Free;
  end;
end;

procedure TGedeminInstall.UpgradeDatabase(const AnServerName,
  AnDatabaseFile, AnEtalonFile: String);
begin
  { DONE -oJKL : Модифай, Апгрейд }
  with TboDBUpgrade.Create(nil) do
  try
    UpgradeLog := FInstallLog;
    ServerName := AnServerName;
    BackupFile := AnEtalonFile;
    SourceDatabase := AnDatabaseFile;
    UserName := FIBUser;
    Password := FIBPassword;
    ExecuteUpgrade;
  finally
    Free;
  end;
end;

procedure TGedeminInstall.RenameInstFile(AnFileSource, AnFileTarget: String);
var
  WinInitFile: String;
  ShortPath: String;
begin
  if not MoveFileEx(PChar(AnFileSource), PChar(AnFileTarget), MOVEFILE_REPLACE_EXISTING) then
  begin
    if FWindowsVersion > wvWinME then
    begin
      // Если NT и выше используем MoveFileEx
      if not MoveFileEx(PChar(AnFileSource), PChar(AnFileTarget),
        MOVEFILE_DELAY_UNTIL_REBOOT + MOVEFILE_REPLACE_EXISTING) then
        raise Exception.Create(GetLastErrorMessage);
    end else
    begin
      // Иначе через реестр и функции системы
      // Создаем бат файл
      WinInitFile := GetWindowsDirectoryString + '\WININIT.INI';

// PathGetShortName не работает, если файл не существует
      ShortPath := ExtractFilePath(JclFileUtils.PathGetShortName(AnFileSource));
      WritePrivateProfileString('Rename',
        PChar(ShortPath + ExtractFileName(AnFileTarget)),
        PChar(ShortPath + ExtractFileName(AnFileSource)), PChar(WinInitFile));
{      WritePrivateProfileString('Rename', PChar(JclFileUtils.PathGetShortName(AnFileTarget)),
        PChar(JclFileUtils.PathGetShortName(AnFileSource)), PChar(WinInitFile));}
    end;
    FRestartRequired := True;
  end;
end;
(* исп-ся InstallReportServer - sty
function TGedeminInstall.ExtractServerName(AnPath: String): String;
var
  I: Integer;
begin
  I := Pos(':', AnPath);
  if I > 0 then
  begin
    Result := Copy(AnPath, 1, I - 1);
    if (Length(Result) > 0) and (Result[1] = '\') then
      raise Exception.Create(Format(cExpWrongNetProtocol, [AnPath]));
  end;
end;
*)
(* исп-ся InstallReportServer - sty
procedure TGedeminInstall.SetUserRole(const AnUser: String);
var
  IBDatabase: TIBDatabase;
  IBTransaction: TIBTransaction;
  IBSQLWork: TIBSQL;
begin
  Assert(FDatabasePath <> '');
  IBDatabase := TIBDatabase.Create(nil);
  try
    IBDatabase.DatabaseName := FDatabasePath;
    IBDatabase.Params.Add('user_name=' + FIBUser);
    IBDatabase.Params.Add('password=' + FIBPassword);
    IBDatabase.Params.Add('lc_ctype=' + DefaultLc_ctype);
    IBDatabase.SQLDialect := 3;
    IBDatabase.LoginPrompt := False;
    IBDatabase.Open;

    IBTransaction := TIBTransaction.Create(nil);
    try
      IBDatabase.DefaultTransaction := IBTransaction;
      IBTransaction.DefaultDatabase := IBDatabase;
      IBTransaction.StartTransaction;

      IBSQLWork := TIBSQL.Create(nil);
      try
        IBSQLWork.Database := IBDatabase;
        ibSQLWork.SQL.Text := 'GRANT administrator TO ' + AnUser + ' WITH ADMIN OPTION';
        ibSQLWork.ExecQuery;

        IBTransaction.Commit;

        IBDatabase.Close;
      finally
        ibSQLWork.Free;
      end;
    finally
      IBTransaction.Free;
    end;
  finally
    IBDatabase.Free;
  end;
end;
*)
procedure TGedeminInstall.ReadInstallFiles;
var
  FileName: String;
  SizeOfFile: Integer;
  OldFileMode: Byte;
  F: File;
//  FileHandle: Integer;
  LCheckTCPIP: String;
  Reg: TRegistry;

  function ReadValue(AnSection, AnKeyName, AnDefault: String): String;
  var
    Size: Integer;
    KName: PChar;
  begin
    Result := AnDefault;
    Size := SizeOfFile;
    if Size <= Length(AnDefault) then
      Size := Length(AnDefault) + 1;
    SetLength(Result, Size);
    if Length(AnKeyName) = 0 then
      KName := nil
    else
      KName := @AnKeyName[1];
    if Size = 0 then Exit;
    Size := GetPrivateProfileString(PChar(AnSection), {PChar(AnKeyName), }KName,
      PChar(AnDefault), @Result[1], Size, PChar(FileName));
    SetLength(Result, Size);
  end;

  procedure ParseString(const S: String; var AnInstallFile: TInstallFile);
  const
    cFilePath = '<FILETARGETPATH>';
    cRewrite = '<ISREWRITE>';
    cRegister = '<ISREGISTERED>';
    cShared = '<ISSHARED>';            
    cSelfExtract = '<ISSELFEXTRACT>';            // Yuri
    cWinVersionType = '<WINVERSIONTYPE>';        // Yuri
    cWinLanguage = '<WINLANGUAGE>';              // Yuri 
    cVersion = '<MINVERSION>';
    cSearchDouble = '<ISSEARCHDOUBLE>';
    cLinkName = '<LINKNAME>';
    cDesktop = '<ONDESKTOP>';
    cDigits = ['0'..'9'];
  var
    Cur, FPos: PChar;
    I: Integer;
    TempS, VerStr: String;
    TempVer: Word;

    function GetValue: String;
    begin
      while Cur^ = ' ' do
        Inc(Cur);
      FPos := Cur;
      while (Cur^ <> ';') and (Cur^ <> #0) do
        Inc(Cur);
      Result := Trim(Copy(FPos, 1, Cur - FPos));
    end;
  begin
    if Length(S) = 0 then Exit;

    I := Pos(cFilePath, AnsiUpperCase(S));
    if I > 0 then
    begin
      Cur := @S[1];
      Inc(Cur, I + Length(cFilePath) - 1);
      AnInstallFile.FileTargetPath := GetValue;
    end;

    I := Pos(cRewrite, AnsiUpperCase(S));
    if I > 0 then
    begin
      Cur := @S[1];
      Inc(Cur, I + Length(cRewrite) - 1);
      TempS := GetValue;
      AnInstallFile.IsRewrite := AnsiUpperCase(TempS) = 'TRUE';
    end;

    I := Pos(cSearchDouble, AnsiUpperCase(S));
    if I > 0 then
    begin
      Cur := @S[1];
      Inc(Cur, I + Length(cSearchDouble) - 1);
      TempS := GetValue;
      AnInstallFile.IsSearchDouble := AnsiUpperCase(TempS) = 'TRUE';
    end;

    I := Pos(cRegister, AnsiUpperCase(S));
    if I > 0 then
    begin
      Cur := @S[1];
      Inc(Cur, I + Length(cRegister) - 1);
      TempS := GetValue;
      AnInstallFile.IsRegistered := AnsiUpperCase(TempS) <> 'FALSE';
    end;

    I := Pos(cShared, AnsiUpperCase(S));
    if I > 0 then
    begin
      Cur := @S[1];
      Inc(Cur, I + Length(cShared) - 1);
      TempS := GetValue;
      AnInstallFile.IsShared := AnsiUpperCase(TempS) = 'TRUE';
    end;

    I := Pos(cSelfExtract, AnsiUpperCase(S));
    if I > 0 then
    begin
      Cur := @S[1];
      Inc(Cur, I + Length(cSelfExtract) - 1);
      TempS := GetValue;
      AnInstallFile.IsSelfExtract := AnsiUpperCase(TempS) = 'TRUE';
    end;

    I := Pos(cWinLanguage, AnsiUpperCase(S));
    if I > 0 then
    begin
      Cur := @S[1];
      Inc(Cur, I + Length(cWinLanguage) - 1);
      TempS := GetValue;
      if AnsiUpperCase(TempS) = 'RUS' then
        AnInstallFile.WinLanguageType := wltRUS
      else
        if AnsiUpperCase(TempS) = 'ENG' then
          AnInstallFile.WinLanguageType := wltENG;
    end;

    I := Pos(cWinVersionType, AnsiUpperCase(S));
    if I > 0 then
    begin
      Cur := @S[1];
      Inc(Cur, I + Length(cWinVersionType) - 1);
      TempS := GetValue;
      if AnsiUpperCase(TempS) = 'WINNT' then
        AnInstallFile.WinVersionType := wvtWinNT
      else
        if AnsiUpperCase(TempS) = 'WIN9X' then
          AnInstallFile.WinVersionType := wvtWin9x;
    end;

    I := Pos(cDesktop, AnsiUpperCase(S));
    if I > 0 then
    begin
      Cur := @S[1];
      Inc(Cur, I + Length(cDesktop) - 1);
      TempS := GetValue;
      AnInstallFile.IsMakeDesktopIcon := AnsiUpperCase(TempS) = 'TRUE';
    end;                              

    I := Pos(cLinkName, AnsiUpperCase(S));
    if I > 0 then
    begin
      Cur := @S[1];
      Inc(Cur, I + Length(cLinkName) - 1);
      AnInstallFile.LinkName := GetValue;
    end;

    I := Pos(cVersion, AnsiUpperCase(S));
    if I > 0 then
    begin
      Cur := @S[1];
      Inc(Cur, I + Length(cVersion) - 1);
      TempS := GetValue;
      if TempS <> '' then
      begin
        Cur := @TempS[1];
        VerStr := '';
        // Hi Major
        while Cur^ <> '.' do
        begin
          if Cur^ in cDigits then
            VerStr := VerStr + Cur^
          else
            raise Exception.Create(Format(cExpWrongFileVersionFormat, [TempS]));
          Inc(Cur);
        end;
        TempVer := StrToInt(VerStr);
        AnInstallFile.MinVersion.dwFileVersionMS := TempVer shl 16;
        Inc(Cur);
        VerStr := '';
        // Low Major
        while Cur^ <> '.' do
        begin
          if Cur^ in cDigits then
            VerStr := VerStr + Cur^
          else
            raise Exception.Create(Format(cExpWrongFileVersionFormat, [TempS]));
          Inc(Cur);
        end;
        TempVer := StrToInt(VerStr);
        AnInstallFile.MinVersion.dwFileVersionMS := AnInstallFile.MinVersion.dwFileVersionMS or TempVer;
        Inc(Cur);
        VerStr := '';
        // Hi Minor
        while Cur^ <> '.' do
        begin
          if Cur^ in cDigits then
            VerStr := VerStr + Cur^
          else
            raise Exception.Create(Format(cExpWrongFileVersionFormat, [TempS]));
          Inc(Cur);
        end;
        TempVer := StrToInt(VerStr);
        AnInstallFile.MinVersion.dwFileVersionLS := TempVer shl 16;
        Inc(Cur);
        VerStr := '';
        // Low Minor
        while Cur^ in cDigits do
        begin
          VerStr := VerStr + Cur^;
          Inc(Cur);
        end;
        TempVer := StrToInt(VerStr);
        AnInstallFile.MinVersion.dwFileVersionLS := AnInstallFile.MinVersion.dwFileVersionLS or TempVer;
      end;
    end;
  end;

  procedure ReadFile(const AnSectionName: String; var AnFileList: PCustomFileList;
    var AnCount: Integer);
  var
    S: String;
    SL: TStrings;
    J: Integer;
  begin
    S := ReadValue(AnSectionName, '', '');
    // Если ничего ни считало, то ничего не меняем.
    if S <> '' then
    begin
      for J := 1 to Length(S) do     
        if S[J] = #0 then
          S[J] := #13;
      SL := TStringList.Create;
      try
        SL.Text := S;
        AnFileList := CreateFileArray(SL.Count);
        AnCount := SL.Count;
        for J := 0 to SL.Count - 1 do
          if SL[J] <> '' then
          begin
            S := ReadValue(AnSectionName, SL[J], '');
            AnFileList[J].FileName := SL[J];
            ParseString(S, AnFileList[J]);
          end;
      finally
        SL.Free;
      end;
    end
  end;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(cUnInstallPath, True) then
    begin
      FInstallRootDir := Reg.ReadString(cUninstallString);
      if CompareText(FInstallRootDir, Application.ExeName) = 0 then
        FInstallRootDir := Reg.ReadString(cInstallSource)
      else
        FInstallRootDir := '';
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;

{ TODO -oYuri : Так как все делаем через файл, то при его отсутствии надо прервать установку }
  FileName := GetSourceMainPath + cFilesIni;
  if FileExists(FileName) then
  begin
{    FileHandle := FileOpen(FileName, fmOpenRead);
    if FileHandle = -1 then
      raise Exception.Create('Нельзя открыть файл ' + FileName);
    try
      SizeOfFile := FileSeek(FileHandle, 0, 2);
    finally
      FileClose(FileHandle);
    end;}
    AssignFile(F, FileName);
    OldFileMode := FileMode;
    FileMode := 0;
    Reset(F, 1);
    try
      SizeOfFile := FileSize(F);
    finally
      CloseFile(F);
      FileMode := OldFileMode;
    end;
    vMainServerFileName := ReadValue(cOptionsSection, cMainServerValueName, vMainServerFileName);
    vMainGuardFileName := ReadValue(cOptionsSection, cMainGuardValueName, vMainGuardFileName);
    vMainClientFileName := ReadValue(cOptionsSection, cMainClientValueName, vMainClientFileName);
    vMainDatabaseFile := ReadValue(cOptionsSection, cMainDatabaseValueName, vMainDatabaseFile);
{    vMainReportFile := ReadValue(cOptionsSection, cMainReportValueName, vMainReportFile);
    vMainReportServiceFile := ReadValue(cOptionsSection, cMainReportServiceValueName, vMainReportServiceFile); sty}
    vMainGedeminFile := ReadValue(cOptionsSection, cMainGedeminValueName, vMainGedeminFile);
    vLinkMainPath := ReadValue(cOptionsSection, cLinkMainPathValueName, vLinkMainPath);

    LCheckTCPIP := 'TRUE';
    LCheckTCPIP := ReadValue(cOptionsSection, cCheckTCPIPValueName, LCheckTCPIP);
    vCheckTCPIP := AnsiUpperCase(LCheckTCPIP) <> 'FALSE';
    LCheckTCPIP := 'TRUE';
    LCheckTCPIP := ReadValue(cOptionsSection, cSetSettingValueName, LCheckTCPIP);
    vSetSetting := AnsiUpperCase(LCheckTCPIP) <> 'FALSE';

    vServerName := ReadValue(cOptionsSection, cServerValueName, vServerName);
    vServerVersion := ReadValue(cOptionsSection, cVersionValueName, vServerVersion);
    vIBServiceName := ReadValue(cOptionsSection, cServiceValueName, vIBServiceName);
    vIBGuardServiceName := ReadValue(cOptionsSection, cGuardServiceValueName, vIBGuardServiceName);
    vIBServiceDisplayName := ReadValue(cOptionsSection, cServiceDisplayValueName, vIBServiceDisplayName);
    vIBGuardServiceDisplayName := ReadValue(cOptionsSection, cGuardServiceDisplayValueName, vIBGuardServiceDisplayName);

    ReadFile(cServerSection, vServerList, vServerListCount);
    ReadFile(cServerDllSection, vServerDllList, vServerDllListCount);
    ReadFile(cClientSection, vClientList, vClientListCount);
    ReadFile(cGedeminSection, vGedeminList, vGedeminListCount);
    ReadFile(cDatabaseSection, vDatabaseList, vDatabaseListCount);
{    ReadFile(cReportSection, vReportList, vReportListCount); sty}
  end;{ else
    raise Exception.Create('Не найдет файл ' + cFilesIni);} 

end;

function TGedeminInstall.OwnerHandle: Integer;
begin
  if Assigned(Owner) and (Owner is TWinControl) then
    Result := TWinControl(Owner).Handle
  else
    Result := 0;
end;

function TGedeminInstall.GetGuardHandle: HWND;
begin
  Result := FindWindow('ib_guard', nil);
  if Result = 0 then
    Result := FindWindow(nil, 'InterBase Guardian');
  if Result = 0 then
    Result := FindWindow(nil, 'Firebird Guardian');
  if Result = 0 then
    Result := FindWindow(nil, 'Yaffil Guardian');
  if Result = 0 then
    Result := FindWindow('YA_guard', nil);
end;

procedure TGedeminInstall.FindGedemin(AnPathList: TStrings);
var
  Reg: TRegistry;
  SL: TStrings;
  I: Integer;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKeyReadOnly(cExecuteRegPath) then
    begin
      SL := TStringList.Create;
      try
        Reg.GetValueNames(SL);
        for I := 0 to SL.Count - 1 do
          if FileExists(SL.Strings[I]) then
          begin
            AnPathList.Add(SL.Strings[I]);
          end;
      finally
        SL.Free;
      end;
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;
                       
function TGedeminInstall.GetLogFileName: String;
begin                                    
  Result := ProgramPath + '\install.log';
end;

function TGedeminInstall.GetTempFileName: String;
begin
  if FTempFileName = '' then
    FTempFileName := ExcludeTrailingBackslash(GetTempPathString) + '\gedemin.bat';
  Result := FTempFileName;
end;
(*
procedure TGedeminInstall.SetSettingNeeded(const ADatabaseName: String; const AnSettingNeeded: Boolean = True);
var
  ibsqlSetting: TIBSQL;
begin
  QueryPassword;

  ibsqlSetting := TIBSQL.Create(nil);
  try
    ibsqlSetting.Transaction := TIBTransaction.Create(nil);
    try
      ibsqlSetting.Database := TIBDatabase.Create(nil);
      try
        ibsqlSetting.Database.DatabaseName := ADatabaseName;
        ibsqlSetting.Database.Params.Add('user_name=' + FIBUser);
        ibsqlSetting.Database.Params.Add('password=' + FIBPassword);
        ibsqlSetting.Database.LoginPrompt := False;
        ibsqlSetting.Transaction.DefaultDatabase := ibsqlSetting.Database;
        ibsqlSetting.Database.Connected := True;
        ibsqlSetting.Transaction.StartTransaction;
        ibsqlSetting.GoToFirstRecordOnExecute := True;
        ibsqlSetting.SQL.Text :=
          'SELECT rdb$relation_name FROM rdb$relations WHERE rdb$relation_name = ''ST_SETTINGSTATE''';
        ibsqlSetting.ExecQuery;
        if not ibsqlSetting.Eof then
        begin
          ibsqlSetting.Close;
          ibsqlSetting.SQL.Text := 'INSERT INTO st_settingstate ' +
           '(STATUS, COMMENT) VALUES(:STATUS, :COMMENT)';
          if AnSettingNeeded then
            ibsqlSetting.ParamByName('status').AsInteger := 0
          else
            ibsqlSetting.ParamByName('status').AsInteger := 2;

          ibsqlSetting.ParamByName('comment').AsString := 'Installer';
          ibsqlSetting.ExecQuery;
          ibsqlSetting.Transaction.Commit;
        end;
      finally
        ibsqlSetting.Database.Free;
      end;
    finally
      ibsqlSetting.Transaction.Free;
    end;
  finally
    ibsqlSetting.Free;
  end;
end;
 sty *)

function GetServerDatabase(AnDBPath: String): String;
var
  FirstPos, J: Integer;
begin
  FirstPos := 0;
  Result := '';
  for J := 1 to Length(AnDBPath) do
    if AnDBPath[J] = ':' then
    begin
      if FirstPos = 0 then
        FirstPos := J
      else
        Result := Copy(AnDBPath, 1, FirstPos - 1);
    end;
end;

procedure TGedeminInstall.RunSelfCopy(AnParams: String);
begin
  if ShellExecute(0, 'open', PChar(Application.ExeName), PChar(AnParams), '', 0) <= 32 then
    raise Exception.Create(Format('Не удалось запустить файл %s с параметрами %s',
      [Application.ExeName, AnParams]));
end;

function TGedeminInstall.GetFileParams(const AnFilePath: String): String;
var
  I: Integer;
begin
  Result := '';
  I := Pos('/', AnFilePath);
  if I > 0 then
    Result := Copy(AnFilePath, I, Length(AnFilePath));
end;

function TGedeminInstall.GetFileFromList(const AnList: TStrings;
  const AnPath: String; const AnExcept: Boolean = False): String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to AnList.Count - 1 do
    if Pos(AnsiUpperCase(AnPath), AnsiUpperCase(AnList[I])) = 1 then
      Result := AnList[I];
  if (Result = '') and AnExcept then
    raise Exception.Create('Файл не найден ' + AnPath);
end;

procedure TGedeminInstall.InstallServerDll;
var                                  
  I: Integer;
begin
  DoLog('Начат процесс установки динамических библиотек для сервера');
  FRestartRequired := False;

  for I := 0 to vServerDllListCount - 1 do
    InstallFile(vServerDllList[I], not (imServerDll in FYetInstalledModules), cA);

  FInstallModules := FInstallModules - [imServerDll];

  DoLog('Процесс установки динамических библиотек для сервера завершен');
end;

function TGedeminInstall.ExtractIBPathFromFileName(const Value: String): String;
begin
  Result := ExtractFilePath(Value);
  if Pos('\BIN\', AnsiUpperCase(Result)) > 0 then
    Result := ExcludeTrailingBackSlash(ExtractFilePath(ExtractFileDir(Result)));
end; 

procedure TGedeminInstall.SetNullID(const ADatabaseName: String);
var
  ibsqlSetting: TIBSQL;
begin
  QueryPassword;

  ibsqlSetting := TIBSQL.Create(nil);
  try
    ibsqlSetting.Transaction := TIBTransaction.Create(nil);
    try
      ibsqlSetting.Database := TIBDatabase.Create(nil);
      try
        ibsqlSetting.Database.DatabaseName := ADatabaseName;
        ibsqlSetting.Database.Params.Add('user_name=' + FIBUser);
        ibsqlSetting.Database.Params.Add('password=' + FIBPassword);
        ibsqlSetting.Database.LoginPrompt := False;
        ibsqlSetting.Transaction.DefaultDatabase := ibsqlSetting.Database;
        ibsqlSetting.Database.Connected := True;
        ibsqlSetting.Transaction.StartTransaction;
        ibsqlSetting.SQL.Text := 'SET GENERATOR GD_G_DBID TO 0';
        ibsqlSetting.ExecQuery;
        ibsqlSetting.Transaction.Commit;
      finally
        ibsqlSetting.Database.Free;
      end;
    finally
      ibsqlSetting.Transaction.Free;
    end;
  finally
    ibsqlSetting.Free;
  end;
end;

function TGedeminInstall.GetProtocol: TProtocol;
begin
  if InstallType = itLocal then
    Result := Local
  else
    Result := TCP;
end;
  
// определяет язык ОС Windows
function TGedeminInstall.GetInstallLanguage: Word;
var
  Reg: TRegistry;
  isOK: Boolean;
begin     
  isOK := False;
  Result := 0;

// Лучшего варианта пока нет...    
  Reg := TRegistry.Create;
  try                          
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKeyReadOnly('\SYSTEM\CurrentControlSet\Control\Nls\Language') then
    begin
      if Reg.ValueExists('InstallLanguage') then
      begin
        try
          Result := StrToInt(Reg.ReadString('InstallLanguage'));
          isOK := True;
        except
        end;
      end;
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;

// если не нашли в реестре - проверяем язык.
// если винда английская - вернет Russian, русская - 'Русский'  
  if not isOK then
  begin 
    with TJclLocaleInfo.Create do 
    try
      if ANSICompareStr(ANSIUpperCase(LocalizedLangName), ANSIUpperCase('Русский')) = 0 then
        Result := 419;  
    finally
      Free;
    end;
  end;
end;

procedure TGedeminInstall.CheckServerName2;
begin
  if not CheckServerName(GetComputerNameString) then
    raise Exception.Create(cExpRussianServerName);
end;

function TGedeminInstall.CheckServerName(const AnName: String): Boolean;
const
  cDigits = ['0'..'9'];
  cRusChars = ['а'..'я', 'А'..'Я', 'ё', 'Ё'];
var
  I: Integer;
begin
  Result := (Length(AnName) > 0) and not (AnName[1] in cDigits);
  if Result then
    for I := 1 to Length(AnName) do
      Result := Result and not (AnName[I] in cRusChars);
end;

(*
procedure TGedeminInstall.RemoveDelayed(AnPathList: TStrings);
var
  i, j: Integer;
begin
  i := 0;
  j := 0;
  while i < AnPathList.Count do
  begin
    while j < FDelayedFilesList.Count do
    begin
      if ANSICompareStr(ANSIUpperCase(FDelayedFilesList[j]), ANSIUpperCase(AnPathList[i])) = 0 then
      begin
        AnPathList.Delete(i);
        Dec(i);
        Break;
      end;
      Inc(j);
    end;
    Inc(i);
  end;
end;
*)
end.
