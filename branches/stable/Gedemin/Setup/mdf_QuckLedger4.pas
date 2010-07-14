unit mdf_QuckLedger4;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit, Windows, Controls, Sysutils;

procedure QuickLedger4(IBDB: TIBDatabase; Log: TModifyLog);

implementation

const
  TriggerCount = 1;
  Triggers: array[0..TriggerCount - 1] of TmdfTrigger = (
    (TriggerName: 'AC_BU_ENTRY_ISSIMPLE'; Description:
      'FOR AC_ENTRY'#13#10 +
      'ACTIVE BEFORE UPDATE POSITION 0'#13#10 +
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
      '    update'#13#10 +
      '      ac_entry e'#13#10 +
      '    set'#13#10 +
      '      e.issimple = 0'#13#10 +
      '    where'#13#10 +
      '      e.recordkey = new.recordkey'#13#10 +
      '      and'#13#10 +
      '      e.accountpart != new.accountpart;'#13#10 +
      '  end'#13#10 +
      'end')
  );

procedure QuickLedger4(IBDB: TIBDatabase; Log: TModifyLog);
var
  I: Integer;
begin
  for I := TriggerCount - 1 downto 0 do
  begin
    if not TriggerExist(Triggers[I], IBDB) then
    begin
      Log(Format('Добавление триггера %s ', [Triggers[i].TriggerName]));
      try
        CreateTrigger(Triggers[i], IBDB);
      except
        on E: Exception do
          Log(Format('Ошибка: %s', [E.Message]));
      end;
    end;
  end;
end;

end.
