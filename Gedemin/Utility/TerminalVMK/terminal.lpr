program terminal;

{$mode objfpc}{$H+}


uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Windows, Forms, mainform, LoginForm, SysUtils, MessageForm, Dialogs, FileUtil,
  JcfStringUtils, Classes, DCalendar;

{$R *.res}
  function MCScanInit: Integer;
    stdcall; external 'MCSSLib.dll' name 'MCScanInit';

  function MCScanRead: Integer;
    stdcall; external 'MCSSLib.dll' name 'MCScanRead';

  function MCScanReadCancel: Integer;
    stdcall; external 'MCSSLib.dll' name 'MCScanReadCancel';

  function MCScanClose: Integer;
    stdcall; external 'MCSSLib.dll' name 'MCScanClose';

  procedure MCRegisterWindow(hWnd: HWND);
    stdcall; external 'MCSSLib.dll' name 'MCRegisterWindow';

  procedure MCGetScanDataByte(szBarData: pbyte; szBarType: pbyte);
    stdcall; external 'MCSSLib.dll' name 'MCGetScanDataByte';

  procedure MCGetBarCodeType(szBarType: pointer);
    stdcall; external 'MCSSLib.dll' name 'MCGetBarCodeType';

  procedure MCSetBarCodeType(szBarType: pointer);
    stdcall; external 'MCSSLib.dll' name 'MCSetBarCodeType';

 type  TBarcodeType = record
    bMC_UPCA: byte;
    bMC_UPCA_ADDON: byte;
    bMC_UPCE: byte;
    bMC_EAN13: byte;
    bMC_EAN13_ADDON: byte;
    bMC_BOOKLAND: byte;
    bMC_EAN8: byte;
    bMC_CODE39: byte;
    bMC_CODE32: byte;
    bMC_PZN: byte;
    bMC_CODE128: byte;
    bMC_UCCEAN128: byte;
    bMC_CODE93: byte;
    bMC_CODE35: byte;
    bMC_CODE11: byte;
    bMC_I2OF5: byte;
    bMC_CODE25_ITF14: byte;
    bMC_CODE25_MATRIX: byte;
    bMC_CODE25_DLOGIC: byte;
    bMC_CODE25_INDUSTRY: byte;
    bMC_CODE25_IATA: byte;
    bMC_CODABAR: byte;
    bMC_COUPON: byte;
    bMC_MSI: byte;
    bMC_PLESSEY: byte;
    bMC_GS1: byte;
    bMC_GS1_LIMITED: byte;
    bMC_GS1_EXPANDED: byte;
    bMC_TELEPEN: byte;

  end;

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

  function CheckDate: Boolean;
  begin
    Result := false;
    if (date < StrToDate('01.01.2015') ) then
      begin
        if TDCalendar.Execute3 then
          begin
            Result := true;
          end
      end else
      begin
        Result := true;
      end;

  end;

  function DoInit(var Log: String): Boolean;
    var
      inres:integer;
      res: boolean;
      m: pChar ;
      TBT: TBarcodeType;
  begin
    Result := True;
    inres := MCScanInit();
      { if inres < 0 then
         begin
           Application.MessageBox( PChar('Устройство не инициализировано!' + IntToStr(inres)), '', 0);
         end;    }
     TBT.bMC_UPCA := 1;
     TBT.bMC_UPCA_ADDON := 1;
     TBT.bMC_UPCE := 1;
     TBT.bMC_EAN13 := 1;
     TBT.bMC_EAN13_ADDON := 1;
     TBT.bMC_BOOKLAND := 1;
     TBT.bMC_EAN8 := 1;
     TBT.bMC_CODE39 := 1;
     TBT.bMC_CODE32 := 1;
     TBT.bMC_PZN := 1;
     TBT.bMC_CODE128 := 1;
     TBT.bMC_UCCEAN128 := 1;
     TBT.bMC_CODE93 := 1;
     TBT.bMC_CODE35 := 1;
     TBT.bMC_CODE11 := 1;
     TBT.bMC_I2OF5 := 1;
     TBT.bMC_CODE25_ITF14 := 1;
     TBT.bMC_CODE25_MATRIX := 1;
     TBT.bMC_CODE25_DLOGIC := 1;
     TBT.bMC_CODE25_INDUSTRY := 1;
     TBT.bMC_CODE25_IATA := 1;
     TBT.bMC_CODABAR := 1;
     TBT.bMC_COUPON := 1;
     TBT.bMC_MSI := 1;
     TBT.bMC_PLESSEY := 1;
     TBT.bMC_GS1 := 1;
     TBT.bMC_GS1_LIMITED := 1;
     TBT.bMC_GS1_EXPANDED := 1;
     TBT.bMC_TELEPEN := 1;


    MCSetBarCodeType(@TBT);


    if inres < 0 then
    begin
      Log := 'Устройство не инициализировано!';
      Result := False;
    end;

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
    if Result then
      begin
        Result := CheckDate;
        if not Result then
        begin
           Log := 'Неправильно установлена системная дата. Выставьте правильно!';
        end;
      end;

   {   if Result then
      begin
        setParameter(1, 0);
        setParameter(2, 0);
        scanEnable();

        if not isScanEnabled() then
        begin
          Log := 'Ошибка при включении!';
          Result := False;
        end;
      end; }

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
  {  {$IFNDEF SKORPIOX3}
    scanDisable();
    deinit();
    {$ENDIF}     }
  end else
    MessageForm.MessageDlg(Log, 'Внимание',
      mtInformation, [mbOk]);
end.

