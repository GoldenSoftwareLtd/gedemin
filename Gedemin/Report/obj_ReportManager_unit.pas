// ShlTanya, 27.02.2019

unit obj_ReportManager_unit;

interface

uses
  ComObj, ActiveX, AxCtrls, Classes, ReportManager_TLB, StdVcl, rp_ServerManager_unit;

type
  TSvrMng = class(TAutoObject, IConnectionPointContainer, ISvrMng)
  private
    { Private declarations }
    FConnectionPoints: TConnectionPoints;
    FConnectionPoint: TConnectionPoint;
    FSinkList: TList;
    FEvents: ISvrMngEvents;
    FIsServerActive: Word;
  public
    procedure Initialize; override;
    procedure UpdateEvent(const AnNewState: Word);
  protected
    { Protected declarations }
    property ConnectionPoints: TConnectionPoints read FConnectionPoints
      implements IConnectionPointContainer;
    procedure EventSinkChanged(const EventSink: IUnknown); override;
    procedure Close; safecall;
    procedure Options; safecall;
    procedure Rebuild; safecall;
    procedure Refresh; safecall;
    procedure Run; safecall;
  end;

implementation

uses ComServ, CheckServerLoad_unit, rp_report_const;

procedure TSvrMng.EventSinkChanged(const EventSink: IUnknown);
begin
  FEvents := EventSink as ISvrMngEvents;
  if FConnectionPoint <> nil then
     FSinkList := FConnectionPoint.SinkList;
end;

procedure TSvrMng.Initialize;
begin
  inherited Initialize;

  FConnectionPoints := TConnectionPoints.Create(Self);
  if AutoFactory.EventTypeInfo <> nil then
    FConnectionPoint := FConnectionPoints.CreateConnectionPoint(
      AutoFactory.EventIID, ckMulti, EventConnect)
  else FConnectionPoint := nil;

  if ServerManager <> nil then
    ServerManager.OnUpdateEvent := UpdateEvent;
  FIsServerActive := CheckReportServerActivate + 1;
end;


procedure TSvrMng.Close;
begin
  if ServerManager <> nil then
    ServerManager.SendMessage(1, WM_USER_CLOSE);
end;

procedure TSvrMng.Options;
begin

end;

procedure TSvrMng.Rebuild;
begin
  if ServerManager <> nil then
    ServerManager.SendMessage(1, WM_USER_REBUILD);
end;

procedure TSvrMng.Refresh;
begin
  if ServerManager <> nil then
    ServerManager.SendMessage(1, WM_USER_REFRESH);
end;

procedure TSvrMng.Run;
begin
  if ServerManager <> nil then
    ServerManager.RunServer;
end;

procedure TSvrMng.UpdateEvent(const AnNewState: Word);
begin
  if not (FIsServerActive = AnNewState) and (FEvents <> nil) then
  begin
    FIsServerActive := AnNewState;
    FEvents.ChangeState(FIsServerActive);
  end;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TSvrMng, Class_SvrMng,
    ciMultiInstance, tmApartment);
end.
