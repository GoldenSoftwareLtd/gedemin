unit mdf_GetSimpleLedger2;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit, mdf_dlgDefaultCardOfAccount_unit, Forms,
  Windows, Controls;

procedure GetSimpleLedger2(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript, classes;

const
   ProcCount = 1;

   Procs: array[0..ProcCount - 1] of TmdfStoredProcedure = (
     (ProcedureName:'AC_GETSIMPLEENTRY'; Description:
        '('#13#10 +
        '    ENTRYKEY INTEGER,'#13#10 +
        '    ACORRACCOUNTKEY INTEGER)'#13#10 +
        'RETURNS ('#13#10 +
        '    ID INTEGER,'#13#10 +
        '    DEBIT NUMERIC(15,4),'#13#10 +
        '    CREDIT NUMERIC(15,4),'#13#10 +
        '    DEBITCURR NUMERIC(15,4),'#13#10 +
        '    CREDITCURR NUMERIC(15,4))'#13#10 +
        'AS'#13#10 +
        '/*Версия 2*/'#13#10 +
        'BEGIN'#13#10 +
        '  ID = :ENTRYKEY; '#13#10 +
        '  SELECT'#13#10 +
        '    SUM(iif(corr_e.issimple = 0, corr_e.creditncu, e.debitncu)),'#13#10 +
        '    SUM(iif(corr_e.issimple = 0, corr_e.debitncu, e.creditncu)),'#13#10 +
        '    SUM(iif(corr_e.issimple = 0, corr_e.creditcurr, e.debitcurr)),'#13#10 +
        '    SUM(iif(corr_e.issimple = 0, corr_e.debitcurr, e.creditcurr))'#13#10 +
        '  FROM'#13#10 +
        '    ac_entry e'#13#10 +
        '    JOIN ac_entry corr_e on e.recordkey = corr_e.recordkey and'#13#10 +
        '      e.accountpart <> corr_e.accountpart'#13#10 +
        '  WHERE'#13#10 +
        '    e.id = :entrykey AND'#13#10 +
        '    corr_e.accountkey + 0 = :acorraccountkey'#13#10 +
        '  INTO :DEBIT,'#13#10 +
        '       :CREDIT,'#13#10 +
        '       :DEBITCURR,'#13#10 +
        '       :CREDITCURR;'#13#10 +
        '  SUSPEND;'#13#10 +
        'END')
   );
procedure GetSimpleLedger2(IBDB: TIBDatabase; Log: TModifyLog);
var
  I: Integer;
begin
  for I := 0 to ProcCount - 1 do
  begin
    if ProcedureExist(Procs[i], IBDB) then
      AlterProcedure(Procs[i], IBDB)
    else
      CreateProcedure(Procs[i], IBDB)
  end;
end;

end.
