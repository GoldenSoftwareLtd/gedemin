unit mdf_AddGSFFieldsToSettings;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit;

procedure AddGSFFields(IBDB: TIBDatabase; Log: TModifyLog);

implementation


uses
  SysUtils;

procedure AddGSFFields(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FTransaction.StartTransaction;

      AddField2('AT_SETTING', 'ENDING', 'DBOOLEAN', FTransaction);
      AddField2('AT_SETTING', 'MINEXEVERSION', 'DTEXT20', FTransaction);
      AddField2('AT_SETTING', 'MINDBVERSION', 'DTEXT20', FTransaction);

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
