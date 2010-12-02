
unit gsStorage_Convert;

interface

uses
  IBDatabase;

procedure ConvertStorageData(DB: TIBDatabase);

implementation

uses
  gsStorage, IBSQL;

procedure ConvertStorageData(DB: TIBDatabase);
var
  qID, qSrc: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  qID := TIBSQL.Create(nil);
  qSrc := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := DB;
    Tr.StartTransaction;

    qID.Transaction := Tr;
    q.SQL.Text := 'SELECT GEN_ID(gd_g_unique, 1) FROM rdb$database';

    Tr.Commit;
  finally
    qID.Free;
    Tr.Free;
  end;
end;

end.