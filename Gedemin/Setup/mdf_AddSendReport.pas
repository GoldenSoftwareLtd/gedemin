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
  Log('������ ��������� ������ GD_AUTOTASK � GD_SMTP');
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
          '  ADD groupkey dforeignkey, '#13#10 +
          '  ADD smtpkey dforeignkey, '#13#10 +
          '  ADD exporttype VARCHAR(5), '#13#10 +
          '  ADD CONSTRAINT gd_chk_autotask_exporttype CHECK(exporttype IN (''WORD'', ''EXCEL'', ''PDF'', ''XML''))';
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
          '    NEW.groupkey = NULL; '#13#10 +
          '    NEW.smtpkey = NULL; '#13#10 +
          '    NEW.exporttype = NULL; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NOT NEW.autotrkey IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.functionkey = NULL; '#13#10 +
          '    NEW.reportkey = NULL; '#13#10 +
          '    NEW.cmdline = NULL; '#13#10 +
          '    NEW.backupfile = NULL; '#13#10 +
          '    NEW.groupkey = NULL; '#13#10 +
          '    NEW.smtpkey = NULL; '#13#10 +
          '    NEW.exporttype = NULL; '#13#10 +
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
          '    NEW.groupkey = NULL; '#13#10 +
          '    NEW.smtpkey = NULL; '#13#10 +
          '    NEW.exporttype = NULL; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NOT NEW.backupfile IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.functionkey = NULL; '#13#10 +
          '    NEW.autotrkey = NULL; '#13#10 +
          '    NEW.reportkey = NULL; '#13#10 +
          '    NEW.cmdline = NULL; '#13#10 +
          '    NEW.groupkey = NULL; '#13#10 +
          '    NEW.smtpkey = NULL; '#13#10 +
          '    NEW.exporttype = NULL; '#13#10 +
          '  END '#13#10 +
          'END';
        FIBSQL.ExecQuery;
		
        FIBSQL.SQL.Text :=
          'ALTER TABLE gd_smtp '#13#10 +
          '  ADD principal dboolean DEFAULT 0';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_biu_smtp FOR gd_smtp '#13#10 +
          '  BEFORE INSERT OR UPDATE '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  if (NEW.principal = 1) THEN '#13#10 +
          '    UPDATE gd_smtp SET gd_smtp.principal = 0; '#13#10 +
          'END';
        FIBSQL.ExecQuery;
		
        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (222, ''0000.0001.0000.0253'', ''22.07.2015'', ''Modified GD_AUTOTASK and GD_SMTP tables.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

        FTransaction.Commit;
        Log('��������� ������ GD_AUTOTASK � GD_SMTP ������� ���������');
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