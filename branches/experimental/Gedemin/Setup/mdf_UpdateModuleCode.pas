
unit mdf_UpdateModuleCode;

interface

uses
  IBDatabase, gdModify;

procedure UpdateModuleCode(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IB, IBSQL, SysUtils;

procedure UpdateModuleCode(IBDB: TIBDatabase; Log: TModifyLog);
var
  Tr: TIBTransaction;
  q: TIBSQL;
//  K: Integer;
begin
  try
    Tr := TIBTransaction.Create(nil);
    try
      Tr.DefaultDatabase := IBDB;
      Tr.StartTransaction;

      q := TIBSQL.Create(nil);
      try
        q.Transaction := Tr;

        q.SQL.Text := 'UPDATE gd_function set modulecode = 1010001 WHERE id in ( ' +
          ' select f.id from gd_function f, evt_object o where o.classname <> ''  and '+
          ' o.objectname = '' and f.modulecode = o.id  and (f.module = ''REPORTMAIN'' or ' +
          ' f.module = ''REPORTPARAM'' or f.module = ''REPORTEVENT'') AND NOT ' +
          ' EXISTS (SELECT * FROM gd_function f1 WHERE modulecode = 1010001 and f.name = f1.name))';
        q.ExecQuery;

        Tr.Commit;
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
