unit mdf_ChangeForeignForAtFields;

interface

uses
  sysutils, IBDatabase, gdModify;


procedure ChangeForeignForAtFields(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL;

procedure ChangeForeignForAtFields(IBDB: TIBDatabase; Log: TModifyLog);
var
  FIBTransaction: TIBTransaction;
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  FIBTransaction := TIBTransaction.Create(nil);
  try
    FIBTransaction.DefaultDatabase := IBDB;
    ibsql.Transaction := FIBTransaction;
    try
      if FIBTransaction.InTransaction then
        FIBTransaction.Rollback;
      FIBTransaction.StartTransaction;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints rc ' +
        ' LEFT JOIN rdb$ref_constraints ref ON ref.rdb$constraint_name = rc.rdb$constraint_name ' +
        ' WHERE rc.rdb$constraint_name = ''AT_FK_FIELDS_RLF''' +
        ' AND ref.rdb$delete_rule = ''RESTRICT''';
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        FIBTransaction.Commit;
        FIBTransaction.DefaultDatabase.Connected := False;
        FIBTransaction.DefaultDatabase.Connected := True;
        FIBTransaction.StartTransaction;
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE at_fields DROP CONSTRAINT at_fk_fields_rlf';
        Log('AT_FIELDS: Удаление foreign key at_fk_fields_rlf');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.DefaultDatabase.Connected := False;
        FIBTransaction.DefaultDatabase.Connected := True;
        FIBTransaction.StartTransaction;
        ibsql.Close;
        ibsql.SQL.Text := ' ALTER TABLE at_fields ADD CONSTRAINT at_fk_fields_rlf ' +
          ' FOREIGN KEY (reflistfieldkey) REFERENCES at_relation_fields (id) ON UPDATE CASCADE ON DELETE SET NULL';
        Log('AT_FIELDS: Создание foreign key at_fk_fields_rlf');
        ibsql.ExecQuery;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints rc ' +
        ' LEFT JOIN rdb$ref_constraints ref ON ref.rdb$constraint_name = rc.rdb$constraint_name ' +
        ' WHERE rc.rdb$constraint_name = ''AT_FK_FIELDS_SLF''' +
        ' AND ref.rdb$delete_rule = ''RESTRICT''';
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        FIBTransaction.Commit;
        FIBTransaction.DefaultDatabase.Connected := False;
        FIBTransaction.DefaultDatabase.Connected := True;
        FIBTransaction.StartTransaction;
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE at_fields DROP CONSTRAINT at_fk_fields_slf';
        Log('AT_FIELDS: Удаление foreign key at_fk_fields_slf');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.DefaultDatabase.Connected := False;
        FIBTransaction.DefaultDatabase.Connected := True;
        FIBTransaction.StartTransaction;
        ibsql.Close;
        ibsql.SQL.Text := ' ALTER TABLE at_fields ADD CONSTRAINT at_fk_fields_slf ' +
          ' FOREIGN KEY (setlistfieldkey) REFERENCES at_relation_fields (id) ON UPDATE CASCADE ON DELETE SET NULL';
        Log('AT_FIELDS: Создание foreign key at_fk_fields_slf');          
        ibsql.ExecQuery;
      end;



      if FIBTransaction.InTransaction then
        FIBTransaction.Commit;
    except
      on E: Exception do
      begin
        if FIBTransaction.InTransaction then
          FIBTransaction.Rollback;
        Log(E.Message);
      end;
    end;
  finally
    ibsql.Free;
    FIBTransaction.Free;
  end;
end;

end.
