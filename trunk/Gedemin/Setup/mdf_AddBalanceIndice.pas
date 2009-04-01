unit mdf_AddBalanceIndice;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit;

procedure AddBalanceIndice(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

const
  Index: TmdfIndex = (RelationName:'INV_BALANCE'; IndexName:'INV_X_BALANCE_CB';
    Columns: 'CONTACTKEY, BALANCE'; Unique: False; Sort: stAsc);


procedure AddBalanceIndice(IBDB: TIBDatabase; Log: TModifyLog);
begin

  Log('Добавление индекса в INV_BALANCE');
  if not IndexExist(Index, IBDB) then
  begin
    Log(Format('Добавление индекса %s', [Index.IndexName]));
    try
      AddIndex(Index, IBDB);
      Log('Добавление прошло успешно');
    except
      on E: Exception do
        Log(Format('Ошибка при добавлении индекса %s', [E.Message]));
    end;
  end;


end;

end.
