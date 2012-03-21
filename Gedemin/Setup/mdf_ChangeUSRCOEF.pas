unit mdf_ChangeUSRCOEF;

interface

uses
  IBDatabase, gdModify;

procedure ChangeUSRCOEF(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure ChangeUSRCOEF(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FIBSQL := TIBSQL.Create(nil);
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FIBSQL.Transaction := FTransaction;
      FTransaction.StartTransaction;

      FIBSQL.SQL.Text := 'SELECT * FROM rdb$fields ' +
        ' WHERE rdb$field_name = ''USR$FA_CORRECTCOEFF''';

      FIBSQL.ExecQuery;
      if FIBSQL.RecordCount > 0 then
      begin
        FIBSQL.Close;
        FIBSQL.SQL.Text := 'ALTER DOMAIN USR$FA_CORRECTCOEFF DROP CONSTRAINT';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

        FTransaction.Commit;
        FTransaction.StartTransaction;

        FIBSQL.SQL.Text := 'ALTER DOMAIN USR$FA_CORRECTCOEFF ADD CHECK ((VALUE IS NULL) OR (VALUE>0 AND VALUE<=2000))';
        FIBSQL.ExecQuery;
      end;

      FIBSQL.Close;
      FIBSQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (137, ''0000.0001.0000.0168'', ''17.01.2012'', ''alter DOMAIN USR$FA_CORRECTCOEFF'') ' +
        '  MATCHING (id)';
      FIBSQL.ExecQuery;

      FIBSQL.Close;
      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        raise;
      end;
    end;
  finally
    FIBSQL.Free;
    FTransaction.Free;
  end;
end;


end.
