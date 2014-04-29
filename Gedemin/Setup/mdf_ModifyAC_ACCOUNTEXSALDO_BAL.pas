unit mdf_ModifyAC_ACCOUNTEXSALDO_BAL;

interface

uses
  IBDatabase, gdModify;

procedure ModifyAC_ACCOUNTEXSALDO_BAL(IBDB: TIBDatabase; Log: TModifyLog);
procedure IntroduceIncorrectRecordGTT(IBDB: TIBDatabase; Log: TModifyLog);
procedure Issue3373(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, mdf_metadata_unit;

procedure IntroduceIncorrectRecordGTT(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  q: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      q := TIBSQL.Create(nil);
      try
        q.Transaction := FTransaction;

        q.SQL.Text :=
          'UPDATE rdb$functions SET rdb$module_name = ''gudf'' WHERE UPPER(rdb$module_name) = ''GUDF.DLL'' ';
        q.ExecQuery;

        if not RelationExist2('AC_INCORRECT_RECORD', FTransaction) then
        begin
          q.SQL.Text :=
            'CREATE GLOBAL TEMPORARY TABLE ac_incorrect_record ( '#13#10 +
            '  id    dintkey, '#13#10 +
            '  CONSTRAINT ac_pk_incorrect_record PRIMARY KEY (id) '#13#10 +
            ') '#13#10 +
            '  ON COMMIT DELETE ROWS';
          q.ExecQuery;
        end;

        q.SQL.Text :=
          'GRANT ALL ON ac_incorrect_record TO administrator';
        q.ExecQuery;

        q.SQL.Text :=
          'CREATE OR ALTER EXCEPTION ac_e_invalidentry ''Invalid entry'' ';
        q.ExecQuery;

        q.SQL.Text :=
          'CREATE OR ALTER TRIGGER ac_bi_record FOR ac_record '#13#10 +
          '  BEFORE INSERT '#13#10 +
          '  POSITION 31700 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.ID IS NULL) THEN '#13#10 +
          '    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
          ' '#13#10 +
          '  NEW.debitncu = 0; '#13#10 +
          '  NEW.debitcurr = 0; '#13#10 +
          '  NEW.creditncu = 0; '#13#10 +
          '  NEW.creditcurr = 0; '#13#10 +
          ' '#13#10 +
          '  INSERT INTO ac_incorrect_record (id) VALUES (NEW.id); '#13#10 +
          'END';
        q.ExecQuery;

        q.SQL.Text :=
          'CREATE OR ALTER TRIGGER ac_bu_record FOR ac_record '#13#10 +
          '  BEFORE UPDATE '#13#10 +
          '  POSITION 31700 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE WasUnlock INTEGER; '#13#10 +
          'BEGIN '#13#10 +
          '  IF (RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK'') IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.debitncu = OLD.debitncu; '#13#10 +
          '    NEW.creditncu = OLD.creditncu; '#13#10 +
          '    NEW.debitcurr = OLD.debitcurr; '#13#10 +
          '    NEW.creditcurr = OLD.creditcurr; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NEW.debitncu IS DISTINCT FROM OLD.debitncu OR '#13#10 +
          '    NEW.creditncu IS DISTINCT FROM OLD.creditncu) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    IF (NEW.debitncu IS DISTINCT FROM NEW.creditncu) THEN '#13#10 +
          '      UPDATE OR INSERT INTO ac_incorrect_record (id) VALUES (NEW.id) '#13#10 +
          '        MATCHING (id); '#13#10 +
          '    ELSE '#13#10 +
          '      DELETE FROM ac_incorrect_record WHERE id = NEW.id; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NEW.recorddate <> OLD.recorddate '#13#10 +
          '    OR NEW.transactionkey <> OLD.transactionkey '#13#10 +
          '    OR NEW.documentkey <> OLD.documentkey '#13#10 +
          '    OR NEW.masterdockey <> OLD.masterdockey '#13#10 +
          '    OR NEW.companykey <> OLD.companykey) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    WasUnlock = RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_UNLOCK''); '#13#10 +
          '    IF (:WasUnlock IS NULL) THEN '#13#10 +
          '      RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_UNLOCK'', 1); '#13#10 +
          '    UPDATE ac_entry e '#13#10 +
          '    SET e.entrydate = NEW.recorddate, '#13#10 +
          '      e.transactionkey = NEW.transactionkey, '#13#10 +
          '      e.documentkey = NEW.documentkey, '#13#10 +
          '      e.masterdockey = NEW.masterdockey, '#13#10 +
          '      e.companykey = NEW.companykey '#13#10 +
          '    WHERE '#13#10 +
          '      e.recordkey = NEW.id; '#13#10 +
          '    IF (:WasUnlock IS NULL) THEN '#13#10 +
          '      RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_UNLOCK'', NULL); '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  WHEN ANY DO '#13#10 +
          '  BEGIN '#13#10 +
          '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_UNLOCK'', NULL); '#13#10 +
          '    EXCEPTION; '#13#10 +
          '  END '#13#10 +
          'END';
        q.ExecQuery;

        q.SQL.Text :=
          'CREATE OR ALTER TRIGGER ac_ad_record FOR ac_record '#13#10 +
          '  AFTER DELETE '#13#10 +
          '  POSITION 31700 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  DELETE FROM ac_incorrect_record WHERE id = OLD.id; '#13#10 +
          'END';
        q.ExecQuery;

        q.SQL.Text :=
          'CREATE OR ALTER TRIGGER ac_bi_entry FOR ac_entry '#13#10 +
          '  BEFORE INSERT '#13#10 +
          '  POSITION 31700 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE Cnt INTEGER = 0; '#13#10 +
          '  DECLARE VARIABLE Cnt2 INTEGER = 0; '#13#10 +
          '  DECLARE VARIABLE WasSetIsSimple INTEGER; '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.ID IS NULL) THEN '#13#10 +
          '    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
          ' '#13#10 +
          '  IF (NEW.accountpart = ''C'') THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.debitncu = 0; '#13#10 +
          '    NEW.debitcurr = 0; '#13#10 +
          '    NEW.debiteq = 0; '#13#10 +
          '    NEW.creditncu = COALESCE(NEW.creditncu, 0); '#13#10 +
          '    NEW.creditcurr = IIF(NEW.currkey IS NULL, 0, COALESCE(NEW.creditcurr, 0)); '#13#10 +
          '    NEW.crediteq = COALESCE(NEW.crediteq, 0); '#13#10 +
          '  END ELSE '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.creditncu = 0; '#13#10 +
          '    NEW.creditcurr = 0; '#13#10 +
          '    NEW.crediteq = 0; '#13#10 +
          '    NEW.debitncu = COALESCE(NEW.debitncu, 0); '#13#10 +
          '    NEW.debitcurr = IIF(NEW.currkey IS NULL, 0, COALESCE(NEW.debitcurr, 0)); '#13#10 +
          '    NEW.debiteq = COALESCE(NEW.debiteq, 0); '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  SELECT recorddate, transactionkey, documentkey, masterdockey, companykey '#13#10 +
          '  FROM ac_record '#13#10 +
          '  WHERE id = NEW.recordkey '#13#10 +
          '  INTO NEW.entrydate, NEW.transactionkey, NEW.documentkey, NEW.masterdockey, NEW.companykey; '#13#10 +
          ' '#13#10 +
          '  SELECT '#13#10 +
          '    COALESCE(SUM(IIF(accountpart = NEW.accountpart, 1, 0)), 0), '#13#10 +
          '    COALESCE(SUM(IIF(accountpart <> NEW.accountpart, 1, 0)), 0) '#13#10 +
          '  FROM ac_entry '#13#10 +
          '  WHERE recordkey = NEW.recordkey '#13#10 +
          '  INTO :Cnt, :Cnt2; '#13#10 +
          ' '#13#10 +
          '  IF (:Cnt > 0 AND :Cnt2 > 1) THEN '#13#10 +
          '    EXCEPTION ac_e_invalidentry; '#13#10 +
          ' '#13#10 +
          '  IF (:Cnt = 0) THEN '#13#10 +
          '    NEW.issimple = 1; '#13#10 +
          '  ELSE BEGIN '#13#10 +
          '    NEW.issimple = 0; '#13#10 +
          '    IF (:Cnt = 1) THEN '#13#10 +
          '    BEGIN '#13#10 +
          '      WasSetIsSimple = RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_SET_ISSIMPLE''); '#13#10 +
          '      IF (:WasSetIsSimple IS NULL) THEN '#13#10 +
          '        RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_SET_ISSIMPLE'', 1); '#13#10 +
          '      UPDATE ac_entry SET issimple = 0 '#13#10 +
          '      WHERE recordkey = NEW.recordkey AND accountpart = NEW.accountpart '#13#10 +
          '        AND id <> NEW.id; '#13#10 +
          '      IF (:WasSetIsSimple IS NULL) THEN '#13#10 +
          '        RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_SET_ISSIMPLE'', NULL); '#13#10 +
          '    END '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  WHEN ANY DO '#13#10 +
          '  BEGIN '#13#10 +
          '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_SET_ISSIMPLE'', NULL); '#13#10 +
          '    EXCEPTION; '#13#10 +
          '  END '#13#10 +
          'END';
        q.ExecQuery;

        q.SQL.Text :=
          'CREATE OR ALTER TRIGGER ac_ai_entry FOR ac_entry '#13#10 +
          '  AFTER INSERT '#13#10 +
          '  POSITION 31700 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE WasUnlock INTEGER; '#13#10 +
          'BEGIN '#13#10 +
          '  WasUnlock = RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK''); '#13#10 +
          '  IF (:WasUnlock IS NULL) THEN '#13#10 +
          '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK'', 1); '#13#10 +
          '  UPDATE '#13#10 +
          '    ac_record '#13#10 +
          '  SET '#13#10 +
          '    debitncu = debitncu + NEW.debitncu, '#13#10 +
          '    creditncu = creditncu + NEW.creditncu, '#13#10 +
          '    debitcurr = debitcurr + NEW.debitcurr, '#13#10 +
          '    creditcurr = creditcurr + NEW.creditcurr '#13#10 +
          '  WHERE '#13#10 +
          '    id = NEW.recordkey; '#13#10 +
          '  IF (:WasUnlock IS NULL) THEN '#13#10 +
          '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK'', NULL); '#13#10 +
          ' '#13#10 +
          ' '#13#10 +
          '  WHEN ANY DO '#13#10 +
          ' '#13#10 +
          '  BEGIN '#13#10 +
          '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK'', NULL); '#13#10 +
          '    EXCEPTION; '#13#10 +
          '  END '#13#10 +
          'END';
        q.ExecQuery;

        q.SQL.Text :=
          'CREATE OR ALTER TRIGGER ac_bu_entry FOR ac_entry '#13#10 +
          '  BEFORE UPDATE '#13#10 +
          '  POSITION 31700 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_SET_ISSIMPLE'') IS NOT NULL) THEN '#13#10 +
          '    EXIT; '#13#10 +
          ' '#13#10 +
          '  NEW.recordkey = OLD.recordkey; '#13#10 +
          ' '#13#10 +
          '  IF (RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_UNLOCK'') IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.entrydate = OLD.entrydate; '#13#10 +
          '    NEW.transactionkey = OLD.transactionkey; '#13#10 +
          '    NEW.documentkey = OLD.documentkey; '#13#10 +
          '    NEW.masterdockey = OLD.masterdockey; '#13#10 +
          '    NEW.companykey = OLD.companykey; '#13#10 +
          '    NEW.issimple = OLD.issimple; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NEW.currkey IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    NEW.creditcurr = 0; '#13#10 +
          '    NEW.debitcurr = 0; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NEW.accountpart <> OLD.accountpart) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    IF (NEW.accountpart = ''C'') THEN '#13#10 +
          '    BEGIN '#13#10 +
          '      NEW.debitncu = 0; '#13#10 +
          '      NEW.debitcurr = 0; '#13#10 +
          '      NEW.debiteq = 0; '#13#10 +
          '      NEW.creditncu = COALESCE(NEW.creditncu, 0); '#13#10 +
          '      NEW.creditcurr = IIF(NEW.currkey IS NULL, 0, COALESCE(NEW.creditcurr, 0)); '#13#10 +
          '      NEW.crediteq = COALESCE(NEW.crediteq, 0); '#13#10 +
          '    END ELSE '#13#10 +
          '    BEGIN '#13#10 +
          '      NEW.creditncu = 0; '#13#10 +
          '      NEW.creditcurr = 0; '#13#10 +
          '      NEW.crediteq = 0; '#13#10 +
          '      NEW.debitncu = COALESCE(NEW.debitncu, 0); '#13#10 +
          '      NEW.debitcurr = IIF(NEW.currkey IS NULL, 0, COALESCE(NEW.debitcurr, 0)); '#13#10 +
          '      NEW.debiteq = COALESCE(NEW.debiteq, 0); '#13#10 +
          '    END '#13#10 +
          '  END '#13#10 +
          'END';
        q.ExecQuery;

        q.SQL.Text :=
          'CREATE OR ALTER TRIGGER ac_au_entry FOR ac_entry '#13#10 +
          '  AFTER UPDATE '#13#10 +
          '  POSITION 31700 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE WasUnlock INTEGER; '#13#10 +
          '  DECLARE VARIABLE WasSetIsSimple INTEGER; '#13#10 +
          '  DECLARE VARIABLE Cnt INTEGER; '#13#10 +
          '  DECLARE VARIABLE Cnt2 INTEGER; '#13#10 +
          'BEGIN '#13#10 +
          '  IF (RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_SET_ISSIMPLE'') IS NOT NULL) THEN '#13#10 +
          '    EXIT; '#13#10 +
          ' '#13#10 +
          '  IF ((OLD.debitncu <> NEW.debitncu) or (OLD.creditncu <> NEW.creditncu) or '#13#10 +
          '      (OLD.debitcurr <> NEW.debitcurr) or (OLD.creditcurr <> NEW.creditcurr)) '#13#10 +
          '  THEN BEGIN '#13#10 +
          '    WasUnlock = RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK''); '#13#10 +
          '    IF (:WasUnlock IS NULL) THEN '#13#10 +
          '      RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK'', 1); '#13#10 +
          '    UPDATE ac_record SET debitncu = debitncu - OLD.debitncu + NEW.debitncu, '#13#10 +
          '      creditncu = creditncu - OLD.creditncu + NEW.creditncu, '#13#10 +
          '      debitcurr = debitcurr - OLD.debitcurr + NEW.debitcurr, '#13#10 +
          '      creditcurr = creditcurr - OLD.creditcurr + NEW.creditcurr '#13#10 +
          '    WHERE '#13#10 +
          '      id = OLD.recordkey; '#13#10 +
          '    IF (:WasUnlock IS NULL) THEN '#13#10 +
          '      RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK'', NULL); '#13#10 +
          ' '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (NEW.accountpart <> OLD.accountpart) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    SELECT '#13#10 +
          '      COALESCE(SUM(IIF(accountpart = NEW.accountpart, 1, 0)), 0), '#13#10 +
          '      COALESCE(SUM(IIF(accountpart = OLD.accountpart, 1, 0)), 0) '#13#10 +
          '    FROM ac_entry '#13#10 +
          '    WHERE recordkey = NEW.recordkey AND id <> NEW.id '#13#10 +
          '    INTO :Cnt, :Cnt2; '#13#10 +
          ' '#13#10 +
          '    IF (:Cnt > 1 AND :Cnt2 > 1) THEN '#13#10 +
          '      EXCEPTION ac_e_invalidentry; '#13#10 +
          ' '#13#10 +
          '    WasSetIsSimple = RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_SET_ISSIMPLE''); '#13#10 +
          '    IF (:WasSetIsSimple IS NULL) THEN '#13#10 +
          '      RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_SET_ISSIMPLE'', 1); '#13#10 +
          '    UPDATE ac_entry SET '#13#10 +
          '      issimple = IIF(accountpart = NEW.accountpart, '#13#10 +
          '        IIF(:Cnt > 1, 0, 1), '#13#10 +
          '        IIF(:Cnt2 > 1, 0, 1)) '#13#10 +
          '    WHERE recordkey = NEW.recordkey; '#13#10 +
          '    IF (:WasSetIsSimple IS NULL) THEN '#13#10 +
          '      RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_SET_ISSIMPLE'', NULL); '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  WHEN ANY DO '#13#10 +
          '  BEGIN '#13#10 +
          '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK'', NULL); '#13#10 +
          '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_SET_ISSIMPLE'', NULL); '#13#10 +
          '    EXCEPTION; '#13#10 +
          '  END '#13#10 +
          'END';
        q.ExecQuery;

        q.SQL.Text :=
          'CREATE OR ALTER TRIGGER ac_ad_entry FOR ac_entry '#13#10 +
          '  AFTER DELETE '#13#10 +
          '  POSITION 31700 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE Cnt INTEGER = 0; '#13#10 +
          '  DECLARE VARIABLE WasSetIsSimple INTEGER; '#13#10 +
          '  DECLARE VARIABLE WasUnlock INTEGER; '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NOT EXISTS(SELECT id FROM ac_entry WHERE recordkey = OLD.recordkey)) THEN '#13#10 +
          '    DELETE FROM ac_record WHERE id = OLD.recordkey; '#13#10 +
          '  ELSE BEGIN '#13#10 +
          '    WasUnlock = RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK''); '#13#10 +
          '    IF (:WasUnlock IS NULL) THEN '#13#10 +
          '      RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK'', 1); '#13#10 +
          '    UPDATE ac_record SET '#13#10 +
          '      debitncu = debitncu - OLD.debitncu, '#13#10 +
          '      creditncu = creditncu - OLD.creditncu, '#13#10 +
          '      debitcurr = debitcurr - OLD.debitcurr, '#13#10 +
          '      creditcurr = creditcurr - OLD.creditcurr '#13#10 +
          '    WHERE '#13#10 +
          '      id = OLD.recordkey; '#13#10 +
          '    IF (:WasUnlock IS NULL) THEN '#13#10 +
          '      RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK'', NULL); '#13#10 +
          ' '#13#10 +
          '    IF (OLD.issimple = 0) THEN '#13#10 +
          '    BEGIN '#13#10 +
          '      SELECT COUNT(*) FROM ac_entry '#13#10 +
          '      WHERE recordkey = OLD.recordkey AND accountpart = OLD.accountpart '#13#10 +
          '      INTO :Cnt; '#13#10 +
          ' '#13#10 +
          '      IF (:Cnt = 1) THEN '#13#10 +
          '      BEGIN '#13#10 +
          '        WasSetIsSimple = RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_SET_ISSIMPLE''); '#13#10 +
          '        IF (:WasSetIsSimple IS NULL) THEN '#13#10 +
          '          RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_SET_ISSIMPLE'', 1); '#13#10 +
          '        UPDATE ac_entry SET issimple = 1 '#13#10 +
          '        WHERE recordkey = OLD.recordkey AND accountpart = OLD.accountpart; '#13#10 +
          '        IF (:WasSetIsSimple IS NULL) THEN '#13#10 +
          '          RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_SET_ISSIMPLE'', NULL); '#13#10 +
          '      END '#13#10 +
          '    END '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  WHEN ANY DO '#13#10 +
          '  BEGIN '#13#10 +
          '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK'', NULL); '#13#10 +
          '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_SET_ISSIMPLE'', NULL); '#13#10 +
          '    EXCEPTION; '#13#10 +
          '  END '#13#10 +
          'END';
        q.ExecQuery;

        q.SQL.Text :=
          'CREATE OR ALTER TRIGGER ac_tc_record '#13#10 +
          '  ACTIVE '#13#10 +
          '  ON TRANSACTION COMMIT '#13#10 +
          '  POSITION 9000 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE ID INTEGER; '#13#10 +
          '  DECLARE VARIABLE STM VARCHAR(512); '#13#10 +
          '  DECLARE VARIABLE DNCU DCURRENCY; '#13#10 +
          '  DECLARE VARIABLE CNCU DCURRENCY; '#13#10 +
          '  DECLARE VARIABLE OFFBALANCE INTEGER; '#13#10 +
          '  DECLARE VARIABLE EID INTEGER; '#13#10 +
          'BEGIN '#13#10 +
          '  IF (EXISTS (SELECT * FROM ac_incorrect_record)) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    STM = '#13#10 +
          '      ''SELECT r.id, r.debitncu, r.creditncu, a.offbalance, e.id '' || '#13#10 +
          '      ''FROM ac_record r '' || '#13#10 +
          '      ''  JOIN ac_incorrect_record ir ON ir.id = r.id '' || '#13#10 +
          '      ''  LEFT JOIN ac_entry e ON e.recordkey = r.id '' || '#13#10 +
          '      ''  LEFT JOIN ac_account a ON a.id = e.accountkey''; '#13#10 +
          ' '#13#10 +
          '    FOR '#13#10 +
          '      EXECUTE STATEMENT (:STM) '#13#10 +
          '      INTO :ID, :DNCU, :CNCU, :OFFBALANCE, :EID '#13#10 +
          '    DO BEGIN '#13#10 +
          '      IF ((:EID IS NULL) '#13#10 +
          '        OR ((:OFFBALANCE IS DISTINCT FROM 1) AND (:DNCU <> :CNCU))) THEN '#13#10 +
          '      BEGIN '#13#10 +
          '        EXCEPTION ac_e_invalidentry ''Попытка сохранить некорректную проводку с ИД: '' || :ID; '#13#10 +
          '      END '#13#10 +
          '    END '#13#10 +
          '  END '#13#10 +
          'END';
        q.ExecQuery;

        FTransaction.Commit;
        FTransaction.StartTransaction;

        if not FieldExist2('AC_RECORD', 'INCORRECT', FTransaction) then
        begin
          q.SQL.Text := 'ALTER TABLE ac_record ADD incorrect dboolean DEFAULT 0';
          q.ExecQuery;

          FTransaction.Commit;
          FTransaction.StartTransaction;

          q.SQL.Text := 'UPDATE ac_record SET incorrect = 0 WHERE incorrect IS NULL';
          q.ExecQuery;
        end;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (208, ''0000.0001.0000.0239'', ''31.03.2014'', ''Introducing AC_INCORRECT_RECORD GTT.'') ' +
          '  MATCHING (id)';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (209, ''0000.0001.0000.0240'', ''31.03.2014'', ''AC_TC_RECORD.'') ' +
          '  MATCHING (id)';

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (210, ''0000.0001.0000.0241'', ''03.04.2014'', ''Get back "incorrect" field for ac_record.'') ' +
          '  MATCHING (id)';

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (211, ''0000.0001.0000.0242'', ''04.04.2014'', ''Missed grant for AC_INCORRECT_RECORD.'') ' +
          '  MATCHING (id)';

        q.ExecQuery;
      finally
        q.Free;
      end;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log(E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        raise;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

procedure ModifyAC_ACCOUNTEXSALDO_BAL(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  q: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      q := TIBSQL.Create(nil);
      try
        q.Transaction := FTransaction;

        q.SQL.Text :=
          'CREATE OR ALTER PROCEDURE AC_ACCOUNTEXSALDO_BAL ( '#13#10 +
          '    DATEEND DATE, '#13#10 +
          '    ACCOUNTKEY INTEGER, '#13#10 +
          '    FIELDNAME VARCHAR(60), '#13#10 +
          '    COMPANYKEY INTEGER, '#13#10 +
          '    ALLHOLDINGCOMPANIES INTEGER, '#13#10 +
          '    CURRKEY INTEGER) '#13#10 +
          'RETURNS ( '#13#10 +
          '    DEBITSALDO NUMERIC(15, 4), '#13#10 +
          '    CREDITSALDO NUMERIC(15, 4), '#13#10 +
          '    CURRDEBITSALDO NUMERIC(15, 4), '#13#10 +
          '    CURRCREDITSALDO NUMERIC(15, 4), '#13#10 +
          '    EQDEBITSALDO NUMERIC(15, 4), '#13#10 +
          '    EQCREDITSALDO NUMERIC(15, 4)) '#13#10 +
          ' AS '#13#10 +
          '   DECLARE VARIABLE SALDO NUMERIC(15, 4); '#13#10 +
          '   DECLARE VARIABLE SALDOCURR NUMERIC(15, 4); '#13#10 +
          '   DECLARE VARIABLE SALDOEQ NUMERIC(15, 4); '#13#10 +
          '   DECLARE VARIABLE TEMPVAR varchar(60); '#13#10 +
          '   DECLARE VARIABLE CLOSEDATE DATE; '#13#10 +
          '   DECLARE VARIABLE CK INTEGER; '#13#10 +
          '   DECLARE VARIABLE SQLStatement VARCHAR(2048); '#13#10 +
          '   DECLARE VARIABLE HoldingList VARCHAR(1024) = ''''; '#13#10 +
          '   DECLARE VARIABLE CurrCondition_E VARCHAR(1024) = ''''; '#13#10 +
          '   DECLARE VARIABLE CurrCondition_Bal VARCHAR(1024) = ''''; '#13#10 +
          ' BEGIN '#13#10 +
          '   DEBITSALDO = 0; '#13#10 +
          '   CREDITSALDO = 0; '#13#10 +
          '   CURRDEBITSALDO = 0; '#13#10 +
          '   CURRCREDITSALDO = 0; '#13#10 +
          '   EQDEBITSALDO = 0; '#13#10 +
          '   EQCREDITSALDO = 0; '#13#10 +
          '   CLOSEDATE = CAST((CAST(''17.11.1858'' AS DATE) + GEN_ID(gd_g_entry_balance_date, 0)) AS DATE); '#13#10 +
          ' '#13#10 +
          '   IF (:AllHoldingCompanies = 1) THEN '#13#10 +
          '   BEGIN '#13#10 +
          '     SELECT LIST(h.companykey, '','') '#13#10 +
          '     FROM gd_holding h '#13#10 +
          '     WHERE h.holdingkey = :companykey '#13#10 +
          '     INTO :HoldingList; '#13#10 +
          '     HoldingList = COALESCE(:HoldingList, ''''); '#13#10 +
          '   END '#13#10 +
          ' '#13#10 +
          '   HoldingList = :CompanyKey || IIF(:HoldingList = '''', '''', '','' || :HoldingList); '#13#10 +
          ' '#13#10 +
          '   IF (:CurrKey > 0) THEN '#13#10 +
          '   BEGIN '#13#10 +
          '     CurrCondition_E =   '' AND (e.currkey   = '' || :currkey || '') ''; '#13#10 +
          '     CurrCondition_Bal = '' AND (bal.currkey = '' || :currkey || '') ''; '#13#10 +
          '   END '#13#10 +
          ' '#13#10 +
          '   IF (:dateend >= :CLOSEDATE) THEN '#13#10 +
          '   BEGIN '#13#10 +
          '     sqlstatement = '#13#10 +
          '       ''SELECT '#13#10 +
          '         main.'' || FIELDNAME || '', '#13#10 +
          '         SUM(main.debitncu - main.creditncu), '#13#10 +
          '         SUM(main.debitcurr - main.creditcurr), '#13#10 +
          '         SUM(main.debiteq - main.crediteq), '#13#10 +
          '         main.companykey '#13#10 +
          '       FROM '#13#10 +
          '       ( '#13#10 +
          '         SELECT '#13#10 +
          '           bal.'' || FIELDNAME || '', '#13#10 +
          '           bal.debitncu, bal.creditncu, '#13#10 +
          '           bal.debitcurr, bal.creditcurr, '#13#10 +
          '           bal.debiteq, bal.crediteq, '#13#10 +
          '           bal.companykey '#13#10 +
          '         FROM '#13#10 +
          '           ac_entry_balance bal '#13#10 +
          '         WHERE '#13#10 +
          '           bal.accountkey = '' || CAST(:accountkey AS VARCHAR(20)) || '' '#13#10 +
          '             AND (bal.companykey IN ('' || :HoldingList || ''))'' '#13#10 +
          '            || :CurrCondition_Bal || '' '#13#10 +
          ' '#13#10 +
          '         UNION ALL '#13#10 +
          ' '#13#10 +
          '         SELECT '#13#10 +
          '           e.'' || FIELDNAME || '', '#13#10 +
          '           e.debitncu, e.creditncu, '#13#10 +
          '           e.debitcurr, e.creditcurr, '#13#10 +
          '           e.debiteq, e.crediteq, '#13#10 +
          '           e.companykey '#13#10 +
          '         FROM '#13#10 +
          '           ac_entry e '#13#10 +
          '         WHERE '#13#10 +
          '           e.accountkey = '' || CAST(:accountkey AS VARCHAR(20)) || '' '#13#10 +
          '           AND e.entrydate >= '''''' || CAST(:closedate AS VARCHAR(20)) || '''''' '#13#10 +
          '           AND e.entrydate < '''''' || CAST(:dateend AS VARCHAR(20)) || '''''' '#13#10 +
          '           AND (e.companykey IN ('' || :HoldingList || ''))'' '#13#10 +
          '          || :CurrCondition_E || '' '#13#10 +
          ' '#13#10 +
          '       ) main '#13#10 +
          '       GROUP BY '#13#10 +
          '         main.'' || FIELDNAME || '', main.companykey''; '#13#10 +
          '   END '#13#10 +
          '   ELSE '#13#10 +
          '   BEGIN '#13#10 +
          '     sqlstatement = '#13#10 +
          '       ''SELECT '#13#10 +
          '         main.'' || FIELDNAME || '', '#13#10 +
          '         SUM(main.debitncu - main.creditncu), '#13#10 +
          '         SUM(main.debitcurr - main.creditcurr), '#13#10 +
          '         SUM(main.debiteq - main.crediteq), '#13#10 +
          '         main.companykey '#13#10 +
          '       FROM '#13#10 +
          '       ( '#13#10 +
          '         SELECT '#13#10 +
          '           bal.'' || FIELDNAME || '', '#13#10 +
          '           bal.debitncu, bal.creditncu, '#13#10 +
          '           bal.debitcurr, bal.creditcurr, '#13#10 +
          '           bal.debiteq, bal.crediteq, '#13#10 +
          '           bal.companykey '#13#10 +
          '         FROM '#13#10 +
          '           ac_entry_balance bal '#13#10 +
          '         WHERE '#13#10 +
          '           bal.accountkey = '' || CAST(:accountkey AS VARCHAR(20)) || '' '#13#10 +
          '             AND (bal.companykey IN ('' || :HoldingList || ''))'' '#13#10 +
          '            || :CurrCondition_Bal || '' '#13#10 +
          ' '#13#10 +
          '         UNION ALL '#13#10 +
          ' '#13#10 +
          '         SELECT '#13#10 +
          '           e.'' || FIELDNAME || '', '#13#10 +
          '          - e.debitncu, - e.creditncu, '#13#10 +
          '          - e.debitcurr, - e.creditcurr, '#13#10 +
          '          - e.debiteq, - e.crediteq, '#13#10 +
          '          e.companykey '#13#10 +
          '         FROM '#13#10 +
          '           ac_entry e '#13#10 +
          '         WHERE '#13#10 +
          '           e.accountkey = '' || CAST(:accountkey AS VARCHAR(20)) || '' '#13#10 +
          '           AND e.entrydate >= '''''' || CAST(:dateend AS VARCHAR(20)) || '''''' '#13#10 +
          '           AND e.entrydate < '''''' || CAST(:closedate AS VARCHAR(20)) || '''''' '#13#10 +
          '           AND (e.companykey IN ('' || :HoldingList || ''))'' '#13#10 +
          '           || :CurrCondition_E || '' '#13#10 +
          '        ) main '#13#10 +
          '       GROUP BY '#13#10 +
          '         main.'' || FIELDNAME || '', main.companykey''; '#13#10 +
          '   END '#13#10 +
          ' '#13#10 +
          '   FOR '#13#10 +
          '     EXECUTE STATEMENT '#13#10 +
          '       sqlstatement '#13#10 +
          '     INTO '#13#10 +
          '       :TEMPVAR, :SALDO, :SALDOCURR, :SALDOEQ, :CK '#13#10 +
          '   DO '#13#10 +
          '   BEGIN '#13#10 +
          '     SALDO = COALESCE(:SALDO, 0); '#13#10 +
          '     IF (SALDO > 0) THEN '#13#10 +
          '       DEBITSALDO = DEBITSALDO + SALDO; '#13#10 +
          '     ELSE '#13#10 +
          '       CREDITSALDO = CREDITSALDO - SALDO; '#13#10 +
          '     SALDOCURR = COALESCE(:SALDOCURR, 0); '#13#10 +
          '     IF (SALDOCURR > 0) THEN '#13#10 +
          '       CURRDEBITSALDO = CURRDEBITSALDO + SALDOCURR; '#13#10 +
          '     ELSE '#13#10 +
          '       CURRCREDITSALDO = CURRCREDITSALDO - SALDOCURR; '#13#10 +
          '     SALDOEQ = COALESCE(:SALDOEQ, 0); '#13#10 +
          '     IF (SALDOEQ > 0) THEN '#13#10 +
          '       EQDEBITSALDO = EQDEBITSALDO + SALDOEQ; '#13#10 +
          '     ELSE '#13#10 +
          '       EQCREDITSALDO = EQCREDITSALDO - SALDOEQ; '#13#10 +
          '   END '#13#10 +
          '   SUSPEND; '#13#10 +
          ' END';
        q.ExecQuery;

        q.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_au_storage_data FOR gd_storage_data '#13#10 +
          '  ACTIVE '#13#10 +
          '  AFTER UPDATE '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF ( '#13#10 +
          '    (OLD.data_type = ''F'') '#13#10 +
          '    AND '#13#10 +
          '    ( '#13#10 +
          '      (OLD.name IS DISTINCT FROM NEW.name) '#13#10 +
          '      OR '#13#10 +
          '      (OLD.parent IS DISTINCT FROM NEW.parent) '#13#10 +
          '    ) '#13#10 +
          '  ) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    IF (UPPER(OLD.name) IN (''DFM'', ''NEWFORM'', ''OPTIONS'', ''SUBTYPES'')) THEN '#13#10 +
          '    BEGIN '#13#10 +
          '      IF (EXISTS (SELECT * FROM gd_storage_data WHERE id = OLD.parent AND data_type = ''G'')) THEN '#13#10 +
          '        EXCEPTION gd_e_storage_data ''Can not change system folder '' || OLD.name; '#13#10 +
          '    END '#13#10 +
          ' '#13#10 +
          '    IF ( '#13#10 +
          '      EXISTS ( '#13#10 +
          '        SELECT * '#13#10 +
          '        FROM '#13#10 +
          '          gd_storage_data f '#13#10 +
          '          JOIN gd_storage_data p ON f.parent = p.id '#13#10 +
          '          JOIN gd_storage_data pp ON p.parent = pp.id '#13#10 +
          '        WHERE f.id = OLD.id AND UPPER(p.name) = ''DFM'' '#13#10 +
          '          AND pp.data_type = ''G'') '#13#10 +
          '    ) THEN '#13#10 +
          '      EXCEPTION gd_e_storage_data ''Can not change system folder '' || OLD.name; '#13#10 +
          '  END '#13#10 +
          'END ';
        q.ExecQuery;

        q.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_bd_storage_data FOR gd_storage_data '#13#10 +
          '  ACTIVE '#13#10 +
          '  BEFORE DELETE '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (UPPER(OLD.name) IN (''DFM'', ''NEWFORM'', ''OPTIONS'', ''SUBTYPES'')) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    IF (EXISTS (SELECT * FROM gd_storage_data WHERE id = OLD.parent AND data_type = ''G'')) THEN '#13#10 +
          '      EXCEPTION gd_e_storage_data ''Can not delete system folder '' || OLD.name; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  IF (OLD.data_type = ''F'') THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    IF ( '#13#10 +
          '      EXISTS ( '#13#10 +
          '        SELECT * '#13#10 +
          '        FROM '#13#10 +
          '          gd_storage_data f '#13#10 +
          '          JOIN gd_storage_data p ON f.parent = p.id '#13#10 +
          '          JOIN gd_storage_data pp ON p.parent = pp.id '#13#10 +
          '          JOIN gd_storage_data v ON v.parent = f.id '#13#10 +
          '        WHERE f.id = OLD.id AND UPPER(p.name) = ''DFM'' '#13#10 +
          '          AND pp.data_type = ''G'') '#13#10 +
          '    ) THEN '#13#10 +
          '      EXCEPTION gd_e_storage_data ''System folder is not empty '' || OLD.name; '#13#10 +
          '  END '#13#10 +
          'END';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (204, ''0000.0001.0000.0235'', ''11.03.2014'', ''Issue 3301.'') ' +
          '  MATCHING (id)';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (205, ''0000.0001.0000.0236'', ''17.03.2014'', ''Issue 3330.'') ' +
          '  MATCHING (id)';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (206, ''0000.0001.0000.0237'', ''17.03.2014'', ''Issue 3330. #2.'') ' +
          '  MATCHING (id)';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (207, ''0000.0001.0000.0238'', ''17.03.2014'', ''Triggers for protection of system storage folders.'') ' +
          '  MATCHING (id)';
        q.ExecQuery;
      finally
        q.Free;
      end;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log(E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        raise;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

procedure Issue3373(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  q: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      q := TIBSQL.Create(nil);
      try
        q.Transaction := FTransaction;

        q.SQL.Text := 
          'CREATE OR ALTER TRIGGER gd_aiu_constvalue FOR gd_constvalue '#13#10 +
          '  AFTER INSERT OR UPDATE '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE F DOUBLE PRECISION; '#13#10 +
          '  DECLARE VARIABLE T TIMESTAMP; '#13#10 +
          '  DECLARE VARIABLE D CHAR(1); '#13#10 +
          'BEGIN '#13#10 +
          '  SELECT datatype FROM gd_const '#13#10 +
          '  WHERE id = NEW.constkey '#13#10 +
          '  INTO :D; '#13#10 +
          ' '#13#10 +
          '  IF (:D = ''D'') THEN '#13#10 +
          '    T = CAST(NEW.constvalue AS TIMESTAMP); '#13#10 +
          '  IF (:D = ''N'') THEN '#13#10 +
          '    F = CAST(NEW.constvalue AS DOUBLE PRECISION); '#13#10 +
          'END';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (212, ''0000.0001.0000.0243'', ''29.04.2014'', ''Issue 3373.'') ' +
          '  MATCHING (id)';
        q.ExecQuery;
      finally
        q.Free;
      end;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log(E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        raise;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
