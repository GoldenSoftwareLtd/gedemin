unit mdf_ChangeRUID;

interface
uses
  sysutils, IBDatabase, gdModify;
  procedure ChangeRUID(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL;

procedure ChangeRUID(IBDB: TIBDatabase; Log: TModifyLog);
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
      ibsql.SQL.Text := 'SELECT * FROM rdb$indices i ' +
        ' WHERE i.rdb$index_name = ''GD_X_RUID_XID''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'CREATE INDEX gd_x_ruid_xid ON gd_ruid(xid);';
        ibsql.ExecQuery;
        Log('GD_RUID: Добавление индекса на поле xid таблицы gd_ruid');
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      {!!!! для стандартных записей с идентификатором < 147000000 устанавливаем значение идентификатора базы = 17}
      ibsql.SQL.Text := 'SELECT * FROM gd_ruid WHERE dbid <> 17 and id < 147000000';
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'UPDATE gd_ruid SET dbid = 17 WHERE dbid <> 17 and id < 147000000';
        Log('GD_RUID: Коррекция идентификатора базы для стандартный записей');
        ibsql.ExecQuery;
      end;

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
