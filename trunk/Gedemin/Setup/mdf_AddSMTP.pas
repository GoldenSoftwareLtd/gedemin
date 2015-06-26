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
  Log('Начато добавление таблицы GD_SMTP');
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
          '  id               dintkey,                     /* Первичный ключ          */ '#13#10 +
          '  name             dname,                       /* имя                     */ '#13#10 +
          '  description      dtext180,                    /* описание                */ '#13#10 +
          '  email            demail NOT NULL,             /* адрес электронной почты */ '#13#10 +
          '  login            dusername,                   /* логин                   */ '#13#10 +
          '  passw            VARCHAR(256) NOT NULL,       /* пароль                  */ '#13#10 +
          '  ipsec            dtext8 DEFAULT NULL,         /* протокол безопасности   SSLV2, SSLV23, SSLV3, TLSV1 */ '#13#10 +
          '  timeout          dinteger_notnull DEFAULT -1, '#13#10 +
          '  server           dtext80 NOT NULL,            /* SMTP Sever */ '#13#10 +
          '  port             dinteger_notnull,            /* SMTP Port */ '#13#10 +
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
          '  CONSTRAINT gd_pk_smtp PRIMARY KEY (id), '#13#10 +
          '  CONSTRAINT gd_chk_smtp_timeout CHECK (timeout >= -1), '#13#10 +
          '  CONSTRAINT gd_chk_smtp_ipsec CHECK(ipsec IN (''SSLV2'', ''SSLV23'', ''SSLV3'', ''TLSV1'')), '#13#10 +
          '  CONSTRAINT gd_chk_smtp_server CHECK (server > ''''), '#13#10 +
          '  CONSTRAINT gd_chk_smtp_port CHECK (port > 0 AND port < 65536) '#13#10 +
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
        FIBSQL.Close;

        FTransaction.Commit;
        Log('Добавление таблицы GD_SMTP успешно завершено');
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