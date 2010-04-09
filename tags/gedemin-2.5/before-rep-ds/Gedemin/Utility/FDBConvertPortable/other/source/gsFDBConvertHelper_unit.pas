unit gsFDBConvertHelper_unit;

interface

uses
  Windows, classes, Sysutils;

type
  TgsServerVersion = (svUnknown, svYaffil, svFirebird_15, svFirebird_20, svFirebird_21, svFirebird_25, svFirebird_30);
  TgsDatabaseVersion = (dvUnknown, dvODS_10_0, dvODS_11_0, dvODS_11_1, dvODS_11_2, dvODS_12);

  TgsApplicationFile = (afLanguages, afSubstitute, afApplicationData, afFirebirdConf, afGudfDll, afIBUdfDll);

  TgsMetadataType = (mtTrigger, mtProcedure, mtView, mtComputedField);

  TCopyProgressRoutine = procedure(TotalFileSize, TotalBytesTransferred: Int64);
  TServiceProgressRoutine = procedure(const AServiceMessage: String);
  TMetadataProgressRoutine = procedure(const AMessage: String; const AMaxProgress, ACurrentProgress: Integer);

  TgsFileSystemHelper = class(TObject)
  private
    class function CheckUserDataDirectory: Boolean;
    class procedure SimpleCopyFile(const FromPath, ToPath: String);
  public
    // ���������� ���� � ����������� ������������ �����
    class function GetApplicationPath: String;
    // ���������� ���� � ����� ����������� ������������ �����
    class function GetApplicationDirectory: String;
    // ����������� ���� firebird.conf �� ���������� ����������, � ���������� ���� RootDirectory = ADirectoryName
    class procedure ChangeFirebirdRootDirectory(const ADirectoryName: String);
    // ���������� ���� � ����� ����������� ������� �� ����������� ����
    class function GetPathToServer(const AServerVersion: TgsServerVersion): String;
    // ���������� ���� � ���������� ����������� ������� �� ����������� ����
    class function GetPathToServerDirectory(const AServerVersion: TgsServerVersion): String;
    // ���������� ���� � ��� ������������ ����������������� �����
    class function GetAvailableApplicationFile(const AFile: TgsApplicationFile): String;
    // ���������� ���� � ��� ������������ ����������������� �����
    class function GetUserApplicationFileName(const AFile: TgsApplicationFile): String;
    // ���������� ���� � ��� ������������ ����������������� �����
    class function GetDefaultApplicationFileName(const AFile: TgsApplicationFile): String;

    // �������� ���������� � ����� ����� �� *.BAK
    class function ChangeExtention(const AFileName, AExt: String): String;

    class function GetDefaultBackupName(const ADatabaseName: String): String;
    class function GetDefaultDatabaseCopyName(const ADatabaseName: String): String;
    class function GetDefaultDatabaseName(const ABackupName: String): String;
    class function IsBackupFile(const AFileName: String): Boolean;

    class function DoDeleteFile(const AFileName: String): Boolean;
    class function DoRenameFile(const OldName, NewName: String): String;

    // ���������� ������ �����
    class function GetFileSize(const AFileName: String): Int64;
    // ��������� ������� ���������� ����� �� �����, ���������� -1 ���� ����� �������,
    //  ����� ���������� ������������� �����
    class function CheckForFreeDiskSpace(const APath: String; const AFileSize: Int64): Int64;
    // �������� ������������� ����������, �������� � ������ ���������� ������ ����������
    //  ���������� ������ ��� ������������� ����, ��� �������� ��������
    class procedure CheckPathExistence(const APath: String);

    // ������� � ��������� ����������� ��� ������ ��������� �����
    class procedure CreateTempFiles(const AServerVersion: TgsServerVersion);
    // ������ ����� ��������� ��� ������������� �� ����� ������ ���������
    class procedure DeleteTempFiles;
  end;

  TgsConfigFileManager = class(TObject)
  public
    // �������� ������ ���������� �������
    class procedure GetSubstituteFunctionList(AFunctionList: TStrings);
    // ��������� ������ ���������� �������
    class procedure SaveSubstituteFunctionList(AFunctionList: TStrings);
    // �������� ������ ��������� �����������
    class procedure GetLanguageList(ALanguageList: TStrings);
    // �������� ������ ���������� �����������
    class procedure GetLanguageContent(const ALanguageName: String; ALanguageContent: TStrings);

    // �������� ������ IB ������������ �� ���������
    class function GetDefaultPageSize: Integer;
    // �������� ������ IB ������������ �� ���������
    class function GetDefaultNumBuffers: Integer;
    // �������� ������ ������� �������
    class procedure GetCodePageList(ACodePageList: TStrings);
  end;

  EgsConfigFileReadError = class(Exception);
  EgsInterruptConvertProcess = class(Exception);
  EgsPathNotAccessible = class(Exception);

const
  // ��������� �� ������� ������������� ������ ������������ ����
  //  ��� ����������� ���������� ����� �� �����
  FREE_SPACE_MULTIPLIER = 2;
  FREE_SPACE_MULTIPLIER_FOR_BK = 4;
  BYTE_IN_MB = 1048576;

  // ������ � ������� �� ��������� ��
  {$IFDEF TARGET_21}
  CONVERT_SERVER_VERSION = svFirebird_21;
  {$ELSE}
    {$IFDEF TARGET_30}
    CONVERT_SERVER_VERSION = svFirebird_30;
    {$ELSE}
    CONVERT_SERVER_VERSION = svFirebird_25;
    {$ENDIF}
  {$ENDIF}

  SERVER_DIR_PATH = '.\app\fdbconvert';

  // ���������� � ����������� ���������
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
  MINIMAL_PAGE_SIZE = 4096;

  // ���������� ������
  BACKUP_EXTENSION = 'bk';
  DATABASE_EXTENSION = 'fdb';
  OLD_DATABASE_EXTENSION = 'bak';
  COPY_FILENAME_PART = '_CONVERT_COPY';
  BACKUP_FILENAME_PART = '_CONVERT_BACKUP';

  // ���������� � ������� ����������
  DEFAULT_DATA_DIR = '.\app\defaultdata';
  DATA_DIR = '.\data';

  // ����������� ������ ������ ����������
  APP_DATA_FILENAME = 'data.ini';
  LANGUAGES_FILENAME = 'languages.ini';
  SUBSTITUTE_FILENAME = 'substitute.ini';
  FIREBIRD_CONF_FILENAME = 'firebird.conf';
  GUDF_DLL_FILENAME = 'gudf.dll';
  IBUDF_DLL_FILENAME = 'ib_udf.dll';

  // ������������ ������ � ���������� INI ������
  SUBSTITUTE_SECTION_NAME = 'SUBSTITUTE';
  CONNECTION_SECTION_NAME = 'CONNECTION';
  CODE_PAGE_LIST_IDENT = 'CodePageList';
  DEFAULT_USER_NAME_IDENT = 'DefaultUserName';
  DEFAULT_USER_PASSWORD_IDENT = 'DefaultUserPassword';
  DEFAULT_PAGE_SIZE_IDENT = 'DefaultPageSize';
  DEFAULT_NUM_BUFFERS_IDENT = 'DefaultNumBuffers';

  // ����������� ������������ ��� ��� �������� � ����������
  FUNCTION_COMMENT_BEGIN = '/*FDB_CONV_COMM';
  FUNCTION_COMMENT_END = 'FDB_CONV_COMM*/';
  // ���� �������������� ��������� ������, �� � ����� ����� �������� SUSPEND
  //  ����� �������� not selectable ������
  PROCEDURE_SUSPEND_TEMP = '/*FDB_SUSPEND_TEMP*/SUSPEND;/*FDB_SUSPEND_TEMP*/';

  LINE_CUT = '...';
  LOG_DIVIDER = #13#10'========================='#13#10;

// �������� ������ ������� �� ������ ��
function GetServerVersionByDBVersion(const ADBVersion: TgsDatabaseVersion): TgsServerVersion;
function GetAppropriateServerVersion(const AServerVersion: TgsServerVersion): TgsServerVersion;
// �������� ������ �� �� ������ �������
function GetDBVersionByServerVersion(const AServerVersion: TgsServerVersion): TgsDatabaseVersion;
// �������� ��������� ������������� ������ ��
function GetTextDBVersion(const ADBVersion: TgsDatabaseVersion): String;
// �������� ��������� ������������� ������ �������
function GetTextServerVersion(const AServerVersion: TgsServerVersion): String;

implementation

uses
  IBHeader, jclStrings, FileCtrl, gsFDBConvertLocalization_unit, inifiles, Forms;

class procedure TgsFileSystemHelper.ChangeFirebirdRootDirectory(const ADirectoryName: String);
var
  ConfigFile: TextFile;
  CurrentDir: String;
begin
  // �������� ������� ����������
  CurrentDir := GetCurrentDir;
  // �������� � ���������� ����������
  SetCurrentDir(GetApplicationDirectory);
  AssignFile(ConfigFile, FIREBIRD_CONF_FILENAME);
  // ���� ���� �� ���������� ��������, ����� ����������� ���
  Rewrite(ConfigFile);
  // ������� ���� � ������ �������
  Write(ConfigFile, 'RootDirectory = ' + ADirectoryName);
  CloseFile(ConfigFile);
  // ��������� � ��������� ����������
  SetCurrentDir(CurrentDir);
end;

class function TgsFileSystemHelper.GetApplicationDirectory: String;
begin
  Result := IncludeTrailingBackslash(ExtractFileDir(GetApplicationPath));
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
    // ������� ������������ �����
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

    // ���������� ���� � ����� � ����������� ������
    SetCurrentDir(GetApplicationDirectory);
    Result := IncludeTrailingBackslash(ExpandFileName(DATA_DIR)) + FileName;
  end;
end;

class function TgsFileSystemHelper.GetDefaultApplicationFileName(const AFile: TgsApplicationFile): String;
var
  FileName: String;
begin
  // ������� ������������ �����
  case AFile of
    afLanguages:
      FileName := LANGUAGES_FILENAME;

    afSubstitute:
      FileName := SUBSTITUTE_FILENAME;

    afApplicationData:
      FileName := APP_DATA_FILENAME;

    afFirebirdConf:
      FileName := FIREBIRD_CONF_FILENAME;

    afGudfDll:
      FileName := GUDF_DLL_FILENAME;

    afIBUdfDll:
      FileName := IBUDF_DLL_FILENAME
  else
    FileName := '';
  end;

  // ���������� ���� � ����� � ����������� ������
  if (AFile <> afFirebirdConf) and (AFile <> afGudfDll) and (AFile <> afIBUdfDll) then
  begin
    SetCurrentDir(GetApplicationDirectory);
    Result := IncludeTrailingBackslash(ExpandFileName(DEFAULT_DATA_DIR)) + FileName;
  end
  else
    Result := IncludeTrailingBackslash(GetApplicationDirectory) + FileName;
end;


class function TgsFileSystemHelper.GetAvailableApplicationFile(const AFile: TgsApplicationFile): String;
var
  DefaultFilePath, FilePath: String;
  SearchResult: TSearchRec;
begin
  // ���������� ���� � ����� � ����������� ������
  DefaultFilePath := GetDefaultApplicationFileName(AFile);
  FilePath := GetUserApplicationFileName(AFile);
  // �������� ������������� ����� ������� � ���������� ���������������� ������,
  //  � ����� � ���������� ������ �� ���������
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

// �������� ������ �� �� ������ �������
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

// �������� ������ ������� �� ������ ��
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

// �������� ��������� ������������� ������ ��
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

// �������� ��������� ������������� ������ �������
function GetTextServerVersion(const AServerVersion: TgsServerVersion): String;
begin
  case AServerVersion of
    svYaffil:
      Result := 'Interbase/Yaffil';

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
  // �������� ������� ���� � ����
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
  // �������� ������� ���� � ����
  DatabasePath := ExpandFileName(ADatabaseName);

  // ���� ����� ����� ���� � ������ ��� �� �������, ���������� ��
  DatabaseDirName := ExtractFilePath(DatabasePath);
  DatabaseFileName := ExtractFileName(DatabasePath);
  DatabaseFileName := Copy(DatabaseFileName, 1, Length(DatabaseFileName) - Length(ExtractFileExt(DatabaseFileName)));
  Result := DatabaseDirName + DatabaseFileName + COPY_FILENAME_PART + '.' + DATABASE_EXTENSION;
end;

class function TgsFileSystemHelper.GetDefaultDatabaseName(const ABackupName: String): String;
var
  BackupPath: String;
begin
  // �������� ������� ���� � ����
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
  Result := '';

  if (OldName <> '') and (NewName <> '') then
  begin
    if FileExists(OldName) then
    begin
      // �������� ��������� ��� ��� ������ �����
      if FileExists(NewName) then
        ReplName := GenerateNewName(ExtractFilePath(NewName), ExtractFileName(NewName))
      else
        ReplName := NewName;
      // ����������� ����
      if RenameFile(OldName, ReplName) then
        Result := ReplName
      else
        raise Exception.Create(Format(GetLocalizedString(lsFileDoesntExists), [OldName]));
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
      // ��������� ��������� ����� �� �����
      DiskFreeSpace := DiskFree(0);

      // ��������� ����������� ������ ���������� ����� ��� ����������� ��
      if AFileSize > DiskFreeSpace then
        Result := AFileSize - DiskFreeSpace;
    end
    else
    begin
      FileDrive := ExtractFileDrive(APath);
      if (FileDrive <> '') and (SetCurrentDir(FileDrive)) then
      begin
        // ��������� ��������� ����� �� �����
        DiskFreeSpace := DiskFree(0);

        // ��������� ����������� ������ ���������� ����� ��� ����������� ��
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
    // ��������� ������ � ��������� ������������
    FunctionFile := TIniFile.Create(TgsFileSystemHelper.GetAvailableApplicationFile(afLanguages));
    try
      // ������� ������ ���� ������ �����, ������������� ��� ��������� �����
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
  // ��������� ������ � ��������� ������������
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
  // ��������� ������ � ���������� ��������
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
  // ��������� ������ � ������� ���������
  FunctionFile := TIniFile.Create(TgsFileSystemHelper.GetAvailableApplicationFile(afApplicationData));
  try
    if FunctionFile.ValueExists(CONNECTION_SECTION_NAME, CODE_PAGE_LIST_IDENT) then
    begin
      DelimiterPos := 1;
      ValueText := Trim(FunctionFile.ReadString(CONNECTION_SECTION_NAME, CODE_PAGE_LIST_IDENT, ''));
      // ������ ����. ����������� ������ ������� �������
      NextDelimiterPos := StrFind(DELIMETER_CHAR, ValueText);
      // ���� ����������� �� ������, � �������� ��������� �� ������ ������,
      //  ������ � ��� ������ ���� ������� ��������
      if (NextDelimiterPos = 0) and (ValueText <> '') then
      begin
        ACodePageList.Add(ValueText);
      end
      else
      begin
        while NextDelimiterPos > 0 do
        begin
          // �������� ������� ��������
          ACodePageList.Add(Trim(StrMid(ValueText, DelimiterPos, NextDelimiterPos - DelimiterPos)));
          // �������� ������� ����������� �����������
          DelimiterPos := NextDelimiterPos + 1;
          // �������� � ����. �����������
          NextDelimiterPos := StrFind(DELIMETER_CHAR, ValueText, DelimiterPos);
        end;
        // ��������� ��������� ������� ��������
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
  // ��������� ���-�� ������� �� ���������
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
  // ��������� ������ �������� �� ���������
  FunctionFile := TIniFile.Create(TgsFileSystemHelper.GetAvailableApplicationFile(afApplicationData));
  try
    Result := FunctionFile.ReadInteger(CONNECTION_SECTION_NAME, DEFAULT_PAGE_SIZE_IDENT, DefaultPageSize);
  finally
    FreeAndNil(FunctionFile);
  end;
end;

class procedure TgsFileSystemHelper.CreateTempFiles(const AServerVersion: TgsServerVersion);
begin
  try
    if AServerVersion = svYaffil then
    begin
      // ��������� ��������������� ������� gudf.dll � ����� � ����������
      TgsFileSystemHelper.SimpleCopyFile(
        TgsFileSystemHelper.GetPathToServerDirectory(AServerVersion) + GUDF_DLL_FILENAME,
        TgsFileSystemHelper.GetDefaultApplicationFileName(afGudfDll));
      // ��������� ��������������� ������� ib_udf.dll � ����� � ����������
      TgsFileSystemHelper.SimpleCopyFile(
        TgsFileSystemHelper.GetPathToServerDirectory(AServerVersion) + IBUDF_DLL_FILENAME,
        TgsFileSystemHelper.GetDefaultApplicationFileName(afIBUdfDll));
    end;    
  except
    // �� �������, �� � �� �������
  end;
end;

class procedure TgsFileSystemHelper.DeleteTempFiles;
begin
  try
    // ������ firebird.conf
    TgsFileSystemHelper.DoDeleteFile(TgsFileSystemHelper.GetDefaultApplicationFileName(afFirebirdConf));
    // ������ gudf.dll
    TgsFileSystemHelper.DoDeleteFile(TgsFileSystemHelper.GetDefaultApplicationFileName(afGudfDll));
    // ������ gudf.dll
    TgsFileSystemHelper.DoDeleteFile(TgsFileSystemHelper.GetDefaultApplicationFileName(afIBUdfDll));
  except
    // �� �������, �� � �� �������
  end;
end;

class procedure TgsFileSystemHelper.SimpleCopyFile(const FromPath, ToPath: String);
const
  BUFFER_SIZE = 1024; // 1KB
var
  Buffer: array[0..BUFFER_SIZE - 1] of byte;
  NumRead: Integer;
  FromFile, ToFile: TFileStream;
begin
  if FileExists(FromPath) then
  begin
    // ������������ ����
    FromFile := TFileStream.Create(FromPath, fmOpenRead or fmShareDenyNone);
    try
      // �������� ��� ����������� ������� ����
      if FileExists(ToPath) then
        ToFile := TFileStream.Create(ToPath, fmOpenWrite or fmShareDenyWrite)
      else
        ToFile := TFileStream.Create(ToPath, fmCreate);
      try
        ToFile.Size := TgsFileSystemHelper.GetFileSize(FromPath);
        ToFile.Position := 0;
        FromFile.Position := 0;

        // ������� ������ ������
        NumRead := FromFile.Read(Buffer[0], BUFFER_SIZE);
        while NumRead > 0 do
        begin
          // ������� ����������� ����
          ToFile.Write(Buffer[0], NumRead);
          // ��������� ������
          NumRead := FromFile.Read(Buffer[0], BUFFER_SIZE);
        end;
      finally
        FreeAndNil(ToFile);
      end;
    finally
      FreeAndNil(FromFile);
    end;
  end;  
end;

class procedure TgsFileSystemHelper.CheckPathExistence(const APath: String);
var
  DirPath: String;
begin
  DirPath := ExtractFileDir(APath);
  if not DirectoryExists(DirPath) then
    if not ForceDirectories(DirPath) then
      raise EgsPathNotAccessible.Create(GetLocalizedString(lsDirectoryAccessError) + ':'#13#10'  "' + DirPath + '"');
end;

end.