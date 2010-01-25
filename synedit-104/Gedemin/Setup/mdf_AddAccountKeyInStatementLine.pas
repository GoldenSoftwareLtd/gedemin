unit mdf_AddAccountKeyInStatementLine;
//Добавление ссылки на ac_account в таблицу bn_bankstatementline

interface
uses
  sysutils, IBDatabase, gdModify;
  procedure AddAccountKeyInStatementLine(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL;

procedure AddAccountKeyInStatementLine(IBDB: TIBDatabase; Log: TModifyLog);
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
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$field_name = ''ACCOUNTKEY'' AND rdb$relation_name = ''BN_BANKSTATEMENTLINE''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE bn_bankstatementline ADD accountkey dforeignkey ';
        Log('BN_BANKSTATEMENTLINE: Добавление поля accountkey');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints ' +
        ' WHERE rdb$constraint_name = ''BN_FK_BSL_ACCOUNTKEY''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE bn_bankstatementline ADD CONSTRAINT BN_FK_BSL_ACCOUNTKEY ' +
          ' FOREIGN KEY (accountkey) REFERENCES ac_account(id) ' +
          ' ON UPDATE CASCADE ';
        Log('BN_BANKSTATEMENTLINE: Добавление внешнего ключа BN_FK_BSL_ACCOUNTKEY');
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
      end;
    end;
  finally
    ibsql.Free;
    FIBTransaction.Free;
  end;
end;

end.
