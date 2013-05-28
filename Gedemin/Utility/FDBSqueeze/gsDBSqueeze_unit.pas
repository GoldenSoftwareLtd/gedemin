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

    FAllContactsSaldo: Boolean;
    FOnlyOurCompaniesSaldo: Boolean;
    FOnlyCompanySaldo: Boolean;

    FCurDate, FCurUserContactKey: String;

    procedure LogEvent(const AMsg: String);

    function GetNewID: String;
    function GetConnected: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    // подсчет и формирование бухгалтерского сальдо
    procedure CalculateAcSaldo;
    // подсчет и формирование складских остатков
    procedure CalculateInvSaldo;
    procedure DeleteDocuments;
    procedure PrepareDB;
    procedure RestoreDB;
    procedure SetItemsCbbEvent;
    procedure TestAndCreateMetadata;


    property AllContactsSaldo: Boolean read FAllContactsSaldo write FAllContactsSaldo;
    property OnlyOurCompaniesSaldo: Boolean read FOnlyOurCompaniesSaldo write FOnlyOurCompaniesSaldo;
    property OnlyCompanySaldo: Boolean read FOnlyCompanySaldo write FOnlyCompanySaldo;

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
  SysUtils, mdf_MetaData_unit, gdcInvDocument_unit;

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
    'lc_ctype=win1251';
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
      '  current_date  AS CurDate, ' +
      '  gu.contactkey AS CurUserContactKey ' +
      'FROM ' +
      '  GD_USER gu ' +
      'WHERE ' +
      '  gu.ibname = CURRENT_USER ';
    q.ExecQuery;

    FCurDate := q.FieldByName('CurDate').AsString;
    FCurUserContactKey := q.FieldByName('CurUserContactKey').AsString;
    q.Close;
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

function TgsDBSqueeze.GetNewID: String;
var
  q: TIBSQL;
  Tr: TIBTransaction;
  Id: String;
begin
  Assert(Connected);
  
  Id := '';
   
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
   Id := Trim(q.FieldByName('NEW_ID').AsString);
  finally
    Result := Id;
    q.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.CalculateAcSaldo;  // подсчет бухгалтерского сальдо        { TODO: String -> исходный тип }
var
  q, q2, q3: TIBSQL;
  Tr: TIBTransaction;
  AccDocTypeKey, ProizvolnyeTransactionKey, ProizvolnyeTrRecordKey, OstatkiAccountKey: String;
  CompanyKey: String;
  UsrFieldsList: TStringList;  // cписок активных аналитик для счета
  NewMasterDocKey, NewDetailDocKey: String;
  NewRecordKey: String;

  procedure DeleteOldAcEntry; // удаление старых бухгалтерских проводок
  var
    q: TIBSQL;
  begin
    LogEvent('Deleting old entries...');
    q := TIBSQL.Create(nil);
    try
      q.Transaction := Tr;

      {q.SQL.Text :=
        'DELETE FROM AC_RECORD r ' +
        'WHERE r.id IN (' +
        '  SELECT DISTINCT recordkey ' +
        '  FROM AC_ENTRY ' +
        '  WHERE companykey = ' +  ' ''' + CompanyKey + ''' ' +
        '    AND entrydate < ' + ' ''' + FDocumentdateWhereClause +  ''' ' +
        ') ';
      q.ExecQuery;}                                                               /// долго

      q.SQL.Text :=
        'DELETE FROM AC_RECORD ' +
        'WHERE companykey = ' +  ' ''' + CompanyKey + ''' ' +
        '  AND recorddate < ' + ' ''' + FDocumentdateWhereClause +  ''' ';
      q.ExecQuery;

      {q.SQL.Text :=
        'DELETE FROM ac_autoentry ' +
        'WHERE NOT EXISTS (SELECT id FROM ac_entry) ';
      q.ExecQuery;}

      Tr.Commit;
      LogEvent('Deleting old entries... OK');
    finally
      q.Free;
    end;
  end;

  procedure CreateHeaderAcDoc;  // создание шапки документа для бух проводок
  var
    q: TIBSQL;
  begin
    q := TIBSQL.Create(nil);
    try
      NewMasterDocKey := GetNewID;
      q.Transaction := Tr;
      q.SQL.Text :=
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
        'VALUES (' + ' ''' +
           NewMasterDocKey + ''' ' + ', ' + ' ''' +
           AccDocTypeKey + ''' ' + ', ' +
           '1' + ', ' +  ' ''' +
           FCurDate + ''' '  + ', ' +  ' ''' +
           CompanyKey + ''' ' +  ', ' +
           '-1' + ', ' +
           '-1' + ', ' +
           '-1' + ', ' + ' ''' +
           FCurUserContactKey + ''' ' + ', ' + ' ''' +
           FCurUserContactKey +  ''' ' +
        ') ';
      q.ExecQuery;

      Tr.Commit;
      Tr.StartTransaction;
      LogEvent('Master document has been created.');
    finally
      q.Free;
    end;
  end;

  procedure CreatePositionAcDoc;  // создание документа с позициями для бух проводок
  var
    q: TIBSQL;
  begin
    q := TIBSQL.Create(nil);
    try
      NewDetailDocKey := GetNewID;

      q.Transaction := Tr;
      q.SQL.Text :=
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
        'VALUES (' + ' ''' +
           NewDetailDocKey + ''' ' +  ', ' +  ' ''' +
           NewMasterDocKey  + ''' ' +  ', ' +  ' ''' +
           AccDocTypeKey + ''' ' +  ', ' +
           '1' + ', ' +  ' ''' +
           FCurDate + ''' ' +  ', ' +  ' ''' +
           CompanyKey + ''' ' +  ', ' +
           '-1' + ', ' +
           '-1' + ', ' +
           '-1' + ', ' + ' ''' +
           FCurUserContactKey + ''' ' +  ', ' +  ' ''' +
           FCurUserContactKey + ''' ' +
        ' ) ';
      q.ExecQuery;

      Tr.Commit;
      Tr.StartTransaction;
      LogEvent('Detail document has been created. ');
    finally
      q.Free;
    end;
  end;

  procedure CalculateAcSaldo_CreateAcEntries;  // вычисление бух сальдо и создание проводок с остатками
  var
    I: Integer;
    AllUsrFieldsNames: String;     // список всех аналитик (в разных БД отличаются)

    procedure InsertAcEntry(const AAccountKey: String; AIBSQLInsert, AIBSQLSaldo: TIBSQL);
    var
      J: Integer;
    begin
      AIBSQLInsert.SQL.Text :=
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
        '  ACCOUNTPART ';
      if (AIBSQLSaldo.FieldByName('SALDO_NCU').AsCurrency < 0.0000)
        or (AIBSQLSaldo.FieldByName('SALDO_CURR').AsCurrency < 0.0000)
        or (AIBSQLSaldo.FieldByName('SALDO_EQ').AsCurrency < 0.0000) then
          AIBSQLInsert.SQL.Add(', CREDITNCU, ' + ' CREDITCURR, ' + ' CREDITEQ ')
      else
        AIBSQLInsert.SQL.Add(', DEBITNCU, ' + '  DEBITCURR, ' + ' DEBITEQ ');

      for J := 0 to UsrFieldsList.Count - 1 do
      begin
        if AIBSQLSaldo.FieldByName(UsrFieldsList[J]).AsString <> '' then
          AIBSQLInsert.SQL.Add(', ' + UsrFieldsList[J]);
      end;

      AIBSQLInsert.SQL.Add(') ' +
        'VALUES ( ' +
           GetNewID + ', ' + ' ''' +
           FCurDate + ''' ' + ', ' + ' ''' +
           NewRecordKey + ''' ' + ', ' + ' ''' +
           ProizvolnyeTransactionKey + ''' ' + ', ' + ' ''' +
           NewDetailDocKey + ''' ' + ', ' + ' ''' +
           NewMasterDocKey + ''' ' +', ' + ' ''' +
           CompanyKey + ''' ' + ', ' +  ' ''' +
           AAccountKey + ''' ' + ', ' + ' ''' +
           AIBSQLSaldo.FieldByName('currkey').AsString + ''' ');

      if (AIBSQLSaldo.FieldByName('SALDO_NCU').AsCurrency < 0.0000)
        or (AIBSQLSaldo.FieldByName('SALDO_CURR').AsCurrency < 0.0000)
        or (AIBSQLSaldo.FieldByName('SALDO_EQ').AsCurrency < 0.0000) then
          AIBSQLInsert.SQL.Add(
            ', ''C''' +
            ', ''' + CurrToStr(Abs(AIBSQLSaldo.FieldByName('SALDO_NCU').AsCurrency)) + ''' ' +
            ', ''' + CurrToStr(Abs(AIBSQLSaldo.FieldByName('SALDO_CURR').AsCurrency)) + ''' ' +
            ', ''' + CurrToStr(Abs(AIBSQLSaldo.FieldByName('SALDO_EQ').AsCurrency)) + ''' ')
      else
        AIBSQLInsert.SQL.Add(
          ', ''D''' +
          ', ''' + AIBSQLSaldo.FieldByName('SALDO_NCU').AsString + ''' ' +
          ', ''' + AIBSQLSaldo.FieldByName('SALDO_CURR').AsString + ''' ' +
          ', ''' + AIBSQLSaldo.FieldByName('SALDO_EQ').AsString + ''' ');

      for J := 0 to UsrFieldsList.Count - 1 do
      begin
        if AIBSQLSaldo.FieldByName(UsrFieldsList[J]).AsString <> '' then
          AIBSQLInsert.SQL.Add(', ''' + AIBSQLSaldo.FieldByName(UsrFieldsList[J]).AsString + ''' ');
      end;
      AIBSQLInsert.SQL.Add(')');
      AIBSQLInsert.ExecQuery;
    end;

  begin
    LogEvent('[test] CalculateAcSaldo_CreateAcEntries...');

    q.SQL.Text :=
      'SELECT LIST(rf.rdb$field_name) as UsrFieldsList ' +
      'FROM RDB$RELATION_FIELDS rf ' +
      'WHERE rf.rdb$relation_name = ''AC_ACCOUNT'' ' +
      '  AND rf.rdb$field_name LIKE ''USR$%'' ';
    q.ExecQuery;

    AllUsrFieldsNames := q.FieldByName('UsrFieldsList').AsString;
    q.Close;

    //-------------------------------------------- вычисление сальдо для счета

    q.SQL.Text :=
      'SELECT ' +
      '  ac.id, ' +
         StringReplace(AllUsrFieldsNames, 'USR$', 'ac.USR$', [rfReplaceAll, rfIgnoreCase]) + ' ' +
      'FROM ' +
      '  AC_ACCOUNT ac ' +
      'WHERE ' +
      '  ac.id IN ( ' +
      '    SELECT DISTINCT accountkey ' +
      '    FROM AC_ENTRY ' +
      '    WHERE companykey = :COMPANY_KEY ' +
      '      AND entrydate < :ENTRY_DATE ' +
      '  ) ';
    q.ParamByName('COMPANY_KEY').AsString := CompanyKey;
    q.ParamByName('ENTRY_DATE').AsString := FDocumentdateWhereClause;
    q.ExecQuery;

    while (not q.EOF) do // считаем сальдо для каждого счета
    begin
      UsrFieldsList.Text := StringReplace(AllUsrFieldsNames, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
      // получаем cписок аналитик, по которым ведется учет для счета
      I := 0;
      while I < UsrFieldsList.Count - 1 do
      begin
        if q.FieldByName(Trim(UsrFieldsList[I])).AsInteger <> 1 then
        begin
          UsrFieldsList.Delete(I);
        end
        else
          Inc(I);
      end;

      // подсчет сальдо в разрезе компании, счета, валюты, аналитик
      q2.SQL.Text :=
        'SELECT currkey, ' +
        '  SUM(debitncu)  - SUM(creditncu)  AS SALDO_NCU, '  +
        '  SUM(debitcurr) - SUM(creditcurr) AS SALDO_CURR, ' +
        '  SUM(debiteq)   - SUM(crediteq)   AS SALDO_EQ';
      for I := 0 to UsrFieldsList.Count - 1 do
          q2.SQL.Add(', ' + UsrFieldsList[I]);
      q2.SQL.Add( ' ' +
        'FROM AC_ENTRY ' +
        'WHERE companykey = :COMPANY_KEY ' +
        '  AND accountkey = :ACCOUNT_KEY ' +
        '  AND entrydate < :ENTRY_DATE ' +
        'GROUP BY currkey');
      for I := 0 to UsrFieldsList.Count - 1 do
          q2.SQL.Add(', ' + UsrFieldsList[I]);

      q2.ParamByName('COMPANY_KEY').AsString := CompanyKey;
      q2.ParamByName('ACCOUNT_KEY').AsString := q.FieldByName('id').AsString ;
      q2.ParamByName('ENTRY_DATE').AsString := FDocumentdateWhereClause;
      q2.ExecQuery;

    //-------------------------------------------- вставка записей для проводок

      while not q2.EOF do
      begin
        NewRecordKey := GetNewID;

        q3.SQL.Text :=
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
          'VALUES ( ' + ' ''' +
             NewRecordKey + ''' ' + ', ' + ' ''' +
             FCurDate + ''' ' + ', ' + ' ''' +
             ProizvolnyeTrRecordKey + ''' ' + ', ' + ' ''' +
             ProizvolnyeTransactionKey + ''' ' + ', ' + ' ''' +
             NewDetailDocKey + ''' ' + ', ' + ' ''' +
             NewMasterDocKey + ''' ' + ', ' +
             '-1' + ', ' +
             '-1' + ', ' +
             '-1' + ', ' + ' ''' +
             CompanyKey + ''' ' +
          ') ';
        q3.ExecQuery;

        DecimalSeparator := '.';   // тип Currency в SQL имееет DecimalSeparator = ','

        // проводка по текущему счету
        InsertAcEntry(q.FieldByName('id').AsString, q3, q2);
        // проводка по счету '00 Остатки'
        InsertAcEntry(OstatkiAccountKey, q3, q2);

        q2.Next;
      end;
      UsrFieldsList.Clear;
      q2.Close;

      q.Next;
    end;
    q.Close;
    Tr.Commit;
    Tr.StartTransaction;
    LogEvent('[test] CalculateAcSaldo_CreateAcEntries... OK');
  end;

begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  q3 := TIBSQL.Create(nil);
  UsrFieldsList := TStringList.Create;
  try
    LogEvent('Calculating entry balance...');
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q2.Transaction := Tr;
    q3.Transaction := Tr;

    q.SQL.Text :=
      'SELECT ' +
      '  gd.id         AS AccDocTypeKey, ' +
      '  atr.id        AS ProizvolnyeTransactionKey, ' +    // 807001
      '  atrr.id       AS ProizvolnyeTrRecordKey, ' +       // 807100
      '  aac.id        AS OstatkiAccountKey ' +
      'FROM ' +
      '  GD_DOCUMENTTYPE gd, GD_USER gu, AC_TRANSACTION atr, AC_ACCOUNT aac, GD_DOCUMENTTYPE gd_inv ' +
      '  JOIN AC_TRRECORD atrr ON atr.id = atrr.transactionkey ' +
      'WHERE ' +
      '  gd.name = ''Хозяйственная операция'' ' +                                { TODO: 'Хозяйственная операция'? }
      '  AND atr.name = ''Произвольные проводки'' ' +                            { TODO: 'Произвольные проводки'? }
      '  AND aac.fullname = ''00 Остатки'' ';
    q.ExecQuery;

    AccDocTypeKey := Trim(q.FieldByName('AccDocTypeKey').AsString);
    ProizvolnyeTransactionKey := Trim(q.FieldByName('ProizvolnyeTransactionKey').AsString);
    ProizvolnyeTrRecordKey := Trim(q.FieldByName('ProizvolnyeTrRecordKey').AsString);
    OstatkiAccountKey := Trim(q.FieldByName('OstatkiAccountKey').AsString);
    q.Close;

    q.SQL.Text :=
      'SELECT gc.contactkey as CompKey ' +
      'FROM GD_COMPANY gc ' +
      'WHERE gc.fullname = :compName ';
    q.ParamByName('compName').AsString := FCompanyName;
    q.ExecQuery;

    CompanyKey := q.FieldByName('CompKey').AsString;
    q.Close;

    CreateHeaderAcDoc;
    CreatePositionAcDoc;
    CalculateAcSaldo_CreateAcEntries;
    DeleteOldAcEntry;

    LogEvent('Calculating entry balance... OK');
  finally
    Tr.Free;
    q.Free;
    q2.Free;
    q3.Free;
    UsrFieldsList.Free;
  end;
end;

procedure TgsDBSqueeze.CalculateInvSaldo;                                       { String -> integer ID }
var
  q, q2: TIBSQL;
  Tr: TIBTransaction;
  InvDocTypeKey: String;
  PseudoClientKey: String;
  UsrFieldsNames: String;
  UsrFieldsList: TStringList;

  LineCount: Integer;
  DocumentParentKey: String;
  CompanyKey: String;

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
      '  LEFT JOIN gd_contact gc ON gc.id = im.contactkey ');
    q.SQL.Add(
      'WHERE ' +
      '  ic.companykey = ' + CompanyKey +
      '  AND im.disabled = 0 ' +
      '  AND im.movementdate < :RemainsDate ' +
      'GROUP BY ' +
      '  im.contactkey, ' +
      '  gc.name, ' +
      '  ic.goodkey, ' +
      '  ic.companykey ');                                                      { TODO: для всех компаний->для выбранной?}
    if (UsrFieldsNames <> '') then
      q.SQL.Add(', ' +
        StringReplace(UsrFieldsNames, 'USR$', 'ic.USR$', [rfReplaceAll, rfIgnoreCase]));

    q.ParamByName('RemainsDate').AsString := FDocumentdateWhereClause;
    q.ExecQuery;
  end;

  function CreateHeaderInvDoc(
    const AFromContact, AToContact, ACompanyKey: String;
    const AInvDocType, ACurUserContactKey: String
  ): String;
  var
    NewDocumentKey: String;
    q: TIBSQL;
    Tr2: TIBTransaction;
  begin
    Assert(Connected);

    //LogEvent('[test] CreateHeaderInvDoc');

    Tr2:= TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);
    try
      Tr2.DefaultDatabase := FIBDatabase;
      Tr2.StartTransaction;
      q.Transaction := Tr2;


        NewDocumentKey := GetNewID;
        q.Close;
        q.SQL.Text :=
          'INSERT INTO gd_document ' +
          '  (id, parent, documenttypekey, number, documentdate, companykey, afull, achag, aview, ' +
            'creatorkey, editorkey) ' +
          'VALUES ' +
          '  (:id, :parent, :documenttypekey, ''1'', :documentdate, :companykey, -1, -1, -1, ' +
            ':creatorkey, :editorkey) ';

        q.ParamByName('ID').AsString := NewDocumentKey;
        q.ParamByName('DOCUMENTTYPEKEY').AsString := AInvDocType;                        ///вынести
        q.ParamByName('PARENT').Clear;
        q.ParamByName('COMPANYKEY').AsString := ACompanyKey;
        q.ParamByName('DOCUMENTDATE').AsString := FDocumentdateWhereClause;//FCurDate;
        q.ParamByName('CREATORKEY').AsString := ACurUserContactKey;
        q.ParamByName('EDITORKEY').AsString := ACurUserContactKey;
        q.ExecQuery;

        Result := NewDocumentKey;

      Tr2.Commit;
    finally
      q.Free;
      Tr2.Free;
    end;
  end;

  function CreatePositionInvDoc(
    const ADocumentParentKey, AFromContact, AToContact, ACompanyKey, ACardGoodKey: String;
    const AGoodQuantity: Currency;
    const AInvDocType, ACurUserContactKey: String;
    AUsrFieldsDataset: TIBSQL = nil
  ): String;
  var
    NewDocumentKey, NewMovementKey, NewCardKey: String;
    I: Integer;
    q: TIBSQL;
    Tr2: TIBTransaction;
  begin
    Assert(Connected);

    //LogEvent('[test] CreatePositionInvDoc');

    Tr2 := TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);
    try

      Tr2.DefaultDatabase := FIBDatabase;
      Tr2.StartTransaction;
      q.Transaction := Tr2;

      NewDocumentKey := GetNewID;

      q.SQL.Text :=
        'INSERT INTO gd_document ' +
        '  (id, parent, documenttypekey, number, documentdate, companykey, afull, achag, aview, ' +
          'creatorkey, editorkey) ' +
        'VALUES ' +
        '  (:id, :parent, :documenttypekey, ''1'', :documentdate, :companykey, -1, -1, -1, ' +
          ':userkey, :userkey) ';

      q.ParamByName('ID').AsString := NewDocumentKey;
      q.ParamByName('DOCUMENTTYPEKEY').AsString := AInvDocType;
      q.ParamByName('PARENT').AsString := ADocumentParentKey;
      q.ParamByName('COMPANYKEY').AsString := ACompanyKey;
      q.ParamByName('DOCUMENTDATE').AsString := FDocumentdateWhereClause; //FCurDate;
      q.ParamByName('USERKEY').AsString := ACurUserContactKey;
      q.ExecQuery;

      Tr2.Commit;
      Tr2.StartTransaction;

      NewCardKey := GetNewID;

      // Создадим новую складскую карточку
      q.SQL.Text :=
        'INSERT INTO inv_card ' +
        '  (id, goodkey, documentkey, firstdocumentkey, firstdate, companykey';
      // Поля-признаки
      q.SQL.Add(', ' +
            UsrFieldsNames);
      q.SQL.Add(
        ') VALUES ' +
        '  (:id, :goodkey, :documentkey, :documentkey, :firstdate, :companykey');
      // Поля-признаки
      q.SQL.Add(', ' +
        StringReplace(UsrFieldsNames, 'USR$', ':USR$', [rfReplaceAll, rfIgnoreCase]));
      q.SQL.Add(
        ')');

      q.ParamByName('FIRSTDATE').AsString := FDocumentdateWhereClause; //FCurDate;
      q.ParamByName('ID').AsString := NewCardKey;
      q.ParamByName('GOODKEY').AsString := ACardGoodKey;
      q.ParamByName('DOCUMENTKEY').AsString := NewDocumentKey;
      q.ParamByName('COMPANYKEY').AsString := ACompanyKey;

      for I := 0 to UsrFieldsList.Count - 1 do
      begin
        if Trim(UsrFieldsList[I]) <> 'USR$INV_ADDLINEKEY' then                    
        begin
          if Assigned(AUsrFieldsDataset) then
            q.ParamByName(Trim(UsrFieldsList[I])).AsVariant :=
              AUsrFieldsDataset.FieldByName(Trim(UsrFieldsList[I])).AsVariant
          else
            q.ParamByName(Trim(UsrFieldsList[I])).Clear;

        end
        else // Заполним поле USR$INV_ADDLINEKEY карточки нового остатка ссылкой на позицию
          q.ParamByName('USR$INV_ADDLINEKEY').AsString := NewDocumentKey;        { TODO:  избавиться USR$INV_ADDLINEKEY? }
      end;

      q.ExecQuery;

      Tr2.Commit;                                                                
      Tr2.StartTransaction;

      NewMovementKey := GetNewID;

      // Создадим дебетовую часть складского движения
      q.SQL.Text :=
        'INSERT INTO inv_movement ' +
        '  (movementkey, movementdate, documentkey, contactkey, cardkey, debit, credit) ' +
        'VALUES ' +
        '  (:movementkey, :movementdate, :documentkey, :contactkey, :cardkey, :debit, :credit) ';
      q.ParamByName('MOVEMENTDATE').AsString := FDocumentdateWhereClause; //FCurDate;

      q.ParamByName('MOVEMENTKEY').AsString := NewMovementKey;
      q.ParamByName('DOCUMENTKEY').AsString := NewDocumentKey;
      q.ParamByName('CONTACTKEY').AsString := AToContact;
      q.ParamByName('CARDKEY').AsString := NewCardKey;
      q.ParamByName('DEBIT').AsCurrency := AGoodQuantity;
      q.ParamByName('CREDIT').AsCurrency := 0;
      q.ExecQuery;

      Tr2.Commit;
      Tr2.StartTransaction;

      // Создадим кредитовую часть складского движения
      q.SQL.Text :=
        'INSERT INTO inv_movement ' +
        '  (movementkey, movementdate, documentkey, contactkey, cardkey, debit, credit) ' +
        'VALUES ' +
        '  (:movementkey, :movementdate, :documentkey, :contactkey, :cardkey, :debit, :credit) ';
      q.ParamByName('MOVEMENTDATE').AsString := FDocumentdateWhereClause; //FCurDate;

      q.ParamByName('MOVEMENTKEY').AsString := NewMovementKey;
      q.ParamByName('DOCUMENTKEY').AsString := NewDocumentKey;
      q.ParamByName('CONTACTKEY').AsString := AFromContact;
      q.ParamByName('CARDKEY').AsString := NewCardKey;
      q.ParamByName('DEBIT').AsCurrency := 0;
      q.ParamByName('CREDIT').AsCurrency := AGoodQuantity;
      q.ExecQuery;

      Tr2.Commit;
    finally
      Result := NewCardKey;

      q.Free;
      Tr2.Free;
    end;
  end;

  // Перепривязка складских карточек и движения
  procedure RebindInvCards;                                                     { TODO : String -> Int ID }
  const
    CardkeyFieldCount = 2;
    CardkeyFieldNames: array[0..CardkeyFieldCount - 1] of String = ('FROMCARDKEY', 'TOCARDKEY');
  var
    I: Integer;
    Tr: TIBTransaction;
    q, q2, q3: TIBSQL;
    qUpdateCard: TIBSQL;
    qUpdateFirstDocKey: TIBSQL;
    qUpdateInvMovement: TIBSQL;

    CurrentCardKey, CurrentFirstDocKey, CurrentFromContactkey, CurrentToContactkey: String;
    NewCardKey, FirstDocumentKey, FirstDate: String;
    CurrentRelationName: String;
    DocumentParentKey: String;
  begin
    LogEvent('Rebinding cards...');
    Tr := TIBTransaction.Create(nil);

    q := TIBSQL.Create(nil);
    q2 := TIBSQL.Create(nil);
    q3 := TIBSQL.Create(nil);
    qUpdateCard := TIBSQL.Create(nil);
    qUpdateFirstDocKey := TIBSQL.Create(nil);
    qUpdateInvMovement := TIBSQL.Create(nil);

    try
      Tr.DefaultDatabase := FIBDatabase;
      Tr.StartTransaction;

      q.Transaction := Tr;
      q2.Transaction := Tr;
      q3.Transaction := Tr;
      qUpdateCard.Transaction := Tr;
      qUpdateFirstDocKey.Transaction := Tr;
      qUpdateInvMovement.Transaction := Tr;

      // обновляет ссылку на родительскую карточку
      qUpdateCard.SQL.Text :=
        'UPDATE ' +
        '  inv_card c ' +
        'SET ' +
        '  c.parent = :new_parent ' +
        'WHERE ' +
        '  c.parent = :old_parent ' +
        '  AND (' +
        '    SELECT FIRST(1) m.movementdate ' +
        '    FROM inv_movement m ' +
        '    WHERE m.cardkey = c.id ' +
        '    ORDER BY m.movementdate DESC' +
        '  ) >= :closedate ';
      qUpdateCard.ParamByName('CLOSEDATE').AsString := FDocumentdateWhereClause;
      qUpdateCard.Prepare;

      // oбновляет ссылку на документ прихода и дату прихода
      qUpdateFirstDocKey.SQL.Text :=
        'UPDATE ' +
        '  inv_card c ' +
        'SET ' +
        '  c.firstdocumentkey = :newdockey, ' +
        '  c.firstdate = :newdate ' +
        'WHERE ' +
        '  c.firstdocumentkey = :olddockey ';
      qUpdateFirstDocKey.Prepare;

      // обновляет в движении ссылки на складские карточки
      qUpdateInvMovement.SQL.Text :=
        'UPDATE ' +
        '  inv_movement m ' +
        'SET ' +
        '  m.cardkey = :new_cardkey ' +
        'WHERE ' +
        '  m.cardkey = :old_cardkey ' +
        '  AND m.movementdate >= :closedate ';
      qUpdateInvMovement.ParamByName('CLOSEDATE').AsString := FDocumentdateWhereClause;
      qUpdateInvMovement.Prepare;

      // выбираем все карточки, которые находятся в движении во время закрытия
      q.SQL.Text :=
        'SELECT' +
        '  m1.contactkey AS fromcontactkey,' +
        '  m.contactkey AS tocontactkey,' +
        '  linerel.relationname,' +
        '  c.id AS cardkey_new, ' +
        '  c1.id AS cardkey_old,' +
        '  c.goodkey,' +
        '  c.companykey, ' +
        '  c.firstdocumentkey';
      if UsrFieldsNames <> '' then q.SQL.Add(', ' +
        StringReplace(UsrFieldsNames, 'USR$', 'c.USR$', [rfReplaceAll, rfIgnoreCase]) + ' ');                                                                       /// c.
      q.SQL.Add(' ' +
        'FROM gd_document d ' +
        '  JOIN gd_documenttype t ON t.id = d.documenttypekey ' +
        '  LEFT JOIN inv_movement m ON m.documentkey = d.id ' +
        '  LEFT JOIN inv_movement m1 ON m1.movementkey = m.movementkey AND m1.id <> m.id ' +
        '  LEFT JOIN inv_card c ON c.id = m.cardkey ' +
        '  LEFT JOIN inv_card c1 ON c1.id = m1.cardkey ' +
        '  LEFT JOIN gd_document d_old ON ((d_old.id = c.documentkey) or (d_old.id = c1.documentkey)) ' +
        '  LEFT JOIN at_relations linerel ON linerel.id = t.linerelkey ' +
        'WHERE ' +
        '  d.documentdate >= ''' + FDocumentdateWhereClause + ''' ' +
        '  AND t.classname = ''TgdcInvDocumentType'' ' +
        '  AND t.documenttype = ''D'' ' +
        '  AND d_old.documentdate < ''' + FDocumentdateWhereClause + ''' ');
      q.ExecQuery;

      FirstDocumentKey := '-1';
      FirstDate := FDocumentdateWhereClause;
      while not q.EOF do
      begin
        if q.FieldByName('CARDKEY_OLD').IsNull then
          CurrentCardKey := q.FieldByName('CARDKEY_NEW').AsString
        else
          CurrentCardKey := q.FieldByName('CARDKEY_OLD').AsString;
        CurrentFirstDocKey := q.FieldByName('FIRSTDOCUMENTKEY').AsString;
        CurrentFromContactkey := q.FieldByName('FROMCONTACTKEY').AsString;
        CurrentToContactkey := q.FieldByName('TOCONTACTKEY').AsString;
        CurrentRelationName := q.FieldByName('RELATIONNAME').AsString;

        if (StrToInt(CurrentFromContactkey) > 0) or (StrToInt(CurrentToContactkey) > 0) then
        begin
          // ищем подходящую карточку в документе остатков для замены удаляемой
          q2.SQL.Text :=
            'SELECT FIRST(1) ' +
            '  c.id AS cardkey, ' +
            '  c.firstdocumentkey, ' +
            '  c.firstdate ' +
            'FROM gd_document d ' +
            '  LEFT JOIN inv_movement m ON m.documentkey = d.id ' +
            '  LEFT JOIN inv_card c ON c.id = m.cardkey ' +
            'WHERE ' +
            '  d.documenttypekey = :doctypekey ' +
            '  AND d.documentdate = :closedate ' +
            '  AND c.goodkey = :goodkey ' +
            '  AND ' +
            '    ((m.contactkey = :contact1) ' +
            '    OR (m.contactkey = :contact2)) ';
          for I := 0 to UsrFieldsList.Count - 1 do
          begin
            if not q.FieldByName(Trim(UsrFieldsList[I])).IsNull then
              q2.SQL.Add(Format(
              'AND c.%0:s = :%0:s ', [Trim(UsrFieldsList[I])]) + ' ')
            else
              q2.SQL.Add(Format(
              'AND c.%0:s IS NULL ', [Trim(UsrFieldsList[I])]) + ' ');
          end;

          q2.ParamByName('DOCUMENTTYPEKEY').AsString := InvDocTypeKey;
          q2.ParamByName('CLOSEDATE').AsString := FDocumentdateWhereClause;
          q2.ParamByName('GOODKEY').AsString := q.FieldByName('GOODKEY').AsString;
          q2.ParamByName('CONTACT1').AsString := CurrentFromContactkey;
          q2.ParamByName('CONTACT2').AsString := CurrentToContactkey;
          for I := 0 to UsrFieldsList.Count - 1 do
          begin
            if not q.FieldByName(Trim(UsrFieldsList[I])).IsNull then
              q2.ParamByName(Trim(UsrFieldsList[I])).AsVariant := q.FieldByName(Trim(UsrFieldsList[I])).AsVariant;
          end;

          q2.ExecQuery;

          // если нашли подходящую карточку, созданную документом остатков
          if q2.RecordCount > 0 then
          begin
            NewCardKey := q2.FieldByName('CARDKEY').AsString;
            FirstDocumentKey := q2.FieldByName('FIRSTDOCUMENTKEY').AsString;
            FirstDate := q2.FieldByName('FIRSTDATE').AsString;
          end
          else begin
            // ищем карточку без доп. признаков
            q2.Close;
            q2.SQL.Text :=                                                         {TODO: вынести. Prepare  }
              'SELECT FIRST(1) ' +
              '  c.id AS cardkey, ' +
              '  c.firstdocumentkey, ' +
              '  c.firstdate ' +
              'FROM gd_document d ' +
              '  LEFT JOIN inv_movement m ON m.documentkey = d.id ' +
              '  LEFT JOIN inv_card c ON c.id = m.cardkey ' +
              'WHERE ' +
              '  d.documenttypekey = :doctypekey ' +
              '  AND d.documentdate = :closedate ' +
              '  AND c.goodkey = :goodkey ' +
              '  AND ' +
              '    ((m.contactkey = :contact1) ' +
              '    OR (m.contactkey = :contact2)) ';

            q2.ParamByName('CLOSEDATE').AsString := FDocumentdateWhereClause;
            q2.ParamByName('GOODKEY').AsString := q.FieldByName('GOODKEY').AsString;
            q2.ParamByName('CONTACT1').AsString := CurrentFromContactkey;
            q2.ParamByName('CONTACT2').AsString := CurrentToContactkey;
            q2.ExecQuery;

            if q2.RecordCount > 0 then
            begin
              NewCardKey := q2.FieldByName('CARDKEY').AsString;
              FirstDocumentKey := q2.FieldByName('FIRSTDOCUMENTKEY').AsString;
              FirstDate := q2.FieldByName('FIRSTDATE').AsString;
            end
            else begin // Иначе вставим документ нулевого прихода, перепривязывать будем потом на созданную им карточку

              DocumentParentKey := CreateHeaderInvDoc(
                CurrentFromContactkey,
                CurrentFromContactkey,
                q.FieldByName('COMPANYKEY').AsString,
                InvDocTypeKey,
                FCurUserContactKey);
            
              CalculateInvBalance(q3);  // По компании строим запрос на складские остатки
              NewCardKey := CreatePositionInvDoc(
                DocumentParentKey,
                CurrentFromContactkey,
                CurrentFromContactkey,
                q.FieldByName('COMPANYKEY').AsString,
                q.FieldByName('GOODKEY').AsString,
                0,
                InvDocTypeKey,
                FCurUserContactKey,
                q3);
              q3.Close;

            end;
          end;
          q2.Close;
        end
        else begin
          // ищем подходящую карточку для замены удаляемой
          q2.SQL.Text :=
            'SELECT FIRST(1) ' +
            '  c.id AS cardkey, ' +
            '  c.firstdocumentkey, ' +
            '  c.firstdate ' +
            'FROM gd_document d ' +
            '  LEFT JOIN inv_movement m ON m.documentkey = d.id ' +
            '  LEFT JOIN inv_card c ON c.id = m.cardkey ' +
            'WHERE ' +
            '  d.documenttypekey = :doctypekey ' +
            '  AND d.documentdate = :closedate ' +
            '  AND c.goodkey = :goodkey ';
          for I := 0 to UsrFieldsList.Count - 1 do
          begin
            if not q.FieldByName(Trim(UsrFieldsList[I])).IsNull then
              q2.SQL.Add(Format(
              'AND c.%0:s = :%0:s ', [Trim(UsrFieldsList[I])]))
            else
              q2.SQL.Add(Format(
              'AND c.%0:s IS NULL ', [Trim(UsrFieldsList[I])]));
          end;

          q2.ParamByName('CLOSEDATE').AsString := FDocumentdateWhereClause;
          q2.ParamByName('DOCTYPEKEY').AsString := InvDocTypeKey;
          q2.ParamByName('GOODKEY').AsString := q.FieldByName('GOODKEY').AsString;
          for I := 0 to UsrFieldsList.Count - 1 do
          begin
            if not q.FieldByName(Trim(UsrFieldsList[I])).IsNull then
              q2.ParamByName(Trim(UsrFieldsList[I])).AsVariant := q.FieldByName(Trim(UsrFieldsList[I])).AsVariant;
          end;

          q2.ExecQuery;

          if q2.RecordCount > 0 then
            NewCardKey := q2.FieldByName('CARDKEY').AsString
          else
            NewCardKey := '-1';

          q2.Close;
        end;


        if StrToInt(NewCardKey) > 0 then
        begin
          // обновление ссылок на родительскую карточку
          qUpdateCard.ParamByName('OLD_PARENT').AsString := CurrentCardKey;
          qUpdateCard.ParamByName('NEW_PARENT').AsString := NewCardKey;
          qUpdateCard.ExecQuery;
          qUpdateCard.Close;

          // обновление ссылок на документ прихода и дату прихода
          if StrToInt(FirstDocumentKey) > -1 then
          begin
            qUpdateFirstDocKey.ParamByName('OLDDOCKEY').AsString := CurrentFirstDocKey;
            qUpdateFirstDocKey.ParamByName('NEWDOCKEY').AsString := FirstDocumentKey;
            qUpdateFirstDocKey.ParamByName('NEWDATE').AsString := FirstDate;
            qUpdateFirstDocKey.ExecQuery;
            qUpdateFirstDocKey.Close;
          end;

          // обновление ссылок на карточки из движения
          qUpdateInvMovement.ParamByName('OLD_CARDKEY').AsString := CurrentCardKey;
          qUpdateInvMovement.ParamByName('NEW_CARDKEY').AsString := NewCardKey;
          qUpdateInvMovement.ExecQuery;
          qUpdateInvMovement.Close;

          // обновление в дополнительнных таблицах складских документов ссылок на складские карточки
          for I := 0 to CardkeyFieldCount - 1 do
          begin
            q2.SQL.Text :=
              'SELECT RDB$FIELD_NAME' +
              'FROM RDB$RELATION_FIELDS ' +
              'WHERE RDB$RELATION_NAME = :RelationName' +
              '  AND RDB$FIELD_NAME = :FieldName';
            q2.ParamByName('RelationName').AsString := CurrentRelationName;
            q2.ParamByName('FieldName').AsString := CardkeyFieldNames[I];
            q2.ExecQuery;

            if not q2.RecordCount > 0 then
            begin
              q2.Close;
              q2.SQL.Text := Format(
                'UPDATE ' +
                '  %0:s line ' +
                'SET ' +
                '  line.%1:s = :new_cardkey ' +
                'WHERE ' +
                '  line.%1:s = :old_cardkey ' +
                '  AND ( '+
                '    SELECT doc.documentdate ' +
                '    FROM gd_document doc ' +
                '    WHERE doc.id = line.documentkey' +
                '  ) >= :closedate ',
                [CurrentRelationName, CardkeyFieldNames[I]]);

              q2.ParamByName('OLD_CARDKEY').AsString := CurrentCardKey;
              q2.ParamByName('NEW_CARDKEY').AsString := NewCardKey;
              q2.ParamByName('CLOSEDATE').AsString := FDocumentdateWhereClause;
              q2.ExecQuery;
            end;
            q2.Close;

          end;
        end
        else begin
          LogEvent(Format('Error rebinding card: OLD_CARDKEY = %0:d', [CurrentCardKey]));
        end;

        q.Next;
      end;
      q.Close;
      Tr.Commit;
      LogEvent('Rebinding cards... OK');
    finally
      q.Free;
      q2.Free;
      q3.Free;
      qUpdateInvMovement.Free;
      qUpdateFirstDocKey.Free;
      qUpdateCard.Free;
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
    Tr.Params.Add('no_auto_undo');
    Tr.StartTransaction;
    q.Transaction := Tr;
    q2.Transaction := Tr;

    q.SQL.Text :=
      'SELECT gc.contactkey as CompKey ' +
      'FROM GD_COMPANY gc ' +
      'WHERE gc.fullname = :compName ';
    q.ParamByName('compName').AsString := FCompanyName;
    q.ExecQuery;

    CompanyKey := q.FieldByName('CompKey').AsString;
    q.Close;

    q.SQL.Text :=
     'SELECT ' +
      '  gd.id AS InvDocTypeKey ' +
      'FROM ' +
      '  GD_DOCUMENTTYPE gd ' +
      'WHERE ' +
      '  gd.name = ''Произвольный тип'' ';
    q.ExecQuery;

    InvDocTypeKey := q.FieldByName('InvDocTypeKey').AsString;
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
      q.ParamByName('id').AsString := PseudoClientKey;
      q.ParamByName('parent').AsInteger := q2.FieldByName('ParentId').AsInteger;
      q.ExecQuery;

      q2.Close;
      Tr.Commit;
      Tr.StartTransaction;
    end
    else
      PseudoClientKey := q.FieldByName('id').AsString;
    q.Close;

    CalculateInvBalance(q);  // строим запрос на складские остатки для компании

    DecimalSeparator := '.';   // тип Currency в SQL имееет DecimalSeparator = ','

    LineCount := 0;

    // Пройдем по остаткам ТМЦ
    while not q.EOF do
    begin

      // Если кол-во позиций в документе > 2000, то создадим новую шапку документа
      { ...}

      if q.FieldByName('BALANCE').AsCurrency >= 0 then
      begin //приход на ContactKey от PseudoClientKey
        DocumentParentKey := CreateHeaderInvDoc(
          PseudoClientKey, // поставщик
          q.FieldByName('ContactKey').AsString,
          q.FieldByName('COMPANYKEY').AsString,                                  ///
          InvDocTypeKey,
          FCurUserContactKey);

        CreatePositionInvDoc(
          DocumentParentKey,
          PseudoClientKey, // поставщик
          q.FieldByName('ContactKey').AsString,
          q.FieldByName('COMPANYKEY').AsString,
          q.FieldByName('GOODKEY').AsString,
          q.FieldByName('BALANCE').AsCurrency,
          InvDocTypeKey,
          FCurUserContactKey,
          q);
      end
      else begin
        // Приход на PseudoClientKey от ContactKey (с положит. кол-вом ТМЦ)
        DocumentParentKey := CreateHeaderInvDoc(
          q.FieldByName('ContactKey').AsString,
          PseudoClientKey,
          q.FieldByName('COMPANYKEY').AsString,
          InvDocTypeKey,
          FCurUserContactKey);

        CreatePositionInvDoc(
          DocumentParentKey,
          q.FieldByName('ContactKey').AsString,
          PseudoClientKey,
          q.FieldByName('COMPANYKEY').AsString,
          q.FieldByName('GOODKEY').AsString,
          -(q.FieldByName('BALANCE').AsCurrency),
          InvDocTypeKey,
          FCurUserContactKey,
          q);
      end;
      //Inc(LineCount);

      q.Next;
    end;
    q.Close;

    RebindInvCards;

    Tr.Commit;
  finally
    q.Free;
    q2.Free;
    Tr.Free;
    UsrFieldsList.Free;
  end;
  LogEvent('Calculating inventory balance... OK');
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
      '  (c.rdb$constraint_type = ''FOREIGN KEY'')  ' +                        
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

  procedure RestoreFKConstraints;                                              
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
    RestoreFKConstraints;                                                    

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
    if RelationExist2('DBS_PK_UNIQUE_CONSTRAINTS', Tr) then                     {TODO: не выполняется RelationExist2}
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
