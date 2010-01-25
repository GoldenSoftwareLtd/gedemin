unit mdf_AddQuantityField;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit;

procedure AddQuantityField(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript;

const
  FieldCount = 2;
  Fields: array[0..FieldCount - 1] of TmdfField = (
    (RelationName: 'AC_OVERTURNBYANAL'; FieldName: 'QUANTITY'; Description: 'DTEXT1024'),
    (RelationName: 'AC_OVERTURNBYANAL'; FieldName: 'ANALYTICFILTER'; Description: 'DTEXT1024'));
procedure AddQuantityField(IBDB: TIBDatabase; Log: TModifyLog);
var
  I: Integer;
begin
  for I := 0 to FieldCount - 1 do
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
