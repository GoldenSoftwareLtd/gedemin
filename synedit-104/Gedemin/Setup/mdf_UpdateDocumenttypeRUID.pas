{
      ibsql.SQL.Text := 'UPDATE gd_documenttype SET ruid = CAST(id as VARCHAR(20))||''_17'' WHERE id < 147000000 and ruid IS NULL';
      ibsql.ExecQuery;
}

unit mdf_UpdateDocumenttypeRUID;

interface

uses
  IBDatabase, gdModify;

procedure ChangeDocumentTypeRUID(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure ChangeDocumentTypeRUID(IBDB: TIBDatabase; Log: TModifyLog);
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
        FIBSQL.SQL.Text := 'UPDATE gd_documenttype SET ruid = CAST(id as VARCHAR(20))||''_17'' WHERE id < 147000000 and ruid IS NULL';
        FIBSQL.ExecQuery;
        Log('GD_COMMAND: Обновление ruid для стандартных документов');

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
