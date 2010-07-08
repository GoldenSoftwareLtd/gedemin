unit mdf_InsertLedgerCommands;

interface

uses
  IBDatabase, gdModify;

procedure InsertLedgerCommands(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript;

procedure InsertLedgerCommands(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
  procedure CreateTable;
  begin
    FIBSQL.Close;
    FIBSQL.SQL.Text :=
      'CREATE TABLE ac_ledger ( '#13#10 +
      '  id               dintkey, '#13#10 +
      '  name             dname UNIQUE, '#13#10 +
      '  accountkey       dintkey, '#13#10 +
      '  incsubaccounts   dboolean_notnull DEFAULT 0, '#13#10 +
      '  showdebit        dboolean_notnull DEFAULT 1, '#13#10 +
      '  showcredit       dboolean_notnull DEFAULT 1, '#13#10 +
      '  showsubaccounts  dboolean_notnull DEFAULT 1, '#13#10 +
      '  level1           dtext1024, '#13#10 +
      '  ascsorting       dboolean_notnull DEFAULT 1, '#13#10 +
      '  inncu            dboolean_notnull DEFAULT 1, '#13#10 +
      '  incurr           dboolean_notnull DEFAULT 0, '#13#10 +
      '  currkey          dforeignkey, '#13#10 +
      '  ncudecdigits     dinteger_notnull DEFAULT 0, '#13#10 +
      '  ncuscale         dinteger_notnull DEFAULT 1, '#13#10 +
      '  currdecdigits    dinteger_notnull DEFAULT 2, '#13#10 +
      '  currscale        dinteger_notnull DEFAULT 1, '#13#10 +
      '  reserved         dreserved, '#13#10 +
      '  showinexplorer   dboolean, '#13#10 +
      ' '#13#10 +
      '  CONSTRAINT ac_pk_ledger PRIMARY KEY (id), '#13#10 +
      '  CONSTRAINT ac_fk_ledger_accountkey FOREIGN KEY (accountkey) '#13#10 +
      '    REFERENCES ac_account (id), '#13#10 +
      '  CONSTRAINT ac_fk_ledger_currkey FOREIGN KEY (currkey) '#13#10 +
      '    REFERENCES gd_curr (id) '#13#10 +
      '); ';
    FIBSQL.ExecQuery;
    FIBSQL.Close;
    FTransaction.Commit;
    IBDB.Connected := False;
    IBDB.Connected := True;
    FTransaction.StartTransaction;
  end;

  procedure CreateProcedure;
  var
    Script: TIBScript;
  begin
    Script := TIBScript.Create(nil);
    try
      Script.Transaction := FTransaction;
      Script.Database := IBDB;
      script.Script.Text :=
        'SET TERM ^ ;'#13#10 +
        'CREATE PROCEDURE AC_GETSIMPLEENTRY ( '#13#10 +
        '    AACCOUNTKEY INTEGER, '#13#10 +
        '    ARECORDKEY INTEGER, '#13#10 +
        '    ACORRACCOUNTKEY INTEGER) '#13#10 +
        'RETURNS ( '#13#10 +
        '    ID INTEGER, '#13#10 +
        '    ACCOUNTKEY INTEGER, '#13#10 +
        '    RECORDKEY INTEGER, '#13#10 +
        '    ACCOUNTPART VARCHAR(1), '#13#10 +
        '    CORRID INTEGER, '#13#10 +
        '    CORRACCOUNTKEY INTEGER, '#13#10 +
        '    CORRACCOUNTPART VARCHAR(1), '#13#10 +
        '    DEBIT NUMERIC(18,4), '#13#10 +
        '    CREDIT NUMERIC(18,4), '#13#10 +
        '    DEBITCURR NUMERIC(18,4), '#13#10 +
        '    CREDITCURR NUMERIC(18,4)) '#13#10 +
        'AS '#13#10 +
        'BEGIN '#13#10 +
        '  FOR '#13#10 +
        '    select '#13#10 +
        '      e.id, '#13#10 +
        '      e.accountkey, '#13#10 +
        '      e.recordkey, '#13#10 +
        '      e.accountpart, '#13#10 +
        '      corr_e.id, '#13#10 +
        '      corr_e.accountkey, '#13#10 +
        '      corr_e.accountpart, '#13#10 +
        '      e.debitncu, '#13#10 +
        '      e.creditncu, '#13#10 +
        '      e.creditcurr, '#13#10 +
        '      e.debitcurr '#13#10 +
        '    from '#13#10 +
        '      ac_entry e '#13#10 +
        '      join ac_entry corr_e on e.recordkey = corr_e.recordkey and '#13#10 +
        '        e.accountpart <> corr_e.accountpart '#13#10 +
        '    where '#13#10 +
        '      e.recordkey = :arecordkey and '#13#10 +
        '      e.accountkey = :aaccountkey and '#13#10 +
        '      corr_e.accountkey = :acorraccountkey and  '#13#10 +
        '      1 >= ( '#13#10 +
        '        select '#13#10 +
        '          count(*) '#13#10 +
        '        from '#13#10 +
        '          ac_entry '#13#10 +
        '        where '#13#10 +
        '          recordkey = e.recordkey and '#13#10 +
        '          accountpart <> e.accountpart ) '#13#10 +
        '    union all '#13#10 +
        '    select '#13#10 +
        '      e.id, '#13#10 +
        '      e.accountkey, '#13#10 +
        '      e.recordkey, '#13#10 +
        '      e.accountpart, '#13#10 +
        '      corr_e.id, '#13#10 +
        '      corr_e.accountkey, '#13#10 +
        '      corr_e.accountpart, '#13#10 +
        '      corr_e.creditncu, '#13#10 +
        '      corr_e.debitncu, '#13#10 +
        '      corr_e.creditcurr, '#13#10 +
        '      corr_e.debitcurr '#13#10 +
        '   from '#13#10 +
        '      ac_entry e '#13#10 +
        '      join ac_entry corr_e on e.recordkey = corr_e.recordkey and '#13#10 +
        '        e.accountpart <> corr_e.accountpart '#13#10 +
        '    where '#13#10 +
        '      e.recordkey = :arecordkey and '#13#10 +
        '      e.accountkey = :aaccountkey and '#13#10 +
        '      corr_e.accountkey = :acorraccountkey and '#13#10 +
        '      1 < ( '#13#10 +
        '        select '#13#10 +
        '          count(*) '#13#10 +
        '        from '#13#10 +
        '          ac_entry '#13#10 +
        '        where '#13#10 +
        '          recordkey = e.recordkey and '#13#10 +
        '          accountpart <> e.accountpart ) '#13#10 +
        '      INTO :ID, '#13#10 +
        '         :ACCOUNTKEY, '#13#10 +
        '         :RECORDKEY, '#13#10 +
        '         :ACCOUNTPART, '#13#10 +
        '         :CORRID, '#13#10 +
        '         :CORRACCOUNTKEY, '#13#10 +
        '         :CORRACCOUNTPART, '#13#10 +
        '         :DEBIT, '#13#10 +
        '         :CREDIT, '#13#10 +
        '         :DEBITCURR, '#13#10 +
        '         :CREDITCURR '#13#10 +
        '  DO '#13#10 +
        '  BEGIN '#13#10 +
        '    SUSPEND; '#13#10 +
        '  END '#13#10 +
        'END ^ '#13#10 +
        'SET TERM ; ^'#13#10 +
        'GRANT ALL ON EXECUTE ON PROCEDURE AC_GETSIMPLEENTRY TO ADMINISTRATOR;';
      Script.ExecuteScript;
      FTransaction.Commit;
      FTransaction.StartTransaction;
    finally
      Script.Free;
    end;
  end;
begin
  Log('Добавление команд в таблицу GD_COMMAND для журнал-ордера');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.SQL.Text := 'SELECT * FROM rdb$relations WHERE rdb$relation_name = ''AC_LEDGER''';
        FIBSQL.ExecQuery;
        if FIBSQL.EOF then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'CREATE DOMAIN dinteger_notnull AS INTEGER NOT NULL';
          try
            FIBSQL.ExecQuery;
          except
          end;  
          FTransaction.Commit;
          FTransaction.StartTransaction;
          CreateTable;
        end else
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'SELECT * FROM rdb$relation_fields WHERE ' +
            'rdb$relation_name = ''AC_LEDGER'' and rdb$field_name in (' +
            '''DATEBEGIN'', ''DATEEND'', ''USESYSTEMDATE'', ''LEVEL2'',' +
            '''LEVEL3'', ''LEVEL4'', ''LEVEL5'', ''SHOWTOTALS'', ''SHOWSZEROS'',' +
            '''SHOWEMPTYLINES'', ''STOREDPROCEDURE'')';
          FIBSQL.ExecQuery;

          if not FIBSQL.Eof then
          begin
            FIBSQL.Close;
            FIBSQL.SQl.Text := 'DROP TABLE AC_LEDGER';
            try
              FIBSQL.ExecQuery;
            except
            end;
            FTransaction.Commit;
            IBDB.Connected := False;
            IBDB.Connected := True;
            FTransaction.StartTransaction;

            CreateTable;
          end;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT * FROM RDB$PROCEDURES WHERE rdb$procedure_name = ''AC_GETSIMPLEENTRY''';
        FIBSQL.ExecQuery;
        if FIBSQl.Eof then
        begin
          CreateProcedure;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT * FROM rdb$relation_fields WHERE rdb$relation_name = ''AC_LEDGER'' AND rdb$field_name = ''SHOWINEXPLORER''';
        FIBSQL.ExecQuery;
        if FIBSQL.Eof then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'ALTER TABLE AC_LEDGER ADD SHOWINEXPLORER DBOOLEAN';
          FIBSQL.ExecQuery;
          FIBSQL.Close;
        end else
          FIBSQL.Close;

        FIBSQL.SQL.Text := 'SELECT * FROM gd_command WHERE id = 714021';
        FIBSQL.ExecQuery;
        if FIBSQL.Eof then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := ' INSERT INTO gd_command (id, parent, name, cmd, ' +
            ' classname, hotkey, imgindex) VALUES (714021, 714000, ''Журнал-ордер'', ' +
            ' '''', ''Tgdv_frmLedger'', NULL, 17)';
          FIBSQL.ExecQuery;
          FIBSQL.Close;
        end else
          FIBSQL.Close;

        FIBSQL.SQL.Text := 'UPDATE gd_command SET parent = 714021, name = ''Настройка журнал-ордера'' ' +
          ' WHERE id = 714020';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

        Log('Добавление прошло успешно');
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
