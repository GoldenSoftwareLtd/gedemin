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
  S, Cmd, FName, IniName: String;
  GedProcID: DWORD;
  ss: array [0..0] of PChar;

function Ctrl_Handler(Ctrl: Longint): LongBool;
begin
  if Ctrl in [CTRL_SHUTDOWN_EVENT, CTRL_LOGOFF_EVENT] then
    Terminating := True;
  Result := True;
end;

begin
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
      if (WaitForSingleObject(MutexHandle, INFINITE) = WAIT_OBJECT_0)
        and (not Terminating) then
      try
        SL := TStringList.Create;
        try
          IniName := ExtractFilePath(ParamStr(0)) + Gedemin_Updater_Ini;

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
              else if Cmd = 'CF' then
              begin
                if not FileExists(FName + '.new') then
                begin
                  LogType := EVENTLOG_ERROR_TYPE;
                  ss[0] := PChar('File not found ' + FName + '.new');
                end
                else if not RenameFile(FName + '.new', FName) then
                begin
                  LogType := EVENTLOG_ERROR_TYPE;
                  ss[0] := PChar('Can not rename file ' + FName + '.new');
                end
              end
              else if Cmd = 'RF' then
              begin
                if not DeleteFile(FName) then
                begin
                  LogType := EVENTLOG_ERROR_TYPE;
                  ss[0] := PChar('Can not delete file ' + FName);
                end;
              end
              else if Cmd = 'UF' then
              begin
                if not FileExists(FName + '.new') then
                begin
                  LogType := EVENTLOG_ERROR_TYPE;
                  ss[0] := PChar('File not found ' + FName + '.new');
                end
                else if FileExists(FName) and (not DeleteFile(FName)) then
                begin
                  LogType := EVENTLOG_ERROR_TYPE;
                  ss[0] := PChar('Can not delete file ' + FName);
                end
                else if not RenameFile(FName + '.new', FName) then
                begin
                  LogType := EVENTLOG_ERROR_TYPE;
                  ss[0] := PChar('Can not rename file ' + FName + '.new');
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
end.
