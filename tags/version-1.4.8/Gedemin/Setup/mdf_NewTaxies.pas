unit mdf_NewTaxies;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit;

procedure NewTaxies(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript, wiz_FunctionBlock_unit, classes, prm_ParamFunctions_unit,
  gd_common_functions;

const
  GD_TAXFUNCTION: TmdfTable = (TableName: 'GD_TAXFUNCTION';
    Description: '');
  FieldCount = 6;
  Fields: array[0..FieldCount - 1] of TmdfField = (
    (RelationName: 'AC_AUTOTRRECORD'; FieldName: 'IMAGEINDEX'; Description: 'DINTEGER'),
    (RelationName: 'AC_AUTOTRRECORD'; FieldName: 'FOLDERKEY'; Description:
      'DFOREIGNKEY REFERENCES GD_COMMAND(id)'),
    (RelationName: 'GD_TAXACTUAL'; FieldName: 'TRRECORDKEY'; Description: 'DFOREIGNKEY REFERENCES AC_AUTOTRRECORD(ID) ON UPDATE CASCADE'),
    (RelationName: 'GD_TAXNAME'; FieldName: 'TRANSACTIONKEY'; Description: 'DFOREIGNKEY REFERENCES AC_TRANSACTION(ID)'),
    (RelationName: 'GD_TAXRESULT'; FieldName: 'NAME'; Description: 'DTEXT60'),
    (RelationName: 'GD_TAXRESULT'; FieldName: 'DESCRIPTION'; Description: 'DTEXT1024')
    );

  TAXFUNCTIONKEY: TmdfField = (
    RelationName: 'GD_TAXRESULT'; FieldName: 'TAXFUNCTIONKEY'; Description: '');
  RESULTTYPE: TmdfField = (
    RelationName: 'GD_TAXRESULT'; FieldName: 'RESULTTYPE'; Description: ''
    );
  GD_IDX_TAXRESULT: TmdfIndex = (RelationName: 'GD_TAXRESULT'; IndexName: 'GD_IDX_TAXRESULT';
    Columns: ''; Unique: False; Sort: stAsc);

function CreateTaxFunction(IBDB: TIBDatabase; Log: TModifyLog): boolean;
var
  Transaction: TIBTransaction;
  taSQL, taUpdateSQL, trSQL, fSQL, tfSQL, tnSQL: TIBSQL;
  SB: TScriptBlock;
  F, V: TVisualBlock;
  FunctionKey, TrRecordKey: Integer;
  Top: Integer;
  Template: TStream;
  TrName: string;
  TransactionKey: Integer;
//  I: Integer;
begin
  Result := False;
  if RelationExist(GD_TAXFUNCTION, IBDB) then
  begin
    Transaction := TIBTransaction.Create(nil);
    try
      Transaction.DefaultDatabase := IBDB;
      Transaction.StartTransaction;
      try
        taSQL := TIBSQL.Create(nil);
        trSQL := TIBSQL.Create(nil);
        fSQL := TIBSQL.Create(nil);
        tfSQL := TIBSQL.Create(nil);
        taUpdateSQL := TIBSQL.Create(nil);
        tnSQL := TIBSQL.Create(nil);
        try
          taSQL.Transaction := Transaction;
          taSQL.SQL.Text := 'SELECT * FROM ac_transaction WHERE id = 807002';
          taSQL.ExecQuery;
          if taSQL.RecordCount = 0 then
          begin
            taSQL.Close;
            taSQL.SQL.Text := 'INSERT INTO ac_transaction (id, parent, name, autotransaction) ' +
              'VALUES(807002, null, ''Налоги'', 1)';
            taSQL.ExecQuery;
          end;
          TransactionKey := 807002;

          taSQL.Close;
          taSQL.SQL.Text := 'SELECT ta.*, tn.name FROM gd_taxactual ta JOIN gd_taxname tn ON tn.id = ta.taxnamekey WHERE EXISTS(SELECT * ' +
            'FROM gd_taxfunction tf WHERE tf.taxactualkey = ta.id)';
          taSQL.ExecQuery;
          trSQL.Transaction := Transaction;
          trSQL.SQL.Text := 'INSERT INTO ac_autotrrecord (id, editorkey, afull, achag,' +
            'aview, transactionkey, description, functionkey, functiontemplate) VALUES(:id, ' +
            '650002, -1, -1, -1, :transactionkey, :description, :functionkey, :functiontemplate)';
          fSQL.Transaction := Transaction;
          fSQL.SQL.Text := 'INSERT INTO gd_function (id, name, afull, achag, aview, ' +
            'script, publicfunction, modulecode, editorkey, module, language) VALUES (' +
            ':id, :name, -1, -1, -1, :script, 0, 1010001, 650002, ''ENTRY'', ''VBScript'')';
          tfSQL.Transaction := Transaction;
          tfSQL.SQL.Text := 'SELECT * FROM gd_taxfunction WHERE taxactualkey = :taxactualkey ORDER BY id';

          taUpdateSQL.Transaction := Transaction;
          taUpdateSQL.SQL.Text := 'UPDATE gd_taxactual SET trrecordkey = :trrecordkey WHERE id = :id';

          tnSQL.Transaction := Transaction;
          tnSQl.SQL.Text := 'UPDATE gd_taxname SET transactionkey = :transactionkey WHERE id =:id AND transactionkey IS NULL';
          while not taSQL.Eof do
          begin
            if taSQL.FieldByName('trrecordkey').AsInteger = 0 then
            begin
              FunctionKey := GenId(IBDB);
              TrRecordKey := GenId(IBDb);
              SB := TScriptBlock.Create(nil);
              try
                F := TTaxFunctionBlock.Create(SB);
                with F as TTaxFunctionBlock do
                begin
                  FunctionParams.AddParam('BeginDate', 'Начало периода', prmDate, 'Начало периода');
                  FunctionParams.AddParam('EndDate', 'Конец периода', prmDate, 'Конец периода');
                  Parent := Sb;
                  BlockName := Format('AutoEntryFunction_%s', [GetRUIDStringByID(TrRecordKey, Transaction)]);
                  CannotDelete := True;
                  TaxActualRuid := GetRUIDStringByID(taSQL.FieldByName('id').AsInteger, Transaction);
                  TaxNameRuid := GetRUIDStringByID(taSQL.FieldByName('taxnamekey').AsInteger, Transaction);
                end;

                Top := 0;
                tfSQL.ParamByName('taxactualkey').AsInteger := taSQL.FieldByName('id').AsInteger;
                tfSQL.ExecQuery;
                try
                  while not tfSQL.Eof do
                  begin
                    V := TTaxVarBlock.Create(SB);
                    V.Parent := F;
                    V.BlockName := tfSQL.FieldByName('name').AsString;
                    TTaxVarBlock(V).Expression := StringReplace(tfSQL.FieldByName('taxfunction').AsString, #13#10, ' ', [rfReplaceAll]);
                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, '[GS.BPeriod]', 'BeginDate', [rfReplaceAll, rfIgnoreCase]);
                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, '[GS.EPeriod]', 'EndDate', [rfReplaceAll, rfIgnoreCase]);

                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.AccBalance', 'GS.SALDO', [rfReplaceAll, rfIgnoreCase]);
                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.DebitCircul', 'GS.OD', [rfReplaceAll, rfIgnoreCase]);
                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.CreditCircul', 'GS.OK', [rfReplaceAll, rfIgnoreCase]);
                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.CorrCircul', 'GS.O', [rfReplaceAll, rfIgnoreCase]);
                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.CrBalance', 'GS.SK', [rfReplaceAll, rfIgnoreCase]);
                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.DebBalance', 'GS.SD', [rfReplaceAll, rfIgnoreCase]);

                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.CrCurrBalance', 'GS.V_SK', [rfReplaceAll, rfIgnoreCase]);
                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.CreditCurrCircul', 'GS.V_OK', [rfReplaceAll, rfIgnoreCase]);
                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.DebCurrBalance', 'GS.V_SD', [rfReplaceAll, rfIgnoreCase]);
                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.DebitCurrCircul', 'GS.V_OD', [rfReplaceAll, rfIgnoreCase]);

                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.QuantCorrCircul', 'GS.K_O', [rfReplaceAll, rfIgnoreCase]);
                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.QuantCrBalance', 'GS.K_SK', [rfReplaceAll, rfIgnoreCase]);
                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.QuantCreditCircul', 'GS.K_OK', [rfReplaceAll, rfIgnoreCase]);
                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.QuantDebBalance', 'GS.K_SD', [rfReplaceAll, rfIgnoreCase]);
                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.QuantDebitCircul', 'GS.K_OD', [rfReplaceAll, rfIgnoreCase]);

                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.MBegin', 'GS.NM', [rfReplaceAll, rfIgnoreCase]);
                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.MEnd', 'GS.KM', [rfReplaceAll, rfIgnoreCase]);
                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.QBegin', 'GS.NK', [rfReplaceAll, rfIgnoreCase]);

                    TTaxVarBlock(V).Expression := StringReplace(TTaxVarBlock(V).Expression, 'GS.YBegin', 'GS.NG', [rfReplaceAll, rfIgnoreCase]);

                    V.Description := tfSQL.FieldByName('description').AsString;

                    V.Top := Top;

                    Top := Top + V.Height + 5;
                    tfSQL.Next;
                  end;
                finally
                  tfSQL.Close;
                end;

                Template := TMemoryStream.Create;
                try
                  SaveLabelToStream(cWizLb, Template);

                  SaveIntegerToStream(1, Template);
                  SB.SaveToStream(Template);

                  TrName := Format('%s(%s)',
                    [taSQL.FieldByName('name').AsString,
                    taSQL.FieldByName('actualdate').AsString]);
                  fSQL.ParamByName('id').AsInteger := FunctionKey;
                  fSQL.ParamByName('name').AsString := F.BlockName;
                  fSQL.ParamByName('script').AsString := Format(
                    'sub %s'#13#10'  msgbox "Пожалуйста пересоздайте данную " + ' +
                    'Chr(13) + Chr(10) + "функцию в автом. хоз операции %s"'#13#10'end sub',
                    [F.BlockName, TrName]);
                  fSQL.ExecQuery;
                  fSQL.Close;

                  trSQL.ParamByName('id').AsInteger := TrRecordKey;
                  trSQL.ParamByName('transactionkey').AsInteger := TransactionKey;
                  trSQL.ParamByName('description').AsString := TrName;
                  trSQL.ParamByName('functionkey').AsInteger := FunctionKey;
                  if Template.Size > 0 then
                  begin
                    Template.Position := 0;
                    trSQL.ParamByName('functiontemplate').LoadFromStream(Template);
                  end;
                finally
                  Template.Free;
                end;

                trSQL.ExecQuery;
                trSQL.Close;

                taUpdateSQL.ParamByName('id').AsInteger := taSQL.FieldByName('id').AsInteger;
                taUpDateSQl.ParamByName('trrecordkey').AsInteger := TrRecordKey;
                taUpdateSQL.ExecQuery;

                tnSQL.ParamByName('id').AsInteger := taSQL.FieldByName('taxnamekey').AsInteger;
                tnSQl.ParamByName('transactionkey').AsInteger := Transactionkey;
                tnSQL.ExecQuery;
              finally
                SB.Free;
              end;
            end;
            taSQL.Next;
          end;
          Transaction.Commit;
          Result := True;
        finally
          taSQL.Free;
          trSQL.Free;
          fSQL.Free;
          tfSQL.Free;
          taUpdateSQL.Free;
          tnSQL.Free;
        end;
      except
        Transaction.RollBack;
      end
    finally
      Transaction.Free;
    end;
  end;
end;

procedure NewTaxies(IBDB: TIBDatabase; Log: TModifyLog);
var
  I: Integer;
begin
  for I := 0 to FieldCount - 1 do
  begin
    if not FieldExist(Fields[i], IBDB) then
    begin
      Log(Format('Добавление поля %s в таблицу %s', [Fields[i].FieldName,
        Fields[I].RelationName]));
      try
        AddField(Fields[I], IBDB);
        Log('succes');
      except
        on E: Exception do
          Log(E.Message);
      end;
    end;
  end;

  if CreateTaxFunction(IBDB, Log) then
  begin
    if IndexExist(GD_IDX_TAXRESULT, IBDB) then
    begin
      try
        DropIndex(GD_IDX_TAXRESULT, IBDB);
      except
        on E: Exception do
          Log(E.Message);
      end;
    end;

    if FieldExist(TAXFUNCTIONKEY, IBDB) then
    begin
      Log('Удаление taxfunctionkey');
      try
        DropField(TAXFUNCTIONKEY, IBDB);
        Log('succes');
      except
        on E: Exception do
          Log(E.Message);
      end;
    end;

    if FieldExist(RESULTTYPE, IBDB) then
    begin
      Log('Удаление resulttype');
      try
        DropField(RESULTTYPE, IBDB);
        Log('succes');
      except
        on E: Exception do
          Log(E.Message);
      end;
    end;

    if RelationExist(GD_TAXFUNCTION, IBDB) then
    begin
      Log('Удаление gd_taxfunction');
      try
        DropRelation(GD_TAXFUNCTION, IBDB);
        Log('succes');
      except
        on E: Exception do
          Log(E.Message);
      end;
    end;
  end;
end;

end.
