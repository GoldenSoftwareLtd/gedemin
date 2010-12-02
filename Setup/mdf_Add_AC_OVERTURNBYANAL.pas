unit mdf_Add_AC_OVERTURNBYANAL;

interface

uses
  IBDatabase, gdModify;

procedure AddOverTurnByAnal(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript;

procedure AddOverTurnByAnal(IBDB: TIBDatabase; Log: TModifyLog);
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
      Script.Script.Text :=
        'CREATE TABLE AC_OVERTURNBYANAL ( '#13#10 +
        '    ID              DINTKEY NOT NULL, '#13#10 +
        '    NAME            DNAME, '#13#10 +
        '    INCSUBACCOUNTS  DBOOLEAN, '#13#10 +
        '    LEVEL1          DTEXT1024 NOT NULL COLLATE PXW_CYRL, '#13#10 +
        '    ACCOUNTS        DBLOB NOT NULL, '#13#10 +
        '    SHOWINEXPLORER  DBOOLEAN, '#13#10 +
        '    INNCU           DBOOLEAN, '#13#10 +
        '    INCURR          DBOOLEAN, '#13#10 +
        '    NCUDECDIGITS    DINTEGER, '#13#10 +
        '    NCUSCALE        DINTEGER, '#13#10 +
        '    CURRDECDIGITS   DINTEGER, '#13#10 +
        '    CURRSCALE       DINTEGER, '#13#10 +
        '    CURRKEY         DFOREIGNKEY '#13#10 +
        '); '#13#10 +
        'ALTER TABLE AC_OVERTURNBYANAL ADD CONSTRAINT CHK_AC_OVERTURNBYANAL check ((INNCU IS NOT NULL AND NCUSCALE IS NOT NULL AND NCUSCALE <> 0) OR (INCURR IS NOT NULL AND CURRSCALE IS NOT NULL AND CURRSCALE <> 0 AND CURRKEY IS NOT NULL)); '#13#10 +
        'ALTER TABLE AC_OVERTURNBYANAL ADD CONSTRAINT UNQ_AC_OVERTURNBYANAL UNIQUE (NAME); '#13#10 +
        'ALTER TABLE AC_OVERTURNBYANAL ADD CONSTRAINT PK_AC_OVERTURNBYANAL PRIMARY KEY (ID); '#13#10 +
        'GRANT ALL ON AC_OVERTURNBYANAL TO ADMINISTRATOR; ';

      Script.ExecuteScript;
      FTransaction.Commit;
      FTransaction.StartTransaction;
    finally
      Script.Free;
    end;
  end;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.SQL.Text := 'SELECT * FROM rdb$relations WHERE rdb$relation_name = ''AC_OVERTURNBYANAL''';
        FIBSQL.ExecQuery;
        if FIBSQL.RecordCount = 0 then
        begin
          Log('Добавление таблицы AC_OVERTURNBYANAL');
          CreateTable;
          Log('Добавление прошло успешно');
        end;
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
