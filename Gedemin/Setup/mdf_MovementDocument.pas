
unit mdf_MovementDocument;

interface

uses
  IBDatabase, gdModify, IBSQL, SysUtils;

procedure MovementDocument(IBDB: TIBDatabase; Log: TModifyLog);
procedure Correct_gd_ai_goodgroup_protect(IBDB: TIBDatabase; Log: TModifyLog);
procedure Correct_ac_companyaccount_triggers(IBDB: TIBDatabase; Log: TModifyLog);
procedure Correct_inv_bu_movement_triggers(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  mdf_metadata_unit;

procedure MovementDocument(IBDB: TIBDatabase; Log: TModifyLog);
var
  SQL: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  SQL := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    SQL.Transaction := Tr;
    try
      CreateException2('gd_e_cannotchangebranch', 'Can not change branch!', Tr);

      SQL.ParamCheck := False;
      {SQL.SQL.Text :=
        'CREATE OR ALTER TRIGGER gd_au_documenttype FOR gd_documenttype '#13#10 +
        '  ACTIVE '#13#10 +
        '  AFTER UPDATE '#13#10 +
        '  POSITION 20000 '#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE new_root dintkey; '#13#10 +
        '  DECLARE VARIABLE old_root dintkey; '#13#10 +
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
        '  END '#13#10 +
        'END ';
      SQL.ExecQuery;}

      SQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (142, ''0000.0001.0000.0173'', ''04.04.2012'', ''Trigger GD_AU_DOCUMENTTYPE_MOVEMENT added.'') ' +
        '  MATCHING (id)';
      SQL.ExecQuery;
      SQL.Close;

      SQL.SQL.Text := 'UPDATE at_fields SET numeration = NULL WHERE OCTET_LENGTH(NUMERATION) = 0 ';
      SQL.ExecQuery;
      SQL.Close;

      if not ConstraintExist2('AT_FIELDS', 'AT_CHK_FIELDS_NUMERATION', Tr) then
      begin
        SQL.SQL.Text :=
          'ALTER TABLE at_fields ADD CONSTRAINT at_chk_fields_numeration ' +
          '  CHECK ((NUMERATION IS NULL) OR (OCTET_LENGTH(NUMERATION) > 0))';
        SQL.ExecQuery;
        SQL.Close;
      end;

      if FunctionExist2('ROUND', Tr) and (not HasDependencies('ROUND', Tr)) then
      begin
        SQL.SQL.Text := 'DROP EXTERNAL FUNCTION "ROUND"';
        SQL.ExecQuery;
        SQL.Close;
      end;

      SQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (143, ''0000.0001.0000.0174'', ''04.04.2012'', ''Some minor changes.'') ' +
        '  MATCHING (id)';
      SQL.ExecQuery;
      SQL.Close;

      CreateException2('GD_E_CANNOTCHANGE_GOODGROUP', 'Can not change good group!', Tr);

      SQL.SQL.Text :=
        'CREATE OR ALTER TRIGGER gd_ad_goodgroup_protect FOR gd_goodgroup '#13#10 +
        '  ACTIVE '#13#10 +
        '  AFTER DELETE '#13#10 +
        '  POSITION 0 '#13#10 +
        'AS '#13#10 +
        'BEGIN '#13#10 +
        '  IF (UPPER(OLD.name) IN (''“¿–¿'', ''—“≈ ÀŒœŒ—”ƒ¿'', ''ƒ–¿√Ã≈“¿ÀÀ€'')) THEN '#13#10 +
        '    EXCEPTION gd_e_cannotchange_goodgroup  ''ÕÂÎ¸Áˇ Û‰‡ÎËÚ¸ „ÛÔÔÛ '' || OLD.Name; '#13#10 +
        'END ';
      SQL.ExecQuery;
      SQL.Close;

      SQL.SQL.Text :=
        'CREATE OR ALTER TRIGGER gd_ai_goodgroup_protect FOR gd_goodgroup '#13#10 +
        '  ACTIVE '#13#10 +
        '  AFTER INSERT '#13#10 +
        '  POSITION 0 '#13#10 +
        'AS '#13#10 +
        'BEGIN '#13#10 +
        '  IF (UPPER(NEW.name) IN (''“¿–¿'', ''—“≈ ÀŒœŒ—”ƒ¿'', ''ƒ–¿√Ã≈“¿ÀÀ€'')) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    IF (EXISTS (SELECT * FROM gd_goodgroup WHERE id <> NEW.id AND UPPER(name) = UPPER(NEW.name))) THEN '#13#10 +
        '      EXCEPTION gd_e_cannotchange_goodgroup  ''ÕÂÎ¸Áˇ ÔÓ‚ÚÓÌÓ ÒÓÁ‰‡Ú¸ „ÛÔÔÛ '' || NEW.Name; '#13#10 +
        '  END '#13#10 +
        'END ';
      SQL.ExecQuery;
      SQL.Close;

      SQL.SQL.Text :=
        'CREATE OR ALTER TRIGGER gd_au_goodgroup_protect FOR gd_goodgroup '#13#10 +
        '  ACTIVE '#13#10 +
        '  AFTER UPDATE '#13#10 +
        '  POSITION 0 '#13#10 +
        'AS '#13#10 +
        'BEGIN '#13#10 +
        '  IF ((UPPER(NEW.name) IN (''“¿–¿'', ''—“≈ ÀŒœŒ—”ƒ¿'', ''ƒ–¿√Ã≈“¿ÀÀ€'')) '#13#10 +
        '    OR (UPPER(OLD.name) IN (''“¿–¿'', ''—“≈ ÀŒœŒ—”ƒ¿'', ''ƒ–¿√Ã≈“¿ÀÀ€''))) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    IF (NEW.name <> OLD.name OR NEW.parent IS DISTINCT FROM OLD.parent) THEN '#13#10 +
        '      EXCEPTION gd_e_cannotchange_goodgroup  ''ÕÂÎ¸Áˇ ËÁÏÂÌËÚ¸ „ÛÔÔÛ '' || NEW.Name; '#13#10 +
        '  END '#13#10 +
        'END ';
      SQL.ExecQuery;
      SQL.Close;

      SQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (144, ''0000.0001.0000.0175'', ''04.04.2012'', ''Protect system good groups.'') ' +
        '  MATCHING (id)';
      SQL.ExecQuery;
      SQL.Close;

      SQL.SQL.Text :=
        'CREATE OR ALTER PROCEDURE INV_GETCARDMOVEMENT ( '#13#10 +
        '    CARDKEY INTEGER, '#13#10 +
        '    CONTACTKEY INTEGER, '#13#10 +
        '    DATEEND DATE) '#13#10 +
        'RETURNS ( '#13#10 +
        '    REMAINS NUMERIC(15, 4)) '#13#10 +
        'AS '#13#10 +
        'BEGIN '#13#10 +
        '  REMAINS = 0; '#13#10 +
        '  SELECT SUM(m.debit - m.credit) '#13#10 +
        '  FROM inv_movement m '#13#10 +
        '  WHERE m.cardkey = :CARDKEY AND m.contactkey = :CONTACTKEY '#13#10 +
        '    AND m.movementdate > :DATEEND AND m.disabled = 0 '#13#10 +
        '  INTO :REMAINS; '#13#10 +
        '  IF (REMAINS IS NULL) THEN '#13#10 +
        '    REMAINS = 0; '#13#10 +
        '  SUSPEND; '#13#10 +
        'END ';
      SQL.ExecQuery;
      SQL.Close;

      SQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (145, ''0000.0001.0000.0176'', ''05.04.2012'', ''Issue 2764.'') ' +
        '  MATCHING (id)';
      SQL.ExecQuery;
      SQL.Close;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('œÓËÁÓ¯Î‡ Ó¯Ë·Í‡: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    SQL.Free;
    Tr.Free;
  end;
end;

procedure Correct_gd_ai_goodgroup_protect(IBDB: TIBDatabase; Log: TModifyLog);
var
  SQL: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  SQL := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    SQL.Transaction := Tr;
    try
      SQL.SQL.Text :=
        'CREATE OR ALTER TRIGGER gd_ai_goodgroup_protect FOR gd_goodgroup '#13#10 +
        '  ACTIVE '#13#10 +
        '  AFTER INSERT '#13#10 +
        '  POSITION 0 '#13#10 +
        'AS '#13#10 +
        'BEGIN '#13#10 +
        '  IF (UPPER(NEW.name) IN (''“¿–¿'', ''—“≈ ÀŒœŒ—”ƒ¿'', ''ƒ–¿√Ã≈“¿ÀÀ€'')) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    IF (EXISTS (SELECT * FROM gd_goodgroup WHERE id <> NEW.id AND UPPER(name) = UPPER(NEW.name))) THEN '#13#10 +
        '      EXCEPTION gd_e_cannotchange_goodgroup  ''ÕÂÎ¸Áˇ ÔÓ‚ÚÓÌÓ ÒÓÁ‰‡Ú¸ „ÛÔÔÛ '' || NEW.Name; '#13#10 +
        '  END '#13#10 +
        'END ';
      SQL.ExecQuery;
      SQL.Close;

      SQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (156, ''0000.0001.0000.0187'', ''31.05.2012'', ''Correct gd_ai_goodgroup_protect trigger.'') ' +
        '  MATCHING (id)';
      SQL.ExecQuery;
      SQL.Close;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('œÓËÁÓ¯Î‡ Ó¯Ë·Í‡: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    SQL.Free;
    Tr.Free;
  end;
end;

procedure Correct_ac_companyaccount_triggers(IBDB: TIBDatabase; Log: TModifyLog);
var
  SQL: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  SQL := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    DropTrigger2('ac_bu_companyaccount', Tr);

    SQL.Transaction := Tr;
    try
      SQL.SQL.Text :=
        'CREATE OR ALTER TRIGGER ac_bi_companyaccount FOR ac_companyaccount'#13#10 +
        '  BEFORE INSERT OR UPDATE'#13#10 +
        '  POSITION 0'#13#10 +
        'AS'#13#10 +
        '  DECLARE VARIABLE ActiveID INTEGER = NULL;'#13#10 +
        'BEGIN'#13#10 +
        '  SELECT FIRST 1 accountkey FROM ac_companyaccount'#13#10 +
        '    WHERE companykey = NEW.companykey AND isactive = 1'#13#10 +
        '    INTO :ActiveID;'#13#10 +
        ''#13#10 +
        '  IF (:ActiveID IS NULL) THEN'#13#10 +
        '    NEW.isactive = 1;'#13#10 +
        '  ELSE'#13#10 +
        '    IF ((:ActiveID <> NEW.accountkey) AND (NEW.isactive = 1)) THEN'#13#10 +
        '      UPDATE ac_companyaccount SET isactive = 0'#13#10 +
        '      WHERE companykey = NEW.companykey AND accountkey = :ActiveID;'#13#10 +
        'END';
      SQL.ExecQuery;
      SQL.Close;

      SQL.SQL.Text :=
        'CREATE OR ALTER TRIGGER ac_ad_companyaccount FOR ac_companyaccount'#13#10 +
        '  AFTER DELETE'#13#10 +
        '  POSITION 0'#13#10 +
        'AS'#13#10 +
        'BEGIN'#13#10 +
        '  IF (OLD.isactive = 1) THEN'#13#10 +
        '    UPDATE ac_companyaccount SET isactive = 1'#13#10 +
        '    WHERE companykey = OLD.companykey AND accountkey <> OLD.accountkey'#13#10 +
        '    ROWS 1;'#13#10 +
        'END';
      SQL.ExecQuery;
      SQL.Close;

      SQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (157, ''0000.0001.0000.0188'', ''18.07.2012'', ''Correct ac_companyaccount triggers.'') ' +
        '  MATCHING (id)';
      SQL.ExecQuery;
      SQL.Close;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('œÓËÁÓ¯Î‡ Ó¯Ë·Í‡: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    SQL.Free;
    Tr.Free;
  end;
end;

procedure Correct_inv_bu_movement_triggers(IBDB: TIBDatabase; Log: TModifyLog);
var
  SQL: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  SQL := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    SQL.Transaction := Tr;
    try
      SQL.SQL.Text :=
        'ALTER TRIGGER INV_BU_MOVEMENT '#13#10 +
        '  ACTIVE '#13#10 +
        '  BEFORE UPDATE '#13#10 +
        '  POSITION 0 '#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE balance NUMERIC(15, 4); '#13#10 +
        'BEGIN '#13#10 +
        '  IF (RDB$GET_CONTEXT(''USER_TRANSACTION'', ''GD_MERGING_RECORDS'') IS NULL) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    IF (NEW.documentkey <> OLD.documentkey) THEN '#13#10 +
        '      EXCEPTION inv_e_movementchange; '#13#10 +
        ' '#13#10 +
        '    IF ((NEW.disabled = 1) OR (NEW.contactkey <> OLD.contactkey) OR (NEW.cardkey <> OLD.cardkey)) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      IF (OLD.debit > 0) THEN '#13#10 +
        '      BEGIN '#13#10 +
        '        SELECT balance FROM inv_balance '#13#10 +
        '        WHERE contactkey = OLD.contactkey '#13#10 +
        '          AND cardkey = OLD.cardkey '#13#10 +
        '        INTO :balance; '#13#10 +
        '        IF (COALESCE(:balance, 0) < OLD.debit) THEN '#13#10 +
        '          EXCEPTION INV_E_INVALIDMOVEMENT; '#13#10 +
        '      END '#13#10 +
        '    END ELSE '#13#10 +
        '    BEGIN '#13#10 +
        '      IF (OLD.debit > NEW.debit) THEN '#13#10 +
        '      BEGIN '#13#10 +
        '        SELECT balance FROM inv_balance '#13#10 +
        '        WHERE contactkey = OLD.contactkey '#13#10 +
        '          AND cardkey = OLD.cardkey '#13#10 +
        '        INTO :balance; '#13#10 +
        '        balance = COALESCE(:balance, 0); '#13#10 +
        '        IF ((:balance > 0) AND (:balance < OLD.debit - NEW.debit)) THEN '#13#10 +
        '          EXCEPTION INV_E_INVALIDMOVEMENT; '#13#10 +
        '      END ELSE '#13#10 +
        '      BEGIN '#13#10 +
        '        IF (NEW.credit > OLD.credit) THEN '#13#10 +
        '        BEGIN '#13#10 +
        '          SELECT balance FROM inv_balance '#13#10 +
        '          WHERE contactkey = OLD.contactkey '#13#10 +
        '            AND cardkey = OLD.cardkey '#13#10 +
        '          INTO :balance; '#13#10 +
        '          balance = COALESCE(:balance, 0); '#13#10 +
        '          IF ((:balance > 0) AND (:balance < NEW.credit - OLD.credit)) THEN '#13#10 +
        '            EXCEPTION INV_E_INVALIDMOVEMENT; '#13#10 +
        '        END '#13#10 +
        '      END '#13#10 +
        '    END '#13#10 +
        '  END '#13#10 +
        'END ';
      SQL.ExecQuery;
      SQL.Close;

      SQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (160, ''0000.0001.0000.0191'', ''19.10.2012'', ''Corrected inv_bu_movement trigger.'') ' +
        '  MATCHING (id)';
      SQL.ExecQuery;
      SQL.Close;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('œÓËÁÓ¯Î‡ Ó¯Ë·Í‡: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    SQL.Free;
    Tr.Free;
  end;
end;

end.


