unit mdf_AddAccountStoredProc;

interface

uses
  IBDatabase, gdModify;

procedure AddAccountStoredProc(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure AddAccountStoredProc(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;

const
  txt_AC_ACCOUNTEXSALDO =
    'CREATE PROCEDURE AC_ACCOUNTEXSALDO ( '#13#10+
    '  DATEEND DATE, '#13#10+
    '  ACCOUNTKEY INTEGER, '#13#10+
    '  FIELDNAME VARCHAR(60), '#13#10+
    '  COMPANYKEY INTEGER) '#13#10+
    'RETURNS '#13#10+
    '  (DEBITSALDO NUMERIC(15, 4), '#13#10+
    '   CREDITSALDO NUMERIC(15, 4)) '#13#10+
    'AS '#13#10+
    'BEGIN '#13#10+
    '  DEBITSALDO = 0; '#13#10+
    '  CREDITSALDO = 0; '#13#10+
    '  SUSPEND; '#13#10+
    'END ';
  txt_AC_CIRCULATIONLIST =
    'CREATE PROCEDURE AC_CIRCULATIONLIST( '#13#10 +
    '    DATEBEGIN DATE, '#13#10 +
    '    DATEEND DATE, '#13#10 +
    '    COMPANYKEY INTEGER, '#13#10 +
    '    ACCOUNTKEY INTEGER) '#13#10 +
    'RETURNS ( '#13#10 +
    '    ALIAS VARCHAR(20), '#13#10 +
    '    NAME VARCHAR(180), '#13#10 +
    '    ID INTEGER, '#13#10 +
    '    BEGINDEBIT NUMERIC(15,4), '#13#10 +
    '    BEGINCREDIT NUMERIC(15,4), '#13#10 +
    '    DEBIT NUMERIC(15,4), '#13#10 +
    '    CREDIT NUMERIC(15,4), '#13#10 +
    '    ENDDEBIT NUMERIC(15,4), '#13#10 +
    '    ENDCREDIT NUMERIC(15,4)) '#13#10 +
    'AS '#13#10 +
    '  DECLARE VARIABLE ACTIVITY VARCHAR(1); '#13#10 +
    '  DECLARE VARIABLE SALDO NUMERIC(15, 4); '#13#10 +
    '  DECLARE VARIABLE FIELDNAME VARCHAR(60); '#13#10 +
    '  DECLARE VARIABLE LB INTEGER; '#13#10 +
    '  DECLARE VARIABLE RB INTEGER; '#13#10 +
    'BEGIN '#13#10 +
    '  /* Procedure Text */ '#13#10 +
    ' '#13#10 +
    '  IF (ACCOUNTKEY = 0) THEN '#13#10 +
    '    SELECT c.lb, c.rb FROM ac_companyaccount p '#13#10 +
    '      JOIN ac_account c ON c.id = p.accountkey '#13#10 +
    '    WHERE p.companykey = :companykey '#13#10 +
    '    INTO :lb, :rb; '#13#10 +
    '  ELSE '#13#10 +
    '    SELECT c.lb, c.rb FROM ac_account c '#13#10 +
    '    WHERE c.id = :ACCOUNTKEY '#13#10 +
    '    INTO :lb, :rb; '#13#10 +
    ' '#13#10 +
    '  FOR '#13#10 +
    '    SELECT a.ID, a.ALIAS, a.activity, f.fieldname, a.Name '#13#10 +
    '    FROM ac_account a LEFT JOIN at_relation_fields f ON a.analyticalfield = f.id '#13#10 +
    '    WHERE '#13#10 +
    '      a.accounttype IN (''A'', ''S'') AND '#13#10 +
    '      a.LB >= :LB AND a.RB <= :RB AND a.alias <> ''00'' '#13#10 +
    '    ORDER BY a.alias '#13#10 +
    '    INTO :id, :ALIAS, :activity, :fieldname, :name '#13#10 +
    '  DO '#13#10 +
    '  BEGIN '#13#10 +
    '    BEGINDEBIT = 0; '#13#10 +
    '    BEGINCREDIT = 0; '#13#10 +
    ' '#13#10 +
    '    IF (activity <> ''B'') THEN '#13#10 +
    '    BEGIN '#13#10 +
    '      SELECT SUM(e.DEBITNCU - e.CREDITNCU) FROM '#13#10 +
    '        ac_entry e LEFT JOIN ac_record r ON e.recordkey = r.id '#13#10 +
    '      WHERE '#13#10 +
    '        e.accountkey = :id AND r.recorddate < :datebegin AND r.companykey = :companykey '#13#10 +
    '      INTO :SALDO; '#13#10 +
    '      IF (SALDO IS NULL) THEN '#13#10 +
    '        SALDO = 0; '#13#10 +
    '   '#13#10 +
    ' '#13#10 +
    '      IF (SALDO > 0) THEN '#13#10 +
    '        BEGINDEBIT = SALDO; '#13#10 +
    '      ELSE '#13#10 +
    '        BEGINCREDIT = -SALDO; '#13#10 +
    ' '#13#10 +
    '    END '#13#10 +
    '    ELSE '#13#10 +
    '    BEGIN '#13#10 +
    '      SELECT debitsaldo, creditsaldo FROM AC_ACCOUNTEXSALDO(:DATEBEGIN, :ID, :FIELDNAME, :companykey) '#13#10 +
    '      INTO :begindebit, :begincredit; '#13#10 +
    '    END '#13#10 +
    ' '#13#10 +
    ' '#13#10 +
    '    SELECT SUM(e.DEBITNCU) FROM '#13#10 +
    '      ac_entry e LEFT JOIN ac_record r ON e.recordkey = r.id '#13#10 +
    '    WHERE '#13#10 +
    '      e.accountkey = :id AND r.recorddate >= :datebegin AND '#13#10 +
    '      r.recorddate <= :dateend AND r.companykey = :companykey '#13#10 +
    '    INTO :DEBIT; '#13#10 +
    ' '#13#10 +
    '    IF (DEBIT IS NULL) THEN '#13#10 +
    '      DEBIT = 0; '#13#10 +
    ' '#13#10 +
    '    SELECT SUM(e.CREDITNCU) FROM '#13#10 +
    '      ac_entry e LEFT JOIN ac_record r ON e.recordkey = r.id '#13#10 +
    '    WHERE '#13#10 +
    '      e.accountkey = :id AND r.recorddate >= :datebegin AND '#13#10 +
    '      r.recorddate <= :dateend AND r.companykey = :companykey '#13#10 +
    '    INTO :CREDIT; '#13#10 +
    ' '#13#10 +
    '    IF (CREDIT IS NULL) THEN '#13#10 +
    '      CREDIT = 0; '#13#10 +
    ' '#13#10 +
    '    ENDDEBIT = 0; '#13#10 +
    '    ENDCREDIT = 0; '#13#10 +
    ' '#13#10 +
    '    IF ((BEGINDEBIT <> 0) OR (BEGINCREDIT <> 0) OR (DEBIT <> 0) OR (CREDIT <> 0)) THEN '#13#10 +
    '    BEGIN '#13#10 +
    '      IF (ACTIVITY <> ''B'') THEN '#13#10 +
    '      BEGIN '#13#10 +
    '        SALDO = BEGINDEBIT - BEGINCREDIT + DEBIT - CREDIT; '#13#10 +
    '        IF (SALDO > 0) THEN '#13#10 +
    '          ENDDEBIT = SALDO; '#13#10 +
    '        ELSE '#13#10 +
    '          ENDCREDIT = -SALDO; '#13#10 +
    '      END '#13#10 +
    '      ELSE '#13#10 +
    '      BEGIN '#13#10 +
    '        SELECT debitsaldo, creditsaldo FROM AC_ACCOUNTEXSALDO(:DATEEND + 1, :ID, :FIELDNAME, :COMPANYKEY) '#13#10 +
    '        INTO :enddebit, :endcredit; '#13#10 +
    '      END '#13#10 +
    '      SUSPEND; '#13#10 +
    '    END '#13#10 +
    '  END '#13#10 +
    ' '#13#10 +
    'END ';

begin
  Log('Добавление процедур для формирования оборотной ведомости');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.SQL.Text := txt_AC_ACCOUNTEXSALDO;
        FIBSQL.ParamCheck := False;
        try
          FIBSQL.ExecQuery
        except
        end;
        FIBSQL.Close;
        FIBSQL.SQL.Text := txt_AC_CIRCULATIONLIST;
        try
          FIBSQL.ExecQuery
        except
        end;

        FIBSQL.Close;

        FIBSQL.SQL.Text := 'GRANT EXECUTE ON PROCEDURE AC_ACCOUNTEXSALDO TO administrator';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

        FIBSQL.SQL.Text := 'GRANT EXECUTE ON PROCEDURE AC_CIRCULATIONLIST TO administrator';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

        FIBSQL.SQL.Text := 'INSERT INTO GD_COMMAND (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED) ' +
          ' VALUES (714100,714000,''Оборотная ведомость'',''acc_CirculationList'',0,NULL,17,NULL,''Tgdv_frmAcctCirculationList'',NULL,-1,-1,-1,0,NULL)';
        try
          FIBSQL.ExecQuery;
        except
        end;  
        FIBSQL.Close;

        FTransaction.Commit;

        
        Log('Добавление процедур прошло успешно');
      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        FTransaction.Rollback;
        Log('Ошибка: ' + E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
