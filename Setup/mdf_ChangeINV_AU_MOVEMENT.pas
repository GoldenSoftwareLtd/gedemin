unit mdf_ChangeINV_AU_MOVEMENT;

interface
uses
  IBDatabase, gdModify;

  procedure ChangeINV_AU_MOVEMENT(IBDB: TIBDatabase; Log: TModifyLog);

implementation
  uses
  IBSQL, SysUtils;

procedure ChangeINV_AU_MOVEMENT(IBDB: TIBDatabase; Log: TModifyLog);
var
  FIBTransaction: TIBTransaction;
  IBSQL: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  FIBTransaction := TIBTransaction.Create(nil);
  try
    FIBTransaction.DefaultDatabase := IBDB;
    ibsql.Transaction := FIBTransaction;
    if FIBTransaction.InTransaction then
      FIBTransaction.Rollback;
    FIBTransaction.StartTransaction;
    try
      ibsql.ParamCheck := False;
      ibsql.SQL.Text :=  'ALTER TRIGGER INV_AU_MOVEMENT'#13#10 +
        ' ACTIVE AFTER UPDATE POSITION 0 '#13#10 +
        ' AS '#13#10 +
        '   DECLARE VARIABLE existscontaccard INTEGER; '#13#10 +
        ' BEGIN '#13#10 +
        '   /* если запись с остатком есть - изменяем ее, если нет - создаем */ '#13#10 +
        '   existscontaccard = 1; '#13#10 +
        '   IF (OLD.disabled = 0) THEN '#13#10 +
        '   BEGIN '#13#10 +
        '     IF (EXISTS( '#13#10 +
        '       SELECT BALANCE '#13#10 +
        '       FROM INV_BALANCE '#13#10 +
        '       WHERE CARDKEY = OLD.CARDKEY AND CONTACTKEY = OLD.CONTACTKEY)) '#13#10 +
        '     THEN BEGIN '#13#10 +
        '       UPDATE INV_BALANCE '#13#10 +
        '       SET '#13#10 +
        '         BALANCE = BALANCE - (OLD.DEBIT - OLD.CREDIT) '#13#10 +
        '       WHERE '#13#10 +
        '         CARDKEY = OLD.CARDKEY AND CONTACTKEY = OLD.CONTACTKEY; '#13#10 +
        '     END '#13#10 +
        '     ELSE '#13#10 +
        '       existscontaccard = 0; '#13#10 +
        '   END '#13#10 +
        '    '#13#10 +
        '   IF (NEW.disabled = 0) THEN '#13#10 +
        '   BEGIN '#13#10 +
        '     IF ( '#13#10 +
        '        (NEW.contactkey <> OLD.contactkey) AND '#13#10 +
        '        (NEW.cardkey = OLD.cardkey) AND '#13#10 +
        '        (NEW.debit = OLD.debit) AND '#13#10 +
        '        (NEW.credit = OLD.credit) AND '#13#10 +
        '        (OLD.disabled = 0) AND '#13#10 +
        '        (existscontaccard = 0) '#13#10 +
        '        ) '#13#10 +
        '     THEN '#13#10 +
        '       existscontaccard = 0; '#13#10 +
        '     ELSE '#13#10 +
        '     IF (EXISTS( '#13#10 +
        '         SELECT BALANCE '#13#10 +
        '         FROM INV_BALANCE '#13#10 +
        '         WHERE CARDKEY = NEW.CARDKEY AND CONTACTKEY = NEW.CONTACTKEY)) '#13#10 +
        '     THEN BEGIN '#13#10 +
        '       UPDATE INV_BALANCE '#13#10 +
        '       SET '#13#10 +
        '         BALANCE = BALANCE + (NEW.DEBIT - NEW.CREDIT) '#13#10 +
        '       WHERE '#13#10 +
        '         CARDKEY = NEW.CARDKEY AND CONTACTKEY = NEW.CONTACTKEY; '#13#10 +
        '     END ELSE BEGIN '#13#10 +
        '         INSERT INTO INV_BALANCE '#13#10 +
        '           (CARDKEY, CONTACTKEY, BALANCE) '#13#10 +
        '         VALUES '#13#10 +
        '           (NEW.CARDKEY, NEW.CONTACTKEY, NEW.DEBIT - NEW.CREDIT); '#13#10 +
        '     END '#13#10 +
        '   END '#13#10 +
        ' END; ';

        Log('INV_MOVEMENT: Изменение триггера INV_AU_MOVEMENT');
        ibsql.ExecQuery;

      if FIBTransaction.InTransaction then
        FIBTransaction.Commit;
    except
      on E: Exception do
      begin
        if FIBTransaction.InTransaction then
          FIBTransaction.Rollback;
        Log('Ошибка: ' + E.Message);
      end;
    end;
  finally
    ibsql.Free;
    FIBTransaction.Free;
  end;
end;

end.
