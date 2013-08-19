unit gsDBSqueeze_unit;

interface

uses
  Windows, SysUtils, IB, IBDatabase, IBSQL, Classes, gd_ProgressNotifier_unit;

type
  TActivateFlag = (aiActivate, aiDeactivate);

  TOnLogEvent = procedure(const S: String) of object;
  TOnSetItemsCbbEvent = procedure(const ACompanies: TStringList) of object;
  TOnGetDBSizeEvent = procedure(const ADBSize: String) of object;
  TOnGetStatistics = procedure(const AnGdDoc: String; const AnAcEntry: String; const AnInvMovement: String) of object;

  EgsDBSqueeze = class(Exception);

  TgsDBSqueeze = class(TObject)
  private
    FCompanyName: String;
    FDatabaseName: String;
    FClosingDate: TDateTime;
    FIBDatabase: TIBDatabase;
    FOnProgressWatch: TProgressWatchEvent;
    FOnSetItemsCbbEvent: TOnSetItemsCbbEvent;
    FOnGetDBSizeEvent: TOnGetDBSizeEvent;
    FOnGetStatistics: TOnGetStatistics;
    FPassword: String;
    FUserName: String;

    FAllOurCompaniesSaldo: Boolean;
    FOnlyCompanySaldo: Boolean;

    FCurUserContactKey: Integer;
    
    FEntryAnalyticsStr: String; // список всех бухгалтерских аналитик  
    FCardFeaturesStr: String;   // cписок полей-признаков складской карточки

    procedure LogEvent(const AMsg: String);
    procedure LogSQL(const AnIBSQL: TIBSQL);

    function GetNewID: Integer;
    function GetConnected: Boolean;

    function CreateHIS(AnIndex: Integer): Integer;
    function DestroyHIS(AnIndex: Integer): Integer;

  public
    constructor Create;
    destructor Destroy; override;

    procedure CreateDBSStateJournal;
    procedure SetFVariables;

    procedure SaveMetadata;
    
    procedure Connect(ANoGarbageCollect: Boolean; AOffForceWrite: Boolean);
    procedure Disconnect;
    procedure Reconnect(ANoGarbageCollect: Boolean; AOffForceWrite: Boolean);

    // подсчет бухгалтерского сальдо
    procedure CalculateAcSaldo;
    // формирование бухгалтерского сальдо
    procedure CreateAcEntries;

    // подсчет складских остатков
    procedure CalculateInvSaldo;
    // формирование складских остатков
    procedure CreateInvSaldo;

    procedure PrepareRebindInvCards;
    procedure RebindInvCards;

    // удаление старого бух сальдо
    procedure DeleteOldAcEntryBalance;

    procedure CreateHIS_IncludeInHIS;
    procedure DeleteDocuments_DeleteHIS;

    procedure PrepareDB;
    procedure RestoreDB;
    procedure SetItemsCbbEvent;
    procedure GetDBSizeEvent;
    procedure GetStatisticsEvent;
    procedure CreateMetadata;

    property AllOurCompaniesSaldo: Boolean read FAllOurCompaniesSaldo write FAllOurCompaniesSaldo;
    property OnlyCompanySaldo: Boolean read FOnlyCompanySaldo write FOnlyCompanySaldo;

    property CompanyName: String read FCompanyName write FCompanyName;
    property Connected: Boolean read GetConnected;
    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property ClosingDate: TDateTime read FClosingDate
      write FClosingDate;
    property OnProgressWatch: TProgressWatchEvent read FOnProgressWatch
      write FOnProgressWatch;
    property OnSetItemsCbbEvent: TOnSetItemsCbbEvent read FOnSetItemsCbbEvent
      write FOnSetItemsCbbEvent;
    property OnGetDBSizeEvent: TOnGetDBSizeEvent read FOnGetDBSizeEvent
      write FOnGetDBSizeEvent;
    property OnGetStatistics: TOnGetStatistics read FOnGetStatistics
      write FOnGetStatistics;
    property Password: String read FPassword write FPassword;
    property UserName: String read FUserName write FUserName;
  end;

implementation

uses
  mdf_MetaData_unit, gdcInvDocument_unit, contnrs, IBQuery;

{ TgsDBSqueeze }

constructor TgsDBSqueeze.Create;
begin
  inherited;
  FIBDatabase := TIBDatabase.Create(nil);

end;

destructor TgsDBSqueeze.Destroy;
begin
  if Connected then
    Disconnect;
  FIBDatabase.Free;
  inherited;
end;

procedure TgsDBSqueeze.Connect(ANoGarbageCollect: Boolean; AOffForceWrite: Boolean);
var
  Tr: TIBTransaction;
  q: TIBSQL;
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
  LogEvent('Connecting to DB... OK');

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text := 'SELECT * FROM mon$database';
    q.ExecQuery;
    LogEvent('MON$PAGE_SIZE = ' + q.FieldByName('mon$page_size').AsString);
    LogEvent('MON$PAGE_BUFFERS = ' + q.FieldByName('mon$page_buffers').AsString);
    LogEvent('MON$FORCED_WRITES = ' + q.FieldByName('mon$forced_writes').AsString);

    q.Close;
    q.SQL.Text := 'SELECT * FROM mon$attachments WHERE mon$attachment_id = CURRENT_CONNECTION';
    q.ExecQuery;
    LogEvent('MON$GARBAGE_COLLECTION = ' + q.FieldByName('mon$garbage_collection').AsString);
  finally
    q.Free;
    Tr.Free;
  end;
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
  FIBDatabase.Connected := False;
  LogEvent('Disconnecting from DB... OK');
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
      'SELECT ' +
      '  gu.contactkey AS CurUserContactKey ' +
      'FROM ' +
      '  GD_USER gu ' +
      'WHERE ' +
      '  gu.ibname = CURRENT_USER';
    q.ExecQuery;

    if q.EOF then
      raise EgsDBSqueeze.Create('Invalid GD_USER data');

    FCurUserContactKey := q.FieldByName('CurUserContactKey').AsInteger;
    q.Close;

    q.SQL.Text :=
      'SELECT LIST( ' +
      '  TRIM(rf.rdb$field_name)) AS UsrFieldsList ' +
      'FROM ' + 
      '  rdb$relation_fields rf ' +
      'WHERE ' +
      '  rf.rdb$relation_name = ''AC_ACCOUNT'' ' +
      '  AND rf.rdb$field_name LIKE ''USR$%'' ';
    q.ExecQuery;

    FEntryAnalyticsStr := q.FieldByName('UsrFieldsList').AsString;
    q.Close;

    q.SQL.Text :=
      'SELECT LIST( ' + 
      ' TRIM(rf.rdb$field_name)) AS UsrFieldsList ' +
      'FROM ' + 
      '  rdb$relation_fields rf ' +
      'WHERE ' + 
      '  rf.rdb$relation_name = ''INV_CARD'' ' +
      '  AND rf.rdb$field_name LIKE ''USR$%'' ';
    q.ExecQuery;

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
  Result := -1;
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;

    q.SQL.Text :=
      'SELECT ' +
      '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0) AS NewID ' +
      'FROM ' +
      '  rdb$database ';
    q.ExecQuery;

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
        'CREATE TABLE DBS_JOURNAL_STATE( ' +
        '  FUNCTIONKEY   INTEGER, ' +
        '  STATE         SMALLINT, ' +        //1-успешно,0-ошибка, NULL-выполнение было прервано пользователем
        '  CALL_TIME     TIMESTAMP, ' +
        '  ERROR_MESSAGE VARCHAR(32000), ' +
        '  CONSTRAINT PK_DBS_PRIMARY KEY (ID))';
      q.ExecQuery;
      LogEvent('Table DBS_FK_CONSTRAINTS has been created.');
    end
    else begin
      q.SQL.Text:=
        'SELECT COUNT(*) FROM DBS_JOURNAL_STATE';
      q.ExecQuery;
      if q.RecordCount <> 0 then
      begin
        //IsUsedDB := True;
        ///CREATE EVENT!
        q.Close;
        q.SQL.Text :=
          'SELECT * FROM DBS_JOURNAL_STATE ORDER BY CALL_TIME DESC';
        q.ExecQuery;  
      //////TODO: сигнал на форму! продолжить или заново
      /// отправим все данные последней записи
      end;
      q.Close;
    end;

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;

end;

procedure TgsDBSqueeze.CalculateAcSaldo;  // подсчет бухгалтерского сальдо
var
  q2, q3: TIBSQL;
  Tr, Tr2: TIBTransaction;
  I: Integer;

  OstatkiAccountKey: Integer;
  AvailableAnalyticsList: TStringList;  // cписок активных аналитик для счета

  CompanyKey: Integer;
  OurCompaniesListStr: String;
  OurCompany_EntryDocList, TmpList: TStringList;
begin
  LogEvent('Calculating entry balance...');
  Assert(Connected);

  TmpList := TStringList.Create;
  AvailableAnalyticsList := TStringList.Create;
  OurCompany_EntryDocList := TStringList.Create; // список "компания=документ для проводок"

  q2 := TIBSQL.Create(nil);
  q3 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  Tr2 := TIBTransaction.Create(nil);
  try
    Tr2.DefaultDatabase := FIBDatabase;
    Tr2.StartTransaction;
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q2.Transaction := Tr;
    q3.Transaction := Tr;

    if FAllOurCompaniesSaldo then
    begin
      q2.SQL.Text :=
        'SELECT LIST(companykey) AS OurCompaniesList ' +
        'FROM gd_ourcompany';
      q2.ExecQuery;

      OurCompaniesListStr := q2.FieldByName('OurCompaniesList').AsString;
      LogEvent('[test] OurCompaniesList: ' + OurCompaniesListStr);
      q2.Close;

      TmpList.Text := StringReplace(OurCompaniesListStr, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
      for I := 0 to TmpList.Count-1 do
        OurCompany_EntryDocList.Append(TmpList[I] + '=' + IntToStr(GetNewID));

      TmpList.Clear;  
    end
    else if FOnlyCompanySaldo then
    begin
      q2.SQL.Text :=
        'SELECT contactkey AS CompanyKey ' +
        'FROM GD_COMPANY gc ' +
        'WHERE fullname = :CompanyName ';
      q2.ParamByName('CompanyName').AsString := FCompanyName;
      q2.ExecQuery;

      CompanyKey := q2.FieldByName('CompanyKey').AsInteger;
      q2.Close;
    end;

    q2.SQL.Text :=
      'SELECT ' +
      '  aac.id  AS OstatkiAccountKey ' +
      'FROM AC_ACCOUNT aac ' +
      'WHERE ' +
      '  aac.fullname = ''00 Остатки'' ';
    q2.ExecQuery;
    OstatkiAccountKey := q2.FieldByName('OstatkiAccountKey').AsInteger;
    q2.Close;
    //-------------------------------------------- вычисление сальдо для счета
    // получаем счета
    q2.SQL.Text :=
      'SELECT DISTINCT ' +
      '  ae.accountkey AS id, ' +
         StringReplace(FEntryAnalyticsStr, 'USR$', 'ac.USR$', [rfReplaceAll, rfIgnoreCase]) + ' ' +
      'FROM AC_ENTRY ae ' +
      '  JOIN AC_ACCOUNT ac ON ae.accountkey = ac.id ' +
      'WHERE ' +
      '  ae.entrydate < :EntryDate ';
    if FOnlyCompanySaldo then
      q2.SQL.Add(
        'AND ae.companykey = :CompanyKey ')
    else if FAllOurCompaniesSaldo then
      q2.SQL.Add(' ' +
        'AND ae.companykey IN (' + OurCompaniesListStr + ') ');

    q2.ParamByName('EntryDate').AsDateTime := FClosingDate;                     ///TODO: проверить
    if FOnlyCompanySaldo then
      q2.ParamByName('CompanyKey').AsInteger := CompanyKey;
    LogEvent('[test] SELECT account begin');
    q2.ExecQuery;
    LogEvent('[test] SELECT account end');


    // считаем и сохраняем сальдо для каждого счета
    while (not q2.EOF) do 
    begin
      LogEvent('[test] acc++');

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
        'INSERT INTO DBS_TMP_AC_SALDO ( ' +
        '  documentkey, masterdockey, ' +
        '  accountkey, ' +
        '  accountpart, ' +
        '  recordkey, ' +
        '  id, ' +
        '  companykey, ' +
        '  currkey, ' +
        '  creditncu, ' +
        '  creditcurr, ' +
        '  crediteq, ' +
        '  debitncu, ' +
        '  debitcurr, ' +
        '  debiteq ';
      for I := 0 to AvailableAnalyticsList.Count - 1 do
        q3.SQL.Add(', ' + AvailableAnalyticsList[I]);

      q3.SQL.Add(
        ') ' +
        'SELECT ');   // CREDIT

      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +     // documentkey = masterkey
          'GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ')
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
          q3.SQL.Add(' ' +
            'WHEN ' + OurCompany_EntryDocList.Names[I] + ' THEN ' + OurCompany_EntryDocList.Values[OurCompany_EntryDocList.Names[I]]);
        end;
        q3.SQL.Add(' ' +
          'END, ');
      end;

      q3.SQL.Add(
        '  accountkey, ' +
        '  ''C'', ' +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' +
        '  companykey, ' +
        '  currkey, ' +
        '  ABS(SUM(debitncu)  - SUM(creditncu)), ' +
        '  ABS(SUM(debitcurr) - SUM(creditcurr)), ' +
        '  ABS(SUM(debiteq)   - SUM(crediteq)), ' +
        '  0.0000 , ' + 
        '  0.0000 , ' +
        '  0.0000');
      for I := 0 to AvailableAnalyticsList.Count - 1 do
        q3.SQL.Add(', ' + AvailableAnalyticsList[I]);

      q3.SQL.Add(' ' +
        'FROM AC_ENTRY ' +
        'WHERE accountkey = :AccountKey ' +
        '  AND entrydate < :EntryDate ');
      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +
          'AND companykey = :CompanyKey ')
      else if FAllOurCompaniesSaldo then
        q3.SQL.Add(' ' +
          'AND companykey IN (' + OurCompaniesListStr + ') ');
      q3.SQL.Add(' ' +
        'GROUP BY ' +
        '  accountkey, ' +
        '  companykey, ' +
        '  currkey ');
      for I := 0 to AvailableAnalyticsList.Count - 1 do
        q3.SQL.Add(', ' + AvailableAnalyticsList[I]);
      q3.SQL.Add(' ' +
        'HAVING ' +
        '  (SUM(debitncu) - SUM(creditncu)) < 0.0000 ' +
        '   OR (SUM(debitcurr) - SUM(creditcurr)) < 0.0000 ' +
        '   OR (SUM(debiteq)   - SUM(crediteq))   < 0.0000 ' +

        'UNION ALL ' +   // DEBIT

        'SELECT ');
      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +
          'GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ')
      else if FAllOurCompaniesSaldo then
      begin       //documentkey   
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
        for i := 0 to OurCompany_EntryDocList.Count-1 do
        begin
          q3.SQL.Add(' ' +
            'WHEN ' + OurCompany_EntryDocList.Names[I] + ' THEN ' + OurCompany_EntryDocList.Values[OurCompany_EntryDocList.Names[I]]);
        end;
        q3.SQL.Add(' ' +
          'END, ');
      end;

      q3.SQL.Add(
        '  accountkey, ' +
        '  ''D'', ' +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' +
        '  companykey, ' +
        '  currkey, ' +
        '  0.0000, ' +
        '  0.0000, ' +
        '  0.0000, ' +
        '  ABS(SUM(debitncu)  - SUM(creditncu)), ' +
        '  ABS(SUM(debitcurr) - SUM(creditcurr)), ' +
        '  ABS(SUM(debiteq)   - SUM(crediteq)) ');
      for I := 0 to AvailableAnalyticsList.Count - 1 do
        q3.SQL.Add(', ' + AvailableAnalyticsList[I]);

      q3.SQL.Add( ' ' +
        'FROM AC_ENTRY ' +
        'WHERE accountkey = :AccountKey ' +
        '  AND entrydate < :EntryDate ');
      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +
          'AND companykey = :CompanyKey ')
      else if FAllOurCompaniesSaldo then
        q3.SQL.Add(' ' +
          'AND companykey IN (' + OurCompaniesListStr + ') ');
      q3.SQL.Add(' ' +
        'GROUP BY ' +
        '  accountkey, ' +
        '  companykey, ' +
        '  currkey ');
      for I := 0 to AvailableAnalyticsList.Count - 1 do
        q3.SQL.Add(', ' + AvailableAnalyticsList[I]);
      q3.SQL.Add(' ' +
        'HAVING ' +
        '  (SUM(debitncu) - SUM(creditncu)) > 0.0000 ' +
        '   OR (SUM(debitcurr) - SUM(creditcurr)) > 0.0000 ' +
        '   OR (SUM(debiteq)   - SUM(crediteq))   > 0.0000 ');

      q3.ParamByName('AccountKey').AsInteger := q2.FieldByName('id').AsInteger;
      q3.ParamByName('EntryDate').AsDateTime := FClosingDate;
      if FOnlyCompanySaldo then
        q3.ParamByName('CompanyKey').AsInteger := CompanyKey;
      LogEvent('[test] select SALDO_1 begin');
      q3.ExecQuery;
      LogEvent('[test] select SALDO_1 end');


      // проводки по счету '00 Остатки'
      q3.SQL.Text :=
        'INSERT INTO DBS_TMP_AC_SALDO ( ' +
        '  documentkey, masterdockey, ' +
        '  accountkey, ' +
        '  accountpart, ' +
        '  RECORDKEY, ' +
        '  id, ' +
        '  companykey, ' +
        '  currkey, ' +
        '  creditncu, ' +
        '  creditcurr, ' +
        '  crediteq, ' +
        '  debitncu, ' +
        '  debitcurr, ' +
        '  debiteq ';
      for I := 0 to AvailableAnalyticsList.Count - 1 do
        q3.SQL.Add(', ' + AvailableAnalyticsList[I]);
  
      q3.SQL.Add(
        ') ' +
        'SELECT ');   // CREDIT

      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +
          'GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ')
      else if FAllOurCompaniesSaldo then
      begin       //documentkey   
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
          q3.SQL.Add(' ' +
            'WHEN ' + OurCompany_EntryDocList.Names[I] + ' THEN ' + OurCompany_EntryDocList.Values[OurCompany_EntryDocList.Names[I]]);
        end;
        q3.SQL.Add(' ' +
          'END, ');
      end;

      q3.SQL.Add(
        '  accountkey, ' +
        '  ''C'', ' +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' +
        '  companykey, ' +
        '  currkey, ' +
        '  ABS(SUM(debitncu)  - SUM(creditncu)), ' +
        '  ABS(SUM(debitcurr) - SUM(creditcurr)), ' +
        '  ABS(SUM(debiteq)   - SUM(crediteq)), ' +
        '  0.0000 , ' +
        '  0.0000 , ' +
        '  0.0000');
      for I := 0 to AvailableAnalyticsList.Count - 1 do
        q3.SQL.Add(', ' + AvailableAnalyticsList[I]);

      q3.SQL.Add( ' ' +
        'FROM AC_ENTRY ' +
        'WHERE accountkey = :AccountKey ' +
        '  AND entrydate < :EntryDate ');
      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +
          'AND companykey = :CompanyKey ')
      else if FAllOurCompaniesSaldo then
        q3.SQL.Add(' ' +
          'AND companykey IN (' + OurCompaniesListStr + ') ');
      q3.SQL.Add(' ' +
        'GROUP BY ' +
        '  accountkey, ' +
        '  companykey, ' +
        '  currkey ');
      for I := 0 to AvailableAnalyticsList.Count - 1 do
        q3.SQL.Add(', ' + AvailableAnalyticsList[I]);
      q3.SQL.Add(' ' +
        'HAVING ' +
        '  (SUM(debitncu) - SUM(creditncu)) < 0.0000 ' +
        '   OR (SUM(debitcurr) - SUM(creditcurr)) < 0.0000 ' +
        '   OR (SUM(debiteq)   - SUM(crediteq))   < 0.0000 ' +

        'UNION ALL ' +   // DEBIT

        'SELECT ');
      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +
          'GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ')
      else if FAllOurCompaniesSaldo then
      begin       //documentkey   
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
        for i := 0 to OurCompany_EntryDocList.Count-1 do
        begin
          q3.SQL.Add(' ' +
            'WHEN ' + OurCompany_EntryDocList.Names[I] + ' THEN ' + OurCompany_EntryDocList.Values[OurCompany_EntryDocList.Names[I]]);
        end;
        q3.SQL.Add(' ' +
          'END, ');
      end;

      q3.SQL.Add(
        '  accountkey, ' +
        '  ''D'', ' +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' +
        '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' +
        '  companykey, ' +
        '  currkey, ' +
        '  0.0000, ' +
        '  0.0000, ' +
        '  0.0000, ' +
        '  ABS(SUM(debitncu)  - SUM(creditncu)), ' +
        '  ABS(SUM(debitcurr) - SUM(creditcurr)), ' +
        '  ABS(SUM(debiteq)   - SUM(crediteq)) ');
      for I := 0 to AvailableAnalyticsList.Count - 1 do
        q3.SQL.Add(', ' + AvailableAnalyticsList[I]);

      q3.SQL.Add( ' ' +
        'FROM AC_ENTRY ' +
        'WHERE accountkey = :AccountKey ' +
        '  AND entrydate < :EntryDate ');
      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +
          'AND companykey = :CompanyKey ')
      else if FAllOurCompaniesSaldo then
        q3.SQL.Add(' ' +
          'AND companykey IN (' + OurCompaniesListStr + ') ');
      q3.SQL.Add(' ' +
        'GROUP BY ' +
        '  accountkey, ' +
        '  companykey, ' +
        '  currkey ');
      for I := 0 to AvailableAnalyticsList.Count - 1 do
        q3.SQL.Add(', ' + AvailableAnalyticsList[I]);
      q3.SQL.Add(' ' +
        'HAVING ' +
        '  (SUM(debitncu) - SUM(creditncu)) > 0.0000 ' +
        '   OR (SUM(debitcurr) - SUM(creditcurr)) > 0.0000 ' +
        '   OR (SUM(debiteq)   - SUM(crediteq))   > 0.0000 ');

      q3.ParamByName('AccountKey').AsInteger := OstatkiAccountKey ;
      q3.ParamByName('EntryDate').AsDateTime := FClosingDate;
      if FOnlyCompanySaldo then
        q3.ParamByName('CompanyKey').AsInteger := CompanyKey;
        
      LogEvent('[test] select SALDO_2 begin');
      q3.ExecQuery;
      LogEvent('[test] select SALDO_2 end');


      AvailableAnalyticsList.Clear;
      q3.Close;

      q2.Next;
    end;
    Tr.Commit;
    Tr2.Commit;
    q2.Close;
  finally
    q2.Free;
    q3.Free;
    Tr2.Free;
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
  CalculatedBalanceDate: TDateTime;   
begin
  LogEvent('Deleting old entries balance...');
  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    if RelationExist2('AC_ENTRY_BALANCE', Tr) then
    begin
      q.SQL.Text := 
        'SELECT ' + 
        '  rdb$generator_name ' + 
        'FROM ' + 
        '  rdb$generators ' + 
        'WHERE ' + 
        '  rdb$generator_name = ''GD_G_ENTRY_BALANCE_DATE''';
      q.ExecQuery;
      if q.RecordCount <> 0 then
      begin
        q.Close;
        q.SQL.Text :=
          'SELECT ' +
          '  (GEN_ID(gd_g_entry_balance_date, 0) - ' + IntToStr(IB_DATE_DELTA) + ') AS CalculatedBalanceDate ' +
          'FROM rdb$database ';
        q.ExecQuery;

        if q.FieldByName('CalculatedBalanceDate').AsInteger > 0 then
        begin
          CalculatedBalanceDate := q.FieldByName('CalculatedBalanceDate').AsInteger;

          LogEvent('[test] CalculatedBalanceDate=' + DateTimeToStr(CalculatedBalanceDate));

          if CalculatedBalanceDate < FClosingDate then
          begin
            q.Close;
            q.SQL.Text := 'DELETE FROM ac_entry_balance';
            q.ExecQuery;

            q.SQL.Text := 'SET GENERATOR gd_g_entry_balance_date TO 0'; // ALTER SEQUENCE gd_g_entry_balance_date RESTART WITH
            q.ExecQuery;
          end;
        end;
        Tr.Commit;
      end;
    end;

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
  ProizvolnyeTransactionKey, ProizvolnyeTrRecordKey, AccDocTypeKey: Integer;
begin
  LogEvent('[test] CreateAcEntries...');

  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;

    q.SQL.Text :=
      'SELECT ' +
      '  gd.id AS AccDocTypeKey ' +
      'FROM ' + 
      '  GD_DOCUMENTTYPE gd ' +
      'WHERE ' +
      '  gd.name = ''Хозяйственная операция'' ';
    q.ExecQuery;
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
      'INSERT INTO GD_DOCUMENT ( ' +
      '  id, ' +
      '  documenttypekey, ' + 
      '  number, ' +
      '  documentdate, ' + 
      '  companykey, ' +
      '  afull, achag, aview, creatorkey, editorkey) ' +
      'SELECT DISTINCT ' +      
      '  documentkey, ' + 
      '  :AccDocTypeKey, ' +
      '  :Number, ' +
      '  :ClosingDate, ' +
      '  companykey, ' +
      '  -1, -1, -1, :CurUserContactKey, :CurUserContactKey ' +
      'FROM DBS_TMP_AC_SALDO ';
    q.ParamByName('AccDocTypeKey').AsInteger := AccDocTypeKey;
    q.ParamByName('Number').AsString := 'б/н';
    q.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    q.ParamByName('CurUserContactKey').AsInteger := FCurUserContactKey;

    LogEvent('[test] INSERT INTO GD_DOCUMENT SELECT begin');
    q.ExecQuery;
    LogEvent('[test] INSERT INTO GD_DOCUMENT SELECT end');

    // перенос проводок
    q.SQL.Text :=
      'INSERT INTO AC_RECORD ( ' +
      '  id, ' +
      '  recorddate, ' + 
      '  trrecordkey, ' + 
      '  transactionkey, ' + 
      '  documentkey, masterdockey, afull, achag, aview, companykey) ' +
      'SELECT DISTINCT ' +
      '  recordkey, ' +
      '  :ClosingDate, ' +
      '  :ProizvolnyeTrRecordKey, ' +
      '  :ProizvolnyeTransactionKey, ' +
      '  documentkey, masterdockey, -1, -1, -1, companykey ' +
      'FROM DBS_TMP_AC_SALDO ';
    q.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    q.ParamByName('ProizvolnyeTrRecordKey').AsInteger := ProizvolnyeTrRecordKey;
    q.ParamByName('ProizvolnyeTransactionKey').AsInteger := ProizvolnyeTransactionKey;
    
    LogEvent('[test] INSERT INTO AC_RECORD SELECT begin');
    q.ExecQuery;
    LogEvent('[test] INSERT INTO AC_RECORD SELECT end');

    // перенос проводок
    q.SQL.Text :=
      'INSERT INTO AC_ENTRY (' +
      '  issimple, ' +
      '  id, ' + 
      '  entrydate, ' +
      '  recordkey, ' +
      '  transactionkey, ' + 
      '  documentkey, masterdockey, companykey, accountkey, currkey, accountpart, ' +
      '  creditncu, creditcurr, crediteq, ' +
      '  debitncu, debitcurr, debiteq, ' +
         FEntryAnalyticsStr + ') ' +
      'SELECT ' +
      '  1, ' +
      '  id, ' +
      '  :ClosingDate, ' +
      '  recordkey, ' +
      '  :ProizvolnyeTransactionKey, ' +
      '  documentkey, masterdockey, companykey, accountkey, currkey, accountpart, ' +
      '  creditncu, creditcurr, crediteq, ' +
      '  debitncu, debitcurr, debiteq, ' +
         FEntryAnalyticsStr + ' ' +
      'FROM DBS_TMP_AC_SALDO ';
    q.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    q.ParamByName('ProizvolnyeTransactionKey').AsInteger := ProizvolnyeTransactionKey;

    LogEvent('[test] INSERT INTO AC_ENTRY SELECT begin');
    q.ExecQuery;
    LogEvent('[test] INSERT INTO AC_ENTRY SELECT end');

    Tr.Commit;
  finally
    q.Free;
    Tr.Free; 
  end;
  LogEvent('[test] CreateAcEntries... OK');
end;


procedure TgsDBSqueeze.CalculateInvSaldo; 
var
  q: TIBSQL;
  Tr: TIBTransaction;

  DocumentParentKey: Integer;
  CompanyKey: Integer;  
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);

  LogEvent('Calculating inventory balance...');

  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;

    if FOnlyCompanySaldo then
    begin
      q.SQL.Text :=
        'SELECT contactkey AS CompanyKey ' +
        'FROM GD_COMPANY ' +
        'WHERE fullname = :CompanyName ';
      q.ParamByName('CompanyName').AsString := FCompanyName;
      q.ExecQuery;

      CompanyKey := q.FieldByName('CompanyKey').AsInteger;
      q.Close;
    end;

    FCardFeaturesStr := ''; ///TODO: отпала необходимость

    // запрос на складские остатки
    q.SQL.Text :=
      'INSERT INTO DBS_TMP_INV_SALDO ' +  
      'SELECT ' +
      '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + // DOCUMENT ID
      '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + // MASTERDOCKEY
      '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + // ID_CARD
      '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + // ID_MOVEMENT_D
      '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + // ID_MOVEMENT_C
      '  im.contactkey AS ContactKey, ' +
      '  ic.goodkey, ' +
      '  ic.companykey, ' + 
      '  SUM(im.debit - im.credit) AS Balance ';
    {if (FCardFeaturesStr <> '') then
      q.SQL.Add(', ' +
        StringReplace(FCardFeaturesStr, 'USR$', 'ic.USR$', [rfReplaceAll, rfIgnoreCase]) + ' '); }
    q.SQL.Add(
      'FROM inv_movement im ' +
      '  JOIN inv_card ic ON im.cardkey = ic.id ' +
      'WHERE ' +
      '  im.cardkey > 0 '); // первый столбец в индексе, чтобы его задействовать
    if FOnlyCompanySaldo then
      q.SQL.Add(
        'AND ic.companykey = :CompanyKey ');
    q.SQL.Add(' ' +
      '  AND im.movementdate < :RemainsDate ' +
      '  AND im.disabled = 0 ' +
      'GROUP BY ' +
      '  im.contactkey, ' +
      '  ic.goodkey, ' +
      '  ic.companykey ');
 {   if (FCardFeaturesStr <> '') then
      q.SQL.Add(', ' +
        StringReplace(FCardFeaturesStr, 'USR$', 'ic.USR$', [rfReplaceAll, rfIgnoreCase]));  }

    q.ParamByName('RemainsDate').AsDateTime := FClosingDate;
    if FOnlyCompanySaldo then
      q.ParamByName('CompanyKey').AsInteger := CompanyKey;
    LogEvent('[test] SELECT...[begin]');
    LogSQL(q);
    q.ExecQuery;
    LogEvent('[test] SELECT...[end]');                                          ///TODO: обработка долгая (20 мин - 2 Гб) GROUP BY 

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
  InvDocTypeKey: Integer;
  PseudoClientKey: Integer;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);

  LogEvent('CreateInvSaldo...');

  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q2.Transaction := Tr;

    q.SQL.Text :=
      'SELECT ' +
      '  gd.id AS InvDocTypeKey ' +
      'FROM ' +
      '  GD_DOCUMENTTYPE gd ' +
      'WHERE ' +
      '  gd.name = ''Произвольный тип'' ';
    q.ExecQuery;

    InvDocTypeKey := q.FieldByName('InvDocTypeKey').AsInteger;
    q.Close;

    q.SQL.Text :=
      'SELECT id ' +
      'FROM gd_contact ' +
      'WHERE name = ''Псевдоклиент'' ';
    q.ExecQuery;

    if q.EOF then // если Псевдоклиента не существует, то создадим
    begin
      q.Close;
      q2.SQL.Text :=
        'SELECT ' +
        '  gc.id AS ParentId ' +
        'FROM gd_contact gc ' +
        'WHERE gc.name = ''Организации'' ';
      q2.ExecQuery;

      PseudoClientKey := GetNewID;

      q.SQL.Text :=
        'INSERT INTO gd_contact ( ' +
        '  id, ' +
        '  parent, ' +
        '  name, ' +
        '  contacttype, ' +
        '  afull, ' +
        '  achag, ' +
        '  aview) ' +
        'VALUES (' +
        '  :id, ' +
        '  :parent, ' +
        '  ''Псевдоклиент'', ' +
        '  3, ' +
        '  -1, ' +
        '  -1, ' +
        '  -1)';
      q.ParamByName('id').AsInteger := PseudoClientKey;
      q.ParamByName('parent').AsInteger := q2.FieldByName('ParentId').AsInteger;

      q.ExecQuery;
      q2.Close;
      Tr.Commit;
      Tr.StartTransaction;
    end
    else
      PseudoClientKey := q.FieldByName('id').AsInteger;
    q.Close;

    // create parent docs
    q.SQL.Text :=
      'INSERT INTO gd_document (' +
      '  id, ' + 
      '  documenttypekey, ' +
      '  number, '  + 
      '  documentdate, ' + 
      '  companykey, afull, achag, aview, ' +
      '  creatorkey, editorkey) ' +
      'SELECT ' + 
      '  id_parentdoc, ' +
      '  :InvDocTypeKey, ' +
      '  ''1'', ' +
      '  :ClosingDate, ' +
      '  companykey, -1, -1, -1, ' +
      '  :CurUserContactKey, :CurUserContactKey ' +
      'FROM DBS_TMP_INV_SALDO ';
    q.ParamByName('InvDocTypeKey').AsInteger := InvDocTypeKey;
    q.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    q.ParamByName('CurUserContactKey').AsInteger := FCurUserContactKey;

    q.ExecQuery;

    Tr.Commit;
    Tr.StartTransaction;

  // CreatePositionInvDoc
   
    q.SQL.Text :=
      'INSERT INTO gd_document (' + 
      '  id, ' + 
      '  parent, ' +
      '  documenttypekey, ' +
      '  number, '  + 
      '  documentdate, ' + 
      '  companykey, afull, achag, aview, ' +
      '  creatorkey, editorkey) ' +
      'SELECT ' +
      '  id_document, ' +
      '  id_parentdoc, ' +
      '  :InvDocTypeKey, ' +
      '  ''1'', ' +
      '  :ClosingDate, ' +
      '  companykey, -1, -1, -1, ' +
      '  :CurUserContactKey, :CurUserContactKey ' +
      'FROM DBS_TMP_INV_SALDO ';
    q.ParamByName('InvDocTypeKey').AsInteger := InvDocTypeKey;
    q.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    q.ParamByName('CurUserContactKey').AsInteger := FCurUserContactKey;

    q.ExecQuery;

    Tr.Commit;
    Tr.StartTransaction;

    // Создадим новую складскую карточку  

    q.SQL.Text :=
      'INSERT INTO inv_card (' +
      '  id, ' +
      '  goodkey, ' +
      '  documentkey, firstdocumentkey, ' + 
      '  firstdate, ' +
      '  companykey ';
    if (FCardFeaturesStr <> '') then      // поля-признаки
    begin
      if Pos('USR$INV_ADDLINEKEY', FCardFeaturesStr) <> 0 then
      begin
        if Pos('USR$INV_ADDLINEKEY,', FCardFeaturesStr) <> 0 then
          q.SQL.Add(', ' +
            StringReplace(FCardFeaturesStr, 'USR$INV_ADDLINEKEY,', ' ', [rfReplaceAll, rfIgnoreCase]) +
            ', USR$INV_ADDLINEKEY ')
        else
          q.SQL.Add(', ' + FCardFeaturesStr);
      end
      else
        q.SQL.Add(', ' + FCardFeaturesStr);
    end;
    q.SQL.Add(
      ') ' +
      'SELECT ' +
      '  id_card, ' +
      '  goodkey, ' +
      '  id_document, id_document, ' +
      '  :ClosingDate, ' +
      '  companykey ');
    if (FCardFeaturesStr <> '') then
    begin
      if Pos('USR$INV_ADDLINEKEY', FCardFeaturesStr) <> 0 then  // Заполним поле USR$INV_ADDLINEKEY карточки нового остатка ссылкой на позицию
      begin
        if Pos('USR$INV_ADDLINEKEY,', FCardFeaturesStr) <> 0 then  //не последний в списке - вырежем
          q.SQL.Add(', ' +
            StringReplace(FCardFeaturesStr, 'USR$INV_ADDLINEKEY,', ' ', [rfReplaceAll, rfIgnoreCase]) +
            ', id_document ')
        else
          q.SQL.Add(', ' +
            StringReplace(FCardFeaturesStr, 'USR$INV_ADDLINEKEY', 'id_document ', [rfReplaceAll, rfIgnoreCase]));
      end
      else
        q.SQL.Add(', ' + FCardFeaturesStr + ' ');
    end;
    q.SQL.Add(
      'FROM  DBS_TMP_INV_SALDO ');

    q.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    q.ExecQuery;

    Tr.Commit;
    Tr.StartTransaction;
    // Создадим дебетовую часть складского движения
    
    q.SQL.Text :=
      'INSERT INTO inv_movement ( ' +
      '  id, goodkey, movementkey, ' + 
      '  movementdate, ' +
      '  documentkey, cardkey, ' +
      '  debit, ' +
      '  credit, ' +
      '  contactkey) ' +       ///id, goodkey test
      'SELECT ' +
      '  id_movement_d, goodkey, id_movement_d, ' +
      '  :ClosingDate, ' +
      '  id_document, id_card, ' +
      '  ABS(balance), ' +
      '  0, ' +
      '  IIF((balance > 0) OR (balance = 0), ' +
      '    contactkey, ' +
      '    :PseudoClientKey) ' +
      'FROM  DBS_TMP_INV_SALDO ';
    q.ParamByName('PseudoClientKey').AsInteger := PseudoClientKey;
    q.ParamByName('ClosingDate').AsDateTime := FClosingDate;

    q.ExecQuery;

    Tr.Commit;  
    Tr.StartTransaction;
    // Создадим кредитовую часть складского движения
 
    q.SQL.Text :=
      'INSERT INTO inv_movement ( ' +
      '  id, goodkey, movementkey, ' + 
      '  movementdate, ' +
      '  documentkey, cardkey, ' +
      '  debit, ' +
      '  credit, ' +
      '  contactkey) ' +       ///id, goodkey test
      'SELECT ' +
      '  id_movement_c, goodkey, id_movement_d, ' + 
      '  :ClosingDate, ' +
      '  id_document, id_card, ' +
      '  0, ' +
      '  ABS(balance), ' +
      '  IIF((balance > 0) OR (balance = 0), ' + 
      '    :PseudoClientKey, ' +
      '    contactkey) ' +
      'FROM  DBS_TMP_INV_SALDO ';
      //LogEvent('[test] ' + q.SQL.Text);
    q.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    q.ParamByName('PseudoClientKey').AsInteger := PseudoClientKey;

    q.ExecQuery;

    Tr.Commit;
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
end;

// Перепривязка складских карточек и движения
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
      'SELECT ' +
      '  gd.id AS InvDocTypeKey ' +
      'FROM ' +
      '  GD_DOCUMENTTYPE gd ' +
      'WHERE ' +
      '  gd.name = ''Произвольный тип'' ';
    q3.ExecQuery;

    InvDocTypeKey := q3.FieldByName('InvDocTypeKey').AsInteger;
    q3.Close;

    qInsertTmpRebind.SQL.Text := 
      'INSERT INTO DBS_TMP_REBIND_INV_CARDS ' +
      '  (CUR_CARDKEY, NEW_CARDKEY, CUR_FIRST_DOCKEY, FIRST_DOCKEY, FIRST_DATE, CUR_RELATION_NAME) ' +
      'VALUES (:CurrentCardKey, :NewCardKey, :CurrentFirstDocKey, :FirstDocumentKey, :FirstDate, :CurrentRelationName) ';
    qInsertTmpRebind.Prepare;

    qInsertGdDoc.SQL.Text :=
      'INSERT INTO gd_document ' +
      '  (id, parent, documenttypekey, number, documentdate, companykey, afull, achag, aview, ' +
      'creatorkey, editorkey) ' +
      'VALUES ' +
      '  (:id, :parent, :documenttypekey, ''1'', :documentdate, :companykey, -1, -1, -1, ' +     ///NUMBER!
      ':userkey, :userkey) ';
    qInsertGdDoc.ParamByName('DOCUMENTDATE').AsDateTime := FClosingDate;
    qInsertGdDoc.Prepare;

    qInsertInvCard.SQL.Text :=
      'INSERT INTO inv_card ' +
      '  (id, goodkey, documentkey, firstdocumentkey, firstdate, companykey';
    // Поля-признаки
    if FCardFeaturesStr <> '' then
      qInsertInvCard.SQL.Add(', ' + FCardFeaturesStr);
    qInsertInvCard.SQL.Add(
      ') VALUES ' +
      '  (:id, :goodkey, :documentkey, :documentkey, :firstdate, :companykey');
    // Поля-признаки
    if FCardFeaturesStr <> '' then
      qInsertInvCard.SQL.Add(', ' +
        StringReplace(FCardFeaturesStr, 'USR$', ':USR$', [rfReplaceAll, rfIgnoreCase]));
    qInsertInvCard.SQL.Add(
      ')');

    qInsertInvCard.ParamByName('FIRSTDATE').AsDateTime := FClosingDate;                       ///
    qInsertInvCard.Prepare;

    qInsertInvMovement.SQL.Text :=
      'INSERT INTO inv_movement ' +
      '  (id, goodkey, movementkey, movementdate, documentkey, contactkey, cardkey, debit, credit) ' +       ///id, goodkey test
      'VALUES ' +
      '  (:id, :goodkey, :movementkey, :movementdate, :documentkey, :contactkey, :cardkey, :debit, :credit) ';
    qInsertInvMovement.ParamByName('MOVEMENTDATE').AsDateTime := FClosingDate;                ///
    qInsertInvMovement.Prepare;

    // выбираем все карточки, которые находятся в движении во время закрытия
    q3.SQL.Text :=
      'SELECT' +
      '  m1.contactkey AS FromConactKey,' +
      '  m.contactkey AS ToContactKey,' +
      '  linerel.relationname,' +
      '  c.id AS CardkeyNew, ' +
      '  c1.id AS CardkeyOld,' +
      '  c.goodkey,' +
      '  c.companykey, ' +
      '  c.firstdocumentkey';
    if FCardFeaturesStr <> '' then
    q3.SQL.Add(', ' +
      StringReplace(FCardFeaturesStr, 'USR$', 'c.USR$', [rfReplaceAll, rfIgnoreCase]) + ' ');                                                                       /// c.
    q3.SQL.Add(' ' +
      'FROM gd_document d ' +
      '  JOIN gd_documenttype t ON t.id = d.documenttypekey ' +
      '  LEFT JOIN inv_movement m ON m.documentkey = d.id ' +
      '  LEFT JOIN inv_movement m1 ON m1.movementkey = m.movementkey AND m1.id <> m.id ' +
      '  LEFT JOIN inv_card c ON c.id = m.cardkey ' +
      '  LEFT JOIN inv_card c1 ON c1.id = m1.cardkey ' +
      '  LEFT JOIN gd_document d_old ON ((d_old.id = c.documentkey) or (d_old.id = c1.documentkey)) ' +
      '  LEFT JOIN at_relations linerel ON linerel.id = t.linerelkey ' +
      'WHERE ' +
      '  d.documentdate >= :ClosingDate ' +
      '  AND t.classname = ''TgdcInvDocumentType'' ' +
      '  AND t.documenttype = ''D'' ' +
      '  AND d_old.documentdate < :ClosingDate ');
    q3.ParamByName('ClosingDate').AsDateTime := FClosingDate;
    q3.ExecQuery;

    FirstDocumentKey := -1;
    FirstDate := FClosingDate;                                 /// TODO: уточнить FirstDate
    while not q3.EOF do
    begin
      if q3.FieldByName('CardkeyOld').IsNull then
        CurrentCardKey := q3.FieldByName('CardkeyNew').AsInteger
      else
        CurrentCardKey := q3.FieldByName('CardkeyOld').AsInteger;
      CurrentFirstDocKey := q3.FieldByName('firstfocumentkey').AsInteger;
      CurrentFromContactkey := q3.FieldByName('FromConactKey').AsInteger;
      CurrentToContactkey := q3.FieldByName('ToContactKey').AsInteger;
      CurrentRelationName := q3.FieldByName('relationname').AsString;

      if (CurrentFromContactkey > 0) or (CurrentToContactkey > 0) then
      begin
        // ищем подходящую карточку в документе остатков для замены удаляемой
        q4.SQL.Text :=
          'SELECT FIRST(1) ' +
          '  c.id AS cardkey, ' +
          '  c.firstdocumentkey, ' +
          '  c.firstdate ' +
          'FROM gd_document d ' +
          '  LEFT JOIN inv_movement m ON m.documentkey = d.id ' +
          '  LEFT JOIN inv_card c ON c.id = m.cardkey ' +
          'WHERE ' +
          '  d.documenttypekey = :DocTypeKey ' +
          '  AND d.documentdate = :ClosingDate ' +
          '  AND c.goodkey = :GoodKey ' +
          '  AND ' +
          '    ((m.contactkey = :contact1) ' +
          '    OR (m.contactkey = :contact2)) ';
        for I := 0 to CardFeaturesList.Count - 1 do  
        begin
          if not q4.FieldByName(Trim(CardFeaturesList[I])).IsNull then
            q4.SQL.Add(Format(
            'AND c.%0:s = :%0:s ', [Trim(CardFeaturesList[I])]) + ' ')
          else
            q4.SQL.Add(Format(
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

        q4.ExecQuery;

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
          q4.SQL.Text :=                                                      // TODO: вынести. Prepare
            'SELECT FIRST(1) ' +
            '  c.id AS cardkey, ' +
            '  c.firstdocumentkey, ' +
            '  c.firstdate ' +
            'FROM gd_document d ' +
            '  LEFT JOIN inv_movement m ON m.documentkey = d.id ' +
            '  LEFT JOIN inv_card c ON c.id = m.cardkey ' +
            'WHERE ' +
            '  d.documenttypekey = :DocTypeKey ' +
            '  AND d.documentdate = :ClosingDate ' +
            '  AND c.goodkey = :GoodKey ' +
            '  AND ' +
            '    ((m.contactkey = :contact1) ' +
            '    OR (m.contactkey = :contact2)) ';

          q4.ParamByName('DocTypeKey').AsInteger := InvDocTypeKey;
          q4.ParamByName('ClosingDate').AsDateTime := FClosingDate;
          q4.ParamByName('GoodKey').AsInteger := q3.FieldByName('goodkey').AsInteger;
          q4.ParamByName('CONTACT1').AsInteger := CurrentFromContactkey;
          q4.ParamByName('CONTACT2').AsInteger := CurrentToContactkey;
          q4.ExecQuery;

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
            qInsertGdDoc.ExecQuery;

            NewDocumentKey := GetNewID;

            qInsertGdDoc.ParamByName('ID').AsInteger := NewDocumentKey;
            qInsertGdDoc.ParamByName('DOCUMENTTYPEKEY').AsInteger := InvDocTypeKey;
            qInsertGdDoc.ParamByName('PARENT').AsInteger := DocumentParentKey;
            qInsertGdDoc.ParamByName('COMPANYKEY').AsInteger := q3.FieldByName('companykey').AsInteger;
            qInsertGdDoc.ParamByName('USERKEY').AsInteger := FCurUserContactKey;
            qInsertGdDoc.ExecQuery;
        
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

            qInsertInvCard.ExecQuery;

            NewMovementKey := GetNewID;

            // Создадим дебетовую часть складского движения
            qInsertInvMovement.ParamByName('ID').AsInteger := GetNewID;
            qInsertInvMovement.ParamByName('GOODKEY').AsInteger := q3.FieldByName('goodkey').AsInteger;
            qInsertInvMovement.ParamByName('MOVEMENTKEY').AsInteger := NewMovementKey;
            qInsertInvMovement.ParamByName('DOCUMENTKEY').AsInteger := NewDocumentKey;
            qInsertInvMovement.ParamByName('CONTACTKEY').AsInteger := CurrentFromContactkey;
            qInsertInvMovement.ParamByName('CARDKEY').AsInteger := NewCardKey;
            qInsertInvMovement.ParamByName('DEBIT').AsCurrency := 0;
            qInsertInvMovement.ParamByName('CREDIT').AsCurrency := 0;
        
            qInsertInvMovement.ExecQuery;

            // Создадим кредитовую часть складского движения
            qInsertInvMovement.ParamByName('ID').AsInteger := GetNewID;
            qInsertInvMovement.ParamByName('GOODKEY').AsInteger := q3.FieldByName('goodkey').AsInteger;
            qInsertInvMovement.ParamByName('MOVEMENTKEY').AsInteger := NewMovementKey;
            qInsertInvMovement.ParamByName('DOCUMENTKEY').AsInteger := NewDocumentKey;
            qInsertInvMovement.ParamByName('CONTACTKEY').AsInteger := CurrentFromContactkey;
            qInsertInvMovement.ParamByName('CARDKEY').AsInteger := NewCardKey;
            qInsertInvMovement.ParamByName('DEBIT').AsCurrency := 0;
            qInsertInvMovement.ParamByName('CREDIT').AsCurrency := 0;

            qInsertInvMovement.ExecQuery;
          end;
        end;
        q4.Close;
      end
      else begin
        // ищем подходящую карточку для замены удаляемой
        q4.SQL.Text :=
          'SELECT FIRST(1) ' +
          '  c.id AS cardkey, ' +
          '  c.firstdocumentkey, ' +
          '  c.firstdate ' +
          'FROM gd_document d ' +
          '  LEFT JOIN inv_movement m ON m.documentkey = d.id ' +
          '  LEFT JOIN inv_card c ON c.id = m.cardkey ' +
          'WHERE ' +
          '  d.documenttypekey = :DocTypeKey ' +
          '  AND d.documentdate = :ClosingDate ' +
          '  AND c.goodkey = :GoodKey ';
        for I := 0 to CardFeaturesList.Count - 1 do
        begin
          if not q3.FieldByName(Trim(CardFeaturesList[I])).IsNull then
            q4.SQL.Add(Format(
            'AND c.%0:s = :%0:s ', [Trim(CardFeaturesList[I])]))
          else
            q4.SQL.Add(Format(
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

        q4.ExecQuery;

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
      qInsertTmpRebind.ParamByName('FirstDate').AsDateTime := FirstDocumentKey;
      qInsertTmpRebind.ParamByName('CurrentRelationName').AsString := CurrentRelationName;
      qInsertTmpRebind.ExecQuery;

      q3.Next;
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


// Перепривязка складских карточек и движения
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
      'UPDATE ' +
      '  inv_card c ' +
      'SET ' +
      '  c.parent = :NewParent ' +
      'WHERE ' +
      '  c.parent = :OldParent ' +
      '  AND (' +
      '    SELECT FIRST(1) m.movementdate ' +
      '    FROM inv_movement m ' +
      '    WHERE m.cardkey = c.id ' +
      '    ORDER BY m.movementdate DESC' +
      '  ) >= :CloseDate ';
    qUpdateCard.ParamByName('CloseDate').AsDateTime := FClosingDate;
    qUpdateCard.Prepare;

    // oбновляет ссылку на документ прихода и дату прихода
    qUpdateFirstDocKey.SQL.Text :=
      'UPDATE ' +
      '  inv_card c ' +
      'SET ' +
      '  c.firstdocumentkey = :NewDockey, ' +
      '  c.firstdate = :NewDate ' +                                           {TODO: убрать}
      'WHERE ' +
      '  c.firstdocumentkey = :OldDockey ';
    qUpdateFirstDocKey.Prepare;

    // обновляет в движении ссылки на складские карточки
    qUpdateInvMovement.SQL.Text :=
      'UPDATE ' +
      '  inv_movement m ' +
      'SET ' +
      '  m.cardkey = :NewCardkey ' +
      'WHERE ' +
      '  m.cardkey = :OldCardkey ' +
      '  AND m.movementdate >= :CloseDate ';
    qUpdateInvMovement.ParamByName('CloseDate').AsDateTime := FClosingDate;
    qUpdateInvMovement.Prepare;


    q3.SQL.Text :=
      'SELECT ' +
      '  CUR_CARDKEY       AS CurrentCardKey, ' +
      '  NEW_CARDKEY       AS NewCardKey, ' +
      '  CUR_FIRST_DOCKEY  AS CurrentFirstDocKey, ' +
      '  FIRST_DOCKEY      AS FirstDocumentKey, ' +
      '  FIRST_DATE        AS FirstDate, ' +
      '  CUR_RELATION_NAME AS CurrentRelationName ' +
      'FROM ' +
      '  DBS_TMP_REBIND_INV_CARDS ';
    q3.ExecQuery;

    while not q3.EOF do
    begin
      if q3.FieldByName('NewCardKey').AsInteger > 0 then
      begin
        // обновление ссылок на родительскую карточку
        qUpdateCard.ParamByName('OldParent').AsInteger :=  q3.FieldByName('CurrentCardKey').AsInteger;
        qUpdateCard.ParamByName('NewParent').AsInteger := q3.FieldByName('NewCardKey').AsInteger;
        qUpdateCard.ExecQuery;
        qUpdateCard.Close;

        // обновление ссылок на документ прихода и дату прихода
        if q3.FieldByName('FirstDocumentKey').AsInteger > -1 then
        begin
          qUpdateFirstDocKey.ParamByName('OldDockey').AsInteger := q3.FieldByName('CurrentFirstDocKey').AsInteger;
          qUpdateFirstDocKey.ParamByName('NewDockey').AsInteger := q3.FieldByName('FirstDocumentKey').AsInteger;
          qUpdateFirstDocKey.ParamByName('NewDate').AsDateTime := q3.FieldByName('FirstDate').AsDateTime;
          qUpdateFirstDocKey.ExecQuery;
          qUpdateFirstDocKey.Close;
        end;

        // обновление ссылок на карточки из движения
        qUpdateInvMovement.ParamByName('OldCardkey').AsInteger := q3.FieldByName('CurrentCardKey').AsInteger;
        qUpdateInvMovement.ParamByName('NewCardkey').AsInteger := q3.FieldByName('NewCardKey').AsInteger;
        qUpdateInvMovement.ExecQuery;
        qUpdateInvMovement.Close;

        // обновление в дополнительнных таблицах складских документов ссылок на складские карточки
        for I := 0 to CardkeyFieldCount - 1 do
        begin
          q4.SQL.Text :=
            'SELECT ' +
            '  RDB$FIELD_NAME' +
            'FROM ' +
            '  RDB$RELATION_FIELDS ' +
            'WHERE ' +
            '  RDB$RELATION_NAME = :RelationName' +
            '  AND RDB$FIELD_NAME = :FieldName';
          q4.ParamByName('RelationName').AsString := q3.FieldByName('CurrentRelationName').AsString;
          q4.ParamByName('FieldName').AsString := CardkeyFieldNames[I];
          q4.ExecQuery;

          if not q4.RecordCount > 0 then //если доп таблица содержит поле TOCARDKEY/FROMCARDKEY, то обновим их ссылки новыми карточками
          begin
            q4.Close;
            q4.SQL.Text := Format(
              'UPDATE ' +
              '  %0:s line ' +
              'SET ' +
              '  line.%1:s = :NewCardkey ' +
              'WHERE ' +
              '  line.%1:s = :OldCardkey ' +
              '  AND ( '+
              '    SELECT doc.documentdate ' +
              '    FROM gd_document doc ' +
              '    WHERE doc.id = line.documentkey' +
              '  ) >= :ClosingDate ',
              [q3.FieldByName('CurrentRelationName').AsString, CardkeyFieldNames[I]]);

            q4.ParamByName('OldCardkey').AsInteger := q3.FieldByName('CurrentCardKey').AsInteger;
            q4.ParamByName('NewCardkey').AsInteger := q3.FieldByName('NewCardKey').AsInteger;
            q4.ParamByName('ClosingDate').AsDateTime := FClosingDate;
            q4.ExecQuery;
          end;
          q4.Close;
        end;
      end
      else begin
        LogEvent('Error rebinding card! cardkey=' + q3.FieldByName('CurrentCardKey').AsString);
      end;
      q3.Next;
    end;
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
  Result := 0;
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);	
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr; 

    q.SQL.Text := Format(
      'SELECT g_his_create(%d, 0) FROM rdb$database', [AnIndex]);
    q.ExecQuery;

    Result :=  q.Fields[0].AsInteger;
    q.Close;

    Tr.Commit;
 
    if Result = 1 then
      LogEvent(Format('HIS[%d] создан успешно.', [AnIndex]))
    else begin
      LogEvent(Format('Попытка создания HIS[%d] завершилась неудачей!', [AnIndex]));
      //TODO: кидать exeption
    end;         
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
  Result := 0;
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);	
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr; 

    q.SQL.Text := Format(
      'SELECT g_his_destroy(%d) FROM rdb$database', [AnIndex]);
    q.ExecQuery;

    Result :=  q.Fields[0].AsInteger;
    q.Close;

    Tr.Commit;
 
    if Result = 1 then
      LogEvent(Format('HIS[%d] разрушен успешно.', [AnIndex]))
    else begin
      LogEvent(Format('Попытка разрушения HIS[%d] завершилась неудачей!', [AnIndex]));
      //TODO: кидать exeption
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
  Count: Integer; ///test

  function IncludeCascadingSequences(const ATableName: String): Integer;  // return real Count included
  var
    Count: Integer;
    Tr, Tr2: TIBTransaction;
    q: TIBQuery;
    q2: TIBSQL;
    q3: TIBSQL;
    q4: TIBSQL;
    TblsNamesList, AllProcessedTblsNames: TStringList;
    ProcTblsNamesList, CascadeProcTbls: TStringList;
    I, IndexEnd: Integer;
    IsDuplicate, DoNothing, GoToFirst, GoToLast, IsFirstIteration: Boolean;
    MainDuplicateTblName: String;
  begin
    Result := 0;
    LogEvent('[test] IncludeCascadingSequences...');
    TblsNamesList := TStringList.Create; // Process Queue
    AllProcessedTblsNames := TStringList.Create;
    ProcTblsNamesList := TStringList.Create;
    CascadeProcTbls := TStringList.Create;

    q := TIBQuery.Create(nil);
    q2 := TIBSQL.Create(nil);
    q3 := TIBSQL.Create(nil);
    q4 := TIBSQL.Create(nil);

    Tr := TIBTransaction.Create(nil);
    Tr2 := TIBTransaction.Create(nil);
    try
      TblsNamesList.Append(ATableName);
      AllProcessedTblsNames.Append(ATableName);

      Tr.DefaultDatabase := FIBDatabase;
      Tr.StartTransaction;
      Tr2.DefaultDatabase := FIBDatabase;
      Tr2.StartTransaction;
      q.Transaction := Tr;
      q2.Transaction := Tr;
      q4.Transaction := Tr;
      q3.Transaction := Tr2;

      IsDuplicate := False;
      DoNothing := False;
      GoToFirst := False;
      GoToLast := False;
      //------------------ добавление в HIS всех цепочек cascade, создание списка обработанных таблиц AllProcessedTblsNames
      while TblsNamesList.Count <> 0 do
      begin
        q.SQL.Text :=
          'SELECT ' +
          '  fc.relation_name, ' +
          '  fc.list_fields, ' +
          '  fc.ref_relation_name, ' +
          '  st.list_fields AS pk_fields ' +
          'FROM dbs_fk_constraints fc ' +
          '  JOIN DBS_SUITABLE_TABLES st ' +
          '    ON st.relation_name = fc.relation_name ' +
          'WHERE ' + 
          '  fc.ref_relation_name = :rln ' +
          '  AND ((fc.update_rule = ''CASCADE'') OR (fc.delete_rule = ''CASCADE'')) ' +        
          '  AND fc.list_fields NOT LIKE ''%,%'' ' ;
        q.ParamByName('rln').AsString := UpperCase(TblsNamesList[0]);
        q.Open;

        while not q.EOF do
        begin
          q3.SQL.Text :=
            'SELECT ' +
            '  SUM(IIF(g_his_has(0, ' + q.FieldByName('pk_fields').AsString + ') = 0, 1, 0)) AS RealKolvo, ' +
            '  COUNT(g_his_include(0, ' + q.FieldByName('pk_fields').AsString + ')) AS Kolvo ' +
            'FROM ' +
               q.FieldByName('relation_name').AsString + ' ' +
            'WHERE ' +
            '  g_his_has(0, ' + q.FieldByName('list_fields').AsString + ') = 1 ' +
            '  AND ' + q.FieldByName('pk_fields').AsString + ' > 147000000 ';                    ///
          q3.ExecQuery;

          Count := Count + q3.FieldByName('RealKolvo').AsInteger;

          if q3.FieldByName('Kolvo').AsInteger <> 0 then
          begin
            if AllProcessedTblsNames.IndexOf(Trim(q.FieldByName('relation_name').AsString)) <> -1 then
            begin
              if q3.FieldByName('RealKolvo').AsInteger <> 0 then
              begin
                if TblsNamesList.IndexOf(Trim(q.FieldByName('relation_name').AsString)) <> -1 then
                begin
                  DoNothing := True;

                  // Случай 1: этот FK является ссылкой таблицы на саму себя
                  if q.FieldByName('relation_name').AsString = q.FieldByName('ref_relation_name').AsString then
                  begin
                    repeat
                      q3.Close;
                      q3.SQL.Text :=
                        'SELECT ' +
                        '  SUM(g_his_include(0, ' + q.FieldByName('pk_fields').AsString + ')) AS RealKolvo ' +
                        'FROM ' +
                           q.FieldByName('relation_name').AsString + ' ' +
                        'WHERE ' +
                        '  g_his_has(0, ' + q.FieldByName('list_fields').AsString + ') = 1 ' +
                        '  AND ' + q.FieldByName('pk_fields').AsString + ' > 147000000 ';          ///
                      q3.ExecQuery;

                      Count := Count + q3.FieldByName('RealKolvo').AsInteger;
                    until q3.FieldByName('RealKolvo').AsInteger = 0;     ///TODO: не логично! сравнить версии файлов

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
                    MainDuplicateTblName := q.FieldByName('relation_name').AsString;
                  end;

                  if q.FieldByName('relation_name').AsString = MainDuplicateTblName then
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
                if (q.FieldByName('relation_name').AsString <> q.FieldByName('ref_relation_name').AsString)
                  and (q.FieldByName('relation_name').AsString = MainDuplicateTblName) then // ситуация 3. заканчиваем цикл переобработки
                begin
                  IsDuplicate := False;
                  MainDuplicateTblName := '';
                end;
              end;

              if (IsDuplicate) and (not DoNothing) then
              begin
                AllProcessedTblsNames.Delete(AllProcessedTblsNames.IndexOf(Trim(q.FieldByName('relation_name').AsString)));
              end;
            end;

            if not DoNothing then
            begin
                AllProcessedTblsNames.Append(Trim(q.FieldByName('relation_name').AsString));
                TblsNamesList.Append(Trim(q.FieldByName('relation_name').AsString));
            end
            else // закончили переобработку Ситуации 3. круг 2
            begin
              DoNothing := False;
            end;
          end;
          q3.Close;

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

        if GoToLast then
          GoToLast := False
        else
          TblsNamesList.Delete(0);
      end;
      Tr2.Commit;
      Tr2.StartTransaction;

      LogEvent('[test] COUNT ref real incuded: ' + IntToStr(Count));

      //------------------ исключение из HIS PK, на которые есть restrict/noAction

      CreateHIS(1);

      TblsNamesList.CommaText := AllProcessedTblsNames.CommaText;     ///TODO: перепроверить, заменить commatext->text
      LogEvent('[test] AllProcessedTblsNames: ' + TblsNamesList.CommaText);
      while TblsNamesList.Count > 0 do
      begin
        ProcTblsNamesList.Append(TblsNamesList[0]);
        LogEvent(ProcTblsNamesList.Text);
        IndexEnd := -1;

        q.Close;
        // получим все FK cascade поля в таблице
        q.SQL.Text :=                                                 ///TODO: вынести. Prepare
          'SELECT ' +
          '  fc.list_fields AS fk_field, ' +
          '  pc.list_fields AS pk_field ' +
          'FROM dbs_fk_constraints fc ' +
          '  JOIN DBS_SUITABLE_TABLES pc ' +
          '    ON pc.relation_name = fc.relation_name ' +
          'WHERE ((fc.update_rule = ''CASCADE'') OR (fc.delete_rule = ''CASCADE'')) ' +
          '  AND fc.relation_name = :rln ' +
          '  AND fc.list_fields NOT LIKE ''%,%'' ';
        q.ParamByName('rln').AsString := TblsNamesList[0];
        q.Open;

        // если FK есть в HIS_2, то исключим PK из HIS (исключение цепи, что выше)
        while not q.EOF do
        begin
          q2.SQL.Text :=
            'SELECT ' +
            '  SUM(' +
            '    IIF(g_his_exclude(0, ' + q.FieldByName('pk_field').AsString + ') = 1, ' +
            '      g_his_include(1, ' + q.FieldByName('pk_field').AsString + '), 0)' +
            '  ) AS Kolvo ' +
            'FROM ' +
               TblsNamesList[0] + ' ' +
            'WHERE ' +
            '  g_his_has(1, ' + q.FieldByName('fk_field').AsString + ') = 1 ';
          q2.ExecQuery;
          Count := Count - q2.FieldByName('Kolvo').AsInteger;
          q2.Close;
          q.Next;
        end;
        q.Close;

        // ищем RESTRICT/NO ACTION на таблицу
        q.SQL.Text :=
          'SELECT ' +
          '  fc.relation_name AS relation_name, ' +
          '  fc.list_fields AS list_fields ' +
          'FROM dbs_fk_constraints fc ' +
          'WHERE fc.update_rule IN (''RESTRICT'', ''NO ACTION'') ' +
          '  AND fc.ref_relation_name = :rln ' +
          '  AND fc.list_fields NOT LIKE ''%,%'' ' ;
        q.ParamByName('rln').AsString := TblsNamesList[0];
        q.Open;

        while not q.EOF do
        begin
          q2.Close;
          // извлекаем FK restrict HIS вместе с цепью
          q2.SQL.Text :=
            'SELECT ' +
            '  SUM(g_his_include(1, ' + q.FieldByName('list_fields').AsString + ')) AS Kolvo ' +
            'FROM ' +
               q.FieldByName('relation_name').AsString + ' ' +
            'WHERE ' +
            '  g_his_exclude(0, ' + q.FieldByName('list_fields').AsString + ') = 1 ';

          // если таблица с rectrict/noAction содержит предположительно удаляемый cascade
          if AllProcessedTblsNames.IndexOf(q.FieldByName('relation_name').AsString) <> -1 then
          begin  //извлекаем FK restrict HIS вместе с цепью, если ВСЕ каскады отсутствуют в HIS

            q4.SQL.Text :=  // получим все FK cascade поля в таблице
              'SELECT ' +
              '  fc.list_fields AS fk_field ' +
              'FROM dbs_fk_constraints fc ' +
              'WHERE ((fc.update_rule = ''CASCADE'') OR (fc.delete_rule = ''CASCADE'')) ' +
              '  AND fc.relation_name = :rln ' +
              '  AND fc.list_fields NOT LIKE ''%,%'' ';
            q4.ParamByName('rln').AsString := q.FieldByName('relation_name').AsString;
            q4.ExecQuery;

            q2.SQL.Add(' AND (0 ');
            while not q4.EOF do
            begin
              q2.SQL.Add(
                ' + g_his_has(0, ' + q4.FieldByName('fk_field').AsString + ') ');
              q4.Next;
            end;
            q2.SQL.Add(') = 0');
            q4.Close;
          end;
          LogSQL(q2);
          q2.ExecQuery;              ///ERR

          Count := Count - q2.FieldByName('Kolvo').AsInteger;

          if q2.FieldByName('Kolvo').AsInteger > 0 then // есть смысл исключать по цепи
          begin
            q2.Close;
            IndexEnd := 0;
            IsFirstIteration := True;
            // исключение цепи из HIS   (исключение цепи, что ниже)
            while ProcTblsNamesList.Count > 0 do
            begin
              if IsFirstIteration then  //движемся от конца к началу ProcTblsNamesList
              begin
                CascadeProcTbls.Add(ProcTblsNamesList[ProcTblsNamesList.Count-1]);   //список элементов цепи каскадной
                IndexEnd := AllProcessedTblsNames.IndexOf(CascadeProcTbls[0]);

                while CascadeProcTbls.Count > 0 do                                  ///////////////ERROR
                begin
                  q2.SQL.Text :=
                    'SELECT ' +
                    '  TRIM(fc.list_fields) AS list_fields, ' +
                    '  TRIM(fc.ref_relation_name) AS ref_relation_name, ' +
                    '  TRIM(pc.list_fields) AS pk_fields ' +
                    'FROM dbs_fk_constraints fc ' +
                    '  JOIN DBS_SUITABLE_TABLES pc ' +
                    '    ON pc.relation_name = fc.relation_name ' +
                    'WHERE ((fc.update_rule = ''CASCADE'') OR (fc.delete_rule = ''CASCADE'')) ' +    
                    '  AND fc.relation_name = :rln ' +
                    '  AND fc.ref_relation_name IN (';

                  LogEvent('[test] ProcTblsNamesList: ' + ProcTblsNamesList.CommaText);
                  for I:=0 to ProcTblsNamesList.Count-1 do                      /// TODO:или AllProc
                  begin
                    q2.SQL.Add(' ''' + ProcTblsNamesList[I] + '''');   ///TODO: возможно пуст? error
                    if I <> ProcTblsNamesList.Count-1 then
                      q2.SQL.Add(',');
                  end;
                  q2.SQL.Add(') ');

                  q2.ParamByName('rln').AsString := CascadeProcTbls[0]; 

                  LogSQL(q2);

                  q2.ExecQuery;

                  while not q2.EOF do
                  begin
                    q4.SQL.Text :=
                      'SELECT ' +
                      '  SUM( ' +
                      '    IIF(g_his_exclude(0, ' + q2.FieldByName('list_fields').AsString + ') = 1, ' +
                      '      g_his_include(1, ' + q2.FieldByName('list_fields').AsString + '), 0) ' +
                      '  ) AS Kolvo ' +
                      'FROM ' +
                         CascadeProcTbls[0] + ' ' +
                      'WHERE ' +
                      '  g_his_has(1, ' + q2.FieldByName('pk_fields').AsString + ') = 1 ';

                    q4.ExecQuery;
                    Count := Count - q4.FieldByName('Kolvo').AsInteger;
                    q4.Close;

                    if CascadeProcTbls.IndexOf(q2.FieldByName('ref_relation_name').AsString) = -1 then
                    begin
                      LogEvent('[test]CascadeProcTbls: ' + CascadeProcTbls.CommaText);
                      LogEvent('[test]CascadeProcTbls.Add: ' + q2.FieldByName('ref_relation_name').AsString);
                      CascadeProcTbls.Add(q2.FieldByName('ref_relation_name').AsString);
                      LogEvent('[test]CascadeProcTbls: ' + CascadeProcTbls.CommaText);
                    end;
                    q2.Next;
                  end;
                  q2.Close;

                  if ProcTblsNamesList.IndexOf(CascadeProcTbls[0]) <> -1 then
                  begin
                    LogEvent('[test] CascadeProcTbls[0]=' +CascadeProcTbls[0] );
                    LogEvent('[test] ProcTblsNamesList: ' + ProcTblsNamesList.CommaText);
                    ProcTblsNamesList.Delete(ProcTblsNamesList.IndexOf(CascadeProcTbls[0]));
                  end;
                  CascadeProcTbls.Delete(0);
                end;
              end
              else begin   // движемся от начала к концу ProcTblsNamesList
                q2.SQL.Text :=
                  'SELECT ' +
                  '  fc.list_fields, ' +
                  '  fc.ref_relation_name, ' +
                  '  st.list_fields AS pk_fields ' +
                  'FROM dbs_fk_constraints fc ' +
                  '  JOIN DBS_SUITABLE_TABLES st ' +
                  '    ON st.relation_name = fc.relation_name ' +
                  'WHERE ((fc.update_rule = ''CASCADE'') OR (fc.delete_rule = ''CASCADE'')) ' +    
                  '  AND fc.relation_name = :rln ' +
                  '  AND fc.ref_relation_name IN (';
                for I:=0 to IndexEnd do
                begin
                  q2.SQL.Add(' ''' + AllProcessedTblsNames[I] + '''');
                  if I <> IndexEnd then
                    q2.SQL.Add(',');
                end;
                q2.SQL.Add(') ');

                q2.ParamByName('rln').AsString := ProcTblsNamesList[0];
                
                LogSQL(q2);

                q2.ExecQuery;

                while not q2.EOF do
                begin
                  q4.SQL.Text :=
                    'SELECT ' +
                    '  SUM(' +
                    '    IIF(g_his_exclude(0, ' + q2.FieldByName('pk_fields').AsString + ') = 1, ' +
                    '      g_his_include(1, ' + q2.FieldByName('pk_fields').AsString + '), 0) ' +
                    '  ) AS Kolvo ' +
                    'FROM ' +
                       ProcTblsNamesList[0] + ' ' +
                    'WHERE ' +
                    '  g_his_has(1, ' + q2.FieldByName('list_fields').AsString + ') = 1 ';
                  q4.ExecQuery;
                  Count := Count - q4.FieldByName('Kolvo').AsInteger;
                  q4.Close;

                  q2.Next;
                end;
                q2.Close;

                ProcTblsNamesList.Delete(0);
              end;

              IsFirstIteration := False;  // значит обработали каскад от таблицы на которую есть рестрикт. т.е. прошли первый круг
            end;
          end;

          q.Next;
        end;
        q.Close;
        Tr.Commit;
        Tr.StartTransaction;

        if IndexEnd <> -1 then   //если нашли подходящий рестрикт т.е. ProcTblsNamesList пуст
        begin
          ProcTblsNamesList.Clear;                                           ///
          for I:=0 to IndexEnd do                                            ///
          begin                                                              ///
            ProcTblsNamesList.Append(AllProcessedTblsNames[I]);              ///
          end;                                                               ///
        end;

        TblsNamesList.Delete(0);
      end;
      
      LogEvent('[test] COUNT HIS after exclude: ' + IntToStr(Count));
      Tr.Commit;

      DestroyHIS(1);
     
      LogEvent('[test] IncludeCascadingSequences... OK');
      Result := Count;
    finally
      CascadeProcTbls.Free;
      ProcTblsNamesList.Free;
      TblsNamesList.Free;
      AllProcessedTblsNames.Free;
      q.Free;
      q2.Free;
      q3.Free;
      q4.Free;
      Tr.Free;
      Tr2.Free;
    end;
  end;

begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    CreateHIS(0);

    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    LogEvent('Including IDs In HugeIntSet... ');

    q.SQL.Text :=
      'SELECT COUNT(g_his_include(0, id)) as Kolvo FROM gd_document WHERE documentdate < :Date';
    q.ParamByName('Date').AsDateTime := FClosingDate;
    q.ExecQuery;

    Count := q.FieldByName('Kolvo').AsInteger;
    q.Close;

    LogEvent(Format('COUNT in HIS without cascade: %d', [Count]));
    IncludeCascadingSequences('GD_DOCUMENT');
    LogEvent(Format('COUNT in HIS with CASCADE: %d', [Count]));

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
begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    LogEvent('Deleting from DB... ');
                                          ///TODO: проверить можно ли в HIS добавить id < 147000000
    q.SQL.Text :=
      'SELECT ' + 
      ''' DELETE FROM '' || relation_name || ' + 
      ''' WHERE g_his_has(0, '' || list_fields  || '') = 1 ' + 
      '     AND '' || list_fields || '' > 147000000 '' ' + 
      'FROM ' + 
      '  DBS_SUITABLE_TABLES ';
    q.ExecQuery;

    Tr.Commit;
    Tr.StartTransaction;

    DestroyHIS(0);

    q.SQL.Text :=
      'DELETE FROM dbs_fk_constraints WHERE constraint_name LIKE ''dbs_%''';
    q.ExecQuery;
    
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

  procedure PrepareTriggers;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE TN CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT rdb$trigger_name ' +
      '    FROM rdb$triggers ' +
      '    WHERE ((rdb$trigger_inactive = 0) OR (rdb$trigger_inactive IS NULL)) ' +
      '      AND ((RDB$SYSTEM_FLAG = 0) OR (RDB$SYSTEM_FLAG IS NULL)) ' +
      //'      AND RDB$TRIGGER_NAME NOT IN (SELECT RDB$TRIGGER_NAME FROM RDB$CHECK_CONSTRAINTS) ' +     ///
      '    INTO :TN ' +
      '  DO ' +
      '  BEGIN ' +
      '    IN AUTONOMOUS TRANSACTION DO ' +
      '      EXECUTE STATEMENT ''ALTER TRIGGER '' || :TN || '' INACTIVE ''; ' +
      '  END ' +
      'END';
    q.ExecQuery;
    Tr.Commit;
    Tr.StartTransaction;
    
    LogEvent('Triggers deactivated.');
  end;

  procedure PrepareIndices;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE N CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT rdb$index_name ' +
      '    FROM rdb$indices ' +
      '    WHERE ((rdb$index_inactive = 0) OR (rdb$index_inactive IS NULL)) ' +
      '      AND ((RDB$SYSTEM_FLAG = 0) OR (RDB$SYSTEM_FLAG IS NULL)) ' +
      '      AND ((NOT rdb$index_name LIKE ''RDB$%'') ' +
      '        OR ((rdb$index_name LIKE ''RDB$PRIMARY%'') ' +
      '        OR (rdb$index_name LIKE ''RDB$FOREIGN%'')) ' +
      '      ) ' + 
      '    INTO :N ' +
      '  DO ' +
      '    EXECUTE STATEMENT ''ALTER INDEX '' || :N || '' INACTIVE ''; ' +
      'END';
    q.ExecQuery;
    Tr.Commit;
    Tr.StartTransaction;
    LogEvent('Indices deactivated.');
  end;

  procedure PreparePkUniqueConstraints;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE CN CHAR(31); ' +
      '  DECLARE VARIABLE RN CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT constraint_name, relation_name ' +
      '    FROM DBS_PK_UNIQUE_CONSTRAINTS ' +
      '    INTO :CN, :RN ' +
      '  DO ' +
      '    EXECUTE STATEMENT ''ALTER TABLE '' || :RN || '' DROP CONSTRAINT '' || :CN; ' +
      'END';
    q.ExecQuery;
    Tr.Commit;
    Tr.StartTransaction;
    LogEvent('PKs&UNIQs dropped.');
  end;

  procedure PrepareFKConstraints;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE CN CHAR(31); ' +
      '  DECLARE VARIABLE RN CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT constraint_name, relation_name ' +
      '    FROM DBS_FK_CONSTRAINTS ' +
      '    WHERE constraint_name NOT LIKE ''dbs_%'' ' +
      '    INTO :CN, :RN ' +
      '  DO ' +
      '    EXECUTE STATEMENT ''ALTER TABLE '' || :RN || '' DROP CONSTRAINT '' || :CN; ' +
      'END';
    q.ExecQuery;

    Tr.Commit;
    Tr.StartTransaction;

    LogEvent('FKs dropped.');
  end;

begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    LogEvent('Prepare DB...');
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    PrepareFKConstraints;
    PreparePkUniqueConstraints;
    PrepareTriggers;
    PrepareIndices;
    
    Tr.Commit;
    LogEvent('Prepare DB... OK');
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
    LogEvent('Saving metadata...');
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    // inactive triggers
    q.SQL.Text :=
      'INSERT INTO DBS_INACTIVE_TRIGGERS (TRIGGER_NAME) ' +
      'SELECT RDB$TRIGGER_NAME ' +
      'FROM RDB$TRIGGERS ' +
      'WHERE (RDB$TRIGGER_INACTIVE <> 0) AND (RDB$TRIGGER_INACTIVE IS NOT NULL) ' +
      '  AND ((RDB$SYSTEM_FLAG = 0) OR (RDB$SYSTEM_FLAG IS NULL)) ';
    q.ExecQuery;

    // inactive indices
    q.SQL.Text :=
      'INSERT INTO DBS_INACTIVE_INDICES (INDEX_NAME) ' +
      'SELECT RDB$INDEX_NAME ' +
      'FROM RDB$INDICES ' +
      'WHERE (RDB$INDEX_INACTIVE <> 0) AND (RDB$INDEX_INACTIVE IS NOT NULL) ' +
      '  AND ((RDB$SYSTEM_FLAG = 0) OR (RDB$SYSTEM_FLAG IS NULL))';
    q.ExecQuery;

    // PKs and Uniques constraints
    q.SQL.Text :=
      'INSERT INTO DBS_PK_UNIQUE_CONSTRAINTS ( ' +
      '  RELATION_NAME, ' +
      '  CONSTRAINT_NAME, ' +
      '  CONSTRAINT_TYPE, ' +
      '  LIST_FIELDS ) ' +
      'SELECT ' +
      '  c.RDB$RELATION_NAME, ' +
      '  c.RDB$CONSTRAINT_NAME, ' +
      '  c.RDB$CONSTRAINT_TYPE, ' +
      '  i.List_Fields ' +
      'FROM ' +
      '  RDB$RELATION_CONSTRAINTS c ' +
      '  JOIN (SELECT inx.RDB$INDEX_NAME, ' +
      '    list(TRIM(inx.RDB$FIELD_NAME)) as List_Fields ' +
      '    FROM RDB$INDEX_SEGMENTS inx ' +
      '    GROUP BY inx.RDB$INDEX_NAME ' +
      '  ) i ON c.RDB$INDEX_NAME = i.RDB$INDEX_NAME ' +
      'WHERE ' +
      '  (c.rdb$constraint_type = ''PRIMARY KEY'' OR c.rdb$constraint_type = ''UNIQUE'') ' +
      '   AND c.rdb$constraint_name NOT LIKE ''RDB$%'' ';
    q.ExecQuery;

    Tr.Commit;
    Tr.StartTransaction;

    // Имена таблиц и их поля PK, который подходит для добавление в множество HIS для удаления 
    q.SQL.Text :=
      'INSERT INTO DBS_SUITABLE_TABLES ' +
      'SELECT ' +
      '  pk.relation_name AS RN, ' +
      '  pk.list_fields AS FN ' +
      'FROM DBS_PK_UNIQUE_CONSTRAINTS pk ' +
      '  JOIN rdb$relation_fields rf ' +
      '    ON rf.rdb$relation_name = pk.relation_name ' +
      '      AND rf.rdb$field_name = pk.list_fields ' +
      '    JOIN rdb$fields f ON f.rdb$field_name = rf.rdb$field_source ' +
      'WHERE constraint_type = ''PRIMARY KEY'' ' +
      '  AND list_fields NOT LIKE ''%,%'' ' +
      '  AND f.rdb$field_type = 8 ';
    q.ExecQuery;

    // FK constraints
    q.SQL.Text :=
      'INSERT INTO DBS_FK_CONSTRAINTS ( ' +
      '  CONSTRAINT_NAME, RELATION_NAME, REF_RELATION_NAME, ' +
      '  UPDATE_RULE, DELETE_RULE, LIST_FIELDS, LIST_REF_FIELDS) ' +
      'SELECT ' +
      '  c.RDB$CONSTRAINT_NAME AS Constraint_Name, ' +
      '  c.RDB$RELATION_NAME AS Relation_Name, ' +
      '  c2.RDB$RELATION_NAME AS Ref_Relation_Name, ' +
      '  refc.RDB$UPDATE_RULE AS Update_Rule, ' +
      '  refc.RDB$DELETE_RULE AS Delete_Rule, ' +
      '  LIST(iseg.rdb$field_name) AS Fields, ' +
      '  LIST(ref_iseg.rdb$field_name) AS Ref_Fields ' +
      'FROM ' +
      '  RDB$RELATION_CONSTRAINTS c ' +
      '  JOIN RDB$REF_CONSTRAINTS refc ' +
      '    ON c.RDB$CONSTRAINT_NAME = refc.RDB$CONSTRAINT_NAME ' +
      '  JOIN RDB$RELATION_CONSTRAINTS c2 ' +
      '    ON refc.RDB$CONST_NAME_UQ = c2.RDB$CONSTRAINT_NAME ' +
      '  JOIN rdb$index_segments iseg ' +
      '    ON iseg.rdb$index_name = c.rdb$index_name ' +
      '  JOIN rdb$index_segments ref_iseg ' +
      '    ON ref_iseg.rdb$index_name = c2.rdb$index_name ' +
      'WHERE ' +
      '  c.rdb$constraint_type = ''FOREIGN KEY''  ' +
      '  AND c.rdb$constraint_name NOT LIKE ''RDB$%'' ' +
      'GROUP BY ' +
      '  1, 2, 3, 4, 5';
    q.ExecQuery;

    Tr.Commit;
    Tr.StartTransaction;

    q.SQL.Text :=
      'INSERT INTO DBS_FK_CONSTRAINTS ( ' +
      '  relation_name, ' +
      '  ref_relation_name, ' +
      '  constraint_name, ' +
      '  list_fields, list_ref_fields, update_rule, delete_rule) ' +
      'SELECT ' +
      '  IIF(relation_name = ''AC_ENTRY'', ''DBS_TMP_AC_SALDO'', relation_name), ' +
      '  IIF(ref_relation_name = ''AC_ENTRY'', ''DBS_TMP_AC_SALDO'', ref_relation_name), ' +
      '  ''dbs_'' || constraint_name, ' +
      '  list_fields, list_ref_fields, update_rule, delete_rule ' +
      'FROM  ' +
      '  DBS_FK_CONSTRAINTS  ' +
      'WHERE  ' +
      '  ((RELATION_NAME = ''AC_ENTRY'') AND (LIST_FIELDS NOT LIKE ''%TRANSACTIONKEY%'') ) ' +
      '  OR ((REF_RELATION_NAME = ''AC_ENTRY'') AND (LIST_REF_FIELDS NOT LIKE ''%TRANSACTIONKEY%'')) ';
    q.ExecQuery;



    Tr.Commit;
    LogEvent('Metadata saved.');
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.RestoreDB;                                               ///TODO: GD_RUID почистить
var
  Tr: TIBTransaction;
  q: TIBSQL;

  procedure RestoreTriggers;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE TN CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT t.rdb$trigger_name ' +
      '    FROM rdb$triggers t ' +
      '      LEFT JOIN dbs_inactive_triggers it ON it.trigger_name = t.rdb$trigger_name ' +
      '    WHERE ((t.rdb$trigger_inactive <> 0) OR (t.rdb$trigger_inactive IS NOT NULL)) ' +         /////t//
      '      AND ((t.rdb$system_flag = 0) OR (t.rdb$system_flag IS NULL)) ' +
      '      AND it.trigger_name IS NULL ' +
      '    INTO :TN ' +
      '  DO ' +
      '    EXECUTE STATEMENT ''ALTER TRIGGER '' || :TN || '' ACTIVE ''; ' +
      'END';
    q.ExecQuery;

    Tr.Commit;
    Tr.StartTransaction;

    LogEvent('Triggers reactivated.');
  end;

  procedure RestoreIndices;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE N CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT i.rdb$index_name ' +
      '    FROM rdb$indices i ' +
      '      LEFT JOIN dbs_inactive_indices ii ON ii.index_name = i.rdb$index_name ' +
      '    WHERE ((i.rdb$index_inactive = 0) OR (i.rdb$index_inactive IS NULL)) ' +
      '      AND ((i.rdb$system_flag = 0) OR (i.rdb$system_flag IS NULL)) ' +
      '      AND ii.index_name IS NULL ' +
      '    INTO :N ' +
      '  DO ' +
      '    EXECUTE STATEMENT ''ALTER INDEX '' || :N || '' ACTIVE ''; ' +
      'END';
    q.ExecQuery;

    Tr.Commit;
    Tr.StartTransaction;

    LogEvent('Indices reactivated.');
  end;

  procedure RestorePkUniqueConstraints;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      '  RETURNS(S VARCHAR(16384)) ' +
      'AS ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT ''ALTER TABLE '' || relation_name || '' ADD CONSTRAINT '' || ' +
      '      constraint_name || '' '' || constraint_type ||'' ('' || list_fields || '') '' ' +
      '    FROM dbs_pk_unique_constraints ' +
      '    INTO :S ' +
      '  DO BEGIN ' +
      '    SUSPEND; ' +
      '    EXECUTE STATEMENT :S WITH AUTONOMOUS TRANSACTION;' +
      '  END ' +
      'END';
    try
      q.ExecQuery;
      while not q.Eof do
        q.Next;
    except
      LogEvent('ERROR!');
      LogEvent('PK Query: ' + q.FieldByName('S').AsString);
      raise;
    end;

    Tr.Commit;
    Tr.StartTransaction;

    LogEvent('PKs&UNIQs restored.');
  end;

  procedure RestoreFKConstraints;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      '  RETURNS(S VARCHAR(16384)) ' +
      'AS ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT ''ALTER TABLE '' || relation_name || '' ADD CONSTRAINT '' || ' +
      '      constraint_name || '' FOREIGN KEY ('' || list_fields || '') REFERENCES '' || ' +
      '      ref_relation_name || ''('' || list_ref_fields || '') '' || ' +
      '      IIF(update_rule = ''RESTRICT'', '''', '' ON UPDATE '' || update_rule) || ' +
      '      IIF(delete_rule = ''RESTRICT'', '''', '' ON DELETE '' || delete_rule) ' +
      '    FROM dbs_fk_constraints ' +
      '    WHERE constraint_name NOT LIKE ''dbs_%'' ' +
      '    INTO :S ' +
      '  DO BEGIN ' +
      '    SUSPEND; ' +
      '    EXECUTE STATEMENT :S; ' +          ///with anonimus transaction
      '  END ' +
      'END';

    try
      q.ExecQuery;
      while not q.Eof do
        q.Next;
    except
      LogEvent('ERROR!');
      LogEvent('FK Query: ' + q.FieldByName('S').AsString);
      raise;
    end;

    Tr.Commit;
 //   Tr.StartTransaction;

    LogEvent('FKs restored.');
  end;

begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.ParamCheck := False;
    q.Transaction := Tr;

    RestoreIndices;
    RestoreTriggers;
    RestorePkUniqueConstraints;
    RestoreFKConstraints;
   
   // Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.SetItemsCbbEvent;
var
  Tr: TIBTransaction;
  q: TIBSQL;
  CompaniesList: TStringList;
begin
  Assert(Connected);
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  CompaniesList := TStringList.Create;
  if Assigned(FOnSetItemsCbbEvent) then
  begin
    try
      Tr.DefaultDatabase := FIBDatabase;
      Tr.StartTransaction;

      q.Transaction := Tr;
      q.SQL.Text :=
        'SELECT gc.fullname as CompName ' +
        'FROM GD_OURCOMPANY go ' +
        '  JOIN GD_COMPANY gc ON go.companykey = gc.contactkey ';
      q.ExecQuery;
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

procedure TgsDBSqueeze.LogSQL(const AnIBSQL: TIBSQL);           //TODO: доработать
begin
  LogEvent('[test] ' + AnIBSQL.SQL.Text);
end;

procedure TgsDBSqueeze.CreateMetadata;
var
  q: TIBSQL;
  q2: TIBSQL;
  Tr: TIBTransaction;

  procedure CreateDBSTmpRebindInvCards;
  begin
    if RelationExist2('DBS_TMP_REBIND_INV_CARDS', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM DBS_TMP_REBIND_INV_CARDS';
      q.ExecQuery;
      LogEvent('Table DBS_TMP_REBIND_INV_CARDS exists.');
    end else
    begin
      q.SQL.Text :=
        'CREATE TABLE DBS_TMP_REBIND_INV_CARDS ( ' +
        '  CUR_CARDKEY       INTEGER, ' +
        '  NEW_CARDKEY       INTEGER, ' +
        '  CUR_FIRST_DOCKEY  INTEGER, ' +
        '  FIRST_DOCKEY      INTEGER, ' +
        '  FIRST_DATE        DATE, ' +
        '  CUR_RELATION_NAME VARCHAR(31), ' +
        '  PRIMARY KEY (CUR_CARDKEY))';  //TODO: CUR_CARDKEY проверить уникальность
      q.ExecQuery;
      LogEvent('Table DBS_TMP_REBIND_INV_CARDS has been created.');
    end;
  end;

  procedure CreateDBSTmpAcSaldo;
  begin
    if RelationExist2('DBS_TMP_AC_SALDO', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM DBS_TMP_AC_SALDO';
      q.ExecQuery;
      LogEvent('Table DBS_TMP_AC_SALDO exists.');
    end else
    begin
      q2.SQL.Text :=
        'SELECT LIST( ' +
        '  TRIM(rf.rdb$field_name) || '' '' || ' +
        '  CASE f.rdb$field_type ' +
        '    WHEN 7 THEN ' +
        '      CASE f.rdb$field_sub_type ' +
        '        WHEN 0 THEN '' SMALLINT'' ' +
        '        WHEN 1 THEN '' NUMERIC('' || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' +
        '        WHEN 2 THEN '' DECIMAL(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' +
        '      END ' +
        '    WHEN 8 THEN ' +
        '      CASE f.rdb$field_sub_type ' +
        '        WHEN 0 THEN '' INTEGER'' ' +
        '        WHEN 1 THEN '' NUMERIC(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' +
        '        WHEN 2 THEN '' DECIMAL(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' +
        '      END ' +
        '    WHEN 9 THEN '' QUAD'' ' +
        '    WHEN 10 THEN '' FLOAT'' ' +
        '    WHEN 12 THEN '' DATE'' ' +
        '    WHEN 13 THEN '' TIME'' ' +
        '    WHEN 14 THEN '' CHAR('' || (TRUNC(f.rdb$field_length / ch.rdb$bytes_per_character)) || '')'' ' +
        '    WHEN 16 THEN ' +
        '      CASE f.rdb$field_sub_type ' +
        '        WHEN 0 THEN '' BIGINT'' ' +
        '        WHEN 1 THEN '' NUMERIC(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' +
        '        WHEN 2 THEN '' DECIMAL(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' +
        '      END ' +
        '    WHEN 27 THEN '' DOUBLE'' ' +
        '    WHEN 35 THEN '' TIMESTAMP'' ' +
        '    WHEN 37 THEN '' VARCHAR('' || (TRUNC(f.rdb$field_length / ch.rdb$bytes_per_character)) || '')'' ' +
        '    WHEN 40 THEN '' CSTRING('' || (TRUNC(f.rdb$field_length / ch.rdb$bytes_per_character)) || '')'' ' +
        '    WHEN 45 THEN '' BLOB_ID'' ' +
        '    WHEN 261 THEN '' BLOB'' ' +
        '    ELSE '' RDB$FIELD_TYPE:?'' ' +
        '  END)  AS AllUsrFieldsList ' +
        'FROM rdb$relation_fields rf ' +
        '  JOIN rdb$fields f ON (f.rdb$field_name = rf.rdb$field_source) ' +
        '  LEFT OUTER JOIN rdb$character_sets ch ON (ch.rdb$character_set_id = f.rdb$character_set_id) ' +
        'WHERE ' +
        '  rf.rdb$relation_name = ''AC_ENTRY'' ' +
        '  AND rf.rdb$field_name LIKE ''USR$%'' ' +
        '  AND COALESCE(rf.rdb$system_flag, 0) = 0 ';
      q2.ExecQuery;

      q.SQL.Text :=
        'CREATE TABLE DBS_TMP_AC_SALDO ( ' +
        '  ID           INTEGER, ' +
        '  COMPANYKEY   INTEGER, ' +
        '  CURRKEY      INTEGER, ' +
        '  ACCOUNTKEY   INTEGER, ' +
        '  MASTERDOCKEY INTEGER, ' +
        '  DOCUMENTKEY  INTEGER, ' +
        '  RECORDKEY    INTEGER, ' +
        '  ACCOUNTPART  VARCHAR(1), ' +
        '  CREDITNCU    DECIMAL(15,4), ' +
        '  CREDITCURR   DECIMAL(15,4), ' +
        '  CREDITEQ     DECIMAL(15,4), ' +
        '  DEBITNCU     DECIMAL(15,4), ' +
        '  DEBITCURR    DECIMAL(15,4), ' +
        '  DEBITEQ      DECIMAL(15,4), ' +
      q2.FieldByName('AllUsrFieldsList').AsString + ', ' +
        '  PRIMARY KEY (ID))';
      q.ExecQuery;
      q2.Close;
      LogEvent('Table DBS_TMP_AC_SALDO has been created.');
    end;
  end;

  procedure CreateDBSTmpInvSaldo;
  begin
    {if RelationExist2('DBS_TMP_INV_SALDO', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM DBS_TMP_INV_SALDO';
      q.ExecQuery;
      LogEvent('Table DBS_TMP_INV_SALDO exists.');
    end else
    begin
      q2.SQL.Text :=
        'SELECT LIST( ' +
        '  TRIM(rf.rdb$field_name) || '' '' || ' +
        '  CASE f.rdb$field_type ' +
        '    WHEN 7 THEN ' +
        '      CASE f.rdb$field_sub_type ' +
        '        WHEN 0 THEN '' SMALLINT'' ' +
        '        WHEN 1 THEN '' NUMERIC('' || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' +
        '        WHEN 2 THEN '' DECIMAL(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' +
        '      END ' +
        '    WHEN 8 THEN ' +
        '      CASE f.rdb$field_sub_type ' +
        '        WHEN 0 THEN '' INTEGER'' ' +
        '        WHEN 1 THEN '' NUMERIC(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' +
        '        WHEN 2 THEN '' DECIMAL(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' +
        '      END ' +
        '    WHEN 9 THEN '' QUAD'' ' +
        '    WHEN 10 THEN '' FLOAT'' ' +
        '    WHEN 12 THEN '' DATE'' ' +
        '    WHEN 13 THEN '' TIME'' ' +
        '    WHEN 14 THEN '' CHAR('' || (TRUNC(f.rdb$field_length / ch.rdb$bytes_per_character)) || '')'' ' +
        '    WHEN 16 THEN ' +
        '      CASE f.rdb$field_sub_type ' +
        '        WHEN 0 THEN '' BIGINT'' ' +
        '        WHEN 1 THEN '' NUMERIC(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' +
        '        WHEN 2 THEN '' DECIMAL(''  || f.rdb$field_precision || '','' || (-f.rdb$field_scale) || '')'' ' +
        '      END ' +
        '    WHEN 27 THEN '' DOUBLE'' ' +
        '    WHEN 35 THEN '' TIMESTAMP'' ' +
        '    WHEN 37 THEN '' VARCHAR('' || (TRUNC(f.rdb$field_length / ch.rdb$bytes_per_character)) || '')'' ' +
        '    WHEN 40 THEN '' CSTRING('' || (TRUNC(f.rdb$field_length / ch.rdb$bytes_per_character)) || '')'' ' +
        '    WHEN 45 THEN '' BLOB_ID'' ' +
        '    WHEN 261 THEN '' BLOB'' ' +
        '    ELSE '' RDB$FIELD_TYPE:?'' ' +
        '  END)  AS AllUsrFieldsList ' +
        'FROM rdb$relation_fields rf ' +
        '  JOIN rdb$fields f ON (f.rdb$field_name = rf.rdb$field_source) ' +
        '  LEFT OUTER JOIN rdb$character_sets ch ON (ch.rdb$character_set_id = f.rdb$character_set_id) ' +
        'WHERE ' +
        '  rf.rdb$relation_name = ''INV_CARD'' ' +
        '  AND rf.rdb$field_name LIKE ''USR$%'' ' +
        '  AND COALESCE(rf.rdb$system_flag, 0) = 0 ';
      q2.ExecQuery;

      q.SQL.Text :=
        'CREATE TABLE DBS_TMP_INV_SALDO ( ' +
        '  ID_DOCUMENT   INTEGER, ' +
        '  ID_PARENTDOC  INTEGER, ' +
        '  ID_CARD       INTEGER, ' +
        '  ID_MOVEMENT_D INTEGER, ' +
        '  ID_MOVEMENT_C INTEGER, ' +
        '  CONTACTKEY    INTEGER, ' +
        '  GOODKEY       INTEGER, ' +
        '  COMPANYKEY    INTEGER, ' +
        '  BALANCE       DECIMAL(15,4), ' +
  ///    q2.FieldByName('AllUsrFieldsList').AsString + ', ' +               ///TODO: отпала необходимость
        '  PRIMARY KEY (ID_DOCUMENT))';
      q.ExecQuery;
      q2.Close;
      LogEvent('Table DBS_TMP_INV_SALDO has been created.');
    end;}

    ///TODO:временно для березы
    if RelationExist2('DBS_TMP_INV_SALDO', Tr) then
    begin
      q.SQL.Text := 'DROP TABLE DBS_TMP_INV_SALDO';
      q.ExecQuery;
      LogEvent('Table DBS_TMP_INV_SALDO exists.');
      Tr.Commit;
      Tr.StartTransaction;
    end;
    q.SQL.Text :=
      'CREATE TABLE DBS_TMP_INV_SALDO ( ' +
      '  ID_DOCUMENT   INTEGER, ' +
      '  ID_PARENTDOC  INTEGER, ' +
      '  ID_CARD       INTEGER, ' +
      '  ID_MOVEMENT_D INTEGER, ' +
      '  ID_MOVEMENT_C INTEGER, ' +
      '  CONTACTKEY    INTEGER, ' +
      '  GOODKEY       INTEGER, ' +
      '  COMPANYKEY    INTEGER, ' +
      '  BALANCE       DECIMAL(15,4), ' +
      '  PRIMARY KEY (ID_DOCUMENT))';
    q.ExecQuery;
    q2.Close;
    LogEvent('Table DBS_TMP_INV_SALDO has been created.');
  ////
  end;

  procedure CreateDBSInactiveTriggers;
  begin
    if RelationExist2('DBS_INACTIVE_TRIGGERS', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM DBS_INACTIVE_TRIGGERS';
      q.ExecQuery;
      LogEvent('Table DBS_INACTIVE_TRIGGERS exists.');
    end else
    begin
      q.SQL.Text :=
        'CREATE TABLE DBS_INACTIVE_TRIGGERS ( ' +
        '  TRIGGER_NAME     CHAR(31) NOT NULL, ' +
        '  PRIMARY KEY (TRIGGER_NAME))';
      q.ExecQuery;
      LogEvent('Table DBS_INACTIVE_TRIGGERS has been created.');
    end;
  end;

  procedure CreateDBSInactiveIndices;
  begin
    if RelationExist2('DBS_INACTIVE_INDICES', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM DBS_INACTIVE_INDICES';
      q.ExecQuery;
      LogEvent('Table DBS_INACTIVE_INDICES exists.');
    end else
    begin
      q.SQL.Text :=
        'CREATE TABLE DBS_INACTIVE_INDICES ( ' +
        '  INDEX_NAME     CHAR(31) NOT NULL, ' +
        '  PRIMARY KEY (INDEX_NAME))';
      q.ExecQuery;
      LogEvent('Table DBS_INACTIVE_INDICES has been created.');
    end;
  end;

  procedure CreateDBSPkUniqueConstraints;
  begin
    if RelationExist2('DBS_PK_UNIQUE_CONSTRAINTS', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM DBS_PK_UNIQUE_CONSTRAINTS';
      q.ExecQuery;
      LogEvent('Table DBS_PK_UNIQUE_CONSTRAINTS exist.');
    end
    else begin
      q.SQL.Text :=
        'CREATE TABLE DBS_PK_UNIQUE_CONSTRAINTS ( ' +
	'  CONSTRAINT_NAME   CHAR(31), ' +
	'  RELATION_NAME     CHAR(31), ' +
	'  CONSTRAINT_TYPE   CHAR(11), ' +
	'  LIST_FIELDS       VARCHAR(310), ' +
	'  PRIMARY KEY (CONSTRAINT_NAME)) ';
      q.ExecQuery;
      q.Close;
      LogEvent('Table DBS_PK_UNIQUE_CONSTRAINTS has been created.');
    end;
  end;

  procedure CreateDBSSuitableTables;
  begin
    if RelationExist2('DBS_SUITABLE_TABLES', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM DBS_SUITABLE_TABLES';
      q.ExecQuery;
      LogEvent('Table DBS_SUITABLE_TABLES exist.');
    end
    else begin
      q.SQL.Text :=
        'CREATE TABLE DBS_SUITABLE_TABLES ( ' +
	'  RELATION_NAME     CHAR(31), ' +
	'  LIST_FIELDS       VARCHAR(310), ' +
	'  PRIMARY KEY (RELATION_NAME)) ';
      q.ExecQuery;
      q.Close;
      LogEvent('Table DBS_SUITABLE_TABLES has been created.');
    end;
  end;

  procedure CreateDBSFKConstraints;
  begin
    if RelationExist2('DBS_FK_CONSTRAINTS', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM DBS_FK_CONSTRAINTS';
      q.ExecQuery;
      LogEvent('Table DBS_FK_CONSTRAINTS exists.');
    end else
    begin
      q.SQL.Text :=
        'CREATE TABLE DBS_FK_CONSTRAINTS ( ' +
        '  CONSTRAINT_NAME   CHAR(31), ' +
        '  RELATION_NAME     CHAR(31), ' +
        '  LIST_FIELDS       VARCHAR(8192), ' +
        '  REF_RELATION_NAME CHAR(31), ' +
        '  LIST_REF_FIELDS   VARCHAR(8192), ' +
        '  UPDATE_RULE       CHAR(11), ' +
        '  DELETE_RULE       CHAR(11), ' +
        '  CONSTRAINT PK_DBS_FK_CONSTRAINTS PRIMARY KEY (CONSTRAINT_NAME))';
      q.ExecQuery;
      LogEvent('Table DBS_FK_CONSTRAINTS has been created.');
    end;
  end;

  procedure CreateUDFs;
  begin
    if FunctionExist2('G_HIS_CREATE', Tr) then
      LogEvent('Function g_his_create exists.')
    else begin
      q.SQL.Text :=
        'DECLARE EXTERNAL FUNCTION G_HIS_CREATE ' +
        '  INTEGER, ' +
        '  INTEGER ' +
        'RETURNS INTEGER BY VALUE ' +
        'ENTRY_POINT ''g_his_create'' MODULE_NAME ''gudf'' ';
      q.ExecQuery;
      LogEvent('Function g_his_create has been declared.');
    end;

    if FunctionExist2('G_HIS_DESTROY', Tr) then
      LogEvent('Function g_his_destroy exists.')
    else begin
      q.SQL.Text :=
        'DECLARE EXTERNAL FUNCTION G_HIS_DESTROY ' +
        '  INTEGER ' +
        'RETURNS INTEGER BY VALUE ' +
        'ENTRY_POINT ''g_his_destroy'' MODULE_NAME ''gudf'' ';
      q.ExecQuery;
      LogEvent('Function g_his_destroy has been declared.');
    end;

    if FunctionExist2('G_HIS_EXCLUDE', Tr) then
      LogEvent('Function g_his_exclude exists.')
    else begin
      q.SQL.Text :=
        'DECLARE EXTERNAL FUNCTION G_HIS_EXCLUDE ' +
        '  INTEGER, ' +
        '  INTEGER ' +
        'RETURNS INTEGER BY VALUE ' +
        'ENTRY_POINT ''g_his_exclude'' MODULE_NAME ''gudf'' ';
      q.ExecQuery;
      LogEvent('Function g_his_exclude has been declared.');
    end;

    if FunctionExist2('G_HIS_HAS', Tr) then
      LogEvent('Function g_his_has exists.')
    else begin
      q.SQL.Text :=
        'DECLARE EXTERNAL FUNCTION G_HIS_HAS ' +
        ' INTEGER, ' +
        ' INTEGER  ' +
        'RETURNS INTEGER BY VALUE ' +
        'ENTRY_POINT ''g_his_has'' MODULE_NAME ''gudf'' ';
      q.ExecQuery;
      LogEvent('Function g_his_has has been declared.');
    end;

    if FunctionExist2('G_HIS_INCLUDE', Tr) then
      LogEvent('Function g_his_include exists.')
    else begin
      q.SQL.Text :=
        'DECLARE EXTERNAL FUNCTION G_HIS_INCLUDE ' +
        ' INTEGER, ' +
        ' INTEGER ' +
        'RETURNS INTEGER BY VALUE ' +
        'ENTRY_POINT ''g_his_include'' MODULE_NAME ''gudf'' ';
      q.ExecQuery;
      LogEvent('Function g_his_include has been declared.');
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

  end;

begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q2.Transaction := Tr;

    CreateDBSTmpAcSaldo;
    CreateDBSTmpInvSaldo;

    CreateDBSInactiveTriggers;
    CreateDBSInactiveIndices;
    CreateDBSPkUniqueConstraints;
    CreateDBSSuitableTables;
    CreateDBSFKConstraints;
    CreateDBSTmpRebindInvCards;
    CreateUDFs;

    Tr.Commit;
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.GetDBSizeEvent;                   ///TODO: доделать
var
  fileSize: Int64;

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

  function GetFileSize(DatabaseName :String): Int64;
  var
    Handle: tHandle;
    FindData: tWin32FindData;
  begin
    Handle := FindFirstFile(PChar(DatabaseName), FindData);
    //if Handle = INVALID_HANDLE_VALUE then
    //  RaiseLastOSError;

    Windows.FindClose(Handle);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
      Result := 0  // Размер каталога всегда считаем равным 0
    else begin
      Int64Rec(Result).Hi := FindData.nFileSizeHigh;
      Int64Rec(Result).Lo := FindData.nFileSizeLow;
    end;
  end;

begin
  fileSize := GetFileSize(FDatabaseName);
  FOnGetDBSizeEvent(BytesToStr(fileSize));
end;

procedure TgsDBSqueeze.GetStatisticsEvent;
var
  q1: TIBSQL;
  q2: TIBSQL;
  q3: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q1 := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  q3 := TIBSQL.Create(nil);
  try
    LogEvent('[test] GetStatistics...');
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q1.Transaction := Tr;
    q2.Transaction := Tr;
    q3.Transaction := Tr;

    q1.SQL.Text :=
      'SELECT COUNT(id) AS Kolvo FROM GD_DOCUMENT';
    q1.ExecQuery;

    q2.SQL.Text :=
      'SELECT COUNT(id) AS Kolvo FROM AC_ENTRY';
    q2.ExecQuery;

    q3.SQL.Text :=
      'SELECT COUNT(id) AS Kolvo FROM INV_MOVEMENT';
    q3.ExecQuery;

    FOnGetStatistics(q1.FieldByName('Kolvo').AsString, q2.FieldByName('Kolvo').AsString, q3.FieldByName('Kolvo').AsString);

    Tr.Commit;
    LogEvent('[test] GetStatistics... OK');
  finally
    q1.Free;
    q2.Free;
    q3.Free;
    Tr.Free;
  end;
end;

end.
