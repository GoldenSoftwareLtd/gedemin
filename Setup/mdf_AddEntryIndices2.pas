unit mdf_AddEntryIndices2;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit;

procedure AddEntryIndices2(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript;

const
  Index: TmdfIndex = (RelationName:'AC_ENTRY'; IndexName:'AC_ENTRY_RECKEY_ACKEY';
    Columns: 'RECORDKEY, ACCOUNTKEY'; Unique: False; Sort: stAsc);

  SP: TmdfStoredProcedure = (ProcedureName: 'AC_GETSIMPLEENTRY';
    Description: '(ENTRYKEY INTEGER,'#13#10 +
      '    ACORRACCOUNTKEY INTEGER)'#13#10 +
      'RETURNS ('#13#10 +
      '    ID INTEGER,'#13#10 +
      '    DEBIT NUMERIC(15,4),'#13#10 +
      '    CREDIT NUMERIC(15,4),'#13#10 +
      '    DEBITCURR NUMERIC(15,4),'#13#10 +
      '    CREDITCURR NUMERIC(15,4))'#13#10 +
      'AS'#13#10 +
      'BEGIN'#13#10 +
      '  SELECT'#13#10 +
      '    e.id,'#13#10 +
      '    e.debitncu,'#13#10 +
      '    e.creditncu,'#13#10 +
      '    e.creditcurr,'#13#10 +
      '    e.debitcurr'#13#10 +
      '  FROM'#13#10 +
      '    ac_entry e'#13#10 +
      '    LEFT JOIN ac_entry corr_e on e.recordkey = corr_e.recordkey and'#13#10 +
      '      e.accountpart <> corr_e.accountpart'#13#10 +
      '  WHERE'#13#10 +
      '    e.id = :entrykey AND'#13#10 +
      '    corr_e.accountkey = :acorraccountkey AND '#13#10 +
      '  (SELECT COUNT(*) FROM ac_entry e1 WHERE '#13#10 +
      '  e1.recordkey = e.recordkey AND e1.accountpart <> e.accountpart) = 1 '#13#10 +
      '  INTO :ID,'#13#10 +
      '     :DEBIT,'#13#10 +
      '     :CREDIT,'#13#10 +
      '     :DEBITCURR,'#13#10 +
      '     :CREDITCURR;'#13#10 +
      '  IF (ID IS NULL) THEN'#13#10 +
      '  BEGIN'#13#10 +
      '    SELECT'#13#10 +
      '      e.id,'#13#10 +
      '      corr_e.creditncu,'#13#10 +
      '      corr_e.debitncu,'#13#10 +
      '      corr_e.creditcurr,'#13#10 +
      '      corr_e.debitcurr'#13#10 +
      '    FROM'#13#10 +
      '      ac_entry e'#13#10 +
      '      LEFT JOIN ac_entry corr_e ON e.recordkey = corr_e.recordkey AND'#13#10 +
      '        e.accountpart <> corr_e.accountpart'#13#10 +
      '    WHERE'#13#10 +
      '      e.id = :entrykey AND'#13#10 +
      '      corr_e.accountkey = :acorraccountkey AND'#13#10 +
      '(SELECT COUNT(*) FROM ac_entry e1 WHERE '#13#10 +
      '  e1.recordkey = e.recordkey AND e1.accountpart = e.accountpart) = 1 '#13#10 +
      '    INTO :ID,'#13#10 +
      '       :DEBIT,'#13#10 +
      '       :CREDIT,'#13#10 +
      '       :DEBITCURR,'#13#10 +
      '       :CREDITCURR;'#13#10 +
      '   END'#13#10 +
      '  SUSPEND;'#13#10 +
      'END');

   AC_LEDGER_SALDO: TmdfStoredProcedure = (
       ProcedureName: 'AC_LEDGER_SALDO';
       Description:'(ABEGINENTRYDATE DATE,'#13#10 +
          '    AENDENTRYDATE DATE,'#13#10 +
          '    ACCOUNTKEY INTEGER,'#13#10 +
          '    INCSUBACCOUNTS SMALLINT,'#13#10 +
          '    COMPANYKEY INTEGER,'#13#10 +
          '    INGROUP INTEGER)'#13#10 +
          'RETURNS ('#13#10 +
          '    ENTRYDATE DATE,'#13#10 +
          '    DEBITNCUBEGIN NUMERIC(15,4),'#13#10 +
          '    CREDITNCUBEGIN NUMERIC(15,4),'#13#10 +
          '    DEBITNCUEND NUMERIC(15,4),'#13#10 +
          '    CREDITNCUEND NUMERIC(15,4),'#13#10 +
          '    DEBITCURRBEGIN NUMERIC(15,4),'#13#10 +
          '    CREDITCURRBEGIN NUMERIC(15,4),'#13#10 +
          '    DEBITCURREND NUMERIC(15,4),'#13#10 +
          '    CREDITCURREND NUMERIC(15,4))'#13#10 +
          'AS'#13#10 +
          'DECLARE VARIABLE O NUMERIC(18,4);'#13#10 +
          'DECLARE VARIABLE SALDOBEGIN NUMERIC(18,4);'#13#10 +
          'DECLARE VARIABLE SALDOEND NUMERIC(18,4);'#13#10 +
          'DECLARE VARIABLE OCURR NUMERIC(18,4);'#13#10 +
          'DECLARE VARIABLE SALDOBEGINCURR NUMERIC(18,4);'#13#10 +
          'DECLARE VARIABLE SALDOENDCURR NUMERIC(18,4);'#13#10 +
          'BEGIN'#13#10 +
          '  SELECT'#13#10 +
          '    IIF(NOT SUM(e1.debitncu - e1.creditncu) IS NULL, SUM(e1.debitncu - e1.creditncu),  0),'#13#10 +
          '    IIF(NOT SUM(e1.debitcurr - e1.creditcurr) IS NULL, SUM(e1.debitcurr - e1.creditcurr), 0)'#13#10 +
          '  FROM'#13#10 +
          '    ac_entry e1'#13#10 +
          '    JOIN ac_record r1 ON r1.id = e1.recordkey'#13#10 +
          '  WHERE'#13#10 +
          '    e1.entrydate < :abeginentrydate AND'#13#10 +
          '    e1.accountkey IN ('#13#10 +
          '      SELECT'#13#10 +
          '        a1.id'#13#10 +
          '      FROM'#13#10 +
          '        ac_account a'#13#10 +
          '        JOIN ac_account a1 ON (a1.lb >= a.lb AND a1.rb <= a.rb)'#13#10 +
          '      WHERE'#13#10 +
          '        a.id = :accountkey AND'#13#10 +
          '        (:incsubaccounts = 1 OR (:incsubaccounts = 0 AND'#13#10 +
          '        a1.lb = a.lb AND a1.rb = a.rb))) AND'#13#10 +
          '    (r1.companykey = :companykey OR'#13#10 +
          '    r1.companykey IN ('#13#10 +
          '      SELECT'#13#10 +
          '        h.companykey'#13#10 +
          '      FROM'#13#10 +
          '        gd_holding h'#13#10 +
          '      WHERE'#13#10 +
          '        h.holdingkey = :companykey)) AND'#13#10 +
          '    G_SEC_TEST(r1.aview, :ingroup) <> 0'#13#10 +
          '  INTO :saldobegin,'#13#10 +
          '       :saldobegincurr;'#13#10 +
          '  FOR'#13#10 +
          '    SELECT'#13#10 +
          '      e.entrydate,'#13#10 +
          '      SUM(e.debitncu - e.creditncu),'#13#10 +
          '      SUM(e.debitcurr - e.creditcurr)'#13#10 +
          '    FROM'#13#10 +
          '      ac_entry e'#13#10 +
          '      JOIN ac_record r ON r.id = e.recordkey'#13#10 +
          '    WHERE'#13#10 +
          '    e.accountkey IN ('#13#10 +
          '      SELECT'#13#10 +
          '        a1.id'#13#10 +
          '      FROM'#13#10 +
          '        ac_account a'#13#10 +
          '        JOIN ac_account a1 ON (a1.lb >= a.lb AND a1.rb <= a.rb)'#13#10 +
          '      WHERE'#13#10 +
          '        a.id = :accountkey AND'#13#10 +
          '        (:incsubaccounts = 1 OR (:incsubaccounts = 0 AND'#13#10 +
          '        a1.lb = a.lb AND a1.rb = a.rb))) AND'#13#10 +
          '      (r.companykey = :companykey OR r.companykey IN ('#13#10 +
          '        SELECT'#13#10 +
          '          h.companykey'#13#10 +
          '        FROM'#13#10 +
          '          gd_holding h'#13#10 +
          '        WHERE'#13#10 +
          '          h.holdingkey = :companykey)) AND'#13#10 +
          '      G_SEC_TEST(r.aview, :ingroup) <> 0 AND'#13#10 +
          '      e.entrydate <= :aendentrydate AND              '#13#10 +
          '      e.entrydate >= :abeginentrydate'#13#10 +
          '    group by e.entrydate'#13#10 +
          '    INTO :ENTRYDATE,'#13#10 +
          '         :O,'#13#10 +
          '         :OCURR'#13#10 +
          '  DO'#13#10 +
          '  BEGIN'#13#10 +
          '    DEBITNCUBEGIN = 0;'#13#10 +
          '    CREDITNCUBEGIN = 0;'#13#10 +
          '    DEBITNCUEND = 0;'#13#10 +
          '    CREDITNCUEND = 0;'#13#10 +
          '    DEBITCURRBEGIN = 0;'#13#10 +
          '    CREDITCURRBEGIN = 0;'#13#10 +
          '    DEBITCURREND = 0;'#13#10 +
          '    CREDITCURREND = 0;'#13#10 +
          '    SALDOEND = :SALDOBEGIN + :O;'#13#10 +
          '    if (SALDOBEGIN > 0) then'#13#10 +
          '      DEBITNCUBEGIN = :SALDOBEGIN;'#13#10 +
          '    else'#13#10 +
          '      CREDITNCUBEGIN =  - :SALDOBEGIN;'#13#10 +
          '    if (SALDOEND > 0) then'#13#10 +
          '      DEBITNCUEND = :SALDOEND;'#13#10 +
          '    else'#13#10 +
          '      CREDITNCUEND =  - :SALDOEND;'#13#10 +
          '    SALDOENDCURR = :SALDOBEGINCURR + :OCURR;'#13#10 +
          '    if (SALDOBEGINCURR > 0) then'#13#10 +
          '      DEBITCURRBEGIN = :SALDOBEGINCURR;'#13#10 +
          '    else'#13#10 +
          '      CREDITCURRBEGIN =  - :SALDOBEGINCURR;'#13#10 +
          '    if (SALDOENDCURR > 0) then'#13#10 +
          '      DEBITCURREND = :SALDOENDCURR;'#13#10 +
          '    else'#13#10 +
          '      CREDITCURREND =  - :SALDOENDCURR;'#13#10 +
          '    SUSPEND;'#13#10 +
          '    SALDOBEGIN = :SALDOEND;'#13#10 +
          '    SALDOBEGINCURR = :SALDOENDCURR;'#13#10 +
          '  END'#13#10 +
          'END');

procedure AddEntryIndices2(IBDB: TIBDatabase; Log: TModifyLog);
begin
  if not IndexExist(Index, IBDB) then
  begin
    Log(Format('Добавление индекса %s', [Index.IndexName]));
    try
      AddIndex(Index, IBDB);
      Log('Добавление прошло успешно');
    except
      on E: Exception do
        Log(Format('Ошибка при добавлении индекса %s', [E.Message]));
    end;
  end;
  Log(Format('Изменение процедуры %s', [Sp.ProcedureName]));
  try
    AlterProcedure(SP, IBDB);
  except
    on E: Exception do
      Log(Format('Ошибка при изменении процедуры %s', [E.Message]));
  end;
  if not ProcedureExist(AC_LEDGER_SALDO, IBDB) then
  begin
    Log(Format('Добавление процедуры %s', [AC_LEDGER_SALDO.ProcedureName]));
    try
      CreateProcedure(AC_LEDGER_SALDO, IBDB);
    except
      on E: Exception do
        Log(Format('Ошибка при добавлении процедуры %s', [E.Message]));
    end;
  end else
  begin
    Log(Format('Изменение процедуры %s', [AC_LEDGER_SALDO.ProcedureName]));
    try
      AlterProcedure(AC_LEDGER_SALDO, IBDB);
    except
      on E: Exception do
        Log(Format('Ошибка при изменении процедуры %s', [E.Message]));
    end;
  end;
end;

end.
