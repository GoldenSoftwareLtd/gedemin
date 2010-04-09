unit mdf_ChangeSetting;

interface
uses
  sysutils, IBDatabase, gdModify;
  procedure ChangeSetting(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL;

procedure ChangeSetting(IBDB: TIBDatabase; Log: TModifyLog);
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
      ibsql.SQL.Text := 'SELECT * FROM rdb$relations ' +
        ' WHERE rdb$relation_name = ''AT_SETTING_STORAGE''';
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'GRANT ALL ON AT_SETTING_STORAGE TO administrator ';
        Log('AT_SETTING_STORAGE: Установка прав доступа');
        ibsql.ExecQuery;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$field_name = ''WITHDETAIL'' AND rdb$relation_name = ''AT_SETTINGPOS''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE at_settingpos ADD withdetail dboolean_notnull default 0 ';
        Log('AT_SETTINGPOS: Добавление поля withdetail');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$field_name = ''VALUENAME'' AND rdb$relation_name = ''AT_SETTING_STORAGE''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE at_setting_storage ADD valuename dtext255 ';
        Log('AT_SETTINGPOS: Добавление поля valuename');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$field_name = ''XID'' AND rdb$relation_name = ''AT_SETTINGPOS''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE at_settingpos ADD xid dinteger NOT NULL ';
        Log('AT_SETTINGPOS: Добавление поля xid');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
        ibsql.Close;
        ibsql.SQL.Text := 'UPDATE at_settingpos SET xid = objectid ';
        Log('AT_SETTINGPOS: Для поля xid установлены значения поля objectid');
        ibsql.ExecQuery;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints ' +
        ' WHERE rdb$constraint_name = ''AT_UK_SETTINGPOS_RUID''';
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE at_settingpos DROP CONSTRAINT at_uk_settingpos_ruid ';
        Log('AT_SETTINGPOS: Удаление уникального ключа at_uk_settingpos_ruid');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$field_name = ''OBJECTID'' AND rdb$relation_name = ''AT_SETTINGPOS''';
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE at_settingpos ALTER COLUMN objectid type dinteger  ';
        ibsql.ExecQuery;
        ibsql.Close;
        ibsql.SQL.Text := 'UPDATE rdb$relation_fields SET ' +
          ' rdb$null_flag = NULL ' +
          ' WHERE (rdb$field_name = ''OBJECTID'') AND  ' +
          ' (rdb$relation_name = ''AT_SETTINGPOS'') ';
        Log('AT_SETTINGPOS: Изменение поля objectid');
        ibsql.ExecQuery;

        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$field_name = ''SETTINGSRUID'' AND rdb$relation_name = ''AT_SETTING''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE at_setting ADD settingsruid DBLOBTEXT80_1251  ';
        Log('AT_SETTING: Добавление поля settingsruid');
        ibsql.ExecQuery;

        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$field_name = ''NEEDMODIFY'' AND rdb$relation_name = ''AT_SETTINGPOS''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE at_settingpos ADD needmodify DBOOLEAN_NOTNULL DEFAULT 1 ';
        Log('AT_SETTINGPOS: Добавление поля needmodify');
        ibsql.ExecQuery;

        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;

        ibsql.Close;
        ibsql.SQL.Text := 'UPDATE at_settingpos SET needmodify = 1  ';
        Log('AT_SETTINGPOS: Обновление поля needmodify');
        ibsql.ExecQuery;

        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;

      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$field_name = ''VERSION'' AND rdb$relation_name = ''AT_SETTING''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE at_setting ADD version dinteger ';
        Log('AT_SETTING: Добавление поля version');
        ibsql.ExecQuery;

        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;

        ibsql.Close;
        ibsql.SQL.Text := 'UPDATE at_setting SET version = 1  ';
        Log('AT_SETTING: Обновление поля version');
        ibsql.ExecQuery;

        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;

      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$field_name = ''DESCRIPTION'' AND rdb$relation_name = ''AT_SETTING''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE at_setting ADD description dtext255 ';
        Log('AT_SETTING: Добавление поля description');
        ibsql.ExecQuery;

        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;

        ibsql.Close;
        ibsql.SQL.Text := 'UPDATE at_setting SET description = name  ';
        Log('AT_SETTING: Обновление поля description');
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
