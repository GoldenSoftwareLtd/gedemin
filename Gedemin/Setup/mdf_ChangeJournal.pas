
unit mdf_ChangeJournal;

interface

uses
  IBDatabase, gdModify;

procedure ChangeJournal(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  SysUtils, IBSQL, mdf_MetaData_unit;

procedure ChangeJournal(IBDB: TIBDatabase; Log: TModifyLog);
var
  FIBTransaction: TIBTransaction;
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  FIBTransaction := TIBTransaction.Create(nil);
  try
    FIBTransaction.DefaultDatabase := IBDB;
    ibsql.Transaction := FIBTransaction;
    ibsql.ParamCheck := False;
    try
      FIBTransaction.StartTransaction;

      ibsql.SQL.Text := 'DELETE FROM gd_journal';
      ibsql.ExecQuery;

      FIBTransaction.Commit;
      FIBTransaction.StartTransaction;

      DropField2('GD_JOURNAL', 'SUBSYSTEMKEY', FIBTransaction);
      DropField2('GD_JOURNAL', 'SESSIONKEY', FIBTransaction);
      DropField2('GD_JOURNAL', 'USERKEY', FIBTransaction);
      DropField2('GD_JOURNAL', 'COMPUTERNAME', FIBTransaction);
      DropField2('GD_JOURNAL', 'OPERATIONKEY', FIBTransaction);
      DropField2('GD_JOURNAL', 'BLOB1', FIBTransaction);

      AddField2('GD_JOURNAL', 'CONTACTKEY', 'DFOREIGNKEY', FIBTransaction);
      AddField2('GD_JOURNAL', 'SOURCE', 'DTEXT40', FIBTransaction);
      AddField2('GD_JOURNAL', 'OBJECTID', 'DFOREIGNKEY', FIBTransaction);
      AddField2('GD_JOURNAL', 'DATA', 'DBLOBTEXT80_1251', FIBTransaction);

      ibsql.SQL.Text :=
        'RECREATE TRIGGER gd_bi_journal2 FOR gd_journal '#13#10 +
        '  BEFORE INSERT '#13#10 +
        '  POSITION 2 '#13#10 +
        'AS '#13#10 +
        'BEGIN '#13#10 +
        '  IF (NEW.operationdate IS NULL) THEN '#13#10 +
        '    NEW.operationdate = ''NOW''; '#13#10 +
        ' '#13#10 +
        '  IF (NEW.contactkey IS NULL) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    SELECT contactkey FROM gd_user '#13#10 +
        '    WHERE ibname = CURRENT_USER '#13#10 +
        '    INTO NEW.contactkey; '#13#10 +
        '  END '#13#10 +
        'END ';
      ibsql.ExecQuery;

      ibsql.SQL.Text := 'CREATE DOMAIN dtimestamp_notnull AS TIMESTAMP NOT NULL ';
      try
        ibsql.ExecQuery;
      except
      end;

      ibsql.SQL.Text :=
        'INSERT INTO FIN_VERSIONINFO (ID,VERSIONSTRING,RELEASEDATE,COMMENT) VALUES (42,''0000.0001.0000.0032'',''2002-11-08'',''GD_JOURNAL has got its final state'')';
      try
        ibsql.ExecQuery;
      except
      end;

      FIBTransaction.Commit;
    except
      on E: Exception do
      begin
        if FIBTransaction.InTransaction then
          FIBTransaction.Rollback;
        Log(E.Message);
        raise;
      end;
    end;
  finally
    ibsql.Free;
    FIBTransaction.Free;
  end;
end;

end.
