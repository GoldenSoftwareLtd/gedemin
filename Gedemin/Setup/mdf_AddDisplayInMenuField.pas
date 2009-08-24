unit mdf_AddDisplayInMenuField;

interface

uses
  IBDatabase, gdModify;

procedure AddDisplayInMenuField(IBDB: TIBDatabase; Log: TModifyLog);


implementation

uses
  IBSQL, SysUtils, gd_KeyAssoc;

procedure AddDisplayInMenuField(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    FIBSQL := TIBSQL.Create(nil);
    try
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.SQL.Text :=
          ' ALTER TABLE EVT_MACROSLIST ' +
          ' ADD DISPLAYINMENU DBOOLEAN ' +
          ' DEFAULT 1';
        FIBSQL.ExecQuery;
        FIBSQL.Transaction.Commit;
        FIBSQL.Transaction.StartTransaction;
        FIBSQL.SQL.Text :=
          'UPDATE evt_macroslist SET displayinmenu = 1';
        FIBSQL.ExecQuery;
        FIBSQL.Transaction.Commit;

        Log('Макросы: добавлено поле отображения в меню.');
      except
        FTransaction.Rollback;
      end;
      try
        if not FTransaction.Active then
          FTransaction.StartTransaction;

        FIBSQL.SQL.Text :=
          ' ALTER TABLE RP_REPORTLIST ' +
          ' ADD DISPLAYINMENU DBOOLEAN ' +
          ' DEFAULT 1';
        FIBSQL.ExecQuery;
        FIBSQL.Transaction.Commit;
        FIBSQL.Transaction.StartTransaction;
        FIBSQL.SQL.Text :=
          'UPDATE rp_reportlist SET displayinmenu = 1';
        FIBSQL.ExecQuery;
        FIBSQL.Transaction.Commit;

        Log('Отчеты: добавлено поле отображения в меню.');
      except
        FTransaction.Rollback;
      end;
    finally
      FIBSQL.Free;
    end;
  finally
    FTransaction.Free;
  end;

end;


end.
