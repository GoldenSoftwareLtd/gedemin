
{++

   Project Gedemin
   Sub-project Setup
   Copyright (c) 2000 by Golden Software, Ltd

   Модуль

     gd_boDBUpgrade.pas

   Описание

     Компонент для проведения апгрейда базы данных.

   Автор

     Kornachenko Nikolai

   История

     ver    date         who      what

     1.00   10.07.2000   NK       Начало работы.
     1.01   05.08.2000   andreik  Protocol initial value changed to TCP.
     2.00   10.08.2000   andreik  Significant changes. TIBTable is used for
                                  data transfering among tables.

--}
unit gd_boDBUpgrade;

{ TODO 1 -oандрэй -cзрабіць : Што захоўваць у ВЕР файле? Нумар (ідэнтыфікатар) версіі ці страку? }
{ TODO 2 -oандрэй -cзрабіць : Пасля распакоўкі базы трэба павялічваць яе памер, каб далей хутчэй ішло аднаўленьне. }
{ DONE 2 -oандрэй -cпамылка : Праграма павінна запускацца толькі на сэрвере, але гэта яўна нідзе не правяраецца. }
{ DONE 2 -oандрэй -cпамылка :
Ніжэй тое, што выдае ў лог файл апгрэйд, калі было немагчыма
стварыць архіўную копію і карыстальнік выбраў спыніць працэс.
Звярнуць увагу на апошнія запісы!

Начат перенос данных: 20.08.00 21:01:40
Имя сервера: KIREEV
Исходная база данных: d:\golden\gedemin\setup\test\gdbase.gdb
Перевод базы данных в однопользовательский режим...
Успешно завершен
Номер версии исходной базы данных: 0000.0001.0000.0009
Номер версии новой базы данных: 0000.0001.0000.0009
Начато создание архивной копии данных: 20.08.00 21:01:46
Имя архивного файла: c:\program files\golden software\gedemin\archive\GDBASE_200800_2101.BK
В процессе создания архивной копии произошел сбой.
Процесс апгрейда был прерван: 20.08.00 21:02:12
Начато восстановление новой базы данных: 20.08.00 21:02:12
Имя файла базы данных: d:\golden\gedemin\setup\test\gdbase.gdb
Имя файла архива: c:\program files\golden software\gedemin\archive\GDBASE_200800_2101.BK
Завершено восстановление базы данных: 20.08.00 21:02:13
Во время восстановления новой версии базы данных произшла ошибка
Обновленная база данных переведена в многопользовательский режим }

interface

uses
  Windows,    Messages,    SysUtils,   Classes,   Graphics,   Controls,    Forms,
  Dialogs,    IBDatabase,  IBServices, IBTable,   IBSQL,  IBExtract;

// тыпы дадзеных, як яны выкарыстоўваюцца ў сыстэмных
// табліцах ІБ
const
  IBFT_SMALLINT         = 7;
  IBFT_INTEGER          = 8;
  IBFT_QUAD             = 9;
  IBFT_FLOAT            = 10;
  IBFT_D_FLOAT          = 11;
  IBFT_DATE             = 12;
  IBFT_TIME             = 13;
  IBFT_CHAR             = 14;
  IBFT_INT64            = 16;
  IBFT_DOUBLE           = 27;
  IBFT_TIMESTAMP        = 35;
  IBFT_VARCHAR          = 37;
  IBFT_CSTRING          = 40;
  IBFT_BLOB             = 261;


//
// аперацыя мердже выконваецца наступным чынам:
// 1. з архіўнай копіі новай базы распакоўваецца табліца з нейкімі дадзенымі
// 2. дзеючая база таксама мае гэту табліцу з нейкімі дадзенымі
// 3. супадаючыя запісы заменяюцца запісамі з дзеючай базы
// 4. адсутнічыя запісы пераносяцца з новай базы як ёсць
// 5. запісы вызначаюцца па первічнаму ключу
//

type
  TUpgradeLog = procedure(const AnMessage: String) of object;

type
  TTablePrimaryKey = class(TCollectionItem)
  private
    FTableName, FConstraintName: String;
    FKeyFieldCount: Integer;
    FKeyFields: array[0..15] of String;

    function GetKeyFields(Index: Integer): String;

  public
    constructor Create(ACollection: TCollection); override;

    procedure Init(const ATableName, AConstraintName: String; const AFields: array of String);
    procedure AddKeyField(const AFieldName: String);
    function AddDDL: String;
    function DropDDL: String;
    function Locate(ATargetTable, ASourceTable: TIBTable): Boolean; overload;
    function Locate(ATargetTable: TIBTable; ASourceTable: TIBSQL): Boolean; overload;

    property TableName: String read FTableName;
    property KeyFieldCount: Integer read FKeyFieldCount;
    property KeyFields[Index: Integer]: String read GetKeyFields;
  end;

type
  TTablePrimaryKeyClass = class of TTablePrimaryKey;

type
  TPrimaryKeys = class(TCollection)
  public
    procedure AddDDL(AStringList: TStringList);
    procedure DropDDL(AStringList: TStringList);
    function Find(const ATableName: String): TTablePrimaryKey;
  end;

type
  EboDBUpgradeException = class(Exception);

  // Типы об]ектов Interbase
  TInterbaseObjectType = (ioDomain,       //Перенос реализован
                          ioTable,        //Перенос реализован
                          ioView,         //Перенос реализован
                          ioField,        //Перенос реализован
                          ioProcedure,    //Перенос реализован
                          ioFunction,     //Перенос реализован
                          ioGenerator,    //Перенос реализован
                          ioException,    //Перенос реализован
                          ioTrigger,      //Перенос реализован
                          ioForeign,      //Перенос реализован
                          ioIndexes);     //Перенос реализован

  // Состояния апгрейда
  TboUpgradeProcessState = (
    psIdle,               // нічога яшчэ не адбываецца, беспрацоўны стан
    psUpgradeAttributes,  // пераносяцца атрыбуты, створанныя карыстальнікам
    psReadingStruct,      // счытваньне структуры (ключоў, спасылак, індэксаў)
    psDeletingStruct,     // выдаленьне структуры (ключоў, спасылак, індэксаў)
    psCreatingStruct,     // стварэньне структуры (ключоў, спасылак, індэксаў)
    psUpgradeTable,       // пераносяцца дадзеныя табліцы
    psUpgradeGenerators,  // пераносяцца генератары
    psSuccess,            // перанос скончыўся поспехам
    psError,              // перанос скончыўся памылкай
    psUserCanceled        // перанос быў спынены
  );

  // тыпы апгрэйду
  TTestCustomUpgradeResult = (
    tcurUpgradeImpossible,       // аднавіць базу немагчыма, трэ' звяртацца да распрацоўшчыкаў
    tcurStandartProcedure,       // трэба запусціць стандартную працэдуру апгрэйда
    tcurCustomProcedure,         // апгрэйд выконваецца спецыяльным кодам, трэба і старая і
                                 // новая базы
    tcurCurrentDatabaseUpgrade   // будзе адноўленая дзеючая база
                                 // распаковываць і капіраваць новую базу не трэба
  );

  TTestCustomUpgradeEvent = procedure (const ASourceVersionID, ATargetVersionID: String;
    var Result: TTestCustomUpgradeResult) of object;

  TCustomUpgradeEvent = procedure (const ASourceVersionID, ATargetVersionID: String) of object;

  TStandartUpgradeEvent = procedure(ASourceDatabase, ATargetDatabase : TIBDatabase) of object;

  TExecDDLScriptStatusUpdate = procedure(const ADDLStatement: String;
    const ACurrent, ATotal: Integer) of object;


  // тып для зваротнай працэдуры, якая выклікаецца, калі
  // запіс дадаецца ў лог файл, каб можна было не толькі
  // у лог, а і на экран выводзіць што-небудзь
  TOnLogRecord = procedure(ASender: TObject; const AString: String) of object;

  TboDBUpgrade = class(TComponent)
  private
    FUpgradeLog: TUpgradeLog;
    FOldDatabase: TIBDatabase;
    FOldTransaction: TIBTransaction;

    FNewDatabase: TIBDatabase;
    FNewTransaction: TIBTransaction;

    FProtocol: TProtocol;

    FUserName: String;
    FPassword: String;

    FBkFileName: String;
    FOldBkFileName: String;
    FCharSet: String;

    FOldVersion: String[20];
    FNewVersion: String[20];

    FCloseUpgrade: Boolean;

    FUpgradeTables: TStringList;
    FExcludeTables: TStringList;
    FMergeTables: TStringList;

    FSourceDatabase: String; //Старая база данных
    FTargetDatabase: String; //Новая база данных

    FArchiveDirectory: String;
    FServerName: String;

    FForeignKeysList: TStringList;
    FIndicesList: TStringList;
    FTriggersList: TStringList;
    FPrimaryKeys: TPrimaryKeys;
    FCurrentObject: String;
    FProcessState: TboUpgradeProcessState;
    FErrorCount: Integer;
    FCurrentStep: Integer;
    FLogFileName: String;
    FTransferReplication: Boolean;
//    FRestartTools: String;
    FOnLogRecord: TOnLogRecord;
    FOnProgressUpgrade: TNotifyEvent;
    FOnTestCustomUpgrade: TTestCustomUpgradeEvent;
    FOnCustomUpgrade: TCustomUpgradeEvent;
    FOnBeforeStandartUpgrade: TStandartUpgradeEvent;
    FOnAfterStandartUpgrade: TStandartUpgradeEvent;
    FSQLDialect: Integer;
    FThisComputerName: String;
    FReconnectToDatabase: Boolean;


    (*
    FAutoExecString: String;
    *)

    function TestStop: Boolean;
    procedure SetExcludeTableList(const Value: TStringList);
    procedure SetCurrentObject(const Value: String);
    procedure SetMergeTableList(const Value: TStringList);

    procedure DeactivateTriggers;
    procedure DeleteForeignKeys;
    procedure DeletePrimaryKeys;
    procedure DeactivateIndices;
    procedure ActivateIndices;
    procedure RestorePrimaryKeys;
    procedure RestoreForeignKeys;
    procedure ActivateTriggers;

    procedure TransferFields;
    procedure TransferIndices;
    procedure TransferForeignKeys;
//
    procedure TransferViews;
    procedure TransferFunctions;
    procedure TransferGenerators;
    procedure TransferExceptions;

    procedure TransferTables;
    procedure TransferProcedures;
    procedure TransferTriggers;
    procedure TransferDomains;

    procedure ShutDownNew;
    function DatabaseOnLine(ADatabaseName: String): Boolean;
    procedure MergeRecords;
    // Считывает версию новой базы данных
    function ReadNewDatabaseVersion: String;
    // Считывает версию существующей базы данных
    function ReadOldDatabaseVersion: String;

    procedure RestructTrees;
    procedure IncAttrGen;

    procedure StandartUpgrade;
    // Устанавливает текущий статус апгрейда
    procedure SetProcessState(const AProcessState: TboUpgradeProcessState);
    // Восстанавливает новую базу данных из bk файла
    procedure RestoreDatabase(const ADatabaseName, AnUserName, APassword,
      ABkFileName: String);
    // Архивируем старую базу
    procedure BackUpDatabase;
    // Переносит значения генераторов
    procedure UpgradeGenerators;
    // Переносит строки из таблицы с именем ATableName
    procedure UpgradeTable(const ATableName: String);
    // Вызов метода OnProgressUpdate
    procedure DoProcessUpgrade;
    // Заносит запись в лог файл
    procedure LogRecord(const AString: String);
    //
    procedure LogError(const AString: String);
    //
    procedure GrantUser;

    // Проверка создателя объекта ДБ
    function CheckUserObject(Const AnObjectName: String; Const AnObjectType: TInterbaseObjectType): Boolean;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    // Запуск апгрейда
    procedure ExecuteUpgrade;
    // Остановка процесса
    procedure StopUpgrade;

    //Имя текущего обрабатываемого объекта
    property CurrentObject: String read FCurrentObject write SetCurrentObject;
    // Текущее состояние апгрейда
    property ProcessState: TboUpgradeProcessState read FProcessState write SetProcessState;
    // Таблицы, исключенные из обработки
    property ExcludeTables: TStringList read FExcludeTables write SetExcludeTableList;
    // Табліцы, якія будуць злівацца з існуючымі
    property MergeTables: TStringList read FMergeTables write SetMergeTableList;
    //
    property ThisComputerName: String read FThisComputerName write FThisComputerName;
    //
    property ReconnectToDatabase: Boolean read FReconnectToDatabase write FReconnectToDatabase;

  published
    property UpgradeLog: TUpgradeLog read FUpgradeLog write FUpgradeLog;
    // імя кампутара, сэрвера базы дадзеных
    property ServerName: String read FServerName write FServerName;
    // Шлях да файлу са старой базай дадзеных
    property SourceDatabase: String read FSourceDatabase write FSourceDatabase;
    // Імя карыстальніка
    property UserName: String read FUserName write FUserName;
    // Пароль
    property Password: String read FPassword write FPassword;
    // Архіў з новай вэрсіяй базы дадзеных
    property BackupFile: String read FBkFileName write FBkFileName;
    // Пратакол падключэньня да сэрвера
    property Protocol: TProtocol read FProtocol write FProtocol
      default TCP;
    property TransferReplication: boolean read FTransferReplication write FTransferReplication
      default True;
    property SQLDialect: Integer read FSQLDialect write FSQLDialect;

    property OnProgressUpdate: TNotifyEvent read FOnProgressUpgrade write FOnProgressUpgrade;
    property OnTestCustomUpgrade: TTestCustomUpgradeEvent read FOnTestCustomUpgrade write FOnTestCustomUpgrade;
    property OnCustomUpgrade: TCustomUpgradeEvent  read FOnCustomUpgrade write FOnCustomUpgrade;
    property OnBeforeStandartUpgrade: TStandartUpgradeEvent read FOnBeforeStandartUpgrade write FOnBeforeStandartUpgrade;
    property OnAfterStandartUpgrade: TStandartUpgradeEvent read FOnAfterStandartUpgrade write FOnBeforeStandartUpgrade;
    property OnLogRecord: TOnLogRecord read FOnLogRecord write FOnLogRecord;
  end;

procedure Register;

implementation

uses
  FileCtrl,  IBDatabaseInfo,       gsDatabaseShutdown,
  Registry,  gd_directories_const, gd_boDBUpgrade_dlgCheckMessage_unit,
  IBQuery,   IBStoredProc,         JCLRegistry,
  DB,        IB,                   IBHeader,
  IBIntf,    gd_encrypt,           JclStrings,
  IBCustomDataSet,                 at_classes,
  {gdModify, } inst_memsize
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

function MyNow(const WithDate: Boolean = True): String;
begin
  if WithDate then
    Result := FormatDateTime('dd.mm.yy hh:nn:ss', Now)
  else
    Result := FormatDateTime('hh:nn:ss', Now);
end;

// эта процедура каждую команду выполняет в своем подключении к БД
procedure ExecDDLScript(const ADatabaseName, AUserName, APassword, ACodePage: String;
  AScript, AnInvalidStatements: TStrings; ACallback: TExecDDLScriptStatusUpdate;
  ADialect: Word; const ReconnectToDatabase: Boolean);
var
  StatusVector: TStatusVector;
  DB: TISC_DB_HANDLE;
  TR: TISC_TR_HANDLE;
  TEB: TISC_TEB;
  DatabaseName: array[0..255] of Char;
  DDLStatement: array[0..2047] of Char;
  R, I: Integer;
  DPB: String[200];
  Connected: Boolean;
{  FTRParams: TStringList;
  FTPB: PChar;
  TPB: String;
  FTPBLength: Short;}
begin
  DPB := Char(isc_dpb_version1) +
    Char(isc_dpb_user_name) +
    Char(Length(AUserName)) +
    AUserName +
    Char(isc_dpb_password) +
    Char(Length(APassword)) +
    APassword +
    Char(isc_dpb_lc_ctype) +
    Char(Length(ACodePage)) +
    ACodePage;
  Connected := False;
  //FTPB := nil;
  try

    for I := 0 to AScript.Count - 1 do
    begin
      DB := nil;
      StrPCopy(DatabaseName, ADatabaseName);

      if not Connected then
      begin
        Assert(isc_attach_database(@StatusVector,
          0,
          DatabaseName,
          @DB,
          Length(DPB),
          @DPB[1]) = 0);
        Connected := True;
      end;


      TEB.db_handle := @DB;
      TEB.tpb_length := 0;
      TEB.tpb_address := nil;

      {FTRParams := TStringList.Create;
      try
        FTRParams.Text := 'nowait';
        GenerateTPB(FTRParams, TPB, FTPBLength);
        if FTPBLength > 0 then
        begin
          if FTPB <> nil then
            FreeMem(FTPB);
          IBAlloc(FTPB, 0, FTPBLength);
          Move(TPB[1], FTPB[0], FTPBLength);
          TEB.tpb_length := FTPBLength;
          TEB.tpb_address := FTPB;
        end;
      finally
        FTRParams.Free;
      end;}

      TR := nil;
      Assert(isc_start_multiple(@StatusVector, @TR, 1, @TEB) = 0);

      StrPCopy(DDLStatement, AScript[I]);

      R := isc_dsql_execute_immediate(
        @StatusVector,
        @DB,
        @TR,
        0,
        DDLStatement,
        ADialect,
        nil);

      if R <> 0 then
      begin
        AnInvalidStatements.Add(AScript[I]);
      end;

      begin

        R := isc_commit_transaction(@StatusVector, @TR);

        if R <> 0 then
        begin
          AnInvalidStatements.Add(AScript[I]);
        end;

      end;

      if ReconnectToDatabase then
      begin
        Assert(isc_detach_database(@StatusVector, @DB) = 0);
        Connected := False;
      end;

      if Assigned(ACallback) then
        ACallback(AScript[I], I, AScript.Count);
    end;

  finally
    {if FTPB <> nil then
      FreeMem(FTPB);}
    if Connected then
      Assert(isc_detach_database(@StatusVector, @DB) = 0);
  end;
end;

constructor TboDBUpgrade.Create(AnOwner: TComponent);
var
  Reg: TRegistry;
begin
  inherited Create(AnOwner);

  FReconnectToDatabase := True;

  // счытваем шлях да папкі з архівамі
  // і кодавую старонку
  Reg := TRegistry.Create;
  try
    Reg.RootKey := ServerRootRegistryKey;

    if Reg.OpenKeyReadOnly(ServerRootRegistrySubKey) then
    begin
      FArchiveDirectory := Reg.ReadString(ArchiveDirectoryValue);
      FCharSet := Reg.ReadString(Lc_ctypeValue);
    end else
    begin
      FArchiveDirectory := '';
      FCharSet := '';
    end;

    if FArchiveDirectory = '' then
      FArchiveDirectory := IncludeTrailingBackSlash(DefaultArchiveDirectory);

    if FCharSet = '' then
      FCharSet := DefaultLc_ctype;
  finally
    Reg.Free;
  end;

  FSourceDatabase := '';
  FTargetDatabase := '';

  FUpgradeTables := TStringList.Create;
  FExcludeTables := TStringList.Create;
  FMergeTables := TStringList.Create;
  FIndicesList := TStringList.Create;
  FForeignKeysList := TStringList.Create;
  FTriggersList := TStringList.Create;
  FPrimaryKeys := TPrimaryKeys.Create(TTablePrimaryKey);

  FCloseUpgrade := False;

  FProtocol := TCP;

  FTransferReplication := True;

  FProcessState := psIdle;
  FCurrentObject := '';
  FErrorCount := 0;
  FLogFileName := '';

  FSQLDialect := 3;
end;

destructor TboDBUpgrade.Destroy;
begin
//
  FExcludeTables.Free;
  FMergeTables.Free;
  FUpgradeTables.Free;
  FIndicesList.Free;
  FForeignKeysList.Free;
  FTriggersList.Free;
  FPrimaryKeys.Free;
  inherited;
end;

function TboDBUpgrade.TestStop: Boolean;
begin
  Application.ProcessMessages;
  if (FProcessState = psError) or (FProcessState = psUserCanceled) then
    Result := True
  else
    Result := False;
end;

procedure TboDBUpgrade.StopUpgrade;
begin
  ProcessState := psUserCanceled;
end;

procedure TboDBUpgrade.SetCurrentObject(const Value: String);
begin
  FCurrentObject := Value;
  DoProcessUpgrade;
  Application.ProcessMessages;
end;

procedure TboDBUpgrade.SetExcludeTableList(const Value: TStringList);
var
  I: Integer;
begin
  FExcludeTables.Clear;

  if Assigned(Value) then
    for I := 0 to Value.Count - 1 do
      if (Pos('//', Value[I]) = 0) and (Trim(Value[I]) > '') then
        if FExcludeTables.IndexOf(UpperCase(Trim(Value[I]))) = -1 then
          FExcludeTables.Add(UpperCase(Trim(Value[I])));
end;

// Проверка типа объекта БД
function TboDBUpgrade.CheckUserObject(Const AnObjectName: String; Const AnObjectType: TInterbaseObjectType): Boolean;
begin
  Result := False;
  if ((Pos(UserPrefix, AnsiUpperCase(Trim(AnObjectName))) = 1) or ((Pos('REPL$', AnsiUpperCase(Trim(AnObjectName))) = 1) and (FTransferReplication)) ) then
    Result := True
  else
    if FTransferReplication then
      case AnObjectType of
        ioTable:
          if (AnsiUpperCase(Trim(AnObjectName)) = 'REPL_LOG') or
             (AnsiUpperCase(Trim(AnObjectName)) = 'REPL_SEPARATOR') or
             (AnsiUpperCase(Trim(AnObjectName)) = 'MANUAL_LOG') then
            Result := True;
        ioGenerator:
          if Pos('REPL', AnsiUpperCase(Trim(AnObjectName))) = 1 then
            Result := True;
      end;
end;

//Перенос исключений
procedure TboDBUpgrade.TransferExceptions;
var
  ibsqlExceptions, ibsqlNew: TIBSQL;
  ibExtract: TIBExtract;
  ProcLines: TStringList;
begin
  LogRecord('Начат перенос исключений: ' + MyNow);
  ibsqlExceptions := TIBSQL.Create(Self);
  try
    ibsqlExceptions.Database := FOldDatabase;
    ibsqlExceptions.Transaction := FOldTransaction;
    if not FOldTransaction.InTransaction then
      FOldTransaction.StartTransaction;
    ibsqlExceptions.SQL.Text := 'SELECT rdb$exception_name FROM rdb$exceptions';
    ibsqlExceptions.ExecQuery;

    if ibsqlExceptions.RecordCount > 0 then
    begin
      ibExtract := TIBExtract.Create(Self);
      try
        ibExtract.Database := FOldDatabase;
        ibExtract.Transaction := FOldTransaction;

        ibsqlNew := TIBSQL.Create(Self);
        try
          ibsqlNew.Database := FNewDatabase;
          ibsqlNew.Transaction := FNewTransaction;
          ibsqlNew.ParamCheck := False;
          ProcLines := TStringList.Create;
          try
            while not ibsqlExceptions.Eof do
            begin
              if CheckUserObject(ibsqlExceptions.Fields[0].AsTrimString, ioException) then
              begin
                try
                  ibExtract.ExtractObject(eoException, ibsqlExceptions.Fields[0].AsTrimString, []);

                  ProcLines.Assign(ibExtract.Items);

                  if not FNewTransaction.InTransaction then
                    FNewTransaction.StartTransaction;

                  ibsqlNew.SQL.Assign(ProcLines);
                  ibsqlNew.ExecQuery;

                  FNewTransaction.Commit;
                  LogRecord('Перенесено исключение: "' + ibsqlExceptions.Fields[0].AsTrimString + '"');
                except
                  on E: Exception do
                  begin
                    Inc(FErrorCount);
                    LogRecord('Ошибка переноса исключения: "' + ibsqlExceptions.Fields[0].AsTrimString + '"');
                    LogRecord(E.Message);
                    LogRecord('DDL statement: ' + ibsqlNew.SQL.Text);
                  end;
                end;
              end;
              ibsqlExceptions.Next;
            end;
          finally
            ProcLines.Free;
          end
        finally
          ibsqlNew.Free;
        end;
      finally
        ibExtract.Free;
      end;
    end;
  finally
    ibsqlExceptions.Free;
  end;

  LogRecord('Завершен перенос исключений: '+ MyNow);
//
end;

//Перенос генераторов
procedure TboDBUpgrade.TransferGenerators;
var
  ibsqlGenerators, ibsqlNew: TIBSQL;
  ibExtract: TIBExtract;
  ProcLines: TStringList;
begin
  LogRecord('Начат перенос генераторов: ' + MyNow);
  ibsqlGenerators := TIBSQL.Create(Self);
  try
    ibsqlGenerators.Database := FOldDatabase;
    ibsqlGenerators.Transaction := FOldTransaction;
    if not FOldTransaction.InTransaction then
      FOldTransaction.StartTransaction;
    ibsqlGenerators.SQL.Text := 'SELECT rdb$generator_name FROM rdb$generators';
    ibsqlGenerators.ExecQuery;

    if ibsqlGenerators.RecordCount > 0 then
    begin
      ibExtract := TIBExtract.Create(Self);
      try
        ibExtract.Database := FOldDatabase;
        ibExtract.Transaction := FOldTransaction;

        ibsqlNew := TIBSQL.Create(Self);
        try
          ibsqlNew.Database := FNewDatabase;
          ibsqlNew.Transaction := FNewTransaction;
          ibsqlNew.ParamCheck := False;
          ProcLines := TStringList.Create;
          try
            while not ibsqlGenerators.Eof do
            begin
              if CheckUserObject(ibsqlGenerators.Fields[0].AsTrimString, ioGenerator) then
              begin
                try
                  ibExtract.ExtractObject(eoGenerator, ibsqlGenerators.Fields[0].AsTrimString, []);

                  ProcLines.Assign(ibExtract.Items);

                  if not FNewTransaction.InTransaction then
                    FNewTransaction.StartTransaction;

                  ibsqlNew.SQL.Assign(ProcLines);
                  ibsqlNew.ExecQuery;

                  FNewTransaction.Commit;
                  LogRecord('Перенесен генератор: "' + ibsqlGenerators.Fields[0].AsTrimString + '"');
                except
                  on E: Exception do
                  begin
                    Inc(FErrorCount);
                    LogRecord('Ошибка переноса генератора: "' + ibsqlGenerators.Fields[0].AsTrimString + '"');
                    LogRecord(E.Message);
                  end;
                end;
              end;
              ibsqlGenerators.Next;
            end;
          finally
            ProcLines.Free;
          end
        finally
          ibsqlNew.Free;
        end;
      finally
        ibExtract.Free;
      end;
    end;
  finally
    ibsqlGenerators.Free;
  end;

  LogRecord('Завершен перенос генераторов: '+ MyNow);
//
end;

//Перенос Функций
procedure TboDBUpgrade.TransferFunctions;
var
  ibsqlFunctions, ibsqlNew: TIBSQL;
  ibExtract: TIBExtract;
  ProcLines: TStringList;
begin
  LogRecord('Начат перенос функций: ' + MyNow);
  ibsqlFunctions := TIBSQL.Create(Self);
  try
    ibsqlFunctions.Database := FOldDatabase;
    ibsqlFunctions.Transaction := FOldTransaction;
    if not FOldTransaction.InTransaction then
      FOldTransaction.StartTransaction;
    ibsqlFunctions.SQL.Text := 'SELECT rdb$function_name FROM rdb$functions';
    ibsqlFunctions.ExecQuery;

    if ibsqlFunctions.RecordCount > 0 then
    begin
      ibExtract := TIBExtract.Create(Self);
      try
        ibExtract.Database := FOldDatabase;
        ibExtract.Transaction := FOldTransaction;

        ibsqlNew := TIBSQL.Create(Self);
        try
          ibsqlNew.Database := FNewDatabase;
          ibsqlNew.Transaction := FNewTransaction;
          ibsqlNew.ParamCheck := False;
          ProcLines := TStringList.Create;
          try
            while not ibsqlFunctions.Eof do
            begin
              if CheckUserObject(ibsqlFunctions.Fields[0].AsTrimString, ioFunction) then
              begin
                try
                  ibExtract.ExtractObject(eoFunction, ibsqlFunctions.Fields[0].AsTrimString, []);

                  ProcLines.Assign(ibExtract.Items);

                  if not FNewTransaction.InTransaction then
                    FNewTransaction.StartTransaction;

                  ibsqlNew.SQL.Assign(ProcLines);
                  ibsqlNew.ExecQuery;

                  FNewTransaction.Commit;
                  LogRecord('Перенесена функция: "' + ibsqlFunctions.Fields[0].AsTrimString + '"');
                except
                  on E: Exception do
                  begin
                    Inc(FErrorCount);
                    LogRecord('Ошибка переноса функции: "' + ibsqlFunctions.Fields[0].AsTrimString + '"');
                    LogRecord(E.Message);
                  end;
                end;
              end;
              ibsqlFunctions.Next;
            end;
          finally
            ProcLines.Free;
          end
        finally
          ibsqlNew.Free;
        end;
      finally
        ibExtract.Free;
      end;
    end;
  finally
    ibsqlFunctions.Free;
  end;

  LogRecord('Завершен перенос функций: '+ MyNow);
//
end;

//Перенос Views
procedure TboDBUpgrade.TransferViews;
var
  ibsqlViews, ibsqlNew: TIBSQL;
  ibExtract: TIBExtract;
  ProcLines: TStringList;
begin
  LogRecord('Начат перенос представлений: ' + MyNow);
  ibsqlViews := TIBSQL.Create(Self);
  try
    ibsqlViews.Database := FOldDatabase;
    ibsqlViews.Transaction := FOldTransaction;
    if not FOldTransaction.InTransaction then
      FOldTransaction.StartTransaction;
    ibsqlViews.SQL.Text := 'SELECT rdb$relation_name ' +
                           ' FROM rdb$relations ' +
                           ' WHERE not rdb$view_source IS NULL';
    ibsqlViews.ExecQuery;

    if ibsqlViews.RecordCount > 0 then
    begin
      ibExtract := TIBExtract.Create(Self);
      try
        ibExtract.Database := FOldDatabase;
        ibExtract.Transaction := FOldTransaction;

        ibsqlNew := TIBSQL.Create(Self);
        try
          ibsqlNew.Database := FNewDatabase;
          ibsqlNew.Transaction := FNewTransaction;
          ibsqlNew.ParamCheck := False;
          ProcLines := TStringList.Create;
          try
            while not ibsqlViews.Eof do
            begin
              if CheckUserObject(ibsqlViews.Fields[0].AsTrimString, ioView) then
              begin
                try
                  ibExtract.ExtractObject(eoView, ibsqlViews.Fields[0].AsTrimString, []);

                  ProcLines.Assign(ibExtract.Items);

                  if not FNewTransaction.InTransaction then
                    FNewTransaction.StartTransaction;

                  ibsqlNew.SQL.Assign(ProcLines);
                  ibsqlNew.ExecQuery;

                  FNewTransaction.CommitRetaining;

                  ibsqlNew.SQL.Text := 'GRANT ALL ON ' + ibsqlViews.Fields[0].AsTrimString + ' TO administrator';
                  ibsqlNew.ExecQuery;
                  FNewTransaction.Commit;

                  LogRecord('Перенесено представление: "' + ibsqlViews.Fields[0].AsTrimString + '"');
                except
                  on E: Exception do
                  begin
                    Inc(FErrorCount);
                    LogRecord('Ошибка переноса представления: "' + ibsqlViews.Fields[0].AsTrimString + '"');
                    LogRecord(E.Message);
                  end;
                end;
              end;
              ibsqlViews.Next;
            end;
          finally
            ProcLines.Free;
          end
        finally
          ibsqlNew.Free;
        end;
      finally
        ibExtract.Free;
      end;
    end;
  finally
    ibsqlViews.Free;
  end;

  LogRecord('Завершен перенос представлений: '+ MyNow);
//
end;

//Перенос таблиц
procedure TboDBUpgrade.TransferTables;
var
  ibsqlTables, ibsqlNew: TIBSQL;
  ibExtract: TIBExtract;
  ProcLines: TStringList;
  S, S2: String;
  I, J: Integer;
begin
  LogRecord('Начат перенос таблиц: ' + MyNow);
  ibsqlTables := TIBSQL.Create(Self);
  try
    ibsqlTables.Database := FOldDatabase;
    ibsqlTables.Transaction := FOldTransaction;
    if not FOldTransaction.InTransaction then
      FOldTransaction.StartTransaction;
    ibsqlTables.SQL.Text := 'SELECT rdb$relation_name ' +
                            ' FROM rdb$relations ' +
                            ' WHERE rdb$view_source IS NULL';
    ibsqlTables.ExecQuery;

    if ibsqlTables.RecordCount > 0 then
    begin
      ProcLines := TStringList.Create;
      try
        ibExtract := TIBExtract.Create(Self);
        try
          ibExtract.Database := FOldDatabase;
          ibExtract.Transaction := FOldTransaction;

          ibsqlNew := TIBSQL.Create(Self);
          try
            ibsqlNew.Database := FNewDatabase;
            ibsqlNew.Transaction := FNewTransaction;
            ibsqlNew.ParamCheck := False;

            while not ibsqlTables.Eof do
            begin
              if CheckUserObject(ibsqlTables.Fields[0].AsTrimString, ioTable) then
              begin
                ProcLines.Add(ibsqlTables.Fields[0].AsTrimString);
              end;
              ibsqlTables.Next;
            end;
            ibsqlTables.Close;

            I := 0;
            J := ProcLines.Count * ProcLines.Count;
            while ProcLines.Count > 0 do
            begin
              try
                ibExtract.ExtractObject(eoTable, ProcLines[I], [etTable]);
                S := ibExtract.Items.Text;
                S := StringReplace(S, '"', '', [rfReplaceAll]);
                if not FNewTransaction.InTransaction then
                   FNewTransaction.StartTransaction;
                ibsqlNew.SQL.Text := S;
                try
                  ibsqlNew.ExecQuery;
                  FNewTransaction.CommitRetaining;
                except
                  if J = 0 then
                    raise
                  else
                  begin
                    if not FNewTransaction.InTransaction then
                      FNewTransaction.Commit;
                    Dec(J);
                    S2 := ProcLines[0];
                    ProcLines.Delete(0);
                    ProcLines.Add(S2);
                    continue;
                  end;
                end;

                ibsqlNew.SQL.Text := 'GRANT ALL ON ' + ProcLines[I] + ' TO administrator';
                ibsqlNew.ExecQuery;
                FNewTransaction.Commit;

                LogRecord('Перенесена таблица: "' + ProcLines[I] + '"');
              except
                on E: Exception do
                begin
                  Inc(FErrorCount);
                  LogRecord('Ошибка переноса таблицы: "' + ProcLines[I] + '"');
                  LogRecord(E.Message);
                end;
              end;
              ProcLines.Delete(0);
            end;
          finally
            ibsqlNew.Free;
          end;
        finally
          ibExtract.Free;
        end;
      finally
        ProcLines.Free;
      end;
    end;
  finally
    ibsqlTables.Free;
  end;

  LogRecord('Завершен перенос таблиц '+ MyNow);
//
end;

//Перенос процедур
procedure TboDBUpgrade.TransferProcedures;

procedure MakeProcedure(var ALines: TStringList);
var
  Term, S: String;
  I: Integer;
  Step: Integer;
begin
//Шаг разбора скрипта
  Step := 0;
  I := 0;
  while I < ALines.Count do
  begin
    case Step of
      0:begin
          if Pos('SET TERM', UpperCase(ALines[I])) <> 0 then
          begin
            Term := Trim(Copy(ALines[I],
                         Pos('SET TERM', UpperCase(ALines[I])) + Length('SET TERM'),
                         Pos(';', ALines[I]) - Length('SET TERM') - 1));
            Step := 1;
          end;
          ALines.Delete(I)
        end;
      1:begin
          if Pos('ALTER PROCEDURE', UpperCase(ALines[I])) <> 0 then
          begin
            ALines[I] := StringReplace(ALines[I], 'ALTER PROCEDURE', 'CREATE PROCEDURE',
                                       [rfIgnoreCase]);
            inc(I);
            Step := 2;
          end
          else
            ALines.Delete(I);
        end;
      2:begin
          if Pos(Term, ALines[I]) <> 0 then
          begin
            S := ALines[I];
            Delete(S, Pos(Term, ALines[I]), 1);
            ALines[I] := S;
            Step := 3;
          end;
          Inc(I);
        end;
      3: ALines.Delete(I);
    end;
  end;
end;

var
  ibsqlProcedures, ibsqlNew, ibsqlDepend: TIBSQL;
  ibExtract: TIBExtract;
  ProcLines: TStringList;
  ProceduresList: TStringList;
  I, J: Integer;
  St: PChar;
begin
  LogRecord('Начат перенос процедур: ' + MyNow);
  ibsqlProcedures := TIBSQL.Create(Self);
  try
    ibsqlProcedures.Database := FOldDatabase;
    ibsqlProcedures.Transaction := FOldTransaction;
    if not FOldTransaction.InTransaction then
      FOldTransaction.StartTransaction;
    ibsqlProcedures.SQL.Text := 'SELECT rdb$procedure_name ' +
                            ' FROM rdb$procedures ';
    ibsqlProcedures.ExecQuery;

    if ibsqlProcedures.RecordCount > 0 then
    begin
      ProceduresList := TStringList.Create;
      try
        while not ibsqlProcedures.Eof do
        begin
          if CheckUserObject(ibsqlProcedures.Fields[0].AsTrimString, ioProcedure) then
            ProceduresList.Add(AnsiQuotedStr(AnsiUpperCase(ibsqlProcedures.Fields[0].AsTrimString), ''''));
          ibsqlProcedures.Next;
        end;
        if ProceduresList.Count > 0 then
        begin
          ibSQlDepend := TIBSQL.Create(Self);
          ibSQlDepend.Database := FOldDatabase;
          ibSQlDepend.Transaction := FOldTransaction;
          if not FOldTransaction.InTransaction then
            FOldTransaction.StartTransaction;
          ibSQLDepend.SQL.Text := 'SELECT DISTINCT rdb$dependent_name AS Name, rdb$depended_on_name AS Depended FROM rdb$dependencies ' +
                                  ' WHERE rdb$dependent_type = 5 ' +
                                  '   AND rdb$depended_on_type = 5 ' +
                                  '   AND rdb$dependent_name <> rdb$depended_on_name ' +
                                  '   AND rdb$dependent_name IN (' + ProceduresList.CommaText + ')' +
                                  '   AND rdb$depended_on_name IN (' + ProceduresList.CommaText + ')' +
                                  ' ORDER BY rdb$depended_on_name';
          ibSQLDepend.ExecQuery;

          for I := 0 to ProceduresList.Count - 1 do
          begin
            St := PChar(ProceduresList[I]);
            ProceduresList[I] := AnsiExtractQuotedStr(St,'''');
          end;

          while not ibSQLdepend.Eof do
          begin
            I := ProceduresList.IndexOf(AnsiUpperCase(ibsqlDepend.Fields[0].AsTrimString));
            J := ProceduresList.IndexOf(AnsiUpperCase(ibsqlDepend.Fields[1].AsTrimString));
            if J > I then
            begin
              ProceduresList.Move(J,I);
              { TODO : !!! }
              ibSQLdepend.Close;
              ibSQLdepend.ExecQuery;
              continue;
            end;
            ibSQLDepend.Next;
          end;

          ibExtract := TIBExtract.Create(Self);
          try
            ibExtract.Database := FOldDatabase;
            ibExtract.Transaction := FOldTransaction;

            ibsqlNew := TIBSQL.Create(Self);
            try
              ibsqlNew.Database := FNewDatabase;
              ibsqlNew.Transaction := FNewTransaction;
              ibsqlNew.ParamCheck := False;
              ProcLines := TStringList.Create;
              try
                for I := 0 to (ProceduresList.Count - 1) do
                begin
                  try
                    ibExtract.ExtractObject(eoProcedure, ProceduresList[I], []);

                    ProcLines.Assign(ibExtract.Items);
                    MakeProcedure(ProcLines);
                    if not FNewTransaction.InTransaction then
                      FNewTransaction.StartTransaction;

                    ibsqlNew.SQL.Assign(ProcLines);
                    ibsqlNew.ExecQuery;
                    FNewTransaction.CommitRetaining;
                    ibsqlNew.SQL.Text := 'GRANT EXECUTE ON PROCEDURE ' + ProceduresList[I] + ' TO administrator';
                    ibsqlNew.ExecQuery;
                    FNewTransaction.Commit;

                    LogRecord('Перенесена процедура: "' + ProceduresList[I] + '"');
                  except
                    on E: Exception do
                    begin
                      Inc(FErrorCount);
                      LogRecord('Ошибка переноса процедуры: "' + ProceduresList[I] + '"');
                      LogRecord(E.Message);
                    end;
                  end;
                end;
              finally
                ProcLines.Free;
              end
            finally
              ibsqlNew.Free;
            end;
          finally
            ibExtract.Free;
          end;
        end;  
      finally
        ProceduresList.Free;
      end
    end;
  finally
    ibsqlProcedures.Free;
  end;

  LogRecord('Завершен перенос процедур '+ MyNow);
//
end;

//Перенос триггеров
procedure TboDBUpgrade.TransferTriggers;
procedure MakeTrigger(var ALines: TStringList);
var
  Term, S: String;
  I: Integer;
  Step: Integer;
begin
//Шаг разбора скрипта
  Step := 0;
  I := 0;
  while I < ALines.Count do
  begin
    case Step of
      0:begin
          if Pos('SET TERM', UpperCase(ALines[I])) <> 0 then
          begin
            Term := Trim(Copy(ALines[I],
                         Pos('SET TERM', UpperCase(ALines[I])) + Length('SET TERM'),
                         Pos(';', ALines[I]) - Length('SET TERM') - 1));
            Step := 1;
          end;
          ALines.Delete(I)
        end;
      1:begin
          if Pos(Term, ALines[I]) <> 0 then
          begin
            S := ALines[I];
            Delete(S, Pos(Term, ALines[I]), 1);
            ALines[I] := S;
            Step := 2;
          end;
          Inc(I);
        end;
      2: ALines.Delete(I);
    end;
  end;
end;

var
  ibsqlTriggers, ibsqlNew: TIBSQL;
  ibExtract: TIBExtract;
  ProcLines: TStringList;
begin
  LogRecord('Начат перенос триггеров: ' + MyNow);
  ibsqlTriggers := TIBSQL.Create(Self);
  try
    ibsqlTriggers.Database := FOldDatabase;
    ibsqlTriggers.Transaction := FOldTransaction;
    if not FOldTransaction.InTransaction then
      FOldTransaction.StartTransaction;
    ibsqlTriggers.SQL.Text := 'SELECT rdb$trigger_name ' +
                              ' FROM rdb$triggers ';
    ibsqlTriggers.ExecQuery;
    if ibsqlTriggers.RecordCount > 0 then
    begin
      ibExtract := TIBExtract.Create(Self);
      try
        ibExtract.Database := FOldDatabase;
        ibExtract.Transaction := FOldTransaction;

        ibsqlNew := TIBSQL.Create(Self);
        try
          ibsqlNew.Database := FNewDatabase;
          ibsqlNew.Transaction := FNewTransaction;
          ibsqlNew.ParamCheck := False;
          ProcLines := TStringList.Create;
          try
            while not ibsqlTriggers.Eof do
            begin
              if CheckUserObject(ibsqlTriggers.Fields[0].AsTrimString, ioTrigger) then
              begin
                try
                  ibExtract.ExtractObject(eoTrigger, ibsqlTriggers.Fields[0].AsTrimString, []);

                  ProcLines.Assign(ibExtract.Items);
                  MakeTrigger(ProcLines);
                  if not FNewTransaction.InTransaction then
                    FNewTransaction.StartTransaction;

                  ibsqlNew.SQL.Assign(ProcLines);
                  ibsqlNew.ExecQuery;

                  FNewTransaction.Commit;
                  LogRecord('Перенесен триггер: "' + ibsqlTriggers.Fields[0].AsTrimString + '"');
                except
                  on E: Exception do
                  begin
                    Inc(FErrorCount);
                    LogRecord('Ошибка переноса триггера: "' + ibsqlTriggers.Fields[0].AsTrimString + '"');
                    LogRecord(E.Message);
                    FNewTransaction.Rollback;
                  end;
                end;
              end;
              ibsqlTriggers.Next;
            end;
          finally
            ProcLines.Free;
          end
        finally
          ibsqlNew.Free;
        end;
      finally
        ibExtract.Free;
      end;
    end;
  finally
    ibsqlTriggers.Free;
  end;

  LogRecord('Завершен перенос триггеров: '+ MyNow);
//
end;

//Перенос доменов
procedure TboDBUpgrade.TransferDomains;
var
  ibsqlDomains, ibsqlNew: TIBSQL;
  ibExtract: TIBExtract;
begin
  LogRecord('Начат перенос доменов: ' + MyNow);

  ibsqlDomains := TIBSQL.Create(Self);
  try
    ibsqlDomains.Database := FOldDatabase;
    ibsqlDomains.Transaction := FOldTransaction;
    if not FOldTransaction.InTransaction then
      FOldTransaction.StartTransaction;
    ibsqlDomains.SQL.Text := 'SELECT rdb$field_name ' +
                              ' FROM rdb$fields ';
    ibsqlDomains.ExecQuery;

    if ibsqlDomains.RecordCount > 0 then
    begin
      ibExtract := TIBExtract.Create(Self);
      try
        ibExtract.Database := FOldDatabase;
        ibExtract.Transaction := FOldTransaction;

        ibsqlNew := TIBSQL.Create(Self);
        try
          ibsqlNew.Database := FNewDatabase;
          ibsqlNew.Transaction := FNewTransaction;
          ibsqlNew.ParamCheck := False;
          while not ibsqlDomains.Eof do
          begin
            if CheckUserObject(ibsqlDomains.Fields[0].AsTrimString, ioDomain) then
            begin
              try
                ibExtract.ExtractObject(eoDomain, ibsqlDomains.Fields[0].AsTrimString, []);
                if not FNewTransaction.InTransaction then
                  FNewTransaction.StartTransaction;
                ibsqlNew.SQL.Assign(ibExtract.Items);
                ibsqlNew.ExecQuery;
                FNewTransaction.Commit;
                LogRecord('Перенесен домен: "' + ibsqlDomains.Fields[0].AsTrimString + '"');
              except
                on E: Exception do
                begin
                  Inc(FErrorCount);
                  LogRecord('Ошибка переноса домена: "' + ibsqlDomains.Fields[0].AsTrimString + '"');
                  LogRecord(E.Message);
                end;
              end;
            end;
            ibsqlDomains.Next;
          end;
        finally
          ibsqlNew.Free;
        end;
      finally
        ibExtract.Free;
      end;
    end;
  finally
     ibsqlDomains.Free;
  end;
  LogRecord('Завершен перенос доменов: '+ MyNow);
end;


//Перенос ForeignKeys
procedure TboDBUpgrade.TransferForeignKeys;
var
  IBQryForeignKeys, IBQry: TIBQuery;
  SourceTable, SourceFields, DestTable, DestFields, ForeignKey, OnDeleteKey, OnUpdateKey: String;
  ErrorList: TStringList;
  ibsqlNewConstr: TIBSQL;
  I: Integer;
begin
  LogRecord('Начат перенос внешних индексов: ' + MyNow);
  try
    FForeignKeysList.Clear;
    IBQry := TIBQuery.Create(Self);
    try
      IBQry.Database := FOldDatabase;
      IBQryForeignKeys := TIBQuery.Create(Self);
      try
        ibsqlNewConstr := TIBSQL.Create(Self);
        try
          ibsqlNewConstr.Database := FNewDatabase;
          if not FNewTransaction.InTransaction then
            FNewTransaction.StartTransaction;
          IBQryForeignKeys.Database := FOldDatabase;
          IBQryForeignKeys.SQL.Text := ' SELECT rdb$constraint_name, rdb$index_name, rdb$relation_name ' +
                                      ' FROM rdb$relation_constraints ' +
                                      ' WHERE (rdb$constraint_type = ''FOREIGN KEY'') ';
          IBQryForeignKeys.Open;
          while not IBQryForeignKeys.Eof do
          begin
            if CheckUserObject(Trim(IBQryForeignKeys.FieldByName('rdb$constraint_name').AsString), ioForeign) or CheckUserObject(Trim(IBQryForeignKeys.FieldByName('rdb$relation_name').AsString), ioTable) then
            begin
              ibsqlNewConstr.Close;
              ibsqlNewConstr.SQL.Text := 'SELECT * FROM RDB$RELATION_CONSTRAINTS WHERE '
               + 'RDB$CONSTRAINT_NAME = ' + AnsiQuotedStr(Trim(IBQryForeignKeys.Fields[0].AsString), '''') ;
              ibsqlNewConstr.ExecQuery;
              if not ibsqlNewConstr.Eof then
              begin
                LogRecord('Обнаружен внешний индекс пользователя в новой базе данных: '
                 + Trim(IBQryForeignKeys.Fields[0].AsString));
                IBQryForeignKeys.Next;
                Continue;
              end;

              CurrentObject := Trim(IBQryForeignKeys.Fields[0].AsString);
              IBQry.Close;
              IBQry.SQL.Text := 'SELECT rdb$field_name ' +
                                ' FROM rdb$index_segments ' +
                                ' WHERE rdb$index_name = ' + AnsiQuotedStr(Trim(IBQryForeignKeys.Fields[1].AsString), '''') +
                                ' ORDER BY rdb$field_position ';
              IBQry.Open;

              SourceTable := Trim(IBQryForeignKeys.Fields[2].AsString);
              SourceFields := '';
              while not IBQry.Eof do
              begin
                SourceFields := SourceFields + Trim(IBQry.Fields[0].AsString) + ',';
                IBQry.Next;
              end;
              if SourceFields > '' then
                SetLength(SourceFields, Length(SourceFields) - 1);

              //2
              IBQry.Close;
              IBQry.SQL.Text := 'SELECT rdb$foreign_key ' +
                                ' FROM rdb$indices ' +
                                ' WHERE rdb$index_name = ' + AnsiQuotedStr(Trim(IBQryForeignKeys.Fields[1].AsString), '''');
              IBQry.Open;
              ForeignKey := Trim(IBQry.Fields[0].AsString);

              //3
              IBQry.Close;
              IBQry.SQL.Text := 'SELECT rdb$relation_name ' +
                                ' FROM rdb$relation_constraints ' +
                                ' WHERE rdb$index_name = ' + AnsiQuotedStr(ForeignKey, '''');
              IBQry.Open;
              DestTable := Trim(IBQry.Fields[0].AsString);

              //4
              IBQry.Close;
              IBQry.SQL.Text := 'SELECT rdb$field_name ' +
                                ' FROM rdb$index_segments ' +
                                ' WHERE rdb$index_name = ' + AnsiQuotedStr(ForeignKey, '''') +
                                ' ORDER BY rdb$field_position';
              IBQry.Open;

              DestFields := '';

              while not IBQry.Eof do
              begin
                DestFields := DestFields + Trim(IBQry.Fields[0].AsString) + ',';
                IBQry.Next;
              end;

              if DestFields > '' then
                SetLength(DestFields, Length(DestFields) - 1);

              //5
              IBQry.Close;
              IBQry.SQL.Text := 'SELECT rdb$update_rule, rdb$delete_rule ' +
                                ' FROM rdb$ref_constraints ' +
                                ' WHERE rdb$constraint_name = ' + AnsiQuotedStr(Trim(IBQryForeignKeys.Fields[0].AsString), '''');
              IBQry.Open;

              if AnsiCompareText(Trim(IBQry.Fields[0].AsString), 'RESTRICT') = 0 then
                OnUpdateKey := ''
              else
                OnUpdateKey := ' ON UPDATE ' + Trim(IBQry.Fields[0].AsString);

              if AnsiCompareText(Trim(IBQry.Fields[1].AsString), 'RESTRICT') = 0 then
                OnDeleteKey := ''
              else
                OnDeleteKey :=  ' ON DELETE ' + Trim(IBQry.Fields[1].AsString);

              //6
              IBQry.Close;
              FForeignKeysList.Add('ALTER TABLE ' + SourceTable + ' ADD CONSTRAINT ' +
                                    Trim(IBQryForeignKeys.Fields[0].AsString) +
                                   ' FOREIGN KEY (' + SourceFields + ')' +
                                   ' REFERENCES ' + DestTable + '(' + DestFields + ')' +
                                    OnDeleteKey + OnUpdateKey);
            end;
            IBQryForeignKeys.Next;
          end;
        finally
          ibsqlNewConstr.Close;
          if ibsqlNewConstr.Transaction.InTransaction then
            ibsqlNewConstr.Transaction.Commit;
          ibsqlNewConstr.Free;
        end;
      finally
        IBQryForeignKeys.Close;
        if IBQryForeignKeys.Transaction.InTransaction then
          IBQryForeignKeys.Transaction.Commit;
        IBQryForeignKeys.Free;
      end;
    finally
      IBQry.Close;
      if IBQry.Transaction.InTransaction then
        IBQry.Transaction.Commit;
      IBQry.Free;
    end;

    ErrorList := TStringLIst.Create;
    try
      FNewDatabase.Close;
      ExecDDLScript(FTargetDatabase, FUserName, FPassword, FCharSet, FForeignKeysList, ErrorList, nil,
        FNewDatabase.SQLDialect, ReconnectToDatabase);
      FNewDatabase.Open;

      for I := ErrorList.Count - 1  downto 0 do
      begin
        Inc(FErrorCount);
        FForeignKeysList.Delete(FForeignKeysList.IndexOf(ErrorList[I]));
        LogRecord('Ошибка переноса FOREIGN KEY: "' + ErrorList[I] + '"');
      end;

      for I := FForeignKeysList.Count - 1  downto 0 do
      begin
        LogRecord('Перенесен FOREIGN KEY: "' + FForeignKeysList[I] + '"');
      end;
    finally
      ErrorList.Free;
    end;
      LogRecord('Завершен перенос внешних индексов: ' + MyNow);
  except
    Inc(FErrorCount);
    LogRecord('Перенос внешних индексов завершен с ошибкой');
  end;

end;

procedure TboDBUpgrade.TransferIndices;
var
  IBSQLWork, IBSQLIndex: TIBSQL;
  Fields, SortMode: String;
  ErrorList: TStringList;
  I: Integer;
begin
  LogRecord('Начат перенос индексов: ' + MyNow);
  IBSQLWork := TIBSQL.Create(Self);
  try
    IBSQLIndex := TIBSQL.Create(Self);
    try
      FIndicesList.Clear;
      ibSQLWork.Database := FOldDatabase;
      IBSQLIndex.Database := FOldDatabase;

      if not ibSQLWork.Transaction.InTransaction then
        ibSQLWork.Transaction.StartTransaction;

      if not IBSQLIndex.Transaction.InTransaction then
        IBSQLIndex.Transaction.StartTransaction;

      IBSQLIndex.SQL.Text := 'SELECT rdb$index_name, rdb$relation_name' +
                             ' FROM RDB$INDICES ind ' +
                             ' WHERE NOT EXISTS(SELECT * FROM RDB$RELATION_CONSTRAINTS ' +
                             '                  WHERE RDB$INDEX_NAME = ind.RDB$INDEX_NAME) ';
      IBSQLIndex.ExecQuery;

      while not IBSQLIndex.Eof do
      begin
        if CheckUserObject(IBSQLIndex.Fields[0].AsTrimString, ioIndexes) then
        begin
          ibSQLWork.Close;
          ibSQLWork.SQL.Text := 'SELECT rdb$field_name, rdb$index_type ' +
                            ' FROM rdb$index_segments rs, rdb$indices ri' +
                            ' WHERE rs.rdb$index_name = ' + AnsiQuotedStr(IBSQLIndex.Fields[0].AsTrimString, '''') +
                            '   AND (rs.rdb$index_name = ri.rdb$index_name) ' +
                            ' ORDER BY rdb$field_position';
          ibSQLWork.ExecQuery;
          Fields := '';

          if ibSQLWork.Fields[1].AsInteger = 1 then
            SortMode := 'DESC'
          else
            SortMode := 'ASC';

          while not ibSQLWork.EOF do
          begin
            Fields := Fields + ibSQLWork.Fields[0].AsTrimString + ',';
            ibSQLWork.Next;
          end;

          SetLength(Fields, Length(Fields) - 1);

          FIndicesList.Add('CREATE ' + SortMode +
                           ' INDEX ' + IBSQLIndex.Fields[0].AsTrimString +
                           ' ON ' + IBSQLIndex.Fields[1].AsTrimString +
                           ' (' + Fields + ')');
        end;
        IBSQLIndex.Next;
      end;
    finally
      IBSQLIndex.Close;
      if ibSQLWork.Transaction.InTransaction then
        IBSQLIndex.Transaction.Commit;
      IBSQLIndex.Free;
    end;
  finally
    ibSQLWork.Close;
    if ibSQLWork.Transaction.InTransaction then
      ibSQLWork.Transaction.Commit;
    ibSQLWork.Free;
  end;

  if FIndicesList.Count > 0 then
  begin
    ErrorList := TStringList.Create;
    try
      FNewDatabase.Close;
      ExecDDLScript(FTargetDatabase, FUserName, FPassword, FCharSet, FIndicesList, ErrorList, nil,
      FNewDatabase.SQLDialect, ReconnectToDatabase);
      FNewDatabase.Open;
      for I := ErrorList.Count - 1 downto 0 do
      begin
        Inc(FErrorCount);
        LogRecord('Ошибка при переносе индекса: "' + ErrorList[I] + '"');
        FIndicesList.Delete(FIndicesList.IndexOf(ErrorList[I]));
      end;
      for I := FIndicesList.Count - 1 downto 0 do
      begin
        LogRecord('Перенесен индекс: "' + FIndicesList[I] + '"');
      end;
    finally
      ErrorList.Free;
    end;
  end;
  LogRecord('Завершен перенос индексов: ' + MyNow);
end;

procedure TboDBUpgrade.TransferFields;
var
  I, J, K: Integer;
  OldFields, NewFields: TStringList;
  IBSQLOld, IBSQLNew, q: TIBSQL;
  FieldType: String;
begin
  ProcessState := psReadingStruct;

  LogRecord('Начат перенос полей созданных пользователем: ' + MyNow);
  try
    OldFields := TStringList.Create;
    try
      NewFields := TStringList.Create;
      try
        IBSQLOld := TIBSQL.Create(Self);
        q := TIBSQL.Create(Self);
        try
          IBSQLOld.Database := FOldDatabase;
          q.Database := FOldDatabase;
          IBSQLNew := TIBSQL.Create(Self);
          try
            IBSQLNew.Database := FNewDatabase;

            if not IBSQLNew.Transaction.InTransaction then
              IBSQLNew.Transaction.StartTransaction;

            if not IBSQLOld.Transaction.InTransaction then
              IBSQLOld.Transaction.StartTransaction;

            for I := 0 to FUpgradeTables.Count - 1 do
            begin

              if CheckUserObject(AnsiUpperCase(FUpgradeTables[I]), ioField) then
                Continue;

              OldFields.Clear;
              NewFields.Clear;

              FOldDatabase.GetFieldNames(FUpgradeTables[I], OldFields);
              FNewDatabase.GetFieldNames(FUpgradeTables[I], NewFields);
              for J := 0 to NewFields.Count - 1 do
              begin
                K := OldFields.IndexOf(NewFields[J]);
                if K <> -1 then
                begin
                  OldFields.Delete(K);
                  if OldFields.Count = 0 then
                    Break;
                end;
              end;

              for J := OldFields.Count - 1 downto 0 do
              begin
                if Pos(UserPrefix, OldFields[J]) <> 1 then
                begin
                  OldFields.Delete(J);
                end;
              end;

              while OldFields.Count > 0 do
              begin
                J := 0;
                if Pos(UserPrefix, OldFields[J]) = 1 then
                begin
                  IBSQLOld.Close;
                  IBSQLOld.SQL.Text := 'SELECT f.RDB$FIELD_NAME AS dname, f.RDB$FIELD_TYPE AS ftype, f.RDB$FIELD_LENGTH AS flength, ' +
                                       '       f.RDB$FIELD_SCALE AS fscale, f.RDB$SEGMENT_LENGTH AS fsegment, ' +
                                       '       f.RDB$NULL_FLAG AS fnullflag, f.RDB$COMPUTED_SOURCE as computedsource, relf.RDB$DEFAULT_SOURCE AS ds1, f.RDB$DEFAULT_SOURCE AS ds2, f.RDB$VALIDATION_SOURCE as vs ' +
                                       ' FROM RDB$RELATION_FIELDS relf, ' +
                                       '      RDB$FIELDS f '+
                                       ' WHERE (relf.RDB$RELATION_NAME = '+ AnsiQuotedStr(FUpgradeTables[I], '''') + ') ' +
                                       '   AND (relf.RDB$FIELD_NAME = ' + AnsiQuotedStr(OldFields[J], '''') + ') ' +
                                       '   AND (f.RDB$FIELD_NAME = relf.RDB$FIELD_SOURCE)';
                  IBSQLOld.ExecQuery;

                  if not IBSQLOld.EOF then
                  begin
                    q.Close;
                    q.SQL.Text := 'SELECT rdb$field_name FROM RDB$DEPENDENCIES ' +
                      'WHERE rdb$dependent_name = :DN AND rdb$depended_on_name = :ON ';
                    q.ParamByName('dn').AsString := IBSQLOld.FieldByName('dname').AsTrimString;
                    q.ParamByName('on').AsString := FUpgradeTables[I];
                    q.ExecQuery;
                    if not q.EOF then
                    begin
                      if OldFields.IndexOf(q.Fields[0].AsTrimString) > 0 then
                      begin
                        OldFields.Exchange(0, OldFields.IndexOf(q.Fields[0].AsTrimString));
                        q.Close;
                        continue;
                      end;
                    end;
                    q.Close;

                    if IBSQLOld.FieldByName('computedsource').AsString > '' then
                    begin
                      FieldType := 'COMPUTED BY ' + IBSQLOld.FieldByName('computedsource').AsString;
                    end else
                    begin
                      if Pos('RDB$', IBSQLOld.FieldByName('dname').AsTrimString) <> 1 then
                        FieldType := IBSQLOld.FieldByName('dname').AsTrimString
                      else
                        case IBSQLOld.FieldByName('ftype').AsInteger of
                          IBFT_SMALLINT: FieldType := 'SMALLINT';
    //                      7: FieldType := 'NUMERIC(4,' + IntToStr(Abs(IBSQLOld.Fields[2].AsInteger)) + ')';
                          //INTEGER
                          IBFT_INTEGER: FieldType := 'INTEGER';
    //                      8: FieldType := 'NUMERIC(9,' + IntToStr(Abs(IBSQLOld.Fields[2].AsInteger)) + ')';
                          IBFT_QUAD: FieldType := 'QUAD';
                          IBFT_FLOAT: FieldType := 'FLOAT';
                          IBFT_D_FLOAT: FieldType := 'D_FLOAT';
                          IBFT_DATE: FieldType := 'DATE';
                          IBFT_TIME: FieldType := 'TIME';
                          IBFT_CHAR: FieldType := 'CHAR(' + IBSQLOld.FieldByName('flength').AsTrimString + ')';
                          IBFT_INT64: FieldType := 'BIGINT';
                          //DOUBLE
                          IBFT_DOUBLE: FieldType := 'NUMERIC(15, ' + IntToStr(Abs(IBSQLOld.FieldByName('fscale').AsInteger)) + ')';
                          IBFT_TIMESTAMP: FieldType := 'TIMESTAMP';
                          IBFT_VARCHAR: FieldType := 'VARCHAR(' + IBSQLOld.FieldByName('flength').AsTrimString + ')';
                          IBFT_CSTRING: FieldType := 'CSTRING';
                          IBFT_BLOB: FieldType := 'BLOB(' + IBSQLOld.FieldByName('fsegment').AsTrimString + ')';
                        else
                          ShowMessage('Неизвестный тип поля. Обратитесь к разработчикам');
                          ProcessState := psError;
                          Exit;
                        end;

                      if IBSQLOld.FieldByName('ds1').AsTrimString > '' then
                      begin
                        FieldType := FieldType + ' ' + IBSQLOld.FieldByName('ds1').AsTrimString;
                      end else
                      if IBSQLOld.FieldByName('ds2').AsTrimString > '' then
                      begin
                        FieldType := FieldType + ' ' + IBSQLOld.FieldByName('ds2').AsTrimString;
                      end;

                      if IBSQLOld.FieldByName('fnullflag').AsInteger = 1 then
                        FieldType := FieldType + ' NOT NULL ';

                      if IBSQLOld.FieldByName('vs').AsTrimString > '' then
                      begin
                        FieldType := FieldType + ' ' + StringReplace(IBSQLOld.FieldByName('vs').AsTrimString, 'VALUE', OldFields[J], [rfReplaceAll, rfIgnoreCase]) ;
                      end;
                    end;

                    IBSQLNew.Close;
                    IBSQLNew.SQL.Text := 'ALTER TABLE ' + FUpgradeTables[I] +
                            ' ADD ' + OldFields[J] + ' ' + FieldType;

                    IBSQLNew.Transaction.Commit;
                    IBSQLNew.Transaction.StartTransaction;

                    try
                      IBSQLNew.ExecQuery;
                      LogRecord('Перенесено поле, созданное пользователем');
                      LogRecord('  Таблица: ' + FUpgradeTables[I]);
                      LogRecord('  Поле: ' + OldFields[J]);
                      LogRecord('  Тип: ' + FieldType);
                    except
                      Inc(FErrorCount);
                      LogRecord('Ошибка при переносе поля созданного пользователем');
                      LogRecord('  Таблица: ' + FUpgradeTables[I]);
                      LogRecord('  Поле: ' + OldFields[J]);
                      LogRecord('  Тип: ' + FieldType);
                    end;
                  end;
                end;
                OldFields.Delete(J);
              end;
            end;
          finally
            IBSQLNew.Close;
            if IBSQLNew.Transaction.InTransaction then
              IBSQLNew.Transaction.Commit;
            IBSQLNew.Free;
          end;
        finally
          IBSQLOld.Close;
          if IBSQLOld.Transaction.InTransaction then
            IBSQLOld.Transaction.Commit;
          IBSQLOld.Free;
          q.Free;
        end;
      finally
        NewFields.Free;
      end;
    finally
      OldFields.Free;
    end;
  except
    LogRecord('Была ошибка при переносе полей созданных пользователем!');
  end;
  LogRecord('Завершен перенос полей созданных пользователем: ' + MyNow);
end;

// Считывает версию новой базы данных
function TboDBUpgrade.ReadNewDatabaseVersion: String;
var
  F: TextFile;
  S: String;
begin
  try
    AssignFile(F, IncludeTrailingBackslash(ExtractFilePath(FBkFileName)) + DBUpgradeVersionFileName);
    Reset(F);
    try
      Read(F, S);
      Result := S;
    finally
      CloseFile(F);
    end;
    LogRecord('Номер версии новой базы данных: ' + Result);
  except
    Inc(FErrorCount);
    LogRecord('Не найден файл с версией новой базы данных');
    ProcessState := psError;
    raise EboDBUpgradeException.Create('Не найден файл с версией новой базы данных');
  end;
end;

// Считывает версию старой базы данных
function TboDBUpgrade.ReadOldDatabaseVersion: String;
var
  IBSP: TIBStoredProc;
begin
  try
    if not FOldDatabase.DefaultTransaction.InTransaction then
      FOldDatabase.DefaultTransaction.StartTransaction;
    IBSP := TIBStoredProc.Create(nil);
    try
      IBSP.Database := FOldDatabase;
      IBSP.Transaction := FOldDatabase.DefaultTransaction;
      try
        IBSP.StoredProcName := 'FIN_P_VER_GETDBVERSION';
        IBSP.ExecProc;
        Result := IBSP.ParamByName('versionstring').AsString;
      except
        LogRecord('Предупреждение! Невозможно получить версию текущей базы данных');
        Result := '';
      end;
    finally
      IBSP.Free;
    end;
    LogRecord('Номер версии исходной базы данных: ' + Result);
  except
    on E: Exception do
    begin
      Inc(FErrorCount);
      LogRecord('Ошибка: Невозможно получить версию текущей базы данных');
      LogRecord(E.Message);
      ProcessState := psError;
      raise EboDBUpgradeException.Create('Невозможно получить версию текущей базы данных');
    end;
  end;
{ TODO : зачем тут второй эксцепт? }
end;

//
procedure TboDBUpgrade.ShutDownNew;
begin
  LogRecord('Начат перевод новой базы в однопользовательский режим: ' + MyNow);
  try
    FNewDataBase := TIBDatabase.Create(Self);
    if FServerName > '' then
      FNewDataBase.DatabaseName := FServerName + ':' + FTargetDatabase
    else
      FNewDataBase.DatabaseName := FTargetDatabase;
    FNewDataBase.SQLDialect := FSQLDialect;

    FNewDataBase.Params.Add('user_name=' + FUserName);
    FNewDataBase.Params.Add('password=' + FPassword);
    FNewDataBase.Params.Add('lc_ctype=' + FCharSet);
    FNewDataBase.LoginPrompt := False;

    FNewTransaction := TIBTransaction.Create(Self);
    FNewTransaction.Params.Add('nowait');
    FNewTransaction.Params.Add('consistency');
    {
    FNewTransaction.Params.Add('read_committed');
    FNewTransaction.Params.Add('rec_version');
    FNewTransaction.Params.Add('nowait');
    }
    FNewTransaction.DefaultDatabase := FNewDatabase;
    FNewDatabase.DefaultTransaction := FNewTransaction;
    try
      with TIBConfigService.Create(Self) do
      try
        Protocol := FProtocol;
        ServerName := FServerName;
        Params.Add('user_name=' + FUserName);
        Params.Add('password=' + FPassword);
        LoginPrompt := False;
        Active := True;
        try
          DatabaseName := FTargetDatabase;
          LogRecord(DatabaseName);

          SetReadonly(False);
          while IsServiceRunning do Sleep(5);
          SetAsyncMode(True); {!!!}
          while IsServiceRunning do Sleep(5);
          SetPageBuffers(4096);
          while IsServiceRunning do Sleep(5);
          ShutdownDatabase(Forced, 0);
          while IsServiceRunning do Sleep(5);
        finally
          Active := False;
        end;
      finally
        Free;
      end;
    except
      Inc(FErrorCount);
      LogRecord('Ошибка при переводе новой базы в однопользовательский режим');
      ProcessState := psError;
    end;

    FNewDatabase.Open;
    FCurrentStep := 5;
    LogRecord('Завершен перевод новой базы в однопользовательский режим: ' + MyNow);
  except
    Inc(FErrorCount);
    LogRecord('Во время перевода новой версии базы в однопользовательский режим произошла ошибка');
    ProcessState := psError;
  end;
end;

// Восстанавливает новую базу данных из bk файла
procedure TboDBUpgrade.RestoreDatabase(const ADatabaseName, AnUserName, APassword,
                                     ABkFileName: String);
var
  IBRestore: TIBRestoreService;

begin
  if (AnsiCompareText(FServerName, FThisComputerName) = 0) and (not FileExists(AbkFileName)) then
  begin
    Inc(FErrorCount);
    LogRecord('Ошибка: Файл с архивом новой версии базы данных не найден. Имя файла: ' + AbkFileName);
    ProcessState := psError;
  end else
  begin
    LogRecord('Начато восстановление новой базы данных: ' + MyNow);
    try
      IBRestore := TIBRestoreService.Create(Self);
      try
        IBRestore.Protocol := FProtocol;
        IBRestore.ServerName := FServerName;
        IBRestore.Params.Add('user_name=' + AnUserName);
        IBRestore.Params.Add('password=' + APassword);
        IBRestore.LoginPrompt := False;

        LogRecord('Имя файла архива: ' + ABkFileName);
        LogRecord('Имя файла базы данных: ' + ADatabaseName);

        IBRestore.Active := True;
        try
          IBRestore.DatabaseName.Add(ADatabaseName);
          IBRestore.BackupFile.Add(ABkFileName);
          IBRestore.Options := [Replace, {UseAllSpace,} CreateNewDB];
          IBRestore.PageSize := 8192;
          IBRestore.PageBuffers := GetPageBuffers(IBRestore.PageSize);
          IBRestore.Verbose := False;
          IBRestore.ServiceStart;
          while not IBRestore.EOF do
            LogRecord(IBRestore.GetNextLine);
          LogRecord('Завершено восстановление базы данных: ' + MyNow);
        finally
          IBRestore.Active := False;
        end;
      finally
        IBRestore.Free;
        FCurrentStep := 4;
      end;
    except
  { TODO 2 -oандрэй -cзрабіць : Трэба яшчэ раз прагледзіць што робіцца калі немагчыма стварыць новую базу }
      Inc(FErrorCount);
      LogRecord('Во время восстановления новой версии базы данных произошла ошибка');
      ProcessState := psError;
    end;
  end;
end;

// Делаем архивную копию
procedure TboDBUpgrade.BackUpDatabase;
var
  IBBackUp: TIBBackupService;
begin

  if MessageBox(0, 'Создать архивную копию существующей базы данных?',
    'Внимание', MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDNO then
  begin
    LogRecord('Оператор отказался от создания архивной копии базы данных.');
    FOldBKFileName := '';
    exit;
  end;

  LogRecord('Начато создание архивной копии данных: ' + MyNow);
  try
    IBBackUp := TIBBackUpService.Create(Self);
    try
      IBBackUp.Protocol := FProtocol;
      IBBackUp.ServerName := FServerName;
      IBBackUp.Params.Add('user_name=' + FUserName);
      IBBackUp.Params.Add('password=' + FPassword);
      IBBackUp.LoginPrompt := False;
      IBBackUp.Options := [NoGarbageCollection]; // см комментарий к исходной базе
      FOldBKFileName := FArchiveDirectory + Format(ArchiveFileName, [FormatDateTime(ArchiveFileDateTimeMask, Now)]);

      while not ForceDirectories(FArchiveDirectory) do
      begin
        MessageBox(0, PChar('Ошибка создания архивной копии:' +  #10#13 +
                   FOldBKFileName +  #10#13 +
                   'Укажите путь для создания архивной копии.'),
         'Внимание', MB_OK);
        LogRecord('Ошибка создания архивной копии: ' + FOldBKFileName);

        SelectDirectory(FArchiveDirectory, [sdAllowCreate, sdPerformCreate, sdPrompt], 0);

        FOldBKFileName := FArchiveDirectory + Format(ArchiveFileName, [FormatDateTime(ArchiveFileDateTimeMask, Now)]);
      end;

      LogRecord('Имя архивного файла: ' + FOldBKFileName);

      IBBackUp.Active := True;
      try
        IBBackUp.DatabaseName := FSourceDatabase;
        IBBackUp.BackupFile.Add(FOldBKFileName);
        IBBackUp.BufferSize := 4096;
        IBBackUp.ServiceStart;
        while not IBBackUp.EOF do
          LogRecord(IBBackUp.GetNextLine);
      finally
        IBBackUp.Active := False;
      end;
    finally
      IBBackUp.Free;
    end;
  except
    Inc(FErrorCount);
    LogRecord('В процессе создания архивной копии произошел сбой.');

    if MessageBox(0,
      'В процессе создания архивной копии исходной базы данных произошел сбой. '#10#13 +
      'Продолжать без создания архивной копии? '#10#13 +
      'Внимание! Вы рискуете потерять все данные!',
      'Внимание',
      MB_ICONQUESTION or MB_YESNO) = IDNO then
    begin
      ProcessState := psError;
      FOldBKFileName := '';
    end;
  end;

  if ProcessState <> psError then
    LogRecord('Завершено создание архивной копии данных: ' + MyNow);
end;

// Переносит значения генераторов
procedure TboDBUpgrade.UpgradeGenerators;
var
  NewSQL, OldSQL, GenSQL: TIBSQL;
begin
  ProcessState := psUpgradeGenerators;
  LogRecord('Начат перенос генераторов ');

  try
    GenSQL := TIBSQL.Create(Self);
    NewSQL := TIBSQL.Create(Self);
    OldSQL := TIBSQL.Create(Self);
    try
      GenSQL.Database := FNewDatabase;
      GenSQL.Transaction := FNewDatabase.DefaultTransaction;
      if not GenSQL.Transaction.InTransaction then
        GenSQL.Transaction.StartTransaction;

      NewSQL.Database := FNewDatabase;
      NewSQL.Transaction := FNewDatabase.DefaultTransaction;
      if not NewSQL.Transaction.InTransaction then
        NewSQL.Transaction.StartTransaction;

      OldSQL.Database := FOldDatabase;
      OldSQL.Transaction := FOldTransaction;
      if not FOldTransaction.InTransaction then
        FOldTransaction.StartTransaction;

      GenSQL.SQL.Text := 'SELECT generator_name FROM gd_v_user_generators';
      GenSQL.ExecQuery;

      while not GenSQL.EOF do
      begin
        CurrentObject := GenSQL.Fields[0].AsTrimString;
        try
          OldSQL.Close;
          OldSQL.SQL.Text := 'SELECT GEN_ID(' + CurrentObject + ',0) FROM rdb$database';
          OldSQL.ExecQuery;
        except
          //Если генератора не было в старой базе пропускаем его
          GenSQL.Next;
          Continue;
        end;

        NewSQL.Close;
        NewSQL.SQL.Text := 'SET GENERATOR ' + CurrentObject + ' TO ' + OldSQL.Fields[0].AsTrimString;
        try
          NewSQL.ExecQuery;
        except
          Inc(FErrorCount);
          LogRecord('Ошибка: Значение генератора ' + CurrentObject + ' не восстановлено в новой базе');
        end;
        GenSQL.Next;
      end;
    finally
      CurrentObject := '';

      FOldTransaction.Commit;
      FNewTransaction.Commit;

//      GenSQL.Transaction.Commit;
      GenSQL.Free;
//      NewSQL.Transaction.Commit;
      NewSQL.Free;
//      OldSQL.Transaction.Commit;
      OldSQL.Free;
    end;
    LogRecord('Завершен перенос генераторов');
  except
    Inc(FErrorCount);
    LogRecord('Ошибка при переносе генераторов ');
  end;
end;

procedure TboDBUpgrade.GrantUser;
var
  ibsqlSource, ibsqlTarget: TIBSQL;
begin
  ibsqlSource := TIBSQL.Create(Self);
  try
    ibsqlSource.Database := FOldDatabase;
    ibsqlSource.Transaction := FOldTransaction;
    if not FOldTransaction.InTransaction then
      FOldTransaction.StartTransaction;
    ibsqlTarget := TIBSQL.Create(Self);
    try
      LogRecord('Начат перенос прав пользователей: ' + MyNow);
      ibsqlTarget.Database := FNewDatabase;
      ibsqlTarget.Transaction := FNewTransaction;
      if not FNewTransaction.InTransaction then
        FNewTransaction.StartTransaction;
      ibsqlSource.SQL.Text := 'SELECT RDB$USER FROM RDB$USER_PRIVILEGES WHERE RDB$RELATION_NAME = '''
       + DefaultSQL_Role_Name + '''';
      try
        ibsqlSource.ExecQuery;
        while not ibsqlSource.Eof do
        begin
          ibsqlTarget.Close;
          ibsqlTarget.SQL.Text := 'GRANT ' + DefaultSQL_Role_Name + ' TO '
           + ibsqlSource.Fields[0].AsTrimString;
          try
            ibsqlTarget.ExecQuery;
          except
            on E: Exception do
            begin
              LogRecord('Ошибка при переносе прав пользователя: ' + ibsqlSource.Fields[0].AsTrimString);
              LogRecord(E.Message);
              exit;
            end;
          end;
          ibsqlSource.Next;
        end;
      except
        on E: Exception do
          LogRecord(E.Message);
      end;
    finally
      LogRecord('Завершен перенос прав пользователей: ' + MyNow);
      if FNewTransaction.InTransaction then
        FNewTransaction.Commit;
      ibsqlTarget.Free;
    end;
  finally
    if FOldTransaction.InTransaction then
      FOldTransaction.Commit;
    ibsqlSource.Free;
  end;
end;

procedure TboDBUpgrade.UpgradeTable(const ATableName: String);
var
  Source, Target: TIBSQL;
  ibdsTarget: TIBDataSet;
  CounterSuccess, CounterFail, I, P, {K,} LeftBorder, RightBorder, BorderCount: Integer;
  List: TStringList;
  S1, S2: String;
  TreeFlag, WasLB, WasRB: Boolean;
begin
  List := TStringList.Create;
  try
    FNewDatabase.GetTableNames(List, False);
    if (StrIPos(ATableName + #13, List.Text) = 0) and
       (StrIPos(ATableName + #10, List.Text) = 0) then
    begin
      // такой табліцы больш няма
      // няма чаго пераносіць
      LogRecord('Таблицы нет в новой базе данных: ' + CurrentObject);
      exit;
    end;
  finally
    List.Free;
  end;

  CounterSuccess := 0;
  CounterFail := 0;

  CurrentObject := ATableName;
  ProcessState := psUpgradeTable;

  Source := TIBSQL.Create(nil);
  Target := TIBSQL.Create(nil);
  ibdsTarget := TIBDataSet.Create(nil);
  try
    Source.Database := FOldDatabase;
    Source.Transaction := FOldTransaction;

    Target.Database := FNewDatabase;
    Target.Transaction := FNewTransaction;

    ibdsTarget.Database := FNewDatabase;
    ibdsTarget.Transaction := FNewTransaction;

    if not FOldTransaction.InTransaction then
      FOldTransaction.StartTransaction;

    if not FNewTransaction.InTransaction then
      FNewTransaction.StartTransaction;

    LogRecord('Начат перенос записей из таблицы: ' + CurrentObject);

    Source.Close;
    Source.SQL.Text := 'SELECT * FROM ' + ATableName;
    Source.ExecQuery;

    (*
    Target.Close;
    Target.SQL.Text := 'SELECT * FROM ' + ATableName;
    Target.ExecQuery;
    *)

    ibdsTarget.Close;
    ibdsTarget.SelectSQL.Text := 'SELECT * FROM ' + ATableName;
    ibdsTarget.Prepare;
    Assert(ibdsTarget.FieldDefs.Count > 0, 'Немагчыма атрымаць дэфініцыі палёў у таргет табліцы');

    LeftBorder := -1;
    RightBorder := -1;
    S1 := '';
    S2 := '';
    BorderCount := 1;
    P := 0;
    WasRB := False;
    WasLB := False;
    for I := 0 to Source.Current.Count - 1 do
    begin
      if UpperCase(Source.Fields[I].Name) = 'LB' then
        WasLB := True;

      if UpperCase(Source.Fields[I].Name) = 'RB' then
        WasRB := True;

      if ibdsTarget.FieldDefs.IndexOf(Source.Fields[I].Name) >= 0 then
      begin
        if not (faReadOnly in ibdsTarget.FieldDefs.Find(Source.Fields[I].Name).Attributes) then
        begin
          S1 := S1 + Source.Fields[I].Name + ',';
          S2 := S2 + ':' + Source.Fields[I].Name + ',';
          if UpperCase(Source.Fields[I].Name) = 'LB' then
            LeftBorder := P;
          if UpperCase(Source.Fields[I].Name) = 'RB' then
            RightBorder := P;
          Inc(P);
        end;
      end;

      (*
      for K := 0 to Target.Current.Count - 1 do
        if Source.Fields[I].Name = Target.Fields[K].Name then
        begin
          S1 := S1 + Source.Fields[I].Name + ',';
          S2 := S2 + ':' + Source.Fields[I].Name + ',';
          if UpperCase(Target.Fields[K].Name) = 'LB' then
            LeftBorder := P;
          if UpperCase(Target.Fields[K].Name) = 'RB' then
            RightBorder := P;
          Inc(P);
          break;
        end;
      *)
    end;

    if S1 > '' then
    begin
      SetLength(S1, Length(S1) - 1);
      SetLength(S2, Length(S2) - 1);
    end;

    TreeFlag := (LeftBorder > -1) and (RightBorder > -1)
      and (not WasRB) and (not WasLB);

    if FMergeTables.IndexOf(ATableName) = -1 then
    begin
      if FExcludeTables.IndexOf(ATableName) = -1 then
      begin
        if Target.RecordCount > 0 then
          LogRecord(' ПРЕДУПРЕЖДЕНИЕ: обнаружены данные в таблице ' + ATableName);
      end;
    end;

    Source.Close;
    Source.SQL.Text := 'SELECT ' + S1 + ' FROM ' + ATableName;
    Source.Prepare;

    Target.Close;
    Target.SQL.Text := 'INSERT INTO ' + ATableName + ' (' + S1 + ') VALUES (' + S2 + ')';
    Target.Prepare;

    Source.ExecQuery;
    while not Source.EOF do
    begin
      try
        for I := 0 to Target.Params.Count - 1 do
        begin
          if Source.FieldByName(Target.Params[I].Name).IsNull then
            Target.Params[I].IsNull := True
          else
            if Target.Params[I].SQLType = Source.FieldByName(Target.Params[I].Name).SQLType then
              Target.Params[I].Assign(Source.FieldByName(Target.Params[I].Name))
            else
              Target.Params[I].AsTrimString := Source.FieldByName(Target.Params[I].Name).AsTrimString;
        end;

        if TreeFlag then
        begin
          if Target.Params[LeftBorder].IsNull then
            Target.Params[LeftBorder].AsInteger := BorderCount;
          if Target.Params[RightBorder].IsNull then
            Target.Params[RightBorder].AsInteger := BorderCount;
          Inc(BorderCount);
        end;

        Target.ExecQuery;

        Inc(CounterSuccess);

        if CounterSuccess mod 1000 = 0 then
        begin
          FNewTransaction.Commit;
          FNewTransaction.StartTransaction;
          LogRecord('  Перенесено: ' + IntToStr(CounterSuccess) + ', ' + MyNow(False));
          Application.ProcessMessages;
        end;

      except
        on E: Exception do
        begin
          LogRecord('Ошибка при переносе записи: ' + Source.Fields[0].AsTrimString);
          LogRecord(E.Message);
          Inc(CounterFail);
        end;
      end;

      Source.Next;
    end;
  finally
    LogRecord('  Перенесено записей:    ' + IntToStr(CounterSuccess));
    if CounterFail > 0 then
      LogRecord('  Не перенесено записей: ' + IntToStr(CounterFail));

    CurrentObject := '';

    Source.Close;
    if FOldTransaction.InTransaction then
      FOldTransaction.Commit;
    Source.Free;

    Target.Close;
    if FNewTransaction.InTransaction then
      FNewTransaction.Commit;
    Target.Free;

    ibdsTarget.Free;
  end;
end;

// Заносит запись в лог файл
procedure TboDBUpgrade.LogRecord(const AString: String);
var
  FSD: TSaveDialog;
  FLogFile: TextFile;
begin
  if Assigned(FUpgradeLog) then
  begin
    FUpgradeLog(AString);
    Exit;
  end;

  try
    if TestStop and (FLogFileName = '') then
      Exit;
    if FLogFileName = '' then
    begin
      FLogFileName := IncludeTrailingBackslash(ExtractFilePath(SourceDatabase)) + 'GDBASE_UPGRADE.LOG';

      if FileExists(FLogFileName) then
      begin
        {
        MessageBox(0, 'Файл GDBASE_UPGRADE.LOG уже существует', 'Внимание',
          MB_ICONEXCLAMATION or MB_OK);
        }
        FSD := TSaveDialog.Create(Self);
        try
          FSD.FileName := FLogFileName;
          FSD.Options := [ofOverwritePrompt, ofExtensionDifferent, ofPathMustExist];

          while not FSD.Execute do
          begin
            if MessageBox(0, 'Вы хотите прервать процесс апгрейда?', 'Внимание',
              MB_YESNO or MB_ICONEXCLAMATION) = mrYes then
            begin
              ProcessState := psUserCanceled;
              FLogFileName := '';
              exit;
            end;
          end;
          FLogFileName := FSD.FileName;
        finally
          FSD.Free;
        end;
      end;

      if not DirectoryExists(ExtractFilePath(FLogFileName)) then
        ForceDirectories(ExtractFilePath(FLogFileName));

      AssignFile(FLogFile, FLogFileName);
      try
        Rewrite(FLogFile);
        CloseFile(FLogFile);
      except
        LogError('Ошибка создания Log файла');
      end;
    end;

    AssignFile(FLogFile, FLogFileName);
    try
      Append(FLogFile);
      WriteLn(FLogFile, AString);
      CloseFile(FLogFile);
    except
      LogError('Ошибка записи в Log файл');
    end;

  finally
    if Assigned(FOnLogRecord) then
      FOnLogRecord(Self, AString);
  end;
end;

// Устанавливает текущий статус апгрейда
procedure TboDBUpgrade.SetProcessState(const AProcessState: TboUpgradeProcessState);
begin
  FProcessState := AProcessState;
  DoProcessUpgrade;
end;

// Вызов метода OnProgressUpdate
procedure TboDBUpgrade.DoProcessUpgrade;
begin
  if Assigned(FOnProgressUpgrade) then
    FOnProgressUpgrade(Self);
  Application.ProcessMessages;
end;

procedure TboDBUpgrade.DeactivateTriggers;
var
  IBSQLTriggers: TIBSQL;
  DelList, ErrorList: TStringList;
  I: Integer;
begin
  ProcessState := psDeletingStruct;
  LogRecord('Начато деактивирование триггеров: ' + MyNow);
  try
    DelList := TStringList.Create;
    try
      FTriggersList.Clear;
      IBSQLTriggers := TIBSQL.Create(Self);
      try
        IBSQLTriggers.Database := FNewDatabase;
        if not IBSQLTriggers.Transaction.InTransaction then
          IBSQLTriggers.Transaction.StartTransaction;
        IBSQLTriggers.SQL.Text := 'SELECT trigger_name FROM gd_v_user_triggers';
        IBSQLTriggers.ExecQuery;
        while not IBSQLTriggers.Eof do
        begin
          CurrentObject := IBSQLTriggers.FieldByName('trigger_name').AsTrimString;
          DelList.Add('ALTER TRIGGER ' + CurrentObject + ' INACTIVE');
          FTriggersList.Add('ALTER TRIGGER ' + CurrentObject + ' ACTIVE');
          IBSQLTriggers.Next;
        end;

        ErrorList := TStringList.Create;
        try
          FNewDatabase.Close;
          ExecDDLScript(FTargetDatabase, FUserName, FPassword, FCharSet, DelList, ErrorList, nil,
            FNewDatabase.SQLDialect, ReconnectToDatabase);
          FNewDatabase.Open;
          for I := ErrorList.Count - 1 downto 0 do
          begin
            Inc(FErrorCount);
            FTriggersList.Delete(DelList.IndexOf(ErrorList[I]));
            LogRecord('Ошибка: Триггер не был деактивирован: ' + ErrorList[I]);
          end;
        finally
          ErrorList.Free;
        end
      finally
        CurrentObject := '';
        IBSQLTriggers.Close;
        if IBSQLTriggers.Transaction.InTransaction then
          IBSQLTriggers.Transaction.Commit;
        IBSQLTriggers.Free;
        LogRecord('Завершено деактивирование триггеров: ' + MyNow);
      end;
    finally
      DelList.Free;
    end;
  except
    Inc(FErrorCount);
    LogRecord('Процесс деактивирования триггеров завершился ошибкой');
  end;
end;

procedure TboDBUpgrade.DeleteForeignKeys;
var
  IBQryForeignKeys, IBQry: TIBQuery;
  SourceTable, SourceFields, DestTable, DestFields, ForeignKey, OnDeleteKey, OnUpdateKey: String;
  DelList, ErrorList: TStringList;
  I: Integer;
begin
  ProcessState := psDeletingStruct;
  LogRecord('Начато удаление внешних индексов: ' + MyNow);
  try
    DelList := TStringList.Create;
    try
      FForeignKeysList.Clear;
      IBQry := TIBQuery.Create(Self);
      try
        IBQry.Database := FNewDatabase;
        IBQryForeignKeys := TIBQuery.Create(Self);
        try
          IBQryForeignKeys.Database := FNewDatabase;
          IBQryForeignKeys.SQL.Text := 'SELECT constraint_name, index_name, relation_name FROM gd_v_foreign_keys';
          IBQryForeignKeys.Open;
          while not IBQryForeignKeys.Eof do
          begin
            CurrentObject := Trim(IBQryForeignKeys.FieldByName('constraint_name').AsString);

            IBQry.Close;
            IBQry.SQL.Text := 'SELECT rdb$field_name ' +
                              ' FROM rdb$index_segments ' +
                              ' WHERE rdb$index_name = ' + AnsiQuotedStr(Trim(IBQryForeignKeys.Fields[1].AsString), '''') +
                              ' ORDER BY rdb$field_position ';
            IBQry.Open;

            SourceTable := Trim(IBQryForeignKeys.Fields[2].AsString);

            SourceFields := '';
            while not IBQry.Eof do
            begin
              SourceFields := SourceFields + Trim(IBQry.Fields[0].AsString) + ',';
              IBQry.Next;
            end;

            if SourceFields > '' then
              SetLength(SourceFields, Length(SourceFields) - 1);

            //2
            IBQry.Close;
            IBQry.SQL.Text := 'SELECT rdb$foreign_key ' +
                              ' FROM rdb$indices ' +
                              ' WHERE rdb$index_name = ' + AnsiQuotedStr((IBQryForeignKeys.Fields[1].AsString), '''');
            IBQry.Open;
            ForeignKey := Trim(IBQry.Fields[0].AsString);

            //3
            IBQry.Close;
            IBQry.SQL.Text := 'SELECT rdb$relation_name ' +
                              ' FROM rdb$relation_constraints ' +
                              ' WHERE rdb$index_name = ' + AnsiQuotedStr(ForeignKey, '''');
            IBQry.Open;
            DestTable := Trim(IBQry.Fields[0].AsString);

            //4
            IBQry.Close;
            IBQry.SQL.Text := 'SELECT rdb$field_name ' +
                              ' FROM rdb$index_segments ' +
                              ' WHERE rdb$index_name = ' + AnsiQuotedStr(ForeignKey, '''') +
                              ' ORDER BY rdb$field_position';
            IBQry.Open;

            DestFields := '';
            while not IBQry.Eof do
            begin
              DestFields := DestFields + Trim(IBQry.Fields[0].AsString) + ',';
              IBQry.Next;
            end;

            if DestFields > '' then
              SetLength(DestFields, Length(DestFields) - 1);

            //5
            IBQry.Close;
            IBQry.SQL.Text := 'SELECT rdb$update_rule, rdb$delete_rule ' +
                              ' FROM rdb$ref_constraints ' +
                              ' WHERE rdb$constraint_name = ' + AnsiQuotedStr(Trim(IBQryForeignKeys.Fields[0].AsString), '''');
            IBQry.Open;

            if AnsiCompareText(Trim(IBQry.Fields[0].AsString), 'RESTRICT') = 0 then
              OnUpdateKey := ''
            else
              OnUpdateKey := ' ON UPDATE ' + Trim(IBQry.Fields[0].AsString);

            if AnsiCompareText(Trim(IBQry.Fields[1].AsString), 'RESTRICT') = 0 then
              OnDeleteKey := ''
            else
              OnDeleteKey :=  ' ON DELETE ' + Trim(IBQry.Fields[1].AsString);

            //6
            IBQry.Close;
            DelList.Add('ALTER TABLE ' + SourceTable + ' DROP CONSTRAINT ' + Trim(IBQryForeignKeys.Fields[0].AsString));
            FForeignKeysList.Add('ALTER TABLE ' + SourceTable + ' ADD CONSTRAINT ' +
                                   Trim(IBQryForeignKeys.Fields[0].AsString) +
                                   ' FOREIGN KEY (' + SourceFields + ')' +
                                   ' REFERENCES ' + DestTable + '(' + DestFields + ')' +
                                   OnDeleteKey + OnUpdateKey);
            IBQryForeignKeys.Next;
          end;

        finally
          CurrentObject := '';
          IBQryForeignKeys.Close;
          if IBQryForeignKeys.Transaction.InTransaction then
            IBQryForeignKeys.Transaction.Commit;
          IBQryForeignKeys.Free;
        end;

      finally
        IBQry.Close;
        if IBQry.Transaction.InTransaction then
          IBQry.Transaction.Commit;
        IBQry.Free;
      end;

      ErrorList := TStringLIst.Create;
      try
        if FNewDatabase.DefaultTransaction.inTransaction then
          FNewDatabase.DefaultTransaction.Commit;
        FNewDatabase.Close;
        ExecDDLScript(FTargetDatabase, FUserName, FPassword, FCharSet, DelList, ErrorList, nil,
        FNewDatabase.SQLDialect, ReconnectToDatabase);
        FNewDatabase.Open;

        for I := ErrorList.Count - 1  downto 0 do
        begin
          Inc(FErrorCount);
          FForeignKeysList.Delete(DelList.IndexOf(ErrorList[I]));
          LogRecord('Ошибка удаления FOREIGN KEY: ' + ErrorList[I]);
        end;
      finally
        ErrorList.Free;
      end;
    finally
      DelList.Free;
      LogRecord('Завершено удаление внешних индексов: ' + MyNow);
    end;
  except
    Inc(FErrorCount);
    LogRecord('Удаление внешних индексов завершено с ошибкой');
  end;
end;

procedure TboDBUpgrade.DeletePrimaryKeys;
var
  IBSQLPrimaryKeys, IBSQLWork: TIBSQL;
  ErrorList, DelList: TStringList;
  I: Integer;
  PrimaryKey: TTablePrimaryKey;
begin
  ProcessState := psDeletingStruct;
  LogRecord('Начато удаление главных индексов: ' + MyNow);
  try
    FPrimaryKeys.Clear;
    IBSQLPrimaryKeys := TIBSQL.Create(Self);
    try
      IBSQLPrimaryKeys.Database := FNewDatabase;
      if not IBSQLPrimaryKeys.Transaction.InTransaction then
        IBSQLPrimaryKeys.Transaction.StartTransaction;

      IBSQLWork := TIBSQL.Create(Self);
      try
        ibSQLWork.Database := FNewDatabase;
        if not ibSQLWork.Transaction.InTransaction then
          ibSQLWork.Transaction.StartTransaction;

        IBSQLPrimaryKeys.SQL.Text := 'SELECT constraint_name, index_name, relation_name FROM gd_v_primary_keys';
        IBSQLPrimaryKeys.ExecQuery;
        while not IBSQLPrimaryKeys.Eof do
        begin
          CurrentObject := IBSQLPrimaryKeys.Fields[0].AsTrimString;

          PrimaryKey := FPrimaryKeys.Add as TTablePrimaryKey;
          PrimaryKey.Init(IBSQLPrimaryKeys.Fields[2].AsTrimString, IBSQLPrimaryKeys.Fields[0].AsTrimString, []);

          ibSQLWork.Close;
          ibSQLWork.SQL.Text := 'SELECT rdb$field_name ' +
                            ' FROM rdb$index_segments ' +
                            ' WHERE rdb$index_name = ' + AnsiQuotedStr(IBSQLPrimaryKeys.Fields[1].AsTrimString, '''') +
                            ' ORDER BY rdb$field_position ';
          ibSQLWork.ExecQuery;

          while not ibSQLWork.Eof do
          begin
            PrimaryKey.AddKeyField(ibSQLWork.Fields[0].AsTrimString);
            ibSQLWork.Next;
          end;

          IBSQLPrimaryKeys.Next;
        end;

      finally
        CurrentObject := '';
        ibSQLWork.Close;
        if ibSQLWork.Transaction.InTransaction then
          ibSQLWork.Transaction.Commit;
        ibSQLWork.Free;
      end;

    finally
      IBSQLPrimaryKeys.Close;
      if IBSQLPrimaryKeys.Transaction.InTransaction then
        IBSQLPrimaryKeys.Transaction.Commit;
      IBSQLPrimaryKeys.Free;
    end;

    ErrorList := TStringList.Create;
    DelList := TStringList.Create;
    try
      FPrimaryKeys.DropDDL(DelList);
      FNewDatabase.Close;
      ExecDDLScript(FTargetDatabase, FUserName, FPassword, FCharSet, DelList, ErrorList, nil,
      FNewDatabase.SQLDialect, ReconnectToDatabase);
      FNewDatabase.Open;
      for I := ErrorList.Count - 1 downto 0 do
      begin
        Inc(FErrorCount);
        FPrimaryKeys.Delete(DelList.IndexOf(ErrorList[I]));
        LogRecord('Ошибка: Не удален PRIMARY KEY: "'+ ErrorList[I] + '"');
      end;
    finally
      DelList.Free;
      ErrorList.Free;
    end;
    LogRecord('Завершено удаление первичных индексов: ' + MyNow);
  except
    LogRecord('Удаление первичных индексов завершено с ошибкой');
    Inc(FErrorCount);
  end;
end;

procedure TboDBUpgrade.DeactivateIndices;
var
  IBSQLIndices: TIBSQL;
  DelList, ErrorList: TStringList;
  I: Integer;
begin
  ProcessState := psDeletingStruct;
  LogRecord('Начато отключение индексов: ' + MyNow);
  try
    DelList := TStringList.Create;
    try
      FIndicesList.Clear;
      IBSQLIndices := TIBSQL.Create(Self);
      try
        IBSQLIndices.Database := FNewDatabase;
        if not IBSQLIndices.Transaction.InTransaction then
          IBSQLIndices.Transaction.StartTransaction;

        IBSQLIndices.SQL.Text := 'SELECT index_name FROM gd_v_user_indices';
        IBSQLIndices.ExecQuery;

        while not IBSQLIndices.Eof do
        begin
          CurrentObject := IBSQLIndices.Fields[0].AsTrimString;
          DelList.Add('ALTER INDEX ' + CurrentObject + ' INACTIVE');
          FIndicesList.Add('ALTER INDEX ' + CurrentObject + ' ACTIVE');
          IBSQLIndices.Next;
        end;
      finally
        CurrentObject := '';
        IBSQLIndices.Close;
        if IBSQLIndices.Transaction.InTransaction then
          IBSQLIndices.Transaction.Commit;
        IBSQLIndices.Free;
      end;

      ErrorList := TStringList.Create;
      try
        FNewDatabase.Close;
        ExecDDLScript(FTargetDatabase, FUserName, FPassword, FCharSet, DelList, ErrorList, nil,
          FNewDatabase.SQLDialect, ReconnectToDatabase);
        FNewDatabase.Open;
        for I := ErrorList.Count - 1 downto 0 do
        begin
          Inc(FErrorCount);
          LogRecord('Ошибка: Не отключен индекс: ' + ErrorList[I]);
          FIndicesList.Delete(DelList.IndexOf(ErrorList[I]));
        end;
      finally
        ErrorList.Free;
      end;
    finally
      DelList.Free;
    end;
    LogRecord('Завершено отключение индексов: ' + MyNow);
  except
    LogRecord('Отключение индексов завершено с ошибкой');
    Inc(FErrorCount);
  end;
end;

procedure TboDBUpgrade.ActivateIndices;
var
  ErrorList: TStringlist;
  I: Integer;
begin
  ProcessState := psCreatingStruct;
  LogRecord('Начата активизация индексов: ' + MyNow);
  try
    if FIndicesList.Count > 0 then
    begin
      ErrorList := TStringList.Create;
      try
        FNewDatabase.Close;
        ExecDDLScript(FTargetDatabase, FUserName, FPassword, FCharSet, FIndicesList, ErrorList, nil,
          FNewDatabase.SQLDialect, ReconnectToDatabase);
        FNewDatabase.Open;
        for I := ErrorList.Count - 1 downto 0 do
        begin
          Inc(FErrorCount);
          LogRecord('Ошибка: Индекс не был активизирован: ' + ErrorList[I]);
        end;
      finally
        ErrorList.Free;
      end;
      FIndicesList.Clear;
    end;
    LogRecord('Активизация индексов завершена: ' + MyNow);
  except
    LogRecord('Активизация индексов завершена с ошибкой');
    Inc(FErrorCount);
  end;
end;

procedure TboDBUpgrade.RestorePrimaryKeys;
var
  ErrorList, CreateList: TStringList;
  I: Integer;
begin
  ProcessState := psCreatingStruct;
  LogRecord('Начато создание главных индексов: ' + MyNow);
  try
    if FPrimaryKeys.Count > 0 then
    begin
      ErrorList := TStringList.Create;
      CreateList := TStringList.Create;
      try
        FPrimaryKeys.AddDDL(CreateList);
        FNewDatabase.Close;
        ExecDDLScript(FTargetDatabase, FUserName, FPassword, FCharSet, CreateList, ErrorList, nil,
          FNewDatabase.SQLDialect, ReconnectToDatabase);
        FNewDatabase.Open;
        for I := ErrorList.Count - 1 downto 0 do
        begin
          Inc(FErrorCount);
          LogRecord('Ошибка: Не создан PRIMARY KEY: ' + ErrorList[I]);
        end;
      finally
        CreateList.Free;
        ErrorList.Free;
      end;
    end;
    FPrimaryKeys.Clear;
    LogRecord('Завершено создание главных индексов: ' + MyNow);
  except
    LogRecord('Создание главных индексов завершено с ошибкой');
    Inc(FErrorCount);
  end;
end;


procedure TboDBUpgrade.RestoreForeignKeys;
var
  ErrorList: TStringList;
  I: Integer;
begin
  ProcessState := psCreatingStruct;
  LogRecord('Начато создание внешних индексов: ' + MyNow);
  try
    if FForeignKeysList.Count > 0 then
    begin
      ErrorList := TStringList.Create;
      try
        FNewDatabase.Close;
        ExecDDLScript(FTargetDatabase, FUserName, FPassword, FCharSet, FForeignKeysList, ErrorList, nil,
          FNewDatabase.SQLDialect, ReconnectToDatabase);
        FNewDatabase.Open;
        for I := ErrorList.Count - 1 downto 0 do
        begin
          Inc(FErrorCount);
          LogRecord('Ошибка: Не создан FOREIGN KEY: ' + ErrorList[I]);
        end;
      finally
        ErrorList.Free;
      end;
    end;
    FForeignKeysList.Clear;
    LogRecord('Завершено создание внешних индексов: ' + MyNow);
  except
    LogRecord('Создание внешних индексов завершено с ошибкой');
    Inc(FErrorCount);
  end;
end;

procedure TboDBUpgrade.ActivateTriggers;
var
  ErrorList: TStringList;
  I: Integer;
begin
  ProcessState := psCreatingStruct;
  LogRecord('Начата активизация триггеров: ' + MyNow);
  try
    if FTriggersList.Count > 0 then
    begin
      ErrorList := TStringList.Create;
      try
        FNewDatabase.Close;
        ExecDDLScript(FTargetDatabase, FUserName, FPassword, FCharSet, FTriggersList, ErrorList, nil,
          FNewDatabase.SQLDialect, ReconnectToDatabase);
        FNewDatabase.Open;
        for I := ErrorList.Count - 1 downto 0 do
        begin
          Inc(FErrorCount);
          LogRecord('Ошибка: Триггер не активизирован: ' + ErrorList[I]);
        end;
      finally
        ErrorList.Free;
      end;
    end;
    FTriggersList.Clear;
    LogRecord('Завершена активизация триггеров: ' + MyNow);
  except
    LogRecord('Активизация триггеров завершена с ошибкой');
    Inc(FErrorCount);
  end;
end;

procedure TboDBUpgrade.RestructTrees;
var
  ibsqlProcedures, ibsqlExeProc: TIBSQL;
begin
  ibsqlProcedures := TIBSQL.Create(Self);
  ibsqlExeProc := TIBSQL.Create(Self);
  try
    LogRecord('Начата перестройка интервальных деревьев ' + DateTimeToStr(Now));
    ibsqlProcedures.Database := FNewDatabase;
    ibsqlProcedures.Transaction := FNewTransaction;
    ibsqlExeProc.Database := FNewDatabase;
    ibsqlExeProc.Transaction := FNewTransaction;
    if not FNewTransaction.InTransaction then
      FNewTransaction.StartTransaction;
    ibsqlProcedures.SQL.Text := 'SELECT rdb$procedure_name pname FROM rdb$procedures '
     + 'WHERE rdb$procedure_name LIKE ''%_P_RESTRUCT_%''';
    ibsqlProcedures.ExecQuery;

    while not ibsqlProcedures.Eof do
    begin
      ibsqlExeProc.Close;
      ibsqlExeProc.SQL.Text := 'EXECUTE PROCEDURE ' + ibsqlProcedures.Fields[0].AsTrimString;
      try
        ibsqlExeProc.ExecQuery;
      except
        on E: Exception do
        begin
          LogRecord('Ошибка при выполнении процедуры: ' + ibsqlProcedures.Fields[0].AsTrimString);
          LogRecord(E.Message);
        end;
      end;

      ibsqlProcedures.Next;
    end;
  finally
    LogRecord('Завершена перестройка деревьев: ' + DateTimeToStr(Now));

    if FNewTransaction.InTransaction then
      FNewTransaction.Commit;
    ibsqlProcedures.Free;
    ibsqlExeProc.Free;
  end;
end;

// Перенос записей подлежащих сливанию из новой базы в старую
procedure TboDBUpgrade.MergeRecords;
var
  SourceSQL: TIBSQL;
  TargetTable: TIBTable;
  I, J: Integer;
  KeyTable: TTablePrimaryKey;
  Spr: String;
begin
  SourceSQL := TIBSQL.Create(Self);
  TargetTable := TIBTable.Create(Self);
  try
    LogRecord('Начато объединение данных ' + DateTimeToStr(Now));
    SourceSQL.Database := FOldDatabase;
    SourceSQL.Transaction := FOldTransaction;

    TargetTable.UniDirectional := False;
    TargetTable.ReadOnly := False;
    TargetTable.Database := FNewDatabase;
    TargetTable.Transaction := FNewTransaction;

    if not FOldTransaction.InTransaction then
      FOldTransaction.StartTransaction;

    if not FNewTransaction.InTransaction then
      FNewTransaction.StartTransaction;

    for I := 0 to FMergeTables.Count - 1 do
    begin
      if FExcludeTables.IndexOf(FMergeTables.Strings[I]) <> -1 then
        continue;

      KeyTable := FPrimaryKeys.Find(FMergeTables.Strings[I]);

      TargetTable.Close;
      TargetTable.TableName := FMergeTables.Strings[I];
      try
        TargetTable.Open;
      except
        LogRecord('Таблицы нет в новой базе данных: ' + FMergeTables.Strings[I]);
        continue;
      end;

{      PrimaryQuery.SQL.Text := 'SELECT ris.rdb$field_name name ' +
       'FROM rdb$relation_constraints rc, rdb$index_segments ris ' +
       'WHERE rc.rdb$constraint_type = ''PRIMARY KEY''' +
       ' AND ris.rdb$index_name = rc.rdb$index_name AND rc.rdb$relation_name = '''
       + FMergeTables.Strings[I] + ''' ORDER BY ris.rdb$field_position';
      PrimaryQuery.Open;}

      TargetTable.First;
      while not TargetTable.Eof do
      begin
        if (not Assigned(KeyTable)) or  (KeyTable.KeyFieldCount = 0) then
        begin
          LogRecord('В таблице ' + FMergeTables.Strings[I] + ' нельзя сравнить данные ');
          LogRecord(' из-за отсутствия главного ключа');
          Break;
        end;

        SourceSQL.Close;
        SourceSQL.SQL.Text := 'SELECT * FROM ' + FMergeTables.Strings[I]
         + ' WHERE ';

        for J := 0 to KeyTable.KeyFieldCount - 1 do
        begin
          case TargetTable.FieldByName(KeyTable.KeyFields[J]).DataType of
            ftString, ftDate, ftTime, ftDateTime: Spr := ''''
          else
            Spr := '';
          end;
          SourceSQL.SQL.Add(KeyTable.KeyFields[J] + ' = ' + Spr
           + Trim(TargetTable.FieldByName(KeyTable.KeyFields[J]).AsString) + Spr);
          SourceSQL.SQL.Add('AND');
        end;
        SourceSQL.SQL.Delete(SourceSQL.SQL.Count - 1);

        try
          SourceSQL.ExecQuery;
          if not SourceSQL.Eof then
            TargetTable.Delete
          else
            TargetTable.Next;
        except
          on E: Exception do
          begin
            LogRecord('Ошибка при открытии таблицы ' + FMergeTables.Strings[I]);
            LogRecord(E.Message);
            Break;
          end;
        end;

      end;
    end;
  finally
    LogRecord('Объединение данных завершено ' + DateTimeToStr(Now));
    if FOldTransaction.InTransaction then
      FOldTransaction.Commit;
    SourceSQL.Free;

    TargetTable.Close;
    if FNewTransaction.InTransaction then
      FNewTransaction.Commit;
    TargetTable.Free;
  end;
end;

//Замена старой базы на новую и перевод в многопользовательский режим
function TboDBUpgrade.DatabaseOnline(ADatabaseName: String): Boolean;
begin
  {
  под Файрбёрдом требуется прописывать имя сервака в пути
  к базе данных.

  if StrIPos(FServerName, ADatabaseName) = 1 then
    Delete(ADatabaseName, 1, Length(FServerName));
  }

  try
    with TIBConfigService.Create(Self) do
    try
      Protocol := FProtocol;
      ServerName := FServerName;
      Params.Add('user_name=' + FUserName);
      Params.Add('password=' + FPassword);
      LoginPrompt := False;
      Active := True;
      try
        { TODO : тут мы полагаемся, что имя сервера задано и используется протокол ТСП/ИП }
        DatabaseName := Copy(ADatabaseName, Length(FServerName) + 2, 255);
        BringDatabaseOnline;
        while IsServiceRunning do Sleep(5);
      finally
        Active := False;
      end;
      LogRecord('База данных переведена в многопользовательский режим');
      Result := True;
    finally
      Free;
    end;

  except
    on E: Exception do
    begin
      Result := False;
      LogRecord('Ошибка при переводе базы в многопользовательский режим');
      LogRecord(E.Message);
      inc(FErrorCount);
    end;
  end;

  (*
  UnregisterAutoExec(ekMachineRunOnce, FAutoExecString);
  *)

  (*
  Reg := TRegistry.Create;
  try
    Reg.RootKey := ServerRootRegistryKey;
    if Reg.OpenKeyReadOnly(RUN_ONCE_KEY) then
      Reg.DeleteValue('Gedemin upgrade');
      DeleteFile(PChar(FRestartTools));
  finally
    Reg.CloseKey;
    Reg.Free;
  end;
  *)
end;

// Выполнение стандартного апгрейда
procedure TboDBUpgrade.StandartUpgrade;
var
  I, J: Integer;
  NewTables: TStringList;
begin
  if Assigned(FOnBeforeStandartUpgrade) then
    FOnBeforeStandartUpgrade(FOldDatabase, FNewDatabase);


  if TestStop then
    exit;

  TransferDomains;

  FNewDatabase.Close;
  FNewDatabase.Open;

  //Шаг 9. Перенос структуры созданной пользователем в новую базу
  if TestStop then
    exit;

  TransferTables;

  FNewDatabase.Close;
  FNewDatabase.Open;

  if TestStop then
    exit;

  //Шаг 8. Создание списка таблиц подлежащих апгрейду
  FOldDatabase.GetTableNames(FUpgradeTables, False);
  for I := 0 to FExcludeTables.Count - 1 do
  begin
    J := FUpgradeTables.IndexOf(FExcludeTables[I]);
    if J <> -1 then
      FUpgradeTables.Delete(J)
    else
      LogRecord('ПРЕДУПРЕЖДЕНИЕ! Список таблиц, не подлегающих апгрэйду, содержит неверное имя: ' + FExcludeTables[I]);
    if FUpgradeTables.Count = 0 then
      Break;
  end;

  NewTables := TStringList.Create;
  try
    FNewDatabase.GetTableNames(NewTables, False);
    for I := FUpgradeTables.Count - 1 downto 0 do
    begin
      J := NewTables.IndexOf(FUpgradeTables[I]);
      if J = -1 then
      begin
        LogRecord('ПРЕДУПРЕЖДЕНИЕ! Данные из таблицы "' + FUpgradeTables[I] + '" не будут перенесены, так как она отсутствует в новой базе');
        FUpgradeTables.Delete(I);
      end;
      if FUpgradeTables.Count = 0 then
        Break;
    end;
  finally
    NewTables.Free;
  end;

  if TestStop then
    exit;

  // перанеслі перад вью, бо вью, створаныя карыстальнікам,
  // могуць уключаць паля створаныя карыстальнікам
  TransferFields;

  FNewDatabase.Close;
  FNewDatabase.Open;

  if TestStop then
    exit;

  TransferViews;

  FNewDatabase.Close;
  FNewDatabase.Open;

  if TestStop then
    exit;

  TransferFunctions;

  FNewDatabase.Close;
  FNewDatabase.Open;

  if TestStop then
    exit;

  TransferGenerators;

  FNewDatabase.Close;
  FNewDatabase.Open;

  if TestStop then
    exit;

  TransferExceptions;

  FNewDatabase.Close;
  FNewDatabase.Open;

  if TestStop then
    exit;

  {TransferIndices;
  if TestStop then
    exit;}

  {TransferForeignKeys;
  if TestStop then
    exit;}

  {TransferProcedures;
  if TestStop then
    exit;}

  {TransferTriggers;
  if TestStop then
    exit;}

  //Шаг 10.1 Отключение индексов и триггеров
  if TestStop then
    exit;

  DeactivateTriggers;

  if TestStop then
    exit;

  DeleteForeignKeys;

  if TestStop then
    exit;

  DeletePrimaryKeys;

  if TestStop then
    exit;

  DeactivateIndices;

  // Сливаем данные
  if TestStop then
    exit;

  MergeRecords;

// Шаг 10.2 Перенос данных
  for I := 0 to FUpgradeTables.Count - 1 do
  begin
    if TestStop then
      exit;
    try
      UpgradeTable(FUpgradeTables[I]);
    except
      on E: Exception do
      begin
        LogRecord('Ошибка  переноса данных таблицы: ' + FUpgradeTables[I]);
        LogRecord('   ' + E.Message);
      end
    end
  end;

  LogRecord('Завершен перенос данных из таблиц: ' + MyNow);

  // Шаг 10.3 Подключение индексов и триггеров
  if TestStop then
    exit;

  ActivateIndices;

  if TestStop then
    exit;

  TransferIndices;

  if TestStop then
    exit;

  RestorePrimaryKeys;

  if TestStop then
    exit;

  RestoreForeignKeys;

  if TestStop then
    exit;

  TransferForeignKeys;

  if TestStop then
    exit;

  ActivateTriggers;

  if TestStop then
    exit;

  TransferProcedures;

  if TestStop then
    exit;

  TransferTriggers;

  if TestStop then
    exit;

  //Шаг 11. Перенос генераторов
  UpgradeGenerators;

  // Перестраиваем границы для интервальных деревьев
  if TestStop then
    exit;

  RestructTrees;

  //
  if TestStop then
    exit;

  IncAttrGen;  

  // Присваиваем права пользователей
  if TestStop then
    exit;

  GrantUser;

  if Assigned(FOnAfterStandartUpgrade) then
    FOnAfterStandartUpgrade(FOldDatabase, FNewDatabase);

  if TestStop then
    exit;

  ProcessState := psSuccess;
end;

// Запуск апгрейда
procedure TboDBUpgrade.ExecuteUpgrade;
var
  UpgradeType: TTestCustomUpgradeResult;
  SL: TStringList;
  FilePath: String;
//  TempProtocol: String;
  //CName: PChar;
  //I: dWord;
  S: String;
  FreeSpace, UpgradeSpace, FS: Integer;
  F: File of byte;
//  Path: array[0..1023] of Char;
  DS: TgsDatabaseShutdown;
begin
  try
    {I := MAX_COMPUTERNAME_LENGTH + 1;
    GetMem(CName, I);
    try
      GetComputerName(PChar(CName), I);
      Assert(AnsiUpperCase(String(CName)) = FServerName, 'Процесс апгрейда можно запустить только на сервере');
    finally
      FreeMem(CName);
    end;}

    if AnsiCompareText(FServerName, FThisComputerName) = 0 then
    begin
      Assert(FileExists(FSourceDatabase), 'Не найден файл базы данных источника');
      Assert(FileExists(FBkFileName), 'Не найден .bk файл базы данных приемника');
    end;
    Assert(ProcessState = psIdle, 'Для запуска апгрейда перезапустите программу');
    Assert(Trim(FUserName) > '', 'Не задано имя пользователя для подключения');
    Assert(Trim(FPassword) > '', 'Не задан пароль для подключения');

    //
    FTargetDatabase := ExtractFilePath(FSourceDatabase) + 'gdbase_new' + ExtractFileExt(FSourceDatabase);

    if AnsiCompareText(FServerName, FThisComputerName) = 0 then
    begin
      S := ExtractFileDrive(FSourceDatabase);
      FreeSpace := DiskFree(Ord(S[1])- Ord('A') + 1) div 1024;

      AssignFile(F, FSourceDatabase);
      Reset(F);
      try
        FS := FileSize(F) div 1024;
      finally
        CloseFile(F);
      end;

      UpgradeSpace := UPGRADE_SIZE * 1024 + FS * 4;
      S := IntToStr(UpgradeSpace);
      if FreeSpace < UpgradeSpace then
      begin
        if MessageBox(0,
          PChar('На диске недостаточно свободного места.'#10#13 +
          'Для успешного завершения апгрейда необходимо: ' + S + ' KB.'#10#13 +
          'Продолжить апгрейд?'),
          'Внимание',
           MB_ICONQUESTION or MB_YESNO) = IDNO then
        begin
          ProcessState := psUserCanceled;
          Exit;
        end
      end;
    end;

    LogRecord('Начат процесс апгрейда: ' + MyNow);
    //
    SL := TStringList.Create;
    try
      FilePath := ExtractFilePath(FBkFileName) + DBUpgradeExcludeTablesFileName;
      if FileExists(FilePath) then
      begin
        SL.LoadFromFile(FilePath);
        ExcludeTables := SL;
      end
      else
        LogRecord('Ошибка: Не найден файл ' + FilePath);
      FilePath := ExtractFilePath(FBkFileName) + DBUpgradeMergeTablesFileName;
      if FileExists(FilePath) then
      begin
        SL.LoadFromFile(ExtractFilePath(FBkFileName) + DBUpgradeMergeTablesFileName);
        MergeTables := SL;
      end
      else
        LogRecord('Не найден файл ' + FilePath);
    finally
      SL.Free;
    end;

    // настройка компонентов базы данных и транзакции
    if not TestStop then
    begin
      FOldDataBase := TIBDatabase.Create(Self);
      FOldDatabase.SQLDialect := FSQLDialect;

      if FProtocol = TCP then
        FOldDataBase.DatabaseName := FServerName + ':' + FSourceDatabase
      else
        FOldDataBase.DatabaseName := FSourceDatabase;

      FOldDataBase.Params.Add('user_name=' + FUserName);
      FOldDataBase.Params.Add('password=' + FPassword);
      FOldDataBase.Params.Add('lc_ctype=' + FCharSet);
      // сборка мусора в отдельных случаях (после большого
      // числа удалений) может завесить сервер на сутки
      // поскольку мы одноразово считываем данные из исходной
      // базы, имеет смысл отключить сборку мусора
      FOldDataBase.Params.Add('no_garbage_collect');
      FOldDataBase.LoginPrompt := False;
      FOldTransaction := TIBTransaction.Create(Self);
      {
      FOldTransaction.Params.Add('nowait');
      FOldTransaction.Params.Add('concurrency');
      }
      FOldTransaction.Params.Add('read');
      FOldTransaction.Params.Add('consistency');
      FOldTransaction.DefaultDatabase := FOldDatabase;
      FOldDatabase.DefaultTransaction := FOldTransaction;

      LogRecord('Имя сервера: ' + FServerName);
      LogRecord('Исходная база данных: ' + FSourceDatabase);
    end;

    if not TestStop then
    try
      // подключаемся к базе данных
      FOldDataBase.Open;
    except
      on E: Exception do
      begin
        LogRecord('Ошибка подключения к базе данных');
        LogRecord(E.Message);
        ProcessState := psError;
      end;
    end;
    try
      // Шаг 2. Перевод базы в однопользовательский режим
      // если есть подключенные пользователи -- выводим их список
      if not TestStop then
      begin
        LogRecord('Перевод базы данных в однопользовательский режим...');

//        FOldDatabase.Close;

        DS := TgsDatabaseShutdown.Create(Self); 
        with DS do
        try
          DS.Database := FOldDatabase;
          if not Shutdown then
            ProcessState := psUserCanceled
          else
          begin
{ TODO -oандрэй -cзрабіць :
grestore.exe используется непосредственным значением
надо заменить на константу }
            (*
            FRestartTools := RegReadStringDef(ServerRootRegistryKey, ServerRootRegistrySubKey, ToolsDirectoryValue, DefaultToolsDirectory);
            if not FileExists(IncludeTrailingBackSlash(FRestartTools) + 'grestore.exe') then
            begin
              GetTempPath(SizeOf(Path), Path);
              FRestartTools := IncludeTrailingBackslash(Path) + 'grestore.exe';
              CopyFile(PChar(ExtractFilePath(Application.ExeName) + 'tools\grestore.exe'),
                PChar(FRestartTools), False);
            end;
            Assert(FProtocol = TCP);
            TempProtocol := 'TCP';
            FAutoExecString := FRestartTools +
                    ' ' + FServerName +
                    ' ' + FOldDatabase.DatabaseName +
                    ' ' + TempProtocol +
                    ' ' + FUserName +
                    ' ' + EncodeString(FPassword, FOldDatabase.DatabaseName) +
                    ' ' + '-R';
            RegisterAutoExec(ekMachineRunOnce, 'grestore.exe', FAutoExecString);
            *)
            FCurrentStep := 1;
          end;
        finally
          Free;
        end;

        (*
        IBInfo := TIBDatabaseInfo.Create(Self);
        try
          IBInfo.Database := FOldDataBase;
          with TdlgUserDisconect.Create(Self) do
          try
            if ShowDialog(IBInfo, FServerName, FUserName, FPassword, FProtocol) <> mrOk then
              ProcessState := psUserCanceled
            else
            begin
              Reg := TRegistry.Create;
              try
                FRestartTools := '';
                Reg.RootKey := ServerRootRegistryKey;
                if Reg.OpenKeyReadOnly(ServerRootRegistrySubKey) then
                  FRestartTools := Reg.ReadString(ToolsDirectoryValue);
                if FRestartTools = '' then
                  FRestartTools := DefaultToolsDirectory;

                if not FileExists(IncludeTrailingBackSlash(FRestartTools) + 'grestore.exe') then
                begin
                  GetTempPath(SizeOf(Path), Path);
                  FRestartTools := IncludeTrailingBackslash(Path);
                  CopyFile(PChar(ExtractFilePath(Application.ExeName) + 'Tools\grestore.exe'),
                    PChar(FRestartTools + 'grestore.exe'), False);
                end;

                if FProtocol = TCP then
                  TempProtocol := 'TCP'
                else  ;
                  if FProtocol = SPX then
                    TempProtocol := 'SPX'
                  else
                    if FProtocol = Local then
                      TempProtocol := 'LOCAL'
                    else
                      if FProtocol = NamedPipe then
                        TempProtocol := 'NAMEDPIPE';

                FRestartTools := FRestartTools + 'grestore.exe';

                if Reg.OpenKeyReadOnly(RUN_ONCE_KEY) then
                  Reg.WriteString('Gedemin upgrade', FRestartTools +
                    ' ' + FServerName +
                    ' ' + FOldDatabase.DatabaseName +
                    ' ' + TempProtocol +
                    ' ' + FUserName +
                    ' ' + EncodeString(FPassword, FOldDatabase.DatabaseName) +
                    ' ' + '-R');

              finally
                Reg.CloseKey;
                Reg.Free;
              end;

              FCurrentStep := 1;
            end;
          finally
            Free;
          end;
        finally
          IBInfo.Free;
        end;
        *)

        LogRecord('Успешно завершен');
      end;

      if not TestStop then
      begin
        FOldDatabase.Close;
        FOldDatabase.Open;
        FCurrentStep := 2;
      end;

      // Шаг 3. Получение версий баз данных
      // Получаем версию старой базы
      if not TestStop then
      begin
        FOldVersion := ReadOldDatabaseVersion;
      end;

      // Получаем версию новой базы
      if not TestStop then
      begin
        FNewVersion := ReadNewDatabaseVersion;

      end;

      // Шаг 4. Создание архивной копии базы
      if not TestStop then
      begin
        BackUpDatabase;
        FCurrentStep := 3;
      end;

{      // Modify
      if not TestStop and (MessageBox(0, 'Произвести модификацию базы данных ' +
       'передет выполнением upgrade?', 'Вопрос', MB_YESNO or MB_ICONQUESTION) = IDYES) then
        with TgdModify.Create(nil) do
        try
          IBUser := FUserName;
          IBPassword := FPassword;
          Database := FOldDatabase;
          ShutDownNeeded := False;
          OnLog := LogRecord;
          Execute;
        finally
          Free;
        end;}

      if not TestStop then
      begin
        FOldDatabase.Close;
        FOldDatabase.Open;
        FCurrentStep := 3;
      end;

      // Шаг 5. Получение типа апгрейда
      if not TestStop then
      begin
        if Assigned(FOnTestCustomUpgrade) then
          FOnTestCustomUpgrade(FOldVersion, FNewVersion, UpgradeType)
        else
          UpgradeType := tcurStandartProcedure;
      end;

      if not TestStop then
        case UpgradeType of

          tcurUpgradeImpossible:
            begin
              LogRecord('Апгрейд базы данных невозможен');
              MessageBox(0,
                'Невозможно провести Upgrade базы данных. Обратитесь к разработчикам системы.',
                'Внимание',
                MB_OK or MB_ICONHAND);
              ProcessState := psError;
            end;

          tcurStandartProcedure:
            begin
              LogRecord('Начат стандартный апгрейд базы данных: ' + MyNow);

              if not TestStop then
                RestoreDatabase(FTargetDatabase, FUserName, FPassword, FBkFileName);

              if not TestStop then
                ShutDownNew;

              if not TestStop then
                StandartUpgrade;

              // Шаг 12. Отключение от базы данных
              if not TestStop then
              begin
                if FOldTransaction.InTransaction then
                  FOldTransaction.Commit;

                if FNewTransaction.InTransaction then
                  FNewTransaction.Commit;

                FOldDatabase.Close;
                FNewDatabase.Close;
              end;

              if FErrorCount <> 0 then
              begin
                if MessageBox(0,
                  'В процессе переноса данных возникали ошибки. Проверьте пожалуйста Log файл.' +
                  ' Отменить апгрейд?',
                  'Внимание',
                   MB_YESNO or MB_ICONQUESTION) = IDYES then
                begin
                  FCurrentStep := 6;
                  ProcessState := psError;
                end
                else
                  FErrorCount := -1;
              end;

              if not TestStop then
              begin
                if not DatabaseOnLine(FNewDatabase.DatabaseName) then
                  FErrorCount := -1;
                if MoveFileEx(PChar(FTargetDatabase), PChar(FSourceDatabase), MOVEFILE_REPLACE_EXISTING) then
                begin
                  LogRecord('Заменен прежний файл базы данных на новый');
                  FCurrentStep := 3;
                end
                else
                begin
                  LogRecord('Ошибка при копировании нового файла базы данных');
                  ProcessState := psError;
                end;
              end;

              if not TestStop then
              begin
                if FErrorCount = -1 then
                begin
                  LogRecord('Процесс апгрейда завершен с ошибками: ' + MyNow);
                  FErrorCount := 0;
                end 
                else               
                  LogRecord('Завершен стандартный апгрейд базы данных: ' + MyNow);
              end;
            end;  
          tcurCurrentDatabaseUpgrade:
            begin
              LogRecord('Начат апгрейд текущей базы данных: ' + MyNow);
              if Assigned(FOnCustomUpgrade) then
                FOnCustomUpgrade(FOldVersion, FNewVersion);
              if not TestStop then
                DatabaseOnline(FOldDataBase.DatabaseName);
              if not TestStop then  
                LogRecord('Завершен апгрейд текущей базы данных: ' + MyNow);
            end;

          tcurCustomProcedure:
            begin
              LogRecord('Начат специальный апгрейд базы данных: ' + MyNow);

              if not TestStop then
                RestoreDatabase(FTargetDatabase, FUserName, FPassword, FBkFileName);

              if not TestStop then
                ShutDownNew;

              if not TestStop then
                if Assigned(FOnCustomUpgrade) then
                  FOnCustomUpgrade(FOldVersion, FNewVersion);

              if not TestStop then
              begin
                DatabaseOnLine(FNewDatabase.DatabaseName);
                if MoveFileEx(PChar(FNewDatabase.DatabaseName), PChar(FOldDatabase.DatabaseName), MOVEFILE_REPLACE_EXISTING) then
                begin
                  LogRecord('Заменен файл старой базы данных на новый');
                  FCurrentStep := 3;
                end
                else
                begin
                  LogRecord('Ошибка при копировании файла новой базы данных');
                  ProcessState := psError;
                end;
              end;  
              if not TestStop then
                LogRecord('Завершен специальный апгрейд базы данных: ' + MyNow);
            end;
          end;

      // Обработка прервания апгрейда и ошибок возникших при апгрейле    
      if TestStop then
        LogRecord('Процесс апгрейда был прерван: ' + MyNow)
      else
      begin
        if FErrorCount <> 0 then
        begin
          if MessageBox(0,
            'В процессе переноса данных возникали ошибки. Проверьте пожалуйста Log файл.' +
            ' Отменить апгрейд?',
            'Внимание',
            MB_YESNO or MB_ICONQUESTION) = IDYES then
          begin
            LogRecord('Процесс апгрейда был отменен: ' + MyNow);
            FCurrentStep := 6;
            ProcessState := psError;
          end
          else
          begin
            LogRecord('Процесс апгрейда завершен с ошибками: ' + MyNow);
            FErrorCount := 0;
          end;
        end;

        if FErrorCount = 0 then
        begin
          LogRecord('Завершен процесс апгрейда: ' + MyNow);
          
          if FOldBkFileName > '' then
            ShowMessage('Процесс апгрейда завершен. Старая база данных находится в файле: ' + FOldBkFileName)
          else
            ShowMessage('Процесс апгрейда завершен.'); 
        end;
      end;
    finally
      if TestStop then
      begin
        if FCurrentStep > 3 then
        begin
          if FNewDatabase <> nil then
            FNewDatabase.Close;
          if MessageBox(0,
            'В процессе переноса данных возникали ошибки.' +
            ' Удалить файл апгрейда?',
            'Внимание',
            MB_YESNO or MB_ICONQUESTION) = IDYES then
          begin
            if DeleteFile(FTargetDatabase) then
              LogRecord('Удален файл: ' + FTargetDatabase)
            else
              LogRecord('Ошибка удаления файла: ' + FTargetDatabase);          
          end;  
        end;

        if FCurrentStep > 2 then
        begin
          FOldDatabase.Close;
          if FOldBkFileName > '' then
            RestoreDatabase(FSourceDatabase, FUserName, FPassword, FOldBkFileName)
        end;

        if FCurrentStep > 0 then
          DatabaseOnLine(FOldDatabase.DatabaseName);
      end;
    end;
  finally
    if ProcessState = psUserCanceled then
      FProcessState := psIdle;

    if ProcessState = psError then
      FProcessState := psIdle;

    FLogFileName := '';
  end;
end;

procedure TboDBUpgrade.SetMergeTableList(const Value: TStringList);
var
  I: Integer;
begin
  FMergeTables.Clear;

  if Assigned(Value) then
    for I := 0 to Value.Count - 1 do
      if (Pos('//', Value[I]) = 0) and (Trim(Value[I]) > '') then
        if FMergeTables.IndexOf(UpperCase(Trim(Value[I]))) = -1 then
          FMergeTables.Add(UpperCase(Trim(Value[I])));
end;

procedure TboDBUpgrade.LogError(const AString: String);
begin
  LogRecord(AString);
  ProcessState := psError;
  raise EboDBUpgradeException.Create(AString);
end;

procedure Register;
begin
  RegisterComponents('Setup', [TboDBUpgrade]);
end;

{ TTablePrimaryKey }

function TTablePrimaryKey.AddDDL: String;
var
  I: Integer;
begin
  Assert(FKeyFieldCount > 0);
  Result := 'ALTER TABLE ' + FTableName + ' ADD CONSTRAINT ' +
    FConstraintName + ' PRIMARY KEY (';
  for I := 0 to FKeyFieldCount - 1 do
    Result := Result + FKeyFields[I] + ',';
  SetLength(Result, Length(Result) - 1);
  Result := UpperCase(Result) + ')';
end;

procedure TTablePrimaryKey.AddKeyField(const AFieldName: String);
begin
  Assert(FKeyFieldCount < 14);
  FKeyFields[FKeyFieldCount] := UpperCase(AFieldName);
  Inc(FKeyFieldCount);
end;

constructor TTablePrimaryKey.Create;
begin
  inherited Create(ACollection);
  FTableName := '';
  FConstraintName := '';
  FKeyFieldCount := 0;
end;

function TTablePrimaryKey.DropDDL: String;
begin
  Assert(FKeyFieldCount > 0);
  Result := UpperCase('ALTER TABLE ' + FTableName + ' DROP CONSTRAINT ' + FConstraintName);
end;

function TTablePrimaryKey.GetKeyFields(Index: Integer): String;
begin
  Assert((Index >= 0) and (Index < FKeyFieldCount));
  Result := FKeyFields[Index];
end;

procedure TTablePrimaryKey.Init(const ATableName, AConstraintName: String;
  const AFields: array of String);
var
  I: Integer;
begin
  Assert(High(AFields) < 15);
  FTableName := UpperCase(ATableName);
  FConstraintName := UpperCase(AConstraintName);
  FKeyFieldCount := High(AFields) - Low(AFields) + 1;
  for I := 0 to FKeyFieldCount - 1 do
    FKeyFields[I] := UpperCase(AFields[I]);
end;

function TTablePrimaryKey.Locate(ATargetTable,
  ASourceTable: TIBTable): Boolean;
var
  I: Integer;
  F: String;
  A: Variant;
begin
  if FKeyFieldCount = 1 then
    Result := ATargetTable.Locate(FKeyFields[0], ASourceTable.FieldByName(FKeyFields[0]).AsVariant, [])
  else
  begin
    F := '';
    A := VarArrayCreate([0, FKeyFieldCount - 1], varVariant);
    for I := 0 to FKeyFieldCount - 1 do
    begin
      F := F + FKeyFields[I] + ';';
      A[I] := ASourceTable.FieldByName(FKeyFields[I]).AsVariant;
    end;
    SetLength(F, Length(F) - 1);

    Result := ATargetTable.Locate(F, A, []);
  end;
end;

function TTablePrimaryKey.Locate(ATargetTable: TIBTable;
  ASourceTable: TIBSQL): Boolean;
var
  I: Integer;
  F: String;
  A: Variant;
begin
  if FKeyFieldCount = 1 then
    Result := ATargetTable.Locate(FKeyFields[0], ASourceTable.FieldByName(FKeyFields[0]).AsVariant, [])
  else
  begin
    F := '';
    A := VarArrayCreate([0, FKeyFieldCount - 1], varVariant);
    for I := 0 to FKeyFieldCount - 1 do
    begin
      F := F + FKeyFields[I] + ';';
      A[I] := ASourceTable.FieldByName(FKeyFields[I]).AsVariant;
    end;
    SetLength(F, Length(F) - 1);

    Result := ATargetTable.Locate(F, A, []);
  end;
end;

{ TPrimaryKeys }

procedure TPrimaryKeys.AddDDL(AStringList: TStringList);
var
  I: Integer;
begin
  AStringList.Clear;
  for I := 0 to Count - 1 do
    AStringList.Add((Items[I] as TTablePrimaryKey).AddDDL);
end;

procedure TPrimaryKeys.DropDDL(AStringList: TStringList);
var
  I: Integer;
begin
  AStringList.Clear;
  for I := 0 to Count - 1 do
    AStringList.Add((Items[I] as TTablePrimaryKey).DropDDL);
end;

function TPrimaryKeys.Find(const ATableName: String): TTablePrimaryKey;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if AnsiCompareText((Items[I] as TTablePrimaryKey).TableName, ATableName) = 0 then
    begin
      Result := Items[I] as TTablePrimaryKey;
      Break;
    end;
end;

procedure TboDBUpgrade.IncAttrGen;
var
  ibsqlExeProc: TIBSQL;
begin
  ibsqlExeProc := TIBSQL.Create(Self);
  try
    LogRecord('Увеличение генератора версии атрибутов ' + DateTimeToStr(Now));
    ibsqlExeProc.Database := FNewDatabase;
    ibsqlExeProc.Transaction := FNewTransaction;
    if not FNewTransaction.InTransaction then
      FNewTransaction.StartTransaction;
    ibsqlExeProc.Close;
    ibsqlExeProc.SQL.Text := 'SELECT GEN_ID(gd_g_attr_version, 1) FROM rdb$database ';
    try
      ibsqlExeProc.ExecQuery;
    except
      on E: Exception do
      begin
        LogRecord('Ошибка при увеличении генератора');
        LogRecord(E.Message);
      end;
    end;
    ibsqlExeProc.Close;
  finally
    if FNewTransaction.InTransaction then
      FNewTransaction.Commit;
    ibsqlExeProc.Free;
  end;
end;

end.


