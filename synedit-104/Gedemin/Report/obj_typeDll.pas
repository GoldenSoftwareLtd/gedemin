unit obj_typeDll;

interface

uses
  ComObj, TypeDll_TLB;

type
  TTest = class(TAutoObject, ITest)
  protected
    function Test(Value1: Integer; Value2: Integer): Integer; safecall;
  end;

implementation

uses
  ComServ;

function TTest.Test(Value1: Integer; Value2: Integer): Integer;
begin
  if Value1 > Value2 then
    Result := Value1
  else
    Result := Value2;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TTest, CLASS_CoTest,
    ciMultiInstance, tmApartment);
end.
