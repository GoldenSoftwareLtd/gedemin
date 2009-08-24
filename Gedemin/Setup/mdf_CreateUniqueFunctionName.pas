unit mdf_CreateUniqueFunctionName;

interface

uses
  IBDatabase, gdModify;

procedure CreateUniqueFunctionName(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, IBCustomDataSet, SysUtils;

procedure CreateUniqueFunctionName(IBDB: TIBDatabase; Log: TModifyLog);
const
  ModifyDate = '23.08.2002';

var
  FTransaction: TIBTransaction;
  FIBSQL, FSecSQL, FFourSQL: TIBSQL;
  FIBDataSet: TIBDataSet;

  function ChangeName(AnScript, AnOldName, AnNewName: String): String;
  var
    I: Integer;
    Gag: String;
  begin
    Result := AnScript;
    AnOldName := AnsiUpperCase(AnOldName);
    Gag := AnNewName;
    FillChar(Gag[1], Length(AnNewName), '0');
    I := Pos(AnOldName, AnsiUpperCase(AnScript));
    while I > 0 do
    begin
      Delete(AnScript, I, Length(AnOldName));
      Insert(Gag, AnScript, I);
      Delete(Result, I, Length(AnOldName));
      Insert(AnNewName, Result, I);

      I := Pos(AnOldName, AnsiUpperCase(AnScript));
    end;
  end;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    try
      FTransaction.DefaultDatabase := IBDB;
      FTransaction.StartTransaction;
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FSecSQL := TIBSQL.Create(nil);
        try
          FSecSQL.Transaction := FTransaction;
          // Проверка существования уникального ключа
          //<--
          {FIBSQL.SQL.Text := 'SELECT ins.rdb$index_name FROM rdb$index_segments ins, rdb$indices iin' +
           ' WHERE ins.rdb$field_name = ''NAME'' AND iin.rdb$relation_name = ''GD_FUNCTION''' +
           ' AND ins.rdb$index_name = iin.rdb$index_name AND iin.rdb$unique_flag <> 0';}
          //-->
          FIBSQL.SQL.Text := 'SELECT DISTINCT ins.rdb$index_name FROM rdb$index_segments ins, rdb$indices iin' +
           ' WHERE ins.rdb$field_name in (''NAME'', ''MODULECODE'') AND iin.rdb$relation_name = ''GD_FUNCTION''' +
           ' AND ins.rdb$index_name = iin.rdb$index_name AND iin.rdb$unique_flag <> 0';
          FIBSQL.ExecQuery;
          while not FIBSQL.Eof do
          begin
            FSecSQL.Close;
            FSecSQL.SQL.Text := 'SELECT COUNT(*) FROM rdb$index_segments WHERE rdb$index_name = :indexname';
            FSecSQL.ParamByName('indexname').AsString := FIBSQL.Fields[0].AsString;
            FSecSQL.ExecQuery;

            //<--
            //if not FSecSQL.Eof and (FSecSQL.Fields[0].AsInteger = 1) then
            //-->
            if not FSecSQL.Eof and (FSecSQL.Fields[0].AsInteger = 2) then
            begin
            //  Log('GD_FUNCTION: Уникальное имя функции уже существует');
              Exit;
            end;

            FIBSQL.Next;
          end;
          FIBSQL.Close;
          FSecSQL.Close;

          // Если ключа не существует то создаем его
          Log('Модификация от ' + ModifyDate);
          Log('GD_FUNCTION: Начат процесс создания уникального имени функции');
            // Модифицируем все имена существующих функций
          //<--
          //FIBSQL.SQL.Text := 'SELECT G_S_ANSIUPPERCASE(name), COUNT(id) FROM gd_function GROUP BY G_S_ANSIUPPERCASE(name), MODULECODE ORDER BY 2 DESC';
          //-->
          FIBSQL.SQL.Text := 'SELECT G_S_ANSIUPPERCASE(name), modulecode, COUNT(id) FROM gd_function GROUP BY G_S_ANSIUPPERCASE(name), MODULECODE ORDER BY 3 DESC';
          FIBSQL.ExecQuery;

          FSecSQL.SQL.Text := 'SELECT id, name FROM gd_function WHERE UPPER(name) = :name';

          FFourSQL := TIBSQL.Create(nil);
          try
            FFourSQL.Transaction := FTransaction;
            FFourSQL.SQL.Text := 'SELECT mainfunctionkey FROM rp_additionalfunction WHERE addfunctionkey = :id';

            FIBDataSet := TIBDataSet.Create(nil);
            try
              FIBDataSet.Transaction := FTransaction;
              FIBDataSet.SelectSQL.Text := 'SELECT id, name, script FROM gd_function WHERE id = :id';
              FIBDataSet.ModifySQL.Text := 'update gd_function set ID = :ID, NAME = :NAME, SCRIPT = :SCRIPT where ID = :OLD_ID';

              while not FIBSQL.Eof and (FIBSQL.Fields[2].AsInteger > 1) do
              begin
                FSecSQL.Close;
                FSecSQL.Params[0].AsString := Trim(FIBSQL.Fields[0].AsString);
                FSecSQL.ExecQuery;

                while not FSecSQL.Eof do
                begin
                  FIBDataSet.Close;
                  FIBDataSet.Params[0].AsInteger := FSecSQL.Fields[0].AsInteger;
                  FIBDataSet.Open;
                  FIBDataSet.Edit;
                  FIBDataSet.FieldByName('script').AsString := ChangeName(FIBDataSet.FieldByName('script').AsString,
                   FIBDataSet.FieldByName('name').AsString, FIBDataSet.FieldByName('name').AsString +
                   FIBDataSet.FieldByName('id').AsString);
                  FIBDataSet.FieldByName('name').AsString := FIBDataSet.FieldByName('name').AsString +
                   FIBDataSet.FieldByName('id').AsString;
                  FIBDataSet.Post;

                  FFourSQL.Close;
                  FFourSQL.Params[0].AsInteger := FSecSQL.Fields[0].AsInteger;
                  FFourSQL.ExecQuery;

                  while not FFourSQL.Eof do
                  begin
                    FIBDataSet.Close;
                    FIBDataSet.Params[0].AsInteger := FFourSQL.Fields[0].AsInteger;
                    FIBDataSet.Open;
                    FIBDataSet.Edit;
                    FIBDataSet.FieldByName('script').AsString := ChangeName(FIBDataSet.FieldByName('script').AsString,
                     FSecSQL.FieldByName('name').AsString, FSecSQL.FieldByName('name').AsString +
                     FSecSQL.FieldByName('id').AsString);
                    FIBDataSet.Post;

                    FFourSQL.Next;
                  end;

                  FSecSQL.Next;
                end;

                FIBSQL.Next;
              end;
            finally
              FIBDataSet.Free;
            end;
          finally
            FFourSQL.Free;
          end;

            // Создаем уникальный индекс
          FIBSQL.Close;
          //<--
          //FIBSQL.SQL.Text := 'CREATE UNIQUE INDEX gd_ux_function_name_modulecode ON gd_function(name)';
          //-->
          FIBSQL.SQL.Text := 'CREATE UNIQUE INDEX gd_ux_function_name_modulecode ON gd_function(name, modulecode)';
          FIBSQL.ExecQuery;
          FIBSQL.Close;
          FTransaction.Commit;
          Log('GD_FUNCTION: Процесс создания уникального имени функции успешно завершен');
        finally
          FSecSQL.Free;
        end;
      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        Log('GD_FUNCTION: Произошла ошибка при создании уникального имени функции: ' + E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
