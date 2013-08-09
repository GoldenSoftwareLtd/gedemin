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

    FInactivBlockTriggers: String; // неактивные триггеры блокировки периода

    FAllOurCompaniesSaldo: Boolean;
    FOnlyCompanySaldo: Boolean;

    FCurUserContactKey: Integer;

    procedure LogEvent(const AMsg: String);

    function GetNewID: Integer;
    function GetConnected: Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    procedure PrepareBeforeInsert;
    procedure RestoreAfterInsert;
    procedure SetBlockTriggerActive(SetActive: Boolean);
    
    procedure Connect;
    procedure Disconnect;

    // подсчет бухгалтерского сальдо
    procedure CalculateAcSaldo;
    // формирование бухгалтерского сальдо
    procedure CreateAcEntries;

    // подсчет и формирование складских остатков
    procedure CalculateInvSaldo;
    
    procedure DeleteDocuments;
    procedure PrepareDB;
    procedure RestoreDB;
    procedure SetItemsCbbEvent;
    procedure GetDBSizeEvent;
    procedure GetStatisticsEvent;
    procedure TestAndCreateMetadata;

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

procedure TgsDBSqueeze.Connect;
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  FIBDatabase.DatabaseName := FDatabaseName;
  FIBDatabase.LoginPrompt := False;
  FIBDatabase.Params.Text :=
    'user_name=' + FUserName + #13#10 +
    'password=' + FPassword + #13#10 +
    'lc_ctype=win1251' + #13#10 +
    'force_write=0' + #13#10;
   // 'no_garbage_collect=1';
  FIBDatabase.Connected := True;
  LogEvent('Connecting to DB... OK');

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

    {q.Close;
    q.SQL.Text :=
      'SELECT RDB$GET_CONTEXT(''SYSTEM'', ''ENGINE_VERSION'') as Ver FROM rdb$database ';    ///TODO: перенести
    q.ExecQuery;

    LogEvent('Firebird Server ver. ' + q.FieldByName('Ver').AsString);  }
    //Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.Disconnect;
begin
  FIBDatabase.Connected := False;
  LogEvent('Disconnecting from DB... OK');
end;

function TgsDBSqueeze.GetNewID: Integer;
var
  q: TIBSQL;
  Tr: TIBTransaction;
  Id: Integer;
begin
  Assert(Connected);

  Id := -1;

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
   Tr.DefaultDatabase := FIBDatabase;
   Tr.StartTransaction;
   q.Transaction := Tr;

   q.SQL.Text :=
     'SELECT GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0) AS NEW_ID ' +
     'FROM RDB$DATABASE ';
   q.ExecQuery;
   Id := q.FieldByName('NEW_ID').AsInteger;
  finally
    Result := Id;
    q.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.SetBlockTriggerActive(SetActive: Boolean);       //TODO: доработать. отключение триггеров блокировки периода
var
  StateStr: String;
  q: TIBSQL;
  q2: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q2.Transaction := Tr;

    if FInactivBlockTriggers = '' then
      LogEvent('[test] FInactivBlockTriggers=""')
    else
      LogEvent('[test] FInactivBlockTriggers=' + FInactivBlockTriggers);

    if FInactivBlockTriggers = '' then
    begin
      q.SQL.Text :=
        'SELECT ' +
        '  rdb$trigger_name AS TN ' +
        'FROM ' +
        '  rdb$triggers ' +
        'WHERE ' +
        '  rdb$system_flag = 0 ' +
        '  AND rdb$trigger_name LIKE ''%BLOCK%'' ' +
        '  AND rdb$trigger_inactive <> 0 ';                                     ///=1
      q.ExecQuery;
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
      'SELECT ' +
      '  rdb$trigger_name AS TN ' +
      'FROM ' +
      '  rdb$triggers ' +
      'WHERE ' +
      '  rdb$system_flag = 0 ' +
      '  AND rdb$trigger_name LIKE ''%BLOCK%'' ' +
      '  AND rdb$trigger_inactive = :IsInactiv ';
    if FInactivBlockTriggers <> ' ' then
      q.SQL.Add(
      '  AND rdb$trigger_name NOT IN (' + FInactivBlockTriggers + ')');

    if SetActive then
    begin
      StateStr := 'ACTIVE';
      q.ParamByName('IsInactiv').AsInteger := 1;
    end
    else begin
      StateStr := 'INACTIVE';
      q.ParamByName('IsInactiv').AsInteger := 0;
    end;
    q.ExecQuery;

    while not q.EOF do
    begin
      q2.SQL.Text := 'ALTER TRIGGER ' + q.FieldByName('TN').AsString + ' '  + StateStr;
      q2.ExecQuery;
      q2.Close;
      q.Next;
    end;
    q.Close;

    Tr.Commit;
    Tr.StartTransaction;

    q.SQL.Text :=                                                                ///
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE TN CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT rdb$trigger_name ' +
      '    FROM rdb$triggers ' +
      '    WHERE rdb$trigger_inactive = 0 ' +
      '     AND RDB$SYSTEM_FLAG = 0 ' +
     // '    AND rdb$relation_name = ''AC_ENTRY'' ' +
      '     AND rdb$trigger_name NOT LIKE ''%ISSIMPLE%'' ' + 
      '    INTO :TN ' +
      '  DO ' +
      '  BEGIN ' +
      '      EXECUTE STATEMENT ''ALTER TRIGGER '' || :TN || '' INACTIVE ''; ' +
      '  END ' +
      'END';
    q.ExecQuery;

    Tr.Commit;
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.PrepareBeforeInsert;
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
    LogEvent('[test] PrepareBeforeInsert...');
    q.Transaction := Tr;

    // fk
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
      '  (c.rdb$constraint_type = ''FOREIGN KEY'')  ' +
      '  AND (NOT c.rdb$constraint_name LIKE ''RDB$%'') ' +
      'GROUP BY ' +
      '  1, 2, 3, 4, 5';
    q.ExecQuery;

    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE CN CHAR(31); ' +
      '  DECLARE VARIABLE RN CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT constraint_name, relation_name ' +
      '    FROM DBS_FK_CONSTRAINTS ' +
      '    INTO :CN, :RN ' +
      '  DO ' +
      '    EXECUTE STATEMENT ''ALTER TABLE '' || :RN || '' DROP CONSTRAINT '' || :CN; ' +
      'END';
    q.ExecQuery;
    Tr.Commit;
    Tr.StartTransaction;

    // pk, unique
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
      '   AND c.rdb$relation_name IN (''AC_ENTRY'', ''AC_RECORD'', ''GD_DOCUMENT'', ''INV_CARD'', ''INV_MOVEMENT'') ' +///
      '   AND (NOT c.rdb$constraint_name LIKE ''RDB$%'') ';
    q.ExecQuery;

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

    //триггеры
    q.SQL.Text :=
      'INSERT INTO DBS_INACTIVE_TRIGGERS (TRIGGER_NAME) ' +
      'SELECT RDB$TRIGGER_NAME ' +
      'FROM RDB$TRIGGERS ' +
      'WHERE RDB$TRIGGER_INACTIVE <> 0 ' + ///=1
      '  AND RDB$SYSTEM_FLAG = 0';                                           
    q.ExecQuery;
    
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE TN CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT rdb$trigger_name ' +
      '    FROM rdb$triggers ' +
      '    WHERE rdb$trigger_inactive = 0 ' +
      '      AND RDB$SYSTEM_FLAG = 0 ' +
      '      AND rdb$relation_name IN (''AC_ENTRY'',''AC_RECORD'',''GD_DOCUMENT'',''INV_CARD'',''INV_MOVEMENT'') ' +///
      '      AND RDB$TRIGGER_NAME NOT IN (SELECT RDB$TRIGGER_NAME FROM RDB$CHECK_CONSTRAINTS) ' +
      '      AND rdb$trigger_name NOT LIKE ''%ISSIMPLE%'' ' +                   ////
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

    // indices
    q.SQL.Text :=
      'INSERT INTO DBS_INACTIVE_INDICES (INDEX_NAME) ' +
      'SELECT RDB$INDEX_NAME ' +
      'FROM RDB$INDICES ' +
      'WHERE RDB$INDEX_INACTIVE <> 0 ' + ///=1
      '  AND RDB$SYSTEM_FLAG = 0';
    q.ExecQuery;

    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE N CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT rdb$index_name ' +
      '    FROM rdb$indices ' +
      '    WHERE rdb$index_inactive = 0 ' +
      '      AND RDB$SYSTEM_FLAG = 0 ' +
      '      AND rdb$relation_name IN (''AC_ENTRY'', ''AC_RECORD'', ''GD_DOCUMENT'', ''INV_CARD'', ''INV_MOVEMENT'') ' +///
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
    LogEvent('[test] PrepareBeforeInsert... OK');
  finally
    q.Free;
    Tr.Free;
  end;
end; 

procedure TgsDBSqueeze.RestoreAfterInsert;
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
    LogEvent('[test] RestoreAfterInsert...');

    q.Transaction := Tr;

    // indices
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE N CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT i.rdb$index_name ' +
      '    FROM rdb$indices i ' +
      '      LEFT JOIN dbs_inactive_indices ii ON ii.index_name = i.rdb$index_name ' +
      '    WHERE i.rdb$index_inactive = 0 ' +
      '      AND i.rdb$system_flag = 0 ' +
      '      AND ii.index_name IS NULL ' +
      '    INTO :N ' +
      '  DO ' +
      '    EXECUTE STATEMENT ''ALTER INDEX '' || :N || '' ACTIVE ''; ' + 
      '  DELETE FROM dbs_inactive_indices; ' +
      'END';
    q.ExecQuery;

    Tr.Commit;
    Tr.StartTransaction;

    // triggers
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE TN CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT t.rdb$trigger_name ' +
      '    FROM rdb$triggers t ' +
      '      LEFT JOIN dbs_inactive_triggers it ON it.trigger_name = t.rdb$trigger_name ' +
      '    WHERE t.rdb$trigger_inactive = 0 ' +
      '      AND t.rdb$system_flag = 0 ' +
      '      AND it.trigger_name IS NULL ' +
      '    INTO :TN ' +
      '  DO ' +
      '    EXECUTE STATEMENT ''ALTER TRIGGER '' || :TN || '' ACTIVE ''; ' +
      '  DELETE FROM dbs_inactive_triggers; ' +
      'END';
    q.ExecQuery;

    Tr.Commit;
    Tr.StartTransaction;

    // pk, unique
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE S CHAR(16384); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT ''ALTER TABLE '' || relation_name || '' ADD CONSTRAINT '' || ' +
      '      constraint_name || '' '' || constraint_type ||'' ('' || list_fields || '') '' ' +
      '    FROM dbs_pk_unique_constraints ' +
      '    INTO :S ' +
      '  DO ' +
      '    EXECUTE STATEMENT :S; ' +
      '  DELETE FROM dbs_pk_unique_constraints; ' +
      'END';
    q.ExecQuery;

    Tr.Commit;
    Tr.StartTransaction;

    // fk
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE S CHAR(16384); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT ''ALTER TABLE '' || relation_name || '' ADD CONSTRAINT '' || ' +
      '      constraint_name || '' FOREIGN KEY ('' || list_fields || '') REFERENCES '' || ' +
      '      ref_relation_name || ''('' || list_ref_fields || '') '' || ' +
      '      IIF(update_rule = ''RESTRICT'', '''', '' ON UPDATE '' || update_rule) || ' +
      '      IIF(delete_rule = ''RESTRICT'', '''', '' ON DELETE '' || delete_rule) ' +
      '    FROM dbs_fk_constraints ' +
      '    INTO :S ' +
      '  DO ' +
      '    EXECUTE STATEMENT :S; ' +
      '  DELETE FROM dbs_fk_constraints; ' +
      'END';
    q.ExecQuery;

    Tr.Commit;
    LogEvent('[test] RestoreAfterInsert... OK');
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.CalculateAcSaldo;  // подсчет бухгалтерского сальдо
var
  q2: TIBSQL;
  q3: TIBSQL;
  Tr2: TIBTransaction;
  Tr: TIBTransaction;

  I: Integer;
  AllUsrFieldsNames: String;     // список всех аналитик (в разных БД отличаются)
  OstatkiAccountKey: Integer;

  OurCompaniesList, TmpList: TStringList;

  CompanyKey: Integer;
  OurCompaniesListStr: String;
  UsrFieldsList: TStringList;  // cписок активных аналитик для счета
begin
  LogEvent('Calculating entry balance...');
  Assert(Connected);

  TmpList := TStringList.Create;
  UsrFieldsList := TStringList.Create;
  OurCompaniesList := TStringList.Create; // список компания - документ для проводок

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

    if FAllOurCompaniesSaldo then
    begin
      TmpList.Text := StringReplace(OurCompaniesListStr, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
      for i := 0 to TmpList.Count-1 do
        OurCompaniesList.Append(TmpList[i] + '=' + IntToStr(GetNewID));
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

    q2.SQL.Text :=
      'SELECT LIST(rf.rdb$field_name) AS UsrFieldsList ' +
      'FROM RDB$RELATION_FIELDS rf ' +
      'WHERE rf.rdb$relation_name = ''AC_ACCOUNT'' ' +
      '  AND rf.rdb$field_name LIKE ''USR$%'' ';
    q2.ExecQuery;

    AllUsrFieldsNames := q2.FieldByName('UsrFieldsList').AsString;
    q2.Close;

    //-------------------------------------------- вычисление сальдо для счета
    // получаем счета
    q2.SQL.Text :=
      'SELECT DISTINCT ' +
      '  ae.accountkey AS id, ' +
         StringReplace(AllUsrFieldsNames, 'USR$', 'ac.USR$', [rfReplaceAll, rfIgnoreCase]) + ' ' +
      'FROM AC_ENTRY ae ' +
      '  JOIN AC_ACCOUNT ac ON ae.accountkey = ac.id ' +
      'WHERE ' +
      '  ae.entrydate < :EntryDate ';
    if FOnlyCompanySaldo then
      q2.SQL.Add(
        'AND ae.companykey = ' + IntToStr(CompanyKey))
    else if FAllOurCompaniesSaldo then
      q2.SQL.Add(' ' +
        'AND ae.companykey IN (' + OurCompaniesListStr + ') ');

    q2.ParamByName('EntryDate').AsDateTime := FClosingDate;                     ///TODO: проверить
    LogEvent('[test] SELECT account begin');
    q2.ExecQuery;
    LogEvent('[test] SELECT account end');


    // считаем и сохраняем сальдо для каждого счета
    while (not q2.EOF) do 
    begin
      LogEvent('[test] acc++');

      UsrFieldsList.Text := StringReplace(AllUsrFieldsNames, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
      // получаем cписок активных аналитик, по которым ведется учет для счета
      I := 0;
      while I < UsrFieldsList.Count - 1 do
      begin
        if (q2.FieldByName(Trim(UsrFieldsList[I])).AsInteger = 0) or (q2.FieldByName(Trim(UsrFieldsList[I])).IsNull) then
        begin
          UsrFieldsList.Delete(I);
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
      for I := 0 to UsrFieldsList.Count - 1 do
        q3.SQL.Add(', ' + UsrFieldsList[I]);

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
        for i := 0 to OurCompaniesList.Count-1 do
        begin
          q3.SQL.Add(' ' +
            'WHEN ' + OurCompaniesList.Names[i] + ' THEN ' + OurCompaniesList.Values[OurCompaniesList.Names[i]]);
        end;
        q3.SQL.Add(' ' +
          'END, ');
                             //masterdocumentkey
        q3.SQL.Add(
          'CASE companykey ');
        for i := 0 to OurCompaniesList.Count-1 do
        begin
          q3.SQL.Add(' ' +
            'WHEN ' + OurCompaniesList.Names[i] + ' THEN ' + OurCompaniesList.Values[OurCompaniesList.Names[i]]);
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
      for I := 0 to UsrFieldsList.Count - 1 do
        q3.SQL.Add(', ' + UsrFieldsList[I]);

      q3.SQL.Add(' ' +
        'FROM AC_ENTRY ' +
        'WHERE accountkey = :AccountKey ' +
        '  AND entrydate < :EntryDate ');
      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +
          'AND companykey = ' + IntToStr(CompanyKey) + ' ')
      else if FAllOurCompaniesSaldo then
        q3.SQL.Add(' ' +
          'AND companykey IN (' + OurCompaniesListStr + ') ');
      q3.SQL.Add(' ' +
        'GROUP BY ' +
        '  accountkey, ' +
        '  companykey, ' +
        '  currkey ');
      for I := 0 to UsrFieldsList.Count - 1 do
        q3.SQL.Add(', ' + UsrFieldsList[I]);
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
        for i := 0 to OurCompaniesList.Count-1 do
        begin
          q3.SQL.Add(' ' +
            'WHEN ' + OurCompaniesList.Names[i] + ' THEN ' + OurCompaniesList.Values[OurCompaniesList.Names[i]]);
        end;
        q3.SQL.Add(' ' +
          'END, ');
                  //masterdocumentkey
        q3.SQL.Add(
          'CASE companykey ');
        for i := 0 to OurCompaniesList.Count-1 do
        begin
          q3.SQL.Add(' ' +
            'WHEN ' + OurCompaniesList.Names[i] + ' THEN ' + OurCompaniesList.Values[OurCompaniesList.Names[i]]);
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
      for I := 0 to UsrFieldsList.Count - 1 do
        q3.SQL.Add(', ' + UsrFieldsList[I]);

      q3.SQL.Add( ' ' +
        'FROM AC_ENTRY ' +
        'WHERE accountkey = :AccountKey ' +
        '  AND entrydate < :EntryDate ');
      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +
          'AND companykey = ' + IntToStr(CompanyKey) + ' ')
      else if FAllOurCompaniesSaldo then
        q3.SQL.Add(' ' +
          'AND companykey IN (' + OurCompaniesListStr + ') ');
      q3.SQL.Add(' ' +
        'GROUP BY ' +
        '  accountkey, ' +
        '  companykey, ' +
        '  currkey ');
      for I := 0 to UsrFieldsList.Count - 1 do
        q3.SQL.Add(', ' + UsrFieldsList[I]);
      q3.SQL.Add(' ' +
        'HAVING ' +
        '  (SUM(debitncu) - SUM(creditncu)) > 0.0000 ' +
        '   OR (SUM(debitcurr) - SUM(creditcurr)) > 0.0000 ' +
        '   OR (SUM(debiteq)   - SUM(crediteq))   > 0.0000 ');

      q3.ParamByName('AccountKey').AsInteger := q2.FieldByName('id').AsInteger;
      q3.ParamByName('EntryDate').AsDateTime := FClosingDate;
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
      for I := 0 to UsrFieldsList.Count - 1 do
        q3.SQL.Add(', ' + UsrFieldsList[I]);
  
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
        for i := 0 to OurCompaniesList.Count-1 do
        begin
          q3.SQL.Add(' ' +
            'WHEN ' + OurCompaniesList.Names[i] + ' THEN ' + OurCompaniesList.Values[OurCompaniesList.Names[i]]);
        end;
        q3.SQL.Add(' ' +
          'END, ');
                  //masterdocumentkey
        q3.SQL.Add(
          'CASE companykey ');
        for i := 0 to OurCompaniesList.Count-1 do
        begin
          q3.SQL.Add(' ' +
            'WHEN ' + OurCompaniesList.Names[i] + ' THEN ' + OurCompaniesList.Values[OurCompaniesList.Names[i]]);
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
      for I := 0 to UsrFieldsList.Count - 1 do
        q3.SQL.Add(', ' + UsrFieldsList[I]);

      q3.SQL.Add( ' ' +
        'FROM AC_ENTRY ' +
        'WHERE accountkey = :AccountKey ' +
        '  AND entrydate < :EntryDate ');
      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +
          'AND companykey = ' + IntToStr(CompanyKey) + ' ')
      else if FAllOurCompaniesSaldo then
        q3.SQL.Add(' ' +
          'AND companykey IN (' + OurCompaniesListStr + ') ');
      q3.SQL.Add(' ' +
        'GROUP BY ' +
        '  accountkey, ' +
        '  companykey, ' +
        '  currkey ');
      for I := 0 to UsrFieldsList.Count - 1 do
        q3.SQL.Add(', ' + UsrFieldsList[I]);
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
        for i := 0 to OurCompaniesList.Count-1 do
        begin
          q3.SQL.Add(' ' +
            'WHEN ' + OurCompaniesList.Names[i] + ' THEN ' + OurCompaniesList.Values[OurCompaniesList.Names[i]]);
        end;
        q3.SQL.Add(' ' +
          'END, ');
                  //masterdocumentkey
        q3.SQL.Add(
          'CASE companykey ');
        for i := 0 to OurCompaniesList.Count-1 do
        begin
          q3.SQL.Add(' ' +
            'WHEN ' + OurCompaniesList.Names[i] + ' THEN ' + OurCompaniesList.Values[OurCompaniesList.Names[i]]);
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
      for I := 0 to UsrFieldsList.Count - 1 do
        q3.SQL.Add(', ' + UsrFieldsList[I]);

      q3.SQL.Add( ' ' +
        'FROM AC_ENTRY ' +
        'WHERE accountkey = :AccountKey ' +
        '  AND entrydate < :EntryDate ');
      if FOnlyCompanySaldo then
        q3.SQL.Add(' ' +
          'AND companykey = ' + IntToStr(CompanyKey) + ' ')
      else if FAllOurCompaniesSaldo then
        q3.SQL.Add(' ' +
          'AND companykey IN (' + OurCompaniesListStr + ') ');
      q3.SQL.Add(' ' +
        'GROUP BY ' +
        '  accountkey, ' +
        '  companykey, ' +
        '  currkey ');
      for I := 0 to UsrFieldsList.Count - 1 do
        q3.SQL.Add(', ' + UsrFieldsList[I]);
      q3.SQL.Add(' ' +
        'HAVING ' +
        '  (SUM(debitncu) - SUM(creditncu)) > 0.0000 ' +
        '   OR (SUM(debitcurr) - SUM(creditcurr)) > 0.0000 ' +
        '   OR (SUM(debiteq)   - SUM(crediteq))   > 0.0000 ');

      q3.ParamByName('AccountKey').AsInteger := OstatkiAccountKey ;
      q3.ParamByName('EntryDate').AsDateTime := FClosingDate;
      LogEvent('[test] select SALDO_2 begin');
      q3.ExecQuery;
      LogEvent('[test] select SALDO_2 end');


      UsrFieldsList.Clear;
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
    UsrFieldsList.Free;
    OurCompaniesList.Free;
    TmpList.Free;
  end;
  LogEvent('Calculating entry balance... OK');
end;

procedure TgsDBSqueeze.CreateAcEntries;
var
  q: TIBSQL;
  Tr: TIBTransaction;
  AllUsrFieldsNames: String;
  ProizvolnyeTransactionKey, ProizvolnyeTrRecordKey, AccDocTypeKey: Integer;

  procedure DeleteOldAcEntry; // удаление старых бухгалтерских проводок
  var
    q2: TIBSQL;
    Tr2: TIBTransaction;
  begin
    LogEvent('Deleting old entries...');
    q2 := TIBSQL.Create(nil);
    Tr2 := TIBTransaction.Create(nil);
    try
      Tr2.DefaultDatabase := FIBDatabase;
      Tr2.StartTransaction;

      q2.Transaction := Tr2;
      q2.SQL.Text :=
        'DELETE FROM AC_RECORD ' +                                              ///TODO: если отключены триггеры, почистить AC_ENTRY
        'WHERE ' +
        '  recorddate < :ClosingDate ';
//      if FOnlyCompanySaldo then                                               ///
//        q2.SQL.Add(' ' +
//          'AND companykey = ' + IntToStr(CompanyKey))
//      else if FAllOurCompaniesSaldo then
//        q2.SQL.Add(' ' +
//          'AND companykey IN(' + OurCompaniesListStr + ')');

      q2.ParamByName('ClosingDate').AsDateTime := FClosingDate;
      q2.ExecQuery;

//      q2.SQL.Text := 'DELETE FROM ac_entry_balance';                          ///TODO: проверить на существование
//      q2.ExecQuery;

      Tr2.Commit;
      LogEvent('Deleting old entries... OK');
    finally
      q2.Free;
      Tr2.Free;
    end;
  end;

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
      '  gd.id    AS AccDocTypeKey ' +
      'FROM GD_DOCUMENTTYPE gd ' +
      'WHERE ' +
      '  gd.name = ''Хозяйственная операция'' ';
    q.ExecQuery;
    AccDocTypeKey := q.FieldByName('AccDocTypeKey').AsInteger;

//    q.Close;                                                                    ///TODO: проверить на существование
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
    q.SQL.Text :=
      'SELECT LIST(rf.rdb$field_name) AS UsrFieldsList ' +
      'FROM RDB$RELATION_FIELDS rf ' +
      'WHERE rf.rdb$relation_name = ''AC_ACCOUNT'' ' +
      '  AND rf.rdb$field_name LIKE ''USR$%'' ';
    q.ExecQuery;

    AllUsrFieldsNames := q.FieldByName('UsrFieldsList').AsString;
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
         IntToStr(AccDocTypeKey) + ', ' +
      '  ''б/н'', ''' + 
         DateToStr(FClosingDate) + ''', ' +
      '  companykey, ' +
      '  -1, -1, -1, ' + IntToStr(FCurUserContactKey) + ',' + IntToStr(FCurUserContactKey) + ' ' +
      'FROM DBS_TMP_AC_SALDO ';
    LogEvent('[test] INSERT INTO GD_DOCUMENT SELECT begin');
    q.ExecQuery;
    LogEvent('[test] INSERT INTO GD_DOCUMENT SELECT end');

    // перенос записей проводок
    q.SQL.Text :=
      'INSERT INTO AC_RECORD ( ' +
      '  id, ' +
      '  recorddate, ' + 
      '  trrecordkey, ' + 
      '  transactionkey, ' + 
      '  documentkey, masterdockey, afull, achag, aview, companykey) ' +
      'SELECT DISTINCT ' +
      '  recordkey, ''' + 
         DateToStr(FClosingDate) + ''', ' +
         IntToStr(ProizvolnyeTrRecordKey) + ', ' + 
         IntToStr(ProizvolnyeTransactionKey) + ', ' +
      '  documentkey, masterdockey, -1, -1, -1, companykey ' +
      'FROM DBS_TMP_AC_SALDO ';
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
         AllUsrFieldsNames + ') ' +
      'SELECT ' +
      '  1, ' +
      '  id, ''' + 
         DateToStr(FClosingDate) + ''', ' +
      '  recordkey, ' +
         IntToStr(ProizvolnyeTransactionKey) + ', ' +
      '  documentkey, masterdockey, companykey, accountkey, currkey, accountpart, ' +
      '  creditncu, creditcurr, crediteq, ' +
      '  debitncu, debitcurr, debiteq, ' +
         AllUsrFieldsNames + ' ' +
      'FROM DBS_TMP_AC_SALDO ';
    LogEvent('[test] INSERT INTO AC_ENTRY SELECT begin');
    q.ExecQuery;
    LogEvent('[test] INSERT INTO AC_ENTRY SELECT end');

//   q.SQL.Text := 'DELETE FROM DBS_TMP_AC_SALDO';
//   q.ExecQuery;

    Tr.Commit;

    //test// DeleteOldAcEntry;
    
  finally
    q.Free;
    Tr.Free; 
  end;
  LogEvent('[test] CreateAcEntries... OK');
end;


procedure TgsDBSqueeze.CalculateInvSaldo;
var
  q, q2, qInsertGdDoc, qInsertInvCard, qInsertInvMovement: TIBSQL;
  Tr: TIBTransaction;
  InvDocTypeKey: Integer;
  PseudoClientKey: Integer;
  UsrFieldsNames: String;
  UsrFieldsList: TStringList;

  DocumentParentKey: Integer;
  CompanyKey: Integer;

  procedure SetTriggerActive(SetActive: Boolean);
  const
    AlterTriggerCount = 3;
    AlterTriggerArray: array[0 .. AlterTriggerCount - 1] of String =
      ('INV_BD_MOVEMENT', 'INV_BU_MOVEMENT', 'INV_BU_CARD');  ///'AC_ENTRY_DO_BALANCE'
  var
    StateStr: String;
    I: Integer;
    q: TIBSQL;
    Tr: TIBTransaction;
  begin
    Tr := TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);
    try
      Tr.DefaultDatabase := FIBDatabase;
      Tr.StartTransaction;
      q.Transaction := Tr;

      if SetActive then
        StateStr := 'ACTIVE'
      else
        StateStr := 'INACTIVE';

      for I := 0 to AlterTriggerCount - 1 do
      begin
        q.SQL.Text := 'ALTER TRIGGER ' + AlterTriggerArray[I] + ' '  + StateStr;
        q.ExecQuery;
        q.Close;
      end;

      Tr.Commit;
    finally
      q.Free;
      Tr.Free;
    end;
  end;

  procedure CalculateInvBalance(q: TIBSQL); // формируем складской остаток на дату
  begin
    // запрос на складские остатки
    q.SQL.Text :=
      'SELECT ' +
      '  im.contactkey AS ContactKey, ' +
      '  gc.name AS ContactName, ' +
      '  ic.goodkey, ' +
      '  ic.companykey ';  ///,
    ///  '  SUM(im.debit - im.credit) AS balance ';
    if (UsrFieldsNames <> '') then
      q.SQL.Add(', ' +
        StringReplace(UsrFieldsNames, 'USR$', 'ic.USR$', [rfReplaceAll, rfIgnoreCase]) + ' ');
    q.SQL.Add(
      'FROM  inv_movement im ' +
      '  JOIN inv_card ic ON im.cardkey = ic.id ' +
      '  LEFT JOIN gd_contact gc ON gc.id = im.contactkey ' +
      'WHERE ' +
      '  im.disabled = 0 ' +
      '  AND im.movementdate < :RemainsDate ');
    if FOnlyCompanySaldo then
      q.SQL.Add(
        'AND ic.companykey = ' + IntToStr(CompanyKey));
    q.SQL.Add(' ' +
      'GROUP BY ' +
      '  im.contactkey, ' +
      '  gc.name, ' +
      '  ic.goodkey, ' +
      '  ic.companykey ');
    if (UsrFieldsNames <> '') then
      q.SQL.Add(', ' +
        StringReplace(UsrFieldsNames, 'USR$', 'ic.USR$', [rfReplaceAll, rfIgnoreCase]));
    q.ParamByName('RemainsDate').AsDateTime := FClosingDate;
    LogEvent('[test] SELECT...[begin]');
    q.ExecQuery;
    LogEvent('[test] SELECT...[end]');                                          ///TODO: обработка долгая (20 мин - 2 Гб) GROUP BY избавиться
  end;

  function CreatePositionInvDoc(
    ADocumentParentKey, AFromContact, AToContact, ACompanyKey, ACardGoodKey: Integer;
    const AGoodQuantity: Currency;
    AInvDocType, ACurUserContactKey: Integer;
    AUsrFieldsDataset: TIBSQL = nil
  ): Integer;
  var
    NewDocumentKey, NewMovementKey, NewCardKey: Integer;
    I: Integer;
  begin
    Assert(Connected);

    NewCardKey := -1;
    try
      NewDocumentKey := GetNewID;

      qInsertGdDoc.ParamByName('ID').AsInteger := NewDocumentKey;
      qInsertGdDoc.ParamByName('DOCUMENTTYPEKEY').AsInteger := AInvDocType;
      qInsertGdDoc.ParamByName('PARENT').AsInteger := ADocumentParentKey;
      qInsertGdDoc.ParamByName('COMPANYKEY').AsInteger := ACompanyKey;
      qInsertGdDoc.ParamByName('USERKEY').AsInteger := ACurUserContactKey;
      qInsertGdDoc.ExecQuery;

      NewCardKey := GetNewID;

      // Создадим новую складскую карточку

      qInsertInvCard.ParamByName('ID').AsInteger := NewCardKey;
      qInsertInvCard.ParamByName('GOODKEY').AsInteger := ACardGoodKey;
      qInsertInvCard.ParamByName('DOCUMENTKEY').AsInteger := NewDocumentKey;
      qInsertInvCard.ParamByName('COMPANYKEY').AsInteger := ACompanyKey;

      for I := 0 to UsrFieldsList.Count - 1 do
      begin
        if Trim(UsrFieldsList[I]) <> 'USR$INV_ADDLINEKEY' then
        begin
          if Assigned(AUsrFieldsDataset) then
            qInsertInvCard.ParamByName(Trim(UsrFieldsList[I])).AsVariant :=
              AUsrFieldsDataset.FieldByName(Trim(UsrFieldsList[I])).AsVariant
          else
            qInsertInvCard.ParamByName(Trim(UsrFieldsList[I])).Clear;

        end
        else // Заполним поле USR$INV_ADDLINEKEY карточки нового остатка ссылкой на позицию
          qInsertInvCard.ParamByName('USR$INV_ADDLINEKEY').AsInteger := NewDocumentKey;
      end;

      qInsertInvCard.ExecQuery;

      NewMovementKey := GetNewID;

      // Создадим дебетовую часть складского движения
      qInsertInvMovement.ParamByName('ID').AsInteger := GetNewID;
      qInsertInvMovement.ParamByName('GOODKEY').AsInteger := ACardGoodKey;
      qInsertInvMovement.ParamByName('MOVEMENTKEY').AsInteger := NewMovementKey;
      qInsertInvMovement.ParamByName('DOCUMENTKEY').AsInteger := NewDocumentKey;
      qInsertInvMovement.ParamByName('CONTACTKEY').AsInteger := AToContact;
      qInsertInvMovement.ParamByName('CARDKEY').AsInteger := NewCardKey;
      qInsertInvMovement.ParamByName('DEBIT').AsCurrency := AGoodQuantity;
      qInsertInvMovement.ParamByName('CREDIT').AsCurrency := 0;

      qInsertInvMovement.ExecQuery;

      // Создадим кредитовую часть складского движения
      qInsertInvMovement.ParamByName('ID').AsInteger := GetNewID;
      qInsertInvMovement.ParamByName('GOODKEY').AsInteger := ACardGoodKey;
      qInsertInvMovement.ParamByName('MOVEMENTKEY').AsInteger := NewMovementKey;
      qInsertInvMovement.ParamByName('DOCUMENTKEY').AsInteger := NewDocumentKey;
      qInsertInvMovement.ParamByName('CONTACTKEY').AsInteger := AFromContact;
      qInsertInvMovement.ParamByName('CARDKEY').AsInteger := NewCardKey;
      qInsertInvMovement.ParamByName('DEBIT').AsCurrency := 0;
      qInsertInvMovement.ParamByName('CREDIT').AsCurrency := AGoodQuantity;

      qInsertInvMovement.ExecQuery;
    finally
      Result := NewCardKey;
    end;
  end;

  // Перепривязка складских карточек и движения
  procedure RebindInvCards(ATr: TIBTransaction);
  const
    CardkeyFieldCount = 2;
    CardkeyFieldNames: array[0..CardkeyFieldCount - 1] of String = ('FROMCARDKEY', 'TOCARDKEY');
  var
    I: Integer;
    q3, q4, q5: TIBSQL;
    qUpdateCard: TIBSQL;
    qUpdateFirstDocKey: TIBSQL;
    qUpdateInvMovement: TIBSQL;

    CurrentCardKey, CurrentFirstDocKey, CurrentFromContactkey, CurrentToContactkey: Integer;
    NewCardKey, FirstDocumentKey: Integer;
    FirstDate: TDateTime;
    CurrentRelationName: String;
    DocumentParentKey: Integer;
  begin
    LogEvent('Rebinding cards...');

    NewCardKey := -1;

    ATr := TIBTransaction.Create(nil);
    q3 := TIBSQL.Create(nil);
    q4 := TIBSQL.Create(nil);
    q5 := TIBSQL.Create(nil);
    qUpdateCard := TIBSQL.Create(nil);
    qUpdateFirstDocKey := TIBSQL.Create(nil);
    qUpdateInvMovement := TIBSQL.Create(nil);
    try
      ATr.DefaultDatabase := FIBDatabase;
      ATr.StartTransaction;

      q3.Transaction := ATr;
      q4.Transaction := ATr;
      q5.Transaction := ATr;
      qUpdateCard.Transaction := ATr;
      qUpdateFirstDocKey.Transaction := ATr;
      qUpdateInvMovement.Transaction := ATr;

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
      if UsrFieldsNames <> '' then q.SQL.Add(', ' +
        StringReplace(UsrFieldsNames, 'USR$', 'c.USR$', [rfReplaceAll, rfIgnoreCase]) + ' ');                                                                       /// c.
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
      FirstDate := FClosingDate;                                                /// TODO: уточнить FirstDate
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
          for I := 0 to UsrFieldsList.Count - 1 do
          begin
            if not q4.FieldByName(Trim(UsrFieldsList[I])).IsNull then
              q4.SQL.Add(Format(
              'AND c.%0:s = :%0:s ', [Trim(UsrFieldsList[I])]) + ' ')
            else
              q4.SQL.Add(Format(
              'AND c.%0:s IS NULL ', [Trim(UsrFieldsList[I])]) + ' ');
          end;

          q4.ParamByName('DocTypeKey').AsInteger := InvDocTypeKey;
          q4.ParamByName('ClosingDate').AsDateTime := FClosingDate;
          q4.ParamByName('GoodKey').AsInteger := q3.FieldByName('goodkey').AsInteger;
          q4.ParamByName('CONTACT1').AsInteger := CurrentFromContactkey;
          q4.ParamByName('CONTACT2').AsInteger := CurrentToContactkey;
          for I := 0 to UsrFieldsList.Count - 1 do
          begin
            if not q.FieldByName(Trim(UsrFieldsList[I])).IsNull then
              q4.ParamByName(Trim(UsrFieldsList[I])).AsVariant := q3.FieldByName(Trim(UsrFieldsList[I])).AsVariant;
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

              CalculateInvBalance(q5);  // По компании строим запрос на складские остатки

              NewCardKey := CreatePositionInvDoc(
                DocumentParentKey,
                CurrentFromContactkey,
                CurrentFromContactkey,
                q3.FieldByName('companykey').AsInteger,
                q3.FieldByName('goodkey').AsInteger,
                0,
                InvDocTypeKey,
                FCurUserContactKey,
                q5);
              q5.Close;

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
          for I := 0 to UsrFieldsList.Count - 1 do
          begin
            if not q3.FieldByName(Trim(UsrFieldsList[I])).IsNull then
              q4.SQL.Add(Format(
              'AND c.%0:s = :%0:s ', [Trim(UsrFieldsList[I])]))
            else
              q4.SQL.Add(Format(
              'AND c.%0:s IS NULL ', [Trim(UsrFieldsList[I])]));
          end;

          q4.ParamByName('ClosingDate').AsDateTime := FClosingDate;
          q4.ParamByName('DocTypeKey').AsInteger := InvDocTypeKey;
          q4.ParamByName('GoodKey').AsInteger := q3.FieldByName('GOODKEY').AsInteger;
          for I := 0 to UsrFieldsList.Count - 1 do
          begin
            if not q3.FieldByName(Trim(UsrFieldsList[I])).IsNull then
              q4.ParamByName(Trim(UsrFieldsList[I])).AsVariant := q3.FieldByName(Trim(UsrFieldsList[I])).AsVariant;
          end;

          q4.ExecQuery;

          if q4.RecordCount > 0 then
            NewCardKey := q4.FieldByName('CardKey').AsInteger
          else
            NewCardKey := -1;

          q4.Close;
        end;


        if NewCardKey > 0 then
        begin
          // обновление ссылок на родительскую карточку
          qUpdateCard.ParamByName('OldParent').AsInteger := CurrentCardKey;
          qUpdateCard.ParamByName('NewParent').AsInteger := NewCardKey;
          qUpdateCard.ExecQuery;
          qUpdateCard.Close;

          // обновление ссылок на документ прихода и дату прихода
          if FirstDocumentKey > -1 then
          begin
            qUpdateFirstDocKey.ParamByName('OldDockey').AsInteger := CurrentFirstDocKey;
            qUpdateFirstDocKey.ParamByName('NewDockey').AsInteger := FirstDocumentKey;
            qUpdateFirstDocKey.ParamByName('NewDate').AsDateTime := FirstDate;
            qUpdateFirstDocKey.ExecQuery;
            qUpdateFirstDocKey.Close;
          end;

          // обновление ссылок на карточки из движения
          qUpdateInvMovement.ParamByName('OldCardkey').AsInteger := CurrentCardKey;
          qUpdateInvMovement.ParamByName('NewCardkey').AsInteger := NewCardKey;
          qUpdateInvMovement.ExecQuery;
          qUpdateInvMovement.Close;

          // обновление в дополнительнных таблицах складских документов ссылок на складские карточки
          for I := 0 to CardkeyFieldCount - 1 do
          begin
            q4.SQL.Text :=
              'SELECT RDB$FIELD_NAME' +
              'FROM RDB$RELATION_FIELDS ' +
              'WHERE RDB$RELATION_NAME = :RelationName' +
              '  AND RDB$FIELD_NAME = :FieldName';
            q4.ParamByName('RelationName').AsString := CurrentRelationName;
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
                [CurrentRelationName, CardkeyFieldNames[I]]);

              q4.ParamByName('OldCardkey').AsInteger := CurrentCardKey;
              q4.ParamByName('NewCardkey').AsInteger := NewCardKey;
              q4.ParamByName('ClosingDate').AsDateTime := FClosingDate;
              q4.ExecQuery;
            end;
            q4.Close;

          end;
        end
        else begin
          LogEvent('Error rebinding card!');
        end;

        q3.Next;
      end;
      q3.Close;
      LogEvent('Rebinding cards... OK');
    finally
      q3.Free;
      q4.Free;
      q5.Free;
      qUpdateInvMovement.Free;
      qUpdateFirstDocKey.Free;
      qUpdateCard.Free;
    end;
  end;

begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  qInsertGdDoc := TIBSQL.Create(nil);
  qInsertInvCard := TIBSQL.Create(nil);
  qInsertInvMovement := TIBSQL.Create(nil);

  UsrFieldsList := TStringList.Create;

  LogEvent('Calculating inventory balance...');

  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q2.Transaction := Tr;
    qInsertGdDoc.Transaction := Tr;
    qInsertInvCard.Transaction := Tr;
    qInsertInvMovement.Transaction := Tr;

    if FOnlyCompanySaldo then
    begin
      q.SQL.Text :=
        'SELECT contactkey AS CompanyKey ' +
        'FROM GD_COMPANY gc ' +
        'WHERE fullname = :CompanyName ';
      q.ParamByName('CompanyName').AsString := FCompanyName;
      q.ExecQuery;

      CompanyKey := q.FieldByName('CompanyKey').AsInteger;
      q.Close;
    end;

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

   // список полей-признаков складской карточки
    q.SQL.Text :=
      'SELECT LIST(rf.rdb$field_name) as UsrFieldsList ' +
      'FROM RDB$RELATION_FIELDS rf ' +
      'WHERE rf.rdb$relation_name = ''INV_CARD'' ' +
      '  AND rf.rdb$field_name LIKE ''USR$%'' ';
    q.ExecQuery;

    UsrFieldsNames := q.FieldByName('UsrFieldsList').AsString;
    q.Close;

    UsrFieldsList.Text := StringReplace(UsrFieldsNames, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);

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
    qInsertInvCard.SQL.Add(', ' +
          UsrFieldsNames);
    qInsertInvCard.SQL.Add(
      ') VALUES ' +
      '  (:id, :goodkey, :documentkey, :documentkey, :firstdate, :companykey');
    // Поля-признаки
    qInsertInvCard.SQL.Add(', ' +
      StringReplace(UsrFieldsNames, 'USR$', ':USR$', [rfReplaceAll, rfIgnoreCase]));
    qInsertInvCard.SQL.Add(
      ')');

    qInsertInvCard.ParamByName('FIRSTDATE').AsDateTime := FClosingDate;                   ///
    qInsertInvCard.Prepare;


    qInsertInvMovement.SQL.Text :=
      'INSERT INTO inv_movement ' +
      '  (id, goodkey, movementkey, movementdate, documentkey, contactkey, cardkey, debit, credit) ' +       ///id, goodkey test
      'VALUES ' +
      '  (:id, :goodkey, :movementkey, :movementdate, :documentkey, :contactkey, :cardkey, :debit, :credit) ';

    qInsertInvMovement.ParamByName('MOVEMENTDATE').AsDateTime := FClosingDate;                ///
    qInsertInvMovement.Prepare;



    CalculateInvBalance(q);  // строим запрос на складские остатки для компании
    LogEvent('[test]');

    ///PrepareBeforeInsert;                                                        ///

    DecimalSeparator := '.';   // тип Currency в SQL имееет DecimalSeparator = ','
    LogEvent('[test] SELECT is done.');
    // Пройдем по остаткам ТМЦ
    while not q.EOF do
    begin

      if q.FieldByName('BALANCE').AsCurrency >= 0 then
      begin
        // Приход на ContactKey от PseudoClientKey
        DocumentParentKey := GetNewID;                                           
        qInsertGdDoc.ParamByName('ID').AsInteger :=  DocumentParentKey;
        qInsertGdDoc.ParamByName('PARENT').Clear;
        qInsertGdDoc.ParamByName('DOCUMENTTYPEKEY').AsInteger := InvDocTypeKey;
        qInsertGdDoc.ParamByName('COMPANYKEY').AsInteger := q.FieldByName('COMPANYKEY').AsInteger;
        qInsertGdDoc.ParamByName('USERKEY').AsInteger := FCurUserContactKey;
        qInsertGdDoc.ExecQuery;

        CreatePositionInvDoc(
          DocumentParentKey,
          PseudoClientKey, // поставщик
          q.FieldByName('ContactKey').AsInteger,
          q.FieldByName('COMPANYKEY').AsInteger,
          q.FieldByName('GOODKEY').AsInteger,
          q.FieldByName('BALANCE').AsCurrency,
          InvDocTypeKey,
          FCurUserContactKey,
          q);
      end
      else begin
        // Приход на PseudoClientKey от ContactKey (с положит. кол-вом ТМЦ)
        DocumentParentKey := GetNewID;                                                 
        qInsertGdDoc.ParamByName('ID').AsInteger := DocumentParentKey;
        qInsertGdDoc.ParamByName('PARENT').Clear;
        qInsertGdDoc.ParamByName('DOCUMENTTYPEKEY').AsInteger := InvDocTypeKey;
        qInsertGdDoc.ParamByName('COMPANYKEY').AsInteger := q.FieldByName('COMPANYKEY').AsInteger;
        qInsertGdDoc.ParamByName('USERKEY').AsInteger := FCurUserContactKey;
        qInsertGdDoc.ExecQuery;

        CreatePositionInvDoc(
          DocumentParentKey,
          q.FieldByName('ContactKey').AsInteger,
          PseudoClientKey,
          q.FieldByName('COMPANYKEY').AsInteger,
          q.FieldByName('GOODKEY').AsInteger,
          -(q.FieldByName('BALANCE').AsCurrency),
          InvDocTypeKey,
          FCurUserContactKey,
          q);
      end;

      q.Next;
    end;
    q.Close;

    Tr.Commit;

    //RestoreAfterInsert;

    Tr.StartTransaction;

    RebindInvCards(Tr);
    Tr.Commit;

    //SetTriggerActive(False);

  {  q.SQL.Text := 'DELETE FROM inv_movement WHERE movementdate < :Date';       /// удалятся при удалении карточки - удалении дока
    q.ParamByName('Date').AsString := FClosingDate;
    q.ExecQuery;

    q.SQL.Text := 'DELETE FROM inv_balance';                                    ///TODO: мб еще что-то
    q.ExecQuery;
  }
    //SetTriggerActive(True);

  finally
    q.Free;
    q2.Free;
    qInsertGdDoc.Free;
    qInsertInvCard.Free;
    qInsertInvMovement.Free;
    Tr.Free;
    UsrFieldsList.Free;
  end;
  LogEvent('Calculating inventory balance... OK');
end;

{
procedure TgsDBSqueeze.CalculateInvSaldo;
var
  q, q2: TIBSQL;
  Tr: TIBTransaction;
  InvDocTypeKey: Integer;
  PseudoClientKey: Integer;
  UsrFieldsNames: String;
  UsrFieldsList: TStringList;

  DocumentParentKey: Integer;
  CompanyKey: Integer;

  procedure CalculateInvBalance(q: TIBSQL); // формируем складской остаток на дату
  begin
    // запрос на складские остатки
    q.SQL.Text :=
      'SELECT ' +
      '  im.contactkey AS ContactKey, ' +
      '  gc.name AS ContactName, ' +
      '  ic.goodkey, ' +
      '  ic.companykey, ' +
      '  SUM(im.debit - im.credit) AS balance ';
    if (UsrFieldsNames <> '') then
      q.SQL.Add(', ' +
        StringReplace(UsrFieldsNames, 'USR$', 'ic.USR$', [rfReplaceAll, rfIgnoreCase]) + ' ');
    q.SQL.Add(
      'FROM  inv_movement im ' +
      '  JOIN inv_card ic ON im.cardkey = ic.id ' +
      '  LEFT JOIN gd_contact gc ON gc.id = im.contactkey ' +
      'WHERE ' +
      '  im.disabled = 0 ' +
      '  AND im.movementdate < :RemainsDate ');
    if FOnlyCompanySaldo then
      q.SQL.Add(
        'AND ic.companykey = ' + IntToStr(CompanyKey));
    q.SQL.Add(' ' +
      'GROUP BY ' +
      '  im.contactkey, ' +
      '  gc.name, ' +
      '  ic.goodkey, ' +
      '  ic.companykey ');
    if (UsrFieldsNames <> '') then
      q.SQL.Add(', ' +
        StringReplace(UsrFieldsNames, 'USR$', 'ic.USR$', [rfReplaceAll, rfIgnoreCase]));

    q.ParamByName('RemainsDate').AsDateTime := FClosingDate;
    q.ExecQuery;
  end;

  function CreateHeaderInvDoc(
    AFromContact, AToContact, ACompanyKey: Integer;
    AInvDocType, ACurUserContactKey: Integer;
    ATr2: TIBTransaction
  ): Integer;
  var
    NewDocumentKey: Integer;
    q3: TIBSQL;
  begin
    Assert(Connected);

    q3 := TIBSQL.Create(nil);
    try
      q3.Transaction := ATr2;

      NewDocumentKey := GetNewID;

      q3.SQL.Text :=
        'INSERT INTO gd_document ' +
        '  (id, parent, documenttypekey, number, documentdate, companykey, afull, achag, aview, ' +
          'creatorkey, editorkey) ' +
        'VALUES ' +
        '  (:id, :parent, :documenttypekey, ''1'', :documentdate, :companykey, -1, -1, -1, ' +              /// NUMBER!
          ':creatorkey, :editorkey) ';

      q3.ParamByName('ID').AsInteger := NewDocumentKey;
      q3.ParamByName('DOCUMENTTYPEKEY').AsInteger := AInvDocType;
      q3.ParamByName('PARENT').Clear;
      q3.ParamByName('COMPANYKEY').AsInteger := ACompanyKey;
      q3.ParamByName('DOCUMENTDATE').AsDateTime := FClosingDate;                ///
      q3.ParamByName('CREATORKEY').AsInteger := ACurUserContactKey;
      q3.ParamByName('EDITORKEY').AsInteger := ACurUserContactKey;
      q3.ExecQuery;

      Result := NewDocumentKey;
    finally
      q3.Free;
    end;
  end;

  function CreatePositionInvDoc(
    ADocumentParentKey, AFromContact, AToContact, ACompanyKey, ACardGoodKey: Integer;
    const AGoodQuantity: Currency;
    AInvDocType, ACurUserContactKey: Integer;
    ATr2: TIBTransaction;
    AUsrFieldsDataset: TIBSQL = nil
  ): Integer;
  var
    NewDocumentKey, NewMovementKey, NewCardKey: Integer;
    I: Integer;
    q3: TIBSQL;
  begin
    Assert(Connected);

    q3 := TIBSQL.Create(nil);
    NewCardKey := -1;
    try
      q3.Transaction := ATr2;

      NewDocumentKey := GetNewID;

      q3.SQL.Text :=
        'INSERT INTO gd_document ' +
        '  (id, parent, documenttypekey, number, documentdate, companykey, afull, achag, aview, ' +
          'creatorkey, editorkey) ' +
        'VALUES ' +
        '  (:id, :parent, :documenttypekey, ''1'', :documentdate, :companykey, -1, -1, -1, ' +     ///NUMBER!
          ':userkey, :userkey) ';

      q3.ParamByName('ID').AsInteger := NewDocumentKey;
      q3.ParamByName('DOCUMENTTYPEKEY').AsInteger := AInvDocType;
      q3.ParamByName('PARENT').AsInteger := ADocumentParentKey;
      q3.ParamByName('COMPANYKEY').AsInteger := ACompanyKey;
      q3.ParamByName('DOCUMENTDATE').AsDateTime := FClosingDate;
      q3.ParamByName('USERKEY').AsInteger := ACurUserContactKey;

      q3.ExecQuery;

      NewCardKey := GetNewID;

      // Создадим новую складскую карточку
      q3.SQL.Text :=
        'INSERT INTO inv_card ' +
        '  (id, goodkey, documentkey, firstdocumentkey, firstdate, companykey';
      // Поля-признаки
      q3.SQL.Add(', ' +
            UsrFieldsNames);
      q3.SQL.Add(
        ') VALUES ' +
        '  (:id, :goodkey, :documentkey, :documentkey, :firstdate, :companykey');
      // Поля-признаки
      q3.SQL.Add(', ' +
        StringReplace(UsrFieldsNames, 'USR$', ':USR$', [rfReplaceAll, rfIgnoreCase]));
      q3.SQL.Add(
        ')');

      q3.ParamByName('FIRSTDATE').AsDateTime := FClosingDate;                   ///
      q3.ParamByName('ID').AsInteger := NewCardKey;
      q3.ParamByName('GOODKEY').AsInteger := ACardGoodKey;
      q3.ParamByName('DOCUMENTKEY').AsInteger := NewDocumentKey;
      q3.ParamByName('COMPANYKEY').AsInteger := ACompanyKey;

      for I := 0 to UsrFieldsList.Count - 1 do
      begin
        if Trim(UsrFieldsList[I]) <> 'USR$INV_ADDLINEKEY' then
        begin
          if Assigned(AUsrFieldsDataset) then
            q3.ParamByName(Trim(UsrFieldsList[I])).AsVariant :=
              AUsrFieldsDataset.FieldByName(Trim(UsrFieldsList[I])).AsVariant
          else
            q3.ParamByName(Trim(UsrFieldsList[I])).Clear;

        end
        else // Заполним поле USR$INV_ADDLINEKEY карточки нового остатка ссылкой на позицию
          q3.ParamByName('USR$INV_ADDLINEKEY').AsInteger := NewDocumentKey;
      end;

      q3.ExecQuery;

      NewMovementKey := GetNewID;

      // Создадим дебетовую часть складского движения
      q3.SQL.Text :=
        'INSERT INTO inv_movement ' +
        '  (movementkey, movementdate, documentkey, contactkey, cardkey, debit, credit) ' +
        'VALUES ' +
        '  (:movementkey, :movementdate, :documentkey, :contactkey, :cardkey, :debit, :credit) ';

      q3.ParamByName('MOVEMENTDATE').AsDateTime := FClosingDate;                ///
      q3.ParamByName('MOVEMENTKEY').AsInteger := NewMovementKey;
      q3.ParamByName('DOCUMENTKEY').AsInteger := NewDocumentKey;
      q3.ParamByName('CONTACTKEY').AsInteger := AToContact;
      q3.ParamByName('CARDKEY').AsInteger := NewCardKey;
      q3.ParamByName('DEBIT').AsCurrency := AGoodQuantity;
      q3.ParamByName('CREDIT').AsCurrency := 0;

      q3.ExecQuery;

      // Создадим кредитовую часть складского движения
      q3.SQL.Text :=
        'INSERT INTO inv_movement ' +
        '  (movementkey, movementdate, documentkey, contactkey, cardkey, debit, credit) ' +
        'VALUES ' +
        '  (:movementkey, :movementdate, :documentkey, :contactkey, :cardkey, :debit, :credit) ';

      q3.ParamByName('MOVEMENTDATE').AsDateTime := FClosingDate;                /// 
      q3.ParamByName('MOVEMENTKEY').AsInteger := NewMovementKey;
      q3.ParamByName('DOCUMENTKEY').AsInteger := NewDocumentKey;
      q3.ParamByName('CONTACTKEY').AsInteger := AFromContact;
      q3.ParamByName('CARDKEY').AsInteger := NewCardKey;
      q3.ParamByName('DEBIT').AsCurrency := 0;
      q3.ParamByName('CREDIT').AsCurrency := AGoodQuantity;

      q3.ExecQuery;
    finally
      Result := NewCardKey;

      q3.Free;
    end;
  end;

  // Перепривязка складских карточек и движения
  procedure RebindInvCards;
  const
    CardkeyFieldCount = 2;
    CardkeyFieldNames: array[0..CardkeyFieldCount - 1] of String = ('FROMCARDKEY', 'TOCARDKEY');
  var
    I: Integer;
    Tr2: TIBTransaction;
    q3, q4, q5: TIBSQL;
    qUpdateCard: TIBSQL;
    qUpdateFirstDocKey: TIBSQL;
    qUpdateInvMovement: TIBSQL;

    CurrentCardKey, CurrentFirstDocKey, CurrentFromContactkey, CurrentToContactkey: Integer;
    NewCardKey, FirstDocumentKey: Integer;
    FirstDate: TDateTime;
    CurrentRelationName: String;
    DocumentParentKey: Integer;
  begin
    LogEvent('Rebinding cards...');

    NewCardKey := -1;

    Tr2 := TIBTransaction.Create(nil);
    q3 := TIBSQL.Create(nil);
    q4 := TIBSQL.Create(nil);
    q5 := TIBSQL.Create(nil);
    qUpdateCard := TIBSQL.Create(nil);
    qUpdateFirstDocKey := TIBSQL.Create(nil);
    qUpdateInvMovement := TIBSQL.Create(nil);
    try
      Tr2.DefaultDatabase := FIBDatabase;
      Tr2.StartTransaction;

      q3.Transaction := Tr2;
      q4.Transaction := Tr2;
      q5.Transaction := Tr2;
      qUpdateCard.Transaction := Tr2;
      qUpdateFirstDocKey.Transaction := Tr2;
      qUpdateInvMovement.Transaction := Tr2;

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
        '  c.firstdate = :NewDate ' +                                           //TODO: убрать
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
      if UsrFieldsNames <> '' then q.SQL.Add(', ' +
        StringReplace(UsrFieldsNames, 'USR$', 'c.USR$', [rfReplaceAll, rfIgnoreCase]) + ' ');                                                                       /// c.
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
      FirstDate := FClosingDate;                                                /// TODO: уточнить FirstDate
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
          for I := 0 to UsrFieldsList.Count - 1 do
          begin
            if not q4.FieldByName(Trim(UsrFieldsList[I])).IsNull then
              q4.SQL.Add(Format(
              'AND c.%0:s = :%0:s ', [Trim(UsrFieldsList[I])]) + ' ')
            else
              q4.SQL.Add(Format(
              'AND c.%0:s IS NULL ', [Trim(UsrFieldsList[I])]) + ' ');
          end;

          q4.ParamByName('DocTypeKey').AsInteger := InvDocTypeKey;
          q4.ParamByName('ClosingDate').AsDateTime := FClosingDate;
          q4.ParamByName('GoodKey').AsInteger := q3.FieldByName('goodkey').AsInteger;
          q4.ParamByName('CONTACT1').AsInteger := CurrentFromContactkey;
          q4.ParamByName('CONTACT2').AsInteger := CurrentToContactkey;
          for I := 0 to UsrFieldsList.Count - 1 do
          begin
            if not q.FieldByName(Trim(UsrFieldsList[I])).IsNull then
              q4.ParamByName(Trim(UsrFieldsList[I])).AsVariant := q3.FieldByName(Trim(UsrFieldsList[I])).AsVariant;
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

              DocumentParentKey := CreateHeaderInvDoc(
                CurrentFromContactkey,
                CurrentFromContactkey,
                q3.FieldByName('companykey').AsInteger,
                InvDocTypeKey,
                FCurUserContactKey,
                Tr2);

              CalculateInvBalance(q5);  // По компании строим запрос на складские остатки
              NewCardKey := CreatePositionInvDoc(                               
                DocumentParentKey,
                CurrentFromContactkey,
                CurrentFromContactkey,
                q3.FieldByName('companykey').AsInteger,
                q3.FieldByName('goodkey').AsInteger,
                0,
                InvDocTypeKey,
                FCurUserContactKey,
                Tr2,
                q5);
              q5.Close;

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
          for I := 0 to UsrFieldsList.Count - 1 do
          begin
            if not q3.FieldByName(Trim(UsrFieldsList[I])).IsNull then
              q4.SQL.Add(Format(
              'AND c.%0:s = :%0:s ', [Trim(UsrFieldsList[I])]))
            else
              q4.SQL.Add(Format(
              'AND c.%0:s IS NULL ', [Trim(UsrFieldsList[I])]));
          end;

          q4.ParamByName('ClosingDate').AsDateTime := FClosingDate;
          q4.ParamByName('DocTypeKey').AsInteger := InvDocTypeKey;
          q4.ParamByName('GoodKey').AsInteger := q3.FieldByName('GOODKEY').AsInteger;
          for I := 0 to UsrFieldsList.Count - 1 do
          begin
            if not q3.FieldByName(Trim(UsrFieldsList[I])).IsNull then
              q4.ParamByName(Trim(UsrFieldsList[I])).AsVariant := q3.FieldByName(Trim(UsrFieldsList[I])).AsVariant;
          end;

          q4.ExecQuery;

          if q4.RecordCount > 0 then
            NewCardKey := q4.FieldByName('CardKey').AsInteger
          else
            NewCardKey := -1;

          q4.Close;
        end;


        if NewCardKey > 0 then
        begin
          // обновление ссылок на родительскую карточку
          qUpdateCard.ParamByName('OldParent').AsInteger := CurrentCardKey;
          qUpdateCard.ParamByName('NewParent').AsInteger := NewCardKey;
          qUpdateCard.ExecQuery;
          qUpdateCard.Close;

          // обновление ссылок на документ прихода и дату прихода
          if FirstDocumentKey > -1 then
          begin
            qUpdateFirstDocKey.ParamByName('OldDockey').AsInteger := CurrentFirstDocKey;
            qUpdateFirstDocKey.ParamByName('NewDockey').AsInteger := FirstDocumentKey;
            qUpdateFirstDocKey.ParamByName('NewDate').AsDateTime := FirstDate;
            qUpdateFirstDocKey.ExecQuery;
            qUpdateFirstDocKey.Close;
          end;

          // обновление ссылок на карточки из движения
          qUpdateInvMovement.ParamByName('OldCardkey').AsInteger := CurrentCardKey;
          qUpdateInvMovement.ParamByName('NewCardkey').AsInteger := NewCardKey;
          qUpdateInvMovement.ExecQuery;
          qUpdateInvMovement.Close;

          // обновление в дополнительнных таблицах складских документов ссылок на складские карточки
          for I := 0 to CardkeyFieldCount - 1 do
          begin
            q4.SQL.Text :=
              'SELECT RDB$FIELD_NAME' +
              'FROM RDB$RELATION_FIELDS ' +
              'WHERE RDB$RELATION_NAME = :RelationName' +
              '  AND RDB$FIELD_NAME = :FieldName';
            q4.ParamByName('RelationName').AsString := CurrentRelationName;
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
                [CurrentRelationName, CardkeyFieldNames[I]]);

              q4.ParamByName('OldCardkey').AsInteger := CurrentCardKey;
              q4.ParamByName('NewCardkey').AsInteger := NewCardKey;
              q4.ParamByName('ClosingDate').AsDateTime := FClosingDate;
              q4.ExecQuery;
            end;
            q4.Close;

          end;
        end
        else begin
          LogEvent('Error rebinding card!');
        end;

        q3.Next;
      end;
      q3.Close;
      Tr2.Commit;
      LogEvent('Rebinding cards... OK');
    finally
      q3.Free;
      q4.Free;
      q5.Free;
      qUpdateInvMovement.Free;
      qUpdateFirstDocKey.Free;
      qUpdateCard.Free;
      Tr2.Free;
    end;
  end;

  procedure SetTriggerActive(SetActive: Boolean);
  const
    AlterTriggerCount = 3;
    AlterTriggerArray: array[0 .. AlterTriggerCount - 1] of String =
      ('INV_BD_MOVEMENT', 'INV_BU_MOVEMENT', 'INV_BU_CARD');  ///'AC_ENTRY_DO_BALANCE'
  var
    StateStr: String;
    I: Integer;
    q: TIBSQL;
    Tr: TIBTransaction;
  begin
    Tr := TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);
    try
      Tr.DefaultDatabase := FIBDatabase;
      Tr.StartTransaction;
      q.Transaction := Tr;

      if SetActive then
        StateStr := 'ACTIVE'
      else
        StateStr := 'INACTIVE';

      for I := 0 to AlterTriggerCount - 1 do
      begin
        q.SQL.Text := 'ALTER TRIGGER ' + AlterTriggerArray[I] + ' '  + StateStr;
        q.ExecQuery;
        q.Close;
      end;

      Tr.Commit;
    finally
      q.Free;
      Tr.Free;
    end;
  end;

begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  UsrFieldsList := TStringList.Create;

  LogEvent('Calculating inventory balance...');

  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q2.Transaction := Tr;

    if FOnlyCompanySaldo then
    begin
      q.SQL.Text :=
        'SELECT contactkey AS CompanyKey ' +
        'FROM GD_COMPANY gc ' +
        'WHERE fullname = :CompanyName ';
      q.ParamByName('CompanyName').AsString := FCompanyName;
      q.ExecQuery;

      CompanyKey := q.FieldByName('CompanyKey').AsInteger;
      q.Close;
    end;

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

   // список полей-признаков складской карточки
    q.SQL.Text :=
      'SELECT LIST(rf.rdb$field_name) as UsrFieldsList ' +
      'FROM RDB$RELATION_FIELDS rf ' +
      'WHERE rf.rdb$relation_name = ''INV_CARD'' ' +
      '  AND rf.rdb$field_name LIKE ''USR$%'' ';
    q.ExecQuery;

    UsrFieldsNames := q.FieldByName('UsrFieldsList').AsString;
    q.Close;

    UsrFieldsList.Text := StringReplace(UsrFieldsNames, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);

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

    CalculateInvBalance(q);  // строим запрос на складские остатки для компании

    DecimalSeparator := '.';   // тип Currency в SQL имееет DecimalSeparator = ','

    // Пройдем по остаткам ТМЦ
    while not q.EOF do                                                          
    begin

      if q.FieldByName('BALANCE').AsCurrency >= 0 then
      begin //приход на ContactKey от PseudoClientKey
        DocumentParentKey := CreateHeaderInvDoc(
          PseudoClientKey, // поставщик
          q.FieldByName('ContactKey').AsInteger,
          q.FieldByName('COMPANYKEY').AsInteger,
          InvDocTypeKey,
          FCurUserContactKey,
          Tr);

        CreatePositionInvDoc(
          DocumentParentKey,
          PseudoClientKey, // поставщик
          q.FieldByName('ContactKey').AsInteger,
          q.FieldByName('COMPANYKEY').AsInteger,
          q.FieldByName('GOODKEY').AsInteger,
          q.FieldByName('BALANCE').AsCurrency,
          InvDocTypeKey,
          FCurUserContactKey,
          Tr,
          q);
      end
      else begin
        // Приход на PseudoClientKey от ContactKey (с положит. кол-вом ТМЦ)
        DocumentParentKey := CreateHeaderInvDoc(
          q.FieldByName('ContactKey').AsInteger,
          PseudoClientKey,
          q.FieldByName('COMPANYKEY').AsInteger,
          InvDocTypeKey,
          FCurUserContactKey,
          Tr);

        CreatePositionInvDoc(
          DocumentParentKey,
          q.FieldByName('ContactKey').AsInteger,
          PseudoClientKey,
          q.FieldByName('COMPANYKEY').AsInteger,
          q.FieldByName('GOODKEY').AsInteger,
          -(q.FieldByName('BALANCE').AsCurrency),
          InvDocTypeKey,
          FCurUserContactKey,
          Tr,
          q);
      end;

      q.Next;
    end;
    q.Close;

    Tr.Commit;
    Tr.StartTransaction;

    RebindInvCards;

    //SetTriggerActive(False);

  //{  q.SQL.Text := 'DELETE FROM inv_movement WHERE movementdate < :Date';       /// удалятся при удалении карточки - удалении дока
  //  q.ParamByName('Date').AsString := FClosingDate;
  //  q.ExecQuery;

  //  q.SQL.Text := 'DELETE FROM inv_balance';                                    ///TODO: мб еще что-то
  //  q.ExecQuery;
  //
    Tr.Commit;
    Tr.StartTransaction;

    //SetTriggerActive(True);

  finally
    q.Free;
    q2.Free;
    Tr.Free;
    UsrFieldsList.Free;
  end;
  LogEvent('Calculating inventory balance... OK');
end;
 }


procedure TgsDBSqueeze.DeleteDocuments;
var
  q: TIBSQL;
  q2: TIBSQL; ///t
  Tr: TIBTransaction;
  Count: Integer; ///test

  procedure AddCascadeKeys(const ATableName: String);
  var
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
    LogEvent('[test] AddCascadeKeys...');
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
          '  pc.list_fields AS pk_fields ' +
          'FROM dbs_fk_constraints fc ' +
          '  JOIN dbs_pk_unique_constraints pc ' +
          '    ON pc.relation_name = fc.relation_name ' +
          '  AND pc.constraint_type = ''PRIMARY KEY'' ' +
          'WHERE ((fc.update_rule = ''CASCADE'') OR (fc.delete_rule = ''CASCADE'')) ' +        
          '  AND fc.ref_relation_name = :rln ' +
          '  AND pc.list_fields NOT LIKE ''%,%'' ' +
          '  AND fc.list_fields NOT LIKE ''%,%'' ' ;
        q.ParamByName('rln').AsString := UpperCase(TblsNamesList[0]);
        q.Open;

        while not q.EOF do
        begin
          // проверка типа поля на INTEGER
          q2.SQL.Text :=
            'SELECT ' +
            '  IIF(F.RDB$FIELD_TYPE = 8, ''INTEGER'', ''NOT INTEGER'') AS FIELD_TYPE ' +
            'FROM RDB$RELATION_FIELDS RF ' +
            '  JOIN RDB$FIELDS F ON (F.RDB$FIELD_NAME = RF.RDB$FIELD_SOURCE) ' +
            'WHERE (RF.RDB$RELATION_NAME = :RELAT_NAME) AND (RF.RDB$FIELD_NAME = :FIELD) ';
          q2.ParamByName('RELAT_NAME').AsString := UpperCase(q.FieldByName('relation_name').AsString);
          q2.ParamByName('FIELD').AsString := UpperCase(q.FieldByName('pk_fields').AsString);
          q2.ExecQuery;

          if AnsiCompareStr(q2.FieldByName('FIELD_TYPE').AsString, 'INTEGER') = 1 then //q2.FieldByName('FIELD_TYPE').AsString = ''INTEGER'' then
          begin
            q3.SQL.Text :=
              'SELECT ' +
              '  SUM(IIF(g_his_has(0, ' + q.FieldByName('pk_fields').AsString + ') = 0, 1, 0)) AS RealKolvo, ' +
              '  COUNT(g_his_include(0, ' + q.FieldByName('pk_fields').AsString + ')) AS Kolvo ' +
              'FROM ' +
              '  ' + q.FieldByName('relation_name').AsString + ' ' +
              'WHERE ' +
              '  g_his_has(0, ' + q.FieldByName('list_fields').AsString + ') = 1 ' +
              '  AND ' + q.FieldByName('pk_fields').AsString + ' > 147000000 ';
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
                          '  ' + q.FieldByName('relation_name').AsString + ' ' +
                          'WHERE ' +
                          '  g_his_has(0, ' + q.FieldByName('list_fields').AsString + ') = 1 ' +
                          '  AND ' + q.FieldByName('pk_fields').AsString + ' > 147000000 ';
                        q3.ExecQuery;

                        Count := Count + q3.FieldByName('RealKolvo').AsInteger;
                      until q3.FieldByName('RealKolvo').AsInteger = 0;

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
                    and(q.FieldByName('relation_name').AsString = MainDuplicateTblName) then // ситуация 3. заканчиваем цикл переобработки
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
          end;
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

        if GoToLast then
          GoToLast := False
        else
          TblsNamesList.Delete(0);
      end;
      Tr2.Commit;                                                               
      Tr2.StartTransaction;

      LogEvent('[test] COUNT real incuded: ' + IntToStr(Count));

      //------------------ исключение из HIS PK, на которые есть restrict/noAction
      q.SQL.Text :=
        'EXECUTE BLOCK AS BEGIN g_his_create(1, 0); END';  // HIS_2
      q.ExecSQL;
      Tr.Commit;
      Tr.StartTransaction;

      TblsNamesList.CommaText := AllProcessedTblsNames.CommaText;

      LogEvent('[test] AllProcessedTblsNames: ' + TblsNamesList.CommaText);
      while TblsNamesList.Count <> 0 do
      begin
        ProcTblsNamesList.Append(TblsNamesList[0]);

        // получим все FK cascade поля в таблице
        q.SQL.Text :=
          'SELECT ' +
          '  fc.list_fields AS fk_field, ' +
          '  pc.list_fields AS pk_field ' +
          'FROM dbs_fk_constraints fc ' +
          '  JOIN dbs_pk_unique_constraints pc ' +
          '    ON pc.relation_name = fc.relation_name ' +
          '  AND pc.constraint_type = ''PRIMARY KEY'' ' +
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
          q2.ExecQuery;

          Count := Count - q2.FieldByName('Kolvo').AsInteger;

          if q2.FieldByName('Kolvo').AsInteger > 0 then // есть смысл исключать по цепи
          begin
            q2.Close;
            IndexEnd := 0;
            IsFirstIteration := True;
            // исключение цепи из HIS   (исключение цепи, что ниже)
            while ProcTblsNamesList.Count <> 0 do
            begin
              if IsFirstIteration then  //движемся от конца к началу ProcTblsNamesList
              begin
                CascadeProcTbls.Add(ProcTblsNamesList[ProcTblsNamesList.Count-1]);   //список элементов цепи каскадной
                IndexEnd := AllProcessedTblsNames.IndexOf(CascadeProcTbls[0]);

                while CascadeProcTbls.Count <> 0 do
                begin
                  q2.SQL.Text :=
                    'SELECT ' +
                    '  fc.list_fields, ' +
                    '  fc.ref_relation_name, ' +
                    '  pc.list_fields AS pk_fields ' +
                    'FROM dbs_fk_constraints fc ' +
                    '  JOIN dbs_pk_unique_constraints pc ' +
                    '    ON pc.relation_name = fc.relation_name ' +
                    '    AND pc.constraint_type = ''PRIMARY KEY'' ' +
                    'WHERE ((fc.update_rule = ''CASCADE'') OR (fc.delete_rule = ''CASCADE'')) ' +    
                    '  AND fc.relation_name = :rln ' +
                    '  AND fc.ref_relation_name IN (';
                  for I:=0 to ProcTblsNamesList.Count-1 do                      /// TODO:или AllProc
                  begin
                    q2.SQL.Add(' ''' + ProcTblsNamesList[I] + '''');
                    if I <> ProcTblsNamesList.Count-1 then
                      q2.SQL.Add(',');
                  end;
                  q2.SQL.Add(') ');

                  q2.ParamByName('rln').AsString := CascadeProcTbls[0];     
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
                      CascadeProcTbls.Add(q2.FieldByName('ref_relation_name').AsString);

                    q2.Next;
                  end;
                  q2.Close;

                  if ProcTblsNamesList.IndexOf(CascadeProcTbls[0]) <> -1 then
                    ProcTblsNamesList.Delete(ProcTblsNamesList.IndexOf(CascadeProcTbls[0]));
                  CascadeProcTbls.Delete(0);
                end;
              end
              else begin   // движемся от начала к концу ProcTblsNamesList
                q2.SQL.Text :=
                  'SELECT ' +
                  '  fc.list_fields, ' +
                  '  fc.ref_relation_name, ' +
                  '  pc.list_fields AS pk_fields ' +
                  'FROM dbs_fk_constraints fc ' +
                  '  JOIN dbs_pk_unique_constraints pc ' +
                  '    ON pc.relation_name = fc.relation_name ' +
                  '    AND pc.constraint_type = ''PRIMARY KEY'' ' +
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

        TblsNamesList.Delete(0);
      end;
      LogEvent('[test] COUNT HIS after exclude: ' + IntToStr(Count));

      q.Close;
      q.SQL.Text :=
        'EXECUTE BLOCK AS BEGIN g_his_destroy(1); END';
      q.ExecSQL;
      Tr.Commit;
      Tr.StartTransaction;

      LogEvent('[test] AddCascadeKeys... OK');
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
  q2 := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q2.Transaction := Tr;

    LogEvent('Deleting from DB... ');

    q.SQL.Text :=
      'EXECUTE BLOCK AS BEGIN g_his_create(0, 0); END';
    q.ExecQuery;

    q.SQL.Text :=
      'SELECT COUNT(g_his_include(0, id)) as Kolvo FROM gd_document WHERE documentdate < :Date';
    q.ParamByName('Date').AsDateTime := FClosingDate;
    q.ExecQuery;

    Count := q.FieldByName('Kolvo').AsInteger;
    q.Close;
    Tr.Commit;
    Tr.StartTransaction;

    LogEvent('COUNT in HIS without cascade: ' + IntToStr(Count));

    AddCascadeKeys('GD_DOCUMENT');
    LogEvent('COUNT in HIS with CASCADE: ' + IntToStr(Count));

    q.SQL.Text :=
      'SELECT relation_name as RN, list_fields AS FN ' +
      'FROM dbs_pk_unique_constraints ' +
      'WHERE constraint_type = ''PRIMARY KEY'' ' +
      '  AND (NOT list_fields LIKE ''%,%'') ';
    q.ExecQuery;
    while not q.EOF do
    begin
      // проверка типа поля PK на INTEGER
      q2.SQL.Text :=
        'SELECT ' +
        '  IIF(F.RDB$FIELD_TYPE = 8, ''INTEGER'', ''NOT INTEGER'') AS FIELD_TYPE ' +
        'FROM RDB$RELATION_FIELDS RF ' +
        '  JOIN RDB$FIELDS F ON (F.RDB$FIELD_NAME = RF.RDB$FIELD_SOURCE) ' +
        'WHERE (RF.RDB$RELATION_NAME = :RELAT_NAME) AND (RF.RDB$FIELD_NAME = :FIELD) ';
      q2.ParamByName('RELAT_NAME').AsString := UpperCase(q.FieldByName('RN').AsString);
      q2.ParamByName('FIELD').AsString := UpperCase(q.FieldByName('FN').AsString);
      q2.ExecQuery;

      if q2.FieldByName('FIELD_TYPE').AsString = 'INTEGER' then
      begin
        q2.Close;
        q2.SQL.Text :=
          'DELETE FROM ' + q.FieldByName('RN').AsString + ' ' +
          'WHERE g_his_has(0, ' +  q.FieldByName('FN').AsString  +') = 1 ' +
          '  AND ' + q.FieldByName('FN').AsString + ' > 147000000 ';
        q2.ExecQuery;
      end
      else
        q2.Close;
      q.Next;
    end;

    Tr.Commit;
    Tr.StartTransaction;

    q.SQL.Text :=
      'EXECUTE BLOCK AS BEGIN g_his_destroy(0); END';
    q.ExecQuery;

    Tr.Commit;
    LogEvent('Deleting from DB... OK');
  finally
    q.Free;
    q2.Free;
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
      'INSERT INTO DBS_INACTIVE_TRIGGERS (TRIGGER_NAME) ' +
      'SELECT RDB$TRIGGER_NAME ' +
      'FROM RDB$TRIGGERS ' +
      'WHERE (RDB$TRIGGER_INACTIVE <> 0) AND (RDB$TRIGGER_INACTIVE IS NOT NULL) ' + ///=1
      '  AND ((RDB$SYSTEM_FLAG = 0) OR (RDB$SYSTEM_FLAG IS NULL)) ';                                           
    q.ExecQuery;
    
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
      'INSERT INTO DBS_INACTIVE_INDICES (INDEX_NAME) ' +
      'SELECT RDB$INDEX_NAME ' +
      'FROM RDB$INDICES ' +
      'WHERE (RDB$INDEX_INACTIVE <> 0) AND (RDB$INDEX_INACTIVE IS NOT NULL) ' + ///=1
      '  AND ((RDB$SYSTEM_FLAG = 0) OR (RDB$SYSTEM_FLAG IS NULL))';
    q.ExecQuery;

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

    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE CN CHAR(31); ' +
      '  DECLARE VARIABLE RN CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT constraint_name, relation_name ' +
      '    FROM DBS_FK_CONSTRAINTS ' +
      '    INTO :CN, :RN ' +
      '  DO ' +
      '    EXECUTE STATEMENT ''ALTER TABLE '' || :RN || '' DROP CONSTRAINT '' || :CN; ' +
      'END';
    q.ExecQuery;

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

procedure TgsDBSqueeze.RestoreDB;                                               ///TODO: GD_RUID почистить
var
  Tr: TIBTransaction;
  q: TIBSQL;
  S: String;

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
      '    WHERE ' +
      '      constraint_name NOT LIKE ''dbs_%'' ' +
      '    INTO :S ' +
      '  DO BEGIN ' +
      '    SUSPEND; ' +
      '    EXECUTE STATEMENT :S WITH AUTONOMOUS TRANSACTION; ' +
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

    //Disconnect;
    //Connect;

    //Tr.DefaultDatabase := FIBDatabase;
   // Tr.StartTransaction;

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

procedure TgsDBSqueeze.TestAndCreateMetadata;
var
  q: TIBSQL;
  q2: TIBSQL;
  Tr: TIBTransaction;

  procedure CreateDBSTmpAcSaldo;
  begin
    if RelationExist2('DBS_TMP_AC_SALDO', Tr) then
    begin
//      q.SQL.Text := 'DELETE FROM DBS_TMP_AC_SALDO';       ///tmp
//      q.ExecQuery;
//      LogEvent('Table DBS_TMP_AC_SALDO exists.');

////test
      q.SQL.Text := 'DROP TABLE DBS_TMP_AC_SALDO';       ///tmp                 ///TODO: убрать. временное решение для березы
      q.ExecQuery;
      Tr.Commit;
      Tr.StartTransaction;
       q2.SQL.Text :=
        'SELECT LIST(rf.rdb$field_name, '' INTEGER, '') AS AllUsrFieldsList ' +
        'FROM RDB$RELATION_FIELDS rf ' +
        'WHERE rf.rdb$relation_name = ''AC_ACCOUNT'' ' +
        '  AND rf.rdb$field_name LIKE ''USR$%'' ';
      q2.ExecQuery;

      q.SQL.Text :=
        'CREATE TABLE DBS_TMP_AC_SALDO ( ' +
        '  ID INTEGER, ' +
        '  COMPANYKEY INTEGER, ' +
        '  CURRKEY    INTEGER, ' +
        '  ACCOUNTKEY INTEGER, ' +
        '  MASTERDOCKEY  INTEGER, ' +
        '  DOCUMENTKEY INTEGER, ' +
        '  RECORDKEY   INTEGER, ' +
        '  ACCOUNTPART VARCHAR(1), ' +
        '  CREDITNCU  DECIMAL(15,4), ' +
        '  CREDITCURR DECIMAL(15,4), ' +
        '  CREDITEQ   DECIMAL(15,4), ' +
        '  DEBITNCU   DECIMAL(15,4), ' +
        '  DEBITCURR  DECIMAL(15,4), ' +
        '  DEBITEQ    DECIMAL(15,4), ' +
        q2.FieldByName('AllUsrFieldsList').AsString + ' INTEGER, ' +
        '  PRIMARY KEY (ID))';
      q.ExecQuery;
      q2.Close;
      LogEvent('Table DBS_TMP_AC_SALDO has been created.');
//////
    end else
    begin

      q2.SQL.Text :=
        'SELECT LIST(rf.rdb$field_name, '' INTEGER, '') AS AllUsrFieldsList ' +
        'FROM RDB$RELATION_FIELDS rf ' +
        'WHERE rf.rdb$relation_name = ''AC_ACCOUNT'' ' +
        '  AND rf.rdb$field_name LIKE ''USR$%'' ';
      q2.ExecQuery;

      q.SQL.Text :=
        'CREATE TABLE DBS_TMP_AC_SALDO ( ' +
        '  ID INTEGER, ' +
        '  COMPANYKEY INTEGER, ' +
        '  CURRKEY    INTEGER, ' +
        '  ACCOUNTKEY INTEGER, ' +
        '  MASTERDOCKEY  INTEGER, ' +
        '  DOCUMENTKEY INTEGER, ' +
        '  RECORDKEY   INTEGER, ' +
        '  ACCOUNTPART VARCHAR(1), ' +
        '  CREDITNCU  DECIMAL(15,4), ' +
        '  CREDITCURR DECIMAL(15,4), ' +
        '  CREDITEQ   DECIMAL(15,4), ' +
        '  DEBITNCU   DECIMAL(15,4), ' +
        '  DEBITCURR  DECIMAL(15,4), ' +
        '  DEBITEQ    DECIMAL(15,4), ' +
        q2.FieldByName('AllUsrFieldsList').AsString + ' INTEGER, ' +
        '  PRIMARY KEY (ID))';
      q.ExecQuery;
      q2.Close;
      LogEvent('Table DBS_TMP_AC_SALDO has been created.');
    end;
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
       /// '  PRIMARY KEY PK_MY_TABLE  (CONSTRAINT_NAME)) ';
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

    CreateDBSInactiveTriggers;
    CreateDBSInactiveIndices;
    CreateDBSPkUniqueConstraints;
    CreateDBSFKConstraints;
    CreateUDFs;

    Tr.Commit;
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.GetDBSizeEvent;                   ///TODO: неправильный размер файлов больше 4 Гб
var
  hFile, fileSize: Int64;

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

begin
  hFile := FileOpen(FDatabaseName, fmOpenRead);
  fileSize := GetFileSize(hFile, nil);
  FileClose(hFile);

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
