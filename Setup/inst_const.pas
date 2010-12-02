unit inst_const;
                                
interface

const
  // ���� � �������
  cSharedDLLRegPath = 'SOFTWARE\Microsoft\Windows\CurrentVersion\SharedDLLs';
  cRunOnceRegPath = 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce';
  cRunRegPath = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run';
  cUninstallPath = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Gedemin';
  cYaffilRegPath = 'SOFTWARE\Yaffil';
  //cGedeminRoot = 'SOFTWARE\Golden Software\Gedemin';
  cServerRegPath = 'SOFTWARE\Golden Software\Gedemin\Server\CurrentVersion';
  cClientRegPath = 'SOFTWARE\Golden Software\Gedemin\Client\CurrentVersion';
  cSettingRegPath = cClientRegPath + '\Setting';

  cExecuteRegPath = 'SOFTWARE\Golden Software\Gedemin\Client\ExecuteFiles';
  cAddDatabaseRegPath = cServerRegPath + '\Database';

  // ������������ ���������� � �������
  cIBValueServerDir = 'ServerDirectory';
  cIBValueVersion = 'Version';
  cIBValueGrdOpt = 'GuardianOptions';
  cIBValueDM = 'DefaultMode';
  cIBValueDCM = 'DefaultClientMode';
  cGDToolsDirectory = 'ToolsDirectory';
  cGDDatabase = 'ServerName';
  cGDValueServerArchive = 'ArchiveDirectory';
  cGDValueRootPath = 'RootPath';
  cGDValueQueryPass = 'InstallQueryPassword';
  cUnDisplayName = 'DisplayName';
  cGedeminInstall = 'GedeminInstall';
  cPackageSearchPath = 'PackageSearchPath';

  cDisplayName = 'DisplayName';
  cUninstallString = 'UninstallString';
  cInstallSource = 'InstallSource';
  cValueDatabase = 'Database';

  // ����� ����� ������� ������ ������� � ������� ��� �� ��������� ...
  cWinCount = 8;
  cWinFiles: array[0..cWinCount - 1] of String = ('MSVCRT.DLL', 'WININET.DLL',
    'SHLWAPI.DLL', 'URLMON.DLL', 'HHCTRL.OCX', 'JSCRIPT.DLL', 'VBSCRIPT.DLL',
    'MIDAS.DLL' {��� �� �����, �� �������� �� �������� ����������});

  // ����� ��� ������� ��������� ����� ������������ � ��������� ������
  // TInstallModule = (imServer, imClient, imGedemin, ImReport, imDatabase);
  cimServer = '/SERVER';
  cimServerDll = '/SERVERDLL';
  cimGedemin = '/GEDEMIN';
  cimClient = '/CLIENT';
  cimDatabase = '/DATABASE';
  cimIBPath = '/IBPATH';
  cimFirstIB = '/IBFIRSTINSTALL';
  cimPassword = '/IBPASS';
  cimUser = '/IBUSER';

  // ��� ������������� � �� ������
  cStartUser = 'STARTUSER';
  cStartPass = 'startuser';
  cSysPass = 'masterkey';

  // ���������� ����� ����������� ������� �������������� � �������
  cAppServerCount = 6;
  cAppServerNames: array[0..cAppServerCount - 1] of String =
    ('IBSERVER.EXE', 'IBGUARD.EXE', 'FBGUARD.EXE', 'FBSERVER.EXE', 'YAGUARD.EXE', 'YASERVER.EXE');

  // ��������� ������������ �������
  cServerExeCount = 3;
  cServerExeNames: array[0..cServerExeCount - 1] of String =
    ('IBSERVER.EXE', 'FBSERVER.EXE', 'YASERVER.EXE');

  // ��������� ������������ ������
  cGuardExeCount = 3;
  cGuardExeNames: array[0..cGuardExeCount - 1] of String =
    ('IBGUARD.EXE', 'FBGUARD.EXE', 'YAGUARD.EXE');

  // �������, ����� ������� �������������� � ���������� ������� ���������������
  // ����� ������������
  cServiceServerCount = 7;
  cServiceServerNames: array[0..cServiceServerCount - 1] of String = ('InterbaseGuardian',
  'FirebirdGuardian', 'YaffilGuardian', 'InterBaseRemoteService', 'InterbaseServer', 'FirebirdServer',
  'YaffilSQLServer(SS)');

  // ������������ ������� ������� ������� � ��� ��� �����������
  cReportServiceName = 'ReportGuard';//'GedeminReportServer';
  cReportDisplayName = 'Gedemin Report Guardian';//'Gedemin Report Server'; sty}

  cCompanyName = 'Golden Software';
  cApplicationName = 'Gedemin';

  cFilesIni = 'files.ini';

  cMainServerValueName = 'ServerMain';
  cMainGuardValueName = 'GuardMain';
  cMainClientValueName = 'ClientMain';
  cMainDatabaseValueName = 'DatabaseMain';
  cMainGedeminValueName = 'GedeminMain';
  cMainSettingValueName = 'SettingPath';
  cCheckTCPIPValueName = 'CheckTCPIP';
  cSetSettingValueName = 'SetSetting';
  cLinkMainPathValueName = 'LinkMainPath';
  cServerValueName = 'ServerName';
  cVersionValueName = 'VersionName';
  cServiceValueName = 'IBServerServiceName';
  cGuardServiceValueName = 'IBGuardServiceName';
  cServiceDisplayValueName = 'IBServerServiceDisplayName';
  cGuardServiceDisplayValueName = 'IBGuardServiceDisplayName';
  cLinkMainPath = '\Golden Software\Gedemin';

  cOptionsSection = 'OPTIONS';
  cServerSection = 'SERVER';
  cServerDllSection = 'SERVERDLL';
  cClientSection = 'CLIENT';
  cDatabaseSection = 'DATABASE';
  cGedeminSection = 'GEDEMIN';

  // ������� ����� ��� ����������� ������
  cMainServerFileName = 'ibserver.exe';
  cMainGuardFileName = 'ibguard.exe';
  cMainClientFileName = 'gds32.dll';
  cMainDatabaseFile = 'gdbase.gdb';
  cMainGedeminFile = 'gedemin.exe';
  cMainDBListFile = 'database.ini';
  cMainSettingPath = 'Setting\';

  // ������������ �������
  cServerName = 'Yaffil';
  cServerVersion = 'WI-Release1.2.877 Yaffil SQL Server';
  cIBServiceName = 'YaffilSQLServer(SS)';
  cIBGuardServiceName = 'YaffilGuardian';
  cIBServiceDisplayName = 'Yaffil SQL Server (SS)';
  cIBGuardServiceDisplayName = 'YaffilGuardian';

implementation


end.
