unit mdf_GrantTables;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit;

procedure GrantTables(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript;

const
  TableCount = 6;
  Tables: array[0..TableCount-1] of TmdfTable = (
    (TableName: 'AC_QUANTITY'; Description: ''),
    (TableName: 'AC_ACCT_CONFIG'; Description: ''),
    (TableName: 'AC_ACCVALUE'; Description: ''),
    (TableName: 'AC_AUTOENTRY'; Description: ''),
    (TableName: 'AC_LEDGER_ACCOUNTS'; Description: ''),
    (TableName: 'WG_POSITIONS'; Description: '')
  );

procedure GrantTables(IBDB: TIBDatabase; Log: TModifyLog);
var
  I: Integer;
  SQL: TIBSQL;
  Transaction: TIBTransaction;
begin
  Transaction :=  TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := IBDB;
    Transaction.StartTransaction;
    try
      SQl := TIBSQL.Create(nil);
      try
        SQL.Transaction := Transaction;
        for I := 0 to TableCount - 1 do
        begin
          if RelationExist(Tables[i], IBDB) then
          begin
            SQL.SQL.Text :=  Format('GRANT ALL ON %s TO ADMINISTRATOR ', [Tables[I].TableName]);
            SQL.ExecQuery;
            SQl.Close;
          end;
        end;
      finally
        SQL.Free;
      end;
      Transaction.Commit;
      Log('success');
    except
      on E: Exception do
      begin
        Transaction.Rollback;
        Log(E.Message);
      end;
    end;
  finally
    Transaction.Free;
  end;
end;

end.
