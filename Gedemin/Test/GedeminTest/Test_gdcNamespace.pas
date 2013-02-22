unit Test_gdcNamespace;

interface

uses
  TestFrameWork, gsTestFrameWork, IBDatabase, gdcBase, classes, gdcNamespace;

type
  Tgs_gdcNamespaceTest = class(TgsDBTestCase)
  private
    function CheckTable(const AName: String): Boolean;
    function CheckNamespace(const AName: String): Boolean;
  protected
    FTableName, FTableName2, FNamespaceName: String;
    FNamespaceKey: Integer;

    function GetFileName: String;

    procedure TestCreateNamespace;
    procedure TestAddObject;
    procedure TestSaveNamespaceToFile;
    procedure TestLoadNamespaceFromFile;
    procedure TestAlwaysoverwrite;
    procedure TestSet;
    procedure TestIncludesiblings;
  published
    procedure DoTest;
  end;

implementation

uses
  gdcMetaData, Sysutils, Windows, gdcBaseInterface, gdcGood, IBSQL,
  gdcContacts;

const
  Alwaysoverwrite = 1;
  Dontremove = 1;
  Includesiblings = 1;
  NotAlwaysoverwrite = 0;
  NotDontremove = 0;
  NotIncludesiblings = 0;  

procedure Tgs_gdcNamespaceTest.DoTest;
begin
  TestCreateNamespace;
  TestAddObject;
  TestSaveNamespaceToFile;
  TestLoadNamespaceFromFile;
  TestAlwaysoverwrite;
  TestSet;
  TestIncludesiblings;
end;

function Tgs_gdcNamespaceTest.CheckTable(const AName: String): Boolean;
begin
  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM rdb$relations WHERE rdb$relation_name = :RN';
  FQ.ParamByName('RN').AsString := AName;
  FQ.ExecQuery;
  Result := not FQ.EOF;
  FQ.Close;
end;

function Tgs_gdcNamespaceTest.CheckNamespace(const AName: String): Boolean;
begin
  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM at_namespace WHERE name = :n';
  FQ.ParamByName('n').AsString := AName;
  FQ.ExecQuery;
  Result := not FQ.Eof;
  FQ.Close;
end;

function Tgs_gdcNamespaceTest.GetFileName: String;
var
  TempPath: array[0..1023] of Char;
begin
  Check(FNamespacename > '');
  GetTempPath(SizeOf(TempPath), TempPath);
  Result := IncludeTrailingBackslash(TempPath) + FNamespacename + '.yml'
end;

procedure Tgs_gdcNamespaceTest.TestIncludesiblings;

  function Check_folder(const AName: String): Boolean;
  begin
    FQ.Close;
    FQ.SQL.Text := 'SELECT * FROM gd_contact WHERE contacttype = 0 AND name = :n';
    FQ.ParamByName('n').AsString := AName;
    FQ.ExecQuery;
    Result := not FQ.Eof;
    FQ.Close;
  end;

var
  F: TgdcFolder;
  Id1: Integer;
  Name1, Name2: String;
  Obj: TgdcNamespace;
begin
  Name1 := 'TEST' + IntToStr(Random(1000000)) + 'F';
  Name2 := 'TEST' + IntToStr(Random(1000000)) + 'F';
  F := TgdcFolder.Create(nil);
  try
    F.Open;
    F.Insert;
    F.FieldByName('contacttype').AsInteger := 0;
    F.FieldByname('name').AsString := Name1;
    F.Post;
    ID1 := F.ID;

    F.Insert;
    F.FieldByName('parent').AsInteger := ID1;
    F.FieldByName('contacttype').AsInteger := 0;
    F.FieldByname('name').AsString := Name2;
    F.Post; 
  finally
    F.Free;
  end;

  TestCreateNamespace;

  ReConnect;

  F := TgdcFolder.Create(nil);
  try
    F.SubSet := 'ByID';
    F.Id := ID1;
    F.Open;
    Check(not F.Eof);
    TgdcNamespace.AddObject(FNamespacekey,
      F.FieldByName(F.GetListField(F.SubType)).AsString,
      F.ClassName,
      F.Subtype,
      F.GetRuid.XID,
      F.GetRuid.DBID,
      FTr, Alwaysoverwrite, NotDontremove, Includesiblings);
  finally
    F.Free;
  end;

  FTr.Commit;
  FTr.StartTransaction;

  Obj := TgdcNamespace.Create(nil);
  try
    Obj.SubSet := 'ByName';
    Obj.ParamByName(Obj.GetListField(Obj.SubType)).AsString := FNamespaceName;
    Obj.Open;
    Check(not Obj.Eof);

    Obj.SaveNamespaceToFile(GetFileName);
    FQ.Close;
    FQ.SQL.Text := 'SELECT count(*) FROM at_object WHERE namespacekey = :nk AND (objectname = :n1 or objectname = :n2)';
    FQ.ParamByName('nk').AsInteger := FNamespaceKey;
    FQ.ParamByName('n1').AsString := Name1;
    FQ.ParamByName('n2').AsString := Name2;
    FQ.ExecQuery;

    Check(not FQ.Eof);
    Check(FQ.FieldByName('count').AsInteger = 2);
    FQ.Close;

    Obj.DeleteNamespaceWithObjects;
  finally
    Obj.Free;
  end;

  Check(not Check_folder(Name1));
  Check(not Check_folder(Name2));

  Obj := TgdcNamespace.Create(nil);
  try
    Obj.Open;
    Obj.LoadFromFile(GetFileName);
  finally
    Obj.Free;
  end;

  ReConnect;

  Check(Check_folder(Name1));
  Check(Check_folder(Name2));

  Obj := TgdcNamespace.Create(nil);
  try
    Obj.SubSet := 'ByName';
    Obj.ParamByName(Obj.GetListField(Obj.SubType)).AsString := FNamespaceName;
    Obj.Open;
    Check(not Obj.Eof);

    Obj.SaveNamespaceToFile(GetFileName);
    Obj.DeleteNamespaceWithObjects;
  finally
    Obj.Free;
  end;

  ReConnect;
end;

procedure Tgs_gdcNamespaceTest.TestLoadNamespaceFromFile;
var
  Obj: TgdcNamespace;
begin
  Obj := TgdcNamespace.Create(nil);
  try
    Obj.Open;
    Obj.LoadFromFile(GetFileName);
  finally
    Obj.Free;
  end;

  ReConnect;

  Check(CheckTable(FTableName));
  
  FQ.SQL.Text := 'SELECT * FROM at_namespace WHERE name = :n';
  FQ.ParamByName('n').AsString := FNamespaceName;
  FQ.ExecQuery;
  Check(not FQ.EOF, 'Namespace not found!');
  FQ.Close;

  Obj := TgdcNamespace.Create(nil);
  try
    Obj.SubSet := 'ByName';
    Obj.ParamByName(Obj.GetListField(Obj.SubType)).AsString := FNamespaceName;
    Obj.Open;
    Check(not Obj.Eof);
    Obj.DeleteNamespaceWithObjects;
  finally
    Obj.Free;
  end;

  ReConnect;
  
  Check(not CheckTable(FTableName));
  Check(not CheckNamespace(FNamespacename));  
end;

procedure Tgs_gdcNamespaceTest.TestSaveNamespaceToFile;
var
  Obj: TgdcNamespace;
begin
  Obj := TgdcNamespace.Create(nil);
  try
    Obj.SubSet := 'ByName';
    Obj.ParamByName(Obj.GetListField(Obj.SubType)).AsString := FNamespaceName;
    Obj.Open;

    Check(not Obj.Eof);

    Obj.SaveNamespaceToFile(GetFileName);
    Obj.DeleteNamespaceWithObjects;
  finally
    Obj.Free;
  end;

  ReConnect;

  Check(not CheckNamespace(FNamespacename));
  Check(not CheckTable(FTableName));
end;

procedure Tgs_gdcNamespaceTest.TestCreateNamespace;
var
  Obj: TgdcNamespace;
begin
  FNamespacename := 'Test_namespace';

  Obj := TgdcNamespace.Create(nil);
  try
    Obj.Open;
    Obj.Insert;
    Obj.FieldByName('name').AsString := FNamespacename;
    Obj.Post;
    FNamespacekey := Obj.ID;
  finally
    Obj.Free;
  end;

  Check(FNamespacekey > 0);
end;

procedure Tgs_gdcNamespaceTest.TestAddObject;
var
  FTable: TgdcTable;
  RUID: TRUID;
begin
  FTableName := 'USR$TEST' + IntToStr(Random(1000000)) + 'A';

  FTable := TgdcPrimeTable.Create(nil);
  try
    FTable.Open;
    FTable.Insert;
    FTable.FieldByName('relationname').AsString := FTableName;
    FTable.Post;
  finally
    FTable.Free;
  end;

  ReConnect;

  FTable := TgdcPrimeTable.Create(nil);
  try
    FTable.SubSet := 'ByName';
    FTable.ParamByName(FTable.GetListField(FTable.SubType)).AsString := FTableName;
    FTable.Open;
    Check(not FTable.EOF);

    RUID := FTable.GetRuid;
    TgdcNamespace.AddObject(FNamespacekey,
      FTable.FieldByName(FTable.GetListField(FTable.SubType)).AsString,
      FTable.ClassName,
      FTable.Subtype,
      RUID.XID,
      RUID.DBID,
      FTr);
  finally
    FTable.Free;      
  end;

  FTr.Commit;
  FTr.StartTransaction;

  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM at_object WHERE xid = :xid and dbid = :dbid';
  FQ.ParamByName('xid').AsInteger := RUID.XID;
  FQ.ParamByName('dbid').AsInteger := RUID.DBID;
  FQ.ExecQuery;

  Check(not FQ.EOF);
  FQ.Close;
end;

procedure Tgs_gdcNamespaceTest.TestAlwaysoverwrite;
var
  LShortName: String;
  Obj: TgdcNamespace;
  FTable: TgdcTable;
begin
  FTableName := 'USR$TEST' + IntToStr(Random(1000000)) + 'A';
  FTableName2 := 'USR$TEST' + IntToStr(Random(1000000)) + 'A';

  FTable := TgdcPrimeTable.Create(nil);
  try
    FTable.Open;
    FTable.Insert;
    FTable.FieldByName('relationname').AsString := FTableName;
    FTable.Post;

    FTable.Insert;
    FTable.FieldByName('relationname').AsString := FTableName2;
    FTable.Post;
  finally
    FTable.Free;
  end;

  TestCreateNamespace;

  ReConnect;

  FTable := TgdcPrimeTable.Create(nil);
  try
    FTable.SubSet := 'ByName';
    FTable.ParamByName(FTable.GetListField(FTable.SubType)).AsString := FTableName;
    FTable.Open;
    Check(not FTable.EOF);

    TgdcNamespace.AddObject(FNamespacekey,
      FTable.FieldByName(FTable.GetListField(FTable.SubType)).AsString,
      FTable.ClassName,
      FTable.Subtype,
      FTable.GetRuid.XID,
      FTable.GetRuid.DBID,
      FTr, NotAlwaysoverwrite, Dontremove);

    FTable.Close;
    FTable.ParamByName(FTable.GetListField(FTable.SubType)).AsString := FTableName2;
    FTable.Open;
    Check(not FTable.EOF);

    LShortName := FTable.FieldByName('lshortname').AsString;
    TgdcNamespace.AddObject(FNamespacekey,
      FTable.FieldByName(FTable.GetListField(FTable.SubType)).AsString,
      FTable.ClassName,
      FTable.Subtype,
      FTable.GetRuid.XID,
      FTable.GetRuid.DBID,
      FTr, Alwaysoverwrite, Dontremove);
  finally
    FTable.Free;
  end;

  FTr.Commit;
  FTr.StartTransaction;

  Obj := TgdcNamespace.Create(nil);
  try
    Obj.SubSet := 'ByName';
    Obj.ParamByName(Obj.GetListField(Obj.SubType)).AsString := FNamespaceName;
    Obj.Open;

    Check(not Obj.Eof);

    Obj.SaveNamespaceToFile(GetFileName);
    Obj.DeleteNamespaceWithObjects;
  finally
    Obj.Free;
  end;

  FTable := TgdcPrimeTable.Create(nil);
  try
    FTable.SubSet := 'ByName';
    FTable.ParamByName(FTable.GetListField(FTable.SubType)).AsString := FTableName;
    FTable.Open;
    Check(not FTable.EOF);

    FTable.Edit;
    FTable.FieldByName('lshortname').AsString := FTableName + FNamespaceName;
    FTable.Post;

    FTable.Close;
    FTable.ParamByName(FTable.GetListField(FTable.SubType)).AsString := FTableName2;
    FTable.Open;
    Check(not FTable.EOF);

    FTable.Edit;
    FTable.FieldByName('lshortname').AsString := FTableName2 + FNamespaceName;
    FTable.Post;
  finally
    FTable.Free;
  end;

  ReConnect;

  Obj := TgdcNamespace.Create(nil);
  try
    Obj.Open;
    Obj.LoadFromFile(GetFileName);

    Obj.Close;
    Obj.SubSet := 'ByName';
    Obj.ParamByName(Obj.GetListField(Obj.SubType)).AsString := FNamespaceName;
    Obj.Open;
    Check(not Obj.Eof);
    Obj.DeleteNamespaceWithObjects;
  finally
    Obj.Free;
  end;

  ReConnect;

  FTable := TgdcPrimeTable.Create(nil);
  try
    FTable.SubSet := 'ByName';
    FTable.ParamByName(FTable.GetListField(FTable.SubType)).AsString := FTableName;
    FTable.Open;
    Check(not FTable.EOF);
    Check(AnsiCompareText(FTable.FieldByName('lshortname').AsString, FTableName + FNamespaceName) = 0);
    FTable.Delete;

    FTable.Close;
    FTable.ParamByName(FTable.GetListField(FTable.SubType)).AsString := FTableName2;
    FTable.Open;
    Check(not FTable.EOF);
    Check(AnsiCompareText(FTable.FieldByName('lshortname').AsString, LShortName) = 0);
    FTable.Delete;
  finally
    FTable.Free;
  end;

  ReConnect;
end;

procedure Tgs_gdcNamespaceTest.TestSet;

  function Check_gd_good_tax(GoodKey: Integer): Integer;
  begin
    Result := 0;
    FQ.Close;
    FQ.SQL.Text := 'SELECT count(*) FROM gd_goodtax WHERE goodkey = :gk';
    FQ.ParamByName('gk').AsInteger := GoodKey;
    FQ.ExecQuery;
    if not FQ.Eof then
      Result := FQ.FieldByName('count').AsInteger;
    FQ.Close;
  end;
var
  Good: TgdcGood;
  ID: Integer;
  q: TIBSQL;
  Obj: TgdcNamespace;
  Count: Integer;
begin
  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM gd_goodgroup WHERE parent is null';
  FQ.ExecQuery;
  Check(not FQ.Eof);

  Good := TgdcGood.Create(nil);
  try
    Good.Open;
    Good.Insert;
    Good.FieldByName('name').AsString := 'Test_Good';
    Good.FieldByname('valuekey').AsInteger := 3000001;
    Good.FieldByname('groupkey').AsInteger := FQ.FieldByName('id').AsInteger;
    Good.Post;
    ID := Good.ID;
  finally
    Good.Free;
  end;
  
  FQ.Close;
  FQ.SQL.Text := 'SELECT first 2 * FROM gd_tax';
  FQ.ExecQuery;
  Check(not FQ.Eof);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTr;
    q.SQL.Text := 'INSERT INTO gd_goodtax (goodkey, taxkey) VALUES(:gk, :tk)';
    while not FQ.Eof do
    begin
      q.Close;
      q.ParamByName('gk').AsInteger := ID;
      q.ParamByName('tk').AsInteger := FQ.FieldByName('id').AsInteger;
      q.ExecQuery;
      FQ.Next;
    end;
  finally
    q.Free;
  end;

  FQ.Close;
  FTr.Commit;
  FTr.StartTransaction;

  Count := Check_gd_good_tax(ID);
  Check(Count > 0);

  TestCreateNamespace;

  ReConnect;

  Good := TgdcGood.Create(nil);
  try
    Good.SubSet := 'ByID';
    Good.Id := ID;
    Good.Open;
    Check(not Good.Eof);
    TgdcNamespace.AddObject(FNamespacekey,
      Good.FieldByName(Good.GetListField(Good.SubType)).AsString,
      Good.ClassName,
      Good.Subtype,
      Good.GetRuid.XID,
      Good.GetRuid.DBID,
      FTr, Alwaysoverwrite, Dontremove);
  finally
    Good.Free;
  end;

  FTr.Commit;
  FTr.StartTransaction;

  Obj := TgdcNamespace.Create(nil);
  try
    Obj.SubSet := 'ByName';
    Obj.ParamByName(Obj.GetListField(Obj.SubType)).AsString := FNamespaceName;
    Obj.Open;
    Check(not Obj.Eof);

    Obj.SaveNamespaceToFile(GetFileName);
    Obj.DeleteNamespaceWithObjects;
  finally
    Obj.Free;
  end;

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTr;
    q.SQL.Text := 'DELETE FROM gd_goodtax WHERE goodkey = :gk';
    q.ParamByName('gk').AsInteger := ID;
    q.ExecQuery;
  finally
    q.Free;
  end;

  FTr.Commit;
  FTr.StartTransaction;

  Check(Check_gd_good_tax(ID) = 0);

  Obj := TgdcNamespace.Create(nil);
  try
    Obj.Open;
    Obj.LoadFromFile(GetFileName);

    Obj.Close;
    Obj.SubSet := 'ByName';
    Obj.ParamByName(Obj.GetListField(Obj.SubType)).AsString := FNamespaceName;
    Obj.Open;
    Check(not Obj.Eof);
    Obj.DeleteNamespaceWithObjects;
  finally
    Obj.Free;
  end;

  ReConnect;

  Check(Check_gd_good_tax(ID) = count);

  Good := TgdcGood.Create(nil);
  try
    Good.SubSet := 'ByID';
    Good.Id := ID;
    Good.Open;
    Check(not Good.Eof);
    Good.Delete;
  finally
    Good.Free;
  end;
end;

initialization
  RegisterTest('DB', Tgs_gdcNamespaceTest.Suite);
end.
