
unit Test_gdcMetaData_unit;

interface

uses
  TestFrameWork, gsTestFrameWork, IBDatabase, gdcBase, gdcMetaData;

type
  TDatabaseTest = class(TgsDBTestCase)
  published
    procedure TestRoleRights;
    procedure TestExternal_BIN_AND;
  end;

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

  TgdcStandartSaveToXMLTest = class(TgsDBTestCase)
  protected
    FTableName, FFieldName: String;
    FDBState, FDBStateAfterCreate: String;

    function AddTableField(const AName, ATableName, ADomainName: String): Boolean;
    function GetTableClass: CgdcTable; virtual; abstract;
    function GetRecordClass: String; virtual;
    function GetFileName(ANumber: Integer): String;
    procedure InitObject(AnObj: TgdcBase); virtual;

    procedure CreateTable; virtual;
    procedure TestMetaData; virtual; abstract;
    procedure AddRecordToTable; virtual; abstract;
    procedure TestAddToSetting; virtual;
    procedure TestDrop; virtual;
    procedure TestLoadSetting; virtual;
  published
    procedure DoTest;
  end;

  TgdcSimpleTableSaveToXMLTest = class(TgdcStandartSaveToXMLTest)
  protected
    function GetTableClass: CgdcTable; override; 
    procedure AddRecordToTable; override;
    procedure TestMetaData; override;
  end;

  TgdcTreeTableSaveToXMLTest = class(TgdcStandartSaveToXMLTest)
  protected
    function GetTableClass: CgdcTable; override;
    function GetRecordClass: String; override;
    procedure AddRecordToTable; override;
    procedure TestMetaData; override;
  end;

  TgdcTableToTableSaveToXMLTest = class(TgdcStandartSaveToXMLTest)
  protected
    function GetTableClass: CgdcTable; override;
    procedure InitObject(AnObj: TgdcBase); override;
    procedure AddRecordToTable; override;
    procedure TestMetaData; override;
  end;

  TgdcSetSaveToXMLTest = class(TgdcStandartSaveToXMLTest)
  protected
    FDomainName, FTableName2, FFieldName2: String;
    function GetTableClass: CgdcTable; override;
    procedure AddRecordToTable; override;

    procedure CreateTable; override;
    procedure TestAddToSetting; override;
    procedure TestMetaData; override;
    procedure TestDrop; override;
    procedure TestLoadSetting; override;
  end;

implementation

uses
  Classes, Windows, DB, IB, gd_security, at_frmSQLProcess,
  IBSQL, gdcBaseInterface, gd_KeyAssoc, SysUtils, at_classes,
  gdcLBRBTreeMetaData, jclStrings, gdcJournal, gdcSetting,
  gdcTableMetaData, gsStreamHelper, gdcAttrUserDefined, at_log,
  gd_directories_const;

const
  DomainName = 'DTEXT60';  

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

  FQ.ParamByName('id').AsInteger := cstUserIDStart;
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
  try
    FQ.ExecQuery;
    Check(False);
  except
    on E: EIBInterBaseError do ;
  end;

  FQ.ParamByName('id').AsInteger := -1;
  FQ.ParamByName('xid').AsInteger := -1;
  FQ.ParamByName('dbid').AsInteger := 17;
  try
    FQ.ExecQuery;
    Check(False);
  except
    on E: EIBInterBaseError do ;
  end;

  FQ.ParamByName('id').AsInteger := 146999999;
  FQ.ParamByName('xid').AsInteger := 146999999;
  FQ.ParamByName('dbid').AsInteger := 17;
  FQ.ExecQuery;

  FQ.ParamByName('id').AsInteger := 146999999;
  FQ.ParamByName('xid').AsInteger := 146999999;
  FQ.ParamByName('dbid').AsInteger := 28;
  try
    FQ.ExecQuery;
    Check(False);
  except
    on E: EIBInterBaseError do ;
  end;

  FQ.ParamByName('id').AsInteger := 146999999;
  FQ.ParamByName('xid').AsInteger := 147999999;
  FQ.ParamByName('dbid').AsInteger := 17;
  try
    FQ.ExecQuery;
    Check(False);
  except
    on E: EIBInterBaseError do ;
  end;
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
begin
  Check(FTableName > '');
  Result := TempPath + '\' + FTableName + '.xml'
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

  Check(FDBStateAfterCreate = GetDBState);

  TestMetaData;

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
begin
  Check(FTableName > '');

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
  R, F: OleVariant;
begin
  FDomainName := 'USR$TEST' + IntToStr(Random(1000000));
  Check(atDatabase.Fields.ByFieldName(FDomainName) = nil, 'Duplicate domain name.');

  FDBState := GetDBState;

  gdcBaseManager.ExecSingleQueryResult('SELECT id FROM at_relations WHERE relationname = :RN',
    'GD_CONTACT', R, FTr);

  gdcBaseManager.ExecSingleQueryResult('SELECT id FROM at_relation_fields WHERE relationkey = :RK AND fieldname = ''NAME''',
    R[0, 0], F, FTr);

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
    FField.FieldByName('settablekey').AsInteger := R[0, 0];
    FField.FieldByName('setlistfieldkey').AsInteger := F[0, 0];
    FField.Post;
    FDomainKey := FField.ID;
  finally
    FField.Free;
  end;

  ReConnect;

  Check(atDatabase.Fields.ByFieldName(FDomainName) <> nil, 'Domain not found in the atDatabase.');
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

  Check(FTableName > '', 'Empty table name');
  Check(FDomainName > '', 'Empty domain name');
  Check(FTableKey > 0, 'Unknown table');
  Check(FDomainKey > 0, 'Unknown domain');

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

    Check(FTableField.FieldByName('crosstable').AsString > '', 'Cross table not set.');

    Temps := FTableField.FieldByName('crosstable').AsString;
  finally
    FTableField.Free;
  end;

  ReConnect;

  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM rdb$relations WHERE rdb$relation_name = :RN';
  FQ.ParamByName('RN').AsString := Temps;
  FQ.ExecQuery;

  Check(not FQ.EOF, 'Relation not found');

  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM rdb$triggers WHERE rdb$trigger_name = :TN AND rdb$relation_name = :RN';
  FQ.ParamByName('RN').AsString := FTableName;
  FQ.ParamByName('TN').AsString := 'USR$BI_' + Temps;
  FQ.ExecQuery;

  Check(not FQ.EOF, 'Trigger not found');

  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM rdb$relation_fields WHERE rdb$field_name = :FN AND rdb$relation_name = :RN';
  FQ.ParamByName('FN').AsString := FFieldName;
  FQ.ParamByName('RN').AsString := FTableName;
  FQ.ExecQuery;

  Check(not FQ.EOF, 'Relation fields not found');

  FDBStateAfterCreate := GetDBState;
end;

procedure TgdcSetTest.TestAddToSetting;
var
  FTable: TgdcPrimeTable;
  gdcSetting: TgdcSetting;
  gdcSettingPos: TgdcSettingPos;
begin
  Check(FTableName > '', 'Table name is empty');

  FTable := TgdcPrimeTable.Create(nil);
  try
    FTable.SubSet := 'ByName';
    FTable.ParamByName(FTable.GetListField(FTable.SubType)).AsString := FTableName;
    FTable.Open;
    Check(not FTable.EOF, 'Table is empty');

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
begin
  Check(FTableName > '', 'Table name is empty');
  Result := IncludeTrailingBackslash(TempPath) + FTableName + '.xml'
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

function TgdcStandartSaveToXMLTest.AddTableField(const AName, ATableName, ADomainName: String): Boolean;
var
  F, R: OleVariant;
  FTableField: TgdcTableField;
begin
  Result := False;

  gdcBaseManager.ExecSingleQueryResult('SELECT id FROM at_relations WHERE relationname = :RN',
    ATableName, R, FTr);

  gdcBaseManager.ExecSingleQueryResult('SELECT id FROM at_fields WHERE fieldname = :FN',
    ADomainName, F, FTr);

  if (not VarIsEmpty(R)) and (not VarIsEmpty(F)) then
  begin
    FTableField := TgdcTableField.Create(nil);
    try
      FTableField.Open;
      FTableField.Insert;
      FTableField.FieldByName('relationtype').AsString := 'T';
      FTableField.FieldByName('fieldname').AsString := AName;
      FTableField.FieldByName('relationname').AsString := ATableName;
      FTableField.FieldByName('fieldsource').AsString := ADomainName;
      FTableField.FieldByName('relationkey').AsInteger := R[0, 0];
      FTableField.FieldByName('fieldsourcekey').AsInteger := F[0, 0];
      FTableField.Post;
      Result := True;
    finally
      FTableField.Free;
    end;
  end;
end;

procedure TgdcStandartSaveToXMLTest.CreateTable;
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

  FFieldName := 'USR$TEST' + IntToStr(Random(1000000)) + 'F';
  Check(AddTableField(FFieldName, FTableName, DomainName));

  ReConnect;

  AddRecordToTable;

  FDBStateAfterCreate := GetDBState;
end;

function TgdcStandartSaveToXMLTest.GetFileName(ANumber: Integer): String;
begin
  Check(FTableName > '');
  Result := TempPath + '\' + FTableName + 'part' + IntToStr(ANumber) + '.xml';  
end;

procedure TgdcStandartSaveToXMLTest.InitObject(AnObj: TgdcBase);
begin
  Assert(Assigned(AnObj) and (AnObj.State = dsInsert));
  AnObj.FieldByName('relationname').AsString := FTableName;
end;

procedure TgdcStandartSaveToXMLTest.TestAddToSetting;
var
  FTable: TgdcTable;
  Obj: TgdcBase;
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

    FQ.Close;
    FQ.SQL.Text := 'SELECT id FROM ' + FTableName;
    FQ.ExecQuery;
    Check(not FQ.EOF);

    gdcSetting := TgdcSetting.Create(nil);
    try
      gdcSetting.Open;
      gdcSetting.Insert;
      gdcSetting.FieldByName('NAME').AsString := FTableName + 'part1';
      gdcSetting.Post;


      gdcSettingPos := TgdcSettingPos.Create(nil);
      try
        gdcSettingPos.SubSet := 'BySetting';
        gdcSettingPos.ParamByName('settingkey').AsInteger := gdcSetting.ID;
        gdcSettingPos.Open;
        gdcSettingPos.AddPos(FTable, True);
        gdcSettingPos.Close;  

        gdcSetting.SaveSettingToBlob(sttXML);
        gdcSetting.SaveToFile(GetFileName(1));
        gdcSetting.Delete;

        gdcSetting.Insert;
        gdcSetting.FieldByName('NAME').AsString := FTableName + 'part2';
        gdcSetting.Post;

        gdcSettingPos.ParamByName('settingkey').AsInteger := gdcSetting.ID;
        gdcSettingPos.Open;



        Obj := CgdcBase(GetClass(GetRecordClass)).CreateSubType(nil, FTableName, 'ByID');
        try
          Obj.Database := gdcBaseManager.Database;
          Obj.Transaction := gdcBaseManager.ReadTransaction; 
          while not FQ.Eof do
          begin
            Obj.ID := FQ.FieldByName('ID').AsInteger;
            Obj.Open;
            gdcSettingPos.AddPos(Obj, False);
            Obj.Close;
            FQ.Next;
          end;
        finally  
          Obj.Free;
        end;

        gdcSetting.SaveSettingToBlob(sttXML);
        gdcSetting.SaveToFile(GetFileName(2));
        gdcSetting.Delete;

      finally
        gdcSettingPos.Free;
      end;
    finally
      gdcSetting.Free;
    end;
  finally
    FTable.Free;
  end;
end;
procedure TgdcStandartSaveToXMLTest.TestDrop;
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

procedure TgdcStandartSaveToXMLTest.TestLoadSetting;
var
  gdcSetting: TgdcSetting;
begin
  Check(FTableName > '');

  gdcSetting := TgdcSetting.Create(nil);
  try
    gdcSetting.Open;
    gdcSetting.LoadFromFile(GetFileName(1));
    gdcSetting.GoToLastLoadedSetting;

    ActivateSettings(IntToStr(gdcSetting.ID));

    gdcSetting.LoadFromFile(GetFileName(2));
    gdcSetting.GoToLastLoadedSetting;

    ActivateSettings(IntToStr(gdcSetting.ID));

    gdcSetting.Close;
    gdcSetting.SubSet := 'ByName';
    gdcSetting.ParamByName(gdcSetting.GetListField(gdcSetting.SubType)).AsString := FTableName + 'part1';
    gdcSetting.Open;
    gdcSetting.Delete;

    gdcSetting.Close;
    gdcSetting.ParamByName(gdcSetting.GetListField(gdcSetting.SubType)).AsString := FTableName + 'part2';
    gdcSetting.Open;
    gdcSetting.Delete;
  finally
    gdcSetting.Free;
  end;

  ReConnect;

  TestMetaData;
  Check(FDBStateAfterCreate = GetDBState);

  Check(DeleteFile(GetFileName(1)));
  Check(DeleteFile(GetFileName(2)));

  TestDrop;
end;

procedure TgdcStandartSaveToXMLTest.DoTest;
begin
  CreateTable;
  TestAddToSetting;
  TestDrop;
  TestLoadSetting;
end;

function TgdcStandartSaveToXMLTest.GetRecordClass: String;
begin
  Result := 'TgdcAttrUserDefined';
end;

function TgdcTreeTableSaveToXMLTest.GetTableClass: CgdcTable;
begin
  Result := TgdcTreeTable;
end;

function TgdcTreeTableSaveToXMLTest.GetRecordClass: String;
begin
  Result := 'TgdcAttrUserDefinedTree';
end;

procedure TgdcTreeTableSaveToXMLTest.AddRecordToTable;
var
  g: TgdcBase;
  Parent: Integer;
begin
  g := CgdcBase(GetClass(GetRecordClass)).Create(nil);
  try
    g.SubType := FTableName;
    g.SubSet := 'ByName';
    g.Open;

    g.Insert;
    g.FieldByName(FFieldName).AsVariant := 'TEST1';
    Parent := g.ID;
    g.Post;

    g.Insert;
    g.FieldByName(FFieldName).AsVariant := 'TEST2';
    g.FieldByName('PARENT').AsInteger := Parent;
    g.Post;

    ReConnect;

    FQ.Close;
    FQ.SQL.Text := 'SELECT count(*) FROM ' + FTableName;
    FQ.ExecQuery;

    Check(not FQ.Eof);
    Check(FQ.FieldByName('count').AsInteger = 2);
  finally
    g.Free;
  end;
end;

procedure TgdcTreeTableSaveToXMLTest.TestMetaData;
begin
  FQ.Close;
  FQ.SQL.Text := 'SELECT count(*) FROM ' + FTableName;
  FQ.ExecQuery;

  Check(not FQ.Eof);
  Check(FQ.FieldByName('count').AsInteger = 2);
end;

function TgdcSimpleTableSaveToXMLTest.GetTableClass: CgdcTable;
begin
  Result := TgdcSimpleTable;
end;

procedure TgdcSimpleTableSaveToXMLTest.AddRecordToTable;
var
  g: TgdcBase;
begin
  g := CgdcBase(GetClass(GetRecordClass)).Create(nil);
  try
    g.SubType := FTableName;
    g.SubSet := 'ByName';
    g.Open;

    g.Insert;
    g.FieldByName(FFieldName).AsVariant := 'TEST1';
    g.Post;

    ReConnect;

    FQ.Close;
    FQ.SQL.Text := 'SELECT count(*) FROM ' + FTableName;
    FQ.ExecQuery;

    Check(not FQ.Eof);
    Check(FQ.FieldByName('count').AsInteger = 1);
  finally
    g.Free;
  end;
end;

procedure TgdcSimpleTableSaveToXMLTest.TestMetaData;
begin
  FQ.Close;
  FQ.SQL.Text := 'SELECT count(*) FROM ' + FTableName;
  FQ.ExecQuery;

  Check(not FQ.Eof);
  Check(FQ.FieldByName('count').AsInteger = 1);
end;

function TgdcTableToTableSaveToXMLTest.GetTableClass: CgdcTable;
begin
  Result := TgdcTableToTable;
end;

procedure TgdcTableToTableSaveToXMLTest.InitObject(AnObj: TgdcBase);
var
  R: OleVariant;
begin
  inherited;
  gdcBaseManager.ExecSingleQueryResult('SELECT id FROM at_relations WHERE relationname = :RN',
    'GD_CONTACT', R, FTr);
  AnObj.FieldByName('referencekey').AsInteger := R[0, 0];
end;

procedure TgdcTableTotableSaveToXMLTest.AddRecordToTable;
var
  g: TgdcBase;
begin
  g := CgdcBase(GetClass(GetRecordClass)).Create(nil);
  try
    g.SubType := FTableName;
    g.SubSet := 'ByName';
    g.Open;

    FQ.Close;
    FQ.SQL.Text := 'SELECT id FROM gd_contact';
    FQ.ExecQuery;

    g.Insert;
    g.FieldByName('ID').AsInteger := FQ.FieldByName('ID').AsInteger;
    g.FieldByName(FFieldName).AsVariant := 'TEST1';
    g.Post;

    ReConnect;

    FQ.Close;
    FQ.SQL.Text := 'SELECT count(*) FROM ' + FTableName;
    FQ.ExecQuery;

    Check(not FQ.Eof);
    Check(FQ.FieldByName('count').AsInteger = 1);
  finally
    g.Free;
  end;
end;

procedure TgdcTableToTableSaveToXMLTest.TestMetaData;
begin
  FQ.Close;
  FQ.SQL.Text := 'SELECT count(*) FROM ' + FTableName;
  FQ.ExecQuery;

  Check(not FQ.Eof);
  Check(FQ.FieldByName('count').AsInteger = 1);
end;

function TgdcSetSaveToXMLTest.GetTableClass: CgdcTable;
begin
  Result := TgdcPrimeTable;
end;

procedure TgdcSetSaveToXMLTest.AddRecordToTable; 
var
  g, g1: TgdcBase;
  CrossTable, Fields: String;
begin
  g1 := CgdcBase(GetClass(GetRecordClass)).Create(nil);
  try
    g1.SubType := FTableName2;
    g1.SubSet := 'ByName';
    g1.Open;

    g1.Insert;
    g1.FieldByName(FFieldName2).AsString := 'TEST1';
    g1.Post;

    g1.Insert;
    g1.FieldByName(FFieldName2).AsString := 'TEST2';
    g1.Post;

    ReConnect;

    FQ.Close;
    FQ.SQL.Text := 'SELECT count(*) FROM ' + FTableName2;
    FQ.ExecQuery;

    Check(not FQ.Eof);
    Check(FQ.FieldByName('count').AsInteger = 2);
  finally
    g1.Free;
  end;

  g := CgdcBase(GetClass(GetRecordClass)).Create(nil);
  try
    g.SubType := FTableName;
    g.SubSet := 'ByName';
    g.Open;

    g.Insert;
    g.Post;

    FQ.Close;
    FQ.SQL.Text := 'SELECT count(*) FROM ' + FTableName;
    FQ.ExecQuery;

    Check(not FQ.Eof);
    Check(FQ.FieldByName('count').AsInteger = 1);

    FQ.Close;
    FQ.SQL.Text := 'SELECT crosstable FROM at_relation_fields WHERE relationname = :RN and fieldname = :FN';
    FQ.ParamByName('RN').AsString := FTableName;
    FQ.ParamByName('FN').AsString := FFieldName;
    FQ.ExecQuery;

    CrossTable := FQ.FieldByName('crosstable').AsString;

    FQ2.SQL.Text := 'SELECT LIST(FieldName) as names FROM at_relation_fields where relationname = :RN';
    FQ2.ParamByName('RN').AsString := CrossTable;
    FQ2.ExecQuery;

    Fields := FQ2.FieldByName('names').AsString;

    FQ2.Close;
    FQ2.SQL.Text := 'SELECT id FROM ' + FTableName2;
    FQ2.ExecQuery;

    FQ.Close;
    FQ.SQl.Text := 'INSERT INTO ' + CrossTable + '(' + Fields + ') VALUES (:ID1, :ID2)';
    FQ.ParamByName('ID1').AsInteger := g.ID;
    FQ.ParamByName('ID2').AsInteger := FQ2.FieldByName('ID').AsInteger;
    FQ.ExecQuery;
    FQ.Close;
    FQ2.Next;

    FQ.ParamByName('ID1').AsInteger := g.ID;
    FQ.ParamByName('ID2').AsInteger := FQ2.FieldByName('ID').AsInteger;
    FQ.ExecQuery;

    if FTr.InTransaction then
    begin
      FTr.Commit;
      FTr.StartTransaction;
    end; 
  finally
    g.Free;
  end;
end;

procedure TgdcSetSaveToXMLTest.TestMetaData;
begin
   FQ.Close;
   FQ.SQL.Text := 'SELECT count(*) FROM ' + FTableName;
   FQ.ExecQuery;
   Check(FQ.FieldByName('count').AsInteger = 1);

   FQ.Close;
   FQ.SQL.Text := 'SELECT crosstable FROM at_relation_fields WHERE relationname = :RN and fieldname = :FN';
   FQ.ParamByName('RN').AsString := FTableName;
   FQ.ParamByName('FN').AsString := FFieldName;
   FQ.ExecQuery;

   FQ2.Close;
   FQ2.SQL.Text := 'SELECT count(*) FROM ' + FQ.FieldByName('crosstable').AsString;
   FQ2.ExecQuery;

   Check(FQ2.FieldByName('count').AsInteger = 2);
end;

procedure TgdcSetSaveToXMLTest.CreateTable;
var
  FTable: TgdcTable;
  FField: TgdcField;
  IDF, IDT: Integer;
begin
  FTableName := 'USR$TEST' + IntToStr(Random(1000000)) + 'A';
  FTableName2 := 'USR$TEST' + IntToStr(Random(1000000)) + 'A';
  
  FDBState := GetDBState;

  FTable := GetTableClass.Create(nil);
  try
    FTable.Open;
    FTable.Insert;
    FTable.FieldByName('relationname').AsString := FTableName2;
    FTable.Post;

    FFieldName2 := 'USR$TEST' + IntToStr(Random(1000000)) + 'F';
    Check(AddTableField(FFieldName2, FTableName2, DomainName));
  finally
    FTable.Free;
  end;

  ReConnect;

  FQ.Close;
  FQ.SQL.Text := 'SELECT r.id, f.id FROM at_relations r ' +
    'LEFT JOIN at_relation_fields f ON f.relationkey = r.id ' +
    'WHERE r.relationname = :RN and f.fieldname = :FN';
  FQ.ParamByName('RN').ASString := FTableName2;
  FQ.ParamByname('FN').AsString := FFieldName2;
  FQ.ExecQuery;
  Check(not FQ.Eof);

  IDT := FQ.FieldByName('ID').AsInteger;
  IDF := FQ.FieldByName('ID1').AsInteger;

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

  FDomainName := 'USR$TEST' + IntToStr(Random(1000000));

  FField := TgdcField.Create(nil);
  try
    FField.Open;
    FField.Insert;
    FField.FieldByName('fieldname').AsString := FDomainName;
    FField.FieldByName('lname').AsString := FDomainName;
    FField.FieldByName('setlistlname').AsString := 'Test';
    FField.FieldByName('ffieldtype').AsInteger := 37;
    FField.FieldByName('flength').AsInteger := 120;
    FField.FieldByName('fcharlength').AsInteger := 120;
    FField.FieldByName('charset').AsString := 'WIN1251';
    FField.FieldByName('collation').AsString := 'PXW_CYRL';
    FField.FieldByName('settable').AsString := FTableName2;
    FField.FieldByName('setlistfield').AsString := FFieldName2;
    FField.FieldByName('settablekey').AsInteger := IDT;
    FField.FieldByName('setlistfieldkey').AsInteger := IDF;
    FField.Post;
  finally
    FField.Free;
  end;

  ReConnect;

  FFieldName := 'USR$TEST' + IntToStr(Random(1000000)) + 'F';
  Check(AddTableField(FFieldName, FTableName, FDomainName));

  ReConnect;

  AddRecordToTable;

  ReConnect;

  FDBStateAfterCreate := GetDBState;
end; 

procedure TgdcSetSaveToXMLTest.TestDrop;
var
  FTableField: TgdcTableField;
  FTable: TgdcTable;
  FDomain: TgdcField;
begin
  Check(FFieldName > '');
  Check(FTableName > '');
  Check(FDomainName > '');
  Check(FTableName2 > ''); 

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

  FTable := GetTableClass.Create(nil);
  try
    FTable.SubSet := 'ByName';
    FTable.ParamByName(FTable.GetListField(FTable.SubType)).AsString := FTableName;
    FTable.Open;
    Check(not FTable.EOF);
    FTable.Delete;

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

    FTableField := TgdcTableField.Create(nil);
    try
      FTableField.SubSet := 'ByName';
      FTableField.ParamByName(FTableField.GetListField(FTableField.SubType)).AsString := FFieldName2;
      FTableField.Open;
      Check(not FTableField.EOF);
      FTableField.Delete;
    finally
      FTableField.Free;
    end;
    
    FTable.Close;
    FTable.ParamByName(FTable.GetListField(FTable.SubType)).AsString := FTableName2;
    FTable.Open;
    Check(not FTable.EOF);
    FTable.Delete;
  finally
    FTable.Free;
  end;

  ReConnect;
  Check(FDBState = GetDBState);
end;

procedure TgdcSetSaveToXMLTest.TestAddToSetting;
var
  FTable: TgdcTable;
  FTableField: TgdcTableField;
  FDomain: TgdcField;
  Obj: TgdcBase;
  gdcSetting: TgdcSetting;
  gdcSettingPos: TgdcSettingPos;
begin
  Check(FTableName > '');
  Check(FTableName2 > '');  

  FTable := GetTableClass.Create(nil);
  try
    FTable.SubSet := 'ByName';
    FTable.ParamByName(FTable.GetListField(FTable.SubType)).AsString := FTableName2;
    FTable.Open;
    Check(not FTable.EOF);

    FQ.Close;
    FQ.SQL.Text := 'SELECT id FROM ' + FTableName2;
    FQ.ExecQuery;
    Check(not FQ.EOF);

    gdcSetting := TgdcSetting.Create(nil);
    try
      gdcSetting.Open;
      gdcSetting.Insert;
      gdcSetting.FieldByName('NAME').AsString := FTableName + 'part1';
      gdcSetting.Post;

      gdcSettingPos := TgdcSettingPos.Create(nil);
      try
        gdcSettingPos.SubSet := 'BySetting';
        gdcSettingPos.ParamByName('settingkey').AsInteger := gdcSetting.ID;
        gdcSettingPos.Open;
        gdcSettingPos.AddPos(FTable, True);

        gdcSettingPos.Close;

        gdcSetting.SaveSettingToBlob(sttXML);
        gdcSetting.SaveToFile(GetFileName(1));
        gdcSetting.Delete;

        gdcSetting.Insert;
        gdcSetting.FieldByName('NAME').AsString := FTableName + 'part2';
        gdcSetting.Post;

        gdcSettingPos.ParamByName('settingkey').AsInteger := gdcSetting.ID;
        gdcSettingPos.Open;

        Obj := CgdcBase(GetClass(GetRecordClass)).CreateSubType(nil, FTableName2, 'ByID');
        try
          Obj.Database := gdcBaseManager.Database;
          Obj.Transaction := gdcBaseManager.ReadTransaction;
          while not FQ.Eof do
          begin
            Obj.ID := FQ.FieldByName('ID').AsInteger;
            Obj.Open;
            gdcSettingPos.AddPos(Obj, False);
            Obj.Close;
            FQ.Next;
          end;
        finally
          Obj.Free;
        end;

        gdcSettingPos.Close;
        gdcSetting.SaveSettingToBlob(sttXML);
        gdcSetting.SaveToFile(GetFileName(2));
        gdcSetting.Delete;

        FTable.Close;
        FTable.ParamByName(FTable.GetListField(FTable.SubType)).AsString := FTableName;
        FTable.Open;
        Check(not FTable.EOF);


        gdcSetting.Insert;
        gdcSetting.FieldByName('NAME').AsString := FTableName + 'part3';
        gdcSetting.Post;

        gdcSettingPos.ParamByName('settingkey').AsInteger := gdcSetting.ID;
        gdcSettingPos.Open;

        FDomain := TgdcField.Create(nil);
        try
          FDomain.SubSet := 'ByName';
          FDomain.ParamByName(FDomain.GetListField(FDomain.SubType)).AsString := FDomainName;
          FDomain.Open;
          Check(not FDomain.EOF);

          gdcSettingPos.AddPos(FDomain, False);
        finally
          FDomain.Free;
        end;
      
        gdcSettingPos.AddPos(FTable, False);
        gdcSettingPos.Close;

        gdcSetting.SaveSettingToBlob(sttXML);
        gdcSetting.SaveToFile(GetFileName(3));
        gdcSetting.Delete;

        gdcSetting.Insert;
        gdcSetting.FieldByName('NAME').AsString := FTableName + 'part4';
        gdcSetting.Post;

        gdcSettingPos.ParamByName('settingkey').AsInteger := gdcSetting.ID;
        gdcSettingPos.Open;

        FTableField := TgdcTableField.Create(nil);
        try
          FTableField.SubSet := 'ByName';
          FTableField.ParamByName(FTableField.GetListField(FTableField.SubType)).AsString := FFieldName;
          FTableField.Open;
          Check(not FTableField.EOF);
          gdcSettingPos.AddPos(FTableField, False);
        finally
          FTableField.Free;
        end;

        gdcSettingPos.Close;

        gdcSetting.SaveSettingToBlob(sttXML);
        gdcSetting.SaveToFile(GetFileName(4));
        gdcSetting.Delete;

        FQ.Close;
        FQ.SQL.Text := 'SELECT id FROM ' + FTableName;
        FQ.ExecQuery;
        Check(not FQ.EOF);

        gdcSetting.Insert;
        gdcSetting.FieldByName('NAME').AsString := FTableName + 'part5';
        gdcSetting.Post;

        gdcSettingPos.ParamByName('settingkey').AsInteger := gdcSetting.ID;
        gdcSettingPos.Open;

        Obj := CgdcBase(GetClass(GetRecordClass)).CreateSubType(nil, FTableName, 'ByID');
        try
          Obj.Database := gdcBaseManager.Database;
          Obj.Transaction := gdcBaseManager.ReadTransaction;
          while not FQ.Eof do
          begin
            Obj.ID := FQ.FieldByName('ID').AsInteger;
            Obj.Open;
            gdcSettingPos.AddPos(Obj, True);
            Obj.Close;
            FQ.Next;
          end;
        finally
          Obj.Free;
        end;

        gdcSetting.SaveSettingToBlob(sttXML);
        gdcSetting.SaveToFile(GetFileName(5));
        gdcSetting.Delete;
      finally
        gdcSettingPos.Free;
      end;
    finally
      gdcSetting.Free;
    end;
  finally
    FTable.Free;
  end;
end;

procedure TgdcSetSaveToXMLTest.TestLoadSetting;
var
  gdcSetting: TgdcSetting;
begin
  Check(FTableName > '');

  gdcSetting := TgdcSetting.Create(nil);
  try
    gdcSetting.Open;
    gdcSetting.LoadFromFile(GetFileName(1));
    gdcSetting.GoToLastLoadedSetting;
    ActivateSettings(IntToStr(gdcSetting.ID));

    gdcSetting.LoadFromFile(GetFileName(2));
    gdcSetting.GoToLastLoadedSetting;
    ActivateSettings(IntToStr(gdcSetting.ID));

    gdcSetting.LoadFromFile(GetFileName(3));
    gdcSetting.GoToLastLoadedSetting;
    ActivateSettings(IntToStr(gdcSetting.ID));

    gdcSetting.LoadFromFile(GetFileName(4));
    gdcSetting.GoToLastLoadedSetting;
    ActivateSettings(IntToStr(gdcSetting.ID));

    gdcSetting.LoadFromFile(GetFileName(5));
    gdcSetting.GoToLastLoadedSetting;
    ActivateSettings(IntToStr(gdcSetting.ID));

    gdcSetting.Close;
    gdcSetting.SubSet := 'ByName';
    gdcSetting.ParamByName(gdcSetting.GetListField(gdcSetting.SubType)).AsString := FTableName + 'part1';
    gdcSetting.Open;
    gdcSetting.Delete;

    gdcSetting.Close;
    gdcSetting.ParamByName(gdcSetting.GetListField(gdcSetting.SubType)).AsString := FTableName + 'part2';
    gdcSetting.Open;
    gdcSetting.Delete;

    gdcSetting.Close;
    gdcSetting.ParamByName(gdcSetting.GetListField(gdcSetting.SubType)).AsString := FTableName + 'part3';
    gdcSetting.Open;
    gdcSetting.Delete;

    gdcSetting.Close;
    gdcSetting.ParamByName(gdcSetting.GetListField(gdcSetting.SubType)).AsString := FTableName + 'part4';
    gdcSetting.Open;
    gdcSetting.Delete;

    gdcSetting.Close;
    gdcSetting.ParamByName(gdcSetting.GetListField(gdcSetting.SubType)).AsString := FTableName + 'part5';
    gdcSetting.Open;
    gdcSetting.Delete;
  finally
    gdcSetting.Free;
  end;

  TestMetaData;
  Check(FDBStateAfterCreate = GetDBState);
  
  Check(DeleteFile(GetFileName(1)));
  Check(DeleteFile(GetFileName(2)));
  Check(DeleteFile(GetFileName(3)));
  Check(DeleteFile(GetFileName(4)));
  Check(DeleteFile(GetFileName(5)));
  TestDrop;  
end;

{ TDatabaseTest }

procedure TDatabaseTest.TestExternal_BIN_AND;
begin
  FQ.SQL.Text :=
    'SELECT * FROM rdb$functions WHERE rdb$module_name = ''ib_udf'' ' +
       'AND rdb$function_name IN (''BIN_AND'', ''BIN_OR'', ''BIN_SHL'') ';
  FQ.ExecQuery;
  Check(FQ.EOF);

  // если используется внешняя функция BIN_AND, то на таком
  // запросе произойдет исключение
  FQ.Close;
  FQ.SQL.Text :=
    'SELECT BIN_AND(536871184, BIN_SHL(1, 32 - 1)) from rdb$database';
  FQ.ExecQuery;
end;

procedure TDatabaseTest.TestRoleRights;
begin
  FQ.SQL.Text :=
    'SELECT'#13#10 +
    '  r.rdb$relation_name,'#13#10 +
    '  p.cnt'#13#10 +
    'FROM'#13#10 +
    '  rdb$relations r LEFT JOIN'#13#10 +
    '  ('#13#10 +
    '    SELECT rdb$relation_name, COUNT(*) AS cnt'#13#10 +
    '    FROM rdb$user_privileges'#13#10 +
    '    WHERE rdb$user = ''ADMINISTRATOR'' '#13#10 +
    '      AND rdb$user_type = 13 AND rdb$object_type = 0'#13#10 +
    '    GROUP BY rdb$relation_name'#13#10 +
    '  ) p ON r.rdb$relation_name = p.rdb$relation_name'#13#10 +
    'WHERE'#13#10 +
    '  r.rdb$system_flag = 0 AND COALESCE(p.cnt, 0) <> 5';
  FQ.ExecQuery;
  Check(FQ.EOF);
end;

initialization
  RegisterTest('DB', TDatabaseTest.Suite);

  RegisterTest('DB', TgdcMetaDataTest.Suite);
  RegisterTest('DB\TgdcMetaDataTest\StandartTables', TgdcPrimeTableTest.Suite);
  RegisterTest('DB\TgdcMetaDataTest\StandartTables', TgdcSimpleTableTest.Suite);
  RegisterTest('DB\TgdcMetaDataTest\StandartTables', TgdcTreeTableTest.Suite);
  RegisterTest('DB\TgdcMetaDataTest\StandartTables', TgdcTableToTableTest.Suite);
  RegisterTest('DB\TgdcMetaDataTest\StandartTables', TgdcLBRBTreeTest.Suite);
  RegisterTest('DB\TgdcMetaDataTest\Set', TgdcSetTest.Suite);
  RegisterTest('DB\TgdcMetaDataTest\SaveSettingXML', TgdcTreeTableSaveToXMLTest.Suite);
  RegisterTest('DB\TgdcMetaDataTest\SaveSettingXML', TgdcSimpleTableSaveToXMLTest.Suite);
  RegisterTest('DB\TgdcMetaDataTest\SaveSettingXML', TgdcTableToTableSaveToXMLTest.Suite);
  RegisterTest('DB\TgdcMetaDataTest\SaveSettingXML', TgdcSetSaveToXMLTest.Suite);
  Randomize;
end.
