unit mdf_AddGoodCriticalDays;

interface

uses
  IBDatabase, gdModify;

procedure AddGoodCriticalDays(IBDB: TIBDatabase; Log: TModifyLog);


implementation

uses
  IBSQL, SysUtils, gd_KeyAssoc;

const
  AddText =
    'ALTER TABLE GD_GOOD ' +
    '  ADD CRITICALDAYS DINTEGER ' +
    '  DEFAULT 0 ' +
    '  CHECK (CRITICALDAYS > -1)';


procedure AddGoodCriticalDays(IBDB: TIBDatabase; Log: TModifyLog);
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
        FIBSQL.SQL.Text := AddText;
        try
          FIBSQL.ExecQuery;
          Log('Товар: Добавлено поле "Количество критических дней".');
          FIBSQL.Close;
          FTransaction.Commit;
          FTransaction.StartTransaction;
          FIBSQL.SQL.Text :=
            'UPDATE gd_good SET CRITICALDAYS = 0';
          FIBSQL.ExecQuery;
          FTransaction.Commit;
          FTransaction.StartTransaction;
        except
        end;
      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        FTransaction.Rollback;
//        Log(E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
