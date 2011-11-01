{Добавление полей listfield, extendedfields в таблицу at_relations}
unit mdf_ChangeAtRelations;

interface
uses
  sysutils, IBDatabase, gdModify;
  procedure ChangeAtRelations(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL;

procedure ChangeAtRelations(IBDB: TIBDatabase; Log: TModifyLog);
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
        ' WHERE rdb$field_name = ''LISTFIELD'' AND rdb$relation_name = ''AT_RELATIONS''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE at_relations ADD listfield dfieldname ';
        Log('AT_RELATIONS: Добавление поля listfield');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$field_name = ''EXTENDEDFIELDS'' AND rdb$relation_name = ''AT_RELATIONS''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE at_relations ADD extendedfields dtext254 ';
        Log('AT_RELATIONS: Добавление поля extendedfields');
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
