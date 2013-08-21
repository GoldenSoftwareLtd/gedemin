
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
    FqLoadAtObject, FqClearAtObject: TIBSQL;
    FgdcNamespace: TgdcNamespace;
    FgdcNamespaceObject: TgdcNamespaceObject;
    FAtObjectRecordCache: TStringHashMap;
    FgdcObjectCache: TStringHashMap;
    FDelayedUpdate: TStringList;
    FqDelayed: TIBSQL;
    FqFindAtObject: TIBSQL;

    procedure FlushStorages;
    procedure LoadAtObjectCache(const ANamespaceKey: Integer);
    procedure LoadObject(AMapping: TYAMLMapping; const AFileTimeStamp: TDateTime);
    procedure CopyRecord(AnObj: TgdcBase; AMapping: TYAMLMapping; AnOverwriteFields: TStrings);
    procedure CopyField(AField: TField; N: TyamlScalar);
    procedure CopySetAttributes(AnObj: TgdcBase; const AnObjID: TID; ASequence: TYAMLSequence);
    procedure ParseReferenceString(const AStr: String; out ARUID: TRUID; out AName: String);
    procedure OverwriteRUID(const AnID, AXID, ADBID: TID);
    function Iterate_RemoveGDCObjects(AUserData: PUserData; const AStr: string; var APtr: PData): Boolean;
    function CacheObject(const AClassName: String; const ASubtype: String): TgdcBase;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Load(AList: TStrings);

    property AlwaysOverwrite: Boolean read FAlwaysOverwrite write FAlwaysOverwrite;
    property DontRemove: Boolean read FDontRemove write FDontRemove;
  end;

implementation

uses
  IBHeader, Storages, gd_security, at_classes, at_frmSQLProcess, gd_common_functions,
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
    Loaded: Boolean;
  end;

{ TgdcNamespaceLoader }

procedure TgdcNamespaceLoader.CopyRecord(AnObj: TgdcBase;
  AMapping: TYAMLMapping; AnOverwriteFields: TStrings);
var
  I: Integer;
  N: TYAMLNode;
  F: TField;
begin
  Assert(AnObj <> nil);
  Assert(AMapping <> nil);
  Assert(AnObj.State in [dsEdit, dsInsert]);

  if AnOverwriteFields = nil then
    for I := 0 to AnObj.FieldCount - 1 do
    begin
      F := AnObj.Fields[I];
      N := AMapping.FindByName(F.FieldName);
      if N is TyamlScalar then
        CopyField(F, N as TyamlScalar);
    end
  else
    for I := 0 to AnOverwriteFields.Count - 1 do
    begin
      F := AnObj.FindField(AnOverwriteFields[I]);
      N := AMapping.FindByName(F.FieldName);
      if N is TyamlScalar then
        CopyField(F, N as TyamlScalar);
    end;
end;

procedure TgdcNamespaceLoader.CopyField(AField: TField; N: TyamlScalar);
var
  RelationName, FieldName: String;
  RefName: String;
  RefRUID: TRUID;
  RefID: TID;
  R: TatRelation;
  RF: TatRelationField;
begin
  Assert(AField <> nil);
  Assert(N <> nil);

  if AField.ReadOnly or AField.Calculated then
    exit;

  if N.IsNull then
  begin
    AField.Clear;
    exit;
  end;

  if (AField.DataType = ftInteger) and (AField.Origin > '') then
  begin
    ParseFieldOrigin(AField.Origin, RelationName, FieldName);
    R := atDatabase.Relations.ByRelationName(RelationName);
    if R <> nil then
    begin
      RF := R.RelationFields.ByFieldName(FieldName);
      if (RF <> nil) and (RF.References <> nil)
        and (R.PrimaryKey <> nil)
        and (R.PrimaryKey.ConstraintFields.Count > 0)
        and (R.PrimaryKey.ConstraintFields[0] <> RF) then
      begin
        ParseReferenceString(N.AsString, RefRUID, RefName);
        RefID := gdcBaseManager.GetIDByRUID(RefRUID.XID, RefRUID.DBID, FTr);
        if RefID = -1 then
        begin
          AField.Clear;
          FDelayedUpdate.Add('UPDATE ' + RelationName + ' SET ' +
            FieldName + ' = (SELECT id FROM gd_ruid WHERE xid = ' +
            IntToStr(RefRUID.XID) + ' AND dbid = ' +
            IntToStr(RefRUID.DBID) + ')');
          exit;
        end else
        begin
          AField.AsInteger := RefID;
          exit;
        end;
      end;
    end;
  end;

  case AField.DataType of
    ftSmallint, ftInteger: AField.AsInteger := N.AsInteger;
    ftCurrency, ftBCD: AField.AsCurrency := N.AsCurrency;
    ftTime, ftDateTime: AField.AsDateTime := N.AsDateTime;
    ftDate: AField.AsDateTime := N.AsDate;
    ftFloat: AField.AsFloat := N.AsFloat;
    ftBoolean: AField.AsBoolean := N.AsBoolean;
    ftLargeInt: (AField as TLargeIntField).AsLargeInt := N.AsInt64;
  else
    AField.AsString := N.AsString;
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
    'SELECT o.* ' +
    'FROM at_object o ' +
    'WHERE o.namespacekey = :nk ';

  FgdcNamespace := TgdcNamespace.Create(nil);
  FgdcNamespace.SubSet := 'ByID';
  FgdcNamespace.ReadTransaction := FTr;
  FgdcNamespace.Transaction := FTr;

  FgdcNamespaceObject := TgdcNamespaceObject.Create(nil);
  FgdcNamespaceObject.SubSet := 'All';
  FgdcNamespaceObject.ReadTransaction := FTr;
  FgdcNamespaceObject.Transaction := FTr;

  FAtObjectRecordCache := TStringHashMap.Create(CaseSensitiveTraits, 65536);
  FgdcObjectCache := TStringHashMap.Create(CaseSensitiveTraits, 1024);

  FDelayedUpdate := TStringList.Create;
  FqDelayed := TIBSQL.Create(nil);
  FqDelayed.Transaction := FTr;

  FqClearAtObject := TIBSQL.Create(nil);
  FqClearAtObject.Transaction := FTr;
  FqClearAtObject.SQL.Text :=
    'DELETE FROM at_object WHERE namespacekey = :nk';

  FqFindAtObject := TIBSQL.Create(nil);
  FqFindAtObject.Transaction := FTr;
  FqFindAtObject.SQL.Text :=
    'SELECT id FROM at_object WHERE namespacekey <> :nk ' +
    '  AND xid = :xid AND dbid = :dbid';
end;

destructor TgdcNamespaceLoader.Destroy;
begin
  FqFindAtObject.Free;
  FqClearAtObject.Free;
  FqDelayed.Free;
  FDelayedUpdate.Free;
  FgdcObjectCache.Iterate(nil, Iterate_FreeObjects);
  FgdcObjectCache.Free;
  FAtObjectRecordCache.Iterate(nil, Iterate_FreeObjects);
  FAtObjectRecordCache.Free;
  FLoadedNSList.Free;
  FgdcNamespace.Free;
  FgdcNamespaceObject.Free;
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
  I, J, K: Integer;
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

      NSRUID := StrToRUID(Mapping.ReadString('Properties\RUID'));
      NSName := Mapping.ReadString('Properties\Name');

      if not (Mapping.FindByName('Objects') is TYAMLSequence) then
        raise EgdcNamespaceLoader.Create('Invalid YAML stream.');

      Objects := Mapping.FindByName('Objects') as TYAMLSequence;

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

        OverwriteRUID(FgdcNamespace.ID, NSRUID.XID, NSRUID.DBID);

        TgdcNamespace.UpdateCurrModified(FgdcNamespace.ID);
        LoadAtObjectCache(FgdcNamespace.ID);

        FqClearAtObject.ParamByName('nk').AsInteger := FgdcNamespace.ID;
        FqClearAtObject.ExecQuery;

        FgdcNamespaceObject.Open;

        for J := 0 to Objects.Count - 1 do
        begin
          if not (Objects[J] is TYAMLMapping) then
            raise EgdcNamespaceLoader.Create('Invalid YAML stream.');
          LoadObject(Objects[J] as TYAMLMapping, FgdcNamespace.FieldByName('filetimestamp').AsDateTime);
        end;

        for K := 0 to FDelayedUpdate.Count - 1 do
        begin
          FqDelayed.SQL.Text := FDelayedUpdate[K];
          FqDelayed.ExecQuery;
        end;

        FDelayedUpdate.Clear;

        FAtObjectRecordCache.IterateMethod(nil, Iterate_RemoveGDCObjects);

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
        AR.Loaded := False;
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
  Obj: TgdcBase;
  AtObjectRecord: TatObjectRecord;
  ObjRUID, HeadObjectRUID: TRUID;
  ObjName: String;
  Fields: TYAMLMapping;
  ObjID: TID;
begin
  Obj := CacheObject(AMapping.ReadString('Properties\Class'),
    AMapping.ReadString('Properties\SubType'));
  ObjRUID := StrToRUID(AMapping.ReadString('Properties\RUID'));

  if FAtObjectRecordCache.Find(AMapping.ReadString('Properties\RUID'),
    AtObjectRecord) then
  begin
    AtObjectRecord.Loaded := True;
    ObjName := AtObjectRecord.ObjectName;
  end else
  begin
    AtObjectRecord := nil;
    ObjName := '';
  end;

  if not (AMapping.FindByName('Fields') is TYAMLMapping) then
    raise EgdcNamespaceLoader.Create('Invalid data structure');

  Fields := AMapping.FindByName('Fields') as TYAMLMapping;

  if FAlwaysOverwrite
    or AMapping.ReadBoolean('Properties\AlwaysOverwrite', False)
    or (AtObjectRecord = nil)
    or ((tiEditionDate in Obj.GetTableInfos(Obj.SubType))
         and
        (Fields.ReadDateTime('EDITIONDATE', 0) > AtObjectRecord.CurrModified))
    or ((not (tiEditionDate in Obj.GetTableInfos(Obj.SubType)))
         and
        (AFileTimeStamp > AtObjectRecord.CurrModified)) then
  begin
    Obj.Close;

    if AtObjectRecord <> nil then
    begin
      Obj.ID := gdcBaseManager.GetIDByRUID(ObjRUID.XID, ObjRUID.DBID, FTr);
      Obj.Open;

      if Obj.EOF then
      begin
        gdcBaseManager.DeleteRUIDByXID(ObjRUID.XID, ObjRUID.DBID, FTr);
        Obj.Insert;
        CopyRecord(Obj, Fields, nil);
        Obj.Post;
      end else
      begin
        if (AtObjectRecord.Modified < AtObjectRecord.CurrModified)
          and (not FAlwaysOverwrite)
          and (not AMapping.ReadBoolean('Properties\AlwaysOverwrite', False)) then
        begin
          with TgdcNamespaceRecCmpController.Create do
          try
            if Compare(nil, Obj, AMapping) then
            begin
              Obj.Edit;
              CopyRecord(Obj, Fields, OverwriteFields);
              Obj.Post;
            end;
          finally
            Free;
          end;
        end else
        begin
          Obj.Edit;
          CopyRecord(Obj, Fields, nil);
          Obj.Post;
        end;
      end;
    end else
    begin
      Obj.ID := -1;
      Obj.Open;
      Obj.Insert;
      CopyRecord(Obj, Fields, nil);
      Obj.Post;
    end;

    OverwriteRUID(Obj.ID, ObjRUID.XID, ObjRUID.DBID);

    ObjID := Obj.ID;
    ObjName := Obj.ObjectName;
    Obj.Close;

    if AMapping.FindByName('Set') is TYAMLSequence then
      CopySetAttributes(Obj, ObjID, AMapping.FindByName('Set') as TYAMLSequence);
  end;

  FgdcNamespaceObject.Insert;
  FgdcNamespaceObject.FieldByName('namespacekey').AsInteger := FgdcNamespace.ID;
  FgdcNamespaceObject.FieldByName('objectname').AsString := ObjName;
  FgdcNamespaceObject.FieldByName('objectclass').AsString := AMapping.ReadString('Properties\Class');
  FgdcNamespaceObject.FieldByName('subtype').AsString := AMapping.ReadString('Properties\Subtype');
  FgdcNamespaceObject.FieldByName('xid').AsInteger := ObjRUID.XID;
  FgdcNamespaceObject.FieldByName('dbid').AsInteger := ObjRUID.DBID;
  if AMapping.ReadBoolean('Properties\AlwaysOverwrite', False) then
    FgdcNamespaceObject.FieldByName('alwaysoverwrite').AsInteger := 1
  else
    FgdcNamespaceObject.FieldByName('alwaysoverwrite').AsInteger := 0;
  if AMapping.ReadBoolean('Properties\DontRemove', False) then
    FgdcNamespaceObject.FieldByName('dontremove').AsInteger := 1
  else
    FgdcNamespaceObject.FieldByName('dontremove').AsInteger := 0;
  if AMapping.ReadBoolean('Properties\IncludeSiblings', False) then
    FgdcNamespaceObject.FieldByName('includesiblings').AsInteger := 1
  else
    FgdcNamespaceObject.FieldByName('includesiblings').AsInteger := 0;
  if tiEditionDate in Obj.GetTableInfos(Obj.SubType) then
  begin
    FgdcNamespaceObject.FieldByName('modified').AsDateTime := Fields.ReadDateTime('EDITIONDATE');
    FgdcNamespaceObject.FieldByName('curr_modified').AsDateTime := Fields.ReadDateTime('EDITIONDATE');
  end else
  begin
    FgdcNamespaceObject.FieldByName('modified').AsDateTime := SysUtils.Now;
    FgdcNamespaceObject.FieldByName('curr_modified').AsDateTime :=
      FgdcNamespaceObject.FieldByName('modified').AsDateTime;
  end;
  FgdcNamespaceObject.Post;

  HeadObjectRUID := StrToRUID(AMapping.ReadString('Properties\HeadObject', 21, ''));
  if HeadObjectRUID.XID > -1 then
  begin
    FDelayedUpdate.Add(
      'UPDATE at_object SET headobjectkey = ' +
      '  (SELECT id FROM at_object WHERE namespacekey = ' + IntToStr(FgdcNamespace.ID) +
      '     AND xid = ' + IntToStr(HeadObjectRUID.XID) +
      '     AND dbid = ' + IntToStr(HeadObjectRUID.DBID) +
      '  ) ' +
      'WHERE id = ' + IntToStr(FgdcNamespaceObject.ID)
    );
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

procedure TgdcNamespaceLoader.OverwriteRUID(const AnID, AXID, ADBID: TID);
begin
  FqOverwriteNSRUID.ParamByName('id').AsInteger := AnID;
  FqOverwriteNSRUID.ParamByName('xid').AsInteger := AXID;
  FqOverwriteNSRUID.ParamByName('dbid').AsInteger := ADBID;
  FqOverwriteNSRUID.ParamByName('editorkey').AsInteger := IBLogin.ContactKey;
  FqOverwriteNSRUID.ExecQuery;

  gdcBaseManager.RemoveRUIDFromCache(AXID, ADBID);
end;

function TgdcNamespaceLoader.Iterate_RemoveGDCObjects(AUserData: PUserData;
  const AStr: string; var APtr: PData): Boolean;
var
  AR: TatObjectRecord;
  ObjRUID: TRUID;
  Obj: TgdcBase;
begin
  AR := TatObjectRecord(APtr);

  if not AR.Loaded then
  begin
    ObjRUID := StrToRUID(AStr);

    FqFindAtObject.Close;
    FqFindAtObject.ParamByName('nk').AsInteger := FgdcNamespace.ID;
    FqFindAtObject.ParamByName('xid').AsInteger := ObjRUID.XID;
    FqFindAtObject.ParamByName('dbid').AsInteger := ObjRUID.DBID;
    FqFindAtObject.ExecQuery;

    if FqFindAtObject.EOF and (not AR.DontRemove) then
    begin
      Obj := CacheObject(AR.ObjectClass.ClassName, AR.ObjectSubType);
      Obj.Close;
      Obj.ID := gdcBaseManager.GetIDByRUIDString(AStr);
      Obj.Open;
      if not Obj.EOF then
      begin
        AddText('Удаляется объект ' + Obj.ObjectName);
        Obj.Delete;
      end;
      Obj.Close;
    end;

    FqFindAtObject.Close;
  end;  

  Result := True;
end;

function TgdcNamespaceLoader.CacheObject(const AClassName,
  ASubtype: String): TgdcBase;
var
  HashKey: String;
  C: TPersistentClass;
begin
  HashKey := AClassName + ASubType;

  if not FgdcObjectCache.Find(HashKey, Result) then
  begin
    C := GetClass(AClassName);

    if (C = nil) or (not C.InheritsFrom(TgdcBase)) then
      raise EgdcNamespaceLoader.Create('Invalid class name ' + AClassName);

    Result := CgdcBase(C).Create(nil);
    try
      Result.SubType := ASubType;
      Result.ReadTransaction := FTr;
      Result.Transaction := FTr;
      Result.SubSet := 'ByID';
      Result.BaseState := Result.BaseState + [sLoadFromStream];
    except
      Result.Free;
      raise;
    end;

    FgdcObjectCache.Add(HashKey, Result);
  end;
end;

procedure TgdcNamespaceLoader.CopySetAttributes(AnObj: TgdcBase;
  const AnObjID: TID; ASequence: TYAMLSequence);
var
  I, J, K, T: Integer;
  q: TIBSQL;
  R: TatRelation;
  Mapping, CrossFields: TYAMLMapping;
  Items: TYAMLSequence;
  FieldName, RefName: String;
  RefRUID: TRUID;
  MS: TStream;
  Param: TIBXSQLVAR;
begin
  for I := 0 to ASequence.Count - 1 do
  begin
    if not (ASequence[I] is TYAMLMapping) then
      break;

    Mapping := ASequence[I] as TYAMLMapping;

    for J := 0 to AnObj.SetAttributesCount - 1 do
    begin
      if AnsiCompareText(Mapping.ReadString('Table'),
        AnObj.SetAttributes[J].CrossRelationName) <> 0 then
        continue;

      R := atDatabase.Relations.ByRelationName(AnObj.SetAttributes[J].CrossRelationName);
      if (R <> nil) and (R.PrimaryKey <> nil)
        and (Mapping.FindByName('Items') is TYAMLSequence) then
      begin
        Items := Mapping.FindbyName('Items') as TYAMLSequence;
        q := TIBSQL.Create(nil);
        try
          q.Transaction := AnObj.Transaction;

          q.SQL.Text := 'DELETE FROM ' + R.RelationName +
            ' WHERE ' + R.PrimaryKey.ConstraintFields[0].FieldName +
            '=' + IntToStr(AnObjID);
          q.ExecQuery;

          q.SQL.Text := AnObj.SetAttributes[J].InsertSQL;
          for K := 0 to Items.Count - 1 do
          begin
            if not (Items[K] is TYAMLMapping) then
              break;

            CrossFields := Items[K] as TYAMLMapping;
            for T := 0 to R.RelationFields.Count - 1 do
            begin
              FieldName := R.RelationFields[T].FieldName;
              Param := q.ParamByName(FieldName);

              if (R.PrimaryKey.ConstraintFields[0] = R.RelationFields[T]) then
                Param.AsInteger := AnObjID
              else begin
                if (CrossFields.FindByName(FieldName) = nil) or CrossFields.ReadNull(FieldName) then
                begin
                  Param.Clear;
                  continue;
                end;

                case Param.SQLType of
                SQL_LONG, SQL_SHORT:
                  if R.RelationFields[T].References <> nil then
                  begin
                    ParseReferenceString(CrossFields.ReadString(FieldName), RefRUID, RefName);
                    Param.AsInteger := gdcBaseManager.GetIDByRUID(RefRUID.XID,
                      RefRUID.DBID, AnObj.Transaction);
                  end else
                  begin
                    if Param.AsXSQLVAR.sqlscale = 0 then
                      Param.AsInteger := CrossFields.ReadInteger(FieldName)
                    else
                      Param.AsCurrency := CrossFields.ReadCurrency(FieldName);
                  end;
                SQL_INT64:
                  if Param.AsXSQLVAR.sqlscale = 0 then
                    Param.AsInt64 := CrossFields.ReadInt64(FieldName)
                  else
                    Param.AsCurrency := CrossFields.ReadCurrency(FieldName);
                SQL_FLOAT, SQL_D_FLOAT, SQL_DOUBLE:
                  Param.AsFloat := CrossFields.ReadFloat(FieldName);
                SQL_TYPE_DATE, SQL_TIMESTAMP, SQL_TYPE_TIME:
                  Param.AsDateTime := CrossFields.ReadDateTime(FieldName);
                SQL_BLOB:
                  if Param.AsXSQLVar.sqlsubtype = 1 then
                    Param.AsString := CrossFields.ReadString(FieldName)
                  else begin
                    MS := TMemoryStream.Create;
                    try
                      CrossFields.ReadStream(FieldName, MS);
                      MS.Position := 0;
                      Param.LoadFromStream(MS);
                    finally
                      MS.Free;
                    end;
                  end;
                else
                  Param.AsString := CrossFields.ReadString(FieldName);
                end;
              end;
            end;
            q.ExecQuery;
          end;
        finally
          q.Free;
        end;
      end;

      break;
    end;
  end;
end;

end.
