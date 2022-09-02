// ShlTanya, 25.02.2019

unit obj_Inherited;

interface

uses
  ComObj, ActiveX, AxCtrls, Classes, StdVcl, Gedemin_TLB;

type
  TCustomInvoker = function(const Object_: IgsObject; const Name: WideString;
      var Params: OleVariant): OleVariant of object;

type
  TgsInherited = class(TAutoObject, IgsInherited)
  private
    FCustomInvoker: TCustomInvoker;
  protected
    { Protected declarations }
    function  DefaultMethod(const Object_: IgsObject;
      const Name: WideString; var Params: OleVariant): OleVariant; safecall;
    function  inherited_(const Sender: IgsObject;
      const Name: WideString; var Params: OleVariant): OleVariant; safecall;
  public
    property CustomInvoker: TCustomInvoker read FCustomInvoker write FCustomInvoker;
  end;

implementation

uses ComServ;

function TgsInherited.DefaultMethod(const Object_: IgsObject;
  const Name: WideString; var Params: OleVariant): OleVariant; safecall;
begin
  if Assigned(FCustomInvoker) then
    Result := FCustomInvoker(Object_, Name, Params)
  else
    Result := NULL;
end;

function TgsInherited.inherited_(const Sender: IgsObject;
      const Name: WideString; var Params: OleVariant): OleVariant; safecall;
begin
  Result := DefaultMethod(Sender, Name, Params);
end;

initialization
  TAutoObjectFactory.Create(ComServer, TgsInherited, Class_gsInherited,
    ciMultiInstance, tmApartment);
end.
