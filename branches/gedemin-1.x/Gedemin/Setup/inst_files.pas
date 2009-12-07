unit inst_files;

interface

uses
  gsGedeminInstall;

(*
const
// количество файлов в каждом разделе по умолчанию
  cClientListCount = 3;
  cServerListCount = 10;
  cServerDllListCount = 3;
  cGedeminListCount = 9 {14 sty};
{  cReportListCount = 9; sty}
  cUninstallListCount = 2;
  cDatabaseListCount = 3;
*)
type
  TClientInstallFileList    = array[0..1] of TInstallFile;
  TServerInstallFileList    = array[0..1] of TInstallFile;
  TServerDllInstallFileList = array[0..1] of TInstallFile;
  TGedeminInstallFileList   = array[0..1] of TInstallFile;
  TDatabaseFileList         = array[0..1] of TInstallFile;

{  TClientInstallFileList = array[0..cClientListCount - 1] of TInstallFile;
  TServerInstallFileList = array[0..cServerListCount - 1] of TInstallFile;
  TServerDllInstallFileList = array[0..cServerDllListCount - 1] of TInstallFile;
  TGedeminInstallFileList = array[0..cGedeminListCount - 1] of TInstallFile;
  TDatabaseFileList = array[0..cDatabaseListCount - 1] of TInstallFile;}

  TCustomFileList = array[0..MAXINT div SizeOf(TInstallFile) - 1] of TInstallFile;
  PCustomFileList = ^TCustomFileList;

  TDynamicFileList = array of TInstallFile;
  PDynamicFileList = ^TDynamicFileList;

const

(*  ClientList: TClientInstallFileList = (
    (FileName: 'IBFiles\Bin\gds32.dll'; FileTargetPath: cSystemPath;
       IsRewrite: True; IsRegistered: False; IsShared: True; IsSearchDouble: True),
    (FileName: 'Microsoft\msvcrt.dll'; FileTargetPath: cSystemPath;//cInterbasePath + 'Bin\';
       IsRewrite: False; IsRegistered: False; IsShared: True;
       MinVersion: (dwFileVersionMS: $050000; dwFileVersionLS: $1C87); IsSearchDouble: True),  {5.0.0.7303}
    (FileName: 'IBFiles\interbase.msg'; FileTargetPath: cInterbasePath;
       IsRewrite: True; IsRegistered: False; IsShared: True; IsSearchDouble: True)
  );

  ServerList: TServerInstallFileList = (
    (FileName: 'IBFiles\Bin\ibserver.exe'; FileTargetPath: cInterbasePath + 'Bin\';
       IsRewrite: True; IsRegistered: False; IsShared: True; IsSearchDouble: True),
    (FileName: 'IBFiles\Bin\ibguard.exe'; FileTargetPath: cInterbasePath + 'Bin\';
       IsRewrite: True; IsRegistered: False; IsShared: True; IsSearchDouble: True),
    (FileName: 'IBFiles\ibconfig'; FileTargetPath: cInterbasePath;
       IsRewrite: False; IsRegistered: False; IsShared: True; IsSearchDouble: True),
    (FileName: 'IBFiles\isc4.gdb'; FileTargetPath: cInterbasePath;
       IsRewrite: False; IsRegistered: False; IsShared: True; IsSearchDouble: True),
    (FileName: 'IBFiles\license.txt'; FileTargetPath: cInterbasePath;
       IsRewrite: False; IsRegistered: False; IsShared: True; IsSearchDouble: True),
//    (FileName: 'IBFiles\ib_license.dat'; FileTargetPath: cInterbasePath;
//       IsRewrite: False; IsRegistered: False; IsShared: False),
    (FileName: 'IBFiles\Bin\gds32.dll'; FileTargetPath: cSystemPath;
       IsRewrite: True; IsRegistered: False; IsShared: True; IsSearchDouble: True),
    (FileName: 'IBFiles\interbase.msg'; FileTargetPath: cInterbasePath;
       IsRewrite: True; IsRegistered: False; IsShared: True; IsSearchDouble: True),
    (FileName: 'Microsoft\msvcrt.dll'; FileTargetPath: cSystemPath;//cInterbasePath + 'Bin\';
       IsRewrite: False; IsRegistered: False; IsShared: True;
       MinVersion: (dwFileVersionMS: $050000; dwFileVersionLS: $1C87); IsSearchDouble: True),  {5.0.0.7303}
    (FileName: 'IBFiles\Bin\ib_util.dll'; FileTargetPath: cInterbasePath + 'Bin\';
       IsRewrite: True; IsRegistered: False; IsShared: True; IsSearchDouble: True),
    (FileName: 'IBFiles\Intl\gdsintl.dll'; FileTargetPath: cInterbasePath + 'Intl\';
       IsRewrite: True; IsRegistered: False; IsShared: True; IsSearchDouble: True)
  );

  ServerDllList: TServerDllInstallFileList = (
    (FileName: 'GUDF\gudf.dll'; FileTargetPath: cInterbasePath + 'Udf\';
       IsRewrite: True; IsRegistered: False; IsShared: True; IsSearchDouble: True),
    (FileName: 'GUDF\fbudf.dll'; FileTargetPath: cInterbasePath + 'Udf\';
       IsRewrite: True; IsRegistered: False; IsShared: True; IsSearchDouble: True),
    (FileName: 'IBFiles\Udf\ib_udf.dll'; FileTargetPath: cInterbasePath + 'Udf\';
       IsRewrite: True; IsRegistered: False; IsShared: True; IsSearchDouble: True)
  );

  GedeminList: TGedeminInstallFileList = (
    (FileName: 'Gedemin\readme.txt'; FileTargetPath: cProgrammPath;
       IsRewrite: False; IsRegistered: False; IsShared: False; IsSearchDouble: True),
    (FileName: 'Gedemin\gedemin.exe'; FileTargetPath: cProgrammPath;
       IsRewrite: False; IsRegistered: True; IsShared: False; IsSearchDouble: True),
//    (FileName: 'Gedemin\gcl.dll'; FileTargetPath: cProgrammPath;
//       IsRewrite: False; IsRegistered: True; IsShared: True; IsSearchDouble: True),
    (FileName: 'Gedemin\Tools\upgrade.exe'; FileTargetPath: cProgrammPath + 'Tools\';
       IsRewrite: False; IsRegistered: False; IsShared: False; IsSearchDouble: True),
    (FileName: 'Gedemin\midas.dll'; FileTargetPath: cSystemPath;
       IsRewrite: False; IsRegistered: True; IsShared: False; IsSearchDouble: True),
{    (FileName: 'Gedemin\Report\rmsvrmng.exe'; FileTargetPath: cProgrammPath + 'Report\';
       IsRewrite: False; IsRegistered: True; IsShared: False; IsSearchDouble: True), sty}
    // —крипт
    (FileName: 'Microsoft\vbscript.dll'; FileTargetPath: cSystemPath;
       IsRewrite: False; IsRegistered: True; IsShared: True; IsSearchDouble: True),
    (FileName: 'Microsoft\jscript.dll'; FileTargetPath: cSystemPath;
       IsRewrite: False; IsRegistered: True; IsShared: True; IsSearchDouble: True),
    (FileName: 'Microsoft\msscript.ocx'; FileTargetPath: cSystemPath;
       IsRewrite: False; IsRegistered: True; IsShared: True; IsSearchDouble: True),
    (FileName: 'Microsoft\msscript.cnt'; FileTargetPath: cSystemPath;
       IsRewrite: False; IsRegistered: False; IsShared: True; IsSearchDouble: True),
    (FileName: 'Microsoft\msscript.hlp'; FileTargetPath: cSystemPath;
       IsRewrite: False; IsRegistered: False; IsShared: True; IsSearchDouble: True){,
    // ’елп
    (FileName: 'Microsoft\shlwapi.dll'; FileTargetPath: cSystemPath;
       IsRewrite: False; IsRegistered: True; IsShared: True; IsSearchDouble: True),
    (FileName: 'Microsoft\wininet.dll'; FileTargetPath: cSystemPath;
       IsRewrite: False; IsRegistered: True; IsShared: True; IsSearchDouble: True),
    (FileName: 'Microsoft\urlmon.dll'; FileTargetPath: cSystemPath;
       IsRewrite: False; IsRegistered: True; IsShared: True; IsSearchDouble: True),
    (FileName: 'Microsoft\hhctrl.ocx'; FileTargetPath: cSystemPath;
       IsRewrite: False; IsRegistered: True; IsShared: True; IsSearchDouble: True) sty}
  );

{  ReportList: TReportIstallFileList = (
    (FileName: 'Gedemin\Report\reportsv.exe'; FileTargetPath: cProgrammPath + 'Report\';
       IsRewrite: False; IsRegistered: False; IsShared: True; IsSearchDouble: True),
    (FileName: 'Gedemin\Report\rmsvrmng.exe'; FileTargetPath: cProgrammPath + 'Report\';
       IsRewrite: False; IsRegistered: False; IsShared: False; IsSearchDouble: True),
    (FileName: 'Gedemin\Report\reportmanager.exe'; FileTargetPath: cProgrammPath + 'Report\';
       IsRewrite: False; IsRegistered: False; IsShared: False; IsSearchDouble: True),
    (FileName: 'Gedemin\midas.dll'; FileTargetPath: cSystemPath;
       IsRewrite: False; IsRegistered: True; IsShared: False; IsSearchDouble: True),
    (FileName: 'Microsoft\msscript.ocx'; FileTargetPath: cSystemPath;
       IsRewrite: False; IsRegistered: True; IsShared: True; IsSearchDouble: True),
    (FileName: 'Microsoft\msscript.cnt'; FileTargetPath: cSystemPath;
       IsRewrite: False; IsRegistered: False; IsShared: False; IsSearchDouble: True),
    (FileName: 'Microsoft\msscript.hlp'; FileTargetPath: cSystemPath;
       IsRewrite: False; IsRegistered: False; IsShared: False; IsSearchDouble: True),
    (FileName: 'Microsoft\vbscript.dll'; FileTargetPath: cSystemPath;
       IsRewrite: False; IsRegistered: True; IsShared: True; IsSearchDouble: True),
    (FileName: 'Microsoft\jscript.dll'; FileTargetPath: cSystemPath;
       IsRewrite: False; IsRegistered: True; IsShared: True; IsSearchDouble: True)
  ); sty }
*)
  // »м€ файла дл€ деинстал€ции
  cUninstallFileName = 'install.exe';

  DatabaseBK = 'Database\etalon.bk';
(*
  DatabaseList: TDatabaseFileList = (
    (FileName: 'Database\excltbl.txt'; FileTargetPath: cDatabasePath;
       IsRewrite: False; IsRegistered: False; IsShared: False; IsSearchDouble: True),
    (FileName: 'Database\gdbase.ver'; FileTargetPath: cDatabasePath;
       IsRewrite: False; IsRegistered: False; IsShared: False; IsSearchDouble: True),
    (FileName: 'Database\mergtbl.txt'; FileTargetPath: cDatabasePath;
       IsRewrite: False; IsRegistered: False; IsShared: False; IsSearchDouble: True)
  );
*)
{const
  c1: array[0..1] of Integer = (1,2);
  c2: array[0..1] of Integer = (0,3);
var
  c3: array[0..3] of Integer = c1 + c2;}
implementation

end.
