
unit Test_gdcMetaData_unit;

interface

uses
  TestFrameWork, gsTestFrameWork, IBDatabase, gdcBase, gdcMetaData;

type
  CgdcStandartTableTest = class of TgdcStandartTableTest;
  TgdcStandartTableTest = class(TgsDBTestCase)
  protected
    FTableName: String;
    FDBState, FDBStateAfterCreate: String;

    function GetTableClass: CgdcTable; virtual; abstract;
    function GetFileName: String;
    procedure InitObject(AnObj: TgdcBase); virtual;

    procedure TestCreateTable; virtual;
    procedure TestMetaData; virtual; abstract;
    procedure TestData; virtual;
    procedure TestAddToSetting;
    procedure TestDrop;
    procedure TestLoadSetting;

  published
    procedure DoTest; virtual;
  end;

  TgdcPrimeTableTest = class(TgdcStandartTableTest)
  protected
    function GetTableClass: CgdcTable; override;
    procedure TestMetaData; override;
  end;

  TgdcSimpleTableTest = class(TgdcStandartTableTest)
  protected
    function GetTableClass: CgdcTable; override;
    procedure TestMetaData; override;
  end;

  TgdcTreeTableTest = class(TgdcSimpleTableTest)
  protected
    function GetTableClass: CgdcTable; override;
  end;

  TgdcTableToTableTest = class(TgdcSimpleTableTest)
  protected
    function GetTableClass: CgdcTable; override;
    procedure InitObject(AnObj: TgdcBase); override;
    procedure TestMetaData; override;
  end;

  TgdcLBRBTreeTest = class(TgdcSimpleTableTest)
  private
    procedure TestRestrLBRBTree;
    procedure TestLBRBTree;
    procedure CheckConsistency(Tr: TIBTransaction);

  protected
    function GetTableClass: CgdcTable; override;
    procedure TestMetaData; override;
    procedure TestData; override;
  end;

  TgdcMetaDataTest = class(TgsDBTestCase)
  published
    procedure TestGD_RUID;
    procedure TestAuditTriggers;
  end;

  TgdcSetTest = class(TgsDBTestCase)
  private
    FDomainName, FTableName, FFieldName, FDBState, FDBStateAfterCreate: String;
    FDomainKey, FTableKey: Integer;
  protected
    procedure CreateTable;
    function GetFileName: String;
    procedure TestCreateDomain;
    procedure TestAddFieldToTable;
    procedure TestAddToSetting;
    procedure TestLoadSetting;
    procedure TestDrop;
  published
    procedure DoTest;
  end;

implementation

uses
  Classes, Windows, DB, IB, gd_security, at_frmSQLProcess,
  IBSQL, gdcBaseInterface, gd_KeyAssoc, SysUtils,
  gdcLBRBTreeMetaData, jclStrings, gdcJournal, gdcSetting,
  gdcTableMetaData, gsStreamHelper;

procedure TgdcMetaDataTest.TestAuditTriggers;
var
  C: Integer;
  Obj: TgdcJournal;
begin
  FQ.SQL.Text := 'SELECT COUNT(*) FROM rdb$triggers';
  FQ.ExecQuery;
  C := FQ.Fields[0].AsInteger;
  FQ.Close;

  Obj := TgdcJournal.Create(nil);
  try
    Obj.CreateTriggers(True);
    Obj.DropTriggers(True);
  finally
    Obj.Free;
  end;

  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = C);

  FQ.Close;
end;

procedure TgdcMetaDataTest.TestGD_RUID;
begin
  FQ.SQL.Text := 'INSERT INTO gd_ruid (id, xid, dbid, modified) VALUES (:id, :xid, :dbid, CURRENT_TIMESTAMP)';

  FQ.ParamByName('id').AsInteger := 147000000;
  FQ.ParamByName('xid').AsInteger := 555000000;
  FQ.ParamByName('dbid').AsInteger := 28;
  FQ.ExecQuery;

  FQ.ParamByName('id').AsInteger := 1;
  FQ.ParamByName('xid').AsInteger := 1;
  FQ.ParamByName('dbid').AsInteger := 17;
  FQ.ExecQuery;

  FQ.ParamByName('id').AsInteger := 0;
  FQ.ParamByName('xid').AsInteger := 0;
  FQ.ParamByName('dbid').AsInteger := 17;
  StartExpectingException(EIBInterBaseError);
  FQ.ExecQuery;
  StopExpectingException('');

  FQ.ParamByName('id').AsInteger := -1;
  FQ.ParamByName('xid').AsInteger := -1;
  FQ.ParamByName('dbid').AsInteger := 17;
  StartExpectingException(EIBInterBaseError);
  FQ.ExecQuery;
  StopExpectingException('');

  FQ.ParamByName('id').AsInteger := 146999999;
  FQ.ParamByName('xid').AsInteger := 146999999;
  FQ.ParamByName('dbid').AsInteger := 17;
  FQ.ExecQuery;

  FQ.ParamByName('id').AsInteger := 146999999;
  FQ.ParamByName('xid').AsInteger := 146999999;
  FQ.ParamByName('dbid').AsInteger := 28;
  StartExpectingException(EIBInterBaseError);
  FQ.ExecQuery;
  StopExpectingException('');

  FQ.ParamByName('id').AsInteger := 146999999;
  FQ.ParamByName('xid').AsInteger := 147999999;
  FQ.ParamByName('dbid').AsInteger := 17;
  StartExpectingException(EIBInterBaseError);
  FQ.ExecQuery;
  StopExpectingException('');
end;

{ TgdcStandartTableTest }

procedure TgdcStandartTableTest.DoTest;
begin
  Check(FTableName = '');
  TestCreateTable;
  TestMetaData;
  TestData;
  TestAddToSetting;
  TestDrop;
  TestLoadSetting;
end;

function TgdcStandartTableTest.GetFileName: String;
var
  TempPath: array[0..1023] of Char;
begin
  Check(FTableName > '');
  GetTempPath(SizeOf(TempPath), TempPath);
  Result := String(TempPath) + '\' + FTableName + '.xml'
end;

procedure TgdcStandartTableTest.InitObject(AnObj: TgdcBase);
begin
  Assert(Assigned(AnObj) and (AnObj.State = dsInsert));
  AnObj.FieldByName('relationname').AsString := FTableName;
end;

procedure TgdcStandartTableTest.TestAddToSetting;
var
  FTable: TgdcTable;
  gdcSetting: TgdcSetting;
  gdcSettingPos: TgdcSettingPos;
begin
  Check(FTableName > '');

  FTable := GetTableClass.Create(nil);
  try
    FTable.SubSet := 'ByName';
    FTable.ParamByName(FTable.GetListField(FTable.SubType)).AsString := FTableName;
    FTable.Open;
    Check(not FTable.EOF);

    gdcSetting := TgdcSetting.Create(nil);
    try
      gdcSetting.Open;
      gdcSetting.Insert;
      gdcSetting.FieldByName('NAME').AsString := FTableName;
      gdcSetting.Post;

      gdcSettingPos := TgdcSettingPos.Create(nil);
      try
        gdcSettingPos.SubSet := 'BySetting';
        gdcSettingPos.ParamByName('settingkey').AsInteger := gdcSetting.ID;
        gdcSettingPos.Open;
        gdcSettingPos.AddPos(FTable, True);
      finally
        gdcSettingPos.Free;
      end;

      gdcSetting.SaveSettingToBlob(sttXML);
      gdcSetting.SaveToFile(GetFileName);

      FQ.Close;
      FQ.SQL.Text := 'SELECT * FROM at_settingpos WHERE settingkey = :sk AND objectclass = ''TgdcTrigger'' ';
      FQ.ParamByName('sk').AsInteger := gdcSetting.ID;
      FQ.ExecQuery;

      Check(FQ.EOF);

      gdcSetting.Delete;
    finally
      gdcSetting.Free;
    end;
  finally
    FTable.Free;
  end;
end;

procedure TgdcStandartTableTest.TestCreateTable;
var
  FTable: TgdcTable;
begin
  FTableName := 'USR$TEST' + IntToStr(Random(1000000)) + 'A';
  FDBState := GetDBState;

  FTable := GetTableClass.Create(nil);
  try
    FTable.Open;
    FTable.Insert;
    InitObject(FTable);
    FTable.Post;
  finally
    FTable.Free;
  end;

  ReConnect;

  FDBStateAfterCreate := GetDBState;
end;

procedure TgdcStandartTableTest.TestData;
begin
  //...
end;

procedure TgdcStandartTableTest.TestDrop;
var
  FTable: TgdcTable;
begin
  Check(FTableName > '');

  FTable := GetTableClass.Create(nil);
  try
    FTable.SubSet := 'ByName';
    FTable.ParamByName(FTable.GetListField(FTable.SubType)).AsString := FTableName;
    FTable.Open;
    Check(not FTable.EOF);
    FTable.Delete;
  finally
    FTable.Free;
  end;

  ReConnect;

  Check(FDBState = GetDBState);
end;

procedure TgdcStandartTableTest.TestLoadSetting;
var
  FTable: TgdcTable;
  gdcSetting: TgdcSetting;
begin
  Check(FTableName > '');

  gdcSetting := TgdcSetting.Create(nil);
  try
    gdcSetting.Open;
    gdcSetting.LoadFromFile(GetFileName);
    gdcSetting.GoToLastLoadedSetting;

    ActivateSettings(IntToStr(gdcSetting.ID));

    gdcSetting.Close;
    gdcSetting.SubSet := 'ByName';
    gdcSetting.ParamByName(gdcSetting.GetListField(gdcSetting.SubType)).AsString := FTableName;
    gdcSetting.Open;
    gdcSetting.Delete;
  finally
    gdcSetting.Free;
  end;

  {SaveStringToFile(StringReplace(FDBStateAfterCreate, ',', #13#10, [rfReplaceAll]), 'c:\temp\1.txt');
  SaveStringToFile(StringReplace(GetDBState, ',', #13#10, [rfReplaceAll]), 'c:\temp\2.txt');}

  Check(FDBStateAfterCreate = GetDBState);

  Check(DeleteFile(GetFileName));

  FTable := GetTableClass.Create(nil);
  try
    FTable.SubSet := 'ByName';
    FTable.ParamByName(FTable.GetListField(FTable.SubType)).AsString := FTableName;
    FTable.Open;
    FTable.Delete;
  finally
    FTable.Free;
  end;

  ReConnect;

  Check(FDBState = GetDBState);
end;

{ TgdcPrimeTableTest }

function TgdcPrimeTableTest.GetTableClass: CgdcTable;
begin
  Result := TgdcPrimeTable;
end;

procedure TgdcPrimeTableTest.TestMetaData;
var
  Temps1, Temps2: String;
begin
  Check(FTableName > '');

  Temps1 := 'USR$BI_' + FTableName;
  Temps2 := GetBaseTableBITriggerName(FTableName, FTr);
  Check(Temps1 = Temps2);
end;

{ TgdcSimpleTableTest }

function TgdcSimpleTableTest.GetTableClass: CgdcTable;
begin
  Result := TgdcSimpleTable;
end;

procedure TgdcSimpleTableTest.TestMetaData;
var
  SimpleTableMetaNames: TBaseTableTriggersName;
  Temps: String;
begin
  Check(FTableName > '');

  GetBaseTableTriggersName(FTableName, FTr, SimpleTableMetaNames);
  Temps := 'USR$BI_' + FTableName;
  Check(Temps = SimpleTableMetaNames.BITriggerName);
  Temps := StringReplace(FTableName, 'USR$', 'USR$BI_', [rfReplaceAll]) + '5';
  Check(Temps = SimpleTableMetaNames.BI5TriggerName);
  Temps := StringReplace(FTableName, 'USR$', 'USR$BU_', [rfReplaceAll]) + '5';
  Check(Temps = SimpleTableMetaNames.BU5TriggerName);
end;

{ TgdcTreeTableTest }

function TgdcTreeTableTest.GetTableClass: CgdcTable;
begin
  Result := TgdcTreeTable;
end;

function TgdcTableToTableTest.GetTableClass;
begin
  Result := TgdctableToTable;
end;

procedure TgdcTableToTableTest.TestMetaData;
var
  TableToTableMetaNames: TBaseTableTriggersName;
begin
  GetBaseTableTriggersName(FTableName, FTr, TableToTableMetaNames);

  Check(TableToTableMetaNames.BITriggerName = '');
  Check(TableToTableMetaNames.BI5TriggerName = '');
  Check(TableToTableMetaNames.BU5TriggerName = '');
end;

function TgdcLBRBTreeTest.GetTableClass;
begin
  Result := TgdcLBRBTreeTable;
end;

procedure TgdcLBRBTreeTest.TestMetaData;
var
  Names: TLBRBTreeMetaNames;
begin
  Check(GetLBRBTreeDependentNames('GD_CONTACT', nil, Names) = -1);
  Check(GetLBRBTreeDependentNames('GD_CONTACT', FTr, Names) > 5);
  Check(Names.ChldCtName = 'GD_P_GCHC_CONTACT');
  Check(Names.ExLimName = 'GD_P_EL_CONTACT');
  Check(Names.RestrName = 'GD_P_RESTRUCT_CONTACT');
  Check(Names.ExceptName = '');
  Check(Names.BITriggerName = 'GD_BI_CONTACT10');
  Check(Names.BUTriggerName = 'GD_BU_CONTACT10');
  Check(Names.LBIndexName = 'GD_X_CONTACT_LB');
  Check(Names.RBIndexName = 'GD_X_CONTACT_RB');
  Check(Names.ChkName = 'GD_CHK_CONTACT_TR_LMT');
end;

procedure TgdcLBRBTreeTest.TestRestrLBRBTree;
var
  Tr: TIBTransaction;
begin
  Check(FTableName > '');

  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.DefaultAction := TACommit;
    Tr.StartTransaction;

    Check(RestrLBRBTree(FTableName, Tr) = 1);
    CheckConsistency(Tr);
  finally
    Tr.Free;
  end;
end;

procedure TgdcLBRBTreeTest.TestLBRBTree;
var
  L: TgdKeyArray;
  I, J, ID: Integer;
  q: TIBSQL;
  Tr: TIBTransaction;
  //SL: TStringList;
begin
  Check(FTableName > '');

  //SL := TStringList.Create;
  L := TgdKeyArray.Create;
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    L.Sorted := False;

    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.DefaultAction := TACommit;
    Tr.Params.Text := 'read_committed'#13#10'rec_version'#13#10'nowait';
    Tr.StartTransaction;

    q.Transaction := Tr;

    try
      for I := 1 to 1800 do
      begin
        q.Close;

        J := Random(20);
        case J of
          0..14:
          begin
            ID := gdcBaseManager.GetNextID;

            if (L.Count = 0) or (Random(10) = 9) then
              q.SQL.Text := 'INSERT INTO ' + FTableName +
                ' (id, parent) VALUES (' + IntToStr(ID) + ', NULL)'
            else begin
              q.SQL.Text := 'INSERT INTO ' + FTableName +
                ' (id, parent) VALUES (' + IntToStr(ID) + ', ' + IntToStr(L.Keys[Random(L.Count)]) + ')';
            end;

            q.ExecQuery;
            //SL.Add(Trim(q.SQL.Text) + ';');
            L.Add(ID);
          end;

          15..18:
          begin
            if L.Count > 0 then
            begin
              if (L.Count = 0) or (Random(9) = 8) then
                q.SQL.Text := 'UPDATE ' + FTableName +
                  ' SET parent=NULL' +
                  ' WHERE id=' + IntToStr(L.Keys[Random(L.Count)])
              else
                q.SQL.Text := 'UPDATE ' + FTableName +
                  ' SET parent=' + IntToStr(L.Keys[Random(L.Count)]) +
                  ' WHERE id=' + IntToStr(L.Keys[Random(L.Count)]);
              try
                q.ExecQuery;
                //SL.Add(Trim(q.SQL.Text) + ';');
              except
                on E: Exception do
                  if (Pos('Invalid parent specified', E.Message) = 0)
                    and (Pos('TREE_E_INVALID_PARENT', E.Message) = 0) then
                  begin
                    raise;
                  end;
              end;
            end;
          end;

          19:
          begin
            if L.Count > 0 then
            begin
              ID := L.Keys[Random(L.Count)];

              q.Close;
              q.SQL.Text := 'SELECT id FROM ' + FTableName +
                ' WHERE ' +
                ' lb >= (SELECT lb FROM ' + FTableName + ' WHERE id=:ID) ' +
                '   AND rb <= (SELECT rb FROM ' + FTableName + ' WHERE id=:ID)';
              q.ParamByName('id').AsInteger := ID;
              q.ExecQuery;
              while not q.EOF do
              begin
                L.Remove(q.Fields[0].AsInteger);
                q.Next;
              end;

              q.Close;
              q.SQL.Text := 'DELETE FROM ' + FTableName + ' WHERE id=' + IntToStr(ID);
              q.ExecQuery;
              //SL.Add(Trim(q.SQL.Text) + ';');
            end;
          end;
        end;

        q.Close;
        q.SQL.Text :=
          'SELECT RDB$GET_CONTEXT(''USER_TRANSACTION'', ''LBRB_UNLOCK'') ' +
          'FROM rdb$database';
        q.ExecQuery;
        Check(q.Fields[0].IsNull,
          'On iteration #' + IntToStr(I) + '. Unlock variable is not null. J = ' + IntToStr(J));

        CheckConsistency(Tr);

        if I mod 400 = 0 then
          OutputDebugString(PChar('LBRBTest: iteration #' + IntToStr(I)));
      end;
    except
      on E: EIBError do
        Check(False, E.Message + ' Code: ' + IntToStr(E.IBErrorCode));
    end;

    q.Close;
    q.SQL.Text := 'SELECT COUNT(*) FROM ' + FTableName;
    q.ExecQuery;
    Check(q.Fields[0].AsInteger = L.Count, 'Incorrect number of tree items.');
  finally
    q.Free;
    Tr.Free;
    L.Free;
  end;
end;

procedure TgdcLBRBTreeTest.TestData;
begin
  inherited;
  TestRestrLBRBTree;
  TestLBRBTree;
end;

procedure TgdcLBRBTreeTest.CheckConsistency(Tr: TIBTransaction);
var
  q: TIBSQL;
begin
  q := TIBSQL.Create(nil);
  try
    q.Transaction := Tr;

    q.SQL.Text := 'SELECT a.lb FROM ' + FTableName + ' a JOIN ' + FTableName
      + ' b ON a.lb = b.lb AND a.id <> b.id';
    q.ExecQuery;
    Check(q.EOF, 'Duplicate LB = ' + q.Fields[0].AsString);

    q.Close;
    q.SQL.Text := 'SELECT a.id || '','' || b.id FROM ' + FTableName + ' a JOIN ' + FTableName
      + ' b ON a.lb < b.lb AND a.rb >= b.lb AND a.rb < b.rb';
    q.ExecQuery;
    Check(q.EOF, 'Overlapped intervals (left). ' + q.Fields[0].AsString);

    q.Close;
    q.SQL.Text := 'SELECT a.id || '','' || b.id FROM ' + FTableName + ' a JOIN ' + FTableName
      + ' b ON a.lb > b.lb AND a.lb <= b.rb AND a.rb > b.rb';
    q.ExecQuery;
    Check(q.EOF, 'Overlapped intervals (right). ' + q.Fields[0].AsString);
    q.Close;

    q.SQL.Text := 'SELECT a.id || '','' || b.id FROM ' + FTableName + ' a JOIN ' + FTableName
      + ' b ON a.parent = b.id AND a.lb <= b.lb AND a.rb >= b.rb ';
    q.ExecQuery;
    Check(q.EOF, 'Parent interval is smaller. ' + q.Fields[0].AsString);
  finally
    q.Free;
  end;
end;

procedure TgdcTableToTableTest.InitObject(AnObj: TgdcBase);
var
  R: OleVariant;
begin
  inherited;
  gdcBaseManager.ExecSingleQueryResult('SELECT id FROM at_relations WHERE relationname = :RN',
    'GD_CONTACT', R, FTr);
  AnObj.FieldByName('referencekey').AsInteger := R[0, 0];
end;

procedure TgdcSetTest.TestCreateDomain;
var
  FField: TgdcField;
begin
  FDomainName := 'USR$TEST' + IntToStr(Random(1000000));

  FDBState := GetDBState;

  FField := TgdcField.Create(nil);
  try
    FField.Open;
    FField.Insert;
    FField.FieldByName('fieldname').AsString := FDomainName;
    FField.FieldByName('lname').AsString := FDomainName;
    FField.FieldByName('setlistlname').AsString := 'Контакты';
    FField.FieldByName('ffieldtype').AsInteger := 37;
    FField.FieldByName('flength').AsInteger := 120;
    FField.FieldByName('fcharlength').AsInteger := 120;
    FField.FieldByName('charset').AsString := 'WIN1251';
    FField.FieldByName('collation').AsString := 'PXW_CYRL';
    FField.FieldByName('settable').AsString := 'GD_CONTACT';
    FField.FieldByName('setlistfield').AsString := 'NAME';
    FField.FieldByName('settablekey').AsInteger := 147000717;
    FField.FieldByName('setlistfieldkey').AsInteger := 147001319;
    FField.Post;
    FDomainKey := FField.ID;
  finally
    FField.Free;
  end;

  ReConnect;

  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM rdb$fields WHERE rdb$field_name = :fn';
  FQ.ParamByName('fn').AsString := FDomainName;
  FQ.ExecQuery;

  Check(not FQ.EOF);
end;

procedure TgdcSetTest.CreateTable;
var
  FTable: TgdcTable;
begin
  FTableName := 'USR$TEST' + IntToStr(Random(1000000)) + 'A';

  FTable := TgdcPrimeTable.Create(nil);
  try
    FTable.Open;
    FTable.Insert;
    FTable.FieldByName('relationname').AsString := FTableName;
    FTable.Post;
    FTableKey := FTable.ID;
  finally
    FTable.Free;
  end;

  ReConnect;
end;

procedure TgdcSetTest.TestAddFieldToTable;
var
  FTableField: TgdcTableField;
  Temps: String;
begin
  CreateTable;

  Check(FTableName > '');
  Check(FDomainName > '');
  Check(FTableKey > 0);
  Check(FDomainKey > 0);

  
  FFieldName := 'USR$TEST' + IntToStr(Random(1000000)) + 'F';

  FTableField := TgdcTableField.Create(nil);
  try
    FTableField.Open;
    FTableField.Insert;
    FTableField.FieldByName('relationtype').AsString := 'T';
    FTableField.FieldByName('fieldname').AsString := FFieldName;
    FTableField.FieldByName('relationname').AsString := FTableName;
    FTableField.FieldByName('fieldsource').AsString := FDomainName;
    FTableField.FieldByName('relationkey').AsInteger := FTableKey;
    FTableField.FieldByName('fieldsourcekey').AsInteger := FDomainKey;
    FTableField.Post;

    Check(FTableField.FieldByName('crosstable').AsString > '');
    
    Temps := FTableField.FieldByName('crosstable').AsString;
  finally
    FTableField.Free;
  end;

  ReConnect;

  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM rdb$relations WHERE rdb$relation_name = :RN';
  FQ.ParamByName('RN').AsString := Temps;
  FQ.ExecQuery;

  Check(not FQ.EOF);

  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM rdb$triggers WHERE rdb$trigger_name = :TN AND rdb$relation_name = :RN';
  FQ.ParamByName('RN').AsString := FTableName;
  FQ.ParamByName('TN').AsString := 'USR$BI_' + Temps;
  FQ.ExecQuery;

  Check(not FQ.EOF);

  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM rdb$relation_fields WHERE rdb$field_name = :FN AND rdb$relation_name = :RN';
  FQ.ParamByName('FN').AsString := FFieldName;
  FQ.ParamByName('RN').AsString := FTableName;
  FQ.ExecQuery;

  Check(not FQ.EOF);
    
  FDBStateAfterCreate := GetDBState;
end;

procedure TgdcSetTest.TestAddToSetting;
var
  FTable: TgdcPrimeTable;
  gdcSetting: TgdcSetting;
  gdcSettingPos: TgdcSettingPos;
begin
  Check(FTableName > '');

  FTable := TgdcPrimeTable.Create(nil);
  try
    FTable.SubSet := 'ByName';
    FTable.ParamByName(FTable.GetListField(FTable.SubType)).AsString := FTableName;
    FTable.Open;
    Check(not FTable.EOF);

    gdcSetting := TgdcSetting.Create(nil);
    try
      gdcSetting.Open;
      gdcSetting.Insert;
      gdcSetting.FieldByName('NAME').AsString := FTableName;
      gdcSetting.Post;

      gdcSettingPos := TgdcSettingPos.Create(nil);
      try
        gdcSettingPos.SubSet := 'BySetting';
        gdcSettingPos.ParamByName('settingkey').AsInteger := gdcSetting.ID;
        gdcSettingPos.Open;
        gdcSettingPos.AddPos(FTable, True);
      finally
        gdcSettingPos.Free;
      end;

      gdcSetting.SaveSettingToBlob(sttXML);
      gdcSetting.AddMissedPositions;
      gdcSetting.SaveToFile(GetFileName);

      FQ.Close;
      FQ.SQL.Text := 'SELECT * FROM at_settingpos sp ' +
        'JOIN gd_ruid r ' +
        '  ON r.xid = sp.xid AND r.dbid = sp.dbid ' +
        'JOIN at_relations t ' +
        '  ON t.id = r.id ' +
        'WHERE settingkey = :sk ' +
        '  AND objectclass = ''TgdcUnknownTable'' AND t.relationname like ''USR$CROSS%''';
      FQ.ParamByName('sk').AsInteger := gdcSetting.ID;
      FQ.ExecQuery;

      Check(FQ.EOF);

      FQ.Close;
      FQ.SQL.Text := 'SELECT * FROM at_settingpos WHERE settingkey = :sk AND objectclass = ''TgdcTrigger'' ';
      FQ.ParamByName('sk').AsInteger := gdcSetting.ID;
      FQ.ExecQuery;

      Check(FQ.EOF);

      gdcSetting.Delete;
    finally
      gdcSetting.Free;
    end;
  finally
    FTable.Free;
  end;
end;

function TgdcSetTest.GetFileName: String;
var
  TempPath: array[0..1023] of Char;
begin
  Check(FTableName > '');

  GetTempPath(SizeOf(TempPath), TempPath);
  Result := String(TempPath) + '\' + FTableName + '.xml'
end;

procedure TgdcSetTest.TestDrop;
var
  FTableField: TgdcTableField;
  FTable: TgdcPrimeTable;
  FDomain: TgdcField;
begin
  Check(FFieldName > '');
  Check(FTableName > '');
  Check(FDomainName > '');

  FTableField := TgdcTableField.Create(nil);
  try
    FTableField.SubSet := 'ByName';
    FTableField.ParamByName(FTableField.GetListField(FTableField.SubType)).AsString := FFieldName;
    FTableField.Open;
    Check(not FTableField.EOF);
    FTableField.Delete;
  finally
    FTableField.Free;
  end;

  ReConnect;

  FTable := TgdcPrimeTable.Create(nil);
  try
    FTable.SubSet := 'ByName';
    FTable.ParamByName(FTable.GetListField(FTable.SubType)).AsString := FTableName;
    FTable.Open;
    Check(not FTable.EOF);
    FTable.Delete;
  finally
    FTable.Free;
  end;

  ReConnect;

  FDomain := TgdcField.Create(nil);
  try
    FDomain.SubSet := 'ByName';
    FDomain.ParamByName(FDomain.GetListField(FDomain.SubType)).AsString := FDomainName;
    FDomain.Open;
    Check(not FDomain.EOF);
    FDomain.Delete;
  finally
    FDomain.Free;
  end;

  ReConnect;

  Check(FDBState = GetDBState);
end;

procedure TgdcSetTest.TestLoadSetting;
var
  FTableField: TgdcTableField;
  FTable: TgdcTable;
  FDomain: TgdcField;
  gdcSetting: TgdcSetting;
begin
  Check(FFieldName > '');
  Check(FDomainName > '');
  Check(FTableName > '');

  gdcSetting := TgdcSetting.Create(nil);
  try
    gdcSetting.Open;
    gdcSetting.LoadFromFile(GetFileName);
    gdcSetting.GoToLastLoadedSetting;

    ActivateSettings(IntToStr(gdcSetting.ID));

    gdcSetting.Close;
    gdcSetting.SubSet := 'ByName';
    gdcSetting.ParamByName(gdcSetting.GetListField(gdcSetting.SubType)).AsString := FTableName;
    gdcSetting.Open;
    gdcSetting.Delete;
  finally
    gdcSetting.Free;
  end;

  Check(FDBStateAfterCreate = GetDBState);

  Check(DeleteFile(GetFileName));

  FTableField := TgdcTableField.Create(nil);
  try
    FTableField.SubSet := 'ByName';
    FTableField.ParamByName(FTableField.GetListField(FTableField.SubType)).AsString := FFieldName;
    FTableField.Open;
    Check(not FTableField.EOF);
    FTableField.Delete;
  finally
    FTableField.Free;
  end;

  ReConnect;

  FTable := TgdcPrimeTable.Create(nil);
  try
    FTable.SubSet := 'ByName';
    FTable.ParamByName(FTable.GetListField(FTable.SubType)).AsString := FTableName;
    FTable.Open;
    FTable.Delete;
  finally
    FTable.Free;
  end;

  ReConnect;

  FDomain := TgdcField.Create(nil);
  try
    FDomain.SubSet := 'ByName';
    FDomain.ParamByName(FDomain.GetListField(FDomain.SubType)).AsString := FDomainName;
    FDomain.Open;
    Check(not FTable.EOF);
    FDomain.Delete;
  finally
    FDomain.Free;
  end;

  ReConnect;

  Check(FDBState = GetDBState);
end; 

procedure TgdcSetTest.DoTest;
begin
  TestCreateDomain;
  TestAddFieldToTable;
  TestAddToSetting;
  TestDrop;
  TestLoadSetting
end; 

initialization
  RegisterTest('DB', TgdcMetaDataTest.Suite);
  RegisterTest('DB\TgdcMetaDataTest\StandartTables', TgdcPrimeTableTest.Suite);
  RegisterTest('DB\TgdcMetaDataTest\StandartTables', TgdcSimpleTableTest.Suite);
  RegisterTest('DB\TgdcMetaDataTest\StandartTables', TgdcTreeTableTest.Suite);
  RegisterTest('DB\TgdcMetaDataTest\StandartTables', TgdcTableToTableTest.Suite);
  RegisterTest('DB\TgdcMetaDataTest\StandartTables', TgdcLBRBTreeTest.Suite);
  RegisterTest('DB\TgdcMetaDataTest\Set', TgdcSetTest.Suite);
  Randomize;
end.
