unit mdf_ModifyBLOBDdocumentdate;

interface

uses
  IBDatabase, gdModify;
 
procedure ModifyBLOB(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure ModifyBLOB(IBDB: TIBDatabase; Log: TModifyLog);
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
          'SELECT * FROM rdb$fields ' +
          'WHERE rdb$field_name = ''DDOCUMENTDATE'' ' +
          '  AND rdb$validation_source > '''' ';
        FIBSQL.ExecQuery;

        if not FIBSQL.EOF then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'ALTER DOMAIN ddocumentdate DROP CONSTRAINT';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'ALTER DOMAIN ddocumentdate ADD' + #13#10 +
          '  CHECK (VALUE BETWEEN ''01.01.1990'' AND ''31.12.2099'')';
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (202, ''0000.0001.0000.0233'', ''03.03.2014'', ''Issue 3323'') ' +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;
      finally
        FIBSQL.Free;
      end;

      FTransaction.Commit;
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