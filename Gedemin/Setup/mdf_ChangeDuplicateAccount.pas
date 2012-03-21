unit mdf_ChangeDuplicateAccount;

interface

uses
  IBDatabase, gdModify, IBSQL, SysUtils;

procedure ChangeDuplicateAccount(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  mdf_metadata_unit;

procedure ChangeDuplicateAccount(IBDB: TIBDatabase; Log: TModifyLog);
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
        'UPDATE ' +
        '  ac_account ' +
        'SET ' +
        '  alias = SUBSTRING(alias || ''-'' || id FROM 1 FOR 20) ' +
        'WHERE ' +
        '  UPPER(TRIM(alias)) IN ( ' +
        '    SELECT ' +
        '      UPPER(TRIM(a1.alias)) ' +
        '    FROM ' +
        '      ac_account a1 ' +
        '      JOIN ac_account a1root ' +
        '        ON a1root.lb < a1.lb AND a1root.rb >= a1.rb AND a1root.parent IS NULL ' +
        '      JOIN ac_account a2 ' +
        '        ON UPPER(a1.alias) = UPPER(a2.alias) AND a1.id < a2.id ' +
        '      JOIN ac_account a2root ' +
        '        ON a2root.lb < a2.lb AND a2root.rb >= a2.rb AND a2root.parent IS NULL ' +
        '    WHERE ' +
        '      a2root.id = a1root.id ' +
        '  )';
      SQL.ExecQuery;

      CreateException2('ac_e_invalidaccount', 'Invalid account!', Tr);

      SQL.Close;
      SQL.ParamCheck := False;
      SQL.SQL.Text :=
        'CREATE OR ALTER TRIGGER AC_AIU_ACCOUNT_CHECKALIAS FOR AC_ACCOUNT '#13#10 +
        '  ACTIVE '#13#10 +
        '  AFTER INSERT OR UPDATE '#13#10 +
        '  POSITION 32000 '#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE P VARCHAR(1) = NULL; '#13#10 +
        'BEGIN '#13#10 +
        '  IF (INSERTING OR (NEW.alias <> OLD.alias)) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    IF (EXISTS '#13#10 +
        '      (SELECT'#13#10 +
        '         root.id, UPPER(TRIM(allacc.alias)), COUNT(*) '#13#10 +
        '       FROM ac_account root '#13#10 +
        '         JOIN ac_account allacc ON allacc.lb > root.lb AND allacc.rb <= root.rb '#13#10 +
        '       WHERE '#13#10 +
        '         root.parent IS NULL '#13#10 +
        '       GROUP BY '#13#10 +
        '         1, 2 '#13#10 +
        '       HAVING '#13#10 +
        '         COUNT(*) > 1) '#13#10 +
        '      ) '#13#10 +
        '     THEN '#13#10 +
        '       EXCEPTION ac_e_invalidaccount ''Duplicate account aliases are not allowed!''; '#13#10 +
        '  END '#13#10 +
        ''#13#10 +
        '  IF (INSERTING OR (NEW.parent IS DISTINCT FROM OLD.parent) '#13#10 +
        '    OR (NEW.accounttype <> OLD.accounttype)) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    SELECT accounttype FROM ac_account WHERE id = NEW.parent INTO :P; '#13#10 +
        '    P = COALESCE(:P, ''Z''); '#13#10 +
        ' '#13#10 +
        '    IF (NOT ( '#13#10 +
        '        (NEW.accounttype = ''C'' AND NEW.parent IS NULL) '#13#10 +
        '        OR '#13#10 +
        '        (NEW.accounttype = ''F'' AND :P IN (''C'', ''F'')) '#13#10 +
        '        OR '#13#10 +
        '        (NEW.accounttype = ''A'' AND :P IN (''C'', ''F'')) '#13#10 +
        '        OR '#13#10 +
        '        (NEW.accounttype = ''S'' AND :P IN (''A'', ''S'')) )) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      EXCEPTION ac_e_invalidaccount; '#13#10 +
        '    END '#13#10 +
        '  END '#13#10 +
        'END ';
      SQL.ExecQuery;

      DropTrigger2('AC_ACCOUNT_BI11', Tr);
      DropTrigger2('AC_ACCOUNT_BU0', Tr);

      DropException2('AC_E_MUST_INSERT_ACCOUNT_IN_F', Tr);
      DropException2('AC_E_MUST_INSERT_FOLDER_IN_F', Tr);
      DropException2('AC_E_CANT_INSERT_CARD_IN_OTHER', Tr);
      DropException2('ac_e_invalidaccountalias', Tr);

      SQL.Close;
      SQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (140, ''0000.0001.0000.0171'', ''14.03.2012'', ''Trigger AC_AIU_ACCOUNT_CHECKALIAS added.'') ' +
        '  MATCHING (id)';
      SQL.ExecQuery;
      SQL.Close;

      SQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (141, ''0000.0001.0000.0172'', ''14.03.2012'', ''Trigger AC_AIU_ACCOUNT_CHECKALIAS added. Part #2.'') ' +
        '  MATCHING (id)';
      SQL.ExecQuery;
      SQL.Close;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
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
