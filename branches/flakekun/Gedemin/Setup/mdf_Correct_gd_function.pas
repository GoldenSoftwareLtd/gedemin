unit mdf_Correct_gd_function;

interface

uses
  IBDatabase, gdModify;

procedure Correct_gd_function(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IB, IBSQL, SysUtils, {gd_ScriptCompiler,} classes;

procedure Correct_gd_function(IBDB: TIBDatabase; Log: TModifyLog);
begin
{  LTransaction := TIBTransaction.Create(nil);
  try
    LTransaction.DefaultDatabase := IBDB;
    LIBSQL := TIBSQL.Create(nil);
    try
      Log('Корректировка поля displayscript таблицы gd_function для поддержки компиляции');

      LIBSQL.Transaction := LTransaction;
      LIBSQL.SQL.Text :=
        'SELECT * FROM gd_function';
      LTransaction.StartTransaction;
      try
        LIBSQL.ExecQuery;
        NameList := TStringList.Create;
        try
          UpdateIBSQL := TIBSQL.Create(nil);
          try
            UpdateIBSQL.Transaction := LTransaction;
            UpdateIBSQL.SQL.Text :=
              'UPDATE gd_function SET displayscript = :displayscript WHERE id = :id';
            while not LIBSQL.Eof do
            begin
              InternalScriptList(
                LIBSQL.FieldByName('script').AsString, NameList);

              if LIBSQL.FieldByName('displayscript').AsString <> NameList.Text then
              begin
                UpdateIBSQL.ParamByName('displayscript').AsString := NameList.Text;
                UpdateIBSQL.ParamByName('id').AsInteger :=
                  LIBSQL.FieldByName('id').AsInteger;
                UpdateIBSQL.ExecQuery;
              end;

              LIBSQL.Next;
            end;
          finally
            UpdateIBSQL.Free;
          end;
        finally
          NameList.Free;
        end;

      except
        LTransaction.Rollback;
        Log('Ошибка. Корректировка не произведена.');
      end;

      Log('Корректировка удачно завершена.');

      if LTransaction.Active then
        LTransaction.Commit;
    finally
      LIBSQL.Free;
    end;
  finally
    LTransaction.Free;
  end;

 }
end;

end.
