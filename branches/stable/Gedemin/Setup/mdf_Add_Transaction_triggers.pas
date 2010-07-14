unit mdf_Add_Transaction_triggers;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit, Sysutils;

procedure Add_Transaction_triggers(IBDB: TIBDatabase; Log: TModifyLog);

implementation

const
  ExceptionCount = 2;
  Exceptions: array[0..ExceptionCount - 1] of TmdfException = (
    (ExceptionName: 'AC_E_AUTOTRCANTCONTAINTR';
    Message: 'Can`t move transaction into autotransaction'),
    (ExceptionName: 'AC_E_TRCANTCONTAINAUTOTR';
    Message: 'Can`t move autotransaction into transaction')
    );
  TriggerCount = 2;
  Triggers: array[0..TriggerCount - 1] of TmdfTrigger = (
    (TriggerName: 'AC_TRANSACTION_BU0'; Description:
      'FOR AC_TRANSACTION'#13#10 +
      'ACTIVE BEFORE UPDATE POSITION 0'#13#10 +
      'AS'#13#10 +
      '  DECLARE a SMALLINT;'#13#10 +
      'begin'#13#10 +
      '  if (not new.parent is null) then'#13#10 +
      '  begin'#13#10 +
      '    select'#13#10 +
      '      autotransaction'#13#10 +
      '    from'#13#10 +
      '      ac_transaction'#13#10 +
      '    where'#13#10 +
      '      id = new.parent'#13#10 +
      '    into :a;'#13#10 +
      ''#13#10 +
      '    if (a is null) then a = 0;'#13#10 +
      '    if (new.autotransaction is null) then new.autotransaction = 0;'#13#10 +
      '    if (new.autotransaction <> a) then'#13#10 +
      '    begin'#13#10 +
      '      if (a = 1) then'#13#10 +
      '      begin'#13#10 +
      '        EXCEPTION ac_e_autotrcantcontaintr;'#13#10 +
      '      end else'#13#10 +
      '      begin'#13#10 +
      '        EXCEPTION ac_e_trcantcontainautotr;'#13#10 +
      '      end'#13#10 +
      '    end'#13#10 +
      '  end'#13#10 +
      'end'),
    (TriggerName: 'AC_TRANSACTION_BI0'; Description:
        'FOR AC_TRANSACTION'#13#10 +
        'ACTIVE BEFORE INSERT POSITION 0'#13#10 +
        'AS'#13#10 +
        '   DECLARE a SMALLINT;'#13#10 +
        'begin'#13#10 +
        '  if (not new.parent is null) then'#13#10 +
        '  begin'#13#10 +
        '    select'#13#10 +
        '      autotransaction'#13#10 +
        '    from'#13#10 +
        '      ac_transaction'#13#10 +
        '    where'#13#10 +
        '      id = new.parent'#13#10 +
        '    into :a;'#13#10 +
        '    if (a is null) then a = 0;'#13#10 +
        '    new.autotransaction = a;'#13#10 +
        '  end'#13#10 +
        'end')
  );

procedure Add_Transaction_triggers(IBDB: TIBDatabase; Log: TModifyLog);
var
  K: Integer;
begin
  for K := 0 to ExceptionCount - 1 do
  begin
    if not ExceptionExists(Exceptions[K], IBDB) then
    begin
      Log(Format('Добавление исключения %s ', [Exceptions[K].ExceptionName]));
      try
        CreateException(Exceptions[K], IBDB);
      except
        on E: Exception do
          Log(Format('Ошибка: %s', [E.Message]));
      end;
    end;
  end;
  for K := 0 to TriggerCount - 1 do
  begin
    if not TriggerExist(Triggers[K], IBDB) then
    begin
      Log(Format('Добавление триггера %s ', [Triggers[K].TriggerName]));
      try
        CreateTrigger(Triggers[K], IBDB);
      except
        on E: Exception do
          Log(Format('Ошибка: %s', [E.Message]));
      end;
    end;
  end;
end;

end.
