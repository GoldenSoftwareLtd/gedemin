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
    FContactName, FContactName2, FGroup, FFolderName: String;

    function GetFileName(const APath: String = ''): String;

    procedure TestCreateNamespace;
    procedure TestAddObject;
    procedure TestSaveNamespaceToFile;
    procedure TestLoadNamespaceFromFile;
    procedure TestAlwaysoverwrite;
    procedure TestSet;
    procedure TestType;
    procedure TestOperation;
    procedure TestObjectPos;

  published
    procedure TestIncludesiblings;
    procedure DoTest;
  end;

implementation

uses
  gdcMetaData, Sysutils, Windows, gdcBaseInterface, gdcGood, IBSQL,
  gdcContacts, yaml_writer, yaml_parser, yaml_common, gsNSObjects,
  gdcConst, contnrs, dbclient, DB, gdcPlace;

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
  //TestIncludesiblings;
  TestType;
  TestOperation;
 // TestObjectPos;
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

function Tgs_gdcNamespaceTest.GetFileName(const APath: String = ''): String;
var
  Path: String;
begin
  Path := IncludeTrailingBackslash(TempPath) + 'yml\';
  Result := ExtractFileDir(Path);
  if Result = '' then
    CreateDir(Path);

  if APath = '' then
    Result := IncludeTrailingBackslash(Path) + FNamespacename + '.yml'
  else
    Result := IncludeTrailingBackslash(Path) + APath + '.yml';
end;

procedure Tgs_gdcNamespaceTest.TestIncludesiblings;
var
  F: TgdcFolder;
  C: TgdcCompany;
  FID1, FID2: Integer;
  FRUID: TRUID;
  NS: TgdcNamespace;
  FName: String;
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;

    F := TgdcFolder.Create(nil);
    try
      F.ReadTransaction := Tr;
      F.Transaction := Tr;
      F.Open;
      F.Insert;
      F.FieldByName('name').AsString := 'Folder 1';
      F.Parent := 650001;
      F.Post;
      FID1 := F.ID;
      FRUID := F.GetRUID;

      F.Insert;
      F.FieldByName('name').AsString := 'Folder 2';
      F.Parent := FID1;
      F.Post;
      FID2 := F.ID;
    finally
      F.Free;
    end;

    C := TgdcCompany.Create(nil);
    try
      C.ReadTransaction := Tr;
      C.Transaction := Tr;
      C.Open;
      C.Insert;
      C.FieldByName('name').AsString := 'Company 1';
      C.Parent := FID1;
      C.Post;

      C.Insert;
      C.FieldByName('name').AsString := 'Company 2';
      C.Parent := FID2;
      C.Post;
    finally
      C.Free;
    end;

    NS := TgdcNamespace.Create(nil);
    try
      NS.ReadTransaction := Tr;
      NS.Transaction := Tr;
      NS.Open;
      NS.Insert;
      NS.FieldByName('name').AsString := 'Namespace 1';
      NS.Post;

      NS.AddObject(NS.ID, 'Folder 1', 'TgdcFolder', '', FRUID.XID,  FRUID.DBID, 0,
        ovAlwaysOverwrite, rmDontRemove, isInclude, Tr);

      FName := TempPath + '\ns.yml';
      SysUtils.DeleteFile(FName);

      NS.SaveNamespaceToFile(FName);
      try
        q := TIBSQL.Create(nil);
        try
          q.Transaction := Tr;
          q.SQL.Text :=
            'SELECT objectname ' +
            'FROM at_object ' +
            'WHERE namespacekey = :nsk ' +
            'ORDER BY objectpos';
          q.ParamByName('nsk').AsInteger := NS.ID;
          q.ExecQuery;

          Check(q.FieldByName('objectname').AsString = 'Folder 1');
          q.Next;
          Check((q.FieldByName('objectname').AsString = 'Folder 2')
            or (q.FieldByName('objectname').AsString = 'Company 1')
            or (q.FieldByName('objectname').AsString = 'Company 2'));
          q.Next;
          Check((q.FieldByName('objectname').AsString = 'Folder 2')
            or (q.FieldByName('objectname').AsString = 'Company 1')
            or (q.FieldByName('objectname').AsString = 'Company 2'));
          q.Next;
          Check((q.FieldByName('objectname').AsString = 'Folder 2')
            or (q.FieldByName('objectname').AsString = 'Company 1')
            or (q.FieldByName('objectname').AsString = 'Company 2'));
          q.Next;
          Check(q.EOF);
        finally
          q.Free;
        end;
      finally
        SysUtils.DeleteFile(FName);
      end;
    finally
      NS.Free;
    end;
  finally
    Tr.Free;
  end;
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
      0,
      ovAlwaysOverwrite, rmDontRemove, isDontInclude,
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
      0,
      ovOverwriteIfNewer, rmDontRemove, isDontInclude,
      FTr);

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
      0,
      ovAlwaysOverwrite, rmDontRemove, isDontInclude,
      FTr);
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
      0,
      ovAlwaysOverwrite, rmDontRemove, isDontInclude,
      FTr);
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

procedure Tgs_gdcNamespaceTest.TestOperation;
var
  ID, ID2, ID3: Integer;
  ConstID, ConstID2, ConstID3: Integer;

  procedure CreateNS(out AnID: Integer; out AConstID: Integer);
  var
    gdcNamespace: TgdcNamespace;
    gdcConst: TgdcConst;
    Name: String;
    OL: TObjectList;
  begin
    AnID := -1;
    AConstID := -1;
    Name := 'TEST' + IntToStr(Random(1000000)) + 'N';
    OL := TObjectList.Create;
    gdcNamespace := TgdcNamespace.Create(nil);
    try
      gdcNamespace.Transaction := FTr;
      gdcNamespace.Open;
      gdcNamespace.Insert;
      gdcNamespace.FieldByName('name').AsString := Name;
      gdcNamespace.Post;
      gdcConst := TgdcConst.Create(nil);
      try
        gdcConst.Transaction := FTr;
        gdcConst.Open;
        gdcConst.Insert;
        gdcConst.FieldByName('name').AsString := 'TEST' + IntToStr(Random(1000000)) + 'C';
        gdcConst.Post;
        AConstID := gdcConst.ID;
        //gdcNamespace.AddObject2(gdcConst, OL);
      finally
        gdcConst.Free;
      end;
      AnID := gdcNamespace.ID;
    finally
      gdcNamespace.Free;
      OL.Free;
    end;
  end;

  procedure SetUses(AParent, AnID: Integer);
  var
    q: TIBSQL;
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := FTr;
      q.SQL.Text := 'INSERT INTO at_namespace_link (namespacekey, useskey) ' +
        'VALUES (:nk, :uk)';
      q.ParamByName('nk').AsInteger := AParent;
      q.ParamByName('uk').AsInteger := AnID;
      q.ExecQuery;
      q.Close;
    finally
      q.Free;
    end;
  end;

  procedure CheckOperation(AData: String; ANSList: TgsNSList; AnID: Integer);
  var
    q: TIBSQL;
    RUID: String;
    Ind: Integer;
    Node: TgsNSNode;
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := FTr;
      q.SQL.Text := 'SELECT * FROM gd_ruid WHERE id = :id';
      q.ParamByName('id').AsInteger := AnID;
      q.ExecQuery;
      Check(not q.Eof);
      RUID := q.FieldByName('xid').AsString + '_' + q.FieldByName('dbid').AsString;
      Ind := ANSList.IndexOf(RUID);
      Check(Ind > - 1);
      Node := ANSList.Objects[Ind] as TgsNSNode;
      Check(Node.GetOperation = AData);
    finally
      q.Free;
    end;
  end;

  procedure SaveNS;
  var
    gdcNamespace: TgdcNamespace;
  begin
    gdcNamespace := TgdcNamespace.Create(nil);
    try
      gdcNamespace.ReadTransaction := FTr;
      gdcNamespace.Transaction := FTr;
      gdcNamespace.SubSet := 'ByID';
      gdcNamespace.ID := ID;
      gdcNamespace.Open;
      gdcNamespace.SaveNamespaceToFile(GetFileName(gdcNamespace.ObjectName));
      gdcNamespace.Close;
      gdcNamespace.ID := ID2;
      gdcNamespace.Open;
      gdcNamespace.SaveNamespaceToFile(GetFileName(gdcNamespace.ObjectName));
      gdcNamespace.ID := ID3;
      gdcNamespace.Open;
      gdcNamespace.SaveNamespaceToFile(GetFileName(gdcNamespace.ObjectName));
    finally
      gdcNamespace.Free;
    end;

    FTr.Commit;
    FTr.StartTransaction;
  end;

  procedure DeleteNS;
  var
    gdcNamespace: TgdcNamespace;
    gdcConst: TgdcConst;
  begin
    gdcNamespace := TgdcNamespace.Create(nil);
    try
      gdcNamespace.Transaction := FTr;
      gdcNamespace.SubSet := 'ByID';
      gdcNamespace.ID := ID;
      gdcNamespace.Open;
      Check(not gdcNamespace.Eof);
      gdcNamespace.Delete;
      gdcNamespace.Close;

      gdcNamespace.ID := ID2;
      gdcNamespace.Open;
      Check(not gdcNamespace.Eof);
      gdcNamespace.Delete;
      gdcNamespace.Close;

      gdcNamespace.ID := ID3;
      gdcNamespace.Open;
      Check(not gdcNamespace.Eof);
      gdcNamespace.Delete;
      gdcNamespace.Close;
    finally
      gdcNamespace.Free;
    end;

    gdcConst := TgdcConst.Create(nil);
    try
      gdcConst.SubSet := 'ByID';
      gdcConst.ID := ConstID;
      gdcConst.Open;
      Check(not gdcConst.Eof);
      gdcConst.Delete;
      gdcConst.Close;

      gdcConst.ID := ConstID2;
      gdcConst.Open;
      Check(not gdcConst.Eof);
      gdcConst.Delete;
      gdcConst.Close;

      gdcConst.ID := ConstID3;
      gdcConst.Open;
      Check(not gdcConst.Eof);
      gdcConst.Delete;
      gdcConst.Close;
    finally
      gdcConst.Free;
    end;

    FTr.Commit;
    FTr.StartTransaction;
  end;

var 
  NSLISt: TgsNSList; 
  gdcNamespace: TgdcNamespace;
  gdcConst: TgdcConst;
begin

  CreateNS(ID, ConstID);
  CreateNS(ID2, ConstID2);
  CreateNS(ID3, ConstID3);
  SetUses(ID, ID2);
  SetUses(ID, ID3);

  FTr.Commit;
  FTr.StartTransaction;

  SaveNS;

  TgdcNamespace.UpdateCurrModified;
  NSList := TgsNSList.Create;
  try 
    NSList.GetFilesForPath(IncludeTrailingBackslash(TempPath) + 'yml\');
    CheckOperation('==', NSList, ID);

    gdcNamespace := TgdcNamespace.Create(nil);
    try
      gdcNamespace.ReadTransaction := FTr;
      gdcNamespace.Transaction := FTr;
      gdcNamespace.SubSet := 'ByID';
      gdcNamespace.ID := ID2;
      gdcNamespace.Open;
      Check(not gdcNamespace.Eof);
      gdcNamespace.Edit;
      gdcNamespace.FieldByName('filetimestamp').AsDateTime := gdcNamespace.FieldByName('filetimestamp').AsDateTime - 1;
      gdcNamespace.Post;
      gdcNamespace.Close;
      gdcNamespace.ID := ID3;
      gdcNamespace.Open;
      gdcNamespace.Edit;
      gdcNamespace.FieldByName('version').AsString :=
        IncVersion(gdcNamespace.FieldByName('version').AsString, '.');
      gdcNamespace.Post;
    finally
      gdcNamespace.Free;
    end;

    FTr.Commit;
    FTr.StartTransaction; 

    NSList.Clear;
    NSList.GetFilesForPath(IncludeTrailingBackslash(TempPath) + 'yml\');
    
    CheckOperation('?', NSList, ID2);
    CheckOperation('=>', NSList, ID);
    CheckOperation('>>', NSList, ID3);

    SaveNS;

    gdcConst := TgdcConst.Create(nil);
    try
      gdcConst.Transaction := FTr;
      gdcConst.ReadTransaction := FTr;
      gdcConst.SubSet := 'ByID';
      gdcConst.ID := ConstID2;
      gdcConst.Open;
      gdcConst.Edit;
      gdcConst.FieldByName('editiondate').AsDateTime := gdcConst.FieldByName('editiondate').AsDateTime + 1;
      gdcConst.Post;
    finally
      gdcConst.Free;
    end;

    FTr.Commit;
    FTr.StartTransaction;

    TgdcNamespace.UpdateCurrModified;
    NSList.Clear;
    NSList.GetFilesForPath(IncludeTrailingBackslash(TempPath) + 'yml\');

    CheckOperation('>>', NSList, ID2);
    CheckOperation('=>', NSList, ID);
    CheckOperation('==', NSList, ID3);

    gdcNamespace := TgdcNamespace.Create(nil);
    try
      gdcNamespace.ReadTransaction := FTr;
      gdcNamespace.Transaction := FTr;
      gdcNamespace.SubSet := 'ByID';
      gdcNamespace.ID := ID3;
      gdcNamespace.Open;
      Check(not gdcNamespace.Eof);
      gdcNamespace.Edit;
      gdcNamespace.FieldByName('version').AsString := '1.0.0.0';
      gdcNamespace.Post;
    finally
      gdcNamespace.Free;
    end;
    FTr.Commit;
    FTr.StartTransaction;

    NSList.Clear;
    NSList.GetFilesForPath(IncludeTrailingBackslash(TempPath) + 'yml\');
    CheckOperation('<<', NSList, ID3);
    CheckOperation('?', NSList, ID);
    CheckOperation('>>', NSList, ID2);
  finally
    NSList.Free;
  end;

  DeleteNS;
end;

procedure Tgs_gdcNamespaceTest.TestObjectPos;
var
  cds: TClientDataSet;
  //GroupName: String;
 // GroupID, GoodID, ValueID: Integer;
  ContactID, ContactID2, GroupID, FolderID: Integer;

  procedure CreateFields;
  begin
    cds.FieldDefs.Add('id', ftInteger, 0, True);
    cds.FieldDefs.Add('displayname', ftString, 255, False);
    cds.FieldDefs.Add('class', ftString, 60, True);
    cds.FieldDefs.Add('subtype', ftString, 60, False);
    cds.FieldDefs.Add('name', ftString, 60, False);
    cds.FieldDefs.Add('namespace', ftString, 255, False);
    cds.FieldDefs.Add('namespacekey', ftInteger, 0, False);
    cds.FieldDefs.Add('headobject', ftString, 21, False);
  end;

  procedure CreateObject;
  var
    Group: TgdcGroup;
    Contact: TgdcContact;
    Folder: TgdcFolder;
    q: TIBSQL;
  begin
    Folder := TgdcFolder.Create(nil);
    try
      Folder.Transaction := FTr;
      Folder.Open;
      Folder.Insert;
      FFolderName := 'TEST' + IntToStr(Random(1000000)) + 'F';
      Folder.FieldByName('name').AsString := FFolderName;
      Folder.Post;
      FolderID := Folder.ID;
    finally
      Folder.Free;
    end;

    Contact := TgdcContact.Create(nil);
    try
      Contact.Transaction := FTr;
      Contact.Open;
      Contact.Insert;
      FContactName := 'TEST' + IntToStr(Random(1000000)) + 'C';
      Contact.FieldByName('name').AsString := FContactName;
      Contact.FieldByName('surname').AsString := 'Test';
      Contact.FieldByName('parent').AsInteger := FolderID;
      Contact.Post;
      ContactID := Contact.ID;

      Contact.Insert;
      FContactName2 := 'TEST' + IntToStr(Random(1000000)) + 'C';
      Contact.FieldByName('name').AsString := FContactName2;
      Contact.FieldByName('surname').AsString := 'Test';
      Contact.FieldByName('parent').AsInteger := FolderID;
      Contact.Post;
      ContactID2 := Contact.ID;
    finally
      Contact.Free;
    end;

    Group := TgdcGroup.Create(nil);
    try
      Group.Transaction := FTr;
      Group.Open;
      Group.Insert;
      FGroup := 'TEST' + IntToStr(Random(1000000)) + 'G';
      Group.FieldByName('name').AsString := FGroup;
     // Group.FieldByname('parent').AsInteger := FolderID;
      Group.FieldByname('parent').Clear;
      Group.Post;
      GroupID := Group.ID;
    finally
      Group.Free;
    end;

    q := TIBSQL.Create(nil);
    try
      q.Transaction := FTr;
      q.SQL.Text := 'INSERT INTO gd_contactlist (groupkey, contactkey) ' +
        'VALUES(:gk, :ck)';
      q.ParamByName('gk').AsInteger := GroupID;
      q.ParamByName('ck').AsInteger := ContactID;
      q.ExecQuery;
      q.Close;
      q.ParamByName('gk').AsInteger := GroupID;
      q.ParamByName('ck').AsInteger := ContactID2;
      q.ExecQuery;
    finally
      q.Free;
    end;

    FTr.Commit;
    FTr.StartTransaction;
  end;

 { procedure CreateObject;
  var
    GoodGroup: TgdcGoodGroup;
    Good: TgdcGood;
    Value: TgdcValue;
  begin
    GoodGroup := TgdcGoodGroup.Create(nil);
    try
      GoodGroup.Transaction := FTr;
      GoodGroup.Open;
      GroupName := 'TEST' + IntToStr(Random(1000000)) + 'G';
      GoodGroup.Insert;
      GoodGroup.FieldByName('name').AsString := GroupName;
      GoodGroup.Post;
      GroupID := GoodGroup.ID;
    finally
      GoodGroup.Free;
    end;

    Value := TgdcValue.Create(nil);
    try
      Value.Transaction := FTr;
      Value.Open;
      Value.Insert;
      Value.FieldByName('name').AsString := 'Test';
      Value.Post;
      ValueID := Value.ID;
    finally
      Value.Free;
    end;

    Good := TgdcGood.Create(nil);
    try
      Good.Transaction := FTr;
      Good.Open;
      Good.Insert;
      Good.FieldByName('name').AsString := 'Test_Good';
      Good.FieldByname('valuekey').AsInteger := ValueID;
      Good.FieldByname('groupkey').AsInteger := GroupID;
      Good.Post;
      GoodID := Good.ID;
    finally
      Good.Free;
    end;


    FTr.Commit;
    FTr.StartTransaction;
  end;

  procedure DeleteObject;
  var
    GoodGroup: TgdcGoodGroup;
    Good: TgdcGood;
    Value: TgdcValue;
  begin
     Good := TgdcGood.Create(nil);
     try
       Good.Transaction := FTr;
       Good.ReadTransaction := FTr;
       Good.SubSet := 'ByID';
       Good.ID := GoodID;
       Good.Open;
       Check(not Good.Eof);
       Good.Delete;
     finally
       Good.Free;
     end;

     GoodGroup := TgdcGoodGroup.Create(nil);
     try
       GoodGroup.Transaction := FTr;
       GoodGroup.ReadTransaction := FTr;
       GoodGroup.SubSet := 'ByID';
       GoodGroup.ID := GroupID;
       GoodGroup.Open;
       Check(not GoodGroup.Eof);
       GoodGroup.Delete;
     finally
       GoodGroup.Free;
     end;

     Value := TgdcValue.Create(nil);
     try
       Value.Transaction := FTr;
       Value.ReadTransaction := FTr;
       Value.SubSet := 'ByID';
       Value.ID := ValueID;
       Value.Open;
       Check(not Value.Eof);
       Value.Delete;
     finally
       Value.Free;
     end;

     FTr.Commit;
     FTr.StartTransaction;
  end; }
{var
  Good: TgdcGood;}
begin
  cds := TClientDataSet.Create(nil);
  try
    CreateFields;
    cds.CreateDataSet;
    cds.Open;
    CreateObject;
  {  Good := TgdcGood.Create(nil);
    try
      Good.Transaction := FTr;
      Good.ReadTransaction := FTr;
      Good.SubSet := 'ByID';
      Good.ID := GoodID;
      Good.Open;
      Check(not Good.Eof);
      TgdcNamespace.SetObjectLink(Good, cds, FTr);


    finally
      Good.Free;
    end; }
   // DeleteObject;
  finally
    cds.Free;
  end;
end;

initialization
  RegisterTest('DB', Tgs_gdcNamespaceTest.Suite);
end.
