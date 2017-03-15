program gedemin_upd;

{$APPTYPE CONSOLE}

uses
  Classes, Windows, SysUtils, gd_directories_const, JclFileUtils;

{$R gedemin_upd_ver.res}

var
  Terminating: Boolean;
  SL: TStringList;
  MutexHandle, GedProcHandle, LogHandle: THandle;
  I, LogType: Integer;
  S, Cmd, FName, IniName, GedName: String;
  GedProcID: DWORD;
  ss: array [0..0] of PChar;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;

function Ctrl_Handler(Ctrl: Longint): LongBool;
begin
  if Ctrl in [CTRL_SHUTDOWN_EVENT, CTRL_LOGOFF_EVENT] then
    Terminating := True;
  Result := True;
end;

begin
  if (ParamCount = 0) or (ParamStr(1) = '/?') or (ParamStr(1) = '-?') then
  begin
    Writeln('Gedemin Updater, v2.10');
    Writeln('Copyright (c) 2015-2017 by Golden Software of Belarus, Ltd');
    exit;
  end;

  Terminating := False;
  SetConsoleCtrlHandler(@Ctrl_Handler, True);

  if ParamCount > 0 then
  begin
    GedProcID := StrToIntDef(ParamStr(1), 0);
    if GedProcID > 0 then
    begin
      GedProcHandle := OpenProcess(SYNCHRONIZE, False, GedProcID);
      if GedProcHandle <> 0 then
      begin
        WaitForSingleObject(GedProcHandle, INFINITE);
        CloseHandle(GedProcHandle);
      end;
    end;
  end;

  if not Terminating then
  begin
    LogHandle := RegisterEventSource(nil, 'Gedemin Updater');
    MutexHandle := CreateMutex(nil, True, PChar(GedeminMutexName));
    try
      IniName := ExtractFilePath(ParamStr(0)) + Gedemin_Updater_Ini;
      if FileExists(IniName) and (WaitForSingleObject(MutexHandle, INFINITE) = WAIT_OBJECT_0)
        and (not Terminating) then
      try
        SL := TStringList.Create;
        try
          SL.LoadFromFile(IniName);

          for I := 0 to SL.Count - 1 do
          begin
            S := Trim(SL[I]);
            if S = '' then
              continue;

            Cmd := Copy(S, 1, 2);
            FName := Copy(S, 4, 1024);

            LogType := EVENTLOG_SUCCESS;
            ss[0] := PChar(S);
            try
              if Cmd = 'CD' then
              begin
                if not CreateDir(FName) then
                begin
                  LogType := EVENTLOG_ERROR_TYPE;
                  ss[0] := PChar('Can not create directory ' + FName);
                end;
              end
              else if Cmd = 'RD' then
              begin
                if not DelTree(FName) then
                begin
                  LogType := EVENTLOG_ERROR_TYPE;
                  ss[0] := PChar('Can not delete directory ' + FName);
                end;
              end
              else if Cmd = 'RF' then
              begin
                if not DeleteFile(FName) then
                begin
                  LogType := EVENTLOG_ERROR_TYPE;
                  ss[0] := PChar('Can not delete file ' + FName);
                end;
              end
              else if (Cmd = 'UF') or (Cmd = 'CF') then
              begin
                if not FileExists(FName + '.new') then
                begin
                  LogType := EVENTLOG_ERROR_TYPE;
                  ss[0] := PChar('File not found ' + FName + '.new');
                end
                else if not MoveFileEx(PChar(FName + '.new'), PChar(FName), MOVEFILE_REPLACE_EXISTING) then
                begin
                  Sleep(2000);
                  if not MoveFileEx(PChar(FName + '.new'), PChar(FName), MOVEFILE_REPLACE_EXISTING) then
                  begin
                    LogType := EVENTLOG_ERROR_TYPE;
                    ss[0] := PChar('Can not rename file ' + FName + '.new'#13#10 +
                      'Error code: ' + IntToStr(GetLastError));
                    if (not FileExists(FName)) and FileExists(FName + '.bak') then
                      MoveFileEx(PChar(FName + '.bak'), PChar(FName), 0);
                    DeleteFile(FName + '.new');
                  end;
                end
              end;
            except
              on E: Exception do
              begin
                LogType := EVENTLOG_ERROR_TYPE;
                ss[0] := PChar(E.Message);
              end;
            end;

            if LogHandle <> 0 then
              ReportEvent(LogHandle, LogType, 0, 0, nil, 1, 0, @ss, nil);
          end;
          DeleteFile(IniName);
        finally
          SL.Free;
        end;
      except
        on E: Exception do
        begin
          LogType := EVENTLOG_ERROR_TYPE;
          ss[0] := PChar(E.Message);
          if LogHandle <> 0 then
            ReportEvent(LogHandle, LogType, 0, 0, nil, 1, 0, @ss, nil);
        end;
      end;
    finally
      ReleaseMutex(MutexHandle);
      CloseHandle(MutexHandle);
      DeregisterEventSource(LogHandle);
    end;
  end;

  if (ParamCount > 5) and (UpperCase(ParamStr(2)) = '/R') then
  begin
    GedName := ExtractFilePath(ParamStr(0)) + ParamStr(3);
    FillChar(StartupInfo, SizeOf(TStartupInfo), #0);
    StartupInfo.cb := SizeOf(TStartupInfo);
    CreateProcess(PChar(GedName),
      PChar('"' + GedName + '" /user "' + ParamStr(4) + '" /password "' +
        ParamStr(5) + '" /sn "' + ParamStr(6) + '" /ns /reload'),
      nil, nil, False, NORMAL_PRIORITY_CLASS, nil, nil,
      StartupInfo, ProcessInfo);
  end;
end.
