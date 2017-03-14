unit mdf_AccAnalyticsExtSupport;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit;

procedure AddAccAnalyticsExt(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure AddAccAnalyticsExt(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    try
      Tr.DefaultDatabase := IBDB;
      q.Transaction := Tr;
      Tr.StartTransaction;

      if not RelationExist2('AC_ACCANALYTICSEXT', Tr) then
      begin
        Log('Добавление объектов аналитики для развернутого сальда по счету');

        q.SQL.Text :=
          'CREATE TABLE AC_ACCANALYTICSEXT ' +
          '( ' +
          '  id          dintkey, ' +
          '  accountkey  dintkey, ' +
          '  valuekey    dintkey, ' +
          '' +
          '  CONSTRAINT ac_pk_ac_accanalyticsext PRIMARY KEY (id)' +
          ' )';
        q.ExecQuery;

        q.SQL.Text :=
          'CREATE UNIQUE INDEX ac_idx_accanalyticsext ' +
          '  ON ac_accanalyticsext (accountkey, valuekey)';
        q.ExecQuery;

        q.SQL.Text :=
          'ALTER TABLE ac_accanalyticsext ' +
          'ADD CONSTRAINT fk_ac_accanalyticsext_account ' +
          'FOREIGN KEY (accountkey) ' +
          'REFERENCES ac_account(id) ' +
          '  ON UPDATE CASCADE ' +
          '  ON DELETE CASCADE ';
        q.ExecQuery;

        q.SQL.Text :=
          'ALTER TABLE ac_accanalyticsext ' +
          'ADD CONSTRAINT fk_ac_accanalyticsext_value ' +
          'FOREIGN KEY (valuekey) ' +
          'REFERENCES at_relation_fields(id) ' +
          '  ON UPDATE CASCADE ' +
          '  ON DELETE CASCADE';
        q.ExecQuery;

        q.SQL.Text :=
          'GRANT ALL ON ac_accanalyticsext TO administrator';
        q.ExecQuery;
      end;

      Tr.Commit;
      Tr.StartTransaction;

      q.SQL.Text :=
        'MERGE INTO ac_accanalyticsext AS tgt ' +
        'USING ' +
        '  (SELECT a.id AS accountkey, a.analyticalfield ' +
        '     FROM ac_account a ' +
        '     LEFT JOIN ac_accanalyticsext aa ' +
        '       ON a.id = aa.accountkey AND a.analyticalfield = aa.valuekey ' +
        '     WHERE analyticalfield IS NOT NULL AND aa.ID IS NULL) AS src ' +
        'ON tgt.accountkey = src.accountkey AND tgt.valuekey = src.analyticalfield ' +
        'WHEN NOT MATCHED THEN INSERT (id, accountkey, valuekey) VALUES (GEN_ID(gd_g_unique, 1), src.accountkey, src.analyticalfield)';
      q.ExecQuery;

      q.SQL.Text :=
        'CREATE OR ALTER PROCEDURE AC_ACCOUNTEXSALDO_BAL ( '#13#10 +
        '    DATEEND DATE, '#13#10 +
        '    ACCOUNTKEY INTEGER, '#13#10 +
        '    FIELDNAME VARCHAR(60), '#13#10 +
        '    COMPANYKEY INTEGER, '#13#10 +
        '    ALLHOLDINGCOMPANIES INTEGER, '#13#10 +
        '    CURRKEY INTEGER) '#13#10 +
        'RETURNS ( '#13#10 +
        '    DEBITSALDO NUMERIC(15, 4), '#13#10 +
        '    CREDITSALDO NUMERIC(15, 4), '#13#10 +
        '    CURRDEBITSALDO NUMERIC(15, 4), '#13#10 +
        '    CURRCREDITSALDO NUMERIC(15, 4), '#13#10 +
        '    EQDEBITSALDO NUMERIC(15, 4), '#13#10 +
        '    EQCREDITSALDO NUMERIC(15, 4)) '#13#10 +
        ' AS '#13#10 +
        '   DECLARE VARIABLE SALDO NUMERIC(15, 4); '#13#10 +
        '   DECLARE VARIABLE SALDOCURR NUMERIC(15, 4); '#13#10 +
        '   DECLARE VARIABLE SALDOEQ NUMERIC(15, 4); '#13#10 +
        '   DECLARE VARIABLE TEMPVAR varchar(60); '#13#10 +
        '   DECLARE VARIABLE CLOSEDATE DATE; '#13#10 +
        '   DECLARE VARIABLE CK INTEGER; '#13#10 +
        '   DECLARE VARIABLE SQLStatement VARCHAR(2048); '#13#10 +
        '   DECLARE VARIABLE HoldingList VARCHAR(1024) = ''''; '#13#10 +
        '   DECLARE VARIABLE CurrCondition_E VARCHAR(1024) = ''''; '#13#10 +
        '   DECLARE VARIABLE CurrCondition_Bal VARCHAR(1024) = ''''; '#13#10 +
        ' BEGIN '#13#10 +
        '   DEBITSALDO = 0; '#13#10 +
        '   CREDITSALDO = 0; '#13#10 +
        '   CURRDEBITSALDO = 0; '#13#10 +
        '   CURRCREDITSALDO = 0; '#13#10 +
        '   EQDEBITSALDO = 0; '#13#10 +
        '   EQCREDITSALDO = 0; '#13#10 +
        '   CLOSEDATE = CAST((CAST(''17.11.1858'' AS DATE) + GEN_ID(gd_g_entry_balance_date, 0)) AS DATE); '#13#10 +
        ' '#13#10 +
        '   IF (:AllHoldingCompanies = 1) THEN '#13#10 +
        '   BEGIN '#13#10 +
        '     SELECT LIST(h.companykey, '','') '#13#10 +
        '     FROM gd_holding h '#13#10 +
        '     WHERE h.holdingkey = :companykey '#13#10 +
        '     INTO :HoldingList; '#13#10 +
        '     HoldingList = COALESCE(:HoldingList, ''''); '#13#10 +
        '   END '#13#10 +
        ' '#13#10 +
        '   HoldingList = :CompanyKey || IIF(:HoldingList = '''', '''', '','' || :HoldingList); '#13#10 +
        ' '#13#10 +
        '   IF (:CurrKey > 0) THEN '#13#10 +
        '   BEGIN '#13#10 +
        '     CurrCondition_E =   '' AND (e.currkey   = '' || :currkey || '') ''; '#13#10 +
        '     CurrCondition_Bal = '' AND (bal.currkey = '' || :currkey || '') ''; '#13#10 +
        '   END '#13#10 +
        ' '#13#10 +
        '   IF (:dateend >= :CLOSEDATE) THEN '#13#10 +
        '   BEGIN '#13#10 +
        '     sqlstatement = '#13#10 +
        '       ''SELECT '#13#10 +
        '         SUM(main.debitncu - main.creditncu), '#13#10 +
        '         SUM(main.debitcurr - main.creditcurr), '#13#10 +
        '         SUM(main.debiteq - main.crediteq), '#13#10 +
        '         main.companykey '#13#10 +
        '       FROM '#13#10 +
        '       ( '#13#10 +
        '         SELECT '#13#10 +
        '           bal.'' || FIELDNAME || '', '#13#10 +
        '           bal.debitncu, bal.creditncu, '#13#10 +
        '           bal.debitcurr, bal.creditcurr, '#13#10 +
        '           bal.debiteq, bal.crediteq, '#13#10 +
        '           bal.companykey '#13#10 +
        '         FROM '#13#10 +
        '           ac_entry_balance bal '#13#10 +
        '         WHERE '#13#10 +
        '           bal.accountkey = '' || CAST(:accountkey AS VARCHAR(20)) || '' '#13#10 +
        '             AND (bal.companykey IN ('' || :HoldingList || ''))'' '#13#10 +
        '            || :CurrCondition_Bal || '' '#13#10 +
        ' '#13#10 +
        '         UNION ALL '#13#10 +
        ' '#13#10 +
        '         SELECT '#13#10 +
        '           e.'' || FIELDNAME || '', '#13#10 +
        '           e.debitncu, e.creditncu, '#13#10 +
        '           e.debitcurr, e.creditcurr, '#13#10 +
        '           e.debiteq, e.crediteq, '#13#10 +
        '           e.companykey '#13#10 +
        '         FROM '#13#10 +
        '           ac_entry e '#13#10 +
        '         WHERE '#13#10 +
        '           e.accountkey = '' || CAST(:accountkey AS VARCHAR(20)) || '' '#13#10 +
        '           AND e.entrydate >= '''''' || CAST(:closedate AS VARCHAR(20)) || '''''' '#13#10 +
        '           AND e.entrydate < '''''' || CAST(:dateend AS VARCHAR(20)) || '''''' '#13#10 +
        '           AND (e.companykey IN ('' || :HoldingList || ''))'' '#13#10 +
        '          || :CurrCondition_E || '' '#13#10 +
        ' '#13#10 +
        '       ) main '#13#10 +
        '       GROUP BY '#13#10 +
        '         main.'' || FIELDNAME || '', main.companykey''; '#13#10 +
        '   END '#13#10 +
        '   ELSE '#13#10 +
        '   BEGIN '#13#10 +
        '     sqlstatement = '#13#10 +
        '       ''SELECT '#13#10 +
        '         SUM(main.debitncu - main.creditncu), '#13#10 +
        '         SUM(main.debitcurr - main.creditcurr), '#13#10 +
        '         SUM(main.debiteq - main.crediteq), '#13#10 +
        '         main.companykey '#13#10 +
        '       FROM '#13#10 +
        '       ( '#13#10 +
        '         SELECT '#13#10 +
        '           bal.'' || FIELDNAME || '', '#13#10 +
        '           bal.debitncu, bal.creditncu, '#13#10 +
        '           bal.debitcurr, bal.creditcurr, '#13#10 +
        '           bal.debiteq, bal.crediteq, '#13#10 +
        '           bal.companykey '#13#10 +
        '         FROM '#13#10 +
        '           ac_entry_balance bal '#13#10 +
        '         WHERE '#13#10 +
        '           bal.accountkey = '' || CAST(:accountkey AS VARCHAR(20)) || '' '#13#10 +
        '             AND (bal.companykey IN ('' || :HoldingList || ''))'' '#13#10 +
        '            || :CurrCondition_Bal || '' '#13#10 +
        ' '#13#10 +
        '         UNION ALL '#13#10 +
        ' '#13#10 +
        '         SELECT '#13#10 +
        '           e.'' || FIELDNAME || '', '#13#10 +
        '          - e.debitncu, - e.creditncu, '#13#10 +
        '          - e.debitcurr, - e.creditcurr, '#13#10 +
        '          - e.debiteq, - e.crediteq, '#13#10 +
        '          e.companykey '#13#10 +
        '         FROM '#13#10 +
        '           ac_entry e '#13#10 +
        '         WHERE '#13#10 +
        '           e.accountkey = '' || CAST(:accountkey AS VARCHAR(20)) || '' '#13#10 +
        '           AND e.entrydate >= '''''' || CAST(:dateend AS VARCHAR(20)) || '''''' '#13#10 +
        '           AND e.entrydate < '''''' || CAST(:closedate AS VARCHAR(20)) || '''''' '#13#10 +
        '           AND (e.companykey IN ('' || :HoldingList || ''))'' '#13#10 +
        '           || :CurrCondition_E || '' '#13#10 +
        '        ) main '#13#10 +
        '       GROUP BY '#13#10 +
        '         main.'' || FIELDNAME || '', main.companykey''; '#13#10 +
        '   END '#13#10 +
        ' '#13#10 +
        '   FOR '#13#10 +
        '     EXECUTE STATEMENT '#13#10 +
        '       sqlstatement '#13#10 +
        '     INTO '#13#10 +
        '       :SALDO, :SALDOCURR, :SALDOEQ, :CK '#13#10 +
        '   DO '#13#10 +
        '   BEGIN '#13#10 +
        '     SALDO = COALESCE(:SALDO, 0); '#13#10 +
        '     IF (SALDO > 0) THEN '#13#10 +
        '       DEBITSALDO = DEBITSALDO + SALDO; '#13#10 +
        '     ELSE '#13#10 +
        '       CREDITSALDO = CREDITSALDO - SALDO; '#13#10 +
        '     SALDOCURR = COALESCE(:SALDOCURR, 0); '#13#10 +
        '     IF (SALDOCURR > 0) THEN '#13#10 +
        '       CURRDEBITSALDO = CURRDEBITSALDO + SALDOCURR; '#13#10 +
        '     ELSE '#13#10 +
        '       CURRCREDITSALDO = CURRCREDITSALDO - SALDOCURR; '#13#10 +
        '     SALDOEQ = COALESCE(:SALDOEQ, 0); '#13#10 +
        '     IF (SALDOEQ > 0) THEN '#13#10 +
        '       EQDEBITSALDO = EQDEBITSALDO + SALDOEQ; '#13#10 +
        '     ELSE '#13#10 +
        '       EQCREDITSALDO = EQCREDITSALDO - SALDOEQ; '#13#10 +
        '   END '#13#10 +
        '   SUSPEND; '#13#10 +
        ' END';
      q.ExecQuery;

      q.SQL.Text :=
        'CREATE OR ALTER PROCEDURE AC_CIRCULATIONLIST ( '#13#10 +
        '    datebegin date, '#13#10 +
        '    dateend date, '#13#10 +
        '    companykey integer, '#13#10 +
        '    allholdingcompanies integer, '#13#10 +
        '    accountkey integer, '#13#10 +
        '    ingroup integer, '#13#10 +
        '    currkey integer, '#13#10 +
        '    dontinmove integer) '#13#10 +
        'returns ( '#13#10 +
        '    alias varchar(20), '#13#10 +
        '    name varchar(180), '#13#10 +
        '    id integer, '#13#10 +
        '    ncu_begin_debit numeric(15,4), '#13#10 +
        '    ncu_begin_credit numeric(15,4), '#13#10 +
        '    ncu_debit numeric(15,4), '#13#10 +
        '    ncu_credit numeric(15,4), '#13#10 +
        '    ncu_end_debit numeric(15,4), '#13#10 +
        '    ncu_end_credit numeric(15,4), '#13#10 +
        '    curr_begin_debit numeric(15,4), '#13#10 +
        '    curr_begin_credit numeric(15,4), '#13#10 +
        '    curr_debit numeric(15,4), '#13#10 +
        '    curr_credit numeric(15,4), '#13#10 +
        '    curr_end_debit numeric(15,4), '#13#10 +
        '    curr_end_credit numeric(15,4), '#13#10 +
        '    eq_begin_debit numeric(15,4), '#13#10 +
        '    eq_begin_credit numeric(15,4), '#13#10 +
        '    eq_debit numeric(15,4), '#13#10 +
        '    eq_credit numeric(15,4), '#13#10 +
        '    eq_end_debit numeric(15,4), '#13#10 +
        '    eq_end_credit numeric(15,4), '#13#10 +
        '    offbalance integer) '#13#10 +
        'as '#13#10 +
        '  DECLARE VARIABLE ACTIVITY CHAR(1); '#13#10 +
        '  DECLARE VARIABLE SALDO NUMERIC(15,4); '#13#10 +
        '  DECLARE VARIABLE SALDOCURR NUMERIC(15,4); '#13#10 +
        '  DECLARE VARIABLE SALDOEQ NUMERIC(15,4); '#13#10 +
        '  DECLARE VARIABLE FIELDNAME VARCHAR(60); '#13#10 +
        '  DECLARE VARIABLE LB INTEGER; '#13#10 +
        '  DECLARE VARIABLE RB INTEGER; '#13#10 +
        'BEGIN '#13#10 +
        '  SELECT c.lb, c.rb FROM ac_account c '#13#10 +
        '  WHERE c.id = :ACCOUNTKEY '#13#10 +
        '  INTO :lb, :rb; '#13#10 +
        ' '#13#10 +
        '  FOR '#13#10 +
        '    SELECT a.ID, a.ALIAS, a.activity, f.fieldname, a.Name, a.offbalance '#13#10 +
        '    FROM ac_account a '#13#10 +
        '      LEFT JOIN '#13#10 +
        '        (SELECT aa.accountkey, LIST(rf.fieldname, '', '') AS fieldname '#13#10 +
        '          FROM  ac_accanalyticsext aa '#13#10 +
        '            JOIN at_relation_fields rf ON aa.valuekey = rf.id '#13#10 +
        '          GROUP BY aa.accountkey) f '#13#10 +
        '        ON a.id = f.accountkey '#13#10 +
        '    WHERE '#13#10 +
        '      a.accounttype IN (''A'', ''S'') AND '#13#10 +
        '      a.LB >= :LB AND a.RB <= :RB AND a.alias <> ''00'' '#13#10 +
        '    INTO :id, :ALIAS, :activity, :fieldname, :name, :offbalance '#13#10 +
        '  DO '#13#10 +
        '  BEGIN '#13#10 +
        '    NCU_BEGIN_DEBIT = 0; '#13#10 +
        '    NCU_BEGIN_CREDIT = 0; '#13#10 +
        '    CURR_BEGIN_DEBIT = 0; '#13#10 +
        '    CURR_BEGIN_CREDIT = 0; '#13#10 +
        '    EQ_BEGIN_DEBIT = 0; '#13#10 +
        '    EQ_BEGIN_CREDIT = 0; '#13#10 +
        ' '#13#10 +
        '    IF ((activity <> ''B'') OR (fieldname IS NULL)) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      IF ( ALLHOLDINGCOMPANIES = 0) THEN '#13#10 +
        '      SELECT '#13#10 +
        '        SUM(e.DEBITNCU - e.CREDITNCU), '#13#10 +
        '        SUM(e.DEBITCURR - e.CREDITCURR), '#13#10 +
        '        SUM(e.DEBITEQ - e.CREDITEQ) '#13#10 +
        '      FROM '#13#10 +
        '        ac_entry e '#13#10 +
        '      WHERE '#13#10 +
        '        e.accountkey = :id AND e.entrydate < :datebegin AND '#13#10 +
        '        (e.companykey = :companykey) AND '#13#10 +
        '        ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
        '      INTO :SALDO, '#13#10 +
        '        :SALDOCURR, :SALDOEQ; '#13#10 +
        '      ELSE '#13#10 +
        '      SELECT '#13#10 +
        '        SUM(e.DEBITNCU - e.CREDITNCU), '#13#10 +
        '        SUM(e.DEBITCURR - e.CREDITCURR), '#13#10 +
        '        SUM(e.DEBITEQ - e.CREDITEQ) '#13#10 +
        '      FROM '#13#10 +
        '        ac_entry e '#13#10 +
        '      WHERE '#13#10 +
        '        e.accountkey = :id AND e.entrydate < :datebegin AND '#13#10 +
        '        (e.companykey = :companykey or e.companykey IN ( '#13#10 +
        '          SELECT '#13#10 +
        '            h.companykey '#13#10 +
        '          FROM '#13#10 +
        '            gd_holding h '#13#10 +
        '          WHERE '#13#10 +
        '            h.holdingkey = :companykey)) AND '#13#10 +
        '        ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
        '      INTO :SALDO, '#13#10 +
        '        :SALDOCURR, :SALDOEQ; '#13#10 +
        ' '#13#10 +
        '      IF (SALDO IS NULL) THEN '#13#10 +
        '        SALDO = 0; '#13#10 +
        ' '#13#10 +
        '      IF (SALDOCURR IS NULL) THEN '#13#10 +
        '        SALDOCURR = 0; '#13#10 +
        ' '#13#10 +
        '      IF (SALDOEQ IS NULL) THEN '#13#10 +
        '        SALDOEQ = 0; '#13#10 +
        ' '#13#10 +
        ' '#13#10 +
        '      IF (SALDO > 0) THEN '#13#10 +
        '        NCU_BEGIN_DEBIT = SALDO; '#13#10 +
        '      ELSE '#13#10 +
        '        NCU_BEGIN_CREDIT = 0 - SALDO; '#13#10 +
        ' '#13#10 +
        '      IF (SALDOCURR > 0) THEN '#13#10 +
        '        CURR_BEGIN_DEBIT = SALDOCURR; '#13#10 +
        '      ELSE '#13#10 +
        '        CURR_BEGIN_CREDIT = 0 - SALDOCURR; '#13#10 +
        ' '#13#10 +
        '      IF (SALDOEQ > 0) THEN '#13#10 +
        '        EQ_BEGIN_DEBIT = SALDOEQ; '#13#10 +
        '      ELSE '#13#10 +
        '        EQ_BEGIN_CREDIT = 0 - SALDOEQ; '#13#10 +
        '    END '#13#10 +
        '    ELSE '#13#10 +
        '    BEGIN '#13#10 +
        '      SELECT '#13#10 +
        '        DEBITsaldo, '#13#10 +
        '        creditsaldo '#13#10 +
        '      FROM '#13#10 +
        '        AC_ACCOUNTEXSALDO(:datebegin, :ID, :FIELDNAME, :COMPANYKEY, '#13#10 +
        '          :allholdingcompanies, :INGROUP, :currkey) '#13#10 +
        '      INTO '#13#10 +
        '        :NCU_BEGIN_DEBIT, '#13#10 +
        '        :NCU_BEGIN_CREDIT; '#13#10 +
        '    END '#13#10 +
        ' '#13#10 +
        '    IF (ALLHOLDINGCOMPANIES = 0) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      IF (DONTINMOVE = 1) THEN '#13#10 +
        '        SELECT '#13#10 +
        '          SUM(e.DEBITNCU), '#13#10 +
        '          SUM(e.CREDITNCU), '#13#10 +
        '          SUM(e.DEBITCURR), '#13#10 +
        '          SUM(e.CREDITCURR), '#13#10 +
        '          SUM(e.DEBITEQ), '#13#10 +
        '          SUM(e.CREDITEQ) '#13#10 +
        '        FROM '#13#10 +
        '          ac_entry e JOIN ac_transaction tr ON e.transactionkey = tr.id '#13#10 +
        '        WHERE '#13#10 +
        '          e.accountkey = :id AND e.entrydate >= :datebegin AND '#13#10 +
        '          e.entrydate <= :dateend AND (e.companykey = :companykey) AND '#13#10 +
        '          ((0 = :currkey) OR (e.currkey = :currkey)) AND '#13#10 +
        '          NOT EXISTS( SELECT e_m.id FROM  ac_entry e_m '#13#10 +
        '              JOIN ac_entry e_cm ON e_cm.recordkey=e_m.recordkey AND '#13#10 +
        '               e_cm.accountpart <> e_m.accountpart AND '#13#10 +
        '               e_cm.accountkey=e_m.accountkey AND '#13#10 +
        '               (e_m.debitncu=e_cm.creditncu OR '#13#10 +
        '                e_m.creditncu=e_cm.debitncu OR '#13#10 +
        '                e_m.debitcurr=e_cm.creditcurr OR '#13#10 +
        '                e_m.creditcurr=e_cm.debitcurr) '#13#10 +
        '              WHERE e_m.id=e.id) '#13#10 +
        '          AND COALESCE(tr.isinternal, 0) = 0 '#13#10 +
        '        INTO :NCU_DEBIT, :NCU_CREDIT, :CURR_DEBIT, CURR_CREDIT, :EQ_DEBIT, EQ_CREDIT; '#13#10 +
        '      ELSE '#13#10 +
        '        SELECT '#13#10 +
        '          SUM(e.DEBITNCU), '#13#10 +
        '          SUM(e.CREDITNCU), '#13#10 +
        '          SUM(e.DEBITCURR), '#13#10 +
        '          SUM(e.CREDITCURR), '#13#10 +
        '          SUM(e.DEBITEQ), '#13#10 +
        '          SUM(e.CREDITEQ) '#13#10 +
        '        FROM '#13#10 +
        '          ac_entry e '#13#10 +
        '        WHERE '#13#10 +
        '          e.accountkey = :id AND e.entrydate >= :datebegin AND '#13#10 +
        '          e.entrydate <= :dateend AND (e.companykey = :companykey) AND '#13#10 +
        '          ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
        '        INTO :NCU_DEBIT, :NCU_CREDIT, :CURR_DEBIT, CURR_CREDIT, :EQ_DEBIT, EQ_CREDIT; '#13#10 +
        '    END '#13#10 +
        '    ELSE '#13#10 +
        '    BEGIN '#13#10 +
        '      IF (DONTINMOVE = 1) THEN '#13#10 +
        '        SELECT '#13#10 +
        '          SUM(e.DEBITNCU), '#13#10 +
        '          SUM(e.CREDITNCU), '#13#10 +
        '          SUM(e.DEBITCURR), '#13#10 +
        '          SUM(e.CREDITCURR), '#13#10 +
        '          SUM(e.DEBITEQ), '#13#10 +
        '          SUM(e.CREDITEQ) '#13#10 +
        '        FROM '#13#10 +
        '          ac_entry e JOIN ac_transaction tr ON e.transactionkey = tr.id '#13#10 +
        '        WHERE '#13#10 +
        '          e.accountkey = :id AND e.entrydate >= :datebegin AND '#13#10 +
        '          e.entrydate <= :dateend AND '#13#10 +
        '          (e.companykey = :companykey or e.companykey IN ( '#13#10 +
        '          SELECT h.companykey FROM gd_holding h '#13#10 +
        '           WHERE h.holdingkey = :companykey)) AND '#13#10 +
        '          ((0 = :currkey) OR (e.currkey = :currkey)) AND '#13#10 +
        '          NOT EXISTS( SELECT e_m.id FROM  ac_entry e_m '#13#10 +
        '              JOIN ac_entry e_cm ON e_cm.recordkey=e_m.recordkey AND '#13#10 +
        '               e_cm.accountpart <> e_m.accountpart AND '#13#10 +
        '               e_cm.accountkey=e_m.accountkey AND '#13#10 +
        '               (e_m.debitncu=e_cm.creditncu OR '#13#10 +
        '                e_m.creditncu=e_cm.debitncu OR '#13#10 +
        '                e_m.debitcurr=e_cm.creditcurr OR '#13#10 +
        '                e_m.creditcurr=e_cm.debitcurr) '#13#10 +
        '              WHERE e_m.id=e.id) '#13#10 +
        '          AND COALESCE(tr.isinternal, 0) = 0 '#13#10 +
        '        INTO :NCU_DEBIT, :NCU_CREDIT, :CURR_DEBIT, CURR_CREDIT, :EQ_DEBIT, :EQ_CREDIT; '#13#10 +
        '      ELSE '#13#10 +
        '        SELECT '#13#10 +
        '          SUM(e.DEBITNCU), '#13#10 +
        '          SUM(e.CREDITNCU), '#13#10 +
        '          SUM(e.DEBITCURR), '#13#10 +
        '          SUM(e.CREDITCURR), '#13#10 +
        '          SUM(e.DEBITEQ), '#13#10 +
        '          SUM(e.CREDITEQ) '#13#10 +
        '        FROM '#13#10 +
        '          ac_entry e '#13#10 +
        '        WHERE '#13#10 +
        '          e.accountkey = :id AND e.entrydate >= :datebegin AND '#13#10 +
        '          e.entrydate <= :dateend AND '#13#10 +
        '          (e.companykey = :companykey or e.companykey IN ( '#13#10 +
        '          SELECT h.companykey FROM gd_holding h '#13#10 +
        '           WHERE h.holdingkey = :companykey)) AND '#13#10 +
        '          ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
        '        INTO :NCU_DEBIT, :NCU_CREDIT, :CURR_DEBIT, CURR_CREDIT, :EQ_DEBIT, :EQ_CREDIT; '#13#10 +
        '    END '#13#10 +
        ' '#13#10 +
        '    IF (NCU_DEBIT IS NULL) THEN '#13#10 +
        '      NCU_DEBIT = 0; '#13#10 +
        ' '#13#10 +
        '    IF (NCU_CREDIT IS NULL) THEN '#13#10 +
        '      NCU_CREDIT = 0; '#13#10 +
        ' '#13#10 +
        '    IF (CURR_DEBIT IS NULL) THEN '#13#10 +
        '      CURR_DEBIT = 0; '#13#10 +
        ' '#13#10 +
        '    IF (CURR_CREDIT IS NULL) THEN '#13#10 +
        '      CURR_CREDIT = 0; '#13#10 +
        ' '#13#10 +
        '    IF (EQ_DEBIT IS NULL) THEN '#13#10 +
        '      EQ_DEBIT = 0; '#13#10 +
        ' '#13#10 +
        '    IF (EQ_CREDIT IS NULL) THEN '#13#10 +
        '      EQ_CREDIT = 0; '#13#10 +
        ' '#13#10 +
        '    NCU_END_DEBIT = 0; '#13#10 +
        '    NCU_END_CREDIT = 0; '#13#10 +
        '    CURR_END_DEBIT = 0; '#13#10 +
        '    CURR_END_CREDIT = 0; '#13#10 +
        '    EQ_END_DEBIT = 0; '#13#10 +
        '    EQ_END_CREDIT = 0; '#13#10 +
        ' '#13#10 +
        '    IF ((ACTIVITY <> ''B'') OR (FIELDNAME IS NULL)) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      SALDO = NCU_BEGIN_DEBIT - NCU_BEGIN_CREDIT + NCU_DEBIT - NCU_CREDIT; '#13#10 +
        '      IF (SALDO > 0) THEN '#13#10 +
        '        NCU_END_DEBIT = SALDO; '#13#10 +
        '      ELSE '#13#10 +
        '        NCU_END_CREDIT = 0 - SALDO; '#13#10 +
        ' '#13#10 +
        '      SALDOCURR = CURR_BEGIN_DEBIT - CURR_BEGIN_CREDIT + CURR_DEBIT - CURR_CREDIT; '#13#10 +
        '      IF (SALDOCURR > 0) THEN '#13#10 +
        '        CURR_END_DEBIT = SALDOCURR; '#13#10 +
        '      ELSE '#13#10 +
        '        CURR_END_CREDIT = 0 - SALDOCURR; '#13#10 +
        ' '#13#10 +
        '      SALDOEQ = EQ_BEGIN_DEBIT - EQ_BEGIN_CREDIT + EQ_DEBIT - EQ_CREDIT; '#13#10 +
        '      IF (SALDOEQ > 0) THEN '#13#10 +
        '        EQ_END_DEBIT = SALDOEQ; '#13#10 +
        '      ELSE '#13#10 +
        '        EQ_END_CREDIT = 0 - SALDOEQ; '#13#10 +
        '    END '#13#10 +
        '    ELSE '#13#10 +
        '    BEGIN '#13#10 +
        '      IF ((NCU_BEGIN_DEBIT <> 0) OR (NCU_BEGIN_CREDIT <> 0) OR '#13#10 +
        '        (NCU_DEBIT <> 0) OR (NCU_CREDIT <> 0) OR '#13#10 +
        '        (CURR_BEGIN_DEBIT <> 0) OR (CURR_BEGIN_CREDIT <> 0) OR '#13#10 +
        '        (CURR_DEBIT <> 0) OR (CURR_CREDIT <> 0) OR '#13#10 +
        '        (EQ_BEGIN_DEBIT <> 0) OR (EQ_BEGIN_CREDIT <> 0) OR '#13#10 +
        '        (EQ_DEBIT <> 0) OR (EQ_CREDIT <> 0)) THEN '#13#10 +
        '      BEGIN '#13#10 +
        '        SELECT '#13#10 +
        '          DEBITsaldo, creditsaldo, '#13#10 +
        '          CurrDEBITsaldo, Currcreditsaldo, '#13#10 +
        '          EQDEBITsaldo, EQcreditsaldo '#13#10 +
        '        FROM AC_ACCOUNTEXSALDO(:DATEEND + 1, :ID, :FIELDNAME, :COMPANYKEY, '#13#10 +
        '          :allholdingcompanies, :INGROUP, :currkey) '#13#10 +
        '        INTO :NCU_END_DEBIT, :NCU_END_CREDIT, :CURR_END_DEBIT, :CURR_END_CREDIT, :EQ_END_DEBIT, :EQ_END_CREDIT; '#13#10 +
        '      END '#13#10 +
        '    END '#13#10 +
        '    IF ((NCU_BEGIN_DEBIT <> 0) OR (NCU_BEGIN_CREDIT <> 0) OR '#13#10 +
        '      (NCU_DEBIT <> 0) OR (NCU_CREDIT <> 0) OR '#13#10 +
        '      (CURR_BEGIN_DEBIT <> 0) OR (CURR_BEGIN_CREDIT <> 0) OR '#13#10 +
        '      (CURR_DEBIT <> 0) OR (CURR_CREDIT <> 0) OR '#13#10 +
        '      (EQ_BEGIN_DEBIT <> 0) OR (EQ_BEGIN_CREDIT <> 0) OR '#13#10 +
        '      (EQ_DEBIT <> 0) OR (EQ_CREDIT <> 0)) THEN '#13#10 +
        '    SUSPEND; '#13#10 +
        '  END '#13#10 +
        'END';
      q.ExecQuery;

      q.SQL.Text :=
        'CREATE OR ALTER PROCEDURE ac_circulationlist_bal( '#13#10 +
        '  datebegin DATE, '#13#10 +
        '  dateend DATE, '#13#10 +
        '  companykey INTEGER, '#13#10 +
        '  allholdingcompanies INTEGER, '#13#10 +
        '  accountkey INTEGER, '#13#10 +
        '  currkey INTEGER, '#13#10 +
        '  dontinmove INTEGER) '#13#10 +
        'RETURNS ( '#13#10 +
        '  alias VARCHAR(20), '#13#10 +
        '  name VARCHAR(180), '#13#10 +
        '  id INTEGER, '#13#10 +
        '  ncu_begin_debit NUMERIC(15,4), '#13#10 +
        '  ncu_begin_credit NUMERIC(15,4), '#13#10 +
        '  ncu_debit NUMERIC(15,4), '#13#10 +
        '  ncu_credit NUMERIC(15,4), '#13#10 +
        '  ncu_end_debit NUMERIC(15,4), '#13#10 +
        '  ncu_end_credit NUMERIC(15,4), '#13#10 +
        '  curr_begin_debit NUMERIC(15,4), '#13#10 +
        '  curr_begin_credit NUMERIC(15,4), '#13#10 +
        '  curr_debit NUMERIC(15,4), '#13#10 +
        '  curr_credit NUMERIC(15,4), '#13#10 +
        '  curr_end_debit NUMERIC(15,4), '#13#10 +
        '  curr_end_credit NUMERIC(15,4), '#13#10 +
        '  eq_begin_debit NUMERIC(15,4), '#13#10 +
        '  eq_begin_credit NUMERIC(15,4), '#13#10 +
        '  eq_debit NUMERIC(15,4), '#13#10 +
        '  eq_credit NUMERIC(15,4), '#13#10 +
        '  eq_end_debit NUMERIC(15,4), '#13#10 +
        '  eq_end_credit NUMERIC(15,4), '#13#10 +
        '  offbalance INTEGER) '#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE activity CHAR(1); '#13#10 +
        '  DECLARE VARIABLE saldo NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE saldocurr NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE saldoeq NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE fieldname VARCHAR(60); '#13#10 +
        '  DECLARE VARIABLE lb INTEGER; '#13#10 +
        '  DECLARE VARIABLE rb INTEGER; '#13#10 +
        '  DECLARE VARIABLE closedate DATE; '#13#10 +
        'BEGIN '#13#10 +
        '  closedate = CAST((CAST(''17.11.1858'' AS DATE) + GEN_ID(gd_g_entry_balance_date, 0)) AS DATE); '#13#10 +
        ' '#13#10 +
        '  SELECT '#13#10 +
        '    c.lb, c.rb '#13#10 +
        '  FROM '#13#10 +
        '    ac_account c '#13#10 +
        '  WHERE '#13#10 +
        '    c.id = :accountkey '#13#10 +
        '  INTO '#13#10 +
        '    :lb, :rb; '#13#10 +
        ' '#13#10 +
        '  FOR '#13#10 +
        '    SELECT '#13#10 +
        '      a.id, a.alias, a.activity, f.fieldname, a.name, a.offbalance '#13#10 +
        '    FROM '#13#10 +
        '      ac_account a '#13#10 +
        '      LEFT JOIN '#13#10 +
        '        (SELECT aa.accountkey, LIST(rf.fieldname, '', '') AS fieldname '#13#10 +
        '          FROM  ac_accanalyticsext aa '#13#10 +
        '            JOIN at_relation_fields rf ON aa.valuekey = rf.id '#13#10 +
        '          GROUP BY aa.accountkey) f '#13#10 +
        '        ON a.id = f.accountkey '#13#10 +
        '    WHERE '#13#10 +
        '      a.accounttype IN (''A'', ''S'') '#13#10 +
        '      AND a.lb >= :lb AND a.rb <= :rb AND a.alias <> ''00'' '#13#10 +
        '    INTO '#13#10 +
        '      :id, :alias, :activity, :fieldname, :name, :offbalance '#13#10 +
        '  DO '#13#10 +
        '  BEGIN '#13#10 +
        '    ncu_begin_debit = 0; '#13#10 +
        '    ncu_begin_credit = 0; '#13#10 +
        '    curr_begin_debit = 0; '#13#10 +
        '    curr_begin_credit = 0; '#13#10 +
        '    eq_begin_debit = 0; '#13#10 +
        '    eq_begin_credit = 0; '#13#10 +
        ' '#13#10 +
        '    IF ((activity <> ''B'') OR (fieldname IS NULL)) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      IF (:closedate <= :datebegin) THEN '#13#10 +
        '      BEGIN '#13#10 +
        '        SELECT '#13#10 +
        '          SUM(main.debitncu - main.creditncu), '#13#10 +
        '          SUM(main.debitcurr - main.creditcurr), '#13#10 +
        '          SUM(main.debiteq - main.crediteq) '#13#10 +
        '        FROM '#13#10 +
        '        ( '#13#10 +
        '          SELECT '#13#10 +
        '            bal.debitncu, '#13#10 +
        '            bal.creditncu, '#13#10 +
        '            bal.debitcurr, '#13#10 +
        '            bal.creditcurr, '#13#10 +
        '            bal.debiteq, '#13#10 +
        '            bal.crediteq '#13#10 +
        '          FROM '#13#10 +
        '            ac_entry_balance bal '#13#10 +
        '          WHERE '#13#10 +
        '            bal.accountkey = :id '#13#10 +
        '            AND (bal.companykey + 0 = :companykey '#13#10 +
        '              OR (:allholdingcompanies = 1 '#13#10 +
        '                AND bal.companykey + 0 IN ( '#13#10 +
        '                  SELECT '#13#10 +
        '                    h.companykey '#13#10 +
        '                  FROM '#13#10 +
        '                    gd_holding h '#13#10 +
        '                  WHERE '#13#10 +
        '                    h.holdingkey = :companykey))) '#13#10 +
        '            AND ((0 = :currkey) OR (bal.currkey = :currkey)) '#13#10 +
        ' '#13#10 +
        '          UNION ALL '#13#10 +
        ' '#13#10 +
        '          SELECT '#13#10 +
        '            e.debitncu, '#13#10 +
        '            e.creditncu, '#13#10 +
        '            e.debitcurr, '#13#10 +
        '            e.creditcurr, '#13#10 +
        '            e.debiteq, '#13#10 +
        '            e.crediteq '#13#10 +
        '          FROM '#13#10 +
        '            ac_entry e '#13#10 +
        '          WHERE '#13#10 +
        '            e.accountkey = :id '#13#10 +
        '            AND e.entrydate >= :closedate '#13#10 +
        '            AND e.entrydate < :datebegin '#13#10 +
        '            AND (e.companykey + 0 = :companykey '#13#10 +
        '              OR (:allholdingcompanies = 1 '#13#10 +
        '              AND e.companykey + 0 IN ( '#13#10 +
        '                SELECT '#13#10 +
        '                  h.companykey '#13#10 +
        '                FROM '#13#10 +
        '                  gd_holding h '#13#10 +
        '                WHERE '#13#10 +
        '                  h.holdingkey = :companykey))) '#13#10 +
        '            AND ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
        '        ) main '#13#10 +
        '        INTO '#13#10 +
        '          :saldo, :saldocurr, :saldoeq; '#13#10 +
        '      END '#13#10 +
        '      ELSE '#13#10 +
        '      BEGIN '#13#10 +
        '        SELECT '#13#10 +
        '          SUM(main.debitncu - main.creditncu), '#13#10 +
        '          SUM(main.debitcurr - main.creditcurr), '#13#10 +
        '          SUM(main.debiteq - main.crediteq) '#13#10 +
        '        FROM '#13#10 +
        '        ( '#13#10 +
        '          SELECT '#13#10 +
        '            bal.debitncu, '#13#10 +
        '            bal.creditncu, '#13#10 +
        '            bal.debitcurr, '#13#10 +
        '            bal.creditcurr, '#13#10 +
        '            bal.debiteq, '#13#10 +
        '            bal.crediteq '#13#10 +
        '          FROM '#13#10 +
        '            ac_entry_balance bal '#13#10 +
        '          WHERE '#13#10 +
        '            bal.accountkey = :id '#13#10 +
        '            AND (bal.companykey + 0 = :companykey '#13#10 +
        '              OR (:allholdingcompanies = 1 '#13#10 +
        '                AND bal.companykey + 0 IN ( '#13#10 +
        '                  SELECT '#13#10 +
        '                    h.companykey '#13#10 +
        '                  FROM '#13#10 +
        '                    gd_holding h '#13#10 +
        '                  WHERE '#13#10 +
        '                    h.holdingkey = :companykey))) '#13#10 +
        '            AND ((0 = :currkey) OR (bal.currkey = :currkey)) '#13#10 +
        ' '#13#10 +
        '          UNION ALL '#13#10 +
        ' '#13#10 +
        '          SELECT '#13#10 +
        '            - e.debitncu, '#13#10 +
        '            - e.creditncu, '#13#10 +
        '            - e.debitcurr, '#13#10 +
        '            - e.creditcurr, '#13#10 +
        '            - e.debiteq, '#13#10 +
        '            - e.crediteq '#13#10 +
        '          FROM '#13#10 +
        '            ac_entry e '#13#10 +
        '          WHERE '#13#10 +
        '            e.accountkey = :id '#13#10 +
        '            AND e.entrydate >= :datebegin '#13#10 +
        '            AND e.entrydate < :closedate '#13#10 +
        '            AND (e.companykey + 0 = :companykey '#13#10 +
        '              OR (:allholdingcompanies = 1 '#13#10 +
        '              AND e.companykey + 0 IN ( '#13#10 +
        '                SELECT '#13#10 +
        '                  h.companykey '#13#10 +
        '                FROM '#13#10 +
        '                  gd_holding h '#13#10 +
        '                WHERE '#13#10 +
        '                  h.holdingkey = :companykey))) '#13#10 +
        '            AND ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
        '        ) main '#13#10 +
        '        INTO '#13#10 +
        '          :saldo, :saldocurr, :saldoeq; '#13#10 +
        '      END '#13#10 +
        ' '#13#10 +
        '      IF (saldo IS NULL) THEN '#13#10 +
        '        saldo = 0; '#13#10 +
        '      IF (saldocurr IS NULL) THEN '#13#10 +
        '        saldocurr = 0; '#13#10 +
        '      IF (saldoeq IS NULL) THEN '#13#10 +
        '        saldoeq = 0; '#13#10 +
        ' '#13#10 +
        '      IF (saldo > 0) THEN '#13#10 +
        '        ncu_begin_debit = saldo; '#13#10 +
        '      ELSE '#13#10 +
        '        ncu_begin_credit = 0 - saldo; '#13#10 +
        '      IF (saldocurr > 0) THEN '#13#10 +
        '        curr_begin_debit = saldocurr; '#13#10 +
        '      ELSE '#13#10 +
        '        curr_begin_credit = 0 - saldocurr; '#13#10 +
        '      IF (saldoeq > 0) THEN '#13#10 +
        '        eq_begin_debit = saldoeq; '#13#10 +
        '      ELSE '#13#10 +
        '         eq_begin_credit = 0 - saldoeq; '#13#10 +
        '    END '#13#10 +
        '    ELSE '#13#10 +
        '    BEGIN '#13#10 +
        '      SELECT '#13#10 +
        '        debitsaldo, '#13#10 +
        '        creditsaldo '#13#10 +
        '      FROM '#13#10 +
        '        ac_accountexsaldo_bal(:datebegin, :id, :fieldname, :companykey, :allholdingcompanies, :currkey) '#13#10 +
        '      INTO '#13#10 +
        '        :ncu_begin_debit, '#13#10 +
        '        :ncu_begin_credit; '#13#10 +
        '    END '#13#10 +
        ' '#13#10 +
        '    IF (allholdingcompanies = 0) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      IF (dontinmove = 1) THEN '#13#10 +
        '        SELECT '#13#10 +
        '          SUM(e.debitncu), '#13#10 +
        '          SUM(e.creditncu), '#13#10 +
        '          SUM(e.debitcurr), '#13#10 +
        '          SUM(e.creditcurr), '#13#10 +
        '          SUM(e.debiteq), '#13#10 +
        '          SUM(e.crediteq) '#13#10 +
        '        FROM '#13#10 +
        '          ac_entry e '#13#10 +
        '        WHERE '#13#10 +
        '          e.accountkey = :id '#13#10 +
        '          AND e.entrydate >= :datebegin '#13#10 +
        '          AND e.entrydate <= :dateend '#13#10 +
        '          AND e.companykey + 0 = :companykey '#13#10 +
        '          AND ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
        '          AND NOT EXISTS ( '#13#10 +
        '            SELECT '#13#10 +
        '              e_cm.id '#13#10 +
        '            FROM '#13#10 +
        '              ac_entry e_cm '#13#10 +
        '            WHERE '#13#10 +
        '              e_cm.recordkey = e.recordkey '#13#10 +
        '              AND e_cm.accountpart <> e.accountpart '#13#10 +
        '              AND e_cm.accountkey=e.accountkey '#13#10 +
        '              AND (e.debitncu=e_cm.creditncu '#13#10 +
        '                OR e.creditncu=e_cm.debitncu '#13#10 +
        '                OR e.debitcurr=e_cm.creditcurr '#13#10 +
        '                OR e.creditcurr=e_cm.debitcurr)) '#13#10 +
        '        INTO '#13#10 +
        '          :ncu_debit, :ncu_credit, :curr_debit, curr_credit, :eq_debit, eq_credit; '#13#10 +
        '      ELSE '#13#10 +
        '        SELECT '#13#10 +
        '          SUM(e.debitncu), '#13#10 +
        '          SUM(e.creditncu), '#13#10 +
        '          SUM(e.debitcurr), '#13#10 +
        '          SUM(e.creditcurr), '#13#10 +
        '          SUM(e.debiteq), '#13#10 +
        '          SUM(e.crediteq) '#13#10 +
        '        FROM '#13#10 +
        '          ac_entry e '#13#10 +
        '        WHERE '#13#10 +
        '          e.accountkey = :id '#13#10 +
        '          AND e.entrydate >= :datebegin '#13#10 +
        '          AND e.entrydate <= :dateend '#13#10 +
        '          AND e.companykey + 0 = :companykey '#13#10 +
        '          AND ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
        '        INTO '#13#10 +
        '          :ncu_debit, :ncu_credit, :curr_debit, curr_credit, :eq_debit, eq_credit; '#13#10 +
        '    END '#13#10 +
        '    ELSE '#13#10 +
        '    BEGIN '#13#10 +
        '      IF (dontinmove = 1) THEN '#13#10 +
        '        SELECT '#13#10 +
        '          SUM(e.debitncu), '#13#10 +
        '          SUM(e.creditncu), '#13#10 +
        '          SUM(e.debitcurr), '#13#10 +
        '          SUM(e.creditcurr), '#13#10 +
        '          SUM(e.debiteq), '#13#10 +
        '          SUM(e.crediteq) '#13#10 +
        '        FROM '#13#10 +
        '          ac_entry e '#13#10 +
        '        WHERE '#13#10 +
        '          e.accountkey = :id '#13#10 +
        '          AND e.entrydate >= :datebegin '#13#10 +
        '          AND e.entrydate <= :dateend '#13#10 +
        '          AND (e.companykey + 0 = :companykey '#13#10 +
        '            OR e.companykey + 0 IN ( '#13#10 +
        '              SELECT '#13#10 +
        '                h.companykey '#13#10 +
        '              FROM '#13#10 +
        '                gd_holding h '#13#10 +
        '              WHERE '#13#10 +
        '                h.holdingkey = :companykey)) '#13#10 +
        '          AND ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
        '          AND NOT EXISTS ( '#13#10 +
        '            SELECT '#13#10 +
        '              e_cm.id '#13#10 +
        '            FROM '#13#10 +
        '              ac_entry e_cm '#13#10 +
        '            WHERE '#13#10 +
        '              e_cm.recordkey = e.recordkey '#13#10 +
        '              AND e_cm.accountpart <> e.accountpart '#13#10 +
        '              AND e_cm.accountkey=e.accountkey '#13#10 +
        '              AND (e.debitncu=e_cm.creditncu '#13#10 +
        '                OR e.creditncu=e_cm.debitncu '#13#10 +
        '                OR e.debitcurr=e_cm.creditcurr '#13#10 +
        '                OR e.creditcurr=e_cm.debitcurr)) '#13#10 +
        '        INTO '#13#10 +
        '          :ncu_debit, :ncu_credit, :curr_debit, curr_credit, :eq_debit, :eq_credit; '#13#10 +
        '      ELSE '#13#10 +
        '        SELECT '#13#10 +
        '          SUM(e.debitncu), '#13#10 +
        '          SUM(e.creditncu), '#13#10 +
        '          SUM(e.debitcurr), '#13#10 +
        '          SUM(e.creditcurr), '#13#10 +
        '          SUM(e.debiteq), '#13#10 +
        '          SUM(e.crediteq) '#13#10 +
        '        FROM '#13#10 +
        '          ac_entry e '#13#10 +
        '        WHERE '#13#10 +
        '          e.accountkey = :id '#13#10 +
        '          AND e.entrydate >= :datebegin '#13#10 +
        '          AND e.entrydate <= :dateend '#13#10 +
        '          AND (e.companykey + 0 = :companykey '#13#10 +
        '            OR e.companykey + 0 IN ( '#13#10 +
        '              SELECT '#13#10 +
        '                h.companykey '#13#10 +
        '              FROM '#13#10 +
        '                gd_holding h '#13#10 +
        '              WHERE '#13#10 +
        '                h.holdingkey = :companykey)) '#13#10 +
        '          AND ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
        '        INTO '#13#10 +
        '          :ncu_debit, :ncu_credit, :curr_debit, curr_credit, :eq_debit, :eq_credit; '#13#10 +
        '    END '#13#10 +
        ' '#13#10 +
        '    IF (ncu_debit IS NULL) THEN '#13#10 +
        '      ncu_debit = 0; '#13#10 +
        '    IF (ncu_credit IS NULL) THEN '#13#10 +
        '      ncu_credit = 0; '#13#10 +
        '    IF (curr_debit IS NULL) THEN '#13#10 +
        '      curr_debit = 0; '#13#10 +
        '    IF (curr_credit IS NULL) THEN '#13#10 +
        '      curr_credit = 0; '#13#10 +
        '    IF (eq_debit IS NULL) THEN '#13#10 +
        '      eq_debit = 0; '#13#10 +
        '    IF (eq_credit IS NULL) THEN '#13#10 +
        '      eq_credit = 0; '#13#10 +
        ' '#13#10 +
        '    ncu_end_debit = 0; '#13#10 +
        '    ncu_end_credit = 0; '#13#10 +
        '    curr_end_debit = 0; '#13#10 +
        '    curr_end_credit = 0; '#13#10 +
        '    eq_end_debit = 0; '#13#10 +
        '    eq_end_credit = 0; '#13#10 +
        ' '#13#10 +
        '    IF ((activity <> ''B'') OR (fieldname IS NULL)) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      saldo = ncu_begin_debit - ncu_begin_credit + ncu_debit - ncu_credit; '#13#10 +
        '      IF (saldo > 0) THEN '#13#10 +
        '        ncu_end_debit = saldo; '#13#10 +
        '      ELSE '#13#10 +
        '        ncu_end_credit = 0 - saldo; '#13#10 +
        ' '#13#10 +
        '      saldocurr = curr_begin_debit - curr_begin_credit + curr_debit - curr_credit; '#13#10 +
        '      IF (saldocurr > 0) THEN '#13#10 +
        '        curr_end_debit = saldocurr; '#13#10 +
        '      ELSE '#13#10 +
        '        curr_end_credit = 0 - saldocurr; '#13#10 +
        ' '#13#10 +
        '      saldoeq = eq_begin_debit - eq_begin_credit + eq_debit - eq_credit; '#13#10 +
        '      IF (saldoeq > 0) THEN '#13#10 +
        '        eq_end_debit = saldoeq; '#13#10 +
        '      ELSE '#13#10 +
        '        eq_end_credit = 0 - saldoeq; '#13#10 +
        '    END '#13#10 +
        '    ELSE '#13#10 +
        '    BEGIN '#13#10 +
        '      IF ((ncu_begin_debit <> 0) OR (ncu_begin_credit <> 0) OR '#13#10 +
        '        (ncu_debit <> 0) OR (ncu_credit <> 0) OR '#13#10 +
        '        (curr_begin_debit <> 0) OR (curr_begin_credit <> 0) OR '#13#10 +
        '        (curr_debit <> 0) OR (curr_credit <> 0) OR '#13#10 +
        '        (eq_begin_debit <> 0) OR (eq_begin_credit <> 0) OR '#13#10 +
        '        (eq_debit <> 0) OR (eq_credit <> 0)) THEN '#13#10 +
        '      BEGIN '#13#10 +
        '        SELECT '#13#10 +
        '          debitsaldo, creditsaldo, '#13#10 +
        '          currdebitsaldo, currcreditsaldo, '#13#10 +
        '          eqdebitsaldo, eqcreditsaldo '#13#10 +
        '        FROM '#13#10 +
        '          ac_accountexsaldo_bal(:dateend + 1, :id, :fieldname, :companykey, :allholdingcompanies, :currkey) '#13#10 +
        '        INTO '#13#10 +
        '          :ncu_end_debit, :ncu_end_credit, :curr_end_debit, :curr_end_credit, :eq_end_debit, :eq_end_credit; '#13#10 +
        '      END '#13#10 +
        '    END '#13#10 +
        '    IF ((ncu_begin_debit <> 0) OR (ncu_begin_credit <> 0) OR '#13#10 +
        '      (ncu_debit <> 0) OR (ncu_credit <> 0) OR '#13#10 +
        '      (curr_begin_debit <> 0) OR (curr_begin_credit <> 0) OR '#13#10 +
        '      (curr_debit <> 0) OR (curr_credit <> 0) OR '#13#10 +
        '      (eq_begin_debit <> 0) OR (eq_begin_credit <> 0) OR '#13#10 +
        '      (eq_debit <> 0) OR (eq_credit <> 0)) THEN '#13#10 +
        '      SUSPEND; '#13#10 +
        '  END '#13#10 +
        'END';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (261, ''0000.0001.0000.0292'', ''13.02.2017'', ''Added extended analytics to account'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log(E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

end.
