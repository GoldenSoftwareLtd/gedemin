unit mdf_UpdateRemainsCommand;

interface

uses
  IBDatabase, gdModify;

procedure ChangeRemainsCommand(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure ChangeRemainsCommand(IBDB: TIBDatabase; Log: TModifyLog);
//var
//  FTransaction: TIBTransaction;
//  FIBSQL: TIBSQL;
begin
{  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.SQL.Text := 'UPDATE gd_command SET subtype = ''AllRemains'' WHERE classname = ''TgdcInvRemains''';
        FIBSQL.ExecQuery;
        Log('GD_COMMAND: Обновление комманды просомтра остатков.');

      finally
        FIBSQL.Free;
      end;
      if FTransaction.InTransaction then
        FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('GD_COMMAND: Произошла ошибка при изменении комманды просомтра остатков.' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
      end;
    end;
  finally
    FTransaction.Free;
  end;}
end;

end.
