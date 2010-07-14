unit mdf_ModifyBlockTriggers2;

interface

uses
  IBDatabase, gdModify;

procedure ModifyBlockTriggers2(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;


procedure ModifyBlockTriggers2(IBDB: TIBDatabase; Log: TModifyLog);
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

        {SQL.Text :=
          'CREATE OR ALTER TRIGGER ac_bi_entry_block FOR ac_entry ' +
          '  INACTIVE ' +
          '  BEFORE INSERT ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          '  DECLARE VARIABLE BG INTEGER; ' +
          'BEGIN ' +
          '  IF (CAST(NEW.entrydate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '  BEGIN ' +
          '    IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '    BEGIN ' +
          '      EXCEPTION gd_e_block; ' +
          '    END ELSE ' +
          '    BEGIN ' +
          '      SELECT ingroup, GEN_ID(gd_g_block_group, 0) FROM gd_user WHERE ibname = CURRENT_USER ' +
          '        INTO :IG, :BG; ' +
          '      IF (BIN_AND(:BG, :IG) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE OR ALTER TRIGGER ac_bu_entry_block FOR ac_entry ' +
          '  INACTIVE ' +
          '  BEFORE UPDATE ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          '  DECLARE VARIABLE BG INTEGER; ' +
          'BEGIN ' +
          '  IF (CAST(NEW.entrydate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '  BEGIN ' +
          '    IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '    BEGIN ' +
          '      EXCEPTION gd_e_block; ' +
          '    END ELSE ' +
          '    BEGIN ' +
          '      SELECT ingroup, GEN_ID(gd_g_block_group, 0) FROM gd_user WHERE ibname = CURRENT_USER ' +
          '        INTO :IG, :BG; ' +
          '      IF (BIN_AND(:BG, :IG) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE OR ALTER TRIGGER ac_bd_entry_block FOR ac_entry ' +
          '  INACTIVE ' +
          '  BEFORE DELETE ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          '  DECLARE VARIABLE BG INTEGER; ' +
          'BEGIN ' +
          '  IF (CAST(OLD.entrydate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '  BEGIN ' +
          '    IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '    BEGIN ' +
          '      EXCEPTION gd_e_block; ' +
          '    END ELSE ' +
          '    BEGIN ' +
          '      SELECT ingroup, GEN_ID(gd_g_block_group, 0) FROM gd_user WHERE ibname = CURRENT_USER ' +
          '        INTO :IG, :BG; ' +
          '      IF (BIN_AND(:BG, :IG) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_bi_document_block FOR gd_document ' +
          '  INACTIVE ' +
          '  BEFORE INSERT ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          '  DECLARE VARIABLE BG INTEGER; ' +
          'BEGIN ' +
          '  IF (CAST(NEW.documentdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '  BEGIN ' +
          '    IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '    BEGIN ' +
          '      EXCEPTION gd_e_block; ' +
          '    END ELSE ' +
          '    BEGIN ' +
          '      SELECT ingroup, GEN_ID(gd_g_block_group, 0) FROM gd_user WHERE ibname = CURRENT_USER ' +
          '        INTO :IG, :BG; ' +
          '      IF (BIN_AND(:BG, :IG) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_bu_document_block FOR gd_document ' +
          '  INACTIVE ' +
          '  BEFORE UPDATE ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          '  DECLARE VARIABLE BG INTEGER; ' +
          'BEGIN ' +
          '  IF (CAST(NEW.documentdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '  BEGIN ' +
          '    IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '    BEGIN ' +
          '      EXCEPTION gd_e_block; ' +
          '    END ELSE ' +
          '    BEGIN ' +
          '      SELECT ingroup, GEN_ID(gd_g_block_group, 0) FROM gd_user WHERE ibname = CURRENT_USER ' +
          '        INTO :IG, :BG; ' +
          '      IF (BIN_AND(:BG, :IG) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_bd_document_block FOR gd_document ' +
          '  INACTIVE ' +
          '  BEFORE DELETE ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          '  DECLARE VARIABLE BG INTEGER; ' +
          'BEGIN ' +
          '  IF (CAST(OLD.documentdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '  BEGIN ' +
          '    IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '    BEGIN ' +
          '      EXCEPTION gd_e_block; ' +
          '    END ELSE ' +
          '    BEGIN ' +
          '      SELECT ingroup, GEN_ID(gd_g_block_group, 0) FROM gd_user WHERE ibname = CURRENT_USER ' +
          '        INTO :IG, :BG; ' +
          '      IF (BIN_AND(:BG, :IG) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE OR ALTER TRIGGER inv_bi_card_block FOR inv_card ' +
          '  INACTIVE ' +
          '  BEFORE INSERT ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE D DATE; ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          '  DECLARE VARIABLE BG INTEGER; ' +
          'BEGIN ' +
          '  IF (GEN_ID(gd_g_block, 0) > 0) THEN ' +
          '  BEGIN ' +
          '    SELECT doc.documentdate ' +
          '    FROM gd_document doc ' +
          '    WHERE doc.id = NEW.documentkey ' +
          '    INTO :D; ' +
          ' ' +
          '    IF (CAST(D AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '    BEGIN ' +
          '      IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ELSE ' +
          '      BEGIN ' +
          '        SELECT ingroup, GEN_ID(gd_g_block_group, 0) FROM gd_user WHERE ibname = CURRENT_USER ' +
          '          INTO :IG, :BG; ' +
          '        IF (BIN_AND(:BG, :IG) = 0) THEN ' +
          '        BEGIN ' +
          '          EXCEPTION gd_e_block; ' +
          '        END ' +
          '      END ' +
          '    END ' +
          '  END   ' +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE OR ALTER TRIGGER inv_bu_card_block FOR inv_card ' +
          '  INACTIVE ' +
          '  BEFORE UPDATE ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE D DATE; ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          '  DECLARE VARIABLE BG INTEGER; ' +
          'BEGIN ' +
          '  IF (GEN_ID(gd_g_block, 0) > 0) THEN ' +
          '  BEGIN ' +
          '    SELECT doc.documentdate ' +
          '    FROM gd_document doc ' +
          '    WHERE doc.id = NEW.documentkey ' +
          '    INTO :D; ' +
          ' ' +
          '    IF (CAST(D AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '    BEGIN ' +
          '      IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ELSE ' +
          '      BEGIN ' +
          '        SELECT ingroup, GEN_ID(gd_g_block_group, 0) FROM gd_user WHERE ibname = CURRENT_USER ' +
          '          INTO :IG, :BG; ' +
          '        IF (BIN_AND(:BG, :IG) = 0) THEN ' +
          '        BEGIN ' +
          '          EXCEPTION gd_e_block; ' +
          '        END ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE OR ALTER TRIGGER inv_bd_card_block FOR inv_card ' +
          '  INACTIVE ' +
          '  BEFORE DELETE ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE D DATE; ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          '  DECLARE VARIABLE BG INTEGER; ' +
          'BEGIN ' +
          '  IF (GEN_ID(gd_g_block, 0) > 0) THEN ' +
          '  BEGIN ' +
          '    SELECT doc.documentdate ' +
          '    FROM gd_document doc ' +
          '    WHERE doc.id = OLD.documentkey ' +
          '    INTO :D; ' +
          ' ' +
          '    IF (CAST(D AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '    BEGIN ' +
          '      IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ELSE ' +
          '      BEGIN ' +
          '        SELECT ingroup, GEN_ID(gd_g_block_group, 0) FROM gd_user WHERE ibname = CURRENT_USER ' +
          '          INTO :IG, :BG; ' +
          '        IF (BIN_AND(:BG, :IG) = 0) THEN ' +
          '        BEGIN ' +
          '          EXCEPTION gd_e_block; ' +
          '        END ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE OR ALTER TRIGGER inv_bi_movement_block FOR inv_movement ' +
          '  INACTIVE ' +
          '  BEFORE INSERT ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          '  DECLARE VARIABLE BG INTEGER; ' +
          'BEGIN ' +
          '  IF (CAST(NEW.movementdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '  BEGIN ' +
          '    IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '    BEGIN ' +
          '      EXCEPTION gd_e_block; ' +
          '    END ELSE ' +
          '    BEGIN ' +
          '      SELECT ingroup, GEN_ID(gd_g_block_group, 0) FROM gd_user WHERE ibname = CURRENT_USER ' +
          '        INTO :IG, :BG; ' +
          '      IF (BIN_AND(:BG, :IG) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE OR ALTER TRIGGER inv_bu_movement_block FOR inv_movement ' +
          '  INACTIVE ' +
          '  BEFORE UPDATE ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          '  DECLARE VARIABLE BG INTEGER; ' +
          'BEGIN ' +
          '  IF (CAST(NEW.movementdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '  BEGIN ' +
          '    IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '    BEGIN ' +
          '      EXCEPTION gd_e_block; ' +
          '    END ELSE ' +
          '    BEGIN ' +
          '      SELECT ingroup, GEN_ID(gd_g_block_group, 0) FROM gd_user WHERE ibname = CURRENT_USER ' +
          '        INTO :IG, :BG; ' +
          '      IF (BIN_AND(:BG, :IG) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE OR ALTER TRIGGER inv_bd_movement_block FOR inv_movement ' +
          '  INACTIVE ' +
          '  BEFORE DELETE ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          '  DECLARE VARIABLE BG INTEGER; ' +
          'BEGIN ' +
          '  IF (CAST(OLD.movementdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '  BEGIN ' +
          '    IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '    BEGIN ' +
          '      EXCEPTION gd_e_block; ' +
          '    END ELSE ' +
          '    BEGIN ' +
          '      SELECT ingroup, GEN_ID(gd_g_block_group, 0) FROM gd_user WHERE ibname = CURRENT_USER ' +
          '        INTO :IG, :BG; ' +
          '      IF (BIN_AND(:BG, :IG) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;}

        SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (67, ''0000.0001.0000.0095'', ''22.03.2005'', ''Fixed Some Errors'') ' +
          '  MATCHING (id) ';
        ExecQuery;
        Close;

        FTransaction.Commit;
      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
        Log('Îøèáêà: ' + E.Message);
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
