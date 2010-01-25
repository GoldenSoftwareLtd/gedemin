
unit mdf_UpdateContact;

interface

uses
  IBDatabase, gdModify;

procedure UpdateContact(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IB, IBSQL, SysUtils;

procedure UpdateContact(IBDB: TIBDatabase; Log: TModifyLog);
var
  Tr: TIBTransaction;
  q: TIBSQL;
  K: Integer;
begin
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    q := TIBSQL.Create(nil);
    try
      q.Transaction := Tr;

      q.SQL.Text := 'SELECT id FROM gd_contact WHERE contacttype=0';
      q.ExecQuery;

      if q.EOF then
      begin
        Log('В базе данных нет папок для контактов!');
        Exit;
      end;

      K := q.Fields[0].AsInteger;
      q.Close;

      q.SQL.Text := 'UPDATE gd_contact SET parent = ' + IntToStr(K) +
        ' WHERE parent IS NULL AND contacttype > 1 ';
      q.ExecQuery;

      if q.RowsAffected > 0 then
      begin
        Log(Format('Обновлен Parent для контактов в количестве: %d', [q.RowsAffected]));
      end;

      Tr.Commit;
      Tr.StartTransaction;

      q.Close;
      q.SQL.Text :=
        'ALTER TABLE gd_contact ADD CONSTRAINT gd_chk_contact_parent ' +
        'CHECK((contacttype IN (0, 1)) OR (NOT (parent IS NULL))) ';
      try
        q.ExecQuery;
      except
      end;

      Tr.Commit;
      Tr.StartTransaction;

      q.Close;
      q.SQL.Text :=
        'update gd_contact set contacttype=3 where id in ( ' +
        'select id from gd_contact where ' +
        'contacttype = 2 and id in (select contactkey from gd_company)) ';
      try
        q.ExecQuery;
      except
      end;

      q.Close;
      Tr.Commit;

    finally
      q.Free;
    end;
  finally
    Tr.Free;
  end;
end;

end.
 