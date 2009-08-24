unit mdf_AddFieldFUNCSTOR;

interface

uses
  IBDatabase, gdModify;

procedure AddFieldFUNCSTOR(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

const
  cAddField: String =
    'ALTER TABLE ac_script ADD funcstor DBLOBTEXT80';
  cPresField: String =
    'SELECT * FROM rdb$relation_fields rf'#13#10 +
    'WHERE rf.rdb$field_name = ''FUNCSTOR'' and rf.rdb$relation_name = ''AC_SCRIPT''';

procedure AddFieldFUNCSTOR(IBDB: TIBDatabase; Log: TModifyLog);
var
  IBSQL: TIBSQL;
  IBTransaction: TIBTransaction;
begin
  IBTransaction := TIBTransaction.Create(nil);
  try
    IBTransaction.DefaultDatabase := IBDB;
    IBSQL := TIBSQL.Create(nil);
    try
      IBSQL.Transaction := IBTransaction;
      IBTransaction.StartTransaction;
      try
        IBSQL.SQL.Text := cPresField;
        IBSQL.ExecQuery;
        if not IBSQL.Eof then
          Exit;

        IBSQL.Close;
        Log('Добавляется поддержка конструктора функций проводок.');
        IBSQL.SQL.Text := cAddField;
        IBSQL.ExecQuery;
      finally
        IBTransaction.Commit;
      end;
    finally
      IBSQL.Free;
    end;
  finally
    IBTransaction.Free;
  end;
end;

end.
