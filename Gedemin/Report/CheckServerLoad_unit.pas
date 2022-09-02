// ShlTanya, 26.02.2019

unit CheckServerLoad_unit;

interface

uses
  Windows, Classes, SysUtils;

const
  ReportServerMutexName = 'REPORTSERVER_MUTEX';
  Long_False = 0;
  Long_True = 1;
  Long_Disable = 2;

function GetServerWindow: THandle;
function CheckReportServerActivate: Word;

implementation

function GetServerWindow: THandle;
begin
  Result := FindWindowEx(0, 0, 'TUnvisibleForm', 'Сервер отчетов для Gedemin');
end;

function CheckReportServerActivate: Word;
var
  Hnd: THandle;
begin
  Result := Long_False;
  SetLastError(0);
  Hnd := OpenMutex(MUTEX_ALL_ACCESS, False, ReportServerMutexName);
  if Hnd <> 0 then
  begin
    CloseHandle(Hnd);
    Result := Long_True;
  end else
    // ERROR_FILE_NOT_FOUND
    if GetLastError = ERROR_ACCESS_DENIED then
      Result := Long_Disable;
end;

end.

