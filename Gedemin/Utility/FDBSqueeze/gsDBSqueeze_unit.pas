unit gsDBSqueeze_unit;

interface

uses
  Windows, SysUtils, IB, IBDatabase, IBSQL, Classes, gd_ProgressNotifier_unit;

type
  TActivateFlag = (aiActivate, aiDeactivate);

  TOnGetDBPropertiesEvent = procedure(const AProperties: TStringList) of object;
  TOnGetDBSizeEvent = procedure(const ADBSize: String) of object;
  TOnGetInfoTestConnectEvent = procedure(const AConnectSuccess: Boolean; const AConnectInfoList: TStringList) of object;
  TOnGetProcStatistics = procedure(const AnGdDoc: String; const AnAcEntry: String; const AnInvMovement: String; const AnInvCard: String) of object;
  TOnGetStatistics = procedure(const AnGdDoc: String; const AnAcEntry: String; const AnInvMovement: String; const AnInvCard: String) of object;
  TOnLogSQLEvent = procedure(const S: String) of object;
  TOnSetItemsCbbEvent = procedure(const ACompanies: TStringList) of object;
  TOnUsedDBEvent = procedure(const AFunctionKey: Integer; const AState: Integer; const ACallTime: String; const AnErrorMessage: String) of object;
  TOnGetConnectedEvent = procedure(const AConnected: Boolean) of object;

  EgsDBSqueeze = class(Exception);

  TgsDBSqueeze = class(TObject)
  private
    FIBDatabase: TIBDatabase;
    
    FAllOurCompaniesSaldo: Boolean;
    FBackupFileName: String;
    FCardFeaturesStr: String;   // cписок полей-признаков складской карточки
    FClosingDate: TDateTime;
    FCompanyName: String;
    FContinueReprocess: Boolean;
    FCreateBackup: Boolean;
    FCurUserContactKey: Integer;
    FDatabaseName: String;
    FEntryAnalyticsStr: String; // список всех бухгалтерских аналитик
    FLogFileName: String;
    FOnlyCompanySaldo: Boolean;
    FPassword: String;
    FSaveLog: Boolean;
    FUserName: String;

    FIgnoreTbls: TStringList;
    FCascadeTbls: TStringList;

    FOnGetConnectedEvent: TOnGetConnectedEvent;
    FOnGetDBPropertiesEvent: TOnGetDBPropertiesEvent;
    FOnGetDBSizeEvent: TOnGetDBSizeEvent;
    FOnGetInfoTestConnectEvent: TOnGetInfoTestConnectEvent;
    FOnGetProcStatistics: TOnGetProcStatistics;
    FOnGetStatistics: TOnGetStatistics;
    FOnProgressWatch: TProgressWatchEvent;
    FOnSetItemsCbbEvent: TOnSetItemsCbbEvent;
    FOnUsedDBEvent: TOnUsedDBEvent;
    FOnLogSQLEvent: TOnLogSQLEvent;

    // тест на наличие в UDF-файле функции. Raise EgsDBSqueeze exception, при отсутствии функции
    procedure FuncTest(const AFuncName: String; const ATr: TIBTransaction);

    function CreateHIS(AnIndex: Integer): Integer;
    function GetCountHIS(AnIndex: Integer): Integer;
    function DestroyHIS(AnIndex: Integer): Integer;
    function GetConnected: Boolean;
    // возвращает сгенерированный новый уникальный идентификатор
    function GetNewID: Integer;
    
  public
    constructor Create;
    destructor Destroy; override;

    procedure Connect(ANoGarbageCollect: Boolean; AOffForceWrite: Boolean);
    procedure Disconnect;
    procedure Reconnect(ANoGarbageCollect: Boolean; AOffForceWrite: Boolean);

    // записать в лог
    procedure LogEvent(const AMsg: String);
    // ExecQuery  и запись в лог
    procedure ExecSqlLogEvent(const AnIBSQL: TIBSQL; const AProcName: String; const AParamValuesStr: String = '');

    // создание бэкап-файла БД (доступно только при локальном размещении БД)
    procedure BackupDatabase;

    // создание таблицы журнала выполения операций, чтобы при повторной обработке БД можно было продолжить
    procedure CreateDBSStateJournal;
    procedure InsertDBSStateJournal(const AFunctionKey: Integer; const AState: Integer; const AErrorMsg: String = '');

    procedure SetFVariables;

    // создание необходимых таблиц для программы
    procedure CreateMetadata;
    //сохранение первоначального состояния (PKs, FKs, UNIQs, состояния индексов и триггеров)
    procedure SaveMetadata;

    // подсчет бухгалтерского сальдо
    procedure CalculateAcSaldo;
    // формирование бухгалтерского сальдо
    procedure CreateAcEntries;

    // подсчет складских остатков
    procedure CalculateInvSaldo;
    // формирование складских остатков
    procedure CreateInvSaldo;

    procedure PrepareRebindInvCards; 
    // перепревязка складских карточек и движения
    procedure RebindInvCards;

    // удаление старого бух сальдо
    procedure DeleteOldAcEntryBalance;

    // удаление документов вместе с каскадными цепочками на них
    procedure CreateHIS_IncludeInHIS;
    procedure DeleteDocuments_DeleteHIS;

    // удаление PKs, FKs, UNIQs, отключение индексов и триггеров
    procedure PrepareDB;
    // восстановление певоначального состояния (создание PKs, FKs, UNIQs, включение индексов и триггеров)
    procedure RestoreDB;

    procedure ClearDBSTables;      ////ClearDBSMetadata

    procedure GetDBPropertiesEvent;   // получить информацию о БД
    procedure GetDBSizeEvent;         // получить размер файла БД
    procedure GetInfoTestConnectEvent;// получить версию сервера и количество подключенных юзеров (учитывая нас)
    procedure GetProcStatisticsEvent; // получить кол-во записей для обработки в GD_DOCUMENT, AC_ENTRY, INV_MOVEMENT
    procedure GetStatisticsEvent;     // получить текущее кол-во записей в GD_DOCUMENT, AC_ENTRY, INV_MOVEMENT
    procedure SetItemsCbbEvent;       // заполнить список our companies для ComboBox
    procedure UsedDBEvent; // БД уже ранее обрабатывалась этой программой, вывести диалог для решения продолжить обработку либо начать заново обрабатывать

    property AllOurCompaniesSaldo: Boolean read FAllOurCompaniesSaldo write FAllOurCompaniesSaldo;
    property BackupFileName: String        read FBackupFileName       write FBackupFileName;
    property ClosingDate: TDateTime        read FClosingDate          write FClosingDate;
    property CompanyName: String           read FCompanyName          write FCompanyName;
    property Connected: Boolean            read GetConnected;
    property CreateBackup: Boolean         read FCreateBackup         write FCreateBackup;
    property DatabaseName: String          read FDatabaseName         write FDatabaseName;
    property LogFileName: String           read FLogFileName          write FLogFileName;
    property OnGetConnectedEvent: TOnGetConnectedEvent 
      read FOnGetConnectedEvent        write FOnGetConnectedEvent;
    property OnGetDBPropertiesEvent: TOnGetDBPropertiesEvent 
      read FOnGetDBPropertiesEvent     write FOnGetDBPropertiesEvent;
    property OnGetDBSizeEvent: TOnGetDBSizeEvent  read FOnGetDBSizeEvent write FOnGetDBSizeEvent;
    property OnGetInfoTestConnectEvent: TOnGetInfoTestConnectEvent 
      read FOnGetInfoTestConnectEvent  write FOnGetInfoTestConnectEvent;
    property OnGetProcStatistics: TOnGetProcStatistics 
      read FOnGetProcStatistics        write FOnGetProcStatistics;
    property OnGetStatistics: TOnGetStatistics    read FOnGetStatistics  write FOnGetStatistics;
    property OnLogSQLEvent: TOnLogSQLEvent        read FOnLogSQLEvent    write FOnLogSQLEvent;
    property OnlyCompanySaldo: Boolean            read FOnlyCompanySaldo write FOnlyCompanySaldo;
    property OnProgressWatch: TProgressWatchEvent read FOnProgressWatch  write FOnProgressWatch;
    property OnSetItemsCbbEvent: TOnSetItemsCbbEvent 
      read FOnSetItemsCbbEvent         write FOnSetItemsCbbEvent;
    property OnUsedDBEvent: TOnUsedDBEvent read FOnUsedDBEvent     write FOnUsedDBEvent;
    property Password: String              read FPassword          write FPassword;
    property SaveLog: Boolean              read FSaveLog           write FSaveLog;
    property UserName: String              read FUserName          write FUserName;
    property ContinueReprocess: Boolean    read FContinueReprocess write FContinueReprocess;
  end;

implementation

uses
  mdf_MetaData_unit, gdcInvDocument_unit, contnrs, IBQuery, IBServices, Messages, IBDatabaseInfo;

{ TgsDBSqueeze }

constructor TgsDBSqueeze.Create;
begin
  inherited;

  FIBDatabase := TIBDatabase.Create(nil);
  FIgnoreTbls := TStringList.Create;
  FCascadeTbls := TStringList.Create;
end;

destructor TgsDBSqueeze.Destroy;
begin
  if Connected then
    Disconnect;
  FIBDatabase.Free;
  FIgnoreTbls.Free;
  FCascadeTbls.Free;

  inherited;
end;

procedure TgsDBSqueeze.Connect(ANoGarbageCollect: Boolean; AOffForceWrite: Boolean);
begin
  FIBDatabase.DatabaseName := FDatabaseName;
  FIBDatabase.LoginPrompt := False;
  FIBDatabase.Params.CommaText :=
    'user_name=' + FUserName + ',' +
    'password=' + FPassword + ',' +   
    'lc_ctype=win1251';
  if ANoGarbageCollect then
    FIBDatabase.Params.Append('no_garbage_collect');
  if AOffForceWrite then
    FIBDatabase.Params.Append('force_write=0');

  FIBDatabase.Connected := True;
  FOnGetConnectedEvent(True);
  LogEvent('Connecting to DB... OK');
end;

procedure TgsDBSqueeze.Reconnect(ANoGarbageCollect: Boolean; AOffForceWrite: Boolean);
begin
  LogEvent('Reconnecting to DB...');

  Disconnect;
  Connect(ANoGarbageCollect, AOffForceWrite);

  LogEvent('Reconnecting to DB... OK');
end;

procedure TgsDBSqueeze.Disconnect;
begin
  if FIBDatabase.Connected then
  begin
    FIBDatabase.Connected := False;
    LogEvent('Disconnecting from DB... OK');
  end;
  FOnGetConnectedEvent(False);
end;


procedure TgsDBSqueeze.BackupDatabase;                                          ///TODO: тестировать
var
  BS: TIBBackupService;
  FS: TFileStream;
  DatabaseName: String;
  LogList: TStringList;
  NextLogLine: String;
begin
  if Connected then
    Disconnect;

  BS := TIBBackupService.Create(nil);
  LogList := TStringList.Create;
  try
    DatabaseName := StringReplace(FDatabaseName, 'localhost:', '', [rfIgnoreCase]);
    LogEvent('[test] DatabaseName=' + DatabaseName);

    if FileExists(FLogFileName) then
    begin
      FS:=TFileStream.Create(FLogFileName, fmOpenReadWrite);
      FS.Seek(0, soFromEnd);   // FStream.Position := FStream.Size;
    end
    else begin
      FS := TFileStream.Create(FLogFileName, fmCreate);
    end;
    
    try
      LogList.Clear;
      BS.Protocol := Local;
      BS.LoginPrompt := False;
      BS.Params.Clear;
      BS.Params.Add('user_name=' + FUserName);
      BS.Params.Add('password=' + FPassword);
      BS.DatabaseName := DatabaseName;
      BS.BackupFile.Clear;
      BS.BackupFile.Add(FBackupFileName);
      BS.Options := [IgnoreChecksums, IgnoreLimbo, NoGarbageCollection];
    
      BS.Attach;              // BackupService.Active := True;
      
      try
        if BS.Active then
        begin
          try
            BS.ServiceStart;
            while (not BS.Eof) and (BS.IsServiceRunning) do
            begin
              NextLogLine := BS.GetNextLine;
              if NextLogLine <> '' then
              begin
                LogEvent(NextLogLine);
                LogList.Add(NextLogLine + #13#10); ////FS.WriteBuffer(Pointer(NextLogLine)^, Length(NextLogLine));
              end;  
            end;
          except
            on E: Exception do
            begin
              BS.Active := False;
              raise EgsDBSqueeze.Create(E.Message);
            end;
          end;
        end;
      finally
        if BS.Active then
          BS.Detach;             // BackupService.Active := False;
        if SaveLog then
          LogList.SaveToStream(FS);
      end;
    finally
      FS.Free;
    end;

    Connect(False, True);       
  finally
    LogList.Free;
    FreeAndNil(BS);
  end;
end;

procedure TgsDBSqueeze.SetFVariables;
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
      'SELECT ' +                                       #13#10 +
      '  gu.contactkey AS CurUserContactKey ' +         #13#10 +
      'FROM ' +                                         #13#10 +
      '  gd_user gu ' +                                 #13#10 +
      'WHERE ' +                                        #13#10 +
      '  gu.ibname = CURRENT_USER';
    ExecSqlLogEvent(q, 'SetFVariables');

    if q.EOF then
      raise EgsDBSqueeze.Create('Invalid GD_USER data');

    FCurUserContactKey := q.FieldByName('CurUserContactKey').AsInteger;
    q.Close;

    q.SQL.Text :=
      'SELECT LIST( ' +                                 #13#10 +
      '  TRIM(rf.rdb$field_name)) AS UsrFieldsList ' +  #13#10 +
      'FROM ' +                                         #13#10 +
      '  rdb$relation_fields rf ' +                     #13#10 +
      'WHERE ' +                                        #13#10 +
      '  rf.rdb$relation_name = ''AC_ACCOUNT'' ' +      #13#10 +
      '  AND rf.rdb$field_name LIKE ''USR$%'' ';
    ExecSqlLogEvent(q, 'SetFVariables');

    FEntryAnalyticsStr := q.FieldByName('UsrFieldsList').AsString;
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
    
    FCardFeaturesStr := q.FieldByName('UsrFieldsList').AsString;
    q.Close;
  finally
    q.Free;
    Tr.Free;
  end;
end;

function TgsDBSqueeze.GetNewID: Integer; // return next unique id
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);
  Result := -1;

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

procedure TgsDBSqueeze.CreateDBSStateJournal;
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
      ExecSqlLogEvent(q, 'InsertDBSStateJournal',
        Format('FunctionKey = %d, State = %d, Now = %s, ErrorMsg = %s', [AFunctionKey, AState, DateTimeToStr(NowDT), AErrorMsg]))
    else
      ExecSqlLogEvent(q, 'InsertDBSStateJournal',
        Format('FunctionKey = %d, State = %d, Now = %s', [AFunctionKey, AState, DateTimeToStr(NowDT)]));

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.CalculateAcSaldo;  // подсчет бухгалтерского сальдо c сохранением в таблице DBS_TMP_AC_SALDO
var
  Tr: TIBTransaction;
  q2, q3: TIBSQL;
  I: Integer;

  OstatkiAccountKey: Integer;           //   ''00 Остатки''
  AvailableAnalyticsList: TStringList;  // cписок активных аналитик для счета

  CompanyKey: Integer;                  // PK компании, выбранной для подсчета сальдо
  OurCompaniesListStr: String;          // список компаний из gd_ourcompany
  OurCompany_EntryDocList: TStringList; // список "компания=документ для проводок"
  TmpList: TStringList;
begin
  LogEvent('Calculating entry balance...');
  Assert(Connected);

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
      q2.SQL.Text :=
        'SELECT LIST(companykey) AS OurCompaniesList ' + #13#10 +
        'FROM gd_ourcompany';
      ExecSqlLogEvent(q2, 'CalculateAcSaldo');

      OurCompaniesListStr := q2.FieldByName('OurCompaniesList').AsString;
      q2.Close;

      TmpList.Text := StringReplace(OurCompaniesListStr, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
      for I := 0 to TmpList.Count-1 do
        OurCompany_EntryDocList.Append(TmpList[I] + '=' + IntToStr(GetNewID));

      TmpList.Clear;  
    end
    else if FOnlyCompanySaldo then
    begin
      q2.SQL.Text :=
        'SELECT contactkey AS CompanyKey ' +            #13#10 +
        'FROM gd_company ' +                            #13#10 +
        'WHERE fullname = :CompanyName ';
      q2.ParamByName('CompanyName').AsString := FCompanyName;
      ExecSqlLogEvent(q2, 'CalculateAcSaldo', Format('CompanyName = %s', [FCompanyName]));

      CompanyKey := q2.FieldByName('CompanyKey').AsInteger;
      q2.Close;
    end;

    q2.SQL.Text :=
      'SELECT ' +                                       #13#10 +
      '  aac.id  AS OstatkiAccountKey ' +               #13#10 +
      'FROM AC_ACCOUNT aac ' +                          #13#10 +
      'WHERE ' +                                        #13#10 +
      '  aac.fullname = ''00 Остатки'' ';
    ExecSqlLogEvent(q2, 'CalculateAcSaldo');

    OstatkiAccountKey := q2.FieldByName('OstatkiAccountKey').AsInteger;
    q2.Close;
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
    if FOnlyCompanySaldo then
      q2.SQL.Add(' ' +                                          
        'AND ae.companykey = :CompanyKey ')
    else if FAllOurCompaniesSaldo then
      q2.SQL.Add(' ' +                                          
        'AND ae.companykey IN (' + OurCompaniesListStr + ') ');

    q2.ParamByName('EntryDate').AsDateTime := FClosingDate;
    if FOnlyCompanySaldo then
      q2.ParamByName('CompanyKey').AsInteger := CompanyKey;
    if FOnlyCompanySaldo then
      ExecSqlLogEvent(q2, 'CalculateAcSaldo', Format('EntryDate = %s ', [DateTimeToStr(FClosingDate)]))
    else
      ExecSqlLogEvent(q2, 'CalculateAcSaldo', Format('EntryDate = %s, CompanyKey = ', [DateTimeToStr(FClosingDate), CompanyKey]));

    // считаем и сохраняем сальдо для каждого счета
    while (not q2.EOF) do 
    begin

      AvailableAnalyticsList.Text := StringReplace(FEntryAnalyticsStr, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
      // получаем cписок активных аналитик, по которым ведется учет для счета
      I := 0;
      while I < AvailableAnalyticsList.Count - 1 do
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
        '  id, ' +                                              #13#10 +
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
        'SELECT ');   // CREDIT

      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +                                            // documentkey = masterkey
          'GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + #13#10)
      else if FAllOurCompaniesSaldo then
      begin                  // documentkey
        q3.SQL.Add(' ' +
          'CASE companykey ');
        for I := 0 to OurCompany_EntryDocList.Count-1 do
        begin
          q3.SQL.Add(' ' +
            'WHEN ' + OurCompany_EntryDocList.Names[I] + ' THEN ' + OurCompany_EntryDocList.Values[OurCompany_EntryDocList.Names[I]]);
        end;
        q3.SQL.Add(' ' +
          'END, ');
                             //masterdocumentkey
        q3.SQL.Add(
          'CASE companykey ');
        for I := 0 to OurCompany_EntryDocList.Count-1 do
        begin
          q3.SQL.Add(' ' +                                      #13#10 +
            'WHEN ' + OurCompany_EntryDocList.Names[I] + ' THEN ' + OurCompany_EntryDocList.Values[OurCompany_EntryDocList.Names[I]]);
        end;
        q3.SQL.Add(' ' +                                        #13#10 +
          'END, ' +                                             #13#10);
      end;

      q3.SQL.Add(
        '  accountkey, ' +                                      #13#10 +
        '  ''C'', ' +                                           #13#10 +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + #13#10 +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + #13#10 +
        '  companykey, ' +                                      #13#10 +
        '  currkey, ' +                                         #13#10 +
        '  ABS(SUM(debitncu)  - SUM(creditncu)), ' +            #13#10 +
        '  ABS(SUM(debitcurr) - SUM(creditcurr)), ' +           #13#10 +
        '  ABS(SUM(debiteq)   - SUM(crediteq)), ' +             #13#10 +
        '  0.0000 , ' +                                         #13#10 +
        '  0.0000 , ' +                                         #13#10 +
        '  0.0000');
      for I := 0 to AvailableAnalyticsList.Count - 1 do
        q3.SQL.Add(', ' +                                       #13#10 +
           AvailableAnalyticsList[I]);

      q3.SQL.Add(' ' +                                          #13#10 +
        'FROM AC_ENTRY ' +                                      #13#10 +
        'WHERE accountkey = :AccountKey ' +                     #13#10 +
        '  AND entrydate < :EntryDate ');
      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +                                        #13#10 +
          'AND companykey = :CompanyKey ')
      else if FAllOurCompaniesSaldo then
        q3.SQL.Add(' ' +                                        #13#10 +
          'AND companykey IN (' + OurCompaniesListStr + ') ');
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
        '  (SUM(debitncu) - SUM(creditncu)) < 0.0000 ' +        #13#10 +
        '   OR (SUM(debitcurr) - SUM(creditcurr)) < 0.0000 ' +  #13#10 +
        '   OR (SUM(debiteq)   - SUM(crediteq))   < 0.0000 ' +  #13#10 +

        'UNION ALL ' +                                          #13#10 +  // DEBIT

        'SELECT ');
      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +                                        #13#10 +
          'GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ')
      else if FAllOurCompaniesSaldo then
      begin       //documentkey   
        q3.SQL.Add(' ' +                                        #13#10 +
          'CASE companykey ');
        for I := 0 to OurCompany_EntryDocList.Count-1 do
        begin
          q3.SQL.Add(' ' +                                      #13#10 +
            'WHEN ' + OurCompany_EntryDocList.Names[I] + ' THEN ' + OurCompany_EntryDocList.Values[OurCompany_EntryDocList.Names[I]]);
        end;
        q3.SQL.Add(' ' +                                        #13#10 +
          'END, ');
                  //masterdocumentkey
        q3.SQL.Add(' ' +                                        #13#10 +
          'CASE companykey ');
        for i := 0 to OurCompany_EntryDocList.Count-1 do
        begin
          q3.SQL.Add(' ' +                                      #13#10 +
            'WHEN ' + OurCompany_EntryDocList.Names[I] + ' THEN ' + OurCompany_EntryDocList.Values[OurCompany_EntryDocList.Names[I]]);
        end;
        q3.SQL.Add(' ' +                                        #13#10 +
          'END, ');
      end;

      q3.SQL.Add(' ' +                                          #13#10 +
        '  accountkey, ' +                                      #13#10 +
        '  ''D'', ' +                                           #13#10 +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + #13#10 +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + #13#10 +
        '  companykey, ' +                                      #13#10 +
        '  currkey, ' +                                         #13#10 +
        '  0.0000, ' +                                          #13#10 +
        '  0.0000, ' +                                          #13#10 +
        '  0.0000, ' +                                          #13#10 +
        '  ABS(SUM(debitncu)  - SUM(creditncu)), ' +            #13#10 +
        '  ABS(SUM(debitcurr) - SUM(creditcurr)), ' +           #13#10 +
        '  ABS(SUM(debiteq)   - SUM(crediteq)) ');
      for I := 0 to AvailableAnalyticsList.Count - 1 do
        q3.SQL.Add(', ' +                                       #13#10 +
          AvailableAnalyticsList[I]);

      q3.SQL.Add(' ' +                                          #13#10 +
        'FROM AC_ENTRY ' +                                      #13#10 +
        'WHERE accountkey = :AccountKey ' +                     #13#10 +
        '  AND entrydate < :EntryDate ');
      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +                                        #13#10 +
          'AND companykey = :CompanyKey ')
      else if FAllOurCompaniesSaldo then
        q3.SQL.Add(' ' +                                        #13#10 +
          'AND companykey IN (' + OurCompaniesListStr + ') ');
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
        '  (SUM(debitncu) - SUM(creditncu)) > 0.0000 ' +        #13#10 +
        '   OR (SUM(debitcurr) - SUM(creditcurr)) > 0.0000 ' +  #13#10 +
        '   OR (SUM(debiteq)   - SUM(crediteq))   > 0.0000 '); 

      q3.ParamByName('AccountKey').AsInteger := q2.FieldByName('id').AsInteger;
      q3.ParamByName('EntryDate').AsDateTime := FClosingDate;
      if FOnlyCompanySaldo then
        q3.ParamByName('CompanyKey').AsInteger := CompanyKey;
      if FOnlyCompanySaldo then
        ExecSqlLogEvent(q3, 'CalculateAcSaldo', Format('AccountKey = %d, EntryDate = %s, CompanyKey = %d', [q2.FieldByName('id').AsInteger, DateTimeToStr(FClosingDate), CompanyKey]))
      else
        ExecSqlLogEvent(q3, 'CalculateAcSaldo', Format('AccountKey = %d, EntryDate = %s', [q2.FieldByName('id').AsInteger, DateTimeToStr(FClosingDate)]));

      // проводки по счету '00 Остатки'
      q3.SQL.Text :=
        'INSERT INTO DBS_TMP_AC_SALDO ( ' +                     #13#10 +
        '  documentkey, masterdockey, ' +                       #13#10 +
        '  accountkey, ' +                                      #13#10 +
        '  accountpart, ' +                                     #13#10 +
        '  RECORDKEY, ' +                                       #13#10 +
        '  id, ' +                                              #13#10 +
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
        'SELECT ');   // CREDIT

      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +                                        #13#10 +
          'GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ')
      else if FAllOurCompaniesSaldo then
      begin       //documentkey   
        q3.SQL.Add(' ' +                                        #13#10 +
          'CASE companykey ');
        for I := 0 to OurCompany_EntryDocList.Count-1 do
        begin
          q3.SQL.Add(' ' +                                      #13#10 +
            'WHEN ' + OurCompany_EntryDocList.Names[I] + ' THEN ' + OurCompany_EntryDocList.Values[OurCompany_EntryDocList.Names[I]]);
        end;
        q3.SQL.Add(' ' +                                        #13#10 +
          'END, ');
                  //masterdocumentkey
        q3.SQL.Add(' ' +                                        #13#10 +
          'CASE companykey ');
        for I := 0 to OurCompany_EntryDocList.Count-1 do
        begin
          q3.SQL.Add(' ' +                                      #13#10 +
            'WHEN ' + OurCompany_EntryDocList.Names[I] + ' THEN ' + OurCompany_EntryDocList.Values[OurCompany_EntryDocList.Names[I]]);
        end;
        q3.SQL.Add(' ' +                                        #13#10 +
          'END, ');
      end;

      q3.SQL.Add(' ' +                                          #13#10 +
        '  accountkey, ' +                                      #13#10 +
        '  ''C'', ' +                                           #13#10 +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + #13#10 +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + #13#10 +
        '  companykey, ' +                                      #13#10 +
        '  currkey, ' +                                         #13#10 +
        '  ABS(SUM(debitncu)  - SUM(creditncu)), ' +            #13#10 +
        '  ABS(SUM(debitcurr) - SUM(creditcurr)), ' +           #13#10 +
        '  ABS(SUM(debiteq)   - SUM(crediteq)), ' +             #13#10 +
        '  0.0000 , ' +                                         #13#10 +
        '  0.0000 , ' +                                         #13#10 +
        '  0.0000');
      for I := 0 to AvailableAnalyticsList.Count - 1 do
        q3.SQL.Add(', ' +                                       #13#10 +
          AvailableAnalyticsList[I]);

      q3.SQL.Add( ' ' +                                         #13#10 +
        'FROM AC_ENTRY ' +                                      #13#10 +
        'WHERE accountkey = :AccountKey ' +                     #13#10 +
        '  AND entrydate < :EntryDate ');
      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +                                        #13#10 +
          'AND companykey = :CompanyKey ')
      else if FAllOurCompaniesSaldo then
        q3.SQL.Add(' ' +                                        #13#10 +
          'AND companykey IN (' + OurCompaniesListStr + ') ');
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
        '  (SUM(debitncu) - SUM(creditncu)) < 0.0000 ' +        #13#10 +
        '   OR (SUM(debitcurr) - SUM(creditcurr)) < 0.0000 ' +  #13#10 +
        '   OR (SUM(debiteq)   - SUM(crediteq))   < 0.0000 ' +  #13#10 +

        'UNION ALL ' +                                          #13#10 +  // DEBIT

        'SELECT ');
      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +                                        #13#10 +
          'GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ')
      else if FAllOurCompaniesSaldo then
      begin       //documentkey   
        q3.SQL.Add(' ' +                                        #13#10 +
          'CASE companykey ');
        for I := 0 to OurCompany_EntryDocList.Count-1 do
        begin
          q3.SQL.Add(' ' +                                      #13#10 +
            'WHEN ' + OurCompany_EntryDocList.Names[I] + ' THEN ' + OurCompany_EntryDocList.Values[OurCompany_EntryDocList.Names[I]]);
        end;
        q3.SQL.Add(' ' +                                        #13#10 +
          'END, ');
                  //masterdocumentkey
        q3.SQL.Add(' ' +                                        #13#10 +
          'CASE companykey ');
        for i := 0 to OurCompany_EntryDocList.Count-1 do
        begin
          q3.SQL.Add(' ' +                                      #13#10 +
            'WHEN ' + OurCompany_EntryDocList.Names[I] + ' THEN ' + OurCompany_EntryDocList.Values[OurCompany_EntryDocList.Names[I]]);
        end;
        q3.SQL.Add(' ' +                                        #13#10 +
          'END, ');
      end;

      q3.SQL.Add(' ' +                                          #13#10 +
        '  accountkey, ' +                                      #13#10 +
        '  ''D'', ' +                                           #13#10 +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + #13#10 +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + #13#10 +
        '  companykey, ' +                                      #13#10 +
        '  currkey, ' +                                         #13#10 +
        '  0.0000, ' +                                          #13#10 +
        '  0.0000, ' +                                          #13#10 +
        '  0.0000, ' +                                          #13#10 +
        '  ABS(SUM(debitncu)  - SUM(creditncu)), ' +            #13#10 +
        '  ABS(SUM(debitcurr) - SUM(creditcurr)), ' +           #13#10 +
        '  ABS(SUM(debiteq)   - SUM(crediteq)) ');
      for I := 0 to AvailableAnalyticsList.Count - 1 do
        q3.SQL.Add(', ' +                                       #13#10 +
          AvailableAnalyticsList[I]);

      q3.SQL.Add( ' ' +                                         #13#10 +
        'FROM AC_ENTRY ' +                                      #13#10 +
        'WHERE accountkey = :AccountKey ' +                     #13#10 +
        '  AND entrydate < :EntryDate ');
      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +                                        #13#10 +
          'AND companykey = :CompanyKey ')
      else if FAllOurCompaniesSaldo then
        q3.SQL.Add(' ' +                                        #13#10 +
          'AND companykey IN (' + OurCompaniesListStr + ') ');
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
        '  (SUM(debitncu) - SUM(creditncu)) > 0.0000 ' +        #13#10 +
        '   OR (SUM(debitcurr) - SUM(creditcurr)) > 0.0000 ' +  #13#10 +
        '   OR (SUM(debiteq)   - SUM(crediteq))   > 0.0000 ');

      q3.ParamByName('AccountKey').AsInteger := OstatkiAccountKey;
      q3.ParamByName('EntryDate').AsDateTime := FClosingDate;
      if FOnlyCompanySaldo then
        q3.ParamByName('CompanyKey').AsInteger := CompanyKey;

      if FOnlyCompanySaldo then
        ExecSqlLogEvent(q3, 'CalculateAcSaldo', Format('AccountKey = %d, EntryDate = %s, CompanyKey = %d', [OstatkiAccountKey, DateTimeToStr(FClosingDate), CompanyKey]))
      else
        ExecSqlLogEvent(q3, 'CalculateAcSaldo', Format('AccountKey = %d, EntryDate = %s', [OstatkiAccountKey, DateTimeToStr(FClosingDate)]));

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

procedure TgsDBSqueeze.DeleteOldAcEntryBalance; // удаление старого бухгалтерского сальдо
const
  IB_DATE_DELTA = 15018; // разница в днях между "нулевыми" датами Delphi и InterBase
var
  q: TIBSQL;
  Tr: TIBTransaction;
  CalculatedBalanceDate: TDateTime; // значение генератора с датой последнего подсчета ENTRY BALANCE

  CompanyKey: Integer;
begin
  LogEvent('Deleting old entries balance...');
  Assert(Connected);

  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    if FOnlyCompanySaldo then
    begin
      q.SQL.Text :=
        'SELECT contactkey AS CompanyKey ' +                    #13#10 +
        'FROM GD_COMPANY ' +                                    #13#10 +
        'WHERE fullname = :CompanyName ';
      q.ParamByName('CompanyName').AsString := FCompanyName;
      ExecSqlLogEvent(q, 'DeleteOldAcEntryBalance', Format('CompanyName = %s', [FCompanyName]));

      CompanyKey := q.FieldByName('CompanyKey').AsInteger;
      q.Close;
    end;

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
          'SELECT ' +                                           #13#10 +
          '  (GEN_ID(gd_g_entry_balance_date, 0) - ' + IntToStr(IB_DATE_DELTA) + ') AS CalculatedBalanceDate ' + #13#10 +
          'FROM rdb$database ';
        ExecSqlLogEvent(q, 'DeleteOldAcEntryBalance');
        if q.FieldByName('CalculatedBalanceDate').AsInteger > 0 then
        begin
          CalculatedBalanceDate := q.FieldByName('CalculatedBalanceDate').AsInteger;

          LogEvent('[test] CalculatedBalanceDate=' + DateTimeToStr(CalculatedBalanceDate));

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

    // очистка GD_RUID от записей, содержащих значения PK удаляемых записей
    q.Close;
    q.SQL.Text :=
      'DELETE FROM gd_ruid r ' +
      'WHERE g_his_has(1, r.xid) = 1 ';
    ExecSqlLogEvent(q, 'DeleteOldAcEntryBalance');

    Tr.Commit;

    LogEvent('Deleting old entries balance... OK');
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.CreateAcEntries;
var
  q: TIBSQL;
  Tr: TIBTransaction;
  AccDocTypeKey, ProizvolnyeTransactionKey, ProizvolnyeTrRecordKey: Integer;
begin
  LogEvent('Create entry balance...');
  Assert(Connected);

  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;

    q.SQL.Text :=
      'SELECT ' +                                       #13#10 +
      '  gd.id AS AccDocTypeKey ' +                     #13#10 +
      'FROM ' +                                         #13#10 +
      '  gd_documenttype gd ' +                         #13#10 +
      'WHERE ' +                                        #13#10 +
      '  gd.name = ''Хозяйственная операция'' ';
    ExecSqlLogEvent(q, 'CreateAcEntries');
    AccDocTypeKey := q.FieldByName('AccDocTypeKey').AsInteger;
                                                                                ///TODO: проверить на существование
//    q.Close;
//    q.SQL.Text :=
//      'SELECT ' +
//      '  atr.id   AS ProizvolnyeTransactionKey ' +    // 807001
//      'FROM ' +
//      '  AC_TRANSACTION atr ' +
//      'WHERE ' +
//      '  atr.name IN (''Произвольные проводки'', ''Произвольная проводка'') ';  
//    q.ExecQuery;
    ProizvolnyeTransactionKey := 807001; //q.FieldByName('ProizvolnyeTransactionKey').AsInteger;

//    q.Close;
//    q.SQL.Text :=
//      'SELECT ' +
//      '  atrr.id  AS ProizvolnyeTrRecordKey ' +       // 807100
//      'FROM ' +
//      '  AC_TRRECORD atrr ' +
//      'WHERE atrr.transactionkey = :TrKey ';
//    q.ParamByName('TrKey').AsInteger := ProizvolnyeTransactionKey;
    ProizvolnyeTrRecordKey := 807100; //q.FieldByName('ProizvolnyeTrRecordKey').AsInteger;

    q.Close;

    // перенос документов
    q.SQL.Text :=
      'INSERT INTO GD_DOCUMENT ( ' +                            #13#10 +
      '  id, ' +                                                #13#10 +
      '  documenttypekey, ' +                                   #13#10 +
      '  number, ' +                                            #13#10 +
      '  documentdate, ' +                                      #13#10 +
      '  companykey, ' +                                        #13#10 +
      '  afull, achag, aview, creatorkey, editorkey) ' +        #13#10 +
      'SELECT DISTINCT ' +                                      #13#10 +
      '  documentkey, ' +                                       #13#10 +
      '  :AccDocTypeKey, ' +                                    #13#10 +
      '  :Number, ' +                                           #13#10 +
      '  :ClosingDate, ' +                                      #13#10 +
      '  companykey, ' +                                        #13#10 +
      '  -1, -1, -1, :CurUserContactKey, :CurUserContactKey ' + #13#10 +
      'FROM DBS_TMP_AC_SALDO ';
    q.ParamByName('AccDocTypeKey').AsInteger := AccDocTypeKey;
    q.ParamByName('Number').AsString := 'б/н';
    q.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    q.ParamByName('CurUserContactKey').AsInteger := FCurUserContactKey;

    ExecSqlLogEvent(q, 'CreateAcEntries',Format('AccDocTypeKey = %d, Number = %s, ClosingDate = %s, CurUserContactKey = %d', [AccDocTypeKey, 'б/н', DateTimeToStr(FClosingDate), FCurUserContactKey]));
    
    // перенос проводок
    q.SQL.Text :=
      'INSERT INTO AC_RECORD ( ' +                              #13#10 +
      '  id, ' +                                                #13#10 +
      '  recorddate, ' +                                        #13#10 +
      '  trrecordkey, ' +                                       #13#10 +
      '  transactionkey, ' +                                    #13#10 +
      '  documentkey, masterdockey, afull, achag, aview, companykey) ' + #13#10 +
      'SELECT DISTINCT ' +                                      #13#10 +
      '  recordkey, ' +                                         #13#10 +
      '  :ClosingDate, ' +                                      #13#10 +
      '  :ProizvolnyeTrRecordKey, ' +                           #13#10 +
      '  :ProizvolnyeTransactionKey, ' +                        #13#10 +
      '  documentkey, masterdockey, -1, -1, -1, companykey ' +  #13#10 +
      'FROM DBS_TMP_AC_SALDO ';
    q.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    q.ParamByName('ProizvolnyeTrRecordKey').AsInteger := ProizvolnyeTrRecordKey;
    q.ParamByName('ProizvolnyeTransactionKey').AsInteger := ProizvolnyeTransactionKey;

    ExecSqlLogEvent(q, 'CreateAcEntries', Format('ClosingDate = %s, ProizvolnyeTrRecordKey = %d, ProizvolnyeTransactionKey = %d', [DateTimeToStr(FClosingDate), ProizvolnyeTrRecordKey, ProizvolnyeTransactionKey]));

    // перенос проводок
   q.SQL.Text :=
      'INSERT INTO AC_ENTRY (' +                                #13#10 +
      '  issimple, ' +                                          #13#10 +
      '  id, ' +                                                #13#10 +
      '  entrydate, ' +                                         #13#10 +
      '  recordkey, ' +                                         #13#10 +
      '  transactionkey, ' +                                    #13#10 +
      '  documentkey, masterdockey, companykey, accountkey, currkey, accountpart, ' + #13#10 +
      '  creditncu, creditcurr, crediteq, ' +                   #13#10 +
      '  debitncu, debitcurr, debiteq, ' +                      #13#10 +
         FEntryAnalyticsStr + ') ' +                            #13#10 +
      'SELECT ' +                                               #13#10 +
      '  1, ' +                                                 #13#10 +
      '  id, ' +                                                #13#10 +
      '  :ClosingDate, ' +                                      #13#10 +
      '  recordkey, ' +                                         #13#10 +
      '  :ProizvolnyeTransactionKey, ' +                        #13#10 +
      '  documentkey, masterdockey, companykey, accountkey, currkey, accountpart, ' + #13#10 +
      '  creditncu, creditcurr, crediteq, ' +                   #13#10 +
      '  debitncu, debitcurr, debiteq, ' +                      #13#10 +
         FEntryAnalyticsStr + ' ' +                             #13#10 +
      'FROM DBS_TMP_AC_SALDO ';
    q.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    q.ParamByName('ProizvolnyeTransactionKey').AsInteger := ProizvolnyeTransactionKey;

    ExecSqlLogEvent(q, 'CreateAcEntries', Format('ClosingDate = %s, ProizvolnyeTransactionKey = %d', [DateTimeToStr(FClosingDate), ProizvolnyeTransactionKey]));

    Tr.Commit;
  finally
    q.Free;
    Tr.Free; 
  end;
  LogEvent('Create entry balance... OK');
end;

procedure TgsDBSqueeze.CalculateInvSaldo;
var
  q: TIBSQL;
  Tr: TIBTransaction;

  DocumentParentKey: Integer;
  CompanyKey: Integer;  
begin
  LogEvent('Calculating inventory balance...');
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);

  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;

    if FOnlyCompanySaldo then
    begin
      q.SQL.Text :=
        'SELECT contactkey AS CompanyKey ' +            #13#10 +
        'FROM GD_COMPANY ' +                            #13#10 +
        'WHERE fullname = :CompanyName ';
      q.ParamByName('CompanyName').AsString := FCompanyName;
      
      ExecSqlLogEvent(q, 'CalculateInvSaldo', 'CompanyName=' + FCompanyName);
      CompanyKey := q.FieldByName('CompanyKey').AsInteger;
      q.Close;
    end;

    FCardFeaturesStr := '';                                                     ///TODO: отпала необходимость

    // запрос на складские остатки
    q.SQL.Text :=
      'INSERT INTO DBS_TMP_INV_SALDO ' +                        #13#10 +
      'SELECT ' +                                               #13#10 +
      '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' +   #13#10 +// DOCUMENT ID
      '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' +   #13#10 +// MASTERDOCKEY
      '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' +   #13#10 +// ID_CARD
      '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' +   #13#10 +// ID_MOVEMENT_D
      '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' +   #13#10 +// ID_MOVEMENT_C
      '  im.contactkey AS ContactKey, ' +                       #13#10 +
      '  ic.goodkey, ' +                                        #13#10 +
      '  ic.companykey, ' +                                     #13#10 +
      '  SUM(im.debit - im.credit) AS Balance ';
    {if (FCardFeaturesStr <> '') then
      q.SQL.Add(', ' +
        StringReplace(FCardFeaturesStr, 'USR$', 'ic.USR$', [rfReplaceAll, rfIgnoreCase]) + ' '); }
    q.SQL.Add(' ' +                                             #13#10 +
      'FROM inv_movement im ' +                                 #13#10 +
      '  JOIN INV_CARD ic ON im.cardkey = ic.id ' +             #13#10 +
      'WHERE ' +                                                #13#10 +
      '  im.cardkey > 0 '); // первый столбец в индексе, чтобы его задействовать
    if FOnlyCompanySaldo then
      q.SQL.Add(' ' +                                           #13#10 +
        'AND ic.companykey = :CompanyKey ');
    q.SQL.Add(' ' +                                             #13#10 +
      '  AND im.movementdate < :RemainsDate ' +                 #13#10 +
      '  AND im.disabled = 0 ' +                                #13#10 +
      'GROUP BY ' +                                             #13#10 +
      '  im.contactkey, ' +                                     #13#10 +
      '  ic.goodkey, ' +                                        #13#10 +
      '  ic.companykey ');
 {   if (FCardFeaturesStr <> '') then
      q.SQL.Add(', ' +
        StringReplace(FCardFeaturesStr, 'USR$', 'ic.USR$', [rfReplaceAll, rfIgnoreCase]));  }

    q.ParamByName('RemainsDate').AsDateTime := FClosingDate;

    if FOnlyCompanySaldo then
    begin
      q.ParamByName('CompanyKey').AsInteger := CompanyKey;
      ExecSqlLogEvent(q, 'CalculateInvSaldo', 'RemainsDate=' + DateTimeToStr(FClosingDate) + ', CompanyKey=' + IntToStr(CompanyKey));
    end
    else
      ExecSqlLogEvent(q, 'CalculateInvSaldo', 'RemainsDate=' + DateTimeToStr(FClosingDate));

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
  LogEvent('Calculating inventory balance... OK');
end;

procedure TgsDBSqueeze.CreateInvSaldo;
var
  q, q2: TIBSQL;
  Tr: TIBTransaction;
  InvDocTypeKey: Integer;   // ''Произвольный тип'' из gd_documenttype
  PseudoClientKey: Integer; // ''Псевдоклиент'' из gd_contact
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
        'SELECT gd.id AS InvDocTypeKey ' +              #13#10 +
        'FROM GD_DOCUMENTTYPE gd ' +                    #13#10 +
        'WHERE gd.name = ''Произвольный тип'' ';
      ExecSqlLogEvent(q, 'CreateInvSaldo');

      InvDocTypeKey := q.FieldByName('InvDocTypeKey').AsInteger;
      q.Close;

      q.SQL.Text :=
        'SELECT id ' +                                  #13#10 +
        'FROM gd_contact ' +                            #13#10 +
        'WHERE name = ''Псевдоклиент'' ';
      ExecSqlLogEvent(q, 'CreateInvSaldo');

      if q.EOF then // если Псевдоклиента не существует, то создадим
      begin
        q.Close;
        q2.SQL.Text :=
          'SELECT gc.id AS ParentId ' +                 #13#10 +
          'FROM gd_contact gc ' +                       #13#10 +
          'WHERE gc.name = ''Организации'' ';
        ExecSqlLogEvent(q2, 'CreateInvSaldo');

        PseudoClientKey := GetNewID;

        q.SQL.Text :=
          'INSERT INTO GD_CONTACT ( ' +                 #13#10 +
          '  id, ' +                                    #13#10 +
          '  parent, ' +                                #13#10 +
          '  name, ' +                                  #13#10 +
          '  contacttype, ' +                           #13#10 +
          '  afull, ' +                                 #13#10 +
          '  achag, ' +                                 #13#10 +
          '  aview) ' +                                 #13#10 +
          'VALUES (' +                                  #13#10 +
          '  :id, ' +                                   #13#10 +
          '  :parent, ' +                               #13#10 +
          '  ''Псевдоклиент'', ' +                      #13#10 +
          '  3, ' +                                     #13#10 +
          '  -1, ' +                                    #13#10 +
          '  -1, ' +                                    #13#10 +
          '  -1)';
        q.ParamByName('id').AsInteger := PseudoClientKey;
        q.ParamByName('parent').AsInteger := q2.FieldByName('ParentId').AsInteger;

        ExecSqlLogEvent(q, 'CreateInvSaldo', 'id=' + IntToStr(PseudoClientKey) + ', parent=' + q2.FieldByName('ParentId').AsString);
        q2.Close;
        Tr.Commit;
        Tr.StartTransaction;
      end
      else
        PseudoClientKey := q.FieldByName('id').AsInteger;
      q.Close;

      // create parent docs
      q.SQL.Text :=
        'INSERT INTO GD_DOCUMENT (' +                   #13#10 +
        '  id, ' +                                      #13#10 +
        '  documenttypekey, ' +                         #13#10 +
        '  number, '  +                                 #13#10 +
        '  documentdate, ' +                            #13#10 +
        '  companykey, afull, achag, aview, ' +         #13#10 +
        '  creatorkey, editorkey) ' +                   #13#10 +
        'SELECT ' +                                     #13#10 +
        '  id_parentdoc, ' +                            #13#10 +
        '  :InvDocTypeKey, ' +                          #13#10 +
        '  ''1'', ' +                                   #13#10 +
        '  :ClosingDate, ' +                            #13#10 +
        '  companykey, -1, -1, -1, ' +                  #13#10 +
        '  :CurUserContactKey, :CurUserContactKey ' +   #13#10 +
        'FROM DBS_TMP_INV_SALDO ';
      q.ParamByName('InvDocTypeKey').AsInteger := InvDocTypeKey;
      q.ParamByName('ClosingDate').AsDateTime := FClosingDate;
      q.ParamByName('CurUserContactKey').AsInteger := FCurUserContactKey;

      ExecSqlLogEvent(q, 'CreateInvSaldo', 'InvDocTypeKey=' + IntToStr(InvDocTypeKey) + ', ClosingDate=' + DateTimeToStr(FClosingDate) + ', CurUserContactKey=' + IntToStr(FCurUserContactKey));

      Tr.Commit;
      Tr.StartTransaction;

    // Create Position SaldoDoc

      q.SQL.Text :=
        'INSERT INTO GD_DOCUMENT (' +                   #13#10 +
        '  id, ' +                                      #13#10 +
        '  parent, ' +                                  #13#10 +
        '  documenttypekey, ' +                         #13#10 +
        '  number, '  +                                 #13#10 +
        '  documentdate, ' +                            #13#10 +
        '  companykey, afull, achag, aview, ' +         #13#10 +
        '  creatorkey, editorkey) ' +                   #13#10 +
        'SELECT ' +                                     #13#10 +
        '  id_document, ' +                             #13#10 +
        '  id_parentdoc, ' +                            #13#10 +
        '  :InvDocTypeKey, ' +                          #13#10 +
        '  ''1'', ' +                                   #13#10 +
        '  :ClosingDate, ' +                            #13#10 +
        '  companykey, -1, -1, -1, ' +                  #13#10 +
        '  :CurUserContactKey, :CurUserContactKey ' +   #13#10 +
        'FROM DBS_TMP_INV_SALDO ';
      q.ParamByName('InvDocTypeKey').AsInteger := InvDocTypeKey;
      q.ParamByName('ClosingDate').AsDateTime := FClosingDate;
      q.ParamByName('CurUserContactKey').AsInteger := FCurUserContactKey;

      ExecSqlLogEvent(q, 'CreateInvSaldo', 'InvDocTypeKey=' + IntToStr(InvDocTypeKey) + ', ClosingDate=' + DateTimeToStr(FClosingDate) +
        ', CurUserContactKey=' + IntToStr(FCurUserContactKey));

      Tr.Commit;
      Tr.StartTransaction;

      // Создадим новую складскую карточку  

      q.SQL.Text :=                                     #13#10 +
        'INSERT INTO INV_CARD (' +                      #13#10 +
        '  id, ' +                                      #13#10 +
        '  goodkey, ' +                                 #13#10 +
        '  documentkey, firstdocumentkey, ' +           #13#10 +
        '  firstdate, ' +                               #13#10 +
        '  companykey ';
      if (FCardFeaturesStr <> '') then  // поля-признаки
      begin
        if Pos('USR$INV_ADDLINEKEY', FCardFeaturesStr) <> 0 then
        begin
          if Pos('USR$INV_ADDLINEKEY,', FCardFeaturesStr) <> 0 then
            q.SQL.Add(', ' +                            #13#10 +
              StringReplace(FCardFeaturesStr, 'USR$INV_ADDLINEKEY,', ' ', [rfReplaceAll, rfIgnoreCase]) +
              ', USR$INV_ADDLINEKEY ')
          else
            q.SQL.Add(', ' +                            #13#10 +
              FCardFeaturesStr);
        end
        else
          q.SQL.Add(', ' +                              #13#10 +
            FCardFeaturesStr);
      end;
      q.SQL.Add(
        ') ' +                                          #13#10 +
        'SELECT ' +                                     #13#10 +
        '  id_card, ' +                                 #13#10 +
        '  goodkey, ' +                                 #13#10 +
        '  id_document, id_document, ' +                #13#10 +
        '  :ClosingDate, ' +                            #13#10 +
        '  companykey ');
      if (FCardFeaturesStr <> '') then
      begin
        if Pos('USR$INV_ADDLINEKEY', FCardFeaturesStr) <> 0 then  // Заполним поле USR$INV_ADDLINEKEY карточки нового остатка ссылкой на позицию
        begin
          if Pos('USR$INV_ADDLINEKEY,', FCardFeaturesStr) <> 0 then  //не последний в списке - вырежем
            q.SQL.Add(', ' +                            #13#10 +
              StringReplace(FCardFeaturesStr, 'USR$INV_ADDLINEKEY,', ' ', [rfReplaceAll, rfIgnoreCase]) +
              ', id_document ')
          else
            q.SQL.Add(', ' +                            #13#10 +
              StringReplace(FCardFeaturesStr, 'USR$INV_ADDLINEKEY', 'id_document ', [rfReplaceAll, rfIgnoreCase]));
        end
        else
          q.SQL.Add(', ' +                              #13#10 +
            FCardFeaturesStr + ' ');
      end;
      q.SQL.Add(' ' +                                   #13#10 +
        'FROM  DBS_TMP_INV_SALDO ');

      q.ParamByName('ClosingDate').AsDateTime := FClosingDate;
      ExecSqlLogEvent(q, 'CreateInvSaldo', 'ClosingDate=' + DateTimeToStr(FClosingDate));

      Tr.Commit;
      Tr.StartTransaction;
      // Создадим дебетовую часть складского движения

      q.SQL.Text :=
        'INSERT INTO INV_MOVEMENT ( ' +                 #13#10 +
        '  id, goodkey, movementkey, ' +                #13#10 +
        '  movementdate, ' +                            #13#10 +
        '  documentkey, cardkey, ' +                    #13#10 +
        '  debit, ' +                                   #13#10 +
        '  credit, ' +                                  #13#10 +
        '  contactkey) ' +                              #13#10 +                ///id, goodkey test
        'SELECT ' +                                     #13#10 +
        '  id_movement_d, goodkey, id_movement_d, ' +   #13#10 +
        '  :ClosingDate, ' +                            #13#10 +
        '  id_document, id_card, ' +                    #13#10 +
        '  ABS(balance), ' +                            #13#10 +
        '  0, ' +                                       #13#10 +
        '  IIF((balance > 0) OR (balance = 0), ' +      #13#10 +
        '    contactkey, ' +                            #13#10 +
        '    :PseudoClientKey) ' +                      #13#10 +
        'FROM  DBS_TMP_INV_SALDO ';
      q.ParamByName('PseudoClientKey').AsInteger := PseudoClientKey;
      q.ParamByName('ClosingDate').AsDateTime := FClosingDate;

      ExecSqlLogEvent(q, 'CreateInvSaldo', 'PseudoClientKey=' + IntToStr(PseudoClientKey) + ', ClosingDate=' + DateTimeToStr(FClosingDate));

      Tr.Commit;
      Tr.StartTransaction;
      // Создадим кредитовую часть складского движения

      q.SQL.Text :=                                     #13#10 +
        'INSERT INTO INV_MOVEMENT ( ' +                 #13#10 +
        '  id, goodkey, movementkey, ' +                #13#10 +
        '  movementdate, ' +                            #13#10 +
        '  documentkey, cardkey, ' +                    #13#10 +
        '  debit, ' +                                   #13#10 +
        '  credit, ' +                                  #13#10 +
        '  contactkey) ' +                              #13#10 +     ///id, goodkey test
        'SELECT ' +                                     #13#10 +
        '  id_movement_c, goodkey, id_movement_d, ' +   #13#10 +
        '  :ClosingDate, ' +                            #13#10 +
        '  id_document, id_card, ' +                    #13#10 +
        '  0, ' +                                       #13#10 +
        '  ABS(balance), ' +                            #13#10 +
        '  IIF((balance > 0) OR (balance = 0), ' +      #13#10 +
        '    :PseudoClientKey, ' +                      #13#10 +
        '    contactkey) ' +                            #13#10 +
        'FROM  DBS_TMP_INV_SALDO ';
      q.ParamByName('ClosingDate').AsDateTime := FClosingDate;
      q.ParamByName('PseudoClientKey').AsInteger := PseudoClientKey;

      ExecSqlLogEvent(q, 'CreateInvSaldo', 'ClosingDate=' + DateTimeToStr(FClosingDate) + ', PseudoClientKey=' + IntToStr(PseudoClientKey));

      Tr.Commit;

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

procedure TgsDBSqueeze.PrepareRebindInvCards;
const
  CardkeyFieldCount = 2;
  CardkeyFieldNames: array[0..CardkeyFieldCount - 1] of String = ('FROMCARDKEY', 'TOCARDKEY');
var
  I: Integer;
  Tr: TIBTransaction;
  q3, q4, qInsertGdDoc, qInsertInvCard, qInsertInvMovement, qInsertTmpRebind: TIBSQL;

  CurrentCardKey, CurrentFirstDocKey, CurrentFromContactkey, CurrentToContactkey: Integer;
  NewCardKey, FirstDocumentKey: Integer;
  FirstDate: TDateTime;
  CurrentRelationName: String;
  DocumentParentKey: Integer;

  CardFeaturesList: TStringList;
  NewDocumentKey, NewMovementKey: Integer;
  InvDocTypeKey: Integer;
begin
  LogEvent('[test] PrepareRebindInvCards...');

  CardFeaturesList := TStringList.Create;

  NewCardKey := -1;

  Tr := TIBTransaction.Create(nil);
  q3 := TIBSQL.Create(nil);
  q4 := TIBSQL.Create(nil);
  qInsertTmpRebind := TIBSQL.Create(nil);
  qInsertGdDoc := TIBSQL.Create(nil);
  qInsertInvCard := TIBSQL.Create(nil);
  qInsertInvMovement := TIBSQL.Create(nil);

  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q3.Transaction := Tr;
    q4.Transaction := Tr;
    qInsertGdDoc.Transaction := Tr;
    qInsertInvCard.Transaction := Tr;
    qInsertInvMovement.Transaction := Tr;
    qInsertTmpRebind.Transaction := Tr;

    CardFeaturesList.Text := StringReplace(FCardFeaturesStr, ',', #13#10, [rfReplaceAll, rfIgnoreCase]); 

    q3.SQL.Text :=
      'SELECT gd.id AS InvDocTypeKey ' +                        #13#10 +
      'FROM gd_documenttype gd ' +                              #13#10 +
      'WHERE gd.name = ''Произвольный тип'' ';
    ExecSqlLogEvent(q3, 'PrepareRebindInvCards');

    InvDocTypeKey := q3.FieldByName('InvDocTypeKey').AsInteger;
    q3.Close;

    qInsertTmpRebind.SQL.Text := 
      'INSERT INTO DBS_TMP_REBIND_INV_CARDS ' +                 #13#10 +
      '  (cur_cardkey, new_cardkey, cur_first_dockey, first_dockey, first_date, cur_relation_name) ' + #13#10 +
      'VALUES (:CurrentCardKey, :NewCardKey, :CurrentFirstDocKey, :FirstDocumentKey, :FirstDate, :CurrentRelationName) ';
    qInsertTmpRebind.Prepare;

    qInsertGdDoc.SQL.Text :=
      'INSERT INTO GD_DOCUMENT ' +                              #13#10 +
      '  (id, parent, documenttypekey, number, documentdate, companykey, afull, achag, aview, ' + #13#10 +
      'creatorkey, editorkey) ' +                               #13#10 +
      'VALUES ' +                                               #13#10 +
      '  (:id, :parent, :documenttypekey, ''1'', :documentdate, :companykey, -1, -1, -1, ' + #13#10 + ///TODO: NUMBER doc
      ':userkey, :userkey) ';
    qInsertGdDoc.ParamByName('DOCUMENTDATE').AsDateTime := FClosingDate;
    qInsertGdDoc.Prepare;

    qInsertInvCard.SQL.Text :=
      'INSERT INTO INV_CARD ' +                                 #13#10 +
      '  (id, goodkey, documentkey, firstdocumentkey, firstdate, companykey';
    // Поля-признаки
    if FCardFeaturesStr <> '' then
      qInsertInvCard.SQL.Add(', ' +                             #13#10 +
        FCardFeaturesStr);
    qInsertInvCard.SQL.Add(' ' +                                #13#10 +
      ') VALUES ' +                                             #13#10 +
      '  (:id, :goodkey, :documentkey, :documentkey, :firstdate, :companykey');
    // Поля-признаки
    if FCardFeaturesStr <> '' then
      qInsertInvCard.SQL.Add(', ' +                             #13#10 +
        StringReplace(FCardFeaturesStr, 'USR$', ':USR$', [rfReplaceAll, rfIgnoreCase]));
    qInsertInvCard.SQL.Add(
      ')');

    qInsertInvCard.ParamByName('FIRSTDATE').AsDateTime := FClosingDate;                       ///
    qInsertInvCard.Prepare;

    qInsertInvMovement.SQL.Text :=
      'INSERT INTO INV_MOVEMENT ' +                             #13#10 +
      '  (id, goodkey, movementkey, movementdate, documentkey, contactkey, cardkey, debit, credit) ' + #13#10 +      ///id, goodkey test
      'VALUES ' +                                               #13#10 +
      '  (:id, :goodkey, :movementkey, :movementdate, :documentkey, :contactkey, :cardkey, :debit, :credit) ';
    qInsertInvMovement.ParamByName('MOVEMENTDATE').AsDateTime := FClosingDate;                ///
    qInsertInvMovement.Prepare;

    // выбираем все карточки, которые находятся в движении во время закрытия
    q3.SQL.Text :=
      'SELECT' +                                                #13#10 +
      '  m1.contactkey AS FromConactKey, ' +                    #13#10 +
      '  m.contactkey AS ToContactKey, ' +                      #13#10 +
      '  linerel.relationname, ' +                              #13#10 +
      '  c.id AS CardkeyNew, ' +                                #13#10 +
      '  c1.id AS CardkeyOld,' +                                #13#10 +
      '  c.goodkey,' +                                          #13#10 +
      '  c.companykey, ' +                                      #13#10 +
      '  c.firstdocumentkey';
    if FCardFeaturesStr <> '' then
      q3.SQL.Add(', ' +                                         #13#10 +
        StringReplace(FCardFeaturesStr, 'USR$', 'c.USR$', [rfReplaceAll, rfIgnoreCase]) + ' ');                                                                       /// c.
    q3.SQL.Add(' ' +                                            #13#10 +
      'FROM gd_document d ' +                                   #13#10 +
      '  JOIN GD_DOCUMENTTYPE t ' +                             #13#10 +
      '    ON t.id = d.documenttypekey ' +                      #13#10 +
      '  LEFT JOIN INV_MOVEMENT m ' +                           #13#10 +
      '    ON m.documentkey = d.id ' +                          #13#10 +
      '  LEFT JOIN INV_MOVEMENT m1 ' +                          #13#10 +
      '    ON m1.movementkey = m.movementkey AND m1.id <> m.id ' + #13#10 +
      '  LEFT JOIN INV_CARD c ' +                               #13#10 +
      '    ON c.id = m.cardkey ' +                              #13#10 +
      '  LEFT JOIN INV_CARD c1 ' +                              #13#10 +
      '    ON c1.id = m1.cardkey ' +                            #13#10 +
      '  LEFT JOIN GD_DOCUMENT d_old ' +                        #13#10 +
      '    ON ((d_old.id = c.documentkey) OR (d_old.id = c1.documentkey)) ' + #13#10 +
      '  LEFT JOIN AT_RELATIONS linerel ' +                     #13#10 +
      '    ON linerel.id = t.linerelkey ' +                     #13#10 +
      'WHERE ' +                                                #13#10 +
      '  d.documentdate >= :ClosingDate ' +                     #13#10 +
      '  AND t.classname = ''TgdcInvDocumentType'' ' +          #13#10 + ///TODO: перепроверить мб Произвольный
      '  AND t.documenttype = ''D'' ' +                         #13#10 +
      '  AND d_old.documentdate < :ClosingDate ');
    q3.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    ExecSqlLogEvent(q3, 'PrepareRebindInvCards', 'ClosingDate=' + DateTimeToStr(FClosingDate));

    FirstDocumentKey := -1;
    FirstDate := FClosingDate;                                 /// TODO: уточнить FirstDate
    while not q3.EOF do
    begin
      if q3.FieldByName('CardkeyOld').IsNull then                      /////=>m1 не сущ=> FromConactKey=0 TODO: уточнить
        CurrentCardKey := q3.FieldByName('CardkeyNew').AsInteger
      else
        CurrentCardKey := q3.FieldByName('CardkeyOld').AsInteger;
      CurrentFirstDocKey := q3.FieldByName('firstdocumentkey').AsInteger;
      CurrentFromContactkey := q3.FieldByName('FromConactKey').AsInteger;
      CurrentToContactkey := q3.FieldByName('ToContactKey').AsInteger;
      CurrentRelationName := q3.FieldByName('relationname').AsString;

      if (CurrentFromContactkey > 0) and (CurrentToContactkey > 0) then         ///!TODO: БЫЛО OR. уточнить что делать при CurrentFromContactkey = 0
      begin
        // ищем подходящую карточку в документе остатков для замены удаляемой
        q4.SQL.Text :=
          'SELECT FIRST(1) ' +                                    #13#10 +
          '  c.id AS cardkey, ' +                                 #13#10 +
          '  c.firstdocumentkey, ' +                              #13#10 +
          '  c.firstdate ' +                                      #13#10 +
          'FROM gd_document d ' +                                 #13#10 +
          '  LEFT JOIN INV_MOVEMENT m ' +                         #13#10 +
          '    ON m.documentkey = d.id ' +                        #13#10 +
          '  LEFT JOIN INV_CARD c ' +                             #13#10 +
          '    ON c.id = m.cardkey ' +                            #13#10 +
          'WHERE ' +                                              #13#10 +
          '  d.documenttypekey = :DocTypeKey ' +                  #13#10 +
          '  AND d.documentdate = :ClosingDate ' +                #13#10 +
          '  AND c.goodkey = :GoodKey ' +                         #13#10 +
          '  AND ' +                                              #13#10 +
          '    ((m.contactkey = :contact1) ' +                    #13#10 +
          '    OR (m.contactkey = :contact2)) ';
        for I := 0 to CardFeaturesList.Count - 1 do  
        begin
          if not q4.FieldByName(Trim(CardFeaturesList[I])).IsNull then
            q4.SQL.Add(' ' +                                      #13#10 +
              Format(
            'AND c.%0:s = :%0:s ', [Trim(CardFeaturesList[I])]))
          else
            q4.SQL.Add(' ' +                                      #13#10 +
              Format(
            'AND c.%0:s IS NULL ', [Trim(CardFeaturesList[I])]) + ' ');
        end;   

        q4.ParamByName('DocTypeKey').AsInteger := InvDocTypeKey;
        q4.ParamByName('ClosingDate').AsDateTime := FClosingDate;
        q4.ParamByName('GoodKey').AsInteger := q3.FieldByName('goodkey').AsInteger;
        q4.ParamByName('CONTACT1').AsInteger := CurrentFromContactkey;
        q4.ParamByName('CONTACT2').AsInteger := CurrentToContactkey;
        for I := 0 to CardFeaturesList.Count - 1 do
        begin
          if not q3.FieldByName(Trim(CardFeaturesList[I])).IsNull then
            q4.ParamByName(Trim(CardFeaturesList[I])).AsVariant := q3.FieldByName(Trim(CardFeaturesList[I])).AsVariant;
        end;       

        ExecSqlLogEvent(q4, 'PrepareRebindInvCards', 'DocTypeKey=' + IntToStr(InvDocTypeKey) + ', ClosingDate=' + DateTimeToStr(FClosingDate) +
          ', GoodKey=' + q3.FieldByName('goodkey').AsString +  ', CONTACT1=' + IntToStr(CurrentFromContactkey) + ', CONTACT2=' + IntToStr(CurrentToContactkey));

        // если нашли подходящую карточку, созданную документом остатков
        if q4.RecordCount > 0 then
        begin
          NewCardKey := q4.FieldByName('CardKey').AsInteger;
          FirstDocumentKey := q4.FieldByName('FirstDocumentKey').AsInteger;
          FirstDate := q4.FieldByName('FirstDate').AsDateTime;
        end
        else begin
          // ищем карточку без доп. признаков
          q4.Close;
          q4.SQL.Text :=                                                        // TODO: вынести. Prepare
            'SELECT FIRST(1) ' +                                        #13#10 +
            '  c.id AS cardkey, ' +                                     #13#10 +
            '  c.firstdocumentkey, ' +                                  #13#10 +
            '  c.firstdate ' +                                          #13#10 +
            'FROM gd_document d ' +                                     #13#10 +
            '  LEFT JOIN INV_MOVEMENT m ' +                             #13#10 +
            '    ON m.documentkey = d.id ' +                            #13#10 +
            '  LEFT JOIN INV_CARD c ' +                                 #13#10 +
            '    ON c.id = m.cardkey ' +                                #13#10 +
            'WHERE ' +                                                  #13#10 +
            '  d.documenttypekey = :DocTypeKey ' +                      #13#10 +
            '  AND d.documentdate = :ClosingDate ' +                    #13#10 +
            '  AND c.goodkey = :GoodKey ' +                             #13#10 +
            '  AND ' +                                                  #13#10 +
            '    ((m.contactkey = :contact1) ' +                        #13#10 +
            '    OR (m.contactkey = :contact2)) ';

          q4.ParamByName('DocTypeKey').AsInteger := InvDocTypeKey;
          q4.ParamByName('ClosingDate').AsDateTime := FClosingDate;
          q4.ParamByName('GoodKey').AsInteger := q3.FieldByName('goodkey').AsInteger;
          q4.ParamByName('CONTACT1').AsInteger := CurrentFromContactkey;
          q4.ParamByName('CONTACT2').AsInteger := CurrentToContactkey;
          
          ExecSqlLogEvent(q4, 'PrepareRebindInvCards', 'DocTypeKey=' + IntToStr(InvDocTypeKey) + ', ClosingDate=' + DateTimeToStr(FClosingDate) +
            ', GoodKey=' + q3.FieldByName('goodkey').AsString + ', CONTACT1=' + IntToStr(CurrentFromContactkey) + ', CONTACT2=' + IntToStr(CurrentToContactkey));

          if q4.RecordCount > 0 then
          begin
            NewCardKey := q4.FieldByName('CardKey').AsInteger;
            FirstDocumentKey := q4.FieldByName('FirstDocumentKey').AsInteger;
            FirstDate := q4.FieldByName('FirstDate').AsDateTime;
          end
          else begin // Иначе вставим документ нулевого прихода, перепривязывать будем потом на созданную им карточку

            DocumentParentKey := GetNewID;
            qInsertGdDoc.ParamByName('ID').AsInteger :=  DocumentParentKey;
            qInsertGdDoc.ParamByName('PARENT').Clear;
            qInsertGdDoc.ParamByName('DOCUMENTTYPEKEY').AsInteger := InvDocTypeKey;
            qInsertGdDoc.ParamByName('COMPANYKEY').AsInteger := q3.FieldByName('COMPANYKEY').AsInteger;
            qInsertGdDoc.ParamByName('USERKEY').AsInteger := FCurUserContactKey;
            
            ExecSqlLogEvent(qInsertGdDoc, 'PrepareRebindInvCards', 'ID=' + IntToStr(DocumentParentKey) + ', PARENT=NULL, DOCUMENTTYPEKEY=' + IntToStr(InvDocTypeKey) +
              ', COMPANYKEY=' + q3.FieldByName('COMPANYKEY').AsString + ', USERKEY=' + IntToStr(FCurUserContactKey));
/////////////
            NewDocumentKey := GetNewID;

            qInsertGdDoc.ParamByName('ID').AsInteger := NewDocumentKey;
            qInsertGdDoc.ParamByName('DOCUMENTTYPEKEY').AsInteger := InvDocTypeKey;
            qInsertGdDoc.ParamByName('PARENT').AsInteger := DocumentParentKey;
            qInsertGdDoc.ParamByName('COMPANYKEY').AsInteger := q3.FieldByName('companykey').AsInteger;
            qInsertGdDoc.ParamByName('USERKEY').AsInteger := FCurUserContactKey;
            //qInsertGdDoc.ExecQuery;
            ExecSqlLogEvent(qInsertGdDoc, 'PrepareRebindInvCards', 'ID=' + IntToStr(NewDocumentKey) + ', PARENT=' + IntToStr(DocumentParentKey) + ', DOCUMENTTYPEKEY=' + IntToStr(InvDocTypeKey) +
              ', COMPANYKEY=' + q3.FieldByName('COMPANYKEY').AsString + ', USERKEY=' + IntToStr(FCurUserContactKey));

            NewCardKey := GetNewID;
        
            // Создадим новую складскую карточку

            qInsertInvCard.ParamByName('ID').AsInteger := NewCardKey;
            qInsertInvCard.ParamByName('GOODKEY').AsInteger := q3.FieldByName('goodkey').AsInteger;
            qInsertInvCard.ParamByName('DOCUMENTKEY').AsInteger := NewDocumentKey;
            qInsertInvCard.ParamByName('COMPANYKEY').AsInteger := q3.FieldByName('companykey').AsInteger;

            for I := 0 to CardFeaturesList.Count - 1 do
            begin
              if Trim(CardFeaturesList[I]) <> 'USR$INV_ADDLINEKEY' then
                qInsertInvCard.ParamByName(Trim(CardFeaturesList[I])).Clear
              else // Заполним поле USR$INV_ADDLINEKEY карточки нового остатка ссылкой на позицию
                qInsertInvCard.ParamByName('USR$INV_ADDLINEKEY').AsInteger := NewDocumentKey;
            end;

            ExecSqlLogEvent(qInsertInvCard, 'PrepareRebindInvCards', 'ID=' + IntToStr(NewCardKey) + ', GOODKEY=' + q3.FieldByName('goodkey').AsString +
                  ', DOCUMENTKEY=' + IntToStr(NewDocumentKey) + ', COMPANYKEY=' + q3.FieldByName('companykey').AsString + ' ...');
            
            NewMovementKey := GetNewID;

            // Создадим дебетовую часть складского движения                                                 /////////// ERROR! CONTACTKEY=0
            qInsertInvMovement.ParamByName('ID').AsInteger := GetNewID;
            qInsertInvMovement.ParamByName('GOODKEY').AsInteger := q3.FieldByName('goodkey').AsInteger;
            qInsertInvMovement.ParamByName('MOVEMENTKEY').AsInteger := NewMovementKey;
            qInsertInvMovement.ParamByName('DOCUMENTKEY').AsInteger := NewDocumentKey;
            qInsertInvMovement.ParamByName('CONTACTKEY').AsInteger := CurrentFromContactkey; /// мб ТоСonact?
            qInsertInvMovement.ParamByName('CARDKEY').AsInteger := NewCardKey;
            qInsertInvMovement.ParamByName('DEBIT').AsCurrency := 0;
            qInsertInvMovement.ParamByName('CREDIT').AsCurrency := 0;
        
            ExecSqlLogEvent(qInsertInvMovement, 'PrepareRebindInvCards', 'ID=GetNewID(), GOODKEY=' + q3.FieldByName('goodkey').AsString + ', MOVEMENTKEY=' + IntToStr(NewMovementKey) +
              ', DOCUMENTKEY=' + IntToStr(NewDocumentKey) + ', CONTACTKEY=' + IntToStr(CurrentFromContactkey) + ', CARDKEY=' + IntToStr(NewCardKey) + ', DEBIT=0, CREDIT=0');

            // Создадим кредитовую часть складского движения
            qInsertInvMovement.ParamByName('ID').AsInteger := GetNewID;
            qInsertInvMovement.ParamByName('GOODKEY').AsInteger := q3.FieldByName('goodkey').AsInteger;
            qInsertInvMovement.ParamByName('MOVEMENTKEY').AsInteger := NewMovementKey;
            qInsertInvMovement.ParamByName('DOCUMENTKEY').AsInteger := NewDocumentKey;
            qInsertInvMovement.ParamByName('CONTACTKEY').AsInteger := CurrentFromContactkey;
            qInsertInvMovement.ParamByName('CARDKEY').AsInteger := NewCardKey;
            qInsertInvMovement.ParamByName('DEBIT').AsCurrency := 0;
            qInsertInvMovement.ParamByName('CREDIT').AsCurrency := 0;

            ExecSqlLogEvent(qInsertInvMovement, 'PrepareRebindInvCards', 'ID=GetNewID(), GOODKEY=' + q3.FieldByName('goodkey').AsString + ', MOVEMENTKEY=' + IntToStr(NewMovementKey) +
              ', DOCUMENTKEY=' + IntToStr(NewDocumentKey) + ', CONTACTKEY=' + IntToStr(CurrentFromContactkey) + ', CARDKEY=' + IntToStr(NewCardKey) + ', DEBIT=0, CREDIT=0');
////////////////////
          end;
        end;
        q4.Close;
      end
      else begin
        // ищем подходящую карточку для замены удаляемой
        q4.SQL.Text :=
          'SELECT FIRST(1) ' +                                          #13#10 +
          '  c.id AS cardkey, ' +                                       #13#10 +
          '  c.firstdocumentkey, ' +                                    #13#10 +
          '  c.firstdate ' +                                            #13#10 +
          'FROM gd_document d ' +                                       #13#10 +
          '  LEFT JOIN INV_MOVEMENT m ' +                               #13#10 +
          '    ON m.documentkey = d.id ' +                              #13#10 +
          '  LEFT JOIN INV_CARD c ' +                                   #13#10 +
          '    ON c.id = m.cardkey ' +                                  #13#10 +
          'WHERE ' +                                                    #13#10 +
          '  d.documenttypekey = :DocTypeKey ' +                        #13#10 +
          '  AND d.documentdate = :ClosingDate ' +                      #13#10 +
          '  AND c.goodkey = :GoodKey ';
        for I := 0 to CardFeaturesList.Count - 1 do
        begin
          if not q3.FieldByName(Trim(CardFeaturesList[I])).IsNull then
            q4.SQL.Add(' ' +                                            #13#10 +
              Format(
            'AND c.%0:s = :%0:s ', [Trim(CardFeaturesList[I])]))
          else
            q4.SQL.Add(' ' +                                            #13#10 +
              Format(
            'AND c.%0:s IS NULL ', [Trim(CardFeaturesList[I])]));
        end;  

        q4.ParamByName('ClosingDate').AsDateTime := FClosingDate;
        q4.ParamByName('DocTypeKey').AsInteger := InvDocTypeKey;
        q4.ParamByName('GoodKey').AsInteger := q3.FieldByName('GOODKEY').AsInteger;
        for I := 0 to CardFeaturesList.Count - 1 do
        begin
          if not q3.FieldByName(Trim(CardFeaturesList[I])).IsNull then
            q4.ParamByName(Trim(CardFeaturesList[I])).AsVariant := q3.FieldByName(Trim(CardFeaturesList[I])).AsVariant;
        end;   

        ExecSqlLogEvent(q4, 'PrepareRebindInvCards', 'ClosingDate=' + DateTimeToStr(FClosingDate) + ', DocTypeKey=' + IntToStr(InvDocTypeKey) + ', GoodKey=' + q3.FieldByName('GOODKEY').AsString);

        if q4.RecordCount > 0 then
          NewCardKey := q4.FieldByName('CardKey').AsInteger
        else
          NewCardKey := -1;

        q4.Close;
      end;

      qInsertTmpRebind.ParamByName('CurrentCardKey').AsInteger := CurrentCardKey;
      qInsertTmpRebind.ParamByName('NewCardKey').AsInteger := NewCardKey;
      qInsertTmpRebind.ParamByName('CurrentFirstDocKey').AsInteger := CurrentFirstDocKey;
      qInsertTmpRebind.ParamByName('FirstDocumentKey').AsInteger := FirstDocumentKey;
      qInsertTmpRebind.ParamByName('FirstDate').AsDateTime := FirstDate; ////
      qInsertTmpRebind.ParamByName('CurrentRelationName').AsString := CurrentRelationName;

      ExecSqlLogEvent(qInsertTmpRebind, 'PrepareRebindInvCards', 'CurrentCardKey=' + IntToStr(CurrentCardKey) + ', NewCardKey=' + IntToStr(NewCardKey) + ', CurrentFirstDocKey=' + IntToStr(CurrentFirstDocKey) +
        ', FirstDocumentKey=' + IntToStr(FirstDocumentKey) + ', FirstDate=' + DateTimeToStr(FirstDocumentKey) + ', CurrentRelationName=' + CurrentRelationName);

      q3.Next;
    end;
    q3.Close;
    Tr.Commit;
    Tr.StartTransaction;

    //---------------- сохранение в HIS(0) PK тех записей, которые позже будут перепривязываться. чтобы игнорировать при удалении те их FK, которые будут потом заменены.
    CreateHIS(0);

    q3.SQL.Text :=                                      #13#10 +
      'SELECT ' +                                       #13#10 +
      '  g_his_include(0, c.id) ' +                     #13#10 +
      'FROM ' +                                         #13#10 +
      '  inv_card c ' +                                 #13#10 +
      '  JOIN DBS_TMP_REBIND_INV_CARDS tmp ' +          #13#10 +
      '    ON tmp.cur_first_dockey = c.firstdocumentkey ';
    ExecSqlLogEvent(q3, 'PrepareRebindInvCards');

    q3.Close;
    q3.SQL.Text :=
      'SELECT ' +                                       #13#10 +
      '  g_his_include(0, c.id) ' +                     #13#10 +
      'FROM ' +                                         #13#10 +
      '  inv_card c ' +                                 #13#10 +
      '  JOIN DBS_TMP_REBIND_INV_CARDS tmp ' +          #13#10 +
      '    ON tmp.cur_cardkey = c.parent ' +            #13#10 +
      'WHERE ' +                                        #13#10 +
      '  ( SELECT FIRST(1) m.movementdate ' +           #13#10 +
      '	   FROM inv_movement m ' +                      #13#10 +
      '	   WHERE m.cardkey = c.id ' +                   #13#10 +
      '	   ORDER BY m.movementdate DESC ' +             #13#10 +
      '  ) >= :CloseDate ';
    q3.ParamByName('CloseDate').AsDateTime := FClosingDate;
    ExecSqlLogEvent(q3, 'PrepareRebindInvCards', 'CloseDate=' + DateTimeToStr(FClosingDate));

    q3.Close;
    q3.SQL.Text :=
      'SELECT ' +                                       #13#10 +
      '  g_his_include(0, m.id) ' +                     #13#10 +
      'FROM ' +                                         #13#10 +
      '  inv_movement m ' +                             #13#10 +
      '  JOIN DBS_TMP_REBIND_INV_CARDS tmp ' +          #13#10 +
      '    ON tmp.cur_cardkey = m.cardkey ' +           #13#10 +
      'WHERE ' +                                        #13#10 +
      '  m.movementdate >= :CloseDate ';
    q3.ParamByName('CloseDate').AsDateTime := FClosingDate;
    ExecSqlLogEvent(q3, 'PrepareRebindInvCards', 'CloseDate=' + DateTimeToStr(FClosingDate));

    FIgnoreTbls.Add('INV_CARD=PARENT');

    FIgnoreTbls.Add('INV_CARD=FIRSTDOCUMENTKEY');

    FIgnoreTbls.Add('INV_MOVEMENT=CARDKEY');

    q3.Close;
    q3.SQL.Text :=
      'SELECT DISTINCT ' +                                      #13#10 +
      '  r.cur_relation_name AS RelationName, ' +               #13#10 +
      '  s.list_fields       AS PkField, ' +                    #13#10 +
      '  rf.rdb$field_name   AS FkField ' +                     #13#10 +
      'FROM dbs_tmp_rebind_inv_cards r ' +                      #13#10 +
      '  JOIN DBS_SUITABLE_TABLES s ' +                         #13#10 +
      '    ON s.relation_name = r.cur_relation_name ' +         #13#10 +
      '  JOIN RDB$RELATION_FIELDS rf ' +                        #13#10 +
      '    ON rf.rdb$relation_name = r.cur_relation_name ' +    #13#10 +
      'WHERE ' +                                                #13#10 +
      '  rf.rdb$field_name IN(''FROMCARDKEY'', ''TOCARDKEY'') ';
    ExecSqlLogEvent(q3, 'PrepareRebindInvCards');

    while not q3.Eof do
    begin
      FIgnoreTbls.Add(UpperCase(Trim(q3.FieldByName('RelationName').AsString)) + '=' + UpperCase(Trim(q3.FieldByName('FkField').AsString)));

      q4.SQL.Text := Format(
        'SELECT ' +                                             #13#10 +
        '  g_his_include(0, line.%0:s) ' +                      #13#10 +
        'FROM ' +                                               #13#10 +
        '  %1:s line ' +                                        #13#10 +
        '  JOIN DBS_TMP_REBIND_INV_CARDS tmp ' +                #13#10 +
        '    ON tmp.cur_cardkey = line.%2:s ' +                 #13#10 +
        'WHERE ' +                                              #13#10 +
        '  (SELECT doc.documentdate  ' +                        #13#10 +
        '   FROM gd_document doc ' +                            #13#10 +
        '   WHERE doc.id = line.documentkey ' +                 #13#10 +
        '  ) >= :ClosingDate ',
        [Trim(q3.FieldByName('PkField').AsString), Trim(q3.FieldByName('RelationName').AsString), Trim(q3.FieldByName('FkField').AsString)]);

      q4.ParamByName('ClosingDate').AsDateTime := FClosingDate;
      ExecSqlLogEvent(q4, 'PrepareRebindInvCards', 'ClosingDate=' + DateTimeToStr(FClosingDate));
      q4.Close;

      q3.Next;
    end;
    q3.Close;
 
    // FK, которые НЕ надо восстанавливать перед перепривязкой, так как там возможны ссылки на уже удаленные записи.
    // Восстановим эти FK ПОСЛЕ перепривязки
    LogEvent('[test] FIgnoreTbls: ' + FIgnoreTbls.Text);
    for I:=0 to FIgnoreTbls.Count-1 do
    begin
      q3.SQL.Text :=
        'INSERT INTO DBS_TMP_FK_CONSTRAINTS ( ' +                       #13#10 +
        '  relation_name, ' +                                           #13#10 +
        '  ref_relation_name, ' +                                       #13#10 +
        '  constraint_name, ' +                                         #13#10 +
        '  list_fields, list_ref_fields, update_rule, delete_rule) ' +  #13#10 +
        'SELECT ' +                                                     #13#10 +
        '  relation_name, ' +                                           #13#10 +
        '  ref_relation_name, ' +                                       #13#10 +
        '  constraint_name, ' +                                         #13#10 +
        '  list_fields, list_ref_fields, update_rule, delete_rule ' +   #13#10 +
        'FROM  ' +                                                      #13#10 +
        '  dbs_fk_constraints  ' +                                      #13#10 +
        'WHERE  ' +                                                     #13#10 +
        '  relation_name = :RN ' +                                      #13#10 +
        '  AND list_fields = :FN ';
      q3.ParamByName('RN').AsString := Copy(FIgnoreTbls[I], 0, Pos('=', FIgnoreTbls[I]) - 1);
      q3.ParamByName('FN').AsString := Copy(FIgnoreTbls[I], Pos('=', FIgnoreTbls[I]) + 1, Length(FIgnoreTbls[I]));

      ExecSqlLogEvent(q3, 'PrepareRebindInvCards', 'RN=' + Copy(FIgnoreTbls[I], 0, Pos('=', FIgnoreTbls[I]) - 1) +
        ', FN=' + Copy(FIgnoreTbls[I], Pos('=', FIgnoreTbls[I]) + 1, Length(FIgnoreTbls[I])));
    end;

    Tr.Commit;

    LogEvent('[test] PrepareRebindInvCards... OK');
  finally
    q3.Free;
    q4.Free;
    qInsertGdDoc.Free;
    qInsertInvCard.Free;
    qInsertInvMovement.Free;
    qInsertTmpRebind.Free;
    Tr.Free;
    CardFeaturesList.Free;
  end;
end;


procedure TgsDBSqueeze.RebindInvCards;
const
  CardkeyFieldCount = 2;
  CardkeyFieldNames: array[0..CardkeyFieldCount - 1] of String = ('FROMCARDKEY', 'TOCARDKEY');
var
  I: Integer;
  Tr: TIBTransaction;
  q3, q4: TIBSQL;
  qUpdateCard: TIBSQL;
  qUpdateFirstDocKey: TIBSQL;
  qUpdateInvMovement: TIBSQL;

begin
  LogEvent('Rebinding cards...');

  Tr := TIBTransaction.Create(nil);
  q3 := TIBSQL.Create(nil);
  q4 := TIBSQL.Create(nil);
  qUpdateCard := TIBSQL.Create(nil);
  qUpdateFirstDocKey := TIBSQL.Create(nil);
  qUpdateInvMovement := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q3.Transaction := Tr;
    q4.Transaction := Tr;
    qUpdateCard.Transaction := Tr;
    qUpdateFirstDocKey.Transaction := Tr;
    qUpdateInvMovement.Transaction := Tr;

    // обновляет ссылку на родительскую карточку
    qUpdateCard.SQL.Text :=
      'UPDATE ' +                                       #13#10 +
      '  inv_card c ' +                                 #13#10 +
      'SET ' +                                          #13#10 +
      '  c.parent = :NewParent ' +                      #13#10 +
      'WHERE ' +                                        #13#10 +
      '  c.parent = :OldParent ' +                      #13#10 +
      '  AND (' +                                       #13#10 +
      '    SELECT FIRST(1) m.movementdate ' +           #13#10 +
      '    FROM inv_movement m ' +                      #13#10 +
      '    WHERE m.cardkey = c.id ' +                   #13#10 +
      '    ORDER BY m.movementdate DESC' +              #13#10 +
      '  ) >= :CloseDate ';
    qUpdateCard.ParamByName('CloseDate').AsDateTime := FClosingDate;
    qUpdateCard.Prepare;

    // oбновляет ссылку на документ прихода и дату прихода
    qUpdateFirstDocKey.SQL.Text :=
      'UPDATE ' +                                       #13#10 +
      '  inv_card c ' +                                 #13#10 +
      'SET ' +                                          #13#10 +
      '  c.firstdocumentkey = :NewDockey ' +            #13#10 +
  //    '  c.firstdate = :NewDate ' +                             {TODO: убрать}
      'WHERE ' +                                        #13#10 +
      '  c.firstdocumentkey = :OldDockey ';
    qUpdateFirstDocKey.Prepare;

    // обновляет в движении ссылки на складские карточки
    qUpdateInvMovement.SQL.Text :=
      'UPDATE ' +                                       #13#10 +
      '  inv_movement m ' +                             #13#10 +
      'SET ' +                                          #13#10 +
      '  m.cardkey = :NewCardkey ' +                    #13#10 +
      'WHERE ' +                                        #13#10 +
      '  m.cardkey = :OldCardkey ' +                    #13#10 +
      '  AND m.movementdate >= :CloseDate ';
    qUpdateInvMovement.ParamByName('CloseDate').AsDateTime := FClosingDate;
    qUpdateInvMovement.Prepare;


    q3.SQL.Text :=
      'SELECT ' +                                       #13#10 +
      '  CUR_CARDKEY       AS CurrentCardKey, ' +       #13#10 +
      '  NEW_CARDKEY       AS NewCardKey, ' +           #13#10 +
      '  CUR_FIRST_DOCKEY  AS CurrentFirstDocKey, ' +   #13#10 +
      '  FIRST_DOCKEY      AS FirstDocumentKey, ' +     #13#10 +
      '  FIRST_DATE        AS FirstDate, ' +            #13#10 +
      '  CUR_RELATION_NAME AS CurrentRelationName ' +   #13#10 +
      'FROM ' +                                         #13#10 +
      '  dbs_tmp_rebind_inv_cards ';
    ExecSqlLogEvent(q3, 'RebindInvCards');

    while not q3.EOF do
    begin
      if q3.FieldByName('NewCardKey').AsInteger > 0 then
      begin
        // обновление ссылок на родительскую карточку
        qUpdateCard.ParamByName('OldParent').AsInteger :=  q3.FieldByName('CurrentCardKey').AsInteger;
        qUpdateCard.ParamByName('NewParent').AsInteger := q3.FieldByName('NewCardKey').AsInteger;
      
        ExecSqlLogEvent(qUpdateCard, 'RebindInvCards', 'OldParent=' + q3.FieldByName('CurrentCardKey').AsString + ', NewParent=' + q3.FieldByName('NewCardKey').AsString);
        qUpdateCard.Close;

        // обновление ссылок на документ прихода и дату прихода
        if q3.FieldByName('FirstDocumentKey').AsInteger > -1 then
        begin
          qUpdateFirstDocKey.ParamByName('OldDockey').AsInteger := q3.FieldByName('CurrentFirstDocKey').AsInteger;
          qUpdateFirstDocKey.ParamByName('NewDockey').AsInteger := q3.FieldByName('FirstDocumentKey').AsInteger;
          ///qUpdateFirstDocKey.ParamByName('NewDate').AsDateTime := q3.FieldByName('FirstDate').AsDateTime;
      
          ExecSqlLogEvent(qUpdateFirstDocKey, 'RebindInvCards', 'OldDockey=' + q3.FieldByName('CurrentFirstDocKey').AsString + ', NewDockey=' + q3.FieldByName('FirstDocumentKey').AsString); ///+', NewDate=' + q3.FieldByName('FirstDate').AsString);
          qUpdateFirstDocKey.Close;
        end;

        // обновление ссылок на карточки из движения
        qUpdateInvMovement.ParamByName('OldCardkey').AsInteger := q3.FieldByName('CurrentCardKey').AsInteger;
        qUpdateInvMovement.ParamByName('NewCardkey').AsInteger := q3.FieldByName('NewCardKey').AsInteger;
        
        ExecSqlLogEvent(qUpdateInvMovement, 'RebindInvCards', 'OldCardkey=' + q3.FieldByName('CurrentCardKey').AsString + ', NewCardkey=' + q3.FieldByName('NewCardKey').AsString);
        qUpdateInvMovement.Close;

        // обновление в дополнительнных таблицах складских документов ссылок на складские карточки
        for I := 0 to CardkeyFieldCount - 1 do
        begin
          q4.SQL.Text :=
            'SELECT ' +                                 #13#10 +
            '  RDB$FIELD_NAME ' +                       #13#10 +
            'FROM ' +                                   #13#10 +
            '  RDB$RELATION_FIELDS ' +                  #13#10 +
            'WHERE ' +                                  #13#10 +
            '  RDB$RELATION_NAME = :RelationName ' +    #13#10 +
            '  AND RDB$FIELD_NAME = :FieldName';
          q4.ParamByName('RelationName').AsString := q3.FieldByName('CurrentRelationName').AsString;
          q4.ParamByName('FieldName').AsString := CardkeyFieldNames[I];
        
          ExecSqlLogEvent(q4, 'RebindInvCards', 'RelationName=' + q3.FieldByName('CurrentRelationName').AsString + ', FieldName=' + CardkeyFieldNames[I]);

          if not q4.RecordCount > 0 then //если доп таблица содержит поле TOCARDKEY/FROMCARDKEY, то обновим их ссылки новыми карточками
          begin
            q4.Close;
            q4.SQL.Text := Format(
              'UPDATE ' +                               #13#10 +
              '  %0:s line ' +                          #13#10 +
              'SET ' +                                  #13#10 +
              '  line.%1:s = :NewCardkey ' +            #13#10 +
              'WHERE ' +                                #13#10 +
              '  line.%1:s = :OldCardkey ' +            #13#10 +
              '  AND ( '+                               #13#10 +
              '    SELECT doc.documentdate ' +          #13#10 +
              '    FROM gd_document doc ' +             #13#10 +
              '    WHERE doc.id = line.documentkey ' +  #13#10 +
              '  ) >= :ClosingDate ',
              [q3.FieldByName('CurrentRelationName').AsString, CardkeyFieldNames[I]]);

            q4.ParamByName('OldCardkey').AsInteger := q3.FieldByName('CurrentCardKey').AsInteger;
            q4.ParamByName('NewCardkey').AsInteger := q3.FieldByName('NewCardKey').AsInteger;
            q4.ParamByName('ClosingDate').AsDateTime := FClosingDate;
            
            ExecSqlLogEvent(q4, 'RebindInvCards', 'OldCardkey=' + q3.FieldByName('CurrentCardKey').AsString + ', NewCardkey=' + q3.FieldByName('NewCardKey').AsString +
              ', ClosingDate=' + DateTimeToStr(FClosingDate));
          end;
          q4.Close;
        end;
      end
      else begin
       /// TODO: exception
        LogEvent('Error rebinding card! cardkey=' + q3.FieldByName('CurrentCardKey').AsString);
      end;
      q3.Next;
    end;
    Tr.Commit;
    Tr.StartTransaction;
    q3.Close;
////
    q3.SQL.Text :=
      'EXECUTE BLOCK ' +                                                                        #13#10 +
      '  RETURNS(S VARCHAR(16384)) ' +                                                          #13#10 +
      'AS ' +                                                                                   #13#10 +
      'BEGIN ' +                                                                                #13#10 +
      '  FOR ' +                                                                                #13#10 +
      '    SELECT ''ALTER TABLE '' || relation_name || '' ADD CONSTRAINT '' || ' +              #13#10 +
      '      constraint_name || '' FOREIGN KEY ('' || list_fields || '') REFERENCES '' || ' +   #13#10 +
      '      ref_relation_name || ''('' || list_ref_fields || '') '' || ' +                     #13#10 +
      '      IIF(update_rule = ''RESTRICT'', '''', '' ON UPDATE '' || update_rule) || ' +       #13#10 +
      '      IIF(delete_rule = ''RESTRICT'', '''', '' ON DELETE '' || delete_rule) ' +          #13#10 +
      '    FROM dbs_tmp_fk_constraints ' +                                                      #13#10 +
      '    INTO :S ' +                                                                          #13#10 +
      '  DO BEGIN ' +                                                                           #13#10 +
      '    SUSPEND; ' +                                                                         #13#10 +
      '    EXECUTE STATEMENT :S WITH AUTONOMOUS TRANSACTION; ' +                                #13#10 +
      '  END ' +                                                                                #13#10 +
      'END';
    ExecSqlLogEvent(q3, 'RebindInvCards');

    Tr.Commit;
    
    LogEvent('Rebinding cards... OK');
  finally
    q3.Free;
    q4.Free;
    qUpdateInvMovement.Free;
    qUpdateFirstDocKey.Free;
    qUpdateCard.Free;
    Tr.Free;
  end;
end;

function TgsDBSqueeze.CreateHIS(AnIndex: Integer): Integer;
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Assert(Connected);
  Result := 0;

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
                                                                                ///TODO: exception
    end;         
  finally
    q.Free;
    Tr.Free;  
  end;
end;

function TgsDBSqueeze.GetCountHIS(AnIndex: Integer): Integer;
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Assert(Connected);
  Result := -1;

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

function TgsDBSqueeze.DestroyHIS(AnIndex: Integer): Integer;
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Assert(Connected);
  Result := 0;

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
                                                                                ///TODO: exception
    end;
  finally
    q.Free;
    Tr.Free;  
  end;
end;

procedure TgsDBSqueeze.CreateHIS_IncludeInHIS;
var
  Tr: TIBTransaction;
  q: TIBSQL;
  Companykey: Integer;
  
  procedure IncludeCascadingSequences(const ATableName: String);
  var
    Tr, Tr2: TIBTransaction;
    q: TIBQuery;
    q2, q3, q4, q5: TIBSQL;
    FkFieldsList: TStringList;
    FkFieldsList2: TStringList;
    FkFieldsListLine: TStringList;
    IsLine: Boolean;
    TblsNamesList: TStringList;  // Process Queue
    AllProcessedTblsNames: TStringList;
    ReProc: TStringList;
    EndReProcTbl: String;
    GoReprocess: Boolean;
    AllProc: TStringList;
    ProcTblsNamesList: TStringList;
    CascadeProcTbls: TStringList;
    I, J, IndexEnd, Inx, Counter, Kolvo, RealKolvo, RealKolvo2: Integer;
    IsAppended, IsDuplicate, DoNothing, GoToFirst, GoToLast, IsFirstIteration: Boolean;
    TmpStr: String;
    MainDuplicateTblName: String;
    LineTblsNames: String;
    LineTblsList:  TStringList;
    LinePosList: TStringList;
    LinePosInx: Integer;

    function PosR2L(const FindS, SrcS: string): Integer;//возвращает начало последнего вхождения подстроки FindS в строку SrcS, т.е. первое с конца.
                                                        //Если возвращает ноль, то подстрока не найдена.
      function InvertS(const S: string): string; //Инверсия строки S
      var
        i, Len: Integer;
      begin
        Len := Length(S);
        SetLength(Result, Len);
        for i := 1 to Len do
          Result[i] := S[Len - i + 1];
      end;
    var
      ps: Integer;
    begin
      ps := Pos(InvertS(FindS), InvertS(SrcS));
      if ps <> 0 then
        Result := Length(SrcS) - Length(FindS) - ps + 2
      else
        Result := 0;
    end;

  begin
    LogEvent('Including cascading sequences in HIS...');
    Assert(Trim(ATableName) <> '');

    FkFieldsList := TStringList.Create;
    FkFieldsList2 := TStringList.Create;
    FkFieldsListLine := TStringList.Create;
    TblsNamesList := TStringList.Create;
    AllProcessedTblsNames := TStringList.Create;
    ProcTblsNamesList := TStringList.Create;
    ReProc :=  TStringList.Create;
    CascadeProcTbls := TStringList.Create;
    LineTblsList := TStringList.Create;
    AllProc := TStringList.Create;
    LinePosList := TStringList.Create;

    q := TIBQuery.Create(nil);
    q2 := TIBSQL.Create(nil);
    q3 := TIBSQL.Create(nil);
    q4 := TIBSQL.Create(nil);
    q5 := TIBSQL.Create(nil);

    Tr := TIBTransaction.Create(nil);
    Tr2 := TIBTransaction.Create(nil);
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

      TblsNamesList.Append(UpperCase(Trim(ATableName)));
      AllProcessedTblsNames.Append(UpperCase(Trim(ATableName)));

      IsLine := False;
      IsAppended:= False;
      IsDuplicate := False;
      DoNothing := False;
      GoToFirst := False;
      GoToLast := False;

      LogEvent('[test] FIgnoreTbls: ' + FIgnoreTbls.Text);

      try
        ///test 0
        q3.SQL.Text :=
        'SELECT COUNT(a.pk) AS A, COUNT(b.pk) AS B, COUNT(c.pk) AS C, COUNT(d.pk) AS D, g_his_has(1, 156383501) AS HIS1_98,  g_his_has(1, 156383500) AS HIS1_97' + #13#10 +
        'FROM dbs_tmp_pk_hash a,dbs_tmp_his_2 b,dbs_tmp_pk_hash c,dbs_tmp_his_2 d ' + #13#10 +
        'WHERE a.relation_name = ''USR$BMS_APPL'' AND a.pk=156383501 ' + #13#10 +
        '  AND b.relation_name = ''USR$BMS_APPL'' AND b.pk=156383500 ' + #13#10 +
        '  AND c.relation_name = ''GD_DOCUMENT'' AND c.pk=156383501 ' + #13#10 +
        '  AND d.relation_name = ''GD_DOCUMENT'' AND d.pk=156383500 ';
        ExecSqlLogEvent(q3, 'IncludeCascadingSequences');
        LogEvent('[_test 0] a=' + q3.FieldByName('A').AsString + ', b=' + q3.FieldByName('B').AsString + ', c=' + q3.FieldByName('C').AsString + ', d=' + q3.FieldByName('D').AsString + ', 98 in HIS: ' + q3.FieldByName('HIS1_98').AsString +', 97 in HIS: ' + q3.FieldByName('HIS1_97').AsString);
        q3.Close;

        //------------------ добавление в HIS всех цепочек cascade, создание списка обработанных таблиц AllProcessedTblsNames
        while TblsNamesList.Count <> 0 do
        begin
          q.Close;
          q.SQL.Text :=
            'SELECT ' +                                                 #13#10 +
            '  TRIM(fc.relation_name)     AS relation_name, ' +         #13#10 +
            '  LIST(fc.list_fields)       AS list_fields, ' +           #13#10 +
            '  TRIM(fc.ref_relation_name) AS ref_relation_name, ' +     #13#10 +
            '  TRIM(fc.LIST_REF_FIELDS)   AS LIST_REF_FIELDS, ' +       #13#10 +
            '  TRIM(st.list_fields)       AS pk_fields ' +              #13#10 +
            'FROM dbs_fk_constraints fc ' +                             #13#10 +
            '  JOIN dbs_suitable_tables st ' +                          #13#10 +
            '    ON st.relation_name = fc.relation_name ' +             #13#10 +
            '  LEFT JOIN dbs_tmp2_fk_constraints fc2 ' +                #13#10 +
            '    ON fc2.constraint_name = fc.constraint_name ' +        #13#10 +
            'WHERE ' +                                                  #13#10 +
            '  fc2.constraint_name IS NULL ' +                          #13#10 +
            '  AND fc.ref_relation_name = :rln ' +                          #13#10 +
            '  AND fc.delete_rule = ''CASCADE'' ' +                     #13#10 +//((fc.update_rule = ''CASCADE'') OR (fc.delete_rule = ''CASCADE'')) '
            '  AND fc.list_fields NOT LIKE ''%,%'' ' +                  #13#10 +
            'GROUP BY fc.relation_name, fc.ref_relation_name, fc.LIST_REF_FIELDS, st.list_fields ';

          q.ParamByName('rln').AsString := TblsNamesList[0];
          q.Open;

          q2.Close;
          q2.SQL.Text :=
            'SELECT ' +                                                                   #13#10 +
            '  TRIM(fc.list_fields) AS fk_fields ' +                                      #13#10 +
            'FROM dbs_fk_constraints fc ' +                                               #13#10 +
            '  JOIN dbs_suitable_tables pc ' +                                            #13#10 +
            '    ON pc.relation_name = fc.relation_name AND pc.list_fields = fc.list_fields ' + #13#10 +
            'WHERE fc.delete_rule = ''CASCADE'' ' +                                       #13#10 +//((fc.update_rule = ''CASCADE'') OR (fc.delete_rule = ''CASCADE'')) ' +
            '  AND fc.relation_name = :rln ' +                                            #13#10 +
            '  AND fc.list_fields NOT LIKE ''%,%'' ';
          q2.ParamByName('rln').AsString := TblsNamesList[0];
          ExecSqlLogEvent(q2, 'IncludeCascadingSequences');

          if q2.RecordCount = 0 then //pk не явл fk
            IsLine := False
          else// pk=fk
            IsLine := True;
          q2.Close;

          IsAppended:= False;
          while not q.EOF do
          begin
            FkFieldsList.Clear;
            Kolvo := 0;
            RealKolvo := 0;
            RealKolvo2 := 0;
            FkFieldsList.Text := StringReplace(q.FieldByName('list_fields').AsString, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
            q2.Close;
            q2.SQL.Text :=
              'SELECT ' +                                                                   #13#10 +
              '  TRIM(fc.list_fields) AS fk_fields ' +                                      #13#10 +
              'FROM dbs_fk_constraints fc ' +                                               #13#10 +
              '  JOIN dbs_suitable_tables pc ' +                                            #13#10 +
              '    ON pc.relation_name = fc.relation_name AND fc.list_fields = pc.list_fields ' + #13#10 +
              'WHERE fc.delete_rule = ''CASCADE'' ' +                                       #13#10 +//((fc.update_rule = ''CASCADE'') OR (fc.delete_rule = ''CASCADE'')) ' +
              '  AND fc.relation_name = :rln ' +                                            #13#10 +
              '  AND fc.list_fields NOT LIKE ''%,%'' ';
            q2.ParamByName('rln').AsString := q.FieldByName('relation_name').AsString;
            ExecSqlLogEvent(q2, 'IncludeCascadingSequences');

            if q2.RecordCount = 0 then // Eсли PK не является FK
            begin
              for I:=0 to FkFieldsList.Count-1 do
              begin
                q3.SQL.Text :=
                  'SELECT ' +                                                                                          #13#10 +
                  '  SUM(IIF(g_his_has(1, r.' + q.FieldByName('pk_fields').AsString + ') = 0, 1, 0)) AS RealKolvo, ' + #13#10 +
                  '  COUNT(g_his_include(1, r.' + q.FieldByName('pk_fields').AsString + '))          AS Kolvo ' +      #13#10 +
                  'FROM ' +                                                       #13#10 +
                     q.FieldByName('relation_name').AsString + ' r ' +            #13#10 +
                  'WHERE ';
                if not IsLine then
                  q3.SQL.Add(' ' +                                                #13#10 +
                    'g_his_has(1, r.' + Trim(FkFieldsList[I]) + ') = 1')
                else
                  q3.SQL.Add(' ' +                                                #13#10 +
                    'EXISTS( ' +                                                  #13#10 +
                    '  SELECT * FROM dbs_tmp_pk_hash h ' +                        #13#10 +
                    '  WHERE h.pk = r.' +  Trim(FkFieldsList[I]) +                #13#10 +
                    '  AND h.relation_name = ''' + TblsNamesList[0] + ''' ' +     #13#10 +/// '        AND h.relation_name = ''' + UpperCase(q.FieldByName('relation_name').AsString) + ''' ' + #13#10 +
                    ') ');

                q3.SQL.Add(' ' +                                                 #13#10 +
                  '  AND r.' + q.FieldByName('pk_fields').AsString + ' > 147000000 ');
                if FIgnoreTbls.IndexOf(                                                    ////
                  UpperCase(q.FieldByName('relation_name').AsString) + '=' +
                  UpperCase(Trim(FkFieldsList[I]))
                ) <> -1 then
                  q3.SQL.Add(' ' +                                                #13#10 +
                    'AND g_his_has(0, r.' + q.FieldByName('pk_fields').AsString +') = 0');

                ExecSqlLogEvent(q3, 'IncludeCascadingSequences');

                Kolvo := Kolvo + q3.FieldByName('Kolvo').AsInteger;
                RealKolvo := RealKolvo + q3.FieldByName('RealKolvo').AsInteger;
                q3.Close;
              end;
            end
            else begin
              if LineTblsList.IndexOfName(UpperCase(q.FieldByName('relation_name').AsString)) <> -1 then
                LineTblsList.Delete(LineTblsList.IndexOfName(UpperCase(q.FieldByName('relation_name').AsString)));

              LineTblsList.Append(UpperCase(q.FieldByName('relation_name').AsString) + '=' +  AllProcessedTblsNames[AllProcessedTblsNames.Count-1] + ';');

            //***
              for I:=0 to FkFieldsList.Count-1 do
              begin
                q3.Close;
                ///////////////////
                q3.SQL.Text :=
                  '  SELECT ' +                                                          #13#10 +
                  '    COUNT(r.' + q.FieldByName('pk_fields').AsString + ') AS Kolvo ' + #13#10 +
                  '  FROM ' +                                                            #13#10 +
                       q.FieldByName('relation_name').AsString + ' r ' +                 #13#10 +
                  '  WHERE ';
                if not IsLine then
                  q3.SQL.Add(' ' +                                                #13#10 +
                    'g_his_has(1, r.' + Trim(FkFieldsList[I]) + ') = 1')
                else
                  q3.SQL.Add(' ' +                                                #13#10 +
                    'EXISTS( ' +                                                  #13#10 +
                    '  SELECT * FROM dbs_tmp_pk_hash h ' +                        #13#10 +
                    '  WHERE h.pk = r.' +  Trim(FkFieldsList[I]) +                #13#10 +
                    '  AND h.relation_name = ''' + TblsNamesList[0] + ''' ' +     #13#10 +/// '        AND h.relation_name = ''' + UpperCase(q.FieldByName('relation_name').AsString) + ''' ' + #13#10 +
                    ') ');

                q3.SQL.Add(' ' +                                                 #13#10 +                                                           #13#10 +
                  '    AND r.' + q.FieldByName('pk_fields').AsString + ' > 147000000 ');
                if FIgnoreTbls.IndexOf(                                                    ////
                  UpperCase(q.FieldByName('relation_name').AsString) + '=' +
                  UpperCase(Trim(FkFieldsList[I]))
                ) <> -1 then
                  q3.SQL.Add(' ' +                                                     #13#10 +
                    'AND (g_his_has(0, r.' + q.FieldByName('pk_fields').AsString +') = 0) ');

                ExecSqlLogEvent(q3, 'IncludeCascadingSequences');

                /////////////////////
                Kolvo := Kolvo + q3.FieldByName('Kolvo').AsInteger;
                q3.Close;

                if Kolvo <> 0 then
                begin
                  q3.SQL.Text :=
                    'INSERT INTO DBS_TMP_PK_HASH ' +                                       #13#10 +
                    'SELECT ' +                                                            #13#10 +
                    '  r.' + q.FieldByName('pk_fields').AsString + ', ' +                  #13#10 +
                    '  ''' + UpperCase(Trim(q.FieldByName('relation_name').AsString)) + ''', ' + #13#10 +
                    '  HASH(' + 'r.' + q.FieldByName('pk_fields').AsString  + ' || ' + '''' + UpperCase(q.FieldByName('relation_name').AsString) + '''), ' + #13#10 +
                    '  ''' + Trim(q.FieldByName('pk_fields').AsString) + ''' ' +                 #13#10 +
                    'FROM ' +                                                              #13#10 +
                       q.FieldByName('relation_name').AsString + ' r ' +                   #13#10 +
                    'WHERE ';
                  if not IsLine then
                    q3.SQL.Add(' ' +                                                #13#10 +
                      'g_his_has(1, r.' + Trim(FkFieldsList[I]) + ') = 1')
                  else
                    q3.SQL.Add(' ' +                                                #13#10 +
                      'EXISTS( ' +                                                  #13#10 +
                      '  SELECT * FROM dbs_tmp_pk_hash h ' +                        #13#10 +
                      '  WHERE h.pk = r.' +  Trim(FkFieldsList[I]) +                #13#10 +
                      '  AND h.relation_name = ''' + TblsNamesList[0] + ''' ' +     #13#10 +/// '        AND h.relation_name = ''' + UpperCase(q.FieldByName('relation_name').AsString) + ''' ' + #13#10 +
                      ') ');

                    q3.SQL.Add(' ' +                                                 #13#10 +
                    '  AND NOT EXISTS( ' +                                                 #13#10 +
                    '    SELECT * FROM DBS_TMP_PK_HASH h ' +                               #13#10 +
                    '    WHERE h.pk = r.' + q.FieldByName('pk_fields').AsString +          #13#10 +
                    '      AND h.relation_name = ''' + UpperCase(Trim(q.FieldByName('relation_name').AsString)) + ''' ' + #13#10 +
                    '  ) ' +                                                               #13#10 +
                    '  AND r.' + q.FieldByName('pk_fields').AsString + ' > 147000000 ');
                  if FIgnoreTbls.IndexOf(                                                    ////
                    UpperCase(q.FieldByName('relation_name').AsString) + '=' +
                    UpperCase(Trim(FkFieldsList[I]))
                  ) <> -1 then
                    q3.SQL.Add(' ' +                                                       #13#10 +
                      'AND (g_his_has(0, r.' + q.FieldByName('pk_fields').AsString +') = 0) ');

                  ExecSqlLogEvent(q3, 'IncludeCascadingSequences');

                  ///ttt

                  RealKolvo := RealKolvo + q3.RowsAffected;
                  if q3.RowsAffected > 0 then
                    LogEvent('[test] RowsAffected insert: ' + IntToStr(q3.RowsAffected));
                  ///Count := Count + q3.FieldByName('RealKolvo').AsInteger;
                end;
              end;
            //***
            end;

            if Kolvo <> 0 then
            begin
              if AllProcessedTblsNames.IndexOf(UpperCase(q.FieldByName('relation_name').AsString)) <> -1 then
              begin
                if RealKolvo <> 0 then
                begin
                  if TblsNamesList.IndexOf(UpperCase(q.FieldByName('relation_name').AsString)) <> -1 then
                  begin
                    DoNothing := True;

                    // Случай 1: этот FK является ссылкой таблицы на саму себя
                    if UpperCase(q.FieldByName('relation_name').AsString) = UpperCase(q.FieldByName('ref_relation_name').AsString) then ///TODO: AnsiCompareStr()=0
                    begin
                      LogEvent('[test] ' + q.FieldByName('relation_name').AsString + '=' + q.FieldByName('ref_relation_name').AsString);
              
                      if q2.RecordCount = 0 then // Eсли PK не является FK
                      begin
                        repeat
                          ///TODO: перепроверить
                          for I:=0 to FkFieldsList.Count-1 do
                          begin
                            q3.Close;
                            q3.SQL.Text :=
                              'SELECT ' +                                                                              #13#10 +
                              '  SUM(g_his_include(1, r.' + q.FieldByName('pk_fields').AsString + ')) AS RealKolvo ' + #13#10 +
                              'FROM ' +                                                                                #13#10 +
                                 q.FieldByName('relation_name').AsString + ' r ' +                                     #13#10 +
                              'WHERE ';

                            if not IsLine then
                              q3.SQL.Add(' ' +                                                #13#10 +
                                'g_his_has(1, r.' + Trim(FkFieldsList[I]) + ') = 1')
                            else
                              q3.SQL.Add(' ' +                                                #13#10 +
                                'EXISTS( ' +                                                  #13#10 +
                                '  SELECT * FROM dbs_tmp_pk_hash h ' +                        #13#10 +
                                '  WHERE h.pk = r.' +  Trim(FkFieldsList[I]) +                #13#10 +
                                '  AND h.relation_name = ''' + TblsNamesList[0] + ''' ' +     #13#10 +/// '        AND h.relation_name = ''' + UpperCase(q.FieldByName('relation_name').AsString) + ''' ' + #13#10 +
                                ') ');

                            q3.SQL.Add(' ' +                                                  #13#10 +
                              '  AND r.' + q.FieldByName('pk_fields').AsString + ' > 147000000 ');         ///
                            if FIgnoreTbls.IndexOf(
                              UpperCase(q.FieldByName('relation_name').AsString) + '=' +
                              UpperCase(Trim(FkFieldsList[I]))
                            ) <> -1 then
                              q3.SQL.Add(' ' +                                                #13#10 +
                                'AND g_his_has(0, r.' + q.FieldByName('pk_fields').AsString +') = 0');

                            ExecSqlLogEvent(q3, 'IncludeCascadingSequences');

                            RealKolvo2 := RealKolvo2 + q3.FieldByName('RealKolvo').AsInteger;
                          end;
                        until RealKolvo2 = 0;
                      end
                      else begin
                        repeat
                          for I:=0 to FkFieldsList.Count-1 do
                          begin
                            q3.Close;

                            q3.SQL.Text :=
                              'INSERT INTO DBS_TMP_PK_HASH ' +                                       #13#10 +
                              'SELECT ' +                                                            #13#10 +
                              '  r.' + q.FieldByName('pk_fields').AsString + ', ' +                  #13#10 +
                              '  ''' + UpperCase(q.FieldByName('relation_name').AsString) + ''', ' + #13#10 +
                              '  HASH(' + 'r.' + q.FieldByName('pk_fields').AsString  + ' || ' + '''' + UpperCase(q.FieldByName('relation_name').AsString) + '''), ' +  #13#10 +
                              '  ''' + q.FieldByName('pk_fields').AsString + ''' ' +                 #13#10 +
                              'FROM ' +                                                              #13#10 +
                                 q.FieldByName('relation_name').AsString + ' r ' +                   #13#10 +
                              'WHERE ';
                            if not IsLine then
                              q3.SQL.Add(' ' +                                                #13#10 +
                                'g_his_has(1, r.' + Trim(FkFieldsList[I]) + ') = 1')
                            else
                              q3.SQL.Add(' ' +                                                #13#10 +
                                'EXISTS( ' +                                                  #13#10 +
                                '  SELECT * FROM dbs_tmp_pk_hash h ' +                        #13#10 +
                                '  WHERE h.pk = r.' +  Trim(FkFieldsList[I]) +                #13#10 +
                                '  AND h.relation_name = ''' + TblsNamesList[0] + ''' ' +     #13#10 +/// '        AND h.relation_name = ''' + UpperCase(q.FieldByName('relation_name').AsString) + ''' ' + #13#10 +
                                ') ');

                            q3.SQL.Add(' ' +                                                 #13#10 +
                              '  AND NOT EXISTS( ' +                                                 #13#10 +
                              '    SELECT * FROM DBS_TMP_PK_HASH h ' +                               #13#10 +
                              '    WHERE h.pk = r.' + q.FieldByName('pk_fields').AsString +          #13#10 +
                              '      AND h.relation_name = ''' + UpperCase(q.FieldByName('relation_name').AsString) + ''' ' + #13#10 +
                              '  ) ' +                                                               #13#10 +
                              '  AND r.' + q.FieldByName('pk_fields').AsString + ' > 147000000 ');
                            if FIgnoreTbls.IndexOf(                                                    ////
                              UpperCase(q.FieldByName('relation_name').AsString) + '=' +
                              UpperCase(Trim(FkFieldsList[I]))
                            ) <> -1 then
                              q3.SQL.Add(' ' +                                                       #13#10 +
                                'AND (g_his_has(0, r.' + q.FieldByName('pk_fields').AsString +') = 0) ');

                            ExecSqlLogEvent(q3, 'IncludeCascadingSequences');

                            ///ttt

                            RealKolvo2 := RealKolvo2 + q3.RowsAffected;
                            ///Count := Count + q3.FieldByName('RealKolvo').AsInteger;
                          end;
                        until RealKolvo2 = 0;
                      end;
                      GoToFirst := True;
                    end;
                      //else
                      //  Cлучай 2: еще не обработали таблицы, ссылающиеся каскадно на эту таблицу =>  q.Next;
                  end
                  // Cлучай 3: уже обработали таблицы, ссылающиеся каскадно на эту таблицу
                  else begin
                    if not IsDuplicate then // первый круг
                    begin
                      IsDuplicate := True;
                      MainDuplicateTblName := UpperCase(q.FieldByName('relation_name').AsString);
                    end;

                    if UpperCase(q.FieldByName('relation_name').AsString) = MainDuplicateTblName then
                    begin
                      TblsNamesList.Clear;
                      GoToLast := True;
                    end;
                  end;
                end
                else begin
                  //Ситуация 1. 2 круг
                  DoNothing := True;

                  //если НЕ(Ситуация 1. 2 круг. дошли до ссылки на себя), то мб Ситуация 3 конец переобработки
                  if (UpperCase(q.FieldByName('relation_name').AsString) <> UpperCase(q.FieldByName('ref_relation_name').AsString))
                    and (UpperCase(q.FieldByName('relation_name').AsString) = MainDuplicateTblName) then // ситуация 3. заканчиваем цикл переобработки
                  begin
                    IsDuplicate := False;
                    MainDuplicateTblName := '';
                  end;
                end;

                if (IsDuplicate) and (not DoNothing) then
                  AllProcessedTblsNames.Delete(AllProcessedTblsNames.IndexOf(UpperCase(q.FieldByName('relation_name').AsString)));
              end;

              if not DoNothing then
              begin
                AllProcessedTblsNames.Append(UpperCase(q.FieldByName('relation_name').AsString));
                TblsNamesList.Append(UpperCase(q.FieldByName('relation_name').AsString));

                IsAppended := True;
              end
              else begin // закончили переобработку Ситуации 3. круг 2
                DoNothing := False;
              end;
            end;
            q3.Close;
            q2.Close;

            if GoToFirst then
            begin
              q.First;
              GoToFirst := False;
            end
            else begin
              if GoToLast then
                q.Last;
              q.Next;
            end;
          end;
          q.Close;

        {**
          if IsAppended or (q.RecordCount=0) then
          begin
            I:=0;
            while I < LineTblsList.Count do
            begin
              if AnsiPos(TblsNamesList[0], LineTblsList.Values[LineTblsList.Names[I]]) <> 0  then     /// если таблица та кот ищем ссылки сохранена как индекс
              begin
                if AnsiPos(AllProcessedTblsNames[AllProcessedTblsNames.Count-1], LineTblsList.Values[LineTblsList.Names[I]]) <> 0  then
                begin
                  //удалим, чтобы не было дубликатов
                  TmpStr := LineTblsList.Values[LineTblsList.Names[I]];
                    Delete(
                      TmpStr,
                      AnsiPos(AllProcessedTblsNames[AllProcessedTblsNames.Count-1], TmpStr),
                      Length(AllProcessedTblsNames[AllProcessedTblsNames.Count-1] + ';'));

                  LineTblsList.Values[LineTblsList.Names[I]] := TmpStr;
                end;
                // запомним место- имя
                //if q.RecordCount = 1 then
                //  LineTblsList.Values[LineTblsList.Names[I]] := LineTblsList.Values[LineTblsList.Names[I]] + ';' + UpperCase(q.FieldByName('relation_name').AsString)
                //else begin
                //  LineTblsList.Values[LineTblsList.Names[I]] := Copy(
                //      LineTblsList.Values[LineTblsList.Names[I]],
                //      0,
                //      PosR2L(';', LineTblsList.Values[LineTblsList.Names[I]])
                //    ) + UpperCase(q.FieldByName('relation_name').AsString);
                //end;
                //LogEvent('[test] AFTER Copy=' + LineTblsList.Values[LineTblsList.Names[I]]);
                //

                ///TODO: ERROR list out of bounds
                LineTblsList.Values[LineTblsList.Names[I]] := LineTblsList.Values[LineTblsList.Names[I]] + AllProcessedTblsNames[AllProcessedTblsNames.Count-1] + ';';
              end;
              Inc(I);
            end;
          end;
        **}
          if GoToLast then
            GoToLast := False
          else
            TblsNamesList.Delete(0);
        end;
        Tr.Commit;
        Tr.StartTransaction;
        Tr2.Commit;
        Tr2.StartTransaction;

        LogEvent('[test] LineTblsList: ' + LineTblsList.Text);
        LogEvent('COUNT with CASCADE ref (BEFORE EXCLUDE): ' + IntToStr(GetCountHIS(1)));

        ///test 1
        q3.SQL.Text :=
          'SELECT LIST(a.pk) AS A,  g_his_has(1, 155457405) AS HIS_1, g_his_has(2, 155457405) AS HIS_2, g_his_has(3, 155457405) AS HIS_3 ' + #13#10 +
          'FROM dbs_tmp_pk_hash a ' + 								#13#10 +
          'WHERE a.relation_name = ''INV_PRICE'' AND a.pk=155457405 ';
        ExecSqlLogEvent(q3, 'IncludeCascadingSequences');
        LogEvent('[_test 1] dbs_1=' + q3.FieldByName('A').AsString + ', his_1=' + q3.FieldByName('HIS_1').AsString + ', his_2=' + q3.FieldByName('HIS_2').AsString + ', his_3=' + q3.FieldByName('HIS_3').AsString);
        q3.Close;
        q3.SQL.Text :=
          'SELECT LIST(b.pk) AS B ' + 	#13#10 +
          'FROM dbs_tmp_his_2 b ' +	#13#10 +
          'WHERE b.relation_name = ''INV_PRICE'' AND b.pk=155457405 ';
        ExecSqlLogEvent(q3, 'IncludeCascadingSequences');
        LogEvent('dbs_2=' + q3.FieldByName('B').AsString);
        q3.Close;
        //------------------ исключение из HIS PK, на которые есть restrict/noAction И исключение PK, на которые ссылаются (PK<147000000 или нах в HIS_3 - документы которые должны остаться)
        EndReProcTbl := '';
        GoReprocess := False;
        LogEvent('[test] AllProcessedTblsNames: ' + AllProcessedTblsNames.CommaText);
        CreateHIS(2);
        TblsNamesList.CommaText := AllProcessedTblsNames.CommaText;

        while TblsNamesList.Count > 0 do
        begin
          ProcTblsNamesList.Append(TblsNamesList[0]);
          LogEvent(ProcTblsNamesList.Text);
          IndexEnd := -1;
          IsLine := False;
          GoReprocess := False;

          FkFieldsList2.Clear;
          FkFieldsListLine.Clear;

          q.SQL.Text :=
            'SELECT ' +                                                                   #13#10 +
            '  TRIM(fc.list_fields) AS fk_fields ' +                                      #13#10 +
            'FROM dbs_fk_constraints fc ' +                                               #13#10 +
            '  JOIN dbs_suitable_tables pc ' +                                            #13#10 +
            '    ON pc.relation_name = fc.relation_name AND pc.list_fields = fc.list_fields ' +  #13#10 +
            'WHERE fc.delete_rule = ''CASCADE'' ' +                                       #13#10 +//((fc.update_rule = ''CASCADE'') OR (fc.delete_rule = ''CASCADE'')) ' +
            '  AND fc.relation_name = :rln ' +                                            #13#10 +
            '  AND fc.list_fields NOT LIKE ''%,%'' ';
          q.ParamByName('rln').AsString := TblsNamesList[0];
          q.Open;

          if q.RecordCount = 0 then
            IsLine := False
          else // pk=fk
            IsLine := True;
          q.Close;

          q.SQL.Text :=
            'SELECT ' +                                                                       #13#10 +
            '  LIST(TRIM(fc.list_fields)||''=''||TRIM(fc.ref_relation_name)) AS fk_field, ' + #13#10 +
            '  TRIM(fc.relation_name) AS relation_name ' +                                #13#10 +
            'FROM dbs_fk_constraints fc ' +                                               #13#10 +
            '  JOIN dbs_suitable_tables pc ' +                                            #13#10 +
            '    ON pc.relation_name = fc.relation_name ' +                               #13#10 +
            'WHERE fc.delete_rule = ''CASCADE'' ' +                                       #13#10 +//((fc.update_rule = ''CASCADE'') OR (fc.delete_rule = ''CASCADE'')) ' + #13#10 +
            '  AND fc.relation_name = :rln ' +                                            #13#10 +
            '  AND fc.list_fields NOT LIKE ''%,%'' ' +                                    #13#10 +
            'GROUP BY fc.relation_name ';
          q.ParamByName('rln').AsString := TblsNamesList[0];
          q.Open;
          FkFieldsList2.Text := StringReplace(q.FieldByName('fk_field').AsString, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
          q.Close;

          q.SQL.Text :=
            'SELECT ' +                                                                       #13#10 +
            '  LIST(TRIM(fc.list_fields)||''=''||TRIM(fc.ref_relation_name)) AS fk_field, ' + #13#10 +
            '  TRIM(fc.relation_name) AS relation_name ' +                                 #13#10 +
            'FROM dbs_fk_constraints fc ' +                                                #13#10 +
            '  JOIN dbs_suitable_tables pc ' +                                             #13#10 +
            '    ON pc.relation_name = fc.relation_name ' +                                #13#10 +
            '  JOIN dbs_suitable_tables pc2 ' +                                            #13#10 +
            '    ON pc2.relation_name = fc.ref_relation_name ' +                           #13#10 +
            '    JOIN dbs_fk_constraints fc2 ON fc2.relation_name = pc2.relation_name ' +  #13#10 +
            '      AND fc2.list_fields = pc2.list_fields ' +                               #13#10 +
            'WHERE fc.delete_rule = ''CASCADE'' ' +                                        #13#10 +//((fc.update_rule = ''CASCADE'') OR (fc.delete_rule = ''CASCADE'')) ' + #13#10 +
            '  AND fc.relation_name = :rln ' +                                             #13#10 +
            '  AND fc.list_fields NOT LIKE ''%,%'' ' +                                     #13#10 +
            'GROUP BY fc.relation_name ';
          q.ParamByName('rln').AsString := TblsNamesList[0];
          q.Open;
          
          if q.RecordCount <> 0 then
            FkFieldsListLine.Text := StringReplace(q.FieldByName('fk_field').AsString, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
          q.Close;

          // получим все FK cascade поля в таблице
          q.SQL.Text :=                                                 ///TODO: вынести. Prepare
            'SELECT ' +
            '  LIST(fc.list_fields) AS fk_field, ' +                                      #13#10 +
            '  TRIM(pc.list_fields) AS pk_field, ' +                                      #13#10 +
            '  fc.relation_name, fc.ref_relation_name, fc.list_ref_fields ' +             #13#10 +///для группировки
            'FROM dbs_fk_constraints fc ' +                                               #13#10 +
            '  JOIN dbs_suitable_tables pc ' +                                            #13#10 +
            '    ON pc.relation_name = fc.relation_name ' +                               #13#10 +
            'WHERE fc.delete_rule = ''CASCADE'' ' +                                       #13#10 +//((fc.update_rule = ''CASCADE'') OR (fc.delete_rule = ''CASCADE'')) ' +
            '  AND fc.relation_name = :rln ' +                                            #13#10 +
            '  AND fc.list_fields NOT LIKE ''%,%'' ' +                                    #13#10 +
            'GROUP BY pc.list_fields, fc.relation_name, fc.ref_relation_name, fc.list_ref_fields ';
          q.ParamByName('rln').AsString := TblsNamesList[0];
          q.Open;

          // если FK есть в HIS_2, то исключим PK из HIS (исключение цепи, что выше)
          while not q.EOF do
          begin
            FkFieldsList.Clear;
            FkFieldsList.Text := StringReplace(q.FieldByName('fk_field').AsString, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);

            if FkFieldsList.Count > 1 then
              LogEvent('[test] FkFieldsList: ' + FkFieldsList.Text);

            for I:=0 to FkFieldsList.Count-1 do
            begin
              if not IsLine then
                q3.SQL.Text :=
                  'SELECT ' +                                                                        #13#10 +
                  '  SUM(' +                                                                         #13#10 +
                  '    IIF(g_his_exclude(1, rln.' + q.FieldByName('pk_field').AsString + ') = 1, ' + #13#10 +
                  '      g_his_include(2, rln.' + q.FieldByName('pk_field').AsString + '), 0)' +     #13#10 +
                  '  ) AS Kolvo ' +                                                                  #13#10 +
                  'FROM ' +                                                                          #13#10 +
                     TblsNamesList[0] + ' rln ' +                                                    #13#10 +
                  'WHERE ' 
              else 
                q3.SQL.Text :=
                  'EXECUTE BLOCK ' +                                                                         #13#10 +
                  //'  RETURNS(S VARCHAR(16384)) ' +
                  'AS ' +                                                                                    #13#10 +
                  '  DECLARE VARIABLE S VARCHAR(16384); ' +                                                  #13#10 +
                  '  DECLARE VARIABLE S2 VARCHAR(16384); ' +                                                 #13#10 +
                  '  DECLARE VARIABLE ID INTEGER; ' +                                                        #13#10 +
                  'BEGIN ' +                                                                                 #13#10 +
                  '  S = ''DELETE FROM dbs_tmp_pk_hash h WHERE h.pk = :PK AND h.relation_name = :RN ''; '  + #13#10 +
                  '  S2 = ''update or INSERT INTO DBS_TMP_HIS_2 (pk, relation_name, pk_field) VALUES(:PK_, :RN_, :PK_FIELD_) ''; ' + #13#10 +
                  '  FOR ' +                                                                                 #13#10 +
                  '    SELECT ' +                                                                            #13#10 +
                  '      rln.' + q.FieldByName('pk_field').AsString +                                        #13#10 +
                  '    FROM ' +                                                                              #13#10 +
                         TblsNamesList[0] + ' rln ' +                                                        #13#10 +
                  '    WHERE ';


              if FkFieldsListLine.IndexOfName(Trim(FkFieldsList[I])) = -1 then
                q3.SQL.Add(' ' +                                                            #13#10 +
                  '(g_his_has(2, rln.' + Trim(FkFieldsList[I]) + ') = 1) ')
              else 
                q3.SQL.Add(' ' +                                                            #13#10 +
                  '   EXISTS( ' +                                                                        #13#10 +
                  '     SELECT * ' +                                                                     #13#10 +
                  '     FROM DBS_TMP_HIS_2 h ' +                                                         #13#10 +
                  '     WHERE h.pk = rln.' + Trim(FkFieldsList[I]) +                                    #13#10 +
                  '       AND h.relation_name = ''' + Trim(q.FieldByName('ref_relation_name').AsString) + '''' + #13#10 +///'       AND TRIM(h.relation_name) = ''' +   TblsNamesList[0] + '''' +                    #13#10 +
                  '    ) ');


              Counter := 0;
              for J:=0 to FkFieldsList2.Count-1 do
              begin
                if Trim(FkFieldsList2.Names[J]) <> Trim(FkFieldsList[I]) then
                begin
                  Inc(Counter);
                  if Counter <> 1 then
                    q3.SQL.Add(' ' +                                                           #13#10 +
                      '   AND ')
                  else
                    q3.SQL.Add(' ' +                                                           #13#10 +
                      ' AND(');

                  if (FkFieldsListLine.IndexOfName(Trim(FkFieldsList2.Names[J])) = -1) then
                    q3.SQL.Add(' ' +                                                             #13#10 +
                      '    ((g_his_has(1, rln.' + Trim(FkFieldsList2.Names[J]) + ')=0) OR (g_his_has(2, rln.' + Trim(FkFieldsList2.Names[J]) + ')=1)) ')
                  else
                    q3.SQL.Add(' ' +
                      '  ((NOT EXISTS( ' +                                                                 #13#10 +
                      '     SELECT * ' +                                                                   #13#10 +
                      '     FROM DBS_TMP_PK_HASH h ' +                                                     #13#10 +
                      '     WHERE h.pk = rln.' + Trim(FkFieldsList2.Names[J]) +                            #13#10 +
                      '       AND TRIM(h.relation_name) = ''' + UpperCase(FkFieldsList2.Values[FkFieldsList2.Names[J]]) + '''' + #13#10 +///'       AND TRIM(h.relation_name) = ''' +   TblsNamesList[0] + '''' +                    #13#10 +
                      '    )) OR (EXISTS( ' +                                                              #13#10 +
                      '     SELECT * ' +                                                                   #13#10 +
                      '     FROM DBS_TMP_HIS_2 h ' +                                                       #13#10 +
                      '     WHERE h.pk = rln.' + Trim(FkFieldsList2.Names[J]) +                            #13#10 +
                      '       AND TRIM(h.relation_name) = ''' + UpperCase(FkFieldsList2.Values[FkFieldsList2.Names[J]]) + '''' + #13#10 +///'       AND TRIM(h.relation_name) = ''' +   TblsNamesList[0] + '''' +                    #13#10 +
                      '   ))) ');
                end;
              end;

              if Counter <> 0 then
              begin
                q3.SQL.Add(' ' +                                                #13#10 +
                  '    )');

                Counter := 0;
              end;

              if IsLine then
                q3.SQL.Add(' ' +                                                                             #13#10 +
                  '  INTO :ID ' +                                                                            #13#10 +
                  '  DO BEGIN ' +                                                                            #13#10 +
                  '    EXECUTE STATEMENT (:S) (PK := :ID, RN := ''' + TblsNamesList[0] + '''); ' +           #13#10 +
                  '    EXECUTE STATEMENT (:S2) (PK_ := :ID, RN_ := ''' + TblsNamesList[0] + ''', PK_FIELD_ := ''' + q.FieldByName('pk_field').AsString + '''); ' +   #13#10 + 
                  '  END ' +                                                                                 #13#10 +
                  'END');

              ExecSqlLogEvent(q3, 'IncludeCascadingSequences');
              ///Count := Count - q2.FieldByName('Kolvo').AsInteger;
              q3.Close;
            end;
  
            q.Next;
          end;
          q.Close;

          if (TblsNamesList[0] = 'INV_PRICE') then//(TblsNamesList[0] = 'GD_DOCUMENT') or (TblsNamesList[0] = 'INV_PRICE') then
          begin
            LogEvent(TblsNamesList[0]);
                    ///test 2
            q3.SQL.Text :=
              'SELECT LIST(a.pk) AS A,  g_his_has(1, 155457405) AS HIS_1, g_his_has(2, 155457405) AS HIS_2, g_his_has(3, 155457405) AS HIS_3 ' + #13#10 +
              'FROM dbs_tmp_pk_hash a ' + 								#13#10 +
              'WHERE a.relation_name = ''INV_PRICE'' AND a.pk=155457405 ';
            ExecSqlLogEvent(q3, 'IncludeCascadingSequences');
            LogEvent('[_test 2] dbs_1=' + q3.FieldByName('A').AsString + ', his_1=' + q3.FieldByName('HIS_1').AsString + ', his_2=' + q3.FieldByName('HIS_2').AsString + ', his_3=' + q3.FieldByName('HIS_3').AsString);
            q3.Close;
            q3.SQL.Text :=
              'SELECT LIST(b.pk) AS B ' + 	#13#10 +
              'FROM dbs_tmp_his_2 b ' +	#13#10 +
              'WHERE b.relation_name = ''INV_PRICE'' AND b.pk=155457405 ';
            ExecSqlLogEvent(q3, 'IncludeCascadingSequences');
            LogEvent('dbs_2=' + q3.FieldByName('B').AsString);
            q3.Close;
          end;

          // ищем RESTRICT/NO ACTION на таблицу  И cascade с PK<147000000
          q.SQL.Text :=
            'SELECT ' +
            '  LIST(TRIM(fc.constraint_name), ''_'') AS  constraint_name, ' +
            '  TRIM(fc.relation_name) AS relation_name, ' +             #13#10 +
            '  ''DBS__TMP'' AS pk_fields, ' + //заглушка
            '  LIST(TRIM(fc.list_fields)||''=''||TRIM(fc.ref_relation_name)) AS fk_field, ' +  #13#10 +
            '  fc.ref_relation_name ' +                                 #13#10 + /// для группировки
            'FROM dbs_fk_constraints fc ' +                             #13#10 +
            'WHERE fc.delete_rule IN (''RESTRICT'', ''NO ACTION'') ' +  #13#10 +
            '  AND fc.ref_relation_name = :rln ' +                      #13#10 +
            '  AND fc.list_fields NOT LIKE ''%,%'' ' +                  #13#10 +
            'GROUP BY fc.relation_name, fc.ref_relation_name, fc.LIST_REF_FIELDS ' +

            'UNION ' +

            'SELECT ' +
            '  ''DBS__'' || LIST(TRIM(fc.constraint_name), ''_'') AS  constraint_name, ' +
            '  TRIM(fc.relation_name) AS relation_name, ' +             #13#10 +
            '  TRIM(pc.list_fields)   AS pk_fields, ' +                 #13#10 +
            '  LIST(TRIM(fc.list_fields)||''=''||TRIM(fc.ref_relation_name)) AS fk_field, ' +  #13#10 +
            '  fc.ref_relation_name ' +                                 #13#10 +
            'FROM dbs_fk_constraints fc ' +                             #13#10 +
            '  JOIN DBS_SUITABLE_TABLES pc ' +                          #13#10 +
            '    ON pc.relation_name = fc.relation_name ' +             #13#10 +
            'WHERE fc.delete_rule = ''CASCADE'' ' +                     #13#10 +
            '  AND fc.ref_relation_name = :rln ' +                      #13#10 +
            '  AND fc.list_fields NOT LIKE ''%,%'' ' +                  #13#10 +
            'GROUP BY fc.relation_name, fc.ref_relation_name, fc.LIST_REF_FIELDS, pc.list_fields ';
          q.ParamByName('rln').AsString := TblsNamesList[0];
          q.Open;

          while not q.EOF do
          begin
            FkFieldsList.Clear;
            Kolvo := 0;

            FkFieldsList.Text := StringReplace(q.FieldByName('fk_field').AsString, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
            
            for I:=0 to FkFieldsList.Count-1 do
            begin
              TmpStr := '';

              if not IsLine then
                q3.SQL.Text :=
                  'SELECT ' +                                                                 #13#10 +
                  '  SUM(' +                                                                  #13#10 +
                  '    IIF(g_his_exclude(1, rln.' + Trim(FkFieldsList.Names[I]) + ') = 1, ' + #13#10 +
                  '      g_his_include(2, rln.' +  Trim(FkFieldsList.Names[I]) + '), 0)' +    #13#10 +
                  '  ) AS Kolvo ' +                                                           #13#10 +
                  'FROM ' +                                                                   #13#10 +
                     q.FieldByName('relation_name').AsString +   ' rln '  +                   #13#10 +
                  'WHERE 0=0 '
              else begin
                TmpStr :=                                                          //для Kolvo
                  '    SELECT ' +                                                    #13#10 +
                  '      COUNT(rln.' + Trim(FkFieldsList.Names[I]) + ') AS Kolvo ' + #13#10 +
                  '    FROM ' +                                                      #13#10 +
                         q.FieldByName('relation_name').AsString + ' rln ' +         #13#10 +
                  '    WHERE ' +                                                     #13#10 +
                  '      EXISTS(' +                                                  #13#10 +
                  '        SELECT * ' +                                              #13#10 +
                  '        FROM dbs_tmp_pk_hash h ' +                                #13#10 +
                  '        WHERE h.pk = rln.' + Trim(FkFieldsList.Names[I]) +        #13#10 +
                  '          AND h.relation_name = ''' + TblsNamesList[0] + '''' +   #13#10 +///'          AND h.relation_name = ''' + UpperCase(q.FieldByName('relation_name').AsString) + '''' + #13#10 +
                  '      ) ';

                q3.SQL.Text :=
                  'EXECUTE BLOCK ' +                                            #13#10 +
                  //'  RETURNS(S VARCHAR(16384)) ' +
                  'AS ' +                                                       #13#10 +
                  '  DECLARE VARIABLE S VARCHAR(16384); ' +                     #13#10 +
                  '  DECLARE VARIABLE S2 VARCHAR(16384); ' +                    #13#10 +
                  '  DECLARE VARIABLE FK INTEGER; ' +                           #13#10 +
                  'BEGIN ' +                                                                                #13#10 +
                  '  S = ''DELETE FROM dbs_tmp_pk_hash h WHERE h.pk = :PK AND h.relation_name = :RN ''; ' + #13#10 +
                  '  S2 = '' update or INSERT INTO DBS_TMP_HIS_2 (pk, relation_name, pk_field) VALUES(:PK_, :RN_, :PK_FIELD_) ''; ' + #13#10 +
                  '  FOR ' +                                                                                #13#10 +
                  '    SELECT ' +                                               #13#10 +
                  '      rln.' + Trim(FkFieldsList.Names[I]) +                  #13#10 +
                  '    FROM ' +                                                 #13#10 +
                         q.FieldByName('relation_name').AsString + ' rln ' +    #13#10 +
                  '    WHERE ' +                                                #13#10 +
                  '      EXISTS(' +                                             #13#10 +
                  '        SELECT * ' +                                         #13#10 +
                  '        FROM dbs_tmp_pk_hash h ' +                           #13#10 +
                  '        WHERE h.pk = rln.' + Trim(FkFieldsList.Names[I]) +   #13#10 +
                  '          AND h.relation_name = ''' + TblsNamesList[0] + '''' + #13#10 +///'          AND h.relation_name = ''' + UpperCase(q.FieldByName('relation_name').AsString) + '''' + #13#10 +
                  '      ) ';
              end;

              if AnsiPos('DBS__', q.FieldByName('constraint_name').AsString) <> 0 then
              begin
                q3.SQL.Add(' ' +
                    'AND ((rln.' + q.FieldByName('pk_fields').AsString + ' < 147000000) OR (g_his_has(3, rln.' + q.FieldByName('pk_fields').AsString + ')=1))');
                if TmpStr <> '' then
                  TmpStr :=  TmpStr +  ' ' +
                   'AND ((rln.' + q.FieldByName('pk_fields').AsString + ' < 147000000) OR (g_his_has(3, rln.' + q.FieldByName('pk_fields').AsString + ')=1))';
              end;

              // если таблица с rectrict/noAction содержит предположительно удаляемый cascade
              if AllProcessedTblsNames.IndexOf(UpperCase(q.FieldByName('relation_name').AsString)) <> -1 then
              begin  //извлекаем FK restrict HIS вместе с цепью, если ВСЕ каскады отсутствуют в HIS
                FkFieldsListLine.Clear;
                q4.SQL.Text :=
                  'SELECT ' +                                                                   #13#10 +
                  '  LIST(TRIM(fc.list_fields)) AS fk_field, ' + #13#10 +
                  '  TRIM(fc.relation_name) AS relation_name ' +                                #13#10 +
                  'FROM dbs_fk_constraints fc ' +                                               #13#10 +
                  '  JOIN dbs_suitable_tables pc ' +                                            #13#10 +
                  '    ON pc.relation_name = fc.relation_name ' +                               #13#10 +
                  '  JOIN dbs_suitable_tables pc2 ' +                                           #13#10 +
                  '    ON pc2.relation_name = fc.ref_relation_name ' +                           #13#10 +
                  '    JOIN dbs_fk_constraints fc2 ON fc2.relation_name = pc2.relation_name ' + #13#10 +
                  '      AND fc2.list_fields = pc2.list_fields ' + #13#10 +
                  'WHERE fc.delete_rule = ''CASCADE'' ' +                                       #13#10 +//((fc.update_rule = ''CASCADE'') OR (fc.delete_rule = ''CASCADE'')) ' + #13#10 +
                  '  AND fc.relation_name = :rln ' +                                            #13#10 +
                  '  AND fc.list_fields NOT LIKE ''%,%'' ' +                                    #13#10 +
                  'GROUP BY fc.relation_name ';
                q4.ParamByName('rln').AsString := UpperCase(q.FieldByName('relation_name').AsString);
                ExecSqlLogEvent(q4, 'IncludeCascadingSequences');

                if q.RecordCount <> 0 then
                  FkFieldsListLine.Text := StringReplace(q4.FieldByName('fk_field').AsString, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);

                q4.Close;
                q4.SQL.Text :=  // получим все FK cascade поля в таблице
                  'SELECT ' +
                  '  TRIM(fc.list_fields) AS fk_field, ' +                                       #13#10 +
                  '  TRIM(fc.ref_relation_name) AS ref_relation_name ' +
                  'FROM dbs_fk_constraints fc ' +                                               #13#10 +
                  'WHERE fc.delete_rule = ''CASCADE'' ' +                                       #13#10 +//((fc.update_rule = ''CASCADE'') OR (fc.delete_rule = ''CASCADE'')) ' +
                  '  AND fc.relation_name = :rln ' +                                            #13#10 +
                  '  AND fc.list_fields NOT LIKE ''%,%'' ';
                q4.ParamByName('rln').AsString := UpperCase(q.FieldByName('relation_name').AsString);
                ExecSqlLogEvent(q4, 'IncludeCascadingSequences');

                while not q4.EOF do
                begin
                  if q4.FieldByName('fk_field').AsString <> Trim(FkFieldsList.Names[I]) then //FkFieldsList.IndexOfName(q4.FieldByName('fk_field').AsString) = -1 then
                  begin
                    if FkFieldsListLine.IndexOf(q4.FieldByName('fk_field').AsString) = -1 then
                    begin
                      q3.SQL.Add(' ' +
                        'AND g_his_has(1, rln.' + q4.FieldByName('fk_field').AsString + ') = 0 ');
                      TmpStr := TmpStr + '  AND g_his_has(1, rln.' + q4.FieldByName('fk_field').AsString + ') = 0 ';
                    end
                    else begin
                      q3.SQL.Add(' ' +
                        'AND (' +                                                                       #13#10 +
                        '  NOT EXISTS(' +                                                               #13#10 +
                        '    SELECT * ' +                                                               #13#10 +
                        '    FROM dbs_tmp_pk_hash h ' +                                                 #13#10 +
                        '    WHERE h.pk = rln.' + q4.FieldByName('fk_field').AsString +                 #13#10 +
                        '      AND h.relation_name = ''' + UpperCase(q4.FieldByName('ref_relation_name').AsString) + '''' + #13#10 +///'            AND h.relation_name = ''' + UpperCase(q.FieldByName('relation_name').AsString) + '''' + #13#10 +
                        '  )) ');
                      TmpStr := TmpStr + ' ' +
                        'AND (' +                                                                       #13#10 +
                        '  NOT EXISTS(' +                                                               #13#10 +
                        '    SELECT * ' +                                                               #13#10 +
                        '    FROM dbs_tmp_pk_hash h ' +                                                 #13#10 +
                        '    WHERE h.pk = rln.' + q4.FieldByName('fk_field').AsString +                 #13#10 +
                        '      AND h.relation_name = ''' + UpperCase(q4.FieldByName('ref_relation_name').AsString) + '''' + #13#10 +///'            AND h.relation_name = ''' + UpperCase(q.FieldByName('relation_name').AsString) + '''' + #13#10 +
                        '  )) ';
                    end;
                  end;
                  q4.Next;
                end;
                q4.Close;

                /////if есть в Proc И ReProc т.е. обработан рестрикт уже то надо переобработать его
              end;

              if not IsLine then
              begin
                ExecSqlLogEvent(q3, 'IncludeCascadingSequences');
                Kolvo := Kolvo + q3.FieldByName('Kolvo').AsInteger;
                ///Count := Count - q2.FieldByName('Kolvo').AsInteger;
              end
              else begin
                q3.SQL.Add(
                  '  INTO :FK ' +                                                                           #13#10 +
                  '  DO BEGIN ' +                                                                           #13#10 +
                  '    EXECUTE STATEMENT (:S) (PK := :FK, RN := ''' + TblsNamesList[0] + '''); ' + #13#10 +///'    EXECUTE STATEMENT (:S) (PK := :FK, RN := ''' + UpperCase(q.FieldByName('relation_name').AsString) + '''); ' + #13#10 +
                  '    EXECUTE STATEMENT (:S2) (PK_ := :FK, RN_ := ''' + TblsNamesList[0] + ''', PK_FIELD_ := ''' + Trim(FkFieldsList.Values[FkFieldsList.Names[I]]) + '''); ' +   #13#10 +                                                          #13#10 +
                  '  END ' +                                                                                #13#10 +
                  'END');

                q5.SQL.Text := TmpStr;
                ExecSqlLogEvent(q5, 'IncludeCascadingSequences');

                Kolvo := Kolvo + q5.FieldByName('Kolvo').AsInteger;
                q5.Close;
                TmpStr := '';

                ExecSqlLogEvent(q3, 'IncludeCascadingSequences');
              end;
              q3.Close;
              if (UpperCase(q.FieldByName('relation_name').AsString)='USR$BMS_APPL') then
              begin
                LogEvent('test');
                q3.SQL.Text := //активные рестрикты
                  'SELECT  ' +
                  '  COUNT(rln.DOCUMENTKEY) AS Kolvo ' +
                {  '  g_his_has(1, rln.DOCUMENTKEY) AS HasDoc_0, ' +
                  '  rln.USR$CONTRACTKEY, ' +
                  '  g_his_has(1, rln.USR$CONTRACTKEY) AS HasContract ' + }
                  'FROM ' +
                  '  USR$BMS_APPL rln  ' +
                  'WHERE ' +
                  '   g_his_has(1, rln.DOCUMENTKEY) = 0  AND g_his_has(1, rln.USR$CONTRACTKEY) = 1   ';
                ExecSqlLogEvent(q3, 'IncludeCascadingSequences');
                {while not q3.EOF do
                begin
                  LogEvent('[Test] activ restricts: ' + #13#10 + ' DOCUMENTKEY=' + q3.FieldByName('DOCUMENTKEY').AsString + #13#10 +
                  'HasDoc_0=' + q3.FieldByName('HasDoc_0').AsString + #13#10 +
                  ' USR$CONTRACTKEY=' + q3.FieldByName('USR$CONTRACTKEY').AsString + #13#10 +
                  'HasContract=' + q3.FieldByName('HasContract').AsString + #13#10);
                end; }
                LogEvent('[Test] Kolvo activ restricts ' + q3.FieldByName('Kolvo').AsString);
                q3.Close;
              end;
            end;

            if Kolvo > 0 then // есть смысл исключать по цепи
            begin
              q2.Close;
              IndexEnd := 0;
              IsFirstIteration := True;
              // исключение цепи из HIS   (исключение цепи, что ниже)
              while ProcTblsNamesList.Count > 0 do
              begin
                if IsFirstIteration then  //движемся от конца к началу 
                begin
                  CascadeProcTbls.Add(ProcTblsNamesList[ProcTblsNamesList.Count-1]);   //список элементов цепи каскадной
                  IndexEnd := AllProcessedTblsNames.IndexOf(CascadeProcTbls[0]);

                  while CascadeProcTbls.Count > 0 do                                  ///
                  begin
                    IsLine := False;

                    q2.SQL.Text :=
                      'SELECT ' +                                                                   #13#10 +
                      '  TRIM(fc.list_fields) AS fk_fields ' +                                      #13#10 +
                      'FROM dbs_fk_constraints fc ' +                                               #13#10 +
                      '  JOIN dbs_suitable_tables pc ' +                                            #13#10 +
                      '    ON pc.relation_name = fc.relation_name AND pc.list_fields = fc.list_fields ' + #13#10 +
                      'WHERE fc.delete_rule = ''CASCADE'' ' +                                       #13#10 +//((fc.update_rule = ''CASCADE'') OR (fc.delete_rule = ''CASCADE'')) ' +
                      '  AND fc.relation_name = :rln ' +                                            #13#10 +
                      '  AND fc.list_fields NOT LIKE ''%,%'' ';
                    q2.ParamByName('rln').AsString := CascadeProcTbls[0];
                    ExecSqlLogEvent(q2, 'IncludeCascadingSequences', 'rln=' + CascadeProcTbls[0]);

                    if q2.RecordCount = 0 then
                      IsLine := False
                    else // pk=fk
                      IsLine := True;
                    q2.Close;

                    FkFieldsList2.Clear;
                    q2.SQL.Text :=
                      'SELECT ' +                                                                   #13#10 +
                      '  LIST(TRIM(fc.list_fields)) AS list_fields, ' + #13#10 +
                      '  fc.relation_name ' +
                      'FROM dbs_fk_constraints fc ' +                                               #13#10 +
                      '  JOIN dbs_suitable_tables pc ' +                                            #13#10 +
                      '    ON pc.relation_name = fc.relation_name ' +                               #13#10 +
                      '  JOIN dbs_suitable_tables pc2 ' +                                           #13#10 +
                      '    ON pc2.relation_name = fc.ref_relation_name ' +                           #13#10 +
                      '    JOIN dbs_fk_constraints fc2 ON fc2.relation_name = pc2.relation_name ' + #13#10 +
                      '      AND fc2.list_fields = pc2.list_fields ' + #13#10 +
                      /////////////////////
                      //'WHERE fc.delete_rule IN (''CASCADE'', ''RESTRICT'', ''NO ACTION'') ' +
                       'WHERE fc.delete_rule =  ''CASCADE'' ' +
                      '  AND fc.relation_name = :rln ' +                                            #13#10 +
                      '  AND fc.list_fields NOT LIKE ''%,%'' ' +                                    #13#10 +
                      '  AND fc.ref_relation_name IN (';

                    for I:=0 to ProcTblsNamesList.Count-1 do
                    begin
                      q2.SQL.Add(' ''' + ProcTblsNamesList[I] + '''');
                      if I <> ProcTblsNamesList.Count-1 then
                        q2.SQL.Add(',');
                    end;
                    q2.SQL.Add(') ' +                                                               #13#10 +
                        'GROUP BY fc.relation_name ');
                    q2.ParamByName('rln').AsString := CascadeProcTbls[0];
                    ExecSqlLogEvent(q2, 'IncludeCascadingSequences', 'rln=' + CascadeProcTbls[0]);
                    
                    FkFieldsList2.Text := StringReplace(q2.FieldByName('list_fields').AsString, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
                    q2.Close;


                    q2.SQL.Text :=
                      'SELECT ' +                                                                   #13#10 +
                      '  LIST(TRIM(fc.list_fields)) AS list_fields, ' +                             #13#10 +
                      '  TRIM(fc.ref_relation_name) AS ref_relation_name, ' +                       #13#10 +
                      '  TRIM(pc.list_fields)       AS pk_fields, ' +                               #13#10 +
                      '  fc.LIST_REF_FIELDS ' +                                                     #13#10 +  ///для группировки
                      'FROM dbs_fk_constraints fc ' +                                               #13#10 +
                      '  JOIN DBS_SUITABLE_TABLES pc ' +                                            #13#10 +
                      '    ON pc.relation_name = fc.relation_name ' +                               #13#10 +
                      /////////////////////
                      //'WHERE fc.delete_rule IN (''CASCADE'', ''RESTRICT'', ''NO ACTION'') ' +                                       #13#10 +//((fc.update_rule = ''CASCADE'') OR ()) ' +
                       'WHERE fc.delete_rule =  ''CASCADE'' ' +
                      '  AND fc.relation_name = :rln ' +                                            #13#10 +
                      '  AND fc.ref_relation_name IN (';

                    for I:=0 to ProcTblsNamesList.Count-1 do
                    begin
                      q2.SQL.Add(' ''' + ProcTblsNamesList[I] + '''');
                      if I <> ProcTblsNamesList.Count-1 then
                        q2.SQL.Add(',');
                    end;
                    q2.SQL.Add(') ' +                                                               #13#10 +
                      'GROUP BY fc.ref_relation_name, pc.list_fields, fc.LIST_REF_FIELDS ');      ////

                    q2.ParamByName('rln').AsString := CascadeProcTbls[0];
                    ExecSqlLogEvent(q2, 'IncludeCascadingSequences', 'rln=' + CascadeProcTbls[0]);

                    while not q2.EOF do
                    begin
                      FkFieldsList.Clear;
                      FkFieldsList.Text := StringReplace(q2.FieldByName('list_fields').AsString, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);

                      for I:=0 to FkFieldsList.Count-1 do
                      begin
                        if FkFieldsList2.IndexOf(Trim(FkFieldsList[I])) = -1 then
                        begin
                          q3.SQL.Text :=
                            'SELECT ' +                                                       #13#10 +
                            '  SUM( ' +                                                       #13#10 +
                            '    IIF(g_his_exclude(1, rln.' + Trim(FkFieldsList[I]) + ') = 1, ' + #13#10 +
                            '      g_his_include(2, rln.' + Trim(FkFieldsList[I]) + '), 0) ' +    #13#10 +
                            '  ) AS Kolvo ' +                                                 #13#10 +
                            'FROM ' +                                                         #13#10 +
                               CascadeProcTbls[0] + ' rln ' +                                     #13#10 +
                            'WHERE ';

                          if not IsLine then
                            q3.SQL.Add(' ' +
                              'g_his_has(2, rln.' + q2.FieldByName('pk_fields').AsString + ') = 1 ')
                          else
                            q3.SQL.Add(' ' +
                              'EXISTS( ' +                                                                                              #13#10 +
                              '     SELECT * ' +                                                                                        #13#10 +
                              '     FROM DBS_TMP_HIS_2 h ' +                                                                            #13#10 +
                              '     WHERE h.pk = rln.' + q2.FieldByName('pk_fields').AsString +                                                 #13#10 +
                              '       AND TRIM(h.relation_name) = ''' + CascadeProcTbls[0] + '''' + #13#10 +///'       AND TRIM(h.relation_name) = ''' +   TblsNamesList[0] + '''' +                    #13#10 +
                              '   )');

                          ExecSqlLogEvent(q3, 'IncludeCascadingSequences');
                          q3.Close;
                        end
                        else begin
                          q3.SQL.Text :=
                            'EXECUTE BLOCK ' +                                                                        #13#10 +
                            //'  RETURNS(S VARCHAR(16384)) ' +
                            'AS ' +                                                                                   #13#10 +
                            '  DECLARE VARIABLE S VARCHAR(16384); ' +                                                 #13#10 +
                            '  DECLARE VARIABLE S2 VARCHAR(16384); ' +                                                #13#10 +
                            '  DECLARE VARIABLE FK INTEGER; ' +                                                       #13#10 +
                            'BEGIN ' +                                                                                #13#10 +
                            '  S = ''DELETE FROM dbs_tmp_pk_hash h WHERE h.pk = :PK AND h.relation_name = :RN ''; ' + #13#10 +
                            '  S2 = ''update or INSERT INTO DBS_TMP_HIS_2 (pk, relation_name, pk_field) VALUES(:PK_, :RN_, :PK_FIELD_) ''; ' + #13#10 +
                            '  FOR ' +                                                                                #13#10 +
                            '    SELECT ' +                                                                           #13#10 +
                            '      rln.' + Trim(FkFieldsList[I]) +                                                    #13#10 +
                            '    FROM ' +                                                                             #13#10 +
                                   CascadeProcTbls[0] + ' rln ' +                                                     #13#10 +
                            '    WHERE ';
                          if not IsLine then
                            q3.SQL.Add(' ' +
                              '    g_his_has(2, rln.' + q2.FieldByName('pk_fields').AsString + ') = 1 ')
                          else
                            q3.SQL.Add(' ' +
                              'EXISTS( ' +                                                                                              #13#10 +
                              '     SELECT * ' +                                                                                        #13#10 +
                              '     FROM DBS_TMP_HIS_2 h ' +                                                                            #13#10 +
                              '     WHERE h.pk = rln.' + q2.FieldByName('pk_fields').AsString +                                                 #13#10 +
                              '       AND TRIM(h.relation_name) = ''' + CascadeProcTbls[0] + '''' + #13#10 +///'       AND TRIM(h.relation_name) = ''' +   TblsNamesList[0] + '''' +                    #13#10 +
                              '   )');

                          q3.SQL.Add(' ' +
                            '      AND EXISTS( ' +                                                                    #13#10 +
                            '        SELECT * ' +                                                                     #13#10 +
                            '        FROM dbs_tmp_pk_hash h ' +                                                       #13#10 +
                            '        WHERE h.pk = rln.' + Trim(FkFieldsList[I]) +                                     #13#10 +
                            '          AND h.relation_name = ''' + UpperCase(q2.FieldByName('ref_relation_name').AsString) + '''' + #13#10 +///'          AND h.relation_name = ''' + CascadeProcTbls[0] + '''' +                        #13#10 +
                            '      ) ' +                                                                              #13#10 +
                            '  INTO :FK ' +                                                                           #13#10 +
                            '  DO BEGIN ' +                                                                           #13#10 +
                            '    EXECUTE STATEMENT (:S) (PK := :FK, RN := ''' + UpperCase(q2.FieldByName('ref_relation_name').AsString) + '''); ' +        #13#10 +///'    EXECUTE STATEMENT (:S) (PK := :FK, RN := ''' + CascadeProcTbls[0] + '''); ' +        #13#10 +
                            '    EXECUTE STATEMENT (:S2) (PK_ := :FK, RN_ := ''' + UpperCase(q2.FieldByName('ref_relation_name').AsString)  + ''', PK_FIELD_ := ''' + UpperCase(q2.FieldByName('LIST_REF_FIELDS').AsString) + '''); ' +   #13#10 +
                            '  END ' +                                                                                #13#10 +
                            'END');
  
                          ExecSqlLogEvent(q3, 'IncludeCascadingSequences');
                          q3.Close;
                        end;
                      end;


                      if CascadeProcTbls.IndexOf(UpperCase(q2.FieldByName('ref_relation_name').AsString)) = -1 then
                      begin
                        CascadeProcTbls.Add(UpperCase(q2.FieldByName('ref_relation_name').AsString));
                      end;
                      q2.Next;
                    end;
                    q2.Close;

                    if ProcTblsNamesList.IndexOf(CascadeProcTbls[0]) <> -1 then
                    begin
                      ProcTblsNamesList.Delete(ProcTblsNamesList.IndexOf(CascadeProcTbls[0]));
                    end;
                    CascadeProcTbls.Delete(0);
                  end;
                  {if (ProcTblsNamesList[0] = 'GD_DOCUMENT') or (ProcTblsNamesList[0] = 'USR$BMS_APPL') then
                  begin
                    LogEvent(ProcTblsNamesList[0]);
                            ///test 4
                    q4.SQL.Text :=
                      'SELECT COUNT(a.pk) AS A, COUNT(b.pk) AS B, COUNT(c.pk) AS C, COUNT(d.pk) AS D ' + #13#10 +
                      'FROM dbs_tmp_pk_hash a,dbs_tmp_his_2 b,dbs_tmp_pk_hash c,dbs_tmp_his_2 d ' + #13#10 +
                      'WHERE a.relation_name = ''USR$BMS_APPL'' AND a.pk=160090798 ' + #13#10 +
                      '  AND b.relation_name = ''USR$BMS_APPL'' AND b.pk=160090798 ' + #13#10 +
                      '  AND c.relation_name = ''GD_DOCUMENT'' AND c.pk=160090797 ' + #13#10 +
                      '  AND d.relation_name = ''GD_DOCUMENT'' AND d.pk=160090797 ';
                    q4.ExecQuery;
                    LogEvent('[_test 4] a=' + q4.FieldByName('A').AsString + ', b=' + q4.FieldByName('B').AsString + ', c=' + q4.FieldByName('C').AsString + ', d=' + q4.FieldByName('D').AsString);
                    q4.Close;
                  end; }
                end
                else begin   // движемся от начала к концу ProcTblsNamesList
                  q2.Close;
                  q2.SQL.Text :=
                    'SELECT ' +                                                                   #13#10 +
                    '  LIST(fc.list_fields||''=''||TRIM(fc.ref_relation_name)) AS fk_field, ' +//'  LIST(fc.list_fields) AS fk_field, ' +                                      #13#10 +
                    '  TRIM(fc.relation_name) AS relation_name ' +                                #13#10 +
                    'FROM dbs_fk_constraints fc ' +                                               #13#10 +
                    '  JOIN dbs_suitable_tables pc ' +                                            #13#10 +
                    '    ON pc.relation_name = fc.relation_name ' +                               #13#10 +
                    /////////////////////
                    //'WHERE fc.delete_rule IN (''CASCADE'', ''RESTRICT'', ''NO ACTION'') ' +
                     'WHERE fc.delete_rule =  ''CASCADE'' ' +
                    '  AND fc.relation_name = :rln ' +                                            #13#10 +
                    '  AND fc.list_fields NOT LIKE ''%,%'' ' +                                    #13#10 +
                    'GROUP BY fc.relation_name ';
                  q2.ParamByName('rln').AsString := ProcTblsNamesList[0];
                  q2.ExecQuery;
                  FkFieldsList2.Text := StringReplace(q2.FieldByName('fk_field').AsString, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
                  q2.Close;

                  q2.SQL.Text :=                                                        /////////////////
                    'SELECT ' +                                                 #13#10 +
                    '  LIST(TRIM(fc.list_fields)) AS list_fields, ' +           #13#10 + 
                    '  TRIM(fc.ref_relation_name) AS ref_relation_name, ' +     #13#10 +
                    '  TRIM(st.list_fields) AS pk_field, ' +                   #13#10 +
                    '  fc.list_ref_fields ' +                                   #13#10 +///для группировки
                    'FROM dbs_fk_constraints fc ' +                             #13#10 +
                    '  JOIN dbs_suitable_tables st ' +                          #13#10 +
                    '    ON st.relation_name = fc.relation_name ' +             #13#10 +
                    /////////////////////
                    //'WHERE fc.delete_rule IN (''CASCADE'', ''RESTRICT'', ''NO ACTION'') ' +
                    'WHERE fc.delete_rule =  ''CASCADE'' ' +
                    '  AND fc.relation_name = :rln ' +                                            #13#10 +
                    '  AND fc.ref_relation_name IN (';
                  for I:=0 to IndexEnd do
                  begin
                    q2.SQL.Add(' ''' + AllProcessedTblsNames[I] + '''');
                    if I <> IndexEnd then
                      q2.SQL.Add(',');
                  end;
                  q2.SQL.Add(') ' +                                                               #13#10 +
                    'GROUP BY fc.ref_relation_name, st.list_fields, fc.LIST_REF_FIELDS');

                  q2.ParamByName('rln').AsString := ProcTblsNamesList[0];
                  ExecSqlLogEvent(q2, 'IncludeCascadingSequences', 'rln=' + ProcTblsNamesList[0]);

                  while not q2.EOF do
                  begin

                    FkFieldsList.Clear;
                    FkFieldsList.Text := StringReplace(q2.FieldByName('list_fields').AsString, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);

                    for I:=0 to FkFieldsList.Count-1 do
                    begin
                      q3.Close;

                      if not IsLine then
                        q3.SQL.Text :=
                          'SELECT ' +                                                                         #13#10 +
                          '  SUM(' +                                                                          #13#10 +
                          '    IIF(g_his_exclude(1, rln.' + q2.FieldByName('pk_field').AsString + ') = 1, ' + #13#10 +
                          '      g_his_include(2, rln.' + q2.FieldByName('pk_field').AsString + '), 0)' +     #13#10 +
                          '  ) AS Kolvo ' +                                                                   #13#10 +
                          'FROM ' +                                                                           #13#10 +
                             ProcTblsNamesList[0] + ' rln ' +                                                 #13#10 +
                          'WHERE '
                      else
                        q3.SQL.Text :=
                          'EXECUTE BLOCK ' +                                                                         #13#10 +
                          //'  RETURNS(S VARCHAR(16384)) ' +
                          'AS ' +                                                                                    #13#10 +
                          '  DECLARE VARIABLE S VARCHAR(16384); ' +                                                  #13#10 +
                          '  DECLARE VARIABLE S2 VARCHAR(16384); ' +                                                  #13#10 +
                          '  DECLARE VARIABLE ID INTEGER; ' +                                                        #13#10 +
                          'BEGIN ' +                                                                                 #13#10 +
                          '  S = ''DELETE FROM dbs_tmp_pk_hash h WHERE h.pk = :PK AND h.relation_name = :RN ''; '  + #13#10 +
                          '  S2 = ''update or INSERT INTO DBS_TMP_HIS_2 (pk, relation_name, pk_field) VALUES(:PK_, :RN_, :PK_FIELD_) ''; ' + #13#10 +
                          '  FOR ' +                                                                                 #13#10 +
                          '    SELECT ' +                                                                            #13#10 +
                          '      rln.' + q2.FieldByName('pk_field').AsString +                                        #13#10 +
                          '    FROM ' +                                                                              #13#10 +
                                 ProcTblsNamesList[0] + ' rln ' +                                                        #13#10 +
                          '    WHERE ';


                      if FkFieldsListLine.IndexOfName(Trim(FkFieldsList[I])) = -1 then
                        q3.SQL.Add(' ' +                                                            #13#10 +
                          '(g_his_has(2, rln.' + Trim(FkFieldsList[I]) + ') = 1) ')
                      else
                        q3.SQL.Add(' ' +                                                            #13#10 +
                          '   EXISTS( ' +                                                                        #13#10 +
                          '     SELECT * ' +                                                                     #13#10 +
                          '     FROM DBS_TMP_HIS_2 h ' +                                                         #13#10 +
                          '     WHERE h.pk = rln.' + Trim(FkFieldsList[I]) +                                    #13#10 +
                          '       AND h.relation_name = ''' + Trim(q2.FieldByName('ref_relation_name').AsString) + '''' + #13#10 +///'       AND TRIM(h.relation_name) = ''' +   TblsNamesList[0] + '''' +                    #13#10 +
                          '    ) ');

                      Counter := 0;
                      for J:=0 to FkFieldsList2.Count-1 do
                      begin
                        if Trim(FkFieldsList2.Names[J]) <> Trim(FkFieldsList[I]) then
                        begin
                          Inc(Counter);
                          if Counter <> 1 then
                            q3.SQL.Add(' ' +                                                           #13#10 +
                              '   AND ')
                          else
                            q3.SQL.Add(' ' +                                                           #13#10 +
                              ' AND(');

                          if FkFieldsListLine.IndexOfName(Trim(FkFieldsList2.Names[J])) = -1 then
                            q3.SQL.Add(' ' +                                                             #13#10 +
                              '    ((g_his_has(1, rln.' + Trim(FkFieldsList2.Names[J]) + ')=0) OR (g_his_has(2, rln.' + Trim(FkFieldsList2.Names[J]) + ')=1)) ')
                          else
                            q3.SQL.Add(' ' +
                              '  ((NOT EXISTS( ' +                                                                 #13#10 +
                              '     SELECT * ' +                                                                     #13#10 +
                              '     FROM DBS_TMP_PK_HASH h ' +                                                       #13#10 +
                              '     WHERE h.pk = rln.' + Trim(FkFieldsList2.Names[J]) +                                    #13#10 +
                              '       AND TRIM(h.relation_name) = ''' + UpperCase(FkFieldsList2.Values[FkFieldsList2.Names[J]]) + '''' + #13#10 +///'       AND TRIM(h.relation_name) = ''' +   TblsNamesList[0] + '''' +                    #13#10 +
                              '    )) OR (EXISTS( ' +                                                                 #13#10 +
                              '     SELECT * ' +                                                                     #13#10 +
                              '     FROM DBS_TMP_HIS_2 h ' +                                                       #13#10 +
                              '     WHERE h.pk = rln.' + Trim(FkFieldsList2.Names[J]) +                                    #13#10 +
                              '       AND TRIM(h.relation_name) = ''' + UpperCase(FkFieldsList2.Values[FkFieldsList2.Names[J]]) + '''' + #13#10 +///'       AND TRIM(h.relation_name) = ''' +   TblsNamesList[0] + '''' +                    #13#10 +
                              '   ))) ');
                        end;
                      end;

                      if Counter <> 0 then
                      begin
                        q3.SQL.Add(' ' +                                                               #13#10 +
                          '    )');

                        Counter := 0;
                      end;

                      if IsLine then
                        q3.SQL.Add(' ' +                                                                             #13#10 +
                          '  INTO :ID ' +                                                                            #13#10 +
                          '  DO BEGIN ' +                                                                            #13#10 +
                          '    EXECUTE STATEMENT (:S) (PK := :ID, RN := ''' + ProcTblsNamesList[0] + '''); ' +       #13#10 +
                          '    EXECUTE STATEMENT (:S2) (PK_ := :ID, RN_ := ''' + ProcTblsNamesList[0] + ''', PK_FIELD_ := ''' + q2.FieldByName('pk_field').AsString + '''); ' +   #13#10 +
                          '  END ' +                                                                                 #13#10 +
                          'END');

                      ExecSqlLogEvent(q3, 'IncludeCascadingSequences');
                      q3.Close;
                    end;
                    q2.Next;
                  end;
                  q2.Close;

                  if ProcTblsNamesList[0] = 'INV_PRICE' then//(ProcTblsNamesList[0] = 'GD_DOCUMENT') or (ProcTblsNamesList[0] = 'INV_PRICE') then
                  begin
                    LogEvent(ProcTblsNamesList[0]);
                    ///test 3
                    q3.SQL.Text :=
                      'SELECT LIST(a.pk) AS A,  g_his_has(1, 155457405) AS HIS_1, g_his_has(2, 155457405) AS HIS_2, g_his_has(3, 155457405) AS HIS_3 ' + #13#10 +
                      'FROM dbs_tmp_pk_hash a ' + 								#13#10 +
                      'WHERE a.relation_name = ''INV_PRICE'' AND a.pk=155457405 ';
                    ExecSqlLogEvent(q3, 'IncludeCascadingSequences');
                    LogEvent('[_test 3] dbs_1=' + q3.FieldByName('A').AsString + ', his_1=' + q3.FieldByName('HIS_1').AsString + ', his_2=' + q3.FieldByName('HIS_2').AsString + ', his_3=' + q3.FieldByName('HIS_3').AsString);
                    q3.Close;
                    q3.SQL.Text :=
                      'SELECT LIST(b.pk) AS B ' + 	#13#10 +
                      'FROM dbs_tmp_his_2 b ' +	#13#10 +
                      'WHERE b.relation_name = ''INV_PRICE'' AND b.pk=155457405 ';
                    ExecSqlLogEvent(q3, 'IncludeCascadingSequences');
                    LogEvent('dbs_2=' + q3.FieldByName('B').AsString);
                    q3.Close;
                  end;

                  ProcTblsNamesList.Delete(0);
                end;

                IsFirstIteration := False;  // значит обработали каскад от таблицы на которую есть рестрикт. т.е. прошли первый круг
              end;
            
              if ReProc.Count <> 0 then
              begin
                GoReprocess := True; 
              end;
            end;
            
            if AllProcessedTblsNames.IndexOf(UpperCase(q.FieldByName('relation_name').AsString)) <> -1 then
            begin
              if ReProc.IndexOf(TblsNamesList[0] + '=' + UpperCase(q.FieldByName('relation_name').AsString)) = -1 then
                ReProc.CommaText := TblsNamesList[0] + '=' + UpperCase(q.FieldByName('relation_name').AsString) + ',' + ReProc.CommaText
              else begin
                ReProc.Delete(ReProc.IndexOf(TblsNamesList[0] + '=' + UpperCase(q.FieldByName('relation_name').AsString)));
                ReProc.CommaText := TblsNamesList[0] + '=' + UpperCase(q.FieldByName('relation_name').AsString) + ',' + ReProc.CommaText;
              end;
            end;  
            /////


              if (UpperCase(q.FieldByName('relation_name').AsString)='USR$BMS_APPL') then
              begin
                LogEvent('test');
                q3.SQL.Text := //активные рестрикты
                   'SELECT  ' +
                  '  COUNT(rln.DOCUMENTKEY) AS Kolvo ' +
                {  '  g_his_has(1, rln.DOCUMENTKEY) AS HasDoc_0, ' +
                  '  rln.USR$CONTRACTKEY, ' +
                  '  g_his_has(1, rln.USR$CONTRACTKEY) AS HasContract ' + }
                  'FROM ' +
                  '  USR$BMS_APPL rln  ' +
                  'WHERE ' +
                  '   g_his_has(1, rln.DOCUMENTKEY) = 0  AND  g_his_has(1, rln.USR$CONTRACTKEY) = 1  ';
                ExecSqlLogEvent(q3, 'IncludeCascadingSequences');
                {while not q3.EOF do
                begin
                  LogEvent('[Test] activ restricts: ' + #13#10 + ' DOCUMENTKEY=' + q3.FieldByName('DOCUMENTKEY').AsString + #13#10 +
                  'HasDoc_0=' + q3.FieldByName('HasDoc_0').AsString + #13#10 +
                  ' USR$CONTRACTKEY=' + q3.FieldByName('USR$CONTRACTKEY').AsString + #13#10 +
                  'HasContract=' + q3.FieldByName('HasContract').AsString + #13#10);
                end; }
                LogEvent('[Test] Kolvo activ restricts AFTER exclude: ' + q3.FieldByName('Kolvo').AsString);
                q3.Close;
              end;
          
            q.Next;
          end;
          q.Close;

          Tr2.Commit;
          Tr2.StartTransaction;

          if IndexEnd <> -1 then   //если нашли подходящий рестрикт т.е. ProcTblsNamesList пуст
          begin
            ProcTblsNamesList.Clear;                                           ///
            for I:=0 to IndexEnd do                                            ///
            begin                                                              ///
              ProcTblsNamesList.Append(AllProcessedTblsNames[I]);              ///
            end;                                                               ///
          end;

          if GoReprocess then 
          begin
            TblsNamesList.CommaText := AllProcessedTblsNames.CommaText;
            ProcTblsNamesList.Clear;
            ReProc.Clear;
          end
          else
            TblsNamesList.Delete(0);
        end;

        LogEvent('[test] COUNT HIS (AFTER EXCLUDE: ' + IntToStr(GetCountHIS(1)));

        ///test 4
          q3.SQL.Text :=
            'SELECT LIST(a.pk) AS A,  g_his_has(1, 155457405) AS HIS_1, g_his_has(2, 155457405) AS HIS_2, g_his_has(3, 155457405) AS HIS_3 ' + #13#10 +
            'FROM dbs_tmp_pk_hash a ' + 								#13#10 +
            'WHERE a.relation_name = ''INV_PRICE'' AND a.pk=155457405 ';
          ExecSqlLogEvent(q3, 'IncludeCascadingSequences');
          LogEvent('[_test 4] dbs_1=' + q3.FieldByName('A').AsString + ', his_1=' + q3.FieldByName('HIS_1').AsString + ', his_2=' + q3.FieldByName('HIS_2').AsString + ', his_3=' + q3.FieldByName('HIS_3').AsString);
          q3.Close;
          q3.SQL.Text :=
            'SELECT LIST(b.pk) AS B ' + 	#13#10 +
            'FROM dbs_tmp_his_2 b ' +	#13#10 +
            'WHERE b.relation_name = ''INV_PRICE'' AND b.pk=155457405 ';
          ExecSqlLogEvent(q3, 'IncludeCascadingSequences');
          LogEvent('dbs_2=' + q3.FieldByName('B').AsString);
          q3.Close;

        Tr.Commit;
        Tr2.Commit;
        Tr.StartTransaction;
        Tr2.StartTransaction;

        DestroyHIS(2);

        ///////////////////////
        for I:=0 to LineTblsList.Count-1 do
        begin
          if AllProcessedTblsNames.IndexOf(LineTblsList.Names[I]) <> -1 then
            AllProcessedTblsNames.Delete(AllProcessedTblsNames.IndexOf(LineTblsList.Names[I]));
        end;
        FCascadeTbls.Text := AllProcessedTblsNames.Text;
        LogEvent('[AAA test] FCascadeTbls: ' + FCascadeTbls.Text);
        LogEvent('[AAA test] LineTblsList: ' + LineTblsList.Text);
        ///////////////////////


       LogEvent('[test] COUNT HIS after exclude: ' + IntToStr(GetCountHIS(1)));

       LogEvent('[TEST] AllProc: ' + AllProc.Text);
       if AllProc.IndexOf('GD_RUID') = -1 then
         AllProc.Append('GD_RUID');
       if AllProc.IndexOf('AC_ENTRY_BALANCE') = -1 then
         AllProc.Append('AC_ENTRY_BALANCE');
       if AllProc.IndexOf('AC_RECORD') = -1 then
         AllProc.Append('AC_RECORD');
       if AllProc.IndexOf('AC_ENTRY') = -1 then
         AllProc.Append('AC_ENTRY');
       if AllProc.IndexOf('INV_CARD') = -1 then
         AllProc.Append('INV_CARD');
       if AllProc.IndexOf('INV_MOVEMENT') = -1 then
         AllProc.Append('INV_MOVEMENT');

       //// INSERT во временную таблицу список ВСЕХ обработанных таблиц AllProc;
       q2.SQL.Text :=
         'INSERT INTO DBS_TMP_PROCESSED_TABLES (RELATION_NAME) VALUES (:RN)';
       q2.Prepare;

       while AllProc.Count <> 0 do
       begin
         q2.ParamByName('RN').AsString := AllProc[0];
         ExecSqlLogEvent(q2, 'IncludeCascadingSequences', 'RN=' + AllProc[0]);
         AllProc.Delete(0);
       end;

        Tr.Commit;
        Tr2.Commit;
      except
        on E: Exception do
        begin
          Tr.Rollback;
          Tr2.Rollback;
          raise EgsDBSqueeze.Create(E.Message);
        end;
      end;

      LogEvent('Including cascading sequences in HIS... OK');
      ///Result := Count;
    finally
      FkFieldsList.Free;
      FkFieldsList2.Free;
      FkFieldsListLine.Free;
      CascadeProcTbls.Free;
      ProcTblsNamesList.Free;
      TblsNamesList.Free;
      AllProcessedTblsNames.Free;
      LineTblsList.Free;
      AllProc.Free;
      LinePosList.Free;
      ReProc.Free;
      q.Free;
      q2.Free;
      q3.Free;
      q4.Free;
      q5.Free;
      Tr.Free;
      Tr2.Free;
    end;
  end;

begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    CreateHIS(1);
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    LogEvent('Including PKs In HugeIntSet... ');

    q.SQL.Text :=                                                               ///TODO: учесть компанию
      'SELECT SUM(g_his_include(1, id)) AS Kolvo ' +                    #13#10 +
      'FROM gd_document ' +                                             #13#10 +
      'WHERE documentdate < :Date';
    q.ParamByName('Date').AsDateTime := FClosingDate;
    ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS', 'Date=' + DateTimeToStr(FClosingDate));
    LogEvent(Format('COUNT in HIS(1) without cascade: %d', [q.FieldByName('Kolvo').AsInteger]));

    if q.FieldByName('Kolvo').AsInteger <> 0 then
    begin
      q.Close;
      CreateHIS(3);
      q.SQL.Text :=                                                             ///TODO: учесть компанию
        'SELECT SUM(g_his_include(3, id)) AS Kolvo ' +                  #13#10 +
        'FROM gd_document ' +                                           #13#10 +
        'WHERE documentdate >= :Date';
      q.ParamByName('Date').AsDateTime := FClosingDate;
      ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS', 'Date=' + DateTimeToStr(FClosingDate));

      IncludeCascadingSequences('GD_DOCUMENT');

      DestroyHIS(3);
    end;
    q.Close;

    LogEvent(Format('COUNT in HIS(1) with CASCADE: %d', [GetCountHIS(1)]));
    q.SQL.Text :=
      'SELECT COUNT(id) AS Kolvo ' +                                    #13#10 +
      'FROM gd_document ' +                                             #13#10 +
      'WHERE (documentdate < :Date) ' +                                 #13#10 +
      '  AND g_his_has(1, id) = 1';
    q.ParamByName('Date').AsDateTime := FClosingDate;
    ExecSqlLogEvent(q, 'CreateHIS_IncludeInHIS', 'Date=' + DateTimeToStr(FClosingDate));
    LogEvent(Format('COUNT DOCS in HIS: %d', [q.FieldByName('Kolvo').AsInteger]));
    q.Close;

    Tr.Commit;

    LogEvent('Including PKs In HugeIntSet... OK');
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.DeleteDocuments_DeleteHIS;
var
  q: TIBSQL;
  Tr: TIBTransaction;
  I: Integer;
begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    LogEvent('Deleting from DB... ');

    for I:=0 to FCascadeTbls.Count-1 do
    begin
      q.SQL.Text :=
        'EXECUTE BLOCK ' +                                                #13#10 +
        'AS ' +                                                           #13#10 +
        '  DECLARE VARIABLE S VARCHAR(16384); ' +                         #13#10 +
        'BEGIN ' +                                                        #13#10 +
        '  FOR ' +                                                        #13#10 +
        '    SELECT ' +                                                   #13#10 +
        '    '' DELETE FROM '' || relation_name || ' +                    #13#10 +
        '    '' WHERE (g_his_has(1, '' || list_fields  || '') = 1) ' +    #13#10 +
        '      AND ('' || list_fields || '' > 147000000) '' ' +           #13#10 +
        '    FROM ' +                                                     #13#10 +
        '      DBS_SUITABLE_TABLES ' +                                    #13#10 +
        '    WHERE ' +                                                    #13#10 +
        '      relation_name NOT LIKE ''DBS_%'' ' +                       #13#10 +
        '      AND relation_name = ''' + Trim(FCascadeTbls[I]) + ''' ' +  #13#10 +
        '    INTO :S ' +                                                  #13#10 +
        '  DO BEGIN ' +                                                   #13#10 +
        '    EXECUTE STATEMENT :S;' +                                     #13#10 +//WITH AUTONOMOUS TRANSACTION
        '  END ' +                                                        #13#10 +
        'END';
      ExecSqlLogEvent(q, 'DeleteDocuments_DeleteHIS');
    end;

    Tr.Commit;
    Tr.StartTransaction;

    q.SQL.Text :=
      'EXECUTE BLOCK ' +                                                #13#10 +
      'AS ' +                                                           #13#10 +
      '  DECLARE VARIABLE PF VARCHAR(31); ' +                           #13#10 +
      '  DECLARE VARIABLE RN VARCHAR(31); ' +                           #13#10 +
      '  DECLARE VARIABLE KOLVO INTEGER; ' +                            #13#10 +
      'BEGIN ' +                                                        #13#10 +
      '  FOR ' +                                                        #13#10 +
      '    SELECT DISTINCT  ' +                                         #13#10 +
      '      relation_name,  ' +                                        #13#10 +
      '      pk_field  ' +                                              #13#10 +
      '    FROM dbs_tmp_pk_hash ' +                                     #13#10 +
      '    INTO :RN, :PF ' +                                            #13#10 +
      '  DO BEGIN ' +                                                   #13#10 +
      '    g_his_create(2, 0); ' +                                      #13#10 +
      '    SELECT SUM(g_his_include(2, pk)) ' +                         #13#10 +
      '    FROM dbs_tmp_pk_hash ' +                                     #13#10 +
      '    WHERE pk_field = :PF AND relation_name = :RN ' +             #13#10 +
      '    INTO :KOLVO; ' +                                             #13#10 +
      '    EXECUTE STATEMENT ''DELETE FROM ''||:RN|| '' WHERE g_his_has(2, '' ||:PF|| '')=1 ''; ' + #13#10 +
      '    g_his_destroy(2); ' +                                        #13#10 +
      '  END ' +                                                        #13#10 +
      'END ';
    ExecSqlLogEvent(q, 'DeleteDocuments_DeleteHIS');

    DestroyHIS(1);
    DestroyHIS(0);

    Tr.Commit;
    LogEvent('Deleting from DB... OK');
  finally
    q.Free;
    Tr.Free;
  end;
end;

function TgsDBSqueeze.GetConnected: Boolean;
begin
  Result := FIBDatabase.Connected;
end;

procedure TgsDBSqueeze.PrepareDB;
var
  Tr: TIBTransaction;
  q: TIBSQL;
  Companykey: Integer;
  FInactivBlockTriggers: String;

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
     /// '      JOIN DBS_TMP_PROCESSED_TABLES p ON p.relation_name = t.RDB$RELATION_NAME ' +  #13#10 +                                                   ////test
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
      'EXECUTE BLOCK ' +                                                        #13#10 +
      'AS ' +                                                                   #13#10 +
      '  DECLARE VARIABLE N CHAR(31); ' +                                       #13#10 +
      'BEGIN ' +                                                                #13#10 +
      '  FOR ' +                                                                #13#10 +
{     '    SELECT i.rdb$index_name ' +                                            #13#10 +
      '    FROM rdb$indices i ' +                                                 #13#10 +
    ///  '      JOIN DBS_TMP_PROCESSED_TABLES p ON p.relation_name = i.RDB$RELATION_NAME ' +  #13#10 +
      '    WHERE ((i.rdb$index_inactive = 0) OR (i.rdb$index_inactive IS NULL)) ' + #13#10 +
      '      AND ((i.RDB$SYSTEM_FLAG = 0) OR (i.RDB$SYSTEM_FLAG IS NULL)) ' +       #13#10 +
     /// '      AND ((rdb$index_name NOT LIKE ''DBS_%'') AND (rdb$index_name NOT LIKE ''PK_DBS_%'')) ' + #13#10 +        ///test
      '      AND i.rdb$relation_name NOT LIKE ''DBS_%'' ' +
      '      AND ((NOT i.rdb$index_name LIKE ''RDB$%'') ' +                       #13#10 +
      '        OR ((i.rdb$index_name LIKE ''RDB$PRIMARY%'') ' +                   #13#10 +
      '        OR (i.rdb$index_name LIKE ''RDB$FOREIGN%'')) ' +                   #13#10 +
      '      ) ' +                                                              #13#10 +     }

      //////////////////////
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
   ///   '      JOIN DBS_TMP_PROCESSED_TABLES p ON p.relation_name = pc.RELATION_NAME ' +  #13#10 +
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

      ////////////////////
      '      AND NOT EXISTS( ' +                                                #13#10 +
      '        SELECT * ' + 							#13#10 +
      '        FROM dbs_fk_constraints cc ' +					#13#10 +
      '        WHERE ' +							#13#10 +
      '          cc.ref_relation_name = pc.relation_name ' +			#13#10 +
      '          AND cc.delete_rule IN(''SET NULL'', ''SET DEFAULT'') ' +       #13#10 +
      '          AND cc.constraint_name NOT LIKE ''RDB$%'' ' +               	#13#10 +
      '      ) ' +                                                              #13#10 +
      ///////////////////
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
      ///'      JOIN DBS_TMP_PROCESSED_TABLES p ON p.relation_name = c.relation_name ' +  #13#10 +
      '    WHERE ' +                                                    #13#10 +
      '      c.constraint_name NOT LIKE ''DBS_%'' ' +                   #13#10 +
      //////////////
      '      AND c.delete_rule NOT IN(''SET NULL'', ''SET DEFAULT'') ' +#13#10 +
      //////
      '    INTO :CN, :RN ' +                                            #13#10 +
      '  DO ' +                                                                           #13#10 +
      '    EXECUTE STATEMENT ''ALTER TABLE '' || :RN || '' DROP CONSTRAINT '' || :CN; ' + #13#10 +
      'END';
    ExecSqlLogEvent(q, 'PrepareFKConstraints');

    Tr.Commit;
    Tr.StartTransaction;

    LogEvent('FKs dropped.');
  end;

  procedure SetBlockTriggerActive(const SetActive: Boolean);
  var
    StateStr: String;
    q: TIBSQL;
    q2: TIBSQL;
  begin
    q := TIBSQL.Create(nil);
    q2 := TIBSQL.Create(nil);
    try
      q.Transaction := Tr;
      q2.Transaction := Tr;

      if FInactivBlockTriggers = '' then
        LogEvent('[test] FInactivBlockTriggers=""')
      else
        LogEvent('[test] FInactivBlockTriggers=' + FInactivBlockTriggers);

      if FInactivBlockTriggers = '' then
      begin
        q.SQL.Text :=
          'SELECT ' +                                                   #13#10 +
          '  rdb$trigger_name AS TN ' +                                 #13#10 +
          'FROM ' +                                                     #13#10 +
          '  rdb$triggers ' +                                           #13#10 +
          'WHERE ' +                                                    #13#10 +
          '  rdb$system_flag = 0 ' +                                    #13#10 +
         // '  AND rdb$relation_name = ''AC_ENTRY'' ' +
          '  AND rdb$trigger_name LIKE ''%BLOCK%'' ' +                 #13#10 +
          '  AND rdb$trigger_inactive <> 0 ';                                   ///=1
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
        //'  AND rdb$relation_name = ''AC_ENTRY'' ' +
        '  AND rdb$trigger_name LIKE ''%BLOCK%'' ' +                    #13#10 +
        '  AND rdb$trigger_inactive = :IsInactiv ';
      if Trim(FInactivBlockTriggers) <> '' then
      begin
        LogEvent('[test] FInactivBlockTriggers=' + FInactivBlockTriggers);
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

      q.SQL.Text :=                                                             ///
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
        '      rdb$trigger_inactive = 0 ' +                                     #13#10 +
        '     AND rdb$system_flag = 0 ' +                                       #13#10 +
       // '     AND rdb$relation_name = ''AC_ENTRY'' ' +
        '     AND rdb$trigger_name NOT LIKE ''%ISSIMPLE%'' ' +                  #13#10 +
        '    INTO :TN ' +                                                       #13#10 +
        '  DO ' +                                                               #13#10 +
        '  BEGIN ' +                                                            #13#10 +
        '    EXECUTE STATEMENT ''ALTER TRIGGER '' || :TN || '' INACTIVE ''; ' + #13#10 +
        '  END ' +                                                              #13#10 +
        'END';
      ExecSqlLogEvent(q, 'SetBlockTriggerActive');

      Tr.Commit;
      Tr.StartTransaction;
    finally
      q.Free;
      q2.Free;
    end;
  end;

begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    LogEvent('DB preparation...');
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    try
      SetBlockTriggerActive(False);

      if FOnlyCompanySaldo then
      begin
        q.SQL.Text :=
          'SELECT contactkey AS CompanyKey ' +                          #13#10 +
          'FROM gd_company ' +                                          #13#10 +
          'WHERE fullname = :CompanyName ';
        q.ParamByName('CompanyName').AsString := FCompanyName;
        ExecSqlLogEvent(q, 'DeleteOldAcEntryBalance', Format('CompanyName = %s', [FCompanyName]));

        Companykey := q.FieldByName('CompanyKey').AsInteger;
        q.Close;
      end;

      LogEvent('[test] DELETE FROM AC_RECORD...');                               ///test
      q.SQL.Text :=
        'DELETE FROM AC_RECORD ' +                                      #13#10 +
        'WHERE ' +                                                      #13#10 +
        '  recorddate < :ClosingDate ';
      if FOnlyCompanySaldo then
        q.SQL.Add(' ' +
          'AND companykey = ' + IntToStr(Companykey));
      //  else if FAllOurCompaniesSaldo then
      //    q2.SQL.Add(' ' +
      //      'AND companykey IN(' + OurCompaniesListStr + ')');

      q.ParamByName('ClosingDate').AsDateTime := FClosingDate;
      ExecSqlLogEvent(q, 'DeleteOldAcEntryBalance', 'ClosingDate=' + DateTimeToStr(FClosingDate));
      LogEvent('[test] DELETE FROM AC_RECORD... OK');
      Tr.Commit;
      Tr.StartTransaction;

      SetBlockTriggerActive(True);

      PrepareFKConstraints;
      PreparePkUniqueConstraints;
      PrepareTriggers;
///      PrepareIndices;       //test

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
      'INSERT INTO DBS_INACTIVE_TRIGGERS (trigger_name) ' +                             #13#10 +
      'SELECT rdb$trigger_name ' +                                                      #13#10 +
      'FROM rdb$triggers ' +                                                            #13#10 +
      'WHERE (rdb$trigger_inactive <> 0) AND (rdb$trigger_inactive IS NOT NULL) ' +     #13#10 +
      '  AND ((rdb$system_flag = 0) OR (rdb$system_flag IS NULL)) ';
    ExecSqlLogEvent(q, 'SaveMetadata');

    // inactive indices
    q.SQL.Text :=
      'INSERT INTO DBS_INACTIVE_INDICES (index_name) ' +                                #13#10 +
      'SELECT rdb$index_name ' +                                                        #13#10 +
      'FROM rdb$indices ' +                                                             #13#10 +
      'WHERE (rdb$index_inactive <> 0) AND (rdb$index_inactive IS NOT NULL) ' +         #13#10 +
      '  AND ((rdb$system_flag = 0) OR (rdb$system_flag IS NULL))';
    ExecSqlLogEvent(q, 'SaveMetadata');

    // PKs and Uniques constraints
    q.SQL.Text :=
   {   'INSERT INTO DBS_PK_UNIQUE_CONSTRAINTS ( ' +                     #13#10 +
      '  RELATION_NAME, ' +                                             #13#10 +
      '  CONSTRAINT_NAME, ' +                                           #13#10 +
      '  CONSTRAINT_TYPE, ' +                                           #13#10 +
      '  LIST_FIELDS ) ' +                                              #13#10 +
      'SELECT ' +                                                       #13#10 +
      '  c.RDB$RELATION_NAME, ' +                                       #13#10 +
      '  c.RDB$CONSTRAINT_NAME, ' +                                     #13#10 +
      '  c.RDB$CONSTRAINT_TYPE, ' +                                     #13#10 +
      '  i.List_Fields ' +                                              #13#10 +
      'FROM ' +                                                         #13#10 +
      '  RDB$RELATION_CONSTRAINTS c ' +                                 #13#10 +
      '  JOIN (SELECT inx.RDB$INDEX_NAME, ' +                           #13#10 +
      '    list(TRIM(inx.RDB$FIELD_NAME)) as List_Fields ' +            #13#10 +
      '    FROM RDB$INDEX_SEGMENTS inx ' +                              #13#10 +
      '    GROUP BY inx.RDB$INDEX_NAME ' +                              #13#10 +
      '  ) i ON c.RDB$INDEX_NAME = i.RDB$INDEX_NAME ' +                 #13#10 +
      'WHERE ' +                                                        #13#10 +
      '  (c.rdb$constraint_type = ''PRIMARY KEY'' OR c.rdb$constraint_type = ''UNIQUE'') ' + #13#10 +
      '   AND c.rdb$constraint_name NOT LIKE ''RDB$%'' '; }

    ///////////
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
      '   ) ' +                                                                                    #13#10 +   }
      '   (c.rdb$constraint_type = ''PRIMARY KEY'' OR c.rdb$constraint_type = ''UNIQUE'')  ' + #13#10 +
      '   AND c.rdb$constraint_name NOT LIKE ''RDB$%'' ';
    ExecSqlLogEvent(q, 'SaveMetadata');

    // Имена таблиц и их поля PK, который подходит для добавления во множество HIS для удаления
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
      /////////////////
      //'  AND refc.rdb$delete_rule NOT IN(''SET NULL'', ''SET DEFAULT'') ' +     #13#10 +
      /////////
      '  AND c.rdb$constraint_name NOT LIKE ''RDB$%'' ' +                       #13#10 +
      'GROUP BY ' +                                                             #13#10 +
      '  1, 2, 3, 4, 5';
    ExecSqlLogEvent(q, 'SaveMetadata');

    Tr.Commit;
    Tr.StartTransaction;

    // для ссылочной целостности таблиц, которые не обрабатываются каскадом FKs

    //чтобы игнорить cascade и видеть только dbs_restrict
    q.SQL.Text :=
      'INSERT INTO DBS_TMP2_FK_CONSTRAINTS ( ' +                                #13#10 +
      '  constraint_name, ' +                                                   #13#10 +
      '  relation_name, ' +                                                     #13#10 +
      '  ref_relation_name, ' +                                                 #13#10 +
      '  update_rule, delete_rule, list_fields, list_ref_fields) ' +            #13#10 +
      'SELECT ' +                                                               #13#10 +
      '  fc.rdb$constraint_name        AS Constraint_Name, ' +                  #13#10 +
      '  fc.rdb$relation_name          AS Relation_Name, ' +                    #13#10 +
      '  fc2.rdb$relation_name         AS Ref_Relation_Name, ' +                #13#10 +
      '  refc.rdb$update_rule          AS Update_Rule, ' +                      #13#10 +
      '  refc.rdb$delete_rule          AS Delete_Rule, ' +                      #13#10 +
      '  LIST(iseg.rdb$field_name)     AS Fields, ' +                           #13#10 +
      '  LIST(ref_iseg.rdb$field_name) AS Ref_Fields ' +                        #13#10 +
      'FROM ' +                                                                 #13#10 +
      '  rdb$relation_constraints fc ' +                                        #13#10 +
      '  JOIN RDB$REF_CONSTRAINTS refc ' +                                      #13#10 +
      '    ON fc.rdb$constraint_name = refc.rdb$constraint_name ' +             #13#10 +
      '  JOIN RDB$RELATION_CONSTRAINTS fc2 ' +                                  #13#10 +
      '    ON refc.rdb$const_name_uq = fc2.rdb$constraint_name ' +              #13#10 +
      '  JOIN RDB$INDEX_SEGMENTS iseg ' +                                       #13#10 +
      '    ON iseg.rdb$index_name = fc.rdb$index_name ' +                       #13#10 +
      '  JOIN RDB$INDEX_SEGMENTS ref_iseg ' +                                   #13#10 +
      '    ON ref_iseg.rdb$index_name = fc2.rdb$index_name ' +                  #13#10 +
      '  JOIN( ' +                                                              #13#10 +
      '    SELECT ' +                                                           #13#10 +
      '      c.rdb$relation_name, ' +                                           #13#10 +
      '      COUNT(i.rdb$field_name)   AS Kolvo, ' +                            #13#10 +
      '      SUM(f.rdb$field_type)     AS Summa, ' +                            #13#10 +
      '      i.rdb$index_name ' +                                               #13#10 + // для группировки
      '    FROM ' +                                                             #13#10 +
      '      rdb$relation_constraints c ' +                                     #13#10 +
      '      JOIN RDB$INDEX_SEGMENTS i ' +                                      #13#10 +
      '        ON i.rdb$index_name = c.rdb$index_name ' +                       #13#10 +
      '      JOIN RDB$RELATION_FIELDS rf ' +                                    #13#10 +
      '        ON rf.rdb$relation_name = c.rdb$relation_name ' +                #13#10 +
      '          AND rf.rdb$field_name = i.rdb$field_name ' +                   #13#10 +
      '        JOIN RDB$FIELDS f ' +                                            #13#10 +
      '          ON f.rdb$field_name = rf.rdb$field_source ' +                  #13#10 +
      '    WHERE ' +                                                                             #13#10 +
      '      (c.rdb$constraint_type = ''PRIMARY KEY'' OR c.rdb$constraint_type = ''UNIQUE'') ' + #13#10 +
      '      AND c.rdb$constraint_name NOT LIKE ''RDB$%'' ' +                                    #13#10 + ///TODO: обдумать
      '    GROUP BY ' +                                                                          #13#10 +
      '      i.rdb$index_name, c.rdb$relation_name ' +                                           #13#10 +
      '    HAVING ' +                                                                            #13#10 +
      '      (COUNT(i.rdb$field_name) > 1) ' +                                                   #13#10 +
      '      OR ((COUNT(i.rdb$field_name) = 1) AND (SUM(f.rdb$field_type) <> 8)) ' +             #13#10 +
      '  )pc ON pc.rdb$relation_name = fc.rdb$relation_name ' +                                  #13#10 +
      'WHERE ' +                                                                #13#10 +
      '  fc.rdb$constraint_type = ''FOREIGN KEY''  ' +                          #13#10 +
      '  AND fc.rdb$constraint_name NOT LIKE ''RDB$%'' ' +                      #13#10 +
      '  AND refc.rdb$delete_rule = ''CASCADE'' ' +                             #13#10 +
      'GROUP BY ' +                                                             #13#10 +
      '  1, 2, 3, 4, 5 ' +                                                      #13#10 +
      ' ' +                                                                     #13#10 +
      'UNION ' +                                                                #13#10 +
      ' ' +                                                                     #13#10 +
      'SELECT ' +                                                               #13#10 +
      '  fc.rdb$constraint_name        AS Constraint_Name, ' +                  #13#10 +
      '  fc.rdb$relation_name          AS Relation_Name, ' +                    #13#10 +
      '  fc2.rdb$relation_name         AS Ref_Relation_Name, ' +                #13#10 +
      '  refc.rdb$update_rule          AS Update_Rule, ' +                      #13#10 +
      '  refc.rdb$delete_rule          AS Delete_Rule, ' +                      #13#10 +
      '  LIST(iseg.rdb$field_name)     AS Fields, ' +                           #13#10 +
      '  LIST(ref_iseg.rdb$field_name) AS Ref_Fields ' +                        #13#10 +
      'FROM ' +                                                                 #13#10 +
      '  rdb$relation_constraints fc ' +                                        #13#10 +
      '  JOIN RDB$REF_CONSTRAINTS refc ' +                                      #13#10 +
      '    ON fc.rdb$constraint_name = refc.rdb$constraint_name ' +             #13#10 +
      '  JOIN RDB$RELATION_CONSTRAINTS fc2 ' +                                  #13#10 +
      '    ON refc.rdb$const_name_uq = fc2.rdb$constraint_name ' +              #13#10 +
      '  JOIN RDB$INDEX_SEGMENTS iseg ' +                                       #13#10 +
      '    ON iseg.rdb$index_name = fc.rdb$index_name ' +                       #13#10 +
      '  JOIN RDB$INDEX_SEGMENTS ref_iseg ' +                                   #13#10 +
      '    ON ref_iseg.rdb$index_name = fc2.rdb$index_name ' +                  #13#10 +
      '  LEFT JOIN DBS_PK_UNIQUE_CONSTRAINTS pc ' +                             #13#10 +
      '    ON pc.relation_name = fc.rdb$relation_name ' +                       #13#10 +
      'WHERE ' +                                                                #13#10 +
      '  fc.rdb$constraint_type = ''FOREIGN KEY''  ' +                          #13#10 +
      '  AND fc.rdb$constraint_name NOT LIKE ''RDB$%'' ' +                      #13#10 +
      '  AND pc.relation_name IS NULL ' +                                       #13#10 +
      '  AND refc.rdb$delete_rule = ''CASCADE'' ' +                             #13#10 +
      'GROUP BY ' +                                                             #13#10 +
      '  1, 2, 3, 4, 5';
    ExecSqlLogEvent(q, 'SaveMetadata');

    Tr.Commit;
    Tr.StartTransaction;

    q.SQL.Text :=
      'INSERT INTO DBS_FK_CONSTRAINTS ( ' +                                     #13#10 +
      '  relation_name, ' +                                                     #13#10 +
      '  ref_relation_name, ' +                                                 #13#10 +
      '  constraint_name, ' +                                                   #13#10 +
      '  list_fields, list_ref_fields, update_rule, delete_rule) ' +            #13#10 +
      'SELECT ' +                                                               #13#10 +
      '  fc.relation_name, ' +                                                  #13#10 +
      '  fc.ref_relation_name, ' +                                              #13#10 +
      '  (''DBS_'' || fc.constraint_name) AS constraint_name, ' +               #13#10 +
      '  fc.list_fields, fc.list_ref_fields, ''RESTRICT'', ''RESTRICT'' ' +     #13#10 +
      'FROM ' +                                                                 #13#10 +
      '  dbs_fk_constraints fc ' +                                              #13#10 +
      '  JOIN( ' +                                                              #13#10 +
      '    SELECT ' +                                                           #13#10 +
      '      c.rdb$relation_name, ' +                                           #13#10 +
      '      COUNT(i.rdb$field_name) AS Kolvo, ' +                              #13#10 +
      '      SUM(f.rdb$field_type) AS Summa, ' +                                #13#10 +
      '      i.rdb$index_name ' +                                               #13#10 +//для группировки
      '    FROM ' +                                                             #13#10 +
      '      rdb$relation_constraints c ' +                                     #13#10 +
      '      JOIN RDB$INDEX_SEGMENTS i ' +                                      #13#10 +
      '        ON i.rdb$index_name = c.rdb$index_name ' +                       #13#10 +
      '      JOIN RDB$RELATION_FIELDS rf ' +                                    #13#10 +
      '        ON rf.rdb$relation_name = c.rdb$relation_name ' +                #13#10 +
      '          AND rf.rdb$field_name = i.rdb$field_name ' +                   #13#10 +
      '        JOIN RDB$FIELDS f ' +                                            #13#10 +
      '          ON f.rdb$field_name = rf.rdb$field_source ' +                  #13#10 +
      '    WHERE ' +                                                                             #13#10 +
      '      (c.rdb$constraint_type = ''PRIMARY KEY'' OR c.rdb$constraint_type = ''UNIQUE'') ' + #13#10 +
      '      AND c.rdb$constraint_name NOT LIKE ''RDB$%'' ' +                                    #13#10 +
      '    GROUP BY ' +                                                         #13#10 +
      '      i.RDB$INDEX_NAME, c.RDB$RELATION_NAME ' +                          #13#10 +
      '    HAVING ' +                                                           #13#10 +
      '      (COUNT(i.RDB$FIELD_NAME) > 1) ' +                                  #13#10 +
      '      OR ((COUNT(i.RDB$FIELD_NAME) = 1) AND (SUM(f.rdb$field_type) <> 8)) ' + #13#10 +
      '  )pc ON pc.rdb$relation_name = fc.relation_name ' +                     #13#10 +
      'WHERE ' +                                                                #13#10 +
      '  fc.delete_rule = ''CASCADE'' ' +                                       #13#10 +
      ' ' +                                                                     #13#10 +
      'UNION ' +                                                                #13#10 +
      ' ' +                                                                     #13#10 +
      'SELECT ' +                                                               #13#10 +
      '  fc.relation_name, ' +                                                  #13#10 +
      '  fc.ref_relation_name, ' +                                              #13#10 +
      '  (''DBS_'' || fc.constraint_name) AS constraint_name, ' +               #13#10 +
      '  fc.list_fields, fc.list_ref_fields, ''RESTRICT'', ''RESTRICT'' ' +     #13#10 +
      'FROM ' +                                                                 #13#10 +
      '  dbs_fk_constraints  fc ' +                                             #13#10 +
      '  LEFT JOIN DBS_PK_UNIQUE_CONSTRAINTS pc ' +                             #13#10 +
      '    ON pc.relation_name = fc.relation_name ' +                           #13#10 +
      'WHERE ' +                                                                #13#10 +
      '  pc.relation_name IS NULL ' +                                           #13#10 +
      '  AND fc.delete_rule = ''CASCADE'' ';
    ExecSqlLogEvent(q, 'SaveMetadata');

    // для ссылочной целостности AcSaldo                                        ///TODO: а надо ли вообще
    q.SQL.Text :=
      'INSERT INTO DBS_FK_CONSTRAINTS ( ' +                                     #13#10 +
      '  relation_name, ' +                                                     #13#10 +
      '  ref_relation_name, ' +                                                 #13#10 +
      '  constraint_name, ' +                                                   #13#10 +
      '  list_fields, list_ref_fields, update_rule, delete_rule) ' +            #13#10 +
      'SELECT ' +                                                               #13#10 +
      '  ''DBS_TMP_AC_SALDO'', ' +                                              #13#10 +
      '  ref_relation_name, ' +                                                 #13#10 +
      '  (''DBS_1'' || constraint_name), ' +                                    #13#10 +
      '  list_fields, list_ref_fields, ''RESTRICT'', ''RESTRICT'' ' +           #13#10 +
      'FROM  ' +                                                                #13#10 +
      '  dbs_fk_constraints  ' +                                                #13#10 +
      'WHERE  ' +                                                               #13#10 +
      '  relation_name = ''AC_ENTRY'' ' +                                       #13#10 +
      '  AND list_fields NOT IN(''TRANSACTIONKEY'', ''RECORDKEY'', ''DOCUMENTKEY'', ''MASTERDOCKEY'')';
    ExecSqlLogEvent(q, 'SaveMetadata');

    // для ссылочной целостности InvSaldo

    q.SQL.Text :=
      'INSERT INTO DBS_FK_CONSTRAINTS ( ' +
      '  relation_name, ' +
      '  ref_relation_name, ' +
      '  constraint_name, ' +
      '  list_fields, list_ref_fields, update_rule, delete_rule) ' +
      'VALUES ( ' +
      '  ''DBS_TMP_INV_SALDO'', ' +
      '  ''GD_GOOD'', ' +
      '  ''DBS_1INV_FK_CARD_GOODKEY'', ' +
      '  ''GOODKEY'', ''ID'', ''RESTRICT'', ''RESTRICT'')';
    ExecSqlLogEvent(q, 'SaveMetadata');

    q.SQL.Text :=
      'INSERT INTO DBS_FK_CONSTRAINTS ( ' +
      '  relation_name, ' +
      '  ref_relation_name, ' +
      '  constraint_name, ' +
      '  list_fields, list_ref_fields, update_rule, delete_rule) ' +
      'VALUES ( ' +
      '  ''DBS_TMP_INV_SALDO'', ' +
      '  ''GD_OURCOMPANY'', ' +
      '  ''DBS_1INV_FK_CARD_COMPANYKEY'', ' +
      '  ''COMPANYKEY'', ''COMPANYKEY'', ''RESTRICT'', ''RESTRICT'')';
    ExecSqlLogEvent(q, 'SaveMetadata');

    q.SQL.Text :=
      'INSERT INTO DBS_FK_CONSTRAINTS ( ' +
      '  relation_name, ' +
      '  ref_relation_name, ' +
      '  constraint_name, ' +
      '  list_fields, list_ref_fields, update_rule, delete_rule) ' +
      'VALUES ( ' +
      '  ''DBS_TMP_INV_SALDO'', ' +
      '  ''GD_CONTACT'', ' +
      '  ''DBS_1INV_FK_MOVEMENT_CK'', ' +
      '  ''CONTACTKEY'', ''ID'', ''RESTRICT'', ''RESTRICT'')';
    ExecSqlLogEvent(q, 'SaveMetadata');

    Tr.Commit;
    LogEvent('Metadata saved.');
  finally
    q.Free;
    Tr.Free;
  end;
end;

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
  ///    '      JOIN DBS_TMP_PROCESSED_TABLES p ON p.relation_name = t.RDB$RELATION_NAME ' +  #13#10 +
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
 ///     '      JOIN DBS_TMP_PROCESSED_TABLES p ON p.relation_name = i.RDB$RELATION_NAME ' +  #13#10 +
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
{      'EXECUTE BLOCK ' +                                                                       #13#10 +
      'AS ' +                                                                                  #13#10 +
      '  DECLARE VARIABLE S VARCHAR(16384); ' +                                                #13#10 +
      'BEGIN ' +                                                                               #13#10 +
      '  FOR ' +                                                                               #13#10 +
      '    SELECT ''ALTER TABLE '' || c.relation_name || '' ADD CONSTRAINT '' || ' +             #13#10 +
      '      c.constraint_name || '' '' || c.constraint_type ||'' ('' || c.list_fields || '') '' ' + #13#10 +
      '    FROM dbs_pk_unique_constraints c ' +                                                  #13#10 +
  ///    '      JOIN DBS_TMP_PROCESSED_TABLES p ON p.relation_name = c.RELATION_NAME ' +  #13#10 +
      '    WHERE c.relation_name NOT LIKE ''DBS_%'' ' +                   #13#10 +
      '    INTO :S ' +                                                  #13#10 +
      '  DO BEGIN ' +                                                   #13#10 +
      '    EXECUTE STATEMENT :S; ' +                                    #13#10 +  /// WITH AUTONOMOUS TRANSACTION
      '    when any DO ' +                                              #13#10 +
      '    BEGIN ' +                                                    #13#10 +
      '      IF (sqlcode <> 0) THEN ' +                                 #13#10 +
      '        S = S || '' An SQL error occurred!''; ' +                #13#10 +
      '      ELSE ' +                                                   #13#10 +
      '        S = S || '' Something bad happened!''; ' +               #13#10 +
      '      SUSPEND; --exception ex_custom S; ' +                      #13#10 +
      '    END ' +                                                      #13#10 +
      '  END ' +                                                        #13#10 +
      'END';        }


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
  /// '      JOIN DBS_TMP_PROCESSED_TABLES p ON p.relation_name = c.RELATION_NAME ' +                #13#10 +
      '    WHERE ' +                                                                                 #13#10 +
      '      c.relation_name NOT LIKE ''DBS_%'' ' +                   			             #13#10 +
      ////////////////////
      '      AND NOT EXISTS( ' +                                                        	     #13#10 +
      '        SELECT * ' + 									     #13#10 +
      '        FROM dbs_fk_constraints cc ' +							     #13#10 +
      '        WHERE ' +									     #13#10 +
      '          cc.ref_relation_name = c.relation_name ' +					     #13#10 +
      '          AND cc.delete_rule IN(''SET NULL'', ''SET DEFAULT'') ' +                            #13#10 +
      '          AND cc.constraint_name NOT LIKE ''RDB$%'' ' +               			     #13#10 +
      '      ) ' +                                                                                   #13#10 +
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
     /// '      JOIN DBS_TMP_PROCESSED_TABLES p ON p.relation_name = c.RELATION_NAME ' +  #13#10 +
      '    WHERE ' +                                                                                #13#10 +
      '      c.constraint_name NOT LIKE ''DBS_%'' ' +                                               #13#10 +
      ////////////////////
      '      AND c.delete_rule NOT IN(''SET NULL'', ''SET DEFAULT'') ' +                            #13#10 +
      ///////////////////
      '      AND NOT EXISTS( ' +                                                                    #13#10 +
      '        SELECT tmp.constraint_name ' +                                                       #13#10 +
      '        FROM dbs_tmp_fk_constraints tmp ' +                                                  #13#10 +
      '        WHERE tmp.constraint_name = c.constraint_name ' +                                    #13#10 +
      '      )' +                                                                                   #13#10 +
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
///      RestoreIndices;        //test
      RestorePkUniqueConstraints;
      RestoreFKConstraints;
      RestoreTriggers;///

      q.SQL.Text :=
        'ALTER TABLE DBS_TMP_PK_HASH DROP CONSTRAINT PK_DBS_TMP_PK_HASH';
      ExecSqlLogEvent(q, 'DeleteDocuments_DeleteHIS'); 
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

procedure TgsDBSqueeze.SetItemsCbbEvent;
var
  Tr: TIBTransaction;
  q: TIBSQL;
  CompaniesList: TStringList;  // Список компаний, по которым ведется учет
begin
  Assert(Connected and Assigned(FOnSetItemsCbbEvent));

  CompaniesList := TStringList.Create;
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);

  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT ' +                                                       #13#10 +
      '  TRIM(gc.fullname || '' | '' || go.companykey) AS CompName ' +  #13#10 +
      'FROM gd_ourcompany go ' +                                        #13#10 +
      '  JOIN GD_COMPANY gc ' +                                         #13#10 +
      '    ON go.companykey = gc.contactkey ';
    ExecSqlLogEvent(q, 'SetItemsCbbEvent');
    while not q.EOF do
    begin
      CompaniesList.Add(q.FieldByName('CompName').AsString);
      q.Next;
    end;

    FOnSetItemsCbbEvent(CompaniesList);
    q.Close;
    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
    CompaniesList.Free;
  end;
end;

procedure TgsDBSqueeze.LogEvent(const AMsg: String);
var
  PI: TgdProgressInfo;
begin
  if Assigned(FOnProgressWatch) then
  begin
    PI.State := psMessage;
    PI.Message := AMsg;
    FOnProgressWatch(Self, PI);
  end;
end;

procedure TgsDBSqueeze.ExecSqlLogEvent(const AnIBSQL: TIBSQL; const AProcName: String; const AParamValuesStr: String = '');
const
  Ms = 1 / (24 * 60 * 60 * 1000); // Значение 1 миллисекунды в формате TDateTime
var
  StartDT: TDateTime;
  Start, Stop: Extended;
  Time : TDateTime;
  TimeStr: String;
  Hour, Min, Sec, Milli: Word;
begin
  TimeStr := '';
  FOnLogSQLEvent('Procedure: ' + AProcName);
  FOnLogSQLEvent(Trim(AnIBSQL.SQL.Text));
  if AParamValuesStr <> '' then
    FOnLogSQLEvent('Parameters: ' + AParamValuesStr);

  StartDT := Now;
  FOnLogSQLEvent('Begin Time: ' + FormatDateTime('h:nn:ss:zzz', StartDT));
  Start := GetTickCount;
  try
    AnIBSQL.ExecQuery;
  except
    on E: Exception do
    begin
      LogEvent('ERROR in procedure: ' + AProcName);
      LogEvent('ERROR SQL: ' + Trim(AnIBSQL.SQL.Text));
      if AParamValuesStr <> '' then
        LogEvent('Parameters: ' + AParamValuesStr);
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

procedure TgsDBSqueeze.FuncTest(const AFuncName: String; const ATr: TIBTransaction);
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

procedure TgsDBSqueeze.CreateMetadata;
var
  q: TIBSQL;
  q2: TIBSQL;
  Tr: TIBTransaction;

  procedure CreateDBSTmpProcessedTbls;
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
  end;

  procedure CreateDBSTmpRebindInvCards;
  begin
    if RelationExist2('DBS_TMP_REBIND_INV_CARDS', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM dbs_tmp_rebind_inv_cards';
      ExecSqlLogEvent(q, 'CreateDBSTmpRebindInvCards');
      LogEvent('Table DBS_TMP_REBIND_INV_CARDS exists.');
    end
    else begin
      q.SQL.Text :=
        'CREATE TABLE DBS_TMP_REBIND_INV_CARDS ( ' +    #13#10 +
        '  CUR_CARDKEY       INTEGER, ' +               #13#10 +
        '  NEW_CARDKEY       INTEGER, ' +               #13#10 +
        '  CUR_FIRST_DOCKEY  INTEGER, ' +               #13#10 +
        '  FIRST_DOCKEY      INTEGER, ' +               #13#10 +
        '  FIRST_DATE        DATE, ' +                  #13#10 +
        '  CUR_RELATION_NAME VARCHAR(31)) ';
      ExecSqlLogEvent(q, 'CreateDBSTmpRebindInvCards');
      LogEvent('Table DBS_TMP_REBIND_INV_CARDS has been created.');
    end;
  end;

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
        '  COMPANYKEY   INTEGER, ' +                    #13#10 +
        '  CURRKEY      INTEGER, ' +                    #13#10 +
        '  ACCOUNTKEY   INTEGER, ' +                    #13#10 +
        '  MASTERDOCKEY INTEGER, ' +                    #13#10 +
        '  DOCUMENTKEY  INTEGER, ' +                    #13#10 +
        '  RECORDKEY    INTEGER, ' +                    #13#10 +
        '  ACCOUNTPART  VARCHAR(1), ' +                 #13#10 +
        '  CREDITNCU    DECIMAL(15,4), ' +              #13#10 +
        '  CREDITCURR   DECIMAL(15,4), ' +              #13#10 +
        '  CREDITEQ     DECIMAL(15,4), ' +              #13#10 +
        '  DEBITNCU     DECIMAL(15,4), ' +              #13#10 +
        '  DEBITCURR    DECIMAL(15,4), ' +              #13#10 +
        '  DEBITEQ      DECIMAL(15,4), ';
      if q2.RecordCount <> 0 then
        q.SQL.Add(' ' +                                 #13#10 +
          q2.FieldByName('AllUsrFieldsList').AsString + ', ');

      q.SQL.Add(' ' +                                   #13#10 +
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
        '  ID_DOCUMENT   INTEGER, ' +                   #13#10 +
        '  ID_PARENTDOC  INTEGER, ' +                   #13#10 +
        '  ID_CARD       INTEGER, ' +                   #13#10 +
        '  ID_MOVEMENT_D INTEGER, ' +                   #13#10 +
        '  ID_MOVEMENT_C INTEGER, ' +                   #13#10 +
        '  CONTACTKEY    INTEGER, ' +                   #13#10 +
        '  GOODKEY       INTEGER, ' +                   #13#10 +
        '  COMPANYKEY    INTEGER, ' +                   #13#10 +
        '  BALANCE       DECIMAL(15,4), ' +             #13#10 +
        '  constraint PK_DBS_TMP_INV_SALDO primary key (ID_DOCUMENT))';
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

  procedure CreateDBSFKConstraints;
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

  procedure CreateDBSTmpFKConstraints;
  begin
    if RelationExist2('DBS_TMP_FK_CONSTRAINTS', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM dbs_tmp_fk_constraints';
      ExecSqlLogEvent(q, 'CreateDBSTmpFKConstraints');
      LogEvent('Table DBS_TMP_FK_CONSTRAINTS exists.');
    end
    else begin
      q.SQL.Text :=
        'CREATE TABLE DBS_TMP_FK_CONSTRAINTS ( ' +      #13#10 +
        '  CONSTRAINT_NAME   CHAR(40), ' +              #13#10 +
        '  RELATION_NAME     CHAR(31), ' +              #13#10 +
        '  LIST_FIELDS       VARCHAR(8192), ' +         #13#10 +
        '  REF_RELATION_NAME CHAR(31), ' +              #13#10 +
        '  LIST_REF_FIELDS   VARCHAR(8192), ' +         #13#10 +
        '  UPDATE_RULE       CHAR(11), ' +              #13#10 +
        '  DELETE_RULE       CHAR(11), ' +              #13#10 +
        '  constraint PK_DBS_TMP_FK_CONSTRAINTS primary key (CONSTRAINT_NAME))';
      ExecSqlLogEvent(q, 'CreateDBSTmpFKConstraints');
      LogEvent('Table DBS_TMP_FK_CONSTRAINTS has been created.');
    end;
  end;

  procedure CreateDBSTmp2FKConstraints;
  begin
    if RelationExist2('DBS_TMP2_FK_CONSTRAINTS', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM dbs_tmp2_fk_constraints';
      ExecSqlLogEvent(q, 'CreateDBSTmp2FKConstraints');
      LogEvent('Table DBS_TMP2_FK_CONSTRAINTS exists.');
    end
    else begin
      q.SQL.Text :=
        'CREATE TABLE DBS_TMP2_FK_CONSTRAINTS ( ' +     #13#10 +
        '  CONSTRAINT_NAME   CHAR(40), ' +              #13#10 +
        '  RELATION_NAME     CHAR(31), ' +              #13#10 +
        '  LIST_FIELDS       VARCHAR(8192), ' +         #13#10 +
        '  REF_RELATION_NAME CHAR(31), ' +              #13#10 +
        '  LIST_REF_FIELDS   VARCHAR(8192), ' +         #13#10 +
        '  UPDATE_RULE       CHAR(11), ' +              #13#10 +
        '  DELETE_RULE       CHAR(11), ' +              #13#10 +
        '  constraint PK_DBS_TMP2_FK_CONSTRAINTS primary key (CONSTRAINT_NAME))';
      ExecSqlLogEvent(q, 'CreateDBSTmp2FKConstraints');
      LogEvent('Table DBS_TMP2_FK_CONSTRAINTS has been created.');
    end;
  end;

  procedure CreateDBSTmpPkHash;
  begin
    if RelationExist2('DBS_TMP_PK_HASH', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM dbs_tmp_pk_hash';
      ExecSqlLogEvent(q, 'CreateDBSTmpPkHash');
      LogEvent('Table DBS_TMP_FK_CONSTRAINTS exists.');
    end
    else begin
      q.SQL.Text :=
        'CREATE TABLE DBS_TMP_PK_HASH ( ' +             #13#10 +
        '  PK            INTEGER  not null,  ' +        #13#10 +
        '  RELATION_NAME CHAR(31) not null, ' +         #13#10 +
        '  PK_HASH       BIGINT, ' +                    #13#10 +
        '  PK_FIELD      CHAR(31), ' +                  #13#10 +
        '  constraint PK_DBS_TMP_PK_HASH primary key (PK, RELATION_NAME) using index DBS_IX_DBS_TMP_PK_HASH) ';
      ExecSqlLogEvent(q, 'CreateDBSTmpPkHash');
      LogEvent('Table DBS_TMP_PK_HASH has been created.');
    end;
  end;

  procedure CreateDBSTmpHIS2;
  begin
    if RelationExist2('DBS_TMP_HIS_2', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM DBS_TMP_HIS_2';
      ExecSqlLogEvent(q, 'CreateDBSTmpHIS2');
      LogEvent('Table DBS_TMP_HIS_2 exists.');
    end
    else begin
      q.SQL.Text :=
        'CREATE TABLE DBS_TMP_HIS_2 ( ' +               #13#10 +
        '  PK            INTEGER  not null,  ' +        #13#10 +
        '  RELATION_NAME CHAR(31) not null, ' +         #13#10 +
        '  PK_HASH       BIGINT, ' +                    #13#10 +
        '  PK_FIELD      CHAR(31), ' +                  #13#10 +
        '  constraint PK_DBS_TMP_HIS_2 primary key (PK, RELATION_NAME) using index DBS_IX_DBS_TMP_HIS_2) ';
      ExecSqlLogEvent(q, 'CreateDBSTmpHIS2');
      LogEvent('Table PK_DBS_TMP_HIS_2 has been created.');
    end;
  end;

  procedure CreateUDFs;
  begin
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
    except
      on E: Exception do
      begin
        Tr.Rollback;
        raise EgsDBSqueeze.Create(E.Message);
      end;
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

    CreateDBSTmpProcessedTbls;
    CreateDBSTmpPkHash;
    CreateDBSTmpAcSaldo;
    CreateDBSTmpInvSaldo;
    CreateDBSTmpRebindInvCards;

    CreateDBSInactiveTriggers;
    CreateDBSInactiveIndices;
    CreateDBSPkUniqueConstraints;
    CreateDBSSuitableTables;
    CreateDBSFKConstraints;

    CreateDBSTmpFKConstraints;
    CreateDBSTmp2FKConstraints;
    CreateDBSTmpHIS2;

    CreateUDFs;

    Tr.Commit;
    LogEvent('Creating metadata... OK');
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
end;

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

      FOnUsedDBEvent(
        q.FieldByName('FUNCTIONKEY').AsInteger,
        q.FieldByName('STATE').AsInteger,
        q.FieldByName('CALL_TIME').AsString,
        q.FieldByName('ERROR_MESSAGE').AsString
      );

      q.Close;
    end;
    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.GetDBSizeEvent;                                          

  function BytesToStr(const i64Size: Int64): String;
  const
    i64GB = 1024 * 1024 * 1024;
    i64MB = 1024 * 1024;
    i64KB = 1024;
  begin
    if i64Size div i64GB > 0 then
      Result := Format('%.2f GB', [i64Size / i64GB])
    else if i64Size div i64MB > 0 then
      Result := Format('%.2f MB', [i64Size / i64MB])
    else if i64Size div i64KB > 0 then
      Result := Format('%.2f KB', [i64Size / i64KB])
    else
      Result := IntToStr(i64Size) + ' Byte(s)';
  end;

  function GetFileSize(ADatabaseName: String): Int64;
{  var
    Handle: tHandle;
    FindData: tWin32FindData;
    DatabaseName: String;    // Полное название файла, размер которого определяем
  begin
    Result := -1;
    if  AnsiPos('localhost:', ADatabaseName) <> 0 then
      DatabaseName := StringReplace(ADatabaseName, 'localhost:', '', [rfIgnoreCase])
    else
      DatabaseName := ADatabaseName;
    Handle := FindFirstFile(PChar(DatabaseName), FindData);
    if Handle = INVALID_HANDLE_VALUE then
    begin
      raise EgsDBSqueeze.Create('Error: FindFirstFile returned Handle = INVALID_HANDLE_VALUE');
    end
    else begin
      Windows.FindClose(Handle);
      if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
        Result := 0  // Размер каталога всегда считаем равным 0
      else begin
        Int64Rec(Result).Hi := FindData.nFileSizeHigh;
        Int64Rec(Result).Lo := FindData.nFileSizeLow;
      end;
    end;
  end;  }
  var
  SearchRecord : TSearchRec;
  DatabaseName: String;
  begin
    Result := -1;
    if  AnsiPos('localhost:', ADatabaseName) <> 0 then
      DatabaseName := StringReplace(ADatabaseName, 'localhost:', '', [rfIgnoreCase])
    else
      DatabaseName := ADatabaseName;
    if FindFirst(DatabaseName, faAnyFile, SearchRecord) = 0 then
      try
        Result := (SearchRecord.FindData.nFileSizeHigh * Int64(MAXDWORD)) + SearchRecord.FindData.nFileSizeLow;
      finally
        FindClose(SearchRecord);
      end;
  end;   

var
  FileSize: Int64;  // Размер файла в байтах
begin
  FileSize := GetFileSize(FDatabaseName);

  FOnGetDBSizeEvent(BytesToStr(FileSize));
end;

procedure TgsDBSqueeze.GetStatisticsEvent;
var
  q1, q2, q3, q4: TIBSQL;
  Tr: TIBTransaction;
begin
  LogEvent('Getting statistics...');
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
    ExecSqlLogEvent(q2, 'GetStatisticsEvent');

    q3.SQL.Text :=
      'SELECT COUNT(id) AS Kolvo FROM inv_movement';
    ExecSqlLogEvent(q3, 'GetStatisticsEvent');

    q4.SQL.Text :=
      'SELECT COUNT(id) AS Kolvo FROM inv_card';
    ExecSqlLogEvent(q4, 'GetStatisticsEvent');

    FOnGetStatistics(
      q1.FieldByName('Kolvo').AsString,
      q2.FieldByName('Kolvo').AsString,
      q3.FieldByName('Kolvo').AsString,
      q4.FieldByName('Kolvo').AsString
    );

    Tr.Commit;
    LogEvent('Getting statistics... OK');
  finally
    q1.Free;
    q2.Free;
    q3.Free;
    q4.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.GetProcStatisticsEvent;                                  ///TODO: доделать
var
  q1, q2, q3, q4: TIBSQL;
  Tr: TIBTransaction;
  CompanyKey: Integer;
begin
  Assert(Connected);
  LogEvent('Getting processing statistics...');

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

    if FOnlyCompanySaldo then
    begin
      q1.SQL.Text :=
        'SELECT contactkey AS CompanyKey ' +            #13#10 +
        'FROM gd_company ' +                            #13#10 +
        'WHERE fullname = :CompanyName ';
      q1.ParamByName('CompanyName').AsString := FCompanyName;
      ExecSqlLogEvent(q1, 'GetProcStatisticsEvent', Format('CompanyName = %s', [FCompanyName]));

      CompanyKey := q1.FieldByName('CompanyKey').AsInteger;
      q1.Close;
    end;

    q1.SQL.Text :=
      'SELECT COUNT(doc.id) AS Kolvo ' +                #13#10 +
      'FROM gd_document doc ' +                         #13#10 +
      'WHERE doc.documentdate < :ClosingDate ';
    if FOnlyCompanySaldo then
    begin                                               
      q1.SQL.Add(' ' +                                  #13#10 +
        'AND (doc.companykey = :Companykey) ');
      q1.ParamByName('Companykey').AsInteger := CompanyKey;
    end;
    q1.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    ExecSqlLogEvent(q1, 'GetProcStatisticsEvent');

   {q2.SQL.Text :=
      'SELECT COUNT(ae.id) AS Kolvo ' +
      'FROM AC_ENTRY ae ' +
      'WHERE (ae.documentkey IN (SELECT doc.id FROM gd_document doc WHERE doc.documentdate < :ClosingDate)) OR ' +
      '  (ae.masterdockey  IN (SELECT doc.id FROM gd_document doc WHERE doc.documentdate < :ClosingDate)) ';
    q2.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    ExecSqlLogEvent(q2, 'GetProcStatisticsEvent');       }

    q2.SQL.Text :=
      'SELECT COUNT(ae.id) AS Kolvo ' +                 #13#10 +
      'FROM ac_entry ae ' +                             #13#10 +
      'WHERE (ae.entrydate < :ClosingDate) ';
    if FOnlyCompanySaldo then
    begin
      q2.SQL.Add(' ' +                                  #13#10 +
        'AND (ae.companykey = :Companykey) ');
      q2.ParamByName('Companykey').AsInteger := CompanyKey;
    end;
    q2.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    ExecSqlLogEvent(q2, 'GetProcStatisticsEvent');

  {  q3.SQL.Text :=
      'SELECT COUNT(im.id) AS Kolvo ' +
      'FROM INV_MOVEMENT im ' +
      'WHERE (im.documentkey IN (SELECT doc.id FROM gd_document doc WHERE doc.documentdate < :ClosingDate)) ';
    q3.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    ExecSqlLogEvent(q3, 'GetProcStatisticsEvent');   }

    q3.SQL.Text :=
      'SELECT COUNT(im.id) AS Kolvo ' +                 #13#10 +
      'FROM ' +                                         #13#10 +
      '  inv_movement im ' +                            #13#10 +
      '  JOIN INV_CARD ic ON im.cardkey = ic.id ' +     #13#10 +
      'WHERE ' +                                        #13#10 +
      '  im.movementdate < :ClosingDate ' +             #13#10 +
      '  AND im.disabled = 0 ';
    if FOnlyCompanySaldo then
    begin
      q3.SQL.Add(' ' +                                  #13#10 +
        'AND ic.companykey = :CompanyKey ');
      q3.ParamByName('Companykey').AsInteger := CompanyKey;
    end;
    q3.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    ExecSqlLogEvent(q3, 'GetProcStatisticsEvent');

    q4.SQL.Text :=
      'SELECT COUNT(ic.id) AS Kolvo ' +                  #13#10 +
      'FROM inv_card ic ' +                              #13#10 +
      'WHERE ' +                                         #13#10 +
      '  ic.documentkey IN (' +                          #13#10 +
      '    SELECT doc.id ' +                             #13#10 +
      '    FROM gd_document doc ' +                      #13#10 +
      '    WHERE doc.documentdate < :ClosingDate ' +
      '  ) ';
    q4.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    ExecSqlLogEvent(q4, 'GetProcStatisticsEvent');

    FOnGetProcStatistics(
      q1.FieldByName('Kolvo').AsString,
      q2.FieldByName('Kolvo').AsString,
      q3.FieldByName('Kolvo').AsString,
      q4.FieldByName('Kolvo').AsString
    );

    Tr.Commit;
    LogEvent('Getting processing statistics... OK');
  finally
    q1.Free;
    q2.Free;
    q3.Free;
    q4.Free;
    Tr.Free;
  end;
end;

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

procedure TgsDBSqueeze.GetInfoTestConnectEvent;                                 ///TODO: определиться с минимальной версией (2.1)
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

procedure TgsDBSqueeze.ClearDBSTables;
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
      'DELETE FROM DBS_TMP_PK_HASH';
    ExecSqlLogEvent(q, 'ClearDBSTables');

    q.SQL.Text :=
      'DELETE FROM DBS_TMP_HIS_2';
    ExecSqlLogEvent(q, 'ClearDBSTables');

    q.SQL.Text :=
      'DELETE FROM DBS_FK_CONSTRAINTS';
    ExecSqlLogEvent(q, 'ClearDBSTables');

    q.SQL.Text :=
      'DELETE FROM DBS_INACTIVE_INDICES';
    ExecSqlLogEvent(q, 'ClearDBSTables');

    q.SQL.Text :=
      'DELETE FROM DBS_INACTIVE_TRIGGERS';
    ExecSqlLogEvent(q, 'ClearDBSTables');

    q.SQL.Text :=
      'DELETE FROM DBS_PK_UNIQUE_CONSTRAINTS';
    ExecSqlLogEvent(q, 'ClearDBSTables');

    q.SQL.Text :=
      'DELETE FROM DBS_SUITABLE_TABLES';
    ExecSqlLogEvent(q, 'ClearDBSTables');

    q.SQL.Text :=
      'DELETE FROM DBS_TMP_AC_SALDO';
    ExecSqlLogEvent(q, 'ClearDBSTables');

    q.SQL.Text :=
      'DELETE FROM DBS_TMP2_FK_CONSTRAINTS';
    ExecSqlLogEvent(q, 'ClearDBSTables');

    q.SQL.Text :=
      'DELETE FROM DBS_TMP_INV_SALDO';
    ExecSqlLogEvent(q, 'ClearDBSTables');

    q.SQL.Text :=
      'DELETE FROM DBS_TMP_REBIND_INV_CARDS';
    ExecSqlLogEvent(q, 'ClearDBSTables');

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;


end.
