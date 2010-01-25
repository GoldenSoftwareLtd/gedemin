{Изменяет наименования шаблонов отчетов на уникальные}
unit mdf_ChangeTemplatesName;

interface
uses
  sysutils, IBDatabase, gdModify;
  procedure ChangeTemplatesName(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL;

procedure ChangeTemplatesName(IBDB: TIBDatabase; Log: TModifyLog);
var
  FIBTransaction: TIBTransaction;
  ibsql, ibsqlUpdate: TIBSQL;
  DBID: Integer;
begin
  ibsql := TIBSQL.Create(nil);
  ibsqlUpdate := TIBSQL.Create(nil);
  FIBTransaction := TIBTransaction.Create(nil);
  try
    FIBTransaction.DefaultDatabase := IBDB;
    ibsql.Transaction := FIBTransaction;
    ibsqlUpdate.Transaction := FIBTransaction;
    try
      if FIBTransaction.InTransaction then
        FIBTransaction.Rollback;
      FIBTransaction.StartTransaction;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT GEN_ID(gd_g_dbid, 0) FROM rdb$database';
      ibsql.ExecQuery;
      DBID := ibsql.Fields[0].AsInteger;

      //Проверяем, есть ли уже уникальный индекс на шаблонах отчетов
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$indices WHERE rdb$index_name = ''RP_X_REPORTTEMPLATE_NAME''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        {Исправим неуникальные названия шаблонов отчетов}
        ibsqlUpdate.Close;
        ibsqlUpdate.SQL.Text := 'UPDATE rp_reporttemplate SET name = :name WHERE id = :id';

        ibsql.Close;
        ibsql.SQL.Text := 'SELECT r.* ' +
          ' FROM rp_reporttemplate r ' +
          ' WHERE ' +
          ' EXISTS( ' +
          '  SELECT name ' +
          '  FROM rp_reporttemplate ' +
          '  WHERE name = r.name  '  +
          '  GROUP BY name ' +
          '  HAVING COUNT(id) > 1)';
        ibsql.ExecQuery;
        if not ibsql.EOF then
          Log('RP_REPORTTEMPLATE: Изменение названий шаблонов отчетов на уникальные');
        while not ibsql.EOF do
        begin
          ibsqlUpdate.Close;
          //Имя может быть не больше 60, 20 символов отводим под руид
          ibsqlUpdate.ParamByName('name').AsString := Copy(ibsql.FieldByName('name').AsString, 1, 40) +
            ibsql.FieldByName('id').AsString + '_' + IntToStr(DBID);
          ibsqlUpdate.ParamByName('id').AsString := ibsql.FieldByName('id').AsString;
          ibsqlUpdate.ExecQuery;
          ibsql.Next;
        end;
        FIBTransaction.Commit;
        FIBTransaction.DefaultDataBase.Connected := False;
        FIBTransaction.DefaultDataBase.Connected := True;
        FIBTransaction.StartTransaction;

        ibsql.Close;
        Log('RP_REPORTTEMPLATE: Создание уникального индекса на поля name');
        ibsql.SQL.Text := 'CREATE UNIQUE INDEX rp_x_reporttemplate_name ON rp_reporttemplate(name)';
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
    ibsqlUpdate.Free;
    FIBTransaction.Free;
  end;
end;

end.
