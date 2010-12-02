unit mdf_BlockRule;

interface

uses
  IbDataBase, gdModify;

procedure ModifyBlockRule(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript, Dialogs;

procedure ModifyBlockRule(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
  Script: TIBScript;
  I: Integer;
const
  DropSQLArray: Array[0..17] of String = (
    'DROP TRIGGER GD_BI_DOCUMENT_BLOCK ' ,
    'DROP TRIGGER GD_BU_DOCUMENT_BLOCK ' ,
    'DROP TRIGGER GD_BD_DOCUMENT_BLOCK ' ,
    'DROP TRIGGER AC_BI_ENTRY_BLOCK '    ,
    'DROP TRIGGER AC_BU_ENTRY_BLOCK '    ,
    'DROP TRIGGER AC_BD_ENTRY_BLOCK '    ,
    'DROP TRIGGER AC_BI_RECORD_BLOCK '   ,
    'DROP TRIGGER AC_BU_RECORD_BLOCK '   ,
    'DROP TRIGGER AC_BD_RECORD_BLOCK '   ,
    'DROP TRIGGER INV_BI_MOVEMENT_BLOCK ',
    'DROP TRIGGER INV_BU_MOVEMENT_BLOCK ',
    'DROP TRIGGER INV_BD_MOVEMENT_BLOCK ',
    'DROP TRIGGER INV_BI_CARD_BLOCK '    ,
    'DROP TRIGGER INV_BU_CARD_BLOCK '    ,
    'DROP TRIGGER INV_BD_CARD_BLOCK '    ,
    'DROP GENERATOR GD_G_BLOCK '         ,
    'DROP GENERATOR GD_G_BLOCK_GROUP '   ,
    'DROP PROCEDURE GD_P_EXCLUDE_BLOCK_DT ');

begin
  Log('Начата модификация механизма блокировки периода...');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FIBSQL := TIBSQL.Create(nil);
      Script := TIBScript.Create(nil);
        try
          Script.Transaction := FTransaction;
          Script.Database := IBDB;
          FIBSQL.Transaction := FTransaction;
          FIBSQL.ParamCheck := False;
          for I := Low(DropSQLArray) to High(DropSQLArray) do
            begin
              FIBSQL.SQL.Text := DropSQLArray[I];
              try
                FTransaction.StartTransaction;
                FIBSQL.ExecQuery;
                FIBSQL.Close;
                FTransaction.Commit;
              except
                on E: Exception do
                begin
                  Log('Ошибка: ' + E.Message);
                  FTransaction.Rollback;
                end;
              end;
            end;

          if not FTransaction.InTransaction then
                FTransaction.StartTransaction;
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'SELECT * FROM rdb$relations ' +
            ' WHERE rdb$relation_name = ''GD_BLOCK_RULE''';
          FIBSQL.ExecQuery;
          if FIBSQL.RecordCount = 0 then
            begin
              Script.Script.Text :=
              'CREATE TABLE GD_BLOCK_RULE'#13#10 +
              '('#13#10 +
              '  ID                    DINTKEY,'#13#10 +
              '  NAME                  DNAME,'#13#10 +
              '  ORDR                  DINTEGER_NOTNULL,'#13#10 +
              '  FORDOCS               DBOOLEAN_NOTNULL DEFAULT 1,'#13#10 +
              '  ALLDOCTYPES           DBOOLEAN_NOTNULL DEFAULT 1,'#13#10 +
              '  INCLDOCTYPES          DBOOLEAN_NOTNULL DEFAULT 1,'#13#10 +
              '  TABLENAME             DTABLENAME,'#13#10 +
              '  ROOTKEY               DFOREIGNKEY,'#13#10 +
              '  INCLSUBLEVELS         DBOOLEAN_NOTNULL DEFAULT 1,'#13#10 +
              '  ALLRECORDS            DBOOLEAN_NOTNULL DEFAULT 1,'#13#10 +
              '  SELECTCONDITION       DTEXT1024,'#13#10 +
              '  ANYDATE               DBOOLEAN_NOTNULL DEFAULT 1,'#13#10 +
              '  DATEFIELDNAME         DFIELDNAME,'#13#10 +
              '  FIXEDDATE             DBOOLEAN_NOTNULL DEFAULT 0,'#13#10 +
              '  BLOCKDATE             DDATE,'#13#10 +
              '  DAYNUMBER             DINTEGER_NOTNULL DEFAULT 0,'#13#10 +
              '  DATEUNIT              CHAR(2),'#13#10 +
              '  ALLUSERS              DBOOLEAN_NOTNULL DEFAULT 1,'#13#10 +
              '  INCLUSERS             DBOOLEAN_NOTNULL DEFAULT 1,'#13#10 +
              '  USERGROUPS            DINTKEY,'#13#10 +
              '  CREATORKEY            DINTKEY,'#13#10 +
              '  CREATIONDATE          DCREATIONDATE,'#13#10 +
              '  EDITORKEY             DINTKEY,'#13#10 +
              '  EDITIONDATE           DEDITIONDATE,'#13#10 +
              '  DISABLED              DDISABLED DEFAULT 0'#13#10 +
              ');'#13#10 +
              'ALTER TABLE GD_BLOCK_RULE ADD CONSTRAINT DATE_UNIT_CHECK CHECK (dateunit in (''CW'',''CM'',''CQ'',''CY'',''PW'',''PM'',''PQ'',''PY'',''TO''));'#13#10 +
              'ALTER TABLE GD_BLOCK_RULE ADD CONSTRAINT UNQ1_GD_BLOCK_RULE UNIQUE (ORDR); '#13#10 +
              'ALTER TABLE GD_BLOCK_RULE ADD CONSTRAINT PK_GD_BLOCK_RULE PRIMARY KEY (ID); '#13#10 +
              'ALTER TABLE GD_BLOCK_RULE ADD CONSTRAINT FK_GD_BLOCK_RULE_1 FOREIGN KEY (CREATORKEY) REFERENCES GD_PEOPLE (CONTACTKEY) ON UPDATE CASCADE; '#13#10 +
              'ALTER TABLE GD_BLOCK_RULE ADD CONSTRAINT FK_GD_BLOCK_RULE_2 FOREIGN KEY (EDITORKEY) REFERENCES GD_PEOPLE (CONTACTKEY) ON UPDATE CASCADE; '#13#10 +
              'GRANT ALL ON GD_BLOCK_RULE TO ADMINISTRATOR; ';
              Script.ExecuteScript;
              FTransaction.Commit;
            end;

          if not FTransaction.InTransaction then
                FTransaction.StartTransaction;
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'SELECT * FROM rdb$relations ' +
            ' WHERE rdb$relation_name = ''GD_BLOCK_DT''';
          FIBSQL.ExecQuery;
          if FIBSQL.RecordCount = 0 then
            begin
              Script.Script.Text :=
              'CREATE TABLE GD_BLOCK_DT ( '#13#10 +
              '  BLOCKRULEKEY          DINTKEY, '#13#10 +
              '  DTKEY                 DINTKEY '#13#10 +
              '); '#13#10 +
              'ALTER TABLE GD_BLOCK_DT ADD CONSTRAINT FK_GD_BLOCK_DT_1 FOREIGN KEY (BLOCKRULEKEY) REFERENCES GD_BLOCK_RULE (ID) ON DELETE CASCADE ON UPDATE CASCADE; '#13#10 +
              'ALTER TABLE GD_BLOCK_DT ADD CONSTRAINT FK_GD_BLOCK_DT_2 FOREIGN KEY (DTKEY) REFERENCES GD_DOCUMENTTYPE (ID) ON DELETE CASCADE ON UPDATE CASCADE; '#13#10 +
              'GRANT ALL ON GD_BLOCK_DT TO ADMINISTRATOR; ';
              Script.ExecuteScript;
              FTransaction.Commit;
            end;

           if not FTransaction.InTransaction then
                FTransaction.StartTransaction;
            FIBSQL.Close;
            FIBSQL.SQL.Text := 'SELECT * FROM rdb$triggers  '+
              ' WHERE rdb$trigger_name = ''GD_BI_BLOCK_RULE'' ';
            FIBSQL.ExecQuery;
            if FIBSQL.RecordCount = 0 then
              begin
                FIBSQL.Close;
                FIBSQL.SQL.Text :=
                'CREATE TRIGGER GD_BI_BLOCK_RULE FOR GD_BLOCK_RULE '#13#10 +
                'ACTIVE BEFORE INSERT POSITION 0 '#13#10 +
                'AS '#13#10 +
                'begin '#13#10 +
                '  IF (NEW.id IS NULL) THEN '#13#10 +
                '    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
                '  IF (NEW.creationdate IS NULL) THEN '#13#10 +
                '    NEW.creationdate = CURRENT_TIMESTAMP; '#13#10 +
                '  IF (NEW.editiondate IS NULL) THEN '#13#10 +
                '    NEW.editiondate = CURRENT_TIMESTAMP; '#13#10 +
                'end ';
                FIBSQL.ExecQuery;
                FTransaction.Commit;
              end;

            if not FTransaction.InTransaction then
                FTransaction.StartTransaction;
            FIBSQL.Close;
            FIBSQL.SQL.Text := 'SELECT * FROM rdb$triggers  '+
              ' WHERE rdb$trigger_name = ''GD_BU_BLOCK_RULE'' ';
            FIBSQL.ExecQuery;
            if FIBSQL.RecordCount = 0 then
              begin
                FIBSQL.Close;
                FIBSQL.SQL.Text :=
                'CREATE TRIGGER GD_BU_BLOCK_RULE FOR GD_BLOCK_RULE '#13#10 +
                'ACTIVE BEFORE UPDATE POSITION 0 '#13#10 +
                'AS '#13#10 +
                'begin '#13#10 +
                '  NEW.editiondate = CURRENT_TIMESTAMP; '#13#10 +
                'end';
                FIBSQL.ExecQuery;
                FTransaction.Commit;
              end;

            if not FTransaction.InTransaction then
                FTransaction.StartTransaction;
            Script.Script.Text :=

            'SET TERM ^ ;'#13#10 +
            'CREATE PROCEDURE AC_CALC_DATE ('#13#10 +
            '    DU CHAR(2),'#13#10 +
            '    DN INTEGER)'#13#10 +
            'RETURNS ('#13#10 +
            '    ADATE DATE)'#13#10 +
            'AS'#13#10 +
            'DECLARE VARIABLE M SMALLINT;'#13#10 +
            'DECLARE VARIABLE Y INTEGER;'#13#10 +
            'BEGIN'#13#10 +

            '  IF (:DU = ''TO'') THEN'#13#10 +
            '    ADATE = CURRENT_DATE + :DN;'#13#10 +

            '#13#10 +  IF (:DU IN (''CW'',''PW'')) THEN'#13#10 +
            '    BEGIN'#13#10 +
            '      IF (:DU = ''CW'') THEN'#13#10 +
            '        ADATE = CURRENT_DATE - EXTRACT(WEEKDAY FROM CURRENT_DATE) + 1;'#13#10 +
            '      ELSE'#13#10 +
            '        ADATE = CURRENT_DATE - EXTRACT(WEEKDAY FROM CURRENT_DATE) - 6;'#13#10 +
            '      ADATE = ADATE + :DN;'#13#10 +
            '    END'#13#10 +

            '  IF (:DU IN (''CM'',''PM'')) THEN'#13#10 +
            '    BEGIN'#13#10 +
            '      M = EXTRACT(MONTH FROM CURRENT_DATE);'#13#10 +
            '      Y = EXTRACT(YEAR FROM CURRENT_DATE);'#13#10 +
            '      IF (:DU = ''PM'') THEN'#13#10 +
            '        M = M - 1;'#13#10 +
            '      IF (:M = 0) THEN'#13#10 +
            '        BEGIN'#13#10 +
            '          M = 12;'#13#10 +
            '          Y = Y - 1;'#13#10 +
            '        END'#13#10 +
            '      ADATE = CAST(''01.'' || M || ''.'' || Y AS DATE) + :DN;'#13#10 +
            '    END'#13#10 +

            '  IF (:DU IN (''CQ'',''PQ'')) THEN'#13#10 +
            '    BEGIN'#13#10 +
            '      M = EXTRACT(MONTH FROM CURRENT_DATE);'#13#10 +
            '      Y = EXTRACT(YEAR FROM CURRENT_DATE);'#13#10 +
            '--      Q = EXTRACT(QUARTER FROM CURRENT_DATE);'#13#10 +
            '      M = CASE'#13#10 +
            '            WHEN (:M IN (1,2,3)) THEN  1'#13#10 +
            '            WHEN (:M IN (4,5,6)) THEN  4'#13#10 +
            '            WHEN (:M IN (7,8,9)) THEN  7'#13#10 +
            '            WHEN (:M IN (10,11,12)) THEN 10'#13#10 +
            '          END;'#13#10 +
            '      IF (:DU = ''PQ'') THEN'#13#10 +
            '        BEGIN'#13#10 +
            '          IF (M = 1) THEN'#13#10 +
            '            BEGIN'#13#10 +
            '              M = 10;'#13#10 +
            '              Y = Y - 1;'#13#10 +
            '            END ELSE'#13#10 +
            '          M = M - 3;'#13#10 +
            '        END'#13#10 +
            '      ADATE = CAST(''01.'' || M || ''.'' || Y AS DATE) + :DN;'#13#10 +
            '    END'#13#10 +

            '  IF (:DU IN (''CY'',''PY'')) THEN'#13#10 +
            '    BEGIN'#13#10 +
            '      Y = EXTRACT(YEAR FROM CURRENT_DATE);'#13#10 +
            '      if (:DU = ''PY'') then'#13#10 +
            '        Y = Y - 1;'#13#10 +
            '      ADATE = CAST(''01.01.'' || Y AS DATE) + :DN ;'#13#10 +
            '    END'#13#10 +

            ' SUSPEND;'#13#10 +

            'END^ '#13#10 +
            'SET TERM ; ^ '#13#10 +
            'GRANT EXECUTE ON PROCEDURE AC_CALC_DATE TO PUBLIC; ';
            Script.ExecuteScript;
            FTransaction.Commit;

            if not FTransaction.InTransaction then
                FTransaction.StartTransaction;
            Script.Script.Text :=
            'SET TERM ^ ; '#13#10 +
            'CREATE PROCEDURE GD_P_BLOCK ('#13#10 +
            '    IS_DOC SMALLINT,'#13#10 +
            '    BLOCK_DATE DATE,'#13#10 +
            '    DOC_TYPE INTEGER,'#13#10 +
            '    BLOCK_TABLE_NAME VARCHAR(255))'#13#10 +
            'RETURNS ('#13#10 +
            '    IS_BLOCKED SMALLINT)'#13#10 +
            'AS'#13#10 +
            'DECLARE VARIABLE ID INTEGER;'#13#10 +
            'DECLARE VARIABLE DATEFIELDNAME VARCHAR(60);'#13#10 +
            'DECLARE VARIABLE ANYDATE SMALLINT;'#13#10 +
            'DECLARE VARIABLE FIXEDDATE SMALLINT;'#13#10 +
            'DECLARE VARIABLE BLOCKDATE DATE;'#13#10 +
            'DECLARE VARIABLE DAYNUMBER INTEGER;'#13#10 +
            'DECLARE VARIABLE DATEUNIT CHAR(2);'#13#10 +
            'DECLARE VARIABLE USERGROUPS INTEGER;'#13#10 +
            'DECLARE VARIABLE CALC_DATE DATE;'#13#10 +
            'DECLARE VARIABLE F_DATE SMALLINT;'#13#10 +
            'DECLARE VARIABLE F_UG SMALLINT;'#13#10 +
            'DECLARE VARIABLE F_DT SMALLINT;'#13#10 +
            'DECLARE VARIABLE IG INTEGER;'#13#10 +
            'DECLARE VARIABLE ALLUSERS SMALLINT;'#13#10 +
            'DECLARE VARIABLE INCLUSERS SMALLINT;'#13#10 +
            'BEGIN'#13#10 +
            '  IS_BLOCKED = 0;'#13#10 +
            '  IF (:IS_DOC = 1) THEN'#13#10 +
            '    BEGIN'#13#10 +
            '      FOR'#13#10 +
            '        SELECT ID, ANYDATE, FIXEDDATE, BLOCKDATE, DAYNUMBER, DATEUNIT,'#13#10 +
            '               USERGROUPS, ALLUSERS, INCLUSERS'#13#10 +
            '        FROM GD_BLOCK_RULE'#13#10 +
            '        WHERE FORDOCS = 1 AND DISABLED = 0'#13#10 +
            '        ORDER BY ORDR'#13#10 +
            '        INTO :ID, :ANYDATE, :FIXEDDATE, :BLOCKDATE, :DAYNUMBER,'#13#10 +
            '             :DATEUNIT, :USERGROUPS, :ALLUSERS, :INCLUSERS'#13#10 +
            '      DO'#13#10 +
            '        BEGIN'#13#10 +
            '          -- ДАТА БЛОКИРОВКИ'#13#10 +
            '          IF (:FIXEDDATE = 1) THEN'#13#10 +
            '            CALC_DATE = :BLOCKDATE; ELSE'#13#10 +
            '            EXECUTE PROCEDURE AC_CALC_DATE(:DATEUNIT,:DAYNUMBER)'#13#10 +
            '              RETURNING_VALUES :CALC_DATE;'#13#10 +
            '          IF ((:BLOCK_DATE - CAST(''17.11.1858'' AS DATE)) < :CALC_DATE) THEN'#13#10 +
            '            F_DATE = 1; ELSE F_DATE = 0;'#13#10 +
            '          IF (:ANYDATE = 1) THEN F_DATE = 1;'#13#10 +
            '          --ГРУППЫ ПОЛЬЗОВАТЕЛЕЙ'#13#10 +
            '          SELECT INGROUP FROM GD_USER WHERE IBNAME = CURRENT_USER'#13#10 +
            '            INTO :IG;'#13#10 +
            '          IF (:ALLUSERS = 1) THEN'#13#10 +
            '            F_UG = 1; ELSE'#13#10 +
            '            BEGIN'#13#10 +
            '              IF (BIN_AND(:USERGROUPS, :IG) = 0) THEN'#13#10 +
            '                BEGIN'#13#10 +
            '                  IF (:INCLUSERS = 1)  THEN'#13#10 +
            '                    F_UG = 1; ELSE F_UG = 0;'#13#10 +
            '                END  ELSE'#13#10 +
            '                BEGIN'#13#10 +
            '                  IF (:INCLUSERS = 0)  THEN'#13#10 +
            '                    F_UG = 1; ELSE F_UG = 0;'#13#10 +
            '                END'#13#10 +
            '            END'#13#10 +
            '          --ТИП  ДОКУМЕНТА'#13#10 +
            '          IF (EXISTS(SELECT 0 FROM GD_BLOCK_DT WHERE BLOCKRULEKEY = :ID AND DTKEY = :DOC_TYPE))'#13#10 +
            '            THEN'#13#10 +
            '              F_DT = 1; ELSE F_DT = 0;'#13#10 +
            '          --IS_BLOCKED'#13#10 +
            '          IF ((F_DATE =1) AND (F_DT =1) AND (F_UG = 1)) THEN'#13#10 +
            '            BEGIN'#13#10 +
            '              IS_BLOCKED = 1;'#13#10 +
            '              LEAVE;'#13#10 +
            '            END'#13#10 +
            '            ELSE IS_BLOCKED = 0;'#13#10 +
            '        END'#13#10 +
            '    END ELSE'#13#10 +
            '    BEGIN'#13#10 +
            '      FOR'#13#10 +
            '        SELECT ID, ANYDATE, DATEFIELDNAME, FIXEDDATE, BLOCKDATE,'#13#10 +
            '               DAYNUMBER, DATEUNIT, USERGROUPS, ALLUSERS, INCLUSERS'#13#10 +
            '        FROM GD_BLOCK_RULE'#13#10 +
            '        WHERE FORDOCS = 0 AND DISABLED = 0 AND TABLENAME = :BLOCK_TABLE_NAME'#13#10 +
            '        ORDER BY ORDR'#13#10 +
            '        INTO :ID, :ANYDATE, :DATEFIELDNAME, :FIXEDDATE, :BLOCKDATE,'#13#10 +
            '             :DAYNUMBER, :DATEUNIT, :USERGROUPS, :ALLUSERS, :INCLUSERS'#13#10 +
            '      DO'#13#10 +
            '        BEGIN'#13#10 +
            '          IF (DATEFIELDNAME IS NOT NULL) THEN'#13#10 +
            '          -- ДАТА БЛОКИРОВКИ'#13#10 +
            '          IF (:FIXEDDATE = 1) THEN'#13#10 +
            '            CALC_DATE = :BLOCKDATE; ELSE'#13#10 +
            '            EXECUTE PROCEDURE AC_CALC_DATE(:DATEUNIT, :DAYNUMBER)'#13#10 +
            '              RETURNING_VALUES :CALC_DATE;'#13#10 +
            '          IF ((:BLOCK_DATE - CAST(''17.11.1858'' AS DATE)) < :CALC_DATE) THEN'#13#10 +
            '            F_DATE = 1; ELSE F_DATE = 0;'#13#10 +
            '          IF (:ANYDATE = 1) THEN F_DATE = 1;'#13#10 +
            '          --ГРУППЫ ПОЛЬЗОВАТЕЛЕЙ'#13#10 +
            '          SELECT INGROUP FROM GD_USER WHERE IBNAME = CURRENT_USER'#13#10 +
            '            INTO :IG;'#13#10 +
            '          IF (:ALLUSERS = 1) THEN'#13#10 +
            '            F_UG = 1; ELSE'#13#10 +
            '            BEGIN'#13#10 +
            '              IF (BIN_AND(:USERGROUPS, :IG) = 0) THEN'#13#10 +
            '                BEGIN'#13#10 +
            '                  IF (:INCLUSERS = 1)  THEN'#13#10 +
            '                    F_UG = 1; ELSE F_UG = 0;'#13#10 +
            '               END  ELSE'#13#10 +
            '               BEGIN'#13#10 +
            '                 IF (:INCLUSERS = 1)  THEN'#13#10 +
            '                   F_UG = 1; ELSE F_UG = 0;'#13#10 +
            '               END'#13#10 +
            '           END'#13#10 +
            '         --IS_BLOCKED'#13#10 +
            '         IF ((F_DATE = 1) AND (F_UG = 1)) THEN'#13#10 +
            '           BEGIN'#13#10 +
            '             IS_BLOCKED = 1;'#13#10 +
            '             LEAVE;'#13#10 +
            '           END'#13#10 +
            '           ELSE IS_BLOCKED = 0;'#13#10 +
            '       END'#13#10 +
            '   END'#13#10 +
            ' SUSPEND;'#13#10 +
            'END^ '#13#10 +
            'SET TERM ; ^ '#13#10 +
            'GRANT EXECUTE ON PROCEDURE GD_P_BLOCK TO PUBLIC; ';
            Script.ExecuteScript;
            FTransaction.Commit;

            FTransaction.StartTransaction;
            FIBSQL.Close;
            FIBSQL.SQL.Text :=
              'UPDATE OR INSERT INTO fin_versioninfo ' +
              '  VALUES (103, ''0000.0001.0000.0130'', ''24.11.2008'', ''gd_block_rule'') ' +
              '  MATCHING (id) ';
            FIBSQL.ExecQuery;
            FTransaction.Commit;

            Log('Модификация механизма блокировки успешно завершена');
        finally
          FIBSQL.Free;
          Script.Free;
        end;
    except
      on E: Exception do
      begin
        FTransaction.Rollback;
        Log('Ошибка модификация механизма блокировки: '#13#10 + E.Message);
      end;
    end;
  finally
    if FTransaction.InTransaction then
      FTransaction.Rollback;
    FTransaction.Free;
  end;
end;

end.
