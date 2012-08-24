{Добавляет возможность работать с холдингом }
unit mdf_AddHolding;

interface

uses
  sysutils, IBDatabase, gdModify;
  
  procedure AddHolding(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL;

procedure AddHolding(IBDB: TIBDatabase; Log: TModifyLog);
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
      ibsql.ParamCheck := False;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relations ' +
        ' WHERE rdb$relation_name = ''GD_HOLDING''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'CREATE TABLE gd_holding ( ' +
          ' holdingkey dintkey NOT NULL, companykey dintkey NOT NULL);';
        Log('GD_HOLDING: Добавление таблицы gd_holding');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'GRANT ALL ON gd_holding TO administrator';
      ibsql.ExecQuery;
      FIBTransaction.Commit;
      FIBTransaction.StartTransaction;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints ' +
        ' WHERE rdb$constraint_name = ''GD_PK_HOLDING''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := ' ALTER TABLE gd_holding ADD CONSTRAINT gd_pk_holding ' +
          ' PRIMARY KEY (holdingkey, companykey); ';
        Log('GD_HOLDING: Добавление первичного ключа');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints ' +
        ' WHERE rdb$constraint_name = ''GD_FK_HOLDING_COMPANYKEY''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE gd_holding ADD CONSTRAINT gd_fk_holding_companykey ' +
          ' FOREIGN KEY (companykey) REFERENCES gd_contact (id) ' +
          ' ON DELETE CASCADE ON UPDATE CASCADE;';
        Log('GD_HOLDING: Добавление внешнего ключа на поле companykey ');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints ' +
        ' WHERE rdb$constraint_name = ''GD_FK_HOLDING_HOLDINGKEY''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE gd_holding ADD  CONSTRAINT gd_fk_holding_holdingkey ' +
          '  FOREIGN KEY (holdingkey) REFERENCES gd_contact (id) ' +
          '  ON DELETE CASCADE ON UPDATE CASCADE;';
        Log('GD_HOLDING: Добавление внешнего ключа на поле holdingkey ');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

{      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields  ' +
        ' WHERE rdb$field_name = ''ISHOLDING'' AND rdb$relation_name = ''GD_COMPANY''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE gd_company ADD isholding dboolean_notnull default 0 ';
        ibsql.ExecQuery;
        Log('GD_COMPANY: Добавление поля isholding');
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
        ibsql.Close;
        ibsql.SQL.Text := 'UPDATE gd_company SET isholding = 0 ';
        ibsql.ExecQuery;
        Log('GD_COMPANY: Обновление поля isholding');
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$triggers  '+
        ' WHERE rdb$trigger_name = ''GD_BI_COMPANY'' ';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'CREATE TRIGGER gd_bi_company FOR gd_company ACTIVE '#13#10 +
          ' BEFORE INSERT POSITION 0 '#13#10 +
          ' AS '#13#10 +
          ' BEGIN '#13#10 +
          '   IF (NEW.isholding IS NULL) THEN '#13#10 +
          '     NEW.isholding = 0; '#13#10 +
          ' END '#13#10 ;
        Log('GD_COMPANY: Добавление триггера gd_bi_company');
        ibsql.ExecQuery;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$triggers  '+
        ' WHERE rdb$trigger_name = ''GD_BU_COMPANY'' ';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'CREATE TRIGGER gd_bu_company FOR gd_company ACTIVE '#13#10 +
          ' BEFORE UPDATE POSITION 0 '#13#10 +
          ' AS '#13#10 +
          ' BEGIN '#13#10 +
          '   IF (NEW.isholding IS NULL) THEN '#13#10 +
          '     NEW.isholding = 0; '#13#10 +
          ' END '#13#10 ;
        Log('GD_COMPANY: Добавление триггера gd_bu_company');
        ibsql.ExecQuery;
      end;}

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
