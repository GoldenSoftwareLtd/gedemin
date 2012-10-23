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
  Res: Boolean;
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

            Res := False;
            try
              if Cmd = 'CD' then
                Res := CreateDir(FName)
              else if Cmd = 'RD' then
                Res := DelTree(FName)
              else if Cmd = 'CF' then
                Res := RenameFile(FName + '.new', FName)
              else if Cmd = 'RF' then
                Res := DeleteFile(FName)
              else if Cmd = 'UF' then
              begin
                Res := FileExists(FName + '.new');
                if Res then Res := DeleteFile(FName);
                if Res then Res := RenameFile(FName + '.new', FName);
              end;

              ss[0] := PChar(S);
              if Res then LogType := EVENTLOG_SUCCESS
                else LogType := EVENTLOG_ERROR_TYPE;
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
