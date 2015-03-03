; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#ifndef GedAppID
  #define public GedAppID "Ged25Local"
#endif

#ifndef URL
  #define public URL "http://www.gsbelarus.com"
#endif

#ifndef DefDir
  #define public DefDir "\Golden Software\Gedemin"
#endif

#ifndef DefGroup
  #define public DefGroup "Golden Software ������� 2.5"
#endif

#ifndef SupportPhone
  #define public SupportPhone "+375-17-2561759"
#endif

#ifndef UpdateToken
  #define public UpdateToken "NORMAL"
#endif

#define public GedFileVersion "2.5.0.0"

[Setup]
AppID={#GedAppID}
AppName={#GedAppName}
AppVerName={#GedAppVerName}
AppPublisher=Golden Software of Belarus, Ltd
AppPublisherURL={#URL}
AppSupportURL={#URL}
AppUpdatesURL={#URL}
AppCopyright=Copyright (c) 1995-2014 Golden Software of Belarus, Ltd.
AppSupportPhone={#SupportPhone}
DefaultDirName={sd}{#DefDir}
DefaultGroupName={#DefGroup}
DisableProgramGroupPage=yes
OutputDir=c:\temp\setup
OutputBaseFilename=setup
Compression=lzma/ultra
SolidCompression=yes
MinVersion=0,5.01sp2
Uninstallable=yes
ShowLanguageDialog=auto
SourceDir={#SourcePath}\..\..\..\Gedemin_Local_FB3\
UsePreviousAppDir=yes
DisableReadyPage=yes
DisableFinishedPage=yes 
VersionInfoCompany=Golden Software of Belarus, Ltd
VersionInfoProductName={#GedAppName}
VersionInfoVersion={#GedFileVersion} 
VersionInfoDescription={#GedAppName}

[Languages]
Name: "english"; MessagesFile: "compiler:default.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"
Name: "belarusian"; MessagesFile: "compiler:Languages\Belarusian.isl"

[Tasks]
Name: "databasefile"; Description: "���������� ���� ���� ������"; GroupDescription: "���� ������:"; Flags:
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags:
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

#ifdef Cash
  Name: "ppserver"; Description: "���������� ������� ���������� ���������"; GroupDescription: "�������� ������������:"; Flags:
  Name: "usbpd"; Description: "���������� ������� ������� ����������"; GroupDescription: "�������� ������������:"; Flags:
#endif

[Files]
Source: "gedemin.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "gedemin_upd.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "gedemin.exe.manifest"; DestDir: "{app}"; Flags: ignoreversion
Source: "gsdbquery.dll"; DestDir: "{app}"; Flags: ignoreversion regserver
Source: "UDF\gudf.dll"; DestDir: "{app}\UDF"; Flags: ignoreversion
Source: "PLUGINS\engine12.dll"; DestDir: "{app}\plugins"; Flags: ignoreversion
Source: "PLUGINS\fbtrace.dll"; DestDir: "{app}\plugins"; Flags: ignoreversion
Source: "PLUGINS\legacy_auth.dll"; DestDir: "{app}\plugins"; Flags: ignoreversion
Source: "PLUGINS\legacy_usermanager.dll"; DestDir: "{app}\plugins"; Flags: ignoreversion
Source: "PLUGINS\srp.dll"; DestDir: "{app}\PLUGINS"; Flags: ignoreversion
Source: "PLUGINS\udr_engine.conf"; DestDir: "{app}\plugins"; Flags: ignoreversion
Source: "PLUGINS\udr_engine.dll"; DestDir: "{app}\plugins"; Flags: ignoreversion

Source: "fbclient.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "fbrmclib.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "ib_util.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "icudt52.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "icudt52l.dat"; DestDir: "{app}"; Flags: ignoreversion
Source: "icuin52.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "icuuc52.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "msvcp100.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "msvcr100.dll"; DestDir: "{app}"; Flags: ignoreversion

Source: "Microsoft.VC80.CRT.manifest"; DestDir: "{app}"; Flags: ignoreversion
Source: "firebird.msg"; DestDir: "{app}"; Flags: ignoreversion
Source: "Intl\fbintl.dll"; DestDir: "{app}\Intl"; Flags: ignoreversion
Source: "Intl\fbintl.conf"; DestDir: "{app}\Intl"; Flags: ignoreversion
Source: "midas.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "midas.sxs.manifest"; DestDir: "{app}"; Flags: ignoreversion
Source: "Help\fr24rus.chm"; DestDir: "{app}\Help"; Flags: ignoreversion
Source: "Help\vbs55.chm"; DestDir: "{app}\Help"; Flags: ignoreversion
Source: "Database\{#DBFileOnlyName}.bk"; DestDir: "{app}\Database"; Flags: deleteafterinstall; Tasks: databasefile

Source: "libeay32.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "ssleay32.dll"; DestDir: "{app}"; Flags: ignoreversion

Source: "SWIPl\Lib\memfile.dll"; DestDir: "{app}\SWIPl\Lib"; Flags: ignoreversion
Source: "SWIPl\Lib\readutil.dll"; DestDir: "{app}\SWIPl\Lib"; Flags: ignoreversion
Source: "SWIPl\gd_pl_state.dat"; DestDir: "{app}\SWIPl"; Flags: ignoreversion
Source: "SWIPl\libgmp-10.dll"; DestDir: "{app}\SWIPl"; Flags: ignoreversion
Source: "SWIPl\libswipl.dll"; DestDir: "{app}\SWIPl"; Flags: ignoreversion
Source: "SWIPl\pthreadGC2.dll"; DestDir: "{app}\SWIPl"; Flags: ignoreversion

#ifdef Cash
  Source: "USBPD.dll"; DestDir: "{app}"; Flags: ignoreversion; Tasks: usbpd
  Source: "PDPosiFlexCommand.dll"; DestDir: "{app}"; Flags: ignoreversion regserver; Tasks: usbpd
  Source: "PDComWriter.dll"; DestDir: "{app}"; Flags: ignoreversion regserver; Tasks: usbpd
  Source: "trhems.ini"; DestDir: "{app}"; Flags: ignoreversion; Tasks: ppserver
  Source: "settings.xml"; DestDir: "{app}"; Flags: ignoreversion; Tasks: ppserver
  Source: "ppServer.exe"; DestDir: "{app}"; Flags: ignoreversion; Tasks: ppserver
#endif

[INI]
Filename: "{app}\gedemin.ini"; Section: "WEB CLIENT"; Key: "Token"; String: "{#UpdateToken}"; 
Filename: "{app}\databases.ini"; Section: "{#GedSafeAppName}"; Key: "FileName"; String: "Database\{#DBFileOnlyName}.fdb"; Tasks: "databasefile"
Filename: "{app}\databases.ini"; Section: "{#GedSafeAppName}"; Key: "Selected"; String: "1"; Tasks: "databasefile"
#ifdef Cash
  Filename: "{app}\gedemin.ini"; Section: "WEB CLIENT"; Key: "AutoUpdate"; String: "0"; 
#endif

[Icons]
Name: "{group}\{#GedSafeAppName}"; Filename: "{app}\gedemin.exe"; WorkingDir: "{app}"
Name: "{group}\www.gsbelarus.com"; Filename: "{#URL}"; IconFileName: "{app}\gedemin.exe"
Name: "{commondesktop}\{#GedSafeAppName}"; Filename: "{app}\gedemin.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#GedSafeAppName}"; Filename: "{app}\gedemin.exe"; Tasks: quicklaunchicon
Name: "{group}\{cm:UninstallProgram,{#GedSafeAppName}}"; Filename: "{uninstallexe}"; WorkingDir: "{app}"
#ifdef Cash
  Name: "{commonstartmenu}\ppServer"; Filename: "{app}\ppServer.exe"; WorkingDir: "{app}"; Tasks: ppserver
#endif

[Run]
FileName: "{app}\gedemin.exe"; Parameters: "/rd /r EMBEDDED ""{app}\Database\{#DBFileOnlyName}.bk"" ""{app}\Database\{#DBFileOnlyName}.fdb"" SYSDBA masterkey 8192 8192"; WorkingDir: {app}; StatusMsg: "���������� ���� ������..."; Flags: waituntilterminated runhidden; Tasks: databasefile
Filename: "{app}\gedemin.exe"; Description: "{cm:LaunchProgram,{#GedSafeAppName}}"; WorkingDir: {app}; Flags: nowait postinstall skipifsilent

[InstallDelete]
Type: files; Name: "{app}\gedemin.jpg"

Type: files; Name: "{app}\gds32.dll"
Type: files; Name: "{app}\fbembed.dll"
Type: files; Name: "{app}\ib_util.dll"
Type: files; Name: "{app}\icudt30.dll"
Type: files; Name: "{app}\icuin30.dll"
Type: files; Name: "{app}\icuuc30.dll"
Type: files; Name: "{app}\msvcp80.dll"
Type: files; Name: "{app}\msvcr80.dll"

[UninstallDelete]
Type: files; Name: "{app}\gedemin.ini"
Type: files; Name: "{app}\gedemin_upd.ini"
Type: files; Name: "{app}\*.bak"
Type: files; Name: "{app}\*.new"
Type: filesandordirs; Name: "{app}\udf"
Type: filesandordirs; Name: "{app}\Intl"
Type: filesandordirs; Name: "{app}\Help"
Type: filesandordirs; Name: "{app}\plugins"
Type: dirifempty; Name: "{app}\Database"

#ifdef Cash
  Type: files; Name: "{app}\trpos.log"
  Type: files; Name: "{app}\trhems.log"
#endif
