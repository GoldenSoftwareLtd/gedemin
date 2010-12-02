unit mdf_ModifyRecordTriggers;

interface

uses
  IBDatabase, gdModify;

procedure ModifyRecordTriggers(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;


procedure ModifyRecordTriggers(IBDB: TIBDatabase; Log: TModifyLog);
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
      with FIBSQL do
      try
        Transaction := FTransaction;
        ParamCheck := False;

        SQL.Text :=
          'DROP TRIGGER ac_bi_record ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE TRIGGER ac_bi_record FOR ac_record ' +
          '  BEFORE INSERT ' +
          '  POSITION 0 ' +
          'AS ' +
          'BEGIN ' +
          '  /* Если ключ не присвоен, присваиваем */ ' +
          '  IF (NEW.ID IS NULL) THEN ' +
          '    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); ' +
          ' ' +
          '  NEW.debitncu = 0; ' +
          '  NEW.debitcurr = 0; ' +
          '  NEW.creditncu = 0; ' +
          '  NEW.creditcurr = 0; ' +
          '  NEW.incorrect = 0; ' +
          'END ';
        ExecQuery;
        Close;



        SQL.Text :=
          'DROP TRIGGER ac_bu_record ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE TRIGGER ac_bu_record FOR ac_record ' +
          '  BEFORE UPDATE ' +
          '  POSITION 0 ' +
          'AS ' +
          'BEGIN ' +
          '  IF ((NEW.debitncu <> NEW.creditncu) OR (NEW.debitcurr <> NEW.creditcurr)) THEN ' +
          '    NEW.incorrect = 1; ' +
          '  ELSE ' +
          '    NEW.incorrect = 0; ' +
          ' ' +
          '  UPDATE ac_entry e ' +
          '    SET e.entrydate = NEW.recorddate ' +
          '    WHERE e.recordkey = NEW.id; ' +
          'END ';
        ExecQuery;
        Close;


        SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (68, ''0000.0001.0000.0096'', ''12.04.2005'', ''Fixed Some Errors'')';
        try
          ExecQuery;
        except
        end;  
        Close;

        FTransaction.Commit;
      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        Log('Ошибка: ' + E.Message);
      end;
    end;
  finally
    if FTransaction.InTransaction then
      FTransaction.Rollback;
    FTransaction.Free;
  end;

end;

end.
