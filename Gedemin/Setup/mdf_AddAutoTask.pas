unit mdf_AddAutoTask;
 
interface
 
uses
  IBDatabase, gdModify;
 
procedure AddAutoTaskTables(IBDB: TIBDatabase; Log: TModifyLog);
 
implementation
 
uses
  IBSQL, SysUtils, mdf_metadata_unit;
 
procedure AddAutoTaskTables(IBDB: TIBDatabase; Log: TModifyLog);
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

        if not RelationExist2('GD_AUTOTASK', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'CREATE TABLE gd_autotask '#13#10 +
            ' ( '#13#10 +
            '   id               dintkey,'#13#10 +
            '   name             dname,'#13#10 +
            '   description      dtext180,'#13#10 +
            '   functionkey      dforeignkey,'#13#10 +
            '   autotrkey        dforeignkey,'#13#10 +
            '   reportkey        dforeignkey,'#13#10 +
            '   cmdline          dtext255,'#13#10 +
            '   backupfile       dtext255,'#13#10 +
            '   userkey          dforeignkey,'#13#10 +
            '   atstartup        dboolean,'#13#10 +
            '   exactdate        dtimestamp,'#13#10 +
            '   monthly          dinteger,'#13#10 +
            '   weekly           dinteger,'#13#10 +
            '   daily            dboolean,'#13#10 +
            '   starttime        dtime,'#13#10 +
            '   endtime          dtime,'#13#10 +
            '   priority         dinteger_notnull DEFAULT 0,'#13#10 +
            '   creatorkey       dforeignkey,'#13#10 +
            '   creationdate     dcreationdate,'#13#10 +
            '   editorkey        dforeignkey,'#13#10 +
            '   editiondate      deditiondate,'#13#10 +
            '   afull            dsecurity,'#13#10 +
            '   achag            dsecurity,'#13#10 +
            '   aview            dsecurity,'#13#10 +
            '   disabled         ddisabled,'#13#10 +
            '   CONSTRAINT gd_pk_autotask PRIMARY KEY (id), '#13#10 +
            '   CONSTRAINT gd_chk_autotask_monthly CHECK (monthly BETWEEN -31 AND 31 AND monthly <> 0), '#13#10 +
            '   CONSTRAINT gd_chk_autotask_weekly CHECK (weekly BETWEEN 1 AND 7), '#13#10 +
            '   CONSTRAINT gd_chk_autotask_priority CHECK (priority >= 0), '#13#10 +
            '   CONSTRAINT gd_chk_autotask_time CHECK((starttime IS NULL AND endtime IS NULL) OR (starttime < endtime)), '#13#10 +
            '   CONSTRAINT gd_chk_autotask_cmd CHECK(cmdline > ''''), '#13#10 +
            '   CONSTRAINT gd_chk_autotask_backupfile CHECK(backupfile > '''') '#13#10 +
            ' )';
          FIBSQL.ExecQuery;
        end;

        if not FieldExist2('GD_AUTOTASK', 'COMPUTER', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_autotask ADD computer dtext60';
          FIBSQL.ExecQuery;
        end;

        if not FieldExist2('GD_AUTOTASK', 'PULSE', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_autotask ADD pulse dinteger';
          FIBSQL.ExecQuery;

          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_autotask ADD CONSTRAINT gd_chk_autotask_pulse CHECK(pulse >= 0)';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_bi_autotask FOR gd_autotask '#13#10 +
          '  BEFORE INSERT '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.id IS NULL) THEN '#13#10 +
          '    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        if not RelationExist2('GD_AUTOTASK_LOG', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'CREATE TABLE gd_autotask_log '#13#10 +
            '( '#13#10 +
            '  id               dintkey, '#13#10 +
            '  autotaskkey      dintkey, '#13#10 +
            '  eventtext        dtext255 NOT NULL, '#13#10 +
            '  creatorkey       dforeignkey, '#13#10 +
            '  creationdate     dcreationdate, '#13#10 +
            '  CONSTRAINT gd_pk_autotask_log PRIMARY KEY (id), '#13#10 +
            '  CONSTRAINT gd_fk_autotask_log_autotaskkey '#13#10 +
            '    FOREIGN KEY (autotaskkey) REFERENCES gd_autotask (id) '#13#10 +
            '    ON DELETE CASCADE '#13#10 +
            '    ON UPDATE CASCADE '#13#10 +
            ')';
          FIBSQL.ExecQuery;
        end;

        if not FieldExist2('GD_AUTOTASK_LOG', 'CONNECTION_ID', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_autotask_log ADD connection_id    dinteger DEFAULT CURRENT_CONNECTION';
          FIBSQL.ExecQuery;  
        end;

        if not FieldExist2('GD_AUTOTASK_LOG', 'CLIENT_ADDRESS', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_autotask_log ADD client_address dtext60';
          FIBSQL.ExecQuery;  
        end;

        if not IndexExist2('GD_X_AUTOTASK_LOG_CD', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'CREATE DESC INDEX gd_x_autotask_log_cd ON gd_autotask_log (creationdate)';
          FIBSQL.ExecQuery;
        end;

        if not IndexExist2('GD_X_AUTOTASK_LOG_CNID', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'CREATE INDEX gd_x_autotask_log_cnid ON gd_autotask_log (connection_id)';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_bi_autotask_log FOR gd_autotask_log '#13#10 +
          '  BEFORE INSERT '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.id IS NULL) THEN '#13#10 +
          '    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
          ''#13#10 +
          '  IF (NEW.client_address IS NULL) THEN'#13#10 +
          '    NEW.client_address = RDB$GET_CONTEXT(''SYSTEM'', ''CLIENT_ADDRESS'');'#13#10 +
          'END';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview, achag, afull) '#13#10 +
          'VALUES ( '#13#10 +
          '       740075, '#13#10 +
          '       740050, '#13#10 +
          '       ''Автозадачи'', '#13#10 +
          '       '''', '#13#10 +
          '       ''TgdcAutoTask'', '#13#10 +
          '       NULL, '#13#10 +
          '       256, '#13#10 +
          '       1, 1, 1 '#13#10 +
          '       ) MATCHING (id)';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'GRANT ALL ON GD_AUTOTASK TO administrator;';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'GRANT ALL ON GD_AUTOTASK_LOG TO administrator;';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (218, ''0000.0001.0000.0249'', ''28.04.2015'', ''Add GD_AUTOTASK, GD_AUTOTASK_LOG tables.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (219, ''0000.0001.0000.0250'', ''05.06.2015'', ''Added COMPUTER field to GD_AUTOTASK.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (220, ''0000.0001.0000.0251'', ''05.06.2015'', ''Added PULSE field to GD_AUTOTASK.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;
      finally
        FIBSQL.Free;
      end;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        Log(E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;  
 
end.