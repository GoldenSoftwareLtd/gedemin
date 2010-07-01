unit mdf_AddQuantityField;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit;

procedure AddQuantityField(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript;

procedure AddQuantityField(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FTransaction.StartTransaction;

      AddField2('AC_OVERTURNBYANAL', 'QUANTITY', 'DTEXT1024', FTransaction);
      AddField2('AC_OVERTURNBYANAL', 'ANALYTICFILTER', 'DTEXT1024', FTransaction);

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        raise;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
