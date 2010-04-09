unit mdf_ChangeFilterFullName;

interface

uses
  IBDatabase, gdModify;

procedure ChangeFilterFullName(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure ChangeFilterFullName(IBDB: TIBDatabase; Log: TModifyLog);
const
  ModifyDate = '30.09.2002';
  cFilterPrefix = '1V\';
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        Log('Модификация от ' + ModifyDate + '. Модификация фильтра.');
        FIBSQL.SQL.Text := 'UPDATE flt_componentfilter SET crc = NULL, ' +
         'fullname = NULL WHERE not fullname LIKE ''' + cFilterPrefix + '%''';
        FIBSQL.ExecQuery;
        if FTransaction.InTransaction then
          FTransaction.Commit;
      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        Log(E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
