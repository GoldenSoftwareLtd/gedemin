
unit gsNSObjects;

interface

uses
  IBDatabase, ContNrs, DBGrids, gdcBaseInterface, gdcBase, gd_KeyAssoc;

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
    FHeadObjectKey: TID;
    FChecked: Boolean;
    FLinked: TgsNSList;
    FCompound: TgsNSList;
    FNamespace: TgsNSList;
    FNSObjects: TgsNSObjects;

  public
    constructor Create(ANSObjects: TgsNSObjects);
    destructor Destroy; override;

    procedure Add(AnObject: TgdcBase);
    function FindObject(const AnID: TID): TgsNSObject;

    property ID: TID read FID;
    property ObjectName: String read FObjectName;
    property ObjectClass: String read FObjectClass;
    property SubType: String read FSubType;
    property RUID: TRUID read FRUID;
    property EditionDate: TDateTime read FEditionDate;
    property HeadObjectKey: TID read FHeadObjectKey;
    property Checked: Boolean read FChecked write FChecked;
    property Linked: TgsNSList read FLinked;
    property Compound: TgsNSList read FCompound;
    property Namespace: TgsNSList read FNamespace;
  end;

  TgsNSList = class(TObject)
  private
    FList: TObjectList;

    function GetObjectCount: Integer;
    function GetObjects(Index: Integer): TgsNSObject;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(AnObject: TgdcBase; ANSObjects: TgsNSObjects);
    function FindObject(const AnID: TID): TgsNSObject;

    property ObjectCount: Integer read GetObjectCount;
    property Objects[Index: Integer]: TgsNSObject read GetObjects;
  end;

  TgsNSObjects = class(TObject)
  private
    FList: TgsNSList;
    FIBTransaction: TIBTransaction;

    function GetIBTransaction: TIBTransaction;

  protected
    procedure Add(AnObject: TgdcBase);

  public
    constructor Create;
    destructor Destroy; override;

    procedure Setup(AnObject: TgdcBase; ABL: TBookmarkList);
    function FindObject(const AnID: TID): TgsNSObject;

    property IBTransaction: TIBTransaction read GetIBTransaction;
  end;

implementation

{ TgsNSObjects }

procedure TgsNSObjects.Add(AnObject: TgdcBase);
begin
  FList.Add(AnObject, Self);
end;

constructor TgsNSObjects.Create;
begin
  inherited Create;
  FList := TgsNSList.Create;
  FIBTransaction := TIBTransaction.Create(nil);
  FIBTransaction.DefaultDatabase := gdcBaseManager.Database;
end;

destructor TgsNSObjects.Destroy;
begin
  FIBTransaction.Free;
  FList.Free;
  inherited;
end;

function TgsNSObjects.FindObject(const AnID: TID): TgsNSObject;
begin
  Result := FList.FindObject(AnID);
end;

function TgsNSObjects.GetIBTransaction: TIBTransaction;
begin
  if not FIBTransaction.InTransaction then
    FIBTransaction.StartTransaction;
  Result := FIBTransaction;  
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
        Add(AnObject);
      end;
      AnObject.Bookmark := Bm;
    finally
      AnObject.EnableControls;
    end;
  end;

  Add(AnObject);
end;

{ TgsNSObject }

procedure TgsNSObject.Add(AnObject: TgdcBase);
begin
  Assert(AnObject <> nil);
  Assert(not AnObject.EOF);
  Assert(FindObject(AnObject.ID) = nil);

  FID := AnObject.ID;
  FObjectName := AnObject.ObjectName;
  FObjectClass := AnObject.ClassName;
  FRUID := AnObject.GetRUID;
  FEditionDate := AnObject.EditionDate;
end;

constructor TgsNSObject.Create(ANSObjects: TgsNSObjects);
begin
  FID := -1;
  FHeadObjectKey := -1;
  FChecked := True;
  FLinked := TgsNSList.Create;
  FCompound := TgsNSList.Create;
  FNamespace := TgsNSList.Create;
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

{ TgsNSList }

procedure TgsNSList.Add(AnObject: TgdcBase; ANSObjects: TgsNSObjects);
var
  NSObj: TgsNSObject;
begin
  Assert(AnObject <> nil);
  Assert(not AnObject.EOF);

  if FindObject(AnObject.ID) <> nil then
    exit;

  NSObj := TgsNSObject.Create(ANSObjects);
  FList.Add(NSObj);
  NSObj.Add(AnObject);
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

function TgsNSList.GetObjectCount: Integer;
begin
  Result := FList.Count;
end;

function TgsNSList.GetObjects(Index: Integer): TgsNSObject;
begin
  Result := FList[Index] as TgsNSObject;
end;

end.
