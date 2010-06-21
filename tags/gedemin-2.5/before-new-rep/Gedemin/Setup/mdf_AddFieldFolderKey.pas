unit mdf_AddFieldFolderKey;

interface

uses
  IBDatabase, gdModify;

procedure AddFieldFolderKey(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, mdf_MetaData_unit;

const
  Field: TmdfField = (RelationName: 'rp_reportlist'; FieldName: 'FOLDERKEY';
    Description: 'DFOREIGNKEY REFERENCES gd_command(id) ON DELETE SET NULL ON UPDATE CASCADE');
procedure AddFieldFolderKey(IBDB: TIBDatabase; Log: TModifyLog);
begin
  if not FieldExist(Field, IBDB) then
  begin
    Log(Format('Добавление поля %s в таблицу %s', [Field.FieldName, Field.relationName]));
    try
      AddField(Field, IBDB);
    except
      on E: Exception do
        Log(Format('Ошибка при добавлении поля: %s', [E.Message]))
    end;
  end;
end;

end.
