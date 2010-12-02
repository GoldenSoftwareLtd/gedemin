unit gsFDBConvert_unit;

interface

uses
  IBDatabase, IBDatabaseInfo, IBSQL, classes, Windows, gsFDBConvertHelper_unit;

const
  COMPUTED_FIELD_DELIMITER = '.';

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
    FConnectedServerType: TgsServerVersion;
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
    procedure UnloadIBServer;
  public
    constructor Create;
    destructor Destroy; override;

    // ����������� � ���� ������ � ������� ����������� ���� �������
    procedure Connect;
    function TryConnect: Boolean;
    // ���������� �� ����
    procedure Disconnect;

    // ���������� ���� ���� ������ ��� �����������
    procedure CopyDatabaseFile(const ADatabaseOriginalPath, ADatabaseCopyPath: String);
    // ������������ ���� �� ������ � ������� ������������ �������
    procedure RestoreDatabase(const ABackupPath, ADatabasePath: String);
    // ���������� ���� � ������� ������������ �������
    procedure BackupDatabase(const ADatabasePath, ABackupPath: String);
    // �������� ����������� ���� ������ � ������� -full -mend
    procedure CheckDatabaseIntegrity(const ADatabasePath: String);

    // �������� ���������� ����������� ��� �������� ��� �������������� ��������� � ��������
    procedure CreateConvertHelpMetadata;
    // �������� ��������������� ����������
    procedure DestroyConvertHelpMetadata;

    // ��������� ����������� ������� �� ����������� ����
    function CheckServerAvailability(const AServerVersion: TgsServerVersion): Boolean;
    // �������� ������ ���� ������
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
    FDeleteFunctionList: TStringList;

    FIBSQLRead: TIBSQL;
    FIBSQLWrite: TIBSQL;

    // ������ - ���� ������ �� ������� CharPosition ��������� � �����������, ����� ����
    class function IsCommented(const ACharPosition: Integer; const AFunctionText: String): Boolean;
    // ������ - ���� ���������� ����� �� ������ � ������ ������� �����, � �������� ��������� SPACE_CHARS
    class function IsSeparateWord(const AFunctionText: String; const AWordPosition, AWordLength: Integer): Boolean;

    // �������� ����� ���������� ���������
    function GetProcedureParamText(const AProcedureName: String): String;
    // �������� ����� ���������� �������������
    function GetViewParamText(const AViewName: String): String;
    // �������� ������ �� ������������� ��� ����������� ����
    function GetMetadataGrants(const AMetadataName: String; const AFieldName: String = ''): String;
    // �������� ������� ����������� ���� � �������
    function GetComputedFieldPosition(const ARelationName, AComputedFieldName: String): Integer;
    // ���������� �� UDF-�������
    function UDFFunctionExists(const AFunctinoName: String): Boolean;
  public
    constructor Create(ADatabase: TIBDatabase);
    destructor Destroy; override;

    // �������� ������ �������� ��������
    procedure GetProcedureList(AProcedureList: TStrings);
    // �������� ������ ���������
    procedure GetTriggerList(ATriggerList: TStrings);
    // �������� ������ ������������� � ���������� ����� � ������� �����������
    procedure GetViewAndComputedFieldList(AMetadataList: TStrings);
    // �������� ������ ������������� � ����������� ����� �� ��������������� �������,
    //  ���� ��� ���� �������� ����� ���������������� ��
    procedure GetBackupViewAndComputedFieldList(AMetadataList: TStrings);
    // �������� ������ ������������ UDF-�������
    procedure GetUDFFunctionList(AFunctionList: TStrings);

    // �������� ������� �� UDF �����������
    function ReplaceSubstituteUDFFunction(var AFunctionText: String): Boolean;
    // ������� �������� ������ UDF-�������
    procedure DeleteUDFFunctions;
    // ������������ ���� ���������\��������
    //  DoInsertSuspendClause - ��������� �� SUSPEND �������� (������ ��� �������� ��������)
    class function CommentFunctionBody(var AFunctionText: String; const DoInsertSuspendClause: Boolean = False): Boolean;
    // ������� ������������� ���� �����������
    class function UncommentFunctionBody(var AFunctionText: String): Boolean;
    // ����������� ������ ������������� � ��������������� �������
    procedure BackupView(const AViewName: String);
    // ����������� ������ ������������ ���� � ��������������� �������
    procedure BackupComputedField(const ARelationName, AComputedFieldName: String);

    // ������� �������������
    procedure DeleteView(const AViewName: String);
    // ������� ����������� ����
    procedure DeleteComputedField(const ARelationName, AComputedFieldName: String);

    // �������� ����� ���������
    function GetProcedureText(const AProcedureName: String): String;
    // �������� ����� ��������
    function GetTriggerText(const ATriggerName: String): String;
    // �������� ����� �������������
    function GetViewText(const AViewName: String): String;
    // �������� ����� ������������ ����
    function GetComputedFieldText(const ARelationName, AComputedFieldName: String): String;

    // �������� ����� ������������� �� ��������������� �������
    function GetBackupViewText(const AViewName: String): String;
    // �������� ����� ������������ ���� �� ��������������� �������
    function GetBackupComputedFieldText(const ARelationName, AComputedFieldName: String): String;

    procedure RestoreGrant(const AMetadataName: String; const ARelationName: String = '');
    procedure RestorePosition(const ARelationName, AMetadataName: String);

    // �������� ����� ���������
    procedure SetProcedureText(const AProcedureName, AProcedureText: String; const AParams: String = '_'); overload;
    procedure SetProcedureText(const AProcedureText: String); overload;
    // �������� ����� ��������
    procedure SetTriggerText(const ATriggerName, ATriggerText: String); overload;
    procedure SetTriggerText(const ATriggerText: String); overload;
    // �������� ����� �������������
    procedure SetViewText(const AViewName, AViewText: String); overload;
    procedure SetViewText(const AViewText: String); overload;
    // �������� ����� ������������ ����
    procedure SetComputedFieldText(const ARelationName, AComputedFieldName, AComputedFieldText: String); overload;
    procedure SetComputedFieldText(const AComputedFieldText: String); overload;

    class function GetFirstNLines(const AText: String; const ALineCount: Integer): String;

    property SubstituteFunctionList: TStringList read FSubstituteFunctionList write FSubstituteFunctionList;
    property DeleteFunctionList: TStringList read FDeleteFunctionList write FDeleteFunctionList;
  end;

implementation

uses
  SysUtils, IB, IBIntf, IBServices, IBHeader, IBErrorCodes,
  gsSysUtils, JclStrings, gsFDBConvertLocalization_unit, forms;

const
  HELP_VIEW_TYPE = 'V';
  HELP_COMPUTED_FIELD_TYPE = 'F';

  HELP_METADATA_TABLE = 'CNV$DATA';
  HELP_M_ID = 'cnv$id';
  HELP_M_OBJTYPE = 'cnv$obj_type';
  HELP_M_NAME = 'cnv$name';
  HELP_M_RELATIONNAME = 'cnv$relation_name';
  HELP_M_SOURCE = 'cnv$source';
  HELP_M_GRANTTEXT = 'cnv$grant_text';
  HELP_M_POSITION = 'cnv$obj_position';
  HELP_METADATA_TABLE_CODE =
    'CREATE TABLE ' + HELP_METADATA_TABLE + ' ( ' +
     HELP_M_ID +           '  INTEGER NOT NULL PRIMARY KEY, ' +
     HELP_M_OBJTYPE +      '  CHAR(1) NOT NULL, ' +
     HELP_M_NAME +         '  VARCHAR(60) CHARACTER SET UNICODE_FSS NOT NULL, ' +
     HELP_M_RELATIONNAME + '  VARCHAR(60) CHARACTER SET UNICODE_FSS, ' +
     HELP_M_SOURCE +       '  BLOB SUB_TYPE 1 CHARACTER SET UNICODE_FSS, ' +
     HELP_M_GRANTTEXT +    '  VARCHAR(2048) CHARACTER SET UNICODE_FSS, ' +
     HELP_M_POSITION +     '  INTEGER, ' +
    '  CHECK(' + HELP_M_OBJTYPE + ' IN (''' + HELP_VIEW_TYPE + ''', ''' + HELP_COMPUTED_FIELD_TYPE + ''')) ' +
    ') ';
  HELP_METADATA_GENERATOR = 'CNV$G_ID';
  HELP_METADATA_GENERATOR_CODE = 'CREATE GENERATOR ' + HELP_METADATA_GENERATOR;
  HELP_METADATA_TRIGGER = 'CNV$BI_DATA';
  HELP_METADATA_TRIGGER_CODE =
    'CREATE TRIGGER ' + HELP_METADATA_TRIGGER + ' FOR ' + HELP_METADATA_TABLE + ' ' +
    '  BEFORE INSERT ' +
    '  POSITION 0 ' +
    'AS BEGIN ' +
    '  NEW.' + HELP_M_ID + ' = GEN_ID(' + HELP_METADATA_GENERATOR + ', 1); ' +
    'END ';

  SPACE_CHARS: set of char = [' ', #0, #10, #13, '/', '(', ')', '+', '-', '=', '*', '/', '<', '>', '!', '~', '^'];
  WITH_GRANT_OPTION_MARKER = '/WGO/';

var
  SetDllDirectory: function(lpPathName: PChar): Boolean; stdcall;

{ TgsFDBConvert }

constructor TgsFDBConvert.Create;
begin
  // ������ ������� SetDllDirectoryW
  SetDllDirectory := GetProcAddress(GetModuleHandle('kernel32.dll'), 'SetDllDirectoryA');

  // �������� ������ � ������� ����� �������������� ��
  LoadIBServer(CONVERT_SERVER_VERSION);
  // �������� ������� ���� ������, � ���������� � �� � ������ ��
  FDatabase := TIBDatabase.Create(nil);
  FDatabaseInfo := TIBDatabaseInfo.Create(nil);
  FDatabaseInfo.Database := FDatabase;
  // �������� ����������
  FReadTransaction := TIBTransaction.Create(nil);
  FReadTransaction.DefaultDatabase := FDatabase;
  FReadTransaction.Params.Text := 'read_committed'#13#10'rec_version'#13#10'nowait'#13#10'read'#13#10;
  FReadTransaction.AutoStopAction := saNone;
  // ��������� �������� ����������, ��� ���������� �� ��������� ��� ��
  FDatabase.DefaultTransaction := FReadTransaction;
  // ���������� �� ������ �� ���������
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
  // ������������ �������� 
  if Assigned(FServiceProgressRoutine) then
    FServiceProgressRoutine(Format('%s: %s (%s >> %s)',
      [TimeToStr(Time), GetLocalizedString(lsDatabaseFileCopyingProcess), ADatabaseOriginalPath, ADatabaseCopyPath]));

  // ������� ������ ������������� �����
  FileSize := TgsFileSystemHelper.GetFileSize(ADatabaseOriginalPath);
  // ������������ ����
  FromFile := TFileStream.Create(ADatabaseOriginalPath, fmOpenRead or fmShareDenyNone);
  try
    // �������� ��� ����������� ������� ����
    if FileExists(ADatabaseCopyPath) then
      ToFile := TFileStream.Create(ADatabaseCopyPath, fmOpenReadWrite or fmShareDenyWrite)
    else
      ToFile := TFileStream.Create(ADatabaseCopyPath, fmCreate);
    try
      CopiedSize := 0;
      ToFile.Size := FileSize;
      ToFile.Position := 0;
      FromFile.Position := 0;

      // ������������ ��������
      if Assigned(FCopyProgressRoutine) then
        FCopyProgressRoutine(FileSize, CopiedSize);
      // ������� ������ ������
      NumRead := FromFile.Read(Buffer[0], BUFFER_SIZE);
      while NumRead > 0 do
      begin
        CopiedSize := CopiedSize + NumRead;
        // ������������ ��������
        if Assigned(FCopyProgressRoutine) then
          FCopyProgressRoutine(FileSize, CopiedSize);
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

procedure TgsFDBConvert.BackupDatabase(const ADatabasePath, ABackupPath: String);
var
  BackupService: TIBBackupService;
  ProcessLogList: TStringList;
  NextLogLine: String;
begin
  // �������� ���������� ������
  LoadIBServer(Self.ServerType);

  BackupService := TIBBackupService.Create(nil);
  ProcessLogList := TStringList.Create;
  try
    BackupService.Protocol := Local;
    BackupService.LoginPrompt := False;
    // ��������� �����������
    BackupService.Params.Clear;
    BackupService.Params.Add('user_name=' + DefaultIBUserName);

    BackupService.Active := True;

    // ���� � ���� � ������� ����� �������� �����
    BackupService.DatabaseName := ADatabasePath;
    // ���� � ������
    BackupService.BackupFile.Add(ABackupPath);
    BackupService.Options := [IgnoreChecksums, IgnoreLimbo, NoGarbageCollection];

    try
      if Assigned(FServiceProgressRoutine) then
        FServiceProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsDatabaseBackupProcess)]));

      BackupService.ServiceStart;
      while (not BackupService.Eof)
        and (BackupService.IsServiceRunning) do
      begin          
        // ����� ���������� �� ��������� ��� ��, ������������ ��������
        NextLogLine := BackupService.GetNextLine;
        if NextLogLine <> '' then
          ProcessLogList.Add(NextLogLine + #13#10);
      end;

    except
      on E: Exception do
      begin
        BackupService.Active := False;

        raise Exception.Create(Format('%s%s%s',
          [GetLocalizedString(lsDatabaseBackupProcessError), #13#10, E.Message]));
      end;
    end;

    // ���� � ���� ���-�� ����, �� ������� ������������, ���������� �� ������� �����������
    if ProcessLogList.Count > 0 then
    begin
      if Application.MessageBox(
           PChar(GetLocalizedString(lsDatabaseBackupProcessError) + #13#10 +
             TgsMetadataEditor.GetFirstNLines(ProcessLogList.Text, 25) + #13#10 +
             GetLocalizedString(lsContinueConvertingQuestion)),
           PChar(GetLocalizedString(lsInformationDialogCaption)),
           MB_YESNO or MB_ICONEXCLAMATION or MB_APPLMODAL) <> IDYES then
      begin
        raise EgsInterruptConvertProcess.Create(Format('%s%s%s',
          [GetLocalizedString(lsDatabaseBackupProcessError), #13#10, ProcessLogList.Text]));
      end
      else
      begin
        if Assigned(FServiceProgressRoutine) then
          FServiceProgressRoutine(Format('%s: %s%s%s',
            [TimeToStr(Time), GetLocalizedString(lsDatabaseBackupProcessError), #13#10, ProcessLogList.Text]));
      end;
    end;

  finally
    FreeAndNil(ProcessLogList);
    BackupService.Active := False;
    FreeAndNil(BackupService);
    // �������� ���������� ������
    UnloadIBServer;
  end;
end;

procedure TgsFDBConvert.RestoreDatabase(const ABackupPath, ADatabasePath: String);
var
  RestoreService: TIBRestoreService;
  ProcessLogList: TStringList;
  NextLogLine: String;
begin
  // �������� ���������� ������
  LoadIBServer(Self.ServerType);

  RestoreService := TIBRestoreService.Create(nil);
  ProcessLogList := TStringList.Create;
  try
    RestoreService.Protocol := Local;
    RestoreService.LoginPrompt := False;
    // ��������� �����������
    RestoreService.Params.Clear;
    RestoreService.Params.Add('user_name=' + DefaultIBUserName);

    RestoreService.Active := True;  

    // ���� � ������
    RestoreService.BackupFile.Add(ABackupPath);
    // ���� � ���� � ������� ����� ����������������� �����
    RestoreService.DatabaseName.Add(ADatabasePath);

    RestoreService.Options := [Replace];

    // ���� ��������������� ��� Firebird 2.5 (��� 3.0), �� ������� ����� ��������������� ���������� � unicode
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
        // ����� ���������� �� ��������� ��� ��, ������������ ��������
        NextLogLine := RestoreService.GetNextLine;
        if NextLogLine <> '' then
          ProcessLogList.Add(NextLogLine + #13#10);
      end;
    except
      on E: Exception do
      begin
        RestoreService.Active := False;

        raise Exception.Create(Format('%s%s%s',
          [GetLocalizedString(lsDatabaseRestoreProcessError), #13#10, E.Message]));
      end;
    end;

    // ���� � ���� ���-�� ����, �� ������� ������������, ���������� �� ������� �����������
    if ProcessLogList.Count > 0 then
    begin
      if Application.MessageBox(
           PChar(GetLocalizedString(lsDatabaseRestoreProcessError) + #13#10 +
             TgsMetadataEditor.GetFirstNLines(ProcessLogList.Text, 25) + #13#10 +
             GetLocalizedString(lsContinueConvertingQuestion)),
           PChar(GetLocalizedString(lsInformationDialogCaption)),
           MB_YESNO or MB_ICONEXCLAMATION or MB_APPLMODAL) <> IDYES then
      begin
        raise EgsInterruptConvertProcess.Create(Format('%s%s%s',
          [GetLocalizedString(lsDatabaseRestoreProcessError), #13#10, ProcessLogList.Text]));
      end
      else
      begin
        if Assigned(FServiceProgressRoutine) then
          FServiceProgressRoutine(Format('%s: %s%s%s',
            [TimeToStr(Time), GetLocalizedString(lsDatabaseRestoreProcessError), #13#10, ProcessLogList.Text]));
      end;    
    end;

  finally
    RestoreService.Active := False;
    FreeAndNil(ProcessLogList);
    FreeAndNil(RestoreService);
    // �������� ���������� ������
    UnloadIBServer;
  end;
end;

procedure TgsFDBConvert.CheckDatabaseIntegrity(const ADatabasePath: String);
var
  ValidationService: TIBValidationService;
  ProcessLogList: TStringList;
  NextLogLine: String;
  ibsqlCheck, ibsqlSelect: TIBSQL;
  WasAskedAboutNullError: Boolean;
begin
  // �������� ���������� ������
  LoadIBServer(Self.ServerType);

  ValidationService := TIBValidationService.Create(nil);
  ProcessLogList := TStringList.Create;
  try
    ValidationService.Protocol := Local;
    ValidationService.LoginPrompt := False;
    ValidationService.Params.Clear;
    ValidationService.Params.Add('user_name=' + DefaultIBUserName);

    ValidationService.Active := True;

    ValidationService.DatabaseName := ADatabasePath;
    ValidationService.Options := [MendDB, IgnoreChecksum];

    try
      if Assigned(FServiceProgressRoutine) then
        FServiceProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsDatabaseValidationProcess)]));

      ValidationService.ServiceStart;
      while (not ValidationService.Eof)
        and (ValidationService.IsServiceRunning) do
      begin
        // ����� ���������� �� ��������� ��� ��, ������������ ��������
        NextLogLine := ValidationService.GetNextLine;
        if NextLogLine <> '' then
          ProcessLogList.Add(NextLogLine + #13#10);
      end;
    except
      on E: Exception do
      begin
        ValidationService.Active := False;

        raise EgsInterruptConvertProcess.Create(Format('%s%s%s',
          [GetLocalizedString(lsDatabaseValidationProcessError), #13#10, E.Message]));
      end;
    end;
  finally
    ValidationService.Active := False;
    FreeAndNil(ProcessLogList);
    FreeAndNil(ValidationService);
    // �������� ���������� ������
    UnloadIBServer;
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
        WasAskedAboutNullError := False;

        ibsqlSelect.SQL.Text :=
          ' SELECT ' +
          '   r.rdb$relation_name rn, r.rdb$field_name rf ' +
          ' FROM ' +
          '   rdb$relation_fields r ' +
          '   JOIN rdb$fields f ON r.rdb$field_source = f.rdb$field_name ' +
          ' WHERE ' +
          '   ((r.rdb$null_flag = 1) OR (f.rdb$null_flag = 1)) AND (r.rdb$view_context IS NULL) ';
        ibsqlSelect.ExecQuery;

        while not ibsqlSelect.EOF do
        begin
          ibsqlCheck.Close;
          ibsqlCheck.SQL.Text := Format('SELECT * FROM %s WHERE %s IS NULL',
            [ibsqlSelect.Fields[0].AsTrimString, ibsqlSelect.Fields[1].AsTrimString]);
          ibsqlCheck.ExecQuery;

          if not ibsqlCheck.EOF then
          begin
            // ������������ ��������
            if Assigned(FServiceProgressRoutine) then
              FServiceProgressRoutine(Format(GetLocalizedString(lsDatabaseNULLCheckMessage),
                [ibsqlSelect.Fields[1].AsTrimString, ibsqlSelect.Fields[0].AsTrimString]));

            // ���� ��� �� ����������, ������� � ������������ � ������������� ���������� �����������
            if not WasAskedAboutNullError then
            begin
              WasAskedAboutNullError := True;
              
              if Application.MessageBox(
                 PChar(Format(GetLocalizedString(lsDatabaseNULLCheckMessage),
                   [ibsqlSelect.Fields[1].AsTrimString, ibsqlSelect.Fields[0].AsTrimString]) + #13#10 +
                   GetLocalizedString(lsContinueCheckingQuestion)),
                 PChar(GetLocalizedString(lsInformationDialogCaption)),
                 MB_YESNO or MB_ICONEXCLAMATION or MB_APPLMODAL) <> IDYES then
                raise EgsInterruptConvertProcess.Create(GetLocalizedString(lsDatabaseNULLCheckProcessError));
            end;
          end;

          ibsqlSelect.Next;
        end;

        // ���� ���������� � ������������ �� ������, ������ ��������� �������, ���� ������� ������ NOT NULL ����
        if WasAskedAboutNullError then
          raise EgsInterruptConvertProcess.Create(GetLocalizedString(lsDatabaseNULLCheckProcessError));

      except
        on E: EgsInterruptConvertProcess do
          raise;

        on E: Exception do 
          raise Exception.Create(Format('%s%s%s',
          [GetLocalizedString(lsDatabaseNULLCheckProcessError), #13#10'  ', E.Message]));
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
  // ������� ���������� ���� � ����� ������������ ����������� �������
  ServerPath := TgsFileSystemHelper.GetPathToServer(AServerVersion);
  if ServerPath <> '' then
    Result := True;
end;

procedure TgsFDBConvert.LoadIBServer(const AServerVersion: TgsServerVersion);
begin
  // ���� �������� �� ��������� ������, �� �������� �������
  if FConnectedServerType <> AServerVersion then
  begin
    UnloadIBServer;

    if AServerVersion <> svUnknown then
    begin
      FConnectedServerType := AServerVersion;
      // ������� � ���c�� ������ DLL ���������� �������
      SetDllDirectory(PChar(TgsFileSystemHelper.GetPathToServerDirectory(AServerVersion)));
      TgsFileSystemHelper.ChangeFirebirdRootDirectory(TgsFileSystemHelper.GetPathToServerDirectory(AServerVersion));
      // ��������� ����� ���� � �������
      SetIBLibraryName(TgsFileSystemHelper.GetPathToServer(AServerVersion));
      // �������� ������
      LoadIBLibrary;
    end
    else
      raise Exception.Create('TgsFDBConvert.LoadIBServer: ' + GetLocalizedString(lsUnknownServerType));
  end;
end;

procedure TgsFDBConvert.UnloadIBServer;
begin
  // ���� ������ ��������
  if FConnectedServerType <> svUnknown then
  begin
    FConnectedServerType := svUnknown;
    // �������� ���������� ������� ��
    FreeIBLibrary;
    // ������ ������������� ���������� ��� ������ DLL �������
    SetDllDirectory('');
  end;
end;

procedure TgsFDBConvert.Connect;
begin
  // �������� ���������� ������
  LoadIBServer(FServerType);
  // ����������� � ��
  FDatabase.DatabaseName := FDatabaseName;
  FDatabase.Params.Clear;
  FDatabase.Params.Add('user_name=' + DefaultIBUserName);
  if FConnectionInformation.CharacterSet <> '' then
    FDatabase.Params.Add('lc_ctype=' + FConnectionInformation.CharacterSet);
  FDatabase.LoginPrompt := False;
  // ��������� 3-�� �������
  FDatabase.SQLDialect := 3;
  try
    FDatabase.Open;
  except
    on E: EIBInterBaseError do
    begin
      if E.IBErrorCode = isc_bad_db_format then
        raise Exception.Create(GetLocalizedString(lsUnknownDatabaseType))
      else
        raise;  
    end
    else
      raise;
  end;
  // �������� �������� ����������
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
    // �������� ���������� ������
    UnloadIBServer;
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
    // ������� �������� ODS �� ��
    ODSMajorVersion := FDatabaseInfo.ODSMajorVersion;
    ODSMinorVersion := FDatabaseInfo.ODSMinorVersion;
    // ��������� ������ �� �� ��������� ���������� ��������
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
        // �������� ��������������� �������
        ibsqlMetadata.SQL.Text := HELP_METADATA_TABLE_CODE;
        ibsqlMetadata.ExecQuery;
        // ��������� ��� ��������������� �������
        ibsqlMetadata.SQL.Text := HELP_METADATA_GENERATOR_CODE;
        ibsqlMetadata.ExecQuery;
        // ������� ��� ��������������� �������
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
      // �������� �������� ��� ��������������� �������
      ibsqlMetadata.SQL.Text :=
        'DROP TRIGGER ' + HELP_METADATA_TRIGGER;
      ibsqlMetadata.ExecQuery;
      // �������� ���������� ��� ��������������� �������
      ibsqlMetadata.SQL.Text :=
        'DROP GENERATOR ' + HELP_METADATA_GENERATOR;
      ibsqlMetadata.ExecQuery;
      // �������� ��������������� �������
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

    // �������� �������� ��� ��������������� �������
    ibsqlMetadata.SQL.Text :=
      'SELECT rdb$relation_name FROM rdb$relations WHERE UPPER(rdb$relation_name) = UPPER(:rel_name) ';
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
    FIBSQLWrite.ParamCheck := False;

    FSubstituteFunctionList := TStringList.Create;
    FDeleteFunctionList := TStringList.Create;
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
  if Assigned(FDeleteFunctionList) then
    FreeAndNil(FDeleteFunctionList);
end;

procedure TgsMetadataEditor.GetProcedureList(AProcedureList: TStrings);
begin
  FIBSQLRead.SQL.Text :=
    'SELECT rdb$procedure_name AS procedure_name FROM rdb$procedures ';
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
    '   AND NOT UPPER(rdb$trigger_name) = UPPER(:help_trigger_name) ';
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
      Result := Trim(ARelationName) + COMPUTED_FIELD_DELIMITER + Trim(AFieldName);
  end;

  procedure GetMetadataDependency(const ARelationName: String; const AFieldName: String = '');
  var
    ibsqlDependency: TIBSQL;
    DepMetadataName: String;
  begin
    ibsqlDependency := TIBSQL.Create(nil);
    try
      ibsqlDependency.Transaction := FDatabase.DefaultTransaction;
      // ������ �� ����� ������������� � ����������� ����� ��������� �� ����������� �������
      if AFieldName = '' then
      begin
        // �������� �������������
        ibsqlDependency.SQL.Text :=
          'SELECT DISTINCT ' +
          '  d1.rdb$dependent_name AS rel_name, CAST(NULL AS CHAR(31)) AS field_name ' +
          'FROM ' +
          '  rdb$dependencies d1 ' +
          '  LEFT JOIN rdb$relations r1 ON d1.rdb$dependent_name = r1.rdb$relation_name AND NOT r1.rdb$view_blr IS NULL ' +
          'WHERE ' +
          '  d1.rdb$dependent_type = 1 ' +
          '  AND UPPER(d1.rdb$depended_on_name) = UPPER(:metadata_name) ' +
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
          '  AND UPPER(d2.rdb$depended_on_name) = UPPER(:metadata_name) ' +
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
          '  AND UPPER(d2.rdb$depended_on_name) = UPPER(:metadata_name) ' +
          '  AND NOT f.rdb$computed_source IS NULL ' +
          '  AND r.rdb$view_source IS NULL ' +
          ' ' +
          'ORDER BY ' +
          '  1, 2 ';
        ibsqlDependency.ParamByName('METADATA_NAME').AsString := ARelationName;
      end
      else
      begin
        // �������� ����������� ����
        ibsqlDependency.SQL.Text :=
          'SELECT DISTINCT ' +
          '  d1.rdb$dependent_name AS rel_name, CAST(NULL AS CHAR(31)) AS field_name ' +
          'FROM ' +
          '  rdb$dependencies d1 ' +
          '  LEFT JOIN rdb$relations r1 ON d1.rdb$dependent_name = r1.rdb$relation_name AND NOT r1.rdb$view_blr IS NULL ' +
          'WHERE ' +
          '  d1.rdb$dependent_type = 1 ' +
          '  AND UPPER(d1.rdb$field_name) = UPPER(:metadata_name) ' +
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
          '  AND UPPER(d2.rdb$field_name) = UPPER(:metadata_name) ' +
          '  AND NOT f.rdb$computed_source IS NULL ' +
          '  AND r.rdb$view_source IS NULL ' +
          ' ' +
          'ORDER BY ' +
          '  1, 2 ';
        ibsqlDependency.ParamByName('METADATA_NAME').AsString := AFieldName;
      end;
      ibsqlDependency.ExecQuery;
      // ������� �� ������ ��������� ��������
      while not ibsqlDependency.Eof do
      begin
        // ���������� ��� ������� �������
        DepMetadataName := FormMetadataString(ibsqlDependency.FieldByName('REL_NAME').AsString,
          ibsqlDependency.FieldByName('FIELD_NAME').AsString);
        // ���� ������ ��� �� � ������ ��� ��������, �� ������� ���
        if AMetadataList.IndexOf(DepMetadataName) = -1 then
        begin
          // �������� �� ������������ ��� ������ ��������� ��������
          if CircularReferenceList.IndexOf(DepMetadataName) = -1 then
          begin
            // ������� � ������ ��� �������� �� ������������
            CircularReferenceList.Add(DepMetadataName);
            // ������ ��������� �������
            GetMetadataDependency(Trim(ibsqlDependency.FieldByName('REL_NAME').AsString),
              Trim(ibsqlDependency.FieldByName('FIELD_NAME').AsString));
            // ������ �� ������ ��� �������� �� ������������
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
  // ������� ������ ������������� � ����������� ����� �������
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
      // ���������� ��� ������� �������
      MetadataName := FormMetadataString(FIBSQLRead.FieldByName('REL_NAME').AsString,
        FIBSQLRead.FieldByName('FIELD_NAME').AsString);
      if AMetadataList.IndexOf(MetadataName) = -1 then
      begin
        // ������� � ������ ��� �������� �� ������������
        CircularReferenceList.Add(MetadataName);
        // ������ ��������� �������
        GetMetadataDependency(Trim(FIBSQLRead.FieldByName('REL_NAME').AsString),
          Trim(FIBSQLRead.FieldByName('FIELD_NAME').AsString));
        // ������� ������ ��� �������� �� ������������
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
  FIBSQLRead.SQL.Text := Format(
    'SELECT DISTINCT ' +
    '  t.%0:s, t.%1:s, t.%2:s ' +
    'FROM ' +
    '  %3:s t ' +
    'ORDER BY ' +
    '  t.%4:s DESC ',
    [HELP_M_OBJTYPE, HELP_M_NAME, HELP_M_RELATIONNAME, HELP_METADATA_TABLE, HELP_M_ID]);
  FIBSQLRead.ExecQuery;

  while not FIBSQLRead.Eof do
  begin
    // � ����������� �� ���� ���������� ����� ���������� ���, ��� ��� + ���_�������
    if FIBSQLRead.FieldByName(HELP_M_OBJTYPE).AsString = HELP_VIEW_TYPE then
      AMetadataList.Add(Trim(FIBSQLRead.FieldByName(HELP_M_NAME).AsString))
    else if FIBSQLRead.FieldByName(HELP_M_OBJTYPE).AsString = HELP_COMPUTED_FIELD_TYPE then
      AMetadataList.Add(Trim(FIBSQLRead.FieldByName(HELP_M_RELATIONNAME).AsString) + COMPUTED_FIELD_DELIMITER +
        Trim(FIBSQLRead.FieldByName(HELP_M_NAME).AsString));

    FIBSQLRead.Next;
  end;
  FIBSQLRead.Close;
end;

function TgsMetadataEditor.GetProcedureText(const AProcedureName: String): String;
begin
  Result := '';

  FIBSQLRead.SQL.Text :=
    ' SELECT rdb$procedure_source AS FuncSource ' +
    ' FROM rdb$procedures ' +
    ' WHERE UPPER(rdb$procedure_name) = UPPER(:procedure_name) ';
  FIBSQLRead.ParamByName('PROCEDURE_NAME').AsString := AProcedureName;

  try
    FIBSQLRead.ExecQuery;

    if FIBSQLRead.RecordCount > 0 then
    begin
      Result := Format('ALTER PROCEDURE %s %s AS'#13#10'%s',
        [Trim(AProcedureName), GetProcedureParamText(AProcedureName), Trim(FIBSQLRead.FieldByName('FUNCSOURCE').AsString)])
    end
    else
      raise Exception.Create('TgsMetadataEditor.GetProcedureText'#13#10 +
        '  Stored procedure "' + AProcedureName + '" not found');
  finally
    FIBSQLRead.Close;
  end;
end;

function TgsMetadataEditor.GetProcedureParamText(const AProcedureName: String): String;
var
  ibsqlParams, ibsqlDomain: TIBSQL;
  S1, S2: String;

  function FormFloatDomain(dsDomain: TIBSQL): String;
  var
    fscale: Integer;
  begin
    if dsDomain.FieldByName('fsubtype').AsInteger = 1 then
      Result := 'NUMERIC'
    else
      Result := 'DECIMAL';

    if dsDomain.FieldByName('fscale').AsInteger < 0 then
      fscale := -dsDomain.FieldByName('fscale').AsInteger
    else
      fscale := dsDomain.FieldByName('fscale').AsInteger;

    if dsDomain.FieldByName('fprecision').AsInteger = 0 then
      Result := Format('%s(9, %s)',
        [Result, IntToStr(fscale)])
    else
      Result := Format('%s(%s, %s)',
        [Result, dsDomain.FieldByName('fprecision').AsString, IntToStr(fscale)]);
  end;

  function GetDomain(dsDomain: TIBSQL): String;
  begin

    case dsDomain.FieldByName('ffieldtype').AsInteger of
    blr_Text, blr_varying:
      begin
        if dsDomain.FieldByName('ffieldtype').AsInteger = blr_Text then
          Result := 'CHAR'
        else
          Result := 'VARCHAR';

        Result := Format('%s(%s)', [Result, dsDomain.FieldByName('fcharlength').AsString]);
      end;

    blr_d_float, blr_double, blr_float:
      Result := 'DOUBLE PRECISION';

    blr_int64:
      if (dsDomain.FieldByName('fsubtype').AsInteger > 0) or
        (dsDomain.FieldByName('fprecision').AsInteger > 0) or
        (dsDomain.FieldByName('fscale').AsInteger < 0) then
      begin
        Result := FormFloatDomain(dsDomain)
      end else
        Result := 'BIGINT';

    blr_long:
      if (dsDomain.FieldByName('fsubtype').AsInteger > 0) or
        (dsDomain.FieldByName('fprecision').AsInteger > 0) or
        (dsDomain.FieldByName('fscale').AsInteger < 0) then
      begin
        Result := FormFloatDomain(dsDomain)
      end else
        Result := 'INTEGER';

    blr_short:
      if (dsDomain.FieldByName('fsubtype').AsInteger > 0) or
        (dsDomain.FieldByName('fprecision').AsInteger > 0) or
        (dsDomain.FieldByName('fscale').AsInteger < 0) then
      begin
        Result := FormFloatDomain(dsDomain)
      end else
        Result := 'SMALLINT';

    blr_sql_time:
      Result := 'TIME';

    blr_sql_date:
      Result := 'DATE';

    blr_timestamp:
      Result := 'TIMESTAMP';

    blr_blob:
      begin
        Result := 'BLOB';
        Result := Format
        (
          ' %s SUB_TYPE %s SEGMENT SIZE %s',
          [
            Result,
            dsDomain.FieldByName('fsubtype').AsString,
            dsDomain.FieldByName('seglength').AsString
          ]
        );
      end;
    end;
    Result := Trim(Result);
  end;

  function GetDomainText(const FieldName: String): String;
  begin
    ibsqlDomain.SQL.Text :=
      'SELECT ' +
      '  rdb.rdb$null_flag AS flag, ' +
      '  rdb.rdb$field_type as ffieldtype, ' +
      '  rdb.rdb$field_sub_type as fsubtype, ' +
      '  rdb.rdb$field_precision as fprecision, ' +
      '  rdb.rdb$field_scale as fscale, ' +
      '  rdb.rdb$field_length as flength, ' +
      '  rdb.rdb$character_length as fcharlength, ' +
      '  rdb.rdb$segment_length as seglength, ' +
      '  rdb.rdb$validation_source AS checksource, ' +
      '  rdb.rdb$default_source as defsource, ' +
      '  rdb.rdb$computed_source as computed_value, ' +
      '  cs.rdb$character_set_name AS charset, ' +
      '  cl.rdb$collation_name AS collation ' +
      ' FROM ' +
      '   rdb$fields rdb ' +
      '   LEFT JOIN rdb$character_sets cs ON rdb.rdb$character_set_id = cs.rdb$character_set_id ' +
      '   LEFT JOIN rdb$collations cl ON rdb.rdb$collation_id = cl.rdb$collation_id ' +
      '     AND rdb.rdb$character_set_id = cl.rdb$character_set_id ' +
      ' WHERE ' +
      '   rdb.rdb$field_name = :fieldname ';
    ibsqlDomain.ParamByName('fieldname').AsString := FieldName;
    try
      ibsqlDomain.ExecQuery;
      if ibsqlDomain.RecordCount > 0 then
        Result := GetDomain(ibsqlDomain)
      else
        raise Exception.Create('Undefined domain type');
    finally
      ibsqlDomain.Close;
    end;
  end;

begin
  Result := '';
  ibsqlParams := TIBSQL.Create(nil);
  ibsqlDomain := TIBSQL.Create(nil);
  try
    ibsqlDomain.Transaction := FDatabase.DefaultTransaction;

    ibsqlParams.Transaction := FDatabase.DefaultTransaction;
    ibsqlParams.SQL.Text :=
      ' SELECT ' +
      '   rdb$parameter_name, rdb$field_source ' +
      ' FROM ' +
      '   rdb$procedure_parameters pr ' +
      ' WHERE ' +
      '   pr.rdb$procedure_name = :pn ' +
      '   AND pr.rdb$parameter_type = :pt ' +
      ' ORDER BY ' +
      '   pr.rdb$parameter_number ASC ';
    ibsqlParams.ParamByName('pn').AsString := AProcedureName;
    ibsqlParams.ParamByName('pt').AsInteger := 0;
    ibsqlParams.ExecQuery;

    S1 := '';
    while not ibsqlParams.EOF do
    begin
      if S1 = '' then
        S1 := '('#13#10;
      S1 := S1 + '    ' + Trim(ibsqlParams.FieldByName('rdb$parameter_name').AsString) + ' ' +
         GetDomainText(ibsqlParams.FieldByName('rdb$field_source').AsString);
      ibsqlParams.Next;
      if not ibsqlParams.EOF then
        S1 := S1 + ','#13#10
      else
        S1 := S1 + ')';
    end;

    S1 := S1 + #13#10;

    ibsqlParams.Close;
    ibsqlParams.ParamByName('pt').AsInteger := 1;

    ibsqlParams.ExecQuery;
    S2 := '';
    while not ibsqlParams.EOF do
    begin
      if S2 = '' then
        S2 := 'RETURNS ( '#13#10;
      S2 := S2 + '    ' + Trim(ibsqlParams.FieldByName('rdb$parameter_name').AsString) + ' ' +
        GetDomainText(ibsqlParams.FieldByName('rdb$field_source').AsString);
      ibsqlParams.Next;
      if not ibsqlParams.EOF then
        S2 := S2 + ','#13#10
      else
        S2 := S2 + ')'#13#10;
    end;

    Result := S1 + S2;
  finally
    FreeAndNil(ibsqlDomain);
    FreeAndNil(ibsqlParams);
  end;
end;

function TgsMetadataEditor.GetTriggerText(const ATriggerName: String): String;
begin
  Result := '';

  FIBSQLRead.SQL.Text :=
    ' SELECT rdb$trigger_source AS FuncSource ' +
    ' FROM rdb$triggers ' +
    ' WHERE UPPER(rdb$trigger_name) = UPPER(:trigger_name) ';
  FIBSQLRead.ParamByName('TRIGGER_NAME').AsString := ATriggerName;

  try
    FIBSQLRead.ExecQuery;

    if FIBSQLRead.RecordCount > 0 then
    begin
      Result := Format('ALTER TRIGGER %s'#13#10'%s',
        [Trim(ATriggerName), Trim(FIBSQLRead.FieldByName('FUNCSOURCE').AsString)]);
    end
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
    '   UPPER(rf.rdb$relation_name) = UPPER(:rel_name) ' +
    '   AND UPPER(rf.rdb$field_name) = UPPER(:field_name) ' +
    '   AND NOT f.rdb$computed_source IS NULL ';
  FIBSQLRead.ParamByName('REL_NAME').AsString := ARelationName;
  FIBSQLRead.ParamByName('FIELD_NAME').AsString := AComputedFieldName;

  try
    FIBSQLRead.ExecQuery;

    if FIBSQLRead.RecordCount > 0 then
      Result := Format(
      'ALTER TABLE %0:s ADD %1:s COMPUTED BY %2:s',
      [Trim(ARelationName), Trim(AComputedFieldName), Trim(FIBSQLRead.FieldByName('FIELD_SOURCE').AsString)])
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
    '   UPPER(rdb$relation_name) = UPPER(:view_name) ' +
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
    Result := Format('CREATE OR ALTER VIEW %s%s'#13#10'AS'#13#10'%s',
      [Trim(AViewName), GetViewParamText(AViewName), Trim(ViewText)])
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
    '   UPPER(r.rdb$relation_name) = UPPER(:view_name) ' +
    '   AND NOT r.rdb$view_source IS NULL ' +
    ' ORDER BY ' +
    '   rf.rdb$field_position ASC';
  FIBSQLRead.ParamByName('VIEW_NAME').AsString := AViewName;

  try
    FIBSQLRead.ExecQuery;
    // ���� ������������� ����������
    if FIBSQLRead.RecordCount > 0 then
    begin
      Result := '('#13#10;
      // ������� �� ������ ����� �������������
      while not FIBSQLRead.Eof do
      begin
        Result := Result + '  ' + Trim(FIBSQLRead.FieldByName('FIELD_NAME').AsString);
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

{
  ��������� ���� ������� ��� ������� � ���������� �� � ��������������� ������,
  ��� ����������� ��������� ��� ������������ �������� ����������.
  ������� ������:
  (GRANT_TYPE)(USER_NAME)=(USER_TYPE)[(WITH_GRANT_OPTION)]
}
function TgsMetadataEditor.GetMetadataGrants(const AMetadataName: String; const AFieldName: String = ''): String;
var
  GrantList: TStringList;
  GrantElementStr: String;
begin
  Result := '';
  // ������ �� ��������� ������ ������� ��� ����������� �������
  FIBSQLRead.SQL.Text :=
    'SELECT ' +
    '  p.rdb$privilege AS user_privilege, ' +
    '  p.rdb$user_type AS user_type, ' +
    '  p.rdb$user AS user_name, ' +
    '  p.rdb$grant_option AS grant_option ' +
    'FROM ' +
    '  rdb$user_privileges p ' +
    'WHERE ' +
    '  UPPER(p.rdb$relation_name) = UPPER(:metadata_name) ' +
    '  AND p.rdb$user <> ''SYSDBA''';
  // ���� ���� ������ ��� ����, �� �������� �����������
  if AFieldName <> '' then
    FIBSQLRead.SQL.Text := FIBSQLRead.SQL.Text +
      '  AND UPPER(p.rdb$field_name) = UPPER(:field_name)';
  FIBSQLRead.ParamByName('METADATA_NAME').AsString := AMetadataName;
  // ���� ���� ������ ��� ����
  if AFieldName <> '' then
    FIBSQLRead.ParamByName('FIELD_NAME').AsString := AFieldName;

  try
    FIBSQLRead.ExecQuery;
    // ���� ������������� ����������
    if FIBSQLRead.RecordCount > 0 then
    begin
      GrantList := TStringList.Create;
      try
        // ������� �� ������ �������
        while not FIBSQLRead.Eof do
        begin
          // ���������� ������� ������� ������
          GrantElementStr := Trim(FIBSQLRead.FieldByName('user_privilege').AsString) +
            Trim(FIBSQLRead.FieldByName('user_name').AsString) + '=' +
            Trim(FIBSQLRead.FieldByName('user_type').AsString);
          if FIBSQLRead.FieldByName('grant_option').AsInteger = 1 then
            GrantElementStr := GrantElementStr + WITH_GRANT_OPTION_MARKER;

          // ������� � ������ ����������� ������� �������
          GrantList.Add(GrantElementStr);

          FIBSQLRead.Next;
        end;

        Result := GrantList.Text;
      finally
        FreeAndNil(GrantList);
      end;
    end;
  finally
    FIBSQLRead.Close;
  end;
end;

function TgsMetadataEditor.GetBackupComputedFieldText(const ARelationName, AComputedFieldName: String): String;
begin
  Result := '';

  FIBSQLRead.SQL.Text := Format(
    ' SELECT ' +
    '   t.%0:s ' +
    ' FROM %1:s t ' +
    ' WHERE ' +
    '   t.%2:s = :%2:s ' +
    '   AND UPPER(t.%3:s) = UPPER(:%3:s) ' +
    '   AND UPPER(t.%4:s) = UPPER(:%4:s) ',
    [HELP_M_SOURCE, HELP_METADATA_TABLE, HELP_M_OBJTYPE, HELP_M_RELATIONNAME, HELP_M_NAME]);
  FIBSQLRead.ParamByName(HELP_M_OBJTYPE).AsString := HELP_COMPUTED_FIELD_TYPE;
  FIBSQLRead.ParamByName(HELP_M_RELATIONNAME).AsString := ARelationName;
  FIBSQLRead.ParamByName(HELP_M_NAME).AsString := AComputedFieldName;
  try
    FIBSQLRead.ExecQuery;

    if FIBSQLRead.RecordCount > 0 then
      Result := FIBSQLRead.FieldByName(HELP_M_SOURCE).AsString
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

  FIBSQLRead.SQL.Text := Format(
    ' SELECT ' +
    '   t.%0:s ' +
    ' FROM %1:s t ' +
    ' WHERE ' +
    '   t.%2:s = :%2:s ' +
    '   AND UPPER(t.%3:s) = UPPER(:%3:s) ',
    [HELP_M_SOURCE, HELP_METADATA_TABLE, HELP_M_OBJTYPE, HELP_M_NAME]);
  FIBSQLRead.ParamByName(HELP_M_OBJTYPE).AsString := HELP_VIEW_TYPE;
  FIBSQLRead.ParamByName(HELP_M_NAME).AsString := AViewName;
  try
    FIBSQLRead.ExecQuery;

    if FIBSQLRead.RecordCount > 0 then
      Result := FIBSQLRead.FieldByName(HELP_M_SOURCE).AsString
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
  // ���� �� ������� ����� ����������, ������� �� ��
  if AParams = '_' then
    ParamText := GetProcedureParamText(AProcedureName)
  else
    ParamText := AParams;

  // ������� ���������� ��������� � ��
  SetProcedureText(Format('ALTER PROCEDURE %s %s AS'#13#10'%s', [AProcedureName, ParamText, AProcedureText]));
end;

procedure TgsMetadataEditor.SetProcedureText(const AProcedureText: String);
begin
  // ������� ���������� ��������� � ��
  FWriteTransaction.StartTransaction;
  try
    FIBSQLWrite.SQL.Text := AProcedureText;
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
  // ������� ���������� ������� � ��
  SetTriggerText('ALTER TRIGGER ' + ATriggerName + #13#10 + ATriggerText);
end;

procedure TgsMetadataEditor.SetTriggerText(const ATriggerText: String);
begin
  // ������� ���������� ������� � ��
  FWriteTransaction.StartTransaction;
  try
    FIBSQLWrite.SQL.Text := ATriggerText;
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
  // ������� ���������� ����������� ���� � ��
  { TODO : �� ����������� ������������� ������������ ���� }
  SetComputedFieldText(Format('ALTER TABLE %s ADD %s COMPUTED BY %s',
    [ARelationName, AComputedFieldName, AComputedFieldText]));
end;

procedure TgsMetadataEditor.SetComputedFieldText(
  const AComputedFieldText: String);
begin
  // ������� ���������� ����������� ���� � ��
  FWriteTransaction.StartTransaction;
  try
    FIBSQLWrite.SQL.Text := AComputedFieldText;
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
  SetViewText('CREATE OR ALTER VIEW ' + AViewName + AViewText);
end;

procedure TgsMetadataEditor.SetViewText(const AViewText: String);
begin
  // ������� ���������� ������������� � ��
  FWriteTransaction.StartTransaction;
  try
    FIBSQLWrite.SQL.Text := AViewText;
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

class function TgsMetadataEditor.CommentFunctionBody(var AFunctionText: String;
  const DoInsertSuspendClause: Boolean = False): Boolean;
var
  CharPosition: Integer;
  LengthBeginComment, LengthEndComment, LengthBegin: Integer;
begin
  // ���� ���� ������� ��� �� ����������������
  if StrFind(FUNCTION_COMMENT_BEGIN, AFunctionText) = 0 then
  begin
    Result := True;
    // ���������� � ��������
    CharPosition := 1;
    LengthBeginComment := Length(FUNCTION_COMMENT_BEGIN);
    LengthEndComment := Length(FUNCTION_COMMENT_END);
    LengthBegin := Length('BEGIN');

    // ������� �� ������ ������ � ��������� ������ ����������� ����� BEGIN
    while CharPosition > 0 do
    begin
      CharPosition := StrFind('BEGIN', AFunctionText, CharPosition);
      // ������������� ��� ��� ����������� BEGIN, � �� ����� �������� ���������
      //  ����� ������������� ��� BEGIN �� �������� � �����������
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
    // �������� � ����� �����������
    CharPosition := CharPosition + LengthBeginComment;
    // �������� �� ���� ������� � ���������� �����������
    while CharPosition > 0 do
    begin
      // ����� ������� ����������� ������� ��������� �����������
      CharPosition := StrFind('/*', AFunctionText, CharPosition);
      if CharPosition > 0 then
      begin
        Insert(FUNCTION_COMMENT_END, AFunctionText, CharPosition);
        CharPosition := CharPosition + LengthEndComment + 1;
      end;
      // ����� ����������� ������� ��������� �����������
      CharPosition := StrFind('*/', AFunctionText, CharPosition);
      if CharPosition > 0 then
      begin
        Insert(FUNCTION_COMMENT_BEGIN, AFunctionText, CharPosition + 2);
        CharPosition := CharPosition + LengthBeginComment + 2;
      end;
    end;
    // ������� �� ����� ������ � ��������� ����� ����������� ����� END
    // TODO: �� �������������� ������ ����� ����� END ���� ����������� ���������� END
    CharPosition := StrILastPos('END', AFunctionText);
    if CharPosition > 0 then
      Insert(FUNCTION_COMMENT_END, AFunctionText, CharPosition);

    // ��������� �� SUSPEND �������� (������ ��� �������� ��������)  
    if DoInsertSuspendClause then
      Insert(PROCEDURE_SUSPEND_TEMP, AFunctionText, CharPosition + LengthEndComment);
  end
  else
    Result := False;
end;

class function TgsMetadataEditor.UncommentFunctionBody(var AFunctionText: String): Boolean;
begin
  if StrFind(FUNCTION_COMMENT_BEGIN, AFunctionText) <> 0 then
  begin
    Result := True;
    // �������� �� ���� ������� � ������ ��������� ������������
    StrReplace(AFunctionText, FUNCTION_COMMENT_BEGIN, '', [rfReplaceAll]);
    StrReplace(AFunctionText, FUNCTION_COMMENT_END, '', [rfReplaceAll]);
    StrReplace(AFunctionText, PROCEDURE_SUSPEND_TEMP, '', [rfReplaceAll]);
  end
  else
    Result := False;
end;

procedure TgsMetadataEditor.BackupComputedField(const ARelationName, AComputedFieldName: String);
begin
  // �������� ����������� ���� �� ��������� �������
  FWriteTransaction.StartTransaction;
  try
    FIBSQLWrite.ParamCheck := True;
    FIBSQLWrite.SQL.Text := Format(
      ' INSERT INTO %0:s' +
      '   (%1:s, %2:s, %3:s, %4:s, %5:s, %6:s) ' +
      ' VALUES ' +
      '   (:%1:s, :%2:s, :%3:s, :%4:s, :%5:s, :%6:s) ',
      [HELP_METADATA_TABLE, HELP_M_OBJTYPE, HELP_M_NAME, HELP_M_RELATIONNAME, HELP_M_SOURCE,
       HELP_M_GRANTTEXT, HELP_M_POSITION]);
    FIBSQLWrite.ParamByName(HELP_M_OBJTYPE).AsString := HELP_COMPUTED_FIELD_TYPE;
    FIBSQLWrite.ParamByName(HELP_M_NAME).AsString := AComputedFieldName;
    FIBSQLWrite.ParamByName(HELP_M_RELATIONNAME).AsString := ARelationName;
    FIBSQLWrite.ParamByName(HELP_M_SOURCE).AsString := GetComputedFieldText(ARelationName, AComputedFieldName);
    FIBSQLWrite.ParamByName(HELP_M_GRANTTEXT).AsString := GetMetadataGrants(ARelationName, AComputedFieldName);
    FIBSQLWrite.ParamByName(HELP_M_POSITION).AsInteger := GetComputedFieldPosition(ARelationName, AComputedFieldName);
    try
      FIBSQLWrite.ExecQuery;
    finally
      FIBSQLWrite.ParamCheck := False;
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
  // �������� ������������� �� ��������� �������
  FWriteTransaction.StartTransaction;
  try
    FIBSQLWrite.ParamCheck := True;
    FIBSQLWrite.SQL.Text := Format(
      ' INSERT INTO %0:s' +
      '   (%1:s, %2:s, %3:s, %4:s) ' +
      ' VALUES ' +
      '   (:%1:s, :%2:s, :%3:s, :%4:s) ',
      [HELP_METADATA_TABLE, HELP_M_OBJTYPE, HELP_M_NAME, HELP_M_SOURCE, HELP_M_GRANTTEXT]);
    FIBSQLWrite.ParamByName(HELP_M_OBJTYPE).AsString := HELP_VIEW_TYPE;
    FIBSQLWrite.ParamByName(HELP_M_NAME).AsString := AViewName;
    FIBSQLWrite.ParamByName(HELP_M_SOURCE).AsString := GetViewText(AViewName);
    FIBSQLWrite.ParamByName(HELP_M_GRANTTEXT).AsString := GetMetadataGrants(AViewName);
    try
      FIBSQLWrite.ExecQuery;
    finally
      FIBSQLWrite.ParamCheck := False;
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
  // ������ ����������� ����
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
  // ������ ����������� ����
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
      // ������ ������ ��������� ���������� ������� � ���������� �����
      FunctionPosition := StrFind(OriginalFunction, AFunctionText);
      // ������ ��� ���������� ������� �������, � ���������� ����� ����� �������
      if (FunctionPosition <> 0) and not Result then
        Result := True;
      // ������� �� ����������� ������ � ������� ������� ���������� �������
      while FunctionPosition <> 0 do
      begin
        if IsSeparateWord(AFunctionText, FunctionPosition, OriginalFunctionLength) then
        begin
          // ������ ���������� �������
          Delete(AFunctionText, FunctionPosition, OriginalFunctionLength);
          // ������� ���������� �������
          Insert(SubstituteFunction, AFunctionText, FunctionPosition);
        end;
        // ������ ��������� ���������� �������
        FunctionPosition := StrFind(OriginalFunction, AFunctionText, FunctionPosition + SubstituteFunctionLength);
      end;
    end;
  end
  else
    raise Exception.Create('TgsMetadataEditor.ReplaceSubstituteUDFFunction'#13#10'  Substitution list not found.');
end;

procedure TgsMetadataEditor.DeleteUDFFunctions;
var
  FunctionCounter: Integer;
begin
  if Assigned(FDeleteFunctionList) then
  begin
    // ������ ����������� ����
    FWriteTransaction.StartTransaction;
    try
      for FunctionCounter := 0 to FDeleteFunctionList.Count - 1 do
      begin
        if UDFFunctionExists(FDeleteFunctionList.Names[FunctionCounter]) then
        begin
          FIBSQLWrite.SQL.Text :=
            'DROP EXTERNAL FUNCTION ' + FDeleteFunctionList.Names[FunctionCounter];
          try
            FIBSQLWrite.ExecQuery;
          finally
            FIBSQLWrite.Close;
          end;
        end;
      end;

      if FWriteTransaction.InTransaction then
        FWriteTransaction.Commit;
    except
      if FWriteTransaction.InTransaction then
        FWriteTransaction.Rollback;
      raise;
    end;
  end
  else
    raise Exception.Create('TgsMetadataEditor.DeleteUDFFunctions'#13#10'  "Delete UDF" list not found.');
end;

function TgsMetadataEditor.UDFFunctionExists(const AFunctinoName: String): Boolean;
begin
  Result := False;

    // ������ �� ����������� ������� ���� �� ��������� ������
  FIBSQLRead.SQL.Text :=
    ' SELECT rdb$function_name ' +
    ' FROM rdb$functions ' +
    ' WHERE UPPER(rdb$function_name) = UPPER(:func_name)';
  FIBSQLRead.ParamByName('FUNC_NAME').AsString := AFunctinoName;

  try
    FIBSQLRead.ExecQuery;
    if FIBSQLRead.RecordCount > 0 then
      Result := True;
  finally
    FIBSQLRead.Close;
  end;
end;

class function TgsMetadataEditor.IsCommented(const ACharPosition: Integer;
  const AFunctionText: String): Boolean;

  function TestForSymbolContaining(const AFirst, ASecond: String): Boolean;
  var
    CurrentPosition: Integer;
  begin
    Result := False;
    // ������ ������ AFirst ����� �������� � ACharPosition
    CurrentPosition := StrFind(AFirst, AFunctionText);
    if (CurrentPosition > 0) and (CurrentPosition < ACharPosition) then
    begin
      while (CurrentPosition > 0) and (CurrentPosition < ACharPosition) do
      begin
        // ������ ������ ASecond
        CurrentPosition := StrFind(ASecond, AFunctionText, CurrentPosition);
        // ���� ��������� ������ ASecond ��� ����� ACharPosition, ������ ������� ������� � �����������
        if CurrentPosition > ACharPosition then
        begin
          Result := True;
          Exit;
        end
        else
          // �����, ����� ������� �������� �� ���� �����������, �������� � ����������
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

class function TgsMetadataEditor.GetFirstNLines(const AText: String;
  const ALineCount: Integer): String;
var
  LinesList: TStringList;
  LineCounter: Integer;
begin
  Result := '';

  LinesList := TStringList.Create;
  try
    LinesList.Text := AText;
    if LinesList.Count > ALineCount then
    begin
      for LineCounter := (LinesList.Count - 1) downto ALineCount do
        LinesList.Delete(LineCounter);
      LinesList.Add(LINE_CUT);
    end;
    Result := LinesList.Text;
  finally
    LinesList.Free;
  end;
end;

{
  ����������� ������ ��� ����� ���������� ������� (������� �� �������� �������)
  ������ �������� ������ �������:
  (GRANT_TYPE)(USER_NAME)=(USER_TYPE)[(WITH_GRANT_OPTION)]
}
procedure TgsMetadataEditor.RestoreGrant(const AMetadataName: String; const ARelationName: String = '');
var
  GrantList: TStringList;
  GrantListCounter: Integer;
  UserName, UserType, GrantType: String;
  WithGrantOption: String;

  procedure ParseGrantElement;
  begin
    // ��� ����������� ������
    GrantType := StrLeft(GrantList.Names[GrantListCounter], 1);
    if GrantType = 'S' then
      GrantType := 'SELECT'
    else if GrantType = 'I' then
      GrantType := 'INSERT'
    else if GrantType = 'U' then
      GrantType := 'UPDATE'
    else if GrantType = 'D' then
      GrantType := 'DELETE'
    else if GrantType = 'R' then
      GrantType := 'REFERENCES'
    else
      GrantType := 'ALL';

    // ��� ������� �������� �������� �����
    UserName := StrRestOf(GrantList.Names[GrantListCounter], 2);

    if StrFind(WITH_GRANT_OPTION_MARKER, GrantList.Values[GrantList.Names[GrantListCounter]]) > 0 then
    begin
      UserType := StrLeft(GrantList.Values[GrantList.Names[GrantListCounter]],
        StrLength(GrantList.Values[GrantList.Names[GrantListCounter]]) - StrLength(WITH_GRANT_OPTION_MARKER));
      WithGrantOption := 'WITH GRANT OPTION';
    end
    else
    begin
      UserType := GrantList.Values[GrantList.Names[GrantListCounter]];
      WithGrantOption := '';
    end;
    // ��� ������� �������� �������� ����� (�������� ������ ������� ��� ���������)
    if UserType = '2' then
      UserType := 'TRIGGER'
    else if UserType = '5' then
      UserType := 'PROCEDURE'
    else
      UserType := '';
  end;

begin
  // ������ �� ����������� ������ ������� �� �������� �������
  FIBSQLRead.SQL.Text := Format(
    'SELECT %0:s FROM %1:s WHERE UPPER(%2:s) = UPPER(:metadata_name)',
    [HELP_M_GRANTTEXT, HELP_METADATA_TABLE, HELP_M_NAME]);
  if ARelationName <> '' then
    FIBSQLRead.SQL.Text := FIBSQLRead.SQL.Text +
      ' AND UPPER(' + HELP_M_RELATIONNAME + ') = UPPER(:relation_name) ';
  FIBSQLRead.ParamByName('METADATA_NAME').AsString := AMetadataName;
  if ARelationName <> '' then
    FIBSQLRead.ParamByName('RELATION_NAME').AsString := ARelationName;

  try
    FIBSQLRead.ExecQuery;

    if (FIBSQLRead.RecordCount > 0) and (FIBSQLRead.FieldByName(HELP_M_GRANTTEXT).AsString <> '') then
    begin
      GrantList := TStringList.Create;
      try
        GrantList.Text := FIBSQLRead.FieldByName(HELP_M_GRANTTEXT).AsString;

        FWriteTransaction.StartTransaction;
        try
          // ������� �� ������ �������� ��� �������� ������� � �������� ������ �� ���
          for GrantListCounter := 0 to GrantList.Count - 1 do
          begin
            // ������ �������� ������
            ParseGrantElement;
            // �������� ������
            if ARelationName = '' then
              FIBSQLWrite.SQL.Text := Format(
                'GRANT %0:s ON %1:s TO %2:s %3:s %4:s',
                [GrantType, AMetadataName, UserType, UserName, WithGrantOption])
            else
              FIBSQLWrite.SQL.Text := Format(
                'GRANT %0:s(%1:s) ON %2:s TO %3:s %4:s %5:s',
                [GrantType, ARelationName, AMetadataName, UserType, UserName, WithGrantOption]);
            try
              FIBSQLWrite.ExecQuery;
            finally
              FIBSQLWrite.Close;
            end;
          end;

          if FWriteTransaction.InTransaction then
            FWriteTransaction.Commit;
        except
          if FWriteTransaction.InTransaction then
            FWriteTransaction.Rollback;
          raise;
        end;
      finally
        FreeAndNil(GrantList);
      end;
    end;
  finally
    FIBSQLRead.Close;
  end;
end;

function TgsMetadataEditor.GetComputedFieldPosition(const ARelationName,
  AComputedFieldName: String): Integer;
begin
  // ������ �� ����������� ������� ���� �� ��������� ������
  FIBSQLRead.SQL.Text :=
    ' SELECT rdb$field_position AS obj_pos ' +
    ' FROM rdb$relation_fields ' +
    ' WHERE UPPER(rdb$relation_name) = UPPER(:rel_name) ' +
    '   AND UPPER(rdb$field_name) = UPPER(:field_name)';
  FIBSQLRead.ParamByName('REL_NAME').AsString := ARelationName;
  FIBSQLRead.ParamByName('FIELD_NAME').AsString := AComputedFieldName;

  try
    FIBSQLRead.ExecQuery;
    if FIBSQLRead.RecordCount > 0 then
      Result := FIBSQLRead.FieldByName('OBJ_POS').AsInteger
    else
      Result := -1;
  finally
    FIBSQLRead.Close;
  end;
end;

procedure TgsMetadataEditor.RestorePosition(const ARelationName, AMetadataName: String);
begin
  // ������ �� ����������� ������� ���� �� �������� �������
  FIBSQLRead.SQL.Text := Format(
    ' SELECT %0:s AS obj_pos FROM %1:s ' +
    ' WHERE UPPER(%2:s) = UPPER(:relation_name)' +
    '   AND UPPER(%3:s) = UPPER(:metadata_name) ',
    [HELP_M_POSITION, HELP_METADATA_TABLE, HELP_M_RELATIONNAME, HELP_M_NAME]);
  FIBSQLRead.ParamByName('RELATION_NAME').AsString := ARelationName;
  FIBSQLRead.ParamByName('METADATA_NAME').AsString := AMetadataName;

  try
    FIBSQLRead.ExecQuery;

    if (FIBSQLRead.RecordCount > 0) and (FIBSQLRead.FieldByName('OBJ_POS').AsInteger >= 0) then
    begin
      FWriteTransaction.StartTransaction;
      try
        FIBSQLWrite.ParamCheck := True;
        FIBSQLWrite.SQL.Text :=
          ' UPDATE rdb$relation_fields ' +
          ' SET rdb$field_position = :obj_pos ' +
          ' WHERE rdb$relation_name = :rel_name AND rdb$field_name = :field_name';
        FIBSQLWrite.ParamByName('REL_NAME').AsString := ARelationName;
        FIBSQLWrite.ParamByName('FIELD_NAME').AsString := AMetadataName;
        FIBSQLWrite.ParamByName('OBJ_POS').AsInteger := FIBSQLRead.FieldByName('OBJ_POS').AsInteger;
        try
          FIBSQLWrite.ExecQuery;
        finally
          FIBSQLWrite.ParamCheck := False;
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
  finally
    FIBSQLRead.Close;
  end;
end;

end.
