// ShlTanya, 24.02.2019

unit mtd_InheritedEvent_Old;

interface

uses
  Gedemin_TLB, obj_ObjectEvent, ActiveX, Classes, mtd_i_InheritedEvent_Old,
  obj_Inherited_Old;

type
  TTwoPointer = Record
    ObjectPointer: TObject;
    EventPointer: TEventInvoker;
  end;

  TTwoPointerList = class(TList)
  public
    constructor Create;
    destructor Destroy; override;

    function Add(AnSender: TObject; AnEventInvoker: TEventInvoker): Integer;
    procedure Delete(AnSender: TObject); overload;
    procedure Delete(AnIndex: Integer); overload;
    function FindEventInvoker(AnSender: TObject): TEventInvoker;
    function FindObjectIndex(AnSender: TObject): Integer;
    procedure Clear; override;
  end;

type
  TInheritedEvent_Old = class(TComponent, IgsInheritedEventInvoker)
  private
    FInheritedObject: IgsInherited;
    FEvent: TEventSink;
    FDisp: IDispatch;

    FRegistredEventList: TTwoPointerList;

    procedure InvokeEvent(DispID: TDispID; var Params: TgsVariantArray);
  protected
    procedure RegisterEventInvoker(AnSender: TObject; AnEventInvoker: TEventInvoker);
    procedure UnRegisterEventInvoker(AnSender: TObject);
    function Get_Self: TObject;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property InheritedObject: IgsInherited read FInheritedObject;
  end;

implementation

uses
  ComObj, SysUtils, Windows;

function CompareItems(Item1, Item2: Pointer): Integer;
begin
  Result := Integer(TTwoPointer(Item1^).ObjectPointer) -
   Integer(TTwoPointer(Item2^).ObjectPointer);
end;

{ TInheritedEvent_Old }

constructor TInheritedEvent_Old.Create(AnOwner: TComponent);
var
  I: Integer;
begin
  Assert(InheritedEventInvoker = nil, 'Объект InheritedEventInvoker может быть только один');

  inherited Create(nil);

  FInheritedObject := TgsInherited_Old.Create;
  FEvent := TEventSink.Create(Self, DIID_IgsInheritedEvents);
  FEvent.OnInvokeEvent := InvokeEvent;
  FDisp := FEvent;
  ComObj.InterfaceConnect(FInheritedObject, DIID_IgsInheritedEvents, FDisp, I);

  FRegistredEventList := TTwoPointerList.Create;

  InheritedEventInvoker := Self;
end;

destructor TInheritedEvent_Old.Destroy;
var
  I: Integer;
begin
  FDisp := nil;
  FEvent := nil;
  FInheritedObject := nil;

  if Assigned(FRegistredEventList) then
  begin
    I := FRegistredEventList.Count;
    FreeAndNil(FRegistredEventList);

  {$IFDEF DEBUG}
    // Проверка. Этого предупреждения возникать не должно
    // Если оно возникает значит в каком-то классе не вызывается UnRegisterEventInvoker
    if I > 0 then
      MessageBox(0, PChar(Format('Не освобождено %d обработчиков событий для класса TInheritedEvent_Old', [I])),
       'Внимание', MB_OK or MB_ICONWARNING or MB_TASKMODAL);
  {$ENDIF}
  end;

  if (InheritedEventInvoker <> nil) and (InheritedEventInvoker.Get_Self = Self) then
    InheritedEventInvoker := nil;

  inherited;
end;

function TInheritedEvent_Old.Get_Self: TObject;
begin
  Result := Self;
end;

procedure TInheritedEvent_Old.InvokeEvent(DispID: TDispID;
  var Params: TgsVariantArray);
var
  LEventInvoker: TEventInvoker;
  LDisp: IDispatch;
  LObj: TObject;
begin
  Assert((Length(Params) = 3) and (VarType(Params[0]) = varDispatch), 'Wrong parametrs count');
  try
    LDisp := Params[0];
    case DispID of
      1:
      begin
        LObj := TObject((LDisp as IgsObject).Get_Self);
        LEventInvoker := FRegistredEventList.FindEventInvoker(LObj);
        if not Assigned(LEventInvoker) then
          raise Exception.Create(Format('Класс %s не подписан на обработку события в классе TInheritedEvent_Old', [LObj.ClassName]));
        LEventInvoker(Params[1], Params[2]);
      end;
    else
      raise Exception.Create(Format('Event interface method %d not supported', [DispID]));
    end;
  except
    on E: Exception do
    begin
      MessageBox(0, PChar(E.Message), 'Ошибка', MB_OK or MB_ICONERROR or MB_TASKMODAL);
    end;
  end;
end;

procedure TInheritedEvent_Old.RegisterEventInvoker(AnSender: TObject;
  AnEventInvoker: TEventInvoker);
begin
  FRegistredEventList.Add(AnSender, AnEventInvoker);
end;

procedure TInheritedEvent_Old.UnRegisterEventInvoker(AnSender: TObject);
begin
  FRegistredEventList.Delete(AnSender);
end;

{ TTwoPointerList }

function TTwoPointerList.Add(AnSender: TObject;
  AnEventInvoker: TEventInvoker): Integer;
var
  LRec: ^TTwoPointer;
begin
  GetMem(LRec, SizeOf(TTwoPointer));
  LRec.ObjectPointer := AnSender;
  LRec.EventPointer := AnEventInvoker;

  Result := inherited Add(LRec);

  Sort(CompareItems);
end;

procedure TTwoPointerList.Clear;
begin
  while Count > 0 do
    Delete(0);

  inherited;
end;

constructor TTwoPointerList.Create;
begin
  inherited;

end;

procedure TTwoPointerList.Delete(AnSender: TObject);
var
  I: Integer;
begin
  I := FindObjectIndex(AnSender);
  while I > -1 do
  begin
    Delete(I);
    I := FindObjectIndex(AnSender);
  end;
end;

procedure TTwoPointerList.Delete(AnIndex: Integer);
var
  LRec: ^TTwoPointer;
begin
  Assert((AnIndex >= 0) and (AnIndex < Count), 'Index out of range');

  LRec := Items[AnIndex];
  inherited Delete(AnIndex);
  FreeMem(LRec);
end;

destructor TTwoPointerList.Destroy;
begin
  Clear;

  inherited;
end;

function TTwoPointerList.FindEventInvoker(AnSender: TObject): TEventInvoker;
var
  I: Integer;
begin
  I := FindObjectIndex(AnSender);
  if I > -1 then
    Result := TTwoPointer(Items[I]^).EventPointer
  else
    Result := nil;
end;

function TTwoPointerList.FindObjectIndex(AnSender: TObject): Integer;
var
  FI, SI, CurInd, ResVal: Integer;
  LRec: TTwoPointer;
begin
  Result := -1;
  FI := 0;
  SI := Count - 1;
  LRec.ObjectPointer := AnSender;
  while (Result = -1) and (FI <= SI) do
  begin
    CurInd := (FI + SI) div 2;
    ResVal := CompareItems(@LRec, Items[CurInd]);
    if ResVal > 0 then
      FI := CurInd + 1
    else
      if ResVal < 0 then
        SI := CurInd - 1
      else
        Result := CurInd;
  end;
end;

end.
