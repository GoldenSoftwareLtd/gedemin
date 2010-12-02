unit tst_BaseClass;

interface

uses
  Windows, {tst_TestInterface;}TestProperty_TLB;

type
  TBaseClass = class(TObject, {ITestInt,}IBaseClass, IDispatch, IUnknown)
  private
    FRefCount: Integer;
  protected
    function GetIdByName(const AnName: String): Integer; virtual;

    function GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount,
      LocaleID: Integer; DispIDs: Pointer): HResult; virtual; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; virtual; stdcall;
    function GetTypeInfoCount(out Count: Integer): HResult; virtual; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; virtual; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    procedure Method1; safecall;
    procedure Method2; safecall;
    procedure Method3; safecall;
    procedure Method11(Param1: Integer); safecall;
  public
    procedure Method10(const AnEnterParam: Integer);
  end;

type
  TArrNames = array of PWideChar;
  TArrDispIDs = array of Integer;

implementation

uses
  ActiveX, ComObj;

{ TBaseClass }

function TBaseClass._AddRef: Integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function TBaseClass._Release: Integer;
begin
  Result := InterlockedDecrement(FRefCount);
  if Result = 0 then Destroy;
end;

{function TBaseClass.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
begin
  Result := (Self as TComponent).GetIDsOfNames(IID, Names, NameCount, LocaleID, DispIDs);
end;}

function TBaseClass.GetTypeInfo(Index, LocaleID: Integer;
  out TypeInfo): HResult;
begin

end;

function TBaseClass.GetTypeInfoCount(out Count: Integer): HResult;
begin

end;                  

function TBaseClass.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo,
  ArgErr: Pointer): HResult;
begin
  Result := 0;
  try
    case DispID of
      1:
      begin
        if TDispParams(Params).cArgs <> 0 then
        begin
          Result := DISP_E_TYPEMISMATCH;
          Exit;
        end;
        Method1;
      end;
      2:
      begin
        if TDispParams(Params).cArgs <> 0 then
        begin
          Result := DISP_E_TYPEMISMATCH;
          Exit;
        end;
        Method2;
      end;
      3:
      begin
        if TDispParams(Params).cArgs <> 0 then
        begin
          Result := DISP_E_TYPEMISMATCH;
          Exit;
        end;
       Method3;
      end;
      10:
      begin
        if TDispParams(Params).cArgs <> 1 then
        begin
          Result := DISP_E_TYPEMISMATCH;
          Exit;
        end;     
        Method10(TDispParams(Params).rgvarg[0].lVal);
      end;
    end;
  except
    Result := DISP_E_EXCEPTION;
  end;
end;

procedure TBaseClass.Method1;
begin
  Beep(3000, 500);
end;

procedure TBaseClass.Method2;
begin
  Beep(2000, 500);
end;

procedure TBaseClass.Method3;
begin
  Beep(1000, 500);
end;

function TBaseClass.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then Result := S_OK else Result := E_NOINTERFACE;
end;

function TBaseClass.GetIdByName(const AnName: String): Integer;
begin
  Result := 0;
  if AnName = 'Method1' then
    Result := 1
  else
    if AnName = 'Method2' then
      Result := 2
    else
      if AnName = 'Method3' then
        Result := 3
      else
        if AnName = 'Method10' then
          Result := 10;
end;

function TBaseClass.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
var
  I: Integer;
begin
  for I := 0 to NameCount - 1 do
    TArrDispIDs(DispIDs)[I] := GetIdByName(TArrNames(Names)[I]);
end;

procedure TBaseClass.Method10(const AnEnterParam: Integer);
begin

end;

procedure TBaseClass.Method11(Param1: Integer);
begin

end;

end.

