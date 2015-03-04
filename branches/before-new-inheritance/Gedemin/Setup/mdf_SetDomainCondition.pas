unit mdf_SetDomainCondition;

interface
uses
  IBSQL, sysutils, IBDatabase, gdModify;

procedure SetDomainCondition(IBDB: TIBDatabase; Log: TModifyLog);

implementation

procedure SetDomainCondition(IBDB: TIBDatabase; Log: TModifyLog);
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
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$field_name = ''REFCONDITION'' AND rdb$relation_name = ''AT_FIELDS''' +
        ' AND rdb$field_source = ''DTEXT255''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE at_fields ALTER refcondition TYPE DTEXT255 ';
        Log('AT_FIELDS: Увеличение длины поля refcondition');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$field_name = ''SETCONDITION'' AND rdb$relation_name = ''AT_FIELDS''' +
        ' AND rdb$field_source = ''DTEXT255''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE at_fields ALTER setcondition TYPE DTEXT255 ';
        Log('AT_FIELDS: Увеличение длины поля setcondition');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
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
 