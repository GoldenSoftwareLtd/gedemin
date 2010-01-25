
unit mdf_CorrectInvTrigger;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit, mdf_dlgDefaultCardOfAccount_unit, Forms,
  Windows, Controls;

procedure CorrectInvTrigger(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript, classes;

procedure CorrectInvTrigger(IBDB: TIBDatabase; Log: TModifyLog);
var
  IBTr: TIBTransaction;
  q: TIBSQL;
begin
  Log('»зменение триггера дл€ inv_movement');
  IBTr := TIBTransaction.Create(nil);
  try
    IBTr.DefaultDatabase := IBDB;
    IBTr.StartTransaction;

    q := TIBSQL.Create(nil);
    q.Transaction := IBTr;
    q.ParamCheck := False;

    try
      try
        q.SQL.Text :=
          'ALTER TRIGGER inv_ai_movement '#13#10 +
          '  ACTIVE '#13#10 +
          '  AFTER INSERT '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE NEWBALANCE NUMERIC(10, 4); '#13#10 +
          'BEGIN '#13#10 +
          '  /* если запись с остатком есть - измен€ем ее, если нет - создаем */ '#13#10 +
          '  IF (EXISTS( '#13#10 +
          '    SELECT BALANCE '#13#10 +
          '    FROM INV_BALANCE '#13#10 +
          '    WHERE CARDKEY = NEW.CARDKEY AND CONTACTKEY = NEW.CONTACTKEY) '#13#10 +
          '  ) '#13#10 +
          '  THEN BEGIN '#13#10 +
          '    UPDATE INV_BALANCE '#13#10 +
          '    SET '#13#10 +
          '      BALANCE = BALANCE + (NEW.DEBIT - NEW.CREDIT) '#13#10 +
          '    WHERE '#13#10 +
          '      CARDKEY = NEW.CARDKEY AND CONTACTKEY = NEW.CONTACTKEY; '#13#10 +
          '  END ELSE BEGIN '#13#10 +
          '    INSERT INTO INV_BALANCE '#13#10 +
          '      (CARDKEY, CONTACTKEY, BALANCE) '#13#10 +
          '    VALUES '#13#10 +
          '      (NEW.CARDKEY, NEW.CONTACTKEY, NEW.DEBIT - NEW.CREDIT); '#13#10 +
          '  END '#13#10 +
          'END ';
        q.ExecQuery;
      except
        on E: Exception do
          Log('error:' +  E.Message);
      end;

      try
        q.SQL.Text :=
          'ALTER TRIGGER INV_AU_MOVEMENT '#13#10 +
          '  ACTIVE '#13#10 +
          '  AFTER UPDATE '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE existscontaccard INTEGER; '#13#10 +
          'BEGIN '#13#10 +
          '  /* если запись с остатком есть - измен€ем ее, если нет - создаем */ '#13#10 +
          '  existscontaccard = 1; '#13#10 +
          '  IF (OLD.disabled = 0) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    IF (EXISTS( '#13#10 +
          '      SELECT BALANCE '#13#10 +
          '      FROM INV_BALANCE '#13#10 +
          '      WHERE CARDKEY = OLD.CARDKEY AND CONTACTKEY = OLD.CONTACTKEY)) '#13#10 +
          '    THEN BEGIN '#13#10 +
          '      UPDATE INV_BALANCE '#13#10 +
          '      SET '#13#10 +
          '        BALANCE = BALANCE - (OLD.DEBIT - OLD.CREDIT) '#13#10 +
          '      WHERE '#13#10 +
          '        CARDKEY = OLD.CARDKEY AND CONTACTKEY = OLD.CONTACTKEY; '#13#10 +
          '    END '#13#10 +
          '    ELSE '#13#10 +
          '      existscontaccard = 0; '#13#10 +
          '  END '#13#10 +
          '   '#13#10 +
          '  IF (NEW.disabled = 0) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    IF ( '#13#10 +
          '       (NEW.contactkey <> OLD.contactkey) AND '#13#10 +
          '       (NEW.cardkey = OLD.cardkey) AND '#13#10 +
          '       (NEW.debit = OLD.debit) AND '#13#10 +
          '       (NEW.credit = OLD.credit) AND '#13#10 +
          '       (OLD.disabled = 0) AND '#13#10 +
          '       (existscontaccard = 0) '#13#10 +
          '       ) '#13#10 +
          '    THEN '#13#10 +
          '      existscontaccard = 0; '#13#10 +
          '    ELSE '#13#10 +
          '    IF (EXISTS( '#13#10 +
          '        SELECT BALANCE '#13#10 +
          '        FROM INV_BALANCE '#13#10 +
          '        WHERE CARDKEY = NEW.CARDKEY AND CONTACTKEY = NEW.CONTACTKEY)) '#13#10 +
          '    THEN BEGIN '#13#10 +
          '      UPDATE INV_BALANCE '#13#10 +
          '      SET '#13#10 +
          '        BALANCE = BALANCE + (NEW.DEBIT - NEW.CREDIT) '#13#10 +
          '      WHERE '#13#10 +
          '        CARDKEY = NEW.CARDKEY AND CONTACTKEY = NEW.CONTACTKEY; '#13#10 +
          '    END ELSE BEGIN '#13#10 +
          '        INSERT INTO INV_BALANCE '#13#10 +
          '          (CARDKEY, CONTACTKEY, BALANCE) '#13#10 +
          '        VALUES '#13#10 +
          '          (NEW.CARDKEY, NEW.CONTACTKEY, NEW.DEBIT - NEW.CREDIT); '#13#10 +
          '    END '#13#10 +
          '  END '#13#10 +
          'END ';
        q.ExecQuery;
      except
        on E: Exception do
          Log('error:' +  E.Message);
      end;

      AddFinVersion('0000.0001.0000.0108', '¬озвращены изменени€ триггеров - параметр ROWCOUNT - возрващал неверное значение', '09.11.2006', IBTr);

      IBTr.Commit;
    finally
      q.Free;
      IBTr.Free;
    end;

  except
    on E: Exception do
      Log('error:' +  E.Message);
  end;

end;

end.
