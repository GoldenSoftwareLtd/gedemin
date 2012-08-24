
{++

  Copyright (c) 2002 by Golden Software of Belarus

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
  Classes;

type
  // sorted array of integer keys
  // duplicates are not allowed
  TgdKeyArray = class
  private
    FArray: array of Integer;
    FCount: Integer;
    FSize: Integer;
    FOnChange: TNotifyEvent;
    FWasModified: Boolean;
    FSorted: Boolean;

    function GetCount: Integer;
    function GetKeys(Index: Integer): Integer;
    function GetSize: Integer;
    procedure SetSorted(const Value: Boolean);

  protected
    procedure Changed; virtual;

    procedure InsertItem(const Index, Value: Integer); virtual;
    procedure Grow; virtual;
    procedure CheckIndex(const Index: Integer);

  public
    constructor Create;
    destructor Destroy; override;

    function Add(const Value: Integer;
      const IgnoreDuplicates: Boolean = False): Integer;
    function IndexOf(const Value: Integer): Integer;
    function Remove(const Value: Integer): Integer;
    procedure Delete(const Index: Integer); virtual;
    function Find(const Value: Integer; out Index: Integer): Boolean;
    procedure Clear; virtual;
    // вычитает из нашего массива переданный. останутся только
    // те элементы, которые есть в нашем массиве, но отсутствуют
    // в переданном.
    procedure Extract(KA: TgdKeyArray);
    procedure Assign(KA: TgdKeyArray);

    procedure LoadFromStream(S: TStream); virtual;
    procedure SaveToStream(S: TStream); virtual;

    property Keys[Index: Integer]: Integer read GetKeys; default;
    property Count: Integer read GetCount;
    property Size: Integer read GetSize;

    function CommaText: String;

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

  published
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  // sorted array of integer keys
  // duplicates are allowed
  TgdKeyDuplArray = class(TgdKeyArray)
  private
    FDuplicates: TDuplicates;
    procedure SetDuplicates(const Value: TDuplicates);
  public
    constructor Create;

    function Add(const Value: Integer): Integer;

    property Duplicates: TDuplicates read FDuplicates write SetDuplicates;
  end;


  // association between integer key and integer value
  // use IndexOf function to obtain index of given key
  // then use Values property to get or set integer value
  TgdKeyIntAssoc = class(TgdKeyArray)
  private
    FValues: array of Integer;

    function GetValuesByIndex(Index: Integer): Integer;
    procedure SetValuesByIndex(Index: Integer; const Value: Integer);
    function GetValuesByKey(Key: Integer): Integer;
    procedure SetValuesByKey(Key: Integer; const Value: Integer);

  protected
    procedure InsertItem(const Index, Value: Integer); override;
    procedure Grow; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Delete(const Index: Integer); override;
    procedure LoadFromStream(S: TStream); override;
    procedure SaveToStream(S: TStream); override;

    property ValuesByIndex[Index: Integer]: Integer read GetValuesByIndex
      write SetValuesByIndex;
    property ValuesByKey[Key: Integer]: Integer read GetValuesByKey
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
    function GetObjectByKey(Key: Integer): TObject;
    procedure SetObjectByIndex(Index: Integer; const Value: TObject);
    procedure SetObjectByKey(Key: Integer; const Value: TObject);
    procedure SetOwnsObjects(const Value: Boolean);

  protected
    procedure InsertItem(const Index, Value: Integer); override;
    procedure Grow; override;

  public
    constructor Create; overload;
    constructor Create(const OwnsObjects: Boolean); overload;
    destructor Destroy; override;

    function  AddObject(const AKey: Integer; AObject: TObject): Integer;
    procedure Delete(const Index: Integer); override;
    function Remove(const Key: Integer): Integer;
    procedure Clear; override;

    property ObjectByIndex[Index: Integer]: TObject read GetObjectByIndex
      write SetObjectByIndex;
    property ObjectByKey[Key: Integer]: TObject read GetObjectByKey
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
    function GetValuesByKey(Key: Integer): String;

  protected
    procedure InsertItem(const Index, Value: Integer); override;
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
    property ValuesByKey[Key: Integer]: String read GetValuesByKey;
  end;

  TgdKeyIntArrayAssoc = class(TgdKeyArray)
  private
    FValues: array of TgdKeyArray;

    function GetValuesByIndex(Index: Integer): TgdKeyArray;
    function GetValuesByKey(Key: Integer): TgdKeyArray;

  protected
    procedure InsertItem(const Index, Value: Integer); override;
    procedure Grow; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Delete(const Index: Integer); override;
    procedure Clear; override;

    property ValuesByIndex[Index: Integer]: TgdKeyArray read GetValuesByIndex;
    property ValuesByKey[Key: Integer]: TgdKeyArray read GetValuesByKey;
  end;

  TgdKeyIntAndStrAssoc = class(TgdKeyArray)
  private
    FStrValues: TStringList;
    FIntValues: array of Integer;

    function  GetStrByIndex(Index: Integer): String;
    procedure SetStrByIndex(Index: Integer; const Value: String);
    function  GetStrByKey(Key: Integer): String;
    procedure SetStrByKey(Key: Integer; const Value: String);
    function  GetIntByIndex(Index: Integer): Integer;
    procedure SetIntByIndex(Index: Integer; const Value: Integer);
    function  GetIntByKey(Key: Integer): Integer;
    procedure SetIntByKey(Key: Integer; const Value: Integer);

  protected
    procedure InsertItem(const Index, Value: Integer); override;
    procedure Grow; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Delete(const Index: Integer); override;
    procedure Clear; override;

    property StrByIndex[Index: Integer]: String read GetStrByIndex
      write SetStrByIndex;
    property StrByKey[Key: Integer]: String read GetStrByKey
      write SetStrByKey;
    property IntByIndex[Index: Integer]: Integer read GetIntByIndex
      write SetIntByIndex;
    property IntByKey[Key: Integer]: Integer read GetIntByKey
      write SetIntByKey;
  end;

implementation

uses
  SysUtils {$IFDEF DEBUG}, Windows{$ENDIF};

const
  kaIntAssocStream = $75443335;

{ TgdKeyArray }

function TgdKeyArray.Add(const Value: Integer;
  const IgnoreDuplicates: Boolean = False): Integer;
begin
  if not Find(Value, Result) then
    InsertItem(Result, Value)
  else if not IgnoreDuplicates then
    raise Exception.Create('TgdKeyArray: Duplicate keys are not allowed. Key=' + IntToStr(Value));
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

function TgdKeyArray.CommaText: String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Count - 1 do
  begin
    if Result > '' then
      Result := Result + ',';
    Result := Result + IntToStr(Keys[I]);
  end;
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

function TgdKeyArray.Find(const Value: Integer;
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

function TgdKeyArray.GetCount: Integer;
begin
  Result := FCount;
end;

function TgdKeyArray.GetKeys(Index: Integer): Integer;
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

function TgdKeyArray.IndexOf(const Value: Integer): Integer;
begin
  if not Find(Value, Result) then
    Result := -1;
end;

procedure TgdKeyArray.InsertItem(const Index, Value: Integer);
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
  I: Integer;
begin
  S.ReadBuffer(I, SizeOf(I));
  if I <> $55443322 then
    raise Exception.Create('Invalid stream format');
  S.ReadBuffer(FCount, SizeOf(FCount));
  FSize := FCount;
  SetLength(FArray, FCount);
  if FCount > 0 then
    S.ReadBuffer(FArray[0], FCount * SizeOf(FArray[0]));
  FWasModified := False;  
end;

function TgdKeyArray.Remove(const Value: Integer): Integer;
begin
  if Find(Value, Result) then
    Delete(Result);
end;

procedure TgdKeyArray.SaveToStream(S: TStream);
var
  I: Integer;
begin
  I := $55443322;
  S.Write(I, SizeOf(I));
  S.Write(FCount, SizeOf(FCount));
  if FCount > 0 then
    S.Write(FArray[0], FCount * SizeOf(FArray[0]));
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

function TgdKeyIntAssoc.GetValuesByIndex(Index: Integer): Integer;
begin
  CheckIndex(Index);
  Result := FValues[Index];
end;

function TgdKeyIntAssoc.GetValuesByKey(Key: Integer): Integer;
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

procedure TgdKeyIntAssoc.InsertItem(const Index, Value: Integer);
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
  I: Integer;
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
    SetLength(FArray, FCount);
    if FCount > 0 then
      S.ReadBuffer(FArray[0], FCount * SizeOf(FArray[0]));

    SetLength(FValues, FCount);
    if FCount > 0 then
      S.ReadBuffer(FValues[0], FCount * SizeOf(FValues[0]));
  end;     
end;

procedure TgdKeyIntAssoc.SaveToStream(S: TStream);
var
  I: Integer;
begin
  I := kaIntAssocStream;
  S.Write(I, SizeOf(I));
  S.Write(FCount, SizeOf(FCount));
  if FCount > 0 then
  begin
    S.Write(FArray[0], FCount * SizeOf(FArray[0]));

    S.Write(FValues[0], FCount * SizeOf(FValues[0]));
  end;  
end;

procedure TgdKeyIntAssoc.SetValuesByIndex(Index: Integer; const Value: Integer);
begin
  CheckIndex(Index);
  FValues[Index] := Value;
end;

procedure TgdKeyIntAssoc.SetValuesByKey(Key: Integer;
  const Value: Integer);
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

function TgdKeyStringAssoc.GetValuesByKey(Key: Integer): String;
begin
  Result := ValuesByIndex[IndexOf(Key)];
end;

procedure TgdKeyStringAssoc.Grow;
begin
  inherited;
  FValues.Capacity := FSize;
end;

procedure TgdKeyStringAssoc.InsertItem(const Index, Value: Integer);
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

function TgdKeyIntArrayAssoc.GetValuesByKey(Key: Integer): TgdKeyArray;
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

procedure TgdKeyIntArrayAssoc.InsertItem(const Index, Value: Integer);
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

function TgdKeyIntAndStrAssoc.GetIntByIndex(Index: Integer): Integer;
begin
  CheckIndex(Index);
  Result := FIntValues[Index];
end;

function TgdKeyIntAndStrAssoc.GetIntByKey(Key: Integer): Integer;
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

function TgdKeyIntAndStrAssoc.GetStrByKey(Key: Integer): String;
begin
  Result := StrByIndex[IndexOf(Key)];
end;

procedure TgdKeyIntAndStrAssoc.Grow;
begin
  inherited;
  SetLength(FIntValues, FSize);
  FStrValues.Capacity := FSize;
end;

procedure TgdKeyIntAndStrAssoc.InsertItem(const Index, Value: Integer);
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
  const Value: Integer);
begin
  CheckIndex(Index);
  FIntValues[Index] := Value;
end;

procedure TgdKeyIntAndStrAssoc.SetIntByKey(Key: Integer;
  const Value: Integer);
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

procedure TgdKeyIntAndStrAssoc.SetStrByKey(Key: Integer;
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

function TgdKeyObjectAssoc.AddObject(const AKey: Integer; AObject: TObject): Integer;
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

function TgdKeyObjectAssoc.GetObjectByKey(Key: Integer): TObject;
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

procedure TgdKeyObjectAssoc.InsertItem(const Index, Value: Integer);
begin
  inherited;
  if Index < (FCount - 1) then
    System.Move(FValues[Index], FValues[Index + 1],
      ((FCount - 1) - Index) * SizeOf(FValues[0]));
  FValues[Index] := nil;
end;

function TgdKeyObjectAssoc.Remove(const Key: Integer): Integer;
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

procedure TgdKeyObjectAssoc.SetObjectByKey(Key: Integer;
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

function TgdKeyDuplArray.Add(const Value: Integer): Integer;
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

procedure TgdKeyDuplArray.SetDuplicates(const Value: TDuplicates);
begin
  FDuplicates := Value;
end;

end.
