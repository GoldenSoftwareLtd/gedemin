unit gsFDBConvertLocalization_unit;

interface

type
  // Идентификаторы локализованных строк
  TgsLocalizedStringID =
    (
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
     lsStep05,
     lsStep06,
     lsStep07,
     lsStep08,
     lsPrevButton,
     lsNextButton,
     lsExitButton,
     lsDatabaseBrowseButton,
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
     lsWantDiskSpace,
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
     lsViewFieldsProcessStartError,
     lsViewFieldsProcessFinishError,
     lsViewModified,
     lsViewSkipped,
     lsViewError,
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
     lsCircularReferenceError,
     lsChooseDatabaseMessage,
     lsInformationDialogCaption,
     lsFEParamsCaption,
     lsFEProcedureCaption,
     lsFEProcedureEditCaption,
     lsFEProcedureErrorCaption,
     lsFETriggerCaption,
     lsFETriggerEditCaption,
     lsFETriggerErrorCaption,
     lsFEViewCaption,
     lsFEViewEditCaption,
     lsFEViewErrorCaption,
     lsFEStopConvert,
     lsFESaveMetadata,
     lsFESkipMetadata,
     lsAllFilesBrowseMask,
     lsDatabaseBrowseMask,
     lsBackupBrowseMask,
     lsLastID
    );

  function GetLocalizedString(const ALocStringID: TgsLocalizedStringID): String;
  procedure LoadLanguageStrings(const ALanguageName: String);

implementation

uses
  classes, typinfo, sysutils, gsFDBConvertHelper_unit;

var
  LocalizedStringArray: array [0..(Integer(lsLastID) - 1)] of String;

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

procedure LoadLanguageStrings(const ALanguageName: String);
var
  LanguageStrings: TStringList;
  LocStringCounter: Integer;
  LocIDString: String;
  LocID: TgsLocalizedStringID;
begin
  LanguageStrings := TStringList.Create;
  try
    // Загрузим локализацию из файла
    TgsConfigFileManager.GetLanguageContent(ALanguageName, LanguageStrings);
    // Занесем строки локализации в массив
    for LocStringCounter := 0 to LanguageStrings.Count - 1 do
    begin
      LocIDString := LanguageStrings.Names[LocStringCounter];
      LocID := StringToLocalizedStringType(LocIDString);
      if LocID <> lsEmptyLocalizedEntry then
        SetLocalizedString(LocID, LanguageStrings.Values[LocIDString]);
    end;
  finally
    FreeAndNil(LanguageStrings);
  end;
end;

procedure __SetDefaultValues;
begin
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
  SetLocalizedString(lsStep05, 'Информация');
  SetLocalizedString(lsStep06, 'Ход процесса');
  SetLocalizedString(lsStep07, 'Завершение');
  SetLocalizedString(lsStep08, 'Реклама');
  SetLocalizedString(lsPrevButton, 'Назад');
  SetLocalizedString(lsNextButton, 'Далее');
  SetLocalizedString(lsExitButton, 'Выйти');
  SetLocalizedString(lsDatabaseBrowseButton, 'Обзор');

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
  SetLocalizedString(lsViewFieldsProcessStartError, 'Ошибка при архивировании');
  SetLocalizedString(lsViewFieldsProcessFinishError, 'Ошибка при восстановлении');
  SetLocalizedString(lsViewModified, 'Представление %s измененено');
  SetLocalizedString(lsViewSkipped, 'Представление %s пропущено, и не восстановлено. Необходимо ручное восстановление.');
  SetLocalizedString(lsViewError, 'Ошибка при сохранении представления');
  SetLocalizedString(lsObjectLeftCommented, 'Объект оставлен закомментированным.');

  SetLocalizedString(lsDatabaseFileCopyingProcess, 'Копирование файла базы данных');
  SetLocalizedString(lsDatabaseBackupProcess, 'Архивация базы данных');
  SetLocalizedString(lsDatabaseBackupProcessError, 'В процессе архивации базы данных произошла ошибка');
  SetLocalizedString(lsDatabaseRestoreProcess, 'Восстановление базы данных');
  SetLocalizedString(lsDatabaseRestoreProcessError, 'В процессе восстановления базы данных произошла ошибка');
  SetLocalizedString(lsDatabaseValidationProcess, 'Проверка базы данных');
  SetLocalizedString(lsDatabaseValidationProcessError, 'В процессе проверки базы данных произошла ошибка');
  SetLocalizedString(lsDatabaseNULLCheckProcess, 'Проверка базы данных на NULL значения');
  SetLocalizedString(lsDatabaseNULLCheckMessage, 'В колонке "%s" таблицы "%s" присутствуют недопустимые NULL значения');
  SetLocalizedString(lsDatabaseNULLCheckProcessError, 'В процессе проверки базы данных на NULL значения произошла ошибка');
  SetLocalizedString(lsCircularReferenceError, 'Удаляемые представления и вычисляемые поля находятся в циклической зависимости');

  SetLocalizedString(lsChooseDatabaseMessage, 'Выберите базу данных для конвертации');
  SetLocalizedString(lsInformationDialogCaption, 'Внимание');

  SetLocalizedString(lsFEParamsCaption, 'Параметры');
  SetLocalizedString(lsFEProcedureCaption, 'Хранимая процедура');
  SetLocalizedString(lsFEProcedureEditCaption, 'Редактирование хранимой процедуры');
  SetLocalizedString(lsFEProcedureErrorCaption, 'Произошла ошибка при сохранении хранимой процедуры');
  SetLocalizedString(lsFETriggerCaption, 'Триггер');
  SetLocalizedString(lsFETriggerEditCaption, 'Редактирование триггера');
  SetLocalizedString(lsFETriggerErrorCaption, 'Произошла ошибка при сохранении триггера');
  SetLocalizedString(lsFEViewCaption, 'Представление');
  SetLocalizedString(lsFEViewEditCaption, 'Редактирование представления');
  SetLocalizedString(lsFEViewErrorCaption, 'Произошла ошибка при сохранении представления');
  SetLocalizedString(lsFEStopConvert, 'Прервать конвертацию БД');
  SetLocalizedString(lsFESaveMetadata, 'Сохранить');
  SetLocalizedString(lsFESkipMetadata, 'Пропустить');

  SetLocalizedString(lsAllFilesBrowseMask, 'Все файлы');
  SetLocalizedString(lsDatabaseBrowseMask, 'База данных');
  SetLocalizedString(lsBackupBrowseMask, 'Архив базы данных');

end;

initialization
  __SetDefaultValues;
end.
