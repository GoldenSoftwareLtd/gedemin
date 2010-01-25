{*******************************************************}
{                                                       }
{       Borland Delphi Visual Component Library         }
{                                                       }
{       Copyright (c) 1997,99 Inprise Corporation       }
{                                                       }
{*******************************************************}

unit mxarrays;

interface

uses
  SysUtils, Windows, Classes, mxconsts;

type
  { Exceptions }
  EArrayError = class(Exception);
  EUnsupportedTypeError = class(Exception);
  ELowCapacityError = class(Exception);

  TCompareProc = function(var item1, item2): Integer;

  TSortOrder = (tsNone, tsAscending, tsDescending);

  { These flags govern some of the behaviour of array methods }
  TArrayFlags = (afOwnsData, afAutoSize, afCanCompare, afSortUnique);
  TArrayFlagSet = Set of TArrayFlags;

  TDuplicates = (dupIgnore, dupAccept, dupError);

  TStringItem = record
    FString: string;
    FObject: TObject;
  end;

  { This is the base array object that all other array classes inheret from }

  TBaseArray = class(TPersistent)
  private
    FMemory: Pointer;           { Pointer to item buffer }
    FCapacity: Integer;         { The allocated size of the array }
    FItemSize: Integer;         { Size of individual item in bytes }
    FCount: Integer;            { Count of items in use }
    FSortOrder: TSortOrder;     { True if array is considered sorted }
    FFlags: TArrayFlagSet;      { Ability flags }
    FDuplicates: TDuplicates;   { Signifies if duplicates are stored or not }
    FCompProc: TCompareProc;
    function GetItemPtr(index: Integer): Pointer;
    procedure CopyFrom(toIndex, numItems: Integer; var Source);
    procedure SetCount(NewCount: Integer);
    function GetLimit: Integer;
  protected
    function ValidIndex(Index: Integer): Boolean;
    function HasFlag(aFlag: TArrayFlags): Boolean;
    procedure SetFlag(aFlag: TArrayFlags);
    procedure ClearFlag(aFlag: TArrayFlags);
    procedure SetAutoSize(aSize: Boolean);
    procedure BlockCopy(Source: TBaseArray; fromIndex, toIndex, numitems: Integer);
    function GetAutoSize: Boolean;
    function ValidateBounds(atIndex: Integer; var numItems: Integer): Boolean;
    procedure RemoveRange(atIndex, numItems: Integer);
    procedure InternalHandleException;
    procedure InvalidateItems(atIndex, numItems: Integer); virtual;
    procedure SetCapacity(NewCapacity: Integer); virtual;
    procedure Grow; virtual;
  public
    constructor Create(itemcount, iSize: Integer); virtual;
    destructor Destroy; override;
    procedure Clear;
    procedure InsertAt(Index: Integer; var Value);
    procedure Insert(Index: Integer; var Value); virtual;
    procedure PutItem(index: Integer; var Value);
    procedure GetItem(index: Integer; var Value);
    procedure RemoveItem(Index: Integer);
    procedure Delete(Index: Integer); virtual;
    procedure Exchange(Index1, Index2: Integer); virtual;
    function IndexOf(var Item): Integer; virtual;
    function FindItem(var Index: Integer; var Value): Boolean;
    procedure Sort(Compare: TCompareProc); virtual;
    property CompareProc: TCompareProc read FCompProc write FCompProc;
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
    property SortOrder: TSortOrder read FSortOrder write FSortOrder;
    property Capacity: Integer read FCapacity write SetCapacity;
    property Limit: Integer read GetLimit write SetCapacity;  
    property ItemSize: Integer read FItemSize;
    property AutoSize: Boolean read GetAutoSize write SetAutoSize;
    property Count: Integer read FCount write SetCount;
    property List: Pointer read FMemory;
  end;

  TSmallIntArray = class(TBaseArray)
  public
    constructor Create(itemcount, dummy: Integer); override;
    procedure PutItem(index: Integer; value: SmallInt);
    function GetItem(index: Integer): SmallInt;
    function Add(Value: SmallInt): Integer;
    procedure Assign(Source: TPersistent); override;
    property Items[Index:Integer]: SmallInt read GetItem write PutItem; default;
  end;

  TIntArray = class(TBaseArray)
  public
    constructor Create(itemcount, dummy: Integer); override;
    procedure PutItem(index: Integer; value: Integer);
    function GetItem(index: Integer): Integer;
    function Add(Value: Integer): Integer;
    procedure Assign(Source: TPersistent); override;
    function Find(var Index: Integer; Value: Integer): Boolean;
    property Items[Index: Integer]: Integer read GetItem write PutItem; default;
  end;

  TSingleArray = class(TBaseArray)
  public
    constructor Create(itemcount, dummy: Integer); override;
    procedure PutItem(index: Integer; value: Single);
    function GetItem(index: Integer): Single;
    function Add(Value: Single): Integer;
    function Find(var Index: Integer; Value: Single): Boolean;
    function IndexOf(var Item): Integer; override;
    procedure Assign(Source: TPersistent); override;
    property Items[Index: Integer]: Single read GetItem write PutItem; default;
  end;

  TDoubleArray = class(TBaseArray)
  public
    constructor Create(itemcount, dummy: Integer); override;
    procedure PutItem(index: Integer; value: Double);
    function GetItem(index: Integer): Double;
    function Add(Value: Double): Integer;
    function Find(var Index: Integer; Value: Double): Boolean;
    function IndexOf(var Item): Integer; override;
    procedure Assign(Source: TPersistent); override;
    property Items[Index: Integer]: Double read GetItem write PutItem; default;
  end;

  TCurrencyArray = class(TBaseArray)
  public
    constructor Create(itemcount, dummy: Integer); override;
    procedure PutItem(index: Integer; value: Currency);
    function GetItem(index: Integer): Currency;
    function Add(Value: Currency): Integer;
    function Find(var Index: Integer; Value: Currency): Boolean;
    function IndexOf(var Item): Integer; override;
    procedure Assign(Source: TPersistent); override;
    property Items[Index: Integer]: Currency read GetItem write PutItem; default;
  end;

  TWordArray = class(TBaseArray)
  public
    constructor Create(itemcount, dummy: Integer); override;
    procedure PutItem(index: Integer; value: Word);
    function GetItem(index: Integer): Word;
    function Add(Value: Word): Integer;
    function Find(var Index: Integer; Value: Word): Boolean;
    function IndexOf(var Item): Integer; override;
    procedure Assign(Source: TPersistent); override;
    property Items[Index: Integer]: Word read GetItem write PutItem; default;
  end;

  TPointerArray = class(TBaseArray)
  public
    constructor Create(itemcount, dummy: Integer); override;
    procedure PutData(index: Integer; value: Pointer);
    function GetData(index: Integer): Pointer;
    procedure CopyFrom(var Source; toIndex, numItems: Integer);
    procedure CopyTo(var Dest; fromIndex, numItems: Integer);
    procedure InvalidateItems(atIndex, numItems: Integer); override;
    function CloneItem(item: Pointer): Pointer; virtual;
    procedure FreeItem(item: Pointer); virtual;
    property AsPtr[Index: Integer]: Pointer read GetData write PutData;
    property Data[Index: Integer]: Pointer read GetData write PutData;
  end;

  TStringArray = class(TBaseArray)
  private
    procedure ExchangeItems(Index1, Index2: Integer);
    procedure QuickSort(L, R: Integer);
    procedure InsertItem(Index: Integer; const S: string);
    procedure AddStrings(Strings: TStringArray);
  protected
    function GetString(Index: Integer): string;
    procedure PutString(Index: Integer; const S: string);
    function GetObject(Index: Integer): TObject;
    procedure PutObject(Index: Integer; AObject: TObject);
    procedure InvalidateItems(atIndex, numItems: Integer); override;
    procedure Grow; override;
  public
    constructor Create(itemcount, dummy: Integer);override;
    function Add(const S: String): Integer;
    procedure Assign(Source: TPersistent); override;
    procedure Exchange(Index1, Index2: Integer); override;
    function Find(S: string; var Index: Integer): Boolean;
    function IndexOf(var Item): Integer; override;
    procedure Sort(Compare: TCompareProc); override;
    procedure Insert(Index: Integer; var Value); override;
    property Strings[Index: Integer]: String read GetString write PutString; default;
  end;

Const
  vMaxRow = (High(Integer)-$f) div Sizeof(SmallInt);
  vMaxCol = High(Integer) div Sizeof(TSmallIntArray)-1;

type
  TMatrixNDX = 0..vMaxCol;
  TDynArrayNDX = 0..vMaxRow;
  TMatrixElements = array[TMatrixNDX] of TSmallIntArray;
  PMatrixElements = ^TMatrixElements;

  EDynArrayRangeError = class(ERangeError);

  TTwoDimArray = class
  Private
    FRows: TDynArrayNDX;
    FColumns: TMatrixNDX;
    FMemAllocated: Integer;
    function GetElement(row: TDynArrayNDX; column: TMatrixNDX): SmallInt;
    procedure SetElement(row: TDynArrayNDX; column: TMatrixNDX; const NewValue: SmallInt);
  Protected
    mtxElements: PMatrixElements;
  Public
    constructor Create;
    Destructor Destroy; override;
    procedure SetSize(NumRows: TDynArrayNDX; NumColumns: TMatrixNDX);
    Property rows: TDynArrayNDX read FRows;
    Property columns: TMatrixNDX read FColumns;
    Property Element[row: TDynArrayNDX; column: TMatrixNDX]: SmallInt read GetElement write SetElement; default;
  end;

  TIndexNDX = 0..vMaxCol;
  TIndexElements = array[TIndexNDX] of TSmallIntArray;
  PIndexElements = ^TIndexElements;

  TIndexArray = class
  Private
    FMemAllocated: Integer;
    FCount: Integer;
    FCapacity: TIndexNDX;
    FAutosize: Boolean;
    function GetElement(Element: TIndexNDx): TSmallIntArray;
    procedure SetElement(Element: TIndexNDX; const NewValue: TSmallIntArray);
  Protected
    idxElements: PIndexElements;
  Public
    constructor Create;
    Destructor Destroy; override;
    procedure SetSize(Elements: TIndexNDX);
    procedure Expand;
    function Add(const NewValue: TSmallIntArray): Integer;
    property MemoryUsage: Integer read FMemAllocated;
    property Autosize: Boolean read FAutosize write FAutosize;
    property Capacity: TIndexNDX read FCapacity write SetSize;
    property Count: Integer read FCount;
    Property Items[Element: TIndexNDX]: TSmallIntArray read GetElement write SetElement; default;
  end;

  TCustomArray = class
  private
    FDataType: Integer;      { The variant data type }
    FArray: Pointer;      { Pointer to the array class }
    FBlankStringVal: string;
    FBlankDateVal: Variant;
    FBlankBoolVal: Word;
    FBlankCount: Integer;
    procedure UnsupportedTypeError(vType: Integer);
  protected
    function GetItem(Index: Integer): Variant;
    procedure SetItem(Index: Integer; Value: Variant);
    function GetCompProc: TCompareProc;
    procedure SetCompProc(Proc: TCompareProc);
    function GetMemberCount: Integer;
    function GetSort: Boolean;
    procedure SetSort(Value: Boolean);
    function GetDups: TDuplicates;
    procedure SetDups(Value: TDuplicates);
  public
    constructor Create(Items: Integer; VarType: Integer);
    destructor Destroy; override;
    function ConvertVar(Value: Variant): Variant;
    function Add(Value: Variant): Integer;
    function IsBlank(Index: Integer): Boolean;
    function MemoryUsage: Integer; virtual;
    procedure SetSize(size: Integer);
    function IndexOf(Value: Variant): Integer;
    procedure Assign(Value: TCustomArray; bSorted, bUnique: Boolean);
    function GetDouble(Index: Integer): Double;
    function GetCurrency(Index: Integer): Currency;
    function GetInteger(Index: Integer): Integer;
    property List: Pointer read FArray;
    property Duplicates: TDuplicates read GetDups write SetDups;
    property Sorted: Boolean read GetSort write SetSort;
    property BlankStringVal: string read FBlankStringVal write FBlankStringVal;
    property BlankDateVal: Variant read FBlankDateVal write FBlankDateVal;
    property BlankBoolVal: Word read FBlankBoolVal write FBlankBoolVal;
    property CompareProc: TCompareProc read GetCompProc write SetCompProc;
    property MemberCount: Integer read GetMemberCount;
    property DataType: Integer read FDataType;
    property BlankCount: Integer read FBlankCount;
    property Items[I: Integer]: Variant read GetItem write SetItem; default;
  end;

  TThreadCustomArray = class
  private
    FCustomArray: TCustomArray;
    FLock: TRTLCriticalSection;
  public
    constructor Create(Items: Integer; VarType: Integer);
    destructor Destroy; override;
    function Add(Item: Variant): Integer;
    function LockArray: TCustomArray;
    function GetItem(Index: Integer): Variant;
    function MemoryUsage: Integer;
    procedure UnlockArray;
  end;

  procedure SetMemoryCapacity(Value: Integer);
  function GetMemoryCapacity: Integer;

implementation

  { Helper functions }

var
  AvailableMemory: Integer;       { Memory available to allocate }
  TotalAllocatedMemory: Integer;  { Total allaocted by the array classes }

function GetAvailableMem: Integer;
var
  MemStats: TMemoryStatus;
begin
  GlobalMemoryStatus(MemStats);
  Result := MemStats.dwAvailPhys + (MemStats.dwAvailPageFile div 2);
end;

procedure SetMemoryCapacity(Value: Integer);
begin
  AvailableMemory := Value;
end;

function GetMemoryCapacity: Integer;
begin
  Result := AvailableMemory;
end;

function CheckLowCapacity(oldSize, newSize: Integer): Boolean;
var
  CheckMemSize: Integer;
begin
  Result := False;
  Dec(TotalAllocatedMemory, oldSize);
  CheckMemSize := AllocMemSize;
  Inc(CheckMemSize, newSize);
  if (CheckMemSize > AvailableMemory) then Result := True;
end;

procedure LowCapacityError;
begin
  raise ELowCapacityError.CreateRes(@sLowCapacityError);
end;

function CmpWord(var item1, item2): Integer;
var
  w1: word absolute item1;
  w2: word absolute item2;
  i1, i2: Integer;
begin
  if (w1 = 2) then
    i1 := -1
  else
    i1 := Integer(w1);

  if (w2 = 2) then
    i2 := -1
  else
    i2 := Integer(w2);

  if (i1 < i2) then
    Result := -1
  else if (i1 > i2) then
    Result := 1
  else
    Result := 0;
end;

function CmpSmallInt(var item1, item2): Integer;
var
  i1: SmallInt absolute item1;
  i2: SmallInt absolute item2;
begin
  Result := i1-i2;
end;

function CmpInteger(var item1, item2): Integer;
var
  i1: Integer absolute item1;
  i2: Integer absolute item2;
begin
  if (i1 < i2) then
    Result := -1
  else if (i1 > i2) then
    Result := 1
  else
    Result := 0;
end;

function CmpSingle(var item1, item2): Integer;
var
  i1: Single absolute item1;
  i2: Single absolute item2;
  r: Single;
begin
  r := i1-i2;
  if (Abs(r) < 1.0E-30) then
    Result := 0
  else if (r < 0) then
    Result := -1
  else
    Result := 1;
end;

function CmpDouble(var item1, item2): Integer;
var
  i1: Double absolute item1;
  i2: Double absolute item2;
  r: Double;
begin
  r := i1-i2;
  if (Abs(r) < 1.0E-100) then
    Result := 0
  else if (r < 0) then
    Result := -1
  else
    Result := 1;
end;

function CmpCurrency(var item1, item2): Integer;
var
  i1: Currency absolute item1;
  i2: Currency absolute item2;
  r:  Currency;  
begin
  r := i1-i2;  
  if (Abs(r) < 1.0E-3000) then
    Result := 0
  else if (r < 0) then
    Result := -1
  else
    Result := 1;
end;

function CmpString(var item1, item2): Integer;
var
  p1: String absolute item1;
  p2: String absolute item2;
begin
  Result := AnsiCompareStr(p1, p2);
end;

procedure ArrayDuplicateError;
begin
  raise EArrayError.CreateRes(@sDupeItem);
end;

procedure ArrayIndexError(Index: Integer);
begin
  raise EArrayError.CreateResFMT(@sArrayIndexOutOfRange, [Index]);
end;

  { TBaseArray class }

constructor TBaseArray.Create(itemcount, iSize: Integer);
begin
  inherited Create;
  FMemory := nil;
  FCapacity := 0;
  FCount := 0;
  FItemSize := iSize;
  FFlags := [afOwnsData, afAutoSize];

  SetCapacity(itemcount);
end;

destructor TBaseArray.Destroy;
begin
  if (FMemory <> nil) then
  begin
    Clear;
    FItemSize := 0;
  end;
  inherited Destroy;
end;

procedure TBaseArray.SetCount(NewCount: Integer);
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    ArrayIndexError(NewCount);
  if (NewCount > FCapacity) then
    SetCapacity(NewCount);
  if (NewCount > FCount) then
    FillMemory(GetItemPtr(FCount), (NewCount - FCount) * FItemSize, 0);    
  FCount := NewCount;
end;

procedure TBaseArray.Clear;
begin
  if (FCount <> 0) then
  begin
    InvalidateItems(0, FCount);
    FCount := 0;
    SetCapacity(0);  { Has same affect as freeing memory }
  end;
end;

procedure TBaseArray.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    ArrayIndexError(NewCapacity);
  if (NewCapacity <> FCapacity) then
  begin
    { Check for available memory }
    if CheckLowCapacity((FCapacity * FItemSize), NewCapacity * FItemSize) then
      LowCapacityError;
    ReallocMem(FMemory, NewCapacity * FItemSize);
    FillChar(Pointer(Integer(FMemory) + FCapacity * FItemSize)^, (NewCapacity - FCapacity) * FItemSize, 0);
    FCapacity := NewCapacity;
  end;
end;

procedure TBaseArray.Grow;
var
  Delta: Integer;  
begin
  if (FCapacity > 64) then
    Delta := FCapacity div 4
  else if (FCapacity > 8) then
    Delta := 16
  else
    Delta := 4;    
  SetCapacity(FCapacity + Delta);
end;

function TBaseArray.GetLimit: Integer;
begin
  if (FCount = 0) then
    Result := FCapacity
  else
    Result := FCount;
end;

procedure TBaseArray.Insert(Index: Integer; var Value);
begin
  InsertAt(Index, Value);
end;

procedure TBaseArray.InsertAt(Index: Integer; var Value);
begin
  if (Index < 0) or (Index > FCount) then
    ArrayIndexError(Index);
  { Increase the array size if needed }
  if AutoSize then
    SetCapacity(FCount+1);
  if (Index < FCount) then
  begin
    try
      MoveMemory(GetItemPtr(Index+1), GetItemPtr(Index), (FCount - Index) * FItemSize);
    except
      InternalHandleException;
    end;
  end;
  CopyFrom(Index, 1, Value);
  Inc(FCount);
end;

function TBaseArray.ValidIndex(Index: Integer): Boolean;
begin
  Result := True;  
  if (Index < 0) or (Index > FCount) then
  begin
    ArrayIndexError(Index);
    Result := False;
  end
end;

procedure TBaseArray.RemoveItem(Index: Integer);
begin
  Delete(Index);
end;

procedure TBaseArray.Delete(Index: Integer);
begin
  { We are removing only one item. }
  if ValidIndex(index) then
  begin
    InvalidateItems(Index, 1);
    Dec(FCount);
    if (Index < FCount) then
    begin
      try
        MoveMemory(GetItemPtr(Index), GetItemPtr(Index + 1), (FCount - Index) * FItemSize);
      except
      end;
    end;
  end;
end;

procedure TBaseArray.RemoveRange(atIndex, numItems: Integer);
begin
  if (numItems = 0) then
    Exit;
  if ValidateBounds(atIndex, numItems) then
  begin
    { Invalidate the items about to be deleted so a derived class can do cleanup on them. }
    InvalidateItems(atIndex, numItems);
    { Move the items above those we delete down, if there are any }
    if ((atIndex+numItems) <= FCount) then
    begin
      MoveMemory(GetItemPtr(atIndex), GetItemPtr(atIndex+numItems),
                (FCount-atIndex-numItems+1)* FItemSize);
    end;
    if AutoSize then
      SetCapacity(FCount - numItems);
  end;
end;

procedure TBaseArray.Exchange(Index1, Index2: Integer);
begin
end;

procedure TBaseArray.Sort(Compare: TCompareProc);
begin
end;

procedure TBaseArray.CopyFrom(toIndex, numItems: Integer; var Source);
begin
  if (numItems = 0) then Exit;
  if ValidateBounds(toIndex, numItems) then
  begin
    try
      InvalidateItems(toIndex, numItems);
      MoveMemory(GetItemPtr(toIndex), @Source, numItems*FItemSize);
    except
      InternalHandleException;
    end;
  end;
end;

procedure TBaseArray.PutItem(index: Integer; var Value);
begin
  if AutoSize and (FCount = FCapacity) then
    Grow;
  if ValidIndex(index) then
  begin
    try
      CopyMemory(GetItemPtr(index), @Value, FItemSize);
    except
      InternalHandleException;
    end;
    if index > FCount-1 then
      Inc(FCount);
  end;
end;

procedure TBaseArray.GetItem(index: Integer; var Value);
begin
  if ValidIndex(index) then
  begin
    try
      CopyMemory(@Value, GetItemPtr(index), FItemSize);
    except
      InternalHandleException;
    end;
  end;
end;

function TBaseArray.GetItemPtr(index: Integer): Pointer;
begin
  Result := nil;  
  if ValidIndex(index) then
    Result := Ptr(LongInt(FMemory) + (index*FItemSize));
end;

function TBaseArray.ValidateBounds(atIndex: Integer; var numItems: Integer): Boolean;
begin
  Result := True;
  if (atIndex < 0) or (atIndex > FCount) then
    Result := False;
  if Result then
    if (numItems > Succ(FCount)) or ((FCount-numItems+1) < atIndex) then
      numItems := FCount - atIndex + 1;
end;

procedure TBaseArray.InvalidateItems(atIndex, numItems: Integer);
begin
end;

function TBaseArray.HasFlag(aFlag: TArrayFlags): Boolean;
begin
   Result := aFlag in FFlags;
end;

procedure TBaseArray.SetFlag(aFlag: TArrayFlags);
begin
   Include(FFLags, aFlag);
end;

procedure TBaseArray.ClearFlag(aFlag: TArrayFlags);
begin
   Exclude(FFLags, aFlag);
end;

procedure TBaseArray.SetAutoSize(aSize: Boolean);
begin
  if (aSize = True) then
    SetFlag(afAutoSize)
  else
    ClearFlag(afAutoSize);
end;

function TBaseArray.GetAutoSize : Boolean;
begin
  Result := HasFlag(afAutoSize);
end;

function TBaseArray.IndexOf(var Item): Integer;
var
  item2: Pointer;  
begin
  if (SortOrder = tsNone) then
  begin
    for Result := 0 to Count - 1 do
    begin
      GetItem(Result, item2);
      
      if (FCompProc(item2, Item) = 0) then
        Exit;
    end;
    Result := -1;
  end
  else
    if not FindItem(Result, Item) then
      Result := -1;
end;

function TBaseArray.FindItem(var Index: Integer; var Value): Boolean;
var
  L, H, I, C: Integer;
  Value2: Pointer;  
begin
  Result := False;
  L := 0;
  H := Count - 1;  
  while (L <= H) do
  begin
    I := (L + H) shr 1;
    GetItem(I, Value2);
    C := FCompProc(Value2, Value);
    if (C < 0) then
      L := I + 1
    else
    begin
      H := I - 1;
      if (C = 0) then
      begin
        Result := True;
        if (Duplicates <> dupAccept) then
          L := I;
      end;
    end;
  end;
  Index := L;
end;

procedure TBaseArray.BlockCopy(Source: TBaseArray; fromIndex, toIndex, numitems: Integer);
begin
  if (numitems = 0) then Exit;
  if (Source is ClassType) and (ItemSize = Source.ItemSize) then
  begin
    if Source.ValidateBounds(fromIndex, numItems) then
    begin
      try
        CopyFrom(toIndex, numItems, Source.GetItemPtr(fromIndex)^);
      except
        InternalHandleException;
      end;
    end;
  end;
end;

procedure TBaseArray.InternalHandleException;
begin
  Clear;  
  raise EArrayError.CreateRes(@sGeneralArrayError);
end;

  { TIntArray }

type
  TIArray = Array[0..High(Integer) div Sizeof(Integer)-1] of Integer;
  PIntArray = ^TIArray;

constructor TIntArray.Create(itemcount, dummy: Integer);
begin
  inherited Create(itemcount, Sizeof(integer));
  FCompProc := CmpInteger;
end;

procedure TIntArray.PutItem(index: Integer ; value: Integer);
begin
  if AutoSize and (FCount = FCapacity) then inherited Grow;
  try
    PIntArray(FMemory)^[index] := value;
  except
    InternalHandleException;
  end;  
  if (index > FCount-1) then Inc(FCount);
end;

function TIntArray.GetItem(index: Integer): Integer;
begin
  Result := 0;
  if ValidIndex(index) then
  begin
    try
      Result := PIntArray(FMemory)^[index];
    except
      InternalHandleException;
    end;
  end;
end;

function TIntArray.Add(Value: Integer): Integer;
begin
  if (SortOrder = tsNone) then
    Result := FCount
  else
    if FindItem(Result, Value) then
      case Duplicates of
        dupIgnore : Exit;
        dupError  : ArrayDuplicateError;
      end;
  InsertAt(Result, Value);
end;

procedure TIntArray.Assign(Source: TPersistent);
var
  I: Integer;  
begin
  if (Source is TIntArray) then
  begin
    try
      Clear;
      for I := 0 to TBaseArray(Source).Count - 1 do
        Add(TIntArray(Source)[I]);
    finally
    end;
    Exit;
  end;
  inherited Assign(Source);
end;

function TIntArray.Find(var Index: Integer; Value: Integer): Boolean;
var
  L, H, I, C: Integer;
  Value2: Integer;  
begin
  Result := False;
  L := 0;
  H := Count - 1;
  while (L <= H) do
  begin
    I := (L + H) shr 1;
    Value2 := GetItem(I);
    C := FCompProc(Value2, Value);
    if (C < 0) then
      L := I + 1
    else
    begin
      H := I - 1;
      if (C = 0) then
      begin
        Result := True;
        if (Duplicates <> dupAccept) then
          L := I;
      end;
    end;
  end;
  Index := L;
end;

  { TSingleArray }

Type
  TRArray = Array[0..High(Integer) div Sizeof(Single)-1] of Single;
  PSingleArray = ^TRArray;

constructor TSingleArray.Create(itemcount, dummy: Integer);
begin
  inherited Create(itemcount, Sizeof(Single));
  FCompProc := CmpSingle;
end;

procedure TSingleArray.PutItem(index: Integer ; value: Single);
begin
  if AutoSize and (FCount = FCapacity) then
    inherited Grow;     
  try
    PSingleArray(FMemory)^[index] := value;
  except
    InternalHandleException;
  end;
  if (index > FCount-1) then
    Inc(FCount);
end;

function TSingleArray.GetItem(index: Integer): Single;
begin
  Result := 0;
  if ValidIndex(index) then
  begin
    try
      Result := PSingleArray(FMemory)^[index];
    except
      InternalHandleException;
    end;
  end;
end;

function TSingleArray.Add(Value: Single): Integer;
begin
  if (SortOrder = tsNone) then
    Result := FCount
  else
    if FindItem(Result, Value) then
      case Duplicates of
        dupIgnore : Exit;
        dupError  : ArrayDuplicateError;
      end;
  InsertAt(Result, Value);
end;

procedure TSingleArray.Assign(Source: TPersistent);
var
  I: Integer;  
begin
  if (Source is TSingleArray) then
  begin
    try
      Clear;
      for I := 0 to TBaseArray(Source).Count - 1 do
        Add(TSingleArray(Source)[I]);
    finally
    end;
    Exit;
  end;
  inherited Assign(Source);
end;

function TSingleArray.Find(var Index: Integer; Value: Single): Boolean;
var
  L, H, I, C: Integer;
  Value2: Single;
begin
  Result := False;
  L := 0;
  H := Count - 1;
  while (L <= H) do
  begin
    I := (L + H) shr 1;
    Value2 := GetItem(I);
    C := FCompProc(Value2, Value);
    if (C < 0) then
      L := I + 1
    else
    begin
      H := I - 1;
      if (C = 0) then
      begin
        Result := True;
        if (Duplicates <> dupAccept) then
          L := I;
      end;
    end;
  end;
  Index := L;
end;

function TSingleArray.IndexOf(var Item): Integer;
var
  item1: Single absolute Item;
  item2: Single;
begin
  if (SortOrder = tsNone) then
  begin
    for Result := 0 to Count - 1 do
    begin
      item2 := GetItem(Result);
      if (FCompProc(item2, item1) = 0) then
        Exit;
    end;
    Result := -1;
  end
  else
    if not Find(Result, item1) then
      Result := -1;
end;

  { TDoubleArray }

type
  TDArray = array[0..High(Integer) div Sizeof(Double)-1] of Double;
  PDoubleArray = ^TDArray;

constructor TDoubleArray.Create(itemcount, dummy: Integer);
begin
  inherited Create(itemcount, Sizeof(Double));
  FCompProc := CmpDouble;
end;

procedure TDoubleArray.PutItem(index: Integer ; value: Double);
begin
  if AutoSize and (FCount = FCapacity) then
    inherited Grow;
  try
    PDoubleArray(FMemory)^[index] := value;
  except
    InternalHandleException;
  end;
  if (index > FCount-1) then Inc(FCount);
end;

function TDoubleArray.GetItem(index: Integer): Double;
begin
  Result := 0;
  if ValidIndex(index) then
  begin
    try
      Result := PDoubleArray(FMemory)^[index];
    except
      InternalHandleException;
    end;
  end;
end;

function TDoubleArray.Add(Value: Double): Integer;
begin
  if (SortOrder = tsNone) then
    Result := FCount
  else
    if Find(Result, Value) then
      case Duplicates of
        dupIgnore : Exit;
        dupError  : ArrayDuplicateError;
      end;
  InsertAt(Result, Value);
end;

procedure TDoubleArray.Assign(Source: TPersistent);
var
  I: Integer;  
begin
  if (Source is TDoubleArray) then
  begin
    try
      Clear;
      for I := 0 to TBaseArray(Source).Count - 1 do
        Add(TDoubleArray(Source)[I]);
    finally
    end;
    Exit;
  end;
  inherited Assign(Source);
end;

function TDoubleArray.Find(var Index: Integer; Value: Double): Boolean;
var
  L, H, I, C: Integer;
  Value2: Double; 
begin
  Result := False;
  L := 0;
  H := Count - 1;
  while (L <= H) do
  begin
    I := (L + H) shr 1;
    Value2 := GetItem(I);
    C := FCompProc(Value2, Value);
    if (C < 0) then
      L := I + 1
    else
    begin
      H := I - 1;
      if (C = 0) then
      begin
        Result := True;
        if (Duplicates <> dupAccept) then
          L := I;
      end;
    end;
  end;
  Index := L;
end;

function TDoubleArray.IndexOf(var Item): Integer;
var
  item1: Double absolute Item;
  item2: Double; 
begin
  if (SortOrder = tsNone) then
  begin
    for Result := 0 to Count - 1 do
    begin
      item2 := GetItem(Result);
      if (FCompProc(item2, item1) = 0) then
        Exit;
    end;
    Result := -1;
  end
  else
    if not Find(Result, item1) then
      Result := -1;
end;

  { TCurrencyArray }

type
  TCArray = array[0..High(Integer) div Sizeof(Currency)-1] of Currency;
  PCurrencyArray = ^TCArray;

constructor TCurrencyArray.Create(itemcount, dummy: Integer);
begin
  inherited Create(itemcount, Sizeof(Currency));
  FCompProc := CmpCurrency;
end;

procedure TCurrencyArray.PutItem(index: Integer ; value: Currency);
begin
  if AutoSize and (FCount = FCapacity) then inherited Grow;
  try
    PCurrencyArray(FMemory)^[index] := value;
  except
    InternalHandleException;
  end;
  if (index > FCount-1) then Inc(FCount);
end;

function TCurrencyArray.GetItem(index: Integer): Currency;
begin
  Result := 0;
  if ValidIndex(index) then
  begin
    try
      Result := PCurrencyArray(FMemory)^[index];
    except
      InternalHandleException;
    end;
  end;
end;

function TCurrencyArray.Add(Value: Currency): Integer;
begin
  if (SortOrder = tsNone) then
    Result := FCount
  else
    if Find(Result, Value) then
      case Duplicates of
        dupIgnore : Exit;
        dupError  : ArrayDuplicateError;
      end;
  InsertAt(Result, Value);
end;

procedure TCurrencyArray.Assign(Source: TPersistent);
var
  I: Integer;
begin
  if (Source is TCurrencyArray) then
  begin
    try
      Clear;
      for I := 0 to TBaseArray(Source).Count - 1 do
        Add(TCurrencyArray(Source)[I]);
    finally
    end;
    Exit;
  end;
  inherited Assign(Source);
end;

function TCurrencyArray.Find(var Index: Integer; Value: Currency): Boolean;
var
  L, H, I, C: Integer;
  Value2: Currency;
begin
  Result := False;
  L := 0;
  H := Count - 1;
  while (L <= H) do
  begin
    I := (L + H) shr 1;
    Value2 := GetItem(I);
    C := FCompProc(Value2, Value);
    if (C < 0) then
      L := I + 1
    else
    begin
      H := I - 1;
      if (C = 0) then
      begin
        Result := True;
        if (Duplicates <> dupAccept) then
          L := I;
      end;
    end;
  end;
  Index := L;
end;

function TCurrencyArray.IndexOf(var Item): Integer;
var
  item1: Currency absolute Item;
  item2: Currency; 
begin
  if (SortOrder = tsNone) then
  begin
    for Result := 0 to Count - 1 do
    begin
      item2 := GetItem(Result);
      if (FCompProc(item2, item1) = 0) then
        Exit;
    end;
    Result := -1;
  end
  else
    if not Find(Result, item1) then
      Result := -1;
end;

  { TSmallIntArray }

type
  TSIArray = array[0..High(Integer) div Sizeof(SmallInt)-1] of SmallInt;
  PSmallIntArray = ^TSIArray;

constructor TSmallIntArray.Create(itemcount, dummy: Integer);
begin
  inherited Create(itemcount, Sizeof(SmallInt));
  FCompProc := CmpSmallInt;
end;

procedure TSmallIntArray.PutItem(index: Integer ; value: SmallInt);
begin
  if AutoSize and (FCount = FCapacity) then
    inherited Grow;
  try
    PSmallIntArray(FMemory)^[index] := value;
  except
    InternalHandleException;
  end;
  if index > FCount-1 then
    Inc(FCount);
end;

function  TSmallIntArray.GetItem(index: Integer): SmallInt;
begin
  Result := 0;
  if ValidIndex(index) then
  begin
    try
      Result := PSmallIntArray(FMemory)^[index];
    except
      InternalHandleException;
    end;
  end;
end;

function TSmallIntArray.Add(Value: SmallInt): Integer;
begin
  if (SortOrder = tsNone) then
    Result := FCount
  else
    if FindItem(Result, Value ) then
      case Duplicates of
        dupIgnore : Exit;
        dupError  : ArrayDuplicateError;
      end;
  InsertAt(Result, Value);
end;

procedure TSmallIntArray.Assign(Source: TPersistent);
var
  I: Integer; 
begin
  if (Source is TSmallIntArray) then
  begin
    try
      Clear;
      for I := 0 to TBaseArray(Source).Count - 1 do
        Add(TSmallIntArray(Source)[I]);
    finally
    end;
    Exit;
  end;
  inherited Assign(Source);
end;

  { TWordArray }

type
  TArrayWord = array[0..High(Integer) div Sizeof(Word)-1] of Word;
  PWordArray = ^TArrayWord;

constructor TWordArray.Create(itemcount, dummy: Integer);
begin
  inherited Create(itemcount, Sizeof(Word));
  FCompProc := CmpWord;
end;

procedure TWordArray.PutItem(index: Integer ; value: Word);
begin
  if AutoSize and (FCount = FCapacity) then
    inherited Grow;
  try
    PWordArray(FMemory)^[index] := value;
  except
    InternalHandleException;
  end;
  if (index > FCount-1) then
    Inc(FCount);
end;

function TWordArray.GetItem(index: Integer): Word;
begin
  Result := 0;
  if ValidIndex(index) then
  begin
    try
      Result := PWordArray(FMemory)^[index];
    except
      InternalHandleException;
    end;
  end;
end;

function TWordArray.Add(Value: Word): Integer;
begin
  if (SortOrder = tsNone) then
    Result := FCount
  else
    if Find(Result, Value) then
      case Duplicates of
        dupIgnore : Exit;
        dupError  : ArrayDuplicateError;
      end;
  InsertAt(Result, Value);
end;

procedure TWordArray.Assign(Source: TPersistent);
var
  I: Integer;
begin
  if (Source is TWordArray) then
  begin
    try
      Clear;
      for I := 0 to TBaseArray(Source).Count - 1 do
        Add(TWordArray(Source)[I]);
    finally
    end;
    Exit;
  end;
  inherited Assign(Source);
end;

function TWordArray.Find(var Index: Integer; Value: Word): Boolean;
var
  L, H, I, C: Integer;
  Value2: Word;
begin
  Result := False;
  L := 0;
  H := Count - 1;
  while (L <= H) do
  begin
    I := (L + H) shr 1;
    Value2 := GetItem(I);
    C := FCompProc(Value2, Value);
    if (C < 0) then
      L := I + 1
    else
    begin
      H := I - 1;
      if (C = 0) then
      begin
        Result := True;
        if (Duplicates <> dupAccept) then
          L := I;
      end;
    end;
  end;
  Index := L;
end;

function TWordArray.IndexOf(var Item): Integer;
var
  item1: Word absolute Item;
  item2: Word;
begin
  if (SortOrder = tsNone) then
  begin
    for Result := 0 to Count - 1 do
    begin
      item2 := GetItem(Result);
      if (FCompProc(item2, item1) = 0) then
        Exit;
    end;
    Result := -1;
  end
  else
    if not Find(Result, item1) then
      Result := -1;
end;

  { TPointerArray }

Type
  TPArray = Array [0..High(Integer) div Sizeof(Pointer)-1] Of Pointer;
  PPArray = ^TPArray;

constructor TPointerArray.Create(itemcount, dummy: Integer);
begin
  inherited Create(itemcount, Sizeof(Pointer));
  FFlags := [afAutoSize];
end;

procedure TPointerArray.CopyFrom(var Source; toIndex, numItems: Integer);
var
  i: Integer;
  p: PPArray;
  arr: TPArray absolute Source;
begin
  if (numItems = 0) then
    Exit;
  if ValidateBounds(toIndex, numItems) then
  begin
    InvalidateItems(toIndex, numItems);
    p := PPArray(FMemory);
    for i:= 0 to Pred(numItems) Do
      p^[toIndex+i] := CloneItem(arr[i]);
    FSortOrder := tsNone;
  end;
end;

procedure TPointerArray.CopyTo(var Dest; fromIndex, numItems: Integer);
var
  i: Integer;
  p: PPArray;
  arr: TPArray absolute Dest;
begin
  if (numItems = 0) then
    Exit;
  if ValidateBounds(fromIndex, numItems) then
  begin
    p := PPArray(FMemory);
    for i:= 0 to Pred(numItems) Do
      arr[i] := CloneItem(p^[fromIndex+i]);
  end;
end;

procedure TPointerArray.PutData(index: Integer ; value: Pointer);
begin
  if ValidIndex(index) then
  begin
    if (PPArray(FMemory)^[index] <> nil) and HasFlag(afOwnsData)then
      FreeItem(PPArray(FMemory)^[index]);
    PPArray(FMemory)^[index] := CloneItem(value);
    FSortOrder := tsNone;
  end;
end;

function TPointerArray.GetData(index: Integer): Pointer;
begin
  if ValidIndex(index) then
    Result := PPArray(FMemory)^[index]
  else
    Result := nil;
end;

procedure TPointerArray.FreeItem(item: Pointer);
begin
  { this is a nop for this class since we do not know what item points to }
end;

procedure TPointerArray.InvalidateItems(atIndex, numItems: Integer);
var
  n: Integer;
  p: Pointer;
begin
  if (numItems > 0) and HasFlag(afOwnsData) then
  begin
    if ValidateBounds(atIndex, numItems) then
    begin
      for n := atIndex to Pred(numItems+atIndex) Do
      begin
        p := AsPtr[n];
        if (p <> nil) then
        begin
          FreeItem(p);
          p := nil;
          PutItem(n, p);
        end;
      end;
    end;
  end;
end;

function TPointerArray.CloneItem(item: Pointer): Pointer;
begin
  Result := item;
end;

  { TStringArray }

type
  PStringItem = ^TStringItem;
  TStringItemList = array[0..MaxListSize] of TStringItem;
  PStringItemList = ^TStringItemList;

constructor TStringArray.Create(itemcount, dummy: Integer);
begin
  inherited Create(itemcount, Sizeof(TStringItem));
  FFlags := [afAutoSize];
  FCompProc := CmpString;   { Note: if the language driver is available then we use it for compares. }
end;

function TStringArray.Add(const S: String): Integer;
begin
  if (SortOrder = tsNone) then
    Result := FCount
  else
    if Find(S, Result) then
      case Duplicates of
        dupIgnore : Exit;
        dupError  : raise EArrayError.CreateRes(@SDuplicateString);
      end;
  InsertItem(Result, S);
end;

procedure TStringArray.Exchange(Index1, Index2: Integer);
begin
  if (Index1 < 0) or (Index1 >= FCount) or
  (Index2 < 0) or (Index2 >= FCount) then
    ArrayIndexError(Index1);    
  ExchangeItems(Index1, Index2);
end;

procedure TStringArray.ExchangeItems(Index1, Index2: Integer);
var
  Temp: Integer;
  Item1, Item2: PStringItem;  
begin
  Item1 := @PStringItemList(FMemory)^[Index1];
  Item2 := @PStringItemList(FMemory)^[Index2];
  Temp := Integer(Item1^.FString);
  Integer(Item1^.FString) := Integer(Item2^.FString);
  Integer(Item2^.FString) := Temp;
  Temp := Integer(Item1^.FObject);
  Integer(Item1^.FObject) := Integer(Item2^.FObject);
  Integer(Item2^.FObject) := Temp;
end;

function TStringArray.Find(S: string; var Index: Integer): Boolean;
var
  L, H, I: Integer;
  C: SmallInt;       { for compatability with the BDE LD }
begin
  Result := False;
  L := 0;
  H := Count - 1;
  while (L <= H) do
  begin
    I := (L + H) shr 1;
    C := SmallInt(FCompProc(PStringItemList(FMemory)^[I].FString, S));
    if (C < 0) then
      L := I + 1
    else
    begin
      H := I - 1;
      if (C = 0) then
      begin
        Result := True;
        if (Duplicates <> dupAccept) then
          L := I;
      end;
    end;
  end;
  Index := L;
end;

function TStringArray.GetObject(Index: Integer): TObject;
begin
  Result := nil;
  if ValidIndex(Index) then
    Result := PStringItemList(FMemory)^[Index].FObject;
end;

procedure TStringArray.Grow;
var
  Delta: Integer;
begin
  if (FCapacity > 64) then
    Delta := FCapacity div 4
  else if (FCapacity > 8) then
    Delta := 16
  else
    Delta := 4;
  inherited SetCapacity(FCapacity + Delta);
end;

function TStringArray.IndexOf(var Item): Integer;
var
  S1: string;
  S2: string absolute Item;
begin
  if (SortOrder = tsNone) then
  begin
    for Result := 0 to Count - 1 do
    begin
      S1 := GetString(Result);
      if (SmallInt(FCompProc(S1, S2)) = 0) then
        Exit;
    end;
    Result := -1;
  end
  else
    if not Find(S2, Result) then
      Result := -1;
end;

procedure TStringArray.Insert(Index: Integer; var Value);
var
  S: string;
begin
  S := Variant(Value);
  if (SortOrder <> tsNone) then
    raise EArrayError.CreateRes(@SSortedListError);
  if (Index < 0) or (Index > FCount) then
    ArrayIndexError(Index);
  InsertItem(Index, S);
end;

procedure TStringArray.InsertItem(Index: Integer; const S: string);
begin
  if (FCount = FCapacity) then
    Grow;
  if (Index < FCount) then
  begin
    try
      System.Move(PStringItemList(FMemory)^[Index], PStringItemList(FMemory)^[Index + 1],
        (FCount - Index) * SizeOf(TStringItem));
    except
      InternalHandleException;
    end;
  end;
  try
    PStringItemList(FMemory)^[Index].FObject := nil;
    Pointer(PStringItemList(FMemory)^[Index].FString) := nil;
    PStringItemList(FMemory)^[Index].FString := S;
  except
    InternalHandleException;
  end;
  Inc(FCount);
end;

procedure TStringArray.PutString(Index: Integer; const S: string);
begin
  { Sorted items must be added }
  if (SortOrder <> tsNone) then
    raise EArrayError.CreateRes(@SSortedListError);
  if ValidIndex(Index) then
  begin
    try
      PStringItemList(FMemory)^[Index].FString := S;
    except
      InternalHandleException;
    end;
  end;
end;

function TStringArray.GetString(Index: Integer): string;
begin
 {$IFOPT R+}
  if ValidIndex(Index) then
 {$ENDIF}
  begin
    try
      Result := PStringItemList(FMemory)^[Index].FString;
    except
      Clear;
      raise;
    end;
  end;
end;

procedure TStringArray.PutObject(Index: Integer; AObject: TObject);
begin
  if ValidIndex(Index) then
    PStringItemList(FMemory)^[Index].FObject := AObject;
end;

procedure TStringArray.QuickSort(L, R: Integer);
var
  I, J: Integer;
  P: string;
begin
  repeat
    I := L;
    J := R;
    P := PStringItemList(FMemory)^[(L + R) shr 1].FString;
    repeat
      while (SmallInt(FCompProc(PStringItemList(FMemory)^[I].FString, P)) < 0) do
        Inc(I);
      while (SmallInt(FCompProc(PStringItemList(FMemory)^[J].FString, P)) > 0) do
        Dec(J);
      if (I <= J) then
      begin
        ExchangeItems(I, J);
        Inc(I);
        Dec(J);
      end;
    until (I > J);
    if (L < J) then
      QuickSort(L, J);
    L := I;
  until (I >= R);
end;

procedure TStringArray.Sort(Compare: TCompareProc);
begin
  if (SortOrder <> tsNone) and (Count > 1) then
    QuickSort(0, Count - 1);
end;

procedure TStringArray.AddStrings(Strings: TStringArray);
var
  I: Integer;
begin
  try
    for I := 0 to Strings.Count - 1 do
      Add(Strings.Strings[I]);
  finally
  end;
end;

procedure TStringArray.Assign(Source: TPersistent);
begin
  if (Source is TStringArray) then
  begin
    try
      Clear;
      AddStrings(TStringArray(Source));
    finally
    end;
    Exit;
  end;
  inherited Assign(Source);
end;

procedure TStringArray.InvalidateItems(atIndex, numItems: Integer);
begin
  Finalize(PStringItemList(FMemory)^[atIndex], numItems);
end;

  { TCustomArray }

function VariantTypeToName(vType: Integer): string;
begin
  case vType of
    varEmpty    : Result := 'Empty';     { Do not localize }
    varNull     : Result := 'Null';      { Do not localize }
    varOleStr   : Result := 'OleStr';    { Do not localize }
    varDispatch : Result := 'Dispatch';  { Do not localize }
    varError    : Result := 'Error';     { Do not localize }
    varVariant  : Result := 'Variant';   { Do not localize }
    varByte     : Result := 'Byte';      { Do not localize }
    varTypeMask : Result := 'TypeMask';  { Do not localize }
    varArray    : Result := 'Array';     { Do not localize }
    varByRef    : Result := 'ByRef';     { Do not localize }
    else
      Result := 'Unknown';            { Do not localize }
  end;
end;

constructor TCustomArray.Create(Items: Integer; VarType: Integer);
begin
  FDataType       := VarType;
  FBlankDateVal   := -650000;  { Satisfies Variants, Lowest TDateTime is actually -693593 }
  FBlankStringVal := '0';
  FBlankBoolVal   := 2;
  FBlankCount     := 0;

  case VarType of
    varSmallint: FArray := TSmallIntArray.Create(Items, 0);
    varInteger:  FArray := TIntArray.Create(Items, 0);
    varDate,
    varDouble:   FArray := TDoubleArray.Create(Items, 0);
    varBoolean:  FArray := TWordArray.Create(Items, 0);
    varString:   FArray := TStringArray.Create(Items, 0);
    varSingle:   FArray := TSingleArray.Create(Items, 0);
    varCurrency: FArray := TCurrencyArray.Create(Items, 0);
    else
      UnsupportedTypeError(FDataType);
  end;
end;

destructor TCustomArray.Destroy;
begin
  if Assigned(FArray) then
  begin
    TBaseArray(FArray).Destroy;
    FArray := nil;
  end;
  FDataType := 0;
  inherited Destroy;
end;

procedure TCustomArray.UnsupportedTypeError(vType: Integer);
var
  sDataType: string;
begin
  sDataType := VariantTypeToName(vType);
  raise EUnsupportedTypeError.CreateResFmt(@sUnsupportedDataType, [sDataType]);
end;

function TCustomArray.GetMemberCount: Integer;
begin
  Result :=  TBaseArray(FArray).Count;
end;

function TCustomArray.GetItem(Index: Integer): Variant;
var
  V: Variant;  
begin
  case FDataType of
    varSmallint: Result := TSmallIntArray(FArray)[Index];
    varDate:
    begin
      V := TDoubleArray(FArray)[Index];
      Result := VarAsType(V, varDate)
    end;

    varInteger:  Result := TIntArray(FArray)[Index];
    varDouble:   Result := TDoubleArray(FArray)[Index];
    varBoolean:  Result := TWordArray(FArray)[Index];
    varString:   Result := TStringArray(FArray).GetString(Index);
    varSingle:   Result := TSingleArray(FArray)[Index];
    varCurrency: Result := TCurrencyArray(FArray)[Index];
    else
      UnsupportedTypeError(FDataType);
  end;
end;

function TCustomArray.GetDouble(Index: Integer): Double;
begin
  Result := TDoubleArray(FArray).GetItem(index);
end;

function TCustomArray.GetCurrency(Index: Integer): Currency;
begin
  Result := TCurrencyArray(FArray).GetItem(index);
end;

function TCustomArray.GetInteger(Index: Integer): Integer;
begin
  Result := TIntArray(FArray).GetItem(index);
end;

function TCustomArray.IsBlank(Index: Integer): Boolean;
begin
  case FDataType of
    varDate:     Result := (TDoubleArray(FArray)[Index] = BlankDateVal);
    varString:   Result := (TStringArray(FArray).GetString(Index) = BlankStringVal);
    varBoolean:  Result := (TWordArray(FArray)[Index] = BlankBoolVal);
    else
      Result := False;
  end;
end;

procedure TCustomArray.SetItem(Index: Integer; Value: Variant);
var
  VarData: TVarData;
begin
  VarData := TVarData(Value);
  { Handle blank values and misc conversion problems }
  if (FDataType <> VarData.vType) then
  begin
     case VarData.vType of
       varEmpty,
       varNull :       begin         Inc(FBlankCount);         case FDataType of           varDate    : Value := VarAsType(BlankDateVal, varDouble);           varString  : Value := VarAsType(BlankStringVal, varString);           varBoolean : Value := VarAsType(BlankBoolVal, varSmallInt);           else             Value := VarAsType(0, FDataType);         end;       end;       varDouble : if (FDataType = varCurrency) then                     Value := VarAsType(Value, varCurrency);     end;  end;  case FDataType of
    varSmallint: TSmallIntArray(FArray)[Index] := Value.VSmallInt;
    varDate:     TDoubleArray(FArray)[Index] := TVarData(Value).VDouble;
    varInteger:  TIntArray(FArray)[Index] := Value;
    varDouble:   TDoubleArray(FArray)[Index] := Value;
    varBoolean:  TWordArray(FArray)[Index] := Value;
    varString:   TStringArray(FArray).Insert(Index, Value);
    varSingle:   TSingleArray(FArray)[Index] := Value;
    varCurrency: TCurrencyArray(FArray)[Index] := Value;
    else
      UnsupportedTypeError(FDataType);
  end;
end;

function TCustomArray.IndexOf(Value: Variant): Integer;
var
  vConv: Variant;
  strVal: String;
  iVal: Integer;
  siVal: SmallInt;
  dVal: Double;
  sgVal: Single;
  cVal: Currency;
  bVal: Word;  
begin
  { This should raise an array index exception if below fails }
  Result := -1;
  case FDataType of
    varSmallint:
    begin
      VarCast(vConv, Value, varSmallInt);
      siVal := SmallInt(TVarData(vConv).VSmallint);
      Result := TBaseArray(FArray).IndexOf(siVal);
    end;
    varDate,
    varDouble:
    begin
      VarCast(vConv, Value, varDouble);
      dVal := Double(TVarData(vConv).VDouble);
      Result := TBaseArray(FArray).IndexOf(dVal);
    end;
    varInteger:
    begin
      VarCast(vConv, Value, varInteger);
      iVal := Integer(TVarData(vConv).VInteger);
      Result := TBaseArray(FArray).IndexOf(iVal);
    end;
    varString:
    begin
      VarCast(vConv, Value, varString);
      strVal := String(TVarData(vConv).VString);
      Result := TStringArray(FArray).IndexOf(strVal)
    end;
    varSingle:
    begin
      VarCast(vConv, Value, varSingle);
      sgVal := Single(TVarData(vConv).VSingle);
      Result := TBaseArray(FArray).IndexOf(sgVal);
    end;
    varCurrency:
    begin
      VarCast(vConv, Value, varCurrency);
      cVal := Currency(TVarData(vConv).VCurrency);
      Result := TCurrencyArray(FArray).IndexOf(cVal);
    end;
    varBoolean:
    begin
      if (Value = BlankBoolVal) then
      begin
        bVal := BlankBoolVal;
      end
      else
      begin
        VarCast(vConv, Value, varBoolean);
        bVal := Word(TVarData(vConv).VBoolean);
      end;
      Result := TWordArray(FArray).IndexOf(bVal);
    end;
    else
      UnsupportedTypeError(FDataType);
  end;
end;

procedure TCustomArray.Assign(Value: TCustomArray; bSorted, bUnique: Boolean);
begin
  if bSorted then
    TBaseArray(FArray).SortOrder := tsDescending;
  if bUnique then
    TBaseArray(FArray).Duplicates := dupIgnore;
  case FDataType of
    varString   : TStringArray(FArray).Assign(TStringArray(Value.FArray));
    varSmallint : TSmallIntArray(FArray).Assign(TSmallIntArray(Value.FArray));
    varInteger  : TIntArray(FArray).Assign(TIntArray(Value.FArray));
    varDate,
    varDouble   : TDoubleArray(FArray).Assign(TDoubleArray(Value.FArray));
    varBoolean  : TWordArray(FArray).Assign(TWordArray(Value.FArray));
    varSingle   : TSingleArray(FArray).Assign(TSingleArray(Value.FArray));
    varCurrency : TCurrencyArray(FArray).Assign(TCurrencyArray(Value.FArray));
    else
      UnsupportedTypeError(FDataType);
  end;
end;

function TCustomArray.Add(Value: Variant): Integer;
var
  VarData: TVarData; 
begin
  VarData := TVarData(Value);
  Result := -1;  { Error }
  { Handle blank values and misc conversion problems }
  if (FDataType <> VarData.vType) then
  begin
     case VarData.vType of
       varEmpty,
       varNull :       begin         Inc(FBlankCount);         case FDataType of           varDate    : Value := VarAsType(BlankDateVal, varDouble);           varString  : Value := VarAsType(BlankStringVal, varString);           varBoolean : Value := VarAsType(BlankBoolVal, varSmallInt);           else             Value := VarAsType(0, FDataType);         end;       end;       varDouble : if (FDataType = varCurrency) then                     Value := VarAsType(Value, varCurrency);     end;  end;  case FDataType of
    varString   : Result := TStringArray(FArray).Add(VarToStr(Value));
    varSmallint : Result := TSmallIntArray(FArray).Add(TVarData(Value).VSmallint);
    varInteger  : Result := TIntArray(FArray).Add(TVarData(Value).VInteger);
    varDate,
    varDouble   : Result := TDoubleArray(FArray).Add(TVarData(Value).VDouble);
    varBoolean  : Result := TWordArray(FArray).Add(Word(TVarData(Value).VBoolean));
    varSingle   : Result := TSingleArray(FArray).Add(TVarData(Value).VSingle);
    varCurrency : Result := TCurrencyArray(FArray).Add(TVarData(Value).VCurrency);
    else
      UnsupportedTypeError(FDataType);
  end;
end;

function TCustomArray.GetCompProc: TCompareProc;
begin
  Result := TBaseArray(FArray).CompareProc;
end;

procedure TCustomArray.SetCompProc(Proc: TCompareProc);
begin
  TBaseArray(FArray).CompareProc := Proc;
end;

procedure TCustomArray.SetSize(size: Integer);
begin
  TBaseArray(FArray).SetCapacity(size);
end;

function TCustomArray.MemoryUsage: Integer;
begin
  Result := (TBaseArray(FArray).Capacity * TBaseArray(FArray).ItemSize);
end;

function  TCustomArray.GetSort: Boolean;
begin
  Result := (TBaseArray(FArray).SortOrder) <> tsNone;
end;

procedure TCustomArray.SetSort(Value: Boolean);
begin
  TBaseArray(FArray).SortOrder := tsDescending;
end;

function  TCustomArray.GetDups: TDuplicates;
begin
  Result := TBaseArray(FArray).Duplicates;
end;

procedure TCustomArray.SetDups(Value: TDuplicates);
begin
  TBaseArray(FArray).Duplicates := Value;
end;

function TCustomArray.ConvertVar(Value: Variant): Variant;
begin
  case TVarData(Value).vType of
    varNull:
    begin
      case DataType of
        varDate     : Result := VarAsType(BlankDateVal, DataType);
        varString   : Result := VarAsType(BlankStringVal, DataType);
        varBoolean  : Result := VarAsType(BlankBoolVal, DataType);
        else
          Result := VarAsType(0, DataType);
      end;
    end;
    varSmallint,
    varInteger,
    varDate,
    varDouble,
    varBoolean,
    varString,
    varSingle,
    varCurrency: Result := VarAsType(Value, DataType);
    else
      UnsupportedTypeError(TVarData(Value).vType);
  end;
end;

  { TTwoDimArray }

constructor TTwoDimArray.Create;
begin
  inherited Create;
  FRows    := 0;
  FColumns := 0;
  mtxElements := nil;
end;

destructor TTwoDimArray.Destroy;
var
  col: TMatrixNDX;  
begin
  if Assigned(mtxElements) then
  begin
    try
      for col := FColumns-1 downto 0 do
      begin
        dec(FMemAllocated, mtxElements^[col].FCapacity);
        mtxElements^[col].Free;
        mtxElements^[col] := nil;
      end;
    finally
      FreeMem(mtxElements, FMemAllocated);
    end;
  end;
  inherited Destroy;
end;

procedure TTwoDimArray.SetSize(NumRows : TDynArrayNDX; NumColumns : TMatrixNDX);
var
  col: TMatrixNDX;  
begin
  FRows := NumRows;
  FColumns := NumColumns;
  FMemAllocated := FColumns*sizeof(TSmallIntArray);
  if ((FMemAllocated + TotalAllocatedMemory) > AvailableMemory) then
    LowCapacityError;
  GetMem(mtxElements, FColumns*sizeof(TSmallIntArray));
  Inc(TotalAllocatedMemory, FMemAllocated);
  { acquire memory for each column of the matrix }
  for col := 0 to FColumns-1 do
  begin
    mtxElements^[col] := TSmallIntArray.Create(FRows, 0);
    inc(FMemAllocated, mtxElements^[col].FCapacity);
  end;
end;

function TTwoDimArray.GetElement(row : TDynArrayNDX; column : TMatrixNDX) : SmallInt;
begin
  if (row > FRows) then
    raise EDynArrayRangeError.CreateResFMT(@sRowOutOfRange, [row]);
  if (column > FColumns) then
    raise EDynArrayRangeError.CreateResFMT(@sColOutOfRange, [column]);
  Result := mtxElements^[column].Items[row];
end;

procedure TTwoDimArray.SetElement(row : TDynArrayNDX; column : TMatrixNDX; const NewValue : SmallInt);
begin
  if (row > FRows) then
    raise EDynArrayRangeError.CreateResFMT(@sRowOutOfRange, [row]);
  if (column > FColumns) then
    raise EDynArrayRangeError.CreateResFMT(@sColOutOfRange, [column]);
  mtxElements^[column].Items[row] := NewValue;
end;

  { TIndexArray }

constructor TIndexArray.Create;
begin
  inherited Create;
  FCapacity := 0;
  FCount := 0;
  FMemAllocated := 0;
  FAutosize := False;
  idxElements := nil;
end;

destructor TIndexArray.Destroy;
var
  Idx: TIndexNDX;  
begin
  if Assigned(idxElements) then
  begin
    try
      if (FCount > 0) then
      begin
        for Idx := FCount-1 downto 0 do
        begin
          dec(FMemAllocated, idxElements^[Idx].FCapacity);
          idxElements^[Idx].Free;
          idxElements^[Idx] := nil;
        end;
      end;
    finally
      FreeMem(idxElements, FMemAllocated);
    end;
  end;
  inherited Destroy;
end;

procedure TIndexArray.SetSize(Elements: TIndexNDX);
begin
  FCapacity := Elements;
  FMemAllocated := FCapacity*sizeof(TSmallIntArray);
  if ((FMemAllocated + TotalAllocatedMemory) > AvailableMemory) then
    LowCapacityError;
  GetMem(idxElements, FCapacity*sizeof(TSmallIntArray));
  Inc(TotalAllocatedMemory, FMemAllocated);
end;

procedure TIndexArray.expand;
var
  Delta, NewCapacity, OldCapacity: Integer;  
begin
  if (FCapacity > 64) then
    Delta := FCapacity div 4
  else if (FCapacity > 8) then
    Delta := 16
  else
    Delta := 4;
  NewCapacity := FCapacity + Delta;
  OldCapacity := FCapacity;
  if (NewCapacity <> FCapacity) then
  begin
    try
      FMemAllocated := NewCapacity*sizeof(TSmallIntArray);
      if CheckLowCapacity(OldCapacity*sizeof(TSmallIntArray), newCapacity*sizeof(TSmallIntArray)) then
        LowCapacityError;
      ReallocMem(idxElements, NewCapacity*sizeof(TSmallIntArray));
      Inc(TotalAllocatedMemory, NewCapacity*sizeof(TSmallIntArray));
    except
      FreeMem(idxElements);
      raise;
    end;
    FCapacity := NewCapacity;
  end;
end;

function TIndexArray.GetElement(Element : TIndexNDX) : TSmallIntArray;
begin
  if (Element > FCapacity) then
    ArrayIndexError(Element);
  Result := idxElements^[Element];
end;

procedure TIndexArray.SetElement(Element : TIndexNDX; const NewValue: TSmallIntArray);
begin
  if AutoSize and (FCount = FCapacity) then
    Expand;
  Assert(FCapacity >= FCount, Format('FCount = %d FCapacity = %d', [FCount, FCapacity]));
  if (Element > FCapacity) then
    ArrayIndexError(Element);
  idxElements^[Element] := NewValue;
  inc(FMemAllocated, NewValue.FCapacity);
  if (Element > FCount-1) then
    Inc(FCount);
end;

function TIndexArray.Add(const NewValue: TSmallIntArray): Integer;
begin
  if AutoSize and (FCount = FCapacity) then
    Expand;
  Assert(FCapacity >= FCount, Format('FCount = %d FCapacity = %d', [FCount, FCapacity]));
  idxElements^[FCount] := NewValue;
  inc(FMemAllocated, NewValue.FCapacity);
  Inc(FCount);
  Result := FCount;
end;

  { TThreadCustomArray }

constructor TThreadCustomArray.Create(Items: Integer; VarType: Integer);
begin
  inherited Create;
  InitializeCriticalSection(FLock);
  FCustomArray := TCustomArray.Create(Items, VarType);
end;

destructor TThreadCustomArray.Destroy;
begin
  LockArray;    // Make sure nobody else is inside the list.
  try
    FCustomArray.Free;
    inherited Destroy;
  finally
    UnlockArray;
    DeleteCriticalSection(FLock);
  end;
end;

function TThreadCustomArray.Add(Item: Variant): Integer;
begin
  LockArray;
  Result := -1;
  try
    if (FCustomArray.IndexOf(Item) = -1) then
      Result := FCustomArray.Add(Item);
  finally
    UnlockArray;
  end;
end;

function TThreadCustomArray.LockArray: TCustomArray;
begin
  EnterCriticalSection(FLock);
  Result := FCustomArray;
end;

function TThreadCustomArray.GetItem(Index: Integer): Variant;
begin
  LockArray;
  try
    Result := FCustomArray.GetItem(Index);
  finally
    UnlockArray;
  end;
end;

function TThreadCustomArray.MemoryUsage: Integer;
begin
  LockArray;
  try
    Result := FCustomArray.MemoryUsage;
  finally
    UnlockArray;
  end;    
end;

procedure TThreadCustomArray.UnlockArray;
begin
  LeaveCriticalSection(FLock);
end;


initialization
  { determine available memory }
  AvailableMemory := GetAvailableMem;
  TotalAllocatedMemory := 0;

end.
