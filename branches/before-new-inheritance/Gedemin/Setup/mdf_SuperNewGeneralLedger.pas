unit mdf_SuperNewGeneralLedger;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit, mdf_dlgDefaultCardOfAccount_unit, Forms,
  Windows, Controls;

procedure SuperNewGeneralLedger(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript, classes;

const
   ProcCount = 1;

   Procs: array[0..ProcCount - 1] of TmdfStoredProcedure = (
     (ProcedureName: 'AC_L_Q'; Description:
        '('#13#10 +
        '    ENTRYKEY INTEGER,'#13#10 +
        '    VALUEKEY INTEGER,'#13#10 +
        '    ACCOUNTKEY INTEGER,'#13#10 +
        '    AACCOUNTPART VARCHAR(1))'#13#10 +
        'RETURNS ('#13#10 +
        '    DEBITQUANTITY NUMERIC(15,4),'#13#10 +
        '    CREDITQUANTITY NUMERIC(15,4))'#13#10 +
        'AS'#13#10 +
        'DECLARE VARIABLE ACCOUNTPART VARCHAR(1);'#13#10 +
        'DECLARE VARIABLE QUANTITY NUMERIC(15,4);'#13#10 +
        'begin'#13#10 +
        '  SELECT'#13#10 +
        '    e.accountpart,'#13#10 +
        '    q.quantity'#13#10 +
        '  FROM'#13#10 +
        '    ac_entry e'#13#10 +
        '    LEFT JOIN ac_entry e1 ON e1.recordkey = e.recordkey AND'#13#10 +
        '      e1.accountpart <> e.accountpart '#13#10 +
        '    LEFT JOIN ac_quantity q ON q.entrykey = iif(e.issimple = 1 and e1.issimple = 1,'#13#10 +
        '      e.id, iif(e.issimple = 0, e.id, e1.id))'#13#10 +
        '  WHERE'#13#10 +
        '    e.id = :entrykey AND'#13#10 +
        '    q.valuekey = :valuekey AND'#13#10 +
        '    e1.accountkey = :accountkey'#13#10 +
        '  INTO'#13#10 +
        '    :accountpart,'#13#10 +
        '    :quantity;'#13#10 +
        '  IF (quantity IS NULL) THEN'#13#10 +
        '    quantity = 0;'#13#10 +
        ''#13#10 +
        '  debitquantity = 0;'#13#10 +
        '  creditquantity = 0;'#13#10 +
        '  IF (accountpart = ''D'') THEN'#13#10 +
        '    debitquantity = :quantity;'#13#10 +
        '  ELSE'#13#10 +
        '    creditquantity = :quantity;'#13#10 +
        ''#13#10 +
        '  suspend;'#13#10 +
        'END')
   );

procedure SuperNewGeneralLedger(IBDB: TIBDatabase; Log: TModifyLog);
var
  I: Integer;
begin
  for I := 0 to ProcCount - 1 do
  begin
    Log(Format('Добавление процедуры %s', [Procs[I].ProcedureName]));
    try
      if ProcedureExist(Procs[i], IBDB) then
        AlterProcedure(Procs[i], IBDB)
      else
        CreateProcedure(Procs[i], IBDB);
    except
      on E: Exception do
        Log('Ошибка:' +  E.Message);
    end;
  end;
end;



end.
