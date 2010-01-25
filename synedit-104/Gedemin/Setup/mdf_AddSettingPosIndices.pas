unit mdf_AddSettingPosIndices;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit;

procedure AddSettingPosIndices(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript;

const
  Index: TmdfIndex = (RelationName:'AT_SETTINGPOS'; IndexName:'AT_SETTINGPOS_XID_DBID';
    Columns: 'XID, DBID'; Unique: False; Sort: stAsc);

procedure AddSettingPosIndices(IBDB: TIBDatabase; Log: TModifyLog);
begin
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
