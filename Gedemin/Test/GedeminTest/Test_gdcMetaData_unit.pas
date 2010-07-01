
unit Test_gdcMetaData_unit;

interface

uses
  TestFrameWork;

type
  TgdcMetaDataTest = class(TTestCase)
  private
    function GetDBState: String;

  published
    procedure TestCreateLBRBTree;
    procedure TestLBRBTree;
    procedure TestDropLBRBTree;
  end;

implementation

uses
  gdcMetaData, gd_security, at_frmSQLProcess, IBSQL, IBDatabase,
  gdcBaseInterface, gd_KeyAssoc, SysUtils;

var
  FLBRBTreeName, FDBState: String;

function TgdcMetaDataTest.GetDBState: String;
var
  q: TIBSQL;
begin
  Result := '';

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;

    q.SQL.Text := 'SELECT LIST(TRIM(rdb$field_name)) FROM rdb$relation_fields';
    q.ExecQuery;
    Result := Result + q.Fields[0].AsTrimString;
    q.Close;

    q.SQL.Text := 'SELECT LIST(TRIM(rdb$procedure_name)) FROM rdb$procedures';
    q.ExecQuery;
    Result := Result + q.Fields[0].AsTrimString;
    q.Close;

    q.SQL.Text := 'SELECT LIST(TRIM(rdb$trigger_name)) FROM rdb$triggers';
    q.ExecQuery;
    Result := Result + q.Fields[0].AsTrimString;
    q.Close;

    q.SQL.Text := 'SELECT LIST(TRIM(rdb$exception_name)) FROM rdb$exceptions';
    q.ExecQuery;
    Result := Result + q.Fields[0].AsTrimString;
    q.Close;
  finally
    q.Free;
  end;
end;

procedure TgdcMetaDataTest.TestCreateLBRBTree;
var
  LBRBTree: TgdcLBRBTreeTable;
begin
  FLBRBTreeName := 'USR$TEST' + IntToStr(Random(10)) + 'LBRBTREE';
  FDBState := GetDBState;

  LBRBTree := TgdcLBRBTreeTable.Create(nil);
  try
    LBRBTree.Open;
    LBRBTree.Insert;
    LBRBTree.FieldByName('relationname').AsString := FLBRBTreeName;
    LBRBTree.Post;
  finally
    LBRBTree.Free;
  end;

  IBLogin.LogOff;
  IBLogin.Login(False, True);

  Check(not frmSQLProcess.IsError);
end;

procedure TgdcMetaDataTest.TestDropLBRBTree;
var
  LBRBTree: TgdcLBRBTreeTable;
begin
  Check(FLBRBTreeName > '');

  LBRBTree := TgdcLBRBTreeTable.Create(nil);
  try
    LBRBTree.SubSet := 'ByName';
    LBRBTree.ParamByName(LBRBTree.GetListField(LBRBTree.SubType)).AsString := FLBRBTreeName;
    LBRBTree.Open;
    Check(not LBRBTree.EOF);
    LBRBTree.Delete;
  finally
    LBRBTree.Free;
  end;

  IBLogin.LogOff;
  IBLogin.Login(False, True);

  Check(not frmSQLProcess.IsError);

  Check(FDBState = GetDBState);
end;

procedure TgdcMetaDataTest.TestLBRBTree;
var
  L: TgdKeyArray;
  I, ID: Integer;
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Check(FLBRBTreeName > '');

  L := TgdKeyArray.Create;
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    L.Sorted := False;

    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.DefaultAction := TACommit;
    Tr.StartTransaction;

    q.Transaction := Tr;

    for I := 1 to 10000 do
    begin
      q.Close;

      case Random(10) of
        0..6:
        begin
          if (L.Count = 0) or (Random(10) = 5) then
            q.SQL.Text := 'INSERT INTO ' + FLBRBTreeName + ' (id, parent) VALUES (:id, NULL)'
          else begin
            q.SQL.Text := 'INSERT INTO ' + FLBRBTreeName + ' (id, parent) VALUES (:id, :p)';
            q.ParamByName('p').AsInteger := L.Keys[Random(L.Count)];
          end;

          q.ParamByName('id').AsInteger := gdcBaseManager.GetNextID;
          try
            q.ExecQuery;
          except
            raise;
          end;

          L.Add(q.ParamByName('id').AsInteger);
        end;

        7..8:
        begin
          if L.Count > 0 then
          begin
            q.SQL.Text := 'UPDATE ' + FLBRBTreeName + ' SET parent=:p WHERE id=:id';
            q.ParamByName('p').AsInteger := L.Keys[Random(L.Count)];
            q.ParamByName('id').AsInteger := L.Keys[Random(L.Count)];
            try
              q.ExecQuery;
            except
              on E: Exception do ;
            end;
          end;
        end;

        9:
        begin
          if L.Count > 0 then
          begin
            ID := L.Keys[Random(L.Count)];

            q.Close;
            q.SQL.Text := 'SELECT id FROM ' + FLBRBTreeName +
              ' WHERE ' +
              ' lb >= (SELECT lb FROM ' + FLBRBTreeName + ' WHERE id=:ID) ' +
              '   AND rb <= (SELECT rb FROM ' + FLBRBTreeName + ' WHERE id=:ID)';
            q.ParamByName('id').AsInteger := ID;
            q.ExecQuery;
            while not q.EOF do
            begin
              L.Remove(q.Fields[0].AsInteger);
              q.Next;
            end;

            q.Close;
            q.SQL.Text := 'DELETE FROM ' + FLBRBTreeName + ' WHERE id=:id';
            q.ParamByName('id').AsInteger := ID;
            q.ExecQuery;
          end;
        end;
      end;

      q.Close;
      q.SQL.Text := 'SELECT a.lb FROM ' + FLBRBTreeName + ' a JOIN ' + FLBRBTreeName
        + ' b ON a.lb = b.lb AND a.id <> b.id';
      q.ExecQuery;
      Check(q.EOF, 'Duplicate LB = ' + q.Fields[0].AsString);

      q.Close;
      q.SQL.Text := 'SELECT a.id || '','' || b.id FROM ' + FLBRBTreeName + ' a JOIN ' + FLBRBTreeName
        + ' b ON a.lb < b.lb AND a.rb >= b.lb AND a.rb < b.rb';
      q.ExecQuery;
      Check(q.EOF, 'Overlapped intervals (left). ' + q.Fields[0].AsString);

      q.Close;
      q.SQL.Text := 'SELECT * FROM ' + FLBRBTreeName + ' a JOIN ' + FLBRBTreeName
        + ' b ON a.lb > b.lb AND a.lb <= b.rb AND a.rb > b.rb';
      q.ExecQuery;
      Check(q.EOF, 'Overlapped intervals (right)');
    end;
  finally
    q.Free;
    Tr.Free;
    L.Free;
  end;
end;

initialization
  RegisterTest('', TgdcMetaDataTest.Suite);
  Randomize;
end.
