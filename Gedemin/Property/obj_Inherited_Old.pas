unit obj_Inherited_Old;

interface

uses
  ComObj, ActiveX, AxCtrls, Classes, StdVcl, Gedemin_TLB;

type
  TgsInherited_Old = class(TAutoObject, IConnectionPointContainer, IgsInherited)
  private
    { Private declarations }
    FConnectionPoints: TConnectionPoints;
    FConnectionPoint: TConnectionPoint;
    FSinkList: TList;
    FEvents: IgsInheritedEvents;
  public
    procedure Initialize; override;
  protected
    { Protected declarations }
    property ConnectionPoints: TConnectionPoints read FConnectionPoints
      implements IConnectionPointContainer;
    procedure EventSinkChanged(const EventSink: IUnknown); override;
    procedure DefaultMethod(const Object_: IgsObject; const Name: WideString;
      var Params: OleVariant); safecall;
  end;

implementation

uses ComServ;

procedure TgsInherited_Old.EventSinkChanged(const EventSink: IUnknown);
begin
  FEvents := EventSink as IgsInheritedEvents;
  if FConnectionPoint <> nil then
     FSinkList := FConnectionPoint.SinkList;
end;

procedure TgsInherited_Old.Initialize;
begin
  inherited Initialize;
  FConnectionPoints := TConnectionPoints.Create(Self);
  if AutoFactory.EventTypeInfo <> nil then
    FConnectionPoint := FConnectionPoints.CreateConnectionPoint(
      AutoFactory.EventIID, ckSingle, EventConnect)
  else FConnectionPoint := nil;
end;


procedure TgsInherited_Old.DefaultMethod(const Object_: IgsObject;
  const Name: WideString; var Params: OleVariant);
begin
  if (FEvents <> nil) then
    FEvents.DefaultEvent(Object_, Name, Params);
end;

initialization
  TAutoObjectFactory.Create(ComServer, TgsInherited_Old, Class_gsInherited_Old,
    ciMultiInstance, tmApartment);
end.
