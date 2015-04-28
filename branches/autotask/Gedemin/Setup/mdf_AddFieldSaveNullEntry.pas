unit mdf_AddFieldSaveNullEntry;

interface

uses
  IBDatabase, gdModify;

procedure AddFieldSaveNullEntry(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, mdf_metadata_unit;

procedure AddFieldSaveNullEntry(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
  I: Integer;
  Str: String;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        Log('Корректировка метаданных проводок');

        FIBSQL.Transaction := FTransaction;

        if not FieldExist2('ac_trrecord', 'issavenull', FTransaction) then
        begin
          FIBSQL.SQL.Text := 'ALTER TABLE ac_trrecord ADD issavenull dboolean';
          FIBSQL.ExecQuery;
        end;

        if not FieldExist2('ac_trrecord', 'functionkey', FTransaction) then
        begin
          FIBSQL.SQL.Text := 'ALTER TABLE ac_trrecord ADD functionkey dforeignkey';
          FIBSQL.ExecQuery;
        end;

        if not ConstraintExist2('ac_trrecord', 'ac_fk_trrecord_function', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE ac_trrecord ADD CONSTRAINT ac_fk_trrecord_function ' +
            '  FOREIGN KEY (functionkey) REFERENCES gd_function(id) ' +
            '  ON UPDATE CASCADE;';
          FIBSQL.ExecQuery;
        end;

        if not FieldExist2('ac_trrecord', 'documenttypekey', FTransaction) then
        begin
          FIBSQL.SQL.Text := 'ALTER TABLE ac_trrecord ADD documenttypekey dintkey';
          FIBSQL.ExecQuery;
        end;

        if not ConstraintExist2('ac_trrecord', 'ac_fk_trrecord_documenttype', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE ac_trrecord ADD CONSTRAINT ac_fk_trrecord_documenttype ' +
            '  FOREIGN KEY (documenttypekey) REFERENCES gd_documenttype(id) ' +
            '  ON UPDATE CASCADE;';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT id FROM gd_documenttype WHERE UPPER(name)=''ПРОИЗВОЛЬНЫЙ ТИП'' ';
        FIBSQL.ExecQuery;
        if FIBSQL.EOF then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'SELECT gen_id(GD_G_Unique, 1) FROM rdb$database';
          FIBSQL.ExecQuery;
          I := FIBSQL.Fields[0].AsInteger;

          FIBSQL.Close;
          FIBSQL.SQL.Text := 'SELECT gen_id(GD_G_DBID, 0) FROM rdb$database';
          FIBSQL.ExecQuery;
          Str := IntToStr(I) + '_' + FIBSQL.Fields[0].AsString;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'INSERT INTO gd_documenttype (id, name, ruid) VALUES (:id, ''Произвольный тип'', :ruid)';
          FIBSQL.ParamByName('id').AsInteger  := I;
          FIBSQL.ParamByName('ruid').AsString := Str;
          FIBSQL.ExecQuery;
        end else
          I := FIBSQL.Fields[0].AsInteger;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'UPDATE ac_trrecord SET documenttypekey = :documenttypekey WHERE documenttypekey IS NULL';
        FIBSQL.ParamByName('documenttypekey').AsInteger := I;
        FIBSQL.ExecQuery;
      finally
        FIBSQL.Free;
      end;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        Log('Ошибка: ' + E.Message);
        raise;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
