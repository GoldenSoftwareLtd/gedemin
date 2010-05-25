
unit Test_gdcMetaData_unit;

interface

uses
  TestFrameWork;

type
  TgdcMetaDataTest = class(TTestCase)
  private
    function GetDBState: String;

  published
    procedure TestLBRBTreeCreation;
  end;

implementation

uses
  gdcMetaData, gd_security, at_frmSQLProcess, IBSQL, gdcBaseInterface;

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

procedure TgdcMetaDataTest.TestLBRBTreeCreation;
var
  LBRBTree: TgdcLBRBTreeTable;
  DBState: String;
begin
  DBState := GetDBState;

  LBRBTree := TgdcLBRBTreeTable.Create(nil);
  try
    LBRBTree.Open;
    LBRBTree.Insert;
    LBRBTree.FieldByName('relationname').AsString := 'USR$TTESTT';
    LBRBTree.Post;
  finally
    LBRBTree.Free;
  end;

  IBLogin.LogOff;
  IBLogin.Login(False, True);

  Check(not frmSQLProcess.IsError);

  LBRBTree := TgdcLBRBTreeTable.Create(nil);
  try
    LBRBTree.SubSet := 'ByName';
    LBRBTree.ParamByName(LBRBTree.GetListField(LBRBTree.SubType)).AsString := 'USR$TTESTT';
    LBRBTree.Open;
    Check(not LBRBTree.EOF);
    LBRBTree.Delete;
  finally
    LBRBTree.Free;
  end;

  IBLogin.LogOff;
  IBLogin.Login(False, True);

  Check(not frmSQLProcess.IsError);

  Check(DBState = GetDBState);
end;

initialization
  RegisterTest('', TgdcMetaDataTest.Suite);
end.
