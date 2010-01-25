unit mdf_AddRateInStatement;

interface
uses
  sysutils, IBDatabase, gdModify;
  procedure AddRateInStatement(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL;

procedure AddRateInStatement(IBDB: TIBDatabase; Log: TModifyLog);
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

      ibsql.SQL.Text := 'SELECT * FROM rdb$fields WHERE rdb$field_name = ''DCURRENCY''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQl.Text := 'CREATE DOMAIN dcurrency AS DECIMAL(15, 10)';
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$field_name = ''RATE'' AND rdb$relation_name = ''BN_BANKSTATEMENT'' AND rdb$field_source = ''DCURRRATE''';
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE bn_bankstatement DROP rate ';
        Log('BN_BANKSTATEMENT: Удаление поля rate с доменом dcurrrate');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$field_name = ''RATE'' AND rdb$relation_name = ''BN_BANKSTATEMENT''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE bn_bankstatement ADD rate dcurrency ';
        Log('BN_BANKSTATEMENT: Добавление поля rate');
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
