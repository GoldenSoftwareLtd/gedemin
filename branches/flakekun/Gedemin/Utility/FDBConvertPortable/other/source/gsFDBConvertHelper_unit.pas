unit gsFDBConvertHelper_unit;

interface

uses
  Windows, classes, Sysutils;

type
  TgsServerVersion = (svUnknown, svYaffil, svFirebird_15, svFirebird_20, svFirebird_21, svFirebird_25, svFirebird_30);
  TgsDatabaseVersion = (dvUnknown, dvODS_10_0, dvODS_11_0, dvODS_11_1, dvODS_11_2, dvODS_12);

  TgsApplicationFile = (afLanguages, afSubstitute, afApplicationData);

  TgsMetadataType = (mtTrigger, mtProcedure, mtView, mtComputedField);

  TCopyProgressRoutine = procedure(TotalFileSize, TotalBytesTransferred: Int64);
  TServiceProgressRoutine = procedure(const AServiceMessage: String);
  TMetadataProgressRoutine = procedure(const AMessage: String; const AMaxProgress, ACurrentProgress: Integer);

  TgsFileSystemHelper = class(TObject)
  private
    class function CheckUserDataDirectory: Boolean;
  public
    // Возвращает путь к запущенному исполняемому файлу
    class function GetApplicationPath: String;
    // Возвращает путь к папке запущенного исполняемого файла
    class function GetApplicationDirectory: String;
    // Редактирует файл firebird.conf из директории приложения, и записывает туда RootDirectory = ADirectoryName
    class procedure ChangeFirebirdRootDirectory(const ADirectoryName: String);
    // Возвращает путь к файлу встроенного сервера по переданному типу
    class function GetPathToServer(const AServerVersion: TgsServerVersion): String;
    // Возвращает путь к директории встроенного сервера по переданному типу
    class function GetPathToServerDirectory(const AServerVersion: TgsServerVersion): String;
    // Возвращает путь и имя необходимого конфигурационного файла
    class function GetAvailableApplicationFile(const AFile: TgsApplicationFile): String;
    // Возвращает путь и имя необходимого конфигурационного файла
    class function GetUserApplicationFileName(const AFile: TgsApplicationFile): String;
    // Возвращает путь и имя необходимого конфигурационного файла
    class function GetDefaultApplicationFileName(const AFile: TgsApplicationFile): String;

    // Заменяет расширение у имени файла на *.BAK
    class function ChangeExtention(const AFileName, AExt: String): String;

    class function GetDefaultBackupName(const ADatabaseName: String): String;
    class function GetDefaultDatabaseCopyName(const ADatabaseName: String): String;
    class function GetDefaultDatabaseName(const ABackupName: String): String;
    class function IsBackupFile(const AFileName: String): Boolean;

    class function DoDeleteFile(const AFileName: String): Boolean;
    class function DoRenameFile(const OldName, NewName: String): String;

    // Возвращает размер файла
    class function GetFileSize(const AFileName: String): Int64;
    // Проверяет наличие свободного места на диске, возвращает -1 если места хватает,
    //  иначе возвращает недостаточный объем
    class function CheckForFreeDiskSpace(const APath: String; const AFileSize: Int64): Int64;
  end;

  TgsConfigFileManager = class(TObject)
  public
    // Получить список замещающих функций
    class procedure GetSubstituteFunctionList(AFunctionList: TStrings);
    // Сохранить список замещаемых функций
    class procedure SaveSubstituteFunctionList(AFunctionList: TStrings);
    // Получить список доступных локализаций
    class procedure GetLanguageList(ALanguageList: TStrings);
    // Получить данные конкретной локализации
    class procedure GetLanguageContent(const ALanguageName: String; ALanguageContent: TStrings);

    // Получить пароль IB пользователя по умолчанию
    class function GetDefaultPageSize: Integer;
    // Получить пароль IB пользователя по умолчанию
    class function GetDefaultNumBuffers: Integer;
    // Получить список кодовых страниц
    class procedure GetCodePageList(ACodePageList: TStrings);
  end;

  EgsConfigFileReadError = class(Exception);

const
  // Множитель на который увеличивается размер оригинальной базы
  //  для определения свободного места на диске
  FREE_SPACE_MULTIPLIER = 1.5;
  BYTE_IN_MB = 1048576;

  // Сервер в который мы переводим БД
  CONVERT_SERVER_VERSION = svFirebird_25;

  SERVER_DIR_PATH = '.\app\fdbconvert';

  // Директории с встроенными серверами
  YAFFIL_PATH = SERVER_DIR_PATH + '\ya';
  FIREBIRD_15_PATH = SERVER_DIR_PATH + '\fb15';
  FIREBIRD_20_PATH = SERVER_DIR_PATH + '\fb20';
  FIREBIRD_21_PATH = SERVER_DIR_PATH + '\fb21';
  FIREBIRD_25_PATH = SERVER_DIR_PATH + '\fb25';
  FIREBIRD_30_PATH = SERVER_DIR_PATH + '\fb30';

  DefaultIBUserName = 'SYSDBA';
  DefaultIBUserPassword = 'masterkey';
  DefaultCharacterSet = 'WIN1251';
  DefaultPageSize = 8192;
  DefaultNumBuffers = 8192;

  // Расширения файлов
  BACKUP_EXTENSION = 'bk';
  DATABASE_EXTENSION = 'fdb';
  OLD_DATABASE_EXTENSION = 'bak';
  COPY_FILENAME_PART = '_CONVERT_COPY';
  BACKUP_FILENAME_PART = '_CONVERT_BACKUP';

  // Директории с данными приложения
  DEFAULT_DATA_DIR = '.\app\defaultdata';
  DATA_DIR = '.\data';

  // Наменования файлов данных приложения
  APP_DATA_FILENAME = 'data.ini';
  LANGUAGES_FILENAME = 'languages.ini';
  SUBSTITUTE_FILENAME = 'substitute.ini';
  FIREBIRD_CONF_FILENAME = 'firebird.conf';

  // Наименования секций и параметров INI файлов
  SUBSTITUTE_SECTION_NAME = 'SUBSTITUTE';
  CONNECTION_SECTION_NAME = 'CONNECTION';
  CODE_PAGE_LIST_IDENT = 'CodePageList';
  DEFAULT_USER_NAME_IDENT = 'DefaultUserName';
  DEFAULT_USER_PASSWORD_IDENT = 'DefaultUserPassword';
  DEFAULT_PAGE_SIZE_IDENT = 'DefaultPageSize';
  DEFAULT_NUM_BUFFERS_IDENT = 'DefaultNumBuffers';

  // Комментарий используемый для тел процедур и триггреров
  FUNCTION_COMMENT_BEGIN = '/*FDB_CONV_COMM';
  FUNCTION_COMMENT_END = 'FDB_CONV_COMM*/';

// Получить версию сервера по версии БД
function GetServerVersionByDBVersion(const ADBVersion: TgsDatabaseVersion): TgsServerVersion;
function GetAppropriateServerVersion(const AServerVersion: TgsServerVersion): TgsServerVersion;
// Получить версию БД по версии сервера
function GetDBVersionByServerVersion(const AServerVersion: TgsServerVersion): TgsDatabaseVersion;
// Получить строковое представление версии БД
function GetTextDBVersion(const ADBVersion: TgsDatabaseVersion): String;
// Получить строковое представление версии сервера
function GetTextServerVersion(const AServerVersion: TgsServerVersion): String;

implementation

uses
  IBHeader, jclStrings, FileCtrl, gsFDBConvertLocalization_unit, inifiles, Forms;

class procedure TgsFileSystemHelper.ChangeFirebirdRootDirectory(const ADirectoryName: String);
var
  ConfigFile: TextFile;
  CurrentDir: String;
begin
  // Запомним текущую директорию
  CurrentDir := GetCurrentDir;
  // Перейдем в директорию встроенных серверов
  SetCurrentDir(GetApplicationDirectory);
  AssignFile(ConfigFile, FIREBIRD_CONF_FILENAME);
  Rewrite(ConfigFile);
  // Запишем путь к новому серверу
  Write(ConfigFile, 'RootDirectory = ' + ADirectoryName);
  CloseFile(ConfigFile);
  // Вермнемся в начальную директорию
  SetCurrentDir(CurrentDir);
end;

class function TgsFileSystemHelper.GetApplicationDirectory: String;
begin
  Result := ExtractFileDir(GetApplicationPath);
end;

class function TgsFileSystemHelper.GetApplicationPath: String;
begin
  Result := ParamStr(0);
end;

class function TgsFileSystemHelper.CheckUserDataDirectory: Boolean;
var
  CurrentDir: String;
begin
  Result := False;
  CurrentDir := GetCurrentDir;
  SetCurrentDir(GetApplicationDirectory);
  if DirectoryExists(ExpandFileName(DATA_DIR)) then
  begin
    Result := True;
  end
  else
  begin
    if CreateDir(ExpandFileName(DATA_DIR)) then
      Result := True;
  end;
end;

class function TgsFileSystemHelper.GetUserApplicationFileName(const AFile: TgsApplicationFile): String;
var
  FileName: String;
begin
  Result := '';
  if CheckUserDataDirectory then
  begin
    // Получим наименование файла
    case AFile of
      afLanguages:
        FileName := LANGUAGES_FILENAME;

      afSubstitute:
        FileName := SUBSTITUTE_FILENAME;

      afApplicationData:
        FileName := APP_DATA_FILENAME;
    else
      FileName := '';
    end;

    // Сформируем пути к файлу в директориях данных
    SetCurrentDir(GetApplicationDirectory);
    Result := IncludeTrailingBackslash(ExpandFileName(DATA_DIR)) + FileName;
  end;
end;

class function TgsFileSystemHelper.GetDefaultApplicationFileName(const AFile: TgsApplicationFile): String;
var
  FileName: String;
begin
  // Получим наименование файла
  case AFile of
    afLanguages:
      FileName := LANGUAGES_FILENAME;

    afSubstitute:
      FileName := SUBSTITUTE_FILENAME;

    afApplicationData:
      FileName := APP_DATA_FILENAME;
  else
    FileName := '';
  end;

  // Сформируем пути к файлу в директориях данных
  SetCurrentDir(GetApplicationDirectory);
  Result := IncludeTrailingBackslash(ExpandFileName(DEFAULT_DATA_DIR)) + FileName;
end;


class function TgsFileSystemHelper.GetAvailableApplicationFile(const AFile: TgsApplicationFile): String;
var
  DefaultFilePath, FilePath: String;
  SearchResult: TSearchRec;
begin
  // Сформируем пути к файлу в директориях данных
  DefaultFilePath := GetDefaultApplicationFileName(AFile);
  FilePath := GetUserApplicationFileName(AFile);
  // Проверим существование файла сначала в директории пользовательских данных,
  //  а затем в директории данных по умолчанию
  if (FindFirst(FilePath, faAnyFile, SearchResult) = 0) and (SearchResult.Size > 0) then
    Result := FilePath
  else if (FindFirst(DefaultFilePath, faAnyFile, SearchResult) = 0) and (SearchResult.Size > 0)then
    Result := DefaultFilePath
  else
    raise EgsConfigFileReadError.Create(GetLocalizedString(lsFileNotFound) + ':'#13#10'  ' + DefaultFilePath + #13#10'  ' + FilePath);
end;

class function TgsFileSystemHelper.GetPathToServer(const AServerVersion: TgsServerVersion): String;

  function GetAvailableIBLibraryName(const AServerPath: String): String;
  begin
    if FileExists(AServerPath + FBEMB_DLL) then
      Result := FBEMB_DLL
    else if FileExists(AServerPath + FBASE_DLL) then
      Result := FBASE_DLL
    else if FileExists(AServerPath + IBASE_DLL) then
      Result := IBASE_DLL;
  end;

begin
  Result := GetPathToServerDirectory(AServerVersion);
  if Result <> '' then
    Result := Result + GetAvailableIBLibraryName(Result);
end;

class function TgsFileSystemHelper.GetPathToServerDirectory(const AServerVersion: TgsServerVersion): String;
var
  ServerPath, OldCurDir: String;
begin
  case AServerVersion of
    svYaffil:
      ServerPath := YAFFIL_PATH;

    svFirebird_15:
      ServerPath := FIREBIRD_15_PATH;

    svFirebird_20:
      ServerPath := FIREBIRD_20_PATH;

    svFirebird_21:
      ServerPath := FIREBIRD_21_PATH;

    svFirebird_25:
      ServerPath := FIREBIRD_25_PATH;

    svFirebird_30:
      ServerPath := FIREBIRD_30_PATH;
  else
    ServerPath := '';
  end;

  if ServerPath <> '' then
  begin
    OldCurDir := GetCurrentDir;
    SetCurrentDir(GetApplicationDirectory);
    ServerPath := IncludeTrailingBackslash(ExpandFileName(ServerPath));
    SetCurrentDir(OldCurDir);
  end;

  Result := ServerPath;
end;

// Получить версию БД по версии сервера
function GetDBVersionByServerVersion(const AServerVersion: TgsServerVersion): TgsDatabaseVersion;
begin
  case AServerVersion of
    svYaffil, svFirebird_15:
      Result := dvODS_10_0;

    svFirebird_20:
      Result := dvODS_11_0;

    svFirebird_21:
      Result := dvODS_11_1;

    svFirebird_25:
      Result := dvODS_11_2;

    svFirebird_30:
      Result := dvODS_12;
  else
    Result := dvUnknown;
  end;
end;

// Получить версию сервера по версии БД
function GetServerVersionByDBVersion(const ADBVersion: TgsDatabaseVersion): TgsServerVersion;
begin
  case ADBVersion of
    dvODS_10_0:
      Result := svYaffil;

    dvODS_11_0:
      Result := svFirebird_20;

    dvODS_11_1:
      Result := svFirebird_21;

    dvODS_11_2:
      Result := svFirebird_25;

    dvODS_12:
      Result := svFirebird_30;
  else
    Result := svUnknown;
  end;
end;

function GetAppropriateServerVersion(const AServerVersion: TgsServerVersion): TgsServerVersion;
begin
  case AServerVersion of
    svYaffil, svFirebird_15:
      Result := svFirebird_20;
  else
    Result := AServerVersion;
  end;
end;

// Получить строковое представление версии БД
function GetTextDBVersion(const ADBVersion: TgsDatabaseVersion): String;
begin
  case ADBVersion of
    dvODS_10_0:
      Result := '10.0';

    dvODS_11_0:
      Result := '11.0';

    dvODS_11_1:
      Result := '11.1';

    dvODS_11_2:
      Result := '11.2';

    dvODS_12:
      Result := '12';
  else
    Result := GetLocalizedString(lsUnknownDatabaseType);
  end;
end;

// Получить строковое представление версии сервера
function GetTextServerVersion(const AServerVersion: TgsServerVersion): String;
begin
  case AServerVersion of
    svYaffil:
      Result := 'Yaffil';

    svFirebird_15:
      Result := 'Firebird 1.5';

    svFirebird_20:
      Result := 'Firebird 2.0';

    svFirebird_21:
      Result := 'Firebird 2.1';

    svFirebird_25:
      Result := 'Firebird 2.5';

    svFirebird_30:
      Result := 'Firebird 3.0';
  else
    Result := GetLocalizedString(lsUnknownServerType);
  end;
end;

class function TgsFileSystemHelper.GetDefaultBackupName(const ADatabaseName: String): String;
var
  DatabasePath, DatabaseDirName, DatabaseFileName: String;
begin
  // Присвоим объекту путь к базе
  DatabasePath := ExpandFileName(ADatabaseName);

  DatabaseDirName := ExtractFilePath(DatabasePath);
  DatabaseFileName := ExtractFileName(DatabasePath);
  DatabaseFileName := Copy(DatabaseFileName, 1, Length(DatabaseFileName) - Length(ExtractFileExt(DatabaseFileName)));
  Result := DatabaseDirName + DatabaseFileName + BACKUP_FILENAME_PART + '.' + BACKUP_EXTENSION;
end;

class function TgsFileSystemHelper.GetDefaultDatabaseCopyName(const ADatabaseName: String): String;
var
  DatabasePath, DatabaseDirName, DatabaseFileName: String;
begin
  // Присвоим объекту путь к базе
  DatabasePath := ExpandFileName(ADatabaseName);

  // Если имена копии базы и бэкапа еще не указаны, сформируем их
  DatabaseDirName := ExtractFilePath(DatabasePath);
  DatabaseFileName := ExtractFileName(DatabasePath);
  DatabaseFileName := Copy(DatabaseFileName, 1, Length(DatabaseFileName) - Length(ExtractFileExt(DatabaseFileName)));
  Result := DatabaseDirName + DatabaseFileName + COPY_FILENAME_PART + '.' + DATABASE_EXTENSION;
end;

class function TgsFileSystemHelper.GetDefaultDatabaseName(const ABackupName: String): String;
var
  BackupPath: String;
begin
  // Присвоим объекту путь к базе
  BackupPath := ExpandFileName(ABackupName);
  Result := ChangeFileExt(BackupPath, '.' + DATABASE_EXTENSION);
end;

class function TgsFileSystemHelper.IsBackupFile(const AFileName: String): Boolean;
begin
  if AnsiPos(BACKUP_EXTENSION, ExtractFileExt(AFileName)) <> 0 then
    Result := True
  else
    Result := False;
end;

class function TgsFileSystemHelper.DoDeleteFile(const AFileName: String): Boolean;
begin
  Result := False;
  if (AFileName <> '') and FileExists(AFileName) then
    Result := DeleteFile(AFileName);
end;

class function TgsFileSystemHelper.DoRenameFile(const OldName,
  NewName: String): String;
var
  ReplName: String;

  function GenerateNewName(const APath, AName: String): String;
  var
    NameCounter: Integer;
    FileExt, FileName: String;
    UniqueName: String;
  begin
    FileExt := ExtractFileExt(AName);
    FileName := StrLeft(AName, StrLength(AName) - StrLength(FileExt));
    for NameCounter := 1 to 100 do
    begin
      UniqueName := FileName + '_' + IntToStr(NameCounter) + FileExt;
      if not FileExists(APath + UniqueName) then
      begin
        Result := APath + UniqueName;
        Exit;
      end;
    end;
    Result := APath + AName;
  end;

begin
  if (OldName <> '') and (NewName <> '') then
  begin
    if FileExists(OldName) then
    begin
      // Подберем свободное имя для нового файла
      if FileExists(NewName) then
        ReplName := GenerateNewName(ExtractFilePath(NewName), ExtractFileName(NewName))
      else
        ReplName := NewName;
      // Переименуем файл
      RenameFile(OldName, ReplName);
      Result := ReplName;
    end
    else
      raise Exception.Create(Format(GetLocalizedString(lsFileDoesntExists), [OldName]));
  end
end;

class function TgsFileSystemHelper.ChangeExtention(const AFileName, AExt: String): String;
begin
  Result := AFileName + '.' + AExt;
end;

class function TgsFileSystemHelper.CheckForFreeDiskSpace(const APath: String; const AFileSize: Int64): Int64;
var
  DiskFreeSpace: Int64;
  OldDirectory, FileDrive: String;
begin
  Result := -1;

  OldDirectory := GetCurrentDir;
  try
    if SetCurrentDir(ExtractFileDir(APath)) then
    begin
      // Определим свободное место на диске
      DiskFreeSpace := DiskFree(0);

      // Определим необходимый размер свободного места для конвертации БД
      if AFileSize > DiskFreeSpace then
        Result := AFileSize - DiskFreeSpace;
    end
    else
    begin
      FileDrive := ExtractFileDrive(APath);
      if (FileDrive <> '') and (SetCurrentDir(FileDrive)) then
      begin
        // Определим свободное место на диске
        DiskFreeSpace := DiskFree(0);

        // Определим необходимый размер свободного места для конвертации БД
        if AFileSize > DiskFreeSpace then
          Result := AFileSize - DiskFreeSpace;
      end
      else
        raise Exception.Create(GetLocalizedString(lsDirectoryAccessError) + ':'#13#10'  "' + ExtractFileDir(APath) + '"');
    end;
  finally
    SetCurrentDir(OldDirectory);
  end;
end;

class function TgsFileSystemHelper.GetFileSize(const AFileName: String): Int64;
var
  SR : TSearchRec;
begin
  Result := -1;

  if FindFirst(AFileName, faAnyFile, SR) = 0 then
    try
      Result := (SR.FindData.nFileSizeHigh * Int64(MAXDWORD)) + SR.FindData.nFileSizeLow;
    finally
      FindClose(SR);
    end;
end;

{ TgsConfigFileManager }

class procedure TgsConfigFileManager.GetLanguageList(ALanguageList: TStrings);
var
  FunctionFile: TIniFile;
begin
  try
    // Считываем данные о доступных локализациях
    FunctionFile := TIniFile.Create(TgsFileSystemHelper.GetAvailableApplicationFile(afLanguages));
    try
      // Считаем список всех секций файла, соответсвенно все доступные языки
      FunctionFile.ReadSections(ALanguageList);
    finally
      FreeAndNil(FunctionFile);
    end;
  except
    on E: EgsConfigFileReadError do
    begin
      Application.MessageBox(PChar(E.Message),
        PChar(GetLocalizedString(lsInformationDialogCaption)), MB_OK or MB_ICONWARNING or MB_APPLMODAL);
    end;
  end;
end;

class procedure TgsConfigFileManager.GetLanguageContent(const ALanguageName: String; ALanguageContent: TStrings);
var
  FunctionFile: TIniFile;
begin
  // Считываем данные о доступных локализациях
  FunctionFile := TIniFile.Create(TgsFileSystemHelper.GetAvailableApplicationFile(afLanguages));
  try
    if FunctionFile.SectionExists(ALanguageName) then
      FunctionFile.ReadSectionValues(ALanguageName, ALanguageContent)
    else
      raise EgsConfigFileReadError.Create(Format(GetLocalizedString(lsLanguageNotFound), [ALanguageName]) + #13#10 +
        '  ' + TgsFileSystemHelper.GetAvailableApplicationFile(afLanguages));
  finally
    FreeAndNil(FunctionFile);
  end;
end;

class procedure TgsConfigFileManager.GetSubstituteFunctionList(AFunctionList: TStrings);
var
  FunctionFile: TIniFile;
begin
  // Считываем данные о заменяемых функциях
  FunctionFile := TIniFile.Create(TgsFileSystemHelper.GetAvailableApplicationFile(afSubstitute));
  try
    if FunctionFile.SectionExists(SUBSTITUTE_SECTION_NAME) then
      FunctionFile.ReadSectionValues(SUBSTITUTE_SECTION_NAME, AFunctionList)
    else
      raise EgsConfigFileReadError.Create(GetLocalizedString(lsWrongSubstituteFile) + #13#10 +
        '  ' + TgsFileSystemHelper.GetAvailableApplicationFile(afSubstitute));
  finally
    FreeAndNil(FunctionFile);
  end;
end;

class procedure TgsConfigFileManager.SaveSubstituteFunctionList(AFunctionList: TStrings);
var
  FunctionFileName: String;
  FunctionFile: TIniFile;
  StringCounter: Integer;
  OriginalFunction, SubstituteFunction: String;
begin
  FunctionFileName := TgsFileSystemHelper.GetUserApplicationFileName(afSubstitute);
  if FunctionFileName <> '' then
  begin
    FunctionFile := TIniFile.Create(FunctionFileName);
    try
      FunctionFile.EraseSection(SUBSTITUTE_SECTION_NAME);
      for StringCounter := 0 to AFunctionList.Count - 1 do
      begin
        OriginalFunction := AFunctionList.Names[StringCounter];
        SubstituteFunction := AFunctionList.Values[OriginalFunction];
        FunctionFile.WriteString(SUBSTITUTE_SECTION_NAME, OriginalFunction, SubstituteFunction);
      end;
    finally
      FreeAndNil(FunctionFile);
    end;
  end;
end;

class procedure TgsConfigFileManager.GetCodePageList(ACodePageList: TStrings);
const
  DELIMETER_CHAR = ',';
var
  FunctionFile: TIniFile;
  ValueText: String;
  DelimiterPos, NextDelimiterPos: Integer;
begin
  // Считываем данные о кодовых страницах
  FunctionFile := TIniFile.Create(TgsFileSystemHelper.GetAvailableApplicationFile(afApplicationData));
  try
    if FunctionFile.ValueExists(CONNECTION_SECTION_NAME, CODE_PAGE_LIST_IDENT) then
    begin
      DelimiterPos := 1;
      ValueText := Trim(FunctionFile.ReadString(CONNECTION_SECTION_NAME, CODE_PAGE_LIST_IDENT, ''));
      // Поищем след. разделитель списка кодовых страниц
      NextDelimiterPos := StrFind(DELIMETER_CHAR, ValueText);
      // Если разделитель не найден, а значение параметра не пустая строка,
      //  значит у нас только одна кодовая страница
      if (NextDelimiterPos = 0) and (ValueText <> '') then
      begin
        ACodePageList.Add(ValueText);
      end
      else
      begin
        while NextDelimiterPos > 0 do
        begin
          // Запомним кодовую страницу
          ACodePageList.Add(Trim(StrMid(ValueText, DelimiterPos, NextDelimiterPos - DelimiterPos)));
          // Запомним позицию предыдущего разделителя
          DelimiterPos := NextDelimiterPos + 1;
          // Перейдем к след. разделителю
          NextDelimiterPos := StrFind(DELIMETER_CHAR, ValueText, DelimiterPos);
        end;
        // Прочитаем последнюю кодовую страницу
        if Trim(StrRestOf(ValueText, DelimiterPos)) <> '' then
          ACodePageList.Add(Trim(StrRestOf(ValueText, DelimiterPos)));
      end;
    end
    else
      raise EgsConfigFileReadError.Create(GetLocalizedString(lsCharsetListNotFound) + #13#10 +
        '  ' + TgsFileSystemHelper.GetAvailableApplicationFile(afApplicationData));
  finally
    FreeAndNil(FunctionFile);
  end;
end;

class function TgsConfigFileManager.GetDefaultNumBuffers: Integer;
var
  FunctionFile: TIniFile;
begin
  // Считываем кол-во буферов по умолчанию
  FunctionFile := TIniFile.Create(TgsFileSystemHelper.GetAvailableApplicationFile(afApplicationData));
  try
    Result := FunctionFile.ReadInteger(CONNECTION_SECTION_NAME, DEFAULT_NUM_BUFFERS_IDENT, DefaultNumBuffers);
  finally
    FreeAndNil(FunctionFile);
  end;
end;

class function TgsConfigFileManager.GetDefaultPageSize: Integer;
var
  FunctionFile: TIniFile;
begin
  // Считываем размер страницы по умолчанию
  FunctionFile := TIniFile.Create(TgsFileSystemHelper.GetAvailableApplicationFile(afApplicationData));
  try
    Result := FunctionFile.ReadInteger(CONNECTION_SECTION_NAME, DEFAULT_PAGE_SIZE_IDENT, DefaultPageSize);
  finally
    FreeAndNil(FunctionFile);
  end;
end;

end.