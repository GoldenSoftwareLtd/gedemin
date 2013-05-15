
unit gsNSObjects;

interface

uses
  Classes, gsTreeView;

type
  TgsNSState = (nsUndefined, nsNotInstalled, nsNewer, nsOlder, nsEqual);
  TNSLog = procedure(const AMessage: string) of object;

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
    UsesList: TStringList;

    constructor Create(const ARUID: String);
    destructor Destroy; override;

    function GetNSState: TgsNSState;
    function CheckDBVersion: Boolean;
    function CheckOnlyInDB: Boolean; 
    procedure FillInfo(S: TStrings);
    function Valid: Boolean;
  end;

  TgsNSList = class(TStringList)
  private
    FLog: TNSLog;
    FErrorNS: TStringList;
    function Valid(ANode: TgsNSNode): Boolean;
    procedure CorrectFill;
    procedure CorrectPack(const ARUID: String);
  public
    constructor Create;
    destructor Destroy; override;
    
    procedure GetFilesForPath(const Path: String);
    procedure Clear; override;
    procedure FillTree(ATreeView: TgsTreeView; AnInternal: Boolean);
    procedure GetAllUses(const RUID: String; SL: TStringList);
    property Log: TNSLog read FLog write FLog;
  end;

implementation

uses
  Windows, SysUtils, ComCtrls, gd_common_functions, gd_FileList_unit, yaml_parser,
  IB, IBSQL, gdcBaseInterface, jclFileUtils, Forms, gd_security;

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
  S.Add(Caption);
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
  Result := FileName = '';
end;

constructor TgsNSList.Create;
begin
  inherited;
  Sorted := True;
  Duplicates := dupError;
  FErrorNS := TStringList.Create;
  FErrorNS.Sorted := True;
  FErrorNS.Duplicates := dupIgnore;
end;

destructor TgsNSList.Destroy;
begin
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
      'SELECT n.id, n.name, n.version, n.filetimestamp, r.xid || ''_'' || r.dbid as RUID ' +
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
            if Assigned(FLog) then
              FLog('Пространство имен "' + N.Name + '" найдено по имени.');
            Ind := IndexOf(q.Fields[4].AsString);
            if (Ind > - 1) and (not (Objects[Ind] as TgsNSNode).Valid) then
              SL.Add(q.Fields[4].AsString);
          end;
        end else
          SL.Add(N.RUID);
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
        'SELECT n.id, n.name, n.version, n.filetimestamp, r.xid || ''_'' || r.dbid as RUID ' +
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
          Obj := TgsNSNode.Create(q.Fields[4].AsString); 
          AddObject(q.Fields[4].AsString, Obj);
        end;
        Obj.VersionInDB := q.Fields[2].AsString;
        Obj.Namespacekey := q.Fields[0].AsInteger;
        Obj.NamespaceName := q.Fields[1].AsString;
        Obj.NamespaceTimestamp := q.Fields[3].AsDateTime;
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
    RUID: String; 
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
            FLog('Неверный формат файла ' + Name);
        end else
        begin
          Ind := SL.IndexOfName(M.ReadString('Properties\Name'));
          if Ind > -1 then
          begin
            if Assigned(FLog) then
              FLog('Пространство имен: "' + M.ReadString('Properties\Name') + '" содержится в файлах:' + #13#10 +
                '1: ' + SL.Values[SL.Names[Ind]] + #13#10 + '2: ' + Name + #13#10 +
                'Только первый файл будет обработан!');
          end else
          begin
            Ind := Self.IndexOf(M.ReadString('Properties\RUID'));
            if Ind = -1 then
            begin
              Obj := TgsNSNode.Create(M.ReadString('Properties\RUID'));
              AddObject(M.ReadString('Properties\RUID'), Obj);
            end else
              Obj := Self.Objects[Ind] as TgsNSNode;


            if (Obj.FileName > '') then
            begin
              if Assigned(FLog) then
                FLog('Пространство имен: "' + M.ReadString('Properties\Name') + '" содержится в файлах:' + #13#10 +
                  '1: ' + Obj.FileName + #13#10 + '2: ' + Name + #13#10 +
                  'Только первый файл будет обработан!');
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
                        if Assigned(FLog) then
                          FLog('Циклическая ссылка, файл ''' + (Self.Objects[Ind] as TgsNSNode).Name + '''!');
                    end else
                    begin
                      Self.AddObject(RUID, TgsNSNode.Create(RUID));
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
    end;
  finally   
    SL.Free;
    NSL.Free;
  end;
end; 

procedure TgsNSList.FillTree(ATreeView: TgsTreeView; AnInternal: Boolean);

  procedure AddNode(Node: TTreeNode; yamlNode: TgsNSNode);
  var
    Temp: TTreeNode;
    I, Ind: Integer;
  begin
    if not yamlNode.Valid then
    begin
      if Assigned(FLog) then
        FLog('Файл (RUID = ' + yamlNode.RUID + ') не найден!');
      Temp := ATreeView.Items.AddChildObject(Node, yamlNode.RUID, yamlNode);
      Temp.StateIndex := 0;
    end else
    begin
      Temp := ATreeView.Items.AddChildObject(Node, yamlNode.Caption, yamlNode);
      Temp.StateIndex := 2;
    end;  

    for I := 0 to yamlNode.UsesList.Count - 1 do
    begin
      Ind := IndexOf(yamlNode.UsesList[I]);
      if  Ind = -1 then
      begin
        if Assigned(FLog) and (FErrorNS.IndexOf(yamlNode.Name) = -1) then
        begin
          FLog('Файл (RUID = ' + yamlNode.UsesList[I] + ') не найден! Пространство имен ''' +
            yamlNode.Name + ''' установится некорректно!');
          FErrorNS.Add(yamlNode.Name);
        end;
      end else
        AddNode(Temp, Objects[Ind] as TgsNSNode);
    end;
  end;

var
  I, K: Integer;
  Link: Boolean;
  Parent: TList;
  Temp: TTreeNode;
begin
  Assert(ATreeView <> nil);
  FErrorNS.Clear;
  
  if not AnInternal then
  begin
    for I := 0 to Count - 1 do
    begin
      if not (Objects[I] as TgsNSNode).CheckOnlyInDB
        and (Objects[I] as TgsNSNode).Valid
        and (not (Objects[I] as TgsNSNode).Internal) then
      begin
        CorrectPack((Objects[I] as TgsNSNode).RUID);
        Temp := ATreeView.Items.AddChildObject(nil, (Objects[I] as TgsNSNode).Caption, Objects[I] as TgsNSNode);
        Temp.StateIndex := 2;
      end;
    end;
  end else
  begin
    Parent := TList.Create;
    try
      for I := 0 to Count - 1 do
      begin
        if (Objects[I] as TgsNSNode).CheckOnlyInDB then
          continue;
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
      FLog('Файл (RUID = ' + Node.RUID + ') не найден!');
    for I := 0 to Node.UsesList.Count - 1 do
    begin
      Ind := IndexOf(Node.UsesList[I]);
      if  (Ind = -1)
        and (FErrorNS.IndexOf(Node.Name) = -1)
        and Assigned(FLog) then
      begin
        FLog('Файл (RUID = ' + Node.UsesList[I] + ') не найден! Пространство имен ''' +
          Node.Name + ''' установится некорректно!');
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
    begin
      raise Exception.Create('Файл (RUID = ' + NSNode.RUID + ') не найден!');
     // Application.MessageBox(PChar('Файл (RUID = ' + NSNode.RUID + ') не найден!'), 'Внимание',
       // MB_OK or MB_ICONWARNING);
    end else
      SL.Add(NSNode.FileName);
  end;
end;

end.