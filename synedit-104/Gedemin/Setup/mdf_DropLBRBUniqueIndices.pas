unit mdf_DropLBRBUniqueIndices;

interface

uses sysutils, classes, IBSQL, IBDatabase, gdModify;

procedure DropLBRBUniqueIndices(IBDB: TIBDatabase; Log: TModifyLog);

implementation

procedure DropLBRBUniqueIndices(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
  sl: TStringList;
  i: integer;
begin
  Tr:= TIBTransaction.Create(nil);
  Tr.DefaultDatabase:= IBDB;
  Tr.StartTransaction;
  q:= TIBSQL.Create(nil);
  q.Transaction:= Tr;
  sl:= TStringList.Create;
  try
    q.SQL.Text:=
      'SELECT rdb$index_name ' +
      'FROM rdb$indices ' +
      'WHERE rdb$index_name LIKE ''%_X_%_LBRB_U%''';
    try
      q.ExecQuery;
      while not q.Eof do begin
        sl.Add(q.Fields[0].AsString);
        q.Next;
      end;
      IBDB.Connected:= False;
      for i:= 0 to sl.Count - 1 do begin
        IBDB.Connected:= True;
        Tr.StartTransaction;
        Log(Format('Удаление индекса %s', [sl[i]]));
        q.Close;
        q.SQL.Text:= 'DROP INDEX ' + sl[i];
        q.ExecQuery;
        Tr.Commit;
        IBDB.Connected:= False;
      end;
    except
      on E: Exception do begin
        Log(Format('В процессе удаления индексов возникла ошибка:'#13#10'%s', [E.Message]));
        if Tr.InTransaction then
          Tr.Rollback;
      end;
    end;
  finally
    sl.Free;
    q.Free;
    tr.Free;
    IBDB.Connected:= True;
  end;
end;

end.
 