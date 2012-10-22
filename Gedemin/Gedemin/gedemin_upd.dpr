program gedemin_upd;

{$APPTYPE CONSOLE}

uses
  Classes, Windows, SysUtils, gd_directories_const, JclFileUtils;

{$R gedemin_upd_ver.res}

var
  Terminating: Boolean;
  SL, Log: TStringList;
  MutexHandle: THandle;
  I: Integer;
  S, Cmd, FName, IniName: String;
  Res: Boolean;
  WaitState: DWORD;

function Ctrl_Handler(Ctrl: Longint): LongBool;
begin
  if Ctrl in [CTRL_SHUTDOWN_EVENT, CTRL_LOGOFF_EVENT] then
    Terminating := True;
  Result := true;
end;

begin
  Terminating := False;
  SetConsoleCtrlHandler(@Ctrl_Handler, True);

  MutexHandle := CreateMutex(nil, True, PChar(GedeminMutexName));
  try
    repeat
      WaitState := WaitForSingleObject(MutexHandle, INFINITE);

      if Terminating then
        break;

      case WaitState of
        WAIT_OBJECT_0:
        begin
          SL := TStringList.Create;
          Log := TStringList.Create;
          try
            IniName := ExtractFilePath(ParamStr(0)) + Gedemin_Updater_Ini;
            SL.LoadFromFile(IniName);
            for I := 0 to SL.Count - 1 do
            begin
              S := Trim(SL[I]);
              Log.Add(S);

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

                if Res then
                  Log.Add('Success!')
                else
                  Log.Add('Error!');
              except
                on E: Exception do
                  Log.Add('Error: ' + E.Message);
              end;
            end;
            DeleteFile(IniName);
            Log.SaveToFile(Gedemin_Updater_Log);
          finally
            Log.Free;
            SL.Free;
          end;
        end;

        WAIT_ABANDONED:
          ReleaseMutex(MutexHandle);
      end;
    until WaitState = WAIT_OBJECT_0;
  finally
    ReleaseMutex(MutexHandle);
    CloseHandle(MutexHandle);
  end;
end.
