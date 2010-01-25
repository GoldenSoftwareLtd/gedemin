unit mdf_QuckLedger2;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit, Sysutils;

procedure QuickLedger2(IBDB: TIBDatabase; Log: TModifyLog);

implementation

const
  TriggerCount = 1;
  Triggers: array[0..TriggerCount - 1] of TmdfTrigger = (
    (TriggerName: 'AC_BI_ENTRY_ISSIMPLE'; Description:
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
      'end')
  );


  SET_ISSIMPLE_ENTRY: TmdfStoredProcedure = (ProcedureName: 'SET_ISSIMPLE_ENTRY';
  Description:'');

procedure QuickLedger2(IBDB: TIBDatabase; Log: TModifyLog);
var
  K: Integer;
begin
  for K := 0 to TriggerCount - 1 do
  begin
    if not TriggerExist(Triggers[K], IBDB) then
    begin
      Log(Format('Добавление триггера %s ', [Triggers[K].TriggerName]));
      try
        CreateTrigger(Triggers[K], IBDB);
      except
        on E: Exception do
          Log(Format('Ошибка %s', [E.Message]));
      end;
    end else
    begin
      Log(Format('Изменение триггера %s ', [Triggers[K].TriggerName]));
      try
        AlterTrigger(Triggers[K], IBDB);
      except
        on E: Exception do
          Log(Format('Ошибка %s', [E.Message]));
      end;
    end;
  end;
  {$IFNDEF BERIOZA}
  Log('Заполнение поля ISSIMPLE');
  try
    ExecuteProcedure(SET_ISSIMPLE_ENTRY, IBDB);
  except
    on E: Exception do
      Log(Format('Ошибка %s', [E.Message]));
  end;
 {$ENDIF}
end;

end.
