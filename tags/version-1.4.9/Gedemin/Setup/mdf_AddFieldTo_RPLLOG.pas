unit mdf_AddFieldTo_RPLLOG;

interface

uses
  IBDatabase, gdModify;

procedure AddFieldTo_RPLLOG(IBDB: TIBDatabase; Log: TModifyLog);


implementation

uses
  IBSQL, SysUtils, gd_KeyAssoc;

procedure AddFieldTo_RPLLOG(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    FIBSQL := TIBSQL.Create(nil);
    try
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.SQL.Text :=
           ' ALTER TABLE RPL$LOG ' +
           ' ADD DBKEY DRPLINTEGER';
        FIBSQL.ExecQuery;
        FIBSQL.Transaction.Commit;
        FIBSQL.Transaction.StartTransaction;
        FIBSQL.SQL.Text :=
          ' ALTER TABLE RPL$LOG ADD FOREIGN KEY (DBKEY) ' +
          ' REFERENCES RPL$REPLICATIONDB ON DELETE CASCADE ';
        FIBSQL.ExecQuery;
        FIBSQL.Transaction.Commit;

        Log('Добавлено поле DBKEY в таблицу RPL$LOG');
      except
        FTransaction.Rollback;
      end;
    finally
      FIBSQL.Free;
    end;
  finally
    FTransaction.Free;
  end;

end;


end.
