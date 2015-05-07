unit mdf_AddAutoTask;
 
interface
 
uses
  IBDatabase, gdModify;
 
procedure AddAutoTaskTables(IBDB: TIBDatabase; Log: TModifyLog);
 
implementation
 
uses
  IBSQL, SysUtils;
 
procedure AddAutoTaskTables(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  Log('Начато добавление таблиц GD_AUTOTASK и GD_AUTOTASK_LOG');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
 
        FIBSQL.SQL.Text := 
          'CREATE TABLE gd_autotask '#13#10 +
          '( '#13#10 +
          '  id               dintkey, '#13#10 +
          '  name             dname, '#13#10 +
          '  description      dtext180, '#13#10 +
          '  functionkey      dforeignkey,      /* если задано -- будет выполняться скрипт-функция */ '#13#10 +
          '  cmdline          dtext255,         /* если задано -- командная строка для вызова внешней программы */ '#13#10 +
          '  backupfile       dtext255,         /* если задано -- имя файла архива */ '#13#10 +
          '  userkey          dforeignkey,      /* учетная запись, под которой выполнять. если не задана -- выполнять под любой*/ '#13#10 +
          '  exactdate        dtimestamp,       /* дата и время однократного выполнения выполнения. Задача будет вы полнена НЕ РАНЬШЕ указанного значения */ '#13#10 +
          '  monthly          dinteger, '#13#10 +
          '  weekly           dinteger, '#13#10 +
          '  starttime        dtime,            /* время начала интервала для выполнения */ '#13#10 +
          '  endtime          dtime,            /* время конца интервала для выполнения  */ '#13#10 +
          '  creatorkey       dforeignkey, '#13#10 +
          '  creationdate     dcreationdate, '#13#10 +
          '  editorkey        dforeignkey, '#13#10 +
          '  editiondate      deditiondate, '#13#10 +
          '  afull            dsecurity, '#13#10 +
          '  achag            dsecurity, '#13#10 +
          '  aview            dsecurity, '#13#10 +
          '  disabled         ddisabled, '#13#10 +
          '  CONSTRAINT gd_pk_autotask PRIMARY KEY (id), '#13#10 +
          '  CONSTRAINT gd_chk_autotask_monthly CHECK ((monthly BETWEEN -30 AND -1) OR (monthly BETWEEN 1 AND 31)), '#13#10 +
          '  CONSTRAINT gd_chk_autotask_weekly CHECK (weekly BETWEEN 1 AND 7) '#13#10 +
          ');';
        FIBSQL.ExecQuery;
 
        FIBSQL.SQL.Text := 
          'CREATE TABLE gd_autotask_log '#13#10 +
          '( '#13#10 +
          '  id               dintkey, '#13#10 +
          '  autotaskkey      dintkey, '#13#10 +
          '  eventtime        dtimestamp_notnull, '#13#10 +
          '  eventtext        dtext255, '#13#10 +
          '  creatorkey       dforeignkey, '#13#10 +
          '  creationdate     dcreationdate, '#13#10 +
          '  CONSTRAINT gd_pk_autotask_log PRIMARY KEY (id), '#13#10 +
          '  CONSTRAINT gd_fk_autotask_log_autotaskkey '#13#10 +
          '    FOREIGN KEY (autotaskkey) REFERENCES gd_autotask (id) '#13#10 +
          '    ON DELETE CASCADE '#13#10 +
          '    ON UPDATE CASCADE '#13#10 +
          ');';
        FIBSQL.ExecQuery;
 
        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (218, ''0000.0001.0000.0249'', ''28.04.2015'', ''Add GD_AUTOTASK, GD_AUTOTASK_LOG tables.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;
        FIBSQL.Close;
 
        FTransaction.Commit;
        Log('Добавление таблиц GD_AUTOTASK и GD_AUTOTASK_LOG успешно завершено');
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