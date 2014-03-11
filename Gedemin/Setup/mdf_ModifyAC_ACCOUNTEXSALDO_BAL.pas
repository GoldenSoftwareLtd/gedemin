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
    Log('Начато изменение AC_ACCOUNTEXSALDO_BAL');
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
            '   declare variable sqlstatement varchar(2048); '#13#10 +
            '   declare variable sqlattstatement1 varchar(1024); '#13#10 +
            '   declare variable sqlattstatement2 varchar(1024); '#13#10 +
            ' BEGIN '#13#10 +
            '   DEBITSALDO = 0; '#13#10 +
            '   CREDITSALDO = 0; '#13#10 +
            '   CURRDEBITSALDO = 0; '#13#10 +
            '   CURRCREDITSALDO = 0; '#13#10 +
            '   EQDEBITSALDO = 0; '#13#10 +
            '   EQCREDITSALDO = 0; '#13#10 +
            '   CLOSEDATE = CAST((CAST(''17.11.1858'' AS DATE) + GEN_ID(gd_g_entry_balance_date, 0)) AS DATE); '#13#10 +
            ' '#13#10 +
            '   IF (:ALLHOLDINGCOMPANIES = 1) THEN '#13#10 +
            '   BEGIN '#13#10 +
            '     sqlattstatement1 = '#13#10 +
            '        '' OR bal.companykey IN ( '#13#10 +
            '            SELECT '#13#10 +
            '              h.companykey '#13#10 +
            '            FROM '#13#10 +
            '              gd_holding h '#13#10 +
            '            WHERE '#13#10 +
            '              h.holdingkey = '' || CAST(:companykey AS VARCHAR(20)) || '')''; '#13#10 +
            '     sqlattstatement2 = '#13#10 +
            '        '' OR e.companykey IN ( '#13#10 +
            '            SELECT '#13#10 +
            '              h.companykey '#13#10 +
            '            FROM '#13#10 +
            '              gd_holding h '#13#10 +
            '            WHERE '#13#10 +
            '              h.holdingkey = '' || CAST(:companykey AS VARCHAR(20)) || '')''; '#13#10 +
            '   END '#13#10 +
            '   ELSE '#13#10 +
            '   BEGIN '#13#10 +
            '     sqlattstatement1 = ''''; '#13#10 +
            '     sqlattstatement2 = ''''; '#13#10 +
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
            '             AND (bal.companykey = '' || CAST(:companykey AS VARCHAR(20)) || :sqlattstatement1 || '') '#13#10 +
            '             AND ((0 = '' || CAST(:currkey AS VARCHAR(20)) || '') OR (bal.currkey = '' || CAST(:currkey AS VARCHAR(20)) || '')) '#13#10 +
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
            '           AND (e.companykey = '' || CAST(:companykey AS VARCHAR(20)) || :sqlattstatement2 || '') '#13#10 +
            '           AND ((0 = '' || CAST(:currkey AS VARCHAR(20)) || '') OR (e.currkey = '' || CAST(:currkey AS VARCHAR(20)) || '')) '#13#10 +
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
            '             AND (bal.companykey = '' || CAST(:companykey AS VARCHAR(20)) || :sqlattstatement1 || '') '#13#10 +
            '             AND ((0 = '' || CAST(:currkey AS VARCHAR(20)) || '') OR (bal.currkey = '' || CAST(:currkey AS VARCHAR(20)) || '')) '#13#10 +
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
            '           AND (e.companykey = '' || CAST(:companykey AS VARCHAR(20)) || :sqlattstatement2 || '') '#13#10 +
            '           AND ((0 = '' || CAST(:currkey AS VARCHAR(20)) || '') OR (e.currkey = '' || CAST(:currkey AS VARCHAR(20)) || '')) '#13#10 +
            ' '#13#10 +
            '       ) main '#13#10 +
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
            '     IF (SALDO IS NULL) THEN '#13#10 +
            '       SALDO = 0; '#13#10 +
            '     IF (SALDO > 0) THEN '#13#10 +
            '       DEBITSALDO = DEBITSALDO + SALDO; '#13#10 +
            '     ELSE '#13#10 +
            '       CREDITSALDO = CREDITSALDO - SALDO; '#13#10 +
            '     IF (SALDOCURR IS NULL) THEN '#13#10 +
            '        SALDOCURR = 0; '#13#10 +
            '     IF (SALDOCURR > 0) THEN '#13#10 +
            '       CURRDEBITSALDO = CURRDEBITSALDO + SALDOCURR; '#13#10 +
            '     ELSE '#13#10 +
            '       CURRCREDITSALDO = CURRCREDITSALDO - SALDOCURR; '#13#10 +
            '     IF (SALDOEQ IS NULL) THEN '#13#10 +
            '        SALDOEQ = 0; '#13#10 +
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
          FIBSQL.Close;

          FTransaction.Commit;
          Log('Изменение AC_ACCOUNTEXSALDO_BAL успешно завершено');

        finally
          FIBSQL.Free;
        end;
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