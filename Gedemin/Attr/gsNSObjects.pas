
unit gsNSObjects;

interface

uses
  ContNrs, DBGrids, gdcBaseInterface, gdcBase, gd_KeyAssoc;

type
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
    FLinked: TgsNSObjects;
    FCompound: TgsNSObjects;
    FNamespace: TgdKeyArray;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(AnObject: TgdcBase);

    property ID: TID read FID;
    property ObjectName: String read FObjectName;
    property ObjectClass: String read FObjectClass;
    property SubType: String read FSubType;
    property RUID: TRUID read FRUID;
    property EditionDate: TDateTime read FEditionDate;
    property HeadObjectKey: TID read FHeadObjectKey;
    property Checked: Boolean read FChecked write FChecked;
  end;

  TgsNSObjects = class(TObject)
  private
    FList: TObjectList;

    function GetObjectCount: Integer;
    function GetObjects(Index: Integer): TgsNSObject;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Setup(AnObject: TgdcBase; ABL: TBookmarkList);
    function FindObject(const AnID: TID): TgsNSObject;

    property ObjectCount: Integer read GetObjectCount;
    property Objects[Index: Integer]: TgsNSObject read GetObjects;
  end;

implementation

{ TgsNSObjects }

constructor TgsNSObjects.Create;
begin
  inherited Create;
  FList := TObjectList.Create(True);
end;

destructor TgsNSObjects.Destroy;
begin
  FList.Free;
  inherited;
end;

function TgsNSObjects.FindObject(const AnID: TID): TgsNSObject;
begin
  Result := nil;
end;

function TgsNSObjects.GetObjectCount: Integer;
begin
  Result := FList.Count;
end;

function TgsNSObjects.GetObjects(Index: Integer): TgsNSObject;
begin
  Result := FList[Index] as TgsNSObject;
end;

procedure TgsNSObjects.Setup(AnObject: TgdcBase; ABL: TBookmarkList);

  procedure Add(AnObject: TgdcBase);
  var
    NSObj: TgsNSObject;
  begin
    if FindObject(AnObject.ID) = nil then
    begin
      NSObj := TgsNSObject.Create;
      FList.Add(NSObj);
      NSObj.Add(AnObject);
    end;
  end;

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

end;

constructor TgsNSObject.Create;
begin
  FID := -1;
  FHeadObjectKey := -1;
  FChecked := True;
  FLinked := TgsNSObjects.Create;
  FCompound := TgsNSObjects.Create;
  FNamespace := TgdKeyArray.Create;
end;

destructor TgsNSObject.Destroy;
begin
  FNamespace.Free;
  FLinked.Free;
  FCompound.Free;
  inherited;
end;

end.
