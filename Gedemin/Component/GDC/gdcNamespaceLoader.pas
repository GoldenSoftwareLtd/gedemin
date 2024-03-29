// ShlTanya, 10.02.2019

unit gdcNamespaceLoader;

interface

uses
  Classes, Windows, Messages, Forms, SysUtils, ContNrs, DB, IBDatabase, IBSQL,
  yaml_parser, gdcBaseInterface, gdcBase, gdcNamespace, JclStrHashMap, gd_KeyAssoc,
  gd_messages_const;

type
  EgdcNamespaceLoader = class(Exception);

  TgdcNamespaceLoaderNexus = class(TForm)
  private
    FList: TStringList;
    FAlwaysOverwrite: Boolean;
    FDontRemove: Boolean;
    FTerminate: Boolean;
    FLoading: Boolean;
    FIgnoreMissedFields: Boolean;
    FUnMethod: Boolean;

    procedure WMLoadNamespace(var Msg: TMessage);
      message WM_LOAD_NAMESPACE;

  public
    destructor Destroy; override;

    procedure LoadNamespace(AList: TStrings; const AnAlwaysOverwrite: Boolean;
      const ADontRemove: Boolean; const ATerminate: Boolean; const AnIgnoreMissedFields: Boolean;
      const AUnMethod: Boolean);

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
    FNSList: TgdKeyArray;
    FIgnoreMissedFields: Boolean;
    FUnMethod: Boolean;
    FNeedClearObjectCache: Boolean;

    procedure FlushStorages;
    procedure LoadAtObjectCache(const ANamespaceKey: TID);
    procedure LoadObject(AMapping: TYAMLMapping; const ANamespaceKey: TID;
      const AFileTimeStamp: TDateTime; const ASecondPass: Boolean);
    function CopyRecord(AnObj: TgdcBase; AMapping: TYAMLMapping; AnOverwriteFields: TStrings): Boolean;
    procedure CopyField(AField: TField; N: TyamlScalar; const SelfRUID: TRUID; const SelfID: TID);
    procedure CopySetAttributes(AnObj: TgdcBase; const AnObjID: TID; ASequence: TYAMLSequence);
    procedure OverwriteRUID(const AnID, AXID: TID; const ADBID: Integer);
    function Iterate_RemoveGDCObjects(AUserData: PUserData; const AStr: string; var APtr: PData): Boolean;
    function CacheObject(const AClassName: String; const ASubtype: String): TgdcBase;
    procedure UpdateUses(ASequence: TYAMLSequence; const ANamespaceKey: TID);
    procedure ProcessMetadata;
    function LoadParam(AParam: TIBXSQLVAR; const AFieldName: String;
      AMapping: TYAMLMapping; ATr: TIBTransaction): Boolean;
    function GetCandidateID(AnObj: TgdcBase; AFields: TYAMLMapping): TID;
    procedure RemoveObjects;
    procedure ReloginDatabase;
    procedure DelayedUpdate;
    procedure LoadOurCompanies;

  public
    constructor Create;
    destructor Destroy; override;

    class procedure LoadDelayed(AList: TStrings; const AnAlwaysOverwrite: Boolean;
      const ADontRemove: Boolean; const ATerminate: Boolean;
      const AnIgnoreMissedFields: Boolean; const AUnMethod: Boolean);
    class function LoadingDelayed: Boolean;

    procedure Load(AList: TStrings);

    property AlwaysOverwrite: Boolean read FAlwaysOverwrite write FAlwaysOverwrite;
    property DontRemove: Boolean read FDontRemove write FDontRemove;
    property Loading: Boolean read FLoading;
    property IgnoreMissedFields: Boolean read FIgnoreMissedFields write FIgnoreMissedFields;
    property UnMethod: Boolean read FUnMethod write FUnMethod;
  end;

  TAtRemoveRecord = class(TObject)
  public
    RUID: TRUID;
    ObjectClass: CgdcBase;
    ObjectSubType: String;
    ObjectName: String;
  end;

implementation

uses
  IBHeader, Storages, gd_security, at_classes, at_frmSQLProcess,
  at_sql_metadata, gd_common_functions, gdcNamespaceRecCmpController,
  gdcMetadata, gdcFunction, gd_directories_const, mtd_i_Base, evt_i_Base,
  gd_CmdLineParams_unit, at_dlgNamespaceRemoveList_unit, gdcContacts,
  {$IFDEF WITH_INDY}
  gdccConst, gdccGlobal, gdccClient_unit, gd_WebClientControl_unit,
  {$ENDIF}
  gd_AutoTaskThread;

var
  FNexus: TgdcNamespaceLoaderNexus;

type
  TAtObjectRecord = class(TObject)
  public
    ID: TID;
    ObjectName: String;
    ObjectClass: CgdcBase;
    ObjectSubType: String;
    Modified: TDateTime;
    CurrModified: TDateTime;
    AlwaysOverwrite: Boolean;
    DontRemove: Boolean;
    HeadObjectKey: TID;
    Loaded: Boolean;
  end;

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
  SelfRUID: TRUID;
  SelfID: TID;
begin
  Assert(AnObj <> nil);
  Assert(AMapping <> nil);
  Assert(AnObj.State in [dsEdit, dsInsert]);

  Result := False;

  SelfRUID := AnObj.GetRUID;
  SelfID := AnObj.ID;

  if AnObj.State = dsInsert then
  begin
    SName := AMapping.ReadString('name', 60, '');
    if SName = '' then
      SName := AMapping.ReadString('usr$name', 60, '');
    if SName = '' then
      S := '����������� ������: '
    else
      S := '����������� ������: ' + SName + ', ';
  end else
    S := '���������� ������: ' + AnObj.ObjectName + ', ';

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
          CopyField(F, SL.Objects[Idx] as TyamlScalar, SelfRUID, SelfID);
          SL.Delete(Idx);
        end else if (Pos('USR$', F.FieldName) = 1) and (not F.ReadOnly) and (not F.Calculated) then
          AddWarning('����������� � �����: ' + F.Origin);
      end;

      if not IgnoreMissedFields then
      begin
        for I := 0 to SL.Count - 1 do
        begin
          if not (SL.Objects[I] as TyamlScalar).IsNull then
          begin
            AddWarning('����������� � ����: ' + SL[I]);
            Result := True;
          end;
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
        CopyField(F, N as TyamlScalar, SelfRUID, SelfID)
      else if (Pos('USR$', F.FieldName) = 1) and (not F.ReadOnly) and (not F.Calculated) then
        AddWarning('����������� � �����: ' + F.Origin);
    end;
end;

procedure TgdcNamespaceLoader.CopyField(AField: TField; N: TyamlScalar;
  const SelfRUID: TRUID; const SelfID: TID);
var
  RelationName, FieldName: String;
  RefName: String;
  RefRUID: TRUID;
  RefID: TID;
  R: TatRelation;
  RF: TatRelationField;
  Flag: Boolean;
  TempS, ExtraCondition: String;
  q: TIBSQL;
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

  {$IFDEF ID64}
  if (AField.DataType in [ftLargeInt])
  {$ELSE}
  if (AField.DataType in [ftInteger])
  {$ENDIF}
    and (AField.Origin > '') and (N is TYAMLString) then
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

        if (RefRUID.XID = SelfRUID.XID) and (RefRUID.DBID = SelfRUID.DBID) then
          RefID := SelfID
        else
          RefID := gdcBaseManager.GetIDByRUID(RefRUID.XID, RefRUID.DBID, FTr);

        if RF.References.RelationName = 'GD_OURCOMPANY' then
        begin
          if FOurCompanies.IndexOf(RefID) = -1 then
          begin
            RefID := IBLogin.CompanyKey;
            AddText('������ ������� ����������� ����=' + RUIDToStr(RefRUID) +
              ' ����������� ������� �����������.');
          end;
        end;

        if RefID = -1 then
        begin
          AField.Clear;
          ExtraCondition := '  AND ' + FieldName + ' IS NULL';

          if AField.Required and (RF.ReferencesField <> nil) then
          begin
            q := TIBSQL.Create(nil);
            try
              q.Transaction := FTr;
              q.SQL.Text :=
                'SELECT FIRST 1 ' + RF.ReferencesField.FieldName +
                '  FROM ' + RF.ReferencesField.Relation.RelationName;
              q.ExecQuery;
              if not q.EOF then
              begin
                SetTID(AField, q.Fields[0]);
                ExtraCondition := '';
                AddWarning('��� ���� ' + FieldName + ' ������������ ��������� �������� ' + q.Fields[0].AsString);
              end;
            finally
              q.Free;
            end;
          end;

          FDelayedUpdate.Add('UPDATE ' + RelationName + ' SET ' +
            FieldName + ' = (SELECT id FROM gd_ruid WHERE xid = ' +
            TID2S(RefRUID.XID) + ' AND dbid = ' +
            IntToStr(RefRUID.DBID) + ') ' +
            'WHERE ' + R.PrimaryKey.ConstraintFields[0].FieldName + ' = ' +
            TID2S((AField.DataSet as TgdcBase).ID) +
            ExtraCondition);
          exit;
        end else
        begin
          SetTID(AField, RefID);
          exit;
        end;
      end;
    end;
  end;

  case AField.DataType of
    {$IFDEF ID64}
    ftLargeInt:
      try
        SetTID(AField, N.AsString);
      except
        on E: EConvertError do
        begin
          if not (N is TYAMLString) then
            raise;

          TgdcNamespace.ParseReferenceString(N.AsString, RefRUID, RefName);
          RefID := gdcBaseManager.GetIDByRUID(RefRUID.XID, RefRUID.DBID, FTr);
          if RefID = -1 then
            raise;

          SetTID(AField, RefID);
          AddWarning('���� ' + AField.Origin + ' �� �������� ������� ������.');
          AddWarning('�������� � �����: ' + N.AsString);
        end;
      end;
      ftInteger: AField.AsInteger := N.AsInteger;
    {$ELSE}
    ftInteger:
      try
        SetTID(AField, N.AsString);
      except
        on E: EConvertError do
        begin
          if not (N is TYAMLString) then
            raise;

          TgdcNamespace.ParseReferenceString(N.AsString, RefRUID, RefName);
          RefID := gdcBaseManager.GetIDByRUID(RefRUID.XID, RefRUID.DBID, FTr);
          if RefID = -1 then
            raise;

          SetTID(AField, RefID);
          AddWarning('���� ' + AField.Origin + ' �� �������� ������� ������.');
          AddWarning('�������� � �����: ' + N.AsString);
        end;
      end;
    ftLargeInt: (AField as TLargeIntField).AsLargeInt := N.AsInt64;
    {$ENDIF}
    ftSmallint: AField.AsInteger := N.AsInteger;
    ftCurrency, ftBCD: AField.AsCurrency := N.AsCurrency;
    ftTime, ftDateTime: AField.AsDateTime := N.AsDateTime;
    ftDate: AField.AsDateTime := N.AsDate;
    ftFloat: AField.AsFloat := N.AsFloat;
    ftBoolean: AField.AsBoolean := N.AsBoolean;
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
  FNSList := TgdKeyArray.Create;
end;

destructor TgdcNamespaceLoader.Destroy;
begin
  FNSList.Free;
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
{$IFDEF WITH_INDY}
const
  LoadNSWeight    = 3;
  RecalcMD5weight = 1;
{$ENDIF}
var
  I, J, K, T: Integer;
  Parser: TyamlParser;
  Mapping: TyamlMapping;
  Objects: TyamlSequence;
  NSID: TID;
  NSTimeStamp: TDateTime;
  NSRUID: TRUID;
  NSName, HashString, OldHashString: String;
  MS: TMemoryStream;
  q: TIBSQL;
  CharReplace: LongBool;
  OldUnMethodMacro: Boolean;
  NewNS: Boolean;
  {$IFDEF WITH_INDY}
  Progress: TgdccProgress;
  {$ENDIF}
begin
  Assert(not FLoading);
  Assert(AList <> nil);
  Assert(IBLogin <> nil);

  FNSList.Clear;
  FLoading := True;
  Global_LoadingNamespace := True;
  if gdAutoTaskThread <> nil then
    gdAutoTaskThread.Forbid;
  FRemoveList.Clear;
  LoadOurCompanies;

  OldUnMethodMacro := UnMethodMacro;
  UnMethodMacro := FUnMethod;
  {$IFDEF WITH_INDY}
  Progress := TgdccProgress.Create;
  {$ENDIF}
  try
    {$IFDEF WITH_INDY}
    Progress.StartWork('��������', '�������� ����������� ���� � ���� ������',
      AList.Count * (LoadNSWeight + RecalcMD5Weight));
    {$ENDIF}

    if UnMethodMacro then
      AddText('�� ����� �������� ����� ��������� ���������� ������.');

    if AList.Count > 1 then
    begin
      AddText('������� ��������:');
      for I := 0 to AList.Count - 1 do
        AddText(IntToStr(I) + ': ' + AList[I]);
    end;

    for I := 0 to AList.Count - 1 do
    begin
      {$IFDEF WITH_INDY}
      Progress.StartStep(ExtractFileName(AList[I]), LoadNSWeight);
      if Progress.Canceled then
      begin
        AddWarning('�������� �������������');
        break;
      end;
      {$ENDIF}

      if FLoadedNSList.IndexOf(AList[I]) > -1 then
        continue;

      FPrevPosted := nil;
      FNeedRelogin := False;
      //FNeedSyncTriggers := False;
      FMetadataCounter := 0;
      FlushStorages;

      AddText('=====================================');
      AddText('����: ' + AList[I]);

      Parser := TYAMLParser.Create;
      try
        Parser.Parse(AList[I], CharReplace);

        if (Parser.YAMLStream.Count = 0)
          or ((Parser.YAMLStream[0] as TyamlDocument).Count = 0)
          or (not ((Parser.YAMLStream[0] as TyamlDocument)[0] is TyamlMapping)) then
        begin
          raise EgdcNamespaceLoader.Create('Invalid YAML stream.');
        end;

        Mapping := (Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping;

        if Mapping.ReadString('StructureVersion') <> '1.0' then
          raise EgdcNamespaceLoader.Create('Unsupported YAML stream version.');

        if CharReplace then
          AddWarning('������ �������� ��� ����������� �� UTF-8.');

        NSRUID := StrToRUID(Mapping.ReadString('Properties\RUID'));
        NSName := Mapping.ReadString('Properties\Name');

        FTr.StartTransaction;
        try
          SetTID(FqFindNS.ParamByName('xid'), NSRUID.XID);
          FqFindNS.ParamByName('dbid').AsInteger := NSRUID.DBID;
          FqFindNS.ParamByName('name').AsString := AnsiUpperCase(NSName);
          FqFindNS.ExecQuery;

          FgdcNamespace.StreamXID := NSRUID.XID;
          FgdcNamespace.StreamDBID := NSRUID.DBID;

          if FqFindNS.EOF then
          begin
            FgdcNamespace.Open;
            FgdcNamespace.Insert;
            FgdcNamespace.FieldByName('name').AsString := Mapping.ReadString('Properties\Name', 255);
            FgdcNamespace.FieldByName('caption').AsString := Mapping.ReadString('Properties\Caption', 255);
            FgdcNamespace.FieldByName('version').AsString := Mapping.ReadString('Properties\Version', 20);
            FgdcNamespace.FieldByName('dbversion').AsString := Mapping.ReadString('Properties\DBversion', 20);
            FgdcNamespace.FieldByName('optional').AsInteger := Mapping.ReadInteger('Properties\Optional', 0);
            FgdcNamespace.FieldByName('internal').AsInteger := Mapping.ReadInteger('Properties\Internal', 1);
            FgdcNamespace.FieldByName('settingruid').AsString := Mapping.ReadString('Properties\SettingRUID', SizeOf(TRUIDString));
            FgdcNamespace.FieldByName('comment').AsString := Mapping.ReadString('Properties\Comment');
            FgdcNamespace.FieldByName('md5').AsString := Mapping.ReadString('Properties\MD5');
            FgdcNamespace.FieldByName('filetimestamp').AsDateTime := gd_common_functions.GetFileLastWrite(AList[I]);
            if FgdcNamespace.FieldByName('filetimestamp').AsDateTime > Now then
              FgdcNamespace.FieldByName('filetimestamp').AsDateTime := Now;
            FgdcNamespace.FieldByName('filename').AsString := System.Copy(AList[I], 1, 255);
            (FgdcNamespace.FieldByName('filedata') as TBlobField).LoadFromFile(AList[I]);
            FgdcNamespace.Post;
            AddText('������� ����� ������������ ����: ' + NSName);
            NewNS := True;
          end else
          begin
            FgdcNamespace.ID := GetTID(FqFindNS.FieldByName('id'));
            FgdcNamespace.Open;
            if FgdcNamespace.EOF then
              raise EgdcNamespaceLoader.Create('Internal consistency check');
            if FqFindNS.FieldByName('ByName').AsInteger <> 0 then
              AddText('������������ ���� ������� �� ������������: ' + NSName)
            else
              AddText('������������ ���� ������� �� ����: ' + NSName);
            NewNS := False;
          end;

          NSID := FgdcNamespace.ID;
          FNSList.Add(NSID, True);
          NSTimeStamp := FgdcNamespace.FieldByName('filetimestamp').AsDateTime;

          OverwriteRUID(NSID, NSRUID.XID, NSRUID.DBID);

          TgdcNamespace.UpdateCurrModified(FTr, NSID);
          LoadAtObjectCache(NSID);

          SetTID(FqClearAtObject.ParamByName('nk'), NSID);
          FqClearAtObject.ExecQuery;

          if Mapping.FindByName('Objects') is TYAMLSequence then
          begin
            Objects := Mapping.FindByName('Objects') as TYAMLSequence;

            for J := 0 to Objects.Count - 1 do
            begin
              {$IFDEF WITH_INDY}
              if Progress.Canceled then
                break;
              {$ENDIF}

              if not (Objects[J] is TYAMLMapping) then
                raise EgdcNamespaceLoader.Create('Invalid YAML stream.');
              LoadObject(Objects[J] as TYAMLMapping, NSID, NSTimeStamp, False);
            end;

            if FMetadataCounter > 0 then
              ProcessMetadata;
          end;

          FAtObjectRecordCache.IterateMethod(@NSID, Iterate_RemoveGDCObjects);
          
          if Mapping.FindByName('Uses') is TYAMLSequence then
            UpdateUses(Mapping.FindByName('Uses') as TYAMLSequence, NSID);

          if FgdcNamespaceObject.Active then
            FgdcNamespaceObject.Close;

          if FgdcNamespace.Active then
            FgdcNamespace.Close;

          if not NewNS then
          begin
            FgdcNamespace.ID := NSID;
            FgdcNamespace.Open;
            FgdcNamespace.Edit;
            FgdcNamespace.FieldByName('name').AsString := Mapping.ReadString('Properties\Name', 255);
            FgdcNamespace.FieldByName('caption').AsString := Mapping.ReadString('Properties\Caption', 255);
            FgdcNamespace.FieldByName('version').AsString := Mapping.ReadString('Properties\Version', 20);
            FgdcNamespace.FieldByName('dbversion').AsString := Mapping.ReadString('Properties\DBversion', 20);
            FgdcNamespace.FieldByName('optional').AsInteger := Mapping.ReadInteger('Properties\Optional', 0);
            FgdcNamespace.FieldByName('internal').AsInteger := Mapping.ReadInteger('Properties\Internal', 1);
            FgdcNamespace.FieldByName('settingruid').AsString := Mapping.ReadString('Properties\SettingRUID', SizeOf(TRUIDString));
            FgdcNamespace.FieldByName('comment').AsString := Mapping.ReadString('Properties\Comment');
            FgdcNamespace.FieldByName('md5').AsString := Mapping.ReadString('Properties\MD5');
            FgdcNamespace.FieldByName('filetimestamp').AsDateTime := gd_common_functions.GetFileLastWrite(AList[I]);
            if FgdcNamespace.FieldByName('filetimestamp').AsDateTime > Now then
              FgdcNamespace.FieldByName('filetimestamp').AsDateTime := Now;
            FgdcNamespace.FieldByName('filename').AsString := System.Copy(AList[I], 1, 255);
            (FgdcNamespace.FieldByName('filedata') as TBlobField).LoadFromFile(AList[I]);
            FgdcNamespace.Post;
            FgdcNamespace.Close;
          end;

          FTr.Commit;

          FLoadedNSList.Add(AList[I]);
        finally
          if FTr.InTransaction then
          begin
            FTr.Rollback;
            gdcBase.ClearCacheList;
          end;
          FAtObjectRecordCache.Iterate(nil, Iterate_FreeObjects);
          FAtObjectRecordCache.Clear;
        end;
      finally
        Parser.Free;
      end;

      DelayedUpdate;

      if FNeedRelogin then
        ReloginDatabase;

      AddText('��������� ��������: ' + NSName);
    end;

    if FSecondPassList.Count > 0 then
    begin
      AddText('��������� �������� ��������:');

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
      AddText('�������� ��������� �������� ��������.');
    end;

    if (FRemoveList.Count > 0) and (not FDontRemove) then
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

    FTr.StartTransaction;
    q := TIBSQL.Create(nil);
    try
      if gdcBaseManager.HasDelayedRUIDChanges then
      begin
        AddText('������ ������ RUID � ������� ������-�������...');
        gdcBaseManager.ProcessDelayedRUIDChanges(FTr);
        AddText('�������� ������ RUID � ������� ������-�������');
      end;  

      q.Transaction := FTr;
      q.SQL.Text := 'UPDATE at_namespace SET changed = :changed, md5 = :md5 WHERE id = :id';

      AddText('����� �������� ����������� ���� MD5...');
      for T := 0 to FNSList.Count - 1 do
      begin
        HashString := '';
        OldHashString := '';
        FgdcNamespace.ID := FNSList.Keys[T];
        FgdcNamespace.Open;
        if not FgdcNamespace.EOF then
        begin
          {$IFDEF WITH_INDY}
          AddText('���������������: ' + FgdcNamespace.ObjectName);
          Progress.StartStep('���������������: ' + FgdcNamespace.ObjectName, RecalcMD5Weight);
          if Progress.Canceled then
          begin
            AddWarning('�������� �������������');
            break;
          end;
          {$ENDIF}

          OldHashString := FgdcNamespace.FieldbyName('MD5').AsString;
          MS := TMemoryStream.Create;
          try
            FgdcNamespace.SaveNamespaceToStream(MS, HashString, IDNO, False, False);
          finally
            MS.Free;
          end;
        end;
        FgdcNamespace.Close;

        if HashString > '' then
        begin
          if HashString = OldHashString then
            q.ParamByName('changed').AsInteger := 0
          else
            q.ParamByName('changed').AsInteger := 1;
          q.ParamByName('md5').AsString := HashString;
          SetTID(q.ParamByName('id'), FNSList.Keys[T]);
          q.ExecQuery;
        end;
      end;
      AddText('������� �������� ����������� ���� MD5.');
    finally
      q.Free;
      FTr.Commit;
    end;
  finally
    UnMethodMacro := OldUnMethodMacro;
    Global_LoadingNamespace := False;
    {$IFDEF WITH_INDY}
    Progress.EndWork('');
    Progress.Free;
    {$ENDIF}
  end;

  FLoading := False;

  AddText('��������� �������� ������ ��.');

  if gdAutoTaskThread <> nil then
  begin
    gdAutoTaskThread.Activate;
    gdAutoTaskThread.ReloadTaskList;
  end else
    ReloginDatabase;

  Assert(FAtObjectRecordCache.Count = 0);
  Assert(FRemoveList.Count = 0);
  Assert(FSecondPassList.Count = 0);
  Assert(FDelayedUpdate.Count = 0);
  Assert(not FNeedRelogin);
end;

procedure TgdcNamespaceLoader.LoadAtObjectCache(const ANamespaceKey: TID);
var
  AR: TAtObjectRecord;
  ObjectRUID: String;
  C: TPersistentClass;
begin
  SetTID(FqLoadAtObject.ParamByName('nk'), ANamespaceKey);
  FqLoadAtObject.ExecQuery;
  try
    while not FqLoadAtObject.EOF do
    begin
      ObjectRUID := RUIDToStr(RUID(GetTID(FqLoadAtObject.FieldByName('xid')),
        FqLoadAtObject.FieldByName('dbid').AsInteger));

      Assert(not FAtObjectRecordCache.Has(ObjectRUID));

      C := GetClass(FqLoadAtObject.FieldByName('objectclass').AsString);
      if (C <> nil) and C.InheritsFrom(TgdcBase) then
      begin
        AR := TatObjectRecord.Create;
        AR.ID := GetTID(FqLoadAtObject.FieldByName('id'));
        AR.ObjectName := FqLoadAtObject.FieldByName('objectname').AsString;
        AR.ObjectClass := CgdcBase(C);
        AR.ObjectSubType := FqLoadAtObject.FieldByName('subtype').AsString;
        AR.HeadObjectKey := GetTID(FqLoadAtObject.FieldByName('headobjectkey'));
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
  NeedSecondPass, PartialOverwrite: Boolean;
  TempMapping: TyamlMapping;
  ObjInserted: Boolean;
  R: TatRelation;
begin
  ObjPosted := False;
  ObjPreserved := False;
  CrossTableCreated := False;
  NeedSecondPass := False;
  PartialOverwrite := False;
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
        (Fields.ReadDateTime('EDITIONDATE', 0) > AtObjectRecord.Modified))
    or ((not (tiEditionDate in Obj.GetTableInfos(Obj.SubType)))
         and
        (AFileTimeStamp > AtObjectRecord.Modified)) then
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
          '��� ������� �������� ������������ ������� ���� ' + Obj.GetDisplayName(Obj.SubType) + #13#10 +
          '���� = ' + ObjRUIDString + ' � ���� ������ ��������� ������ � �� = ' + TID2S(CandidateID) + '.'#13#10#13#10 +
          '������������ ������ ���������� ��������������� ��� ���������� ���������������.';
        if not gd_CmdLineParams.QuietMode then
        begin
          if MessageBox(0, PChar(SWarn), '��������', MB_OKCANCEL or MB_ICONEXCLAMATION or MB_TASKMODAL) = IDOK then
            Obj.EditDialog
          else begin
            AddMistake('������� ������� �������������');
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
        AddText('����������� ������ ' + Obj.GetDisplayName(Obj.SubType) +
          ' �� = ' + TID2S(RUIDID) + '. ����������� � ��. ����� ��������.');
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
        AddText('������ ������ �� �������������� �����: ' + Obj.ObjectName +
          ' (' + Obj.GetDisplayName(Obj.SubType) + '), RUID � �����: ' + ObjRUIDString +
          ', RUID � ��: ' + RUIDToStr(Obj.GetRUID));
        if RUIDID > -1 then
        begin
          gdcBaseManager.DeleteRUIDByID(RUIDID, FTr);
          AddWarning('���� ' + ObjRUIDString + ' ������������� � �� ' +
            TID2S(RUIDID) + ' �� �� ' +
            TID2S(CandidateID));
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
        if Obj is TgdcStoredProc then
        begin
          TgdcStoredProc(Obj).PrepareToSaveToStream(True);
          TgdcStoredProc(Obj).PrepareToSaveToStream(False);
        end;

        if Compare(nil, Obj, AMapping) then
        begin
          PartialOverwrite := InequalFields.Count <> OverwriteFields.Count;
          NeedSecondPass := CopyRecord(Obj, Fields, OverwriteFields);
        end else
        begin
          ObjPreserved := True;

          if CancelLoad then
          begin
            AddWarning('������� �������� ������� �������������.');
            Abort;
          end
          else if InequalFields.Count > 0 then
            AddText('������ � ���� �� �������� ������� �� �����: ' + Obj.ObjectName);
        end;
      finally
        Free;
      end;
    end else
      NeedSecondPass := CopyRecord(Obj, Fields, nil);

    if Obj.State = dsInsert then
    begin
      ObjInserted := True;
      S := '������ ������: ';
    end else
    begin
      ObjInserted := False;
      S := '������� ������: ';
    end;

    S := S + Obj.ObjectName + ' (' + Obj.ClassName + Obj.SubType + ', ' + TID2S(Obj.ID) + ')';

    Obj.Post;
    if (Obj.GetRUID.XID <> ObjRUID.XID) or (Obj.GetRUID.DBID <> ObjRUID.DBID) then
      AddMistake('��������� ���� ������� ' + RUIDToStr(ObjRUID) + ' -> ' + RUIDToStr(Obj.GetRUID));
    AddText(S);
    ObjPosted := True;
    ObjID := Obj.ID;

    if Obj is TgdcOurCompany then
      FOurCompanies.Add(Obj.ID, True);

    if ObjID >= cstUserIDStart then
      OverwriteRUID(ObjID, ObjRUID.XID, ObjRUID.DBID);

    ObjName := Obj.ObjectName;
    if ObjName = '' then
      ObjName := Obj.GetDisplayName(Obj.SubType);

    if Obj is TgdcRelationField then
    begin
      if Obj.FieldByName('crosstable').AsString > '' then
        CrossTableCreated := True
      else
      if ObjInserted then
      begin
        R := atDatabase.Relations.ByRelationName(Obj.FieldByName('relationname').AsString);
        if (R <> nil)
          and (R.PrimaryKey <> nil)
          and (R.PrimaryKey.ConstraintFields <> nil)
          and (R.PrimaryKey.ConstraintFields.Count = 2)
          and (R.PrimaryKey.ConstraintFields[0].References <> nil)
          and (R.PrimaryKey.ConstraintFields[1].References <> nil) then
        begin
          FNeedClearObjectCache := True;
        end;
      end;
    end;

    Obj.Close;

    if AMapping.FindByName('Set') is TYAMLSequence then
      CopySetAttributes(Obj, ObjID, AMapping.FindByName('Set') as TYAMLSequence);

    if NeedSecondPass then
    begin
      if ASecondPass then
      begin
        if not IgnoreMissedFields then
          AddWarning('����(�) �����������(��) � �� ����� ��������� ��������!');
      end else
      begin
        if Obj is TgdcMetaBase then
          AddMistake('������ ���������� ' + Obj.ObjectName +
            '(' + Obj.ClassName + ') �� ����� ���� �������� ��������!')
        else begin
          TempMapping := TyamlMapping.Create;
          TempMapping.Assign(AMapping);
          FSecondPassList.Add(TempMapping);
        end;
      end;
    end;
  end else
  begin
    if (AtObjectRecord <> nil)
      and
      (
        (
          (tiEditionDate in Obj.GetTableInfos(Obj.SubType))
           and
          (Fields.ReadDateTime('EDITIONDATE', 0) <= AtObjectRecord.Modified)
        )
        or
        (
          (not (tiEditionDate in Obj.GetTableInfos(Obj.SubType)))
           and
          (AFileTimeStamp <= AtObjectRecord.Modified)
        )
      ) then
    begin
      AddText('������ "' + AtObjectRecord.ObjectName +
        '" (' + AtObjectRecord.ObjectClass.ClassName + AtObjectRecord.ObjectSubType + ', ' +
        ObjRUIDSTring + '), ' +
        '�� ����� �������. ���� � ����� <= ���� � ������� ��������� ������� � ��.');
    end;
  end;

  if not ASecondPass then
  begin
    if not FgdcNamespaceObject.Active then
      FgdcNamespaceObject.Open;
    FgdcNamespaceObject.Insert;
    SetTID(FgdcNamespaceObject.FieldByName('namespacekey'), ANamespaceKey);
    FgdcNamespaceObject.FieldByName('objectname').AsString := ObjName;
    FgdcNamespaceObject.FieldByName('objectclass').AsString := AMapping.ReadString('Properties\Class');
    FgdcNamespaceObject.FieldByName('subtype').AsString := AMapping.ReadString('Properties\Subtype');
    SetTID(FgdcNamespaceObject.FieldByName('xid'), ObjRUID.XID);
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
        if PartialOverwrite then
          FgdcNamespaceObject.FieldByName('modified').AsDateTime := AtObjectRecord.Modified
        else
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

  HeadObjectRUID := StrToRUID(AMapping.ReadString('Properties\HeadObject', SizeOf(TRUIDString), ''));
  if HeadObjectRUID.XID > -1 then
  begin
    FDelayedUpdate.Add(
      'UPDATE at_object SET headobjectkey = ' +
      '  (SELECT id FROM at_object WHERE namespacekey = ' + TID2S(ANamespaceKey) +
      '     AND xid = ' + TID2S(HeadObjectRUID.XID) +
      '     AND dbid = ' + IntToStr(HeadObjectRUID.DBID) +
      '  ) ' +
      'WHERE id = ' + TID2S(FgdcNamespaceObject.ID)
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

procedure TgdcNamespaceLoader.OverwriteRUID(const AnID, AXID: TID; const ADBID: Integer);
var
  AtObjectRecord: TAtObjectRecord;
begin
  Assert(
    ((AnID >= cstUserIDStart) and (AXID >= cstUserIDSTart))
    or
    ((AnID < cstUserIDStart) and (ADBID = cstEtalonDBID) and (AnID = AXID))
  );

  SetTID(FqFindRUID.ParamByName('id'), AnID);
  FqFindRUID.ExecQuery;
  try
    if FqFindRUID.EOF then
    begin
      SetTID(FqInsertNSRUID.ParamByName('id'), AnID);
      SetTID(FqInsertNSRUID.ParamByName('xid'), AXID);
      FqInsertNSRUID.ParamByName('dbid').AsInteger := ADBID;
      SetTID(FqInsertNSRUID.ParamByName('editorkey'), IBLogin.ContactKey);
      FqInsertNSRUID.ExecQuery;
    end
    else if (GetTID(FqFindRUID.FieldByName('xid')) <> AXID)
      or (FqFindRUID.FieldByName('dbid').AsInteger <> ADBID) then
    begin
      gdcBaseManager.ChangeRUID(GetTID(FqFindRUID.FieldByName('xid')),
        FqFindRUID.FieldByName('dbid').AsInteger, AXID, ADBID, FTr, False);

      AddWarning('��������� ���� ������� ' +
        RUIDToStr(GetTID(FqFindRUID.FieldByName('xid')), FqFindRUID.FieldByName('dbid').AsInteger) +
        ' -> ' +
        RUIDToStr(AXID, ADBID));
        
      if FAtObjectRecordCache.Find(RUIDToStr(GetTID(FqFindRUID.FieldByName('xid')),
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
    RR.ObjectName := AR.ObjectName;
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
  if FNeedClearObjectCache then
  begin
    FgdcObjectCache.Iterate(nil, Iterate_FreeObjects);
    FgdcObjectCache.Clear;
    FNeedClearObjectCache := False;
  end;

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
            '=' + TID2S(AnObjID);
          q.ExecQuery;

          q.SQL.Text := AnObj.SetAttributes[J].InsertSQL;
          AddText(q.SQL.Text);
          for K := 0 to Items.Count - 1 do
          begin
            if not (Items[K] is TYAMLMapping) then
              break;

            for T := 0 to R.RelationFields.Count - 1 do
            begin
              FieldName := R.RelationFields[T].FieldName;
              Param := q.ParamByName(FieldName);

              if (R.PrimaryKey.ConstraintFields[0] = R.RelationFields[T]) then
                SetTID(Param, AnObjID)
              else
                LoadParam(Param, FieldName, Items[K] as TYAMLMapping, AnObj.Transaction);

            end;

            try
              q.ExecQuery;
              SetItemAdded := True;
            except
              on E: Exception do
              begin
                AddMistake('������ ��� ���������� �������� ���������: ' + E.Message + #13#10 +
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
      // �������� ������, ����� ���������� �������� ����������
      // ���������� ������������� �����-�������
      KF := AnObj.GetKeyField(AnObj.SubType);
      q.SQL.Text :=
        'UPDATE ' + AnObj.GetListTable(AnObj.SubType) +
        '  SET ' + KF + ' = :id' +
        '  WHERE ' + KF + ' = :id';
      SetTID(q.ParamByName('id'), AnObjID);
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
    SetTID(q.ParamByName('nk'), ANamespaceKey);
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
      SetTID(q.ParamByName('xid'), NSRUID.XID);
      q.ParamByName('dbid').AsInteger := NSRUID.DBID;
      q.ExecQuery;

      if q.EOF then
      begin
        q.Close;
        q.SQL.Text :=
          'SELECT n.id FROM at_namespace n ' +
          'WHERE UPPER(n.name) = :n';
        q.ParamByName('n').AsString := AnsiUpperCase(NSName);
        q.ExecQuery;
      end;

      if not q.EOF then
      begin
        NSID := GetTID(q.FieldByName('id'));
        q.Close;
      end else
      begin
        NSID := gdcBaseManager.GetNextID;

        q.Close;
        q.SQL.Text :=
          'INSERT INTO at_namespace (id, name) ' +
          'VALUES (:id, :name)';
        SetTID(q.ParamByName('id'), NSID);
        q.ParamByName('name').AsString := NSName;
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO gd_ruid (id, xid, dbid, modified, editorkey) ' +
          'VALUES (:id, :xid, :dbid, CURRENT_TIMESTAMP, :editorkey) ' +
          'MATCHING (xid, dbid)';
        SetTID(q.ParamByName('id'), NSID);
        SetTID(q.ParamByName('xid'), NSRUID.XID);
        q.ParamByName('dbid').AsInteger := NSRUID.DBID;
        SetTID(q.ParamByName('editorkey'), IBLogin.ContactKey);
        q.ExecQuery;
      end;

      q.SQL.Text :=
        'INSERT INTO at_namespace_link (namespacekey, useskey) ' +
        'VALUES (:namespacekey, :useskey)';
      SetTID(q.ParamByName('namespacekey'), ANamespaceKey);
      SetTID(q.ParamByName('useskey'), NSID);
      try
        q.ExecQuery;
      except
        on E: Exception do
          AddMistake(E.Message);
      end;
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

  AddText('������ ����������...');

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
  //FNeedSyncTriggers := True;
  FNeedRelogin := True;
end;

class procedure TgdcNamespaceLoader.LoadDelayed(AList: TStrings;
  const AnAlwaysOverwrite, ADontRemove, ATerminate, AnIgnoreMissedFields,
  AUnMethod: Boolean);
begin
  if FNexus = nil then
    FNexus := TgdcNamespaceLoaderNexus.CreateNew(nil);
  FNexus.LoadNamespace(AList, AnAlwaysOverwrite, ADontRemove, ATerminate,
    AnIgnoreMissedFields, AUnMethod);
end;

function TgdcNamespaceLoader.LoadParam(AParam: TIBXSQLVAR; const AFieldName: String;
  AMapping: TYAMLMapping; ATr: TIBTransaction): Boolean;
var
  V: TYAMLScalar;
  RefRUID, RefName: String;
begin
  Result := True;

  if (not (AMapping.FindByName(AFieldName) is TYAMLScalar)) or AMapping.ReadNull(AFieldName) then
  begin
    AParam.Clear;
    exit;
  end;

  V := AMapping.FindByName(AFieldName) as TYAMLScalar;

  case AParam.SQLType of
  {$IFDEF ID64}
  SQL_INT64:
    if (V is TYAMLString) and ParseReferenceString(V.AsString, RefRUID, RefName) then
    begin
      SetTID(AParam, gdcBaseManager.GetIDByRUIDString(RefRUID, ATr));
      if GetTID(AParam) = -1 then
      begin
        AParam.Clear;
        AddWarning('�� ������ ������ ��� ��������� ' + AParam.Name + ', "' + V.AsString + '"');
        AddWarning('��������, ������� �������� ������� �������� � ��.');
        Result := False;
      end;
    end else
    if AParam.AsXSQLVAR.sqlscale = 0 then
      AParam.AsInt64 := V.AsInt64
    else
      AParam.AsCurrency := V.AsCurrency;
  SQL_LONG, SQL_SHORT:
    if AParam.AsXSQLVAR.sqlscale = 0 then
      AParam.AsInteger := V.AsInteger
    else
      AParam.AsCurrency := V.AsCurrency;
  {$ELSE}
  SQL_LONG, SQL_SHORT:
    if (V is TYAMLString) and ParseReferenceString(V.AsString, RefRUID, RefName) then
    begin
      SetTID(AParam, gdcBaseManager.GetIDByRUIDString(RefRUID, ATr));
      if GetTID(AParam) = -1 then
      begin
        AParam.Clear;
        AddWarning('�� ������ ������ ��� ��������� ' + AParam.Name + ', "' + V.AsString + '"');
        AddWarning('��������, ������� �������� ������� �������� � ��.');
        Result := False;
      end;
    end else
    if AParam.AsXSQLVAR.sqlscale = 0 then
      AParam.AsInteger := V.AsInteger
    else
      AParam.AsCurrency := V.AsCurrency;
  SQL_INT64:
    if AParam.AsXSQLVAR.sqlscale = 0 then
      AParam.AsInt64 := V.AsInt64
    else
      AParam.AsCurrency := V.AsCurrency;
  {$ENDIF}
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
  CheckStmt: String;
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
        if not LoadParam(FqCheckTheSame.Params[I], FqCheckTheSame.Params[I].Name,
          AFields, AnObj.Transaction) then
        begin
          AddWarning('���������� ����� ������� �� �������������� �����: ' + CheckStmt);
          exit;
        end;

      FqCheckTheSame.ExecQuery;

      if not FqCheckTheSame.EOF then
      begin
        Result := GetTID(FqCheckTheSame.Fields[0]);

        for I := 0 to FqCheckTheSame.Params.Count - 1 do
        begin
          if Pos(FqCheckTheSame.Params[I].Name + ': ', CheckStmt) > 0 then
            continue;

          CheckStmt := CheckStmt + #13#10 + FqCheckTheSame.Params[I].Name + ': ';
          if FqCheckTheSame.Params[I].IsNull then
            CheckStmt := CheckStmt + 'NULL'
          else
            CheckStmt := CheckStmt + FqCheckTheSame.Params[I].AsString;
        end;

        FqCheckTheSame.Next;
        if FqCheckTheSame.EOF then
          AddText('����� ������� �� �������������� �����:'#13#10 + CheckStmt)
        else begin
          CheckStmt :=
            '����� ������� �� �������������� �����.'#13#10 +
            '������ ������ ������������� ����� ������:'#13#10 + CheckStmt;
          AddWarning(CheckStmt);
          Result := -1;
        end;
      end;
    finally
      FqCheckTheSame.Close;
    end;
  except
    on E: Exception do
    begin
      AddWarning('������ � �������� ������ �� �������������� �����: '#13#10 +
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

    SetTID(FqFindAtObject.ParamByName('xid'), RR.RUID.XID);
    FqFindAtObject.ParamByName('dbid').AsInteger := RR.RUID.DBID;
    FqFindAtObject.ExecQuery;

    if not FqFindAtObject.EOF then
      FRemoveList.Delete(I);

    FqFindAtObject.Close;
  end;

  if FRemoveList.Count > 0 then
  begin
    AddText('���������� �������� ��� ��������: ' + IntToStr(FRemoveList.Count));
    if (not gd_CmdLineParams.QuietMode) and (gd_CmdLineParams.LoadsettingFileName = '') then
    begin
      with Tat_dlgNamespaceRemoveList.Create(nil) do
      try
        RemoveList := FRemoveList;
        DoDialog;
      finally
        Free;                                                           
      end;
    end;  
  end;

  for I := FRemoveList.Count - 1 downto 0 do
  begin
    RR := FRemoveList[I] as TatRemoveRecord;
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
          AddText('������ ������: ' + ObjectName);
        except
          on E: Exception do
          begin
            AddWarning('������ �� ����� ���� ������: ' +
              ObjectName + #13#10 + E.Message);
          end;
        end;
        if Obj is TgdcMetaBase then
          Inc(FMetadataCounter);
      end;
    end;
    Obj.Close;
  end;

  FRemoveList.Clear;
end;

procedure TgdcNamespaceLoader.ReloginDatabase;
begin
  {if FNeedSyncTriggers then
  begin
    AddText('������������� ��������� � ��������...');
    atDatabase.SyncIndicesAndTriggers(FTr);
    FNeedSyncTriggers := False;
  end;}
  AddText('��������������� � ���� ������...');
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
    AddText('���������� ���������� �������:');
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
      FOurCompanies.Add(GetTID(q.Fields[0]));
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
  const AnAlwaysOverwrite, ADontRemove, ATerminate, AnIgnoreMissedFields,
  AUnMethod: Boolean);
begin
  if FLoading then
    raise EgdcNamespaceLoader.Create('Namespace is loading.');
  if FList = nil then
    FList := TStringList.Create;
  FList.Assign(AList);
  FAlwaysOverwrite := AnAlwaysOverwrite;
  FDontRemove := ADontRemove;
  FTerminate := ATerminate;
  FIgnoreMissedFields := AnIgnoreMissedFields;
  FUnMethod := AUnMethod;
  PostMessage(Handle, WM_LOAD_NAMESPACE, 0, 0);
end;

procedure TgdcNamespaceLoaderNexus.WMLoadNamespace(var Msg: TMessage);
var
  L: TgdcNamespaceLoader;
  {$IFDEF WITH_INDY}
  SL: TStringList;
  T: TDateTime;
  {$ENDIF}
begin
  Assert(not FLoading);
  Assert(FList <> nil);

  {$IFDEF WITH_INDY}
  T := Now;
  {$ENDIF}
  FLoading := True;
  try
    L := TgdcNamespaceLoader.Create;
    try
      L.AlwaysOverwrite := FAlwaysOverwrite;
      L.DontRemove := FDontRemove;
      L.IgnoreMissedFields := FIgnoreMissedFields;
      L.UnMethod := FUnMethod;
      try
        L.Load(FList);
      except
        on E: Exception do
        begin
          if not (E is EAbort) then
            AddMistake(E.Message);
          if not gd_CmdLineParams.QuietMode then
            raise
          else
            ExitCode := 1;
        end;
      end;
    finally
      L.Free;
    end;

    FreeAndNil(FList);
  finally
    FLoading := False;

    {$IFDEF WITH_INDY}
    if (gd_CmdLineParams.SendLogEmail > '')
      and FileExists(gd_CmdLineParams.LoadSettingFileName)
      and (gdWebClientControl <> nil)
      and gdccClient.Connected then
    begin
      gdccClient.AddLogRecord('ns', 'Request log to send via email...');
      gdccClient.SendCommand(gdcc_cmd_GetLog, gdcc_lt_Warning or gdcc_lt_Error, gdcc_cmd_LogTransfered);
      if gdccClient.WaitForCommand(gdcc_cmd_LogTransfered, 4000) then
      begin
        SL := TStringList.Create;
        try
          SL.CommaText := gdccClient.LogStr;
          gdccClient.AddLogRecord('ns', 'Log received. ' + IntToStr(SL.Count) + ' lines');

          if SL.Count = 0 then
            gdWebClientControl.SendEmail(-1, gd_CmdLineParams.SendLogEmail,
              '������� ��������� �� ' + ExtractFileName(gd_CmdLineParams.LoadSettingFileName),
              '����� ��������: ' + FormatDateTime('hh:nn:ss', Now - T), '', False, False, True)
          else
            gdWebClientControl.SendEmail(-1, gd_CmdLineParams.SendLogEmail,
              '������ ��� �������������� � �������� �������� �� ' + ExtractFileName(gd_CmdLineParams.LoadSettingFileName),
              SL.Text, '', False, False, True);
        finally
          SL.Free;
        end;
      end;
    end;
    {$ENDIF}
  end;

  if FTerminate then
    Application.Terminate;
end;

initialization
  FNexus := nil;

finalization
  FreeAndNil(FNexus);
end.
