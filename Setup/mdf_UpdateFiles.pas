
{Добавляет в gd_files поле description}
unit mdf_UpdateFiles;

interface

uses
  IBDatabase, gdModify;

procedure UpdateFiles(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IB, IBSQL, SysUtils;

procedure UpdateFiles(IBDB: TIBDatabase; Log: TModifyLog);
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;
    try
      q.Transaction := Tr;

      q.SQL.Text := 'SELECT * FROM rdb$relation_fields WHERE rdb$relation_name = ''GD_FILE'' ' +
        ' AND rdb$field_name = ''DESCRIPTION''';
      q.ExecQuery;

      if q.EOF then
      begin
        q.Close;
        q.SQL.Text := 'ALTER TABLE gd_file ADD description dtext80 ';
        Log('GD_FILE: Добавление поля DESCRIPTION');
        q.ExecQuery;
        q.Close;
        Tr.Commit;
        Tr.StartTransaction;
        q.SQL.Text := 'UPDATE gd_file SET description = name';
        Log('GD_FILE: Обновление поля DESCRIPTION');
        q.ExecQuery;
      end;
      Tr.Commit;

    except
      if Tr.InTransaction then
        Tr.Rollback;
      raise;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

end.
