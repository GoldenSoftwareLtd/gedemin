unit gsFDBConvertLocalization_unit;

interface

type
  // Идентификаторы локализованных строк
  TgsLocalizedStringID =
    (
     lsApplicationCaption,
     lsEmptyLocalizedEntry,
     lsPressAnyButton,
     lsFileNotFound,
     lsFileDoesntExists,
     lsDirectoryAccessError,
     lsUnknownDatabaseType,
     lsUnknownServerType,
     lsLanguageNotFound,
     lsWrongSubstituteFile,
     lsCharsetListNotFound,
     lsEnterDatabasePath,
     lsUnknownParameterValue,
     lsDatabasePreprocessInformation,
     lsStep01,
     lsHello,
     lsLanguage,
     lsStep02,
     lsDatabaseBrowseDescription,
     lsStep03,
     lsStep03Group01,
     lsStep03Group02,
     lsStep03Group03,
     lsOriginalDatabase,
     lsOriginalBackup,
     lsResultDatabaseName,
     lsOriginalDBVersion,
     lsOriginalServerVersion,
     lsNewServerVersion,
     lsBackupName,
     lsTempDatabaseName,
     lsPageSize,
     lsPageSize_02,
     lsBufferSize,
     lsBufferSize_02,
     lsCharacterSet,
     lsStep04,
     lsOriginalFunction,
     lsSubstituteFunction,
     lsStep04Comment,
     lsDeleteUDF,
     lsStep05,
     lsStep06,
     lsStep07,
     lsStep07Comment,
     lsPrevButton,
     lsNextButton,
     lsExitButton,
     lsDatabaseBrowseButton,
     lsBAKDatabaseCopy,
     lsProcessSuccessfullEnd,
     lsNewDatabaseNameFinalMessage,
     lsOriginalDatabaseNameFinalMessage,
     lsProcessInterruptedEnd,
     lsOriginalDatabaseNameInterruptMessage,
     lsOriginalBackupNameInterruptMessage,
     lsStartConvertQuestion,
     lsNoDiskSpaceForTempFiles,
     lsNoDiskSpaceForDBCopy,
     lsNoDiskSpaceForBackup,
     lsDirectoryNotWritable,
     lsWantDiskSpace,
     lsDiskSpaceQuantifier,
     lsEditingMetadataError,
     lsRestoreWithServer,
     lsProcedureProcessStart,
     lsProcedureProcessFinish,
     lsProcedureModified,
     lsProcedureSkipped,
     lsProcedureError,
     lsTriggerProcessStart,
     lsTriggerProcessFinish,
     lsTriggerModified,
     lsTriggerSkipped,
     lsTriggerError,
     lsViewFieldsProcessStart,
     lsViewFieldsProcessFinish,
     lsComputedFieldProcessStartError,
     lsComputedFieldProcessFinishError,
     lsViewModified,
     lsViewSkipped,
     lsViewError,
     lsComputedFieldModified,
     lsComputedFieldSkipped,
     lsComputedFieldError, 
     lsObjectLeftCommented,
     lsDatabaseFileCopyingProcess,
     lsDatabaseBackupProcess,
     lsDatabaseBackupProcessError,
     lsDatabaseRestoreProcess,
     lsDatabaseRestoreProcessError,
     lsDatabaseValidationProcess,
     lsDatabaseValidationProcessError,
     lsDatabaseNULLCheckProcess,
     lsDatabaseNULLCheckMessage,
     lsDatabaseNULLCheckProcessError,
     lsContinueCheckingQuestion,
     lsContinueConvertingQuestion,
     lsCircularReferenceError,
     lsChooseDatabaseMessage,
     lsInformationDialogCaption,
     lsFEProcedureEditCaption,
     lsFEProcedureErrorCaption,
     lsFETriggerEditCaption,
     lsFETriggerErrorCaption,
     lsFEViewEditCaption,
     lsFEViewErrorCaption,
     lsFEComputedFieldEditCaption,
     lsFEComputedFieldErrorCaption,
     lsFEStopConvert,
     lsFESaveMetadata,
     lsFEDoComment,
     lsFEDoUncomment,
     lsFEDoShowError,
     lsAllFilesBrowseMask,
     lsDatabaseBrowseMask,
     lsBackupBrowseMask,
     lsLastID
    );

  function GetLocalizedString(const ALocStringID: TgsLocalizedStringID): String;
  procedure LoadLanguageStrings(const ALanguageName: String);
  function LanguageLoadedOnStartup: String;

implementation

uses
  classes, typinfo, sysutils, gsFDBConvertHelper_unit, jclStrings, windows;

const
  MULTILINE_FIRSTLINE_MARK = 1;
  MULTILINE_SEPARATOR = ' ';
  DOUBLE_SLASH_DUMMY = '/\\/';

  LANG_BELARUSIAN_NAME = 'Беларуская';
  LANG_RUSSIAN_NAME = 'Русский';
  LANG_ENGLISH_NAME = 'English';

var
  LocalizedStringArray: array [0..(Integer(lsLastID) - 1)] of String;
  LanguageLoadedOnStartupName: String;

function LanguageLoadedOnStartup: String;
begin
  Result := LanguageLoadedOnStartupName;
end;

procedure ProcessControlChar(var AString: String);
begin
  // временно заменим двойные слэши
  StrReplace(AString, '\\', DOUBLE_SLASH_DUMMY, [rfReplaceAll, rfIgnoreCase]);
  // перенос на новую строку
  StrReplace(AString, '\n', #13#10, [rfReplaceAll, rfIgnoreCase]);
  // табуляция
  StrReplace(AString, '\t', #9, [rfReplaceAll, rfIgnoreCase]);
  // вернем обратно двойные слэши
  StrReplace(AString, DOUBLE_SLASH_DUMMY, '\\', [rfReplaceAll, rfIgnoreCase]);
  // слэш
  StrReplace(AString, '\\', '\', [rfReplaceAll, rfIgnoreCase]);
end;

function LocalizedStringTypeToString(const ALocalizedStringType: TgsLocalizedStringID): String;
begin
  Result := GetEnumName(TypeInfo(TgsLocalizedStringID), Integer(ALocalizedStringType));
end;

function StringToLocalizedStringType(const ALocalizedStringTypeStr: String): TgsLocalizedStringID;
var
  I: Integer;
begin
  Result := lsEmptyLocalizedEntry;
  if ALocalizedStringTypeStr > '' then
  begin
    I := GetEnumValue(TypeInfo(TgsLocalizedStringID), ALocalizedStringTypeStr);
    if I <> -1 then
    begin
      Result := TgsLocalizedStringID(I);
      Exit;
    end;
  end;
end;

function GetLocalizedString(const ALocStringID: TgsLocalizedStringID): String;
begin
  Result := LocalizedStringArray[Integer(ALocStringID)];
end;

procedure SetLocalizedString(const ALocStringID: TgsLocalizedStringID; const AString: String);
begin
  LocalizedStringArray[Integer(ALocStringID)] := AString;
end;

procedure SetLanguageOnKeybordLayout;
var
  Ch: array[0..KL_NAMELENGTH] of Char;
  KeboardLayout: Integer;
begin
  LanguageLoadedOnStartupName := '';

  GetKeyboardLayoutName(Ch);

  KeboardLayout := StrToInt('$' + String(Ch));
  try
    case (KeboardLayout and $3ff) of
      LANG_BELARUSIAN:
      begin
        LoadLanguageStrings(LANG_BELARUSIAN_NAME);
        LanguageLoadedOnStartupName := LANG_BELARUSIAN_NAME;
      end;

      LANG_RUSSIAN:
      begin
        LoadLanguageStrings(LANG_RUSSIAN_NAME);
        LanguageLoadedOnStartupName := LANG_RUSSIAN_NAME;
      end;

      LANG_ENGLISH:
      begin
        LoadLanguageStrings(LANG_ENGLISH_NAME);
        LanguageLoadedOnStartupName := LANG_ENGLISH_NAME;
      end;
    else
      LoadLanguageStrings(LANG_ENGLISH_NAME);
      LanguageLoadedOnStartupName := LANG_ENGLISH_NAME;
    end;
  except
    // Если не получилось загрузить язык на основании расклдаки клавиатуры
    // загрузим его потом в форме, или останется язык по умолчанию в консоли
  end;
end;

procedure LoadLanguageStrings(const ALanguageName: String);
var
  LanguageStrings: TStringList;
  LocStringCounter: Integer;
  LocIDString: String;
  LocValue, TempS: String;
  LocID: TgsLocalizedStringID;
  MultiLineSymbolIndex: Integer;
  MultiLineNumberString: String;
begin
  LanguageStrings := TStringList.Create;
  try
    // Загрузим локализацию из файла
    TgsConfigFileManager.GetLanguageContent(ALanguageName, LanguageStrings);
    // Занесем строки локализации в массив
    for LocStringCounter := 0 to LanguageStrings.Count - 1 do
    begin
      LocIDString := LanguageStrings.Names[LocStringCounter];
      LocValue := LanguageStrings.Values[LocIDString];
      // обработаем контрольные символы
      ProcessControlChar(LocValue);
      // возможно запись содержит несколько строк, типа lsLine.1, lsLine.2, lsLine.3
      MultiLineSymbolIndex := StrFind('.', LocIDString);
      if MultiLineSymbolIndex > 0 then
      begin
        LocID := StringToLocalizedStringType(StrLeft(LocIDString, MultiLineSymbolIndex - 1));
        // если идентификатор элемента локализации верен
        if LocID <> lsEmptyLocalizedEntry then
        begin
          // найдем номер строки в мультистроковом элементе
          MultiLineNumberString := Trim(StrRight(LocIDString, StrLength(LocIDString) - MultiLineSymbolIndex));
          if StrIsDigit(MultiLineNumberString) then
          begin
            // если номер строки = MULTILINE_FIRSTLINE_MARK, то заменяем системный элемент считанным,
            //  иначе дописываем системный элемент считанными данными,
            //  разделяя их пробелом
            if StrToInt(MultiLineNumberString) = MULTILINE_FIRSTLINE_MARK then
              SetLocalizedString(LocID, LocValue)
            else
            begin
              TempS := GetLocalizedString(LocID);
              if Copy(TempS, Length(TempS), 1) > ' ' then
                TempS := TempS + MULTILINE_SEPARATOR;
              SetLocalizedString(LocID, TempS + LocValue);
            end;
          end;
        end;
      end
      else
      begin
        LocID := StringToLocalizedStringType(LocIDString);
        // если идентификатор элемента локализации верен
        if LocID <> lsEmptyLocalizedEntry then
          // установим элемент локализации в систему
          SetLocalizedString(LocID, LocValue);
      end;
    end;
  finally
    FreeAndNil(LanguageStrings);
  end;
end;

procedure __SetDefaultValues;
begin
  SetLocalizedString(lsApplicationCaption, 'FDB Converter');
  SetLocalizedString(lsPressAnyButton, 'Нажмите любую клавишу...');
  SetLocalizedString(lsFileNotFound, 'Файл не найден');
  SetLocalizedString(lsFileDoesntExists, 'Файл %0:s не существует.');
  SetLocalizedString(lsDirectoryAccessError, 'Ошибка доступа к директории');
  SetLocalizedString(lsUnknownDatabaseType, 'Неизвестный тип БД');
  SetLocalizedString(lsUnknownServerType, 'Неизвестный тип сервера');
  SetLocalizedString(lsLanguageNotFound, 'Не найден язык %0:s в файле локализаций!');
  SetLocalizedString(lsWrongSubstituteFile, 'Неверный формат файла заменяемых функций!');
  SetLocalizedString(lsCharsetListNotFound, 'Не найден список кодовых страниц в файле данных приложения!');
  SetLocalizedString(lsEnterDatabasePath, 'Введите путь к конвертируемой БД:');
  SetLocalizedString(lsUnknownParameterValue, 'неизвестно');
  SetLocalizedString(lsDatabasePreprocessInformation, 'Предварительная информация о конвертации БД');

  SetLocalizedString(lsStep01, 'Приветствие');
  SetLocalizedString(lsHello, 'Приветствие');
  SetLocalizedString(lsLanguage, 'Язык интерфейса');
  SetLocalizedString(lsStep02, 'Выбор файла базы данных');
  SetLocalizedString(lsDatabaseBrowseDescription, 'Выберите базу данных или файл архива базы данных');
  SetLocalizedString(lsStep03, 'Подробная информация');
  SetLocalizedString(lsStep03Group01, 'Временные файлы. Будут удалены по окончании процесса');
  SetLocalizedString(lsStep03Group02, 'Исходная база данных');
  SetLocalizedString(lsStep03Group03, 'Сконвертированная база данных');
  SetLocalizedString(lsOriginalDatabase, 'Исходная база данных');
  SetLocalizedString(lsOriginalBackup, 'Исходный архивный файл');
  SetLocalizedString(lsResultDatabaseName, 'Конечная база данных');
  SetLocalizedString(lsOriginalDBVersion, 'Версия исходной БД');
  SetLocalizedString(lsOriginalServerVersion, 'Исходный сервер');
  SetLocalizedString(lsNewServerVersion, 'Новый сервер');
  SetLocalizedString(lsBackupName, 'Архивный файл');
  SetLocalizedString(lsTempDatabaseName, 'Временная БД');
  SetLocalizedString(lsPageSize, 'Размер страницы');
  SetLocalizedString(lsPageSize_02, 'байт');
  SetLocalizedString(lsBufferSize, 'Размер буфера');
  SetLocalizedString(lsBufferSize_02, 'страниц');
  SetLocalizedString(lsCharacterSet, 'Кодовая страница');
  SetLocalizedString(lsStep04, 'Заменяемые функции');
  SetLocalizedString(lsOriginalFunction, 'Заменяемая функция');
  SetLocalizedString(lsSubstituteFunction, 'Заменяющая функция');
  SetLocalizedString(lsStep04Comment, 'Список функций можно изменять');
  SetLocalizedString(lsDeleteUDF, 'Удаляемые функции');
  SetLocalizedString(lsStep05, 'Информация');
  SetLocalizedString(lsStep06, 'Ход процесса');
  SetLocalizedString(lsStep07, 'Реклама');
  SetLocalizedString(lsStep07Comment, 'Реклама');
  SetLocalizedString(lsPrevButton, 'Назад');
  SetLocalizedString(lsNextButton, 'Далее');
  SetLocalizedString(lsExitButton, 'Выйти');
  SetLocalizedString(lsDatabaseBrowseButton, 'Обзор');            
  SetLocalizedString(lsBAKDatabaseCopy, 'BAK файл');

  SetLocalizedString(lsProcessSuccessfullEnd, 'Процесс завершен успешно');
  SetLocalizedString(lsNewDatabaseNameFinalMessage, 'Сконвертированная база данных сохранена под именем:');
  SetLocalizedString(lsOriginalDatabaseNameFinalMessage, 'Оригинальная база данных сохранена под именем:');
  SetLocalizedString(lsProcessInterruptedEnd, 'Процесс конвертации прерван');
  SetLocalizedString(lsOriginalDatabaseNameInterruptMessage, 'Оригинальная данных сохранена под именем:');
  SetLocalizedString(lsOriginalBackupNameInterruptMessage, 'Оригинальная база данных оставлена без изменений');
  SetLocalizedString(lsStartConvertQuestion, 'Начать конвертирование');
  SetLocalizedString(lsNoDiskSpaceForTempFiles, 'Не хватает места на диске для временных файлов');
  SetLocalizedString(lsNoDiskSpaceForDBCopy, 'Не хватает места на диске для копии БД');
  SetLocalizedString(lsNoDiskSpaceForBackup, 'Не хватает места на диске для архива БД');
  SetLocalizedString(lsDirectoryNotWritable, 'Ошибка доступа к диску: директория программы недоступна для записи');
  SetLocalizedString(lsWantDiskSpace, 'Необходимо: %d МБ');
  SetLocalizedString(lsEditingMetadataError, 'В процессе редактирования метаданных произошла ошибка');
  SetLocalizedString(lsRestoreWithServer, 'Восстановление базы данных с помощью сервера');
  SetLocalizedString(lsProcedureProcessStart, 'Комментирование хранимых процедур');
  SetLocalizedString(lsProcedureProcessFinish, 'Удаление комментариев из хранимых процедур');
  SetLocalizedString(lsProcedureModified, 'Процедура %s изменена');
  SetLocalizedString(lsProcedureSkipped, 'Процедура %s пропущена. Необходимо ручное изменение.');
  SetLocalizedString(lsProcedureError, 'Ошибка при сохранении хранимой процедуры');
  SetLocalizedString(lsTriggerProcessStart, 'Комментирование триггеров');
  SetLocalizedString(lsTriggerProcessFinish, 'Удаление комментариев из триггеров');
  SetLocalizedString(lsTriggerModified, 'Триггер %s изменен');
  SetLocalizedString(lsTriggerSkipped, 'Триггер %s пропущен. Необходимо ручное изменение.');
  SetLocalizedString(lsTriggerError, 'Ошибка при сохранении триггера');
  SetLocalizedString(lsViewFieldsProcessStart, 'Архивирование представлений и вычисляемых полей');
  SetLocalizedString(lsViewFieldsProcessFinish, 'Восстановление представлений и вычисляемых полей');
  SetLocalizedString(lsComputedFieldProcessStartError, 'Ошибка при архивировании вычисляемого поля');
  SetLocalizedString(lsComputedFieldProcessFinishError, 'Ошибка при восстановлении вычисляемого поля');
  SetLocalizedString(lsViewModified, 'Представление %s измененено');
  SetLocalizedString(lsViewSkipped, 'Представление %s пропущено, и не восстановлено. Необходимо ручное восстановление.');
  SetLocalizedString(lsViewError, 'Ошибка при сохранении представления');
  SetLocalizedString(lsComputedFieldModified, 'Вычисляемое поле %s измененено');
  SetLocalizedString(lsComputedFieldSkipped, 'Вычисляемое поле %s пропущено, и не восстановлено. Необходимо ручное восстановление.');
  SetLocalizedString(lsComputedFieldError, 'Ошибка при сохранении вычисляемого поля');
  SetLocalizedString(lsObjectLeftCommented, 'Объект оставлен закомментированным.');
  
  SetLocalizedString(lsDatabaseFileCopyingProcess, 'Копирование файла базы данных');
  SetLocalizedString(lsDatabaseBackupProcess, 'Архивация базы данных');
  SetLocalizedString(lsDatabaseBackupProcessError, 'В процессе архивации базы данных произошла ошибка');
  SetLocalizedString(lsDatabaseRestoreProcess, 'Восстановление базы данных');
  SetLocalizedString(lsDatabaseRestoreProcessError, 'В процессе восстановления базы данных произошла ошибка');
  SetLocalizedString(lsDatabaseValidationProcess, 'Проверка базы данных');
  SetLocalizedString(lsDatabaseValidationProcessError, 'В процессе проверки базы данных произошла ошибка');
  SetLocalizedString(lsDatabaseNULLCheckProcess, 'Проверка базы данных на NULL значения');
  SetLocalizedString(lsContinueCheckingQuestion, 'Продолжить проверку?');
  SetLocalizedString(lsContinueConvertingQuestion, 'Продолжить процесс конвертации?');
  SetLocalizedString(lsDatabaseNULLCheckMessage, 'В колонке "%s" таблицы "%s" присутствуют недопустимые NULL значения');
  SetLocalizedString(lsDatabaseNULLCheckProcessError, 'В процессе проверки базы данных на NULL значения произошла ошибка');
  SetLocalizedString(lsCircularReferenceError, 'Удаляемые представления и вычисляемые поля находятся в циклической зависимости');

  SetLocalizedString(lsChooseDatabaseMessage, 'Выберите базу данных для конвертации');
  SetLocalizedString(lsInformationDialogCaption, 'Внимание');

  SetLocalizedString(lsFEProcedureEditCaption, 'Редактирование хранимой процедуры');
  SetLocalizedString(lsFEProcedureErrorCaption, 'Произошла ошибка при сохранении хранимой процедуры');
  SetLocalizedString(lsFETriggerEditCaption, 'Редактирование триггера');
  SetLocalizedString(lsFETriggerErrorCaption, 'Произошла ошибка при сохранении триггера');
  SetLocalizedString(lsFEViewEditCaption, 'Редактирование представления');
  SetLocalizedString(lsFEViewErrorCaption, 'Произошла ошибка при сохранении представления');
  SetLocalizedString(lsFEComputedFieldEditCaption, 'Редактирование вычисляемого поля');
  SetLocalizedString(lsFEComputedFieldErrorCaption, 'Произошла ошибка при компиляции вычисляемого поля');
  SetLocalizedString(lsFEStopConvert, 'Прервать конвертацию БД');
  SetLocalizedString(lsFESaveMetadata, 'Сохранить');
  SetLocalizedString(lsFEDoComment, 'Закомментировать');
  SetLocalizedString(lsFEDoUncomment, 'Откомментировать');
  SetLocalizedString(lsFEDoShowError, 'Показать текст ошибки');

  SetLocalizedString(lsAllFilesBrowseMask, 'Все файлы');
  SetLocalizedString(lsDatabaseBrowseMask, 'База данных');
  SetLocalizedString(lsBackupBrowseMask, 'Архив базы данных');

end;

initialization
  __SetDefaultValues;
  SetLanguageOnKeybordLayout;
end.
