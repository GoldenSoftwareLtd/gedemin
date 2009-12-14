unit gsFDBConvert_unit;

interface

uses
  IBDatabase, IBDatabaseInfo, IBSQL, classes, Windows, gsFDBConvertHelper_unit;

type
  TgsConnectionInformation = record
    ServerPath: String;                     // Embedded server path
    PageSize: Integer;
    NumBuffers: Integer;
    CharacterSet: String;
  end;

  TgsFDBConvert = class(TObject)
  private
    FServerType: TgsServerVersion;
    FOriginalServerType: TgsServerVersion;
    FConnectionInformation: TgsConnectionInformation;

    FDatabase: TIBDatabase;
    FDatabaseInfo: TIBDatabaseInfo;
    FReadTransaction: TIBTransaction;
    FWriteTransaction: TIBTransaction;

    FDatabaseName: String;
    FDatabaseOriginalName: String;
    FDatabaseCopyName: String;
    FDatabaseBackupName: String;

    FFinishOriginalDatabaseName: String;
    FFinishConvertedDatabaseName: String;

    FCopyProgressRoutine: TCopyProgressRoutine;
    FServiceProgressRoutine: TServiceProgressRoutine;
    FMetadataProgressRoutine: TMetadataProgressRoutine;

    function GetConnected: Boolean;
    procedure SetDatabaseName(const Value: String);
    function GetDatabaseName: String;

    function ConvertHelpMetadataExists: Boolean;

    procedure LoadIBServer(const AServerVersion: TgsServerVersion);
  public
    constructor Create;
    destructor Destroy; override;

    // Подключится к базе данных с помощью переданного типа сервера
    procedure Connect;
    function TryConnect: Boolean;
    // Отключится от базы
    procedure Disconnect;

    // Копировать файл базы данных для конвертации
    procedure CopyDatabaseFile(const ADatabaseOriginalPath, ADatabaseCopyPath: String);
    // Восстановить базу из бэкапа с помощью переданнного сервера
    procedure RestoreDatabase(const ABackupPath, ADatabasePath: String);
    // Забэкапить базу с помощью переданнного сервера
    procedure BackupDatabase(const ADatabasePath, ABackupPath: String);
    // Проверка целостности базы данных с ключами -full -mend
    procedure CheckDatabaseIntegrity(const ADatabasePath: String);

    // Создание метаданных необходимых для хранения тел конвертируемых триггеров и процедур
    procedure CreateConvertHelpMetadata;
    // Удаление вспомогательных метаданных
    procedure DestroyConvertHelpMetadata;

    // Проверяет доступность сервера по переданному типу
    function CheckServerAvailability(const AServerVersion: TgsServerVersion): Boolean;
    // Получить версию базы данных
    function GetDatabaseVersion: TgsDatabaseVersion;
    function GetDatabaseCharacterSet: String;

    property Database: TIBDatabase read FDatabase;
    property DatabaseName: String read GetDatabaseName write SetDatabaseName;
    property DatabaseOriginalName: String read FDatabaseOriginalName write FDatabaseOriginalName;
    property DatabaseCopyName: String read FDatabaseCopyName write FDatabaseCopyName;
    property DatabaseBackupName: String read FDatabaseBackupName write FDatabaseBackupName;

    property FinishOriginalDatabaseName: String read FFinishOriginalDatabaseName write FFinishOriginalDatabaseName;
    property FinishConvertedDatabaseName: String read FFinishConvertedDatabaseName write FFinishConvertedDatabaseName;

    property DatabaseInfo: TIBDatabaseInfo read FDatabaseInfo;
    property Connected: Boolean read GetConnected;

    property ConnectionInformation: TgsConnectionInformation read FConnectionInformation write FConnectionInformation;
    property ServerType: TgsServerVersion read FServerType write FServerType;
    property OriginalServerType: TgsServerVersion read FOriginalServerType write FOriginalServerType;

    property CopyProgressRoutine: TCopyProgressRoutine read FCopyProgressRoutine write FCopyProgressRoutine;
    property ServiceProgressRoutine: TServiceProgressRoutine read FServiceProgressRoutine write FServiceProgressRoutine;
    property MetadataProgressRoutine: TMetadataProgressRoutine read FMetadataProgressRoutine write FMetadataProgressRoutine;
  end;

  TgsMetadataEditor = class(TObject)
  private
    FDatabase: TIBDatabase;
    FWriteTransaction: TIBTransaction;
    FSubstituteFunctionList: TStringList;

    FIBSQLRead: TIBSQL;
    FIBSQLWrite: TIBSQL;

    // Истина - если символ на позиции CharPosition находится в комментарии, иначе Ложь
    class function IsCommented(const ACharPosition: Integer; const AFunctionText: String): Boolean;
    // Истина - если переданное слово не входит в состав другого слова, а отделено символами SPACE_CHARS
    class function IsSeparateWord(const AFunctionText: String; const AWordPosition, AWordLength: Integer): Boolean;

    // Получить текст параметров представления
    function GetViewParamText(const AViewName: String): String;
  public
    constructor Create(ADatabase: TIBDatabase);
    destructor Destroy; override;

    // Получить список хранимых процедур
    procedure GetProcedureList(AProcedureList: TStrings);
    // Получить список триггеров
    procedure GetTriggerList(ATriggerList: TStrings);
    // Получить список представлений и вычиляемых полей в порядке зависимости
    procedure GetViewAndComputedFieldList(AMetadataList: TStrings);
    // Получить список представлений и вычисляемых полей из вспомогательной таблицы,
    //  куда они были помещены перед конвертированием БД
    procedure GetBackupViewAndComputedFieldList(AMetadataList: TStrings);
    // Получить список используемых UDF-функций
    procedure GetUDFFunctionList(AFunctionList: TStrings);

    // Заменяет функции из UDF встроенными
    function ReplaceSubstituteUDFFunction(var AFunctionText: String): Boolean;
    // Комментирует тело процедуры\триггера
    class function CommentFunctionBody(var AFunctionText: String): Boolean;
    // Удаляет установленные выше комментарии
    class function UncommentFunctionBody(var AFunctionText: String): Boolean;
    // Скопировать данные представления в вспомогательную таблицу
    procedure BackupView(const AViewName: String);
    // Скопировать данные вычисляемого поля в вспомогательную таблицу
    procedure BackupComputedField(const ARelationName, AComputedFieldName: String);
    // Восстановить данные представления из вспомогательной таблицы
    procedure RestoreView(const AViewName: String);
    // Восстановить данные вычисляемого поля из вспомогательной таблицы
    procedure RestoreComputedField(const ARelationName, AComputedFieldName: String);

    // Удалить представление
    procedure DeleteView(const AViewName: String);
    // Удалить вычисляемое поле
    procedure DeleteComputedField(const ARelationName, AComputedFieldName: String);

    // Получить текст процедуры
    function GetProcedureText(const AProcedureName: String): String;
    // Получить текст параметров процедуры
    function GetProcedureParamText(const AProcedureName: String): String;
    // Получить текст триггера
    function GetTriggerText(const ATriggerName: String): String;
    // Получить текст представления
    function GetViewText(const AViewName: String): String;
    // Получить текст вычисляемого поля
    function GetComputedFieldText(const ARelationName, AComputedFieldName: String): String;

    // Получить текст представления из вспомогательной таблицы
    function GetBackupViewText(const AViewName: String): String;
    // Получить текст вычисляемого поля из вспомогательной таблицы
    function GetBackupComputedFieldText(const ARelationName, AComputedFieldName: String): String;

    // Изменить текст процедуры
    procedure SetProcedureText(const AProcedureName, AProcedureText: String; const AParams: String = '_');
    // Изменить текст триггера
    procedure SetTriggerText(const ATriggerName, ATriggerText: String);
    // Изменить текст представления
    procedure SetViewText(const AViewName, AViewText: String);
    // Изменить текст вычисляемого поля
    procedure SetComputedFieldText(const ARelationName, AComputedFieldName, AComputedFieldText: String);

    property SubstituteFunctionList: TStringList read FSubstituteFunctionList write FSubstituteFunctionList;
  end;

implementation

uses
  SysUtils, IBIntf, IBServices,
  gsSysUtils, gdUpdateIndiceStat, JclStrings,
  gsFDBConvertLocalization_unit;

const
  HELP_VIEW_TYPE = 'V';
  HELP_COMPUTED_FIELD_TYPE = 'F';

  HELP_METADATA_TABLE = 'CNV$DATA';
  HELP_METADATA_TABLE_CODE =
    'CREATE TABLE ' + HELP_METADATA_TABLE + ' ( ' +
    '  id             INTEGER NOT NULL PRIMARY KEY, ' +
    '  obj_type       CHAR(1) NOT NULL, ' +
    '  name           VARCHAR(60) CHARACTER SET UNICODE_FSS NOT NULL, ' +
    '  relation_name  VARCHAR(60) CHARACTER SET UNICODE_FSS, ' +
    '  source         BLOB SUB_TYPE 1 CHARACTER SET UNICODE_FSS, ' +
    '  CHECK(obj_type IN (''' + HELP_VIEW_TYPE + ''', ''' + HELP_COMPUTED_FIELD_TYPE + ''')) ' +
    ') ';
  HELP_METADATA_GENERATOR = 'CNV$G_ID';
  HELP_METADATA_GENERATOR_CODE = 'CREATE GENERATOR ' + HELP_METADATA_GENERATOR;
  HELP_METADATA_TRIGGER = 'CNV$BI_DATA';
  HELP_METADATA_TRIGGER_CODE =
    'CREATE TRIGGER ' + HELP_METADATA_TRIGGER + ' FOR ' + HELP_METADATA_TABLE + ' ' +
    '  BEFORE INSERT ' +
    '  POSITION 0 ' +
    'AS BEGIN ' +
    '  NEW.id = GEN_ID(' + HELP_METADATA_GENERATOR + ', 1); ' +
    'END ';

  SPACE_CHARS: set of char = [' ', #0, #10, #13, '/', '(', ')', '+', '-', '=', '*', '/', '<', '>', '!', '~', '^'];

var
  SetDllDirectory: function(lpPathName: PChar): Boolean; stdcall;

{ TgsFDBConvert }

constructor TgsFDBConvert.Create;
begin
  // Импорт функции SetDllDirectoryW
  SetDllDirectory := GetProcAddress(GetModuleHandle('kernel32.dll'), 'SetDllDirectoryA');

  // Загрузим сервер в который будем конвертировать БД
  LoadIBServer(CONVERT_SERVER_VERSION);
  // Создадим объекты базы данных, и информации о БД и свяжем их
  FDatabase := TIBDatabase.Create(nil);
  FDatabaseInfo := TIBDatabaseInfo.Create(nil);
  FDatabaseInfo.Database := FDatabase;
  // Читающая транзакция
  FReadTransaction := TIBTransaction.Create(nil);
  FReadTransaction.DefaultDatabase := FDatabase;
  FReadTransaction.Params.Text := 'read_committed'#13#10'rec_version'#13#10'nowait'#13#10'read'#13#10;
  FReadTransaction.AutoStopAction := saNone;
  // Установим читающую транзакцию, как транзакцию по умолчанию для БД
  FDatabase.DefaultTransaction := FReadTransaction;
  // Транзакция на запись по умолчанию
  FWriteTransaction := TIBTransaction.Create(nil);
  FWriteTransaction.DefaultDatabase := FDatabase;

  FServerType := svUnknown;
  FOriginalServerType := svUnknown;

  FDatabaseCopyName := '';
  FDatabaseBackupName := '';
end;

destructor TgsFDBConvert.Destroy;
begin
  inherited;

  if Assigned(FWriteTransaction) and FWriteTransaction.InTransaction then
    FWriteTransaction.Commit;
  FreeAndNil(FWriteTransaction);
  if Assigned(FReadTransaction) and FReadTransaction.InTransaction then
    FReadTransaction.Commit;
  FreeAndNil(FReadTransaction);
  FreeAndNil(FDatabaseInfo);
  FreeAndNil(FDatabase);
end;

procedure TgsFDBConvert.CopyDatabaseFile(const ADatabaseOriginalPath, ADatabaseCopyPath: String);
const
  BUFFER_SIZE = 10240; // 10KB 
var
  FromFile, ToFile: TFileStream;
  Buffer: array[0..BUFFER_SIZE - 1] of byte;
  NumRead: Integer;
  FileSize, CopiedSize: Int64;
begin
  // Получим размер оригинального файла
  FileSize := TgsFileSystemHelper.GetFileSize(ADatabaseOriginalPath);
  // Оригинальный файл
  FromFile := TFileStream.Create(ADatabaseOriginalPath, fmOpenRead or fmShareDenyNone);
  try
    // Создадим или перезапишем целевой файл
    if FileExists(ADatabaseCopyPath) then
      ToFile := TFileStream.Create(ADatabaseCopyPath, fmOpenReadWrite or fmShareDenyWrite)
    else
      ToFile := TFileStream.Create(ADatabaseCopyPath, fmCreate);
    try
      CopiedSize := 0;
      ToFile.Size := FileSize;
      ToFile.Position := 0;
      FromFile.Position := 0;

      // Визуализация процесса
      FCopyProgressRoutine(FileSize, CopiedSize, 0, 0, 0, 0, 0, 0, nil);
      // Сделаем первое чтение
      NumRead := FromFile.Read(Buffer[0], BUFFER_SIZE);
      while NumRead > 0 do
      begin
        CopiedSize := CopiedSize + NumRead;
        // Визуализация процесса
        FCopyProgressRoutine(FileSize, CopiedSize, 0, 0, 0, 0, 0, 0, nil);
        // Запишем прочитанную инфу
        ToFile.Write(Buffer[0], NumRead);
        // Следующее чтение
        NumRead := FromFile.Read(Buffer[0], BUFFER_SIZE);
      end;

    finally
      FreeAndNil(ToFile);
    end;
  finally
    FreeAndNil(FromFile);
  end;
end;

procedure TgsFDBConvert.BackupDatabase(const ADatabasePath, ABackupPath: String);
var
  BackupService: TIBBackupService;
begin
  // Загрузим встроенный сервер
  LoadIBServer(Self.ServerType);

  BackupService := TIBBackupService.Create(nil);
  try
    BackupService.Protocol := Local;
    BackupService.LoginPrompt := False;
    // Параметры подключения
    BackupService.Params.Clear;
    BackupService.Params.Add('user_name=' + DefaultIBUserName);

    BackupService.Active := True;

    // Путь к базе с которой будет делаться бэкап
    BackupService.DatabaseName := ADatabasePath;
    // Путь к бэкапу
    BackupService.BackupFile.Add(ABackupPath);
    BackupService.Options := [NoGarbageCollection];

    try
      if Assigned(FServiceProgressRoutine) then
        FServiceProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsDatabaseBackupProcess)]));

      BackupService.ServiceStart;
      while (not BackupService.Eof)
        and (BackupService.IsServiceRunning) do
      begin
        if Assigned(FServiceProgressRoutine) then
          FServiceProgressRoutine(BackupService.GetNextLine);
      end;

    except
      on E: Exception do
      begin
        BackupService.Active := False;

        raise Exception.Create(Format('%s: %s%s%s',
          [TimeToStr(Time), GetLocalizedString(lsDatabaseBackupProcessError), #13#10, E.Message]));
      end;
    end;
  finally
    BackupService.Active := False;
    FreeAndNil(BackupService);
  end;
end;

procedure TgsFDBConvert.RestoreDatabase(const ABackupPath, ADatabasePath: String);
var
  RestoreService: TIBRestoreService;
begin
  // Загрузим встроенный сервер
  LoadIBServer(Self.ServerType);

  RestoreService := TIBRestoreService.Create(nil);
  try
    RestoreService.Protocol := Local;
    RestoreService.LoginPrompt := False;
    // Параметры подключения
    RestoreService.Params.Clear;
    RestoreService.Params.Add('user_name=' + DefaultIBUserName);

    RestoreService.Active := True;  

    // Путь к бэкапу
    RestoreService.BackupFile.Add(ABackupPath);
    // Путь к базе в которую будет восстанавливаться бэкап
    RestoreService.DatabaseName.Add(ADatabasePath);

    RestoreService.Options := [Replace];
    // Если восстанавливаем под Firebird 2.5 (или 3.0), то добавим опцию перекодирования метаданных в unicode
    if (Self.ServerType in [svFirebird_25, svFirebird_30])
       and (ConnectionInformation.CharacterSet <> '')
       and not (Self.OriginalServerType in [svFirebird_21, svFirebird_25, svFirebird_30]) then
      RestoreService.FixFssCharacterSet := ConnectionInformation.CharacterSet;
    RestoreService.PageSize := ConnectionInformation.PageSize;
    RestoreService.PageBuffers := ConnectionInformation.NumBuffers;

    try
      if Assigned(FServiceProgressRoutine) then
        FServiceProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsDatabaseRestoreProcess)]));

      RestoreService.ServiceStart;
      while (not RestoreService.Eof)
        and (RestoreService.IsServiceRunning) do
      begin
        if Assigned(FServiceProgressRoutine) then
          FServiceProgressRoutine(RestoreService.GetNextLine);
      end;

    except
      on E: Exception do
      begin
        RestoreService.Active := False;

        raise Exception.Create(Format('%s: %s%s%s',
          [TimeToStr(Time), GetLocalizedString(lsDatabaseRestoreProcessError), #13#10, E.Message]));
      end;
    end;
  finally
    RestoreService.Active := False;
    FreeAndNil(RestoreService);
  end;
end;

procedure TgsFDBConvert.CheckDatabaseIntegrity(const ADatabasePath: String);
var
  ValidationService: TIBValidationService;
  ibsqlCheck, ibsqlSelect: TIBSQL;
begin
  // Загрузим встроенный сервер
  LoadIBServer(Self.ServerType);

  ValidationService := TIBValidationService.Create(nil);
  try
    ValidationService.Protocol := Local;
    ValidationService.LoginPrompt := False;
    ValidationService.Params.Clear;
    ValidationService.Params.Add('user_name=' + DefaultIBUserName);

    ValidationService.Active := True;

    ValidationService.DatabaseName := ADatabasePath;
    ValidationService.Options := [MendDB, ValidateFull];

    try
      if Assigned(FServiceProgressRoutine) then
        FServiceProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsDatabaseValidationProcess)]));

      ValidationService.ServiceStart;
      while (not ValidationService.Eof)
        and (ValidationService.IsServiceRunning) do
      begin
        if Assigned(FServiceProgressRoutine) then
          FServiceProgressRoutine(ValidationService.GetNextLine);
      end;

    except
      on E: Exception do
      begin
        ValidationService.Active := False;

        raise Exception.Create(Format('%s: %s%s%s',
          [TimeToStr(Time), GetLocalizedString(lsDatabaseValidationProcessError), #13#10, E.Message]));
      end;
    end;
  finally
    ValidationService.Active := False;
    FreeAndNil(ValidationService);
  end;


  Connect;
  try
    ibsqlSelect := TIBSQL.Create(nil);
    ibsqlCheck := TIBSQL.Create(nil);
    try
      ibsqlSelect.Transaction := FReadTransaction;
      ibsqlCheck.Transaction := FReadTransaction;

      if Assigned(FServiceProgressRoutine) then
        FServiceProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsDatabaseNULLCheckProcess)]));

      try
        ibsqlSelect.SQL.Text := 'SELECT r.rdb$relation_name rn, r.rdb$field_name rf ' +
          'FROM rdb$relation_fields r JOIN rdb$fields f ON r.rdb$field_source = f.rdb$field_name ' +
          'WHERE ((r.rdb$null_flag = 1) OR (f.rdb$null_flag = 1)) AND (r.rdb$view_context IS NULL) ' +
          '';
        ibsqlSelect.ExecQuery;

        while not ibsqlSelect.EOF do
        begin
          if GetAsyncKeyState(VK_ESCAPE) shr 1 > 0 then
            break;

          ibsqlCheck.Close;
          ibsqlCheck.SQL.Text := Format('SELECT * FROM %s WHERE %s IS NULL',
            [ibsqlSelect.Fields[0].AsTrimString, ibsqlSelect.Fields[1].AsTrimString]);
          ibsqlCheck.ExecQuery;

          if not ibsqlCheck.EOF then
            raise Exception.Create(Format(GetLocalizedString(lsDatabaseNULLCheckMessage),
              [ibsqlSelect.Fields[1].AsTrimString, ibsqlSelect.Fields[0].AsTrimString]));

          ibsqlSelect.Next;
        end;

      except
        on E: Exception do
          raise Exception.Create(Format('%s: %s%s%s',
          [TimeToStr(Time), GetLocalizedString(lsDatabaseNULLCheckProcessError), #13#10, E.Message]));
      end;
    finally
      ibsqlSelect.Free;
      ibsqlCheck.Free;
    end;
  finally
    Disconnect;
  end;
end;

function TgsFDBConvert.CheckServerAvailability(const AServerVersion: TgsServerVersion): Boolean;
var
  ServerPath: String;
begin
  Result := False;
  // Получим абсолютный путь к файлу необходимого встроенного сервера
  ServerPath := TgsFileSystemHelper.GetPathToServer(AServerVersion);
  if ServerPath <> '' then
    Result := True;
end;

procedure TgsFDBConvert.LoadIBServer(const AServerVersion: TgsServerVersion);
begin
  if AServerVersion <> svUnknown then
  begin
    FServerType := AServerVersion;
    // Добавим в спиcок поиска DLL директорию сервера
    SetDllDirectory(PChar(TgsFileSystemHelper.GetPathToServerDirectory(AServerVersion)));
    TgsFileSystemHelper.ChangeFirebirdRootDirectory(TgsFileSystemHelper.GetPathToServerDirectory(AServerVersion));
    // Установим новый путь к серверу
    SetIBLibraryName(TgsFileSystemHelper.GetPathToServer(AServerVersion));
    // Загрузим сервер
    LoadIBLibrary;
  end
  else
    raise Exception.Create('TgsFDBConvert.LoadIBServer: Server version not specified');
end;

procedure TgsFDBConvert.Connect;
begin
  // Загрузим встроенный сервер
  LoadIBServer(FServerType);
  // Подключимся к БД
  FDatabase.DatabaseName := FDatabaseName;
  FDatabase.Params.Clear;
  FDatabase.Params.Add('user_name=' + DefaultIBUserName);
  if FConnectionInformation.CharacterSet <> '' then
    FDatabase.Params.Add('lc_ctype=' + FConnectionInformation.CharacterSet);
  FDatabase.LoginPrompt := False;
  FDatabase.Open;
  // Запустим читающую транзакцию
  FReadTransaction.StartTransaction;
end;

function TgsFDBConvert.TryConnect: Boolean;
begin
  Result := False;
  try
    Connect;
    Result := True;
  except
    //
  end;
end;

procedure TgsFDBConvert.Disconnect;
begin
  if Connected then
  begin
    if Assigned(FReadTransaction) and FReadTransaction.InTransaction then
      FReadTransaction.Commit;
    FDatabase.Close;

    // Выгрузим библиотеку сервера БД
    FreeIBLibrary;
    // Удалим установленную директорию для поиска DLL сервера
    SetDllDirectory('');
  end;
end;

function TgsFDBConvert.GetConnected: Boolean;
begin
  if Assigned(FDatabase) then
    Result := FDatabase.Connected
  else
    Result := False;
end;

function TgsFDBConvert.GetDatabaseName: String;
begin
  Result := FDatabaseName;
end;

procedure TgsFDBConvert.SetDatabaseName(const Value: String);
begin
  FDatabaseName := ExpandFileName(Value);
end;

function TgsFDBConvert.GetDatabaseVersion: TgsDatabaseVersion;
var
  ODSMajorVersion, ODSMinorVersion: Integer;
begin
  Result := dvUnknown;
  if Connected then
  begin
    // Получим значения ODS из БД
    ODSMajorVersion := FDatabaseInfo.ODSMajorVersion;
    ODSMinorVersion := FDatabaseInfo.ODSMinorVersion;
    // Определим версию БД на основании полученных значений
    case ODSMajorVersion of
      10: // Yaffil, Firebird 1.5
        Result := dvODS_10_0;

      11: // Firebird 2.0 +
        case ODSMinorVersion of
          0: Result := dvODS_11_0;   // 2.0
          1: Result := dvODS_11_1;   // 2.1
          2: Result := dvODS_11_2;   // 2.5
        end;

      12: // Firebird 3.0
        Result := dvODS_12;
    end;
  end
  else
    raise Exception.Create('Database not available');
end;

function TgsFDBConvert.GetDatabaseCharacterSet: String;
var
  ibsql: TIBSQL;
begin
  Result := '';
  if Connected then
  begin
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := FReadTransaction;
      ibsql.SQL.Text := 'SELECT rdb$character_set_name AS char_set FROM rdb$database';
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
        Result := Trim(ibsql.FieldByName('CHAR_SET').AsString);
    finally
      FreeAndNil(ibsql);
    end;
  end
  else
    raise Exception.Create('Database not available');
end;

procedure TgsFDBConvert.CreateConvertHelpMetadata;
var
  ibsqlMetadata: TIBSQL;
begin
  if not ConvertHelpMetadataExists then
  begin
    ibsqlMetadata := TIBSQL.Create(nil);
    try
      ibsqlMetadata.Transaction := FWriteTransaction;

      FWriteTransaction.StartTransaction;
      try
        // Создание вспомогательной таблицы
        ibsqlMetadata.SQL.Text := HELP_METADATA_TABLE_CODE;
        ibsqlMetadata.ExecQuery;
        // Генератор для вспомогательной таблицы
        ibsqlMetadata.SQL.Text := HELP_METADATA_GENERATOR_CODE;
        ibsqlMetadata.ExecQuery;
        // Триггер для вспомогательной таблицы
        ibsqlMetadata.SQL.Text := HELP_METADATA_TRIGGER_CODE;
        ibsqlMetadata.ExecQuery;

        if FWriteTransaction.InTransaction then
          FWriteTransaction.Commit;
      except
        if FWriteTransaction.InTransaction then
          FWriteTransaction.Rollback;
        raise;
      end;
    finally
      FreeAndNil(ibsqlMetadata);
    end;
  end;  
end;

procedure TgsFDBConvert.DestroyConvertHelpMetadata;
var
  ibsqlMetadata: TIBSQL;
begin
  ibsqlMetadata := TIBSQL.Create(nil);
  try
    ibsqlMetadata.Transaction := FWriteTransaction;

    FWriteTransaction.StartTransaction;
    try
      // Удаление триггера для вспомогательной таблицы
      ibsqlMetadata.SQL.Text :=
        'DROP TRIGGER ' + HELP_METADATA_TRIGGER;
      ibsqlMetadata.ExecQuery;
      // Удаление генератора для вспомогательной таблицы
      ibsqlMetadata.SQL.Text :=
        'DROP GENERATOR ' + HELP_METADATA_GENERATOR;
      ibsqlMetadata.ExecQuery;
      // Создание вспомогательной таблицы
      ibsqlMetadata.SQL.Text :=
        'DROP TABLE ' + HELP_METADATA_TABLE;
      ibsqlMetadata.ExecQuery;

      if FWriteTransaction.InTransaction then
        FWriteTransaction.Commit;
    except
      if FWriteTransaction.InTransaction then
        FWriteTransaction.Rollback;
    end;
  finally
    FreeAndNil(ibsqlMetadata);
  end;
end;

function TgsFDBConvert.ConvertHelpMetadataExists: Boolean;
var
  ibsqlMetadata: TIBSQL;
begin
  Result := False;

  ibsqlMetadata := TIBSQL.Create(nil);
  try
    ibsqlMetadata.Transaction := FReadTransaction;

    // Удаление триггера для вспомогательной таблицы
    ibsqlMetadata.SQL.Text :=
      'SELECT rdb$relation_name FROM rdb$relations WHERE UPPER(TRIM(rdb$relation_name)) = :rel_name ';
    ibsqlMetadata.ParamByName('REL_NAME').AsString := HELP_METADATA_TABLE;
    ibsqlMetadata.ExecQuery;

    if ibsqlMetadata.RecordCount > 0 then
      Result := True;

  finally
    FreeAndNil(ibsqlMetadata);
  end;
end;

{ TgsMetadataEditor }

constructor TgsMetadataEditor.Create(ADatabase: TIBDatabase);
begin
  if Assigned(ADatabase) then
  begin
    FDatabase := ADatabase;

    FWriteTransaction := TIBTransaction.Create(nil);
    FWriteTransaction.DefaultDatabase := ADatabase;
    FWriteTransaction.Params.Text := 'read_committed'#13#10'rec_version'#13#10'nowait'#13#10;

    FIBSQLRead := TIBSQL.Create(nil);
    FIBSQLRead.Transaction := ADatabase.DefaultTransaction;

    FIBSQLWrite := TIBSQL.Create(nil);
    FIBSQLWrite.Transaction := FWriteTransaction;

    FSubstituteFunctionList := TStringList.Create;
  end
  else
    raise Exception.Create('Object TgsMetadataEditor needs database');
end;

destructor TgsMetadataEditor.Destroy;
begin
  if Assigned(FWriteTransaction) then
    FreeAndNil(FWriteTransaction);
  if Assigned(FIBSQLRead) then
    FreeAndNil(FIBSQLRead);
  if Assigned(FIBSQLWrite) then
    FreeAndNil(FIBSQLWrite);
  if Assigned(FSubstituteFunctionList) then
    FreeAndNil(FSubstituteFunctionList);
end;

procedure TgsMetadataEditor.GetProcedureList(AProcedureList: TStrings);
begin
  FIBSQLRead.SQL.Text :=
    'SELECT rdb$procedure_name AS procedure_name FROM rdb$procedures';
  FIBSQLRead.ExecQuery;

  while not FIBSQLRead.Eof do
  begin
    AProcedureList.Add(Trim(FIBSQLRead.FieldByName('PROCEDURE_NAME').AsString));
    FIBSQLRead.Next;
  end;
  FIBSQLRead.Close;
end;

procedure TgsMetadataEditor.GetTriggerList(ATriggerList: TStrings);
begin
  FIBSQLRead.SQL.Text :=
    ' SELECT ' +
    '   rdb$trigger_name AS trigger_name ' +
    ' FROM ' +
    '   rdb$triggers ' +
    ' WHERE ' +
    '   NOT rdb$trigger_source IS NULL ' +
    '   AND NOT rdb$trigger_name LIKE ''CHECK%'' ' +
    '   AND NOT UPPER(TRIM(rdb$trigger_name)) = :help_trigger_name ';
  FIBSQLRead.ParamByName('HELP_TRIGGER_NAME').AsString := HELP_METADATA_TRIGGER; 
  FIBSQLRead.ExecQuery;

  while not FIBSQLRead.Eof do
  begin
    ATriggerList.Add(Trim(FIBSQLRead.FieldByName('TRIGGER_NAME').AsString));
    FIBSQLRead.Next;
  end;
  FIBSQLRead.Close;
end;

procedure TgsMetadataEditor.GetUDFFunctionList(AFunctionList: TStrings);
begin
  FIBSQLRead.SQL.Text :=
    'SELECT DISTINCT ' +
    '  f.rdb$function_name AS funcname, f.rdb$module_name AS modulename ' +
    'FROM ' +
    '  rdb$functions f ' +
    '  LEFT JOIN rdb$dependencies d ON d.rdb$depended_on_name = f.rdb$function_name ' +
    'WHERE ' +
    '  d.rdb$depended_on_type = 15 ';
  FIBSQLRead.ExecQuery;

  while not FIBSQLRead.Eof do
  begin
    AFunctionList.Add(Trim(FIBSQLRead.FieldByName('FUNCNAME').AsString) + ',' +
      Trim(FIBSQLRead.FieldByName('MODULENAME').AsString));
    FIBSQLRead.Next;
  end;
  FIBSQLRead.Close;
end;

procedure TgsMetadataEditor.GetViewAndComputedFieldList(AMetadataList: TStrings);
var
  MetadataName: String;
  CircularReferenceList: TStringList;

  function FormMetadataString(const ARelationName: String; const AFieldName: String = ''): String;
  begin
    if AFieldName = '' then
      Result := Trim(ARelationName)
    else
      Result := Trim(ARelationName) + ',' + Trim(AFieldName);
  end;

  procedure GetMetadataDependency(const ARelationName: String; const AFieldName: String = '');
  var
    ibsqlDependency: TIBSQL;
    DepMetadataName: String;
  begin
    ibsqlDependency := TIBSQL.Create(nil);
    try
      ibsqlDependency.Transaction := FDatabase.DefaultTransaction;
      // Запрос на поиск представлений и вычисляемых полей зависящих от переданного объекта
      if AFieldName = '' then
      begin
        // Передано представление
        ibsqlDependency.SQL.Text :=
          'SELECT DISTINCT ' +
          '  d1.rdb$dependent_name AS rel_name, CAST(NULL AS CHAR(31)) AS field_name ' +
          'FROM ' +
          '  rdb$dependencies d1 ' +
          '  LEFT JOIN rdb$relations r1 ON d1.rdb$dependent_name = r1.rdb$relation_name AND NOT r1.rdb$view_blr IS NULL ' +
          'WHERE ' +
          '  d1.rdb$dependent_type = 1 ' +
          '  AND UPPER(TRIM(d1.rdb$depended_on_name)) = UPPER(:metadata_name) ' +
          ' ' +
          'UNION ' +
          ' ' +
          'SELECT DISTINCT ' +
          '  f2.rdb$relation_name AS rel_name, CAST(NULL AS CHAR(31)) AS field_name ' +
          'FROM ' +
          '  rdb$dependencies d2 ' +
          '  JOIN rdb$relation_fields f2 on d2.rdb$dependent_name = f2.rdb$field_source ' +
          '  LEFT JOIN rdb$relations r2 on (f2.rdb$relation_name = r2.rdb$relation_name) and (not r2.Rdb$View_Blr is null) ' +
          'WHERE ' +
          '  d2.rdb$dependent_type = 3 ' +
          '  AND UPPER(TRIM(d2.rdb$depended_on_name)) = UPPER(:metadata_name) ' +
          ' ' +
          'UNION ' +
          ' ' +
          'SELECT DISTINCT ' +
          '  f2.rdb$relation_name AS rel_name, f2.rdb$field_name AS field_name ' +
          'FROM ' +
          '  rdb$dependencies d2 ' +
          '  JOIN rdb$relation_fields f2 ON f2.rdb$field_source = d2.rdb$dependent_name ' +
          '  JOIN rdb$fields f ON f.rdb$field_name = f2.rdb$field_source ' +
          '  JOIN rdb$relations r ON r.rdb$relation_name = f2.rdb$relation_name ' +
          'WHERE ' +
          '  d2.rdb$dependent_type = 3 ' +
          '  AND UPPER(TRIM(d2.rdb$depended_on_name)) = UPPER(:metadata_name) ' +
          '  AND NOT f.rdb$computed_source IS NULL ' +
          '  AND r.rdb$view_source IS NULL ' +
          ' ' +
          'ORDER BY ' +
          '  1, 2 ';
        ibsqlDependency.ParamByName('METADATA_NAME').AsString := ARelationName;
      end
      else
      begin
        // Передано вычисляемое поле
        ibsqlDependency.SQL.Text :=
          'SELECT DISTINCT ' +
          '  d1.rdb$dependent_name AS rel_name, CAST(NULL AS CHAR(31)) AS field_name ' +
          'FROM ' +
          '  rdb$dependencies d1 ' +
          '  LEFT JOIN rdb$relations r1 ON d1.rdb$dependent_name = r1.rdb$relation_name AND NOT r1.rdb$view_blr IS NULL ' +
          'WHERE ' +
          '  d1.rdb$dependent_type = 1 ' +
          '  AND UPPER(TRIM(d1.rdb$field_name)) = UPPER(:metadata_name) ' +
          ' ' +
          'UNION ALL ' +
          ' ' +
          'SELECT DISTINCT ' +
          '  f2.rdb$relation_name AS rel_name, f2.rdb$field_name AS field_name ' +
          'FROM ' +
          '  rdb$dependencies d2 ' +
          '  JOIN rdb$relation_fields f2 ON f2.rdb$field_source = d2.rdb$dependent_name ' +
          '  JOIN rdb$fields f ON f.rdb$field_name = f2.rdb$field_source ' +
          '  JOIN rdb$relations r ON r.rdb$relation_name = f2.rdb$relation_name ' +
          'WHERE ' +
          '  d2.rdb$dependent_type = 3 ' +
          '  AND UPPER(TRIM(d2.rdb$field_name)) = UPPER(:metadata_name) ' +
          '  AND NOT f.rdb$computed_source IS NULL ' +
          '  AND r.rdb$view_source IS NULL ' +
          ' ' +
          'ORDER BY ' +
          '  1, 2 ';
        ibsqlDependency.ParamByName('METADATA_NAME').AsString := AFieldName;
      end;
      ibsqlDependency.ExecQuery;
      // Пройдем по списку зависящих объектов
      while not ibsqlDependency.Eof do
      begin
        // Сформируем имя данного объекта
        DepMetadataName := FormMetadataString(ibsqlDependency.FieldByName('REL_NAME').AsString,
          ibsqlDependency.FieldByName('FIELD_NAME').AsString);
        // Если объект еще не в списке для удаления, то добавим его
        if AMetadataList.IndexOf(DepMetadataName) = -1 then
        begin
          // Проверим на зацикливание при поиске зависящих объектов
          if CircularReferenceList.IndexOf(DepMetadataName) = -1 then
          begin
            // Добавим в список для проверки на зацикливание
            CircularReferenceList.Add(DepMetadataName);
            // Найдем зависящие объекты
            GetMetadataDependency(Trim(ibsqlDependency.FieldByName('REL_NAME').AsString),
              Trim(ibsqlDependency.FieldByName('FIELD_NAME').AsString));
            // Удалим из списка для проверки на зацикливание
            CircularReferenceList.Delete(CircularReferenceList.IndexOf(DepMetadataName));
          end
          else
          begin
            CircularReferenceList.Add(DepMetadataName);
            raise Exception.Create(GetLocalizedString(lsCircularReferenceError) + #13#10 +
              '  ' + CircularReferenceList.CommaText);
          end;
          AMetadataList.Add(DepMetadataName);
        end;
        ibsqlDependency.Next;
      end;
    finally
      FreeAndNil(ibsqlDependency);
    end;
  end;

begin
  // Получим список представлений и вычисляемых полей системы
  FIBSQLRead.SQL.Text :=
    ' SELECT DISTINCT ' +
    '   r.rdb$relation_name AS rel_name, CAST(NULL AS CHAR(31)) AS field_name ' +
    ' FROM ' +
    '   rdb$relations r ' +
    ' WHERE ' +
    '   NOT rdb$view_source IS NULL ' +
    ' ' +
    ' UNION ALL ' +
    ' ' +
    ' SELECT DISTINCT ' +
    '   rf.rdb$relation_name AS rel_name, rf.rdb$field_name AS field_name ' +
    ' FROM ' +
    '   rdb$relation_fields rf ' +
    '   JOIN rdb$fields f ON f.rdb$field_name = rf.rdb$field_source ' +
    '   JOIN rdb$relations r ON r.rdb$relation_name = rf.rdb$relation_name ' +
    ' WHERE ' +
    '   NOT f.rdb$computed_source IS NULL ' +
    '   AND r.rdb$view_source IS NULL ' +
    ' ' +
    ' ORDER BY ' +
    '   1, 2 ';                              

  CircularReferenceList := TStringList.Create;
  try
    FIBSQLRead.ExecQuery;
    while not FIBSQLRead.Eof do
    begin
      // Сформируем имя данного объекта
      MetadataName := FormMetadataString(FIBSQLRead.FieldByName('REL_NAME').AsString,
        FIBSQLRead.FieldByName('FIELD_NAME').AsString);
      if AMetadataList.IndexOf(MetadataName) = -1 then
      begin
        // Добавим в список для проверки на зацикливание
        CircularReferenceList.Add(MetadataName);
        // Найдем зависящие объекты
        GetMetadataDependency(Trim(FIBSQLRead.FieldByName('REL_NAME').AsString),
          Trim(FIBSQLRead.FieldByName('FIELD_NAME').AsString));
        // Очистим список для проверки на зацикливание
        CircularReferenceList.Clear;
        AMetadataList.Add(MetadataName);
      end;

      FIBSQLRead.Next;
    end;
    FIBSQLRead.Close;
  finally
    FreeAndNil(CircularReferenceList);
  end;
end;

procedure TgsMetadataEditor.GetBackupViewAndComputedFieldList(AMetadataList: TStrings);
begin
  FIBSQLRead.SQL.Text :=
    'SELECT DISTINCT ' +
    '  t.obj_type, t.name, t.relation_name ' +
    'FROM ' +
      HELP_METADATA_TABLE + ' t ' +
    'ORDER BY ' +
    '  id DESC ' ;
  FIBSQLRead.ExecQuery;

  while not FIBSQLRead.Eof do
  begin
    // В зависимости от типа метаданных будем вытягивать ИМЯ, или ИМЯ + ИМЯ_ТАБЛИЦЫ
    if FIBSQLRead.FieldByName('OBJ_TYPE').AsString = HELP_VIEW_TYPE then
      AMetadataList.Add(Trim(FIBSQLRead.FieldByName('NAME').AsString))
    else if FIBSQLRead.FieldByName('OBJ_TYPE').AsString = HELP_COMPUTED_FIELD_TYPE then
      AMetadataList.Add(Trim(FIBSQLRead.FieldByName('RELATION_NAME').AsString) + ',' +
        Trim(FIBSQLRead.FieldByName('NAME').AsString));

    FIBSQLRead.Next;
  end;
  FIBSQLRead.Close;
end;

function TgsMetadataEditor.GetProcedureText(const AProcedureName: String): String;
begin
  Result := '';

  FIBSQLRead.SQL.Text :=
    ' SELECT rdb$procedure_source AS FuncSource FROM rdb$procedures ' +
    ' WHERE UPPER(TRIM(rdb$procedure_name)) = UPPER(:procedure_name) ';
  FIBSQLRead.ParamByName('PROCEDURE_NAME').AsString := AProcedureName;

  try
    FIBSQLRead.ExecQuery;

    if FIBSQLRead.RecordCount > 0 then
      Result := FIBSQLRead.FieldByName('FUNCSOURCE').AsString
    else
      raise Exception.Create('TgsMetadataEditor.GetProcedureText'#13#10 +
        '  Stored procedure "' + AProcedureName + '" not found');
  finally
    FIBSQLRead.Close;
  end;
end;

function TgsMetadataEditor.GetProcedureParamText(const AProcedureName: String): String;
begin
  Result := GetParamsText(AProcedureName, FDatabase);
end;

function TgsMetadataEditor.GetTriggerText(const ATriggerName: String): String;
begin
  Result := '';

  FIBSQLRead.SQL.Text :=
    ' SELECT rdb$trigger_source AS FuncSource FROM rdb$triggers ' +
    ' WHERE UPPER(TRIM(rdb$trigger_name)) = UPPER(:trigger_name) ';
  FIBSQLRead.ParamByName('TRIGGER_NAME').AsString := ATriggerName;

  try
    FIBSQLRead.ExecQuery;

    if FIBSQLRead.RecordCount > 0 then
      Result := FIBSQLRead.FieldByName('FUNCSOURCE').AsString
    else
      raise Exception.Create('TgsMetadataEditor.GetTriggerText'#13#10 +
        '  Trigger "' + ATriggerName + '" not found');
  finally
    FIBSQLRead.Close;
  end;
end;

function TgsMetadataEditor.GetComputedFieldText(const ARelationName,
  AComputedFieldName: String): String;
begin
  Result := '';

  FIBSQLRead.SQL.Text :=
    ' SELECT ' +
    '   f.rdb$computed_source AS field_source ' +
    ' FROM ' +
    '   rdb$relation_fields rf ' +
    '   JOIN rdb$fields f ON f.rdb$field_name = rf.rdb$field_source ' +
    ' WHERE ' +
    '   UPPER(TRIM(rf.rdb$relation_name)) = UPPER(:rel_name) ' +
    '   AND UPPER(TRIM(rf.rdb$field_name)) = UPPER(:field_name) ' +
    '   AND NOT f.rdb$computed_source IS NULL ';
  FIBSQLRead.ParamByName('REL_NAME').AsString := ARelationName;
  FIBSQLRead.ParamByName('FIELD_NAME').AsString := AComputedFieldName;

  try
    FIBSQLRead.ExecQuery;

    if FIBSQLRead.RecordCount > 0 then
      Result := FIBSQLRead.FieldByName('FIELD_SOURCE').AsString
    else
      raise Exception.Create('TgsMetadataEditor.GetComputedFieldText'#13#10 +
        '  Computed field "' + ARelationName + '.' + AComputedFieldName + '" not found');
  finally
    FIBSQLRead.Close;
  end;
end;

function TgsMetadataEditor.GetViewText(const AViewName: String): String;
var
  ViewText: String;
begin
  Result := '';

  FIBSQLRead.SQL.Text :=
    ' SELECT ' +
    '   rdb$view_source AS view_source ' +
    ' FROM ' +
    '   rdb$relations ' +
    ' WHERE ' +
    '   UPPER(TRIM(rdb$relation_name)) = UPPER(:view_name) ' +
    '   AND NOT rdb$view_source IS NULL ';
  FIBSQLRead.ParamByName('VIEW_NAME').AsString := AViewName;

  try
    FIBSQLRead.ExecQuery;
    if FIBSQLRead.RecordCount > 0 then
      ViewText := FIBSQLRead.FieldByName('VIEW_SOURCE').AsString
    else
      ViewText := '';
  finally
    FIBSQLRead.Close;
  end;

  if ViewText <> '' then
    Result := GetViewParamText(AViewName) + #13#10'AS'#13#10 + ViewText
  else
    raise Exception.Create('TgsMetadataEditor.GetViewText'#13#10 +
      '  View "' + AViewName + '" not found');

end;

function TgsMetadataEditor.GetViewParamText(const AViewName: String): String;
begin
  Result := '';

  FIBSQLRead.SQL.Text :=
    ' SELECT ' +
    '   rf.rdb$field_name AS field_name ' +
    ' FROM ' +
    '   rdb$relations r ' +
    '   JOIN rdb$relation_fields rf ON rf.rdb$relation_name = r.rdb$relation_name ' +
    ' WHERE ' +
    '   UPPER(TRIM(r.rdb$relation_name)) = UPPER(:view_name) ' +
    '   AND NOT r.rdb$view_source IS NULL ';
  FIBSQLRead.ParamByName('VIEW_NAME').AsString := AViewName;

  try
    FIBSQLRead.ExecQuery;
    // Если представление существует
    if FIBSQLRead.RecordCount > 0 then
    begin
      Result := '('#13#10;
      // Пройдем по списку полей представления
      while not FIBSQLRead.Eof do
      begin
        Result := Result + Trim(FIBSQLRead.FieldByName('FIELD_NAME').AsString);
        FIBSQLRead.Next;
        if not FIBSQLRead.EOF then
          Result := Result + ','#13#10
        else
          Result := Result + ')';
      end;
    end
    else
      raise Exception.Create('TgsMetadataEditor.GetViewParamText'#13#10 +
        '  View "' + AViewName + '" not found');
  finally
    FIBSQLRead.Close;
  end;
end;

function TgsMetadataEditor.GetBackupComputedFieldText(const ARelationName, AComputedFieldName: String): String;
begin
  Result := '';

  FIBSQLRead.SQL.Text :=
    ' SELECT ' +
    '   t.source ' +
    ' FROM ' +
      HELP_METADATA_TABLE + ' t ' +
    ' WHERE ' +
    '   t.obj_type = :obj_type ' +
    '   AND UPPER(TRIM(t.relation_name)) = UPPER(:rel_name) ' +
    '   AND UPPER(TRIM(t.name)) = UPPER(:field_name) ';
  FIBSQLRead.ParamByName('OBJ_TYPE').AsString := HELP_COMPUTED_FIELD_TYPE;
  FIBSQLRead.ParamByName('REL_NAME').AsString := ARelationName;
  FIBSQLRead.ParamByName('FIELD_NAME').AsString := AComputedFieldName;
  try
    FIBSQLRead.ExecQuery;

    if FIBSQLRead.RecordCount > 0 then
      Result := FIBSQLRead.FieldByName('SOURCE').AsString
    else
      raise Exception.Create('TgsMetadataEditor.GetBackupComputedFieldText'#13#10 +
        '  Computed field "' + ARelationName + '.' + AComputedFieldName + '" not found');
  finally
    FIBSQLRead.Close;
  end;
end;

function TgsMetadataEditor.GetBackupViewText(const AViewName: String): String;
begin
  Result := '';

  FIBSQLRead.SQL.Text :=
    ' SELECT ' +
    '   t.source ' +
    ' FROM ' +
      HELP_METADATA_TABLE + ' t ' +
    ' WHERE ' +
    '   t.obj_type = :obj_type ' +
    '   AND UPPER(TRIM(t.name)) = UPPER(:view_name) ';
  FIBSQLRead.ParamByName('OBJ_TYPE').AsString := HELP_VIEW_TYPE;
  FIBSQLRead.ParamByName('VIEW_NAME').AsString := AViewName;
  try
    FIBSQLRead.ExecQuery;

    if FIBSQLRead.RecordCount > 0 then
      Result := FIBSQLRead.FieldByName('SOURCE').AsString
    else
      raise Exception.Create('TgsMetadataEditor.GetBackupViewText'#13#10 +
        '  View "' + AViewName + '" not found');
  finally
    FIBSQLRead.Close;
  end;
end;

procedure TgsMetadataEditor.SetProcedureText(const AProcedureName, AProcedureText: String; const AParams: String = '_');
var
  ParamText: String;
begin
  // Если не передан текст параметров, возьмем из БД
  if AParams = '_' then
    ParamText := GetProcedureParamText(AProcedureName)
  else
    ParamText := AParams;

  // Запишем измененную процедуру в БД
  FWriteTransaction.StartTransaction;
  try
    FIBSQLWrite.SQL.Text :=
      'ALTER PROCEDURE ' + AProcedureName + ' ' + ParamText + ' AS ' + AProcedureText;
    try
      FIBSQLWrite.ExecQuery;
    finally
      FIBSQLWrite.Close;
    end;

    if FWriteTransaction.InTransaction then
      FWriteTransaction.Commit;
  except
    if FWriteTransaction.InTransaction then
      FWriteTransaction.Rollback;
    raise;
  end;
end;

procedure TgsMetadataEditor.SetTriggerText(const ATriggerName, ATriggerText: String);
begin
  // Запишем измененный триггер в БД
  FWriteTransaction.StartTransaction;
  try
    FIBSQLWrite.SQL.Text :=
      'ALTER TRIGGER ' + ATriggerName + #13#10 + ATriggerText;
    try
      FIBSQLWrite.ExecQuery;
    finally
      FIBSQLWrite.Close;
    end;

    if FWriteTransaction.InTransaction then
      FWriteTransaction.Commit;
  except
    if FWriteTransaction.InTransaction then
      FWriteTransaction.Rollback;
    raise;
  end;
end;

procedure TgsMetadataEditor.SetComputedFieldText(const ARelationName,
  AComputedFieldName, AComputedFieldText: String);
begin
  // Запишем измененное вычисляемое поле в БД
  FWriteTransaction.StartTransaction;
  try
    FIBSQLWrite.SQL.Text :=
      'ALTER TABLE ' + ARelationName + ' ALTER ' + AComputedFieldName + ' COMPUTED BY ' + AComputedFieldText;
    try
      FIBSQLWrite.ExecQuery;
    finally
      FIBSQLWrite.Close;
    end;

    if FWriteTransaction.InTransaction then
      FWriteTransaction.Commit;
  except
    if FWriteTransaction.InTransaction then
      FWriteTransaction.Rollback;
    raise;
  end;
end;

procedure TgsMetadataEditor.SetViewText(const AViewName, AViewText: String);
begin
  // Запишем измененное представление в БД
  FWriteTransaction.StartTransaction;
  try
    FIBSQLWrite.SQL.Text :=
      'CREATE OR ALTER VIEW ' + AViewName + AViewText;
    try
      FIBSQLWrite.ExecQuery;
    finally
      FIBSQLWrite.Close;
    end;

    if FWriteTransaction.InTransaction then
      FWriteTransaction.Commit;
  except
    if FWriteTransaction.InTransaction then
      FWriteTransaction.Rollback;
    raise;
  end;
end;

class function TgsMetadataEditor.CommentFunctionBody(var AFunctionText: String): Boolean;
var
  CharPosition: Integer;
  LengthBeginComment, LengthEndComment, LengthBegin: Integer;
begin
  // Если тело функции еще не закомментировали
  if StrFind(FUNCTION_COMMENT_BEGIN, AFunctionText) = 0 then
  begin
    Result := True;
    // Подготовка к процессу
    CharPosition := 1;
    LengthBeginComment := Length(FUNCTION_COMMENT_BEGIN);
    LengthEndComment := Length(FUNCTION_COMMENT_END);
    LengthBegin := Length('BEGIN');

    // Пройдем от начала текста и установим начало комментария после BEGIN
    while CharPosition > 0 do
    begin
      CharPosition := StrFind('BEGIN', AFunctionText, CharPosition);
      // Удостоверимся что это управляющий BEGIN, а не кусок названия параметра
      //  Также удостоверимся что BEGIN не заключен в комментарий
      if IsSeparateWord(AFunctionText, CharPosition, LengthBegin)
       and not IsCommented(CharPosition, AFunctionText) then
      begin
        CharPosition := CharPosition + LengthBegin;
        Insert(FUNCTION_COMMENT_BEGIN, AFunctionText, CharPosition);
        Break;
      end
      else
        CharPosition := CharPosition + LengthBegin;
    end;
    // Перейдем к концу комментария
    CharPosition := CharPosition + LengthBeginComment;
    // Пробежим по всей функции и экранируем комментарии
    while CharPosition > 0 do
    begin
      // Перед началом комментария закроем служебный комментарий
      CharPosition := StrFind('/*', AFunctionText, CharPosition);
      if CharPosition > 0 then
      begin
        Insert(FUNCTION_COMMENT_END, AFunctionText, CharPosition);
        CharPosition := CharPosition + LengthEndComment + 1;
      end;
      // После комментария откроем служебный комментарий
      CharPosition := StrFind('*/', AFunctionText, CharPosition);
      if CharPosition > 0 then
      begin
        Insert(FUNCTION_COMMENT_BEGIN, AFunctionText, CharPosition + 2);
        CharPosition := CharPosition + LengthBeginComment + 2;
      end;
    end;
    // Пройдем от конца текста и установим конец комментария перед END
    // TODO: не обрабатывается случай когда после END идет комментарий содержащий END
    CharPosition := StrILastPos('END', AFunctionText);
    if CharPosition > 0 then
      Insert(FUNCTION_COMMENT_END, AFunctionText, CharPosition);
  end
  else
    Result := False;
end;

class function TgsMetadataEditor.UncommentFunctionBody(var AFunctionText: String): Boolean;
begin
  if StrFind(FUNCTION_COMMENT_BEGIN, AFunctionText) <> 0 then
  begin
    Result := True;
    // Пробежим по всей функции и уберем служебные комментариии
    StrReplace(AFunctionText, FUNCTION_COMMENT_BEGIN, '', [rfReplaceAll]);
    StrReplace(AFunctionText, FUNCTION_COMMENT_END, '', [rfReplaceAll]);
  end
  else
    Result := False;
end;

procedure TgsMetadataEditor.BackupComputedField(const ARelationName, AComputedFieldName: String);
begin
  // Сохраним вычисляемое поле во временную таблицу
  FWriteTransaction.StartTransaction;
  try
    FIBSQLWrite.SQL.Text :=
      ' INSERT INTO ' + HELP_METADATA_TABLE +
      '   (obj_type, name, relation_name, source) ' +
      ' VALUES ' +
      '   (:obj_type, :name, :relation_name, :source)';
    FIBSQLWrite.ParamByName('OBJ_TYPE').AsString := HELP_COMPUTED_FIELD_TYPE;
    FIBSQLWrite.ParamByName('NAME').AsString := AComputedFieldName;
    FIBSQLWrite.ParamByName('RELATION_NAME').AsString := ARelationName;
    FIBSQLWrite.ParamByName('SOURCE').AsString := GetComputedFieldText(ARelationName, AComputedFieldName);
    try
      FIBSQLWrite.ExecQuery;
    finally
      FIBSQLWrite.Close;
    end;

    if FWriteTransaction.InTransaction then
      FWriteTransaction.Commit;
  except
    if FWriteTransaction.InTransaction then
      FWriteTransaction.Rollback;
    raise;
  end;
end;

procedure TgsMetadataEditor.BackupView(const AViewName: String);
begin
  // Сохраним представление во временную таблицу
  FWriteTransaction.StartTransaction;
  try
    FIBSQLWrite.SQL.Text :=
      ' INSERT INTO ' + HELP_METADATA_TABLE +
      '   (obj_type, name, source) ' +
      ' VALUES ' +
      '   (:obj_type, :name, :source)';
    FIBSQLWrite.ParamByName('OBJ_TYPE').AsString := HELP_VIEW_TYPE;
    FIBSQLWrite.ParamByName('NAME').AsString := AViewName;
    FIBSQLWrite.ParamByName('SOURCE').AsString := GetViewText(AViewName);
    try
      FIBSQLWrite.ExecQuery;
    finally
      FIBSQLWrite.Close;
    end;

    if FWriteTransaction.InTransaction then
      FWriteTransaction.Commit;
  except
    if FWriteTransaction.InTransaction then
      FWriteTransaction.Rollback;
    raise;
  end;
end;

procedure TgsMetadataEditor.RestoreComputedField(const ARelationName, AComputedFieldName: String);
begin
  // Восстановим вычисляемое поле из временной таблицы
  FWriteTransaction.StartTransaction;
  try
    FIBSQLWrite.SQL.Text := Format(
      ' ALTER TABLE %0:s ' +
      ' ADD %1:s ' +
      ' COMPUTED BY %2:s ',
      [ARelationName, AComputedFieldName, GetBackupComputedFieldText(ARelationName, AComputedFieldName)]);
    try
      FIBSQLWrite.ExecQuery;
    finally
      FIBSQLWrite.Close;
    end;

    if FWriteTransaction.InTransaction then
      FWriteTransaction.Commit;
  except
    if FWriteTransaction.InTransaction then
      FWriteTransaction.Rollback;
    raise;
  end;
end;

procedure TgsMetadataEditor.RestoreView(const AViewName: String);
begin
  // Восстановим представление из временной таблицы
  FWriteTransaction.StartTransaction;
  try
    FIBSQLWrite.SQL.Text := Format(
      ' CREATE VIEW %0:s ' +
      ' %1:s ',
      [AViewName, GetBackupViewText(AViewName)]);
    try
      FIBSQLWrite.ExecQuery;
    finally
      FIBSQLWrite.Close;
    end;

    if FWriteTransaction.InTransaction then
      FWriteTransaction.Commit;
  except
    if FWriteTransaction.InTransaction then
      FWriteTransaction.Rollback;
    raise;
  end;
end;

procedure TgsMetadataEditor.DeleteComputedField(const ARelationName,
  AComputedFieldName: String);
begin
  // Удалим вычисляемое поле
  FWriteTransaction.StartTransaction;
  try
    FIBSQLWrite.SQL.Text :=
      'ALTER TABLE ' + ARelationName + ' DROP ' + AComputedFieldName;
    try
      FIBSQLWrite.ExecQuery;
    finally
      FIBSQLWrite.Close;
    end;

    if FWriteTransaction.InTransaction then
      FWriteTransaction.Commit;
  except
    if FWriteTransaction.InTransaction then
      FWriteTransaction.Rollback;
    raise;
  end;
end;

procedure TgsMetadataEditor.DeleteView(const AViewName: String);
begin
  // Удалим вычисляемое поле
  FWriteTransaction.StartTransaction;
  try
    FIBSQLWrite.SQL.Text :=
      'DROP VIEW ' + AViewName;
    try
      FIBSQLWrite.ExecQuery;
    finally
      FIBSQLWrite.Close;
    end;

    if FWriteTransaction.InTransaction then
      FWriteTransaction.Commit;
  except
    if FWriteTransaction.InTransaction then
      FWriteTransaction.Rollback;
    raise;
  end;
end;

function TgsMetadataEditor.ReplaceSubstituteUDFFunction(var AFunctionText: String): Boolean;
var
  FunctionCounter: Integer;
  OriginalFunction: String;
  SubstituteFunction: String;
  FunctionPosition: Integer;
  OriginalFunctionLength, SubstituteFunctionLength: Integer;
begin
  Result := False;
  if Assigned(FSubstituteFunctionList) then
  begin
    for FunctionCounter := 0 to FSubstituteFunctionList.Count - 1 do
    begin
      OriginalFunction := FSubstituteFunctionList.Names[FunctionCounter];
      SubstituteFunction := FSubstituteFunctionList.Values[OriginalFunction];
      OriginalFunctionLength := StrLength(OriginalFunction);
      SubstituteFunctionLength := StrLength(SubstituteFunction);
      // Поищем первое вхождение заменяемой функции в переданный текст
      FunctionPosition := StrFind(OriginalFunction, AFunctionText);
      // Укажем что заменяемая функция найдена, и переданный текст будет изменен
      if (FunctionPosition <> 0) and not Result then
        Result := True;
      // Пройдем по переданному тексту в поисках текущей заменяемой функции
      while FunctionPosition <> 0 do
      begin
        if IsSeparateWord(AFunctionText, FunctionPosition, OriginalFunctionLength) then
        begin
          // Удалим заменяемую функцию
          Delete(AFunctionText, FunctionPosition, OriginalFunctionLength);
          // Вставим заменяющую функцию
          Insert(SubstituteFunction, AFunctionText, FunctionPosition);
        end;
        // Поищем следующую заменяемой функцию
        FunctionPosition := StrFind(OriginalFunction, AFunctionText, FunctionPosition + SubstituteFunctionLength);
      end;
    end;
  end
  else
    raise Exception.Create('TgsMetadataEditor.ReplaceSubstituteUDFFunction'#13#10'  Substitution list not found.');
end;

class function TgsMetadataEditor.IsCommented(const ACharPosition: Integer;
  const AFunctionText: String): Boolean;

  function TestForSymbolContaining(const AFirst, ASecond: String): Boolean;
  var
    CurrentPosition: Integer;
  begin
    Result := False;
    // Поищем символ AFirst перед символом в ACharPosition
    CurrentPosition := StrFind(AFirst, AFunctionText);
    if (CurrentPosition > 0) and (CurrentPosition < ACharPosition) then
    begin
      while (CurrentPosition > 0) and (CurrentPosition < ACharPosition) do
      begin
        // Найдем символ ASecond
        CurrentPosition := StrFind(ASecond, AFunctionText, CurrentPosition);
        // Если следующий символ ASecond уже после ACharPosition, значит искомая позиция в комментарии
        if CurrentPosition > ACharPosition then
        begin
          Result := True;
          Exit;
        end
        else
          // Иначе, перед искомым символом не один комментарий, перейдем к следующему
          CurrentPosition := StrFind(AFirst, AFunctionText, CurrentPosition);
      end;
    end;
  end;

begin
  Result := TestForSymbolContaining('/*', '*/');
  if not Result then
    Result := TestForSymbolContaining('--', #13#10);
end;

class function TgsMetadataEditor.IsSeparateWord(const AFunctionText: String;
  const AWordPosition, AWordLength: Integer): Boolean;
begin
  if (AFunctionText[AWordPosition - 1] in SPACE_CHARS)
     and (AFunctionText[AWordPosition + AWordLength] in SPACE_CHARS) then
    Result := True
  else
    Result := False;
end;

end.
