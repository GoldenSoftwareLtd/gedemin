unit mdf_AddTransactionFunctionFields;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit, mdf_dlgDefaultCardOfAccount_unit, Forms,
  Windows, Controls;

procedure AddTransactionFuntionField(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript, classes, gd_common_functions;

const
  FieldCount = 4;
  Fields: array[0..FieldCount - 1] of TmdfField = (
    (RelationName: 'GD_DOCUMENTTYPE'; FieldName: 'HEADERFUNCTIONKEY'; Description:
      'DFOREIGNKEY REFERENCES GD_FUNCTION(ID)'),
    (RelationName: 'GD_DOCUMENTTYPE'; FieldName: 'HEADERFUNCTIONTEMPLATE'; Description:
      'DBLOB80'),
    (RelationName: 'GD_DOCUMENTTYPE'; FieldName: 'LINEFUNCTIONKEY'; Description:
      'DFOREIGNKEY REFERENCES GD_FUNCTION(ID)'),
    (RelationName: 'GD_DOCUMENTTYPE'; FieldName: 'LINEFUNCTIONTEMPLATE'; Description:
      'DBLOB80')
  );


procedure AddTransactionFuntionField(IBDB: TIBDatabase; Log: TModifyLog);
var
  I: Integer;
begin
  for I := 0 to FieldCount - 1 do
  begin
    if not FieldExist(Fields[i], IBDB) then
    begin
      Log(Format('Добавление поля %s в таблицу %s', [Fields[i].FieldName,
        Fields[I].RelationName]));
      try
        AddField(Fields[I], IBDB);
        Log('succes');
      except
        on E: Exception do
          Log(E.Message);
      end;
    end;
  end;
end;

end.
