unit mdf_ModifyBlockTriggers;

interface

uses
  IBDatabase, gdModify;

procedure ModifyBlockTriggers(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, mdf_metadata_unit;

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

        if not GeneratorExist2('gd_g_block_group', FTransaction) then
        begin
          SQL.Text := 'CREATE GENERATOR gd_g_block_group ';
          ExecQuery;
          
          SQL.Text := 'SET GENERATOR gd_g_block_group TO 0';
          ExecQuery;

          SQL.Text := 'SET GENERATOR gd_g_block TO 0';
          ExecQuery;
        end;

        if not ProcedureExist2('INV_MAKEREST', FTransaction) then
        begin
          SQL.Text:=
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
          Log('Добавление процедуры пересчета остатков');
        end;

        SQL.Text :=
          'CREATE OR ALTER TRIGGER GD_BU_FUNCTION FOR GD_FUNCTION '#13#10 +
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

        SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (64, ''0000.0001.0000.0092'', ''01.03.2005'', ''Sync triggers procedures changed'') ' +
          '  MATCHING (id)';
        ExecQuery;
      finally
        FIBSQL.Free;
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
