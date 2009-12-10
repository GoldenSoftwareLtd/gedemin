{Добавляет поля в gd_documenttype:
12.05.2003 Julie поле IsCommon}
unit mdf_AddFieldDocumentType;

interface
uses
  sysutils, IBDatabase, gdModify;
  procedure AddFieldDocumentType(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL;

procedure AddFieldDocumentType(IBDB: TIBDatabase; Log: TModifyLog);
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
        ' WHERE rdb$field_name = ''ISCOMMON'' AND rdb$relation_name = ''GD_DOCUMENTTYPE''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE gd_documenttype ADD iscommon dboolean DEFAULT 0 ';
        Log('GD_DOCUMENTTYPE: Добавление поля iscommon');
        ibsql.ExecQuery;

        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;

        ibsql.Close;
        ibsql.SQL.Text := 'UPDATE gd_documenttype SET iscommon = 0 ';
        Log('GD_DOCUMENTTYPE: Обновление поля iscommon');
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
        Log(E.Message);
      end;
    end;
  finally
    ibsql.Free;
    FIBTransaction.Free;
  end;
end;

end.
