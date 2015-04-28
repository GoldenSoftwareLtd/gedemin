unit gsStorageLink;

interface

uses
  SysUtils, Classes, Contnrs, Windows, gsMMFStream, GsHugeIntSet;

type
  TRecordID = Record
    ID: Cardinal;
    Pos: Cardinal;
  end;

  TgsStorageID = class(TObject)
  private
    FStorage_ID: TgsStream64;
    FStorage_Link: TgsStream64;
    FHuge: TgsHugeIntSet;
    S: array of TRecordID;
    LastElement: Cardinal;
    FCount: Integer;
    
    procedure NewBlock;
    procedure CheckMemorySize(const AnItem: Cardinal);
    procedure GetLastBlockPosition(const AFirstBlockPosition: Cardinal);
  public
    constructor Create(ACount: Integer);
    destructor Destroy; override;

    procedure IncludeID(const AnItem, AnElement: Cardinal);
    procedure IncludeID2(const AnItem, AnElement: Cardinal);
    procedure Add(const AnItem: Cardinal);
    function GetLink(const AnItem: Cardinal): String;
    procedure Sort;
    procedure SetStorage_ID;
  end;

implementation

constructor TgsStorageID.Create(ACount: Integer);
var
  I, J: Integer;
begin
  inherited Create;

  FStorage_ID := TgsStream64.Create;
  J := 0;
  for I := 1 to ACount do
    FStorage_ID.WriteBuffer(J, SizeOf(J));

  FStorage_Link := TgsStream64.Create; 
  FStorage_Link.WriteBuffer(J, SizeOf(J));
  //FHuge := TgsHugeIntSet.Create('1');
  LastElement := 0;
  FCount := 0;
end;

procedure TgsStorageID.IncludeID(const AnItem, AnElement: Cardinal);
var
  Element, Current_pos, pos_block_link: Cardinal;
  Write: Boolean;
  J: integer;
begin
  CheckMemorySize(AnItem);
  if AnElement <> 0 then
  begin
    FStorage_ID.Position := 4 * AnItem;
    FStorage_ID.ReadBuffer(pos_block_link, sizeof(pos_block_link));
    if pos_block_link = 0 then
    begin
      FStorage_ID.Position := 4 * AnItem;
      Current_pos := FStorage_Link.Size;
      FStorage_ID.WriteBuffer(Current_pos, sizeof(Current_pos));
      NewBlock;
      FStorage_Link.WriteBuffer(AnElement, sizeof(AnElement));
    end else
    begin
      GetLastBlockPosition(pos_block_link);
      Write := False;
      for J := 1 to 2 do
      begin
        FStorage_Link.ReadBuffer(Element, sizeof(Element));
        if Element = 0 then
        begin
          FStorage_Link.Position := FStorage_Link.Position - 4;
          FStorage_Link.WriteBuffer(AnElement, sizeof(AnElement));
          Write := True;
          break;
        end;
      end;
      if not Write then
      begin
        Element := FStorage_Link.Size;
        FStorage_Link.WriteBuffer(Element, sizeof(Element));
        NewBlock;
        FStorage_Link.WriteBuffer(AnElement, sizeof(AnElement));
      end;
    end;
  end;
end;

procedure TgsStorageID.IncludeID2(const AnItem, AnElement: Cardinal);
var
  Element: Cardinal;
begin
  if LastElement <> AnItem then
  begin
    if Sizeof(S) > 104857600 then
      SetStorage_ID;
    Setlength(S,  High(S) + 2);
    S[High(S)].ID := AnItem;
    LastElement := AnItem;
    FCount := 0;
    NewBlock;
    S[High(S)].Pos := FStorage_Link.Position;
  end;
  if FCount <> 3 then
  begin
    FStorage_Link.WriteBuffer(AnElement, sizeof(AnElement));
    Inc(FCount);
  end
  else
  begin
    Element := FStorage_Link.Size;
    FStorage_Link.WriteBuffer(Element, sizeof(Element));
    NewBlock;
    FStorage_Link.WriteBuffer(AnElement, sizeof(AnElement));
    FCount := 1;
  end;
end;

destructor TgsStorageID.Destroy;
begin
  FStorage_ID.Free;
  FStorage_Link.Free;
  Setlength(S, 0);
  inherited;
end;

function TgsStorageID.GetLink(const AnItem: Cardinal): String;
var
  Element, pos_block_link: Cardinal;
  I: integer;
  LinkInsert: TStringList;
begin
  LinkInsert := TStringList.Create;
  try
    FStorage_ID.Position := 4 * AnItem;
    FStorage_ID.ReadBuffer(pos_block_link, sizeof(pos_block_link));
    if pos_block_link <> 0 then
    begin
      while (pos_block_link <> 0) do
      begin
        FStorage_Link.Position := pos_block_link;
        for I := 1 to 3 do
        begin
          FStorage_Link.ReadBuffer(Element, sizeof(Element));
          LinkInsert.Add(IntToStr(Element));
        end;
        FStorage_Link.ReadBuffer(pos_block_link, sizeof(pos_block_link));
      end;
      Result := LinkInsert.CommaText;
    end
    else
      Result := '';
  finally
    LinkInsert.Free;
  end;
end;

procedure TgsStorageID.NewBlock;
var
  I,J: Cardinal;
begin
  J := 0;
  FStorage_Link.Position := FStorage_Link.Size; 
  for I := 1 to 4 do
    FStorage_Link.WriteBuffer(J, sizeof(J));
  FStorage_Link.Position := FStorage_Link.POsition - 16;
end;

procedure TgsStorageID.GetLastBlockPosition(const AFirstBlockPosition: Cardinal);
var
  NextElement: Cardinal;
begin
  NextElement := AFirstBlockPosition;
  while (NextElement <> 0) do
  begin
    FStorage_Link.Position := NextElement + 12;
    FStorage_Link.ReadBuffer(NextElement, sizeof(NextElement));
  end;
  FStorage_Link.Position := FStorage_Link.Position  - 4;
end;

procedure TgsStorageID.Add(const AnItem: Cardinal);
var
  Element, Pos, I: Cardinal; 
begin
  if not FHuge.Has(AnItem) then
  begin
    FHuge.Include(AnItem);
    FStorage_ID.Position := 4*AnItem;
    FStorage_ID.ReadBuffer(Pos, sizeof(Pos));
    while (Pos <> 0) do
    begin
      for I := 1 to 3 do
      begin
        FStorage_Link.Position := Pos + (I - 1)*4;
        FStorage_Link.ReadBuffer(Element, sizeof(Element));
        if Element <> 0  then
          Add(Element)
        else
          break
      end;
      FStorage_Link.Position := Pos + 12;
      FStorage_Link.ReadBuffer(Pos,sizeof(Pos));
    end;
  end;
end;

procedure TgsStorageID.CheckMemorySize(const AnItem: Cardinal);
var
  I,J : integer;
begin
  if FStorage_ID.Size <= 4*AnItem then
  begin
    J := 0;
    for I := 1 to AnItem do
      FStorage_ID.WriteBuffer(J, Sizeof(J));
  end;
end;

procedure TgsStorageID.Sort;
var
  J, I: integer;
  RID: TRecordID;
begin
  for I := High(S) - 1 downto 0 do
    for J := 0 to I do
    begin
      if S[J].ID > S[J + 1].ID then
      begin
        RID := S[J];
        S[J] := S[J + 1];
        S[J + 1] := RID;
      end;
    end;
end;

procedure TgsStorageID.SetStorage_ID;
var
  I: Integer;
  pos_block_link: Cardinal;
begin
  Sort;
  for I := 0 to High(S) do
  begin
    CheckMemorySize(S[I].ID);
    FStorage_ID.Position := 4 * S[I].ID;
    FStorage_ID.ReadBuffer(pos_block_link, sizeof(pos_block_link));
    if pos_block_link <> 0 then
    begin
      GetLastBlockPosition(pos_block_link);
      FStorage_Link.WriteBuffer(S[I].Pos, sizeof(S[I].Pos));
    end else
    begin
      FStorage_ID.Position := 4 * S[I].ID;
      FStorage_ID.WriteBuffer(S[I].Pos, sizeof(S[I].Pos));
    end;
  end;
  Setlength(S,0);
end;

end.
