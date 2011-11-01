unit mdf_AddPK_AC_G_LEDGERACCOUNT;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit;

procedure AddPK_AC_G_LEDGERACCOUNT(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript, classes, gd_common_functions;

const
  AC_G_LEDGERACCOUNT: TmdfTable =
    (TableName: 'AC_G_LEDGERACCOUNT';
    Description: ' ALTER COLUMN ACCOUNTKEY TYPE DFOREIGNKEY NOT NULL'  );

  AlterConstraintCount = 1;
  AlterConstraints: array[0..AlterConstraintCount -  1] of TmdfConstraint = (
    (TableName: 'AC_G_LEDGERACCOUNT'; ConstraintName: 'PK_AC_G_LEDGERACCOUNT';
      Description: ' PRIMARY KEY (LEDGERKEY, ACCOUNTKEY)')
  );

procedure AddPK_AC_G_LEDGERACCOUNT(IBDB: TIBDatabase; Log: TModifyLog);
var
  I: Integer;
  SQL: TIBSQL;
  Transaction: TIBTransaction;
begin
//  AlterRelation(AC_G_LEDGERACCOUNT, IBDB);
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDataBAse := IBDB;
    Transaction.StartTransaction;
    try
      SQL := TIBSQL.Create(nil);
      try
        SQl.Transaction := Transaction;
        SQl.SQl.Text := 'update RDB$RELATION_FIELDS set'#13#10 +
          'RDB$NULL_FLAG = 1'#13#10 +
          'where (RDB$FIELD_NAME = ''ACCOUNTKEY'') and'#13#10 +
          '(RDB$RELATION_NAME = ''AC_G_LEDGERACCOUNT'')';
        SQL.ExecQuery;
      finally
        SQl.Free;
      end;
      Transaction.Commit;
      try
        IBDB.Connected := False;
      finally
        IBDB.Connected := True;
      end;
    except
      Transaction.RollBack;
    end;
  finally
    Transaction.Free;
  end;

  for I := 0 to AlterConstraintCount - 1 do
  begin
    if not ConstraintExist(AlterConstraints[I], IBDB) then
    begin
      Log(Format('Добавление первичного ключа %s в таблицу %s', [AlterConstraints[i].ConstraintName,
        AlterConstraints[I].TableName]));
      try
        AddConstraint(AlterConstraints[I], IBDB);
      except
        on E: Exception do
          Log('Ошибка: ' + E.Message);
      end;
    end;
  end;


  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDataBAse := IBDB;
    Transaction.StartTransaction;
    try
      SQL := TIBSQL.Create(nil);
      try
        SQl.Transaction := Transaction;
        SQL.ParamCheck := False;
        SQl.SQl.Text :=
          'ALTER TRIGGER GD_AU_DOCUMENT '#13#10 +
          '  AFTER UPDATE'#13#10 +
          '  POSITION 0'#13#10 +
          'AS'#13#10 +
          'BEGIN'#13#10 +
          '  IF (NEW.PARENT IS NULL) THEN'#13#10 +
          '  BEGIN'#13#10 +
          '    UPDATE gd_document SET documentdate = NEW.documentdate,'#13#10 +
          '      number = NEW.number, companykey = NEW.companykey'#13#10 +
          '    WHERE (parent = NEW.ID)'#13#10 +
          '      AND ((documentdate <> NEW.documentdate)'#13#10 +
          '        OR (number <> NEW.number) OR (companykey <> NEW.companykey));'#13#10 +
          '  END ELSE'#13#10 +
          '  BEGIN'#13#10 +
          '    UPDATE gd_document SET editiondate = NEW.editiondate,'#13#10 +
          '      editorkey = NEW.editorkey'#13#10 +
          '    WHERE (ID = NEW.parent) AND (editiondate <> NEW.editiondate);'#13#10 +
          '  END'#13#10 +
          'END';
        SQL.ExecQuery;
      finally
        SQl.Free;
      end;
      Transaction.Commit;
      try
        IBDB.Connected := False;
      finally
        IBDB.Connected := True;
      end;
    except
      Transaction.RollBack;
    end;
  finally
    Transaction.Free;
  end;

  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDataBAse := IBDB;
    Transaction.StartTransaction;
    try
      SQL := TIBSQL.Create(nil);
      try
        SQl.Transaction := Transaction;
        SQL.ParamCheck := False;
        SQl.SQl.Text :=
          'CREATE TRIGGER GD_AD_DOCUMENT FOR GD_DOCUMENT'#13#10 +
          '  AFTER DELETE'#13#10 +
          '  POSITION 0'#13#10 +
          'AS'#13#10 +
          'BEGIN'#13#10 +
          '  IF (NOT (OLD.PARENT IS NULL)) THEN'#13#10 +
          '  BEGIN'#13#10 +
          '    UPDATE gd_document SET editiondate = ''NOW'''#13#10 +
          '    WHERE ID = OLD.parent;'#13#10 +
          '  END'#13#10 +
          'END';
        SQL.ExecQuery;
      finally
        SQl.Free;
      end;
      Transaction.Commit;
      try
        IBDB.Connected := False;
      finally
        IBDB.Connected := True;
      end;
    except
      Transaction.RollBack;
    end;
  finally
    Transaction.Free;
  end;

  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDataBAse := IBDB;
    Transaction.StartTransaction;
    try
      SQL := TIBSQL.Create(nil);
      try
        SQl.Transaction := Transaction;
        SQL.ParamCheck := False;
        SQl.SQl.Text :=
          'CREATE TRIGGER GD_AI_DOCUMENT FOR GD_DOCUMENT'#13#10 +
          '  AFTER INSERT'#13#10 +
          '  POSITION 0'#13#10 +
          'AS'#13#10 +
          'BEGIN'#13#10 +
          '  IF (NOT (NEW.PARENT IS NULL)) THEN'#13#10 +
          '  BEGIN'#13#10 +
          '    UPDATE gd_document SET editiondate = NEW.editiondate,'#13#10 +
          '      editorkey = NEW.editorkey'#13#10 +
          '    WHERE (ID = NEW.parent) AND (editiondate <> NEW.editiondate);'#13#10 +
          '  END'#13#10 +
          'END';
        SQL.ExecQuery;
      finally
        SQl.Free;
      end;
      Transaction.Commit;
      try
        IBDB.Connected := False;
      finally
        IBDB.Connected := True;
      end;
    except
      Transaction.RollBack;
    end;
  finally
    Transaction.Free;
  end;
end;

end.
