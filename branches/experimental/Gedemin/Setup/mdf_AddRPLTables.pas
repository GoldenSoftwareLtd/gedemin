unit mdf_AddRPLTables;

interface

uses
  IBDatabase, gdModify;

procedure AddRPLTables(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, mdf_MetaData_unit;

const
  CreateDatabaseTableSQL =
    'CREATE TABLE RPL_DATABASE ( ' +
    '    ID          DINTKEY, ' +
    '    NAME        DNAME, ' +
    '    ISOURBASE   DBOOLEAN)';

  CreateDatabasePrimaryKey =
    'ALTER TABLE RPL_DATABASE ADD CONSTRAINT RPL_PK_DATABASE_ID PRIMARY KEY (ID)';

  CreateDatabaseTrigger =
    'CREATE TRIGGER RPL_BI_DATABASE FOR RPL_DATABASE ' +
    'ACTIVE BEFORE INSERT POSITION 0 ' +
    'AS ' +
    'BEGIN ' +
    '  IF (NEW.ID IS NULL) THEN ' +
    '    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); ' +
    'END';

  GrantDatabase =
    'GRANT ALL ON RPL_DATABASE TO ADMINISTRATOR';

  CreateRecordTableSQL =
    'CREATE TABLE RPL_RECORD ( ' +
    '    ID           DINTKEY, ' +
    '    BASEKEY      DINTKEY, ' +
    '    EDITIONDATE  DTIMESTAMP, ' +
    '    STATE        SMALLINT)';

  CreateRecordPrimaryKey =
    'ALTER TABLE RPL_RECORD ADD CONSTRAINT RPL_PK_RECORD_ID PRIMARY KEY (ID, BASEKEY)';

  CreateRecordForeignKey01 =
    'ALTER TABLE RPL_RECORD ADD CONSTRAINT RPL_FK_RECORD_BASEKEY FOREIGN KEY (BASEKEY) ' +
      'REFERENCES RPL_DATABASE (ID) ON DELETE CASCADE ON UPDATE CASCADE';

  CreateRecordForeignKey02 =
    'ALTER TABLE RPL_RECORD ADD CONSTRAINT RPL_FK_RECORD_ID FOREIGN KEY (ID) ' +
      'REFERENCES GD_RUID (ID) ON DELETE CASCADE ON UPDATE CASCADE';

  GrantRecord =
    'GRANT ALL ON RPL_RECORD TO ADMINISTRATOR';

  AlterATSettingPos = 'ALTER TABLE at_settingpos ADD autoadded DBOOLEAN_NOTNULL DEFAULT 0 NOT NULL';

procedure AddRPLTables(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.ParamCheck := False;

        FTransaction.StartTransaction;

        if not IndexExist2('GD_X_FUNCTION_MODULE', FTransaction) then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'CREATE INDEX gd_x_function_module ON gd_function (module) ';
          FIBSQL.ExecQuery;
        end;

        if not FieldExist2('GD_CONTACT', 'CREATORKEY', FTransaction) then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_contact ADD creatorkey dforeignkey';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_contact ADD creationdate dcreationdate';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_contact ADD CONSTRAINT gd_fk_contact_creatorkey ' +
            '  FOREIGN KEY (creatorkey) REFERENCES gd_contact(id) ' +
            '  ON UPDATE CASCADE ';
          FIBSQL.ExecQuery;
        end;

        if not FieldExist2('GD_GOOD', 'CREATORKEY', FTransaction) then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_good ADD creatorkey dforeignkey';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_good ADD creationdate dcreationdate';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_good ADD CONSTRAINT gd_fk_good_creatorkey ' +
            '  FOREIGN KEY (creatorkey) REFERENCES gd_contact(id) ' +
            '  ON UPDATE CASCADE ';
          FIBSQL.ExecQuery;
        end;

        if not FieldExist2('GD_GOODGROUP', 'CREATORKEY', FTransaction) then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_goodgroup ADD creatorkey dforeignkey';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_goodgroup ADD creationdate dcreationdate';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_goodgroup ADD CONSTRAINT gd_fk_goodgroup_creatorkey ' +
            '  FOREIGN KEY (creatorkey) REFERENCES gd_contact(id) ' +
            '  ON UPDATE CASCADE ';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_goodgroup ADD editorkey dforeignkey';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_goodgroup ADD editiondate deditiondate';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_goodgroup ADD CONSTRAINT gd_fk_goodgroup_editorkey ' +
            '  FOREIGN KEY (editorkey) REFERENCES gd_contact(id) ' +
            '  ON UPDATE CASCADE ';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'SELECT rdb$relation_name FROM rdb$relations WHERE rdb$relation_name = ''RPL_DATABASE'' ';
        FIBSQL.ExecQuery;
        if FIBSQL.RecordCount = 0 then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := CreateDatabaseTableSQL;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := CreateDatabasePrimaryKey;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := CreateDatabaseTrigger;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := GrantDatabase;
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'SELECT rdb$relation_name FROM rdb$relations WHERE rdb$relation_name = ''RPL_RECORD'' ';
        FIBSQL.ExecQuery;
        if FIBSQL.RecordCount = 0 then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := CreateRecordTableSQL;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := CreateRecordPrimaryKey;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := CreateRecordForeignKey01;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := CreateRecordForeignKey02;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := GrantRecord;
          FIBSQL.ExecQuery;
        end;

        // Если в таблице AT_SETTINGPOS еще нет поля AUTOADDED
        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          ' SELECT ' +
          '   rdb$field_name ' +
          ' FROM ' +
          '   rdb$relation_fields ' +
          ' WHERE' +
          '   rdb$relation_name = ''AT_SETTINGPOS'' ' +
          '   AND rdb$field_name = ''AUTOADDED'' ';
        FIBSQL.ExecQuery;
        if FIBSQL.RecordCount = 0 then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := AlterATSettingPos;
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (108, ''0000.0001.0000.0140'', ''09.07.2008'', ''Добавлены RPL таблицы'') ';
        try
          FIBSQL.ExecQuery;
        except
        end;

        FTransaction.Commit;
      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        raise;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
