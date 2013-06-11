
unit gsNSObjects;

interface

uses
  Classes, gsTreeView;

type
  TgsNSState = (nsUndefined, nsNotInstalled, nsNewer, nsOlder, nsEqual);
  TgsNSStates = set of TgsNSState;
  TNSLog = procedure(const AMessage: string) of object;

  TgsNSNode = class;
  TgsNSList = class;

  TgsNSTreeNode = class(TObject)
  public
    Parent: TgsNSTreeNode;
    YamlNode: TgsNSNode;
    UsesObject: TStringList;

    constructor Create;
    destructor Destroy; override;
  end;

  TgsNSTree = class(TStringList)
  public   
    function AddNode(Node: TgsNSTreeNode; yamlNode: TgsNSNode): TgsNSTreeNode;
    function GetTreeNodeByRUID(const ARUID: String): TgsNSTreeNode;
    function GetDependState(const ARUID: String): String;
    function CheckNSCorrect(const ARUID: String; var AError: String): Boolean;
    procedure SetNSFileName(const ARUID: String; AFileList: TStringList);
  end;

  TgsNSNode = class(TObject)
  public
    RUID: String;
    Name: String;
    Caption: String;
    FileName: String;
    FileTimestamp: TDateTime;
    Version: String;
    DBVersion: String;
    Optional: Boolean;
    Internal: Boolean;
    Comment: String;
    Filesize: Integer;

    VersionInDB: String;
    Namespacekey: Integer;
    NamespaceName: String;
    NamespaceTimestamp: TDateTime;
    NamespaceOptional: Boolean;
    NamespaceInternal: Boolean;
    NSList: TgsNSList;
    UsesList: TStringList;


    constructor Create(ANSList: TgsNSList; const ARUID: String; const AName: String = '');
    destructor Destroy; override;

    function GetUsesString: String;
    function GetNSState: TgsNSState;
    function GetOperation: String;
    function CheckDBVersion: Boolean;
    function CheckOnlyInDB: Boolean;
    function GetDisplayFolder: String;
    procedure FillInfo(S: TStrings);
    function Valid: Boolean;

  end;

  TgsNSList = class(TStringList)
  private
    FLog: TNSLog;
    FErrorNS: TStringList;
    FNSTree: TgsNSTree;

    function Valid(ANode: TgsNSNode): Boolean;
    procedure CorrectFill;
    procedure CreateNSTree;
    procedure CorrectPack(const ARUID: String);
  public

    constructor Create;
    destructor Destroy; override;

    function GetAllUsesString: String;
    function GetNSDependOn(const ARUID: String): String;
    procedure GetFilesForPath(const Path: String);
    procedure Clear; override;
    procedure FillTree(ATreeView: TgsTreeView);
    procedure GetAllUses(const RUID: String; SL: TStringList);
    property Log: TNSLog read FLog write FLog;
    property NSTree: TgsNSTree read FNSTree;
  end;

implementation

uses
  Windows, SysUtils, ComCtrls, gd_common_functions, gd_FileList_unit,
  yaml_parser, IB, IBSQL, gdcBaseInterface, jclFileUtils, Forms, gd_security, gdcNamespace;

constructor TgsNSNode.Create(ANSList: TgsNSList; const ARUID: String; const AName: String = '');
begin
  inherited Create;
  RUID := ARUID;
  Name := AName;
  NSList := ANSList;
  UsesList := TStringList.Create;
  UsesList.Sorted := True;
  UsesList.Duplicates := dupError;    
end;

destructor TgsNSNode.Destroy;
begin
  UsesList.Free;
  inherited;
end;

procedure TgsNSNode.FillInfo(S: TStrings);
begin
  S.Add(Caption);
  S.Add('RUID: ' + RUID);
  S.Add('������: ' + Version);
  S.Add('������ � ���� ������: ' + VersionInDB);
  S.Add('����: ' + ExtractFilePath(FileName));
  S.Add('����: ' + ExtractFileName(FileName));
end;

function TgsNSNode.GetUsesString: String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to UsesList.Count - 1 do
    Result := Result + UsesList[I] + ';';
  SetLength(Result, Length(Result) - 1);  
end;

function TgsNSNode.GetDisplayFolder: String;
begin
  Result := ExtractFilePath(FileName);
  if (Result = '') and (Pos(';' + RUID + ';', NSList.GetAllUsesString) > 0) then
    Result := '<�� �������>';
end;

function TgsNSNode.GetNSState: TgsNSState;
var
  I: Integer;
begin
  if Version = '' then
    Result := nsUndefined
  else if VersionInDB = '' then
    Result := nsNotInstalled
  else begin
    I := TFLItem.CompareVersionStrings(VersionInDB, Version);
    if I < 0 then
      Result := nsNewer
    else if I > 0 then
      Result := nsOlder
    else
      Result := nsEqual;
  end;
end;

function TgsNSNode.GetOperation: String;
var
  NSTreeNode: TgsNSTreeNode;
  q: TIBSQL;
  TempS: String;
begin
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT * FROM at_object o ' +
      'WHERE namespacekey = :nsk ' +
      '  AND DATEDIFF(SECOND, ' +
      '    COALESCE(o.modified,      cast(''01.01.2000 00:00:00.0000'' as TIMESTAMP)), ' +
      '    COALESCE(o.curr_modified, cast(''01.01.2000 00:00:00.0000'' as TIMESTAMP))) > 0';
    case GetNSState of
      nsUndefined:
      begin
        NSTreeNode := NSList.NSTree.GetTreeNodeByRUID(RUID);
        if (NSTreeNode <> nil)
          and (NSTreeNode.Parent <> nil) then
        begin
          Result := '!';
        end else if VersionInDB > '' then
          Result := '>'
        else
          Result := '';
      end;
      nsNotInstalled: Result := '<';
      nsNewer:
      begin
        q.ParamByName('nsk').AsInteger := Namespacekey;
        q.ExecQuery;
        if not q.Eof then
          Result := '?'
        else
          Result := '<<';
        q.Close;
      end;
      nsOlder: Result := '>>';
      nsEqual:
      begin
        if filetimestamp <> namespacetimestamp then
        begin
          Result := '?';
        end else
        begin
          q.ParamByName('nsk').AsInteger := Namespacekey;
          q.ExecQuery;
          if q.Eof then
          begin
            TempS := NSList.NSTree.GetDependState(RUID);
            if TempS = '<<' then
              Result := '<='
            else if TempS = '>>' then
              Result := '=>'
            else
              Result := '==';
          end else
            Result := '>>';
          q.Close;
        end;
      end;
    end;  
  finally
    q.Free;
  end; 
end;

function TgsNSNode.CheckDBVersion: Boolean;
begin
  Result := TFLItem.CompareVersionStrings(DBVersion, IBLogin.DBVersion) <= 0;
end;

function TgsNSNode.Valid: Boolean;
begin
  Result := FileExists(FileName);
end;

function TgsNSNode.CheckOnlyInDB: Boolean;
begin
  Result := (FileName = '') and (Namespacekey > 0);
end;

constructor TgsNSList.Create;
begin
  inherited;
  Sorted := True;
  Duplicates := dupError;
  FErrorNS := TStringList.Create;
  FErrorNS.Sorted := True;
  FErrorNS.Duplicates := dupIgnore;
  FNSTree := TgsNSTree.Create;
end;

destructor TgsNSList.Destroy;
begin
  FNSTree.Free;
  Clear;
  FErrorNS.Free;
  inherited;
end;

procedure TgsNSList.Clear;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Objects[I].Free;
  inherited;
end;

function TgsNSList.GetAllUsesString: String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Count - 1 do
    Result := Result + (Objects[I] as TgsNSNode).GetUsesString + ';';
  Result := ';' + Result;
end;

function TgsNSList.Valid(ANode: TgsNSNode): Boolean;

  function Acyclic(Obj: TgsNSNode): Boolean;
  var
    I, Ind: Integer;
  begin
    if Obj = ANode then
      Result := False
    else
    begin
      Result := True;
      for I := 0 to Obj.UsesList.Count - 1 do
      begin
        Ind := Self.IndexOf(Obj.UsesList[I]);
        if Ind >= 0 then
          Result := Acyclic(Self.Objects[Ind] as TgsNSNode);
        if not Result then
          break;
      end;
    end;
  end;

var
  I, Ind: Integer;
begin
  Result := True;
  for I := 0 to ANode.UsesList.Count - 1 do
  begin
    Ind := Self.IndexOf(ANode.UsesList[I]);
    if (Ind >= 0) and (not Acyclic(Self.Objects[Ind] as TgsNSNode)) then
    begin
      Result := False;
      break;
    end;
  end;
end;

procedure TgsNSList.CorrectFill;
var
  q: TIBSQL;
  I, Ind: Integer;
  SL: TStringList;
  N: TgsNSNode;
begin
  q := TIBSQL.Create(nil);
  SL := TStringList.Create;
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT n.id, n.name, n.version, n.filetimestamp, ' +
      '  r.xid || ''_'' || r.dbid as RUID, n.internal, n.optional ' +
      'FROM at_namespace n JOIN gd_ruid r ' +
      '  ON n.id = r.id ' +
      'WHERE UPPER(n.name) = UPPER(:n)';

    for I := 0 to Count - 1 do
    begin
      N := Objects[I] as TgsNSNode;
      if (N.NamespaceName = '') then
      begin
        if N.Valid then
        begin
          q.Close;
          q.ParamByName('n').AsString := N.Name;
          q.ExecQuery;

          if not q.Eof then
          begin
            N.VersionInDB := q.Fields[2].AsString;
            N.Namespacekey := q.Fields[0].AsInteger;
            N.NamespaceName := q.Fields[1].AsString;
            N.NamespaceTimestamp := q.Fields[3].AsDateTime;
            N.NamespaceOptional := Boolean(q.Fields[6].AsInteger);
            N.NamespaceInternal := Boolean(q.Fields[5].AsInteger);
            if Assigned(FLog) then
              FLog('������������ ���� "' + N.Name + '" ������� �� �����.');
            Ind := IndexOf(q.Fields[4].AsString);
            if (Ind > - 1) and (not (Objects[Ind] as TgsNSNode).Valid) then
              SL.Add(q.Fields[4].AsString);
          end;
        end;
      end;
    end;

    for I := 0 to SL.Count - 1 do
    begin
      Ind := Indexof(SL[I]);
      Objects[Ind].Free;
      Delete(Ind);
    end;
  finally
    q.Free;
    SL.Free;
  end;
end;

function TgsNSList.GetNSDependOn(const ARUID: String): String;
begin
 //for 
end;

procedure TgsNSList.GetFilesForPath(const Path: String);

  procedure FillInNamespace;
  var
    q: TIBSQL;
    Ind: Integer;
    Obj: TgsNSNode;
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;

      q.SQL.Text :=
        'SELECT n.id, n.name, n.version, n.filetimestamp, ' +
        '  r.xid || ''_'' || r.dbid as RUID, n.internal, n.optional ' +
        'FROM at_namespace n JOIN gd_ruid r ' +
        '  ON n.id = r.id ';
      q.ExecQuery;

      while not q.Eof do
      begin
        Ind := Self.IndexOf(q.Fields[4].AsString);
        if Ind > -1 then
        begin
          Obj := Self.Objects[Ind] as TgsNSNode;
        end else
        begin
          Obj := TgsNSNode.Create(Self, q.Fields[4].AsString);
          AddObject(q.Fields[4].AsString, Obj);
        end;
        Obj.VersionInDB := q.Fields[2].AsString;
        Obj.Namespacekey := q.Fields[0].AsInteger;
        Obj.NamespaceName := q.Fields[1].AsString;
        Obj.NamespaceTimestamp := q.Fields[3].AsDateTime;
        Obj.NamespaceOptional := Boolean(q.Fields[6].AsInteger);
        Obj.NamespaceInternal := Boolean(q.Fields[5].AsInteger);
        q.Next;
      end;
    finally
      q.Free;  
    end;
  end;

  procedure GetYAMLNode(const Name: String; SL: TStringList);
  var
    Parser: TyamlParser;
    M: TyamlMapping;
    N: TyamlNode;
    S: TyamlSequence;
    Ind, I: Integer;
    RUID, Temps: String;
    Obj: TgsNSNode;
  begin
    Parser := TyamlParser.Create;
    try
      Parser.Parse(Name, 'Objects', 8192);

      if (Parser.YAMLStream.Count > 0)
        and ((Parser.YAMLStream[0] as TyamlDocument).Count > 0)
        and ((Parser.YAMLStream[0] as TyamlDocument)[0] is TyamlMapping) then
      begin
        M := (Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping;
        if M.ReadString('Properties\Name') = '' then
        begin
          if Assigned(FLog) then
            FLog('�������� ������ ����� ' + Name);
        end else
        begin
          Ind := SL.IndexOfName(M.ReadString('Properties\Name'));
          if Ind > -1 then
          begin
            if Assigned(FLog) then
              FLog('������������ ����: "' +
                M.ReadString('Properties\Name') +
                '" ���������� � ������:' + #13#10 +
                '1: ' + SL.Values[SL.Names[Ind]] + #13#10 + '2: ' + Name + #13#10 +
                '������ ������ ���� ����� ���������!');
          end else
          begin
            Ind := Self.IndexOf(M.ReadString('Properties\RUID'));
            if Ind = -1 then
            begin
              Obj := TgsNSNode.Create(Self, M.ReadString('Properties\RUID'));
              AddObject(M.ReadString('Properties\RUID'), Obj);
            end else
              Obj := Self.Objects[Ind] as TgsNSNode;


            if (Obj.FileName > '') then
            begin
              if Assigned(FLog) then
                FLog('������������ ����: "' +
                  M.ReadString('Properties\Name') +
                  '" ���������� � ������:' + #13#10 +
                  '1: ' + Obj.FileName + #13#10 + '2: ' + Name + #13#10 +
                  '������ ������ ���� ����� ���������!');
            end else
            begin
              Obj.Name := M.ReadString('Properties\Name');
              Obj.Caption := M.ReadString('Properties\Caption');
              Obj.FileName := Name;
              Obj.FileTimestamp := gd_common_functions.GetFileLastWrite(Name);
              Obj.Version := M.ReadString('Properties\Version');
              Obj.DBVersion := M.ReadString('Properties\DBVersion');
              Obj.Optional := M.ReadBoolean('Properties\Optional');
              Obj.Internal := M.ReadBoolean('Properties\Internal');
              Obj.Comment := M.ReadString('Properties\Comment');
              Obj.Filesize := FileGetSize(Name);
              SL.Add(Obj.Name + '=' + Name);

              N := M.FindByName('Uses');

              if N <> nil then
              begin
                if not (N is TyamlSequence) then
                  raise Exception.Create('Invalid data!');

                S := N as TyamlSequence;
                for I := 0 to S.Count - 1 do
                begin
                  if not (S.Items[I] is TyamlString) then
                    raise Exception.Create('Invalid data!');

                  if ParseReferenceString((S.Items[I] as TyamlString).AsString, RUID, Temps) then
                  begin 
                    Ind := Self.IndexOf(RUID);
                    if Ind > -1 then
                    begin
                      if Valid(Self.Objects[Ind] as TgsNSNode) then
                        Obj.UsesList.Add(RUID)
                      else
                        if Assigned(FLog) then
                          FLog('����������� ������, ���� ''' +
                          (Self.Objects[Ind] as TgsNSNode).Name + '''!');
                    end else
                    begin
                      Self.AddObject(RUID, TgsNSNode.Create(Self, RUID, Temps));
                      Obj.UsesList.Add(RUID);
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    finally
      Parser.Free;
    end;
  end;

var
  SL: TStringList;
  NSL: TStringList;
  I: Integer;
begin
  Clear;
  SL := TStringList.Create;
  NSL := TStringList.Create;
  try 
    if AdvBuildFileList(IncludeTrailingBackslash(Path) + '*.yml',
      faAnyFile, SL, amAny, [flFullNames, flRecursive], '*.*', nil) then
    begin
      for I := 0 to SL.Count - 1 do
        GetYAMLNode(SL[I], NSL);

      FillInNamespace;  
      CorrectFill;
      CreateNSTree;
    end;
  finally   
    SL.Free;
    NSL.Free;
  end;
end;

procedure TgsNSList.CreateNSTree;

  procedure AddNode(Node: TgsNSTreeNode; yamlNode: TgsNSNode);
  var
    Temp: TgsNSTreeNode;
    I, Ind: Integer;
  begin
    Temp := FNSTree.AddNode(Node, yamlNode);

    for I := 0 to yamlNode.UsesList.Count - 1 do
    begin
      Ind := IndexOf(yamlNode.UsesList[I]);
      if  Ind > -1 then
        AddNode(Temp, Objects[Ind] as TgsNSNode);
    end;
  end;
  
var
  Parent: TList;
  I: Integer;
  UsesString: String;
begin
  NSTree.Clear;
  Parent := TList.Create;
  try
    UsesString := GetAllUsesString;
    for I := 0 to Count - 1 do
    begin
      if (Objects[I] as TgsNSNode).CheckOnlyInDB then
        continue;
      if Pos(';' + Strings[I] + ';', UsesString) = 0 then
        Parent.Add(Objects[I]);
    end;   

    for I := 0 to Parent.Count - 1 do
      AddNode(nil, TgsNSNode(Parent[I]));
  finally
    Parent.Free;
  end;
end;

procedure TgsNSList.FillTree(ATreeView: TgsTreeView);

  procedure AddNode(Node: TTreeNode; yamlNode: TgsNSNode);
  var
    Temp: TTreeNode;
    I, Ind: Integer;
  begin
    if not yamlNode.Valid then
    begin
      if Assigned(FLog) and (FErrorNS.IndexOf(yamlNode.Name) = -1) then
      begin
        FLog('���� (RUID = ' + yamlNode.RUID + ') �� ������!');
        FErrorNS.Add(yamlNode.Name);
      end;
      Temp := ATreeView.Items.AddChildObject(Node, yamlNode.Name, yamlNode);
      Temp.StateIndex := 0;
    end else
    begin
      Temp := ATreeView.Items.AddChildObject(Node, yamlNode.Name, yamlNode);
      Temp.StateIndex := 2;
    end;

    for I := 0 to yamlNode.UsesList.Count - 1 do
    begin
      Ind := IndexOf(yamlNode.UsesList[I]);
      if  Ind = -1 then
      begin
        if Assigned(FLog) and (FErrorNS.IndexOf(yamlNode.Name) = -1) then
        begin
          FLog('���� (RUID = ' +
            yamlNode.UsesList[I] + ') �� ������! ������������ ���� ''' +
            yamlNode.Name + ''' ����������� �����������!');
          FErrorNS.Add(yamlNode.Name);
        end;
      end else
        AddNode(Temp, Objects[Ind] as TgsNSNode);
    end;
  end;

var
  I: Integer; 
begin
  Assert(ATreeView <> nil);
  for I := 0 to FNSTree.Count - 1 do
    AddNode(nil, (FNSTree.Objects[I] as TgsNSTreeNode).yamlNode);  
end;

procedure TgsNSList.CorrectPack(const ARUID: String);
var
  Ind, I: Integer;
  Node: TgsNSNode;
begin

  Ind := IndexOf(ARUID);
  if Ind > -1 then
  begin
    Node := Objects[Ind] as TgsNSNode;
    if not Node.Valid and Assigned(FLog) then
      FLog('���� (RUID = ' + Node.RUID + ') �� ������!');
    for I := 0 to Node.UsesList.Count - 1 do
    begin
      Ind := IndexOf(Node.UsesList[I]);
      if  (Ind = -1)
        and (FErrorNS.IndexOf(Node.Name) = -1)
        and Assigned(FLog) then
      begin
        FLog('���� (RUID = ' +
          Node.UsesList[I] + ') �� ������! ������������ ���� ''' +
          Node.Name + ''' ����������� �����������!');
        FErrorNS.Add(Node.Name);
     end else
       CorrectPack(Node.UsesList[I]);
    end;
  end;
end;

procedure TgsNSList.GetAllUses(const RUID: String; SL: TStringList);
var
  I, Ind: Integer;
  NSNode: TgsNSNode;
begin
  Assert(SL <> nil);

  Ind := IndexOf(RUID);
  if Ind > -1 then
  begin
    NSNode := Objects[Ind] as TgsNSNode;
    for I := 0 to NSNode.UsesList.Count - 1 do
      GetAllUses(NSNode.UsesList[I], SL);
    if not NSNode.Valid then
      raise Exception.Create('���� (RUID = ' + NSNode.RUID + ') �� ������!')
    else
      SL.Add(NSNode.FileName);
  end;
end;

function TgsNSTree.CheckNSCorrect(const ARUID: String; var AError: String): Boolean;

  function CheckNSNode(Node: TgsNSTreeNode): Boolean;
  var
    I: Integer;
  begin
    Result := True;
    if Node.YamlNode <> nil then
    begin
      if not Node.YamlNode.Valid then
      begin
        AError := '����������� �� ����� ���� ������������ ���� ''' + Node.YamlNode.Name + '''.';
        Result := False;
      end else
      begin
        for I := 0 to Node.UsesObject.Count - 1 do
        begin
          Result := CheckNSNode(Node.UsesObject.Objects[I] as TgsNSTreeNode);
          if not Result then
            break;
        end;
      end;
    end;
  end;
  
var
  Node: TgsNSTreeNode; 
begin
  Result := True;
  AError := '';
  Node := GetTreeNodeByRUID(ARUID);
  if Node <> nil then
  begin
    Result := CheckNSNode(Node);
  end;
end;

procedure TgsNSTree.SetNSFileName(const ARUID: String; AFileList: TStringList);

  procedure FillFileList(Node: TgsNSTreeNode);
  var
    I: Integer;
  begin
    if Node.YamlNode <> nil then
    begin
      for I := 0 to Node.UsesObject.Count - 1 do
        FillFileList(Node.UsesObject.Objects[I] as TgsNSTreeNode);
      if AFileList.IndexOf(Node.YamlNode.FileName) = -1 then
        AFileList.Add(Node.YamlNode.FileName);
   end;
  end;
var
  Node: TgsNSTreeNode;
begin
  Assert(AFileList <> nil);

  Node := GetTreeNodeByRUID(ARUID);
  if Node <> nil then
    FillFileList(Node);
end;

function TgsNSTree.AddNode(Node: TgsNSTreeNode; yamlNode: TgsNSNode): TgsNSTreeNode;
begin
  if Node = nil then
  begin
    Result := TgsNSTreeNode.Create;
    Result.YamlNode := yamlNode;
    Result.Parent := Node;
    AddObject(yamlNode.RUID, Result);
  end else
  begin
    Result := TgsNSTreeNode.Create;
    Result.YamlNode := yamlNode;
    Result.Parent := Node;
    Node.UsesObject.AddObject(yamlNode.RUID, Result);
  end;
end;  

function TgsNSTree.GetTreeNodeByRUID(const ARUID: String): TgsNSTreeNode;

  function FindNode(Node: TgsNSTreeNode): TgsNSTreeNode;
  var
    I, Ind: Integer;
  begin
    Result := nil;
    Ind := Node.UsesObject.IndexOf(ARUID);
    if Ind > -1 then
    begin
      Result := Node.UsesObject.Objects[Ind] as TgsNSTreeNode;
    end else
    begin
      for I := 0 to Node.UsesObject.Count - 1 do
      begin
        Result := FindNode(Node.UsesObject.Objects[I] as TgsNSTreeNode);
        if Result <> nil then
          break;
      end;
    end;
  end;

var
  I, Ind: Integer;
begin
  Result := nil;
  Ind := IndexOf(ARUID);
  if Ind > -1 then
  begin
    Result := Objects[Ind] as TgsNSTreeNode;
  end else
  begin
    for I := 0 to Count - 1 do
    begin
      Result := FindNode(Objects[I] as TgsNSTreeNode);
      if Result <> nil then
        break;
    end;
  end;
end;

function TgsNSTree.GetDependState(const ARUID: String): String;

  function SetState(Node: TgsNSTreeNode): String;
  var
    I: Integer;
  begin
    Result := '';
    if Node.YamlNode <> nil then
    begin
      if not Node.YamlNode.CheckOnlyInDB then
        Result := Node.YamlNode.GetOperation;
      if (Result <> '>>') or (Result <> '<<') then
      begin
        for I := 0 to Node.UsesObject.Count - 1 do
        begin
          Result := SetState(Node.UsesObject.Objects[I] as TgsNSTreeNode);
          if (Result = '>>') or (Result = '<<') then
            break;
        end;
      end;
   end;
  end;
var
  Node: TgsNSTreeNode;
  I: Integer;
begin
  Result := '';
  Node := GetTreeNodeByRUID(ARUID);
  if Node <> nil then
  for I := 0 to Node.UsesObject.Count - 1 do
  begin
    Result := SetState(Node.UsesObject.Objects[I] as TgsNSTreeNode);
    if (Result = '>>') or (Result = '<<') then
      break;
  end;
end;

constructor TgsNSTreeNode.Create;
begin
  inherited;
  UsesObject := TStringList.Create;
end;

destructor TgsNSTreeNode.Destroy;
begin
  UsesObject.Free;

  inherited;  
end; 
end.