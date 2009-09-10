unit mdf_AddSQLHistTables;

interface

uses
  IBDatabase, gdModify;

procedure AddSQLHistTables(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, mdf_MetaData_unit;

const
  CreateSQLHistTable =
    'CREATE TABLE gd_sql_history ('#13#10 +
    '  id               dintkey,'#13#10 +
    '  sql_text         dblobtext80_1251 not null,'#13#10 +
    '  sql_params       dblobtext80_1251,'#13#10 +
    '  bookmark         CHAR(1),'#13#10 +
    '  creatorkey       dintkey,'#13#10 +
    '  creationdate     dcreationdate,'#13#10 +
    '  editorkey        dintkey,'#13#10 +
    '  editiondate      deditiondate,'#13#10 +
    '  exec_count       dinteger_notnull DEFAULT 1'#13#10 +
    ')';

  CreatePrimaryKey =
    'ALTER TABLE gd_sql_history ADD CONSTRAINT gd_pk_sql_history PRIMARY KEY (id)';

  CreateBITrigger =
    'CREATE TRIGGER gd_bi_sql_history FOR gd_sql_history '#13#10 +
    '  BEFORE INSERT '#13#10 +
    '  POSITION 0 '#13#10 +
    'AS '#13#10 +
    'BEGIN '#13#10 +
    'IF (NEW.ID IS NULL) THEN '#13#10 +
    '  NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
    'END';

  CreateBUTrigger =
    'CREATE TRIGGER gd_bu_sql_history FOR gd_sql_history '#13#10 +
    '  BEFORE UPDATE '#13#10 +
    '  POSITION 0 '#13#10 +
    'AS '#13#10 +
    'BEGIN '#13#10 +
    '  IF (NEW.editiondate <> OLD.editiondate) THEN '#13#10 +
    '    NEW.exec_count = NEW.exec_count + 1; '#13#10 +
    'END';

  GrantSQLHistory =
    'GRANT ALL ON GD_SQL_HISTORY TO ADMINISTRATOR';

  CreateSQLHistForeignKey01 =
    'ALTER TABLE gd_sql_history ADD CONSTRAINT gd_fk_sql_history_creatorkey  '#13#10 +
    '  FOREIGN KEY (creatorkey) REFERENCES gd_contact (id) '#13#10 +
    '  ON DELETE NO ACTION '#13#10 +
    '  ON UPDATE CASCADE';

  CreateRecordForeignKey02 =
    'ALTER TABLE gd_sql_history ADD CONSTRAINT gd_fk_sql_history_editorkey '#13#10 +
    '  FOREIGN KEY (editorkey) REFERENCES gd_contact (id) '#13#10 +
    '  ON DELETE NO ACTION '#13#10 +
    '  ON UPDATE CASCADE';

procedure AddSQLHistTables(IBDB: TIBDatabase; Log: TModifyLog);
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
        FIBSQL.SQL.Text :=
          'SELECT rdb$relation_name FROM rdb$relations WHERE rdb$relation_name = ''GD_SQL_HISTORY'' ';
        FIBSQL.ExecQuery;
        if FIBSQL.RecordCount = 0 then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := CreateSQLHistTable;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := CreatePrimaryKey;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := CreateSQLHistForeignKey01;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := CreateRecordForeignKey02;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := CreateBITrigger;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := CreateBUTrigger;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := GrantSQLHistory;
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'ALTER TABLE ac_companyaccount DROP CONSTRAINT ac_pk_companyaccount ';
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'ALTER TABLE ac_companyaccount '#13#10 +
          '  ADD CONSTRAINT ac_pk_companyaccount PRIMARY KEY (companykey, accountkey) ';
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (107, ''0000.0001.0000.0139'', ''07.09.2009'', ''GD_SQL_HISTORY table added and other changes'')';
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
