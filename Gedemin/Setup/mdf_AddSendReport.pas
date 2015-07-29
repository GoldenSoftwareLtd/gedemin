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
  Log('Начато изменение таблиц GD_AUTOTASK и GD_SMTP');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        
        FIBSQL.SQL.Text :=
          'ALTER TABLE gd_autotask '#13#10 +
          '  ADD emailgroupkey    dforeignkey, '#13#10 +
          '  ADD emailrecipients  dtext255, '#13#10 +
          '  ADD emailsmtpkey     dforeignkey, '#13#10 +
          '  ADD emailexporttype  VARCHAR(3), '#13#10 +
          '  ADD CONSTRAINT fk_gd_autotask_esk '#13#10 +
          '    FOREIGN KEY (emailsmtpkey) REFERENCES gd_smtp(id) '#13#10 +
          '    ON UPDATE CASCADE, '#13#10 +
          '  ADD CONSTRAINT fk_gd_autotask_fk '#13#10 +
          '    FOREIGN KEY (functionkey) REFERENCES gd_function(id) '#13#10 +
          '    ON UPDATE CASCADE, '#13#10 +
          '  ADD CONSTRAINT fk_gd_autotask_atrk '#13#10 +
          '    FOREIGN KEY (autotrkey) REFERENCES ac_transaction(id) '#13#10 +
          '    ON UPDATE CASCADE, '#13#10 +
          '  ADD CONSTRAINT fk_gd_autotask_rk '#13#10 +
          '    FOREIGN KEY (reportkey) REFERENCES rp_reportlist(id) '#13#10 +
          '    ON UPDATE CASCADE, '#13#10 +
          '  ADD CONSTRAINT fk_gd_autotask_uk '#13#10 +
          '    FOREIGN KEY (userkey) REFERENCES gd_user(id) '#13#10 +
          '    ON UPDATE CASCADE, '#13#10 +
          '  ADD CONSTRAINT fk_gd_autotask_ck '#13#10 +
          '    FOREIGN KEY (creatorkey) REFERENCES gd_contact(id) '#13#10 +
          '    ON UPDATE CASCADE, '#13#10 +
          '  ADD CONSTRAINT fk_gd_autotask_ek '#13#10 +
          '    FOREIGN KEY (editorkey) REFERENCES gd_contact(id) '#13#10 +
          '    ON UPDATE CASCADE, '#13#10 +
          '  ADD CONSTRAINT gd_chk_autotask_emailrecipients CHECK(emailrecipients > ''''), '#13#10 +
          '  ADD CONSTRAINT gd_chk_autotask_recipients CHECK((emailrecipients > '''') OR (emailgroupkey IS NOT NULL))';
        FIBSQL.ExecQuery;

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

        FIBSQL.SQL.Text :=
          'ALTER TABLE gd_autotask_log '#13#10 +
          '  ADD CONSTRAINT gd_fk_autotask_log_ck '#13#10 +
          '    FOREIGN KEY (creatorkey) REFERENCES gd_contact(id) '#13#10 +
          '    ON UPDATE CASCADE';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'ALTER TABLE gd_smtp '#13#10 +
          '  ADD principal dboolean DEFAULT 0, '#13#10 +
          '  ADD CONSTRAINT fk_gd_smtp_ck '#13#10 +
          '    FOREIGN KEY (creatorkey) REFERENCES gd_contact(id) '#13#10 +
          '    ON UPDATE CASCADE, '#13#10 +
          '  ADD CONSTRAINT fk_gd_smtp_ek '#13#10 +
          '    FOREIGN KEY (editorkey) REFERENCES gd_contact(id) '#13#10 +
          '    ON UPDATE CASCADE';
        FIBSQL.ExecQuery;

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

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_biu_smtp FOR gd_smtp '#13#10 +
          '  BEFORE INSERT OR UPDATE '#13#10 +
          '  POSITION 32000 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.principal = 1) THEN '#13#10 +
          '    UPDATE gd_smtp SET gd_smtp.principal = 0 WHERE id <> NEW.id; '#13#10 +
          'END';
        FIBSQL.ExecQuery;
		
        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (222, ''0000.0001.0000.0253'', ''22.07.2015'', ''Modified GD_AUTOTASK and GD_SMTP tables.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

        FTransaction.Commit;
        Log('Изменение таблиц GD_AUTOTASK и GD_SMTP успешно завершено');
      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        FTransaction.Rollback;
        Log(E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;  
 
end.