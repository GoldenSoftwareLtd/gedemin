unit mdf_AddRestrFieldToInv_BalanceOption;

interface
 
uses
  IBDatabase, gdModify;

procedure AddRestrFieldToInv_BalanceOption(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, mdf_MetaData_unit;

procedure AddRestrFieldToInv_BalanceOption(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTr: TIBTransaction;
  q: TIBSQL;
begin
  FTr := TIBTransaction.Create(nil);
  try
    FTr.DefaultDatabase := IBDB;
    FTr.StartTransaction;

    q := TIBSQL.Create(nil);
    try
      q.Transaction := FTr;
      try
        AddField2('INV_BALANCEOPTION', 'RESTRICTREMAINSBY', 'DTEXT32', FTr);

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (262, ''0000.0001.0000.0293'', ''31.03.2017'', ''Added restrict remains field to INV_BALANCEOPTION'') ' +
          '  MATCHING (id)';
        q.ExecQuery;

        FTr.Commit;
      except
        on E: Exception do
        begin
      	  Log('Произошла ошибка: ' + E.Message);
          if FTr.InTransaction then
            FTr.Rollback;
          raise;
        end;
      end;
    finally
      q.Free;
    end;
  finally
    FTr.Free;
  end;
end;

end.