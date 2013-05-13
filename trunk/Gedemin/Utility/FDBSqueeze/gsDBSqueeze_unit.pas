unit gsDBSqueeze_unit;

interface

uses
  IB, IBDatabase, IBSQL, Classes, gd_ProgressNotifier_unit;

type
  TOnLogEvent = procedure(const S: String) of object;
  TActivateFlag = (aiActivate, aiDeactivate);
  TOnSetItemsCbbEvent = procedure(const ACompanies: TStringList) of object;

  TgsDBSqueeze = class(TObject)
  private
    FCompanyName: String;
    FDatabaseName: String;
    FDocumentdateWhereClause: String;
    FIBDatabase: TIBDatabase;
    FOnProgressWatch: TProgressWatchEvent;
    FOnSetItemsCbbEvent: TOnSetItemsCbbEvent;                                   
    FPassword: String;
    FUserName: String;

    function GetConnected: Boolean;

    procedure LogEvent(const AMsg: String);

  public
    constructor Create;
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    // подсчет и формирование бухгалтерского сальдо
    procedure CalculateAcSaldo;
    // подсчет и формирование складских остатков
    //procedure CalculateInvSaldo;
    procedure DeleteDocuments;
    procedure PrepareDB;
    procedure RestoreDB;
    procedure SetItemsCbbEvent;
    procedure TestAndCreateMetadata;

    property CompanyName: String read FCompanyName write FCompanyName;
    property Connected: Boolean read GetConnected;
    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property DocumentdateWhereClause: String read FDocumentdateWhereClause
      write FDocumentdateWhereClause;
    property OnProgressWatch: TProgressWatchEvent read FOnProgressWatch
      write FOnProgressWatch;
    property OnSetItemsCbbEvent: TOnSetItemsCbbEvent read FOnSetItemsCbbEvent
      write FOnSetItemsCbbEvent;
    property Password: String read FPassword write FPassword;
    property UserName: String read FUserName write FUserName;
  end;

implementation

uses
  SysUtils, mdf_MetaData_unit;

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
begin
  FIBDatabase.DatabaseName := FDatabaseName;
  FIBDatabase.LoginPrompt := False;
  FIBDatabase.Params.Text :=
    'user_name=' + FUserName + #13#10 +
    'password=' + FPassword + #13#10 +
    'lc_ctype=win1251';
  FIBDatabase.Connected := True;
  LogEvent('Connecting to DB... OK');
end;

procedure TgsDBSqueeze.Disconnect;
begin
  FIBDatabase.Connected := False;
  LogEvent('Disconnecting from DB... OK');
end;

procedure TgsDBSqueeze.CalculateAcSaldo;  // подсчет бухгалтерского сальдо
var
  q: TIBSQL;
  q2: TIBSQL;
  q3: TIBSQL;
  q4: TIBSQL;
  q5: TIBSQL;
  Tr: TIBTransaction;
  CompanyKey: String;
  NewMasterDocKey: String;
  NewDetailDocKey: String;
  NewRecordKey: String;
  UsrFieldsList: TStringList;

  procedure DeleteOldAcEntry; // удаление старых бухгалтерских проводок
  begin
    LogEvent('Deleting old entries...');                                        {TODO: Очень долго-искать проблему(?)}
    {q.SQL.Text :=
      'DELETE FROM AC_RECORD r ' +
      'WHERE r.id IN (' +
      '  SELECT DISTINCT recordkey ' +
      '  FROM AC_ENTRY ' +
      '  WHERE companykey = ' +  ' ''' + CompanyKey + ''' ' +
      '    AND entrydate < ' + ' ''' + FDocumentdateWhereClause +  ''' ' +
      ') ';
    q.ExecQuery;}

    q.SQL.Text := ' SELECT DISTINCT recordkey as rkey FROM AC_ENTRY ' +
      'WHERE companykey = ' + '''' + CompanyKey + ''' ' +
      '  AND entrydate < ' + ' ''' + FDocumentdateWhereClause +  ''' ';
    q.ExecQuery;
    while not q.EOF do
    begin
      q2.SQL.Text := 'DELETE FROM AC_RECORD r WHERE r.id = ' +''''+ q.FieldByName('rkey').AsString + '''';
      q2.ExecQuery;
      q.Next;
    end;
    q.Close;

    Tr.Commit;
    LogEvent('Deleting old entries... OK');
  end;

  procedure CreateMasterDoc;  // создание документа для бух проводок
  begin
    q.SQL.Text :=
      'SELECT ' +
      '  current_date  AS CUR_DATE, ' +
      '  gd.id         AS DOCTYPE, ' +
      '  gu.contactkey AS CUR_USER_CONTACTKEY ' +
      'FROM GD_DOCUMENTTYPE gd, GD_USER gu ' +
      'WHERE gd.name = ''Хозяйственная операция'' ' +
      '  AND gu.ibname = CURRENT_USER ';
    q.ExecQuery;

    q2.SQL.Text :=
      'SELECT GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0) AS NEW_ID ' +
      'FROM RDB$DATABASE ';
    q2.ExecQuery;

    NewMasterDocKey := q2.FieldByName('NEW_ID').AsString;
    q2.Close;

    q2.SQL.Text :=
      'INSERT INTO GD_DOCUMENT ( ' +
      '  ID, ' +
      '  DOCUMENTTYPEKEY, ' +
      '  NUMBER, ' +
      '  DOCUMENTDATE, ' +
      '  COMPANYKEY, ' +
      '  AFULL, ' +
      '  ACHAG, ' +
      '  AVIEW, ' +
      '  CREATORKEY, ' +
      '  EDITORKEY) ' +
      'VALUES (' + ' '' ' +
         NewMasterDocKey + ' '' ' + ', ' + ' '' ' +
         q.FieldByName('DOCTYPE').AsString + ' '' ' + ', ' + ' '' ' +
         '1' + ' '' ' + ', ' +  ' '' ' +
         q.FieldByName('CUR_DATE').AsString + ' '' '  + ', ' +  ' '' ' +
         CompanyKey + ' '' ' +  ', ' + ' '' ' +
         '-1' + ' '' ' +  ', ' + ' '' ' +
         '-1' + ' '' ' +  ', ' + ' '' ' +
         '-1' + ' '' ' +  ', ' + ' '' ' +
         q.FieldByName('CUR_USER_CONTACTKEY').AsString + ' '' ' + ', ' + ' '' ' +
         q.FieldByName('CUR_USER_CONTACTKEY').AsString +  ' '' ' +
      ' ) ';
    q2.ExecQuery;

    Tr.Commit;
    Tr.StartTransaction;
    LogEvent('Master document has been created.');
  end;

  procedure CreateDetailDoc;                                                    {TODO: можно использовать вместо него masterDoc}
  begin
    q.SQL.Text :=
      'SELECT ' +
      '  current_date  AS CUR_DATE, ' +
      '  gd.id         AS DOCTYPE, ' +
      '  gu.contactkey AS CUR_USER_CONTACTKEY ' +
      'FROM GD_DOCUMENTTYPE gd, GD_USER gu ' +
      'WHERE gd.name = ''Хозяйственная операция'' ' +
      '  AND gu.ibname = CURRENT_USER ';
    q.ExecQuery;

    q2.SQL.Text :=
      'SELECT GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0) AS NEW_ID ' +
      'FROM RDB$DATABASE ';
    q2.ExecQuery;

    NewDetailDocKey := q2.FieldByName('NEW_ID').AsString;
    q2.Close;

    q2.SQL.Text :=
      'INSERT INTO GD_DOCUMENT ( ' +
      '  ID, ' +
      '  PARENT, ' +
      '  DOCUMENTTYPEKEY, ' +
      '  NUMBER, ' +
      '  DOCUMENTDATE, ' +
      '  COMPANYKEY, ' +
      '  AFULL, ' +
      '  ACHAG, ' +
      '  AVIEW, ' +
      '  CREATORKEY, ' +
      '  EDITORKEY) ' +
      'VALUES (' + ' '' ' +
         NewDetailDocKey + ' '' ' +  ', ' +  ' '' ' +
         NewMasterDocKey  + ' '' ' +  ', ' +  ' '' ' +
         q.FieldByName('DOCTYPE').AsString + ' '' ' +  ', ' +  ' '' ' +
         '1' + ' '' ' +  ', ' +  ' '' ' +
         q.FieldByName('CUR_DATE').AsString + ' '' ' +  ', ' +  ' '' ' +
         CompanyKey + ' '' ' +  ', ' +  ' '' ' +
         '-1' + ' '' ' +  ', ' + ' '' ' +
         '-1' + ' '' ' +  ', ' + ' '' ' +
         '-1' + ' '' ' +  ', ' + ' '' ' +
         q.FieldByName('CUR_USER_CONTACTKEY').AsString + ' '' ' +  ', ' +  ' '' ' +
         q.FieldByName('CUR_USER_CONTACTKEY').AsString + ' '' ' +
      ' ) ';
    q2.ExecQuery;

    Tr.Commit;
    Tr.StartTransaction;
    LogEvent('Detail document has been created. ');
  end;

  procedure CalculateAcSaldo_CreateAcEntries;  // вычисление бух сальдо и создание проводок с остатками
  var
    I: Integer;
  begin
    LogEvent('[test] CalculateAcSaldo_CreateAcEntries...');
    //-------------------------------------------- вычисление сальдо для счета
    q.SQL.Text :=
      'SELECT ' +
      '  current_date AS CUR_DATE, ' +
      '  atr.id AS NEW_TRANSACTIONKEY, ' +        // 807001
      '  atrr.id AS NEW_TRRECORDKEY, ' +          // 807100
      '  aac.id AS OSTATKI_ACCOUNTKEY ' +
      'FROM AC_TRANSACTION atr, AC_ACCOUNT aac ' +
      '  JOIN AC_TRRECORD atrr ON atr.id = atrr.transactionkey ' +
      'WHERE atr.name = ''Произвольные проводки'' ' +                           { TODO: 'Произвольные проводки'? }
      '  AND aac.fullname = ''00 Остатки'' ';
    q.ExecQuery;

    q2.SQL.Text :=
      'SELECT ac.id, ' +
      '  ac.usr$gs_customer,/* ac.usr$fa_groupkey,*/ ac.usr$gs_department, /* ac.usr$fa_invcardkey,*/ ac.usr$gs_document, ac.usr$gs_good, ' +
      '  ac.usr$gs_service,  ac.usr$gs_employee, /*ac.usr$wg_feetypekey,*/  ac.usr$vattype_key,   ac.usr$gs_contract, ac.usr$gs_economicactivity, ' +
      '  ac.usr$gs_expenses,/* ac.usr$bte_carkey,*/  ac.usr$gs_saletaxrate/*, ac.usr$bfds_object*/ ' +
      'FROM AC_ACCOUNT ac ' +
      'WHERE ac.id IN ( ' +
      '  SELECT DISTINCT accountkey ' +
      '  FROM AC_ENTRY ' +
      '  WHERE companykey = :COMPANY_KEY ' +
      '    AND entrydate < :ENTRY_DATE ' +
      '  ) ';
    q2.ParamByName('COMPANY_KEY').AsString := CompanyKey;
    q2.ParamByName('ENTRY_DATE').AsString := FDocumentdateWhereClause;
    q2.ExecQuery;

    while (not q2.EOF) do // считаем сальдо для каждого счета
    begin
      // получаем cписок аналитик, по которым ведется учет для счета
      if q2.FieldByName('usr$gs_customer').AsInteger = 1    then UsrFieldsList.Add('usr$gs_customer');
      // if q2.FieldByName('usr$fa_groupkey').AsInteger = 1    then UsrFieldsList.Add('usr$fa_groupkey');
      if q2.FieldByName('usr$gs_department').AsInteger = 1  then UsrFieldsList.Add('usr$gs_department');
      // if q2.FieldByName('usr$fa_invcardkey').AsInteger = 1  then UsrFieldsList.Add('usr$fa_invcardkey');
      if q2.FieldByName('usr$gs_document').AsInteger = 1    then UsrFieldsList.Add('usr$gs_document');
      if q2.FieldByName('usr$gs_good').AsInteger = 1        then UsrFieldsList.Add('usr$gs_good');
      if q2.FieldByName('usr$gs_service').AsInteger = 1     then UsrFieldsList.Add('usr$gs_service');
      if q2.FieldByName('usr$gs_employee').AsInteger = 1    then UsrFieldsList.Add('usr$gs_employee');
      // if q2.FieldByName('usr$wg_feetypekey').AsInteger = 1  then UsrFieldsList.Add('usr$wg_feetypekey');
      if q2.FieldByName('usr$vattype_key').AsInteger = 1    then UsrFieldsList.Add('usr$vattype_key');
      if q2.FieldByName('usr$gs_contract').AsInteger = 1    then UsrFieldsList.Add('usr$gs_contract');
      if q2.FieldByName('usr$gs_economicactivity').AsInteger = 1 then UsrFieldsList.Add('usr$gs_economicactivity');
      if q2.FieldByName('usr$gs_expenses').AsInteger = 1    then UsrFieldsList.Add('usr$gs_expenses');
      // if q2.FieldByName('usr$bte_carkey').AsInteger = 1     then UsrFieldsList.Add('usr$bte_carkey');
      if q2.FieldByName('usr$gs_saletaxrate').AsInteger = 1 then UsrFieldsList.Add('usr$gs_saletaxrate');
      // if q2.FieldByName('usr$bfds_object').AsInteger = 1    then UsrFieldsList.Add('usr$bfds_object');

      // подсчет сальдо в разрезе компании, счета, валюты, аналитик
      q3.SQL.Text :=
        'SELECT currkey, ' +
        '  SUM(debitncu)  - SUM(creditncu)  AS SALDO_NCU, '  +
        '  SUM(debitcurr) - SUM(creditcurr) AS SALDO_CURR, ' +
        '  SUM(debiteq)   - SUM(crediteq)   AS SALDO_EQ';
      for I := 0 to UsrFieldsList.Count - 1 do
          q3.SQL.Add(', ' + UsrFieldsList[i]);
      q3.SQL.Add( ' ' +
        'FROM AC_ENTRY ' +
        'WHERE companykey = :COMPANY_KEY ' +
        '  AND accountkey = :ACCOUNT_KEY ' +
        '  AND entrydate < :ENTRY_DATE ' +
        'GROUP BY currkey');
      for I := 0 to UsrFieldsList.Count - 1 do
          q3.SQL.Add(', ' + UsrFieldsList[I]);

      q3.ParamByName('COMPANY_KEY').AsString := CompanyKey;
      q3.ParamByName('ACCOUNT_KEY').AsString := q2.FieldByName('id').AsString ;
      q3.ParamByName('ENTRY_DATE').AsString := FDocumentdateWhereClause;
      q3.ExecQuery;
    //-------------------------------------------- вставка записей для проводок
      while not q3.EOF do
      begin
        q4.SQL.Text :=
          'SELECT GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0) AS NEW_ID ' +
          'FROM RDB$DATABASE ';
        q4.ExecQuery;

        NewRecordKey := q4.FieldByName('NEW_ID').AsString;
        q4.Close;

        q4.SQL.Text :=
          'INSERT INTO ac_record (' +
          '  ID, ' +
          '  RECORDDATE, ' +
          '  TRRECORDKEY, ' +
          '  TRANSACTIONKEY, ' +
          '  DOCUMENTKEY, ' +
          '  MASTERDOCKEY, ' +
          '  AFULL, ' +
          '  ACHAG, ' +
          '  AVIEW, ' +
          '  COMPANYKEY ' +
          ')' +
          'VALUES ( ' + ' '' ' +
             NewRecordKey + ' '' ' + ', ' + ' '' ' +
             q.FieldByName('CUR_DATE').AsString + ' '' ' + ', ' + ' '' ' +
             q.FieldByName('NEW_TRRECORDKEY').AsString + ' '' ' + ', ' + ' '' ' +
             q.FieldByName('NEW_TRANSACTIONKEY').AsString + ' '' ' + ', ' + ' '' ' +
             NewDetailDocKey + ' '' ' + ', ' + ' '' ' +
             NewMasterDocKey + ' '' ' + ', ' + ' '' ' +
             '-1' + ' '' ' +  ', ' + ' '' ' +
             '-1' + ' '' ' +  ', ' + ' '' ' +
             '-1' + ' '' ' +  ', ' + ' '' ' +
             CompanyKey + ' '' ' +
          ') ';
        q4.ExecQuery;

        DecimalSeparator := '.';   // тип Currency в SQL имееет DecimalSeparator = ','
       { ///test
        LogEvent('SALDO_NCU=' + q3.FieldByName('SALDO_NCU').AsString + '  ');
        LogEvent(CurrToStr(q3.FieldByName('SALDO_NCU').AsCurrency));
        LogEvent('SALDO_CURR=' + q3.FieldByName('SALDO_CURR').AsString + '  ');
        LogEvent(CurrToStr(Abs(q3.FieldByName('SALDO_CURR').AsCurrency)));
        LogEvent('SALDO_EQ=' + q3.FieldByName('SALDO_EQ').AsString + '  ');
        LogEvent(CurrToStr(Abs(q3.FieldByName('SALDO_EQ').AsCurrency)));
        LogEvent('UsrFieldsList: ');
        for I := 0 to UsrFieldsList.Count - 1 do
          LogEvent(', ' + UsrFieldsList[I]);
        LogEvent('end UsrFieldsList');
        ///  }

        q5.SQL.Text :=                                                          { TODO : error при включенных FK (AC_FK_ENTRY_RK) }
          'INSERT INTO ac_entry (' +
          '  ID, ' +
          '  ENTRYDATE, ' +
          '  RECORDKEY, ' +
          '  TRANSACTIONKEY, ' +
          '  DOCUMENTKEY, ' +
          '  MASTERDOCKEY, ' +
          '  COMPANYKEY, ' +
          '  ACCOUNTKEY, ' +
          '  CURRKEY, ' +
          '  ACCOUNTPART, ';
        if (q3.FieldByName('SALDO_NCU').AsCurrency < 0.0000)
          or (q3.FieldByName('SALDO_CURR').AsCurrency < 0.0000)
          or (q3.FieldByName('SALDO_EQ').AsCurrency < 0.0000) then
            q5.SQL.Add('  CREDITNCU, ' +'  CREDITCURR, ' + '  CREDITEQ')
        else
          q5.SQL.Add('  DEBITNCU, ' + '  DEBITCURR, ' + '  DEBITEQ');

        for I := 0 to UsrFieldsList.Count - 1 do
        begin
          if q3.FieldByName(UsrFieldsList[I]).AsString <> '' then
            q5.SQL.Add(', ' + UsrFieldsList[I]);
        end;                                                                    { TODO: протестить }

        q5.SQL.Add(') ' +
          'VALUES ( ' +
             'GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + ' '' ' +
             q.FieldByName('CUR_DATE').AsString + ' '' ' + ', ' + ' '' ' +
             NewRecordKey + ' '' ' + ', ' + ' '' ' +
             q.FieldByName('NEW_TRANSACTIONKEY').AsString + ' '' ' + ', ' + ' '' ' +
             NewDetailDocKey + ' '' ' + ', ' + ' '' ' +
             NewMasterDocKey + ' '' ' +', ' + ' '' ' +
             CompanyKey + ' '' ' + ', ' +  ' '' ' +
             q2.FieldByName('id').AsString + ' '' ' + ', ' + ' '' ' +
             q3.FieldByName('currkey').AsString + ' '' ');

        if (q3.FieldByName('SALDO_NCU').AsCurrency < 0.0000)
          or (q3.FieldByName('SALDO_CURR').AsCurrency < 0.0000)
          or (q3.FieldByName('SALDO_EQ').AsCurrency < 0.0000) then
            q5.SQL.Add(
              ', ''C''' +
              ', '' ' + CurrToStr(Abs(q3.FieldByName('SALDO_NCU').AsCurrency)) + ' '' ' +
              ', '' ' + CurrToStr(Abs(q3.FieldByName('SALDO_CURR').AsCurrency)) + ' '' ' +
              ', '' ' + CurrToStr(Abs(q3.FieldByName('SALDO_EQ').AsCurrency)) + ' '' ')
        else
          q5.SQL.Add(
            ', ''D''' +
            ', '' ' + q3.FieldByName('SALDO_NCU').AsString + ' '' ' +
            ', '' ' + q3.FieldByName('SALDO_CURR').AsString + ' '' ' +
            ', '' ' + q3.FieldByName('SALDO_EQ').AsString + ' '' ');

        for I := 0 to UsrFieldsList.Count - 1 do
        begin
          if q3.FieldByName(UsrFieldsList[I]).AsString <> '' then
            q5.SQL.Add(', ''' + q3.FieldByName(UsrFieldsList[I]).AsString + ''' ');
        end;
        q5.SQL.Add(')');
        q5.ExecQuery;

        //----------------- проводка по счету '00 Остатки'
      
        q5.SQL.Text :=
          'INSERT INTO ac_entry (' +
          '  ID, ' +
          '  ENTRYDATE, ' +
          '  RECORDKEY, ' +
          '  TRANSACTIONKEY, ' +
          '  DOCUMENTKEY, ' +
          '  MASTERDOCKEY, ' +
          '  COMPANYKEY, ' +
          '  ACCOUNTKEY, ' +
          '  CURRKEY, ' +
          '  ACCOUNTPART, ';
        if (q3.FieldByName('SALDO_NCU').AsCurrency < 0.0000)
          or (q3.FieldByName('SALDO_CURR').AsCurrency < 0.0000)
          or (q3.FieldByName('SALDO_EQ').AsCurrency < 0.0000) then
            q5.SQL.Add('  CREDITNCU, ' +'  CREDITCURR, ' + '  CREDITEQ ')
        else
          q5.SQL.Add('  DEBITNCU, ' + '  DEBITCURR, ' + '  DEBITEQ ');

        for I := 0 to UsrFieldsList.Count - 1 do
        begin
          if q3.FieldByName(UsrFieldsList[I]).AsString <> '' then
            q5.SQL.Add(', ' + UsrFieldsList[I]);
        end;
        q5.SQL.Add(') ' +
          'VALUES ( ' +
             'GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0), ' + ' '' ' +
             q.FieldByName('CUR_DATE').AsString + ' '' ' + ', ' + ' '' ' +
             NewRecordKey + ' '' ' + ', ' + ' '' ' +
             q.FieldByName('NEW_TRANSACTIONKEY').AsString + ' '' ' + ', ' + ' '' ' +
             NewDetailDocKey + ' '' ' + ', ' + ' '' ' +
             NewMasterDocKey + ' '' ' +', ' + ' '' ' +
             CompanyKey + ' '' ' + ', ' +  ' '' ' +
             q.FieldByName('OSTATKI_ACCOUNTKEY').AsString + ' '' ' + ', ' + ' '' ' +
             q3.FieldByName('currkey').AsString + ' '' ');

        if (q3.FieldByName('SALDO_NCU').AsCurrency < 0.0000)
          or (q3.FieldByName('SALDO_CURR').AsCurrency < 0.0000)
          or (q3.FieldByName('SALDO_EQ').AsCurrency < 0.0000) then
            q5.SQL.Add(
              ', ''C''' +
              ', '' ' + CurrToStr(Abs(q3.FieldByName('SALDO_NCU').AsCurrency)) + ' '' ' +
              ', '' ' + CurrToStr(Abs(q3.FieldByName('SALDO_CURR').AsCurrency)) + ' '' ' +
              ', '' ' + CurrToStr(Abs(q3.FieldByName('SALDO_EQ').AsCurrency)) + ' '' ')
        else
          q5.SQL.Add(
            ', ''D''' +
            ', '' ' + q3.FieldByName('SALDO_NCU').AsString + ' '' ' +
            ', '' ' + q3.FieldByName('SALDO_CURR').AsString + ' '' ' +
            ', '' ' + q3.FieldByName('SALDO_EQ').AsString + ' '' ');

        for I := 0 to UsrFieldsList.Count - 1 do
        begin
          if q3.FieldByName(UsrFieldsList[I]).AsString <> '' then
            q5.SQL.Add(', ''' + q3.FieldByName(UsrFieldsList[I]).AsString + ''' ');
        end;
        q5.SQL.Add(')');
        q5.ExecQuery;

        q3.Next;
      end;
      UsrFieldsList.Clear;
      q2.Next;
      q3.Close;
      LogEvent('[test] account closed');
    end;
    q.Close;
    q2.Close;
    Tr.Commit;
    LogEvent('[test] CalculateAcSaldo_CreateAcEntries... OK');
    Tr.StartTransaction;
  end;

begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  q3 := TIBSQL.Create(nil);
  q4 := TIBSQL.Create(nil);
  q5 := TIBSQL.Create(nil);
  UsrFieldsList := TStringList.Create;
  try
    LogEvent('Calculating entry balance...');
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q2.Transaction := Tr;
    q3.Transaction := Tr;
    q4.Transaction := Tr;
    q5.Transaction := Tr;

    q.SQL.Text :=
      'SELECT gc.contactkey as CompKey ' +
      'FROM GD_COMPANY gc ' +
      'WHERE gc.fullname = :compName ';
    q.ParamByName('compName').AsString := FCompanyName;
    q.ExecQuery;

    CompanyKey := q.FieldByName('CompKey').AsString;
    q.Close;

    CreateMasterDoc;
    CreateDetailDoc;
    CalculateAcSaldo_CreateAcEntries;
    ///DeleteOldAcEntry;                                                         { TODO :  13.05.2013 12:04:10 }
    LogEvent('Calculating entry balance... OK');
  finally
    Tr.Free;
    q.Free;
    q2.Free;
    q3.Free;
    q4.Free;
    q5.Free;
    UsrFieldsList.Free;
  end;
end;


procedure TgsDBSqueeze.DeleteDocuments;                                         {TODO: неточный алгоритм DoCascade - переделать}

  procedure DoCascade(const ATableName: String; ATr: TIBTransaction);
  var
    q, q2, q3: TIBSQL;
    Count: Integer; ///test
    Tr2: TIBTransaction;
  begin
    q := TIBSQL.Create(nil);
    q2 := TIBSQL.Create(nil);
    q3 := TIBSQL.Create(nil);
    Tr2 := TIBTransaction.Create(nil);
    try
      Tr2.DefaultDatabase := FIBDatabase;
      Tr2.StartTransaction;
      q3.Transaction := Tr2;

      q2.Transaction := ATr;
      q.Transaction := ATr;

      LogEvent('DoCascade...   --test');

      q.SQL.Text :=
        'SELECT ' +
        '  fc.relation_name, ' +
        '  fc.list_fields, ' +
        '  pc.list_fields AS pk_fields ' +
        'FROM dbs_fk_constraints fc ' +
        '  JOIN dbs_pk_unique_constraints pc ' +
        '    ON pc.relation_name = fc.relation_name ' +
        '  AND pc.constraint_type = ''PRIMARY KEY'' ' +
        'WHERE fc.update_rule = ''CASCADE'' ' +
        '  AND UPPER(fc.ref_relation_name) = :rln ';
      q.ParamByName('rln').AsString := UpperCase(ATableName);
      q.ExecQuery;

      while not q.EOF do
      begin
        q2.SQL.Text :=
          'SELECT COUNT(fc.RELATION_NAME) as Kolvo ' +
          'FROM DBS_FK_CONSTRAINTS fc ' +
          'WHERE UPPER(fc.ref_relation_name) = :rln ' +
          '  AND fc.update_rule IN (''RESTRICT'', ''NO ACTION'') ';
        q2.ParamByName('rln').AsString := UpperCase(q.FieldByName('relation_name').AsString);
        q2.ExecQuery;

        if q2.FieldByName('Kolvo').AsInteger = 0 then
        begin
          q2.Close;

          if Pos(',', q.FieldByName('pk_fields').AsString) = 0 then
          begin
            q2.SQL.Text :=
              'SELECT ' +                                                       //проверка типа поля РК
              '  CASE F.RDB$FIELD_TYPE ' +
              '    WHEN 8 THEN ''INTEGER'' ' +
              '    ELSE ''NOT INTEGER'' ' +
              '  END FIELD_TYPE ' +
              'FROM RDB$RELATION_FIELDS RF ' +
              'JOIN RDB$FIELDS F ON (F.RDB$FIELD_NAME = RF.RDB$FIELD_SOURCE) ' +
              'WHERE (RF.RDB$RELATION_NAME = :RELAT_NAME) AND (RF.RDB$FIELD_NAME = :FIELD) ';
            q2.ParamByName('RELAT_NAME').AsString := q.FieldByName('relation_name').AsString;
            q2.ParamByName('FIELD').AsString := q.FieldByName('pk_fields').AsString;
            q2.ExecQuery;

            if q2.FieldByName('FIELD_TYPE').AsString = 'INTEGER' then
            begin
              q2.Close;
              q2.SQL.Text :=
              'SELECT ' +                                                       //проверка типа поля
              '  CASE F.RDB$FIELD_TYPE ' +
              '    WHEN 8 THEN ' +
              '      CASE F.RDB$FIELD_SUB_TYPE ' +
              '        WHEN 0 THEN ''INTEGER'' ' +
              '        ELSE ''NOT INTEGER'' ' +
              '    END ' +
              '    ELSE ''NOT INTEGER'' ' +
              '  END FIELD_TYPE ' +
              'FROM RDB$RELATION_FIELDS RF ' +
              '  JOIN RDB$FIELDS F ON (F.RDB$FIELD_NAME = RF.RDB$FIELD_SOURCE) ' +
              'WHERE (RF.RDB$RELATION_NAME = :RELAT_NAME) AND (RF.RDB$FIELD_NAME = :FIELD) ';
              q2.ParamByName('RELAT_NAME').AsString := q.FieldByName('relation_name').AsString;

              q2.ParamByName('FIELD').AsString := q.FieldByName('list_fields').AsString;
              q2.ExecQuery;

              if q2.FieldByName('FIELD_TYPE').AsString = 'INTEGER' then
              begin
                q2.Close;
                q3.SQL.Text :=
                  'SELECT COUNT(g_his_include(0, ' + q.FieldByName('pk_fields').AsString + ')) AS Kolvo ' +
                  'FROM ' +
                  '  ' + q.FieldByName('relation_name').AsString + ' ' +
                  'WHERE ' +
                  '  g_his_has(0, ' + q.FieldByName('list_fields').AsString + ') = 1 AND ' +
                     q.FieldByName('pk_fields').AsString + ' > 147000000 ';
                q3.ExecQuery;

                //LogEvent('test--COUNT HIS now: ' + q3.FieldByName('Kolvo').AsString);

                Count := Count + q3.FieldByName('Kolvo').AsInteger;             { TODO :  Count убрать. test }


                q3.Close;

                Tr2.Commit;                                                     { TODO: оставить ATr? }
                Tr2.DefaultDatabase := FIBDatabase;
                Tr2.StartTransaction;

                DoCascade(q.FieldByName('relation_name').AsString, ATr);
              end
              else
                q2.Close;
            end
            else
              q2.Close;
          end;
        end;
        q2.Close;
        q.Next;
      end;
      q.Close;
      LogEvent('test--COUNT in HIS: ' + IntToStr(Count));
      LogEvent('DoCascade...OK   --test');
    finally
      q2.Free;
      q3.Free;
      q.Free;
    end;
  end;

  procedure ExcludeFKs(ATr: TIBTransaction);
  var
    q: TIBSQL;
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := ATr;
      LogEvent('ExcludeFKs...   --test');

 {     ///--for test
      if RelationExist2('DBS_EXCLUDED_FIELDS', ATr) then
      begin
        q.SQL.Text := ' DELETE FROM DBS_EXCLUDED_FIELDS ';
        q.ExecQuery;
        LogEvent('Table DBS_EXCLUDED_FIELDS exists. --for test');
      end else
      begin
        q.SQL.Text :=
          'CREATE TABLE DBS_EXCLUDED_FK_FIELDS ( ' +
          '  TABLE_NAME    CHAR(31) NOT NULL, ' +
          '  FK_FIELD_NAME CHAR(31) NOT NULL, ' +
          '  PRIMARY KEY (FK_FIELD_NAME, TABLE_NAME)) ';
        q.ExecQuery;
        LogEvent('Table DBS_EXCLUDED_FIELDS has been created. --for test');
      end;
      q.Close;
      ATr.Commit;
      ATr.DefaultDatabase := FIBDatabase;
      ATr.StartTransaction;
 }

      q.SQL.Text :=
      {
        'EXECUTE BLOCK ' +
        'AS ' +
        '  DECLARE VARIABLE RN CHAR(31); ' +
        '  DECLARE VARIABLE FN CHAR(31); ' +
        '  DECLARE VARIABLE S  VARCHAR(8192); ' +
        'BEGIN ' +
        '  FOR ' +
        '    SELECT ' +
        '      DISTINCT c.relation_name ' +
        '    FROM ' +
        '      dbs_fk_constraints c ' +
        '    INTO :RN ' +
        '  DO BEGIN ' +
        '    S = ''''; ' +
        '    FOR ' +
        '      SELECT ' +
        '        c.list_fields  ' +
        '      FROM ' +
        '        dbs_fk_constraints c ' +
        '        JOIN rdb$relation_fields rf ON rf.rdb$field_name = c.list_fields ' +
        '          AND rf.rdb$relation_name = c.relation_name ' +
        '        JOIN rdb$fields f ON f.rdb$field_name = rf.rdb$field_source ' +
        '      WHERE ' +
        '        c.update_rule IN (''RESTRICT'', ''NO ACTION'') ' +
        '        AND f.rdb$field_type = 8 ' +
        '        AND c.relation_name = :RN ' +
        '      INTO :FN ' +
        '    DO BEGIN ' +
        '      S = IIF(:S = '''', :S, :S || '','') || ' +
        '        '' SUM(g_his_exclude(0, '' || :FN || ''))''; ' +
        '    END ' +
        '    EXECUTE STATEMENT ''SELECT '' || :S || '' FROM '' || :RN; ' +
        '  END ' +
        'END; ';
       }
                        ///предыдущая(моя) версия
        'EXECUTE BLOCK ' +
        'AS ' +
        'DECLARE VARIABLE NOT_EOF INTEGER; ' +                                  ///test
        'DECLARE VARIABLE iid INTEGER; ' +
        'DECLARE VARIABLE type_field VARCHAR(20); ' +
        'DECLARE VARIABLE RELAT_NAME VARCHAR(31); ' +
        'DECLARE VARIABLE FIELD VARCHAR(31); ' +
        'BEGIN ' +
        '  FOR ' +
        '    SELECT RELATION_NAME, LIST_FIELDS ' +
        '    FROM DBS_FK_CONSTRAINTS ' +
        '    WHERE update_rule IN (''RESTRICT'', ''NO ACTION'') ' +
        '    INTO :RELAT_NAME, :FIELD ' +
        '  DO BEGIN ' +
        '    SELECT ' +
        '    CASE F.RDB$FIELD_TYPE ' +
        '      WHEN 8 THEN ' +
        '        ''INTEGER'' ' +
        '      ELSE ''NOT INTEGER'' ' +
        '    END FIELD_TYPE ' +
        '    FROM RDB$RELATION_FIELDS RF ' +
        '      JOIN RDB$FIELDS F ON (F.RDB$FIELD_NAME = RF.RDB$FIELD_SOURCE) ' +
        '    WHERE (RF.RDB$RELATION_NAME = :RELAT_NAME) AND (RF.RDB$FIELD_NAME = :FIELD) ' +
        '    INTO :type_field ; ' +
        '    if (:type_field = ''INTEGER'') then ' +
        '    begin ' +
        '      FOR ' +
        '        EXECUTE STATEMENT ''SELECT '' || :FIELD || '' FROM '' || :RELAT_NAME ' +
        '      INTO :iid ' +
        '      DO BEGIN ' +
        '        if (g_his_has(0, :iid) = 1) then ' +
        '        begin ' +
      { '          SELECT COUNT(FK_FIELD_NAME) FROM DBS_EXCLUDED_FK_FIELDS ' +          ///
        '            WHERE (TABLE_NAME = :RELAT_NAME) AND (FK_FIELD_NAME = :FIELD) ' +  ///
        '          INTO :NOT_EOF; ' +                                                   ///
        '          if (:NOT_EOF = 0) then ' +                                           ///
        '          begin ' +                                                            ///
        '            INSERT INTO DBS_EXCLUDED_FK_FIELDS (TABLE_NAME, FK_FIELD_NAME) ' + ///test
        '              VALUES (:RELAT_NAME, :FIELD); ' +                                ///
        '          end ' +   }
        '          g_his_exclude(0, :iid); ' +
        '        end ' +
        '      END ' +
        '    end ' +
        '  END ' +
        'END ';
      q.ExecQuery;
      ATr.Commit;
      ATr.DefaultDatabase := FIBDatabase;
      ATr.StartTransaction;

      LogEvent('ExcludeFKs... OK  --test');
    finally
      q.Free;
    end;
  end;

  procedure test;                                                               /// test
  var
    Tr: TIBTransaction;
    q: TIBSQL;
    q2: TIBSQL;
    Count: Integer;
  begin
    Tr := TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);
    q2 := TIBSQL.Create(nil);
    try
      Tr.DefaultDatabase := FIBDatabase;
      Tr.StartTransaction;
      q.Transaction := Tr;
      q2.Transaction := Tr;

      q.SQL.Text :=
        'SELECT COUNT (id) as Kolvo FROM gd_document WHERE documentdate < :Date';
      q.ParamByName('Date').AsString := FDocumentdateWhereClause;
      q.ExecQuery;
      LogEvent('[test] COUNT doc records for delete: ' + q.FieldByName('Kolvo').AsString);
      q.Close;

      q.SQL.Text :=
        'SELECT relation_name as RN, list_fields as LF ' +
        'FROM dbs_pk_unique_constraints ' +
        'WHERE constraint_type = ''PRIMARY KEY'' ' ;
      q.ExecQuery;

      while not q.EOF do
      begin
        q2.SQL.Text :=
          'SELECT count( ' + q.FieldByName('LF').AsString + ' ) as Kolvo ' +
          'FROM ' + q.FieldByName('RN').AsString + ' ' +
          'WHERE g_his_has(0, ' + q.FieldByName('LF').AsString + ') = 1';
          q2.ExecQuery;
          Count := Count + q2.FieldByName('Kolvo').AsInteger;
          q2.Close;
      end;
      LogEvent('[test] COUNT AFTER: ' + IntToStr(Count));
      q.Close;
    finally
      q2.Free;
      q.Free;
      Tr.Free;
    end;
  end;

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

    q.SQL.Text :=
      'EXECUTE BLOCK AS BEGIN g_his_create(0, 0); END';
    q.ExecQuery;

    q.SQL.Text :=
      'SELECT COUNT(g_his_include(0, id)) as Kolvo FROM gd_document WHERE documentdate < :Date';
    q.ParamByName('Date').AsString := FDocumentdateWhereClause;
    q.ExecQuery;

    LogEvent('[test] COUNT doc records for delete: ' + q.FieldByName('Kolvo').AsString);
    q.Close;

    Tr.Commit;
    Tr.StartTransaction;

    DoCascade('gd_document', Tr);   ///without FKs22
    //ExcludeFKs(Tr);

    test;                                                                       /// test

    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE RN CHAR(31); ' +
      '  DECLARE VARIABLE FN CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT relation_name, list_fields ' +
      '    FROM dbs_pk_unique_constraints ' +
      '    WHERE constraint_type = ''PRIMARY KEY'' ' +
      '    INTO :RN, :FN ' +
      '  DO BEGIN ' +
      '    EXECUTE STATEMENT ''DELETE FROM '' || :RN || '' WHERE ' +
      '      g_his_has(0, '' || :FN || '') = 1 AND '' || :FN || '' > 147000000''; ' +
      '  END ' +
      'END';
    q.ExecQuery;

    Tr.Commit;
    test;                                                                       /// test

    q.SQL.Text :=
      'EXECUTE BLOCK AS BEGIN g_his_destroy(0); END';
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
      'INSERT INTO DBS_INACTIVE_TRIGGERS (TRIGGER_NAME) ' +
      'SELECT RDB$TRIGGER_NAME ' +
      'FROM RDB$TRIGGERS ' +
      'WHERE RDB$TRIGGER_INACTIVE = 1 ' +
      '  AND RDB$SYSTEM_FLAG = 0';
    q.ExecQuery;

    //Tr.Commit;
    //Tr.StartTransaction;

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
      '      AND RDB$TRIGGER_NAME NOT IN (SELECT RDB$TRIGGER_NAME FROM RDB$CHECK_CONSTRAINTS) ' +
      '    INTO :TN ' +
      '  DO ' +
      '    EXECUTE STATEMENT ''ALTER TRIGGER '' || :TN || '' INACTIVE ''; ' +
      'END';
    q.ExecQuery;
    LogEvent('Triggers deactivated.');
  end;

  procedure PrepareIndices;
  begin
    q.SQL.Text :=
      'INSERT INTO DBS_INACTIVE_INDICES (INDEX_NAME) ' +
      'SELECT RDB$INDEX_NAME ' +
      'FROM RDB$INDICES ' +
      'WHERE RDB$INDEX_INACTIVE = 1 ' +
      '  AND RDB$SYSTEM_FLAG = 0';
    q.ExecQuery;

    //Tr.Commit;
    //Tr.StartTransaction;

    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE N CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT rdb$index_name ' +
      '    FROM rdb$indices ' +
      '    WHERE rdb$index_inactive = 0 ' +
     // '      AND RDB$SYSTEM_FLAG = 0 ' +                                           //
      '      AND (NOT rdb$index_name LIKE ''RDB$%'') ' +
      '      AND (NOT rdb$index_name LIKE ''INTEG_$%'') ' +
      '    INTO :N ' +
      '  DO ' +
      '    EXECUTE STATEMENT ''ALTER INDEX '' || :N || '' INACTIVE ''; ' +
      'END';
    q.ExecQuery;
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
      '    list(inx.RDB$FIELD_NAME) as List_Fields ' +
      '    FROM RDB$INDEX_SEGMENTS inx ' +
      '    GROUP BY inx.RDB$INDEX_NAME ' +
      '  ) i ON c.RDB$INDEX_NAME = i.RDB$INDEX_NAME ' +
      'WHERE ' +
      '  (c.rdb$constraint_type = ''PRIMARY KEY'' OR c.rdb$constraint_type = ''UNIQUE'') ' +
      '   AND (NOT c.rdb$constraint_name LIKE ''RDB$%'') ' +
      '   AND (NOT c.rdb$constraint_name LIKE ''INTEG_%'') '; // NOT c.RDB$INDEX_NAME
    q.ExecQuery;
    //Tr.Commit;
    //Tr.StartTransaction;
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
      '  (c.rdb$constraint_type = ''FOREIGN KEY'')  ' +                         {TODO: added test}
      '  AND (NOT c.rdb$constraint_name LIKE ''RDB$%'') ' +
      '    AND (NOT c.rdb$constraint_name LIKE ''INTEG_%'') '  + // c.rdb$index_name LIKE ''INTEG_%'' '
      'GROUP BY ' +
      '  1, 2, 3, 4, 5';
    q.ExecQuery;                                                                

    //Tr.Commit;
    //Tr.StartTransaction;

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
    LogEvent('FKs dropped.');
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

    PrepareFKConstraints;
    PreparePkUniqueConstraints;
    PrepareTriggers;
    PrepareIndices;
    
    Tr.Commit;
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

    LogEvent('Indices reactivated.');
  end;


  procedure RestorePkUniqueConstraints;
  begin
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

    LogEvent('PKs&UNIQs restored.');
  end;

  procedure RestoreFKConstraints;                                               {TODO: ошибка! AC_ENTRY  FK}
  begin
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
    Tr.StartTransaction;

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
    ///RestoreFKConstraints;                                                    { TODO:  13.05.2013 12:04:51 }

    Tr.Commit;
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
  Tr: TIBTransaction;

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

  procedure CreateDBSFKConstraints;                                             {TODO: протестить}
  begin
    {if RelationExist2('DBS_FK_CONSTRAINTS', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM DBS_FK_CONSTRAINTS';
      q.ExecQuery;
      LogEvent('Table DBS_FK_CONSTRAINTS exists.');
    end else
    begin }
      q.SQL.Text :=
        'CREATE TABLE DBS_FK_CONSTRAINTS ( ' +
        '  CONSTRAINT_NAME   CHAR(31), ' +
        '  RELATION_NAME     CHAR(31), ' +
        '  LIST_FIELDS       VARCHAR(8192), ' +
        '  REF_RELATION_NAME CHAR(31), ' +
        '  LIST_REF_FIELDS   VARCHAR(8192), ' +
        '  UPDATE_RULE       CHAR(11), ' +
        '  DELETE_RULE       CHAR(11), ' +
        '  PRIMARY KEY (CONSTRAINT_NAME)) ';
      q.ExecQuery;
      LogEvent('Table DBS_FK_CONSTRAINTS has been created.');
    //end;
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
  end;

begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    CreateDBSInactiveTriggers;
    CreateDBSInactiveIndices;
    CreateDBSPkUniqueConstraints;
    CreateDBSFKConstraints;
    CreateUDFs;

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;

end.
