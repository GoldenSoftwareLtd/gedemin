unit mdf_AddSMTP;
 
interface
 
uses
  IBDatabase, gdModify;
 
procedure AddSMTPTable(IBDB: TIBDatabase; Log: TModifyLog);
 
implementation
 
uses
  IBSQL, SysUtils, mdf_metadata_unit;
 
procedure AddSMTPTable(IBDB: TIBDatabase; Log: TModifyLog);
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
      try
        FIBSQL.Transaction := FTransaction;
        
        FIBSQL.SQL.Text :=
          'CREATE TABLE gd_smtp '#13#10 +
          '( '#13#10 +
          '  id               dintkey, '#13#10 +
          '  name             dname, '#13#10 +
          '  description      dtext180, '#13#10 +
          '  email            dname, '#13#10 +
          '  login            dname, '#13#10 +
          '  passw            VARCHAR(256) NOT NULL, '#13#10 +
          '  ipsec            dtext8 DEFAULT NULL, '#13#10 +
          '  timeout          dinteger_notnull DEFAULT -1, '#13#10 +
          '  server           dtext80 NOT NULL, '#13#10 +
          '  port             dinteger_notnull DEFAULT 25, '#13#10 +
          ' '#13#10 +
          '  creatorkey       dforeignkey, '#13#10 +
          '  creationdate     dcreationdate, '#13#10 +
          '  editorkey        dforeignkey, '#13#10 +
          '  editiondate      deditiondate, '#13#10 +
          '  afull            dsecurity, '#13#10 +
          '  achag            dsecurity, '#13#10 +
          '  aview            dsecurity, '#13#10 +
          '  disabled         ddisabled, '#13#10 +
          ' '#13#10 +
          '  CONSTRAINT gd_pk_smtp PRIMARY KEY (id)' +
          ')';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'GRANT ALL ON GD_SMTP TO administrator';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (221, ''0000.0001.0000.0252'', ''25.06.2015'', ''Added GD_SMTP table.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;
      finally
        FIBSQL.Free;
      end;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        Log(E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;  
 
end.