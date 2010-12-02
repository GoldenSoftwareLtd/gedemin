unit mfd_UpdateLocalName;

interface

uses
  IBDatabase, gdModify;

procedure UpdateLocalName(IBDB: TIBDatabase; Log: TModifyLog);
implementation
uses
  IBSQL, SysUtils;

procedure UpdateLocalName(IBDB: TIBDatabase; Log: TModifyLog);
var
  SQL, uSQL: TIBSQL;
  FTransaction: TIBTransaction;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := FTransaction;
      SQL.SQL.Text := 'SELECT g.id, e.eventname FROM gd_function g, evt_objectevent e ' +
        'WHERE g.id = e.functionkey and g.module = ''EVENTS''';
      FTransaction.StartTransaction;
      try
        SQL.ExecQuery;
        uSQL := TIBSQL.Create(nil);
        try
          uSQL.Transaction := FTransaction;
          uSQl.SQL.Text := 'UPDATE gd_function SET event = :event WHERE id = :id';
          while not SQL.Eof do
          begin
            uSQL.Params[0].AsString := SQL.Fields[1].AsString;
            uSQL.Params[1].AsInteger := SQL.Fields[0].AsInteger;
            uSQL.ExecQuery;
            uSQL.Close;
            SQL.Next;
          end;
          uSQL.SQL.Text := 'DELETE FROM gd_function WHERE module = ''EVENTS'' and event is null';
          uSQL.ExecQuery;
          FTransaction.Commit;
          Log('Произведено обновление поля event в таблице gd_function');
        finally
          USQL.Free;
        end;
      except
        FTransaction.Rollback;
        Log('Ошибка обновления поля event в таблице gd_function');
      end;
    finally
      SQl.Free;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
