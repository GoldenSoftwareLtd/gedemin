unit GsHugeIntSet;

interface

uses
  SysUtils, Classes, Contnrs, Windows;

type
  EgsHugeIntSet = class(Exception);

  TgsHugeIntSet = class(TObject)
  private 
    FFileMapping: THandle;
    FData: PChar;
    FCount: Integer;         
    FFileName: PChar;
    FDelta: Integer; 

    procedure CheckRange(const AnItem: Integer);
    procedure OpenFile(const AName: PChar; const ASize: Cardinal);
    procedure MapView;
  public
    constructor Create(const AName: PChar; const ASize: Cardinal; const ADelta: Integer = 0);  
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

  BLOCK_SIZE = (High(Integer) div 8) + 1;

constructor TgsHugeIntSet.Create(const AName: PChar; const ASize: Cardinal; const ADelta: Integer = 0);
begin
  inherited Create;
  FFileName := AName;
  FCount := 0;
  OpenFile(FFileName, ASize);
  MapView;
  FDelta := ADelta;
end;

procedure TgsHugeIntSet.Include(const AnItem: Integer);
begin
  if not Has(AnItem) then
  begin
    FData[(AnItem - FDelta) div 8] := Char(ord(FData[(AnItem - FDelta) div 8])
      or BitMaskArr[(AnItem - FDelta) mod 8]);
    Inc(FCount);
  end;
end;

procedure TgsHugeIntSet.Exclude(const AnItem: Integer);
begin
  if Has(AnItem) then
  begin
    FData[(AnItem - FDelta) div 8] := Char(ord(FData[(AnItem - FDelta) div 8])
      and (not BitMaskArr[(AnItem - FDelta) mod 8]));
    Dec(FCount);
  end;
end;

function TgsHugeIntSet.Has(const AnItem: Integer): Boolean;
begin
  CheckRange(AnItem);
  Result := Boolean(ord(FData[(AnItem - FDelta) div 8])
    and BitMaskArr[(AnItem - FDelta) mod 8]);
end;

procedure TgsHugeIntSet.Clear;
begin
 // FillChar(FArray[0], Length(FArray), 0);
  UnMapViewOfFile(FData);
  MapView;
  FCount := 0;
end;

destructor TgsHugeIntSet.Destroy;
begin
   UnMapViewOfFile(FData);
   CloseHandle(FFileMapping);
  //SetLength(FArray, 0);
  inherited;
end;

procedure TgsHugeIntSet.CheckRange(const AnItem: Integer);
begin
  if (AnItem - FDelta) < 0 then
    raise EgsHugeIntSet.Create('Negative index is not supported');
end;

procedure TgsHugeIntSet.OpenFile(const AName: PChar; const ASize: Cardinal);
begin
  FFileMapping := OpenFileMapping(FILE_MAP_READ or FILE_MAP_WRITE,
    False,
    FFileName);
  if FFileMapping = 0 then
  begin
    FFileMapping := CreateFileMapping(INVALID_HANDLE_VALUE,
      nil,
      PAGE_READWRITE,
      0,
      ASize,
      FFileName);

    if FFileMapping = 0 then
      raise Exception.Create('Can not create a file mapping');
  end;
end;

procedure TgsHugeIntSet.MapView;
begin
  FData := MapViewOfFile(FFileMapping,
    FILE_MAP_READ or FILE_MAP_WRITE,
    0,
    0,
    0);
  if FData = nil then
    raise Exception.Create('Can not map view of file!');
end;
end.
