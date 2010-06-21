unit mdf_Add_Account_triggers;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit, Sysutils, IBSQL;

procedure Add_Account_Triggers(IBDB: TIBDatabase; Log: TModifyLog);

implementation

const
  ExceptionCount = 3;
  Exceptions: array[0..ExceptionCount - 1] of TmdfException = (
    (ExceptionName: 'AC_E_MUST_INSERT_ACCOUNT_IN_F';
    Message: 'You must insert account in folder!'),
    (ExceptionName: 'AC_E_MUST_INSERT_FOLDER_IN_F';
    Message: 'You must insert folder in folder!'),
   (ExceptionName: 'AC_E_CANT_INSERT_CARD_IN_OTHER';
    Message: 'You can not insert card of account in other objects!')
    );
  TriggerCount = 2;
  Triggers: array[0..TriggerCount - 1] of TmdfTrigger = (
    (TriggerName: 'AC_ACCOUNT_BI11'; Description:
      'FOR AC_ACCOUNT'#13#10 +
      'ACTIVE BEFORE INSERT POSITION 0'#13#10 +
      'AS'#13#10 +
      'DECLARE VARIABLE P VARCHAR(1);'#13#10 +
      'begin'#13#10 +
      '  p = ''Z'';'#13#10 +
      '  if (not new.parent is null) then'#13#10 +
      '  begin'#13#10 +
      '    SELECT'#13#10 +
      '      a.accounttype'#13#10 +
      '    FROM'#13#10 +
      '      ac_account a'#13#10 +
      '    WHERE'#13#10 +
      '      a.id = NEW.parent'#13#10 +
      '    INTO :p;'#13#10 +
      '  end'#13#10 +
      ''#13#10 +
      '  if (new.accounttype = ''A'') then'#13#10 +
      '  begin'#13#10 +
      '    if (p <> ''F'') then'#13#10 +
      '      EXCEPTION ac_e_must_insert_account_in_f;'#13#10 +
      '  end else'#13#10 +
      '  if (NEW.accounttype = ''F'') then'#13#10 +
      '  begin'#13#10 +
      '    if ((p <> ''C'') and (p <> ''F'')) then'#13#10 +
      '      EXCEPTION ac_e_must_insert_folder_in_f;'#13#10 +
      '  end else'#13#10 +
      '  if (new.accounttype = ''C'') then'#13#10 +
      '  begin'#13#10 +
      '    if (p <> ''Z'') then'#13#10 +
      '      EXCEPTION ac_e_cant_insert_card_in_other;'#13#10 +
      '  end'#13#10 +
      'end'),
    (TriggerName: 'AC_ACCOUNT_BU0'; Description:
      'FOR AC_ACCOUNT'#13#10 +
      'ACTIVE BEFORE UPDATE POSITION 0'#13#10 +
      'AS'#13#10 +
      'DECLARE VARIABLE P VARCHAR(1);'#13#10 +
      'begin'#13#10 +
      '  p = ''Z'';'#13#10 +
      '  if (not new.parent is null) then'#13#10 +
      '  begin'#13#10 +
      '    SELECT'#13#10 +
      '      a.accounttype'#13#10 +
      '    FROM'#13#10 +
      '      ac_account a'#13#10 +
      '    WHERE'#13#10 +
      '      a.id = NEW.parent'#13#10 +
      '    INTO :p;'#13#10 +
      '  end'#13#10 +
      ''#13#10 +
      '  if (new.accounttype = ''A'') then'#13#10 +
      '  begin'#13#10 +
      '    if (p <> ''F'') then'#13#10 +
      '      EXCEPTION ac_e_must_insert_account_in_f;'#13#10 +
      '  end else'#13#10 +
      '  if (NEW.accounttype = ''F'') then'#13#10 +
      '  begin'#13#10 +
      '    if ((p <> ''C'') and (p <> ''F'')) then'#13#10 +
      '      EXCEPTION ac_e_must_insert_folder_in_f;'#13#10 +
      '  end else'#13#10 +
      '  if (new.accounttype = ''C'') then'#13#10 +
      '  begin'#13#10 +
      '    if (p <> ''Z'') then'#13#10 +
      '      EXCEPTION ac_e_cant_insert_card_in_other;'#13#10 +
      '  end'#13#10 +
      'end')
  );

procedure Add_Account_Triggers(IBDB: TIBDatabase; Log: TModifyLog);
var
  K: Integer;
  SQL, q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Tr;
      Tr.StartTransaction;
      try
        SQL.SQL.Text := 'SELECT'#13#10 +
          '(SELECT First(1) a3.id from ac_account a3 WHERE a3.lb <= a.lb AND a3.rb >= a.rb AND'#13#10 +
          '    a3.accounttype = ''F'' ORDER BY a3.lb) as parent,'#13#10 +
          '  a1.id'#13#10 +
          'FROM'#13#10 +
          '  ac_account a'#13#10 +
          '  JOIN ac_account a1 ON a1.parent = a.id and a1.accounttype = ''A'''#13#10 +
          'WHERE'#13#10 +
          '  a.accounttype = ''A''';
        SQL.ExecQuery;
        q := TIBSQl.Create(nil);
        try
          q.Transaction := Tr;
          q.SQL.Text := 'UPDATE ac_account SET parent =:parent WHERE id = :id';
          while not SQL.Eof do
          begin
            q.ParamByName('parent').AsInteger := SQl.FieldByName('parent').AsInteger;
            q.ParamByName('id').AsInteger := SQl.FieldByName('id').AsInteger;
            q.ExecQuery;
            q.Close;
            SQL.Next;
          end;
        finally
          q.free;
        end;

        Tr.Commit;

        for K := 0 to ExceptionCount - 1 do
        begin
          if not ExceptionExists(Exceptions[K], IBDB) then
          begin
            Log(Format('Добавление исключения %s ', [Exceptions[K].ExceptionName]));
            try
              CreateException(Exceptions[K], IBDB);
            except
              on E: Exception do
                Log(Format('Ошибка %s', [E.Message]));
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
                Log(Format('Ошибка %s', [E.Message]));
            end;
          end;
        end;
      except
        Tr.Rollback;
      end;
    finally
      SQL.Free;
    end;
  finally
    Tr.Free;
  end;
end;

end.
