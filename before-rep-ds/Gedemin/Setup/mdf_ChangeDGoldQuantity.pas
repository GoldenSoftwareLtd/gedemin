unit mdf_ChangeDGoldQuantity;

interface
uses
  IBDatabase, gdModify;

  procedure ChangeDGoldQuantity(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL, SysUtils;

procedure ChangeDGoldQuantity(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  Log('Изменение домена DGOLDQUANTITY');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.ParamCheck := False;
        FIBSQL.SQL.Text := 'ALTER DOMAIN DGOLDQUANTITY TYPE NUMERIC(15, 8)';
        try
          FTransaction.StartTransaction;
          FIBSQL.ExecQuery;
          FIBSQL.Close;
          FTransaction.Commit;
        except
          on E: Exception do
          begin
           //Log(E.Message);
            FTransaction.Rollback;
          end;
        end;
        Log('Завершено изменение домена');
        FIBSQL.Close;
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
