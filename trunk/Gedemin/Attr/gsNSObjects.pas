
unit gsNSObjects;

interface

uses
  Classes, gsTreeView;

type
  TgsNSState = (nsUndefined, nsNotInstalled, nsNewer, nsOlder, nsEqual);

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
    VersionInDB: String;
    UsesList: TStringList;

    constructor Create(const ARUID: String);
    destructor Destroy; override;

    function GetNSState: TgsNSState;
    procedure FillInfo(S: TStrings);
  end;

  TgsNSList = class(TStringList)
  private
    function Valid(ANode: TgsNSNode): Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    procedure GetFilesForPath(Path: String);
    procedure Clear; override;
    procedure FillTree(ATreeView: TgsTreeView; AnInternal: Boolean);
  end;

implementation

uses
  SysUtils, ComCtrls, gd_common_functions, gd_FileList_unit, yaml_parser,
  IB, IBSQL, gdcBaseInterface, jclFileUtils;

constructor TgsNSNode.Create(const ARUID: String);
begin
  inherited Create;
  RUID := ARUID;
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
  S.Add(Name);
  S.Add('RUID: ' + RUID);
  S.Add('Версия: ' + Version);
  S.Add('Версия в базе данных: ' + VersionInDB);
  S.Add('Путь: ' + ExtractFilePath(FileName));
  S.Add('Файл: ' + ExtractFileName(FileName));
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

constructor TgsNSList.Create;
begin
  inherited;
  Sorted := True;
  Duplicates := dupError;
end;

destructor TgsNSList.Destroy;
begin
  Clear;
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

procedure TgsNSList.GetFilesForPath(Path: String);

  procedure GetYAMLNode(const Name: String);
  var
    Parser: TyamlParser;
    M: TyamlMapping;
    N: TyamlNode;
    S: TyamlSequence;
    Ind, I: Integer;
    RUID: String;
    q: TIBSQL;
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

        Ind := Self.IndexOf(M.ReadString('Properties\RUID'));

        if Ind = -1 then
        begin
          Obj := TgsNSNode.Create(M.ReadString('Properties\RUID'));
          AddObject(M.ReadString('Properties\RUID'), Obj);
        end else
          Obj := Self.Objects[Ind] as TgsNSNode;

        Obj.Name := M.ReadString('Properties\Name');
        Obj.Caption := M.ReadString('Properties\Caption');
        Obj.FileName := Name;
        Obj.FileTimestamp := gd_common_functions.GetFileLastWrite(Name);
        Obj.Version := M.ReadString('Properties\Version');
        Obj.DBVersion := M.ReadString('Properties\DBVersion');
        Obj.Optional := M.ReadBoolean('Properties\Optional');
        Obj.Internal := M.ReadBoolean('Properties\Internal');
        Obj.Comment := M.ReadString('Properties\Comment');

        q := TIBSQL.Create(nil);
        try
          q.Transaction := gdcBaseManager.ReadTransaction;
          q.SQL.Text :=
            'SELECT n.version ' +
            'FROM at_namespace n JOIN gd_ruid r ' +
            '  ON n.id = r.id ' +
            'WHERE r.xid || ''_'' || r.dbid = :ruid';
          q.ParamByName('ruid').AsString := Obj.RUID;
          q.ExecQuery;

          if not q.Eof then
            Obj.VersionInDB := q.Fields[0].AsString;
        finally
          q.Free;
        end;

        N := M.FindByName('Uses');

        if N <> nil then
        begin
          if not (N is TyamlSequence) then
            raise Exception.Create('Invalid data!');

          S := N as TyamlSequence;
          for I := 0 to S.Count - 1 do
          begin
            if not (S.Items[I] is TyamlScalar) then
              raise Exception.Create('Invalid data!');

            RUID := (S.Items[I] as TyamlScalar).AsString;
            if Pos(' ', RUID) > 0 then
              SetLength(RUID, Pos(' ', RUID) - 1);

            if CheckRUID(RUID) then
            begin
              Ind := Self.IndexOf(RUID);
              if Ind > -1 then
              begin
                if Valid(Self.Objects[Ind] as TgsNSNode) then
                  Obj.UsesList.Add(RUID)
                else
                  raise Exception.Create('Invalid object "' + (Self.Objects[Ind] as TgsNSNode).Name + '"!');
              end else
              begin
                Self.AddObject(RUID, TgsNSNode.Create(RUID));
                Obj.UsesList.Add(RUID);
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
  I: Integer;
begin
  Clear;
  SL := TStringList.Create;
  try
    if AdvBuildFileList(IncludeTrailingBackslash(Path) + '*.yml',
      faAnyFile, SL, amAny, [flFullNames, flRecursive], '*.*', nil) then
    begin
      for I := 0 to SL.Count - 1 do
        GetYAMLNode(SL[I]);
    end;
  finally
    SL.Free;
  end;
end;

procedure TgsNSList.FillTree(ATreeView: TgsTreeView; AnInternal: Boolean);

  procedure AddNode(Node: TTreeNode; yamlNode: TgsNSNode);
  var
    Temp: TTreeNode;
    I, Ind: Integer;
  begin
    Temp := Node;
    if AnInternal or not yamlNode.Internal then
    begin
      Temp := ATreeView.Items.AddChildObject(Node, yamlNode.Caption, yamlNode);
      Temp.StateIndex := 2;
    end;

    for I := 0 to yamlNode.UsesList.Count - 1 do
    begin
      Ind := IndexOf(yamlNode.UsesList[I]);
      if (Ind = -1) or (not FileExists((Objects[Ind] as TgsNSNode).FileName)) then
        raise Exception.Create('Файл ' + (Objects[Ind] as TgsNSNode).Name + '(RUID=' + (Objects[Ind] as TgsNSNode).RUID + ') не найден!')
      else
        AddNode(Temp, Objects[Ind] as TgsNSNode);
    end;
  end;

var
  I, K: Integer;
  Link: Boolean;
  Parent: TList;
begin
  Assert(ATreeView <> nil);

  Parent := TList.Create;
  try
    for I := 0 to Count - 1 do
    begin
      Link := False;
      for K := 0 to Count - 1 do
      begin
        if (I <> K) and
          ((Objects[K] as TgsNSNode).UsesList.IndexOf(Strings[I]) > -1)
        then
        begin
          Link := True;
          break;
        end;
      end;

      if not Link then
        Parent.Add(Objects[I]);
    end;

    for I := 0 to Parent.Count - 1 do
      AddNode(nil, TgsNSNode(Parent[I]));
  finally
    Parent.Free;
  end;
end;

end.