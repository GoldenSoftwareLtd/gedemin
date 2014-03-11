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
            'UPDATE OR INSERT INTO fin_versioninfo ' +
            '  VALUES (204, ''0000.0001.0000.0235'', ''11.03.2014'', ''Issue 3301.'') ' +
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