unit mdf_ModifyBlockTriggers;

interface

uses
  IBDatabase, gdModify;

procedure ModifyBlockTriggers(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;


procedure ModifyBlockTriggers(IBDB: TIBDatabase; Log: TModifyLog);
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

        try
          SQL.Text := 'CREATE GENERATOR gd_g_block_group ';
          ExecQuery;
        except
        end;

        Close;
        SQL.Text := 'SET GENERATOR gd_g_block_group TO 0';
        ExecQuery;

        Close;
        SQL.Text := 'SET GENERATOR gd_g_block TO 0';
        ExecQuery;

        Close;
        SQL.Text :=
         'CREATE TRIGGER AC_AD_ENTRY_DELETERECORD FOR AC_ENTRY ' +
         '  ACTIVE AFTER DELETE POSITION 0 ' +
         'AS ' +
         'BEGIN ' +
         '  DELETE FROM AC_RECORD WHERE ID = OLD.RECORDKEY; ' +
         'END ';
        try
          ExecQuery;
        except
        end;

        Close;
        SQL.Text := 'DROP TRIGGER AC_AD_ENTRY_ISSIMPLE ';
        ExecQuery;

        Close;
        SQL.Text :=
          'CREATE TRIGGER AC_AD_ENTRY_ISSIMPLE FOR AC_ENTRY ' +
          'ACTIVE AFTER DELETE POSITION 1 ' +
          'AS ' +
          'declare variable CountEntry integer; ' +
          'begin ' +
          '  CountEntry = 0; ' +
          '  if (old.issimple = 0) then ' +
          '  begin ' +
          '    select ' +
          '      count(e.id) ' +
          '    from ' +
          '      ac_entry e ' +
          '    where ' +
          '      e.recordkey = old.recordkey ' +
          '      and ' +
          '      e.accountpart = old.accountpart ' +
          '      and ' +
          '      e.id != old.id ' +
          '    into :CountEntry; ' +
          '    if ( CountEntry = 1) ' +
          '    then ' +
          '    begin ' +
          '      update ' +
          '        ac_entry e ' +
          '      set ' +
          '        e.issimple = 1 ' +
          '      where ' +
          '        e.recordkey = old.recordkey ' +
          '        and ' +
          '        e.accountpart = old.accountpart; ' +
          '    end ' +
          '  end ' +
          'end ';
        ExecQuery;
        Close;

        {SQL.Text :=
          'DROP TRIGGER ac_bi_entry_block ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE TRIGGER ac_bi_entry_block FOR ac_entry ' +
          '  INACTIVE ' +
          '  BEFORE INSERT ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          'BEGIN ' +
          '  IF (CAST(NEW.entrydate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '  BEGIN ' +
          '    IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '    BEGIN ' +
          '      EXCEPTION gd_e_block; ' +
          '    END ELSE ' +
          '    BEGIN ' +
          '      SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' +
          '        INTO :IG; ' +
          '      IF (BIN_AND(GEN_ID(gd_g_block_group, 0), :IG) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'DROP TRIGGER ac_bu_entry_block ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE TRIGGER ac_bu_entry_block FOR ac_entry ' +
          '  INACTIVE ' +
          '  BEFORE UPDATE ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          'BEGIN ' +
          '  IF (CAST(NEW.entrydate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '  BEGIN ' +
          '    IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '    BEGIN ' +
          '      EXCEPTION gd_e_block; ' +
          '    END ELSE ' +
          '    BEGIN ' +
          '      SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' +
          '        INTO :IG; ' +
          '      IF (BIN_AND(GEN_ID(gd_g_block_group, 0), :IG) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'DROP TRIGGER ac_bd_entry_block  ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE TRIGGER ac_bd_entry_block FOR ac_entry ' +
          '  INACTIVE ' +
          '  BEFORE DELETE ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          'BEGIN ' +
          '  IF (CAST(OLD.entrydate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '  BEGIN ' +
          '    IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '    BEGIN ' +
          '      EXCEPTION gd_e_block; ' +
          '    END ELSE ' +
          '    BEGIN ' +
          '      SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' +
          '        INTO :IG; ' +
          '      IF (BIN_AND(GEN_ID(gd_g_block_group, 0), :IG) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'DROP TRIGGER gd_bi_document_block ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE TRIGGER gd_bi_document_block FOR gd_document ' +
          '  INACTIVE ' +
          '  BEFORE INSERT ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          'BEGIN ' +
          '  IF (CAST(NEW.documentdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '  BEGIN ' +
          '    IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '    BEGIN ' +
          '      EXCEPTION gd_e_block; ' +
          '    END ELSE ' +
          '    BEGIN ' +
          '      SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' +
          '        INTO :IG; ' +
          '      IF (BIN_AND(GEN_ID(gd_g_block_group, 0), :IG) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'DROP TRIGGER gd_bu_document_block ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE TRIGGER gd_bu_document_block FOR gd_document ' +
          '  INACTIVE ' +
          '  BEFORE UPDATE ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          'BEGIN ' +
          '  IF (CAST(NEW.documentdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '  BEGIN ' +
          '    IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '    BEGIN ' +
          '      EXCEPTION gd_e_block; ' +
          '    END ELSE ' +
          '    BEGIN ' +
          '      SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' +
          '        INTO :IG; ' +
          '      IF (BIN_AND(GEN_ID(gd_g_block_group, 0), :IG) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'DROP TRIGGER gd_bd_document_block ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE TRIGGER gd_bd_document_block FOR gd_document ' +
          '  INACTIVE ' +
          '  BEFORE DELETE ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          'BEGIN ' +
          '  IF (CAST(OLD.documentdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '  BEGIN ' +
          '    IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '    BEGIN ' +
          '      EXCEPTION gd_e_block; ' +
          '    END ELSE ' +
          '    BEGIN ' +
          '      SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' +
          '        INTO :IG; ' +
          '      IF (BIN_AND(GEN_ID(gd_g_block_group, 0), :IG) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        try
          SQL.Text :=
            'DROP TRIGGER inv_bi_card_block ';
          ExecQuery;
        except
        end;
        Close;

        SQL.Text :=
          'CREATE TRIGGER inv_bi_card_block FOR inv_card ' +
          '  INACTIVE ' +
          '  BEFORE INSERT ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE D DATE; ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
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
          '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' +
          '          INTO :IG; ' +
          '        IF (BIN_AND(GEN_ID(gd_g_block_group, 0), :IG) = 0) THEN ' +
          '        BEGIN ' +
          '          EXCEPTION gd_e_block; ' +
          '        END ' +
          '      END ' +
          '    END ' +
          '  END   ' +
          'END ';
        ExecQuery;
        Close;

        try
          SQL.Text :=
            'DROP TRIGGER inv_bu_card_block ';
          ExecQuery;
        except
        end;
        Close;

        SQL.Text :=
          'CREATE TRIGGER inv_bu_card_block FOR inv_card ' +
          '  INACTIVE ' +
          '  BEFORE UPDATE ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE D DATE; ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
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
          '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' +
          '          INTO :IG; ' +
          '        IF (BIN_AND(GEN_ID(gd_g_block_group, 0), :IG) = 0) THEN ' +
          '        BEGIN ' +
          '          EXCEPTION gd_e_block; ' +
          '        END ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        try
          SQL.Text :=
            'DROP TRIGGER inv_bd_card_block ';
          ExecQuery;
        except
        end;
        Close;

        SQL.Text :=
          'CREATE TRIGGER inv_bd_card_block FOR inv_card ' +
          '  INACTIVE ' +
          '  BEFORE DELETE ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE D DATE; ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
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
          '        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' +
          '          INTO :IG; ' +
          '        IF (BIN_AND(GEN_ID(gd_g_block_group, 0), :IG) = 0) THEN ' +
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
          'DROP TRIGGER inv_bi_movement_block ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE TRIGGER inv_bi_movement_block FOR inv_movement ' +
          '  INACTIVE ' +
          '  BEFORE INSERT ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          'BEGIN ' +
          '  IF (CAST(NEW.movementdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '  BEGIN ' +
          '    IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '    BEGIN ' +
          '      EXCEPTION gd_e_block; ' +
          '    END ELSE ' +
          '    BEGIN ' +
          '      SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' +
          '        INTO :IG; ' +
          '      IF (BIN_AND(GEN_ID(gd_g_block_group, 0), :IG) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'DROP TRIGGER inv_bu_movement_block ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE TRIGGER inv_bu_movement_block FOR inv_movement ' +
          '  INACTIVE ' +
          '  BEFORE UPDATE ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          'BEGIN ' +
          '  IF (CAST(NEW.movementdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '  BEGIN ' +
          '    IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '    BEGIN ' +
          '      EXCEPTION gd_e_block; ' +
          '    END ELSE ' +
          '    BEGIN ' +
          '      SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' +
          '        INTO :IG; ' +
          '      IF (BIN_AND(GEN_ID(gd_g_block_group, 0), :IG) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'DROP TRIGGER inv_bd_movement_block ';
        ExecQuery;
        Close;

        SQL.Text :=
          'CREATE TRIGGER inv_bd_movement_block FOR inv_movement ' +
          '  INACTIVE ' +
          '  BEFORE DELETE ' +
          '  POSITION 28017 ' +
          'AS ' +
          '  DECLARE VARIABLE IG INTEGER; ' +
          'BEGIN ' +
          '  IF (CAST(OLD.movementdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
          '  BEGIN ' +
          '    IF (GEN_ID(gd_g_block_group, 0) = 0) THEN ' +
          '    BEGIN ' +
          '      EXCEPTION gd_e_block; ' +
          '    END ELSE ' +
          '    BEGIN ' +
          '      SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER ' +
          '        INTO :IG; ' +
          '      IF (BIN_AND(GEN_ID(gd_g_block_group, 0), :IG) = 0) THEN ' +
          '      BEGIN ' +
          '        EXCEPTION gd_e_block; ' +
          '      END ' +
          '    END ' +
          '  END ' +
          'END ';
        ExecQuery;}

        Close;
        SQL.Text :=
          'SELECT * FROM rdb$procedures WHERE rdb$procedure_name = ''INV_MAKEREST''';
        ExecQuery;
        if EOF then
        begin
          Close;
          ParamCheck := False;
          SQl.Text:=
            'CREATE PROCEDURE inv_makerest                               '#13#10 +
            'AS                                                          '#13#10 +
            '  DECLARE VARIABLE CONTACTKEY INTEGER;                      '#13#10 +
            '  DECLARE VARIABLE CARDKEY INTEGER;                         '#13#10 +
            '  DECLARE VARIABLE BALANCE NUMERIC(15, 4);                  '#13#10 +
            'BEGIN                                                       '#13#10 +
            '  DELETE FROM INV_BALANCE;                                  '#13#10 +
            '  FOR                                                       '#13#10 +
            '    SELECT m.contactkey, m.cardkey, SUM(m.debit - m.credit) '#13#10 +
            '      FROM                                                  '#13#10 +
            '        inv_movement m                                      '#13#10 +
            '      WHERE disabled = 0                                    '#13#10 +
            '    GROUP BY m.contactkey, m.cardkey                        '#13#10 +
            '    INTO :contactkey, :cardkey, :balance                    '#13#10 +
            '  DO                                                        '#13#10 +
            '    INSERT INTO inv_balance (contactkey, cardkey, balance)  '#13#10 +
            '      VALUES (:contactkey, :cardkey, :balance);             '#13#10 +
            'END ';
          ExecQuery;
          Close;
          Log('Добавление процедуры пересчета остатков');
        end else
          Close;

        Close;
        SQL.Text := 'SELECT * FROM rdb$triggers ' +
          ' WHERE rdb$trigger_name = ''GD_BU_FUNCTION''';
        ExecQuery;
        if RecordCount = 0 then
        begin
          Close;
          SQL.Text :=
            'CREATE TRIGGER GD_BU_FUNCTION FOR GD_FUNCTION     '#13#10 +
            'ACTIVE BEFORE UPDATE POSITION 0                   '#13#10 +
            'AS                                                '#13#10 +
            'begin                                             '#13#10 +
            '  IF (NEW.modulecode IS NULL) then                '#13#10 +
            '    IF (OLD.modulecode IS NULL) THEN              '#13#10 +
            '      NEW.modulecode = 1010001;/*ID Application*/ '#13#10 +
            '    ELSE                                          '#13#10 +
            '      NEW.modulecode = OLD.modulecode;            '#13#10 +
            '  IF (NEW.publicfunction IS NULL) then            '#13#10 +
            '    IF (OLD.publicfunction IS NULL) THEN          '#13#10 +
            '      NEW.publicfunction = 0;                     '#13#10 +
            '    ELSE                                          '#13#10 +
            '      NEW.publicfunction = OLD.publicfunction;    '#13#10 +
            'end';
          ExecQuery;
          Close;
          Log('GD_FUNCTION: Добавление триггера ''GD_BU_FUNCTION''');
        end else
          Close;

        SQL.Text :=
          'CREATE OR ALTER EXCEPTION AC_E_ENTRYBEFOREDOCUMENT ''Entry date before document date'' ';
        ExecQuery;

        Close;
        SQL.Text :=
          'CREATE OR ALTER TRIGGER ac_bi_record FOR ac_record'#13#10 +
          '  BEFORE INSERT'#13#10 +
          '  POSITION 0'#13#10 +
          'AS'#13#10 +
          '  DECLARE VARIABLE D DATE;'#13#10 +
          'BEGIN'#13#10 +
          '  /* Если ключ не присвоен, присваиваем */'#13#10 +
          '  IF (NEW.ID IS NULL) THEN'#13#10 +
          '    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);'#13#10 +
          ''#13#10 +
          '  NEW.debitncu = 0;'#13#10 +
          '  NEW.debitcurr = 0;'#13#10 +
          '  NEW.creditncu = 0;'#13#10 +
          '  NEW.creditcurr = 0;'#13#10 +
          '  NEW.incorrect = 0;'#13#10 +
          ''#13#10 +
          '  SELECT documentdate'#13#10 +
          '  FROM gd_document'#13#10 +
          '  WHERE id = NEW.documentkey'#13#10 +
          '  INTO :D;'#13#10 +
          ''#13#10 +
          '  IF (:D > NEW.recorddate) THEN'#13#10 +
          '  BEGIN'#13#10 +
          '    EXCEPTION AC_E_ENTRYBEFOREDOCUMENT;'#13#10 +
          '  END'#13#10 +
          ''#13#10 +
          'END';
        ExecQuery;

        Close;
        SQL.Text :=
          'CREATE OR ALTER TRIGGER ac_bu_record FOR ac_record '#13#10 +
          '  BEFORE UPDATE '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE D DATE; '#13#10 +
          'BEGIN '#13#10 +
          '  /* Если ключ не присвоен, присваиваем */ '#13#10 +
          ' '#13#10 +
          '  IF ((NEW.debitncu <> NEW.creditncu) OR (NEW.debitcurr <> NEW.creditcurr)) THEN '#13#10 +
          '    NEW.incorrect = 1; '#13#10 +
          '  ELSE '#13#10 +
          '    NEW.incorrect = 0; '#13#10 +
          ' '#13#10 +
          '  SELECT documentdate '#13#10 +
          '  FROM gd_document '#13#10 +
          '  WHERE id = NEW.documentkey '#13#10 +
          '  INTO :D; '#13#10 +
          ' '#13#10 +
          '  IF (:D > NEW.recorddate) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    EXCEPTION AC_E_ENTRYBEFOREDOCUMENT; '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  UPDATE ac_entry e '#13#10 +
          '    SET e.entrydate = NEW.recorddate '#13#10 +
          '    WHERE e.recordkey = NEW.id; '#13#10 +
          ' '#13#10 +
          'END ';
        ExecQuery;
        Close;

        SQL.Text :=
          'ALTER PROCEDURE AT_P_SYNC_TRIGGERS ( '#13#10 +
          '    RELATION_NAME VARCHAR (31)) '#13#10 +
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
          '    FROM at_triggers '#13#10 +
          '      LEFT JOIN rdb$triggers '#13#10 +
          '        ON triggername=rdb$trigger_name '#13#10 +
          '          AND relationname=rdb$relation_name '#13#10 +
          '    WHERE '#13#10 +
          '      rdb$trigger_name IS NULL AND relationname = :RELATION_NAME '#13#10 +
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
          '     t.triggername IS NULL AND rdb$relation_name = :RELATION_NAME '#13#10 +
          '    INTO :RN, :TN, :TI, :ID '#13#10 +
          '  DO BEGIN '#13#10 +
          '    RN = TRIM(RN); '#13#10 +
          '    TN = TRIM(TN); '#13#10 +
          '    IF (TI IS NULL) THEN '#13#10 +
          '      TI = 0; '#13#10 +
          '    IF (TI > 1) THEN '#13#10 +
          '      TI = 1; '#13#10 +
          '    INSERT INTO at_triggers( '#13#10 +
          '      relationname, triggername, relationkey, trigger_inactive) '#13#10 +
          '    VALUES ( '#13#10 +
          '      :RN, :TN, :ID, :TI); '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  /* проверяем триггеры на активность*/ '#13#10 +
          '  FOR '#13#10 +
          '    SELECT ri.rdb$trigger_inactive, ri.rdb$trigger_name '#13#10 +
          '    FROM rdb$triggers ri '#13#10 +
          '    LEFT JOIN at_triggers t ON ri.rdb$trigger_name = t.triggername '#13#10 +
          '    WHERE ((t.trigger_inactive IS NULL) OR '#13#10 +
          '    (t.trigger_inactive <> ri.rdb$trigger_inactive) OR '#13#10 +
          '    (ri.rdb$trigger_inactive IS NULL AND t.trigger_inactive = 1)) AND '#13#10 +
          '    (ri.rdb$relation_name = :RELATION_NAME) '#13#10 +
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
        ExecQuery;
        Close;

        SQL.Text :=
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
          '     (t.triggername IS NULL) and (r.id IS NOT NULL) '#13#10 +
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
        ExecQuery;

        Close;
        SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (64, ''0000.0001.0000.0092'', ''01.03.2005'', ''Sync triggers procedures changed'') ' +
          '  MATCHING (id)';
        ExecQuery;

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
