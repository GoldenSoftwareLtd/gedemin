unit mdf_ModifyBlockTriggers4;

interface

uses
  IBDatabase, gdModify;

procedure ModifyBlockTriggers4(IBDB: TIBDatabase; Log: TModifyLog);
procedure _ModifyBlockTriggers(FTransaction: TIBTransaction);

implementation

uses
  IBSQL, SysUtils;

procedure _ModifyBlockTriggers(FTransaction: TIBTransaction);
var
  FIBSQL: TIBSQL;
begin
  FIBSQL := TIBSQL.Create(nil);
  with FIBSQL do
  try
    Transaction := FTransaction;
    ParamCheck := False;

    try
      SQL.Text := 'CREATE GENERATOR gd_g_block_group ';
      ExecQuery;
    except
    end;
    
    SQL.Text :=
      'CREATE OR ALTER PROCEDURE gd_p_exclude_block_dt(DT INTEGER)'#13#10 +
      '  RETURNS(F INTEGER)'#13#10 +
      'AS'#13#10 +
      'BEGIN'#13#10 +
      '  F = 0;'#13#10 +
      'END';
    ExecQuery;

    Close;
    SQL.Text := 'GRANT EXECUTE ON PROCEDURE GD_P_EXCLUDE_BLOCK_DT TO ADMINISTRATOR';
    ExecQuery;

    SQL.Text :=
      'CREATE OR ALTER TRIGGER ac_bi_entry_block FOR ac_entry ' + #13#10 +
      '  INACTIVE ' + #13#10 +
      '  BEFORE INSERT ' + #13#10 +
      '  POSITION 28017 ' + #13#10 +
      'AS ' +
      '  DECLARE VARIABLE IG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE BG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE DT INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE F INTEGER; ' + #13#10 +
      'BEGIN ' + #13#10 +
      '  IF ((NEW.entrydate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN ' + #13#10 +
      '  BEGIN ' + #13#10 +
      '    SELECT d.documenttypekey '+ #13#10 +
      '    FROM gd_document d '+ #13#10 +
      '      JOIN ac_record r ON r.documentkey = d.id '+ #13#10 +
      '    WHERE '+ #13#10 +
      '      r.id = NEW.recordkey '+ #13#10 +
      '    INTO '+ #13#10 +
      '      :DT; '+ #13#10 +
      '  '+ #13#10 +
      '    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT) '+ #13#10 +
      '      RETURNING_VALUES :F; '+ #13#10 +
      '  '+ #13#10 +
      '    IF(:F = 0) THEN '+ #13#10 +
      '    BEGIN '+ #13#10 +
      '      BG = GEN_ID(gd_g_block_group, 0); '+ #13#10 +
      '      IF (:BG = 0) THEN '+ #13#10 +
      '      BEGIN '+ #13#10 +
      '        EXCEPTION gd_e_block; '+ #13#10 +
      '      END ELSE '+ #13#10 +
      '      BEGIN '+ #13#10 +
      '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER '+ #13#10 +
      '          INTO :IG; '+ #13#10 +
      '        IF (BIN_AND(:BG, :IG) = 0) THEN '+ #13#10 +
      '        BEGIN '+ #13#10 +
      '          EXCEPTION gd_e_block; '+ #13#10 +
      '        END '+ #13#10 +
      '      END '+ #13#10 +
      '    END '+ #13#10 +
      '  END '+ #13#10 +
      'END ';
    ExecQuery;

    Close;
    SQL.Text :=
      'CREATE OR ALTER TRIGGER ac_bu_entry_block FOR ac_entry ' + #13#10 +
      '  INACTIVE ' + #13#10 +
      '  BEFORE UPDATE ' + #13#10 +
      '  POSITION 28017 ' + #13#10 +
      'AS ' + #13#10 +
      '  DECLARE VARIABLE IG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE BG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE DT INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE F INTEGER; ' + #13#10 +
      'BEGIN ' + #13#10 +
      '  IF (((NEW.entrydate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_block, 0)) ' + #13#10 +
      '     OR ((OLD.entrydate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_block, 0))) THEN ' + #13#10 +
      '  BEGIN ' + #13#10 +
      '    SELECT d.documenttypekey ' + #13#10 +
      '    FROM gd_document d ' + #13#10 +
      '      JOIN ac_record r ON r.documentkey = d.id ' + #13#10 +
      '    WHERE ' + #13#10 +
      '      r.id = NEW.recordkey ' + #13#10 +
      '    INTO ' + #13#10 +
      '      :DT; ' + #13#10 +
      '  ' + #13#10 +
      '    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT) ' + #13#10 +
      '      RETURNING_VALUES :F; ' + #13#10 +
      '  ' + #13#10 +
      '    IF(:F = 0) THEN ' + #13#10 +
      '    BEGIN ' + #13#10 +
      '      BG = GEN_ID(gd_g_block_group, 0); ' + #13#10 +
      '      IF (:BG = 0) THEN ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        EXCEPTION gd_e_block; ' + #13#10 +
      '      END ELSE ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' + #13#10 +
      '          INTO :IG; ' + #13#10 +
      '        IF (BIN_AND(:BG, :IG) = 0) THEN ' + #13#10 +
      '        BEGIN ' + #13#10 +
      '          EXCEPTION gd_e_block; ' + #13#10 +
      '        END ' + #13#10 +
      '      END ' + #13#10 +
      '    END  ' + #13#10 +
      '  END ' + #13#10 +
      'END ';
    ExecQuery;

    Close;
    SQL.Text :=
      'CREATE OR ALTER TRIGGER ac_bd_entry_block FOR ac_entry ' + #13#10 +
      '  INACTIVE ' + #13#10 +
      '  BEFORE DELETE ' + #13#10 +
      '  POSITION 28017 ' + #13#10 +
      'AS ' + #13#10 +
      '  DECLARE VARIABLE IG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE BG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE DT INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE F INTEGER; ' + #13#10 +
      'BEGIN ' + #13#10 +
      '  IF ((OLD.entrydate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN ' + #13#10 +
      '  BEGIN ' + #13#10 +
      '    SELECT d.documenttypekey ' + #13#10 +
      '    FROM gd_document d ' + #13#10 +
      '      JOIN ac_record r ON r.documentkey = d.id ' + #13#10 +
      '    WHERE ' + #13#10 +
      '      r.id = OLD.recordkey ' + #13#10 +
      '    INTO ' + #13#10 +
      '      :DT; ' + #13#10 +
      '   ' + #13#10 +
      '    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT) ' + #13#10 +
      '      RETURNING_VALUES :F; ' + #13#10 +
      '   ' + #13#10 +
      '    IF(:F = 0) THEN ' + #13#10 +
      '    BEGIN ' + #13#10 +
      '      BG = GEN_ID(gd_g_block_group, 0); ' + #13#10 +
      '      IF (:BG = 0) THEN ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        EXCEPTION gd_e_block; ' + #13#10 +
      '      END ELSE ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' + #13#10 +
      '          INTO :IG; ' + #13#10 +
      '        IF (BIN_AND(:BG, :IG) = 0) THEN ' + #13#10 +
      '        BEGIN ' + #13#10 +
      '          EXCEPTION gd_e_block; ' + #13#10 +
      '        END ' + #13#10 +
      '      END ' + #13#10 +
      '    END ' + #13#10 +
      '  END ' + #13#10 +
      'END ';
    ExecQuery;

    Close;
    SQL.Text :=
      'CREATE OR ALTER TRIGGER gd_bi_document_block FOR gd_document ' + #13#10 +
      '  INACTIVE ' + #13#10 +
      '  BEFORE INSERT ' + #13#10 +
      '  POSITION 28017 ' + #13#10 +
      'AS ' + #13#10 +
      '  DECLARE VARIABLE IG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE BG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE F INTEGER; ' + #13#10 +
      'BEGIN ' + #13#10 +
      '  IF ((NEW.documentdate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN ' + #13#10 +
      '  BEGIN ' + #13#10 +
      '    EXECUTE PROCEDURE gd_p_exclude_block_dt (NEW.documenttypekey) ' + #13#10 +
      '      RETURNING_VALUES :F; ' + #13#10 +
      '  ' + #13#10 +
      '    IF (:F = 0) THEN ' + #13#10 +
      '    BEGIN ' + #13#10 +
      '      BG = GEN_ID(gd_g_block_group, 0); ' + #13#10 +
      '      IF (:BG = 0) THEN ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        EXCEPTION gd_e_block; ' + #13#10 +
      '      END ELSE ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' + #13#10 +
      '          INTO :IG; ' + #13#10 +
      '        IF (BIN_AND(:BG, :IG) = 0) THEN ' + #13#10 +
      '        BEGIN ' + #13#10 +
      '          EXCEPTION gd_e_block; ' + #13#10 +
      '        END ' + #13#10 +
      '      END ' + #13#10 +
      '    END ' + #13#10 +
      '  END ' + #13#10 +
      'END ';
    ExecQuery;

    Close;
    SQL.Text :=
      'CREATE OR ALTER TRIGGER gd_bu_document_block FOR gd_document ' + #13#10 +
      '  INACTIVE ' + #13#10 +
      '  BEFORE UPDATE ' + #13#10 +
      '  POSITION 28017 ' + #13#10 +
      'AS ' + #13#10 +
      '  DECLARE VARIABLE IG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE BG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE F INTEGER; ' + #13#10 +
      'BEGIN ' + #13#10 +
      '  IF (((NEW.documentdate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_block, 0)) ' + #13#10 +
      '      OR ((OLD.documentdate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_block, 0))) THEN ' + #13#10 +
      '  BEGIN ' + #13#10 +
      '    EXECUTE PROCEDURE gd_p_exclude_block_dt (NEW.documenttypekey) ' + #13#10 +
      '      RETURNING_VALUES :F; ' + #13#10 +
      '  ' + #13#10 +
      '    IF (:F = 0) THEN ' + #13#10 +
      '    BEGIN ' + #13#10 +
      '      BG = GEN_ID(gd_g_block_group, 0); ' + #13#10 +
      '      IF (:BG = 0) THEN ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        EXCEPTION gd_e_block; ' + #13#10 +
      '      END ELSE ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' + #13#10 +
      '          INTO :IG; ' + #13#10 +
      '        IF (BIN_AND(:BG, :IG) = 0) THEN ' + #13#10 +
      '        BEGIN ' + #13#10 +
      '          EXCEPTION gd_e_block; ' + #13#10 +
      '        END ' + #13#10 +
      '      END ' + #13#10 +
      '    END ' + #13#10 +
      '  END ' + #13#10 +
      'END ';
    ExecQuery;

    Close;
    SQL.Text :=
      'CREATE OR ALTER TRIGGER gd_bd_document_block FOR gd_document ' + #13#10 +
      '  INACTIVE ' + #13#10 +
      '  BEFORE DELETE ' + #13#10 +
      '  POSITION 28017 ' + #13#10 +
      'AS ' + #13#10 +
      '  DECLARE VARIABLE IG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE BG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE F INTEGER; ' + #13#10 +
      'BEGIN ' + #13#10 +
      '  IF ((OLD.documentdate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN ' + #13#10 +
      '  BEGIN ' + #13#10 +
      '    EXECUTE PROCEDURE gd_p_exclude_block_dt (OLD.documenttypekey) ' + #13#10 +
      '      RETURNING_VALUES :F; ' + #13#10 +
      '   ' + #13#10 +
      '    IF (:F = 0) THEN ' + #13#10 +
      '    BEGIN ' + #13#10 +
      '      BG = GEN_ID(gd_g_block_group, 0); ' + #13#10 +
      '      IF (:BG = 0) THEN ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        EXCEPTION gd_e_block; ' + #13#10 +
      '      END ELSE ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' + #13#10 +
      '          INTO :IG; ' + #13#10 +
      '        IF (BIN_AND(:BG, :IG) = 0) THEN ' + #13#10 +
      '        BEGIN ' + #13#10 +
      '          EXCEPTION gd_e_block; ' + #13#10 +
      '        END ' + #13#10 +
      '      END ' + #13#10 +
      '    END ' + #13#10 +
      '  END ' + #13#10 +
      'END ';
    ExecQuery;

    Close;
    SQL.Text :=
      'CREATE OR ALTER TRIGGER inv_bi_card_block FOR inv_card ' + #13#10 +
      '  INACTIVE ' + #13#10 +
      '  BEFORE INSERT ' + #13#10 +
      '  POSITION 28017 ' + #13#10 +
      'AS ' + #13#10 +
      '  DECLARE VARIABLE D DATE; ' + #13#10 +
      '  DECLARE VARIABLE IG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE BG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE DT INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE F INTEGER; ' + #13#10 +
      'BEGIN ' + #13#10 +
      '  IF (GEN_ID(gd_g_block, 0) > 0) THEN ' + #13#10 +
      '  BEGIN ' + #13#10 +
      '    SELECT doc.documentdate, doc.documenttypekey ' + #13#10 +
      '    FROM gd_document doc ' + #13#10 +
      '    WHERE doc.id = NEW.documentkey ' + #13#10 +
      '    INTO :D, :DT; ' + #13#10 +
      '  ' + #13#10 +
      '    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT) ' + #13#10 +
      '      RETURNING_VALUES :F; ' + #13#10 +
      '  ' + #13#10 +
      '    IF(:F = 0) THEN ' + #13#10 +
      '    BEGIN ' + #13#10 +
      '      IF ((D - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        BG = GEN_ID(gd_g_block_group, 0); ' + #13#10 +
      '        IF (:BG = 0) THEN ' + #13#10 +
      '        BEGIN ' + #13#10 +
      '          EXCEPTION gd_e_block; ' + #13#10 +
      '        END ELSE ' + #13#10 +
      '        BEGIN ' + #13#10 +
      '          SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' + #13#10 +
      '            INTO :IG; ' + #13#10 +
      '          IF (BIN_AND(:BG, :IG) = 0) THEN ' + #13#10 +
      '          BEGIN ' + #13#10 +
      '            EXCEPTION gd_e_block; ' + #13#10 +
      '          END ' + #13#10 +
      '        END ' + #13#10 +
      '      END ' + #13#10 +
      '    END ' + #13#10 +
      '  END ' + #13#10 +
      'END ';
    ExecQuery;

    Close;
    SQL.Text :=
      'CREATE OR ALTER TRIGGER inv_bu_card_block FOR inv_card ' + #13#10 +
      '  INACTIVE ' + #13#10 +
      '  BEFORE UPDATE ' + #13#10 +
      '  POSITION 28017 ' + #13#10 +
      'AS ' + #13#10 +
      '  DECLARE VARIABLE D DATE; ' + #13#10 +
      '  DECLARE VARIABLE IG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE BG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE DT INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE F INTEGER; ' + #13#10 +
      'BEGIN ' + #13#10 +
      '  IF (GEN_ID(gd_g_block, 0) > 0) THEN ' + #13#10 +
      '  BEGIN ' + #13#10 +
      '    SELECT doc.documentdate, doc.documenttypekey ' + #13#10 +
      '    FROM gd_document doc ' + #13#10 +
      '    WHERE doc.id = NEW.documentkey ' + #13#10 +
      '    INTO :D, :DT; ' + #13#10 +
      '  ' + #13#10 +
      '    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT) ' + #13#10 +
      '      RETURNING_VALUES :F; ' + #13#10 +
      '  ' + #13#10 +
      '    IF(:F = 0) THEN ' + #13#10 +
      '    BEGIN ' + #13#10 +
      '      IF ((D - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        BG = GEN_ID(gd_g_block_group, 0); ' + #13#10 +
      '        IF (:BG = 0) THEN ' + #13#10 +
      '        BEGIN ' + #13#10 +
      '          EXCEPTION gd_e_block; ' + #13#10 +
      '        END ELSE ' + #13#10 +
      '        BEGIN ' + #13#10 +
      '          SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' + #13#10 +
      '            INTO :IG; ' + #13#10 +
      '          IF (BIN_AND(:BG, :IG) = 0) THEN ' + #13#10 +
      '          BEGIN ' + #13#10 +
      '            EXCEPTION gd_e_block; ' + #13#10 +
      '          END ' + #13#10 +
      '        END ' + #13#10 +
      '      END ' + #13#10 +
      '    END ' + #13#10 +
      '  END ' + #13#10 +
      'END ';
    ExecQuery;

    Close;
    SQL.Text :=
      'CREATE OR ALTER TRIGGER inv_bd_card_block FOR inv_card ' + #13#10 +
      '  INACTIVE ' + #13#10 +
      '  BEFORE DELETE ' + #13#10 +
      '  POSITION 28017 ' + #13#10 +
      'AS ' + #13#10 +
      '  DECLARE VARIABLE D DATE; ' + #13#10 +
      '  DECLARE VARIABLE IG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE BG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE DT INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE F INTEGER; ' + #13#10 +
      'BEGIN ' + #13#10 +
      '  IF (GEN_ID(gd_g_block, 0) > 0) THEN ' + #13#10 +
      '  BEGIN ' + #13#10 +
      '    SELECT doc.documentdate, doc.documenttypekey ' + #13#10 +
      '    FROM gd_document doc ' + #13#10 +
      '    WHERE doc.id = OLD.documentkey ' + #13#10 +
      '    INTO :D, :DT; ' + #13#10 +
      '  ' + #13#10 +
      '    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT) ' + #13#10 +
      '      RETURNING_VALUES :F; ' + #13#10 +
      '  ' + #13#10 +
      '    IF(:F = 0) THEN ' + #13#10 +
      '    BEGIN ' + #13#10 +
      '      IF ((D - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        BG = GEN_ID(gd_g_block_group, 0); ' + #13#10 +
      '        IF (:BG = 0) THEN ' + #13#10 +
      '        BEGIN ' + #13#10 +
      '          EXCEPTION gd_e_block; ' + #13#10 +
      '        END ELSE ' + #13#10 +
      '        BEGIN ' + #13#10 +
      '          SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' + #13#10 +
      '            INTO :IG; ' + #13#10 +
      '          IF (BIN_AND(:BG, :IG) = 0) THEN ' + #13#10 +
      '          BEGIN ' + #13#10 +
      '            EXCEPTION gd_e_block; ' + #13#10 +
      '          END ' + #13#10 +
      '        END ' + #13#10 +
      '      END ' + #13#10 +
      '    END ' + #13#10 +
      '  END ' + #13#10 +
      'END ';
    ExecQuery;

    Close;
    SQL.Text :=
      'CREATE OR ALTER TRIGGER inv_bi_movement_block FOR inv_movement ' + #13#10 +
      '  INACTIVE ' + #13#10 +
      '  BEFORE INSERT ' + #13#10 +
      '  POSITION 28017 ' + #13#10 +
      'AS ' + #13#10 +
      '  DECLARE VARIABLE IG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE BG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE DT INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE F INTEGER; ' + #13#10 +
      'BEGIN ' + #13#10 +
      '  IF ((NEW.movementdate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN ' + #13#10 +
      '  BEGIN ' + #13#10 +
      '    SELECT d.documenttypekey ' + #13#10 +
      '    FROM gd_document d ' + #13#10 +
      '    WHERE d.id = NEW.documentkey ' + #13#10 +
      '    INTO :DT; ' + #13#10 +
      '  ' + #13#10 +
      '    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT) ' + #13#10 +
      '      RETURNING_VALUES :F; ' + #13#10 +
      '  ' + #13#10 +
      '    IF(:F = 0) THEN ' + #13#10 +
      '    BEGIN ' + #13#10 +
      '      BG = GEN_ID(gd_g_block_group, 0); ' + #13#10 +
      '      IF (:BG = 0) THEN ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        EXCEPTION gd_e_block; ' + #13#10 +
      '      END ELSE ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' + #13#10 +
      '          INTO :IG; ' + #13#10 +
      '        IF (BIN_AND(:BG, :IG) = 0) THEN ' + #13#10 +
      '        BEGIN ' + #13#10 +
      '          EXCEPTION gd_e_block; ' + #13#10 +
      '        END ' + #13#10 +
      '      END ' + #13#10 +
      '    END ' + #13#10 +
      '  END ' + #13#10 +
      'END ';
    ExecQuery;

    Close;
    SQL.Text :=
      'CREATE OR ALTER TRIGGER inv_bu_movement_block FOR inv_movement ' + #13#10 +
      '  INACTIVE ' + #13#10 +
      '  BEFORE UPDATE ' + #13#10 +
      '  POSITION 28017 ' + #13#10 +
      'AS ' + #13#10 +
      '  DECLARE VARIABLE IG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE BG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE DT INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE F INTEGER; ' + #13#10 +
      'BEGIN ' + #13#10 +
      '  IF (((NEW.movementdate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_block, 0)) ' + #13#10 +
      '      OR ((OLD.movementdate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_block, 0))) THEN ' + #13#10 +
      '  BEGIN ' + #13#10 +
      '    SELECT d.documenttypekey ' + #13#10 +
      '    FROM gd_document d ' + #13#10 +
      '    WHERE d.id = NEW.documentkey ' + #13#10 +
      '    INTO :DT; ' + #13#10 +
      '  ' + #13#10 +
      '    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT) ' + #13#10 +
      '      RETURNING_VALUES :F; ' + #13#10 +
      '  ' + #13#10 +
      '    IF(:F = 0) THEN ' + #13#10 +
      '    BEGIN ' + #13#10 +
      '      BG = GEN_ID(gd_g_block_group, 0); ' + #13#10 +
      '      IF (:BG = 0) THEN ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        EXCEPTION gd_e_block; ' + #13#10 +
      '      END ELSE ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' + #13#10 +
      '          INTO :IG; ' + #13#10 +
      '        IF (BIN_AND(:BG, :IG) = 0) THEN ' + #13#10 +
      '        BEGIN ' + #13#10 +
      '          EXCEPTION gd_e_block; ' + #13#10 +
      '        END ' + #13#10 +
      '      END ' + #13#10 +
      '    END ' + #13#10 +
      '  END ' + #13#10 +
      'END ';
    ExecQuery;

    Close;
    SQL.Text :=
      'CREATE OR ALTER TRIGGER inv_bd_movement_block FOR inv_movement ' + #13#10 +
      '  INACTIVE ' + #13#10 +
      '  BEFORE DELETE ' + #13#10 +
      '  POSITION 28017 ' + #13#10 +
      'AS ' + #13#10 +
      '  DECLARE VARIABLE IG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE BG INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE DT INTEGER; ' + #13#10 +
      '  DECLARE VARIABLE F INTEGER; ' + #13#10 +
      'BEGIN ' + #13#10 +
      '  IF ((OLD.movementdate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN ' + #13#10 +
      '  BEGIN ' + #13#10 +
      '    SELECT d.documenttypekey ' + #13#10 +
      '    FROM gd_document d ' + #13#10 +
      '    WHERE d.id = OLD.documentkey ' + #13#10 +
      '    INTO :DT; ' + #13#10 +
      '  ' + #13#10 +
      '    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT) ' + #13#10 +
      '      RETURNING_VALUES :F; ' + #13#10 +
      '  ' + #13#10 +
      '    IF(:F = 0) THEN ' + #13#10 +
      '    BEGIN ' + #13#10 +
      '      BG = GEN_ID(gd_g_block_group, 0); ' + #13#10 +
      '      IF (:BG = 0) THEN ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        EXCEPTION gd_e_block; ' + #13#10 +
      '      END ELSE ' + #13#10 +
      '      BEGIN ' + #13#10 +
      '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' + #13#10 +
      '          INTO :IG; ' + #13#10 +
      '        IF (BIN_AND(:BG, :IG) = 0) THEN ' + #13#10 +
      '        BEGIN ' + #13#10 +
      '          EXCEPTION gd_e_block; ' + #13#10 +
      '        END ' + #13#10 +
      '      END ' + #13#10 +
      '    END ' + #13#10 +
      '  END ' + #13#10 +
      'END ';
    ExecQuery;
    Close;
  finally
    FIBSQL.Free;
  end;
end;

procedure ModifyBlockTriggers4(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      _ModifyBlockTriggers(FTransaction);

      FIBSQL := TIBSQL.Create(nil);
      with FIBSQL do
      try
        Transaction := FTransaction;
        ParamCheck := False;

        SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (89, ''0000.0001.0000.0117'', ''31.01.2007'', ''Some internal changes'') ' +
          '  MATCHING (id)';
        ExecQuery;

        Close;
        SQL.Text := 'SELECT rdb$trigger_name FROM rdb$triggers WHERE rdb$trigger_name = ''GD_COMMAND_BU'' ';
        ExecQuery;

        if not EOF then
        begin
          Close;
          SQL.Text := 'DROP TRIGGER gd_command_bu ';
          ExecQuery;
        end;

        Close;
        SQL.Text := 'SELECT rdb$trigger_name FROM rdb$triggers WHERE rdb$trigger_name = ''GD_AU_COMMAND'' ';
        ExecQuery;

        if not EOF then
        begin
          Close;
          SQL.Text := 'DROP TRIGGER gd_au_command ';
          ExecQuery;
        end;

        Close;
        SQL.Text :=
          'ALTER TRIGGER gd_bi_command ACTIVE BEFORE INSERT POSITION 0 '#13#10 +
          'AS BEGIN '#13#10 +
          '  IF (NEW.ID IS NULL) THEN '#13#10 +
          '    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);'#13#10 +
          'END';
        ExecQuery;

        Close;
        SQL.Text := 'SELECT rdb$trigger_name FROM rdb$triggers WHERE rdb$trigger_name = ''GD_AIU_COMMAND'' ';
        ExecQuery;

        if not EOF then
        begin
          Close;
          SQL.Text := 'DROP TRIGGER gd_aiu_command ';
          ExecQuery;
        end;

        Close;
        SQL.Text :=
          'CREATE TRIGGER gd_aiu_command FOR gd_command '#13#10 +
          '  AFTER INSERT OR UPDATE '#13#10 +
          '  POSITION 100 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  UPDATE gd_command SET aview = NEW.aview, achag = NEW.achag, afull = NEW.afull '#13#10 +
          '  WHERE classname = NEW.classname '#13#10 +
          '    AND COALESCE(subtype, '''') = COALESCE(NEW.subtype, '''') '#13#10 +
          '    AND ((aview <> NEW.aview) OR (achag <> NEW.achag) OR (afull <> NEW.afull)) '#13#10 +
          '    AND id <> NEW.id; '#13#10 +
          'END';
        ExecQuery;

        Close;
        SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (90, ''0000.0001.0000.0118'', ''04.02.2007'', ''Some internal changes'') ' +
          '  MATCHING (id) ';
        ExecQuery;

        Close;
      finally
        FIBSQL.Free;
      end;

      FTransaction.Commit;
    except
      on E: Exception do
        Log('Œ¯Ë·Í‡: ' + E.Message);
    end;
  finally
    if FTransaction.InTransaction then
      FTransaction.Rollback;
    FTransaction.Free;
  end;
end;

end.
