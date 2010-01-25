unit mdf_AddGSFFieldsToSettings;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit;

procedure AddGSFFields(IBDB: TIBDatabase; Log: TModifyLog);

implementation


uses
  SysUtils;

const
  FieldCount = 3;
  Fields: array[0..FieldCount - 1] of TmdfField = (
    (RelationName: 'AT_SETTING'; FieldName: 'ENDING'; Description: 'DBOOLEAN'),
    (RelationName: 'AT_SETTING'; FieldName: 'MINEXEVERSION'; Description: 'DTEXT20'),
    (RelationName: 'AT_SETTING'; FieldName: 'MINDBVERSION'; Description: 'DTEXT20'));

procedure AddGSFFields(IBDB: TIBDatabase; Log: TModifyLog);
var
  i: Integer;
begin  
  for i := 0 to FieldCount - 1 do
  begin
    if not FieldExist(Fields[I], IBDB) then
    begin
      Log(Format('Добавление поля %s в таблицу %s', [Fields[i].FieldName,
        Fields[i].RelationName]));
      try
        AddField(Fields[I], IBDB);
        Log(Format('Добавление поля %s в таблицу %s прошло успешно', [Fields[i].FieldName,
          Fields[i].RelationName]));
      except
        Log(Format('Ошибка при добавлении поля %s в таблицу %s', [Fields[i].FieldName,
          Fields[i].RelationName]));
      end;
    end;
  end;
end;

end.
