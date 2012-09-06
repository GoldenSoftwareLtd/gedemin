unit dmLogin_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_security_body, syn_ManagerInterface_body_unit, gdcBase,
  gsDesktopManager, IBDatabase, flt_ScriptInterface_body,
  {$IFDEF WITH_INDY}
  gd_WebClientControl_unit,
  {$ENDIF}
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

  {$IFDEF WITH_INDY}
  if not Application.Terminated then
    gdWebClientThread.AfterConnection;
  {$ENDIF}  
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
            on E: Exception do
              Application.ShowException(E);
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

initialization
  UserParamExists := False;
  PasswordParamExists := False;
  LoadSettingPath := '';
  LoadSettingFileName := '';
end.
