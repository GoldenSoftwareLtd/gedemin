unit mdf_Delete_BITrigger_AtSettingPos;

interface

uses
  IBDatabase, gdModify, IBSQL, SysUtils;

procedure DeleteBITRiggerAtSettingPos(IBDB: TIBDatabase; Log: TModifyLog);
procedure DeleteMetaDataSimpleTableAtSettingPos(IBDB: TIBDatabase; Log: TModifyLog);
procedure DeleteMetaDataTableToTableAtSettingPos(IBDB: TIBDatabase; Log: TModifyLog);
procedure DeleteMetaDataTreeTableAtSettingPos(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  gdcTableMetaData;

procedure DeleteBITRiggerAtSettingPos(IBDB: TIBDatabase; Log: TModifyLog);
var
  SQL, q: TIBSQL;
  Tr: TIBTransaction;
  TempS: String;
  Deleted: Integer;
begin
  Deleted := 0;
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT r.relationname ' +
      'FROM  at_settingpos  t ' +
      '  JOIN gd_ruid g on g.xid = t.xid and g.dbid = t.dbid ' +
      '  JOIN at_relations r on r.id = g.id '+
      'WHERE t.objectclass = ''TgdcPrimeTable'' AND r.relationname LIKE ''USR$%'' ';
    try
      q.ExecQuery;

      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := Tr;

        while not q.EOF do
        begin
          TempS := GetBaseTableBITriggerName(q.FieldByName('relationname').AsString, Tr);

          SQL.Close;
          SQL.SQL.Text :=
            'DELETE FROM at_settingpos t ' +
            'WHERE ' +
            '  t.objectclass = ''TgdcTrigger'' ' +
            '  AND t.objectname = :o1';
          SQL.ParamByName('o1').AsString := TempS;
          SQL.ExecQuery;

          Deleted := Deleted + SQL.RowsAffected;
          q.Next;
        end;

        SQL.Close;
        SQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (146, ''0000.0001.0000.0177'', ''11.04.2012'', ''Delete system triggers of prime tables from at_settingpos.'') ' +
          '  MATCHING (id)';
        SQL.ExecQuery;

        SQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (148, ''0000.0001.0000.0179'', ''16.04.2012'', ''Delete system triggers of prime tables from at_settingpos. #2'') ' +
          '  MATCHING (id)';
        SQL.ExecQuery;

        Tr.Commit;
      finally
        SQL.Free;
      end;

      if Deleted > 0 then
        Log('Удалено триггеров Простой таблицы с ИД из at_settingpos: ' + IntToStr(Deleted));
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure DeleteMetaDataSimpleTableAtSettingPos(IBDB: TIBDatabase; Log: TModifyLog);
var
  SQL, q: TIBSQL;
  Tr: TIBTransaction;
  SimpleTableMetaNames: TBaseTableTriggersName;
  Deleted: Integer;
begin
  Deleted := 0;
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT r.relationname ' +
      'FROM  at_settingpos  t ' +
      '  JOIN gd_ruid g on g.xid = t.xid and g.dbid = t.dbid ' +
      '  JOIN at_relations r on r.id = g.id '+
      'WHERE t.objectclass = ''TgdcSimpleTable'' AND r.relationname LIKE ''USR$%'' ';
    try
      q.ExecQuery;

      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := Tr;

        while not q.eof do
        begin
          GetBaseTableTriggersName(q.FieldByName('relationname').AsString, Tr, SimpleTableMetaNames);

          SQL.Close;
          SQL.SQL.Text :=
            'DELETE FROM at_settingpos t ' +
            'WHERE ' +
            '  t.objectclass = ''TgdcTrigger'' ' +
            '  AND (t.objectname = :o1 OR t.objectname = :o2 OR t.objectname = :o3)';
          SQL.ParamByName('o1').AsString := SimpleTableMetaNames.BITriggerName;
          SQL.ParamByName('o2').AsString := SimpleTableMetaNames.BI5TriggerName;
          SQL.ParamByName('o3').AsString := SimpleTableMetaNames.BU5TriggerName;
          SQL.ExecQuery;

          Deleted := Deleted + SQL.RowsAffected;
          q.Next;
        end;

        SQL.Close;
        SQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (147, ''0000.0001.0000.0178'', ''16.04.2012'', ''Delete system metadada of simple tables from at_settingpos.'') ' +
          '  MATCHING (id)';
        SQL.ExecQuery;

        SQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (149, ''0000.0001.0000.0180'', ''16.04.2012'', ''Delete system metadada of simple tables from at_settingpos. #2'') ' +
          '  MATCHING (id)';
        SQL.ExecQuery;

        Tr.Commit;
      finally
        SQL.Free;
      end;

      if Deleted > 0 then
        Log('Удалено триггеров Простой таблицы из at_settingpos: ' + IntToStr(Deleted));
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure DeleteMetaDataTableToTableAtSettingPos(IBDB: TIBDatabase; Log: TModifyLog);
var
  SQL, q: TIBSQL;
  Tr: TIBTransaction;
  TempS: String;
  Deleted: Integer;
begin
  Deleted := 0;
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT r.relationname ' +
      'FROM  at_settingpos  t ' +
      '  JOIN gd_ruid g on g.xid = t.xid and g.dbid = t.dbid ' +
      '  JOIN at_relations r on r.id = g.id '+
      'WHERE t.objectclass = ''TgdcTableToTable'' AND r.relationname LIKE ''USR$%'' ';
    try
      q.ExecQuery;

      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := Tr;

        while not q.EOF do
        begin
          TempS := GetBaseTableBITriggerName(q.FieldByName('relationname').AsString, Tr);

          SQL.Close;
          SQL.SQL.Text :=
            'DELETE FROM at_settingpos t ' +
            'WHERE ' +
            '  t.objectclass = ''TgdcTrigger'' ' +
            '  AND t.objectname = :o1';
          SQL.ParamByName('o1').AsString := TempS;
          SQL.ExecQuery;

          Deleted := Deleted + SQL.RowsAffected;
          q.Next;
        end;

        SQL.Close;
        SQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (150, ''0000.0001.0000.0181'', ''16.04.2012'', ''Delete system triggers of tabletotable tables from at_settingpos.'') ' +
          '  MATCHING (id)';
        SQL.ExecQuery;

        Tr.Commit;
      finally
        SQL.Free;
      end;

      if Deleted > 0 then
        Log('Удалено триггеров Таблицы со ссылкой из at_settingpos: ' + IntToStr(Deleted));
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure DeleteMetaDataTreeTableAtSettingPos(IBDB: TIBDatabase; Log: TModifyLog);
var
  SQL, q: TIBSQL;
  Tr: TIBTransaction;
  TreeTableMetaNames: TBaseTableTriggersName;
  Deleted: Integer;
begin
  Deleted := 0;
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT r.relationname ' +
      'FROM  at_settingpos  t ' +
      '  JOIN gd_ruid g on g.xid = t.xid and g.dbid = t.dbid ' +
      '  JOIN at_relations r on r.id = g.id '+
      'WHERE t.objectclass = ''TgdcTreeTable'' AND r.relationname LIKE ''USR$%'' ';
    try
      q.ExecQuery;

      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := Tr;

        while not q.eof do
        begin
          GetBaseTableTriggersName(q.FieldByName('relationname').AsString, Tr, TreeTableMetaNames);

          SQL.Close;
          SQL.SQL.Text :=
            'DELETE FROM at_settingpos t ' +
            'WHERE ' +
            '  t.objectclass = ''TgdcTrigger'' ' +
            '  AND (t.objectname = :o1 OR t.objectname = :o2 OR t.objectname = :o3)';
          SQL.ParamByName('o1').AsString := TreeTableMetaNames.BITriggerName;
          SQL.ParamByName('o2').AsString := TreeTableMetaNames.BI5TriggerName;
          SQL.ParamByName('o3').AsString := TreeTableMetaNames.BU5TriggerName;
          SQL.ExecQuery;

          Deleted := Deleted + SQL.RowsAffected;
          q.Next;
        end;

        SQL.Close;
        SQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (151, ''0000.0001.0000.0182'', ''16.04.2012'', ''Delete system metadada of tree tables from at_settingpos.'') ' +
          '  MATCHING (id)';
        SQL.ExecQuery;

        Tr.Commit;
      finally
        SQL.Free;
      end;

      if Deleted > 0 then
        Log('Удалено триггеров Таблицы простое дерево из at_settingpos: ' + IntToStr(Deleted));
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

end.
