unit TabHost;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, gd_createable_form, prp_DockForm_unit, SuperPageControl, Menus,
  ActnList, ExtCtrls;

type
  TTabDockHost = class(TDockableForm)
    PageControl1: TSuperPageControl;
    ActionList: TActionList;
    actClosePage: TAction;
    N2: TMenuItem;
    N3: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PageControl1UnDock(Sender: TObject; Client: TControl;
      NewTarget: TWinControl; var Allow: Boolean);
    procedure PageControl1DockDrop(Sender: TObject;
      Source: TDragDockObject; X, Y: Integer);
    procedure PageControl1GetSiteInfo(Sender: TObject;
      DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
      var CanDock: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormGetSiteInfo(Sender: TObject; DockClient: TControl;
      var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
    procedure PageControl1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure actClosePageUpdate(Sender: TObject);
    procedure actClosePageExecute(Sender: TObject);
  private
   { Private declarations }
   FTabSheet: TSuperTabSheet;
   procedure UpdateCaption;
  public
    { Public declarations }
  end;

var
  TabDockHost: TTabDockHost;

implementation
uses ConjoinHost, prp_frm_Unit;
{$R *.DFM}

procedure TTabDockHost.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  ARect: TRect;
  H: TWinControl;
  I: Integer;
  V: Boolean;
begin
  if Application.Terminated then
  begin
    Action := caFree;
    Exit;
  end;

  if PageControl1.DockClientCount = 1 then
  begin
    V := PageControl1.VisibleDockClientCount = 1;
    Hide;
    H := HostDockSite;
    ARect.TopLeft := ClientToScreen(Point(0, 0));
    ARect.BottomRight := ClientToScreen(Point(Width, Height));
    ManualFloat(ARect);

    with TDockableForm(PageControl1.DockClients[0]) do
    begin
      ARect.TopLeft := ClientToScreen(Point(0, 0));
      ARect.BottomRight := ClientToScreen(Point(UndockWidth, UndockHeight));
      ManualFloat(ARect);
      if H <> nil then
        ManualDock(H, nil, alClient);
      Visible := V;
    end;
    Action := caFree;
  end else
  begin
    for I := 0 to PageControl1.DockClientCount - 1do
      PageControl1.DockClients[I].Hide;
    Hide;
    Action := caHide;
  end;
end;

procedure TTabDockHost.PageControl1UnDock(Sender: TObject;
  Client: TControl; NewTarget: TWinControl; var Allow: Boolean);
begin
  //only 2 dock clients means the host must be destroyed and
  //the remaining window undocked to its old position and size.
  Allow := (NewTarget <> PageControl1) and (NewTarget <> Self);

  if Allow and (PageControl1.VisibleDockClientCount <= 2) and
    not Application.Terminated  then
  begin
    if (HostDockSite <> nil) and (PageControl1.VisibleDockClientCount = 2) then
    begin
    end else
      PostMessage(Self.Handle, WM_CLOSE, 0, 0);
  end;
  UpdateCaption;
end;

procedure TTabDockHost.PageControl1GetSiteInfo(Sender: TObject;
  DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
  var CanDock: Boolean);
begin
  CanDock := False;
end;

procedure TTabDockHost.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  for I := PageControl1.DockClientCount - 1 downto 0 do
    PageControl1.DockClients[I].Free;

  inherited;
end;

procedure TTabDockHost.PageControl1DockDrop(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer);
var
  T: TTabDockHost;
begin
  if Source.Control is TTabDockHost then
  begin
    T := TTabDockHost(Source.Control);
    while T.PageControl1.DockClientCount > 0 do
      TDockableForm(T.PageControl1.DockClients[0]).ManualDock(PageControl1, nil, alClient);
    PostMessage(T.Handle, WM_CLOSE, 0, 0);
  end else
    Source.Control.ManualDock(PageControl1, nil, alClient);
  UpdateCaption;   
end;

procedure TTabDockHost.FormGetSiteInfo(Sender: TObject;
  DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
  var CanDock: Boolean);
begin
  CanDock := False;
end;

procedure TTabDockHost.UpdateCaption;
var
  S: string;
  I: Integer;
begin
  S := '';
  for I := 0 to PageControl1.DockClientCount - 1 do
  begin
    if S > '' then
      S := S + ', ';
    if PageControl1.DockClients[I].Visible then
      S := S + TDockableForm(PageControl1.DockClients[I]).Caption;
  end;
  Caption := S;
end;

procedure TTabDockHost.PageControl1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Index: Integer;
  P: TPoint;
begin
  if mbRight = Button then
  begin
    Index := PageControl1.GetTabIndexFromXY(X, Y);
    if Index > -1 then
    begin
      FTabSheet := PageControl1.Pages[Index];
      P := ClientToScreen(Point(X, Y));
      PopupMenu.Popup(P.X, P.Y);
    end;
  end else
    inherited;
end;

procedure TTabDockHost.actClosePageUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := FTabSheet <> nil;
end;

procedure TTabDockHost.actClosePageExecute(Sender: TObject);
var
  I: Integer;
begin
  if FTabSheet <> nil then
  begin
    for I := FTabSheet.ControlCount - 1 downto 0 do
    begin
      if FTabSheet.Controls[I] is TDockableForm then
      begin
        TDockableForm(FTabSheet.Controls[I]).Hide;
        Exit;
      end;
    end;
  end;
end;

end.

