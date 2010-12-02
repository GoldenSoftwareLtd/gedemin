unit mdf_ModifyAnaliticalForeignKey;

interface

uses
  IBDatabase, gdModify;

procedure ModifyAnaliticalForeignKey(IBDB: TIBDatabase; Log: TModifyLog);


implementation

uses
  IBSQL, SysUtils;

const TextAddConstraint =
'alter table AC_ACCOUNT '#13#10 +
'add constraint AC_FK_ACCOUNT_ANLTCF '#13#10 +
'foreign key (ANALYTICALFIELD) '#13#10 +
'references AT_RELATION_FIELDS(ID) '#13#10 +
'on delete SET NULL '#13#10 +
'on update CASCADE ';

const TextDropConstraint =
'alter table AC_ACCOUNT '#13#10 +
'DROP constraint AC_FK_ACCOUNT_ANLTCF ';



procedure ModifyAnaliticalForeignKey(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  Log('Изменение ссылки ANALITICALFIELD');

  FTransaction := TIBTransaction.Create(nil);
  try
    IBDB.Connected := False;
    IBDB.Connected := True;
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.SQL.Text := TextDropConstraint;
        try
          FIBSQL.ExecQuery;
          FTransaction.Commit;
          Log('Удаление ForeignKey ANALITICALFIELD прошло успешно');
        except
          FTransaction.Rollback;
          Log('Ошибка при удалении ForeignKey');
        end;
        FIBSQL.Close;

        IBDB.Connected := False;
        IBDB.Connected := True;

        FTransaction.StartTransaction;
        FIBSQL.SQL.Text  := TextAddConstraint;
        try
          FIBSQL.ExecQuery;
          FTransaction.Commit;
          Log('Добавление ForeignKey ANALITICALFIELD прошло успешно');
        except
          FTransaction.Rollback;
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
