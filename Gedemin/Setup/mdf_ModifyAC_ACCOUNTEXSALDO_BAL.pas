 unit mdf_ModifyAC_ACCOUNTEXSALDO_BAL;
 
  interface
 
  uses
    IBDatabase, gdModify;
 
  procedure ModifyAC_ACCOUNTEXSALDO_BAL(IBDB: TIBDatabase; Log: TModifyLog);
 
  implementation
 
  uses
    IBSQL, SysUtils;
 
  procedure ModifyAC_ACCOUNTEXSALDO_BAL(IBDB: TIBDatabase; Log: TModifyLog);
  var
    FTransaction: TIBTransaction;
    FIBSQL: TIBSQL;
  begin
    FTransaction := TIBTransaction.Create(nil);
    try
      FTransaction.DefaultDatabase := IBDB;
      FTransaction.StartTransaction;
      try
        FIBSQL := TIBSQL.Create(nil);
        try
          FIBSQL.Transaction := FTransaction;

          FIBSQL.SQL.Text :=
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
            '         main.'' || FIELDNAME || '', '#13#10 +
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
            '         main.'' || FIELDNAME || '', '#13#10 +
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
            '       :TEMPVAR, :SALDO, :SALDOCURR, :SALDOEQ, :CK '#13#10 +
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
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'CREATE OR ALTER TRIGGER ac_tc_record '#13#10 +
            '  ACTIVE '#13#10 +
            '  ON TRANSACTION COMMIT '#13#10 +
            '  POSITION 9000 '#13#10 +
            'AS '#13#10 +
            '  DECLARE VARIABLE S VARCHAR(255); '#13#10 +
            '  DECLARE VARIABLE ID INTEGER; '#13#10 +
            '  DECLARE VARIABLE STM VARCHAR(512); '#13#10 +
            '  DECLARE VARIABLE DebitNCU dcurrency; '#13#10 +
            '  DECLARE VARIABLE CreditNCU dcurrency; '#13#10 +
            'BEGIN '#13#10 +
            '  S = RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_INCORRECT''); '#13#10 +
            '  IF (:S IS NOT NULL) THEN '#13#10 +
            '  BEGIN '#13#10 +
            '    STM = '#13#10 +
            '      ''SELECT r.id, r.debitncu, r.creditncu '' || '#13#10 +
            '      ''FROM ac_record r LEFT JOIN ac_entry e '' || '#13#10 +
            '      ''  ON e.recordkey = r.id LEFT JOIN ac_account a ON a.id = e.accountkey '' || '#13#10 +
            '      ''WHERE (a.offbalance IS DISTINCT FROM 1) AND ''; '#13#10 +
            ' '#13#10 +
            '    IF (:S = ''TM'') THEN '#13#10 +
            '      STM = :STM || '' (r.incorrect = 1)''; '#13#10 +
            '    ELSE '#13#10 +
            '      STM = :STM || '' (r.id IN ('' || RIGHT(:S, CHAR_LENGTH(:S) - 1) || ''))''; '#13#10 +
            ' '#13#10 +
            '    FOR '#13#10 +
            '      EXECUTE STATEMENT (:STM) '#13#10 +
            '      INTO :ID, :DebitNCU, :CreditNCU '#13#10 +
            '    DO BEGIN '#13#10 +
            '      IF (:DebitNCU <> :CreditNCU) THEN '#13#10 +
            '        EXCEPTION ac_e_invalidentry ''Попытка сохранить некорректную проводку с ИД: '' || :ID; '#13#10 +
            '      ELSE '#13#10 +
            '        UPDATE ac_record SET incorrect = 0 WHERE id = :ID; '#13#10 +
            '    END '#13#10 +
            '  END '#13#10 +
            'END';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'CREATE OR ALTER TRIGGER gd_au_storage_data FOR gd_storage_data '#13#10 +
            '  ACTIVE '#13#10 +
            '  AFTER UPDATE '#13#10 +
            '  POSITION 0 '#13#10 +
            'AS '#13#10 +
            'BEGIN '#13#10 +
            '  IF ( '#13#10 +
            '    (OLD.data_type = ''F'') '#13#10 +
            '    AND '#13#10 +
            '    ( '#13#10 +
            '      (OLD.name IS DISTINCT FROM NEW.name) '#13#10 +
            '      OR '#13#10 +
            '      (OLD.parent IS DISTINCT FROM NEW.parent) '#13#10 +
            '    ) '#13#10 +
            '  ) THEN '#13#10 +
            '  BEGIN '#13#10 +
            '    IF (UPPER(OLD.name) IN (''DFM'', ''NEWFORM'', ''OPTIONS'', ''SUBTYPES'')) THEN '#13#10 +
            '    BEGIN '#13#10 +
            '      IF (EXISTS (SELECT * FROM gd_storage_data WHERE id = OLD.parent AND data_type = ''G'')) THEN '#13#10 +
            '        EXCEPTION gd_e_storage_data ''Can not change system folder '' || OLD.name; '#13#10 +
            '    END '#13#10 +
            ' '#13#10 +
            '    IF ( '#13#10 +
            '      EXISTS ( '#13#10 +
            '        SELECT * '#13#10 +
            '        FROM '#13#10 +
            '          gd_storage_data f '#13#10 +
            '          JOIN gd_storage_data p ON f.parent = p.id '#13#10 +
            '          JOIN gd_storage_data pp ON p.parent = pp.id '#13#10 +
            '        WHERE f.id = OLD.id AND UPPER(p.name) = ''DFM'' '#13#10 +
            '          AND pp.data_type = ''G'') '#13#10 +
            '    ) THEN '#13#10 +
            '      EXCEPTION gd_e_storage_data ''Can not change system folder '' || OLD.name; '#13#10 +
            '  END '#13#10 +
            'END ';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'CREATE OR ALTER TRIGGER gd_bd_storage_data FOR gd_storage_data '#13#10 +
            '  ACTIVE '#13#10 +
            '  BEFORE DELETE '#13#10 +
            '  POSITION 0 '#13#10 +
            'AS '#13#10 +
            'BEGIN '#13#10 +
            '  IF (UPPER(OLD.name) IN (''DFM'', ''NEWFORM'', ''OPTIONS'', ''SUBTYPES'')) THEN '#13#10 +
            '  BEGIN '#13#10 +
            '    IF (EXISTS (SELECT * FROM gd_storage_data WHERE id = OLD.parent AND data_type = ''G'')) THEN '#13#10 +
            '      EXCEPTION gd_e_storage_data ''Can not delete system folder '' || OLD.name; '#13#10 +
            '  END '#13#10 +
            ' '#13#10 +
            '  IF (OLD.data_type = ''F'') THEN '#13#10 +
            '  BEGIN '#13#10 +
            '    IF ( '#13#10 +
            '      EXISTS ( '#13#10 +
            '        SELECT * '#13#10 +
            '        FROM '#13#10 +
            '          gd_storage_data f '#13#10 +
            '          JOIN gd_storage_data p ON f.parent = p.id '#13#10 +
            '          JOIN gd_storage_data pp ON p.parent = pp.id '#13#10 +
            '          JOIN gd_storage_data v ON v.parent = f.id '#13#10 +
            '        WHERE f.id = OLD.id AND UPPER(p.name) = ''DFM'' '#13#10 +
            '          AND pp.data_type = ''G'') '#13#10 +
            '    ) THEN '#13#10 +
            '      EXCEPTION gd_e_storage_data ''System folder is not empty '' || OLD.name; '#13#10 +
            '  END '#13#10 +
            'END';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'UPDATE OR INSERT INTO fin_versioninfo ' +
            '  VALUES (204, ''0000.0001.0000.0235'', ''11.03.2014'', ''Issue 3301.'') ' +
            '  MATCHING (id)';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'UPDATE OR INSERT INTO fin_versioninfo ' +
            '  VALUES (205, ''0000.0001.0000.0236'', ''17.03.2014'', ''Issue 3330.'') ' +
            '  MATCHING (id)';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'UPDATE OR INSERT INTO fin_versioninfo ' +
            '  VALUES (206, ''0000.0001.0000.0237'', ''17.03.2014'', ''Issue 3330. #2.'') ' +
            '  MATCHING (id)';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'UPDATE OR INSERT INTO fin_versioninfo ' +
            '  VALUES (207, ''0000.0001.0000.0238'', ''17.03.2014'', ''Triggers for protection of system storage folders.'') ' +
            '  MATCHING (id)';
          FIBSQL.ExecQuery;
        finally
          FIBSQL.Free;
        end;

        FTransaction.Commit;
      except
        on E: Exception do
        begin
          FTransaction.Rollback;
          Log(E.Message);
        end;
      end;
    finally
      FTransaction.Free;
    end;
  end;  
 
  end.