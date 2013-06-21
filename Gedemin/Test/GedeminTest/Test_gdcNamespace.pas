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
    FTableNameForType: String;

    function GetFileName: String;

    procedure TestCreateNamespace;
    procedure TestAddObject;
    procedure TestSaveNamespaceToFile;
    procedure TestLoadNamespaceFromFile;
    procedure TestAlwaysoverwrite;
    procedure TestSet;
    procedure TestIncludesiblings;
    procedure TestType;
  published
    procedure DoTest;
  end;

implementation

uses
  gdcMetaData, Sysutils, Windows, gdcBaseInterface, gdcGood, IBSQL,
  gdcContacts, yaml_writer, yaml_parser, yaml_common;

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
  TestType;
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
begin
  Check(FNamespacename > '');
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

procedure Tgs_gdcNamespaceTest.TestType;

  procedure InsertRecord(const AStr: String; ADouble: Double; ACurr: Currency; ADateTime: TDateTime;
    const ABlob: String; AInt: Integer; ABigInt: Int64);
  var
    q: TIBSQL;
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := FTr;
      q.SQL.Text :=
        'INSERT INTO ' + FTableNameForType +
        '  (USR$FLOAT, USR$CURRENCY, USR$TIMESTAMP, USR$VARCHAR, USR$BLOB, USR$INT, USR$BIGINT) ' +
        '  VALUES(:f, :c, :t, :v, :b, :i, :bi)';
      q.ParamByName('f').AsDouble := ADouble;
      q.ParamByName('c').AsCurrency := ACurr;
      q.ParamByName('t').AsDateTime := ADateTime;
      q.ParamByName('v').AsString := AStr;
      q.ParamByName('b').AsString := ABlob;
      q.ParamByName('i').AsInteger := AInt;
      q.ParamByName('bi').AsInt64 := ABigInt;
      q.ExecQuery;
      q.Close;

      FTr.Commit;
      FTr.StartTransaction;
    finally
      q.Free;
    end;
  end;

  procedure WriteYAML(AStream: TStream);
  var
    Writer: TyamlWriter;
    q: TIBSQL;    
  begin
    Assert(AStream <> nil);

    Writer := TyamlWriter.Create(AStream);
    q := TIBSQL.Create(nil);
    try
      q.Transaction := FTr;
      q.SQL.Text := 'SELECT USR$FLOAT, USR$CURRENCY, USR$TIMESTAMP, ' +
        'USR$VARCHAR, USR$BLOB, USR$INT, USR$BIGINT FROM ' + FTableNameForType;
      q.ExecQuery;
      if not q.EOF then
      begin
        Writer.WriteKey('Fields');
        Writer.IncIndent;
        Writer.StartNewLine;
        Writer.WriteKey('USR$FLOAT');
        Writer.WriteFloat(q.Fields[0].AsDouble);
        Writer.StartNewLine;
        Writer.WriteKey('USR$CURRENCY');
        Writer.WriteCurrency(q.Fields[1].AsCurrency);
        Writer.StartNewLine;
        Writer.WriteKey('USR$TIMESTAMP');
        Writer.WriteTimestamp(q.Fields[2].AsDateTime);
        Writer.StartNewLine;
        Writer.WriteKey('USR$VARCHAR');
        Writer.WriteText(q.Fields[3].AsString, qDoubleQuoted);
        Writer.StartNewLine;
        Writer.WriteKey('USR$BLOB');
        Writer.WriteText(q.Fields[4].AsString, qDoubleQuoted);
        Writer.StartNewLine;
        Writer.WriteKey('USR$INT');
        Writer.WriteInteger(q.Fields[5].AsInteger);
        Writer.StartNewLine;
        Writer.WriteKey('USR$BIGINT');
        Writer.WriteString(q.Fields[6].AsString)
      end;
    finally
      Writer.Free;
      q.Free;
    end;
  end;

  procedure CheckRead(AStream: TStream);
  var
    Parser: TyamlParser;
    M: TyamlMapping;
    N: TyamlNode;
    q: TIBSQL;
    C: Currency;
  begin
    Assert(AStream <> nil);

    Parser := TyamlParser.Create;
    q := TIBSQL.Create(nil);
    try
      q.Transaction := FTr;
      q.SQL.Text := 'SELECT USR$FLOAT, USR$CURRENCY, USR$TIMESTAMP, ' +
        'USR$VARCHAR, USR$BLOB, USR$INT, USR$BIGINT FROM ' + FTableNameForType;

      Parser.Parse(AStream);
      if (Parser.YAMLStream.Count > 0)
        and ((Parser.YAMLStream[0] as TyamlDocument).Count > 0)
        and ((Parser.YAMLStream[0] as TyamlDocument)[0] is TyamlMapping) then
      begin
        q.ExecQuery;
        M := (Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping;
        N := M.FindByName('Fields\USR$FLOAT');
        Check(N <> nil);
        Check(N is TyamlFloat);
        Check(q.Fields[0].AsDouble = (N as TyamlFloat).AsFloat);
        N := M.FindByName('Fields\USR$CURRENCY');
        Check(N <> nil);
        Check(N is TyamlFloat);
        C := (N as TyamlFloat).AsFloat;
        Check(q.Fields[1].AsCurrency = C);

        N := M.FindByName('Fields\USR$TIMESTAMP');
        Check(N <> nil);
        Check(N is TyamlDateTime);
        Check(q.Fields[2].AsDateTime = (N as TyamlDateTime).AsDateTime);
        N := M.FindByName('Fields\USR$VARCHAR');
        Check(N <> nil);
        Check(N is TyamlString);
        Check(q.Fields[3].AsString = (N as TyamlString).AsString);

        N := M.FindByName('Fields\USR$BLOB');
        Check(N <> nil);
        Check(N is TyamlString);
        Check(q.Fields[4].AsString = (N as TyamlString).AsString);

        N := M.FindByName('Fields\USR$INT');
        Check(N <> nil);
        Check(N is TyamlInteger);
        Check(q.Fields[5].AsInteger = (N as TyamlInteger).AsInteger);

        N := M.FindByName('Fields\USR$BIGINT');
        Check(N <> nil);
        Check(N is TyamlInt64);
        Check(q.Fields[6].AsInt64 = (N as TyamlInt64).AsInt64);
      end;
    finally
      Parser.Free;
      q.Free;
    end;
  end;
var
  q: TIBSQL;
  S: TMemoryStream;
begin
  FTableNameForType := 'USR$TEST' + IntToStr(Random(1000000)) + 'A';
  S := TMemoryStream.Create;
  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTr;
    q.SQL.Text :=
      'CREATE TABLE ' + FTableNameForType + '( ' +
      '  USR$FLOAT DOUBLE PRECISION, ' +
      '  USR$CURRENCY DCURRENCY, ' +
      '  USR$TIMESTAMP TIMESTAMP, ' +
      '  USR$VARCHAR VARCHAR(20), ' +
      '  USR$BLOB DBLOBTEXT80_1251, ' +
      '  USR$BIGINT BIGINT, ' +
      '  USR$INT INTEGER ' +
      ')';
    q.ExecQuery;
    q.Close;
    q.SQL.Text := 'DELETE FROM ' + FTableNameForType;
    FTr.Commit;
    FTr.StartTransaction;

    InsertRecord(' ', 9.123456, 46.1234, Now, '   test'#13#10'test   ', MaxInt, High(Int64));
    WriteYAML(S);
    S.Position := 0;
    CheckRead(S);

    S.Clear;
    q.ExecQuery;
    q.Close;
    FTr.Commit;
    FTr.StartTransaction;

    InsertRecord(' ', 9.123, 46.12, Now, '   test'#13#10''#13#10''#13#10'  ', Low(Integer), Low(Int64));
    WriteYAML(S);
    S.Position := 0;
    CheckRead(S);

    q.Close;
    q.SQL.Text := 'DROP TABLE ' + FTableNameForType;
    q.ExecQuery;

    FTr.Commit;
    FTr.StartTransaction;
  finally
    q.Free;
    S.Free;
  end;
end;

initialization
  RegisterTest('DB', Tgs_gdcNamespaceTest.Suite);
end.
