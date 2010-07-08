unit mdf_AddFieldPlaceCode;

interface

uses
  IBDatabase, gdModify;

procedure AddFieldPlaceCode(IBDB: TIBDatabase; Log: TModifyLog);


implementation

uses
  IBSQL, SysUtils, mdf_MetaData_unit;

const
  Field: TmdfField = (RelationName: 'gd_place'; FieldName: 'code'; Description: 'DTEXT8');
procedure AddFieldPlaceCode(IBDB: TIBDatabase; Log: TModifyLog);
begin
  if not FieldExist(Field, IBDB) then
  begin
    Log(Format('Добавление поля %s в таблицу %s', [Field.FieldName, Field.relationName]));
    try
      AddField(Field, IBDB);
    except
      on E: Exception do
        Log('Ошибка: ' + E.Message)
    end;
  end;
end;

end.
