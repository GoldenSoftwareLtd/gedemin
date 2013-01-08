unit gd_ExternalEditor;

interface

uses
  Classes;

procedure InvokeExternalEditor(const ALang: String; S: TStrings);

implementation

uses
  Windows, SysUtils, gd_GlobalParams_unit;

procedure InvokeExternalEditor(const ALang: String; S: TStrings);
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  FName, FTemp: String;
  TempPath: array[0..1023] of Char;
  TempFileName: array[0..1023] of Char;
begin
  Assert(S <> nil);

  FName := gd_GlobalParams.GetExternalEditor(ALang);

  if FName = '' then
    raise Exception.Create('В файле настроек gedemin.ini не определен ' +
      'внешний редактор для языка "' + ALang + '".');

  if (GetTempPath(SizeOf(TempPath), TempPath) = 0) or
    (GetTempFileName(TempPath, 'gd', 0, TempFileName) = 0) then
  begin
    raise Exception.Create('Ошибка при определении имени временного файла. ' +
      SysErrorMessage(GetLastError));
  end;

  FTemp := ChangeFileExt(TempFileName, '.' + ALang);

  S.SaveToFile(FTemp);
  try
    FillChar(StartupInfo, SizeOf(TStartupInfo), #0);
    StartupInfo.cb := SizeOf(TStartupInfo);
    if not CreateProcess(nil,
      PChar(FName + ' "' + FTemp + '"'),
      nil, nil, False, NORMAL_PRIORITY_CLASS, nil, nil,
      StartupInfo, ProcessInfo) then
    begin
      raise Exception.Create('Ошибка при запуске внешнего редактора.'#13#10 +
        'Командная строка: ' + FName + #13#10 +
        SysErrorMessage(GetLastError));
    end;

    WaitForSingleObject(ProcessInfo.hProcess, INFINITE);

    S.LoadFromFile(FTemp);
  finally
    DeleteFile(FTemp);
  end;
end;


end.