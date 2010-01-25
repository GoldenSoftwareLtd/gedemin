unit mdf_AddIsCheckNumberField;

interface

uses
  IBDatabase, gdModify;

procedure AddIsCheckNumberField(IBDB: TIBDatabase; Log: TModifyLog);


implementation

uses
  IBSQL, SysUtils;

procedure AddIsCheckNumberField(IBDB: TIBDatabase; Log: TModifyLog);
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
        FIBSQL.ParamCheck := False;

        FIBSQL.SQL.Text := 'SELECT ischecknumber FROM gd_documenttype';
        try
          FIBSQL.Prepare
        except
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'ALTER TABLE gd_documenttype ADD ischecknumber dboolean DEFAULT 0 ';

          FIBSQL.ExecQuery;
          Log('Добавление поля ischecknumber в gd_documenttype прошло успешно');
        end;
      finally
        FIBSQL.Free;
      end;
      if FTransaction.InTransaction then
        FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка при добавлении поля ischecknumber в gd_documenttype.' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;


end.
