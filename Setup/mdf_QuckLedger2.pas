unit mdf_QuckLedger2;

interface

uses
  IBDatabase, gdModify;

procedure QuickLedger2(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, mdf_MetaData_unit, mdf_ModifyBlockTriggers4;

procedure QuickLedger2(IBDB: TIBDatabase; Log: TModifyLog);
var
  ibtr: TIBTransaction;
  q: TIBSQL;
begin
  ibtr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    ibtr.DefaultDatabase := IBDB;
    ibtr.StartTransaction;
    _ModifyBlockTriggers(ibtr);
    ibtr.Commit;

    ibtr.StartTransaction;
    q.Transaction := ibtr;

    q.SQL.Text :=
      'CREATE OR ALTER TRIGGER AC_BI_ENTRY_ISSIMPLE FOR AC_ENTRY '#13#10 +
      'ACTIVE BEFORE INSERT POSITION 0'#13#10 +
      'AS'#13#10 +
      'begin'#13#10 +
      '  if (exists(select'#13#10 +
      '    e.id'#13#10 +
      '  from'#13#10 +
      '    ac_entry e'#13#10 +
      '  where'#13#10 +
      '    e.recordkey = new.recordkey'#13#10 +
      '    and'#13#10 +
      '    e.accountpart = new.accountpart'#13#10 +
      '    and'#13#10 +
      '    e.id != new.id))'#13#10 +
      '  then'#13#10 +
      '  begin'#13#10 +
      '    new.issimple = 0;'#13#10 +
      '    update'#13#10 +
      '      ac_entry e'#13#10 +
      '    set'#13#10 +
      '      e.issimple = 1'#13#10 +
      '    where'#13#10 +
      '      e.recordkey = new.recordkey'#13#10 +
      '      and'#13#10 +
      '      e.accountpart != new.accountpart;'#13#10 +
      ''#13#10 +
      '    update'#13#10 +
      '      ac_entry e'#13#10 +
      '    set'#13#10 +
      '      e.issimple = 0'#13#10 +
      '    where'#13#10 +
      '      e.recordkey = new.recordkey'#13#10 +
      '      and'#13#10 +
      '      e.accountpart = new.accountpart;'#13#10 +
      '  end'#13#10 +
      '  else'#13#10 +
      '  begin'#13#10 +
      '    new.issimple = 1;'#13#10 +
      '  end'#13#10 +
      'end';
    q.ExecQuery;
    ibtr.Commit;

    {$IFNDEF BERIOZA}
    {ibtr.StartTransaction;
    q.SQL.Text := 'EXECUTE PROCEDURE SET_ISSIMPLE_ENTRY';
    q.ExecQuery;
    ibtr.Commit;}
   {$ENDIF}
  finally
    q.Free;
    ibtr.Free;
  end;
end;

end.
