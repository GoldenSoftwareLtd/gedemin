unit mdf_NewTrEntries;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit, mdf_dlgDefaultCardOfAccount_unit, Forms,
  Windows, Controls;

procedure NewTrEntries(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript, wiz_FunctionBlock_unit, classes, prm_ParamFunctions_unit,
  gd_common_functions;

const
  AC_V_TRENTRYRECORD: TmdfView = (ViewName: 'AC_V_TRENTRYRECORD');
  AlterFieldCount = 1;
  AlterFields: array[0..AlterFieldCount - 1] of TmdfField = (
    (RelationName: 'AC_TRRECORD'; FieldName: 'DOCUMENTTYPEKEY'; Description: 'TYPE DFOREIGNKEY')
  );

  AlterConstraintCount = 3;
  AlterConstraints: array[0..AlterConstraintCount -  1] of TmdfConstraint = (
    (TableName: 'AC_AUTOENTRY'; ConstraintName: 'FK_AC_AUTOENTRY_TRRECORDKEY';
      Description: ' FOREIGN KEY (TRRECORDKEY) REFERENCES AC_TRRECORD(ID)'),
    (TableName: 'AC_AUTOTRRECORD'; ConstraintName: 'FK_AC_AUTOTRRECORD_ID';
      Description: ' FOREIGN KEY (ID) REFERENCES AC_TRRECORD(ID)'),
    (TableName: 'AC_TRRECORD'; ConstraintName: 'FK_AC_TRRECORD_ACCOUNTKEY';
      Description: ' FOREIGN KEY (ACCOUNTKEY) REFERENCES AC_ACCOUNT(ID)')
  );
  FieldCount = 3;
  Fields: array[0..FieldCount - 1] of TmdfField = (
    (RelationName: 'AC_TRRECORD'; FieldName: 'FUNCTIONTEMPLATE'; Description: 'DBLOB80'),
    (RelationName: 'AC_TRRECORD'; FieldName: 'DOCUMENTPART'; Description:
      'DTEXT10'),
    (RelationName: 'GD_TAXNAME'; FieldName: 'ACCOUNTKEY'; Description:
      'DFOREIGNKEY NOT NULL REFERENCES AC_ACCOUNT(ID)')
  );
  DropFieldCount = 8;
  FunctionTemplateIndex = 7;
  DropFields: array[0..DropFieldCount - 1] of TmdfField = (
    (RelationName: 'AC_AUTOTRRECORD'; FieldName: 'DISABLED'; Description: ''),
    (RelationName: 'AC_AUTOTRRECORD'; FieldName: 'ACHAG'; Description: ''),
    (RelationName: 'AC_AUTOTRRECORD'; FieldName: 'AFULL'; Description: ''),
    (RelationName: 'AC_AUTOTRRECORD'; FieldName: 'AVIEW'; Description: ''),
    (RelationName: 'AC_AUTOTRRECORD'; FieldName: 'TRANSACTIONKEY'; Description: ''),
    (RelationName: 'AC_AUTOTRRECORD'; FieldName: 'DESCRIPTION'; Description: ''),
    (RelationName: 'AC_AUTOTRRECORD'; FieldName: 'FUNCTIONKEY'; Description: ''),
    (RelationName: 'AC_AUTOTRRECORD'; FieldName: 'FUNCTIONTEMPLATE'; Description: '')
  );

function ConvertAutoTrrecord(IBDB: TIBDatabase; Log: TModifyLog): boolean;
var
  Transaction: TIBTransaction;
  SQL, InsertSQL: TIBSQl;
  Str: TStream;
  I: Integer;
begin
  Result := False;
  if FieldExist(DropFields[FunctionTemplateIndex], IBDb) then
  begin
    Transaction := TIBTransaction.Create(nil);
    try
      Transaction.DefaultDataBase := IBDB;
      Transaction.StartTransaction;
      try
        SQL := TIBSQL.Create(nil);
        try
          SQL.Transaction := Transaction;
          SQl.SQl.Text := 'SELECT * FROM ac_autotrrecord';
          SQL.ExecQuery;
          if SQL.RecordCount > 0 then
          begin
            InsertSQL := TIBSQL.Create(nil);
            try
              InsertSQL.Transaction := Transaction;
              InsertSQl.SQl.Text := 'INSERT INTO ac_trrecord (id, transactionkey, description,' +
                'afull, achag, aview, disabled, functionkey, functiontemplate) ' +
                'VALUES (:id, :transactionkey, :description, :afull, :achag, :aview, ' +
                ':disabled, :functionkey, :functiontemplate)';
              while not SQL.Eof do
              begin
                for I := 0 to DropFieldCount - 1 do
                begin
                  if DropFields[i].RelationName = 'AC_AUTOTRRECORD' then
                  begin
                    if I <> FunctionTemplateIndex then
                    begin
                      try
                        //Поле с заданным именем может небыть в СКЛ запросе
                        InsertSQL.ParamByName(DropFields[I].FieldName).Value :=
                          SQL.FieldByName(DropFields[I].FieldName).Value
                      except
                      end;
                    end else
                    begin
                      Str := TMemoryStream.Create;
                      try
                        SQL.FieldByName(DropFields[I].FieldName).SaveToStream(Str);

                        Str.Position := 0;
                        InsertSQL.ParamByName(DropFields[I].FieldName).LoadFromStream(Str);
                      finally
                        Str.Free;
                      end;
                    end;
                  end;
                end;
                InsertSQl.ParamByName('id').AsInteger := SQl.FieldByName('id').AsInteger;
                InsertSQl.ExecQuery;
                SQL.Next;
              end;
            finally
              InsertSQL.Free;
            end;
          end;
        finally
          SQL.Free;
        end;
        Transaction.Commit;
        Result := True;
      except
        Transaction.RollBack;
        Result := False;
      end;
    finally
      Transaction.Free;
    end;
  end;
end;

procedure ConvertOldTrEntries(IBDB: TIBDatabase; Log: TModifyLog);
var
  Transaction: TIBTransaction;
  SQL, TrEntrySQL, FunctionSQL, UpdateSQL, InsertFunctionSQL: TIBSQl;
  DeleteEntrySQL, InsertAddSQl: TIBSQL;
  Str: TStream;
  Count: Integer;
//  DebitCount, CreditCount: Integer;
  OldBody, NewBody: string;
  FunctionId: Integer;
  SB: TScriptBlock;
  F, V: TVisualBlock;
  FunctionScript: String;
  trExecSingleQueryID: Integer;
begin
  if FieldExist(DropFields[FunctionTemplateIndex], IBDb) then
  begin
    Transaction := TIBTransaction.Create(nil);
    try
      Transaction.DefaultDataBase := IBDB;
      Transaction.StartTransaction;
      try
        SQL := TIBSQL.Create(nil);
        TrEntrySQL := TIBSQL.Create(nil);
        FunctionSQL := TIBSQL.Create(nil);
        InsertFunctionSQL := TIBSQL.Create(nil);
        UpdateSQL := TIBSQL.Create(nil);
        DeleteEntrySQl := TIBSQl.Create(nil);
        InsertAddSQl := TIBSQL.Create(nil);
        try
          UpdateSQL.Transaction := Transaction;
          UpdateSQl.SQL.text := 'UPDATE ac_trrecord SET functionkey = :functionkey, functiontemplate = :functiontemplate WHERE id =:id';
          DeleteEntrySQl.Transaction := Transaction;
          try
            DeleteEntrySQl.SQl.Text := 'DELETE FROM ac_script';
            DeleteEntrySQl.ExecQuery;
            DeleteEntrySQl.SQl.Text := 'DROP TRIGGER AC_AF_TRENTRY';
            DeleteEntrySQL.ExecQuery;
            Transaction.Commit;
            Transaction.StartTransaction;
          except
            if not Transaction.InTransaction then Transaction.StartTransaction;
          end;
          DeleteEntrySQL.SQl.Text := 'DELETE FROM ac_trentry WHERE trrecordkey = :trrecordkey';

          SQL.Transaction := Transaction;
          SQL.SQL.Text := 'SELECT DISTINCT r.id, r.transactionkey, r.issavenull FROM ac_trrecord r JOIN ac_trentry e ON e.trrecordkey = r.id';
          SQL.ExecQuery;
          if SQL.RecordCount > 0 then
          begin
            TrEntrySQL.Transaction := Transaction;
            TrEntrySQL.SQL.Text := 'SELECT e.*, a.alias FROM ac_trentry e JOIN ac_account a On a.id = e.accountkey WHERE e.trrecordkey = :trrecordkey ORDER BY e.functionkey';
            FunctionSQL.Transaction := Transaction;
            FunctionSQL.SQl.Text := 'SELECT id FROM gd_function WHERE UPPER(name) = UPPER(''tr_ExecSingleQuery'') AND modulecode = 1010001';
            FunctionSQl.ExecQuery;
            trExecSingleQueryID := FunctionSQl.FieldByName('id').AsInteger;
            FunctionSQl.Close;

            FunctionSQL.SQL.Text := 'SELECT * FROM gd_function WHERE id = :id';
            InsertFunctionSQL.Transaction := Transaction;
            InsertFunctionSQL.SQl.Text := 'INSERT INTO gd_function (id, name, afull, achag, aview, ' +
              'script, publicfunction, modulecode, editorkey, module, language) VALUES (' +
              ':id, :name, -1, -1, -1, :script, 0, 1010001, 650002, ''ENTRY'', ''VBScript'')';

            InsertAddSQl.Transaction := Transaction;
            InsertAddSQl.SQl.Text := 'INSERT INTO RP_ADDITIONALFUNCTION (mainfunctionkey, ADDFUNCTIONKEY) VALUES (:main, :add)';
            while not SQL.Eof do
            begin
              NewBody := '';
              OldBody := '';
              SB := TScriptBlock.Create(nil);
              try
                F := TTrEntryFunctionBlock.Create(SB);
                with F as TTrEntryFunctionBlock do
                begin
                  FunctionParams.AddParam('gdcEntry', 'бизнес объект проводки', prmDate, '');
                  FunctionParams.AddParam('gdcDocument', 'бизнес объект документа', prmDate, '');
                  Parent := Sb;
                  BlockName := Format('AutoEntryFunction_%s', [GetRUIDStringByID(SQL.FieldByName('id').AsInteger, Transaction)]);
                  CannotDelete := True;
                end;


                TrEntrySQL.ParamByName('trrecordkey').AsInteger := SQL.FieldByName('id').AsInteger;
                TrEntrySQL.ExecQuery;
                try
                  Count := 0;
                  NewBody :=
                    'RecordKey = gdcEntry.GetNextId(True)'#13#10 +
                    'IsZero = True'#13#10 + 'DebitNcu = 0'#13#10 +
                    'CreditNcu = 0'#13#10 + 'DebitCurr = 0'#13#10 +
                    'CreditCurr = 0'#13#10;

                  while not TrEntrySQL.Eof do
                  begin
                    NewBody := NewBody + #13#10 +
                      'gdcEntry.Insert'#13#10 +
                      'gdcEntry.FieldByName("recordkey").AsInteger = RecordKey'#13#10 +
                      Format('gdcEntry.FieldByName("accountkey").AsInteger = gdcBaseManager.GetIdByRUIDString("%s") ''%s'#13#10,
                        [GetRUIDStringByID(TrEntrySQl.FieldByName('accountkey').AsInteger, Transaction), TrEntrySQl.FieldByName('alias').AsString]) + #13#10 +
                      Format('gdcEntry.FieldByName("accountpart").AsString = "%s"', [TrEntrySQL.FieldByName('accountpart').AsString]);

                    Inc(Count);
                    FunctionSQL.ParamByName('id').AsInteger := TrEntrySQL.FieldByName('functionkey').AsInteger;
                    FunctionSQL.ExecQuery;
                    try
                      if FunctionSQL.RecordCount > 0 then
                      begin
                        OldBody := StringReplace(FunctionSQL.FieldByName('script').AsString, 'end sub', '', [rfReplaceAll, rfIgnoreCase]);
                        OldBody := StringReplace(OldBody, 'sub', '''', [rfReplaceAll, rfIgnoreCase])
                      end else
                      begin
                        if Count <> 2 then
                          OldBody := '';
                      end;
                    finally
                      FunctionSQL.Close;
                    end;

                    NewBody := NewBody + #13#10 + OldBody;
                    NewBody := NewBody +
                      'gdcEntry.Post'#13#10 +
                      'IsZero = IsZero and (gdcEntry.FieldByName("debitncu").AsCurrency = 0) and _'#13#10 +
                      '  (gdcEntry.FieldByName("creditncu").AsCurrency = 0) and _'#13#10 +
                      '  (gdcEntry.FieldByName("debitcurr").AsCurrency = 0) and _'#13#10 +
                      '  (gdcEntry.FieldByName("creditcurr").AsCurrency = 0)'#13#10 +
                      'DebitNcu = DebitNcu + gdcEntry.FieldByName("debitncu").AsCurrency'#13#10 +
                      'CreditNcu = CreditNcu + gdcEntry.FieldByName("creditncu").AsCurrency'#13#10 +
                      'DebitCurr = DebitCurr + gdcEntry.FieldByName("debitcurr").AsCurrency'#13#10 +
                      'CreditCurr = CreditCurr + gdcEntry.FieldByName("creditcurr").AsCurrency';
                    TrEntrySQL.Next;
                  end;

                  NewBody := NewBody + #13#10 +
                    'if (DebitNcu <> CreditNcu) or (DebitCurr <> CreditCurr) then'#13#10 +
                    '  call Exception.Raise("Exception", "Сумма по дебету не равна сумме по кредиту!" + Chr(13) + Chr(10) + _'#13#10 +
                    '    "Проверьте настройку типовой операции." + Chr(13) + Chr(10))'#13#10 +
                    'end if';

                  if SQL.FieldByName('issavenull').AsInteger = 0 then
                  begin
                    NewBody := NewBody + #13#10 +
                      'if IsZero then '#13#10 +
                      '  gdcEntry.Close'#13#10 +
                      '  call gdcBaseManager.ExecSingleQuery("DELETE FROM ac_record WHERE id = (" + _ '#13#10 +
                      '    CStr(RecordKey) + ")", Transaction )'#13#10 +
                      '  gdcEntry.Open'#13#10 +
                      'end if'
                  end;
                  V := TUserBlock.Create(SB);
                  V.Parent := F;
                  V.BlockName := V.GetUniqueName;
                  TUserBlock(V).Script.Text := NewBody;
                finally
                  TrEntrySQL.Close;
                end;
                FunctionScript :=
                  Format('function %s(gdcEntry, gdcDocument)'#13#10, [F.BlockName]) +
                  'IsZero = True'#13#10 +
                  'Result = False'#13#10 +
                  'set Transaction = gdcDocument.Transaction'#13#10 +
                  Format('Except Except%s(gdcEntry)'#13#10, [F.BlockName]) +
                  NewBody + #13#10 +
                  'end function'#13#10 +
                  Format('sub Except%s (gdcEntry)'#13#10, [F.BlockName]) +
                  '  if (gdcEntry.State = 2) or (gdcEntry.State = 3) then gdcEntry.Cancel'#13#10 +
                  'end sub';

                  FunctionId := GenId(IBDB);
                  InsertFunctionSQL.ParamByName('id').AsInteger := FunctionId;
                  InsertFunctionSQL.ParamByName('script').AsString := FunctionScript;
                  InsertFunctionSQl.ParamByName('name').AsString := F.BlockName;
                  InsertFunctionSQl.ExecQuery;

                  if trExecSingleQueryID > 0 then
                  begin
                    InsertAddSQl.ParamByName('main').AsInteger := FunctionId;
                    InsertAddSQl.ParamByName('add').AsInteger := trExecSingleQueryID;
                    InsertAddSQl.ExecQuery;
                    InsertAddSQl.Close;
                  end;

                  UpdateSQl.ParamByName('id').AsInteger := SQL.FieldByName('id').AsInteger;
                  UpdateSQl.ParamByName('functionkey').AsInteger := FunctionId;
                  Str := TMemoryStream.Create;
                  try
                    SaveLabelToStream(cWizLb, Str);
                    SaveIntegerToStream(1, Str);
                    Sb.SaveToStream(Str);
                    Str.Position := 0;

                    UpdateSQL.ParamByName('functiontemplate').LoadFromStream(Str);
                  finally
                    Str.Free;
                  end;
                  UpdateSQL.ExecQuery;
                  DeleteEntrySQL.ParamByName('trrecordkey').AsInteger := SQl.FieldByName('id').AsInteger;
                  DeleteEntrySQL.ExecQuery;
              finally
                SB.Free;
              end;
              SQL.Next;
            end;
          end;
        finally
          SQL.Free;
          TrEntrySQL.Free;
          FunctionSQL.Free;
          InsertFunctionSQL.Free;
          UpdateSQL.Free;
          DeleteEntrySQL.Free;
          InsertAddSQl.Free;
        end;
        Transaction.Commit;
      except
        Transaction.RollBack;
      end;
    finally
      Transaction.Free;
    end;
  end;
end;


procedure NewTrEntries(IBDB: TIBDatabase; Log: TModifyLog);
var
  I: Integer;
  SQL: TIBSQL;
  Transaction: TIBTransaction;
  D: TdlgCardOfAccount;
begin
  for I := 0 to FieldCount - 1 do
  begin
    if not FieldExist(Fields[i], IBDB) then
    begin
      Log(Format('Добавление поля %s в таблицу %s', [Fields[i].FieldName,
        Fields[I].RelationName]));
      try
        AddField(Fields[I], IBDB);
      except
        on E: Exception do
          Log('Ошибка: ' + E.Message);
      end;
    end;
  end;

  D := TdlgCardOfAccount.Create(nil);
  try
    D.Db := IBDB;
    if D.ShowModal = mrOk then
    begin
      Transaction := TIBTransaction.Create(nil);
      try
        Transaction.DefaultDatabase := IBDB;
        Transaction.StartTransaction;
        try
          SQL := TIBSQL.Create(nil);
          try
            SQl.Transaction := Transaction;

            SQL.SQl.Text := 'UPDATE gd_taxname SET accountkey = :accountkey WHERE accountkey IS NULL';
            SQL.ParamByName('accountkey').AsInteger := D.CardOFAccount;
            SQL.ExecQuery;

            SQL.Close;
            SQL.SQl.Text := 'UPDATE ac_trrecord SET accountkey = :accountkey WHERE accountkey IS NULL';
            SQl.ParamByName('accountkey').AsInteger := D.CardOFAccount;
            SQl.ExecQuery;
          finally
            SQL.Free;
          end;
          Transaction.Commit;
        except
          Transaction.RollBack;
        end;
      finally
        Transaction.Free;
      end;
    end;
  finally
    D.Free;
  end;

  DropView(AC_V_TRENTRYRECORD, IBDB);

  SQL := TIBSQL.Create(nil);
  try
    Transaction := TIBTransaction.Create(nil);
    try
      Transaction.DefaultDataBase := IBDB;
      Transaction.StartTransaction;
      try
        SQL.Transaction := Transaction;
        SQL.SQl.Text := 'update RDB$RELATION_FIELDS set ' +
          'RDB$FIELD_SOURCE = ''DFOREIGNKEY'' ' +
          'where (RDB$FIELD_NAME = ''DOCUMENTTYPEKEY'') and ' +
          '(RDB$RELATION_NAME = ''AC_TRRECORD'')' ;
        SQL.ExecQuery;

        Transaction.Commit;

        try
          IBDB.Connected :=  False;
        finally
          IBDB.Connected :=  True;
        end;
      except
        Transaction.RollBack;
        raise;
      end;
    finally
      Transaction.Free;
    end;
  finally
    SQL.Free;
  end;

  ConvertAutoTrrecord(IBDB, Log);
  ConvertOldTrEntries(IBDB, Log);

  IBDB.Connected := False;
  IBDB.Connected := True;

  for I := 0 to DropFieldCount - 1 do
  begin
    if FieldExist(DropFields[I], IBDB) then
    begin
      Log(Format('Удаление поля %s из таблицы %s', [DropFields[i].FieldName,
        DropFields[I].RelationName]));
      try
        DropField(DropFields[I], IBDB);
      except
        on E: Exception do
          Log('Ошибка: ' + E.Message);
      end;
    end;
  end;

  for I := 0 to AlterConstraintCount - 1 do
  begin
    Log(Format('Добавление внешней ссылки %s в таблицу %s', [AlterConstraints[i].ConstraintName,
      AlterConstraints[I].TableName]));
    try
      DropConstraint(AlterConstraints[I], IBDb);
      AddConstraint(AlterConstraints[I], IBDB);
    except
      on E: Exception do
        Log('Ошибка: ' + E.Message);
    end;
  end;
end;

end.
