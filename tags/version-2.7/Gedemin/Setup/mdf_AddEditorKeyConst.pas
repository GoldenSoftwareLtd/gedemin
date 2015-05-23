unit mdf_AddEditorKeyConst;

interface

uses
  IBDatabase, gdModify;

procedure AddEditorKeyConst(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, mdf_metadata_unit;

procedure AddEditorKeyConst(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;

        if not FieldExist2('gd_constvalue', 'editorkey', FTransaction) then
        begin
          FIBSQL.SQL.Text := 'ALTER TABLE gd_constvalue ADD editorkey dforeignkey ';
          FIBSQL.ExecQuery;

          FIBSQL.SQL.Text :=
              'ALTER TABLE gd_constvalue ADD CONSTRAINT gd_fk_ek_constvalue '#13#10 +
              '  FOREIGN KEY (editorkey) REFERENCES gd_contact(id) '#13#10 +
              '  ON DELETE SET NULL '#13#10 +
              '  ON UPDATE CASCADE ';
          FIBSQL.ExecQuery;

          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_constvalue ADD editiondate deditiondate';
          FIBSQL.ExecQuery;

          FTransaction.Commit;
          Log('Добавление EDITORKEY в константы прошло успешно');
        end;
      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        Log('Ошибка: ' + E.Message);
        raise;
      end;
    end;
  finally
    if FTransaction.InTransaction then
      FTRansaction.Rollback;
    FTransaction.Free;
  end;

  Log('Дезактивация некоторых триггеров');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;

        if TriggerExist2('gd_bi_contact_2', FTransaction) then
        begin
          FIBSQL.SQL.Text := 'ALTER TRIGGER gd_bi_contact_2 INACTIVE';
          FIBSQL.ExecQuery;
        end;

        if TriggerExist2('gd_bu_contact_2', FTransaction) then
        begin
          FIBSQL.SQL.Text := 'ALTER TRIGGER gd_bu_contact_2 INACTIVE';
          FIBSQL.ExecQuery;
        end;

        if TriggerExist2('gd_command_bu', FTransaction) then
        begin
          FIBSQL.SQL.Text := 'ALTER TRIGGER gd_command_bu INACTIVE';
          FIBSQL.ExecQuery;
        end;

        if TriggerExist2('gd_au_command', FTransaction) then
        begin
          FIBSQL.SQL.Text := 'ALTER TRIGGER gd_au_command INACTIVE';
          FIBSQL.ExecQuery;
        end;

        if TriggerExist2('gd_bi_goodgroup_2', FTransaction) then
        begin
          FIBSQL.SQL.Text := 'ALTER TRIGGER gd_bi_goodgroup_2 INACTIVE';
          FIBSQL.ExecQuery;
        end;

        if TriggerExist2('gd_bi_good_2', FTransaction) then
        begin
          FIBSQL.SQL.Text := 'ALTER TRIGGER gd_bi_good_2 INACTIVE';
          FIBSQL.ExecQuery;
        end;

        if TriggerExist2('gd_bu_good_2', FTransaction) then
        begin
          FIBSQL.SQL.Text := 'ALTER TRIGGER gd_bu_good_2 INACTIVE';
          FIBSQL.ExecQuery;
        end;

        if TriggerExist2('gd_bu_goodgroup_2', FTransaction) then
        begin
          FIBSQL.SQL.Text := 'ALTER TRIGGER gd_bu_goodgroup_2 INACTIVE';
          FIBSQL.ExecQuery;
        end;
      finally
        FIBSQL.Free;
      end;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Ошибка: ' + E.Message);
        raise;
      end;
    end;
  finally
    if FTransaction.InTransaction then
      FTransaction.Rollback;
    FTransaction.Free;
  end;
end;

end.
