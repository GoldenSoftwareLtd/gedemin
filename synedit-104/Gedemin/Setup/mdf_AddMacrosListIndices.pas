
unit mdf_AddMacrosListIndices;

interface

uses
  IBDatabase, gdModify;

procedure AddMacrosListIndices(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IB, IBSQL, SysUtils;

procedure AddMacrosListIndices(IBDB: TIBDatabase; Log: TModifyLog);
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  try
    Tr := TIBTransaction.Create(nil);
    try
      Tr.DefaultDatabase := IBDB;

      q := TIBSQL.Create(nil);
      try
        q.Transaction := Tr;

        Tr.StartTransaction;
        try
          q.SQL.Text := 'SELECT * FROM rdb$indices WHERE rdb$relation_name = ' +
            '''EVT_MACROSLIST'' AND rdb$index_name = ''EVT_MACROSLIST_IDX''';
          q.ExecQuery;
          if q.Eof then
          begin
            q.Close;
            Log('Добавление индекса EVT_MACROSLIST_IDX');
            q.SQL.Text := 'CREATE UNIQUE INDEX EVT_MACROSLIST_IDX ON EVT_MACROSLIST (NAME, MACROSGROUPKEY)';
            q.ExecQuery;
            Tr.Commit;
            Log('Индекс EVT_MACROSLIST_IDX добавлен');
          end;
        except
          on E: Exception do
          begin
            Tr.Rollback;
            Log('Ошибка при добавлении EVT_MACROSLIST_IDX: ' + E.Message);
          end;
        end;

        q.Close;

        if not Tr.InTransaction then
          Tr.StartTransaction;
        try
          q.SQL.Text := 'SELECT * FROM rdb$indices WHERE rdb$relation_name = ' +
            '''EVT_MACROSLIST'' AND rdb$index_name = ''EVT_X_MACROSLIST_FUNCTIONKEY''';
          q.ExecQuery;
          if q.Eof then
          begin
            q.Close;
            Log('Добавление индекса EVT_X_MACROSLIST_FUNCTIONKEY');
            q.SQL.Text := 'CREATE UNIQUE INDEX EVT_X_MACROSLIST_FUNCTIONKEY ON EVT_MACROSLIST (FUNCTIONKEY)';
            q.ExecQuery;
            Tr.Commit;
            Log('Индекс EVT_X_MACROSLIST_FUNCTIONKEY добавлен');
          end;
        except
          on E: Exception do
          begin
            Tr.Rollback;
            Log('Ошибка при добавлении EVT_X_MACROSLIST_FUNCTIONKEY: ' + E.Message);
          end;
        end;
      finally
        q.Free;
      end;
    finally
      Tr.Free;
    end;
  except
  end;
end;

end.
