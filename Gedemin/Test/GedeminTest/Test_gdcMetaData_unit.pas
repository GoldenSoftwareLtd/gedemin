
unit Test_gdcMetaData_unit;

interface

uses
  TestFrameWork, IBDatabase;

type
  TgdcMetaDataTest = class(TTestCase)
  private
    function GetDBState: String;
    procedure CheckConsistency(Tr: TIBTransaction);

  published
    procedure TestCreateLBRBTree;
    procedure TestLBRBTree;
    procedure TestRestrLBRBTree;
    procedure TestDropLBRBTree;
  end;

implementation

uses
  Classes, Windows, IB, gdcMetaData, gd_security,
  at_frmSQLProcess, IBSQL, gdcBaseInterface, gd_KeyAssoc,
  SysUtils, gdcLBRBTreeMetaData, jclStrings;

var
  FLBRBTreeName, FDBState: String;

procedure TgdcMetaDataTest.CheckConsistency(Tr: TIBTransaction);
var
  q: TIBSQL;
begin
  q := TIBSQL.Create(nil);
  try
    q.Transaction := Tr;

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
    q.SQL.Text := 'SELECT a.id || '','' || b.id FROM ' + FLBRBTreeName + ' a JOIN ' + FLBRBTreeName
      + ' b ON a.lb > b.lb AND a.lb <= b.rb AND a.rb > b.rb';
    q.ExecQuery;
    Check(q.EOF, 'Overlapped intervals (right). ' + q.Fields[0].AsString);
  finally
    q.Free;
  end;
end;

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
  Check(IBLogin.LoggedIn);

  Check(StrIPos('test.fdb', IBLogin.Database.DatabaseName) > 0, 'Выполнение возможно только на тестовой БД');

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
  Check(IBLogin.LoggedIn);
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
  I, J, ID: Integer;
  q: TIBSQL;
  Tr: TIBTransaction;
  //SL: TStringList;
begin
  Check(IBLogin.LoggedIn);
  Check(FLBRBTreeName > '');

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
      for I := 1 to 1200 do
      begin
        q.Close;

        J := Random(20);
        case J of
          0..14:
          begin
            ID := gdcBaseManager.GetNextID;

            if (L.Count = 0) or (Random(10) = 9) then
              q.SQL.Text := 'INSERT INTO ' + FLBRBTreeName +
                ' (id, parent) VALUES (' + IntToStr(ID) + ', NULL)'
            else begin
              q.SQL.Text := 'INSERT INTO ' + FLBRBTreeName +
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
                q.SQL.Text := 'UPDATE ' + FLBRBTreeName +
                  ' SET parent=NULL' +
                  ' WHERE id=' + IntToStr(L.Keys[Random(L.Count)])
              else
                q.SQL.Text := 'UPDATE ' + FLBRBTreeName +
                  ' SET parent=' + IntToStr(L.Keys[Random(L.Count)]) +
                  ' WHERE id=' + IntToStr(L.Keys[Random(L.Count)]);
              try
                q.ExecQuery;
                //SL.Add(Trim(q.SQL.Text) + ';');
              except
                on E: Exception do
                  if Pos('cycle', E.Message) = 0 then
                    raise;
              end;
            end;
          end;

          19:
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
              q.SQL.Text := 'DELETE FROM ' + FLBRBTreeName + ' WHERE id=' + IntToStr(ID);
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
        Check(False, E.Message + ' Code: ' + IntToStr(E.SQLCode));
    end;

    q.Close;
    q.SQL.Text := 'SELECT COUNT(*) FROM ' + FLBRBTreeName;
    q.ExecQuery;
    Check(q.Fields[0].AsInteger = L.Count, 'Incorrect number of tree items.');
  finally
    q.Free;
    Tr.Free;
    L.Free;

    //SL.SaveToFile('d:\log.sql');
    //SL.Free;
  end;
end;

procedure TgdcMetaDataTest.TestRestrLBRBTree;
var
  Tr: TIBTransaction;
begin
  Check(IBLogin.LoggedIn);
  Check(FLBRBTreeName > '');

  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.DefaultAction := TACommit;
    Tr.StartTransaction;

    Check(RestrLBRBTree(FLBRBTreeName, Tr) = 1);
    CheckConsistency(Tr);
  finally
    Tr.Free;
  end;
end;

initialization
  RegisterTest('', TgdcMetaDataTest.Suite);
  Randomize;
end.
