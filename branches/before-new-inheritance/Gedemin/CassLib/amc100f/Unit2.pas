unit Unit2;

interface

uses
  ComObj, ActiveX, gsDRV_TLB, StdVcl;

type
  TTAMC100F1 = class(TAutoObject, ITAMC100F)
  protected
    { Protected declarations }
  end;

implementation

uses ComServ;

initialization
  TAutoObjectFactory.Create(ComServer, TTAMC100F1, Class_TAMC100F1,
    ciMultiInstance, tmApartment);
end.
