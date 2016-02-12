unit mdf_AddSendReport;
 
interface
 
uses
  IBDatabase, gdModify;

procedure ModifyAutoTaskAndSMTPTable(IBDB: TIBDatabase; Log: TModifyLog);

implementation
 
uses
  Classes, IBSQL, SysUtils, mdf_metadata_unit, gdcMetaData;

procedure ModifyAutoTaskAndSMTPTable(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL, q: TIBSQL;
  S: String;
  SL: TStringList;
begin
  SL := TStringList.Create;
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
        AddField2('gd_autotask', 'reload', 'dboolean', FTransaction);

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
          '  IF (NEW.reload <> 0) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.functionkey = NULL; '#13#10 +
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
          '  IF (NOT NEW.functionkey IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.autotrkey = NULL; '#13#10 +
          '    NEW.reportkey = NULL; '#13#10 +
          '    NEW.cmdline = NULL; '#13#10 +
          '    NEW.backupfile = NULL; '#13#10 +
          '    NEW.reload = 0; '#13#10 +
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
          '    NEW.reload = 0; '#13#10 +
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
          '    NEW.reload = 0; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NOT NEW.cmdline IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.functionkey = NULL; '#13#10 +
          '    NEW.autotrkey = NULL; '#13#10 +
          '    NEW.reportkey = NULL; '#13#10 +
          '    NEW.backupfile = NULL; '#13#10 +
          '    NEW.reload = 0; '#13#10 +
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
          '    NEW.reload = 0; '#13#10 +
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
          'ALTER TABLE gd_autotask ADD CONSTRAINT gd_chk_autotask_exporttype ' +
          'CHECK(emailexporttype IN (''DOC'', ''RTF'', ''XLS'', ''XLSX'', ''BIFF'', ' +
          ' ''PDF'', ''XML'', ''TXT'', ''HTM'', ''ODS'', ''ODT'', ''JPG'', ''BMP'', ''TIFF'')) ';
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
            '  relationfieldkey      dforeignkey, '#13#10 +
            '  contactkey            dforeignkey, '#13#10 +
            '  disabled              ddisabled, '#13#10 +
            ' '#13#10 +
            '  CONSTRAINT gd_pk_dt_option PRIMARY KEY (id), '#13#10 +
            '  CONSTRAINT gd_fk_dt_option_dtkey FOREIGN KEY (dtkey) '#13#10 +
            '    REFERENCES gd_documenttype (id) '#13#10 +
            '    ON DELETE CASCADE '#13#10 +
            '    ON UPDATE CASCADE, '#13#10 +
            '  CONSTRAINT gd_fk_dt_option_relfkey FOREIGN KEY (relationfieldkey) '#13#10 +
            '    REFERENCES at_relation_fields (id) '#13#10 +
            '    ON DELETE CASCADE '#13#10 +
            '    ON UPDATE CASCADE, '#13#10 +
            '  CONSTRAINT gd_fk_dt_option_contactkey FOREIGN KEY (contactkey) '#13#10 +
            '    REFERENCES gd_contact (id) '#13#10 +
            '    ON DELETE CASCADE '#13#10 +
            '    ON UPDATE CASCADE '#13#10 +
            ')';
          FIBSQL.ExecQuery;
        end else
        begin
          if not FieldExist2('GD_DOCUMENTTYPE_OPTION', 'EDITIONDATE', FTransaction) then
          begin
            FIBSQL.SQL.Text := 'DELETE FROM gd_documenttype_option';
            FIBSQL.ExecQuery;

            FTransaction.Commit;
            FTransaction.StartTransaction;
          end;
        end;

        AddField2('GD_DOCUMENTTYPE_OPTION', 'CURRKEY', 'dforeignkey', FTransaction);
        AddField2('GD_DOCUMENTTYPE_OPTION', 'EDITIONDATE', 'deditiondate', FTransaction);

        if not ConstraintExist2('GD_DOCUMENTTYPE_OPTION', 'GD_FK_DT_OPTION_CURRKEY', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_documenttype_option '#13#10 +
            'ADD CONSTRAINT gd_fk_dt_option_currkey FOREIGN KEY (currkey) '#13#10 +
            '  REFERENCES gd_curr (id) '#13#10 +
            '  ON DELETE CASCADE '#13#10 +
            '  ON UPDATE CASCADE';
          FIBSQL.ExecQuery;
        end;

        DropConstraint2('GD_DOCUMENTTYPE_OPTION', 'GD_UQ_DT_OPTION', FTransaction);
        DropConstraint2('GD_DOCUMENTTYPE_OPTION', 'GD_FK_DT_OPTION_RELKEY', FTransaction);

        FTransaction.Commit;
        FTransaction.StartTransaction;

        DropField2('GD_DOCUMENTTYPE_OPTION', 'STR_VALUE', FTransaction);
        DropField2('GD_DOCUMENTTYPE_OPTION', 'RELATIONKEY', FTransaction);

        FTransaction.Commit;
        FTransaction.StartTransaction;

        FIBSQL.SQL.Text :=
          'UPDATE gd_documenttype_option o ' +
          'SET o.editiondate = (SELECT t.editiondate FROM gd_documenttype t WHERE t.id = o.dtkey) ' +
          'WHERE o.editiondate IS NULL';
        FIBSQL.ExecQuery;

        if not ConstraintExist2('GD_DOCUMENTTYPE_OPTION', 'GD_UQ_DT_OPTION', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_documenttype_option ADD CONSTRAINT gd_uq_dt_option '#13#10 +
            'UNIQUE (dtkey, option_name, relationfieldkey, contactkey, currkey)';
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
          'CREATE OR ALTER TRIGGER gd_aiu_documenttype_option FOR gd_documenttype_option '#13#10 +
          '  AFTER INSERT OR UPDATE '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE I INTEGER = 0; '#13#10 +
          'BEGIN '#13#10 +
          '  IF (EXISTS( '#13#10 +
          '    SELECT '#13#10 +
          '      option_name, '#13#10 +
          '      COUNT(option_name) '#13#10 +
          '    FROM '#13#10 +
          '      gd_documenttype_option '#13#10 +
          '    WHERE '#13#10 +
          '      dtkey = NEW.dtkey AND bool_value IS NOT NULL '#13#10 +
          '    GROUP BY '#13#10 +
          '      option_name '#13#10 +
          '    HAVING '#13#10 +
          '      COUNT(option_name) > 1)) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    EXCEPTION gd_e_exception ''Duplicate boolean option name''; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (POSITION(''.'', NEW.option_name) > 0) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    IF (NEW.bool_value = 0) THEN '#13#10 +
          '      EXCEPTION gd_e_exception ''Invalid enum type value''; '#13#10 +
          ' '#13#10 +
          '    SELECT COUNT(*) FROM gd_documenttype_option '#13#10 +
          '    WHERE dtkey = NEW.dtkey '#13#10 +
          '      AND option_name STARTING WITH LEFT(NEW.option_name, CHARACTER_LENGTH(NEW.option_name) - POSITION(''.'', REVERSE(NEW.option_name)) + 1) '#13#10 +
          '      AND NEW.bool_value IS NOT NULL '#13#10 +
          '    INTO :I; '#13#10 +
          ' '#13#10 +
          '    IF (:I > 1) THEN '#13#10 +
          '      EXCEPTION gd_e_exception ''Multiple enum type values''; '#13#10 +
          '  END '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_ad_documenttype_option FOR gd_documenttype_option '#13#10 +
          '  ACTIVE '#13#10 +
          '  AFTER DELETE '#13#10 +
          '  POSITION 32000 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE xid  INTEGER = -1; '#13#10 +
          '  DECLARE VARIABLE dbid INTEGER = -1; '#13#10 +
          'BEGIN '#13#10 +
          '  FOR '#13#10 +
          '    SELECT xid, dbid FROM gd_ruid WHERE id = OLD.id '#13#10 +
          '    INTO :xid, :dbid '#13#10 +
          '  DO BEGIN '#13#10 +
          '    DELETE FROM at_object WHERE xid = :xid AND dbid = :dbid; '#13#10 +
          '    DELETE FROM gd_ruid WHERE id = OLD.id; '#13#10 +
          '  END '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_db_connect '#13#10 +
          '  ACTIVE '#13#10 +
          '  ON CONNECT '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE ingroup INTEGER = NULL; '#13#10 +
          '  DECLARE VARIABLE userkey INTEGER = NULL; '#13#10 +
          '  DECLARE VARIABLE contactkey INTEGER = NULL; '#13#10 +
          'BEGIN '#13#10 +
          '  SELECT FIRST 1 id, contactkey, ingroup '#13#10 +
          '  FROM gd_user '#13#10 +
          '  WHERE ibname = CURRENT_USER '#13#10 +
          '  INTO :userkey, :contactkey, :ingroup; '#13#10 +
          '  RDB$SET_CONTEXT(''USER_SESSION'', ''GD_USERKEY'', COALESCE(:userkey, 150001)); '#13#10 +
          '  RDB$SET_CONTEXT(''USER_SESSION'', ''GD_CONTACTKEY'', COALESCE(:contactkey, 650002)); '#13#10 +
          '  RDB$SET_CONTEXT(''USER_SESSION'', ''GD_INGROUP'', COALESCE(:ingroup, 0)); '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        AddField2('GD_JOURNAL', 'CLIENTADDRESS', 'CHAR(15)', FTransaction);

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_bi_journal2 FOR gd_journal '#13#10 +
          '  BEFORE INSERT '#13#10 +
          '  POSITION 2 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.operationdate IS NULL) THEN '#13#10 +
          '    NEW.operationdate = CURRENT_TIMESTAMP; '#13#10 +
          ' '#13#10 +
          '  IF (NEW.contactkey IS NULL) THEN '#13#10 +
          '    NEW.contactkey = RDB$GET_CONTEXT(''USER_SESSION'', ''GD_CONTACTKEY''); '#13#10 +
          ' '#13#10 +
          '  IF (NEW.clientaddress IS NULL) THEN '#13#10 +
          '    NEW.clientaddress = RDB$GET_CONTEXT(''SYSTEM'', ''CLIENT_ADDRESS''); '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'GRANT ALL ON GD_DOCUMENTTYPE_OPTION TO administrator';
        FIBSQL.ExecQuery;

        DropConstraint2('GD_OBJECT_DEPENDENCIES', 'GD_PK_OBJECT_DEPENDENCIES', FTransaction);

        if RelationExist2('GD_OBJECT_DEPENDENCIES', FTransaction) then
        begin
          FIBSQL.SQL.Text := 'DROP TABLE GD_OBJECT_DEPENDENCIES';
          FIBSQL.ExecQuery;

          FTransaction.Commit;
          FTransaction.StartTransaction;
        end;

        FIBSQL.SQL.Text :=
          'CREATE GLOBAL TEMPORARY TABLE gd_object_dependencies ( '#13#10 +
          '  sessionid         dintkey, '#13#10 +
          '  seqid             dintkey, '#13#10 +
          '  masterid          dintkey, '#13#10 +
          '  reflevel          dinteger_notnull, '#13#10 +
          '  relationname      dtablename NOT NULL, '#13#10 +
          '  fieldname         dfieldname NOT NULL, '#13#10 +
          '  crossrelation     dboolean_notnull, '#13#10 +
          '  refobjectid       dintkey, '#13#10 +
          '  refobjectname     dname, '#13#10 +
          '  refrelationname   dname, '#13#10 +
          '  refclassname      dname, '#13#10 +
          '  refsubtype        dname, '#13#10 +
          '  refeditiondate    TIMESTAMP, '#13#10 +
          ' '#13#10 +
          '  CONSTRAINT gd_pk_object_dependencies PRIMARY KEY (sessionid, seqid) '#13#10 +
          ') '#13#10 +
          '  ON COMMIT DELETE ROWS ';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text := 'GRANT ALL ON gd_object_dependencies TO administrator';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_biu_people_pn FOR gd_people '#13#10 +
          '  ACTIVE '#13#10 +
          '  BEFORE INSERT OR UPDATE '#13#10 +
          '  POSITION 32000 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (CHAR_LENGTH(NEW.personalnumber) > 0 '#13#10 +
          '    AND (INSERTING OR NEW.personalnumber IS DISTINCT FROM OLD.personalnumber)) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.personalnumber = UPPER(TRIM(NEW.personalnumber)); '#13#10 +
          '    NEW.personalnumber = '#13#10 +
          '      REPLACE( '#13#10 +
          '        REPLACE( '#13#10 +
          '          REPLACE( '#13#10 +
          '            REPLACE( '#13#10 +
          '              REPLACE( '#13#10 +
          '                REPLACE( '#13#10 +
          '                  REPLACE( '#13#10 +
          '                    REPLACE( '#13#10 +
          '                      REPLACE( '#13#10 +
          '                        REPLACE( '#13#10 +
          '                          REPLACE( '#13#10 +
          '                            NEW.personalnumber, '#13#10 +
          '                            ''Х'', ''X''), '#13#10 +
          '                          ''Т'', ''T''), '#13#10 +
          '                        ''С'', ''C''), '#13#10 +
          '                      ''Р'', ''P''), '#13#10 +
          '                    ''О'', ''O''), '#13#10 +
          '                  ''Н'', ''H''), '#13#10 +
          '                ''М'', ''M''), '#13#10 +
          '              ''К'', ''K''), '#13#10 +
          '            ''Е'', ''E''), '#13#10 +
          '          ''А'', ''A''), '#13#10 +
          '        ''В'', ''B''); '#13#10 +
          '  END '#13#10 +
          '   '#13#10 +
          '  IF (CHAR_LENGTH(NEW.passportnumber) > 0 '#13#10 +
          '    AND (INSERTING OR NEW.passportnumber IS DISTINCT FROM OLD.passportnumber)) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.passportnumber = UPPER(TRIM(NEW.passportnumber)); '#13#10 +
          '    NEW.passportnumber = '#13#10 +
          '      REPLACE( '#13#10 +
          '        REPLACE( '#13#10 +
          '          REPLACE( '#13#10 +
          '            REPLACE( '#13#10 +
          '              REPLACE( '#13#10 +
          '                REPLACE( '#13#10 +
          '                  REPLACE( '#13#10 +
          '                    REPLACE( '#13#10 +
          '                      REPLACE( '#13#10 +
          '                        REPLACE( '#13#10 +
          '                          REPLACE( '#13#10 +
          '                            NEW.passportnumber, '#13#10 +
          '                            ''Х'', ''X''), '#13#10 +
          '                          ''Т'', ''T''), '#13#10 +
          '                        ''С'', ''C''), '#13#10 +
          '                      ''Р'', ''P''), '#13#10 +
          '                    ''О'', ''O''), '#13#10 +
          '                  ''Н'', ''H''), '#13#10 +
          '                ''М'', ''M''), '#13#10 +
          '              ''К'', ''K''), '#13#10 +
          '            ''Е'', ''E''), '#13#10 +
          '          ''А'', ''A''), '#13#10 +
          '        ''В'', ''B''); '#13#10 +
          '  END '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          ' CREATE OR ALTER TRIGGER at_ad_namespace FOR at_namespace '#13#10 +
          '   ACTIVE '#13#10 +
          '   AFTER DELETE '#13#10 +
          '   POSITION 0 '#13#10 +
          ' AS '#13#10 +
          ' BEGIN '#13#10 +
          '   DELETE FROM gd_ruid WHERE id = OLD.id; '#13#10 +
          ' END';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER at_aiud_object FOR at_object '#13#10 +
          '  ACTIVE '#13#10 +
          '  AFTER INSERT OR UPDATE OR DELETE '#13#10 +
          '  POSITION 20000 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (INSERTING) THEN '#13#10 +
          '    UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0 '#13#10 +
          '      AND n.id = NEW.namespacekey; '#13#10 +
          ' '#13#10 +
          '  IF (DELETING) THEN '#13#10 +
          '    UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0 '#13#10 +
          '      AND n.id = OLD.namespacekey; '#13#10 +
          ' '#13#10 +
          '  IF (UPDATING) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    IF (NEW.namespacekey <> OLD.namespacekey) THEN '#13#10 +
          '      UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0 '#13#10 +
          '        AND n.id IN (NEW.namespacekey, OLD.namespacekey); '#13#10 +
          ' '#13#10 +
          '    IF (NEW.objectname <> OLD.objectname '#13#10 +
          '      OR NEW.objectclass <> OLD.objectclass '#13#10 +
          '      OR NEW.subtype IS DISTINCT FROM OLD.subtype '#13#10 +
          '      OR NEW.xid <> OLD.xid '#13#10 +
          '      OR NEW.dbid <> OLD.dbid '#13#10 +
          '      OR NEW.objectpos IS DISTINCT FROM OLD.objectpos '#13#10 +
          '      OR NEW.alwaysoverwrite <> OLD.alwaysoverwrite '#13#10 +
          '      OR NEW.dontremove <> OLD.dontremove '#13#10 +
          '      OR NEW.includesiblings <> OLD.includesiblings '#13#10 +
          '      OR NEW.headobjectkey IS DISTINCT FROM OLD.headobjectkey '#13#10 +
          '      OR NEW.modified IS DISTINCT FROM OLD.modified '#13#10 +
          '      OR NEW.curr_modified IS DISTINCT FROM OLD.curr_modified) THEN '#13#10 +
          '    BEGIN '#13#10 +
          '      UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0 '#13#10 +
          '        AND n.id = NEW.namespacekey; '#13#10 +
          '    END '#13#10 +
          '  END '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER at_bi_object FOR at_object '#13#10 +
          '  ACTIVE '#13#10 +
          '  BEFORE INSERT '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.id IS NULL) THEN '#13#10 +
          '    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1); '#13#10 +
          ' '#13#10 +
          '  IF ((NEW.xid < 147000000 AND NEW.dbid <> 17) OR '#13#10 +
          '    (NEW.xid >= 147000000 AND NOT EXISTS(SELECT * FROM gd_ruid '#13#10 +
          '      WHERE xid = NEW.xid AND dbid = NEW.dbid))) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    EXCEPTION gd_e_invalid_ruid ''Invalid ruid. XID = '' || '#13#10 +
          '      NEW.xid || '', DBID = '' || NEW.dbid || ''.''; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NEW.objectpos IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    SELECT MAX(objectpos) '#13#10 +
          '    FROM at_object '#13#10 +
          '    WHERE namespacekey = NEW.namespacekey '#13#10 +
          '    INTO NEW.objectpos; '#13#10 +
          '    NEW.objectpos = COALESCE(NEW.objectpos, 0) + 1; '#13#10 +
          '  END ELSE '#13#10 +
          '  BEGIN '#13#10 +
          '    IF (EXISTS(SELECT * FROM at_object WHERE objectpos = NEW.objectpos '#13#10 +
          '      AND namespacekey = NEW.namespacekey)) THEN '#13#10 +
          '    BEGIN '#13#10 +
          '      UPDATE at_object SET objectpos = objectpos + 1 '#13#10 +
          '        WHERE objectpos >= NEW.objectpos AND namespacekey = NEW.namespacekey; '#13#10 +
          '    END '#13#10 +
          '  END '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        DropTrigger2('at_au_object', FTransaction);

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER at_bu_object FOR at_object '#13#10 +
          '  ACTIVE '#13#10 +
          '  BEFORE UPDATE '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE depend_id dintkey; '#13#10 +
          '  DECLARE VARIABLE p INTEGER; '#13#10 +
          '  DECLARE VARIABLE hopos INTEGER; '#13#10 +
          'BEGIN '#13#10 +
          '  IF ((NEW.xid < 147000000 AND NEW.dbid <> 17) OR '#13#10 +
          '    (NEW.xid >= 147000000 AND NOT EXISTS(SELECT * FROM gd_ruid '#13#10 +
          '      WHERE xid = NEW.xid AND dbid = NEW.dbid))) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    EXCEPTION gd_e_invalid_ruid ''Invalid ruid. XID = '' || '#13#10 +
          '      NEW.xid || '', DBID = '' || NEW.dbid || ''.''; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NEW.namespacekey <> OLD.namespacekey) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    IF (COALESCE(RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AT_OBJECT_LOCK''), 0) = 0) THEN '#13#10 +
          '    BEGIN '#13#10 +
          '      IF (NEW.objectpos IS DISTINCT FROM OLD.objectpos) THEN '#13#10 +
          '        EXCEPTION gd_e_exception ''Can not change object position and namespace simultaneously.''; '#13#10 +
          ' '#13#10 +
          '      IF (NEW.headobjectkey IS DISTINCT FROM OLD.headobjectkey) THEN '#13#10 +
          '        EXCEPTION gd_e_exception ''Can not change head object and namespace simultaneously.''; '#13#10 +
          ' '#13#10 +
          '      IF (NEW.headobjectkey IS NOT NULL) THEN '#13#10 +
          '      BEGIN '#13#10 +
          '        SELECT objectpos '#13#10 +
          '        FROM at_object '#13#10 +
          '        WHERE id = NEW.headobjectkey '#13#10 +
          '        INTO :hopos; '#13#10 +
          ' '#13#10 +
          '        IF (:hopos > NEW.objectpos) THEN '#13#10 +
          '        BEGIN '#13#10 +
          '          /* prevent cycling */ '#13#10 +
          '          DELETE FROM at_namespace_link '#13#10 +
          '          WHERE namespacekey = NEW.namespacekey AND useskey = OLD.namespacekey; '#13#10 +
          ' '#13#10 +
          '          /* transfer links from old to new */ '#13#10 +
          '          MERGE INTO at_namespace_link AS l '#13#10 +
          '          USING (SELECT useskey FROM at_namespace_link '#13#10 +
          '            WHERE namespacekey = OLD.namespacekey AND useskey <> NEW.namespacekey) AS u '#13#10 +
          '          ON l.namespacekey = NEW.namespacekey AND l.useskey = u.useskey '#13#10 +
          '          WHEN NOT MATCHED THEN INSERT (namespacekey, useskey) VALUES (NEW.namespacekey, u.useskey); '#13#10 +
          ' '#13#10 +
          '          /* setup link from old to new */ '#13#10 +
          '          UPDATE OR INSERT INTO at_namespace_link (namespacekey, useskey) '#13#10 +
          '          VALUES (OLD.namespacekey, NEW.namespacekey) '#13#10 +
          '            MATCHING (namespacekey, useskey); '#13#10 +
          '        END '#13#10 +
          '        ELSE IF (:hopos < NEW.objectpos) THEN '#13#10 +
          '        BEGIN '#13#10 +
          '          UPDATE OR INSERT INTO at_namespace_link (namespacekey, useskey) '#13#10 +
          '          VALUES (NEW.namespacekey, OLD.namespacekey) '#13#10 +
          '            MATCHING (namespacekey, useskey); '#13#10 +
          '        END '#13#10 +
          ' '#13#10 +
          '        NEW.headobjectkey = NULL; '#13#10 +
          '      END '#13#10 +
          '    END '#13#10 +
          ' '#13#10 +
          '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AT_OBJECT_LOCK'', '#13#10 +
          '      COALESCE(CAST(RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AT_OBJECT_LOCK'') AS INTEGER), 0) + 1); '#13#10 +
          ' '#13#10 +
          '    FOR '#13#10 +
          '      SELECT id '#13#10 +
          '      FROM at_object '#13#10 +
          '      WHERE (headobjectkey = NEW.id OR id = NEW.id) '#13#10 +
          '        AND namespacekey = OLD.namespacekey '#13#10 +
          '      ORDER BY objectpos '#13#10 +
          '      INTO :depend_id '#13#10 +
          '    DO BEGIN '#13#10 +
          '      p = NULL; '#13#10 +
          '      SELECT MAX(objectpos) '#13#10 +
          '      FROM at_object '#13#10 +
          '      WHERE namespacekey = NEW.namespacekey '#13#10 +
          '      INTO :p; '#13#10 +
          '      p = COALESCE(:p, 0) + 1; '#13#10 +
          ' '#13#10 +
          '      IF (:depend_id = NEW.id) THEN '#13#10 +
          '      BEGIN '#13#10 +
          '        NEW.objectpos = :p; '#13#10 +
          '      END ELSE '#13#10 +
          '      BEGIN '#13#10 +
          '        UPDATE at_object SET namespacekey = NEW.namespacekey, objectpos = :p '#13#10 +
          '          WHERE id = :depend_id; '#13#10 +
          '      END '#13#10 +
          '    END '#13#10 +
          ' '#13#10 +
          '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AT_OBJECT_LOCK'', '#13#10 +
          '      CAST(RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AT_OBJECT_LOCK'') AS INTEGER) - 1); '#13#10 +
          '  END '#13#10 +
          '  ELSE IF (NEW.objectpos IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    SELECT MAX(objectpos) '#13#10 +
          '    FROM at_object '#13#10 +
          '    WHERE namespacekey = NEW.namespacekey '#13#10 +
          '    INTO NEW.objectpos; '#13#10 +
          '    NEW.objectpos = COALESCE(NEW.objectpos, 0) + 1; '#13#10 +
          '  END '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        FTransaction.Commit;
        FTransaction.StartTransaction;

        AlterTriggers(GetActiveTriggers('GD_PEOPLE', SL, FTransaction), False, FTransaction);

        FIBSQL.SQL.Text :=
          'UPDATE gd_people SET personalnumber = '' '' || personalnumber, passportnumber = '' '' || passportnumber ' +
          'WHERE personalnumber IS NOT NULL OR passportnumber IS NOT NULL';
        FIBSQL.ExecQuery;

        AlterTriggers(SL, True, FTransaction);

        // turn off the trigger so setting missed modify dates
        // will not affect at_namespace CHANGED state

        FIBSQL.SQL.Text :=
          'ALTER TRIGGER at_aiud_object INACTIVE';
        FIBSQL.ExecQuery;

        FTransaction.Commit;
        FTransaction.StartTransaction;

        // add EDITIONDATE field into prime tables
        // (user reference without additional system fields)

        while True do
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'select '#13#10 +
            '  r.RDB$RELATION_NAME '#13#10 +
            'from '#13#10 +
            '  RDB$RELATIONS r '#13#10 +
            '  JOIN RDB$RELATION_FIELDS rfs ON rfs.RDB$RELATION_NAME = r.RDB$RELATION_NAME AND rfs.RDB$FIELD_NAME = ''ID'' '#13#10 +
            '  JOIN RDB$FIELDS f ON f.RDB$FIELD_NAME = rfs.RDB$FIELD_SOURCE AND f.RDB$FIELD_NAME = ''DINTKEY'' '#13#10 +
            'where '#13#10 +
            '  (not exists (select * from RDB$RELATION_FIELDS rf '#13#10 +
            '    where rf.RDB$RELATION_NAME = r.RDB$RELATION_NAME and rf.RDB$FIELD_NAME = ''EDITORKEY'')) '#13#10 +
            'and '#13#10 +
            '  (not exists (select * from RDB$RELATION_FIELDS rf '#13#10 +
            '    where rf.RDB$RELATION_NAME = r.RDB$RELATION_NAME and rf.RDB$FIELD_NAME = ''EDITIONDATE'')) '#13#10 +
            'and '#13#10 +
            '  (not exists (select * from RDB$RELATION_FIELDS rf '#13#10 +
            '    where rf.RDB$RELATION_NAME = r.RDB$RELATION_NAME and rf.RDB$FIELD_NAME = ''DOCUMENTKEY'')) '#13#10 +
            'and '#13#10 +
            '  (not exists (select * from RDB$RELATION_FIELDS rf '#13#10 +
            '    where rf.RDB$RELATION_NAME = r.RDB$RELATION_NAME and rf.RDB$FIELD_NAME = ''INHERITEDKEY'')) '#13#10 +
            'and '#13#10 +
            '  r.RDB$RELATION_NAME LIKE ''USR$%'' '#13#10 +
            'and '#13#10 +
            '  not r.RDB$RELATION_NAME LIKE ''USR$CROSS%'' '#13#10 +
            'and '#13#10 +
            '  r.RDB$VIEW_BLR IS NULL';
          FIBSQL.ExecQuery;

          if FIBSQL.EOF then
            break;

          S := FIBSQL.FieldByName('RDB$RELATION_NAME').AsTrimString;

          FIBSQL.Close;

          FIBSQL.SQL.Text := 'ALTER TABLE ' + S + ' ADD editiondate deditiondate';
          FIBSQL.ExecQuery;

          FTransaction.Commit;
          FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'MERGE INTO at_object o '#13#10 +
            '   USING (SELECT r.xid, r.dbid FROM gd_ruid r JOIN ' + S + ' t ON t.id = r.id '#13#10 +
            '     WHERE t.editiondate IS NULL) s '#13#10 +
            '   ON o.xid = s.xid AND o.dbid = s.dbid '#13#10 +
            '   WHEN MATCHED THEN '#13#10 +
            '     UPDATE SET modified = ''25.03.1918'', curr_modified = ''25.03.1918''';
          FIBSQL.ExecQuery;

          AlterTriggers(GetActiveTriggers(S, SL, FTransaction), False, FTransaction);

          FIBSQL.SQL.Text :=
            'UPDATE ' + S + ' SET editiondate = ''25.03.1918'' WHERE editiondate IS NULL';
          FIBSQL.ExecQuery;

          AlterTriggers(SL, True, FTransaction);
        end;

        // recreate triggers for Prime tables

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'select '#13#10 +
          '  r.RDB$RELATION_NAME '#13#10 +
          'from '#13#10 +
          '  RDB$RELATIONS r '#13#10 +
          '  JOIN RDB$RELATION_FIELDS rfs ON rfs.RDB$RELATION_NAME = r.RDB$RELATION_NAME AND rfs.RDB$FIELD_NAME = ''ID'' '#13#10 +
          '  JOIN RDB$FIELDS f ON f.RDB$FIELD_NAME = rfs.RDB$FIELD_SOURCE AND f.RDB$FIELD_NAME = ''DINTKEY'' '#13#10 +
          'where '#13#10 +
          '  (not exists (select * from RDB$RELATION_FIELDS rf '#13#10 +
          '    where rf.RDB$RELATION_NAME = r.RDB$RELATION_NAME and rf.RDB$FIELD_NAME = ''EDITORKEY'')) '#13#10 +
          'and '#13#10 +
          '  (exists (select * from RDB$RELATION_FIELDS rf '#13#10 +
          '    where rf.RDB$RELATION_NAME = r.RDB$RELATION_NAME and rf.RDB$FIELD_NAME = ''EDITIONDATE'')) '#13#10 +
          'and '#13#10 +
          '  (not exists (select * from RDB$RELATION_FIELDS rf '#13#10 +
          '    where rf.RDB$RELATION_NAME = r.RDB$RELATION_NAME and rf.RDB$FIELD_NAME = ''DOCUMENTKEY'')) '#13#10 +
          'and '#13#10 +
          '  (not exists (select * from RDB$RELATION_FIELDS rf '#13#10 +
          '    where rf.RDB$RELATION_NAME = r.RDB$RELATION_NAME and rf.RDB$FIELD_NAME = ''INHERITEDKEY'')) '#13#10 +
          'and '#13#10 +
          '  r.RDB$RELATION_NAME LIKE ''USR$%'' '#13#10 +
          'and '#13#10 +
          '  not r.RDB$RELATION_NAME LIKE ''USR$CROSS%'' '#13#10 +
          'and '#13#10 +
          '  r.RDB$VIEW_BLR IS NULL';
        FIBSQL.ExecQuery;
        while not FIBSQL.EOF do
        begin
          S := FIBSQL.FieldByName('RDB$RELATION_NAME').AsTrimString;

          q := TIBSQL.Create(nil);
          try
            q.Transaction := FTransaction;

            q.SQL.Text := TgdcPrimeTable.CreateInsertEditorTrigger(S);
            q.ExecQuery;

            q.SQL.Text := TgdcPrimeTable.CreateUpdateEditorTrigger(S);
            q.ExecQuery;
          finally
            q.Free;
          end;

          FIBSQL.Next;
        end;

        // recreate triggers for Simple tables

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'select '#13#10 +
          '  r.RDB$RELATION_NAME '#13#10 +
          'from '#13#10 +
          '  RDB$RELATIONS r '#13#10 +
          '  JOIN RDB$RELATION_FIELDS rfs ON rfs.RDB$RELATION_NAME = r.RDB$RELATION_NAME AND rfs.RDB$FIELD_NAME = ''ID'' '#13#10 +
          '  JOIN RDB$FIELDS f ON f.RDB$FIELD_NAME = rfs.RDB$FIELD_SOURCE AND f.RDB$FIELD_NAME = ''DINTKEY'' '#13#10 +
          'where '#13#10 +
          '  (exists (select * from RDB$RELATION_FIELDS rf '#13#10 +
          '    where rf.RDB$RELATION_NAME = r.RDB$RELATION_NAME and rf.RDB$FIELD_NAME = ''EDITORKEY'')) '#13#10 +
          'and '#13#10 +
          '  (exists (select * from RDB$RELATION_FIELDS rf '#13#10 +
          '    where rf.RDB$RELATION_NAME = r.RDB$RELATION_NAME and rf.RDB$FIELD_NAME = ''EDITIONDATE'')) '#13#10 +
          'and '#13#10 +
          '  (not exists (select * from RDB$RELATION_FIELDS rf '#13#10 +
          '    where rf.RDB$RELATION_NAME = r.RDB$RELATION_NAME and rf.RDB$FIELD_NAME = ''DOCUMENTKEY'')) '#13#10 +
          'and '#13#10 +
          '  (not exists (select * from RDB$RELATION_FIELDS rf '#13#10 +
          '    where rf.RDB$RELATION_NAME = r.RDB$RELATION_NAME and rf.RDB$FIELD_NAME = ''INHERITEDKEY'')) '#13#10 +
          'and '#13#10 +
          '  r.RDB$RELATION_NAME LIKE ''USR$%'' '#13#10 +
          'and '#13#10 +
          '  not r.RDB$RELATION_NAME LIKE ''USR$CROSS%'' '#13#10 +
          'and '#13#10 +
          '  r.RDB$VIEW_BLR IS NULL';
        FIBSQL.ExecQuery;
        while not FIBSQL.EOF do
        begin
          S := FIBSQL.FieldByName('RDB$RELATION_NAME').AsTrimString;

          q := TIBSQL.Create(nil);
          try
            q.Transaction := FTransaction;

            q.SQL.Text := TgdcSimpleTable.CreateInsertEditorTrigger(S);
            q.ExecQuery;

            q.SQL.Text := TgdcSimpleTable.CreateUpdateEditorTrigger(S);
            q.ExecQuery;
          finally
            q.Free;
          end;

          FIBSQL.Next;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'ALTER TRIGGER at_aiud_object ACTIVE';
        FIBSQL.ExecQuery;

        FTransaction.Commit;
        FTransaction.StartTransaction;

        DropTrigger2('at_ai_relation_field', FTransaction);
        DropTrigger2('at_au_relation_field', FTransaction);
        DropTrigger2('at_ad_relation_field', FTransaction);
        DropTrigger2('at_bu_rf', FTransaction);

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER at_aiud_relation_field FOR at_relation_fields '#13#10 +
          '  AFTER INSERT OR UPDATE OR DELETE '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE VERSION INTEGER; '#13#10 +
          'BEGIN '#13#10 +
          '  VERSION = GEN_ID(gd_g_attr_version, 1); '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER at_biu_rf FOR at_relation_fields '#13#10 +
          '  BEFORE INSERT OR UPDATE '#13#10 +
          '  POSITION 1000 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  SELECT relationname FROM at_relations WHERE id = NEW.relationkey '#13#10 +
          '  INTO NEW.relationname; '#13#10 +
          ' '#13#10 +
          '  IF (NEW.crossfield = '''') THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.crossfield = NULL; '#13#10 +
          '    NEW.editiondate = CURRENT_TIMESTAMP(0); '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NEW.crosstable = '''') THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.crosstable = NULL; '#13#10 +
          '    NEW.editiondate = CURRENT_TIMESTAMP(0); '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  NEW.objects = TRIM(NEW.objects);'#13#10 +
          ' '#13#10 +
          '  IF (NEW.objects = '''' OR NEW.objects LIKE ''TgdcBase%'' OR NEW.objects LIKE ''(Blob)%'') THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.objects = NULL; '#13#10 +
          '    NEW.editiondate = CURRENT_TIMESTAMP(0); '#13#10 +
          '  END '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER rp_ad_reportlist FOR rp_reportlist '#13#10 +
          '  ACTIVE '#13#10 +
          '  AFTER DELETE '#13#10 +
          '  POSITION 32000 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE RUID VARCHAR(21) = NULL; '#13#10 +
          'BEGIN '#13#10 +
          '  SELECT xid || ''_'' || dbid '#13#10 +
          '  FROM gd_ruid '#13#10 +
          '  WHERE id = OLD.id '#13#10 +
          '  INTO :RUID; '#13#10 +
          ' '#13#10 +
          '  IF (COALESCE(:RUID, '''') <> '''') THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    DELETE FROM gd_command WHERE cmdtype = 2 AND cmd = :RUID; '#13#10 +
          '  END '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_au_ruid FOR gd_ruid '#13#10 +
          '  ACTIVE '#13#10 +
          '  AFTER UPDATE '#13#10 +
          '  POSITION 32000 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.xid <> OLD.xid OR NEW.dbid <> OLD.dbid) THEN '#13#10 +
          '    UPDATE at_object SET xid = NEW.xid, dbid = NEW.dbid '#13#10 +
          '      WHERE xid = OLD.xid AND dbid = OLD.dbid; '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_aiu_documenttype FOR gd_documenttype '#13#10 +
          '  ACTIVE '#13#10 +
          '  AFTER INSERT OR UPDATE '#13#10 +
          '  POSITION 20001 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE P INTEGER; '#13#10 +
          '  DECLARE VARIABLE XID INTEGER; '#13#10 +
          '  DECLARE VARIABLE DBID INTEGER; '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.documenttype = ''B'') THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    IF (EXISTS (SELECT * FROM gd_documenttype WHERE documenttype <> ''B'' AND id = NEW.parent)) THEN '#13#10 +
          '      EXCEPTION gd_e_exception ''Document class can not include a folder.''; '#13#10 +
          '  END ELSE '#13#10 +
          '  BEGIN '#13#10 +
          '    IF ((INSERTING OR (NEW.ruid <> OLD.ruid)) '#13#10 +
          '      AND (NEW.ruid SIMILAR TO ''([[:DIGIT:]]{9,10}\_[[:DIGIT:]]+)|([[:DIGIT:]]+\_17)'' ESCAPE ''\'')) THEN '#13#10 +
          '    BEGIN '#13#10 +
          '      P = POSITION(''_'' IN NEW.ruid); '#13#10 +
          '      XID = LEFT(NEW.ruid, :P - 1); '#13#10 +
          '      DBID = RIGHT(NEW.ruid, CHAR_LENGTH(NEW.ruid) - :P); '#13#10 +
          ' '#13#10 +
          '      UPDATE OR INSERT INTO gd_ruid (id, xid, dbid, modified, editorkey) '#13#10 +
          '      VALUES (NEW.id, :XID, :DBID, NEW.editiondate, RDB$GET_CONTEXT(''USER_SESSION'', ''GD_CONTACTKEY'')) '#13#10 +
          '      MATCHING(id); '#13#10 +
          '    END '#13#10 +
          '  END '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER at_aiu_namespace_link FOR at_namespace_link '#13#10 +
          '  ACTIVE '#13#10 +
          '  AFTER INSERT OR UPDATE '#13#10 +
          '  POSITION 20001 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (EXISTS( '#13#10 +
          '    WITH RECURSIVE tree AS '#13#10 +
          '    ( '#13#10 +
          '      SELECT '#13#10 +
          '        namespacekey AS initial, namespacekey, useskey '#13#10 +
          '      FROM '#13#10 +
          '        at_namespace_link '#13#10 +
          '      WHERE '#13#10 +
          '        namespacekey = NEW.namespacekey AND useskey = NEW.useskey '#13#10 +
          ' '#13#10 +
          '      UNION ALL '#13#10 +
          ' '#13#10 +
          '      SELECT '#13#10 +
          '        IIF(tr.initial <> tt.namespacekey, tr.initial, -1) AS initial, '#13#10 +
          '        tt.namespacekey, '#13#10 +
          '        tt.useskey '#13#10 +
          '      FROM '#13#10 +
          '        at_namespace_link tt JOIN tree tr ON '#13#10 +
          '          tr.useskey = tt.namespacekey AND tr.initial > 0 '#13#10 +
          ' '#13#10 +
          '    ) '#13#10 +
          '    SELECT * FROM tree WHERE initial = -1)) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    EXCEPTION gd_e_exception ''Обнаружена циклическая зависимость ПИ.''; '#13#10 +
          '  END '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_aiu_companyaccount FOR gd_companyaccount '#13#10 +
          '  AFTER INSERT OR UPDATE '#13#10 +
          '  POSITION 30000 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (EXISTS( '#13#10 +
          '    SELECT '#13#10 +
          '      b.bankcode, b.bankbranch, a.account, COUNT(*) '#13#10 +
          '    FROM '#13#10 +
          '      gd_companyaccount a JOIN gd_bank b '#13#10 +
          '        ON b.bankkey = a.bankkey '#13#10 +
          '    WHERE '#13#10 +
          '      a.account = NEW.account '#13#10 +
          '    GROUP BY '#13#10 +
          '      b.bankcode, b.bankbranch, a.account '#13#10 +
          '    HAVING '#13#10 +
          '      COUNT(*) > 1)) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    EXCEPTION gd_e_exception ''Дублируется номер банковского счета!''; '#13#10 +
          '  END '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        FTransaction.Commit;
        FTransaction.StartTransaction;

        FIBSQL.SQL.Text :=
          'EXECUTE BLOCK '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE RUID VARCHAR(21); '#13#10 +
          '  DECLARE VARIABLE XID INTEGER; '#13#10 +
          '  DECLARE VARIABLE DBID INTEGER; '#13#10 +
          '  DECLARE VARIABLE DOC_XID INTEGER; '#13#10 +
          '  DECLARE VARIABLE DOC_DBID INTEGER; '#13#10 +
          '  DECLARE VARIABLE P INTEGER; '#13#10 +
          '  DECLARE VARIABLE ID INTEGER; '#13#10 +
          'BEGIN '#13#10 +
          '  FOR '#13#10 +
          '    SELECT '#13#10 +
          '      t.id, t.ruid, r.xid, r.dbid '#13#10 +
          '    FROM gd_documenttype t JOIN gd_ruid r '#13#10 +
          '      ON r.id = t.id '#13#10 +
          '    WHERE '#13#10 +
          '      t.ruid <> r.xid || ''_'' || r.dbid '#13#10 +
          '      AND POSITION(''_'' IN t.ruid) > 0 '#13#10 +
          '    INTO '#13#10 +
          '      :ID, :RUID, :XID, :DBID '#13#10 +
          '  DO BEGIN '#13#10 +
          '    P = POSITION(''_'' IN :RUID); '#13#10 +
          '    DOC_XID = LEFT(:RUID, :P - 1); '#13#10 +
          '    DOC_DBID = RIGHT(:RUID, CHARACTER_LENGTH(:RUID) - :P); '#13#10 +
          ''#13#10 +
          '    DELETE FROM gd_ruid WHERE id <> :ID '#13#10 +
          '      AND xid = :DOC_XID AND dbid = :DOC_DBID;'#13#10 +
          '    UPDATE gd_ruid SET xid = :DOC_XID, '#13#10 +
          '      dbid = :DOC_DBID '#13#10 +
          '    WHERE '#13#10 +
          '      id = :ID; '#13#10 +
          '  END '#13#10 +
          'END';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_au_documenttype FOR gd_documenttype '#13#10 +
          '  ACTIVE '#13#10 +
          '  AFTER UPDATE '#13#10 +
          '  POSITION 20000 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE new_root INTEGER = NULL; '#13#10 +
          '  DECLARE VARIABLE old_root INTEGER = NULL; '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.parent IS DISTINCT FROM OLD.parent) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    SELECT id FROM gd_documenttype '#13#10 +
          '    WHERE parent IS NULL AND lb <= NEW.lb AND rb >= NEW.rb '#13#10 +
          '    INTO :new_root; '#13#10 +
          ' '#13#10 +
          '    SELECT id FROM gd_documenttype '#13#10 +
          '    WHERE parent IS NULL AND lb <= OLD.lb AND rb >= OLD.rb '#13#10 +
          '    INTO :old_root; '#13#10 +
          ' '#13#10 +
          '    IF (:new_root <> :old_root) THEN '#13#10 +
          '    BEGIN '#13#10 +
          '      IF (:new_root IN (804000, 805000) OR :old_root IN (804000, 805000)) THEN '#13#10 +
          '        EXCEPTION gd_e_cannotchangebranch; '#13#10 +
          '    END '#13#10 +
          ' '#13#10 +
          '    IF (NEW.documenttype = ''B'') THEN '#13#10 +
          '    BEGIN '#13#10 +
          '      IF (EXISTS (SELECT * FROM gd_documenttype WHERE documenttype <> ''B'' AND id = NEW.parent)) THEN '#13#10 +
          '        EXCEPTION gd_e_exception ''Document class can not include a folder.''; '#13#10 +
          '    END '#13#10 +
          '  END '#13#10 +
          'END';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

        FIBSQL.SQL.Text :=
          'UPDATE at_relation_fields '#13#10 +
          '  SET objects = NULL, editiondate = CURRENT_TIMESTAMP(0) '#13#10 +
          '  WHERE objects = '''' OR objects LIKE ''TgdcBase%'' OR objects LIKE ''(Blob)%'' ';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

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
        FIBSQL.Close;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (228, ''0000.0001.0000.0259'', ''02.09.2015'', ''Correction for GD_DOCUMENTTYPE_OPTION'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (229, ''0000.0001.0000.0260'', ''04.09.2015'', ''Correction for GD_DOCUMENTTYPE_OPTION #2'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (230, ''0000.0001.0000.0261'', ''01.10.2015'', ''Correction for GD_DOCUMENTTYPE_OPTION #3'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (231, ''0000.0001.0000.0262'', ''20.10.2015'', ''Client address is added to GD_JOURNAL.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (232, ''0000.0001.0000.0263'', ''23.10.2015'', ''Edition date to GD_DOCUMENTTYPE_OPTION.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (233, ''0000.0001.0000.0264'', ''09.11.2015'', ''XLSX type added.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (234, ''0000.0001.0000.0265'', ''14.11.2015'', ''Added Reload auto task.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (235, ''0000.0001.0000.0266'', ''27.11.2015'', ''Added seqid field to gd_object_dependencies table.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (236, ''0000.0001.0000.0267'', ''02.12.2015'', ''https://github.com/GoldenSoftwareLtd/GedeminSalary/issues/208'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (237, ''0000.0001.0000.0268'', ''20.12.2015'', ''Delete a record from GD_RUID when deleting AT_NAMESPACE.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (238, ''0000.0001.0000.0269'', ''21.12.2015'', ''Some fixes for CHANGED flag of AT_OBJECT.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (239, ''0000.0001.0000.0270'', ''29.12.2015'', ''AT_OBJECT triggers.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (240, ''0000.0001.0000.0271'', ''02.01.2016'', ''Add edition date field to TgdcSimpleTable.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (241, ''0000.0001.0000.0272'', ''09.01.2016'', ''Second try. Now with triggers disabled.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (242, ''0000.0001.0000.0273'', ''17.01.2016'', ''Nullify objects in at_relation_fields.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (243, ''0000.0001.0000.0274'', ''24.01.2016'', ''Issue when RUIDs of DT differ from GD_RUID record.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (244, ''0000.0001.0000.0275'', ''28.01.2016'', ''Trigger to prevent namespace cyclic dependencies.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (245, ''0000.0001.0000.0276'', ''12.02.2016'', ''Fixed minor bugs.'') '#13#10 +
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
    SL.Free;
  end;
end;

end.