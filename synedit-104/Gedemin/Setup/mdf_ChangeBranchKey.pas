unit mdf_ChangeBranchKey;
//Изменение branchkey в at_relations и gd_documenttype

interface
uses
  sysutils, IBDatabase, gdModify;
  procedure ChangeBranchKey(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL;

procedure ChangeBranchKey(IBDB: TIBDatabase; Log: TModifyLog);
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
      ibsql.SQL.Text := ' SELECT * FROM rdb$ref_constraints c ' +
        ' WHERE ' +
        '  c.rdb$constraint_name = ''GD_FK_DOCUMENTTYPE_BRANCHKEY''' +
        '  and c.rdb$delete_rule <> ''SET NULL''';

      ibsql.ExecQuery;

      if ibsql.RecordCount > 0 then
      begin
        FIBTransaction.Commit;
        FIBTransaction.DefaultDatabase.Connected := False;
        FIBTransaction.DefaultDatabase.Connected := True;
        FIBTransaction.StartTransaction;

        ibsql.Close;
        ibsql.SQL.Text := 'alter table GD_DOCUMENTTYPE ' +
          ' drop constraint GD_FK_DOCUMENTTYPE_BRANCHKEY';
        Log('GD_DOCUMENTTYPE: Удаление внешнего ключа GD_FK_DOCUMENTTYPE_BRANCHKEY');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.DefaultDatabase.Connected := False;
        FIBTransaction.DefaultDatabase.Connected := True;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := ' SELECT * FROM rdb$relation_constraints c ' +
        ' WHERE ' +
        '  c.rdb$constraint_name = ''GD_FK_DOCUMENTTYPE_BRANCHKEY''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := ' alter table GD_DOCUMENTTYPE ' +
          ' add constraint GD_FK_DOCUMENTTYPE_BRANCHKEY ' +
          ' foreign key (BRANCHKEY) ' +
          ' references GD_COMMAND(ID) ' +
          ' on delete SET NULL ' +
          ' on update CASCADE ';
        Log('GD_DOCUMENTTYPE: Добавление внешнего ключа GD_FK_DOCUMENTTYPE_BRANCHKEY');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.DefaultDatabase.Connected := False;
        FIBTransaction.DefaultDatabase.Connected := True;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := ' SELECT * ' +
        ' FROM ' +
        '  gd_command c ' +
        ' JOIN gd_documenttype d ON d.ruid = c.cmd and c.parent = d.branchkey ';
      ibsql.ExecQuery;

      if ibsql.RecordCount > 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := ' UPDATE gd_documenttype r SET r.branchkey = ' +
          ' (SELECT MAX(c.id) FROM gd_command c WHERE c.subtype = r.ruid and c.parent = r.branchkey) ' +
          ' WHERE ' +
          ' EXISTS(SELECT c.id FROM gd_command c WHERE c.subtype = r.ruid and c.parent = r.branchkey)';
        Log('GD_DOCUMENTTYPE: Обновление ссылки на исследователь');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := ' SELECT * ' +
        ' FROM ' +
        '   gd_command c ' +
        '   JOIN at_relations r ON c.parent = r.branchkey ' +
        ' WHERE ' +
        '   r.relationname = c.subtype';
      ibsql.ExecQuery;

      if ibsql.RecordCount > 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := ' UPDATE at_relations r SET r.branchkey = ' +
          ' (SELECT MAX(c.id) FROM gd_command c WHERE c.subtype = r.relationname AND c.parent = r.branchkey) ' +
          ' WHERE ' +
          ' EXISTS(SELECT c.id FROM gd_command c WHERE c.subtype = r.relationname and c.parent = r.branchkey)';
        Log('AT_RELATIONS: Обновление ссылки на исследователь');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
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
