unit gd_StyleManager;

interface

uses
  Contnrs, Classes, TypInfo, Forms, SysUtils, gsDBGrid, Graphics;

type

  TgdStyleEntry = class
  private
    FID: Integer;
    FObjectKey: Integer;
    FPropID: Integer;
    FIntValue: Integer;
    FStrValue: String;
    FUserKey: Integer;
    FThemeKey: Integer;

  public
    property ID: Integer read FID;
    property ObjectKey: Integer read FObjectKey;
    property PropID: Integer read FPropID;
    property IntValue: Integer read FIntValue;
    property StrValue: String read FStrValue;
    property UserKey: Integer read FUserKey;
    property ThemeKey: Integer read FThemeKey;
  end;

  TgdStyleObject = class
  private
    FID: Integer;
    FObjectType: Integer;
    FObjectName: String;

    FEntry: TObjectList;

    function GetEntry(Index: Integer): TgdStyleEntry;
    function GetCount: Integer;

  public
    function Compare(const AnObjectType: Integer;
      const AnObjectName: String): Integer;

    property ID: Integer read FID;
    property ObjectType: Integer read FObjectType;
    property ObjectName: String read FObjectName;



    property Entry[Index: Integer]: TgdStyleEntry read GetEntry;
    property Count: Integer read GetCount;
  end;

  TgdStyleManager = class
  private
    FStyleObjects: array of TgdStyleObject;
    FCount: Integer;

    FChanges: TStringList;

    procedure _Grow;
    procedure _Compact;

    function _Find(const AnObjectType: Integer; const AnObjectName: String;
      out Index: Integer): Boolean;
    procedure _Insert(const Index: Integer; ASO: TgdStyleObject);

  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromDB;
    procedure SaveToDB;

  end;

var
  _gdStyleManager: TgdStyleManager;

function gdStyleManager: TgdStyleManager;

implementation

uses
  gd_security, gdcBaseInterface, IBSQL, IBDatabase;

function gdStyleManager: TgdStyleManager;
begin
  if _gdStyleManager = nil then
    _gdStyleManager := TgdStyleManager.Create;
  Result := _gdStyleManager;
end;

{ TgdStyleEntry }

{ TgdStyleObject }

function TgdStyleObject.GetEntry(Index: Integer): TgdStyleEntry;
begin
  Result := FEntry[Index] as TgdStyleEntry;
end;

function TgdStyleObject.GetCount: Integer;
begin
  if FEntry = nil then
    Result := 0
  else
    Result := FEntry.Count;
end;

function TgdStyleObject.Compare(const AnObjectType: Integer;
  const AnObjectName: String): Integer;
begin
  if FObjectType > AnObjectType then
    Result := 1
  else if FObjectType < AnObjectType then
    Result := -1
  else
    Result := 0;

  if Result = 0 then
    Result := CompareText(FObjectName, AnObjectName);
end;

{ TgdStyleManager }

constructor TgdStyleManager.Create;
begin
  inherited;

  FChanges := TStringList.Create;
end;

destructor TgdStyleManager.Destroy;
begin
  FChanges.Free;

  inherited;
end;

procedure TgdStyleManager._Grow;
begin
  if High(FStyleObjects) = -1 then
    SetLength(FStyleObjects, 2048)
  else
    SetLength(FStyleObjects, High(FStyleObjects) + 1 + 1024);
end;

procedure TgdStyleManager._Compact;
var
  B, E: Integer;
begin
  B := 0;
  while B < FCount do
  begin
    E := B;
    while (E < FCount) and (FStyleObjects[E] = nil) do
      Inc(E);
    if E = FCount then
    begin
      FCount := B;
      break;
    end;
    if E > B then
    begin
      System.Move(FStyleObjects[E], FStyleObjects[B], (FCount - E) * SizeOf(FStyleObjects[0]));
      Dec(FCount, E - B);
    end;
    Inc(B);
  end;
end;

function TgdStyleManager._Find(const AnObjectType: Integer; const AnObjectName: String;
  out Index: Integer): Boolean;
var
  L, H, C: Integer;
begin
  Result := False;
  L := 0;
  H := FCount - 1;
  while L <= H do
  begin
    Index := (L + H) shr 1;
    C := FStyleObjects[Index].Compare(AnObjectType, AnObjectName);
    if C < 0 then
      L := Index + 1
    else if C > 0 then
      H := Index - 1
    else begin
      Result := True;
      exit;
    end;
  end;
  Index := L;
end;

procedure TgdStyleManager._Insert(const Index: Integer; ASO: TgdStyleObject);
begin
  if FCount > High(FStyleObjects) then _Grow;
  if Index < FCount then
  begin
    System.Move(FStyleObjects[Index], FStyleObjects[Index + 1],
      (FCount - Index) * SizeOf(FStyleObjects[0]));
  end;
  FStyleObjects[Index] := ASO;
  Inc(FCount);
end;

procedure TgdStyleManager.LoadFromDB;
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(gdcBaseManager <> nil);

  q := TIBSQL.Create(nil);
  try
    Tr := TIBTransaction.Create(nil);
    try
      Tr.DefaultDatabase := gdcBaseManager.Database;
      Tr.StartTransaction;

      q.SQL.Text := ''; 

      q.ExecQuery;
      Tr.Commit;
    finally
      Tr.Free;
    end;
  finally
    q.Free;
  end;
end;

procedure TgdStyleManager.SaveToDB;
var
  I: Integer;
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  if FChanges.Count > 0 then
  begin
    try
      Assert(gdcBaseManager <> nil);

      q := TIBSQL.Create(nil);
      try
        Tr := TIBTransaction.Create(nil);
        try
          Tr.DefaultDatabase := gdcBaseManager.Database;
          Tr.StartTransaction;
          for I := 0 to FChanges.Count - 1 do
          begin
            q.Close;
            q.SQL.Text := FChanges[I];
            q.ExecQuery;
          end;
          Tr.Commit;
        finally
          Tr.Free;
        end;
      finally
        q.Free;
      end;
    finally
      FChanges.Clear;
    end;
  end;
end;

initialization

finalization
  FreeAndNil(_gdStyleManager);

end.
