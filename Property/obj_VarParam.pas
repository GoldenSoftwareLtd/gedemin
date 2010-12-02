unit obj_VarParam;

interface

uses
  ComObj, Gedemin_TLB, gdcOLEClassList;

type
//  TgsVarParam = class(TAutoIntfObject, IgsVarParam)
  TgsVarParam = class(TAutoObject, IgsVarParam)
  private
    FParam: OleVariant;
  protected
    function  Get_Value: OleVariant; safecall;
    procedure Set_Value(Value: OleVariant); safecall;
  public
    constructor Create(const Param: Variant);
  end;

var
  VarParam: TgsVarParam;

implementation

uses
  ComServ;

{ TgsVarParam }

constructor TgsVarParam.Create(const Param: Variant);
begin
  inherited Create;
//  inherited Create(ComServer.TypeLib, IID_IgsVarParam);

  FParam := Param;
end;

function TgsVarParam.Get_Value: OleVariant;
begin
  Result := FParam;
end;

procedure TgsVarParam.Set_Value(Value: OleVariant);
begin
  FParam := Value;
end;

initialization
//  VarParam := TgsVarParam.Create;
 // TAutoObjectFactory.Create(ComServer, CgsVarParam, CLASS_gsVarParam,
   // ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TgsVarParam, CLASS_gsVarParam,
    ciMultiInstance, tmApartment);
end.
