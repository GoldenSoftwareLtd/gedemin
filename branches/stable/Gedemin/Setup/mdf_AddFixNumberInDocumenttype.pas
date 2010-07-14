unit mdf_AddFixNumberInDocumenttype;
//Добавление флага фиксированной длины номера в gd_lastnumber

interface
uses
  sysutils, IBDatabase, gdModify;
  procedure AddFixNumberInDocumenttype(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL;

procedure AddFixNumberInDocumenttype(IBDB: TIBDatabase; Log: TModifyLog);
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
      ibsql.SQL.Text := 'SELECT * FROM rdb$fields WHERE rdb$field_name = ''DFIXLENGTH''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := ' CREATE DOMAIN DFIXLENGTH AS INTEGER ' +
          ' CHECK ((VALUE IS NULL) OR (VALUE > 0 AND VALUE <= 20))';
        Log('Добавление домена DFIXLENGTH');
        ibsql.ExecQuery;

        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$field_name = ''FIXLENGTH'' AND rdb$relation_name = ''GD_LASTNUMBER''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE gd_lastnumber ADD fixlength dfixlength';
        Log('GD_LASTNUMBER: Добавление поля fixlength');
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

  ibsql := TIBSQL.Create(nil);
  FIBTransaction := TIBTransaction.Create(nil);
  try
    FIBTransaction.DefaultDatabase := IBDB;
    ibsql.Transaction := FIBTransaction;
    try
      FIBTransaction.StartTransaction;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$indices WHERE rdb$index_name = ''EVT_X_OBJECT_OBJECTNAME_UPPER''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'CREATE ASC INDEX evt_x_object_objectname_upper ' +
          'ON evt_object ' +
          'COMPUTED BY (UPPER(objectname)) ';
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
