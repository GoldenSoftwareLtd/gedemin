// ShlTanya, 09.02.2019

{++

  Copyright (c) 2002-2015 by Golden Software of Belarus, Ltd

  Module

    gd_KeyAssoc.pas

  Abstract

    Sorted array of integers. Association between integer value
    and string, integer.

  Author

    Andrei Kireev (16-Feb-02)

  Contact address

    andreik@gsbelarus.com
    http://gsbelarus.com

  Revisions history

    1.00    16-Feb-02    andreik      Initial version.
    1.01    15-Jun-02    DAlex        Add TgdKeyIntAndStrAssoc.

--}

unit gd_KeyAssoc;

interface

uses
  Classes, gdcBaseInterface, dialogs;

type
  // sorted array of integer keys
  // duplicates are not allowed
  TgdKeyArray = class
  private
    FArray: array of TID;
    FCount: Integer;
    FSize: Integer;
    FOnChange: TNotifyEvent;
    FWasModified: Boolean;
    FSorted: Boolean;

    function GetCount: Integer;
    function GetKeys(Index: Integer): TID;
    function GetSize: Integer;
    procedure SetSorted(const Value: Boolean);
    function GetCommaText: String;
    procedure SetCommaText(const Value: String);

  protected
    procedure Changed; virtual;

    procedure InsertItem(const Index: Integer; const Value: TID); virtual;
    procedure Grow; virtual;
    procedure CheckIndex(const Index: Integer);

  public
    constructor Create;
    destructor Destroy; override;

    function Add(const Value: TID;
      const IgnoreDuplicates: Boolean = False): Integer;
    function IndexOf(const Value: TID): Integer;
    function Remove(const Value: TID): Integer;
    procedure Delete(const Index: Integer); virtual;
    function Find(const Value: TID; out Index: Integer): Boolean;
    procedure Clear; virtual;
    // вычитает из нашего массива переданный. останутся только
    // те элементы, которые есть в нашем массиве, но отсутствуют
    // в переданном.
    procedure Extract(KA: TgdKeyArray);
    procedure Assign(KA: TgdKeyArray);

    procedure LoadFromStream(S: TStream); virtual;
    procedure SaveToStream(S: TStream); virtual;

    property Keys[Index: Integer]: TID read GetKeys; default;
    property Count: Integer read GetCount;
    property Size: Integer read GetSize;

    //Устанавливается в Истина при изменении содержимого.
    //Исключение загрузка из потока
    //Пригодится при сохранении объектов в UserStorage
    //т.к. SelectedID - это TgdcKeyArray и он сохраняется в USerStorage каждый раз при закрытии формы
    //При этом идет синхронизация стораджа с БД.
    //Это выполняется для каждого б-о на форме.
    //Очень медленно
    property WasModified: Boolean read FWasModified;

    //
    property Sorted: Boolean read FSorted write SetSorted default True;

    //
    property CommaText: String read GetCommaText write SetCommaText;

  published
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  // sorted array of integer keys
  // duplicates are allowed
  TgdKeyDuplArray = class(TgdKeyArray)
  private
    FDuplicates: TDuplicates;

  public
    constructor Create;

    function Add(const Value: TID): Integer;

    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
  end;


  // association between integer key and integer value
  // use IndexOf function to obtain index of given key
  // then use Values property to get or set integer value
  TgdKeyIntAssoc = class(TgdKeyArray)
  private
    FValues: array of TID;

    function GetValuesByIndex(Index: Integer): TID;
    procedure SetValuesByIndex(Index: Integer; const Value: TID);
    function GetValuesByKey(Key: TID): TID;
    procedure SetValuesByKey(Key: TID; const Value: TID);

  protected
    procedure InsertItem(const Index: Integer; const Value: TID); override;
    procedure Grow; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Delete(const Index: Integer); override;
    procedure LoadFromStream(S: TStream); override;
    procedure SaveToStream(S: TStream); override;

    property ValuesByIndex[Index: Integer]: TID read GetValuesByIndex
      write SetValuesByIndex;
    property ValuesByKey[Key: TID]: TID read GetValuesByKey
      write SetValuesByKey;
  end;

  // association between integer key and Object
  // use IndexOf function to obtain index of given key
  // then use Values property to get or set Object
//  TgdKeyObjectAssoc = class(TgdKeyArray)
  TgdKeyObjectAssoc = class(TgdKeyDuplArray)
  private
    FValues: array of TObject;
    FOwnsObjects: Boolean;

    function GetObjectByIndex(Index: Integer): TObject;
    function GetObjectByKey(Key: TID): TObject;
    procedure SetObjectByIndex(Index: Integer; const Value: TObject);
    procedure SetObjectByKey(Key: TID; const Value: TObject);
    procedure SetOwnsObjects(const Value: Boolean);

  protected
    procedure InsertItem(const Index: Integer; const Value: TID); override;
    procedure Grow; override;

  public
    constructor Create; overload;
    constructor Create(const OwnsObjects: Boolean); overload;
    destructor Destroy; override;

    function  AddObject(const AKey: TID; AObject: TObject): Integer;
    procedure Delete(const Index: Integer); override;
    function Remove(const Key: TID): Integer;
    procedure Clear; override;

    property ObjectByIndex[Index: Integer]: TObject read GetObjectByIndex
      write SetObjectByIndex;
    property ObjectByKey[Key: TID]: TObject read GetObjectByKey
      write SetObjectByKey; default;
    property OwnsObjects: Boolean read FOwnsObjects write SetOwnsObjects default False;
  end;

  // association between integer key and string value
  // use IndexOf function to obtain index of given key
  // then use Values property to get or set string value
  TgdKeyStringAssoc = class(TgdKeyArray)
  private
    FValues: TStringList;

    function GetValuesByIndex(Index: Integer): String;
    procedure SetValuesByIndex(Index: Integer; const Value: String);
    function GetValuesByKey(Key: TID): String;

  protected
    procedure InsertItem(const Index: Integer; const Value: TID); override;
    procedure Grow; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Delete(const Index: Integer); override;
    procedure Clear; override;

    procedure LoadFromStream(S: TStream); override;
    procedure SaveToStream(S: TStream); override;

    property ValuesByIndex[Index: Integer]: String read GetValuesByIndex
      write SetValuesByIndex;
    property ValuesByKey[Key: TID]: String read GetValuesByKey;
  end;

  TgdKeyIntArrayAssoc = class(TgdKeyArray)
  private
    FValues: array of TgdKeyArray;

    function GetValuesByIndex(Index: Integer): TgdKeyArray;
    function GetValuesByKey(Key: TID): TgdKeyArray;

  protected
    procedure InsertItem(const Index: Integer; const Value: TID); override;
    procedure Grow; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Delete(const Index: Integer); override;
    procedure Clear; override;

    property ValuesByIndex[Index: Integer]: TgdKeyArray read GetValuesByIndex;
    property ValuesByKey[Key: TID]: TgdKeyArray read GetValuesByKey;
  end;

  TgdKeyIntAndStrAssoc = class(TgdKeyArray)
  private
    FStrValues: TStringList;
    FIntValues: array of TID;

    function  GetStrByIndex(Index: Integer): String;
    procedure SetStrByIndex(Index: Integer; const Value: String);
    function  GetStrByKey(Key: TID): String;
    procedure SetStrByKey(Key: TID; const Value: String);
    function  GetIntByIndex(Index: Integer): TID;
    procedure SetIntByIndex(Index: Integer; const Value: TID);
    function  GetIntByKey(Key: TID): TID;
    procedure SetIntByKey(Key: TID; const Value: TID);

  protected
    procedure InsertItem(const Index: Integer; const Value: TID); override;
    procedure Grow; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Delete(const Index: Integer); override;
    procedure Clear; override;

    property StrByIndex[Index: Integer]: String read GetStrByIndex
      write SetStrByIndex;
    property StrByKey[Key: TID]: String read GetStrByKey
      write SetStrByKey;
    property IntByIndex[Index: Integer]: TID read GetIntByIndex
      write SetIntByIndex;
    property IntByKey[Key: TID]: TID read GetIntByKey
      write SetIntByKey;
  end;

implementation

uses
  SysUtils {$IFDEF DEBUG}, Windows{$ENDIF};

const
  kaIntAssocStream = $75443335;

{ TgdKeyArray }

function TgdKeyArray.Add(const Value: TID;
  const IgnoreDuplicates: Boolean = False): Integer;
begin
  if not Find(Value, Result) then
    InsertItem(Result, Value)
  else if not IgnoreDuplicates then
    raise Exception.Create('TgdKeyArray: Duplicate keys are not allowed. Key=' + TID2S(Value));
end;

procedure TgdKeyArray.Assign(KA: TgdKeyArray);
var
  I: Integer;
begin
  Clear;
  for I := 0 to KA.Count - 1 do
    Add(KA[I]);
end;

procedure TgdKeyArray.Changed;
begin
  FWasModified := True;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TgdKeyArray.CheckIndex(const Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then
    raise Exception.Create('Index is out of bounds');
end;

procedure TgdKeyArray.Clear;
begin
  FCount := 0;
  Changed;
end;

constructor TgdKeyArray.Create;
begin
  FCount := 0;
  FSize := 0;
  SetLength(FArray, FSize);
  FWasModified := False;
  FSorted := True;
end;

procedure TgdKeyArray.Delete(const Index: Integer);
begin
  CheckIndex(Index);
  if Index < (FCount - 1) then
  begin
    System.Move(FArray[Index + 1], FArray[Index],
      (FCount - Index - 1) * SizeOf(FArray[0]));
  end;
  Dec(FCount);

  Changed;
end;

destructor TgdKeyArray.Destroy;
begin
  SetLength(FArray, 0);
  inherited;
end;

procedure TgdKeyArray.Extract(KA: TgdKeyArray);
var
  I: Integer;
begin
  Assert(Assigned(KA));
  for I := Count - 1 downto 0 do
    if KA.IndexOf(Keys[I]) <> -1 then
      Delete(I);
end;

function TgdKeyArray.Find(const Value: TID;
  out Index: Integer): Boolean;
var
  L, H, I: Integer;
begin
  if FSorted then
  begin
    Result := False;
    L := 0;
    H := FCount - 1;
    while L <= H do
    begin
      I := (L + H) shr 1;
      if FArray[I] < Value then L := I + 1 else
      begin
        H := I - 1;
        if FArray[I] = Value then
        begin
          Result := True;
          L := I;
        end;
      end;
    end;
    Index := L;
  end else
  begin
    for I := 0 to FCount - 1 do
    begin
      if FArray[I] = Value then
      begin
        Result := True;
        Index := I;
        exit;
      end;
    end;
    Result := False;
    Index := FCount;
  end;
end;

function TgdKeyArray.GetCommaText: String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Count - 1 do
    Result := Result + TID2S(Keys[I]) + ',';
  if Result > '' then
    SetLength(Result, Length(Result) - 1);
end;

function TgdKeyArray.GetCount: Integer;
begin
  Result := FCount;
end;

function TgdKeyArray.GetKeys(Index: Integer): TID;
begin
  CheckIndex(Index);
  Result := FArray[Index];
end;

function TgdKeyArray.GetSize: Integer;
begin
  Result := FSize;
end;

procedure TgdKeyArray.Grow;
var
  Delta: Integer;
begin
  if FSize > 64 then Delta := FSize div 4 else
    if FSize > 8 then Delta := 16 else
      Delta := 4;
  FSize := FSize + Delta;
  SetLength(FArray, FSize);
end;

function TgdKeyArray.IndexOf(const Value: TID): Integer;
begin
  if not Find(Value, Result) then
    Result := -1;
end;

procedure TgdKeyArray.InsertItem(const Index: Integer; const Value: TID);
begin
  if FCount = FSize then Grow;
  if Index < FCount then
  begin
    System.Move(FArray[Index], FArray[Index + 1],
      (FCount - Index) * SizeOf(FArray[0]));
    {$IFDEF DEBUG}
    if (FCount - Index) * SizeOf(FArray[0]) > 1024 * 10 then
    begin
      OutputDebugString('Big move in TgdKeyArray');
    end;
    {$ENDIF}
  end;
  FArray[Index] := Value;
  Inc(FCount);

  Changed;
end;

procedure TgdKeyArray.LoadFromStream(S: TStream);
var
  I, Len: Integer;
  {$IFDEF ID64}
  j: Integer;
  TmpArray: array of Integer;
  {$ENDIF}
begin
  S.ReadBuffer(I, SizeOf(I));
  if I <> $55443322 then
    raise Exception.Create('Invalid stream format');
  S.ReadBuffer(FCount, SizeOf(FCount));
  FSize := FCount;
  SetLength(FArray, FCount);
  if FCount > 0 then
    try
      Len := GetLenIDinStream(@S);
      {$IFDEF ID64}
      if Len = SizeOf(Integer) then
      begin
        SetLength(TmpArray, FCount);
        S.ReadBuffer(TmpArray[0], FCount * Len);
        for j:= Low(TmpArray) to High(TmpArray) do
          FArray[j] := TmpArray[j];
        SetLength(TmpArray,0);
      end
      else
        S.ReadBuffer(FArray[0], FCount * Len);
      {$ELSE}
      S.ReadBuffer(FArray[0], FCount * Len);
      {$ENDIF}

    except
    end;
  FWasModified := False;
end;

function TgdKeyArray.Remove(const Value: TID): Integer;
begin
  if Find(Value, Result) then
    Delete(Result);
end;

procedure TgdKeyArray.SaveToStream(S: TStream);
var
  I, Len: Integer;
begin
  I := $55443322;
  S.Write(I, SizeOf(I));
  S.Write(FCount, SizeOf(FCount));

  {метка сохранение ID в Int64}
  Len := SetLenIDinStream(@S);

  if FCount > 0 then
    S.Write(FArray[0], FCount * Len);
end;

procedure TgdKeyArray.SetCommaText(const Value: String);

  function ExtractInt(const V: String; var B: Integer): TID;
  var
    E: Integer;
  begin
    E := B + 1;
    while (B <= Length(V)) and (E <= Length(V)) and (V[E] <> ',') do
      Inc(E);
    {$IFDEF ID64}
    Result := StrToInt64(Copy(V, B, E - B));
    {$ELSE}
    Result := StrToInt(Copy(V, B, E - B));
    {$ENDIF}
    B := E + 1;
  end;

var
  P: Integer;
begin
  Clear;
  P := 1;
  while P <= Length(Value) do
    Add(ExtractInt(Value, P));
end;

procedure TgdKeyArray.SetSorted(const Value: Boolean);
begin
  if FSorted <> Value then
  begin
    if Count > 0 then
      raise Exception.Create('Array is not empty');
    FSorted := Value;
  end;  
end;

{ TgdKeyIntAssoc }

constructor TgdKeyIntAssoc.Create;
begin
  inherited Create;
  SetLength(FValues, FSize);
end;

procedure TgdKeyIntAssoc.Delete(const Index: Integer);
begin
  CheckIndex(Index);
  System.Move(FValues[Index + 1], FValues[Index],
    (FCount - Index) * SizeOf(FValues[0]));
  // колькасць запісаў будзе зменшаная ў наследаваным
  // метадзе
  inherited Delete(Index);
end;

destructor TgdKeyIntAssoc.Destroy;
begin
  SetLength(FValues, 0);
  inherited;
end;

function TgdKeyIntAssoc.GetValuesByIndex(Index: Integer): TID;
begin
  CheckIndex(Index);
  Result := FValues[Index];
end;

function TgdKeyIntAssoc.GetValuesByKey(Key: TID): TID;
var
  Index: Integer;
begin
  if Find(Key, Index) then
    Result := FValues[Index]
  else
    raise Exception.Create('Invalid key value');
end;

procedure TgdKeyIntAssoc.Grow;
begin
  inherited;
  SetLength(FValues, FSize);
end;

procedure TgdKeyIntAssoc.InsertItem(const Index: Integer; const Value: TID);
begin
  inherited;
  // пасля выкліку наследаванага метаду
  // колькасць запісаў (ФКаунт) ужо павялічана
  // на адзінку
  if Index < (FCount - 1) then
    System.Move(FValues[Index], FValues[Index + 1],
      ((FCount - 1) - Index) * SizeOf(FValues[0]));
  FValues[Index] := 0;
end;

procedure TgdKeyIntAssoc.LoadFromStream(S: TStream);
var
  I, Len: Integer;
  {$IFDEF ID64}
  j: Integer;
  TmpArray: array of Integer;
  {$ENDIF}
begin
  if (S = nil) or (S.Size = 0) then
    Clear
  else
  begin
    S.ReadBuffer(I, SizeOf(I));
    if I <> kaIntAssocStream then
      raise Exception.Create('Invalid stream format');
    S.ReadBuffer(FCount, SizeOf(FCount));
    FSize := FCount;

    Len := GetLenIDinStream(@S);

    {$IFDEF ID64}
    if Len = SizeOf(Integer) then
    begin
      SetLength(TmpArray, FCount);
      SetLength(FArray, FCount);
      if FCount > 0 then
      try
        S.ReadBuffer(TmpArray[0], FCount * Len);
        for j:= Low(TmpArray) to High(TmpArray) do
          FArray[j] := TmpArray[j];
        SetLength(TmpArray,0);
      except
      end;

      SetLength(TmpArray, FCount);
      SetLength(FValues, FCount);
      if FCount > 0 then
      try
        S.ReadBuffer(TmpArray[0], FCount * Len);
        for j:= Low(TmpArray) to High(TmpArray) do
          FValues[j] := TmpArray[j];
        SetLength(TmpArray,0);
      except
      end;

    end
    else begin
      SetLength(FArray, FCount);
      if FCount > 0 then
      try
         S.ReadBuffer(FArray[0], FCount * Len);
      except
      end;

      SetLength(FValues, FCount);
      if FCount > 0 then
      try
        S.ReadBuffer(FValues[0], FCount * Len);
      except
      end;
    end;
    {$ELSE}
    SetLength(FArray, FCount);
    if FCount > 0 then
    try
       S.ReadBuffer(FArray[0], FCount * Len);
    except
    end;

    SetLength(FValues, FCount);
    if FCount > 0 then
    try
      S.ReadBuffer(FValues[0], FCount * Len);
    except
    end;
    {$ENDIF}
  end;
end;

procedure TgdKeyIntAssoc.SaveToStream(S: TStream);
var
  I, Len: Integer;
begin
  I := kaIntAssocStream;
  S.Write(I, SizeOf(I));
  S.Write(FCount, SizeOf(FCount));

  {метка сохранения ID в Int64}
  Len := SetLenIDinStream(@S);

  if FCount > 0 then
  begin
    S.Write(FArray[0], FCount * Len);
    S.Write(FValues[0], FCount * Len);
  end;
end;

procedure TgdKeyIntAssoc.SetValuesByIndex(Index: Integer; const Value: TID);
begin
  CheckIndex(Index);
  FValues[Index] := Value;
end;

procedure TgdKeyIntAssoc.SetValuesByKey(Key: TID;
  const Value: TID);
var
  Index: Integer;
begin
  if Find(Key, Index) then
    FValues[Index] := Value
  else
    raise Exception.Create('Invalid key value');
end;

{ TgdKeyStringAssoc }

procedure TgdKeyStringAssoc.Clear;
begin
  FValues.Clear;
  inherited;
end;

constructor TgdKeyStringAssoc.Create;
begin
  inherited Create;
  FValues := TstringList.Create;
end;

procedure TgdKeyStringAssoc.Delete(const Index: Integer);
begin
  CheckIndex(Index);
  FValues.Delete(Index);
  inherited Delete(Index);
end;

destructor TgdKeyStringAssoc.Destroy;
begin
  FValues.Free;
  inherited;
end;

function TgdKeyStringAssoc.GetValuesByIndex(Index: Integer): String;
begin
  CheckIndex(Index);
  Result := FValues[Index];
end;

function TgdKeyStringAssoc.GetValuesByKey(Key: TID): String;
begin
  Result := ValuesByIndex[IndexOf(Key)];
end;

procedure TgdKeyStringAssoc.Grow;
begin
  inherited;
  FValues.Capacity := FSize;
end;

procedure TgdKeyStringAssoc.InsertItem(const Index: Integer; const Value: TID);
begin
  inherited;
  FValues.Insert(Index, '');
end;

procedure TgdKeyStringAssoc.LoadFromStream(S: TStream);
begin
  inherited;
  if Count > 0 then
    FValues.LoadFromStream(S);
end;

procedure TgdKeyStringAssoc.SaveToStream(S: TStream);
begin
  inherited;
  if Count > 0 then
    FValues.SaveToStream(S);
end;

procedure TgdKeyStringAssoc.SetValuesByIndex(Index: Integer; const Value: String);
begin
  CheckIndex(Index);
  FValues[Index] := Value;
end;

{ TgdKeyIntArrayAssoc }

procedure TgdKeyIntArrayAssoc.Clear;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
    FValues[I].Free;
  inherited;
end;

constructor TgdKeyIntArrayAssoc.Create;
begin
  inherited Create;
  SetLength(FValues, FSize);
end;

procedure TgdKeyIntArrayAssoc.Delete(const Index: Integer);
begin
  CheckIndex(Index);
  FValues[Index].Free;
  System.Move(FValues[Index + 1], FValues[Index],
    (FCount - Index) * SizeOf(FValues[0]));
  inherited Delete(Index);
end;

destructor TgdKeyIntArrayAssoc.Destroy;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
    FValues[I].Free;
  SetLength(FValues, 0);
  inherited;
end;

function TgdKeyIntArrayAssoc.GetValuesByIndex(Index: Integer): TgdKeyArray;
begin
  CheckIndex(Index);
  Result := FValues[Index];
end;

function TgdKeyIntArrayAssoc.GetValuesByKey(Key: TID): TgdKeyArray;
var
  Index: Integer;
begin
  if Find(Key, Index) then
    Result := FValues[Index]
  else
    raise Exception.Create('Invalid key');
end;

procedure TgdKeyIntArrayAssoc.Grow;
begin
  inherited;
  SetLength(FValues, FSize);
end;

procedure TgdKeyIntArrayAssoc.InsertItem(const Index: Integer; const Value: TID);
begin
  inherited;
  if Index < (FCount - 1) then
    System.Move(FValues[Index], FValues[Index + 1],
      ((FCount - 1) - Index) * SizeOf(FValues[0]));
  FValues[Index] := TgdKeyArray.Create;
end;

{ TgdKeyIntAndStrAssoc }

procedure TgdKeyIntAndStrAssoc.Clear;
begin
  FStrValues.Clear;
  inherited;
end;

constructor TgdKeyIntAndStrAssoc.Create;
begin
  inherited Create;
  SetLength(FIntValues, FSize);
  FStrValues := TStringList.Create;
end;

procedure TgdKeyIntAndStrAssoc.Delete(const Index: Integer);
begin
  CheckIndex(Index);
  System.Move(FIntValues[Index + 1], FIntValues[Index],
    (FCount - Index) * SizeOf(FIntValues[0]));
  FStrValues.Delete(Index);
  inherited Delete(Index);
end;

destructor TgdKeyIntAndStrAssoc.Destroy;
begin
  SetLength(FIntValues, 0);
  FStrValues.Free;
  inherited;
end;

function TgdKeyIntAndStrAssoc.GetIntByIndex(Index: Integer): TID;
begin
  CheckIndex(Index);
  Result := FIntValues[Index];
end;

function TgdKeyIntAndStrAssoc.GetIntByKey(Key: TID): TID;
var
  Index: Integer;
begin
  if Find(Key, Index) then
    Result := FIntValues[Index]
  else
    raise Exception.Create('Invalid key value');
end;

function TgdKeyIntAndStrAssoc.GetStrByIndex(Index: Integer): String;
begin
  CheckIndex(Index);
  Result := FStrValues[Index];
end;

function TgdKeyIntAndStrAssoc.GetStrByKey(Key: TID): String;
begin
  Result := StrByIndex[IndexOf(Key)];
end;

procedure TgdKeyIntAndStrAssoc.Grow;
begin
  inherited;
  SetLength(FIntValues, FSize);
  FStrValues.Capacity := FSize;
end;

procedure TgdKeyIntAndStrAssoc.InsertItem(const Index: Integer; const Value: TID);
begin
  inherited;
  if Index < (FCount - 1) then
  begin
    System.Move(FIntValues[Index], FIntValues[Index + 1],
      ((FCount - 1) - Index) * SizeOf(FIntValues[0]));
  end;
  FIntValues[Index] := 0;
  FStrValues.Insert(Index, '');
end;

procedure TgdKeyIntAndStrAssoc.SetIntByIndex(Index: Integer;
  const Value: TID);
begin
  CheckIndex(Index);
  FIntValues[Index] := Value;
end;

procedure TgdKeyIntAndStrAssoc.SetIntByKey(Key: TID;
  const Value: TID);
var
  Index: Integer;
begin
  if Find(Key, Index) then
    FIntValues[Index] := Value
  else
    raise Exception.Create('Invalid key value');
end;

procedure TgdKeyIntAndStrAssoc.SetStrByIndex(Index: Integer;
  const Value: String);
begin
  CheckIndex(Index);
  FStrValues[Index] := Value;
end;

procedure TgdKeyIntAndStrAssoc.SetStrByKey(Key: TID;
  const Value: String);
var
  Index: Integer;
begin
  if Find(Key, Index) then
    FStrValues[Index] := Value
  else
    raise Exception.Create('Invalid key value');
end;

{ TgdKeyObjectAssoc }

function TgdKeyObjectAssoc.AddObject(const AKey: TID; AObject: TObject): Integer;
begin
  Result := Add(AKey);
  ObjectByIndex[Result] := AObject;
end;

procedure TgdKeyObjectAssoc.Clear;
var
  i: Integer;
begin
  if OwnsObjects then
  begin
    for i := 0 to Count - 1 do
      ObjectByIndex[i].Free;
  end;

  inherited;
end;

constructor TgdKeyObjectAssoc.Create;
begin
  inherited Create;
  SetLength(FValues, FSize);
end;

constructor TgdKeyObjectAssoc.Create(const OwnsObjects: Boolean);
begin
  Create;
  FOwnsObjects := OwnsObjects;
end;

procedure TgdKeyObjectAssoc.Delete(const Index: Integer);
begin
  if FOwnsObjects then
    ObjectByIndex[Index].Free;

  CheckIndex(Index);
  if Index < (FCount - 1) then
  begin
    System.Move(FValues[Index + 1], FValues[Index],
      (FCount - Index - 1) * SizeOf(FValues[0]));
  end;
  // колькасць запісаў будзе зменшаная ў наследаваным
  // метадзе
  inherited Delete(Index);
end;

destructor TgdKeyObjectAssoc.Destroy;
var
  i: Integer;
begin
  if OwnsObjects then
  begin
    for i := 0 to Count - 1 do
      ObjectByIndex[i].Free;
  end;
  SetLength(FValues, 0);
  inherited;
end;

function TgdKeyObjectAssoc.GetObjectByIndex(Index: Integer): TObject;
begin
  CheckIndex(Index);
  Result := FValues[Index];
end;

function TgdKeyObjectAssoc.GetObjectByKey(Key: TID): TObject;
var
  Index: Integer;
begin
  if Find(Key, Index) then
    Result := FValues[Index]
  else
    raise Exception.Create('Invalid key value');
end;

procedure TgdKeyObjectAssoc.Grow;
begin
  inherited;
  SetLength(FValues, FSize);
end;

procedure TgdKeyObjectAssoc.InsertItem(const Index: Integer; const Value: TID);
begin
  inherited;
  if Index < (FCount - 1) then
    System.Move(FValues[Index], FValues[Index + 1],
      ((FCount - 1) - Index) * SizeOf(FValues[0]));
  FValues[Index] := nil;
end;

function TgdKeyObjectAssoc.Remove(const Key: TID): Integer;
begin
  if FOwnsObjects then
    ObjectByKey[Key].Free;
  Result := inherited Remove(Key);
end;

procedure TgdKeyObjectAssoc.SetObjectByIndex(Index: Integer;
  const Value: TObject);
begin
  CheckIndex(Index);
  FValues[Index] := Value;
end;

procedure TgdKeyObjectAssoc.SetObjectByKey(Key: TID;
  const Value: TObject);
var
  Index: Integer;
begin
  if Find(Key, Index) then
    FValues[Index] := Value
  else
    raise Exception.Create('Invalid key value');
end;

procedure TgdKeyObjectAssoc.SetOwnsObjects(const Value: Boolean);
begin
  FOwnsObjects := Value;
end;

{ TgdKeyDuplArray }

function TgdKeyDuplArray.Add(const Value: TID): Integer;
begin
  case FDuplicates of
    dupIgnore: Result := Inherited Add(Value, True);
    dupError:  Result := Inherited Add(Value, False);
    dupAccept:
    begin
      Find(Value, Result);
      InsertItem(Result, Value);
    end;
  end;
end;

constructor TgdKeyDuplArray.Create;
begin
  inherited Create;
  FDuplicates := dupError;
end;

end.
