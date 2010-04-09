unit mdf_AddFieldsToInv_BalanceOptions;

interface

uses
  IBDatabase, gdModify;

procedure AddFieldsToInv_BalanceOptions(IBDB: TIBDatabase; Log: TModifyLog);


implementation

uses
  IBSQL, SysUtils, gd_KeyAssoc;

procedure AddFieldsToInv_BalanceOptions(IBDB: TIBDatabase; Log: TModifyLog);
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
           ' ALTER TABLE INV_BALANCEOPTION ' +
           ' ADD GOODVIEWFIELDS DBLOBTEXT80 ';
        FIBSQL.ExecQuery;
        FIBSQL.Transaction.Commit;
        Log('Добавлено поле GoodViewFields в таблицу INV_BALANCEOPTION');
      except
        FTransaction.Rollback;
      end;
      try
        FIBSQL.Transaction.StartTransaction;
        FIBSQL.SQL.Text :=
           ' ALTER TABLE INV_BALANCEOPTION ' +
           ' ADD GOODSUMFIELDS DBLOBTEXT80 ';
        FIBSQL.ExecQuery;
        FIBSQL.Transaction.Commit;
        Log('Добавлено поле GoodSumFields в таблицу INV_BALANCEOPTION');
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
