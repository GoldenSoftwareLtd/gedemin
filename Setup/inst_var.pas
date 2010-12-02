unit inst_var;

interface

uses
  inst_const, inst_files, gsGedeminInstall;

var
  vMainServerFileName,
  vMainGuardFileName,
  vMainClientFileName,
  vMainDatabaseFile,
{  vMainReportFile,
  vMainReportServiceFile, sty}
  vMainGedeminFile,
  vMainSettingPath: String;

  vCheckTCPIP,
  vSetSetting: Boolean;

  vServerName,
  vServerVersion,
  vIBServiceName,
  vIBGuardServiceName,
  vIBServiceDisplayName,
  vIBGuardServiceDisplayName,
  vLinkMainPath: String;

  vClientListCount,
  vServerListCount,
  vServerDllListCount,
  vGedeminListCount,
{  vReportListCount, sty}
  vDatabaseListCount: Integer;

  vClientList,
  vServerList,
  vServerDllList,
  vGedeminList,
{  vReportList, sty}
  vDatabaseList: PCustomFileList;

function CreateFileArray(const AnCount: Integer): Pointer;
procedure DestroyFileArray(var AnFileArray: PCustomFileList; var AnCount: Integer);

implementation

function CreateFileArray(const AnCount: Integer): Pointer;
begin
  GetMem(Result, SizeOf(TInstallFile) * AnCount);
  FillChar(Result^, SizeOf(TInstallFile) * AnCount, #0);
end;

procedure DestroyFileArray(var AnFileArray: PCustomFileList; var AnCount: Integer);
var
  I: Integer;
begin
  for I := 0 to AnCount - 1 do
  begin
    AnFileArray[I].FileName := '';
    AnFileArray[I].FileTargetPath := '';
    AnFileArray[I].LinkName := '';
  end;                             
  FreeMem(AnFileArray, SizeOf(TInstallFile) * AnCount);
  AnFileArray := nil;
  AnCount := 0;
end;

initialization

{  vClientList := CreateFileArray(2);
  DestroyFileArray(vClientList);}

  vMainServerFileName := cMainServerFileName;
  vMainGuardFileName := cMainGuardFileName;
  vMainClientFileName := cMainClientFileName;
  vMainDatabaseFile := cMainDatabaseFile;
{  vMainReportFile := cMainReportFile;
  vMainReportServiceFile := cMainReportServiceFile; sty}
  vMainGedeminFile := cMainGedeminFile;
  vMainSettingPath := cMainSettingPath;
  vLinkMainPath := cLinkMainPath;

  vCheckTCPIP := True;
  vSetSetting := False;

  vServerName := cServerName;
  vServerVersion := cServerVersion;
  vIBServiceName := cIBServiceName ;
  vIBGuardServiceName := cIBGuardServiceName;
  vIBServiceDisplayName := cIBServiceDisplayName;
  vIBGuardServiceDisplayName := cIBGuardServiceDisplayName;

{  vClientListCount := cClientListCount;
  vServerListCount := cServerListCount;
  vServerDllListCount := cServerDllListCount;
  vGedeminListCount := cGedeminListCount;
  vDatabaseListCount := cDatabaseListCount;}

  vClientList := nil;
  vServerList := nil;
  vServerDllList := nil;
  vGedeminList := nil;
  vDatabaseList := nil;
{  vClientList := @ClientList;
  vServerList := @ServerList;
  vServerDllList := @ServerDllList;
  vGedeminList := @GedeminList;
  vDatabaseList := @DatabaseList;}

finalization

  if Assigned(vClientList) {and (vClientList <> @ClientList) }then
    DestroyFileArray(vClientList, vClientListCount);
  if Assigned(vServerList) {and (vServerList <> @ServerList) }then
    DestroyFileArray(vServerList, vServerListCount);
  if Assigned(vGedeminList) {and (vGedeminList <> @GedeminList) }then
    DestroyFileArray(vGedeminList, vGedeminListCount);
{  if Assigned(vReportList) and (vReportList <> @ReportList) then
    DestroyFileArray(vReportList, vReportListCount); sty}
  if Assigned(vDatabaseList) {and (vDatabaseList <> @DatabaseList) }then
    DestroyFileArray(vDatabaseList, vDatabaseListCount);

end.
