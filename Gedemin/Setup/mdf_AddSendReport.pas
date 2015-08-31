unit mdf_AddSendReport;
 
interface
 
uses
  IBDatabase, gdModify;

procedure ModifyAutoTaskAndSMTPTable(IBDB: TIBDatabase; Log: TModifyLog);
 
implementation
 
uses
  IBSQL, SysUtils, mdf_metadata_unit;
 
procedure ModifyAutoTaskAndSMTPTable(IBDB: TIBDatabase; Log: TModifyLog);
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

        AddField2('gd_autotask', 'emailgroupkey', 'dforeignkey', FTransaction);
        AddField2('gd_autotask', 'emailrecipients', 'dtext1024', FTransaction);
        AddField2('gd_autotask', 'emailsmtpkey', 'dforeignkey', FTransaction);
        AddField2('gd_autotask', 'emailexporttype', 'VARCHAR(4)', FTransaction);

        DropConstraint2('gd_autotask', 'fk_gd_autotask_esk', FTransaction);
        if not ConstraintExist2('gd_autotask', 'gd_fk_autotask_esk', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_autotask ADD CONSTRAINT gd_fk_autotask_esk ' +
            'FOREIGN KEY (emailsmtpkey) REFERENCES gd_smtp(id) ' +
            'ON UPDATE CASCADE';
          FIBSQL.ExecQuery;
        end;

        DropConstraint2('gd_autotask', 'fk_gd_autotask_fk', FTransaction);
        if not ConstraintExist2('gd_autotask', 'gd_fk_autotask_fk', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_autotask ADD CONSTRAINT gd_fk_autotask_fk ' +
            'FOREIGN KEY (functionkey) REFERENCES gd_function(id) ' +
            'ON UPDATE CASCADE';
          FIBSQL.ExecQuery;
        end;

        DropConstraint2('gd_autotask', 'fk_gd_autotask_atrk', FTransaction);
        if not ConstraintExist2('gd_autotask', 'gd_fk_autotask_atrk', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_autotask ADD CONSTRAINT gd_fk_autotask_atrk ' +
            'FOREIGN KEY (autotrkey) REFERENCES ac_transaction(id) ' +
            'ON UPDATE CASCADE';
          FIBSQL.ExecQuery;
        end;

        DropConstraint2('gd_autotask', 'fk_gd_autotask_rk', FTransaction);
        if not ConstraintExist2('gd_autotask', 'gd_fk_autotask_rk', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_autotask ADD CONSTRAINT gd_fk_autotask_rk ' +
            'FOREIGN KEY (reportkey) REFERENCES rp_reportlist(id) ' +
            'ON UPDATE CASCADE';
          FIBSQL.ExecQuery;
        end;

        DropConstraint2('gd_autotask', 'fk_gd_autotask_uk', FTransaction);
        if not ConstraintExist2('gd_autotask', 'gd_fk_autotask_uk', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_autotask ADD CONSTRAINT gd_fk_autotask_uk ' +
            'FOREIGN KEY (userkey) REFERENCES gd_user(id) ' +
            'ON UPDATE CASCADE';
          FIBSQL.ExecQuery;
        end;

        DropConstraint2('gd_autotask', 'fk_gd_autotask_ck', FTransaction);
        if not ConstraintExist2('gd_autotask', 'gd_fk_autotask_ck', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_autotask ADD CONSTRAINT gd_fk_autotask_ck ' +
            'FOREIGN KEY (creatorkey) REFERENCES gd_contact(id) ' +
            'ON UPDATE CASCADE';
          FIBSQL.ExecQuery;
        end;

        DropConstraint2('gd_autotask', 'fk_gd_autotask_ek', FTransaction);
        if not ConstraintExist2('gd_autotask', 'gd_fk_autotask_ek', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_autotask ADD CONSTRAINT gd_fk_autotask_ek ' +
            'FOREIGN KEY (editorkey) REFERENCES gd_contact(id) ' +
            'ON UPDATE CASCADE';
          FIBSQL.ExecQuery;
        end;

        if not ConstraintExist2('gd_autotask', 'gd_chk_autotask_emailrecipients', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_autotask ADD CONSTRAINT gd_chk_autotask_emailrecipients ' +
            'CHECK(emailrecipients > '''')';
          FIBSQL.ExecQuery;
        end;

        if not ConstraintExist2('gd_autotask', 'gd_chk_autotask_recipients', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_autotask ADD CONSTRAINT gd_chk_autotask_recipients ' +
            'CHECK((emailrecipients > '''') OR (emailgroupkey IS NOT NULL))';
          FIBSQL.ExecQuery;
        end;

        if not ConstraintExist2('gd_autotask', 'GD_CHK_AUTOTASK_EXPORTTYPE', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_autotask ADD CONSTRAINT GD_CHK_AUTOTASK_EXPORTTYPE ' +
            'CHECK(emailexporttype IN (''DOC'', ''XLS'', ''PDF'', ''XML''))';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_biu_autotask FOR gd_autotask '#13#10 +
          '  BEFORE INSERT OR UPDATE '#13#10 +
          '  POSITION 27000 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NOT NEW.atstartup IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.exactdate = NULL; '#13#10 +
          '    NEW.monthly = NULL; '#13#10 +
          '    NEW.weekly = NULL; '#13#10 +
          '    NEW.daily = NULL; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NOT NEW.exactdate IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.atstartup = NULL; '#13#10 +
          '    NEW.monthly = NULL; '#13#10 +
          '    NEW.weekly = NULL; '#13#10 +
          '    NEW.daily = NULL; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NOT NEW.monthly IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.atstartup = NULL; '#13#10 +
          '    NEW.exactdate = NULL; '#13#10 +
          '    NEW.weekly = NULL; '#13#10 +
          '    NEW.daily = NULL; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NOT NEW.weekly IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.atstartup = NULL; '#13#10 +
          '    NEW.exactdate = NULL; '#13#10 +
          '    NEW.monthly = NULL; '#13#10 +
          '    NEW.daily = NULL; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NOT NEW.daily IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.atstartup = NULL; '#13#10 +
          '    NEW.exactdate = NULL; '#13#10 +
          '    NEW.monthly = NULL; '#13#10 +
          '    NEW.weekly = NULL; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NOT NEW.functionkey IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.autotrkey = NULL; '#13#10 +
          '    NEW.reportkey = NULL; '#13#10 +
          '    NEW.cmdline = NULL; '#13#10 +
          '    NEW.backupfile = NULL; '#13#10 +
          '    NEW.emailgroupkey = NULL; '#13#10 +
          '    NEW.emailrecipients = NULL; '#13#10 +
          '    NEW.emailsmtpkey = NULL; '#13#10 +
          '    NEW.emailexporttype = NULL; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NOT NEW.autotrkey IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.functionkey = NULL; '#13#10 +
          '    NEW.reportkey = NULL; '#13#10 +
          '    NEW.cmdline = NULL; '#13#10 +
          '    NEW.backupfile = NULL; '#13#10 +
          '    NEW.emailgroupkey = NULL; '#13#10 +
          '    NEW.emailrecipients = NULL; '#13#10 +
          '    NEW.emailsmtpkey = NULL; '#13#10 +
          '    NEW.emailexporttype = NULL; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NOT NEW.reportkey IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.functionkey = NULL; '#13#10 +
          '    NEW.autotrkey = NULL; '#13#10 +
          '    NEW.cmdline = NULL; '#13#10 +
          '    NEW.backupfile = NULL; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NOT NEW.cmdline IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.functionkey = NULL; '#13#10 +
          '    NEW.autotrkey = NULL; '#13#10 +
          '    NEW.reportkey = NULL; '#13#10 +
          '    NEW.backupfile = NULL; '#13#10 +
          '    NEW.emailgroupkey = NULL; '#13#10 +
          '    NEW.emailrecipients = NULL; '#13#10 +
          '    NEW.emailsmtpkey = NULL; '#13#10 +
          '    NEW.emailexporttype = NULL; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NOT NEW.backupfile IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.functionkey = NULL; '#13#10 +
          '    NEW.autotrkey = NULL; '#13#10 +
          '    NEW.reportkey = NULL; '#13#10 +
          '    NEW.cmdline = NULL; '#13#10 +
          '    NEW.emailgroupkey = NULL; '#13#10 +
          '    NEW.emailrecipients = NULL; '#13#10 +
          '    NEW.emailsmtpkey = NULL; '#13#10 +
          '    NEW.emailexporttype = NULL; '#13#10 +
          '  END '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        if not ConstraintExist2('gd_autotask_log', 'gd_fk_autotask_log_ck', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_autotask_log '#13#10 +
            '  ADD CONSTRAINT gd_fk_autotask_log_ck '#13#10 +
            '    FOREIGN KEY (creatorkey) REFERENCES gd_contact(id) '#13#10 +
            '    ON UPDATE CASCADE';
          FIBSQL.ExecQuery;
        end;

        AddField2('gd_smtp', 'principal', 'dboolean_notnull', FTransaction);

        DropConstraint2('gd_smtp', 'fk_gd_smtp_ck', FTransaction);
        DropConstraint2('gd_smtp', 'gd_smtp_fk_ck', FTransaction);
        if not ConstraintExist2('gd_smtp', 'gd_fk_smtp_ck', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_smtp '#13#10 +
            'ADD CONSTRAINT gd_fk_smtp_ck '#13#10 +
            '  FOREIGN KEY (creatorkey) REFERENCES gd_contact (id) '#13#10 +
            '  ON UPDATE CASCADE';
          FIBSQL.ExecQuery;
        end;

        DropConstraint2('gd_smtp', 'fk_gd_smtp_ek', FTransaction);
        DropConstraint2('gd_smtp', 'gd_smtp_fk_ek', FTransaction);
        if not ConstraintExist2('gd_smtp', 'gd_fk_smtp_ek', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_smtp '#13#10 +
            'ADD CONSTRAINT gd_fk_smtp_ek '#13#10 +
            '  FOREIGN KEY (editorkey) REFERENCES gd_contact (id) '#13#10 +
            '  ON UPDATE CASCADE';
          FIBSQL.ExecQuery;
        end;

        DropConstraint2('gd_smtp', 'gd_chk_smtp_timeout', FTransaction);
        if not ConstraintExist2('gd_smtp', 'gd_smtp_chk_timeout', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_smtp '#13#10 +
            'ADD '#13#10 +
            '  CONSTRAINT gd_smtp_chk_timeout CHECK (timeout >= -1) ';
          FIBSQL.ExecQuery;
        end;

        DropConstraint2('gd_smtp', 'gd_chk_smtp_ipsec', FTransaction);
        if not ConstraintExist2('gd_smtp', 'gd_smtp_chk_ipsec', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_smtp '#13#10 +
            'ADD '#13#10 +
            '  CONSTRAINT gd_smtp_chk_ipsec CHECK(ipsec IN (''SSLV2'', ''SSLV23'', ''SSLV3'', ''TLSV1'')) ';
          FIBSQL.ExecQuery;
        end;

        DropConstraint2('gd_smtp', 'gd_chk_smtp_server', FTransaction);
        if not ConstraintExist2('gd_smtp', 'gd_smtp_chk_server', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_smtp '#13#10 +
            'ADD '#13#10 +
            '  CONSTRAINT gd_smtp_chk_server CHECK (server > '''') ';
          FIBSQL.ExecQuery;
        end;

        DropConstraint2('gd_smtp', 'gd_chk_smtp_port', FTransaction);
        if not ConstraintExist2('gd_smtp', 'gd_smtp_chk_port', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_smtp '#13#10 +
            'ADD CONSTRAINT gd_smtp_chk_port CHECK (port > 0 AND port < 65536) ';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_bi_smtp FOR gd_smtp '#13#10 +
          '  BEFORE INSERT '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.id IS NULL) THEN '#13#10 +
          '    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        DropTrigger2('gd_biu_smtp', FTransaction);
        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_aiu_smtp FOR gd_smtp '#13#10 +
          '  AFTER INSERT OR UPDATE '#13#10 +
          '  POSITION 32000 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.principal = 1) THEN '#13#10 +
          '    UPDATE gd_smtp SET principal = 0 '#13#10 +
          '	WHERE principal = 1 AND id <> NEW.id; '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'ALTER TABLE gd_autotask ALTER emailrecipients TYPE dtext1024 ';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'ALTER TABLE gd_autotask ALTER emailexporttype TYPE VARCHAR(4) ';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'ALTER TABLE gd_smtp ALTER email TYPE dname ';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'ALTER TABLE gd_smtp ALTER login TYPE dname ';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex) '#13#10 +
          'VALUES ( '#13#10 +
          '  740925, '#13#10 +
          '  740000, '#13#10 +
          '  ''Почтовые сервера'', '#13#10 +
          '  ''SMTP'', '#13#10 +
          '  ''TgdcSMTP'', '#13#10 +
          '  NULL, '#13#10 +
          '  160 '#13#10 +
          ') '#13#10 +
          'MATCHING (id)';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

        DropConstraint2('gd_autotask', 'gd_chk_autotask_exporttype', FTransaction);
        FIBSQL.SQL.Text :=
          'ALTER TABLE gd_autotask ADD CONSTRAINT gd_chk_autotask_exporttype CHECK(emailexporttype IN (''DOC'', ''RTF'', ''XLS'', ''PDF'', ''XML'', ''TXT'', ''HTM'', ''ODS'', ''ODT'')) ';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text := 'UPDATE gd_documenttype SET classname = NULL WHERE id=807005';
        FIBSQL.ExecQuery;

        if not RelationExist2('GD_DOCUMENTTYPE_OPTION', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'CREATE TABLE gd_documenttype_option ( '#13#10 +
            '  id                    dintkey, '#13#10 +
            '  dtkey                 dintkey, '#13#10 +
            '  option_name           dname, '#13#10 +
            '  bool_value            dboolean, '#13#10 +
            '  str_value             dtext255, '#13#10 +
            '  relationkey           dforeignkey, '#13#10 +
            '  relationfieldkey      dforeignkey, '#13#10 +
            '  contactkey            dforeignkey, '#13#10 +
            '  disabled              ddisabled, '#13#10 +
            ' '#13#10 +
            '  CONSTRAINT gd_pk_dt_option PRIMARY KEY (id), '#13#10 +
            '  CONSTRAINT gd_fk_dt_option_dtkey FOREIGN KEY (dtkey) '#13#10 +
            '    REFERENCES gd_documenttype (id) '#13#10 +
            '    ON DELETE CASCADE '#13#10 +
            '    ON UPDATE CASCADE, '#13#10 +
            '  CONSTRAINT gd_fk_dt_option_relkey FOREIGN KEY (relationkey) '#13#10 +
            '    REFERENCES at_relations (id) '#13#10 +
            '    ON DELETE CASCADE '#13#10 +
            '    ON UPDATE CASCADE, '#13#10 +
            '  CONSTRAINT gd_fk_dt_option_relfkey FOREIGN KEY (relationfieldkey) '#13#10 +
            '    REFERENCES at_relation_fields (id) '#13#10 +
            '    ON DELETE CASCADE '#13#10 +
            '    ON UPDATE CASCADE, '#13#10 +
            '  CONSTRAINT gd_fk_dt_option_contactkey FOREIGN KEY (contactkey) '#13#10 +
            '    REFERENCES gd_contact (id) '#13#10 +
            '    ON DELETE CASCADE '#13#10 +
            '    ON UPDATE CASCADE, '#13#10 +
            '  CONSTRAINT gd_uq_dt_option UNIQUE (dtkey, option_name) '#13#10 +
            ')';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_bi_documenttype_option FOR gd_documenttype_option '#13#10 +
          '  BEFORE INSERT '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.ID IS NULL) THEN '#13#10 +
          '    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (222, ''0000.0001.0000.0253'', ''22.07.2015'', ''Modified GD_AUTOTASK and GD_SMTP tables.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (223, ''0000.0001.0000.0254'', ''03.08.2015'', ''Modified GD_AUTOTASK and GD_SMTP tables. Attempt #2'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (224, ''0000.0001.0000.0255'', ''09.08.2015'', ''SMTP servers command has been added to the Explorer.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (225, ''0000.0001.0000.0256'', ''17.08.2015'', ''Adjust some db fields.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (226, ''0000.0001.0000.0257'', ''20.08.2015'', ''Check constraint expanded.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (227, ''0000.0001.0000.0258'', ''31.08.2015'', ''GD_DOCUMENTTYPE_OPTION'') '#13#10 +
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