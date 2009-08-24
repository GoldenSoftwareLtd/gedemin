unit mdf_ModifyACBALANCEENTRY;

interface

uses
  IBDatabase, gdModify;

procedure ModifyAccBalanceEntry(IBDB: TIBDatabase; Log: TModifyLog);


implementation

uses
  IBSQL, SysUtils;

procedure ModifyAccBalanceEntry(IBDB: TIBDatabase; Log: TModifyLog);
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
        FIBSQL.ParamCheck := False;        
        FIBSQL.SQL.Text :=
          'ALTER PROCEDURE AC_P_BALANCEENTRY( '#13#10 +
          '    RECORDKEY INTEGER) '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE debitncu NUMERIC(15, 4); '#13#10 +
          '  DECLARE VARIABLE debitcurr NUMERIC(15, 4); '#13#10 +
          '  DECLARE VARIABLE creditncu NUMERIC(15, 4); '#13#10 +
          '  DECLARE VARIABLE creditcurr NUMERIC(15, 4); '#13#10 +
          '  DECLARE VARIABLE difncu NUMERIC(15, 4); '#13#10 +
          '  DECLARE VARIABLE difcurr NUMERIC(15, 4); '#13#10 +
          '  DECLARE VARIABLE trrecordkey INTEGER; '#13#10 +
          '  DECLARE VARIABLE emptycredit INTEGER; '#13#10 +
          '  DECLARE VARIABLE emptydebit INTEGER; '#13#10 +
          '  DECLARE VARIABLE documenttypekey INTEGER; '#13#10 +
          'BEGIN '#13#10 +
          '  SELECT debitncu, debitcurr, creditncu, creditcurr, trrecordkey, documenttypekey '#13#10 +
          '  FROM ac_record r LEFT JOIN gd_document doc ON r.documentkey = doc.id '#13#10 +
          '  WHERE r.id = :recordkey '#13#10 +
          '  INTO :debitncu, :debitcurr, :creditncu, :creditcurr, :trrecordkey, :documenttypekey; '#13#10 + 
          ' '#13#10 + 
          '  IF ((:debitncu <> :creditncu) OR (:debitcurr <> :creditcurr)) THEN '#13#10 + 
          '  BEGIN '#13#10 + 
          '    SELECT COUNT(*) FROM '#13#10 + 
          '      ac_trentry e '#13#10 + 
          '    WHERE '#13#10 + 
          '      e.trrecordkey = :trrecordkey  '#13#10 + 
          '      AND e.accountpart = ''D'' '#13#10 +
          '      AND e.functionkey IS NULL '#13#10 +
          '    INTO :emptydebit; '#13#10 +
          ' '#13#10 +
          '    IF (emptydebit IS NULL) THEN '#13#10 +
          '      emptydebit = 0; '#13#10 +
          ' '#13#10 +
          '    SELECT COUNT(*) FROM '#13#10 +
          '      ac_trentry e '#13#10 +
          '    WHERE '#13#10 +
          '      e.trrecordkey = :trrecordkey '#13#10 +
          '      AND e.accountpart = ''C'' '#13#10 +
          '      AND e.functionkey IS NULL '#13#10 +
          '    INTO :emptycredit; '#13#10 +
          ' '#13#10 +
          '    IF (emptycredit IS NULL) THEN '#13#10 +
          '      emptycredit = 0; '#13#10 +
          ' '#13#10 +
          '    IF ((emptydebit > 0) OR (emptycredit > 0)) THEN '#13#10 +
          '    BEGIN '#13#10 +
          '      difncu = :debitncu - :creditncu; '#13#10 +
          '      difcurr = :debitcurr - :creditcurr; '#13#10 +
          '      IF (emptydebit > 0 AND emptycredit > 0) THEN '#13#10 +
          '      BEGIN '#13#10 +
          '        IF (difncu > 0) THEN '#13#10 +
          '          UPDATE ac_entry SET creditncu = creditncu + :difncu '#13#10 +
          '          WHERE recordkey = :recordkey AND '#13#10 +
          '            accountkey = '#13#10 +
          '            (SELECT MAX(accountkey + 0) FROM ac_trentry e '#13#10 +
          '             WHERE e.trrecordkey = :trrecordkey '#13#10 +
          '                   AND e.accountpart = ''C'' '#13#10 +
          '                   AND e.functionkey IS NULL); '#13#10 +
          '        ELSE '#13#10 +
          '          IF (difncu < 0) THEN '#13#10 +
          '            UPDATE ac_entry SET debitncu = debitncu - :difncu '#13#10 +
          '            WHERE recordkey = :recordkey AND '#13#10 +
          '                  accountkey = '#13#10 +
          '                  (SELECT MAX(accountkey + 0) FROM ac_trentry e '#13#10 +
          '                  WHERE e.trrecordkey = :trrecordkey '#13#10 +
          '                        AND e.accountpart = ''D'' '#13#10 +
          '                        AND e.functionkey IS NULL); '#13#10 +
          ' '#13#10 +
          '        IF (difcurr > 0) THEN '#13#10 +
          '          UPDATE ac_entry SET creditcurr = creditcurr + :difcurr '#13#10 +
          '          WHERE recordkey = :recordkey AND '#13#10 +
          '            accountkey = '#13#10 +
          '            (SELECT MAX(accountkey + 0) FROM ac_trentry e '#13#10 +
          '             WHERE e.trrecordkey = :trrecordkey '#13#10 +
          '                   AND e.accountpart = ''C'' '#13#10 +
          '                   AND e.functionkey IS NULL); '#13#10 +
          '        ELSE '#13#10 +
          '          IF (difcurr < 0) THEN '#13#10 +
          '            UPDATE ac_entry SET debitcurr = debitcurr - :difcurr '#13#10 +
          '            WHERE recordkey = :recordkey AND '#13#10 +
          '                  accountkey = '#13#10 +
          '                  (SELECT MAX(accountkey + 0) FROM ac_trentry e '#13#10 +
          '                  WHERE e.trrecordkey = :trrecordkey '#13#10 +
          '                        AND e.accountpart = ''D'' '#13#10 +
          '                        AND e.functionkey IS NULL); '#13#10 +
          ' '#13#10 +
          '      END '#13#10 +
          '      ELSE '#13#10 +
          '      BEGIN '#13#10 +
          '        IF (emptydebit > 0) THEN '#13#10 +
          '        BEGIN '#13#10 +
          '          UPDATE ac_entry SET debitncu = debitncu - :difncu '#13#10 +
          '          WHERE recordkey = :recordkey AND '#13#10 +
          '            accountkey = '#13#10 +
          '            (SELECT MAX(accountkey + 0) FROM ac_trentry e '#13#10 +
          '             WHERE e.trrecordkey = :trrecordkey '#13#10 +
          '                   AND e.accountpart = ''D'' '#13#10 +
          '                   AND e.functionkey IS NULL); '#13#10 +
          '          UPDATE ac_entry SET debitcurr = debitcurr - :difcurr '#13#10 +
          '          WHERE recordkey = :recordkey AND '#13#10 +
          '            accountkey = '#13#10 +
          '            (SELECT MAX(accountkey + 0) FROM ac_trentry e '#13#10 +
          '             WHERE e.trrecordkey = :trrecordkey '#13#10 +
          '                   AND e.accountpart = ''D'' '#13#10 +
          '                   AND e.functionkey IS NULL); '#13#10 +
          '                    '#13#10 +
          '        END '#13#10 +
          '        ELSE '#13#10 +
          '        BEGIN '#13#10 +
          '          UPDATE ac_entry SET creditncu = creditncu + :difncu '#13#10 +
          '          WHERE recordkey = :recordkey AND '#13#10 +
          '            accountkey = '#13#10 +
          '            (SELECT MAX(accountkey + 0) FROM ac_trentry e '#13#10 +
          '             WHERE e.trrecordkey = :trrecordkey '#13#10 +
          '                   AND e.accountpart = ''C'' '#13#10 +
          '                   AND e.functionkey IS NULL); '#13#10 +
          '          UPDATE ac_entry SET creditcurr = creditcurr + :difcurr '#13#10 +
          '          WHERE recordkey = :recordkey AND '#13#10 +
          '            accountkey = '#13#10 +
          '            (SELECT MAX(accountkey + 0) FROM ac_trentry e '#13#10 +
          '             WHERE e.trrecordkey = :trrecordkey '#13#10 +
          '                   AND e.accountpart = ''C'' '#13#10 +
          '                   AND e.functionkey IS NULL); '#13#10 +
          ' '#13#10 +
          '        END '#13#10 +
          '      END '#13#10 +
          '    END '#13#10 +
          '  END '#13#10 +
          'END ';
        FIBSQL.ExecQuery;
        Log('Обновление процедуры корректировки баланса проводки завершено');

      finally
        FIBSQL.Free;
      end;
      if FTransaction.InTransaction then
        FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка при обновлении процедуры построения оборотной ведомости прошло успешно.' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;


end.
