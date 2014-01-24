
unit gdcNamespaceLoader;

interface

uses
  Classes, Windows, Messages, Forms, SysUtils, ContNrs, DB, IBDatabase, IBSQL,
  yaml_parser, gdcBaseInterface, gdcBase, gdcNamespace, JclStrHashMap, gd_KeyAssoc;

const
  WM_LOAD_NAMESPACE = WM_USER + 1001;

type
  EgdcNamespaceLoader = class(Exception);

  TgdcNamespaceLoaderNexus = class(TForm)
  private
    FList: TStringList;
    FAlwaysOverwrite: Boolean;
    FDontRemove: Boolean;
    FTerminate: Boolean;
    FLoading: Boolean;

    procedure WMLoadNamespace(var Msg: TMessage);
      message WM_LOAD_NAMESPACE;

  public
    destructor Destroy; override;

    procedure LoadNamespace(AList: TStrings; const AnAlwaysOverwrite: Boolean;
      const ADontRemove: Boolean; const ATerminate: Boolean);

    property Loading: Boolean read FLoading;
  end;

  TgdcNamespaceLoader = class(TObject)
  private
    FDontRemove: Boolean;
    FAlwaysOverwrite: Boolean;
    FLoadedNSList: TStringList;
    FTr: TIBTransaction;
    FqFindNS, FqInsertNSRUID: TIBSQL;
    FqFindRUID: TIBSQL;
    FqLoadAtObject, FqClearAtObject: TIBSQL;
    FgdcNamespace: TgdcNamespace;
    FgdcNamespaceObject: TgdcNamespaceObject;
    FAtObjectRecordCache: TStringHashMap;
    FgdcObjectCache: TStringHashMap;
    FDelayedUpdate: TStringList;
    FqFindAtObject: TIBSQL;
    FMetadataCounter: Integer;
    FNeedRelogin: Boolean;
    FPrevPosted: CgdcBase;
    FqCheckTheSame: TIBSQL;
    FRemoveList: TObjectList;
    FSecondPassList: TObjectList;
    FOurCompanies: TgdKeyArray;
    FLoading: Boolean;

    procedure FlushStorages;
    procedure LoadAtObjectCache(const ANamespaceKey: Integer);
    procedure LoadObject(AMapping: TYAMLMapping; const ANamespaceKey: TID;
      const AFileTimeStamp: TDateTime; const ASecondPass: Boolean);
    function CopyRecord(AnObj: TgdcBase; AMapping: TYAMLMapping; AnOverwriteFields: TStrings): Boolean;
    procedure CopyField(AField: TField; N: TyamlScalar);
    procedure CopySetAttributes(AnObj: TgdcBase; const AnObjID: TID; ASequence: TYAMLSequence);
    procedure OverwriteRUID(const AnID, AXID, ADBID: TID);
    function Iterate_RemoveGDCObjects(AUserData: PUserData; const AStr: string; var APtr: PData): Boolean;
    function CacheObject(const AClassName: String; const ASubtype: String): TgdcBase;
    procedure UpdateUses(ASequence: TYAMLSequence; const ANamespaceKey: TID);
    procedure ProcessMetadata;
    procedure LoadParam(AParam: TIBXSQLVAR; const AFieldName: String;
      AMapping: TYAMLMapping; ATr: TIBTransaction);
    function GetCandidateID(AnObj: TgdcBase; AFields: TYAMLMapping): TID;
    procedure RemoveObjects;
    procedure ReloginDatabase;
    procedure DelayedUpdate;
    procedure LoadOurCompanies;

  public
    constructor Create;
    destructor Destroy; override;

    class procedure LoadDelayed(AList: TStrings; const AnAlwaysOverwrite: Boolean;
      const ADontRemove: Boolean; const ATerminate: Boolean);
    class function LoadingDelayed: Boolean;

    procedure Load(AList: TStrings);

    property AlwaysOverwrite: Boolean read FAlwaysOverwrite write FAlwaysOverwrite;
    property DontRemove: Boolean read FDontRemove write FDontRemove;
    property Loading: Boolean read FLoading;
  end;

implementation

uses
  IBHeader, Storages, gd_security, at_classes, at_frmSQLProcess,
  at_sql_metadata, gd_common_functions, gdcNamespaceRecCmpController,
  gdcMetadata, gdcFunction, gd_directories_const, mtd_i_Base, evt_i_Base,
  gd_CmdLineParams_unit;

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

  TAtRemoveRecord = class(TObject)
  public
    RUID: TRUID;
    ObjectClass: CgdcBase;
    ObjectSubType: String;
  end;

var
  FNexus: TgdcNamespaceLoaderNexus;

{ TgdcNamespaceLoader }

function TgdcNamespaceLoader.CopyRecord(AnObj: TgdcBase;
  AMapping: TYAMLMapping; AnOverwriteFields: TStrings): Boolean;
var
  I, Idx: Integer;
  N: TYAMLNode;
  F: TField;
  SL: TStringList;
  KV: TyamlKeyValue;
  S, SName: String;
begin
  Assert(AnObj <> nil);
  Assert(AMapping <> nil);
  Assert(AnObj.State in [dsEdit, dsInsert]);

  Result := False;

  if AnObj.State = dsInsert then
  begin
    SName := AMapping.ReadString('name', 60, '');
    if SName = '' then
      SName := AMapping.ReadString('usr$name', 60, '');
    if SName = '' then
      S := 'Добавляется объект: '
    else
      S := 'Добавляется объект: ' + SName + ', ';
  end else
    S := 'Изменяется объект: ' + AnObj.ObjectName + ', ';

  AddText(S +
    RUIDToStr(AnObj.GetRUID) + ', ' +
    AnObj.GetListTable(AnObj.SubType));

  if AnOverwriteFields = nil then
  begin
    SL := TStringList.Create;
    try
      for I := 0 to AMapping.Count - 1 do
      begin
        KV := AMapping.Items[I] as TyamlKeyValue;
        if KV.Value is TyamlScalar then
          SL.AddObject(KV.Key, KV.Value);
      end;

      SL.Sorted := True;
      
      for I := 0 to AnObj.FieldCount - 1 do
      begin
        F := AnObj.Fields[I];
        Idx := SL.IndexOf(F.FieldName);
        if Idx > -1 then
        begin
          CopyField(F, SL.Objects[Idx] as TyamlScalar);
          SL.Delete(Idx);
        end else if (Pos('USR$', F.FieldName) = 1) and (not F.ReadOnly) and (not F.Calculated) then
          AddWarning('Отсутствует в файле: ' + F.Origin);
      end;

      for I := 0 to SL.Count - 1 do
      begin
        if not (SL.Objects[I] as TyamlScalar).IsNull then
        begin
          AddWarning('Отсутствует в базе: ' + SL[I]);
          Result := True;
        end;  
      end;
    finally
      SL.Free;
    end;
  end else
    for I := 0 to AnOverwriteFields.Count - 1 do
    begin
      F := AnObj.FieldByName(AnOverwriteFields[I]);
      N := AMapping.FindByName(F.FieldName);
      if N is TyamlScalar then
        CopyField(F, N as TyamlScalar)
      else if (Pos('USR$', F.FieldName) = 1) and (not F.ReadOnly) and (not F.Calculated) then
        AddWarning('Отсутствует в файле: ' + F.Origin);
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
  Flag: Boolean;
  TempS: String;
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

  if (AField.DataType = ftInteger) and (AField.Origin > '')
    and (N is TYAMLString) then
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
        TgdcNamespace.ParseReferenceString(N.AsString, RefRUID, RefName);
        RefID := gdcBaseManager.GetIDByRUID(RefRUID.XID, RefRUID.DBID, FTr);

        if RF.References.RelationName = 'GD_OURCOMPANY' then
        begin
          if FOurCompanies.IndexOf(RefID) = -1 then
          begin
            RefID := IBLogin.CompanyKey;
            AddWarning('Вместо рабочей организации РУИД=' + RUIDToStr(RefRUID) +
              ' подставлена текущая организация.');
          end;
        end;

        if RefID = -1 then
        begin
          AField.Clear;
          FDelayedUpdate.Add('UPDATE ' + RelationName + ' SET ' +
            FieldName + ' = (SELECT id FROM gd_ruid WHERE xid = ' +
            IntToStr(RefRUID.XID) + ' AND dbid = ' +
            IntToStr(RefRUID.DBID) + ') ' +
            'WHERE ' + R.PrimaryKey.ConstraintFields[0].FieldName + ' = ' +
            IntToStr((AField.DataSet as TgdcBase).ID) +
            '  AND ' + FieldName + ' IS NULL');
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
    ftBlob, ftGraphic:
      if (N is TyamlBinary) and (AField is TBlobField) then
        TBlobField(AField).LoadFromStream(TyamlBinary(N).AsStream)
      else begin
        Flag := False;

        if (AField.DataSet.ClassName = 'TgdcStorageValue') then
        begin
          TempS := N.AsString;
          if TryObjectTextToBinary(TempS) then
          begin
            AField.AsString := TempS;
            Flag := True;
          end
        end;

        if not Flag then
          AField.AsString := N.AsString;
      end;
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
  FTr.Name := 'NSLoaderTr';
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

  FqInsertNSRUID := TIBSQL.Create(nil);
  FqInsertNSRUID.Transaction := FTr;
  FqInsertNSRUID.SQL.Text :=
    'INSERT INTO gd_ruid (id, xid, dbid, editorkey, modified) ' +
    'VALUES (:id, :xid, :dbid, :editorkey, CURRENT_TIMESTAMP(0))';

  FqFindRUID := TIBSQL.Create(nil);
  FqFindRUID.Transaction := FTr;
  FqFindRUID.SQL.Text :=
    'SELECT xid, dbid FROM gd_ruid WHERE id = :id';

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
  FgdcNamespace.BaseState := FgdcNamespace.BaseState + [sLoadFromStream];

  FgdcNamespaceObject := TgdcNamespaceObject.Create(nil);
  FgdcNamespaceObject.SubSet := 'All';
  FgdcNamespaceObject.ReadTransaction := FTr;
  FgdcNamespaceObject.Transaction := FTr;

  FAtObjectRecordCache := TStringHashMap.Create(CaseSensitiveTraits, 65536);
  FgdcObjectCache := TStringHashMap.Create(CaseSensitiveTraits, 1024);

  FDelayedUpdate := TStringList.Create;

  FqClearAtObject := TIBSQL.Create(nil);
  FqClearAtObject.Transaction := FTr;
  FqClearAtObject.SQL.Text :=
    'DELETE FROM at_object WHERE namespacekey = :nk';

  FqFindAtObject := TIBSQL.Create(nil);
  FqFindAtObject.Transaction := FTr;
  FqFindAtObject.SQL.Text :=
    'SELECT id FROM at_object WHERE xid = :xid AND dbid = :dbid';

  FqCheckTheSame := TIBSQL.Create(nil);
  FqCheckTheSame.Transaction := FTr;

  FRemoveList := TObjectList.Create(True);
  FSecondPassList := TObjectList.Create(True);

  FOurCompanies := TgdKeyArray.Create;
end;

destructor TgdcNamespaceLoader.Destroy;
begin
  FOurCompanies.Free;
  FSecondPassList.Free;
  FRemoveList.Free;
  FqCheckTheSame.Free;
  FqFindAtObject.Free;
  FqClearAtObject.Free;
  FDelayedUpdate.Free;
  FgdcObjectCache.Iterate(nil, Iterate_FreeObjects);
  FgdcObjectCache.Free;
  FAtObjectRecordCache.Iterate(nil, Iterate_FreeObjects);
  FAtObjectRecordCache.Free;
  FLoadedNSList.Free;
  FgdcNamespace.Free;
  FgdcNamespaceObject.Free;
  FqFindNS.Free;
  FqInsertNSRUID.Free;
  FqFindRUID.Free;
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
  NSID: TID;
  NSTimeStamp: TDateTime;
  NSRUID: TRUID;
  NSName, NSList: String;
  q: TIBSQL;
begin
  Assert(not FLoading);
  Assert(AList <> nil);
  Assert(IBLogin <> nil);

  NSList := '';
  FLoading := True;
  FRemoveList.Clear;
  LoadOurCompanies;

  if AList.Count > 1 then
  begin
    AddText('Порядок загрузки:');
    for I := 0 to AList.Count - 1 do
      AddText(IntToStr(I) + ': ' + AList[I]);
  end;

  for I := 0 to AList.Count - 1 do
  begin
    if FLoadedNSList.IndexOf(AList[I]) > -1 then
      continue;

    FPrevPosted := nil;
    FNeedRelogin := False;
    FMetadataCounter := 0;
    FlushStorages;

    AddText('=====================================');
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

      FTr.StartTransaction;
      try
        FqFindNS.ParamByName('xid').AsInteger := NSRUID.XID;
        FqFindNS.ParamByName('dbid').AsInteger := NSRUID.DBID;
        FqFindNS.ParamByName('name').AsString := AnsiUpperCase(NSName);
        FqFindNS.ExecQuery;

        FgdcNamespace.StreamXID := NSRUID.XID;
        FgdcNamespace.StreamDBID := NSRUID.DBID;

        if FqFindNS.EOF then
        begin
          FgdcNamespace.Open;
          FgdcNamespace.Insert;
          AddText('Создано новое пространство имен: ' + NSName);
        end else
        begin
          FgdcNamespace.ID := FqFindNS.FieldByName('id').AsInteger;
          FgdcNamespace.Open;
          FgdcNamespace.Edit;
          if FqFindNS.FieldByName('ByName').AsInteger <> 0 then
            AddText('Пространство имен найдено по наименованию: ' + NSName)
          else
            AddText('Пространство имен найдено по РУИД: ' + NSName);
        end;

        FgdcNamespace.FieldByName('name').AsString := Mapping.ReadString('Properties\Name', 255);
        FgdcNamespace.FieldByName('caption').AsString := Mapping.ReadString('Properties\Caption', 255);
        FgdcNamespace.FieldByName('version').AsString := Mapping.ReadString('Properties\Version', 20);
        FgdcNamespace.FieldByName('dbversion').AsString := Mapping.ReadString('Properties\DBversion', 20);
        FgdcNamespace.FieldByName('optional').AsInteger := Mapping.ReadInteger('Properties\Optional', 0);
        FgdcNamespace.FieldByName('internal').AsInteger := Mapping.ReadInteger('Properties\Internal', 1);
        FgdcNamespace.FieldByName('settingruid').AsString := Mapping.ReadString('Properties\SettingRUID', 21);
        FgdcNamespace.FieldByName('comment').AsString := Mapping.ReadString('Properties\Comment');
        FgdcNamespace.FieldByName('filetimestamp').AsDateTime := gd_common_functions.GetFileLastWrite(AList[I]);
        if FgdcNamespace.FieldByName('filetimestamp').AsDateTime > Now then
          FgdcNamespace.FieldByName('filetimestamp').AsDateTime := Now;
        FgdcNamespace.FieldByName('filename').AsString := System.Copy(AList[I], 1, 255);
        (FgdcNamespace.FieldByName('filedata') as TBlobField).LoadFromFile(AList[I]);
        FgdcNamespace.Post;

        NSID := FgdcNamespace.ID;
        NSList := NSList + IntToStr(NSID) + ',';
        NSTimeStamp := FgdcNamespace.FieldByName('filetimestamp').AsDateTime;

        OverwriteRUID(NSID, NSRUID.XID, NSRUID.DBID);

        TgdcNamespace.UpdateCurrModified(FTr, NSID);
        LoadAtObjectCache(NSID);

        FqClearAtObject.ParamByName('nk').AsInteger := NSID;
        FqClearAtObject.ExecQuery;

        if Mapping.FindByName('Objects') is TYAMLSequence then
        begin
          Objects := Mapping.FindByName('Objects') as TYAMLSequence;

          for J := 0 to Objects.Count - 1 do
          begin
            if not (Objects[J] is TYAMLMapping) then
              raise EgdcNamespaceLoader.Create('Invalid YAML stream.');
            LoadObject(Objects[J] as TYAMLMapping, NSID, NSTimeStamp, False);
          end;

          FAtObjectRecordCache.IterateMethod(@NSID, Iterate_RemoveGDCObjects);

          if FMetadataCounter > 0 then
            ProcessMetadata;
        end;

        if Mapping.FindByName('Uses') is TYAMLSequence then
          UpdateUses(Mapping.FindByName('Uses') as TYAMLSequence, NSID);

        if FgdcNamespaceObject.Active then
          FgdcNamespaceObject.Close;

        if FgdcNamespace.Active then
          FgdcNamespace.Close;

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

    DelayedUpdate;

    if FNeedRelogin then
      ReloginDatabase;

    AddText('Закончена загрузка: ' + NSName);
  end;

  if FSecondPassList.Count > 0 then
  begin
    AddText('Повторная загрузка объектов:');

    FgdcObjectCache.Iterate(nil, Iterate_FreeObjects);
    FgdcObjectCache.Clear;

    FTr.StartTransaction;
    try
      for K := 0 to FSecondPassList.Count - 1 do
        LoadObject(FSecondPassList[K] as TYAMLMapping, -1, 0, True);
      if FMetadataCounter > 0 then
        ProcessMetadata;
      FTr.Commit;
      DelayedUpdate;
    finally
      FSecondPassList.Clear;
      if FTr.InTransaction then
        FTr.Rollback;
    end;
    AddText('Окончена повторная загрузка объектов.');
  end;

  if FRemoveList.Count > 0 then
  begin
    FTr.StartTransaction;
    try
      RemoveObjects;
      if FMetadataCounter > 0 then
        ProcessMetadata;
    finally
      FTr.Commit;
    end;
  end;

  if FNeedRelogin then
    ReloginDatabase;

  q := TIBSQL.Create(nil);
  FTr.StartTransaction;
  try
    q.Transaction := FTr;
    if NSList > '' then
    begin
      q.SQL.Text := 'UPDATE at_namespace SET changed = 0 WHERE id IN (' +
        System.Copy(NSList, 1, Length(NSList) - 1) + ')';
      q.ExecQuery;
    end;
  finally
    q.Free;
    FTr.Commit;
  end;

  FLoading := False;

  Assert(FAtObjectRecordCache.Count = 0);
  Assert(FRemoveList.Count = 0);
  Assert(FSecondPassList.Count = 0);
  Assert(FDelayedUpdate.Count = 0);
  Assert(not FNeedRelogin);
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
  const ANamespaceKey: TID; const AFileTimeStamp: TDateTime;
  const ASecondPass: Boolean);
var
  Obj: TgdcBase;
  AtObjectRecord: TatObjectRecord;
  ObjRUID, HeadObjectRUID: TRUID;
  ObjName, ObjRUIDString, S, SWarn: String;
  Fields: TYAMLMapping;
  ObjID, CandidateID, RUIDID: TID;
  ObjPosted, ObjPreserved, CrossTableCreated: Boolean;
  NeedSecondPass: Boolean;
  TempMapping: TyamlMapping;
begin
  ObjPosted := False;
  ObjPreserved := False;
  CrossTableCreated := False;
  NeedSecondPass := False;
  Obj := CacheObject(AMapping.ReadString('Properties\Class'),
    AMapping.ReadString('Properties\SubType'));
  ObjRUIDString := AMapping.ReadString('Properties\RUID');
  ObjRUID := StrToRUID(ObjRUIDString);

  if (not ASecondPass) and FAtObjectRecordCache.Find(ObjRUIDString, AtObjectRecord) then
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
    or ASecondPass
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

    if (Obj is TgdcTableField) and (AMapping.ReadString('Fields\COMPUTED_VALUE') > '') then
      ProcessMetadata;

    if (FPrevPosted <> nil) and (not Obj.InheritsFrom(FPrevPosted)) then
    begin
      if FPrevPosted.InheritsFrom(TgdcField) or FPrevPosted.InheritsFrom(TgdcRelation) then
        ProcessMetadata;
    end;

    RUIDID := gdcBaseManager.GetIDByRUIDString(ObjRUIDString, FTr);

    Obj.StreamXID := ObjRUID.XID;
    Obj.StreamDBID := ObjRUID.DBID;

    CandidateID := GetCandidateID(Obj, Fields);

    if (RUIDID > -1) and (RUIDID < cstUserIDStart) then
    begin
      if (CandidateID > -1) and (CandidateID <> RUIDID) then
      begin
        Obj.ID := CandidateID;
        Obj.Open;
        if Obj.EOF then
          raise EgdcNamespaceLoader.Create('Internal error. CandidateID not found.');
        SWarn :=
          'При попытке загрузки стандартного объекта типа ' + Obj.GetDisplayName(Obj.SubType) + #13#10 +
          'РУИД = ' + ObjRUIDString + ' в базе данных обнаружен объект с ИД = ' + IntToStr(CandidateID) + '.'#13#10#13#10 +
          'Существующий объект необходимо отредактировать для устранения неоднозначности.';
        if not gd_CmdLineParams.QuietMode then
        begin
          if MessageBox(0, PChar(SWarn), 'Внимание', MB_OKCANCEL or MB_ICONEXCLAMATION or MB_TASKMODAL) = IDOK then
            Obj.EditDialog
          else begin
            AddMistake('Процесс прерван пользователем');
            Abort;
          end;
        end else
          AddWarning(SWarn);
        Obj.Close;
      end;

      Obj.ID := RUIDID;
      Obj.Open;
      if Obj.EOF then
      begin
        Obj.Insert;
        Obj.ID := RUIDID;
        AddText('Стандартный объект ' + Obj.GetDisplayName(Obj.SubType) +
          ' ИД = ' + IntToStr(RUIDID) + '. Отсутствует в БД. Будет добавлен.');
      end else
        Obj.Edit;
    end else
    begin
      if (CandidateID > -1) and (CandidateID <> RUIDID) then
      begin
        Obj.ID := CandidateID;
        Obj.Open;
        if Obj.EOF then
          raise EgdcNamespaceLoader.Create('Invalid check the same statement.');
        Obj.Edit;
        AddText('Объект найден по потенциальному ключу: ' + Obj.ObjectName +
          ' (' + Obj.GetDisplayName(Obj.SubType) + ')');
        if RUIDID > -1 then
        begin
          gdcBaseManager.DeleteRUIDByID(RUIDID, FTr);
          AddWarning('РУИД ' + ObjRUIDString + ' перенаправлен с ИД ' +
            IntToStr(RUIDID) + ' на ИД ' +
            IntToStr(CandidateID));
        end;
      end
      else if RUIDID > -1 then
      begin
        Obj.ID := RUIDID;
        Obj.Open;
        if Obj.EOF then
        begin
          gdcBaseManager.DeleteRUIDByXID(ObjRUID.XID, ObjRUID.DBID, FTr);
          Obj.Insert;
        end else
          Obj.Edit;
      end else
      begin
        Obj.Open;
        Obj.Insert;
      end;
    end;

    if (Obj.State = dsEdit)
      and (AtObjectRecord <> nil)
      and (AtObjectRecord.Modified < AtObjectRecord.CurrModified)
      and (not FAlwaysOverwrite)
      and (not ASecondPass)
      and (not AMapping.ReadBoolean('Properties\AlwaysOverwrite', False)) then
    begin
      with TgdcNamespaceRecCmpController.Create do
      try
        if Compare(nil, Obj, AMapping) then
          NeedSecondPass := CopyRecord(Obj, Fields, OverwriteFields)
        else begin
          AddText('Объект сохранен в исходном состоянии: ' + Obj.ObjectName);
          ObjPreserved := True;

          if CancelLoad then
          begin
            AddWarning('Процесс загрузки прерван пользователем.');
            Abort;
          end;
        end;
      finally
        Free;
      end;
    end else
      NeedSecondPass := CopyRecord(Obj, Fields, nil);

    if Obj.State = dsInsert then
      S := 'Создан объект: '
    else
      S := 'Изменен объект: ';

    S := S + Obj.ObjectName + ' (' + Obj.GetDisplayName(Obj.SubType) + ')';

    Obj.Post;
    if (Obj.GetRUID.XID <> ObjRUID.XID) or (Obj.GetRUID.DBID <> ObjRUID.DBID) then
      AddMistake('Изменился РУИД объекта ' + RUIDToStr(ObjRUID) + ' -> ' + RUIDToStr(Obj.GetRUID));
    AddText(S);
    ObjPosted := True;
    ObjID := Obj.ID;

    if ObjID >= cstUserIDStart then
      OverwriteRUID(ObjID, ObjRUID.XID, ObjRUID.DBID);

    ObjName := Obj.ObjectName;
    if ObjName = '' then
      ObjName := Obj.GetDisplayName(Obj.SubType);

    if (Obj is TgdcRelationField) and (Obj.FieldByName('crosstable').AsString > '') then
      CrossTableCreated := True;

    Obj.Close;

    if AMapping.FindByName('Set') is TYAMLSequence then
      CopySetAttributes(Obj, ObjID, AMapping.FindByName('Set') as TYAMLSequence);

    if NeedSecondPass then
    begin
      if ASecondPass then
        AddWarning('Поле(я) отсутствует(ют) в БД после повторной загрузки!')
      else begin
        if Obj is TgdcMetaBase then
          AddMistake('Метаданные не могут быть загружены повторно!')
        else begin
          TempMapping := TyamlMapping.Create;
          TempMapping.Assign(AMapping);
          FSecondPassList.Add(TempMapping);
        end;
      end;
    end;
  end;

  if not ASecondPass then
  begin
    if not FgdcNamespaceObject.Active then
      FgdcNamespaceObject.Open;
    FgdcNamespaceObject.Insert;
    FgdcNamespaceObject.FieldByName('namespacekey').AsInteger := ANamespaceKey;
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
    if ObjPreserved and (AtObjectRecord <> nil) then
    begin
      FgdcNamespaceObject.FieldByName('modified').AsDateTime := AtObjectRecord.Modified;
      FgdcNamespaceObject.FieldByName('curr_modified').AsDateTime := AtObjectRecord.CurrModified;
    end else
    begin
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
    end;
    FgdcNamespaceObject.Post;
  end;

  HeadObjectRUID := StrToRUID(AMapping.ReadString('Properties\HeadObject', 21, ''));
  if HeadObjectRUID.XID > -1 then
  begin
    FDelayedUpdate.Add(
      'UPDATE at_object SET headobjectkey = ' +
      '  (SELECT id FROM at_object WHERE namespacekey = ' + IntToStr(ANamespaceKey) +
      '     AND xid = ' + IntToStr(HeadObjectRUID.XID) +
      '     AND dbid = ' + IntToStr(HeadObjectRUID.DBID) +
      '  ) ' +
      'WHERE id = ' + IntToStr(FgdcNamespaceObject.ID)
    );
  end;

  if ObjPosted then
  begin
    if Obj is TgdcFunction then
      FNeedRelogin := True;

    if CrossTableCreated then
      ProcessMetadata
    else if Obj is TgdcMetaBase then
      Inc(FMetadataCounter)
    else if FMetadataCounter > 0 then
      ProcessMetadata;

    FPrevPosted := CgdcBase(Obj.ClassType);
  end;
end;

procedure TgdcNamespaceLoader.OverwriteRUID(const AnID, AXID, ADBID: TID);
var
  AtObjectRecord: TAtObjectRecord;
begin
  Assert(
    ((AnID >= cstUserIDStart) and (AXID >= cstUserIDSTart))
    or
    ((AnID < cstUserIDStart) and (ADBID = cstEtalonDBID) and (AnID = AXID))
  );

  FqFindRUID.ParamByName('id').AsInteger := AnID;
  FqFindRUID.ExecQuery;
  try
    if FqFindRUID.EOF then
    begin
      FqInsertNSRUID.ParamByName('id').AsInteger := AnID;
      FqInsertNSRUID.ParamByName('xid').AsInteger := AXID;
      FqInsertNSRUID.ParamByName('dbid').AsInteger := ADBID;
      FqInsertNSRUID.ParamByName('editorkey').AsInteger := IBLogin.ContactKey;
      FqInsertNSRUID.ExecQuery;
    end
    else if (FqFindRUID.FieldByName('xid').AsInteger <> AXID)
      or (FqFindRUID.FieldByName('dbid').AsInteger <> ADBID) then
    begin
      gdcBaseManager.ChangeRUID(FqFindRUID.FieldByName('xid').AsInteger,
        FqFindRUID.FieldByName('dbid').AsInteger, AXID, ADBID, FTr);

      AddWarning('Изменился РУИД объекта ' +
        RUIDToStr(FqFindRUID.FieldByName('xid').AsInteger, FqFindRUID.FieldByName('dbid').AsInteger) +
        ' -> ' +
        RUIDToStr(AXID, ADBID));
        
      if FAtObjectRecordCache.Find(RUIDToStr(FqFindRUID.FieldByName('xid').AsInteger,
        FqFindRUID.FieldByName('dbid').AsInteger), AtObjectRecord) then
      begin
        AtObjectRecord.Loaded := True;
      end;
    end;
  finally
    FqFindRUID.Close;
  end;
end;

function TgdcNamespaceLoader.Iterate_RemoveGDCObjects(AUserData: PUserData;
  const AStr: string; var APtr: PData): Boolean;
var
  AR: TatObjectRecord;
  RR: TatRemoveRecord;
begin
  AR := TatObjectRecord(APtr);

  if (not AR.Loaded) and (not AR.DontRemove) then
  begin
    RR := TatRemoveRecord.Create;
    RR.RUID := StrToRUID(AStr);
    RR.ObjectClass := AR.ObjectClass;
    RR.ObjectSubType := AR.ObjectSubType;
    FRemoveList.Add(RR);
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
  Mapping: TYAMLMapping;
  Items: TYAMLSequence;
  FieldName, KF: String;
  Param: TIBXSQLVAR;
  SetItemAdded: Boolean;
begin
  SetItemAdded := False;
  q := TIBSQL.Create(nil);
  try
    q.Transaction := AnObj.Transaction;

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

          q.SQL.Text := 'DELETE FROM ' + R.RelationName +
            ' WHERE ' + R.PrimaryKey.ConstraintFields[0].FieldName +
            '=' + IntToStr(AnObjID);
          q.ExecQuery;

          q.SQL.Text := AnObj.SetAttributes[J].InsertSQL;
          for K := 0 to Items.Count - 1 do
          begin
            if not (Items[K] is TYAMLMapping) then
              break;

            for T := 0 to R.RelationFields.Count - 1 do
            begin
              FieldName := R.RelationFields[T].FieldName;
              Param := q.ParamByName(FieldName);

              if (R.PrimaryKey.ConstraintFields[0] = R.RelationFields[T]) then
                Param.AsInteger := AnObjID
              else
                LoadParam(Param, FieldName, Items[K] as TYAMLMapping, AnObj.Transaction);
            end;

            try
              q.ExecQuery;
              SetItemAdded := True;
            except
              on E: Exception do
              begin
                AddMistake('Ошибка при добавлении элемента множества: ' + E.Message + #13#10 +
                  q.SQL.Text);
              end;
            end;
          end;
        end;

        break;
      end;
    end;

    if SetItemAdded then
    begin
      // холостой апдейт, чтобы отработали триггеры заполнения
      // текстового представления полей-множест
      KF := AnObj.GetKeyField(AnObj.SubType);
      q.SQL.Text :=
        'UPDATE ' + AnObj.GetListTable(AnObj.SubType) +
        '  SET ' + KF + ' = :id' +
        '  WHERE ' + KF + ' = :id';
      q.ParamByName('id').AsInteger := AnObjID;
      q.ExecQuery;
    end;
  finally
    q.Free;
  end;
end;

procedure TgdcNamespaceLoader.UpdateUses(ASequence: TYAMLSequence;
  const ANamespaceKey: TID);
var
  I: Integer;
  q: TIBSQL;
  NSRUID: TRUID;
  NSName: String;
  NSID: TID;
begin
  Assert(ASequence <> nil);
  Assert(ANamespaceKey > -1);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTr;

    q.SQL.Text :=
      'DELETE FROM at_namespace_link WHERE namespacekey = :nk';
    q.ParamByName('nk').AsInteger := ANamespaceKey;
    q.ExecQuery;

    for I := 0 to ASequence.Count - 1 do
    begin
      if not (ASequence[I] is TYAMLString) then
        raise EgdcNamespaceLoader.Create('Invalid data structure');

      TgdcNamespace.ParseReferenceString(
        (ASequence[I] as TYAMLString).AsString, NSRUID, NSName);

      q.Close;
      q.SQL.Text :=
        'SELECT n.id FROM at_namespace n JOIN gd_ruid r ' +
        '  ON r.id = n.id ' +
        'WHERE r.xid = :xid AND r.dbid = :dbid';
      q.ParamByName('xid').AsInteger := NSRUID.XID;
      q.ParamByName('dbid').AsInteger := NSRUID.DBID;
      q.ExecQuery;

      if not q.EOF then
      begin
        NSID := q.FieldByName('id').AsInteger;
        q.Close;
      end else
      begin
        NSID := gdcBaseManager.GetNextID;

        q.Close;
        q.SQL.Text :=
          'INSERT INTO at_namespace (id, name) ' +
          'VALUES (:id, :name)';
        q.ParamByName('id').AsInteger := NSID;
        q.ParamByName('name').AsString := NSName;
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO gd_ruid (id, xid, dbid, modified, editorkey) ' +
          'VALUES (:id, :xid, :dbid, CURRENT_TIMESTAMP, :editorkey) ' +
          'MATCHING (xid, dbid)';
        q.ParamByName('id').AsInteger := NSID;
        q.ParamByName('xid').AsInteger := NSRUID.XID;
        q.ParamByName('dbid').AsInteger := NSRUID.DBID;
        q.ParamByName('editorkey').AsInteger := IBLogin.ContactKey;
        q.ExecQuery;
      end;

      q.SQL.Text :=
        'INSERT INTO at_namespace_link (namespacekey, useskey) ' +
        'VALUES (:namespacekey, :useskey)';
      q.ParamByName('namespacekey').AsInteger := ANamespaceKey;
      q.ParamByName('useskey').AsInteger := NSID;
      q.ExecQuery;
    end;
  finally
    q.Free;
  end;
end;

procedure TgdcNamespaceLoader.ProcessMetadata;
var
  q: TIBSQL;
  RunMultiConnection: Boolean;
begin
  Assert(atDatabase <> nil);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTr;
    q.SQL.Text := 'SELECT * FROM at_transaction';
    q.ExecQuery;
    RunMultiConnection := not q.EOF;
  finally
    q.Free;
  end;

  AddText('Коммит транзакции...');

  FTr.Commit;
  gdcBaseManager.ReadTransaction.Commit;
  gdcBaseManager.Database.Connected := False;
  try
    if RunMultiConnection then
      with TmetaMultiConnection.Create do
      try
        RunScripts(False);
      finally
        Free;
      end;
  finally
    gdcBaseManager.Database.Connected := True;
    if not gdcBaseManager.ReadTransaction.InTransaction then
      gdcBaseManager.ReadTransaction.StartTransaction;
    FTr.StartTransaction;
  end;

  if RunMultiConnection then
    atDatabase.ForceLoadFromDatabase;

  FMetadataCounter := 0;
  FNeedRelogin := True;
end;

class procedure TgdcNamespaceLoader.LoadDelayed(AList: TStrings;
  const AnAlwaysOverwrite, ADontRemove, ATerminate: Boolean);
begin
  if FNexus = nil then
    FNexus := TgdcNamespaceLoaderNexus.CreateNew(nil);
  FNexus.LoadNamespace(AList, AnAlwaysOverwrite, ADontRemove, ATerminate);
end;

procedure TgdcNamespaceLoader.LoadParam(AParam: TIBXSQLVAR; const AFieldName: String;
  AMapping: TYAMLMapping; ATr: TIBTransaction);
var
  V: TYAMLScalar;
  RefRUID, RefName: String;
begin
  if (not (AMapping.FindByName(AFieldName) is TYAMLScalar)) or AMapping.ReadNull(AFieldName) then
  begin
    AParam.Clear;
    exit;
  end;

  V := AMapping.FindByName(AFieldName) as TYAMLScalar;

  case AParam.SQLType of
  SQL_LONG, SQL_SHORT:
    if (V is TYAMLString) and ParseReferenceString(V.AsString, RefRUID, RefName) then
    begin
      AParam.AsInteger := gdcBaseManager.GetIDByRUIDString(RefRUID, ATr);
      if AParam.AsInteger = -1 then
        AddMistake('Объект не найден: ' + V.AsString);
    end else if AParam.AsXSQLVAR.sqlscale = 0 then
      AParam.AsInteger := V.AsInteger
    else
      AParam.AsCurrency := V.AsCurrency;
  SQL_INT64:
    if AParam.AsXSQLVAR.sqlscale = 0 then
      AParam.AsInt64 := V.AsInt64
    else
      AParam.AsCurrency := V.AsCurrency;
  SQL_FLOAT, SQL_D_FLOAT, SQL_DOUBLE:
    AParam.AsFloat := V.AsFloat;
  SQL_TYPE_DATE, SQL_TIMESTAMP, SQL_TYPE_TIME:
    AParam.AsDateTime := V.AsDateTime;
  SQL_BLOB:
    if AParam.AsXSQLVar.sqlsubtype = 1 then
      AParam.AsString := V.AsString
    else
      AParam.LoadFromStream(V.AsStream);
  else
    AParam.AsString := V.AsString;
  end;
end;

function TgdcNamespaceLoader.GetCandidateID(AnObj: TgdcBase; AFields: TYAMLMapping): TID;
var
  CheckStmt, S: String;
  I: Integer;
begin
  Result := -1;

  try
    CheckStmt := AnObj.CheckTheSameStatement;

    if CheckStmt > '' then
    try
      FqCheckTheSame.SQL.Text := CheckStmt;
      FqCheckTheSame.Prepare;

      for I := 0 to FqCheckTheSame.Params.Count - 1 do
        LoadParam(FqCheckTheSame.Params[I], FqCheckTheSame.Params[I].Name,
          AFields, AnObj.Transaction);

      FqCheckTheSame.ExecQuery;

      if not FqCheckTheSame.EOF then
      begin
        Result := FqCheckTheSame.Fields[0].AsInteger;

        FqCheckTheSame.Next;
        if not FqCheckTheSame.EOF then
        begin
          S := 'Поиск по потенциальному ключу.'#13#10 +
            'Запрос вернул многострочный набор данных:'#13#10 + CheckStmt;
          for I := 0 to FqCheckTheSame.Params.Count - 1 do
          begin
            S := S + #13#10 + FqCheckTheSame.Params[I].Name + ': ';
            if FqCheckTheSame.Params[I].IsNull then
              S := S + 'NULL'
            else
              S := S + FqCheckTheSame.Params[I].AsString;
          end;
          AddWarning(S);
          Result := -1;
        end;
      end;
    finally
      FqCheckTheSame.Close;
    end;
  except
    on E: Exception do
    begin
      AddWarning('Ошибка в процессе поиска по потенциальному ключу: '#13#10 +
        E.Message);
    end;
  end;
end;

procedure TgdcNamespaceLoader.RemoveObjects;
var
  I: Integer;
  RR: TatRemoveRecord;
  Obj: TgdcBase;
  ObjectName: String;
begin
  for I := FRemoveList.Count - 1 downto 0 do
  begin
    RR := FRemoveList[I] as TatRemoveRecord;

    FqFindAtObject.ParamByName('xid').AsInteger := RR.RUID.XID;
    FqFindAtObject.ParamByName('dbid').AsInteger := RR.RUID.DBID;
    FqFindAtObject.ExecQuery;

    if FqFindAtObject.EOF then
    begin
      Obj := CacheObject(RR.ObjectClass.ClassName, RR.ObjectSubType);
      Obj.Close;
      Obj.ID := gdcBaseManager.GetIDByRUID(RR.RUID.XID, RR.RUID.DBID);
      Obj.Open;
      if (not Obj.EOF) and (Obj.ID >= cstUserIDStart) then
      begin
        if (not (Obj is TgdcMetaBase)) or TgdcMetaBase(Obj).IsUserDefined then
        begin
          try
            ObjectName := Obj.ObjectName + ' (' + Obj.GetDisplayName(Obj.SubType) + ')';
            Obj.Delete;
            if Obj is TgdcFunction then
              FNeedRelogin := True;
            AddText('Удален объект: ' + ObjectName);
          except
            on E: Exception do
            begin
              AddWarning('Объект не может быть удален: ' +
                ObjectName + #13#10 + E.Message);
            end;
          end;
          if Obj is TgdcMetaBase then
            Inc(FMetadataCounter);
        end;
      end;
      Obj.Close;
    end;

    FqFindAtObject.Close;
  end;

  FRemoveList.Clear;
end;

procedure TgdcNamespaceLoader.ReloginDatabase;
begin
  AddText('Переподключение к базе данных...');
  atDatabase.SyncIndicesAndTriggers(FTr);
  IBLogin.Relogin;
  FNeedRelogin := False;
end;

procedure TgdcNamespaceLoader.DelayedUpdate;
var
  K: Integer;
begin
  Assert(not FTr.InTransaction);

  if FDelayedUpdate.Count > 0 then
  begin
    AddText('Отложенное обновление записей:');
    FTr.StartTransaction;
    try
      for K := 0 to FDelayedUpdate.Count - 1 do
        try
          AddText(FDelayedUpdate[K]);
          FTr.ExecSQLImmediate(FDelayedUpdate[K]);
        except
          on E: Exception do
            AddMistake(E.Message);
        end;
      FDelayedUpdate.Clear;
    finally
      FTr.Commit;
    end;
  end;
end;

procedure TgdcNamespaceLoader.LoadOurCompanies;
var
  q: TIBSQL;
begin
  FOurCompanies.Clear;
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text := 'SELECT companykey FROM gd_ourcompany';
    q.ExecQuery;
    while not q.EOF do
    begin
      FOurCompanies.Add(q.Fields[0].AsInteger);
      q.Next;
    end;
  finally
    q.Free;
  end;
end;

class function TgdcNamespaceLoader.LoadingDelayed: Boolean;
begin
  Result := (FNexus <> nil) and FNexus.Loading;
end;

{ TgdcNamespaceLoaderNexus }

destructor TgdcNamespaceLoaderNexus.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TgdcNamespaceLoaderNexus.LoadNamespace(AList: TStrings;
  const AnAlwaysOverwrite, ADontRemove, ATerminate: Boolean);
begin
  if FLoading then
    raise EgdcNamespaceLoader.Create('Namespace is loading.');
  if FList = nil then
    FList := TStringList.Create;
  FList.Assign(AList);
  FAlwaysOverwrite := AnAlwaysOverwrite;
  FDontRemove := ADontRemove;
  FTerminate := ATerminate;
  PostMessage(Handle, WM_LOAD_NAMESPACE, 0, 0);
end;

procedure TgdcNamespaceLoaderNexus.WMLoadNamespace(var Msg: TMessage);
var
  L: TgdcNamespaceLoader;
begin
  Assert(not FLoading);
  Assert(FList <> nil);

  FLoading := True;
  try
    L := TgdcNamespaceLoader.Create;
    try
      L.AlwaysOverwrite := FAlwaysOverwrite;
      L.DontRemove := FDontRemove;
      try
        L.Load(FList);
      except
        on E: Exception do
        begin
          AddMistake(E.Message);
          if not gd_CmdLineParams.QuietMode then
            raise;
        end;
      end;
    finally
      L.Free;
    end;

    FreeAndNil(FList);
  finally
    FLoading := False;
  end;

  if FTerminate then
    Application.Terminate;
end;

initialization
  FNexus := nil;

finalization
  FreeAndNil(FNexus);
end.
