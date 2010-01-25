unit mdf_AlterTriggerGoodTax;

interface
uses
  sysutils, IBDatabase, gdModify;
  procedure AlterTriggerGoodTax(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL;

procedure AlterTriggerGoodTax(IBDB: TIBDatabase; Log: TModifyLog);
var
  FIBTransaction: TIBTransaction;
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  FIBTransaction := TIBTransaction.Create(nil);
  try
    FIBTransaction.DefaultDatabase := IBDB;
    ibsql.Transaction := FIBTransaction;
    try
      if FIBTransaction.InTransaction then
        FIBTransaction.Rollback;
      FIBTransaction.StartTransaction;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$triggers WHERE rdb$trigger_name = ''GD_BI_GOODTAX''';
      ibsql.ExecQuery;
      ibsql.ParamCheck := False;
      if ibsql.RecordCount > 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TRIGGER gd_bi_goodtax '#13#10 +
          ' BEFORE INSERT '#13#10 +
          ' POSITION 0 '#13#10 +
          ' AS '#13#10 +
          ' BEGIN '#13#10 +
          '   IF (NEW.rate IS NULL) THEN'#13#10 +
          '     SELECT rate FROM gd_tax '#13#10 +
          '     WHERE id = NEW.taxkey INTO NEW.rate; '#13#10 +
          '   IF (NEW.datetax IS NULL) THEN '#13#10 +
          '     NEW.datetax = ''NOW''; ' +
          ' END';
        Log('GD_GOODTAX: Изменение триггера gd_bi_goodtax');
        ibsql.ExecQuery;
      end
      else
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'CREATE TRIGGER gd_bi_goodtax FOR gd_goodtax '#13#10 +
          ' BEFORE INSERT '#13#10 +
          ' POSITION 0 '#13#10 +
          ' AS '#13#10 +
          ' BEGIN '#13#10 +
          '   IF (NEW.rate IS NULL) THEN'#13#10 +
          '     SELECT rate FROM gd_tax '#13#10 +
          '     WHERE id = NEW.taxkey INTO NEW.rate; '#13#10 +
          '   IF (NEW.datetax IS NULL) THEN '#13#10 +
          '     NEW.datetax = ''NOW''; ' +
          ' END';
        Log('GD_GOODTAX: Создание триггера gd_bi_goodtax');
        ibsql.ExecQuery;
      end;

      if FIBTransaction.InTransaction then
        FIBTransaction.Commit;
    except
      on E: Exception do
      begin
        if FIBTransaction.InTransaction then
          FIBTransaction.Rollback;
        Log(E.Message);
        raise;
      end;
    end;
  finally
    ibsql.Free;
    FIBTransaction.Free;
  end;
end;

end.
