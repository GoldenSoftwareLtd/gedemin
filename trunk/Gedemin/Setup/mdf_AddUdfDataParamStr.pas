unit mdf_AddUdfDataParamStr;

interface
uses
  IBDatabase, gdModify;

procedure AddUdfDataParamStr(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure AddUdfDataParamStr(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
//  I: Integer;
begin
  Log('Удаление поддержки G_D_GETDATEPARAMSTR');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.ParamCheck := False;
        FIBSQL.SQL.Text := 'DROP EXTERNAL FUNCTION G_D_GETDATEPARAMSTR ';
        try
          FTransaction.StartTransaction;
          FIBSQL.ExecQuery;
          FIBSQL.Close;
          FTransaction.Commit;
        except
          on E: Exception do
          begin
           //Log('Ошибка: ' + E.Message);
            FTransaction.Rollback;
          end;
        end;
        FIBSQL.Close;
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

  Log('Удаление поддержки G_D_DATEPARAMSTR');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.ParamCheck := False;
        FIBSQL.SQL.Text := 'DROP EXTERNAL FUNCTION G_D_DATEPARAMSTR ';
        try
          FTransaction.StartTransaction;
          FIBSQL.ExecQuery;
          FIBSQL.Close;
          FTransaction.Commit;
        except
          on E: Exception do
          begin
           //Log('Ошибка: ' + E.Message);
            FTransaction.Rollback;
          end;
        end;
        FIBSQL.Close;
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
 
