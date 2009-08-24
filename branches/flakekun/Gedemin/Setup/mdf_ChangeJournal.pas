
unit mdf_ChangeJournal;

interface

uses
  sysutils, IBDatabase, gdModify;


procedure ChangeJournal(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL;

procedure ChangeJournal(IBDB: TIBDatabase; Log: TModifyLog);
var
  FIBTransaction: TIBTransaction;
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  FIBTransaction := TIBTransaction.Create(nil);
  try
    FIBTransaction.DefaultDatabase := IBDB;
    ibsql.Transaction := FIBTransaction;
    ibsql.ParamCheck := False;
    try
      FIBTransaction.StartTransaction;

      ibsql.Close;

      ibsql.SQL.Text := 'DELETE FROM gd_journal';
      ibsql.ExecQuery;

      FIBTransaction.Commit;
      FIBTransaction.StartTransaction;

      ibsql.SQL.Text :=
        'ALTER PROCEDURE gd_p_sec_loginuser (username VARCHAR(20), passw VARCHAR(20), subsystem INTEGER) '#13#10 +
        '  RETURNS ( '#13#10 +
        '    result        INTEGER, '#13#10 +
        '    userkey       INTEGER, '#13#10 +
        '    contactkey    INTEGER, '#13#10 +
        '    ibname        VARCHAR(20), '#13#10 +
        '    ibpassword    VARCHAR(20), '#13#10 +
        '    ingroup       INTEGER, '#13#10 +
        '    session       INTEGER, '#13#10 +
        '    subsystemname VARCHAR(60), '#13#10 +
        '    groupname     VARCHAR(255), '#13#10 +
        '    dbversion     VARCHAR(20), '#13#10 +
        '    dbreleasedate DATE, '#13#10 +
        '    dbversionid   INTEGER, '#13#10 +
        '    dbversioncomment VARCHAR(254), '#13#10 +
        '    auditlevel    INTEGER, '#13#10 +
        '    auditcache    INTEGER, '#13#10 +
        '    auditmaxdays  INTEGER, '#13#10 +
        '    allowuseraudit SMALLINT '#13#10 +
        '  ) '#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE C1 INTEGER; '#13#10 +
        '  DECLARE VARIABLE C2 INTEGER; '#13#10 +
        '  DECLARE VARIABLE C3 INTEGER; '#13#10 +
        '  DECLARE VARIABLE WS TIME; '#13#10 +
        '  DECLARE VARIABLE WE TIME; '#13#10 +
        '  DECLARE VARIABLE ED DATE; '#13#10 +
        '  DECLARE VARIABLE CT TIME; '#13#10 +
        '  DECLARE VARIABLE CD DATE; '#13#10 +
        'BEGIN '#13#10 +
        '  /* '#13#10 +
        '  IF (NOT EXISTS(SELECT * FROM gd_subsystem WHERE id = :subsystem)) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    result = -1001; '#13#10 +
        '    EXIT; '#13#10 +
        '  END '#13#10 +
        '  */ '#13#10 +
        ' '#13#10 +
        '  /* '#13#10 +
        '  IF (EXISTS(SELECT * FROM gd_subsystem WHERE id = :subsystem AND disabled <> 0)) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    result = -1002; '#13#10 +
        '    EXIT; '#13#10 +
        '  END '#13#10 +
        '  */ '#13#10 +
        ' '#13#10 +
        '  IF (NOT EXISTS(SELECT * FROM gd_user WHERE g_s_ansicomparetext(name, :username) = 0)) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    result = -1003; '#13#10 +
        '    EXIT; '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        '  IF (EXISTS(SELECT * FROM gd_user WHERE g_s_ansicomparetext(name, :username) = 0 AND disabled <> 0)) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    result = -1005; '#13#10 +
        '    EXIT; '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        '  SELECT CURRENT_DATE FROM rdb$database INTO :CD; '#13#10 +
        ' '#13#10 +
        '  SELECT workstart, workend, expdate, passwneverexp '#13#10 +
        '  FROM gd_user '#13#10 +
        '  WHERE (g_s_ansicomparetext(name, :username) = 0) AND disabled = 0 '#13#10 +
        '  INTO :WS, :WE, :ED, :C1; '#13#10 +
        ' '#13#10 +
        '  IF ((:CD >= :ED) AND (:C1 = 0)) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    result = -1005; '#13#10 +
        '    EXIT; '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        '  SELECT CURRENT_TIME FROM rdb$database INTO :CT; '#13#10 +
        ' '#13#10 +
        '  IF ( '#13#10 +
        '    (NOT :WS IS NULL) AND '#13#10 +
        '    (NOT :WE IS NULL) AND '#13#10 +
        '    ((:CT < :WS) OR (:CT > :WE)) '#13#10 +
        '  ) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    result = -1006; '#13#10 +
        '    EXIT; '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        '  IF ( '#13#10 +
        '        NOT EXISTS( '#13#10 +
        '          SELECT * FROM gd_user '#13#10 +
        '          WHERE (g_s_ansicomparetext(passw, :passw) = 0) '#13#10 +
        '            AND (g_s_ansicomparetext(name, :username) = 0) '#13#10 +
        '            AND disabled = 0 '#13#10 +
        '        ) '#13#10 +
        '     ) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    result = -1004; '#13#10 +
        '    EXIT; '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        '  /* !!!! непон€тно почему это работает ! */ '#13#10 +
        '  /* '#13#10 +
        '  SELECT g_b_and(us.ingroup, ss.groupsallowed) '#13#10 +
        '  FROM gd_user us, gd_subsystem ss '#13#10 +
        '  WHERE (g_s_ansicomparetext(us.name, :username) = 0) '#13#10 +
        '    AND ss.id = :subsystem '#13#10 +
        '  INTO :C1; '#13#10 +
        ' '#13#10 +
        '  IF (:C1 = 0) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    result = -1007; '#13#10 +
        '    EXIT; '#13#10 +
        '  END '#13#10 +
        '  */ '#13#10 +
        ' '#13#10 +
        '  SELECT name, auditlevel, auditcache, auditmaxdays '#13#10 +
        '  FROM gd_subsystem '#13#10 +
        '  WHERE id = :subsystem AND disabled = 0 '#13#10 +
        '  INTO :subsystemname, :auditlevel, :auditcache, :auditmaxdays; '#13#10 +
        ' '#13#10 +
        '  SELECT id, contactkey, ibname, ibpassword, ingroup, mustchange, allowaudit '#13#10 +
        '  FROM gd_user '#13#10 +
        '  WHERE (g_s_ansicomparetext(passw, :passw) = 0) '#13#10 +
        '        AND (g_s_ansicomparetext(name, :username) = 0) AND disabled = 0 '#13#10 +
        '  INTO :userkey, :contactkey, :ibname, :ibpassword, :ingroup, :C1, :AllowUserAudit; '#13#10 +
        ' '#13#10 +
        '  IF (:contactkey IS NULL) THEN '#13#10 +
        '    contactkey = -1; '#13#10 +
        ' '#13#10 +
        '  EXECUTE PROCEDURE gd_p_sec_getgroupsforuser(:userkey) '#13#10 +
        '    RETURNING_VALUES :groupname; '#13#10 +
        ' '#13#10 +
        '  IF (:C1 = 0) THEN '#13#10 +
        '    result = 1; '#13#10 +
        '  ELSE '#13#10 +
        '    result = 2; '#13#10 +
        ' '#13#10 +
        '  /* '#13#10 +
        '  C2 = 1; '#13#10 +
        '  C1 = 1; '#13#10 +
        '  C3 = 0; '#13#10 +
        '  WHILE ((:C1 < 33) AND (:C3 <> 1)) DO '#13#10 +
        '  BEGIN '#13#10 +
        '    SELECT COUNT(gs.id) '#13#10 +
        '    FROM gd_usergroup gg, gd_user gu, gd_subsystem gs '#13#10 +
        '    WHERE gg.id = :C1 '#13#10 +
        '      AND gg.disabled = 0 '#13#10 +
        '      AND gu.id = :UserKey '#13#10 +
        '      AND gs.id = :subsystem '#13#10 +
        '      AND g_b_and(:C2, g_b_and(gu.ingroup, gs.groupsallowed)) > 0 '#13#10 +
        '    INTO :C3; '#13#10 +
        ' '#13#10 +
        '    C1 = :C1 + 1; '#13#10 +
        '    IF (:C1 < 32) THEN '#13#10 +
        '      C2 = :C2 * 2; '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        '  IF (:C3 = 0) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    result = -1008; '#13#10 +
        '    EXIT; '#13#10 +
        '  END '#13#10 +
        '  */ '#13#10 +
        ' '#13#10 +
        '  /* унiкальны нумар сэсii */ '#13#10 +
        '  SELECT GEN_ID(gd_g_session_id, 1) '#13#10 +
        '  FROM RDB$DATABASE '#13#10 +
        '  INTO :session; '#13#10 +
        ' '#13#10 +
        '  /* б€гучы нумар вэрс__ базы _ дата выхаду†*/ '#13#10 +
        '  SELECT versionstring, releasedate, /*id,*/ comment '#13#10 +
        '  FROM fin_versioninfo '#13#10 +
        '  WHERE id = (SELECT MAX(id) FROM fin_versioninfo) '#13#10 +
        '  INTO :dbversion, :dbreleasedate, /*:dbversionid,*/ :dbversioncomment; '#13#10 +
        ' '#13#10 +
        '  dbversionid = GEN_ID(gd_g_dbid, 0); '#13#10 +
        ' '#13#10 +
        '  /* '#13#10 +
        '  SELECT GEN_ID(gd_g_dbid, 0) FROM rdb$database '#13#10 +
        '    INTO :dbversionid; '#13#10 +
        '  */ '#13#10 +
        ' '#13#10 +
        '  /* выд€л€ем зап_сы з журналу старэйшы€ за азначаны тэрм_н */ '#13#10 +
        '  /* '#13#10 +
        '  IF (:AuditMaxDays > 0) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    DELETE FROM gd_journal '#13#10 +
        '    WHERE '#13#10 +
        '      ((CURRENT_TIMESTAMP - operationdate) > :AuditMaxDays); '#13#10 +
        '  END '#13#10 +
        '  */ '#13#10 +
        'END ';
      ibsql.ExecQuery;

      FIBTransaction.Commit;
      FIBTransaction.StartTransaction;
      
      ibsql.SQL.Text := 'ALTER TABLE gd_journal DROP subsystemkey';
      ibsql.ExecQuery;

      ibsql.SQL.Text := 'ALTER TABLE gd_journal DROP sessionkey';
      ibsql.ExecQuery;

      ibsql.SQL.Text := 'ALTER TABLE gd_journal DROP userkey';
      ibsql.ExecQuery;

      ibsql.SQL.Text := 'ALTER TABLE gd_journal DROP computername';
      ibsql.ExecQuery;

      ibsql.SQL.Text := 'ALTER TABLE gd_journal DROP operationkey';
      ibsql.ExecQuery;

      ibsql.SQL.Text := 'ALTER TABLE gd_journal DROP blob1';
      ibsql.ExecQuery;

      ibsql.SQL.Text := 'ALTER TABLE gd_journal ADD contactkey dforeignkey';
      ibsql.ExecQuery;

      ibsql.SQL.Text := 'ALTER TABLE gd_journal ADD source dtext40';
      ibsql.ExecQuery;

      ibsql.SQL.Text := 'ALTER TABLE gd_journal ADD objectid dforeignkey';
      ibsql.ExecQuery;

      ibsql.SQL.Text := 'ALTER TABLE gd_journal ADD data dblobtext80_1251';
      ibsql.ExecQuery;


      ibsql.SQL.Text :=
        'CREATE TRIGGER gd_bi_journal2 FOR gd_journal '#13#10 +
        '  BEFORE INSERT '#13#10 +
        '  POSITION 2 '#13#10 +
        'AS '#13#10 +
        'BEGIN '#13#10 +
        '  IF (NEW.operationdate IS NULL) THEN '#13#10 +
        '    NEW.operationdate = ''NOW''; '#13#10 +
        ' '#13#10 +
        '  IF (NEW.contactkey IS NULL) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    SELECT contactkey FROM gd_user '#13#10 +
        '    WHERE ibname = CURRENT_USER '#13#10 +
        '    INTO NEW.contactkey; '#13#10 +
        '  END '#13#10 +
        'END ';
      ibsql.ExecQuery;

      ibsql.SQL.Text := 'CREATE DOMAIN dtimestamp_notnull AS TIMESTAMP NOT NULL ';
      ibsql.ExecQuery;

      FIBTransaction.Commit;
      FIBTransaction.StartTransaction;

      try
        ibsql.SQL.Text :=
          'INSERT INTO FIN_VERSIONINFO (ID,VERSIONSTRING,RELEASEDATE,COMMENT) VALUES (42,''0000.0001.0000.0032'',''2002-11-08'',''GD_JOURNAL has got its final state'')';
        ibsql.ExecQuery;

        FIBTransaction.Commit;
      except
      end;  

      Log('ќбновлен GD_JOURNAL');
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
