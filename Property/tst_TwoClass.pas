unit tst_TwoClass;

interface

uses
  Windows, tst_BaseClass, TestProperty_TLB;

type
  TTwoClass = class(TBaseClass, ITwoClass)
  private
  protected
    function GetIdByName(const AnName: String): Integer; override;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; override;
    procedure Method4; safecall;
    procedure Method5; safecall;
  end;

implementation

uses
  ActiveX;

{ TTwoClass }

function TTwoClass.GetIdByName(const AnName: String): Integer;
begin
  Result := 0;
  if AnName = 'Method4' then
    Result := 4
  else
    if AnName = 'Method5' then
      Result := 5;
  if Result = 0 then
    Result := inherited GetIdByName(AnName);
end;

function TTwoClass.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo,
  ArgErr: Pointer): HResult;
begin
  Result := 0;
  try
    case DispID of
      4:
      begin
        if TDispParams(Params).cArgs <> 0 then
        begin
          Result := DISP_E_TYPEMISMATCH;
          Exit;
        end;
        Method4;
      end;
      5:
      begin
        if TDispParams(Params).cArgs <> 0 then
        begin
          Result := DISP_E_TYPEMISMATCH;
          Exit;
        end;
        Method5;
      end;
    end;
  except
    Result := DISP_E_EXCEPTION;
  end;
  Result := inherited Invoke(DispID, IID, LocaleID, Flags, Params, VarResult, ExcepInfo, ArgErr);
end;

procedure TTwoClass.Method4;
begin
  Beep(2500, 500);
end;

procedure TTwoClass.Method5;
begin
  Beep(1500, 500);
end;

end.
