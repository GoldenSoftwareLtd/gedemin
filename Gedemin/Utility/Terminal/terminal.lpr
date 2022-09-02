program terminal;

{$mode objfpc}{$H+}


uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Windows, Forms, mainform, LoginForm, SysUtils, MessageForm, Dialogs, FileUtil,
  JcfStringUtils, Classes, ShowOrder;

{$R *.res}
  {$IFNDEF SKORPIOX3}
  procedure scanEnable;
    stdcall; external 'scaner_dll.dll' name 'scanEnable';

  function isScanEnabled: Boolean;
    stdcall; external 'scaner_dll.dll' name 'isScanEnabled';

  procedure scanDisable;
    stdcall; external 'scaner_dll.dll' name 'scanDisable';

  function getParameter(nParameterIdentifier: Cardinal): Cardinal;
    stdcall; external 'scaner_dll.dll' name 'getParameter';

  procedure setParameter(nParameterIdentifier: Cardinal; Value: Cardinal);
    stdcall; external 'scaner_dll.dll' name 'setParameter';

  function init: Boolean;
    stdcall; external 'scaner_dll.dll' name 'init';

  procedure deinit;
    stdcall; external 'scaner_dll.dll' name 'init';
 {$ENDIF}

  procedure CheckFiles;
  const
    constfile = ';SHCODE_GOODS.txt;SHCODE_USERS.txt;SHCODE_DEPART.txt;ENDTRANSFER.txt;ALLTRANSFER.txt';
    path: array[0..2] of string  = ('\cl\', '\ov\', '\dl\');
  var
    I, intFileAge, retval: Integer;
    SRec: TSearchRec;
    Date: TDateTime;
    temps: String;
  begin
    for I := 0 to High(path) do
    begin
      temps := ExtractFilePath(Application.ExeName) + path[I];
      retval := FindFirst(temps + '*.*', faAnyFile, SRec);
      while retval = 0 Do
      begin
        intFileAge := FileAge(temps + SRec.name);
        date := TDate(FileDateToDateTime(intFileAge));
        if (date < TDate(now) - 1) and (StrIPos(';' + SRec.name + ';', constfile) = 0) then
          DeleteFile(temps + SRec.name);
        retval := FindNext(SRec);
      end;
      FindClose(SRec);
    end;
  end;

  procedure CheckLog;
  var
    FLGR: Integer;
    SL: TStringList;
    I: Integer;
  begin
    if FileExists(ExtractFilePath(Application.ExeName) + 'OPERATIONLOG.TXT') then
    begin
      FLGR := FileUtil.FileSize(ExtractFilePath(Application.ExeName) + 'OPERATIONLOG.TXT');
      if FLGR >= 3000000 then
      begin
        SL := TStringList.Create;
        try
          SL.LoadFromFile(ExtractFilePath(Application.ExeName) + 'OPERATIONLOG.TXT');
          for I := 0 to SL.Count div 2 do
            SL.Delete(0);
          SL.SaveToFile(ExtractFilePath(Application.ExeName) + 'OPERATIONLOG.TXT');
        finally
          SL.Free;
        end;
      end;
    end;
  end;

  function DoInit(var Log: String): Boolean;
  begin
    Result := True;

    {$IFNDEF SKORPIOX3}
    if not init() then
    begin
      Log := 'Устройство не инициализировано!';
      Result := False;
    end;
    {$ENDIF}
    if Result then
    begin
      if not FileExists(ExtractFilePath(Application.ExeName) + '\cl\SHCODE_USERS.TXT') then
      begin
        Log := 'Файл SHCODE_USERS.TXT не найден! Загрузите его на устройство!';
        Result := False;
      end else
      begin
        if not FileExists(ExtractFilePath(Application.ExeName) + '\cl\SHCODE_GOODS.TXT') then
        begin
          Log := 'Файл SHCODE_GOODS.TXT не найден! Загрузите его на устройство!';
          Result := False;
        end else
        begin
          if not FileExists(ExtractFilePath(Application.ExeName) + '\cl\SHCODE_DEPART.TXT') then
          begin
            Log := 'Файл SHCODE_DEPART.TXT не найден! Загрузите его на устройство!';
            Result := False;
          end;
        end;
      end;

      {$IFNDEF SKORPIOX3}
      if Result then
      begin
        setParameter(1, 0);
        setParameter(2, 0);
        scanEnable();

        if not isScanEnabled() then
        begin
          Log := 'Ошибка при включении!';
          Result := False;
        end;
      end;
      {$ENDIF}
    end;
  end;
var
  Log: String;
begin
  Application.Initialize;
  Log := '';
  if DoInit(Log) then
  begin
    CheckFiles;
    CheckLog;
    if TLoginForm.Execute2 then
    begin
      Application.CreateForm(TMainForm, FMainForm);
      Application.Run;
    end;
    {$IFNDEF SKORPIOX3}
    scanDisable();
    deinit();
    {$ENDIF}
  end else
    MessageForm.MessageDlg(Log, 'Внимание',
      mtInformation, [mbOk]);
end.

