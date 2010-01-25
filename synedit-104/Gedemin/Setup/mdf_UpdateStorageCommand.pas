unit mdf_UpdateStorageCommand;

interface

uses
  IBDatabase, gdModify;

procedure ChangeStorageCommand(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure ChangeStorageCommand(IBDB: TIBDatabase; Log: TModifyLog);
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
        FIBSQL.SQL.Text := 'UPDATE gd_command SET classname = ''Tst_frmMain'' WHERE id = 740300';
        FIBSQL.ExecQuery;
        Log('GD_COMMAND: Обновление комманды просмотра хранилища.');

      finally
        FIBSQL.Free;
      end;
      if FTransaction.InTransaction then
        FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('GD_COMMAND: Произошла ошибка при изменении комманды просмотра хранилища.' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
