unit mdf_DocumentAndCommandUpdate;

interface
uses
  sysutils, IBDatabase, gdModify;
  procedure DocumentAndCommandUpdate(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL;

procedure DocumentAndCommandUpdate(IBDB: TIBDatabase; Log: TModifyLog);
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

      //Добавляем форейн ключ на transactionkey в документе
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints c '+
        ' WHERE c.rdb$constraint_name = ''GD_FK_DOC_TRANSACTIONKEY'' ';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        //Обработаем случай возможного слияния операций
        ibsql.SQL.Text := ' update gd_document doc set doc.transactionkey = ' +
           ' (SELECT FIRST 1 r.transactionkey FROM ac_record r ' +
           ' WHERE r.documentkey = doc.id) ' +
           ' where ' +
           ' exists (SELECT * FROM  ac_record r ' +
           ' WHERE r.documentkey = doc.id) ' +
           ' AND not (transactionkey IN (SELECT id FROM ac_transaction))';
        ibsql.ExecQuery;
        //На случай хранения лабуды
        ibsql.Close;
        ibsql.SQL.Text := ' update gd_document doc set doc.transactionkey = NULL ' +
           ' where ' +
           ' transactionkey IS NOT NULL ' +
           ' AND not (transactionkey IN (SELECT id FROM ac_transaction))';
        ibsql.ExecQuery;

        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;

        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE gd_document ADD CONSTRAINT gd_fk_doc_transactionkey ' +
          ' FOREIGN KEY (transactionkey) REFERENCES ac_transaction (id) ON UPDATE CASCADE ';
        Log('GD_DOCUMENT: Добавление форейн ключа на поле transactionkey');
        ibsql.ExecQuery;
      end;

      FIBTransaction.Commit;
      FIBTransaction.StartTransaction;

      //Прописываем класс для каждого типа документов
      ibsql.SQL.Text := 'SELECT * FROM gd_documenttype WHERE classname IS NULL AND ' +
        ' documenttype = ''D'' AND id >= 147000000';
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'UPDATE gd_documenttype t SET classname = ' +
          ' (SELECT tt.classname FROM gd_documenttype tt WHERE tt.id = t.parent) ' +
          ' WHERE classname IS NULL AND documenttype = ''D''';
        Log('GD_DOCUMENTTYPE: Обновление поля classname');
        ibsql.ExecQuery;
      end;
      FIBTransaction.Commit;
      FIBTransaction.StartTransaction;

      //Изменяем imgindex = 17 на imgindex = 0
      // Сделано по указанию Киреева
      ibsql.SQL.Text := 'SELECT * FROM gd_command WHERE imgindex=17 ';
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'UPDATE gd_command SET imgindex=0 WHERE imgindex=17';
        Log('GD_COMMAND: Обновление поля imgindex');
        ibsql.ExecQuery;
      end;
      FIBTransaction.Commit;

    except
      on E: Exception do
      begin
        if FIBTransaction.InTransaction then
          FIBTransaction.Rollback;
        Log('Ошибка: ' + E.Message);
      end;
    end;
  finally
    ibsql.Free;
    FIBTransaction.Free;
  end;
end;

end.
