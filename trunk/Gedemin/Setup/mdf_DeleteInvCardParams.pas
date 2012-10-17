unit mdf_DeleteInvCardParams;

interface

uses
  IBDatabase, gdModify, IBSQL, SysUtils;

procedure DeleteCardParamsItem(IBDB: TIBDatabase; Log: TModifyLog);

implementation

procedure DeleteCardParamsItem(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text :=
      'DELETE FROM gd_storage_data sd WHERE sd.id IN( ' +
      '  SELECT g2.id ' +
      '  FROM gd_storage_data g ' +
      '    JOIN gd_storage_data g2 on g2.parent = g.id ' +
      '  WHERE g.data_type = ''U'' ' +
      '    AND UPPER(g2.name) = UPPER(''gdv_dlgInvCardParams(Tgdv_dlgInvCardParams)''))';
    try
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (159, ''0000.0001.0000.0190'', ''17.10.2012'', ''Delete InvCardForm params from userstorage.'') ' +
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
    q.Free;
    Tr.Free;
  end;
end;

end.
