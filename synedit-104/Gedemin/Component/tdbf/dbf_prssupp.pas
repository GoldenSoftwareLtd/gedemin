unit dbf_prssupp;

// parse support

{$I dbf_common.inc}

interface

uses
  Classes;

type

  {TOCollection interfaces between OWL TCollection and VCL TList}

  TOCollection = class(TList)
  public
    procedure AtFree(Index: Integer);
    procedure FreeAll;
    procedure DoFree(Item: Pointer);
    procedure FreeItem(Item: Pointer); virtual;
    destructor Destroy; override;
  end;

  TNoOwnerCollection = class(TOCollection)
  public
    procedure FreeItem(Item: Pointer); override;
  end;

  { TSortedCollection object }

  TSortedCollection = class(TOCollection)
  public
    function Compare(Key1, Key2: Pointer): Integer; virtual; abstract;
    function IndexOf(Item: Pointer): Integer; virtual;
    procedure Add(Item: Pointer); virtual;
    procedure AddReplace(Item: Pointer); virtual;
    procedure AddList(Source: TList; FromIndex, ToIndex: Integer);
    {if duplicate then replace the duplicate else add}
    function KeyOf(Item: Pointer): Pointer; virtual;
    function Search(Key: Pointer; var Index: Integer): Boolean; virtual;
  end;

  { TStrCollection object }

  TStrCollection = class(TSortedCollection)
  public
    function Compare(Key1, Key2: Pointer): Integer; override;
    procedure FreeItem(Item: Pointer); override;
  end;

implementation

uses SysUtils;

destructor TOCollection.Destroy;
begin
  FreeAll;
  inherited Destroy;
end;

procedure TOCollection.AtFree(Index: Integer);
var
  Item: Pointer;
begin
  Item := Items[Index];
  Delete(Index);
  FreeItem(Item);
end;


procedure TOCollection.FreeAll;
var
  I: Integer;
begin
  try
    for I := 0 to Count - 1 do
      FreeItem(Items[I]);
  finally
    Count := 0;
  end;
end;

procedure TOCollection.DoFree(Item: Pointer);
begin
  AtFree(IndexOf(Item));
end;

procedure TOCollection.FreeItem(Item: Pointer);
begin
  if (Item <> nil) then
    with TObject(Item) as TObject do
      Free;
end;

{----------------------------------------------------------------virtual;
  Implementing TNoOwnerCollection
  -----------------------------------------------------------------}

procedure TNoOwnerCollection.FreeItem(Item: Pointer);
begin
end;

{ TSortedCollection }

function TSortedCollection.IndexOf(Item: Pointer): Integer;
var
  I: Integer;
begin
  IndexOf := -1;
  if Search(KeyOf(Item), I) then
  begin
    while (I < Count) and (Item <> Items[I]) do
      Inc(I);
    if I < Count then IndexOf := I;
  end;
end;

procedure TSortedCollection.AddReplace(Item: Pointer);
var
  Index: Integer;
begin
  if Search(KeyOf(Item), Index) then
    Delete(Index);
  Add(Item);
end;

procedure TSortedCollection.Add(Item: Pointer);
var
  I: Integer;
begin
  Search(KeyOf(Item), I);
  Insert(I, Item);
end;

procedure TSortedCollection.AddList(Source: TList; FromIndex, ToIndex: Integer);
var
  I: Integer;
begin
  for I := FromIndex to ToIndex do
    Add(Source.Items[I]);
end;

function TSortedCollection.KeyOf(Item: Pointer): Pointer;
begin
  Result := Item;
end;

function TSortedCollection.Search(Key: Pointer; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Search := False;
  L := 0;
  H := Count - 1;
  while L <= H do
  begin
    I := (L + H) div 2;
    C := Compare(KeyOf(Items[I]), Key);
    if C < 0 then
      L := I + 1
    else
    begin
      H := I - 1;
      if C = 0 then
        Search := True;
    end;
  end;
  Index := L;
end;

{ TStrCollection }

function TStrCollection.Compare(Key1, Key2: Pointer): Integer;
begin
  Compare := StrComp(Key1, Key2);
end;

procedure TStrCollection.FreeItem(Item: Pointer);
begin
  StrDispose(Item);
end;

end.

