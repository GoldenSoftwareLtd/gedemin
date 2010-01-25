unit mdf_SQLMonitor;

interface

uses
  IBDatabase, gdModify, Forms,
  Windows, Controls;

procedure SQLMonitor(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript, classes;

procedure SQLMonitor(IBDB: TIBDatabase; Log: TModifyLog);
var
  IBTr: TIBTransaction;
  q: TIBSQL;
begin
  IBTr := TIBTransaction.Create(nil);
  try
    IBTr.DefaultDatabase := IBDB;
    IBTr.StartTransaction;

    q := TIBSQL.Create(nil);
    try
      q.ParamCheck := False;
      q.Transaction := IBTr;

      q.SQL.Text := 'SELECT rdb$field_source FROM rdb$relation_fields ' +
        'WHERE rdb$relation_name = ''GD_GOODGROUP'' AND rdb$field_name = ''DESCRIPTION'' ';
      q.ExecQuery;
      if q.EOF or (q.Fields[0].AsString <> 'DBLOBTEXT80_1251') then
      begin
        q.Close;

        q.SQL.Text := 'ALTER TABLE gd_goodgroup ADD temp_desc dblobtext80_1251 ';
        try
          q.ExecQuery;
        except
        end;

        q.SQL.Text := 'UPDATE gd_goodgroup SET temp_desc = description ';
        try
          q.ExecQuery;
        except
        end;

        q.SQL.Text := 'ALTER TABLE gd_goodgroup DROP description ';
        try
          q.ExecQuery;
        except
        end;

        q.SQL.Text := 'ALTER TABLE gd_goodgroup ADD description dblobtext80_1251 ';
        try
          q.ExecQuery;
        except
        end;

        q.SQL.Text := 'UPDATE gd_goodgroup SET  description = temp_desc';
        try
          q.ExecQuery;
        except
        end;

        q.SQL.Text := 'ALTER TABLE gd_goodgroup DROP temp_desc ';
        try
          q.ExecQuery;
        except
        end;
      end;

      q.Close;

      try
        q.SQL.Text :=
          'CREATE TABLE gd_sql_statement '#13#10 +
          '( '#13#10 +
          '  id               dintkey, '#13#10 +
          '  crc              INTEGER NOT NULL UNIQUE, '#13#10 +
          '  kind             SMALLINT NOT NULL, '#13#10 +
          '  data             dblobtext80_1251 not null '#13#10 +
          ') ';
        q.ExecQuery;
      except
      end;

      try
        q.SQL.Text := 'ALTER TABLE gd_sql_statement ADD CONSTRAINT gd_pk_sql_statement PRIMARY KEY (id) ';
        q.ExecQuery;
      except
      end;

      try
        q.SQL.Text :=
          'CREATE TRIGGER gd_bi_sql_statement FOR gd_sql_statement '#13#10 +
          '  BEFORE INSERT '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.ID IS NULL) THEN '#13#10 +
          '    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
          'END ';
        q.ExecQuery;
      except
      end;

      try
        q.SQL.Text :=
          'CREATE TABLE gd_sql_log '#13#10 +
          '( '#13#10 +
          '  statementcrc     INTEGER NOT NULL, '#13#10 +
          '  paramscrc        INTEGER, '#13#10 +
          '  contactkey       dintkey, '#13#10 +
          '  starttime        dtimestamp_notnull, '#13#10 +
          '  duration         INTEGER NOT NULL '#13#10 +
          '); ';
        q.ExecQuery;
      except
      end;

      try
        q.SQL.Text :=
          'ALTER TABLE gd_sql_log ADD CONSTRAINT gd_fk_sql_log_scrc '#13#10 +
          '  FOREIGN KEY (statementcrc) REFERENCES gd_sql_statement (crc) '#13#10 +
          '  ON DELETE CASCADE '#13#10 +
          '  ON UPDATE CASCADE ';
        q.ExecQuery;
      except
      end;

      try
        q.SQL.Text :=
          'ALTER TABLE gd_sql_log ADD CONSTRAINT gd_fk_sql_log_pcrc '#13#10 +
          '  FOREIGN KEY (paramscrc) REFERENCES gd_sql_statement (crc) '#13#10 +
          '  ON DELETE CASCADE '#13#10 +
          '  ON UPDATE CASCADE ';
        q.ExecQuery;
      except
      end;

      try
        q.SQL.Text := 'GRANT ALL ON GD_SQL_STATEMENT TO administrator ';
        q.ExecQuery;
      except
      end;

      try
        q.SQL.Text := 'GRANT ALL ON GD_SQL_LOG TO administrator ';
        q.ExecQuery;
      except
      end;

      q.SQL.Text :=
        'ALTER PROCEDURE gd_p_sec_getgroupsforuser(UserKey INTEGER) '#13#10 +
        '  RETURNS(GroupsForUser VARCHAR(2048)) '#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE UGK INTEGER; '#13#10 +
        '  DECLARE VARIABLE GroupName VARCHAR(2048); '#13#10 +
        '  DECLARE VARIABLE C1 INTEGER; '#13#10 +
        '  DECLARE VARIABLE C2 INTEGER; '#13#10 +
        '  DECLARE VARIABLE IG INTEGER; '#13#10 +
        'BEGIN '#13#10 +
        '  SELECT ingroup FROM gd_user WHERE id = :UserKey INTO :IG; '#13#10 +
        ' '#13#10 +
        '  C2 = 1; '#13#10 +
        '  C1 = 1; '#13#10 +
        '  GroupsForUser = ''''; '#13#10 +
        '  WHILE (:C1 <= 32) DO '#13#10 +
        '  BEGIN '#13#10 +
        '    IF (g_b_and(:C2, :IG) > 0) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      GroupName = ''''; '#13#10 +
        '      SELECT gg.name '#13#10 +
        '      FROM gd_usergroup gg '#13#10 +
        '      WHERE gg.id = :C1 '#13#10 +
        '      INTO :GroupName; '#13#10 +
        ' '#13#10 +
        '      IF (:GroupName <> '''') THEN '#13#10 +
        '        GroupsForUser = :GroupsForUser || '', '' || :GroupName; '#13#10 +
        '    END '#13#10 +
        ' '#13#10 +
        '    C1 = :C1 + 1; '#13#10 +
        ' '#13#10 +
        '    IF (:C1 < 32) THEN '#13#10 +
        '      C2 = :C2 * 2; '#13#10 +
        '  END '#13#10 +
        'END ';
      q.ExecQuery;

      q.SQL.Text :=
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
        '    groupname     VARCHAR(2048), '#13#10 +
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
        '  DECLARE VARIABLE PNE INTEGER; '#13#10 +
        '  DECLARE VARIABLE MCH INTEGER; '#13#10 +
        '  DECLARE VARIABLE WS TIME; '#13#10 +
        '  DECLARE VARIABLE WE TIME; '#13#10 +
        '  DECLARE VARIABLE ED DATE; '#13#10 +
        '  DECLARE VARIABLE UDISABLED INTEGER; '#13#10 +
        '  DECLARE VARIABLE UPASSW VARCHAR(20); '#13#10 +
        'BEGIN '#13#10 +
        '  UDISABLED = NULL; '#13#10 +
        ' '#13#10 +
        '  SELECT id, disabled, passw, workstart, workend, expdate, passwneverexp, '#13#10 +
        '    contactkey, ibname, ibpassword, ingroup, mustchange, allowaudit '#13#10 +
        '  FROM gd_user '#13#10 +
        '  WHERE UPPER(name) = UPPER(:username) '#13#10 +
        '  INTO :userkey, :UDISABLED, :UPASSW, :WS, :WE, :ED, :PNE, '#13#10 +
        '    :contactkey, :ibname, :ibpassword, :ingroup, :MCH, :AllowUserAudit; '#13#10 +
        ' '#13#10 +
        '  IF (:userkey IS NULL) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    result = -1003; '#13#10 +
        '    EXIT; '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        '  IF (:UDISABLED <> 0) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    result = -1005; '#13#10 +
        '    EXIT; '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        '  IF ((CURRENT_DATE >= :ED) AND (:PNE = 0)) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    result = -1005; '#13#10 +
        '    EXIT; '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        '  IF ( '#13#10 +
        '    (NOT :WS IS NULL) AND '#13#10 +
        '    (NOT :WE IS NULL) AND '#13#10 +
        '    ((CURRENT_TIME < :WS) OR (CURRENT_TIME > :WE)) '#13#10 +
        '  ) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    result = -1006; '#13#10 +
        '    EXIT; '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        '  IF (:UPASSW <> :passw) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    result = -1004; '#13#10 +
        '    EXIT; '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        '  /* '#13#10 +
        '  SELECT name, auditlevel, auditcache, auditmaxdays '#13#10 +
        '  FROM gd_subsystem '#13#10 +
        '  WHERE id = :subsystem AND disabled = 0 '#13#10 +
        '  INTO :subsystemname, :auditlevel, :auditcache, :auditmaxdays; '#13#10 +
        '  */ '#13#10 +
        ' '#13#10 +
        '  IF (:contactkey IS NULL) THEN '#13#10 +
        '    contactkey = -1; '#13#10 +
        ' '#13#10 +
        '  EXECUTE PROCEDURE gd_p_sec_getgroupsforuser(:userkey) '#13#10 +
        '    RETURNING_VALUES :groupname; '#13#10 +
        ' '#13#10 +
        '  result = IIF(:MCH = 0, 1, 2); '#13#10 +
        ' '#13#10 +
        '  /* унiкальны нумар сэсii */ '#13#10 +
        '  session = GEN_ID(gd_g_session_id, 1); '#13#10 +
        ' '#13#10 +
        '  /* б€гучы нумар вэрс__ базы _ дата выхаду†*/ '#13#10 +
        '  SELECT FIRST 1 versionstring, releasedate, /*id,*/ comment '#13#10 +
        '  FROM fin_versioninfo '#13#10 +
        '  ORDER BY id DESC '#13#10 +
        '  INTO :dbversion, :dbreleasedate, /*:dbversionid,*/ :dbversioncomment; '#13#10 +
        ' '#13#10 +
        '  dbversionid = GEN_ID(gd_g_dbid, 0); '#13#10 +
        'END ';
      q.ExecQuery;

      try
        q.SQL.Text := 'INSERT INTO fin_versioninfo ' +
          'VALUES (71, ''0000.0001.0000.0099'', ''15.03.2006'', ''Tables for SQL monitor added'') ';
        q.ExecQuery;
      except
      end;

      try
        q.SQL.Text := 'INSERT INTO fin_versioninfo ' +
          'VALUES (72, ''0000.0001.0000.0100'', ''17.03.2006'', ''Type of description field of goodgroup has been changed'') ';
        q.ExecQuery;
      except
      end;
    finally
      q.Free;
    end;

    IBTr.Commit;
  finally
    IBTr.Free;
  end;
end;



end.
