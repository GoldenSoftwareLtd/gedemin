unit mdf_AddAccountKeyToTypeEntry;

interface

uses
  IBDatabase, gdModify;

procedure AddAccountKeyToTypeEntry(IBDB: TIBDatabase; Log: TModifyLog);

implementation

{uses
  IBSQL, SysUtils, IBScript;

const
TextView =
  'CREATE VIEW AC_V_TRENTRYRECORD( '#13#10 +
  '    DEBITALIAS, '#13#10 +
  '    CREDITALIAS, '#13#10 +
  '    DESCRIPTION, '#13#10 +
  '    TRANSACTIONKEY, '#13#10 +
  '    TRACCOUNTKEY, '#13#10 +
  '    TRRECORDKEY, '#13#10 +
  '    ID, '#13#10 +
  '    ACCOUNTKEY, '#13#10 +
  '    ACCOUNTPART, '#13#10 +
  '    AFULL, '#13#10 +
  '    ACHAG, '#13#10 +
  '    AVIEW, '#13#10 +
  '    DISABLED, '#13#10 +
  '    ISSAVENULL, '#13#10 +
  '    FUNCTIONKEY, '#13#10 +
  '    ENTRYFUNCTIONKEY, '#13#10 +
  '    ENTRYFUNCTIONSTOR, '#13#10 +
  '    DOCUMENTTYPEKEY) '#13#10 +
  'AS '#13#10 +
  'SELECT '#13#10 +
  '  a.alias as debitalias, CAST('''' AS VARCHAR(20)) as creditalias, '#13#10 +
  '  a.name as accountname, '#13#10 +
  '  r.transactionkey, r.accountkey, '#13#10 +
  '  e.trrecordkey, e.id, e.accountkey, e.accountpart, '#13#10 +
  '  r.afull, r.achag, r.aview, r.disabled, r.issavenull, r.functionkey, '#13#10 +
  '  e.functionkey, e.functionstor, r.documenttypekey '#13#10 +
  'FROM '#13#10 +
  '  ac_trrecord r '#13#10 +
  '    JOIN ac_trentry e ON (r.id = e.trrecordkey) '#13#10 +
  '    JOIN ac_account a ON (a.id = e.accountkey) '#13#10 +
  ' '#13#10 +
  'WHERE '#13#10 +
  '  e.accountpart = ''D'' '#13#10 +
  ' '#13#10 +
  'UNION '#13#10 +
  ' '#13#10 +
  'SELECT '#13#10 +
  '  CAST('''' AS VARCHAR(20)) as debitalias, a.alias as creditalias, '#13#10 +
  '  a.name as accountname, '#13#10 +
  '  r.transactionkey, r.accountkey, '#13#10 +
  '  e.trrecordkey, e.id, e.accountkey, e.accountpart, '#13#10 +
  '  r.afull, r.achag, r.aview, r.disabled, r.issavenull, r.functionkey, '#13#10 +
  '  e.functionkey, e.functionstor, r.documenttypekey '#13#10 +
  'FROM '#13#10 +
  '  ac_trrecord r '#13#10 +
  '    JOIN ac_trentry e ON (r.id = e.trrecordkey) '#13#10 +
  '    JOIN ac_account a ON (a.id = e.accountkey) '#13#10 +
  ' '#13#10 +
  'WHERE '#13#10 +
  '  e.accountpart = ''C'' '#13#10 +
  ' '#13#10 +
  'UNION '#13#10 +
  ' '#13#10 +
  'SELECT '#13#10 +
  '  CAST('' '' AS VARCHAR(20)), CAST('' '' AS VARCHAR(20)), '#13#10 +
  '  r.description, '#13#10 +
  '  r.transactionkey, r.accountkey, '#13#10 +
  '  r.id, CAST(0 AS INTEGER), '#13#10 +
  '  CAST(0 AS INTEGER), CAST(''Z'' AS VARCHAR(1)), '#13#10 +
  '  r.afull, r.achag, r.aview, r.disabled, r.issavenull, r.functionkey, '#13#10 +
  '  CAST(0 AS INTEGER), e.functionstor, r.documenttypekey '#13#10 +
  ' '#13#10 +
  'FROM '#13#10 +
  '  ac_trrecord r '#13#10 +
  '    LEFT JOIN ac_trentry e ON (e.id = -1)';
}

procedure AddAccountKeyToTypeEntry(IBDB: TIBDatabase; Log: TModifyLog);
{var
  FTransaction: TIBTransaction;

  procedure AddField;
  var
    Script: TIBScript;
  begin
    Script := TIBScript.Create(nil);
    try
      Script.Transaction := FTransaction;
      Script.Database := IBDB;
      if not FTransaction.InTransaction then
        FTransaction.StartTransaction;
      Script.Script.Text := 'ALTER TABLE AC_TRRECORD ADD ACCOUNTKEY DFOREIGNKEY';
      Script.ExecuteScript;
      FTransaction.Commit;
      FTransaction.StartTransaction;
    finally
      Script.Free;
    end;
  end;

  procedure AddForeignKey;
  var
    Script: TIBScript;
  begin
    Script := TIBScript.Create(nil);
    try
      Script.Transaction := FTransaction;
      Script.Database := IBDB;
      if not FTransaction.InTransaction then
        FTransaction.StartTransaction;
      Script.Script.Text :=
        'ALTER TABLE ac_trrecord ADD CONSTRAINT ac_fk_trrecord_ak '#13#10 +
        '  FOREIGN KEY (accountkey) REFERENCES ac_account(id) '#13#10 +
        '  ON UPDATE CASCADE '#13#10 +
        '  ON DELETE SET NULL';
      Script.ExecuteScript;
      FTransaction.Commit;
      FTransaction.StartTransaction;
    finally
      Script.Free;
    end;
  end;

  procedure UpdateAccountKey;
  var
    ibsql: TIBSQL;
  begin
    ibsql:= TIBSQL.Create(nil);
    try
      ibsql.Transaction := FTransaction;
      ibsql.Database := IBDB;
      if not FTransaction.InTransaction then
        FTransaction.StartTransaction;
      ibsql.SQL.Text :=
        'UPDATE ac_trrecord SET accountkey = (SELECT MAX(accountkey) FROM ac_companyaccount WHERE isactive = 1) WHERE accountkey IS NULL';
      ibsql.ExecQuery;
      FTransaction.Commit;
      FTransaction.StartTransaction;
    finally
      ibsql.Free;
    end;
  end;

  procedure FieldExist;
  var
    FIBSQL: TIBSQL;
  begin
    FIBSQL := TIBSQL.Create(nil);
    try
      FIBSQL.Transaction := FTransaction;
      FIBSQL.SQL.Text := 'SELECT * FROM rdb$relation_fields WHERE rdb$field_name = ''ACCOUNTKEY'' AND rdb$relation_name = ''AC_TRRECORD''';
      FIBSQL.ExecQuery;
      if FIBSQL.RecordCount = 0 then
      begin
        Log('Добавление поля AccountKey в таблицу AC_TRRECORD');
        AddField;
        AddForeignKey;
      end;
      UpdateAccountKey;

      if not FTransaction.InTransaction then
        FTransaction.StartTransaction;
      FIBSQL.Close;
      FIBSQL.SQL.Text  := 'DROP VIEW AC_V_TRENTRYRECORD';
      try
        FIBSQL.ExecQuery;
        FTransaction.Commit;
      except
        FTransaction.Rollback;
      end;
      FIBSQL.Close;

      FTransaction.StartTransaction;
      FIBSQL.SQL.Text := TextView;
      try
        FIBSQL.ExecQuery;
        FTransaction.Commit;
        Log('Проводка: Скорректировано представление AC_V_TRENTRYRECORD.');
      except
        FTransaction.Rollback;
      end;

      FTransaction.StartTransaction;
      FIBSQL.SQL.Text := 'GRANT ALL ON AC_V_TRENTRYRECORD TO administrator';
      try
        FIBSQL.ExecQuery;
        FTransaction.Commit;
      except
        FTransaction.Rollback;
      end;
      Log('Добавление прошло успешно');

     finally
       FIBSQL.Free;
     end;
  end;}

begin
{  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FieldExist;
      if FTransaction.InTransaction then
        FTransaction.Commit;
    except
      on E: Exception do
      begin
        FTransaction.Rollback;
        Log('Ошибка: ' + E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;}
end;

end.
