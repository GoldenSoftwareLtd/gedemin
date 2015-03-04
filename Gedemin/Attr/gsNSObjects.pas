
unit gsNSObjects;

interface

uses
  Classes, IBDatabase, ContNrs, DBGrids, gdcBaseInterface, gdcBase, gd_KeyAssoc,
  at_dlgToNamespaceInterface;

type
  TgsNSList = class;
  TgsNSObjects = class;

  TgsNSObject = class(TObject)
  private
    FID: TID;
    FObjectName: String;
    FObjectClass: String;
    FSubType: String;
    FRUID: TRUID;
    FEditionDate: TDateTime;
    FChecked: Boolean;
    FLinked: TgsNSList;
    FCompound: TgsNSList;
    FNamespace: TgdKeyArray;
    FNSObjects: TgsNSObjects;

  public
    constructor Create(ANSObjects: TgsNSObjects);
    destructor Destroy; override;

    procedure Add(AnObject: TgdcBase);
    function FindObject(const AnID: TID): TgsNSObject;
    procedure GetNamespaces(AKeyArray: TgdKeyArray);
    procedure InitView(I: Iat_dlgToNamespace);

    property ID: TID read FID;
    property ObjectName: String read FObjectName;
    property ObjectClass: String read FObjectClass;
    property SubType: String read FSubType;
    property RUID: TRUID read FRUID;
    property EditionDate: TDateTime read FEditionDate;
    property Checked: Boolean read FChecked write FChecked;
    property Linked: TgsNSList read FLinked;
    property Compound: TgsNSList read FCompound;
    property Namespace: TgdKeyArray read FNamespace;
  end;

  TgsNSList = class(TObject)
  private
    FList: TObjectList;

    function GetObjectCount: Integer;
    function GetObjects(Index: Integer): TgsNSObject;

  public
    constructor Create;
    destructor Destroy; override;

    function Add(AnObject: TgdcBase; ANSObjects: TgsNSObjects): Integer;
    function FindObject(const AnID: TID): TgsNSObject;
    procedure GetNamespaces(AKeyArray: TgdKeyArray);
    procedure InitView(I: Iat_dlgToNamespace);

    property ObjectCount: Integer read GetObjectCount;
    property Objects[Index: Integer]: TgsNSObject read GetObjects;
  end;

  TgsNSObjects = class(TObject)
  private
    FList: TgsNSList;
    FTransaction: TIBTransaction;
    FSessionID: Integer;

    function GetTransaction: TIBTransaction;

  protected
    function GetNextSessionID: Integer;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Setup(AnObject: TgdcBase; ABL: TBookmarkList);
    function FindObject(const AnID: TID): TgsNSObject;
    function GetNamespaceCount: Integer;
    procedure InitView(I: Iat_dlgToNamespace);

    property NSList: TgsNSList read FList;
    property Transaction: TIBTransaction read GetTransaction;
  end;

implementation

uses
  IBSQL, gdcMetaData, flt_sql_parser;

{ TgsNSObjects }

constructor TgsNSObjects.Create;
begin
  inherited Create;
  FList := TgsNSList.Create;
  FTransaction := TIBTransaction.Create(nil);
  FTransaction.DefaultDatabase := gdcBaseManager.Database;
end;

destructor TgsNSObjects.Destroy;
begin
  FTransaction.Free;
  FList.Free;
  inherited;
end;

function TgsNSObjects.FindObject(const AnID: TID): TgsNSObject;
begin
  Result := FList.FindObject(AnID);
end;

function TgsNSObjects.GetTransaction: TIBTransaction;
begin
  if not FTransaction.InTransaction then
    FTransaction.StartTransaction;
  Result := FTransaction;  
end;

function TgsNSObjects.GetNextSessionID: Integer;
begin
  Inc(FSessionID);
  Result := FSessionID;
end;

procedure TgsNSObjects.Setup(AnObject: TgdcBase; ABL: TBookmarkList);
var
  Bm: String;
  I: Integer;
begin
  if ABL <> nil then
  begin
    ABL.Refresh;

    AnObject.DisableControls;
    try
      Bm := AnObject.Bookmark;
      for I := 0 to ABL.Count - 1 do
      begin
        AnObject.Bookmark := ABL[I];
        FList.Add(AnObject, Self);
      end;
      AnObject.Bookmark := Bm;
    finally
      AnObject.EnableControls;
    end;
  end;

  FList.Add(AnObject, Self);
end;

function TgsNSObjects.GetNamespaceCount: Integer;
var
  KA: TgdKeyArray;
begin
  KA := TgdKeyArray.Create;
  try
    FList.GetNamespaces(KA);
    Result := KA.Count;
  finally
    KA.Free;
  end;
end;

procedure TgsNSObjects.InitView(I: Iat_dlgToNamespace);
begin
  FList.InitView(I);
end;

{ TgsNSObject }

procedure TgsNSObject.Add(AnObject: TgdcBase);
var
  SessionID: Integer;
  qLink, qNS: TIBSQL;
  J: Integer;
  LinkObj, CompoundObj: TgdcBase;
  TL: TStringList;
  C: TPersistentClass;
begin
  Assert(AnObject <> nil);
  Assert(not AnObject.IsEmpty);
  Assert(FNSObjects.FindObject(AnObject.ID) = nil);

  FID := AnObject.ID;
  FObjectName := AnObject.ObjectName;
  FObjectClass := AnObject.ClassName;
  FSubType := AnObject.SubType;
  FRUID := AnObject.GetRUID;
  FEditionDate := AnObject.EditionDate;

  qNS := TIBSQL.Create(nil);
  try
    qNS.Transaction := FNSObjects.Transaction;
    qNS.SQL.Text :=
      'SELECT LIST(n.id, '','') ' +
      'FROM at_object o ' +
      '  JOIN gd_ruid r ON r.xid = o.xid AND r.dbid = o.dbid ' +
      '  JOIN at_namespace n ON n.id = o.namespacekey ' +
      'WHERE r.id = :ID';
    qNS.ParamByName('id').AsInteger := AnObject.ID;
    qNS.ExecQuery;
    if not qNS.EOF then
      FNamespace.CommaText := qNS.Fields[0].AsString;
  finally
    qNS.Free;
  end;

  SessionID := FNSObjects.GetNextSessionID;
  AnObject.GetDependencies(FNSObjects.Transaction, SessionID, False, ';EDITORKEY;CREATORKEY;');

  qLink := TIBSQL.Create(nil);
  try
    qLink.Transaction := FNSObjects.Transaction;
    qLink.SQL.Text :=
      'SELECT DISTINCT '#13#10 +
      '  od.refobjectid as id, '#13#10 +
      '  r.xid as xid, '#13#10 +
      '  r.dbid as dbid, '#13#10 +
      '  od.refclassname as class, '#13#10 +
      '  od.refsubtype as subtype, '#13#10 +
      '  od.refobjectname as name, '#13#10 +
      '  od.refeditiondate as editiondate '#13#10 +
      'FROM '#13#10 +
      '  gd_object_dependencies od '#13#10 +
      '  LEFT JOIN gd_p_getruid(od.refobjectid) r '#13#10 +
      '    ON 1=1 '#13#10 +
      'WHERE '#13#10 +
      '  od.sessionid = :sid '#13#10 +
      'ORDER BY '#13#10 +
      '  od.reflevel DESC';
    qLink.ParamByName('sid').AsInteger := SessionID;
    qLink.ExecQuery;

    while not qLink.EOF do
    begin
      if FNSObjects.FindObject(qLink.FieldByName('id').AsInteger) = nil then
      begin
        C := GetClass(qLink.FieldByName('class').AsString);

        if (C <> nil) and C.InheritsFrom(TgdcBase) then
        begin
          LinkObj := CgdcBase(C).Create(nil);
          try
            LinkObj.Transaction := FNSObjects.Transaction;
            LinkObj.SubType := qLink.FieldByName('subtype').AsString;
            LinkObj.SubSet := 'ByID';
            LinkObj.ID := qLink.FieldByName('id').AsInteger;
            LinkObj.Open;

            if not LinkObj.EOF then
              FLinked.Add(LinkObj, FNSObjects);
          finally
            LinkObj.Free;
          end;
        end;
      end;
      qLink.Next;
    end;

    for J := 0 to AnObject.CompoundClassesCount - 1 do
    begin
      CompoundObj := AnObject.CompoundClasses[J].gdClass.Create(nil);
      try
        CompoundObj.Transaction := FNSObjects.Transaction;
        CompoundObj.SubType := AnObject.CompoundClasses[J].SubType;
        CompoundObj.SubSet := 'All';
        CompoundObj.Prepare;

        TL := TStringList.Create;
        try
          ExtractTablesList(CompoundObj.SelectSQL.Text, TL);
          if TL.IndexOfName(AnObject.CompoundClasses[J].LinkRelationName) > -1 then
          begin
            CompoundObj.ExtraConditions.Add(
              TL.Values[AnObject.CompoundClasses[J].LinkRelationName] +
              AnObject.CompoundClasses[J].LinkFieldName +
              '=:LinkID');
            CompoundObj.ParamByName('LinkID').AsInteger := AnObject.ID;
            CompoundObj.Open;
            while not CompoundObj.EOF do
            begin
              FCompound.Add(CompoundObj, FNSObjects);
              CompoundObj.Next;
            end;
          end;
        finally
          TL.Free;
        end;
      finally
        CompoundObj.Free;
      end;
    end;
  finally
    qLink.Free;
  end;
end;

constructor TgsNSObject.Create(ANSObjects: TgsNSObjects);
begin
  FID := -1;
  FChecked := True;
  FLinked := TgsNSList.Create;
  FCompound := TgsNSList.Create;
  FNamespace := TgdKeyArray.Create;
  FNSObjects := ANSObjects;
end;

destructor TgsNSObject.Destroy;
begin
  FNamespace.Free;
  FLinked.Free;
  FCompound.Free;
  inherited;
end;

function TgsNSObject.FindObject(const AnID: TID): TgsNSObject;
begin
  if AnID = FID then
    Result := Self
  else begin
    Result := FLinked.FindObject(AnID);
    if Result = nil then
      Result := FCompound.FindObject(AnID);
  end;
end;

procedure TgsNSObject.GetNamespaces(AKeyArray: TgdKeyArray);
var
  I: Integer;
begin
  Assert(AKeyArray <> nil);

  for I := 0 to FNamespace.Count - 1 do
    AKeyArray.Add(FNamespace.Keys[I], True);

  FLinked.GetNamespaces(AKeyArray);
  FCompound.GetNamespaces(AKeyArray);
end;

procedure TgsNSObject.InitView(I: Iat_dlgToNamespace);
begin
  I.AddObject(FID, FObjectName, FObjectClass, FSubType, FRUID, FEditionDate,
    -1, '', False);
end;

{ TgsNSList }

function TgsNSList.Add(AnObject: TgdcBase; ANSObjects: TgsNSObjects): Integer;
var
  NSObj: TgsNSObject;
begin
  Assert(ANSObjects <> nil);
  Assert(AnObject <> nil);
  Assert(not AnObject.IsEmpty);

  if (ANSObjects.FindObject(AnObject.ID) = nil) and
    (
      (not (AnObject is TgdcMetaBase))
      or
      (not TgdcMetaBase(AnObject).IsDerivedObject)
    ) then
  begin
    NSObj := TgsNSObject.Create(ANSObjects);
    Result := FList.Add(NSObj);
    NSObj.Add(AnObject);
  end else
    Result := -1;
end;

constructor TgsNSList.Create;
begin
  inherited;
  FList := TObjectList.Create(True);
end;

destructor TgsNSList.Destroy;
begin
  FList.Free;
  inherited;
end;

function TgsNSList.FindObject(const AnID: TID): TgsNSObject;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ObjectCount - 1 do
  begin
    Result := Objects[I].FindObject(AnID);
    if Result <> nil then
      break;
  end;
end;

procedure TgsNSList.GetNamespaces(AKeyArray: TgdKeyArray);
var
  I: Integer;
begin
  for I := 0 to ObjectCount - 1 do
    Objects[I].GetNamespaces(AKeyArray);
end;

function TgsNSList.GetObjectCount: Integer;
begin
  Result := FList.Count;
end;

function TgsNSList.GetObjects(Index: Integer): TgsNSObject;
begin
  Result := FList[Index] as TgsNSObject;
end;

procedure TgsNSList.InitView(I: Iat_dlgToNamespace);
var
  J: Integer;
begin
  for J := 0 to ObjectCount - 1 do
    Objects[J].InitView(I);
end;

end.
