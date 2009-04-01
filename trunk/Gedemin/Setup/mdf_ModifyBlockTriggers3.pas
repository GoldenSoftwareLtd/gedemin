unit mdf_ModifyBlockTriggers3;

interface

uses
  IBDatabase, gdModify;

procedure ModifyBlockTriggers3(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;


procedure ModifyBlockTriggers3(IBDB: TIBDatabase; Log: TModifyLog);
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
      with FIBSQL do
      try
        Transaction := FTransaction;
        ParamCheck := False;

        SQL.Text :=
          'CREATE OR ALTER PROCEDURE gd_p_exclude_block_dt(DT INTEGER)'#13#10 +
          '  RETURNS(F INTEGER)'#13#10 +
          'AS'#13#10 +
          'BEGIN'#13#10 +
          '  F = 0;'#13#10 +
          'END';
        try
          ExecQuery;
        except
          on E: Exception do
            Log('Сообщение:' +  E.Message);
        end;
        Close;

        SQL.Text := 'GRANT EXECUTE ON PROCEDURE GD_P_EXCLUDE_BLOCK_DT TO ADMINISTRATOR';
        try
          ExecQuery;
        except
          on E: Exception do
            Log('Внимание:' +  E.Message);
        end;

        SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (84, ''0000.0001.0000.0112'', ''03.01.2007'', ''Fixed triggers for FireBird 2.0'')';
        try
          ExecQuery;
        except
        end;
        Close;

        (*
        SQL.Text :=
          'ALTER TABLE rp_reportgroup DROP aview ';
        try
          ExecQuery;
        except
          on E: Exception do
          begin
            Log('Внимание: ' + E.Message);
          end;
        end;
        Close;

        SQL.Text :=
          'ALTER TABLE rp_reportgroup DROP achag ';
        try
          ExecQuery;
        except
          on E: Exception do
          begin
            Log('Внимание: ' + E.Message);
          end;
        end;
        Close;

        SQL.Text :=
          'ALTER TABLE rp_reportgroup DROP afull ';
        try
          ExecQuery;
        except
          on E: Exception do
          begin
            Log('Внимание: ' + E.Message);
          end;
        end;
        Close;
        *)

        SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (85, ''0000.0001.0000.0113'', ''20.01.2007'', ''Stripped security descriptors from rp_reportgroup'')';
        try
          ExecQuery;
        except
        end;
        Close;

        SQL.Text :=
          'UPDATE gd_people p SET p.surname=(SELECT SUBSTRING(c.name FROM 1 FOR 20) FROM gd_contact c WHERE c.id=p.contactkey) ' +
            'WHERE COALESCE(p.surname, '''')='''' ';
        ExecQuery;
        Close;

        SQL.Text :=
          'UPDATE rdb$relation_fields SET rdb$null_flag=1 ' +
            'WHERE rdb$relation_name=''GD_PEOPLE'' AND ' +
            'rdb$field_name=''SURNAME'' AND COALESCE(rdb$null_flag, 0)=0';
        ExecQuery;
        Close;

        SQL.Text := 'SELECT * FROM rdb$relations WHERE rdb$relation_name = ''USR$INV_CARMARKS'' ';
        ExecQuery;
        if not Eof then
        begin
          Close;
          SQL.Text := 'SELECT * FROM usr$inv_carmarks ';
          ExecQuery;
          if Eof then
          begin
            Close;
            SQL.Text := 'INSERT INTO usr$inv_carmarks (usr$mark) VALUES (''марка'') ';
            ExecQuery;
          end;
        end;
        Close;

        SQL.Text := 'SELECT * FROM rdb$relations WHERE rdb$relation_name = ''USR$INV_CAR'' ';
        ExecQuery;
        if not Eof then
        begin
          Close;
          SQL.Text := 'UPDATE usr$inv_car SET usr$markkey = (SELECT FIRST 1 id FROM usr$inv_carmarks) WHERE usr$markkey IS NULL ';
          ExecQuery;

          Close;
          SQL.Text := 'UPDATE usr$inv_car SET usr$number = CAST(id AS VARCHAR(20)) WHERE COALESCE(usr$number, '''')='''' ';
          ExecQuery;
        end;
        Close;

        SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (86, ''0000.0001.0000.0114'', ''22.01.2007'', ''surname field of gd_people became not null'')';
        try
          ExecQuery;
        except
        end;
        Close;

        SQL.Text :=
          'DROP TRIGGER GD_AU_DOCUMENT ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE TRIGGER GD_AU_DOCUMENT FOR GD_DOCUMENT ' + #13#10 +
          '  AFTER UPDATE ' + #13#10 +
          '  POSITION 0 ' + #13#10 +
          'AS ' + #13#10 +
          'BEGIN ' + #13#10 +
          '  IF (NEW.PARENT IS NULL) THEN ' + #13#10 +
          '  BEGIN ' + #13#10 +
          ' ' + #13#10 +
          '    IF ((OLD.documentdate <> NEW.documentdate) OR (OLD.number <> NEW.number) ' + #13#10 +
          '      OR (OLD.companykey <> NEW.companykey)) THEN ' + #13#10 +
          '    BEGIN ' + #13#10 +
          '    IF (NEW.DOCUMENTTYPEKEY <> 800300) THEN ' + #13#10 +
          '      UPDATE gd_document SET documentdate = NEW.documentdate, ' + #13#10 +
          '        number = NEW.number, companykey = NEW.companykey ' + #13#10 +
          '      WHERE (parent = NEW.ID) ' + #13#10 +
          '        AND ((documentdate <> NEW.documentdate) ' + #13#10 +
          '         OR (number <> NEW.number) OR (companykey <> NEW.companykey)); ' + #13#10 +
          '    ELSE ' + #13#10 +
          '      UPDATE gd_document SET documentdate = NEW.documentdate, ' + #13#10 +
          '        companykey = NEW.companykey ' + #13#10 +
          '      WHERE (parent = NEW.ID) ' + #13#10 +
          '        AND ((documentdate <> NEW.documentdate) ' + #13#10 +
          '        OR  (companykey <> NEW.companykey)); ' + #13#10 +
          '    END ' + #13#10 +
          '  END ELSE ' + #13#10 +
          '  BEGIN ' + #13#10 +
          '    IF (NEW.editiondate <> OLD.editiondate) THEN ' + #13#10 +
          '      UPDATE gd_document SET editiondate = NEW.editiondate, ' + #13#10 +
          '        editorkey = NEW.editorkey ' + #13#10 +
          '      WHERE (ID = NEW.parent) AND (editiondate <> NEW.editiondate); ' + #13#10 +
          '  END ' + #13#10 +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (87, ''0000.0001.0000.0115'', ''24.01.2007'', ''Fixed block and GD_AU_DOCUMENT triggers'')';
        try
          ExecQuery;
        except
        end;
        Close;

        SQL.Text :=
          'DROP TRIGGER gd_aiu_command ';
        try
          ExecQuery;
        except
        end;
        Close;

        SQL.Text :=
          'CREATE TRIGGER gd_aiu_command FOR gd_command ' + #13#10 +
          '  AFTER INSERT OR UPDATE ' + #13#10 +
          '  POSITION 100 ' + #13#10 +
          'AS ' + #13#10 +
          'BEGIN ' + #13#10 +
          '  UPDATE gd_command SET aview = NEW.aview, achag = NEW.achag, afull = NEW.afull ' + #13#10 +
          '  WHERE classname = NEW.classname ' + #13#10 +
          '    AND COALESCE(subtype, '''') = COALESCE(NEW.subtype, '''') ' + #13#10 +
          '    AND ((aview <> NEW.aview) OR (achag <> NEW.achag) OR (afull <> NEW.afull)) ' + #13#10 +
          '    AND id <> NEW.id; ' + #13#10 +
          'END';
        ExecQuery;
        Close;

        SQL.Text :=
          'ALTER TABLE gd_usergroup ADD CONSTRAINT gd_chk_usergroup_id CHECK (id BETWEEN 1 AND 32)';
        try
          ExecQuery;
        except
          on E: Exception do
          begin
            Log('Внимание: ' + E.Message);
          end;
        end;
        Close;

        SQL.Text :=
          'ALTER TABLE gd_usergroup ADD CONSTRAINT gd_chk_usergroup_name CHECK (name > '''')';
        try
          ExecQuery;
        except
          on E: Exception do
          begin
            Log('Внимание: ' + E.Message);
          end;
        end;
        Close;

        SQL.Text :=
          'ALTER TRIGGER gd_bi_usergroup BEFORE INSERT POSITION 0 ' + #13#10 +
          '  AS ' + #13#10 +
          'BEGIN ' + #13#10 +
          '  IF (NEW.ID IS NULL) THEN ' + #13#10 +
          '    EXECUTE PROCEDURE gd_p_getnextusergroupid ' + #13#10 +
          '      RETURNING_VALUES NEW.id; ' + #13#10 +
          'END ';
        ExecQuery;
        Close;

        SQL.Text := 'DROP EXCEPTION gd_e_notidusegroup';
        try
          ExecQuery;
        except
          on E: Exception do
          begin
            Log('Внимание: ' + E.Message);
          end;
        end;
        Close;

        SQL.Text :=
          'ALTER TRIGGER gd_bu_usergroup BEFORE UPDATE POSITION 0 ' + #13#10 +
          'AS ' + #13#10 +
          'BEGIN ' + #13#10 +
          '  IF ((OLD.ID < 7) AND (OLD.name <> NEW.name)) THEN ' + #13#10 +
          '    EXCEPTION gd_e_canteditusergroup; ' + #13#10 +
          'END';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE TRIGGER gd_ad_usergroup FOR gd_usergroup ' + #13#10 +
          '  AFTER DELETE ' + #13#10 +
          '  POSITION 0 ' + #13#10 +
          'AS ' + #13#10 +
          '  DECLARE VARIABLE MASK INTEGER; ' + #13#10 +
          '  DECLARE VARIABLE I INTEGER; ' + #13#10 +
          'BEGIN ' + #13#10 +
          '  MASK = 1; ' + #13#10 +
          '  I = 1; ' + #13#10 +
          '  WHILE (I < OLD.id) DO ' + #13#10 +
          '  BEGIN ' + #13#10 +
          '    MASK = g_b_shl(:MASK, 1); ' + #13#10 +
          '    I = :I + 1; ' + #13#10 +
          '  END ' + #13#10 +
          ' ' + #13#10 +
          '  /* пользователей, которые входили только в удаленную группу */ ' + #13#10 +
          '  /* переведем в стандартную группу Пользователи              */ ' + #13#10 +
          '  UPDATE gd_user SET ingroup = 4 WHERE ingroup = :MASK; ' + #13#10 +
          ' ' + #13#10 +
          '  /* исключим пользователей из удаленной группы               */ ' + #13#10 +
          '  UPDATE gd_user SET ingroup = g_b_and(ingroup, g_b_not(:MASK)) ' + #13#10 +
          '    WHERE g_b_and(ingroup, :MASK) <> 0; ' + #13#10 +
          'END ';
        try
          ExecQuery;
        except
          on E: Exception do
          begin
            Log('Внимание: ' + E.Message);
          end;
        end;
        Close;

        SQL.Text :=
          'CREATE TRIGGER gd_biu_user FOR gd_user ' + #13#10 +
          '  BEFORE INSERT OR UPDATE ' + #13#10 +
          '  POSITION 100 ' + #13#10 +
          'AS ' + #13#10 +
          '  DECLARE VARIABLE I INTEGER; ' + #13#10 +
          '  DECLARE VARIABLE MASK INTEGER; ' + #13#10 +
          '  DECLARE VARIABLE M INTEGER; ' + #13#10 +
          'BEGIN ' + #13#10 +
          '  I = 1; ' + #13#10 +
          '  M = 1; ' + #13#10 +
          '  MASK = 0; ' + #13#10 +
          '  WHILE (I <= 32) DO ' + #13#10 +
          '  BEGIN ' + #13#10 +
          '    IF (EXISTS (SELECT * FROM gd_usergroup WHERE id = :I)) THEN ' + #13#10 +
          '      MASK = g_b_or(:MASK, :M); ' + #13#10 +
          '    M = g_b_shl(:M, 1); ' + #13#10 +
          '    I = :I + 1; ' + #13#10 +
          '  END ' + #13#10 +
          ' ' + #13#10 +
          '  NEW.ingroup = g_b_and(NEW.ingroup, :MASK); ' + #13#10 +
          'END ';
        try
          ExecQuery;
        except
          on E: Exception do
          begin
            Log('Внимание: ' + E.Message);
          end;
        end;
        Close;

        SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (88, ''0000.0001.0000.0116'', ''28.01.2007'', ''Some internal changes'')';
        try
          ExecQuery;
        except
        end;
        Close;

        FTransaction.Commit;
      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        Log('Ошибка: ' + E.Message);
      end;
    end;
  finally
    if FTransaction.InTransaction then
      FTransaction.Rollback;
    FTransaction.Free;
  end;

end;

end.
