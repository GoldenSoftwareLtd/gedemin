// ShlTanya, 27.02.2019

unit obj_ObjectEvent;

interface

uses
  Windows, Classes, ActiveX;

type
  TgsVariantArray = Array of OleVariant;

type
  TInvokeEvent = procedure(DispID: TDispID; var Params: TgsVariantArray) of object;

type
  TEventSink = class(TInterfacedObject, IUnknown, IDispatch)
  private
    FEventID: TGUID;
    InternalRefCount : Integer;
    FInvokeEvent: TInvokeEvent;
  protected
    { IUnknown }
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    { IDispatch }
    function GetTypeInfoCount(out Count: Integer): HRESULT; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HRESULT; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HRESULT; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HRESULT; stdcall;
  public
    constructor Create(AnOwner: TObject; AnEventID: TGUID);

    property OnInvokeEvent: TInvokeEvent read FInvokeEvent write FInvokeEvent;
  end;

implementation

{ TEventSink }

function TEventSink._AddRef: Integer;
begin
  Inc(InternalRefCount);
  Result := InternalRefCount;
end;

function TEventSink._Release: Integer;
begin
  Dec(InternalRefCount);
  Result := InternalRefCount;
end;

constructor TEventSink.Create(AnOwner: TObject; AnEventID: TGUID);
begin
  FEventID := AnEventID;
  InternalRefCount := 1;
end;

function TEventSink.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TEventSink.GetTypeInfo(Index, LocaleID: Integer;
  out TypeInfo): HRESULT;
begin
  Pointer(TypeInfo) := nil;
  Result := E_NOTIMPL;
end;

function TEventSink.GetTypeInfoCount(out Count: Integer): HRESULT;
begin
  Count := 0;
  Result:= S_OK;
end;

function TEventSink.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo,
  ArgErr: Pointer): HRESULT;
var
  ParamCount, I: integer;
  VarArray : TgsVariantArray;
begin
  // Get parameter count
  ParamCount := TDispParams(Params).cArgs;
  // Set our array to appropriate length
  SetLength(VarArray, ParamCount);
  // Copy over data
  for I := Low(VarArray) to High(VarArray) do
    VarArray[High(VarArray)-I] := OleVariant(TDispParams(Params).rgvarg^[I]);
  // Invoke Server proxy class
  if Assigned(FInvokeEvent) then
    FInvokeEvent(DispID, VarArray);
  // Clean array
  SetLength(VarArray, 0);
  // Pascal Events return 'void' - so assume success!
  Result := S_OK;
end;

function TEventSink.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  if GetInterface(IID, Obj) then
  begin
    Result := S_OK;
    Exit;
  end;
  if IsEqualIID(IID, FEventID) then
  begin
    GetInterface(IDispatch, Obj);
    Result := S_OK;
    Exit;
  end;
  Result := E_NOINTERFACE;
end;

end.
