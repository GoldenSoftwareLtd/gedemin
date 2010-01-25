unit mdf_AddEntryDate;

interface

uses
  IBDatabase, gdModify;

procedure AddAccountEntryDate(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure AddAccountEntryDate(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  Log('Добавление даты проводки в AC_ENTRY');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        try
          FIBSQL.SQL.Text := 'SELECT entrydate FROM ac_entry';
          FIBSQL.Prepare;
        except
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'ALTER TABLE ac_entry ADD entrydate DDATE';
          try
            FIBSQL.ExecQuery;
          except
          end;
          FIBSQL.Close;
          FTransaction.Commit;
          FTransaction.StartTransaction;
          FIBSQL.ParamCheck := False;
          FIBSQL.SQL.Text :=
            'CREATE TRIGGER AC_BI_ENTRY_ENTRYDATE FOR AC_ENTRY '#13#10 +
            'ACTIVE BEFORE INSERT POSITION 1 '#13#10 +
            'AS '#13#10 +
            'BEGIN '#13#10 +
            '  /* Trigger text */ '#13#10 +
            '  SELECT recorddate FROM ac_record '#13#10 +
            '  WHERE id = NEW.recordkey '#13#10 +
            '  INTO NEW.entrydate; '#13#10 +
            'END ';
          try
            FIBSQL.ExecQuery;
          except
          end;
          FIBSQL.Close;

          FIBSQL.SQL.Text :=
            'ALTER TRIGGER AC_AU_ENTRY '#13#10 +
            'ACTIVE AFTER UPDATE POSITION 0 '#13#10 +
            'AS '#13#10 +
            'BEGIN '#13#10 +
            '  IF ((OLD.debitncu <> NEW.debitncu) or (OLD.creditncu <> NEW.creditncu) or '#13#10 +
            '     (OLD.debitcurr <> NEW.debitcurr) or (OLD.creditcurr <> NEW.creditcurr)) '#13#10 +
            '  THEN '#13#10 +
            '    UPDATE ac_record SET debitncu = debitncu - OLD.debitncu + NEW.debitncu, '#13#10 +
            '      creditncu = creditncu - OLD.creditncu + NEW.creditncu, '#13#10 +
            '      debitcurr = debitcurr - OLD.debitcurr + NEW.debitcurr, '#13#10 +
            '      creditcurr = creditcurr - OLD.creditcurr + NEW.creditcurr '#13#10 +
            '    WHERE '#13#10 +
            '      id = OLD.recordkey; '#13#10 +
            'END';
          FIBSQL.ExecQuery;

          FTransaction.Commit;
          FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'ALTER TRIGGER AC_BU_RECORD '#13#10 +
            'ACTIVE BEFORE UPDATE POSITION 0 '#13#10 +
            'AS '#13#10 +
            'BEGIN '#13#10 +
            ' '#13#10 +
            '  IF ((NEW.debitncu <> NEW.creditncu) OR (NEW.debitcurr <> NEW.creditcurr)) THEN '#13#10 +
            '    NEW.incorrect = 1; '#13#10 +
            '  ELSE '#13#10 +
            '    NEW.incorrect = 0; '#13#10 +
            ' '#13#10 +
            '  UPDATE ac_entry e SET e.entrydate = NEW.recorddate WHERE e.recordkey = NEW.id; '#13#10 +
            ' '#13#10 +
            'END ';
          try
            FIBSQL.ExecQuery;
          except
          end;

          FTransaction.Commit;
          FTransaction.StartTransaction;

          FIBSQL.SQL.Text := 'UPDATE ac_record SET id = id';
          FIBSQL.ExecQuery;
          FIBSQL.Close;
          FTransaction.Commit;
          Log('Добавление даты проводки в AC_ENTRY - успешно завершено ');
        end;
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
