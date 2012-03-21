unit dmLogin_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_security_body, syn_ManagerInterface_body_unit, gdcBase,
  gsDesktopManager, IBDatabase, flt_ScriptInterface_body,
  prm_ParamFunctions_unit, FileCtrl, gd_resourcestring;

type
  TLoginType = (ltQuery, ltSilent, ltSingle, ltMulti, ltSingleSilent, ltMultiSilent);

type
  TdmLogin = class(TDataModule)
    boLogin: TboLogin;
    smMain: TSynManager;
    gdcBaseManager: TgdcBaseManager;
    gsDesktopManager: TgsDesktopManager;
    prmGlobalDlg1: TprmGlobalDlg;
    ibtrAttr: TIBTransaction;
    ibtrGlobalDlg: TIBTransaction;
    procedure boLoginAfterSuccessfullConnection(Sender: TObject);
    procedure boLoginAfterChangeCompany(Sender: TObject);
    procedure boLoginBeforeDisconnect(Sender: TObject);
    procedure boLoginBeforeChangeCompany(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure prmGlobalDlg1DlgCreate(const AnFirstKey,
      AnSecondKey: Integer; const AnParamList: TgsParamList;
      var AnResult: Boolean; const AShowDlg: Boolean = True;
      const AFormName: string = ''; const AFilterName: string = '');

  private
    FSystemConnect: Boolean;

  public
    constructor CreateAndConnect(AOwner: TComponent; const ALoginType: TLoginType;
      const AUser: String = ''; const APassword: String = ''; const ADBPath: string = '');

//    procedure LoadSettings(const AnFirstStart: Boolean = True);
    procedure LoadSettings;
  end;

var
  dmLogin: TdmLogin;
  UserParamExists: Boolean;
  PasswordParamExists: Boolean;
  LoadSettingPath: String;
  LoadSettingFileName: String;
  
implementation

uses
  dmDataBase_unit,              gd_security,           gd_CmdLineParams_unit,
  gd_security_operationconst,   gd_RegionalSettings,   syn_ManagerInterface_unit,
  gsTrayIconInterface,          Storages,              at_classes,
  at_classes_body,              flt_dlg_dlgQueryParam_unit,
  rp_BaseReport_unit,           gd_splash,             gsStorage,
  Registry,                     inst_const,            gdcSetting,
  gdcBaseInterface,             dm_i_ClientReport_unit,
  prp_PropertySettings,         gd_i_ScriptFactory,    flt_sqlFilterCache,

  {$IFDEF LOCALIZATION}
  gd_localization,
  gd_localization_stub,
  {$ENDIF}

  IBSQL;

{$R *.DFM}

procedure TdmLogin.boLoginAfterSuccessfullConnection(Sender: TObject);
var
{$IFDEF DEBUG}
  T: TDateTime;
{$ENDIF}
  MS: TMemoryStream;
  R: OleVariant;
begin
  gdcBase.CacheDBID := -1;

  {$IFDEF DEBUG}
  T := Now;
  {$ENDIF}
  if Assigned(GlobalStorage) then
  begin
    if Assigned(gdSplash) then
      gdSplash.ShowText(sLoadingGlobalStorage);
    GlobalStorage.LoadFromDataBase;
  end;
  {$IFDEF DEBUG}
    OutputDebugString(PChar('GlobalStorage: ' + FormatDateTime('s.z', Now - T)));
    T := Now;
  {$ENDIF}
  if Assigned(UserStorage) then
  begin
    if Assigned(gdSplash) then
      gdSplash.ShowText(sLoadingUserStorage);
    UserStorage.ObjectKey := IBLogin.UserKey;
  end;

  {$IFDEF DEBUG}
    OutputDebugString(PChar('UserStorage: ' + FormatDateTime('s.z', Now - T)));
  {$ENDIF}

  // Мы отказываемся от использования раздельных системных настроек
  // внутри Гедымина
  LoadSystemLocalSettingsIntoDelphiVars;

  if Pos('dd.mm.yy', AnsiLowerCase(ShortDateFormat)) <> 1 then
  begin
    MessageBox(0,
      'Для корректной работы программы необходимо, чтобы короткий формат даты'#13#10 +
      'соответствовал шаблону дд.мм.гг или дд.мм.гггг.'#13#10#13#10 +
      'Установить формат даты можно в разделе Исследователь->Сервис->Региональные установки'#13#10 +
      'или в настройках операционной системы.'#13#10#13#10 +
      'Рекомендуется установить формат даты в операционной системе,'#13#10 +
      'а в региональных установках системы Гедымин отметить флаг "Использовать'#13#10 +
      'системные настройки".'#13#10#13#10 +
      'Для текущего сеанса работы будет использоваться формат дд.мм.гг.',
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    ShortDateFormat := 'dd.mm.yy';
  end;

  try
    if Assigned(UserStorage) then
      if UserStorage.ValueExists(SM_SYNC_PATH, 'DATA') and Assigned(SynManager) then
      begin
        MS := TMemoryStream.Create;
        try
          UserStorage.ReadStream(SM_SYNC_PATH, 'DATA', MS);
          MS.Position := 0;
          try
            SynManager.LoadFromStream(MS);
          except
            //если не удалось прочитать, то скинем по-умолчанию (удалим)
            UserStorage.DeleteValue(SM_SYNC_PATH, 'DATA', False);
          end;
        finally
          MS.Free;
        end;
      end;
  except
    {$IFDEF DEBUG}
    on E: Exception do
      MessageBox(0, PChar('Произошел сбой при попытке прочитать настройки скрипта.' +
       E.Message), 'Ошибка', MB_OK or MB_ICONERROR or MB_TASKMODAL);
    {$ENDIF}
  end;

  {$IFNDEF DEPARTMENT}
  // Запуск настроек
  if not FSystemConnect then
    LoadSettings;
  {$ENDIF}

  if dm_i_ClientReport <> nil then
  begin
    if Assigned(gdSplash) then
      gdSplash.ShowText(sInitMacrosSystem);

    PropertySettings := prp_PropertySettings.LoadSettings;
    if Assigned(ScriptFactory) then
      ScriptFactory.ExceptionFlags := PropertySettings.Exceptions;
  end;

  if (not GlobalStorage.ReadBoolean('Options', 'MultipleConnect', True))
    and (not IBLogin.IsIBUserAdmin) then
  begin
    gdcBaseManager.ExecSingleQueryResult(
      'SELECT FIRST 1 mon$remote_address FROM mon$attachments ' +
      'WHERE mon$attachment_id <> CURRENT_CONNECTION AND mon$user = CURRENT_USER',
      0, R);
    if not VarIsEmpty(R)then
    begin
      MessageBox(0,
        PChar(
          'С IP адреса ' + String(R[0, 0]) + ' уже выполнено'#13#10 +
          'подключение под данной учетной записью.'#13#10#13#10 +
          'Системными установками вторичные подключения запрещены.'),
        'Внимание',
        MB_OK or MB_ICONHAND or MB_TASKMODAL);
      Application.Terminate;
    end;
  end;
end;

procedure TdmLogin.boLoginAfterChangeCompany(Sender: TObject);
begin
  {.$IFDEF GEDEMIN}
  CompanyStorage.ObjectKey := IBLogin.CompanyKey;
  if TrayIcon <> nil then TrayIcon.ToolTip := IBLogin.CompanyName;
  {.$ENDIF}
end;

procedure TdmLogin.boLoginBeforeDisconnect(Sender: TObject);
begin
  //TipTop: Перенесено 01.04.2003
  SaveStorages;

  gdcBase.CacheDBID := -1;

  flt_sqlFilterCache.SaveCacheToDatabase;

  if Assigned(gdcBaseManager) then
    gdcBaseManager.ClearSecDescArr;
end;

procedure TdmLogin.boLoginBeforeChangeCompany(Sender: TObject);
begin
  {.$IFDEF GEDEMIN}
  if Assigned(CompanyStorage) then
    CompanyStorage.SaveToDataBase;
  {.$ENDIF}
end;

procedure TdmLogin.DataModuleCreate(Sender: TObject);
var
  ICp: ICompanyChangeNotify;
  ICn: IConnectChangeNotify;
begin
  {$IFDEF LOCALIZATION}
  LocalizationInitParams;
  {$ENDIF}

  FSystemConnect := False;
  ICp := nil;
  ICn := nil;
  // Здесь проверка потому, что подключение может уже произойти,
  // если приложение создано как COM-сервер
  try
    if Application.MainForm <> nil then
    begin
      if Application.MainForm.GetInterface(ICompanyChangeNotify, ICp) then
        IBLogin.AddCompanyNotify(ICp);
      if Application.MainForm.GetInterface(IConnectChangeNotify, ICn) then
        IBLogin.AddConnectNotify(ICn);
    end;

    if not IBLogin.LoggedIn then
    begin
      IBLogin.SubSystemKey := GD_SYS_GADMIN;

      // теперь программа загрузится и без подключения к
      // базе данных. например, если надо сначала распаковать файл
      // с базой, а потом к нему подключаться
      if not IBLogin.IsSilentLogin then
      try
        if not IBLogin.Login then
        begin
          if gd_CmdLineParams.QuietMode or
            (MessageBox(0,
            'Подключение к базе данных не было осуществлено.'#13#10 +
            'Продолжить загрузку программы?',
            'Внимание',
            MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDNO) then
          begin
            Application.Terminate;
          end;
        end;
      except
        on E: Exception do
        begin
          Application.ShowException(E);
          Application.Terminate;
        end;
      end;
    end
    else if Application.MainForm <> nil then
    begin
      if ICn <> nil then
        ICn.DoAfterSuccessfullConnection;
      if ICp <> nil then
        ICp.DoAfterChangeCompany;
    end;
  except
    on E: Exception do
      Application.HandleException(E);
  end;
end;

procedure TdmLogin.prmGlobalDlg1DlgCreate(const AnFirstKey,
  AnSecondKey: Integer; const AnParamList: TgsParamList;
  var AnResult: Boolean; const AShowDlg: Boolean = True;
  const AFormName: string = ''; const AFilterName: string = '');

var
  FDlgForm: TdlgQueryParam;
  MS: TMemoryStream;
  VS: TVarStream;
  TempVar: Variant;
  DidActivate: Boolean;
begin
  FDlgForm := TdlgQueryParam.Create(nil);

  if (AFormName > '') or (AFilterName > '') then
  begin
    FDlgForm.lblFormName.Caption:= 'Объект: ' + AFormName;
    FDlgForm.lblFilterName.Caption:= 'Фильтр: ' + AFilterName;
    FDlgForm.pnlName.Visible:= True;
    FDlgForm.Height:= 94;
  end
  else begin
    FDlgForm.pnlName.Visible:= False;
    FDlgForm.Height:= 64;
  end;

  try
    MS := TMemoryStream.Create;
    try

      if UserStorage.ValueExists(LocFilterFolderName + IntToStr(AnFirstKey), IntToStr(AnSecondKey), False) then
      begin
        UserStorage.ReadStream(LocFilterFolderName + IntToStr(AnFirstKey), IntToStr(AnSecondKey), MS, False);
        //MS.Position := 0;
        VS := TVarStream.Create(MS);
        try
          VS.Read(TempVar);
        finally
          VS.Free;
        end;
      end;

      AnParamList.SetVariantArray(TempVar);

      if AShowDlg or (VarType(TempVar) = varEmpty) then
      begin
        FDlgForm.FDatabase := dmDatabase.ibdbGAdmin;
        FDlgForm.FTransaction := ibtrGlobalDlg;
        if not ibtrGlobalDlg.InTransaction then
        begin
          ibtrGlobalDlg.StartTransaction;
          DidActivate := True;
        end else
          DidActivate := False;
        try
          AnResult := FDlgForm.QueryParams(AnParamList);
          try
            if AnResult then
            begin
              TempVar := AnParamList.GetVariantArray;
              MS.Clear;
              VS := TVarStream.Create(MS);
              try
                VS.Write(TempVar);
              finally
                VS.Free;
              end;
              MS.Position := 0;
              UserStorage.WriteStream(LocFilterFolderName + IntToStr(AnFirstKey), IntToStr(AnSecondKey), MS);
            end;
          except
            // Нам до звезды запишет оно или нет
          end;
        finally
          if DidActivate and ibtrGlobalDlg.InTransaction then
            ibtrGlobalDlg.Commit;
        end;
      end else
        AnResult := True;

    finally
      MS.Free;
    end;

  finally
    FDlgForm.Free;
  end;
end;

constructor TdmLogin.CreateAndConnect(AOwner: TComponent;
  const ALoginType: TLoginType; const AUser, APassword, ADBPath: String);
begin
  Assert(dmLogin = nil, 'dmLogin уже создан');

  // Обязательное условие корректной работы
  // Задание его непосредственно в коде не помогает
  // Должно быть присвоено в .dfm файле
  //OldCreateOrder := False;

  inherited Create(AOwner);

  // Присваиваем значение глобальной переменной,
  // т.к. это надо сделать до подключения
  dmLogin := Self;

  // Подключаемся к базе здесь, потому что это надо сделать до вызова OnCreate
  IBLogin.SubSystemKey := GD_SYS_GADMIN;
  case ALoginType of
    ltQuery: IBLogin.Login;
    ltSilent: IBLogin.LoginSilent(AUser, APassword, ADBPath);
    ltSingle: IBLogin.LoginSingle;
    ltMulti: IBLogin.BringOnLine;
    ltSingleSilent: Assert(False, 'Тип подключения ltSingleSilent не поддерживается');
    ltMultiSilent: Assert(False, 'Тип подключения ltMultiSilent не поддерживается');
  else
    Assert(False, 'Неизвестный тип подключения');
  end
end;

procedure TdmLogin.LoadSettings;
var
  AllGSFList: TGSFList;
  i: Integer;
  gdcSetting: TgdcSetting;
  isFound: Boolean;
begin
  if (LoadSettingFileName > '') then
    if
     UserParamExists and
     PasswordParamExists and
     FileExists(LoadSettingFileName) and
     DirectoryExists(LoadSettingPath) then
    begin
      gdcSetting := TgdcSetting.Create(nil);
      gdcSetting.Subset := 'ByID';
      AllGSFList := TGSFList.Create;
      try
        AllGSFList.gdcSetts := gdcSetting;
        AllGSFList.isYesToAll := True;           // YesToAll на запросы
        AllGSFList.GetFilesForPath({ExtractFilePath(}LoadSettingPath{)});
        AllGSFList.LoadPackageInfo;

        isFound := False;
        for i := 0 to AllGSFList.Count-1 do
          if ( AnsiCompareText((AllGSFList.Objects[i] as TGSFHeader).FilePath, ExtractFilePath(LoadSettingFileName)) = 0 ) and
             ( AnsiCompareText((AllGSFList.Objects[i] as TGSFHeader).FileName, ExtractFileName(LoadSettingFileName)) = 0 ) then
          begin
            isFound := True;
            Break;
          end;
        if isFound then      // пакет найден
        begin
          if (AllGSFList.Objects[i] as TGSFHeader).FullCorrect then  // и корректен
          begin
            AllGSFList.InstallPackage(i, True);
            AllGSFList.ActivatePackages;
            LoadSettingFileName := ''; // иначе после переподключения снова начнет устанавливать
          end else
          with (AllGSFList.Objects[i] as TGSFHeader) do
          begin
            if not CorrectPack then
              MessageBox(0, 'Пакет некорректен!', 'Gedemin', MB_OK or MB_ICONERROR or MB_TASKMODAL) else
            if avNotApprEXEVersion in ApprVersion then
              MessageBox(0, 'Пакет не подходит по версии исполняемого модуля!', 'Gedemin', MB_OK or MB_ICONERROR or MB_TASKMODAL) else
            if avNotApprDBVersion in ApprVersion then
              MessageBox(0, 'Пакет не подходит по версии базы данных!', 'Gedemin', MB_OK or MB_ICONERROR or MB_TASKMODAL) else
          end
        end
        else begin
          MessageBox(0,
            PChar('Пакет "' + LoadSettingFileName + '" не найден!'),
            'Гедымин',
            MB_OK or MB_ICONERROR or MB_TASKMODAL);
        end;

      finally
        AllGSFList.Free;
        gdcSetting.Free;
      end;

      Application.Terminate;
    end else
    begin
      if UserParamExists and PasswordParamExists then
      begin
        if not FileExists(LoadSettingFileName) then
          MessageBox(0, PChar('Файл ' + LoadSettingFileName + ' не найден!'), 'Gedemin', MB_OK or MB_ICONERROR or MB_TASKMODAL);
        if not DirectoryExists(LoadSettingPath) then
          MessageBox(0, PChar('Путь ' + LoadSettingPath + ' не найден!'), 'Gedemin', MB_OK or MB_ICONERROR or MB_TASKMODAL);
      end;
    end;
end;

(*
procedure TdmLogin.LoadSettings(const AnFirstStart: Boolean = True);
const
  cFirststart = 0;
  cDisable = 1;
  cDontShow = 2;
  cComplete = 3;
var
  ibsqlSetting: TIBSQL;
  K: Integer;
  S: String;
  SettingName: String;
  Reg: TRegistry;
  Breaked: Boolean;
  SL, SourceList: TStrings;
  SettingStorage: TIniSettingsStorage;
  SetRUID: TRUID;
  gdcAllSetting: TgdcSetting;

  procedure ActivateSettings(AnList: TStrings; AnSettings: TIniSettingsStorage);
  var
    I, J{, L}: Integer;
    gdcSetting: TgdcSetting;
    TempFileName: String;
    OldSettingList, NewSettingList: TStrings;
  begin
    gdcSetting := TgdcSetting.Create(nil);
    try
      FSystemConnect := True;

      OldSettingList := TStringList.Create;
      try
        NewSettingList := TStringList.Create;
        try
          for I := 0 to AnList.Count - 1 do
            for J := 0 to AnSettings.Count - 1 do
              if AnList[I] = AnSettings.Setting[J].RUID then
              begin
                TempFileName := AnSettings.Setting[J].FullFileName;
                // Проверяем существование файла и запрашиваем путь если не находим
                if not FileExists(TempFileName) then
                begin
                  MessageBox(Application.Handle, PChar('Не удалось обнаружить файл ' +
                   TempFileName + ' выберите его вручную.'), 'Внимание', MB_OK or MB_ICONWARNING);
                  while not FileExists(SettingName) do
                  begin
                    with TOpenDialog.Create(nil) do
                    try
                      InitialDir := ExtractFileDir(TempFileName);
                      Filter := TempFileName + '|' + TempFileName;
                      Breaked := not Execute;
                      if Execute then
                        TempFileName := FileName
                      else
                        raise Exception.Create('Файл ' + TempFileName + ' не найден');
                    finally
                      Free;
                    end;
                  end;
                end;
                // Сохраняем список
                gdcSetting.SubSet := 'All';
                gdcSetting.Open;
{                gdcSetting.First;
                OldSettingList.Clear;
                while not gdcSetting.Eof do
                begin
                  OldSettingList.Add(gdcSetting.FieldByName('id').AsString);
                  gdcSetting.Next;
                end;}
                // Загружаем настройку
                gdcSetting.LoadFromFile(TempFileName);
                // Проверка ошибки
                if Assigned(frmSQLProcess) then
                begin
                  if frmSQLProcess.Visible then
                    frmSQLProcess.Hide;
                  if frmSQLProcess.IsError then
                    raise Exception.Create('Ошибка при загрузке настройки ' +
                      AnSettings.Setting[J].RUID);
                end;
                // Получаем ключи новых настроек
                gdcSetting.Close;
                gdcSetting.Open;
                gdcSetting.First;
//                NewSettingList.Clear;
                SetRUID := StrToRUID(AnSettings.Setting[J].RUID);
                NewSettingList.Add(IntToStr(gdcBaseManager.GetIDByRUID(SetRUID.XID, SetRUID.DBID)));
{ TODO -oJKL -cSetting :
Если в одну настройку включены другие, то будет активирована
только главная, т.к. никто не возвращает RUIDы считанных объектов. }
{                while not gdcSetting.Eof do
                begin
                  if (OldSettingList.IndexOf(gdcSetting.FieldByName('id').AsString) = -1) and
                   (NewSettingList.IndexOf(gdcSetting.FieldByName('id').AsString) = -1) then
                    NewSettingList.Add(gdcSetting.FieldByName('id').AsString);
                  gdcSetting.Next;
                end;
                gdcSetting.Close;
                // Активируем настройки
                gdcSetting.SubSet := 'ByID';
                gdcSetting.ID := -1;
                gdcSetting.Open;
                for L := 0 to NewSettingList.Count - 1 do
                begin
                  gdcSetting.ID := StrToInt(NewSettingList[L]);

                  gdcSetting.ActivateSetting(nil, nil, False);
                  // Проверка ошибки
                  if Assigned(frmSQLProcess) then
                  begin
                    if frmSQLProcess.Visible then
                      frmSQLProcess.Hide;
                    if frmSQLProcess.IsError then
                      raise Exception.Create('Ошибка при активизации настройки ' +
                        AnSettings.Setting[J].RUID);
                  end;
                end;}

                Break;
              end;

          if NewSettingList.Count > 0 then
          begin
            gdcSetting.SubSet := 'ByID';
            gdcSetting.ActivateSetting(NewSettingList, nil, False);
            gdcSetting.Open;
            // Проверка ошибки
            if Assigned(frmSQLProcess) then
            begin
              if frmSQLProcess.Visible then
                frmSQLProcess.Hide;
              if frmSQLProcess.IsError then
                raise Exception.Create('Ошибка при активизации настройки '{ +
                  AnSettings.Setting[J].RUID});
            end;
          end;
        finally
          NewSettingList.Free;
        end;
      finally
        OldSettingList.Free;
      end;
    finally
      gdcSetting.Free;
      FSystemConnect := False;
    end;
  end;
begin
  if FSystemConnect then
    Exit;

  // Проверка необходимости запуска
  ibsqlSetting := TIBSQL.Create(nil);
  try
    ibsqlSetting.Transaction := TIBTransaction.Create(nil);
    try
      ibsqlSetting.Transaction.DefaultDatabase := IBLogin.Database;
      ibsqlSetting.Transaction.StartTransaction;
      ibsqlSetting.Database := IBLogin.Database;
      ibsqlSetting.GoToFirstRecordOnExecute := True;
      ibsqlSetting.SQL.Text :=
        'SELECT rdb$relation_name FROM rdb$relations WHERE rdb$relation_name = ''ST_SETTINGSTATE''';
      ibsqlSetting.ExecQuery;
      if not ibsqlSetting.Eof then
      begin
        ibsqlSetting.Close;
        ibsqlSetting.SQL.Text := 'SELECT * FROM st_settingstate ORDER BY statedate DESC';
        ibsqlSetting.ExecQuery;

        if not ibsqlSetting.Eof and AnFirstStart then
          K := ibsqlSetting.FieldByName('status').AsInteger
        else
          K := cFirststart;

        S := 'Gedemin user: ' + IBLogin.UserName +
         '; WindowsUser: ' + GetUserNameString +
         '; ComputerName: ' + GetComputerNameString;

        case K of
          // 0
          cFirststart: begin
            with TdlgSetSetting.Create(nil) do
            try
              case Execute(AnFirstStart) of
                stYes:
                try
                  ibsqlSetting.Close;
                  ibsqlSetting.SQL.Text := 'INSERT INTO st_settingstate ' +
                   '(STATUS, COMMENT) VALUES(:STATUS, :COMMENT)';
                  ibsqlSetting.ParamByName('status').AsInteger := cDisable;
                  ibsqlSetting.ParamByName('comment').AsString := S;
                  ibsqlSetting.ExecQuery;
                  ibsqlSetting.Transaction.Commit;

                  Reg := TRegistry.Create(KEY_READ);
                  try
                    Reg.RootKey := HKEY_LOCAL_MACHINE;
                    if Reg.OpenKeyReadOnly(cSettingRegPath) then
                    begin
                      SettingName := Reg.ReadString(cSettingIni);
                      Reg.CloseKey;
                    end;
                  finally
                    Reg.Free;
                  end;

                  Breaked := False;
                  while not FileExists(SettingName) and not Breaked do
                  begin
                    MessageBox(Application.Handle, 'Не удалось обнаружить файл ' +
                     cMainSettingFile + '. Выберите его вручную' , 'Внимание', MB_OK or MB_ICONWARNING);
                    with TOpenDialog.Create(Application) do
                    try
                      InitialDir := ExtractFileDir(SettingName);
                      Filter := cMainSettingFile + '|' + cMainSettingFile;
                      Breaked := not Execute;
                      if not Breaked then
                        SettingName := FileName;
                    finally
                      Free;
                    end;
                  end;

                  if Breaked then
                    raise EAbort.Create('Файл ' + cMainSettingFile + ' не найден.');

                  SettingStorage := TIniSettingsStorage.Create;
                  try
                    SettingStorage.IniName := SettingName;
                    SettingStorage.ReadFromIni;
                    SL := TStringList.Create;
                    try
                      SourceList := TStringList.Create;
                      try
                        gdcAllSetting := TgdcSetting.Create(nil);
                        try
                          gdcAllSetting.SubSet := 'All';
                          gdcAllSetting.Open;
                          gdcAllSetting.First;
                          while not gdcAllSetting.Eof do
                          begin
                            gdcBaseManager.GetFullRUIDByID(gdcAllSetting.FieldByName('id').AsInteger,
                             SetRUID.XID, SetRUID.DBID);
                            SourceList.Add(RUIDToStr(SetRUID));

                            gdcAllSetting.Next;
                          end;

                          SL.Assign(SourceList);

                          if SettingStorage.SelectSettings(SL) then
                          begin
                            if SL.Count = 0 then
                              raise EAbort.Create('Не выбрано ни одной настройки.');
                            SettingStorage.ExtractSortQueue(SL, SourceList);
                            ActivateSettings(SL, SettingStorage);
                          end else
                            raise EAbort.Create('Пользователь не выбрал настройки.');
                        finally
                          gdcAllSetting.Free;
                        end;
                      finally
                        SourceList.Free;
                      end;
                    finally
                      SL.Free;
                    end;
                  finally
                    SettingStorage.Free;
                  end;

                  ibsqlSetting.Transaction.StartTransaction;
                  ibsqlSetting.Close;
                  ibsqlSetting.SQL.Text := 'INSERT INTO st_settingstate ' +
                   '(STATUS, COMMENT) VALUES(:STATUS, :COMMENT)';
                  ibsqlSetting.ParamByName('status').AsInteger := cComplete;
                  ibsqlSetting.ParamByName('comment').AsString := S;
                  ibsqlSetting.ExecQuery;
                  ibsqlSetting.Transaction.Commit;

                  MessageBox(Application.Handle, 'Настройки загружены успешно.',
                   'Внимание', MB_OK or MB_ICONINFORMATION);
                except
                  on E: EAbort do
                  begin
                    ibsqlSetting.Transaction.StartTransaction;
                    ibsqlSetting.Close;
                    ibsqlSetting.SQL.Text := 'INSERT INTO st_settingstate ' +
                     '(STATUS, COMMENT) VALUES(:STATUS, :COMMENT)';
                    if AnFirstStart then
                      ibsqlSetting.ParamByName('status').AsInteger := cFirststart
                    else
                      ibsqlSetting.ParamByName('status').AsInteger := cComplete;
                    ibsqlSetting.ParamByName('comment').AsString := S;
                    ibsqlSetting.ExecQuery;
                    ibsqlSetting.Transaction.Commit;
                    if AnFirstStart then
                      MessageBox(Application.Handle, PChar('Gedemin будет загружен без настроек. ' +
                       E.Message), 'Ошибка', MB_OK or MB_ICONWARNING);
                  end;
                  on E: Exception do
                  begin
                    ibsqlSetting.Transaction.StartTransaction;
                    ibsqlSetting.Close;
                    ibsqlSetting.SQL.Text := 'INSERT INTO st_settingstate ' +
                     '(STATUS, COMMENT) VALUES(:STATUS, :COMMENT)';
                    if AnFirstStart then
                      ibsqlSetting.ParamByName('status').AsInteger := cFirststart
                    else
                      ibsqlSetting.ParamByName('status').AsInteger := cComplete;
                    ibsqlSetting.ParamByName('comment').AsString := S;
                    ibsqlSetting.ExecQuery;
                    ibsqlSetting.Transaction.Commit;
                    MessageBox(Application.Handle, PChar('Произошла ошибка при ' +
                     'загрузке настроек: ' + E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
                  end;
                end;
                stNoDontShow:
                begin
                  ibsqlSetting.Close;
                  ibsqlSetting.SQL.Text := 'INSERT INTO st_settingstate ' +
                   '(STATUS, COMMENT) VALUES(:STATUS, :COMMENT)';
                  ibsqlSetting.ParamByName('status').AsInteger := cDontShow;
                  ibsqlSetting.ParamByName('comment').AsString := S;
                  ibsqlSetting.ExecQuery;
                  ibsqlSetting.Transaction.Commit;
                end;
                //stNo:;
              end;
            finally
              Free;
            end;
          end;
          // 1
          cDisable:
          begin
            if IBLogin.IsIBUserAdmin then
              if MessageBox(Application.Handle, 'Идет процесс установки настроек. ' +
               'Вход в систему может привести к нежелательным последствиям. ' +
               'Хотите прекратить загрузку программы?', 'Внимание', MB_YESNO or MB_ICONSTOP) = IDYES then
              begin
                Application.Terminate;
                Exit;
              end else
              begin
                ibsqlSetting.Close;
                ibsqlSetting.SQL.Text := 'INSERT INTO st_settingstate ' +
                 '(STATUS, COMMENT) VALUES(:STATUS, :COMMENT)';
                ibsqlSetting.ParamByName('status').AsInteger := cDontShow;
                ibsqlSetting.ParamByName('comment').AsString := S;
                ibsqlSetting.ExecQuery;
                ibsqlSetting.Transaction.Commit;
              end
            else
            begin
              MessageBox(Application.Handle, 'Идет процесс установки настроек. ' +
               'Вход в систему заблокирован. Обратитесь к администратору системы.',
               'Внимание', MB_OK or MB_ICONSTOP);
              Application.Terminate;
              Exit;
            end;
          end;
        else
          // 2, 3
          Exit;
        end;
      end
{$IFNDEF DEPARTMENT}
{      else
        MessageBox(Application.Handle, 'Необходимо выполнить апгрейд базы данных.',
         'Внимание', MB_OK or MB_ICONINFORMATION)
         }
{$ENDIF}
      ;
    finally
      ibsqlSetting.Transaction.Free;
    end;
  finally
    ibsqlSetting.Free;
  end;
end;
*)

initialization

  UserParamExists := False;
  PasswordParamExists := False;
  LoadSettingPath := '';
  LoadSettingFileName := '';

end.
