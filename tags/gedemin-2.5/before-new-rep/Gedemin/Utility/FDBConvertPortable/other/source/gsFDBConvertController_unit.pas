unit gsFDBConvertController_unit;

interface

uses
  gsFDBConvert_unit, Windows, Forms, classes, gsFDBConvertHelper_unit;

type
  TgsFDBConvertController = class(TObject)
  private
    FProcessForm: TForm;
    FFDBConvert: TgsFDBConvert;
    FWasConvertingProcess: Boolean;
    FInConvertingProcess: Boolean;

    procedure SetProcessForm(const Value: TForm);

    procedure ProcessSubstituteList;
    // Проверяет, доступен ли диск для записи.  Если ничего записать не получается, завершаем программу
    procedure CheckDiskWriteAbility(const InFormMode: Boolean);
    // Проверка на наличие и создание путей указанных в параметрах
    procedure CheckProcessPathes;
  public
    constructor Create(AnOwner: TObject);
    destructor Destroy; override;

    procedure SetupDialogForm;

    procedure LoadLanguage(const ALanguageName: String);

    procedure SetCurrentStepMessage(const AStepMessage: String);

    // Отобразить информацию о предстоящем процессе
    procedure ViewPreProcessInformation;
    // Отобразить информацию о завершенном процессе
    procedure ViewAfterProcessInformation;
    // Отобразить информацию о прерванном из-за ошибки (или пользователем) процессе
    procedure ViewInterruptedProcessInformation(const AErrorMessage: String);
    // Установить необходимые параметры конвертации БД
    procedure SetProcessParameters;
    // Проверить правильность указанных параметров конвертации
    procedure CheckProcessParams(const RespondToForm: Boolean = False);

    procedure ClearConvertParams;
    // Запустить процесс конвертации БД
    procedure DoConvertDatabase;

    property ProcessForm: TForm read FProcessForm write SetProcessForm;
    property ModelObject: TgsFDBConvert read FFDBConvert write FFDBConvert;

    property InConvertingProcess: Boolean read FInConvertingProcess write FInConvertingProcess;
  end;

implementation

uses
  Sysutils,
  stdctrls,
  gsFDBConvertConsoleView_unit,
  gsFDBConvertFormView_unit,
  gs_frmFunctionEdit_unit,
  jclStrings,
  IBDatabase, IB,
  gsFDBConvertLocalization_unit,
  Graphics;

type
  TgsConvertThread = class(TThread)
  protected
    FMessage: String;
    FController: TgsFDBConvertController;
    FIsRestoringMetadata: Boolean;

    FgsFunctionEditor: TgsMetadataEditor;
    FMetadataMaxProgress, FMetadataCurrentProgress: Integer;
    FMetadataName, FMetadataText, FMetadataError: String;
    FEditMetadataType: TgsMetadataType;

    procedure SynchronizeMethod(Method: TThreadMethod);

    procedure DoEditMetadata;

    procedure ProcessProcedures;
    procedure ProcessTriggers;
    procedure ProcessViewsAndComputedFields;

    procedure OnMetadataEditError;
    procedure OnInterruptedProcess;
  public
    procedure Execute; override;

    property Controller: TgsFDBConvertController read FController write FController;
  end;
  
  EgsNeedFreeSpace = class(Exception);
  EgsUnknownServerVersion = class(Exception);

{ TgsFDBConvertController }

constructor TgsFDBConvertController.Create(AnOwner: TObject);
begin
  // Проверяем, доступен ли диск для записи
  //  Если ничего записать не получается, завершаем программу
  CheckDiskWriteAbility(Assigned(AnOwner));

  FFDBConvert := TgsFDBConvert.Create;

  if Assigned(AnOwner) and (AnOwner is TgsFDBConvertFormView) then
  begin
    FProcessForm := TForm(AnOwner);
    // Установим процедуры визуализации работы нитей
    ModelObject.ServiceProgressRoutine := FormServiceProgressRoutine;
    ModelObject.MetadataProgressRoutine := FormMetadataProgressRoutine;
    ModelObject.CopyProgressRoutine := FormCopyProgressRoutine;
  end
  else
  begin
    // Установим процедуры визуализации работы нитей
    ModelObject.ServiceProgressRoutine := ConsoleServiceProgressRoutine;
    ModelObject.MetadataProgressRoutine := ConsoleMetadataProgressRoutine;
    ModelObject.CopyProgressRoutine := ConsoleCopyProgressRoutine;
  end;

  FWasConvertingProcess := False;
end;

destructor TgsFDBConvertController.Destroy;
begin
  inherited;
  FreeAndNil(FFDBConvert);

  TgsFileSystemHelper.DeleteTempFiles;
end;

procedure TgsFDBConvertController.SetupDialogForm;
var
  SubstituteList: TStringList;
  StringCounter: Integer;
  CharsetIndex: Integer;
begin
  if Assigned(FProcessForm) then
  begin
    with (FProcessForm as TgsFDBConvertFormView) do
    begin
      // Загрузим список локализаций
      TgsConfigFileManager.GetLanguageList(cbLanguage.Items);
      // Если не смогли загрузить язык на основании раскладки клавиатуры, то
      // выберем первый язык из списка (поэтому язык по умолчанию должен быть первым в файле)
      if (cbLanguage.Items.Count > 0) then
      begin
        if LanguageLoadedOnStartup <> '' then
        begin
          cbLanguage.ItemIndex := cbLanguage.Items.IndexOf(LanguageLoadedOnStartup);
        end
        else
        begin
          cbLanguage.ItemIndex := 0;
          cbLanguage.OnChange(cbLanguage);
        end;
      end;
      // Загрузим список кодовых страниц
      TgsConfigFileManager.GetCodePageList(cbCharacterSet.Items);
      // Выберем кодовую страницу по умолчанию
      CharsetIndex := cbCharacterSet.Items.IndexOf(DefaultCharacterSet);
      if CharsetIndex > -1 then
        cbCharacterSet.ItemIndex := CharsetIndex
      else
        cbCharacterSet.ItemIndex := cbCharacterSet.Items.Add(DefaultCharacterSet);
      // Загрузим список заменяемых функций
      SubstituteList := TStringList.Create;
      try
        TgsConfigFileManager.GetSubstituteFunctionList(SubstituteList);
        for StringCounter := 0 to SubstituteList.Count - 1 do
        begin
          sgSubstituteList.Cells[0, StringCounter] := SubstituteList.Names[StringCounter];
          sgSubstituteList.Cells[1, StringCounter] := SubstituteList.Values[SubstituteList.Names[StringCounter]];
        end;
      finally
        FreeAndNil(SubstituteList);
      end;
      // Загрузим значения для подключения по умолчанию
      cbPageSize.Text := IntToStr(TgsConfigFileManager.GetDefaultPageSize);
      eBufferSize.Text := IntToStr(TgsConfigFileManager.GetDefaultNumBuffers);
    end;
  end
  else
    raise Exception.Create('Dialog form is not assigned!');
end;

procedure TgsFDBConvertController.LoadLanguage(const ALanguageName: String);
begin
  // Инициализируем работу с новой локализацией
  LoadLanguageStrings(ALanguageName);
end;

procedure TgsFDBConvertController.ProcessSubstituteList;
var
  SubstituteList: TStringList;
  StringCounter: Integer;
begin
  with (FProcessForm as TgsFDBConvertFormView) do
  begin
    // Сохраним введенные замещаемые функции
    SubstituteList := TStringList.Create;
    try
      for StringCounter := 0 to sgSubstituteList.RowCount - 1 do
      begin
        // Учитываем только правильно указанные записи
        if (sgSubstituteList.Cells[0, StringCounter] <> '')
           and (sgSubstituteList.Cells[1, StringCounter] <> '') then
          SubstituteList.Add(sgSubstituteList.Cells[0, StringCounter] + '=' + sgSubstituteList.Cells[1, StringCounter]);
      end;
      // Сохранить данные в файлы
      TgsConfigFileManager.SaveSubstituteFunctionList(SubstituteList);
    finally
      FreeAndNil(SubstituteList);
    end;
  end;
end;

procedure TgsFDBConvertController.SetProcessParameters;
var
  ConnectInfo: TgsConnectionInformation;
  ParameterValue: String;
begin
  if not FWasConvertingProcess then
  begin
    // Если мы в оконном интерфейсе
    if Assigned(FProcessForm) then
    begin
      with (FProcessForm as TgsFDBConvertFormView) do
      begin
        // Если вызов идет со страницы "2/8 - Выбор файла базы данных"
        if pcMain.ActivePage = tbs02 then
        begin
          // Получим имя БД
          ModelObject.DatabaseName := eDatabaseName.Text;
          ModelObject.DatabaseOriginalName := eDatabaseName.Text;

          if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseName) then
          begin
            // Имя оригинальной БД (бэкапа)
            ModelObject.FinishOriginalDatabaseName :=
              TgsFileSystemHelper.ChangeExtention(ModelObject.DatabaseOriginalName, OLD_DATABASE_EXTENSION);
            // Имя конвертированной БД
            ModelObject.FinishConvertedDatabaseName := ModelObject.DatabaseOriginalName;
          end
          else
          begin
            // Имя оригинальной БД (бэкапа)
            ModelObject.FinishOriginalDatabaseName := ModelObject.DatabaseOriginalName;
            // Имя конвертированной БД
            ModelObject.FinishConvertedDatabaseName := ModelObject.DatabaseCopyName;
          end;

          // Путь к копии БД
          ModelObject.DatabaseCopyName := TgsFileSystemHelper.GetDefaultDatabaseCopyName(ModelObject.DatabaseName);
          // Путь к бэкапу БД
          ModelObject.DatabaseBackupName := TgsFileSystemHelper.GetDefaultBackupName(ModelObject.DatabaseName);;

          // Обработчик сервисов сервера БД
          ModelObject.ServiceProgressRoutine := FormServiceProgressRoutine;
          // Обработчик копирования БД
          ModelObject.CopyProgressRoutine := FormCopyProgressRoutine;
          // Обработчик конвертирования метаданных
          ModelObject.MetadataProgressRoutine := FormMetadataProgressRoutine;
        end
        else
        begin
          // Иначе берем всю оставшуюся информацию
          // Путь к копии БД
          ModelObject.DatabaseCopyName := eTempDatabaseName.Text;
          // Путь к бэкапу БД
          ModelObject.DatabaseBackupName := eBackupName.Text;

          if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseName) then
          begin
            // Минимальным значением размера страницы для FB 2.5 является 4096
            if StrToInt(cbPageSize.Text) >= MINIMAL_PAGE_SIZE then
              ConnectInfo.PageSize := StrToInt(cbPageSize.Text)
            else
              ConnectInfo.PageSize := MINIMAL_PAGE_SIZE;
            ConnectInfo.NumBuffers := StrToInt(eBufferSize.Text);
            ConnectInfo.CharacterSet := Trim(cbCharacterSet.Text);
          end
          else
          begin
            ConnectInfo.PageSize := -1;
            ConnectInfo.NumBuffers := -1;
            ConnectInfo.CharacterSet := '';
          end;
          ModelObject.ConnectionInformation := ConnectInfo;
        end;

        // Обработаем введенные замещаемые функции
        if pcMain.ActivePage = tbs04 then
          ProcessSubstituteList;
      end;
    end
    else
    begin
      // Запросить путь и имя базы данных у пользователя (если не передано в параметрах)
      ParameterValue := GetConsoleParamValue('DB');
      while ParameterValue = '' do
      begin
        ParameterValue := Trim(GetInputString(GetLocalizedString(lsEnterDatabasePath)));
        ParameterValue := StringReplace(ParameterValue, '"', '', [rfReplaceAll]);
        if StrUpper(StrLeft(ParameterValue, 1)) = 'Q' then
          Halt(1);
      end;
      ModelObject.DatabaseName := ParameterValue;
      ModelObject.DatabaseOriginalName := ParameterValue;

      // Получим название копии БД
      ParameterValue := GetConsoleParamValue('COPY');
      if ParameterValue = '' then
        ParameterValue := TgsFileSystemHelper.GetDefaultDatabaseCopyName(ModelObject.DatabaseName);
      ModelObject.DatabaseCopyName := ParameterValue;

      // Получим название бэкапа БД
      ParameterValue := GetConsoleParamValue('BACKUP');
      if ParameterValue = '' then
        ParameterValue := TgsFileSystemHelper.GetDefaultBackupName(ModelObject.DatabaseName);
      ModelObject.DatabaseBackupName := ParameterValue;

      // При конвертации БД возьмем параметры подключения из нее (если не переданы другие),
      //  при конвертации бэкапа возьмем параметры по умолчанию
      if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseName) then
      begin
        // Имя оригинальной БД (бэкапа)
        ModelObject.FinishOriginalDatabaseName :=
          TgsFileSystemHelper.ChangeExtention(ModelObject.DatabaseOriginalName, OLD_DATABASE_EXTENSION);
        // Имя конвертированной БД
        ModelObject.FinishConvertedDatabaseName := ModelObject.DatabaseOriginalName;

        ModelObject.ServerType := CONVERT_SERVER_VERSION;
        ModelObject.Connect;
        try
          // Получим размер страницы
          ParameterValue := GetConsoleParamValue('PAGE');
          if ParameterValue = '' then
            ConnectInfo.PageSize := ModelObject.DatabaseInfo.PageSize
          else
            ConnectInfo.PageSize := StrToInt(ParameterValue);
          // Минимальным значением размера страницы для FB 2.5 является 4096
          if ConnectInfo.PageSize < MINIMAL_PAGE_SIZE then
            ConnectInfo.PageSize := MINIMAL_PAGE_SIZE;

          // Получим кол-во буферов
          ParameterValue := GetConsoleParamValue('BUFF');
          if ParameterValue = '' then
            ConnectInfo.NumBuffers := ModelObject.DatabaseInfo.NumBuffers
          else
            ConnectInfo.NumBuffers := StrToInt(ParameterValue);

          // Кодировка
          ParameterValue := GetConsoleParamValue('CHARSET');
          if ParameterValue = '' then
            ConnectInfo.CharacterSet := ModelObject.GetDatabaseCharacterSet
          else
            ConnectInfo.CharacterSet := ParameterValue;
        finally
          ModelObject.Disconnect;
        end;
      end
      else
      begin
        // Имя оригинальной БД (бэкапа)
        ModelObject.FinishOriginalDatabaseName := ModelObject.DatabaseOriginalName;
        // Имя конвертированной БД
        ModelObject.FinishConvertedDatabaseName := ModelObject.DatabaseCopyName;

        // Получим размер страницы
        ParameterValue := GetConsoleParamValue('PAGE');
        if ParameterValue = '' then
          ConnectInfo.PageSize := DefaultPageSize
        else
          ConnectInfo.PageSize := StrToInt(ParameterValue);
        // Минимальным значением размера страницы для FB 2.5 является 4096
        if ConnectInfo.PageSize < MINIMAL_PAGE_SIZE then
          ConnectInfo.PageSize := MINIMAL_PAGE_SIZE;

        // Получим кол-во буферов
        ParameterValue := GetConsoleParamValue('BUFF');
        if ParameterValue = '' then
          ConnectInfo.NumBuffers := DefaultNumBuffers
        else
          ConnectInfo.NumBuffers := StrToInt(ParameterValue);

        // Кодировка
        ParameterValue := GetConsoleParamValue('CHARSET');
        if ParameterValue = '' then
          ConnectInfo.CharacterSet := DefaultCharacterSet
        else
          ConnectInfo.CharacterSet := ParameterValue;
      end;

      ModelObject.ConnectionInformation := ConnectInfo;

      // Обработчик сервисов сервера БД
      ModelObject.ServiceProgressRoutine := ConsoleServiceProgressRoutine;
      // Обработчик копирования БД
      ModelObject.CopyProgressRoutine := ConsoleCopyProgressRoutine;
      // Обработчик конвертирования метаданных
      ModelObject.MetadataProgressRoutine := ConsoleMetadataProgressRoutine;
    end;
  end;
end;

procedure TgsFDBConvertController.ViewPreProcessInformation;
var
  CharsetIndex: Integer;
  CurrentCharset: String;
begin
  if not FWasConvertingProcess then
  begin
    // Подключимся к БД с помощью FB 2.5 и получим служебную информацию (если нам передали не бекап)
    if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseName) then
    begin
      ModelObject.ServerType := CONVERT_SERVER_VERSION;
      ModelObject.Connect;
      // Если передан не бэкап
      if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseName) then
      begin
        // Запомним версию оригинального сервера, будет использоваться в ModelObject.RestoreDatabase
        ModelObject.OriginalServerType := GetServerVersionByDBVersion(ModelObject.GetDatabaseVersion);
      end;  
    end;

    try
      // Если мы в оконном интерфейсе
      if Assigned(FProcessForm) then
      begin
        with FProcessForm as TgsFDBConvertFormView do
        begin
          if pcMain.ActivePage = tbs02 then
          begin
            eOriginalDatabase.Text := ModelObject.DatabaseName;
            eNewServerVersion.Text := GetTextServerVersion(CONVERT_SERVER_VERSION);
            eTempDatabaseName.Text := ModelObject.DatabaseCopyName;
            eBackupName.Text := ModelObject.DatabaseBackupName;

            // Если передан не бэкап
            if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseName) then
            begin
              eBAKDatabaseCopy.Text := ModelObject.FinishOriginalDatabaseName;
              eOriginalDBVersion.Text := GetTextDBVersion(ModelObject.GetDatabaseVersion);
              eOriginalServerVersion.Text := GetTextServerVersion(ModelObject.OriginalServerType);

              // Заполнение параметров: кол-во страниц, размер страницы, кодировка
              pnlDBProperties.Visible := True;
              // Минимальным значением размера страницы для FB 2.5 является 4096
              if ModelObject.DatabaseInfo.PageSize >= MINIMAL_PAGE_SIZE then
                cbPageSize.Text := IntToStr(ModelObject.DatabaseInfo.PageSize)
              else
                cbPageSize.Text := IntToStr(MINIMAL_PAGE_SIZE);
              eBufferSize.Text := IntToStr(ModelObject.DatabaseInfo.NumBuffers);
              // Получим кодировку БД
              CurrentCharset := ModelObject.GetDatabaseCharacterSet;
              if CurrentCharset <> '' then
              begin
                CharsetIndex := cbCharacterSet.Items.IndexOf(CurrentCharset);
                if CharsetIndex > -1 then
                  cbCharacterSet.ItemIndex := CharsetIndex
                else
                  cbCharacterSet.ItemIndex := cbCharacterSet.Items.Add(CurrentCharset);
              end;
            end
            else
            begin
              eBAKDatabaseCopy.Text := Format('< %0:s >', [GetLocalizedString(lsUnknownParameterValue)]);
              eOriginalDBVersion.Text := Format('< %0:s >', [GetLocalizedString(lsUnknownParameterValue)]);
              eOriginalServerVersion.Text := Format('< %0:s >', [GetLocalizedString(lsUnknownParameterValue)]);

              // Скроем поля ввода (кол-во страниц, размер страницы, кодировка) при выборе бекапа
              pnlDBProperties.Visible := False;
            end;
          end;

          // Выведем тоже самое в мемо
          mProcessInformation.Clear;
          mProcessInformation.Lines.Add(lblOriginalDatabase.Caption + ' ' + eOriginalDatabase.Text);
          mProcessInformation.Lines.Add(lblBAKDatabaseCopy.Caption + ' ' + eBAKDatabaseCopy.Text);
          mProcessInformation.Lines.Add(lblOriginalDBVersion.Caption + ' ' + eOriginalDBVersion.Text);
          mProcessInformation.Lines.Add(lblOriginalServerVersion.Caption + ' ' + eOriginalServerVersion.Text);
          mProcessInformation.Lines.Add(lblNewServerVersion.Caption + ' ' + eNewServerVersion.Text);

          mProcessInformation.Lines.Add(lblBackupName.Caption + ' ' + eBackupName.Text);
          mProcessInformation.Lines.Add(lblTempDatabaseName.Caption + ' ' + eTempDatabaseName.Text);
          if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseName) then
          begin
            mProcessInformation.Lines.Add(lblPageSize.Caption + ' ' + cbPageSize.Text + ' ' + lblPageSize_02.Caption);
            mProcessInformation.Lines.Add(lblBufferSize.Caption + ' ' + eBufferSize.Text + ' ' + lblBufferSize_02.Caption);
            mProcessInformation.Lines.Add(lblCharacterSet.Caption + ' ' + cbCharacterSet.Text);
          end;
        end;
      end
      else
      begin
        WriteToConsoleLn(GetLocalizedString(lsDatabasePreprocessInformation));
        // Если передан не бэкап
        if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseName) then
        begin
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsOriginalDatabase),
            ModelObject.DatabaseName]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsBAKDatabaseCopy),
            ModelObject.FinishOriginalDatabaseName]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsOriginalDBVersion),
            GetTextDBVersion(ModelObject.GetDatabaseVersion)]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsOriginalServerVersion),
            GetTextServerVersion(GetServerVersionByDBVersion(ModelObject.GetDatabaseVersion))]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsNewServerVersion),
            GetTextServerVersion(CONVERT_SERVER_VERSION)]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsBackupName),
            ModelObject.DatabaseBackupName]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsTempDatabaseName),
            TgsFileSystemHelper.GetDefaultDatabaseCopyName(ModelObject.DatabaseName)]));
          WriteToConsoleLn(Format('  %0:s %1:d %2:s', [GetLocalizedString(lsPageSize),
            ModelObject.DatabaseInfo.PageSize, GetLocalizedString(lsPageSize_02)]));
          WriteToConsoleLn(Format('  %0:s %1:d %2:s', [GetLocalizedString(lsBufferSize),
            ModelObject.DatabaseInfo.NumBuffers, GetLocalizedString(lsBufferSize_02)]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsCharacterSet),
            ModelObject.GetDatabaseCharacterSet]));
        end
        else
        begin
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsOriginalBackup),
            ModelObject.DatabaseName]));
          WriteToConsoleLn(Format('  %0:s < %1:s >', [GetLocalizedString(lsOriginalServerVersion),
            GetLocalizedString(lsUnknownParameterValue)]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsNewServerVersion),
            GetTextServerVersion(CONVERT_SERVER_VERSION)]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsBackupName),
            ModelObject.DatabaseBackupName]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsResultDatabaseName),
            TgsFileSystemHelper.GetDefaultDatabaseCopyName(ModelObject.DatabaseName)]));
        end;
      end;
    finally
      ModelObject.Disconnect;
    end;
  end;  
end;

procedure TgsFDBConvertController.ViewAfterProcessInformation;
begin
  // Если мы в оконном интерфейсе
  if Assigned(FProcessForm) then
  begin
    with FProcessForm as TgsFDBConvertFormView do
    begin
      AddMessage(' ');
      AddMessage(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsProcessSuccessfullEnd)]));
      if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseOriginalName) then
      begin
        AddMessage(GetLocalizedString(lsOriginalDatabaseNameFinalMessage));
        AddMessage('  ' + ModelObject.FinishOriginalDatabaseName);
      end;
      AddMessage(GetLocalizedString(lsNewDatabaseNameFinalMessage));
      AddMessage('  ' + ModelObject.FinishConvertedDatabaseName);
      AddMessage(LOG_DIVIDER);
      Animate.Visible := False;
    end;
  end
  else
  begin
    WriteToConsoleLn(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsProcessSuccessfullEnd)]));
    if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseOriginalName) then
    begin
      WriteToConsoleLn(GetLocalizedString(lsOriginalDatabaseNameFinalMessage));
      WriteToConsoleLn('  ' + ModelObject.FinishOriginalDatabaseName);
    end;
    WriteToConsoleLn(GetLocalizedString(lsNewDatabaseNameFinalMessage));
    WriteToConsoleLn('  ' + ModelObject.FinishConvertedDatabaseName);
  end;
end;

procedure TgsFDBConvertController.ViewInterruptedProcessInformation(const AErrorMessage: String);
begin
  // Если мы в оконном интерфейсе
  if Assigned(FProcessForm) then
  begin
    with FProcessForm as TgsFDBConvertFormView do
    begin
      AddMessage(' ');
      // сообщим об ошибке
      if AErrorMessage <> '' then
      begin
        AddMessage(Format('%s: %s', [TimeToStr(Time), AErrorMessage]));
        AddMessage(' ');
        AddMessage(GetLocalizedString(lsProcessInterruptedEnd));
      end
      else
        AddMessage(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsProcessInterruptedEnd)]));

      AddMessage(' ');

      if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseOriginalName) then
      begin
        AddMessage(GetLocalizedString(lsOriginalDatabaseNameInterruptMessage));
        AddMessage('  ' + ModelObject.DatabaseOriginalName);
      end
      else
      begin
        AddMessage(GetLocalizedString(lsOriginalBackupNameInterruptMessage));
        AddMessage('  ' + ModelObject.DatabaseOriginalName);
      end;
      
      AddMessage(LOG_DIVIDER);
      // скроем анимацию
      Animate.Visible := False;
      // очистим прогресс-бар
      SetCurrentStep('');
    end;
  end
  else
  begin
    // сообщим об ошибке
    if AErrorMessage <> '' then
    begin
      WriteToConsoleLn(Format('%s: %s', [TimeToStr(Time), AErrorMessage]));
      WriteToConsoleLn(GetLocalizedString(lsProcessInterruptedEnd));
    end
    else
      WriteToConsoleLn(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsProcessInterruptedEnd)]));

    if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseOriginalName) then
    begin
      WriteToConsoleLn(GetLocalizedString(lsOriginalDatabaseNameInterruptMessage));
      WriteToConsoleLn('  ' + ModelObject.DatabaseOriginalName);
    end
    else
    begin
      WriteToConsoleLn(GetLocalizedString(lsOriginalBackupNameInterruptMessage));
      WriteToConsoleLn('  ' + ModelObject.DatabaseOriginalName);
    end;
  end;
end;

procedure TgsFDBConvertController.SetProcessForm(const Value: TForm);
begin
  if Value is TgsFDBConvertFormView then
    FProcessForm := Value
  else
    raise Exception.Create(Format('TgsFDBConvertController.SetProcessForm:'#13#10 +
      '  Unknown form type, want %0:s, get %1:s', [TgsFDBConvertFormView.Classname, Value.Classname]));
end;

procedure TgsFDBConvertController.DoConvertDatabase;
var
  InputString: String;
begin
  // Если запуск произошел из консоли
  if not Assigned(FProcessForm) then
  begin
    // Если из консоли запустили без параметра авто-конвертации
    if FindConsoleParam('S') = -1 then
    begin
      InputString := GetInputString(GetLocalizedString(lsStartConvertQuestion) + '(Y/N)?');
      if StrUpper(Trim(InputString)) <> 'Y' then
        Exit;
    end;
  end;

  // Если True значит процесс уже был проведен,
  //  не будем запускать его снова пока не будет вызвано ClearConvertParams
  if not FWasConvertingProcess then
  begin
    // Запомним что процесс был запущен
    FWasConvertingProcess := True;

    // Запустим анимацию 
    if Assigned(FProcessForm) then
      with FProcessForm as TgsFDBConvertFormView do
        Animate.Visible := True;

    // Создадим нить вставляющую или удаляющую комментарии из хранимых процедур и триггеры
    with TgsConvertThread.Create(True) do
    begin
      Controller := Self;

      FreeOnTerminate := True;
      Priority := tpLower;
      Resume;

      // Если запуск произошел из консоли, значит будем ждать пока не отработает нить
      if not Assigned(FProcessForm) then
        while not Terminated do
          Sleep(500);
    end;
  end;
end;

procedure TgsFDBConvertController.ClearConvertParams;
begin
  FWasConvertingProcess := False;
end;

procedure TgsFDBConvertController.CheckProcessParams(const RespondToForm: Boolean = False);
var
  ProcessedFileSize, ProcessedDBFileSize, ProcessedBKFileSize: Int64;
  NeedFreeSpace: Boolean;
  MessageStr: String;
  FreeSpaceMultiplier: Real;

  function FileSizeToStr(const AFileSize: Int64): String;
  var
    SizeInMB: Int64;
  begin
    SizeInMB := AFileSize div BYTE_IN_MB;
    if SizeInMB >= 1 then
      Result := IntToStr(SizeInMB)
    else
      Result := '<1';
  end;

begin
  NeedFreeSpace := False;
  MessageStr := '';

  // Если на входе БД, то нужно свободного места в FREE_SPACE_MULTIPLIER больше чем размер входного файла,
  //  если бекап - в FREE_SPACE_MULTIPLIER_FOR_BK
  if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseName) then
  begin
    if (ModelObject.OriginalServerType = svUnknown) and not RespondToForm then
      raise EgsUnknownServerVersion.Create(GetLocalizedString(lsUnknownServerType));
    FreeSpaceMultiplier := FREE_SPACE_MULTIPLIER;
  end
  else
  begin
    FreeSpaceMultiplier := FREE_SPACE_MULTIPLIER_FOR_BK;
  end;

  // Кол-во свободного места под временные файлы
  ProcessedFileSize := Round(TgsFileSystemHelper.GetFileSize(ModelObject.DatabaseName) * FreeSpaceMultiplier);

  // Проверим наличие свободного места на диске
  // Если копия БД и архив на одном диске
  if UpperCase(ExtractFileDrive(ModelObject.DatabaseCopyName)) =
    UpperCase(ExtractFileDrive(ModelObject.DatabaseBackupName)) then
  begin
    // Проверим свободное место для копии БД и архива БД
    MessageStr := Format('%s %s %s',
      [UpperCase(ExtractFileDrive(ModelObject.DatabaseCopyName)), FileSizeToStr(ProcessedFileSize), GetLocalizedString(lsDiskSpaceQuantifier)]);
    if TgsFileSystemHelper.CheckForFreeDiskSpace(ModelObject.DatabaseCopyName, ProcessedFileSize) > 0 then
    begin
      NeedFreeSpace := True;
      if not (RespondToForm and Assigned(FProcessForm)) then
        raise EgsNeedFreeSpace.Create(GetLocalizedString(lsNoDiskSpaceForTempFiles) + #13#10#13#10 +
          Format('%s %s %s',
            [GetLocalizedString(lsWantDiskSpace), FileSizeToStr(ProcessedFileSize), GetLocalizedString(lsDiskSpaceQuantifier)]));
    end;
  end
  else
  begin
    // Проверим свободное место для архива БД
    ProcessedBKFileSize := Round(ProcessedFileSize * (1 / 3));
    MessageStr := Format('%s %s %s',
      [UpperCase(ExtractFileDrive(ModelObject.DatabaseBackupName)), FileSizeToStr(ProcessedBKFileSize), GetLocalizedString(lsDiskSpaceQuantifier)]);
    if TgsFileSystemHelper.CheckForFreeDiskSpace(ModelObject.DatabaseBackupName, ProcessedBKFileSize) > 0 then
    begin
      NeedFreeSpace := True;
      if not (RespondToForm and Assigned(FProcessForm)) then
        raise EgsNeedFreeSpace.Create(GetLocalizedString(lsNoDiskSpaceForBackup) + #13#10 +
          ModelObject.DatabaseBackupName + #13#10#13#10 +
          Format('%s %s %s',
            [GetLocalizedString(lsWantDiskSpace), FileSizeToStr(ProcessedBKFileSize),
             GetLocalizedString(lsDiskSpaceQuantifier)]));
    end;

    // Проверим свободное место для копии БД
    ProcessedDBFileSize := Round(ProcessedFileSize * (2 / 3));
    MessageStr := MessageStr + Format(', %s %s %s',
      [UpperCase(ExtractFileDrive(ModelObject.DatabaseCopyName)), FileSizeToStr(ProcessedDBFileSize), GetLocalizedString(lsDiskSpaceQuantifier)]);
    if TgsFileSystemHelper.CheckForFreeDiskSpace(ModelObject.DatabaseCopyName, ProcessedDBFileSize) > 0 then
    begin
      NeedFreeSpace := True;
      if not (RespondToForm and Assigned(FProcessForm)) then
        raise EgsNeedFreeSpace.Create(GetLocalizedString(lsNoDiskSpaceForDBCopy) + #13#10 +
          ModelObject.DatabaseCopyName + #13#10#13#10 +
          Format('%s %s %s',
            [GetLocalizedString(lsWantDiskSpace), FileSizeToStr(ProcessedDBFileSize),
             GetLocalizedString(lsDiskSpaceQuantifier)]));
    end;
  end;

  if RespondToForm then
  begin
    if Assigned(FProcessForm) then
    begin
      if NeedFreeSpace then
        MessageStr := MessageStr + ' - ' + GetLocalizedString(lsNoDiskSpaceForTempFiles);
      (FProcessForm as TgsFDBConvertFormView).eNeedFreeSpace.Text := MessageStr;
    end;
  end
  else
  begin
    // Проверим наличие указанных путей, и создадим если надо
    CheckProcessPathes;
  end;
end;

procedure TgsFDBConvertController.SetCurrentStepMessage(const AStepMessage: String);
begin
  if Assigned(FProcessForm) then
    (FProcessForm as TgsFDBConvertFormView).SetCurrentStep(AStepMessage);
end;

procedure TgsFDBConvertController.CheckDiskWriteAbility(const InFormMode: Boolean);
begin
  try
    // Пытаемся отредактировать файл конфигурации сервера
    TgsFileSystemHelper.ChangeFirebirdRootDirectory(TgsFileSystemHelper.GetPathToServerDirectory(svFirebird_25));
  except
    // Если запущена не в консоли
    if InFormMode then
    begin
      // Покажем сообщение об ошибке
      Application.MessageBox(
        PChar(GetLocalizedString(lsDirectoryNotWritable)),
        PChar(GetLocalizedString(lsInformationDialogCaption)),
        MB_OK or MB_ICONERROR or MB_APPLMODAL);
      Application.Terminate;
    end
    else
    begin
      WriteToConsoleLn(GetLocalizedString(lsDirectoryNotWritable));
      Halt;
    end;
  end;
end;

procedure TgsFDBConvertController.CheckProcessPathes;
begin
  TgsFileSystemHelper.CheckPathExistence(ModelObject.DatabaseCopyName);
  TgsFileSystemHelper.CheckPathExistence(ModelObject.DatabaseBackupName);
end;

{ TgsConvertThread }

procedure TgsConvertThread.DoEditMetadata;
begin
  Controller.ModelObject.Connect;
  try
    FgsFunctionEditor := TgsMetadataEditor.Create(Controller.ModelObject.Database);
    // Загрузим список заменяемых функций
    try
      TgsConfigFileManager.GetSubstituteFunctionList(FgsFunctionEditor.SubstituteFunctionList);
    except
      on E: EgsConfigFileReadError do
      begin
        Controller.ModelObject.ServiceProgressRoutine(E.Message);
        Exit;
      end;
    end;

    try
      try
        if not FIsRestoringMetadata then
        begin
          // При удалении\коммментировании метаданных, сначала закомментируем триггеры\процедуры,
          //  а потом удалим представления\выч. поля
          ProcessTriggers;
          ProcessProcedures;
          ProcessViewsAndComputedFields;
        end
        else
        begin
          // При восстановлении метаданных сначала восстановим представления\выч. поля,
          //  а потом откомментируем триггеры\процедуры
          ProcessViewsAndComputedFields;
          ProcessProcedures;
          ProcessTriggers;
        end;
      except
        on E: EgsInterruptConvertProcess do
        begin
          raise;
        end;

        on E: Exception do
        begin
          Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsEditingMetadataError)]),
            FMetadataMaxProgress, FMetadataCurrentProgress);
          Controller.ModelObject.MetadataProgressRoutine(E.Message, FMetadataMaxProgress, FMetadataCurrentProgress);
        end;
      end;
    finally
      FreeAndNil(FgsFunctionEditor);
    end;
  finally
    Controller.ModelObject.Disconnect;
  end;
end;

procedure TgsConvertThread.Execute;
var
  ConnectInfo: TgsConnectionInformation;
  OriginalIsBackup: Boolean;
begin
  // Укажем контроллеру что процесс стартовал
  Controller.InConvertingProcess := True;

  // Если мы в оконном интерфейсе, то заблокируем кнопки
  if Assigned(Controller.ProcessForm) then
    Synchronize((Controller.ProcessForm as TgsFDBConvertFormView).DisableControls);

  try
    try
      // Если передан бэкап - разбекапим его во временную базу
      if TgsFileSystemHelper.IsBackupFile(Controller.ModelObject.DatabaseName) then
      begin
        OriginalIsBackup := True;
        // Пробуем восстановить БД несколькими серверами подряд
        try
          Controller.ModelObject.ServiceProgressRoutine(Format('%s: %s %s',
            [TimeToStr(Time), GetLocalizedString(lsRestoreWithServer), GetTextServerVersion(svYaffil)]));
          Controller.ModelObject.ServerType := svYaffil;
          // Создадим или скопируем файлы необходимые для корректной работы конвертера с данным сервером
          TgsFileSystemHelper.CreateTempFiles(svYaffil);
          try
            Controller.ModelObject.RestoreDatabase(Controller.ModelObject.DatabaseName, Controller.ModelObject.DatabaseCopyName);
          finally
            // Удалим временные файлы, созданные для работы данного сервера
            TgsFileSystemHelper.DeleteTempFiles;
          end;  
        except
          on E: EgsInterruptConvertProcess do
            raise
          else
          begin
            try
              // сообщим об ошибке восстановления
              Controller.ModelObject.ServiceProgressRoutine(GetLocalizedString(lsDatabaseRestoreProcessError));
              // Восстанавливаем след. сервером
              Controller.ModelObject.ServiceProgressRoutine(Format('%s: %s %s',
                [TimeToStr(Time), GetLocalizedString(lsRestoreWithServer), GetTextServerVersion(svFirebird_20)]));
              Controller.ModelObject.ServerType := svFirebird_20;
              Controller.ModelObject.RestoreDatabase(Controller.ModelObject.DatabaseName, Controller.ModelObject.DatabaseCopyName);
            except
              on E: EgsInterruptConvertProcess do
                raise
              else
              begin
                try
                  // сообщим об ошибке восстановления
                  Controller.ModelObject.ServiceProgressRoutine(GetLocalizedString(lsDatabaseRestoreProcessError));
                  // Восстанавливаем след. сервером
                  Controller.ModelObject.ServiceProgressRoutine(Format('%s: %s %s',
                    [TimeToStr(Time), GetLocalizedString(lsRestoreWithServer), GetTextServerVersion(svFirebird_25)]));
                  Controller.ModelObject.ServerType := svFirebird_25;
                  Controller.ModelObject.RestoreDatabase(Controller.ModelObject.DatabaseName, Controller.ModelObject.DatabaseCopyName);
                except
                  on E: EgsInterruptConvertProcess do
                    raise;

                  on E: Exception do
                  begin
                    // сообщим об ошибке восстановления
                    Controller.ModelObject.ServiceProgressRoutine(GetLocalizedString(lsDatabaseRestoreProcessError));
                    raise Exception.Create(E.Message);
                  end;
                end;
              end;  
            end;
          end;  
        end;
      end
      else
      begin
        OriginalIsBackup := False;

        Controller.SetCurrentStepMessage(GetLocalizedString(lsDatabaseFileCopyingProcess));
        // Иначе берем базу и копируем во временную базу
        Controller.ModelObject.CopyDatabaseFile(Controller.ModelObject.DatabaseName, Controller.ModelObject.DatabaseCopyName);
        Controller.SetCurrentStepMessage('');
      end;

      // Далее будем работать с копией БД
      Controller.ModelObject.DatabaseName := Controller.ModelObject.DatabaseCopyName;

      // Если у нас был бэкап, то получим версию сервера оригинальной БД
      if OriginalIsBackup then
      begin
        Controller.ModelObject.ServerType := CONVERT_SERVER_VERSION;
        Controller.ModelObject.Connect;
        try
          Controller.ModelObject.ServerType :=
            GetAppropriateServerVersion(GetServerVersionByDBVersion(Controller.ModelObject.GetDatabaseVersion));
          // Запомним версию оригинального сервера, будет использоваться в ModelObject.RestoreDatabase
          Controller.ModelObject.OriginalServerType := Controller.ModelObject.ServerType;
          // Получим из восстановленной базы кодовую страницу
          ConnectInfo := Controller.ModelObject.ConnectionInformation;
          ConnectInfo.CharacterSet := Controller.ModelObject.GetDatabaseCharacterSet;
          Controller.ModelObject.ConnectionInformation := ConnectInfo;
        finally
          Controller.ModelObject.Disconnect;
        end;
      end
      else
      begin
        // Для нормальной БД версия была получена в ViewPreProcessInformation
        Controller.ModelObject.ServerType :=
          GetAppropriateServerVersion(Controller.ModelObject.OriginalServerType);
      end;

      // Проверим целостность БД
      Controller.ModelObject.CheckDatabaseIntegrity(Controller.ModelObject.DatabaseName);

      // Создадим временные таблицы для метаданных
      Controller.ModelObject.Connect;
      try
        Controller.ModelObject.CreateConvertHelpMetadata;
      finally
        Controller.ModelObject.Disconnect;
      end;

      // Комментируем метаданные
      FIsRestoringMetadata := False;
      Self.DoEditMetadata;

      // Далее будем работать с новым сервером
      Controller.ModelObject.ServerType := CONVERT_SERVER_VERSION;

      // Бэкап
      Controller.ModelObject.BackupDatabase(Controller.ModelObject.DatabaseName,
        Controller.ModelObject.DatabaseBackupName);

      // Рестор
      Controller.ModelObject.RestoreDatabase(Controller.ModelObject.DatabaseBackupName,
        Controller.ModelObject.DatabaseName);

      FIsRestoringMetadata := True;
      Self.DoEditMetadata;

      // Удалим временные таблицы для метаданных
      Controller.ModelObject.Connect;
      try
        Controller.ModelObject.DestroyConvertHelpMetadata;
      finally
        Controller.ModelObject.Disconnect;
      end;

      // Если передан не бэкап
      if not TgsFileSystemHelper.IsBackupFile(Controller.ModelObject.DatabaseOriginalName) then
      begin
        try
          // Переименуем старую БД в *.BAK
          TgsFileSystemHelper.DoRenameFile(Controller.ModelObject.DatabaseOriginalName,
            Controller.ModelObject.FinishOriginalDatabaseName);
          // Переименуем новую БД в старую
          TgsFileSystemHelper.DoRenameFile(Controller.ModelObject.DatabaseCopyName,
            Controller.ModelObject.DatabaseOriginalName);
        except
          on E: Exception do
            Controller.ModelObject.ServiceProgressRoutine(E.Message);
        end;
      end;

      // Отобразим информацию о завершенном процессе
      SynchronizeMethod(Controller.ViewAfterProcessInformation);
    except
      on E: Exception do
      begin
        // Отобразим информацию о прерванном процессе
        FMessage := E.Message;
        SynchronizeMethod(OnInterruptedProcess);
      end;
    end;
  finally
    // Отключимся от БД
    Controller.ModelObject.Disconnect;
    // Удалим временные файлы
    if not TgsFileSystemHelper.IsBackupFile(Controller.ModelObject.DatabaseOriginalName) then
      TgsFileSystemHelper.DoDeleteFile(Controller.ModelObject.DatabaseCopyName);
    TgsFileSystemHelper.DoDeleteFile(Controller.ModelObject.DatabaseBackupName);

    // Укажем контроллеру что процесс завершился
    Controller.InConvertingProcess := False;

    // Если мы в оконном интерфейсе, то разблокируем кнопки
    if Assigned(Controller.ProcessForm) then
      Synchronize((Controller.ProcessForm as TgsFDBConvertFormView).EnableControls);

    // При вызове из консоли, поток опрашивается на Terminated,
    //  поэтому чтобы закончить выполнение установим его в True
    Terminate;
  end;
end;

procedure TgsConvertThread.OnMetadataEditError;
var
  NewFunctionText: String;
  DialogResult: TModalResult;
  DelimeterPos: Integer;
  ComputedTableName, ComputedFieldName: String;
begin
  // Если работаем с оконным интерфейсом, то дадим пользователю исправить функцию
  if Assigned(Controller.ProcessForm) then
  begin
    try
      with TfrmFunctionEdit.Create(Controller.ProcessForm) do
      begin
        case FEditMetadataType of
          // Произошла ошибка при редактировании хранимой процедуры
          mtProcedure:
          begin
            // Покажем сообщение об ошибке
            Application.MessageBox(
              PChar(Format('%s %s %s',
                [GetLocalizedString(lsFEProcedureErrorCaption), #13#10,
                 FgsFunctionEditor.GetFirstNLines(FMetadataError, 25)])),
              PChar(GetLocalizedString(lsInformationDialogCaption)),
              MB_OK or MB_ICONERROR or MB_APPLMODAL);

            // Вызвать диалог редактирования для хранимой процедуры
            DialogResult := ShowForProcedure(FMetadataName, FMetadataText, FMetadataError);
            case DialogResult of
              idOk:
              begin
                NewFunctionText := SynEditFunctionText;
                // Сохраним измененную процедуру
                FgsFunctionEditor.SetProcedureText(NewFunctionText);
                // Визуализация процесса
                Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsProcedureModified), [FMetadataName]),
                  FMetadataMaxProgress, FMetadataCurrentProgress);
              end;

              idAbort:
              begin
                raise EgsInterruptConvertProcess.Create('');
              end;
            else
              // Визуализация процесса
              Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsProcedureSkipped), [FMetadataName]),
                FMetadataMaxProgress, FMetadataCurrentProgress);
            end;
          end;

          // Произошла ошибка при редактировании триггера
          mtTrigger:
          begin
            // Покажем сообщение об ошибке
            Application.MessageBox(
              PChar(Format('%s %s %s',
                [GetLocalizedString(lsFETriggerErrorCaption), #13#10,
                 FgsFunctionEditor.GetFirstNLines(FMetadataError, 25)])),
              PChar(GetLocalizedString(lsInformationDialogCaption)),
              MB_OK or MB_ICONERROR or MB_APPLMODAL);

            // Вызвать диалог редактирования для триггера
            DialogResult := ShowForTrigger(FMetadataName, FMetadataText, FMetadataError);
            case DialogResult of
              idOk:
              begin
                NewFunctionText := SynEditFunctionText;
                // Сохраним измененный триггер
                FgsFunctionEditor.SetTriggerText(NewFunctionText);
                // Визуализация процесса
                Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsTriggerModified), [FMetadataName]),
                  FMetadataMaxProgress, FMetadataCurrentProgress);
              end;

              idAbort:
              begin
                raise EgsInterruptConvertProcess.Create('');
              end;
            else
              // Визуализация процесса
              Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsTriggerSkipped), [FMetadataName]),
                FMetadataMaxProgress, FMetadataCurrentProgress);
            end;
          end;

          // Произошла ошибка при редактировании представления
          mtView:
          begin
            // Покажем сообщение об ошибке
            Application.MessageBox(
              PChar(Format('%s %s %s',
                [GetLocalizedString(lsFEViewErrorCaption), #13#10,
                 FgsFunctionEditor.GetFirstNLines(FMetadataError, 25)])),
              PChar(GetLocalizedString(lsInformationDialogCaption)),
              MB_OK or MB_ICONERROR or MB_APPLMODAL);

            // Вызвать диалог редактирования для триггера
            DialogResult := ShowForView(FMetadataName, FMetadataText, FMetadataError);
            case DialogResult of
              idOk:
              begin
                NewFunctionText := SynEditFunctionText;
                // Сохраним измененный триггер
                FgsFunctionEditor.SetViewText(NewFunctionText);
                // Восстановим гранты для представления
                FgsFunctionEditor.RestoreGrant(FMetadataName);
                // Визуализация процесса
                Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsViewModified), [FMetadataName]),
                  FMetadataMaxProgress, FMetadataCurrentProgress);
              end;

              idAbort:
              begin
                raise EgsInterruptConvertProcess.Create('');
              end;
            else
              // Визуализация процесса
              Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsViewSkipped), [FMetadataName]),
                FMetadataMaxProgress, FMetadataCurrentProgress);
            end;
          end;

          // Произошла ошибка при редактировании вычисляемого поля
          mtComputedField:
          begin
            // Покажем сообщение об ошибке
            Application.MessageBox(
              PChar(Format('%s %s %s',
                [GetLocalizedString(lsFEComputedFieldErrorCaption), #13#10,
                 FgsFunctionEditor.GetFirstNLines(FMetadataError, 25)])),
              PChar(GetLocalizedString(lsInformationDialogCaption)),
              MB_OK or MB_ICONERROR or MB_APPLMODAL);

            // Вызвать диалог редактирования для триггера
            DialogResult := ShowForComputedField(FMetadataName, FMetadataText, FMetadataError);
            case DialogResult of
              idOk:
              begin
                NewFunctionText := SynEditFunctionText;        
                // Сохраним измененный триггер
                FgsFunctionEditor.SetViewText(NewFunctionText);
                // Выделим имя таблицы и имя вычисляемого поля
                DelimeterPos := AnsiPos(COMPUTED_FIELD_DELIMITER, FMetadataName);
                ComputedTableName := StrLeft(FMetadataName, DelimeterPos - 1);
                ComputedFieldName := StrRight(FMetadataName, StrLength(FMetadataName) - DelimeterPos);
                // Восстановим гранты и позицию вычисляемого поля
                FgsFunctionEditor.RestoreGrant(ComputedFieldName, ComputedTableName);
                FgsFunctionEditor.RestorePosition(ComputedTableName, ComputedFieldName);
                // Визуализация процесса
                Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsComputedFieldModified), [FMetadataName]),
                  FMetadataMaxProgress, FMetadataCurrentProgress);
              end;

              idAbort:
              begin
                raise EgsInterruptConvertProcess.Create('');
              end;
            else
              // Визуализация процесса
              Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsComputedFieldSkipped), [FMetadataName]),
                FMetadataMaxProgress, FMetadataCurrentProgress);
            end;
          end;
        end;
      end;
    except
      // При редактировании могли остаться ошибки - снова отобразим диалог редактирования
      on E: EIBInterbaseError do
      begin
        FMetadataText := NewFunctionText;
        FMetadataError := E.Message;
        SynchronizeMethod(OnMetadataEditError);
      end;
    end;
  end
  else
  begin
    case FEditMetadataType of
      mtProcedure:
        Controller.ModelObject.MetadataProgressRoutine(
          Format('%s %s. %s', [GetLocalizedString(lsProcedureError), FMetadataName, GetLocalizedString(lsObjectLeftCommented)]),
          FMetadataMaxProgress, FMetadataCurrentProgress);

      mtTrigger:
        Controller.ModelObject.MetadataProgressRoutine(
          Format('%s %s. %s', [GetLocalizedString(lsTriggerError), FMetadataName, GetLocalizedString(lsObjectLeftCommented)]),
          FMetadataMaxProgress, FMetadataCurrentProgress);

      mtView:
        Controller.ModelObject.MetadataProgressRoutine(
          Format('%s %s. %s', [GetLocalizedString(lsViewError), FMetadataName, GetLocalizedString(lsObjectLeftCommented)]),
          FMetadataMaxProgress, FMetadataCurrentProgress);

      mtComputedField:
        Controller.ModelObject.MetadataProgressRoutine(
          Format('%s %s. %s', [GetLocalizedString(lsComputedFieldError), FMetadataName, GetLocalizedString(lsObjectLeftCommented)]),
          FMetadataMaxProgress, FMetadataCurrentProgress);
    end;
  end;
end;

procedure TgsConvertThread.ProcessProcedures;
var
  FunctionList: TStringList;
  FunctionText: String;
  MetadataCounter: Integer;
begin
  FunctionList := TStringList.Create;
  try
    // Укажем что идет редактирование хранимых процедур
    FEditMetadataType := mtProcedure;
    // Получим список процедур для обработки
    FgsFunctionEditor.GetProcedureList(FunctionList);
    // Визуализация процесса
    FMetadataMaxProgress := FunctionList.Count;
    FMetadataCurrentProgress := 0;
    if not FIsRestoringMetadata then
    begin
      Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsProcedureProcessStart)]),
        FMetadataMaxProgress, FMetadataCurrentProgress);
      Controller.SetCurrentStepMessage(GetLocalizedString(lsProcedureProcessStart));
    end
    else
    begin
      Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsProcedureProcessFinish)]),
        FMetadataMaxProgress, FMetadataCurrentProgress);
      Controller.SetCurrentStepMessage(GetLocalizedString(lsProcedureProcessFinish));
    end;

    // Пройдем по списку процедур
    for MetadataCounter := 0 to FunctionList.Count - 1 do
    begin
      // Визуализация процесса
      FMetadataCurrentProgress := MetadataCounter + 1;
      Controller.ModelObject.MetadataProgressRoutine('  ' + FunctionList[MetadataCounter], FMetadataMaxProgress, FMetadataCurrentProgress);
      try
        // Закомментируем\Откомментируем тело процедуры FunctionList[MetadataCounter]
        FunctionText := FgsFunctionEditor.GetProcedureText(FunctionList[MetadataCounter]);
        // В зависимости от установленного флага будем комментировать, или же убирать комментарии
        if not FIsRestoringMetadata then
        begin
          if FgsFunctionEditor.CommentFunctionBody(FunctionText, True) then
            FgsFunctionEditor.SetProcedureText(FunctionText);
        end
        else
        begin
          // Заменим вызовы функций на новые
          if FgsFunctionEditor.ReplaceSubstituteUDFFunction(FunctionText) then
            FgsFunctionEditor.SetProcedureText(FunctionText);
          // Откомментиреум процедуру
          if FgsFunctionEditor.UncommentFunctionBody(FunctionText) then
            FgsFunctionEditor.SetProcedureText(FunctionText);
        end;
      except
        on E: EIBInterbaseError do
        begin
          FMetadataName := FunctionList[MetadataCounter];
          FMetadataText := FunctionText;
          FMetadataError := E.Message;
          SynchronizeMethod(OnMetadataEditError);
        end;
      end;
    end;
    // Визуализация процесса
    FMetadataMaxProgress := FMetadataCurrentProgress;
    Controller.ModelObject.MetadataProgressRoutine('', FMetadataMaxProgress, FMetadataCurrentProgress);
    Controller.SetCurrentStepMessage('');
  finally
    FreeAndNil(FunctionList);
  end;
end;

procedure TgsConvertThread.ProcessTriggers;
var
  FunctionList: TStringList;
  FunctionText: String;
  MetadataCounter: Integer;
begin
  FunctionList := TStringList.Create;
  try
    // Укажем что идет редактирование триггеров
    FEditMetadataType := mtTrigger;
    // Получим список триггеров для обработки
    FgsFunctionEditor.GetTriggerList(FunctionList);
    // Визуализация процесса
    FMetadataMaxProgress := FunctionList.Count;
    FMetadataCurrentProgress := 0;

    if not FIsRestoringMetadata then
    begin
      Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsTriggerProcessStart)]),
        FMetadataMaxProgress, FMetadataCurrentProgress);
      Controller.SetCurrentStepMessage(GetLocalizedString(lsTriggerProcessStart));
    end
    else
    begin
      Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsTriggerProcessFinish)]),
        FMetadataMaxProgress, FMetadataCurrentProgress);
      Controller.SetCurrentStepMessage(GetLocalizedString(lsTriggerProcessFinish));
    end;

    // Пройдем по списку триггеров
    for MetadataCounter := 0 to FunctionList.Count - 1 do
    begin
      // Визуализация процесса
      FMetadataCurrentProgress := MetadataCounter + 1;
      Controller.ModelObject.MetadataProgressRoutine('  ' + FunctionList[MetadataCounter], FMetadataMaxProgress, FMetadataCurrentProgress);
      try
        // Закомментируем\Откомментируем тело триггера FunctionList[MetadataCounter]
        FunctionText := FgsFunctionEditor.GetTriggerText(FunctionList[MetadataCounter]);
        // В зависимости от установленного флага будем комментировать, или же убирать комментарии
        if not FIsRestoringMetadata then
        begin
          if FgsFunctionEditor.CommentFunctionBody(FunctionText) then
            FgsFunctionEditor.SetTriggerText(FunctionText);
        end
        else
        begin
          // Заменим вызовы функций на новые
          if FgsFunctionEditor.ReplaceSubstituteUDFFunction(FunctionText) then
            FgsFunctionEditor.SetTriggerText(FunctionText);
          // Откомментируем триггер
          if FgsFunctionEditor.UncommentFunctionBody(FunctionText) then
            FgsFunctionEditor.SetTriggerText(FunctionText);
        end;
      except
        on E: EIBInterbaseError do
        begin
          FMetadataName := FunctionList[MetadataCounter];
          FMetadataText := FunctionText;
          FMetadataError := E.Message;
          SynchronizeMethod(OnMetadataEditError);
        end;
      end;
    end;
    // Визуализация процесса
    FMetadataMaxProgress := FMetadataCurrentProgress;
    Controller.ModelObject.MetadataProgressRoutine('', FMetadataMaxProgress, FMetadataCurrentProgress);
    Controller.SetCurrentStepMessage('');
  finally
    FreeAndNil(FunctionList);
  end;
end;

procedure TgsConvertThread.ProcessViewsAndComputedFields;
var
  FunctionList: TStringList;
  MetadataText: String;
  MetadataCounter, DelimeterPos: Integer;
  ComputedTableName, ComputedFieldName: String;
begin
  // Скопируем\восстановим представления и вычисляемые поля
  FunctionList := TStringList.Create;
  try
    if not FIsRestoringMetadata then
      FgsFunctionEditor.GetViewAndComputedFieldList(FunctionList)
    else
      FgsFunctionEditor.GetBackupViewAndComputedFieldList(FunctionList);

    // Визуализация процесса
    FMetadataMaxProgress := FunctionList.Count;
    FMetadataCurrentProgress := 0;
    if not FIsRestoringMetadata then
    begin
      Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsViewFieldsProcessStart)]),
        FMetadataMaxProgress, FMetadataCurrentProgress);
      Controller.SetCurrentStepMessage(GetLocalizedString(lsViewFieldsProcessStart));
    end
    else
    begin
      Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsViewFieldsProcessFinish)]),
        FMetadataMaxProgress, FMetadataCurrentProgress);
      Controller.SetCurrentStepMessage(GetLocalizedString(lsViewFieldsProcessFinish));
    end;

    // Пройдем по списку представлений и вычисляемых полей
    for MetadataCounter := 0 to FunctionList.Count - 1 do
    begin
      // Визуализация процесса
      FMetadataCurrentProgress := MetadataCounter + 1;
      Controller.ModelObject.MetadataProgressRoutine('  ' + FunctionList[MetadataCounter], FMetadataMaxProgress, FMetadataCurrentProgress);
      try
        // Определим что за элемент списка, представление или выч. поле
        DelimeterPos := AnsiPos(COMPUTED_FIELD_DELIMITER, FunctionList[MetadataCounter]);
        if DelimeterPos = 0 then
        begin
          // Укажем что идет редактирование представлений
          FEditMetadataType := mtView;
          // Если идет архивация метаданных
          if not FIsRestoringMetadata then
          begin
            FgsFunctionEditor.BackupView(FunctionList[MetadataCounter]);
            FgsFunctionEditor.DeleteView(FunctionList[MetadataCounter]);
          end
          else
          begin
            MetadataText := FgsFunctionEditor.GetBackupViewText(FunctionList[MetadataCounter]);
            FgsFunctionEditor.SetViewText(MetadataText);
            FgsFunctionEditor.RestoreGrant(FunctionList[MetadataCounter]);
          end;
        end
        else
        begin
          // Укажем что идет редактирование вычисляемых полей
          FEditMetadataType := mtComputedField;
          // Выделим имя таблицы и имя вычисляемого поля
          ComputedTableName := StrLeft(FunctionList[MetadataCounter], DelimeterPos - 1);
          ComputedFieldName := StrRight(FunctionList[MetadataCounter], StrLength(FunctionList[MetadataCounter]) - DelimeterPos);
          // Если идет архивация метаданных
          if not FIsRestoringMetadata then
          begin
            FgsFunctionEditor.BackupComputedField(ComputedTableName, ComputedFieldName);
            FgsFunctionEditor.DeleteComputedField(ComputedTableName, ComputedFieldName);
          end
          else
          begin
            MetadataText := FgsFunctionEditor.GetBackupComputedFieldText(ComputedTableName, ComputedFieldName);
            FgsFunctionEditor.SetComputedFieldText(MetadataText);
            FgsFunctionEditor.RestoreGrant(ComputedFieldName, ComputedTableName);
            FgsFunctionEditor.RestorePosition(ComputedTableName, ComputedFieldName);
          end;
        end;
      except
        on E: EIBInterbaseError do
        begin
          FMetadataName := FunctionList[MetadataCounter];
          FMetadataError := E.Message;
          FMetadataText := MetadataText;
          SynchronizeMethod(OnMetadataEditError);
        end;
      end;
    end;
    // Визуализация процесса
    FMetadataMaxProgress := FMetadataCurrentProgress;
    Controller.ModelObject.MetadataProgressRoutine('', FMetadataMaxProgress, FMetadataCurrentProgress);
    Controller.SetCurrentStepMessage('');
  finally
    FreeAndNil(FunctionList);
  end;
end;

procedure TgsConvertThread.OnInterruptedProcess;
begin
  // Обработаем прерывание выполнения процесса (вызванное пользователем или исключением)
  Controller.ViewInterruptedProcessInformation(FMessage);
  // Очистим сообщение об ошибке
  FMessage := '';
end;

procedure TgsConvertThread.SynchronizeMethod(Method: TThreadMethod);
begin
  if Assigned(Controller.ProcessForm) then
    Synchronize(Method)
  else
    Method;
end;

end.
