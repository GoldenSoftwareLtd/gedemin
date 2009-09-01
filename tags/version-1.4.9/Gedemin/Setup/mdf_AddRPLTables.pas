unit mdf_AddRPLTables;

interface

uses
  IBDatabase, gdModify;

procedure AddRPLTables(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

const
  CreateDatabaseTableSQL =
    'CREATE TABLE RPL_DATABASE ( ' +
    '    ID          DINTKEY, ' +
    '    NAME        DTEXT60 NOT NULL COLLATE PXW_CYRL, ' +
    '    ISOURBASE   DBOOLEAN)';

  CreateDatabasePrimaryKey =
    'ALTER TABLE RPL_DATABASE ADD CONSTRAINT PK_RPL_DATABASE PRIMARY KEY (ID)';

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
    'ALTER TABLE RPL_RECORD ADD CONSTRAINT PK_RPL_RECORD PRIMARY KEY (ID, BASEKEY)';

  CreateRecordForeignKey01 =
    'ALTER TABLE RPL_RECORD ADD CONSTRAINT FK_RPL_RECORD FOREIGN KEY (BASEKEY) ' +
      'REFERENCES RPL_DATABASE (ID) ON DELETE CASCADE ON UPDATE CASCADE';

  CreateRecordForeignKey02 =
    'ALTER TABLE RPL_RECORD ADD CONSTRAINT FK_RPL_RECORD_GD_RUID FOREIGN KEY (ID) ' +
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
        try
          // Если таблица RPL_DATABASE не существует
          FIBSQL.SQL.Text := 'SELECT rdb$relation_name FROM rdb$relations WHERE rdb$relation_name = ''RPL_DATABASE'' ';
          FIBSQL.ExecQuery;
          if FIBSQL.RecordCount = 0 then
          begin
            FIBSQL.Close;
            FIBSQL.SQL.Text := CreateDatabaseTableSQL;
            FIBSQL.ExecQuery;
            Log('Таблица RPL_DATABASE добавлена успешно');

            FIBSQL.Close;
            FIBSQL.SQL.Text := CreateDatabasePrimaryKey;
            FIBSQL.ExecQuery;
            Log('Добавление первичного ключа прошло успешно');

            FIBSQL.Close;
            FIBSQL.SQL.Text := CreateDatabaseTrigger;
            FIBSQL.ExecQuery;
            Log('Добавление триггера прошло успешно');

            FIBSQL.Close;
            FIBSQL.SQL.Text := GrantDatabase;
            FIBSQL.ExecQuery;
          end;

          // Если таблица RPL_RECORD не существует
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'SELECT rdb$relation_name FROM rdb$relations WHERE rdb$relation_name = ''RPL_RECORD'' ';
          FIBSQL.ExecQuery;
          if FIBSQL.RecordCount = 0 then
          begin
            FIBSQL.Close;
            FIBSQL.SQL.Text := CreateRecordTableSQL;
            FIBSQL.ExecQuery;
            Log('Таблица RPL_RECORD добавлена успешно');

            FIBSQL.Close;
            FIBSQL.SQL.Text := CreateRecordPrimaryKey;
            FIBSQL.ExecQuery;
            Log('Добавление первичного ключа прошло успешно');

            FIBSQL.Close;
            FIBSQL.SQL.Text := CreateRecordForeignKey01;
            FIBSQL.ExecQuery;
            FIBSQL.Close;
            FIBSQL.SQL.Text := CreateRecordForeignKey02;
            FIBSQL.ExecQuery;
            Log('Добавление ссылок прошло успешно');

            FIBSQL.Close;
            FIBSQL.SQL.Text := GrantRecord;
            FIBSQL.ExecQuery;
          end;

          FTransaction.Commit;
        except
          on E: Exception do
          begin
            Log(E.Message);
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
        end;

        FTransaction.StartTransaction;
        try
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
            Log('Добавление поля AUTOADDED в таблицу AT_SETTINGPOS прошло успешно');
          end;
          FTransaction.Commit;
        except
          on E: Exception do
          begin
            Log(E.Message);
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
        end;

        FTransaction.StartTransaction;
        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (102, ''0000.0001.0000.0129'', ''25.08.2008'', ''$RPL tables added'')';
        try
          FIBSQL.ExecQuery;
          FTransaction.Commit;
        except
        end;
        
      finally
        FIBSQL.Free;
      end;
      if FTransaction.InTransaction then
        FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка при добавлении RPL таблиц.' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;


end.
