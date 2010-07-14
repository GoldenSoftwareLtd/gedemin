
unit mdf_AddDTBlock;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit, mdf_dlgDefaultCardOfAccount_unit, Forms,
  Windows, Controls;

procedure AddDTBlock(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript, classes;

procedure AddDTBlock(IBDB: TIBDatabase; Log: TModifyLog);
var
  IBTr: TIBTransaction;
  q: TIBSQL;
begin
  IBTr := TIBTransaction.Create(nil);
  try
    IBTr.DefaultDatabase := IBDB;
    IBTr.StartTransaction;

    q := TIBSQL.Create(nil);
    q.Transaction := IBTr;
    q.ParamCheck := False;

    try
      {try
        q.SQL.Text := 'CREATE GENERATOR gd_g_block_group ';
        q.ExecQuery;
      except
      end;

      q.SQL.Text :=
        'SET GENERATOR gd_g_block_group TO 0 ';
      q.ExecQuery;

      try
        q.SQL.Text :=
          'CREATE OR ALTER PROCEDURE gd_p_exclude_block_dt(DT INTEGER)'#13#10 +
          '  RETURNS(F INTEGER)'#13#10 +
          'AS'#13#10 +
          'BEGIN'#13#10 +
          '  F = 0;'#13#10 +
          'END';
        q.ExecQuery;
      except
        on E: Exception do
          Log('Ошибка:' +  E.Message);
      end;

      try
        q.SQL.Text :=
          'GRANT EXECUTE ON PROCEDURE GD_P_EXCLUDE_BLOCK_DT TO ADMINISTRATOR';
        q.ExecQuery;
      except
        on E: Exception do
          Log('Ошибка:' +  E.Message);
      end;

      try
        q.SQL.Text :=
          'ALTER TRIGGER ac_bi_entry_block '#13#10 +
          '  INACTIVE'#13#10 +
          '  BEFORE INSERT'#13#10 +
          '  POSITION 28017'#13#10 +
          'AS'#13#10 +
          '  DECLARE VARIABLE IG INTEGER;'#13#10 +
          '  DECLARE VARIABLE BG INTEGER;'#13#10 +
          '  DECLARE VARIABLE DT INTEGER;'#13#10 +
          '  DECLARE VARIABLE F INTEGER;'#13#10 +
          'BEGIN'#13#10 +
          '  IF (CAST(NEW.entrydate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN'#13#10 +
          '  BEGIN'#13#10 +
          '    SELECT d.documenttypekey'#13#10 +
          '    FROM gd_document d'#13#10 +
          '      JOIN ac_record r ON r.documentkey = d.id'#13#10 +
          '    WHERE'#13#10 +
          '      r.id = NEW.recordkey'#13#10 +
          '    INTO'#13#10 +
          '      :DT;'#13#10 +
          ''#13#10 +
          '    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)'#13#10 +
          '      RETURNING_VALUES :F;'#13#10 +
          ''#13#10 +
          '    IF(:F = 0) THEN'#13#10 +
          '    BEGIN'#13#10 +
          '      BG = GEN_ID(gd_g_block_group, 0);'#13#10 +
          '      IF (:BG = 0) THEN'#13#10 +
          '      BEGIN'#13#10 +
          '        EXCEPTION gd_e_block;'#13#10 +
          '      END ELSE'#13#10 +
          '      BEGIN'#13#10 +
          '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER'#13#10 +
          '          INTO :IG;'#13#10 +
          '        IF (BIN_AND(:BG, :IG) = 0) THEN'#13#10 +
          '        BEGIN'#13#10 +
          '          EXCEPTION gd_e_block;'#13#10 +
          '        END'#13#10 +
          '      END'#13#10 +
          '    END  '#13#10 +
          '  END'#13#10 +
          'END';
        q.ExecQuery;
      except
        on E: Exception do
          Log('Ошибка:' +  E.Message);
      end;

      try
        q.SQL.Text :=
          'ALTER TRIGGER ac_bu_entry_block '#13#10 +
          '  INACTIVE'#13#10 +
          '  BEFORE UPDATE'#13#10 +
          '  POSITION 28017'#13#10 +
          'AS'#13#10 +
          '  DECLARE VARIABLE IG INTEGER;'#13#10 +
          '  DECLARE VARIABLE BG INTEGER;'#13#10 +
          '  DECLARE VARIABLE DT INTEGER;'#13#10 +
          '  DECLARE VARIABLE F INTEGER;'#13#10 +
          'BEGIN'#13#10 +
          '  IF (CAST(NEW.entrydate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN'#13#10 +
          '  BEGIN'#13#10 +
          '    SELECT d.documenttypekey'#13#10 +
          '    FROM gd_document d'#13#10 +
          '      JOIN ac_record r ON r.documentkey = d.id'#13#10 +
          '    WHERE'#13#10 +
          '      r.id = NEW.recordkey'#13#10 +
          '    INTO'#13#10 +
          '      :DT;'#13#10 +
          ''#13#10 +
          '    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)'#13#10 +
          '      RETURNING_VALUES :F;'#13#10 +
          ''#13#10 +
          '    IF(:F = 0) THEN'#13#10 +
          '    BEGIN'#13#10 +
          '      BG = GEN_ID(gd_g_block_group, 0);'#13#10 +
          '      IF (:BG = 0) THEN'#13#10 +
          '      BEGIN'#13#10 +
          '        EXCEPTION gd_e_block;'#13#10 +
          '      END ELSE'#13#10 +
          '      BEGIN'#13#10 +
          '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER'#13#10 +
          '          INTO :IG;'#13#10 +
          '        IF (BIN_AND(:BG, :IG) = 0) THEN'#13#10 +
          '        BEGIN'#13#10 +
          '          EXCEPTION gd_e_block;'#13#10 +
          '        END'#13#10 +
          '      END'#13#10 +
          '    END'#13#10 +
          '  END'#13#10 +
          'END';
        q.ExecQuery;
      except
        on E: Exception do
          Log('Ошибка:' +  E.Message);
      end;

      try
        q.SQL.Text :=
          'ALTER TRIGGER ac_bd_entry_block '#13#10 +
          '  INACTIVE'#13#10 +
          '  BEFORE DELETE'#13#10 +
          '  POSITION 28017'#13#10 +
          'AS'#13#10 +
          '  DECLARE VARIABLE IG INTEGER;'#13#10 +
          '  DECLARE VARIABLE BG INTEGER;'#13#10 +
          '  DECLARE VARIABLE DT INTEGER;'#13#10 +
          '  DECLARE VARIABLE F INTEGER;'#13#10 +
          'BEGIN'#13#10 +
          '  IF (CAST(OLD.entrydate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN'#13#10 +
          '  BEGIN'#13#10 +
          '    SELECT d.documenttypekey'#13#10 +
          '    FROM gd_document d'#13#10 +
          '      JOIN ac_record r ON r.documentkey = d.id'#13#10 +
          '    WHERE'#13#10 +
          '      r.id = OLD.recordkey'#13#10 +
          '    INTO'#13#10 +
          '      :DT;'#13#10 +
          ''#13#10 +
          '    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)'#13#10 +
          '      RETURNING_VALUES :F;'#13#10 +
          ''#13#10 +
          '    IF(:F = 0) THEN'#13#10 +
          '    BEGIN'#13#10 +
          '      BG = GEN_ID(gd_g_block_group, 0);'#13#10 +
          '      IF (:BG = 0) THEN'#13#10 +
          '      BEGIN'#13#10 +
          '        EXCEPTION gd_e_block;'#13#10 +
          '      END ELSE'#13#10 +
          '      BEGIN'#13#10 +
          '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER'#13#10 +
          '          INTO :IG;'#13#10 +
          '        IF (BIN_AND(:BG, :IG) = 0) THEN'#13#10 +
          '        BEGIN'#13#10 +
          '          EXCEPTION gd_e_block;'#13#10 +
          '        END'#13#10 +
          '      END'#13#10 +
          '    END'#13#10 +
          '  END'#13#10 +
          'END';
        q.ExecQuery;
      except
        on E: Exception do
          Log('Ошибка:' +  E.Message);
      end;

      try
        q.SQL.Text :=
          'ALTER TRIGGER gd_bi_document_block '#13#10 +
          '  INACTIVE'#13#10 +
          '  BEFORE INSERT'#13#10 +
          '  POSITION 28017'#13#10 +
          'AS'#13#10 +
          '  DECLARE VARIABLE IG INTEGER;'#13#10 +
          '  DECLARE VARIABLE BG INTEGER;'#13#10 +
          '  DECLARE VARIABLE F INTEGER;'#13#10 +
          'BEGIN'#13#10 +
          '  IF (CAST(NEW.documentdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN'#13#10 +
          '  BEGIN'#13#10 +
          '    EXECUTE PROCEDURE gd_p_exclude_block_dt (NEW.documenttypekey)'#13#10 +
          '      RETURNING_VALUES :F;'#13#10 +
          ''#13#10 +
          '    IF (:F = 0) THEN'#13#10 +
          '    BEGIN'#13#10 +
          '      BG = GEN_ID(gd_g_block_group, 0);'#13#10 +
          '      IF (:BG = 0) THEN'#13#10 +
          '      BEGIN'#13#10 +
          '        EXCEPTION gd_e_block;'#13#10 +
          '      END ELSE'#13#10 +
          '      BEGIN'#13#10 +
          '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER'#13#10 +
          '          INTO :IG;'#13#10 +
          '        IF (BIN_AND(:BG, :IG) = 0) THEN'#13#10 +
          '        BEGIN'#13#10 +
          '          EXCEPTION gd_e_block;'#13#10 +
          '        END'#13#10 +
          '      END'#13#10 +
          '    END'#13#10 +
          '  END'#13#10 +
          'END';
        q.ExecQuery;
      except
        on E: Exception do
          Log('Ошибка:' +  E.Message);
      end;

      try
        q.SQL.Text :=
          'ALTER TRIGGER gd_bu_document_block '#13#10 +
          '  INACTIVE'#13#10 +
          '  BEFORE UPDATE'#13#10 +
          '  POSITION 28017'#13#10 +
          'AS'#13#10 +
          '  DECLARE VARIABLE IG INTEGER;'#13#10 +
          '  DECLARE VARIABLE BG INTEGER;'#13#10 +
          '  DECLARE VARIABLE F INTEGER;'#13#10 +
          'BEGIN'#13#10 +
          '  IF (CAST(NEW.documentdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN'#13#10 +
          '  BEGIN'#13#10 +
          '    EXECUTE PROCEDURE gd_p_exclude_block_dt (NEW.documenttypekey)'#13#10 +
          '      RETURNING_VALUES :F;'#13#10 +
          ''#13#10 +
          '    IF (:F = 0) THEN'#13#10 +
          '    BEGIN'#13#10 +
          '      BG = GEN_ID(gd_g_block_group, 0);'#13#10 +
          '      IF (:BG = 0) THEN'#13#10 +
          '      BEGIN'#13#10 +
          '        EXCEPTION gd_e_block;'#13#10 +
          '      END ELSE'#13#10 +
          '      BEGIN'#13#10 +
          '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER'#13#10 +
          '          INTO :IG;'#13#10 +
          '        IF (BIN_AND(:BG, :IG) = 0) THEN'#13#10 +
          '        BEGIN'#13#10 +
          '          EXCEPTION gd_e_block;'#13#10 +
          '        END'#13#10 +
          '      END'#13#10 +
          '    END'#13#10 +
          '  END'#13#10 +
          'END';
        q.ExecQuery;
      except
        on E: Exception do
          Log('Ошибка:' +  E.Message);
      end;

      try
        q.SQL.Text :=
          'ALTER TRIGGER gd_bd_document_block '#13#10 +
          '  INACTIVE'#13#10 +
          '  BEFORE DELETE'#13#10 +
          '  POSITION 28017'#13#10 +
          'AS'#13#10 +
          '  DECLARE VARIABLE IG INTEGER;'#13#10 +
          '  DECLARE VARIABLE BG INTEGER;'#13#10 +
          '  DECLARE VARIABLE F INTEGER;'#13#10 +
          'BEGIN'#13#10 +
          '  IF (CAST(OLD.documentdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN'#13#10 +
          '  BEGIN'#13#10 +
          '    EXECUTE PROCEDURE gd_p_exclude_block_dt (OLD.documenttypekey)'#13#10 +
          '      RETURNING_VALUES :F;'#13#10 +
          ''#13#10 +
          '    IF (:F = 0) THEN'#13#10 +
          '    BEGIN'#13#10 +
          '      BG = GEN_ID(gd_g_block_group, 0);'#13#10 +
          '      IF (:BG = 0) THEN'#13#10 +
          '      BEGIN'#13#10 +
          '        EXCEPTION gd_e_block;'#13#10 +
          '      END ELSE'#13#10 +
          '      BEGIN'#13#10 +
          '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER'#13#10 +
          '          INTO :IG;'#13#10 +
          '        IF (BIN_AND(:BG, :IG) = 0) THEN'#13#10 +
          '        BEGIN'#13#10 +
          '          EXCEPTION gd_e_block;'#13#10 +
          '        END'#13#10 +
          '      END'#13#10 +
          '    END'#13#10 +
          '  END'#13#10 +
          'END';
        q.ExecQuery;
      except
        on E: Exception do
          Log('Ошибка:' +  E.Message);
      end;

      try
        q.SQL.Text :=
          'ALTER TRIGGER inv_bi_card_block '#13#10 +
          '  INACTIVE'#13#10 +
          '  BEFORE INSERT'#13#10 +
          '  POSITION 28017'#13#10 +
          'AS'#13#10 +
          '  DECLARE VARIABLE D DATE;'#13#10 +
          '  DECLARE VARIABLE IG INTEGER;'#13#10 +
          '  DECLARE VARIABLE BG INTEGER;'#13#10 +
          '  DECLARE VARIABLE DT INTEGER;'#13#10 +
          '  DECLARE VARIABLE F INTEGER;'#13#10 +
          'BEGIN'#13#10 +
          '  IF (GEN_ID(gd_g_block, 0) > 0) THEN'#13#10 +
          '  BEGIN'#13#10 +
          '    SELECT doc.documentdate, doc.documenttypekey'#13#10 +
          '    FROM gd_document doc'#13#10 +
          '    WHERE doc.id = NEW.documentkey'#13#10 +
          '    INTO :D, :DT;'#13#10 +
          ''#13#10 +
          '    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)'#13#10 +
          '      RETURNING_VALUES :F;'#13#10 +
          ''#13#10 +
          '    IF(:F = 0) THEN'#13#10 +
          '    BEGIN'#13#10 +
          '      IF (CAST(D AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN'#13#10 +
          '      BEGIN'#13#10 +
          '        BG = GEN_ID(gd_g_block_group, 0);'#13#10 +
          '        IF (:BG = 0) THEN'#13#10 +
          '        BEGIN'#13#10 +
          '          EXCEPTION gd_e_block;'#13#10 +
          '        END ELSE'#13#10 +
          '        BEGIN'#13#10 +
          '          SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER'#13#10 +
          '            INTO :IG;'#13#10 +
          '          IF (BIN_AND(:BG, :IG) = 0) THEN'#13#10 +
          '          BEGIN'#13#10 +
          '            EXCEPTION gd_e_block;'#13#10 +
          '          END'#13#10 +
          '        END'#13#10 +
          '      END'#13#10 +
          '    END'#13#10 +
          '  END'#13#10 +
          'END';
        q.ExecQuery;
      except
        on E: Exception do
          Log('Ошибка:' +  E.Message);
      end;

      try
        q.SQL.Text :=
          'ALTER TRIGGER inv_bu_card_block '#13#10 +
          '  INACTIVE'#13#10 +
          '  BEFORE UPDATE'#13#10 +
          '  POSITION 28017'#13#10 +
          'AS'#13#10 +
          '  DECLARE VARIABLE D DATE;'#13#10 +
          '  DECLARE VARIABLE IG INTEGER;'#13#10 +
          '  DECLARE VARIABLE BG INTEGER;'#13#10 +
          '  DECLARE VARIABLE DT INTEGER;'#13#10 +
          '  DECLARE VARIABLE F INTEGER;'#13#10 +
          'BEGIN'#13#10 +
          '  IF (GEN_ID(gd_g_block, 0) > 0) THEN'#13#10 +
          '  BEGIN'#13#10 +
          '    SELECT doc.documentdate, doc.documenttypekey'#13#10 +
          '    FROM gd_document doc'#13#10 +
          '    WHERE doc.id = NEW.documentkey'#13#10 +
          '    INTO :D, :DT;'#13#10 +
          ''#13#10 +
          '    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)'#13#10 +
          '      RETURNING_VALUES :F;'#13#10 +
          ''#13#10 +
          '    IF(:F = 0) THEN'#13#10 +
          '    BEGIN'#13#10 +
          '      IF (CAST(D AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN'#13#10 +
          '      BEGIN'#13#10 +
          '        BG = GEN_ID(gd_g_block_group, 0);'#13#10 +
          '        IF (:BG = 0) THEN'#13#10 +
          '        BEGIN'#13#10 +
          '          EXCEPTION gd_e_block;'#13#10 +
          '        END ELSE'#13#10 +
          '        BEGIN'#13#10 +
          '          SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER'#13#10 +
          '            INTO :IG;'#13#10 +
          '          IF (BIN_AND(:BG, :IG) = 0) THEN'#13#10 +
          '          BEGIN'#13#10 +
          '            EXCEPTION gd_e_block;'#13#10 +
          '          END'#13#10 +
          '        END'#13#10 +
          '      END'#13#10 +
          '    END'#13#10 +
          '  END'#13#10 +
          'END';
        q.ExecQuery;
      except
        on E: Exception do
          Log('Ошибка:' +  E.Message);
      end;

      try
        q.SQL.Text :=
          'ALTER TRIGGER inv_bd_card_block '#13#10 +
          '  INACTIVE'#13#10 +
          '  BEFORE DELETE'#13#10 +
          '  POSITION 28017'#13#10 +
          'AS'#13#10 +
          '  DECLARE VARIABLE D DATE;'#13#10 +
          '  DECLARE VARIABLE IG INTEGER;'#13#10 +
          '  DECLARE VARIABLE BG INTEGER;'#13#10 +
          '  DECLARE VARIABLE DT INTEGER;'#13#10 +
          '  DECLARE VARIABLE F INTEGER;'#13#10 +
          'BEGIN'#13#10 +
          '  IF (GEN_ID(gd_g_block, 0) > 0) THEN'#13#10 +
          '  BEGIN'#13#10 +
          '    SELECT doc.documentdate, doc.documenttypekey'#13#10 +
          '    FROM gd_document doc'#13#10 +
          '    WHERE doc.id = OLD.documentkey'#13#10 +
          '    INTO :D, :DT;'#13#10 +
          ''#13#10 +
          '    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)'#13#10 +
          '      RETURNING_VALUES :F;'#13#10 +
          ''#13#10 +
          '    IF(:F = 0) THEN'#13#10 +
          '    BEGIN'#13#10 +
          '      IF (CAST(D AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN'#13#10 +
          '      BEGIN'#13#10 +
          '        BG = GEN_ID(gd_g_block_group, 0);'#13#10 +
          '        IF (:BG = 0) THEN'#13#10 +
          '        BEGIN'#13#10 +
          '          EXCEPTION gd_e_block;'#13#10 +
          '        END ELSE'#13#10 +
          '        BEGIN'#13#10 +
          '          SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER'#13#10 +
          '            INTO :IG;'#13#10 +
          '          IF (BIN_AND(:BG, :IG) = 0) THEN'#13#10 +
          '          BEGIN'#13#10 +
          '            EXCEPTION gd_e_block;'#13#10 +
          '          END'#13#10 +
          '        END'#13#10 +
          '      END'#13#10 +
          '    END'#13#10 +
          '  END'#13#10 +
          'END';
        q.ExecQuery;
      except
        on E: Exception do
          Log('Ошибка:' +  E.Message);
      end;

      try
        q.SQL.Text :=
          'ALTER TRIGGER inv_bi_movement_block '#13#10 +
          '  INACTIVE'#13#10 +
          '  BEFORE INSERT'#13#10 +
          '  POSITION 28017'#13#10 +
          'AS'#13#10 +
          '  DECLARE VARIABLE IG INTEGER;'#13#10 +
          '  DECLARE VARIABLE BG INTEGER;'#13#10 +
          '  DECLARE VARIABLE DT INTEGER;'#13#10 +
          '  DECLARE VARIABLE F INTEGER;'#13#10 +
          'BEGIN'#13#10 +
          '  IF (CAST(NEW.movementdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN'#13#10 +
          '  BEGIN'#13#10 +
          '    SELECT d.documenttypekey'#13#10 +
          '    FROM gd_document d'#13#10 +
          '    WHERE d.id = NEW.documentkey'#13#10 +
          '    INTO :DT;'#13#10 +
          ''#13#10 +
          '    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)'#13#10 +
          '      RETURNING_VALUES :F;'#13#10 +
          ''#13#10 +
          '    IF(:F = 0) THEN'#13#10 +
          '    BEGIN'#13#10 +
          '      BG = GEN_ID(gd_g_block_group, 0);'#13#10 +
          '      IF (:BG = 0) THEN'#13#10 +
          '      BEGIN'#13#10 +
          '        EXCEPTION gd_e_block;'#13#10 +
          '      END ELSE'#13#10 +
          '      BEGIN'#13#10 +
          '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER'#13#10 +
          '          INTO :IG;'#13#10 +
          '        IF (BIN_AND(:BG, :IG) = 0) THEN'#13#10 +
          '        BEGIN'#13#10 +
          '          EXCEPTION gd_e_block;'#13#10 +
          '        END'#13#10 +
          '      END'#13#10 +
          '    END'#13#10 +
          '  END'#13#10 +
          'END';
        q.ExecQuery;
      except
        on E: Exception do
          Log('Ошибка:' +  E.Message);
      end;

      try
        q.SQL.Text :=
          'ALTER TRIGGER inv_bu_movement_block '#13#10 +
          '  INACTIVE'#13#10 +
          '  BEFORE UPDATE'#13#10 +
          '  POSITION 28017'#13#10 +
          'AS'#13#10 +
          '  DECLARE VARIABLE IG INTEGER;'#13#10 +
          '  DECLARE VARIABLE BG INTEGER;'#13#10 +
          '  DECLARE VARIABLE DT INTEGER;'#13#10 +
          '  DECLARE VARIABLE F INTEGER;'#13#10 +
          'BEGIN'#13#10 +
          '  IF (CAST(NEW.movementdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN'#13#10 +
          '  BEGIN'#13#10 +
          '    SELECT d.documenttypekey'#13#10 +
          '    FROM gd_document d'#13#10 +
          '    WHERE d.id = NEW.documentkey'#13#10 +
          '    INTO :DT;'#13#10 +
          ''#13#10 +
          '    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)'#13#10 +
          '      RETURNING_VALUES :F;'#13#10 +
          ''#13#10 +
          '    IF(:F = 0) THEN'#13#10 +
          '    BEGIN'#13#10 +
          '      BG = GEN_ID(gd_g_block_group, 0);'#13#10 +
          '      IF (:BG = 0) THEN'#13#10 +
          '      BEGIN'#13#10 +
          '        EXCEPTION gd_e_block;'#13#10 +
          '      END ELSE'#13#10 +
          '      BEGIN'#13#10 +
          '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER'#13#10 +
          '          INTO :IG;'#13#10 +
          '        IF (BIN_AND(:BG, :IG) = 0) THEN'#13#10 +
          '        BEGIN'#13#10 +
          '          EXCEPTION gd_e_block;'#13#10 +
          '        END'#13#10 +
          '      END'#13#10 +
          '    END'#13#10 +
          '  END'#13#10 +
          'END';
        q.ExecQuery;
      except
        on E: Exception do
          Log('Ошибка:' +  E.Message);
      end;

      try
        q.SQL.Text :=
          'ALTER TRIGGER inv_bd_movement_block '#13#10 +
          '  INACTIVE'#13#10 +
          '  BEFORE DELETE'#13#10 +
          '  POSITION 28017'#13#10 +
          'AS'#13#10 +
          '  DECLARE VARIABLE IG INTEGER;'#13#10 +
          '  DECLARE VARIABLE BG INTEGER;'#13#10 +
          '  DECLARE VARIABLE DT INTEGER;'#13#10 +
          '  DECLARE VARIABLE F INTEGER;'#13#10 +
          'BEGIN'#13#10 +
          '  IF (CAST(OLD.movementdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN'#13#10 +
          '  BEGIN'#13#10 +
          '    SELECT d.documenttypekey'#13#10 +
          '    FROM gd_document d'#13#10 +
          '    WHERE d.id = OLD.documentkey'#13#10 +
          '    INTO :DT;'#13#10 +
          ''#13#10 +
          '    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)'#13#10 +
          '      RETURNING_VALUES :F;'#13#10 +
          ''#13#10 +
          '    IF(:F = 0) THEN'#13#10 +
          '    BEGIN'#13#10 +
          '      BG = GEN_ID(gd_g_block_group, 0);'#13#10 +
          '      IF (:BG = 0) THEN'#13#10 +
          '      BEGIN'#13#10 +
          '        EXCEPTION gd_e_block;'#13#10 +
          '      END ELSE'#13#10 +
          '      BEGIN'#13#10 +
          '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER'#13#10 +
          '          INTO :IG;'#13#10 +
          '        IF (BIN_AND(:BG, :IG) = 0) THEN'#13#10 +
          '        BEGIN'#13#10 +
          '          EXCEPTION gd_e_block;'#13#10 +
          '        END'#13#10 +
          '      END'#13#10 +
          '    END'#13#10 +
          '  END'#13#10 +
          'END';
        q.ExecQuery;
      except
        on E: Exception do
          Log('Ошибка:' +  E.Message);
      end;

      try
        q.SQL.Text :=
          'ALTER TRIGGER inv_ad_movement'#13#10 +
          '  AFTER DELETE'#13#10 +
          '  POSITION 0'#13#10 +
          'AS'#13#10 +
          'BEGIN'#13#10 +
          '  IF (OLD.disabled = 0) THEN'#13#10 +
          '  BEGIN'#13#10 +
          '    /*'#13#10 +
          '    эта проверка тут излишняя.'#13#10 +
          ''#13#10 +
          '    IF (EXISTS('#13#10 +
          '      SELECT BALANCE'#13#10 +
          '      FROM INV_BALANCE'#13#10 +
          '      WHERE CARDKEY = OLD.CARDKEY AND CONTACTKEY = OLD.CONTACTKEY))'#13#10 +
          '    THEN BEGIN'#13#10 +
          '    */'#13#10 +
          '      UPDATE INV_BALANCE'#13#10 +
          '      SET'#13#10 +
          '        BALANCE = BALANCE - (OLD.DEBIT - OLD.CREDIT)'#13#10 +
          '      WHERE'#13#10 +
          '        CARDKEY = OLD.CARDKEY AND CONTACTKEY = OLD.CONTACTKEY;'#13#10 +
          '    /*'#13#10 +
          '    END'#13#10 +
          '    */'#13#10 +
          '  END'#13#10 +
          ''#13#10 +
          'END';
        q.ExecQuery;
      except
        on E: Exception do
          Log('Ошибка:' +  E.Message);
      end;

      try
        q.SQL.Text :=
          'ALTER TRIGGER INV_BU_BALANCE '#13#10 +
          'ACTIVE BEFORE UPDATE POSITION 0'#13#10 +
          'AS'#13#10 +
          '  DECLARE VARIABLE quantity NUMERIC(15, 4);'#13#10 +
          'BEGIN'#13#10 +
          '/*Тело триггера*/'#13#10 +
          '  IF (NEW.contactkey <> OLD.contactkey) THEN'#13#10 +
          '  BEGIN'#13#10 +
          '    /*'#13#10 +
          '    IF (EXISTS (SELECT * FROM inv_balance WHERE contactkey = NEW.contactkey AND'#13#10 +
          '      cardkey = NEW.cardkey))'#13#10 +
          '    THEN'#13#10 +
          '    BEGIN'#13#10 +
          '    */'#13#10 +
          '      quantity = NULL;'#13#10 +
          '      SELECT balance'#13#10 +
          '        FROM inv_balance'#13#10 +
          '        WHERE contactkey = NEW.contactkey AND cardkey = NEW.cardkey'#13#10 +
          '        INTO :quantity;'#13#10 +
          '      IF (NOT (:quantity IS NULL)) THEN'#13#10 +
          '      BEGIN'#13#10 +
          '        DELETE FROM inv_balance'#13#10 +
          '        WHERE'#13#10 +
          '          contactkey = NEW.contactkey AND cardkey = NEW.cardkey;'#13#10 +
          ''#13#10 +
          '        NEW.balance = NEW.balance + :quantity;'#13#10 +
          '      END'#13#10 +
          '    /*'#13#10 +
          '    END'#13#10 +
          '    */'#13#10 +
          '  END'#13#10 +
          'END';
        q.ExecQuery;
      except
        on E: Exception do
          Log('Ошибка:' +  E.Message);
      end;}

      q.SQL.Text := 'UPDATE inv_balance SET balance = 0 WHERE balance IS NULL ';
      q.ExecQuery;

      if FieldExist2('GD_PRECIOUSEMETAL', 'USR$GOODKEY', IBTr) then
      begin
        q.Close;
        q.SQL.Text :=
          'UPDATE gd_preciousemetal SET usr$goodkey = (SELECT FIRST 1 id FROM gd_good) WHERE usr$goodkey IS NULL';
        q.ExecQuery;
      end;

      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        'VALUES (76, ''0000.0001.0000.0104'', ''18.09.2006'', ''Ability to exclude some document types from block period added'') ' +
        'MATCHING (id) ';
      q.ExecQuery;

      IBTr.Commit;
    finally
      q.Free;
      IBTr.Free;
    end;

  except
    on E: Exception do
      Log('Ошибка:' +  E.Message);
  end;

end;

end.
