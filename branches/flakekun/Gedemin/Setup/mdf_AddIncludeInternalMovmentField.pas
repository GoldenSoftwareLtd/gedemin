unit mdf_AddIncludeInternalMovmentField;

interface

uses
  IBDatabase, gdModify;

procedure AddIncludeInternalMovment(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript;

procedure AddIncludeInternalMovment(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;

  procedure Add(RelationName: string);
  var
    Script: TIBScript;
  begin
    Script := TIBScript.Create(nil);
    try
      Script.Transaction := FTransaction;
      Script.Database := IBDB;
      Script.Script.Text :=
        Format('ALTER TABLE %s ADD INCLUDEINTERNALMOVEMENT DBOOLEAN;', [RelationName]);
      Script.ExecuteScript;
      FTransaction.Commit;
      FTransaction.StartTransaction;
    finally
      Script.Free;
    end;
  end;

  procedure FieldExist(RelationName: string);
  var
    FIBSQL: TIBSQL;
  begin
    FIBSQL := TIBSQL.Create(nil);
    try
      FIBSQL.Transaction := FTransaction;
      FIBSQL.SQL.Text := Format('SELECT * FROM rdb$relation_fields WHERE rdb$field_name = ''INCLUDEINTERNALMOVEMENT'' AND rdb$relation_name = ''%s''', [RelationName]);
      FIBSQL.ExecQuery;
      if FIBSQL.RecordCount = 0 then
      begin
        Log(Format('Добавление поля IncludeInternalField в таблицу %s', [RelationName]));
        Add(RelationName);
        Log('Добавление прошло успешно');
      end;
     finally
       FIBSQL.Free;
     end; 
  end;

begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FieldExist('AC_LEDGER');
      FieldExist('AC_OVERTURNBYANAL');
      FTransaction.Commit;
    except
      on E: Exception do
      begin
        FTransaction.Rollback;
        Log(E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
