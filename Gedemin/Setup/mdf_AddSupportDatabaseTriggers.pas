unit mdf_AddSupportDatabaseTriggers;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit;

procedure AddSupportDatabaseTriggers(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddAvailableIDProc(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure AddSupportDatabaseTriggers(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    try
      Tr.DefaultDatabase := IBDB;
      q.Transaction := Tr;
      Tr.StartTransaction;

      DropConstraint2('AT_TRIGGERS', 'AT_FK_TRIGGER_RELATIONKEY', Tr);
      DropNotNullConstraint2('AT_TRIGGERS', 'RELATIONKEY', Tr);
      DropNotNullConstraint2('AT_TRIGGERS', 'RELATIONNAME', Tr);

      q.SQL.Text := 'alter table at_triggers alter  relationkey type dforeignkey';
      q.ExecQuery;

      q.SQL.Text :=
        'ALTER TABLE at_triggers ADD CONSTRAINT at_fk_trigger_relationkey FOREIGN KEY(relationkey) ' +
        'REFERENCES at_relations(id) ON UPDATE CASCADE ON DELETE CASCADE';
      q.ExecQuery;  

      q.SQL.Text :=
        'ALTER PROCEDURE AT_P_SYNC_TRIGGERS_ALL '#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE RN VARCHAR(31); '#13#10 +
        '  DECLARE VARIABLE TN VARCHAR(31); '#13#10 +
        '  DECLARE VARIABLE ID INTEGER; '#13#10 +
        '  DECLARE VARIABLE TI SMALLINT; '#13#10 +
        'BEGIN '#13#10 +
        ' '#13#10 +
        '  /* удалим не существующие уже триггеры */ '#13#10 +
        '  FOR '#13#10 +
        '    SELECT triggername '#13#10 +
        '    FROM at_triggers LEFT JOIN rdb$triggers '#13#10 +
        '      ON triggername=rdb$trigger_name '#13#10 +
        '        AND relationname=rdb$relation_name '#13#10 +
        '    WHERE '#13#10 +
        '      rdb$trigger_name IS NULL '#13#10 +
        '    INTO :TN '#13#10 +
        '  DO BEGIN '#13#10 +
        '    DELETE FROM at_triggers WHERE triggername=:TN; '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        ' '#13#10 +
        ' /* добавим новые триггеры */ '#13#10 +
        '  FOR '#13#10 +
        '    SELECT rdb$relation_name, rdb$trigger_name, '#13#10 +
        '      rdb$trigger_inactive, r.id '#13#10 +
        '    FROM rdb$triggers LEFT JOIN at_triggers t '#13#10 +
        '      ON t.triggername=rdb$trigger_name '#13#10 +
        '    LEFT JOIN at_relations r ON rdb$relation_name = r.relationname '#13#10 +
        '    WHERE '#13#10 +
        '     (t.triggername IS NULL) '#13#10 +
        '     and (((r.id IS NOT NULL) and (rdb$trigger_type <=114)) '#13#10 +
        '       or (rdb$trigger_type >=8192)) '#13#10 +
        '    INTO :RN, :TN, :TI, :ID '#13#10 +
        '  DO BEGIN '#13#10 +
        '    RN = TRIM(RN); '#13#10 +
        '    TN = TRIM(TN); '#13#10 +
        '    IF (TI IS NULL) THEN '#13#10 +
        '      TI = 0; '#13#10 +
        '    IF (TI > 1) THEN '#13#10 +
        '      TI = 1; '#13#10 +
        '    INSERT INTO at_triggers(relationname, triggername, relationkey, trigger_inactive) '#13#10 +
        '    VALUES (:RN, :TN, :ID, :TI); '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        '  /* проверяем триггеры на активность*/ '#13#10 +
        '  FOR '#13#10 +
        '    SELECT ri.rdb$trigger_inactive, ri.rdb$trigger_name '#13#10 +
        '    FROM rdb$triggers ri '#13#10 +
        '    LEFT JOIN at_triggers t ON ri.rdb$trigger_name = t.triggername '#13#10 +
        '    WHERE ((t.trigger_inactive IS NULL) OR '#13#10 +
        '    (t.trigger_inactive <> ri.rdb$trigger_inactive) OR '#13#10 +
        '    (ri.rdb$trigger_inactive IS NULL AND t.trigger_inactive = 1)) '#13#10 +
        '    INTO :TI, :TN '#13#10 +
        '  DO BEGIN '#13#10 +
        '    IF (TI IS NULL) THEN '#13#10 +
        '      TI = 0; '#13#10 +
        '    IF (TI > 1) THEN '#13#10 +
        '      TI = 1; '#13#10 +
        '    UPDATE at_triggers SET trigger_inactive = :TI WHERE triggername = :TN; '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        'END ';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'CREATE OR ALTER TRIGGER gd_biu_bank FOR gd_bank '#13#10 +
        '  ACTIVE '#13#10 +
        '  BEFORE INSERT OR UPDATE '#13#10 +
        '  POSITION 32000 '#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE d_name VARCHAR(60); '#13#10 +
        '  DECLARE VARIABLE d_id INTEGER; '#13#10 +
        'BEGIN '#13#10 +
        '  IF (INSERTING OR NEW.bankcode <> OLD.bankcode) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    NEW.bankMFO = NEW.bankcode; '#13#10 +
        '    NEW.SWIFT = NEW.bankcode; '#13#10 +
        '  END ELSE '#13#10 +
        '  BEGIN '#13#10 +
        '    IF (NEW.bankMFO IS NOT NULL AND NEW.bankMFO IS DISTINCT FROM OLD.bankMFO) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      NEW.bankcode = NEW.bankMFO; '#13#10 +
        '      NEW.SWIFT = NEW.bankMFO; '#13#10 +
        '    END ELSE '#13#10 +
        '    BEGIN '#13#10 +
        '      IF (NEW.SWIFT IS NOT NULL AND NEW.SWIFT IS DISTINCT FROM OLD.SWIFT) THEN '#13#10 +
        '      BEGIN '#13#10 +
        '        NEW.bankcode = NEW.SWIFT; '#13#10 +
        '        NEW.bankMFO = NEW.SWIFT; '#13#10 +
        '      END '#13#10 +
        '    END '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        '  /* IF (NOT (NEW.bankcode SIMILAR TO ''[A-Z]{6}([A-Z0-9]{2}|[A-Z0-9]{5})'')) THEN '#13#10 +
        '    EXCEPTION gd_e_exception ''Неверный формат BIC "'' || NEW.bankcode || ''"''; */ '#13#10 +
        ' '#13#10 +
        '  FOR '#13#10 +
        '    SELECT c.id, c.name '#13#10 +
        '    FROM gd_contact c JOIN gd_bank b ON b.bankkey = c.id '#13#10 +
        '    WHERE b.bankkey <> NEW.bankkey AND b.bankcode = NEW.bankcode '#13#10 +
        '      AND b.bankbranch IS NOT DISTINCT FROM NEW.bankbranch '#13#10 +
        '    INTO :d_id, :d_name '#13#10 +
        '  DO '#13#10 +
        '    EXCEPTION gd_e_exception ''Дублируется BIC у банка "'' || :d_name || ''", ИД='' || :d_id; '#13#10 +
        'END';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'CREATE OR ALTER TRIGGER gd_biu_companyaccount FOR gd_companyaccount '#13#10 +
        '  ACTIVE '#13#10 +
        '  BEFORE INSERT OR UPDATE '#13#10 +
        '  POSITION 30000 '#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE hc INTEGER = NULL; '#13#10 +
        '  DECLARE VARIABLE c_id INTEGER = NULL; '#13#10 +
        '  DECLARE VARIABLE c_name dtext180 = NULL; '#13#10 +
        'BEGIN '#13#10 +
        '  IF (INSERTING OR NEW.account <> OLD.account) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    /* IF (NOT (NEW.account SIMILAR TO ''[A-Z]{2}[0-9]{2}[A-Z0-9]{4}[0-9]{4}[A-Z0-9]{16}'')) THEN '#13#10 +
        '      EXCEPTION gd_e_exception ''Неверный формат IBAN "'' || NEW.account || ''"''; */'#13#10 +
        ' '#13#10 +
        '    NEW.iban = NEW.account; '#13#10 +
        ' '#13#10 +
        '    SELECT '#13#10 +
        '      co.headcompany '#13#10 +
        '    FROM '#13#10 +
        '      gd_company co '#13#10 +
        '    WHERE '#13#10 +
        '      co.contactkey = NEW.companykey '#13#10 +
        '    INTO '#13#10 +
        '      :hc; '#13#10 +
        ' '#13#10 +
        '    FOR '#13#10 +
        '      SELECT '#13#10 +
        '        co.contactkey, co.fullname '#13#10 +
        '      FROM '#13#10 +
        '        gd_company co JOIN gd_companyaccount acc ON acc.companykey = co.contactkey '#13#10 +
        '      WHERE '#13#10 +
        '        acc.account = NEW.account '#13#10 +
        '        AND '#13#10 +
        '        acc.id <> NEW.id '#13#10 +
        '        AND '#13#10 +
        '        ( '#13#10 +
        '          (:hc IS NULL) '#13#10 +
        '          OR '#13#10 +
        '          (co.headcompany IS DISTINCT FROM :hc) '#13#10 +
        '        ) '#13#10 +
        '      INTO :c_id, :c_name '#13#10 +
        '    DO '#13#10 +
        '      EXCEPTION gd_e_exception ''Дублируется IBAN у организации "'' || :c_name || ''", ИД='' || :c_id; '#13#10 +
        '  END '#13#10 +
        'END';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO gd_command '#13#10 +
        '  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED) '#13#10 +
        'VALUES '#13#10 +
        '  (741116,740400,''Триггеры БД'',''gdcDBTrigger'',0,NULL,253,NULL,''TgdcDBTrigger'',NULL,1,1,1,0,NULL) ' +
        'MATCHING (id)';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (267, ''0000.0001.0000.0298'', ''02.08.2017'', ''Add support database triggers'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log(E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure AddAvailableIDProc(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    try
      Tr.DefaultDatabase := IBDB;
      q.Transaction := Tr;
      Tr.StartTransaction;

      if not ConstraintExist2('GD_AVAILABLE_ID', 'GD_CHK_AVAILABLE_ID', Tr) then
      begin
        q.SQL.Text :=
          'ALTER TABLE gd_available_id ADD CONSTRAINT gd_chk_available_id CHECK (id_from <= id_to)';
        q.ExecQuery;
      end;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (270, ''0000.0001.0000.0301'', ''19.12.2017'', ''Added GD_AVAILABLE_ID procs.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log(E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

end.
