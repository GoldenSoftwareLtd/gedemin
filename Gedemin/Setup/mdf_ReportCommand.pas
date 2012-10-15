unit mdf_ReportCommand;

interface

uses
  IBDatabase, gdModify, IBSQL, SysUtils;

procedure DeleteSF(IBDB: TIBDatabase; Log: TModifyLog);

implementation

procedure DeleteSF(IBDB: TIBDatabase; Log: TModifyLog);
var
  SQL, q, SQL2: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  SQL := TIBSQL.Create(nil);
  SQL2 := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT f.id as funid, r2.xid || ''_'' || r2.dbid as funruid, r.xid || ''_'' || r.dbid as rruid ' +
      'FROM rp_reportlist rl ' +
      '  JOIN gd_ruid r on r.id = rl.id ' +
      '  JOIN gd_function f on f.name = ''ReportScriptFunction'' || r.xid || ''_'' || r.dbid ' +
      '  JOIN gd_ruid r2 on r2.id = f.id ';
    SQL.Transaction := Tr;
    SQL.SQL.Text := 'UPDATE gd_command SET cmd = :RR, cmdtype = 2  WHERE cmd = :FR';
    SQL2.Transaction := Tr;
    SQL2.SQL.Text := 'DELETE FROM gd_function WHERE id = :ID';
    try
      q.ExecQuery;

      while not q.Eof do
      begin
        SQL.ParamByName('RR').AsString := q.FieldByName('rruid').AsString;
        SQL.ParamByName('FR').AsString := q.FieldByName('funruid').AsString;
        SQL.ExecQuery;

        SQL2.ParamByName('ID').AsInteger := q.FieldByName('funid').AsInteger;
        SQL2.ExecQuery;

        q.Next;
      end;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (158, ''0000.0001.0000.0189'', ''26.09.2012'', ''Change way of reports being called from Explorer tree.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    SQL.Free;
    SQL2.Free;
    q.Free;
    Tr.Free;
  end;
end;

end.
