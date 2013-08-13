
unit gdcNamespaceLoader;

interface

uses
  Classes, SysUtils, DB, IBDatabase, IBSQL, yaml_parser, gdcBaseInterface,
  gdcBase, gdcNamespace, JclStrHashMap;

type
  EgdcNamespaceLoader = class(Exception);

  TgdcNamespaceLoader = class(TObject)
  private
    FDontRemove: Boolean;
    FAlwaysOverwrite: Boolean;
    FLoadedNSList: TStringList;
    FTr: TIBTransaction;
    FqFindNS, FqOverwriteNSRUID: TIBSQL;
    FqLoadAtObject: TIBSQL;
    FgdcNamespace: TgdcNamespace;
    FAtObjectRecordCache: TStringHashMap;
    FgdcObjectCache: TStringHashMap;

    procedure FlushStorages;
    procedure LoadAtObjectCache(const ANamespaceKey: Integer);
    procedure LoadObject(AMapping: TYAMLMapping; const AFileTimeStamp: TDateTime);
    procedure CopyData(AnObj: TgdcBase; AMapping: TYAMLMapping; AnOverwriteFields: TStrings);
    procedure CopyField(AField: TField; AMapping: TYAMLMapping);
    procedure ParseReferenceString(const AStr: String; out ARUID: TRUID; out AName: String);

  public
    constructor Create;
    destructor Destroy; override;

    procedure Load(AList: TStrings);

    property AlwaysOverwrite: Boolean read FAlwaysOverwrite write FAlwaysOverwrite;
    property DontRemove: Boolean read FDontRemove write FDontRemove;
  end;

implementation

uses
  Storages, gd_security, at_classes, at_frmSQLProcess, gd_common_functions,
  gdcNamespaceRecCmpController;

type
  TAtObjectRecord = class(TObject)
  public
    ID: Integer;
    ObjectName: String;
    ObjectClass: CgdcBase;
    ObjectSubType: String;
    Modified: TDateTime;
    CurrModified: TDateTime;
    AlwaysOverwrite: Boolean;
    DontRemove: Boolean;
    HeadObjectKey: Integer;
  end;

{ TgdcNamespaceLoader }

procedure TgdcNamespaceLoader.CopyData(AnObj: TgdcBase;
  AMapping: TYAMLMapping; AnOverwriteFields: TStrings);
var
  I: Integer;
begin
  Assert(AnObj <> nil);
  Assert(AMapping <> nil);
  Assert(AnObj.State in [dsEdit, dsInsert]);

  if AnOverwriteFields = nil then
    for I := 0 to AnObj.FieldCount - 1 do
      CopyField(AnObj.Fields[I], AMapping)
  else
    for I := 0 to AnOverwriteFields.Count - 1 do
      CopyField(AnObj.FindField(AnOverwriteFields[I]), AMapping);
end;

procedure TgdcNamespaceLoader.CopyField(AField: TField;
  AMapping: TYAMLMapping);
var
  N: TYAMLNode;
  RelationName, FieldName: String;
  R: TatRelation;
  RF: TatRelationField;
begin
  if AField.ReadOnly or AField.Calculated then
    exit;

  N := AMapping.FindByName(AField.FieldName);

  if N = nil then
    exit;

  if N is TYAMLNull then
    AField.Clear
  else begin
    if (AField.DataType = ftInteger) and (AField.Origin > '') then
    begin
      ParseFieldOrigin(AField.Origin, RelationName, FieldName);

      R := atDatabase.Relations.ByRelationName(RelationName);

      if R <> nil then
      begin
        RF := R.RelationFields.ByFieldName(FieldName);
        if (RF <> nil) and (RF.References <> nil) then
        begin



        end;
      end;
    end;
  end;
end;

constructor TgdcNamespaceLoader.Create;
begin
  FLoadedNSList := TStringList.Create;
  FLoadedNSList.Sorted := True;
  FLoadedNSList.Duplicates := dupError;

  FTr := TIBTransaction.Create(nil);
  FTr.DefaultDatabase := gdcBaseManager.Database;
  FTr.Params.CommaText := 'read_committed,rec_version,nowait';

  FqFindNS := TIBSQL.Create(nil);
  FqFindNS.Transaction := FTr;
  FqFindNS.SQL.Text :=
    'SELECT n.id, n.name, 0 AS ByName ' +
    'FROM at_namespace n ' +
    '  JOIN gd_ruid r ON r.id = n.id ' +
    'WHERE ' +
    '  r.xid = :XID AND r.dbid = :DBID ' +
    'UNION ' +
    'SELECT n.id, n.name, 1 AS ByName ' +
    'FROM at_namespace n ' +
    'WHERE ' +
    '  UPPER(n.name) = :name ' +
    'ORDER BY 3 ASC';

  FqOverwriteNSRUID := TIBSQL.Create(nil);
  FqOverwriteNSRUID.Transaction := FTr;
  FqOverwriteNSRUID.SQL.Text :=
    'UPDATE OR INSERT INTO gd_ruid (id, xid, dbid, editorkey, modified) ' +
    'VALUES (:id, :xid, :dbid, :editorkey, CURRENT_TIMESTAMP(0)) ' +
    'MATCHING (id)';

  FqLoadAtObject := TIBSQL.Create(nil);
  FqLoadAtObject.Transaction := FTr;
  FqLoadAtObject.SQL.Text :=
    'SELECT * ' +
    'FROM at_object ' +
    'WHERE namespacekey = :nk ';

  FgdcNamespace := TgdcNamespace.Create(nil);
  FgdcNamespace.SubSet := 'ByID';
  FgdcNamespace.ReadTransaction := FTr;
  FgdcNamespace.Transaction := FTr;

  FAtObjectRecordCache := TStringHashMap.Create(CaseSensitiveTraits, 65536);
  FgdcObjectCache := TStringHashMap.Create(CaseSensitiveTraits, 1024);
end;

destructor TgdcNamespaceLoader.Destroy;
begin
  FgdcObjectCache.Iterate(nil, Iterate_FreeObjects);
  FgdcObjectCache.Free;
  FAtObjectRecordCache.Iterate(nil, Iterate_FreeObjects);
  FAtObjectRecordCache.Free;
  FLoadedNSList.Free;
  FgdcNamespace.Free;
  FqFindNS.Free;
  FqOverwriteNSRUID.Free;
  FqLoadAtObject.Free;
  FTr.Free;
  inherited;
end;

procedure TgdcNamespaceLoader.FlushStorages;
begin
  Assert(GlobalStorage <> nil);
  Assert(UserStorage <> nil);
  Assert(CompanyStorage <> nil);

  GlobalStorage.SaveToDatabase;
  UserStorage.SaveToDatabase;
  CompanyStorage.SaveToDatabase;
end;

procedure TgdcNamespaceLoader.Load(AList: TStrings);
var
  I, J: Integer;
  Parser: TyamlParser;
  Mapping: TyamlMapping;
  Objects: TyamlSequence;
  NSRUID: TRUID;
  NSName: String;
begin
  Assert(AList <> nil);

  for I := 0 to AList.Count - 1 do
  begin
    if FLoadedNSList.IndexOf(AList[I]) > -1 then
      continue;

    FlushStorages;

    AddText('Файл: ' + AList[I]);

    Parser := TYAMLParser.Create;
    try
      Parser.Parse(AList[I]);

      if (Parser.YAMLStream.Count = 0)
        or ((Parser.YAMLStream[0] as TyamlDocument).Count = 0)
        or (not ((Parser.YAMLStream[0] as TyamlDocument)[0] is TyamlMapping)) then
      begin
        raise EgdcNamespaceLoader.Create('Invalid YAML stream.');
      end;

      Mapping := (Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping;

      if Mapping.ReadString('StructureVersion') <> '1.0' then
        raise EgdcNamespaceLoader.Create('Unsupported YAML stream version.');

      Objects := Mapping.FindByName('Objects') as TYAMLSequence;

      if (Objects = nil) or (not (Objects is TYAMLSequence)) then
        raise EgdcNamespaceLoader.Create('Invalid YAML stream.');

      NSRUID := StrToRUID(Mapping.ReadString('Properties\RUID'));
      NSName := Mapping.ReadString('Properties\Name');

      FTr.StartTransaction;
      try
        FqFindNS.ParamByName('xid').AsInteger := NSRUID.XID;
        FqFindNS.ParamByName('dbid').AsInteger := NSRUID.DBID;
        FqFindNS.ParamByName('name').AsString := AnsiUpperCase(NSName);
        FqFindNS.ExecQuery;

        AddText('Пространство имен: ' + NSName);

        if FqFindNS.EOF then
        begin
          FgdcNamespace.Open;
          FgdcNamespace.Insert;
          AddText('Создано в базе данных');
        end else
        begin
          FgdcNamespace.ID := FqFindNS.FieldByName('id').AsInteger;
          FgdcNamespace.Open;
          FgdcNamespace.Edit;
          if FqFindNS.FieldByName('ByName').AsInteger <> 0 then
            AddText('Найдено по имени')
          else
            AddText('Найдено по РУИДу');
        end;

        FgdcNamespace.FieldByName('name').AsString := Mapping.ReadString('Properties\Name', 255);
        FgdcNamespace.FieldByName('caption').AsString := Mapping.ReadString('Properties\Caption', 255);
        FgdcNamespace.FieldByName('version').AsString := Mapping.ReadString('Properties\Version', 20);
        FgdcNamespace.FieldByName('dbversion').AsString := Mapping.ReadString('Properties\DBversion', 20);
        FgdcNamespace.FieldByName('optional').AsInteger := Mapping.ReadInteger('Properties\Optional', 0);
        FgdcNamespace.FieldByName('internal').AsInteger := Mapping.ReadInteger('Properties\Internal', 1);
        FgdcNamespace.FieldByName('comment').AsString := Mapping.ReadString('Properties\Comment');
        FgdcNamespace.FieldByName('filetimestamp').AsDateTime := gd_common_functions.GetFileLastWrite(AList[I]);
        if FgdcNamespace.FieldByName('filetimestamp').AsDateTime > Now then
          FgdcNamespace.FieldByName('filetimestamp').AsDateTime := Now;
        FgdcNamespace.FieldByName('filename').AsString := System.Copy(AList[I], 1, 255);
        FgdcNamespace.Post;

        FqOverwriteNSRUID.ParamByName('id').AsInteger := FgdcNamespace.ID;
        FqOverwriteNSRUID.ParamByName('xid').AsInteger := NSRUID.XID;
        FqOverwriteNSRUID.ParamByName('dbid').AsInteger := NSRUID.DBID;
        FqOverwriteNSRUID.ParamByName('editorkey').AsInteger := IBLogin.ContactKey;
        FqOverwriteNSRUID.ExecQuery;

        TgdcNamespace.UpdateCurrModified(FgdcNamespace.ID);
        LoadAtObjectCache(FgdcNamespace.ID);

        for J := 0 to Objects.Count - 1 do
        begin
          if not (Objects[J] is TYAMLMapping) then
            raise EgdcNamespaceLoader.Create('Invalid YAML stream.');
          LoadObject(Objects[J] as TYAMLMapping, FgdcNamespace.FieldByName('filetimestamp').AsDateTime);
        end;

        FTr.Commit;

        FLoadedNSList.Add(AList[I]);
      finally
        if FTr.InTransaction then
          FTr.Rollback;
        FAtObjectRecordCache.Iterate(nil, Iterate_FreeObjects);
        FAtObjectRecordCache.Clear;
      end;
    finally
      Parser.Free;
    end;
  end;
end;

procedure TgdcNamespaceLoader.LoadAtObjectCache(const ANamespaceKey: Integer);
var
  AR: TAtObjectRecord;
  ObjectRUID: String;
  C: TPersistentClass;
begin
  FqLoadAtObject.ParamByName('nk').AsInteger := ANamespaceKey;
  FqLoadAtObject.ExecQuery;
  try
    while not FqLoadAtObject.EOF do
    begin
      ObjectRUID := RUIDToStr(RUID(FqLoadAtObject.FieldByName('xid').AsInteger,
        FqLoadAtObject.FieldByName('dbid').AsInteger));

      Assert(not FAtObjectRecordCache.Has(ObjectRUID));

      C := GetClass(FqLoadAtObject.FieldByName('objectclass').AsString);
      if (C <> nil) and C.InheritsFrom(TgdcBase) then
      begin
        AR := TatObjectRecord.Create;
        AR.ID := FqLoadAtObject.FieldByName('id').AsInteger;
        AR.ObjectName := FqLoadAtObject.FieldByName('objectname').AsString;
        AR.ObjectClass := CgdcBase(C);
        AR.ObjectSubType := FqLoadAtObject.FieldByName('subtype').AsString;
        AR.HeadObjectKey := FqLoadAtObject.FieldByName('headobjectkey').AsInteger;
        AR.AlwaysOverwrite := FqLoadAtObject.FieldByName('alwaysoverwrite').AsInteger <> 0;
        AR.DontRemove := FqLoadAtObject.FieldByName('dontremove').AsInteger <> 0;
        AR.Modified := FqLoadAtObject.FieldByName('modified').AsDateTime;
        AR.CurrModified := FqLoadAtObject.FieldByName('curr_modified').AsDateTime;
        FAtObjectRecordCache.Add(ObjectRUID, AR);
      end;

      FqLoadAtObject.Next;
    end;
  finally
    FqLoadAtObject.Close;
  end;
end;

procedure TgdcNamespaceLoader.LoadObject(AMapping: TYAMLMapping;
  const AFileTimeStamp: TDateTime);
var
  HashKey: String;
  Obj: TgdcBase;
  C: TPersistentClass;
  AtObjectRecord: TatObjectRecord;
  ObjRUID: TRUID;
begin
  HashKey := AMapping.ReadString('Properties\Class') + AMapping.ReadString('Properties\SubType');

  if not FgdcObjectCache.Find(HashKey, Obj) then
  begin
    C := GetClass(AMapping.ReadString('Properties\Class'));

    if (C = nil) or (not C.InheritsFrom(TgdcBase)) then
      raise EgdcNamespaceLoader.Create('Invalid class name ' + AMapping.ReadString('Properties\Class'));

    Obj := CgdcBase(C).Create(nil);
    try
      Obj.SubType := AMapping.ReadString('Properties\SubType');
      Obj.ReadTransaction := FTr;
      Obj.Transaction := FTr;
      Obj.SubSet := 'ByID';
      Obj.BaseState := Obj.BaseState + [sLoadFromStream];
    except
      Obj.Free;
      raise;
    end;

    FgdcObjectCache.Add(HashKey, Obj);
  end;

  if not FAtObjectRecordCache.Find(AMapping.ReadString('Properties\RUID'), AtObjectRecord) then
    AtObjectRecord := nil;

  if FAlwaysOverwrite
    or AMapping.ReadBoolean('Properties\AlwaysOverwrite', False)
    or (AtObjectRecord = nil)
    or ((tiEditionDate in Obj.GetTableInfos(Obj.SubType))
         and
        (AMapping.ReadDateTime('Fields\EDITIONDATE', 0) > AtObjectRecord.CurrModified)) then
  begin
    ObjRUID := StrToRUID(AMapping.ReadString('Properties\RUID'));

    if AtObjectRecord <> nil then
    begin
      Obj.Close;
      Obj.ID := gdcBaseManager.GetIDByRUID(ObjRUID.XID, ObjRUID.DBID, FTr);
    end;

    Obj.Open;

    if not Obj.EOF then
      with TgdcNamespaceRecCmpController.Create do
      try
        Compare(nil, Obj, AMapping);
      finally
        Free;
      end;
  end;
end;

procedure TgdcNamespaceLoader.ParseReferenceString(const AStr: String;
  out ARUID: TRUID; out AName: String);
var
  P: Integer;
begin
  P := Pos(' ', AStr);
  if P = 0 then
  begin
    ARUID := StrToRUID(AStr);
    AName := '';
  end else
  begin
    ARUID := StrToRUID(System.Copy(AStr, 1, P - 1));
    AName := System.Copy(AStr, P + 1, MaxInt);
  end;
end;

end.
