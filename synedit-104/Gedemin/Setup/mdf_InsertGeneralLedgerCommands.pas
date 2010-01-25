unit mdf_InsertGeneralLedgerCommands;

interface

uses
  IBDatabase, gdModify;

procedure InsertGeneralLedgerCommands(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript;

procedure InsertGeneralLedgerCommands(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
  procedure CreateTable;
  var
    Script: TIBScript;
  begin
    Script := TIBScript.Create(nil);
    try
      Script.Transaction := FTransaction;
      Script.Database := IBDB;
      try
        Script.Script.Text :=
          'CREATE TABLE AC_GENERALLEDGER ( '#13#10 +
          '    ID             DINTKEY NOT NULL, '#13#10 +
          '    NAME           DNAME NOT NULL COLLATE PXW_CYRL, '#13#10 +
          '    DEFAULTUSE     DBOOLEAN, '#13#10 +
          '    INNCU          DBOOLEAN, '#13#10 +
          '    INCURR         DBOOLEAN, '#13#10 +
          '    NCUDECDIGITS   DINTEGER_NOTNULL, '#13#10 +
          '    NCUSCALE       DINTEGER_NOTNULL, '#13#10 +
          '    CURRDECDIGITS  DINTEGER_NOTNULL NOT NULL, '#13#10 +
          '    CURRSCALE      DINTEGER_NOTNULL NOT NULL, '#13#10 +
          '    CURRKEY        DFOREIGNKEY, '#13#10 +
          '    ACCOUNTKEY     DFOREIGNKEY, '#13#10 +
          '    ENHANCEDSALDO  DBOOLEAN '#13#10 +
          '); '#13#10 +
          'ALTER TABLE AC_GENERALLEDGER ADD CONSTRAINT UNQ_AC_GENERALLEDGER UNIQUE (NAME); '#13#10 +
          'ALTER TABLE AC_GENERALLEDGER ADD CONSTRAINT PK_AC_GENERALLEDGER PRIMARY KEY (ID); '#13#10 +
          'ALTER TABLE AC_GENERALLEDGER ADD CONSTRAINT FK_AC_GENERALLEDGER_ACKEY FOREIGN KEY (ACCOUNTKEY) REFERENCES AC_ACCOUNT (ID); '#13#10 +
          'ALTER TABLE AC_GENERALLEDGER ADD CONSTRAINT FK_AC_GENERALLEDGER_CURRKEY FOREIGN KEY (CURRKEY) REFERENCES GD_CURR (ID); '#13#10 +
          'GRANT ALL ON AC_GENERALLEDGER TO ADMINISTRATOR; '#13#10;
        Script.ExecuteScript;
        FTransaction.Commit;
        IBDB.Connected := False;
        IBDB.Connected := True;
        FTransaction.StartTransaction;
      except
      end;

      try
        Script.Script.Text :=
          'CREATE TABLE AC_G_LEDGERACCOUNT ( '#13#10 +
          'LEDGERKEY   DFOREIGNKEY NOT NULL, '#13#10 +
          'ACCOUNTKEY  DFOREIGNKEY '#13#10 +
          '); '#13#10 +
          'ALTER TABLE AC_G_LEDGERACCOUNT ADD CONSTRAINT FK_AC_G_LEDGERACCOUNT_AKEY FOREIGN KEY (ACCOUNTKEY) REFERENCES AC_ACCOUNT (ID); '#13#10 +
          'ALTER TABLE AC_G_LEDGERACCOUNT ADD CONSTRAINT FK_AC_G_LEDGERACCOUNT_LKEY FOREIGN KEY (LEDGERKEY) REFERENCES AC_GENERALLEDGER (ID); '#13#10 +
          'GRANT ALL ON AC_G_LEDGERACCOUNT TO ADMINISTRATOR; '#13#10;
        Script.ExecuteScript;
        FTransaction.Commit;
        IBDB.Connected := False;
        IBDB.Connected := True;
        FTransaction.StartTransaction;
      except
      end;
    finally
      Script.Free;
    end;
  end;
begin
  Log('Добавление команд в таблицу GD_COMMAND для Главной книги');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.SQL.Text := 'SELECT * FROM rdb$relations WHERE rdb$relation_name = ''AC_GENERALLEDGER''';
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
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT * FROM gd_command WHERE id = 714025';
        FIBSQL.ExecQuery;
        if FIBSQL.Eof then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := ' INSERT INTO gd_command (id, parent, name, cmd, ' +
            ' classname, hotkey, imgindex) VALUES (714025, 714000, ''Главная книга'', ' +
            ' '''', ''Tgdv_frmGeneralLedger'', NULL, 17)';
          FIBSQL.ExecQuery;
          FIBSQL.Close;
        end else
          FIBSQL.Close;

        Log('Добавление прошло успешно');
      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        FTransaction.Rollback;
        Log(E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
