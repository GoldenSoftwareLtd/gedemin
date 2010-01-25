unit mdf_AddBranchKey;

interface
uses
  sysutils, IBDatabase, gdModify;
  procedure AddBranchKey(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL;

procedure AddBranchKey(IBDB: TIBDatabase; Log: TModifyLog);
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
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$field_name = ''BRANCHKEY'' AND rdb$relation_name = ''AT_RELATIONS''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE at_relations ADD branchkey dforeignkey ';
        Log('AT_RELATION: Добавление поля branchkey');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints c LEFT JOIN ' +
        ' rdb$ref_constraints r ON r.rdb$constraint_name = c.rdb$constraint_name ' +
        ' WHERE c.rdb$constraint_name = ''AT_FK_RELATIONS_BRANCHKEY'' AND r.rdb$delete_rule = ''CASCADE''';
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE at_relations DROP CONSTRAINT at_fk_relations_branchkey ';
        ibsql.ExecQuery;
        Log('AT_RELATION: Удаление форейн ключа на поле branchkey');
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints c '+
        ' WHERE c.rdb$constraint_name = ''AT_FK_RELATIONS_BRANCHKEY'' ';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE at_relations ADD CONSTRAINT at_fk_relations_branchkey ' +
          ' FOREIGN KEY (branchkey) REFERENCES gd_command (id) ON UPDATE CASCADE ';
        Log('AT_RELATION: Добавление форейн ключа на поле branchkey');
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
