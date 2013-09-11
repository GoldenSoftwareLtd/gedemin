unit GsHugeIntSet;

interface

uses
  SysUtils, Classes;

type
  EgsHugeIntSet = class(Exception);

  TgsHugeByteArr = array[0..0] of Byte;
  PgsHugeByteArr = ^TgsHugeByteArr;

  TgsHugeIntSet = class(TObject)
  private
    FData: PgsHugeByteArr;
    FSize: Integer;

    FCount: Integer;       /// количество элементов во множестве

  public
    constructor Create;
    destructor Destroy; override;

    procedure Include(const AnItem: Integer);
    procedure Exclude(const AnItem: Integer);
    function Has(const AnItem: Integer): Boolean;
    procedure Clear;

    property Count: Integer read FCount;
  end;

  TgsIntArr = array[0..0] of Integer;
  PgsIntArr = ^TgsIntArr;

  TgsRecRefArr = class(TObject)
  private
    FData: PgsIntArr;
    FSize: Integer;
    FCount: Integer;

  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

const
  BitMaskArr: array[0..7] of Byte = (
    1 shl 7,
    1 shl 6,
    1 shl 5,
    1 shl 4,
    1 shl 3,
    1 shl 2,
    1 shl 1,
    1);

constructor TgsHugeIntSet.Create;
begin
  inherited Create;
  FSize := High(Integer) div 8;
  FData := AllocMem(FSize);
  FCount := 0;
end;

procedure TgsHugeIntSet.Include(const AnItem: Integer);
var
  Idx: Integer;
begin
  if AnItem < 0 then
    raise EgsHugeIntSet.Create('Negative id is not supported');
  Idx := AnItem div 8;
  FData^[Idx] := FData^[Idx] or BitMaskArr[AnItem mod 8];
  Inc(FCount);                                                                  ///
end;

procedure TgsHugeIntSet.Exclude(const AnItem: Integer);
var
  Idx: Integer;
begin
  if AnItem < 0 then
    raise EgsHugeIntSet.Create('Negative id is not supported');
  Idx := AnItem div 8;
  FData^[Idx] := FData^[Idx] and (not BitMaskArr[AnItem mod 8]);
  Dec(FCount);                                                                  ///
end;

function TgsHugeIntSet.Has(const AnItem: Integer): Boolean;
begin
  if AnItem < 0 then
    raise EgsHugeIntSet.Create('Negative id is not supported');
  Result := (FData^[AnItem div 8] and BitMaskArr[AnItem mod 8]) <> 0;
end;

destructor TgsHugeIntSet.Destroy;
begin
  FreeMem(FData);
  inherited;
end;

{ TgsRecRefArr }

constructor TgsRecRefArr.Create;
begin
  FCount := 0;
  FSize := SizeOf(FData[0]) * 65536;
  FData := AllocMem(FSize);
end;

destructor TgsRecRefArr.Destroy;
begin
  FreeMem(FData);
  inherited;
end;

procedure TgsHugeIntSet.Clear;
begin
  FillChar(FData^, FSize, #00);
end;

end.
