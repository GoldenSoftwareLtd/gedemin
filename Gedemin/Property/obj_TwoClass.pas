// ShlTanya, 25.02.2019

unit obj_TwoClass;

interface

uses
  ComObj, ActiveX, TestProperty_TLB, StdVcl, obj_BaseClass;

type
  ToleTwoClass = class(ToleBaseClass, ITwoClass)
  protected
    procedure Method4; safecall;
    procedure Method5; safecall;
    { Protected declarations }
  end;

implementation

uses ComServ, Windows;

procedure ToleTwoClass.Method4;
begin
  Beep(2500, 500);
end;

procedure ToleTwoClass.Method5;
begin
  Beep(1500, 500);
end;

initialization
  TAutoObjectFactory.Create(ComServer, ToleTwoClass, Class_oleTwoClass,
    ciMultiInstance, tmApartment);
end.
