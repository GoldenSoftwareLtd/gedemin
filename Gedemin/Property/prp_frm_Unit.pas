// ShlTanya, 25.02.2019

unit prp_frm_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_createable_form, ExtCtrls, TB2Dock, TB2Toolbar, prp_DockForm_unit, TB2Item,
  ComCtrls, Db;

type
  Tprp_frm = class(TCreateableForm)
    tbdTop: TTBDock;
    VLSplitter: TSplitter;
    VRSplitter: TSplitter;
    HSplitter: TSplitter;
    LeftDockPanel: TPanel;
    RightDockPanel: TPanel;
    BottomDockPanel: TPanel;
    tbdLeft: TTBDock;
    tbdBottom: TTBDock;
    tbdRight: TTBDock;
    StatusBar: TStatusBar;
    procedure LeftDockPanelDockDrop(Sender: TObject;
      Source: TDragDockObject; X, Y: Integer);
    procedure LeftDockPanelDockOver(Sender: TObject;
      Source: TDragDockObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean);
    procedure BottomDockPanelDockOver(Sender: TObject;
      Source: TDragDockObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean);
    procedure LeftDockPanelUnDock(Sender: TObject; Client: TControl;
      NewTarget: TWinControl; var Allow: Boolean);
    procedure LeftDockPanelGetSiteInfo(Sender: TObject;
      DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
      var CanDock: Boolean);
    procedure RightDockPanelDockOver(Sender: TObject;
      Source: TDragDockObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure BottomDockPanelResize(Sender: TObject);
  private
    FReCalcDockBounds: Boolean;
    FBottomDockHeight: integer;
    procedure SetReCalcDockBounds(const Value: Boolean);
    procedure WMClose(var Message: TWMClose); message WM_CLOSE;
    { Private declarations }
  protected
    FDockFormList: TList;
    FShiftDown: Boolean;
    FVisibleForms: TList;
    procedure SetEnabled(Value: Boolean); override;
    procedure VisibleChanging; override;
    function ComputeDockingRect(Host: TWinControl; var DockRect: TRect; MousePos: TPoint): TAlign;
  public
    { Public declarations }
    procedure ShowDockPanel(APanel: TPanel; MakeVisible: Boolean;
      Client: TControl);
    procedure SaveSettings; override;
    procedure LoadSettings; override;
    procedure OnDockWindowDestroy(Sender: TDockableForm); virtual;
    procedure OnDockFormHide(Sender: TObject); virtual;
    procedure OnDockFormShow(Sender: TObject); virtual;
    procedure SignForm(F: TDockableForm);
    procedure UnSignForm(F: TDockableForm);
    property ReCalcDockBounds: Boolean read FReCalcDockBounds write SetReCalcDockBounds;
  end;

var
  prp_frm: Tprp_frm;

implementation

uses gd_directories_const, TabHost, ConjoinHost, gsStorage, Storages;

{$R *.DFM}

{ TForm1 }

procedure Tprp_frm.BottomDockPanelDockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
var
  ARect: TRect;
begin
  Accept := (Source.Control is TDockableForm) and
    TDockableForm(Source.Control).Dockable and
    (TPanel(Sender).VisibleDockClientCount = 0);

  if Accept then
  begin
    if (TPanel(Sender).Height <> 0) and
      (TPanel(Sender).Width <> 0) then
    begin
      if ComputeDockingRect(TWinControl(Sender), ARect, Point(X, Y)) <> alNone then
        Source.DockRect := ARect;
    end else
    begin
      //Modify the DockRect to preview dock area.
      if FBottomDockHeight > 0 then
        ARect.TopLeft := BottomDockPanel.ClientToScreen(
          Point(0, -FBottomDockHeight))
      else
        ARect.TopLeft := BottomDockPanel.ClientToScreen(
          Point(0, -Self.ClientHeight div 3));
      ARect.BottomRight := BottomDockPanel.ClientToScreen(
        Point(BottomDockPanel.Width, BottomDockPanel.Height));
      Source.DockRect := ARect;
    end;
  end;
end;

procedure Tprp_frm.LeftDockPanelDockDrop(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer);
begin
  //OnDockDrop gets called AFTER the client has actually docked,
  //so we check for DockClientCount = 1 before making the dock panel visible.
  if (Sender as TPanel).VisibleDockClientCount = 1 then
    ShowDockPanel(Sender as TPanel, True, nil);
  (Sender as TPanel).DockManager.ResetBounds(True);
  if not (Source.Control is TTabDockHost) and not (Source.Control is TConjoinDockHost) then
    with TDockableForm(Source.Control) do
    begin
      pCaption.Caption := '  ' + Caption;
      pCaption.Visible := True;
      pCaption.Top := 0;
    end;
  //Make DockManager repaints it's clients.    
end;

procedure Tprp_frm.LeftDockPanelDockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
var
  ARect: TRect;
begin
  Accept := (Source.Control is TDockableForm) and
    TDockableForm(Source.Control).Dockable and
    (TPanel(Sender).VisibleDockClientCount = 0);
  if Accept then
  begin
    //Modify the DockRect to preview dock area.
    ARect.TopLeft := LeftDockPanel.ClientToScreen(Point(0, 0));
    ARect.BottomRight := LeftDockPanel.ClientToScreen(
      Point(Self.ClientWidth div 3, LeftDockPanel.Height));
    Source.DockRect := ARect;
  end;
end;

procedure Tprp_frm.LeftDockPanelGetSiteInfo(Sender: TObject;
  DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
  var CanDock: Boolean);
begin
  //if CanDock is true, the panel will not automatically draw the preview rect.
  CanDock := (DockClient is TDockableForm) and
    ((TPanel(Sender).VisibleDockClientCount = 0) or ((TPanel(Sender).Height = 0) or
    (TPanel(Sender).Width = 0))) and TDockableForm(DockClient).Dockable;
end;

procedure Tprp_frm.LeftDockPanelUnDock(Sender: TObject; Client: TControl;
  NewTarget: TWinControl; var Allow: Boolean);
var
  VisibleCount, I: Integer;
begin
  with Client do
  begin
    UndockHeight := Height;
    UndockWidth := Width;
    with TDockableForm(Client) do
      pCaption.Visible := False;
  end;
  VisibleCount := 0;
  for I := 0  to (Sender as TPanel).DockClientCount - 1 do
  begin
    if ((Sender as TPanel).DockClients[I].Visible) and
      (Client <> (Sender as TPanel).DockClients[I]) then
      Inc(VisibleCount);
  end;
  //OnUnDock gets called BEFORE the client is undocked, in order to optionally
  //disallow the undock. DockClientCount is never 0 when called from this event.
  if (VisibleCount = 0){ or
     ((Sender as TPanel).DockClientCount = 1)} then
    ShowDockPanel(Sender as TPanel, False, nil);
end;

procedure Tprp_frm.ShowDockPanel(APanel: TPanel; MakeVisible: Boolean;
  Client: TControl);
begin
  //Client - the docked client to show if we are re-showing the panel.
  //Client is ignored if hiding the panel.

  //Since docking to a non-visible docksite isn't allowed, instead of setting
  //Visible for the panels we set the width to zero. The default InfluenceRect
  //for a control extends a few pixels beyond it's boundaries, so it is possible
  //to dock to zero width controls.

  //Don't try to hide a panel which has visible dock clients.
  if not MakeVisible and (APanel.VisibleDockClientCount > 1) then
    Exit;

  if APanel = LeftDockPanel then
    VLSplitter.Visible := MakeVisible
  else
  if APanel = BottomDockPanel then
    HSplitter.Visible := MakeVisible
  else
    VRSplitter.Visible := MakeVisible;

    if MakeVisible then
      if APanel = LeftDockPanel then
      begin
        if FReCalcDockBounds or (APanel.Width + 10 >= ClientWidth) or
          (APanel.Width = 0) then
          APanel.Width := ClientWidth div 3;
        VLSplitter.Left := APanel.Width + VLSplitter.Width;
        tbdLeft.Left := VLSplitter.Left + VLSplitter.Width;
      end else
      if APanel = BottomDockPanel then
      begin
{        if (APanel.VisibleDockClientCount = 1) and (Client <> nil) then
          APanel.Height := Client.Height;}
        if FReCalcDockBounds or (APanel.Height + 10 >= ClientHeight) or
            (APanel.Height = 0) then begin
          APanel.Height := FBottomDockHeight;
//          APanel.Height := ClientHeight div 3;
        end;

        APanel.Top := StatusBar.Top - APanel.Height;
        HSplitter.Top := ClientHeight - APanel.Height - HSplitter.Width;
        tbdBottom.Top := HSplitter.Top - tbdBottom.Height;
      end else
      begin
        if FReCalcDockBounds or (APanel.Width + 10 >= ClientWidth) or
          (APanel.Width = 0) then
          APanel.Width := ClientWidth div 3;
        VRSplitter.Left := APanel.Left - VLSplitter.Width;
        tbdRight.Left := VLSplitter.Left - tbdRight.Width;
      end
    else
      if APanel = LeftDockPanel then
        APanel.Width := 0
      else
      if APanel = BottomDockPanel then
        APanel.Height := 0
      else
        APanel.Width := 0;
end;

procedure Tprp_frm.RightDockPanelDockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
var
  ARect: TRect;
begin
  Accept := (Source.Control is TDockableForm) and
    TDockableForm(Source.Control).Dockable and
    (TPanel(Sender).VisibleDockClientCount = 0);
  if Accept then
  begin
    //Modify the DockRect to preview dock area.
    ARect.TopLeft := RightDockPanel.ClientToScreen(
      Point(-Self.ClientWidth div 3, 0));
    ARect.BottomRight := RightDockPanel.ClientToScreen(
      Point(RightDockPanel.Width, RightDockPanel.Height));
    Source.DockRect := ARect;
  end;
end;

procedure Tprp_frm.LoadSettings;
var
  F: TgsStorageFolder;
  Path: string;
begin
  inherited;

  Path := Self.Name;
  F := UserStorage.OpenFolder(Path, True);
  FBottomDockHeight := F.ReadInteger('BottomDockHeight', ClientHeight div 3);
  UserStorage.CloseFolder(F);
  //TBRegLoadPositions(Self, HKEY_CURRENT_USER, ClientRootRegistrySubKey + 'TB\' + Name);
end;

procedure Tprp_frm.SaveSettings;
var
  F: TgsStorageFolder;
  Path: string;
begin
  //TBRegSavePositions(Self, HKEY_CURRENT_USER, ClientRootRegistrySubKey + 'TB\' + Name);
  Path := Self.Name;
  F := UserStorage.OpenFolder(Path, True);
  F.WriteInteger('BottomDockHeight', FBottomDockHeight);
  UserStorage.CloseFolder(F);

  inherited;
end;

procedure Tprp_frm.FormCreate(Sender: TObject);
begin
  LeftDockPanel.Width := 0;
  RightDockPanel.Width := 0;
  BottomDockPanel.Height := 0;
  FDockFormList := TList.Create;
  FReCalcDockBounds := True;
  ShowSpeedButton := True;
end;

procedure Tprp_frm.OnDockWindowDestroy(Sender: TDockableForm);
begin
end;

procedure Tprp_frm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (Action = caHide) and FShiftDown then
    Action := caFree;
  FShiftDown := False;
end;

procedure Tprp_frm.FormDestroy(Sender: TObject);
begin
  //Высврбождаем докформы
  if FDockFormList <> nil then
  begin
    while FDockFormList.Count > 0 do
      TDockableForm(FDockFormList[0]).Free;
    FDockFormList.Free;
  end;
  if FVisibleForms <> nil then
    FVisibleForms.Free;
end;

procedure Tprp_frm.UnSignForm(F: TDockableForm);
var
  I: Integer;
begin
  if F <> nil then
  begin
    I := FDockFormList.IndexOf(F);
    if I > - 1 then
      FDockFormList.Delete(I);
  end;
end;

procedure Tprp_frm.SignForm(F: TDockableForm);
begin
  if F <> nil then
    FDockFormList.Add(F);
end;

procedure Tprp_frm.FormActivate(Sender: TObject);
var
  I: Integer;
  F: TCustomForm;
begin
  //Идея в следующем: При активации основного окна все привязанные
  //формы не задокированные к основной форме делать видимыми
  if FDockFormList <> nil then
  begin
    for I := 0 to FDockFormList.Count - 1 do
    begin
      if (TDockableForm(FDockFormList[I]).HostDockSite = nil) and
       TDockableForm(FDockFormList[I]).Visible and
       TDockableForm(FDockFormList[I]).Enabled and
       not TDockableForm(FDockFormList[I]).StayOnTop then
       begin
        F := TDockableForm(FDockFormList[I]);
        SetWindowPos(F.Handle, Handle, 0, 0, 0, 0,
          SWP_NOMOVE + SWP_NOSIZE + SWP_NOACTIVATE);
       end;
    end;
  end;
end;

procedure Tprp_frm.OnDockFormHide(Sender: TObject);
begin
end;

procedure Tprp_frm.OnDockFormShow(Sender: TObject);
begin
end;

procedure Tprp_frm.SetReCalcDockBounds(const Value: Boolean);
begin
  FReCalcDockBounds := Value;
end;

procedure Tprp_frm.WMClose(var Message: TWMClose);
begin
  FShiftDown := GetAsyncKeyState(VK_SHIFT) shr 1 > 0;
  inherited;
end;

procedure Tprp_frm.SetEnabled(Value: Boolean);
var
  I: Integer;
begin
  if FDockFormList <> nil then
    for I := 0 to FDockFormList.Count - 1 do
      TDockableForm(FDockFormList[I]).Enabled := Value;

  inherited;
end;

procedure Tprp_frm.VisibleChanging;
var
  I: Integer;
begin
  inherited;
  if FDockFormList <> nil then
  begin
    if FVisibleForms = nil then FVisibleForms := TList.Create;
    if not Visible then
    begin
      for I := 0 to FVisibleForms.Count - 1 do
        TDockableForm(FVisibleForms[I]).Visible := True;
      FVisibleForms.Clear;
    end else
    begin
      for I := 0 to FDockFormList.Count  - 1 do
        if (TDockableForm(FDockFormList[I]).HostDockSite = nil) and
          TDockableForm(FDockFormList[I]).Visible then
        begin
          TDockableForm(FDockFormList[I]).Visible := False;
          FVisibleForms.Add(FDockFormList[I]);
        end;
    end;
  end;
end;

function Tprp_frm.ComputeDockingRect(Host: TWinControl; var DockRect: TRect;
  MousePos: TPoint): TAlign;
var
  DockTopRect,
  DockLeftRect,
  DockBottomRect,
  DockRightRect,
  DockCenterRect: TRect;
begin
  Result := alNone;
  //divide form up into docking "Zones"
  DockLeftRect.TopLeft := Point(0, 0);
  DockLeftRect.BottomRight := Point(Host.ClientWidth div 5, Host.ClientHeight);

  DockTopRect.TopLeft := Point(Host.ClientWidth div 5, 0);
  DockTopRect.BottomRight := Point(Host.ClientWidth div 5 * 4, Host.ClientHeight div 5);

  DockRightRect.TopLeft := Point(Host.ClientWidth div 5 * 4, 0);
  DockRightRect.BottomRight := Point(Host.ClientWidth, Host.ClientHeight);

  DockBottomRect.TopLeft := Point(Host.ClientWidth div 5, Host.ClientHeight div 5 * 4);
  DockBottomRect.BottomRight := Point(Host.ClientWidth div 5 * 4, Host.ClientHeight);

  DockCenterRect.TopLeft := Point(Host.ClientWidth div 5, Host.ClientHeight div 5);
  DockCenterRect.BottomRight := Point(Host.ClientWidth div 5 * 4, Host.ClientHeight div 5 * 4);

  //Find out where the mouse cursor is, to decide where to draw dock preview.
  if PtInRect(DockLeftRect, MousePos) then
    begin
      Result := alLeft;
      DockRect := DockLeftRect;
      DockRect.Right := Host.ClientWidth div 2;
    end
  else
    if PtInRect(DockTopRect, MousePos) then
      begin
        Result := alTop;
        DockRect := DockTopRect;
        DockRect.Left := 0;
        DockRect.Right := Host.ClientWidth;
        DockRect.Bottom := Host.ClientHeight div 2;
      end
    else
      if PtInRect(DockRightRect, MousePos) then
        begin
          Result := alRight;
          DockRect := DockRightRect;
          DockRect.Left := Host.ClientWidth div 2;
        end
      else
        if PtInRect(DockBottomRect, MousePos) then
          begin
            Result := alBottom;
            DockRect := DockBottomRect;
            DockRect.Left := 0;
            DockRect.Right := Host.ClientWidth;
            DockRect.Top := Host.ClientHeight div 2;
         end
        else
          if PtInRect(DockCenterRect, MousePos) then
          begin
            Result := alClient;
            DockRect := DockCenterRect;
          end;
  if Result = alNone then
  begin
//    Result := alClient;
    Exit;
  end;

  //DockRect is in screen coordinates.
  DockRect.TopLeft := Host.ClientToScreen(DockRect.TopLeft);
  DockRect.BottomRight := Host.ClientToScreen(DockRect.BottomRight);
end;

procedure Tprp_frm.BottomDockPanelResize(Sender: TObject);
begin
  if (TPanel(Sender).Height = 0) or not TForm(TPanel(Sender).Owner).Showing then Exit;
  FBottomDockHeight:= TPanel(Sender).Height;
end;

end.
