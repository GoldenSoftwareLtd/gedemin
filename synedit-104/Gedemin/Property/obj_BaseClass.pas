unit obj_BaseClass;

interface

uses
  ComObj, ActiveX, AxCtrls, Classes, TestProperty_TLB, StdVcl;

type
  ToleBaseClass = class(TAutoObject, IConnectionPointContainer, IBaseClass)
  private
    { Private declarations }
    FConnectionPoints: TConnectionPoints;
    FConnectionPoint: TConnectionPoint;
    FSinkList: TList;
    FEvents: IBaseClassEvents;
  public
    procedure Initialize; override;
  protected
    { Protected declarations }
    property ConnectionPoints: TConnectionPoints read FConnectionPoints
      implements IConnectionPointContainer;
    procedure EventSinkChanged(const EventSink: IUnknown); override;
    procedure Method1; safecall;
    procedure Method2; safecall;
    procedure Method3; safecall;
    procedure Method11(Param1: Integer); safecall;
  end;

implementation

uses ComServ, Windows;

procedure ToleBaseClass.EventSinkChanged(const EventSink: IUnknown);
begin
  FEvents := EventSink as IBaseClassEvents;
  if FConnectionPoint <> nil then
     FSinkList := FConnectionPoint.SinkList;
end;

procedure ToleBaseClass.Initialize;
begin
  inherited Initialize;
  FConnectionPoints := TConnectionPoints.Create(Self);
  if AutoFactory.EventTypeInfo <> nil then
    FConnectionPoint := FConnectionPoints.CreateConnectionPoint(
      AutoFactory.EventIID, ckSingle, EventConnect)
  else FConnectionPoint := nil;
end;


procedure ToleBaseClass.Method1;
begin
  Windows.Beep(3000, 1000);
end;

procedure ToleBaseClass.Method2;
begin
  Windows.Beep(2000, 1000);
end;

procedure ToleBaseClass.Method3;
begin
  Windows.Beep(1000, 1000);
end;

procedure ToleBaseClass.Method11(Param1: Integer);
begin

end;

initialization
  TAutoObjectFactory.Create(ComServer, ToleBaseClass, Class_oleBaseClass,
    ciMultiInstance, tmApartment);
end.
