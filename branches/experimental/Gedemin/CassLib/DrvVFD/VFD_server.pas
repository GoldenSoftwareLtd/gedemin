unit VFD_server;

interface

uses
  ComObj, ActiveX, AddIn_TLB, StdVcl;

type
  TVFD_Display = class(TAutoObject, IVFD_Display)
  protected
    { Protected declarations }
  end;

implementation

uses ComServ;

initialization
  TAutoObjectFactory.Create(ComServer, TVFD_Display, Class_VFD_Display,
    ciMultiInstance, tmApartment);
end.
