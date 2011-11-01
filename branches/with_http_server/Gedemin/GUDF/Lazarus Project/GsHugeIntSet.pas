unit GsHugeIntSet;

interface

uses
  Windows, SysUtils, Classes, Contnrs, Dialogs;

type
  EgsHugeIntSet = class(Exception);

  TgsHugeIntSet = class(TObject)
  private
    FArray: array of Byte;
    FCount: Integer;

    procedure CheckRange(const AnItem: Integer);

  public
    constructor Create;
    destructor Destroy; override;

    procedure Include(const AnItem: Integer);
    procedure Exclude(const AnItem: Integer);
    procedure Clear;
    function Has(const AnItem: Integer): Boolean;

    property Count: Integer read FCount;
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
  inherited;
  FCount := 0;
  SetLength(FArray, (High(Integer) div 8) + 1);
  Clear;
end;

procedure TgsHugeIntSet.Include(const AnItem: Integer);
begin
  if not Has(AnItem) then
  begin
    FArray[AnItem div 8] := FArray[AnItem div 8]
      or BitMaskArr[AnItem mod 8];
    Inc(FCount);
  end;
end;

procedure TgsHugeIntSet.Exclude(const AnItem: Integer);
begin
  if Has(AnItem) then
  begin
    FArray[AnItem div 8] := FArray[AnItem div 8]
      and (not BitMaskArr[AnItem mod 8]);
    Dec(FCount);
  end;
end;

function TgsHugeIntSet.Has(const AnItem: Integer): Boolean;
begin
  CheckRange(AnItem);
  Result := Boolean(FArray[AnItem div 8]
    and BitMaskArr[AnItem mod 8]);
end;

procedure TgsHugeIntSet.Clear;
begin
  FillChar(FArray[0], Length(FArray), 0);
  FCount := 0;
end;

destructor TgsHugeIntSet.Destroy;
begin
  SetLength(FArray, 0);
  inherited;
end;

procedure TgsHugeIntSet.CheckRange(const AnItem: Integer);
begin
  if AnItem < 0 then
    raise EgsHugeIntSet.Create('Negative index is not supported');
end;

end.
