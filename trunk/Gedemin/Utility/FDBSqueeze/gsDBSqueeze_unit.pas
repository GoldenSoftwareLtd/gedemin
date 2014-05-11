unit gsDBSqueeze_unit;

interface

uses
  Windows, SysUtils, IB, IBDatabase, IBSQL, IBQuery, Classes, gd_ProgressNotifier_unit;

const
  NEWDOCUMENT_NUMBER = 'б/н';            // номер новых документов для бух сальдо
  NEWINVDOCUMENT_NUMBER = '1';           // номер новых доментов для складского сальдо
  PROIZVOLNYE_TRANSACTION_KEY = 807001;  // AC_TRANSACTION.id WHERE AC_TRANSACTION.name = Произвольные(ая) проводки(а)
  PROIZVOLNYE_TRRECORD_KEY = 807100;     // AC_TRRECORD.id WHERE transactionkey = PROIZVOLNYE_TRANSACTION_KEY
  OSTATKY_ACCOUNT_KEY = 300003;          // AC_ACCOUNT.id WHERE fullname = 00 Остатки
  HOZOPERATION_DOCTYPE_KEY = 806001;     // gd_documenttype.id WHERE name = Хозяйственная операция
  MAX_PROGRESS_STEP = 12500;
  PROGRESS_STEP = MAX_PROGRESS_STEP div 100;
  INCLUDE_HIS_PROGRESS_STEP = PROGRESS_STEP*16;

type
  TActivateFlag = (aiActivate, aiDeactivate);

  TOnGetDBPropertiesEvent = procedure(const AProperties: TStringList) of object;
  TOnGetInfoTestConnectEvent = procedure(const AConnectSuccess: Boolean; const AConnectInfoList: TStringList) of object;
  TOnGetProcStatistics = procedure(const AnGdDoc: String; const AnAcEntry: String; const AnInvMovement: String; const AnInvCard: String) of object;
  TOnGetStatistics = procedure(const AnGdDoc: String; const AnAcEntry: String; const AnInvMovement: String; const AnInvCard: String) of object;
  TOnLogSQLEvent = procedure(const S: String) of object;
  TOnSetDocTypeStringsEvent = procedure(const ADocTypeList: TStringList) of object;
  TOnGetInvCardFeaturesEvent =  procedure (const ACardFeaturesList: TStringList) of object;
  TOnSetDocTypeBranchEvent = procedure(const ABranchList: TStringList) of object;
  TOnGetConnectedEvent = procedure(const AConnected: Boolean) of object;

  EgsDBSqueeze = class(Exception);

  TgsDBConnectInfo = record
    DatabaseName: String;
    Host: String;
    Port: Integer;
    UserName: String;
    Password: String;
    CharacterSet: String;
  end;

  TgsDBSqueeze = class(TObject)
  private
    FIBDatabase: TIBDatabase;
    FConnectInfo: TgsDBConnectInfo;
    FDBPageSize: Integer;
    FDBPageBuffers: Integer;

    FAllOurCompaniesSaldo: Boolean;
    FCalculateSaldo: Boolean;
    FCardFeaturesStr: String;                                   // cписок полей-признаков складской карточки
    FCascadeTbls: TStringList;
    FClosingDate: TDateTime;                                    // дата закрытия периода - до нее (не включительно) удаляем документы
    FCurrentProgressStep: Integer;
    FCurUserContactKey: Integer;
    FDocTypesList: TStringList;                                 // типы документов выбранные пользователем
    FDoProcDocTypes: Boolean;                                   // true - обрабатывать ТОЛЬКО документы с выбранными типами, false - обрабатывать все КРОМЕ документов с выбранными типами
    FDoStopProcessing: Boolean;                                 // флаг прерывания выполнения
    FEntryAnalyticsStr: String;                                 // список всех бухгалтерских аналитик
    FInactivBlockTriggers: String;
    FInvSaldoDoc: Integer;
    FOurCompaniesListStr: String;                               // список компаний из gd_ourcompany
    FProizvolnyyDocTypeKey: Integer;                            // ''Произвольный тип'' из gd_documenttype

    FOnGetConnectedEvent: TOnGetConnectedEvent;
    FOnGetDBPropertiesEvent: TOnGetDBPropertiesEvent;
    FOnGetInfoTestConnectEvent: TOnGetInfoTestConnectEvent;
    FOnGetInvCardFeaturesEvent : TOnGetInvCardFeaturesEvent;
    FOnGetProcStatistics: TOnGetProcStatistics;
    FOnGetStatistics: TOnGetStatistics;
    FOnLogSQLEvent: TOnLogSQLEvent;
    FOnProgressWatch: TProgressWatchEvent;
    FOnSetDocTypeBranchEvent: TOnSetDocTypeBranchEvent;
    FOnSetDocTypeStringsEvent: TOnSetDocTypeStringsEvent;

    procedure CreateUDFs;
    procedure SetTriggersState(const ATableName: String; const AIsActive: Boolean);
    function CreateHIS(AnIndex: Integer): Integer;
    function DestroyHIS(AnIndex: Integer): Integer;
    function GetConnected: Boolean;
    function GetCountHIS(AnIndex: Integer): Integer;
    function GetNewID: Integer;                                 // возвращает сгенерированный новый уникальный идентификатор

  public
    constructor Create;
    destructor Destroy; override;

    procedure CalculateAcSaldo;                                 // подсчет бухгалтерского сальдо
    procedure CalculateInvSaldo;                                // подсчет складских остатков
    procedure Connect(ANoGarbageCollect: Boolean; AOffForceWrite: Boolean);
    procedure CreateAcEntries;                                  // формирование бухгалтерского сальдо
    procedure CreateDBSStateJournal;                            // создание таблицы журнала выполения операций, чтобы при повторной обработке БД можно было продолжить
    procedure CreateHIS_IncludeInHIS;
    procedure CreateInvBalance;
    procedure CreateInvSaldo;                                   // формирование складских остатков
    procedure CreateMetadata;                                   // создание необходимых таблиц для программы
    procedure DeleteDBSTables;
    procedure DeleteDocuments_DeleteHIS;
    procedure DeleteOldAcEntryBalance;                          // удаление старого бух сальдо
    procedure Disconnect;
    procedure DropDBSStateJournal;
    procedure ExecSqlLogEvent(const AnIBQuery: TIBQuery; const AProcName: String); Overload;
    procedure ExecSqlLogEvent(const AnIBSQL: TIBSQL; const AProcName: String); Overload;   // ExecQuery  и запись в лог
    procedure InsertDBSStateJournal(const AFunctionKey: Integer; const AState: Integer; const AErrorMsg: String = '');
    procedure MergeCards(const ADocDate: TDateTime; const ADocTypeList: TStringList; const AUsrSelectedFieldsList: TStringList);
    procedure PrepareDB;                                        // удаление PKs, FKs, UNIQs, отключение индексов и триггеров
    procedure Reconnect(ANoGarbageCollect: Boolean; AOffForceWrite: Boolean);
    procedure RestoreDB;                                        // восстановление певоначального состояния (создание PKs, FKs, UNIQs, включение индексов и триггеров)
    procedure SaveMetadata;                                     // сохранение первоначального состояния (PKs, FKs, UNIQs, состояния индексов и триггеров)
    procedure SetBlockTriggerActive(const SetActive: Boolean);  // переключение состояния активности триггеров блокировки (LIKE %BLOCK%)
    procedure SetFVariables;
    procedure SetSelectDocTypes(const ADocTypesList: TStringList);

    procedure ErrorEvent(const AMsg: String; const AProcessName: String = '');
    procedure GetDBPropertiesEvent;                             // получить информацию о БД
    procedure GetInfoTestConnectEvent;                          // получить версию сервера и количество подключенных юзеров (учитывая нас)
    procedure GetInvCardFeaturesEvent;                          // заполнить список признаков INV_CARD для StringGrid
    procedure GetProcStatisticsEvent;                           // получить кол-во записей для обработки в GD_DOCUMENT, AC_ENTRY, INV_MOVEMENT
    procedure GetStatisticsEvent;                               // получить текущее кол-во записей в GD_DOCUMENT, AC_ENTRY, INV_MOVEMENT
    procedure LogEvent(const AMsg: String);                     // записать в лог
    procedure ProgressMsgEvent(const AMsg: String; AStepIncrement: Integer = 1);
    procedure ProgressWatchEvent(const AProgressInfo: TgdProgressInfo);
    procedure SetDocTypeStringsEvent;                           // заполнить список типов документов для StringGrid
    procedure UsedDBEvent;                                      // БД уже ранее обрабатывалась этой программой, вывести диалог для решения продолжить обработку либо начать заново обрабатывать

    property AllOurCompaniesSaldo: Boolean read FAllOurCompaniesSaldo write FAllOurCompaniesSaldo;
    property CalculateSaldo: Boolean       read FCalculateSaldo   write FCalculateSaldo;
    property ClosingDate: TDateTime        read FClosingDate      write FClosingDate;
    property Connected: Boolean            read GetConnected;
    property ConnectInfo: TgsDBConnectInfo read FConnectInfo      write FConnectInfo;
    property DocTypesList: TStringList     read FDocTypesList     write SetSelectDocTypes;
    property DoProcDocTypes: Boolean       read FDoProcDocTypes   write FDoProcDocTypes;
    property DoStopProcessing: Boolean     read FDoStopProcessing write FDoStopProcessing;

    property OnGetConnectedEvent: TOnGetConnectedEvent
      read FOnGetConnectedEvent        write FOnGetConnectedEvent;
    property OnGetDBPropertiesEvent: TOnGetDBPropertiesEvent
      read FOnGetDBPropertiesEvent     write FOnGetDBPropertiesEvent;
    property OnGetInfoTestConnectEvent: TOnGetInfoTestConnectEvent
      read FOnGetInfoTestConnectEvent  write FOnGetInfoTestConnectEvent;
    property OnGetInvCardFeaturesEvent: TOnGetInvCardFeaturesEvent
      read FOnGetInvCardFeaturesEvent  write FOnGetInvCardFeaturesEvent;
    property OnGetProcStatistics: TOnGetProcStatistics
      read FOnGetProcStatistics        write FOnGetProcStatistics;
    property OnGetStatistics: TOnGetStatistics
      read FOnGetStatistics            write FOnGetStatistics;
    property OnLogSQLEvent: TOnLogSQLEvent
      read FOnLogSQLEvent              write FOnLogSQLEvent;
    property OnProgressWatch: TProgressWatchEvent
      read FOnProgressWatch            write FOnProgressWatch;
    property OnSetDocTypeBranchEvent: TOnSetDocTypeBranchEvent
      read FOnSetDocTypeBranchEvent    write FOnSetDocTypeBranchEvent;
    property OnSetDocTypeStringsEvent: TOnSetDocTypeStringsEvent
      read FOnSetDocTypeStringsEvent   write FOnSetDocTypeStringsEvent;
  end;

implementation

uses
  mdf_MetaData_unit, gdcInvDocument_unit, contnrs, IBServices, Messages, IBDatabaseInfo;

{ TgsDBSqueeze }

constructor TgsDBSqueeze.Create;
begin
  inherited;

  FIBDatabase := TIBDatabase.Create(nil);

  FCascadeTbls := TStringList.Create;
  FCurrentProgressStep := 0;
end;
//---------------------------------------------------------------------------
destructor TgsDBSqueeze.Destroy;
begin
  if Connected then
    Disconnect;
  FIBDatabase.Free;
  FCascadeTbls.Free;
  if Assigned(FDocTypesList) then
    FDocTypesList.Free;

  inherited;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.Connect(ANoGarbageCollect: Boolean; AOffForceWrite: Boolean);
begin
  if not FIBDatabase.Connected then
  begin
    if FConnectInfo.Port <> 0 then
      FIBDatabase.DatabaseName := FConnectInfo.Host + '/' + IntToStr(FConnectInfo.Port) + ':' + FConnectInfo.DatabaseName
    else
      FIBDatabase.DatabaseName := FConnectInfo.Host + ':' + FConnectInfo.DatabaseName;

    FIBDatabase.LoginPrompt := False;
    FIBDatabase.Params.CommaText :=
      'user_name=' + FConnectInfo.UserName + ',' +
      'password=' + FConnectInfo.Password + ',' +
      'lc_ctype=' + FConnectInfo.CharacterSet;
    if ANoGarbageCollect then
      FIBDatabase.Params.Append('no_garbage_collect');
    if AOffForceWrite then
      FIBDatabase.Params.Append('force_write=0');

    FIBDatabase.Connected := True;
    if Assigned(FOnGetConnectedEvent) then
      FOnGetConnectedEvent(True);
    LogEvent('Connecting to DB... OK');
    CreateUDFs;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.Reconnect(ANoGarbageCollect: Boolean; AOffForceWrite: Boolean);
begin
  LogEvent('Reconnecting to DB...');

  if FIBDatabase.Connected then
  begin
    FIBDatabase.Connected := False;
  end;

  if FConnectInfo.Port <> 0 then
      FIBDatabase.DatabaseName := FConnectInfo.Host + '/' + IntToStr(FConnectInfo.Port) + ':' + FConnectInfo.DatabaseName
  else
      FIBDatabase.DatabaseName := FConnectInfo.Host + ':' + FConnectInfo.DatabaseName;

    FIBDatabase.LoginPrompt := False;
    FIBDatabase.Params.CommaText :=
      'user_name=' + FConnectInfo.UserName + ',' +
      'password=' + FConnectInfo.Password + ',' +
      'lc_ctype=' + FConnectInfo.CharacterSet;
    if ANoGarbageCollect then
      FIBDatabase.Params.Append('no_garbage_collect');
    if AOffForceWrite then
      FIBDatabase.Params.Append('force_write=0');

    FIBDatabase.Connected := True;

  LogEvent('Reconnecting to DB... OK');
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.Disconnect;
begin
  if FIBDatabase.Connected then
  begin
    FIBDatabase.Connected := False;
    LogEvent('Disconnecting from DB... OK');
    FOnGetConnectedEvent(False);
  end;
end;
//---------------------------------------------------------------------------
function TgsDBSqueeze.GetConnected: Boolean;
begin
  Result := FIBDatabase.Connected;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.CreateUDFs;
  
  procedure FuncTest(const AFuncName: String; const ATr: TIBTransaction);     // тест на наличие в UDF-файле функции
  var
    q: TIBSQL;
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := ATr;

      q.SQL.Text := 'SELECT ' + AFuncName;

      if AnsiUpperCase(Trim(AFuncName)) = 'G_HIS_CREATE' then
        q.SQL.Add('(0, 0)')
      else if (AnsiUpperCase(Trim(AFuncName)) = 'G_HIS_INCLUDE') or
        (AnsiUpperCase(Trim(AFuncName)) = 'G_HIS_EXCLUDE') or
        (AnsiUpperCase(Trim(AFuncName)) = 'G_HIS_HAS') then
         q.SQL.Add('(0, 1)')
      else if (AnsiUpperCase(Trim(AFuncName)) = 'G_HIS_DESTROY') or
        (AnsiUpperCase(Trim(AFuncName)) = 'G_HIS_COUNT') then
        q.SQL.Add('(0)');

      q.SQL.Add(' FROM rdb$database');

      try
        ExecSqlLogEvent(q, 'FuncTest');
      except
        on E: Exception do
        begin
          raise EgsDBSqueeze.Create('Error: function ' + AFuncName + ' unknown in UDF library. ' + E.Message);
        end;
      end;
    finally
      q.Free;
    end;
  end;

var
  Tr: TIBTransaction;
  q: TIBSQL;
  begin
    Assert(Connected);

    Tr := TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);
    try
      Tr.DefaultDatabase := FIBDatabase;
      Tr.StartTransaction;

      q.Transaction := Tr;
      try
        if FunctionExist2('G_HIS_CREATE', Tr) then
        begin
          FuncTest('G_HIS_CREATE', Tr);
          LogEvent('Function g_his_create exists.');
        end
        else begin
          q.SQL.Text :=
            'DECLARE EXTERNAL FUNCTION G_HIS_CREATE ' +   #13#10 +
            '  INTEGER, ' +                               #13#10 +
            '  INTEGER ' +                                #13#10 +
            'RETURNS INTEGER BY VALUE ' +                 #13#10 +
            'ENTRY_POINT ''g_his_create'' MODULE_NAME ''gudf'' ';
          ExecSqlLogEvent(q, 'CreateUDFs');
          LogEvent('Function g_his_create has been declared.');
        end;

        if FunctionExist2('G_HIS_INCLUDE', Tr) then
        begin
          FuncTest('G_HIS_INCLUDE', Tr);
          LogEvent('Function g_his_include exists.');
        end
        else begin
          q.SQL.Text :=
            'DECLARE EXTERNAL FUNCTION G_HIS_INCLUDE ' +  #13#10 +
            ' INTEGER, ' +                                #13#10 +
            ' INTEGER ' +                                 #13#10 +
            'RETURNS INTEGER BY VALUE ' +                 #13#10 +
            'ENTRY_POINT ''g_his_include'' MODULE_NAME ''gudf'' ';
          ExecSqlLogEvent(q, 'CreateUDFs');
          LogEvent('Function g_his_include has been declared.');
        end;

        if FunctionExist2('G_HIS_HAS', Tr) then
        begin
          FuncTest('G_HIS_HAS', Tr);
          LogEvent('Function g_his_has exists.');
        end
        else begin
          q.SQL.Text :=
            'DECLARE EXTERNAL FUNCTION G_HIS_HAS ' +      #13#10 +
            ' INTEGER, ' +                                #13#10 +
            ' INTEGER  ' +                                #13#10 +
            'RETURNS INTEGER BY VALUE ' +                 #13#10 +
            'ENTRY_POINT ''g_his_has'' MODULE_NAME ''gudf'' ';
          ExecSqlLogEvent(q, 'CreateUDFs');
          LogEvent('Function g_his_has has been declared.');
        end;

        if FunctionExist2('G_HIS_COUNT', Tr) then
        begin
          FuncTest('G_HIS_COUNT', Tr);
          LogEvent('Function g_his_count exists.');
        end
        else begin
          q.SQL.Text :=
            'DECLARE EXTERNAL FUNCTION G_HIS_COUNT ' +    #13#10 +
            ' INTEGER ' +                                 #13#10 +
            'RETURNS INTEGER BY VALUE ' +                 #13#10 +
            'ENTRY_POINT ''g_his_count'' MODULE_NAME ''gudf'' ';
          ExecSqlLogEvent(q, 'CreateUDFs');
          LogEvent('Function g_his_count has been declared.');
        end;

        if FunctionExist2('G_HIS_EXCLUDE', Tr) then
        begin
          FuncTest('G_HIS_EXCLUDE', Tr);
          LogEvent('Function g_his_exclude exists.');
        end
        else begin
          q.SQL.Text :=
            'DECLARE EXTERNAL FUNCTION G_HIS_EXCLUDE ' +  #13#10 +
            '  INTEGER, ' +                               #13#10 +
            '  INTEGER ' +                                #13#10 +
            'RETURNS INTEGER BY VALUE ' +                 #13#10 +
            'ENTRY_POINT ''g_his_exclude'' MODULE_NAME ''gudf'' ';
          ExecSqlLogEvent(q, 'CreateUDFs');
          LogEvent('Function g_his_exclude has been declared.');
        end;

        if FunctionExist2('G_HIS_DESTROY', Tr) then
        begin
          FuncTest('G_HIS_DESTROY', Tr);
          LogEvent('Function g_his_destroy exists.');
        end
        else begin
          q.SQL.Text :=
            'DECLARE EXTERNAL FUNCTION G_HIS_DESTROY ' +  #13#10 +
            '  INTEGER ' +                                #13#10 +
            'RETURNS INTEGER BY VALUE ' +                 #13#10 +
            'ENTRY_POINT ''g_his_destroy'' MODULE_NAME ''gudf'' ';
          ExecSqlLogEvent(q, 'CreateUDFs');
          LogEvent('Function g_his_destroy has been declared.');
        end;

        {if FunctionExist2('bin_and', Tr) then
        begin
          q.SQL.Text :=
            'DECLARE EXTERNAL FUNCTION bin_and ' +
            ' INTEGER, ' +
            ' INTEGER ' +
            'RETURNS INTEGER BY VALUE ' +
            'ENTRY_POINT ''IB_UDF_bin_and'' MODULE_NAME ''ib_udf'' ';
          q.ExecQuery;
        end;

        if FunctionExist2('bin_or', Tr) then
        begin
          q.SQL.Text :=
            'DECLARE EXTERNAL FUNCTION bin_or ' +
            ' INTEGER, INTEGER ' +
            'RETURNS INTEGER BY VALUE ' +
            'ENTRY_POINT ''IB_UDF_bin_or'' MODULE_NAME ''ib_udf'' ';
          q.ExecQuery;
        end;  }

        Tr.Commit;
      except
        on E: Exception do
        begin
          Tr.Rollback;
          raise EgsDBSqueeze.Create(E.Message);
        end;
      end;
    finally
      q.Free;
      Tr.Free;
    end;
  end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.GetInfoTestConnectEvent;
var
  InfConnectList: TStringList;
  DBInfo: TIBDatabaseInfo;
  ODSMajor, ODSMinor: Integer;
begin
  if Connected then
  begin
    DBInfo := TIBDatabaseInfo.Create(nil);
    DBInfo.Database := FIBDatabase;
    InfConnectList := TStringList.Create;
    try
      ODSMajor := DBInfo.ODSMajorVersion;
      ODSMinor := DBInfo.ODSMinorVersion;

      InfConnectList.Append('ActivConnectCount=' + IntToStr((DBInfo.UserNames).Count));

      try
        case ODSMajor of
          8:
            begin
              InfConnectList.Append('ServerName=InterBase');
              if ODSMinor = 0 then
                InfConnectList.Append('ServerVersion=4.0/4.1')
              else if ODSMinor = 2 then
                InfConnectList.Append('ServerVersion=4.2')
              else
                raise EgsDBSqueeze.Create('Wrong ODS-version');
            end;
          9:
            begin
              InfConnectList.Append('ServerName=InterBase');
              if ODSMinor = 0 then
                InfConnectList.Append('ServerVersion=5.0/5.1')
              else if ODSMinor = 1 then
                InfConnectList.Append('ServerVersion=5.5/5.6')
              else
                raise EgsDBSqueeze.Create('Wrong ODS-version');
            end;
          10:
            begin
              if ODSMinor = 0 then
              begin
                InfConnectList.Append('ServerName=Firebird/Yaffil');
                InfConnectList.Append('ServerVersion=1.0');
              end
              else if ODSMinor = 1 then
              begin
                InfConnectList.Append('ServerName=Firebird');
                InfConnectList.Append('ServerVersion=1.5');
              end
              else
                raise EgsDBSqueeze.Create('Wrong ODS-version');
            end;
          11:
            begin
              InfConnectList.Append('ServerName=Firebird');
              case ODSMinor of
                0: InfConnectList.Append('ServerVersion=2.0');
                1: InfConnectList.Append('ServerVersion=2.1');
                2: InfConnectList.Append('ServerVersion=2.5');
              else
                raise EgsDBSqueeze.Create('Wrong ODS-version');
              end;
            end;
          12:
            begin
              InfConnectList.Append('ServerName=InterBase');
              if ODSMinor = 0 then
                InfConnectList.Append('ServerVersion=2007')
              else
                raise EgsDBSqueeze.Create('Wrong ODS-version');
            end;
          13:
            begin
              InfConnectList.Append('ServerName=InterBase');
              if ODSMinor = 1 then
                InfConnectList.Append('ServerVersion=2009')
              else
                raise EgsDBSqueeze.Create('Wrong ODS-version');
            end;
          15:
            begin
              InfConnectList.Append('ServerName=InterBase');
              if ODSMinor = 0 then
                InfConnectList.Append('ServerVersion=XE/XE3')
              else
                raise EgsDBSqueeze.Create('Wrong ODS-version');
            end;
        else
          raise EgsDBSqueeze.Create('Wrong ODS-version');
        end;
      except
        on E: EgsDBSqueeze do
        raise EgsDBSqueeze.Create(E.Message+ ': ' + IntToStr(ODSMajor) + '.' +  IntToStr(ODSMinor));
      end;

      FOnGetInfoTestConnectEvent(True, InfConnectList);
    finally
      InfConnectList.Free;
      FreeAndNil(DBInfo);
    end;
  end
  else
    FOnGetInfoTestConnectEvent(False, nil);
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.UsedDBEvent;                                             
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;

    if RelationExist2('DBS_JOURNAL_STATE', Tr) then
    begin
      q.SQL.Text :=
        'SELECT FIRST(1) * ' +                          #13#10 +
        'FROM dbs_journal_state ' +                     #13#10 +
        'ORDER BY call_time DESC';
      ExecSqlLogEvent(q, 'UsedDBEvent');

      LogEvent('Warning: It''s USED DB! ');
      LogEvent('Latest operation: CALL_TIME=' + q.FieldByName('CALL_TIME').AsString +
        ', Message FUNCTIONKEY=WM_USER+' + IntToStr(q.FieldByName('FUNCTIONKEY').AsInteger - WM_USER) +
        ', SUCCESSFULLY=' + q.FieldByName('STATE').AsString);

      q.Close;
    end;
    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.CreateDBSStateJournal;
var                                                                             ///TODO: отпала необходимость
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;

    if not RelationExist2('DBS_JOURNAL_STATE', Tr) then
    begin
      q.SQL.Text :=
        'CREATE TABLE DBS_JOURNAL_STATE( ' +            #13#10 +
        '  FUNCTIONKEY   INTEGER, ' +                   #13#10 +
        '  STATE         SMALLINT, ' +                  #13#10 +  // 1-успешно,0-ошибка, NULL-выполнение было прервано пользователем
        '  CALL_TIME     TIMESTAMP, ' +                 #13#10 +
        '  ERROR_MESSAGE VARCHAR(32000))';
      ExecSqlLogEvent(q, 'CreateDBSStateJournal');
      LogEvent('Table DBS_JOURNAL_STATE has been created.');
    end
    else begin
      LogEvent('Table DBS_JOURNAL_STATE exists.');
      q.SQL.Text:=
        'SELECT COUNT(*) FROM dbs_journal_state';
      ExecSqlLogEvent(q, 'CreateDBSStateJournal');
      if q.RecordCount <> 0 then  // БД уже обрабатывалась программой
        UsedDBEvent;
      q.Close;
    end;

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.InsertDBSStateJournal(
  const AFunctionKey: Integer;
  const AState: Integer;
  const AErrorMsg: String = '');
var
  q: TIBSQL;
  Tr: TIBTransaction;
  NowDT: TDateTime;
begin
  Assert(Connected);
  NowDT := Now;
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;

    q.SQL.Text :=
      'INSERT INTO dbs_journal_state ' +                #13#10 +
      'VALUES(:FunctionKey, :State, :Now, :ErrorMsg)';
    q.ParamByName('FunctionKey').AsInteger := AFunctionKey;
    q.ParamByName('State').AsInteger := AState;
    q.ParamByName('Now').AsDateTime := NowDT;
    if AErrorMsg = '' then
      q.ParamByName('ErrorMsg').Clear
    else
      q.ParamByName('ErrorMsg').AsString := AErrorMsg;

    if AErrorMsg <> '' then
      ExecSqlLogEvent(q, 'InsertDBSStateJournal')
    else
      ExecSqlLogEvent(q, 'InsertDBSStateJournal');

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.DropDBSStateJournal;
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;

    q.SQL.Text :=
      'DROP TABLE dbs_journal_state ';
    ExecSqlLogEvent(q, 'InsertDBSStateJournal');

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.SetDocTypeStringsEvent;
var
  Tr: TIBTransaction;
  q, q2: TIBSQL;
  DocTypeList: TStringList;   // Список типов документов
  DocTypeBranch: TStringList; // Список ветви типов документов
  I: Integer;

  function GetChildListStr(AParent: Integer): String;
  var
    Tr: TIBTransaction;
    q: TIBSQL;
  begin
    Tr := TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);

    try
      Tr.DefaultDatabase := FIBDatabase;
      Tr.StartTransaction;
      q.Transaction := Tr;

      q.SQL.Text :=
        'SELECT LIST(id || ''='' || name) AS Childs ' +
        'FROM ( ' +
        '  SELECT id, name ' +
        '  FROM gd_documenttype ' +
        '  WHERE documenttype = ''B'' ' +
        '    AND parent = :ParentID ' +
        '  ORDER BY name) ';

      q.ParamByName('ParentID').AsInteger := AParent;
      ExecSqlLogEvent(q, 'SetDocTypeStringsEvent');

      Result := q.FieldByName('Childs').AsString;

      Tr.Commit;
    finally
      q.Free;
      Tr.Free;
    end;
  end;

  procedure AddBranchChildInList(AParent: Integer; ALevel: String);
  var
   I: Integer;
   ChildsList: TStringList;
  begin
    ChildsList := TStringList.Create;
    try
      ChildsList.Text := StringReplace(GetChildListStr(AParent), ',', #13#10, [rfReplaceAll, rfIgnoreCase]);

      if ChildsList.Count <> 0 then
      begin
        for I:=0 to ChildsList.Count-1 do
        begin
          try
            DocTypeBranch.Add(ChildsList.Names[I] + '=' + ALevel + ChildsList.Values[ChildsList.Names[I]]);

            AddBranchChildInList(StrToInt(ChildsList.Names[I]), ALevel + #9);
          except
            LogEvent(ChildsList.Names[I]);
          end;
        end;
      end;
    finally
      FreeAndNil(ChildsList);
    end;
  end;

begin
  Assert(FIBDatabase.Connected and Assigned(FOnSetDocTypeStringsEvent));

  DocTypeList := TStringList.Create;
  DocTypeBranch := TStringList.Create;
  
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q2.Transaction := Tr;

    q.SQL.Text :=
      'SELECT ' +                     #13#10 +
      '  id, ' +                      #13#10 +
      '  name ' +                     #13#10 +
      'FROM gd_documenttype ' +       #13#10 +
      'WHERE ' +                      #13#10 +
      '  parent IS NULL ' +           #13#10 +
      '  AND documenttype = ''B'' ' + #13#10 +
      'ORDER BY name';
    ExecSqlLogEvent(q, 'SetDocTypeStringsEvent');
    while not q.EOF do
    begin
      DocTypeBranch.Add(q.FieldByName('id').AsString + '=' + q.FieldByName('name').AsString);
      AddBranchChildInList(q.FieldByName('id').AsInteger, #9);

      q.Next;
    end;
    q.Close;

    for I:=0 to DocTypeBranch.Count-1 do
    begin
      q.SQL.Text :=
        'SELECT ' +                                                             #13#10 +
        '  LIST(TRIM(dt.id) || ''='' || TRIM(dt.name), ''||'') AS DocType ' +   #13#10 +
        'FROM ( ' +                                                             #13#10 +
        '  SELECT id, name ' +                                                  #13#10 +
        '  FROM GD_DOCUMENTTYPE ' +                                             #13#10 +
        '  WHERE documenttype = ''D'' ' +                                       #13#10 +
        '    AND parent = :Branch ' +                                           #13#10 +
        '  ORDER BY name ' +                                                    #13#10 +
        ') dt ';
      q.ParamByName('Branch').AsString := DocTypeBranch.Names[I];
      ExecSqlLogEvent(q, 'SetDocTypeStringsEvent');

      if (not q.EOF) and (q.FieldByName('DocType').AsString <> '') then
      begin
        DocTypeList.Append(q.FieldByName('DocType').AsString);
      end
      else begin
        DocTypeList.Append(IntToStr(GetNewID)+'=0');
      end;
      q.Close;
    end;

    for I:=0 to DocTypeBranch.Count-1 do
    begin
      DocTypeBranch[I] := DocTypeBranch.Values[DocTypeBranch.Names[I]];
    end;

    q.SQL.Text :=
      'SELECT ' +                                                               #13#10 +
      '  LIST(TRIM(dt.id) || ''='' || TRIM(dt.name), ''||'') AS DocType ' +     #13#10 +
      'FROM ( ' +                                                               #13#10 +
      '  SELECT id, name ' +                                         #13#10 +
      '  FROM GD_DOCUMENTTYPE ' +                                    #13#10 +
      '  WHERE documenttype = ''D'' ' +                              #13#10 +
      '    AND parent IS NULL ' +                                    #13#10 +
      '  ORDER BY name ' +                                           #13#10 +
      ') dt ';
    ExecSqlLogEvent(q, 'SetDocTypeStringsEvent');
    if not q.EOF then
    begin
      DocTypeList.Append(q.FieldByName('DocType').AsString);
      DocTypeBranch.Add('Непривязанные к ветви');
    end;
    q.Close;

    FOnSetDocTypeBranchEvent(DocTypeBranch);
    FOnSetDocTypeStringsEvent(DocTypeList);

    Tr.Commit;
  finally
    q.Free;
    q2.Free;
    Tr.Free;
    DocTypeList.Free;
    DocTypeBranch.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.GetInvCardFeaturesEvent;
var
  Tr: TIBTransaction;
  q: TIBSQL;
  CardFeaturesList: TStringList;   // Список признаков карточек
begin
  Assert(FIBDatabase.Connected and Assigned(FOnGetInvCardFeaturesEvent));

  CardFeaturesList := TStringList.Create;

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;

    q.SQL.Text :=
      'SELECT ' +                            #13#10 +
      '  TRIM(rf.lname)     AS lname, ' +    #13#10 +
      '  TRIM(rf.fieldname) AS fieldname ' + #13#10 +
      'FROM ' +                              #13#10 +
      '  AT_RELATION_FIELDS rf ' +           #13#10 +
      'WHERE ' +                             #13#10 +
      '  rf.relationname = ''INV_CARD'' ' +  #13#10 +
      '  AND rf.fieldname LIKE ''USR$%'' ' + #13#10 +
      'ORDER BY 1';
    ExecSqlLogEvent(q, 'GetInvCardFeaturesEvent');
    while not q.EOF do
    begin
      CardFeaturesList.Append(q.FieldByName('fieldname').AsString + '=' + q.FieldByName('lname').AsString);
      q.Next;
    end;

    FOnGetInvCardFeaturesEvent(CardFeaturesList);

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
    CardFeaturesList.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.GetDBPropertiesEvent;
var
  DBInfo: TIBDatabaseInfo;
  ODSMajor, ODSMinor: Integer;
  q: TIBSQL;
  Tr: TIBTransaction;
  DBPropertiesList: TStringList; // Association list
begin
  Assert(Connected);

  DBInfo := TIBDatabaseInfo.Create(nil);
  DBInfo.Database := FIBDatabase;
  DBPropertiesList := TStringList.Create;
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    ODSMajor := DBInfo.ODSMajorVersion;
    ODSMinor := DBInfo.ODSMinorVersion;

    try
      case ODSMajor of
        8:
          begin
            if ODSMinor = 0 then
              DBPropertiesList.Append('Server=IB 4.0/4.1')
            else if ODSMinor = 2 then
              DBPropertiesList.Append('Server=IB 4.2')
            else
              raise EgsDBSqueeze.Create('Wrong ODS-version');
          end;
        9:
          begin
            if ODSMinor = 0 then
              DBPropertiesList.Append('Server=IB 5.0/5.1')
            else if ODSMinor = 1 then
              DBPropertiesList.Append('Server=IB 5.5/5.6')
            else
              raise EgsDBSqueeze.Create('Wrong ODS-version');
          end;
        10:
          begin
            if ODSMinor = 0 then
            begin
              DBPropertiesList.Append('Server=FB 1.0/Yaffil');
            end
            else if ODSMinor = 1 then
            begin
              DBPropertiesList.Append('ServerVersion=FB 1.5');
            end
            else
              raise EgsDBSqueeze.Create('Wrong ODS-version');
          end;
        11:
          begin
            case ODSMinor of
              0: DBPropertiesList.Append('Server=FB 2.0');
              1: DBPropertiesList.Append('Server=FB 2.1');
              2: DBPropertiesList.Append('Server=FB 2.5');
            else
              raise EgsDBSqueeze.Create('Wrong ODS-version');
            end;
          end;
        12:
          begin
            if ODSMinor = 0 then
              DBPropertiesList.Append('Server=IB 2007')
            else
              raise EgsDBSqueeze.Create('Wrong ODS-version');
          end;
        13:
          begin
            if ODSMinor = 1 then
              DBPropertiesList.Append('Server=IB 2009')
            else
              raise EgsDBSqueeze.Create('Wrong ODS-version');
          end;
        15:
          begin
            if ODSMinor = 0 then
              DBPropertiesList.Append('Server=IB XE/XE3')
            else
              raise EgsDBSqueeze.Create('Wrong ODS-version');
          end;
      else
        raise EgsDBSqueeze.Create('Wrong ODS-version');
      end;
    except
      on E: EgsDBSqueeze do
      raise EgsDBSqueeze.Create(E.Message+ ': ' + IntToStr(ODSMajor) + '.' +  IntToStr(ODSMinor));
    end;

    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;

    DBPropertiesList.Append('DBName=' + DBInfo.DBFileName);
    DBPropertiesList.Append('ODS=' + IntToStr(ODSMajor) + '.' + IntToStr(ODSMinor));
    DBPropertiesList.Append('PageSize=' + IntToStr(DBInfo.PageSize));
    DBPropertiesList.Append('SQLDialect=' + IntToStr(DBInfo.DBSQLDialect));
    DBPropertiesList.Append('ForcedWrites=' + IntToStr(DBInfo.ForcedWrites));

    FDBPageSize := DBInfo.PageSize;
    
    if RelationExist2('MON$DATABASE', Tr) then
    begin
      q.SQL.Text :=
        'SELECT ' +                                             #13#10 +
        '  mon$database_name   AS DBName, ' +                   #13#10 +
        '  mon$ods_major||''.''||mon$ods_minor AS ODS, ' +      #13#10 +
        '  mon$page_size       AS PageSize, ' +                 #13#10 +
        '  mon$page_buffers    AS PageBuffers, ' +              #13#10 +
        '  mon$sql_dialect     AS SQLDialect, ' +               #13#10 +
        '  mon$forced_writes   AS ForcedWrites ' +              #13#10 +
        'FROM mon$database ';
      ExecSqlLogEvent(q, 'GetDBPropertiesEvent');

      FDBPageBuffers :=  q.FieldByName('PageBuffers').AsInteger;

      DBPropertiesList.Append('PageBuffers=' + q.FieldByName('PageBuffers').AsString);
      q.Close;
    end
    else begin
      DBPropertiesList.Append('PageBuffers=' + '-');
    end;

    if RelationExist2('MON$ATTACHMENTS', Tr) then
    begin
      q.SQL.Text :=
        'SELECT ' +                                             #13#10 +
        '  mon$user               AS U, ' +                     #13#10 +
        '  mon$remote_protocol    AS RemProtocol, ' +           #13#10 +
        '  mon$remote_address     AS RemAddress, ' +            #13#10 +
        '  mon$garbage_collection AS GarbCollection ' +         #13#10 +
        'FROM mon$attachments ' +                               #13#10 +
        'WHERE mon$attachment_id = CURRENT_CONNECTION ';
      ExecSqlLogEvent(q, 'GetDBPropertiesEvent');
      DBPropertiesList.Append('User=' + Trim(q.FieldByName('U').AsString));
      DBPropertiesList.Append('RemoteProtocol=' + Trim(q.FieldByName('RemProtocol').AsString));
      DBPropertiesList.Append('RemoteAddress=' + q.FieldByName('RemAddress').AsString);
      DBPropertiesList.Append('GarbageCollection=' + q.FieldByName('GarbCollection').AsString);
      q.Close;
    end
    else begin
      DBPropertiesList.Append('User=' + '-');
      DBPropertiesList.Append('RemoteProtocol=' + '-');
      DBPropertiesList.Append('RemoteAddress=' + '-');
      DBPropertiesList.Append('GarbageCollection=' + '-');
    end;

    FOnGetDBPropertiesEvent(DBPropertiesList);

    Tr.Commit;
  finally
    FreeAndNil(DBInfo);
    DBPropertiesList.Free;
    q.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.GetStatisticsEvent;
var
  q1, q2, q3, q4: TIBSQL;
  Tr: TIBTransaction;
begin
  LogEvent('Getting statistics...');
  ProgressMsgEvent('Получение статистики...', 0);
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q1 := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  q3 := TIBSQL.Create(nil);
  q4 := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q1.Transaction := Tr;
    q2.Transaction := Tr;
    q3.Transaction := Tr;
    q4.Transaction := Tr;

    q1.SQL.Text :=
      'SELECT COUNT(id) AS Kolvo FROM gd_document';
    ExecSqlLogEvent(q1, 'GetStatisticsEvent');

    q2.SQL.Text :=
      'SELECT COUNT(id) AS Kolvo FROM ac_entry';
    if not FDoStopProcessing then
      ExecSqlLogEvent(q2, 'GetStatisticsEvent');

    q3.SQL.Text :=
      'SELECT COUNT(id) AS Kolvo FROM inv_movement';
    if not FDoStopProcessing then
      ExecSqlLogEvent(q3, 'GetStatisticsEvent');

    q4.SQL.Text :=
      'SELECT COUNT(id) AS Kolvo FROM inv_card';
    if not FDoStopProcessing then
    begin
      ExecSqlLogEvent(q4, 'GetStatisticsEvent');

      FOnGetStatistics(
        q1.FieldByName('Kolvo').AsString,
        q2.FieldByName('Kolvo').AsString,
        q3.FieldByName('Kolvo').AsString,
        q4.FieldByName('Kolvo').AsString
      );

      LogEvent('Getting statistics... OK');
      Tr.Commit;
    end;
    ProgressMsgEvent('', 0);
  finally
    q1.Free;
    q2.Free;
    q3.Free;
    q4.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.GetProcStatisticsEvent;
var
  q1, q2, q3, q4: TIBSQL;
  Tr: TIBTransaction;
begin
  LogEvent('Getting processing statistics...');
  Assert(Connected);
  
  Tr := TIBTransaction.Create(nil);
  q1 := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  q3 := TIBSQL.Create(nil);
  q4 := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;

    CreateHIS(0);

    Tr.StartTransaction;
    q1.Transaction := Tr;
    q2.Transaction := Tr;
    q3.Transaction := Tr;
    q4.Transaction := Tr;

    q1.SQL.Text :=
      'SELECT COUNT(g_his_include(0, doc.id)) AS Kolvo ' + #13#10 +
      '  FROM gd_document doc ' +                          #13#10 +
      ' WHERE doc.documentdate < :ClosingDate ';
    if Assigned(FDocTypesList) then
    begin
      if not FDoProcDocTypes then
        q1.SQL.Add(' ' +
          '   AND doc.documenttypekey NOT IN(' + FDocTypesList.CommaText + ') ')
      else
        q1.SQL.Add(' ' +
          '   AND doc.documenttypekey IN(' + FDocTypesList.CommaText + ') ');
    end;

    q1.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    ExecSqlLogEvent(q1, 'GetProcStatisticsEvent');

    q2.SQL.Text :=
      'SELECT COUNT(ae.id) AS Kolvo ' +                 #13#10 +
      'FROM ac_entry ae ' +                             #13#10 +
      'WHERE ' +                                        #13#10 +
      '  g_his_has(0, ae.documentkey)= 1 ' +            #13#10 +
      '  OR g_his_has(0, ae.masterdockey)=1 ';
    if not FDoStopProcessing then
      ExecSqlLogEvent(q2, 'GetProcStatisticsEvent');

    q3.SQL.Text :=
      'SELECT COUNT(im.id) AS Kolvo ' +                 #13#10 +
      '  FROM inv_movement im ' +                       #13#10 +
      ' WHERE g_his_has(0, im.documentkey)=1 ';

    if not FDoStopProcessing then
      ExecSqlLogEvent(q3, 'GetProcStatisticsEvent');

    q4.SQL.Text :=
      'SELECT COUNT(ic.id) AS Kolvo ' +                  #13#10 +
      'FROM inv_card ic ' +                              #13#10 +
      'WHERE ' +                                         #13#10 +
      '  g_his_has(0, ic.documentkey)=1 ' +              #13#10 +
      '  OR g_his_has(0, ic.firstdocumentkey)=1';
    if not FDoStopProcessing then
    begin
      ExecSqlLogEvent(q4, 'GetProcStatisticsEvent');

    FOnGetProcStatistics(
      q1.FieldByName('Kolvo').AsString,
      q2.FieldByName('Kolvo').AsString,
      q3.FieldByName('Kolvo').AsString,
      q4.FieldByName('Kolvo').AsString
    );
     Tr.Commit;

    end;
    DestroyHIS(0);
    LogEvent('Getting processing statistics... OK');

    
    ProgressMsgEvent(' ', 0);
  finally
    q1.Free;
    q2.Free;
    q3.Free;
    q4.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
function TgsDBSqueeze.CreateHIS(AnIndex: Integer): Integer;
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);	
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;

    q.SQL.Text := Format(
      'SELECT g_his_create(%d, 0) FROM rdb$database', [AnIndex]);
    ExecSqlLogEvent(q, 'CreateHIS');

    Result :=  q.Fields[0].AsInteger;
    q.Close;

    Tr.Commit;
 
    if Result = 1 then
      LogEvent(Format('HIS[%d] создан успешно.', [AnIndex]))
    else begin
      LogEvent(Format('Попытка создания HIS[%d] завершилась неудачей!', [AnIndex]));
      raise EgsDBSqueeze.Create('Error create HugeIntSet!');
    end;         
  finally
    q.Free;
    Tr.Free;  
  end;
end;
//---------------------------------------------------------------------------
function TgsDBSqueeze.GetCountHIS(AnIndex: Integer): Integer;
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;

    q.SQL.Text := Format(
      'SELECT g_his_count(%d) FROM rdb$database', [AnIndex]);
    ExecSqlLogEvent(q, 'GetCountHIS');

    Result := q.Fields[0].AsInteger;
    q.Close;

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
function TgsDBSqueeze.DestroyHIS(AnIndex: Integer): Integer;
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;

    q.SQL.Text := Format(
      'SELECT g_his_destroy(%d) FROM rdb$database', [AnIndex]);
    ExecSqlLogEvent(q, 'DestroyHIS');

    Result :=  q.Fields[0].AsInteger;
    q.Close;

    Tr.Commit;

    if Result = 1 then
      LogEvent(Format('HIS[%d] разрушен успешно.', [AnIndex]))
    else begin
      LogEvent(Format('Попытка разрушения HIS[%d] завершилась неудачей!', [AnIndex]));
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.SetSelectDocTypes(const ADocTypesList: TStringList);
begin
  if not Assigned(FDocTypesList) then
    FDocTypesList := TStringList.Create
  else
    FDocTypesList.Clear;
  FDocTypesList.Text := ADocTypesList.Text;
  LogEvent('Setting selected document types... OK');
end;
//---------------------------------------------------------------------------
function TgsDBSqueeze.GetNewID: Integer; // return next unique id
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;

    q.SQL.Text :=
      'SELECT ' +                                                       #13#10 +
      '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0) AS NewID ' +   #13#10 +
      'FROM ' +                                                         #13#10 +
      '  rdb$database ';
    ExecSqlLogEvent(q, 'GetNewID');

    Result := q.FieldByName('NewID').AsInteger;
  finally
    q.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.SetFVariables;
var
  q, q2: TIBSQL;
  Tr: TIBTransaction;
begin
  LogEvent('Initializing class members... ');
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q2.Transaction := Tr;

    q.SQL.Text :=
      'SELECT gu.contactkey AS CurUserContactKey ' +    #13#10 +
      '  FROM gd_user gu ' +                            #13#10 +
      ' WHERE gu.ibname = CURRENT_USER';
    ExecSqlLogEvent(q, 'SetFVariables');

    if q.EOF then
      raise EgsDBSqueeze.Create('Invalid GD_USER data');
    FCurUserContactKey := q.FieldByName('CurUserContactKey').AsInteger;
    q.Close;

    q.SQL.Text :=
      'SELECT ' +                                       #13#10 +
      '  TRIM(rf.rdb$field_name) AS UsrFieldName ' +    #13#10 +
      'FROM ' +                                         #13#10 +
      '  rdb$relation_fields rf ' +                     #13#10 +
      'WHERE ' +                                        #13#10 +
      '  rf.rdb$relation_name = ''AC_ACCOUNT'' ' +      #13#10 +
      '  AND rf.rdb$field_name LIKE ''USR$%'' ';
    ExecSqlLogEvent(q, 'SetFVariables');

    while not q.EOF do
    begin
      q2.SQL.Text :=
        'SELECT * ' +                                   #13#10 +
        '  FROM RDB$RELATION_FIELDS ' +                 #13#10 +
        ' WHERE rdb$relation_name = ''AC_ENTRY'' ' +    #13#10 +
        '   AND TRIM(rdb$field_name) = :FN ';
      q2.ParamByName('FN').AsString := q.FieldByName('UsrFieldName').AsString;
      ExecSqlLogEvent(q2, 'SetFVariables');
      if not q2.EOF then
      begin
        if FEntryAnalyticsStr > '' then
          FEntryAnalyticsStr := FEntryAnalyticsStr + ',' + q.FieldByName('UsrFieldName').AsString
        else
          FEntryAnalyticsStr := q.FieldByName('UsrFieldName').AsString;
      end;
      q2.Close;
      q.Next;
    end;
    q.Close;

    q.SQL.Text :=
      'SELECT LIST( ' +                                 #13#10 +
      '  TRIM(rf.rdb$field_name)) AS UsrFieldsList ' +  #13#10 +
      'FROM ' +                                         #13#10 +
      '  rdb$relation_fields rf ' +                     #13#10 +
      'WHERE ' +                                        #13#10 +
      '  rf.rdb$relation_name = ''INV_CARD'' ' +        #13#10 +
      '  AND rf.rdb$field_name LIKE ''USR$%'' ';
    ExecSqlLogEvent(q, 'SetFVariables');

    if not q.EOF then
      FCardFeaturesStr := q.FieldByName('UsrFieldsList').AsString;
    q.Close;

    q.SQL.Text :=
      'SELECT gd.id AS InvDocTypeKey ' +                #13#10 +
      '  FROM GD_DOCUMENTTYPE gd ' +                    #13#10 +
      ' WHERE TRIM(gd.name) = ''Произвольный тип'' ';
    ExecSqlLogEvent(q, 'CreateInvSaldo');

    if q.EOF then
      raise EgsDBSqueeze.Create('Отсутствует запись GD_DOCUMENTTYPE.NAME = ''Произвольный тип''');
    FProizvolnyyDocTypeKey := q.FieldByName('InvDocTypeKey').AsInteger;
    q.Close;  
  
    if FAllOurCompaniesSaldo then
    begin
      q.SQL.Text :=
        'SELECT LIST(companykey) AS OurCompaniesList ' + #13#10 +
        '  FROM gd_ourcompany';
      ExecSqlLogEvent(q, 'CalculateAcSaldo');

      if not q.EOF then
        FOurCompaniesListStr := q.FieldByName('OurCompaniesList').AsString;
      q.Close;
    end;

   { q.SQL.Text :=
      'SELECT id ' +                                    #13#10 +
      '  FROM gd_contact ' +                            #13#10 +
      ' WHERE name = ''Псевдоклиент'' ';
    ExecSqlLogEvent(q, 'CreateInvSaldo');
    if q.EOF then // если Псевдоклиента не существует, то создадим
    begin
      q.Close;
      q.SQL.Text :=
        'SELECT gc.id AS ParentId ' +                   #13#10 +
        '  FROM gd_contact gc ' +                       #13#10 +
        ' WHERE gc.name = ''Организации'' ';
      ExecSqlLogEvent(q, 'CreateInvSaldo');

      FPseudoClientKey := GetNewID;

      q2.SQL.Text :=
        'INSERT INTO GD_CONTACT ( ' +                   #13#10 +
        '  id, ' +                                      #13#10 +
        '  parent, ' +                                  #13#10 +
        '  name, ' +                                    #13#10 +
        '  contacttype, ' +                             #13#10 +
        '  afull, ' +                                   #13#10 +
        '  achag, ' +                                   #13#10 +
        '  aview) ' +                                   #13#10 +
        'VALUES (' +                                    #13#10 +
        '  :id, ' +                                     #13#10 +
        '  :parent, ' +                                 #13#10 +
        '  ''Псевдоклиент'', ' +                        #13#10 +
        '  3, ' +                                       #13#10 +
        '  -1, ' +                                      #13#10 +
        '  -1, ' +                                      #13#10 +
        '  -1)';
      q2.ParamByName('id').AsInteger := FPseudoClientKey;
      q2.ParamByName('parent').AsInteger := q.FieldByName('ParentId').AsInteger;

      ExecSqlLogEvent(q2, 'CreateInvSaldo');
    end
    else
      FPseudoClientKey := q.FieldByName('id').AsInteger;
    }
    FInvSaldoDoc := GetNewID;

    q.Close;
    Tr.Commit;
    LogEvent('Initializing class members... OK');
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.CreateMetadata;
var
  q: TIBSQL;
  q2: TIBSQL;
  Tr: TIBTransaction;

 { procedure CreateDBSTmpProcessedTbls;
  begin
    if RelationExist2('DBS_TMP_PROCESSED_TABLES', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM dbs_tmp_processed_tables';
      ExecSqlLogEvent(q, 'CreateDBSTmpProcessedTbls');
      LogEvent('Table DBS_TMP_PROCESSED_TABLES exists.');
    end
    else begin
      q.SQL.Text :=
        'CREATE TABLE DBS_TMP_PROCESSED_TABLES ( ' +    #13#10 +
        '  RELATION_NAME VARCHAR(31), ' +               #13#10 +
        '  constraint PK_DBS_TMP_PROCESSED_TABLES primary key (RELATION_NAME))';
      ExecSqlLogEvent(q, 'CreateDBSTmpProcessedTbls');
      LogEvent('Table DBS_TMP_PROCESSED_TABLES has been created.');
    end;
  end;    }

  procedure CreateDBSTmpAcSaldo;
  begin
    if RelationExist2('DBS_TMP_AC_SALDO', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM dbs_tmp_ac_saldo';
      ExecSqlLogEvent(q, 'CreateDBSTmpAcSaldo');
      LogEvent('Table DBS_TMP_AC_SALDO exists.');
    end
    else begin
      q2.SQL.Text :=
        'SELECT LIST( ' +                                               #13#10 +
        '  TRIM(rf.rdb$field_name) || '' '' || ' +                      #13#10 +
        '  CASE f.rdb$field_type ' +                                    #13#10 +
        '    WHEN 7 THEN ' +                                            #13#10 +
        '      CASE f.rdb$field_sub_type ' +                            #13#10 +
        '        WHEN 0 THEN '' SMALLINT'' ' +                          #13#10 +
        '        WHEN 1 THEN '' NUMERIC('' || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' +  #13#10 +
        '        WHEN 2 THEN '' DECIMAL(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' + #13#10 +
        '      END ' +                                                  #13#10 +
        '    WHEN 8 THEN ' +                                            #13#10 +
        '      CASE f.rdb$field_sub_type ' +                            #13#10 +
        '        WHEN 0 THEN '' INTEGER'' ' +                           #13#10 +
        '        WHEN 1 THEN '' NUMERIC(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' + #13#10 +
        '        WHEN 2 THEN '' DECIMAL(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' + #13#10 +
        '      END ' +                                                  #13#10 +
        '    WHEN 9 THEN '' QUAD'' ' +                                  #13#10 +
        '    WHEN 10 THEN '' FLOAT'' ' +                                #13#10 +
        '    WHEN 12 THEN '' DATE'' ' +                                 #13#10 +
        '    WHEN 13 THEN '' TIME'' ' +                                 #13#10 +
        '    WHEN 14 THEN '' CHAR('' || (TRUNC(f.rdb$field_length / ch.rdb$bytes_per_character)) || '')'' ' +      #13#10 +
        '    WHEN 16 THEN ' +                                           #13#10 +
        '      CASE f.rdb$field_sub_type ' +                            #13#10 +
        '        WHEN 0 THEN '' BIGINT'' ' +                            #13#10 +
        '        WHEN 1 THEN '' NUMERIC(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' + #13#10 +
        '        WHEN 2 THEN '' DECIMAL(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' + #13#10 +
        '      END ' +                                                  #13#10 +
        '    WHEN 27 THEN '' DOUBLE'' ' +                               #13#10 +
        '    WHEN 35 THEN '' TIMESTAMP'' ' +                            #13#10 +
        '    WHEN 37 THEN '' VARCHAR('' || (TRUNC(f.rdb$field_length / ch.rdb$bytes_per_character)) || '')'' ' +   #13#10 +
        '    WHEN 40 THEN '' CSTRING('' || (TRUNC(f.rdb$field_length / ch.rdb$bytes_per_character)) || '')'' ' +   #13#10 +
        '    WHEN 45 THEN '' BLOB_ID'' ' +                              #13#10 +
        '    WHEN 261 THEN '' BLOB'' ' +                                #13#10 +
        '    ELSE '' RDB$FIELD_TYPE:?'' ' +                             #13#10 +
        '  END)  AS AllUsrFieldsList ' +                                #13#10 +
        'FROM rdb$relation_fields rf ' +                                #13#10 +
        '  JOIN rdb$fields f ON (f.rdb$field_name = rf.rdb$field_source) ' +                                       #13#10 +
        '  LEFT OUTER JOIN rdb$character_sets ch ON (ch.rdb$character_set_id = f.rdb$character_set_id) ' +         #13#10 +
        'WHERE ' +                                                      #13#10 +
        '  rf.rdb$relation_name = ''AC_ENTRY'' ' +                      #13#10 +
        '  AND rf.rdb$field_name LIKE ''USR$%'' ' +                     #13#10 +
        '  AND COALESCE(rf.rdb$system_flag, 0) = 0 ';
      ExecSqlLogEvent(q2, 'CreateDBSTmpAcSaldo');

      q.SQL.Text :=
        'CREATE TABLE DBS_TMP_AC_SALDO ( ' +            #13#10 +
        '  ID           INTEGER, ' +                    #13#10 +
        '  ID_OSTATKY   INTEGER, ' +                    #13#10 +
        '  COMPANYKEY   INTEGER, ' +                    #13#10 +
        '  CURRKEY      INTEGER, ' +                    #13#10 +
        '  ACCOUNTKEY   INTEGER, ' +                    #13#10 +
        '  MASTERDOCKEY INTEGER, ' +                    #13#10 +
        '  DOCUMENTKEY  INTEGER, ' +                    #13#10 +
        '  RECORDKEY    INTEGER, ' +                    #13#10 +
        '  RECORDKEY_OSTATKY INTEGER, ' +               #13#10 +
        '  ACCOUNTPART  VARCHAR(1), ' +                 #13#10 +
        '  CREDITNCU    DECIMAL(15,4), ' +              #13#10 +
        '  CREDITCURR   DECIMAL(15,4), ' +              #13#10 +
        '  CREDITEQ     DECIMAL(15,4), ' +              #13#10 +
        '  DEBITNCU     DECIMAL(15,4), ' +              #13#10 +
        '  DEBITCURR    DECIMAL(15,4), ' +              #13#10 +
        '  DEBITEQ      DECIMAL(15,4), ';
      if q2.RecordCount <> 0 then
        q.SQL.Add(' ' +
          q2.FieldByName('AllUsrFieldsList').AsString + ', ');
      q.SQL.Add(' ' +
        '  constraint PK_DBS_TMP_AC_SALDO primary key (ID))');
      ExecSqlLogEvent(q, 'CreateDBSTmpAcSaldo');

      q2.Close;
      LogEvent('Table DBS_TMP_AC_SALDO has been created.');
    end;
  end;

  procedure CreateDBSTmpInvSaldo;
  begin
    if RelationExist2('DBS_TMP_INV_SALDO', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM dbs_tmp_inv_saldo';

      ExecSqlLogEvent(q, 'CreateDBSTmpInvSaldo');
      LogEvent('Table DBS_TMP_INV_SALDO exists.');
    end
    else begin
      q.SQL.Text :=
        'CREATE TABLE DBS_TMP_INV_SALDO ( ' +           #13#10 +
        '  ID_MOVEMENT_D INTEGER, ' +                   #13#10 +
        '  ID_MOVEMENT_C INTEGER, ' +                   #13#10 +
        '  MOVEMENTKEY   INTEGER, ' +                   #13#10 +
        '  CONTACTKEY    INTEGER, ' +                   #13#10 +
        '  GOODKEY       INTEGER, ' +                   #13#10 +
        '  CARDKEY       INTEGER, ' +                   #13#10 +
        '  COMPANYKEY    INTEGER, ' +                   #13#10 +
        '  BALANCE       DECIMAL(15,4), ';
      q.SQL.Add(' ' +
        '  constraint PK_DBS_TMP_INV_SALDO primary key (MOVEMENTKEY))');
      ExecSqlLogEvent(q, 'CreateDBSTmpInvSaldo');

      q.SQL.Text :=
        'CREATE INDEX DBS_TMP_INV_SALDO_X_CARDKEY ON DBS_TMP_INV_SALDO (CARDKEY, ID_MOVEMENT_D)';
      ExecSqlLogEvent(q, 'CreateDBSTmpInvSaldo');

      LogEvent('Table DBS_TMP_INV_SALDO has been created.');
    end;
  end;

  procedure CreateDBSInactiveTriggers;
  begin
    if RelationExist2('DBS_INACTIVE_TRIGGERS', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM dbs_inactive_triggers';
      ExecSqlLogEvent(q, 'CreateDBSInactiveTriggers');
      LogEvent('Table DBS_INACTIVE_TRIGGERS exists.');
    end
    else begin
      q.SQL.Text :=
        'CREATE TABLE DBS_INACTIVE_TRIGGERS ( ' +       #13#10 +
        '  TRIGGER_NAME  CHAR(31) NOT NULL, ' +         #13#10 +
        '  constraint PK_DBS_INACTIVE_TRIGGERS primary key (TRIGGER_NAME))';
      ExecSqlLogEvent(q, 'CreateDBSInactiveTriggers');
      LogEvent('Table DBS_INACTIVE_TRIGGERS has been created.');
    end;
  end;
    
  procedure CreateDBSInactiveIndices;
  begin
    if RelationExist2('DBS_INACTIVE_INDICES', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM dbs_inactive_indices';
      ExecSqlLogEvent(q, 'CreateDBSInactiveIndices');
      LogEvent('Table DBS_INACTIVE_INDICES exists.');
    end
    else begin
      q.SQL.Text :=
        'CREATE TABLE DBS_INACTIVE_INDICES ( ' +        #13#10 +
        '  INDEX_NAME   CHAR(31) NOT NULL, ' +          #13#10 +
        '  constraint PK_DBS_INACTIVE_INDICES primary key (INDEX_NAME))';
      ExecSqlLogEvent(q, 'CreateDBSInactiveIndices');
      LogEvent('Table DBS_INACTIVE_INDICES has been created.');
    end;
  end;

  procedure CreateDBSPkUniqueConstraints;
  begin
    if RelationExist2('DBS_PK_UNIQUE_CONSTRAINTS', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM dbs_pk_unique_constraints';
      ExecSqlLogEvent(q, 'CreateDBSPkUniqueConstraints');
      LogEvent('Table DBS_PK_UNIQUE_CONSTRAINTS exist.');
    end
    else begin
      q.SQL.Text :=
        'CREATE TABLE DBS_PK_UNIQUE_CONSTRAINTS ( ' +   #13#10 +
	'  CONSTRAINT_NAME   CHAR(35), ' +              #13#10 +
	'  RELATION_NAME     CHAR(31), ' +              #13#10 +
	'  CONSTRAINT_TYPE   CHAR(11), ' +              #13#10 +
	'  LIST_FIELDS       VARCHAR(310), ' +          #13#10 +
	'  constraint PK_DBS_PK_UNIQUE_CONSTRAINTS primary key (CONSTRAINT_NAME)) ';
      ExecSqlLogEvent(q, 'CreateDBSPkUniqueConstraints');
      q.Close;
      LogEvent('Table DBS_PK_UNIQUE_CONSTRAINTS has been created.');
    end;
  end;

  procedure CreateDBSFkConstraints;
  begin
    if RelationExist2('DBS_FK_CONSTRAINTS', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM dbs_fk_constraints';
      ExecSqlLogEvent(q, 'CreateDBSFKConstraints');
      LogEvent('Table DBS_FK_CONSTRAINTS exists.');
    end
    else begin
      q.SQL.Text :=
        'CREATE TABLE DBS_FK_CONSTRAINTS ( ' +          #13#10 +
        '  CONSTRAINT_NAME   CHAR(40), ' +              #13#10 +
        '  RELATION_NAME     CHAR(31), ' +              #13#10 +
        '  LIST_FIELDS       VARCHAR(8192), ' +         #13#10 +
        '  REF_RELATION_NAME CHAR(31), ' +              #13#10 +
        '  LIST_REF_FIELDS   VARCHAR(8192), ' +         #13#10 +
        '  UPDATE_RULE       CHAR(11), ' +              #13#10 +
        '  DELETE_RULE       CHAR(11), ' +              #13#10 +
        '  constraint PK_DBS_FK_CONSTRAINTS primary key (CONSTRAINT_NAME))';
      ExecSqlLogEvent(q, 'CreateDBSFKConstraints');
      LogEvent('Table DBS_FK_CONSTRAINTS has been created.');
    end;
  end;

  procedure CreateDBSSuitableTables;
  begin
    if RelationExist2('DBS_SUITABLE_TABLES', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM dbs_suitable_tables';
      ExecSqlLogEvent(q, 'CreateDBSSuitableTables');
      LogEvent('Table DBS_SUITABLE_TABLES exist.');
    end
    else begin
      q.SQL.Text :=
        'CREATE TABLE DBS_SUITABLE_TABLES ( ' +         #13#10 +
	'  RELATION_NAME     CHAR(31), ' +              #13#10 +
	'  LIST_FIELDS       VARCHAR(310), ' +          #13#10 + // pk
	'  constraint PK_DBS_SUITABLE_TABLES primary key (RELATION_NAME)) ';
      ExecSqlLogEvent(q, 'CreateDBSSuitableTables');
      q.Close;
      LogEvent('Table DBS_SUITABLE_TABLES has been created.');
    end;
  end;

begin
  LogEvent('Creating metadata...');
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q2.Transaction := Tr;

    //CreateDBSTmpProcessedTbls;
    CreateDBSTmpAcSaldo;
    CreateDBSTmpInvSaldo;

    CreateDBSInactiveTriggers;
    CreateDBSInactiveIndices;
    CreateDBSPkUniqueConstraints;
    CreateDBSFkConstraints;
    CreateDBSSuitableTables;

    Tr.Commit;
    LogEvent('Creating metadata... OK');
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.SaveMetadata;
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    // inactive triggers
    q.SQL.Text :=
      'INSERT INTO DBS_INACTIVE_TRIGGERS (trigger_name) ' +                          #13#10 +
      'SELECT rdb$trigger_name ' +                                                   #13#10 +
      '  FROM rdb$triggers ' +                                                       #13#10 +
      ' WHERE (rdb$trigger_inactive <> 0) AND (rdb$trigger_inactive IS NOT NULL) ' + #13#10 +
      '   AND ((rdb$system_flag = 0) OR (rdb$system_flag IS NULL)) ';
    ExecSqlLogEvent(q, 'SaveMetadata');

    // inactive indices
    q.SQL.Text :=
      'INSERT INTO DBS_INACTIVE_INDICES (index_name) ' +                             #13#10 +
      'SELECT rdb$index_name ' +                                                     #13#10 +
      '  FROM rdb$indices ' +                                                        #13#10 +
      ' WHERE (rdb$index_inactive <> 0) AND (rdb$index_inactive IS NOT NULL) ' +     #13#10 +
      '   AND ((rdb$system_flag = 0) OR (rdb$system_flag IS NULL))';
    ExecSqlLogEvent(q, 'SaveMetadata');

    // PKs and Uniques constraints
    q.SQL.Text :=
      'INSERT INTO DBS_PK_UNIQUE_CONSTRAINTS ( ' +                              #13#10 +
      '  relation_name, ' +                                                     #13#10 +
      '  constraint_name, ' +                                                   #13#10 +
      '  constraint_type, ' +                                                   #13#10 +
      '  list_fields ) ' +                                                      #13#10 +
      'SELECT ' +                                                               #13#10 +
      '   c.rdb$relation_name, ' +                                              #13#10 +
      '   c.rdb$constraint_name, ' +                                            #13#10 +
      '   c.rdb$constraint_type, ' +                                            #13#10 +
      '   i.List_Fields ' +                                                     #13#10 +
      ' FROM ' +                                                                #13#10 +
      '   rdb$relation_constraints c ' +                                        #13#10 +
      '   JOIN (SELECT inx.rdb$index_name, ' +                                  #13#10 +
      '     LIST(TRIM(inx.rdb$field_name)) AS List_Fields ' +                   #13#10 +
      '     FROM rdb$index_segments inx ' +                                     #13#10 +
      '     GROUP BY inx.rdb$index_name ' +                                     #13#10 +
      '   ) i ON c.rdb$index_name = i.rdb$index_name ' +                        #13#10 +
      ' WHERE ' +                                                               #13#10 +
{     '   NOT EXISTS( ' +                                                       #13#10 +
      '       SELECT * ' +                                                      #13#10 +
      '       FROM rdb$relation_constraints cc  ' +                             #13#10 +
      '         JOIN RDB$REF_CONSTRAINTS refcc  ' +                             #13#10 +
      '           ON cc.rdb$constraint_name = refcc.rdb$constraint_name  ' +    #13#10 +
      '         JOIN RDB$RELATION_CONSTRAINTS cc2  ' +                          #13#10 +
      '           ON refcc.rdb$const_name_uq = cc2.rdb$constraint_name ' +      #13#10 +
      '         JOIN RDB$INDEX_SEGMENTS isegc  ' +                              #13#10 +
      '           ON isegc.rdb$index_name = cc.rdb$index_name  ' +              #13#10 +
      '         JOIN RDB$INDEX_SEGMENTS ref_isegc  ' +                          #13#10 +
      '           ON ref_isegc.rdb$index_name = cc2.rdb$index_name  ' +         #13#10 +
      '       WHERE ' +                                                         #13#10 +
      '         cc2.rdb$relation_name = c.rdb$relation_name ' +                 #13#10 +
      '         AND cc.rdb$constraint_type = ''FOREIGN KEY'' ' +                #13#10 +
      '         AND refcc.rdb$delete_rule IN(''SET NULL'', ''SET DEFAULT'') ' + #13#10 +
      '         AND cc.rdb$constraint_name NOT LIKE ''RDB$%'' ' +               #13#10 +
      '   ) ' +                                                                 #13#10 +   }
      '   (c.rdb$constraint_type = ''PRIMARY KEY'' OR c.rdb$constraint_type = ''UNIQUE'')  ' + #13#10 +
      '   AND c.rdb$constraint_name NOT LIKE ''RDB$%'' ';
    ExecSqlLogEvent(q, 'SaveMetadata');

    // Имена таблиц и их поля PK, которыe подходят для обработки
    q.SQL.Text :=
      'INSERT INTO DBS_SUITABLE_TABLES ' +                                      #13#10 +
      'SELECT ' +                                                               #13#10 +
      '  pk.relation_name AS RN, ' +                                            #13#10 +
      '  pk.list_fields   AS FN ' +                                             #13#10 +
      'FROM ' +                                                                 #13#10 +
      '  dbs_pk_unique_constraints pk ' +                                       #13#10 +
      '  JOIN RDB$RELATION_FIELDS rf ' +                                        #13#10 +
      '    ON rf.rdb$relation_name = pk.relation_name ' +                       #13#10 +
      '      AND rf.rdb$field_name = pk.list_fields ' +                         #13#10 +
      '    JOIN RDB$FIELDS f ' +                                                #13#10 +
      '      ON f.rdb$field_name = rf.rdb$field_source ' +                      #13#10 +
      'WHERE ' +                                                                #13#10 +
      '  constraint_type = ''PRIMARY KEY'' ' +                                  #13#10 +
      '  AND list_fields NOT LIKE ''%,%'' ' +                                   #13#10 +
      '  AND f.rdb$field_type = 8 ';
    ExecSqlLogEvent(q, 'SaveMetadata');

    // FK constraints
    q.SQL.Text :=
      'INSERT INTO DBS_FK_CONSTRAINTS ( ' +                                     #13#10 +
      '  constraint_name, relation_name, ref_relation_name, ' +                 #13#10 +
      '  update_rule, delete_rule, list_fields, list_ref_fields) ' +            #13#10 +
      'SELECT ' +                                                               #13#10 +
      '  c.rdb$constraint_name         AS Constraint_Name, ' +                  #13#10 +
      '  c.rdb$relation_name           AS Relation_Name, ' +                    #13#10 +
      '  c2.rdb$relation_name          AS Ref_Relation_Name, ' +                #13#10 +
      '  refc.rdb$update_rule          AS Update_Rule, ' +                      #13#10 +
      '  refc.rdb$delete_rule          AS Delete_Rule, ' +                      #13#10 +
      '  LIST(iseg.rdb$field_name)     AS Fields, ' +                           #13#10 +
      '  LIST(ref_iseg.rdb$field_name) AS Ref_Fields ' +                        #13#10 +
      'FROM ' +                                                                 #13#10 +
      '  rdb$relation_constraints c ' +                                         #13#10 +
      '  JOIN RDB$REF_CONSTRAINTS refc ' +                                      #13#10 +
      '    ON c.rdb$constraint_name = refc.rdb$constraint_name ' +              #13#10 +
      '  JOIN RDB$RELATION_CONSTRAINTS c2 ' +                                   #13#10 +
      '    ON refc.rdb$const_name_uq = c2.rdb$constraint_name ' +               #13#10 +
      '  JOIN RDB$INDEX_SEGMENTS iseg ' +                                       #13#10 +
      '    ON iseg.rdb$index_name = c.rdb$index_name ' +                        #13#10 +
      '  JOIN RDB$INDEX_SEGMENTS ref_iseg ' +                                   #13#10 +
      '    ON ref_iseg.rdb$index_name = c2.rdb$index_name ' +                   #13#10 +
      'WHERE ' +                                                                #13#10 +
      '  c.rdb$constraint_type = ''FOREIGN KEY''  ' +                           #13#10 +
      ///'  AND refc.rdb$delete_rule NOT IN(''SET NULL'', ''SET DEFAULT'') ' +     #13#10 +
      '  AND c.rdb$constraint_name NOT LIKE ''RDB$%'' ' +                       #13#10 +
      'GROUP BY ' +                                                             #13#10 +
      '  1, 2, 3, 4, 5';
    ExecSqlLogEvent(q, 'SaveMetadata');

    Tr.Commit;
    Tr.StartTransaction;

    if FCalculateSaldo then
    begin
      // для ссылочной целостности AcSaldo
      q.SQL.Text :=
        'INSERT INTO DBS_FK_CONSTRAINTS ( ' +                                     #13#10 +
        '  relation_name, ' +                                                     #13#10 +
        '  ref_relation_name, ' +                                                 #13#10 +
        '  constraint_name, ' +                                                   #13#10 +
        '  list_fields, list_ref_fields, update_rule, delete_rule) ' +            #13#10 +
        'SELECT ' +                                                               #13#10 +
        '  ''DBS_TMP_AC_SALDO'', ' +                                              #13#10 +
        '  ref_relation_name, ' +                                                 #13#10 +
        '  (''DBS_'' || constraint_name), ' +                                     #13#10 +
        '  list_fields, list_ref_fields, ''RESTRICT'', ''RESTRICT'' ' +           #13#10 +
        'FROM  ' +                                                                #13#10 +
        '  dbs_fk_constraints  ' +                                                #13#10 +
        'WHERE  ' +                                                               #13#10 +
        '  relation_name = ''AC_ENTRY'' ' +                                       #13#10 +
        '  AND list_fields LIKE ''USR$%''';
      ExecSqlLogEvent(q, 'SaveMetadata');

      // чтобы сохранить карточки необходимые InvSaldo
      q.SQL.Text :=
        'INSERT INTO DBS_FK_CONSTRAINTS ( ' +                                     #13#10 +
        '  relation_name, ' +                                                     #13#10 +
        '  ref_relation_name, ' +                                                 #13#10 +
        '  constraint_name, ' +                                                   #13#10 +
        '  list_fields, list_ref_fields, update_rule, delete_rule) ' +            #13#10 +
        'VALUES( ' +
        '  ''DBS_TMP_INV_SALDO'', ' +
        '  ''INV_CARD'', ' +
        '  ''DBS_INV_FK_MOVEMENT_CARDK'', ' +
        '  ''CARDKEY'', ''ID'', ''RESTRICT'', ''RESTRICT'')';
      ExecSqlLogEvent(q, 'SaveMetadata');
    end;
    Tr.Commit;
    LogEvent('Metadata saved.');
  finally
    q.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.CalculateAcSaldo; // подсчет бухгалтерского сальдо c сохранением в таблице DBS_TMP_AC_SALDO
var
  Tr: TIBTransaction;
  q2, q3: TIBSQL;
  I: Integer;
  TmpStr: String;
  TmpList: TStringList;
  AvailableAnalyticsList: TStringList;  // cписок активных аналитик для счета
  OurCompany_EntryDocList: TStringList; // список "компания=документ для проводок"
begin
  LogEvent('Calculating entry balance...');
  Assert(Connected);
  TmpStr := '';
  TmpList := TStringList.Create;
  AvailableAnalyticsList := TStringList.Create;
  OurCompany_EntryDocList := TStringList.Create;

  q2 := TIBSQL.Create(nil);
  q3 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q2.Transaction := Tr;
    q3.Transaction := Tr;

    if FAllOurCompaniesSaldo then
    begin
      TmpList.Text := StringReplace(FOurCompaniesListStr, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
      for I := 0 to TmpList.Count-1 do
        OurCompany_EntryDocList.Append(TmpList[I] + '=' + IntToStr(GetNewID));

      TmpList.Clear;  
    end;

    //-------------------------------------------- вычисление сальдо для счета
    // получаем счета
    q2.SQL.Text :=
      'SELECT DISTINCT ' +                                      #13#10 +
      '  ae.accountkey AS id, ' +                               #13#10 +
         StringReplace(FEntryAnalyticsStr, 'USR$', 'ac.USR$', [rfReplaceAll, rfIgnoreCase]) + ' ' + #13#10 +
      'FROM AC_ENTRY ae ' +                                     #13#10 +
      '  JOIN AC_ACCOUNT ac ON ae.accountkey = ac.id ' +        #13#10 +
      'WHERE ' +                                                #13#10 +
      '  ae.entrydate < :EntryDate ';
    if FAllOurCompaniesSaldo then
      q2.SQL.Add(' ' +
        'AND ae.companykey IN (' + FOurCompaniesListStr + ') ');

    q2.ParamByName('EntryDate').AsDateTime := FClosingDate;
    
    ExecSqlLogEvent(q2, 'CalculateAcSaldo');

    // считаем и сохраняем сальдо для каждого счета
    while (not q2.EOF) and (not FDoStopProcessing) do
    begin
      AvailableAnalyticsList.Text := StringReplace(FEntryAnalyticsStr, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
      // получаем cписок активных аналитик, по которым ведется учет для счета
      I := 0;
      while I < AvailableAnalyticsList.Count do     
      begin
        if (q2.FieldByName(Trim(AvailableAnalyticsList[I])).AsInteger = 0) or (q2.FieldByName(Trim(AvailableAnalyticsList[I])).IsNull) then
        begin
          AvailableAnalyticsList.Delete(I);
        end
        else
          Inc(I);
      end;

      // подсчет сальдо в разрезе компании, счета, валюты, аналитик
      
      // проводки по счетам
      q3.SQL.Text :=
        'INSERT INTO DBS_TMP_AC_SALDO ( ' +                     #13#10 +
        '  documentkey, masterdockey, ' +                       #13#10 +
        '  accountkey, ' +                                      #13#10 +
        '  accountpart, ' +                                     #13#10 +
        '  recordkey, ' +                                       #13#10 +
        '  recordkey_ostatky, ' +                               #13#10 +
        '  id, ' +                                              #13#10 +
        '  id_ostatky, ' +                                      #13#10 +
        '  companykey, ' +                                      #13#10 +
        '  currkey, ' +                                         #13#10 +
        '  creditncu, ' +                                       #13#10 +
        '  creditcurr, ' +                                      #13#10 +
        '  crediteq, ' +                                        #13#10 +
        '  debitncu, ' +                                        #13#10 +
        '  debitcurr, ' +                                       #13#10 +
        '  debiteq ';
      for I := 0 to AvailableAnalyticsList.Count - 1 do
        q3.SQL.Add(', ' +                                       #13#10 +
          AvailableAnalyticsList[I]);
      q3.SQL.Add(
        ') ' +                                                  #13#10 +
        'SELECT ');                                             // CREDIT
      // documentkey = masterkey
      if FAllOurCompaniesSaldo then
      begin                     // documentkey
        TmpStr := ' ' +
          'CASE companykey ';
        for I := 0 to OurCompany_EntryDocList.Count-1 do
        begin
          TmpStr :=  TmpStr + ' ' +
            'WHEN ' + OurCompany_EntryDocList.Names[I] + ' THEN ' + OurCompany_EntryDocList.Values[OurCompany_EntryDocList.Names[I]];
        end;
        TmpStr :=  TmpStr + ' ' +
          'END ';
      end;
      TmpStr :=  TmpStr + ',' + TmpStr + ',';// + masterdocumentkey
      
      q3.SQL.Add(' ' +
        TmpStr +                                                #13#10 +
        '  accountkey, ' +                                      #13#10 +
        '  ''C'', ' +                                           #13#10 +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + #13#10 +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + #13#10 +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + #13#10 +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + #13#10 +
        '  companykey, ' +                                      #13#10 +
        '  currkey, ' +                                         #13#10 +
        '  ABS(SUM(debitncu)  - SUM(creditncu)), ' +            #13#10 +
        '  ABS(SUM(debitcurr) - SUM(creditcurr)), ' +           #13#10 +
        '  ABS(SUM(debiteq)   - SUM(crediteq)), ' +             #13#10 +
        '  CAST(0.0000 AS DECIMAL(15,4)) , ' +                  #13#10 +
        '  CAST(0.0000 AS DECIMAL(15,4)) , ' +                  #13#10 +
        '  CAST(0.0000 AS DECIMAL(15,4)) ');
      for I := 0 to AvailableAnalyticsList.Count - 1 do                         /////////////////////////////////////
      begin
        //if UpperCase(Trim(AvailableAnalyticsList[I])) <> 'USR$GS_DOCUMENT' then
          q3.SQL.Add(', ' +
            AvailableAnalyticsList[I])
        {else begin
          if FOnlyCompanySaldo then
            q3.SQL.Add( ', ' +
              IntToStr(OnlyCompanyEntryDoc))
          else if FAllOurCompaniesSaldo then
          begin                     // documentkey
            q3.SQL.Add(', ' +
              'CASE companykey ');
            for J := 0 to OurCompany_EntryDocList.Count-1 do
            begin
              q3.SQL.Add( ' ' +
                'WHEN ' + OurCompany_EntryDocList.Names[J] + ' THEN ' + OurCompany_EntryDocList.Values[OurCompany_EntryDocList.Names[J]]);
            end;
            q3.SQL.Add(' ' +
              'END ');
          end;
        end;  }
      end;

      q3.SQL.Add(' ' +
        'FROM AC_ENTRY ' +                                      #13#10 +
        'WHERE accountkey = :AccountKey ' +                     #13#10 +
        '  AND entrydate < :EntryDate ');
      if FAllOurCompaniesSaldo then
        q3.SQL.Add(' ' +                                        #13#10 +
          'AND companykey IN (' + FOurCompaniesListStr + ') ');

      q3.SQL.Add(' ' +                                          #13#10 +
        'GROUP BY ' +                                           #13#10 +
        '  accountkey, ' +                                      #13#10 +
        '  companykey, ' +                                      #13#10 +
        '  currkey ');
      for I := 0 to AvailableAnalyticsList.Count - 1 do
        q3.SQL.Add(', ' +                                       #13#10 +
          AvailableAnalyticsList[I]);
      q3.SQL.Add(' ' +                                          #13#10 +
        'HAVING ' +                                             #13#10 +
        '  (SUM(debitncu) - SUM(creditncu)) < CAST(0.0000 AS DECIMAL(15,4)) ' +        #13#10 +
        '   OR (SUM(debitcurr) - SUM(creditcurr)) < CAST(0.0000 AS DECIMAL(15,4)) ' +  #13#10 +
        '   OR (SUM(debiteq)   - SUM(crediteq))   < CAST(0.0000 AS DECIMAL(15,4)) ' +  #13#10 +

        'UNION ALL ' +                                          #13#10 +  

        'SELECT ');                                            // DEBIT
      // documentkey = masterkey

      q3.SQL.Add(' ' +
        TmpStr +                                                  #13#10 +
          '  accountkey, ' +                                      #13#10 +
          '  ''D'', ' +                                           #13#10 +
          '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + #13#10 +
          '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + #13#10 +
          '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + #13#10 +
          '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + #13#10 +
          '  companykey, ' +                                      #13#10 +
          '  currkey, ' +                                         #13#10 +
          '  CAST(0.0000 AS DECIMAL(15,4)), ' +                   #13#10 +
          '  CAST(0.0000 AS DECIMAL(15,4)), ' +                   #13#10 +
          '  CAST(0.0000 AS DECIMAL(15,4)), ' +                   #13#10 +
          '  ABS(SUM(debitncu)  - SUM(creditncu)), ' +            #13#10 +
          '  ABS(SUM(debitcurr) - SUM(creditcurr)), ' +           #13#10 +
          '  ABS(SUM(debiteq)   - SUM(crediteq)) ');
      for I := 0 to AvailableAnalyticsList.Count - 1 do                         /////////////////////////////////////
      begin
        //if UpperCase(Trim(AvailableAnalyticsList[I])) <> 'USR$GS_DOCUMENT' then
          q3.SQL.Add(', ' +
            AvailableAnalyticsList[I])
        {else begin
          if FOnlyCompanySaldo then
            q3.SQL.Add( ', ' +
              IntToStr(OnlyCompanyEntryDoc))
          else if FAllOurCompaniesSaldo then
          begin                     // documentkey
            q3.SQL.Add(', ' +
              'CASE companykey ');
            for J := 0 to OurCompany_EntryDocList.Count-1 do
            begin
              q3.SQL.Add( ' ' +
                'WHEN ' + OurCompany_EntryDocList.Names[J] + ' THEN ' + OurCompany_EntryDocList.Values[OurCompany_EntryDocList.Names[J]]);
            end;
            q3.SQL.Add(' ' +
              'END ');
          end;
        end; }
      end;

      q3.SQL.Add(' ' +                                          #13#10 +
        'FROM AC_ENTRY ' +                                      #13#10 +
        'WHERE accountkey = :AccountKey ' +                     #13#10 +
        '  AND entrydate < :EntryDate ');
      if FAllOurCompaniesSaldo then
        q3.SQL.Add(' ' +                                        #13#10 +
          'AND companykey IN (' + FOurCompaniesListStr + ') ');
      q3.SQL.Add(' ' +
        'GROUP BY ' +                                           #13#10 +
        '  accountkey, ' +                                      #13#10 +
        '  companykey, ' +                                      #13#10 +
        '  currkey ');
      for I := 0 to AvailableAnalyticsList.Count - 1 do
        q3.SQL.Add(', ' +                                       #13#10 +
          AvailableAnalyticsList[I]);
      q3.SQL.Add(' ' +
        'HAVING ' +                                                                    #13#10 +
        '  (SUM(debitncu) - SUM(creditncu)) > CAST(0.0000 AS DECIMAL(15,4)) ' +        #13#10 +
        '   OR (SUM(debitcurr) - SUM(creditcurr)) > CAST(0.0000 AS DECIMAL(15,4)) ' +  #13#10 +
        '   OR (SUM(debiteq)   - SUM(crediteq))   > CAST(0.0000 AS DECIMAL(15,4)) '); 

      q3.ParamByName('AccountKey').AsInteger := q2.FieldByName('id').AsInteger;
      q3.ParamByName('EntryDate').AsDateTime := FClosingDate;
      
      ExecSqlLogEvent(q3, 'CalculateAcSaldo');

      AvailableAnalyticsList.Clear;
      q3.Close;

      q2.Next;
    end;

    Tr.Commit;
    q2.Close;
  finally
    q2.Free;
    q3.Free;
    Tr.Free;
    AvailableAnalyticsList.Free;
    OurCompany_EntryDocList.Free;
    TmpList.Free;
  end;
  LogEvent('Calculating entry balance... OK');
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.CalculateInvSaldo;
var
  q, q2: TIBSQL;
  Tr: TIBTransaction;
begin
  LogEvent('Calculating inventory balance...');
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);

  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q2.Transaction := Tr;

    // запрос на складские остатки
    q.SQL.Text :=
      'INSERT INTO DBS_TMP_INV_SALDO ' +                        #13#10 +
      'SELECT ' +                                               #13#10 +
      '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' +   #13#10 +   // ID_MOVEMENT_D
      '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' +   #13#10 +   // ID_MOVEMENT_C
      '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' +   #13#10 +   // MOVEMENTKEY
      '  im.contactkey AS ContactKey, ' +                       #13#10 +
      '  ic.goodkey, ' +                                        #13#10 +
      '  im.cardkey, ' +                                        #13#10 +
      '  doc.companykey, ' +                                    #13#10 +
      '  SUM(im.debit - im.credit) AS Balance ';
    q.SQL.Add(' ' +
      'FROM inv_movement im ' +                                 #13#10 +
      '  JOIN GD_DOCUMENT doc ON im.documentkey = doc.id ' +    #13#10 +
      '  JOIN INV_CARD ic ON im.cardkey = ic.id ' +             #13#10 +
      '  JOIN GD_CONTACT cont ON cont.id = im.contactkey ' +    #13#10 +
      '    JOIN gd_contact contact_head ' +                                   #13#10 +
      '      ON contact_head.lb <= cont.lb AND contact_head.rb >= cont.rb ' + #13#10 +
      'WHERE ' +                                                              #13#10 +
      '  im.cardkey > 0 ' +                                     #13#10 +   // первый столбец в индексе, чтобы его задействовать
      '  AND contact_head.id = doc.companykey ');

    if Assigned(FDocTypesList) then
    begin
      if not FDoProcDocTypes then
        q.SQL.Add(' ' +
          '  AND doc.documenttypekey NOT IN(' + FDocTypesList.CommaText + ') ')
      else
        q.SQL.Add(' ' +
          '  AND doc.documenttypekey IN(' + FDocTypesList.CommaText + ') ');
    end;

    q.SQL.Add(' ' +
      '  AND im.movementdate < :RemainsDate ' +                 #13#10 +
      '  AND im.disabled = 0 ' +                                #13#10 +
      'GROUP BY ' +                                             #13#10 +
      '  im.contactkey, ' +                                     #13#10 +
      '  im.cardkey, ic.goodkey, ' +                            #13#10 +
      '  doc.companykey ');

    q.ParamByName('RemainsDate').AsDateTime := FClosingDate;

    ExecSqlLogEvent(q, 'CalculateInvSaldo');
    Tr.Commit;
    Tr.StartTransaction;

    ProgressMsgEvent('', 3*PROGRESS_STEP);

    // перепривязка карточек, необходимых для сальдо, на сальдовый документ

    q2.SQL.Text :=
      'SELECT FIRST(1) s.companykey FROM DBS_TMP_INV_SALDO s';                  ///TODO: выбрать компанию для дока
    ExecSqlLogEvent(q2, 'CalculateInvSaldo');

    if not q2.EOF then
    begin
      // SaldoDoc
      q.SQL.Text :=
        'INSERT INTO GD_DOCUMENT (' +                   #13#10 +
        '  id, ' +                                      #13#10 +
        '  documenttypekey, ' +                         #13#10 +
        '  number, '  +                                 #13#10 +
        '  documentdate, ' +                            #13#10 +
        '  companykey, afull, achag, aview, ' +         #13#10 +
        '  creatorkey, editorkey) ' +                   #13#10 +
        'VALUES( '  +                                   #13#10 +
        '  :id, ' +                                     #13#10 +
        '  :documenttypekey, ' +                        #13#10 +
        '  :number, ' +                                 #13#10 +
        '  :documentdate, ' +                           #13#10 +
        '  :companykey, -1, -1, -1, ' +                 #13#10 +
        '  :UserKey, :UserKey) ';

      q.ParamByName('id').AsInteger := FInvSaldoDoc;
      q.ParamByName('documenttypekey').AsInteger := FProizvolnyyDocTypeKey;
      q.ParamByName('documentdate').AsDateTime := FClosingDate;
      q.ParamByName('UserKey').AsInteger := FCurUserContactKey;
      q.ParamByName('number').AsString := NEWINVDOCUMENT_NUMBER;
      q.ParamByName('companykey').AsInteger := q2.FieldByName('companykey').AsInteger;

      ExecSqlLogEvent(q, 'CreateInvSaldo');
    end;
    q2.Close;
    Tr.Commit;

    ProgressMsgEvent('', 2*PROGRESS_STEP);
 
    ProgressMsgEvent('', 2*PROGRESS_STEP);
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
  LogEvent('Calculating inventory balance... OK');
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.SetBlockTriggerActive(const SetActive: Boolean);
var
  StateStr: String;
  q: TIBSQL;
  q2: TIBSQL;
  Tr: TIBTransaction;
begin
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    
    q.Transaction := Tr;
    q2.Transaction := Tr;

    if FInactivBlockTriggers = '' then
    begin
      q.SQL.Text :=
        'SELECT ' +                                                   #13#10 +
        '  rdb$trigger_name AS TN ' +                                 #13#10 +
        'FROM ' +                                                     #13#10 +
        '  rdb$triggers ' +                                           #13#10 +
        'WHERE ' +                                                    #13#10 +
        '  rdb$system_flag = 0 ' +                                    #13#10 +
        '  AND rdb$trigger_name LIKE ''%BLOCK%'' ' +                  #13#10 +
        '  AND rdb$trigger_inactive <> 0 ';
      ExecSqlLogEvent(q, 'SetBlockTriggerActive');
      while not q.EOF do
      begin
        FInactivBlockTriggers := FInactivBlockTriggers + ' ''' + q.FieldByName('TN').AsString + '''';

        q.Next;
        if not q.EOF then
          FInactivBlockTriggers := FInactivBlockTriggers + ', ';
      end;
      q.Close;
    end;

    FInactivBlockTriggers := FInactivBlockTriggers + ' ';

    q.SQL.Text :=
      'SELECT ' +                                                     #13#10 +
      '  rdb$trigger_name AS TN ' +                                   #13#10 +
      'FROM ' +                                                       #13#10 +
      '  rdb$triggers ' +                                             #13#10 +
      'WHERE ' +                                                      #13#10 +
      '  rdb$system_flag = 0 ' +                                      #13#10 +
      '  AND rdb$trigger_name LIKE ''%BLOCK%'' ' +                    #13#10 +
      '  AND rdb$trigger_inactive = :IsInactiv ';
    if Trim(FInactivBlockTriggers) <> '' then
    begin
      q.SQL.Add(
      '  AND rdb$trigger_name NOT IN (' + FInactivBlockTriggers + ')');
    end;

    if SetActive then
    begin
      StateStr := 'ACTIVE';
      q.ParamByName('IsInactiv').AsInteger := 1;
    end
    else begin
      StateStr := 'INACTIVE';
      q.ParamByName('IsInactiv').AsInteger := 0;
    end;
    ExecSqlLogEvent(q, 'SetBlockTriggerActive');

    while not q.EOF do
    begin
      q2.SQL.Text := 'ALTER TRIGGER ' + q.FieldByName('TN').AsString + ' '  + StateStr;
      ExecSqlLogEvent(q2, 'SetBlockTriggerActive');
      q2.Close;
      q.Next;
    end;
    q.Close;

    Tr.Commit;
    Tr.StartTransaction;

    q.SQL.Text :=
      'EXECUTE BLOCK ' +                                                              #13#10 +
      'AS ' +                                                                         #13#10 +
      '  DECLARE VARIABLE TN CHAR(31); ' +                                            #13#10 +
      'BEGIN ' +                                                                      #13#10 +
      '  FOR ' +                                                                      #13#10 +
      '    SELECT ' +                                                                 #13#10 +
      '      rdb$trigger_name ' +                                                     #13#10 +
      '    FROM ' +                                                                   #13#10 +
      '      rdb$triggers ' +                                                         #13#10 +
      '    WHERE ' +                                                                  #13#10 +
     /// '      rdb$trigger_inactive = 0 ' +                                          #13#10 +            ///TODO вроде лишнее
      '      rdb$system_flag = 0 ' +                                              #13#10 +
      '      AND rdb$relation_name IN(''INV_MOVEMENT'', ''INV_CARD'', ''INV_BALANCE'') ' + #13#10 +
      '    INTO :TN ' +                                                               #13#10 +
      '  DO ' +                                                                       #13#10 +
      '  BEGIN ' +                                                                    #13#10 +
      '    EXECUTE STATEMENT ''ALTER TRIGGER '' || :TN || '' ' + StateStr + ' ''; ' + #13#10 +
      '  END ' +                                                                      #13#10 +
      'END';
    ExecSqlLogEvent(q, 'SetBlockTriggerActive');

    Tr.Commit;
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.CreateHIS_IncludeInHIS;
var
  Tr: TIBTransaction;
  q, q2: TIBSQL;
  I: Integer;

  procedure IncludeDependenciesHIS(const ATableName: String);
  const
    STEP_COUNT = 8;
  var
    LineDocTbls: TStringList;
    CrossLineTbls: TStringList;
    LineSetTbls: TStringList;
    ReProcTbl: String;
    EndReprocLineTbl: String;
    ReProcLineTbls: TStringList;
    GoLineReproc: Boolean;
    WaitReProc: Boolean;
    RefRelation: String;
    TmpStr: String;
    Step: Integer;
    ReprocIncrement: Integer;
    ReprocSituation: Boolean;
    ReprocCondition: Boolean;

    Tr, Tr2: TIBTransaction;
    q2: TIBQuery;
    q, q3, q4, q5: TIBSQL;
    FkFieldsList: TStringList;
    FkFieldsList2, FkFieldsList3: TStringList;
    FkFieldsListLine: TStringList;
    IsLine: Boolean;
    TblsNamesList: TStringList; // Process Queue
    AllProcessedTblsNames: TStringList;
    ExcFKTbls: TStringList;
    ReProc, ReProcAll: TStringList;
    GoReprocess, ReprocStarted: Boolean;
    EndReprocTbl: String;
    AllProc: TStringList;
    ProcTblsNamesList: TStringList;
    CascadeProcTbls: TStringList;
    I, J, K, N, IndexEnd, Inx, Counter, Kolvo, RealKolvo, RealKolvo2, ExcKolvo: Integer;
    IsAppended, IsDuplicate, DoNothing, GoToFirst, GoToLast, IsFirstIteration, Condition: Boolean;

    TmpList: TStringList;
    MainDuplicateTblName: String;
    LineTblsNames: String;
    LineTblsList:  TStringList;
    LinePosList: TStringList;
    LinePosInx: Integer;
    Line1PosInx, Line2PosInx: Integer;
    SelfFkFieldsListLine: TStringList;
    SelfFkFieldsList2: TStringList;
  begin
    LogEvent('Including in HIS...');
    Assert(Trim(ATableName) <> '');

    LineDocTbls := TStringList.Create;
    CrossLineTbls := TStringList.Create;
    LineSetTbls := TStringList.Create;
    ProcTblsNamesList := TStringList.Create;
    ReProcLineTbls := TStringList.Create;

    FkFieldsList := TStringList.Create;
    FkFieldsList2 := TStringList.Create;
    FkFieldsList3 := TStringList.Create;
    FkFieldsListLine := TStringList.Create;
    TblsNamesList := TStringList.Create;
    AllProcessedTblsNames := TStringList.Create;

    ReProc :=  TStringList.Create;
    ReProcAll :=  TStringList.Create;
    CascadeProcTbls := TStringList.Create;
    LineTblsList := TStringList.Create;
    AllProc := TStringList.Create;
    LinePosList := TStringList.Create;
    TmpList := TStringList.Create;
    ExcFKTbls := TStringList.Create;

    SelfFkFieldsListLine := TStringList.Create;
    SelfFkFieldsList2 := TStringList.Create;
    q := TIBSQL.Create(nil);
    q2 := TIBQuery.Create(nil);
    q3 := TIBSQL.Create(nil);
    q4 := TIBSQL.Create(nil);
    q5 := TIBSQL.Create(nil);

    Tr := TIBTransaction.Create(nil);
    Tr2 := TIBTransaction.Create(nil);
    try

      try
        Tr.DefaultDatabase := FIBDatabase;
        Tr.StartTransaction;
        Tr2.DefaultDatabase := FIBDatabase;
        Tr2.StartTransaction;
        q.Transaction := Tr;
        q2.Transaction := Tr;
        q4.Transaction := Tr;
        q3.Transaction := Tr2;
        q5.Transaction := Tr2;

        //include HIS_1 - обязаны остаться

        //1) список табл. составляющих единое целое с документом

        LineDocTbls.Append('GD_DOCUMENT=PARENT'); // позиции
        LineDocTbls.Append('AC_ENTRY=DOCUMENTKEY||MASTERDOCKEY');
        LineDocTbls.Append('AC_RECORD=DOCUMENTKEY||MASTERDOCKEY');

        // табл PK=FK             таблицы со связью 1-to-1 к GD_DOCUMENT

        q.SQL.Text :=
          'SELECT ' +                                             #13#10 +
          '  TRIM(fc.relation_name)       AS relation_name, ' +   #13#10 +
          '  LIST(TRIM(fc.list_fields))   AS pkfk_field ' +       #13#10 +
          'FROM dbs_fk_constraints fc ' +                         #13#10 +
          '  JOIN DBS_SUITABLE_TABLES pc ' +                      #13#10 +
          '    ON pc.relation_name = fc.relation_name ' +         #13#10 +
          '      AND fc.list_fields = pc.list_fields ' +          #13#10 +
          'WHERE ' +                                              #13#10 +
          '  fc.ref_relation_name = ''GD_DOCUMENT'' ' +                                                                     #13#10 +
          '  AND fc.relation_name NOT IN (''GD_DOCUMENT'', ''AC_ENTRY'', ''AC_RECORD'', ''INV_CARD'', ''INV_MOVEMENT'') ' + #13#10 +
          '  AND fc.list_fields NOT LIKE ''%,%'' ' +                                                                        #13#10 +
          'GROUP BY fc.relation_name ';

        ExecSqlLogEvent(q, 'IncludeDependenciesHIS');

        while not q.EOF do
        begin
          FkFieldsList.Clear;
          FkFieldsList.Text := StringReplace(q.FieldByName('pkfk_field').AsString, ',', #13#10, [rfReplaceAll, rfIgnoreCase]); // поля PK=FK

          for I:=0 to FkFieldsList.Count-1 do
          begin
            if LineDocTbls.IndexOfName(UpperCase(q.FieldByName('relation_name').AsString)) <> -1 then
            begin
              if AnsiPos(Trim(FkFieldsList[I]), LineDocTbls.Values[UpperCase(q.FieldByName('relation_name').AsString)]) = 0 then
                LineDocTbls.Values[UpperCase(q.FieldByName('relation_name').AsString)] := LineDocTbls.Values[UpperCase(q.FieldByName('relation_name').AsString)] + '||' + Trim(FkFieldsList[I]);
            end
            else
              LineDocTbls.Append(UpperCase(q.FieldByName('relation_name').AsString) + '=' + Trim(FkFieldsList[I]));
          end;

          q.Next;
        end;
        q.Close;

        LineDocTbls.Append('INV_CARD=DOCUMENTKEY||FIRSTDOCUMENTKEY');

        // упорядочить чтобы избежать некоторых переобработок: Line2 ссылающийся на Line1 должен стоять ПЕРЕД Line1
        TmpList.CommaText := LineDocTbls.CommaText;

        for J:=0 to TmpList.Count-1 do
        begin
          Line2PosInx := LineDocTbls.IndexOfName(TmpList.Names[J]);
          Inx := Line2PosInx;

          q2.SQL.Text :=
            'SELECT ' +                                           #13#10 +
            '  TRIM(fc.ref_relation_name) AS ref_relation_name ' +#13#10 +
            'FROM dbs_fk_constraints fc ' +                       #13#10 +
            'WHERE  ' +                                           #13#10 +
            '  fc.relation_name = :rln ' +                        #13#10 +
            '  AND fc.list_fields NOT LIKE ''%,%'' ';
          q2.ParamByName('rln').AsString := TmpList.Names[J];
          ExecSqlLogEvent(q2, 'IncludeDependenciesHIS');

          while not q2.EOF do
          begin
            if UpperCase(q2.FieldByName('ref_relation_name').AsString) <> 'GD_DOCUMENT' then
            begin
              Line1PosInx := LineDocTbls.IndexOfName(UpperCase(q2.FieldByName('ref_relation_name').AsString));
              if (Line1PosInx <> -1) and (Line1PosInx < Line2PosInx) then
              begin
                if Line1PosInx < Inx then
                  Inx := Line1PosInx;
              end;
            end;
            q2.Next;
          end;

          if Inx < Line2PosInx then
          begin
            LineDocTbls.Delete(Line2PosInx);
            LineDocTbls.Insert(Inx, TmpList.Names[J] + '=' + TmpList.Values[TmpList.Names[J]]);
          end;

          q2.Close;
        end;
        TmpList.Clear;


        LineDocTbls.Append('INV_MOVEMENT=DOCUMENTKEY');

        // 2) cross-табл для множеств Line

        for J:=0 to LineDocTbls.Count-1 do
        begin
          q.SQL.Text :=
            'SELECT DISTINCT ' +                                  #13#10 +
            '  TRIM(rf.crosstable)  AS cross_relation_name, ' +   #13#10 +
            '  TRIM(fc.list_fields) AS cross_main_field ' +       #13#10 +
            'FROM AT_RELATION_FIELDS rf ' +                       #13#10 +
            '  JOIN dbs_fk_constraints fc ' +                     #13#10 +
            '    ON fc.relation_name = rf.crosstable ' +          #13#10 +
            '      AND fc.ref_relation_name = rf.relationname ' + #13#10 +
            'WHERE ' +                                            #13#10 +
            '  rf.relationname = :rln ' +                         #13#10 +
            '  AND  rf.crosstable IS NOT NULL ';
          q.ParamByName('rln').AsString := LineDocTbls.Names[J];
          ExecSqlLogEvent(q, 'IncludeDependenciesHIS');

          if not q.EOF then
            TmpStr := LineDocTbls.Names[J] + '=';

          while not q.EOF do
          begin
            if CrossLineTbls.IndexOfName(UpperCase(q.FieldByName('cross_relation_name').AsString)) = -1 then
              CrossLineTbls.Append(UpperCase(q.FieldByName('cross_relation_name').AsString) + '=' + UpperCase(q.FieldByName('cross_main_field').AsString));

            TmpStr := TmpStr + UpperCase(q.FieldByName('cross_relation_name').AsString);         ///TODO добавить проверку уникальности

            q.Next;

            if not q.EOF then
              TmpStr := TmpStr + ','
            else
             LineSetTbls.Append(TmpStr);
          end;

          TmpStr := '';
          q.Close;
        end;

        LogEvent('LineSetTbls: ' + LineSetTbls.Text);
        LogEvent('CrossLineTbls: ' + CrossLineTbls.Text);
        LogEvent('LineDocTbls: ' + LineDocTbls.Text);

 
  CreateHIS(0);              LogEvent('3)');

  q3.SQL.Text :=
    'SELECT SUM(g_his_include(0, id)) FROM gd_document WHERE parent IS NULL';
  ExecSqlLogEvent(q3, 'IncludeDependenciesHIS');
  q3.Close;

      Tr2.Commit;
      Tr2.StartTransaction;

        // 3) include HIS доки на которые есть ссылки (не от таблицы Line, не от crossLine)
        q2.SQL.Text :=
          'SELECT ' +                                             #13#10 +
          '  TRIM(fc.relation_name)       AS relation_name, ' +   #13#10 +
          '  LIST(TRIM(fc.list_fields))   AS fk_fields ' +        #13#10 +
          'FROM dbs_fk_constraints fc ' +                         #13#10 +
          '  LEFT JOIN AT_RELATION_FIELDS rf ' +                  #13#10 +
          '    ON rf.relationname = fc.ref_relation_name ' +      #13#10 +
          '      AND rf.crosstable = fc.relation_name ' +         #13#10 +
          'WHERE ' +                                              #13#10 +
          '  fc.ref_relation_name = ''GD_DOCUMENT'' ' +           #13#10 +
          '  AND rf.relationname IS NULL ' +                      #13#10 +
          '  AND fc.list_fields NOT LIKE ''%,%'' ' +              #13#10 +
          'GROUP BY fc.relation_name ';

        ExecSqlLogEvent(q2, 'IncludeDependenciesHIS');

        while (not q2.EOF) and (not FDoStopProcessing) do
        begin
          if (LineDocTbls.IndexOfName(UpperCase(q2.FieldByName('relation_name').AsString)) = -1) and
             (CrossLineTbls.IndexOfName(UpperCase(q2.FieldByName('relation_name').AsString)) = -1) then
          begin
            FkFieldsList2.Clear;
            FkFieldsList2.Text := StringReplace(q2.FieldByName('fk_fields').AsString, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);

            for I:=0 to FkFieldsList2.Count-1 do
            begin
              q3.SQL.Text :=
                'SELECT ' +                                                           #13#10 +
                '  SUM(g_his_include(1, rln.' +  FkFieldsList2[I] + ')) AS Kolvo ' +  #13#10 +
                'FROM '  +                                                            #13#10 +
                   q2.FieldByName('relation_name').AsString + ' rln ' +               #13#10 +
                'WHERE ' +
                '  g_his_has(0, rln.' + FkFieldsList2[I] + ')=1 ';
              ExecSqlLogEvent(q3, 'IncludeDependenciesHIS');

              if q3.FieldByName('Kolvo').AsInteger > 0 then
                LogEvent(q2.FieldByName('relation_name').AsString + '.' + FkFieldsList2[I]);

              q3.Close;
            end;
          end;

          q2.Next;
        end;
        q2.Close;
        ProgressMsgEvent('', 100);

  DestroyHIS(0);

        Tr2.Commit;
        Tr2.StartTransaction;

        LogEvent('4)');
        // 4) include linefield Line если на нее есть ссылка (не от таблицы Line и не от cross-таблиц Line)
        for J:=0 to LineDocTbls.Count-1 do
        begin
          // line values
          FkFieldsList.Clear;
          FkFieldsList.Text := StringReplace(LineDocTbls.Values[LineDocTbls.Names[J]], '||', #13#10, [rfReplaceAll, rfIgnoreCase]);

          q2.SQL.Text :=
            'SELECT ' +                                           #13#10 +
            '  TRIM(fc.relation_name)     AS relation_name, ' +   #13#10 +
            '  LIST(TRIM(fc.list_fields)) AS fk_fields, ' +       #13#10 +
            '  TRIM(fc.list_ref_fields)   AS list_ref_fields, ' + #13#10 +
            '  TRIM(pc.list_fields)       AS pk_fields ' +        #13#10 +
            'FROM dbs_fk_constraints fc ' +                       #13#10 +
            '  LEFT JOIN DBS_SUITABLE_TABLES pc ' +               #13#10 +
            '    ON pc.relation_name = fc.relation_name ' +       #13#10 +
            '  LEFT JOIN AT_RELATION_FIELDS rf ' +                #13#10 +
            '    ON rf.relationname = fc.ref_relation_name ' +    #13#10 +
            '      AND rf.crosstable = fc.relation_name ' +       #13#10 +
            'WHERE ' +                                            #13#10 +
            '  fc.ref_relation_name = :rln ' +                    #13#10 +
            '  AND rf.relationname IS NULL ' +                    #13#10 +
            '  AND fc.list_fields NOT LIKE ''%,%'' ' +            #13#10 +
            'GROUP BY fc.relation_name, fc.list_ref_fields, pc.list_fields';

          q2.ParamByName('rln').AsString := LineDocTbls.Names[J];
          ExecSqlLogEvent(q2, 'IncludeDependenciesHIS');

          while not q2.EOF and (not FDoStopProcessing) do
          begin
            if (LineDocTbls.IndexOfName(UpperCase(q2.FieldByName('relation_name').AsString)) = -1) and
               (CrossLineTbls.IndexOfName(UpperCase(q2.FieldByName('relation_name').AsString)) = -1) and
               (UpperCase(q2.FieldByName('relation_name').AsString) <> 'INV_BALANCE') then
            begin
              FkFieldsList2.Clear;
              FkFieldsList2.Text := StringReplace(q2.FieldByName('fk_fields').AsString, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);

              if FkFieldsList2.Count > 0 then
              begin
                q3.SQL.Text :=
                  'SELECT ';
                for I:=0 to FkFieldsList2.Count-1 do
                begin
                  if I<>0 then
                    q3.SQL.Add(' , ');

                  if LineDocTbls.Names[J] = 'GD_DOCUMENT' then
                  begin
                    q3.SQL.Add('  ' +
                      'SUM(g_his_include(1, rln.' +  FkFieldsList2[I] + '))  , ');    //gd_document.id
                  end;
                  for K :=0 to FkFieldsList.Count-1 do
                  begin
                    if K<>0 then
                      q3.SQL.Add(', ');

                    q3.SQL.Add('  ' +
                      'SUM(g_his_include(1, line' + IntToStr(I) + '.' + FkFieldsList[K] + ') ');

                    if LineDocTbls.Names[J] = 'INV_CARD' then                       //inv_card.id
                      q3.SQL.Add(' + g_his_include(2, line' + IntToStr(I) + '.id) ');

                    q3.SQL.Add(') ');
                  end;
                end;
                q3.SQL.Add(' ' +
                  'FROM '  +                                                    #13#10 +
                     q2.FieldByName('relation_name').AsString + ' rln ');
                for I:=0 to FkFieldsList2.Count-1 do
                begin
                  q3.SQL.Add('  ' +
                    'LEFT JOIN ' +                                              #13#10 +
                       LineDocTbls.Names[J] + ' line' + IntToStr(I) + ' ' +     #13#10 +
                    '    ON line' + IntToStr(I) + '.' + q2.FieldByName('list_ref_fields').AsString + ' = rln.' + FkFieldsList2[I]);
                end;

                ExecSqlLogEvent(q3, 'IncludeDependenciesHIS');
                q3.Close;
              end;
            end;

            q2.Next;
          end;
          q2.Close;
        end;

        ProgressMsgEvent('', 100);

        Tr2.Commit;
        Tr2.StartTransaction;

        LogEvent('5)');
        // 5) Все оставшиеся Line должны затянуть за собой доки и кросс-таблицы, если имеет поле-множество
        ReprocSituation := False;
        Step := 0;
        ReprocIncrement := (LineDocTbls.Count) div STEP_COUNT;
        IsFirstIteration := True;
        J := 0;
        while (J < LineDocTbls.Count) and (not FDoStopProcessing) do
        begin
          if GoReprocess then
          begin
            GoReprocess := False;
            ReprocSituation := False;
            Step := 0;
            ProcTblsNamesList.Clear;
          end;
          ProcTblsNamesList.Append(LineDocTbls.Names[J]);
          ReprocCondition := False;

          RealKolvo := 0;
          ReProcTbl := '';
          // line values
          FkFieldsList.Clear;
          FkFieldsList.Text := StringReplace(LineDocTbls.Values[LineDocTbls.Names[J]], '||', #13#10, [rfReplaceAll, rfIgnoreCase]);

          //---------обработка FKs Line
          // 5.1) обработка записей Line которые в HIS
            // Все оставшиеся записи текущего Line должны затянуть за собой свои FK

          if IsFirstIteration then
          begin
            if LineDocTbls.Names[J] = 'GD_DOCUMENT' then
            begin
              q3.SQL.Text :=
                'SELECT SUM(g_his_include(1, id)) ' +              #13#10 +
                '  FROM gd_document ' +                            #13#10 +
                ' WHERE parent < 147000000';
              ExecSqlLogEvent(q3, 'IncludeDependenciesHIS');
              q3.Close;
            end;


            // if PK<147000000 главные поля include HIS, чтобы далее затянуть FKs таких записей
            // PKs Line
            q4.SQL.Text :=
              'SELECT ' +                                     #13#10 +
              '  TRIM(c.list_fields) AS pk_fields ' +         #13#10 +
              'FROM ' +                                       #13#10 +
              '  dbs_pk_unique_constraints c ' +              #13#10 +
              'WHERE ' +                                      #13#10 +
              '  c.relation_name = :rln ' +                   #13#10 +
              '  AND c.constraint_type = ''PRIMARY KEY'' ';

            q4.ParamByName('rln').AsString := LineDocTbls.Names[J];
            ExecSqlLogEvent(q4, 'IncludeDependenciesHIS');

            if not q4.EOF then
            begin
              FkFieldsList2.Clear;
              if AnsiPos(',', q4.FieldByName('pk_fields').AsString) = 0 then
                FkFieldsList2.Text := UpperCase(q4.FieldByName('pk_fields').AsString)
              else
                FkFieldsList2.Text := UpperCase(StringReplace(q4.FieldByName('pk_fields').AsString, ',', #13#10, [rfReplaceAll, rfIgnoreCase]));

              q3.SQL.Text :=
                'SELECT ';
              for I:=0 to FkFieldsList.Count-1 do
              begin
                if I <> 0 then
                  q3.SQL.Add(', ');

                q3.SQL.Add('  ' +
                  'SUM(g_his_include(1, rln.' + FkFieldsList[I] + ')) ');
              end;
              q3.SQL.Add(' ' +
                'FROM ' + LineDocTbls.Names[J] + ' rln ' +    #13#10 +
                'WHERE ');
              for I:=0 to FkFieldsList2.Count-1 do //PKs
              begin
                if I <> 0 then
                   q3.SQL.Add(' OR ');

                q3.SQL.Add('  ' +
                  'rln.' +  FkFieldsList2[I] + ' < 147000000 ');
              end;

              ExecSqlLogEvent(q3, 'IncludeDependenciesHIS');
              for I:=0 to q3.Current.Count-1 do // = FkFieldsList.Count
              begin
                if q3.Fields[I].AsInteger > 0 then
                begin
                  RealKolvo := RealKolvo + q3.Fields[I].AsInteger;  // каждый раз переобработка с gd_document
                  LogEvent('REPROCESS! LineTable: ' + LineDocTbls.Names[J] + ' FK: ' + FkFieldsList[I] + ' --> GD_DOCUMENT');
                end;
              end;
              q3.Close;
              FkFieldsList2.Clear;
            end;
            q4.Close;
          end;

          if LineDocTbls.Names[J] = 'GD_DOCUMENT' then
          begin
            repeat
              q3.Close;
              q3.SQL.Text :=
                'SELECT SUM(g_his_include(1, parent)) AS RealCount ' + #13#10 +
                '  FROM gd_document ' +                                #13#10 +
                ' WHERE g_his_has(1, id)=1 ';
              ExecSqlLogEvent(q3, 'CreateHIS_IncludeInHIS');                 //tr убрать sum
            until q3.FieldByName('RealCount').AsInteger = 0;
            q3.Close;
          end;

          // все FK поля в Line
          q2.SQL.Text :=                                                        ///TODO: вынести. Prepare
            'SELECT ' +                                                         #13#10 +
            '  TRIM(fc.list_fields)       AS fk_field, ' +                      #13#10 +
            '  TRIM(fc.ref_relation_name) AS ref_relation_name, ' +             #13#10 +
            '  TRIM(fc.list_ref_fields)   AS list_ref_fields ' +                #13#10 +
            'FROM dbs_fk_constraints fc ' +                                     #13#10 +
            'WHERE  ' +                                                         #13#10 +
            '  fc.relation_name = :rln ' +                                      #13#10 +
            '  AND fc.list_fields NOT LIKE ''%,%'' ';

          q2.ParamByName('rln').AsString := LineDocTbls.Names[J];
          ExecSqlLogEvent(q2, 'IncludeDependenciesHIS');

          FkFieldsListLine.Clear;
          FkFieldsList2.Clear;
          SelfFkFieldsListLine.Clear;
          SelfFkFieldsList2.Clear;
          while not q2.EOF do
          begin
            if LineDocTbls.IndexOfName(UpperCase( q2.FieldByName('ref_relation_name').AsString )) <> -1 then
            begin
              if LineDocTbls.Names[J] <> UpperCase( q2.FieldByName('ref_relation_name').AsString ) then
              begin
                FkFieldsListLine.Append(UpperCase( q2.FieldByName('fk_field').AsString ) + '=' + UpperCase( q2.FieldByName('ref_relation_name').AsString ));
                FkFieldsList2.Append(UpperCase( q2.FieldByName('list_ref_fields').AsString ));
              end
              else begin// ссылка на саму себя - обработаем отдельно, чтобы избежать переобработки
                SelfFkFieldsListLine.Append(UpperCase( q2.FieldByName('fk_field').AsString ) + '=' + UpperCase( q2.FieldByName('ref_relation_name').AsString ));
                SelfFkFieldsList2.Append(UpperCase( q2.FieldByName('list_ref_fields').AsString ));
              end;  
            end;

            q2.Next;
          end;
          q2.Close;

          if LineDocTbls.Names[J] = 'INV_CARD' then  // не обрабатывать записи для которых нет inv_movement - нужно удалить
            TmpStr := ' (g_his_has(2, rln.id)=1) OR (rln.id < 147000000) ' ;

          if FkFieldsList.Count = 1 then
          begin
            if FkFieldsListLine.IndexOfName(FkFieldsList[0]) <> -1 then
            begin
              FkFieldsList2.Delete(FkFieldsListLine.IndexOfName(FkFieldsList[0]));
              FkFieldsListLine.Delete(FkFieldsListLine.IndexOfName(FkFieldsList[0]));
            end
            else if SelfFkFieldsListLine.IndexOfName(FkFieldsList[0]) <> -1 then
            begin
              SelfFkFieldsList2.Delete(SelfFkFieldsListLine.IndexOfName(FkFieldsList[0]));
              SelfFkFieldsListLine.Delete(SelfFkFieldsListLine.IndexOfName(FkFieldsList[0]));
            end;
          end;


          if SelfFkFieldsListLine.Count <> 0 then
          begin
            if LineDocTbls.Names[J] <> 'INV_CARD' then
            begin                                                LogEvent('5) 1.');
              repeat
                FkFieldsList3.Clear;

                q3.Close;
                q3.SQL.Text :=
                  'SELECT ';
                for I:=0 to SelfFkFieldsListLine.Count-1 do
                begin
                  RefRelation := SelfFkFieldsListLine.Values[SelfFkFieldsListLine.Names[I]];
                  FkFieldsList3.Text := StringReplace(LineDocTbls.Values[RefRelation], '||', #13#10, [rfReplaceAll, rfIgnoreCase]); // главные поля таблицы ref_relation_name
                  N := FkFieldsList.IndexOf(SelfFkFieldsListLine.Names[I]);
                  if I <> 0 then
                    q3.SQL.Add(' + ');

                  q3.SQL.Add('  ' +
                    'SUM( ' +
                    '  IIF(( ');

                  if LineDocTbls.Names[J] = 'INV_CARD' then
                    q3.SQL.Add(TmpStr)
                  else begin  
                    if N = -1 then  // не главное
                    begin
                      for K:=0 to FkFieldsList.Count-1 do
                      begin
                        if K <> 0 then
                          q3.SQL.Add('  OR ');

                        q3.SQL.Add('  ' +
                          '   (g_his_has(1, rln.' + FkFieldsList[K] + ') = 1 ');

                        if IsFirstIteration then
                          q3.SQL.Add(' OR rln.' + FkFieldsList[K] + ' < 147000000 ');

                        q3.SQL.Add('  ' +
                          ') ');
                      end;
                    end
                    else begin
                      TmpList.Clear;
                      TmpList.Text := FkFieldsList.Text;
                      TmpList.Delete(N);
                      for K:=0 to TmpList.Count-1 do
                      begin
                        if K <> 0 then
                          q3.SQL.Add('  OR ');
                        q3.SQL.Add('  ' +
                          '(g_his_has(1, rln.' + TmpList[K] + ') = 1 ');

                        if IsFirstIteration then
                          q3.SQL.Add(' OR rln.' + TmpList[K] + ' < 147000000 ');

                        q3.SQL.Add('  ' +
                          ') ');
                      end;
                    end;
                  end;
                  q3.SQL.Add('), ');

                  if RefRelation = 'GD_DOCUMENT' then
                    q3.SQL.Add('  ' +
                      'g_his_include(1, rln.' +  SelfFkFieldsListLine.Names[I] + ') ')
                  else begin
                    for K:=0 to FkFieldsList3.Count-1 do
                    begin
                     if K <> 0 then
                        q3.SQL.Add(' + ');

                      q3.SQL.Add('  ' +
                        'g_his_include(1, line' + IntToStr(I) + '.' +  FkFieldsList3[K] + ') ' );
                    end;

                    if RefRelation = 'INV_CARD' then // если есть ссылка то не удаляем
                      q3.SQL.Add(' + ' +
                        ' g_his_include(2, line' + IntToStr(I) + '.id)');
                  end;

                  q3.SQL.Add(', 0)) ');
                end;

                q3.SQL.Add(' AS RealCount ' +
                  'FROM ' + LineDocTbls.Names[J] + ' rln ');

                for I:=0 to SelfFkFieldsListLine.Count-1 do
                begin
                  if SelfFkFieldsListLine.Values[SelfFkFieldsListLine.Names[I]] <> 'GD_DOCUMENT' then
                    q3.SQL.Add('  ' +
                      'LEFT JOIN ' + SelfFkFieldsListLine.Values[SelfFkFieldsListLine.Names[I]] + ' line' + IntToStr(I) + #13#10 +
                      '  ON line' + IntToStr(I) + '.' + SelfFkFieldsList2[I] + ' = rln.' + SelfFkFieldsListLine.Names[I]);
                end;

                ExecSqlLogEvent(q3, 'IncludeDependenciesHIS');
              
              until q3.FieldByName('RealCount').AsInteger = 0;
              q3.Close;
            end
            else begin      LogEvent('5) 2.');
              repeat
                FkFieldsList3.Clear;

                q3.Close;
                q3.SQL.Text :=
                  'SELECT ';
                for I:=0 to SelfFkFieldsListLine.Count-1 do
                begin
                  RefRelation := SelfFkFieldsListLine.Values[SelfFkFieldsListLine.Names[I]];
                  FkFieldsList3.Text := StringReplace(LineDocTbls.Values[RefRelation], '||', #13#10, [rfReplaceAll, rfIgnoreCase]); // главные поля таблицы ref_relation_name
                  //N := FkFieldsList.IndexOf(SelfFkFieldsListLine.Names[I]);
                  if I <> 0 then
                    q3.SQL.Add(' + ');

                  q3.SQL.Add('  ' +
                    'SUM( ');

                  q3.SQL.Add(' ' +
                    ' g_his_include(2, rln.' + SelfFkFieldsListLine.Names[I] + ')');

                  q3.SQL.Add(')  ');
                end;

                q3.SQL.Add(' AS RealCount ' +
                  'FROM ' + LineDocTbls.Names[J] + ' rln ' +
                  'WHERE ' + TmpStr);

                ExecSqlLogEvent(q3, 'IncludeDependenciesHIS');

              until q3.FieldByName('RealCount').AsInteger = 0;
              q3.Close;


              FkFieldsList3.Clear;
              q3.Close;
              q3.SQL.Text :=
                'SELECT ';
              for I:=0 to SelfFkFieldsListLine.Count-1 do
              begin
                RefRelation := SelfFkFieldsListLine.Values[SelfFkFieldsListLine.Names[I]];
                FkFieldsList3.Text := StringReplace(LineDocTbls.Values[RefRelation], '||', #13#10, [rfReplaceAll, rfIgnoreCase]); // главные поля таблицы ref_relation_name
                //N := FkFieldsList.IndexOf(SelfFkFieldsListLine.Names[I]);
                if I <> 0 then
                  q3.SQL.Add(', ');


                for K:=0 to FkFieldsList3.Count-1 do
                begin
                 if K <> 0 then
                    q3.SQL.Add(', ');

                  q3.SQL.Add('  ' +
                    'SUM(g_his_include(1, line' + IntToStr(I) + '.' +  FkFieldsList3[K] + ')) ' );
                end;
              end;
              q3.SQL.Add(' ' +
                'FROM ' + LineDocTbls.Names[J] + ' rln ');

              for I:=0 to SelfFkFieldsListLine.Count-1 do
              begin
                if SelfFkFieldsListLine.Values[SelfFkFieldsListLine.Names[I]] <> 'GD_DOCUMENT' then
                  q3.SQL.Add('  ' +
                    'LEFT JOIN ' + SelfFkFieldsListLine.Values[SelfFkFieldsListLine.Names[I]] + ' line' + IntToStr(I) + #13#10 +
                    '  ON line' + IntToStr(I) + '.' + SelfFkFieldsList2[I] + ' = rln.' + SelfFkFieldsListLine.Names[I]);
              end;

              q3.SQl.Add(' WHERE ' + TmpStr);
              ExecSqlLogEvent(q3, 'IncludeDependenciesHIS');
              q3.Close;
            end;
          end;
          {if SelfFkFieldsListLine.Count <> 0 then
          begin
            repeat
              FkFieldsList3.Clear;

              q3.Close;
              q3.SQL.Text :=
                'SELECT ';
              for I:=0 to SelfFkFieldsListLine.Count-1 do
              begin
                RefRelation := SelfFkFieldsListLine.Values[SelfFkFieldsListLine.Names[I]];
                FkFieldsList3.Text := StringReplace(LineDocTbls.Values[RefRelation], '||', #13#10, [rfReplaceAll, rfIgnoreCase]); // главные поля таблицы ref_relation_name
                N := FkFieldsList.IndexOf(SelfFkFieldsListLine.Names[I]);
                if I <> 0 then
                  q3.SQL.Add(' + ');

                q3.SQL.Add('  ' +
                  'SUM( ' +
                  '  IIF(( ');

                if LineDocTbls.Names[J] = 'INV_CARD' then
                  q3.SQL.Add(TmpStr)
                else begin  
                  if N = -1 then  // не главное
                  begin
                    for K:=0 to FkFieldsList.Count-1 do
                    begin
                      if K <> 0 then
                        q3.SQL.Add('  OR ');

                      q3.SQL.Add('  ' +
                        '   (g_his_has(1, rln.' + FkFieldsList[K] + ') = 1 ');

                      if IsFirstIteration then
                        q3.SQL.Add(' OR rln.' + FkFieldsList[K] + ' < 147000000 ');

                      q3.SQL.Add('  ' +
                        ') ');
                    end;
                  end
                  else begin
                    TmpList.Clear;
                    TmpList.Text := FkFieldsList.Text;
                    TmpList.Delete(N);
                    for K:=0 to TmpList.Count-1 do
                    begin
                      if K <> 0 then
                        q3.SQL.Add('  OR ');
                      q3.SQL.Add('  ' +
                        '(g_his_has(1, rln.' + TmpList[K] + ') = 1 ');

                      if IsFirstIteration then
                        q3.SQL.Add(' OR rln.' + TmpList[K] + ' < 147000000 ');

                      q3.SQL.Add('  ' +
                        ') ');
                    end;
                  end;
                end;
                q3.SQL.Add('), ');

                if RefRelation = 'GD_DOCUMENT' then
                  q3.SQL.Add('  ' +
                    'g_his_include(1, rln.' +  SelfFkFieldsListLine.Names[I] + ') ')
                else begin
                  for K:=0 to FkFieldsList3.Count-1 do
                  begin
                   if K <> 0 then
                      q3.SQL.Add(' + ');

                    q3.SQL.Add('  ' +
                      'g_his_include(1, line' + IntToStr(I) + '.' +  FkFieldsList3[K] + ') ' );
                  end;

                  if RefRelation = 'INV_CARD' then // если есть ссылка то не удаляем
                    q3.SQL.Add(' + ' +
                      ' g_his_include(2, line' + IntToStr(I) + '.id)');
                end;

                q3.SQL.Add(', 0)) ');
              end;

              q3.SQL.Add(' AS RealCount ' +
                'FROM ' + LineDocTbls.Names[J] + ' rln ');

              for I:=0 to SelfFkFieldsListLine.Count-1 do
              begin
                if SelfFkFieldsListLine.Values[SelfFkFieldsListLine.Names[I]] <> 'GD_DOCUMENT' then
                  q3.SQL.Add('  ' +
                    'LEFT JOIN ' + SelfFkFieldsListLine.Values[SelfFkFieldsListLine.Names[I]] + ' line' + IntToStr(I) + #13#10 +
                    '  ON line' + IntToStr(I) + '.' + SelfFkFieldsList2[I] + ' = rln.' + SelfFkFieldsListLine.Names[I]);
              end;

              ExecSqlLogEvent(q3, 'IncludeDependenciesHIS');
            
            until q3.FieldByName('RealCount').AsInteger = 0;

            q3.Close;
          end;   }


          //====================================

          if FkFieldsListLine.Count <> 0 then
          begin
            LogEvent('5) 3.');
            FkFieldsList3.Clear;

            q3.SQL.Text :=
              'SELECT ';
            for I:=0 to FkFieldsListLine.Count-1 do
            begin
              RefRelation := FkFieldsListLine.Values[FkFieldsListLine.Names[I]];
              FkFieldsList3.Text := StringReplace(LineDocTbls.Values[RefRelation], '||', #13#10, [rfReplaceAll, rfIgnoreCase]); // главные поля таблицы ref_relation_name
              N := FkFieldsList.IndexOf(FkFieldsListLine.Names[I]);
              if I <> 0 then
                q3.SQL.Add(', ');

              q3.SQL.Add('  ' +
                'SUM( ' +
                '  IIF(( ');

              if LineDocTbls.Names[J] = 'INV_CARD' then
                q3.SQL.Add(TmpStr)
              else begin
                if N = -1 then  // не главное
                begin
                  for K:=0 to FkFieldsList.Count-1 do
                  begin
                    if K <> 0 then
                      q3.SQL.Add('  OR ');

                    q3.SQL.Add('  ' +
                      '   (g_his_has(1, rln.' + FkFieldsList[K] + ') = 1 ');

                    if IsFirstIteration then
                      q3.SQL.Add(' OR rln.' + FkFieldsList[K] + ' < 147000000 ');

                    q3.SQL.Add('  ' +
                      ') ');
                  end;
                end
                else begin
                  TmpList.Clear;
                  TmpList.Text := FkFieldsList.Text;
                  TmpList.Delete(N);
                  for K:=0 to TmpList.Count-1 do
                  begin
                    if K <> 0 then
                      q3.SQL.Add('  OR ');
                    q3.SQL.Add('  ' +
                      '(g_his_has(1, rln.' + TmpList[K] + ') = 1 ');

                    if IsFirstIteration then
                      q3.SQL.Add(' OR rln.' + TmpList[K] + ' < 147000000 ');

                    q3.SQL.Add('  ' +
                      ') ');
                  end;
                end;
              end;
              q3.SQL.Add('), ');

              if RefRelation = 'GD_DOCUMENT' then
                q3.SQL.Add('  ' +
                  'g_his_include(1, rln.' +  FkFieldsListLine.Names[I] + ') ')
              else begin
                for K:=0 to FkFieldsList3.Count-1 do
                begin
                 if K <> 0 then
                    q3.SQL.Add(' + ');

                  q3.SQL.Add('  ' +
                    'g_his_include(1, line' + IntToStr(I) + '.' +  FkFieldsList3[K] + ') ' );
                end;

                if RefRelation = 'INV_CARD' then // если есть ссылка то не удаляем
                  q3.SQL.Add(' + ' +
                    ' g_his_include(2, line' + IntToStr(I) + '.id)');
              end;

              q3.SQL.Add(', 0)) ');
            end;


            q3.SQL.Add(' ' +
              'FROM ' + LineDocTbls.Names[J] + ' rln ');

            for I:=0 to FkFieldsListLine.Count-1 do
            begin
              if FkFieldsListLine.Values[FkFieldsListLine.Names[I]] <> 'GD_DOCUMENT' then
                q3.SQL.Add('  ' +
                  'LEFT JOIN ' + FkFieldsListLine.Values[FkFieldsListLine.Names[I]] + ' line' + IntToStr(I) + #13#10 +
                  '  ON line' + IntToStr(I) + '.' + FkFieldsList2[I] + ' = rln.' + FkFieldsListLine.Names[I]);
            end;

            ExecSqlLogEvent(q3, 'IncludeDependenciesHIS');

            for I:=0 to q3.Current.Count-1 do // = FkFieldsListLine.Count
            begin
              if q3.Fields[I].AsInteger > 0 then
              begin
                RefRelation := FkFieldsListLine.Values[FkFieldsListLine.Names[I]];

                if ProcTblsNamesList.IndexOf(RefRelation) <> -1 then
                begin
                  RealKolvo := RealKolvo + q3.Fields[I].AsInteger;  // каждый раз переобработка с gd_document
                  LogEvent('REPROCESS! LineTable: ' + LineDocTbls.Names[J] + ' FK: ' + FkFieldsListLine.Names[I] + ' --> ' + RefRelation);
                end;
              end;
            end;
            q3.Close;
          end;
          TmpStr := '';

          // 5.2) if Line содержит поля-множества, то обработаем их CROSS-таблицы, чтобы сохранить необходимые записи

          //---обработка PKs  если табл имеет поля-множества

          if LineSetTbls.IndexOfName(LineDocTbls.Names[J]) <> -1 then
          begin
            if LineDocTbls.Names[J] <> 'INV_CARD' then /// inv_card.id уже сохранили - HIS_2
            begin
              // PKs Line     (PK=FK обработаны уже)
              q4.SQL.Text :=
                'SELECT ' +                                     #13#10 +
                '  TRIM(c.list_fields) AS pk_fields ' +         #13#10 +
                'FROM ' +                                       #13#10 +
                '  dbs_pk_unique_constraints c ' +              #13#10 +
                'WHERE ' +                                      #13#10 +
                '  c.relation_name = :rln ' +                   #13#10 +
                '  AND c.constraint_type = ''PRIMARY KEY'' ' +  #13#10 +
                '  AND NOT EXISTS( ' +                          #13#10 +
                '    SELECT * ' +                               #13#10 +
                '    FROM dbs_fk_constraints fc ' +             #13#10 +
                '    WHERE ' +                                  #13#10 +
                '      fc.relation_name = c.relation_name ' +   #13#10 +
                '      AND fc.list_fields = c.list_fields) ';

              q4.ParamByName('rln').AsString := LineDocTbls.Names[J];
              ExecSqlLogEvent(q4, 'IncludeDependenciesHIS');

              if not q4.EOF then
              begin
                FkFieldsList3.Clear;
                if AnsiPos(',', q4.FieldByName('pk_fields').AsString) = 0 then
                  FkFieldsList3.Text := UpperCase(q4.FieldByName('pk_fields').AsString)
                else
                  FkFieldsList3.Text := UpperCase(StringReplace(q4.FieldByName('pk_fields').AsString, ',', #13#10, [rfReplaceAll, rfIgnoreCase]));

                // include pk Line если главное поле в HIS

                LogEvent('5.2)');
                q3.SQL.Text :=
                  'SELECT ';
                for I:=0 to FkFieldsList3.Count-1 do //pks
                begin
                  q3.SQL.Add(' ' +
                    ' SUM(g_his_include(1, rln.' +  FkFieldsList3[I] + ')) ');

                  if I < FkFieldsList3.Count-1 then
                    q3.SQL.Add(', ');
                end;
                q3.SQL.Add(' ' +
                  'FROM '  +
                     LineDocTbls.Names[J] + ' rln ' +           #13#10 +
                  'WHERE ');
                for I:=0 to FkFieldsList.Count-1 do //line values
                begin
                  if I <> 0 then
                     q3.SQL.Add(' OR ');

                  q3.SQL.Add('  ' +
                    '(g_his_has(1, rln.' +  FkFieldsList[I] + ') = 1) ');

                  if IsFirstIteration then
                    q3.SQL.Add(' OR (rln.' +  FkFieldsList[I] + ' < 147000000) ');
                end;

                ExecSqlLogEvent(q3, 'IncludeDependenciesHIS');
                q3.Close;
              end;
              q4.Close;
            end;
            //---------обработка полей-множеств Line

            FkFieldsList3.Clear;
            if AnsiPos(',', LineSetTbls.Values[LineDocTbls.Names[J]]) = 0 then
              FkFieldsList3.Text := LineSetTbls.Values[LineDocTbls.Names[J]]
            else
              FkFieldsList3.Text := StringReplace(LineSetTbls.Values[LineDocTbls.Names[J]], ',', #13#10, [rfReplaceAll, rfIgnoreCase]);

            for N:=0 to FkFieldsList3.Count-1 do
            begin
              // получим все не главные FK cascade поля в кросс-таблице
              q4.SQL.Text :=                                                    /// TODO: Prepare
                 'SELECT ' +                                                                          #13#10 +
                 '  TRIM(fc.list_fields)       AS list_field, ' +                                     #13#10 +
                 '  TRIM(fc.ref_relation_name) AS ref_relation_name, ' +                              #13#10 +
                  '  TRIM(fc.list_ref_fields)   AS list_ref_fields ' +                                #13#10 +
                 'FROM dbs_fk_constraints fc ' +                                                      #13#10 +
                 'WHERE  ' +                                                                          #13#10 +
                 '  fc.relation_name = :rln ' +                                                       #13#10 +
                 '  AND fc.list_fields <> ''' + CrossLineTbls.Values[FkFieldsList3[N]] + ''' ' +      #13#10 +
                 '  AND fc.list_fields NOT LIKE ''%,%'' ';
              q4.ParamByName('rln').AsString := FkFieldsList3[N];
              ExecSqlLogEvent(q4, 'IncludeDependenciesHIS');

              FkFieldsListLine.Clear;
              FkFieldsList2.Clear;
              while not q4.EOF do
              begin
                if LineDocTbls.IndexOfName(UpperCase( q4.FieldByName('ref_relation_name').AsString )) <> -1 then
                begin
                  FkFieldsListLine.Append(UpperCase( q4.FieldByName('list_field').AsString ) + '=' + UpperCase( q4.FieldByName('ref_relation_name').AsString ));
                  FkFieldsList2.Append(UpperCase( q4.FieldByName('list_ref_fields').AsString ));
                end;

                q4.Next;
              end;
              q4.Close;

              if FkFieldsListLine.Count <> 0 then
              begin            LogEvent('5.2) 2.');
                q3.SQL.Text :=
                  'SELECT ';
                for I:=0 to FkFieldsListLine.Count-1 do
                begin
                  RefRelation := FkFieldsListLine.Values[FkFieldsListLine.Names[I]];
                  FkFieldsList.Clear;
                  FkFieldsList.Text := StringReplace(LineDocTbls.Values[FkFieldsListLine.Values[FkFieldsListLine.Names[I]]], '||', #13#10, [rfReplaceAll, rfIgnoreCase]);   // главные поля таблицы ref_relation_name

                  if I<>0 then
                    q3.SQL.Add(', ');

                  q3.SQL.Add('  ' +
                      'SUM( ');
                   
                  if RefRelation = 'GD_DOCUMENT' then
                  begin
                    q3.SQL.Add(' IIF( g_his_has(1, rln.'+ CrossLineTbls.Values[FkFieldsList3[N]] + ') = 1 ');
                    if IsFirstIteration then
                      q3.SQL.Add('  ' +
                        '  OR rln.' + CrossLineTbls.Values[FkFieldsList3[N]] + ' < 147000000');
                      q3.SQL.Add(', ');

                    q3.SQL.Add('  ' +
                      'g_his_include(1, rln.' +  FkFieldsListLine.Names[I] + ')')
                  end
                  else begin
                    if RefRelation = 'INV_CARD' then // если есть ссылка то не удаляем
                    begin
                      q3.SQL.Add(' IIF( g_his_has(2, line' + IntToStr(I) + '.id)=1');
                      if IsFirstIteration then
                        q3.SQL.Add('  ' +
                          '  OR line.' +  IntToStr(I) + '.id < 147000000');

                      q3.SQL.Add(', ' +
                        'g_his_include(2, line' + IntToStr(I) + '.id) ');
                      for K:=0 to FkFieldsList.Count-1 do
                      begin
                       if K <> 0 then
                          q3.SQL.Add(' + ');

                        q3.SQL.Add('  ' +
                          'g_his_include(1, line' + IntToStr(I) + '.' +  FkFieldsList[K] + ') ' );
                      end;
                    end
                    else begin
                      q3.SQL.Add(' IIF( g_his_has(1, rln.'+ CrossLineTbls.Values[FkFieldsList3[N]] + ') = 1 ');
                      if IsFirstIteration then
                        q3.SQL.Add('  ' +
                          '  OR rln.' + CrossLineTbls.Values[FkFieldsList3[N]] + ' < 147000000');
                      q3.SQL.Add(', ');

                      for K:=0 to FkFieldsList.Count-1 do
                      begin
                       if K <> 0 then
                          q3.SQL.Add(' + ');

                        q3.SQL.Add('  ' +
                          'g_his_include(1, line' + IntToStr(I) + '.' +  FkFieldsList[K] + ') ' );
                      end;
                    end;
                  end;
                  q3.SQL.Add(', 0))');
                end;

                q3.SQL.Add('  ' +
                  'FROM '  + FkFieldsList3[N] + ' rln ');
                for I:=0 to FkFieldsListLine.Count-1 do
                begin
                  if FkFieldsListLine.Values[FkFieldsListLine.Names[I]] <> 'GD_DOCUMENT' then
                    q3.SQL.Add('  ' +
                      'LEFT JOIN ' +                                                                                 #13#10 +
                         FkFieldsListLine.Values[FkFieldsListLine.Names[I]] + ' line' + IntToStr(I) + ' ' +          #13#10 +
                      '    ON line' + IntToStr(I) + '.' + FkFieldsList2[I] + ' = rln.' + FkFieldsListLine.Names[I]);
                end;

                ExecSqlLogEvent(q3, 'IncludeDependenciesHIS');

                for I:=0 to q3.Current.Count-1 do // = FkFieldsListLine.Count
                begin
                  if q3.Fields[I].AsInteger > 0 then
                  begin
                    RefRelation := FkFieldsListLine.Values[FkFieldsListLine.Names[I]];
                    
                    if ProcTblsNamesList.IndexOf(RefRelation) <> -1 then
                    begin
                      RealKolvo := RealKolvo + q3.Fields[I].AsInteger;  // каждый раз переобработка с gd_document
                      LogEvent('REPROCESS! CrossTable: ' + FkFieldsList3[N]  + ' FK: ' + FkFieldsListLine.Names[I] + ' --> ' + RefRelation);
                    end;
                  end;
                end;
                q3.Close;
              end;
              TmpStr := '';
            end;
          end;

          LogEvent('==> ' + IntToStr(J) + ' ' + LineDocTbls.Names[J]);
////////////
          if RealKolvo > 0 then // переобработаем в конце шага
            ReprocSituation := True;

          if not IsFirstIteration then
          begin
            if Step <> STEP_COUNT-1 then
            begin
              if ((J+1) mod ReprocIncrement) = 0 then
              begin
                Inc(Step);
                ReprocCondition := True;
              end;
            end
            else if J = LineDocTbls.Count-1 then
              ReprocCondition := True;
          end
          else if J = LineDocTbls.Count-1 then
          begin
            IsFirstIteration := False;
            ReprocCondition := True;
          end;

          // запуск переобработки
          if  ReprocSituation and ReprocCondition then
          begin
            GoReprocess := True;
            J := 0 - 1;

            LogEvent('GO REPROCESS gd_doc!');
          end;
////////////
          ProgressMsgEvent('');
          Inc(J);
        end;

        // сохраним обработанные таблицы чтобы только для них отключать и удалять
        FCascadeTbls.Text := LineDocTbls.Text;
        if CrossLineTbls.Count > 0 then
          FCascadeTbls.CommaText := FCascadeTbls.CommaText + ',' + CrossLineTbls.CommaText;

        Tr.Commit;
        Tr2.Commit;
        LogEvent('Including in HIS... OK');
      except
        on E: Exception do
        begin
          Tr.Rollback;
          Tr2.Rollback;
          raise EgsDBSqueeze.Create(E.Message);
        end;
      end;
    finally
      LineDocTbls.Free;
      CrossLineTbls.Free;
      ReProcLineTbls.Free;
      LineSetTbls.Free;
      SelfFkFieldsListLine.Free;
      SelfFkFieldsList2.Free;
      ExcFKTbls.Free;
      FkFieldsList.Free;
      FkFieldsList2.Free;
      FkFieldsList3.Free;
      FkFieldsListLine.Free;
      CascadeProcTbls.Free;
      ProcTblsNamesList.Free;
      TblsNamesList.Free;
      AllProcessedTblsNames.Free;
      LineTblsList.Free;
      AllProc.Free;
      LinePosList.Free;
      ReProc.Free;
      ReProcAll.Free;
      TmpList.Free;
      q.Free;
      q2.Free;
      q3.Free;
      q4.Free;
      q5.Free;
      Tr.Free;
      Tr2.Free;
    end;
  end;

  function TableHasId(TableName: String): Boolean;
  var
    q: TIBSQL;
    Tr: TIBTransaction;
  begin
    q := TIBSQL.Create(nil);
    Tr := TIBTransaction.Create(nil);
    try
      Tr.DefaultDatabase := FIBDatabase;
      Tr.StartTransaction;

      q.Transaction := Tr;

      q.SQL.Text :=
        'SELECT * ' +                                       #13#10 +
        'FROM RDB$RELATION_FIELDS rf ' +                    #13#10 +
        '  LEFT JOIN dbs_fk_constraints fc ' +              #13#10 +
        '    ON fc.relation_name = rf.RDB$RELATION_NAME ' + #13#10 +
        '      AND fc.list_fields = rf.RDB$FIELD_NAME ' +   #13#10 +
        'WHERE rf.RDB$RELATION_NAME = :RN ' +               #13#10 +
        '  AND rf.RDB$FIELD_NAME = :FN ' +
        '  AND fc.list_fields IS NULL';

      q.ParamByName('RN').AsString := UpperCase(Trim(TableName));
      q.ParamByName('FN').AsString := 'ID';
      ExecSqlLogEvent(q, 'CreateInvBalance');

      Result := not q.EOF;

      Tr.Commit;
    finally
      q.Free;
      Tr.Free;
    end;
  end;

begin
  LogEvent('Including Keys In HugeIntSet... ');
  Assert(Connected);

  SetBlockTriggerActive(False);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  try
CreateHIS(0);

    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q2.Transaction := Tr;

    q.SQL.Text :=                                                               //////////////////
        'UPDATE gd_document doc ' +
        '   SET doc.documentdate = :ClosingDate ' +
        ' WHERE doc.id = :SaldoDocKey ';
      q.ParamByName('ClosingDate').AsDateTime := FClosingDate-1;
      q.ParamByName('SaldoDocKey').AsInteger := FInvSaldoDoc;
    ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');

    Tr.Commit;
    Tr.StartTransaction;

    LogEvent('Update INV_CARD...');
 
    q.SQL.Text :=
      'SELECT SUM(g_his_include(0, cardkey)) FROM DBS_TMP_INV_SALDO';
    if not FDoStopProcessing then
      ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');
    q.Close;

    Tr.Commit;
    Tr.StartTransaction;

    q.SQL.Text :=
      'UPDATE inv_card c ' +
      'SET c.firstdocumentkey = :SaldoDocKey, ' +
      '    c.documentkey = :SaldoDocKey ' +
      'WHERE g_his_has(0, c.id)=1 ';
    q.ParamByName('SaldoDocKey').AsInteger := FInvSaldoDoc;
    if not FDoStopProcessing then
      ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');

    Tr.Commit;
    Tr.StartTransaction;

    if (GetCountHIS(0) > 0) and (not FDoStopProcessing) then
    begin
      repeat
        q.Close;
        q.SQL.Text :=
          'SELECT SUM(g_his_include(0, id)) AS Kolvo ' +
          'FROM inv_card ' +
          'WHERE g_his_has(0, parent)=1';
        ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');
      until q.FieldByName('Kolvo').AsInteger = 0;
    end;
    q.Close;

    Tr.Commit;
    Tr.StartTransaction;

    q2.SQL.Text :=
        'SELECT ' +
        '  TRIM(rf.rdb$field_name) AS FieldName ' +                     #13#10 +
        'FROM ' +                                                       #13#10 +
        '  rdb$relation_fields rf ' +                                   #13#10 +
        'WHERE ' +                                                      #13#10 +
        '  rf.rdb$relation_name = ''INV_CARD'' ' +                      #13#10 +
        '  AND rf.rdb$field_name IN(''USR$INV_ADDLINEKEY'', ''USR$INV_MOVEDOCKEY'', ''USR$INV_BILLLINEKEY'', ''USR$INV_PRMETALKEY'', ''USR$WC_STARTUPDOCKEY'', ''USR$WC_CONSERVREVDOCKEY'', ''USR$WC_CONSERVATIONDOCKEY'') ' + #13#10 +
        '  AND COALESCE(rf.rdb$system_flag, 0) = 0 ';
    ExecSqlLogEvent(q2, 'CreateHIS_IncludeInHIS');

    if not q2.EOF then
    begin
      q.SQL.Text :=
        'UPDATE inv_card c ' +
        'SET ';
      while not q2.EOF do
      begin
        if UpperCase(q2.FieldByName('FieldName').AsString) <> 'USR$INV_MOVEDOCKEY' then
          q.SQL.Add(' ' +
            ' c.' + q2.FieldByName('FieldName').AsString + ' = :SaldoDocKey ')
        else
          q.SQL.Add(' ' +
            ' c.' + q2.FieldByName('FieldName').AsString + ' = NULL ');

        q2.Next;
        if not q2.EOF then
          q.SQL.Add(', ');
      end;
      q.SQL.Add(' ' +
         'WHERE g_his_has(0, c.id)=1 ');
    end;
    q2.Close;

    q.ParamByName('SaldoDocKey').AsInteger := FInvSaldoDoc;
    if not FDoStopProcessing then
      ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');

DestroyHIS(0);

    Tr.Commit;
    Tr.StartTransaction;
    LogEvent('Update INV_CARD... OK');
    //////////////////////////


    LogEvent('DELETE FROM INV_BALANCE...');

    q.SQL.Text :=
      'DELETE FROM INV_BALANCE';
    ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');
    Tr.Commit;
    Tr.StartTransaction;

    LogEvent('DELETE FROM INV_BALANCE... OK');

    LogEvent('DELETE FROM AC_RECORD...');

    q.SQL.Text :=
      'DELETE FROM gd_ruid gr ' +               #13#10 +
      'WHERE EXISTS( ' +                        #13#10 +
      '  SELECT * ' +                           #13#10 +
      '  FROM AC_RECORD ar ' +                  #13#10 +
      '  WHERE ar.id = gr.xid ' +               #13#10 +
      '    AND ar.recorddate < :ClosingDate ';
    q.SQL.Add(')');
    q.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');

    q.SQL.Text :=
      'DELETE FROM AC_RECORD ' +                #13#10 +
      ' WHERE recorddate < :ClosingDate ';
    q.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    if not FDoStopProcessing then
      ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');
    Tr.Commit;
    Tr.StartTransaction;

    LogEvent('DELETE FROM AC_RECORD... OK');
    Tr.Commit;
    Tr.StartTransaction;
    ProgressMsgEvent('', 100);

    CreateHIS(1);

    // новые доки и с типами указанными пользователем должны остаться
    
    q.SQL.Text :=
      'SELECT SUM(g_his_include(1, doc.id)) AS Kolvo ' + #13#10 +
      'FROM gd_document doc ' +                          #13#10 +
      'WHERE doc.parent IS NULL ' +                      #13#10 +
      '  AND ((doc.documentdate >= :Date) ';
    if Assigned(FDocTypesList) then
    begin
      q.SQL.Add(' ' +
        ' OR (doc.documentdate < :Date ');
      if not FDoProcDocTypes then
        q.SQL.Add(' ' +
          '   AND doc.documenttypekey IN(' + FDocTypesList.CommaText + ')) ')
      else
        q.SQL.Add(' ' +
          '   AND doc.documenttypekey NOT IN(' + FDocTypesList.CommaText + ')) ');
    end;
    q.SQL.Add(')');
    q.ParamByName('Date').AsDateTime := FClosingDate;
    if not FDoStopProcessing then
      ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');
    q.Close;

    q.SQL.Text :=
      'SELECT g_his_include(1, :SaldoDocKey) FROM rdb$database ';                           /////////////
    q.ParamByName('SaldoDocKey').AsInteger := FInvSaldoDoc;
    if not FDoStopProcessing then
      ExecSqlLogEvent(q, 'CalculateInvSaldo');
    q.Close;

    LogEvent('DELETE FROM INV_MOVEMENT...');

    q.SQL.Text :=
      'SELECT SUM(g_his_include(1, id)) FROM gd_document WHERE g_his_has(1, parent)=1 OR parent<147000000 ';
    if not FDoStopProcessing then
      ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');
    q.Close;

    q.SQL.Text :=
      'DELETE FROM gd_ruid gr ' +                    #13#10 +
      'WHERE EXISTS(' +                              #13#10 +
      '  SELECT * ' +                                #13#10 +
      '  FROM inv_movement im ' +                    #13#10 +
      '  WHERE im.id = gr.xid ' +                    #13#10 +
      '    AND g_his_has(1, im.documentkey)=0' +     #13#10 +
      ')';
    ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');

    q.SQL.Text :=
      'DELETE FROM INV_MOVEMENT ' +                  #13#10 +
      ' WHERE g_his_has(1, documentkey)=0 ';
    ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');
    Tr.Commit;
    Tr.StartTransaction;
    LogEvent('DELETE FROM INV_MOVEMENT... OK');


    CreateHIS(2); // inv_card.id на которые есть ссылки
    ProgressMsgEvent('', 100);


    if not FDoStopProcessing then
      IncludeDependenciesHIS('GD_DOCUMENT');

 
    LogEvent(Format('AFTER COUNT in HIS(1): %d', [GetCountHIS(1)]));
    q.SQL.Text :=                                                               ///TODO: обновлять прогресс
      'DELETE FROM gd_ruid gr ' +                    #13#10 +
      'WHERE EXISTS(' +                              #13#10 +
      '  SELECT * ' +                                #13#10 +
      '  FROM gd_document doc ' +                    #13#10 +
       ' WHERE doc.id = gr.xid ' +                   #13#10 +
       '   AND g_his_has(1, doc.id)=0 ' +            #13#10 +
      '    AND id >= 147000000 ' +                   #13#10 +
      ')';
    ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');

    for I:=1 to FCascadeTbls.Count-1 do
    begin
      if TableHasId(FCascadeTbls.Names[I]) then
      begin
        if AnsiPos('||', FCascadeTbls.Values[FCascadeTbls.Names[I]]) = 0 then
          q.SQL.Text :=
            'DELETE FROM gd_ruid gr ' +                     #13#10 +
            'WHERE EXISTS(' +                               #13#10 +
            '  SELECT * ' +                                 #13#10 +
            '  FROM ' + FCascadeTbls.Names[I]  + ' rln ' +  #13#10 +
            '  WHERE rln.id = gr.xid ' +                                                        #13#10 +
            '    AND g_his_has(1, rln.' + FCascadeTbls.Values[FCascadeTbls.Names[I]] + ')=0 ' + #13#10 +
            '    AND rln.' + FCascadeTbls.Values[FCascadeTbls.Names[I]] + ' >= 147000000) '
        else begin
          if FCascadeTbls.Names[I] = 'INV_CARD' then
            q.SQL.Text :=
              'DELETE FROM gd_ruid gr ' +                    #13#10 +
              'WHERE EXISTS(' +                              #13#10 +
              '  SELECT * ' +                                #13#10 +
              '  FROM inv_card rln ' +                       #13#10 +
              '  WHERE rln.id = gr.xid ' +                   #13#10 +
              '    AND g_his_has(2, rln.id)=0 ' +            #13#10 +
              '    AND rln.id >= 147000000) '
          else
            q.SQL.Text :=
              'DELETE FROM gd_ruid gr ' +                    #13#10 +
              'WHERE EXISTS(' +                              #13#10 +
              '  SELECT * ' +                                #13#10 +
              '  FROM ' + FCascadeTbls.Names[I]  + ' rln ' + #13#10 +
              '  WHERE rln.id = gr.xid ' +                                                                                                                                       #13#10 +
              '    AND (rln.' +  StringReplace(FCascadeTbls.Values[FCascadeTbls.Names[I]], '||', ' >= 147000000) AND (rln.', [rfReplaceAll, rfIgnoreCase]) + ' >= 147000000) ' + #13#10 +
              '    AND (g_his_has(1, rln.' + StringReplace(FCascadeTbls.Values[FCascadeTbls.Names[I]], '||', ')=0 OR g_his_has(1, rln.', [rfReplaceAll, rfIgnoreCase]) + ')=0 )) ';
        end;

        ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');
      end;
    end;

    if RelationExist2('AC_ENTRY_BALANCE', Tr) then
    begin
      q.SQL.Text :=
        'SELECT ' +                                          #13#10 +
        '  rdb$generator_name ' +                            #13#10 +
        'FROM ' +                                            #13#10 +
        '  rdb$generators ' +                                #13#10 +
        'WHERE ' +                                           #13#10 +
        '  rdb$generator_name = ''GD_G_ENTRY_BALANCE_DATE''';
      ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');
      if q.RecordCount <> 0 then
      begin
        q.Close;
        q.SQL.Text :=
          'SELECT ' +                                                                                    #13#10 +
          '  (GEN_ID(gd_g_entry_balance_date, 0) - ' + IntToStr(15018) + ') AS CalculatedBalanceDate ' + #13#10 +
          'FROM rdb$database ';
        ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');
        if q.FieldByName('CalculatedBalanceDate').AsInteger > 0 then
        begin
          if q.FieldByName('CalculatedBalanceDate').AsInteger < FClosingDate then
          begin
            q.Close;
            q.SQL.Text :=
              'DELETE FROM GD_RUID gr ' +   #13#10 +
              'WHERE EXISTS( ' +            #13#10 +
              '  SELECT * FROM ac_entry_balance ae WHERE ae.id = gr.xid)';
            ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');
          end;
        end;
      end;
      q.Close;
    end;

    Tr.Commit;
    ProgressMsgEvent('', 100);
    LogEvent('Including PKs In HugeIntSet... OK');
    if FCurrentProgressStep < 33*PROGRESS_STEP then
      ProgressMsgEvent('', ((33*PROGRESS_STEP) - FCurrentProgressStep));
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.SetTriggersState(const ATableName: String; const AIsActive: Boolean);
var
  StateStr: String;
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    
    q.Transaction := Tr;

    if AIsActive then
      StateStr := 'ACTIVE'
    else
      StateStr := 'INACTIVE';

    q.SQL.Text :=
      'EXECUTE BLOCK ' +                                                      #13#10 +
      'AS ' +                                                                 #13#10 +
      '  DECLARE VARIABLE TN CHAR(31); ' +                                    #13#10 +
      'BEGIN ' +                                                              #13#10 +
      '  FOR ' +                                                              #13#10 +
      '    SELECT ' +                                                         #13#10 +
      '      rdb$trigger_name ' +                                             #13#10 +
      '    FROM ' +                                                           #13#10 +
      '      rdb$triggers ' +                                                 #13#10 +
      '    WHERE ' +                                                          #13#10 +
     // '      rdb$trigger_inactive = 0 ' +                                     #13#10 +
      '      rdb$system_flag = 0 ' +                                          #13#10 +
      '      AND rdb$relation_name = ''' + UpperCase(Trim(ATableName))  + ''' ' + #13#10 +
      '    INTO :TN ' +                                                       #13#10 +
      '  DO ' +                                                               #13#10 +
      '  BEGIN ' +                                                            #13#10 +
      '    EXECUTE STATEMENT ''ALTER TRIGGER '' || :TN || '' ' + StateStr + ' ''; ' + #13#10 +
      '  END ' +                                                                      #13#10 +
      'END';
    if not FDoStopProcessing then
      ExecSqlLogEvent(q, 'SetBlockTriggerActive');

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.MergeCards(const ADocDate: TDateTime; const ADocTypeList: TStringList; const AUsrSelectedFieldsList: TStringList);
var
  Tr: TIBTransaction;
  q, q2: TIBSQL;
  I: Integer;
  FkFields: TStringList;
begin
  LogEvent('InvCard merging... ');
  Assert(Connected);

  FkFields :=  TStringList.Create;
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  try
    CreateHIS(0);

    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q2.Transaction := Tr;

    if RelationExist2('DBS_TMP_MERGE_CARD', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM DBS_TMP_MERGE_CARD';
      ExecSqlLogEvent(q, 'MergeCards');
      LogEvent('Table DBS_TMP_MERGE_CARD exists.');
    end
    else begin
      q.SQL.Text :=
        'CREATE TABLE DBS_TMP_MERGE_CARD ( ' +             #13#10 +
        '  OLD_CARDKEY INTEGER, ' +                        #13#10 +
        '  NEW_CARDKEY INTEGER, ' +                        #13#10 +
        'constraint PK_DBS_TMP_MERGE_CARD primary key (OLD_CARDKEY))';
      ExecSqlLogEvent(q, 'MergeCards');
      LogEvent('Table DBS_TMP_MERGE_CARD has been created.');
    end;

    Tr.Commit;
    Tr.StartTransaction;

    q.SQL.Text :=
      'SELECT SUM(g_his_include(0, doc.id)) AS Kolvo ' +   #13#10 +
      'FROM gd_document doc ' +                            #13#10 +
      'WHERE  ' +                                          #13#10 +
      '  doc.documentdate < :DocDate ';
    if ADocTypeList.Count <> 0 then
      q.SQL.Add(' ' +
        'AND doc.documenttypekey IN(' + ADocTypeList.CommaText + ') ');
    q.ParamByName('DocDate').AsDateTime := ADocDate;
    if not FDoStopProcessing then
      ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');
    q.Close;


    q2.SQL.Text :=
      'SELECT LIST( ' +                                               #13#10 +
      '  TRIM(rf.rdb$field_name) || '' '' || ' +                      #13#10 +
      '  CASE f.rdb$field_type ' +                                    #13#10 +
      '    WHEN 7 THEN ' +                                            #13#10 +
      '      CASE f.rdb$field_sub_type ' +                            #13#10 +
      '        WHEN 0 THEN '' SMALLINT'' ' +                          #13#10 +
      '        WHEN 1 THEN '' NUMERIC('' || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' +  #13#10 +
      '        WHEN 2 THEN '' DECIMAL(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' + #13#10 +
      '      END ' +                                                  #13#10 +
      '    WHEN 8 THEN ' +                                            #13#10 +
      '      CASE f.rdb$field_sub_type ' +                            #13#10 +
      '        WHEN 0 THEN '' INTEGER'' ' +                           #13#10 +
      '        WHEN 1 THEN '' NUMERIC(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' + #13#10 +
      '        WHEN 2 THEN '' DECIMAL(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' + #13#10 +
      '      END ' +                                                  #13#10 +
      '    WHEN 9 THEN '' QUAD'' ' +                                  #13#10 +
      '    WHEN 10 THEN '' FLOAT'' ' +                                #13#10 +
      '    WHEN 12 THEN '' DATE'' ' +                                 #13#10 +
      '    WHEN 13 THEN '' TIME'' ' +                                 #13#10 +
      '    WHEN 14 THEN '' CHAR('' || (TRUNC(f.rdb$field_length / ch.rdb$bytes_per_character)) || '')'' ' +      #13#10 +
      '    WHEN 16 THEN ' +                                           #13#10 +
      '      CASE f.rdb$field_sub_type ' +                            #13#10 +
      '        WHEN 0 THEN '' BIGINT'' ' +                            #13#10 +
      '        WHEN 1 THEN '' NUMERIC(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' + #13#10 +
      '        WHEN 2 THEN '' DECIMAL(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' + #13#10 +
      '      END ' +                                                  #13#10 +
      '    WHEN 27 THEN '' DOUBLE'' ' +                               #13#10 +
      '    WHEN 35 THEN '' TIMESTAMP'' ' +                            #13#10 +
      '    WHEN 37 THEN '' VARCHAR('' || (TRUNC(f.rdb$field_length / ch.rdb$bytes_per_character)) || '')'' ' +   #13#10 +
      '    WHEN 40 THEN '' CSTRING('' || (TRUNC(f.rdb$field_length / ch.rdb$bytes_per_character)) || '')'' ' +   #13#10 +
      '    WHEN 45 THEN '' BLOB_ID'' ' +                              #13#10 +
      '    WHEN 261 THEN '' BLOB'' ' +                                #13#10 +
      '    ELSE '' RDB$FIELD_TYPE:?'' ' +                             #13#10 +
      '  END, '';'')  AS FieldsList ' +                                #13#10 +
      'FROM rdb$relation_fields rf ' +                                #13#10 +
      '  JOIN rdb$fields f ON (f.rdb$field_name = rf.rdb$field_source) ' +                                       #13#10 +
      '  LEFT OUTER JOIN rdb$character_sets ch ON (ch.rdb$character_set_id = f.rdb$character_set_id) ' +         #13#10 +
      'WHERE ' +                                                      #13#10 +
      '  rf.rdb$relation_name = ''INV_CARD'' ' +                      #13#10 +
      '  AND rf.rdb$field_name IN (''' + StringReplace(AUsrSelectedFieldsList.CommaText, ',', ''',''', [rfReplaceAll, rfIgnoreCase]) + ''') ' + #13#10 +
      '  AND COALESCE(rf.rdb$system_flag, 0) = 0 ';
    if not FDoStopProcessing then
      ExecSqlLogEvent(q2, 'MergeCards');


    q.SQL.Text :=
      'EXECUTE BLOCK   ' +
      'AS  ' +                                             #13#10 +
      '  DECLARE VARIABLE OLD_CARD    INTEGER = NULL;  ' + #13#10 +
      '  DECLARE VARIABLE NEW_CARD    INTEGER = NULL;  ' + #13#10 +
      '  DECLARE VARIABLE goodkey     INTEGER = NULL;  ' + #13#10 +
      '  DECLARE VARIABLE old_goodkey INTEGER = NULL;  ';
    if AUsrSelectedFieldsList.Count > 0 then
    begin
      q.SQL.Add('  ' +
        'DECLARE VARIABLE ' + StringReplace(q2.FieldByName('FieldsList').AsString, ';', ' = NULL;  DECLARE VARIABLE ', [rfReplaceAll, rfIgnoreCase]) + ' = NULL;  ' +
        'DECLARE VARIABLE old_' + StringReplace(q2.FieldByName('FieldsList').AsString, ';', ' = NULL;  DECLARE VARIABLE old_', [rfReplaceAll, rfIgnoreCase]) + ' = NULL; ');
    end;
    q.SQL.Add('  ' +                                       #13#10 +
      'BEGIN  ' +                                          #13#10 +
      '  FOR  ' +                                          #13#10 +
      '      SELECT  ' +                                   #13#10 +
      '        ic.id, ' +                                  #13#10 +
      '        ic.goodkey ');
    if AUsrSelectedFieldsList.Count > 0 then
      q.SQL.Add(', ' +
        '      ic.' + StringReplace(AUsrSelectedFieldsList.CommaText, ',', ',ic.', [rfReplaceAll, rfIgnoreCase]));
    q.SQL.Add(
      '      FROM inv_card ic  ' +                         #13#10 +
      '      WHERE g_his_has(0, ic.documentkey)=1 ' +      #13#10 +
      '      ORDER BY   ' +                                #13#10 +
      '        ic.goodkey ');
    if AUsrSelectedFieldsList.Count > 0 then
      q.SQL.Add(', ' +
        '      ic.' + StringReplace(AUsrSelectedFieldsList.CommaText, ',', ',ic.', [rfReplaceAll, rfIgnoreCase]));
    q.SQL.Add(
      '    INTO ' +                                        #13#10 +
      '      :OLD_CARD, ' +                                #13#10 +
      '      :goodkey ');
    if AUsrSelectedFieldsList.Count > 0 then
      q.SQL.Add(', ' +
        '    :' + StringReplace(AUsrSelectedFieldsList.CommaText, ',', ', :', [rfReplaceAll, rfIgnoreCase]));
    q.SQL.Add(
      '  DO BEGIN ' +                                      #13#10 +
      '    IF (' +                                         #13#10 +
      '      old_goodkey IS NOT DISTINCT FROM :goodkey ');
    for I:=0 to AUsrSelectedFieldsList.Count-1 do
      q.SQL.Add(
        '    AND old_' + AUsrSelectedFieldsList[I] + ' IS NOT DISTINCT FROM :' + AUsrSelectedFieldsList[I]);
    q.SQL.Add(
      '    ) THEN ' +                                           #13#10 +
      '      INSERT INTO DBS_TMP_MERGE_CARD (old_cardkey, new_cardkey) VALUES (:OLD_CARD, :NEW_CARD); ' +  #13#10 +
      '    ELSE ' +                                             #13#10 +
      '    BEGIN ' +                                            #13#10 +
      '      NEW_CARD = :OLD_CARD; ' +                          #13#10 +
      '      old_goodkey = :goodkey; ');
    for I:=0 to AUsrSelectedFieldsList.Count-1 do
      q.SQL.Add(
        '    old_' + AUsrSelectedFieldsList[I] + ' = :' + AUsrSelectedFieldsList[I] + '; ');
    q.SQL.Add(
      '    END ' +                                         #13#10 +
      '  END ' +                                           #13#10 +
      'END ');

    if not FDoStopProcessing then
      ExecSqlLogEvent(q, 'MergeCards');

    q2.Close;  
    DestroyHIS(0);

    Tr.Commit;
    Tr.StartTransaction;

    SetTriggersState('INV_MOVEMENT', False);

    q2.SQL.Text :=
      'DELETE FROM inv_balance';
    if not FDoStopProcessing then
      ExecSqlLogEvent(q2, 'MergeCards');


     SetTriggersState('INV_CARD', False);

    {
    q.SQL.Text := 'ALTER TRIGGER INV_BU_CARD inactive ';
    if not FDoStopProcessing then
      ExecSqlLogEvent(q, 'MergeCards');      }

    Tr.Commit;
    Tr.StartTransaction;

    q2.SQL.Text :=
      'SELECT ' +                                                     #13#10 +
      '  c.rdb$relation_name                 AS relation_name, ' +    #13#10 +
      '  LIST(TRIM(iseg.rdb$field_name))     AS fk_fields ' +         #13#10 +
      'FROM ' +                                                       #13#10 +
      '  rdb$relation_constraints c  ' +                              #13#10 +
      '  JOIN RDB$REF_CONSTRAINTS refc ' +                            #13#10 +
      '    ON c.rdb$constraint_name = refc.rdb$constraint_name ' +    #13#10 +
      '  JOIN RDB$RELATION_CONSTRAINTS c2 ' +                         #13#10 +
      '    ON refc.rdb$const_name_uq = c2.rdb$constraint_name ' +     #13#10 +
      '  JOIN RDB$INDEX_SEGMENTS iseg ' +                             #13#10 +
      '    ON iseg.rdb$index_name = c.rdb$index_name ' +              #13#10 +
      'WHERE ' +                                                      #13#10 +
      '  c2.rdb$relation_name = ''INV_CARD'' ' +                      #13#10 +
      '  AND c.rdb$relation_name <> ''INV_BALANCE'' '  +              #13#10 +
      '  AND c.rdb$constraint_type = ''FOREIGN KEY '' ' +             #13#10 +
      '  AND c.rdb$constraint_name NOT LIKE ''RDB$%'' ' +             #13#10 +
      'GROUP BY ' +                                                   #13#10 +
      '  c.rdb$relation_name, c2.rdb$relation_name ';
    ExecSqlLogEvent(q2, 'MergeCards');

    while (not q2.EOF) and (not FDoStopProcessing) do
    begin
      FkFields.Clear;
      FkFields.Text := StringReplace(q2.FieldByName('fk_fields').AsString, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);

      for I:=0 to FkFields.Count-1 do
      begin
        q.SQL.Text :=
          'MERGE INTO ' + q2.FieldByName('relation_name').AsString + ' rln ' +  #13#10 +
          'USING (SELECT * FROM DBS_TMP_MERGE_CARD) mc ' +                      #13#10 +
          '  ON (rln.' + FkFields[I] + ' = mc.old_cardkey) ' +                  #13#10 +
          '    WHEN MATCHED THEN ' +                                            #13#10 +
          '      UPDATE SET rln.' + FkFields[I] + ' = mc.new_cardkey ';
        ExecSqlLogEvent(q, 'MergeCards');
        q.Close;
      end;

      q2.Next;
    end;
    q2.Close;

    Tr.Commit;
    Tr.StartTransaction;

    q.SQL.Text :=
      'EXECUTE BLOCK  ' +                     #13#10 +
      'AS ' +                                 #13#10 +
      '  DECLARE VARIABLE ID INTEGER; ' +     #13#10 +
      'BEGIN ' +                              #13#10 +
      '  FOR  ' +                             #13#10 +
      '    SELECT ic.id ' +                   #13#10 +
      '    FROM inv_card ic ' +               #13#10 +
      '      JOIN dbs_tmp_merge_card mc  ' +  #13#10 +
      '        ON mc.old_cardkey = ic.id ' +  #13#10 +
      '    INTO :ID     ' +                   #13#10 +
      '  DO ' +                               #13#10 +
      '  BEGIN ' +                                                                    #13#10 +
      '    EXECUTE STATEMENT ''DELETE FROM inv_card ic WHERE ic.id = '' || :ID;  ' +  #13#10 +
      '  END ' +                                                                      #13#10 +
      'END';
    if not FDoStopProcessing then
      ExecSqlLogEvent(q, 'MergeCards');
      
    Tr.Commit;
    Tr.StartTransaction;

    SetTriggersState('INV_MOVEMENT', True);

   { q.SQL.Text := 'ALTER TRIGGER INV_BU_CARD active ';
    if not FDoStopProcessing then
      ExecSqlLogEvent(q, 'MergeCards');   }

    SetTriggersState('INV_CARD', True);

    CreateInvBalance;

    q.SQL.Text := 'DROP TABLE DBS_TMP_MERGE_CARD';
    if not FDoStopProcessing then
      ExecSqlLogEvent(q, 'DeleteDBSTables');

    Tr.Commit;
    LogEvent('InvCard merging... OK');
  finally
    q.Free;
    q2.Free;
    Tr.Free;
    FkFields.Free;
  end
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.PrepareDB;
var
  Tr: TIBTransaction;
  q: TIBSQL;

  procedure PrepareTriggers;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +                                                                #13#10 +
      'AS ' +                                                                           #13#10 +
      '  DECLARE VARIABLE TN CHAR(31); ' +                                              #13#10 +
      'BEGIN ' +                                                                        #13#10 +
      '  FOR ' +                                                                        #13#10 +
      '    SELECT t.rdb$trigger_name ' +                                                #13#10 +
      '    FROM rdb$triggers t ' +                                                      #13#10 +
     // '      JOIN DBS_TMP_PROCESSED_TABLES p ON p.relation_name = t.RDB$RELATION_NAME ' +  #13#10 +
      '    WHERE ((t.rdb$trigger_inactive = 0) OR (t.rdb$trigger_inactive IS NULL)) ' + #13#10 +
      '      AND ((t.RDB$SYSTEM_FLAG = 0) OR (t.RDB$SYSTEM_FLAG IS NULL)) ' +           #13#10 +
      //'      AND RDB$TRIGGER_NAME NOT IN (SELECT RDB$TRIGGER_NAME FROM RDB$CHECK_CONSTRAINTS) ' +
      '    INTO :TN ' +                                                                 #13#10 +
      '  DO ' +                                                                         #13#10 +
      '  BEGIN ' +                                                                      #13#10 +
      '    IN AUTONOMOUS TRANSACTION DO ' +                                             #13#10 +
      '      EXECUTE STATEMENT ''ALTER TRIGGER '' || :TN || '' INACTIVE ''; ' +         #13#10 +
      '  END ' +                                                                        #13#10 +
      'END';
    ExecSqlLogEvent(q, 'PrepareTriggers');
    Tr.Commit;
    Tr.StartTransaction;
    
    LogEvent('Triggers deactivated.');
  end;

  procedure PrepareIndices;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +                                                            #13#10 +
      'AS ' +                                                                       #13#10 +
      '  DECLARE VARIABLE N CHAR(31); ' +                                           #13#10 +
      'BEGIN ' +                                                                    #13#10 +
      '  FOR ' +                                                                    #13#10 +
     '    SELECT i.rdb$index_name ' +                                               #13#10 +
      '    FROM rdb$indices i ' +                                                   #13#10 +
    //  '      JOIN DBS_TMP_PROCESSED_TABLES p ON p.relation_name = i.RDB$RELATION_NAME ' +  #13#10 +
      '    WHERE ((i.rdb$index_inactive = 0) OR (i.rdb$index_inactive IS NULL)) ' + #13#10 +
      '      AND ((i.RDB$SYSTEM_FLAG = 0) OR (i.RDB$SYSTEM_FLAG IS NULL)) ' +       #13#10 +
      '      AND i.rdb$relation_name NOT LIKE ''DBS_%'' ' +                         #13#10 +
      '      AND ((NOT i.rdb$index_name LIKE ''RDB$%'') ' +                         #13#10 +
      '        OR ((i.rdb$index_name LIKE ''RDB$PRIMARY%'') ' +                     #13#10 +
      '        OR (i.rdb$index_name LIKE ''RDB$FOREIGN%'')) ' +                     #13#10 +
      '      ) ' +                                                                  #13#10 +

   {   //////////////////////
      '    SELECT ii.rdb$index_name ' + #13#10 +
      '    FROM rdb$indices ii ' + #13#10 +
      '    WHERE ((ii.rdb$index_inactive = 0) OR (ii.rdb$index_inactive IS NULL)) ' + #13#10 +
      '      AND ((ii.RDB$SYSTEM_FLAG = 0) OR (ii.RDB$SYSTEM_FLAG IS NULL)) ' + #13#10 +
      '      AND ii.rdb$relation_name NOT LIKE ''DBS_%'' ' + #13#10 +
      '      AND ((NOT ii.rdb$index_name LIKE ''RDB$%'') ' + #13#10 +
      '        OR ((ii.rdb$index_name LIKE ''RDB$PRIMARY%'') ' + #13#10 +
      '        OR (ii.rdb$index_name LIKE ''RDB$FOREIGN%'')) ' + #13#10 +
      '      ) ' + #13#10 +
      '      AND NOT EXISTS ( ' + #13#10 +
      '        SELECT * ' + #13#10 +
      '        FROM RDB$RELATION_CONSTRAINTS c ' + #13#10 +
      '          JOIN ( ' + #13#10 +
      '          	SELECT  ' + #13#10 +
      '          	  inx.RDB$INDEX_NAME,                   ' + #13#10 +
      '              LIST(TRIM(inx.RDB$FIELD_NAME)) as List_Fields    ' + #13#10 +
      '            FROM  ' + #13#10 +
      '              RDB$INDEX_SEGMENTS inx                       ' + #13#10 +
      '            GROUP BY  ' + #13#10 +
      '              inx.RDB$INDEX_NAME                      ' + #13#10 +
      '          ) i ON c.RDB$INDEX_NAME = i.RDB$INDEX_NAME  ' + #13#10 +
      '        WHERE ' + #13#10 +
      '          c.RDB$INDEX_NAME = ii.rdb$index_name ' + #13#10 +
      '          AND EXISTS( ' + #13#10 +
      '              SELECT * ' + #13#10 +
      '              FROM   RDB$RELATION_CONSTRAINTS cc  ' + #13#10 +
      '                JOIN RDB$REF_CONSTRAINTS refcc  ' + #13#10 +
      '                  ON cc.RDB$CONSTRAINT_NAME = refcc.RDB$CONSTRAINT_NAME  ' + #13#10 +
      '                JOIN RDB$RELATION_CONSTRAINTS cc2  ' + #13#10 +
      '                  ON refcc.RDB$CONST_NAME_UQ = cc2.RDB$CONSTRAINT_NAME ' + #13#10 +
      '                JOIN rdb$index_segments isegc  ' + #13#10 +
      '                  ON isegc.rdb$index_name = cc.rdb$index_name  ' + #13#10 +
      '                JOIN rdb$index_segments ref_isegc  ' + #13#10 +
      '                  ON ref_isegc.rdb$index_name = cc2.rdb$index_name  ' + #13#10 +
      '              WHERE ' + #13#10 +
      '                cc2.RDB$RELATION_NAME = c.RDB$RELATION_NAME ' + #13#10 +
      '                AND cc.rdb$constraint_type = ''FOREIGN KEY'' ' + #13#10 +
      '                AND refcc.rdb$delete_rule IN(''SET NULL'', ''SET DEFAULT'')   ' + #13#10 +
      '                AND cc.rdb$constraint_name NOT LIKE ''RDB$%'' ' + #13#10 +
      '          ) ' + #13#10 +
      //'	      AND (c.rdb$constraint_type = ''PRIMARY KEY'' OR c.rdb$constraint_type = ''UNIQUE'')  ' + #13#10 +
      //'	      AND c.rdb$constraint_name NOT LIKE ''RDB$%''    ' + #13#10 +

      '        UNION ' + #13#10 +

      '        SELECT * ' + #13#10 +
      '        FROM RDB$RELATION_CONSTRAINTS c                     ' + #13#10 +
      '          JOIN ( ' + #13#10 +
      '          	SELECT  ' + #13#10 +
      '          	  inx.RDB$INDEX_NAME,                   ' + #13#10 +
      '              LIST(TRIM(inx.RDB$FIELD_NAME)) as List_Fields    ' + #13#10 +
      '            FROM  ' + #13#10 +
      '              RDB$INDEX_SEGMENTS inx                       ' + #13#10 +
      '            GROUP BY  ' + #13#10 +
      '              inx.RDB$INDEX_NAME                      ' + #13#10 +
      '          ) i ON c.RDB$INDEX_NAME = i.RDB$INDEX_NAME  ' + #13#10 +
      '        WHERE ' + #13#10 +
      '          c.RDB$INDEX_NAME = ii.rdb$index_name ' + #13#10 +
      '          AND EXISTS( ' + #13#10 +
      '            SELECT * ' + #13#10 +
      '            FROM  ' + #13#10 +
      '              RDB$RELATION_CONSTRAINTS cc  ' + #13#10 +
      '              JOIN RDB$REF_CONSTRAINTS refcc  ' + #13#10 +
      '                ON cc.RDB$CONSTRAINT_NAME = refcc.RDB$CONSTRAINT_NAME  ' + #13#10 +
      '              JOIN RDB$RELATION_CONSTRAINTS cc2  ' + #13#10 +
      '                ON refcc.RDB$CONST_NAME_UQ = cc2.RDB$CONSTRAINT_NAME ' + #13#10 +
      '              JOIN rdb$index_segments isegc  ' + #13#10 +
      '                ON isegc.rdb$index_name = cc.rdb$index_name  ' + #13#10 +
      '              JOIN rdb$index_segments ref_isegc  ' + #13#10 +
      '                ON ref_isegc.rdb$index_name = cc2.rdb$index_name  ' + #13#10 +
      '            WHERE ' + #13#10 +
      '              cc2.RDB$RELATION_NAME = c.RDB$RELATION_NAME ' + #13#10 +
      '              AND cc.rdb$constraint_type = ''FOREIGN KEY'' ' + #13#10 +
      '              AND refcc.rdb$delete_rule IN(''SET NULL'', ''SET DEFAULT'')   ' + #13#10 +
      '              AND cc.rdb$constraint_name NOT LIKE ''RDB$%'' ' + #13#10 +
      '          ) ' + #13#10 +
      //'          AND (c.rdb$constraint_type = ''PRIMARY KEY'' OR c.rdb$constraint_type = ''UNIQUE'')  ' + #13#10 +
      //'          AND c.rdb$constraint_name NOT LIKE ''RDB$%'' ' + #13#10 +
      '      ) ' + #13#10 +
   }

      '    INTO :N ' +                                                          #13#10 +
      '  DO ' +                                                                 #13#10 +
      '    EXECUTE STATEMENT ''ALTER INDEX '' || :N || '' INACTIVE ''; ' +      #13#10 +
      'END';
    ExecSqlLogEvent(q, 'PrepareIndices');
    Tr.Commit;
    Tr.StartTransaction;
    LogEvent('Indices deactivated.');
  end;

  procedure PreparePkUniqueConstraints;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +                                                        #13#10 +
      'AS ' +                                                                   #13#10 +
      '  DECLARE VARIABLE CN CHAR(31); ' +                                      #13#10 +
      '  DECLARE VARIABLE RN CHAR(31); ' +                                      #13#10 +
      'BEGIN ' +                                                                #13#10 +
      '  FOR ' +                                                                #13#10 +
      '    SELECT ' +                                                           #13#10 +
      '      pc.constraint_name, ' +                                            #13#10 +
      '      pc.relation_name ' +                                               #13#10 +
      '    FROM ' +                                                             #13#10 +
      '      dbs_pk_unique_constraints pc ' +                                   #13#10 +
    //'      JOIN DBS_TMP_PROCESSED_TABLES p ON p.relation_name = pc.RELATION_NAME ' +  #13#10 +
      '    WHERE ' +
      '      pc.relation_name NOT LIKE ''DBS_%'' ' +                            #13#10 +
////////////////////
{           '  AND NOT EXISTS( ' +                                              #13#10 +
      '       SELECT * ' +                                                      #13#10 +
      '       FROM rdb$relation_constraints cc  ' +                             #13#10 +
      '         JOIN RDB$REF_CONSTRAINTS refcc  ' +                             #13#10 +
      '           ON cc.rdb$constraint_name = refcc.rdb$constraint_name  ' +    #13#10 +
      '         JOIN RDB$RELATION_CONSTRAINTS cc2  ' +                          #13#10 +
      '           ON refcc.rdb$const_name_uq = cc2.rdb$constraint_name ' +      #13#10 +
      '         JOIN RDB$INDEX_SEGMENTS isegc  ' +                              #13#10 +
      '           ON isegc.rdb$index_name = cc.rdb$index_name  ' +              #13#10 +
      '         JOIN RDB$INDEX_SEGMENTS ref_isegc  ' +                          #13#10 +
      '           ON ref_isegc.rdb$index_name = cc2.rdb$index_name  ' +         #13#10 +
      '       WHERE ' +                                                         #13#10 +
      '         cc2.rdb$relation_name = pc.relation_name ' +                    #13#10 +
      '         AND cc.rdb$constraint_type = ''FOREIGN KEY'' ' +                #13#10 +
      '         AND refcc.rdb$delete_rule IN(''SET NULL'', ''SET DEFAULT'') ' + #13#10 +
      '         AND cc.rdb$constraint_name NOT LIKE ''RDB$%'' ' +               #13#10 +
      '   ) ' +                                                                 #13#10 +         }
///////////////////
 {
      ////////////////////
      '      AND NOT EXISTS( ' +                                                #13#10 +
      '        SELECT * ' + 							#13#10 +
      '        FROM dbs_fk_constraints cc ' +					#13#10 +
      '        WHERE ' +							#13#10 +
      '          cc.ref_relation_name = pc.relation_name ' +			#13#10 +
      '          AND cc.delete_rule IN(''SET NULL'', ''SET DEFAULT'') ' +       #13#10 +
      '          AND cc.constraint_name NOT LIKE ''RDB$%'' ' +               	#13#10 +
      '      ) ' +                                                              #13#10 +
      /////////////////// }
      '    INTO :CN, :RN ' +                                                              #13#10 +
      '  DO ' +                                                                           #13#10 +
      '    EXECUTE STATEMENT ''ALTER TABLE '' || :RN || '' DROP CONSTRAINT '' || :CN; ' + #13#10 +
      'END';
    ExecSqlLogEvent(q, 'PreparePkUniqueConstraints');
    Tr.Commit;
    Tr.StartTransaction;
    LogEvent('PKs&UNIQs dropped.');
  end;

  procedure PrepareFKConstraints;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +                                                #13#10 +
      'AS ' +                                                           #13#10 +
      '  DECLARE VARIABLE CN CHAR(31); ' +                              #13#10 +
      '  DECLARE VARIABLE RN CHAR(31); ' +                              #13#10 +
      'BEGIN ' +                                                        #13#10 +
      '  FOR ' +                                                        #13#10 +
      '    SELECT ' +                                                   #13#10 +
      '      c.constraint_name, ' +                                     #13#10 +
      '      c.relation_name ' +                                        #13#10 +
      '    FROM ' +                                                     #13#10 +
      '      dbs_fk_constraints c ' +                                   #13#10 +
      //'      JOIN DBS_TMP_PROCESSED_TABLES p ON p.relation_name = c.relation_name ' +  #13#10 +
      '    WHERE ' +                                                    #13#10 +
      '      c.constraint_name NOT LIKE ''DBS_%'' ' +                   #13#10 +
      //'      AND c.delete_rule NOT IN(''SET NULL'', ''SET DEFAULT'') ' +#13#10 +
      '    INTO :CN, :RN ' +                                            #13#10 +
      '  DO ' +                                                                           #13#10 +
      '    EXECUTE STATEMENT ''ALTER TABLE '' || :RN || '' DROP CONSTRAINT '' || :CN; ' + #13#10 +
      'END';
    ExecSqlLogEvent(q, 'PrepareFKConstraints');

    Tr.Commit;
    Tr.StartTransaction;

    LogEvent('FKs dropped.');
  end;

begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    LogEvent('DB preparation...');

    SetBlockTriggerActive(True);

    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    try
      PrepareFKConstraints;
      ProgressMsgEvent('', 1*PROGRESS_STEP);
      if not FDoStopProcessing then
        PreparePkUniqueConstraints;
      ProgressMsgEvent('', 1*PROGRESS_STEP);
      if not FDoStopProcessing then
        PrepareTriggers;
      if not FDoStopProcessing then
        PrepareIndices;
      ProgressMsgEvent('', 1*PROGRESS_STEP);                                

      Tr.Commit;
      LogEvent('DB preparation... OK');
    except
      on E: Exception do
      begin
        Tr.Rollback;
        raise;
      end;
    end
  finally
    q.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.DeleteOldAcEntryBalance; // удаление старого бухгалтерского сальдо
const
  IB_DATE_DELTA = 15018; // разница в днях между "нулевыми" датами Delphi и InterBase
var
  q: TIBSQL;
  Tr: TIBTransaction;
  CalculatedBalanceDate: TDateTime; // значение генератора с датой последнего подсчета ENTRY BALANCE
begin
  LogEvent('Deleting old entries balance...');
  Assert(Connected);

  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    if RelationExist2('AC_ENTRY_BALANCE', Tr) then
    begin
      q.SQL.Text := 
        'SELECT ' +                                             #13#10 +
        '  rdb$generator_name ' +                               #13#10 +
        'FROM ' +                                               #13#10 +
        '  rdb$generators ' +                                   #13#10 +
        'WHERE ' +                                              #13#10 +
        '  rdb$generator_name = ''GD_G_ENTRY_BALANCE_DATE''';
      ExecSqlLogEvent(q, 'DeleteOldAcEntryBalance');
      if q.RecordCount <> 0 then
      begin
        q.Close;
        q.SQL.Text :=
          'SELECT ' +                                                                                            #13#10 +
          '  (GEN_ID(gd_g_entry_balance_date, 0) - ' + IntToStr(IB_DATE_DELTA) + ') AS CalculatedBalanceDate ' + #13#10 +
          'FROM rdb$database ';
        ExecSqlLogEvent(q, 'DeleteOldAcEntryBalance');
        if q.FieldByName('CalculatedBalanceDate').AsInteger > 0 then
        begin
          CalculatedBalanceDate := q.FieldByName('CalculatedBalanceDate').AsInteger;

          LogEvent('Old CalculatedBalanceDate=' + DateTimeToStr(CalculatedBalanceDate));

          if CalculatedBalanceDate < FClosingDate then
          begin
            q.Close;
            q.SQL.Text := 'DELETE FROM ac_entry_balance';
            ExecSqlLogEvent(q, 'DeleteOldAcEntryBalance');

            q.SQL.Text := 'SET GENERATOR gd_g_entry_balance_date TO 0';
            ExecSqlLogEvent(q, 'DeleteOldAcEntryBalance');
          end;
        end;
      end;
    end;

    Tr.Commit;
    LogEvent('Deleting old entries balance... OK');
  finally
    q.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.DeleteDocuments_DeleteHIS;
var
  q: TIBSQL;
  Tr: TIBTransaction;
  I: Integer;
begin
  Assert(Connected);
  LogEvent('Deleting from DB... ');

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    ////TEST
    q.SQL.Text :=
      'SELECT g_his_has(1, 147818321) AS IsHas FROM rdb$database';
    ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS');
    LogEvent('[test] HIS_1 dbs_doc: ' + q.FieldByName('IsHas').AsString);
    q.Close;


    q.SQL.Text :=
      'DELETE FROM GD_DOCUMENT ' +        #13#10 +
      ' WHERE g_his_has(1, id)=0 ' +      #13#10 +
      '   AND id >= 147000000';
    ExecSqlLogEvent(q, 'DeleteDocuments_DeleteHIS');

    for I:=1 to FCascadeTbls.Count-1 do
    begin
      if AnsiPos('||', FCascadeTbls.Values[FCascadeTbls.Names[I]]) = 0 then
        q.SQL.Text :=
          'DELETE FROM ' + FCascadeTbls.Names[I]  +                                      #13#10 +
          ' WHERE (g_his_has(1,' + FCascadeTbls.Values[FCascadeTbls.Names[I]] + ')=0 ' + #13#10 +
          '   AND ' + FCascadeTbls.Values[FCascadeTbls.Names[I]] + ' >= 147000000) '
      else begin
        if FCascadeTbls.Names[I] = 'INV_CARD' then
          q.SQL.Text :=
            'DELETE FROM inv_card ' +     #13#10 +
            'WHERE g_his_has(2, id)=0 ' + #13#10 +
            '  AND id >= 147000000 '
        else
          q.SQL.Text :=
            'DELETE FROM ' + FCascadeTbls.Names[I] +                                                                                                                 #13#10 +
            ' WHERE (' +  StringReplace(FCascadeTbls.Values[FCascadeTbls.Names[I]], '||', ' >= 147000000) AND (',[rfReplaceAll, rfIgnoreCase]) + ' >= 147000000) ' + #13#10 +
            '   AND (g_his_has(1,' + StringReplace(FCascadeTbls.Values[FCascadeTbls.Names[I]], '||', ')=0 OR g_his_has(1,',[rfReplaceAll, rfIgnoreCase]) + ')=0 )';
      end;
      if not FDoStopProcessing then
        ExecSqlLogEvent(q, 'DeleteDocuments_DeleteHIS');
    end;

    Tr.Commit;

    DestroyHIS(2);
    DestroyHIS(1);
   
    LogEvent('Deleting from DB... OK');
  finally
    q.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.CreateAcEntries;
var
  qInsertAcEntry, qInsertAcRec, q2: TIBSQL;
  Tr: TIBTransaction;
begin
  LogEvent('Create entry balance...');
  Assert(Connected);

  qInsertAcRec := TIBSQL.Create(nil);
  qInsertAcEntry := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    qInsertAcRec.Transaction := Tr;
    qInsertAcEntry.Transaction := Tr;
    q2.Transaction := Tr;

    // перенос документов.  documentkey=masterdockey
    q2.SQL.Text :=
      'INSERT INTO GD_DOCUMENT ( ' +                                     #13#10 +
      '  id, ' +                                                         #13#10 +
      '  documenttypekey, ' +                                            #13#10 +
      '  number, ' +                                                     #13#10 +
      '  documentdate, ' +                                               #13#10 +
      '  companykey, ' +                                                 #13#10 +
      '  afull, achag, aview, creatorkey, editorkey) ' +                 #13#10 +
      'SELECT DISTINCT ' +                                               #13#10 +
      '  documentkey, ' +                                                #13#10 +
      '  :AccDocTypeKey, ' +                                             #13#10 +
      '  :Number, ' +                                                    #13#10 +
      '  :ClosingDate, ' +                                               #13#10 +
      '  companykey, ' +                                                 #13#10 +
      '  -1, -1, -1, :CurUserContactKey, :CurUserContactKey ' +          #13#10 +
      'FROM DBS_TMP_AC_SALDO ';
    q2.ParamByName('AccDocTypeKey').AsInteger := HOZOPERATION_DOCTYPE_KEY;
    q2.ParamByName('Number').AsString := NEWDOCUMENT_NUMBER;
    q2.ParamByName('ClosingDate').AsDateTime := FClosingDate-1;
    q2.ParamByName('CurUserContactKey').AsInteger := FCurUserContactKey;

    ExecSqlLogEvent(q2, 'CreateAcEntries');
    ProgressMsgEvent('', 2*PROGRESS_STEP);

    // перенос проводок
    qInsertAcRec.SQL.Text :=
      'INSERT INTO AC_RECORD ( ' +                                       #13#10 +
      '  id, ' +                                                         #13#10 +
      '  recorddate, ' +                                                 #13#10 +
      '  trrecordkey, ' +                                                #13#10 +
      '  transactionkey, ' +                                             #13#10 +
      '  documentkey, masterdockey, afull, achag, aview, companykey) ' + #13#10 +
      'SELECT ' +                                                        #13#10 +//DISTINCT ' +                                               
      '  recordkey, ' +                                                  #13#10 +
      '  :ClosingDate, ' +                                               #13#10 +
      '  :ProizvolnyeTrRecordKey, ' +                                    #13#10 +
      '  :ProizvolnyeTransactionKey, ' +                                 #13#10 +
      '  documentkey, masterdockey, -1, -1, -1, companykey ' +           #13#10 +
      'FROM DBS_TMP_AC_SALDO ';
    qInsertAcRec.ParamByName('ClosingDate').AsDateTime := FClosingDate-1;
    qInsertAcRec.ParamByName('ProizvolnyeTrRecordKey').AsInteger := PROIZVOLNYE_TRRECORD_KEY;
    qInsertAcRec.ParamByName('ProizvolnyeTransactionKey').AsInteger := PROIZVOLNYE_TRANSACTION_KEY;
    if not FDoStopProcessing then
      ExecSqlLogEvent(qInsertAcRec, 'CreateAcEntries');
    ProgressMsgEvent('', 2*PROGRESS_STEP);

    // перенос проводок
    qInsertAcEntry.SQL.Text :=
      'INSERT INTO AC_ENTRY (' +                                #13#10 +
      '  issimple, ' +                                          #13#10 +
      '  id, ' +                                                #13#10 +
      '  entrydate, ' +                                         #13#10 +
      '  recordkey, ' +                                         #13#10 +
      '  transactionkey, ' +                                    #13#10 +
      '  documentkey, masterdockey, companykey, accountkey, ' + #13#10 +
      '  currkey, accountpart, ' +                              #13#10 +
      '  creditncu, creditcurr, crediteq, ' +                   #13#10 +
      '  debitncu, debitcurr, debiteq ';
    if FEntryAnalyticsStr <> '' then
      qInsertAcEntry.SQL.Add(',' +
          FEntryAnalyticsStr);
    qInsertAcEntry.SQL.Add(') ' +
      'SELECT ' +                                               #13#10 +
      '  1, ' +                                                 #13#10 +
      '  id, ' +                                                #13#10 +
      '  :ClosingDate, ' +                                      #13#10 +
      '  recordkey, ' +                                         #13#10 +
      '  :ProizvolnyeTransactionKey, ' +                        #13#10 +
      '  documentkey, masterdockey, companykey, accountkey, ' + #13#10 +
      '  currkey, accountpart, ' +                              #13#10 +
      '  creditncu, creditcurr, crediteq, ' +                   #13#10 +
      '  debitncu, debitcurr, debiteq ');
    if FEntryAnalyticsStr <> '' then
      qInsertAcEntry.SQL.Add(',' +
          FEntryAnalyticsStr);
    qInsertAcEntry.SQL.Add(' ' +
      'FROM DBS_TMP_AC_SALDO ');
    qInsertAcEntry.ParamByName('ClosingDate').AsDateTime := FClosingDate-1;
    qInsertAcEntry.ParamByName('ProizvolnyeTransactionKey').AsInteger := PROIZVOLNYE_TRANSACTION_KEY;
    if not FDoStopProcessing then
      ExecSqlLogEvent(qInsertAcEntry, 'CreateAcEntries');

    Tr.Commit;
    ProgressMsgEvent('', 3*PROGRESS_STEP);
  finally
    q2.Free;
    qInsertAcRec.Free;
    qInsertAcEntry.Free;
    Tr.Free;
  end;
  LogEvent('Create entry balance... OK');
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.CreateInvSaldo;
var
  q, q2: TIBSQL;
  Tr: TIBTransaction;
begin
  LogEvent('Create inventory balance...');
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);

  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q2.Transaction := Tr;

    try
      q.SQL.Text :=
        'INSERT INTO INV_MOVEMENT ( ' +                 #13#10 +
        '  id, goodkey, movementkey, ' +                #13#10 +
        '  movementdate, ' +                            #13#10 +
        '  documentkey, cardkey, ' +                    #13#10 +
        '  debit, ' +                                   #13#10 +
        '  credit, ' +                                  #13#10 +
        '  contactkey) ' +                              #13#10 +
        'SELECT ' +                                     #13#10 +
        '  id_movement_d, goodkey, movementkey, ' +     #13#10 +
        '  :ClosingDate, ' +                            #13#10 +
        '  :SaldoDoc, cardkey, ' +                      #13#10 +
        '  IIF((balance >= 0), ' +                      #13#10 +
        '    ABS(balance), ' +                          #13#10 +
        '    0), ' +                                    #13#10 +
        '  IIF((balance >= 0), ' +                      #13#10 +
        '    0, ' +                                     #13#10 +
        '    ABS(balance)), ' +                         #13#10 +
        '  contactkey ' +                               #13#10 +
        'FROM  DBS_TMP_INV_SALDO ';
      q.ParamByName('SaldoDoc').AsInteger := FInvSaldoDoc;
      q.ParamByName('ClosingDate').AsDateTime := FClosingDate-1;
      ExecSqlLogEvent(q, 'CreateInvSaldo');

      Tr.Commit;
      Tr.StartTransaction;
      ProgressMsgEvent('', 3*PROGRESS_STEP);


     { // Создадим дебетовую часть складского движения

       q.SQL.Text :=
        'INSERT INTO INV_MOVEMENT ( ' +                 #13#10 +
        '  id, goodkey, movementkey, ' +                #13#10 +
        '  movementdate, ' +                            #13#10 +
        '  documentkey, cardkey, ' +                    #13#10 +
        '  debit, ' +                                   #13#10 +
        '  credit, ' +                                  #13#10 +
        '  contactkey) ' +                              #13#10 +
        'SELECT ' +                                     #13#10 +
        '  id_movement_d, goodkey, movementkey, ' +     #13#10 +
        '  :ClosingDate, ' +                            #13#10 +
        '  :SaldoDoc, cardkey, ' +                      #13#10 +
        '  ABS(balance), ' +                            #13#10 +
        '  0, ' +                                       #13#10 +
        '  IIF((balance >= 0), ' +                      #13#10 +
        '    contactkey, ' +                            #13#10 +
        '    :FPseudoClientKey) ' +                     #13#10 +
        'FROM  DBS_TMP_INV_SALDO ';
      q.ParamByName('SaldoDoc').AsInteger := FInvSaldoDoc;
      q.ParamByName('FPseudoClientKey').AsInteger := FPseudoClientKey;
      q.ParamByName('ClosingDate').AsDateTime := FClosingDate-1;
      ExecSqlLogEvent(q, 'CreateInvSaldo');

      Tr.Commit;
      Tr.StartTransaction;
      ProgressMsgEvent('', 3*PROGRESS_STEP);

      // Создадим кредитовую часть складского движения

      q.SQL.Text :=                                     #13#10 +
        'INSERT INTO INV_MOVEMENT ( ' +                 #13#10 +
        '  id, goodkey, movementkey, ' +                #13#10 +
        '  movementdate, ' +                            #13#10 +
        '  documentkey, cardkey, ' +                    #13#10 +
        '  debit, ' +                                   #13#10 +
        '  credit, ' +                                  #13#10 +
        '  contactkey) ' +                              #13#10 +
        'SELECT ' +                                     #13#10 +
        '  id_movement_c, goodkey, movementkey, ' +     #13#10 +
        '  :ClosingDate, ' +                            #13#10 +
        '  :SaldoDoc, ' +                               #13#10 +
        '  cardkey, ' +                                 #13#10 + 
        '  0, ' +                                       #13#10 +
        '  ABS(balance), ' +                            #13#10 +
        '  IIF((balance >= 0), ' +                      #13#10 +
        '    :FPseudoClientKey, ' +                     #13#10 +
        '    contactkey) ' +                            #13#10 +
        'FROM  DBS_TMP_INV_SALDO ';
      q.ParamByName('SaldoDoc').AsInteger := FInvSaldoDoc;
      q.ParamByName('ClosingDate').AsDateTime := FClosingDate-1;
      q.ParamByName('FPseudoClientKey').AsInteger := FPseudoClientKey;
      if not FDoStopProcessing then
        ExecSqlLogEvent(q, 'CreateInvSaldo');             }

      Tr.Commit;
      ProgressMsgEvent('', 4*PROGRESS_STEP);
      LogEvent('Create inventory balance... OK');
    except
      on E: Exception do
      begin
        Tr.Rollback;
        raise EgsDBSqueeze.Create(E.Message);
      end;
    end;
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.RestoreDB;
var
  Tr: TIBTransaction;
  q: TIBSQL;

  procedure RestoreTriggers;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +                                                                  #13#10 +
      'AS ' +                                                                             #13#10 +
      '  DECLARE VARIABLE TN CHAR(31); ' +                                                #13#10 +
      'BEGIN ' +                                                                          #13#10 +
      '  FOR ' +                                                                          #13#10 +
      '    SELECT ' +                                                                     #13#10 +
      '      t.rdb$trigger_name ' +                                                       #13#10 +
      '    FROM ' +                                                                       #13#10 +
      '      rdb$triggers t ' +                                                           #13#10 +
  //    '      JOIN DBS_TMP_PROCESSED_TABLES  p ON p.relation_name = t.RDB$RELATION_NAME ' +  #13#10 +
      '      LEFT JOIN DBS_INACTIVE_TRIGGERS it ' +                                       #13#10 +
      '        ON it.trigger_name = t.rdb$trigger_name ' +                                #13#10 +
      '    WHERE ' +                                                                      #13#10 +
      '      ((t.rdb$trigger_inactive <> 0) AND (t.rdb$trigger_inactive IS NOT NULL)) ' + #13#10 +
      '      AND ((t.rdb$system_flag = 0) OR (t.rdb$system_flag IS NULL)) ' +             #13#10 +
      '      AND it.trigger_name IS NULL ' +                                              #13#10 +
      '    INTO :TN ' +                                                                   #13#10 +
      '  DO ' +                                                                           #13#10 +
      '    EXECUTE STATEMENT ''ALTER TRIGGER '' || :TN || '' ACTIVE ''; ' +               #13#10 +
      'END';
    ExecSqlLogEvent(q, 'RestoreTriggers');

    Tr.Commit;
    Tr.StartTransaction;

    LogEvent('Triggers reactivated.');
  end;

  procedure RestoreIndices;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +                                                                  #13#10 +
      'AS ' +                                                                             #13#10 +
      '  DECLARE VARIABLE N CHAR(31); ' +                                                 #13#10 +
      'BEGIN ' +                                                                          #13#10 +
      '  FOR ' +                                                                          #13#10 +
      '    SELECT ' +                                                                     #13#10 +
      '      i.rdb$index_name ' +                                                         #13#10 +
      '    FROM ' +                                                                       #13#10 +
      '      rdb$indices i ' +                                                            #13#10 +
 //     '      JOIN DBS_TMP_PROCESSED_TABLES p ON p.relation_name = i.RDB$RELATION_NAME ' +  #13#10 +
      '      LEFT JOIN DBS_INACTIVE_INDICES ii ' +                                        #13#10 +
      '        ON ii.index_name = i.rdb$index_name ' +                                    #13#10 +
      '    WHERE ((i.rdb$index_inactive <> 0) AND (i.rdb$index_inactive IS NOT NULL)) ' + #13#10 +
      '      AND ((i.rdb$system_flag = 0) OR (i.rdb$system_flag IS NULL)) ' +             #13#10 +
      '      AND ii.index_name IS NULL ' +                                                #13#10 +
      '    INTO :N ' +                                                                    #13#10 +
      '  DO ' +                                                                           #13#10 +
      '    EXECUTE STATEMENT ''ALTER INDEX '' || :N || '' ACTIVE ''; ' +                  #13#10 +
      'END';
    ExecSqlLogEvent(q, 'RestoreIndices');

    Tr.Commit;
    Tr.StartTransaction;

    LogEvent('Indices reactivated.');
  end;

  procedure RestorePkUniqueConstraints;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +                                                                             #13#10 +
      'AS ' +                                                                                        #13#10 +
      '  DECLARE VARIABLE S VARCHAR(16384); ' +                                                      #13#10 +
      'BEGIN ' +                                                                                     #13#10 +
      '  FOR ' +                                                                                     #13#10 +
      '    SELECT ' +                                                                                #13#10 +
      '      ''ALTER TABLE '' || c.relation_name || ' +                                              #13#10 +
      '      '' ADD CONSTRAINT '' || c.constraint_name || '' '' || ' +                               #13#10 +
      '      c.constraint_type || '' ('' || ' +                                                      #13#10 +
      '      c.list_fields || '') '' ' +                                                             #13#10 +
      '    FROM dbs_pk_unique_constraints c ' +                                                      #13#10 +
  // '      JOIN DBS_TMP_PROCESSED_TABLES p ON p.relation_name = c.RELATION_NAME ' +                #13#10 +
      '    WHERE ' +                                                                                 #13#10 +
      '      c.relation_name NOT LIKE ''DBS_%'' ' +                   			             #13#10 +
      ////////////////////                                                                                          
   {   '      AND NOT EXISTS( ' +                                                        	     #13#10 +
      '        SELECT * ' + 									     #13#10 +
      '        FROM dbs_fk_constraints cc ' +							     #13#10 +
      '        WHERE ' +									     #13#10 +
      '          cc.ref_relation_name = c.relation_name ' +					     #13#10 +
      '          AND cc.delete_rule IN(''SET NULL'', ''SET DEFAULT'') ' +                            #13#10 +
      '          AND cc.constraint_name NOT LIKE ''RDB$%'' ' +               			     #13#10 +
      '      ) ' +      }                                                                            #13#10 +
      ///////////////////
      '    INTO :S ' +                                                  			     #13#10 +
      '  DO BEGIN ' +                                                   			     #13#10 +
      '    EXECUTE STATEMENT :S; ' +                                    			     #13#10 +  /// WITH AUTONOMOUS TRANSACTION
      '    when any DO ' +                                              			     #13#10 +
      '    BEGIN ' +                                                    			     #13#10 +
      '      IF (sqlcode <> 0) THEN ' +                                 			     #13#10 +
      '        S = S || '' An SQL error occurred!''; ' +                			     #13#10 +
      '      ELSE ' +                                                   			     #13#10 +
      '        S = S || '' Something bad happened!''; ' +               			     #13#10 +
      '      SUSPEND; --exception ex_custom S; ' +                      			     #13#10 +
      '    END ' +                                                      			     #13#10 +
      '  END ' +                                                        			     #13#10 +
      'END';
    ExecSqlLogEvent(q, 'RestorePkUniqueConstraints');

    Tr.Commit;
    Tr.StartTransaction;

    LogEvent('PKs&UNIQs restored.');
  end;

  procedure RestoreFKConstraints;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +                                                                            #13#10 +
      '  RETURNS(S VARCHAR(16384)) ' +                                                              #13#10 +
      'AS ' +                                                                                       #13#10 +
      'BEGIN ' +                                                                                    #13#10 +
      '  FOR ' +                                                                                    #13#10 +
      '    SELECT ' +                                                                               #13#10 +
      '      '' ALTER TABLE '' || c.relation_name || ' +                                            #13#10 +
      '      '' ADD CONSTRAINT '' || c.constraint_name || ' +                                       #13#10 +
      '      '' FOREIGN KEY ('' || c.list_fields || '') ' +                                         #13#10 +
      '         REFERENCES '' || c.ref_relation_name || ''('' || c.list_ref_fields || '') '' || ' + #13#10 +
      '      IIF(c.update_rule = ''RESTRICT'', '''', '' ON UPDATE '' || c.update_rule) || ' +       #13#10 +
      '      IIF(c.delete_rule = ''RESTRICT'', '''', '' ON DELETE '' || c.delete_rule) ' +          #13#10 +
      '    FROM ' +                                                                                 #13#10 +
      '      dbs_fk_constraints c ' +                                                               #13#10 +
     // '      JOIN DBS_TMP_PROCESSED_TABLES p ON p.relation_name = c.RELATION_NAME ' +             #13#10 +
      '    WHERE ' +                                                                                #13#10 +
      '      c.constraint_name NOT LIKE ''DBS_%'' ' +                                               #13#10 +
      ////////////////////
    //   '      AND c.delete_rule NOT IN(''SET NULL'', ''SET DEFAULT'') ' +                         #13#10 +
      ///////////////////
      '    INTO :S ' +                                                                              #13#10 +
      '  DO BEGIN ' +                                                                               #13#10 +
      '    EXECUTE STATEMENT :S; ' +                                                                #13#10 +  /// WITH AUTONOMOUS TRANSACTION
      '    when any DO ' +                                                                          #13#10 +
      '    BEGIN ' +                                                                                #13#10 +
      '      IF (sqlcode <> 0) THEN ' +                                                             #13#10 +
      '        S = S || '' An SQL error occurred!''; ' +                                            #13#10 +
      '      ELSE ' +                                                                               #13#10 +
      '        S = S || '' Something bad happened!''; ' +                                           #13#10 +
      '      SUSPEND; --exception ex_custom S; ' +                                                  #13#10 +
      '    END ' +                                                                                  #13#10 +
      '  END ' +                                                                                    #13#10 +
      'END';
    ExecSqlLogEvent(q, 'RestoreFKConstraints');

    Tr.Commit;
    Tr.StartTransaction;

    LogEvent('FKs restored.');
  end;

begin
  LogEvent('Restoring DB...');
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    try
      RestoreIndices;                 //4%
      ProgressMsgEvent('', 4*PROGRESS_STEP);
      if not FDoStopProcessing then
        RestorePkUniqueConstraints;     //8%
      ProgressMsgEvent('', 8*PROGRESS_STEP);
      if not FDoStopProcessing then
        RestoreFKConstraints;           //16%
      ProgressMsgEvent('', 14*PROGRESS_STEP);
      if not FDoStopProcessing then
        RestoreTriggers;                //2%
      ProgressMsgEvent('', 2*PROGRESS_STEP);

      Tr.Commit;
    except
      on E: Exception do
      begin
        Tr.Rollback;
        raise;
      end;
    end;
    LogEvent('Restoring DB... OK');
  finally
    q.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.CreateInvBalance;
var
  q: TIBSQL;
  Tr: TIBTransaction;

  function ExistField(FieldName: String; TableName: String): Boolean;
  var
    q: TIBSQL;
    Tr: TIBTransaction;
  begin
    q := TIBSQL.Create(nil);
    Tr := TIBTransaction.Create(nil);
    try
      Tr.DefaultDatabase := FIBDatabase;
      Tr.StartTransaction;

      q.Transaction := Tr;

      q.SQL.Text :=
        'SELECT * ' +                       #13#10 +
        '  FROM RDB$RELATION_FIELDS ' +     #13#10 +
        ' WHERE RDB$RELATION_NAME = :RN ' + #13#10 +
        '   AND RDB$FIELD_NAME = :FN ';
      q.ParamByName('RN').AsString := UpperCase(Trim(TableName));
      q.ParamByName('FN').AsString := UpperCase(Trim(FieldName));
      ExecSqlLogEvent(q, 'CreateInvBalance');

      Result := not q.EOF;

      Tr.Commit;
    finally
      q.Free;
      Tr.Free;
    end;
  end;

begin
  LogEvent('Creating inventory balance...');
  Assert(Connected);

  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    if ExistField('GOODKEY', 'INV_BALANCE') and ExistField('GOODKEY', 'INV_MOVEMENT') then 
      q.SQL.Text :=
        'INSERT INTO inv_balance (' +                      #13#10 +
        '  cardkey, ' +                                    #13#10 +
        '  contactkey, ' +                                 #13#10 +
        '  balance, ' +                                    #13#10 +
        '  goodkey ' +                                     #13#10 +
        ') ' +                                             #13#10 +
        'SELECT ' +                                        #13#10 +
        '  m.cardkey, ' +                                  #13#10 +
        '  m.contactkey, ' +                               #13#10 +
        '  SUM(m.debit - m.credit), ' +                    #13#10 +
        '  m.goodkey ' +                                   #13#10 +
        'FROM inv_movement m ' +                           #13#10 +
        'WHERE m.disabled = 0 ' +                          #13#10 +
        'GROUP BY m.cardkey, m.contactkey, m.goodkey '
    else
      q.SQL.Text :=
        'INSERT INTO inv_balance (' +                      #13#10 +
        '  cardkey, ' +                                    #13#10 +
        '  contactkey, ' +                                 #13#10 +
        '  balance ' +                                     #13#10 +
        ') ' +                                             #13#10 +
        'SELECT ' +                                        #13#10 +
        '  m.cardkey, ' +                                  #13#10 +
        '  m.contactkey, ' +                               #13#10 +
        '  SUM(m.debit - m.credit) ' +                     #13#10 +
        'FROM inv_movement m ' +                           #13#10 +
        'WHERE m.disabled = 0 ' +                          #13#10 +
        'GROUP BY m.cardkey, m.contactkey ';
    if not FDoStopProcessing then
      ExecSqlLogEvent(q, 'CreateInvBalance');

    Tr.Commit;
    LogEvent('Creating inventory balance... OK');
  finally
    q.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.DeleteDBSTables;
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);
  LogEvent('Deleting temporary metadata tables...');

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;

    try
     { q.SQL.Text := 'DROP TABLE DBS_TMP_PROCESSED_TABLES';
      ExecSqlLogEvent(q, 'DeleteDBSTables');    }

      q.SQL.Text := 'DROP TABLE DBS_TMP_AC_SALDO'; 
      {q.SQL.Text := 'DELETE FROM DBS_TMP_AC_SALDO'; }
      ExecSqlLogEvent(q, 'DeleteDBSTables');

      q.SQL.Text := 'DROP TABLE DBS_TMP_INV_SALDO';
      ExecSqlLogEvent(q, 'DeleteDBSTables');

      q.SQL.Text := 'DROP TABLE DBS_INACTIVE_TRIGGERS';
      ExecSqlLogEvent(q, 'DeleteDBSTables');

      q.SQL.Text := 'DROP TABLE DBS_INACTIVE_INDICES';
      ExecSqlLogEvent(q, 'DeleteDBSTables');

      q.SQL.Text := 'DROP TABLE DBS_PK_UNIQUE_CONSTRAINTS';
      ExecSqlLogEvent(q, 'DeleteDBSTables');

      q.SQL.Text := 'DROP TABLE DBS_SUITABLE_TABLES';
      ExecSqlLogEvent(q, 'DeleteDBSTables');

      q.SQL.Text := 'DROP TABLE DBS_FK_CONSTRAINTS';
      ExecSqlLogEvent(q, 'DeleteDBSTables');

      Tr.Commit;

      DropDBSStateJournal;
      LogEvent('Deleting temporary metadata tables... OK');
    except
      on E: Exception do
      begin
        ErrorEvent('Ошибка при удалении таблицы: ' + E.Message);
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.ExecSqlLogEvent(const AnIBSQL: TIBSQL; const AProcName: String);
const
  Ms = 1 / (24 * 60 * 60 * 1000); // Значение 1 миллисекунды в формате TDateTime
var
  I: Integer;
  ParamValuesStr: String;
  StartDT: TDateTime;
  Start, Stop: Extended;
  Time : TDateTime;
  TimeStr: String;
  Hour, Min, Sec, Milli: Word;
begin
  ParamValuesStr := '';
  for I:=0 to AnIBSQL.Params.Count-1 do
  begin
    if I <> 0 then
     ParamValuesStr := ParamValuesStr + ', ';

    if AnIBSQL.Params.Vars[I].IsNull then
      ParamValuesStr := ParamValuesStr + AnIBSQL.Params.Vars[I].Name + '=NULL'
    else
      ParamValuesStr := ParamValuesStr + AnIBSQL.Params.Vars[I].Name + '=' + AnIBSQL.Params.Vars[I].AsString;
  end;

  TimeStr := '';
  FOnLogSQLEvent('Procedure: ' + AProcName);
  FOnLogSQLEvent(AnIBSQL.SQL.Text);
  if ParamValuesStr <> '' then
    FOnLogSQLEvent('Parameters: ' + ParamValuesStr);

  StartDT := Now;
  FOnLogSQLEvent('Begin Time: ' + FormatDateTime('h:nn:ss:zzz', StartDT));
  Start := GetTickCount;
  try
    AnIBSQL.ExecQuery;
  except
    on E: Exception do
    begin
      LogEvent('ERROR in procedure: ' + AProcName);
      LogEvent('ERROR SQL: ' + AnIBSQL.SQL.Text);
      if ParamValuesStr <> '' then
        LogEvent('Parameters: ' + ParamValuesStr);
      raise EgsDBSqueeze.Create(E.Message);
    end;
  end;
  Stop := GetTickCount;

  if AnIBSQL.RowsAffected <> -1 then
    FOnLogSQLEvent('Rows Affected: ' + IntToStr(AnIBSQL.RowsAffected))
  else
    FOnLogSQLEvent('Records Count: ' + IntToStr(AnIBSQL.RecordCount));

  Time := (Stop - Start) * Ms;
  DecodeTime(Time, Hour, Min, Sec, Milli);
  if Hour > 0 then
  begin
    TimeStr := TimeStr + IntToStr(Hour);
    if Hour > 1 then
      TimeStr := TimeStr + ' hours '
    else
      TimeStr := TimeStr + ' hour ';
  end;
  if Min > 0 then
  begin
    TimeStr := TimeStr + IntToStr(Min);
    if Min > 1 then
      TimeStr := TimeStr + ' minutes '
    else
      TimeStr := TimeStr + ' minute ';
  end;
  if Sec > 0 then
  begin
    TimeStr := TimeStr + IntToStr(Sec);
    if Sec > 1 then
      TimeStr := TimeStr + ' seconds '
    else
      TimeStr := TimeStr + ' second ';
  end;
  if Ms > 0 then
    TimeStr := TimeStr + IntToStr(Milli) + ' ms ';

  FOnLogSQLEvent('Execution Time: ' + TimeStr);
  FOnLogSQLEvent('End Time: ' + FormatDateTime('h:nn:ss:zzz', (StartDT + Time)));  ///TODO: еще не выполнился в к этому моменту
  FOnLogSQLEvent('   ');
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.ExecSqlLogEvent(const AnIBQuery: TIBQuery; const AProcName: String);
const
  Ms = 1 / (24 * 60 * 60 * 1000); // Значение 1 миллисекунды в формате TDateTime
var
  I: Integer;
  ParamValuesStr: String;
  StartDT: TDateTime;
  Start, Stop: Extended;
  Time : TDateTime;
  TimeStr: String;
  Hour, Min, Sec, Milli: Word;
begin
  ParamValuesStr := '';
  for I:=0 to AnIBQuery.Params.Count-1 do
  begin
    if I <> 0 then
     ParamValuesStr := ParamValuesStr + ', ';

    if AnIBQuery.Params[I].IsNull then
      ParamValuesStr := ParamValuesStr + AnIBQuery.Params[I].Name + '=NULL'
    else
      ParamValuesStr := ParamValuesStr + AnIBQuery.Params[I].Name + '=' + AnIBQuery.Params[I].AsString;
  end;

  TimeStr := '';
  FOnLogSQLEvent('Procedure: ' + AProcName);
  FOnLogSQLEvent(AnIBQuery.SQL.Text);
  if ParamValuesStr <> '' then
    FOnLogSQLEvent('Parameters: ' + ParamValuesStr);

  StartDT := Now;
  FOnLogSQLEvent('Begin Time: ' + FormatDateTime('h:nn:ss:zzz', StartDT));
  Start := GetTickCount;
  try
    AnIBQuery.Open;
  except
    on E: Exception do
    begin
      LogEvent('ERROR in procedure: ' + AProcName);
      LogEvent('ERROR SQL: ' + AnIBQuery.SQL.Text);
      if ParamValuesStr <> '' then
        LogEvent('Parameters: ' + ParamValuesStr);
      raise EgsDBSqueeze.Create(E.Message);
    end;
  end;
  Stop := GetTickCount;

  if AnIBQuery.RowsAffected <> -1 then
    FOnLogSQLEvent('Rows Affected: ' + IntToStr(AnIBQuery.RowsAffected))
  else
    FOnLogSQLEvent('Records Count: ' + IntToStr(AnIBQuery.RecordCount));

  Time := (Stop - Start) * Ms;
  DecodeTime(Time, Hour, Min, Sec, Milli);
  if Hour > 0 then
  begin
    TimeStr := TimeStr + IntToStr(Hour);
    if Hour > 1 then
      TimeStr := TimeStr + ' hours '
    else
      TimeStr := TimeStr + ' hour ';
  end;
  if Min > 0 then
  begin
    TimeStr := TimeStr + IntToStr(Min);
    if Min > 1 then
      TimeStr := TimeStr + ' minutes '
    else
      TimeStr := TimeStr + ' minute ';
  end;
  if Sec > 0 then
  begin
    TimeStr := TimeStr + IntToStr(Sec);
    if Sec > 1 then
      TimeStr := TimeStr + ' seconds '
    else
      TimeStr := TimeStr + ' second ';
  end;
  if Ms > 0 then
    TimeStr := TimeStr + IntToStr(Milli) + ' ms ';

  FOnLogSQLEvent('Execution Time: ' + TimeStr);
  FOnLogSQLEvent('End Time: ' + FormatDateTime('h:nn:ss:zzz', (StartDT + Time)));  ///TODO: еще не выполнился в к этому моменту
  FOnLogSQLEvent('   ');
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.ProgressWatchEvent(const AProgressInfo: TgdProgressInfo);
begin
  FOnProgressWatch(Self, AProgressInfo);
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.LogEvent(const AMsg: String);
var
  PI: TgdProgressInfo;
begin
  if Assigned(FOnProgressWatch) then
  begin
    PI.State := psMessage;
    PI.Message := AMsg;
    ProgressWatchEvent(PI);
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.ProgressMsgEvent(const AMsg: String; AStepIncrement: Integer = 1);
var
  PI: TgdProgressInfo;
begin
  if Assigned(FOnProgressWatch) then
  begin
    FCurrentProgressStep :=  FCurrentProgressStep + AStepIncrement;

    PI.State := psProgress;
    PI.CurrentStep := FCurrentProgressStep;
    PI.CurrentStepName := AMsg;
    ProgressWatchEvent(PI);
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze.ErrorEvent(const AMsg: String; const AProcessName: String = '');
var
  PI: TgdProgressInfo;
begin
  if Assigned(FOnProgressWatch) then
  begin
    PI.State := psError;
    PI.ProcessName := AProcessName;
    PI.Message := AMsg;
    ProgressWatchEvent(PI);
  end;
end;

end.



