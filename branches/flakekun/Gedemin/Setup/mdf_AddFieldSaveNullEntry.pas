unit mdf_AddFieldSaveNullEntry;

interface

uses
  IBDatabase, gdModify;

procedure AddFieldSaveNullEntry(IBDB: TIBDatabase; Log: TModifyLog);


implementation

uses
  IBSQL, SysUtils, gd_KeyAssoc;

procedure AddFieldSaveNullEntry(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL{, ReadIBSQL}: TIBSQL;
  TypeArray: TgdKeyIntAssoc;
  I, K: Integer;
  Str: String;

begin
  Log('Добавление поля в типовые проводки');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        Log('Корректировка метаданных проводок.');
        FIBSQL.Transaction := FTransaction;
        FIBSQL.SQL.Text := 'ALTER TABLE ac_trrecord ADD issavenull dboolean';
        try
          FIBSQL.ExecQuery;
        except
        end;

        {
        FIBSQL.Close;
        FIBSQL.SQL.Text := 'ALTER TABLE ac_trentry ADD functionkey dforeignkey';
        try
          FIBSQL.ExecQuery;
          Log('Проводка: Добавлено поле functionkey в таблицу ac_trentry.');
        except
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'ALTER TABLE ac_trentry ADD functionstor dblob80 DEFAULT null';
        try
          FIBSQL.ExecQuery;
          Log('Проводка: Добавлено поле functionstor в таблицу ac_trentry.');
        except
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'ALTER TABLE ac_trentry ADD CONSTRAINT ac_fk_trentry_function ' +
          '  FOREIGN KEY (functionkey) REFERENCES gd_function(id) ' +
          '  ON UPDATE CASCADE;';
        try
          FIBSQL.ExecQuery;
          Log('Проводка: Добавлен внешний ключ для поля functionkey таблицы ac_trentry.');
        except
        end;
        }

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'ALTER TABLE ac_trrecord ADD functionkey dforeignkey';
        try
          FIBSQL.ExecQuery;
        except
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'ALTER TABLE ac_trrecord ADD CONSTRAINT ac_fk_trrecord_function ' +
          '  FOREIGN KEY (functionkey) REFERENCES gd_function(id) ' +
          '  ON UPDATE CASCADE;';
        try
          FIBSQL.ExecQuery;
        except
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'ALTER TABLE ac_trrecord ADD documenttypekey dintkey';
        try
          FIBSQL.ExecQuery;
        except
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'ALTER TABLE ac_trrecord ADD CONSTRAINT ac_fk_trrecord_documenttype ' +
          '  FOREIGN KEY (documenttypekey) REFERENCES gd_documenttype(id) ' +
          '  ON UPDATE CASCADE;';
        try
          FIBSQL.ExecQuery;
        except
        end;

        TypeArray := TgdKeyIntAssoc.Create;
        try
          {FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'UPDATE ac_trentry SET functionkey = :functionkey ' +
            'WHERE id = :id';

          ReadIBSQL := TIBSQL.Create(nil);
          try
            ReadIBSQL.Transaction := TIBTransaction.Create(ReadIBSQL);
            ReadIBSQL.Transaction.DefaultDatabase := FTransaction.DefaultDatabase;
            ReadIBSQL.SQL.Text :=
              'SELECT z.*, te.trrecordkey FROM ac_script z ' +
              'LEFT JOIN ac_trentry te ON te.id = z.trentrykey ';
            ReadIBSQL.Transaction.StartTransaction;
            ReadIBSQL.ExecQuery;
            while not ReadIBSQL.Eof do
            begin
              if TypeArray.IndexOf(ReadIBSQL.FieldByName('trrecordkey').AsInteger) = -1 then
              begin
                I := TypeArray.Add(ReadIBSQL.FieldByName('trrecordkey').AsInteger);
                TypeArray.ValuesByIndex[I] := ReadIBSQL.FieldByName('documenttypekey').AsInteger;
              end;
              FIBSQL.ParamByName('functionkey').AsVariant :=
                ReadIBSQL.FieldByName('functionkey').AsVariant;
              FIBSQL.ParamByName('id').AsInteger :=
                ReadIBSQL.FieldByName('trentrykey').AsInteger;
              FIBSQL.ExecQuery;
              ReadIBSQL.Next;
            end;
            ReadIBSQL.Transaction.Commit;
          finally
            ReadIBSQL.Free;
          end;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'UPDATE ac_trrecord SET documenttypekey = :documenttypekey ' +
            'WHERE id = :id';
          for I := 0 to TypeArray.Count - 1 do
          begin
            FIBSQL.ParamByName('documenttypekey').AsInteger := TypeArray.ValuesByIndex[I];
            FIBSQL.ParamByName('id').AsInteger := TypeArray.Keys[I];
            FIBSQL.ExecQuery;
          end;}

          TypeArray.Clear;

          FIBSQL.Close;
          FIBSQL.SQL.Text := 'SELECT id FROM ac_trrecord WHERE documenttypekey IS NULL';
          FIBSQL.ExecQuery;
          while not FIBSQL.Eof do
          begin
            TypeArray.Add(FIBSQL.FieldByName('id').AsInteger);
            FIBSQL.Next;
          end;

          if TypeArray.Count > 0 then
          begin
            FIBSQL.Close;
            FIBSQL.SQL.Text := 'SELECT gen_id(GD_G_Unique, 1) FROM rdb$database';
            FIBSQL.ExecQuery;
            I := FIBSQL.Fields[0].AsInteger;

            FIBSQL.Close;
            FIBSQL.SQL.Text := 'SELECT gen_id(GD_G_DBID, 0) FROM rdb$database';
            FIBSQL.ExecQuery;
            K := FIBSQL.Fields[0].AsInteger;
            Str := IntToStr(I) + '_' + IntToStr(K);

            FIBSQL.Close;
            FIBSQL.SQL.Text :=
              'INSERT INTO gd_documenttype (id, name, ruid) VALUES (:id, ''Произвольный тип'', :ruid)';
            FIBSQL.ParamByName('id').AsInteger  := i;
            FIBSQL.ParamByName('ruid').AsString := Str;
            FIBSQL.ExecQuery;

            FIBSQL.SQL.Text :=
              'UPDATE ac_trrecord SET documenttypekey = :documenttypekey WHERE id = :id';
            for k := 0 to TypeArray.Count - 1 do
            begin
              FIBSQL.ParamByName('id').AsInteger := TypeArray[k];
              FIBSQL.ParamByName('documenttypekey').AsInteger := I;
              FIBSQL.ExecQuery;
            end;
          end;
        finally
          TypeArray.Free;
        end;
      finally
        FIBSQL.Free;
      end;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        Log(E.Message);
        raise;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
