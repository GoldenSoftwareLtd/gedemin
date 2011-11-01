unit mdf_AddQuantityFK;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit;

procedure AddQuantityFK(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript, classes, gd_common_functions;

const
  AlterConstraintCount = 2;
  AlterConstraints: array[0..AlterConstraintCount -  1] of TmdfConstraint = (
    (TableName: 'AC_QUANTITY'; ConstraintName: 'FK_AC_QUANTITY_VALUE';
      Description: ' FOREIGN KEY (VALUEKEY) REFERENCES GD_VALUE(ID)'),
    (TableName: 'AC_ACCVALUE'; ConstraintName: 'FK_AC_ACCVALUE_VALUE';
      Description: ' FOREIGN KEY (VALUEKEY) REFERENCES GD_VALUE(ID)')
  );

procedure AddQuantityFK(IBDB: TIBDatabase; Log: TModifyLog);
var
  I: Integer;
begin
  for I := 0 to AlterConstraintCount - 1 do
  begin
    if not ConstraintExist(AlterConstraints[I], IBDB) then
    begin
      Log(Format('Добавление внешней ссылки %s в таблицу %s', [AlterConstraints[i].ConstraintName,
        AlterConstraints[I].TableName]));
      try
        AddConstraint(AlterConstraints[I], IBDB);
      except
        on E: Exception do
          Log('Ошибка: ' + E.Message);
      end;
    end;
  end;
end;

end.
