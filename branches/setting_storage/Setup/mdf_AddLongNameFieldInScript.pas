unit mdf_AddLongNameFieldInScript;

interface

uses
  IBSQL, sysutils, IBDatabase, gdModify;

procedure AddLongNameFieldInScript(IBDB: TIBDatabase; Log: TModifyLog);

implementation

procedure AddLongNameFieldInScript(IBDB: TIBDatabase; Log: TModifyLog);
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

      ibsql.SQL.Text :=
        'SELECT * FROM rdb$fields WHERE rdb$field_name = ''DLONGNAME''';
      ibsql.ExecQuery;
      if ibsql.Eof then
      begin
        ibsql.Close;
        ibsql.SQL.Text :=
          'CREATE DOMAIN dlongname ' +
          '  AS VARCHAR(80) CHARACTER SET WIN1251 NOT NULL COLLATE PXW_CYRL';
        Log('Создание домена DLONGNAME.');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;
      ibsql.Close;

      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$field_name = ''NAME'' AND rdb$relation_name = ''GD_FUNCTION''' +
        ' AND rdb$field_source = ''DLONGNAME''';
      ibsql.ExecQuery;
      if ibsql.Eof then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE gd_function ALTER name TYPE dlongname';
        Log('gd_function: Увеличение длины поля name');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;
      ibsql.Close;

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

